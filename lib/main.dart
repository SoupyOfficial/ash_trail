import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/hive_database_service.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/account_provider.dart';

/// App initialization state per design doc 6.1.1
enum AppInitState { uninitialized, initializing, ready, failed }

/// Provider for app initialization state
final appInitStateProvider = StateProvider<AppInitState>((ref) {
  return AppInitState.uninitialized;
});

/// Main entry point for all platforms
/// Uses Hive database for offline-first storage on web, iOS, Android, and desktop
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive database
  final db = HiveDatabaseService();
  await db.initialize();

  runApp(const ProviderScope(child: AshTrailApp()));
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
      themeMode: ThemeMode.dark,
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
    final authState = ref.watch(authStateProvider);
    final activeAccount = ref.watch(activeAccountProvider);

    return authState.when(
      data: (user) {
        // Check if we have an active account (authenticated or anonymous)
        return activeAccount.when(
          data: (account) {
            if (account != null) {
              // Have an active account (authenticated or anonymous), show home
              return const HomeScreen();
            }
            // No active account - show welcome screen with options
            return const WelcomeScreen();
          },
          loading:
              () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
          error:
              (error, _) =>
                  Scaffold(body: Center(child: Text('Error: $error'))),
        );
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (error, stack) =>
              Scaffold(body: Center(child: Text('Error: $error'))),
    );
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
              ),
              const SizedBox(height: 12),
              // Continue anonymously button (per design doc 8.5)
              OutlinedButton.icon(
                onPressed: () async {
                  final switcher = ref.read(accountSwitcherProvider.notifier);
                  await switcher.createAnonymousAccount();
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
