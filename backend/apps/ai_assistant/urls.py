from django.urls import path

from .views import analyze_view, chat_view

urlpatterns = [
    path('chat/', chat_view, name='ai_chat'),
    path('analyze/', analyze_view, name='ai_analyze'),
]
