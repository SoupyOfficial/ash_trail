import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/database_service_web.dart';
import 'screens/home_screen.dart';

/// Web-specific entry point
/// Uses Hive (IndexedDB) for web compatibility instead of Isar
///
/// The UI is identical to native, with QuickLogWidget supporting:
/// - Quick tap logging
/// - Hold-to-record duration capture
/// - Undo functionality
/// - Offline-first with web-compatible persistence
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database for web
  final db = IsarDatabaseService();
  await db.initialize();

  runApp(const ProviderScope(child: AshTrailWebApp()));
}

class AshTrailWebApp extends StatelessWidget {
  const AshTrailWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ash Trail',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
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
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
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
      themeMode: ThemeMode.system,
      // Use the same HomeScreen as native - UI is identical on web
      // QuickLogWidget works identically with hold-to-record on web
      home: const HomeScreen(),
    );
  }
}
