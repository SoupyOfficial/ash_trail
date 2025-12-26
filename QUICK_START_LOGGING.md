# Quick Start Guide - New Logging Features

## ✅ What's Ready to Use Now

All the core logging infrastructure is fully implemented and ready! Here's what you can start using immediately:

---

## 📦 Available Services

### 1. LogRecordService (Extended)
**Location:** `lib/services/log_record_service.dart`

New methods available:
```dart
final service = LogRecordService();

// Quick log (one-tap logging)
await service.quickLog(
  accountId: 'your-account-id',
  eventType: EventType.inhale,
  value: 6,
  unit: Unit.seconds,
  tags: ['morning', 'routine'],
  location: 'home',
);

// Backdate a log entry
await service.backdateLog(
  accountId: 'your-account-id',
  eventAt: DateTime.now().subtract(Duration(minutes: 10)),
  eventType: EventType.inhale,
  value: 5,
  unit: Unit.seconds,
);

// Batch add multiple entries
await service.batchAdd(
  accountId: 'your-account-id',
  entries: [
    {
      'eventAt': DateTime.now().subtract(Duration(hours: 1)),
      'eventType': EventType.inhale,
      'value': 5.0,
      'unit': Unit.seconds,
      'tags': ['social'],
    },
    // ... more entries
  ],
);

// Find duplicates
final duplicates = await service.findPotentialDuplicates(record);

// Restore a deleted record
await service.restoreDeleted(record);

// Update context fields
await service.updateContext(
  record,
  location: 'home',
  mood: 7.5,
  craving: 3.0,
);
```

### 2. TemplateService
**Location:** `lib/services/template_service.dart`

```dart
final templateService = TemplateService();

// Create a template
final template = await templateService.createTemplate(
  accountId: 'your-account-id',
  name: 'Quick Hit',
  description: 'Standard single inhale',
  eventType: EventType.inhale,
  defaultValue: 6,
  unit: Unit.seconds,
  defaultTags: ['quick'],
  icon: '💨',
);

// Get all templates
final templates = await templateService.getTemplates(
  accountId: 'your-account-id',
  activeOnly: true,
);

// Get most used templates
final popular = await templateService.getMostUsedTemplates(
  accountId: 'your-account-id',
  limit: 5,
);

// Use a template
await templateService.recordUsage(template);
final record = await logService.createFromTemplate(
  accountId: 'your-account-id',
  eventType: template.eventType,
  defaultValue: template.defaultValue,
  defaultUnit: template.unit,
  defaultTags: template.defaultTags,
);

// Watch templates in real-time
templateService.watchTemplates(
  accountId: 'your-account-id',
).listen((templates) {
  // Update UI
});

// Create default templates for new users
await templateService.createDefaultTemplates(
  accountId: 'your-account-id',
);
```

### 3. SessionService
**Location:** `lib/services/session_service.dart`

```dart
final sessionService = SessionService();

// Start a session
final session = await sessionService.startSession(
  accountId: 'your-account-id',
  name: 'Morning Session',
  tags: ['morning', 'routine'],
  location: 'home',
);

// Log entries with session ID
await logService.quickLog(
  accountId: 'your-account-id',
  sessionId: session.sessionId,
  eventType: EventType.inhale,
  value: 6,
  unit: Unit.seconds,
);

// End session (auto-computes metrics)
final ended = await sessionService.endSession(session);
print('Duration: ${ended.durationSeconds}s');
print('Entries: ${ended.entryCount}');
print('Average value: ${ended.averageValue}');
print('Total value: ${ended.totalValue}');

// Get active session
final active = await sessionService.getActiveSession(
  accountId: 'your-account-id',
);

// Watch active session in real-time
sessionService.watchActiveSession(
  accountId: 'your-account-id',
).listen((session) {
  // Update UI with live session info
});

// Get session statistics
final stats = await sessionService.getSessionStatistics(
  accountId: 'your-account-id',
  startDate: DateTime.now().subtract(Duration(days: 30)),
);
```

