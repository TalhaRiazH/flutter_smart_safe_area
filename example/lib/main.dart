import 'package:flutter/material.dart';
import 'package:flutter_smart_safe_area/flutter_smart_safe_area.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SmartSafeAreaHost.ensureEdgeToEdge();
  runApp(const SmartSafeAreaExampleApp());
}

class SmartSafeAreaExampleApp extends StatefulWidget {
  const SmartSafeAreaExampleApp({super.key});

  @override
  State<SmartSafeAreaExampleApp> createState() =>
      _SmartSafeAreaExampleAppState();
}

class _SmartSafeAreaExampleAppState extends State<SmartSafeAreaExampleApp> {
  bool _extendBackground = true;
  BottomSafeAreaBehavior _behavior = BottomSafeAreaBehavior.auto;
  SimulatedSystemNav _simulated = SimulatedSystemNav.device;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF6EA8FF),
      ),
      builder: (context, child) {
        return SmartSafeAreaSimulator(
          nav: _simulated,
          top: _simulated == SimulatedSystemNav.device ? null : 47,
          child: SmartSafeAreaHost(
            config: SmartSafeAreaConfig(
              extendBackground: _extendBackground,
              bottomBehavior: _behavior,
            ),
            showDebugOverlay: true,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
      home: _HomeScreen(
        extendBackground: _extendBackground,
        behavior: _behavior,
        simulated: _simulated,
        onExtendBackground: (value) {
          setState(() => _extendBackground = value);
        },
        onBehavior: (value) {
          setState(() => _behavior = value);
        },
        onSimulated: (value) {
          setState(() => _simulated = value);
        },
      ),
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen({
    required this.extendBackground,
    required this.behavior,
    required this.simulated,
    required this.onExtendBackground,
    required this.onBehavior,
    required this.onSimulated,
  });

  final bool extendBackground;
  final BottomSafeAreaBehavior behavior;
  final SimulatedSystemNav simulated;
  final ValueChanged<bool> onExtendBackground;
  final ValueChanged<BottomSafeAreaBehavior> onBehavior;
  final ValueChanged<SimulatedSystemNav> onSimulated;

  @override
  Widget build(BuildContext context) {
    final insets = context.smartSafeArea;

    return SmartSafeAreaScaffold(
      extendBackground: extendBackground,
      bottomBehavior: behavior,
      letterboxColor: const Color(0xFF05070D),
      backgroundColor: const Color(0xFF10203A),
      backgroundGradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF2B4C7E),
          Color(0xFF10203A),
          Color(0xFF0A1220),
        ],
      ),
      bottomNavigationBar: const _DemoTabBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          Text(
            'flutter_smart_safe_area',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Background stays edge-to-edge. Buttons, text, and images inset '
            'only when 3-button system navigation is showing.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          _InfoCard(
            title: 'Detected',
            rows: [
              ('Nav mode', insets.navMode.name),
              ('Raw bottom', '${insets.rawBottom.toStringAsFixed(0)} dp'),
              (
                'Content bottom',
                '${insets.contentBottom.toStringAsFixed(0)} dp'
              ),
              ('Top inset', '${insets.content.top.toStringAsFixed(0)} dp'),
            ],
          ),
          const SizedBox(height: 16),
          _Panel(
            title: 'Simulate a device',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final nav in SimulatedSystemNav.values)
                  ChoiceChip(
                    label: Text(nav.name),
                    selected: simulated == nav,
                    onSelected: (_) => onSimulated(nav),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _Panel(
            title: 'Background behind system nav',
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('extendBackground'),
              subtitle: Text(
                extendBackground
                    ? 'Color / gradient can sit behind the system nav'
                    : 'Everything, including the background, is inset',
              ),
              value: extendBackground,
              onChanged: onExtendBackground,
            ),
          ),
          const SizedBox(height: 12),
          _Panel(
            title: 'Bottom behavior',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final value in BottomSafeAreaBehavior.values)
                      ChoiceChip(
                        label: Text(value.name),
                        selected: behavior == value,
                        onSelected: (_) => onBehavior(value),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(_behaviorHint(behavior)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Sample button (content, so it is inset)'),
          ),
          const SizedBox(height: 12),
          const Card(
            child: ListTile(
              leading: Icon(Icons.image_outlined),
              title: Text('Sample image / card'),
              subtitle: Text('In-screen elements stay in the safe region'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _behaviorHint(BottomSafeAreaBehavior value) {
    return switch (value) {
      BottomSafeAreaBehavior.auto =>
        '3-button: inset. Gesture: flush with the edge.',
      BottomSafeAreaBehavior.always => 'Always apply the raw bottom inset.',
      BottomSafeAreaBehavior.never => 'Never apply a bottom inset.',
    };
  }
}

class _DemoTabBar extends StatelessWidget {
  const _DemoTabBar();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFF15233A),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _TabIcon(icon: Icons.home_outlined, label: 'Home'),
            _TabIcon(icon: Icons.explore_outlined, label: 'Explore'),
            _TabIcon(icon: Icons.settings_outlined, label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

class _TabIcon extends StatelessWidget {
  const _TabIcon({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.rows});

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: title,
      child: Column(
        children: [
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: Text(row.$1)),
                  Text(
                    row.$2,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
