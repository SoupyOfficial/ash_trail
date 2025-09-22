# AI Prompt Templates

Copy-paste ready prompts for generating project documentation with AI assistants.

## 📋 Feature Matrix Templates

### Template 1: Web Application
```
Generate a comprehensive feature matrix for a web application project:

**Project Details:**
- Name: [YOUR_PROJECT_NAME]
- Technology: React frontend + Node.js backend + PostgreSQL database
- Domain: [YOUR_BUSINESS_DOMAIN - e.g., e-commerce, healthcare, finance]
- Target Users: [YOUR_USER_TYPES - e.g., customers, admins, staff]
- Expected Scale: [Small <1k users | Medium 1k-10k | Large 10k+ users]

**Required Features:**
Include these feature categories with 3-5 features each:
- Core: User authentication, data management, core business logic
- UI: Dashboard, forms, navigation, responsive design
- Integration: APIs, third-party services, payment processing
- Performance: Caching, optimization, monitoring
- Infrastructure: Deployment, backup, security

**Specifications:**
- Use Fibonacci effort estimation (1,2,3,5,8,13,21)
- Include realistic dependencies between features
- Set coverage targets: 85% core, 75% UI, 70% integration
- Define clear, testable acceptance criteria
- Plan 3 milestones: MVP, Beta, v1.0

Output as YAML following the feature_matrix.yaml structure.
```

### Template 2: Mobile Application  
```
Create a feature matrix for a mobile application:

**Project Context:**
- Platform: [React Native | Flutter | Native iOS/Android]
- App Type: [Consumer | Business | Internal Tool]
- Key Features: [LIST 5-7 MAIN FEATURES]
- Offline Support: [Yes/No]
- Real-time Features: [Yes/No]

**Mobile-Specific Requirements:**
- Cross-platform compatibility
- Offline data synchronization
- Push notifications
- App store deployment
- Device-specific integrations (camera, GPS, etc.)
- Performance optimization for mobile devices

Include features for app lifecycle management, user onboarding, settings, and analytics.
Set realistic development timelines considering mobile testing requirements.
```

### Template 3: API/Backend Service
```
Generate feature matrix for a backend API service:

**Service Details:**
- API Type: [REST | GraphQL | gRPC]
- Primary Technology: [Python FastAPI | Node.js Express | Java Spring | Go Gin]
- Database: [PostgreSQL | MongoDB | Redis]
- Expected Load: [Requests per second, concurrent users]

**API Features:**
- Authentication and authorization
- Core business entity CRUD operations
- Data validation and serialization
- Rate limiting and throttling
- Monitoring and health checks
- Documentation (OpenAPI/Swagger)

**Quality Requirements:**
- 90%+ test coverage for business logic
- API response time <200ms for 95th percentile
- Comprehensive error handling and logging
- Security best practices (OWASP compliance)

Include scalability considerations and deployment strategies.
```

## 🔧 API Documentation Templates

### REST API Documentation
```
Generate comprehensive REST API documentation for [FEATURE_NAME]:

**API Context:**
- Base URL: https://api.[yourproject].com/v1
- Authentication: Bearer token / API key
- Content-Type: application/json
- Rate Limiting: 1000 requests/hour per user

**Endpoints to Document:**
[LIST YOUR ENDPOINTS - example:]
- GET /users - List users with pagination
- POST /users - Create new user
- GET /users/{id} - Get user details
- PUT /users/{id} - Update user
- DELETE /users/{id} - Delete user

**For Each Endpoint Include:**
- HTTP method and full URL path
- Request parameters (path, query, body)
- Request/response JSON examples with realistic data
- All possible HTTP status codes and meanings
- Error response format and common error scenarios
- Authentication requirements
- Rate limiting information

**Additional Requirements:**
- Include data model schemas (JSON Schema format)
- Provide cURL examples for testing
- Document pagination patterns
- Include filtering and sorting parameters
- Show validation error responses

Format as Markdown compatible with OpenAPI 3.0 specification.
```

