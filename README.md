# Ash Trail

A **multi-account, offline-first logging and analytics app** built with Flutter. Track timestamped events quickly and reliably with comprehensive analytics and data transparency.

## Features

### 🚀 Fast Logging First

- **Multi-account support** - Switch between accounts seamlessly
- **One-tap log entries** - Quick logging with optional notes and amounts
- **Immediate feedback** - See your data reflected instantly in charts and tables

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

- **Firestore sync** - Cloud backup of all log entries
- **Custom auth service** - ~48-hour sessions for easy multi-device use
- **Conflict resolution** - Smart handling of sync conflicts

## Architecture

### Data Models

- **Account** - Multi-account support with session management
- **LogRecord** - Timestamped events with rich metadata (eventType, value, unit, tags)
- **Session** - Groups related log entries with aggregate metrics
- **LogTemplate** - Quick logging templates for common actions
- **Profile** - Optional profiles within accounts
- **DailyRollup** - Pre-aggregated daily statistics
- **SyncMetadata** - Track sync status per account

### Tech Stack

- **Flutter** - Cross-platform UI framework
- **Riverpod** - State management
- **Isar** (native) / **Hive** (web) - Local database (offline-first)
- **Firestore** - Cloud sync target
- **FL Chart** - Analytics visualization
- **Firebase Auth** - Authentication (with custom refresh token service)

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

### Adding Accounts

Currently accounts are added manually through the UI. Firebase Authentication integration coming soon for automatic account creation.

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

- [ ] Firebase Authentication integration
- [ ] Custom Flask refresh token service on Google Cloud Functions
- [ ] Complete Firestore sync implementation
- [ ] Chart implementations (cumulative, daily/weekly, rolling windows)
- [ ] Export functionality
- [ ] Session grouping and analysis
- [ ] Data backup and restore
- [ ] Multi-device sync conflict resolution UI
- [ ] Shared dashboards (future: organization-wide reporting)

## License

This project is private and not currently licensed for public use.

## Author
