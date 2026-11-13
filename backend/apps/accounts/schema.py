import graphene
from graphene_django import DjangoObjectType
from graphql_jwt.shortcuts import get_token
from graphql import GraphQLError
from .models import CustomUser, OTPVerification

class UserType(DjangoObjectType):
    class Meta:
        model = CustomUser
        fields = (
            'id', 'phone', 'name', 'email', 'role', 'location',
            'profile_photo', 'whatsapp_number', 'instagram_handle',
            'facebook_url', 'tiktok_handle', 'nida_number',
            'is_verified', 'rating', 'review_count', 'created_at'
        )

class OTPResponseType(graphene.ObjectType):
    success = graphene.Boolean()
    message = graphene.String()
    phone = graphene.String()

class VerifyOTPResponseType(graphene.ObjectType):
    token = graphene.String()
    user_exists = graphene.Boolean()
    user = graphene.Field(UserType)
    message = graphene.String()

# Mutations
class SendOTP(graphene.Mutation):
    class Arguments:
        phone = graphene.String(required=True)

    Output = OTPResponseType

    def mutate(self, info, phone):
        clean_phone = phone.strip()
        if not clean_phone:
            raise GraphQLError("Tafadhali weka namba sahihi ya simu.")
        
        otp = OTPVerification.generate_otp(clean_phone)
        return OTPResponseType(
            success=True,
            message="OTP imetumwa kikamilifu kwenye namba yako.",
            phone=clean_phone
        )

class VerifyOTP(graphene.Mutation):
    class Arguments:
        phone = graphene.String(required=True)
        otp_code = graphene.String(required=True)

    Output = VerifyOTPResponseType

    def mutate(self, info, phone, otp_code):
        clean_phone = phone.strip()
        clean_code = otp_code.strip()

        # Check OTP in database (or demo code '123456')
        otp_records = OTPVerification.objects.filter(
            phone=clean_phone,
            otp_code=clean_code,
            is_used=False
        ).order_by('-created_at')

        valid_otp = None
        for record in otp_records:
            if record.is_valid() or clean_code == '123456':
                valid_otp = record
                break

        if not valid_otp and clean_code != '123456':
            raise GraphQLError("Msimbo wa OTP si sahihi au umepitwa na wakati.")

        if valid_otp:
            valid_otp.is_used = True
            valid_otp.save()

        # Check if user already registered
        try:
            user = CustomUser.objects.get(phone=clean_phone)
            token = get_token(user)
            return VerifyOTPResponseType(
                token=token,
                user_exists=True,
                user=user,
                message="Umeingia kikamilifu."
            )
        except CustomUser.DoesNotExist:
            return VerifyOTPResponseType(
                token=None,
                user_exists=False,
                user=None,
                message="Namba imethibitishwa. Kamilisha usajili wa akaunti."
            )

class RegisterUser(graphene.Mutation):
    class Arguments:
        phone = graphene.String(required=True)
        name = graphene.String(required=True)
        role = graphene.String(required=True) # 'RENTER' or 'OWNER'
        location = graphene.String(required=False)
        email = graphene.String(required=False)
        whatsapp_number = graphene.String(required=False)
        instagram_handle = graphene.String(required=False)
        facebook_url = graphene.String(required=False)
        tiktok_handle = graphene.String(required=False)
        nida_number = graphene.String(required=False)

    token = graphene.String()
    user = graphene.Field(UserType)
    message = graphene.String()

    def mutate(self, info, phone, name, role, **kwargs):
        clean_phone = phone.strip()
        if CustomUser.objects.filter(phone=clean_phone).exists():
            raise GraphQLError("Mtumiaji mwenye namba hii tayari yupo. Tafadhali ingia.")

        user = CustomUser.objects.create_user(
            phone=clean_phone,
            name=name.strip(),
            role=role.upper(),
            email=kwargs.get('email', ''),
            location=kwargs.get('location', ''),
            whatsapp_number=kwargs.get('whatsapp_number', clean_phone),
            instagram_handle=kwargs.get('instagram_handle', ''),
            facebook_url=kwargs.get('facebook_url', ''),
            tiktok_handle=kwargs.get('tiktok_handle', ''),
            nida_number=kwargs.get('nida_number', ''),
        )
        token = get_token(user)
        return RegisterUser(token=token, user=user, message="Umefanikiwa kujisajili.")

class UpdateProfile(graphene.Mutation):
    class Arguments:
        name = graphene.String(required=False)
        email = graphene.String(required=False)
        location = graphene.String(required=False)
        whatsapp_number = graphene.String(required=False)
        instagram_handle = graphene.String(required=False)
        facebook_url = graphene.String(required=False)
        tiktok_handle = graphene.String(required=False)
        nida_number = graphene.String(required=False)

    user = graphene.Field(UserType)
    message = graphene.String()

    def mutate(self, info, **kwargs):
        user = info.context.user
        if user.is_anonymous:
            raise GraphQLError("Lazima uwe umeingia kwenye akaunti ili kubadili taarifa.")

        for key, value in kwargs.items():
            if value is not None:
                setattr(user, key, value)
        user.save()
        return UpdateProfile(user=user, message="Wasifu umesasishwa kikamilifu.")

class Query(graphene.ObjectType):
    me = graphene.Field(UserType)
    user_by_id = graphene.Field(UserType, id=graphene.ID(required=True))

    def resolve_me(self, info):
        user = info.context.user
        if user.is_anonymous:
            return None
        return user

    def resolve_user_by_id(self, info, id):
        try:
            return CustomUser.objects.get(pk=id)
        except CustomUser.DoesNotExist:
            return None

class Mutation(graphene.ObjectType):
    send_otp = SendOTP.Field()
    verify_otp = VerifyOTP.Field()
    register_user = RegisterUser.Field()
    update_profile = UpdateProfile.Field()

