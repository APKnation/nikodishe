import json

from django.core.cache import cache
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt

from .services import (
    AIUnavailable,
    customer_support_reply,
    is_configured,
    project_analysis,
)

MAX_MESSAGE_LENGTH = 2000


def _client_ip(request):
    forwarded = request.META.get('HTTP_X_FORWARDED_FOR', '')
    if forwarded:
        return forwarded.split(',')[0].strip()
    return request.META.get('REMOTE_ADDR', 'unknown')


def _throttled(request, bucket, limit=30, window=60):
    """Kinga nyepesi ya matumizi kupita kiasi (requests kwa dakika)."""
    key = f'ai_rate_{bucket}_{_client_ip(request)}'
    count = cache.get(key, 0)
    if count >= limit:
        return True
    cache.set(key, count + 1, timeout=window)
    return False


def _parse_json(request):
    try:
        return json.loads((request.body or b'{}').decode('utf-8'))
    except (UnicodeDecodeError, json.JSONDecodeError):
        return None


def _error(message, status=400, **extra):
    payload = {'success': False, 'error': message}
    payload.update(extra)
    return JsonResponse(payload, status=status)


@csrf_exempt
def chat_view(request):
    """
    POST /api/ai/chat/
    Body: {"message": "...", "history": [{"role": "user", "content": "..."}],
           "lang": "sw"}
    """
    if request.method != 'POST':
        return _error('Njia inayoruhusiwa ni POST tu.', status=405)

    if _throttled(request, 'chat', limit=30, window=60):
        return _error('Maombi ni mengi mno. Tafadhali subiri dakika moja.', status=429)

    body = _parse_json(request)
    if body is None:
        return _error('Data yaliyotumwa si JSON sahihi.')

    message = (body.get('message') or '').strip()
    if not message:
        return _error('Tafadhali andika swali lako.')
    if len(message) > MAX_MESSAGE_LENGTH:
        return _error('Swali ni refu mno. Tafadhali lifyingishe kwa ufupi.')

    history = body.get('history')
    if not isinstance(history, list):
        history = []
    clean_history = []
    for item in history[-10:]:
        if not isinstance(item, dict):
            continue
        role = item.get('role')
        content = item.get('content')
        if role in ('user', 'assistant') and isinstance(content, str) and content.strip():
            clean_history.append({'role': role, 'content': content.strip()[:1000]})

    lang = 'en' if str(body.get('lang', 'sw')).lower().startswith('en') else 'sw'
    user = request.user if getattr(request.user, 'is_authenticated', False) else None

    try:
        reply = customer_support_reply(
            message=message,
            history=clean_history,
            lang=lang,
            user=user,
        )
    except AIUnavailable as exc:
        return _error(str(exc), status=503, configured=is_configured())

    return JsonResponse({
        'success': True,
        'reply': reply,
        'model': _model_name(),
    })


@csrf_exempt
def analyze_view(request):
    """
    POST /api/ai/analyze/
    Body: {"focus": "..."} (hiari)

    - Staff/Superuser: uchambuzi wa jukwaa zima.
    - Owner: uchambuzi wa biashara yake pekee.
    - Wengine: hawaruhusiwi.
    """
    if request.method != 'POST':
        return _error('Njia inayoruhusiwa ni POST tu.', status=405)

    user = request.user
    if not getattr(user, 'is_authenticated', False):
        return _error('Lazima uwe umeingia kwenye akaunti.', status=401)

    is_staff = bool(getattr(user, 'is_staff', False) or getattr(user, 'is_superuser', False))
    is_owner = getattr(user, 'role', '') == 'OWNER'
    if not (is_staff or is_owner):
        return _error('Uchambuzi wa AI unapatikana kwa wenye vifaa na wasimamizi pekee.', status=403)

    if _throttled(request, 'analyze', limit=10, window=60):
        return _error('Maombi ni mengi mno. Tafadhali subiri dakika moja.', status=429)

    body = _parse_json(request)
    if body is None:
        return _error('Data yaliyotumwa si JSON sahihi.')

    focus = (body.get('focus') or '').strip()[:300] or None

    try:
        analysis, snapshot = project_analysis(
            user=None if is_staff else user,
            focus=focus,
        )
    except AIUnavailable as exc:
        return _error(str(exc), status=503, configured=is_configured())

    return JsonResponse({
        'success': True,
        'analysis': analysis,
        'scope': 'platform' if is_staff else 'owner',
        'snapshot': snapshot,
        'model': _model_name(),
    })


def _model_name():
    from django.conf import settings
    return getattr(settings, 'OLLAMA_MODEL', '')
