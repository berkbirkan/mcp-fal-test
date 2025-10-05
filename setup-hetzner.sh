#!/bin/bash

# Hetzner Sunucu için MCP Docker Kurulum Scripti
# Bu script Docker daemon sorunları için alternatif çözümler sunar

set -e

echo "🚀 Hetzner Sunucu için MCP fal.ai Server Docker Kurulumu..."

# Renkli çıktı için fonksiyonlar
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Docker'ın çalışıp çalışmadığını kontrol et
if ! command -v docker &> /dev/null; then
    print_error "Docker yüklü değil. Lütfen Docker'ı yükleyin."
    exit 1
fi

print_success "Docker bulundu"

# .env dosyasının varlığını kontrol et
if [ ! -f ".env" ]; then
    print_warning ".env dosyası bulunamadı. env.example'dan kopyalanıyor..."
    if [ -f "env.example" ]; then
        cp env.example .env
        print_warning "Lütfen .env dosyasını düzenleyip FAL_KEY değerini ayarlayın!"
        print_warning "Örnek: FAL_KEY=your_actual_api_key_here"
    else
        print_error "env.example dosyası bulunamadı!"
        exit 1
    fi
fi

# Docker imajını build et
print_status "Docker imajı build ediliyor..."
if docker build -t mcp-fal-server .; then
    print_success "Docker imajı başarıyla build edildi"
else
    print_error "Docker imajı build edilemedi!"
    print_status "Alternatif çözüm: Docker daemon'ı yeniden başlatın"
    print_status "sudo systemctl restart docker"
    exit 1
fi

# Mevcut container'ı durdur ve kaldır
print_status "Mevcut container'lar temizleniyor..."
docker stop mcp-fal-server 2>/dev/null || true
docker rm mcp-fal-server 2>/dev/null || true

# Container'ı başlat
print_status "MCP server başlatılıyor..."
if docker run -d \
    --name mcp-fal-server \
    --restart unless-stopped \
    -p 8765:8080 \
    -e HOST=0.0.0.0 \
    -e PORT=8080 \
    -e FAL_KEY="${FAL_KEY:-}" \
    -v "$(pwd)/logs:/app/logs" \
    mcp-fal-server; then
    
    print_success "MCP server başarıyla başlatıldı!"
    
    # Container'ın çalışıp çalışmadığını kontrol et
    sleep 5
    if docker ps | grep -q "mcp-fal-server"; then
        print_status "Server bilgileri:"
        echo "  - URL: http://localhost:8765"
        echo "  - Container adı: mcp-fal-server"
        echo "  - Host Port: 8765"
        echo "  - Container Port: 8080"
        echo ""
        print_status "Logları görüntülemek için:"
        echo "  docker logs -f mcp-fal-server"
        echo ""
        print_status "Container'ı durdurmak için:"
        echo "  docker stop mcp-fal-server"
        echo "  docker rm mcp-fal-server"
    else
        print_error "Container başlatılamadı!"
        print_status "Logları kontrol edin:"
        docker logs mcp-fal-server
        exit 1
    fi
else
    print_error "Container başlatılamadı!"
    exit 1
fi

print_success "Kurulum tamamlandı! 🎉"
