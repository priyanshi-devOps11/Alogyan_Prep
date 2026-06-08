import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alogyan_prep/core/theme/app_theme.dart';
import 'package:alogyan_prep/features/bundles/controllers/bundle_controller.dart';
import 'package:alogyan_prep/features/bundles/data/bundle_model.dart';
import 'bundle_detail_screen.dart';

class BundleListingScreen extends ConsumerStatefulWidget {
  const BundleListingScreen({super.key});

  @override
  ConsumerState<BundleListingScreen> createState() =>
      _BundleListingScreenState();
}

class _BundleListingScreenState extends ConsumerState<BundleListingScreen> {
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(bundleListProvider);
    final notifier = ref.read(bundleListProvider.notifier);
    final examTags = ref.watch(examTagsProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────────
            _Header(onSortTap: () => _showSortSheet(context, ref)),

            // ── Search bar ─────────────────────────────────────────────────
            _SearchBar(
              controller: _searchCtrl,
              onChanged: notifier.search,
              onClear: () {
                _searchCtrl.clear();
                notifier.search('');
              },
            ),

            // ── Category chips ─────────────────────────────────────────────
            _CategoryChips(
              selected: state.selectedCategory,
              onSelect: notifier.setCategory,
            ),

            // ── Exam filter chips ──────────────────────────────────────────
            _ExamFilterChips(
              tags: examTags,
              selected: state.selectedExamFilter,
              onSelect: (tag) => notifier.setExamFilter(
                  state.selectedExamFilter == tag ? null : tag),
            ),

            // ── Result count bar ───────────────────────────────────────────
            _ResultBar(
              count: state.filtered.length,
              hasActiveFilters: state.searchQuery.isNotEmpty ||
                  state.selectedCategory != BundleCategory.all ||
                  state.selectedExamFilter != null,
              onClear: notifier.clearFilters,
            ),

            // ── Bundle list ────────────────────────────────────────────────
            Expanded(
              child: state.filtered.isEmpty
                  ? _EmptyState(onClear: notifier.clearFilters)
                  : ListView.separated(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(
                    AppTheme.s16, AppTheme.s8, AppTheme.s16, AppTheme.s32),
                itemCount: state.filtered.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: AppTheme.s12),
                itemBuilder: (_, i) => _BundleCard(
                  bundle: state.filtered[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BundleDetailScreen(
                          bundle: state.filtered[i]),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortSheet(BuildContext ctx, WidgetRef ref) {
    final state    = ref.read(bundleListProvider);
    final notifier = ref.read(bundleListProvider.notifier);

    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppTheme.bgWhite,
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXL))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppTheme.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sort by', style: AppTheme.headingLight),
            const SizedBox(height: AppTheme.s16),
            ...SortOption.values.map((opt) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(opt.label, style: AppTheme.labelMedium),
              trailing: state.sortOption == opt
                  ? const Icon(Icons.check_rounded,
                  color: AppTheme.brandRed)
                  : null,
              onTap: () {
                notifier.setSort(opt);
                Navigator.pop(ctx);
              },
            )),
            const SizedBox(height: AppTheme.s8),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.onSortTap});
  final VoidCallback onSortTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
        AppTheme.s20, AppTheme.s16, AppTheme.s20, AppTheme.s8),
    child: Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Study Bundles', style: AppTheme.headingLight),
        Text('Pick your exam. Start learning.',
            style:
            AppTheme.bodySmall.copyWith(color: AppTheme.textMuted)),
      ]),
      const Spacer(),
      GestureDetector(
        onTap: onSortTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.bgWhite,
            borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
            border: Border.all(color: AppTheme.borderLight),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.sort_rounded,
                size: 16, color: AppTheme.textPrimary),
            const SizedBox(width: 6),
            Text('Sort',
                style: AppTheme.labelMedium.copyWith(fontSize: 13)),
          ]),
        ),
      ),
    ]),
  );
}

// ─── Search Bar ───────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar(
      {required this.controller,
        required this.onChanged,
        required this.onClear});
  final TextEditingController controller;
  final void Function(String) onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.s16, vertical: AppTheme.s8),
    child: TextField(
      controller: controller,
      onChanged: onChanged,
      style: AppTheme.bodyLight.copyWith(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: 'Search bundles, exams, topics...',
        hintStyle:
        AppTheme.bodyLight.copyWith(color: AppTheme.textMuted),
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
          borderRadius:
          BorderRadius.circular(AppTheme.radiusCircle),
          borderSide: const BorderSide(color: AppTheme.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(AppTheme.radiusCircle),
          borderSide:
          const BorderSide(color: AppTheme.brandRed, width: 1.5),
        ),
      ),
    ),
  );
}

