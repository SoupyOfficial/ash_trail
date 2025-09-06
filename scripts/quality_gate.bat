@echo off
REM Unified quality gate for Windows
SETLOCAL ENABLEDELAYEDEXPANSION

ECHO === AshTrail Quality Gate ===

ECHO * Formatting check
python scripts\branch_policy.py --allow-main
IF %ERRORLEVEL% NEQ 0 (
  ECHO Branch policy violation.
  EXIT /B 1
)
flutter format --set-exit-if-changed .
IF %ERRORLEVEL% NEQ 0 (
  ECHO Format changes required.
  EXIT /B 1
)

ECHO * Static analysis
flutter analyze
IF %ERRORLEVEL% NEQ 0 EXIT /B 1

ECHO * Running tests with coverage
flutter test --coverage
IF %ERRORLEVEL% NEQ 0 EXIT /B 1

ECHO * Parsing coverage threshold
python scripts\dev_assistant.py test-coverage --json > %TEMP%\cov.json 2> NUL
IF %ERRORLEVEL% NEQ 0 ECHO Warning: dev assistant returned non-zero (may be coverage below target)
for /f "usebackq tokens=2 delims::, " %%A in (`findstr /I "line_coverage" %TEMP%\cov.json`) do set COV=%%A

ECHO Detected coverage: !COV!

REM naive numeric extract
for /f "tokens=* delims= " %%B in ("!COV!") do set COVCLEAN=%%B
REM Remove quotes and commas
set COVCLEAN=!COVCLEAN: =!
set COVCLEAN=!COVCLEAN:,.=!
set COVCLEAN=!COVCLEAN:"=!

ECHO Coverage numeric: !COVCLEAN!

REM Compare (integer floor)
for /f "delims=. tokens=1" %%C in ("!COVCLEAN!") do set COVINT=%%C
IF !COVINT! LSS 80 (
  ECHO Coverage below 80%% (detected !COVCLEAN!)
  EXIT /B 1
)

ECHO * Patch coverage check
REM Invokes patch_coverage.py to enforce per-diff coverage (threshold default 85%)
python scripts\patch_coverage.py --json > %TEMP%\patch_cov.json 2> NUL
IF %ERRORLEVEL% NEQ 0 (
  ECHO Patch coverage below threshold.
  type %TEMP%\patch_cov.json
  EXIT /B 1
)
for /f "usebackq tokens=2 delims::, " %%A in (`findstr /I "patch_coverage_pct" %TEMP%\patch_cov.json`) do set PATCH=%%A
ECHO Patch coverage: !PATCH!

ECHO Quality gate passed.
EXIT /B 0
