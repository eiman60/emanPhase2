import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Page3Chat extends StatefulWidget {
  const Page3Chat({super.key});

  @override
  State<Page3Chat> createState() => _Page3ChatState();
}

class _Page3ChatState extends State<Page3Chat> {
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
          'مرحباً 👋 أنا مساعد الحج الذكي. اسألني عن خطوات الحج، المناسك، أو أي استفسار يتعلق برحلتك.',
      isUser: false,
    ),
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isSending = false;
  bool _isCheckingHealth = false;
  bool _isBackendReachable = false;

  static const String _configuredApiBaseUrl = String.fromEnvironment(
    'AI_API_BASE_URL',
    defaultValue: '',
  );

  String get _apiBaseUrl => _apiBaseUrlCandidates.first;

  List<String> get _apiBaseUrlCandidates {
    final configured = _configuredApiBaseUrl.trim();
    if (configured.isNotEmpty) return [configured];

    if (kIsWeb) {
      final origin = Uri.base.origin;
      final host = Uri.base.host;
      if (host == 'localhost' || host == '127.0.0.1') {
        return ['http://localhost:8000', origin];
      }
      return [origin, 'http://localhost:8000'];
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return ['http://10.0.2.2:8000'];
      default:
        return ['http://localhost:8000'];
    }
  }

  @override
  void initState() {
    super.initState();
    _checkBackendHealth();
  }

  Future<void> _checkBackendHealth() async {
    if (_isCheckingHealth) return;
    setState(() => _isCheckingHealth = true);

    var reachable = false;
    for (final baseUrl in _apiBaseUrlCandidates) {
      try {
        final response = await http.get(Uri.parse('$baseUrl/health'));
        if (response.statusCode == 200) {
          reachable = true;
          break;
        }
      } catch (_) {
        continue;
      }
    }

    if (!mounted) return;
    setState(() {
      _isBackendReachable = reachable;
      _isCheckingHealth = false;
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isSending = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      http.Response? response;
      http.Response? lastResponse;
      String? lastTriedBaseUrl;

      for (final baseUrl in _apiBaseUrlCandidates) {
        lastTriedBaseUrl = baseUrl;
        try {
          final currentResponse = await http.post(
            Uri.parse('$baseUrl/ask'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'question': text}),
          );

          if (currentResponse.statusCode == 200) {
            response = currentResponse;
            break;
          }

          lastResponse = currentResponse;
        } catch (_) {
          continue;
        }
      }

      if (!mounted) return;

      response ??= lastResponse;

      if (response == null) {
        throw Exception('AI backend is unreachable');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final answer = (data['answer'] as String?)?.trim();
        final phase = (data['phase'] as String?)?.trim();

        setState(() {
          _messages.add(
            _ChatMessage(
              text: answer?.isNotEmpty == true
                  ? answer!
                  : 'تم استلام الرد لكن بدون محتوى واضح.',
              isUser: false,
              subtitle: phase?.isNotEmpty == true ? 'المرحلة: $phase' : null,
            ),
          );
        });
      } else {
        setState(() {
          _messages.add(
            _ChatMessage(
              text:
                  'تعذر الاتصال بخدمة الذكاء الاصطناعي (HTTP ${response!.statusCode}). '
                  'تأكد من تشغيل الخادم على ${lastTriedBaseUrl ?? _apiBaseUrl}.',
              isUser: false,
              isError: true,
            ),
          );
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            text:
                'تعذر الوصول إلى خدمة AI. تم تجربة: ${_apiBaseUrlCandidates.join(' ثم ')}. '
                'يمكنك تمرير المتغير AI_API_BASE_URL عبر --dart-define أو تشغيل الخادم محلياً.',
            isUser: false,
            isError: true,
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          if (!_isBackendReachable && !_isCheckingHealth)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2E6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF2C39B)),
              ),
              child: const Text(
                'خدمة AI غير متصلة حالياً. تأكد من تشغيل خادم FastAPI على المنفذ 8000 '
                'واضبط AI_API_BASE_URL إذا كان الخادم على جهاز آخر.',
                style: TextStyle(color: Color(0xFF7A3E00), fontSize: 12.5),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _ChatBubble(message: _messages[index]);
              },
            ),
          ),
          if (_isSending)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          _buildComposer(),
          const SizedBox(height: 88),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(86),
      child: AppBar(
        backgroundColor: const Color(0xFF5B3928),
        elevation: 0,
        toolbarHeight: 86,
        titleSpacing: 0,
        leading: const Icon(
          Icons.auto_awesome,
          color: Color(0xFFF2EDE6),
          size: 24,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'مساعدك الشخصي',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 9,
                  color: _isCheckingHealth
                      ? const Color(0xFFFFD166)
                      : _isBackendReachable
                      ? const Color(0xFF34C759)
                      : const Color(0xFFFF6B6B),
                ),
                const SizedBox(width: 4),
                Text(
                  _isCheckingHealth
                      ? 'Checking AI...'
                      : _isBackendReachable
                      ? 'AI Connected'
                      : 'AI Offline',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFF0EDE7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE9E7E4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'اسأل عن مناسك الحج...',
              ),
            ),
          ),
          IconButton(
            onPressed: _isSending
                ? null
                : () async {
                    if (!_isBackendReachable) {
                      await _checkBackendHealth();
                    }
                    _sendMessage();
                  },
            icon: const Icon(Icons.send, color: Color(0xFF574B40), size: 20),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final align =
        message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = message.isUser
        ? const Color(0xFF5B3928)
        : message.isError
            ? const Color(0xFFFFF1F1)
            : Colors.white;
    final textColor =
        message.isUser ? Colors.white : (message.isError ? Colors.red : Colors.black87);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: align,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(14),
                border: message.isError
                    ? Border.all(color: const Color(0xFFFFCACA))
                    : null,
              ),
              child: Text(
                message.text,
                style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
              ),
            ),
          ),
          if ((message.subtitle ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 4, left: 4),
              child: Text(
                message.subtitle!,
                style: const TextStyle(color: Colors.black54, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.subtitle,
    this.isError = false,
  });

  final String text;
  final bool isUser;
  final String? subtitle;
  final bool isError;
}
