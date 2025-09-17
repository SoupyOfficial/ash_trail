import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/routing/app_router.dart';
import 'features/theming/presentation/providers/theme_provider.dart';
import 'features/haptics_baseline/presentation/providers/haptics_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences for theme persistence
  final prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [
      createThemeRepositoryOverride(prefs),
      sharedPreferencesProvider.overrideWithValue(prefs),
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

    return MaterialApp.router(
      title: 'AshTrail',
      theme: theme,
      routerConfig: router,
    );
  }
}
