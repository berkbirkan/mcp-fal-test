# Python 3.11 slim imajını kullan
FROM python:3.11-slim

# Çalışma dizinini ayarla
WORKDIR /app

# Python bağımlılıklarını kopyala ve yükle
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Uygulama dosyalarını kopyala
COPY . .

# Güvenlik için non-root kullanıcı oluştur
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Port 8080'i expose et
EXPOSE 8080

# Sağlık kontrolü için environment variable
ENV PYTHONPATH=/app
ENV HOST=0.0.0.0
ENV PORT=8080

# Uygulamayı başlat
CMD ["python", "main.py"]