// ─── Category Chips ───────────────────────────────────────────────────────────
class _CategoryChips extends StatelessWidget {
  const _CategoryChips(
      {required this.selected, required this.onSelect});
  final BundleCategory selected;
  final void Function(BundleCategory) onSelect;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 40,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding:
      const EdgeInsets.symmetric(horizontal: AppTheme.s16),
      children: BundleCategory.values.map((cat) {
        final isSelected = cat == selected;
        return GestureDetector(
          onTap: () => onSelect(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: AppTheme.s8),
            padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.s16, vertical: AppTheme.s8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.brandRed
                  : AppTheme.bgWhite,
              borderRadius:
              BorderRadius.circular(AppTheme.radiusCircle),
              border: Border.all(
                  color: isSelected
                      ? AppTheme.brandRed
                      : AppTheme.borderLight),
              boxShadow:
              isSelected ? [] : AppTheme.cardShadow,
            ),
            child: Text('${cat.emoji} ${cat.label}',
                style: AppTheme.labelMedium.copyWith(
                    fontSize: 12,
                    color: isSelected
                        ? Colors.white
                        : AppTheme.textPrimary)),
          ),
        );
      }).toList(),
    ),
  );
}

// ─── Exam Filter Chips ────────────────────────────────────────────────────────
class _ExamFilterChips extends StatelessWidget {
  const _ExamFilterChips(
      {required this.tags,
        required this.selected,
        required this.onSelect});
  final List<String> tags;
  final String? selected;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 36,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.s16, vertical: AppTheme.s4),
      children: tags.map((tag) {
        final isSelected = tag == selected;
        return GestureDetector(
          onTap: () => onSelect(tag),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: AppTheme.s8),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.brandRedSurface
                  : Colors.transparent,
              borderRadius:
              BorderRadius.circular(AppTheme.radiusCircle),
              border: Border.all(
                  color: isSelected
                      ? AppTheme.brandRed
                      : AppTheme.borderLight,
                  width: isSelected ? 1.5 : 1),
            ),
            child: Text(tag,
                style: AppTheme.stepLabel.copyWith(
                    color: isSelected
                        ? AppTheme.brandRed
                        : AppTheme.textSecondary,
                    fontWeight: isSelected
                        ? FontWeight.w700
                        : FontWeight.w500)),
          ),
        );
      }).toList(),
    ),
  );
}

// ─── Result Bar ───────────────────────────────────────────────────────────────
class _ResultBar extends StatelessWidget {
  const _ResultBar(
      {required this.count,
        required this.hasActiveFilters,
        required this.onClear});
  final int count;
  final bool hasActiveFilters;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.s20, vertical: AppTheme.s8),
    child: Row(children: [
      Text('$count bundles found',
          style: AppTheme.bodySmall
              .copyWith(color: AppTheme.textMuted)),
      const Spacer(),
      if (hasActiveFilters)
        GestureDetector(
          onTap: onClear,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.close_rounded,
                size: 14, color: AppTheme.brandRed),
            const SizedBox(width: 4),
            Text('Clear',
                style: AppTheme.linkText.copyWith(fontSize: 12)),
          ]),
        ),
    ]),
  );
}

