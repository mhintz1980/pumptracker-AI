# SPARC IDE Project Structure

## Root Directory Organization

```
/
├── .kiro/                    # Kiro IDE configuration and steering rules
├── branding/                 # Custom branding assets (icons, splash screens)
├── build/                    # Build artifacts and temporary files
├── docs/                     # Comprehensive documentation
├── extensions/               # Extension packages (.vsix files)
├── package/                  # Distribution packages and manifests
├── plans/                    # SPARC methodology project plans
├── scripts/                  # Build and setup automation scripts
├── src/                      # Source code and configurations
├── test-reports/             # Generated test reports
├── tests/                    # Test suites and test utilities
└── vscodium/                 # VSCodium source code and patches
```

## Source Code Structure (`src/`)

- **`config/`**: IDE configuration files (keybindings, settings, product config)
- **`mcp/`**: Model Context Protocol server implementation
- **`sparc-workflow/`**: SPARC methodology templates and configuration
- **`themes/`**: Custom UI themes (Dracula Pro, Material Theme)

## Scripts Organization (`scripts/`)

- **Setup**: `setup-sparc-ide.sh`, `setup-build-environment.sh`
- **Build**: `build-sparc-ide.sh`, `package-sparc-ide.sh`
- **Branding**: `apply-branding.sh`, `prepare-windows-branding.sh`
- **Security**: `verify-security.sh`, `generate-admin-password.sh`
- **Platform-specific**: `windows/` subdirectory for Windows-specific scripts

## Testing Structure (`tests/`)

- **`branding/`**: Branding modification tests
- **`build-scripts/`**: Build script validation tests
- **`roo-code/`**: Roo Code integration tests
- **`ui-config/`**: UI configuration tests
- **`helpers/`**: Shared test utilities

## Documentation Structure (`docs/`)

- **Architecture**: `1_architecture_overview.md`
- **Setup**: `2_installation_setup.md`, `installation-guide.md`
- **Usage**: `3_user_guide.md`, `user-guide.md`
- **Development**: `4_developer_guide.md`, `developer-guide.md`
- **Maintenance**: `5_troubleshooting_guide.md`, `6_security_guide.md`

## Configuration Conventions

- **Environment files**: Use `.env.example` templates, never commit actual `.env`
- **JSON configs**: Use consistent indentation (2 spaces)
- **Shell scripts**: Include security headers (`set -e`, `set -o nounset`)
- **Permissions**: Executable scripts in `scripts/`, secure permissions for certificates

## File Naming Conventions

- **Scripts**: kebab-case with `.sh` extension
- **Configs**: lowercase with appropriate extension (`.json`, `.md`)
- **Documentation**: numbered prefixes for ordered reading
- **Tests**: descriptive names matching component being tested

## Security Considerations

- **Certificates**: Store in `certs/` with 600 permissions
- **Secrets**: Use environment variables, never hardcode
- **Extensions**: Require signature verification in `extensions/verification/`
- **Build artifacts**: Generate checksums and signatures in `dist/`
