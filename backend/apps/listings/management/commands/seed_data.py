from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from apps.listings.models import Listing, ListingImage

User = get_user_model()

class Command(BaseCommand):
    help = 'Pakia data za majaribio (Sample seed data) kwa ajili ya Kodisha'

    def handle(self, *args, **options):
        self.stdout.write(self.style.NOTICE('Inaanza kupakia data za majaribio...'))

        # 1. Unda watumiaji
        owner, _ = User.objects.get_or_create(
            phone='+255712345678',
            defaults={
                'name': 'Amina Salehe',
                'role': 'OWNER',
                'location': 'Dar es Salaam (Kinondoni)',
                'whatsapp_number': '+255712345678',
                'instagram_handle': '@amina_rentals_tz',
                'is_verified': True,
                'rating': 4.9,
                'review_count': 28,
            }
        )

        renter, _ = User.objects.get_or_create(
            phone='+255754321987',
            defaults={
                'name': 'John Mwangi',
                'role': 'RENTER',
                'location': 'Arusha',
                'whatsapp_number': '+255754321987',
                'instagram_handle': '@john_mwangi_arusha',
            }
        )

        # 2. Vifaa vya Majaribio
        sample_listings = [
            {
                'title': 'Meza za Sherehe (Set ya 10)',
                'description': 'Meza 10 za plastiki zenye ubora wa juu, zinafaa kwa sherehe za harusi, birthday na mikutano. Zinakuja na vitambaa vya meza bila malipo ya ziada.',
                'category': 'SHEREHE',
                'listing_type': 'RENT',
                'price_per_day': 50000,
                'location': 'Kinondoni, Dar es Salaam',
                'latitude': -6.7924,
                'longitude': 39.2083,
                'rating': 4.8,
                'review_count': 24,
                'images': [
                    'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800',
                    'https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?w=800',
                ],
            },
            {
                'title': 'Viti 100 vya Sherehe',
                'description': 'Viti 100 vya chuma, rangi nyeupe, bora kwa sherehe za nje na ndani. Vinasafishwa na kudisinfected kabla ya kukodishwa.',
                'category': 'SHEREHE',
                'listing_type': 'RENT',
                'price_per_day': 80000,
                'location': 'Mwenge, Dar es Salaam',
                'latitude': -6.7712,
                'longitude': 39.2215,
                'rating': 4.7,
                'review_count': 18,
                'images': [
                    'https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=800',
                ],
            },
            {
                'title': 'Scaffolding za Chuma (Set ya 20)',
                'description': 'Scaffolding za kisasa na salama kwa ujenzi wa ghorofa, upakaji rangi na marekebisho ya majengo. Zimekaguliwa na kuthibitishwa.',
                'category': 'UJENZI',
                'listing_type': 'RENT',
                'price_per_day': 120000,
                'location': 'Kariakoo, Dar es Salaam',
                'latitude': -6.8223,
                'longitude': 39.2783,
                'rating': 4.9,
                'review_count': 32,
                'images': [
                    'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800',
                ],
            },
            {
                'title': 'Mixer ya Saruji (Diesel)',
                'description': 'Concrete Mixer inayotumia mafuta ya diesel, ujazo wa lita 350. Inafanya kazi masaa 12 bila kupumzika. Inakuja na fundi anayeisimamia.',
                'category': 'UJENZI',
                'listing_type': 'RENT',
                'price_per_day': 150000,
                'location': 'Mbezi Beach, Dar es Salaam',
                'latitude': -6.7214,
                'longitude': 39.2291,
                'rating': 4.6,
                'review_count': 14,
                'images': [
                    'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800',
                ],
            },
            {
                'title': 'Jenereta ya 20KVA (Silent)',
                'description': 'Jenereta ya umeme ya kimya (silent canopy), ina uwezo wa kuwasha vifaa vyote vya ukumbi wa harusi au site ya ujenzi.',
                'category': 'UJENZI',
                'listing_type': 'RENT',
                'price_per_day': 200000,
                'location': 'Tegeta, Dar es Salaam',
                'latitude': -6.6711,
                'longitude': 39.1834,
                'rating': 5.0,
                'review_count': 21,
                'images': [
                    'https://images.unsplash.com/photo-1513836279014-a89f7a76ae86?w=800',
                ],
            },
            {
                'title': 'Ukumbi wa Kariakoo (Watu 300)',
                'description': 'Ukumbi wenye kiyoyozi (AC), taa za kisasa, generator ya dharura, vyoo safi na sehemu kubwa ya maegesho ya magari.',
                'category': 'UKUMBI',
                'listing_type': 'RENT',
                'price_per_day': 800000,
                'location': 'Kariakoo, Dar es Salaam',
                'latitude': -6.8201,
                'longitude': 39.2755,
                'rating': 4.9,
                'review_count': 45,
                'images': [
                    'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=800',
                ],
            },
            {
                'title': 'Ukumbi wa Mikutano Masaki (Watu 80)',
                'description': 'Conference Hall ya kisasa yenye projecta, internet ya fiber kasi ya juu, viti vya ergonomic na mfumo wa video conference.',
                'category': 'UKUMBI',
                'listing_type': 'RENT',
                'price_per_day': 450000,
                'location': 'Masaki, Dar es Salaam',
                'latitude': -6.7455,
                'longitude': 39.2789,
                'rating': 4.8,
                'review_count': 19,
                'images': [
                    'https://images.unsplash.com/photo-1431540015161-0bf868a2d407?w=800',
                ],
            },
        ]

        count = 0
        for data in sample_listings:
            images = data.pop('images', [])
            listing, created = Listing.objects.get_or_create(
                owner=owner,
                title=data['title'],
                defaults=data
            )
            if created:
                count += 1
                for i, img_url in enumerate(images):
                    ListingImage.objects.create(
                        listing=listing,
                        image_url=img_url,
                        is_primary=(i == 0)
                    )

        self.stdout.write(self.style.SUCCESS(f'Umefanikiwa! Vifaa {count} vimeongezwa kwenye database.'))

