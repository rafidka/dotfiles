#!/usr/bin/env bash
# install.sh - First-time setup for dotfiles
# Usage: ./install.sh

set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo "  Dotfiles Installation"
echo "========================================"
echo ""
echo "Installing from: $DOTFILES"
echo ""

# --- Oh-My-Zsh Installation ---
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "[1/4] Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
else
    echo "[1/4] Oh-My-Zsh already installed, skipping..."
fi

# --- Zsh Plugin Installation ---
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo "[2/4] Installing Zsh plugins..."

# zsh-syntax-highlighting
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    echo "  - Installing zsh-syntax-highlighting..."
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo "  - zsh-syntax-highlighting already installed"
fi

# zsh-autosuggestions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    echo "  - Installing zsh-autosuggestions..."
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "  - zsh-autosuggestions already installed"
fi

# zsh-completions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]]; then
    echo "  - Installing zsh-completions..."
    git clone --depth=1 https://github.com/zsh-users/zsh-completions.git "$ZSH_CUSTOM/plugins/zsh-completions"
else
    echo "  - zsh-completions already installed"
fi

# fzf-tab
if [[ ! -d "$ZSH_CUSTOM/plugins/fzf-tab" ]]; then
    echo "  - Installing fzf-tab..."
    git clone --depth=1 https://github.com/Aloxaf/fzf-tab.git "$ZSH_CUSTOM/plugins/fzf-tab"
else
    echo "  - fzf-tab already installed"
fi

# --- FZF Installation ---
echo "[3/4] Installing FZF..."
if [[ ! -d "$HOME/.fzf" ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
else
    echo "  - FZF already installed"
fi

# --- Add activation to .zshrc ---
echo "[4/4] Configuring .zshrc..."
ZSHRC="$HOME/.zshrc"
ACTIVATION_LINE="source ~/dotfiles/activate.sh"

# Create .zshrc if it doesn't exist
if [[ ! -f "$ZSHRC" ]]; then
    touch "$ZSHRC"
fi

if ! grep -q "dotfiles/activate.sh" "$ZSHRC" 2>/dev/null; then
    echo "" >> "$ZSHRC"
    echo "# Dotfiles configuration" >> "$ZSHRC"
    echo "$ACTIVATION_LINE" >> "$ZSHRC"
    echo "  - Added activation to .zshrc"
else
    echo "  - .zshrc already configured"
fi

echo ""
echo "========================================"
echo "  Installation Complete!"
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. Restart your shell or run: source ~/.zshrc"
echo "  2. Open vim and run :PlugInstall to install vim plugins"
echo "     (vim-plug will be auto-installed on first vim launch)"
echo "  3. For CoC language servers, run commands like:"
echo "     :CocInstall coc-pyright coc-tsserver coc-json coc-go"
echo ""
echo "Optional: Create ~/dotfiles/zsh/local.zsh for machine-specific settings"
echo ""
echo "Note: Vim configuration uses VIMINIT environment variable."
echo "      No symlinks are needed - everything is self-contained in ~/dotfiles."
echo ""
