from pathlib import Path
import os

BASE_DIR = Path(__file__).resolve().parent.parent


def _load_env_file(path):
    """
    Loader nyepesi wa backend/.env bila dependency ya ziada.
    Environment variables zilizowekwa tayari (mf. kwenye shell) hazibadilishwi.
    """
    try:
        with open(path, encoding='utf-8') as env_file:
            for raw_line in env_file:
                line = raw_line.strip()
                if not line or line.startswith('#') or '=' not in line:
                    continue
                key, value = line.split('=', 1)
                key = key.strip()
                value = value.strip().strip('"').strip("'")
                if key:
                    os.environ.setdefault(key, value)
    except FileNotFoundError:
        pass


_load_env_file(BASE_DIR / '.env')

SECRET_KEY = os.environ.get(
    'DJANGO_SECRET_KEY',
    'django-insecure-kodisha-tanzania-secret-key-super-secure-change-in-prod-2025'
)

DEBUG = os.environ.get('DJANGO_DEBUG', 'True') == 'True'

ALLOWED_HOSTS = ['*']

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',

    # Third party apps
    'corsheaders',
    'graphene_django',

    # Local apps
    'apps.accounts',
    'apps.listings',
    'apps.bookings',
    'apps.payments',
    'apps.reviews',
    'apps.notifications',
    'apps.ai_assistant',
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'kodisha_backend.middleware.KodishaFallbackTokenMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'kodisha_backend.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'kodisha_backend.wsgi.application'
ASGI_APPLICATION = 'kodisha_backend.asgi.application'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

AUTH_USER_MODEL = 'accounts.CustomUser'

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

try:
    import graphql_jwt
    HAS_GRAPHQL_JWT = True
except ImportError:
    HAS_GRAPHQL_JWT = False

AUTHENTICATION_BACKENDS = [
    'django.contrib.auth.backends.ModelBackend',
]
if HAS_GRAPHQL_JWT:
    AUTHENTICATION_BACKENDS.insert(0, 'graphql_jwt.backends.JSONWebTokenBackend')

# Graphene GraphQL Configuration
GRAPHENE = {
    'SCHEMA': 'kodisha_backend.schema.schema',
}
if HAS_GRAPHQL_JWT:
    GRAPHENE['MIDDLEWARE'] = [
        'graphql_jwt.middleware.JSONWebTokenMiddleware',
    ]

from datetime import timedelta
GRAPHQL_JWT = {
    'JWT_VERIFY_EXPIRATION': True,
    'JWT_EXPIRATION_DELTA': timedelta(days=7),
    'JWT_REFRESH_EXPIRATION_DELTA': timedelta(days=30),
    'JWT_AUTH_HEADER_PREFIX': 'Bearer',
}

# Internationalization
LANGUAGE_CODE = 'sw'  # Default Kiswahili
TIME_ZONE = 'Africa/Dar_es_Salaam'
USE_I18N = True
USE_TZ = True

# Static files (CSS, JavaScript, Images)
STATIC_URL = 'static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'

# Media files (Listing images, Profile photos)
MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

# Ruhusu uploads za picha (wasifu, vifaa) kupita kikomo cha default cha Django
DATA_UPLOAD_MAX_MEMORY_SIZE = 10 * 1024 * 1024  # 10MB
FILE_UPLOAD_MAX_MEMORY_SIZE = 10 * 1024 * 1024  # 10MB

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# CORS Settings
CORS_ALLOW_ALL_ORIGINS = True
CORS_ALLOW_CREDENTIALS = True

# ─── Kodisha AI ──────────────────────────────────────────────────────────────
# AI_PROVIDER: "gemini" (bure, inahitaji GEMINI_API_KEY) au "ollama".
AI_PROVIDER = os.environ.get('AI_PROVIDER', 'gemini').strip().lower()
AI_TIMEOUT = int(os.environ.get('AI_TIMEOUT', '90'))

# Google Gemini (free tier): https://aistudio.google.com/apikey
GEMINI_API_KEY = os.environ.get('GEMINI_API_KEY', '')
GEMINI_MODEL = os.environ.get('GEMINI_MODEL', 'gemini-3.5-flash-lite')
GEMINI_BASE_URL = os.environ.get(
    'GEMINI_BASE_URL', 'https://generativelanguage.googleapis.com/v1beta'
)

# Ollama Cloud / local Ollama (hiari)
OLLAMA_BASE_URL = os.environ.get('OLLAMA_BASE_URL', 'https://ollama.com')
OLLAMA_API_KEY = os.environ.get('OLLAMA_API_KEY', '')
OLLAMA_MODEL = os.environ.get('OLLAMA_MODEL', 'gpt-oss:120b')
OLLAMA_TIMEOUT = int(os.environ.get('OLLAMA_TIMEOUT', '90'))