### GraphQL Schema Documentation
```
Create GraphQL API documentation and schema:

**Schema Elements:**
- Types: [LIST YOUR TYPES - e.g., User, Product, Order]
- Queries: [LIST READ OPERATIONS]
- Mutations: [LIST WRITE OPERATIONS]  
- Subscriptions: [LIST REAL-TIME OPERATIONS]

**Documentation Requirements:**
1. Complete GraphQL schema definition with field descriptions
2. Example queries with variables for each operation
3. Example mutations with input validation
4. Subscription examples for real-time features
5. Error handling patterns and custom error types
6. Authentication and authorization directives
7. Performance considerations (N+1 queries, DataLoader usage)
8. Client integration examples (Apollo, Relay)

Include realistic sample data and cover edge cases in examples.
```

## 🏗️ Design Document Templates

### UI/UX Design Document
```
Create a comprehensive UI/UX design document for [FEATURE_NAME]:

**User Context:**
- Primary Users: [USER_PERSONAS - e.g., end customers, administrators, power users]
- Device Targets: [Desktop | Mobile | Tablet | All]
- Use Cases: [LIST PRIMARY USER FLOWS]
- Accessibility Level: [WCAG 2.1 AA compliance required]

**Design Deliverables:**

1. **User Journey Mapping**
   - Step-by-step flow for each use case
   - Decision points and alternative paths
   - Error scenarios and recovery options
   - Success states and completion criteria

2. **Interface Specifications**
   - Screen layouts and component hierarchy
   - Responsive breakpoints: Mobile (<768px), Tablet (768-1024px), Desktop (>1024px)
   - Component states: default, hover, active, loading, error, disabled
   - Navigation patterns and information architecture

3. **Interaction Design**  
   - Form validation and real-time feedback
   - Loading states and progress indicators
   - Error messaging and help text
   - Confirmation dialogs for destructive actions

4. **Visual Design System**
   - Color palette (primary, secondary, neutral, semantic colors)
   - Typography scale and hierarchy
   - Spacing system (4px base grid)
   - Icon library and illustration style

5. **Accessibility Features**
   - Keyboard navigation support
   - Screen reader compatibility (ARIA labels)
   - Color contrast ratios (4.5:1 minimum)
   - Focus indicators and tab order

**Performance Requirements:**
- First Contentful Paint < 2s
- Largest Contentful Paint < 4s
- Cumulative Layout Shift < 0.1
- First Input Delay < 100ms

Provide wireframes in ASCII art or Mermaid diagram format.
Include component specifications with props/attributes.
```

### System Architecture Document
```
Generate comprehensive system architecture documentation:

**System Requirements:**
- Architecture Pattern: [Microservices | Monolith | Serverless | Modular Monolith]
- Technology Stack: [YOUR_TECH_STACK]
- Expected Scale: [Daily active users, requests per second]
- Reliability Target: [99.9% uptime | 99.99% uptime]
- Geographic Distribution: [Single region | Multi-region | Global]

**Architecture Documentation:**

1. **System Overview**
   - High-level architecture diagram (use Mermaid syntax)
   - Component boundaries and responsibilities
   - Data flow between components
   - External dependencies and integrations

2. **Component Design**
   - Service breakdown with single responsibilities
   - Interface contracts and API definitions
   - Technology choices with rationale
   - Scalability characteristics and bottlenecks

3. **Data Architecture**
   - Database design and schema overview
   - Data partitioning and sharding strategy
   - Caching layers and invalidation policies
   - Data consistency and transaction boundaries

4. **Infrastructure Design**
   - Deployment architecture (containers, orchestration)
   - Load balancing and auto-scaling policies
   - CDN and edge computing strategy
   - Disaster recovery and backup procedures

5. **Security Architecture**
   - Authentication and authorization flows
   - Data encryption (at rest and in transit)
   - Network security and firewall rules
   - Security monitoring and incident response

6. **Monitoring and Observability**
   - Metrics collection and alerting
   - Distributed tracing setup
   - Log aggregation and analysis
   - Performance monitoring and SLAs

Include Architecture Decision Records (ADRs) for major technical choices.
Provide deployment diagrams and operational runbooks.
```

