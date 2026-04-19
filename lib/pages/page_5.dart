import 'package:flutter/material.dart';

import '../data/emergency_report_store.dart';

class Page5 extends StatelessWidget {
  const Page5({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F6F0),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: const Padding(
                padding: EdgeInsets.only(left: 14),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFF3B33B),
                  child: Icon(Icons.person_outline, size: 25, color: Colors.white),
                ),
              ),
              actions: const [
                Icon(Icons.wallet_outlined, size: 25, color: Color(0xFF171717)),
                SizedBox(width: 8),
                Icon(Icons.notifications_outlined, size: 25, color: Color(0xFF171717)),
                SizedBox(width: 8),
                Icon(Icons.more_vert, size: 25, color: Color(0xFF171717)),
                SizedBox(width: 15),
              ],
              centerTitle: true,
              title: const Text(
                'استكشاف',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF171717),
                ),
              ),
            ),
          ),
        ),
        body: ValueListenableBuilder<List<EmergencyReport>>(
          valueListenable: EmergencyReportStore.reports,
          builder: (context, reports, _) {
            if (reports.isEmpty) {
              return const Center(
                child: Text(
                  'لا يوجد بلاغات حالياً',
                  style: TextStyle(fontFamily: 'Amiri', fontSize: 24, color: Color(0xFF6B7280)),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) => _ReportCard(report: reports[index]),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: reports.length,
            );
          },
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});

  final EmergencyReport report;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: report.taken ? const Color(0xFF16A34A) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  report.typeLabel,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontFamily: 'Amiri', fontSize: 21, fontWeight: FontWeight.w700),
                ),
              ),
              Icon(
                report.taken ? Icons.assignment_turned_in : Icons.notifications_active_outlined,
                color: report.taken ? const Color(0xFF16A34A) : const Color(0xFFEB4548),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            report.locationLabel,
            textAlign: TextAlign.right,
            style: const TextStyle(fontFamily: 'Amiri', color: Color(0xFF4B5563)),
          ),
          const SizedBox(height: 4),
          Text(
            '(${report.latitude.toStringAsFixed(5)}, ${report.longitude.toStringAsFixed(5)})',
            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                '${report.createdAt.hour.toString().padLeft(2, '0')}:${report.createdAt.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(color: Color(0xFF9CA3AF)),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => EmergencyReportStore.toggleTaken(report.id),
                style: FilledButton.styleFrom(
                  backgroundColor: report.taken ? const Color(0xFF6B7280) : const Color(0xFFEB4548),
                ),
                child: Text(
                  report.taken ? 'إلغاء الاستلام' : 'استلام البلاغ',
                  style: const TextStyle(fontFamily: 'Amiri'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
