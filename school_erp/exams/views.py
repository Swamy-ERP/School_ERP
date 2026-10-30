from datetime import datetime, timedelta
from decimal import Decimal
from collections import defaultdict

from django.core.exceptions import ValidationError
from django.http import JsonResponse
from rest_framework import viewsets
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated

from .models import (
    Board, Class, Subject, ExamType, ExamPattern, Venue, ExamSchedule,
    TeacherAvailability, StudentAnswer, ExamResult, ExamMode, GradeScale,
)
from .serializers import (
    BoardSerializer, ClassSerializer, SubjectSerializer, ExamTypeSerializer,
    ExamPatternSerializer, VenueSerializer, ExamScheduleSerializer,
)
from .validators import (
    calculate_grace_marks,
    score_answers,
    validate_result_calculation,
    validate_student_answers,
    validation_error_text,
)


class BoardViewSet(viewsets.ModelViewSet):
    queryset = Board.objects.all()
    serializer_class = BoardSerializer
    permission_classes = [IsAuthenticated]


class ClassViewSet(viewsets.ModelViewSet):
    queryset = Class.objects.all()
    serializer_class = ClassSerializer
    permission_classes = [IsAuthenticated]


class SubjectViewSet(viewsets.ModelViewSet):
    queryset = Subject.objects.all()
    serializer_class = SubjectSerializer
    permission_classes = [IsAuthenticated]


class ExamTypeViewSet(viewsets.ModelViewSet):
    queryset = ExamType.objects.all()
    serializer_class = ExamTypeSerializer
    permission_classes = [IsAuthenticated]


class ExamPatternViewSet(viewsets.ModelViewSet):
    queryset = ExamPattern.objects.all()
    serializer_class = ExamPatternSerializer
    permission_classes = [IsAuthenticated]


class VenueViewSet(viewsets.ModelViewSet):
    queryset = Venue.objects.all()
    serializer_class = VenueSerializer
    permission_classes = [IsAuthenticated]


class ExamScheduleViewSet(viewsets.ModelViewSet):
    queryset = ExamSchedule.objects.all()
    serializer_class = ExamScheduleSerializer
    permission_classes = [IsAuthenticated]


def is_teacher_available(teacher_id, date, start_time, duration):
    exam_end = datetime.combine(date, start_time) + timedelta(minutes=duration)
    if exam_end.date() != date:
        return False
    slots = TeacherAvailability.objects.filter(teacher_id=teacher_id, date=date)
    exam_end_time = exam_end.time()
    return any(slot.start_time <= start_time and slot.end_time >= exam_end_time for slot in slots)


def _venue_capacity(venues, venue_id):
    if str(venue_id) in venues:
        return int(venues[str(venue_id)])
    if venue_id in venues:
        return int(venues[venue_id])
    return 0


def _venue_is_full(bookings, current_time, duration, student_count, capacity):
    """A hall can be reused after an exam; capacity applies to overlapping exams only."""
    current_end = current_time + timedelta(minutes=duration)
    occupied = 0
    for previous_start, previous_duration, count in bookings:
        previous_end = previous_start + timedelta(minutes=previous_duration)
        if current_time < previous_end and previous_start < current_end:
            occupied += count
    return occupied + student_count > capacity


def _students_overlap(booked, current_time, duration):
    current_end = current_time + timedelta(minutes=duration)
    for previous_start, previous_duration in booked:
        previous_end = previous_start + timedelta(minutes=previous_duration)
        if current_time < previous_end and previous_start < current_end:
            return True
    return False


def _is_scheduling_clash(exc):
    text = validation_error_text(exc).lower()
    return 'clash' in text or 'not available' in text or 'no availability' in text


