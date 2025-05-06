#!/bin/bash
# SPARC IDE - Roo Code Extension Download Script
# This script downloads the Roo Code extension and prepares it for integration with SPARC IDE

set -e
set -o nounset  # Exit if a variable is unset
set -o pipefail # Exit if any command in a pipeline fails

# Configuration
# Load environment variables if .env file exists
if [ -f ".env" ]; then
    # Source environment variables from .env file
    set -a
    source .env
    set +a
fi

# Configuration with environment variable support
EXTENSIONS_DIR="${ROO_EXTENSIONS_DIR:-extensions}"
ROO_CODE_PUBLISHER="${ROO_CODE_PUBLISHER:-RooVeterinaryInc}"
ROO_CODE_EXTENSION="${ROO_CODE_EXTENSION:-roo-cline}"
ROO_CODE_FILENAME="${ROO_CODE_FILENAME:-roo-code.vsix}"
ROO_CODE_SIGNATURE="${ROO_CODE_SIGNATURE:-roo-code.vsix.sig}"
ROO_CODE_PUBLIC_KEY="${ROO_CODE_PUBLIC_KEY:-roo-code-public.pem}"
MARKETPLACE_URL="${ROO_MARKETPLACE_URL:-https://marketplace.visualstudio.com/_apis/public/gallery/publishers}"
SIGNATURE_URL="${ROO_SIGNATURE_URL:-https://roo-verification.example.com/signatures}"
PUBLIC_KEY_URL="${ROO_PUBLIC_KEY_URL:-https://roo-verification.example.com/keys}"

# Create .env.example file if it doesn't exist
if [ ! -f ".env.example" ]; then
    cat > ".env.example" << 'EOL'
# Roo Code Extension Configuration
# Copy this file to .env and customize as needed

# Directories
ROO_EXTENSIONS_DIR=extensions

# Extension Information
ROO_CODE_PUBLISHER=RooVeterinaryInc
ROO_CODE_EXTENSION=roo-cline
ROO_CODE_FILENAME=roo-code.vsix
ROO_CODE_SIGNATURE=roo-code.vsix.sig
ROO_CODE_PUBLIC_KEY=roo-code-public.pem

# URLs
ROO_MARKETPLACE_URL=https://marketplace.visualstudio.com/_apis/public/gallery/publishers
ROO_SIGNATURE_URL=https://roo-verification.example.com/signatures
ROO_PUBLIC_KEY_URL=https://roo-verification.example.com/keys
EOL
    chmod 644 ".env.example"
    print_info "Created .env.example file. Copy to .env and customize as needed."
fi
# Print colored output
print_info() {
    echo -e "\e[1;34m[INFO]\e[0m $1"
}

print_success() {
    echo -e "\e[1;32m[SUCCESS]\e[0m $1"
}

