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
   git clone <your-repo-url>
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

</details>