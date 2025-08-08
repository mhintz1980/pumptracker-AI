# PowerShell Test Script for Roo Code Setup
# This script tests the custom Roo Code extension setup for SPARC IDE

param(
    [switch]$Verbose
)

# Configuration
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$RooCodeDir = Join-Path $ProjectRoot "roo-code-sparc"
$TestResults = @()

# Helper function to add test result
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

Write-Host "=== Testing Roo Code Directory Structure ===" -ForegroundColor Cyan

# Test 1: Roo Code directory exists
$dirExists = Test-Path $RooCodeDir -PathType Container
Add-TestResult "Roo Code directory exists" $dirExists "Directory: $RooCodeDir"

# Test 2: Package.json exists and has correct structure
$packageJsonPath = Join-Path $RooCodeDir "package.json"
$packageJsonExists = Test-Path $packageJsonPath -PathType Leaf
Add-TestResult "package.json exists" $packageJsonExists

if ($packageJsonExists) {
    try {
        $packageJson = Get-Content $packageJsonPath | ConvertFrom-Json
        
        $hasName = $null -ne $packageJson.name
        Add-TestResult "package.json has name field" $hasName
        
        $hasCorrectName = $packageJson.name -eq "roo-code-sparc"
        Add-TestResult "package.json has correct name" $hasCorrectName
        
        $hasSPARCInDisplayName = $packageJson.displayName -like "*SPARC*"
        Add-TestResult "package.json mentions SPARC" $hasSPARCInDisplayName
        
    } catch {
        Add-TestResult "package.json is valid JSON" $false "Parse error"
    }
}

Write-Host "`n=== Testing TypeScript Configuration ===" -ForegroundColor Cyan

# Test 3: TypeScript configuration exists
$tsconfigPath = Join-Path $RooCodeDir "tsconfig.json"
$tsconfigExists = Test-Path $tsconfigPath -PathType Leaf
Add-TestResult "tsconfig.json exists" $tsconfigExists

Write-Host "`n=== Testing Source Files ===" -ForegroundColor Cyan

# Test 4: Source files exist
$srcDir = Join-Path $RooCodeDir "src"
$srcDirExists = Test-Path $srcDir -PathType Container
Add-TestResult "src directory exists" $srcDirExists

if ($srcDirExists) {
    $extensionFile = Join-Path $srcDir "extension.ts"
    $extensionExists = Test-Path $extensionFile -PathType Leaf
    Add-TestResult "extension.ts exists" $extensionExists
    
    $providersDir = Join-Path $srcDir "providers"
    $providersDirExists = Test-Path $providersDir -PathType Container
    Add-TestResult "providers directory exists" $providersDirExists
    
    if ($providersDirExists) {
        $rooCodeProvider = Join-Path $providersDir "rooCodeProvider.ts"
        $rooCodeProviderExists = Test-Path $rooCodeProvider -PathType Leaf
        Add-TestResult "rooCodeProvider.ts exists" $rooCodeProviderExists
        
        $sparcProvider = Join-Path $providersDir "sparcMethodologyProvider.ts"
        $sparcProviderExists = Test-Path $sparcProvider -PathType Leaf
        Add-TestResult "sparcMethodologyProvider.ts exists" $sparcProviderExists
    }
    
    $utilsDir = Join-Path $srcDir "utils"
    $utilsDirExists = Test-Path $utilsDir -PathType Container
    Add-TestResult "utils directory exists" $utilsDirExists
    
    if ($utilsDirExists) {
        $apiKeyManager = Join-Path $utilsDir "apiKeyManager.ts"
        $apiKeyManagerExists = Test-Path $apiKeyManager -PathType Leaf
        Add-TestResult "apiKeyManager.ts exists" $apiKeyManagerExists
    }
}

Write-Host "`n=== Testing Build Script Integration ===" -ForegroundColor Cyan

# Test 5: Build script exists
$buildScript = Join-Path $ProjectRoot "scripts\build-roo-code.sh"
$buildScriptExists = Test-Path $buildScript -PathType Leaf
Add-TestResult "build-roo-code.sh exists" $buildScriptExists

$mainBuildScript = Join-Path $ProjectRoot "scripts\build-sparc-ide.sh"
$mainBuildScriptExists = Test-Path $mainBuildScript -PathType Leaf
Add-TestResult "main build script exists" $mainBuildScriptExists

if ($mainBuildScriptExists) {
    $mainBuildContent = Get-Content $mainBuildScript -Raw
    $hasBuildRooCodeFunction = $mainBuildContent -match "build_roo_code"
    Add-TestResult "main build script calls build_roo_code" $hasBuildRooCodeFunction
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
    Write-Host "`nAll tests passed! The custom Roo Code setup is working correctly." -ForegroundColor Green
    exit 0
}