@echo off
setlocal EnableDelayedExpansion

REM AI/ML Virtual Environment Setup Script for Windows
REM This script automates the creation and setup of a Python virtual environment for Kaggle competitions

title AI/ML Environment Setup

REM Colors for output (Windows 10+ with ANSI support)
set "RED=[91m"
set "GREEN=[92m"
set "YELLOW=[93m"
set "BLUE=[94m"
set "NC=[0m"

REM Function to print colored output
goto :main

:print_status
echo %BLUE%[INFO]%NC% %~1
goto :eof

:print_success
echo %GREEN%[SUCCESS]%NC% %~1
goto :eof

:print_warning
echo %YELLOW%[WARNING]%NC% %~1
goto :eof

:print_error
echo %RED%[ERROR]%NC% %~1
goto :eof

:check_python
call :print_status "Checking for Python 3.12..."

REM Try different Python 3.12 commands
python --version >nul 2>&1
if !errorlevel! == 0 (
    for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
    echo !PYTHON_VERSION! | findstr "3.12" >nul
    if !errorlevel! == 0 (
        set "PYTHON_CMD=python"
        call :print_success "Found python ^(version 3.12^)"
        goto python_found
    )
)

py -3.12 --version >nul 2>&1
if !errorlevel! == 0 (
    set "PYTHON_CMD=py -3.12"
    call :print_success "Found py -3.12"
    goto python_found
)

python3.12 --version >nul 2>&1
if !errorlevel! == 0 (
    set "PYTHON_CMD=python3.12"
    call :print_success "Found python3.12"
    goto python_found
)

call :print_error "Python 3.12 not found!"
call :print_status "Please install Python 3.12 first:"
echo   Download from https://www.python.org/
echo   Or install via Microsoft Store
echo   Or use: winget install Python.Python.3.12
pause
exit /b 1

:python_found
for /f "tokens=*" %%i in ('!PYTHON_CMD! --version') do set PYTHON_VERSION=%%i
call :print_status "Using: !PYTHON_VERSION!"
goto :eof

:create_venv
call :print_status "Creating virtual environment..."

if exist ".venv" (
    call :print_warning "Virtual environment already exists at .venv"
    set /p "recreate=Do you want to recreate it? (y/N): "
    if /i "!recreate!"=="y" (
        call :print_status "Removing existing virtual environment..."
        rmdir /s /q .venv
    ) else (
        call :print_status "Using existing virtual environment"
        goto :eof
    )
)

call :print_status "Creating new virtual environment with !PYTHON_CMD!..."
!PYTHON_CMD! -m venv .venv

if exist ".venv" (
    call :print_success "Virtual environment created successfully!"
) else (
    call :print_error "Failed to create virtual environment"
    pause
    exit /b 1
)
goto :eof

:setup_venv
call :print_status "Activating virtual environment..."

REM Activate the virtual environment
call .venv\Scripts\activate.bat

REM Check if activation was successful
if defined VIRTUAL_ENV (
    call :print_success "Virtual environment activated: !VIRTUAL_ENV!"
) else (
    call :print_error "Failed to activate virtual environment"
    pause
    exit /b 1
)

call :print_status "Upgrading pip..."
python -m pip install --upgrade pip

call :print_success "Pip upgraded successfully"
goto :eof

:install_packages
call :print_status "Installing Python packages..."

if exist "requirements.txt" (
    call :print_status "Installing packages from requirements.txt..."
    pip install -r requirements.txt
    call :print_success "Packages installed from requirements.txt"
) else (
    call :print_status "No requirements.txt found. Installing essential AI/ML packages..."
    
    REM Essential packages for Kaggle competitions
    set PACKAGES=numpy pandas matplotlib seaborn plotly scikit-learn xgboost lightgbm catboost tensorflow torch torchvision transformers datasets accelerate jupyter ipykernel notebook scipy statsmodels opencv-python pillow tqdm joblib optuna wandb albumentations polars pyarrow
    
    call :print_status "Installing essential packages..."
    pip install !PACKAGES!
    
    REM Generate requirements.txt
    call :print_status "Generating requirements.txt..."
    pip freeze > requirements.txt
    
    REM Count lines in requirements.txt
    for /f %%i in ('find /c /v "" ^< requirements.txt') do set LINE_COUNT=%%i
    call :print_success "Generated requirements.txt with !LINE_COUNT! packages"
)
goto :eof

