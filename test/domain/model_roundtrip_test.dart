import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ash_trail/domain/models/account.dart';

void main() {
  test('Account JSON roundtrip', () {
    const account = Account(
      id: 'a1',
      displayName: 'User One',
      provider: 'email',
    );
    final jsonStr = jsonEncode(account.toJson());
    final decoded = Account.fromJson(
      jsonDecode(jsonStr) as Map<String, dynamic>,
    );
    expect(decoded, equals(account));
  });
}
