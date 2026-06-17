import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alogyan_prep/core/theme/app_theme.dart';
import 'package:alogyan_prep/features/onboarding/controllers/controllers.dart';
import 'package:alogyan_prep/features/bundle_listing/presentation/screens/bundle_listing_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth      = ref.watch(authProvider);
    final userModel = auth.userModel;
    final firstName = userModel?.firstName ?? '';
    final lastName  = userModel?.lastName  ?? '';
    final fullName  = [firstName, lastName]
        .where((s) => s.isNotEmpty)
        .join(' ');
    final greeting  = fullName.isNotEmpty ? fullName : (auth.email ?? 'Student');

    // Goal label for personalization
    final goalId    = userModel?.selectedExamGoalId ?? '';
    final goalLabel = _goalLabel(goalId);

    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.s20, vertical: AppTheme.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Top bar ────────────────────────────────────────────────
              Row(children: [
                Container(
                  width: 38, height: 38,
                  decoration: BoxDecoration(
                      color: AppTheme.brandRed,
                      borderRadius: BorderRadius.circular(AppTheme.radiusS)),
                  child: const Icon(Icons.school_rounded,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Text('Alogyan Prep',
                    style: AppTheme.labelMedium.copyWith(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                _SignOutButton(),
              ]),

              const SizedBox(height: AppTheme.s24),

              // ── Welcome card ───────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.s20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.brandRedLight, AppTheme.brandRedDark],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  boxShadow: AppTheme.buttonShadow,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hi, $greeting! 👋',
                          style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Text(
                        goalLabel.isNotEmpty
                            ? 'Keep going with your $goalLabel prep 🚀'
                            : 'Ready to study today?',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85)),
                      ),
                    ]),
              ),

              const SizedBox(height: AppTheme.s24),

              // ── Section title ──────────────────────────────────────────
              Text('Quick Actions',
                  style: AppTheme.labelMedium.copyWith(fontSize: 15)),
              const SizedBox(height: AppTheme.s12),

              // ── Quick action cards ─────────────────────────────────────
              _ActionCard(
                icon:     Icons.menu_book_rounded,
                title:    'Study Bundles',
                subtitle: 'Browse mock tests, PDF notes & more',
                color:    AppTheme.brandRed,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const BundleListingScreen()),
                ),
              ),
              const SizedBox(height: AppTheme.s12),

              _ActionCard(
                icon:     Icons.quiz_rounded,
                title:    'Mock Test',
                subtitle: 'Practice with full-length tests',
                color:    const Color(0xFF6366F1),
                onTap:    () => _comingSoon(context, 'Mock Test'),
              ),
              const SizedBox(height: AppTheme.s12),

              _ActionCard(
                icon:     Icons.auto_stories_rounded,
                title:    'Daily Study',
                subtitle: 'Chapter-wise notes & revision',
                color:    const Color(0xFF059669),
                onTap:    () => _comingSoon(context, 'Daily Study'),
              ),
              const SizedBox(height: AppTheme.s12),

              _ActionCard(
                icon:     Icons.trending_up_rounded,
                title:    'Performance',
                subtitle: 'Track your progress & analytics',
                color:    const Color(0xFFF59E0B),
                onTap:    () => _comingSoon(context, 'Performance'),
              ),

              const SizedBox(height: AppTheme.s24),

              // ── Profile info strip ─────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(AppTheme.s16),
                decoration: BoxDecoration(
                    color: AppTheme.bgWhite,
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    boxShadow: AppTheme.cardShadow),
                child: Row(children: [
                  // Avatar circle
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                        color: AppTheme.brandRedSurface,
                        shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        firstName.isNotEmpty
                            ? firstName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.brandRed),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.s12),
                  Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fullName.isNotEmpty ? fullName : 'Student',
                          style: AppTheme.labelMedium,
                        ),
                        Text(
                          auth.email ?? '',
                          style: AppTheme.bodySmall
                              .copyWith(color: AppTheme.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ])),
                  if (goalLabel.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: AppTheme.brandRedSurface,
                          borderRadius:
                          BorderRadius.circular(AppTheme.radiusCircle)),
                      child: Text(goalLabel,
                          style: AppTheme.stepLabel
                              .copyWith(color: AppTheme.brandRed)),
                    ),
                ]),
              ),

              const SizedBox(height: AppTheme.s32),
            ],
          ),
        ),
      ),
    );
  }

  String _goalLabel(String id) => switch (id) {
    'jee'     => 'JEE',
    'neet'    => 'NEET',
    'upsc'    => 'UPSC',
    'ssc'     => 'SSC',
    'banking' => 'Banking',
    'cat'     => 'CAT',
    _         => '',
  };

  void _comingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$feature coming soon!'),
      backgroundColor: AppTheme.brandRed,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusS)),
    ));
  }
}

// ── Sign out button — standalone so it doesn't rebuild the whole screen ──────
class _SignOutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppTheme.bgWhite,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusL)),
            title: Text('Sign Out',
                style: AppTheme.headingLight.copyWith(fontSize: 18)),
            content: Text('Are you sure you want to sign out?',
                style: AppTheme.bodyLight),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel',
                      style: AppTheme.labelMedium
                          .copyWith(color: AppTheme.textMuted))),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text('Sign Out',
                      style: AppTheme.labelMedium
                          .copyWith(color: AppTheme.brandRed))),
            ],
          ),
        );
        if (confirm == true && context.mounted) {
          // signOut() resets flow + sets unauthenticated.
          // _AuthGate watches authProvider and routes to OnboardingScreen
          // automatically — no Navigator call needed here.
          await ref.read(authProvider.notifier).signOut();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.bgWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.logout_rounded, size: 14, color: AppTheme.brandRed),
          const SizedBox(width: 5),
          Text('Sign out',
              style: AppTheme.labelMedium
                  .copyWith(color: AppTheme.brandRed, fontSize: 12)),
        ]),
      ),
    );
  }
}

// ── Reusable action card ──────────────────────────────────────────────────────
class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData     icon;
  final String       title, subtitle;
  final Color        color;
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
              borderRadius: BorderRadius.circular(AppTheme.radiusM)),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: AppTheme.s16),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.labelMedium),
                Text(subtitle,
                    style: AppTheme.bodySmall
                        .copyWith(color: AppTheme.textMuted)),
              ]),
        ),
        const Icon(Icons.arrow_forward_ios_rounded,
            size: 14, color: AppTheme.textMuted),
      ]),
    ),
  );
}