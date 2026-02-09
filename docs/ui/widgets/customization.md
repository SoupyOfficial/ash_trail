# Widget Customization

This file explains how to manage your home screen widget layout — entering edit mode, reordering widgets, adding new ones, removing existing ones, and understanding the default layout. Each account has its own independent widget arrangement.

← [Back to Widget Catalog](README.md) · [Back to Index](../README.md)

---

## How to Enter/Exit Edit Mode

Tap the **pencil (✏️) icon** in the HomeScreen app bar. When edit mode is active, each widget shows a drag handle and a remove (✕) button. Tap the pencil again to exit and save your changes. All changes take effect immediately and are auto-saved.

## Drag-and-Drop Reordering

Long-press a widget's drag handle to pick it up. Drag it to the desired position in the grid. Release to drop it in place. The new order is saved immediately. [Compact](../glossary.md#widget-size) widgets (half-width) are automatically paired side-by-side — dragging a compact widget between two other compacts will rearrange the pairing.

## Remove a Widget

Tap the **✕ button** on a widget while in edit mode. A confirmation dialog appears ("Remove {widget name}?"). Confirm to remove it. An undo snackbar appears for several seconds — tapping "Undo" restores the widget to its previous position. The widget is merely hidden from your layout, not deleted from the catalog — you can always add it back.

## Add a Widget

While in edit mode, tap the **"+" button** at the bottom of the widget grid. A bottom sheet opens showing all available widgets organized by category (Time, Duration, Count, Comparison, Pattern, Ratings & Reasons, Actions). Each widget shows its name, icon, and one-line description. Tap a widget to add it to the end of your grid. Widgets already on the grid are shown as disabled/grayed out — you cannot add duplicates (unless the widget has `allowMultiple` enabled, which currently none do).

## Layout Rules

| Widget Size | Layout Behavior |
|-------------|-----------------|
| **Compact** | Half the screen width. Automatically paired side-by-side with another compact widget (two per row). If there's an odd number of compact widgets in a row, the last one takes up one half. |
| **Standard** | Full screen width, normal height. Always occupies an entire row by itself. |
| **Large** | Full screen width, extra vertical height. Used for heatmaps, Quick Log, and Recent Entries. Always occupies an entire row. |

## Default Widgets for New Accounts

When a new account is created or if no saved layout exists, these 6 widgets are shown in order:

| # | Widget | Category | Size |
|---|--------|----------|------|
| 1 | [Time Since Last](time-based.md#time-since-last) | Time | standard |
| 2 | [Quick Log](action.md#quick-log) | Action | large |
| 3 | [Hits Today](count-based.md#hits-today) | Count | compact |
| 4 | [Total Today](duration-based.md#total-today) | Duration | compact |
| 5 | [Mood/Physical Avg](secondary-data.md#moodphysical-avg) | Secondary | standard |
| 6 | [Recent Entries](action.md#recent-entries) | Action | large |

This default set provides a balanced starting point: a live timer, the primary logging tool, two key metrics (count and duration), mood tracking, and a recent entries list.

## Layout Persistence

Widget layout (which widgets are shown and in what order) is saved to SharedPreferences with a key scoped to the account's userId. Switching accounts loads that account's saved layout. Each account has its own completely independent widget arrangement — changes to one account's layout do not affect any other account.

---

← [Back to Widget Catalog](README.md) · [Back to Index](../README.md)
