## Plan: Grid-Based Dashboard Layout Overhaul

**TL;DR** — Replace the current `ReorderableListView` + fragile compact-pairing algorithm with a responsive grid-based layout system. This addresses the brittle reorder index mapping, rigid compact pairing, lack of responsive breakpoints, and missing grid span support. The grid will adapt column count by screen size (2 on mobile, 3–4 on tablet/desktop) and each `WidgetSize` will map to a grid column span. Drag-and-drop reorder will work at the grid cell level instead of through row-index translation.

**Steps**

1. **Add `flutter_staggered_grid_view` dependency** in `pubspec.yaml`. This is the industry-standard Flutter grid package (4.7k likes, MIT license, zero non-Flutter dependencies). Use `StaggeredGrid.count` for the dashboard layout, where each tile gets a `crossAxisCellCount` derived from its `WidgetSize`.

2. **Extend `WidgetSize` with span metadata** in `lib/widgets/home_widgets/widget_catalog.dart`:
   - Add a `columnSpan` getter to `WidgetSize`: `compact` → 1, `standard` → 2, `large` → full-width (equal to the grid's `crossAxisCount`).
   - Add a `mainAxisCellCount` (row span) concept: `compact` → 1, `standard` → 1, `large` → 2. This gives heatmaps and charts more vertical room.

3. **Create a `ResponsiveGridConfig` helper** in `lib/utils/responsive_layout.dart` that computes grid parameters from `MediaQuery`:
   - Mobile portrait: `crossAxisCount: 2`
   - Mobile landscape / small tablet: `crossAxisCount: 3`
   - Tablet / desktop: `crossAxisCount: 4`
   - Returns `crossAxisSpacing`, `mainAxisSpacing`, and `padding` values that scale accordingly.

4. **Build a new `DashboardGrid` widget** (new file `lib/widgets/home_widgets/dashboard_grid.dart`):
   - Replace `ReorderableListView.builder` usage in `lib/screens/home_screen.dart`.
   - Use `StaggeredGrid.count` with tiles placed via `StaggeredGridTile.count(crossAxisCellCount, mainAxisCellCount, child)`.
   - Each tile's `crossAxisCellCount` comes from `WidgetCatalog.getEntry(config.type).size.columnSpan`, clamped to `crossAxisCount` so large widgets never overflow on small screens.
   - Wrap the grid in a `SingleChildScrollView` for scrolling.

5. **Implement drag-and-drop reorder on the grid**:
   - Use Flutter's `LongPressDraggable` + `DragTarget` pattern on each grid tile inside `DashboardGrid`. This is the Flutter-recommended approach for grid reorder (since `ReorderableListView` only works with lists).
   - Each tile wraps its child in a `LongPressDraggable<String>` (carrying the widget's `id`), and each cell position is a `DragTarget<String>` that accepts reorder drops.
   - On drop, compute the new flat index from the target position and call `HomeLayoutConfigNotifier.reorder()`.
   - Show a placeholder/ghost cell at the drop position during drag using `DragTarget.builder`'s `candidateData`.
   - Keep haptic feedback (`HapticFeedback.mediumImpact()`) on drag start and drop.

6. **Simplify reorder logic in the model** — update `reorder()` in `lib/models/home_widget_config.dart`:
   - Remove the `newIndex > oldIndex` adjustment (this was a `ReorderableListView` quirk where `newIndex` is pre-removal). The grid drag-drop gives us exact target position, so the adjustment is unnecessary.
   - Add an `undoReorder()` method that stores the previous widget order and can restore it, enabling undo for reorder operations (currently only remove has undo).

7. **Remove the row-pairing algorithm** from `lib/screens/home_screen.dart`:
   - Delete `_buildLayoutRows()` and `_getFirstWidgetIndexForRow()` — the grid handles multi-column placement natively.
   - This eliminates the fragile row→widget index mapping entirely.

8. **Update `HomeWidgetWrapper`** in `lib/widgets/home_widgets/home_widget_wrapper.dart`:
   - Remove `ReorderableDragStartListener` (it's specific to `ReorderableListView`).
   - In edit mode, the drag handle becomes the `LongPressDraggable` feedback trigger — the whole header bar is the drag affordance.
   - Keep the remove button, animated border, and `HomeWidgetEditPadding` as-is.

9. **Update `HomeScreen._buildMainViewContent()`** in `lib/screens/home_screen.dart`:
   - Replace the `ReorderableListView.builder` + `Column` with the new `DashboardGrid` widget.
   - Pass `visibleWidgets`, `records`, `isEditMode`, and callbacks to `DashboardGrid`.
   - Remove the `proxyDecorator` (replace with drag feedback styling inside `DashboardGrid`).

10. **Add responsive behavior** — update `lib/screens/home_screen.dart` to use `LayoutBuilder` or `MediaQuery` to pass the appropriate `crossAxisCount` to `DashboardGrid`. This makes the dashboard genuinely responsive across form factors.

11. **Add undo for reorder** — in `lib/screens/home_screen.dart`, after a reorder completes, show a `SnackBar` with an "UNDO" action that calls the new `undoReorder()` method on the notifier. This matches the existing undo pattern for widget removal.

12. **Add widget settings UI** — create a `WidgetSettingsSheet` (new file `lib/widgets/home_widgets/widget_settings_sheet.dart`):
    - Long-press on a widget in edit mode opens a bottom sheet with widget-specific settings (e.g., number of recent entries for `recentEntries`, number of days for `durationTrend`).
    - Calls the existing `HomeLayoutConfigNotifier.updateWidgetSettings()` which already works but has no UI.

13. **Update tests**:
    - Update `test/screens/home_screen_test.dart`: replace `ReorderableListView` expectations with grid-based assertions. Add tests for responsive column count selection.
    - Add new test file `test/widgets/dashboard_grid_test.dart`: test grid rendering, span calculations, drag-and-drop reorder, responsive breakpoints.
    - Update `test/widgets/home_widget_wrapper_test.dart`: remove `ReorderableDragStartListener` assertions, add `LongPressDraggable` assertions.
    - Add tests for `undoReorder()` in `test/models/home_widget_config_test.dart`.
    - Add provider-level tests for `HomeLayoutConfigNotifier` persistence logic (currently missing).

14. **Schema migration** — in `lib/models/home_widget_config.dart`, bump `version` to 2 in `HomeLayoutConfig`. Add migration logic in `fromJson()`: if `version == 1`, apply any necessary transforms (the model shape isn't changing fundamentally, but this ensures we handle any future span/settings additions gracefully rather than silently falling back to defaults).

**Verification**
- Run existing widget tests: `flutter test test/widgets/` — all should pass after updates
- Run existing model tests: `flutter test test/models/home_widget_config_test.dart` — all should pass plus new `undoReorder` tests
- Manual verification: confirm 2-column layout on iPhone, 3-column on iPad mini, 4-column on iPad Pro
- Manual verification: drag a widget in edit mode — it should show a ghost placeholder, drop to correct position, offer undo via snackbar
- Manual verification: compact widgets occupy 1 column, standard widgets span 2 columns, large widgets span full width
- Run `flutter analyze` — zero new warnings

**Decisions**
- **`flutter_staggered_grid_view` over `reorderable_grid_view`**: The staggered grid package (4.7k likes) is more mature and flexible with multi-span support. `reorderable_grid_view` (163 likes) has known bugs with `placeholderBuilder` in long lists and scope issues. We implement custom drag-and-drop on top of the staggered grid instead. **Confirmed**: `flutter_reorderable_grid_view` (v5.5.2, 232 likes) was also evaluated — it wraps any `GridView` with built-in drag-and-drop, auto-scroll, locked indices, and animations. However, its maintainer confirmed in [Issue #65](https://github.com/karvulf/flutter-reorderable-grid-view/issues/65) that it does **not** support staggered grids (items with different sizes), making it incompatible with our column-span requirements.
- **`LongPressDraggable` + `DragTarget` over `ReorderableListView`**: Flutter's built-in reorderable only works with lists. For grids, the official Flutter docs recommend using `LongPressDraggable` + `DragTarget` directly.
- **Keep `SharedPreferences` for persistence**: The current approach is adequate. No need to migrate to a database for layout config — it's small JSON data with per-account scoping.
- **Column spans over fixed pairing**: Rather than hard-coding "pair two compacts", we let the grid system handle placement naturally via `crossAxisCellCount`. Three consecutive compacts fill 3 of 4 columns on tablet — no special pairing code needed.

---

## Edge Cases, Pitfalls & Implementation Guidance

This section documents Flutter-specific issues, known package bugs, and implementation pitfalls that an AI agent must handle when implementing the plan above.

### Known `flutter_staggered_grid_view` Bugs

1. **Negative BoxConstraints crash** ([Issue #362](https://github.com/nicoseminar/flutter_staggered_grid_view/issues/362)): `StaggeredGrid` crashes with `BoxConstraints(w=-3.0, h=-3.0; NOT NORMALIZED)` when it receives zero-width constraints (e.g., `BoxConstraints(w=0.0, 0.0<=h<=Infinity)`). This can happen when the grid is placed inside a `SliverToBoxAdapter` that hasn't been laid out yet, or during animated transitions where the parent width is momentarily zero.
   - **Mitigation**: Wrap the `StaggeredGrid` in a `LayoutBuilder` and guard against zero/negative width: `if (constraints.maxWidth <= 0) return const SizedBox.shrink();`

2. **NaN/Infinity crash** ([Issue #361](https://github.com/nicoseminar/flutter_staggered_grid_view/issues/361)): `Infinity or NaN toInt` crash in `_SliverPatternGridLayout.getMinChildIndexForScrollOffset` when using `SliverStairedGridDelegate` with padding.
   - **Mitigation**: We're using `StaggeredGrid.count` (not sliver variants), so this shouldn't affect us. But avoid wrapping in `CustomScrollView` with `SliverToBoxAdapter` — use `SingleChildScrollView` instead.

3. **Left-biased tile alignment** ([Issue #343](https://github.com/nicoseminar/flutter_staggered_grid_view/issues/343)): When the first row isn't fully filled (e.g., one `compact` widget on a 4-column grid), tiles align to the left with no center alignment option.
   - **Mitigation**: This is acceptable behavior for a dashboard. If centering is desired for single-widget states, add a conditional `Center` wrapper when there's only one widget.

### Flutter Drag-and-Drop Pitfalls

4. **`LongPressDraggable` feedback widget sizing**: The `feedback` widget is rendered in the `Overlay` and does not inherit the parent's constraints. If you pass a widget that relies on parent width (e.g., `Expanded`, `Flexible`), it will throw or render at 0 width.
   - **Mitigation**: Give the `feedback` widget explicit dimensions. Capture the tile size using `LayoutBuilder` or a `GlobalKey` and pass it as a `SizedBox` wrapper: `SizedBox(width: tileWidth, height: tileHeight, child: Material(elevation: 4, child: tileContent))`.

5. **`childWhenDragging` must match layout slot**: When `LongPressDraggable.childWhenDragging` is displayed, it replaces `child` in the tree. If it returns `const SizedBox.shrink()`, the `StaggeredGrid` will collapse that slot and other tiles will shift unexpectedly during drag.
   - **Mitigation**: Use an `Opacity(opacity: 0.3, child: originalChild)` for `childWhenDragging` to keep the slot occupied, or use a `Container` with a dashed border placeholder at the original size.

6. **No built-in auto-scroll during drag**: Unlike `ReorderableListView`, `LongPressDraggable` does not auto-scroll when dragging near the edge of a `ScrollView`. Flutter provides `EdgeDraggingAutoScroller` but it requires manual integration.
   - **Mitigation**: Use Flutter's `EdgeDraggingAutoScroller` class. Create an instance in `DashboardGrid._DashboardGridState`, providing the `ScrollController` and the scrollable's `RenderObject`. Start auto-scrolling in `onDragUpdate` when the pointer is within 80dp of the top/bottom edge. Stop in `onDragEnd`/`onDraggableCanceled`. Example pattern:
   ```dart
   late final EdgeDraggingAutoScroller _autoScroller;
   
   @override
   void initState() {
     super.initState();
     // Initialize after first frame when RenderObject is available
     WidgetsBinding.instance.addPostFrameCallback((_) {
       _autoScroller = EdgeDraggingAutoScroller(
         Scrollable.of(context),
         velocityScalar: 20,
       );
     });
   }
   ```

7. **`DragTarget` hit testing with overlapping spans**: In a staggered grid, a `large` widget (span 2×2) covers multiple grid cells. If each cell is a separate `DragTarget`, the large widget's `DragTarget` may not receive events because smaller targets overlap it.
   - **Mitigation**: Make each rendered widget (not each cell) a single `DragTarget`. The grid's flat list of widgets is the drag target list — compute the drop position from the pointer offset relative to the grid, not from individual cell targets.

8. **`rootOverlay: true` consideration**: By default, `LongPressDraggable` places the feedback in the nearest `Overlay`. If the dashboard is inside a `NestedScrollView` or `TabBarView`, the feedback may be clipped by the parent.
   - **Mitigation**: Set `rootOverlay: true` on `LongPressDraggable` so the dragged widget renders above all other UI elements, including app bars and navigation.

### Riverpod State Management During Drag

9. **Excessive rebuilds during drag**: Each call to `notifier.reorder()` triggers `state = newState`, which causes all widgets watching `homeLayoutConfigProvider` to rebuild. If reorder is called on every `onMove` of a `DragTarget`, this causes visible jank (30+ rebuilds per drag).
   - **Mitigation**: Only call `reorder()` on `DragTarget.onAcceptWithDetails` (i.e., on drop), not on hover. During drag, use a local `ValueNotifier<int?>` for the "preview drop position" that only the placeholder rendering reads. This keeps drag preview updates local to `DashboardGrid` state without triggering Riverpod rebuilds.

10. **Account-scoped provider invalidation**: `homeLayoutConfigProvider` is scoped via `activeAccountProvider`. If the active account changes mid-drag (e.g., notification tap switches account), the provider resets. The drag state becomes stale.
    - **Mitigation**: Cancel any in-progress drag on account change. Watch `activeAccountProvider` in `DashboardGrid` and call `setState(() { _draggedWidgetId = null; })` when it changes.

11. **SharedPreferences write coalescing**: Each `reorder()`, `addWidget()`, or `removeWidget()` call immediately writes to SharedPreferences via `_saveConfig()`. Rapid successive operations (e.g., undo then redo) cause redundant disk writes.
    - **Mitigation**: Debounce `_saveConfig()` with a short delay (e.g., 300ms) using a `Timer`. Cancel the previous timer on each new write. This is a low priority optimization but prevents I/O thrashing.

### Widget State Preservation

12. **Key management during reorder**: If widgets use `ValueKey(widget.id)`, Flutter will reuse the `Element` and `State` when the widget moves position in the list. If they use positional keys or no keys, state is lost (e.g., `_TimeSinceLastHitWidget`'s active `Timer` restarts).
    - **Mitigation**: Every widget in the grid MUST have `key: ValueKey(config.id)`. The `config.id` is a UUID that's stable across reorders. Verify this in `HomeWidgetBuilder` — currently it does NOT set keys on returned widgets. This must be added.

13. **Stateful widget timers**: `_TimeSinceLastHitWidget` and `_TotalDurationTodayCard` in `home_widget_builder.dart` use `Timer.periodic`. During drag, if the widget tree rebuilds, these timers may be cancelled and restarted, causing visible flicker in the displayed values.
    - **Mitigation**: With proper `ValueKey`s (item 12), the `State` objects will be preserved across reorder. The timers should survive. Test this explicitly by reordering and verifying the "time since" counter doesn't reset.

14. **`Dismissible` widgets inside grid items**: `_RecentEntriesWidget` uses `Dismissible` for swipe-to-dismiss entries. Inside a grid with `LongPressDraggable`, the gesture recognizers may conflict — a horizontal swipe could be claimed by `Dismissible` before `LongPressDraggable` gets a chance to detect a long press.
    - **Mitigation**: This should not conflict since `LongPressDraggable` uses a long press (not a drag start) and `Dismissible` uses directional swipe. However, if issues arise, conditionally disable `Dismissible` during edit mode (when drag-and-drop is active) by checking `isEditMode`.

### Layout & Responsive Edge Cases

15. **`IntrinsicHeight` removal**: The current `_buildLayoutRows()` wraps paired compact widgets in `IntrinsicHeight` to equalize heights. When using `StaggeredGrid.count`, heights are determined by `mainAxisCellCount`. If widgets have variable internal heights (e.g., `_RecentEntriesWidget` with 0-5 entries), the fixed cell height may clip content or leave empty space.
    - **Mitigation**: Use `StaggeredGridTile.fit` for widgets with variable heights instead of `StaggeredGridTile.count`. This lets the grid compute the actual height from the widget's intrinsic size while still respecting `crossAxisCellCount` for width. Trade-off: `fit` tiles don't have predictable heights, which may look less uniform.

16. **Column clamp on small screens**: On mobile portrait with `crossAxisCount: 2`, a `large` widget (span = crossAxisCount) takes the full width. But if `crossAxisCount` changes during orientation change (e.g., 2 → 3), the saved span metadata doesn't change.
    - **Mitigation**: Always clamp `crossAxisCellCount` to `min(widget.columnSpan, crossAxisCount)` at render time, not at save time. The span in `WidgetCatalog.getEntry()` is a maximum, and `DashboardGrid` applies `clamp(1, crossAxisCount)`.

17. **Orientation change during drag**: If the user rotates the device while dragging a widget, the grid reflows (column count changes) and the drag position becomes invalid.
    - **Mitigation**: Cancel the active drag on orientation change. Use `OrientationBuilder` or `MediaQuery.orientationOf(context)` in `DashboardGrid` to detect changes and reset `_draggedWidgetId`.

18. **Empty grid state**: When all widgets are removed or hidden, the grid renders as an empty `SizedBox`. The user needs a way to add widgets back.
    - **Mitigation**: Show a centered empty-state message with an "Add Widgets" button when `visibleWidgets.isEmpty`. The current code doesn't handle this — it falls through to an empty `ReorderableListView`.

### Testing Pitfalls

19. **`StaggeredGrid` in tests needs constrained width**: Unlike `ListView`, `StaggeredGrid` requires a parent with finite width constraints. Putting it in a bare `MaterialApp` + `Scaffold` in tests works, but wrapping it in a `Row` or `Column` without `Expanded` will cause an overflow error.
    - **Mitigation**: In tests, always wrap the `DashboardGrid` in a `SizedBox(width: 400)` or `MediaQuery` with a known size. Set `tester.view.physicalSize` and `tester.view.devicePixelRatio` for responsive breakpoint tests.

20. **Drag-and-drop in widget tests**: Flutter's `WidgetTester` supports `tester.drag()` and `tester.longPress()` but does NOT have built-in support for `LongPressDraggable` + `DragTarget` reorder. You need to simulate the full gesture sequence:
    ```dart
    // Long press to start drag
    final gesture = await tester.startGesture(tester.getCenter(find.byKey(Key('widget-1'))));
    await tester.pump(const Duration(milliseconds: 500)); // LongPressDraggable delay
    // Move to target position
    await gesture.moveTo(tester.getCenter(find.byKey(Key('widget-3'))));
    await tester.pump();
    // Release
    await gesture.up();
    await tester.pumpAndSettle();
    ```

21. **`SharedPreferences` mocking pattern**: The existing test pattern uses `SharedPreferences.setMockInitialValues({})` and overrides `sharedPreferencesProvider`. New tests must follow this exact pattern. The provider throws `UnimplementedError` if not overridden.
    - **Mitigation**: Copy the `_buildHomeScreenAsync()` helper from `test/screens/home_screen_test.dart` as the template. It includes all required overrides: `activeAccountProvider`, `activeAccountLogRecordsProvider`, `syncServiceProvider`, and `sharedPreferencesProvider`.

22. **`FakeSyncService`**: Tests need the `FakeSyncService` from `test/helpers/test_helpers.dart` because the home screen watches the sync service. Missing this override causes test failures unrelated to the grid functionality.

### Code-Level Implementation Notes

23. **Barrel export update**: Add `dashboard_grid.dart` to `lib/widgets/home_widgets/home_widgets.dart` barrel file. Also add `widget_settings_sheet.dart` if step 12 is implemented.

24. **`AnimatedBuilder` deprecation**: The current `proxyDecorator` in `home_screen.dart` uses `AnimatedBuilder`. While not yet deprecated, it's been replaced by `ListenableBuilder` in recent Flutter versions. When building the drag feedback in the new implementation, use `ListenableBuilder` or `Material` directly instead.

25. **`ResponsiveGrid` vs `DashboardGrid`**: The existing `ResponsiveGrid` in `lib/utils/responsive_layout.dart` is a thin wrapper around `GridView.count`. It is NOT suitable for the dashboard because it requires uniform-sized children and doesn't support multi-span tiles. `DashboardGrid` is a new widget specifically for the home dashboard. Do not attempt to extend `ResponsiveGrid`.

26. **Existing responsive infrastructure**: The `Breakpoints` class in `lib/utils/design_constants.dart` already defines mobile (<600), tablet (600-1199), and desktop (≥1200) breakpoints. `ResponsiveSize.responsive()` already provides adaptive values. `ResponsiveGridConfig` (step 3) should reuse these constants rather than defining new breakpoints.

27. **`HomeWidgetConfig.equality` is by `id` only**: Two `HomeWidgetConfig` instances with the same `id` but different `type`, `order`, or `settings` are considered equal. This means Riverpod won't emit a new state if you only change the `order` field on existing configs. However, `HomeLayoutConfig` uses a `List<HomeWidgetConfig>`, so list-level equality (order of elements) still triggers rebuilds correctly. Just be aware of this when writing unit tests — comparing individual configs won't catch order changes.

28. **`allowMultiple` is always `false`**: All 30 `WidgetCatalogEntry` definitions set `allowMultiple: false`. The infrastructure to support multiples exists (`isWidgetTypeAddedProvider` checks for it) but is unused. The plan doesn't change this, but if a widget type is later changed to `allowMultiple: true`, each instance needs a unique UUID (already handled by `addWidget()` in the notifier).

29. **Version field in `HomeLayoutConfig`**: Currently `version: 1` with no migration logic. Step 14 adds migration. The `fromJson` factory should check `json['version']` and apply transforms. For v1 → v2, no data shape changes are needed (span info comes from `WidgetCatalog`, not persisted config), but the version bump ensures future migrations have a baseline.

30. **`HapticFeedback` import**: The current code uses `HapticFeedback.mediumImpact()` in a few places. For the new drag-and-drop, use `HapticFeedback.selectionClick()` on drag start and `HapticFeedback.mediumImpact()` on drop. Import from `package:flutter/services.dart`.

### FlutterLongPressDraggable API Reference (Key Parameters)

For the implementation of step 5, these `LongPressDraggable` parameters are essential:
- `delay: Duration(milliseconds: 300)` — shorter than default 500ms for more responsive feel
- `hapticFeedbackOnStart: true` — built-in haptic on long press recognition
- `feedback` — the widget shown under the finger (must have explicit size, see #4)
- `childWhenDragging` — placeholder at original position (see #5)
- `data` — the `HomeWidgetConfig.id` (String) identifying what's being dragged
- `dragAnchorStrategy: childDragAnchorStrategy` — keeps feedback anchored to child's original position relative to pointer
- `rootOverlay: true` — ensures feedback renders above all UI layers
- `onDragStarted` / `onDragEnd` — for starting/stopping auto-scroll and updating edit mode UI
- `maxSimultaneousDrags: 1` — prevent multi-touch drag confusion
