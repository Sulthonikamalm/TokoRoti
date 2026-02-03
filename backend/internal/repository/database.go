package repository

import (
	"database/sql"
	"log"
	"time"

	_ "github.com/go-sql-driver/mysql"
)

// KoneksiDatabase adalah pembungkus (wrapper) untuk objek sql.DB.
// Wrapper ini menambahkan kapabilitas pemulihan koneksi otomatis.
type KoneksiDatabase struct {
	*sql.DB
	dsn string // Data Source Name (Connection String)
}

// InisialisasiDatabase membuka koneksi ke database dan mengatur pooling.
// Fungsi ini menangani koneksi awal dan memulai pemantau kesehatan koneksi.
func InisialisasiDatabase(urlDatabase string) (*KoneksiDatabase, error) {
	// Membuka koneksi database dengan driver MySQL
	db, err := sql.Open("mysql", urlDatabase)
	if err != nil {
		return nil, err
	}

	// Konfigurasi Connection Pooling untuk efisiensi dan stabilitas
	// Angka ini disesuaikan untuk kebutuhan aplikasi menengah dan batasan hosting gratis
	db.SetMaxOpenConns(10)                 // Maksimal koneksi terbuka
	db.SetMaxIdleConns(5)                  // Maksimal koneksi menganggur
	db.SetConnMaxLifetime(3 * time.Minute) // Durasi maksimal koneksi hidup
	db.SetConnMaxIdleTime(1 * time.Minute) // Durasi maksimal koneksi boleh diam

	// Verifikasi koneksi awal
	if err := db.Ping(); err != nil {
		return nil, err
	}

	log.Println("Info: Koneksi database berhasil dibangun.")

	basisData := &KoneksiDatabase{
		DB:  db,
		dsn: urlDatabase,
	}

	// Menjalankan pengecekan kesehatan koneksi di latar belakang (goroutine)
	go basisData.pemantauKesehatan()

	return basisData, nil
}

// Tutup menutup koneksi database dengan aman.
func (d *KoneksiDatabase) Tutup() error {
	return d.DB.Close()
}

// pemantauKesehatan secara berkala memeriksa apakah koneksi masih hidup.
// Jika koneksi putus (misal karena timeout dari Aiven/MySQL), akan mencoba menyambung kembali.
func (d *KoneksiDatabase) pemantauKesehatan() {
	penghitungWaktu := time.NewTicker(30 * time.Second)
	defer penghitungWaktu.Stop()

	for range penghitungWaktu.C {
		if err := d.Ping(); err != nil {
			log.Printf("Peringatan: Koneksi database terputus (%v). Mencoba menyambung kembali...", err)
			d.sambungUlang()
		}
	}
}

// sambungUlang melakukan upaya koneksi ulang dengan strategi exponsial backoff.
func (d *KoneksiDatabase) sambungUlang() {
	maksimalPercobaan := 5
	jedaWaktu := 1 * time.Second

	for i := 0; i < maksimalPercobaan; i++ {
		dbBaru, err := sql.Open("mysql", d.dsn)
		if err != nil {
			log.Printf("Gagal membuka koneksi baru: %v", err)
			time.Sleep(jedaWaktu)
			jedaWaktu *= 2
			continue
		}

		if err := dbBaru.Ping(); err != nil {
			log.Printf("Gagal ping koneksi baru: %v", err)
			dbBaru.Close()
			time.Sleep(jedaWaktu)
			jedaWaktu *= 2
			continue
		}

		// Terapkan pengaturan pooling yang sama
		dbBaru.SetMaxOpenConns(10)
		dbBaru.SetMaxIdleConns(5)
		dbBaru.SetConnMaxLifetime(3 * time.Minute)
		dbBaru.SetConnMaxIdleTime(1 * time.Minute)

		// Ganti koneksi lama dengan yang baru
		d.DB.Close()
		d.DB = dbBaru

		log.Println("Info: Koneksi database berhasil dipulihkan.")
		return
	}

	log.Printf("Gagal menyambung ulang setelah %d percobaan.", maksimalPercobaan)
}

// EksekusiQueryAman menjalankan query SELECT dengan mekanisme retry otomatis jika koneksi gagal.
func (d *KoneksiDatabase) EksekusiQueryAman(query string, argumen ...interface{}) (*sql.Rows, error) {
	barisData, err := d.Query(query, argumen...)
	if err != nil {
		// Logika sederhana: jika error, coba sekali lagi setelah reconnect
		log.Println("Peringatan: Gagal eksekusi query, mencoba pemulihan koneksi...")
		d.sambungUlang()
		return d.Query(query, argumen...)
	}
	return barisData, nil
}
