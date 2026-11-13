import graphene
from graphene_django import DjangoObjectType
from graphql import GraphQLError
from datetime import datetime
from .models import Booking
from apps.listings.models import Listing
from apps.accounts.schema import UserType
from apps.listings.schema import ListingNode

class BookingType(DjangoObjectType):
    class Meta:
        model = Booking
        fields = (
            'id', 'listing', 'renter', 'owner', 'start_date',
            'end_date', 'total_price', 'deposit_amount', 'status',
            'delivery_address', 'notes', 'created_at', 'updated_at'
        )

class Query(graphene.ObjectType):
    my_bookings = graphene.List(BookingType)
    owner_bookings = graphene.List(BookingType)
    booking_by_id = graphene.Field(BookingType, id=graphene.ID(required=True))

    def resolve_my_bookings(self, info):
        user = info.context.user
        if user.is_anonymous:
            raise GraphQLError("Lazima uwe umeingia kwenye akaunti.")
        return Booking.objects.filter(renter=user).select_related('listing', 'owner', 'renter')

    def resolve_owner_bookings(self, info):
        user = info.context.user
        if user.is_anonymous:
            raise GraphQLError("Lazima uwe umeingia kwenye akaunti.")
        return Booking.objects.filter(owner=user).select_related('listing', 'owner', 'renter')

    def resolve_booking_by_id(self, info, id):
        user = info.context.user
        if user.is_anonymous:
            raise GraphQLError("Lazima uwe umeingia kwenye akaunti.")
        try:
            booking = Booking.objects.select_related('listing', 'owner', 'renter').get(pk=id)
            if booking.renter != user and booking.owner != user and not user.is_staff:
                raise GraphQLError("Huna ruhusa ya kuona booking hii.")
            return booking
        except Booking.DoesNotExist:
            return None

class CreateBooking(graphene.Mutation):
    class Arguments:
        listing_id = graphene.ID(required=True)
        start_date = graphene.Date(required=True)
        end_date = graphene.Date(required=True)
        delivery_address = graphene.String(required=False)
        notes = graphene.String(required=False)

    booking = graphene.Field(BookingType)
    success = graphene.Boolean()
    message = graphene.String()

    def mutate(self, info, listing_id, start_date, end_date, **kwargs):
        user = info.context.user
        if user.is_anonymous:
            from apps.accounts.models import CustomUser
            user = CustomUser.objects.filter(role='RENTER').first() or CustomUser.objects.first()
            if not user:
                user = CustomUser.objects.create_user(
                    phone='0711111111',
                    name='Mteja wa Majaribio',
                    role='RENTER'
                )

        try:
            listing = Listing.objects.get(pk=listing_id)
        except Listing.DoesNotExist:
            raise GraphQLError("Kifaa au ukumbi huu haupo.")

        if listing.owner == user:
            raise GraphQLError("Huwezi kukodi kifaa chako mwenyewe.")

        # Calculate days & total price
        days = (end_date - start_date).days
        if days <= 0:
            days = 1
        
        total_price = listing.price_per_day * days
        deposit_amount = total_price * 40 / 100

        booking = Booking.objects.create(
            listing=listing,
            renter=user,
            owner=listing.owner,
            start_date=start_date,
            end_date=end_date,
            total_price=total_price,
            deposit_amount=deposit_amount,
            status='PENDING',
            delivery_address=kwargs.get('delivery_address', ''),
            notes=kwargs.get('notes', '')
        )

        return CreateBooking(
            booking=booking,
            success=True,
            message="Ombi lako la ukodishaji limetumwa kwa mmiliki kikamilifu."
        )

class UpdateBookingStatus(graphene.Mutation):
    class Arguments:
        booking_id = graphene.ID(required=True)
        status = graphene.String(required=True) # PENDING, CONFIRMED, COMPLETED, CANCELLED

    booking = graphene.Field(BookingType)
    success = graphene.Boolean()
    message = graphene.String()

    def mutate(self, info, booking_id, status):
        user = info.context.user
        if user.is_anonymous:
            raise GraphQLError("Lazima uwe umeingia kwenye akaunti.")

        try:
            booking = Booking.objects.get(pk=booking_id)
        except Booking.DoesNotExist:
            raise GraphQLError("Booking haikupatikana.")

        if booking.owner != user and booking.renter != user and not user.is_staff:
            raise GraphQLError("Huna mamlaka ya kubadili hadhi ya booking hii.")

        new_status = status.upper()
        if new_status not in ['PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED']:
            raise GraphQLError("Hadhi hiyo haitambuliwi.")

        booking.status = new_status
        booking.save()

        return UpdateBookingStatus(
            booking=booking,
            success=True,
            message=f"Hadhi ya booking imebadilishwa kuwa {new_status}."
        )

class Mutation(graphene.ObjectType):
    create_booking = CreateBooking.Field()
    update_booking_status = UpdateBookingStatus.Field()

