#!/usr/bin/env python3
"""AI Documentation Assistant

Helper script to guide users through AI-assisted documentation generation.
Provides interactive prompts and templates for creating project documentation.

Usage:
    python scripts/ai_docs_assistant.py --interactive
    python scripts/ai_docs_assistant.py --template feature-matrix
    python scripts/ai_docs_assistant.py --validate
"""

import argparse
import json
import os
import sys
from pathlib import Path
from typing import Dict, List, Optional

def detect_project_root() -> Path:
    """Detect project root directory."""
    current = Path.cwd()
    indicators = ['.git', 'automation.config.yaml', 'pyproject.toml', 'package.json']

    for path in [current] + list(current.parents):
        for indicator in indicators:
            if (path / indicator).exists():
                return path
    return current

def detect_project_type() -> Dict[str, str]:
    """Detect project type and technology stack."""
    project_root = detect_project_root()
    project_info = {
        'language': 'unknown',
        'framework': 'unknown',
        'type': 'unknown'
    }

    # Language detection
    if (project_root / 'pyproject.toml').exists() or (project_root / 'requirements.txt').exists():
        project_info['language'] = 'python'
        if (project_root / 'manage.py').exists():
            project_info['framework'] = 'django'
        elif any((project_root).glob('**/app.py')):
            project_info['framework'] = 'flask'
        elif any((project_root).glob('**/main.py')):
            project_info['framework'] = 'fastapi'

    elif (project_root / 'package.json').exists():
        project_info['language'] = 'javascript'
        try:
            with open(project_root / 'package.json', 'r') as f:
                package_data = json.load(f)
                deps = list(package_data.get('dependencies', {}).keys())
                if 'react' in deps:
                    project_info['framework'] = 'react'
                elif 'vue' in deps:
                    project_info['framework'] = 'vue'
                elif 'express' in deps:
                    project_info['framework'] = 'express'
        except Exception:
            pass

    elif (project_root / 'pubspec.yaml').exists():
        project_info['language'] = 'dart'
        project_info['framework'] = 'flutter'

    elif (project_root / 'go.mod').exists():
        project_info['language'] = 'go'

    elif (project_root / 'Cargo.toml').exists():
        project_info['language'] = 'rust'

    elif any((project_root).glob('*.csproj')) or any((project_root).glob('*.sln')):
        project_info['language'] = 'csharp'
        project_info['framework'] = 'dotnet'

    # Project type detection
    if 'api' in str(project_root).lower() or 'backend' in str(project_root).lower():
        project_info['type'] = 'api'
    elif 'frontend' in str(project_root).lower() or 'ui' in str(project_root).lower():
        project_info['type'] = 'frontend'
    elif 'mobile' in str(project_root).lower() or project_info['framework'] == 'flutter':
        project_info['type'] = 'mobile'
    else:
        project_info['type'] = 'web_application'

    return project_info

