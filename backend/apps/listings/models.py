from django.db import models
from django.conf import settings

class Listing(models.Model):
    CATEGORY_CHOICES = (
        ('SHEREHE', 'Sherehe na Matukio (Party & Events)'),
        ('UJENZI', 'Vifaa vya Ujenzi (Construction Equipment)'),
        ('UKUMBI', 'Kumbi za Sherehe na Mikutano (Venues)'),
    )

    TYPE_CHOICES = (
        ('RENT', 'Kukodisha Pekee (Rent Only)'),
        ('SELL', 'Kuuza Pekee (Sell Only)'),
        ('BOTH', 'Kukodisha na Kuuza (Rent & Sell)'),
    )

    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='listings',
        verbose_name='Mmiliki'
    )
    title = models.CharField(max_length=200, verbose_name='Jina la Kifaa / Ukumbi')
    description = models.TextField(verbose_name='Maelezo ya Kina')
    category = models.CharField(max_length=20, choices=CATEGORY_CHOICES, verbose_name='Kundi / Category')
    listing_type = models.CharField(max_length=10, choices=TYPE_CHOICES, default='RENT', verbose_name='Aina ya Biashara')
    
    price_per_day = models.DecimalField(max_digits=12, decimal_places=2, default=0.0, verbose_name='Bei kwa Siku (TZS)')
    sale_price = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True, verbose_name='Bei ya Kuuza (TZS)')
    currency = models.CharField(max_length=10, default='TZS', verbose_name='Sarafu')
    
    location = models.CharField(max_length=255, verbose_name='Eneo / Mji (Mf. Tegeta, Dar es Salaam)')
    latitude = models.FloatField(null=True, blank=True, verbose_name='Latitudo')
    longitude = models.FloatField(null=True, blank=True, verbose_name='Longitudo')
    
    is_available = models.BooleanField(default=True, verbose_name='Kinapatikana')
    rating = models.FloatField(default=0.0, verbose_name='Ukadiriaji wa Wastani')
    review_count = models.PositiveIntegerField(default=0, verbose_name='Idadi ya Maoni')
    features = models.JSONField(default=list, blank=True, verbose_name='Sifa Maalumu (Features)')
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = 'Tangazo la Kifaa'
        verbose_name_plural = 'Matangazo ya Vifaa'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.title} ({self.get_category_display()}) - {self.price_per_day} {self.currency}"

class ListingImage(models.Model):
    listing = models.ForeignKey(
        Listing,
        on_delete=models.CASCADE,
        related_name='images',
        verbose_name='Tangazo'
    )
    image = models.ImageField(upload_to='listings/', verbose_name='Picha')
    is_primary = models.BooleanField(default=False, verbose_name='Picha Kuu')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Picha ya Tangazo'
        verbose_name_plural = 'Picha za Matangazo'

