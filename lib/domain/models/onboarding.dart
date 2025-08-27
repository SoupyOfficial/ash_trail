// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding.freezed.dart';
part 'onboarding.g.dart';

@freezed
class Onboarding with _$Onboarding {
  @JsonSerializable(explicitToJson: true)
  const factory Onboarding({
    required String accountId, // TODO: FK to Account
    required List<String> stepsCompleted, // TODO: constrain to enum values
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Onboarding;

  factory Onboarding.fromJson(Map<String, dynamic> json) =>
      _$OnboardingFromJson(json);
}
