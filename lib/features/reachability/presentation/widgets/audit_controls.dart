// Audit controls widget
// Interface for starting and managing reachability audits

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reachability_providers.dart';
import '../../domain/entities/ui_element.dart';

class AuditControls extends ConsumerStatefulWidget {
  const AuditControls({super.key});

  @override
  ConsumerState<AuditControls> createState() => _AuditControlsState();
}

class _AuditControlsState extends ConsumerState<AuditControls> {
  final _screenNameController = TextEditingController();
  bool _isPerformingAudit = false;

  @override
  void initState() {
    super.initState();
    _screenNameController.text = 'Sample Screen';
  }

  @override
  void dispose() {
    _screenNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentReport = ref.watch(currentAuditReportProvider);
    final hasCurrentReport = currentReport != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Audit Controls',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Screen name input
            TextFormField(
              controller: _screenNameController,
              decoration: const InputDecoration(
                labelText: 'Screen Name',
                hintText: 'Enter the name of the screen to audit',
                prefixIcon: Icon(Icons.label_outline),
                border: OutlineInputBorder(),
              ),
              enabled: !_isPerformingAudit,
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isPerformingAudit ? null : _performSampleAudit,
                    child: _isPerformingAudit
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Running Audit...'),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.analytics),
                              SizedBox(width: 8),
                              Text('Run Sample Audit'),
                            ],
                          ),
                  ),
                ),
                if (hasCurrentReport) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _saveCurrentReport,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.save),
                        SizedBox(width: 8),
                        Text('Save'),
                      ],
                    ),
                  ),
                ],
                if (hasCurrentReport) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _clearCurrentReport,
                    child: const Text('Clear'),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // Audit instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'How it works',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Analyzes UI elements for thumb zone accessibility\n'
                    '• Checks minimum touch target sizes (48dp)\n'
                    '• Evaluates semantic labeling for screen readers\n'
                    '• Provides recommendations for improvements',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performSampleAudit() async {
    if (_screenNameController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a screen name');
      return;
    }

    setState(() {
      _isPerformingAudit = true;
    });

    try {
      final screenSize = MediaQuery.of(context).size;
      final sampleElements = _generateSampleElements(screenSize);

      await ref.read(currentAuditReportProvider.notifier).performAudit(
            screenName: _screenNameController.text.trim(),
            screenSize: screenSize,
            elements: sampleElements,
          );

      if (mounted) {
        _showSuccessSnackBar('Audit completed successfully!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Audit failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPerformingAudit = false;
        });
      }
    }
  }

  Future<void> _saveCurrentReport() async {
    try {
      await ref.read(currentAuditReportProvider.notifier).saveCurrentReport();
      if (mounted) {
        _showSuccessSnackBar('Report saved successfully!');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to save report: ${e.toString()}');
      }
    }
  }

  void _clearCurrentReport() {
    ref.read(currentAuditReportProvider.notifier).clearCurrentReport();
    _showInfoSnackBar('Report cleared');
  }

  List<UiElement> _generateSampleElements(Size screenSize) {
    // Generate sample UI elements for demonstration
    return [
      // Top navigation (difficult to reach)
      UiElement(
        id: 'nav_back',
        label: 'Back Button',
        bounds: Rect.fromLTWH(16, 50, 44, 44),
        type: UiElementType.navigationItem,
        isInteractive: true,
        semanticLabel: 'Navigate back',
      ),

      // Title (unreachable for interaction)
      UiElement(
        id: 'title',
        label: 'Screen Title',
        bounds: Rect.fromLTWH(80, 50, screenSize.width - 120, 44),
        type: UiElementType.other,
        isInteractive: false,
      ),

      // Menu button (difficult to reach)
      UiElement(
        id: 'menu',
        label: 'Menu',
        bounds: Rect.fromLTWH(screenSize.width - 60, 50, 44, 44),
        type: UiElementType.navigationItem,
        isInteractive: true,
        semanticLabel: 'Open menu',
      ),

      // Search field (moderate reach)
      UiElement(
        id: 'search',
        label: 'Search',
        bounds: Rect.fromLTWH(
            16, screenSize.height * 0.25, screenSize.width - 32, 48),
        type: UiElementType.textField,
        isInteractive: true,
        semanticLabel: 'Search field',
      ),

      // Primary action button (easy reach)
      UiElement(
        id: 'primary_action',
        label: 'Start Recording',
        bounds: Rect.fromLTWH(
          (screenSize.width - 200) / 2,
          screenSize.height * 0.7,
          200,
          56,
        ),
        type: UiElementType.actionButton,
        isInteractive: true,
        semanticLabel: 'Start recording session',
        hasAlternativeAccess: true,
      ),

      // Secondary button (easy reach)
      UiElement(
        id: 'secondary_action',
        label: 'View Logs',
        bounds: Rect.fromLTWH(
          (screenSize.width - 150) / 2,
          screenSize.height * 0.8,
          150,
          44,
        ),
        type: UiElementType.button,
        isInteractive: true,
        semanticLabel: 'View previous logs',
      ),

      // Bottom navigation (easy reach)
      UiElement(
        id: 'bottom_nav_1',
        label: 'Home',
        bounds: Rect.fromLTWH(
          screenSize.width * 0.1,
          screenSize.height - 80,
          screenSize.width * 0.2,
          48,
        ),
        type: UiElementType.navigationItem,
        isInteractive: true,
        semanticLabel: 'Home tab',
      ),

      UiElement(
        id: 'bottom_nav_2',
        label: 'History',
        bounds: Rect.fromLTWH(
          screenSize.width * 0.4,
          screenSize.height - 80,
          screenSize.width * 0.2,
          48,
        ),
        type: UiElementType.navigationItem,
        isInteractive: true,
      ), // Missing semantic label - will trigger recommendation

      UiElement(
        id: 'bottom_nav_3',
        label: 'Settings',
        bounds: Rect.fromLTWH(
          screenSize.width * 0.7,
          screenSize.height - 80,
          screenSize.width * 0.2,
          48,
        ),
        type: UiElementType.navigationItem,
        isInteractive: true,
        semanticLabel: 'Settings tab',
      ),

      // Small touch target (will trigger recommendation)
      UiElement(
        id: 'small_button',
        label: 'Info',
        bounds: Rect.fromLTWH(
            screenSize.width - 40, screenSize.height * 0.3, 24, 24),
        type: UiElementType.button,
        isInteractive: true,
        semanticLabel: 'Information',
      ),
    ];
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
