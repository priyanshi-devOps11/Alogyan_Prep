import 'package:flutter/material.dart';
import 'package:alogyan_prep/core/theme/app_theme.dart';
import '../models/bundle_model.dart';

// purchased_badge.dart
class PurchasedBadge extends StatelessWidget {
  const PurchasedBadge({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppTheme.success,
      borderRadius: BorderRadius.circular(AppTheme.radiusS),
    ),
    child: const Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.check_rounded, color: Colors.white, size: 11),
      SizedBox(width: 3),
      Text('Purchased',
          style: TextStyle(
              fontFamily: 'Poppins', fontSize: 10,
              fontWeight: FontWeight.w700, color: Colors.white)),
    ]),
  );
}

// search_widget.dart
class BundleSearchBar extends StatelessWidget {
  const BundleSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });
  final TextEditingController controller;
  final void Function(String) onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
        AppTheme.s16, AppTheme.s8, AppTheme.s16, 0),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTheme.bodyLight.copyWith(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search bundles, exams, topics...',
        hintStyle: AppTheme.bodyLight.copyWith(color: AppTheme.textMuted),
        prefixIcon: const Icon(Icons.search_rounded,
            color: AppTheme.textMuted, size: 20),
        suffixIcon: controller.text.isNotEmpty
            ? GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close_rounded,
                color: AppTheme.textMuted, size: 18))
            : null,
        filled: true,
        fillColor: AppTheme.bgWhite,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.s16, vertical: AppTheme.s12),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
            borderSide: const BorderSide(color: AppTheme.borderLight)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
            borderSide:
            const BorderSide(color: AppTheme.brandRed, width: 1.5)),
      ),
    ),
  );
}

// filter_widget.dart
class BundleFilterBar extends StatelessWidget {
  const BundleFilterBar({
    super.key,
    required this.active,
    required this.onSelect,
  });
  final BundleFilter active;
  final void Function(BundleFilter) onSelect;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
          AppTheme.s16, AppTheme.s8, AppTheme.s16, 0),
      children: BundleFilter.values.map((f) {
        final selected = f == active;
        return GestureDetector(
          onTap: () => onSelect(f),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: AppTheme.s8),
            padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.s16, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? AppTheme.brandRed : AppTheme.bgWhite,
              borderRadius:
              BorderRadius.circular(AppTheme.radiusCircle),
              border: Border.all(
                  color: selected
                      ? AppTheme.brandRed
                      : AppTheme.borderLight),
              boxShadow: selected ? [] : AppTheme.cardShadow,
            ),
            child: Text(f.label,
                style: AppTheme.labelMedium.copyWith(
                    fontSize: 13,
                    color: selected
                        ? Colors.white
                        : AppTheme.textPrimary)),
          ),
        );
      }).toList(),
    ),
  );
}

// bundle_card.dart
class BundleCard extends StatelessWidget {
  const BundleCard({
    super.key,
    required this.bundle,
    required this.onTap,
    required this.onBuyTap,
  });
  final BundleModel bundle;
  final VoidCallback onTap;
  final VoidCallback onBuyTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: AppTheme.bgWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Thumbnail ──────────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusL),
                bottomLeft: Radius.circular(AppTheme.radiusL)),
            child: Stack(children: [
              Container(
                width: 110, height: 120,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.brandRedSurface, AppTheme.bgCardAlt])),
                child: bundle.thumbnailUrl != null
                    ? Image.network(bundle.thumbnailUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder())
                    : _placeholder(),
              ),
              // Purchased badge — top right of image
              if (bundle.isPurchased)
                const Positioned(top: 6, right: 6, child: PurchasedBadge()),
              // Free badge
              if (bundle.isFree || bundle.price == 0)
                Positioned(
                    top: 6, left: 6,
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                            color: AppTheme.success,
                            borderRadius: BorderRadius.circular(AppTheme.radiusS)),
                        child: const Text('FREE',
                            style: TextStyle(fontFamily: 'Poppins', fontSize: 10,
                                fontWeight: FontWeight.w700, color: Colors.white)))),
              // Discount badge
              if (bundle.hasDiscount)
                Positioned(
                    bottom: 6, left: 6,
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                            color: AppTheme.brandRed,
                            borderRadius: BorderRadius.circular(AppTheme.radiusS)),
                        child: Text('${bundle.discountPercent}% OFF',
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 10,
                                fontWeight: FontWeight.w700, color: Colors.white)))),
            ]),
          ),

          // ── Content ────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.s12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category tag
                  if (bundle.category != null)
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: AppTheme.brandRedSurface,
                            borderRadius:
                            BorderRadius.circular(AppTheme.radiusS)),
                        child: Text(bundle.category!,
                            style: AppTheme.stepLabel
                                .copyWith(color: AppTheme.brandRed))),
                  const SizedBox(height: AppTheme.s4),

                  // Bundle name
                  Text(bundle.name,
                      style: AppTheme.labelMedium.copyWith(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppTheme.s4),

                  // Description
                  Text(bundle.description,
                      style: AppTheme.bodySmall
                          .copyWith(fontSize: 12, color: AppTheme.textMuted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: AppTheme.s8),

                  // Stats: courses + rating
                  Row(children: [
                    if (bundle.courseCount > 0) ...[
                      const Icon(Icons.play_circle_outline_rounded,
                          size: 13, color: AppTheme.textMuted),
                      const SizedBox(width: 3),
                      Text('${bundle.courseCount} courses',
                          style: AppTheme.bodySmall.copyWith(fontSize: 11)),
                      const SizedBox(width: AppTheme.s8),
                    ],
                    const Icon(Icons.star_rounded,
                        size: 13, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 2),
                    Text('${bundle.rating}',
                        style: AppTheme.bodySmall.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: AppTheme.s8),

                  // Price + Buy button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      if (bundle.isFree || bundle.price == 0)
                        Text('FREE',
                            style: AppTheme.labelMedium.copyWith(
                                color: AppTheme.success, fontSize: 15))
                      else
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('₹${bundle.price.toInt()}',
                                  style: AppTheme.labelMedium.copyWith(
                                      color: AppTheme.brandRed,
                                      fontSize: 16)),
                              if (bundle.hasDiscount)
                                Text(
                                    '₹${bundle.originalPrice!.toInt()}',
                                    style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.textMuted,
                                        fontSize: 11,
                                        decoration:
                                        TextDecoration.lineThrough)),
                            ]),

                      // Action button
                      GestureDetector(
                        onTap: bundle.isPurchased ? null : onBuyTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: bundle.isPurchased
                                ? AppTheme.success.withValues(alpha: 0.1)
                                : null,
                            gradient: bundle.isPurchased
                                ? null
                                : const LinearGradient(colors: [
                              AppTheme.brandRedLight,
                              AppTheme.brandRedDark
                            ]),
                            borderRadius:
                            BorderRadius.circular(AppTheme.radiusM),
                            border: bundle.isPurchased
                                ? Border.all(
                                color: AppTheme.success
                                    .withValues(alpha: 0.4))
                                : null,
                          ),
                          child: Text(
                            bundle.isPurchased
                                ? '✓ Owned'
                                : bundle.isFree
                                ? 'Get Free'
                                : 'Buy Now',
                            style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: bundle.isPurchased
                                    ? AppTheme.success
                                    : Colors.white),
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

  Widget _placeholder() => Center(
    child: Icon(Icons.menu_book_rounded,
        size: 40, color: AppTheme.brandRed.withValues(alpha: 0.3)),
  );
}