:verify_installation
call :print_status "Verifying installation..."

REM Create a temporary Python script for verification
echo import sys > verify_temp.py
echo print(f'Python version: {sys.version}') >> verify_temp.py
echo. >> verify_temp.py
echo packages = ['numpy', 'pandas', 'sklearn', 'matplotlib', 'torch', 'tensorflow'] >> verify_temp.py
echo for pkg in packages: >> verify_temp.py
echo     try: >> verify_temp.py
echo         __import__(pkg) >> verify_temp.py
echo         print(f'✓ {pkg}') >> verify_temp.py
echo     except ImportError: >> verify_temp.py
echo         print(f'✗ {pkg} - FAILED') >> verify_temp.py

python verify_temp.py
del verify_temp.py

call :print_success "Installation verification complete"
goto :eof

:setup_jupyter
call :print_status "Setting up Jupyter kernel..."

python -m ipykernel install --user --name kaggle-env --display-name "Kaggle Competition (Python 3.12)"

call :print_success "Jupyter kernel 'Kaggle Competition (Python 3.12)' installed"
call :print_status "You can now select this kernel in Jupyter notebooks"
goto :eof

:create_activation_script
if not exist "activate.bat" (
    call :print_status "Creating Windows activation script..."
    
    REM Create activate.bat
    (
    echo @echo off
    echo.
    echo echo 🚀 Activating AI/ML Python Environment...
    echo echo 📍 Project: %%cd%%
    echo echo.
    echo REM Activate the virtual environment
    echo call .venv\Scripts\activate.bat
    echo.
    echo if defined VIRTUAL_ENV ^(
    echo     echo ✅ Virtual environment activated successfully!
    echo     echo 📦 Environment: %%VIRTUAL_ENV%%
    echo     echo.
    echo     for /f "tokens=*" %%%%i in ^('python --version'^) do echo 🐍 Python: %%%%i
    echo     for /f "tokens=2" %%%%i in ^('pip --version'^) do echo 📦 pip: %%%%i
    echo     echo.
    echo     echo 💡 Quick commands:
    echo     echo    pip list          - Show installed packages
    echo     echo    jupyter notebook  - Start Jupyter notebook
    echo     echo    deactivate        - Exit virtual environment
    echo     echo.
    echo ^) else ^(
    echo     echo ❌ Failed to activate virtual environment
    echo     echo Make sure .venv directory exists in %%cd%%
    echo ^)
    ) > activate.bat
    
    call :print_success "Created activation script: activate.bat"
)
goto :eof

:main
echo ======================================
echo 🤖 AI/ML Environment Setup Script
echo ======================================
echo.

REM Check if we're in the right directory
for %%i in ("%cd%") do set "CURRENT_DIR=%%~nxi"
echo !CURRENT_DIR! | findstr "Demo" >nul
if !errorlevel! neq 0 (
    if not exist "main.py" (
        call :print_warning "You might not be in the correct project directory"
        call :print_status "Current directory: %cd%"
        set /p "continue=Continue anyway? (y/N): "
        if /i not "!continue!"=="y" (
            call :print_status "Aborted"
            pause
            exit /b 0
        )
    )
)

REM Run setup steps
call :check_python
if !errorlevel! neq 0 exit /b 1

call :create_venv
if !errorlevel! neq 0 exit /b 1

call :setup_venv
if !errorlevel! neq 0 exit /b 1

call :install_packages
if !errorlevel! neq 0 exit /b 1

call :verify_installation
if !errorlevel! neq 0 exit /b 1

call :setup_jupyter
if !errorlevel! neq 0 exit /b 1

call :create_activation_script
if !errorlevel! neq 0 exit /b 1

echo.
echo ======================================
call :print_success "🎉 Setup Complete!"
echo ======================================
echo.
call :print_status "Your AI/ML environment is ready for Kaggle competitions!"
echo.
call :print_status "Next steps:"
echo   1. Run: .venv\Scripts\activate.bat
echo   2. Or use: activate.bat
echo   3. Start coding: jupyter notebook
echo.
call :print_status "Environment details:"
echo   📁 Location: %cd%\.venv
for /f "tokens=*" %%i in ('!PYTHON_CMD! --version') do echo   🐍 Python: %%i
if exist "requirements.txt" (
    for /f %%i in ('find /c /v "" ^< requirements.txt') do echo   📦 Packages: %%i installed
)
echo.

pause
exit /b 0