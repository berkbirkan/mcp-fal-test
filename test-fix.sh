#!/bin/bash

# Hetzner Sunucu Test Scripti
# FastMCP düzeltmesini test etmek için

echo "🧪 FastMCP Düzeltmesi Test Ediliyor..."

# Mevcut container'ı durdur
echo "Mevcut container durduruluyor..."
docker stop mcp-fal-server 2>/dev/null || true
docker rm mcp-fal-server 2>/dev/null || true

# Yeni imajı build et
echo "Yeni Docker imajı build ediliyor..."
if docker build -t mcp-fal-server .; then
    echo "✅ Docker imajı başarıyla build edildi"
else
    echo "❌ Docker imajı build edilemedi!"
    exit 1
fi

# Container'ı başlat
echo "Container başlatılıyor..."
if docker run -d \
    --name mcp-fal-server \
    --restart unless-stopped \
    -p 8765:8080 \
    -e HOST=0.0.0.0 \
    -e PORT=8080 \
    -e FAL_KEY="${FAL_KEY:-test_key}" \
    mcp-fal-server; then
    
    echo "✅ Container başlatıldı"
    
    # 10 saniye bekle
    echo "Container'ın başlamasını bekliyor..."
    sleep 10
    
    # Container durumunu kontrol et
    if docker ps | grep -q "mcp-fal-server"; then
        echo "✅ Container çalışıyor"
        
        # Logları kontrol et
        echo "📋 Son loglar:"
        docker logs --tail 20 mcp-fal-server
        
        # Port testi
        echo "🌐 Port testi yapılıyor..."
        sleep 5  # Ekstra bekleme süresi
        if curl -s -o /dev/null -w "%{http_code}" http://localhost:8765 | grep -q "200\|404\|405"; then
            echo "✅ Port 8765 erişilebilir"
        else
            echo "⚠️ Port 8765 henüz hazır değil, biraz daha bekleyin"
            echo "📋 Son loglar:"
            docker logs --tail 10 mcp-fal-server
        fi
        
        echo ""
        echo "🎉 Test tamamlandı!"
        echo "📊 Server bilgileri:"
        echo "  - URL: http://localhost:8765"
        echo "  - Container: mcp-fal-server"
        echo "  - Loglar: docker logs -f mcp-fal-server"
        
    else
        echo "❌ Container başlatılamadı!"
        echo "📋 Hata logları:"
        docker logs mcp-fal-server
        exit 1
    fi
else
    echo "❌ Container başlatılamadı!"
    exit 1
fi
