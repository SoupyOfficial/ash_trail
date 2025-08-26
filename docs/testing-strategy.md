# Testing Strategy

## Levels

* Unit: domain use cases
* Widget: record button, log list, charts
* Integration: account switcher, offline queue
* Contract: Firestore rules tests using emulator

## Tooling

* `flutter_test`, `integration_test`, `golden_toolkit`, `mocktail`, Firebase emulator
* Coverage gate ≥ 80% on CI

## Example Golden

```dart
testGoldens('RecordButton', (tester) async {
  await tester.pumpWidgetBuilder(RecordButton(onStart: (){}, onStop: (_){},));
  await screenMatchesGolden(tester, 'record_button');
});
```
