#!/usr/bin/env python3
"""
Simple feature scaffold generator for AshTrail.
Creates basic feature structure with corrected template variables.
"""

import argparse
import sys
from pathlib import Path
import re

def snake_case(name):
    """Convert to snake_case."""
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()

def pascal_case(name):
    """Convert to PascalCase."""
    return ''.join(word.capitalize() for word in name.replace('_', ' ').split())

def camel_case(name):
    """Convert to camelCase."""
    pascal = pascal_case(name)
    return pascal[0].lower() + pascal[1:] if pascal else name

def create_feature_scaffold(feature_name, epic_name=None):
    """Create a basic feature scaffold."""
    feature_snake = snake_case(feature_name)
    feature_pascal = pascal_case(feature_name)
    feature_camel = camel_case(feature_name)
    
    print(f"🚀 Creating feature scaffold for: {feature_pascal}")
    print(f"   Snake case: {feature_snake}")
    print(f"   Camel case: {feature_camel}")
    
    # Create directory structure
    base_path = Path(f"lib/features/{feature_snake}")
    directories = [
        base_path / "domain" / "entities",
        base_path / "domain" / "repositories", 
        base_path / "data" / "repositories",
        base_path / "presentation" / "providers",
        base_path / "presentation" / "screens",
    ]
    
    for dir_path in directories:
        dir_path.mkdir(parents=True, exist_ok=True)
        print(f"📁 Created {dir_path}")
    
    # Create basic repository interface
    repo_content = f'''// Repository interface for {feature_pascal}

import 'package:fpdart/fpdart.dart';
import '../../../core/failures/app_failure.dart';

abstract class {feature_pascal}Repository {{
  Future<Either<AppFailure, List<Map<String, dynamic>>>> getByAccount(String accountId);
  Future<Either<AppFailure, Map<String, dynamic>>> create(Map<String, dynamic> data);
  Future<Either<AppFailure, void>> delete(String id);
}}
'''
    
    repo_file = base_path / "domain" / "repositories" / f"{feature_snake}_repository.dart"
    repo_file.write_text(repo_content)
    print(f"📄 Created {repo_file}")
    
    # Create basic repository implementation
    repo_impl_content = f'''// Repository implementation for {feature_pascal}

import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/failures/app_failure.dart';
import '../../domain/repositories/{feature_snake}_repository.dart';

part '{feature_snake}_repository_impl.g.dart';

@riverpod
{feature_pascal}Repository {feature_camel}Repository({feature_pascal}RepositoryRef ref) {{
  return {feature_pascal}RepositoryImpl();
}}

class {feature_pascal}RepositoryImpl implements {feature_pascal}Repository {{
  @override
  Future<Either<AppFailure, List<Map<String, dynamic>>>> getByAccount(String accountId) async {{
    // TODO: Implement data access
    return const Right([]);
  }}
  
  @override
  Future<Either<AppFailure, Map<String, dynamic>>> create(Map<String, dynamic> data) async {{
    // TODO: Implement create
    return Right(data);
  }}
  
  @override
  Future<Either<AppFailure, void>> delete(String id) async {{
    // TODO: Implement delete
    return const Right(null);
  }}
}}
'''
    
    repo_impl_file = base_path / "data" / "repositories" / f"{feature_snake}_repository_impl.dart"
    repo_impl_file.write_text(repo_impl_content)
    print(f"📄 Created {repo_impl_file}")
    
    # Create basic provider
    provider_content = f'''// Providers for {feature_pascal} feature

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/{feature_snake}_repository_impl.dart';

part '{feature_snake}_providers.g.dart';

@riverpod
Future<List<Map<String, dynamic>>> {feature_camel}List(
  {feature_pascal}ListRef ref, {{
  required String accountId,
}}) async {{
  final repository = ref.watch({feature_camel}RepositoryProvider);
  final result = await repository.getByAccount(accountId);
  
  return result.fold(
    (failure) => throw failure,
    (items) => items,
  );
}}

@riverpod
class {feature_pascal}Controller extends _${feature_pascal}Controller {{
  @override
  Future<void> build() async {{
    // Initialize controller
  }}
  
  Future<void> create(Map<String, dynamic> data) async {{
    state = const AsyncLoading();
    
    final repository = ref.read({feature_camel}RepositoryProvider);
    final result = await repository.create(data);
    
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (item) {{
        state = const AsyncData(null);
        ref.invalidate({feature_camel}ListProvider);
      }},
    );
  }}
}}
'''
    
    provider_file = base_path / "presentation" / "providers" / f"{feature_snake}_providers.dart"
    provider_file.write_text(provider_content)
    print(f"📄 Created {provider_file}")
    
    # Create basic screen
    screen_content = f'''// Main screen for {feature_pascal} feature

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/{feature_snake}_providers.dart';

class {feature_pascal}Screen extends ConsumerWidget {{
  final String accountId;
  
  const {feature_pascal}Screen({{
    super.key,
    required this.accountId,
  }});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {{
    final itemsAsync = ref.watch({feature_camel}ListProvider(accountId: accountId));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('{feature_pascal}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateDialog(context, ref),
          ),
        ],
      ),
      body: itemsAsync.when(
        data: (items) => items.isEmpty 
          ? const Center(child: Text('No items yet'))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => ListTile(
                title: Text('Item ${{index + 1}}'),
                subtitle: Text('TODO: Display item data'),
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () => ref.invalidate({feature_camel}ListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }}
  
  void _showCreateDialog(BuildContext context, WidgetRef ref) {{
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create {feature_pascal}'),
        content: const Text('TODO: Implement create form'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {{
              // TODO: Implement create
              Navigator.of(context).pop();
            }},
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }}
}}
'''
    
    screen_file = base_path / "presentation" / "screens" / f"{feature_snake}_screen.dart"
    screen_file.write_text(screen_content)
    print(f"📄 Created {screen_file}")
    
    # Create README
    readme_content = f'''# {feature_pascal} Feature

This feature implements {feature_snake} functionality for AshTrail.

## Status
🚧 **In Development** - Basic scaffold created

## Structure
```
lib/features/{feature_snake}/
├── domain/
│   └── repositories/          # Repository interfaces
├── data/
│   └── repositories/          # Repository implementations  
└── presentation/
    ├── providers/             # Riverpod providers
    └── screens/               # UI screens
```

## Next Steps

1. **Define Entity**: Add entity to `feature_matrix.yaml` or create manually
2. **Implement Data Layer**: Add local (Isar) and remote (API) data sources
3. **Add Business Logic**: Create use cases with validation
4. **Complete UI**: Implement forms, detailed views, and interactions
5. **Add Tests**: Unit tests, widget tests, and integration tests

## GitHub Copilot Commands

```
@github #file:lib/features/{feature_snake} Complete this feature implementation
@github #file:current Add comprehensive error handling
@github #file:current Implement offline-first data layer
@github #file:current Add proper form validation and UI
```

## TODO

- [ ] Define proper entity model
- [ ] Implement Isar local storage
- [ ] Add API/Firestore integration
- [ ] Create proper forms and validation
- [ ] Add comprehensive tests
- [ ] Update navigation routing
- [ ] Add to feature_matrix.yaml if needed
'''
    
    readme_file = base_path / "README.md"
    readme_file.write_text(readme_content)
    print(f"📚 Created {readme_file}")
    
    print(f"\n✅ Feature scaffold completed!")
    print(f"\n📝 Next steps:")
    print(f"1. Run code generation: scripts\\dev_generate.bat")
    print(f"2. Implement the TODOs using GitHub Copilot")
    print(f"3. Add proper entity definitions")
    print(f"4. Implement data layer with Isar/API")
    print(f"5. Add comprehensive tests")

def main():
    parser = argparse.ArgumentParser(description="Generate feature scaffold for AshTrail")
    parser.add_argument("feature_name", help="Name of the feature")
    parser.add_argument("--epic", help="Epic name")
    
    args = parser.parse_args()
    create_feature_scaffold(args.feature_name, args.epic)

if __name__ == "__main__":
    main()
