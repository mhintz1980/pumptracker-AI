#!/bin/bash
# Test for build-roo-code.sh script

# Source test utilities
source "$(dirname "$0")/../helpers/test_utils.sh"

# Test functions
test_roo_code_directory_exists() {
    print_test "Testing roo-code-sparc directory exists"
    
    # Check if roo-code-sparc directory exists
    assert_directory_exists "$SPARC_IDE_ROOT/roo-code-sparc" "roo-code-sparc directory should exist"
    
    # Check if package.json exists
    assert_file_exists "$SPARC_IDE_ROOT/roo-code-sparc/package.json" "package.json should exist in roo-code-sparc directory"
    
    # Check if src directory exists
    assert_directory_exists "$SPARC_IDE_ROOT/roo-code-sparc/src" "src directory should exist in roo-code-sparc"
    
    return 0
}

test_build_script_exists() {
    print_test "Testing build-roo-code.sh script exists"
    
    # Create a test copy of the script
    local test_script=$(create_test_script_copy "$SPARC_IDE_ROOT/scripts/build-roo-code.sh")
    
    # Check if script exists and is executable
    assert_file_exists "$test_script" "build-roo-code.sh script should exist"
    assert_file_executable "$test_script" "build-roo-code.sh script should be executable"
    
    return 0
}

test_package_json_structure() {
    print_test "Testing package.json structure"
    
    local package_json="$SPARC_IDE_ROOT/roo-code-sparc/package.json"
    
    # Check if package.json contains required fields
    assert_json_field_exists "$package_json" ".name" "package.json should have name field"
    assert_json_field_exists "$package_json" ".displayName" "package.json should have displayName field"
    assert_json_field_exists "$package_json" ".description" "package.json should have description field"
    assert_json_field_exists "$package_json" ".version" "package.json should have version field"
    assert_json_field_exists "$package_json" ".engines.vscode" "package.json should have vscode engine requirement"
    
    # Check if package.json contains SPARC-specific configuration
    assert_json_field_contains "$package_json" ".name" "roo-code-sparc" "package.json name should be roo-code-sparc"
    assert_json_field_contains "$package_json" ".displayName" "SPARC IDE" "package.json displayName should mention SPARC IDE"
    
    return 0
}

test_typescript_configuration() {
    print_test "Testing TypeScript configuration"
    
    local tsconfig="$SPARC_IDE_ROOT/roo-code-sparc/tsconfig.json"
    
    # Check if tsconfig.json exists
    assert_file_exists "$tsconfig" "tsconfig.json should exist in roo-code-sparc directory"
    
    # Check if tsconfig.json contains required compiler options
    assert_json_field_exists "$tsconfig" ".compilerOptions.target" "tsconfig.json should have target compiler option"
    assert_json_field_exists "$tsconfig" ".compilerOptions.module" "tsconfig.json should have module compiler option"
    assert_json_field_exists "$tsconfig" ".compilerOptions.outDir" "tsconfig.json should have outDir compiler option"
    
    return 0
}

test_source_files_exist() {
    print_test "Testing source files exist"
    
    local src_dir="$SPARC_IDE_ROOT/roo-code-sparc/src"
    
    # Check if main extension file exists
    assert_file_exists "$src_dir/extension.ts" "extension.ts should exist in src directory"
    
    # Check if provider files exist
    assert_file_exists "$src_dir/providers/rooCodeProvider.ts" "rooCodeProvider.ts should exist"
    assert_file_exists "$src_dir/providers/sparcMethodologyProvider.ts" "sparcMethodologyProvider.ts should exist"
    assert_file_exists "$src_dir/providers/chatWebviewProvider.ts" "chatWebviewProvider.ts should exist"
    
    # Check if utility files exist
    assert_file_exists "$src_dir/utils/apiKeyManager.ts" "apiKeyManager.ts should exist"
    assert_file_exists "$src_dir/utils/configurationManager.ts" "configurationManager.ts should exist"
    
    # Check if client files exist
    assert_file_exists "$src_dir/clients/aiClient.ts" "aiClient.ts should exist"
    
    return 0
}

test_build_script_integration() {
    print_test "Testing build script integration"
    
    # Check if main build script references build-roo-code.sh
    local main_build_script="$SPARC_IDE_ROOT/scripts/build-sparc-ide.sh"
    assert_file_exists "$main_build_script" "Main build script should exist"
    
    # Check if main build script calls build_roo_code function
    assert_file_contains "$main_build_script" "build_roo_code" "Main build script should call build_roo_code function"
    
    # Check if build-roo-code.sh script is referenced
    assert_file_contains "$main_build_script" "build-roo-code.sh" "Main build script should reference build-roo-code.sh"
    
    return 0
}

# Run tests
run_test "Roo Code Directory Exists" test_roo_code_directory_exists
run_test "Build Script Exists" test_build_script_exists
run_test "Package.json Structure" test_package_json_structure
run_test "TypeScript Configuration" test_typescript_configuration
run_test "Source Files Exist" test_source_files_exist
run_test "Build Script Integration" test_build_script_integration

# Exit with success
exit 0