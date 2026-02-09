# Feature Catalog

This is a high-level inventory of every user-facing feature in Ash Trail, organized by domain. Each feature is described in more detail in its respective documentation file — see [Screen Reference](screens.md) for screen-related features, [Widget Catalog](widgets/README.md) for dashboard features, [Logging & Entry Fields](logging.md) for logging features, and [Data, Sync & Export](data-sync.md) for data management.

← [Back to Index](README.md)

---

| Category | Feature | Description |
|----------|---------|-------------|
| **Authentication** | Email sign-up/in | Create account with email + password (8+ chars with number) |
| | Google SSO | Sign in with Google account |
| | Apple SSO | Sign in with Apple ID |
| | Multi-account | Multiple accounts on one device, switch instantly |
| | Profile management | Edit display name, email, change password, delete account |
| **Logging** | Quick Log (press & hold) | Press-and-hold button to record duration in real time |
| | Detailed logging | Full form: event type, duration, notes, reasons, mood, physical, location |
| | Backdate entry | Log a past event with date/time picker and quick-offset buttons (-5m, -15m, -30m, -1h) |
| | Edit entry | Modify any field of an existing entry |
| | Delete & undo | Soft-delete with snackbar undo |
| | Auto-location capture | GPS coordinates captured automatically on log |
| **Dashboard** | Customizable widget grid | 27 widgets across 7 categories, drag-to-reorder, add/remove |
| | Edit mode | Toggle layout editing via pencil icon |
| | Per-account layout | Each account saves its own widget arrangement |
| | Pull-to-refresh | Refresh all widget data |
| **Analytics** | Summary cards | Total entries, synced, pending, total duration |
| | Bar chart | Daily activity (count or duration) over selected range |
| | Line chart | Daily activity trend line over selected range |
| | Pie chart | Event type breakdown |
| | Heatmaps | Hourly/weekday/weekend activity intensity grids |
| | Time range filter | 7, 14, 30 days, or custom date range |
| | Trend direction | Up/down/stable indicator comparing period halves |
| **History** | Full entry list | Scrollable list of all entries |
| | Search | Text search across entries |
| | Event type filter | Show only specific event types |
| | Date range filter | Filter to a date window |
| | Grouping | Group by: none, day, week, month, or event type |
| **Data Management** | Offline-first storage | All data saved locally (Hive) before sync |
| | Cloud sync | Automatic push/pull to Firebase/Firestore |
| | Export (CSV) | Copy flat-format data to clipboard |
| | Export (JSON) | Copy full-fidelity data to clipboard |
| | Import (CSV/JSON) | Import from clipboard (planned) |

> **Note:** Features marked "(planned)" are not yet implemented. The Import feature UI exists but is currently disabled with a "coming soon" indicator.

---

← [Back to Index](README.md)
