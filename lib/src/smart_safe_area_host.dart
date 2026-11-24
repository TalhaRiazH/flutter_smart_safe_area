import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'smart_safe_area_color_bars.dart';
import 'smart_safe_area_config.dart';
import 'smart_safe_area_insets.dart';
import 'smart_safe_area_raw_padding.dart';
import 'smart_safe_area_scope.dart';
import 'smart_safe_area_screen_style.dart';
import 'smart_safe_area_simulation_scope.dart';
import 'system_nav.dart';
import 'system_nav_mode.dart';

/// App-level host that enables edge-to-edge, publishes [SmartSafeAreaConfig],
/// and optionally rewrites [MediaQuery.padding] so Flutter's own [SafeArea]
/// widgets pick up 3-button vs gesture detection.
///
/// Put this in [MaterialApp.builder]:
///
/// ```dart
/// MaterialApp(
///   builder: SmartSafeAreaHost.materialBuilder(),
///   home: const HomeScreen(),
/// )
/// ```
///
/// Call [SmartSafeAreaHost.ensureEdgeToEdge] from `main()` on Android so the
/// system bars start transparent before the first frame.
///
/// The host also re-applies edge-to-edge and rebuilds when the app resumes or
/// window metrics change, so 3-button vs gesture insets update after the user
/// changes system navigation in Settings.
class SmartSafeAreaHost extends StatefulWidget {
  /// Creates an app-level smart safe-area host.
  const SmartSafeAreaHost({
    super.key,
    this.config = const SmartSafeAreaConfig(),
    this.showDebugOverlay = false,
    this.statusBarIconBrightness = Brightness.light,
    this.systemNavigationBarIconBrightness = Brightness.light,
    required this.child,
  });

  /// Defaults inherited by every [SmartSafeArea] below this host.
  final SmartSafeAreaConfig config;

  /// When `true`, draws a small banner with the detected nav mode and insets.
  final bool showDebugOverlay;

  /// Status-bar icon brightness used when [config.enableEdgeToEdge] is true.
  final Brightness statusBarIconBrightness;

  /// Navigation-bar icon brightness used when [config.enableEdgeToEdge] is true.
  final Brightness systemNavigationBarIconBrightness;

  /// The rest of the app (typically the [MaterialApp] child).
  final Widget child;

  /// Transparent edge-to-edge overlay style (icon brightness only).
  ///
  /// Do not set status-bar / nav-bar **colors** — those trigger deprecated
  /// Window APIs on Android 15+.
  static SystemUiOverlayStyle overlayStyle({
    Brightness statusBarIconBrightness = Brightness.light,
    Brightness systemNavigationBarIconBrightness = Brightness.light,
  }) {
    return SystemUiOverlayStyle(
      statusBarIconBrightness: statusBarIconBrightness,
      systemNavigationBarIconBrightness: systemNavigationBarIconBrightness,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarContrastEnforced: false,
    );
  }

  /// Enables [SystemUiMode.edgeToEdge] on Android. Safe to call from `main()`.
  static Future<void> ensureEdgeToEdge({
    Brightness statusBarIconBrightness = Brightness.light,
    Brightness systemNavigationBarIconBrightness = Brightness.light,
  }) async {
    if (kIsWeb) return;
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      overlayStyle(
        statusBarIconBrightness: statusBarIconBrightness,
        systemNavigationBarIconBrightness: systemNavigationBarIconBrightness,
      ),
    );
  }

  /// [MaterialApp.builder] helper.
  ///
  /// [then] wraps the navigator [child] **inside** the host, so it still sees
  /// the adapted [MediaQuery] padding.
  static TransitionBuilder materialBuilder({
    SmartSafeAreaConfig config = const SmartSafeAreaConfig(),
    bool showDebugOverlay = false,
    Brightness statusBarIconBrightness = Brightness.light,
    Brightness systemNavigationBarIconBrightness = Brightness.light,
    TransitionBuilder? then,
  }) {
    return (BuildContext context, Widget? child) {
      final inner = then != null ? then(context, child) : child;
      return SmartSafeAreaHost(
        config: config,
        showDebugOverlay: showDebugOverlay,
        statusBarIconBrightness: statusBarIconBrightness,
        systemNavigationBarIconBrightness: systemNavigationBarIconBrightness,
        child: inner ?? const SizedBox.shrink(),
      );
    };
  }

  @override
  State<SmartSafeAreaHost> createState() => _SmartSafeAreaHostState();
}

class _SmartSafeAreaHostState extends State<SmartSafeAreaHost>
    with WidgetsBindingObserver {
  EdgeInsets? _appliedLivePadding;
  final SmartSafeAreaScreenController _screens =
      SmartSafeAreaScreenController();

  @override
  void initState() {
    super.initState();
    _screens.addListener(_onScreenStyle);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshSystemInsets();
    });
  }

  void _onScreenStyle() {
    // Registration can happen while a route is disposing. Apply it on the
    // next frame so the host never calls setState during that build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _screens.removeListener(_onScreenStyle);
    WidgetsBinding.instance.removeObserver(this);
    _screens.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshSystemInsets();
    }
  }

  @override
  void didChangeMetrics() {
    if (!mounted) return;
    final live = SystemNav.liveViewPadding(context);
    if (live == _appliedLivePadding) return;
    _appliedLivePadding = live;
    setState(() {});
  }

  Future<void> _refreshSystemInsets() async {
    if (!mounted) return;
    if (widget.config.appliesToCurrentPlatform &&
        widget.config.enableEdgeToEdge) {
      await SmartSafeAreaHost.ensureEdgeToEdge(
        statusBarIconBrightness: widget.statusBarIconBrightness,
        systemNavigationBarIconBrightness:
            widget.systemNavigationBarIconBrightness,
      );
    }
    if (!mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    if (!config.appliesToCurrentPlatform) {
      return SmartSafeAreaScope(config: config, child: widget.child);
    }

    Widget built = SmartSafeAreaScreenScope(
      controller: _screens,
      child: SmartSafeAreaScope(
        config: config,
        child: _MediaQueryAdapter(
          config: config,
          screenStyle: _screens,
          child: widget.child,
        ),
      ),
    );

    if (config.enableEdgeToEdge) {
      built = AnnotatedRegion<SystemUiOverlayStyle>(
        value: SmartSafeAreaHost.overlayStyle(
          statusBarIconBrightness: widget.statusBarIconBrightness,
          systemNavigationBarIconBrightness:
              widget.systemNavigationBarIconBrightness,
        ),
        child: built,
      );
    }

    if (widget.showDebugOverlay) {
      built = _DebugOverlay(child: built);
    }

    return built;
  }
}

