from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser, OTPVerification

@admin.register(CustomUser)
class CustomUserAdmin(UserAdmin):
    list_display = ('phone', 'name', 'role', 'location', 'is_verified', 'rating', 'created_at')
    list_filter = ('role', 'is_verified', 'is_staff', 'created_at')
    search_fields = ('phone', 'name', 'location', 'nida_number')
    ordering = ('-created_at',)
    fieldsets = (
        ('Taarifa Binafsi', {'fields': ('phone', 'name', 'email', 'role', 'location', 'profile_photo')}),
        ('Mawasiliano na Mitandao', {'fields': ('whatsapp_number', 'instagram_handle', 'facebook_url', 'tiktok_handle')}),
        ('Uthibitisho & NIDA', {'fields': ('nida_number', 'is_verified', 'rating', 'review_count')}),
        ('Ruhusa & Hadhi', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('phone', 'name', 'role', 'password'),
        }),
    )

@admin.register(OTPVerification)
class OTPVerificationAdmin(admin.ModelAdmin):
    list_display = ('phone', 'otp_code', 'is_used', 'created_at', 'expires_at')
    list_filter = ('is_used', 'created_at')
    search_fields = ('phone', 'otp_code')

