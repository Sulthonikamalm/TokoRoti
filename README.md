<div align="center">

# 🍞 BreadHouse

### Sistem Manajemen Toko Roti Modern

[![Go](https://img.shields.io/badge/Go-1.21-00ADD8?style=flat-square&logo=go&logoColor=white)](https://golang.org/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?style=flat-square&logo=mysql&logoColor=white)](https://www.mysql.com/)
[![Tailwind](https://img.shields.io/badge/Tailwind-3.0-38B2AC?style=flat-square&logo=tailwind-css&logoColor=white)](https://tailwindcss.com/)
[![Deploy](https://img.shields.io/badge/Deploy-Koyeb-6C5CE7?style=flat-square)](https://koyeb.com/)

Proyek integrasi Tugas Besar Basis Data ke aplikasi web dinamis.
Berikut adalah link untuk demo

[🛒 Toko Pelanggan](https://toko-roti-nu.vercel.app/) · [📊 Admin Dashboard](https://popular-shay-telkom-university-982c46db.koyeb.app/admin/) · [📖 Dokumentasi](#arsitektur)

</div>

---

## Tentang Proyek

**BreadHouse** adalah hasil akhir dari perjalanan belajar Manajemen Basis Data di Semester 4. Proyek ini mengambil skema database toko roti yang awalnya hanya berupa file SQL statis, kemudian menghidupkannya menjadi aplikasi web yang nyata dan bisa diakses dari mana saja.

Lebih dari sekadar tugas kuliah, proyek ini menjadi wadah untuk memahami bagaimana data mengalir dari database ke layar pengguna, dan bagaimana sebuah sistem dapat di-deploy ke cloud agar bisa diakses secara global.

---

## Apa yang Dipelajari

Proyek ini mencakup beberapa domain pembelajaran yang saling terhubung:

### 1. Basis Data Relasional
Memahami perancangan skema database yang baik, relasi antar tabel (one-to-many, many-to-many), penggunaan foreign key, dan penulisan query SQL yang efisien. Skema yang digunakan mencakup entitas seperti Produk, Pelanggan, Transaksi, Cabang, hingga Bahan Baku.

### 2. Pemrograman Backend dengan Go
Mempelajari bahasa Go dari dasar, membangun REST API menggunakan package `net/http`, menerapkan pola repository untuk akses database, dan menangani berbagai skenario seperti koneksi ulang otomatis dan migrasi data.

### 3. Pengembangan Frontend
Membangun antarmuka pengguna dengan HTML, CSS (Tailwind), dan JavaScript murni. Menerapkan konsep responsive design, fetch API untuk komunikasi dengan backend, dan pengalaman pengguna yang intuitif.

### 4. DevOps & Deployment
Memahami konsep containerization dengan Docker, konfigurasi environment variables, penanganan CORS, dan deployment ke berbagai platform cloud (Aiven untuk database, Koyeb untuk backend, Vercel untuk frontend).

---

## Arsitektur

Sistem ini menggunakan arsitektur 3-tier yang memisahkan concern dengan jelas:

```
┌──────────────────────────────────────────────────────────────┐
│                      PRESENTATION                            │
│                                                              │
│   Frontend (HTML/CSS/JS)          Admin Dashboard            │
│   Tailwind CSS · Fetch API        Manajemen Produk & Stok    │
│                                                              │
│                    📍 Vercel / Koyeb Static                  │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼ REST API (HTTPS)
┌──────────────────────────────────────────────────────────────┐
│                         LOGIC                                │
│                                                              │
│   Backend (Go)                                               │
│   Clean Architecture · CORS · Auto-Reconnect                 │
│                                                              │
│                    📍 Koyeb (Docker Container)               │
└──────────────────────────────────────────────────────────────┘
                              │
                              ▼ MySQL (TLS)
┌──────────────────────────────────────────────────────────────┐
│                          DATA                                │
│                                                              │
│   MySQL Database                                             │
│   Managed Cloud · TLS Encryption · Auto Backup               │
│                                                              │
│                    📍 Aiven Cloud                            │
└──────────────────────────────────────────────────────────────┘
```

---

## Struktur Proyek

```
TokoRoti/
│
├── backend/
│   ├── cmd/
│   │   └── main.go                 # Entry point aplikasi
│   ├── internal/
│   │   ├── handler/                # HTTP handlers & middleware
│   │   ├── repository/             # Akses database
│   │   └── model/                  # Struktur data
│   ├── Dockerfile                  # Konfigurasi container
│   └── go.mod
│
├── frontend/
│   ├── public/                     # Halaman toko untuk pelanggan
│   │   ├── index.html
│   │   ├── css/
│   │   └── js/
│   └── admin/                      # Dashboard admin
│       ├── index.html
│       └── app.js
│
├── jejak-pembelajaran-sql/
│   └── database.sql                # Skema database (Artefak Tugas Besar)
│
└── README.md
```

---

## Fitur

| Modul | Deskripsi |
|-------|-----------|
| **Katalog Produk** | Menampilkan daftar roti dengan harga, stok, dan kategori |
| **Keranjang Belanja** | Sistem cart dengan perhitungan diskon member |
| **Checkout** | Proses pembayaran dengan gesture swipe |
| **Registrasi Member** | Pendaftaran pelanggan baru dengan level keanggotaan |
| **Dashboard Admin** | Monitoring produk, transaksi, dan log aktivitas |
| **Manajemen Stok** | Tambah produk baru dan update stok |
| **Auto Migration** | Database terisi otomatis saat pertama kali deploy |

---

## API Endpoints

| Method | Endpoint | Fungsi |
|--------|----------|--------|
| `GET` | `/api/produk` | Mengambil daftar produk |
| `GET` | `/api/transaksi` | Riwayat transaksi |
| `GET` | `/api/pencatatan` | Log aktivitas sistem |
| `POST` | `/api/pelanggan/cek` | Verifikasi member |
| `POST` | `/api/pelanggan/baru` | Registrasi member baru |
| `POST` | `/api/produk/baru` | Tambah produk |
| `PUT` | `/api/produk/stok` | Update stok |
| `POST` | `/api/transaksi/checkout` | Proses checkout |

---

## Deployment

### Database → Aiven
1. Buat MySQL service di [Aiven](https://aiven.io)
2. Import `jejak-pembelajaran-sql/database.sql`
3. Simpan Service URI untuk backend

### Backend → Koyeb
1. Connect repository GitHub
2. Pilih Docker deployment
3. Set Dockerfile path: `backend/Dockerfile`
4. Tambahkan environment variables:
   - `DATABASE_URL` = Service URI dari Aiven
   - `PORT` = `8080`

### Frontend → Vercel
1. Import repository di [Vercel](https://vercel.com)
2. Set root directory ke `frontend/public`
3. Deploy

---

## Menjalankan Lokal

```bash
# Clone repository
git clone https://github.com/Sulthonikamalm/TokoRoti.git
cd TokoRoti

# Jalankan backend
cd backend
go mod tidy
go run cmd/main.go

# Akses aplikasi
# Toko:  http://localhost:8080/
# Admin: http://localhost:8080/admin/
```

---

## Teknologi

<div align="center">

| Layer | Teknologi |
|:-----:|:---------:|
| Frontend | HTML · CSS · JavaScript · Tailwind CSS |
| Backend | Go · net/http · MySQL Driver |
| Database | MySQL 8.0 |
| Infrastructure | Docker · Aiven · Koyeb · Vercel |

</div>

---

## Catatan Akademik

Skema database yang digunakan dalam proyek ini (`jejak-pembelajaran-sql/database.sql`) merupakan artefak dari Tugas Besar Mata Kuliah **Manajemen Basis Data** Semester 4. File tersebut sengaja dipertahankan dalam bentuk aslinya sebagai dokumentasi proses pembelajaran.

Proyek ini mendemonstrasikan bagaimana sebuah desain database akademis dapat diimplementasikan menjadi sistem yang berfungsi penuh dan dapat diakses secara publik.

---

## Ucapan Terima Kasih

<div align="center">

Terima kasih yang sebesar-besarnya kepada

### **Yohanes Setiawan, S.Si., M.Kom**

atas bimbingan dan ilmu yang diberikan selama mengampu mata kuliah Manajemen Basis Data.

[![Google Scholar](https://img.shields.io/badge/Google_Scholar-4285F4?style=for-the-badge&logo=google-scholar&logoColor=white)](https://scholar.google.com/citations?user=NkJgzwkAAAAJ&hl=id)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/yohset95)

</div>

---

<div align="center">

**Telkom University · Semester 4 & 6**

Dari SQL statis ke aplikasi web dinamis yang berjalan di cloud.

---

*Dibuat dengan ☕ dan semangat belajar*

</div>
