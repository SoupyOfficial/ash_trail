// GENERATED - DO NOT EDIT.
// coverage:ignore-file

import 'package:freezed_annotation/freezed_annotation.dart';

part 'device.freezed.dart';
part 'device.g.dart';

@freezed
@JsonSerializable(explicitToJson: true)
class Device with _$Device {
  const factory Device({
    required String id,
    required String platform, // TODO: constrain to enum values
    required String appVersion,
    String? osVersion,
    String? model,
    required DateTime createdAt,
  }) = _Device;

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
}