### 4. ValidationService
**Location:** `lib/services/validation_service.dart`

```dart
// Clamp values to reasonable bounds
final clamped = ValidationService.clampValue(150, Unit.seconds);
// Returns 60 (max reasonable value for seconds)

// Detect clock skew
final confidence = ValidationService.detectClockSkew(eventAt);
// Returns TimeConfidence.high/.medium/.low

// Validate mood/craving
final validMood = ValidationService.validateMood(7.5); // 0-10
final validCraving = ValidationService.validateCraving(3.0); // 0-10

// Clean tags
final cleaned = ValidationService.cleanTags([
  ' Social ',
  'STRESS',
  'bored',
  '  ',
]);
// Returns ['social', 'stress', 'bored']

// Check for duplicates
final isDupe = ValidationService.isPotentialDuplicate(
  eventAt1: record1.eventAt,
  eventAt2: record2.eventAt,
  value1: record1.value,
  value2: record2.value,
  eventType1: record1.eventType.name,
  eventType2: record2.eventType.name,
);

// Detect outliers
final outlierIndices = ValidationService.detectOutliers([
  5.0, 6.0, 5.5, 6.2, 50.0, 5.8
]);
// Returns [4] (index of 50.0)

// Calculate data quality score
final score = ValidationService.calculateDataQualityScore(
  hasValidTimestamp: true,
  hasValidValue: true,
  timeConfidence: TimeConfidence.high,
  hasTags: true,
  hasNotes: true,
  hasLocation: false,
);
// Returns 94 (out of 100)
```

---

## 🗃️ New Data Models

### LogRecord (Extended)
**New fields available:**
- `location` - String (home/work/other)
- `mood` - Double (0-10 scale)
- `craving` - Double (0-10 scale)
- `timeConfidence` - TimeConfidence enum
- `editHistory` - String (JSON for revisions)
- `isTemplate` - Boolean
- `templateName` - String

### LogTemplate
**All fields available** - see model at `lib/models/log_template.dart`

### Session
**All fields available** - see model at `lib/models/session.dart`

### Profile (Extended)
**New default fields:**
- `defaultEventType`
- `defaultValue`
- `defaultUnit`
- `defaultTagsString`
- `defaultLocation`

---

## 🎯 Common Use Cases

### Use Case 1: Quick Logging with Profile Defaults

```dart
// Get active profile
final profile = await profileService.getActiveProfile(accountId);

// Use profile defaults for quick logging
await logService.quickLog(
  accountId: accountId,
  profileId: profile.profileId,
  eventType: profile.defaultEventType ?? EventType.inhale,
  value: profile.defaultValue ?? 6,
  unit: profile.defaultUnit ?? Unit.seconds,
  tags: profile.defaultTags,
  location: profile.defaultLocation,
);
```

### Use Case 2: Template-Based Logging

```dart
// Get templates
final templates = await templateService.getTemplates(
  accountId: accountId,
  activeOnly: true,
);

// User selects a template
final selectedTemplate = templates.first;

// Log using template
await templateService.recordUsage(selectedTemplate);
await logService.createFromTemplate(
  accountId: accountId,
  eventType: selectedTemplate.eventType,
  defaultValue: selectedTemplate.defaultValue,
  defaultUnit: selectedTemplate.unit,
  defaultTags: selectedTemplate.defaultTags,
  noteTemplate: selectedTemplate.noteTemplate,
  defaultLocation: selectedTemplate.defaultLocation,
);
```

### Use Case 3: Session Tracking

