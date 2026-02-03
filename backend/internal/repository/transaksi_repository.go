package repository

import (
	"tokoroti/internal/model"
)

// RepositoryTransaksi menangani interaksi database untuk data transaksi penjualan.
type RepositoryTransaksi struct {
	db *KoneksiDatabase
}

// BuatRepositoryTransaksi menginisialisasi repository transaksi baru.
func BuatRepositoryTransaksi(db *KoneksiDatabase) *RepositoryTransaksi {
	return &RepositoryTransaksi{db: db}
}

// AmbilSemua mengambil data transaksi beserta informasi pelanggan dan cabang terkait (JOIN).
func (r *RepositoryTransaksi) AmbilSemua() ([]model.TransaksiPenjualan, error) {
	kueri := `
		SELECT 
			tp.ID_Transaksi_Penjualan,
			tp.ID_Pelanggan,
			p.Nama AS Nama_Pelanggan,
			tp.ID_Cabang,
			c.Nama_Cabang,
			tp.Tanggal_Transaksi,
			tp.Total_Harga
		FROM Transaksi_Penjualan tp
		LEFT JOIN Pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
		INNER JOIN Cabang c ON tp.ID_Cabang = c.ID_Cabang
		ORDER BY tp.Tanggal_Transaksi DESC
	`

	barisData, err := r.db.EksekusiQueryAman(kueri)
	if err != nil {
		return nil, err
	}
	defer barisData.Close()

	var daftarTransaksi []model.TransaksiPenjualan
	for barisData.Next() {
		var t model.TransaksiPenjualan
		err := barisData.Scan(
			&t.IDTransaksiPenjualan,
			&t.IDPelanggan,
			&t.NamaPelanggan,
			&t.IDCabang,
			&t.NamaCabang,
			&t.TanggalTransaksi,
			&t.TotalHarga,
		)
		if err != nil {
			return nil, err
		}
		daftarTransaksi = append(daftarTransaksi, t)
	}

	return daftarTransaksi, nil
}
