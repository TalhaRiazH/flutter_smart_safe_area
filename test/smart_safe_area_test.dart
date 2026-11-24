import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_safe_area/smart_safe_area.dart';

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

  group('SmartSafeArea', () {
    testWidgets('pads content on 3-button and leaves top inset', (tester) async {
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
