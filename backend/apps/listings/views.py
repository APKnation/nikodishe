import os
import uuid
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.core.files.storage import default_storage
from django.core.files.base import ContentFile
from django.conf import settings

@csrf_exempt
def upload_image_view(request):
    """
    Endpoint ya ku-upload picha moja kwa moja kutoka kwenye simu au web.
    Inapokea multipart/form-data na kurudisha URL kamili ya picha.
    """
    if request.method != 'POST':
        return JsonResponse({'error': 'Njia inayoruhusiwa ni POST tu.'}, status=405)

    if 'image' not in request.FILES:
        return JsonResponse({'error': 'Tafadhali chagua faili la picha (field: image).'}, status=400)

    image_file = request.FILES['image']
    ext = os.path.splitext(image_file.name)[1].lower()
    if ext not in ['.jpg', '.jpeg', '.png', '.webp']:
        ext = '.jpg'

    filename = f"listings/{uuid.uuid4().hex}{ext}"
    saved_path = default_storage.save(filename, ContentFile(image_file.read()))
    full_url = request.build_absolute_uri(settings.MEDIA_URL + saved_path)

    return JsonResponse({
        'success': True,
        'message': 'Picha imepakiwa kikamilifu.',
        'image_url': full_url,
        'relative_path': settings.MEDIA_URL + saved_path,
    })

