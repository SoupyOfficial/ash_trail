## Plan: Settings Screen with Preset Color Themes & Widget Settings

**TL;DR** — Add a global Settings screen accessible via a gear icon in the Home AppBar. It lets users pick from 6–8 Material 3 seed color presets, toggle light/dark/system theme mode, and configure dashboard display settings (density, card style, reduce-motion). All settings are persisted in SharedPreferences via a new Riverpod `StateNotifier`, and the existing hardcoded values in `AshTrailApp` and `DashboardGrid` become provider-driven. This follows the established pattern used by `HomeLayoutConfigNotifier`.

---

**Steps**

### A. Theme & Appearance

1. **Create settings models** — New file `lib/models/app_settings.dart`
   - `ThemePreset` class: `name` (String), `seedColor` (Color)
   - Static list of 8 presets: Royal Blue (default, `0xFF4169E1`), Teal (`0xFF009688`), Emerald (`0xFF10B981`), Amber (`0xFFF59E0B`), Rose (`0xFFE11D48`), Purple (`0xFF7C3AED`), Slate (`0xFF64748B`), Coral (`0xFFFF6B6B`)
   - `DashboardDensity` enum: `compact`, `comfortable` (default), `spacious` — maps to grid spacing multipliers and card padding
   - `CardStyle` class: `cornerRadius` (double, default `12`), `elevation` (double, default `2`)
   - `AppSettings` class holding all settings together:
     - `presetIndex` (int, default `0`)
     - `themeMode` (`ThemeMode`, default `.system`)
     - `dashboardDensity` (`DashboardDensity`, default `.comfortable`)
     - `cardCornerRadius` (double, default `12`)
     - `cardElevation` (double, default `2`)
     - `reduceMotion` (bool, default `false`)
   - `toJson()` / `fromJson()` for SharedPreferences serialization; `ThemeMode` stored as string (`'system'`/`'light'`/`'dark'`)

2. **Create app settings provider** — New file `lib/providers/app_settings_provider.dart`
   - `AppSettingsNotifier extends StateNotifier<AppSettings>` following the `HomeLayoutConfigNotifier` pattern
   - Read/write from `sharedPreferencesProvider` using key `'app_settings'` (global, not per-account)
   - Mutator methods: `setPreset(int)`, `setThemeMode(ThemeMode)`, `setDashboardDensity(DashboardDensity)`, `setCardCornerRadius(double)`, `setCardElevation(double)`, `setReduceMotion(bool)`, `resetToDefaults()`
   - `appSettingsProvider` as `StateNotifierProvider<AppSettingsNotifier, AppSettings>`
   - Derived convenience providers for consumption across the app:
     - `activeSeedColorProvider` → `Color`
     - `activeThemeModeProvider` → `ThemeMode`
     - `dashboardDensityProvider` → `DashboardDensity`
     - `cardCornerRadiusProvider` → `double`
     - `cardElevationProvider` → `double`
     - `reduceMotionProvider` → `bool`

3. **Wire theme into AshTrailApp** — Modify `lib/main.dart` (lines ~220–260)
   - Replace the hardcoded `const royalBlue = Color(0xFF4169E1)` with `final seedColor = ref.watch(activeSeedColorProvider)`
   - Replace `themeMode: ThemeMode.system` with `themeMode: ref.watch(activeThemeModeProvider)`
   - Read `ref.watch(cardCornerRadiusProvider)` and `ref.watch(cardElevationProvider)` to build `cardTheme` dynamically instead of using hardcoded `12` and `2`
   - Pass `seedColor` into both `theme:` and `darkTheme:` `ColorScheme.fromSeed()` calls
   - Keep other existing appBar/scaffold theme customizations

### B. Widget Display Settings — Functionality

4. **Wire dashboard density into grid** — Modify `lib/utils/responsive_layout.dart`
   - `DashboardGridConfig.forContext()` (or equivalent factory) currently returns hardcoded spacing/padding per breakpoint. Add an optional `DashboardDensity` parameter that applies a multiplier to spacing and padding:
     - `compact`: spacing × 0.5, padding × 0.75
     - `comfortable`: no change (current values)
     - `spacious`: spacing × 1.5, padding × 1.25
   - Alternatively, create a new `DashboardGridConfig.withDensity(DashboardDensity, Breakpoint)` method

5. **Wire density into DashboardGrid** — Modify `lib/widgets/home_widgets/dashboard_grid.dart`
   - Watch `dashboardDensityProvider` and pass the density to `DashboardGridConfig.forContext()`
   - The grid will rebuild when density changes, re-laying out all widgets with new spacing

6. **Wire card style into stat cards** — Modify `lib/widgets/home_widgets/stat_card_widget.dart` (and any other widget using hardcoded card radius/elevation)
   - Watch `cardCornerRadiusProvider` and `cardElevationProvider`
   - Replace hardcoded `BorderRadii.md` (12) and `ElevationLevel.sm` (1) with the provider values
   - This also affects the `CardTheme` in `main.dart` (step 3), so stat cards that rely on `CardTheme` will automatically update

7. **Wire reduce-motion into animations** — Modify animation-consuming widgets
   - Create a helper: `Duration resolveAnimationDuration(Duration original, bool reduceMotion)` → returns `Duration.zero` when `reduceMotion` is `true`
   - In `lib/widgets/home_widgets/dashboard_grid.dart`: wrap the hardcoded `Duration(milliseconds: 200)` for `AnimatedContainer` with the helper, watching `reduceMotionProvider`
   - In `lib/widgets/home_widgets/home_widget_wrapper.dart`: same for `AnimatedContainer` and `AnimatedPadding` (both 200ms)
   - In `lib/widgets/home_widgets/stat_card_widget.dart`: wrap `AnimationDuration.fast.duration` for `AnimatedSwitcher`
   - Also check `MediaQuery.of(context).disableAnimations` as a platform-level override (combine with OR: if either platform or user setting says reduce, reduce)
   - Optional: add this helper to `lib/utils/design_constants.dart` as a static method on `AnimationDuration`

