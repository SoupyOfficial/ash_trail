#Requires -Version 5.1
[CmdletBinding()]
param(
    [switch]$Coverage,
    [switch]$Verbose,
    [switch]$NoCoverageCheck,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

if ($Help) {
    Write-Host "Test Runner Script" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Usage: .\scripts\test.ps1 [OPTIONS]" -ForegroundColor White
    Write-Host ""
    Write-Host "Options:" -ForegroundColor White
    Write-Host "  -Coverage           Run tests with coverage reporting" -ForegroundColor Gray
    Write-Host "  -Verbose            Run tests in verbose mode" -ForegroundColor Gray
    Write-Host "  -NoCoverageCheck    Skip coverage threshold checking" -ForegroundColor Gray
    Write-Host "  -Help               Show this help message" -ForegroundColor Gray
    Write-Host ""
    Write-Host "This script will:" -ForegroundColor White
    Write-Host "  ✓ Detect project language automatically" -ForegroundColor Gray
    Write-Host "  ✓ Run language-specific test suites" -ForegroundColor Gray
    Write-Host "  ✓ Generate coverage reports (if requested)" -ForegroundColor Gray
    Write-Host "  ✓ Check coverage thresholds" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Supported languages: python, java, node, go, flutter, rust, csharp" -ForegroundColor White
    exit 0
}

Write-Host "🧪 Running Tests" -ForegroundColor Green
Write-Host "===============" -ForegroundColor Green

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

function Invoke-Tests {
    param($Language, $CoverageMode, $VerboseMode)
    
    Write-Info "Running $Language tests (coverage: $CoverageMode, verbose: $VerboseMode)..."
    
    # Ensure coverage directory exists
    if (-not (Test-Path "coverage")) {
        New-Item -ItemType Directory -Path "coverage" -Force | Out-Null
    }
    
    switch ($Language) {
        "python" {
            if ($CoverageMode) {
                Write-Info "Running Python tests with coverage..."
                if (Test-CommandExists pytest) {
                    $pytestArgs = @("--cov=.", "--cov-report=lcov:coverage/lcov.info", "--cov-report=term")
                    if ($VerboseMode) {
                        $pytestArgs += "-v"
                    } else {
                        $pytestArgs += "-q"
                    }
                    pytest @pytestArgs
                } else {
                    Write-Warning "pytest not found, falling back to unittest"
                    if (Test-CommandExists coverage) {
                        coverage run -m unittest discover
                        coverage lcov -o coverage/lcov.info
                        coverage report
                    } else {
                        python -m unittest discover
                    }
                }
            } else {
                Write-Info "Running Python tests..."
                if (Test-CommandExists pytest) {
                    if ($VerboseMode) {
                        pytest -v
                    } else {
                        pytest -q
                    }
                } else {
                    python -m unittest discover
                }
            }
        }
        
        "java" {
            if (Test-CommandExists mvn) {
                Write-Info "Running Java tests with Maven..."
                $mvnArgs = @("test")
                if ($CoverageMode) {
                    $mvnArgs += "jacoco:report"
                }
                if (-not $VerboseMode) {
                    $mvnArgs = @("-q") + $mvnArgs
                }
                mvn @mvnArgs
            } elseif (Test-CommandExists gradle) {
                Write-Info "Running Java tests with Gradle..."
                $gradleArgs = @("test")
                if ($CoverageMode) {
                    $gradleArgs += "jacocoTestReport"
                }
                if (-not $VerboseMode) {
                    $gradleArgs = @("--quiet") + $gradleArgs
                }
                gradle @gradleArgs
            } else {
                Write-Error-Custom "Neither Maven nor Gradle found"
                return $false
            }
        }
        
        "node" {
            if (Test-Path "package.json") {
                if ($CoverageMode) {
                    if (Select-String -Path "package.json" -Pattern '"test:coverage"') {
                        Write-Info "Running Node.js tests with coverage..."
                        npm run test:coverage
                    } elseif (Test-CommandExists nyc) {
                        Write-Info "Running Node.js tests with nyc coverage..."
                        nyc npm test
                    } else {
                        Write-Warning "No coverage tool found, running tests without coverage"
                        npm test
                    }
                } else {
                    Write-Info "Running Node.js tests..."
                    if ($VerboseMode) {
                        npm test -- --verbose
                    } else {
                        npm test
                    }
                }
            } else {
                Write-Error-Custom "package.json not found"
                return $false
            }
        }
        
        "go" {
            Write-Info "Running Go tests..."
            $goArgs = @("test", "./...")
            
            if ($CoverageMode) {
                $goArgs += "-coverprofile=coverage/coverage.out"
            }
            
            if ($VerboseMode) {
                $goArgs += "-v"
            }
            
            go @goArgs
            
            if ($CoverageMode -and (Test-Path "coverage/coverage.out")) {
                Write-Info "Generating coverage report..."
                go tool cover -func=coverage/coverage.out
                # Convert to lcov format if gcov2lcov is available
                if (Test-CommandExists gcov2lcov) {
                    gcov2lcov -infile coverage/coverage.out -outfile coverage/lcov.info
                }
            }
        }
        
        "flutter" {
            Write-Info "Running Flutter tests..."
            $flutterArgs = @("test")
            
            if ($CoverageMode) {
                $flutterArgs += "--coverage"
            }
            
            if (-not $VerboseMode) {
                $flutterArgs += @("--reporter", "compact")
            }
            
            flutter @flutterArgs
        }
        
        "rust" {
            Write-Info "Running Rust tests..."
            $cargoArgs = @("test")
            
            if ($VerboseMode) {
                $cargoArgs += "--verbose"
            }
            
            if ($CoverageMode) {
                if (Test-CommandExists cargo-tarpaulin) {
                    Write-Info "Running tests with coverage using tarpaulin..."
                    cargo tarpaulin --out lcov --output-dir coverage
                } else {
                    Write-Warning "cargo-tarpaulin not found, running tests without coverage"
                    cargo @cargoArgs
                }
            } else {
                cargo @cargoArgs
            }
        }
        
        "csharp" {
            Write-Info "Running .NET tests..."
            $dotnetArgs = @("test")
            
            if ($CoverageMode) {
                $dotnetArgs += "--collect:XPlat Code Coverage"
            }
            
            if (-not $VerboseMode) {
                $dotnetArgs += @("--verbosity", "quiet")
            }
            
            dotnet @dotnetArgs
        }
        
        "unknown" {
            Write-Error-Custom "Unknown project type - cannot run tests"
            return $false
        }
    }
    
    return $true
}

function Test-Coverage {
    param($Language)
    
    Write-Info "Checking coverage thresholds..."
    
    $coverageFile = ""
    $threshold = 80  # Default threshold
    
    # Find coverage file based on language
    switch ($Language) {
        "python" { $coverageFile = "coverage/lcov.info" }
        "flutter" { $coverageFile = "coverage/lcov.info" }
        "java" { 
            $javaFile = Get-ChildItem -Path . -Recurse -Filter "*jacoco*.xml" | Select-Object -First 1
            if ($javaFile) { $coverageFile = $javaFile.FullName }
        }
        "node" {
            if (Test-Path "coverage/lcov.info") {
                $coverageFile = "coverage/lcov.info"
            } elseif (Test-Path "coverage/coverage-final.json") {
                $coverageFile = "coverage/coverage-final.json"
            }
        }
        "go" { $coverageFile = "coverage/coverage.out" }
        "rust" { $coverageFile = "coverage/lcov.info" }
        "csharp" {
            $csFile = Get-ChildItem -Path . -Recurse -Filter "coverage.cobertura.xml" | Select-Object -First 1
            if ($csFile) { $coverageFile = $csFile.FullName }
        }
    }
    
    if ($coverageFile -and (Test-Path $coverageFile)) {
        Write-Info "Found coverage file: $coverageFile"
        
        # Calculate coverage percentage based on file type
        $coveragePct = 0
        
        if ($coverageFile -like "*.lcov*") {
            # LCOV format
            $content = Get-Content $coverageFile
            $hitLines = ($content | Where-Object { $_ -match "^DA:.*,1$" }).Count
            $totalLines = ($content | Where-Object { $_ -match "^DA:" }).Count
            if ($totalLines -gt 0) {
                $coveragePct = [math]::Round(($hitLines / $totalLines) * 100, 1)
            }
        } elseif ($coverageFile -like "*.json*") {
            # JSON format (Node.js)
            try {
                $json = Get-Content $coverageFile | ConvertFrom-Json
                $coveragePct = $json.total.lines.pct
            } catch {
                $coveragePct = 0
            }
        } elseif ($coverageFile -like "*.out*") {
            # Go coverage format
            try {
                $output = go tool cover -func=$coverageFile
                $lastLine = $output | Select-Object -Last 1
                if ($lastLine -match "(\d+\.\d+)%") {
                    $coveragePct = [double]$matches[1]
                }
            } catch {
                $coveragePct = 0
            }
        }
        
        Write-Info "Coverage: ${coveragePct}%"
        
        # Check threshold
        if ($coveragePct -ge $threshold) {
            Write-Success "Coverage ${coveragePct}% meets threshold of ${threshold}%"
        } else {
            Write-Warning "Coverage ${coveragePct}% below threshold of ${threshold}%"
            return $false
        }
    } else {
        Write-Warning "No coverage file found, skipping threshold check"
    }
    
    return $true
}

function Invoke-Main {
    try {
        $language = Get-DetectedLanguage
        Write-Info "Project root: $ProjectRoot"
        Write-Info "Detected language: $language"
        
        if ($Coverage) {
            Write-Info "Coverage reporting enabled"
        }
        
        if ($Verbose) {
            Write-Info "Verbose mode enabled"
        }
        
        Write-Host ""
        
        # Run tests
        $testStatus = Invoke-Tests $language $Coverage $Verbose
        
        # Check coverage if enabled and tests passed
        $coverageStatus = $true
        if ($testStatus -and $Coverage -and -not $NoCoverageCheck) {
            Write-Host ""
            $coverageStatus = Test-Coverage $language
        }
        
        Write-Host ""
        
        # Summary
        if ($testStatus -and $coverageStatus) {
            Write-Success "All tests passed!"
            if ($Coverage) {
                Write-Info "💡 Coverage reports generated in coverage/ directory"
            }
            Write-Host ""
            Write-Info "💡 Next steps:"
            Write-Host "   1. Run '.\scripts\build.ps1' to build the project"
            Write-Host "   2. Check coverage reports for improvement opportunities"
            exit 0
        } else {
            Write-Error-Custom "Tests failed!"
            Write-Info "💡 Tips:"
            Write-Host "   1. Check test output above for specific failures"
            Write-Host "   2. Run with -Verbose for more detailed output"
            Write-Host "   3. Fix failing tests before proceeding"
            exit 1
        }
    } catch {
        Write-Error-Custom "Test execution failed: $($_.Exception.Message)"
        exit 1
    }
}

Invoke-Main