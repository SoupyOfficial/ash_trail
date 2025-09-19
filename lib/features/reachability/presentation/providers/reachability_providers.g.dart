// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reachability_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$reachabilityRepositoryHash() =>
    r'14bff35f1be60ebea41e3eb9016eb5f3d527c4b5';

/// See also [reachabilityRepository].
@ProviderFor(reachabilityRepository)
final reachabilityRepositoryProvider =
    AutoDisposeFutureProvider<ReachabilityRepositoryImpl>.internal(
  reachabilityRepository,
  name: r'reachabilityRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reachabilityRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReachabilityRepositoryRef
    = AutoDisposeFutureProviderRef<ReachabilityRepositoryImpl>;
String _$reachabilityLocalDataSourceHash() =>
    r'e5137f8b10a0c29c9e97a346e544d4c4b91b877d';

/// See also [reachabilityLocalDataSource].
@ProviderFor(reachabilityLocalDataSource)
final reachabilityLocalDataSourceProvider =
    AutoDisposeFutureProvider<ReachabilityLocalDataSource>.internal(
  reachabilityLocalDataSource,
  name: r'reachabilityLocalDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$reachabilityLocalDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReachabilityLocalDataSourceRef
    = AutoDisposeFutureProviderRef<ReachabilityLocalDataSource>;
String _$performReachabilityAuditUseCaseHash() =>
    r'b51c0aa19c3839a14750320cb38e5e7517cf74b5';

/// See also [performReachabilityAuditUseCase].
@ProviderFor(performReachabilityAuditUseCase)
final performReachabilityAuditUseCaseProvider =
    AutoDisposeFutureProvider<PerformReachabilityAuditUseCase>.internal(
  performReachabilityAuditUseCase,
  name: r'performReachabilityAuditUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$performReachabilityAuditUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PerformReachabilityAuditUseCaseRef
    = AutoDisposeFutureProviderRef<PerformReachabilityAuditUseCase>;
String _$getAuditReportsUseCaseHash() =>
    r'4437c5b88ab9d37863d0a141fa87b926e8230b03';

/// See also [getAuditReportsUseCase].
@ProviderFor(getAuditReportsUseCase)
final getAuditReportsUseCaseProvider =
    AutoDisposeFutureProvider<GetAuditReportsUseCase>.internal(
  getAuditReportsUseCase,
  name: r'getAuditReportsUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getAuditReportsUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetAuditReportsUseCaseRef
    = AutoDisposeFutureProviderRef<GetAuditReportsUseCase>;
String _$getReachabilityZonesUseCaseHash() =>
    r'0423ad870e61d185eb737f2950999b56768b1785';

/// See also [getReachabilityZonesUseCase].
@ProviderFor(getReachabilityZonesUseCase)
final getReachabilityZonesUseCaseProvider =
    AutoDisposeFutureProvider<GetReachabilityZonesUseCase>.internal(
  getReachabilityZonesUseCase,
  name: r'getReachabilityZonesUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getReachabilityZonesUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetReachabilityZonesUseCaseRef
    = AutoDisposeFutureProviderRef<GetReachabilityZonesUseCase>;
String _$saveAuditReportUseCaseHash() =>
    r'ea9c07f5c46841e192afe7d3c204cd9e87841255';

/// See also [saveAuditReportUseCase].
@ProviderFor(saveAuditReportUseCase)
final saveAuditReportUseCaseProvider =
    AutoDisposeFutureProvider<SaveAuditReportUseCase>.internal(
  saveAuditReportUseCase,
  name: r'saveAuditReportUseCaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$saveAuditReportUseCaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SaveAuditReportUseCaseRef
    = AutoDisposeFutureProviderRef<SaveAuditReportUseCase>;
String _$reachabilityZonesHash() => r'64697f7637bd8270c4e0cda733ced571dc89fe7f';

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

/// See also [reachabilityZones].
@ProviderFor(reachabilityZones)
const reachabilityZonesProvider = ReachabilityZonesFamily();

/// See also [reachabilityZones].
class ReachabilityZonesFamily
    extends Family<AsyncValue<List<ReachabilityZone>>> {
  /// See also [reachabilityZones].
  const ReachabilityZonesFamily();

  /// See also [reachabilityZones].
  ReachabilityZonesProvider call(
    Size screenSize,
  ) {
    return ReachabilityZonesProvider(
      screenSize,
    );
  }

  @override
  ReachabilityZonesProvider getProviderOverride(
    covariant ReachabilityZonesProvider provider,
  ) {
    return call(
      provider.screenSize,
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
  String? get name => r'reachabilityZonesProvider';
}

/// See also [reachabilityZones].
class ReachabilityZonesProvider
    extends AutoDisposeFutureProvider<List<ReachabilityZone>> {
  /// See also [reachabilityZones].
  ReachabilityZonesProvider(
    Size screenSize,
  ) : this._internal(
          (ref) => reachabilityZones(
            ref as ReachabilityZonesRef,
            screenSize,
          ),
          from: reachabilityZonesProvider,
          name: r'reachabilityZonesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$reachabilityZonesHash,
          dependencies: ReachabilityZonesFamily._dependencies,
          allTransitiveDependencies:
              ReachabilityZonesFamily._allTransitiveDependencies,
          screenSize: screenSize,
        );

  ReachabilityZonesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.screenSize,
  }) : super.internal();

  final Size screenSize;

  @override
  Override overrideWith(
    FutureOr<List<ReachabilityZone>> Function(ReachabilityZonesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReachabilityZonesProvider._internal(
        (ref) => create(ref as ReachabilityZonesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        screenSize: screenSize,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ReachabilityZone>> createElement() {
    return _ReachabilityZonesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReachabilityZonesProvider && other.screenSize == screenSize;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, screenSize.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ReachabilityZonesRef
    on AutoDisposeFutureProviderRef<List<ReachabilityZone>> {
  /// The parameter `screenSize` of this provider.
  Size get screenSize;
}

class _ReachabilityZonesProviderElement
    extends AutoDisposeFutureProviderElement<List<ReachabilityZone>>
    with ReachabilityZonesRef {
  _ReachabilityZonesProviderElement(super.provider);

  @override
  Size get screenSize => (origin as ReachabilityZonesProvider).screenSize;
}

String _$isAuditInProgressHash() => r'2de14cabebe253b2a8398b44231e10fb2e55aeb6';

/// See also [isAuditInProgress].
@ProviderFor(isAuditInProgress)
final isAuditInProgressProvider = AutoDisposeProvider<bool>.internal(
  isAuditInProgress,
  name: r'isAuditInProgressProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAuditInProgressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAuditInProgressRef = AutoDisposeProviderRef<bool>;
String _$auditComplianceScoreHash() =>
    r'3bc8c36f2bb8348a6fdfc9809e365e1b37645914';

/// See also [auditComplianceScore].
@ProviderFor(auditComplianceScore)
final auditComplianceScoreProvider = AutoDisposeProvider<double>.internal(
  auditComplianceScore,
  name: r'auditComplianceScoreProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$auditComplianceScoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuditComplianceScoreRef = AutoDisposeProviderRef<double>;
String _$auditPassesThresholdHash() =>
    r'3179ce06d3bf91e2bef557ecce35744a22ac9e1e';

/// See also [auditPassesThreshold].
@ProviderFor(auditPassesThreshold)
final auditPassesThresholdProvider = AutoDisposeProvider<bool>.internal(
  auditPassesThreshold,
  name: r'auditPassesThresholdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$auditPassesThresholdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AuditPassesThresholdRef = AutoDisposeProviderRef<bool>;
String _$auditReportsListHash() => r'7fd1d8908103e9071d1c1231625a9f5911a6b2f5';

/// See also [AuditReportsList].
@ProviderFor(AuditReportsList)
final auditReportsListProvider = AutoDisposeAsyncNotifierProvider<
    AuditReportsList, List<ReachabilityAuditReport>>.internal(
  AuditReportsList.new,
  name: r'auditReportsListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$auditReportsListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuditReportsList
    = AutoDisposeAsyncNotifier<List<ReachabilityAuditReport>>;
String _$currentAuditReportHash() =>
    r'46417144a53f2916f0c852193c8f8ef9ba957dc0';

/// See also [CurrentAuditReport].
@ProviderFor(CurrentAuditReport)
final currentAuditReportProvider = AutoDisposeNotifierProvider<
    CurrentAuditReport, ReachabilityAuditReport?>.internal(
  CurrentAuditReport.new,
  name: r'currentAuditReportProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentAuditReportHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentAuditReport = AutoDisposeNotifier<ReachabilityAuditReport?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
