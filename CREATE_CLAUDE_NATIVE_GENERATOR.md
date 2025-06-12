# Instructions: Create Universal Claude-Native Project Generator

> **Mission**: Build a universal tool that generates Claude-native projects in any programming language, following proven cloudflare-hub and CFHub iOS patterns.

## 🎯 Project Overview

Create a tool (npm package or Homebrew formula) that scaffolds projects optimized for AI-assisted development across any programming language. The tool should embed the architectural patterns proven successful in cloudflare-hub and CFHub iOS.

## 📋 Implementation Requirements

### Tool Choice Decision

**Option 1: NPM Package** (`create-claude-project`)
- ✅ Cross-platform, widely adopted
- ✅ Easy distribution and updates
- ✅ Rich ecosystem for templates
- ✅ Works with any programming language

**Option 2: Homebrew Formula** (`claude-create`)
- ✅ Native macOS/Linux experience
- ✅ Better for system-level tools
- ❌ Limited to Unix-like systems

**Recommendation**: Start with NPM package for broader reach, add Homebrew later.

## 🏗️ Core Architecture

### Generator Structure
```
create-claude-project/
├── src/
│   ├── cli.ts                   # Command-line interface
│   ├── generator.ts             # Main generator logic
│   ├── templates/               # Language-specific templates
│   │   ├── swift/              # Swift/iOS projects
│   │   ├── typescript/         # Node.js/TypeScript projects
│   │   ├── python/             # Python projects
│   │   ├── go/                 # Go projects
│   │   ├── java/               # Java projects
│   │   └── rust/               # Rust projects
│   ├── patterns/               # Universal patterns
│   │   ├── integration-first/  # Integration-first architecture
│   │   ├── ai-attribution/     # AI development workflow
│   │   └── quality-gates/      # Quality enforcement
│   └── utils/
│       ├── fileUtils.ts
│       ├── templateEngine.ts
│       └── validation.ts
├── templates/                   # Template files
├── tests/
├── package.json
└── README.md
```

## 🎨 Universal Templates

### 1. Core Template Structure
Every generated project should have:

```
<project-name>/
├── <source-dir>/               # src/, Sources/, lib/, etc.
│   ├── <ProjectName>Core/      # Core abstractions
│   ├── <ProjectName>Client/    # HTTP/API client  
│   ├── <ProjectName>App/       # Application layer
│   └── integrations/           # Self-contained integrations
├── <test-dir>/                 # Language-specific test directory
├── docs/
│   ├── architecture.md
│   ├── getting-started.md
│   └── security.md
├── scripts/
│   ├── validate-standards.sh
│   ├── lint.sh
│   ├── setup-ai-workflow.sh
│   └── pre-commit-hook.sh
├── .gitmessage                 # AI attribution template
├── CLAUDE.md                   # AI development guidelines
├── README.md
└── <build-config>              # package.json, Package.swift, etc.
```

### 2. Language-Specific Mappings
```typescript
const LANGUAGE_MAPPINGS = {
  swift: {
    sourceDir: 'Sources',
    testDir: 'Tests',
    buildConfig: 'Package.swift',
    extension: '.swift',
    testFramework: 'swift-testing'
  },
  typescript: {
    sourceDir: 'src',
    testDir: 'tests',
    buildConfig: 'package.json',
    extension: '.ts',
    testFramework: 'vitest'
  },
  python: {
    sourceDir: 'src',
    testDir: 'tests',
    buildConfig: 'pyproject.toml',
    extension: '.py',
    testFramework: 'pytest'
  },
  go: {
    sourceDir: '.',
    testDir: '.',
    buildConfig: 'go.mod',
    extension: '.go',
    testFramework: 'testing'
  },
  java: {
    sourceDir: 'src/main/java',
    testDir: 'src/test/java',
    buildConfig: 'pom.xml',
    extension: '.java',
    testFramework: 'junit'
  },
  rust: {
    sourceDir: 'src',
    testDir: 'tests',
    buildConfig: 'Cargo.toml',
    extension: '.rs',
    testFramework: 'cargo test'
  }
}
```

## 📝 Template Files to Create

### 1. Universal Files (Language-Agnostic)

