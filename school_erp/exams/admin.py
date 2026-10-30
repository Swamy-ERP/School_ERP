from django.contrib import admin
from .models import (
    Board, Class, Subject, Teacher, Venue, ExamType, ExamPattern,
    TeacherAvailability, ExamSchedule, Student, GradeScale, ExamResult,
    AssessmentParameter, Question, StudentAnswer,
)


admin.site.register(Board)
admin.site.register(Class)
admin.site.register(Subject)
admin.site.register(Teacher)
admin.site.register(Venue)
admin.site.register(ExamType)
admin.site.register(ExamPattern)
admin.site.register(ExamSchedule)
admin.site.register(TeacherAvailability)
admin.site.register(Student)
admin.site.register(GradeScale)
admin.site.register(ExamResult)
admin.site.register(AssessmentParameter)
admin.site.register(Question)
admin.site.register(StudentAnswer)

# Register your models here.
