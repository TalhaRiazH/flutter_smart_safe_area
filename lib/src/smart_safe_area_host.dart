import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'smart_safe_area_config.dart';
import 'smart_safe_area_insets.dart';
import 'smart_safe_area_scope.dart';
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
class SmartSafeAreaHost extends StatelessWidget {
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
  Widget build(BuildContext context) {
    if (!config.appliesToCurrentPlatform) {
      return SmartSafeAreaScope(config: config, child: child);
    }

    Widget built = SmartSafeAreaScope(
      config: config,
      child: _MediaQueryAdapter(
        config: config,
        child: child,
      ),
    );

    if (config.enableEdgeToEdge) {
      built = AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle(
          statusBarIconBrightness: statusBarIconBrightness,
          systemNavigationBarIconBrightness: systemNavigationBarIconBrightness,
        ),
        child: built,
      );
    }

    if (showDebugOverlay) {
      built = _DebugOverlay(child: built);
    }

    return built;
  }
}

class _MediaQueryAdapter extends StatelessWidget {
  const _MediaQueryAdapter({
    required this.config,
    required this.child,
  });

  final SmartSafeAreaConfig config;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final padding = mq.padding;
    final viewPadding = mq.viewPadding;

    final smartBottom = SmartSafeAreaInsets.of(
      context,
      config: config,
      extraPadding: EdgeInsets.zero,
      minimum: EdgeInsets.zero,
      keyboardAware: false,
    ).contentBottom;

    final nextPadding = padding.copyWith(
      top: math.max(padding.top, viewPadding.top),
      left: math.max(padding.left, viewPadding.left),
      right: math.max(padding.right, viewPadding.right),
      bottom: config.adaptExistingSafeArea
          ? smartBottom
          : math.max(padding.bottom, viewPadding.bottom),
    );

    if (nextPadding == padding) return child;

    return MediaQuery(
      data: mq.copyWith(padding: nextPadding),
      child: child,
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
