from django.db import models
from django.conf import settings

class Notification(models.Model):
    TYPE_CHOICES = (
        ('BOOKING_NEW', 'Ombi Jipya la Booking'),
        ('BOOKING_CONFIRMED', 'Booking Imethibitishwa'),
        ('PAYMENT_RECEIVED', 'Malipo Yamepokelewa'),
        ('REMINDER', 'Kikumbusho cha Kurejesha'),
        ('SYSTEM', 'Taarifa ya Mfumo'),
    )

    recipient = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='notifications',
        verbose_name='Mpokea Arifa'
    )
    title = models.CharField(max_length=200, verbose_name='Kichwa cha Arifa')
    body = models.TextField(verbose_name='Ujumbe wa Arifa')
    notification_type = models.CharField(max_length=30, choices=TYPE_CHOICES, default='SYSTEM', verbose_name='Aina ya Arifa')
    
    is_read = models.BooleanField(default=False, verbose_name='Imesomwa')
    related_id = models.CharField(max_length=100, blank=True, verbose_name='ID ya Kitu Husika (Mf. Booking ID)')
    
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Arifa'
        verbose_name_plural = 'Arifa'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.title} -> {self.recipient.name} ({'Imesomwa' if self.is_read else 'Mpya'})"

