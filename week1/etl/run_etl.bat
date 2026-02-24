@echo off
REM ────────────────────────────────────────────────
REM  ETL Pipeline - Run every 6 hours
REM ────────────────────────────────────────────────

set PYTHON_EXE=C:\Users\mukht\AppData\Local\Programs\Python\Python313\python.exe
set SCRIPT_PATH=C:\Users\mukht\mantisai-de-internship\week1\etl\pipeline.py
set PROJECT_FOLDER=C:\Users\mukht\mantisai-de-internship\week1\etl

"%PYTHON_EXE%" "%SCRIPT_PATH%"

:: === Log the running time in the etl_run_log file  ===
echo [%date% %time%] ETL pipeline executed >> "C:\Users\mukht\mantisai-de-internship\week1\logs\etl_run_log.txt"

exit