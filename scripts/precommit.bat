@echo off
echo Running pre-commit checks...
flutter format --set-exit-if-changed .
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
flutter analyze
IF %ERRORLEVEL% NEQ 0 EXIT /B 1
flutter test --tags=fast
IF %ERRORLEVEL% NEQ 0 (
  echo Fast tests failed, running full test suite...
  flutter test
  IF %ERRORLEVEL% NEQ 0 EXIT /B 1
)
echo Pre-commit checks passed.
