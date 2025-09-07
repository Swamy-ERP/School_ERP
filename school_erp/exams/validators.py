from django.core.exceptions import ValidationError
from datetime import datetime, timedelta
from .models import ExamSchedule, TeacherAvailability, Student, Question, StudentAnswer, ExamResult

def validate_exam_schedule(exam_data):
    "Validate exam schedule for clashes"
    class_id = exam_data.get('class_assigned')
    date = exam_data.get('date')
    start_time = exam_data.get('start_time')
    duration = exam_data.get('duration_minutes')
    venue_id = exam_data.get('venue')

    # Check for existing exams for the same class on the same date
    existing_exams = ExamSchedule.objects.filter(
        class_assigned_id=class_id,
        date=date
    )

    exam_end_time = (datetime.combine(date, start_time) + timedelta(minutes=duration)).time()

    for exam in existing_exams:
        existing_end_time = (datetime.combine(date, exam.start_time) + 
                           timedelta(minutes=exam.duration_minutes)).time()
        
        if ((start_time >= exam.start_time and start_time <= existing_end_time) or
            (exam_end_time >= exam.start_time and exam_end_time <= existing_end_time)):
            raise ValidationError(f"Exam clash detected for class {class_id} on {date}")

def validate_teacher_availability(teacher_id, date, start_time, duration):
    "Validate teacher availability for exam supervision"
    exam_end_time = (datetime.combine(date, start_time) + timedelta(minutes=duration)).time()
    
    available_slots = TeacherAvailability.objects.filter(
        teacher_id=teacher_id,
        date=date
    )

    if not available_slots:
        raise ValidationError(f"Teacher {teacher_id} has no availability set for {date}")

    for slot in available_slots:
        if slot.start_time <= start_time and slot.end_time >= exam_end_time:
            return True
    
    raise ValidationError(f"Teacher {teacher_id} is not available at the specified time")

def validate_question_paper(questions):
    """Validate question paper structure and total marks"""
    if not questions:
        raise ValidationError("Question paper cannot be empty")

    total_marks = sum(q.marks for q in questions)
    if total_marks <= 0:
        raise ValidationError("Total marks must be greater than 0")

    # Validate question types distribution
    question_types = {}
    for q in questions:
        q_type = type(q).__name__
        question_types[q_type] = question_types.get(q_type, 0) + 1

    return True

def validate_student_answers(student_id, exam_schedule_id, answers):
    """Validate student answers before submission"""
    # Check if student is registered for the exam
    if not Student.objects.filter(id=student_id).exists():
        raise ValidationError("Invalid student ID")

    # Check if exam exists and is ongoing
    exam = ExamSchedule.objects.get(id=exam_schedule_id)
    current_time = datetime.now().time()
    
    if current_time < exam.start_time:
        raise ValidationError("Exam has not started yet")
    
    exam_end_time = (datetime.combine(exam.date, exam.start_time) + 
                     timedelta(minutes=exam.duration_minutes)).time()
    if current_time > exam_end_time:
        raise ValidationError("Exam has ended")

    # Validate answer format for each question
    for answer in answers:
        question = Question.objects.get(id=answer.question_id)
        if not answer.selected_option in question.options:
            raise ValidationError(f"Invalid option selected for question {question.id}")

def calculate_grace_marks(student_id, exam_schedule_id, marks_obtained):
    """Calculate grace marks based on school policy"""
    exam = ExamSchedule.objects.get(id=exam_schedule_id)
    passing_marks = exam.passing_marks
    max_grace = 5  # Maximum grace marks allowed

    if marks_obtained < passing_marks:
        needed_grace = passing_marks - marks_obtained
        if needed_grace <= max_grace:
            return needed_grace
    return 0

def validate_result_calculation(student_id, exam_schedule_id, marks_obtained, grace_marks=0):
    """Validate result calculation including grace marks"""
    if marks_obtained < 0:
        raise ValidationError("Marks obtained cannot be negative")

    exam = ExamSchedule.objects.get(id=exam_schedule_id)
    
    # Validate against maximum marks
    if marks_obtained > exam.total_marks:
        raise ValidationError("Marks obtained cannot exceed total marks")

    # Validate grace marks
    if grace_marks > 0:
        calculated_grace = calculate_grace_marks(student_id, exam_schedule_id, marks_obtained)
        if grace_marks > calculated_grace:
            raise ValidationError("Invalid grace marks applied")

    return True