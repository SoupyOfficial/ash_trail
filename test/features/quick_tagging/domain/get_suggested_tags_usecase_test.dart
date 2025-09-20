import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:ash_trail/core/failures/app_failure.dart';
import 'package:ash_trail/domain/models/tag.dart';
import 'package:ash_trail/features/quick_tagging/domain/repositories/quick_tagging_repository.dart';
import 'package:ash_trail/features/quick_tagging/domain/usecases/get_suggested_tags_usecase.dart';

class _RepoMock extends Mock implements QuickTaggingRepository {}

void main() {
  late _RepoMock repo;
  late GetSuggestedTagsUseCase useCase;

  setUp(() {
    repo = _RepoMock();
    useCase = GetSuggestedTagsUseCase(repository: repo);
  });

  test('returns validation failure when accountId empty', () async {
    final res = await useCase(accountId: '');
    expect(res.isLeft(), true);
    res.match(
      (l) => expect(l, isA<AppFailure>()),
      (_) => fail('Expected failure'),
    );
  });

  test('delegates to repository and returns tags', () async {
    final tags = [
      Tag(
          id: 't1',
          accountId: 'a1',
          name: 'Morning',
          color: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now()),
    ];
    when(() => repo.getTopSuggestedTags(accountId: 'a1', limit: 5))
        .thenAnswer((_) async => Right(tags));

    final res = await useCase(accountId: 'a1');

    expect(res.isRight(), true);
    res.match(
      (_) => fail('Expected success'),
      (r) => expect(r, tags),
    );
    verify(() => repo.getTopSuggestedTags(accountId: 'a1', limit: 5)).called(1);
  });
}
