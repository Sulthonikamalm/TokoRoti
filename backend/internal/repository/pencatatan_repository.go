package repository

import (
	"tokoroti/internal/model"
)

// RepositoryPencatatan menangani akses data untuk log aktivitas (audit trail).
type RepositoryPencatatan struct {
	db *KoneksiDatabase
}

// BuatRepositoryPencatatan menginisialisasi repository pencatatan.
func BuatRepositoryPencatatan(db *KoneksiDatabase) *RepositoryPencatatan {
	return &RepositoryPencatatan{db: db}
}

// AmbilSemua mengambil log aktivitas dengan melakukan klasifikasi tipe aktivitas secara otomatis di level query.
func (r *RepositoryPencatatan) AmbilSemua() ([]model.Pencatatan, error) {
	kueri := `
		SELECT 
			pc.ID_Pencatatan,
			pc.ID_Cabang,
			c.Nama_Cabang,
			pc.ID_Transaksi_Penjualan,
			pc.ID_Pembelian_BahanBaku,
			pc.ID_Pengiriman,
			pc.Tanggal_Pencatatan,
			CASE 
				WHEN pc.ID_Transaksi_Penjualan IS NOT NULL THEN 'PENJUALAN'
				WHEN pc.ID_Pembelian_BahanBaku IS NOT NULL THEN 'PEMBELIAN'
				WHEN pc.ID_Pengiriman IS NOT NULL THEN 'PENGIRIMAN'
				ELSE 'LAINNYA'
			END AS Tipe_Aktivitas
		FROM Pencatatan pc
		LEFT JOIN Cabang c ON pc.ID_Cabang = c.ID_Cabang
		ORDER BY pc.Tanggal_Pencatatan DESC
	`

	barisData, err := r.db.EksekusiQueryAman(kueri)
	if err != nil {
		return nil, err
	}
	defer barisData.Close()

	var daftarLog []model.Pencatatan
	for barisData.Next() {
		var p model.Pencatatan
		err := barisData.Scan(
			&p.IDPencatatan,
			&p.IDCabang,
			&p.NamaCabang,
			&p.IDTransaksiPenjualan,
			&p.IDPembelianBahanBaku,
			&p.IDPengiriman,
			&p.TanggalPencatatan,
			&p.TipeAktivitas,
		)
		if err != nil {
			return nil, err
		}
		daftarLog = append(daftarLog, p)
	}

	return daftarLog, nil
}

// AmbilBerdasarkanTipe memfilter log berdasarkan kategori aktivitasnya.
func (r *RepositoryPencatatan) AmbilBerdasarkanTipe(tipe string) ([]model.Pencatatan, error) {
	// Logika pemilihan kondisi where dinamis
	var kondisi string
	switch tipe {
	case "PENJUALAN":
		kondisi = "pc.ID_Transaksi_Penjualan IS NOT NULL"
	case "PEMBELIAN":
		kondisi = "pc.ID_Pembelian_BahanBaku IS NOT NULL"
	case "PENGIRIMAN":
		kondisi = "pc.ID_Pengiriman IS NOT NULL"
	default:
		// Jika tipe tidak dikenali, kembalikan semua data
		return r.AmbilSemua()
	}

	kueri := `
		SELECT 
			pc.ID_Pencatatan,
			pc.ID_Cabang,
			c.Nama_Cabang,
			pc.ID_Transaksi_Penjualan,
			pc.ID_Pembelian_BahanBaku,
			pc.ID_Pengiriman,
			pc.Tanggal_Pencatatan,
			CASE 
				WHEN pc.ID_Transaksi_Penjualan IS NOT NULL THEN 'PENJUALAN'
				WHEN pc.ID_Pembelian_BahanBaku IS NOT NULL THEN 'PEMBELIAN'
				WHEN pc.ID_Pengiriman IS NOT NULL THEN 'PENGIRIMAN'
				ELSE 'LAINNYA'
			END AS Tipe_Aktivitas
		FROM Pencatatan pc
		LEFT JOIN Cabang c ON pc.ID_Cabang = c.ID_Cabang
		WHERE ` + kondisi + `
		ORDER BY pc.Tanggal_Pencatatan DESC
	`

	barisData, err := r.db.EksekusiQueryAman(kueri)
	if err != nil {
		return nil, err
	}
	defer barisData.Close()

	var daftarLog []model.Pencatatan
	for barisData.Next() {
		var p model.Pencatatan
		err := barisData.Scan(
			&p.IDPencatatan,
			&p.IDCabang,
			&p.NamaCabang,
			&p.IDTransaksiPenjualan,
			&p.IDPembelianBahanBaku,
			&p.IDPengiriman,
			&p.TanggalPencatatan,
			&p.TipeAktivitas,
		)
		if err != nil {
			return nil, err
		}
		daftarLog = append(daftarLog, p)
	}

	return daftarLog, nil
}
