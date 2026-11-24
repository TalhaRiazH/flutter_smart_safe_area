import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'bottom_safe_area_behavior.dart';
import 'system_nav.dart';

/// App-wide defaults for [SmartSafeArea], [SmartSafeAreaScaffold], and
/// [SmartSafeAreaHost].
///
/// Wrap your app with [SmartSafeAreaHost] (or [SmartSafeAreaScope]) so every
/// screen inherits these values. Individual widgets can still override them.
@immutable
class SmartSafeAreaConfig {
  /// Creates a configuration. All values have production-safe defaults.
  ///
  /// At least one of [applyOnAndroid] or [applyOnIOS] must be `true`.
  const SmartSafeAreaConfig({
    this.bottomBehavior = BottomSafeAreaBehavior.auto,
    this.extendBackground = true,
    this.applyTop = true,
    this.applyLeft = true,
    this.applyRight = true,
    this.applyBottom = true,
    this.applyOnAndroid = true,
    this.applyOnIOS = true,
    this.threeButtonNavThreshold = SystemNav.defaultThreeButtonThreshold,
    this.minimum = EdgeInsets.zero,
    this.extraPadding = EdgeInsets.zero,
    this.keyboardAware = false,
    this.adaptExistingSafeArea = true,
    this.enableEdgeToEdge = true,
    this.letterboxColor,
    this.topSafeAreaColor,
    this.bottomSafeAreaColor,
    this.leftSafeAreaColor,
    this.rightSafeAreaColor,
  }) : assert(
          applyOnAndroid || applyOnIOS,
          'At least one of applyOnAndroid or applyOnIOS must be true.',
        );

  /// Package defaults used when no [SmartSafeAreaScope] is above the widget.
  static const SmartSafeAreaConfig defaults = SmartSafeAreaConfig();

  /// When to inset content from the bottom system nav.
  ///
  /// Defaults to [BottomSafeAreaBehavior.auto]: inset only for 3-button nav.
  final BottomSafeAreaBehavior bottomBehavior;

  /// When `true` (default), background color / image / gradient draws behind
  /// the system bars. Only in-screen elements (buttons, text, images) are
  /// inset.
  ///
  /// When `false`, the entire screen — including the background — is inset
  /// and the unsafe region is filled with [letterboxColor].
  final bool extendBackground;

  /// Whether to apply the top inset (status bar / notch). Defaults to `true`.
  final bool applyTop;

  /// Whether to apply the left inset. Defaults to `true`.
  final bool applyLeft;

  /// Whether to apply the right inset. Defaults to `true`.
  final bool applyRight;

  /// Master switch for the bottom inset. Defaults to `true`.
  ///
  /// Combined with [bottomBehavior] to decide the actual content padding.
  final bool applyBottom;

  /// When `true` (default), smart insets apply on Android.
  ///
  /// Set to `false` to leave Android layouts unchanged. At least one of
  /// [applyOnAndroid] or [applyOnIOS] must stay `true`.
  final bool applyOnAndroid;

  /// When `true` (default), smart insets apply on iOS.
  ///
  /// Set to `false` to leave iPhone / iPad layouts unchanged. At least one of
  /// [applyOnAndroid] or [applyOnIOS] must stay `true`.
  final bool applyOnIOS;

  /// Whether this config applies on [platform].
  ///
  /// Android and iOS follow [applyOnAndroid] / [applyOnIOS]. Other platforms
  /// (web desktop, macOS, Windows, Linux) stay enabled.
  bool appliesTo(TargetPlatform platform) {
    return switch (platform) {
      TargetPlatform.android => applyOnAndroid,
      TargetPlatform.iOS => applyOnIOS,
      _ => true,
    };
  }

  /// Whether this config applies on the current [defaultTargetPlatform].
  bool get appliesToCurrentPlatform => appliesTo(defaultTargetPlatform);

  /// Minimum bottom inset treated as 3-button navigation. Defaults to `40`.
  final double threeButtonNavThreshold;

  /// Minimum padding on each side, same idea as Flutter's [SafeArea.minimum].
  final EdgeInsets minimum;

  /// Extra padding added on top of the resolved system insets.
  final EdgeInsets extraPadding;

  /// When `true`, the bottom content inset is at least the keyboard height
  /// ([MediaQueryData.viewInsets.bottom]).
  final bool keyboardAware;

  /// When `true` (default), [SmartSafeAreaHost] rewrites
  /// [MediaQueryData.padding.bottom] to the **smart** content inset so existing
  /// Flutter [SafeArea] widgets pick up 3-button vs gesture detection.
  final bool adaptExistingSafeArea;

  /// When `true` (default), [SmartSafeAreaHost] paints a transparent
  /// edge-to-edge [SystemUiOverlayStyle] so backgrounds can draw behind the
  /// system bars.
  final bool enableEdgeToEdge;

  /// Color painted in the unsafe region when [extendBackground] is `false`.
  ///
  /// If null, the scaffold / widget background color is used, then black.
  final Color? letterboxColor;

