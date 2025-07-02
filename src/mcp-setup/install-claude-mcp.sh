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
    echo ""
    echo "This usually means:"
    echo "1. The installation script is in the wrong directory"
    echo "2. The claude-mcp script is missing or renamed"
    echo "3. The project structure is incomplete"
    echo ""
    echo "Expected structure:"
    echo "  src/mcp-setup/install-claude-mcp.sh  (this script)"
    echo "  src/mcp-setup/claude-mcp            (main script)"
    echo ""
    echo "Current directory: $SCRIPT_DIR"
    echo "Looking for: $CLAUDE_MCP_SCRIPT"
    exit 1
fi

# Validate that the main script is executable
if [ ! -x "$CLAUDE_MCP_SCRIPT" ]; then
    print_warning "Main script is not executable, fixing..."
    if ! chmod +x "$CLAUDE_MCP_SCRIPT" 2>/dev/null; then
        print_error "Failed to make main script executable"
        echo "Manual fix: chmod +x $CLAUDE_MCP_SCRIPT"
        exit 1
    fi
fi

# Function to check bash version
check_bash_version() {
    local bash_path="$1"
    if [ ! -x "$bash_path" ]; then
        return 1
    fi
    
    local version_output
    if ! version_output=$("$bash_path" --version 2>&1); then
        print_error "Failed to get version from $bash_path"
        echo "Error output: $version_output"
        return 1
    fi
    
    local version=$(echo "$version_output" | head -n1 | grep -o '[0-9]\+\.[0-9]\+' | head -n1)
    if [ -z "$version" ]; then
        print_error "Could not parse version from: $version_output"
        return 1
    fi
    
    local major_version=${version%%.*}
    if [ "$major_version" -lt 4 ]; then
        print_error "Found Bash $version at $bash_path, but need version 4.0+"
        return 1
    fi
    
    echo "$version"
    return 0
}

# Check if Bash 4+ is available
print_status "Checking Bash version..."

# Check system bash first
SYSTEM_BASH_VERSION=$(check_bash_version "/bin/bash" 2>/dev/null)
if [ $? -eq 0 ] && [ -n "$SYSTEM_BASH_VERSION" ]; then
    BASH_PATH="/bin/bash"
    print_success "Found Bash $SYSTEM_BASH_VERSION at $BASH_PATH (system default)"
elif check_bash_version "/usr/local/bin/bash" >/dev/null 2>&1; then
    BASH_PATH="/usr/local/bin/bash"
    BASH_VERSION=$(check_bash_version "$BASH_PATH")
    print_success "Found Bash $BASH_VERSION at $BASH_PATH"
elif check_bash_version "/opt/homebrew/bin/bash" >/dev/null 2>&1; then
    BASH_PATH="/opt/homebrew/bin/bash"
    BASH_VERSION=$(check_bash_version "$BASH_PATH")
    print_success "Found Bash $BASH_VERSION at $BASH_PATH"
else
    print_warning "Bash 4+ not found in common locations. Attempting installation..."
    
    # Check if Homebrew is available
    if ! command -v brew >/dev/null 2>&1; then
        print_error "Homebrew not found. Cannot install Bash 4+."
        echo ""
        echo "To fix this issue:"
        echo "1. Install Homebrew:"
        echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        echo "2. Then install Bash:"
        echo "   brew install bash"
        echo "3. Re-run this installation script"
        echo ""
        echo "Or manually install Bash 4+ and ensure it's available at one of these paths:"
        echo "   /usr/local/bin/bash"
        echo "   /opt/homebrew/bin/bash"
        exit 1
    fi
    
    print_status "Installing Bash via Homebrew..."
    if ! brew install bash; then
        print_error "Failed to install Bash via Homebrew"
        echo ""
        echo "This could be due to:"
        echo "- Network connectivity issues"
        echo "- Homebrew permissions problems"
        echo "- Insufficient disk space"
        echo ""
        echo "Try these steps:"
        echo "1. Update Homebrew: brew update"
        echo "2. Fix permissions: brew doctor"
        echo "3. Retry installation: brew install bash"
        exit 1
    fi
    
    # Verify installation
    if check_bash_version "/usr/local/bin/bash" >/dev/null 2>&1; then
        BASH_PATH="/usr/local/bin/bash"
        BASH_VERSION=$(check_bash_version "$BASH_PATH")
    elif check_bash_version "/opt/homebrew/bin/bash" >/dev/null 2>&1; then
        BASH_PATH="/opt/homebrew/bin/bash"
        BASH_VERSION=$(check_bash_version "$BASH_PATH")
    else
        print_error "Bash installation completed but executable not found"
        echo ""
        echo "Homebrew may have installed Bash to a different location."
        echo "Try running: brew --prefix bash"
        echo "Then manually set the path or re-run this script."
        exit 1
    fi
    
    print_success "Bash $BASH_VERSION installed successfully at $BASH_PATH"
fi

# Check for required tools
print_status "Checking for required tools..."

# Check for Claude Code CLI (claude mcp command)
if ! command -v claude >/dev/null 2>&1; then
    print_error "Claude Code CLI not found in PATH"
    echo ""
    echo "The claude-mcp tool requires Claude Code CLI to be installed."
    echo ""
    echo "To install Claude Code CLI:"
    echo "1. Download from: https://claude.ai/code"
    echo "2. Or install via npm: npm install -g @anthropic/claude-code"
    echo "3. Ensure 'claude' command is available in your PATH"
    echo ""
    echo "After installation, you should be able to run: claude --version"
    exit 1
fi

