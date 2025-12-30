import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/hive_database_service.dart';
import 'screens/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'providers/auth_provider.dart';

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
        cardTheme: CardTheme(
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
          background: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
        cardTheme: CardTheme(
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

/// Wrapper widget that shows login or home based on auth state
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        // User is authenticated, show home screen
        if (user != null) {
          return const HomeScreen();
        }
        // User is not authenticated, show login screen
        return const LoginScreen();
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