  /// Color painted in the top inset (status bar / notch). `null` leaves the
  /// background visible there.
  final Color? topSafeAreaColor;

  /// Color painted in the bottom inset (3-button system nav). `null` leaves
  /// the background visible there. Gesture / home-indicator devices stay
  /// unpainted when [bottomBehavior] is [BottomSafeAreaBehavior.auto].
  final Color? bottomSafeAreaColor;

  /// Color painted in the left inset. `null` leaves the background visible.
  final Color? leftSafeAreaColor;

  /// Color painted in the right inset. `null` leaves the background visible.
  final Color? rightSafeAreaColor;

  /// Returns a copy with the given fields replaced.
  SmartSafeAreaConfig copyWith({
    BottomSafeAreaBehavior? bottomBehavior,
    bool? extendBackground,
    bool? applyTop,
    bool? applyLeft,
    bool? applyRight,
    bool? applyBottom,
    bool? applyOnAndroid,
    bool? applyOnIOS,
    double? threeButtonNavThreshold,
    EdgeInsets? minimum,
    EdgeInsets? extraPadding,
    bool? keyboardAware,
    bool? adaptExistingSafeArea,
    bool? enableEdgeToEdge,
    Color? letterboxColor,
    bool clearLetterboxColor = false,
    Color? topSafeAreaColor,
    bool clearTopSafeAreaColor = false,
    Color? bottomSafeAreaColor,
    bool clearBottomSafeAreaColor = false,
    Color? leftSafeAreaColor,
    bool clearLeftSafeAreaColor = false,
    Color? rightSafeAreaColor,
    bool clearRightSafeAreaColor = false,
  }) {
    return SmartSafeAreaConfig(
      bottomBehavior: bottomBehavior ?? this.bottomBehavior,
      extendBackground: extendBackground ?? this.extendBackground,
      applyTop: applyTop ?? this.applyTop,
      applyLeft: applyLeft ?? this.applyLeft,
      applyRight: applyRight ?? this.applyRight,
      applyBottom: applyBottom ?? this.applyBottom,
      applyOnAndroid: applyOnAndroid ?? this.applyOnAndroid,
      applyOnIOS: applyOnIOS ?? this.applyOnIOS,
      threeButtonNavThreshold:
          threeButtonNavThreshold ?? this.threeButtonNavThreshold,
      minimum: minimum ?? this.minimum,
      extraPadding: extraPadding ?? this.extraPadding,
      keyboardAware: keyboardAware ?? this.keyboardAware,
      adaptExistingSafeArea:
          adaptExistingSafeArea ?? this.adaptExistingSafeArea,
      enableEdgeToEdge: enableEdgeToEdge ?? this.enableEdgeToEdge,
      letterboxColor:
          clearLetterboxColor ? null : (letterboxColor ?? this.letterboxColor),
      topSafeAreaColor: clearTopSafeAreaColor
          ? null
          : (topSafeAreaColor ?? this.topSafeAreaColor),
      bottomSafeAreaColor: clearBottomSafeAreaColor
          ? null
          : (bottomSafeAreaColor ?? this.bottomSafeAreaColor),
      leftSafeAreaColor: clearLeftSafeAreaColor
          ? null
          : (leftSafeAreaColor ?? this.leftSafeAreaColor),
      rightSafeAreaColor: clearRightSafeAreaColor
          ? null
          : (rightSafeAreaColor ?? this.rightSafeAreaColor),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SmartSafeAreaConfig &&
        other.bottomBehavior == bottomBehavior &&
        other.extendBackground == extendBackground &&
        other.applyTop == applyTop &&
        other.applyLeft == applyLeft &&
        other.applyRight == applyRight &&
        other.applyBottom == applyBottom &&
        other.applyOnAndroid == applyOnAndroid &&
        other.applyOnIOS == applyOnIOS &&
        other.threeButtonNavThreshold == threeButtonNavThreshold &&
        other.minimum == minimum &&
        other.extraPadding == extraPadding &&
        other.keyboardAware == keyboardAware &&
        other.adaptExistingSafeArea == adaptExistingSafeArea &&
        other.enableEdgeToEdge == enableEdgeToEdge &&
        other.letterboxColor == letterboxColor &&
        other.topSafeAreaColor == topSafeAreaColor &&
        other.bottomSafeAreaColor == bottomSafeAreaColor &&
        other.leftSafeAreaColor == leftSafeAreaColor &&
        other.rightSafeAreaColor == rightSafeAreaColor;
  }

  @override
  int get hashCode => Object.hash(
        bottomBehavior,
        extendBackground,
        applyTop,
        applyLeft,
        applyRight,
        applyBottom,
        applyOnAndroid,
        applyOnIOS,
        threeButtonNavThreshold,
        minimum,
        extraPadding,
        keyboardAware,
        adaptExistingSafeArea,
        enableEdgeToEdge,
        Object.hash(
          letterboxColor,
          topSafeAreaColor,
          bottomSafeAreaColor,
          leftSafeAreaColor,
          rightSafeAreaColor,
        ),
      );
}
