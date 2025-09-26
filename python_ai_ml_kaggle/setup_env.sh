#!/bin/bash

# AI/ML Virtual Environment Setup Script
# This script automates the creation and setup of a Python virtual environment for Kaggle competitions

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Python 3.12 is available
check_python() {
    print_status "Checking for Python 3.12..."
    
    # Try different Python 3.12 commands
    if command -v python3.12 &> /dev/null; then
        PYTHON_CMD="python3.12"
        print_success "Found python3.12"
    elif command -v python3 &> /dev/null && python3 --version | grep -q "3.12"; then
        PYTHON_CMD="python3"
        print_success "Found python3 (version 3.12)"
    else
        print_error "Python 3.12 not found!"
        print_status "Please install Python 3.12 first:"
        echo "  brew install python@3.12  # On macOS"
        echo "  Or download from https://www.python.org/"
        exit 1
    fi
    
    PYTHON_VERSION=$($PYTHON_CMD --version)
    print_status "Using: $PYTHON_VERSION"
}

# Create virtual environment
create_venv() {
    print_status "Creating virtual environment..."
    
    if [ -d ".venv" ]; then
        print_warning "Virtual environment already exists at .venv"
        read -p "Do you want to recreate it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Removing existing virtual environment..."
            rm -rf .venv
        else
            print_status "Using existing virtual environment"
            return 0
        fi
    fi
    
    print_status "Creating new virtual environment with $PYTHON_CMD..."
    $PYTHON_CMD -m venv .venv
    
    if [ -d ".venv" ]; then
        print_success "Virtual environment created successfully!"
    else
        print_error "Failed to create virtual environment"
        exit 1
    fi
}

# Activate virtual environment and upgrade pip
setup_venv() {
    print_status "Activating virtual environment..."
    
    # Activate the virtual environment
    source .venv/bin/activate
    
    if [[ "$VIRTUAL_ENV" != "" ]]; then
        print_success "Virtual environment activated: $VIRTUAL_ENV"
    else
        print_error "Failed to activate virtual environment"
        exit 1
    fi
    
    print_status "Upgrading pip..."
    python -m pip install --upgrade pip
    
    print_success "Pip upgraded successfully"
}

# Install packages from requirements.txt
install_packages() {
    print_status "Installing Python packages..."
    
    if [ -f "requirements.txt" ]; then
        print_status "Installing packages from requirements.txt..."
        pip install -r requirements.txt
        print_success "Packages installed from requirements.txt"
    else
        print_status "No requirements.txt found. Installing essential AI/ML packages..."
        
        # Essential packages for Kaggle competitions
        PACKAGES=(
            "numpy"
            "pandas" 
            "matplotlib"
            "seaborn"
            "plotly"
            "scikit-learn"
            "xgboost"
            "lightgbm"
            "catboost"
            "tensorflow"
            "torch"
            "torchvision"
            "transformers"
            "datasets"
            "accelerate"
            "jupyter"
            "ipykernel"
            "notebook"
            "scipy"
            "statsmodels"
            "opencv-python"
            "pillow"
            "tqdm"
            "joblib"
            "optuna"
            "wandb"
            "albumentations"
            "polars"
            "pyarrow"
        )
        
        print_status "Installing ${#PACKAGES[@]} essential packages..."
        pip install "${PACKAGES[@]}"
        
        # Generate requirements.txt
        print_status "Generating requirements.txt..."
        pip freeze > requirements.txt
        print_success "Generated requirements.txt with $(wc -l < requirements.txt) packages"
    fi
}

# Verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    # Test key imports
    python -c "
import sys
print(f'Python version: {sys.version}')

# Test key packages
packages = ['numpy', 'pandas', 'sklearn', 'matplotlib', 'torch', 'tensorflow']
for pkg in packages:
    try:
        __import__(pkg)
        print(f'✓ {pkg}')
    except ImportError:
        print(f'✗ {pkg} - FAILED')
"
    
    print_success "Installation verification complete"
}

# Setup Jupyter kernel
setup_jupyter() {
    print_status "Setting up Jupyter kernel..."
    
    python -m ipykernel install --user --name kaggle-env --display-name "Kaggle Competition (Python 3.12)"
    
    print_success "Jupyter kernel 'Kaggle Competition (Python 3.12)' installed"
    print_status "You can now select this kernel in Jupyter notebooks"
}

# Create activation helper
create_activation_script() {
    if [ ! -f "activate.sh" ]; then
        print_status "Creating activation script..."
        # The activate.sh script should already exist, but create it if it doesn't
        cat > activate.sh << 'EOF'
#!/bin/bash

# AI/ML Environment Activation Script
echo "🚀 Activating AI/ML Python Environment..."
echo "📍 Project: $(basename $(pwd))"

# Activate the virtual environment
source .venv/bin/activate

if [[ "$VIRTUAL_ENV" != "" ]]; then
    echo "✅ Virtual environment activated successfully!"
    echo "📦 Environment: $VIRTUAL_ENV"
    echo ""
    echo "🐍 Python: $(python --version)"
    echo "📦 pip: $(pip --version | cut -d' ' -f2)"
    echo ""
    echo "💡 Quick commands:"
    echo "   pip list          - Show installed packages"
    echo "   jupyter notebook  - Start Jupyter notebook"
    echo "   deactivate        - Exit virtual environment"
    echo ""
else
    echo "❌ Failed to activate virtual environment"
fi
EOF
        chmod +x activate.sh
        print_success "Created activation script: ./activate.sh"
    fi
}

# Main execution
main() {
    echo "======================================"
    echo "🤖 AI/ML Environment Setup Script"
    echo "======================================"
    echo ""
    
    # Check if we're in the right directory
    if [[ ! "$(basename $(pwd))" == *"Demo"* ]] && [[ ! -f "main.py" ]]; then
        print_warning "You might not be in the correct project directory"
        print_status "Current directory: $(pwd)"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Aborted"
            exit 0
        fi
    fi
    
    # Run setup steps
    check_python
    create_venv
    setup_venv
    install_packages
    verify_installation
    setup_jupyter
    create_activation_script
    
    echo ""
    echo "======================================"
    print_success "🎉 Setup Complete!"
    echo "======================================"
    echo ""
    print_status "Your AI/ML environment is ready for Kaggle competitions!"
    echo ""
    print_status "Next steps:"
    echo "  1. Run: source .venv/bin/activate"
    echo "  2. Or use: ./activate.sh"
    echo "  3. Start coding: jupyter notebook"
    echo ""
    print_status "Environment details:"
    echo "  📁 Location: $(pwd)/.venv"
    echo "  🐍 Python: $($PYTHON_CMD --version)"
    echo "  📦 Packages: $(wc -l < requirements.txt) installed"
    echo ""
}

# Run main function
main "$@"