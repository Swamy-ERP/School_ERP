from django.core.exceptions import ValidationError
from django.db import models


class Board(models.Model):
    name = models.CharField(max_length=100, unique=True)

    def __str__(self):
        return self.name


class Class(models.Model):
    name = models.CharField(max_length=50)
    board = models.ForeignKey(Board, on_delete=models.CASCADE)

    def __str__(self):
        return self.name


class Subject(models.Model):
    name = models.CharField(max_length=100)
    code = models.CharField(max_length=20, unique=True)
    board = models.ForeignKey(Board, on_delete=models.CASCADE)

    def __str__(self):
        return f"{self.name} ({self.code})"


class Student(models.Model):
    name = models.CharField(max_length=100)
    student_id = models.CharField(max_length=20, unique=True)
    enrolled_class = models.ForeignKey(Class, on_delete=models.CASCADE)

    def __str__(self):
        return f"{self.name} ({self.student_id})"


class Teacher(models.Model):
    name = models.CharField(max_length=100)

    def __str__(self):
        return self.name


class TeacherAvailability(models.Model):
    teacher = models.ForeignKey(Teacher, on_delete=models.CASCADE)
    date = models.DateField()
    start_time = models.TimeField()
    end_time = models.TimeField()

    def clean(self):
        if self.start_time and self.end_time and self.start_time >= self.end_time:
            raise ValidationError("Availability end time must be after the start time")

    def save(self, *args, **kwargs):
        self.full_clean()
        super().save(*args, **kwargs)


class Venue(models.Model):
    name = models.CharField(max_length=100)
    capacity = models.PositiveIntegerField()

    def __str__(self):
        return self.name


class ExamType(models.Model):
    name = models.CharField(max_length=100, unique=True)

    def __str__(self):
        return self.name


class ExamPattern(models.Model):
    name = models.CharField(max_length=100)
    board = models.ForeignKey(Board, on_delete=models.CASCADE)
    description = models.TextField(blank=True)

    def __str__(self):
        return self.name


class ExamMode(models.TextChoices):
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
    total_marks = models.DecimalField(max_digits=5, decimal_places=2, default=100)
    passing_marks = models.DecimalField(max_digits=5, decimal_places=2, default=35)
    is_result_published = models.BooleanField(default=False)

    class Meta:
        unique_together = ('class_assigned', 'subject', 'date', 'start_time')

    def clean(self):
        if self.duration_minutes is not None and self.duration_minutes <= 0:
            raise ValidationError("Duration must be greater than 0")
        if self.total_marks is not None and self.passing_marks is not None:
            if self.total_marks <= 0:
                raise ValidationError("Total marks must be greater than 0")
            if self.passing_marks < 0:
                raise ValidationError("Passing marks cannot be negative")
            if self.passing_marks > self.total_marks:
                raise ValidationError("Passing marks cannot exceed total marks")

        if not (self.date and self.start_time and self.duration_minutes and self.class_assigned_id and self.teacher_id):
            return

        from .validators import validate_exam_schedule, validate_teacher_availability
        validate_exam_schedule({
            'class_assigned': self.class_assigned_id,
            'date': self.date,
            'start_time': self.start_time,
            'duration_minutes': self.duration_minutes,
            'venue': self.venue_id,
            'exam_id': self.pk,
        })
        validate_teacher_availability(
            self.teacher_id,
            self.date,
            self.start_time,
            self.duration_minutes,
            exam_id=self.pk,
        )

    def save(self, *args, **kwargs):
        self.full_clean()
        super().save(*args, **kwargs)

    def __str__(self):
        return f"{self.subject.name} - {self.class_assigned.name} on {self.date}"


class GradeScale(models.Model):
    name = models.CharField(max_length=50)  # e.g: A+, B+, fail
    min_score = models.FloatField()
    max_score = models.FloatField()
    description = models.TextField(blank=True)

    def clean(self):
        if self.min_score is not None and self.max_score is not None and self.min_score > self.max_score:
            raise ValidationError("Grade minimum score cannot exceed the maximum score")

    def save(self, *args, **kwargs):
        self.full_clean()
        super().save(*args, **kwargs)

    def __str__(self):
        return self.name


class ExamResult(models.Model):
    student = models.ForeignKey(Student, on_delete=models.CASCADE)
    exam_schedule = models.ForeignKey(ExamSchedule, on_delete=models.CASCADE)
    marks_obtained = models.FloatField()
    graded_scale = models.ForeignKey(GradeScale, on_delete=models.CASCADE, null=True, blank=True)
    grace_marks = models.FloatField(default=0)
    is_manual = models.BooleanField(default=True)  # True if manually marked

    class Meta:
        unique_together = ('student', 'exam_schedule')

    def __str__(self):
        return f"{self.student} - {self.exam_schedule}"


class AssessmentParameter(models.Model):
    name = models.CharField(max_length=100)  # e.g: Knowledge, presentation
    weightage = models.FloatField()  # percentage contribution to total marks

    def __str__(self):
        return self.name


class Question(models.Model):
    subject = models.ForeignKey(Subject, on_delete=models.CASCADE)
    text = models.TextField()
    options = models.JSONField()  # e.g: {"A": "option 1", "B": "Option 2"}
    correct_option = models.CharField(max_length=1)  # e.g: "A"
    marks = models.FloatField(default=1.0)

    def __str__(self):
        return self.text[:50]


class StudentAnswer(models.Model):
    student = models.ForeignKey(Student, on_delete=models.CASCADE)
    question = models.ForeignKey(Question, on_delete=models.CASCADE)
    selected_option = models.CharField(max_length=1)
    exam_schedule = models.ForeignKey(ExamSchedule, on_delete=models.CASCADE)

    class Meta:
        unique_together = ('student', 'question', 'exam_schedule')
