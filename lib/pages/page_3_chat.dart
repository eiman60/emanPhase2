import 'package:flutter/material.dart';

class Page3Chat extends StatefulWidget {
  const Page3Chat({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<Page3Chat> createState() => _Page3ChatState();
}

class _Page3ChatState extends State<Page3Chat> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final value = _controller.text.trim();
    if (value.isEmpty) {
      return;
    }

    setState(() {
      _messages.add(
        _ChatMessage(
          text: value,
          time: _timeLabel(DateTime.now()),
          isOutgoing: true,
        ),
      );
      _controller.clear();
    });
  }

  String _timeLabel(DateTime time) {
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF1F0EC),
      child: Column(
        children: [
          _ChatHeader(onBack: widget.onBack),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _messages.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.separated(
                      padding: const EdgeInsets.only(top: 16, bottom: 16),
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return _MessageBubble(message: message);
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemCount: _messages.length,
                    ),
            ),
          ),
          _ChatComposer(
            controller: _controller,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.time,
    required this.isOutgoing,
  });

  final String text;
  final String time;
  final bool isOutgoing;
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      width: double.infinity,
      color: const Color(0xFFFFFFFF),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Color(0xFF6B5B48), size: 24),
          ),
          const SizedBox(width: 2),
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFF9EFC4),
            child: Icon(Icons.auto_awesome, color: Color(0xFFF2B806), size: 24),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nusuk AI',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                ),
                Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: Color(0xFF1D4ED8)),
                    SizedBox(width: 4),
                    Text(
                      'Online',
                      style: TextStyle(fontSize: 11, color: Color(0xFF1D4ED8), fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: Color(0xFF5A4A35), size: 24),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 292,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        decoration: BoxDecoration(
          color: message.isOutgoing ? const Color(0xFF846548) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(message.isOutgoing ? 20 : 16),
          border: message.isOutgoing ? null : Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                fontSize: 16.5,
                color: message.isOutgoing ? Colors.white : const Color(0xFF253043),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                message.time,
                style: TextStyle(
                  fontSize: 10,
                  color: message.isOutgoing ? const Color(0xFFD9DCE2) : const Color(0xFF838A96),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatComposer extends StatelessWidget {
  const _ChatComposer({
    required this.controller,
    required this.onSend,
  });

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        border: Border(top: BorderSide(color: Color(0xFFE4E2DD))),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(color: Color(0xFFE7E2D7), shape: BoxShape.circle),
            child: const Icon(Icons.add, color: Color(0xFF5D4B39), size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1EFE8),
                borderRadius: BorderRadius.circular(19),
              ),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Color(0xFF5C4D40), fontSize: 16),
                  isCollapsed: true,
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: Color(0xFFF9C216), shape: BoxShape.circle),
              child: const Icon(Icons.send_outlined, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
