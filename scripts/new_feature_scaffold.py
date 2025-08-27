#!/usr/bin/env python3
"""
AshTrail Feature Development Template Generator

Creates a complete feature scaffold following Clean Architecture principles.
Generates the directory structure, base files, and provides Copilot-friendly
templates for rapid development.

Usage:
    python scripts/new_feature_scaffold.py <feature_name> [--epic <epic_name>]

Example:
    python scripts/new_feature_scaffold.py user_profile --epic accounts
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

def create_feature_structure(feature_name, epic_name=None):
    """Create the complete feature directory structure."""
    feature_snake = snake_case(feature_name)
    feature_pascal = pascal_case(feature_name)
    
    base_path = Path(f"lib/features/{feature_snake}")
    
    # Create directory structure
    directories = [
        base_path / "domain" / "entities",
        base_path / "domain" / "repositories",
        base_path / "domain" / "use_cases",
        base_path / "data" / "models",
        base_path / "data" / "repositories",
        base_path / "data" / "data_sources",
        base_path / "presentation" / "providers",
        base_path / "presentation" / "screens",
        base_path / "presentation" / "widgets",
    ]
    
    for dir_path in directories:
        dir_path.mkdir(parents=True, exist_ok=True)
        print(f"📁 Created {dir_path}")
    
    return base_path, feature_snake, feature_pascal

def create_domain_files(base_path, feature_snake, feature_pascal):
    """Create domain layer files."""
    
    feature_camel = camel_case(feature_snake)
    
    # Entity (if not generated from feature_matrix)
    entity_content = f'''// Domain entity for {feature_pascal}
// NOTE: If this entity exists in feature_matrix.yaml, 
// delete this file and use the generated version instead.

import 'package:freezed_annotation/freezed_annotation.dart';

part '{feature_snake}_entity.freezed.dart';

@freezed
class {feature_pascal}Entity with _${feature_pascal}Entity {{
  const factory {feature_pascal}Entity({{
    required String id,
    required String accountId,
    required DateTime createdAt,
    DateTime? updatedAt,
    // TODO: Add feature-specific fields
  }}) = _{feature_pascal}Entity;
}}
'''
    
    entity_file = base_path / "domain" / "entities" / f"{feature_snake}_entity.dart"
    entity_file.write_text(entity_content)
    print(f"📄 Created {entity_file}")
    
    # Repository interface
    repo_interface_content = f'''// Repository interface for {feature_pascal}
// Defines the contract for data access

import 'package:fpdart/fpdart.dart';
import '../../../core/failures/app_failure.dart';
import '../entities/{feature_snake}_entity.dart';

abstract class {feature_pascal}Repository {{
  /// Fetch all {feature_snake} items for the given account
  Future<Either<AppFailure, List<{feature_pascal}Entity>>> getByAccount(
    String accountId,
  );
  
  /// Create a new {feature_snake} item
  Future<Either<AppFailure, {feature_pascal}Entity>> create(
    {feature_pascal}Entity entity,
  );
  
  /// Update an existing {feature_snake} item
  Future<Either<AppFailure, {feature_pascal}Entity>> update(
    {feature_pascal}Entity entity,
  );
  
  /// Delete a {feature_snake} item
  Future<Either<AppFailure, void>> delete(String id);
}}
'''
    
    repo_file = base_path / "domain" / "repositories" / f"{feature_snake}_repository.dart"
    repo_file.write_text(repo_interface_content)
    print(f"📄 Created {repo_file}")
    
    # Use case
    use_case_content = f'''// Use case for {feature_pascal} operations
// Encapsulates business logic

import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/failures/app_failure.dart';
import '../entities/{feature_snake}_entity.dart';
import '../repositories/{feature_snake}_repository.dart';
import '../../data/repositories/{feature_snake}_repository_impl.dart';

part '{feature_snake}_use_case.g.dart';

@riverpod
{feature_pascal}UseCase {feature_camel}UseCase({feature_pascal}UseCaseRef ref) {{
  return {feature_pascal}UseCase(
    repository: ref.watch({feature_camel}RepositoryProvider),
  );
}}

class {feature_pascal}UseCase {{
  final {feature_pascal}Repository _repository;
  
  const {feature_pascal}UseCase({{
    required {feature_pascal}Repository repository,
  }}) : _repository = repository;
  
  /// Get all {feature_snake} items for account
  Future<Either<AppFailure, List<{feature_pascal}Entity>>> getByAccount(
    String accountId,
  ) async {{
    return await _repository.getByAccount(accountId);
  }}
  
  /// Create new {feature_snake} item
  Future<Either<AppFailure, {feature_pascal}Entity>> create(
    {feature_pascal}Entity entity,
  ) async {{
    // TODO: Add business logic validation
    return await _repository.create(entity);
  }}
  
  /// Update existing {feature_snake} item
  Future<Either<AppFailure, {feature_pascal}Entity>> update(
    {feature_pascal}Entity entity,
  ) async {{
    // TODO: Add business logic validation
    return await _repository.update(entity);
  }}
  
  /// Delete {feature_snake} item
  Future<Either<AppFailure, void>> delete(String id) async {{
    return await _repository.delete(id);
  }}
}}
'''
    
    use_case_file = base_path / "domain" / "use_cases" / f"{feature_snake}_use_case.dart"
    use_case_file.write_text(use_case_content)
    print(f"📄 Created {use_case_file}")

def create_data_files(base_path, feature_snake, feature_pascal):
    """Create data layer files."""
    
    # DTO Model
    dto_content = f'''// Data Transfer Object for {feature_pascal}
// Used for API communication and serialization

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/models/{feature_snake}.dart'; // Generated model
import '../../domain/entities/{feature_snake}_entity.dart';

part '{feature_snake}_dto.freezed.dart';
part '{feature_snake}_dto.g.dart';

@freezed
class {feature_pascal}Dto with _${feature_pascal}Dto {{
  const factory {feature_pascal}Dto({{
    required String id,
    required String accountId,
    required DateTime createdAt,
    DateTime? updatedAt,
    // TODO: Add DTO-specific fields (match API contract)
  }}) = _{feature_pascal}Dto;
  
  factory {feature_pascal}Dto.fromJson(Map<String, dynamic> json) =>
      _${feature_pascal}DtoFromJson(json);
}}

extension {feature_pascal}DtoMapper on {feature_pascal}Dto {{
  /// Convert DTO to domain entity
  {feature_pascal}Entity toEntity() {{
    return {feature_pascal}Entity(
      id: id,
      accountId: accountId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }}
}}

extension {feature_pascal}EntityMapper on {feature_pascal}Entity {{
  /// Convert domain entity to DTO
  {feature_pascal}Dto toDto() {{
    return {feature_pascal}Dto(
      id: id,
      accountId: accountId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }}
}}
'''
    
    dto_file = base_path / "data" / "models" / f"{feature_snake}_dto.dart"
    dto_file.write_text(dto_content)
    print(f"📄 Created {dto_file}")
    
    # Repository Implementation
    repo_impl_content = f'''// Repository implementation for {feature_pascal}
// Implements the domain repository interface

import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/failures/app_failure.dart';
import '../../domain/entities/{feature_snake}_entity.dart';
import '../../domain/repositories/{feature_snake}_repository.dart';
import '../data_sources/{feature_snake}_local_data_source.dart';
import '../data_sources/{feature_snake}_remote_data_source.dart';

part '{feature_snake}_repository_impl.g.dart';

@riverpod
{feature_pascal}Repository {camel_case(feature_name)}Repository({pascal_case(feature_name)}RepositoryRef ref) {{
  return {feature_pascal}RepositoryImpl(
    localDataSource: ref.watch({camel_case(feature_name)}LocalDataSourceProvider),
    remoteDataSource: ref.watch({camel_case(feature_name)}RemoteDataSourceProvider),
  );
}}

class {feature_pascal}RepositoryImpl implements {feature_pascal}Repository {{
  final {feature_pascal}LocalDataSource _localDataSource;
  final {feature_pascal}RemoteDataSource _remoteDataSource;
  
  const {feature_pascal}RepositoryImpl({{
    required {feature_pascal}LocalDataSource localDataSource,
    required {feature_pascal}RemoteDataSource remoteDataSource,
  }}) : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;
  
  @override
  Future<Either<AppFailure, List<{feature_pascal}Entity>>> getByAccount(
    String accountId,
  ) async {{
    try {{
      // Offline-first: try local first
      final localResult = await _localDataSource.getByAccount(accountId);
      
      // TODO: Implement sync logic
      // - Check if data is stale
      // - Trigger background sync if needed
      // - Return local data immediately
      
      return Right(localResult);
    }} catch (e) {{
      return Left(DataFailure('Failed to fetch {feature_snake}: $e'));
    }}
  }}
  
  @override
  Future<Either<AppFailure, {feature_pascal}Entity>> create(
    {feature_pascal}Entity entity,
  ) async {{
    try {{
      // Write to local storage first (offline-first)
      await _localDataSource.insert(entity);
      
      // Enqueue for remote sync
      // TODO: Add to sync queue
      
      return Right(entity);
    }} catch (e) {{
      return Left(DataFailure('Failed to create {feature_snake}: $e'));
    }}
  }}
  
  @override
  Future<Either<AppFailure, {feature_pascal}Entity>> update(
    {feature_pascal}Entity entity,
  ) async {{
    try {{
      await _localDataSource.update(entity);
      
      // TODO: Add to sync queue
      
      return Right(entity);
    }} catch (e) {{
      return Left(DataFailure('Failed to update {feature_snake}: $e'));
    }}
  }}
  
  @override
  Future<Either<AppFailure, void>> delete(String id) async {{
    try {{
      await _localDataSource.delete(id);
      
      // TODO: Add to sync queue
      
      return const Right(null);
    }} catch (e) {{
      return Left(DataFailure('Failed to delete {feature_snake}: $e'));
    }}
  }}
}}
'''
    
    repo_impl_file = base_path / "data" / "repositories" / f"{feature_snake}_repository_impl.dart"
    repo_impl_file.write_text(repo_impl_content)
    print(f"📄 Created {repo_impl_file}")

def create_data_sources(base_path, feature_snake, feature_pascal):
    """Create data source files."""
    
    # Local data source
    local_ds_content = f'''// Local data source for {feature_pascal}
// Handles local storage operations (Isar)

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/{feature_snake}_entity.dart';

part '{feature_snake}_local_data_source.g.dart';

@riverpod
{feature_pascal}LocalDataSource {camel_case(feature_name)}LocalDataSource(
  {pascal_case(feature_name)}LocalDataSourceRef ref,
) {{
  // TODO: Inject Isar instance
  return {feature_pascal}LocalDataSource();
}}

class {feature_pascal}LocalDataSource {{
  // TODO: Add Isar instance
  
  Future<List<{feature_pascal}Entity>> getByAccount(String accountId) async {{
    // TODO: Implement Isar query
    // return isar.{feature_snake}s.filter()
    //   .accountIdEqualTo(accountId)
    //   .findAll();
    throw UnimplementedError('Implement Isar query');
  }}
  
  Future<void> insert({feature_pascal}Entity entity) async {{
    // TODO: Implement Isar insert
    // await isar.writeTxn(() async {{
    //   await isar.{feature_snake}s.put(entity.toIsar());
    // }});
    throw UnimplementedError('Implement Isar insert');
  }}
  
  Future<void> update({feature_pascal}Entity entity) async {{
    // TODO: Implement Isar update
    throw UnimplementedError('Implement Isar update');
  }}
  
  Future<void> delete(String id) async {{
    // TODO: Implement Isar delete
    throw UnimplementedError('Implement Isar delete');
  }}
}}
'''
    
    local_ds_file = base_path / "data" / "data_sources" / f"{feature_snake}_local_data_source.dart"
    local_ds_file.write_text(local_ds_content)
    print(f"📄 Created {local_ds_file}")
    
    # Remote data source
    remote_ds_content = f'''// Remote data source for {feature_pascal}
// Handles API/Firestore operations

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/{feature_snake}_dto.dart';

part '{feature_snake}_remote_data_source.g.dart';

@riverpod
{feature_pascal}RemoteDataSource {camel_case(feature_name)}RemoteDataSource(
  {pascal_case(feature_name)}RemoteDataSourceRef ref,
) {{
  // TODO: Inject HTTP client or Firestore instance
  return {feature_pascal}RemoteDataSource();
}}

class {feature_pascal}RemoteDataSource {{
  // TODO: Add HTTP client or Firestore instance
  
  Future<List<{feature_pascal}Dto>> getByAccount(String accountId) async {{
    // TODO: Implement API call
    // final response = await dio.get('/api/{feature_snake}s?accountId=$accountId');
    // return (response.data as List)
    //   .map((json) => {feature_pascal}Dto.fromJson(json))
    //   .toList();
    throw UnimplementedError('Implement API call');
  }}
  
  Future<{feature_pascal}Dto> create({feature_pascal}Dto dto) async {{
    // TODO: Implement API call
    // final response = await dio.post('/api/{feature_snake}s', data: dto.toJson());
    // return {feature_pascal}Dto.fromJson(response.data);
    throw UnimplementedError('Implement API call');
  }}
  
  Future<{feature_pascal}Dto> update({feature_pascal}Dto dto) async {{
    // TODO: Implement API call
    throw UnimplementedError('Implement API call');
  }}
  
  Future<void> delete(String id) async {{
    // TODO: Implement API call
    throw UnimplementedError('Implement API call');
  }}
}}
'''
    
    remote_ds_file = base_path / "data" / "data_sources" / f"{feature_snake}_remote_data_source.dart"
    remote_ds_file.write_text(remote_ds_content)
    print(f"📄 Created {remote_ds_file}")

def create_presentation_files(base_path, feature_snake, feature_pascal):
    """Create presentation layer files."""
    
    # Provider
    provider_content = f'''// Providers for {feature_pascal} feature
// Manages state and business logic integration

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/{feature_snake}_entity.dart';
import '../../domain/use_cases/{feature_snake}_use_case.dart';

part '{feature_snake}_providers.g.dart';

/// Provides list of {feature_snake} items for the active account
@riverpod
Future<List<{feature_pascal}Entity>> {camel_case(feature_name)}List(
  {pascal_case(feature_name)}ListRef ref, {{
  required String accountId,
}}) async {{
  final useCase = ref.watch({camel_case(feature_name)}UseCaseProvider);
  final result = await useCase.getByAccount(accountId);
  
  return result.fold(
    (failure) => throw failure,
    (items) => items,
  );
}}

/// Provides a specific {feature_snake} item by ID
@riverpod
Future<{feature_pascal}Entity?> {camel_case(feature_name)}ById(
  {pascal_case(feature_name)}ByIdRef ref, {{
  required String id,
  required String accountId,
}}) async {{
  final items = await ref.watch({camel_case(feature_name)}ListProvider(accountId: accountId).future);
  return items.where((item) => item.id == id).firstOrNull;
}}

/// Controller for {feature_snake} operations
@riverpod
class {feature_pascal}Controller extends _${feature_pascal}Controller {{
  @override
  Future<void> build() async {{
    // Initialize controller state
  }}
  
  /// Create a new {feature_snake} item
  Future<void> create({feature_pascal}Entity entity) async {{
    state = const AsyncLoading();
    
    final useCase = ref.read({camel_case(feature_name)}UseCaseProvider);
    final result = await useCase.create(entity);
    
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (item) {{
        state = const AsyncData(null);
        // Invalidate list to refresh UI
        ref.invalidate({camel_case(feature_name)}ListProvider);
      }},
    );
  }}
  
  /// Update an existing {feature_snake} item
  Future<void> update({feature_pascal}Entity entity) async {{
    state = const AsyncLoading();
    
    final useCase = ref.read({camel_case(feature_name)}UseCaseProvider);
    final result = await useCase.update(entity);
    
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (item) {{
        state = const AsyncData(null);
        ref.invalidate({camel_case(feature_name)}ListProvider);
      }},
    );
  }}
  
  /// Delete a {feature_snake} item
  Future<void> delete(String id) async {{
    state = const AsyncLoading();
    
    final useCase = ref.read({camel_case(feature_name)}UseCaseProvider);
    final result = await useCase.delete(id);
    
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) {{
        state = const AsyncData(null);
        ref.invalidate({camel_case(feature_name)}ListProvider);
      }},
    );
  }}
}}
'''
    
    provider_file = base_path / "presentation" / "providers" / f"{feature_snake}_providers.dart"
    provider_file.write_text(provider_content)
    print(f"📄 Created {provider_file}")
    
    # Screen
    screen_content = f'''// Main screen for {feature_pascal} feature

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/{feature_snake}_providers.dart';
import '../widgets/{feature_snake}_list_widget.dart';

class {feature_pascal}Screen extends ConsumerWidget {{
  final String accountId;
  
  const {feature_pascal}Screen({{
    super.key,
    required this.accountId,
  }});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {{
    return Scaffold(
      appBar: AppBar(
        title: Text('{pascal_case(feature_name)}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateDialog(context, ref),
          ),
        ],
      ),
      body: {feature_pascal}ListView(accountId: accountId),
    );
  }}
  
  void _showCreateDialog(BuildContext context, WidgetRef ref) {{
    // TODO: Implement create dialog
    // Consider using GitHub Copilot to generate the form:
    // @github #file:current Create a form dialog for adding new {feature_snake}
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create {pascal_case(feature_name)}'),
        content: const Text('TODO: Implement create form'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {{
              // TODO: Implement create action
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
    
    # Widget
    widget_content = f'''// List widget for {feature_pascal} items

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/{feature_snake}_providers.dart';

class {feature_pascal}ListView extends ConsumerWidget {{
  final String accountId;
  
  const {feature_pascal}ListView({{
    super.key,
    required this.accountId,
  }});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {{
    final itemsAsync = ref.watch({camel_case(feature_name)}ListProvider(accountId: accountId));
    
    return itemsAsync.when(
      data: (items) {{
        if (items.isEmpty) {{
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No {feature_snake} items yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap + to create your first item',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }}
        
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {{
            final item = items[index];
            return {feature_pascal}ListTile(item: item);
          }},
        );
      }},
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading {feature_snake} items',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate({camel_case(feature_name)}ListProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }}
}}

class {feature_pascal}ListTile extends ConsumerWidget {{
  final dynamic item; // TODO: Replace with proper {feature_pascal}Entity type
  
  const {feature_pascal}ListTile({{
    super.key,
    required this.item,
  }});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {{
    return ListTile(
      title: Text('TODO: Display {feature_snake} title'),
      subtitle: Text('TODO: Display {feature_snake} subtitle'),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () => _showActions(context, ref),
      ),
      onTap: () {{
        // TODO: Navigate to detail screen
        // Use GitHub Copilot to help implement navigation:
        // @github #file:current Add navigation to detail screen
      }},
    );
  }}
  
  void _showActions(BuildContext context, WidgetRef ref) {{
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {{
              Navigator.of(context).pop();
              // TODO: Implement edit action
            }},
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {{
              Navigator.of(context).pop();
              _showDeleteConfirmation(context, ref);
            }},
          ),
        ],
      ),
    );
  }}
  
  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {{
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete {pascal_case(feature_name)}'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {{
              Navigator.of(context).pop();
              // TODO: Implement delete action
              // ref.read({camel_case(feature_name)}ControllerProvider.notifier).delete(item.id);
            }},
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }}
}}
'''
    
    widget_file = base_path / "presentation" / "widgets" / f"{feature_snake}_list_widget.dart"
    widget_file.write_text(widget_content)
    print(f"📄 Created {widget_file}")

def create_test_files(feature_snake, feature_pascal):
    """Create test files for the feature."""
    
    test_base = Path(f"test/features/{feature_snake}")
    test_base.mkdir(parents=True, exist_ok=True)
    
    # Unit test for use case
    use_case_test_content = f'''// Unit tests for {feature_pascal}UseCase

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';

import 'package:ash_trail/features/{feature_snake}/domain/entities/{feature_snake}_entity.dart';
import 'package:ash_trail/features/{feature_snake}/domain/repositories/{feature_snake}_repository.dart';
import 'package:ash_trail/features/{feature_snake}/domain/use_cases/{feature_snake}_use_case.dart';
import 'package:ash_trail/core/failures/app_failure.dart';

class Mock{feature_pascal}Repository extends Mock implements {feature_pascal}Repository {{}}

void main() {{
  group('{feature_pascal}UseCase', () {{
    late {feature_pascal}UseCase useCase;
    late Mock{feature_pascal}Repository mockRepository;
    
    setUp(() {{
      mockRepository = Mock{feature_pascal}Repository();
      useCase = {feature_pascal}UseCase(repository: mockRepository);
    }});
    
    group('getByAccount', () {{
      const accountId = 'test-account-id';
      
      test('should return list of entities when repository succeeds', () async {{
        // Arrange
        final entities = [
          {feature_pascal}Entity(
            id: 'test-id',
            accountId: accountId,
            createdAt: DateTime.now(),
          ),
        ];
        when(() => mockRepository.getByAccount(accountId))
            .thenAnswer((_) async => Right(entities));
        
        // Act
        final result = await useCase.getByAccount(accountId);
        
        // Assert
        expect(result, isA<Right<AppFailure, List<{feature_pascal}Entity>>>());
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (items) => expect(items, equals(entities)),
        );
        verify(() => mockRepository.getByAccount(accountId)).called(1);
      }});
      
      test('should return failure when repository fails', () async {{
        // Arrange
        const failure = DataFailure('Repository error');
        when(() => mockRepository.getByAccount(accountId))
            .thenAnswer((_) async => const Left(failure));
        
        // Act
        final result = await useCase.getByAccount(accountId);
        
        // Assert
        expect(result, isA<Left<AppFailure, List<{feature_pascal}Entity>>>());
        result.fold(
          (f) => expect(f, equals(failure)),
          (items) => fail('Expected failure but got success: $items'),
        );
      }});
    }});
    
    group('create', () {{
      test('should create entity when repository succeeds', () async {{
        // Arrange
        final entity = {feature_pascal}Entity(
          id: 'test-id',
          accountId: 'test-account-id',
          createdAt: DateTime.now(),
        );
        when(() => mockRepository.create(entity))
            .thenAnswer((_) async => Right(entity));
        
        // Act
        final result = await useCase.create(entity);
        
        // Assert
        expect(result, isA<Right<AppFailure, {feature_pascal}Entity>>());
        result.fold(
          (failure) => fail('Expected success but got failure: $failure'),
          (item) => expect(item, equals(entity)),
        );
        verify(() => mockRepository.create(entity)).called(1);
      }});
      
      // TODO: Add more test cases using GitHub Copilot:
      // @github #file:current Add test cases for validation failures
      // @github #file:current Add test cases for edge cases
    }});
    
    // TODO: Add tests for update and delete methods
    // Use GitHub Copilot to generate similar test patterns
  }});
}}
'''
    
    test_file = test_base / f"{feature_snake}_use_case_test.dart"
    test_file.write_text(use_case_test_content)
    print(f"🧪 Created {test_file}")
    
    # Widget test
    widget_test_content = f'''// Widget tests for {feature_pascal} UI components

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ash_trail/features/{feature_snake}/presentation/widgets/{feature_snake}_list_widget.dart';
import 'package:ash_trail/features/{feature_snake}/presentation/providers/{feature_snake}_providers.dart';
import 'package:ash_trail/features/{feature_snake}/domain/entities/{feature_snake}_entity.dart';

import '../../../test_util/test_harness.dart';

void main() {{
  group('{feature_pascal}ListView', () {{
    testWidgets('shows loading indicator when data is loading', (tester) async {{
      // Arrange
      final harness = TestHarness.overrides([
        {camel_case(feature_name)}ListProvider(accountId: 'test-account')
            .overrideWith((_) => const AsyncLoading()),
      ]);
      
      // Act
      await tester.pumpWidget(
        harness.wrap(
          const {feature_pascal}ListView(accountId: 'test-account'),
        ),
      );
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    }});
    
    testWidgets('shows empty state when no items exist', (tester) async {{
      // Arrange
      final harness = TestHarness.overrides([
        {camel_case(feature_name)}ListProvider(accountId: 'test-account')
            .overrideWith((_) => const AsyncData(<{feature_pascal}Entity>[])),
      ]);
      
      // Act
      await tester.pumpWidget(
        harness.wrap(
          const {feature_pascal}ListView(accountId: 'test-account'),
        ),
      );
      
      // Assert
      expect(find.text('No {feature_snake} items yet'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    }});
    
    testWidgets('shows list of items when data is available', (tester) async {{
      // Arrange
      final entities = [
        {feature_pascal}Entity(
          id: 'test-id-1',
          accountId: 'test-account',
          createdAt: DateTime.now(),
        ),
        {feature_pascal}Entity(
          id: 'test-id-2',
          accountId: 'test-account',
          createdAt: DateTime.now(),
        ),
      ];
      
      final harness = TestHarness.overrides([
        {camel_case(feature_name)}ListProvider(accountId: 'test-account')
            .overrideWith((_) => AsyncData(entities)),
      ]);
      
      // Act
      await tester.pumpWidget(
        harness.wrap(
          const {feature_pascal}ListView(accountId: 'test-account'),
        ),
      );
      
      // Assert
      expect(find.byType({feature_pascal}ListTile), findsNWidgets(2));
    }});
    
    testWidgets('shows error state when data loading fails', (tester) async {{
      // Arrange
      const error = 'Test error';
      final harness = TestHarness.overrides([
        {camel_case(feature_name)}ListProvider(accountId: 'test-account')
            .overrideWith((_) => const AsyncError(error, StackTrace.empty)),
      ]);
      
      // Act
      await tester.pumpWidget(
        harness.wrap(
          const {feature_pascal}ListView(accountId: 'test-account'),
        ),
      );
      
      // Assert
      expect(find.text('Error loading {feature_snake} items'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    }});
    
    // TODO: Add more widget tests using GitHub Copilot:
    // @github #file:current Add tests for list tile interactions
    // @github #file:current Add golden tests for visual validation
  }});
}}
'''
    
    widget_test_file = test_base / f"{feature_snake}_widget_test.dart"
    widget_test_file.write_text(widget_test_content)
    print(f"🧪 Created {widget_test_file}")

def create_readme(feature_snake, feature_pascal, epic_name):
    """Create README for the feature."""
    
    readme_content = f'''# {feature_pascal} Feature

This feature implements {feature_snake} functionality for the AshTrail app.

## Overview

**Epic**: {epic_name or 'TBD'}  
**Status**: 🚧 In Development  
**Architecture**: Clean Architecture with feature-first modules

## Structure

```
lib/features/{feature_snake}/
├── domain/                 # Business logic (pure Dart)
│   ├── entities/          # Domain entities
│   ├── repositories/      # Repository interfaces
│   └── use_cases/         # Business use cases
├── data/                  # Data access layer
│   ├── models/           # DTOs and mappers
│   ├── repositories/     # Repository implementations
│   └── data_sources/     # Local (Isar) and remote (API) sources
└── presentation/         # UI layer
    ├── providers/        # Riverpod providers
    ├── screens/          # Main screens
    └── widgets/          # Reusable widgets
```

## Development Guidelines

### 1. Use Generated Models
If this feature's entities are defined in `feature_matrix.yaml`, use the generated models instead of the manual entity file.

### 2. Implement Data Sources
- **Local**: Implement Isar queries for offline storage
- **Remote**: Implement API calls or Firestore operations
- **Sync**: Add operations to sync queue for offline-first behavior

### 3. Follow Offline-First Pattern
1. Write to local storage first
2. Mark as dirty/pending sync
3. Enqueue for background sync
4. Handle conflicts with last-write-wins

### 4. Provider Best Practices
- Use `@riverpod` for automatic disposal
- Split read and write operations
- Invalidate providers after mutations
- Handle loading/error states properly

### 5. Testing Strategy
- **Unit**: Test use cases and repository logic
- **Widget**: Test UI components and interactions
- **Integration**: Test end-to-end flows with offline scenarios

## TODO Checklist

### Data Layer
- [ ] Implement Isar schema and queries
- [ ] Implement API/Firestore operations
- [ ] Add sync queue integration
- [ ] Handle conflict resolution

### Business Logic
- [ ] Add validation rules to use cases
- [ ] Implement business logic constraints
- [ ] Add error handling for edge cases

### UI Layer
- [ ] Implement create/edit forms
- [ ] Add proper loading states
- [ ] Implement optimistic updates
- [ ] Add accessibility labels

### Testing
- [ ] Complete unit test coverage (≥70%)
- [ ] Add widget tests for all components
- [ ] Add integration tests for critical flows
- [ ] Create golden tests for UI validation

### Documentation
- [ ] Update feature_matrix.yaml if needed
- [ ] Add ADR for any architectural decisions
- [ ] Document API contracts
- [ ] Update this README

## GitHub Copilot Tips

Use these prompts to accelerate development:

### Code Generation
```
@github #file:current Implement the Isar data source with proper queries
@github #file:current Add validation logic to the use case
@github #file:current Create a form widget for {feature_snake} input
@github #file:current Implement optimistic updates in the provider
```

### Testing
```
@github #file:current Add comprehensive unit tests for edge cases
@github #file:current Create widget tests with golden file validation
@github #file:current Add integration tests for offline scenarios
```

### Architecture
```
@github #workspace How should I handle conflicts in {feature_snake}?
@github #file:current Follow AshTrail's offline-first patterns
@github #file:current Add proper error handling following app conventions
```

## Related Files

- `feature_matrix.yaml` - Feature requirements and acceptance criteria
- `lib/core/failures/` - Common failure types
- `lib/core/routing/` - Navigation integration
- `test/test_util/test_harness.dart` - Test utilities

## References

- [AshTrail Architecture Guide](./.github/copilot-instructions.md)
- [Clean Architecture Principles](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Riverpod Documentation](https://riverpod.dev/)
- [Freezed Documentation](https://pub.dev/packages/freezed)
'''
    
    readme_file = Path(f"lib/features/{feature_snake}/README.md")
    readme_file.write_text(readme_content)
    print(f"📚 Created {readme_file}")

def main():
    """Main function to generate feature scaffold."""
    parser = argparse.ArgumentParser(
        description="Generate a complete feature scaffold for AshTrail"
    )
    parser.add_argument("feature_name", help="Name of the feature (e.g., user_profile)")
    parser.add_argument("--epic", help="Epic name this feature belongs to")
    
    args = parser.parse_args()
    
    print(f"🚀 Generating feature scaffold for: {args.feature_name}")
    print("=" * 50)
    
    # Create feature structure
    base_path, feature_snake, feature_pascal = create_feature_structure(
        args.feature_name, args.epic
    )
    
    print(f"\n📁 Feature: {feature_pascal} ({feature_snake})")
    print(f"📁 Path: {base_path}")
    if args.epic:
        print(f"📁 Epic: {args.epic}")
    
    # Generate all files
    print(f"\n⚙️  Generating domain layer...")
    create_domain_files(base_path, feature_snake, feature_pascal)
    
    print(f"\n⚙️  Generating data layer...")
    create_data_files(base_path, feature_snake, feature_pascal)
    create_data_sources(base_path, feature_snake, feature_pascal)
    
    print(f"\n⚙️  Generating presentation layer...")
    create_presentation_files(base_path, feature_snake, feature_pascal)
    
    print(f"\n🧪 Generating tests...")
    create_test_files(feature_snake, feature_pascal)
    
    print(f"\n📚 Generating documentation...")
    create_readme(feature_snake, feature_pascal, args.epic)
    
    print(f"\n✅ Feature scaffold completed!")
    print("=" * 50)
    print(f"\n📝 Next steps:")
    print(f"1. Review generated files in lib/features/{feature_snake}/")
    print(f"2. Update feature_matrix.yaml if this is a new feature")
    print(f"3. Run code generation: scripts\\dev_generate.bat")
    print(f"4. Implement TODOs using GitHub Copilot")
    print(f"5. Add proper entity definition if not in feature_matrix.yaml")
    print(f"6. Implement Isar schema and API calls")
    print(f"7. Add comprehensive tests")
    
    print(f"\n🤖 GitHub Copilot commands:")
    print(f"   @github #workspace Implement {feature_snake} feature following AshTrail patterns")
    print(f"   @github #file:lib/features/{feature_snake} Complete the implementation")
    print(f"   @github #file:current Add comprehensive error handling")

if __name__ == "__main__":
    main()
