import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/features/error_boundary/data/services/share_service.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

void main() {
  group('ShareService', () {
    test('PlatformShareService returns failure (not implemented)', () async {
      final service = PlatformShareService();

      final res = await service.shareText(text: 'hello', subject: 'subj');
      expect(res.isLeft(), isTrue);
      res.match(
        (l) => expect(l, isA<AppFailure>()),
        (_) => fail('Expected failure for unimplemented platform share'),
      );

      final res2 = await service.shareTextFromRect(
        text: 'hello',
        subject: null,
        x: 0,
        y: 0,
        width: 10,
        height: 10,
      );
      expect(res2.isLeft(), isTrue);
    });

    test('DebugShareService returns success and prints', () async {
      final service = DebugShareService();

      final res =
          await service.shareText(text: 'hello world', subject: 'greet');
      expect(res.isRight(), isTrue);
      res.match(
        (_) => fail('Unexpected failure'),
        (r) => expect(r, equals(unit)),
      );

      final res2 = await service.shareTextFromRect(
        text: 'from rect',
        subject: 'area',
        x: 1,
        y: 2,
        width: 3,
        height: 4,
      );
      expect(res2.isRight(), isTrue);
    });
  });
}
