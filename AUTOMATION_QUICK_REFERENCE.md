# AshTrail Automation Quick Reference (Generated)

This file is auto-generated from the canonical instruction prompt. Do not edit manually.

## Enhanced AI Prompt Generation
The `start-next-feature` command now generates **production-grade AI Implementation Guides** with:
- 🏗️ **Complete Architecture Context** - Clean Architecture patterns, data flow, tech stack
- 📋 **Comprehensive Requirements** - Acceptance criteria, user stories, technical specs
- 🛠️ **Implementation Strategy** - Phase-by-phase development with code examples
- 🧪 **Testing Templates** - Unit, widget, integration test patterns with >85% coverage
- 🔍 **Quality Checklists** - Pre/post implementation validation, accessibility, performance
- 🚫 **Anti-Pattern Warnings** - Common mistakes and architectural violations
- 📚 **Reference Resources** - Related features, documentation, existing patterns
- ⏱️ **Development Workflow** - Step-by-step process with time estimates and validation

## Output Contract Summary
1. Plan
2. Files to Change
3. Code (full files)
4. Tests
5. Docs diffs / ADR
6. Manual QA steps
7. Performance & Accessibility check
8. Commit Message (conventional)
## Architectural Rules (Abbrev)
1. Layer separation:
	- Domain: entities + pure use cases (no Flutter, no I/O side effects beyond abstractions).
	- Data: repositories, DTOs, mappers, local (Isar) & remote (Firestore/Dio) implementations.
	- Presentation: widgets, controllers/providers, navigation, formatting.
2. No UI → data imports; depend upward by abstractions only.
3. All external effects behind interfaces injected via Riverpod providers.
4. Errors: use sealed `AppFailure` hierarchy – never expose raw exceptions to UI.
5. Serialization only through DTO + mapper; never expose Firestore docs directly to domain/UI.
6. Feature directory pattern: `lib/features/<feature>/{domain,data,presentation,widgets}`.
7. Provider naming: `<Thing>Provider`; keep scopes minimal; avoid provider pyramids by composing use cases.
## Coverage Policy
## Coverage Policy (Consolidated)
Global project (enforced): ≥80% line coverage.
Patch / new or changed lines (enforced): ≥85% line coverage.
Domain layer (aspirational): ≥90% line coverage (flag if below, do not block unless <80%).
Core shared modules (core, telemetry, critical services) target: ≥85%.
Fail fast if patch coverage below threshold or global coverage drops >2% versus previous main baseline (future automation hook).


## Governance Additions
- Instruction hash posted on PRs (automation-governance workflow)
- Docs integrity check blocks drift
- SBOM + license scan (non-strict) produced as artifacts

## Regeneration
python scripts/docs_integrity.py --update-quick-reference
<!-- canonical-section-hashes: json -->
{
  "Architectural Rules": "88869c0f90873f77b890c378efc99cb1efc5eb0ebd3286219e13dafc9cdefcfa",
  "Error Handling Pattern": "3e548abc49517f72d7e520c3695db0b698ee8a89f8ef4353635cdce03780d778"
}
