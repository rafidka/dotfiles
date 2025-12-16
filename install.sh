#!/usr/bin/env bash
# install.sh - First-time setup for homedir
# Usage: ./install.sh

set -e

HOMEDIR_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo "  Homedir Installation"
echo "========================================"
echo ""
echo "Installing from: $HOMEDIR_ROOT"
echo ""

# --- Oh-My-Zsh Installation ---
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "[1/6] Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
else
    echo "[1/6] Oh-My-Zsh already installed, skipping..."
fi

# --- Zsh Plugin Installation ---
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo "[2/6] Installing Zsh plugins..."

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

# --- FZF Installation ---
echo "[3/6] Installing FZF..."
if [[ ! -d "$HOME/.fzf" ]]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
else
    echo "  - FZF already installed"
fi

# --- Vim Configuration ---
echo "[4/6] Setting up Vim configuration..."

# Create ~/.vim directory structure
mkdir -p "$HOME/.vim/autoload"
mkdir -p "$HOME/.vim/after"
mkdir -p "$HOME/.vim/undodir"

# Symlink vimrc
if [[ -L "$HOME/.vim/vimrc" ]]; then
    rm "$HOME/.vim/vimrc"
fi
if [[ -f "$HOME/.vim/vimrc" ]]; then
    echo "  - Backing up existing ~/.vim/vimrc to ~/.vim/vimrc.bak"
    mv "$HOME/.vim/vimrc" "$HOME/.vim/vimrc.bak"
fi
ln -sf "$HOMEDIR_ROOT/vim/vimrc" "$HOME/.vim/vimrc"
echo "  - Linked ~/.vim/vimrc"

# Symlink coc.vim
if [[ -L "$HOME/.vim/coc.vim" ]]; then
    rm "$HOME/.vim/coc.vim"
fi
ln -sf "$HOMEDIR_ROOT/vim/coc.vim" "$HOME/.vim/coc.vim"
echo "  - Linked ~/.vim/coc.vim"

# Symlink ftplugin directory
if [[ -L "$HOME/.vim/after/ftplugin" ]]; then
    rm "$HOME/.vim/after/ftplugin"
fi
if [[ -d "$HOME/.vim/after/ftplugin" ]]; then
    echo "  - Backing up existing ftplugin to ~/.vim/after/ftplugin.bak"
    mv "$HOME/.vim/after/ftplugin" "$HOME/.vim/after/ftplugin.bak"
fi
ln -sf "$HOMEDIR_ROOT/vim/ftplugin" "$HOME/.vim/after/ftplugin"
echo "  - Linked ~/.vim/after/ftplugin"

# Create ~/.vimrc that sources our vimrc
if [[ ! -f "$HOME/.vimrc" ]] || ! grep -q "source ~/.vim/vimrc" "$HOME/.vimrc" 2>/dev/null; then
    echo "source ~/.vim/vimrc" > "$HOME/.vimrc"
    echo "  - Created ~/.vimrc"
fi

# --- Install vim-plug ---
echo "[5/6] Installing vim-plug..."
if [[ ! -f "$HOME/.vim/autoload/plug.vim" ]]; then
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    echo "  - vim-plug installed"
else
    echo "  - vim-plug already installed"
fi

# --- Add activation to .zshrc ---
echo "[6/6] Configuring .zshrc..."
ZSHRC="$HOME/.zshrc"
ACTIVATION_LINE="source ~/homedir/activate.sh"

# Create .zshrc if it doesn't exist
if [[ ! -f "$ZSHRC" ]]; then
    touch "$ZSHRC"
fi

if ! grep -q "homedir/activate.sh" "$ZSHRC" 2>/dev/null; then
    echo "" >> "$ZSHRC"
    echo "# Homedir configuration" >> "$ZSHRC"
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
echo "  3. For CoC language servers, run commands like:"
echo "     :CocInstall coc-pyright coc-tsserver coc-json coc-go"
echo ""
echo "Optional: Create ~/homedir/zsh/local.zsh for machine-specific settings"
echo ""
