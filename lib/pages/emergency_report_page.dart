import 'package:flutter/material.dart';

class EmergencyReportPage extends StatelessWidget {
  const EmergencyReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F0),
      appBar: AppBar(
        title: const Text(
          'الإبلاغ عن طارئ',
          style: TextStyle(fontFamily: 'Amiri', fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'الموقع',
              textAlign: TextAlign.right,
              style: TextStyle(fontFamily: 'Amiri', fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, color: Color(0xFFEB4548), size: 34),
                    SizedBox(height: 8),
                    Text('مكان الخريطة / تحديد الموقع', style: TextStyle(fontFamily: 'Amiri', fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'أدخل الموقع أو اسم المكان',
                hintStyle: const TextStyle(fontFamily: 'Amiri'),
                prefixIcon: const Icon(Icons.location_on_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'اختر نوع البلاغ الطارئ',
              textAlign: TextAlign.right,
              style: TextStyle(fontFamily: 'Amiri', fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _EmergencyReportOption(
              icon: Icons.local_hospital_outlined,
              title: 'حالة صحية',
              subtitle: 'الإبلاغ عن حالة طبية تحتاج إلى تدخل فوري',
            ),
            const SizedBox(height: 12),
            _EmergencyReportOption(
              icon: Icons.report_problem_outlined,
              title: 'حادث أو ازدحام',
              subtitle: 'الإبلاغ عن حادث أو منطقة ازدحام خطرة',
            ),
            const SizedBox(height: 12),
            _EmergencyReportOption(
              icon: Icons.location_on_outlined,
              title: 'مساعدة في الموقع',
              subtitle: 'طلب مساعدة عاجلة في موقعك الحالي',
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: const Color(0xFFEB4548),
              ),
              child: const Text('إرسال البلاغ', style: TextStyle(fontFamily: 'Amiri', fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmergencyReportOption extends StatelessWidget {
  const _EmergencyReportOption({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFEB4548), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontFamily: 'Amiri', fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Color(0xFF6B7280), fontFamily: 'Amiri', fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
