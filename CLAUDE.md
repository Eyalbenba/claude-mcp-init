# Claude MCP Init - Project Documentation

This file contains detailed project information for contributors and maintainers.

## Project Overview

Claude MCP Init is a configuration management tool specifically designed for Claude Code users to easily set up and manage Model Context Protocol (MCP) servers. The tool provides a beautiful interactive CLI interface that simplifies the complex process of configuring multiple MCP integrations.

## Architecture

### Core Components

- **`src/mcp-setup/claude-mcp`** - Main interactive CLI script with Bash 4+ associative arrays
- **`src/mcp-setup/install-claude-mcp.sh`** - Installation script that sets up the global command
- **`.env-mcp`** - Environment configuration file (gitignored)
- **`.env-mcp.example`** - Template for environment variables

### Design Principles

1. **User-Friendly**: Beautiful CLI with colors, status indicators, and clear messaging
2. **Extensible**: Easy to add new MCP servers following established patterns
3. **Secure**: Environment-based configuration, no hardcoded credentials
4. **Robust**: Requirement validation, error handling, and graceful fallbacks
5. **Cross-Platform**: Auto-detection of system paths and dependencies

## Supported MCP Servers

Currently supports 9 MCP server integrations:

| Server | Type | Transport | Requirements |
|--------|------|-----------|-------------|
| AWS CloudWatch | Database/Logs | stdio | AWS credentials |
| Snowflake | Database | stdio | Snowflake credentials |
| Linear | Project Management | SSE | None (remote) |
| GitHub | Code Repository | HTTP/stdio | GitHub token |
| Notion | Documentation | stdio | Notion API key |
| Tavily | Web Search | stdio | Tavily API key |
| Zen AI | AI Workflows | stdio | OpenAI API key + local server |
| MongoDB | Database | stdio | MongoDB connection string |
| Context7 | Code Documentation | HTTP/SSE/stdio | None (remote/npm) |

## Technical Details

### Bash Version Requirements

- Requires Bash 4.0+ for associative arrays
- Auto-installs via Homebrew on macOS if needed
- Graceful fallback and clear error messages for unsupported versions

### Path Detection

- Auto-detects `uvx` installation in common locations
- Supports manual override via `UVX_PATH_OVERRIDE` environment variable
- Validates executables before attempting configuration

### Configuration Patterns

Each MCP server follows a consistent pattern:

1. **Server Definition**: Name, description, and requirements in associative arrays
2. **Requirement Check**: Validates environment variables and dependencies
3. **Configuration Function**: Implements the actual `claude mcp add` command
4. **Error Handling**: Provides clear success/failure messages

### Interactive Menu System

- Numbered server selection with status indicators
- Batch configuration ("Configure All Available")
- Requirements validation with clear missing dependency messages
- Graceful error handling and user guidance

## Development Workflow

### Adding New MCP Servers

1. **Server Arrays**: Add to `MCP_SERVERS`, `MCP_DESCRIPTIONS`, `MCP_REQUIREMENTS`
2. **Requirements Check**: Handle special cases in `check_requirements()`
3. **Configuration Function**: Implement `configure_[server]_server()`
4. **Case Statement**: Add to the switch in `configure_server()`
5. **Documentation**: Update README and environment template

### Testing

- Test installation: `./src/mcp-setup/install-claude-mcp.sh`
- Test status: `claude-mcp status`
- Test configuration: `claude-mcp configure`
- Test removal: `claude-mcp remove`

### Code Style

- Use consistent error/success messaging with colored output
- Follow existing naming conventions (`configure_[server]_server`)
- Include proper error handling and graceful fallbacks
- Maintain the user-friendly interactive experience

## Security Considerations

- All API keys stored in `.env-mcp` (gitignored)
- No hardcoded credentials in scripts
- Environment variable validation before use
- Secure transport protocols (HTTPS, WSS) for remote servers

## Contribution Guidelines

- Follow the established patterns for consistency
- Test thoroughly across different environments
- Update documentation (README.md and .env-mcp.example)
- Ensure error messages are helpful and actionable
- Use the Context7 integration as a reference example

## Future Enhancements

- Support for more MCP servers as they become available
- Configuration profiles for different environments
- Backup and restore functionality for configurations
- Integration with Claude Code workspace settings
- Automated testing framework for server configurations

## Troubleshooting Common Issues

### Bash Version
- Install newer Bash: `brew install bash`
- Use specific Bash: `/opt/homebrew/bin/bash claude-mcp configure`

### UVX Path Issues
- Set override: `export UVX_PATH_OVERRIDE="/path/to/uvx"`
- Check installation: `which uvx`

### Permission Issues
- Make scripts executable: `chmod +x src/mcp-setup/*`
- Check PATH: `echo $PATH`

### API Key Issues
- Validate format and permissions
- Check environment loading: `claude-mcp status`
- Review `.env-mcp` syntax

This project aims to make MCP server configuration accessible to all Claude Code users, regardless of their technical expertise.