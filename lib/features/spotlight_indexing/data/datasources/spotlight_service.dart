// iOS Spotlight integration service.
// Handles communication with Core Spotlight APIs for indexing and deindexing content.

import 'package:fpdart/fpdart.dart';
import 'package:flutter/services.dart';
import '../models/spotlight_item_model.dart';
import '../../../../core/failures/app_failure.dart';

class SpotlightService {
  static const MethodChannel _channel = MethodChannel('com.ashtrail.spotlight');

  /// Index a single item in iOS Spotlight search
  Future<Either<AppFailure, void>> indexItem(SpotlightItemModel item) async {
    try {
      await _channel.invokeMethod('indexItem', {
        'id': item.id,
        'title': item.title,
        'description': item.description ?? '',
        'keywords': item.keywords ?? [],
        'contentType': _getContentType(item.type),
        'url': item.deepLink,
        'lastUpdated': item.lastUpdated.millisecondsSinceEpoch,
      });
      return right(null);
    } on PlatformException catch (e) {
      return left(AppFailure.unexpected(
        message: 'Failed to index spotlight item: ${e.message}',
        cause: e,
      ));
    } catch (e) {
      return left(AppFailure.unexpected(
        message: 'Unexpected error indexing spotlight item: $e',
        cause: e,
      ));
    }
  }

  /// Index multiple items in a batch operation
  Future<Either<AppFailure, void>> indexItems(List<SpotlightItemModel> items) async {
    try {
      final itemsData = items.map((item) => {
        'id': item.id,
        'title': item.title,
        'description': item.description ?? '',
        'keywords': item.keywords ?? [],
        'contentType': _getContentType(item.type),
        'url': item.deepLink,
        'lastUpdated': item.lastUpdated.millisecondsSinceEpoch,
      }).toList();

      await _channel.invokeMethod('indexItems', {'items': itemsData});
      return right(null);
    } on PlatformException catch (e) {
      return left(AppFailure.unexpected(
        message: 'Failed to index spotlight items: ${e.message}',
        cause: e,
      ));
    } catch (e) {
      return left(AppFailure.unexpected(
        message: 'Unexpected error indexing spotlight items: $e',
        cause: e,
      ));
    }
  }

  /// Remove a single item from the spotlight index
  Future<Either<AppFailure, void>> deindexItem(String itemId) async {
    try {
      await _channel.invokeMethod('deindexItem', {'id': itemId});
      return right(null);
    } on PlatformException catch (e) {
      return left(AppFailure.unexpected(
        message: 'Failed to deindex spotlight item: ${e.message}',
        cause: e,
      ));
    } catch (e) {
      return left(AppFailure.unexpected(
        message: 'Unexpected error deindexing spotlight item: $e',
        cause: e,
      ));
    }
  }

  /// Remove multiple items from the spotlight index
  Future<Either<AppFailure, void>> deindexItems(List<String> itemIds) async {
    try {
      await _channel.invokeMethod('deindexItems', {'ids': itemIds});
      return right(null);
    } on PlatformException catch (e) {
      return left(AppFailure.unexpected(
        message: 'Failed to deindex spotlight items: ${e.message}',
        cause: e,
      ));
    } catch (e) {
      return left(AppFailure.unexpected(
        message: 'Unexpected error deindexing spotlight items: $e',
        cause: e,
      ));
    }
  }

  /// Clear all indexed items (typically used on logout)
  Future<Either<AppFailure, void>> clearAllItems() async {
    try {
      await _channel.invokeMethod('clearAllItems');
      return right(null);
    } on PlatformException catch (e) {
      return left(AppFailure.unexpected(
        message: 'Failed to clear spotlight items: ${e.message}',
        cause: e,
      ));
    } catch (e) {
      return left(AppFailure.unexpected(
        message: 'Unexpected error clearing spotlight items: $e',
        cause: e,
      ));
    }
  }

  /// Check if Spotlight indexing is available (iOS only)
  Future<bool> isSpotlightAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isSpotlightAvailable');
      return result ?? false;
    } catch (e) {
      // If the method channel fails, assume Spotlight is not available
      return false;
    }
  }

  /// Get the Core Spotlight content type for the given item type
  String _getContentType(String type) {
    switch (type) {
      case 'tag':
        return 'com.ashtrail.tag';
      case 'chartView':
        return 'com.ashtrail.chartview';
      default:
        return 'com.ashtrail.content';
    }
  }
}