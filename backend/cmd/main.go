package main

import (
	"database/sql"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"tokoroti/internal/handler"
	"tokoroti/internal/repository"

	_ "github.com/go-sql-driver/mysql"
)

func main() {
	// ==========================================
	// 1. Konfigurasi Lingkungan
	// ==========================================
	portAplikasi := os.Getenv("PORT")
	if portAplikasi == "" {
		portAplikasi = "8080"
	}

	// ==========================================
	// 2. Konfigurasi Database (Cloud Ready)
	// ==========================================
	var dsn string

	// Cek Environment Variable (Priority 1: Production/Cloud)
	if urlEnv := os.Getenv("DATABASE_URL"); urlEnv != "" {
		log.Println("Info: Menggunakan konfigurasi database dari Environment Variable (Cloud Mode).")

		// Pastikan DSN memiliki parameter yang diperlukan untuk Aiven
		// Aiven menggunakan format: mysql://user:pass@host:port/dbname
		// Go MySQL Driver menggunakan format: user:pass@tcp(host:port)/dbname
		dsn = urlEnv

		// Tambahkan parameter TLS dan multiStatements jika belum ada
		if !strings.Contains(dsn, "tls=") {
			if strings.Contains(dsn, "?") {
				dsn += "&tls=true"
			} else {
				dsn += "?tls=true"
			}
		}
		if !strings.Contains(dsn, "multiStatements=") {
			dsn += "&multiStatements=true"
		}
		if !strings.Contains(dsn, "parseTime=") {
			dsn += "&parseTime=true"
		}

		log.Printf("Info: DSN Cloud diproses dengan TLS enabled.")
	} else {
		// Fallback ke Lokal XAMPP (Priority 2: Local Development)
		dbUser := "root"
		dbPass := ""
		dbHost := "127.0.0.1:3306"
		dbName := "tokoroti"

		log.Println("Info: Menggunakan konfigurasi database Lokal (XAMPP Mode).")

		// Cek & Buat Database Lokal jika belum ada
		dsnCek := fmt.Sprintf("%s:%s@tcp(%s)/", dbUser, dbPass, dbHost)
		dbCek, err := sql.Open("mysql", dsnCek)
		if err == nil {
			_, _ = dbCek.Exec("CREATE DATABASE IF NOT EXISTS " + dbName)
			dbCek.Close()
		}

		// multiStatements=true penting untuk seed data
		dsn = fmt.Sprintf("%s:%s@tcp(%s)/%s?parseTime=true&multiStatements=true", dbUser, dbPass, dbHost, dbName)
	}

	// ==========================================
	// 3. Inisialisasi Koneksi & Migrasi
	// ==========================================
	db, err := repository.InisialisasiDatabase(dsn)
	if err != nil {
		log.Fatalf("Fatal: Gagal inisialisasi koneksi aplikasi: %v", err)
	}
	defer db.Tutup()

	// --> LOGIKA MIGRASI OTOMATIS <--
	cekTabel(db.DB)

	// Inisialisasi Layer
	repoProduk := repository.BuatRepositoryProduk(db)
	repoTransaksi := repository.BuatRepositoryTransaksi(db)
	repoPencatatan := repository.BuatRepositoryPencatatan(db)
	repoPelanggan := repository.BuatRepositoryPelanggan(db)
	h := handler.BuatHandler(repoProduk, repoTransaksi, repoPencatatan, repoPelanggan)

	// Routing & Server
	mux := http.NewServeMux()

	// --- API Endpoints ---
	mux.HandleFunc("/api/produk", h.AmbilDaftarProduk)
	mux.HandleFunc("/api/transaksi", h.AmbilRiwayatTransaksi)
	mux.HandleFunc("/api/pencatatan", h.AmbilLogAktivitas)
	mux.HandleFunc("/api/pelanggan/cek", h.CekMemberHandler)
	mux.HandleFunc("/api/pelanggan/baru", h.RegistrasiPelangganHandler)
	mux.HandleFunc("/api/produk/baru", h.TambahProdukHandler)
	mux.HandleFunc("/api/produk/stok", h.UpdateStokHandler)
	mux.HandleFunc("/api/transaksi/baru", h.BuatTransaksiHandler)
	mux.HandleFunc("/api/transaksi/checkout", h.CheckoutKeranjangHandler)

	// --- Utility Endpoints ---
	mux.HandleFunc("/kesehatan", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Write([]byte(`{"status":"sehat", "pesan":"Sistem berjalan normal"}`))
	})

	// --- STATIC FILE SERVING (Frontend Integration) ---
	// Solusi Elegan: Backend melayani Frontend agar satu domain (No CORS Issues)

	// 1. Serve Folder Public (Toko) di Root URL
	fsPublic := http.FileServer(http.Dir("../frontend/public"))
	mux.Handle("/", http.StripPrefix("/", fsPublic))

	// 2. Serve Folder Admin di URL /admin/
	// Perlu trik sedikit karena struktur folder frontend terpisah
	fsAdmin := http.FileServer(http.Dir("../frontend/admin"))
	mux.Handle("/admin/", http.StripPrefix("/admin/", fsAdmin))

	// CORS sudah tidak terlalu krusial karena satu domain, tapi tetap pasang untuk safety
	handlerAkhir := handler.MiddlewareCORS(mux)

	log.Println("===============================================================")
	log.Printf("✅ SISTEM BREADHOUSE SIAP (MODE FULLSTACK)")
	log.Printf("🛒 Toko (Public) : http://localhost:%s/", portAplikasi)
	log.Printf("📊 Admin Panel   : http://localhost:%s/admin/", portAplikasi)
	log.Printf("📡 API Endpoint  : http://localhost:%s/api/...", portAplikasi)
	log.Printf("📂 Database      : 'tokoroti' (Terhubung)")
	log.Println("===============================================================")

	if err := http.ListenAndServe(":"+portAplikasi, handlerAkhir); err != nil {
		log.Fatalf("Server berhenti: %v", err)
	}
}

