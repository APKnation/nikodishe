import graphene
from graphene_django import DjangoObjectType
from graphql import GraphQLError
from django.db.models import Q
from .models import Payment
from apps.bookings.models import Booking
from apps.accounts.schema import UserType
from apps.bookings.schema import BookingType

class PaymentNodeType(DjangoObjectType):
    class Meta:
        model = Payment
        fields = (
            'id', 'booking', 'renter', 'owner', 'amount',
            'payment_method', 'payment_type', 'status',
            'reference_code', 'phone_number', 'created_at'
        )

class Query(graphene.ObjectType):
    my_payments = graphene.List(PaymentNodeType)
    payment_by_ref = graphene.Field(PaymentNodeType, reference_code=graphene.String(required=True))

    def resolve_my_payments(self, info):
        user = info.context.user
        if user.is_anonymous:
            raise GraphQLError("Lazima uwe umeingia kwenye akaunti.")
        return Payment.objects.filter(
            Q(renter=user) | Q(owner=user)
        ).select_related('booking', 'renter', 'owner')

    def resolve_payment_by_ref(self, info, reference_code):
        try:
            return Payment.objects.select_related('booking', 'renter', 'owner').get(reference_code=reference_code.strip())
        except Payment.DoesNotExist:
            return None

class ProcessPayment(graphene.Mutation):
    class Arguments:
        booking_id = graphene.ID(required=True)
        amount = graphene.Float(required=True)
        payment_method = graphene.String(required=True) # MPESA, AIRTEL_MONEY, TIGO_PESA, HALOPESA
        payment_type = graphene.String(required=True) # DEPOSIT, FULL, REMAINDER
        phone_number = graphene.String(required=True)

    payment = graphene.Field(PaymentNodeType)
    success = graphene.Boolean()
    message = graphene.String()

    def mutate(self, info, booking_id, amount, payment_method, payment_type, phone_number):
        user = info.context.user
        if user.is_anonymous:
            raise GraphQLError("Lazima uwe umeingia kwenye akaunti ili kufanya malipo.")

        try:
            booking = Booking.objects.select_related('owner', 'listing').get(pk=booking_id)
        except Booking.DoesNotExist:
            raise GraphQLError("Booking haikupatikana.")

        ref_code = Payment.generate_reference()
        payment = Payment.objects.create(
            booking=booking,
            renter=user,
            owner=booking.owner,
            amount=amount,
            payment_method=payment_method.upper(),
            payment_type=payment_type.upper(),
            status='COMPLETED',
            reference_code=ref_code,
            phone_number=phone_number.strip()
        )

        # Update booking status to confirmed if deposit or full is paid
        if payment_type.upper() in ['DEPOSIT', 'FULL']:
            booking.status = 'CONFIRMED'
            booking.save()

        return ProcessPayment(
            payment=payment,
            success=True,
            message="Malipo yamekamilika kikamilifu. Uthibitisho umetumwa."
        )

class Mutation(graphene.ObjectType):
    process_payment = ProcessPayment.Field()
