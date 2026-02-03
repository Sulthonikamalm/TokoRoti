package repository

import (
	"tokoroti/internal/model"
)

// RepositoryProduk menangani operasi database yang berkaitan dengan tabel Produk_Roti.
type RepositoryProduk struct {
	db *KoneksiDatabase
}

// BuatRepositoryProduk membuat instance baru dari RepositoryProduk.
func BuatRepositoryProduk(db *KoneksiDatabase) *RepositoryProduk {
	return &RepositoryProduk{db: db}
}

// AmbilSemua mengambil seluruh data produk dari database.
func (r *RepositoryProduk) AmbilSemua() ([]model.ProdukRoti, error) {
	kueri := `
		SELECT 
			ID_Produk, 
			Kode_Produk, 
			Nama_Produk, 
			Jenis_Produk, 
			Harga, 
			Stok_Roti 
		FROM Produk_Roti
		ORDER BY ID_Produk ASC
	`

	barisData, err := r.db.EksekusiQueryAman(kueri)
	if err != nil {
		return nil, err
	}
	defer barisData.Close()

	var daftarProduk []model.ProdukRoti
	for barisData.Next() {
		var p model.ProdukRoti
		err := barisData.Scan(
			&p.IDProduk,
			&p.KodeProduk,
			&p.NamaProduk,
			&p.JenisProduk,
			&p.Harga,
			&p.StokRoti,
		)
		if err != nil {
			return nil, err
		}
		daftarProduk = append(daftarProduk, p)
	}

	return daftarProduk, nil
}
