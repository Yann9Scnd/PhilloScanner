import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/bmkg_weather_model.dart';
import '../services/bmkg_weather_service.dart';
import '../theme/app_theme.dart';

class BmkgWeatherCard extends StatefulWidget {
  const BmkgWeatherCard({super.key});

  @override
  State<BmkgWeatherCard> createState() => _BmkgWeatherCardState();
}

class _BmkgWeatherCardState extends State<BmkgWeatherCard> {
  final BmkgWeatherService _service = BmkgWeatherService();
  bool _isLoading = true;
  BmkgWeatherModel? _weatherData;
  bool _isMock = false;
  String _selectedAdm4 = '32.73.01.1001';
  String _lastUpdated = '';

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoading = true;
    });

    final data = await _service.fetchWeather(adm4Code: _selectedAdm4);
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';

    if (mounted) {
      setState(() {
        _weatherData = data;
        _isMock = data.isMock;
        _isLoading = false;
        _lastUpdated = timeStr;
      });
    }
  }

  IconData _getWeatherIcon(String desc, int code) {
    final lower = desc.toLowerCase();
    if (lower.contains('hujan petir') || lower.contains('badai')) {
      return Icons.thunderstorm_rounded;
    } else if (lower.contains('hujan')) {
      return Icons.water_drop_rounded;
    } else if (lower.contains('berawan')) {
      return Icons.cloud_rounded;
    } else if (lower.contains('cerah berawan')) {
      return Icons.wb_cloudy_rounded;
    } else if (lower.contains('kabut') || lower.contains('embum')) {
      return Icons.cloud_queue_rounded;
    } else {
      return Icons.wb_sunny_rounded;
    }
  }

  Color _getWeatherColor(String desc) {
    final lower = desc.toLowerCase();
    if (lower.contains('hujan')) {
      return const Color(0xFF0288D1);
    } else if (lower.contains('berawan')) {
      return const Color(0xFF455A64);
    } else {
      return const Color(0xFFF57C00);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weather = _weatherData?.currentWeather;
    final location = _weatherData?.location;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF003B58),
            Color(0xFF00537A),
            Color(0xFF035664),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF003B58).withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background subtle pattern circle
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Badge & Refresh Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // BMKG Official Badge
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_sync_rounded,
                              size: 16,
                              color: Color(0xFF8AC9DA),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _isMock ? 'Data Cadangan (Offline)' : 'API BMKG Terhubung',
                                style: AppTextStyles.labelMd(color: Colors.white).copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                  letterSpacing: 0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Refresh Button
                    InkWell(
                      onTap: _isLoading ? null : _loadWeatherData,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.refresh_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Location Picker Row
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFFFFDDB4),
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: const Color(0xFF003B58),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedAdm4,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white70,
                              size: 20,
                            ),
                            isExpanded: true,
                            style: AppTextStyles.titleMd(color: Colors.white),
                            onChanged: (String? newAdm4) {
                              if (newAdm4 != null && newAdm4 != _selectedAdm4) {
                                setState(() {
                                  _selectedAdm4 = newAdm4;
                                });
                                _loadWeatherData();
                              }
                            },
                            items: BmkgWeatherService.presetRegions.map((region) {
                              return DropdownMenuItem<String>(
                                value: region.adm4,
                                child: Text(
                                  '${region.name}, ${region.region}',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (location != null && !_isLoading) ...[
                  Text(
                    '${location.desa}, Kec. ${location.kecamatan}, ${location.kotkab}',
                    style: AppTextStyles.labelMd(color: Colors.white.withValues(alpha: 0.80)),
                  ),
                ],

                const SizedBox(height: 16),

                // Main Weather Display Row (Temp, Icon, Desc)
                if (_isLoading) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ] else if (weather != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Weather Icon Card
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.20),
                          ),
                        ),
                        child: Icon(
                          _getWeatherIcon(weather.weatherDesc, weather.weatherCode),
                          size: 38,
                          color: _getWeatherColor(weather.weatherDesc),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Temperature Display
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text(
                                    '${weather.temp.round()}',
                                    style: GoogleFonts.inter(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.0,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Text(
                                  '°C',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF8AC9DA),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              weather.weatherDesc,
                              style: AppTextStyles.titleMd(color: Colors.white).copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 16),

                  // Weather Metrics Grid (3 columns)
                  Row(
                    children: [
                      Expanded(
                        child: _WeatherMetricItem(
                          icon: Icons.water_drop_outlined,
                          label: 'Kelembapan',
                          value: '${weather.humidity}%',
                        ),
                      ),
                      Expanded(
                        child: _WeatherMetricItem(
                          icon: Icons.air_rounded,
                          label: 'Angin',
                          value: '${weather.windSpeed.toStringAsFixed(1)} km/h',
                        ),
                      ),
                      Expanded(
                        child: _WeatherMetricItem(
                          icon: Icons.explore_outlined,
                          label: 'Arah Angin',
                          value: weather.windDirection,
                        ),
                      ),
                    ],
                  ),

                  if (_lastUpdated.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'Diperbarui: $_lastUpdated',
                        style: AppTextStyles.labelMd(
                          color: Colors.white.withValues(alpha: 0.65),
                        ).copyWith(fontSize: 10),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherMetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherMetricItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF8AC9DA)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.labelMd(
                  color: Colors.white.withValues(alpha: 0.75),
                ).copyWith(fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.labelLg(color: Colors.white).copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