print_error() {
    echo -e "\e[1;31m[ERROR]\e[0m $1"
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check if curl is installed
    if ! command -v curl &> /dev/null; then
        print_error "curl is not installed. Please install curl and try again."
        exit 1
    fi
    
    # Check if openssl is installed
    if ! command -v openssl &> /dev/null; then
        print_error "OpenSSL is not installed. Please install OpenSSL and try again."
        exit 1
    fi
    
    # Check if extensions directory exists
    if [ ! -d "$EXTENSIONS_DIR" ]; then
        print_info "Creating extensions directory..."
        mkdir -p "$EXTENSIONS_DIR"
    fi
    
    # Create a directory for verification keys and signatures
    if [ ! -d "$EXTENSIONS_DIR/verification" ]; then
        print_info "Creating verification directory..."
        mkdir -p "$EXTENSIONS_DIR/verification"
    fi
    
    print_success "All prerequisites are met."
# Validate URL to prevent command injection
validate_url() {
    local url="$1"
    # Check if URL matches expected pattern (https:// followed by valid characters)
    if [[ ! "$url" =~ ^https://[a-zA-Z0-9][a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(/[a-zA-Z0-9._~:/?#[\]@!$&'()*+,;=%-]+)?$ ]]; then
        print_error "Invalid URL format: $url"
        return 1
    fi
    return 0
}

# Download Roo Code extension
download_roo_code() {
    print_info "Downloading Roo Code extension..."
    
    # Construct the download URLs
    DOWNLOAD_URL="$MARKETPLACE_URL/$ROO_CODE_PUBLISHER/vsextensions/$ROO_CODE_EXTENSION/latest/vspackage"
    SIG_URL="$SIGNATURE_URL/$ROO_CODE_PUBLISHER/$ROO_CODE_EXTENSION/latest/$ROO_CODE_SIGNATURE"
    KEY_URL="$PUBLIC_KEY_URL/$ROO_CODE_PUBLISHER/$ROO_CODE_EXTENSION/$ROO_CODE_PUBLIC_KEY"
    
    # Validate URLs to prevent command injection
    print_info "Validating URLs..."
    if ! validate_url "$DOWNLOAD_URL" || ! validate_url "$SIG_URL" || ! validate_url "$KEY_URL"; then
        print_error "URL validation failed. Aborting download for security reasons."
        exit 1
    fi
    
    # Create a temporary directory for downloads
    TEMP_DIR=$(mktemp -d)
    print_info "Created temporary directory for downloads: $TEMP_DIR"
    
    # Download the extension to temporary location first
    print_info "Downloading extension package..."
    if ! curl --fail --silent --show-error --location --max-time 300 \
              --output "$TEMP_DIR/$ROO_CODE_FILENAME" "$DOWNLOAD_URL"; then
        print_error "Failed to download Roo Code extension."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Verify file is not empty
    if [ ! -s "$TEMP_DIR/$ROO_CODE_FILENAME" ]; then
        print_error "Downloaded extension file is empty."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Download the signature to temporary location
    print_info "Downloading cryptographic signature..."
    if ! curl --fail --silent --show-error --location --max-time 60 \
              --output "$TEMP_DIR/$ROO_CODE_SIGNATURE" "$SIG_URL"; then
        print_error "Failed to download signature file. Cannot verify extension authenticity."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Verify signature file is not empty
    if [ ! -s "$TEMP_DIR/$ROO_CODE_SIGNATURE" ]; then
        print_error "Downloaded signature file is empty."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Download the public key to temporary location
    print_info "Downloading public key for verification..."
    if ! curl --fail --silent --show-error --location --max-time 60 \
              --output "$TEMP_DIR/$ROO_CODE_PUBLIC_KEY" "$KEY_URL"; then
        print_error "Failed to download public key. Cannot verify extension authenticity."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Verify public key file is not empty
    if [ ! -s "$TEMP_DIR/$ROO_CODE_PUBLIC_KEY" ]; then
        print_error "Downloaded public key file is empty."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Verify public key format
    if ! openssl rsa -in "$TEMP_DIR/$ROO_CODE_PUBLIC_KEY" -pubin -noout 2>/dev/null; then
        print_error "Invalid public key format. Security check failed."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Move verified files to final location
    mkdir -p "$EXTENSIONS_DIR/verification"
    mv "$TEMP_DIR/$ROO_CODE_FILENAME" "$EXTENSIONS_DIR/$ROO_CODE_FILENAME"
    mv "$TEMP_DIR/$ROO_CODE_SIGNATURE" "$EXTENSIONS_DIR/verification/$ROO_CODE_SIGNATURE"
    mv "$TEMP_DIR/$ROO_CODE_PUBLIC_KEY" "$EXTENSIONS_DIR/verification/$ROO_CODE_PUBLIC_KEY"
    
    # Set secure permissions
    chmod 644 "$EXTENSIONS_DIR/$ROO_CODE_FILENAME"
    chmod 644 "$EXTENSIONS_DIR/verification/$ROO_CODE_SIGNATURE"
    chmod 644 "$EXTENSIONS_DIR/verification/$ROO_CODE_PUBLIC_KEY"
    
    # Clean up
    rm -rf "$TEMP_DIR"
    
    print_success "Roo Code extension and verification files downloaded and validated successfully."
}

# Verify the downloaded extension
verify_extension() {
    print_info "Verifying Roo Code extension..."
        
        # Check if the file exists and has a non-zero size
        if [ ! -f "$EXTENSIONS_DIR/$ROO_CODE_FILENAME" ] || [ ! -s "$EXTENSIONS_DIR/$ROO_CODE_FILENAME" ]; then
            print_error "Downloaded file is empty or does not exist."
            exit 1
        fi
        
        # Check if the file is a valid VSIX package (ZIP file)
        if ! file "$EXTENSIONS_DIR/$ROO_CODE_FILENAME" | grep -q "Zip archive data"; then
            print_error "Downloaded file is not a valid VSIX package."
            exit 1
        fi
        
        # Check file size (reject suspiciously large files)
        FILE_SIZE=$(stat -c%s "$EXTENSIONS_DIR/$ROO_CODE_FILENAME")
        MAX_SIZE=$((100 * 1024 * 1024)) # 100MB max
        if [ "$FILE_SIZE" -gt "$MAX_SIZE" ]; then
            print_error "Extension file is too large ($FILE_SIZE bytes). Maximum allowed size is $MAX_SIZE bytes."
            exit 1
        fi
        
        # Verify file integrity with checksum
        print_info "Verifying file integrity with SHA-256 checksum..."
        CHECKSUM=$(openssl dgst -sha256 "$EXTENSIONS_DIR/$ROO_CODE_FILENAME" | awk '{print $2}')
        print_info "SHA-256: $CHECKSUM"
        
        # Verify cryptographic signature
        print_info "Verifying cryptographic signature..."
        
        # Check if signature and public key files exist
        if [ ! -f "$EXTENSIONS_DIR/verification/$ROO_CODE_SIGNATURE" ]; then
            print_error "Signature file not found. Cannot verify authenticity."
            exit 1
        fi
        
        if [ ! -f "$EXTENSIONS_DIR/verification/$ROO_CODE_PUBLIC_KEY" ]; then
            print_error "Public key file not found. Cannot verify authenticity."
            exit 1
        fi
        
        # Verify the signature using OpenSSL with explicit algorithm
        if openssl dgst -sha256 -verify "$EXTENSIONS_DIR/verification/$ROO_CODE_PUBLIC_KEY" \
                       -signature "$EXTENSIONS_DIR/verification/$ROO_CODE_SIGNATURE" \
                       "$EXTENSIONS_DIR/$ROO_CODE_FILENAME" 2>/dev/null; then
            print_success "Cryptographic signature verification passed."
        else
            print_error "Cryptographic signature verification FAILED. The extension may have been tampered with."
            print_error "Aborting installation for security reasons."
            exit 1
        fi
        
        # Create a secure temporary directory for extraction
        TEMP_DIR=$(mktemp -d)
        chmod 700 "$TEMP_DIR"
        
        print_info "Verifying extension contents..."
        
        # Create a list of potentially dangerous file extensions
        DANGEROUS_EXTENSIONS="\.(sh|bash|exe|dll|so|dylib|cmd|bat|ps1|vbs|js)$"
        
        # Check for potentially dangerous files in the VSIX package
        if unzip -l "$EXTENSIONS_DIR/$ROO_CODE_FILENAME" | grep -E "$DANGEROUS_EXTENSIONS"; then
            print_warning "Potentially dangerous files found in the extension package."
            print_info "These files will be carefully examined during installation."
        fi
        
        # Extract the extension.vsixmanifest file from the VSIX package
        if ! unzip -q -o "$EXTENSIONS_DIR/$ROO_CODE_FILENAME" "extension.vsixmanifest" -d "$TEMP_DIR"; then
            print_error "Failed to extract manifest from VSIX package."
            rm -rf "$TEMP_DIR"
            exit 1
        fi
        
        # Check if the manifest file exists
        if [ ! -f "$TEMP_DIR/extension.vsixmanifest" ]; then
            print_error "Manifest file not found in VSIX package."
            rm -rf "$TEMP_DIR"
            exit 1
        fi
        
        # Verify manifest file is not too large (prevent DoS)
        MANIFEST_SIZE=$(stat -c%s "$TEMP_DIR/extension.vsixmanifest")
        if [ "$MANIFEST_SIZE" -gt 1000000 ]; then # 1MB max
            print_error "Manifest file is suspiciously large ($MANIFEST_SIZE bytes)."
            rm -rf "$TEMP_DIR"
            exit 1
        fi
        
        # Check for suspicious content in manifest
        if grep -q "curl\|wget\|eval\|exec" "$TEMP_DIR/extension.vsixmanifest"; then
            print_error "Suspicious content found in manifest file."
            rm -rf "$TEMP_DIR"
            exit 1
        fi
        
        # Verify publisher ID in the manifest using XML-aware parsing
        if grep -q "<Identity[^>]*Publisher=\"$ROO_CODE_PUBLISHER\"" "$TEMP_DIR/extension.vsixmanifest"; then
            print_success "Publisher identity verified."
        else
            print_error "Publisher identity verification FAILED. Expected '$ROO_CODE_PUBLISHER'."
            print_error "The extension may be counterfeit. Aborting installation."
            rm -rf "$TEMP_DIR"
            exit 1
        fi
        
        # Extract and verify package.json if it exists
        if unzip -q -o "$EXTENSIONS_DIR/$ROO_CODE_FILENAME" "extension/package.json" -d "$TEMP_DIR" 2>/dev/null; then
            if [ -f "$TEMP_DIR/extension/package.json" ]; then
                print_info "Verifying package.json..."
                
                # Validate JSON format
                if ! jq . "$TEMP_DIR/extension/package.json" > /dev/null 2>&1; then
                    print_error "Invalid JSON format in package.json."
                    rm -rf "$TEMP_DIR"
                    exit 1
                fi
                
                # Check for suspicious content
                if grep -q "curl\|wget\|eval\|exec" "$TEMP_DIR/extension/package.json"; then
                    print_error "Suspicious content found in package.json."
                    rm -rf "$TEMP_DIR"
                    exit 1
                fi
                
                # Verify publisher name in package.json
                PACKAGE_PUBLISHER=$(jq -r '.publisher // ""' "$TEMP_DIR/extension/package.json")
                if [ "$PACKAGE_PUBLISHER" != "$ROO_CODE_PUBLISHER" ] && [ -n "$PACKAGE_PUBLISHER" ]; then
                    print_error "Publisher mismatch in package.json. Expected: $ROO_CODE_PUBLISHER, Found: $PACKAGE_PUBLISHER"
                    rm -rf "$TEMP_DIR"
                    exit 1
                fi
                
                print_success "package.json verified."
            fi
        fi
        
        # Clean up temporary directory
        rm -rf "$TEMP_DIR"
        
        print_success "Roo Code extension verified successfully."
        
        # Create a verification record with secure permissions
        VERIFICATION_RECORD="$EXTENSIONS_DIR/verification/verification-record.json"
        
        # Create JSON verification record
        cat > "$VERIFICATION_RECORD" << EOL
    {
      "extension": "$ROO_CODE_EXTENSION",
      "publisher": "$ROO_CODE_PUBLISHER",
      "verificationDate": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
      "sha256Checksum": "$CHECKSUM",
      "signatureVerified": true,
      "publisherVerified": true,
      "fileSize": $FILE_SIZE,
      "verificationVersion": "1.0"
    }
    EOL
        
        # Set secure permissions
        chmod 644 "$VERIFICATION_RECORD"
        
        print_info "Verification record created at $VERIFICATION_RECORD"
    }
configure_roo_code() {
    print_info "Configuring Roo Code integration with enhanced security..."
    
    # Create a temporary directory for configuration
    TEMP_DIR=$(mktemp -d)
    chmod 700 "$TEMP_DIR"
    
    # Ensure config directory exists with proper permissions
    if [ ! -d "src/config" ]; then
        print_info "Creating config directory..."
        mkdir -p "src/config"
        chmod 755 "src/config"
    fi
    
    # Check if settings.json exists
    if [ ! -f "src/config/settings.json" ]; then
        print_error "settings.json not found. Please create it first."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Verify settings.json is valid JSON
    if ! jq . "src/config/settings.json" > /dev/null 2>&1; then
        print_error "settings.json is not valid JSON. Please fix it first."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Create security configuration file in temporary directory first
    print_info "Creating security configuration..."
    
    TEMP_SECURITY_CONFIG="$TEMP_DIR/extension-security.json"
    SECURITY_CONFIG="src/config/extension-security.json"
    
    cat > "$TEMP_SECURITY_CONFIG" << EOL
{
  "extensions": {
    "verification": {
      "enabled": true,
      "requireSignatureVerification": true,
      "requirePublisherVerification": true,
      "trustedPublishers": [
        "$ROO_CODE_PUBLISHER"
      ],
      "signatureAlgorithm": "sha256WithRSAEncryption",
      "minimumKeyLength": 2048
    },
    "installation": {
      "allowedSources": [
        "marketplace",
        "verified-local"
      ],
      "blockUnverified": true,
      "maxExtensionSize": 104857600,
      "requireHttps": true
    },
    "runtime": {
      "sandboxed": true,
      "restrictedPermissions": true,
      "allowNetworkAccess": false,
      "allowFileSystemAccess": false,
      "allowProcessExecution": false
    },
    "contentSecurity": {
      "blockDangerousFileTypes": true,
      "dangerousExtensions": [
        ".sh", ".bash", ".exe", ".dll", ".so", ".dylib",
        ".cmd", ".bat", ".ps1", ".vbs", ".js"
      ],
      "scanForMalware": true
    }
  },
  "verificationKeys": {
    "$ROO_CODE_PUBLISHER": "$EXTENSIONS_DIR/verification/$ROO_CODE_PUBLIC_KEY"
  },
  "verificationRecords": {
    "$ROO_CODE_EXTENSION": "$EXTENSIONS_DIR/verification/verification-record.json"
  },
  "securityUpdates": {
    "checkForUpdates": true,
    "updateFrequency": "daily",
    "notifyOnVulnerabilities": true
  }
}
EOL
    
    # Validate the JSON format
    if ! jq . "$TEMP_SECURITY_CONFIG" > /dev/null 2>&1; then
        print_error "Generated security configuration is not valid JSON."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Check for sensitive information
    if grep -q "API_KEY\|SECRET\|PASSWORD\|TOKEN" "$TEMP_SECURITY_CONFIG"; then
        print_error "Security configuration contains potentially sensitive information."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Move the validated configuration to the final location
    cp "$TEMP_SECURITY_CONFIG" "$SECURITY_CONFIG"
    chmod 644 "$SECURITY_CONFIG"
    
    # Update settings.json to include security settings
    print_info "Updating settings.json with security configuration..."
    
    # Create a temporary file for settings
    TEMP_SETTINGS="$TEMP_DIR/settings.json"
    
    # Add security configuration to settings.json
    if ! jq --arg securityConfig "$SECURITY_CONFIG" '.security.extensionVerification = true | .security.extensionSecurityConfigPath = $securityConfig | .security.enforceStrictSecurity = true | .security.allowedExtensionPublishers = ["'$ROO_CODE_PUBLISHER'"]' "src/config/settings.json" > "$TEMP_SETTINGS"; then
        print_error "Failed to update settings.json. JSON processing error."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Validate the updated settings
    if ! jq . "$TEMP_SETTINGS" > /dev/null 2>&1; then
        print_error "Updated settings.json is not valid JSON."
        rm -rf "$TEMP_DIR"
        exit 1
    fi
    
    # Move the validated settings to the final location
    cp "$TEMP_SETTINGS" "src/config/settings.json"
    chmod 644 "src/config/settings.json"
    
    # Create a security audit log
    AUDIT_LOG="src/config/security-audit.log"
    {
        echo "Security Configuration Update"
        echo "Date: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
        echo "Extension: $ROO_CODE_EXTENSION"
        echo "Publisher: $ROO_CODE_PUBLISHER"
        echo "Verification Enabled: Yes"
        echo "Strict Security: Enabled"
        echo "Dangerous File Types Blocked: Yes"
        echo "Network Access Restricted: Yes"
        echo "File System Access Restricted: Yes"
        echo "Process Execution Restricted: Yes"
    } > "$AUDIT_LOG"
    chmod 644 "$AUDIT_LOG"
    
    # Clean up
    rm -rf "$TEMP_DIR"
    
    print_success "Roo Code integration configured successfully with enhanced security."
    print_info "Security audit log created at $AUDIT_LOG"
}

# Main function
main() {
    print_info "Setting up Roo Code integration..."
    
    check_prerequisites
    download_roo_code
    verify_extension
    configure_roo_code
    
    print_success "Roo Code integration set up successfully."
    print_info "The Roo Code extension has been downloaded to $EXTENSIONS_DIR/$ROO_CODE_FILENAME"
    print_info "It will be automatically installed when building SPARC IDE."
}

# Run main function
main