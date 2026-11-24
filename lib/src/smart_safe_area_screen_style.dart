import 'package:flutter/widgets.dart';

import 'smart_safe_area_config.dart';
import 'smart_safe_area_insets.dart';

/// Tracks the [SmartSafeAreaConfig] of the screen that is currently visible.
///
/// The app-wide host paints status-bar and bottom-inset colors from its own
/// config. A [SmartSafeAreaScaffold] registers here while its route is current
/// so that one screen can replace those colors.
class SmartSafeAreaScreenController extends ChangeNotifier {
  final Map<Object, SmartSafeAreaConfig> _styles = {};
  Object? _current;

  /// Style of the current screen, or `null` to use the app-wide config.
  SmartSafeAreaConfig? get active =>
      _current == null ? null : _styles[_current];

  /// Makes [config] the style while [key]'s screen is visible.
  void activate(Object key, SmartSafeAreaConfig config) {
    final changed = _current != key || _styles[key] != config;
    _styles[key] = config;
    _current = key;
    if (changed) notifyListeners();
  }

  /// Drops [key] when its screen is covered or disposed.
  void deactivate(Object key) {
    final removed = _styles.remove(key) != null;
    if (_current == key) {
      _current = _styles.isEmpty ? null : _styles.keys.last;
    }
    if (removed) notifyListeners();
  }
}

/// Exposes a [SmartSafeAreaScreenController] to the current app.
class SmartSafeAreaScreenScope extends InheritedWidget {
  /// Creates a scope for [controller].
  const SmartSafeAreaScreenScope({
    super.key,
    required this.controller,
    required super.child,
  });

  /// Controller owned by [SmartSafeAreaHost].
  final SmartSafeAreaScreenController controller;

  /// The controller above [context], or `null` when there is no host.
  static SmartSafeAreaScreenController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SmartSafeAreaScreenScope>()
        ?.controller;
  }

  @override
  bool updateShouldNotify(SmartSafeAreaScreenScope oldWidget) {
    return controller != oldWidget.controller;
  }
}

/// Registers [config] as the safe-area style while this screen is current.
class SmartSafeAreaScreenStyle extends StatefulWidget {
  /// Creates a screen style.
  const SmartSafeAreaScreenStyle({
    super.key,
    required this.config,
    required this.child,
  });

  /// Style to use instead of the app-wide config.
  final SmartSafeAreaConfig config;

  /// The screen.
  final Widget child;

  @override
  State<SmartSafeAreaScreenStyle> createState() =>
      _SmartSafeAreaScreenStyleState();
}

class _SmartSafeAreaScreenStyleState extends State<SmartSafeAreaScreenStyle> {
  SmartSafeAreaScreenController? _controller;

  void _sync() {
    if (!mounted) return;
    final controller = SmartSafeAreaScreenScope.maybeOf(context);
    _controller = controller;
    if (controller == null) return;
    final route = ModalRoute.of(context);
    final current = route == null || route.isCurrent;
    if (current) {
      controller.activate(this, widget.config);
    } else {
      controller.deactivate(this);
    }
  }

  void _syncAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAfterFrame();
  }

  @override
  void didUpdateWidget(SmartSafeAreaScreenStyle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) _syncAfterFrame();
  }

  @override
  void dispose() {
    _controller?.deactivate(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (SmartSafeAreaScreenScope.maybeOf(context) == null) {
      return widget.child;
    }
    return _ScreenInsetQuery(config: widget.config, child: widget.child);
  }
}

/// Applies this screen's bottom inset without changing the rest of the app.
class _ScreenInsetQuery extends StatelessWidget {
  const _ScreenInsetQuery({required this.config, required this.child});

  final SmartSafeAreaConfig config;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!config.adaptExistingSafeArea) return child;
    final mq = MediaQuery.of(context);
    final bottom = SmartSafeAreaInsets.of(
      context,
      config: config,
      extraPadding: EdgeInsets.zero,
      minimum: EdgeInsets.zero,
    ).contentBottom;
    if ((mq.padding.bottom - bottom).abs() < 0.5 &&
        (mq.viewPadding.bottom - bottom).abs() < 0.5) {
      return child;
    }
    return MediaQuery(
      data: mq.copyWith(
        padding: mq.padding.copyWith(bottom: bottom),
        viewPadding: mq.viewPadding.copyWith(bottom: bottom),
      ),
      child: child,
    );
  }
}
