import 'package:flutter/widgets.dart';

import 'smart_safe_area_simulation_scope.dart';
import 'system_nav.dart';

/// Preset insets for [SmartSafeAreaSimulator].
enum SimulatedSystemNav {
  /// Use the real device [MediaQuery] (no override).
  device,

  /// Typical iPhone home indicator / Android gesture inset (~34).
  gesture,

  /// Typical Android 3-button navigation inset (~48).
  threeButton,

  /// No bottom inset (desktop / web).
  none,

  /// Use [SmartSafeAreaSimulator.customBottom].
  custom,
}

/// Overrides [MediaQuery.viewPadding] so you can preview 3-button vs gesture
/// layouts on any device, including desktop and the iOS Simulator.
///
/// Useful in example apps, golden tests, and widget tests.
///
/// ```dart
/// SmartSafeAreaSimulator(
///   nav: SimulatedSystemNav.threeButton,
///   child: MyApp(),
/// )
/// ```
class SmartSafeAreaSimulator extends StatelessWidget {
  /// Creates a simulator that overrides the bottom system inset.
  const SmartSafeAreaSimulator({
    super.key,
    this.nav = SimulatedSystemNav.device,
    this.customBottom = 48,
    this.top,
    this.left = 0,
    this.right = 0,
    required this.child,
  });

  /// Which system nav to pretend is active.
  final SimulatedSystemNav nav;

  /// Bottom inset used when [nav] is [SimulatedSystemNav.custom].
  final double customBottom;

  /// Optional top inset override (status bar). `null` keeps the real value.
  final double? top;

  /// Left inset override.
  final double left;

  /// Right inset override.
  final double right;

  /// The subtree that should see the simulated insets.
  final Widget child;

  /// Logical pixels used for [SimulatedSystemNav.gesture].
  static const double gestureInset = 34;

  /// Logical pixels used for [SimulatedSystemNav.threeButton].
  static const double threeButtonInset = 48;

  /// Resolves the simulated bottom inset, or `null` to keep the device value.
  double? get resolvedBottom {
    switch (nav) {
      case SimulatedSystemNav.device:
        return null;
      case SimulatedSystemNav.gesture:
        return gestureInset;
      case SimulatedSystemNav.threeButton:
        return threeButtonInset;
      case SimulatedSystemNav.none:
        return 0;
      case SimulatedSystemNav.custom:
        return customBottom;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locked = nav != SimulatedSystemNav.device || top != null;
    Widget built = child;
    if (locked) {
      final mq = MediaQuery.of(context);
      final bottom = resolvedBottom ?? mq.viewPadding.bottom;
      final nextViewPadding = mq.viewPadding.copyWith(
        top: top ?? mq.viewPadding.top,
        bottom: bottom,
        left: left,
        right: right,
      );
      final nextPadding = mq.padding.copyWith(
        top: top ?? mq.padding.top,
        bottom: bottom >= SystemNav.defaultThreeButtonThreshold ? bottom : 0,
        left: left,
        right: right,
      );
      built = MediaQuery(
        data: mq.copyWith(
          viewPadding: nextViewPadding,
          padding: nextPadding,
        ),
        child: child,
      );
    }

    return SmartSafeAreaSimulationScope(
      locked: locked,
      child: built,
    );
  }
}
