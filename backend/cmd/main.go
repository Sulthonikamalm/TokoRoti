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

	dbUser := "root"
	dbPass := ""
	dbHost := "127.0.0.1:3306"
	dbName := "tokoroti"

	if urlEnv := os.Getenv("DATABASE_URL"); urlEnv != "" {
		// Logika parsing env jika perlu, tapi kita fokus lokal XAMPP dulu
	}

	// ==========================================
	// 2. Cek & Buat Database (Jika Belum Ada)
	// ==========================================
	dsnDasar := fmt.Sprintf("%s:%s@tcp(%s)/", dbUser, dbPass, dbHost)
	dbCek, err := sql.Open("mysql", dsnDasar)
	if err != nil {
		log.Fatal("Gagal membuka koneksi cek database:", err)
	}

	// Coba buat database
	_, err = dbCek.Exec("CREATE DATABASE IF NOT EXISTS " + dbName)
	if err != nil {
		log.Printf("Peringatan saat membuat DB: %v (Pastikan MySQL XAMPP sudah Start)", err)
	}
	dbCek.Close()

	// ==========================================
	// 3. Koneksi Aplikasi Utama & AUTO MIGRATION
	// ==========================================
	// TAMBAHAN: multiStatements=true agar bisa jalanin file SQL panjang sekaligus
	urlDatabaseLengkap := fmt.Sprintf("%s:%s@tcp(%s)/%s?parseTime=true&multiStatements=true", dbUser, dbPass, dbHost, dbName)

	db, err := repository.InisialisasiDatabase(urlDatabaseLengkap)
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
	h := handler.BuatHandler(repoProduk, repoTransaksi, repoPencatatan)

	// Routing & Server
	mux := http.NewServeMux()

	// API Endpoints
	mux.HandleFunc("/api/produk", h.AmbilDaftarProduk)
	mux.HandleFunc("/api/transaksi", h.AmbilRiwayatTransaksi)
	mux.HandleFunc("/api/pencatatan", h.AmbilLogAktivitas)

	// Utility Endpoints
	mux.HandleFunc("/kesehatan", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.Write([]byte(`{"status":"sehat", "pesan":"Sistem berjalan normal"}`))
	})

	// Root Handler (Agar tidak 404 saat dibuka di browser)
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/" {
			http.NotFound(w, r)
			return
		}
		w.Header().Set("Content-Type", "text/html")
		htmlSapaan := `
		<!DOCTYPE html>
		<html>
		<head>
			<title>Backend BreadHouse</title>
			<style>
				body { font-family: sans-serif; text-align: center; padding: 50px; color: #333; }
				h1 { color: #d97706; }
				.card { background: #fff7ed; padding: 20px; border-radius: 10px; display: inline-block; border: 1px solid #fed7aa; }
			</style>
		</head>
		<body>
			<div class="card">
				<h1>🍞 BreadHouse API Berjalan!</h1>
				<p>Backend aktif dan terhubung ke database <b>tokoroti</b>.</p>
				<p>Silakan buka Frontend (<i>index.html</i>) untuk mengakses dashboard.</p>
			</div>
		</body>
		</html>
		`
		w.Write([]byte(htmlSapaan))
	})

	handlerAkhir := handler.MiddlewareCORS(mux)

	log.Println("===============================================================")
	log.Printf("✅ SISTEM BREADHOUSE SIAP!")
	log.Printf("📡 Backend berjalan di: http://localhost:%s", portAplikasi)
	log.Printf("📂 Database           : 'tokoroti' (Auto-Migration Active)")
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
	// Mencari file database.sql di folder ../jejak-pembelajaran-sql/
	pathSQL := filepath.Join("..", "jejak-pembelajaran-sql", "database.sql")

	// Baca file
	kontenSQL, err := ioutil.ReadFile(pathSQL)
	if err != nil {
		// Coba path alternatif jika dijalankan dari root
		pathSQL = filepath.Join("jejak-pembelajaran-sql", "database.sql")
		kontenSQL, err = ioutil.ReadFile(pathSQL)
		if err != nil {
			log.Printf("❌ Gagal membaca file SQL migrasi: %v. Mohon import database.sql secara manual.", err)
			return
		}
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
