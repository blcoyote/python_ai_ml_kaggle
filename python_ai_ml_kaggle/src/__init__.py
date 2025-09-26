"""
Kaggle Competition Source Code Package

This package contains production-ready code for Kaggle competitions,
organized into data, features, models, and utils modules.
"""

__version__ = "0.1.0"
__author__ = "Kaggle Competitor"

# Import commonly used functions
from .utils import set_seed, get_logger

__all__ = ["set_seed", "get_logger"]