## 🚀 Complete Project Setup Template

```
Initialize a complete project using the development automation template:

**Project Overview:**
- Project Name: [YOUR_PROJECT_NAME]
- Technology Stack: [PRIMARY_LANGUAGE + FRAMEWORK + DATABASE]
- Business Domain: [e.g., e-commerce, healthcare, fintech, education]
- Target Audience: [end users, businesses, internal teams]
- Team Composition: [NUMBER] [junior/mid/senior] developers
- Project Timeline: [3 months | 6 months | 1 year]
- Budget/Resource Constraints: [any limitations]

**Deliverables Required:**

1. **Feature Matrix** (feature_matrix.yaml)
   - 15-25 features organized into 5 epics
   - Realistic effort estimates using Fibonacci scale
   - Clear dependency mapping
   - Specific, testable acceptance criteria
   - Coverage targets appropriate for component types
   - 3 milestone phases with target dates

2. **API Specifications**
   - OpenAPI 3.0 specification for all REST endpoints
   - GraphQL schema (if applicable)
   - Authentication and authorization patterns
   - Error handling standards
   - Rate limiting policies

3. **Domain Models**
   - Entity definitions with relationships
   - Data validation rules and constraints
   - Business logic specifications
   - Database schema design (ERD + DDL)

4. **Architecture Documentation**
   - System architecture overview with diagrams
   - Technology decision rationales (ADRs)
   - Deployment and infrastructure design
   - Security and compliance requirements
   - Performance and scalability considerations

5. **Development Configuration**
   - automation.config.yaml with language-specific settings
   - CI/CD pipeline configuration
   - Code quality gates and thresholds
   - Testing strategy and coverage requirements

**Quality Criteria:**
- All features must have realistic effort estimates for the specified team
- API documentation must include comprehensive examples and error scenarios
- Architecture must support the expected scale and performance requirements
- Configuration must be ready for immediate development kickoff
- Documentation should be appropriate for [junior/mid/senior] developers

**Special Requirements:**
[Add any specific requirements like compliance, integrations, performance needs]

Generate implementation-ready specifications that can be used immediately for project development.
```

## 🔄 Legacy System Migration Template

```
Create a comprehensive legacy system modernization plan:

**Current System:**
- Legacy Technology: [e.g., COBOL mainframe, PHP 5.6, .NET Framework 2.0]
- Current Functionality: [core features and business processes]
- Known Technical Debt: [performance issues, security vulnerabilities, maintenance challenges]
- User Base: [NUMBER] active users, [NUMBER] transactions/day
- Data Volume: [size and complexity of existing data]
- Integration Points: [systems that connect to legacy system]

**Target System:**
- Modern Technology Stack: [target technologies]
- Architecture Approach: [cloud-native, microservices, serverless]
- Migration Strategy: [Strangler Fig | Big Bang | Gradual | Parallel Run]
- Timeline: [total migration duration]
- Risk Tolerance: [low/medium/high]

**Migration Deliverables:**

1. **Current State Analysis**
   - Complete inventory of legacy system features
   - Technical architecture documentation
   - Data model and integration mapping
   - Performance baseline and bottlenecks
   - Security vulnerabilities assessment

2. **Target State Design**
   - Modern system architecture
   - Feature parity mapping (legacy → modern)
   - Technology stack rationale and ADRs
   - Performance and scalability improvements
   - Security and compliance enhancements

3. **Migration Roadmap**
   - Phase-by-phase migration plan with priorities
   - Risk assessment and mitigation strategies
   - Data migration strategy and validation procedures
   - Integration bridge design for transition period
   - Rollback procedures and checkpoints

4. **Implementation Plan**
   - Resource requirements and team structure
   - Timeline with milestones and dependencies
   - Testing strategy (parallel testing, user acceptance)
   - Training and change management plan
   - Go-live strategy and monitoring

**Success Criteria:**
- Zero data loss during migration
- < 1 hour total downtime across all phases
- Feature parity achieved within [timeframe]
- Performance improvement: [specific metrics]
- User adoption: [acceptance criteria]

**Risk Management:**
- Detailed rollback plans for each phase
- Data backup and recovery procedures
- Business continuity during transition
- User communication and training plan
- Post-migration monitoring and support

Focus on minimal business disruption and measurable success metrics.
Include both technical and business stakeholder considerations.
```

