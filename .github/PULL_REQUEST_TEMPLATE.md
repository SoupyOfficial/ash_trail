# Pull Request Template

Use this template to help reviewers understand the change, validate generated artifacts, and ensure Copilot-assisted code is reviewed properly.

Title: [type] Short description (e.g. feat: add smoke log mapper)

Description
- What changed and why (1-3 sentences)
- Any migration or breaking changes
- Link to feature_matrix id / issue: [e.g. FM-123]

Type of change
- [ ] feat  - new feature
- [ ] fix   - bug fix
- [ ] docs  - documentation only
- [ ] chore - maintenance / tooling
- [ ] test  - tests only

Checklist (required)
- [ ] I ran the test suite locally: `flutter test` and fixed failures
- [ ] I ran static analysis: `dart analyze` and addressed warnings
- [ ] I regenerated code where applicable: `flutter pub run build_runner build --delete-conflicting-outputs` (or ran `scripts\dev_generate.bat`)
- [ ] I verified generated artifacts are included/changed only when intended and no unrelated generated diffs remain
- [ ] I added/updated unit or widget tests for new behavior (include new tests in this PR)
- [ ] All new strings are covered by docs or localization entries where required
- [ ] I removed any debug/test scaffolding and secrets from the change

Copilot / AI assistance disclosure
- [ ] This PR contains Copilot or AI-assisted code completion
  - If checked, add the label `copilot-assisted` and include a short note on which files or areas were AI generated.
  - Ensure a human reviewer has manually inspected logic, security, and data-handling code.

Review Checklist for Maintainers
- Ensure CI (analysis, tests, codegen validation) passes before merging.
- Confirm generated artifacts match `feature_matrix.yaml` where relevant.
- For Copilot-assisted PRs: require at least one approving review from a maintainer with domain context (do not auto-merge)
- If this PR touches data models or migrations, confirm migration steps and update `docs/data-model.md`.

Automations & Labels
- Add label `automation-monitor` for changes to automation or monitor scripts.
- Add label `requires-migration` if DB/Isar model changes are included.

How to test locally (quick)
1. Fetch deps: `flutter pub get`
2. Run tests: `flutter test`
3. Regenerate code if you changed the matrix: `scripts\dev_generate.bat`

Notes / Additional context
- Add any screenshots, logs, or design links here.

If this PR was created by the GitHub Copilot coding agent, the agent's implementation prompt and summary should be included in the PR description for auditability.
