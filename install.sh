#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_SKILLS_DIR="$HOME/.claude/skills"
TMP_DIR="/tmp/claude-setup-tmp"

echo "============================================"
echo "  Claude Code Setup - One-Click Install"
echo "============================================"
echo ""

# Check prerequisites
if ! command -v claude &>/dev/null; then
    echo "[ERROR] claude command not found. Install Claude Code CLI first."
    echo "         https://code.claude.com/docs/quickstart"
    exit 1
fi

if ! command -v git &>/dev/null; then
    echo "[ERROR] git command not found."
    exit 1
fi

# [1] Install marketplace plugins
echo "[1/3] Installing Marketplace plugins..."
echo "----------------------------------------"
while IFS= read -r line; do
    line="${line%%#*}"  # strip comments
    line="${line// /}"   # strip whitespace
    [ -z "$line" ] && continue
    echo "  Installing plugin: $line"
    if claude plugin install "$line"; then
        echo "  ✓ $line installed"
    else
        echo "  ✗ $line failed (may already be installed)"
    fi
done < "$REPO_DIR/plugins.txt"
echo ""

# [2] Install third-party skills
echo "[2/3] Installing third-party Skills..."
echo "----------------------------------------"
mkdir -p "$CLAUDE_SKILLS_DIR"

while IFS=' ' read -r repo subdir target; do
    [[ "$repo" == "#"* || -z "$repo" ]] && continue
    echo "  Installing skill: $target"
    echo "  From: $repo ($subdir)"

    rm -rf "$TMP_DIR"
    if git clone --depth 1 --filter=blob:none --sparse "$repo" "$TMP_DIR" 2>/dev/null; then
        (cd "$TMP_DIR" && git sparse-checkout set "$subdir" 2>/dev/null)
        if [ -d "$TMP_DIR/$subdir" ]; then
            rm -rf "$CLAUDE_SKILLS_DIR/$target"
            cp -r "$TMP_DIR/$subdir" "$CLAUDE_SKILLS_DIR/$target"
            echo "  ✓ $target installed"
        else
            echo "  ✗ Subdirectory $subdir not found"
        fi
        rm -rf "$TMP_DIR"
    else
        echo "  ✗ Clone failed (check network)"
    fi
done < <(grep -v '^#' "$REPO_DIR/skills.txt" | grep -v '^$')
echo ""

# [3] Cleanup
echo "[3/3] Cleanup..."
rm -rf "$TMP_DIR"
echo ""

echo "============================================"
echo "  Done! Restart Claude Code to apply changes."
echo "============================================"