### C. Settings Screen UI

8. **Create Settings screen** — New file `lib/screens/settings_screen.dart`
   - `ConsumerWidget` (stateless, all state in providers)
   - **AppBar**: title "Settings", with a "Reset to Defaults" action in overflow menu
   - Scrollable `ListView` body with the following sections, each with a section header:

   **Section 1 — Color Theme**
   - Horizontal `Wrap` of 8 circular color swatches (48dp diameter, min touch target)
   - Active preset: white check icon overlay + animated border ring in `colorScheme.primary`
   - Tapping a swatch calls `appSettingsNotifier.setPreset(index)` + haptic feedback
   - Below the swatches, show the preset name as a caption

   **Section 2 — Appearance**
   - `SegmentedButton<ThemeMode>` with three segments: System (icon: `brightness_auto`), Light (icon: `light_mode`), Dark (icon: `dark_mode`)

   **Section 3 — Dashboard Display**
   - **Density**: `SegmentedButton<DashboardDensity>` with three options: Compact, Comfortable, Spacious. Subtitle text explaining the effect ("Adjusts spacing between dashboard widgets")
   - **Card Corner Radius**: `Slider` from `4` to `24`, step `2`, showing current value label. Small preview card next to it showing the radius in real time
   - **Card Elevation**: `Slider` from `0` to `8`, step `1`, showing current value. Same preview card reacting to elevation changes

   **Section 4 — Accessibility**
   - **Reduce Motion**: `SwitchListTile` with icon `accessibility_new`. Subtitle: "Minimizes animations throughout the app"

   - Use design constants from `lib/utils/design_constants.dart` for spacing (`Spacing`, `Paddings`)
   - Use accessibility helpers from `lib/utils/a11y_utils.dart` (`SemanticIcon`, `MinimumTouchTarget`)
   - Add `Key` constants for all interactive elements (e.g., `Key('settings_theme_preset_0')`, `Key('settings_theme_mode_system')`, `Key('settings_density_compact')`, `Key('settings_card_radius_slider')`, `Key('settings_reduce_motion_switch')`)

9. **Add gear icon to Home AppBar** — Modify `lib/screens/home_screen.dart` (lines ~108–130)
   - Add a `SemanticIconButton` with `Icons.settings` before the existing account icon button in the `actions` list
   - `Navigator.push` to `SettingsScreen` with `RouteSettings(name: 'SettingsScreen')`
   - Import the new `settings_screen.dart`

### D. Tests

10. **Add tests** — New file `test/screens/settings_screen_test.dart`
    - Widget tests:
      - Color presets render (8 swatches visible)
      - Tapping a preset updates provider state and shows check mark
      - Theme mode segmented button toggles correctly
      - Dashboard density segmented button toggles correctly
      - Card radius slider changes value and preview updates
      - Card elevation slider changes value
      - Reduce motion switch toggles
      - Reset to defaults restores all values
      - Default state: Royal Blue, System, Comfortable, radius 12, elevation 2, motion on
    - Provider unit tests for `AppSettingsNotifier`:
      - Persistence round-trip (save → reload → values match)
      - Default values when no stored data
      - Each mutator method updates the correct field
      - `resetToDefaults()` clears all customizations
      - Invalid JSON in SharedPreferences falls back to defaults gracefully
    - Follow existing test patterns in the `test/` directory

---

**Verification**
- Run `flutter test test/screens/settings_screen_test.dart` to validate widget + provider tests
- Run `flutter test` to ensure no regressions
- Manual check:
  - Launch app → tap gear icon → opens Settings
  - Select different color presets → theme updates in real time across all screens
  - Toggle appearance mode (System / Light / Dark) → theme switches immediately
  - Change density → return to Home → observe grid spacing change
  - Adjust card corner radius slider → preview card and home dashboard cards update live
  - Adjust card elevation slider → same live update
  - Toggle reduce motion → animations become instant on Home widgets
  - Kill and relaunch → all settings persist
  - Reset to defaults → everything returns to original values
- Verify accessibility: minimum 48dp touch targets on all color swatches and controls, semantic labels

**Decisions**
- **Global scope** over per-account: all settings stored under a single SharedPreferences key `'app_settings'`, not keyed by `accountId`
- **Gear icon in Home AppBar** over Accounts screen: placed before the existing account icon for consistent discoverability
- **6–8 curated presets** over custom picker: simpler UX, can always add a custom picker later
- **`StateNotifier` + SharedPreferences** over Hive: matches the established `HomeLayoutConfigNotifier` pattern and keeps preferences lightweight
- **Single `AppSettings` model** over separate theme/widget providers: one SharedPreferences key, one notifier, simpler persistence logic. Derived convenience providers keep consumers focused
- **Density enum** over raw spacing values: three clear presets are easier to understand than a spacing slider; maps to multipliers applied to existing responsive breakpoint values
- **Card radius & elevation sliders** with bounded ranges: radius 4–24 (step 2) and elevation 0–8 (step 1) prevent unusable extremes while giving meaningful customization
- **Reduce motion** as a boolean toggle: simple and effective — when on, all `AnimatedContainer`/`AnimatedSwitcher`/`AnimatedPadding` durations become `Duration.zero`. Respects platform `MediaQuery.disableAnimations` as an override
