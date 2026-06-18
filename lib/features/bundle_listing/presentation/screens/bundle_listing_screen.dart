import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alogyan_prep/core/theme/app_theme.dart';
import 'package:alogyan_prep/features/bundle_listing/controllers/bundle_controller.dart';
import 'package:alogyan_prep/features/bundle_listing/models/bundle_model.dart';
import 'package:alogyan_prep/features/bundle_listing/widgets/bundle_widgets.dart';
import 'package:alogyan_prep/features/onboarding/controllers/controllers.dart';

class BundleListingScreen extends ConsumerStatefulWidget {
  const BundleListingScreen({super.key});

  @override
  ConsumerState<BundleListingScreen> createState() =>
      _BundleListingScreenState();
}

class _BundleListingScreenState extends ConsumerState<BundleListingScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state    = ref.watch(bundleProvider);
    final notifier = ref.read(bundleProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      appBar: AppBar(
        backgroundColor: AppTheme.bgWhite,
        elevation: 0,
        automaticallyImplyLeading: false, // remove default back button
        title: Text('Study Bundles',
            style: AppTheme.headingLight.copyWith(fontSize: 18)),
        actions: [
          // Sign out button
          GestureDetector(
            onTap: () async {
              await ref.read(authProvider.notifier).signOut();
              // signOut() resets flow to splash + sets unauthenticate
            },
            child: Container(
              margin: const EdgeInsets.only(right: AppTheme.s16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.brandRedSurface,
                borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
                border: Border.all(
                    color: AppTheme.brandRed.withValues(alpha: 0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.logout_rounded,
                    size: 15, color: AppTheme.brandRed),
                const SizedBox(width: 5),
                Text('Sign Out',
                    style: AppTheme.labelMedium.copyWith(
                        color: AppTheme.brandRed, fontSize: 12)),
              ]),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.borderLight),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search bar ───
          BundleSearchBar(
            controller: _searchCtrl,
            onChanged: (v) {
              setState(() {});
              notifier.search(v);
            },
            onClear: () {
              _searchCtrl.clear();
              setState(() {});
              notifier.search('');
            },
          ),

          const SizedBox(height: AppTheme.s8),

          // ── Filter tabs: All / Free / Paid / Purchased ────────────────
          BundleFilterBar(
            active: state.activeFilter,
            onSelect: notifier.setFilter,
          ),

          const SizedBox(height: AppTheme.s8),

          // ── Result count ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.s20),
            child: Row(children: [
              Text('${state.filtered.length} bundles',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted)),
              const Spacer(),
              if (state.query.isNotEmpty ||
                  state.activeFilter != BundleFilter.all)
                GestureDetector(
                  onTap: () {
                    _searchCtrl.clear();
                    setState(() {});
                    notifier.clearAll();
                  },
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.close_rounded,
                        size: 14, color: AppTheme.brandRed),
                    const SizedBox(width: 3),
                    Text('Clear',
                        style: AppTheme.linkText.copyWith(fontSize: 12)),
                  ]),
                ),
            ]),
          ),

          const SizedBox(height: AppTheme.s8),

          // ── Bundle list / Loading / Empty / Error ─────────────────────
          Expanded(child: _buildBody(state, notifier)),
        ],
      ),
    );
  }

  Widget _buildBody(BundleState state, BundleController notifier) {
    if (state.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.brandRed));
    }

    if (state.error != null) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off_rounded, size: 56, color: AppTheme.textMuted),
        const SizedBox(height: AppTheme.s12),
        Text(state.error!, style: AppTheme.bodyLight),
        const SizedBox(height: AppTheme.s16),
        GestureDetector(
          onTap: notifier.loadBundles,
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppTheme.brandRedLight, AppTheme.brandRedDark]),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM)),
              child: Text('Retry', style: AppTheme.buttonLabel)),
        ),
      ]));
    }

    if (state.filtered.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.search_off_rounded, size: 64,
            color: AppTheme.textMuted.withValues(alpha: 0.4)),
        const SizedBox(height: AppTheme.s16),
        Text('No bundles found',
            style: AppTheme.headingLight.copyWith(color: AppTheme.textSecondary)),
        const SizedBox(height: AppTheme.s8),
        Text('Try different search or filter',
            style: AppTheme.bodyLight.copyWith(color: AppTheme.textMuted)),
        const SizedBox(height: AppTheme.s20),
        GestureDetector(
          onTap: () {
            _searchCtrl.clear();
            setState(() {});
            ref.read(bundleProvider.notifier).clearAll();
          },
          child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
              decoration: BoxDecoration(
                  color: AppTheme.brandRedSurface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
                  border: Border.all(color: AppTheme.brandRed.withValues(alpha: 0.3))),
              child: Text('Clear Filters',
                  style: AppTheme.labelMedium.copyWith(color: AppTheme.brandRed))),
        ),
      ]));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
          AppTheme.s16, AppTheme.s4, AppTheme.s16, AppTheme.s32),
      itemCount: state.filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppTheme.s12),
      itemBuilder: (_, i) {
        final bundle = state.filtered[i];
        return BundleCard(
          bundle: bundle,
          onTap: () => _showDetail(context, bundle),
          onBuyTap: () {
            ref.read(bundleProvider.notifier).markPurchased(bundle.id);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('${bundle.name} added! Happy studying 🎉'),
                backgroundColor: AppTheme.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusS))));
          },
        );
      },
    );
  }

  void _showDetail(BuildContext context, BundleModel bundle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgWhite,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusXL))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (_, ctrl) => _BundleDetailSheet(bundle: bundle, ctrl: ctrl,
            onBuy: () {
              ref.read(bundleProvider.notifier).markPurchased(bundle.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${bundle.name} purchased! 🎉'),
                  backgroundColor: AppTheme.success,
                  behavior: SnackBarBehavior.floating));
            }),
      ),
    );
  }
}

