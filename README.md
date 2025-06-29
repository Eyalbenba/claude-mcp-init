# Claude Code MCP Setup

A user-friendly command-line interface for configuring Model Context Protocol (MCP) servers with Claude Code.

## Features

- 🎨 **Beautiful CLI Interface** - Colorful, intuitive menus and status displays
- 🔧 **Interactive Configuration** - Choose which MCP servers to configure
- ✅ **Requirement Validation** - Automatically checks if API keys and dependencies are available
- 🚀 **One-Command Setup** - Install and configure everything with simple commands
- 🔄 **Server Management** - List, remove, and check status of configured servers

## Quick Setup

1. **Clone and install**
   ```bash
   git clone https://github.com/Eyalbenba/claude-mcp-init
   cd claude-mcp-init
   ./src/mcp-setup/install-claude-mcp.sh
   ```

2. **Configure environment**
   ```bash
   cp src/mcp-setup/.env-mcp.example .env-mcp
   # Edit .env-mcp with your API keys
   ```

3. **Setup MCP servers**
   ```bash
   claude-mcp status    # Check requirements
   claude-mcp configure # Interactive setup
   ```

## Commands

| Command | Description |
|---------|-------------|
| `claude-mcp configure` | Interactive MCP server configuration |
| `claude-mcp status` | Check server requirements and status |
| `claude-mcp list` | List configured MCP servers |
| `claude-mcp remove` | Remove MCP servers |
| `claude-mcp help` | Show help information |

## Environment Variables

Required in `.env-mcp` file:

```bash
# AWS (for CloudWatch)
AWS_PROFILE=your-profile
AWS_REGION=us-east-1

# API Keys (optional, based on servers you want)
GITHUB_PAT=your-github-token
NOTION_API_KEY=your-notion-key
TAVILY_API_KEY=your-tavily-key
OPENAI_API_KEY=your-openai-key

# Database connections (optional)
SNOWFLAKE_ACCOUNT=your-account
SNOWFLAKE_USER=your-user
SNOWFLAKE_PASSWORD=your-password
MDB_MCP_CONNECTION_STRING=your-mongodb-uri
```

## File Structure

```
src/mcp-setup/
├── claude-mcp                 # Interactive CLI tool
├── install-claude-mcp.sh      # Installation script
├── .env-mcp.example          # Environment template
└── zen-mcp-server/           # Advanced AI workflow server

.env-mcp                       # Your API keys (gitignored)
```

## Troubleshooting

### Command not found
```bash
# Restart terminal or add to PATH
export PATH="$HOME/.local/bin:$PATH"
```

### Bash version issues (macOS)
```bash
brew install bash
/opt/homebrew/bin/bash claude-mcp configure
```

### Missing API keys
The `claude-mcp status` command shows exactly which environment variables are missing.

## Contributing

### Adding a New MCP Server

To add support for a new MCP server:

1. **Edit the server definitions** in `src/mcp-setup/claude-mcp`:
   ```bash
   # Add to the MCP server arrays
   MCP_SERVERS[newserver]="New Server Name"
   MCP_DESCRIPTIONS[newserver]="Description of what this server does"
   MCP_REQUIREMENTS[newserver]="REQUIRED_ENV_VAR, ANOTHER_VAR"
   ```

2. **Add configuration function**:
   ```bash
   configure_newserver_server() {
       if claude mcp add "server-name" "$UVX_PATH" \
           server-package@latest \
           -e "ENV_VAR=$ENV_VAR" \
           -t stdio; then
           print_success "New Server configured successfully"
       else
           print_error "Failed to configure New Server"
           return 1
       fi
   }
   ```

3. **Add to the case statement**:
   ```bash
   case "$server_key" in
       # ... existing servers ...
       "newserver")
           configure_newserver_server
           ;;
   ```

4. **Update documentation**:
   - Add the server to the supported servers table in this README
   - Add any required environment variables to `.env-mcp.example`

5. **Test the integration**:
   ```bash
   claude-mcp status    # Should show your new server
   claude-mcp configure # Should allow configuring it
   ```

See the Context7 integration as a reference example.

<details>
<summary>Supported MCP Servers</summary>

| Server | Description | Requirements |
|--------|-------------|--------------|
| **AWS CloudWatch** | Access AWS logs and metrics | `AWS_PROFILE`, `AWS_REGION` |
| **Snowflake** | Query databases with natural language | `SNOWFLAKE_ACCOUNT`, `SNOWFLAKE_USER`, etc. |
| **Linear** | Project management integration | None (remote server) |
| **GitHub** | Repository and issue management | `GITHUB_PAT` or `GITHUB_TOKEN` |
| **Notion** | Documentation and knowledge base | `NOTION_API_KEY` |
| **Tavily** | Web search and content extraction | `TAVILY_API_KEY` |
| **Zen** | Enhanced AI capabilities and workflows | `OPENAI_API_KEY` |
| **MongoDB** | Database operations | `MDB_MCP_CONNECTION_STRING` |
| **Context7** | Up-to-date code documentation for any prompt | None (remote server or npm package) |

</details>