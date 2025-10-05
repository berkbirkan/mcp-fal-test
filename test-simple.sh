#!/bin/bash

# FastMCP Basit Test Scripti
# Eğer run_http_async de çalışmazsa bu scripti kullanın

echo "🧪 FastMCP Basit Test..."

# Mevcut container'ı durdur
echo "Mevcut container durduruluyor..."
docker stop mcp-fal-server 2>/dev/null || true
docker rm mcp-fal-server 2>/dev/null || true

# Test için basit bir main.py oluştur
cat > main_simple.py << 'EOF'
"""
Basit FastMCP Test Server
"""
import os
import sys
import asyncio
from fastmcp import FastMCP

# Basit FastMCP server oluştur
mcp = FastMCP("Test Server")

@mcp.tool()
async def test_tool(message: str) -> str:
    """Basit test tool'u"""
    return f"Echo: {message}"

async def main():
    try:
        host = os.getenv("HOST", "0.0.0.0")
        port = int(os.getenv("PORT", "8080"))
        
        print(f"Starting simple MCP server on {host}:{port}")
        
        # En basit kullanım - parametresiz
        await mcp.run_http_async()
        
    except Exception as e:
        print(f"Error: {e}")
        # Alternatif: sadece run() metodunu dene
        try:
            print("Trying simple run() method...")
            mcp.run()
        except Exception as e2:
            print(f"Simple run() also failed: {e2}")
            sys.exit(1)

if __name__ == "__main__":
    asyncio.run(main())
EOF

# Dockerfile'ı güncelle
cat > Dockerfile.simple << 'EOF'
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY main_simple.py main.py

RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8080

ENV PYTHONPATH=/app
ENV HOST=0.0.0.0
ENV PORT=8080

CMD ["python", "main.py"]
EOF

# Basit imajı build et
echo "Basit Docker imajı build ediliyor..."
if docker build -f Dockerfile.simple -t mcp-fal-server-simple .; then
    echo "✅ Basit Docker imajı build edildi"
else
    echo "❌ Basit Docker imajı build edilemedi!"
    exit 1
fi

# Container'ı başlat
echo "Basit container başlatılıyor..."
if docker run -d \
    --name mcp-fal-server-simple \
    --restart unless-stopped \
    -p 8765:8080 \
    -e HOST=0.0.0.0 \
    -e PORT=8080 \
    mcp-fal-server-simple; then
    
    echo "✅ Basit container başlatıldı"
    
    # 20 saniye bekle
    echo "Container'ın başlamasını bekliyor..."
    sleep 20
    
    # Logları kontrol et
    echo "📋 Loglar:"
    docker logs --tail 30 mcp-fal-server-simple
    
    # Container durumunu kontrol et
    if docker ps | grep -q "mcp-fal-server-simple"; then
        echo "✅ Basit container çalışıyor"
        echo "🌐 Test URL: http://localhost:8765"
    else
        echo "❌ Basit container başlatılamadı!"
    fi
else
    echo "❌ Basit container başlatılamadı!"
fi

# Temizlik
rm -f main_simple.py Dockerfile.simple
