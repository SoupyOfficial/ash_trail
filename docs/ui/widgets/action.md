# Action Widgets

Unlike all other widgets which are read-only displays, these 2 interactive widgets allow user interaction directly from the home screen. Quick Log lets you create new entries without leaving the dashboard. Recent Entries shows your latest logs with edit and delete capabilities.

← [Back to Widget Catalog](README.md) · [Back to Index](../README.md)

---

#### Quick Log

**ID:** `quickLog` · **Size:** large · **Category:** Action

**What it shows:** A large press-and-hold button in the center of the widget. Below the button: a mood slider (1–10), a physical slider (1–10), and selectable [reason](../glossary.md#log-reason) chips. A timer display shows the current duration as you hold.

**How it's calculated:** This widget creates data rather than displaying computed metrics. When you press and hold the button, a timer starts counting seconds. When you release, the elapsed time becomes the [duration](../glossary.md#duration) of a new [entry](../glossary.md#entry). The entry is saved with `eventType=vape`, `unit=seconds`, and the current timestamp. If you adjusted the mood/physical sliders or selected reason chips before pressing, those values are included on the entry. Location is auto-captured if permission is granted. A **1-second minimum threshold** applies — holds shorter than 1 second are ignored to prevent accidental logs from brief taps.

**How to interpret it:**
- This isn't a metric to interpret — it's your primary logging tool
- The timer shows real-time duration as you hold
- After logging, other widgets will automatically update to reflect the new entry

**Data source:** Creates new `LogRecord` entries. Does not read existing data.

**Usefulness:** The fastest way to log an entry. Press, hold for the duration of your session, release. No need to navigate to a separate screen or fill out a form. Perfect for in-the-moment logging.

---

#### Recent Entries

**ID:** `recentEntries` · **Size:** large · **Category:** Action

**What it shows:** A scrollable list of the last 5 entries (configurable via widget settings). Each row shows the [event type](../glossary.md#event-type) icon, formatted date/time, and duration.

**How it's calculated:** Queries all non-deleted entries for the active account. Sorts them newest-first. Takes the top N entries (default 5, configurable via the `count` setting in the widget's settings map). Formats each entry's timestamp and duration for display.

**How to interpret it:**
- Gives you a quick glance at what you've logged recently
- Useful for confirming a log was saved correctly
- Shows the full timeline context without switching to the History tab

**Data source:** Most recent non-deleted `LogRecord` entries — reads `eventAt`, `eventType`, `duration`, and `isDeleted`.

**Usefulness:** Quick reference without leaving the dashboard. Swipe left on any entry to [soft-delete](../glossary.md#soft-delete) it (with undo snackbar). Tap an entry to open the edit dialog to modify any field.

---

← [Back to Widget Catalog](README.md) · [Back to Index](../README.md)
