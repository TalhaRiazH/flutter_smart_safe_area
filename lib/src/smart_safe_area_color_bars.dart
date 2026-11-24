import 'package:flutter/widgets.dart';

/// Applies [visible] and [opacity] to a safe-area fill [color].
///
/// Returns `null` when the bar should not be painted (`visible` is false,
/// [color] is null, or [opacity] is `0`).
Color? resolveSafeAreaFill({
  Color? color,
  double opacity = 1,
  bool visible = true,
}) {
  if (!visible || color == null) return null;
  final next = opacity.clamp(0.0, 1.0);
  if (next <= 0) return null;
  if (next >= 1) return color;
  return color.withValues(alpha: color.a * next);
}

/// Whether a resolved fill should sit over scrolling content.
///
/// Translucent bars do not consume padding, so lists can move behind them.
bool safeAreaFillIsTranslucent(Color? color) {
  return color != null && color.a < 0.999;
}

/// Content padding with translucent sides left at `0` so children draw behind
/// the overlay bars.
EdgeInsets paddingWithoutTranslucentFills(
  EdgeInsets insets, {
  Color? top,
  Color? bottom,
  Color? left,
  Color? right,
}) {
  return EdgeInsets.fromLTRB(
    safeAreaFillIsTranslucent(left) ? 0 : insets.left,
    safeAreaFillIsTranslucent(top) ? 0 : insets.top,
    safeAreaFillIsTranslucent(right) ? 0 : insets.right,
    safeAreaFillIsTranslucent(bottom) ? 0 : insets.bottom,
  );
}

/// Overlay bar sizes. Translucent fills still use the real inset so the color
/// covers the system region while content scrolls underneath.
EdgeInsets overlayInsetsForFills(
  EdgeInsets insets, {
  Color? top,
  Color? bottom,
  Color? left,
  Color? right,
}) {
  return EdgeInsets.fromLTRB(
    left == null ? 0 : insets.left,
    top == null ? 0 : insets.top,
    right == null ? 0 : insets.right,
    bottom == null ? 0 : insets.bottom,
  );
}

/// Paints optional colors in the system inset regions around [child].
class SmartSafeAreaColorBars extends StatelessWidget {
  /// Creates overlay bars for each inset side that has a color.
  const SmartSafeAreaColorBars({
    super.key,
    required this.insets,
    required this.child,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  /// Insets that size the color bars.
  final EdgeInsets insets;

  /// Screen content drawn under the bars.
  final Widget child;

  /// Color of the status-bar / notch region.
  final Color? top;

  /// Color of the system-nav / home-indicator region.
  final Color? bottom;

  /// Color of the left inset.
  final Color? left;

  /// Color of the right inset.
  final Color? right;

  bool get _hasBars =>
      (top != null && insets.top > 0) ||
      (bottom != null && insets.bottom > 0) ||
      (left != null && insets.left > 0) ||
      (right != null && insets.right > 0);

  @override
  Widget build(BuildContext context) {
    if (!_hasBars) return child;

    return Stack(
      children: [
        child,
        if (top != null && insets.top > 0)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: insets.top,
            child: IgnorePointer(child: ColoredBox(color: top!)),
          ),
        if (bottom != null && insets.bottom > 0)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: insets.bottom,
            child: IgnorePointer(child: ColoredBox(color: bottom!)),
          ),
        if (left != null && insets.left > 0)
          Positioned(
            top: insets.top,
            bottom: insets.bottom,
            left: 0,
            width: insets.left,
            child: IgnorePointer(child: ColoredBox(color: left!)),
          ),
        if (right != null && insets.right > 0)
          Positioned(
            top: insets.top,
            bottom: insets.bottom,
            right: 0,
            width: insets.right,
            child: IgnorePointer(child: ColoredBox(color: right!)),
          ),
      ],
    );
  }
}
