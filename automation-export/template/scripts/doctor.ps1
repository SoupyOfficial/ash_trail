#Requires -Version 5.1
[CmdletBinding()]
param(
    [switch]$Help
)

$ErrorActionPreference = "Stop"

if ($Help) {
    Write-Host "Development Environment Health Check" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Usage: .\scripts\doctor.ps1 [OPTIONS]" -ForegroundColor White
    Write-Host ""
    Write-Host "Options:" -ForegroundColor White
    Write-Host "  -Help      Show this help message" -ForegroundColor Gray
    Write-Host ""
    Write-Host "This script checks:" -ForegroundColor White
    Write-Host "  ✓ System tools (git, curl, python3)" -ForegroundColor Gray
    Write-Host "  ✓ Git configuration and hooks" -ForegroundColor Gray
    Write-Host "  ✓ Language-specific tools and dependencies" -ForegroundColor Gray
    Write-Host "  ✓ Project structure and permissions" -ForegroundColor Gray
    Write-Host "  ✓ Automation configuration" -ForegroundColor Gray
    exit 0
}

Write-Host "🔍 Development Environment Health Check" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

# Change to project root
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
Set-Location $ProjectRoot

# Global status tracking
$Script:OverallStatus = 0
$Script:Warnings = 0
$Script:Errors = 0

# Utility functions
function Write-Info { param($Message) Write-Host "ℹ️  $Message" -ForegroundColor Cyan }
function Write-Success { param($Message) Write-Host "✅ $Message" -ForegroundColor Green }
function Write-Warning { 
    param($Message) 
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
    $Script:Warnings++
}
function Write-Error-Custom { 
    param($Message) 
    Write-Host "❌ $Message" -ForegroundColor Red
    $Script:Errors++
    $Script:OverallStatus = 1
}

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

function Test-SystemTools {
    Write-Info "Checking system tools..."
    
    $tools = @("git", "curl", "python")
    foreach ($tool in $tools) {
        if (Test-CommandExists $tool) {
            try {
                $version = switch ($tool) {
                    "git" { (git --version) -replace "git version ", "" }
                    "curl" { (curl --version).Split()[1] }
                    "python" { (python --version) -replace "Python ", "" }
                }
                Write-Success "$tool $version"
            } catch {
                Write-Success "$tool (version detection failed)"
            }
        } else {
            Write-Error-Custom "$tool not found"
        }
    }
}

function Test-GitConfig {
    Write-Info "Checking Git configuration..."
    
    if ((Test-CommandExists git) -and (Test-Path ".git")) {
        try {
            $userName = git config user.name 2>$null
            $userEmail = git config user.email 2>$null
            
            if ($userName -and $userEmail) {
                Write-Success "Git user configured: $userName <$userEmail>"
            } else {
                Write-Warning "Git user not configured. Run: git config --global user.name 'Your Name' ; git config --global user.email 'your.email@example.com'"
            }
            
            # Check pre-commit
            if (Test-CommandExists pre-commit) {
                if (Test-Path ".pre-commit-config.yaml") {
                    try {
                        pre-commit validate-config 2>$null | Out-Null
                        Write-Success "Pre-commit configuration valid"
                    } catch {
                        Write-Warning "Pre-commit configuration invalid"
                    }
                } else {
                    Write-Warning "No .pre-commit-config.yaml found"
                }
            } else {
                Write-Warning "pre-commit not installed"
            }
        } catch {
            Write-Warning "Git configuration check failed"
        }
    } else {
        Write-Warning "Not a Git repository or Git not available"
    }
}

