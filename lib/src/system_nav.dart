import 'dart:math' as math;
import 'dart:ui' show FlutterView;

import 'package:flutter/widgets.dart';

import 'smart_safe_area_scope.dart';
import 'smart_safe_area_simulation_scope.dart';
import 'system_nav_mode.dart';

/// Detects the system navigation style from [MediaQuery] / [FlutterView].
///
/// Android 3-button nav is typically ~48 dp. iPhone home-indicator and gesture
/// nav insets are smaller (~16–34). Only the larger inset is treated as a
/// visible 3-button bar.
///
/// On Android edge-to-edge, [MediaQueryData.padding] can be zero while
/// [MediaQueryData.viewPadding] still carries the inset. This API always
/// prefers [viewPadding], with a [FlutterView] fallback.
abstract final class SystemNav {
  /// Minimum bottom inset (logical pixels) treated as 3-button navigation.
  ///
  /// Matches the threshold used by production edge-to-edge apps: values below
  /// this are treated as gesture / home-indicator navigation.
  static const double defaultThreeButtonThreshold = 40;

  /// Raw bottom system inset in logical pixels.
  ///
  /// This is the physical inset (3-button bar **or** home indicator), not the
  /// content inset. Use [contentBottomInset] when padding widgets.
  static double rawBottomInset(BuildContext context) {
    final mqBottom = MediaQuery.viewPaddingOf(context).bottom;
    if (SmartSafeAreaSimulationScope.lockedOf(context)) {
      return mqBottom;
    }
    final live = liveViewPadding(context);
    if (live != null) {
      final stale = (live.bottom - mqBottom).abs() > 0.5;
      // A live status-bar or side inset means this view is reporting real
      // metrics, so a bottom of 0 is a real gesture/none result — not a
      // missing value. An all-zero live padding is ignored so an ancestor
      // MediaQuery (tests, simulator) stays in charge.
      final liveHasMetrics =
          live.top > 0 || live.bottom > 0 || live.left > 0 || live.right > 0;
      if (stale && (liveHasMetrics || mqBottom <= 0)) {
        return live.bottom;
      }
    }
    if (mqBottom > 0) return mqBottom;
    return live?.bottom ?? 0;
  }

  /// Current [FlutterView] padding in logical pixels, or `null` if unknown.
  ///
  /// Used when Android swaps the 3-button / gesture overlay and [MediaQuery]
  /// still holds the previous inset.
  static EdgeInsets? liveViewPadding(BuildContext? context) {
    FlutterView? view;
    if (context != null && context.mounted) {
      view = View.maybeOf(context);
    }
    view ??= WidgetsBinding.instance.platformDispatcher.implicitView;
    if (view == null) {
      final views = WidgetsBinding.instance.platformDispatcher.views;
      if (views.isNotEmpty) view = views.first;
    }
    if (view == null || view.devicePixelRatio <= 0) return null;
    final physical = EdgeInsets.fromLTRB(
      math.max(view.viewPadding.left, view.padding.left).toDouble(),
      math.max(view.viewPadding.top, view.padding.top).toDouble(),
      math.max(view.viewPadding.right, view.padding.right).toDouble(),
      math.max(view.viewPadding.bottom, view.padding.bottom).toDouble(),
    );
    return physical / view.devicePixelRatio;
  }

  /// Resolved 3-button threshold from [SmartSafeAreaScope] or the default.
  static double thresholdOf(BuildContext context) {
    return SmartSafeAreaScope.maybeOf(context)?.threeButtonNavThreshold ??
        defaultThreeButtonThreshold;
  }

  /// Detected [SystemNavMode] for the current view.
  static SystemNavMode modeOf(BuildContext context, {double? threshold}) {
    final raw = rawBottomInset(context);
    final min = threshold ?? thresholdOf(context);
    if (raw <= 0) return SystemNavMode.none;
    if (raw >= min) return SystemNavMode.threeButton;
    return SystemNavMode.gesture;
  }

  /// Whether a 3-button system navigation bar is showing.
  static bool isThreeButton(BuildContext context, {double? threshold}) {
    return modeOf(context, threshold: threshold) == SystemNavMode.threeButton;
  }

  /// Whether the device is using gesture / home-indicator navigation.
  static bool isGesture(BuildContext context, {double? threshold}) {
    return modeOf(context, threshold: threshold) == SystemNavMode.gesture;
  }

  /// Bottom inset that content (buttons, text, images) should use.
  ///
  /// - 3-button nav: the full [rawBottomInset]
  /// - gesture / none: `0` (content stays flush; the background may still
  ///   draw behind the home indicator)
  static double contentBottomInset(
    BuildContext context, {
    double? threshold,
  }) {
    final raw = rawBottomInset(context);
    final min = threshold ?? thresholdOf(context);
    if (raw < min) return 0;
    return raw;
  }
}
