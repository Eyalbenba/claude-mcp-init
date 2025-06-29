#!/bin/bash

# Configure MCP Servers for Claude
# This script configures all MCP servers based on the .env-mcp file

set -e  # Exit on any error

# =============================================================================
# Configuration - Update these paths for your system
# =============================================================================

# Path to uvx executable - TEAM MEMBERS: UPDATE THIS FOR YOUR SYSTEM
# To find your uvx path, run: which uvx
# Common locations:
# - macOS (Homebrew): /opt/homebrew/bin/uvx
# - macOS (manual install): /Users/$(whoami)/.local/bin/uvx
# - Linux: ~/.local/bin/uvx
# - If uvx is in your PATH, you can just use: "uvx"

# Auto-detect uvx path or use manual override
if [ -n "${UVX_PATH_OVERRIDE:-}" ]; then
    UVX_PATH="$UVX_PATH_OVERRIDE"
elif command -v uvx >/dev/null 2>&1; then
    UVX_PATH="uvx"
elif [ -f "/Users/$(whoami)/.local/bin/uvx" ]; then
    UVX_PATH="/Users/$(whoami)/.local/bin/uvx"
elif [ -f "/opt/homebrew/bin/uvx" ]; then
    UVX_PATH="/opt/homebrew/bin/uvx"
elif [ -f "/usr/local/bin/uvx" ]; then
    UVX_PATH="/usr/local/bin/uvx"
else
    # Fallback - team members should update this
    UVX_PATH="/Users/$(whoami)/.local/bin/uvx"
fi

# GitHub MCP Configuration - Choose one:
# "copilot" = Use GitHub Copilot MCP API (HTTP transport, requires GITHUB_MCP_PAT)
# "uvx" = Use uvx github-mcp-server (stdio transport, requires GITHUB_TOKEN)
GITHUB_MCP_TYPE="copilot"  # <-- UPDATE THIS: "copilot" or "uvx"

# Verify uvx exists
if [ "$UVX_PATH" = "uvx" ]; then
    if ! command -v uvx >/dev/null 2>&1; then
        echo "Error: uvx not found in PATH"
        echo "Please install uvx or set UVX_PATH_OVERRIDE environment variable"
        echo "You can find uvx with: which uvx"
        exit 1
    fi
elif [ ! -f "$UVX_PATH" ]; then
    echo "Error: uvx not found at $UVX_PATH"
    echo "Please install uvx or set UVX_PATH_OVERRIDE environment variable"
    echo "You can find uvx with: which uvx"
    exit 1
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if .env-mcp file exists
if [ ! -f ".env-mcp" ]; then
    print_error ".env-mcp file not found in current directory"
    print_status "Please create .env-mcp file with your environment variables"
    exit 1
fi

print_status "Loading environment variables from .env-mcp..."
set -a && source .env-mcp && set +a

# Verify required environment variables
required_vars=("AWS_PROFILE" "AWS_REGION" "FASTMCP_LOG_LEVEL")
missing_vars=()

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        missing_vars+=("$var")
    fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
    print_error "Missing required environment variables: ${missing_vars[*]}"
    print_status "Please add these variables to your .env-mcp file"
    exit 1
fi

print_success "Environment variables loaded successfully"

# Function to configure MCP server
configure_mcp_server() {
    local server_name="$1"
    local command="$2"
    local args="$3"
    local env_vars="$4"

    print_status "Configuring $server_name..."

    # Build the command with environment variables
    local cmd="claude mcp add \"$server_name\" \"$command\""

    # Add args if provided
    if [ -n "$args" ] && [ "$args" != "[]" ]; then
        # Remove brackets and quotes from args, then add each arg
        local clean_args=$(echo "$args" | sed 's/\[//g' | sed 's/\]//g' | sed 's/"//g')
        cmd="$cmd $clean_args"
    fi

    # Add environment variables (handle special characters properly)
    if [ -n "$env_vars" ]; then
        # Split on space but preserve quoted values
        while IFS= read -r env_var; do
            if [ -n "$env_var" ]; then
                cmd="$cmd -e '$env_var'"
            fi
        done <<< "$(echo "$env_vars" | tr ' ' '\n')"
    fi

    # Add transport
    cmd="$cmd -t stdio"

    print_status "Running: $cmd"

    if eval "$cmd"; then
        print_success "$server_name configured successfully"
    else
        print_error "Failed to configure $server_name"
        return 1
    fi
}

