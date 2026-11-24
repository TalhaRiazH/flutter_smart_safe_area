import 'package:flutter/material.dart';

import 'bottom_safe_area_behavior.dart';
import 'smart_safe_area.dart';
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

    final bodyNeedsTop = applyTop && (appBar == null || extendBodyBehindAppBar);
    final bodyNeedsBottom =
        applyBottom && (bottomNavigationBar == null || extendBody);

    Widget? nav = bottomNavigationBar;
    if (nav != null && wrapBottomNavigationBar) {
      nav = SmartSystemNavBar(
        color: extend ? backgroundColor : null,
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
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
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

    return ColoredBox(
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
    );
  }
}
