#!/usr/bin/env python3
"""Feature Scaffolding Templates

Language-specific templates for generating initial feature structure.
Extracted from AshTrail project and generalized for multiple languages.

Usage:
    python scripts/scaffold_feature.py python user_auth --epic core
    python scripts/scaffold_feature.py javascript dashboard --epic ui
    python scripts/scaffold_feature.py java notification-service --epic integration
"""

import argparse
import os
import sys
from pathlib import Path
from typing import Dict, List, Optional
import yaml
import json

def detect_project_root() -> Path:
    """Detect project root by looking for common indicators."""
    current = Path.cwd()
    indicators = [
        'automation.config.yaml',
        'feature_matrix.yaml',
        '.git',
        'pyproject.toml',
        'package.json',
        'pom.xml',
        'go.mod',
        'Cargo.toml',
        'pubspec.yaml',
    ]

    for path in [current] + list(current.parents):
        for indicator in indicators:
            if (path / indicator).exists():
                return path

    return current

ROOT = detect_project_root()

# Template configurations for different languages
TEMPLATES = {
    'python': {
        'structure': [
            'src/features/{feature_name}/',
            'src/features/{feature_name}/__init__.py',
            'src/features/{feature_name}/models.py',
            'src/features/{feature_name}/views.py',
            'src/features/{feature_name}/serializers.py',
            'src/features/{feature_name}/services.py',
            'tests/features/test_{feature_name}.py',
            'tests/features/test_{feature_name}_integration.py'
        ],
        'files': {
            'src/features/{feature_name}/__init__.py': '''"""
{feature_title} Feature

{description}
"""

from .models import {feature_class}
from .views import {feature_class}ViewSet
from .serializers import {feature_class}Serializer

__all__ = [
    '{feature_class}',
    '{feature_class}ViewSet',
    '{feature_class}Serializer',
]
''',
            'src/features/{feature_name}/models.py': '''"""
{feature_title} Models

Database models for {feature_name} feature.
"""

from typing import Optional
from dataclasses import dataclass
from datetime import datetime


@dataclass
class {feature_class}:
    """
    {feature_title} model.

    Attributes:
        id: Unique identifier
        created_at: Creation timestamp
        updated_at: Last update timestamp
    """
    id: str
    created_at: datetime
    updated_at: Optional[datetime] = None

    def __post_init__(self):
        if self.updated_at is None:
            self.updated_at = self.created_at
''',
            'src/features/{feature_name}/views.py': '''"""
{feature_title} Views

API endpoints for {feature_name} feature.
"""

from typing import List, Optional
from .models import {feature_class}
from .serializers import {feature_class}Serializer


class {feature_class}ViewSet:
    """
    ViewSet for {feature_title} operations.

    Provides CRUD operations for {feature_class} instances.
    """

    def __init__(self):
        self.serializer_class = {feature_class}Serializer

    def list(self) -> List[{feature_class}]:
        """List all {feature_name} instances."""
        # TODO: Implement listing logic
        return []

    def retrieve(self, id: str) -> Optional[{feature_class}]:
        """Retrieve a specific {feature_name} instance."""
        # TODO: Implement retrieval logic
        return None

    def create(self, data: dict) -> {feature_class}:
        """Create a new {feature_name} instance."""
        # TODO: Implement creation logic
        serializer = self.serializer_class(data=data)
        if serializer.is_valid():
            return serializer.save()
        raise ValueError("Invalid data")

    def update(self, id: str, data: dict) -> Optional[{feature_class}]:
        """Update an existing {feature_name} instance."""
        # TODO: Implement update logic
        return None

    def destroy(self, id: str) -> bool:
        """Delete a {feature_name} instance."""
        # TODO: Implement deletion logic
        return False
''',
            'src/features/{feature_name}/serializers.py': '''"""
{feature_title} Serializers

Data serialization for {feature_name} feature.
"""

from typing import Dict, Any
from .models import {feature_class}


class {feature_class}Serializer:
    """
    Serializer for {feature_class} model.
    """

    def __init__(self, instance: {feature_class} = None, data: Dict[str, Any] = None):
        self.instance = instance
        self.data = data
        self._validated_data = None
        self._errors = None

    def is_valid(self) -> bool:
        """Validate the input data."""
        if self.data is None:
            return False

        # TODO: Add validation logic
        required_fields = ['id']  # Add your required fields

        self._errors = {{}}
        for field in required_fields:
            if field not in self.data:
                self._errors[field] = f"{{field}} is required"

        if not self._errors:
            self._validated_data = self.data.copy()
            return True

        return False

    def save(self) -> {feature_class}:
        """Save the validated data."""
        if not self.is_valid():
            raise ValueError("Invalid data")

        # TODO: Implement save logic
        return {feature_class}(**self._validated_data)

    def to_dict(self) -> Dict[str, Any]:
        """Convert model instance to dictionary."""
        if self.instance is None:
            return {{}}

        return {{
            'id': self.instance.id,
            'created_at': self.instance.created_at.isoformat(),
            'updated_at': self.instance.updated_at.isoformat() if self.instance.updated_at else None,
        }}

    @property
    def errors(self) -> Dict[str, str]:
        """Get validation errors."""
        return self._errors or {{}}
''',
            'src/features/{feature_name}/services.py': '''"""
{feature_title} Services

Business logic for {feature_name} feature.
"""

from typing import List, Optional, Dict, Any
from .models import {feature_class}


class {feature_class}Service:
    """
    Service class for {feature_title} business logic.
    """

    def __init__(self):
        # TODO: Initialize any dependencies (database, external services, etc.)
        pass

    def get_all(self) -> List[{feature_class}]:
        """Get all {feature_name} instances."""
        # TODO: Implement business logic for retrieving all instances
        return []

    def get_by_id(self, id: str) -> Optional[{feature_class}]:
        """Get {feature_name} by ID."""
        # TODO: Implement business logic for retrieving by ID
        return None

    def create(self, data: Dict[str, Any]) -> {feature_class}:
        """Create a new {feature_name}."""
        # TODO: Implement business logic for creation
        # This might include validation, transformation, side effects, etc.
        pass

    def update(self, id: str, data: Dict[str, Any]) -> Optional[{feature_class}]:
        """Update an existing {feature_name}."""
        # TODO: Implement business logic for updates
        return None

    def delete(self, id: str) -> bool:
        """Delete a {feature_name}."""
        # TODO: Implement business logic for deletion
        return False

    def search(self, query: str) -> List[{feature_class}]:
        """Search {feature_name} instances."""
        # TODO: Implement search logic
        return []
''',
            'tests/features/test_{feature_name}.py': '''"""
Tests for {feature_title} Feature

Unit tests for {feature_name} feature components.
"""

import unittest
from unittest.mock import Mock, patch
from datetime import datetime

from src.features.{feature_name}.models import {feature_class}
from src.features.{feature_name}.views import {feature_class}ViewSet
from src.features.{feature_name}.serializers import {feature_class}Serializer
from src.features.{feature_name}.services import {feature_class}Service


class Test{feature_class}Model(unittest.TestCase):
    """Test cases for {feature_class} model."""

    def setUp(self):
        """Set up test fixtures."""
        self.test_data = {{
            'id': 'test-123',
            'created_at': datetime.now()
        }}

    def test_model_creation(self):
        """Test {feature_class} model creation."""
        instance = {feature_class}(**self.test_data)

        self.assertEqual(instance.id, 'test-123')
        self.assertIsInstance(instance.created_at, datetime)
        self.assertIsNotNone(instance.updated_at)

    def test_model_post_init(self):
        """Test model post-initialization logic."""
        instance = {feature_class}(**self.test_data)

        # updated_at should be set to created_at if not provided
        self.assertEqual(instance.updated_at, instance.created_at)


class Test{feature_class}Serializer(unittest.TestCase):
    """Test cases for {feature_class} serializer."""

    def setUp(self):
        """Set up test fixtures."""
        self.valid_data = {{
            'id': 'test-123',
        }}
        self.invalid_data = {{}}

    def test_serializer_valid_data(self):
        """Test serializer with valid data."""
        serializer = {feature_class}Serializer(data=self.valid_data)

        self.assertTrue(serializer.is_valid())
        self.assertEqual(len(serializer.errors), 0)

    def test_serializer_invalid_data(self):
        """Test serializer with invalid data."""
        serializer = {feature_class}Serializer(data=self.invalid_data)

        self.assertFalse(serializer.is_valid())
        self.assertIn('id', serializer.errors)

    def test_serializer_to_dict(self):
        """Test serializer to_dict method."""
        instance = {feature_class}(
            id='test-123',
            created_at=datetime.now()
        )
        serializer = {feature_class}Serializer(instance=instance)

        result = serializer.to_dict()

        self.assertIn('id', result)
        self.assertIn('created_at', result)
        self.assertEqual(result['id'], 'test-123')


class Test{feature_class}ViewSet(unittest.TestCase):
    """Test cases for {feature_class} viewset."""

    def setUp(self):
        """Set up test fixtures."""
        self.viewset = {feature_class}ViewSet()

    def test_viewset_initialization(self):
        """Test viewset initialization."""
        self.assertEqual(self.viewset.serializer_class, {feature_class}Serializer)

    def test_list_method(self):
        """Test list method."""
        result = self.viewset.list()

        # Should return empty list initially
        self.assertIsInstance(result, list)
        self.assertEqual(len(result), 0)

    def test_retrieve_method(self):
        """Test retrieve method."""
        result = self.viewset.retrieve('test-123')

        # Should return None initially
        self.assertIsNone(result)


class Test{feature_class}Service(unittest.TestCase):
    """Test cases for {feature_class} service."""

    def setUp(self):
        """Set up test fixtures."""
        self.service = {feature_class}Service()

    def test_service_initialization(self):
        """Test service initialization."""
        self.assertIsInstance(self.service, {feature_class}Service)

    def test_get_all_method(self):
        """Test get_all method."""
        result = self.service.get_all()

        # Should return empty list initially
        self.assertIsInstance(result, list)
        self.assertEqual(len(result), 0)

    def test_get_by_id_method(self):
        """Test get_by_id method."""
        result = self.service.get_by_id('test-123')

        # Should return None initially
        self.assertIsNone(result)


if __name__ == '__main__':
    unittest.main()
''',
            'tests/features/test_{feature_name}_integration.py': '''"""
Integration Tests for {feature_title} Feature

Integration tests covering the full {feature_name} feature workflow.
"""

import unittest
from unittest.mock import Mock, patch
from datetime import datetime

from src.features.{feature_name}.models import {feature_class}
from src.features.{feature_name}.views import {feature_class}ViewSet
from src.features.{feature_name}.services import {feature_class}Service


class {feature_class}IntegrationTest(unittest.TestCase):
    """Integration tests for {feature_title} feature."""

    def setUp(self):
        """Set up test fixtures."""
        self.service = {feature_class}Service()
        self.viewset = {feature_class}ViewSet()

    def test_create_retrieve_workflow(self):
        """Test complete create and retrieve workflow."""
        # TODO: Implement integration test for create -> retrieve workflow
        pass

    def test_update_workflow(self):
        """Test complete update workflow."""
        # TODO: Implement integration test for update workflow
        pass

    def test_delete_workflow(self):
        """Test complete delete workflow."""
        # TODO: Implement integration test for delete workflow
        pass

    def test_search_functionality(self):
        """Test search functionality."""
        # TODO: Implement integration test for search
        pass

    def test_error_handling(self):
        """Test error handling across components."""
        # TODO: Implement error handling tests
        pass


if __name__ == '__main__':
    unittest.main()
'''
        }
    },

    'javascript': {
        'structure': [
            'src/features/{feature_name}/',
            'src/features/{feature_name}/index.js',
            'src/features/{feature_name}/components/',
            'src/features/{feature_name}/components/index.js',
            'src/features/{feature_name}/hooks/',
            'src/features/{feature_name}/hooks/index.js',
            'src/features/{feature_name}/services/',
            'src/features/{feature_name}/services/index.js',
            'src/features/{feature_name}/utils/',
            'src/features/{feature_name}/utils/index.js',
            'src/features/{feature_name}/__tests__/',
            'src/features/{feature_name}/__tests__/{feature_name}.test.js',
            'src/features/{feature_name}/__tests__/{feature_name}.integration.test.js'
        ],
        'files': {
            'src/features/{feature_name}/index.js': '''/**
 * {feature_title} Feature
 *
 * {description}
 */

export {{ default as {feature_class}Component }} from './components';
export {{ use{feature_class} }} from './hooks';
export {{ {feature_name}Service }} from './services';
export * from './utils';
''',
            'src/features/{feature_name}/components/index.js': '''/**
 * {feature_title} Components
 */

import React, {{ useState, useEffect }} from 'react';
import {{ use{feature_class} }} from '../hooks';

/**
 * Main {feature_title} component
 */
const {feature_class}Component = ({{ id, onUpdate, ...props }}) => {{
  const {{
    data,
    loading,
    error,
    refresh
  }} = use{feature_class}(id);

  if (loading) {{
    return <div className="loading">Loading {feature_name}...</div>;
  }}

  if (error) {{
    return <div className="error">Error: {{error.message}}</div>;
  }}

  return (
    <div className="{feature_name}-component" {{...props}}>
      <h2>{feature_title}</h2>
      {{data && (
        <div className="{feature_name}-content">
          <pre>{{JSON.stringify(data, null, 2)}}</pre>
        </div>
      )}}
    </div>
  );
}};

export default {feature_class}Component;
''',
            'src/features/{feature_name}/hooks/index.js': '''/**
 * {feature_title} Hooks
 */

import {{ useState, useEffect, useCallback }} from 'react';
import {{ {feature_name}Service }} from '../services';

/**
 * Custom hook for {feature_title} data management
 *
 * @param {{string}} id - The {feature_name} ID
 * @returns {{object}} Hook state and methods
 */
export const use{feature_class} = (id) => {{
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const fetchData = useCallback(async () => {{
    if (!id) return;

    setLoading(true);
    setError(null);

    try {{
      const result = await {feature_name}Service.getById(id);
      setData(result);
    }} catch (err) {{
      setError(err);
    }} finally {{
      setLoading(false);
    }}
  }}, [id]);

  const create = useCallback(async (newData) => {{
    setLoading(true);
    setError(null);

    try {{
      const result = await {feature_name}Service.create(newData);
      setData(result);
      return result;
    }} catch (err) {{
      setError(err);
      throw err;
    }} finally {{
      setLoading(false);
    }}
  }}, []);

  const update = useCallback(async (updateData) => {{
    if (!id) return;

    setLoading(true);
    setError(null);

    try {{
      const result = await {feature_name}Service.update(id, updateData);
      setData(result);
      return result;
    }} catch (err) {{
      setError(err);
      throw err;
    }} finally {{
      setLoading(false);
    }}
  }}, [id]);

  const remove = useCallback(async () => {{
    if (!id) return;

    setLoading(true);
    setError(null);

    try {{
      await {feature_name}Service.delete(id);
      setData(null);
    }} catch (err) {{
      setError(err);
      throw err;
    }} finally {{
      setLoading(false);
    }}
  }}, [id]);

  useEffect(() => {{
    fetchData();
  }}, [fetchData]);

  return {{
    data,
    loading,
    error,
    refresh: fetchData,
    create,
    update,
    delete: remove
  }};
}};
''',
            'src/features/{feature_name}/services/index.js': '''/**
 * {feature_title} Services
 *
 * API and business logic for {feature_name} feature
 */

/**
 * Service class for {feature_title} operations
 */
class {feature_class}Service {{
  constructor() {{
    this.baseUrl = process.env.REACT_APP_API_URL || '/api';
  }}

  /**
   * Get all {feature_name} items
   * @returns {{Promise<Array>}} Array of {feature_name} items
   */
  async getAll() {{
    try {{
      const response = await fetch(`${{this.baseUrl}}/{feature_name}`);

      if (!response.ok) {{
        throw new Error(`HTTP error! status: ${{response.status}}`);
      }}

      return await response.json();
    }} catch (error) {{
      console.error('Error fetching {feature_name} items:', error);
      throw error;
    }}
  }}

  /**
   * Get {feature_name} by ID
   * @param {{string}} id - The {feature_name} ID
   * @returns {{Promise<Object>}} The {feature_name} item
   */
  async getById(id) {{
    try {{
      const response = await fetch(`${{this.baseUrl}}/{feature_name}/${{id}}`);

      if (!response.ok) {{
        throw new Error(`HTTP error! status: ${{response.status}}`);
      }}

      return await response.json();
    }} catch (error) {{
      console.error(`Error fetching {feature_name} ${{id}}:`, error);
      throw error;
    }}
  }}

  /**
   * Create new {feature_name}
   * @param {{Object}} data - The {feature_name} data
   * @returns {{Promise<Object>}} The created {feature_name}
   */
  async create(data) {{
    try {{
      const response = await fetch(`${{this.baseUrl}}/{feature_name}`, {{
        method: 'POST',
        headers: {{
          'Content-Type': 'application/json',
        }},
        body: JSON.stringify(data),
      }});

      if (!response.ok) {{
        throw new Error(`HTTP error! status: ${{response.status}}`);
      }}

      return await response.json();
    }} catch (error) {{
      console.error('Error creating {feature_name}:', error);
      throw error;
    }}
  }}

  /**
   * Update {feature_name}
   * @param {{string}} id - The {feature_name} ID
   * @param {{Object}} data - The update data
   * @returns {{Promise<Object>}} The updated {feature_name}
   */
  async update(id, data) {{
    try {{
      const response = await fetch(`${{this.baseUrl}}/{feature_name}/${{id}}`, {{
        method: 'PUT',
        headers: {{
          'Content-Type': 'application/json',
        }},
        body: JSON.stringify(data),
      }});

      if (!response.ok) {{
        throw new Error(`HTTP error! status: ${{response.status}}`);
      }}

      return await response.json();
    }} catch (error) {{
      console.error(`Error updating {feature_name} ${{id}}:`, error);
      throw error;
    }}
  }}

  /**
   * Delete {feature_name}
   * @param {{string}} id - The {feature_name} ID
   * @returns {{Promise<boolean>}} Success status
   */
  async delete(id) {{
    try {{
      const response = await fetch(`${{this.baseUrl}}/{feature_name}/${{id}}`, {{
        method: 'DELETE',
      }});

      if (!response.ok) {{
        throw new Error(`HTTP error! status: ${{response.status}}`);
      }}

      return true;
    }} catch (error) {{
      console.error(`Error deleting {feature_name} ${{id}}:`, error);
      throw error;
    }}
  }}

  /**
   * Search {feature_name} items
   * @param {{string}} query - Search query
   * @returns {{Promise<Array>}} Search results
   */
  async search(query) {{
    try {{
      const response = await fetch(`${{this.baseUrl}}/{feature_name}/search?q=${{encodeURIComponent(query)}}`);

      if (!response.ok) {{
        throw new Error(`HTTP error! status: ${{response.status}}`);
      }}

      return await response.json();
    }} catch (error) {{
      console.error('Error searching {feature_name}:', error);
      throw error;
    }}
  }}
}}

export const {feature_name}Service = new {feature_class}Service();
''',
            'src/features/{feature_name}/__tests__/{feature_name}.test.js': '''/**
 * {feature_title} Tests
 *
 * Unit tests for {feature_name} feature
 */

import React from 'react';
import {{ render, screen, fireEvent, waitFor }} from '@testing-library/react';
import {{ jest }} from '@jest/globals';

import {feature_class}Component from '../components';
import {{ use{feature_class} }} from '../hooks';
import {{ {feature_name}Service }} from '../services';

// Mock the service
jest.mock('../services', () => ({{
  {feature_name}Service: {{
    getById: jest.fn(),
    create: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
    getAll: jest.fn(),
    search: jest.fn(),
  }}
}}));

// Mock the hook
jest.mock('../hooks', () => ({{
  use{feature_class}: jest.fn()
}}));

describe('{feature_class}Component', () => {{
  beforeEach(() => {{
    jest.clearAllMocks();
  }});

  test('renders loading state', () => {{
    use{feature_class}.mockReturnValue({{
      data: null,
      loading: true,
      error: null,
      refresh: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn()
    }});

    render(<{feature_class}Component id="test-123" />);

    expect(screen.getByText('Loading {feature_name}...')).toBeInTheDocument();
  }});

  test('renders error state', () => {{
    const mockError = new Error('Test error');
    use{feature_class}.mockReturnValue({{
      data: null,
      loading: false,
      error: mockError,
      refresh: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn()
    }});

    render(<{feature_class}Component id="test-123" />);

    expect(screen.getByText('Error: Test error')).toBeInTheDocument();
  }});

  test('renders data when loaded', () => {{
    const mockData = {{ id: 'test-123', name: 'Test {feature_title}' }};
    use{feature_class}.mockReturnValue({{
      data: mockData,
      loading: false,
      error: null,
      refresh: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn()
    }});

    render(<{feature_class}Component id="test-123" />);

    expect(screen.getByText('{feature_title}')).toBeInTheDocument();
    expect(screen.getByText(/test-123/)).toBeInTheDocument();
  }});
}});

describe('use{feature_class} hook', () => {{
  // Note: Testing custom hooks requires @testing-library/react-hooks
  // This is a simplified example

  test('hook functionality would be tested here', () => {{
    // TODO: Add comprehensive hook tests
    expect(true).toBe(true);
  }});
}});

describe('{feature_name}Service', () => {{
  beforeEach(() => {{
    global.fetch = jest.fn();
    jest.clearAllMocks();
  }});

  afterEach(() => {{
    global.fetch.mockRestore();
  }});

  test('getById fetches data correctly', async () => {{
    const mockData = {{ id: 'test-123', name: 'Test {feature_title}' }};
    global.fetch.mockResolvedValueOnce({{
      ok: true,
      json: async () => mockData,
    }});

    const result = await {feature_name}Service.getById('test-123');

    expect(global.fetch).toHaveBeenCalledWith('/api/{feature_name}/test-123');
    expect(result).toEqual(mockData);
  }});

  test('create posts data correctly', async () => {{
    const mockData = {{ name: 'New {feature_title}' }};
    const mockResponse = {{ id: 'new-123', ...mockData }};

    global.fetch.mockResolvedValueOnce({{
      ok: true,
      json: async () => mockResponse,
    }});

    const result = await {feature_name}Service.create(mockData);

    expect(global.fetch).toHaveBeenCalledWith('/api/{feature_name}', {{
      method: 'POST',
      headers: {{
        'Content-Type': 'application/json',
      }},
      body: JSON.stringify(mockData),
    }});
    expect(result).toEqual(mockResponse);
  }});

  test('handles fetch errors', async () => {{
    global.fetch.mockResolvedValueOnce({{
      ok: false,
      status: 404,
    }});

    await expect({feature_name}Service.getById('not-found'))
      .rejects
      .toThrow('HTTP error! status: 404');
  }});
}});
'''
        }
    }
}

