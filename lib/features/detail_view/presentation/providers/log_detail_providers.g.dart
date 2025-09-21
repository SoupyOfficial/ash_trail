// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_detail_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$logDetailRepositoryHash() =>
    r'ae7703e9404319416d758ef326a88c04e3dd671a';

/// Repository provider
///
/// Copied from [logDetailRepository].
@ProviderFor(logDetailRepository)
final logDetailRepositoryProvider = Provider<LogDetailRepository>.internal(
  logDetailRepository,
  name: r'logDetailRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$logDetailRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LogDetailRepositoryRef = ProviderRef<LogDetailRepository>;
String _$getLogDetailUseCaseHash() =>
    r'7bec25f23db7e989ca38bdb8654cc3e32500f43b';

/// Use case providers
///
/// Copied from [getLogDetailUseCase].
@ProviderFor(getLogDetailUseCase)
final getLogDetailUseCaseProvider = Provider<GetLogDetailUseCase>.internal(
  getLogDetailUseCase,
  name: r'getLogDetailUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getLogDetailUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetLogDetailUseCaseRef = ProviderRef<GetLogDetailUseCase>;
String _$refreshLogDetailUseCaseHash() =>
    r'5e2b28e2226961d4d7a17c594caa06a7e09e5b0a';

/// See also [refreshLogDetailUseCase].
@ProviderFor(refreshLogDetailUseCase)
final refreshLogDetailUseCaseProvider =
    Provider<RefreshLogDetailUseCase>.internal(
  refreshLogDetailUseCase,
  name: r'refreshLogDetailUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$refreshLogDetailUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RefreshLogDetailUseCaseRef = ProviderRef<RefreshLogDetailUseCase>;
String _$logDetailErrorHash() => r'82f06b5eb496e126b0b9a8a85482da1ba3b14be8';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Convenience provider for error handling
///
/// Copied from [logDetailError].
@ProviderFor(logDetailError)
const logDetailErrorProvider = LogDetailErrorFamily();

/// Convenience provider for error handling
///
/// Copied from [logDetailError].
class LogDetailErrorFamily extends Family<String?> {
  /// Convenience provider for error handling
  ///
  /// Copied from [logDetailError].
  const LogDetailErrorFamily();

  /// Convenience provider for error handling
  ///
  /// Copied from [logDetailError].
  LogDetailErrorProvider call(
    String logId,
  ) {
    return LogDetailErrorProvider(
      logId,
    );
  }

  @override
  LogDetailErrorProvider getProviderOverride(
    covariant LogDetailErrorProvider provider,
  ) {
    return call(
      provider.logId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'logDetailErrorProvider';
}

/// Convenience provider for error handling
///
/// Copied from [logDetailError].
class LogDetailErrorProvider extends AutoDisposeProvider<String?> {
  /// Convenience provider for error handling
  ///
  /// Copied from [logDetailError].
  LogDetailErrorProvider(
    String logId,
  ) : this._internal(
          (ref) => logDetailError(
            ref as LogDetailErrorRef,
            logId,
          ),
          from: logDetailErrorProvider,
          name: r'logDetailErrorProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$logDetailErrorHash,
          dependencies: LogDetailErrorFamily._dependencies,
          allTransitiveDependencies:
              LogDetailErrorFamily._allTransitiveDependencies,
          logId: logId,
        );

  LogDetailErrorProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.logId,
  }) : super.internal();

  final String logId;

  @override
  Override overrideWith(
    String? Function(LogDetailErrorRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LogDetailErrorProvider._internal(
        (ref) => create(ref as LogDetailErrorRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        logId: logId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<String?> createElement() {
    return _LogDetailErrorProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LogDetailErrorProvider && other.logId == logId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, logId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LogDetailErrorRef on AutoDisposeProviderRef<String?> {
  /// The parameter `logId` of this provider.
  String get logId;
}

class _LogDetailErrorProviderElement extends AutoDisposeProviderElement<String?>
    with LogDetailErrorRef {
  _LogDetailErrorProviderElement(super.provider);

  @override
  String get logId => (origin as LogDetailErrorProvider).logId;
}

String _$logDetailNotifierHash() => r'ebbff43d3d97df158cbff6348edfbf33af7bd3c3';

abstract class _$LogDetailNotifier
    extends BuildlessAutoDisposeAsyncNotifier<LogDetailEntity> {
  late final String logId;

  FutureOr<LogDetailEntity> build(
    String logId,
  );
}

/// Log detail state provider
///
/// Copied from [LogDetailNotifier].
@ProviderFor(LogDetailNotifier)
const logDetailNotifierProvider = LogDetailNotifierFamily();

/// Log detail state provider
///
/// Copied from [LogDetailNotifier].
class LogDetailNotifierFamily extends Family<AsyncValue<LogDetailEntity>> {
  /// Log detail state provider
  ///
  /// Copied from [LogDetailNotifier].
  const LogDetailNotifierFamily();

  /// Log detail state provider
  ///
  /// Copied from [LogDetailNotifier].
  LogDetailNotifierProvider call(
    String logId,
  ) {
    return LogDetailNotifierProvider(
      logId,
    );
  }

  @override
  LogDetailNotifierProvider getProviderOverride(
    covariant LogDetailNotifierProvider provider,
  ) {
    return call(
      provider.logId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'logDetailNotifierProvider';
}

/// Log detail state provider
///
/// Copied from [LogDetailNotifier].
class LogDetailNotifierProvider extends AutoDisposeAsyncNotifierProviderImpl<
    LogDetailNotifier, LogDetailEntity> {
  /// Log detail state provider
  ///
  /// Copied from [LogDetailNotifier].
  LogDetailNotifierProvider(
    String logId,
  ) : this._internal(
          () => LogDetailNotifier()..logId = logId,
          from: logDetailNotifierProvider,
          name: r'logDetailNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$logDetailNotifierHash,
          dependencies: LogDetailNotifierFamily._dependencies,
          allTransitiveDependencies:
              LogDetailNotifierFamily._allTransitiveDependencies,
          logId: logId,
        );

  LogDetailNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.logId,
  }) : super.internal();

  final String logId;

  @override
  FutureOr<LogDetailEntity> runNotifierBuild(
    covariant LogDetailNotifier notifier,
  ) {
    return notifier.build(
      logId,
    );
  }

  @override
  Override overrideWith(LogDetailNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: LogDetailNotifierProvider._internal(
        () => create()..logId = logId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        logId: logId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<LogDetailNotifier, LogDetailEntity>
      createElement() {
    return _LogDetailNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LogDetailNotifierProvider && other.logId == logId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, logId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LogDetailNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<LogDetailEntity> {
  /// The parameter `logId` of this provider.
  String get logId;
}

class _LogDetailNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<LogDetailNotifier,
        LogDetailEntity> with LogDetailNotifierRef {
  _LogDetailNotifierProviderElement(super.provider);

  @override
  String get logId => (origin as LogDetailNotifierProvider).logId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
