import graphene
from graphene_django import DjangoObjectType
from graphql import GraphQLError
from django.db.models import Q
from .models import Listing, ListingImage
from apps.accounts.schema import UserType

class ListingImageType(DjangoObjectType):
    url = graphene.String()

    class Meta:
        model = ListingImage
        fields = ('id', 'image', 'image_url', 'is_primary', 'created_at')

    def resolve_url(self, info):
        if self.image:
            return info.context.build_absolute_uri(self.image.url)
        return self.image_url or ''

    def resolve_image(self, info):
        if self.image:
            return info.context.build_absolute_uri(self.image.url)
        return self.image_url or ''

class ListingNode(DjangoObjectType):
    images = graphene.List(ListingImageType)
    features = graphene.List(graphene.String)

    class Meta:
        model = Listing
        fields = (
            'id', 'owner', 'title', 'description', 'category',
            'listing_type', 'price_per_day', 'sale_price', 'currency',
            'location', 'latitude', 'longitude', 'is_available',
            'rating', 'review_count', 'created_at', 'updated_at'
        )

    def resolve_images(self, info):
        return self.images.all()

    def resolve_features(self, info):
        return self.features or []

class Query(graphene.ObjectType):
    listings = graphene.List(
        ListingNode,
        category=graphene.String(required=False),
        listing_type=graphene.String(required=False),
        search=graphene.String(required=False),
        min_price=graphene.Float(required=False),
        max_price=graphene.Float(required=False),
        owner_id=graphene.ID(required=False),
        is_available=graphene.Boolean(required=False),
    )
    listing_by_id = graphene.Field(ListingNode, id=graphene.ID(required=True))
    my_listings = graphene.List(ListingNode)

    def resolve_listings(self, info, **kwargs):
        qs = Listing.objects.all().select_related('owner').prefetch_related('images')

        category = kwargs.get('category')
        if category and category.upper() != 'ALL':
            qs = qs.filter(category=category.upper())

        listing_type = kwargs.get('listing_type')
        if listing_type:
            qs = qs.filter(listing_type=listing_type.upper())

        search = kwargs.get('search')
        if search:
            qs = qs.filter(
                Q(title__icontains=search) |
                Q(description__icontains=search) |
                Q(location__icontains=search)
            )

        min_price = kwargs.get('min_price')
        if min_price is not None:
            qs = qs.filter(price_per_day__gte=min_price)

        max_price = kwargs.get('max_price')
        if max_price is not None:
            qs = qs.filter(price_per_day__lte=max_price)

        owner_id = kwargs.get('owner_id')
        if owner_id:
            qs = qs.filter(owner_id=owner_id)

        is_available = kwargs.get('is_available')
        if is_available is not None:
            qs = qs.filter(is_available=is_available)

        return qs

    def resolve_listing_by_id(self, info, id):
        try:
            return Listing.objects.select_related('owner').prefetch_related('images').get(pk=id)
        except Listing.DoesNotExist:
            return None

    def resolve_my_listings(self, info):
        user = info.context.user
        if user.is_anonymous:
            raise GraphQLError("Lazima uwe umeingia kwenye akaunti.")
        return Listing.objects.filter(owner=user).prefetch_related('images')

# Mutations
class CreateListing(graphene.Mutation):
    class Arguments:
        title = graphene.String(required=True)
        description = graphene.String(required=True)
        category = graphene.String(required=True)
        listing_type = graphene.String(required=False)
        price_per_day = graphene.Float(required=True)
        sale_price = graphene.Float(required=False)
        location = graphene.String(required=True)
        latitude = graphene.Float(required=False)
        longitude = graphene.Float(required=False)
        features = graphene.List(graphene.String, required=False)
        images = graphene.List(graphene.String, required=False)
        owner_id = graphene.ID(required=False)

    listing = graphene.Field(ListingNode)
    success = graphene.Boolean()
    message = graphene.String()

    def mutate(self, info, title, description, category, price_per_day, location, **kwargs):
        user = info.context.user
        if user.is_anonymous:
            owner_id = kwargs.get('owner_id')
            if owner_id:
                from apps.accounts.models import CustomUser
                user = CustomUser.objects.filter(id=owner_id).first()

            if not user or user.is_anonymous:
                from apps.accounts.models import CustomUser
                user = CustomUser.objects.filter(role='OWNER').first() or CustomUser.objects.first()
                if not user:
                    user = CustomUser.objects.create_user(
                        phone='0712345678',
                        name='Mmiliki wa Kifaa',
                        role='OWNER'
                    )

        listing = Listing.objects.create(
            owner=user,
            title=title.strip(),
            description=description.strip(),
            category=category.upper(),
            listing_type=kwargs.get('listing_type', 'RENT').upper(),
            price_per_day=price_per_day,
            sale_price=kwargs.get('sale_price'),
            location=location.strip(),
            latitude=kwargs.get('latitude'),
            longitude=kwargs.get('longitude'),
            features=kwargs.get('features', [])
        )

        # Hifadhi picha zote zilizotumwa
        images = kwargs.get('images', [])
        if images:
            for i, img_url in enumerate(images):
                if img_url and img_url.strip():
                    ListingImage.objects.create(
                        listing=listing,
                        image_url=img_url.strip(),
                        is_primary=(i == 0)
                    )

        return CreateListing(listing=listing, success=True, message="Tangazo na picha zimewekwa kikamilifu.")

