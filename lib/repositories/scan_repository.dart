import '../database/database_helper.dart';
import '../models/scan_result_model.dart';
import '../services/api_client.dart';

class ScanRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ApiClient _apiClient = ApiClient();

  /// Get all scan history captured by ESP32-CAM
  Future<List<ScanResultModel>> getScanHistory() async {
    try {
      return await _apiClient.fetchScans();
    } catch (_) {
      return await _dbHelper.getAllScans();
    }
  }

  /// Get the latest scan captured by ESP32-CAM
  Future<ScanResultModel?> getLatestScan() async {
    try {
      return await _apiClient.fetchLatestScan();
    } catch (_) {
      return await _dbHelper.getLatestScan();
    }
  }

  /// Add a new photo analysis result from ESP32-CAM to server (falls back to local DB)
  Future<int> addEspScanResult(ScanResultModel scan) async {
    try {
      return await _apiClient.addScan(scan);
    } catch (_) {
      return await _dbHelper.insertScan(scan);
    }
  }
}