// cekTabel mengecek apakah tabel 'produk_roti' ada. Jika tidak, jalankan migrasi SQL.
func cekTabel(db *sql.DB) {
	_, err := db.Query("SELECT 1 FROM produk_roti LIMIT 1")
	if err != nil {
		log.Println("⚠️  Tabel belum ditemukan. Memulai MIGRASI DATA OTOMATIS...")
		jalankanMigrasi(db)
	} else {
		log.Println("info: Tabel database sudah lengkap. Siap digunakan.")
	}
}

// jalankanMigrasi membaca file database.sql dan mengeksekusinya
func jalankanMigrasi(db *sql.DB) {
	// Daftar path yang dicoba (urutan prioritas)
	pathCandidates := []string{
		"migrations/database.sql",                                     // Docker/Koyeb
		filepath.Join("..", "jejak-pembelajaran-sql", "database.sql"), // Local dari backend/
		filepath.Join("jejak-pembelajaran-sql", "database.sql"),       // Local dari root
	}

	var kontenSQL []byte
	var err error
	var pathSQL string

	for _, p := range pathCandidates {
		kontenSQL, err = ioutil.ReadFile(p)
		if err == nil {
			pathSQL = p
			log.Printf("📂 File migrasi ditemukan: %s", pathSQL)
			break
		}
	}

	if err != nil {
		log.Printf("❌ Gagal membaca file SQL migrasi dari semua path. Mohon import database.sql secara manual.")
		return
	}

	queries := string(kontenSQL)

	// Eksekusi SQL (membutuhkan multiStatements=true di DSN)
	_, err = db.Exec(queries)
	if err != nil {
		// Jika error karena multiple statements, kita coba split manual sederhana
		log.Printf("⚠️ Gagal eksekusi langsung (%v). Mencoba split statement...", err)
		manualSplitExec(db, queries)
	} else {
		log.Println("✅ Sukses! Database telah diisi dengan data awal (Seeding).")
	}
}

// manualSplitExec memecah query berdasarkan ';' untuk kompatibilitas driver
func manualSplitExec(db *sql.DB, queries string) {
	statements := strings.Split(queries, ";")
	sukses := 0
	gagal := 0

	for _, stmt := range statements {
		stmt = strings.TrimSpace(stmt)
		if stmt == "" {
			continue
		}
		_, err := db.Exec(stmt)
		if err != nil {
			// Abaikan error drop table if exists
			if !strings.Contains(err.Error(), "Unknown table") {
				gagal++
			}
		} else {
			sukses++
		}
	}
	log.Printf("Info Migrasi: %d perintah berhasil, %d gagal/dilewati.", sukses, gagal)
}