class AddListingImage(graphene.Mutation):
    class Arguments:
        listing_id = graphene.ID(required=True)
        image_url = graphene.String(required=True)
        is_primary = graphene.Boolean(default_value=False)

    image = graphene.Field(ListingImageType)
    success = graphene.Boolean()
    message = graphene.String()

    def mutate(self, info, listing_id, image_url, is_primary=False):
        user = info.context.user
        if user.is_anonymous:
            raise GraphQLError("Lazima uwe umeingia kwenye akaunti.")

        try:
            listing = Listing.objects.get(pk=listing_id, owner=user)
        except Listing.DoesNotExist:
            raise GraphQLError("Tangazo halikupatikana au huna mamlaka nalo.")

        if is_primary:
            listing.images.update(is_primary=False)

        img = ListingImage.objects.create(
            listing=listing,
            image_url=image_url.strip(),
            is_primary=is_primary
        )
        return AddListingImage(image=img, success=True, message="Picha imeongezwa kikamilifu.")

class DeleteListingImage(graphene.Mutation):
    class Arguments:
        id = graphene.ID(required=True)

    success = graphene.Boolean()
    message = graphene.String()

    def mutate(self, info, id):
        user = info.context.user
        if user.is_anonymous:
            raise GraphQLError("Lazima uwe umeingia kwenye akaunti.")

        try:
            img = ListingImage.objects.select_related('listing').get(pk=id, listing__owner=user)
            img.delete()
            return DeleteListingImage(success=True, message="Picha imefutwa kikamilifu.")
        except ListingImage.DoesNotExist:
            raise GraphQLError("Picha haikupatikana.")

class UpdateListing(graphene.Mutation):
    class Arguments:
        id = graphene.ID(required=True)
        title = graphene.String(required=False)
        description = graphene.String(required=False)
        category = graphene.String(required=False)
        listing_type = graphene.String(required=False)
        price_per_day = graphene.Float(required=False)
        sale_price = graphene.Float(required=False)
        location = graphene.String(required=False)
        is_available = graphene.Boolean(required=False)
        features = graphene.List(graphene.String, required=False)

    listing = graphene.Field(ListingNode)
    success = graphene.Boolean()
    message = graphene.String()

    def mutate(self, info, id, **kwargs):
        user = info.context.user
        if user.is_anonymous:
            raise GraphQLError("Lazima uwe umeingia kwenye akaunti.")

        try:
            listing = Listing.objects.get(pk=id, owner=user)
        except Listing.DoesNotExist:
            raise GraphQLError("Tangazo halikupatikana au huna mamlaka nalo.")

        for key, val in kwargs.items():
            if val is not None:
                if key in ['category', 'listing_type']:
                    setattr(listing, key, val.upper())
                else:
                    setattr(listing, key, val)
        listing.save()
        return UpdateListing(listing=listing, success=True, message="Tangazo limesasishwa.")

class DeleteListing(graphene.Mutation):
    class Arguments:
        id = graphene.ID(required=True)

    success = graphene.Boolean()
    message = graphene.String()

    def mutate(self, info, id):
        user = info.context.user
        if user.is_anonymous:
            raise GraphQLError("Lazima uwe umeingia kwenye akaunti.")

        try:
            listing = Listing.objects.get(pk=id, owner=user)
            listing.delete()
            return DeleteListing(success=True, message="Tangazo limefutwa kikamilifu.")
        except Listing.DoesNotExist:
            raise GraphQLError("Tangazo halikupatikana.")

class Mutation(graphene.ObjectType):
    create_listing = CreateListing.Field()
    update_listing = UpdateListing.Field()
    delete_listing = DeleteListing.Field()
    add_listing_image = AddListingImage.Field()
    delete_listing_image = DeleteListingImage.Field()
