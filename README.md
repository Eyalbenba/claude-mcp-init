# Claude Code MCP Configuration Manager

A lightweight CLI for configuring Model Context Protocol (MCP) servers with Claude Code.

## Table of Contents

- [Features](#features)
- [Supported MCP Servers](#supported-mcp-servers)
- [Quick Setup](#quick-setup)
- [Commands](#commands)
- [Environment Variables](#environment-variables)
- [File Structure](#file-structure)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Features

- 🎨 **Beautiful CLI Interface** - Colorful, intuitive menus and status displays
- 🔧 **Interactive Configuration** - Choose which MCP servers to configure
- ✅ **Requirement Validation** - Automatically checks if API keys and dependencies are available
- 🚀 **One-Command Setup** - Install and configure everything with simple commands
- 🔄 **Server Management** - List, remove, and check status of configured servers
- 🔐 **Secure Configuration** - Environment-based API key management

## Supported MCP Servers

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
| **Interrupt User** | Ask human for context and additional information | None (uvx package) |

## Quick Setup

1. **Clone and install**
   ```bash
   git clone https://github.com/Eyalbenba/claude-code-mcp-init
   cd claude-code-mcp-init
   ./src/mcp-setup/install-claude-mcp.sh
   ```

2. **Configure environment**
   ```bash
   cp .env-mcp.example .env-mcp
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

We welcome contributions! 🎉 Here's how to get started:

**Quick Start:** Fork → Clone → Test → Submit PR

### 🚀 Ways to Contribute
- 🐛 **Bug fixes** - Fix issues or improve error handling
- ✨ **New MCP servers** - Add support for more services  
- 📚 **Documentation** - Improve guides and examples
- 🧪 **Testing** - Help validate configurations

### 📋 Contribution Standards
- **Branch naming:** `feat/server-name` or `bugfix/description`
- **Test your changes:** Run `claude-mcp status` and `claude-mcp configure`
- **Follow patterns:** Use existing code style in `src/mcp-setup/claude-mcp`
- **Update docs:** Add new servers to README table and `.env-mcp.example`

<details>
<summary>🔧 Adding a New MCP Server</summary>

### Step-by-Step Guide

1. **Define the server** in `src/mcp-setup/claude-mcp`:
   ```bash
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

3. **Wire it up** in the case statement:
   ```bash
   case "$server_key" in
       # ... existing servers ...
       "newserver")
           configure_newserver_server
           ;;
   ```

4. **Update documentation**:
   - Add server to the Supported MCP Servers table above
   - Add environment variables to `.env-mcp.example`

5. **Test thoroughly**:
   ```bash
   claude-mcp status    # Should show your new server
   claude-mcp configure # Should allow configuring it
   ```

**Reference:** See the Context7 integration as a complete example.

</details>

<details>
<summary>💻 Development Setup</summary>

### Quick Setup
```bash
# Fork the repo on GitHub, then:
git clone https://github.com/YOUR-USERNAME/claude-mcp-init
cd claude-mcp-init
./src/mcp-setup/install-claude-mcp.sh

# Create test environment
cp .env-mcp.example .env-mcp
# Edit .env-mcp with your test credentials

# Test your changes
claude-mcp status
claude-mcp configure
```

### Requirements
- Bash 4.0+ (auto-installed on macOS via Homebrew)
- uvx (auto-detected or set `UVX_PATH_OVERRIDE`)
- Claude Code CLI

</details>

<details>
<summary>📝 Pull Request Checklist</summary>

### Before Submitting
- [ ] **Tested locally** - Your changes work with `claude-mcp status` and `claude-mcp configure`
- [ ] **Documentation updated** - README table and `.env-mcp.example` if adding new server
- [ ] **Code follows patterns** - Matches existing style and structure
- [ ] **Branch named correctly** - `feat/server-name` or `bugfix/description`
- [ ] **Clear commit message** - Explains what and why

### Pull Request Template
```markdown
## Changes
- Brief description of what you added/fixed

## Testing
- [ ] Tested with `claude-mcp status`
- [ ] Tested with `claude-mcp configure`
- [ ] Updated documentation if needed

## Type of Change
- [ ] Bug fix
- [ ] New MCP server
- [ ] Documentation update
- [ ] Other: ___________
```

</details>

<details>
<summary>🤝 Community Guidelines</summary>

### Code of Conduct
- **Be respectful** and inclusive in all interactions
- **Help others** learn and contribute
- **Focus on constructive feedback** in reviews
- **Assume good intentions** from contributors

### Getting Help
- **Issues** - Use GitHub Issues for bugs and feature requests
- **Discussions** - Use GitHub Discussions for questions
- **Security** - Email security issues privately (see Security section)

### Recognition
All contributors will be recognized in our release notes and contributor acknowledgments.

</details>
