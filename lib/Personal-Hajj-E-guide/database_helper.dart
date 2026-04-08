import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hajj_smart_guide.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE zones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        points TEXT NOT NULL,
        instruction TEXT NOT NULL
      )
    ''');
    await _insertInitialData(db);
  }

  Future _insertInitialData(Database db) async {
    final List<Map<String, dynamic>> hajjZones = [
      {
        'name': 'الحرم المكي',
        'instruction':
            'أهلاً بك في الحرم المكي استعد لأداء الطواف والسعي، تقبل الله طاعتك.',
        'points': jsonEncode([
          {'lat': 21.4280, 'lng': 39.8265},
          {'lat': 21.4280, 'lng': 39.8295},
          {'lat': 21.4255, 'lng': 39.8295},
          {'lat': 21.4255, 'lng': 39.8265},
        ])
      },
      {
        'name': 'منى',
        'instruction':
            'أنت الآن في منى مبيت الحجاج هنا سنة مؤكدة، أكثر من التكبير وذكر الله.',
        'points': jsonEncode([
          {'lat': 21.4165, 'lng': 39.8925},
          {'lat': 21.4165, 'lng': 39.8960},
          {'lat': 21.4135, 'lng': 39.8960},
          {'lat': 21.4135, 'lng': 39.8925},
        ])
      },
      {
        'name': 'عرفات',
        'instruction':
            'أنت في صعيد عرفات الطاهر خير الدعاء دعاء يوم عرفة، تفرغ للعبادة حتى الغروب.',
        'points': jsonEncode([
          {'lat': 21.3505, 'lng': 39.9840},
          {'lat': 21.3505, 'lng': 39.9875},
          {'lat': 21.3475, 'lng': 39.9875},
          {'lat': 21.3475, 'lng': 39.9840},
        ])
      },
      {
        'name': 'مزدلفة',
        'instruction':
            'أنت في مزدلفة اجمع الحصى وصلِّ المغرب والعشاء جمعاً وقصراً وبت هنا الليلة.',
        'points': jsonEncode([
          {'lat': 21.3895, 'lng': 39.9115},
          {'lat': 21.3895, 'lng': 39.9150},
          {'lat': 21.3865, 'lng': 39.9150},
          {'lat': 21.3865, 'lng': 39.9115},
        ])
      }
    ];

    for (var zone in hajjZones) {
      await db.insert('zones', zone);
    }
  }

  Future<List<Map<String, dynamic>>> getZones() async {
    final db = await instance.database;
    return await db.query('zones');
  }
}
