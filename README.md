# Ash Trail

A **multi-account, offline-first logging and analytics app** built with Flutter. Track timestamped events quickly and reliably with comprehensive analytics and data transparency.

## Features

### 🚀 Fast Logging First

- **Multi-account support** - Switch between accounts seamlessly without re-authentication
  - Seamless account switching using Firebase Custom Tokens
  - 48-hour token validity for instant switching
  - All accounts remain logged in simultaneously
  - Data isolation per account with automatic sync filtering
- **Home screen logging** - Press-and-hold duration recording directly from home
- **Vape tracking (MVP)** - Focus on vape session tracking with duration in seconds
- **Optional context** - Add mood, physical ratings, and reasons (8 categories)
- **Immediate feedback** - See your data reflected instantly in stats and recent entries
- **All-time & 7-day stats** - Quick overview of total usage and recent trends

### 📊 Analytics-Heavy

- **Multiple view types** - Charts and detailed data tables
- **Time-range filtering** - Cumulative usage, daily/weekly breakdowns
- **Rolling windows** - Track trends over time
- **Session tracking** - Group related entries together
- **Data transparency** - See exactly what data is used in charts

### 💾 Offline-First

- **Works without connectivity** - Full functionality offline
- **Local-first storage** - All data stored locally with Isar
- **Background sync** - Automatic cloud sync when available
- **Sync state tracking** - Always know what's synced and what's pending

### ☁️ Cloud Integration

- **Firestore sync** - Cloud backup of all log entries with account-scoped isolation
- **Firebase Custom Tokens** - Seamless multi-account switching via Cloud Function
  - Custom token generation service for instant account switching
  - No re-authentication required when switching between logged-in accounts
  - Automatic token refresh when expired
- **Conflict resolution** - Smart handling of sync conflicts with last-write-wins strategy

## Architecture

### Data Models

- **Account** - Multi-account support with session management
- **LogRecord** - Timestamped events with rich metadata (eventType, duration, unit, reasons, mood/physical ratings)
- **EventType** - Event types including vape (MVP default), inhale, sessions, notes, etc.
- **LogReason** - Context tracking (medical, recreational, social, stress, habit, sleep, pain, other)
- **Session** - Groups related log entries with aggregate metrics
- **Profile** - Optional profiles within accounts
- **DailyRollup** - Pre-aggregated daily statistics
- **SyncMetadata** - Track sync status per account

### Tech Stack

- **Flutter** - Cross-platform UI framework
- **Riverpod** - State management
- **Isar** (native) / **Hive** (web) - Local database (offline-first)
- **Firestore** - Cloud sync target with security rules enforcing account isolation
- **FL Chart** - Analytics visualization
- **Firebase Auth** - Authentication with Custom Token support
- **Google Cloud Functions** - Custom token generation service for multi-account switching

### Repository Pattern

The app uses a platform-agnostic repository pattern:

- **Native platforms** (iOS, Android, macOS, Linux, Windows) use **Isar** database
- **Web platform** uses **Hive** database
- Same API surface across all platforms via abstract repositories

### Project Structure

```text
lib/
  ├── models/          # Data models with Isar annotations
  ├── services/        # Business logic (Isar, logging, accounts)
  ├── providers/       # Riverpod state management
  ├── screens/         # UI screens (home, analytics, accounts)
  ├── widgets/         # Reusable UI components
  └── utils/           # Helper functions and utilities
```

## Getting Started

### Prerequisites

- Flutter SDK 3.7.0 or higher
- Dart 3.7.0 or higher

### Installation

1. Clone the repository:

```bash
git clone https://github.com/SoupyOfficial/ash_trail.git
cd ash_trail
```

1. Install dependencies:

```bash
flutter pub get
```

1. Generate Isar database code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

1. Run the app:

```bash
flutter run
```

## Development

### Code Generation

After modifying Isar models, regenerate the code:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Or watch for changes:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Multi-Account Support

The app supports multiple authenticated accounts with seamless switching:

- **Sign in** with Google, Apple, or Email to add accounts
- **Switch accounts** instantly without re-authentication using Firebase Custom Tokens
- **Data isolation** - each account's data is kept separate
- **Automatic sync** - only syncs records for the currently authenticated account

**Documentation**:
- [Multi-Account Architecture](docs/MULTI_ACCOUNT_ARCHITECTURE.md) - Complete architecture and design
- [Multi-Account Implementation Guide](docs/MULTI_ACCOUNT_IMPLEMENTATION.md) - Developer quick reference
- [Authentication & Accounts Design Doc](docs/plan/8.%20Authentication%20&%20Accounts.md) - Design specifications

## LogRecord System

### Core Data Model

`LogRecord` is the primary event logging model with rich metadata:

```dart
// Key fields
logId: String              // Unique identifier
accountId: String          // Associated account
profileId: String?         // Optional profile within account
timestamp: DateTime        // Event timestamp
eventType: EventType       // Type of event (enum)
value: double?             // Numeric value (duration, amount, etc.)
unit: Unit?                // Unit of measurement (enum)
tags: List<String>         // Categorization tags
note: String?              // Optional text note
sessionId: String?         // Group related entries
```

### Event Types

- `inhale` - Inhalation event
- `sessionStart` / `sessionEnd` - Session boundaries
- `note` - Text-only entry
- `purchase` - Purchase tracking
- `mood` / `energy` / `stress` - Wellness metrics
- `custom` - User-defined events

### Units of Measurement

- Time: `seconds`, `minutes`, `hours`
- Mass: `mg`, `grams`
- Volume: `ml`
- Discrete: `hits`, `count`
- `none` for qualitative entries

### Session Grouping

Sessions group related log entries with aggregate metrics:

- Automatic session boundaries
- Total duration calculations
- Event count tracking
- Average value computations

### Templates

Quick logging templates for common actions:

- Pre-configured eventType, unit, and tags
- One-tap logging with customizable defaults
- Template management in UI

### Platform-Specific Storage

- **Native** (iOS/Android/Desktop): Isar database
- **Web**: Hive database
- Same API surface via repository pattern
- Automatic platform detection at build time

## Roadmap

- [x] Firebase Authentication integration
- [x] Custom token service on Google Cloud Functions for multi-account switching
- [x] Complete Firestore sync implementation with account isolation
- [ ] Chart implementations (cumulative, daily/weekly, rolling windows)
- [ ] Export functionality
- [ ] Session grouping and analysis
- [ ] Data backup and restore
- [ ] Multi-device sync conflict resolution UI
- [ ] Shared dashboards (future: organization-wide reporting)

## License

This project is private and not currently licensed for public use.

## Author
