from django.contrib import admin
from .models import Booking

@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = ('id', 'listing', 'renter', 'owner', 'start_date', 'end_date', 'total_price', 'status', 'created_at')
    list_filter = ('status', 'start_date', 'created_at')
    search_fields = ('listing__title', 'renter__phone', 'renter__name', 'owner__phone', 'owner__name')
    ordering = ('-created_at',)

