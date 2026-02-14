import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widget_catalog.dart';

/// Wrapper component for home widgets that provides:
/// - Drag handle in edit mode (whole header bar is the drag affordance)
/// - Remove button in edit mode
/// - Consistent styling and animation
class HomeWidgetWrapper extends StatelessWidget {
  final String widgetId;
  final HomeWidgetType type;
  final Widget child;
  final bool isEditMode;
  final VoidCallback? onRemove;

  const HomeWidgetWrapper({
    super.key,
    required this.widgetId,
    required this.type,
    required this.child,
    required this.isEditMode,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final entry = WidgetCatalog.getEntry(type);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: EdgeInsets.symmetric(
        horizontal: isEditMode ? 4 : 0,
        vertical: isEditMode ? 4 : 0,
      ),
      decoration:
          isEditMode
              ? BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  width: 2,
                ),
              )
              : null,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          // Main widget content - fill available space
          SizedBox(width: double.infinity, child: child),

          // Edit mode overlay
          if (isEditMode) ...[
            // Drag handle at top (whole header is the drag affordance)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildDragHandle(context, entry),
            ),

            // Remove button at top-right
            Positioned(top: 4, right: 4, child: _buildRemoveButton(context)),
          ],
        ],
      ),
    );
  }

  Widget _buildDragHandle(BuildContext context, WidgetCatalogEntry entry) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Row(
        children: [
          // Drag handle icon
          MouseRegion(
            cursor: SystemMouseCursors.grab,
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                Icons.drag_handle,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Widget name
          Expanded(
            child: Text(
              entry.displayName,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoveButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onRemove?.call();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.close,
            color: Theme.of(context).colorScheme.onErrorContainer,
            size: 16,
          ),
        ),
      ),
    );
  }
}

/// A simple wrapper for widgets that just need padding in edit mode
class HomeWidgetEditPadding extends StatelessWidget {
  final Widget child;
  final bool isEditMode;

  const HomeWidgetEditPadding({
    super.key,
    required this.child,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(top: isEditMode ? 36 : 0),
      child: child,
    );
  }
}
