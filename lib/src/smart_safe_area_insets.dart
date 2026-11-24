import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'bottom_safe_area_behavior.dart';
import 'smart_safe_area_config.dart';
import 'smart_safe_area_scope.dart';
import 'system_nav.dart';
import 'system_nav_mode.dart';

/// Resolved safe-area insets for the current view and [SmartSafeAreaConfig].
///
/// Use [SmartSafeAreaInsets.of] when you need the numbers (for example to pad
/// a scroll view) without wrapping a widget.
@immutable
class SmartSafeAreaInsets {
  /// Creates resolved insets. Prefer [SmartSafeAreaInsets.of].
  const SmartSafeAreaInsets({
    required this.navMode,
    required this.raw,
    required this.content,
    required this.config,
  });

  /// Detected system navigation mode.
  final SystemNavMode navMode;

  /// Raw system [viewPadding] (status bar, notches, home indicator / 3-button).
  final EdgeInsets raw;

  /// Padding that **content** (buttons, text, images) should use.
  ///
  /// [content.bottom] is `0` on gesture devices when [config] uses
  /// [BottomSafeAreaBehavior.auto].
  final EdgeInsets content;

  /// Config that produced these insets.
  final SmartSafeAreaConfig config;

  /// Whether a 3-button system nav bar is showing.
  bool get isThreeButton => navMode == SystemNavMode.threeButton;

  /// Whether the device is using gesture / home-indicator navigation.
  bool get isGesture => navMode == SystemNavMode.gesture;

  /// Raw bottom system inset.
  double get rawBottom => raw.bottom;

  /// Content bottom inset after behavior + keyboard rules.
  double get contentBottom => content.bottom;

  /// Resolves insets from [context].
  ///
  /// Per-call arguments override the inherited [SmartSafeAreaConfig].
  static SmartSafeAreaInsets of(
    BuildContext context, {
    SmartSafeAreaConfig? config,
    BottomSafeAreaBehavior? bottomBehavior,
    bool? applyTop,
    bool? applyLeft,
    bool? applyRight,
    bool? applyBottom,
    double? threeButtonNavThreshold,
    EdgeInsets? minimum,
    EdgeInsets? extraPadding,
    bool? keyboardAware,
  }) {
    final inherited = config ?? SmartSafeAreaScope.of(context);
    final resolved = inherited.copyWith(
      bottomBehavior: bottomBehavior,
      applyTop: applyTop,
      applyLeft: applyLeft,
      applyRight: applyRight,
      applyBottom: applyBottom,
      threeButtonNavThreshold: threeButtonNavThreshold,
      minimum: minimum,
      extraPadding: extraPadding,
      keyboardAware: keyboardAware,
    );

    final mq = MediaQuery.of(context);
    final viewPadding = mq.viewPadding;
    final rawBottom = SystemNav.rawBottomInset(context);
    final raw = EdgeInsets.fromLTRB(
      viewPadding.left,
      viewPadding.top,
      viewPadding.right,
      rawBottom,
    );

    final navMode = SystemNav.modeOf(
      context,
      threshold: resolved.threeButtonNavThreshold,
    );

    if (!resolved.appliesToCurrentPlatform) {
      return SmartSafeAreaInsets(
        navMode: navMode,
        raw: raw,
        content: EdgeInsets.zero,
        config: resolved,
      );
    }

    final smartBottom = _resolveBottom(
      rawBottom: rawBottom,
      behavior: resolved.bottomBehavior,
      apply: resolved.applyBottom,
      threshold: resolved.threeButtonNavThreshold,
    );

    final keyboard = resolved.keyboardAware ? mq.viewInsets.bottom : 0.0;
    final bottom = math.max(smartBottom, keyboard);

    final content = EdgeInsets.fromLTRB(
      _side(
        apply: resolved.applyLeft,
        system: raw.left,
        minimum: resolved.minimum.left,
        extra: resolved.extraPadding.left,
      ),
      _side(
        apply: resolved.applyTop,
        system: raw.top,
        minimum: resolved.minimum.top,
        extra: resolved.extraPadding.top,
      ),
      _side(
        apply: resolved.applyRight,
        system: raw.right,
        minimum: resolved.minimum.right,
        extra: resolved.extraPadding.right,
      ),
      _side(
        apply: true,
        system: bottom,
        minimum: resolved.minimum.bottom,
        extra: resolved.extraPadding.bottom,
      ),
    );

    return SmartSafeAreaInsets(
      navMode: navMode,
      raw: raw,
      content: content,
      config: resolved,
    );
  }

  /// Convenience: content padding only.
  static EdgeInsets paddingOf(
    BuildContext context, {
    SmartSafeAreaConfig? config,
    BottomSafeAreaBehavior? bottomBehavior,
    bool? applyTop,
    bool? applyLeft,
    bool? applyRight,
    bool? applyBottom,
    bool? keyboardAware,
  }) {
    return of(
      context,
      config: config,
      bottomBehavior: bottomBehavior,
      applyTop: applyTop,
      applyLeft: applyLeft,
      applyRight: applyRight,
      applyBottom: applyBottom,
      keyboardAware: keyboardAware,
    ).content;
  }

  /// Convenience: content bottom inset only.
  static double bottomOf(
    BuildContext context, {
    BottomSafeAreaBehavior? bottomBehavior,
    bool? applyBottom,
    bool? keyboardAware,
  }) {
    return of(
      context,
      bottomBehavior: bottomBehavior,
      applyBottom: applyBottom,
      keyboardAware: keyboardAware,
    ).contentBottom;
  }

  static double _resolveBottom({
    required double rawBottom,
    required BottomSafeAreaBehavior behavior,
    required bool apply,
    required double threshold,
  }) {
    if (!apply) return 0;
    switch (behavior) {
      case BottomSafeAreaBehavior.auto:
        return rawBottom >= threshold ? rawBottom : 0;
      case BottomSafeAreaBehavior.always:
        return rawBottom;
      case BottomSafeAreaBehavior.never:
        return 0;
    }
  }

  static double _side({
    required bool apply,
    required double system,
    required double minimum,
    required double extra,
  }) {
    if (!apply) return extra;
    return math.max(system, minimum) + extra;
  }
}

/// Shortcuts for reading smart insets from a [BuildContext].
extension SmartSafeAreaContext on BuildContext {
  /// Resolved [SmartSafeAreaInsets] for this context.
  SmartSafeAreaInsets get smartSafeArea => SmartSafeAreaInsets.of(this);

  /// Detected [SystemNavMode] for this context.
  SystemNavMode get systemNavMode => SystemNav.modeOf(this);
}
