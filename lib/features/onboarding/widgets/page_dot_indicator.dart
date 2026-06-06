import 'package:flutter/material.dart';

// Clean absolute import to pull token parameters smoothly
import 'package:alogyan_prep/core/theme/app_theme.dart';

/// A row of animated page indicator dots.
///
/// The active dot stretches horizontally from [AppTheme.dotWidthInactive]
/// to [AppTheme.dotWidthActive] using an [AnimatedContainer].
class PageDotIndicator extends StatelessWidget {
  const PageDotIndicator({
    super.key,
    required this.totalPages,
    required this.currentIndex,
  })  : assert(totalPages > 0, 'totalPages must be > 0'),
        assert(
        currentIndex >= 0 && currentIndex < totalPages,
        'currentIndex out of range',
        );

  final int totalPages;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalPages, (i) {
        final bool isActive = i == currentIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3.0),
          child: AnimatedContainer(
            duration: AppTheme.dotAnimDuration,
            curve: AppTheme.dotAnimCurve,
            width: isActive
                ? AppTheme.dotWidthActive
                : AppTheme.dotWidthInactive,
            height: AppTheme.dotHeight,
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.dotActive
                  : AppTheme.dotInactive,
              borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
            ),
          ),
        );
      }),
    );
  }
}