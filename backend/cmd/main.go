package main

import (
	"crypto/tls"
	"database/sql"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strings"

	"tokoroti/internal/handler"
	"tokoroti/internal/repository"

	"github.com/go-sql-driver/mysql"
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
	// 2. Registrasi TLS "Skip Verify" (Anti Gagal SSL)
	// ==========================================
	// Kita buat konfigurasi TLS kustom bernama "custom-skip"
	// yang mengizinkan sertifikat apa pun (InsecureSkipVerify: true)
	errTLS := mysql.RegisterTLSConfig("custom-skip", &tls.Config{
		InsecureSkipVerify: true,
	})
	if errTLS != nil {
		log.Printf("Peringatan TLS: %v", errTLS)
	}

	// ==========================================
	// 3. Konfigurasi Database (Smart Parser)
	// ==========================================
	var dsn string
	urlEnv := os.Getenv("DATABASE_URL")

	if urlEnv != "" {
		log.Println("Info: Menggunakan konfigurasi database dari Environment Variable.")

		// LOGIKA PINTAR: Cek apakah formatnya mysql:// (dari Aiven)
		// Jika ya, kita bongkar dan rakit ulang jadi format Go Driver
		if strings.HasPrefix(urlEnv, "mysql://") {
			parsedURL, err := url.Parse(urlEnv)
			if err == nil {
				password, _ := parsedURL.User.Password()
				// Format Go: user:pass@tcp(host:port)/dbname?param
				dsn = fmt.Sprintf("%s:%s@tcp(%s)%s",
					parsedURL.User.Username(),
					password,
					parsedURL.Host,
					parsedURL.Path,
				)
				log.Println("Info: URL 'mysql://' berhasil dikonversi otomatis.")
			} else {
				// Jika gagal parse, pakai apa adanya (fallback)
				dsn = urlEnv
			}
		} else {
			// Jika format sudah benar (bukan mysql://), pakai langsung
			dsn = urlEnv
		}

		// Paksa menggunakan TLS config "custom-skip" yang kita buat di atas
		if strings.Contains(dsn, "?") {
			dsn += "&tls=custom-skip&multiStatements=true&parseTime=true"
		} else {
			dsn += "?tls=custom-skip&multiStatements=true&parseTime=true"
		}

	} else {
		// Fallback ke Lokal XAMPP
		log.Println("Info: Menggunakan konfigurasi database Lokal.")
		dsn = "root:@tcp(127.0.0.1:3306)/tokoroti?parseTime=true&multiStatements=true"
	}

	// ==========================================
	// 4. Inisialisasi Koneksi & Migrasi
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

	// Routing
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

	// --- Frontend Serving ---
	fsPublic := http.FileServer(http.Dir("../frontend/public"))
	mux.Handle("/", http.StripPrefix("/", fsPublic))
	fsAdmin := http.FileServer(http.Dir("../frontend/admin"))
	mux.Handle("/admin/", http.StripPrefix("/admin/", fsAdmin))

	handlerAkhir := handler.MiddlewareCORS(mux)

	log.Println("===============================================================")
	log.Printf("✅ SISTEM BREADHOUSE SIAP (BYPASS SSL MODE)")
	log.Printf("🛒 Toko (Public) : http://localhost:%s/", portAplikasi)
	log.Printf("📊 Admin Panel   : http://localhost:%s/admin/", portAplikasi)
	log.Println("===============================================================")

	if err := http.ListenAndServe(":"+portAplikasi, handlerAkhir); err != nil {
		log.Fatalf("Server berhenti: %v", err)
	}
}

// Helper functions
func cekTabel(db *sql.DB) {
	_, err := db.Query("SELECT 1 FROM produk_roti LIMIT 1")
	if err != nil {
		log.Println("⚠️ Tabel belum ditemukan. Memulai MIGRASI DATA...")
		jalankanMigrasi(db)
	} else {
		log.Println("info: Tabel database sudah lengkap. Siap digunakan.")
	}
}

func jalankanMigrasi(db *sql.DB) {
	pathCandidates := []string{
		"../jejak-pembelajaran-sql/database.sql", // Prioritas path deployment baru
		"migrations/database.sql",
		"jejak-pembelajaran-sql/database.sql",
		filepath.Join("..", "jejak-pembelajaran-sql", "database.sql"),
	}

	var kontenSQL []byte
	var err error

	for _, p := range pathCandidates {
		kontenSQL, err = ioutil.ReadFile(p)
		if err == nil {
			log.Printf("📂 File migrasi ditemukan: %s", p)
			break
		}
	}

	if err != nil {
		log.Printf("❌ Gagal membaca file database.sql. Pastikan folder jejak-pembelajaran-sql ikut ter-upload.")
		return
	}

	queries := string(kontenSQL)
	_, err = db.Exec(queries)
	if err != nil {
		log.Printf("⚠️ Gagal eksekusi langsung, mencoba split statement...")
		manualSplitExec(db, queries)
	} else {
		log.Println("✅ Sukses! Database telah diisi (Seeding).")
	}
}

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
			if !strings.Contains(err.Error(), "Unknown table") {
				gagal++
			}
		} else {
			sukses++
		}
	}
	log.Printf("Info Migrasi: %d perintah berhasil, %d gagal/dilewati.", sukses, gagal)
}
