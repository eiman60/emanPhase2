import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../Personal-Hajj-E-guide/location_service.dart';
import '../data/emergency_report_store.dart';

class EmergencyReportPage extends StatefulWidget {
  const EmergencyReportPage({super.key});

  @override
  State<EmergencyReportPage> createState() => _EmergencyReportPageState();
}

class _EmergencyReportPageState extends State<EmergencyReportPage> {
  final LocationService _locationService = LocationService();
  final TextEditingController _locationController = TextEditingController();

  ll.LatLng? _userLocation;
  String _selectedType = 'medical';
  bool _isLoadingLocation = true;

  static const Map<String, ({IconData icon, String title, String subtitle})>
      _reportTypes = {
    'medical': (
      icon: Icons.local_hospital_outlined,
      title: 'حالة صحية',
      subtitle: 'الإبلاغ عن حالة طبية تحتاج إلى تدخل فوري',
    ),
    'accident': (
      icon: Icons.report_problem_outlined,
      title: 'حادث أو ازدحام',
      subtitle: 'الإبلاغ عن حادث أو منطقة ازدحام خطرة',
    ),
    'location_help': (
      icon: Icons.location_on_outlined,
      title: 'مساعدة في الموقع',
      subtitle: 'طلب مساعدة عاجلة في موقعك الحالي',
    ),
  };

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final position = await _locationService.getCurrentLocation();
      final zone = await _locationService.checkUserZone();
      final current = ll.LatLng(position.latitude, position.longitude);
      _locationController.text = '$zone (${current.latitude.toStringAsFixed(6)}, ${current.longitude.toStringAsFixed(6)})';

      if (mounted) {
        setState(() {
          _userLocation = current;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر تحديد الموقع تلقائياً، تأكد من تفعيل GPS.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  void _submitReport() {
    if (_userLocation == null || _locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى التأكد من تحديد الموقع أولاً.')),
      );
      return;
    }

    final selected = _reportTypes[_selectedType]!;
    EmergencyReportStore.add(
      EmergencyReport(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: _selectedType,
        typeLabel: selected.title,
        locationLabel: _locationController.text.trim(),
        latitude: _userLocation!.latitude,
        longitude: _userLocation!.longitude,
        createdAt: DateTime.now(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إرسال البلاغ بنجاح.')),
    );
    Navigator.of(context).pop();
  }

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
            _buildMapPreview(),
            const SizedBox(height: 10),
            TextField(
              controller: _locationController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'سيتم تعبئة الموقع تلقائياً',
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
            ..._reportTypes.entries.map((entry) {
              final value = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _EmergencyReportOption(
                  icon: value.icon,
                  title: value.title,
                  subtitle: value.subtitle,
                  selected: _selectedType == entry.key,
                  onTap: () => setState(() => _selectedType = entry.key),
                ),
              );
            }),
            const Spacer(),
            FilledButton(
              onPressed: _submitReport,
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

  Widget _buildMapPreview() {
    if (_isLoadingLocation) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_userLocation == null) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Center(
          child: TextButton.icon(
            onPressed: _loadCurrentLocation,
            icon: const Icon(Icons.my_location),
            label: const Text('إعادة تحديد موقعي'),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 160,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: _userLocation!,
            initialZoom: 16,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _userLocation!,
                  width: 42,
                  height: 42,
                  child: const Icon(Icons.location_pin, color: Color(0xFFEB4548), size: 42),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: FilledButton.tonalIcon(
                  onPressed: _loadCurrentLocation,
                  icon: const Icon(Icons.gps_fixed),
                  label: const Text('تحديث'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _EmergencyReportOption extends StatelessWidget {
  const _EmergencyReportOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFFEB4548) : const Color(0xFFE5E7EB),
            width: selected ? 1.5 : 1,
          ),
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
            if (selected)
              const Icon(Icons.check_circle, color: Color(0xFFEB4548)),
          ],
        ),
      ),
    );
  }
}
