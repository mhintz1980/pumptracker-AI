# SPARC IDE - Create Placeholder Branding Assets
# This script creates placeholder branding assets for Windows installer

param(
    [string]$BrandingDir = "branding\windows"
)

# Configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = (Get-Item "$ScriptDir\..").FullName
$WindowsBrandingDir = Join-Path $RootDir $BrandingDir

# Function to write colored output
function Write-ColoredOutput {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$true)]
        [string]$Type
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    
    switch ($Type) {
        "INFO" { Write-Host "[$Timestamp] [INFO] $Message" -ForegroundColor Cyan }
        "SUCCESS" { Write-Host "[$Timestamp] [SUCCESS] $Message" -ForegroundColor Green }
        "ERROR" { Write-Host "[$Timestamp] [ERROR] $Message" -ForegroundColor Red }
        "WARNING" { Write-Host "[$Timestamp] [WARNING] $Message" -ForegroundColor Yellow }
    }
}

# Create directory if it doesn't exist
if (-not (Test-Path $WindowsBrandingDir)) {
    New-Item -ItemType Directory -Path $WindowsBrandingDir -Force | Out-Null
    Write-ColoredOutput "Created Windows branding directory: $WindowsBrandingDir" "INFO"
}

# Create placeholder installer icon (copy from existing icon if available)
$InstallerIconPath = Join-Path $WindowsBrandingDir "sparc-ide-installer.ico"
$AppIconPath = Join-Path $WindowsBrandingDir "sparc-ide.ico"

if ((Test-Path $AppIconPath) -and (-not (Test-Path $InstallerIconPath))) {
    Copy-Item -Path $AppIconPath -Destination $InstallerIconPath -Force
    Write-ColoredOutput "Created placeholder installer icon: sparc-ide-installer.ico" "SUCCESS"
} elseif (-not (Test-Path $InstallerIconPath)) {
    Write-ColoredOutput "No source icon found. Please provide sparc-ide-installer.ico manually." "WARNING"
}

# Create placeholder BMP files using PowerShell graphics
$BannerPath = Join-Path $WindowsBrandingDir "sparc-ide-installer-banner.bmp"
$DialogPath = Join-Path $WindowsBrandingDir "sparc-ide-installer-dialog.bmp"

# Function to create a simple BMP placeholder
function Create-PlaceholderBMP {
    param(
        [string]$FilePath,
        [int]$Width,
        [int]$Height,
        [string]$Text
    )
    
    try {
        # Load System.Drawing assembly
        Add-Type -AssemblyName System.Drawing
        
        # Create bitmap
        $bitmap = New-Object System.Drawing.Bitmap($Width, $Height)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        
        # Set background color (SPARC IDE blue)
        $backgroundColor = [System.Drawing.Color]::FromArgb(42, 165, 245)
        $graphics.Clear($backgroundColor)
        
        # Set text properties
        $font = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Bold)
        $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
        
        # Calculate text position (centered)
        $textSize = $graphics.MeasureString($Text, $font)
        $x = ($Width - $textSize.Width) / 2
        $y = ($Height - $textSize.Height) / 2
        
        # Draw text
        $graphics.DrawString($Text, $font, $textBrush, $x, $y)
        
        # Save as BMP
        $bitmap.Save($FilePath, [System.Drawing.Imaging.ImageFormat]::Bmp)
        
        # Cleanup
        $graphics.Dispose()
        $bitmap.Dispose()
        $font.Dispose()
        $textBrush.Dispose()
        
        Write-ColoredOutput "Created placeholder BMP: $(Split-Path -Leaf $FilePath)" "SUCCESS"
        
    } catch {
        Write-ColoredOutput "Failed to create BMP placeholder: $_" "ERROR"
        
        # Create a minimal BMP header as fallback
        $bmpHeader = @(
            0x42, 0x4D,  # BM signature
            0x36, 0x00, 0x00, 0x00,  # File size (54 bytes header only)
            0x00, 0x00, 0x00, 0x00,  # Reserved
            0x36, 0x00, 0x00, 0x00,  # Offset to pixel data
            0x28, 0x00, 0x00, 0x00,  # DIB header size
            [byte]($Width -band 0xFF), [byte](($Width -shr 8) -band 0xFF), 0x00, 0x00,  # Width
            [byte]($Height -band 0xFF), [byte](($Height -shr 8) -band 0xFF), 0x00, 0x00,  # Height
            0x01, 0x00,  # Planes
            0x18, 0x00,  # Bits per pixel (24-bit)
            0x00, 0x00, 0x00, 0x00,  # Compression
            0x00, 0x00, 0x00, 0x00,  # Image size
            0x13, 0x0B, 0x00, 0x00,  # X pixels per meter
            0x13, 0x0B, 0x00, 0x00,  # Y pixels per meter
            0x00, 0x00, 0x00, 0x00,  # Colors used
            0x00, 0x00, 0x00, 0x00   # Important colors
        )
        
        # Write minimal BMP file
        [System.IO.File]::WriteAllBytes($FilePath, $bmpHeader)
        Write-ColoredOutput "Created minimal BMP placeholder: $(Split-Path -Leaf $FilePath)" "WARNING"
    }
}

# Create banner (493x58)
if (-not (Test-Path $BannerPath)) {
    Create-PlaceholderBMP -FilePath $BannerPath -Width 493 -Height 58 -Text "SPARC IDE"
}

# Create dialog (493x312)
if (-not (Test-Path $DialogPath)) {
    Create-PlaceholderBMP -FilePath $DialogPath -Width 493 -Height 312 -Text "SPARC IDE - AI Development Environment"
}

Write-ColoredOutput "Placeholder branding assets creation completed" "SUCCESS"
Write-ColoredOutput "Replace these placeholder files with actual branding assets for production builds" "INFO"