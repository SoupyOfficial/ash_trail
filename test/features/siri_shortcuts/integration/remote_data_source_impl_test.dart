import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/siri_shortcuts/data/datasources/siri_shortcuts_remote_data_source.dart';
import 'package:ash_trail/features/siri_shortcuts/data/models/siri_shortcuts_model.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/entities/siri_shortcut_type.dart';

void main() {
  group('SiriShortcutsRemoteDataSourceImpl', () {
    late SiriShortcutsRemoteDataSourceImpl dataSource;

    setUp(() {
      dataSource = const SiriShortcutsRemoteDataSourceImpl();
    });

    test('should check platform support correctly', () async {
      // act
      final isSupported = await dataSource.isSiriShortcutsSupported();

      // assert - This will be false on testing platform (not iOS)
      expect(isSupported, isFalse);
    });

    test('should throw error when donating on unsupported platform', () async {
      // arrange
      final shortcut = SiriShortcutsModel(
        id: '1',
        type: 'add_log',
        createdAt: DateTime.now(),
        isDonated: false,
        invocationCount: 0,
      );

      // act & assert
      await expectLater(
        () => dataSource.donateShortcut(shortcut),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('should record telemetry without errors', () async {
      // act & assert
      await expectLater(
        () => dataSource.recordShortcutInvocation(
          shortcutId: '1',
          type: const SiriShortcutType.addLog(),
          invokedAt: DateTime.now(),
        ),
        returnsNormally,
      );
    });

    test('should handle multiple shortcuts donation on unsupported platform',
        () async {
      // arrange
      final shortcuts = [
        SiriShortcutsModel(
          id: '1',
          type: 'add_log',
          createdAt: DateTime.now(),
          isDonated: false,
          invocationCount: 0,
        ),
        SiriShortcutsModel(
          id: '2',
          type: 'start_timed_log',
          createdAt: DateTime.now(),
          isDonated: false,
          invocationCount: 0,
        ),
      ];

      // act & assert
      await expectLater(
        () => dataSource.donateShortcuts(shortcuts),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('should simulate delay for telemetry recording', () async {
      // arrange
      final stopwatch = Stopwatch()..start();

      // act
      await dataSource.recordShortcutInvocation(
        shortcutId: '1',
        type: const SiriShortcutType.startTimedLog(),
        invokedAt: DateTime.now(),
      );

      // assert
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(40));
    });
  });
}
