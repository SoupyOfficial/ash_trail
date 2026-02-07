import 'package:patrol/patrol.dart';
import 'package:ash_trail/main.dart' as app;

/// App lifecycle component — launch, reset.
class AppComponent {
  final PatrolIntegrationTester $;
  AppComponent(this.$);

  static bool _launched = false;

  // ── Actions ──

  /// Launch the app. Guards against double-launch within the same test process.
  Future<void> launch() async {
    if (!_launched) {
      app.main();
      _launched = true;
    }
  }

  /// Reset for future use — sign out + re-launch flow.
  Future<void> reset() async {
    // TODO: implement sign-out + re-launch when needed
  }
}
