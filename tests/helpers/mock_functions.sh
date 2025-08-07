#!/bin/bash
# SPARC IDE Mock Functions
# This script provides mock implementations of functions for testing

# Mock print functions
print_header() {
    echo "===== $1 ====="
}

print_info() {
    echo "[INFO] $1"
}

print_success() {
    echo "[SUCCESS] $1"
}

print_error() {
    echo "[ERROR] $1"
}

print_warning() {
    echo "[WARNING] $1"
}

# Mock command functions
check_prerequisites() {
    echo "[INFO] Checking prerequisites..."
    echo "[SUCCESS] All prerequisites are met"
}

download_roo_code() {
    echo "[INFO] Downloading Roo Code extension..."
    echo "[SUCCESS] Roo Code extension downloaded successfully"
}

verify_extension() {
    echo "[INFO] Verifying Roo Code extension..."
    echo "[SUCCESS] Roo Code extension verified successfully"
}

configure_roo_code() {
    echo "[INFO] Configuring Roo Code integration..."
    echo "[SUCCESS] Roo Code integration configured successfully"
}

# Mock build functions
build_sparc_ide() {
    local platform="$1"
    echo "[INFO] Building for $platform..."
    echo "[SUCCESS] SPARC IDE built successfully for $platform"
}

create_packages() {
    local platform="$1"
    case "$platform" in
        linux)
            echo "[INFO] Creating Linux packages..."
            echo "[SUCCESS] Packages created successfully for linux"
            ;;
        windows)
            echo "[INFO] Creating Windows installer..."
            echo "[SUCCESS] Packages created successfully for windows"
            ;;
        macos)
            echo "[INFO] Creating macOS package..."
            echo "[SUCCESS] Packages created successfully for macos"
            ;;
    esac
}

copy_artifacts() {
    local platform="$1"
    case "$platform" in
        linux)
            echo "[INFO] Copying Linux artifacts..."
            ;;
        windows)
            echo "[INFO] Copying Windows artifacts..."
            ;;
        macos)
            echo "[INFO] Copying macOS artifacts..."
            ;;
    esac
    echo "[SUCCESS] Artifacts copied to dist/ directory"
}

# Mock environment variables
export TEMP_DIR="${TEMP_DIR:-/tmp/sparc-ide-test}"
export SCRIPT_DIR="${SCRIPT_DIR:-$(dirname "${BASH_SOURCE[0]}")}"