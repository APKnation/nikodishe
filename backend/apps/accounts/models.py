import random
from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, BaseUserManager
from django.utils import timezone
from datetime import timedelta

class CustomUserManager(BaseUserManager):
    def create_user(self, phone, name='', role='RENTER', password=None, **extra_fields):
        if not phone:
            raise ValueError('Namba ya simu inahitajika.')
        phone = phone.strip()
        user = self.model(phone=phone, name=name, role=role, **extra_fields)
        if password:
            user.set_password(password)
        else:
            user.set_unusable_password()
        user.save(using=self._db)
        return user

    def create_superuser(self, phone, password, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('role', 'OWNER')

        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser lazima awe na is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser lazima awe na is_superuser=True.')

        return self.create_user(phone, password=password, **extra_fields)

class CustomUser(AbstractBaseUser, PermissionsMixin):
    ROLE_CHOICES = (
        ('RENTER', 'Mkodishaji / Mteja (Customer)'),
        ('OWNER', 'Mmiliki wa Vifaa (Equipment Owner)'),
    )

    phone = models.CharField(max_length=20, unique=True, verbose_name='Namba ya Simu')
    name = models.CharField(max_length=150, verbose_name='Jina Kamili')
    email = models.EmailField(blank=True, null=True, verbose_name='Barua Pepe')
    role = models.CharField(max_length=10, choices=ROLE_CHOICES, default='RENTER', verbose_name='Wadhifa / Role')
    location = models.CharField(max_length=255, blank=True, verbose_name='Eneo / Mji')
    profile_photo = models.ImageField(upload_to='profiles/', blank=True, null=True, verbose_name='Picha ya Wasifu')
    
    # Social and Contact links (For FR5 & direct contact)
    whatsapp_number = models.CharField(max_length=20, blank=True, verbose_name='Namba ya WhatsApp')
    instagram_handle = models.CharField(max_length=100, blank=True, verbose_name='Instagram (@username)')
    facebook_url = models.CharField(max_length=255, blank=True, verbose_name='Facebook URL au Jina')
    tiktok_handle = models.CharField(max_length=100, blank=True, verbose_name='TikTok (@username)')
    
    # Identity & Trust
    nida_number = models.CharField(max_length=30, blank=True, verbose_name='Namba ya NIDA')
    is_verified = models.BooleanField(default=False, verbose_name='Imethibitishwa')
    rating = models.FloatField(default=0.0, verbose_name='Kiwango cha Ukadiriaji')
    review_count = models.PositiveIntegerField(default=0, verbose_name='Idadi ya Maoni')

    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    objects = CustomUserManager()

    USERNAME_FIELD = 'phone'
    REQUIRED_FIELDS = ['name']

    class Meta:
        verbose_name = 'Mtumiaji'
        verbose_name_plural = 'Watumiaji'

    def __str__(self):
        return f"{self.name} ({self.phone}) - {self.role}"

class OTPVerification(models.Model):
    phone = models.CharField(max_length=20, verbose_name='Namba ya Simu')
    otp_code = models.CharField(max_length=6, verbose_name='Msimbo wa OTP')
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()
    is_used = models.BooleanField(default=False)

    class Meta:
        verbose_name = 'Uthibitishaji wa OTP'
        verbose_name_plural = 'Mithibitisho ya OTP'

    def is_valid(self):
        return not self.is_used and timezone.now() <= self.expires_at

    @classmethod
    def generate_otp(cls, phone):
        # Cryptographically strong 6-digit code (never hardcoded).
        code = f"{random.SystemRandom().randint(100000, 999999)}"
        expires = timezone.now() + timedelta(minutes=5)
        otp_record = cls.objects.create(
            phone=phone.strip(),
            otp_code=code,
            expires_at=expires
        )
        return otp_record

