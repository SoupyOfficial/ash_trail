import 'package:flutter/material.dart';
import '../../responsive/presentation/widgets/adaptive_layout.dart';
import '../../responsive/presentation/widgets/responsive_padding.dart';
import '../../responsive/presentation/widgets/min_tap_target.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      mobile: const _MobileLogsView(),
      tablet: const _TabletLogsView(),
      desktop: const _DesktopLogsView(),
    );
  }
}

class _MobileLogsView extends StatelessWidget {
  const _MobileLogsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
        centerTitle: true,
      ),
      body: ResponsivePadding(
        child: Column(
          children: [
            const Text('Mobile Logs View'),
            const ResponsiveGap(mobile: 16.0),
            ResponsiveButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add new log')),
                );
              },
              child: const Text('Add Log'),
            ),
            const Expanded(
              child: Center(
                child: Text('Log list will appear here'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabletLogsView extends StatelessWidget {
  const _TabletLogsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
        centerTitle: false,
      ),
      body: ResponsivePadding(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Logs',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const ResponsiveGap(tablet: 20.0),
            Row(
              children: [
                ResponsiveButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add new log')),
                    );
                  },
                  child: const Text('Add Log'),
                ),
                const SizedBox(width: 16),
                ResponsiveButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filter logs')),
                    );
                  },
                  child: const Text('Filter'),
                ),
              ],
            ),
            const ResponsiveGap(tablet: 24.0),
            const Expanded(
              child: Center(
                child: Text('Tablet log table will appear here'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopLogsView extends StatelessWidget {
  const _DesktopLogsView();

  @override
  Widget build(BuildContext context) {
    return DualPaneLayout(
      primary: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Logs',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const ResponsiveGap(desktop: 24.0),
            Row(
              children: [
                ResponsiveButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add new log')),
                    );
                  },
                  child: const Text('Add Log'),
                ),
                const SizedBox(width: 16),
                ResponsiveButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Filter logs')),
                    );
                  },
                  child: const Text('Filter'),
                ),
                const SizedBox(width: 16),
                ResponsiveButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export logs')),
                    );
                  },
                  child: const Text('Export'),
                ),
              ],
            ),
            const ResponsiveGap(desktop: 32.0),
            const Expanded(
              child: Center(
                child: Text('Desktop log table will appear here'),
              ),
            ),
          ],
        ),
      ),
      secondary: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log Details',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const ResponsiveGap(desktop: 16.0),
            const Expanded(
              child: Center(
                child: Text('Selected log details will appear here'),
              ),
            ),
          ],
        ),
      ),
      divider: const VerticalDivider(),
    );
  }
}