def get_template_prompts() -> Dict[str, str]:
    """Return collection of AI prompt templates."""
    return {
        'feature-matrix': '''Generate a comprehensive feature matrix for a {project_type} project:

**Project Details:**
- Name: {project_name}
- Technology: {technology_stack}
- Domain: {business_domain}
- Target Users: {target_users}
- Expected Scale: {expected_scale}

**Required Features:**
Include these feature categories with 3-5 features each:
- Core: User authentication, data management, core business logic
- UI: Dashboard, forms, navigation, responsive design
- Integration: APIs, third-party services, external systems
- Performance: Caching, optimization, monitoring
- Infrastructure: Deployment, backup, security

**Specifications:**
- Use Fibonacci effort estimation (1,2,3,5,8,13,21)
- Include realistic dependencies between features
- Set coverage targets: 85% core, 75% UI, 70% integration
- Define clear, testable acceptance criteria
- Plan 3 milestones: MVP, Beta, v1.0

Output as YAML following the feature_matrix.yaml structure.''',

        'api-docs': '''Generate comprehensive REST API documentation for {feature_name}:

**API Context:**
- Base URL: https://api.{project_name}.com/v1
- Authentication: Bearer token
- Content-Type: application/json
- Rate Limiting: 1000 requests/hour per user

**Endpoints to Document:**
{api_endpoints}

**For Each Endpoint Include:**
- HTTP method and full URL path
- Request parameters (path, query, body)
- Request/response JSON examples with realistic data
- All possible HTTP status codes and meanings
- Error response format and common error scenarios
- Authentication requirements

**Additional Requirements:**
- Include data model schemas (JSON Schema format)
- Provide cURL examples for testing
- Document pagination patterns
- Show validation error responses

Format as Markdown compatible with OpenAPI 3.0 specification.''',

        'domain-models': '''Generate domain model documentation for {business_domain}:

**Business Context:**
- Primary Entities: {main_entities}
- Key Relationships: {key_relationships}
- Business Rules: {business_rules}

**For each entity include:**
- Attributes with types and constraints
- Business rules and validations
- Relationships with cardinality
- Database schema (SQL DDL)
- Sample data and edge cases

**Output Requirements:**
- Entity-relationship diagrams (Mermaid syntax)
- Complete validation rules
- Database indexes and constraints
- Migration scripts if needed

Focus on business logic clarity and ensure all relationships are properly defined.''',

        'system-architecture': '''Generate system architecture documentation for {project_name}:

**System Requirements:**
- Architecture Pattern: {architecture_pattern}
- Technology Stack: {technology_stack}
- Expected Scale: {expected_scale}
- Reliability Target: {reliability_target}

**Documentation Sections:**
1. High-level architecture diagram (Mermaid syntax)
2. Component responsibilities and interfaces
3. Data flow and integration patterns
4. Infrastructure and deployment design
5. Security and compliance measures
6. Monitoring and observability setup

**Include:**
- Architecture Decision Records (ADRs) for key choices
- Scalability and performance considerations
- Disaster recovery and backup procedures
- Development and deployment workflows

Focus on production-ready architecture with realistic constraints.''',

        'ui-design': '''Create UI/UX design document for {feature_name}:

**Design Context:**
- Primary Users: {target_users}
- Device Targets: {device_targets}
- Use Cases: {primary_use_cases}

**Design Deliverables:**
1. User journey flows with decision points
2. Component specifications and states
3. Responsive design breakpoints
4. Accessibility requirements (WCAG 2.1 AA)
5. Performance targets (Core Web Vitals)

**Include:**
- Wireframes (ASCII art or Mermaid diagrams)
- Component hierarchy and props
- Color palette and typography system
- Interactive states and animations

Focus on usability and accessibility best practices.'''
    }

def interactive_mode():
    """Interactive mode to collect project information."""
    print("🤖 AI Documentation Assistant")
    print("=" * 50)

    # Detect current project
    project_info = detect_project_type()
    project_root = detect_project_root()

    print(f"📁 Project root: {project_root}")
    print(f"🔍 Detected: {project_info['language']} {project_info['framework']} {project_info['type']}")
    print()

    # Collect project information
    project_name = input("Project name: ").strip() or project_root.name
    business_domain = input("Business domain (e.g., e-commerce, healthcare): ").strip()
    target_users = input("Target users (e.g., customers, administrators): ").strip()
    expected_scale = input("Expected scale (small/medium/large): ").strip() or "medium"

    # Technology stack
    if project_info['language'] != 'unknown':
        tech_stack = f"{project_info['language']}"
        if project_info['framework'] != 'unknown':
            tech_stack += f" {project_info['framework']}"
        use_detected = input(f"Use detected tech stack '{tech_stack}'? (Y/n): ").strip().lower()
        if use_detected in ['n', 'no']:
            tech_stack = input("Technology stack: ").strip()
    else:
        tech_stack = input("Technology stack: ").strip()

    # Template selection
    print("\n📋 Available Templates:")
    templates = get_template_prompts()
    for i, template_name in enumerate(templates.keys(), 1):
        print(f"  {i}. {template_name.replace('-', ' ').title()}")

    template_choice = input("\nSelect template (1-5): ").strip()
    template_names = list(templates.keys())

    try:
        selected_template = template_names[int(template_choice) - 1]
    except (ValueError, IndexError):
        print("Invalid selection, using feature-matrix template")
        selected_template = 'feature-matrix'

    # Generate prompt based on template
    template_prompt = templates[selected_template]

    # Collect template-specific information
    context = {
        'project_name': project_name,
        'project_type': project_info['type'],
        'technology_stack': tech_stack,
        'business_domain': business_domain,
        'target_users': target_users,
        'expected_scale': expected_scale
    }

    if selected_template == 'api-docs':
        context['feature_name'] = input("Feature name for API docs: ").strip()
        context['api_endpoints'] = input("Main endpoints (comma-separated): ").strip()

    elif selected_template == 'domain-models':
        context['main_entities'] = input("Main entities (comma-separated): ").strip()
        context['key_relationships'] = input("Key relationships: ").strip()
        context['business_rules'] = input("Business rules: ").strip()

    elif selected_template == 'system-architecture':
        context['architecture_pattern'] = input("Architecture pattern (microservices/monolith): ").strip()
        context['reliability_target'] = input("Reliability target (99.9%/99.99%): ").strip()

    elif selected_template == 'ui-design':
        context['feature_name'] = input("Feature name for UI design: ").strip()
        context['device_targets'] = input("Device targets (desktop/mobile/both): ").strip()
        context['primary_use_cases'] = input("Primary use cases: ").strip()

    # Generate final prompt
    try:
        final_prompt = template_prompt.format(**context)
    except KeyError as e:
        print(f"⚠️  Missing context for {e}, using placeholder")
        # Fill in missing placeholders
        for key in ['feature_name', 'api_endpoints', 'main_entities', 'key_relationships',
                   'business_rules', 'architecture_pattern', 'reliability_target',
                   'device_targets', 'primary_use_cases']:
            if key not in context:
                context[key] = f"[{key.upper()}]"
        final_prompt = template_prompt.format(**context)

    # Output results
    print("\n" + "="*60)
    print("🎯 Generated AI Prompt:")
    print("="*60)
    print(final_prompt)
    print("="*60)

    # Save to file
    output_file = project_root / f"ai-prompt-{selected_template}.txt"
    save_prompt = input(f"\nSave prompt to {output_file}? (Y/n): ").strip().lower()
    if save_prompt not in ['n', 'no']:
        with open(output_file, 'w') as f:
            f.write(final_prompt)
        print(f"✅ Prompt saved to {output_file}")

    print("\n📚 Next Steps:")
    print("1. Copy the prompt above to your AI assistant (ChatGPT, Claude, etc.)")
    print("2. Review and refine the generated documentation")
    print("3. Save the results to appropriate files in your project")
    print("4. Use 'python scripts/ai_docs_assistant.py --validate' to check completeness")

