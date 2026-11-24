import 'package:flutter/material.dart';

import 'bottom_safe_area_behavior.dart';
import 'smart_safe_area.dart';
import 'smart_safe_area_color_bars.dart';
import 'smart_safe_area_insets.dart';
import 'smart_safe_area_scope.dart';
import 'smart_system_nav_bar.dart';

/// A [Scaffold] that treats the background and the content separately.
///
/// **Default (complete solution)**
/// - [backgroundColor], [backgroundImage], [backgroundGradient], and
///   [background] draw edge-to-edge, including behind the system nav.
/// - [body] (buttons, text, images, lists) is inset using smart detection:
///   3-button nav gets a bottom inset; gesture / home-indicator does not.
///
/// Set [extendBackground] to `false` to inset **everything**, including the
/// background. The unsafe region is filled with [letterboxColor].
///
/// When [bottomNavigationBar] is set, it is wrapped in [SmartSystemNavBar]
/// so the bar color fills behind 3-button nav and the body is not double-padded.
class SmartSafeAreaScaffold extends StatelessWidget {
  /// Creates a smart safe-area scaffold.
  const SmartSafeAreaScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.backgroundImage,
    this.backgroundGradient,
    this.background,
    this.extendBackground,
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
    this.bottomBehavior,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.minimum,
    this.extra,
    this.keyboardAware,
    this.threeButtonNavThreshold,
    this.wrapBottomNavigationBar = true,
    this.resizeToAvoidBottomInset = true,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.primary = true,
  });

  /// Optional app bar. When set, the body does not re-apply the top inset
  /// unless [extendBodyBehindAppBar] is `true`.
  final PreferredSizeWidget? appBar;

  /// Screen content. Inset according to smart safe-area rules.
  final Widget body;

  /// Optional floating action button.
  ///
  /// When there is no [bottomNavigationBar], the button is lifted by the smart
  /// bottom inset so it does not sit under 3-button system navigation.
  final Widget? floatingActionButton;

  /// Location of [floatingActionButton].
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Optional bottom bar. Wrapped with [SmartSystemNavBar] when
  /// [wrapBottomNavigationBar] is `true`.
  final Widget? bottomNavigationBar;

  /// Optional drawer.
  final Widget? drawer;

  /// Optional end drawer.
  final Widget? endDrawer;

  /// Scaffold / full-bleed background color.
  final Color? backgroundColor;

  /// Full-bleed background image.
  final DecorationImage? backgroundImage;

  /// Full-bleed background gradient.
  final Gradient? backgroundGradient;

  /// Fully custom full-bleed background widget.
  final Widget? background;

  /// When `true` (default), backgrounds stay edge-to-edge and only [body] is
  /// inset. When `false`, the background is inset too.
  final bool? extendBackground;

  /// Color of the unsafe region when [extendBackground] is `false`.
  final Color? letterboxColor;

  /// Color of the status-bar inset. `null` inherits from [SmartSafeAreaConfig].
  final Color? topSafeAreaColor;

  /// Color of the bottom system-nav inset. `null` inherits from the config.
  ///
  /// When [bottomNavigationBar] is set, this also fills the 3-button region
  /// under the bar.
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

  /// Bottom inset policy. `null` inherits from [SmartSafeAreaScope].
  ///
  /// When [extendBackground] is `false` and this is also `null`, the scaffold
  /// uses [BottomSafeAreaBehavior.always] so the whole screen — including the
  /// background — clears the system nav.
  final BottomSafeAreaBehavior? bottomBehavior;

  /// Whether to apply the top inset to [body]. `null` inherits.
  final bool? top;

  /// Whether to apply the bottom inset to [body]. `null` inherits.
  final bool? bottom;

  /// Whether to apply the left inset to [body]. `null` inherits.
  final bool? left;

  /// Whether to apply the right inset to [body]. `null` inherits.
  final bool? right;

  /// Minimum padding. `null` inherits.
  final EdgeInsets? minimum;

  /// Extra padding. `null` inherits.
  final EdgeInsets? extra;

  /// When `true`, body bottom padding is at least the keyboard height.
  final bool? keyboardAware;

  /// Override the 3-button detection threshold.
  final double? threeButtonNavThreshold;

  /// When `true` (default), [bottomNavigationBar] is wrapped in
  /// [SmartSystemNavBar].
  final bool wrapBottomNavigationBar;

  /// Passed to [Scaffold.resizeToAvoidBottomInset].
  final bool resizeToAvoidBottomInset;

  /// Passed to [Scaffold.extendBody].
  final bool extendBody;

  /// Passed to [Scaffold.extendBodyBehindAppBar].
  final bool extendBodyBehindAppBar;

  /// Passed to [Scaffold.primary].
  final bool primary;

  bool get _hasCustomBackground =>
      background != null ||
      backgroundImage != null ||
      backgroundGradient != null;

  @override
  Widget build(BuildContext context) {
    final inherited = SmartSafeAreaScope.of(context);
    final extend = extendBackground ?? inherited.extendBackground;
    final applyTop = top ?? inherited.applyTop;
    final applyBottom = bottom ?? inherited.applyBottom;
    final behavior = bottomBehavior ??
        (extend ? inherited.bottomBehavior : BottomSafeAreaBehavior.always);

    final showTop = showTopSafeArea ?? inherited.showTopSafeArea;
    final showBottom = showBottomSafeArea ?? inherited.showBottomSafeArea;
    final topColor = resolveSafeAreaFill(
      color: topSafeAreaColor ?? inherited.topSafeAreaColor,
      opacity: topSafeAreaOpacity ?? inherited.topSafeAreaOpacity,
      visible: showTop,
    );
    final bottomColor = resolveSafeAreaFill(
      color: bottomSafeAreaColor ?? inherited.bottomSafeAreaColor,
      opacity: bottomSafeAreaOpacity ?? inherited.bottomSafeAreaOpacity,
      visible: showBottom,
    );
    final leftColor = resolveSafeAreaFill(
      color: leftSafeAreaColor ?? inherited.leftSafeAreaColor,
      opacity: leftSafeAreaOpacity ?? inherited.leftSafeAreaOpacity,
      visible: showLeftSafeArea ?? inherited.showLeftSafeArea,
    );
    final rightColor = resolveSafeAreaFill(
      color: rightSafeAreaColor ?? inherited.rightSafeAreaColor,
      opacity: rightSafeAreaOpacity ?? inherited.rightSafeAreaOpacity,
      visible: showRightSafeArea ?? inherited.showRightSafeArea,
    );
    final hasBottomTint =
        (bottomSafeAreaColor ?? inherited.bottomSafeAreaColor) != null;

    final bottomIsTranslucent = safeAreaFillIsTranslucent(bottomColor);
    final topIsTranslucent = safeAreaFillIsTranslucent(topColor);
    final effectiveExtendBody =
        extendBody || (bottomNavigationBar != null && bottomIsTranslucent);
    final effectiveExtendBodyBehindAppBar =
        extendBodyBehindAppBar || (appBar != null && topIsTranslucent);

    final bodyNeedsTop =
        applyTop && (appBar == null || effectiveExtendBodyBehindAppBar);
    final bodyNeedsBottom =
        applyBottom && (bottomNavigationBar == null || effectiveExtendBody);

    Widget? nav = bottomNavigationBar;
    if (nav != null && wrapBottomNavigationBar) {
      nav = SmartSystemNavBar(
        color: extend ? (hasBottomTint ? bottomColor : backgroundColor) : null,
        bottomBehavior: behavior,
        threeButtonNavThreshold: threeButtonNavThreshold,
        child: nav,
      );
    }

    final Widget bodyWidget;
    if (_hasCustomBackground) {
      bodyWidget = SmartSafeArea(
        top: bodyNeedsTop,
        bottom: bodyNeedsBottom,
        left: left,
        right: right,
        minimum: minimum,
        extra: extra,
        bottomBehavior: behavior,
        keyboardAware: keyboardAware,
        threeButtonNavThreshold: threeButtonNavThreshold,
        extendBackground: extend,
        backgroundColor: backgroundColor,
        backgroundImage: backgroundImage,
        backgroundGradient: backgroundGradient,
        background: background,
        letterboxColor: letterboxColor,
        topSafeAreaColor: topColor,
        bottomSafeAreaColor: bodyNeedsBottom ? bottomColor : null,
        leftSafeAreaColor: leftColor,
        rightSafeAreaColor: rightColor,
        showTopSafeArea: true,
        showBottomSafeArea: true,
        showLeftSafeArea: true,
        showRightSafeArea: true,
        topSafeAreaOpacity: 1,
        bottomSafeAreaOpacity: 1,
        leftSafeAreaOpacity: 1,
        rightSafeAreaOpacity: 1,
        child: body,
      );
    } else if (extend) {
      bodyWidget = SmartSafeArea(
        top: bodyNeedsTop,
        bottom: bodyNeedsBottom,
        left: left,
        right: right,
        minimum: minimum,
        extra: extra,
        bottomBehavior: behavior,
        keyboardAware: keyboardAware,
        threeButtonNavThreshold: threeButtonNavThreshold,
        topSafeAreaColor: topColor,
        bottomSafeAreaColor: bodyNeedsBottom ? bottomColor : null,
        leftSafeAreaColor: leftColor,
        rightSafeAreaColor: rightColor,
        showTopSafeArea: true,
        showBottomSafeArea: true,
        showLeftSafeArea: true,
        showRightSafeArea: true,
        topSafeAreaOpacity: 1,
        bottomSafeAreaOpacity: 1,
        leftSafeAreaOpacity: 1,
        rightSafeAreaOpacity: 1,
        child: body,
      );
    } else {
      bodyWidget = body;
    }

    Widget? fab = floatingActionButton;
    final scaffoldIsLetterboxed = !extend && !_hasCustomBackground;
    if (fab != null &&
        !scaffoldIsLetterboxed &&
        applyBottom &&
        bottomNavigationBar == null) {
      final fabBottom = SmartSafeAreaInsets.of(
        context,
        applyTop: false,
        applyLeft: false,
        applyRight: false,
        applyBottom: true,
        bottomBehavior: behavior,
        threeButtonNavThreshold: threeButtonNavThreshold,
        extraPadding: extra,
        minimum: minimum,
        keyboardAware: keyboardAware,
      ).contentBottom;
      if (fabBottom > 0) {
        fab = Padding(
          padding: EdgeInsets.only(bottom: fabBottom),
          child: fab,
        );
      }
    }

    final scaffold = Scaffold(
      primary: primary,
      appBar: appBar,
      body: bodyWidget,
      backgroundColor:
          _hasCustomBackground ? Colors.transparent : backgroundColor,
      floatingActionButton: fab,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: nav,
      drawer: drawer,
      endDrawer: endDrawer,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: effectiveExtendBody,
      extendBodyBehindAppBar: effectiveExtendBodyBehindAppBar,
    );

    if (extend || _hasCustomBackground) {
      return scaffold;
    }

    final insets = SmartSafeAreaInsets.of(
      context,
      applyTop: applyTop && appBar == null,
      applyBottom: applyBottom && bottomNavigationBar == null,
      applyLeft: left,
      applyRight: right,
      minimum: minimum,
      extraPadding: extra,
      bottomBehavior: behavior,
      keyboardAware: keyboardAware,
      threeButtonNavThreshold: threeButtonNavThreshold,
    );
    final letterbox = letterboxColor ??
        inherited.letterboxColor ??
        backgroundColor ??
        const Color(0xFF000000);

    return SmartSafeAreaColorBars(
      insets: insets.content,
      top: topColor,
      bottom: bottomColor,
      left: leftColor,
      right: rightColor,
      child: ColoredBox(
        color: letterbox,
        child: Padding(
          padding: insets.content,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: insets.content.top > 0,
            removeBottom: insets.content.bottom > 0,
            removeLeft: insets.content.left > 0,
            removeRight: insets.content.right > 0,
            child: scaffold,
          ),
        ),
      ),
    );
  }
}
