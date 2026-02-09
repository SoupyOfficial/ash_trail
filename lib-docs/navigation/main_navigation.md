# main_navigation

> **Source:** `lib/navigation/main_navigation.dart`

## Purpose

Main navigation shell with a Material 3 bottom navigation bar. Uses `IndexedStack` to preserve screen state across tab switches. Provides three primary destinations: Home, Analytics, and History.

## Dependencies

- `package:flutter/material.dart` — Flutter UI framework (Scaffold, NavigationBar, IndexedStack)
- `package:flutter_riverpod/flutter_riverpod.dart` — ConsumerStatefulWidget for Riverpod integration
- `../screens/home_screen.dart` — HomeScreen widget
- `../screens/analytics_screen.dart` — AnalyticsScreen widget
- `../screens/history_screen.dart` — HistoryScreen widget

## Pseudo-Code

### Class: MainNavigation (ConsumerStatefulWidget)

```
CLASS MainNavigation EXTENDS ConsumerStatefulWidget
  CREATES STATE -> _MainNavigationState
END CLASS
```

### Class: _MainNavigationState

```
CLASS _MainNavigationState EXTENDS ConsumerState<MainNavigation>

  STATE:
    _currentIndex: int = 0

  CONSTANT:
    _screens: List<Widget> = [HomeScreen, AnalyticsScreen, HistoryScreen]

  FUNCTION build(context) -> Widget
    RETURN Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens         // all three screens stay mounted
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) =>
          SET STATE _currentIndex = index,

        destinations: [
          NavigationDestination(key: "nav_home",      icon: home_outlined,      selectedIcon: home,      label: "Home"),
          NavigationDestination(key: "nav_analytics", icon: analytics_outlined, selectedIcon: analytics, label: "Analytics"),
          NavigationDestination(key: "nav_history",   icon: history_outlined,   selectedIcon: history,   label: "History"),
        ]
      )
    )
  END FUNCTION

END CLASS
```
