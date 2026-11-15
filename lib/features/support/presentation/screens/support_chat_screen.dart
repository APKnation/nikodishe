import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/locale_provider.dart';
import '../../../../data/services/api_service.dart';

class _ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
  });
}

/// Chat ya msaada inayojibiwa na Kodisha AI (backend: Ollama Cloud).
class SupportChatScreen extends ConsumerStatefulWidget {
  const SupportChatScreen({super.key});

  @override
  ConsumerState<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends ConsumerState<SupportChatScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<_ChatMessage> _messages = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _messages.add(const _ChatMessage(
      text: 'Habari! Mimi ni Kodisha AI 🤖\n'
          'Ninaweza kukusaidia kuhusu kukodisha vifaa, malipo, bookings, '
          'au kukusaidia kutumia Kodisha. Uliza swali lolote!',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send([String? preset]) async {
    if (_sending) return;
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty) return;

    final lang = ref.read(localeProvider);

    // Historia ya mazungumzo kabla ya swali jipya (bila ujumbe wa makosa).
    final history = _messages
        .where((m) => !m.isError)
        .map((m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.text,
            })
        .toList();

    _controller.clear();
    _focusNode.unfocus();
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _sending = true;
    });
    _scrollToBottom();

    try {
      final reply = await _api.aiChat(
        message: text,
        history: history,
        lang: lang == AppLanguage.en ? 'en' : 'sw',
      );
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(text: reply, isUser: false));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(
          text: e.toString(),
          isUser: false,
          isError: true,
        ));
      });
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);
    final isSw = lang == AppLanguage.sw;

    final suggestions = isSw
        ? const [
            'Ninawezaje kukodisha kifaa?',
            'Malipo yanafanyikaje?',
            'Amana ya 40% ni nini?',
            'Naweza kuuza vifaa vyangu?',
          ]
        : const [
            'How do I rent an item?',
            'How does payment work?',
            'What is the 40% deposit?',
            'Can I sell my equipment?',
          ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: AppColors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isSw ? 'Kodisha AI' : 'Kodisha AI'),
                Text(
                  isSw ? 'Msaidizi wa wateja • Papo kwa papo' : 'Customer assistant • Instant',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _messages.length + (_sending ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _messages.length) {
                  return _TypingBubble(isSw: isSw);
                }
                return _MessageBubble(message: _messages[index]);
              },
            ),
          ),
          if (_messages.length <= 1)
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return ActionChip(
                    label: Text(suggestion),
                    onPressed: _sending ? null : () => _send(suggestion),
                    backgroundColor: AppColors.white,
                    side: const BorderSide(color: AppColors.border),
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            decoration: const BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            hintText: isSw
                                ? 'Andika swali lako hapa...'
                                : 'Type your question here...',
                            filled: true,
                            fillColor: AppColors.surfaceSubtle,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Material(
                        color: _sending ? AppColors.blueTint : AppColors.primary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _sending ? null : _send,
                          child: SizedBox(
                            width: 46,
                            height: 46,
                            child: Icon(
                              Icons.send_rounded,
                              color: _sending ? AppColors.textTertiary : AppColors.white,
                              size: 21,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isSw
                        ? 'Majibu yanasaidiwa na AI. Kwa dharura piga 0700 000 000.'
                        : 'Answers are AI-assisted. For emergencies call 0700 000 000.',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final bg = isUser
        ? AppColors.primary
        : message.isError
            ? AppColors.amberTint
            : AppColors.white;
    final fg = isUser ? AppColors.white : AppColors.textPrimary;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: bg,
          border: isUser ? null : Border.all(color: AppColors.border),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: isUser
              ? null
              : [
                  BoxShadow(
                    color: AppColors.blueDark.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.isError) ...[
              const Icon(Icons.error_outline, color: AppColors.error, size: 16),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: SelectableText(
                message.text,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: fg,
                  fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  final bool isSw;

  const _TypingBubble({required this.isSw});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isSw ? 'Kodisha AI inaandika...' : 'Kodisha AI is typing...',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
