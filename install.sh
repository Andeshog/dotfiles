#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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
        
        # Back up existing file
        echo -e "${BLUE}Backing up existing $target to $target.backup${NC}"
        mv "$target" "$target.backup"
    fi
    
    # Create the symlink
    ln -s "$source" "$target"
    echo -e "${GREEN}✓${NC} Linked $target -> $source"
}

# Create symlinks
create_symlink "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"

echo -e "${GREEN}Done! Dotfiles installed.${NC}"