```dart
// Start session
final session = await sessionService.startSession(
  accountId: accountId,
  name: 'Evening Session',
  tags: ['evening', 'relax'],
);

// Log events during session
for (int i = 0; i < 5; i++) {
  await Future.delayed(Duration(minutes: 2));
  
  await logService.quickLog(
    accountId: accountId,
    sessionId: session.sessionId,
    eventType: EventType.inhale,
    value: 6,
    unit: Unit.seconds,
  );
}

// End session
final ended = await sessionService.endSession(session);

// Display results
print('Session completed:');
print('  Duration: ${ended.durationSeconds}s');
print('  Entries: ${ended.entryCount}');
print('  Average: ${ended.averageValue}s');
print('  Avg interval: ${ended.averageIntervalSeconds}s');
```

### Use Case 4: Batch Import with Validation

```dart
// Import historical data
final entries = [
  {
    'eventAt': DateTime.parse('2024-12-24 08:00:00'),
    'eventType': EventType.inhale,
    'value': 5.0,
    'unit': Unit.seconds,
    'tags': ['morning'],
  },
  {
    'eventAt': DateTime.parse('2024-12-24 12:00:00'),
    'eventType': EventType.inhale,
    'value': 6.0,
    'unit': Unit.seconds,
    'tags': ['afternoon'],
  },
  // ... more entries
];

// Batch add with auto-validation
final records = await logService.batchAdd(
  accountId: accountId,
  entries: entries,
);

print('Imported ${records.length} records');

// Check for duplicates
for (final record in records) {
  final dupes = await logService.findPotentialDuplicates(record);
  if (dupes.isNotEmpty) {
    print('Warning: ${dupes.length} potential duplicates found');
  }
}
```

### Use Case 5: Data Quality Monitoring

```dart
// Get recent records
final records = await logService.getLogRecords(
  accountId: accountId,
  startDate: DateTime.now().subtract(Duration(days: 7)),
);

// Calculate quality scores
int highQuality = 0;
int mediumQuality = 0;
int lowQuality = 0;

for (final record in records) {
  final score = ValidationService.calculateDataQualityScore(
    hasValidTimestamp: ValidationService.isReasonableTimestamp(record.eventAt),
    hasValidValue: ValidationService.isValidValue(record.value, record.unit),
    timeConfidence: record.timeConfidence,
    hasTags: record.tags.isNotEmpty,
    hasNotes: record.note != null && record.note!.isNotEmpty,
    hasLocation: record.location != null && record.location!.isNotEmpty,
  );
  
  if (score >= 80) highQuality++;
  else if (score >= 60) mediumQuality++;
  else lowQuality++;
}

print('Data quality report:');
print('  High (80-100): $highQuality');
print('  Medium (60-79): $mediumQuality');
print('  Low (<60): $lowQuality');
```

---

## 🚀 Next Steps to Build UI

Now that the core is complete, you can build UI widgets:

1. **QuickLogButton** - Floating action button with quick log
2. **BackdateDialog** - Time picker with quick options (10 min, 30 min, 1 hr ago)
3. **TemplateSelector** - Grid or list of templates
4. **SessionControl** - Start/end buttons with live timer
5. **TagSelector** - Chip input for tags
6. **LogEditDialog** - Full edit form with all fields
7. **SyncIndicator** - Per-record sync status badge
8. **BulkEntryScreen** - Spreadsheet-like bulk input
9. **ImportExport** - File picker and CSV/JSON handlers

---

## 📚 Full Documentation

See [LOGGING_FEATURES.md](./LOGGING_FEATURES.md) for complete documentation including:
- Architecture overview
- All model schemas
- All service methods
- Validation rules
- Data quality metrics
- Migration guide

---

## ✨ Key Benefits

✅ **Fast** - Optimized for quick logging with defaults
✅ **Smart** - Auto-validates, clamps values, detects outliers
✅ **Safe** - Soft deletes, duplicate detection, quality scoring
✅ **Flexible** - Templates, sessions, batch operations
✅ **Offline-first** - All operations work locally
✅ **Real-time** - Streams for live updates
✅ **Quality-focused** - Built-in data quality assurance

**Ready to build amazing logging experiences! 🎉**
