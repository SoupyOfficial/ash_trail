# Phase 1: Critical Integration Plan

## Overview
Integrate existing architectural components to create a functional home screen with working record button that saves smoke logs to local storage.

## Goal
Enable users to capture smoke hits using the hold-to-record functionality with proper data persistence.

## Assumptions
- All domain models and use cases are correctly implemented
- RecordButtonController state management is working
- AccessibleRecordButton widget has proper accessibility support
- Local storage mechanism (SharedPreferences/Isar) is available

## Acceptance Criteria
- [ ] Functional home screen displays record button prominently
- [ ] Hold-to-record creates and saves SmokeLog entries locally
- [ ] Proper haptic feedback during recording interactions
- [ ] Accessibility labels work correctly with screen readers
- [ ] Error states display meaningful messages to users
- [ ] Recording duration is accurately tracked and displayed
- [ ] Smoke logs persist across app restarts
- [ ] Undo functionality works for last recorded entry

## Files to Create/Modify

### 1. Create Functional Home Screen
**File**: `lib/features/home/presentation/screens/home_screen.dart`
- Replace placeholder HomeScreen in app_router.dart
- Integrate AccessibleRecordButton with proper sizing and positioning
- Add welcome message and basic usage instructions
- Handle error states from record operations

### 2. Create Home Feature Provider
**File**: `lib/features/home/presentation/providers/home_providers.dart`
- Wire together record button state and smoke log creation
- Handle active account selection for log association
- Manage loading states during record operations

### 3. Update App Router
**File**: `lib/core/routing/app_router.dart`
- Import and use new home screen instead of placeholder
- Ensure proper navigation state management

### 4. Implement Concrete Data Source
**File**: `lib/features/capture_hit/data/repositories/smoke_log_repository_impl.dart`
- Create working implementation with local storage (SharedPreferences initially)
- Implement proper error handling and offline queue
- Add data validation and sanitization

### 5. Update App Shell FAB
**File**: `lib/features/app_shell/presentation/app_shell.dart`
- Replace placeholder FAB with actual record functionality
- Navigate to home screen when tapped
- Consider removing FAB if home screen has primary record button

## Implementation Steps

### Step 1: Create Home Screen Structure
1. Create feature directory: `lib/features/home/`
2. Implement home screen with record button integration
3. Add proper responsive layout and accessibility
4. Include loading states and error handling

### Step 2: Wire Data Persistence
1. Implement concrete SmokeLogRepository with local storage
2. Verify CreateSmokeLogUseCase integration
3. Test data persistence across app restarts
4. Add proper error handling for storage failures

### Step 3: Update Navigation
1. Replace placeholder HomeScreen in app_router.dart
2. Update import statements and route configuration
3. Test deep linking to home screen
4. Verify navigation state persistence

### Step 4: Integration Testing
1. Test full record button flow: press → hold → release → save
2. Verify accessibility with VoiceOver/TalkBack
3. Test error scenarios (storage failures, validation errors)
4. Confirm haptic feedback works correctly

### Step 5: Polish and Validation
1. Add loading skeletons for better UX
2. Implement undo functionality for last recording
3. Add telemetry events for user interactions
4. Test on multiple screen sizes

## Code Implementation

### Home Screen Implementation
```dart
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordState = ref.watch(recordButtonProvider);
    final activeAccount = ref.watch(activeAccountProvider);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Welcome content
              _buildWelcomeHeader(context),
              const SizedBox(height: 48),
              
              // Main record button
              Expanded(
                child: Center(
                  child: _buildRecordButton(context, ref, recordState),
                ),
              ),
              
              // Status and actions
              _buildStatusSection(context, ref, recordState),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Data Repository Implementation
```dart
class SmokeLogRepositoryImpl implements SmokeLogRepository {
  final SharedPreferences _prefs;
  
  @override
  Future<Either<AppFailure, SmokeLog>> createLog(SmokeLog log) async {
    try {
      final logs = await _getAllLogs();
      logs.add(log);
      
      final encoded = logs.map((l) => l.toJson()).toList();
      await _prefs.setString(_keyLogs, json.encode(encoded));
      
      return Right(log);
    } catch (e) {
      return Left(DataFailure.saveError(e.toString()));
    }
  }
}
```

## Manual QA Steps
1. **Happy Path**: Launch app → see home screen → hold record button → release after 2s → verify smoke log saved
2. **Error Path**: Simulate storage failure → verify error message shows → retry works
3. **Accessibility**: Enable VoiceOver → navigate to record button → verify semantic labels
4. **Offline**: Disable network → record entry → restart app → verify data persisted
5. **Account Switching**: Switch accounts → record entry → verify associated with correct account

## Performance Expectations
- Record button response: ≤50ms to haptic feedback
- Log save operation: ≤120ms local storage
- Home screen render: ≤200ms first paint
- No dropped frames during hold-to-record animation

## Accessibility Checklist
- [ ] Record button has minimum 48dp tap target
- [ ] Semantic labels describe current state
- [ ] VoiceOver announces recording progress
- [ ] High contrast mode supported
- [ ] Text scaling to 200% works without overflow

## Commit Message
```
feat(home): implement functional home screen with record button integration

- Create dedicated home screen with integrated AccessibleRecordButton
- Implement concrete SmokeLogRepository with SharedPreferences storage
- Wire RecordButtonController with CreateSmokeLogUseCase for data persistence
- Add proper error handling and loading states
- Replace placeholder home screen in app router
- Update app shell FAB to use actual record functionality

Closes logging.capture_hit feature gap - users can now capture and save smoke logs locally.

BREAKING CHANGE: HomeScreen moved from core/routing to features/home module
```

## Success Metrics
- Users can successfully record and save smoke logs
- Zero crashes during record button interactions  
- Accessibility compliance score >90%
- Record operation completes within performance budgets
- Data persists correctly across app restarts