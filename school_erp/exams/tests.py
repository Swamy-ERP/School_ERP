from datetime import date, datetime, time, timedelta
from decimal import Decimal

from django.contrib.auth import get_user_model
from django.core.exceptions import ValidationError
from django.utils import timezone
from rest_framework.test import APITestCase

from exams.models import (
    Board, Class, ExamMode, ExamPattern, ExamResult, ExamSchedule, ExamType,
    GradeScale, Question, Student, Subject, Teacher, TeacherAvailability, Venue,
)
from exams.validators import (
    calculate_grace_marks, validate_question_paper, validate_result_calculation,
    validate_student_answers,
)
from exams import views as exam_views


class ExamWorkflowTests(APITestCase):
    def setUp(self):
        user_model = get_user_model()
        self.user = user_model.objects.create_user(username='examadmin', password='pass12345')
        self.client.force_authenticate(self.user)

        self.board = Board.objects.create(name='State Board')
        self.klass = Class.objects.create(name='10-A', board=self.board)
        self.other_class = Class.objects.create(name='10-B', board=self.board)
        self.math = Subject.objects.create(name='Mathematics', code='MATH', board=self.board)
        self.science = Subject.objects.create(name='Science', code='SCI', board=self.board)
        self.teacher = Teacher.objects.create(name='Ada')
        self.other_teacher = Teacher.objects.create(name='Grace')
        self.venue = Venue.objects.create(name='Hall 1', capacity=40)
        self.exam_type = ExamType.objects.create(name='Midterm')
        self.pattern = ExamPattern.objects.create(name='Theory', board=self.board)
        self.exam_date = date(2026, 3, 2)
        self._available(self.teacher, self.exam_date)
        self._available(self.other_teacher, self.exam_date)
        self.student = Student.objects.create(name='Anil', student_id='S1', enrolled_class=self.klass)
        self.other_student = Student.objects.create(name='Bina', student_id='S2', enrolled_class=self.other_class)
        GradeScale.objects.create(name='Fail', min_score=0, max_score=34)
        GradeScale.objects.create(name='Pass', min_score=35, max_score=40)

    def _available(self, teacher, day, start=time(9, 0), end=time(17, 0)):
        return TeacherAvailability.objects.create(
            teacher=teacher, date=day, start_time=start, end_time=end,
        )

    def _exam(self, **overrides):
        payload = dict(
            exam_type=self.exam_type,
            exam_pattern=self.pattern,
            subject=self.math,
            class_assigned=self.klass,
            teacher=self.teacher,
            mode=ExamMode.OFFLINE,
            date=self.exam_date,
            start_time=time(9, 0),
            duration_minutes=60,
            venue=self.venue,
            total_marks=Decimal('40'),
            passing_marks=Decimal('35'),
        )
        payload.update(overrides)
        return ExamSchedule.objects.create(**payload)

    def _exam_payload(self, **overrides):
        payload = {
            'duration': 60,
            'students': [self.student.id],
            'venue_id': self.venue.id,
            'teacher_id': self.teacher.id,
            'exam_type_id': self.exam_type.id,
            'exam_pattern_id': self.pattern.id,
            'subject_id': self.math.id,
            'class_id': self.klass.id,
            'total_marks': '40',
            'passing_marks': '35',
        }
        payload.update(overrides)
        return payload

    def test_overlapping_class_exams_are_rejected_including_contained_intervals(self):
        self._exam(subject=self.science, start_time=time(10, 0), duration_minutes=60)
        with self.assertRaises(ValidationError):
            self._exam(start_time=time(9, 0), duration_minutes=180)

    def test_back_to_back_exams_are_allowed(self):
        self._exam(start_time=time(9, 0), duration_minutes=60)
        later = self._exam(subject=self.science, start_time=time(10, 0), duration_minutes=60)
        self.assertEqual(later.start_time, time(10, 0))

    def test_updating_an_exam_does_not_clash_with_itself(self):
        exam = self._exam()
        exam.duration_minutes = 90
        exam.save()

        self._exam(subject=self.science, start_time=time(12, 0), duration_minutes=60)
        exam.duration_minutes = 240
        with self.assertRaises(ValidationError):
            exam.save()

    def test_teacher_cannot_supervise_two_overlapping_exams(self):
        self._exam()
        with self.assertRaises(ValidationError):
            self._exam(
                class_assigned=self.other_class,
                subject=self.science,
                start_time=time(9, 30),
            )

    def test_passing_marks_cannot_exceed_total(self):
        with self.assertRaises(ValidationError):
            self._exam(passing_marks=Decimal('50'), total_marks=Decimal('40'))

    def test_smart_schedule_separates_same_class_and_reuses_the_hall(self):
        response = self.client.post('/api/smart-schedule/', {
            'start_date': '2026-03-02',
            'venues': {str(self.venue.id): 6},
            'exams': [
                self._exam_payload(students=[1, 2, 3, 4, 5, 6]),
                self._exam_payload(subject_id=self.science.id, students=[1, 2, 3, 4, 5, 6]),
            ],
        }, format='json')

        self.assertEqual(response.status_code, 200, response.content)
        scheduled = response.json()['scheduled_exams']
        self.assertEqual(
            [row['start_time'] for row in scheduled],
            ['09:00', '10:30'],
        )
        self.assertEqual(ExamSchedule.objects.count(), 2)

    def test_smart_schedule_runs_parallel_exams_when_the_hall_has_room(self):
        response = self.client.post('/api/smart-schedule/', {
            'start_date': '2026-03-02',
            'venues': {str(self.venue.id): 20},
            'exams': [
                self._exam_payload(students=[1, 2, 3, 4, 5, 6]),
                self._exam_payload(
                    subject_id=self.science.id,
                    class_id=self.other_class.id,
                    teacher_id=self.other_teacher.id,
                    students=[7, 8, 9, 10, 11, 12],
                ),
            ],
        }, format='json')

        self.assertEqual(response.status_code, 200, response.content)
        times = [row['start_time'] for row in response.json()['scheduled_exams']]
        self.assertEqual(times, ['09:00', '09:00'])

    def test_smart_schedule_reports_when_no_slot_exists(self):
        original_window = exam_views.PLANNING_WINDOW
        exam_views.PLANNING_WINDOW = timedelta(hours=3)
        try:
            response = self.client.post('/api/smart-schedule/', {
                'start_date': '2026-03-02',
                'venues': {str(self.venue.id): 5},
                'exams': [self._exam_payload(students=[1, 2, 3, 4, 5, 6])],
            }, format='json')
        finally:
            exam_views.PLANNING_WINDOW = original_window

        self.assertEqual(response.status_code, 400)
        self.assertIn('Unable to schedule', response.json()['error'])
        self.assertEqual(ExamSchedule.objects.count(), 0)

    def test_schedule_requires_authentication(self):
        self.client.force_authenticate(user=None)
        response = self.client.post('/api/smart-schedule/', {}, format='json')
        self.assertEqual(response.status_code, 401)

    def _questions(self):
        return [
            Question.objects.create(
                subject=self.math,
                text=f'Question {index}',
                options={'A': 'right', 'B': 'wrong'},
                correct_option='A',
                marks=10,
            )
            for index in range(4)
        ]

    def test_evaluate_applies_grace_marks_and_stores_the_result(self):
        exam = self._exam()
        questions = self._questions()
        answers = [
            {'question_id': questions[0].id, 'selected_option': 'A'},
            {'question_id': questions[1].id, 'selected_option': 'A'},
            {'question_id': questions[2].id, 'selected_option': 'A'},
            {'question_id': questions[3].id, 'selected_option': 'B'},
        ]
        response = self.client.post('/api/evaluate/', {
            'student_id': self.student.id,
            'exam_schedule_id': exam.id,
            'answers': answers,
        }, format='json')

        self.assertEqual(response.status_code, 200, response.content)
        body = response.json()
        self.assertEqual(body['total_score'], 30)
        self.assertEqual(body['grace_marks'], 5)
        self.assertEqual(body['final_score'], 35)
        self.assertEqual(body['grade'], 'Pass')

        result = ExamResult.objects.get(student=self.student, exam_schedule=exam)
        self.assertEqual(result.marks_obtained, 35)
        self.assertEqual(result.grace_marks, 5)
        self.assertFalse(result.is_manual)
        self.assertEqual(result.graded_scale.name, 'Pass')

    def test_evaluate_withholds_grace_when_the_gap_is_larger_than_five(self):
        exam = self._exam()
        questions = self._questions()
        answers = [
            {'question_id': question.id, 'selected_option': 'B'}
            for question in questions
        ]
        response = self.client.post('/api/evaluate/', {
            'student_id': self.student.id,
            'exam_schedule_id': exam.id,
            'answers': answers,
        }, format='json')

        self.assertEqual(response.status_code, 200, response.content)
        body = response.json()
        self.assertEqual(body['total_score'], 0)
        self.assertEqual(body['grace_marks'], 0)
        self.assertEqual(body['grade'], 'Fail')
        self.assertEqual(calculate_grace_marks(self.student.id, exam.id, 32), 3)

    def test_evaluate_rejects_invalid_answers(self):
        exam = self._exam()
        question = self._questions()[0]
        science_question = Question.objects.create(
            subject=self.science,
            text='Science question',
            options={'A': 'yes', 'B': 'no'},
            correct_option='A',
            marks=10,
        )

        invalid_option = self.client.post('/api/evaluate/', {
            'student_id': self.student.id,
            'exam_schedule_id': exam.id,
            'answers': [{'question_id': question.id, 'selected_option': 'Z'}],
        }, format='json')
        self.assertEqual(invalid_option.status_code, 400)
        self.assertEqual(ExamResult.objects.count(), 0)

        wrong_subject = self.client.post('/api/evaluate/', {
            'student_id': self.student.id,
            'exam_schedule_id': exam.id,
            'answers': [{'question_id': science_question.id, 'selected_option': 'A'}],
        }, format='json')
        self.assertEqual(wrong_subject.status_code, 400)

        duplicate = self.client.post('/api/evaluate/', {
            'student_id': self.student.id,
            'exam_schedule_id': exam.id,
            'answers': [
                {'question_id': question.id, 'selected_option': 'A'},
                {'question_id': question.id, 'selected_option': 'B'},
            ],
        }, format='json')
        self.assertEqual(duplicate.status_code, 400)

        other_class = self.client.post('/api/evaluate/', {
            'student_id': self.other_student.id,
            'exam_schedule_id': exam.id,
            'answers': [{'question_id': question.id, 'selected_option': 'A'}],
        }, format='json')
        self.assertEqual(other_class.status_code, 400)

    def test_exam_window_uses_the_full_date_and_time(self):
        exam = self._exam()
        start = timezone.make_aware(datetime.combine(exam.date, exam.start_time))
        with self.assertRaises(ValidationError):
            validate_student_answers(
                self.student.id, exam.id, [], require_open_window=True,
                now=start - timedelta(minutes=1),
            )
        validate_student_answers(
            self.student.id, exam.id, [], require_open_window=True, now=start,
        )
        with self.assertRaises(ValidationError):
            validate_student_answers(
                self.student.id, exam.id, [], require_open_window=True,
                now=start + timedelta(minutes=exam.duration_minutes),
            )

    def test_result_validation_rejects_negative_marks_and_excess_grace(self):
        exam = self._exam()
        with self.assertRaises(ValidationError):
            validate_result_calculation(self.student.id, exam.id, -1, 0)
        with self.assertRaises(ValidationError):
            validate_result_calculation(self.student.id, exam.id, 50, 0)
        with self.assertRaises(ValidationError):
            validate_result_calculation(self.student.id, exam.id, 30, 10)

    def test_question_paper_cannot_be_empty(self):
        with self.assertRaises(ValidationError):
            validate_question_paper([])
