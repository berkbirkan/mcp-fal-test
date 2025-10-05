#!/bin/bash

# MCP Docker Kurulum Scripti
# Bu script MCP server'ını Docker ile kurar ve yapılandırır

set -e

echo "🚀 MCP fal.ai Server Docker Kurulumu Başlıyor..."

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

# Docker'ın yüklü olup olmadığını kontrol et
if ! command -v docker &> /dev/null; then
    print_error "Docker yüklü değil. Lütfen Docker'ı yükleyin."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose yüklü değil. Lütfen Docker Compose'u yükleyin."
    exit 1
fi

print_success "Docker ve Docker Compose bulundu"

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

# Docker ağını oluştur
print_status "Docker ağı oluşturuluyor..."
if docker network ls | grep -q "mcp-network"; then
    print_warning "mcp-network ağı zaten mevcut"
else
    docker network create mcp-network
    print_success "mcp-network ağı oluşturuldu"
fi

# Docker imajını build et
print_status "Docker imajı build ediliyor..."
docker-compose build

# Container'ı başlat
print_status "MCP server başlatılıyor..."
docker-compose up -d

# Container'ın çalışıp çalışmadığını kontrol et
sleep 5
if docker-compose ps | grep -q "Up"; then
    print_success "MCP server başarıyla başlatıldı!"
    print_status "Server bilgileri:"
    echo "  - URL: http://localhost:8080"
    echo "  - Container adı: mcp-fal-server"
    echo "  - Ağ: mcp-network"
    echo ""
    print_status "Diğer container'lardan erişim için:"
    echo "  - URL: http://mcp-fal-server:8080"
    echo "  - Aynı mcp-network ağına bağlı container'lar erişebilir"
    echo ""
    print_status "Logları görüntülemek için:"
    echo "  docker-compose logs -f"
    echo ""
    print_status "Container'ı durdurmak için:"
    echo "  docker-compose down"
else
    print_error "MCP server başlatılamadı!"
    print_status "Logları kontrol edin:"
    docker-compose logs
    exit 1
fi

print_success "Kurulum tamamlandı! 🎉"
