# PowerShell Test Script for Build Script
# This script tests the build-roo-code.sh script functionality

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$BuildScript = Join-Path $ProjectRoot "scripts\build-roo-code.sh"
$ExtensionsDir = Join-Path $ProjectRoot "extensions"
$TestResults = @()

function Add-TestResult {
    param(
        [string]$TestName,
        [bool]$Passed,
        [string]$Message = ""
    )
    
    $script:TestResults += [PSCustomObject]@{
        Test = $TestName
        Passed = $Passed
        Message = $Message
    }
    
    if ($Passed) {
        Write-Host "PASS: $TestName" -ForegroundColor Green
    } else {
        Write-Host "FAIL: $TestName - $Message" -ForegroundColor Red
    }
}

Write-Host "=== Testing Build Script ===" -ForegroundColor Cyan

# Test 1: Build script exists and is readable
$buildScriptExists = Test-Path $BuildScript -PathType Leaf
Add-TestResult "build-roo-code.sh exists" $buildScriptExists

if ($buildScriptExists) {
    # Test 2: Build script contains expected content
    $buildScriptContent = Get-Content $BuildScript -Raw
    
    $hasShebang = $buildScriptContent -match "^#!/bin/bash"
    Add-TestResult "Build script has bash shebang" $hasShebang
    
    $hasRooCodeDir = $buildScriptContent -match "roo-code-sparc"
    Add-TestResult "Build script references roo-code-sparc directory" $hasRooCodeDir
    
    $hasNpmInstall = $buildScriptContent -match "npm install"
    Add-TestResult "Build script runs npm install" $hasNpmInstall
    
    $hasNpmCompile = $buildScriptContent -match "npm run compile"
    Add-TestResult "Build script runs npm compile" $hasNpmCompile
    
    $hasVscePackage = $buildScriptContent -match "vsce package"
    Add-TestResult "Build script packages extension" $hasVscePackage
    
    $hasExtensionsDir = $buildScriptContent -match "extensions"
    Add-TestResult "Build script outputs to extensions directory" $hasExtensionsDir
}

# Test 3: Extensions directory exists (should be created by build process)
$extensionsDirExists = Test-Path $ExtensionsDir -PathType Container
Add-TestResult "Extensions directory exists" $extensionsDirExists

# Test 4: Check if VSIX would be copied to extensions directory
if ($extensionsDirExists) {
    $vsixInExtensions = Get-ChildItem -Path $ExtensionsDir -Filter "*.vsix" -ErrorAction SilentlyContinue
    $hasVsixInExtensions = $vsixInExtensions.Count -gt 0
    Add-TestResult "VSIX files present in extensions directory" $hasVsixInExtensions "Found $($vsixInExtensions.Count) VSIX files"
}

Write-Host "`n=== Test Summary ===" -ForegroundColor Cyan

$totalTests = $TestResults.Count
$passedTests = ($TestResults | Where-Object { $_.Passed }).Count
$failedTests = $totalTests - $passedTests

Write-Host "Total Tests: $totalTests" -ForegroundColor White
Write-Host "Passed: $passedTests" -ForegroundColor Green
Write-Host "Failed: $failedTests" -ForegroundColor Red

if ($failedTests -gt 0) {
    Write-Host "`nFailed Tests:" -ForegroundColor Red
    $TestResults | Where-Object { -not $_.Passed } | ForEach-Object {
        Write-Host "  - $($_.Test): $($_.Message)" -ForegroundColor Red
    }
    exit 1
} else {
    Write-Host "`nAll build script tests passed!" -ForegroundColor Green
    exit 0
}