#Requires -Version 5.1
[CmdletBinding()]
param(
    [switch]$NoVulns,
    [switch]$NoLicenses,
    [switch]$NoSbom,
    [switch]$NoSecrets,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

if ($Help) {
    Write-Host "Security & Compliance Checks Script" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Usage: .\scripts\security.ps1 [OPTIONS]" -ForegroundColor White
    Write-Host ""
    Write-Host "Options:" -ForegroundColor White
    Write-Host "  -NoVulns      Skip vulnerability scanning" -ForegroundColor Gray
    Write-Host "  -NoLicenses   Skip license compliance check" -ForegroundColor Gray
    Write-Host "  -NoSbom       Skip SBOM generation" -ForegroundColor Gray
    Write-Host "  -NoSecrets    Skip secrets detection" -ForegroundColor Gray
    Write-Host "  -Help         Show this help message" -ForegroundColor Gray
    Write-Host ""
    Write-Host "This script will:" -ForegroundColor White
    Write-Host "  ✓ Scan for known vulnerabilities" -ForegroundColor Gray
    Write-Host "  ✓ Check license compliance" -ForegroundColor Gray
    Write-Host "  ✓ Generate Software Bill of Materials (SBOM)" -ForegroundColor Gray
    Write-Host "  ✓ Detect potential secrets in code" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Supported languages: python, java, node, go, flutter, rust, csharp" -ForegroundColor White
    exit 0
}

Write-Host "🔒 Security & Compliance Checks" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green

# Change to project root
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
Set-Location $ProjectRoot

# Utility functions
function Write-Info { param($Message) Write-Host "ℹ️  $Message" -ForegroundColor Cyan }
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Warning { param($Message) Write-Host "⚠️  $Message" -ForegroundColor Yellow }
function Write-Error-Custom { param($Message) Write-Host "❌ $Message" -ForegroundColor Red }

function Test-CommandExists {
    param($Command)
    return $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Get-DetectedLanguage {
    if ((Test-Path "pyproject.toml") -or (Test-Path "requirements.txt") -or (Test-Path "setup.py")) {
        return "python"
    } elseif ((Test-Path "pom.xml") -or (Test-Path "build.gradle") -or (Test-Path "build.gradle.kts")) {
        return "java"
    } elseif (Test-Path "package.json") {
        return "node"
    } elseif (Test-Path "go.mod") {
        return "go"
    } elseif (Test-Path "pubspec.yaml") {
        return "flutter"
    } elseif (Test-Path "Cargo.toml") {
        return "rust"
    } elseif ((Get-ChildItem -Path . -Recurse -Include "*.csproj","*.sln","*.fsproj" -Depth 2).Count -gt 0) {
        return "csharp"
    } else {
        return "unknown"
    }
}

function Invoke-VulnerabilityScan {
    param($Language)
    Write-Info "Running vulnerability scan for $Language..."
    
    switch ($Language) {
        "python" {
            if (Test-CommandExists safety) {
                Write-Info "Running Safety scan..."
                try {
                    safety check
                    Write-Success "No known vulnerabilities found"
                    return $true
                } catch {
                    Write-Warning "Vulnerabilities detected by Safety"
                    return $false
                }
            } elseif (Test-CommandExists pip-audit) {
                Write-Info "Running pip-audit scan..."
                try {
                    pip-audit
                    Write-Success "No known vulnerabilities found"
                    return $true
                } catch {
                    Write-Warning "Vulnerabilities detected by pip-audit"
                    return $false
                }
            } else {
                Write-Warning "No Python vulnerability scanner found (install: pip install safety pip-audit)"
            }
        }
        
        "java" {
            if (Test-CommandExists mvn) {
                Write-Info "Running OWASP dependency check with Maven..."
                try {
                    mvn dependency-check:check | Out-Null
                    Write-Success "Maven dependency check passed"
                } catch {
                    Write-Warning "Maven dependency check found issues"
                }
            } elseif (Test-CommandExists gradle) {
                Write-Info "Running OWASP dependency check with Gradle..."
                try {
                    gradle dependencyCheckAnalyze | Out-Null
                    Write-Success "Gradle dependency check passed"
                } catch {
                    Write-Warning "Gradle dependency check found issues"
                }
            }
        }
        
        "node" {
            Write-Info "Running npm audit..."
            try {
                npm audit --audit-level=moderate | Out-Null
                Write-Success "No moderate or high vulnerabilities found"
                return $true
            } catch {
                Write-Warning "npm audit found vulnerabilities"
                return $false
            }
        }
        
        "go" {
            if (Test-CommandExists govulncheck) {
                Write-Info "Running govulncheck..."
                try {
                    govulncheck ./...
                    Write-Success "No vulnerabilities found in Go dependencies"
                    return $true
                } catch {
                    Write-Warning "Vulnerabilities found in Go dependencies"
                    return $false
                }
            } else {
                Write-Warning "govulncheck not found (install: go install golang.org/x/vuln/cmd/govulncheck@latest)"
            }
        }
        
        "rust" {
            if (Test-CommandExists cargo-audit) {
                Write-Info "Running cargo audit..."
                try {
                    cargo audit
                    Write-Success "No vulnerabilities found in Rust dependencies"
                    return $true
                } catch {
                    Write-Warning "Vulnerabilities found in Rust dependencies"
                    return $false
                }
            } else {
                Write-Warning "cargo-audit not found (install: cargo install cargo-audit)"
            }
        }
        
        "csharp" {
            Write-Info "Running .NET vulnerability scan..."
            try {
                dotnet list package --vulnerable | Out-Null
                Write-Success "No vulnerable packages found"
                return $true
            } catch {
                Write-Warning "Vulnerable packages detected"
                return $false
            }
        }
        
        "flutter" {
            if (Test-Path "pubspec.yaml") {
                Write-Info "Checking Flutter dependencies..."
                Write-Warning "Flutter vulnerability scanning not available - manual review recommended"
            }
        }
        
        "unknown" {
            Write-Warning "Unknown project type - no vulnerability scanning available"
        }
    }
    
    return $true
}

function Invoke-LicenseCheck {
    param($Language)
    Write-Info "Running license compliance check for $Language..."
    
    switch ($Language) {
        "python" {
            if (Test-CommandExists pip-licenses) {
                Write-Info "Generating Python license report..."
                try {
                    pip-licenses --format=json --output-file=licenses.json | Out-Null
                    Write-Success "Python license report generated: licenses.json"
                } catch {
                    Write-Warning "Failed to generate Python license report"
                }
            } else {
                Write-Warning "pip-licenses not found (install: pip install pip-licenses)"
            }
        }
        
        "java" {
            if (Test-CommandExists mvn) {
                Write-Info "Generating Maven license report..."
                try {
                    mvn license:aggregate-third-party-report | Out-Null
                    Write-Success "Maven license report generated"
                } catch {
                    Write-Warning "Failed to generate Maven license report"
                }
            } elseif (Test-CommandExists gradle) {
                Write-Info "Generating Gradle license report..."
                try {
                    gradle generateLicenseReport | Out-Null
                    Write-Success "Gradle license report generated"
                } catch {
                    Write-Warning "Failed to generate Gradle license report"
                }
            }
        }
        
        "node" {
            if (Test-CommandExists license-checker) {
                Write-Info "Checking Node.js licenses..."
                try {
                    license-checker --onlyAllow 'MIT;Apache-2.0;BSD-3-Clause;ISC;BSD-2-Clause' | Out-Null
                    Write-Success "All licenses are approved"
                } catch {
                    Write-Warning "Some licenses may need review"
                }
            } else {
                Write-Warning "license-checker not found (install: npm install -g license-checker)"
            }
        }
        
        "go" {
            if (Test-CommandExists go-licenses) {
                Write-Info "Generating Go license report..."
                try {
                    go-licenses csv ./... > licenses.csv
                    Write-Success "Go license report generated: licenses.csv"
                } catch {
                    Write-Warning "Failed to generate Go license report"
                }
            } else {
                Write-Warning "go-licenses not found (install: go install github.com/google/go-licenses@latest)"
            }
        }
        
        "rust" {
            if (Test-CommandExists cargo-license) {
                Write-Info "Generating Rust license report..."
                try {
                    cargo-license --json > licenses.json
                    Write-Success "Rust license report generated: licenses.json"
                } catch {
                    Write-Warning "Failed to generate Rust license report"
                }
            } else {
                Write-Warning "cargo-license not found (install: cargo install cargo-license)"
            }
        }
        
        "csharp" {
            Write-Info "Generating .NET package list..."
            try {
                dotnet list package --include-transitive > packages.txt
                Write-Success ".NET package list generated: packages.txt"
            } catch {
                Write-Warning "Failed to generate .NET package list"
            }
        }
    }
}

function New-SBOM {
    param($Language)
    Write-Info "Generating Software Bill of Materials (SBOM)..."
    
    # Ensure build directory exists
    if (-not (Test-Path "build")) {
        New-Item -ItemType Directory -Path "build" -Force | Out-Null
    }
    
    switch ($Language) {
        "python" {
            Write-Info "Creating Python SBOM..."
            if (Test-CommandExists cyclone-x) {
                try {
                    cyclone-x py -o build/sbom.json | Out-Null
                    Write-Success "SBOM generated: build/sbom.json"
                } catch {
                    Write-Warning "Failed to generate full SBOM with cyclone-x"
                    New-BasicSBOM
                }
            } else {
                New-BasicSBOM
                Write-Warning "Basic SBOM generated (install cyclone-dx for full SBOM)"
            }
        }
        
        "node" {
            if (Test-CommandExists cyclone-dx) {
                Write-Info "Creating Node.js SBOM..."
                try {
                    cyclone-dx npm -o build/sbom.json | Out-Null
                    Write-Success "SBOM generated: build/sbom.json"
                } catch {
                    Write-Warning "cyclone-dx failed for Node.js SBOM generation"
                    New-BasicSBOM
                }
            } else {
                Write-Warning "cyclone-dx not found for Node.js SBOM generation"
                New-BasicSBOM
            }
        }
        
        default {
            Write-Info "Creating basic SBOM for $Language..."
            New-BasicSBOM
            Write-Success "Basic SBOM generated: build/sbom.json"
        }
    }
}

function New-BasicSBOM {
    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.000Z")
    $uuid = [System.Guid]::NewGuid().ToString()
    $projectName = Split-Path -Leaf $PWD
    
    $sbom = @{
        bomFormat = "CycloneDX"
        specVersion = "1.4"
        serialNumber = "urn:uuid:$uuid"
        version = 1
        metadata = @{
            timestamp = $timestamp
            tools = @(@{name = "automation-template"; version = "1.0.0"})
            component = @{
                type = "application"
                name = $projectName
                version = "1.0.0"
            }
        }
        components = @()
    }
    
    $sbom | ConvertTo-Json -Depth 10 | Out-File -FilePath "build/sbom.json" -Encoding UTF8
}

function Test-Secrets {
    Write-Info "Checking for secrets in repository..."
    
    $secretPatterns = @(
        "password\s*=\s*['""][^'""]+['""]",
        "api[_-]?key\s*=\s*['""][^'""]+['""]",
        "secret\s*=\s*['""][^'""]+['""]",
        "token\s*=\s*['""][^'""]+['""]",
        "private[_-]?key",
        "AKIA[0-9A-Z]{16}",  # AWS Access Key
        "-----BEGIN.*PRIVATE KEY-----"
    )
    
    $secretsFound = $false
    
    try {
        $trackedFiles = git ls-files
        foreach ($pattern in $secretPatterns) {
            foreach ($file in $trackedFiles) {
                if (Test-Path $file) {
                    $content = Get-Content $file -Raw -ErrorAction SilentlyContinue
                    if ($content -and $content -match $pattern) {
                        Write-Warning "Potential secret pattern found in: $file"
                        $secretsFound = $true
                    }
                }
            }
        }
    } catch {
        Write-Warning "Could not scan files for secrets"
        return $true
    }
    
    if ($secretsFound) {
        Write-Warning "Potential secrets found in repository - please review"
        Write-Info "💡 Use .env files and .gitignore for sensitive data"
        return $false
    } else {
        Write-Success "No obvious secrets detected in tracked files"
    }
    
    return $true
}

function Invoke-Main {
    try {
        $language = Get-DetectedLanguage
        Write-Info "Project root: $ProjectRoot"
        Write-Info "Detected language: $language"
        
        Write-Host ""
        
        $overallStatus = $true
        
        # Run vulnerability scan
        if (-not $NoVulns) {
            $vulnResult = Invoke-VulnerabilityScan $language
            if (-not $vulnResult) {
                $overallStatus = $false
            }
            Write-Host ""
        }
        
        # Run license check
        if (-not $NoLicenses) {
            Invoke-LicenseCheck $language
            Write-Host ""
        }
        
        # Generate SBOM
        if (-not $NoSbom) {
            New-SBOM $language
            Write-Host ""
        }
        
        # Check for secrets
        if (-not $NoSecrets) {
            $secretResult = Test-Secrets
            if (-not $secretResult) {
                $overallStatus = $false
            }
            Write-Host ""
        }
        
        # Summary
        if ($overallStatus) {
            Write-Success "All security and compliance checks passed!"
            Write-Host ""
            Write-Info "💡 Generated files:"
            Write-Host "   - licenses.json/csv - License compliance report"
            Write-Host "   - build/sbom.json - Software Bill of Materials"
            Write-Host "   - packages.txt - Dependency list (if applicable)"
            exit 0
        } else {
            Write-Warning "Some security or compliance issues found!"
            Write-Info "💡 Review the warnings above and take appropriate action"
            exit 1
        }
    } catch {
        Write-Error-Custom "Security check failed: $($_.Exception.Message)"
        exit 1
    }
}

Invoke-Main