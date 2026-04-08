import 'package:geolocator/geolocator.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;
import 'dart:convert';
import 'database_helper.dart';

class LocationService {

  // دالة مساعدة لإنشاء موقع افتراضي في مشعر منى للاختبار (مظللة حالياً)
  /*
  Position _getMockMinaPosition() {
    return Position(
      latitude: 21.4152, // إحداثيات منى التي زودتني بها
      longitude: 39.8942,
      timestamp: DateTime.now(),
      accuracy: 5.0, // GPS in
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );
  }
  */

  Future<Position> getCurrentLocation() async {
    //  تفعيل الكود  لطلب GPS 
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('Permissions denied.');
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    /* وضع الاختبار (مظلل الآن):
    return _getMockMinaPosition();
    */
  }

  Future<String> checkUserZone() async {
    try {
      // الموقع الفعلي الان 
      Position position = await getCurrentLocation();
      
      final zones = await DatabaseHelper.instance.getZones();

      for (var zone in zones) {
        var pointsList = jsonDecode(zone['points']) as List;
        List<mp.LatLng> polygon = pointsList.map((p) =>
          mp.LatLng(p['lat'], p['lng'])
        ).toList();

        bool isInside = mp.PolygonUtil.containsLocation(
          mp.LatLng(position.latitude, position.longitude),
          polygon,
          false,
        );

        if (isInside) {
          return zone['name'];
        }
      }
      return "خارج نطاق المشاعر المقدسة";
    } catch (e) {
      return "خطأ في تحديد المنطقة: $e";
    }
  }

  Future<Map<String, String>> getEmergencyData() async {
    try {
      // سيستخدم الموقع الفعلي في حالة الطوارئ
      Position position = await getCurrentLocation();

      return {
        "lat": position.latitude.toStringAsFixed(6),
        "lng": position.longitude.toStringAsFixed(6),
        "quality": "عالية (Real-time GPS)",
        "time": DateTime.now().toString().substring(11, 19),
      };
    } catch (e) {
      return {
        "lat": "0.000000",
        "lng": "0.000000",
        "quality": "خطأ في تحديد الموقع",
        "time": DateTime.now().toString().substring(11, 19),
      };
    }
  }
}