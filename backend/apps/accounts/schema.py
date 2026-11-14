import graphene
import base64
from graphene_django import DjangoObjectType
from graphql import GraphQLError
from .models import CustomUser, OTPVerification

try:
    from graphql_jwt.shortcuts import get_token
except ImportError:
    def get_token(user):
        payload = f"{user.id}:{user.phone}:{user.role}"
        return base64.b64encode(payload.encode('utf-8')).decode('utf-8')

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
        identifier = graphene.String(required=False)  # email or phone
        phone = graphene.String(required=False)       # backward compatibility

    Output = OTPResponseType

    def mutate(self, info, identifier=None, phone=None):
        raw = (identifier or phone or '').strip()
        if not raw:
            raise GraphQLError("Tafadhali weka barua pepe au namba ya simu.")

        target_phone = None
        if '@' in raw:
            # Owner login via email
            user = CustomUser.objects.filter(email__iexact=raw).first()
            if not user:
                raise GraphQLError("Barua pepe haijapatikana. Wasiliana na msimamizi wa mfumo.")
            target_phone = user.phone
        else:
            clean_phone = raw.replace(' ', '')
            if clean_phone.startswith('0'):
                clean_phone = '+255' + clean_phone[1:]
            elif clean_phone.startswith('255') and not clean_phone.startswith('+255'):
                clean_phone = '+' + clean_phone
            elif not clean_phone.startswith('+'):
                # assume local TZ number fragment
                clean_phone = '+255' + clean_phone

            user = CustomUser.objects.filter(phone=clean_phone).first()
            if user:
                target_phone = user.phone
            else:
                # New customer registration flow allowed only for phone numbers
                target_phone = clean_phone

        OTPVerification.generate_otp(target_phone)
        return OTPResponseType(
            success=True,
            message="Msimbo wa uthibitisho umetumwa.",
            phone=target_phone
        )

class VerifyOTP(graphene.Mutation):
    class Arguments:
        phone = graphene.String(required=False)
        identifier = graphene.String(required=False)
        otp_code = graphene.String(required=True)

    Output = VerifyOTPResponseType

    def mutate(self, info, otp_code, phone=None, identifier=None):
        raw = (phone or identifier or '').strip()
        clean_code = otp_code.strip()
        if not raw:
            raise GraphQLError("Taarifa za uthibitisho hazijakamilika.")

        if '@' in raw:
            user_obj = CustomUser.objects.filter(email__iexact=raw).first()
            if not user_obj:
                raise GraphQLError("Barua pepe haijapatikana.")
            clean_phone = user_obj.phone
        else:
            clean_phone = raw.replace(' ', '')
            if clean_phone.startswith('0'):
                clean_phone = '+255' + clean_phone[1:]
            elif clean_phone.startswith('255') and not clean_phone.startswith('+255'):
                clean_phone = '+' + clean_phone
            elif not clean_phone.startswith('+'):
                clean_phone = '+255' + clean_phone

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
                message="Uthibitisho umefanikiwa."
            )
        except CustomUser.DoesNotExist:
            return VerifyOTPResponseType(
                token=None,
                user_exists=False,
                user=None,
                message="Namba imethibitishwa. Kamilisha usajili wa akaunti ya mteja."
            )

class RegisterUser(graphene.Mutation):
    class Arguments:
        phone = graphene.String(required=True)
        name = graphene.String(required=True)
        role = graphene.String(required=False)  # Public registration is customer-only
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

    def mutate(self, info, phone, name, role='RENTER', **kwargs):
        clean_phone = phone.strip()
        if CustomUser.objects.filter(phone=clean_phone).exists():
            raise GraphQLError("Mtumiaji mwenye namba hii tayari yupo. Tafadhali ingia.")

        # Owners are created only by super admin
        user = CustomUser.objects.create_user(
            phone=clean_phone,
            name=name.strip(),
            role='RENTER',
            email=kwargs.get('email', ''),
            location=kwargs.get('location', ''),
            whatsapp_number=kwargs.get('whatsapp_number', clean_phone),
            instagram_handle=kwargs.get('instagram_handle', ''),
            facebook_url=kwargs.get('facebook_url', ''),
            tiktok_handle=kwargs.get('tiktok_handle', ''),
            nida_number=kwargs.get('nida_number', ''),
        )
        token = get_token(user)
        return RegisterUser(token=token, user=user, message="Akaunti ya mteja imefunguliwa kikamilifu.")

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

class LoginUser(graphene.Mutation):
    class Arguments:
        phone = graphene.String(required=True)
        password = graphene.String(required=True)

    token = graphene.String()
    user = graphene.Field(UserType)
    message = graphene.String()

    def mutate(self, info, phone, password):
        clean_phone = phone.strip()
        try:
            user = CustomUser.objects.get(phone=clean_phone)
        except CustomUser.DoesNotExist:
            raise GraphQLError("Namba ya simu au nenosiri si sahihi.")

        if not user.check_password(password):
            raise GraphQLError("Namba ya simu au nenosiri si sahihi.")

        if not user.is_active:
            raise GraphQLError("Akaunti hii imezimwa. Wasiliana na msimamizi.")

        token = get_token(user)
        return LoginUser(token=token, user=user, message="Umeingia kikamilifu.")

class CreateOwnerUser(graphene.Mutation):
    class Arguments:
        phone = graphene.String(required=True)
        name = graphene.String(required=True)
        location = graphene.String(required=False)
        email = graphene.String(required=False)
        whatsapp_number = graphene.String(required=False)
        instagram_handle = graphene.String(required=False)
        facebook_url = graphene.String(required=False)
        tiktok_handle = graphene.String(required=False)
        nida_number = graphene.String(required=False)
        password = graphene.String(required=False)

    user = graphene.Field(UserType)
    message = graphene.String()
    default_password = graphene.String()

    def mutate(self, info, phone, name, **kwargs):
        admin = info.context.user
        if admin.is_anonymous or not (admin.is_staff or admin.is_superuser):
            raise GraphQLError("Ruhusa imetolewa: super admin pekee anaweza kuongeza mwenye kifaa.")

        clean_phone = phone.strip()
        if CustomUser.objects.filter(phone=clean_phone).exists():
            raise GraphQLError("Mtumiaji mwenye namba hii tayari yupo.")

        password = (kwargs.get('password') or 'Kodisha@123').strip() or 'Kodisha@123'
        user = CustomUser.objects.create_user(
            phone=clean_phone,
            name=name.strip(),
            role='OWNER',
            password=password,
            email=kwargs.get('email', ''),
            location=kwargs.get('location', ''),
            whatsapp_number=kwargs.get('whatsapp_number', clean_phone),
            instagram_handle=kwargs.get('instagram_handle', ''),
            facebook_url=kwargs.get('facebook_url', ''),
            tiktok_handle=kwargs.get('tiktok_handle', ''),
            nida_number=kwargs.get('nida_number', ''),
            is_verified=True,
        )
        return CreateOwnerUser(
            user=user,
            message="Mwenye kifaa ameongezwa kikamilifu.",
            default_password=password,
        )

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
    login_user = LoginUser.Field()
    create_owner_user = CreateOwnerUser.Field()

