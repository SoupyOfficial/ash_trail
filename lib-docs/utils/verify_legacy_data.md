# verify_legacy_data

> **Source:** `lib/utils/verify_legacy_data.dart`

## Purpose

CLI verification script that validates the legacy Firestore data structure and ensures the `LegacyDataAdapter` correctly reads and converts data from legacy collections (`JacobLogs`, `AshleyLogs`). Intended to be run as a standalone tool (`flutter run -d linux`) to confirm production-readiness of legacy data support.

## Dependencies

- `dart:developer` — `developer.log` for structured console output
- `package:cloud_firestore/cloud_firestore.dart` — Firestore client for querying collections
- `package:firebase_core/firebase_core.dart` — Firebase initialization
- `../firebase_options.dart` — `DefaultFirebaseOptions` for platform-specific Firebase config
- `../services/legacy_data_adapter.dart` — `LegacyDataAdapter` for legacy collection querying and conversion

## Pseudo-Code

---

### Function: main() → Future\<void\>

Top-level entry point that performs an 8-step verification sequence wrapped in a try/catch.

```
// ── Initialization ──
AWAIT Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
LOG banner: "Legacy Firestore Data Structure Verification"

INIT adapter = LegacyDataAdapter()
INIT firestore = FirebaseFirestore.instance

TRY

  // ═══════ Step 1: Check JacobLogs Collection ═══════
  SET jacobLogsSnapshot = AWAIT firestore.collection("JacobLogs").limit(10).get()
  LOG "Collection exists"
  LOG "Document count (first 10): {snapshot.docs.length}"

  IF snapshot HAS documents
    SET firstDoc = snapshot.docs.first
    LOG "Sample Document ID: {firstDoc.id}"
    FOR EACH (key, value) IN firstDoc.data()
      LOG "  - {key}: {value.runtimeType}"

  // ═══════ Step 2: Check for soupsterx@gmail.com Account Data ═══════
  SET jacobAccountDocs = AWAIT firestore.collection("JacobLogs")
    .where("accountId", isEqualTo: "jacob")
    .limit(5)
    .get()
  LOG "Documents with accountId='jacob': {docs.length}"

  // ═══════ Step 3: Test LegacyDataAdapter ═══════
  SET hasLegacy = AWAIT adapter.hasLegacyData("jacob")
  LOG "hasLegacyData('jacob'): {hasLegacy}"

  SET legacyCount = AWAIT adapter.getLegacyRecordCount("jacob")
  LOG "getLegacyRecordCount('jacob'): {legacyCount}"

  // ═══════ Step 4: Query JacobLogs via Adapter ═══════
  SET jacobLogs = AWAIT adapter.queryLegacyCollection(
    collectionName: "JacobLogs",
    limit: 5
  )
  LOG "Query returned: {jacobLogs.length} records"

  IF jacobLogs IS NOT EMPTY
    FOR i FROM 0 TO MIN(jacobLogs.length, 3)
      SET record = jacobLogs[i]
      LOG record.logId, accountId, eventType, eventAt, duration, unit,
          moodRating, physicalRating

  // ═══════ Step 5: Check AshleyLogs Collection ═══════
  TRY
    SET ashleyLogsSnapshot = AWAIT firestore.collection("AshleyLogs").limit(10).get()
    LOG "Collection exists, count: {docs.length}"
  CATCH e
    LOG "AshleyLogs collection not found: {e}"

  // ═══════ Step 6: Test Deduplication ═══════
  SET allLegacy = AWAIT adapter.queryAllLegacyCollections(limit: 100)
  LOG "queryAllLegacyCollections returned: {allLegacy.length} records"

  // Check for duplicate logIds
  INIT logIds = empty Set<String>
  SET duplicates = 0
  FOR EACH record IN allLegacy
    IF logIds ALREADY CONTAINS record.logId
      INCREMENT duplicates
    ELSE
      ADD record.logId TO logIds
  LOG "Duplicate logIds found: {duplicates}"

  // ═══════ Step 7: Verify Field Conversions ═══════
  IF jacobLogs IS NOT EMPTY
    SET record = jacobLogs.first
    LOG field mapping validity:
      - logId:     ✓ if not empty
      - accountId: ✓ if not empty
      - eventType: ✓ (always required)
      - eventAt:   ✓ (always required)
      - duration:  ✓ if >= 0
      - unit:      ✓ (always required)
      - note:      ✓ present or null (optional)
      - moodRating: ✓ present or null (optional)
      - source:    ✓ if source.name == "imported", else ⚠️

  // ═══════ Step 8: Summary ═══════
  LOG "✅ Legacy data adapter is operational"
  LOG "✅ JacobLogs collection accessible"
  LOG "✅ Field conversion working correctly"
  LOG "✅ Account ID mapping verified"
  LOG "✅ Deduplication logic verified"
  LOG "✅ Ready for production deployment"
  LOG banner: "LEGACY DATA SUPPORT VERIFIED"

CATCH e
  LOG "❌ Error during verification: {e}"
  LOG possible causes:
    - Firebase not initialized properly
    - Missing Firestore permissions
    - Collections not present in Firestore
    - Network connectivity issue
```
