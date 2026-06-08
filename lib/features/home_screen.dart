import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alogyan_prep/core/theme/app_theme.dart';
import 'package:alogyan_prep/features/onboarding/controllers/controllers.dart';
import 'package:alogyan_prep/features/onboarding/data/onboarding_model.dart';
import 'package:alogyan_prep/features/bundles/presentation/screens/bundle_listing_screen.dart';

/// Real Home Screen — navigates to Bundle Listing (ALO-002).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    ref.listen(authProvider, (_, next) {
      if (next.status == AuthStatus.unauthenticated) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const _LoginRedirect()),
              (_) => false,
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.brandRed,
                    borderRadius: BorderRadius.circular(AppTheme.radiusS),
                  ),
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Text('Alogyan Prep',
                    style: AppTheme.labelMedium.copyWith(
                        fontSize: 17, fontWeight: FontWeight.w700)),
                const Spacer(),
                GestureDetector(
                  onTap: () => ref.read(authProvider.notifier).signOut(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppTheme.bgWhite,
                      borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
                      border: Border.all(color: AppTheme.borderLight),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.logout_rounded, size: 14, color: AppTheme.brandRed),
                      const SizedBox(width: 5),
                      Text('Sign out',
                          style: AppTheme.labelMedium.copyWith(
                              color: AppTheme.brandRed, fontSize: 12)),
                    ]),
                  ),
                ),
              ]),

              const SizedBox(height: AppTheme.s24),

              // ── Welcome ───────────────────────────────────────────────────
              Text('Welcome back! 👋',
                  style: AppTheme.displayLight.copyWith(fontSize: 24)),
              const SizedBox(height: AppTheme.s4),
              Text(auth.email ?? '',
                  style: AppTheme.bodyLight.copyWith(color: AppTheme.textMuted)),

              const SizedBox(height: AppTheme.s32),

              // ── Quick actions ─────────────────────────────────────────────
              _QuickAction(
                icon: Icons.menu_book_rounded,
                title: 'Study Bundles',
                subtitle: 'Browse mock tests, PDF notes & more',
                color: AppTheme.brandRed,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BundleListingScreen()),
                ),
              ),
              const SizedBox(height: AppTheme.s12),
              _QuickAction(
                icon: Icons.quiz_rounded,
                title: 'Daily Quiz',
                subtitle: 'Test yourself with today\'s questions',
                color: const Color(0xFF6366F1),
                onTap: () {},
              ),
              const SizedBox(height: AppTheme.s12),
              _QuickAction(
                icon: Icons.trending_up_rounded,
                title: 'Performance',
                subtitle: 'Track your progress & analytics',
                color: const Color(0xFF059669),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(AppTheme.s16),
      decoration: BoxDecoration(
        color: AppTheme.bgWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: AppTheme.s16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: AppTheme.labelMedium),
            Text(subtitle,
                style: AppTheme.bodySmall.copyWith(color: AppTheme.textMuted)),
          ]),
        ),
        const Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: AppTheme.textMuted),
      ]),
    ),
  );
}

class _LoginRedirect extends StatelessWidget {
  const _LoginRedirect();
  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: AppTheme.bgSoft,
    body: Center(
        child: CircularProgressIndicator(color: AppTheme.brandRed)),
  );
}