print_status "Starting MCP server configuration..."

# 1. AWS CloudWatch Logs MCP Server
print_status "=== Configuring AWS CloudWatch Logs MCP Server ==="
configure_mcp_server \
    "awslabs.cloudwatch-logs-mcp-server" \
    "$UVX_PATH" \
    "awslabs.cloudwatch-logs-mcp-server@latest" \
    "AWS_PROFILE=$AWS_PROFILE AWS_REGION=$AWS_REGION FASTMCP_LOG_LEVEL=$FASTMCP_LOG_LEVEL"

# 2. MongoDB MCP Server
print_status "=== Configuring MongoDB MCP Server ==="
if [ -n "$MDB_MCP_CONNECTION_STRING" ]; then
    configure_mcp_server \
        "mongodb-mcp-server" \
        "$UVX_PATH" \
        "mongodb-mcp-server@latest" \
        "MDB_MCP_CONNECTION_STRING="$MDB_MCP_CONNECTION_STRING" DO_NOT_TRACK=1 MDB_MCP_READ_ONLY=true MDB_MCP_TELEMETRY=disabled"
else
    print_warning "MDB_MCP_CONNECTION_STRING not found in .env-mcp, skipping MongoDB MCP server"
fi

# 3. Snowflake MCP Server
print_status "=== Configuring Snowflake MCP Server ==="
snowflake_vars=("SNOWFLAKE_ACCOUNT" "SNOWFLAKE_USER" "SNOWFLAKE_PASSWORD" "SNOWFLAKE_DATABASE" "SNOWFLAKE_WAREHOUSE" "SNOWFLAKE_SCHEMA")
snowflake_missing=()

for var in "${snowflake_vars[@]}"; do
    if [ -z "${!var}" ]; then
        snowflake_missing+=("$var")
    fi
done

