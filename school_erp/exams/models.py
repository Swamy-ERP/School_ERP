from django.db import models
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated

class Board(models.Model):
    name = models.CharField(max_length=100, unique=True)


class Class(models.Model):
    name = models.CharField(max_length=50)
    board = models.ForeignKey(Board, on_delete=models.CASCADE)


class Subject(models.Model):
    name = models.CharField(max_length=100)
    code = models.CharField(max_length=20,unique=True)
    board = models.ForeignKey(Board,on_delete=models.CASCADE)

class Student(models.Model):
    name = models.CharField(max_length=100)
    student_id = models.CharField(max_length=20, unique=True)
    enrolled_class = models.ForeignKey(Class, on_delete=models.CASCADE)


class Teacher(models.Model):
    name = models.CharField(max_length=100)


class TeacherAvailability(models.Model):
    teacher = models.ForeignKey(Teacher, on_delete=models.CASCADE)
    date = models.DateField()
    start_time = models.TimeField()
    end_time = models.TimeField()


class Venue(models.Model):
    name = models.CharField(max_length=100)
    capacity = models.PositiveIntegerField()

    def __str__(self):
        return self.name



class ExamType(models.Model):
    name = models.CharField(max_length=100,unique=True)


class ExamPattern(models.Model):
    name = models.CharField(max_length=100)
    board = models.ForeignKey(Board,on_delete=models.CASCADE)
    description = models.TextField(blank=True)



class ExamMode(models.Model):
    ONLINE = 'Online', 'Online'
    OFFLINE = 'Offline', 'Offline'


class ExamSchedule(models.Model):
    exam_type = models.ForeignKey(ExamType, on_delete=models.CASCADE)
    exam_pattern = models.ForeignKey(ExamPattern, on_delete=models.CASCADE)
    subject = models.ForeignKey(Subject, on_delete=models.CASCADE)
    class_assigned = models.ForeignKey(Class, on_delete=models.CASCADE)
    teacher = models.ForeignKey(Teacher, on_delete=models.CASCADE)
    mode = models.CharField(max_length=10, choices=ExamMode.choices, default=ExamMode.OFFLINE)
    date = models.DateField()
    start_time = models.TimeField()
    duration_minutes = models.PositiveIntegerField()
    venue = models.ForeignKey(Venue, on_delete=models.CASCADE)
    total_marks = models.DecimalField(max_digits=5, decimal_places=2)
    passing_marks = models.DecimalField(max_digits=5, decimal_places=2)
    is_result_published = models.BooleanField(default=False)

    class Meta:
        unique_together = ('class_assigned', 'subject', 'date', 'start_time')

    def clean(self):
        from .validators import validate_exam_schedule, validate_teacher_availability
        validate_exam_schedule({
            'class_assigned': self.class_assigned_id,
            'date': self.date,
            'start_time': self.start_time,
            'duration_minutes': self.duration_minutes,
            'venue': self.venue_id
        })
        validate_teacher_availability(
            self.teacher_id,
            self.date,
            self.start_time,
            self.duration_minutes
        )

    def save(self, *args, **kwargs):
        self.full_clean()
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.subject.name} - {self.class_assigned.name} on {self.date}"
    


class GradeScale(models.Model):
    name = models.CharField(max_length=50) # e.g: A+, B+, fail
    min_score = models.FloatField()
    max_score = models.FloatField()
    description = models.TextField(blank=True)


class ExamResult(models.Model):
    student = models.ForeignKey(Student, on_delete=models.CASCADE)
    exam_schedule = models.ForeignKey(ExamSchedule, on_delete=models.CASCADE)
    marks_obtained = models.FloatField()
    graded_scale = models.ForeignKey(GradeScale, on_delete= models.CASCADE)
    is_manual = models.BooleanField(default=True) #True if manually marked


class AssessmentParameter(models.Model):
    name = models.CharField(max_length=100) #e.g: Knowledge, presentation
    weightage = models.FloatField()  #percentage contribution to total marks


class Question(models.Model):
    subject = models.ForeignKey(Subject, on_delete=models.CASCADE)
    text = models.TextField()
    options = models.JSONField()  #e.g: "A": "option 1", "B" : "Option 2"...
    correct_option = models.CharField(max_length=1)  #e.g: "A"....
    marks = models.FloatField(default=1.0)


class StudentAnswer(models.Model):
    student = models.ForeignKey(Student, on_delete=models.CASCADE)
    question = models.ForeignKey(Question, on_delete=models.CASCADE)
    selected_option = models.CharField(max_length=1)
    exam_schedule = models.ForeignKey(ExamSchedule, on_delete=models.CASCADE)



