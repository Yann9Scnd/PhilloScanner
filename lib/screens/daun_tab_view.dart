import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/chat_message_model.dart';
import '../models/scan_result_model.dart';
import '../theme/app_theme.dart';

/// Tab Daun — 2 Sub-mode:
///  1) Scan & Diagnosa AI
///  2) Tanya AI (chat assistant)
class DaunTabView extends StatefulWidget {
  final void Function(ScanResultModel)? onSaveToHistory;
  final VoidCallback? onOpenCamera;

  const DaunTabView({super.key, this.onSaveToHistory, this.onOpenCamera});

  @override
  State<DaunTabView> createState() => _DaunTabViewState();
}

class _DaunTabViewState extends State<DaunTabView> {
  // ===== Sub-mode =====
  int _activeSubMode = 0; // 0 = scanner, 1 = ai_chat

  // ===== Scanner state =====
  bool _isScanning = false;
  ScanResultModel? _scanResult;

  // ===== AI Chat state =====
  final List<ChatMessageModel> _messages = [
    const ChatMessageModel(
      id: 'm1',
      sender: 'ai',
      text:
          'Halo! Saya AI PhylloScanner. Silakan tanyakan hal terkait penyakit tanaman, dosis obat, atau cara penanganan hama pertanian Anda.',
      timestamp: '14:31 WIB',
    ),
  ];
  final TextEditingController _chatController = TextEditingController();
  bool _isChatLoading = false;
  final ScrollController _chatScrollController = ScrollController();

  // Sampel daun dari dataset (padanan `sampleLeaves` React)
  static const _samples = [
    _SampleLeaf(
      id: 'sample-cabai-1',
      title: 'Bercak Daun Cercospora (Terdeteksi)',
      diseaseName: 'Bercak Daun Cabai',
      latinName: 'Cercospora capsici',
      confidence: 94,
      severity: 'Sedang',
      image:
          'https://images.unsplash.com/photo-1592417817098-8f3d6eb231fc?q=80&w=800&auto=format&fit=crop',
      recommendations: [
        'Pangkas daun cabai yang berbercak parah agar spora jamur tidak tertiup angin.',
        'Aplikasi fungisida tembaga hidroksida organik pada pagi hari.',
        'Jaga kelembapan tanah di kisaran 60-70% via irigasi otomatis.',
      ],
    ),
    _SampleLeaf(
      id: 'sample-cabai-2',
      title: 'Daun Cabai Sehat Optimal',
      diseaseName: 'Daun Cabai Sehat',
      latinName: 'Capsicum annuum (Sehat)',
      confidence: 98,
      severity: 'Sehat',
      image:
          'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?q=80&w=800&auto=format&fit=crop',
      recommendations: [
        'Pertahankan sistem irigasi otomatis dari Node 2 ESP32.',
        'Berikan nutrisi Kalsium & Kalium rutin untuk memperkuat dinding sel daun.',
        'Monitor terus visual daun lewat Node 1 ESP32-CAM.',
      ],
    ),
    _SampleLeaf(
      id: 'sample-cabai-3',
      title: 'Virus Kuning Geminivirus',
      diseaseName: 'Virus Kuning / Bule',
      latinName: 'Pepper Yellow Leaf Curl Virus',
      confidence: 91,
      severity: 'Tinggi',
      image:
          'https://images.unsplash.com/photo-1530836369250-ef72a3f5cda8?q=80&w=800&auto=format&fit=crop',
      recommendations: [
        'Pasang perangkap kuning perekat untuk membasmi kaper putih (Bemisia tabaci).',
        'Pangkas pucuk cabai yang melengkung memangkuk ke atas.',
        'Semprot insektisida nabati minyak mimba/serai.',
      ],
    ),
  ];

  @override
  void dispose() {
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ===== Scanner: proses scan sampel / upload foto =====
  Future<void> _runScan(
    String imageUrl, {
    String diseaseName = 'Bercak Daun Cercospora',
    String latinName = 'Cercospora capsici',
    int confidence = 91,
    String severity = 'Sedang',
    List<String> recommendations = const [
      'Semprotkan fungisida tembaga hidroksida organik pada pagi hari.',
      'Pangkas daun yang terinfeksi bercak untuk mencegah penyebaran spora.',
      'Nyalakan Kipas Ventilasi untuk menurunkan kelembapan udara.',
    ],
    String deviceSource = 'Kamera Smartphone',
    String sector = 'Upload Foto Galeri',
  }) async {
    setState(() => _isScanning = true);

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    setState(() {
      _scanResult = ScanResultModel(
        deviceId: deviceSource,
        imageUrl: imageUrl,
        diseaseName: diseaseName,
        scientificName: latinName,
        severity: severity,
        confidence: confidence,
        timestamp: 'Baru saja',
        soilMoisture: '60%',
        sector: sector,
        temperatureAtScan: 28,
        aiRecommendations: recommendations,
      );
      _isScanning = false;
      _activeSubMode = 0;
    });
    _showToast('Hasil Scan Diperbarui: $diseaseName');
  }

  Future<void> _pickAndScanImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      final base64Str = base64Encode(bytes);
      final dataUrl = 'data:image/jpeg;base64,$base64Str';
      await _runScan(dataUrl, deviceSource: 'Kamera Smartphone', sector: 'Upload Foto Galeri');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka galeri. Gunakan sampel daun di bawah ini.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ===== AI Chat: reply keyword lokal (padanan DaunView React) =====
  Future<void> _sendChatMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _isChatLoading) return;

