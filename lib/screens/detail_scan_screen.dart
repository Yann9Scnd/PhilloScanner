import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/chat_message_model.dart';
import '../models/scan_result_model.dart';
import '../services/ai_service.dart';
import '../theme/app_theme.dart';

/// Halaman Detail Hasil Scan Daun
class DetailScanScreen extends StatefulWidget {
  final ScanResultModel scan;

  const DetailScanScreen({super.key, required this.scan});

  @override
  State<DetailScanScreen> createState() => _DetailScanScreenState();
}

class _DetailScanScreenState extends State<DetailScanScreen> {
  final List<ChatMessageModel> _messages = [];
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  bool _isChatLoading = false;

  ScanResultModel get _activeScan => widget.scan;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessageModel(
      id: 'ai-intro',
      sender: 'ai',
      text:
          'Deteksi: ${_activeScan.diseaseName} (Kepercayaan ${_activeScan.confidence}%). Tanyakan cara pencegahan alami atau penanganan untuk tanaman di sekitar Anda.',
      timestamp: _activeScan.timestamp,
    ));
  }

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

  Future<void> _handleSendChat() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _isChatLoading) return;

    setState(() {
      _messages.add(ChatMessageModel(
        id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
        sender: 'user',
        text: text,
        timestamp: 'Sekarang',
      ));
      _chatController.clear();
      _isChatLoading = true;
    });
    _scrollChatToBottom();

    String replyText;
    try {
      replyText = await AiService.instance.chat(text);
    } catch (_) {
      replyText = 'Maaf, AI sedang tidak dapat dihubungi. Coba lagi nanti.';
    }

    if (!mounted) return;
    setState(() {
      _messages.add(ChatMessageModel(
        id: 'ai-${DateTime.now().millisecondsSinceEpoch}',
        sender: 'ai',
        text: replyText,
        timestamp: 'Sekarang',
      ));
      _isChatLoading = false;
    });
    _scrollChatToBottom();
  }

  Future<void> _handleShare() async {
    final text =
        'Hasil Scan LeafGuard: ${_activeScan.diseaseName} (Kepercayaan ${_activeScan.confidence}%, ${_activeScan.severity})';
    await Clipboard.setData(ClipboardData(text: text));
    _showToast('Informasi berhasil disalin ke clipboard!');
  }

  void _handleSave() {
    _showToast('Tersimpan di database lokal!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(9999),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('Detail Hasil Scan',
                      style:
                          AppTextStyles.headlineSm(color: AppColors.onSurface)),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Featured Image Card (Square 1:1)
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              // Scan Image
                              Positioned.fill(
                                child: Image.network(
                                  _activeScan.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (ctx, e, st) => Container(
                                    color: AppColors.surfaceContainer,
                                    child: const Center(
                                        child: Icon(Icons.eco,
                                            size: 64,
                                            color: AppColors.primary)),
                                  ),
                                ),
                              ),
                              // Severity Badge
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryContainer,
                                    borderRadius: BorderRadius.circular(9999),
                                    boxShadow: [
                                      BoxShadow(
                                          color:
                                              Colors.black.withValues(alpha: 0.15),
                                          blurRadius: 6)
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_rounded,
                                          size: 18,
                                          color:
                                              AppColors.onSecondaryContainer),
                                      const SizedBox(width: 4),
                                      Text(
                                        _activeScan.severity.toUpperCase(),
                                        style: AppTextStyles.labelLg(
                                                color: AppColors
                                                    .onSecondaryContainer)
                                            .copyWith(letterSpacing: 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Animated scan line hint (static decoration)
                              Positioned(
                                left: 0,
                                right: 0,
                                top: 100,
                                child: Opacity(
                                  opacity: 0.30,
                                  child: Container(
                                    height: 2,
                                    color: AppColors.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Result Summary Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 1))
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('IDENTIFIKASI',
                                        style: AppTextStyles.labelMd(
                                                color: AppColors.secondary)
                                            .copyWith(letterSpacing: 1.5)),
                                    const SizedBox(height: 4),
                                    Text(_activeScan.diseaseName,
                                        style: AppTextStyles.headlineLgMobile(
                                            color: AppColors.primary)),
                                    if (_activeScan.scientificName.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(_activeScan.scientificName,
                                          style: AppTextStyles.labelMd(
                                              color: AppColors.onSurfaceVariant)),
                                    ],
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Kepercayaan',
                                      style: AppTextStyles.labelMd(
                                          color: AppColors.outline)),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('${_activeScan.confidence}',
                                          style: AppTextStyles.dataDisplay(
                                              color: AppColors.primary)),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 6),
                                        child: Text('%',
                                            style: AppTextStyles.titleMd(
                                                color: AppColors.primary)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  size: 16, color: AppColors.outline),
                              const SizedBox(width: 6),
                              Text(_activeScan.timestamp,
                                  style: AppTextStyles.bodyMd(
                                      color: AppColors.outline)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // AI Recommendations Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.lightbulb_rounded,
                                    size: 20, color: AppColors.onPrimary),
                              ),
                              const SizedBox(width: 12),
                              Text('Saran AI',
                                  style: AppTextStyles.titleMd(
                                      color: AppColors.primary)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(
                            _activeScan.aiRecommendations.length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _StepItem(
                                step: index + 1,
                                text: _activeScan.aiRecommendations[index],
                                isLast:
                                    index == _activeScan.aiRecommendations.length - 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tanya AI LeafGuard Chat Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.10)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: AppColors.secondaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.smart_toy_outlined,
                                    size: 18, color: AppColors.onSecondaryContainer),
                              ),
                              const SizedBox(width: 10),
                              Text('Tanya AI LeafGuard',
                                  style: AppTextStyles.titleMd(
                                      color: AppColors.primary)),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Chat Messages
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 220),
                            child: ListView.separated(
                              controller: _chatScrollController,
                              shrinkWrap: true,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _messages.length + (_isChatLoading ? 1 : 0),
                              separatorBuilder: (_, _) => const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                if (index == _messages.length) {
                                  return const Align(
                                    alignment: Alignment.centerLeft,
                                    child: _TypingBubble(),
                                  );
                                }
                                final msg = _messages[index];
                                final isUser = msg.sender == 'user';
                                return Align(
                                  alignment: isUser
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    constraints: const BoxConstraints(maxWidth: 280),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isUser
                                          ? AppColors.primary
                                          : const Color(0xFFF3F3F3),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(isUser ? 14 : 4),
                                        topRight: Radius.circular(isUser ? 4 : 14),
                                        bottomLeft: const Radius.circular(14),
                                        bottomRight: const Radius.circular(14),
                                      ),
                                    ),
                                    child: Text(
                                      msg.text,
                                      style: AppTextStyles.labelMd(
                                        color: isUser
                                            ? AppColors.onPrimary
                                            : AppColors.onSurfaceVariant,
                                      ).copyWith(fontSize: 12, height: 1.4),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Chat Input
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F3F3),
                              borderRadius: BorderRadius.circular(9999),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _chatController,
                                    onSubmitted: (_) => _handleSendChat(),
                                    textInputAction: TextInputAction.send,
                                    style: const TextStyle(fontSize: 13),
                                    decoration: InputDecoration(
                                      hintText: 'Tanyakan sesuatu...',
                                      hintStyle: AppTextStyles.labelMd(
                                          color: AppColors.outline),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: GestureDetector(
                                    onTap: _handleSendChat,
                                    child: Container(
                                      width: 34,
                                      height: 34,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.send_rounded,
                                          size: 16, color: AppColors.onPrimary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Technical Info Grid
                    Row(
                      children: [
                        Expanded(
                          child: _TechInfoCard(
                            icon: Icons.videocam_rounded,
                            label: 'Sumber Perangkat',
                            value: _activeScan.deviceId,
                            subtitle: 'ESP32-CAM',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TechInfoCard(
                            icon: Icons.water_drop_outlined,
                            label: 'Kelembapan',
                            value: _activeScan.soilMoisture,
                            subtitle: 'Waktu Scan',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Action Footer Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _handleShare,
                            icon: const Icon(Icons.share_rounded),
                            label: const Text('Bagikan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              elevation: 4,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _handleSave,
                            icon: const Icon(Icons.download_rounded),
                            label: const Text('Simpan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surfaceContainer,
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(14),
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      child: Text(
        'AI LeafGuard sedang mengetik...',
        style: AppTextStyles.labelMd(color: AppColors.outline).copyWith(fontSize: 11),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final int step;
  final String text;
  final bool isLast;
  const _StepItem({
    required this.step,
    required this.text,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                  color: AppColors.secondaryContainer, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  '$step',
                  style:
                      AppTextStyles.labelMd(color: AppColors.onSecondaryContainer),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 1.5,
                height: 18,
                color: const Color(0xFFC0C7CF),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 6),
            child: Text(text,
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)
                    .copyWith(fontSize: 15, height: 1.4)),
          ),
        ),
      ],
    );
  }
}

class _TechInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  const _TechInfoCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.outline),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label,
                    style: AppTextStyles.labelMd(color: AppColors.outline),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: AppTextStyles.titleMd(color: AppColors.primary),
              overflow: TextOverflow.ellipsis),
          Text(subtitle,
              style: AppTextStyles.labelMd(color: AppColors.outlineVariant)),
        ],
      ),
    );
  }
}
