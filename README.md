# 🍞 BreadHouse - Bakery Management System

<div align="center">

![Go Version](https://img.shields.io/badge/Go-1.21+-00ADD8?style=for-the-badge&logo=go&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0+-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Tailwind CSS](https://img.shields.io/badge/Tailwind-3.0+-38B2AC?style=for-the-badge&logo=tailwind-css&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**Sistem Manajemen Toko Roti Modern dengan Arsitektur 3-Tier**

[Demo Frontend](#) • [API Documentation](#api-endpoints) • [Getting Started](#-quick-start)

</div>

---

## 📋 Deskripsi Proyek

**BreadHouse** adalah sistem manajemen toko roti yang mengintegrasikan skema database dari Tugas Besar Semester 4 ke dalam aplikasi web modern. Proyek ini mendemonstrasikan migrasi dari SQL statis ke sistem dinamis dengan arsitektur 3-tier.

### ✨ Fitur Utama

- 📦 **Manajemen Produk** - Katalog lengkap produk roti dengan kategori dan stok
- 🧾 **Riwayat Transaksi** - Pencatatan penjualan dari semua cabang
- 📋 **Log Aktivitas** - Audit trail untuk pembelian, penjualan, dan pengiriman
- 🔄 **Auto-Reconnect** - Handle idle timeout untuk database cloud
- 🌐 **CORS Ready** - Siap untuk deployment cross-origin

---

## 🏗️ Arsitektur Sistem (Cloud Native)

```
┌─────────────────────────────────────────────────────────────┐
│                    🖥️ PRESENTATION TIER                     │
│  ┌─────────────────────────────────────────────────────┐    │
│  │            Frontend (Vanilla HTML/CSS/JS)           │    │
│  │         Tailwind CSS • Fetch API • Responsive       │    │
│  │          📍 Deploy: Vercel (toko-roti-nu.vercel.app)│    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ REST API (JSON over HTTPS)
┌─────────────────────────────────────────────────────────────┐
│                      ⚙️ LOGIC TIER                          │
│  ┌─────────────────────────────────────────────────────┐    │
│  │              Backend (Go + Docker)                  │    │
│  │      Clean Architecture • CORS • Auto-Reconnect     │    │
│  │            📍 Deploy: Koyeb (tokoroti-api.koyeb.app)│    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ MySQL (TLS/SSL Required)
┌─────────────────────────────────────────────────────────────┐
│                       🗄️ DATA TIER                          │
│  ┌─────────────────────────────────────────────────────┐    │
│  │             Database (MySQL on Aiven)               │    │
│  │         Managed Cloud • TLS • Auto Backup           │    │
│  │     📍 Skema: jejak-pembelajaran-sql/database.sql   │    │
│  └─────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────┘
```

---

## 📁 Struktur Proyek

```
TokoRoti/
├── 📂 backend/
│   ├── 📂 cmd/
│   │   └── main.go              # Entry point aplikasi
│   ├── 📂 internal/
│   │   ├── 📂 handler/
│   │   │   ├── handler.go       # HTTP handlers
│   │   │   └── cors.go          # CORS middleware
│   │   ├── 📂 repository/
│   │   │   ├── database.go      # DB connection + auto-reconnect
│   │   │   ├── produk_repository.go
│   │   │   ├── transaksi_repository.go
│   │   │   └── pencatatan_repository.go
│   │   └── 📂 model/
│   │       ├── produk.go
│   │       ├── transaksi.go
│   │       └── pencatatan.go
│   ├── go.mod
│   └── .env.example
│
├── 📂 frontend/
│   ├── index.html               # Dashboard utama
│   ├── style.css                # Custom styles
│   └── app.js                   # Application logic
│
├── 📂 jejak-pembelajaran-sql/
│   └── database.sql             # Skema SQL lengkap (Artefak Tugas Besar)
│
└── README.md
```

---

## 🚀 Quick Start

### Prerequisites

- Go 1.21+
- MySQL 8.0+ (atau Aiven account)
- Node.js (opsional, untuk dev server frontend)

### 1. Clone Repository

```bash
git clone https://github.com/username/breadhouse.git
cd breadhouse
```

### 2. Setup Database

Import skema ke database MySQL (Otomatis jika backend dijalankan, atau manual):

```bash
mysql -u username -p database_name < jejak-pembelajaran-sql/database.sql
```

### 3. Konfigurasi Backend

```bash
cd backend

# Copy environment file
cp .env.example .env

# Edit .env dengan kredensial database Anda
# DATABASE_URL=mysql://user:password@host:port/database?ssl-mode=REQUIRED
```

### 4. Jalankan Backend

```bash
cd backend
go mod tidy
go run cmd/main.go
```

Server akan berjalan di `http://localhost:8080`

### 5. Jalankan Frontend

Buka `frontend/index.html` di browser, atau gunakan live server:

```bash
cd frontend
npx serve .
```

---

## 📡 API Endpoints

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| `GET` | `/api/produk` | Daftar semua produk roti |
| `GET` | `/api/transaksi` | Riwayat transaksi penjualan |
| `GET` | `/api/pencatatan` | Log aktivitas sistem |
| `GET` | `/api/pencatatan?tipe=PENJUALAN` | Filter log by tipe |
| `GET` | `/health` | Health check endpoint |

### Response Format

```json
{
  "success": true,
  "message": "Data produk berhasil diambil",
  "data": [...],
  "count": 12
}
```

---

## 🌐 Deployment (Cloud Stack)

### 1️⃣ Database → Aiven MySQL

1. Buat MySQL service di [Aiven](https://aiven.io) (Free Tier available)
2. Dapatkan **Service URI** dari dashboard
3. Import skema dari `jejak-pembelajaran-sql/database.sql`
4. Simpan URI untuk langkah berikutnya

### 2️⃣ Backend → Koyeb (Docker)

1. Push repository ke GitHub
2. Buat App baru di [Koyeb](https://koyeb.com)
3. Pilih **Docker** deployment method
4. Set build context ke root repository (karena Dockerfile di root)
5. Set environment variables:
   - `DATABASE_URL` = Service URI dari Aiven
   - `PORT` = `8080`
6. Deploy! Backend akan otomatis migrasi database saat startup.

### 3️⃣ Frontend → Vercel

1. Import project di [Vercel](https://vercel.com)
2. Set root directory ke `frontend/public` (untuk toko) atau `frontend/admin` (untuk dashboard)
3. Update `PRODUCTION_API` di `js/app.js` dengan URL Koyeb yang didapat
4. Deploy & enjoy! 🎉

---

## 🔧 Environment Variables

| Variable | Deskripsi | Contoh |
|----------|-----------|--------|
| `DATABASE_URL` | MySQL connection string | `mysql://user:pass@host:port/db?ssl-mode=REQUIRED` |
| `PORT` | Server port | `8080` |
| `ALLOWED_ORIGINS` | CORS whitelist | `https://app.vercel.app` |

---

## 🛡️ Fitur Keamanan

- **TLS Connection** - Enkripsi data ke database Aiven
- **CORS Middleware** - Whitelist origin yang diizinkan
- **Auto-Reconnect** - Handle connection drops gracefully
- **Input Escaping** - Prevent XSS di frontend

---

## 📚 Dokumentasi Tambahan

- [Learning Journal](docs/learning_process.md) - Proses pembelajaran dan migrasi
- [Database Schema](database-archive/database.sql) - Skema SQL lengkap

---

## 🤝 Contributing

1. Fork repository
2. Buat feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push ke branch (`git push origin feature/amazing`)
5. Buat Pull Request

---

## 📄 License

Proyek ini dilisensikan di bawah [MIT License](LICENSE).

---

<div align="center">

**Built with ❤️ for learning purposes**

Semester 6 • Database Migration Project

</div>
