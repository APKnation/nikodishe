from django.db import models
from django.conf import settings
from django.db.models import Avg
from apps.listings.models import Listing
from apps.bookings.models import Booking

class Review(models.Model):
    booking = models.ForeignKey(
        Booking,
        on_delete=models.CASCADE,
        related_name='reviews',
        verbose_name='Booking Husika'
    )
    listing = models.ForeignKey(
        Listing,
        on_delete=models.CASCADE,
        related_name='reviews',
        verbose_name='Kifaa / Ukumbi'
    )
    renter = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='written_reviews',
        verbose_name='Mtoa Maoni (Mteja)'
    )
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='received_reviews',
        verbose_name='Mpokea Maoni (Mmiliki)'
    )
    
    rating = models.PositiveSmallIntegerField(default=5, verbose_name='Nyota (1-5)')
    comment = models.TextField(verbose_name='Maoni')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = 'Tathmini na Maoni'
        verbose_name_plural = 'Tathmini na Maoni'
        ordering = ['-created_at']

    def __str__(self):
        return f"{self.listing.title} - {self.rating}★ by {self.renter.name}"

    def save(self, *args, **kwargs):
        super().save(*args, **kwargs)
        # Update listing rating
        listing_reviews = Review.objects.filter(listing=self.listing)
        avg_rating = listing_reviews.aggregate(Avg('rating'))['rating__avg'] or 0.0
        self.listing.rating = round(avg_rating, 1)
        self.listing.review_count = listing_reviews.count()
        self.listing.save(update_fields=['rating', 'review_count'])

        # Update owner overall rating
        owner_reviews = Review.objects.filter(owner=self.owner)
        owner_avg = owner_reviews.aggregate(Avg('rating'))['rating__avg'] or 0.0
        self.owner.rating = round(owner_avg, 1)
        self.owner.review_count = owner_reviews.count()
        self.owner.save(update_fields=['rating', 'review_count'])

