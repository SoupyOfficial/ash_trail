import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ash_trail/features/spotlight_indexing/data/datasources/spotlight_service.dart';
import 'package:ash_trail/features/spotlight_indexing/data/models/spotlight_item_model.dart';

void main() {
  group('SpotlightService', () {
    late SpotlightService spotlightService;
    late MockMethodChannel mockMethodChannel;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      spotlightService = SpotlightService();
      mockMethodChannel = MockMethodChannel();
    });

    tearDown(() {
      mockMethodChannel.reset();
    });

    group('indexItem', () {
      test('should successfully index a single item', () async {
        // Arrange
        const channel = MethodChannel('com.ashtrail.spotlight');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (methodCall) async {
          expect(methodCall.method, 'indexItem');
          expect(methodCall.arguments['id'], 'test_id');
          expect(methodCall.arguments['title'], 'Test Title');
          return null;
        });

        final item = SpotlightItemModel(
          id: 'test_id',
          type: 'tag',
          title: 'Test Title',
          description: 'Test Description',
          keywords: ['test', 'tag'],
          deepLink: 'ashtrail://test',
          accountId: 'account1',
          contentId: 'content1',
          lastUpdated: DateTime.now(),
          isActive: true,
        );

        // Act
        final result = await spotlightService.indexItem(item);

        // Assert
        expect(result.isRight(), true);
      });

      test('should handle PlatformException during indexing', () async {
        // Arrange
        const channel = MethodChannel('com.ashtrail.spotlight');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (methodCall) async {
          throw PlatformException(code: 'ERROR', message: 'Platform error');
        });

        final item = SpotlightItemModel(
          id: 'test_id',
          type: 'tag',
          title: 'Test Title',
          deepLink: 'ashtrail://test',
          accountId: 'account1',
          contentId: 'content1',
          lastUpdated: DateTime.now(),
          isActive: true,
        );

        // Act
        final result = await spotlightService.indexItem(item);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(
              failure.message, contains('Failed to index spotlight item')),
          (success) => fail('Expected failure'),
        );
      });

      test('should handle general exception during indexing', () async {
        // Arrange
        const channel = MethodChannel('com.ashtrail.spotlight');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (methodCall) async {
          throw Exception('General error');
        });

        final item = SpotlightItemModel(
          id: 'test_id',
          type: 'tag',
          title: 'Test Title',
          deepLink: 'ashtrail://test',
          accountId: 'account1',
          contentId: 'content1',
          lastUpdated: DateTime.now(),
          isActive: true,
        );

        // Act
        final result = await spotlightService.indexItem(item);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(
              failure.message, contains('Failed to index spotlight item')),
          (success) => fail('Expected failure'),
        );
      });
    });

    group('indexItems', () {
      test('should successfully index multiple items', () async {
        // Arrange
        const channel = MethodChannel('com.ashtrail.spotlight');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (methodCall) async {
          expect(methodCall.method, 'indexItems');
          final items = methodCall.arguments['items'] as List;
          expect(items.length, 2);
          return null;
        });

        final items = [
          SpotlightItemModel(
            id: 'test_id_1',
            type: 'tag',
            title: 'Test Title 1',
            deepLink: 'ashtrail://test1',
            accountId: 'account1',
            contentId: 'content1',
            lastUpdated: DateTime.now(),
            isActive: true,
          ),
          SpotlightItemModel(
            id: 'test_id_2',
            type: 'chartView',
            title: 'Test Title 2',
            deepLink: 'ashtrail://test2',
            accountId: 'account1',
            contentId: 'content2',
            lastUpdated: DateTime.now(),
            isActive: true,
          ),
        ];

        // Act
        final result = await spotlightService.indexItems(items);

        // Assert
        expect(result.isRight(), true);
      });

      test('should handle PlatformException during batch indexing', () async {
        // Arrange
        const channel = MethodChannel('com.ashtrail.spotlight');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (methodCall) async {
          throw PlatformException(code: 'ERROR', message: 'Batch error');
        });

        final items = [
          SpotlightItemModel(
            id: 'test_id',
            type: 'tag',
            title: 'Test Title',
            deepLink: 'ashtrail://test',
            accountId: 'account1',
            contentId: 'content1',
            lastUpdated: DateTime.now(),
            isActive: true,
          ),
        ];

        // Act
        final result = await spotlightService.indexItems(items);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(
              failure.message, contains('Failed to index spotlight items')),
          (success) => fail('Expected failure'),
        );
      });
    });

    group('deindexItem', () {
      test('should successfully deindex a single item', () async {
        // Arrange
        const channel = MethodChannel('com.ashtrail.spotlight');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (methodCall) async {
          expect(methodCall.method, 'deindexItem');
          expect(methodCall.arguments['id'], 'test_id');
          return null;
        });

        // Act
        final result = await spotlightService.deindexItem('test_id');

        // Assert
        expect(result.isRight(), true);
      });

      test('should handle PlatformException during deindexing', () async {
        // Arrange
        const channel = MethodChannel('com.ashtrail.spotlight');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (methodCall) async {
          throw PlatformException(code: 'ERROR', message: 'Deindex error');
        });

        // Act
        final result = await spotlightService.deindexItem('test_id');

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(
              failure.message, contains('Failed to deindex spotlight item')),
          (success) => fail('Expected failure'),
        );
      });
    });

    group('deindexItems', () {
      test('should successfully deindex multiple items', () async {
        // Arrange
        const channel = MethodChannel('com.ashtrail.spotlight');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (methodCall) async {
          expect(methodCall.method, 'deindexItems');
          final ids = methodCall.arguments['ids'] as List;
          expect(ids, ['id1', 'id2']);
          return null;
        });

        // Act
        final result = await spotlightService.deindexItems(['id1', 'id2']);

        // Assert
        expect(result.isRight(), true);
      });

      test('should handle PlatformException during batch deindexing', () async {
        // Arrange
        const channel = MethodChannel('com.ashtrail.spotlight');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (methodCall) async {
          throw PlatformException(
              code: 'ERROR', message: 'Batch deindex error');
        });

        // Act
        final result = await spotlightService.deindexItems(['id1', 'id2']);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(
              failure.message, contains('Failed to deindex spotlight items')),
          (success) => fail('Expected failure'),
        );
      });
    });

    group('clearAllItems', () {
      test('should successfully clear all items', () async {
        // Arrange
        const channel = MethodChannel('com.ashtrail.spotlight');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (methodCall) async {
          expect(methodCall.method, 'clearAllItems');
          return null;
        });

        // Act
        final result = await spotlightService.clearAllItems();

        // Assert
        expect(result.isRight(), true);
      });

      test('should handle PlatformException during clear all', () async {
        // Arrange
        const channel = MethodChannel('com.ashtrail.spotlight');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (methodCall) async {
          throw PlatformException(code: 'ERROR', message: 'Clear error');
        });

        // Act
        final result = await spotlightService.clearAllItems();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(
              failure.message, contains('Failed to clear spotlight items')),
          (success) => fail('Expected failure'),
        );
      });
    });

    group('isSpotlightAvailable', () {
      test('should return true when Spotlight is available', () async {
        // Arrange
        const channel = MethodChannel('com.ashtrail.spotlight');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (methodCall) async {
          expect(methodCall.method, 'isSpotlightAvailable');
          return true;
        });

        // Act
        final result = await spotlightService.isSpotlightAvailable();

        // Assert
        expect(result, true);
      });

      test('should return false when Spotlight is not available', () async {
        // Arrange
        const channel = MethodChannel('com.ashtrail.spotlight');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (methodCall) async {
          expect(methodCall.method, 'isSpotlightAvailable');
          return false;
        });

        // Act
        final result = await spotlightService.isSpotlightAvailable();

        // Assert
        expect(result, false);
      });

      test('should return false when method call throws exception', () async {
        // Arrange
        const channel = MethodChannel('com.ashtrail.spotlight');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (methodCall) async {
          throw Exception('Not available');
        });

        // Act
        final result = await spotlightService.isSpotlightAvailable();

        // Assert
        expect(result, false);
      });

      test('should return false when method call returns null', () async {
        // Arrange
        const channel = MethodChannel('com.ashtrail.spotlight');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (methodCall) async {
          return null;
        });

        // Act
        final result = await spotlightService.isSpotlightAvailable();

        // Assert
        expect(result, false);
      });
    });
  });
}

class MockMethodChannel {
  void reset() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.ashtrail.spotlight'),
      null,
    );
  }
}
