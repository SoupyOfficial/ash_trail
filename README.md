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
- **LogEntry** - Timestamped events with sync state tracking
- **SyncMetadata** - Track sync status per account

### Tech Stack
- **Flutter** - Cross-platform UI framework
- **Riverpod** - State management
- **Isar** - Local database (offline-first)
- **Firestore** - Cloud sync target
- **FL Chart** - Analytics visualization
- **Firebase Auth** - Authentication (with custom refresh token service)

### Project Structure
```
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

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Isar database code:
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Run the app:
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

**Jacob** - [SoupyOfficial](https://github.com/SoupyOfficial)
