#!/bin/bash

# Exit on error
set -e

echo "🚀 Setting up Hugo development environment..."

# Check if Hugo is installed
if ! command -v hugo &> /dev/null; then
    echo "❌ Hugo is not installed. Please install Hugo first:"
    echo "   Visit: https://gohugo.io/installation/"
    exit 1
fi

# Check Hugo version
HUGO_VERSION=$(hugo version)
echo "✅ Found Hugo: $HUGO_VERSION"

# Initialize and update Git submodules
echo "📦 Initializing Git submodules..."
git submodule update --init --recursive

# Verify theme directory
if [ ! -d "themes/ananke" ]; then
    echo "❌ Theme directory not found. Something went wrong with submodule initialization."
    exit 1
fi

echo "✅ Theme directory verified"

echo "✨ Setup complete! You can now run:"
echo "   hugo server -D"