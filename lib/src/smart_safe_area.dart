import 'package:flutter/widgets.dart';

import 'bottom_safe_area_behavior.dart';
import 'smart_safe_area_color_bars.dart';
import 'smart_safe_area_config.dart';
import 'smart_safe_area_insets.dart';
import 'smart_safe_area_scope.dart';

/// A drop-in replacement for Flutter's [SafeArea] that understands 3-button
/// vs gesture navigation.
///
/// **Default behavior**
/// - Top / left / right: standard system insets (notch, status bar, sides).
/// - Bottom: inset only when a 3-button system nav bar is showing. Gesture
///   and home-indicator devices stay flush with the screen edge.
///
/// When a [backgroundColor], [backgroundImage], [backgroundGradient], or
/// [background] is provided, that decoration fills the full widget bounds by
/// default ([extendBackground] = `true`) and only [child] is inset.
///
/// Set [extendBackground] to `false` to inset the background as well.
class SmartSafeArea extends StatelessWidget {
  /// Pads [child] using smart system insets.
  const SmartSafeArea({
    super.key,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.minimum,
    this.extra,
    this.bottomBehavior,
    this.extendBackground,
    this.backgroundColor,
    this.backgroundImage,
    this.backgroundGradient,
    this.background,
    this.letterboxColor,
    this.topSafeAreaColor,
    this.bottomSafeAreaColor,
    this.leftSafeAreaColor,
    this.rightSafeAreaColor,
    this.showTopSafeArea,
    this.showBottomSafeArea,
    this.showLeftSafeArea,
    this.showRightSafeArea,
    this.topSafeAreaOpacity,
    this.bottomSafeAreaOpacity,
    this.leftSafeAreaOpacity,
    this.rightSafeAreaOpacity,
    this.keyboardAware,
    this.threeButtonNavThreshold,
    required this.child,
  });

  /// Whether to apply the top inset. `null` inherits from [SmartSafeAreaScope].
  final bool? top;

  /// Whether to apply the bottom inset. `null` inherits from the scope.
  final bool? bottom;

  /// Whether to apply the left inset. `null` inherits from the scope.
  final bool? left;

  /// Whether to apply the right inset. `null` inherits from the scope.
  final bool? right;

  /// Minimum padding on each side. `null` inherits from the scope.
  final EdgeInsets? minimum;

  /// Extra padding added after system insets. `null` inherits from the scope.
  final EdgeInsets? extra;

  /// Bottom inset policy. `null` inherits from the scope.
  final BottomSafeAreaBehavior? bottomBehavior;

  /// When `true`, [backgroundColor] / image / gradient / [background] draw
  /// behind the system bars and only [child] is inset.
  ///
  /// `null` inherits from [SmartSafeAreaConfig.extendBackground] (`true`).
  final bool? extendBackground;

  /// Solid background painted behind [child].
  final Color? backgroundColor;

  /// Background image painted behind [child].
  final DecorationImage? backgroundImage;

  /// Background gradient painted behind [child].
  final Gradient? backgroundGradient;

  /// Fully custom background widget (drawn behind [child]).
  final Widget? background;

  /// Color of the unsafe region when [extendBackground] is `false`.
  final Color? letterboxColor;

  /// Color of the top inset. `null` inherits from [SmartSafeAreaConfig].
  final Color? topSafeAreaColor;

  /// Color of the bottom inset. `null` inherits from the config.
  final Color? bottomSafeAreaColor;

  /// Color of the left inset. `null` inherits from the config.
  final Color? leftSafeAreaColor;

  /// Color of the right inset. `null` inherits from the config.
  final Color? rightSafeAreaColor;

  /// Whether to paint the top inset color. `null` inherits from the config.
  final bool? showTopSafeArea;

  /// Whether to paint the bottom inset color. `null` inherits from the config.
  final bool? showBottomSafeArea;

  /// Whether to paint the left inset color. `null` inherits from the config.
  final bool? showLeftSafeArea;

  /// Whether to paint the right inset color. `null` inherits from the config.
  final bool? showRightSafeArea;

