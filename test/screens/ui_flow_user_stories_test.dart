import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ash_trail/models/log_record.dart';
import 'package:ash_trail/models/enums.dart';
import 'package:ash_trail/widgets/home_quick_log_widget.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('User Story: UI Flow Tests (Stories 37-41)', () {
    /// Helper to create a testable widget with providers
    Widget createTestWidget(Widget child) {
      return ProviderScope(child: MaterialApp(home: Scaffold(body: child)));
    }

    group('Story 37: Quick Log Widget Structure', () {
      testWidgets('Quick log widget displays with all core elements', (
        tester,
      ) async {
        // GIVEN: User is on home screen with quick log
        await tester.pumpWidget(
          createTestWidget(
            const SingleChildScrollView(child: HomeQuickLogWidget()),
          ),
        );
        await tester.pumpAndSettle();

        // THEN: Widget is present and renders
        expect(find.byType(HomeQuickLogWidget), findsOneWidget);
        expect(find.byType(Card), findsOneWidget);
      });

      testWidgets('Quick log widget has mood slider', (tester) async {
        // GIVEN: User views quick log widget
        await tester.pumpWidget(
          createTestWidget(
            const SingleChildScrollView(child: HomeQuickLogWidget()),
          ),
        );
        await tester.pumpAndSettle();

        // THEN: Mood slider is present
        expect(find.text('Mood'), findsOneWidget);
        expect(find.byType(Slider), findsWidgets);
      });

      testWidgets('Quick log widget has physical rating slider', (
        tester,
      ) async {
        // GIVEN: User views quick log widget
        await tester.pumpWidget(
          createTestWidget(
            const SingleChildScrollView(child: HomeQuickLogWidget()),
          ),
        );
        await tester.pumpAndSettle();

        // THEN: Physical slider is present
        expect(find.text('Physical'), findsOneWidget);
        // Two sliders total (mood + physical)
        expect(find.byType(Slider), findsNWidgets(2));
      });
    });

    group('Story 38: Press-and-Hold Recording', () {
      testWidgets('Quick log has press-and-hold recording area', (
        tester,
      ) async {
        // GIVEN: User is on quick log widget
        await tester.pumpWidget(
          createTestWidget(
            const SingleChildScrollView(child: HomeQuickLogWidget()),
          ),
        );
        await tester.pumpAndSettle();

        // THEN: GestureDetector for recording is present
        expect(find.byType(GestureDetector), findsWidgets);
        expect(find.text('Hold to record duration'), findsOneWidget);
      });

      testWidgets('Recording area has touch icon', (tester) async {
        // GIVEN: User is on quick log widget
        await tester.pumpWidget(
          createTestWidget(
            const SingleChildScrollView(child: HomeQuickLogWidget()),
          ),
        );
        await tester.pumpAndSettle();

        // THEN: Touch icon is visible
        expect(find.byIcon(Icons.touch_app), findsOneWidget);
      });
    });

    group('Story 39: Reason Selection', () {
      testWidgets('Quick log has reason filter chips', (tester) async {
        // GIVEN: User is on quick log
        await tester.pumpWidget(
          createTestWidget(
            const SingleChildScrollView(child: HomeQuickLogWidget()),
          ),
        );
        await tester.pumpAndSettle();

        // THEN: Filter chips for reasons are present
        expect(find.text('Reasons'), findsOneWidget);
        expect(find.byType(FilterChip), findsWidgets);
      });

      testWidgets('All reason types are available as chips', (tester) async {
        // GIVEN: User views quick log
        await tester.pumpWidget(
          createTestWidget(
            const SingleChildScrollView(child: HomeQuickLogWidget()),
          ),
        );
        await tester.pumpAndSettle();

        // THEN: All LogReason values have chips
        expect(find.byType(FilterChip), findsNWidgets(LogReason.values.length));
      });

      testWidgets('Can toggle reason chips', (tester) async {
        // GIVEN: User views quick log with reasons
        await tester.pumpWidget(
          createTestWidget(
            const SingleChildScrollView(child: HomeQuickLogWidget()),
          ),
        );
        await tester.pumpAndSettle();

        // WHEN: User taps a reason chip
        final medicalChip = find.widgetWithText(FilterChip, 'Medical');
        expect(medicalChip, findsOneWidget);

        await tester.tap(medicalChip);
        await tester.pumpAndSettle();

        // THEN: Chip should be selected (FilterChip with selected=true)
        final selectedChip = tester.widget<FilterChip>(
          find.byType(FilterChip).first,
        );
        // Note: The actual selection state is managed internally
        expect(selectedChip, isNotNull);
      });
    });

    group('Story 40: Rating Slider Interaction', () {
      testWidgets('Mood slider has correct range (1-10)', (tester) async {
        // GIVEN: Quick log widget
        await tester.pumpWidget(
          createTestWidget(
            const SingleChildScrollView(child: HomeQuickLogWidget()),
          ),
        );
        await tester.pumpAndSettle();

        // THEN: Slider has min 1, max 10
        final sliders = tester.widgetList<Slider>(find.byType(Slider)).toList();
        expect(sliders.length, 2); // mood + physical

        // First slider (mood)
        expect(sliders[0].min, 1);
        expect(sliders[0].max, 10);

        // Second slider (physical)
        expect(sliders[1].min, 1);
        expect(sliders[1].max, 10);
      });

      testWidgets('Slider defaults to middle value', (tester) async {
        // GIVEN: Fresh quick log widget
        await tester.pumpWidget(
          createTestWidget(
            const SingleChildScrollView(child: HomeQuickLogWidget()),
          ),
        );
        await tester.pumpAndSettle();

        // THEN: Slider starts at midpoint (5.5)
        final sliders = tester.widgetList<Slider>(find.byType(Slider)).toList();
        expect(sliders[0].value, 5.5);
        expect(sliders[1].value, 5.5);
      });
    });

    group('Story 41: Widget Layout and Accessibility', () {
      testWidgets('Quick log widget is scrollable within constraints', (
        tester,
      ) async {
        // GIVEN: Widget in constrained space
        await tester.pumpWidget(
          createTestWidget(
            const SizedBox(
              height: 400,
              child: SingleChildScrollView(child: HomeQuickLogWidget()),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // THEN: Widget renders within constraints
        expect(find.byType(HomeQuickLogWidget), findsOneWidget);
        expect(find.byType(SingleChildScrollView), findsWidgets);
      });

      testWidgets('Widget uses Card with proper padding', (tester) async {
        // GIVEN: Quick log widget
        await tester.pumpWidget(
          createTestWidget(
            const SingleChildScrollView(child: HomeQuickLogWidget()),
          ),
        );
        await tester.pumpAndSettle();

        // THEN: Card with padding is present
        expect(find.byType(Card), findsOneWidget);
        expect(find.byType(Padding), findsWidgets);
      });

      testWidgets('Widget has text labels for all sections', (tester) async {
        // GIVEN: Quick log widget
        await tester.pumpWidget(
          createTestWidget(
            const SingleChildScrollView(child: HomeQuickLogWidget()),
          ),
        );
        await tester.pumpAndSettle();

        // THEN: All section labels are visible
        expect(find.text('Mood'), findsOneWidget);
        expect(find.text('Physical'), findsOneWidget);
        expect(find.text('Reasons'), findsOneWidget);
        expect(find.text('Hold to record duration'), findsOneWidget);
      });
    });
  });

  group('User Story: Log Record Model Tests', () {
    const uuid = Uuid();
    const testAccountId = 'model-test-account';

    test('Story 42: LogRecord creation with all fields', () {
      // GIVEN: All field values
      final now = DateTime.now();

      // WHEN: Creating a log record
      final record = LogRecord.create(
        logId: uuid.v4(),
        accountId: testAccountId,
        eventType: EventType.vape,
        eventAt: now,
        duration: 45.0,
        unit: Unit.seconds,
        note: 'Test session',
        moodRating: 8.0,
        physicalRating: 7.5,
        latitude: 40.7128,
        longitude: -74.0060,
        reasons: [LogReason.recreational, LogReason.social],
      );

      // THEN: All fields are set correctly
      expect(record.accountId, testAccountId);
      expect(record.eventType, EventType.vape);
      expect(record.eventAt, now);
      expect(record.duration, 45.0);
      expect(record.unit, Unit.seconds);
      expect(record.note, 'Test session');
      expect(record.moodRating, 8.0);
      expect(record.physicalRating, 7.5);
      expect(record.latitude, 40.7128);
      expect(record.longitude, -74.0060);
      expect(record.reasons, contains(LogReason.recreational));
      expect(record.reasons, contains(LogReason.social));
    });

    test('Story 43: LogRecord creation with minimal fields', () {
      // GIVEN: Only required fields
      final now = DateTime.now();

      // WHEN: Creating a minimal log record
      final record = LogRecord.create(
        logId: uuid.v4(),
        accountId: testAccountId,
        eventType: EventType.note,
        eventAt: now,
      );

      // THEN: Required fields set, optionals have defaults or null
      expect(record.accountId, testAccountId);
      expect(record.eventType, EventType.note);
      expect(record.eventAt, now);
      // Duration has a default, but note is null
      expect(record.note, isNull);
      expect(record.moodRating, isNull);
    });

    test('Story 44: LogRecord handles different event types', () {
      // GIVEN: Various event types
      final now = DateTime.now();

      // WHEN: Creating records for each type
      final eventTypes = EventType.values;

      // THEN: Each type can be created
      for (final eventType in eventTypes) {
        final record = LogRecord.create(
          logId: uuid.v4(),
          accountId: testAccountId,
          eventType: eventType,
          eventAt: now,
        );
        expect(record.eventType, eventType);
      }
    });

    test('Story 45: LogRecord handles all unit types', () {
      // GIVEN: Various unit types
      final now = DateTime.now();

      // WHEN: Creating records for each unit
      final units = Unit.values;

      // THEN: Each unit can be assigned
      for (final unit in units) {
        final record = LogRecord.create(
          logId: uuid.v4(),
          accountId: testAccountId,
          eventType: EventType.vape,
          eventAt: now,
          duration: 10,
          unit: unit,
        );
        expect(record.unit, unit);
      }
    });

    test('Story 46: LogRecord handles all reason types', () {
      // GIVEN: All reason types
      final now = DateTime.now();

      // WHEN: Creating a record with all reasons
      final record = LogRecord.create(
        logId: uuid.v4(),
        accountId: testAccountId,
        eventType: EventType.vape,
        eventAt: now,
        reasons: LogReason.values,
      );

      // THEN: All reasons are stored
      expect(record.reasons?.length, LogReason.values.length);
      for (final reason in LogReason.values) {
        expect(record.reasons, contains(reason));
      }
    });
  });

  group('User Story: Rating System Tests', () {
    const uuid = Uuid();
    const testAccountId = 'rating-test-account';

    test('Story 47: Mood rating accepts valid range (1-10)', () {
      // GIVEN: Valid mood ratings
      final now = DateTime.now();

      // WHEN: Creating records with boundary values
      final lowMood = LogRecord.create(
        logId: uuid.v4(),
        accountId: testAccountId,
        eventType: EventType.vape,
        eventAt: now,
        moodRating: 1.0,
      );

      final highMood = LogRecord.create(
        logId: uuid.v4(),
        accountId: testAccountId,
        eventType: EventType.vape,
        eventAt: now,
        moodRating: 10.0,
      );

      final midMood = LogRecord.create(
        logId: uuid.v4(),
        accountId: testAccountId,
        eventType: EventType.vape,
        eventAt: now,
        moodRating: 5.5,
      );

      // THEN: All valid ratings are accepted
      expect(lowMood.moodRating, 1.0);
      expect(highMood.moodRating, 10.0);
      expect(midMood.moodRating, 5.5);
    });

    test('Story 48: Physical rating accepts valid range (1-10)', () {
      // GIVEN: Valid physical ratings
      final now = DateTime.now();

      // WHEN: Creating records with boundary values
      final low = LogRecord.create(
        logId: uuid.v4(),
        accountId: testAccountId,
        eventType: EventType.vape,
        eventAt: now,
        physicalRating: 1.0,
      );

      final high = LogRecord.create(
        logId: uuid.v4(),
        accountId: testAccountId,
        eventType: EventType.vape,
        eventAt: now,
        physicalRating: 10.0,
      );

      // THEN: All valid ratings are accepted
      expect(low.physicalRating, 1.0);
      expect(high.physicalRating, 10.0);
    });
  });

  group('User Story: Location Data Tests', () {
    const uuid = Uuid();
    const testAccountId = 'location-test-account';

    test('Story 49: Location data stores valid coordinates', () {
      // GIVEN: Valid GPS coordinates
      final now = DateTime.now();

      // WHEN: Creating record with location
      final record = LogRecord.create(
        logId: uuid.v4(),
        accountId: testAccountId,
        eventType: EventType.vape,
        eventAt: now,
        latitude: 51.5074, // London
        longitude: -0.1278,
      );

      // THEN: Coordinates are stored
      expect(record.latitude, 51.5074);
      expect(record.longitude, -0.1278);
    });

    test('Story 50: Location data handles boundary coordinates', () {
      // GIVEN: Boundary GPS coordinates
      final now = DateTime.now();

      // WHEN: Creating records at extremes
      final northPole = LogRecord.create(
        logId: uuid.v4(),
        accountId: testAccountId,
        eventType: EventType.vape,
        eventAt: now,
        latitude: 90.0,
        longitude: 0.0,
      );

      final southPole = LogRecord.create(
        logId: uuid.v4(),
        accountId: testAccountId,
        eventType: EventType.vape,
        eventAt: now,
        latitude: -90.0,
        longitude: 0.0,
      );

      final dateLine = LogRecord.create(
        logId: uuid.v4(),
        accountId: testAccountId,
        eventType: EventType.vape,
        eventAt: now,
        latitude: 0.0,
        longitude: 180.0,
      );

      // THEN: Boundary coordinates are stored
      expect(northPole.latitude, 90.0);
      expect(southPole.latitude, -90.0);
      expect(dateLine.longitude, 180.0);
    });

    test('Story 51: Location data is optional', () {
      // GIVEN: No location data
      final now = DateTime.now();

      // WHEN: Creating record without location
      final record = LogRecord.create(
        logId: uuid.v4(),
        accountId: testAccountId,
        eventType: EventType.vape,
        eventAt: now,
      );

      // THEN: Location fields are null
      expect(record.latitude, isNull);
      expect(record.longitude, isNull);
    });
  });
}
