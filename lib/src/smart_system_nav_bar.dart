import 'package:flutter/widgets.dart';

import 'bottom_safe_area_behavior.dart';
import 'smart_safe_area_insets.dart';
import 'smart_safe_area_scope.dart';

/// Wraps an app bottom bar so its **color** fills behind the system nav, while
/// the bar's children (tabs, buttons) are inset only when 3-button nav is on.
///
/// This is the same pattern as a home tab bar that stays flush on gesture
/// phones and lifts above Back / Home / Recents on 3-button Android.
///
/// ```dart
/// bottomNavigationBar: SmartSystemNavBar(
///   color: Colors.white,
///   child: MyTabRow(),
/// )
/// ```
class SmartSystemNavBar extends StatelessWidget {
  /// Creates a system-nav-aware bottom bar.
  const SmartSystemNavBar({
    super.key,
    required this.child,
    this.color,
    this.bottomBehavior,
    this.fillSystemNav = true,
    this.threeButtonNavThreshold,
  });

  /// The bar content (tab row, CTA, etc.). Not inset on gesture devices.
  final Widget child;

  /// Color painted behind [child] and, when [fillSystemNav] is true, in the
  /// 3-button system-nav region.
  ///
  /// If null, the region is transparent so the scaffold background shows.
  final Color? color;

  /// Bottom inset policy. `null` inherits from [SmartSafeAreaScope].
  final BottomSafeAreaBehavior? bottomBehavior;

  /// When `true` (default), the 3-button inset is filled with [color] so the
  /// bar looks continuous behind the system buttons.
  final bool fillSystemNav;

  /// Override the 3-button detection threshold.
  final double? threeButtonNavThreshold;

  @override
  Widget build(BuildContext context) {
    final inherited = SmartSafeAreaScope.of(context);
    final insets = SmartSafeAreaInsets.of(
      context,
      applyTop: false,
      applyLeft: false,
      applyRight: false,
      applyBottom: true,
      bottomBehavior: bottomBehavior ?? inherited.bottomBehavior,
      threeButtonNavThreshold: threeButtonNavThreshold,
      extraPadding: EdgeInsets.zero,
      minimum: EdgeInsets.zero,
      keyboardAware: false,
    );
    final bottom = insets.contentBottom;

    // Material BottomNavigationBar reads viewPadding, and NavigationBar reads
    // padding. Strip both so this bar adds the smart inset once.
    final media = MediaQuery.of(context);
    Widget bar = MediaQuery(
      data: media.copyWith(
        padding: media.padding.copyWith(bottom: 0),
        viewPadding: media.viewPadding.copyWith(bottom: 0),
      ),
      child: child,
    );
    if (color != null) {
      bar = ColoredBox(color: color!, child: bar);
    }

    if (bottom <= 0 || !fillSystemNav) {
      return bar;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        bar,
        ColoredBox(
          color: color ?? const Color(0x00000000),
          child: SizedBox(height: bottom, width: double.infinity),
        ),
      ],
    );
  }
}
