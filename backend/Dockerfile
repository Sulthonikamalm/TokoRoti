# ============================================================
# BREADHOUSE BACKEND - DOCKERFILE
# Optimized for Koyeb Deployment
# ============================================================

# Stage 1: Build
FROM golang:1.21-alpine AS builder

# Install git untuk fetching dependencies
RUN apk add --no-cache git ca-certificates

WORKDIR /app

# Copy dependency files terlebih dahulu (untuk caching layer)
COPY go.mod go.sum ./
RUN go mod download

# Copy seluruh source code
COPY . .

# Build binary yang dioptimasi untuk production
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o main ./cmd/main.go

# ============================================================
# Stage 2: Production Image (Minimal)
# ============================================================
FROM alpine:latest

# Install CA certificates untuk koneksi TLS ke Aiven
RUN apk --no-cache add ca-certificates tzdata

WORKDIR /app

# Copy binary dari stage builder
COPY --from=builder /app/main .

# Copy file SQL untuk Auto Migration
# Path disesuaikan dengan struktur folder di repo
COPY --from=builder /app/../jejak-pembelajaran-sql/database.sql ./migrations/database.sql

# Copy frontend files agar backend bisa serve static files (Opsional untuk Koyeb)
# Jika frontend di Vercel, ini bisa di-skip. Tapi kita sertakan untuk fleksibilitas.
COPY --from=builder /app/../frontend ./frontend

# Expose port sesuai variabel PORT (default 8080)
EXPOSE 8080

# Jalankan aplikasi
CMD ["./main"]
