# main

> **Source:** `lib/main.dart`

## Purpose

App entry point for Ash Trail. Initializes all platform services (Firebase, Hive DB, crash reporting, location, SharedPreferences) with isolated error handling, then launches the Riverpod-wrapped MaterialApp. Contains the root widget (`AshTrailApp`), auth routing (`AuthWrapper`), and the onboarding welcome screen (`WelcomeScreen`).

## Dependencies

- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter_riverpod/flutter_riverpod.dart` — State management (ProviderScope, ConsumerWidget)
- `package:firebase_core/firebase_core.dart` — Firebase initialization
- `package:shared_preferences/shared_preferences.dart` — Key-value persistent storage
- `firebase_options.dart` — Auto-generated Firebase platform config
- `logging/app_logger.dart` — Centralized logging
- `services/hive_database_service.dart` — Hive local database
- `services/crash_reporting_service.dart` — Crash/error reporting
- `services/location_service.dart` — GPS/location permissions
- `screens/login_screen.dart` — Login UI
- `providers/auth_provider.dart` — Auth state provider
- `providers/account_provider.dart` — Active account provider
- `providers/home_widget_config_provider.dart` — Home widget config (SharedPreferences provider)
- `navigation/main_navigation.dart` — Bottom nav shell

## Pseudo-Code

### Enum: AppInitState

```
ENUM AppInitState
  uninitialized   — app has not started init
  initializing    — init in progress
  ready           — all services up
  failed          — at least one critical init failed
END ENUM
```

### Provider: appInitStateProvider

```
STATE_PROVIDER appInitStateProvider -> AppInitState
  INITIAL VALUE = AppInitState.uninitialized
END
```

### Function: main()

```
ASYNC FUNCTION main() -> void

  // 1. Configure logging verbosity
  READ environment variable VERBOSE_LOGGING (default: true)
  CALL AppLogger.setVerboseLogging(enableVerbose)
  LOG info "APP START at {timestamp}"
  LOG warning "Verbose logging: {enableVerbose}"

  // 2. Initialize Flutter binding
  CALL WidgetsFlutterBinding.ensureInitialized()

  // 3. Firebase
  TRY
    AWAIT Firebase.initializeApp(options: platform config)
    LOG info "Firebase initialized"
  CATCH error
    LOG error "Firebase initialization error"
  END TRY

  // 4. Crash Reporting
  TRY
    AWAIT CrashReportingService.initialize()
    LOG info "CrashReportingService initialized"
  CATCH error
    LOG error "Crash reporting initialization error"
  END TRY

  // 5. Hive Database
  TRY
    CREATE HiveDatabaseService instance
    AWAIT db.initialize()
    LOG info "Hive database initialized"
  CATCH error
    LOG error "Hive database initialization error"
  END TRY

  // 6. Location Permissions
  TRY
    CREATE LocationService instance
    hasPermission = AWAIT locationService.hasLocationPermission()
    IF hasPermission THEN
      LOG info "Location permission already granted"
    ELSE
      LOG warning "Location permission not granted - will prompt user"
    END IF
  CATCH error
    LOG error "Location service initialization error"
  END TRY

  // 7. SharedPreferences
  SET sharedPrefs = null
  TRY
    sharedPrefs = AWAIT SharedPreferences.getInstance()
    LOG info "SharedPreferences initialized"
  CATCH error
    LOG error "SharedPreferences initialization error"
  END TRY

  // 8. Launch app
  CALL runApp with ProviderScope(
    overrides: [
      IF sharedPrefs != null THEN
        OVERRIDE sharedPreferencesProvider with sharedPrefs value
    ],
    child: AshTrailApp
  )

END FUNCTION
```

### Class: AshTrailApp (ConsumerWidget)

```
CLASS AshTrailApp EXTENDS ConsumerWidget

  FUNCTION build(context, ref) -> Widget
    DEFINE royalBlue = Color(0xFF4169E1)

    RETURN MaterialApp(
      title: "Ash Trail"
      debugShowCheckedModeBanner: false

      theme (LIGHT):
        colorScheme from seed royalBlue, brightness light
        useMaterial3: true
        card elevation 2, border radius 12
        appBar centered, no elevation

      darkTheme (DARK):
        colorScheme from seed royalBlue, brightness dark, surface #121212
        scaffold background black
        useMaterial3: true
        card elevation 2, color #1E1E1E, border radius 12
        appBar centered, no elevation, background black

      themeMode: system (follow OS setting)
      home: AuthWrapper
    )
  END FUNCTION

END CLASS
```

### Class: AuthWrapper (ConsumerWidget)

```
CLASS AuthWrapper EXTENDS ConsumerWidget

  FUNCTION build(context, ref) -> Widget
    TRY
      WATCH authStateProvider -> authState
      WATCH activeAccountProvider -> activeAccount

      MATCH authState:
        CASE data(user):
          MATCH activeAccount:
            CASE data(account):
              IF account != null THEN
                RETURN MainNavigation   // authenticated with active account
              ELSE
                RETURN WelcomeScreen    // no active account
              END IF
            CASE loading:
              RETURN centered CircularProgressIndicator
            CASE error(e, stack):
              LOG error "Active account provider error"
              RETURN centered error text
          END MATCH

        CASE loading:
          RETURN centered CircularProgressIndicator

        CASE error(e, stack):
          LOG error "Auth state provider error"
          RETURN centered error text
      END MATCH

    CATCH error
      LOG error "AuthWrapper build error"
      RETURN WelcomeScreen   // graceful fallback
    END TRY
  END FUNCTION

END CLASS
```

### Class: WelcomeScreen (ConsumerWidget)

```
CLASS WelcomeScreen EXTENDS ConsumerWidget

  FUNCTION build(context, ref) -> Widget
    RETURN Scaffold(
      body: SafeArea with padding 24,
        Column (center, stretch):
          Spacer
          Fire icon (size 100, primary color)
          "Welcome to Ash Trail" — headline medium
          "Track your sessions with ease" — body large, variant color
          Spacer
          FilledButton "Sign In" with login icon (key: sign_in_button)
            ON PRESS:
              TRY
                NAVIGATE push to LoginScreen
              CATCH error
                LOG error "Navigation error"
                SHOW SnackBar with error message (3 seconds)
              END TRY
          SizedBox height 24
    )
  END FUNCTION

END CLASS
```
