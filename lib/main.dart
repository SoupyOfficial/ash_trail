import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'logging/app_logger.dart';
import 'models/app_error.dart';
import 'services/hive_database_service.dart';
import 'services/app_analytics_service.dart';
import 'services/app_performance_service.dart';
import 'services/crash_reporting_service.dart';
import 'services/error_reporting_service.dart';
import 'services/location_service.dart';
import 'services/otel_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'screens/login_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/account_provider.dart';
import 'providers/app_settings_provider.dart';
import 'providers/home_widget_config_provider.dart';
import 'navigation/main_navigation.dart';
import 'utils/error_display.dart';

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
  // Enable verbose logging for TestFlight/QA builds.
  // This ensures all debug/info logs from HomeQuickLogWidget, AccountSwitcher,
  // LogRecordService, etc. are visible even in release mode.
  // Set to false before production release to reduce log noise.
  const enableVerbose = bool.fromEnvironment(
    'VERBOSE_LOGGING',
    defaultValue: true,
  );
  AppLogger.setVerboseLogging(enableVerbose);

  _log.i('APP START at ${DateTime.now()}');
  _log.w(
    'Verbose logging: $enableVerbose (diagnostics: ${AppLogger.diagnostics})',
  );

  WidgetsFlutterBinding.ensureInitialized();
  _log.i('WidgetsFlutterBinding initialized');

  // Set custom error widget for release builds
  ErrorWidget.builder = (FlutterErrorDetails details) {
    ErrorReportingService.instance.reportException(
      details.exception,
      stackTrace: details.stack,
      context: 'ErrorWidget.builder',
    );
    return Material(
      child: Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This section encountered an error. Try navigating away and back.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  };

  try {
    _log.i('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _log.i('Firebase initialized');
  } catch (e) {
    _log.e('Firebase initialization error', error: e);
  }

  // Initialize OpenTelemetry (before any traced operations so dual-write
  // captures startup spans). Non-fatal — app works without OTel.
  try {
    await OTelService.instance.initialize();
    _log.i('OTelService initialized');
  } catch (e) {
    _log.e('OTel initialization error (non-fatal)', error: e);
  }

  try {
    _log.i('Initializing CrashReportingService...');
    await AppPerformanceService.instance.traceStartup('crashlytics', () async {
      await CrashReportingService.initialize();
      await CrashReportingService.setDeviceContext();
    });
    _log.i('CrashReportingService initialized');
  } catch (e) {
    _log.e('Crash reporting initialization error', error: e);
  }

  // --- Observability init (always-on, all build modes) ---

  // Wire logger breadcrumbs → Crashlytics (D2)
  AppLogger.onErrorLog = (name, message) {
    CrashReportingService.logMessage('[$name] $message');
  };

  // Initialize analytics — explicitly enable collection
  try {
    await AppAnalyticsService.instance.initialize();
    _log.i('AppAnalyticsService initialized');
  } catch (e) {
    _log.e('Analytics initialization error', error: e);
  }

  // Performance SDK auto-starts with Firebase — custom traces available immediately
  _log.i('AppPerformanceService ready (auto-started with Firebase)');

  try {
    _log.i('Initializing Hive database...');
    await AppPerformanceService.instance.traceStartup('hive', () async {
      final db = HiveDatabaseService();
      await db.initialize();
    });
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
    sharedPrefs = await AppPerformanceService.instance.traceStartup(
      'shared_prefs',
      () async {
        return await SharedPreferences.getInstance();
      },
    );
    _log.i('SharedPreferences initialized');
  } catch (e) {
    _log.e('SharedPreferences initialization error', error: e);
  }

  // Set app version user property
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    AppAnalyticsService.instance.setAppVersion(packageInfo.version);
  } catch (_) {}

  // Log cold launch
  AppAnalyticsService.instance.logAppOpen();

  _log.i('Starting ProviderScope and WidgetApp');

  // Global error zone – catches any unhandled async errors.
  runZonedGuarded(
    () {
      runApp(
        ProviderScope(
          overrides: [
            if (sharedPrefs != null)
              sharedPreferencesProvider.overrideWithValue(sharedPrefs),
          ],
          child: const AshTrailApp(),
        ),
      );
    },
    (error, stackTrace) {
      ErrorReportingService.instance.report(
        AppError.from(error, stackTrace),
        stackTrace: stackTrace,
        context: 'runZonedGuarded',
      );
    },
  );
}

class AshTrailApp extends ConsumerWidget {
  const AshTrailApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Provider-driven theme — seed color and mode come from AppSettings
    final seedColor = ref.watch(activeSeedColorProvider);
    final themeMode = ref.watch(activeThemeModeProvider);
    final cardRadius = ref.watch(cardCornerRadiusProvider);
    final cardElev = ref.watch(cardElevationProvider);
    final reduceMotion = ref.watch(reduceMotionProvider);

    return MaterialApp(
      title: 'Ash Trail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: cardElev,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
          ),
        ),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
          surface: const Color(0xFF121212),
        ),
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: cardElev,
          color: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cardRadius),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.black,
        ),
      ),
      themeMode: themeMode,
      navigatorObservers: [
        if (AppAnalyticsService.instance.observer != null)
          AppAnalyticsService.instance.observer!,
      ],
      builder:
          reduceMotion
              ? (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(disableAnimations: true),
                child: child!,
              )
              : null,
      home: const AuthWrapper(),
    );
  }
}

/// Wrapper widget that handles authentication state
/// Shows home screen for authenticated users, welcome screen otherwise
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final authState = ref.watch(authStateProvider);
      final activeAccount = ref.watch(activeAccountProvider);

      return authState.when(
        data: (user) {
          // Check if we have an active authenticated account
          return activeAccount.when(
            data: (account) {
              if (account != null) {
                // Have an active account, show main navigation
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
              return Scaffold(
                body: ErrorDisplay.asyncError(
                  error,
                  stack,
                  reportContext: 'AuthWrapper.activeAccount',
                ),
              );
            },
          );
        },
        loading:
            () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
        error: (error, stack) {
          return Scaffold(
            body: ErrorDisplay.asyncError(
              error,
              stack,
              reportContext: 'AuthWrapper.authState',
            ),
          );
        },
      );
    } catch (e, stack) {
      _log.e('AuthWrapper build error', error: e, stackTrace: stack);
      return const WelcomeScreen();
    }
  }
}

/// Welcome screen for new users - offers sign in options
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
                        settings: const RouteSettings(name: 'LoginScreen'),
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  } catch (e) {
                    _log.e('Navigation error', error: e);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error navigating: $e'),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
