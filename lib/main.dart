import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'logging/app_logger.dart';
import 'services/hive_database_service.dart';
import 'services/crash_reporting_service.dart';
import 'services/location_service.dart';
import 'screens/login_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/account_provider.dart';
import 'providers/home_widget_config_provider.dart';
import 'navigation/main_navigation.dart';

final _log = AppLogger.logger('main');

/// App initialization state per design doc 6.1.1
enum AppInitState { uninitialized, initializing, ready, failed }

/// Provider for app initialization state
final appInitStateProvider = StateProvider<AppInitState>((ref) {
  return AppInitState.uninitialized;
});

/// Main entry point for all platforms
/// Uses Hive database for offline-first storage on web, iOS, Android, and desktop
void main() async {
  _log.i('APP START at ${DateTime.now()}');

  WidgetsFlutterBinding.ensureInitialized();
  _log.i('WidgetsFlutterBinding initialized');

  try {
    _log.i('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _log.i('Firebase initialized');
  } catch (e) {
    _log.e('Firebase initialization error', error: e);
  }

  try {
    _log.i('Initializing CrashReportingService...');
    await CrashReportingService.initialize();
    _log.i('CrashReportingService initialized');
  } catch (e) {
    _log.e('Crash reporting initialization error', error: e);
  }

  try {
    _log.i('Initializing Hive database...');
    final db = HiveDatabaseService();
    await db.initialize();
    _log.i('Hive database initialized');
  } catch (e) {
    _log.e('Hive database initialization error', error: e);
  }

  try {
    _log.i('Checking location permissions...');
    final locationService = LocationService();
    final hasPermission = await locationService.hasLocationPermission();
    if (hasPermission) {
      _log.i('Location permission already granted');
    } else {
      _log.w('Location permission not granted - will prompt user');
    }
  } catch (e) {
    _log.e('Location service initialization error', error: e);
  }

  SharedPreferences? sharedPrefs;
  try {
    _log.i('Initializing SharedPreferences...');
    sharedPrefs = await SharedPreferences.getInstance();
    _log.i('SharedPreferences initialized');
  } catch (e) {
    _log.e('SharedPreferences initialization error', error: e);
  }

  _log.i('Starting ProviderScope and WidgetApp');
  runApp(
    ProviderScope(
      overrides: [
        if (sharedPrefs != null)
          sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const AshTrailApp(),
    ),
  );
}

class AshTrailApp extends ConsumerWidget {
  const AshTrailApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Royal blue and black color scheme
    const royalBlue = Color(0xFF4169E1);

    return MaterialApp(
      title: 'Ash Trail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: royalBlue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: royalBlue,
          brightness: Brightness.dark,
          surface: const Color(0xFF121212),
        ),
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.black,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
    );
  }
}

/// Wrapper widget that supports anonymous mode (per design doc 8.5)
/// Shows home screen for both authenticated and anonymous users
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final authState = ref.watch(authStateProvider);
      final activeAccount = ref.watch(activeAccountProvider);

      return authState.when(
        data: (user) {
          // Check if we have an active account (authenticated or anonymous)
          return activeAccount.when(
            data: (account) {
              if (account != null) {
                // Have an active account (authenticated or anonymous), show main navigation
                return const MainNavigation();
              }
              // No active account - show welcome screen with options
              return const WelcomeScreen();
            },
            loading:
                () => const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
            error: (error, stack) {
              _log.e('Active account provider error', error: error, stackTrace: stack);
              return Scaffold(
                body: Center(child: Text('Error: ${error.toString()}')),
              );
            },
          );
        },
        loading:
            () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
        error: (error, stack) {
          _log.e('Auth state provider error', error: error, stackTrace: stack);
          return Scaffold(
            body: Center(child: Text('Error: ${error.toString()}')),
          );
        },
      );
    } catch (e, stack) {
      _log.e('AuthWrapper build error', error: e, stackTrace: stack);
      return const WelcomeScreen();
    }
  }
}

/// Welcome screen for new users - offers sign in or anonymous mode
/// Per design doc 8.5: Anonymous usage is a first-class mode
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.local_fire_department,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to Ash Trail',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Track your sessions with ease',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Sign in button
              FilledButton.icon(
                key: const Key('sign_in_button'),
                onPressed: () {
                  try {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  } catch (e) {
                    _log.e('Navigation error', error: e);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error navigating: $e')),
                    );
                  }
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
              ),
              const SizedBox(height: 12),
              // Continue anonymously button (per design doc 8.5)
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    final switcher = ref.read(accountSwitcherProvider.notifier);
                    await switcher.createAnonymousAccount();
                  } catch (e) {
                    _log.e('Anonymous account creation error', error: e);
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                icon: const Icon(Icons.person_outline),
                label: const Text('Continue Without Account'),
              ),
              const SizedBox(height: 8),
              Text(
                'Your data stays on this device until you sign in',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