  /// Opacity of the top inset color (`0`–`1`). `null` inherits from the config.
  final double? topSafeAreaOpacity;

  /// Opacity of the bottom inset color (`0`–`1`). `null` inherits from the config.
  final double? bottomSafeAreaOpacity;

  /// Opacity of the left inset color (`0`–`1`). `null` inherits from the config.
  final double? leftSafeAreaOpacity;

  /// Opacity of the right inset color (`0`–`1`). `null` inherits from the config.
  final double? rightSafeAreaOpacity;

  /// When `true`, bottom padding is at least the keyboard height.
  final bool? keyboardAware;

  /// Override the 3-button detection threshold (default `40`).
  final double? threeButtonNavThreshold;

  /// Screen content — buttons, text, images, lists — that should be inset.
  final Widget child;

  bool get _hasBackground =>
      background != null ||
      backgroundColor != null ||
      backgroundImage != null ||
      backgroundGradient != null;

  @override
  Widget build(BuildContext context) {
    final inherited = SmartSafeAreaScope.of(context);
    final insets = SmartSafeAreaInsets.of(
      context,
      applyTop: top,
      applyBottom: bottom,
      applyLeft: left,
      applyRight: right,
      minimum: minimum,
      extraPadding: extra,
      bottomBehavior: bottomBehavior,
      keyboardAware: keyboardAware,
      threeButtonNavThreshold: threeButtonNavThreshold,
    );

    final padded = _consumePadding(context, insets.content, child);
    final topFill = resolveSafeAreaFill(
      color: topSafeAreaColor ?? inherited.topSafeAreaColor,
      opacity: topSafeAreaOpacity ?? inherited.topSafeAreaOpacity,
      visible: showTopSafeArea ?? inherited.showTopSafeArea,
    );
    final bottomFill = resolveSafeAreaFill(
      color: bottomSafeAreaColor ?? inherited.bottomSafeAreaColor,
      opacity: bottomSafeAreaOpacity ?? inherited.bottomSafeAreaOpacity,
      visible: showBottomSafeArea ?? inherited.showBottomSafeArea,
    );
    final leftFill = resolveSafeAreaFill(
      color: leftSafeAreaColor ?? inherited.leftSafeAreaColor,
      opacity: leftSafeAreaOpacity ?? inherited.leftSafeAreaOpacity,
      visible: showLeftSafeArea ?? inherited.showLeftSafeArea,
    );
    final rightFill = resolveSafeAreaFill(
      color: rightSafeAreaColor ?? inherited.rightSafeAreaColor,
      opacity: rightSafeAreaOpacity ?? inherited.rightSafeAreaOpacity,
      visible: showRightSafeArea ?? inherited.showRightSafeArea,
    );
    final colored = SmartSafeAreaColorBars(
      insets: insets.content,
      top: topFill,
      bottom: bottomFill,
      left: leftFill,
      right: rightFill,
      child: padded,
    );

    if (!_hasBackground) {
      return colored;
    }

    final extend = extendBackground ?? inherited.extendBackground;
    final bg = _buildBackground();

    if (extend) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: bg),
          Positioned.fill(child: colored),
        ],
      );
    }

    final letterbox = letterboxColor ??
        inherited.letterboxColor ??
        backgroundColor ??
        const Color(0xFF000000);

    return SmartSafeAreaColorBars(
      insets: insets.content,
      top: topFill,
      bottom: bottomFill,
      left: leftFill,
      right: rightFill,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: ColoredBox(color: letterbox)),
          Padding(
            padding: insets.content,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(child: bg),
                Positioned.fill(
                  child: _consumePadding(context, EdgeInsets.zero, child),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    if (background != null) return background!;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        image: backgroundImage,
        gradient: backgroundGradient,
      ),
    );
  }

  Widget _consumePadding(
    BuildContext context,
    EdgeInsets padding,
    Widget child,
  ) {
    if (padding == EdgeInsets.zero) return child;
    return Padding(
      padding: padding,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: padding.top > 0,
        removeBottom: padding.bottom > 0,
        removeLeft: padding.left > 0,
        removeRight: padding.right > 0,
        child: child,
      ),
    );
  }
}
