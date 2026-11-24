import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_smart_safe_area/flutter_smart_safe_area.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SystemNav detection', () {
    testWidgets('treats a 48dp inset as 3-button nav', (tester) async {
      late SmartSafeAreaInsets insets;
      await tester.pumpWidget(
        _harness(
          viewPadding: const EdgeInsets.only(top: 47, bottom: 48),
          child: Builder(
            builder: (context) {
              insets = SmartSafeAreaInsets.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(insets.navMode, SystemNavMode.threeButton);
      expect(insets.isThreeButton, isTrue);
      expect(insets.rawBottom, 48);
      expect(insets.contentBottom, 48);
    });

    testWidgets('treats a 34dp inset as gesture nav and skips content inset',
        (tester) async {
      late SmartSafeAreaInsets insets;
      await tester.pumpWidget(
        _harness(
          viewPadding: const EdgeInsets.only(top: 47, bottom: 34),
          child: Builder(
            builder: (context) {
              insets = SmartSafeAreaInsets.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(insets.navMode, SystemNavMode.gesture);
      expect(insets.isGesture, isTrue);
      expect(insets.rawBottom, 34);
      expect(insets.contentBottom, 0);
    });

    testWidgets('treats a 0 inset as none', (tester) async {
      late SmartSafeAreaInsets insets;
      await tester.pumpWidget(
        _harness(
          viewPadding: EdgeInsets.zero,
          child: Builder(
            builder: (context) {
              insets = SmartSafeAreaInsets.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(insets.navMode, SystemNavMode.none);
      expect(insets.contentBottom, 0);
    });
  });

  group('BottomSafeAreaBehavior', () {
    testWidgets('always applies the raw gesture inset', (tester) async {
      late SmartSafeAreaInsets insets;
      await tester.pumpWidget(
        _harness(
          viewPadding: const EdgeInsets.only(bottom: 34),
          config: const SmartSafeAreaConfig(
            bottomBehavior: BottomSafeAreaBehavior.always,
          ),
          child: Builder(
            builder: (context) {
              insets = SmartSafeAreaInsets.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(insets.contentBottom, 34);
    });

    testWidgets('never applies a bottom inset even for 3-button',
        (tester) async {
      late SmartSafeAreaInsets insets;
      await tester.pumpWidget(
        _harness(
          viewPadding: const EdgeInsets.only(bottom: 48),
          config: const SmartSafeAreaConfig(
            bottomBehavior: BottomSafeAreaBehavior.never,
          ),
          child: Builder(
            builder: (context) {
              insets = SmartSafeAreaInsets.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(insets.contentBottom, 0);
    });
  });

  group('Platform enable flags', () {
    test('requires at least one of Android or iOS', () {
      expect(
        () => SmartSafeAreaConfig(
          applyOnAndroid: false,
          applyOnIOS: false,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('skips content insets on Android when applyOnAndroid is false',
        (tester) async {
      late SmartSafeAreaInsets insets;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        await tester.pumpWidget(
          _harness(
            viewPadding: const EdgeInsets.only(top: 47, bottom: 48),
            config: const SmartSafeAreaConfig(
              applyOnAndroid: false,
              applyOnIOS: true,
            ),
            child: Builder(
              builder: (context) {
                insets = SmartSafeAreaInsets.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(insets.content.top, 47);
        expect(insets.content.bottom, 48);
        expect(insets.rawBottom, 48);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('applies content insets on iOS when only iOS is enabled',
        (tester) async {
      late SmartSafeAreaInsets insets;
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        await tester.pumpWidget(
          _harness(
            viewPadding: const EdgeInsets.only(top: 47, bottom: 48),
            config: const SmartSafeAreaConfig(
              applyOnAndroid: false,
              applyOnIOS: true,
            ),
            child: Builder(
              builder: (context) {
                insets = SmartSafeAreaInsets.of(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(insets.content.top, 47);
        expect(insets.content.bottom, 48);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    testWidgets('host does not rewrite MediaQuery when Android is disabled',
        (tester) async {
      late EdgeInsets padding;
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  viewPadding: const EdgeInsets.only(top: 47, bottom: 34),
                  padding: const EdgeInsets.only(top: 47, bottom: 34),
                ),
                child: SmartSafeAreaHost(
                  config: const SmartSafeAreaConfig(
                    applyOnAndroid: false,
                    applyOnIOS: true,
                  ),
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
            home: Builder(
              builder: (context) {
                padding = MediaQuery.paddingOf(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        );

        expect(padding.bottom, 34);
        expect(padding.top, 47);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  });

  group('SmartSafeArea', () {
    testWidgets('pads content on 3-button and leaves top inset',
        (tester) async {
      await tester.pumpWidget(
        _harness(
          viewPadding: const EdgeInsets.only(top: 47, bottom: 48),
          child: const SmartSafeArea(
            child: Text('content'),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding).first);
      final insets = padding.padding.resolve(TextDirection.ltr);
      expect(insets.top, 47);
      expect(insets.bottom, 48);
    });

    testWidgets('does not pad the bottom on gesture devices', (tester) async {
      await tester.pumpWidget(
        _harness(
          viewPadding: const EdgeInsets.only(top: 47, bottom: 34),
          child: const SmartSafeArea(
            child: Text('content'),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding).first);
      final insets = padding.padding.resolve(TextDirection.ltr);
      expect(insets.top, 47);
      expect(insets.bottom, 0);
    });

    testWidgets('lets content draw behind translucent safe area colors',
        (tester) async {
      await tester.pumpWidget(
        _harness(
          viewPadding: const EdgeInsets.only(top: 47, bottom: 48),
          child: const SmartSafeArea(
            topSafeAreaColor: Color(0xFFFF0000),
            topSafeAreaOpacity: 0.4,
            bottomSafeAreaColor: Color(0xFF00FF00),
            bottomSafeAreaOpacity: 0.4,
            child: Text('content'),
          ),
        ),
      );

      expect(tester.getTopLeft(find.text('content')).dy, lessThan(47));
      expect(
        tester
            .getSize(
              find.byWidgetPredicate(
                (widget) =>
                    widget is ColoredBox &&
                    widget.color.r == 1 &&
                    widget.color.g == 0,
              ),
            )
            .height,
        47,
      );
    });

    testWidgets('paints top and bottom safe area colors', (tester) async {
      const topColor = Color(0xFFFF0000);
      const bottomColor = Color(0xFF00FF00);
      await tester.pumpWidget(
        _harness(
          viewPadding: const EdgeInsets.only(top: 47, bottom: 48),
          child: const SmartSafeArea(
            topSafeAreaColor: topColor,
            bottomSafeAreaColor: bottomColor,
            child: Text('content'),
          ),
        ),
      );

      final topBox = tester.widget<ColoredBox>(
        find.byWidgetPredicate(
          (widget) => widget is ColoredBox && widget.color == topColor,
        ),
      );
      final bottomBox = tester.widget<ColoredBox>(
        find.byWidgetPredicate(
          (widget) => widget is ColoredBox && widget.color == bottomColor,
        ),
      );
      expect(topBox.color, topColor);
      expect(bottomBox.color, bottomColor);
      expect(
        tester
            .getSize(
              find.byWidgetPredicate(
                (widget) => widget is ColoredBox && widget.color == topColor,
              ),
            )
            .height,
        47,
      );
      expect(
        tester
            .getSize(
              find.byWidgetPredicate(
                (widget) => widget is ColoredBox && widget.color == bottomColor,
              ),
            )
            .height,
        48,
      );
    });

    testWidgets('hides a safe area color when show is false', (tester) async {
      const topColor = Color(0xFFFF0000);
      await tester.pumpWidget(
        _harness(
          viewPadding: const EdgeInsets.only(top: 47, bottom: 48),
          child: const SmartSafeArea(
            topSafeAreaColor: topColor,
            showTopSafeArea: false,
            child: Text('content'),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) => widget is ColoredBox && widget.color == topColor,
        ),
        findsNothing,
      );
    });

    testWidgets('applies opacity to a safe area color', (tester) async {
      const topColor = Color(0xFFFF0000);
      await tester.pumpWidget(
        _harness(
          viewPadding: const EdgeInsets.only(top: 47, bottom: 48),
          child: const SmartSafeArea(
            topSafeAreaColor: topColor,
            topSafeAreaOpacity: 0.5,
            child: Text('content'),
          ),
        ),
      );

      final topBox = tester.widget<ColoredBox>(
        find.byWidgetPredicate(
          (widget) =>
              widget is ColoredBox &&
              widget.color.r == 1 &&
              widget.color.g == 0 &&
              widget.color.b == 0,
        ),
      );
      expect(topBox.color.a, closeTo(0.5, 0.01));
    });
  });

  group('SmartSafeAreaHost', () {
    testWidgets('rewrites MediaQuery.padding.bottom for existing SafeArea',
        (tester) async {
      late EdgeInsets padding;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                viewPadding: const EdgeInsets.only(top: 47, bottom: 34),
                padding: const EdgeInsets.only(top: 47, bottom: 34),
              ),
              child: SmartSafeAreaHost(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          home: Builder(
            builder: (context) {
              padding = MediaQuery.paddingOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(padding.bottom, 0);
      expect(padding.top, 47);
    });

    testWidgets('keeps MediaQuery.padding.bottom for 3-button nav',
        (tester) async {
      late EdgeInsets padding;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                viewPadding: const EdgeInsets.only(top: 47, bottom: 48),
                padding: const EdgeInsets.only(top: 47, bottom: 48),
              ),
              child: SmartSafeAreaHost(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          home: Builder(
            builder: (context) {
              padding = MediaQuery.paddingOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(padding.bottom, 48);
    });

    testWidgets('drops the nav inset while the keyboard is open',
        (tester) async {
      late EdgeInsets padding;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                viewPadding: const EdgeInsets.only(top: 47, bottom: 48),
                padding: const EdgeInsets.only(top: 47, bottom: 48),
                viewInsets: const EdgeInsets.only(bottom: 300),
              ),
              child: SmartSafeAreaHost(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          home: Builder(
            builder: (context) {
              padding = MediaQuery.paddingOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(padding.bottom, 0);
      expect(padding.top, 47);
    });

    testWidgets('clears a stale 3-button inset when the live bottom is 0',
        (tester) async {
      final dpr = tester.view.devicePixelRatio;
      tester.view.padding = FakeViewPadding(top: 47 * dpr);
      tester.view.viewPadding = FakeViewPadding(top: 47 * dpr);
      addTearDown(tester.view.reset);

      late double contentBottom;
      late SystemNavMode mode;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                viewPadding: const EdgeInsets.only(top: 47, bottom: 48),
                padding: const EdgeInsets.only(top: 47, bottom: 48),
              ),
              child: SmartSafeAreaHost(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          home: Builder(
            builder: (context) {
              final insets = SmartSafeAreaInsets.of(context);
              contentBottom = insets.contentBottom;
              mode = insets.navMode;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(mode, SystemNavMode.none);
      expect(contentBottom, 0);
    });

    testWidgets('keeps screen state when the bottom inset changes',
        (tester) async {
      final padding = ValueNotifier<EdgeInsets>(
        const EdgeInsets.only(top: 47, bottom: 48),
      );
      addTearDown(padding.dispose);

      await tester.pumpWidget(
        ValueListenableBuilder<EdgeInsets>(
          valueListenable: padding,
          builder: (context, insets, _) {
            return MaterialApp(
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    viewPadding: insets,
                    padding: insets,
                  ),
                  child: SmartSafeAreaHost(
                    child: child ?? const SizedBox.shrink(),
                  ),
                );
              },
              home: const _Counter(),
            );
          },
        ),
      );

      await tester.tap(find.text('add'));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);

      padding.value = const EdgeInsets.only(top: 47, bottom: 34);
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('rebuilds after resume so system-nav changes are applied',
        (tester) async {
      late double bottom;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                viewPadding: const EdgeInsets.only(top: 47, bottom: 48),
                padding: const EdgeInsets.only(top: 47, bottom: 48),
              ),
              child: SmartSafeAreaHost(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          home: Builder(
            builder: (context) {
              bottom = SmartSafeAreaInsets.of(context).contentBottom;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(bottom, 48);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump();

      expect(find.byType(SmartSafeAreaHost), findsOneWidget);
      expect(bottom, 48);
    });

    testWidgets('prefers live FlutterView insets when MediaQuery is stale',
        (tester) async {
      tester.view.padding = const FakeViewPadding(top: 47, bottom: 24);
      tester.view.viewPadding = const FakeViewPadding(top: 47, bottom: 24);
      addTearDown(tester.view.reset);

      late double contentBottom;
      late SystemNavMode mode;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                viewPadding: const EdgeInsets.only(top: 47, bottom: 48),
                padding: const EdgeInsets.only(top: 47, bottom: 48),
              ),
              child: SmartSafeAreaHost(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
          home: Builder(
            builder: (context) {
              final insets = SmartSafeAreaInsets.of(context);
              contentBottom = insets.contentBottom;
              mode = insets.navMode;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(mode, SystemNavMode.gesture);
      expect(contentBottom, 0);
    });
  });

  group('SmartSafeAreaHost.materialBuilder', () {
    testWidgets('then wraps the route child inside the host', (tester) async {
      const innerKey = Key('then-child');
      await tester.pumpWidget(
        MaterialApp(
          builder: SmartSafeAreaHost.materialBuilder(
            then: (context, child) {
              return KeyedSubtree(
                key: innerKey,
                child: child ?? const SizedBox.shrink(),
              );
            },
          ),
          home: const SizedBox.shrink(),
        ),
      );

      expect(
        find.descendant(
          of: find.byType(SmartSafeAreaHost),
          matching: find.byKey(innerKey),
        ),
        findsOneWidget,
      );
    });
  });

  group('SmartSystemNavBar', () {
    testWidgets('adds a 3-button filler under the tab row', (tester) async {
      late double childViewBottom;
      await tester.pumpWidget(
        _harness(
          viewPadding: const EdgeInsets.only(bottom: 48),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SmartSystemNavBar(
              color: const Color(0xFFFF0000),
              child: Builder(
                builder: (context) {
                  childViewBottom = MediaQuery.viewPaddingOf(context).bottom;
                  return const SizedBox(height: 56, width: double.infinity);
                },
              ),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(SmartSystemNavBar)).height, 104);
      expect(childViewBottom, 0);
    });

    testWidgets('does not add filler on gesture devices', (tester) async {
      await tester.pumpWidget(
        _harness(
          viewPadding: const EdgeInsets.only(bottom: 34),
          child: const Align(
            alignment: Alignment.bottomCenter,
            child: SmartSystemNavBar(
              color: Color(0xFFFF0000),
              child: SizedBox(height: 56, width: double.infinity),
            ),
          ),
        ),
      );

      expect(tester.getSize(find.byType(SmartSystemNavBar)).height, 56);
    });
  });

  group('SmartSafeAreaScaffold', () {
    testWidgets('insets the whole screen when extendBackground is false',
        (tester) async {
      await tester.pumpWidget(
        _harness(
          viewPadding: const EdgeInsets.only(top: 47, bottom: 34),
          child: const SmartSafeAreaScaffold(
            extendBackground: false,
            backgroundColor: Color(0xFF3F51B5),
            letterboxColor: Color(0xFF000000),
            body: Text('body'),
          ),
        ),
      );

      expect(find.text('body'), findsOneWidget);
      final padding = tester.widget<Padding>(
        find
            .ancestor(
              of: find.byType(Scaffold),
              matching: find.byType(Padding),
            )
            .first,
      );
      final insets = padding.padding.resolve(TextDirection.ltr);
      expect(insets.top, 47);
      expect(insets.bottom, 34);
    });

    testWidgets('lifts the FAB above 3-button nav', (tester) async {
      await tester.pumpWidget(
        _harness(
          viewPadding: const EdgeInsets.only(bottom: 48),
          child: SmartSafeAreaScaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
            body: const SizedBox.expand(),
          ),
        ),
      );

      final fabPadding = tester.widget<Padding>(
        find.ancestor(
          of: find.byType(FloatingActionButton),
          matching: find.byType(Padding),
        ),
      );
      expect(fabPadding.padding.resolve(TextDirection.ltr).bottom, 48);
    });
  });

  group('SmartSafeAreaSimulator', () {
    testWidgets('simulates 3-button nav on any device', (tester) async {
      late SystemNavMode mode;
      late double content;
      await tester.pumpWidget(
        const MaterialApp(
          home: SmartSafeAreaSimulator(
            nav: SimulatedSystemNav.threeButton,
            top: 47,
            child: _Capture(),
          ),
        ),
      );
      final state = tester.state<_CaptureState>(find.byType(_Capture));
      mode = state.mode;
      content = state.contentBottom;

      expect(mode, SystemNavMode.threeButton);
      expect(content, 48);
    });
  });
}

class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$_count'),
        TextButton(
          onPressed: () => setState(() => _count += 1),
          child: const Text('add'),
        ),
      ],
    );
  }
}

class _Capture extends StatefulWidget {
  const _Capture();

  @override
  State<_Capture> createState() => _CaptureState();
}

class _CaptureState extends State<_Capture> {
  late SystemNavMode mode;
  late double contentBottom;

  @override
  Widget build(BuildContext context) {
    mode = SystemNav.modeOf(context);
    contentBottom = SmartSafeAreaInsets.of(context).contentBottom;
    return const SizedBox.shrink();
  }
}

Widget _harness({
  required EdgeInsets viewPadding,
  required Widget child,
  SmartSafeAreaConfig? config,
}) {
  return MaterialApp(
    builder: (context, appChild) {
      Widget wrapped = MediaQuery(
        data: MediaQuery.of(context).copyWith(
          viewPadding: viewPadding,
          padding: viewPadding,
        ),
        child: appChild ?? child,
      );
      if (config != null) {
        wrapped = SmartSafeAreaScope(config: config, child: wrapped);
      }
      return wrapped;
    },
    home: child,
  );
}