def to_pascal_case(text: str) -> str:
    """Convert snake_case or kebab-case to PascalCase."""
    return ''.join(word.capitalize() for word in text.replace('-', '_').split('_'))

def to_snake_case(text: str) -> str:
    """Convert to snake_case."""
    return text.replace('-', '_').lower()

def create_directories(paths: List[str]):
    """Create directory structure."""
    for path in paths:
        Path(path).mkdir(parents=True, exist_ok=True)

def create_file_with_content(file_path: str, content: str, variables: Dict[str, str]):
    """Create file with templated content."""
    # Replace template variables
    for key, value in variables.items():
        content = content.replace(f'{{{key}}}', value)

    Path(file_path).parent.mkdir(parents=True, exist_ok=True)

    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

def scaffold_feature(language: str, feature_name: str, epic: str = "core", description: str = ""):
    """Generate feature scaffold for specified language."""
    if language not in TEMPLATES:
        print(f"❌ Language '{language}' not supported")
        print(f"Supported languages: {', '.join(TEMPLATES.keys())}")
        return False

    template = TEMPLATES[language]

    # Prepare template variables
    feature_snake = to_snake_case(feature_name)
    feature_class = to_pascal_case(feature_name)
    feature_title = feature_name.replace('_', ' ').replace('-', ' ').title()

    if not description:
        description = f"Implementation of {feature_title} functionality"

    variables = {
        'feature_name': feature_snake,
        'feature_class': feature_class,
        'feature_title': feature_title,
        'epic': epic,
        'description': description,
    }

    print(f"🚀 Scaffolding {feature_title} feature for {language}")
    print(f"📁 Feature name: {feature_snake}")
    print(f"🏗️  Class name: {feature_class}")
    print(f"📊 Epic: {epic}")

    # Create directory structure
    directories = []
    for path_template in template['structure']:
        if path_template.endswith('/'):
            directories.append(path_template.format(**variables))

    create_directories(directories)
    print(f"📂 Created {len(directories)} directories")

    # Create files with content
    files_created = 0
    for file_template, content_template in template.get('files', {}).items():
        file_path = file_template.format(**variables)
        create_file_with_content(file_path, content_template, variables)
        files_created += 1
        print(f"📄 Created {file_path}")

    # Create empty files for remaining structure items
    for path_template in template['structure']:
        if not path_template.endswith('/'):
            file_path = path_template.format(**variables)
            if not Path(file_path).exists():
                Path(file_path).parent.mkdir(parents=True, exist_ok=True)
                Path(file_path).touch()
                files_created += 1
                print(f"📄 Created {file_path} (empty)")

    print(f"✅ Scaffold complete: {files_created} files created")

    # Update feature matrix if it exists
    feature_matrix_path = ROOT / "feature_matrix.yaml"
    if feature_matrix_path.exists():
        try:
            with open(feature_matrix_path, 'r', encoding='utf-8') as f:
                matrix = yaml.safe_load(f)

            if 'features' not in matrix:
                matrix['features'] = {}

            # Add new feature entry
            matrix['features'][feature_snake] = {
                'name': feature_title,
                'epic': epic,
                'description': description,
                'priority': len(matrix['features']) + 1,
                'status': 'designed',
                'complexity': 'medium',
                'effort_points': 8,
                'tags': [language, 'generated'],
                'dependencies': [],
                'blocked_by': [],
                'acceptance_criteria': [
                    f"{feature_title} component/module is implemented",
                    f"Basic CRUD operations are available",
                    f"Unit tests provide adequate coverage",
                    f"Integration tests validate workflow"
                ],
                'test_coverage': {
                    'target': 80,
                    'current': 0
                }
            }

            with open(feature_matrix_path, 'w', encoding='utf-8') as f:
                yaml.dump(matrix, f, default_flow_style=False, indent=2)

            print(f"📋 Updated feature_matrix.yaml with new feature")

        except Exception as e:
            print(f"⚠️  Warning: Could not update feature_matrix.yaml: {e}")

    return True

