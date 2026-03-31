## Dotfiles
Contains configuration for NeoVim, Tmux and WezTerm

### Automatic installation
The `install` script will create symlinks for NeoVim and Tmux configs. If there exist configs already, these will be backed up.

```bash
./scripts/install.sh
./scripts/install.sh --only-tmux
./scripts/install.sh --override
```

### WezTerm symlink
```bash
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.wezterm.lua" -Target "\\wsl$\Ubuntu-22.04\home\path_to_dotfiles\wezterm.lua"
```