# Verify that claude mcp command works
if ! claude mcp --help >/dev/null 2>&1; then
    print_warning "Claude MCP commands may not be available"
    echo ""
    echo "This could mean:"
    echo "1. Claude Code CLI is outdated (update required)"
    echo "2. MCP features are not enabled"
    echo "3. Configuration issue with Claude Code"
    echo ""
    echo "Try updating Claude Code CLI to the latest version"
    echo ""
else
    print_success "Claude Code CLI with MCP support detected"
fi

# Create wrapper script
print_status "Creating claude-mcp command..."

# Determine installation directory
INSTALL_DIR=""
if [ -w "/usr/local/bin" ]; then
    INSTALL_DIR="/usr/local/bin"
    print_status "Using /usr/local/bin (system-wide installation)"
elif [ -w "$HOME/.local/bin" ] 2>/dev/null; then
    INSTALL_DIR="$HOME/.local/bin"
    print_status "Using $HOME/.local/bin (user installation)"
    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        print_warning "Adding $HOME/.local/bin to PATH"
        if ! echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc 2>/dev/null; then
            print_warning "Could not update ~/.bashrc"
        fi
        if ! echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc 2>/dev/null; then
            print_status "Note: ~/.zshrc not found or not writable (this is normal)"
        fi
    fi
else
    # Create ~/.local/bin if it doesn't exist
    print_status "Creating $HOME/.local/bin directory..."
    if ! mkdir -p "$HOME/.local/bin" 2>/dev/null; then
        print_error "Failed to create $HOME/.local/bin directory"
        echo ""
        echo "This could be due to:"
        echo "- Insufficient permissions"
        echo "- Disk space issues"
        echo "- File system problems"
        echo ""
        echo "Try running: mkdir -p $HOME/.local/bin"
        echo "Or install with sudo to /usr/local/bin"
        exit 1
    fi
    
    INSTALL_DIR="$HOME/.local/bin"
    print_status "Using $HOME/.local/bin (user installation)"
    print_warning "Adding $HOME/.local/bin to PATH"
    
    if ! echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc 2>/dev/null; then
        print_warning "Could not update ~/.bashrc - you may need to add $HOME/.local/bin to PATH manually"
    fi
    if ! echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc 2>/dev/null; then
        print_status "Note: ~/.zshrc not found or not writable (this is normal)"
    fi
fi

# Verify installation directory is valid
if [ -z "$INSTALL_DIR" ] || [ ! -d "$INSTALL_DIR" ]; then
    print_error "Could not determine a valid installation directory"
    echo ""
    echo "Tried:"
    echo "- /usr/local/bin (not writable)"
    echo "- $HOME/.local/bin (failed to create)"
    echo ""
    echo "Solutions:"
    echo "1. Run with sudo for system-wide installation"
    echo "2. Create $HOME/.local/bin manually: mkdir -p $HOME/.local/bin"
    echo "3. Specify custom path: INSTALL_DIR=/custom/path $0"
    exit 1
fi

# Create the wrapper script
WRAPPER_SCRIPT="$INSTALL_DIR/claude-mcp"

print_status "Creating wrapper script at $WRAPPER_SCRIPT"

# Check if file already exists and warn user
if [ -f "$WRAPPER_SCRIPT" ]; then
    print_warning "Existing claude-mcp command found at $WRAPPER_SCRIPT - overwriting"
fi

# Create wrapper script with error handling
if ! cat > "$WRAPPER_SCRIPT" << EOF 2>/dev/null
#!/bin/bash
# Claude MCP CLI Wrapper
exec "$BASH_PATH" "$CLAUDE_MCP_SCRIPT" "\$@"
EOF
then
    print_error "Failed to create wrapper script at $WRAPPER_SCRIPT"
    echo ""
    echo "This could be due to:"
    echo "- Insufficient permissions"
    echo "- Disk space issues"
    echo "- Directory not writable"
    echo ""
    echo "Try:"
    echo "1. Check permissions: ls -la $INSTALL_DIR"
    echo "2. Check disk space: df -h"
    echo "3. Run with sudo if needed"
    exit 1
fi

# Make executable with error handling
if ! chmod +x "$WRAPPER_SCRIPT" 2>/dev/null; then
    print_error "Failed to make wrapper script executable"
    echo ""
    echo "Manual fix: chmod +x $WRAPPER_SCRIPT"
    exit 1
fi

print_success "claude-mcp command installed to $WRAPPER_SCRIPT"

# Test the installation
print_status "Testing installation..."

# First check if the wrapper script exists and is executable
if [ ! -f "$WRAPPER_SCRIPT" ]; then
    print_error "Installation test failed: Wrapper script not found at $WRAPPER_SCRIPT"
    exit 1
fi

if [ ! -x "$WRAPPER_SCRIPT" ]; then
    print_error "Installation test failed: Wrapper script is not executable"
    echo "Try: chmod +x $WRAPPER_SCRIPT"
    exit 1
fi

# Test basic functionality
TEST_OUTPUT=""
if TEST_OUTPUT=$("$WRAPPER_SCRIPT" help 2>&1); then
    print_success "Installation successful!"
else
    print_error "Installation test failed: Command execution error"
    echo ""
    echo "Test command: $WRAPPER_SCRIPT help"
    echo "Error output:"
    echo "$TEST_OUTPUT"
    echo ""
    echo "Possible causes:"
    echo "1. Bash path issue: $BASH_PATH"
    echo "2. Main script issue: $CLAUDE_MCP_SCRIPT"
    echo "3. Environment or dependency missing"
    echo ""
    echo "Debug steps:"
    echo "1. Test Bash: $BASH_PATH --version"
    echo "2. Test main script: $BASH_PATH $CLAUDE_MCP_SCRIPT help"
    echo "3. Check PATH: echo \$PATH"
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