def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Generate language-specific feature scaffolds",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python scaffold_feature.py python user_auth --epic core
  python scaffold_feature.py javascript dashboard --epic ui --description "User dashboard with metrics"
  python scaffold_feature.py java notification-service --epic integration

Supported languages: """ + ", ".join(TEMPLATES.keys())
    )

    parser.add_argument('language', choices=TEMPLATES.keys(),
                       help='Programming language/framework')
    parser.add_argument('feature_name', help='Feature name (snake_case or kebab-case)')
    parser.add_argument('--epic', default='core',
                       help='Epic category (default: core)')
    parser.add_argument('--description', default='',
                       help='Feature description')

    args = parser.parse_args()

    try:
        success = scaffold_feature(
            args.language,
            args.feature_name,
            args.epic,
            args.description
        )

        if success:
            print(f"\n🎉 Feature scaffold complete!")
            print(f"Next steps:")
            print(f"1. Review generated files and customize as needed")
            print(f"2. Implement business logic in service classes")
            print(f"3. Add comprehensive tests")
            print(f"4. Update feature_matrix.yaml status when ready")
            print(f"5. Use 'python scripts/dev_assistant.py start-next-feature --feature {to_snake_case(args.feature_name)}' to begin development")
        else:
            sys.exit(1)

    except KeyboardInterrupt:
        print("\n⚠️  Operation cancelled")
        sys.exit(130)
    except Exception as e:
        print(f"💥 Error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    main()
