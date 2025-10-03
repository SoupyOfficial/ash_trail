import 'package:ash_trail/core/providers/account_providers.dart' as accounts;
import 'package:ash_trail/domain/models/account.dart';
import 'package:ash_trail/domain/models/smoke_log.dart';
import 'package:ash_trail/features/capture_hit/presentation/providers/record_button_state_provider.dart'
    as record;
import 'package:ash_trail/features/capture_hit/presentation/providers/smoke_log_providers.dart'
    as smoke;
import 'package:ash_trail/features/haptics_baseline/domain/entities/haptic_event.dart';
import 'package:ash_trail/features/haptics_baseline/presentation/providers/haptics_providers.dart'
    as haptics;
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeHapticTriggerNotifier extends haptics.HapticTriggerNotifier {
  FakeHapticTriggerNotifier();

  final List<HapticEvent> events = <HapticEvent>[];

  @override
  Future<bool> trigger(HapticEvent event) async {
    events.add(event);
    return true;
  }
}

class TestCreateSmokeLogNotifier extends smoke.CreateSmokeLogNotifier {
  static SmokeLog? _nextLog;
  static Object? _error;
  static Map<String, dynamic>? lastParams;

  static void configureSuccess(SmokeLog log) {
    _nextLog = log;
    _error = null;
    lastParams = null;
  }

  static void configureFailure(Object error) {
    _nextLog = null;
    _error = error;
    lastParams = null;
  }

  static void reset() {
    _nextLog = null;
    _error = null;
    lastParams = null;
  }

  @override
  Future<SmokeLog> createSmokeLog({
    required String accountId,
    required int durationMs,
    String? methodId,
    int? potency,
    required int moodScore,
    required int physicalScore,
    String? notes,
  }) async {
    lastParams = <String, dynamic>{
      'accountId': accountId,
      'durationMs': durationMs,
      'methodId': methodId,
      'potency': potency,
      'moodScore': moodScore,
      'physicalScore': physicalScore,
      'notes': notes,
    };

    if (_error != null) {
      state = AsyncError<SmokeLog>(_error!, StackTrace.current);
      throw _error!;
    }

    final SmokeLog? result = _nextLog;
    if (result == null) {
      throw StateError('TestCreateSmokeLogNotifier.nextLog is not configured');
    }

    state = AsyncData<SmokeLog>(result);
    return result;
  }
}

ProviderContainer _createContainer(
  FakeHapticTriggerNotifier hapticsNotifier, {
  List<Override> extraOverrides = const <Override>[],
}) {
  return ProviderContainer(
    overrides: <Override>[
      haptics.hapticTriggerProvider.overrideWith(() => hapticsNotifier),
      smoke.createSmokeLogProvider.overrideWith(TestCreateSmokeLogNotifier.new),
      ...extraOverrides,
    ],
  );
}

