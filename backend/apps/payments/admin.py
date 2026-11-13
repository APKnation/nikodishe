from django.contrib import admin
from .models import Payment

@admin.register(Payment)
class PaymentAdmin(admin.ModelAdmin):
    list_display = ('reference_code', 'booking', 'renter', 'owner', 'amount', 'payment_method', 'payment_type', 'status', 'created_at')
    list_filter = ('payment_method', 'payment_type', 'status', 'created_at')
    search_fields = ('reference_code', 'phone_number', 'renter__phone', 'owner__phone')
    ordering = ('-created_at',)

