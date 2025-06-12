# CFHub iOS Pull Request

## Summary
<!-- Provide a brief description of your changes -->

## Type of Change
<!-- Check the type of change this PR introduces -->
- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📝 Documentation update
- [ ] 🔧 Refactoring (no functional changes)
- [ ] 🧪 Test improvements
- [ ] 🔌 New integration

## Integration Area
<!-- Check which areas this PR affects -->
- [ ] CFHubCore (Core abstractions)
- [ ] CFHubClient (HTTP client)
- [ ] CFHubApp (SwiftUI application)
- [ ] CFHubCloudflare (Cloudflare integration)
- [ ] CFHubGitHub (GitHub integration)
- [ ] Documentation
- [ ] Scripts/Tooling

## AI Development Compliance
<!-- Confirm compliance with our Claude-first practices -->
- [ ] All new code includes proper AI attribution (`🤖 Generated with [Claude Code](https://claude.ai/code)`)
- [ ] Co-authorship attribution included where applicable (`Co-Authored-By: Claude <noreply@anthropic.com>`)
- [ ] Changes follow established architectural patterns
- [ ] Integration-first architecture maintained (if applicable)

## Quality Gates
<!-- Confirm all quality requirements are met -->
- [ ] `swift build` passes successfully
- [ ] `swift test` passes with 95%+ coverage
- [ ] `./scripts/validate-standards.sh` passes
- [ ] `./scripts/lint.sh` passes (SwiftLint compliance)
- [ ] No hardcoded secrets or credentials
- [ ] Swift 6 concurrency compliance maintained

## Testing
<!-- Describe your testing approach -->
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated (if applicable)
- [ ] Manual testing completed
- [ ] Error handling tested

### Test Coverage
<!-- Provide test coverage information -->
- **New Code Coverage**: __%
- **Overall Coverage**: __%

## Security Considerations
<!-- Address any security implications -->
- [ ] No credentials stored in client code
- [ ] Proxy authentication pattern followed
- [ ] Input validation implemented
- [ ] Error messages don't leak sensitive information

## Breaking Changes
<!-- If this is a breaking change, describe the impact -->
<!-- What steps are needed for users to migrate? -->

## Related Issues
<!-- Link to related issues -->
Fixes #<!-- issue number -->
Related to #<!-- issue number -->

## Screenshots/Recordings
<!-- If UI changes, include screenshots or recordings -->

## Deployment Notes
<!-- Any special deployment considerations -->

## Reviewer Checklist
<!-- For reviewers to complete -->
- [ ] Code follows project conventions and patterns
- [ ] AI attribution is properly included
- [ ] Architecture decisions align with integration-first principles
- [ ] Security model is maintained
- [ ] Tests are comprehensive and passing
- [ ] Documentation is updated (if needed)

---

**🤖 Generated with [Claude Code](https://claude.ai/code)**

**Co-Authored-By: Claude <noreply@anthropic.com>**