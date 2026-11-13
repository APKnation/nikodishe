from django.urls import path
from .views import upload_image_view

urlpatterns = [
    path('upload-image/', upload_image_view, name='upload_listing_image'),
]

