import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../models/app_settings.dart';
import '../../models/home_widget_config.dart';
import '../../models/log_record.dart';
import '../../utils/design_constants.dart';
import '../../utils/responsive_layout.dart';
import 'home_widget_builder.dart';
import 'home_widget_wrapper.dart';
import 'widget_catalog.dart';

/// A responsive, drag-and-drop grid dashboard that replaces the former
/// [ReorderableListView]-based layout.
///
/// Uses [StaggeredGrid.count] for multi-span tile placement and
/// [LongPressDraggable] + [DragTarget] for grid-level reorder.
class DashboardGrid extends StatefulWidget {
  final List<HomeWidgetConfig> visibleWidgets;
  final List<LogRecord> records;
  final bool isEditMode;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(HomeWidgetConfig config) onRemove;
  final VoidCallback? onLogCreated;
  final VoidCallback? onRecordTap;
  final Future<void> Function(LogRecord)? onRecordDelete;
  final DashboardDensity density;
  final bool reduceMotion;

  const DashboardGrid({
    super.key,
    required this.visibleWidgets,
    required this.records,
    required this.isEditMode,
    required this.onReorder,
    required this.onRemove,
    this.onLogCreated,
    this.onRecordTap,
    this.onRecordDelete,
    this.density = DashboardDensity.comfortable,
    this.reduceMotion = false,
  });

  @override
  State<DashboardGrid> createState() => _DashboardGridState();
}

class _DashboardGridState extends State<DashboardGrid> {
  /// ID of the widget currently being dragged (null when idle).
  String? _draggedWidgetId;

  /// Flat index of the current drop-preview position (local state,
  /// does NOT trigger Riverpod rebuilds — see plan note #9).
  final ValueNotifier<int?> _dropPreviewIndex = ValueNotifier(null);

  final ScrollController _scrollController = ScrollController();

  /// Tracks the last grid column count so we can cancel drag on orientation
  /// change (plan note #17).
  int? _lastCrossAxisCount;

