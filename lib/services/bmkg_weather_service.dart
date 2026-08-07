import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/bmkg_weather_model.dart';

class BmkgRegionOption {
  final String adm4;
  final String name;
  final String region;

  const BmkgRegionOption({
    required this.adm4,
    required this.name,
    required this.region,
  });
}

class BmkgWeatherService {
  final http.Client _client;

  BmkgWeatherService({http.Client? client}) : _client = client ?? http.Client();

  /// Daftar pilihan wilayah pertanian / daerah BMKG
  static const List<BmkgRegionOption> presetRegions = [
    BmkgRegionOption(
      adm4: '32.73.01.1001',
      name: 'Sukarasa, Sukasari',
      region: 'Kota Bandung, Jabar',
    ),
    BmkgRegionOption(
      adm4: '32.17.07.2001',
      name: 'Lembang',
      region: 'Bandung Barat, Jabar',
    ),
    BmkgRegionOption(
      adm4: '32.01.01.2001',
      name: 'Dramaga',
      region: 'Kab. Bogor, Jabar',
    ),
    BmkgRegionOption(
      adm4: '32.05.01.2001',
      name: 'Tarogong Kaler',
      region: 'Kab. Garut, Jabar',
    ),
    BmkgRegionOption(
      adm4: '33.29.01.2001',
      name: 'Brebes',
      region: 'Kab. Brebes, Jateng',
    ),
    BmkgRegionOption(
      adm4: '34.04.07.2001',
      name: 'Pakem',
      region: 'Sleman, D.I. Yogyakarta',
    ),
    BmkgRegionOption(
      adm4: '35.07.18.2001',
      name: 'Pujon',
      region: 'Kab. Malang, Jatim',
    ),
    BmkgRegionOption(
      adm4: '35.06.01.2001',
      name: 'Pare',
      region: 'Kab. Kediri, Jatim',
    ),
    BmkgRegionOption(
      adm4: '51.02.01.2001',
      name: 'Bedugul / Baturiti',
      region: 'Tabanan, Bali',
    ),
    BmkgRegionOption(
      adm4: '12.71.01.1001',
      name: 'Medan Kota',
      region: 'Kota Medan, Sumut',
    ),
    BmkgRegionOption(
      adm4: '73.71.01.1001',
      name: 'Ujung Pandang',
      region: 'Kota Makassar, Sulsel',
    ),
  ];

  /// Mengambil data cuaca terkini dari API BMKG
  Future<BmkgWeatherModel> fetchWeather({String adm4Code = '32.73.01.1001'}) async {
    final uri = Uri.parse('https://api.bmkg.go.id/publik/prakiraan-cuaca?adm4=$adm4Code');

    try {
      final response = await _client.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return BmkgWeatherModel.fromJson(decoded);
      } else {
        // Fallback jika API HTTP error
        return BmkgWeatherModel.mock(adm4: adm4Code);
      }
    } catch (_) {
      // Fallback jika koneksi gagal atau timeout
      return BmkgWeatherModel.mock(adm4: adm4Code);
    }
  }
}