if [ ${#snowflake_missing[@]} -eq 0 ]; then
    print_status "Configuring Snowflake MCP Server..."

    # Snowflake MCP server requires special uvx arguments
    if claude mcp add "Snowflake MCP" "$UVX_PATH" \
        -e "SNOWFLAKE_ACCOUNT=$SNOWFLAKE_ACCOUNT" \
        -e "SNOWFLAKE_USER=$SNOWFLAKE_USER" \
        -e "SNOWFLAKE_PASSWORD=$SNOWFLAKE_PASSWORD" \
        -e "SNOWFLAKE_DATABASE=$SNOWFLAKE_DATABASE" \
        -e "SNOWFLAKE_WAREHOUSE=$SNOWFLAKE_WAREHOUSE" \
        -e "SNOWFLAKE_SCHEMA=$SNOWFLAKE_SCHEMA" \
        -t stdio -- --python=3.12 mcp_snowflake_server; then
        print_success "Snowflake MCP Server configured successfully"
    else
        print_error "Failed to configure Snowflake MCP Server"
    fi
else
    print_warning "Missing Snowflake variables: ${snowflake_missing[*]}, skipping Snowflake MCP server"
fi

# 4. Linear MCP Server (using remote server - no API key needed)
print_status "=== Configuring Linear MCP Server ==="
print_status "Configuring Linear MCP Server (remote)..."

if claude mcp add Linear -- npx -y mcp-remote https://mcp.linear.app/sse; then
    print_success "Linear MCP Server configured successfully"
else
    print_error "Failed to configure Linear MCP Server"
    print_status "Make sure npx is installed: npm install -g npx"
fi

# 5. Notion MCP Server
print_status "=== Configuring Notion MCP Server ==="
if [ -n "$NOTION_API_KEY" ]; then
    configure_mcp_server \
        "notion-mcp-server" \
        "$UVX_PATH" \
        "notion-mcp-server@latest" \
        "NOTION_API_KEY=$NOTION_API_KEY FASTMCP_LOG_LEVEL=$FASTMCP_LOG_LEVEL"
else
    print_warning "NOTION_API_KEY not found in .env-mcp, skipping Notion MCP server"
fi

# 6. GitHub MCP Server
print_status "=== Configuring GitHub MCP Server ==="

if [ "$GITHUB_MCP_TYPE" = "copilot" ]; then
    # GitHub Copilot MCP API (HTTP transport)
    print_status "Configuring GitHub Copilot MCP Server (HTTP)..."
    if [ -n "$GITHUB_PAT" ]; then
        if claude mcp add github "https://api.githubcopilot.com/mcp/" \
            -t http \
            -H "Authorization: Bearer $GITHUB_PAT"; then
            print_success "GitHub Copilot MCP Server configured successfully"
        else
            print_error "Failed to configure GitHub Copilot MCP Server"
        fi
    else
        print_warning "GITHUB_PAT not found in .env-mcp, skipping GitHub Copilot MCP server"
    fi
elif [ "$GITHUB_MCP_TYPE" = "uvx" ]; then
    # Traditional uvx github-mcp-server (stdio transport)
    print_status "Configuring GitHub MCP Server (uvx)..."
    if [ -n "$GITHUB_TOKEN" ]; then
        configure_mcp_server \
            "github-mcp-server" \
            "$UVX_PATH" \
            "github-mcp-server@latest" \
            "GITHUB_TOKEN=$GITHUB_TOKEN FASTMCP_LOG_LEVEL=$FASTMCP_LOG_LEVEL"
    else
        print_warning "GITHUB_TOKEN not found in .env-mcp, skipping GitHub MCP server"
    fi
else
    print_error "Invalid GITHUB_MCP_TYPE: $GITHUB_MCP_TYPE. Must be 'copilot' or 'uvx'"
fi

# 7. Zen MCP Server
print_status "=== Configuring Zen MCP Server ==="
if [ -n "$OPENAI_API_KEY" ]; then
    print_status "Configuring Zen MCP Server..."

    # Check if zen-mcp-server directory exists
    if [ -d "zen-mcp-server" ]; then
        print_status "Found existing zen-mcp-server directory"
        ZEN_SERVER_PATH="$(pwd)/zen-mcp-server/run-server.sh"
    else
        print_warning "zen-mcp-server directory not found. Please clone it first:"
        print_status "git clone https://github.com/BeehiveInnovations/zen-mcp-server.git"
        print_status "cd zen-mcp-server && ./run-server.sh"
        print_warning "Skipping Zen MCP server configuration"
        ZEN_SERVER_PATH=""
    fi

    if [ -n "$ZEN_SERVER_PATH" ] && [ -f "$ZEN_SERVER_PATH" ]; then
        if claude mcp add zen-mcp-server "$ZEN_SERVER_PATH" \
            -e "OPENAI_API_KEY=$OPENAI_API_KEY" \
            -e "FASTMCP_LOG_LEVEL=$FASTMCP_LOG_LEVEL" \
            -t stdio; then
            print_success "Zen MCP Server configured successfully"
        else
            print_error "Failed to configure Zen MCP Server"
        fi
    fi
else
    print_warning "OPENAI_API_KEY not found in .env-mcp, skipping Zen MCP server"
    print_status "Add OPENAI_API_KEY=your_openai_api_key to .env-mcp to use Zen MCP"
fi

# 8. Tavily Web Search MCP Server
print_status "=== Configuring Tavily Web Search MCP Server ==="
if [ -n "$TAVILY_API_KEY" ]; then
    print_status "Configuring Tavily MCP Server..."

    # Tavily MCP server uses npx, not uvx
    if claude mcp add "tavily-mcp" "npx" \
        -e "TAVILY_API_KEY=$TAVILY_API_KEY" \
        -t stdio -- -y tavily-mcp@latest; then
        print_success "Tavily MCP Server configured successfully"
    else
        print_error "Failed to configure Tavily MCP Server"
    fi
else
    print_warning "TAVILY_API_KEY not found in .env-mcp, skipping Tavily MCP server"
    print_status "Add TAVILY_API_KEY=your_tavily_api_key to .env-mcp to use Tavily search"
fi

print_success "MCP server configuration completed!"
print_status "You can now use Claude with all configured MCP servers"
print_status "To verify configuration, run: claude mcp list"
