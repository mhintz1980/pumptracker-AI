# PowerShell Script to Run All Roo Code Tests
# This script runs all tests related to the custom Roo Code setup

$TestDir = $PSScriptRoot
$AllTestsPassed = $true

Write-Host "=== SPARC IDE Roo Code Test Suite ===" -ForegroundColor Magenta
Write-Host "Running comprehensive tests for custom Roo Code extension..." -ForegroundColor White

# Test 1: Setup Tests
Write-Host "`n--- Running Setup Tests ---" -ForegroundColor Yellow
$setupResult = & powershell -ExecutionPolicy Bypass -File "$TestDir\test-roo-code-setup.ps1"
if ($LASTEXITCODE -ne 0) {
    $AllTestsPassed = $false
    Write-Host "Setup tests FAILED" -ForegroundColor Red
} else {
    Write-Host "Setup tests PASSED" -ForegroundColor Green
}

# Test 2: Build Tests
Write-Host "`n--- Running Build Tests ---" -ForegroundColor Yellow
$buildResult = & powershell -ExecutionPolicy Bypass -File "$TestDir\test-extension-build.ps1"
if ($LASTEXITCODE -ne 0) {
    $AllTestsPassed = $false
    Write-Host "Build tests FAILED" -ForegroundColor Red
} else {
    Write-Host "Build tests PASSED" -ForegroundColor Green
}

# Test 3: Build Script Tests
Write-Host "`n--- Running Build Script Tests ---" -ForegroundColor Yellow
$scriptResult = & powershell -ExecutionPolicy Bypass -File "$TestDir\test-build-script.ps1"
if ($LASTEXITCODE -ne 0) {
    $AllTestsPassed = $false
    Write-Host "Build script tests FAILED" -ForegroundColor Red
} else {
    Write-Host "Build script tests PASSED" -ForegroundColor Green
}

# Final Summary
Write-Host "`n=== FINAL TEST SUMMARY ===" -ForegroundColor Magenta

if ($AllTestsPassed) {
    Write-Host "ALL TESTS PASSED!" -ForegroundColor Green
    Write-Host "The custom Roo Code extension for SPARC IDE is working perfectly!" -ForegroundColor Green
    Write-Host "`nWhat was tested:" -ForegroundColor White
    Write-Host "- Directory structure and file organization" -ForegroundColor Green
    Write-Host "- Package.json configuration and metadata" -ForegroundColor Green
    Write-Host "- TypeScript configuration and compilation" -ForegroundColor Green
    Write-Host "- Source code files and architecture" -ForegroundColor Green
    Write-Host "- Build script integration with main build process" -ForegroundColor Green
    Write-Host "- Extension packaging and VSIX creation" -ForegroundColor Green
    Write-Host "- Dependencies installation and management" -ForegroundColor Green
    Write-Host "`nThe extension is ready for integration into SPARC IDE!" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "SOME TESTS FAILED" -ForegroundColor Red
    Write-Host "Please review the test output above and fix any issues." -ForegroundColor Red
    exit 1
}