void main() {
  const String testAccountId = 'test-account';
  final DateTime testStartTime = DateTime(2024, 1, 1, 12, 0, 0);
  final SmokeLog sampleSmokeLog = SmokeLog(
    id: 'log-123',
    accountId: testAccountId,
    ts: testStartTime,
    durationMs: 1200,
    methodId: 'method-1',
    potency: 5,
    moodScore: 7,
    physicalScore: 6,
    notes: 'Test notes',
    deviceLocalId: 'device-1',
    createdAt: testStartTime,
    updatedAt: testStartTime,
  );

  setUp(TestCreateSmokeLogNotifier.reset);
  tearDown(TestCreateSmokeLogNotifier.reset);

  group('RecordButtonController lifecycle', () {
    test('startRecording transitions to recording and updates duration', () {
      fakeAsync((FakeAsync async) {
        final FakeHapticTriggerNotifier fakeHaptics =
            FakeHapticTriggerNotifier();
        final ProviderContainer container = _createContainer(fakeHaptics);
        addTearDown(container.dispose);
        final ProviderSubscription<record.RecordButtonState> subscription =
            container.listen(record.recordButtonProvider, (_, __) {});
        addTearDown(subscription.close);

        final record.RecordButtonController controller =
            container.read(record.recordButtonProvider.notifier);

        controller.startRecording(testAccountId);
        async.flushMicrotasks();

        expect(fakeHaptics.events, contains(HapticEvent.impactLight));
        expect(container.read(record.recordButtonProvider),
            isA<record.RecordButtonRecordingState>());
        expect(controller.isRecording, isTrue);

        async.elapse(const Duration(milliseconds: 350));
        async.flushMicrotasks();

        final record.RecordButtonRecordingState recordingState =
            container.read(record.recordButtonProvider)
                as record.RecordButtonRecordingState;
        expect(recordingState.currentDurationMs, greaterThan(0));
        expect(controller.currentDurationMs, recordingState.currentDurationMs);
      });
    });

    test('startRecording is ignored when controller is not idle', () {
      fakeAsync((FakeAsync async) {
        final FakeHapticTriggerNotifier fakeHaptics =
            FakeHapticTriggerNotifier();
        final ProviderContainer container = _createContainer(fakeHaptics);
        addTearDown(container.dispose);
        final ProviderSubscription<record.RecordButtonState> subscription =
            container.listen(record.recordButtonProvider, (_, __) {});
        addTearDown(subscription.close);

        final record.RecordButtonController controller =
            container.read(record.recordButtonProvider.notifier);

        controller.startRecording(testAccountId);
        async.flushMicrotasks();
        controller.startRecording(testAccountId);
        async.flushMicrotasks();

        final Iterable<HapticEvent> impactEvents = fakeHaptics.events
            .where((HapticEvent event) => event == HapticEvent.impactLight);
        expect(impactEvents.length, 1);
      });
    });

    test('stopRecording completes flow and resets to idle', () {
      fakeAsync((FakeAsync async) {
        final FakeHapticTriggerNotifier fakeHaptics =
            FakeHapticTriggerNotifier();
        final ProviderContainer container = _createContainer(fakeHaptics);
        addTearDown(container.dispose);
        final ProviderSubscription<record.RecordButtonState> subscription =
            container.listen(record.recordButtonProvider, (_, __) {});
        addTearDown(subscription.close);

        final record.RecordButtonController controller =
            container.read(record.recordButtonProvider.notifier);

        TestCreateSmokeLogNotifier.configureSuccess(sampleSmokeLog);

        controller.startRecording(testAccountId);
        async.flushMicrotasks();

        async.elapse(const Duration(milliseconds: 1200));
        async.flushMicrotasks();

        controller.stopRecording(
          methodId: 'method-42',
          potency: 4,
          moodScore: 8,
          physicalScore: 5,
          notes: 'Happy path',
        );
        async.flushMicrotasks();

        final record.RecordButtonState state =
            container.read(record.recordButtonProvider);
        expect(state, isA<record.RecordButtonCompletedState>());
        final record.RecordButtonCompletedState completedState =
            state as record.RecordButtonCompletedState;

        expect(completedState.smokeLogId, sampleSmokeLog.id);
        expect(completedState.durationMs,
            TestCreateSmokeLogNotifier.lastParams?['durationMs']);
        expect(fakeHaptics.events, contains(HapticEvent.success));
        expect(
            TestCreateSmokeLogNotifier.lastParams?['accountId'], testAccountId);
        expect(TestCreateSmokeLogNotifier.lastParams?['notes'], 'Happy path');

        async.elapse(const Duration(milliseconds: 1500));
        async.flushMicrotasks();

        expect(container.read(record.recordButtonProvider),
            isA<record.RecordButtonIdleState>());
        expect(controller.isRecording, isFalse);
        expect(controller.currentDurationMs, 0);
      });
    });

    test('stopRecording handles errors and recovers to idle', () {
      fakeAsync((FakeAsync async) {
        final FakeHapticTriggerNotifier fakeHaptics =
            FakeHapticTriggerNotifier();
        final ProviderContainer container = _createContainer(fakeHaptics);
        addTearDown(container.dispose);
        final ProviderSubscription<record.RecordButtonState> subscription =
            container.listen(record.recordButtonProvider, (_, __) {});
        addTearDown(subscription.close);

        final record.RecordButtonController controller =
            container.read(record.recordButtonProvider.notifier);

        final Exception failure = Exception('create failed');
        TestCreateSmokeLogNotifier.configureFailure(failure);

        controller.startRecording(testAccountId);
        async.flushMicrotasks();

        controller.stopRecording(
          moodScore: 6,
          physicalScore: 4,
        );
        async.flushMicrotasks();

        final record.RecordButtonState state =
            container.read(record.recordButtonProvider);
        expect(state, isA<record.RecordButtonErrorState>());
        final record.RecordButtonErrorState errorState =
            state as record.RecordButtonErrorState;
        expect(errorState.message, contains('create failed'));
        expect(fakeHaptics.events, contains(HapticEvent.error));

        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();

        expect(container.read(record.recordButtonProvider),
            isA<record.RecordButtonIdleState>());
        expect(controller.hasError, isFalse);
        expect(controller.errorMessage, isNull);
      });
    });

    test('stopRecording does nothing when not recording', () {
      fakeAsync((FakeAsync async) {
        final FakeHapticTriggerNotifier fakeHaptics =
            FakeHapticTriggerNotifier();
        final ProviderContainer container = _createContainer(fakeHaptics);
        addTearDown(container.dispose);
        final ProviderSubscription<record.RecordButtonState> subscription =
            container.listen(record.recordButtonProvider, (_, __) {});
        addTearDown(subscription.close);

        final record.RecordButtonController controller =
            container.read(record.recordButtonProvider.notifier);

        controller.stopRecording(
          moodScore: 5,
          physicalScore: 5,
        );
        async.flushMicrotasks();

        expect(fakeHaptics.events, isEmpty);
        expect(container.read(record.recordButtonProvider),
            isA<record.RecordButtonIdleState>());
      });
    });

    test('cancelRecording stops recording and emits warning haptic', () {
      fakeAsync((FakeAsync async) {
        final FakeHapticTriggerNotifier fakeHaptics =
            FakeHapticTriggerNotifier();
        final ProviderContainer container = _createContainer(fakeHaptics);
        addTearDown(container.dispose);
        final ProviderSubscription<record.RecordButtonState> subscription =
            container.listen(record.recordButtonProvider, (_, __) {});
        addTearDown(subscription.close);

        final record.RecordButtonController controller =
            container.read(record.recordButtonProvider.notifier);

        controller.startRecording(testAccountId);
        async.flushMicrotasks();

        controller.cancelRecording();
        async.flushMicrotasks();

        expect(fakeHaptics.events, contains(HapticEvent.warning));
        expect(container.read(record.recordButtonProvider),
            isA<record.RecordButtonIdleState>());
      });
    });

    test('cancelRecording when idle emits no haptic feedback', () {
      fakeAsync((FakeAsync async) {
        final FakeHapticTriggerNotifier fakeHaptics =
            FakeHapticTriggerNotifier();
        final ProviderContainer container = _createContainer(fakeHaptics);
        addTearDown(container.dispose);
        final ProviderSubscription<record.RecordButtonState> subscription =
            container.listen(record.recordButtonProvider, (_, __) {});
        addTearDown(subscription.close);

        final record.RecordButtonController controller =
            container.read(record.recordButtonProvider.notifier);

        controller.cancelRecording();
        async.flushMicrotasks();

        expect(fakeHaptics.events, isEmpty);
        expect(controller.isRecording, isFalse);
      });
    });

    test('resetToIdle clears current state and timers', () {
      final FakeHapticTriggerNotifier fakeHaptics = FakeHapticTriggerNotifier();
      final ProviderContainer container = _createContainer(fakeHaptics);
      addTearDown(container.dispose);
      final ProviderSubscription<record.RecordButtonState> subscription =
          container.listen(record.recordButtonProvider, (_, __) {});
      addTearDown(subscription.close);

      final record.RecordButtonController controller =
          container.read(record.recordButtonProvider.notifier);

      controller.state = const record.RecordButtonState.error(message: 'oops');
      expect(controller.hasError, isTrue);

      controller.resetToIdle();
      expect(container.read(record.recordButtonProvider),
          isA<record.RecordButtonIdleState>());
      expect(controller.hasError, isFalse);
      expect(controller.currentDurationMs, 0);
    });
  });

  group('Controller computed properties', () {
    test('currentDurationMs reflects state variants', () {
      final FakeHapticTriggerNotifier fakeHaptics = FakeHapticTriggerNotifier();
      final ProviderContainer container = _createContainer(fakeHaptics);
      addTearDown(container.dispose);
      final ProviderSubscription<record.RecordButtonState> subscription =
          container.listen(record.recordButtonProvider, (_, __) {});
      addTearDown(subscription.close);

      final record.RecordButtonController controller =
          container.read(record.recordButtonProvider.notifier);

      expect(controller.currentDurationMs, 0);

      controller.state = record.RecordButtonState.recording(
        startTime: testStartTime,
        currentDurationMs: 900,
      );
      expect(controller.currentDurationMs, 900);
      expect(controller.isRecording, isTrue);

      controller.state = const record.RecordButtonState.completed(
        durationMs: 2300,
        smokeLogId: 'log-456',
      );
      expect(controller.currentDurationMs, 2300);
      expect(controller.isRecording, isFalse);

      controller.state = const record.RecordButtonState.error(message: 'boom');
      expect(controller.hasError, isTrue);
      expect(controller.errorMessage, 'boom');
    });
  });

  group('Derived providers', () {
    test('formattedDurationProvider formats values for each state', () {
      final FakeHapticTriggerNotifier fakeHaptics = FakeHapticTriggerNotifier();
      final ProviderContainer container = _createContainer(fakeHaptics);
      addTearDown(container.dispose);
      final ProviderSubscription<record.RecordButtonState> subscription =
          container.listen(record.recordButtonProvider, (_, __) {});
      addTearDown(subscription.close);

      final record.RecordButtonController controller =
          container.read(record.recordButtonProvider.notifier);

      controller.state = record.RecordButtonState.recording(
        startTime: testStartTime,
        currentDurationMs: 850,
      );
      expect(container.read(record.formattedDurationProvider), '0.8s');

      controller.state = const record.RecordButtonState.completed(
        durationMs: 2340,
        smokeLogId: 'log-789',
      );
      expect(container.read(record.formattedDurationProvider), '2.3s');

      controller.state = const record.RecordButtonState.idle();
      expect(container.read(record.formattedDurationProvider), '0.0s');
    });

    test(
        'recordButtonEnabledProvider and isRecordingActiveProvider reflect state',
        () {
      final FakeHapticTriggerNotifier fakeHaptics = FakeHapticTriggerNotifier();
      final ProviderContainer container = _createContainer(fakeHaptics);
      addTearDown(container.dispose);

      final record.RecordButtonController controller =
          container.read(record.recordButtonProvider.notifier);

      expect(container.read(record.recordButtonEnabledProvider), isTrue);
      expect(container.read(record.isRecordingActiveProvider), isFalse);

      controller.state = record.RecordButtonState.recording(
        startTime: testStartTime,
        currentDurationMs: 500,
      );
      expect(container.read(record.recordButtonEnabledProvider), isFalse);
      expect(container.read(record.isRecordingActiveProvider), isTrue);

      controller.state = const record.RecordButtonState.error(message: 'nope');
      expect(container.read(record.recordButtonEnabledProvider), isFalse);
      expect(container.read(record.isRecordingActiveProvider), isFalse);

      controller.state = const record.RecordButtonState.idle();
      expect(container.read(record.recordButtonEnabledProvider), isTrue);
      expect(container.read(record.isRecordingActiveProvider), isFalse);
    });

    test('currentAccountIdProvider tracks active account changes', () {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(record.currentAccountIdProvider),
          'phase1-mock-account');

      container.read(accounts.activeAccountProvider.notifier).state =
          const Account(
        id: 'secondary-account',
        displayName: 'Tester',
        firstName: 'Test',
        lastName: 'User',
        email: 'test@ashtrail.local',
        provider: 'mock',
      );
      expect(
          container.read(record.currentAccountIdProvider), 'secondary-account');

      container.read(accounts.activeAccountProvider.notifier).state = null;
      expect(container.read(record.currentAccountIdProvider), isNull);
    });
  });
}
