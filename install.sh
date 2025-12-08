#!/bin/bash

set -e

# Auto-detect GitHub user/repo from git remote, with fallbacks
detect_github_info() {
    local remote_url
    remote_url=$(git remote get-url origin 2>/dev/null || echo "")

    if [[ -n "$remote_url" ]]; then
        # Handle SSH format: git@github.com:user/repo.git
        if [[ "$remote_url" =~ git@github\.com:([^/]+)/([^/.]+)(\.git)?$ ]]; then
            GITHUB_USER="${BASH_REMATCH[1]}"
            GITHUB_REPO="${BASH_REMATCH[2]}"
            return 0
        fi
        # Handle HTTPS format: https://github.com/user/repo.git
        if [[ "$remote_url" =~ github\.com/([^/]+)/([^/.]+)(\.git)?$ ]]; then
            GITHUB_USER="${BASH_REMATCH[1]}"
            GITHUB_REPO="${BASH_REMATCH[2]}"
            return 0
        fi
    fi
    return 1
}

# Configuration with auto-detection
if detect_github_info; then
    echo "Detected repository: $GITHUB_USER/$GITHUB_REPO"
else
    # Fallback defaults
    GITHUB_USER="lleewwiiss"
    GITHUB_REPO="opencode-maestro"
    echo "Could not detect git remote, using defaults: $GITHUB_USER/$GITHUB_REPO"
fi
BRANCH="main"

# Parse Arguments
TARGET_DIR=".opencode"
INSTALL_TYPE="Local"

# Check for flags
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -g|--global)
            TARGET_DIR="$HOME/.config/opencode"
            INSTALL_TYPE="Global"
            ;;
        -h|--help)
            echo "Usage: install.sh [-g|--global] [-h|--help]"
            echo "  -g, --global  Install to ~/.config/opencode instead of ./.opencode"
            echo "  -h, --help    Show this help message"
            exit 0
            ;;
        *)
            echo "Warning: Unknown argument '$1' ignored"
            ;;
    esac
    shift
done

echo "🚀 Installing OpenCode Agentic Workflow..."
echo "📍 Location: $INSTALL_TYPE ($TARGET_DIR)"

# 1. Check Dependencies
if ! command -v bd &> /dev/null; then
    echo ""
    echo "⚠️  Warning: Beads CLI (bd) not found."
    echo "   The workflow commands require 'bd' for issue tracking."
    echo "   Install it from: https://github.com/beads-dev/beads"
    echo ""
    echo "   Continuing installation, but /create and /start commands won't work without it."
    echo ""
fi

# 2. Setup Directories
echo "📂 Setting up directories..."
mkdir -p "$TARGET_DIR/agent"
mkdir -p "$TARGET_DIR/command"

# 3. Install Templates
echo "📥 Downloading configuration..."

BASE_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/templates"

# Helper to download or copy
install_file() {
    local src="$1"
    local dest="$2"
    
    # If running locally and file exists in templates, copy it
    if [ -f "./templates/$src" ]; then
        cp "./templates/$src" "$dest"
    else
        # Otherwise curl it
        # Note: We strip the .opencode/ prefix from src when fetching from raw url if the structure differs
        # But assuming structure matches...
        curl -sSL "$BASE_URL/$src" -o "$dest"
    fi
}

# Install Agents
install_file ".opencode/agent/codebase-analyzer.md" "$TARGET_DIR/agent/codebase-analyzer.md"
install_file ".opencode/agent/codebase-locator.md" "$TARGET_DIR/agent/codebase-locator.md"
install_file ".opencode/agent/codebase-pattern-finder.md" "$TARGET_DIR/agent/codebase-pattern-finder.md"
install_file ".opencode/agent/code-reviewer.md" "$TARGET_DIR/agent/code-reviewer.md"
install_file ".opencode/agent/web-search-researcher.md" "$TARGET_DIR/agent/web-search-researcher.md"

# Install Commands
COMMANDS="create.md start.md research.md plan.md iterate.md implement.md finish.md handoff.md resume.md"
for cmd in $COMMANDS; do
    install_file ".opencode/command/$cmd" "$TARGET_DIR/command/$cmd"
done

# 4. Install Workflow Doc
echo "📜 Installing Workflow Protocol..."
if [ "$INSTALL_TYPE" == "Global" ]; then
    WORKFLOW_DEST="$TARGET_DIR/AGENTIC_WORKFLOW.md"
else
    WORKFLOW_DEST="AGENTIC_WORKFLOW.md"
fi

if [ -f "./AGENTIC_WORKFLOW.md" ] && [ "$INSTALL_TYPE" == "Local" ]; then
    cp "./AGENTIC_WORKFLOW.md" "$WORKFLOW_DEST" 2>/dev/null || true
elif [ -f "./AGENTIC_WORKFLOW.md" ]; then
    cp "./AGENTIC_WORKFLOW.md" "$WORKFLOW_DEST"
else
    curl -sSL "https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${BRANCH}/AGENTIC_WORKFLOW.md" -o "$WORKFLOW_DEST"
fi

echo "✅ Installation Complete!"
echo "👉 Run 'opencode' and type '/create' to get started."
