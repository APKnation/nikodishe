import uuid
from django.db import models
from django.conf import settings
from apps.bookings.models import Booking

class Payment(models.Model):
    METHOD_CHOICES = (
        ('MPESA', 'M-Pesa (Vodacom)'),
        ('AIRTEL_MONEY', 'Airtel Money'),
        ('TIGO_PESA', 'Tigo Pesa / Mixx by Yas'),
        ('HALOPESA', 'HaloPesa'),
    )

    TYPE_CHOICES = (
        ('DEPOSIT', 'Amana ya Awali (40% Deposit)'),
        ('FULL', 'Malipo Kamili (100% Full Payment)'),
        ('REMAINDER', 'Kumalizia Salio (60% Remainder)'),
    )

    STATUS_CHOICES = (
        ('PENDING', 'Inasubiri (Pending)'),
        ('COMPLETED', 'Yamekamilika (Completed)'),
        ('FAILED', 'Yameshindikana (Failed)'),
    )

    booking = models.ForeignKey(
        Booking,
        on_delete=models.CASCADE,
        related_name='payments',
        verbose_name='Booking Husika'
    )
    renter = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='my_payments',
        verbose_name='Mlipaji (Mteja)'
    )
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='received_payments',
        verbose_name='Mpokeaji (Mmiliki)'
    )
    
    amount = models.DecimalField(max_digits=12, decimal_places=2, verbose_name='Kiasi cha Malipo (TZS)')
    payment_method = models.CharField(max_length=20, choices=METHOD_CHOICES, verbose_name='Njia ya Malipo')
    payment_type = models.CharField(max_length=20, choices=TYPE_CHOICES, default='FULL', verbose_name='Aina ya Malipo')
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='COMPLETED', verbose_name='Hadhi ya Malipo')
    
    reference_code = models.CharField(max_length=50, unique=True, verbose_name='Kumbukumbu Namba (Ref)')
    phone_number = models.CharField(max_length=20, verbose_name='Namba Iliyofanya Malipo')

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Muamala wa Malipo'
        verbose_name_plural = 'Miamala ya Malipo'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.reference_code} - {self.amount} TZS ({self.get_payment_method_display()})"

    @classmethod
    def generate_reference(cls):
        return f"KOD-{uuid.uuid4().hex[:8].upper()}"

