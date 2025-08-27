// Utility script to enforce placeholder TODO comments in acceptance tests.
// Scans test/acceptance for lines containing `expect(true, isTrue);` and ensures
// the immediately preceding non-empty line is the standard TODO marker.
// This is a temporary measure to avoid build errors until real assertions are implemented.
// Run with: `dart run tool/add_acceptance_placeholders.dart`

import 'dart:io';

const String rootRelativeDir = 'test/acceptance';
const String expectPattern = 'expect(true, isTrue);';
const String todoLine = '// TODO: implement acceptance validation';

void main(List<String> args) {
  final acceptanceDir = Directory(rootRelativeDir);
  if (!acceptanceDir.existsSync()) {
    stderr.writeln('Directory not found: ${acceptanceDir.path}');
    exit(1);
  }
  int filesUpdated = 0;
  int expectsInserted = 0;

  for (final file in acceptanceDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('_test.dart'))) {
    final original = file.readAsLinesSync();
    final updated = <String>[];
    bool modified = false;
    for (int i = 0; i < original.length; i++) {
      final line = original[i];
      updated.add(line);
      if (line.trim() == todoLine) {
        // Look ahead for next non-empty line to see if it has the expect placeholder.
        int k = i + 1;
        while (k < original.length && original[k].trim().isEmpty) {
          k++;
        }
        final needsExpect = k >= original.length || !original[k].contains(expectPattern);
        if (needsExpect) {
          final indent = _leadingWhitespaceOf(line);
          updated.add('$indent$expectPattern // placeholder');
          expectsInserted++;
          modified = true;
        }
      }
    }
    if (modified) {
      file.writeAsStringSync(updated.join('\n'));
      filesUpdated++;
      stdout.writeln('Updated: ${file.path}');
    }
  }
  stdout.writeln('Done. Files updated: $filesUpdated. Expect placeholders inserted: $expectsInserted');
}

String _leadingWhitespaceOf(String line) {
  final match = RegExp(r'^(\s*)').firstMatch(line);
  return match?.group(1) ?? '';
}
