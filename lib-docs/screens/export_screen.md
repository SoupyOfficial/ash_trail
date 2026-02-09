# export_screen

> **Source:** `lib/screens/export_screen.dart`

## Purpose

Provides a UI for exporting log records as CSV or JSON (copied to clipboard) and placeholder import functionality for CSV/JSON files. Scoped to the active account's data only.

## Dependencies

- `package:flutter/material.dart` — Flutter UI framework
- `package:flutter/services.dart` — `Clipboard` for copying exported data
- `package:flutter_riverpod/flutter_riverpod.dart` — Riverpod state management
- `../providers/log_record_provider.dart` — `activeAccountLogRecordsProvider`
- `../services/export_service.dart` — `ExportService` (exportToCsv, exportToJson)

## Providers Defined

- `exportServiceProvider` — `Provider<ExportService>` that creates an `ExportService` instance

## Pseudo-Code

### Class: ExportScreen (ConsumerStatefulWidget)

Creates `_ExportScreenState`.

### Class: _ExportScreenState (ConsumerState)

#### State

```
_isExporting: bool = false
_isImporting: bool = false (final, never toggled in current implementation)
```

#### Method: build(context) -> Widget

```
RETURN Scaffold:
  appBar = AppBar(title: "Import / Export")
  body = SingleChildScrollView (padding 16):
    Column (crossAxis stretch):
      — Export Section —
      _buildSectionHeader("Export Data", upload icon)
      Text: "Export your log entries for backup..."

      _buildExportCard("Export as CSV",  "Flat format for spreadsheets", table_chart icon,
                       onTap: IF !_isExporting -> _exportCsv())
      _buildExportCard("Export as JSON", "Full-fidelity backup format", data_object icon,
                       onTap: IF !_isExporting -> _exportJson())

      — Import Section —
      _buildSectionHeader("Import Data", download icon)
      Text: "Import log entries from a backup file."

      _buildImportCard("Import from CSV",  "Import entries from a CSV file", table_chart icon,
                       onTap: IF !_isImporting -> _importCsv())
      _buildImportCard("Import from JSON", "Restore from a JSON backup", data_object icon,
                       onTap: IF !_isImporting -> _importJson())

      — Info Card —
      Card with info_outline icon:
        "Exported data only includes entries from your current account.
         Imports will be validated before adding."
```

#### Method: _buildSectionHeader(context, title, icon) -> Widget

```
Row: Icon(icon, primary) + Text(title, titleLarge)
```

#### Method: _buildExportCard / _buildImportCard

```
Card with ListTile:
  leading  = CircleAvatar (primaryContainer / secondaryContainer)
  title    = title
  subtitle = description
  trailing = IF exporting/importing -> CircularProgressIndicator(24x24)
             ELSE -> chevron_right icon
  onTap    = provided callback
```

#### Method: _exportCsv() -> Future<void>

```
SET _isExporting = true
TRY:
  records = AWAIT ref.read(activeAccountLogRecordsProvider.future)
  exportService = ref.read(exportServiceProvider)
  csvContent = AWAIT exportService.exportToCsv(records)
  AWAIT Clipboard.setData(csvContent)
  SHOW SnackBar "Exported {count} records to clipboard"
CATCH:
  SHOW SnackBar error (error background)
FINALLY:
  SET _isExporting = false
```

#### Method: _exportJson() -> Future<void>

```
SET _isExporting = true
TRY:
  records = AWAIT ref.read(activeAccountLogRecordsProvider.future)
  exportService = ref.read(exportServiceProvider)
  jsonContent = AWAIT exportService.exportToJson(records)
  AWAIT Clipboard.setData(jsonContent)
  SHOW SnackBar "Exported {count} records - copied to clipboard"
CATCH:
  SHOW SnackBar error
FINALLY:
  SET _isExporting = false
```

#### Method: _importCsv() / _importJson() -> Future<void>

```
// TODO: Not yet implemented — shows placeholder dialog
_showNotImplementedDialog("CSV Import" / "JSON Import")
```

#### Method: _showNotImplementedDialog(feature) -> void

```
SHOW AlertDialog:
  title = "{feature} Coming Soon"
  content = "This feature is planned for a future release. Export is available now."
  action: OK -> pop
```
