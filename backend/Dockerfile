# ============================================================
# BREADHOUSE BACKEND - DOCKERFILE
# Optimized for Koyeb (Work Directory: backend)
# ============================================================

FROM golang:1.21-alpine

WORKDIR /app

# Salin go.mod dan go.sum dari direktori saat ini (backend)
COPY go.mod go.sum ./
RUN go mod download

# Salin semua kode di folder backend ke /app
COPY . .

# Build dari folder cmd/main.go
RUN go build -o main cmd/main.go

EXPOSE 8080

CMD ["./main"]
