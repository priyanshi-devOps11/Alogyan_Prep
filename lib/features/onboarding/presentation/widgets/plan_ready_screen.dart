import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alogyan_prep/core/theme/app_theme.dart';
import 'package:alogyan_prep/features/onboarding/controllers/controllers.dart';
import 'package:alogyan_prep/features/onboarding/data/onboarding_model.dart';
import 'package:alogyan_prep/features/home_screen.dart';

class PlanReadyScreen extends ConsumerWidget {
  const PlanReadyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flow = ref.watch(flowProvider);
    final auth = ref.watch(authProvider);
    final aN   = ref.read(authProvider.notifier);

    final goal = ExamGoals.all
        .where((g) => g.id == flow.profile.examGoalId)
        .firstOrNull;

    return Scaffold(
      backgroundColor: AppTheme.bgSoft,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.s24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: AppTheme.s32),

            // Illustration
            Center(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.26,
                child: Image.asset(
                  'assets/images/plan_ready_illustration.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    height: MediaQuery.sizeOf(context).height * 0.26,
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppTheme.brandRedSurface, AppTheme.bgCardAlt]),
                        borderRadius: BorderRadius.circular(AppTheme.radiusXL)),
                    child: Center(child: Icon(Icons.emoji_events_rounded,
                        size: 72, color: AppTheme.brandRed.withValues(alpha: 0.5))),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppTheme.s24),

            // Assessment complete badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(AppTheme.radiusCircle)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.check_circle_rounded,
                    size: 14, color: Color(0xFF22C55E)),
                const SizedBox(width: 6),
                Text('Assessment Complete',
                    style: AppTheme.stepLabel.copyWith(color: const Color(0xFF22C55E))),
              ]),
            ),

            const SizedBox(height: AppTheme.s16),
            Text('Your Personalized\nStudy Plan Is Ready',
                style: AppTheme.displayLight),
            const SizedBox(height: AppTheme.s12),
            Text(
              "We've crunched the numbers and analysed your profile from thousands of students similar to yours.",
              style: AppTheme.bodyLight,
            ),
            const SizedBox(height: AppTheme.s20),

            // Plan chips
            Row(children: [
              Expanded(child: _PlanChip(
                  label: goal?.label ?? 'Your Goal',
                  icon: Icons.flag_outlined,
                  color: AppTheme.brandRed)),
              const SizedBox(width: AppTheme.s12),
              Expanded(child: _PlanChip(
                  label: '12 Modules',
                  icon: Icons.layers_outlined,
                  color: const Color(0xFF6366F1))),
            ]),
            const SizedBox(height: AppTheme.s12),
            Row(children: [
              Expanded(child: _PlanChip(
                  label: '2.5 Hours/day',
                  icon: Icons.timer_outlined,
                  color: const Color(0xFF059669))),
              const SizedBox(width: AppTheme.s12),
              Expanded(child: _PlanChip(
                  label: 'Adaptive AI',
                  icon: Icons.auto_awesome_rounded,
                  color: const Color(0xFFF59E0B))),
            ]),

            const Spacer(),

            // CTA
            SizedBox(
              width: double.infinity, height: 52,
              child: GestureDetector(
                onTap: auth.isLoading ? null : () async {
                  final uid = auth.userId;
                  if (uid != null) {
                    await aN.saveProfile(uid: uid, data: flow.profile.toMap());
                  }
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (_) => false,
                    );
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                      gradient: auth.isLoading
                          ? LinearGradient(colors: [
                        AppTheme.brandRedDark.withValues(alpha: 0.5),
                        AppTheme.brandRedDark.withValues(alpha: 0.5)])
                          : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppTheme.brandRedLight, AppTheme.brandRedDark]),
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      boxShadow: auth.isLoading ? [] : AppTheme.buttonShadow),
                  child: Center(
                    child: auth.isLoading
                        ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(Colors.white)))
                        : Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('Start Learning', style: AppTheme.buttonLabel),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 18),
                    ]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.s24),
          ]),
        ),
      ),
    );
  }
}

class _PlanChip extends StatelessWidget {
  const _PlanChip({required this.label, required this.icon, required this.color});
  final String label; final IconData icon; final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppTheme.s12),
    decoration: BoxDecoration(color: AppTheme.bgWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: AppTheme.cardShadow),
    child: Row(children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 6),
      Expanded(child: Text(label,
          style: AppTheme.labelMedium.copyWith(fontSize: 12))),
    ]),
  );
}