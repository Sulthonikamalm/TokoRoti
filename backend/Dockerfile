# ============================================================
# BREADHOUSE FULLSTACK - DOCKERFILE
# Build Context: Root Repository (Koyeb: Dockerfile Path = backend/Dockerfile)
# ============================================================

FROM golang:1.21-alpine

WORKDIR /app

# COPY seluruh isi repository (Backend, Frontend, SQL) ke dalam container
# Ini penting agar folder ../frontend bisa ditemukan oleh main.go
COPY . .

# Masuk ke folder backend untuk build aplikasi
WORKDIR /app/backend
RUN go mod download
RUN go build -o main cmd/main.go

# Buka Port 8080
EXPOSE 8080

# Jalankan aplikasi dari folder backend
CMD ["./main"]
