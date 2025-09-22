# AI Agent Quick Reference

Quick prompts and examples for AI agents to generate project documentation using the development automation template.

## 🚀 Feature Matrix Generation

### Basic Prompt Template

```
Generate a comprehensive feature matrix for a [PROJECT_TYPE] project with:

Technology: [TECH_STACK]
Domain: [BUSINESS_DOMAIN]  
Users: [TARGET_USERS]
Scale: [EXPECTED_SIZE]

Include:
- 15-25 features across 5 epics (core, ui, integration, performance, infrastructure)
- Realistic effort estimates (Fibonacci: 1,2,3,5,8,13,21)
- Clear dependencies and acceptance criteria
- Test coverage targets (70-90% based on component criticality)
- Implementation details (files, endpoints, database tables)
- Milestone planning with target dates

Output as YAML following feature_matrix.yaml structure.
```

### Example: E-commerce Platform

```
Create feature matrix for e-commerce platform:

Technology: React TypeScript frontend + Node.js Express backend + PostgreSQL
Features: Product catalog, user auth, shopping cart, payments, orders, inventory
Users: Customers, admins, vendors
Scale: 10k+ products, 1k+ daily users

Include realistic dependencies (payments depends on cart and auth, orders depend on payments, etc.)
```

### Example: Healthcare System

```
Feature matrix for healthcare management:

Technology: Python Django + React + PostgreSQL
Features: Patient records, appointments, billing, medications, reporting
Compliance: HIPAA compliant, audit logging
Users: Doctors, nurses, admins, patients

All features must include security and compliance requirements in acceptance criteria.
```

## 📋 API Documentation

### REST API Prompt

```
Generate REST API documentation for [FEATURE_NAME]:

Include for each endpoint:
- HTTP method and URL pattern
- Request/response examples with realistic data
- Error responses and status codes
- Authentication requirements
- Rate limiting info

Endpoints: [LIST_ENDPOINTS]
Data Models: [LIST_MODELS]

Format as OpenAPI 3.0 compatible Markdown.
```

### GraphQL API Prompt

```
Create GraphQL schema and documentation:

Types: [ENTITY_TYPES]
Queries: [READ_OPERATIONS]
Mutations: [WRITE_OPERATIONS]

Include complete schema, example queries with variables, and error handling patterns.
```

## 🏗️ Domain Model Documentation

### Entity Documentation Prompt

```
Generate domain model documentation:

Business Domain: [DOMAIN_DESCRIPTION]
Key Entities: [MAIN_ENTITIES]
Relationships: [KEY_RELATIONSHIPS]

For each entity include:
- Attributes with types and constraints
- Business rules and validations
- Relationships with cardinality
- Database schema (SQL DDL)
- Sample data and edge cases

Include entity-relationship diagrams in Mermaid syntax.
```

## 🎨 Design Documentation

### UI/UX Design Prompt

```
Create UI/UX design document for [FEATURE_NAME]:

Users: [USER_TYPES]
Devices: [DESKTOP/MOBILE/BOTH]
Use Cases: [PRIMARY_FLOWS]

Include:
- User journey flows with decision points
- Component specifications and states
- Responsive design breakpoints
- Accessibility requirements (WCAG)
- Performance targets

Format with wireframes and flow diagrams.
```

### System Architecture Prompt

```
Generate system architecture document:

Architecture: [MICROSERVICES/MONOLITH/SERVERLESS]
Technology: [TECH_STACK]
Scale: [PERFORMANCE_REQUIREMENTS]
Reliability: [UPTIME_TARGET]

Include:
- High-level architecture diagrams
- Component responsibilities
- Data flow and integration patterns
- Infrastructure and deployment design
- Monitoring and security architecture

Use Mermaid diagrams and include ADRs for key decisions.
```

## 🔧 Project Setup

### Complete Project Initialization

```
Initialize [PROJECT_TYPE] project with automation template:

Project: [PROJECT_NAME]
Technology: [PRIMARY_STACK]
Domain: [BUSINESS_DOMAIN]
Team: [TEAM_SIZE] [EXPERIENCE_LEVEL] developers
Timeline: [PROJECT_DURATION]

Generate:
1. Feature matrix with 15-25 features
2. API specifications (OpenAPI 3.0)
3. Domain models with validation rules
4. Architecture documentation with ADRs
5. Development workflow configuration

Ensure all specifications are implementation-ready for immediate project kickoff.
```

### Legacy Modernization

```
Create modernization plan for legacy [LEGACY_TYPE] to [TARGET_TECH]:

Current: [LEGACY_TECHNOLOGY]
Target: [NEW_ARCHITECTURE]
Migration: [STRATEGY] approach
Timeline: [DURATION]
Users: [USER_COUNT]

Include:
- Feature parity mapping
- Migration phases with risk assessment
- Data migration strategy
- Integration bridge design
- Rollback procedures

Focus on minimal business disruption and measurable milestones.
```

## 🔍 Validation Prompts

### Quality Checks

```
Review generated documentation for:
- Consistency between feature matrix and API specs
- Realistic effort estimates and timelines
- Complete CRUD operations for all entities
- Proper dependency ordering without cycles
- Testable acceptance criteria with metrics
```

### Refinement Prompts

```
Refine the feature matrix to ensure:
- No circular dependencies
- Realistic estimates for [TEAM_SIZE] [EXPERIENCE_LEVEL] developers
- Testable acceptance criteria with specific metrics
- Achievable coverage targets for [TECHNOLOGY]
- Business-aligned milestone planning
```

## 💡 Best Practices

1. **Be Specific** - Provide detailed context about domain, technology, and team
2. **Iterate** - Use follow-up prompts to refine and expand
3. **Validate Dependencies** - Check for logical feature ordering
4. **Review Realism** - Ensure estimates match team capabilities
5. **Check Completeness** - Verify all CRUD operations and error scenarios
6. **Align Business Goals** - Ensure features support actual requirements

## 📚 Usage Examples

### Startup MVP
```
Generate MVP feature matrix for [STARTUP_IDEA]:
- Core user authentication and onboarding
- Primary value proposition features (3-5 features)
- Basic admin panel
- Payment integration
- Mobile-responsive web interface
Target: 3-month development with 2 full-stack developers
```

### Enterprise Integration
```
Design enterprise system integration:
- Legacy system connectivity (REST/SOAP APIs)
- Data synchronization and conflict resolution  
- User management and SSO integration
- Audit logging and compliance reporting
- High availability and disaster recovery
Target: Enterprise-grade reliability and security
```

### Mobile-First Application
```
Create mobile-first application architecture:
- React Native or Flutter cross-platform
- Offline-first data synchronization
- Push notifications and real-time updates
- Social authentication and sharing
- App store deployment pipeline
Target: Consumer mobile app with 100k+ users
```

This quick reference provides ready-to-use prompts for generating comprehensive project documentation with AI assistance.
