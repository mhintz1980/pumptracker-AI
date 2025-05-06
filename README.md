# SPARC IDE

SPARC IDE is a customizable, open-source distribution of VSCode built specifically for agentic software development. It integrates Roo Code to enable prompt-driven development, autonomous agent workflows, and AI-native collaboration.

## Features

- **VSCodium Base**: Fork and customize VSCodium as the foundation
  - Support for Linux, macOS, and Windows platforms
  - Custom branding and UI elements
  - MIT-licensed and telemetry-free

- **Roo Code Integration**:
  - Pre-installed Roo Code extension
  - Default configuration for multiple AI models
  - Custom keybindings for AI interactions
  - Support for custom AI modes and workflows

- **SPARC Methodology Support**:
  - Dedicated UI panels for each SPARC phase
  - Templates and workflows for Specification, Pseudocode, Architecture, Refinement, and Completion
  - Progress tracking across SPARC phases
  - Phase-specific AI prompts and tools

- **Multi-Model AI Support**:
  - OpenRouter integration
  - Claude integration
  - GPT-4 integration
  - Gemini integration
  - Custom LLM endpoint configuration

- **AI-Centric Layout**:
  - Left panel: File Explorer + Roo Code
  - Bottom panel: Terminal + Action Logs
  - Right panel: Extensions (GitLens, Prettier)
  - Custom themes (Dracula Pro, Material Theme)

## System Requirements

- **Operating System**:
  - Linux: Ubuntu 20.04+, Debian 11+
  - Windows: Windows 10+
  - macOS: macOS 11+
- **Hardware**:
  - CPU: 4+ cores
  - RAM: 8GB+
  - Storage: 1GB+ free space

## Building from Source

### Prerequisites

- Node.js 16+
- Yarn 1.22+
- Git
- Platform-specific dependencies:
  - Linux: `build-essential`, `libx11-dev`, `libxkbfile-dev`, `libsecret-1-dev`
  - Windows: Visual Studio Build Tools
  - macOS: Xcode Command Line Tools

### Build Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/sparc-ide/sparc-ide.git
   cd sparc-ide
   ```

2. Make the build script executable:
   ```bash
   chmod +x scripts/build-sparc-ide.sh
   ```

3. Run the build script:
   ```bash
   # Auto-detect platform
   ./scripts/build-sparc-ide.sh
   
   # Or specify platform
   ./scripts/build-sparc-ide.sh --platform linux
   ./scripts/build-sparc-ide.sh --platform windows
   ./scripts/build-sparc-ide.sh --platform macos
   ```

4. The build artifacts will be available in the `dist/` directory.

## Installation

### Linux

1. Download the appropriate package for your distribution:
   - DEB package: `sparc-ide_1.0.0_amd64.deb`
   - RPM package: `sparc-ide-1.0.0.x86_64.rpm`

2. Install the package:
   - DEB: `sudo dpkg -i sparc-ide_1.0.0_amd64.deb`
   - RPM: `sudo rpm -i sparc-ide-1.0.0.x86_64.rpm`

3. Launch SPARC IDE from your applications menu or run `sparc-ide` in the terminal.

### Windows

1. Download the Windows installer: `sparc-ide-setup-1.0.0.exe`
2. Run the installer and follow the on-screen instructions.
3. Launch SPARC IDE from the Start menu.

### macOS

1. Download the macOS package: `sparc-ide-1.0.0.dmg`
2. Open the DMG file and drag SPARC IDE to the Applications folder.
3. Launch SPARC IDE from the Applications folder.

## Configuration

### API Key Configuration

To use AI features, you need to configure API keys:

1. Open SPARC IDE.
2. Go to Settings (File > Preferences > Settings).
3. Search for "roo-code.apiKey".
4. Enter your OpenRouter API key.
5. Optionally, configure keys for other AI providers.

### Custom AI Modes

SPARC IDE provides custom AI modes for specific tasks:

- **QA Engineer**: Detect edge cases and write tests
- **Architect**: Design scalable and maintainable systems
- **Code Reviewer**: Identify issues and suggest improvements
- **Documentation Writer**: Create clear and comprehensive documentation

You can create your own custom modes in the settings.

## SPARC Methodology

SPARC IDE implements the SPARC methodology with five phases:

1. **Specification**: Define detailed requirements and acceptance criteria
2. **Pseudocode**: Create implementation pseudocode and logic flow
3. **Architecture**: Design system architecture and component interactions
4. **Refinement**: Implement iterative improvements and testing
5. **Completion**: Finalize documentation, deployment, and maintenance

To switch between phases:

1. Click on the SPARC icon in the activity bar.
2. Select the desired phase from the SPARC panel.
3. Use templates and AI prompts specific to the current phase.

## Keyboard Shortcuts

- `Ctrl+Shift+A`: Open AI chat
- `Ctrl+Shift+I`: Insert AI-generated code
- `Ctrl+Shift+E`: Explain selected code
- `Ctrl+Shift+R`: Refactor selected code
- `Ctrl+Shift+D`: Document selected code
- `Ctrl+Shift+T`: Generate tests for selected code
- `Ctrl+Alt+1-5`: Switch between SPARC phases
- `Ctrl+Alt+T`: Create template for current SPARC phase
- `Ctrl+Alt+A`: Create artifact for current SPARC phase
- `Ctrl+Alt+P`: Show SPARC progress
- `Ctrl+Shift+1-4`: Switch between AI models
- `Ctrl+Shift+Q/S/C/W`: Switch between AI modes

## Contributing

We welcome contributions to SPARC IDE! Please see [CONTRIBUTING.md](docs/CONTRIBUTING.md) for details on how to contribute.

## License

SPARC IDE is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## Acknowledgements

- [VSCodium](https://github.com/VSCodium/vscodium) for providing the base for SPARC IDE
- [Roo Code](https://github.com/RooVeterinaryInc/roo-cline) for the AI integration
- All the open-source projects that make SPARC IDE possible
