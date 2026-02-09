# Ash Trail — UI Documentation

Ash Trail is a comprehensive vaping and smoking habit tracker built with Flutter. This documentation suite covers every screen, widget, data source, and calculation in the app from a UI perspective.

**v1.0.1 · Last updated: February 9, 2026**

---

## Table of Contents

| Document | Description |
|----------|-------------|
| [Key Concepts & Glossary](glossary.md) | Domain-specific terms and definitions referenced throughout all docs |
| [Architecture & Data Flow](architecture.md) | Four Mermaid diagrams showing the app's layered architecture, data flow, provider graph, and data model |
| [Feature Catalog](features.md) | Exhaustive table of every user-facing feature organized by domain |
| [Screen Reference & Navigation](screens.md) | All 10 screens, navigation flow diagrams, and detailed screen descriptions |
| [Widget Catalog](widgets/README.md) | Introduction to the 27-widget home dashboard system with rendering pipeline and summary table |
| ↳ [Time-Based Widgets](widgets/time-based.md) | 7 widgets analyzing when you use and gaps between entries |
| ↳ [Duration-Based Widgets](widgets/duration-based.md) | 6 widgets analyzing how long each session lasts |
| ↳ [Count-Based Widgets](widgets/count-based.md) | 4 widgets tracking how many entries you log |
| ↳ [Comparison Widgets](widgets/comparison.md) | 3 widgets comparing today's usage against baselines |
| ↳ [Pattern Widgets](widgets/pattern.md) | 3 visual widgets revealing recurring habits across days and hours |
| ↳ [Secondary Data Widgets](widgets/secondary-data.md) | 2 widgets surfacing mood, physical, and contextual information |
| ↳ [Action Widgets](widgets/action.md) | 2 interactive widgets for logging and reviewing entries from the dashboard |
| ↳ [Widget Customization](widgets/customization.md) | How to reorder, add, remove widgets and manage per-account layouts |
| [Logging & Entry Fields](logging.md) | Complete field reference for log entries, logging modes, and entry lifecycle |
| [Understanding Trend Indicators](trends.md) | Color convention explainer for the trend arrows on widgets |
| [Data, Sync & Export](data-sync.md) | Offline-first storage, cloud sync state machine, and export formats |
| [Developer Quick-Start](developer-guide.md) | "Where Is X?" file map, folder structure, and common commands cheat sheet |
| [Quick-Reference Card](quick-reference.md) | Appendix with scannable summary tables of all widgets, screens, and fields |

---

## App Overview

Ash Trail is a habit-tracking app designed to help users monitor their vaping and smoking patterns. It builds awareness of usage frequency, duration, and timing to support harm reduction. The target audience is anyone who wants to understand and potentially reduce their consumption, whether for health, financial, or personal reasons.

The app is built with Flutter and runs on iOS (primary platform), Android, web, macOS, Linux, and Windows. It uses an offline-first architecture — all data is saved locally to Hive (a lightweight NoSQL store) the instant you log an entry. Cloud sync to Firebase/Firestore happens automatically in the background when connectivity is available, so the app works fully offline with no data loss.

The core concept that touches every metric in the app is the **6 AM [day boundary](glossary.md#day-boundary)**: a "day" runs from 6:00 AM to 5:59 AM the next calendar day. This means a late-night entry at 2 AM on Tuesday is counted as part of "Monday" in all widgets, charts, and calculations. This design choice groups late-night activity with the day it naturally belongs to. The app uses Material 3 with a royal blue (`#4169E1`) + black color scheme and defaults to matching the system theme (light or dark).

---

## Documentation Decisions

These explain *why* the documentation is structured this way:

- **Multi-file over single file** — Each doc covers a single concern, keeping files short and navigable. A developer looking for widget details goes straight to the relevant category file instead of scrolling through a monolith.
- **Widgets get their own subdirectory** — The widget catalog is the largest section (27 detailed entries). Splitting by category keeps each file focused.
- **User-facing language over code references** — Calculations described in plain English. Exception: the Developer Quick-Start uses exact file paths and identifiers.
- **Trend color convention explicitly documented** — The inverted color convention (green ↓ = less = good) is non-obvious and deserves its own section.
- **Structured widget entries over flat tables** — Each widget gets 6 consistent fields for scanability and thoroughness.
- **Glossary up front** — Avoids repeating definitions; ensures consistent terminology across all files.
- **Quick-reference appendix** — Provides a scannable summary for fast lookup.
- **Mermaid diagrams over images** — Text-based, version-controlled, render on GitHub and in VS Code, never go stale.
- **"Where Is X?" section** — The most critical section for a solo dev returning after months away.
