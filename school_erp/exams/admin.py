from django.contrib import admin
from .models import (Board, Class, Subject, Teacher, Venue, ExamType, ExamPattern, TeacherAvailability, ExamSchedule)


admin.site.register(Board)
admin.site.register(Class)
admin.site.register(Subject)
admin.site.register(Teacher)
admin.site.register(Venue)
admin.site.register(ExamType)
admin.site.register(ExamPattern)
admin.site.register(ExamSchedule)
admin.site.register(TeacherAvailability)

# Register your models here.
