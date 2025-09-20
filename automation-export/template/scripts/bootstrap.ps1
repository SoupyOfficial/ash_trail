#Requires -Version 5.1
[CmdletBinding()]
param(
    [switch]$SkipDeps,
    [switch]$SkipHooks,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

if ($Help) {
    Write-Host "Development Environment Bootstrap Script" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Usage: .\scripts\bootstrap.ps1 [OPTIONS]" -ForegroundColor White
    Write-Host ""
    Write-Host "Options:" -ForegroundColor White
    Write-Host "  -Help        Show this help message" -ForegroundColor Gray
    Write-Host "  -SkipDeps    Skip system dependency installation" -ForegroundColor Gray
    Write-Host "  -SkipHooks   Skip git hooks setup" -ForegroundColor Gray
    Write-Host ""
    Write-Host "This script will:" -ForegroundColor White
    Write-Host "  1. Detect your project language" -ForegroundColor Gray
    Write-Host "  2. Install necessary system dependencies" -ForegroundColor Gray
    Write-Host "  3. Install language-specific tools" -ForegroundColor Gray
    Write-Host "  4. Setup git hooks" -ForegroundColor Gray
    Write-Host "  5. Create necessary directories" -ForegroundColor Gray
    exit 0
}

Write-Host "🚀 Development Environment Bootstrap" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Change to project root (script should be in scripts\ subdirectory)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
Set-Location $ProjectRoot

Write-Host "📁 Project root: $ProjectRoot" -ForegroundColor Cyan

# Check for config file
$ConfigFile = "automation.config.yaml"
if (-not (Test-Path $ConfigFile)) {
    Write-Host "❌ automation.config.yaml not found. Creating default..." -ForegroundColor Yellow
    try {
        Copy-Item "scripts\..\automation.config.yaml" . -ErrorAction Stop
    } catch {
        Write-Host "❌ Could not find automation config template" -ForegroundColor Red
        exit 1
    }
}

function Detect-Language {
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

$Language = Detect-Language
Write-Host "🔍 Detected language: $Language" -ForegroundColor Cyan

if ($Language -eq "unknown") {
    Write-Host "⚠️  Could not detect project language. Continuing with generic setup..." -ForegroundColor Yellow
}

function Install-SystemDeps {
    Write-Host "📦 Installing system dependencies..." -ForegroundColor Cyan
    
    # Check if Chocolatey is installed
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Chocolatey package manager..." -ForegroundColor Yellow
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
    
    # Install basic tools
    $tools = @("git", "curl", "wget", "python3")
    foreach ($tool in $tools) {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
            Write-Host "Installing $tool..." -ForegroundColor Yellow
            choco install $tool -y
        }
    }
}

function Install-LanguageTools {
    Write-Host "🔧 Installing $Language tools..." -ForegroundColor Cyan
    
    switch ($Language) {
        "python" {
            if (Get-Command python -ErrorAction SilentlyContinue) {
                python -m pip install --upgrade pip
                if (Test-Path "requirements.txt") {
                    pip install -r requirements.txt
                }
                if (Test-Path "pyproject.toml") {
                    pip install -e .
                }
                # Common dev tools
                pip install ruff black pytest coverage
            } else {
                Write-Host "⚠️  Python not found. Please install Python manually" -ForegroundColor Yellow
            }
        }
        "java" {
            if (-not (Get-Command mvn -ErrorAction SilentlyContinue) -and -not (Get-Command gradle -ErrorAction SilentlyContinue)) {
                Write-Host "⚠️  Please install Maven or Gradle manually" -ForegroundColor Yellow
            }
        }
        "node" {
            if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
                Write-Host "⚠️  Please install Node.js manually" -ForegroundColor Yellow
            } else {
                npm install
            }
        }
        "go" {
            if (-not (Get-Command go -ErrorAction SilentlyContinue)) {
                Write-Host "⚠️  Please install Go manually" -ForegroundColor Yellow
            } else {
                try { go mod tidy } catch { Write-Host "No go.mod found" -ForegroundColor Gray }
                go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
            }
        }
        "flutter" {
            if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
                Write-Host "⚠️  Please install Flutter manually" -ForegroundColor Yellow
            } else {
                flutter pub get
            }
        }
        "rust" {
            if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
                Write-Host "⚠️  Please install Rust manually" -ForegroundColor Yellow
            } else {
                cargo fetch
            }
        }
        "csharp" {
            if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
                Write-Host "⚠️  Please install .NET SDK manually" -ForegroundColor Yellow
            } else {
                dotnet restore
            }
        }
    }
}

function Setup-GitHooks {
    Write-Host "🪝 Setting up git hooks..." -ForegroundColor Cyan
    
    if (Test-Path ".git") {
        # Install pre-commit if not present
        if (-not (Get-Command pre-commit -ErrorAction SilentlyContinue)) {
            Write-Host "📦 Installing pre-commit..." -ForegroundColor Yellow
            if (Get-Command pip -ErrorAction SilentlyContinue) {
                pip install pre-commit
            } elseif (Get-Command pip3 -ErrorAction SilentlyContinue) {
                pip3 install pre-commit
            } else {
                Write-Host "⚠️  Could not install pre-commit. Please install manually." -ForegroundColor Yellow
                return
            }
        }
        
        # Install hooks if config exists
        if (Test-Path ".pre-commit-config.yaml") {
            pre-commit install
            Write-Host "✅ Pre-commit hooks installed" -ForegroundColor Green
        } else {
            Write-Host "⚠️  No .pre-commit-config.yaml found. Hooks not installed." -ForegroundColor Yellow
        }
    } else {
        Write-Host "⚠️  Not a git repository. Skipping hook setup." -ForegroundColor Yellow
    }
}

function Create-Directories {
    Write-Host "📁 Creating project directories..." -ForegroundColor Cyan
    $directories = @("coverage", "build", "logs", ".vscode")
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
}

function Main {
    Write-Host ""
    Write-Host "Starting bootstrap process..." -ForegroundColor White
    Write-Host ""
    
    # Basic checks
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "Installing system dependencies..." -ForegroundColor Cyan
        Install-SystemDeps
    }
    
    Create-Directories
    Install-LanguageTools
    Setup-GitHooks
    
    Write-Host ""
    Write-Host "🎉 Bootstrap complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📝 Next steps:" -ForegroundColor White
    Write-Host "1. Run '.\scripts\doctor.ps1' to validate your setup" -ForegroundColor Gray
    Write-Host "2. Run '.\scripts\lint.ps1' to check code quality" -ForegroundColor Gray
    Write-Host "3. Run '.\scripts\test.ps1' to run tests" -ForegroundColor Gray
    Write-Host ""
    Write-Host "💡 Tip: Use '.\scripts\doctor.ps1 -Help' to see available commands" -ForegroundColor Yellow
}

# Main execution
try {
    if (-not $SkipDeps) {
        Main
    } else {
        Write-Host "⚠️  Skipping dependency installation as requested" -ForegroundColor Yellow
        Create-Directories
        if (-not $SkipHooks) { Setup-GitHooks }
        Write-Host "🎉 Bootstrap complete (with skips)!" -ForegroundColor Green
    }
} catch {
    Write-Host "❌ Bootstrap failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}