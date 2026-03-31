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
              child: const SizedBox.shrink(),
            ),
          ),
          const _ComposerBar(),
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
