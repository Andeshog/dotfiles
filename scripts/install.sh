#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ONLY_TMUX=0
OVERRIDE=0

usage() {
    cat <<EOF
Usage: $(basename "$0") [--only-tmux] [--override] [--help]

Options:
  --only-tmux  Only install the tmux config
  --override   Replace existing targets without creating .backup copies
  -h, --help   Show this help message
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --only-tmux)
            ONLY_TMUX=1
            shift
            ;;
        --override)
            OVERRIDE=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

echo -e "${BLUE}Setting up dotfiles...${NC}"

# Get the directory where this script is located
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Function to create symlink
create_symlink() {
    local source="$1"
    local target="$2"
    
    # If target already exists
    if [ -e "$target" ] || [ -L "$target" ]; then
        # If it's already a symlink pointing to the right place, skip
        if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
            echo -e "${GREEN}✓${NC} $target already linked correctly"
            return
        fi

        if [ "$OVERRIDE" -eq 1 ]; then
            echo -e "${YELLOW}Replacing existing $target without backup${NC}"
            rm -rf "$target"
        else
            echo -e "${YELLOW}Backing up existing $target to $target.backup${NC}"
            mv "$target" "$target.backup"
        fi
    fi

    # Create the symlink
    ln -s "$source" "$target"
    echo -e "${GREEN}✓${NC} Linked $target -> $source"
}

# Create symlinks
create_symlink "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"

if [ "$ONLY_TMUX" -eq 0 ]; then
    mkdir -p "$HOME/.config"
    create_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
fi

echo -e "${GREEN}Done! Dotfiles installed.${NC}"
