import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../responsive/presentation/widgets/adaptive_layout.dart';
import '../../responsive/presentation/widgets/responsive_padding.dart';
import '../../responsive/presentation/widgets/min_tap_target.dart';
import '../../loading_skeletons/presentation/widgets/widgets.dart';
import '../../haptics_baseline/presentation/providers/haptics_providers.dart';

class LogsScreen extends ConsumerWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AdaptiveLayout(
      mobile: const _MobileLogsView(),
      tablet: const _TabletLogsView(),
      desktop: const _DesktopLogsView(),
    );
  }
}

class _MobileLogsView extends ConsumerStatefulWidget {
  const _MobileLogsView();

  @override
  ConsumerState<_MobileLogsView> createState() => _MobileLogsViewState();
}

class _MobileLogsViewState extends ConsumerState<_MobileLogsView> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate loading logs
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
        centerTitle: true,
      ),
      body: LoadingStateHandler(
        isLoading: _isLoading,
        loadingWidget: const ResponsivePadding(
          child: SkeletonList(itemCount: 5),
        ),
        child: ResponsivePadding(
          child: Column(
            children: [
              const Text('Mobile Logs View'),
              const ResponsiveGap(mobile: 16.0),
              ResponsiveButton(
                onPressed: () async {
                  // Trigger impact haptic on press
                  await ref.read(hapticTriggerProvider.notifier).impactLight();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Add new log')),
                  );

                  // Trigger success haptic on completion
                  await ref.read(hapticTriggerProvider.notifier).success();
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
      ),
    );
  }
}

class _TabletLogsView extends ConsumerStatefulWidget {
  const _TabletLogsView();

  @override
  ConsumerState<_TabletLogsView> createState() => _TabletLogsViewState();
}

class _TabletLogsViewState extends ConsumerState<_TabletLogsView> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Logs'),
        centerTitle: false,
      ),
      body: LoadingStateHandler(
        isLoading: _isLoading,
        loadingWidget: ResponsivePadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonContainer(
                height: 32,
                width: 100,
                child: const SizedBox(),
              ),
              const ResponsiveGap(tablet: 20.0),
              Row(
                children: [
                  SkeletonContainer(
                    height: 40,
                    width: 80,
                    child: const SizedBox(),
                  ),
                  const SizedBox(width: 16),
                  SkeletonContainer(
                    height: 40,
                    width: 60,
                    child: const SizedBox(),
                  ),
                ],
              ),
              const ResponsiveGap(tablet: 24.0),
              const Expanded(
                child: SkeletonList(itemCount: 4),
              ),
            ],
          ),
        ),
        child: ResponsivePadding(
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
                    onPressed: () async {
                      await ref
                          .read(hapticTriggerProvider.notifier)
                          .impactLight();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Add new log')),
                      );

                      await ref.read(hapticTriggerProvider.notifier).success();
                    },
                    child: const Text('Add Log'),
                  ),
                  const SizedBox(width: 16),
                  ResponsiveButton(
                    onPressed: () async {
                      await ref.read(hapticTriggerProvider.notifier).tap();

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
      ),
    );
  }
}

class _DesktopLogsView extends ConsumerStatefulWidget {
  const _DesktopLogsView();

  @override
  ConsumerState<_DesktopLogsView> createState() => _DesktopLogsViewState();
}

class _DesktopLogsViewState extends ConsumerState<_DesktopLogsView> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoadingStateHandler(
      isLoading: _isLoading,
      loadingWidget: DualPaneLayout(
        primary: ResponsiveContainer(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonContainer(
                  height: 32,
                  width: 100,
                  child: const SizedBox(),
                ),
                const ResponsiveGap(desktop: 24.0),
                Row(
                  children: [
                    SkeletonContainer(
                      height: 40,
                      width: 80,
                      child: const SizedBox(),
                    ),
                    const SizedBox(width: 16),
                    SkeletonContainer(
                      height: 40,
                      width: 60,
                      child: const SizedBox(),
                    ),
                    const SizedBox(width: 16),
                    SkeletonContainer(
                      height: 40,
                      width: 60,
                      child: const SizedBox(),
                    ),
                  ],
                ),
                const ResponsiveGap(desktop: 32.0),
                const Expanded(
                  child: SkeletonList(itemCount: 6),
                ),
              ],
            ),
          ),
        ),
        secondary: ResponsiveContainer(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonContainer(
                  height: 24,
                  width: 120,
                  child: const SizedBox(),
                ),
                const ResponsiveGap(desktop: 16.0),
                const Expanded(
                  child: SkeletonChart(height: 200, showLegend: false),
                ),
              ],
            ),
          ),
        ),
        divider: const VerticalDivider(),
      ),
      child: DualPaneLayout(
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
      ),
    );
  }
}
