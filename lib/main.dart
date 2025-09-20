import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/routing/app_router.dart';
import 'features/theming/presentation/providers/theme_provider.dart';
import 'features/haptics_baseline/presentation/providers/haptics_providers.dart';
import 'features/quick_actions/presentation/widgets/quick_actions_listener.dart';
import 'core/feature_flags/feature_flags.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences for theme persistence
  final prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [
      createThemeRepositoryOverride(prefs),
      sharedPreferencesProvider.overrideWithValue(prefs),
      // Runtime feature flags override
      // Use compile-time environment variables to enable gated features in specific builds
      // Example: flutter run --dart-define=ENABLE_BATCH_EDIT=true
      featureFlagsProvider.overrideWithValue(const {
        if (bool.fromEnvironment('ENABLE_BATCH_EDIT', defaultValue: false))
          'logging.batch_edit_delete': true,
        if (bool.fromEnvironment('ENABLE_INLINE_EDIT', defaultValue: false))
          'logging.edit_inline_snackbar': true,
      }),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final theme = ref.watch(currentThemeDataProvider);

    return QuickActionsListener(
      child: MaterialApp.router(
        title: 'AshTrail',
        theme: theme,
        routerConfig: router,
      ),
    );
  }
}
