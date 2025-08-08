# PowerShell Test Script for Extension Build
# This script tests that the Roo Code extension can be built successfully

$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$RooCodeDir = Join-Path $ProjectRoot "roo-code-sparc"
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

Write-Host "=== Testing Extension Build Process ===" -ForegroundColor Cyan

# Test 1: Compiled output exists
$outDir = Join-Path $RooCodeDir "out"
$outDirExists = Test-Path $outDir -PathType Container
Add-TestResult "Compiled output directory exists" $outDirExists

if ($outDirExists) {
    $extensionJs = Join-Path $outDir "extension.js"
    $extensionJsExists = Test-Path $extensionJs -PathType Leaf
    Add-TestResult "extension.js compiled successfully" $extensionJsExists
}

# Test 2: VSIX package exists
$vsixFiles = Get-ChildItem -Path $RooCodeDir -Filter "*.vsix"
$vsixExists = $vsixFiles.Count -gt 0
Add-TestResult "VSIX package created" $vsixExists

if ($vsixExists) {
    $vsixFile = $vsixFiles[0]
    $vsixSize = $vsixFile.Length
    $vsixSizeOk = $vsixSize -gt 100KB  # Should be reasonably sized
    Add-TestResult "VSIX package has reasonable size" $vsixSizeOk "Size: $([math]::Round($vsixSize/1KB, 2)) KB"
}

# Test 3: Node modules installed
$nodeModulesDir = Join-Path $RooCodeDir "node_modules"
$nodeModulesExists = Test-Path $nodeModulesDir -PathType Container
Add-TestResult "Node modules installed" $nodeModulesExists

# Test 4: Package lock exists (indicates successful npm install)
$packageLock = Join-Path $RooCodeDir "package-lock.json"
$packageLockExists = Test-Path $packageLock -PathType Leaf
Add-TestResult "package-lock.json exists" $packageLockExists

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
    Write-Host "`nAll build tests passed! The extension builds successfully." -ForegroundColor Green
    exit 0
}