PLANNING_WINDOW = timedelta(days=14)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def smart_schedule_view(request):
    try:
        data = request.data
        exams = data.get('exams', [])
        venues = data.get('venues', {})
        start_date = datetime.strptime(data.get('start_date', '2025-09-10'), "%Y-%m-%d").date()

        if not exams:
            raise ValidationError("No exams provided for scheduling")
        if not venues:
            raise ValidationError("No venues provided for scheduling")

        schedule = []
        student_exam_times = defaultdict(list)
        venue_bookings = defaultdict(list)
        current_time = datetime.combine(start_date, datetime.strptime("09:00", "%H:%M").time())
        deadline = datetime.combine(start_date, datetime.strptime("09:00", "%H:%M").time()) + PLANNING_WINDOW

        for exam in exams:
            required_fields = [
                'duration', 'students', 'venue_id', 'teacher_id',
                'exam_type_id', 'exam_pattern_id', 'subject_id', 'class_id',
            ]
            if not all(field in exam for field in required_fields):
                raise ValidationError(f"Missing required fields in exam data: {required_fields}")

            duration = int(exam["duration"])
            if duration <= 0:
                raise ValidationError("Duration must be greater than 0")
            students = exam["students"]
            if not isinstance(students, list):
                raise ValidationError("Exam students must be a list")
            venue_id = exam["venue_id"]
            teacher_id = exam["teacher_id"]
            scheduled = False
            step = timedelta(minutes=duration + 30)

            while not scheduled:
                if current_time > deadline:
                    raise ValidationError(
                        f"Unable to schedule class {exam['class_id']} subject {exam['subject_id']} within 14 days"
                    )

                clash = False
                capacity = _venue_capacity(venues, venue_id)
                if _venue_is_full(venue_bookings[venue_id], current_time, duration, len(students), capacity):
                    clash = True

                if not is_teacher_available(teacher_id, current_time.date(), current_time.time(), duration):
                    clash = True

                if not clash:
                    for student in students:
                        if _students_overlap(student_exam_times[student], current_time, duration):
                            clash = True
                            break

                if not clash:
                    try:
                        exam_schedule = ExamSchedule(
                            exam_type_id=exam["exam_type_id"],
                            exam_pattern_id=exam["exam_pattern_id"],
                            subject_id=exam["subject_id"],
                            class_assigned_id=exam["class_id"],
                            teacher_id=teacher_id,
                            mode=exam.get("mode", ExamMode.OFFLINE),
                            date=current_time.date(),
                            start_time=current_time.time(),
                            duration_minutes=duration,
                            venue_id=venue_id,
                            total_marks=Decimal(str(exam.get("total_marks", 100))),
                            passing_marks=Decimal(str(exam.get("passing_marks", 35))),
                        )
                        exam_schedule.save()

                        schedule.append({
                            "class_id": exam["class_id"],
                            "subject_id": exam["subject_id"],
                            "teacher_id": teacher_id,
                            "date": current_time.date().isoformat(),
                            "start_time": current_time.time().isoformat(timespec='minutes'),
                            "duration": duration,
                            "venue_id": venue_id,
                        })

                        for student in students:
                            student_exam_times[student].append((current_time, duration))
                        venue_bookings[venue_id].append((current_time, duration, len(students)))
                        scheduled = True
                    except ValidationError as exc:
                        if not _is_scheduling_clash(exc):
                            raise
                        clash = True

                if not scheduled:
                    current_time += step

        return JsonResponse({'scheduled_exams': schedule}, status=200)
    except ValidationError as exc:
        return JsonResponse({'error': validation_error_text(exc)}, status=400)
    except (TypeError, ValueError, KeyError) as exc:
        return JsonResponse({'error': str(exc)}, status=400)


def _grade_for_score(score):
    matches = [
        scale for scale in GradeScale.objects.all()
        if scale.min_score <= score <= scale.max_score
    ]
    if not matches:
        return None
    return max(matches, key=lambda scale: scale.min_score)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def evaluate_exam(request):
    try:
        data = request.data
        try:
            student_id = data['student_id']
            exam_schedule_id = data['exam_schedule_id']
        except KeyError as exc:
            raise ValidationError(f"Missing field: {exc.args[0]}")

        answers = data.get('answers', [])
        validate_student_answers(student_id, exam_schedule_id, answers)

        for answer in answers:
            question_id = answer['question_id'] if isinstance(answer, dict) else answer.question_id
            selected_option = answer['selected_option'] if isinstance(answer, dict) else answer.selected_option
            StudentAnswer.objects.update_or_create(
                student_id=student_id,
                question_id=question_id,
                exam_schedule_id=exam_schedule_id,
                defaults={'selected_option': selected_option},
            )

        stored_answers = StudentAnswer.objects.filter(
            student_id=student_id,
            exam_schedule_id=exam_schedule_id,
        ).select_related('question')
        total_score = score_answers(stored_answers)
        grace_marks = calculate_grace_marks(student_id, exam_schedule_id, total_score)
        validate_result_calculation(student_id, exam_schedule_id, total_score, grace_marks)
        final_score = total_score + grace_marks
        grade = _grade_for_score(final_score)

        ExamResult.objects.update_or_create(
            student_id=student_id,
            exam_schedule_id=exam_schedule_id,
            defaults={
                'marks_obtained': final_score,
                'graded_scale': grade,
                'is_manual': False,
                'grace_marks': grace_marks,
            },
        )

        return JsonResponse({
            'student_id': student_id,
            'exam_schedule_id': exam_schedule_id,
            'total_score': total_score,
            'grace_marks': grace_marks,
            'final_score': final_score,
            'grade': grade.name if grade else "Ungraded",
        })
    except ValidationError as exc:
        return JsonResponse({'error': validation_error_text(exc)}, status=400)
    except (TypeError, ValueError, KeyError) as exc:
        return JsonResponse({'error': str(exc)}, status=400)
