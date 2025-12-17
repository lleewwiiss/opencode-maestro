#!/bin/bash

set -e

REPO_URL="https://raw.githubusercontent.com/lleewwiiss/opencode-maestro/main"

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
        *) 
            # If unknown arg, maybe it's for something else, but for now ignore or error?
            # Let's just ignore unknown args to be safe or print warning
            ;;
    esac
    shift
done

echo "🚀 Installing OpenCode Agentic Workflow..."
echo "📍 Location: $INSTALL_TYPE ($TARGET_DIR)"

# 1. Check Dependencies
if ! command -v bd &> /dev/null; then
    echo "📦 Beads (bd) not found."
    echo "   Please install it: https://github.com/beads-dev/beads"
fi

# 2. Setup Directories
echo "📂 Setting up directories..."
mkdir -p "$TARGET_DIR/agent"
mkdir -p "$TARGET_DIR/command"

# 3. Install Templates
echo "📥 Downloading configuration..."

BASE_URL="${REPO_URL}/templates"

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

# Install Agents (codebase-specific only - oh-my-opencode provides explore, librarian, oracle, etc.)
install_file ".opencode/agent/codebase-analyzer.md" "$TARGET_DIR/agent/codebase-analyzer.md"
install_file ".opencode/agent/codebase-pattern-finder.md" "$TARGET_DIR/agent/codebase-pattern-finder.md"

# Install Commands (11 commands in the workflow)
COMMANDS="coach.md create.md start.md research.md plan.md implement.md finish.md handoff.md rehydrate.md scout.md"
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
    curl -sSL "${REPO_URL}/AGENTIC_WORKFLOW.md" -o "$WORKFLOW_DEST"
fi

echo "✅ Installation Complete!"
echo "👉 Run 'opencode' and type '/create' to get started."
