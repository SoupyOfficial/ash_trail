# AI Agent Assistance Guide

This guide provides example prompts and instructions for AI agents to generate comprehensive project documentation, including feature matrices, API specifications, entity documentation, and design documents.

## Table of Contents

- [Feature Matrix Generation](#feature-matrix-generation)
- [API Documentation](#api-documentation)
- [Entity/Domain Model Documentation](#entitydomain-model-documentation)
- [Design Documentation](#design-documentation)  
- [Architecture Documentation](#architecture-documentation)
- [Project Setup Prompts](#project-setup-prompts)

## Feature Matrix Generation

### Basic Feature Matrix Prompt

```
Generate a comprehensive feature matrix for a \[PROJECT_TYPE\] project called "\[PROJECT_NAME\]". The matrix should include:

**Project Context:**
- Technology stack: \[LANGUAGE/FRAMEWORK\]
- Target users: \[USER_TYPE\]
- Main purpose: \[PROJECT_PURPOSE\]
- Expected scale: \[SMALL/MEDIUM/LARGE\]

**Required Structure:**
1. Project metadata (name, version, language, framework)
2. Epic definitions with priorities (core, ui, integration, performance, infrastructure)
3. Detailed feature definitions including:
   - Name, description, and epic assignment
   - Priority, status, and complexity levels
   - Effort estimation (Fibonacci scale: 1, 2, 3, 5, 8, 13, 21)
   - Dependencies and blockers
   - Implementation details (files, endpoints, database tables)
   - Acceptance criteria (3-5 specific, testable requirements)
   - Test coverage targets (realistic percentages)
4. Milestone definitions with target dates
5. Workflow configuration
6. Language-specific templates

**Output Format:** YAML following the template structure in feature_matrix.yaml
**Focus Areas:** \[LIST 3-5 KEY FEATURE AREAS\]

Please ensure all features have realistic dependencies, proper status progression, and achievable coverage targets.
```

### Domain-Specific Feature Matrix Examples

#### E-commerce Platform
```
Generate a feature matrix for an e-commerce platform with these specifics:

**Technology:** React TypeScript frontend, Node.js Express backend, PostgreSQL database
**Key Features:** Product catalog, user authentication, shopping cart, payment processing, order management, inventory tracking
**User Types:** Customers, administrators, vendors
**Scale:** Medium-sized (10k+ products, 1k+ daily users)

Include features for:
- User management (registration, profiles, authentication)
- Product management (catalog, search, recommendations)
- Commerce operations (cart, checkout, payments)
- Order fulfillment (processing, shipping, tracking)
- Admin tools (dashboard, analytics, inventory)
- Integration points (payment gateways, shipping APIs)

Structure with realistic dependencies (e.g., payment processing depends on user authentication and cart functionality).
```

#### Healthcare Management System
```
Create a feature matrix for a healthcare management system:

**Technology:** Python Django backend, React frontend, PostgreSQL database
**Key Features:** Patient records, appointment scheduling, billing, medication tracking, reporting
**Compliance:** HIPAA compliant, audit logging required
**Users:** Doctors, nurses, administrators, patients

Include features for:
- Patient management (records, medical history, demographics)
- Appointment system (scheduling, reminders, availability)
- Medical documentation (notes, prescriptions, lab results)
- Billing and insurance (claims processing, payment tracking)
- Reporting and analytics (patient outcomes, resource utilization)
- Security and compliance (audit logs, access control, data encryption)

Ensure all features include security considerations and compliance requirements in acceptance criteria.
```

#### SaaS Analytics Platform
```
Design a feature matrix for a SaaS analytics platform:

**Technology:** Python FastAPI backend, Vue.js frontend, ClickHouse for analytics, Redis for caching
**Key Features:** Data ingestion, dashboard creation, real-time analytics, user management, multi-tenancy
**Users:** End users, admin users, API consumers
**Scale:** Large (millions of events per day, hundreds of customers)

Focus on:
- Data pipeline (ingestion, processing, storage)
- Analytics engine (queries, aggregations, real-time processing)
- User interface (dashboards, charts, custom queries)
- Multi-tenancy (data isolation, resource management)
- API and integrations (REST API, webhooks, SDKs)
- Performance and monitoring (query optimization, system health)

Include realistic effort estimates for data platform complexity and proper dependency chains.
```

## API Documentation

### REST API Documentation Prompt

```
Generate comprehensive REST API documentation for the [FEATURE_NAME] feature in a [LANGUAGE/FRAMEWORK] project.

**Context:**
- Base URL: [API_BASE_URL]
- Authentication: [AUTH_METHOD]
- Data format: JSON
- API version: v1

**Required Documentation:**
1. **Overview** - Feature purpose and main endpoints
2. **Authentication** - How to authenticate requests
3. **Endpoints** - For each endpoint include:
   - HTTP method and URL pattern
   - Description and use case
   - Request parameters (path, query, body)
   - Request/response examples with realistic data
   - HTTP status codes and error responses
   - Rate limiting information
4. **Data Models** - JSON schemas for request/response objects
5. **Error Handling** - Standard error format and common errors
6. **SDK Examples** - Code samples in popular languages
7. **Testing** - Example curl commands or test cases

**Endpoints to Document:**
[LIST_OF_ENDPOINTS]

**Data Models:**
[LIST_OF_MODELS]

Format as Markdown with OpenAPI 3.0 specification compatibility. Include realistic examples and comprehensive error scenarios.
```

### GraphQL API Documentation Prompt

```
Create GraphQL API documentation for a [PROJECT_TYPE] with these requirements:

**Schema Elements:**
- Types: [LIST_TYPES]
- Queries: [LIST_QUERIES] 
- Mutations: [LIST_MUTATIONS]
- Subscriptions: [LIST_SUBSCRIPTIONS]

**Documentation Structure:**
1. Schema overview and design principles
2. Type definitions with field descriptions
3. Query documentation with examples
4. Mutation documentation with input validation
5. Subscription documentation with real-time use cases
6. Error handling and validation
7. Authentication and authorization
8. Performance considerations (N+1 queries, DataLoader usage)
9. Client integration examples

Include complete GraphQL schema definition and example queries/mutations with variables.
```

## Entity/Domain Model Documentation

### Domain Model Generation Prompt

```
Generate comprehensive domain model documentation for a [PROJECT_TYPE] system:

**Business Domain:** [DOMAIN_DESCRIPTION]
**Key Entities:** [LIST_MAIN_ENTITIES]
**Relationships:** [DESCRIBE_KEY_RELATIONSHIPS]

**For each entity, provide:**
1. **Entity Definition**
   - Name and purpose
   - Key attributes with types and constraints
   - Business rules and invariants
   - Lifecycle states (if applicable)

2. **Relationships**
   - Related entities and cardinality
   - Foreign key constraints
   - Cascade rules and referential integrity

3. **Behaviors**
   - Key operations and methods
   - Business logic and validation rules
   - Event triggers and side effects

4. **Implementation Details**
   - Database table schema
   - Indexes and performance considerations
   - Audit/versioning requirements

5. **Examples**
   - Sample data instances
   - Common queries and operations
   - Edge cases and validation scenarios

**Output Format:** Include entity-relationship diagrams (Mermaid syntax), database schemas (SQL DDL), and code examples in [TARGET_LANGUAGE].

Focus on business logic clarity and ensure all relationships are properly defined with realistic constraints.
```

### Data Model Validation Prompt

```
Create comprehensive data validation documentation for these entities: [ENTITY_LIST]

**For each entity, specify:**
1. **Field Validations**
   - Required fields and optional fields
   - Data type constraints and formats
   - Length limits and range validations
   - Pattern matching (regex) for formatted fields
   - Custom business rule validations

2. **Cross-Field Validations**
   - Conditional requirements based on other fields
   - Date range validations
   - Mutual exclusivity rules
   - Dependent field relationships

3. **Entity-Level Validations**
   - Uniqueness constraints (single and composite)
   - Business invariant rules
   - State transition validations
   - Referential integrity checks

4. **Integration Validations**
   - External system data consistency
   - API contract validations
   - Batch operation constraints

**Include:**
- Validation error messages and codes
- Unit test examples for each validation rule
- Performance impact of complex validations
- Database constraints vs application-level validation trade-offs

Format as implementation-ready specifications with code examples in [TARGET_LANGUAGE].
```

## Design Documentation

### UI/UX Design Document Prompt

```
Create a comprehensive UI/UX design document for [FEATURE_NAME] in a [APPLICATION_TYPE]:

**User Context:**
- Primary users: [USER_TYPES]
- Use cases: [PRIMARY_USE_CASES]
- Device targets: [DESKTOP/MOBILE/BOTH]
- Accessibility requirements: [WCAG_LEVEL]

**Design Requirements:**
1. **User Flow Documentation**
   - Step-by-step user journeys for each use case
   - Decision points and alternative paths
   - Error scenarios and recovery flows
   - Success criteria and completion states

2. **Interface Specifications**
   - Screen layouts and component hierarchy
   - Responsive design breakpoints
   - Component states (default, hover, active, disabled, loading, error)
   - Navigation patterns and information architecture

3. **Interaction Design**
   - User input methods and validation feedback
   - Loading states and progress indicators
   - Error messages and help text
   - Confirmation dialogs and destructive actions

4. **Visual Design Guidelines**
   - Color palette and theme definitions
   - Typography scale and font usage
   - Spacing system and grid layout
   - Icon library and visual elements

5. **Accessibility Considerations**
   - Keyboard navigation support
   - Screen reader compatibility
   - Color contrast requirements
   - Focus management and ARIA labels

6. **Performance Requirements**
   - Load time targets for different network conditions
   - Animation performance guidelines
   - Image optimization and lazy loading
   - Critical rendering path optimization

**Deliverables:**
- Wireframes (ASCII art or Mermaid diagrams)
- Component specifications with props/attributes
- User flow diagrams
- Accessibility checklist
- Performance budget breakdown

Include realistic examples and consider common usability patterns for [APPLICATION_TYPE] applications.
```

### System Architecture Design Prompt

```
Generate a comprehensive system architecture document for [PROJECT_NAME]:

**System Context:**
- Architecture pattern: [MICROSERVICES/MONOLITH/SERVERLESS]
- Technology stack: [TECH_STACK]
- Expected scale: [USERS/REQUESTS_PER_DAY]
- Performance requirements: [LATENCY/THROUGHPUT_TARGETS]
- Reliability requirements: [UPTIME_TARGET]

**Architecture Documentation:**
1. **System Overview**
   - High-level architecture diagram
   - Component responsibilities and boundaries
   - Data flow between components
   - External dependencies and integrations

2. **Component Design**
   - Service/module breakdown with single responsibilities
   - Interface definitions and contracts
   - Technology choices and rationale
   - Scalability and performance characteristics

3. **Data Architecture**
   - Database design and partitioning strategy
   - Caching layers and invalidation strategies
   - Data consistency and transaction boundaries
   - Backup and disaster recovery plans

4. **Infrastructure Design**
   - Deployment architecture and environments
   - Load balancing and auto-scaling strategies
   - Monitoring and observability setup
   - Security architecture and access controls

5. **Non-Functional Requirements**
   - Performance benchmarks and SLAs
   - Security measures and compliance requirements
   - Disaster recovery and business continuity
   - Operational procedures and runbooks

6. **Integration Patterns**
   - API design principles and versioning
   - Event-driven communication patterns
   - Third-party service integrations
   - Error handling and circuit breaker patterns

**Include:**
- Architecture diagrams (Mermaid or C4 model syntax)
- Technology decision rationales (ADRs)
- Deployment configuration examples
- Monitoring and alerting specifications
- Security threat model and mitigations

Focus on production-ready architecture with realistic scalability and reliability considerations.
```

## Architecture Documentation

### Technical Architecture Decision Records (ADRs)

```
Generate Architecture Decision Records (ADRs) for key technical decisions in [PROJECT_NAME]:

**For each decision, create an ADR with:**
1. **Title** - Concise decision summary
2. **Status** - Proposed/Accepted/Rejected/Superseded
3. **Context** - Problem statement and constraints
4. **Options Considered** - Alternative solutions with pros/cons
5. **Decision** - Chosen solution and rationale
6. **Consequences** - Expected positive and negative outcomes

**Key Decisions to Document:**
- Primary technology stack selection ([LANGUAGE/FRAMEWORK] choice)
- Database technology and data modeling approach
- Architecture pattern (microservices vs monolith)
- Authentication and authorization strategy
- Caching strategy and technology
- Message queue/event streaming technology
- Deployment and CI/CD pipeline approach
- Monitoring and observability tools
- Testing strategy and framework selection

**ADR Template Format:**
```markdown
# ADR-001: [Decision Title]

## Status
[Proposed | Accepted | Rejected | Superseded]

## Context
[Describe the problem and constraints]

## Options Considered
### Option 1: [Name]
- Pros: [List advantages]
- Cons: [List disadvantages]
- Trade-offs: [Key considerations]

### Option 2: [Name]
[Same format]

## Decision
[Chosen option and why]

## Consequences
### Positive
- [Expected benefits]

### Negative
- [Expected challenges or limitations]

## Implementation Notes
- [Key implementation considerations]
- [Migration or adoption strategy]
- [Monitoring and success metrics]

## References
- [Links to research, documentation, or related ADRs]
```

Focus on decisions that have long-term architectural impact and provide clear rationale for future team members.
```

## Project Setup Prompts

### Complete Project Initialization Prompt

```
Initialize a complete [PROJECT_TYPE] project using the development automation template:

**Project Details:**
- Name: [PROJECT_NAME]
- Technology stack: [PRIMARY_LANGUAGE/FRAMEWORK]
- Domain: [BUSINESS_DOMAIN]
- Target audience: [USER_DESCRIPTION]
- Expected team size: [TEAM_SIZE]
- Timeline: [PROJECT_DURATION]

**Generate the following:**

1. **Feature Matrix** (`feature_matrix.yaml`)
   - 15-25 features across 5 epics
   - Realistic dependencies and effort estimates
   - Clear acceptance criteria for each feature
   - Milestone planning with target dates

2. **Project Configuration** (`automation.config.yaml`)
   - Language-specific tool configuration
   - CI/CD pipeline settings
   - Code quality gates and thresholds
   - Environment-specific settings

3. **API Specifications**
   - OpenAPI 3.0 specification for REST APIs
   - Core entity CRUD operations
   - Authentication endpoints
   - Integration endpoints

4. **Domain Models**
   - Entity definitions with relationships
   - Data validation rules
   - Business logic specifications
   - Database schema design

5. **Architecture Documentation**
   - System architecture overview
   - Component interaction diagrams  
   - Technology decision rationales (ADRs)
   - Deployment and infrastructure design

6. **Development Workflow**
   - Git branching strategy
   - Code review guidelines
   - Testing strategy
   - Release process documentation

**Quality Requirements:**
- All features must have realistic effort estimates
- API documentation must include examples and error handling
- Architecture must support expected scale and performance
- Documentation should be suitable for a [EXPERIENCE_LEVEL] development team

Provide implementation-ready specifications that can be used immediately for project kickoff.
```

### Legacy System Modernization Prompt

```
Generate a modernization plan and feature matrix for migrating a legacy [LEGACY_SYSTEM_TYPE] to modern [TARGET_TECHNOLOGY]:

**Legacy System Context:**
- Current technology: [LEGACY_TECH_STACK]
- Main functionality: [CORE_FEATURES]
- Known issues: [PAIN_POINTS]
- Users: [USER_COUNT] active users
- Data volume: [DATA_SCALE]

**Modernization Approach:**
- Target architecture: [NEW_ARCHITECTURE_PATTERN]
- Migration strategy: [STRANGLER_FIG/BIG_BANG/GRADUAL]
- Timeline: [MIGRATION_DURATION]
- Risk tolerance: [LOW/MEDIUM/HIGH]

**Required Deliverables:**

1. **Migration Feature Matrix**
   - Feature parity mapping (legacy → modern)
   - Modernization priorities and phases
   - Risk assessment for each feature migration
   - Data migration requirements
   - Integration bridge requirements

2. **Architecture Transition Plan**
   - Current state architecture documentation
   - Target state architecture design
   - Transition states and milestones
   - Data migration strategy
   - System integration approach

3. **Risk Mitigation Strategy**
   - Technical risks and mitigation plans
   - Business continuity during migration
   - Rollback procedures and checkpoints
   - User training and change management
   - Performance and reliability considerations

4. **Implementation Roadmap**
   - Phase-by-phase migration plan
   - Resource requirements and timeline
   - Dependencies and critical path
   - Success criteria and validation points
   - Go-live strategy and monitoring

Focus on realistic timelines, minimal business disruption, and measurable success criteria. Include detailed rollback plans for each migration phase.
```

## Best Practices for AI-Generated Documentation

### Validation Prompts

Use these follow-up prompts to validate and improve AI-generated documentation:

1. **Consistency Check**
```
Review the generated feature matrix and API documentation for consistency:
- Are all API endpoints referenced in feature implementation details?
- Do entity relationships match database schema definitions?
- Are feature dependencies logically ordered and achievable?
- Do acceptance criteria align with API specifications?
```

2. **Completeness Review**
```
Analyze the documentation for completeness and gaps:
- Are all CRUD operations documented for each entity?
- Do all features have realistic test coverage targets?
- Are error scenarios properly documented in API specs?
- Are all external integrations identified with proper dependencies?
```

3. **Realism Assessment**
```
Evaluate the realism of estimates and requirements:
- Are effort points reasonable for described feature complexity?
- Do timeline estimates account for testing and integration?
- Are performance requirements achievable with chosen technology?
- Are coverage targets realistic for the team's experience level?
```

### Documentation Quality Guidelines

When using AI to generate project documentation:

1. **Be Specific** - Provide detailed context about your project domain, technology constraints, and team capabilities
2. **Iterate and Refine** - Use follow-up prompts to expand or correct generated content
3. **Validate Dependencies** - Ensure feature dependencies make logical sense and don't create circular references
4. **Review Acceptance Criteria** - Make sure criteria are specific, measurable, and testable
5. **Check Technical Feasibility** - Verify that proposed solutions match your team's technical capabilities
6. **Align with Business Goals** - Ensure generated features support actual business requirements
7. **Consider Maintenance** - Include features for monitoring, logging, and ongoing maintenance

### Example Refinement Prompts

```
Refine the feature matrix to ensure:
- No circular dependencies between features
- Realistic effort estimates based on [TEAM_SIZE] developers with [EXPERIENCE_LEVEL] experience
- All acceptance criteria are testable with specific metrics
- Coverage targets are achievable for the chosen technology stack
- Milestones align with business delivery requirements

Provide updated YAML with explanations for any significant changes.
```

This guide provides comprehensive prompts and patterns for AI agents to generate high-quality project documentation that supports effective development workflows using the automation template.
