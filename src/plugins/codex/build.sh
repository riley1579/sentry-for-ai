#!/usr/bin/env bash
#
# build.sh — Build the Codex distribution of the Sentry plugin.
#
# Codex differs from Claude/Cursor in layout: the plugin must live in a SUBDIR
# (`plugins/sentry/`) referenced by a marketplace catalog at
# `.agents/plugins/marketplace.json`. Codex cannot treat the repo/branch root as
# the plugin (Claude/Cursor can). Skills ship unchanged; every one is
# model-invocable.
#
# Source lives alongside this script (plugin.json, marketplace.json) and is
# assembled into the `.codex-plugin/` layout here; shared content comes from the
# repo's src/ dir (skills/, SKILL_TREE.md) and root (assets/, mcp.json). Codex
# expects the MCP config as `.mcp.json`, so the source `mcp.json` is emitted
# under that name.
#
# Usage: build.sh <TARGET_DIR>   (TARGET_DIR assumed empty)

set -euo pipefail

TARGET_DIR="${1:?usage: build.sh <TARGET_DIR>}"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SRC_DIR/../../.." && pwd)"
cd "$REPO_ROOT"
source "$REPO_ROOT/scripts/build-common.sh"
resolve_content_root "$REPO_ROOT/src"

PLUGIN_NAME="sentry"
PLUGIN="$TARGET_DIR/plugins/$PLUGIN_NAME"

mkdir -p "$PLUGIN/.codex-plugin" "$TARGET_DIR/.agents/plugins"

install_plugin_manifest "$SRC_DIR/plugin.json" "$PLUGIN/.codex-plugin/plugin.json"
cp "$SRC_DIR/marketplace.json" "$TARGET_DIR/.agents/plugins/marketplace.json"
cp "$SRC_DIR/README.md" "$TARGET_DIR/README.md"
cp LICENSE "$TARGET_DIR/LICENSE"

cp mcp.json "$PLUGIN/.mcp.json"
copy_skill_tree "$CONTENT_ROOT" "$PLUGIN/SKILL_TREE.md"
rsync -a assets/ "$PLUGIN/assets/"
# copy_skills hydrates each skill's shared references. (Codex ships no commands.)
copy_skills "$CONTENT_ROOT" "$PLUGIN/skills"

echo "Built Codex dist into $TARGET_DIR (plugins/$PLUGIN_NAME)."