// ─── Bundle Card ──────────────────────────────────────────────────────────────
class _BundleCard extends StatelessWidget {
  const _BundleCard({required this.bundle, required this.onTap});
  final Bundle bundle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: AppTheme.bgWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Stack(children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusL)),
              child: Container(
                height: 130, width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.brandRedSurface, AppTheme.bgCardAlt]),
                ),
                child: Image.asset(bundle.imageAsset, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                        child: Icon(Icons.menu_book_rounded,
                            size: 52,
                            color: AppTheme.brandRed
                                .withValues(alpha: 0.3)))),
              ),
            ),
            // Badges
            Positioned(
              top: 8, left: 8,
              child: Row(children: [
                if (bundle.isFree)
                  _Badge('FREE', AppTheme.success),
                if (bundle.isNew)
                  _Badge('NEW', const Color(0xFF6366F1)),
                if (bundle.isBestseller)
                  _Badge('🔥 Bestseller', AppTheme.brandRed),
                if (bundle.isPurchased)
                  _Badge('✓ Purchased', AppTheme.success),
              ]),
            ),
            if (bundle.hasDiscount)
              Positioned(
                  top: 8, right: 8,
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: AppTheme.brandRed,
                          borderRadius: BorderRadius.circular(AppTheme.radiusS)),
                      child: Text('${bundle.discountPercent}% OFF',
                          style: const TextStyle(
                              fontFamily: 'Poppins', fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)))),
          ]),
          // Content
          Padding(
            padding: const EdgeInsets.all(AppTheme.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  _TagChip(bundle.examTag, AppTheme.brandRed, AppTheme.brandRedSurface),
                  const SizedBox(width: AppTheme.s8),
                  _TagChip(bundle.category, const Color(0xFF6366F1), AppTheme.bgCardAlt),
                ]),
                const SizedBox(height: AppTheme.s8),
                Text(bundle.title,
                    style: AppTheme.labelMedium.copyWith(fontSize: 15),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: AppTheme.s4),
                Text(bundle.subtitle,
                    style: AppTheme.bodySmall
                        .copyWith(color: AppTheme.textMuted),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: AppTheme.s12),
                // Stats
                Row(children: [
                  if (bundle.questionCount > 0) ...[
                    const Icon(Icons.help_outline_rounded,
                        size: 13, color: AppTheme.textMuted),
                    const SizedBox(width: 3),
                    Text('${bundle.questionCount}+ Qs',
                        style: AppTheme.bodySmall.copyWith(fontSize: 12)),
                    const SizedBox(width: AppTheme.s12),
                  ],
                  const Icon(Icons.star_rounded,
                      size: 13, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 3),
                  Text('${bundle.rating}',
                      style: AppTheme.bodySmall.copyWith(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                  Text(' (${bundle.reviewCount})',
                      style: AppTheme.bodySmall.copyWith(
                          fontSize: 11, color: AppTheme.textMuted)),
                ]),
                const SizedBox(height: AppTheme.s12),
                // Price row
                Row(children: [
                  if (bundle.isFree || bundle.price == 0)
                    Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusM)),
                        child: Text('FREE',
                            style: AppTheme.labelMedium
                                .copyWith(color: AppTheme.success, fontSize: 13)))
                  else ...[
                    Text('₹${bundle.price.toInt()}',
                        style: AppTheme.headingLight
                            .copyWith(color: AppTheme.brandRed, fontSize: 18)),
                    if (bundle.hasDiscount) ...[
                      const SizedBox(width: 6),
                      Text('₹${bundle.originalPrice!.toInt()}',
                          style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textMuted,
                              decoration: TextDecoration.lineThrough)),
                    ],
                  ],
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
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
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      border: bundle.isPurchased
                          ? Border.all(
                          color: AppTheme.success.withValues(alpha: 0.3))
                          : null,
                      boxShadow: bundle.isPurchased
                          ? []
                          : [BoxShadow(
                          color: AppTheme.brandRed.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3))],
                    ),
                    child: Text(
                        bundle.isPurchased
                            ? '✓ Purchased'
                            : bundle.isFree ? 'Get Free' : 'Buy Now',
                        style: TextStyle(
                            fontFamily: 'Poppins', fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: bundle.isPurchased
                                ? AppTheme.success
                                : Colors.white)),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, this.color);
  final String label; final Color color;
  @override
  Widget build(BuildContext context) => Container(
      margin: const EdgeInsets.only(right: 5),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(AppTheme.radiusS)),
      child: Text(label,
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 10,
              fontWeight: FontWeight.w700, color: Colors.white)));
}

class _TagChip extends StatelessWidget {
  const _TagChip(this.label, this.textColor, this.bgColor);
  final String label; final Color textColor, bgColor;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusS)),
      child: Text(label,
          style: AppTheme.stepLabel.copyWith(color: textColor)));
}

// ─── Empty state ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onClear});
  final VoidCallback onClear;
  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.search_off_rounded, size: 72,
          color: AppTheme.textMuted.withValues(alpha: 0.4)),
      const SizedBox(height: AppTheme.s16),
      Text('No bundles found',
          style: AppTheme.headingLight.copyWith(color: AppTheme.textSecondary)),
      const SizedBox(height: AppTheme.s8),
      Text('Try different keywords or filters',
          style: AppTheme.bodyLight.copyWith(color: AppTheme.textMuted)),
      const SizedBox(height: AppTheme.s24),
      GestureDetector(
        onTap: onClear,
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
                color: AppTheme.brandRedSurface,
                borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
                border: Border.all(color: AppTheme.brandRed.withValues(alpha: 0.3))),
            child: Text('Clear Filters',
                style: AppTheme.labelMedium.copyWith(color: AppTheme.brandRed))),
      ),
    ]),
  );
}