    setState(() {
      _messages.add(ChatMessageModel(
        id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
        sender: 'user',
        text: text,
        timestamp: 'Baru saja',
      ));
      _chatController.clear();
      _isChatLoading = true;
    });
    _scrollChatToBottom();

    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;
    final q = text.toLowerCase();
    String replyText =
        'Terima kasih atas pertanyaannya. Untuk masalah tersebut, pastikan sirkulasi udara di greenhouse terjaga baik dan dosis pupuk seimbang.';
    if (q.contains('jamur') || q.contains('fungisida') || q.contains('bercak')) {
      replyText =
          'Untuk mengatasi infeksi jamur seperti Cercospora, gunakan bio-fungisida Trichoderma sp. atau larutan minyak mimba (Neem Oil) dosis 5ml/liter air. Semprotkan di pagi hari.';
    } else if (q.contains('pupuk') || q.contains('nutrisi')) {
      replyText =
          'Pastikan kadar PPM nutrisi berada di angka 1000 - 1200 PPM dengan pH media tanah 6.0 - 6.5 agar serapan hara optimal.';
    } else if (q.contains('kamera') || q.contains('esp32')) {
      replyText =
          'Anda dapat memantau daun secara langsung dan menggerakkan sudut lensa kamera dari menu Kamera ESP32.';
    }

