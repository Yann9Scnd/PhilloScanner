import 'package:flutter/material.dart';
import '../models/disease_model.dart';
import '../theme/app_theme.dart';

/// Halaman Detail Penyakit — Ensiklopedia (deskripsi, gejala, cara pencegahan)
class DiseaseDetailScreen extends StatelessWidget {
  final DiseaseModel disease;

  const DiseaseDetailScreen({super.key, required this.disease});

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
                  Text('Detail Penyakit',
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
                    // Featured Image
                    AspectRatio(
                      aspectRatio: 1.2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                disease.imageUrl,
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
                                child: Text(
                                  disease.category.toUpperCase(),
                                  style: AppTextStyles.labelLg(
                                          color: AppColors.onSecondaryContainer)
                                      .copyWith(letterSpacing: 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title + Scientific Name
                    Text(disease.name,
                        style: AppTextStyles.headlineLgMobile(
                            color: AppColors.primary)),
                    if (disease.scientificName.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(disease.scientificName,
                          style: AppTextStyles.labelMd(
                              color: AppColors.onSurfaceVariant)),
                    ],
                    const SizedBox(height: 16),

                    // Description
                    _InfoSection(
                      icon: Icons.menu_book_rounded,
                      title: 'Deskripsi',
                      child: Text(disease.description,
                          style: AppTextStyles.bodyMd(
                                  color: AppColors.onSurfaceVariant)
                              .copyWith(fontSize: 15, height: 1.5)),
                    ),
                    const SizedBox(height: 16),

                    // Symptoms
                    _InfoSection(
                      icon: Icons.report_problem_rounded,
                      title: 'Gejala',
                      child: Text(disease.symptoms,
                          style: AppTextStyles.bodyMd(
                                  color: AppColors.onSurfaceVariant)
                              .copyWith(fontSize: 15, height: 1.5)),
                    ),
                    const SizedBox(height: 16),

                    // General Prevention
                    _InfoSection(
                      icon: Icons.shield_rounded,
                      title: 'Cara Pencegahan Umum',
                      accentColor: AppColors.primary,
                      child: Column(
                        children: List.generate(
                          disease.preventionSteps.length,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _StepItem(
                              step: index + 1,
                              text: disease.preventionSteps[index],
                            ),
                          ),
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

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  final Color? accentColor;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.child,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppColors.secondary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1))
        ],
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
                    color: color, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, size: 20, color: AppColors.onPrimary),
              ),
              const SizedBox(width: 12),
              Text(title, style: AppTextStyles.titleMd(color: color)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final int step;
  final String text;

  const _StepItem({required this.step, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)
                  .copyWith(fontSize: 15, height: 1.4)),
        ),
      ],
    );
  }
}
