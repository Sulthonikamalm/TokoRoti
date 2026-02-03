package repository

import (
	"database/sql"
	"errors"
	"fmt"
	"time"
	"tokoroti/internal/model"
)

type RepositoryTransaksi struct {
	db *KoneksiDatabase
}

func BuatRepositoryTransaksi(db *KoneksiDatabase) *RepositoryTransaksi {
	return &RepositoryTransaksi{db: db}
}

// AmbilSemua mengambil riwayat transaksi (Untuk Admin)
func (r *RepositoryTransaksi) AmbilSemua() ([]model.TransaksiPenjualan, error) {
	kueri := `
		SELECT 
			tp.ID_Transaksi_Penjualan, 
			tp.Tanggal_Transaksi, 
			tp.Total_Harga, 
			COALESCE(p.Nama, 'Guest') AS Nama_Pelanggan,
			c.Nama_Cabang
		FROM Transaksi_Penjualan tp
		LEFT JOIN Pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
		JOIN Cabang c ON tp.ID_Cabang = c.ID_Cabang
		ORDER BY tp.Tanggal_Transaksi DESC
		LIMIT 50
	`
	rows, err := r.db.Query(kueri)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var hasil []model.TransaksiPenjualan
	for rows.Next() {
		var t model.TransaksiPenjualan
		var namaPelanggan sql.NullString // Handle null

		err := rows.Scan(&t.IDTransaksiPenjualan, &t.TanggalTransaksi, &t.TotalHarga, &namaPelanggan, &t.NamaCabang)
		if err != nil {
			return nil, err
		}

		if namaPelanggan.Valid {
			tmp := namaPelanggan.String
			t.NamaPelanggan = &tmp
		} else {
			tmp := "Guest"
			t.NamaPelanggan = &tmp
		}

		hasil = append(hasil, t)
	}
	return hasil, nil
}

// TambahTransaksi (DeepLogic: Demand Driven Supply Chain)
// Fungsi ini menangani pembelian user, mengurangi stok, dan mencatat log.
func (r *RepositoryTransaksi) TambahTransaksi(idProduk int, idPelanggan int, jumlah int, totalHarga float64) error {
	// 1. Mulai Transaksi Database (Atomic)
	tx, err := r.db.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback() // Rollback jika ada error di tengah jalan

	// 2. Cek Stok & Kunci Baris (SELECT FOR UPDATE untuk mencegah race condition)
	var stokSaatIni int
	err = tx.QueryRow("SELECT Stok_Roti FROM Produk_Roti WHERE ID_Produk = ? FOR UPDATE", idProduk).Scan(&stokSaatIni)
	if err != nil {
		return errors.New("produk tidak ditemukan")
	}

	if stokSaatIni < jumlah {
		// Logika Supply Chain Otomatis: Trigger Produksi (Simulasi Error dulu)
		return fmt.Errorf("stok habis! permintaan produksi dikirim ke pabrik")
	}

	// 3. Kurangi stok
	_, err = tx.Exec("UPDATE Produk_Roti SET Stok_Roti = Stok_Roti - ? WHERE ID_Produk = ?", jumlah, idProduk)
	if err != nil {
		return err
	}

	// 4. Catat Transaksi Penjualan
	// Handle Guest (ID 0) -> NULL
	var idPelNull sql.NullInt64
	if idPelanggan > 0 {
		idPelNull.Int64 = int64(idPelanggan)
		idPelNull.Valid = true
	}

	res, err := tx.Exec(`
		INSERT INTO Transaksi_Penjualan 
		(Tanggal_Transaksi, Total_Harga, ID_Pelanggan, ID_Cabang) 
		VALUES (?, ?, ?, 3004)`,
		time.Now(), totalHarga, idPelNull)
	if err != nil {
		// Jika Pelanggan NULL dan IDPelanggan dikirim 0/1, SQL mungkin menolak jika FK strict.
		// Namun logic handler sudah handle Guest ID.
		return fmt.Errorf("gagal mencatat transaksi: %v", err)
	}

	idTransaksi, _ := res.LastInsertId()

	// 5. Catat Detail Transaksi
	// Tabel: Detail_Transaksi (Quantity, Total_Harga)
	_, err = tx.Exec(`
		INSERT INTO Detail_Transaksi (Quantity, Total_Harga, ID_Transaksi_Penjualan, ID_Produk)
		VALUES (?, ?, ?, ?)`,
		jumlah, totalHarga, idTransaksi, idProduk)
	if err != nil {
		return err
	}
	// 7. Commit Semua
	return tx.Commit()
}

// ItemKeranjang merepresentasikan satu item dalam request bulk
type ItemKeranjang struct {
	IDProduk int     `json:"id_produk"`
	Jumlah   int     `json:"jumlah"`
	Harga    float64 `json:"harga"` // Harga satuan setelah diskon
}

// TambahTransaksiBulk (DeepLogic: Shopping Cart Checkout)
// Menangani banyak item sekaligus dalam satu No. Struk (Atomic Transaction)
func (r *RepositoryTransaksi) TambahTransaksiBulk(items []ItemKeranjang, idPelanggan int, totalTagihan float64) error {
	if len(items) == 0 {
		return errors.New("keranjang kosong")
	}

	// 1. Mulai Transaksi
	tx, err := r.db.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback()

	// 2. Buat Header Transaksi Dulu
	// Handle Guest (ID 0) -> NULL
	var idPelNull sql.NullInt64
	if idPelanggan > 0 {
		idPelNull.Int64 = int64(idPelanggan)
		idPelNull.Valid = true
	}

	res, err := tx.Exec(`
		INSERT INTO Transaksi_Penjualan 
		(Tanggal_Transaksi, Total_Harga, ID_Pelanggan, ID_Cabang) 
		VALUES (?, ?, ?, 3004)`,
		time.Now(), totalTagihan, idPelNull)
	if err != nil {
		return fmt.Errorf("gagal buat header transaksi: %v", err)
	}
	idTransaksi, _ := res.LastInsertId()

	// 3. Loop Item
	for _, item := range items {
		// A. Cek & Kunci Stok
		var stok int
		err = tx.QueryRow("SELECT Stok_Roti FROM Produk_Roti WHERE ID_Produk = ? FOR UPDATE", item.IDProduk).Scan(&stok)
		if err != nil {
			return fmt.Errorf("produk ID %d tidak ditemukan", item.IDProduk)
		}
		if stok < item.Jumlah {
			return fmt.Errorf("stok produk ID %d tidak cukup (Sisa: %d)", item.IDProduk, stok)
		}

		// B. Kurangi Stok
		_, err = tx.Exec("UPDATE Produk_Roti SET Stok_Roti = Stok_Roti - ? WHERE ID_Produk = ?", item.Jumlah, item.IDProduk)
		if err != nil {
			return err
		}

		// C. Masukkan Detail Transaksi
		// Tabel: Detail_Transaksi
		subtotal := item.Harga * float64(item.Jumlah)
		_, err = tx.Exec(`
			INSERT INTO Detail_Transaksi (Quantity, Total_Harga, ID_Transaksi_Penjualan, ID_Produk)
			VALUES (?, ?, ?, ?)`,
			item.Jumlah, subtotal, idTransaksi, item.IDProduk)
		if err != nil {
			return err
		}
	}

	// 4. Log Aktivitas -> SKIP
	// _, _ = tx.Exec(...)

	// 5. Commit
	return tx.Commit()
}
