import 'package:ash_trail/domain/models/tag.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Tag fromJson/toJson roundtrip covers generated mapping', () {
    final now = DateTime.utc(2025, 1, 2, 3, 4, 5);
    final tag = Tag(
      id: 't1',
      accountId: 'acct1',
      name: 'Focus',
      color: '#FF00FF',
      createdAt: now,
      updatedAt: now,
    );

    final json = tag.toJson();
    final parsed = Tag.fromJson(json);

    expect(parsed.id, 't1');
    expect(parsed.accountId, 'acct1');
    expect(parsed.name, 'Focus');
    expect(parsed.color, '#FF00FF');
    expect(parsed.createdAt.toUtc(), now);
    expect(parsed.updatedAt.toUtc(), now);
  });
}
