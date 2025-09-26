# AI/ML Virtual Environment Setup Script for Windows PowerShell
# This script automates the creation and setup of a Python virtual environment for Kaggle competitions

param(
    [switch]$Force = $false
)

# Enable colors in PowerShell console
if ($Host.UI.RawUI.ForegroundColor) {
    $colors = @{
        Red = "Red"
        Green = "Green" 
        Yellow = "Yellow"
        Blue = "Blue"
        Default = "White"
    }
} else {
    $colors = @{
        Red = "White"
        Green = "White"
        Yellow = "White" 
        Blue = "White"
        Default = "White"
    }
}

# Helper functions for colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] " -ForegroundColor $colors.Blue -NoNewline
    Write-Host $Message -ForegroundColor $colors.Default
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] " -ForegroundColor $colors.Green -NoNewline
    Write-Host $Message -ForegroundColor $colors.Default
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] " -ForegroundColor $colors.Yellow -NoNewline
    Write-Host $Message -ForegroundColor $colors.Default
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] " -ForegroundColor $colors.Red -NoNewline
    Write-Host $Message -ForegroundColor $colors.Default
}

# Function to check Python installation
function Test-Python {
    Write-Status "Checking for Python 3.12..."
    
    # Try different Python commands
    $pythonCommands = @(
        @{cmd="python"; args=@("--version")},
        @{cmd="py"; args=@("-3.12", "--version")},
        @{cmd="python3.12"; args=@("--version")}
    )
    
    foreach ($pyCmd in $pythonCommands) {
        try {
            $version = & $pyCmd.cmd $pyCmd.args 2>$null
            if ($version -match "Python 3\.12") {
                $script:PythonCommand = $pyCmd.cmd + " " + ($pyCmd.args[0..($pyCmd.args.Length-2)] -join " ")
                $script:PythonCommand = $script:PythonCommand.Trim()
                Write-Success "Found Python 3.12: $version"
                Write-Status "Using command: $script:PythonCommand"
                return $true
            }
        }
        catch {
            # Continue to next command
        }
    }
    
    Write-Error "Python 3.12 not found!"
    Write-Status "Please install Python 3.12 first:"
    Write-Host "  - Download from: https://www.python.org/"
    Write-Host "  - Microsoft Store: search 'Python 3.12'"
    Write-Host "  - Winget: winget install Python.Python.3.12"
    return $false
}

# Function to create virtual environment
function New-VirtualEnvironment {
    Write-Status "Creating virtual environment..."
    
    if (Test-Path ".venv") {
        Write-Warning "Virtual environment already exists at .venv"
        if (-not $Force) {
            $recreate = Read-Host "Do you want to recreate it? (y/N)"
            if ($recreate -ne "y" -and $recreate -ne "Y") {
                Write-Status "Using existing virtual environment"
                return $true
            }
        }
        
        Write-Status "Removing existing virtual environment..."
        Remove-Item -Recurse -Force ".venv"
    }
    
    Write-Status "Creating new virtual environment..."
    $createCmd = "$script:PythonCommand -m venv .venv"
    
    try {
        Invoke-Expression $createCmd
        if (Test-Path ".venv") {
            Write-Success "Virtual environment created successfully!"
            return $true
        } else {
            Write-Error "Failed to create virtual environment"
            return $false
        }
    }
    catch {
        Write-Error "Error creating virtual environment: $($_.Exception.Message)"
        return $false
    }
}

# Function to activate virtual environment and upgrade pip
function Initialize-VirtualEnvironment {
    Write-Status "Activating virtual environment and upgrading pip..."
    
    $activateScript = ".venv\Scripts\Activate.ps1"
    if (-not (Test-Path $activateScript)) {
        Write-Error "Virtual environment activation script not found"
        return $false
    }
    
    try {
        # Source the activation script
        . $activateScript
        
        Write-Success "Virtual environment activated"
        
        # Upgrade pip
        Write-Status "Upgrading pip..."
        python -m pip install --upgrade pip | Out-Null
        Write-Success "Pip upgraded successfully"
        
        return $true
    }
    catch {
        Write-Error "Failed to activate virtual environment: $($_.Exception.Message)"
        return $false
    }
}

# Function to install packages
function Install-Packages {
    Write-Status "Installing Python packages..."
    
    if (Test-Path "requirements.txt") {
        Write-Status "Installing packages from requirements.txt..."
        try {
            pip install -r requirements.txt
            Write-Success "Packages installed from requirements.txt"
        }
        catch {
            Write-Error "Failed to install packages from requirements.txt"
            return $false
        }
    } else {
        Write-Status "No requirements.txt found. Installing essential AI/ML packages..."
        
        $packages = @(
            "numpy", "pandas", "matplotlib", "seaborn", "plotly", 
            "scikit-learn", "xgboost", "lightgbm", "catboost",
            "tensorflow", "torch", "torchvision", "transformers", 
            "datasets", "accelerate", "jupyter", "ipykernel", 
            "notebook", "scipy", "statsmodels", "opencv-python", 
            "pillow", "tqdm", "joblib", "optuna", "wandb",
            "albumentations", "polars", "pyarrow"
        )
        
        Write-Status "Installing $($packages.Count) essential packages..."
        try {
            pip install $packages
            
            # Generate requirements.txt
            Write-Status "Generating requirements.txt..."
            pip freeze > requirements.txt
            $lineCount = (Get-Content requirements.txt).Count
            Write-Success "Generated requirements.txt with $lineCount packages"
        }
        catch {
            Write-Error "Failed to install packages: $($_.Exception.Message)"
            return $false
        }
    }
    
    return $true
}

