#!/bin/bash

# AI/ML Environment Activation Script
# This script activates the Python virtual environment for AI/ML projects

echo "🚀 Activating AI/ML Python Environment..."
echo "📍 Project: $(basename $(pwd))"
echo "🐍 Python: 3.12.11"

# Activate the virtual environment
source .venv/bin/activate

# Verify activation
if [[ "$VIRTUAL_ENV" != "" ]]; then
    echo "✅ Virtual environment activated successfully!"
    echo "📦 Environment: $VIRTUAL_ENV"
    echo ""
    echo "🔧 Available tools:"
    echo "   - Python $(python --version 2>&1 | cut -d' ' -f2)"
    echo "   - pip $(pip --version | cut -d' ' -f2)"
    echo "   - jupyter notebook/lab"
    echo ""
    echo "📚 Key packages installed:"
    echo "   - numpy, pandas, matplotlib, seaborn"
    echo "   - scikit-learn, xgboost, lightgbm, catboost"  
    echo "   - tensorflow, torch, transformers"
    echo "   - opencv-python, pillow, albumentations"
    echo ""
    echo "💡 Quick commands:"
    echo "   pip list          - Show installed packages"
    echo "   jupyter notebook  - Start Jupyter notebook"
    echo "   deactivate        - Exit virtual environment"
    echo ""
else
    echo "❌ Failed to activate virtual environment"
    echo "Make sure .venv directory exists in $(pwd)"
fi