#!/bin/sh

# Usage: ./install.sh

# Create symbolic links from .git/hooks to our hooks
ln -sf ../../.github/hooks/pre-commit ../.git/hooks/pre-commit

# Make the hooks executable
chmod +x ../.git/hooks/pre-commit

echo "Git hooks installed successfully!"