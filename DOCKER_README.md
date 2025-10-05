# MCP fal.ai Server - Docker Kurulumu

Bu proje, fal.ai API'sini Model Context Protocol (MCP) üzerinden kullanmanızı sağlayan bir Docker containerized server'dır.

## 🚀 Hızlı Başlangıç

### 1. Otomatik Kurulum (Önerilen)

```bash
# Kurulum scriptini çalıştır
./setup.sh
```

Bu script:
- Docker ağını oluşturur
- Container'ı build eder
- Server'ı başlatır
- Gerekli kontrolleri yapar

### 2. Manuel Kurulum

```bash
# 1. Environment dosyasını ayarla
cp env.example .env
# .env dosyasını düzenleyip FAL_KEY değerini ayarlayın

# 2. Docker ağını oluştur
docker network create mcp-network

# 3. Container'ı build et ve başlat
docker-compose up --build -d
```

## 📋 Gereksinimler

- Docker
- Docker Compose
- fal.ai API Key

## 🔧 Yapılandırma

### Environment Variables

`.env` dosyasında aşağıdaki değişkenleri ayarlayabilirsiniz:

```bash
# fal.ai API Key (zorunlu)
FAL_KEY=your_fal_api_key_here

# Server ayarları (opsiyonel)
HOST=0.0.0.0
PORT=8080
```

### Docker Compose Ayarları

`docker-compose.yml` dosyasında:
- Port mapping: `8765:8080`
- Network: `mcp-network`
- Restart policy: `unless-stopped`

## 🌐 Erişim

### Host'tan Erişim
```
http://localhost:8765
```

### Diğer Docker Container'lardan Erişim
```
http://mcp-fal-server:8080
```

**Not:** Diğer container'ların erişebilmesi için aynı `mcp-network` ağına bağlı olmaları gerekir.

## 🛠️ Yönetim Komutları

```bash
# Server'ı başlat
docker-compose up -d

# Server'ı durdur
docker-compose down

# Logları görüntüle
docker-compose logs -f

# Container durumunu kontrol et
docker-compose ps

# Container'ı yeniden başlat
docker-compose restart
```

## 🔒 Güvenlik

Bu Docker kurulumu aşağıdaki güvenlik önlemlerini içerir:

- **Non-root user**: Container içinde root yetkisi yok
- **Read-only filesystem**: Dosya sistemi salt okunur
- **No new privileges**: Yeni yetki kazanımı engellenmiş
- **Internal network**: Sadece aynı ağdaki container'lar erişebilir
- **Health checks**: Otomatik sağlık kontrolü

## 📊 Sağlık Kontrolü

Container otomatik olarak sağlık kontrolü yapar:
- URL: `http://localhost:8765/health`
- Interval: 30 saniye
- Timeout: 10 saniye
- Retries: 3

## 🐛 Sorun Giderme

### Container Başlamıyor
```bash
# Logları kontrol et
docker-compose logs

# Container durumunu kontrol et
docker-compose ps
```

### API Key Hatası
```bash
# .env dosyasını kontrol et
cat .env

# Environment variable'ları kontrol et
docker-compose exec mcp-server env | grep FAL_KEY
```

### Ağ Bağlantı Sorunları
```bash
# Ağları listele
docker network ls

# Ağ detaylarını görüntüle
docker network inspect mcp-network
```

## 📝 API Endpoints

MCP server aşağıdaki endpoint'leri sağlar:

- `GET /health` - Sağlık kontrolü
- `POST /mcp` - MCP tool çağrıları
- `GET /docs` - API dokümantasyonu

## 🔄 Güncelleme

```bash
# En son değişiklikleri çek
git pull

# Container'ı yeniden build et
docker-compose up --build -d
```

## 📞 Destek

Sorunlar için:
1. Logları kontrol edin: `docker-compose logs`
2. Container durumunu kontrol edin: `docker-compose ps`
3. Ağ bağlantısını kontrol edin: `docker network inspect mcp-network`