    setState(() {
      _messages.add(ChatMessageModel(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        sender: 'ai',
        text: replyText,
        timestamp: 'Baru saja',
      ));
      _isChatLoading = false;
    });
    _scrollChatToBottom();
  }

  void _scrollChatToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Mode Tabs
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _ModeTab(
                  icon: Icons.auto_awesome_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  label: 'Scan & Diagnosa AI',
                  isActive: _activeSubMode == 0,
                  onTap: () => setState(() => _activeSubMode = 0),
                ),
                _ModeTab(
                  icon: Icons.smart_toy_outlined,
                  label: 'Tanya AI',
                  isActive: _activeSubMode == 1,
                  onTap: () => setState(() => _activeSubMode = 1),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _activeSubMode,
            children: [
              _buildScannerMode(context),
              _buildAiChatMode(context),
            ],
          ),
        ),
      ],
    );
  }

  // ================= MODE 1: SCAN & DIAGNOSA AI =================
  Widget _buildScannerMode(BuildContext context) {
    final scan = _scanResult;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sample Switcher & Upload
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.photo_camera_outlined,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('Pilih Sampel / Upload Foto Baru',
                          style: AppTextStyles.labelLg(color: AppColors.onSurface)
                              .copyWith(fontWeight: FontWeight.w700)),
                    ),
                    if (widget.onOpenCamera != null)
                      GestureDetector(
                        onTap: widget.onOpenCamera,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1C),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.videocam_rounded,
                                  size: 14, color: Color(0xFF34D399)),
                              SizedBox(width: 4),
                              Text('Live ESP32',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _isScanning ? null : _pickAndScanImage,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.upload_rounded, size: 14, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text('Upload',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Sample thumbnails
                Row(
                  children: _samples.map((sample) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: sample != _samples.last ? 8 : 0),
                        child: GestureDetector(
                          onTap: () async {
                            await _runScan(
                              sample.image,
                              diseaseName: sample.diseaseName,
                              latinName: sample.latinName,
                              confidence: sample.confidence,
                              severity: sample.severity,
                              recommendations: sample.recommendations,
                              deviceSource: 'ESP32-CAM Sektor A-01',
                              sector: 'Greenhouse Sektor A',
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                            ),
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    sample.image,
                                    height: 40,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (ctx, e, st) => Container(
                                      height: 40,
                                      color: AppColors.surfaceContainer,
                                      child: const Icon(Icons.eco,
                                          color: AppColors.primary, size: 20),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  sample.diseaseName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.labelMd(
                                          color: AppColors.onSurface)
                                      .copyWith(fontSize: 9, fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  sample.severity,
                                  style: AppTextStyles.labelMd(
                                          color: AppColors.outline)
                                      .copyWith(fontSize: 8),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Active Diagnosis Card
          if (_isScanning)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 48),
              alignment: Alignment.center,
              child: const Column(
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Menganalisis daun via Gemini AI...',
                      style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            )
          else if (scan != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              scan.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, e, st) => Container(
                                color: const Color(0xFF0F172A),
                                child: const Center(
                                  child: Icon(Icons.image_not_supported_rounded,
                                      color: Colors.white54, size: 40),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.70),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${scan.deviceId} • ${scan.sector}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 9, fontFamily: 'monospace'),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF34D399),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.auto_awesome_rounded,
                                      size: 12, color: Colors.black),
                                  const SizedBox(width: 4),
                                  Text('${scan.confidence}% AKURASI AI',
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Disease name + severity
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(scan.diseaseName,
                                style: AppTextStyles.titleLg(color: AppColors.onSurface)),
                            Text(scan.scientificName,
                                style: AppTextStyles.labelMd(
                                    color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3CD),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(scan.severity,
                            style: AppTextStyles.labelMd(color: const Color(0xFF92400E))
                                .copyWith(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Recommendations
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shield_rounded,
                                size: 18, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text('REKOMENDASI PENANGANAN AI',
                                style: AppTextStyles.labelMd(color: AppColors.primary)
                                    .copyWith(letterSpacing: 0.8, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...scan.aiRecommendations.map((rec) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: CircleAvatar(radius: 3, backgroundColor: AppColors.primary),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(rec,
                                      style: AppTextStyles.labelMd(
                                              color: AppColors.onSurfaceVariant)
                                          .copyWith(fontSize: 12, height: 1.4)),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            widget.onSaveToHistory?.call(scan);
                            _showToast('Hasil scan berhasil disimpan ke Riwayat!');
                          },
                          icon: const Icon(Icons.bookmark_add_rounded, size: 18),
                          label: const Text('Simpan ke Riwayat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => setState(() => _activeSubMode = 1),
                          icon: const Icon(Icons.smart_toy_outlined,
                              size: 18, color: Color(0xFFF59E0B)),
                          label: const Text('Konsultasi AI'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF92400E),
                            backgroundColor: AppColors.secondaryContainer,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(vertical: 48),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 48, color: AppColors.outlineVariant),
                  const SizedBox(height: 12),
                  Text('Pilih sampel daun atau upload foto untuk mulai scan.',
                      style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ================= MODE 2: TANYA AI =================
  Widget _buildAiChatMode(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.smart_toy_outlined,
                      size: 20, color: AppColors.onSecondaryContainer),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Konsultasi AI LeafGuard',
                          style: AppTextStyles.labelLg(color: AppColors.onSurface)
                              .copyWith(fontWeight: FontWeight.w700)),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                                color: Color(0xFF4CAF50), shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Text('Online • Asisten Pertanian Presisi',
                              style: AppTextStyles.labelMd(
                                      color: Color(0xFF16A34A))
                                  .copyWith(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _chatScrollController,
              padding: const EdgeInsets.all(14),
              itemCount: _messages.length + (_isChatLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('AI sedang mengetik jawaban...',
                              style: TextStyle(fontSize: 11, color: AppColors.outline)),
                        ],
                      ),
                    ),
                  );
                }
                final m = _messages[index];
                final isUser = m.sender == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.78,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primary : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(m.text,
                            style: AppTextStyles.labelMd(
                                    color: isUser
                                        ? AppColors.onPrimary
                                        : AppColors.onSurface)
                                .copyWith(fontSize: 12.5, height: 1.4)),
                        const SizedBox(height: 4),
                        Text(m.timestamp,
                            style: TextStyle(
                                fontSize: 9,
                                color: isUser
                                    ? Colors.white70
                                    : AppColors.outline)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Input
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    onSubmitted: (_) => _sendChatMessage(),
                    decoration: InputDecoration(
                      hintText: 'Tanyakan penanganan, obat, atau nutrisi...',
                      hintStyle: AppTextStyles.bodyMd(color: AppColors.outline),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isChatLoading ? null : _sendChatMessage,
                  icon: const Icon(Icons.send_rounded),
                  style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===== Mode Tab Widget =====
class _ModeTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? iconColor;

  const _ModeTab({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: isActive
                      ? (iconColor ?? AppColors.onPrimary)
                      : AppColors.onSurfaceVariant),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMd(
                          color: isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant)
                      .copyWith(fontWeight: FontWeight.w700, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== Sampel Daun =====
class _SampleLeaf {
  final String id;
  final String title;
  final String diseaseName;
  final String latinName;
  final int confidence;
  final String severity;
  final String image;
  final List<String> recommendations;

  const _SampleLeaf({
    required this.id,
    required this.title,
    required this.diseaseName,
    required this.latinName,
    required this.confidence,
    required this.severity,
    required this.image,
    required this.recommendations,
  });
}