class _MediaQueryAdapter extends StatelessWidget {
  const _MediaQueryAdapter({
    required this.config,
    required this.screenStyle,
    required this.child,
  });

  final SmartSafeAreaConfig config;
  final SmartSafeAreaScreenController screenStyle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context);
    if (!SmartSafeAreaSimulationScope.lockedOf(context)) {
      final live = SystemNav.liveViewPadding(context);
      if (live != null &&
          (live.bottom > 0 ||
              live.top > 0 ||
              live.left > 0 ||
              live.right > 0)) {
        final staleBottom = (live.bottom - mq.viewPadding.bottom).abs() > 0.5;
        final staleTop = (live.top - mq.viewPadding.top).abs() > 0.5;
        if (staleBottom || staleTop) {
          mq = mq.copyWith(
            viewPadding: live,
            padding: mq.padding.copyWith(
              top: live.top,
              left: live.left,
              right: live.right,
              bottom: live.bottom,
            ),
          );
        }
      }
    }

    return MediaQuery(
      data: mq,
      child: Builder(
        builder: (context) {
          final padding = MediaQuery.paddingOf(context);
          final viewPadding = MediaQuery.viewPaddingOf(context);
          final insets = SmartSafeAreaInsets.of(
            context,
            config: config,
            extraPadding: EdgeInsets.zero,
            minimum: EdgeInsets.zero,
            keyboardAware: false,
          );
          final smartBottom = insets.contentBottom;
          final nextPadding = padding.copyWith(
            top: math.max(padding.top, viewPadding.top),
            left: math.max(padding.left, viewPadding.left),
            right: math.max(padding.right, viewPadding.right),
            bottom: config.adaptExistingSafeArea
                ? smartBottom
                : math.max(padding.bottom, viewPadding.bottom),
          );
          final smartViewPadding = config.adaptExistingSafeArea
              ? viewPadding.copyWith(bottom: smartBottom)
              : viewPadding;
          return SmartSafeAreaRawPadding(
            padding: viewPadding,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                padding: nextPadding,
                viewPadding: smartViewPadding,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  child,
                  _HostColorOverlay(
                    fallback: config,
                    screenStyle: screenStyle,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HostColorOverlay extends StatelessWidget {
  const _HostColorOverlay({
    required this.fallback,
    required this.screenStyle,
  });

  final SmartSafeAreaConfig fallback;
  final SmartSafeAreaScreenController screenStyle;

  @override
  Widget build(BuildContext context) {
    final config = screenStyle.active ?? fallback;
    final insets = SmartSafeAreaInsets.of(
      context,
      config: config,
      extraPadding: EdgeInsets.zero,
      minimum: EdgeInsets.zero,
      keyboardAware: false,
    );
    final top = resolveSafeAreaFill(
      color: config.topSafeAreaColor,
      opacity: config.topSafeAreaOpacity,
      visible: config.showTopSafeArea,
    );
    final bottom = resolveSafeAreaFill(
      color: config.bottomSafeAreaColor,
      opacity: config.bottomSafeAreaOpacity,
      visible: config.showBottomSafeArea,
    );
    final left = resolveSafeAreaFill(
      color: config.leftSafeAreaColor,
      opacity: config.leftSafeAreaOpacity,
      visible: config.showLeftSafeArea,
    );
    final right = resolveSafeAreaFill(
      color: config.rightSafeAreaColor,
      opacity: config.rightSafeAreaOpacity,
      visible: config.showRightSafeArea,
    );
    return IgnorePointer(
      child: SmartSafeAreaColorBars(
        insets: overlayInsetsForFills(
          insets.content,
          top: top,
          bottom: bottom,
          left: left,
          right: right,
        ),
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _DebugOverlay extends StatelessWidget {
  const _DebugOverlay({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: MediaQuery.viewPaddingOf(context).top + 4,
          right: 8,
          child: IgnorePointer(
            child: Builder(
              builder: (context) {
                final insets = SmartSafeAreaInsets.of(context);
                final label = switch (insets.navMode) {
                  SystemNavMode.threeButton => '3-button',
                  SystemNavMode.gesture => 'gesture',
                  SystemNavMode.none => 'no nav',
                };
                return Material(
                  color: const Color(0xCC111111),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      '$label  raw ${insets.rawBottom.toStringAsFixed(0)}  '
                      'content ${insets.contentBottom.toStringAsFixed(0)}  '
                      'thr ${SystemNav.thresholdOf(context).toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFFFFFFFF),
                        fontSize: 11,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
