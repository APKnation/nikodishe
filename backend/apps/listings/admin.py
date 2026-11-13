from django.contrib import admin
from .models import Listing, ListingImage

class ListingImageInline(admin.TabularInline):
    model = ListingImage
    extra = 1

@admin.register(Listing)
class ListingAdmin(admin.ModelAdmin):
    list_display = ('title', 'owner', 'category', 'listing_type', 'price_per_day', 'location', 'is_available', 'created_at')
    list_filter = ('category', 'listing_type', 'is_available', 'created_at')
    search_fields = ('title', 'description', 'location', 'owner__phone', 'owner__name')
    inlines = [ListingImageInline]
    ordering = ('-created_at',)