function Test-LanguageTools {
    param($Language)
    Write-Info "Checking $Language tools..."
    
    switch ($Language) {
        "python" {
            if (Test-CommandExists python) {
                try {
                    $pythonVersion = (python --version) -replace "Python ", ""
                    Write-Success "Python $pythonVersion"
                    
                    # Check pip
                    try {
                        python -m pip --version | Out-Null
                        $pipVersion = (python -m pip --version).Split()[1]
                        Write-Success "pip $pipVersion"
                    } catch {
                        Write-Error-Custom "pip not available"
                    }
                    
                    # Check common dev tools
                    $devTools = @("ruff", "black", "pytest")
                    foreach ($tool in $devTools) {
                        try {
                            python -c "import $tool" 2>$null
                            Write-Success "$tool available"
                        } catch {
                            if (Test-CommandExists $tool) {
                                Write-Success "$tool available"
                            } else {
                                Write-Warning "$tool not installed (install with: pip install $tool)"
                            }
                        }
                    }
                    
                    # Check project dependencies
                    if (Test-Path "requirements.txt") {
                        try {
                            python -m pip check 2>$null | Out-Null
                            Write-Success "Dependencies satisfied"
                        } catch {
                            Write-Warning "Dependency conflicts detected. Run: pip install -r requirements.txt"
                        }
                    }
                } catch {
                    Write-Error-Custom "Python check failed"
                }
            } else {
                Write-Error-Custom "Python not found"
            }
        }
        
        "java" {
            $javaFound = $false
            if (Test-CommandExists java) {
                try {
                    $javaVersion = (java -version 2>&1 | Select-String "version").ToString().Split('"')[1]
                    Write-Success "Java $javaVersion"
                    $javaFound = $true
                } catch {
                    Write-Success "Java (version detection failed)"
                    $javaFound = $true
                }
            }
            
            if (Test-CommandExists mvn) {
                try {
                    $mvnVersion = (mvn --version | Select-String "Apache Maven").ToString().Split()[2]
                    Write-Success "Maven $mvnVersion"
                    $javaFound = $true
                } catch {
                    Write-Success "Maven (version detection failed)"
                    $javaFound = $true
                }
            } elseif (Test-CommandExists gradle) {
                try {
                    $gradleVersion = (gradle --version | Select-String "Gradle").ToString().Split()[1]
                    Write-Success "Gradle $gradleVersion"
                    $javaFound = $true
                } catch {
                    Write-Success "Gradle (version detection failed)"
                    $javaFound = $true
                }
            }
            
            if (-not $javaFound) {
                Write-Error-Custom "Java development tools not found"
            }
        }
        
        "node" {
            if (Test-CommandExists node) {
                try {
                    $nodeVersion = node --version
                    Write-Success "Node.js $nodeVersion"
                    
                    if (Test-CommandExists npm) {
                        $npmVersion = npm --version
                        Write-Success "npm $npmVersion"
                        
                        if (Test-Path "node_modules") {
                            Write-Success "Dependencies installed"
                        } else {
                            Write-Warning "No node_modules found. Run: npm install"
                        }
                    } else {
                        Write-Error-Custom "npm not found"
                    }
                } catch {
                    Write-Error-Custom "Node.js check failed"
                }
            } else {
                Write-Error-Custom "Node.js not found"
            }
        }
        
        "go" {
            if (Test-CommandExists go) {
                try {
                    $goVersion = (go version).Split()[2]
                    Write-Success "Go $goVersion"
                    
                    if (Test-Path "go.mod") {
                        try {
                            go list -m 2>$null | Out-Null
                            Write-Success "Go module valid"
                        } catch {
                            Write-Warning "Go module issues. Run: go mod tidy"
                        }
                    }
                    
                    if (Test-CommandExists golangci-lint) {
                        Write-Success "golangci-lint available"
                    } else {
                        Write-Warning "golangci-lint not installed"
                    }
                } catch {
                    Write-Error-Custom "Go check failed"
                }
            } else {
                Write-Error-Custom "Go not found"
            }
        }
        
        "flutter" {
            if (Test-CommandExists flutter) {
                try {
                    $flutterVersion = (flutter --version | Select-Object -First 1).Split()[1]
                    Write-Success "Flutter $flutterVersion"
                    
                    Write-Info "Running flutter doctor..."
                    try {
                        flutter doctor 2>$null | Out-Null
                        Write-Success "Flutter doctor passed"
                    } catch {
                        Write-Warning "Flutter doctor found issues. Run: flutter doctor"
                    }
                } catch {
                    Write-Error-Custom "Flutter check failed"
                }
            } else {
                Write-Error-Custom "Flutter not found"
            }
        }
        
        "rust" {
            if ((Test-CommandExists rustc) -and (Test-CommandExists cargo)) {
                try {
                    $rustVersion = (rustc --version).Split()[1]
                    $cargoVersion = (cargo --version).Split()[1]
                    Write-Success "Rust $rustVersion, Cargo $cargoVersion"
                    
                    if (Test-Path "Cargo.toml") {
                        try {
                            cargo check --quiet 2>$null | Out-Null
                            Write-Success "Cargo project valid"
                        } catch {
                            Write-Warning "Cargo project issues. Run: cargo check"
                        }
                    }
                } catch {
                    Write-Error-Custom "Rust check failed"
                }
            } else {
                Write-Error-Custom "Rust toolchain not found"
            }
        }
        
        "csharp" {
            if (Test-CommandExists dotnet) {
                try {
                    $dotnetVersion = dotnet --version
                    Write-Success ".NET SDK $dotnetVersion"
                    
                    if ((Get-ChildItem -Path . -Recurse -Include "*.csproj","*.sln","*.fsproj" -Depth 2).Count -gt 0) {
                        try {
                            dotnet restore --verbosity quiet 2>$null | Out-Null
                            Write-Success "Project dependencies restored"
                        } catch {
                            Write-Warning "Project issues. Run: dotnet restore"
                        }
                    }
                } catch {
                    Write-Error-Custom ".NET SDK check failed"
                }
            } else {
                Write-Error-Custom ".NET SDK not found"
            }
        }
        
        "unknown" {
            Write-Warning "Unknown project type - skipping language-specific checks"
        }
    }
}

