@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
ECHO == AshTrail dev generate ==
python scripts\generate_from_feature_matrix.py || GOTO :err
flutter pub run build_runner build --delete-conflicting-outputs || GOTO :err
flutter analyze || GOTO :err
IF EXIST test (FOR /F %%i IN ('dir /b test') DO (flutter test --coverage || GOTO :err & GOTO :after))
:after
ECHO Done.
EXIT /B 0
:err
ECHO Generation failed.
EXIT /B 1
