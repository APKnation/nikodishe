import base64
import json
from unittest.mock import patch

from django.test import TestCase

from apps.accounts.models import CustomUser


def _token_for(user):
    payload = f'{user.id}:{user.phone}:{user.role}'
    return base64.b64encode(payload.encode('utf-8')).decode('utf-8')


class AIChatTests(TestCase):
    def test_chat_requires_message(self):
        response = self.client.post(
            '/api/ai/chat/',
            data=json.dumps({}),
            content_type='application/json',
        )
        self.assertEqual(response.status_code, 400)
        self.assertFalse(response.json()['success'])

    @patch('apps.ai_assistant.services._chat', return_value='Jibu la AI')
    def test_chat_returns_reply(self, mocked_chat):
        response = self.client.post(
            '/api/ai/chat/',
            data=json.dumps({'message': 'Ninawezaje kukodisha tent?'}),
            content_type='application/json',
        )
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()['reply'], 'Jibu la AI')
        mocked_chat.assert_called_once()


class AIAnalyzeTests(TestCase):
    def test_analyze_requires_authentication(self):
        response = self.client.post(
            '/api/ai/analyze/',
            data='{}',
            content_type='application/json',
        )
        self.assertEqual(response.status_code, 401)

    def test_renter_cannot_analyze(self):
        user = CustomUser.objects.create_user(
            phone='+255700111111', name='Mteja', role='RENTER'
        )
        response = self.client.post(
            '/api/ai/analyze/',
            data='{}',
            content_type='application/json',
            HTTP_AUTHORIZATION=f'Bearer {_token_for(user)}',
        )
        self.assertEqual(response.status_code, 403)

    @patch(
        'apps.ai_assistant.services._chat',
        return_value='Ripoti ya uchambuzi',
    )
    def test_owner_gets_scoped_analysis(self, mocked_chat):
        owner = CustomUser.objects.create_user(
            phone='+255700222222', name='Mmiliki', role='OWNER'
        )
        response = self.client.post(
            '/api/ai/analyze/',
            data=json.dumps({'focus': 'Mapato'}),
            content_type='application/json',
            HTTP_AUTHORIZATION=f'Bearer {_token_for(owner)}',
        )
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertEqual(data['analysis'], 'Ripoti ya uchambuzi')
        self.assertEqual(data['scope'], 'owner')
        self.assertEqual(data['snapshot']['kwa_mmiliki'], 'Mmiliki')
        mocked_chat.assert_called_once()
