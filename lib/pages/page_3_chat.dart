import 'package:flutter/material.dart';

class Page3Chat extends StatelessWidget {
  const Page3Chat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF8F6F0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
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
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: AppBar(
          backgroundColor: const Color(0xFF5B3928),
          elevation: 0,
          toolbarHeight: 86,
          titleSpacing: 0,
          leading: const Icon(
            Icons.upload_outlined,
            color: Color(0xFFF2EDE6),
            size: 24,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
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
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.apps, color: Color(0xFFF2EDE6), size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE9E7E4),
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
          SizedBox(width: 8),
          Icon(Icons.send, color: Color(0xFF574B40), size: 18),
        ],
      ),
    );
  }
}
