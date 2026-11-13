import base64
from django.utils.deprecation import MiddlewareMixin

class KodishaFallbackTokenMiddleware(MiddlewareMixin):
    """
    Middleware inayotambua token ya uthibitishaji kwenye 'Authorization: Bearer <token>'
    hata kama django-graphql-jwt haijasakinishwa kwenye mazingira ya sasa.
    """
    def process_request(self, request):
        if getattr(request, 'user', None) and request.user.is_authenticated:
            return

        auth_header = request.META.get('HTTP_AUTHORIZATION', '')
        if auth_header.startswith('Bearer '):
            token = auth_header.split('Bearer ')[1].strip()
            try:
                from apps.accounts.models import CustomUser
                decoded = base64.b64decode(token).decode('utf-8')
                parts = decoded.split(':')
                if len(parts) >= 2:
                    user_id = parts[0]
                    user = CustomUser.objects.filter(id=user_id).first()
                    if user:
                        request.user = user
            except Exception:
                pass
