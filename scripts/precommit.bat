@echo off
echo Running pre-commit quality gate...
call scripts\quality_gate.bat
IF %ERRORLEVEL% NEQ 0 (
  echo Quality gate failed.
  EXIT /B 1
)
echo Pre-commit checks passed (quality gate).
