# SPARC IDE Technology Stack

## Build System & Core Technologies

- **Base**: VSCodium (open-source VS Code fork)
- **Runtime**: Electron framework for cross-platform desktop apps
- **Frontend**: TypeScript + React for UI components
- **Build Tools**: Gulp task automation, Yarn package management
- **Extension System**: VS Code Extension API

## AI Integration Stack

- **AI Models**: OpenRouter, Claude, GPT-4, Gemini via REST APIs
- **Context Management**: TypeScript-based conversation handling
- **Prompt Templates**: Handlebars templating system
- **API Security**: Node.js Keytar for secure credential storage

## MCP Server

- **Runtime**: Node.js 20+
- **Framework**: Express.js with CORS, Helmet security
- **Authentication**: JWT tokens, bcrypt password hashing
- **Logging**: Winston logging framework
- **Testing**: Jest unit testing, Supertest integration testing

## Development & Testing

- **Version Control**: Git with GitHub Actions CI/CD
- **Testing**: Jest (unit), Mocha (integration), custom shell script tests
- **Security**: OpenSSL certificate generation, GPG signing
- **Documentation**: Markdown, TypeDoc for code docs

## Common Build Commands

```bash
# Setup environment
./scripts/setup-sparc-ide.sh

# Build for specific platform
./scripts/build-sparc-ide.sh --platform linux|windows|macos

# Run tests
./tests/run-tests.sh

# Start MCP server
cd src/mcp && npm start

# Generate certificates (development)
npm run generate-certs

# Security verification
./scripts/verify-security.sh
```

## Package Management

- **Main**: Yarn for VSCodium dependencies
- **MCP Server**: npm for Node.js dependencies
- **Extensions**: .vsix packages with cryptographic verification

## Security Requirements

- All extensions must have signature verification
- API keys stored securely (never hardcoded)
- HTTPS required for production MCP server
- Regular dependency vulnerability scanning
