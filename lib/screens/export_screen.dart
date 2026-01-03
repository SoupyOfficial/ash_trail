import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/log_record_provider.dart';
import '../services/export_service.dart';

/// Provider for ExportService
final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});

/// Export/Import Screen per design doc 23. Import - Export
/// Provides UI for exporting and importing log data
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool _isExporting = false;
  final bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import / Export')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Export section
            _buildSectionHeader(context, 'Export Data', Icons.upload),
            const SizedBox(height: 8),
            Text(
              'Export your log entries for backup or use in other apps.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _buildExportCard(
              context,
              title: 'Export as CSV',
              description:
                  'Flat format for spreadsheets (Excel, Google Sheets)',
              icon: Icons.table_chart,
              onTap: _isExporting ? null : () => _exportCsv(),
            ),
            const SizedBox(height: 8),
            _buildExportCard(
              context,
              title: 'Export as JSON',
              description: 'Full-fidelity backup format',
              icon: Icons.data_object,
              onTap: _isExporting ? null : () => _exportJson(),
            ),
            const SizedBox(height: 24),

            // Import section
            _buildSectionHeader(context, 'Import Data', Icons.download),
            const SizedBox(height: 8),
            Text(
              'Import log entries from a backup file.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            _buildImportCard(
              context,
              title: 'Import from CSV',
              description: 'Import entries from a CSV file',
              icon: Icons.table_chart,
              onTap: _isImporting ? null : () => _importCsv(),
            ),
            const SizedBox(height: 8),
            _buildImportCard(
              context,
              title: 'Import from JSON',
              description: 'Restore from a JSON backup',
              icon: Icons.data_object,
              onTap: _isImporting ? null : () => _importJson(),
            ),
            const SizedBox(height: 24),

            // Info card
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Exported data only includes entries from your current account. '
                        'Imports will be validated before adding to your account.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }

  Widget _buildExportCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing:
            _isExporting
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildImportCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing:
            _isImporting
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Future<void> _exportCsv() async {
    setState(() => _isExporting = true);

    try {
      final records = await ref.read(activeAccountLogRecordsProvider.future);
      final exportService = ref.read(exportServiceProvider);

      final csvContent = await exportService.exportToCsv(records);

      // Copy to clipboard as a fallback (share_plus would be better)
      await Clipboard.setData(ClipboardData(text: csvContent));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported ${records.length} records to clipboard'),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportJson() async {
    setState(() => _isExporting = true);

    try {
      final records = await ref.read(activeAccountLogRecordsProvider.future);
      final exportService = ref.read(exportServiceProvider);

      final jsonContent = await exportService.exportToJson(records);

      // Copy to clipboard (share_plus not available)
      await Clipboard.setData(ClipboardData(text: jsonContent));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Exported ${records.length} records - copied to clipboard',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _importCsv() async {
    // TODO: Implement file picker for CSV import
    // Per design doc 23.6.1: Validate before mutation
    // Per design doc 23.6.2: Handle conflicts

    _showNotImplementedDialog('CSV Import');
  }

  Future<void> _importJson() async {
    // TODO: Implement file picker for JSON import
    // Per design doc 23.6.1: Validate before mutation
    // Per design doc 23.6.2: Handle conflicts

    _showNotImplementedDialog('JSON Import');
  }

  void _showNotImplementedDialog(String feature) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('$feature Coming Soon'),
            content: const Text(
              'This feature is planned for a future release. '
              'Export functionality is available now.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
