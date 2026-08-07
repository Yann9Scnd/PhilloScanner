import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/disease_model.dart';
import '../models/scan_result_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }
    _database = await _initDB('phylloscanner.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Diseases dataset table
    await db.execute('''
      CREATE TABLE diseases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        scientific_name TEXT NOT NULL,
        category TEXT NOT NULL,
        image_url TEXT NOT NULL,
        description TEXT NOT NULL,
        symptoms TEXT NOT NULL,
        treatment_steps TEXT NOT NULL
      )
    ''');

    // 2. Scan Results table (ESP32 photos & AI diagnosis)
    await db.execute('''
      CREATE TABLE scan_results (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT NOT NULL,
        image_url TEXT NOT NULL,
        disease_name TEXT NOT NULL,
        scientific_name TEXT NOT NULL,
        severity TEXT NOT NULL,
        confidence INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        soil_moisture TEXT NOT NULL,
        ai_recommendations TEXT NOT NULL
      )
    ''');

    // 3. Sensor Readings table
    await db.execute('''
      CREATE TABLE sensor_readings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT NOT NULL,
        soil_moisture TEXT NOT NULL,
        temperature TEXT NOT NULL,
        pump_status TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // Seed initial disease dataset
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    // Seed Dataset Diseases
    final initialDiseases = [
      const DiseaseModel(
        name: 'Bercak Daun (Leaf Spot)',
        scientificName: 'Cercospora capsici',
        category: 'Jamur',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDImDcqK7-2TTfEsSRFVDFrIL3dQC65jCejg5cgzzThGqbPc0YSXIKHK65Bv3w6jaLbb4vCHoWMCu1it6APEayNlB3gCHUyBhrdSpETKR_zOBRDhX55O8SMMDhqzDi2RxH30VpHV7n4_4owIfcONwCDp3rtJrW96aeAUp9p6I5ANQylU_4936R6VO1pIDMY2tjqDjPk1tXDSjMhqIVSkGUc9eeDfuMpN75K-HkO-Tgj3NvEUWr_LbPUVQ',
        description:
            'Bercak daun disebabkan oleh jamur Cercospora capsici. Penyakit ini membuat bercak cokelat keabu-abuan pada daun.',
        symptoms: 'Bercak lingkaran kecil berwarna cokelat tua dengan pusat kelabu.',
        treatmentSteps: [
          'Kurangi kelembapan di sekitar area terdampak.',
          'Buang bagian daun yang rusak parah agar tidak menular.',
          'Berikan pupuk tambahan untuk memperkuat imun tanaman.'
        ],
      ),
      const DiseaseModel(
        name: 'Karat Daun (Rust)',
        scientificName: 'Puccinia sorghi',
        category: 'Jamur',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDImDcqK7-2TTfEsSRFVDFrIL3dQC65jCejg5cgzzThGqbPc0YSXIKHK65Bv3w6jaLbb4vCHoWMCu1it6APEayNlB3gCHUyBhrdSpETKR_zOBRDhX55O8SMMDhqzDi2RxH30VpHV7n4_4owIfcONwCDp3rtJrW96aeAUp9p6I5ANQylU_4936R6VO1pIDMY2tjqDjPk1tXDSjMhqIVSkGUc9eeDfuMpN75K-HkO-Tgj3NvEUWr_LbPUVQ',
        description:
            'Karat daun dicirikan oleh bintik-bintik oranye keemasan seperti karat di permukaan bawah daun.',
        symptoms: 'Pustul berisi spora berwarna serbuk karat cokelat kemerahan.',
        treatmentSteps: [
          'Semprotkan fungisida berbasis tembaga organik.',
          'Jaga sirkulasi udara antar tanaman agar tidak terlalu rapat.',
          'Hindari penyiraman langsung dari atas daun.'
        ],
      ),
      const DiseaseModel(
        name: 'Busuk Akar (Root Rot)',
        scientificName: 'Pythium spp.',
        category: 'Bakteri',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDImDcqK7-2TTfEsSRFVDFrIL3dQC65jCejg5cgzzThGqbPc0YSXIKHK65Bv3w6jaLbb4vCHoWMCu1it6APEayNlB3gCHUyBhrdSpETKR_zOBRDhX55O8SMMDhqzDi2RxH30VpHV7n4_4owIfcONwCDp3rtJrW96aeAUp9p6I5ANQylU_4936R6VO1pIDMY2tjqDjPk1tXDSjMhqIVSkGUc9eeDfuMpN75K-HkO-Tgj3NvEUWr_LbPUVQ',
        description:
            'Busuk akar berkembang akibat media tanam terlalu basah dan serangan bakteri/patogen tanah.',
        symptoms: 'Daun menguning tiba-tiba, layu, dan batang bagian bawah lembek.',
        treatmentSteps: [
          'Atur drainase pot atau media hidroponik.',
          'Hentikan penyiraman sementara hingga media agak kering.',
          'Gunakan agen hayati Trichoderma pada media tanam.'
        ],
      ),
    ];

    for (var disease in initialDiseases) {
      await db.insert('diseases', disease.toMap());
    }

    // Seed Initial ESP32 Scan Results
    final initialScans = [
      const ScanResultModel(
        deviceId: 'ESP32-CAM Sektor B-04',
        imageUrl:
            'https://lh3.googleusercontent.com/aida/AP1WRLsJNUTrlybw3NU7q_uVkGQ2i6ryWi7lAXAGkOSvK_H2Ptj28d2-iZ--leefUeHsmVULchMwRDed-DsFju613H_X7TztLlQM821oZKXYF_4PrWPd8DFjAvWQHWXhrFAGvB5Rrw8anPY1K0deDmtaCTLCD2H1WG9eT53kZBJqRDVh8-u1C4d2vm72Hr24gioVwOVzH9sz-OHjukpoyBkBBiPKQKF9t-eGPhcSyBcjKjHvrcTbgs5jR9GWKMok',
        diseaseName: 'Bercak Daun',
        scientificName: 'Cercospora capsici',
        severity: 'Sedang',
        confidence: 92,
        timestamp: '12 Okt 2023 • 14:30',
        soilMoisture: '58%',
        aiRecommendations: [
          'Kurangi kelembapan di sekitar area terdampak.',
          'Buang bagian daun yang rusak parah agar tidak menular.',
          'Berikan pupuk tambahan untuk memperkuat imun tanaman.'
        ],
      ),
      const ScanResultModel(
        deviceId: 'ESP32-CAM Sektor A-01',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDImDcqK7-2TTfEsSRFVDFrIL3dQC65jCejg5cgzzThGqbPc0YSXIKHK65Bv3w6jaLbb4vCHoWMCu1it6APEayNlB3gCHUyBhrdSpETKR_zOBRDhX55O8SMMDhqzDi2RxH30VpHV7n4_4owIfcONwCDp3rtJrW96aeAUp9p6I5ANQylU_4936R6VO1pIDMY2tjqDjPk1tXDSjMhqIVSkGUc9eeDfuMpN75K-HkO-Tgj3NvEUWr_LbPUVQ',
        diseaseName: 'Karat Daun',
        scientificName: 'Puccinia sorghi',
        severity: 'Rendah',
        confidence: 88,
        timestamp: '12 Okt 2023 • 11:15',
        soilMoisture: '62%',
        aiRecommendations: [
          'Semprotkan fungisida berbasis tembaga organik.',
          'Jaga sirkulasi udara antar tanaman.',
        ],
      ),
    ];

    for (var scan in initialScans) {
      await db.insert('scan_results', scan.toMap());
    }
  }

  Future<int> insertScan(ScanResultModel scan) async {
    final db = await instance.database;
    return await db.insert('scan_results', scan.toMap());
  }

  Future<List<ScanResultModel>> getAllScans() async {
    final db = await instance.database;
    final result = await db.query('scan_results', orderBy: 'id DESC');
    return result.map((json) => ScanResultModel.fromMap(json)).toList();
  }

  Future<ScanResultModel?> getLatestScan() async {
    final db = await instance.database;
    final result = await db.query('scan_results', orderBy: 'id DESC', limit: 1);
    if (result.isNotEmpty) {
      return ScanResultModel.fromMap(result.first);
    }
    return null;
  }

  Future<List<DiseaseModel>> getDiseases({String? category}) async {
    final db = await instance.database;
    List<Map<String, dynamic>> result;
    if (category != null && category != 'Semua') {
      result = await db.query(
        'diseases',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'id ASC',
      );
    } else {
      result = await db.query('diseases', orderBy: 'id ASC');
    }
    return result.map((json) => DiseaseModel.fromMap(json)).toList();
  }
}
