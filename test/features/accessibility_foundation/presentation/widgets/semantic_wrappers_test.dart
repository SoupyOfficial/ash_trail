// Spec Header:
// Semantic Wrappers Widget Tests
// Tests accessibility wrapper widgets for proper semantics and touch targets.
// Assumption: Semantics can be tested through tester.getSemantics() API.

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/accessibility_foundation/presentation/widgets/semantic_wrappers.dart';

void main() {
  group('AccessibleButton', () {
    testWidgets('renders with minimum tap target size', (tester) async {
      // Arrange
      const minTapTarget = 48.0;
      var wasPressed = false;

      // Act - Use MediaQuery to provide proper context
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(400, 600),
              textScaler: TextScaler.linear(1.0),
              accessibleNavigation: false,
              disableAnimations: false,
              platformBrightness: Brightness.light,
              devicePixelRatio: 1.0,
              boldText: false,
              highContrast: false,
            ),
            child: AccessibleButton(
              onPressed: () => wasPressed = true,
              minTapTarget: minTapTarget,
              child: const Text('Test Button'),
            ),
          ),
        ),
      );

      // Assert - Find our AccessibleButton's ConstrainedBox (with finite constraints)
      final constrainedBoxes = find.byType(ConstrainedBox);
      expect(constrainedBoxes, findsAtLeastNWidgets(1));

      // Find the ConstrainedBox that has finite, reasonable constraints (our AccessibleButton one)
      final accessibleButtonConstrainedBox =
          constrainedBoxes.evaluate().firstWhere(
        (element) {
          final widget = element.widget as ConstrainedBox;
          // Look for ConstrainedBox with finite, reasonable constraints
          return widget.constraints.minWidth.isFinite &&
              widget.constraints.minHeight.isFinite &&
              widget.constraints.minWidth >= 40 && // reasonable minimum
              widget.constraints.minHeight >= 40;
        },
        orElse: () => constrainedBoxes.evaluate().first,
      );

      final constrainedBox =
          accessibleButtonConstrainedBox.widget as ConstrainedBox;
      expect(constrainedBox.constraints.minWidth, equals(minTapTarget));
      expect(constrainedBox.constraints.minHeight, equals(minTapTarget));

      // Test tap functionality
      await tester.tap(find.text('Test Button'));
      expect(wasPressed, isTrue);
    });

    testWidgets('includes semantic label', (tester) async {
      // Arrange
      const semanticLabel = 'Custom button label';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: AccessibleButton(
            onPressed: () {},
            semanticLabel: semanticLabel,
            child: const Text('Button Text'),
          ),
        ),
      );

      // Assert
      final semantics = tester.getSemantics(find.byType(AccessibleButton));
      expect(semantics.label, contains(semanticLabel));
      expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
    });

    testWidgets('shows tooltip when provided', (tester) async {
      // Arrange
      const tooltip = 'Button tooltip';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: AccessibleButton(
            onPressed: () {},
            tooltip: tooltip,
            child: const Text('Button'),
          ),
        ),
      );

      // Assert
      expect(find.byType(Tooltip), findsOneWidget);
      final tooltipWidget = tester.widget<Tooltip>(find.byType(Tooltip));
      expect(tooltipWidget.message, equals(tooltip));
    });

    testWidgets('respects excludeSemantics flag', (tester) async {
      // Arrange
      const semanticLabel = 'Custom button label';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: AccessibleButton(
            onPressed: () {},
            excludeSemantics: true,
            semanticLabel: semanticLabel,
            child: const Text('Button'),
          ),
        ),
      );

      // Assert - The custom semantic label should not be present since we excluded semantics
      final buttonSemanticsNodes = tester.getSemantics(find.text('Button'));
      // When excludeSemantics is true, our custom label should not be present
      expect(buttonSemanticsNodes.label, isNot(contains(semanticLabel)));
    });
  });

  group('AccessibleRecordButton', () {
    testWidgets('renders with correct default semantic label', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: AccessibleRecordButton(
            onPressed: () {},
            onLongPress: () {},
          ),
        ),
      );

      // Assert
      final semantics =
          tester.getSemantics(find.byType(AccessibleRecordButton));
      expect(semantics.label, contains('Record smoking hit'));
      expect(semantics.hint, contains('Double tap to activate'));
    });

    testWidgets('shows recording state correctly', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: AccessibleRecordButton(
            onPressed: () {},
            onLongPress: () {},
            isRecording: true,
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.stop), findsOneWidget);
      final semantics =
          tester.getSemantics(find.byType(AccessibleRecordButton));
      expect(semantics.label, contains('Recording in progress'));
      expect(semantics.hint, contains('Release to complete recording'));
    });

    testWidgets('uses larger tap target size', (tester) async {
      // Arrange
      const minTapTarget = 56.0;

      // Act - Use MediaQuery to provide proper context
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(400, 600),
              textScaler: TextScaler.linear(1.0),
              accessibleNavigation: false,
              disableAnimations: false,
              platformBrightness: Brightness.light,
              devicePixelRatio: 1.0,
              boldText: false,
              highContrast: false,
            ),
            child: AccessibleRecordButton(
              onPressed: () {},
              onLongPress: () {},
              minTapTarget: minTapTarget,
            ),
          ),
        ),
      );

      // Assert - Find our AccessibleRecordButton's ConstrainedBox (with finite constraints)
      final constrainedBoxes = find.byType(ConstrainedBox);
      expect(constrainedBoxes, findsAtLeastNWidgets(1));

      // Find the ConstrainedBox with finite, reasonable constraints (our AccessibleRecordButton one)
      final recordButtonConstrainedBox = constrainedBoxes.evaluate().firstWhere(
        (element) {
          final widget = element.widget as ConstrainedBox;
          // Look for ConstrainedBox with finite, reasonable constraints
          return widget.constraints.minWidth.isFinite &&
              widget.constraints.minHeight.isFinite &&
              widget.constraints.minWidth >=
                  50 && // reasonable minimum for RecordButton
              widget.constraints.minHeight >= 50;
        },
        orElse: () => constrainedBoxes.evaluate().first,
      );

      final constrainedBox =
          recordButtonConstrainedBox.widget as ConstrainedBox;
      expect(constrainedBox.constraints.minWidth, equals(minTapTarget));
      expect(constrainedBox.constraints.minHeight, equals(minTapTarget));
    });
  });

  group('AccessibleNavigationItem', () {
    testWidgets('renders with proper semantic information', (tester) async {
      // Arrange
      const label = 'Home';
      var wasTapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Material(
              child: AccessibleNavigationItem(
                label: label,
                icon: Icons.home,
                onTap: () => wasTapped = true,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(label), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);

      final semantics =
          tester.getSemantics(find.byType(AccessibleNavigationItem));
      expect(semantics.label, contains(label));
      expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);

      // Test tap functionality
      await tester.tap(find.byType(AccessibleNavigationItem));
      expect(wasTapped, isTrue);
    });

    testWidgets('shows selected state in semantics', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Material(
              child: AccessibleNavigationItem(
                label: 'Home',
                icon: Icons.home,
                onTap: () {},
                isSelected: true,
              ),
            ),
          ),
        ),
      );

      // Assert
      final semantics =
          tester.getSemantics(find.byType(AccessibleNavigationItem));
      expect(semantics.label, contains('selected'));
      expect(semantics.hasFlag(SemanticsFlag.isSelected), isTrue);
    });

    testWidgets('includes badge count in semantics', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Material(
              child: AccessibleNavigationItem(
                label: 'Logs',
                icon: Icons.list,
                onTap: () {},
                badgeCount: 5,
              ),
            ),
          ),
        ),
      );

      // Assert
      final semantics =
          tester.getSemantics(find.byType(AccessibleNavigationItem));
      expect(semantics.label, contains('5 unread'));
      expect(find.byType(Badge), findsOneWidget);
    });
  });

  group('AccessibleLogRow', () {
    testWidgets('renders with proper content and semantics', (tester) async {
      // Arrange
      const title = 'Morning Session';
      const subtitle = '2 hits, 15mg THC';
      const timestamp = '9:30 AM';
      var wasTapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Material(
              child: AccessibleLogRow(
                title: title,
                subtitle: subtitle,
                timestamp: timestamp,
                onTap: () => wasTapped = true,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(title), findsOneWidget);
      expect(find.text(subtitle), findsOneWidget);
      expect(find.text(timestamp), findsOneWidget);

      final semantics = tester.getSemantics(find.byType(AccessibleLogRow));
      expect(semantics.label, contains(title));
      expect(semantics.label, contains(subtitle));
      expect(semantics.label, contains(timestamp));

      // Test tap functionality
      await tester.tap(find.byType(AccessibleLogRow));
      expect(wasTapped, isTrue);
    });

    testWidgets('shows edit and delete buttons when provided', (tester) async {
      // Arrange
      var editTapped = false;
      var deleteTapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Material(
              child: AccessibleLogRow(
                title: 'Test Log',
                subtitle: 'Test Subtitle',
                timestamp: '10:00 AM',
                onEdit: () => editTapped = true,
                onDelete: () => deleteTapped = true,
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);

      // Test edit button
      await tester.tap(find.byIcon(Icons.edit));
      expect(editTapped, isTrue);

      // Test delete button
      await tester.tap(find.byIcon(Icons.delete));
      expect(deleteTapped, isTrue);
    });

    testWidgets('enforces minimum tap target height', (tester) async {
      // Arrange
      const minTapTarget = 48.0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(400, 600),
              textScaler: TextScaler.linear(1.0),
              accessibleNavigation: false,
              disableAnimations: false,
              platformBrightness: Brightness.light,
              devicePixelRatio: 1.0,
              boldText: false,
              highContrast: false,
            ),
            child: Material(
              child: AccessibleLogRow(
                title: 'Test',
                subtitle: 'Test',
                timestamp: '10:00 AM',
                minTapTarget: minTapTarget,
              ),
            ),
          ),
        ),
      );

      // Assert - Find the ConstrainedBox that has the min height constraint
      final constrainedBoxes = find.byType(ConstrainedBox);
      expect(constrainedBoxes, findsAtLeastNWidgets(1));

      // Look for our specific constraint box (the one with finite minHeight)
      final specificConstrainedBox =
          tester.widgetList<ConstrainedBox>(constrainedBoxes).firstWhere(
                (box) =>
                    box.constraints.minHeight.isFinite &&
                    box.constraints.minHeight > 0,
              );

      expect(
          specificConstrainedBox.constraints.minHeight, equals(minTapTarget));
    });
  });

  group('AccessibleFocusTraversalGroup', () {
    testWidgets('creates focus traversal group with default policy',
        (tester) async {
      // Act
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: AccessibleFocusTraversalGroup(
            child: Column(
              children: [
                TextButton(onPressed: () {}, child: const Text('Button 1')),
                TextButton(onPressed: () {}, child: const Text('Button 2')),
              ],
            ),
          ),
        ),
      );

      // Assert - Find our specific FocusTraversalGroup (the innermost one)
      final traversalGroups = find.byType(FocusTraversalGroup);
      expect(traversalGroups, findsWidgets);

      final traversalGroup =
          tester.widgetList<FocusTraversalGroup>(traversalGroups).last;
      expect(traversalGroup.policy, isA<OrderedTraversalPolicy>());
    });

    testWidgets('uses custom focus traversal policy when provided',
        (tester) async {
      // Arrange
      final customPolicy = ReadingOrderTraversalPolicy();

      // Act
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: AccessibleFocusTraversalGroup(
            policy: customPolicy,
            child: const Text('Test'),
          ),
        ),
      );

      // Assert - Find our specific FocusTraversalGroup (the innermost one)
      final traversalGroups = find.byType(FocusTraversalGroup);
      expect(traversalGroups, findsWidgets);

      final traversalGroup =
          tester.widgetList<FocusTraversalGroup>(traversalGroups).last;
      expect(traversalGroup.policy, equals(customPolicy));
    });
  });

  group('Accessibility integration with MediaQuery', () {
    testWidgets('components adapt to high text scale factor', (tester) async {
      // Arrange
      const baseSize = 48.0;
      const textScale = 2.0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(textScale),
            ),
            child: AccessibleButton(
              onPressed: () {},
              minTapTarget: baseSize,
              child: const Text('Scaled Button'),
            ),
          ),
        ),
      );

      // Assert - Button should use larger tap target
      final constrainedBox = tester.widget<ConstrainedBox>(
        find.byType(ConstrainedBox).first,
      );
      expect(constrainedBox.constraints.minWidth, greaterThan(baseSize));
    });

    testWidgets('components adapt to screen reader mode', (tester) async {
      // Arrange
      const baseSize = 48.0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              accessibleNavigation: true,
            ),
            child: AccessibleRecordButton(
              onPressed: () {},
              onLongPress: () {},
              minTapTarget: baseSize,
            ),
          ),
        ),
      );

      // Assert - Button should use larger tap target for screen reader users
      final constrainedBox = tester.widget<ConstrainedBox>(
        find.byType(ConstrainedBox).first,
      );
      expect(constrainedBox.constraints.minWidth, greaterThan(baseSize));
    });
  });
}
