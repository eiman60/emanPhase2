import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'dart:convert';
import 'database_helper.dart';
import 'location_service.dart'; 
import 'package:geolocator/geolocator.dart'; 

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService(); 
  
  List<Polygon> _polygons = [];
  List<Map<String, dynamic>> _zonePolygons = [];
  String _statusMessage = "جاري فحص موقعك في المشاعر...";
  bool _isSatellite = false; 
  String? _selectedZoneFromTap;
  
  final String _streetUrl = 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';
  final String _satelliteUrl = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

  //   الموقع يتغير بناء على الاحداثيات    
  ll.LatLng _userPos = const ll.LatLng(21.4152, 39.8942);

  @override
  void initState() {
    super.initState();
    _initializeLocation(); 
  }

  // دالة لجلب الموقع الحقيقي وتحديث الكاميرا
  void _initializeLocation() async {
    try {
      Position position = await _locationService.getCurrentLocation();
      setState(() {
        _userPos = ll.LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_userPos, 16); 
      _loadMapData(); 
    } catch (e) {
      _loadMapData(); 
    }
  }

  void _loadMapData() async {
    final zones = await DatabaseHelper.instance.getZones();
    List<Polygon> temp = [];
    List<Map<String, dynamic>> zoneData = [];
    String foundZone = "خارج نطاق المشاعر حالياً";
    
    for (var zone in zones) {
      var pointsList = jsonDecode(zone['points']) as List;
      List<ll.LatLng> points = pointsList.map((p) => ll.LatLng(p['lat'], p['lng'])).toList();
      zoneData.add({
        'name': zone['name'],
        'points': points,
      });
      
      bool isInside = _checkIfInside(_userPos, points);
      
      if (isInside) {
        foundZone = "أنت الآن في نطاق: ${zone['name']}";
      }

      temp.add(Polygon(
        points: points,
        color: isInside ? Colors.green.withValues(alpha: 0.3) : Colors.blue.withValues(alpha: 0.1),
        borderStrokeWidth: isInside ? 3 : 1,
        borderColor: isInside ? Colors.green : Colors.blueGrey,
      ));
    }
    setState(() {
      _polygons = temp;
      _zonePolygons = zoneData;
      _statusMessage = foundZone;
    });
  }

  String _zoneNameForPoint(ll.LatLng point) {
    for (final zone in _zonePolygons) {
      final points = zone['points'] as List<ll.LatLng>;
      if (_checkIfInside(point, points)) {
        return zone['name'] as String;
      }
    }
    return "خارج نطاق المشاعر المقدسة";
  }

  bool _checkIfInside(ll.LatLng point, List<ll.LatLng> polygon) {
    var intersections = 0;
    for (var i = 0; i < polygon.length; i++) {
      var j = (i + 1) % polygon.length;
      if (((polygon[i].latitude <= point.latitude && point.latitude < polygon[j].latitude) ||
          (polygon[j].latitude <= point.latitude && point.latitude < polygon[i].latitude)) &&
          (point.longitude < (polygon[j].longitude - polygon[i].longitude) * (point.latitude - polygon[i].latitude) / (polygon[j].latitude - polygon[i].latitude) + 
          polygon[i].longitude)) {
        intersections++;
      }
    }
    return intersections % 2 != 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userPos,
              initialZoom: 16,
              onTap: (_, point) {
                final zone = _zoneNameForPoint(point);
                setState(() {
                  _selectedZoneFromTap = zone;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _isSatellite ? _satelliteUrl : _streetUrl,
                subdomains: const ['a', 'b', 'c', 'd'],
              ),
              PolygonLayer(polygons: _polygons),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _userPos,
                    child: const Icon(Icons.person_pin_circle, color: Colors.red, size: 40),
                  ),
                ],
              ),
            ],
          ),

          Positioned(
            top: 60, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Row(
                children: [
                  const Icon(Icons.explore, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(_statusMessage, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 100, right: 20,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: "sat_btn",
                  backgroundColor: Colors.white,
                  onPressed: () => setState(() => _isSatellite = !_isSatellite),
                  child: Icon(_isSatellite ? Icons.map : Icons.layers, color: Colors.blue),
                ),
                const SizedBox(height: 12),
                FloatingActionButton(
                  heroTag: "loc_btn",
                  backgroundColor: Colors.white,
                  onPressed: () => _initializeLocation(), 
                  child: const Icon(Icons.gps_fixed, color: Colors.blue),
                ),
              ],
            ),
          ),
          
          Positioned(
            bottom: 30, left: 20,
            child: FloatingActionButton.extended(
              backgroundColor: Colors.white,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: Colors.blue),
              label: const Text("رجوع", style: TextStyle(color: Colors.blue)),
            ),
          ),

          if (_selectedZoneFromTap != null)
            Positioned(
              left: 20,
              right: 20,
              bottom: 95,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "الموقع المختار: $_selectedZoneFromTap",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        LocationService.setManualZoneOverride(_selectedZoneFromTap!);
                        Navigator.pop(context, _selectedZoneFromTap);
                      },
                      child: const Text("اعتماد كموقع حالي"),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
