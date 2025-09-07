from django.urls import path,include
from rest_framework.routers import DefaultRouter
from .views import BoardViewSet,ClassViewSet,SubjectViewSet,ExamTypeViewSet,ExamPatternViewSet,VenueViewSet,ExamScheduleViewSet,smart_schedule_view


router = DefaultRouter()
router.register(r'boards', BoardViewSet)
router.register(r'classes', ClassViewSet)
router.register(r'subjects', SubjectViewSet)
router.register(r'exam-types', ExamTypeViewSet)
router.register(r'exam-patterns', ExamPatternViewSet)
router.register(r'venues', VenueViewSet)
router.register(r'exam-schedules', ExamScheduleViewSet)




urlpatterns = [
    path('',include(router.urls)),
    path('smart-schedule/', smart_schedule_view, name = 'smart_schedule'),
]