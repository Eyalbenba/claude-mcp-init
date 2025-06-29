#!/bin/bash

# Claude MCP CLI Installation Script
# This script sets up the claude-mcp command for easy access

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}                     Claude MCP CLI Installation                              ${BLUE}║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Get the directory where this script is located (should be src/mcp-setup)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_MCP_SCRIPT="$SCRIPT_DIR/claude-mcp"

# Check if claude-mcp script exists
if [ ! -f "$CLAUDE_MCP_SCRIPT" ]; then
    print_error "claude-mcp script not found at $CLAUDE_MCP_SCRIPT"
    exit 1
fi

# Check if Bash 4+ is available
print_status "Checking Bash version..."
if command -v /usr/local/bin/bash >/dev/null 2>&1; then
    BASH_PATH="/usr/local/bin/bash"
    BASH_VERSION=$($BASH_PATH --version | head -n1 | grep -o '[0-9]\+\.[0-9]\+' | head -n1)
    print_success "Found Bash $BASH_VERSION at $BASH_PATH"
elif command -v /opt/homebrew/bin/bash >/dev/null 2>&1; then
    BASH_PATH="/opt/homebrew/bin/bash"
    BASH_VERSION=$($BASH_PATH --version | head -n1 | grep -o '[0-9]\+\.[0-9]\+' | head -n1)
    print_success "Found Bash $BASH_VERSION at $BASH_PATH"
else
    print_warning "Bash 4+ not found. Installing via Homebrew..."
    if command -v brew >/dev/null 2>&1; then
        brew install bash
        if command -v /usr/local/bin/bash >/dev/null 2>&1; then
            BASH_PATH="/usr/local/bin/bash"
        elif command -v /opt/homebrew/bin/bash >/dev/null 2>&1; then
            BASH_PATH="/opt/homebrew/bin/bash"
        else
            print_error "Failed to install Bash 4+"
            exit 1
        fi
        print_success "Bash 4+ installed successfully"
    else
        print_error "Homebrew not found. Please install Homebrew first:"
        echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
fi

# Create wrapper script
print_status "Creating claude-mcp command..."

# Determine installation directory
if [ -w "/usr/local/bin" ]; then
    INSTALL_DIR="/usr/local/bin"
elif [ -w "$HOME/.local/bin" ]; then
    INSTALL_DIR="$HOME/.local/bin"
    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        print_warning "Adding $HOME/.local/bin to PATH"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
    fi
else
    # Create ~/.local/bin if it doesn't exist
    mkdir -p "$HOME/.local/bin"
    INSTALL_DIR="$HOME/.local/bin"
    print_warning "Adding $HOME/.local/bin to PATH"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
fi

# Create the wrapper script
WRAPPER_SCRIPT="$INSTALL_DIR/claude-mcp"

cat > "$WRAPPER_SCRIPT" << EOF
#!/bin/bash
# Claude MCP CLI Wrapper
exec "$BASH_PATH" "$CLAUDE_MCP_SCRIPT" "\$@"
EOF

chmod +x "$WRAPPER_SCRIPT"

print_success "claude-mcp command installed to $WRAPPER_SCRIPT"

# Test the installation
print_status "Testing installation..."
if "$WRAPPER_SCRIPT" help >/dev/null 2>&1; then
    print_success "Installation successful!"
else
    print_error "Installation test failed"
    exit 1
fi

echo ""
print_success "🎉 Claude MCP CLI is now installed!"
echo ""
echo "Usage:"
echo "  claude-mcp configure    # Configure MCP servers interactively"
echo "  claude-mcp status       # Check MCP server status"
echo "  claude-mcp list         # List configured servers"
echo "  claude-mcp remove       # Remove servers"
echo "  claude-mcp help         # Show help"
echo ""

if [[ "$INSTALL_DIR" == "$HOME/.local/bin" ]]; then
    print_warning "Note: You may need to restart your terminal or run:"
    echo "  source ~/.bashrc  # or ~/.zshrc"
    echo "  to use the claude-mcp command"
fi

echo ""
print_status "Next steps:"
echo "1. Make sure you have a .env-mcp file with your API keys"
echo "2. Run: claude-mcp status"
echo "3. Run: claude-mcp configure"
echo ""
