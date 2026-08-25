import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../theme/app_theme.dart';

class AiConfigDialog extends StatefulWidget {
  const AiConfigDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => const AiConfigDialog(),
    );
  }

  @override
  State<AiConfigDialog> createState() => _AiConfigDialogState();
}

class _AiConfigDialogState extends State<AiConfigDialog> {
  late TextEditingController _apiKeyController;
  late String _selectedProvider;
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController(text: AiService.instance.apiKey);
    _selectedProvider = AiService.instance.provider;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  void _save() {
    AiService.instance.provider = _selectedProvider;
    AiService.instance.apiKey = _apiKeyController.text.trim();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 18),
            const SizedBox(width: 8),
            const Expanded(child: Text('Pengaturan AI berhasil disimpan!')),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: AppColors.surfaceContainerLowest,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF0F172A), Color(0xFFA78BFA)],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFA78BFA).withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFA78BFA).withValues(alpha: 0.40)),
                    ),
                    child: const Icon(Icons.psychology_rounded, color: Color(0xFFA78BFA), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pengaturan AI',
                          style: AppTextStyles.labelLg(color: Colors.white)
                              .copyWith(fontWeight: FontWeight.w800),
                        ),
                        const Text(
                          'Masukkan API Key untuk analisis daun',
                          style: TextStyle(color: Color(0xFFD4C8FF), fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedProvider = 'gemini'),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _selectedProvider == 'gemini'
                                    ? const Color(0xFFA78BFA).withValues(alpha: 0.10)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedProvider == 'gemini'
                                      ? const Color(0xFFA78BFA)
                                      : const Color(0xFFE2E8F0),
                                  width: _selectedProvider == 'gemini' ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    color: _selectedProvider == 'gemini'
                                        ? const Color(0xFFA78BFA)
                                        : AppColors.onSurfaceVariant,
                                    size: 22,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Google Gemini',
                                    style: AppTextStyles.labelMd(
                                            color: _selectedProvider == 'gemini'
                                                ? const Color(0xFFA78BFA)
                                                : AppColors.onSurfaceVariant)
                                        .copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Gratis 15 RPM',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _selectedProvider == 'gemini'
                                          ? const Color(0xFF7C5CBF)
                                          : AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedProvider = 'openai'),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _selectedProvider == 'openai'
                                    ? const Color(0xFFA78BFA).withValues(alpha: 0.10)
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _selectedProvider == 'openai'
                                      ? const Color(0xFFA78BFA)
                                      : const Color(0xFFE2E8F0),
                                  width: _selectedProvider == 'openai' ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.smart_toy_rounded,
                                    color: _selectedProvider == 'openai'
                                        ? const Color(0xFFA78BFA)
                                        : AppColors.onSurfaceVariant,
                                    size: 22,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'OpenAI GPT-4o',
                                    style: AppTextStyles.labelMd(
                                            color: _selectedProvider == 'openai'
                                                ? const Color(0xFFA78BFA)
                                                : AppColors.onSurfaceVariant)
                                        .copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Bayar per token',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _selectedProvider == 'openai'
                                          ? const Color(0xFF7C5CBF)
                                          : AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Text(
                      'API Key',
                      style: AppTextStyles.labelMd(color: AppColors.onSurfaceVariant)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _apiKeyController,
                      obscureText: _obscureKey,
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: _selectedProvider == 'gemini' ? 'AIza...' : 'sk-...',
                        prefixIcon: const Icon(Icons.key_rounded, size: 18),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureKey ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            size: 18,
                          ),
                          onPressed: () => setState(() => _obscureKey = !_obscureKey),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFA78BFA), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Cara Mendapatkan API Key',
                                style: AppTextStyles.labelLg(color: AppColors.primary)
                                    .copyWith(fontWeight: FontWeight.w800, fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dapatkan API Key:\n'
                            '- Gemini: aistudio.google.com/apikey\n'
                            '- OpenAI: platform.openai.com/api-keys',
                            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)
                                .copyWith(fontSize: 11, height: 1.6),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.check_rounded, size: 16),
                        label: const Text('Simpan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA78BFA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
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
