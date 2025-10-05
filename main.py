"""
fal.ai MCP Server : Main entry point

This module sets up and runs the fal.ai MCP server,
providing tools to interact with fal.ai models and services.
"""

import os
import sys
from fastmcp import FastMCP
from api.models import register_model_tools
from api.generate import register_generation_tools
from api.storage import register_storage_tools
from api.config import get_api_key, SERVER_NAME, SERVER_DESCRIPTION, SERVER_VERSION, SERVER_DEPENDENCIES

mcp = FastMCP(SERVER_NAME)

register_model_tools(mcp)
register_generation_tools(mcp)
register_storage_tools(mcp)

def main():
    try:
        get_api_key()
    except ValueError:
        print("Warning: FAL_KEY environment variable not set. Some features may not work.")
    
    try:
        # HTTP server olarak çalıştır
        host = os.getenv("HOST", "0.0.0.0")
        port = int(os.getenv("PORT", "8080"))
        
        print(f"Starting MCP server on {host}:{port}")
        
        # FastMCP'nin basit run metodu
        mcp.run()
        
    except Exception as e:
        print(f"Error starting server: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()