def show_template(template_name: str):
    """Show a specific template prompt."""
    templates = get_template_prompts()
    if template_name not in templates:
        print(f"❌ Template '{template_name}' not found.")
        print("Available templates:", ", ".join(templates.keys()))
        sys.exit(1)

    print(f"📋 Template: {template_name.replace('-', ' ').title()}")
    print("="*60)
    print(templates[template_name])
    print("="*60)

def validate_documentation():
    """Validate existing documentation completeness."""
    project_root = detect_project_root()

    print("🔍 Documentation Validation")
    print("="*40)

    # Check for key files
    checks = {
        'Feature Matrix': project_root / 'feature_matrix.yaml',
        'Automation Config': project_root / 'automation.config.yaml',
        'API Documentation': project_root / 'docs' / 'api.md',
        'Architecture Docs': project_root / 'docs' / 'architecture.md',
        'Domain Models': project_root / 'docs' / 'domain-models.md',
        'README': project_root / 'README.md'
    }

    results = {}
    for name, path in checks.items():
        exists = path.exists()
        results[name] = exists
        status = "✅" if exists else "❌"
        print(f"{status} {name}: {path}")

    # Summary
    total_checks = len(checks)
    passed_checks = sum(results.values())
    completion = (passed_checks / total_checks) * 100

    print(f"\n📊 Documentation Completion: {completion:.1f}% ({passed_checks}/{total_checks})")

    if completion < 100:
        print("\n💡 Suggestions:")
        for name, exists in results.items():
            if not exists:
                print(f"  - Generate {name} using AI templates")
        print("  - Use 'python scripts/ai_docs_assistant.py --interactive' to create missing docs")
    else:
        print("\n🎉 All key documentation files are present!")

def list_templates():
    """List all available templates."""
    templates = get_template_prompts()
    print("📋 Available AI Documentation Templates:")
    print("="*45)

    for template_name in templates.keys():
        title = template_name.replace('-', ' ').title()
        print(f"  • {template_name} - {title}")

    print("\nUsage:")
    print("  python scripts/ai_docs_assistant.py --template feature-matrix")
    print("  python scripts/ai_docs_assistant.py --interactive")

def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="AI Documentation Assistant",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python scripts/ai_docs_assistant.py --interactive
  python scripts/ai_docs_assistant.py --template feature-matrix
  python scripts/ai_docs_assistant.py --template api-docs
  python scripts/ai_docs_assistant.py --validate
  python scripts/ai_docs_assistant.py --list
"""
    )

    parser.add_argument('--interactive', '-i', action='store_true',
                       help='Interactive mode to collect project info and generate prompts')
    parser.add_argument('--template', '-t',
                       help='Show specific template prompt')
    parser.add_argument('--validate', '-v', action='store_true',
                       help='Validate existing documentation completeness')
    parser.add_argument('--list', '-l', action='store_true',
                       help='List all available templates')

    args = parser.parse_args()

    if args.interactive:
        interactive_mode()
    elif args.template:
        show_template(args.template)
    elif args.validate:
        validate_documentation()
    elif args.list:
        list_templates()
    else:
        parser.print_help()

if __name__ == '__main__':
    main()
