import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alogyan_prep/core/theme/app_theme.dart';
import 'package:alogyan_prep/features/bundles/controllers/bundle_controller.dart';
import 'package:alogyan_prep/features/bundles/data/bundle_model.dart';

class BundleDetailScreen extends ConsumerWidget {
  const BundleDetailScreen({super.key, required this.bundle});
  final Bundle bundle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(bundleListProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.brandRed,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 16)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(fit: StackFit.expand, children: [
                Container(decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.brandRedLight, AppTheme.brandRedDark]))),
                Image.asset(bundle.imageAsset, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                        child: Icon(Icons.menu_book_rounded, size: 72,
                            color: Colors.white.withValues(alpha: 0.3)))),
                Container(decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent,
                          AppTheme.bgDark.withValues(alpha: 0.5)]))),
              ]),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.s20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Tags
                Row(children: [
                  _Chip(bundle.examTag, AppTheme.brandRed, AppTheme.brandRedSurface),
                  const SizedBox(width: 8),
                  _Chip(bundle.category, const Color(0xFF6366F1), AppTheme.bgCardAlt),
                  if (bundle.isBestseller) ...[
                    const SizedBox(width: 8),
                    _Chip('🔥 Bestseller', AppTheme.brandRed, AppTheme.brandRedSurface),
                  ],
                ]),
                const SizedBox(height: AppTheme.s12),
                Text(bundle.title, style: AppTheme.headingLight),
                const SizedBox(height: AppTheme.s8),
                Text(bundle.subtitle, style: AppTheme.bodyLight),
                const SizedBox(height: AppTheme.s16),
                // Rating
                Row(children: [
                  ...List.generate(5, (i) => Icon(
                      i < bundle.rating.floor()
                          ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 18, color: const Color(0xFFF59E0B))),
                  const SizedBox(width: 8),
                  Text('${bundle.rating}',
                      style: AppTheme.labelMedium.copyWith(fontSize: 14)),
                  Text(' · ${bundle.reviewCount} reviews',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted)),
                ]),
                const SizedBox(height: AppTheme.s20),
                // Stats grid
                Container(
                  padding: const EdgeInsets.all(AppTheme.s16),
                  decoration: BoxDecoration(
                      color: AppTheme.bgWhite,
                      borderRadius: BorderRadius.circular(AppTheme.radiusL),
                      boxShadow: AppTheme.cardShadow),
                  child: Row(children: [
                    if (bundle.questionCount > 0)
                      Expanded(child: _StatItem(Icons.help_outline_rounded,
                          AppTheme.brandRed, '${bundle.questionCount}+', 'Questions')),
                    if (bundle.pdfPageCount > 0)
                      Expanded(child: _StatItem(Icons.description_outlined,
                          const Color(0xFF6366F1), '${bundle.pdfPageCount}', 'Pages')),
                    Expanded(child: _StatItem(Icons.timer_outlined,
                        const Color(0xFF059669), bundle.duration, 'Access')),
                    Expanded(child: _StatItem(Icons.star_rounded,
                        const Color(0xFFF59E0B), '${bundle.rating}', 'Rating')),
                  ]),
                ),
                const SizedBox(height: AppTheme.s24),
                Text("What's Included",
                    style: AppTheme.headingLight.copyWith(fontSize: 18)),
                const SizedBox(height: AppTheme.s12),
                ..._getIncludes().map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.s8),
                  child: Row(children: [
                    Container(width: 22, height: 22,
                        decoration: BoxDecoration(
                            color: AppTheme.brandRedSurface, shape: BoxShape.circle),
                        child: const Icon(Icons.check_rounded,
                            size: 13, color: AppTheme.brandRed)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(item, style: AppTheme.bodyLight)),
                  ]),
                )),
                const SizedBox(height: AppTheme.s80),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
            left: AppTheme.s20, right: AppTheme.s20,
            bottom: MediaQuery.viewPaddingOf(context).bottom + AppTheme.s16,
            top: AppTheme.s16),
        decoration: BoxDecoration(
            color: AppTheme.bgWhite,
            boxShadow: [BoxShadow(
                color: AppTheme.textPrimary.withValues(alpha: 0.08),
                blurRadius: 20, offset: const Offset(0, -4))]),
        child: Row(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (bundle.isFree || bundle.price == 0)
                Text('FREE', style: AppTheme.headingLight.copyWith(color: AppTheme.success))
              else ...[
                Text('₹${bundle.price.toInt()}',
                    style: AppTheme.headingLight.copyWith(color: AppTheme.brandRed)),
                if (bundle.hasDiscount)
                  Text('₹${bundle.originalPrice!.toInt()}',
                      style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textMuted,
                          decoration: TextDecoration.lineThrough)),
              ],
            ],
          ),
          const SizedBox(width: AppTheme.s20),
          Expanded(child: GestureDetector(
            onTap: () {
              if (!bundle.isPurchased) {
                notifier.markPurchased(bundle.id);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Bundle added! Happy studying 🎉'),
                    backgroundColor: AppTheme.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusS))));
                Navigator.pop(context);
              }
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                  color: bundle.isPurchased ? AppTheme.success : null,
                  gradient: bundle.isPurchased ? null : const LinearGradient(
                      colors: [AppTheme.brandRedLight, AppTheme.brandRedDark]),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  boxShadow: bundle.isPurchased ? [] : AppTheme.buttonShadow),
              child: Center(child: Text(
                  bundle.isPurchased ? '✓ Already Purchased' :
                  bundle.isFree ? 'Get for Free' : 'Buy Now',
                  style: const TextStyle(fontFamily: 'Poppins',
                      fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white))),
            ),
          )),
        ]),
      ),
    );
  }

  List<String> _getIncludes() => [
    if (bundle.questionCount > 0) '${bundle.questionCount}+ Practice Questions',
    if (bundle.pdfPageCount > 0) '${bundle.pdfPageCount} pages of PDF Notes',
    'Chapter-wise organisation',
    'Performance analytics & tracking',
    '${bundle.duration} access',
    'Offline access available',
    if (bundle.category == 'Live Sessions') 'Live doubt sessions',
    'Mobile & tablet friendly',
  ];
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, this.textColor, this.bgColor);
  final String label; final Color textColor, bgColor;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusS)),
      child: Text(label,
          style: AppTheme.stepLabel.copyWith(color: textColor, fontSize: 12)));
}

class _StatItem extends StatelessWidget {
  const _StatItem(this.icon, this.color, this.value, this.label);
  final IconData icon; final Color color; final String value, label;
  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, color: color, size: 20),
    const SizedBox(height: 4),
    Text(value, style: AppTheme.labelMedium.copyWith(fontSize: 12)),
    Text(label,
        style: AppTheme.bodySmall.copyWith(
            fontSize: 10, color: AppTheme.textMuted)),
  ]);
}