#!/bin/bash

# SPARC IDE - Roo Code Extension Build Script
# This script builds the custom Roo Code extension for SPARC IDE

set -e
set -o nounset

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ROO_CODE_DIR="$PROJECT_ROOT/roo-code-sparc"
EXTENSIONS_DIR="$PROJECT_ROOT/extensions"

echo -e "${BLUE}Building Roo Code extension for SPARC IDE...${NC}"

# Check if roo-code directory exists
if [ ! -d "$ROO_CODE_DIR" ]; then
    echo -e "${RED}Error: Roo Code directory not found at $ROO_CODE_DIR${NC}"
    exit 1
fi

# Change to roo-code directory
cd "$ROO_CODE_DIR"

# Check if package.json exists
if [ ! -f "package.json" ]; then
    echo -e "${RED}Error: package.json not found in $ROO_CODE_DIR${NC}"
    exit 1
fi

echo -e "${YELLOW}Installing dependencies...${NC}"
if command -v npm >/dev/null 2>&1; then
    npm install
else
    echo -e "${RED}Error: npm is not installed${NC}"
    exit 1
fi

echo -e "${YELLOW}Compiling TypeScript...${NC}"
npm run compile

echo -e "${YELLOW}Running linter...${NC}"
npm run lint || echo -e "${YELLOW}Warning: Linting issues found${NC}"

echo -e "${YELLOW}Packaging extension...${NC}"
# Install vsce if not available
if ! command -v vsce >/dev/null 2>&1; then
    echo -e "${YELLOW}Installing vsce globally...${NC}"
    npm install -g vsce
fi

# Create extensions directory if it doesn't exist
mkdir -p "$EXTENSIONS_DIR"

# Package the extension
vsce package --out "$EXTENSIONS_DIR/roo-code-sparc.vsix"

echo -e "${GREEN}✓ Roo Code extension built successfully!${NC}"
echo -e "${BLUE}Extension package: $EXTENSIONS_DIR/roo-code-sparc.vsix${NC}"

# Verify the package
if [ -f "$EXTENSIONS_DIR/roo-code-sparc.vsix" ]; then
    echo -e "${GREEN}✓ Extension package verified${NC}"
    
    # Show package info
    echo -e "${BLUE}Package details:${NC}"
    ls -lh "$EXTENSIONS_DIR/roo-code-sparc.vsix"
else
    echo -e "${RED}Error: Extension package not found${NC}"
    exit 1
fi

echo -e "${GREEN}Roo Code extension build completed successfully!${NC}"