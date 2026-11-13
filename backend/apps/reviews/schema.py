import graphene
from graphene_django import DjangoObjectType
from graphql import GraphQLError
from .models import Review
from apps.bookings.models import Booking
from apps.listings.schema import ListingNode
from apps.accounts.schema import UserType

class ReviewType(DjangoObjectType):
    class Meta:
        model = Review
        fields = (
            'id', 'booking', 'listing', 'renter', 'owner',
            'rating', 'comment', 'created_at'
        )

class Query(graphene.ObjectType):
    reviews_by_listing = graphene.List(ReviewType, listing_id=graphene.ID(required=True))
    reviews_by_owner = graphene.List(ReviewType, owner_id=graphene.ID(required=True))

    def resolve_reviews_by_listing(self, info, listing_id):
        return Review.objects.filter(listing_id=listing_id).select_related('renter', 'listing')

    def resolve_reviews_by_owner(self, info, owner_id):
        return Review.objects.filter(owner_id=owner_id).select_related('renter', 'listing')

class CreateReview(graphene.Mutation):
    class Arguments:
        booking_id = graphene.ID(required=True)
        rating = graphene.Int(required=True)
        comment = graphene.String(required=True)

    review = graphene.Field(ReviewType)
    success = graphene.Boolean()
    message = graphene.String()

    def mutate(self, info, booking_id, rating, comment):
        user = info.context.user
        if user.is_anonymous:
            raise GraphQLError("Lazima uwe umeingia kwenye akaunti.")

        if rating < 1 or rating > 5:
            raise GraphQLError("Kiwango cha nyota lazima kiwe kati ya 1 na 5.")

        try:
            booking = Booking.objects.select_related('listing', 'owner').get(pk=booking_id)
        except Booking.DoesNotExist:
            raise GraphQLError("Booking haikupatikana.")

        if booking.renter != user:
            raise GraphQLError("Ni mteja aliyekodi pekee anayeruhusiwa kutoa tathmini ya booking hii.")

        review = Review.objects.create(
            booking=booking,
            listing=booking.listing,
            renter=user,
            owner=booking.owner,
            rating=rating,
            comment=comment.strip()
        )

        return CreateReview(
            review=review,
            success=True,
            message="Asante kwa kutoa maoni yako!"
        )

class Mutation(graphene.ObjectType):
    create_review = CreateReview.Field()

