// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_widgets_notifiers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeWidgetsListHash() => r'06a9d1412cd5bc32c0a51bda4bf6979d7cbe04dc';

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

abstract class _$HomeWidgetsList
    extends BuildlessAutoDisposeAsyncNotifier<List<WidgetData>> {
  late final String accountId;

  FutureOr<List<WidgetData>> build(
    String accountId,
  );
}

/// See also [HomeWidgetsList].
@ProviderFor(HomeWidgetsList)
const homeWidgetsListProvider = HomeWidgetsListFamily();

/// See also [HomeWidgetsList].
class HomeWidgetsListFamily extends Family<AsyncValue<List<WidgetData>>> {
  /// See also [HomeWidgetsList].
  const HomeWidgetsListFamily();

  /// See also [HomeWidgetsList].
  HomeWidgetsListProvider call(
    String accountId,
  ) {
    return HomeWidgetsListProvider(
      accountId,
    );
  }

  @override
  HomeWidgetsListProvider getProviderOverride(
    covariant HomeWidgetsListProvider provider,
  ) {
    return call(
      provider.accountId,
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
  String? get name => r'homeWidgetsListProvider';
}

/// See also [HomeWidgetsList].
class HomeWidgetsListProvider extends AutoDisposeAsyncNotifierProviderImpl<
    HomeWidgetsList, List<WidgetData>> {
  /// See also [HomeWidgetsList].
  HomeWidgetsListProvider(
    String accountId,
  ) : this._internal(
          () => HomeWidgetsList()..accountId = accountId,
          from: homeWidgetsListProvider,
          name: r'homeWidgetsListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$homeWidgetsListHash,
          dependencies: HomeWidgetsListFamily._dependencies,
          allTransitiveDependencies:
              HomeWidgetsListFamily._allTransitiveDependencies,
          accountId: accountId,
        );

  HomeWidgetsListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.accountId,
  }) : super.internal();

  final String accountId;

  @override
  FutureOr<List<WidgetData>> runNotifierBuild(
    covariant HomeWidgetsList notifier,
  ) {
    return notifier.build(
      accountId,
    );
  }

  @override
  Override overrideWith(HomeWidgetsList Function() create) {
    return ProviderOverride(
      origin: this,
      override: HomeWidgetsListProvider._internal(
        () => create()..accountId = accountId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        accountId: accountId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<HomeWidgetsList, List<WidgetData>>
      createElement() {
    return _HomeWidgetsListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HomeWidgetsListProvider && other.accountId == accountId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, accountId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin HomeWidgetsListRef
    on AutoDisposeAsyncNotifierProviderRef<List<WidgetData>> {
  /// The parameter `accountId` of this provider.
  String get accountId;
}

class _HomeWidgetsListProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<HomeWidgetsList,
        List<WidgetData>> with HomeWidgetsListRef {
  _HomeWidgetsListProviderElement(super.provider);

  @override
  String get accountId => (origin as HomeWidgetsListProvider).accountId;
}

String _$widgetConfigurationHash() =>
    r'be8fa27074a718665c25d1605fa8d23c4e3d9d99';

/// See also [WidgetConfiguration].
@ProviderFor(WidgetConfiguration)
final widgetConfigurationProvider = AutoDisposeNotifierProvider<
    WidgetConfiguration, WidgetConfigState>.internal(
  WidgetConfiguration.new,
  name: r'widgetConfigurationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$widgetConfigurationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WidgetConfiguration = AutoDisposeNotifier<WidgetConfigState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
