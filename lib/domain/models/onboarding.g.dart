// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Onboarding _$OnboardingFromJson(Map<String, dynamic> json) => Onboarding(
  accountId: json['accountId'] as String,
  stepsCompleted:
      (json['stepsCompleted'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$OnboardingToJson(Onboarding instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'stepsCompleted': instance.stepsCompleted,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$OnboardingImpl _$$OnboardingImplFromJson(Map<String, dynamic> json) =>
    _$OnboardingImpl(
      accountId: json['accountId'] as String,
      stepsCompleted:
          (json['stepsCompleted'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$OnboardingImplToJson(_$OnboardingImpl instance) =>
    <String, dynamic>{
      'accountId': instance.accountId,
      'stepsCompleted': instance.stepsCompleted,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
