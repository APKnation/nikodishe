from django.db import models
from django.conf import settings
from apps.listings.models import Listing

class Booking(models.Model):
    STATUS_CHOICES = (
        ('PENDING', 'Inasubiri (Pending)'),
        ('CONFIRMED', 'Imethibitishwa (Confirmed)'),
        ('COMPLETED', 'Imekamilika (Completed)'),
        ('CANCELLED', 'Imeghairiwa (Cancelled)'),
    )

    listing = models.ForeignKey(
        Listing,
        on_delete=models.CASCADE,
        related_name='bookings',
        verbose_name='Kifaa / Ukumbi'
    )
    renter = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='my_bookings',
        verbose_name='Mkodishaji'
    )
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='received_bookings',
        verbose_name='Mmiliki wa Kifaa'
    )
    
    start_date = models.DateField(verbose_name='Tarehe ya Kuanza')
    end_date = models.DateField(verbose_name='Tarehe ya Kumaliza')
    
    total_price = models.DecimalField(max_digits=12, decimal_places=2, verbose_name='Jumla ya Gharama (TZS)')
    deposit_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0.0, verbose_name='Kiwango cha Amana (40%)')
    
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='PENDING', verbose_name='Hadhi ya Booking')
    delivery_address = models.CharField(max_length=255, blank=True, verbose_name='Mahali pa Kufikishiwa')
    notes = models.TextField(blank=True, verbose_name='Ujumbe / Maelezo ya Ziada')

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Ombi la Ukodishaji (Booking)'
        verbose_name_plural = 'Maombi ya Ukodishaji (Bookings)'
        ordering = ['-created_at']

    def __str__(self):
        return f"Booking #{self.id} - {self.listing.title} ({self.status})"

