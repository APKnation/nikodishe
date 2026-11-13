from django.contrib import admin
from .models import Review

@admin.register(Review)
class ReviewAdmin(admin.ModelAdmin):
    list_display = ('listing', 'renter', 'owner', 'rating', 'created_at')
    list_filter = ('rating', 'created_at')
    search_fields = ('listing__title', 'renter__name', 'renter__phone', 'comment')
    ordering = ('-created_at',)

