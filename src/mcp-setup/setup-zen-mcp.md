# Zen MCP Server Setup Guide

## Overview
Zen MCP Server provides advanced AI model access through Claude, allowing you to use OpenAI models with enhanced capabilities like deep thinking, code review, debugging, and analysis.

## Prerequisites
- Python 3.10+ (3.12 recommended)
- Git
- OpenAI API key

## Setup Steps

### 1. Clone Zen MCP Server
```bash
# From your browser-pool directory
git clone https://github.com/BeehiveInnovations/zen-mcp-server.git
cd zen-mcp-server
```

**Note**: The `zen-mcp-server/` directory is automatically added to `.gitignore` to prevent committing sensitive API keys and the cloned repository.

### 2. Run Initial Setup
```bash
# This sets up everything automatically
./run-server.sh
```

### 3. Configure API Key
```bash
# Edit the .env file in zen-mcp-server directory
nano .env

# Add your OpenAI API key:
OPENAI_API_KEY=your-openai-api-key-here
```

### 4. Update Your Main .env-mcp File
Add your OpenAI API key to the main `.env-mcp` file in the browser-pool root:
```bash
OPENAI_API_KEY=your-openai-api-key-here
```

**Security Note**: The `.env-mcp` file is already in `.gitignore` to protect your API keys from being committed to version control.

### 5. Run Configuration Script
```bash
# From browser-pool root directory
./.agent/.claude/configure-mcp-servers.sh
```

## Usage Examples

Once configured, you can use Zen naturally in Claude:

- **Deep Thinking**: "Think deeper about this architecture design with zen"
- **Code Review**: "Using zen perform a code review of this code for security issues"  
- **Debugging**: "Use zen and debug why this test is failing"
- **Analysis**: "With zen, analyze these files to understand the data flow"
- **Specific Models**: "Use o3 to debug this logic error" (uses OpenAI O3 specifically)

## Verification

After setup, verify Zen is working:
```bash
# Check MCP server list
claude mcp list

# Should show:
# zen-mcp-server: /path/to/zen-mcp-server/run-server.sh
```

## Troubleshooting

### Common Issues:
1. **Python version**: Ensure Python 3.10+ is installed
2. **API key**: Make sure OpenAI API key is valid and has credits
3. **Permissions**: Ensure `run-server.sh` is executable: `chmod +x run-server.sh`

### Getting Help:
- Check Zen MCP logs in the zen-mcp-server directory
- Verify API key works with OpenAI directly
- Ensure Claude can access the run-server.sh script

## Notes
- Only OpenAI models are configured (no OpenRouter)
- The server reads .env file each time, so no restart needed for API key changes
- Always run `./run-server.sh` again after `git pull` to keep everything current
