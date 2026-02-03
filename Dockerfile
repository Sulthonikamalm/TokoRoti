# ============================================================
# BREADHOUSE FULLSTACK - DOCKERFILE
# Build Context: Repository Root (TokoRoti/)
# Target: Koyeb Deployment
# ============================================================

# Stage 1: Build Backend
FROM golang:1.21-alpine AS builder

RUN apk add --no-cache git ca-certificates

WORKDIR /build

# Copy Go module files dari subfolder backend
COPY backend/go.mod backend/go.sum ./backend/
WORKDIR /build/backend
RUN go mod download

# Copy seluruh source backend
WORKDIR /build
COPY backend/ ./backend/

# Build binary
WORKDIR /build/backend
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /app/main ./cmd/main.go

# ============================================================
# Stage 2: Production Image
# ============================================================
FROM alpine:latest

# TLS Certificates (Wajib untuk Aiven MySQL)
RUN apk --no-cache add ca-certificates tzdata

WORKDIR /app

# Copy binary
COPY --from=builder /app/main .

# Copy SQL Migration File (Artefak Akademik Semester 4)
COPY jejak-pembelajaran-sql/database.sql ./migrations/database.sql

# Copy Frontend Files (Untuk serve static jika diperlukan)
COPY frontend/ ./frontend/

# Port default Koyeb
EXPOSE 8080

# Environment Variable akan diset di Koyeb Dashboard
# DATABASE_URL, PORT

CMD ["./main"]
