#!/usr/bin/env bash
set -euo pipefail

# --- Configuration -----------------------------------------------------------
ARCH="$(uname -m)"
BIN_DIR="$HOME/.local/bin"

# --- Helpers -----------------------------------------------------------------
usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS] <version>

Install a specific Neovim release from GitHub (AppImage, extracted without FUSE).

Arguments:
    <version>       Release tag, e.g. "v0.12.0", "v0.11.6", or "nightly"

Options:
    -d, --dir DIR   Install root (default: ~/.local/opt/nvim-<version>)
    -b, --bin DIR   Symlink directory (default: ~/.local/bin)
    -f, --force     Overwrite existing installation without prompting
    -h, --help      Show this help message

Examples:
    $(basename "$0") v0.12.0
    $(basename "$0") nightly
    $(basename "$0") --dir ~/tools/nvim v0.12.0
EOF
    exit "${1:-0}"
}

die() {
    echo "error: $*" >&2
    exit 1
}
info() { echo ":: $*"; }

# --- Parse arguments ---------------------------------------------------------
NVIM_VERSION=""
NVIM_ROOT=""
FORCE=0

while [[ $# -gt 0 ]]; do
    case "$1" in
    -d | --dir)
        NVIM_ROOT="$2"
        shift 2
        ;;
    -b | --bin)
        BIN_DIR="$2"
        shift 2
        ;;
    -f | --force)
        FORCE=1
        shift
        ;;
    -h | --help) usage 0 ;;
    -*) die "unknown option: $1" ;;
    *)
        [[ -z "$NVIM_VERSION" ]] || die "unexpected argument: $1"
        NVIM_VERSION="$1"
        shift
        ;;
    esac
done

[[ -n "$NVIM_VERSION" ]] || {
    echo "error: version argument required" >&2
    usage 1
}

# Normalise: add leading 'v' for numbered releases (e.g. 0.12.0 -> v0.12.0)
if [[ "$NVIM_VERSION" =~ ^[0-9] ]]; then
    NVIM_VERSION="v${NVIM_VERSION}"
fi

# Default install root if not overridden
: "${NVIM_ROOT:=$HOME/.local/opt/nvim-${NVIM_VERSION}}"

# --- Architecture ------------------------------------------------------------
case "$ARCH" in
x86_64) ASSET="nvim-linux-x86_64.appimage" ;;
aarch64) ASSET="nvim-linux-arm64.appimage" ;;
*) die "unsupported architecture: $ARCH" ;;
esac

DOWNLOAD_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/${ASSET}"

# --- Paths -------------------------------------------------------------------
APPIMAGE="$NVIM_ROOT/$ASSET"
EXTRACT_DIR="$NVIM_ROOT/squashfs-root"
NVIM_BIN="$EXTRACT_DIR/usr/bin/nvim"

# --- Pre-flight checks -------------------------------------------------------
command -v curl >/dev/null 2>&1 || die "curl is required but not found"

if [[ -d "$EXTRACT_DIR" && "$FORCE" -eq 0 ]]; then
    read -rp "Existing installation found at $NVIM_ROOT. Overwrite? [y/N] " ans
    [[ "$ans" =~ ^[Yy]$ ]] || {
        info "Aborted."
        exit 0
    }
fi

# --- Install -----------------------------------------------------------------
mkdir -p "$NVIM_ROOT" "$BIN_DIR"

info "Downloading Neovim ${NVIM_VERSION} (${ARCH})..."
if ! curl -fL -o "$APPIMAGE" "$DOWNLOAD_URL"; then
    rm -f "$APPIMAGE"
    die "download failed — check that '${NVIM_VERSION}' is a valid release tag"
fi

chmod +x "$APPIMAGE"

info "Extracting AppImage (no FUSE required)..."
rm -rf "$EXTRACT_DIR"
(cd "$NVIM_ROOT" && "./$ASSET" --appimage-extract >/dev/null 2>&1)

[[ -x "$NVIM_BIN" ]] || die "extraction failed — $NVIM_BIN not found"

# Clean up the AppImage after successful extraction
rm -f "$APPIMAGE"

# --- Symlink -----------------------------------------------------------------
ln -sf "$NVIM_BIN" "$BIN_DIR/nvim"

# Ensure ~/.local/bin is on PATH for bash and zsh
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [[ -f "$rc" ]] || continue
    if ! grep -q 'local/bin' "$rc" 2>/dev/null; then
        echo "export PATH='$HOME/.local/bin:$PATH'" >>"$rc"
        info "Added ~/.local/bin to PATH in $(basename "$rc")"
    fi
done

# --- Verify ------------------------------------------------------------------
info "Installed successfully:"
"$BIN_DIR/nvim" --version | head -n 2