#### CLAUDE.md Template
```markdown
# <ProjectName> - AI Development Guidelines

## AI Assistance Overview
This project follows proven Claude-native patterns with **85-90% AI-generated code** and rigorous human oversight.

## Human vs AI Responsibilities
### 👨‍💻 Human Responsibilities
- Strategic architecture decisions
- Security review and design
- Requirements definition and acceptance criteria
- Code review and quality gates
- Integration testing and deployment

### 🤖 AI Responsibilities  
- Implementation following established patterns
- Test generation with high coverage
- Documentation and code comments
- Boilerplate and repetitive code
- Error handling and edge cases

## Attribution Requirements
All AI-assisted work must include:
```
🤖 Generated with [Claude Code](https://claude.ai/code)
Co-Authored-By: Claude <noreply@anthropic.com>
```

## Quality Standards
- 100% build success requirement
- 95%+ test coverage
- Linting compliance
- Integration-first architecture compliance
- Security validation

## Development Workflow
[Include language-specific workflow details]
```

#### .gitmessage Template
```
# <ProjectName> Commit Template
# Following Claude-native development standards
#
# Format: <type>(<scope>): <subject>
#
# Types: feat, fix, docs, style, refactor, test, chore
# Scope: integration, core, client, app, etc.
#
# Example:
# feat(core): implement integration registry pattern
#
# Extended description (optional)
#
# 🤖 Generated with [Claude Code](https://claude.ai/code)
#
# Co-Authored-By: Claude <noreply@anthropic.com>
```

#### README.md Template
```markdown
# <ProjectName>

> **<Project Description>** - Claude-native architecture with integration-first design

[![AI-Assisted](https://img.shields.io/badge/AI-Assisted-purple.svg)](https://claude.ai/code)
[![<Language>](https://img.shields.io/badge/<Language>-<Version>-<color>.svg)](<language-url>)

## Architecture

### Integration-First Design
Following proven patterns, each service integration is completely self-contained:

```
<source-dir>/
├── <ProjectName>Core/          # Core abstractions
├── <ProjectName>Client/        # HTTP client
└── integrations/
    ├── <Service1>Integration/  # Complete <Service1> integration
    └── <Service2>Integration/  # Complete <Service2> integration
```

### Key Principles
- 🔒 **Security-First**: Never store credentials in client applications
- 🌐 **Cloud-Native**: Ephemeral environments and real-time monitoring
- 🎯 **Quality-First**: Zero tolerance for technical debt
- 🤖 **AI-Assisted**: 85-90% AI-generated with human oversight

## Quick Start

### Prerequisites
[Language-specific prerequisites]

### Installation
[Language-specific installation steps]

### Development
```bash
# Run quality gates
./scripts/validate-standards.sh

# Setup AI workflow
./scripts/setup-ai-workflow.sh
```

---

**🤖 Generated with [Claude Code](https://claude.ai/code)**

**Co-Authored-By: Claude <noreply@anthropic.com>**
```

### 2. Language-Specific Core Files

#### Integration Interface Template
Each language needs a core integration interface/protocol:

**TypeScript**:
```typescript
export interface Integration {
  readonly identifier: string;
  readonly displayName: string;
  readonly version: string;
  readonly requiredPermissions: Permission[];
  
  getActualState(): Promise<Resource[]>;
  plan(desired: Resource[]): Promise<Action[]>;
  apply(actions: Action[]): Promise<ApplyResult>;
  rollback(): Promise<void>;
  healthCheck(): Promise<HealthStatus>;
}
```

**Swift**:
```swift
public protocol Integration: Actor {
    static var identifier: String { get }
    static var displayName: String { get }
    static var version: String { get }
    static var requiredPermissions: [Permission] { get }
    
    func getActualState() async throws -> [Resource]
    func plan(desired: [Resource]) async throws -> [Action]
    func apply(actions: [Action]) async throws -> ApplyResult
    func rollback() async throws
    func healthCheck() async throws -> HealthStatus
}
```

**Python**:
```python
from abc import ABC, abstractmethod
from typing import List

class Integration(ABC):
    @property
    @abstractmethod
    def identifier(self) -> str: ...
    
    @property  
    @abstractmethod
    def display_name(self) -> str: ...
    
    @abstractmethod
    async def get_actual_state(self) -> List[Resource]: ...
    
    @abstractmethod
    async def plan(self, desired: List[Resource]) -> List[Action]: ...
    
    @abstractmethod
    async def apply(self, actions: List[Action]) -> ApplyResult: ...
```

### 3. Quality Gate Scripts

#### validate-standards.sh Template
```bash
#!/bin/bash
# Universal Quality Gates for Claude-Native Projects

set -euo pipefail

# Language-specific build command
case "<LANGUAGE>" in
  "swift")
    BUILD_CMD="swift build"
    TEST_CMD="swift test"
    ;;
  "typescript")
    BUILD_CMD="npm run build"
    TEST_CMD="npm test"
    ;;
  "python")
    BUILD_CMD="python -m build"
    TEST_CMD="pytest"
    ;;
  # Add more languages...
esac

echo "🚀 Starting <ProjectName> Quality Gates"

# 1. Build Check
echo "📦 Building project..."
if $BUILD_CMD; then
    echo "✅ Build successful"
else
    echo "❌ Build failed"
    exit 1
fi

# 2. Test Check  
echo "🧪 Running tests..."
if $TEST_CMD; then
    echo "✅ All tests pass"
else
    echo "❌ Tests failed"
    exit 1
fi

# 3. AI Attribution Check
echo "🤖 Checking AI attribution..."
MISSING_ATTRIBUTION=$(find <SOURCE_DIR> -name "*<EXTENSION>" ! -exec grep -l "🤖 Generated with" {} \; | wc -l)
if [ "$MISSING_ATTRIBUTION" -eq 0 ]; then
    echo "✅ AI attribution complete"
else
    echo "❌ $MISSING_ATTRIBUTION files missing AI attribution"
    exit 1
fi

# 4. Integration Architecture Check
echo "🏗️ Validating integration architecture..."
INTEGRATION_COUNT=$(find <SOURCE_DIR>/integrations -maxdepth 1 -type d -name "*Integration*" | wc -l)
if [ "$INTEGRATION_COUNT" -gt 0 ]; then
    echo "✅ Integration-first architecture detected ($INTEGRATION_COUNT integrations)"
else
    echo "⚠️ No integrations found"
fi

echo "🎉 All quality gates passed!"
```

## 🚀 CLI Implementation

### Command Structure
```bash
# Basic usage
npx create-claude-project my-app

# With language specification
npx create-claude-project my-app --language typescript

# With integration templates
npx create-claude-project my-app --language swift --integrations github,cloudflare

# With custom template
npx create-claude-project my-app --template custom-template
```

### CLI Flow
1. **Project Name Input**: Validate and sanitize project name
2. **Language Selection**: Choose from supported languages
3. **Integration Selection**: Choose initial integrations to scaffold
4. **Template Generation**: Create project structure
5. **Dependency Installation**: Install language-specific dependencies
6. **Git Initialization**: Setup git with AI workflow
7. **Success Message**: Next steps and development instructions

### Example CLI Code Structure
```typescript
// src/cli.ts
import { Command } from 'commander';
import { generateProject } from './generator';

const program = new Command();

program
  .name('create-claude-project')
  .description('Generate Claude-native projects in any language')
  .argument('<project-name>', 'Name of the project to create')
  .option('-l, --language <language>', 'Programming language', 'typescript')
  .option('-i, --integrations <integrations>', 'Comma-separated list of integrations')
  .option('-t, --template <template>', 'Custom template to use')
  .action(async (projectName, options) => {
    await generateProject(projectName, options);
  });

program.parse();
```

## 🔧 Generator Implementation

### Core Generator Logic
```typescript
// src/generator.ts
export async function generateProject(
  projectName: string, 
  options: GeneratorOptions
): Promise<void> {
  const config = await resolveConfiguration(projectName, options);
  
  // 1. Create project directory
  await createProjectDirectory(config.projectPath);
  
  // 2. Generate core structure
  await generateCoreStructure(config);
  
  // 3. Generate language-specific files
  await generateLanguageFiles(config);
  
  // 4. Generate integration templates
  await generateIntegrations(config);
  
  // 5. Setup development environment
  await setupDevelopmentEnvironment(config);
  
  // 6. Initialize git with AI workflow
  await initializeGitWithAIWorkflow(config);
  
  // 7. Install dependencies
  await installDependencies(config);
  
  console.log(`✅ Created Claude-native ${config.language} project: ${projectName}`);
  console.log(`📁 Location: ${config.projectPath}`);
  console.log(`📖 Next steps: cd ${projectName} && ./scripts/setup-ai-workflow.sh`);
}
```

## 📦 Package Configuration

### package.json
```json
{
  "name": "create-claude-project",
  "version": "1.0.0",
  "description": "Universal generator for Claude-native projects",
  "bin": {
    "create-claude-project": "./dist/cli.js"
  },
  "keywords": [
    "ai-assisted",
    "claude",
    "project-generator", 
    "scaffold",
    "integration-first",
    "swift",
    "typescript",
    "python",
    "go"
  ],
  "dependencies": {
    "commander": "^11.0.0",
    "inquirer": "^9.0.0",
    "mustache": "^4.2.0",
    "chalk": "^4.1.2"
  }
}
```

## 🧪 Testing Strategy

### Test Structure
```
tests/
├── generators/
│   ├── swift.test.ts
│   ├── typescript.test.ts
│   └── python.test.ts
├── templates/
│   ├── core-files.test.ts
│   └── integration-first.test.ts
├── utils/
│   └── file-operations.test.ts
└── e2e/
    └── full-generation.test.ts
```

### E2E Test Example
```typescript
describe('Swift Project Generation', () => {
  it('should generate complete Swift project with integrations', async () => {
    const tempDir = await createTempDirectory();
    
    await generateProject('TestApp', {
      language: 'swift',
      integrations: ['github', 'cloudflare'],
      outputPath: tempDir
    });
    
    // Verify structure
    expect(await fileExists(path.join(tempDir, 'TestApp/Package.swift'))).toBe(true);
    expect(await fileExists(path.join(tempDir, 'TestApp/Sources/TestAppCore'))).toBe(true);
    expect(await fileExists(path.join(tempDir, 'TestApp/Sources/integrations/GitHubIntegration'))).toBe(true);
    
    // Verify AI attribution
    const coreFile = await readFile(path.join(tempDir, 'TestApp/Sources/TestAppCore/Integration.swift'));
    expect(coreFile).toContain('🤖 Generated with [Claude Code]');
    
    // Verify build works
    const buildResult = await exec('swift build', { cwd: path.join(tempDir, 'TestApp') });
    expect(buildResult.exitCode).toBe(0);
  });
});
```

## 📚 Documentation Requirements

### README for the Generator
Include:
1. **Installation instructions** for the generator tool
2. **Usage examples** for different languages
3. **Template customization** guide
4. **Contributing guidelines** for adding new languages
5. **Architecture overview** of the generator itself

### Generated Project Documentation
Every generated project should include:
1. **architecture.md**: Technical architecture explanation
2. **getting-started.md**: Quick start guide
3. **security.md**: Security model and best practices  
4. **CLAUDE.md**: AI development guidelines

## 🚀 Release Strategy

### Phase 1: MVP
- Support TypeScript and Swift
- Basic integration templates (GitHub, Cloudflare)
- Core quality gates
- NPM package distribution

### Phase 2: Language Expansion
- Add Python, Go, Java, Rust support
- More integration templates
- Custom template support
- Homebrew formula

### Phase 3: Advanced Features
- IDE integrations (VS Code extension)
- Cloud deployment templates
- CI/CD pipeline generation
- Community template marketplace

## 💡 Key Success Factors

1. **Pattern Consistency**: Ensure all generated projects follow the same architectural principles
2. **Quality Enforcement**: Automated validation of generated code quality
3. **AI Attribution**: Mandatory and automated AI attribution tracking
4. **Documentation Excellence**: Comprehensive docs for both the tool and generated projects
5. **Community Adoption**: Easy to use, well-documented, and valuable to developers

## 🎯 Final Implementation Notes

### Tool Decision: NPM Package
Create `create-claude-project` as an NPM package for maximum reach and ease of use.

### Priority Languages
1. **TypeScript**: Most popular for CLI tools and web development
2. **Swift**: Mobile-first development, proven with CFHub iOS
3. **Python**: Data science and backend development
4. **Go**: Cloud-native and infrastructure tools

### Integration Templates
Start with proven integrations:
- GitHub (repository management)
- Cloudflare (web infrastructure)  
- AWS (cloud services)
- Generic REST API template

---

**🤖 Generated with [Claude Code](https://claude.ai/code)**

**Co-Authored-By: Claude <noreply@anthropic.com>**