  @override
  void dispose() {
    _dropPreviewIndex.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(DashboardGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cancel drag if edit mode was turned off or widget list changed
    if (!widget.isEditMode && _draggedWidgetId != null) {
      _cancelDrag();
    }
  }

  void _cancelDrag() {
    setState(() {
      _draggedWidgetId = null;
    });
    _dropPreviewIndex.value = null;
  }

  @override
  Widget build(BuildContext context) {
    final gridConfig = DashboardGridConfig.withDensity(
      width: MediaQuery.of(context).size.width,
      density: widget.density,
    );
    final crossAxisCount = gridConfig.crossAxisCount;

    // Cancel drag if column count changed (orientation/resize — plan note #17)
    if (_lastCrossAxisCount != null &&
        _lastCrossAxisCount != crossAxisCount &&
        _draggedWidgetId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _cancelDrag());
    }
    _lastCrossAxisCount = crossAxisCount;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Guard against zero-width constraints (see plan bug #1)
        if (constraints.maxWidth <= 0) {
          return const SizedBox.shrink();
        }

        if (widget.visibleWidgets.isEmpty) {
          return _buildEmptyState(context);
        }

        return SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.all(gridConfig.padding),
          child: StaggeredGrid.count(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: gridConfig.crossAxisSpacing,
            mainAxisSpacing: gridConfig.mainAxisSpacing,
            children: _buildGridTiles(crossAxisCount),
          ),
        );
      },
    );
  }

  List<Widget> _buildGridTiles(int crossAxisCount) {
    return List.generate(widget.visibleWidgets.length, (index) {
      final config = widget.visibleWidgets[index];
      final entry = WidgetCatalog.getEntry(config.type);
      final span = entry.size
          .columnSpan(crossAxisCount)
          .clamp(1, crossAxisCount);

      final tileChild = _buildTileContent(config, index);

      if (!widget.isEditMode) {
        return StaggeredGridTile.fit(
          crossAxisCellCount: span,
          child: KeyedSubtree(key: ValueKey(config.id), child: tileChild),
        );
      }

      // Edit mode: wrap in LongPressDraggable + DragTarget
      return StaggeredGridTile.fit(
        crossAxisCellCount: span,
        child: _buildDraggableTile(config, index, crossAxisCount),
      );
    });
  }

  Widget _buildTileContent(HomeWidgetConfig config, int index) {
    return HomeWidgetWrapper(
      widgetId: config.id,
      type: config.type,
      isEditMode: widget.isEditMode,
      reduceMotion: widget.reduceMotion,
      onRemove: () => widget.onRemove(config),
      child: HomeWidgetEditPadding(
        isEditMode: widget.isEditMode,
        reduceMotion: widget.reduceMotion,
        child: HomeWidgetBuilder(
          config: config,
          records: widget.records,
          onLogCreated: widget.onLogCreated,
          onRecordTap: widget.onRecordTap,
          onRecordDelete: widget.onRecordDelete,
        ),
      ),
    );
  }

  Widget _buildDraggableTile(
    HomeWidgetConfig config,
    int index,
    int crossAxisCount,
  ) {
    final isDragging = _draggedWidgetId == config.id;

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) {
        final draggedId = details.data;
        if (draggedId == config.id) return false;
        _dropPreviewIndex.value = index;
        return true;
      },
      onLeave: (_) {
        // Only clear if we're still pointing at this index
        if (_dropPreviewIndex.value == index) {
          _dropPreviewIndex.value = null;
        }
      },
      onAcceptWithDetails: (details) {
        final draggedId = details.data;
        final oldIndex = widget.visibleWidgets.indexWhere(
          (w) => w.id == draggedId,
        );
        if (oldIndex == -1 || oldIndex == index) return;
        HapticFeedback.mediumImpact();
        widget.onReorder(oldIndex, index);
        _dropPreviewIndex.value = null;
      },
      builder: (context, candidateData, rejectedData) {
        final isDropTarget = candidateData.isNotEmpty;

        return LongPressDraggable<String>(
          data: config.id,
          delay: const Duration(milliseconds: 300),
          hapticFeedbackOnStart: true,
          maxSimultaneousDrags: 1,
          dragAnchorStrategy: childDragAnchorStrategy,
          rootOverlay: true,
          onDragStarted: () {
            HapticFeedback.selectionClick();
            setState(() {
              _draggedWidgetId = config.id;
            });
          },
          onDragEnd: (_) {
            _cancelDrag();
          },
          onDraggableCanceled: (_, __) {
            _cancelDrag();
          },
          // Feedback: sized widget shown under the finger
          feedback: _buildDragFeedback(config, index, crossAxisCount),
          // Placeholder at original position during drag
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: KeyedSubtree(
              key: ValueKey('dragging_${config.id}'),
              child: _buildTileContent(config, index),
            ),
          ),
          child: AnimatedContainer(
            duration: resolveAnimationDuration(
              const Duration(milliseconds: 200),
              widget.reduceMotion,
            ),
            decoration:
                isDropTarget
                    ? BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    )
                    : null,
            child: KeyedSubtree(
              key: ValueKey(config.id),
              child:
                  isDragging
                      ? Opacity(
                        opacity: 0.3,
                        child: _buildTileContent(config, index),
                      )
                      : _buildTileContent(config, index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDragFeedback(
    HomeWidgetConfig config,
    int index,
    int crossAxisCount,
  ) {
    // Give explicit dimensions — feedback widget renders in Overlay
    // and doesn't inherit parent constraints (see plan note #4).
    final gridConfig = DashboardGridConfig.withDensity(
      width: MediaQuery.of(context).size.width,
      density: widget.density,
    );
    final entry = WidgetCatalog.getEntry(config.type);
    final span = entry.size.columnSpan(crossAxisCount).clamp(1, crossAxisCount);

    final availableWidth =
        MediaQuery.of(context).size.width -
        (gridConfig.padding * 2) -
        (gridConfig.crossAxisSpacing * (crossAxisCount - 1));
    final cellWidth = availableWidth / crossAxisCount;
    final tileWidth =
        cellWidth * span + gridConfig.crossAxisSpacing * (span - 1);

    return SizedBox(
      width: tileWidth,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: _buildTileContent(config, index),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_outlined,
            size: 80,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No widgets on your dashboard',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the edit button to add widgets',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