## 📊 Domain-Specific Templates

### E-commerce Platform
```
Generate feature matrix for an e-commerce platform:

**Platform Specifics:**
- Business Model: [B2C | B2B | Marketplace | Subscription]
- Product Types: [Physical | Digital | Services | Mixed]
- Payment Methods: [Credit cards, PayPal, cryptocurrency, etc.]
- Shipping Requirements: [Local | National | International]
- Expected Product Catalog Size: [100s | 1000s | 10000+ items]

**Core E-commerce Features:**
- Product catalog management with categories and search
- Shopping cart and checkout process
- Payment processing and order management
- User accounts and purchase history
- Inventory management and stock tracking
- Admin dashboard and reporting
- Customer service tools (returns, refunds, support tickets)

**Advanced Features:**
- Recommendation engine
- Reviews and ratings system
- Wishlist and favorites
- Multi-language and multi-currency support
- SEO optimization and marketing tools
- Analytics and business intelligence

Include realistic complexity estimates for e-commerce specific challenges.
```

### Healthcare Management System
```
Create feature matrix for healthcare management system:

**System Context:**
- Healthcare Setting: [Hospital | Clinic | Private Practice | Telemedicine]
- User Types: [Patients, Doctors, Nurses, Administrators, Insurance]
- Compliance Requirements: [HIPAA | GDPR | Other regional requirements]
- Integration Needs: [EHR systems, Lab systems, Insurance networks]
- Patient Volume: [Daily patient encounters]

**Healthcare Features:**
- Patient registration and demographics
- Electronic health records (EHR)
- Appointment scheduling and management
- Medical billing and insurance processing
- Prescription management
- Lab results and diagnostic imaging
- Clinical decision support
- Audit logging and compliance reporting

**Special Considerations:**
- All features must include HIPAA compliance measures
- Audit trails for all patient data access
- Data encryption and secure communication
- Role-based access control with granular permissions
- Disaster recovery and data backup procedures
- Integration with external healthcare systems

Set higher test coverage requirements (90%+) for critical patient safety features.
```

## 🛠️ Customization Guide

### Adapting Templates

1. **Replace Placeholder Values**
   - \[YOUR_PROJECT_NAME\] → Your actual project name
   - \[TECHNOLOGY_STACK\] → Your chosen technologies
   - \[BUSINESS_DOMAIN\] → Your specific industry/domain
   - \[USER_TYPES\] → Your actual user personas

2. **Adjust Scope and Scale**
   - Modify feature counts based on project size
   - Adjust effort estimates for your team's experience level
   - Update timeline expectations based on resources
   - Customize coverage targets for your quality requirements

3. **Domain-Specific Modifications**
   - Add industry-specific features and requirements
   - Include relevant compliance and regulatory needs
   - Adjust security and privacy considerations
   - Incorporate domain-specific integrations

### Best Practices

- **Start Simple**: Begin with basic templates and iterate
- **Be Specific**: Provide detailed context for better AI responses
- **Validate Output**: Review generated content for consistency and realism
- **Iterate**: Use follow-up prompts to refine and expand documentation
- **Test Feasibility**: Ensure technical requirements match team capabilities

## 💡 Pro Tips

1. **Combine Templates**: Use multiple templates for complex projects
2. **Version Control**: Track changes to generated documentation
3. **Team Review**: Have team members validate AI-generated content
4. **Regular Updates**: Refresh documentation as project evolves
5. **Learn from Output**: Use AI responses to improve future prompts

These templates provide a solid foundation for generating high-quality project documentation with AI assistance. Customize them for your specific needs and iterate based on results.
