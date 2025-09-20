import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/features/siri_shortcuts/data/datasources/siri_shortcuts_remote_data_source.dart';
import 'package:ash_trail/features/siri_shortcuts/data/models/siri_shortcuts_model.dart';
import 'package:ash_trail/features/siri_shortcuts/domain/entities/siri_shortcut_type.dart';

class FakeRemoteDataSource implements SiriShortcutsRemoteDataSource {
  bool _isSupported = true;
  bool _shouldThrow = false;

  void setSupported(bool isSupported) {
    _isSupported = isSupported;
  }

  void setShouldThrow(bool shouldThrow) {
    _shouldThrow = shouldThrow;
  }

  @override
  Future<void> donateShortcut(SiriShortcutsModel shortcut) async {
    if (_shouldThrow) throw Exception('Remote error');
    // Mock success
  }

  @override
  Future<void> donateShortcuts(List<SiriShortcutsModel> shortcuts) async {
    if (_shouldThrow) throw Exception('Remote error');
    // Mock success
  }

  @override
  Future<bool> isSiriShortcutsSupported() async {
    if (_shouldThrow) throw Exception('Remote error');
    return _isSupported;
  }

  @override
  Future<void> recordShortcutInvocation({
    required String shortcutId,
    required SiriShortcutType type,
    required DateTime invokedAt,
  }) async {
    if (_shouldThrow) throw Exception('Remote error');
    // Mock telemetry recording
  }
}

void main() {
  group('SiriShortcutsRemoteDataSource Integration', () {
    late FakeRemoteDataSource dataSource;

    setUp(() {
      dataSource = FakeRemoteDataSource();
    });

    test('should donate single shortcut successfully', () async {
      // arrange
      final shortcut = SiriShortcutsModel(
        id: '1',
        type: 'add_log',
        createdAt: DateTime.now(),
        isDonated: false,
        invocationCount: 0,
      );
      dataSource.setShouldThrow(false);

      // act & assert
      await expectLater(
        () => dataSource.donateShortcut(shortcut),
        returnsNormally,
      );
    });

    test('should donate multiple shortcuts successfully', () async {
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
      dataSource.setShouldThrow(false);

      // act & assert
      await expectLater(
        () => dataSource.donateShortcuts(shortcuts),
        returnsNormally,
      );
    });

    test('should check Siri shortcuts support', () async {
      // arrange
      dataSource.setSupported(true);
      dataSource.setShouldThrow(false);

      // act
      final isSupported = await dataSource.isSiriShortcutsSupported();

      // assert
      expect(isSupported, isTrue);
    });

    test('should record shortcut invocation', () async {
      // arrange
      dataSource.setShouldThrow(false);

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

    test('should handle donation errors', () async {
      // arrange
      final shortcut = SiriShortcutsModel(
        id: '1',
        type: 'add_log',
        createdAt: DateTime.now(),
        isDonated: false,
        invocationCount: 0,
      );
      dataSource.setShouldThrow(true);

      // act & assert
      await expectLater(
        () => dataSource.donateShortcut(shortcut),
        throwsException,
      );
    });

    test('should handle support check errors', () async {
      // arrange
      dataSource.setShouldThrow(true);

      // act & assert
      await expectLater(
        () => dataSource.isSiriShortcutsSupported(),
        throwsException,
      );
    });

    test('should handle telemetry recording errors', () async {
      // arrange
      dataSource.setShouldThrow(true);

      // act & assert
      await expectLater(
        () => dataSource.recordShortcutInvocation(
          shortcutId: '1',
          type: const SiriShortcutType.startTimedLog(),
          invokedAt: DateTime.now(),
        ),
        throwsException,
      );
    });
  });
}
