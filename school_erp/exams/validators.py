from datetime import datetime, timedelta

from django.core.exceptions import ValidationError
from django.utils import timezone

from .models import ExamSchedule, Question, Student, StudentAnswer, TeacherAvailability


def validation_error_text(exc):
    if hasattr(exc, 'messages'):
        return '; '.join(str(message) for message in exc.messages)
    return str(exc)


def _window(date, start_time, duration):
    start = datetime.combine(date, start_time)
    return start, start + timedelta(minutes=duration)


def _overlaps(date_a, start_a, duration_a, date_b, start_b, duration_b):
    start_a_dt, end_a_dt = _window(date_a, start_a, duration_a)
    start_b_dt, end_b_dt = _window(date_b, start_b, duration_b)
    return start_a_dt < end_b_dt and start_b_dt < end_a_dt


def validate_exam_schedule(exam_data):
    """Validate exam schedule for clashes with other exams for the same class."""
    class_id = exam_data.get('class_assigned')
    date = exam_data.get('date')
    start_time = exam_data.get('start_time')
    duration = exam_data.get('duration_minutes')
    exam_id = exam_data.get('exam_id')

    if not all([class_id, date, start_time, duration]):
        raise ValidationError("Exam schedule is missing class, date, start time, or duration")

    nearby_dates = [date - timedelta(days=1), date, date + timedelta(days=1)]
    existing_exams = ExamSchedule.objects.filter(
        class_assigned_id=class_id,
        date__in=nearby_dates,
    )
    if exam_id:
        existing_exams = existing_exams.exclude(pk=exam_id)

    for exam in existing_exams:
        if _overlaps(date, start_time, duration, exam.date, exam.start_time, exam.duration_minutes):
            raise ValidationError(f"Exam clash detected for class {class_id} on {date}")


def validate_teacher_availability(teacher_id, date, start_time, duration, exam_id=None):
    """Validate teacher availability and that the teacher is not already supervising."""
    if not all([teacher_id, date, start_time, duration]):
        raise ValidationError("Teacher availability check is missing required values")

    exam_start, exam_end = _window(date, start_time, duration)
    if exam_end.date() != exam_start.date():
        raise ValidationError("Exam must start and end on the same day")

    available_slots = TeacherAvailability.objects.filter(teacher_id=teacher_id, date=date)
    if not available_slots.exists():
        raise ValidationError(f"Teacher {teacher_id} has no availability set for {date}")

    exam_end_time = exam_end.time()
    covered = any(
        slot.start_time <= start_time and slot.end_time >= exam_end_time
        for slot in available_slots
    )
    if not covered:
        raise ValidationError(f"Teacher {teacher_id} is not available at the specified time")

    nearby_dates = [date - timedelta(days=1), date, date + timedelta(days=1)]
    other_duties = ExamSchedule.objects.filter(teacher_id=teacher_id, date__in=nearby_dates)
    if exam_id:
        other_duties = other_duties.exclude(pk=exam_id)
    for exam in other_duties:
        if _overlaps(date, start_time, duration, exam.date, exam.start_time, exam.duration_minutes):
            raise ValidationError(f"Exam clash detected for teacher {teacher_id} on {date}")
    return True


def validate_question_paper(questions):
    """Validate question paper structure and total marks."""
    if not questions:
        raise ValidationError("Question paper cannot be empty")

    total_marks = 0
    for question in questions:
        marks = getattr(question, 'marks', None)
        if marks is None and isinstance(question, dict):
            marks = question.get('marks')
        if marks is None or marks <= 0:
            raise ValidationError("Each question must have marks greater than 0")
        total_marks += marks

    if total_marks <= 0:
        raise ValidationError("Total marks must be greater than 0")
    return True


def _answer_value(answer, *names):
    if isinstance(answer, dict):
        for name in names:
            if name in answer:
                return answer[name]
        return None
    for name in names:
        if hasattr(answer, name):
            value = getattr(answer, name)
            if value is not None:
                return value
    return None


def _option_is_valid(selected_option, options):
    if isinstance(options, dict):
        return selected_option in options
    if isinstance(options, (list, tuple)):
        return selected_option in options
    return False