// ── Bundle detail bottom sheet ────────────────────────────────────────────────
class _BundleDetailSheet extends StatelessWidget {
  const _BundleDetailSheet({
    required this.bundle,
    required this.ctrl,
    required this.onBuy,
  });
  final BundleModel bundle;
  final ScrollController ctrl;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) => Column(children: [
    // Handle
    Container(margin: const EdgeInsets.symmetric(vertical: 10),
        width: 36, height: 4,
        decoration: BoxDecoration(color: AppTheme.borderLight,
            borderRadius: BorderRadius.circular(2))),
    Expanded(
      child: ListView(controller: ctrl,
        padding: const EdgeInsets.fromLTRB(
            AppTheme.s20, AppTheme.s8, AppTheme.s20, AppTheme.s24),
        children: [
          // Category + Purchased badge row
          Row(children: [
            if (bundle.category != null)
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.brandRedSurface,
                      borderRadius: BorderRadius.circular(AppTheme.radiusS)),
                  child: Text(bundle.category!,
                      style: AppTheme.stepLabel.copyWith(color: AppTheme.brandRed))),
            const Spacer(),
            if (bundle.isPurchased) const PurchasedBadge(),
          ]),
          const SizedBox(height: AppTheme.s12),
          Text(bundle.name, style: AppTheme.headingLight),
          const SizedBox(height: AppTheme.s8),
          Text(bundle.description, style: AppTheme.bodyLight),
          const SizedBox(height: AppTheme.s16),
          // Stats
          Row(children: [
            if (bundle.courseCount > 0) ...[
              const Icon(Icons.play_circle_outline_rounded,
                  size: 16, color: AppTheme.brandRed),
              const SizedBox(width: 5),
              Text('${bundle.courseCount} Courses', style: AppTheme.labelMedium),
              const SizedBox(width: AppTheme.s16),
            ],
            const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
            const SizedBox(width: 4),
            Text('${bundle.rating}  (${bundle.reviewCount} reviews)',
                style: AppTheme.bodyLight),
          ]),
          const SizedBox(height: AppTheme.s24),
          // What's included
          Text("What's Included",
              style: AppTheme.labelMedium.copyWith(fontSize: 16)),
          const SizedBox(height: AppTheme.s12),
          ...[
            if (bundle.courseCount > 0) '${bundle.courseCount} structured courses',
            'Chapter-wise practice questions',
            'Performance analytics & tracking',
            'Mobile-friendly offline access',
            if (bundle.isFree || bundle.price == 0) 'Completely free — no payment needed',
          ].map((item) => Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.s8),
            child: Row(children: [
              Container(width: 22, height: 22,
                  decoration: BoxDecoration(color: AppTheme.brandRedSurface,
                      shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded,
                      size: 13, color: AppTheme.brandRed)),
              const SizedBox(width: 10),
              Expanded(child: Text(item, style: AppTheme.bodyLight)),
            ]),
          )),
          const SizedBox(height: AppTheme.s32),
          // CTA
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, children: [
                  if (bundle.isFree || bundle.price == 0)
                    Text('FREE', style: AppTheme.headingLight.copyWith(
                        color: AppTheme.success))
                  else ...[
                    Text('₹${bundle.price.toInt()}',
                        style: AppTheme.headingLight.copyWith(color: AppTheme.brandRed)),
                    if (bundle.hasDiscount)
                      Text('₹${bundle.originalPrice!.toInt()}',
                          style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textMuted,
                              decoration: TextDecoration.lineThrough)),
                  ],
                ]),
            const SizedBox(width: AppTheme.s16),
            Expanded(child: GestureDetector(
              onTap: bundle.isPurchased ? null : onBuy,
              child: Container(height: 48,
                decoration: BoxDecoration(
                    color: bundle.isPurchased ? AppTheme.success : null,
                    gradient: bundle.isPurchased ? null
                        : const LinearGradient(colors: [
                      AppTheme.brandRedLight, AppTheme.brandRedDark]),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    boxShadow: bundle.isPurchased ? [] : AppTheme.buttonShadow),
                child: Center(child: Text(
                    bundle.isPurchased ? '✓ Already Purchased'
                        : bundle.isFree ? 'Get for Free' : 'Buy Now',
                    style: const TextStyle(fontFamily: 'Poppins',
                        fontSize: 15, fontWeight: FontWeight.w700,
                        color: Colors.white))),
              ),
            )),
          ]),
        ],
      ),
    ),
  ]);
}