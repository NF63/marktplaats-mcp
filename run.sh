#!/bin/bash
# Run the Marktplaats MCP Server

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create venv if it doesn't exist
if [ ! -d "$SCRIPT_DIR/.venv" ]; then
    python3 -m venv "$SCRIPT_DIR/.venv"
    "$SCRIPT_DIR/.venv/bin/pip" install -e "$SCRIPT_DIR"
fi

# Run the server
exec "$SCRIPT_DIR/.venv/bin/python" -m marktplaats_mcp
