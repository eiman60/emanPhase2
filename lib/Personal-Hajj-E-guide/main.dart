import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'location_service.dart';
import 'map_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MaterialApp(
    home: HomeScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();

  String currentZone = "جاري تحديد الموقع...";
  String networkStatus = "Checking...";
  String currentInstruction = "يرجى تفعيل الموقع للبدء في استلام الإرشادات.";
  Color zoneColor = Colors.grey;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _startSmartGuidance();
    Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      if (result.isNotEmpty) _updateConnectionStatus(result.first);
    });
  }

  void _checkConnectivity() async {
    var result = await Connectivity().checkConnectivity();
    if (result.isNotEmpty) _updateConnectionStatus(result.first);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      if (result == ConnectivityResult.none) {
        networkStatus = "أنت الآن غير متصل بالإنترنت )";
      } else {
        networkStatus = "متصل بالإنترنت";
      }
    });
  }

  void _startSmartGuidance() async {
    setState(() => _isSyncing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    String zone = await _locationService.checkUserZone();
    _updateUIForZone(zone);
    setState(() => _isSyncing = false);
  }

  void _updateUIForZone(String zone) {
    setState(() {
      currentZone = zone;
      if (zone == "منى") {
        currentInstruction = "أنت الآن في منى: مبيت الحجاج، استعد لرمي الجمرات وذكر الله في أيام التشريق.";
        zoneColor = Colors.green;
      } else if (zone == "عرفات") {
        currentInstruction = "أنت في صعيد عرفات خير الدعاء دعاء يوم عرفة، تفرغ للعبادة حتى غروب الشمس.";
        zoneColor = Colors.orange;
      } else if (zone == "مزدلفة") {
        currentInstruction = " أنت في مزدلفة اجمع الحصى, وأكثر من ذكر الله عند المشعر الحرام ";
        zoneColor = Colors.deepPurple;
      } else if (zone == "الحرم المكي") {
        currentInstruction = "أنت في الحرم المكي استعد لأداء طواف الإفاضة والسعي، تقبل الله طاعتك.";
        zoneColor = Colors.blue;
      } else {
        currentInstruction = "أنت حالياً خارج نطاق المشاعر المقدسة. اتبع المسارات المحددة للوصول لوجهتك.";
        zoneColor = Colors.grey;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("تم تحديث الموقع: $zone"),
        backgroundColor: zoneColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isOffline = networkStatus.contains("غير متصل");

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            floating: false,
            pinned: true,
            backgroundColor: Colors.green[800],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text("دليل الحاج الذكي",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[900]!, Colors.green[700]!],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                //شريط حالة الشبكة 
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  decoration: BoxDecoration(
                    color: isOffline ? Colors.orange[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                        color: isOffline ? Colors.orange[200]! : Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(isOffline ? Icons.cloud_off : Icons.cloud_done,
                          size: 16,
                          color: isOffline ? Colors.orange[800] : Colors.green[800]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(networkStatus,
                            style: TextStyle(
                                color: isOffline ? Colors.orange[900] : Colors.green[900],
                                fontSize: 10,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),

                //  بطاقة الموقع والتعليمات 
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5))
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: zoneColor.withOpacity(0.1),
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: zoneColor),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text("الموقع: $currentZone",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: zoneColor,
                                        overflow: TextOverflow.ellipsis)),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(currentInstruction,
                              style: const TextStyle(
                                  fontSize: 15,
                                  height: 1.6,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                //  الأزرار
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: _isSyncing ? null : _startSmartGuidance,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 55,
                          decoration: BoxDecoration(
                            color: _isSyncing ? Colors.grey[200] : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                                color: Colors.green[800]!, width: 1.5),
                          ),
                          child: Center(
                            child: _isSyncing
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.green))
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.sync,
                                          color: Colors.green[800]),
                                      const SizedBox(width: 10),
                                      const Text("تحديث الموقع ",
                                          style: TextStyle(
                                              color: Color(0xFF2E7D32),
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MapScreen())),
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            gradient: LinearGradient(colors: [
                              Colors.green[700]!,
                              Colors.green[900]!
                            ]),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map, color: Colors.white),
                              SizedBox(width: 10),
                              Text(" الخريطة التفاعلية",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  "Offline Geofencing Active | SQLite Local DB",
                  style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 10,
                      letterSpacing: 1.2),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}