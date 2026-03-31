import 'package:flutter/material.dart';

class Page3Chat extends StatefulWidget {
  const Page3Chat({super.key});

  @override
  State<Page3Chat> createState() => _Page3ChatState();
}

class _Page3ChatState extends State<Page3Chat> {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF3F2EF),
      child: Column(
        children: [
          const _ChatTopBar(),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F2EF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                children: [
                  const _DatePill(label: 'Today, 10:24 AM'),
                  const SizedBox(height: 14),
                  const _IncomingBubble(
                    text:
                        'Assalamu alaikum, Ahmed! 🌙\n\nI am your Nusuk AI assistant. How can I help you plan your spiritual journey today?',
                    time: '10:24 AM',
                  ),
                  const SizedBox(height: 10),
                  const _OutgoingBubble(
                    text: 'What are the requirements to perform Umrah this season?',
                    time: '10:26 AM',
                  ),
                  const SizedBox(height: 10),
                  const _IncomingBubble(
                    text:
                        'For this season, you will need an active Umrah permit which you can easily issue directly through this app.\n\nPlease also ensure your visa is valid. Would you like me to guide you to the permit issuance page?',
                    time: '10:27 AM',
                  ),
                ],
              ),
            ),
          ),
          const _ComposerBar(),
          const SizedBox(height: 10),
          const _ChatToolsRow(),
          const SizedBox(height: 92),
        ],
      ),
    );
  }
}

class _ChatTopBar extends StatelessWidget {
  const _ChatTopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 40, 18, 14),
      decoration: const BoxDecoration(
        color: Color(0xFF5B3928),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Nusuk AI ✨',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.circle, size: 9, color: Color(0xFF34C759)),
                    SizedBox(width: 4),
                    Text(
                      'Online',
                      style: TextStyle(
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
          const Icon(Icons.more_vert, color: Color(0xFFF2EDE6), size: 22),
        ],
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE8E7E4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF8A8A88),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _IncomingBubble extends StatelessWidget {
  const _IncomingBubble({required this.text, required this.time});

  final String text;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(color: Color(0xFFF6EBC6), shape: BoxShape.circle),
          child: const Icon(Icons.auto_awesome_outlined, color: Color(0xFF8E6E53), size: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF2E2A28),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    time,
                    style: const TextStyle(fontSize: 11, color: Color(0xFFA09A93)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OutgoingBubble extends StatelessWidget {
  const _OutgoingBubble({required this.text, required this.time});

  final String text;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        decoration: BoxDecoration(
          color: const Color(0xFF4A3028),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.4),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                time,
                style: const TextStyle(fontSize: 11, color: Color(0xFFE8D9D0)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposerBar extends StatelessWidget {
  const _ComposerBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEEEC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_file, color: Color(0xFF746C64), size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Ask and plan your journey...',
              style: TextStyle(color: Color(0xFF827B74), fontSize: 15),
            ),
          ),
          const Icon(Icons.mic_none, color: Color(0xFF746C64), size: 20),
          const SizedBox(width: 8),
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(color: Color(0xFFD1AA22), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}

class _ChatToolsRow extends StatelessWidget {
  const _ChatToolsRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F5F3),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ToolIcon(
            icon: Icons.auto_awesome_outlined,
            highlighted: true,
          ),
          _ToolIcon(icon: Icons.calendar_today_outlined),
          _ToolIcon(icon: Icons.crop_original_outlined),
          _ToolIcon(icon: Icons.tune),
          _ToolIcon(icon: Icons.hexagon_outlined, highlighted: true),
        ],
      ),
    );
  }
}

class _ToolIcon extends StatelessWidget {
  const _ToolIcon({required this.icon, this.highlighted = false});

  final IconData icon;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: highlighted ? const Color(0xFFF3DE9A) : Colors.transparent,
        border: highlighted ? null : Border.all(color: const Color(0xFFD6D3CF)),
      ),
      child: Icon(icon, size: 18, color: const Color(0xFF574B40)),
    );
  }
}
