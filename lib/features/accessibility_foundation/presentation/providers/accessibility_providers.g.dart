// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accessibility_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$accessibilityCapabilitiesHash() =>
    r'e203ad631c19fe8bbade6c87068519b404a8a57d';

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

/// Provider for current accessibility capabilities from system
///
/// Copied from [accessibilityCapabilities].
@ProviderFor(accessibilityCapabilities)
const accessibilityCapabilitiesProvider = AccessibilityCapabilitiesFamily();

/// Provider for current accessibility capabilities from system
///
/// Copied from [accessibilityCapabilities].
class AccessibilityCapabilitiesFamily
    extends Family<AccessibilityCapabilities> {
  /// Provider for current accessibility capabilities from system
  ///
  /// Copied from [accessibilityCapabilities].
  const AccessibilityCapabilitiesFamily();

  /// Provider for current accessibility capabilities from system
  ///
  /// Copied from [accessibilityCapabilities].
  AccessibilityCapabilitiesProvider call(
    BuildContext context,
  ) {
    return AccessibilityCapabilitiesProvider(
      context,
    );
  }

  @override
  AccessibilityCapabilitiesProvider getProviderOverride(
    covariant AccessibilityCapabilitiesProvider provider,
  ) {
    return call(
      provider.context,
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
  String? get name => r'accessibilityCapabilitiesProvider';
}

/// Provider for current accessibility capabilities from system
///
/// Copied from [accessibilityCapabilities].
class AccessibilityCapabilitiesProvider
    extends AutoDisposeProvider<AccessibilityCapabilities> {
  /// Provider for current accessibility capabilities from system
  ///
  /// Copied from [accessibilityCapabilities].
  AccessibilityCapabilitiesProvider(
    BuildContext context,
  ) : this._internal(
          (ref) => accessibilityCapabilities(
            ref as AccessibilityCapabilitiesRef,
            context,
          ),
          from: accessibilityCapabilitiesProvider,
          name: r'accessibilityCapabilitiesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$accessibilityCapabilitiesHash,
          dependencies: AccessibilityCapabilitiesFamily._dependencies,
          allTransitiveDependencies:
              AccessibilityCapabilitiesFamily._allTransitiveDependencies,
          context: context,
        );

  AccessibilityCapabilitiesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.context,
  }) : super.internal();

  final BuildContext context;

  @override
  Override overrideWith(
    AccessibilityCapabilities Function(AccessibilityCapabilitiesRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AccessibilityCapabilitiesProvider._internal(
        (ref) => create(ref as AccessibilityCapabilitiesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        context: context,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<AccessibilityCapabilities> createElement() {
    return _AccessibilityCapabilitiesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AccessibilityCapabilitiesProvider &&
        other.context == context;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, context.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AccessibilityCapabilitiesRef
    on AutoDisposeProviderRef<AccessibilityCapabilities> {
  /// The parameter `context` of this provider.
  BuildContext get context;
}

class _AccessibilityCapabilitiesProviderElement
    extends AutoDisposeProviderElement<AccessibilityCapabilities>
    with AccessibilityCapabilitiesRef {
  _AccessibilityCapabilitiesProviderElement(super.provider);

  @override
  BuildContext get context =>
      (origin as AccessibilityCapabilitiesProvider).context;
}

String _$effectiveMinTapTargetHash() =>
    r'8c478750bab5ba3c04780d444dd690ddb48495c2';

/// Provider for effective minimum tap target size
///
/// Copied from [effectiveMinTapTarget].
@ProviderFor(effectiveMinTapTarget)
const effectiveMinTapTargetProvider = EffectiveMinTapTargetFamily();

/// Provider for effective minimum tap target size
///
/// Copied from [effectiveMinTapTarget].
class EffectiveMinTapTargetFamily extends Family<double> {
  /// Provider for effective minimum tap target size
  ///
  /// Copied from [effectiveMinTapTarget].
  const EffectiveMinTapTargetFamily();

  /// Provider for effective minimum tap target size
  ///
  /// Copied from [effectiveMinTapTarget].
  EffectiveMinTapTargetProvider call(
    BuildContext context, {
    double baseSize = 48.0,
  }) {
    return EffectiveMinTapTargetProvider(
      context,
      baseSize: baseSize,
    );
  }

  @override
  EffectiveMinTapTargetProvider getProviderOverride(
    covariant EffectiveMinTapTargetProvider provider,
  ) {
    return call(
      provider.context,
      baseSize: provider.baseSize,
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
  String? get name => r'effectiveMinTapTargetProvider';
}

/// Provider for effective minimum tap target size
///
/// Copied from [effectiveMinTapTarget].
class EffectiveMinTapTargetProvider extends AutoDisposeProvider<double> {
  /// Provider for effective minimum tap target size
  ///
  /// Copied from [effectiveMinTapTarget].
  EffectiveMinTapTargetProvider(
    BuildContext context, {
    double baseSize = 48.0,
  }) : this._internal(
          (ref) => effectiveMinTapTarget(
            ref as EffectiveMinTapTargetRef,
            context,
            baseSize: baseSize,
          ),
          from: effectiveMinTapTargetProvider,
          name: r'effectiveMinTapTargetProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$effectiveMinTapTargetHash,
          dependencies: EffectiveMinTapTargetFamily._dependencies,
          allTransitiveDependencies:
              EffectiveMinTapTargetFamily._allTransitiveDependencies,
          context: context,
          baseSize: baseSize,
        );

  EffectiveMinTapTargetProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.context,
    required this.baseSize,
  }) : super.internal();

  final BuildContext context;
  final double baseSize;

  @override
  Override overrideWith(
    double Function(EffectiveMinTapTargetRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: EffectiveMinTapTargetProvider._internal(
        (ref) => create(ref as EffectiveMinTapTargetRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        context: context,
        baseSize: baseSize,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<double> createElement() {
    return _EffectiveMinTapTargetProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is EffectiveMinTapTargetProvider &&
        other.context == context &&
        other.baseSize == baseSize;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, context.hashCode);
    hash = _SystemHash.combine(hash, baseSize.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin EffectiveMinTapTargetRef on AutoDisposeProviderRef<double> {
  /// The parameter `context` of this provider.
  BuildContext get context;

  /// The parameter `baseSize` of this provider.
  double get baseSize;
}

class _EffectiveMinTapTargetProviderElement
    extends AutoDisposeProviderElement<double> with EffectiveMinTapTargetRef {
  _EffectiveMinTapTargetProviderElement(super.provider);

  @override
  BuildContext get context => (origin as EffectiveMinTapTargetProvider).context;
  @override
  double get baseSize => (origin as EffectiveMinTapTargetProvider).baseSize;
}

String _$isScreenReaderActiveHash() =>
    r'41e73d32eee372c083fbb13a2f83c4824fd270e1';

/// Provider to check if screen reader is active
///
/// Copied from [isScreenReaderActive].
@ProviderFor(isScreenReaderActive)
const isScreenReaderActiveProvider = IsScreenReaderActiveFamily();

/// Provider to check if screen reader is active
///
/// Copied from [isScreenReaderActive].
class IsScreenReaderActiveFamily extends Family<bool> {
  /// Provider to check if screen reader is active
  ///
  /// Copied from [isScreenReaderActive].
  const IsScreenReaderActiveFamily();

  /// Provider to check if screen reader is active
  ///
  /// Copied from [isScreenReaderActive].
  IsScreenReaderActiveProvider call(
    BuildContext context,
  ) {
    return IsScreenReaderActiveProvider(
      context,
    );
  }

  @override
  IsScreenReaderActiveProvider getProviderOverride(
    covariant IsScreenReaderActiveProvider provider,
  ) {
    return call(
      provider.context,
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
  String? get name => r'isScreenReaderActiveProvider';
}

/// Provider to check if screen reader is active
///
/// Copied from [isScreenReaderActive].
class IsScreenReaderActiveProvider extends AutoDisposeProvider<bool> {
  /// Provider to check if screen reader is active
  ///
  /// Copied from [isScreenReaderActive].
  IsScreenReaderActiveProvider(
    BuildContext context,
  ) : this._internal(
          (ref) => isScreenReaderActive(
            ref as IsScreenReaderActiveRef,
            context,
          ),
          from: isScreenReaderActiveProvider,
          name: r'isScreenReaderActiveProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isScreenReaderActiveHash,
          dependencies: IsScreenReaderActiveFamily._dependencies,
          allTransitiveDependencies:
              IsScreenReaderActiveFamily._allTransitiveDependencies,
          context: context,
        );

  IsScreenReaderActiveProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.context,
  }) : super.internal();

  final BuildContext context;

  @override
  Override overrideWith(
    bool Function(IsScreenReaderActiveRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsScreenReaderActiveProvider._internal(
        (ref) => create(ref as IsScreenReaderActiveRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        context: context,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsScreenReaderActiveProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsScreenReaderActiveProvider && other.context == context;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, context.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin IsScreenReaderActiveRef on AutoDisposeProviderRef<bool> {
  /// The parameter `context` of this provider.
  BuildContext get context;
}

class _IsScreenReaderActiveProviderElement
    extends AutoDisposeProviderElement<bool> with IsScreenReaderActiveRef {
  _IsScreenReaderActiveProviderElement(super.provider);

  @override
  BuildContext get context => (origin as IsScreenReaderActiveProvider).context;
}

String _$shouldReduceMotionHash() =>
    r'11618e3f7dc4e298d77ce3f39ae3ea7a68332275';

/// Provider to check if motion should be reduced
///
/// Copied from [shouldReduceMotion].
@ProviderFor(shouldReduceMotion)
const shouldReduceMotionProvider = ShouldReduceMotionFamily();

/// Provider to check if motion should be reduced
///
/// Copied from [shouldReduceMotion].
class ShouldReduceMotionFamily extends Family<bool> {
  /// Provider to check if motion should be reduced
  ///
  /// Copied from [shouldReduceMotion].
  const ShouldReduceMotionFamily();

  /// Provider to check if motion should be reduced
  ///
  /// Copied from [shouldReduceMotion].
  ShouldReduceMotionProvider call(
    BuildContext context,
  ) {
    return ShouldReduceMotionProvider(
      context,
    );
  }

  @override
  ShouldReduceMotionProvider getProviderOverride(
    covariant ShouldReduceMotionProvider provider,
  ) {
    return call(
      provider.context,
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
  String? get name => r'shouldReduceMotionProvider';
}

/// Provider to check if motion should be reduced
///
/// Copied from [shouldReduceMotion].
class ShouldReduceMotionProvider extends AutoDisposeProvider<bool> {
  /// Provider to check if motion should be reduced
  ///
  /// Copied from [shouldReduceMotion].
  ShouldReduceMotionProvider(
    BuildContext context,
  ) : this._internal(
          (ref) => shouldReduceMotion(
            ref as ShouldReduceMotionRef,
            context,
          ),
          from: shouldReduceMotionProvider,
          name: r'shouldReduceMotionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shouldReduceMotionHash,
          dependencies: ShouldReduceMotionFamily._dependencies,
          allTransitiveDependencies:
              ShouldReduceMotionFamily._allTransitiveDependencies,
          context: context,
        );

  ShouldReduceMotionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.context,
  }) : super.internal();

  final BuildContext context;

  @override
  Override overrideWith(
    bool Function(ShouldReduceMotionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShouldReduceMotionProvider._internal(
        (ref) => create(ref as ShouldReduceMotionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        context: context,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _ShouldReduceMotionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShouldReduceMotionProvider && other.context == context;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, context.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ShouldReduceMotionRef on AutoDisposeProviderRef<bool> {
  /// The parameter `context` of this provider.
  BuildContext get context;
}

class _ShouldReduceMotionProviderElement
    extends AutoDisposeProviderElement<bool> with ShouldReduceMotionRef {
  _ShouldReduceMotionProviderElement(super.provider);

  @override
  BuildContext get context => (origin as ShouldReduceMotionProvider).context;
}

String _$platformAccessibilityFeaturesHash() =>
    r'eb82970ed1172b5983c0c99a948ec2954a06b86e';

/// Provider for platform accessibility features
///
/// Copied from [platformAccessibilityFeatures].
@ProviderFor(platformAccessibilityFeatures)
final platformAccessibilityFeaturesProvider =
    AutoDisposeFutureProvider<Map<String, dynamic>>.internal(
  platformAccessibilityFeatures,
  name: r'platformAccessibilityFeaturesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$platformAccessibilityFeaturesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PlatformAccessibilityFeaturesRef
    = AutoDisposeFutureProviderRef<Map<String, dynamic>>;
String _$shouldAnnounceImmediatelyHash() =>
    r'26b1d3f1af0b76750a2c88aead39d723504203d7';

/// Utility provider to check if semantic announcements should be immediate
///
/// Copied from [shouldAnnounceImmediately].
@ProviderFor(shouldAnnounceImmediately)
const shouldAnnounceImmediatelyProvider = ShouldAnnounceImmediatelyFamily();

/// Utility provider to check if semantic announcements should be immediate
///
/// Copied from [shouldAnnounceImmediately].
class ShouldAnnounceImmediatelyFamily extends Family<bool> {
  /// Utility provider to check if semantic announcements should be immediate
  ///
  /// Copied from [shouldAnnounceImmediately].
  const ShouldAnnounceImmediatelyFamily();

  /// Utility provider to check if semantic announcements should be immediate
  ///
  /// Copied from [shouldAnnounceImmediately].
  ShouldAnnounceImmediatelyProvider call({
    bool isError = false,
    bool isImportant = false,
  }) {
    return ShouldAnnounceImmediatelyProvider(
      isError: isError,
      isImportant: isImportant,
    );
  }

  @override
  ShouldAnnounceImmediatelyProvider getProviderOverride(
    covariant ShouldAnnounceImmediatelyProvider provider,
  ) {
    return call(
      isError: provider.isError,
      isImportant: provider.isImportant,
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
  String? get name => r'shouldAnnounceImmediatelyProvider';
}

/// Utility provider to check if semantic announcements should be immediate
///
/// Copied from [shouldAnnounceImmediately].
class ShouldAnnounceImmediatelyProvider extends AutoDisposeProvider<bool> {
  /// Utility provider to check if semantic announcements should be immediate
  ///
  /// Copied from [shouldAnnounceImmediately].
  ShouldAnnounceImmediatelyProvider({
    bool isError = false,
    bool isImportant = false,
  }) : this._internal(
          (ref) => shouldAnnounceImmediately(
            ref as ShouldAnnounceImmediatelyRef,
            isError: isError,
            isImportant: isImportant,
          ),
          from: shouldAnnounceImmediatelyProvider,
          name: r'shouldAnnounceImmediatelyProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shouldAnnounceImmediatelyHash,
          dependencies: ShouldAnnounceImmediatelyFamily._dependencies,
          allTransitiveDependencies:
              ShouldAnnounceImmediatelyFamily._allTransitiveDependencies,
          isError: isError,
          isImportant: isImportant,
        );

  ShouldAnnounceImmediatelyProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.isError,
    required this.isImportant,
  }) : super.internal();

  final bool isError;
  final bool isImportant;

  @override
  Override overrideWith(
    bool Function(ShouldAnnounceImmediatelyRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShouldAnnounceImmediatelyProvider._internal(
        (ref) => create(ref as ShouldAnnounceImmediatelyRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        isError: isError,
        isImportant: isImportant,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _ShouldAnnounceImmediatelyProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShouldAnnounceImmediatelyProvider &&
        other.isError == isError &&
        other.isImportant == isImportant;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, isError.hashCode);
    hash = _SystemHash.combine(hash, isImportant.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ShouldAnnounceImmediatelyRef on AutoDisposeProviderRef<bool> {
  /// The parameter `isError` of this provider.
  bool get isError;

  /// The parameter `isImportant` of this provider.
  bool get isImportant;
}

class _ShouldAnnounceImmediatelyProviderElement
    extends AutoDisposeProviderElement<bool> with ShouldAnnounceImmediatelyRef {
  _ShouldAnnounceImmediatelyProviderElement(super.provider);

  @override
  bool get isError => (origin as ShouldAnnounceImmediatelyProvider).isError;
  @override
  bool get isImportant =>
      (origin as ShouldAnnounceImmediatelyProvider).isImportant;
}

String _$isAccessibilityModeActiveHash() =>
    r'ae036169dba6786f3b8a0819de33b7acbe338e64';

/// Provider for accessibility mode detection
///
/// Copied from [isAccessibilityModeActive].
@ProviderFor(isAccessibilityModeActive)
const isAccessibilityModeActiveProvider = IsAccessibilityModeActiveFamily();

/// Provider for accessibility mode detection
///
/// Copied from [isAccessibilityModeActive].
class IsAccessibilityModeActiveFamily extends Family<bool> {
  /// Provider for accessibility mode detection
  ///
  /// Copied from [isAccessibilityModeActive].
  const IsAccessibilityModeActiveFamily();

  /// Provider for accessibility mode detection
  ///
  /// Copied from [isAccessibilityModeActive].
  IsAccessibilityModeActiveProvider call(
    BuildContext context,
  ) {
    return IsAccessibilityModeActiveProvider(
      context,
    );
  }

  @override
  IsAccessibilityModeActiveProvider getProviderOverride(
    covariant IsAccessibilityModeActiveProvider provider,
  ) {
    return call(
      provider.context,
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
  String? get name => r'isAccessibilityModeActiveProvider';
}

/// Provider for accessibility mode detection
///
/// Copied from [isAccessibilityModeActive].
class IsAccessibilityModeActiveProvider extends AutoDisposeProvider<bool> {
  /// Provider for accessibility mode detection
  ///
  /// Copied from [isAccessibilityModeActive].
  IsAccessibilityModeActiveProvider(
    BuildContext context,
  ) : this._internal(
          (ref) => isAccessibilityModeActive(
            ref as IsAccessibilityModeActiveRef,
            context,
          ),
          from: isAccessibilityModeActiveProvider,
          name: r'isAccessibilityModeActiveProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isAccessibilityModeActiveHash,
          dependencies: IsAccessibilityModeActiveFamily._dependencies,
          allTransitiveDependencies:
              IsAccessibilityModeActiveFamily._allTransitiveDependencies,
          context: context,
        );

  IsAccessibilityModeActiveProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.context,
  }) : super.internal();

  final BuildContext context;

  @override
  Override overrideWith(
    bool Function(IsAccessibilityModeActiveRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsAccessibilityModeActiveProvider._internal(
        (ref) => create(ref as IsAccessibilityModeActiveRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        context: context,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _IsAccessibilityModeActiveProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsAccessibilityModeActiveProvider &&
        other.context == context;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, context.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin IsAccessibilityModeActiveRef on AutoDisposeProviderRef<bool> {
  /// The parameter `context` of this provider.
  BuildContext get context;
}

class _IsAccessibilityModeActiveProviderElement
    extends AutoDisposeProviderElement<bool> with IsAccessibilityModeActiveRef {
  _IsAccessibilityModeActiveProviderElement(super.provider);

  @override
  BuildContext get context =>
      (origin as IsAccessibilityModeActiveProvider).context;
}

String _$needsLargerTapTargetsHash() =>
    r'6488b6bd6943eb7e5e523dc0f1f05eed41ecd195';

/// Provider for checking if larger tap targets are needed
///
/// Copied from [needsLargerTapTargets].
@ProviderFor(needsLargerTapTargets)
const needsLargerTapTargetsProvider = NeedsLargerTapTargetsFamily();

/// Provider for checking if larger tap targets are needed
///
/// Copied from [needsLargerTapTargets].
class NeedsLargerTapTargetsFamily extends Family<bool> {
  /// Provider for checking if larger tap targets are needed
  ///
  /// Copied from [needsLargerTapTargets].
  const NeedsLargerTapTargetsFamily();

  /// Provider for checking if larger tap targets are needed
  ///
  /// Copied from [needsLargerTapTargets].
  NeedsLargerTapTargetsProvider call(
    BuildContext context,
  ) {
    return NeedsLargerTapTargetsProvider(
      context,
    );
  }

  @override
  NeedsLargerTapTargetsProvider getProviderOverride(
    covariant NeedsLargerTapTargetsProvider provider,
  ) {
    return call(
      provider.context,
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
  String? get name => r'needsLargerTapTargetsProvider';
}

/// Provider for checking if larger tap targets are needed
///
/// Copied from [needsLargerTapTargets].
class NeedsLargerTapTargetsProvider extends AutoDisposeProvider<bool> {
  /// Provider for checking if larger tap targets are needed
  ///
  /// Copied from [needsLargerTapTargets].
  NeedsLargerTapTargetsProvider(
    BuildContext context,
  ) : this._internal(
          (ref) => needsLargerTapTargets(
            ref as NeedsLargerTapTargetsRef,
            context,
          ),
          from: needsLargerTapTargetsProvider,
          name: r'needsLargerTapTargetsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$needsLargerTapTargetsHash,
          dependencies: NeedsLargerTapTargetsFamily._dependencies,
          allTransitiveDependencies:
              NeedsLargerTapTargetsFamily._allTransitiveDependencies,
          context: context,
        );

  NeedsLargerTapTargetsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.context,
  }) : super.internal();

  final BuildContext context;

  @override
  Override overrideWith(
    bool Function(NeedsLargerTapTargetsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NeedsLargerTapTargetsProvider._internal(
        (ref) => create(ref as NeedsLargerTapTargetsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        context: context,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _NeedsLargerTapTargetsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NeedsLargerTapTargetsProvider && other.context == context;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, context.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin NeedsLargerTapTargetsRef on AutoDisposeProviderRef<bool> {
  /// The parameter `context` of this provider.
  BuildContext get context;
}

class _NeedsLargerTapTargetsProviderElement
    extends AutoDisposeProviderElement<bool> with NeedsLargerTapTargetsRef {
  _NeedsLargerTapTargetsProviderElement(super.provider);

  @override
  BuildContext get context => (origin as NeedsLargerTapTargetsProvider).context;
}

String _$needsHighContrastHash() => r'd7e5ef6cb328e29d19711374eea82b3970e5a299';

/// Provider for checking if high contrast is needed
///
/// Copied from [needsHighContrast].
@ProviderFor(needsHighContrast)
const needsHighContrastProvider = NeedsHighContrastFamily();

/// Provider for checking if high contrast is needed
///
/// Copied from [needsHighContrast].
class NeedsHighContrastFamily extends Family<bool> {
  /// Provider for checking if high contrast is needed
  ///
  /// Copied from [needsHighContrast].
  const NeedsHighContrastFamily();

  /// Provider for checking if high contrast is needed
  ///
  /// Copied from [needsHighContrast].
  NeedsHighContrastProvider call(
    BuildContext context,
  ) {
    return NeedsHighContrastProvider(
      context,
    );
  }

  @override
  NeedsHighContrastProvider getProviderOverride(
    covariant NeedsHighContrastProvider provider,
  ) {
    return call(
      provider.context,
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
  String? get name => r'needsHighContrastProvider';
}

/// Provider for checking if high contrast is needed
///
/// Copied from [needsHighContrast].
class NeedsHighContrastProvider extends AutoDisposeProvider<bool> {
  /// Provider for checking if high contrast is needed
  ///
  /// Copied from [needsHighContrast].
  NeedsHighContrastProvider(
    BuildContext context,
  ) : this._internal(
          (ref) => needsHighContrast(
            ref as NeedsHighContrastRef,
            context,
          ),
          from: needsHighContrastProvider,
          name: r'needsHighContrastProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$needsHighContrastHash,
          dependencies: NeedsHighContrastFamily._dependencies,
          allTransitiveDependencies:
              NeedsHighContrastFamily._allTransitiveDependencies,
          context: context,
        );

  NeedsHighContrastProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.context,
  }) : super.internal();

  final BuildContext context;

  @override
  Override overrideWith(
    bool Function(NeedsHighContrastRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NeedsHighContrastProvider._internal(
        (ref) => create(ref as NeedsHighContrastRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        context: context,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _NeedsHighContrastProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NeedsHighContrastProvider && other.context == context;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, context.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin NeedsHighContrastRef on AutoDisposeProviderRef<bool> {
  /// The parameter `context` of this provider.
  BuildContext get context;
}

class _NeedsHighContrastProviderElement extends AutoDisposeProviderElement<bool>
    with NeedsHighContrastRef {
  _NeedsHighContrastProviderElement(super.provider);

  @override
  BuildContext get context => (origin as NeedsHighContrastProvider).context;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