function Test-ProjectStructure {
    Write-Info "Checking project structure..."
    
    $requiredDirs = @("coverage", "build", ".vscode")
    foreach ($dir in $requiredDirs) {
        if (Test-Path $dir) {
            Write-Success "Directory $dir exists"
        } else {
            Write-Warning "Directory $dir missing (will be created automatically)"
        }
    }
    
    if (Test-Path "automation.config.yaml") {
        Write-Success "Automation config found"
    } else {
        Write-Warning "automation.config.yaml not found"
    }
}

function Test-ScriptPermissions {
    Write-Info "Checking script permissions..."
    
    $scriptsDir = "scripts"
    if (Test-Path $scriptsDir) {
        $psScripts = Get-ChildItem -Path $scriptsDir -Filter "*.ps1" -ErrorAction SilentlyContinue
        if ($psScripts.Count -gt 0) {
            Write-Success "Found $($psScripts.Count) PowerShell scripts"
        }
        
        $bashScripts = Get-ChildItem -Path $scriptsDir -Filter "*.sh" -ErrorAction SilentlyContinue
        if ($bashScripts.Count -gt 0) {
            Write-Success "Found $($bashScripts.Count) shell scripts (for WSL/Git Bash)"
        }
    }
}

function Invoke-Main {
    try {
        $language = Get-DetectedLanguage
        
        Write-Info "Project root: $ProjectRoot"
        Write-Info "Detected language: $language"
        Write-Host ""
        
        Test-SystemTools
        Write-Host ""
        Test-GitConfig
        Write-Host ""
        Test-LanguageTools $language
        Write-Host ""
        Test-ProjectStructure
        Write-Host ""
        Test-ScriptPermissions
        Write-Host ""
        
        # Summary
        Write-Host "📊 Health Check Summary" -ForegroundColor Blue
        Write-Host "========================" -ForegroundColor Blue
        
        if ($Script:Errors -eq 0 -and $Script:Warnings -eq 0) {
            Write-Success "All checks passed! Your development environment is ready."
        } elseif ($Script:Errors -eq 0) {
            Write-Warning "$($Script:Warnings) warning(s) found, but no critical errors."
            Write-Host "💡 Your environment should work, but consider addressing the warnings." -ForegroundColor Cyan
        } else {
            Write-Host "❌ $($Script:Errors) error(s) and $($Script:Warnings) warning(s) found." -ForegroundColor Red
            Write-Host "💡 Please resolve the errors before proceeding." -ForegroundColor Cyan
        }
        
        Write-Host ""
        if ($Script:OverallStatus -eq 0) {
            Write-Host "🚀 Ready to start development!" -ForegroundColor Green
            Write-Host "💡 Next steps:" -ForegroundColor Cyan
            Write-Host "   1. Run '.\scripts\lint.ps1' to check code quality"
            Write-Host "   2. Run '.\scripts\test.ps1' to run tests"
            Write-Host "   3. Run '.\scripts\build.ps1' to build the project"
        } else {
            Write-Host "⚡ Run '.\scripts\bootstrap.ps1' to set up missing tools" -ForegroundColor Yellow
        }
        
        exit $Script:OverallStatus
    } catch {
        Write-Host "❌ Health check failed: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

Invoke-Main