import 'dart:io';

// Simple coverage gate parsing lcov.info lines like: DA:<line>,<count>
// Accepts threshold percent argument.
void main(List<String> args) {
  final threshold = args.isNotEmpty ? double.parse(args.first) : 80.0;
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    stderr.writeln('coverage/lcov.info not found');
    exit(1);
  }
  final lines = file.readAsLinesSync();
  int hit = 0, found = 0;
  for (final l in lines) {
    if (l.startsWith('DA:')) {
      final parts = l.substring(3).split(',');
      final count = int.parse(parts[1]);
      found++;
      if (count > 0) hit++;
    }
  }
  final pct = found == 0 ? 0 : (hit / found * 100);
  stdout.writeln(
      'Line Coverage: ${pct.toStringAsFixed(2)}% (threshold $threshold%)');
  if (pct + 1e-9 < threshold) {
    stderr.writeln('Coverage below threshold.');
    exit(2);
  }
}
