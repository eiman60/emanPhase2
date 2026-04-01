import 'package:flutter/material.dart';

class Page3Chat extends StatelessWidget {
  const Page3Chat({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F2EF),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F2EF),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
            ),
          ),
          _buildComposer(),
          const SizedBox(height: 92),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Nusuk AI',
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

  Widget _buildComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEEEC),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'Ask and plan your journey...',
              style: TextStyle(color: Color(0xFF827B74), fontSize: 15),
            ),
          ),
          Icon(Icons.mic_none, color: Color(0xFF746C64), size: 20),
        ],
      ),
    );
  }
}
