# AI-Assisted Development Quick Start Guide

## 🚀 Welcome to AshTrail AI Development

This guide will help you effectively use AI assistance to develop AshTrail features. The workspace is now configured for industry-standard AI-assisted development.

## 📋 Prerequisites

### Required Tools
- **GitHub CLI**: For issue management
- **Flutter SDK**: For development and testing  
- **VS Code**: Primary development environment
- **Git**: Version control

### Setup Verification
```bash
# Check your setup
python scripts/dev_assistant.py health

# See project status
python scripts/dev_assistant.py status

# List next features
python scripts/dev_assistant.py features
```

## 🎯 How to Request Feature Development

### Step 1: Choose a Feature
Use the development assistant to see what's next:
```bash
python scripts/dev_assistant.py features
```

### Step 2: Create a GitHub Issue
1. Go to GitHub Issues → New Issue
2. Choose "Feature Request" template
3. Fill out the template with details
4. Assign appropriate labels (P0/P1/P2/P3, epic)

### Step 3: Trigger AI Implementation
In your request to me, use this format:

```
#github-pull-request_copilot-coding-agent

Title: [FEATURE] App Shell & Navigation Scaffold
Epic: UI
Priority: P0

Description:
Implement the core app shell with bottom navigation, top app bar, and routing scaffold. This provides the foundation for all other UI features.

Acceptance Criteria:
- [ ] Bottom navigation with 4 main tabs (Dashboard, Log, Insights, Settings)
- [ ] Top app bar with title and context actions
- [ ] Responsive design for mobile and tablet
- [ ] Smooth transitions between tabs
- [ ] Deep link support for all routes
- [ ] Offline state indicators
- [ ] Loading states during navigation
- [ ] Error boundaries for route failures
- [ ] Accessibility support (semantics, screen reader)
- [ ] Theme-aware styling
- [ ] Test coverage ≥80%
- [ ] Documentation updated

Technical Requirements:
- Use go_router for typed routing
- Implement with Clean Architecture patterns
- Riverpod for state management
- Material 3 design system
- Responsive breakpoints for tablet/desktop

Implementation Notes:
Focus on the shell structure first, then add routing. Each tab should be a separate feature that can be developed independently.
```

### Step 4: AI Development Process
When you provide the trigger, I will:

1. **Analyze**: Review requirements and existing code
2. **Plan**: Propose architecture and approach
3. **Implement**: Create code following established patterns
4. **Test**: Write comprehensive tests
5. **Document**: Update relevant documentation
6. **Integrate**: Create PR and update GitHub issues

## 📖 Available Documentation

### Core References
- `docs/requirements/functional-requirements.md` - Feature requirements
- `.github/instructions/development-workflow.md` - AI development process
- `.github/instructions/testing-standards.md` - Testing requirements
- `.github/instructions/feature-request-template.md` - How to request features

### Architecture Guides
- `.github/instructions/code-generation.instructions.md` - Code generation rules
- `.github/instructions/instruction-prompt.instructions.md` - AI instructions
- `.github/copilot-instructions.md` - Copilot context

## 🔧 Common Workflows

### Feature Development
```bash
# 1. Check what's next
python scripts/dev_assistant.py features

# 2. Request feature using trigger format above
python scripts/dev_assistant.py start-next-feature

# 3. Review and approve the AI's implementation plan

# 4. Monitor progress and provide feedback
python scripts/dev_assistant.py status

# 5. Test and merge when ready
python scripts/dev_assistant.py finalize-feature
```

### Bug Fixes
```bash
# 1. Create bug report issue using template

# 2. Use bug fix trigger:
#github-pull-request_copilot-coding-agent

Title: [BUG] Session timer not updating in real-time
Priority: High
...

# 3. Follow same process as features
```

### Code Reviews
```bash
# Check current status
python scripts/dev_assistant.py status

# Review PR changes
git diff origin/main

# Test changes
flutter test
flutter analyze
```

## 📊 Progress Tracking

### Project Health
```bash
# Get comprehensive status
python scripts/dev_assistant.py status

# Just health check
python scripts/dev_assistant.py health

```

### Key Metrics
- **Features**: Track planned → in progress → completed
- **Code Quality**: Maintain 80%+ test coverage
- **Architecture**: Follow Clean Architecture patterns
- **Performance**: Meet performance budgets

## 💡 Best Practices

### Requesting Features
1. **Be Specific**: Clear acceptance criteria and technical requirements
2. **Prioritize**: Use P0/P1/P2/P3 priority levels appropriately
3. **Context**: Link to related issues and provide background
4. **Test Focus**: Specify what testing is needed

### AI Interaction
1. **Review Plans**: Always review AI's proposed approach before implementation
2. **Provide Feedback**: Give specific feedback on AI's work
3. **Ask Questions**: Request clarification when needed
4. **Iterative**: Work in small, reviewable increments

### Quality Gates
- All code must pass tests and static analysis
- Documentation must be updated with changes
- Architecture patterns must be followed
- GitHub issues must be kept current

## 🚨 Troubleshooting

### Common Issues

**Flutter not found**
```bash
# Install Flutter and add to PATH
# Verify with: flutter doctor
```

**Uncommitted changes**
```bash
# Commit changes before development
git add .
git commit -m "chore: save work before feature development"
```

**Test failures**
```bash
# Run tests to see failures
flutter test

# Check analysis
flutter analyze

# Fix issues and re-run
```

### Getting Help
1. Check health status: `python scripts/dev_assistant.py health`
2. Review documentation in `.github/instructions/`
3. Ask specific questions with context
4. Provide error messages and logs

## 🎉 Ready to Start!

You now have a professional AI-assisted development workspace. Use the trigger format above to request features, and I'll handle the implementation following industry best practices.

**Next Steps:**
1. Run `python scripts/dev_assistant.py features` to see what's available
2. Choose a P0 feature to start with
3. Use the trigger format to request implementation
4. Review and iterate on the AI's work

Happy coding! 🚀