# Function to verify installation
function Test-Installation {
    Write-Status "Verifying installation..."
    
    $testScript = @"
import sys
print(f'Python version: {sys.version}')

packages = ['numpy', 'pandas', 'sklearn', 'matplotlib', 'torch', 'tensorflow']
for pkg in packages:
    try:
        __import__(pkg)
        print(f'✓ {pkg}')
    except ImportError:
        print(f'✗ {pkg} - FAILED')
"@
    
    try {
        $testScript | python
        Write-Success "Installation verification complete"
        return $true
    }
    catch {
        Write-Error "Installation verification failed: $($_.Exception.Message)"
        return $false
    }
}

# Function to setup Jupyter kernel
function Set-JupyterKernel {
    Write-Status "Setting up Jupyter kernel..."
    
    try {
        python -m ipykernel install --user --name kaggle-env --display-name "Kaggle Competition (Python 3.12)"
        Write-Success "Jupyter kernel 'Kaggle Competition (Python 3.12)' installed"
        Write-Status "You can now select this kernel in Jupyter notebooks"
        return $true
    }
    catch {
        Write-Warning "Failed to setup Jupyter kernel: $($_.Exception.Message)"
        return $true  # Not critical for main functionality
    }
}

# Function to create activation scripts
function New-ActivationScripts {
    # Create PowerShell activation script
    if (-not (Test-Path "activate.ps1")) {
        Write-Status "Creating PowerShell activation script..."
        
        $activateContent = @'
# AI/ML Environment Activation Script for PowerShell
Write-Host "🚀 Activating AI/ML Python Environment..." -ForegroundColor Blue
Write-Host "📍 Project: $(Split-Path -Leaf (Get-Location))" -ForegroundColor Cyan

# Activate the virtual environment
& ".venv\Scripts\Activate.ps1"

if ($env:VIRTUAL_ENV) {
    Write-Host "✅ Virtual environment activated successfully!" -ForegroundColor Green
    Write-Host "📦 Environment: $env:VIRTUAL_ENV" -ForegroundColor Yellow
    Write-Host ""
    
    $pythonVersion = python --version
    $pipVersion = (pip --version).Split(' ')[1]
    
    Write-Host "🐍 Python: $pythonVersion" -ForegroundColor Cyan
    Write-Host "📦 pip: $pipVersion" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "💡 Quick commands:" -ForegroundColor Yellow
    Write-Host "   pip list          - Show installed packages"
    Write-Host "   jupyter notebook  - Start Jupyter notebook"
    Write-Host "   deactivate        - Exit virtual environment"
    Write-Host ""
} else {
    Write-Host "❌ Failed to activate virtual environment" -ForegroundColor Red
    Write-Host "Make sure .venv directory exists in $(Get-Location)" -ForegroundColor Yellow
}
'@
        
        $activateContent | Out-File -FilePath "activate.ps1" -Encoding UTF8
        Write-Success "Created PowerShell activation script: activate.ps1"
    }
    
    # Create batch activation script for compatibility
    if (-not (Test-Path "activate.bat")) {
        Write-Status "Creating batch activation script..."
        
        $batchContent = @'
@echo off
echo 🚀 Activating AI/ML Python Environment...
echo 📍 Project: %cd%

call .venv\Scripts\activate.bat

if defined VIRTUAL_ENV (
    echo ✅ Virtual environment activated successfully!
    echo 📦 Environment: %VIRTUAL_ENV%
    echo.
    for /f "tokens=*" %%i in ('python --version') do echo 🐍 Python: %%i
    for /f "tokens=2" %%i in ('pip --version') do echo 📦 pip: %%i
    echo.
    echo 💡 Quick commands:
    echo    pip list          - Show installed packages
    echo    jupyter notebook  - Start Jupyter notebook
    echo    deactivate        - Exit virtual environment
    echo.
) else (
    echo ❌ Failed to activate virtual environment
    echo Make sure .venv directory exists in %cd%
)
'@
        
        $batchContent | Out-File -FilePath "activate.bat" -Encoding ASCII
        Write-Success "Created batch activation script: activate.bat"
    }
}

# Main execution function
function Main {
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "🤖 AI/ML Environment Setup Script" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Check if we're in the right directory
    $currentDir = Split-Path -Leaf (Get-Location)
    if ($currentDir -notlike "*Demo*" -and -not (Test-Path "main.py")) {
        Write-Warning "You might not be in the correct project directory"
        Write-Status "Current directory: $(Get-Location)"
        if (-not $Force) {
            $continue = Read-Host "Continue anyway? (y/N)"
            if ($continue -ne "y" -and $continue -ne "Y") {
                Write-Status "Aborted"
                return
            }
        }
    }
    
    # Run setup steps
    if (-not (Test-Python)) { return }
    if (-not (New-VirtualEnvironment)) { return }
    if (-not (Initialize-VirtualEnvironment)) { return }
    if (-not (Install-Packages)) { return }
    if (-not (Test-Installation)) { return }
    Set-JupyterKernel | Out-Null
    New-ActivationScripts
    
    Write-Host ""
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Success "🎉 Setup Complete!"
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Status "Your AI/ML environment is ready for Kaggle competitions!"
    Write-Host ""
    Write-Status "Next steps:"
    Write-Host "  1. Run: .\.venv\Scripts\Activate.ps1"
    Write-Host "  2. Or use: .\activate.ps1 (PowerShell) or activate.bat (Command Prompt)"
    Write-Host "  3. Start coding: jupyter notebook"
    Write-Host ""
    Write-Status "Environment details:"
    Write-Host "  📁 Location: $(Get-Location)\.venv"
    $version = & $script:PythonCommand --version
    Write-Host "  🐍 Python: $version"
    if (Test-Path "requirements.txt") {
        $packageCount = (Get-Content requirements.txt).Count
        Write-Host "  📦 Packages: $packageCount installed"
    }
    Write-Host ""
}

# Execute main function
Main