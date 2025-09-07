import json
from django.shortcuts import render
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.db.models import Sum
from datetime import datetime, timedelta
from collections import defaultdict
from rest_framework.decorators import api_view,permission_classes
from rest_framework import viewsets
from rest_framework.permissions import IsAuthenticated
from .models import Board, Class, Subject,Teacher, ExamType, ExamPattern,Venue,ExamSchedule,TeacherAvailability,Student,StudentAnswer,Question,ExamResult,ExamMode,GradeScale
from .serializers import BoardSerializer,ClassSerializer,SubjectSerializer,ExamTypeSerializer,ExamPatternSerializer,VenueSerializer,ExamScheduleSerialzer
from .validators import validate_exam_schedule, validate_teacher_availability, validate_question_paper, validate_student_answers, validate_result_calculation, calculate_grace_marks
from django.core.exceptions import ValidationError


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
    serializer_class = ExamScheduleSerialzer
    permission_classes = [IsAuthenticated]


def is_teacher_available(teacher_id, date, start_time, duration):
    exam_end_time = (datetime.combine(date,start_time) + timedelta(minutes=duration)).time()
    slots = TeacherAvailability.objects.filter(teacher_id = teacher_id,date=date)
    for slot in slots:
        if slot.start_time <= start_time and slot.end_time >= exam_end_time:
            return True
    return False

@api_view(['POST'])
@permission_classes([IsAuthenticated])
@csrf_exempt
def smart_schedule_view(request):
    try:
        data = json.loads(request.body)
        exams = data.get('exams', [])
        venues = data.get('venues', {})
        start_time = datetime.strptime(data.get('start_date', '2025-09-10'), "%Y-%m-%d").date()

        # Validate input data
        if not exams:
            raise ValidationError("No exams provided for scheduling")
        if not venues:
            raise ValidationError("No venues provided for scheduling")

        schedule = []
        student_exam_times = defaultdict(list)
        venue_usage = defaultdict(lambda: defaultdict(int))
        current_time = datetime.combine(start_time, datetime.strptime("09:00", "%H:%M").time())

        for exam in exams:
            # Validate exam data
            required_fields = ['duration', 'students', 'venue_id', 'teacher_id', 
                             'exam_type_id', 'exam_pattern_id', 'subject_id', 'class_id']
            if not all(field in exam for field in required_fields):
                raise ValidationError(f"Missing required fields in exam data: {required_fields}")

            duration = exam["duration"]
            students = exam["students"]
            venue_id = exam["venue_id"]
            teacher_id = exam["teacher_id"]
            scheduled = False

            while not scheduled:
                clash = False
                
                # Validate venue capacity
                if venue_usage[current_time.date()][venue_id] + len(students) > venues.get(str(venue_id), 0):
                    clash = True

                # Validate teacher availability
                if not is_teacher_available(teacher_id, current_time.date(), current_time.time(), duration):
                    clash = True

                # Check student schedule clashes
                for student in students:
                    for t in student_exam_times[student]:
                        if abs((current_time - t).total_seconds()) < duration * 60:
                            clash = True
                            break
                    if clash:
                        break

                if not clash:
                    # Create exam schedule with validation
                    try:
                        exam_schedule = ExamSchedule(
                            exam_type_id=exam["exam_type_id"],
                            exam_pattern_id=exam["exam_pattern_id"],
                            subject_id=exam["subject_id"],
                            class_assigned_id=exam["class_id"],
                            teacher_id=teacher_id,
                            date=current_time.date(),
                            start_time=current_time.time(),
                            duration_minutes=duration,
                            venue_id=venue_id
                        )
                        exam_schedule.full_clean()  # This will run all model validations
                        exam_schedule.save()
                        
                        schedule.append({
                            "class_id": exam["class_id"],
                            "subject_id": exam["subject_id"],
                            "teacher_id": teacher_id,
                            "date": current_time.date().isoformat(),
                            "start_time": current_time.time().isoformat(timespec='minutes'),
                            "duration": duration,
                            "venue_id": venue_id
                        })
                        
                        for student in students:
                            student_exam_times[student].append(current_time)
                        venue_usage[current_time.date()][venue_id] += len(students)
                        scheduled = True
                    except ValidationError as e:
                        return JsonResponse({'error': str(e)}, status=400)
                
                if not scheduled:
                    current_time += timedelta(minutes=duration + 30)

        return JsonResponse({'scheduled_exams': schedule}, status=200)
    except ValidationError as e:
        return JsonResponse({'error': str(e)}, status=400)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def evaluate_exam(request):
    try:
        data = request.data
        student_id = data['student_id']
        exam_schedule_id = data['exam_schedule_id']
        answers = data.get('answers', [])

        # Validate student answers
        validate_student_answers(student_id, exam_schedule_id, answers)

        total_score = 0.0
        for answer in answers:
            if answer.selected_option == answer.question.correct_option:
                total_score += answer.question.marks

        # Calculate grace marks if needed
        grace_marks = calculate_grace_marks(student_id, exam_schedule_id, total_score)
        final_score = total_score + grace_marks

        # Validate final result calculation
        validate_result_calculation(student_id, exam_schedule_id, final_score, grace_marks)

        # Get appropriate grade
        grade = None
        for scale in GradeScale.objects.all():
            if scale.min_score <= final_score <= scale.max_score:
                grade = scale
                break

        ExamResult.objects.update_or_create(
            student_id=student_id,
            exam_schedule_id=exam_schedule_id,
            defaults={
                'marks_obtained': final_score,
                'grade_scale': grade,
                'is_manual': False,
                'grace_marks': grace_marks
            }
        )

        return JsonResponse({
            'student_id': student_id,
            'exam_schedule_id': exam_schedule_id,
            'total_score': total_score,
            'grace_marks': grace_marks,
            'final_score': final_score,
            'grade': grade.name if grade else "Ungraded"
        })
    
    except ValidationError as e:
        return JsonResponse({'error': str(e)}, status=400)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)




# Create your views here.
