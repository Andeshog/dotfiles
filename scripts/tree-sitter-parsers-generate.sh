#!/bin/bash
set -euo pipefail

declare -A REPOS=(
    # c, lua, vim, vimdoc, markdown, markdown_inline, query are bundled by Neovim
    # and must not be overridden here
    [cpp]="tree-sitter/tree-sitter-cpp"
    [cmake]="uyha/tree-sitter-cmake"
    [python]="tree-sitter/tree-sitter-python"
    [bash]="tree-sitter/tree-sitter-bash"
    [json]="tree-sitter/tree-sitter-json"
    [yaml]="tree-sitter-grammars/tree-sitter-yaml"
    [toml]="tree-sitter-grammars/tree-sitter-toml"
    [comment]="stsewd/tree-sitter-comment"
    [diff]="the-mikedavis/tree-sitter-diff"
)
PARSER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim/parser"

if ! command -v tree-sitter &>/dev/null; then
    echo "error: tree-sitter-cli not found. Install it with 'cargo install tree-sitter-cli' or your package manager." >&2
    exit 1
fi

mkdir -p "$PARSER_DIR"
BUILD_DIR=$(mktemp -d)
trap "rm -rf '$BUILD_DIR'" EXIT

for lang in "${!REPOS[@]}"; do
    echo "Building $lang..."
    git clone --depth 1 --quiet "https://github.com/${REPOS[$lang]}" "$BUILD_DIR/$lang"
    tree-sitter build --output "$PARSER_DIR/$lang.so" "$BUILD_DIR/$lang"
    echo "Built $lang"
done
echo "Done."
