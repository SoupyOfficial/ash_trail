// Reachability Audit Screen
// Main UI for performing and viewing reachability audits

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reachability_providers.dart';
import '../widgets/audit_report_card.dart';
import '../widgets/reachability_zone_overlay.dart';
import '../widgets/audit_controls.dart';
import '../../domain/entities/reachability_audit_report.dart';

class ReachabilityAuditScreen extends ConsumerStatefulWidget {
  const ReachabilityAuditScreen({super.key});

  @override
  ConsumerState<ReachabilityAuditScreen> createState() =>
      _ReachabilityAuditScreenState();
}

class _ReachabilityAuditScreenState
    extends ConsumerState<ReachabilityAuditScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reachability & Ergonomics'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.analytics_outlined),
              text: 'Audit',
            ),
            Tab(
              icon: Icon(Icons.history),
              text: 'Reports',
            ),
            Tab(
              icon: Icon(Icons.touch_app_outlined),
              text: 'Zones',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _AuditTab(),
          _ReportsTab(),
          _ZonesTab(),
        ],
      ),
    );
  }
}

class _AuditTab extends ConsumerWidget {
  const _AuditTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentReport = ref.watch(currentAuditReportProvider);
    final isAuditInProgress = ref.watch(isAuditInProgressProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Reachability Audit',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Analyze UI elements for thumb zone accessibility and ergonomics compliance.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          const AuditControls(),
          const SizedBox(height: 24),
          if (currentReport != null) ...[
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    AuditReportCard(report: currentReport),
                    const SizedBox(height: 16),
                    _ComplianceScoreCard(report: currentReport),
                    const SizedBox(height: 16),
                    _RecommendationsCard(report: currentReport),
                  ],
                ),
              ),
            ),
          ] else if (isAuditInProgress) ...[
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Performing reachability audit...'),
                  ],
                ),
              ),
            ),
          ] else ...[
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Start an audit to analyze reachability',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReportsTab extends ConsumerWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(auditReportsListProvider);

    return reportsAsync.when(
      data: (reports) {
        if (reports.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No audit reports yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Run an audit to generate your first report',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AuditReportCard(
                report: report,
                onTap: () => _showReportDetails(context, ref, report),
                onDelete: () => _deleteReport(context, ref, report.id),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load reports',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(auditReportsListProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDetails(
      BuildContext context, WidgetRef ref, ReachabilityAuditReport report) {
    ref.read(currentAuditReportProvider.notifier).setCurrentReport(report);
    // Navigate to audit tab to show details
    if (context.findAncestorStateOfType<_ReachabilityAuditScreenState>() !=
        null) {
      context
          .findAncestorStateOfType<_ReachabilityAuditScreenState>()!
          ._tabController
          .animateTo(0);
    }
  }

  void _deleteReport(BuildContext context, WidgetRef ref, String reportId) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text(
            'Are you sure you want to delete this audit report? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(auditReportsListProvider.notifier)
                  .deleteReport(reportId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _ZonesTab extends ConsumerWidget {
  const _ZonesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final zonesAsync = ref.watch(reachabilityZonesProvider(screenSize));

    return zonesAsync.when(
      data: (zones) {
        return Stack(
          children: [
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: const Center(
                child: Text(
                  'Reachability Zone Visualization',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            ReachabilityZoneOverlay(zones: zones),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load zones',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.refresh(reachabilityZonesProvider(screenSize)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComplianceScoreCard extends StatelessWidget {
  const _ComplianceScoreCard({required this.report});

  final ReachabilityAuditReport report;

  @override
  Widget build(BuildContext context) {
    final score = report.complianceScore;
    final percentage = (score * 100).round();
    final passes = report.passesAudit;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  passes ? Icons.check_circle : Icons.warning,
                  color: passes ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Compliance Score',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: score,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                passes ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$percentage% compliant',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: passes ? Colors.green : Colors.orange,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              passes
                  ? 'Meets minimum accessibility standards'
                  : 'Below recommended accessibility threshold (60%)',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationsCard extends StatelessWidget {
  const _RecommendationsCard({required this.report});

  final ReachabilityAuditReport report;

  @override
  Widget build(BuildContext context) {
    final recommendations = report.recommendations ?? [];

    if (recommendations.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Recommendations',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('No recommendations needed - great job!'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  'Recommendations (${recommendations.length})',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...recommendations.take(5).map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _getPriorityColor(rec.priority).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'P${rec.priority}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getPriorityColor(rec.priority),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rec.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            if (rec.suggestedFix != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                rec.suggestedFix!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
            if (recommendations.length > 5) ...[
              const SizedBox(height: 8),
              Text(
                '${recommendations.length - 5} more recommendations...',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    return switch (priority) {
      1 => Colors.red,
      2 => Colors.orange,
      3 => Colors.blue,
      _ => Colors.grey,
    };
  }
}
