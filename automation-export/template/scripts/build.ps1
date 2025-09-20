#Requires -Version 5.1
[CmdletBinding()]
param(
    [switch]$Release,
    [switch]$Clean,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

if ($Help) {
    Write-Host "Build Script" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Usage: .\scripts\build.ps1 [OPTIONS]" -ForegroundColor White
    Write-Host ""
    Write-Host "Options:" -ForegroundColor White
    Write-Host "  -Release    Build in release/production mode" -ForegroundColor Gray
    Write-Host "  -Clean      Clean build artifacts before building" -ForegroundColor Gray
    Write-Host "  -Help       Show this help message" -ForegroundColor Gray
    Write-Host ""
    Write-Host "This script will:" -ForegroundColor White
    Write-Host "  ✓ Detect project language automatically" -ForegroundColor Gray
    Write-Host "  ✓ Run language-specific build process" -ForegroundColor Gray
    Write-Host "  ✓ Generate optimized builds (if -Release specified)" -ForegroundColor Gray
    Write-Host "  ✓ Verify build outputs" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Supported languages: python, java, node, go, flutter, rust, csharp" -ForegroundColor White
    exit 0
}

Write-Host "🏗️  Building Project" -ForegroundColor Green
Write-Host "==================" -ForegroundColor Green

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

function Invoke-Build {
    param($Language, $ReleaseMode, $CleanFirst)
    
    Write-Info "Building $Language project (release: $ReleaseMode, clean: $CleanFirst)..."
    
    # Ensure build directory exists
    if (-not (Test-Path "build")) {
        New-Item -ItemType Directory -Path "build" -Force | Out-Null
    }
    
    switch ($Language) {
        "python" {
            if ($CleanFirst) {
                Write-Info "Cleaning Python build artifacts..."
                Remove-Item -Path "build", "dist" -Recurse -Force -ErrorAction SilentlyContinue
                Get-ChildItem -Path . -Recurse -Directory -Name "*egg-info" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                Get-ChildItem -Path . -Recurse -Directory -Name "__pycache__" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                Get-ChildItem -Path . -Recurse -Directory -Name ".pytest_cache" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
                Get-ChildItem -Path . -Recurse -Filter "*.pyc" | Remove-Item -Force -ErrorAction SilentlyContinue
            }
            
            Write-Info "Building Python package..."
            if (Test-Path "pyproject.toml") {
                if (Test-CommandExists python) {
                    python -m build
                } else {
                    python3 -m build
                }
            } elseif (Test-Path "setup.py") {
                if (Test-CommandExists python) {
                    python setup.py sdist bdist_wheel
                } else {
                    python3 setup.py sdist bdist_wheel
                }
            } else {
                Write-Warning "No build configuration found (pyproject.toml or setup.py)"
                Write-Info "Creating basic package structure..."
                if (Test-CommandExists python) {
                    python -c "import py_compile; import glob; [py_compile.compile(f, doraise=True) for f in glob.glob('**/*.py', recursive=True)]"
                } else {
                    python3 -c "import py_compile; import glob; [py_compile.compile(f, doraise=True) for f in glob.glob('**/*.py', recursive=True)]"
                }
            }
        }
        
        "java" {
            if (Test-CommandExists mvn) {
                Write-Info "Building Java project with Maven..."
                $mvnArgs = @()
                
                if ($CleanFirst) {
                    $mvnArgs += "clean"
                }
                
                if ($ReleaseMode) {
                    $mvnArgs += @("package", "-Dmaven.test.skip=true")
                } else {
                    $mvnArgs += "compile"
                }
                
                mvn @mvnArgs
                
            } elseif (Test-CommandExists gradle) {
                Write-Info "Building Java project with Gradle..."
                $gradleArgs = @()
                
                if ($CleanFirst) {
                    $gradleArgs += "clean"
                }
                
                if ($ReleaseMode) {
                    $gradleArgs += @("build", "-x", "test")
                } else {
                    $gradleArgs += "compileJava"
                }
                
                gradle @gradleArgs
            } else {
                Write-Error-Custom "Neither Maven nor Gradle found"
                return $false
            }
        }
        
        "node" {
            if ($CleanFirst) {
                Write-Info "Cleaning Node.js build artifacts..."
                Remove-Item -Path "node_modules\.cache", "build", "dist" -Recurse -Force -ErrorAction SilentlyContinue
            }
            
            Write-Info "Installing Node.js dependencies..."
            try {
                npm ci --prefer-offline
            } catch {
                npm install
            }
            
            if ((Test-Path "package.json") -and (Select-String -Path "package.json" -Pattern '"build"')) {
                Write-Info "Running Node.js build script..."
                if ($ReleaseMode) {
                    if (Select-String -Path "package.json" -Pattern '"build:prod"') {
                        npm run build:prod
                    } else {
                        $env:NODE_ENV = "production"
                        npm run build
                    }
                } else {
                    npm run build
                }
            } else {
                Write-Warning "No build script found in package.json"
            }
        }
        
        "go" {
            if ($CleanFirst) {
                Write-Info "Cleaning Go build artifacts..."
                try {
                    go clean -cache -modcache -testcache
                } catch { }
                Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue
            }
            
            Write-Info "Building Go project..."
            $goArgs = @("build")
            
            if ($ReleaseMode) {
                $goArgs += @("-ldflags", "-s -w")  # Strip debug info
            }
            
            # Build to build directory
            $goArgs += @("-o", "build/")
            $goArgs += "./..."
            
            go @goArgs
        }
        
        "flutter" {
            if ($CleanFirst) {
                Write-Info "Cleaning Flutter build artifacts..."
                flutter clean
            }
            
            Write-Info "Getting Flutter dependencies..."
            flutter pub get
            
            # Run code generation if needed
            if (Select-String -Path "pubspec.yaml" -Pattern "build_runner") {
                Write-Info "Running code generation..."
                flutter packages pub run build_runner build --delete-conflicting-outputs
            }
            
            Write-Info "Building Flutter app..."
            if ($ReleaseMode) {
                flutter build apk --release
            } else {
                flutter build apk --debug
            }
        }
        
        "rust" {
            if ($CleanFirst) {
                Write-Info "Cleaning Rust build artifacts..."
                cargo clean
            }
            
            Write-Info "Building Rust project..."
            $cargoArgs = @("build")
            
            if ($ReleaseMode) {
                $cargoArgs += "--release"
            }
            
            cargo @cargoArgs
        }
        
        "csharp" {
            if ($CleanFirst) {
                Write-Info "Cleaning .NET build artifacts..."
                dotnet clean
            }
            
            Write-Info "Restoring .NET dependencies..."
            dotnet restore
            
            Write-Info "Building .NET project..."
            $dotnetArgs = @("build")
            
            if ($ReleaseMode) {
                $dotnetArgs += @("--configuration", "Release")
            }
            
            dotnet @dotnetArgs
        }
        
        "unknown" {
            Write-Error-Custom "Unknown project type - cannot build"
            return $false
        }
    }
    
    return $true
}

function Test-BuildOutputs {
    param($Language)
    
    Write-Info "Checking build outputs..."
    
    switch ($Language) {
        "python" {
            if (Test-Path "dist") {
                $wheelFiles = Get-ChildItem -Path "dist" -Filter "*.whl" -ErrorAction SilentlyContinue
                $tarFiles = Get-ChildItem -Path "dist" -Filter "*.tar.gz" -ErrorAction SilentlyContinue
                Write-Success "Python package built: $($wheelFiles.Count) wheel(s), $($tarFiles.Count) source archive(s)"
            }
        }
        
        "java" {
            $targetJars = Get-ChildItem -Path "target" -Filter "*.jar" -ErrorAction SilentlyContinue
            $buildJars = Get-ChildItem -Path "build/libs" -Filter "*.jar" -ErrorAction SilentlyContinue
            
            if ($targetJars.Count -gt 0) {
                Write-Success "Maven JAR built: $($targetJars[0].Name)"
            } elseif ($buildJars.Count -gt 0) {
                Write-Success "Gradle JAR built: $($buildJars[0].Name)"
            }
        }
        
        "node" {
            if ((Test-Path "build") -or (Test-Path "dist")) {
                Write-Success "Node.js build outputs created"
            }
        }
        
        "go" {
            if (Test-Path "build") {
                $binaries = Get-ChildItem -Path "build" -ErrorAction SilentlyContinue
                Write-Success "Go binaries built: $($binaries.Count) executable(s)"
            }
        }
        
        "flutter" {
            $debugApk = Test-Path "build/app/outputs/flutter-apk/app-debug.apk"
            $releaseApk = Test-Path "build/app/outputs/flutter-apk/app-release.apk"
            if ($debugApk -or $releaseApk) {
                Write-Success "Flutter APK built"
            }
        }
        
        "rust" {
            $debugBin = Get-ChildItem -Path "target/debug" -ErrorAction SilentlyContinue
            $releaseBin = Get-ChildItem -Path "target/release" -ErrorAction SilentlyContinue
            if ($debugBin.Count -gt 0 -or $releaseBin.Count -gt 0) {
                Write-Success "Rust binary built"
            }
        }
        
        "csharp" {
            $assemblies = Get-ChildItem -Path . -Recurse -Include "*.dll", "*.exe" | Where-Object { $_.FullName -like "*\bin\*" }
            if ($assemblies.Count -gt 0) {
                Write-Success ".NET assemblies built"
            }
        }
    }
}

function Invoke-Main {
    try {
        $language = Get-DetectedLanguage
        Write-Info "Project root: $ProjectRoot"
        Write-Info "Detected language: $language"
        
        if ($Release) {
            Write-Info "Building in RELEASE mode"
        } else {
            Write-Info "Building in DEBUG mode"
        }
        
        if ($Clean) {
            Write-Info "Will clean before building"
        }
        
        Write-Host ""
        
        # Run build
        $buildStatus = Invoke-Build $language $Release $Clean
        
        # Check outputs if build succeeded
        if ($buildStatus) {
            Write-Host ""
            Test-BuildOutputs $language
        }
        
        Write-Host ""
        
        # Summary
        if ($buildStatus) {
            Write-Success "Build completed successfully!"
            Write-Host ""
            Write-Info "💡 Next steps:"
            Write-Host "   1. Test your build artifacts"
            Write-Host "   2. Deploy or distribute your application"
            if (-not $Release) {
                Write-Host "   3. Consider building with -Release for production"
            }
            exit 0
        } else {
            Write-Error-Custom "Build failed!"
            Write-Info "💡 Tips:"
            Write-Host "   1. Check build output above for specific errors"
            Write-Host "   2. Ensure all dependencies are installed"
            Write-Host "   3. Run '.\scripts\doctor.ps1' to check environment"
            Write-Host "   4. Try building with -Clean to start fresh"
            exit 1
        }
    } catch {
        Write-Error-Custom "Build failed: $($_.Exception.Message)"
        exit 1
    }
}

Invoke-Main