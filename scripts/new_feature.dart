#!/usr/bin/env dart
// Feature Scaffold Script
// Usage: dart scripts/new_feature.dart feature_name "User story" "Given ... When ... Then ..."
// Creates Clean Architecture folders & starter files.

import 'dart:io';

const structure = [
  'lib/features/{f}/domain/entities',
  'lib/features/{f}/domain/usecases',
  'lib/features/{f}/data/dtos',
  'lib/features/{f}/data/repositories',
  'lib/features/{f}/presentation/providers',
  'lib/features/{f}/presentation/widgets',
  'test/features/{f}/',
];

void main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Feature name required.');
    exit(64);
  }
  final feature =
      args.first.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]'), '_');
  final story = args.length > 1 ? args[1] : '';
  final gherkin = args.length > 2 ? args[2] : '';

  for (final path in structure) {
    final dir = Directory(path.replaceAll('{f}', feature));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  final readme = File('lib/features/$feature/README.md');
  if (!readme.existsSync()) {
    readme.writeAsStringSync(
        '''# Feature: $feature\n\nUser Story: $story\n\nAcceptance Criteria:\n$gherkin\n\nScaffold generated via scripts/new_feature.dart.\n''');
  }

  final providerFile = File(
      'lib/features/$feature/presentation/providers/${feature}_example_provider.dart');
  if (!providerFile.existsSync()) {
    providerFile.writeAsStringSync(
        '''import 'package:riverpod_annotation/riverpod_annotation.dart';\n\npart '${feature}_example_provider.g.dart';\n\n@riverpod\nString ${feature}Greeting(${feature}GreetingRef ref) {\n  return '$feature ready';\n}\n''');
  }

  stdout.writeln('Feature "$feature" scaffolded.');
}