def _ensure_exam_window_open(exam, now=None):
    tz = timezone.get_current_timezone()
    start = datetime.combine(exam.date, exam.start_time)
    if timezone.is_naive(start):
        start = timezone.make_aware(start, tz)
    end = start + timedelta(minutes=exam.duration_minutes)
    current = now or timezone.now()
    if timezone.is_naive(current):
        current = timezone.make_aware(current, tz)
    if current < start:
        raise ValidationError("Exam has not started yet")
    if current >= end:
        raise ValidationError("Exam has ended")


def validate_student_answers(student_id, exam_schedule_id, answers, require_open_window=False, now=None):
    """Validate student answers before they are stored or graded."""
    if answers is None:
        answers = []
    if not isinstance(answers, (list, tuple)):
        raise ValidationError("Answers must be a list")

    try:
        student = Student.objects.get(id=student_id)
    except Student.DoesNotExist:
        raise ValidationError("Invalid student ID")

    try:
        exam = ExamSchedule.objects.get(id=exam_schedule_id)
    except ExamSchedule.DoesNotExist:
        raise ValidationError("Invalid exam schedule")

    if student.enrolled_class_id != exam.class_assigned_id:
        raise ValidationError("Student is not enrolled in the class for this exam")

    if require_open_window:
        _ensure_exam_window_open(exam, now=now)

    seen_questions = set()
    for answer in answers:
        question_id = _answer_value(answer, 'question_id', 'question')
        if hasattr(question_id, 'id'):
            question_id = question_id.id
        selected_option = _answer_value(answer, 'selected_option')
        if not question_id or selected_option in (None, ''):
            raise ValidationError("Each answer needs a question and a selected option")
        if question_id in seen_questions:
            raise ValidationError(f"Duplicate answer for question {question_id}")
        seen_questions.add(question_id)

        try:
            question = Question.objects.get(id=question_id)
        except Question.DoesNotExist:
            raise ValidationError(f"Invalid question {question_id}")

        if question.subject_id != exam.subject_id:
            raise ValidationError(f"Question {question.id} does not belong to this exam subject")
        if not question.options:
            raise ValidationError(f"Question {question.id} has no options")
        if not _option_is_valid(selected_option, question.options):
            raise ValidationError(f"Invalid option selected for question {question.id}")

    return True


def calculate_grace_marks(student_id, exam_schedule_id, marks_obtained):
    """Calculate grace marks based on school policy.

    A student who is at most 5 marks short of the passing mark receives
    exactly the marks needed to pass. Larger gaps receive no grace.
    """
    exam = ExamSchedule.objects.get(id=exam_schedule_id)
    passing_marks = float(exam.passing_marks)
    raw_marks = float(marks_obtained)
    max_grace = 5

    if raw_marks < passing_marks:
        needed_grace = passing_marks - raw_marks
        if needed_grace <= max_grace:
            return round(needed_grace, 2)
    return 0


def validate_result_calculation(student_id, exam_schedule_id, marks_obtained, grace_marks=0):
    """Validate result calculation including grace marks.

    ``marks_obtained`` is the raw score before grace is added.
    """
    raw_marks = float(marks_obtained)
    grace = float(grace_marks or 0)
    if raw_marks < 0:
        raise ValidationError("Marks obtained cannot be negative")
    if grace < 0:
        raise ValidationError("Grace marks cannot be negative")

    exam = ExamSchedule.objects.get(id=exam_schedule_id)
    total_marks = float(exam.total_marks)
    if raw_marks > total_marks:
        raise ValidationError("Marks obtained cannot exceed total marks")

    calculated_grace = calculate_grace_marks(student_id, exam_schedule_id, raw_marks)
    if grace - calculated_grace > 0.001:
        raise ValidationError("Invalid grace marks applied")
    if raw_marks + grace > total_marks + 0.001:
        raise ValidationError("Marks obtained cannot exceed total marks")
    return True


def score_answers(answers):
    """Score stored answers from the question key. Client-supplied marks are ignored."""
    total = 0.0
    for answer in answers:
        if isinstance(answer, StudentAnswer):
            question = answer.question
            selected = answer.selected_option
        else:
            question = answer
            selected = _answer_value(answer, 'selected_option')
        if selected == question.correct_option:
            total += float(question.marks)
    return total
