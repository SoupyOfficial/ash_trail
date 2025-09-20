#Requires -Version 5.1
[CmdletBinding()]
param(
    [switch]$Fix,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

if ($Help) {
    Write-Host "Code Quality & Linting Script" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Usage: .\scripts\lint.ps1 [OPTIONS]" -ForegroundColor White
    Write-Host ""
    Write-Host "Options:" -ForegroundColor White
    Write-Host "  -Fix       Fix issues automatically where possible" -ForegroundColor Gray
    Write-Host "  -Help      Show this help message" -ForegroundColor Gray
    Write-Host ""
    Write-Host "This script will:" -ForegroundColor White
    Write-Host "  ✓ Detect project language automatically" -ForegroundColor Gray
    Write-Host "  ✓ Run language-specific linting tools" -ForegroundColor Gray
    Write-Host "  ✓ Check code formatting" -ForegroundColor Gray
    Write-Host "  ✓ Perform generic file quality checks" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Supported languages: python, java, node, go, flutter, rust, csharp" -ForegroundColor White
    exit 0
}

Write-Host "🔍 Code Quality & Linting" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green

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

function Invoke-LanguageLint {
    param($Language, $FixMode)
    
    Write-Info "Running $Language linting (fix mode: $FixMode)..."
    
    switch ($Language) {
        "python" {
            if ($FixMode) {
                Write-Info "Fixing Python code formatting and linting issues..."
                if (Test-CommandExists ruff) {
                    try { ruff check --fix . } catch { }
                }
                if (Test-CommandExists black) {
                    black .
                }
            } else {
                $lintFailed = $false
                Write-Info "Checking Python code with ruff..."
                if (Test-CommandExists ruff) {
                    try {
                        ruff check .
                    } catch {
                        $lintFailed = $true
                    }
                } else {
                    Write-Warning "ruff not found, skipping lint check"
                }
                
                Write-Info "Checking Python formatting with black..."
                if (Test-CommandExists black) {
                    try {
                        black --check .
                    } catch {
                        Write-Error-Custom "Code formatting issues found. Run: .\scripts\lint.ps1 -Fix"
                        $lintFailed = $true
                    }
                } else {
                    Write-Warning "black not found, skipping format check"
                }
                
                if ($lintFailed) { return $false }
            }
        }
        
        "java" {
            if (Test-CommandExists mvn) {
                if ($FixMode) {
                    Write-Info "Applying Java code formatting..."
                    mvn spotless:apply
                } else {
                    Write-Info "Checking Java code formatting..."
                    try {
                        mvn spotless:check -q
                    } catch {
                        Write-Error-Custom "Java formatting issues found. Run: .\scripts\lint.ps1 -Fix"
                        return $false
                    }
                }
            } elseif (Test-CommandExists gradle) {
                if ($FixMode) {
                    Write-Info "Applying Java code formatting..."
                    gradle spotlessApply
                } else {
                    Write-Info "Checking Java code formatting..."
                    try {
                        gradle spotlessCheck
                    } catch {
                        Write-Error-Custom "Java formatting issues found. Run: .\scripts\lint.ps1 -Fix"
                        return $false
                    }
                }
            } else {
                Write-Error-Custom "Neither Maven nor Gradle found"
                return $false
            }
        }
        
        "node" {
            if ((Test-Path "package.json") -and (Select-String -Path "package.json" -Pattern '"lint"')) {
                if ($FixMode) {
                    Write-Info "Fixing JavaScript/TypeScript code..."
                    if (Select-String -Path "package.json" -Pattern '"lint:fix"') {
                        npm run lint:fix
                    } else {
                        try { npx eslint --fix . } catch { }
                    }
                } else {
                    Write-Info "Linting JavaScript/TypeScript code..."
                    npm run lint
                }
            } else {
                Write-Info "Running ESLint directly..."
                if (Test-CommandExists npx) {
                    if ($FixMode) {
                        try { npx eslint --fix . } catch { }
                    } else {
                        try {
                            npx eslint .
                        } catch {
                            Write-Error-Custom "ESLint issues found. Run: .\scripts\lint.ps1 -Fix"
                            return $false
                        }
                    }
                } else {
                    Write-Warning "npx not found, skipping lint"
                }
            }
        }
        
        "go" {
            $lintFailed = $false
            
            Write-Info "Running go vet..."
            try {
                go vet ./...
            } catch {
                $lintFailed = $true
            }
            
            if ($FixMode) {
                Write-Info "Formatting Go code..."
                go fmt ./...
                if (Test-CommandExists golangci-lint) {
                    try { golangci-lint run --fix } catch { }
                }
            } else {
                Write-Info "Checking Go code formatting..."
                $formatOutput = go fmt ./...
                if ($formatOutput) {
                    Write-Error-Custom "Go formatting issues found. Run: .\scripts\lint.ps1 -Fix"
                    $lintFailed = $true
                }
                
                if (Test-CommandExists golangci-lint) {
                    Write-Info "Running golangci-lint..."
                    try {
                        golangci-lint run
                    } catch {
                        $lintFailed = $true
                    }
                } else {
                    Write-Warning "golangci-lint not found, skipping advanced linting"
                }
            }
            
            if ($lintFailed) { return $false }
        }
        
        "flutter" {
            if ($FixMode) {
                Write-Info "Formatting Dart code..."
                dart format .
            } else {
                $lintFailed = $false
                
                Write-Info "Checking Dart formatting..."
                try {
                    dart format --set-exit-if-changed .
                } catch {
                    Write-Error-Custom "Dart formatting issues found. Run: .\scripts\lint.ps1 -Fix"
                    $lintFailed = $true
                }
                
                Write-Info "Running Flutter analyzer..."
                try {
                    flutter analyze
                } catch {
                    $lintFailed = $true
                }
                
                if ($lintFailed) { return $false }
            }
        }
        
        "rust" {
            if ($FixMode) {
                Write-Info "Formatting Rust code..."
                cargo fmt
                if (Test-CommandExists cargo-clippy) {
                    try { cargo clippy --fix --allow-dirty } catch { }
                }
            } else {
                $lintFailed = $false
                
                Write-Info "Checking Rust formatting..."
                try {
                    cargo fmt --check
                } catch {
                    Write-Error-Custom "Rust formatting issues found. Run: .\scripts\lint.ps1 -Fix"
                    $lintFailed = $true
                }
                
                Write-Info "Running Clippy..."
                try {
                    cargo clippy -- -D warnings
                } catch {
                    $lintFailed = $true
                }
                
                if ($lintFailed) { return $false }
            }
        }
        
        "csharp" {
            if ($FixMode) {
                Write-Info "Formatting C# code..."
                dotnet format
            } else {
                Write-Info "Checking C# formatting..."
                try {
                    dotnet format --verify-no-changes
                } catch {
                    Write-Error-Custom "C# formatting issues found. Run: .\scripts\lint.ps1 -Fix"
                    return $false
                }
            }
        }
        
        "unknown" {
            Write-Warning "Unknown project type - no language-specific linting available"
        }
    }
    
    return $true
}

function Invoke-GenericChecks {
    param($FixMode)
    Write-Info "Running generic file checks..."
    
    $extensions = @("*.py", "*.js", "*.ts", "*.java", "*.go", "*.dart", "*.rs", "*.cs")
    
    if ($FixMode) {
        Write-Info "Removing trailing whitespace..."
        foreach ($ext in $extensions) {
            Get-ChildItem -Recurse -Include $ext -ErrorAction SilentlyContinue | ForEach-Object {
                (Get-Content $_.FullName) -replace '\s+$', '' | Set-Content $_.FullName
            }
        }
        
        Write-Info "Adding newlines to end of files..."
        foreach ($ext in $extensions) {
            Get-ChildItem -Recurse -Include $ext -ErrorAction SilentlyContinue | ForEach-Object {
                $content = Get-Content $_.FullName -Raw
                if ($content -and -not $content.EndsWith("`n")) {
                    Add-Content $_.FullName -Value ""
                }
            }
        }
    } else {
        # Check for trailing whitespace
        $hasTrailingWhitespace = $false
        foreach ($ext in $extensions) {
            $files = Get-ChildItem -Recurse -Include $ext -ErrorAction SilentlyContinue
            foreach ($file in $files) {
                if (Select-String -Path $file.FullName -Pattern '\s+$' -Quiet) {
                    $hasTrailingWhitespace = $true
                    break
                }
            }
            if ($hasTrailingWhitespace) { break }
        }
        
        if ($hasTrailingWhitespace) {
            Write-Error-Custom "Trailing whitespace found. Run: .\scripts\lint.ps1 -Fix"
            return $false
        }
    }
    
    return $true
}

function Invoke-Main {
    try {
        # Check for config file
        if (-not (Test-Path "automation.config.yaml")) {
            Write-Error-Custom "automation.config.yaml not found. Run .\scripts\bootstrap.ps1 first"
            exit 1
        }
        
        $language = Get-DetectedLanguage
        Write-Info "Project root: $ProjectRoot"
        Write-Info "Detected language: $language"
        
        if ($Fix) {
            Write-Info "Running in fix mode - will attempt to fix issues"
        } else {
            Write-Info "Running in check mode - will report issues only"
        }
        
        Write-Host ""
        
        # Run language-specific linting
        $lintStatus = Invoke-LanguageLint $language $Fix
        
        # Run generic checks
        $genericStatus = Invoke-GenericChecks $Fix
        
        Write-Host ""
        
        # Summary
        if ($lintStatus -and $genericStatus) {
            if ($Fix) {
                Write-Success "All issues have been fixed!"
            } else {
                Write-Success "All linting checks passed!"
            }
            Write-Host ""
            Write-Info "💡 Next steps:"
            Write-Host "   1. Run '.\scripts\test.ps1' to run tests"
            Write-Host "   2. Run '.\scripts\build.ps1' to build the project"
            exit 0
        } else {
            if ($Fix) {
                Write-Warning "Some issues could not be automatically fixed"
                Write-Info "💡 Manual intervention may be required"
            } else {
                Write-Error-Custom "Linting issues found!"
                Write-Info "💡 Run '.\scripts\lint.ps1 -Fix' to attempt automatic fixes"
            }
            exit 1
        }
    } catch {
        Write-Error-Custom "Linting failed: $($_.Exception.Message)"
        exit 1
    }
}

Invoke-Main