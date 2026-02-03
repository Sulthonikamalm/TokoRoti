package model

// ProdukRoti merepresentasikan struktur tabel Produk_Roti di database.
// Struktur ini digunakan untuk memetakan data dari baris database ke objek Go.
type ProdukRoti struct {
	IDProduk    int     `json:"id_produk"`
	KodeProduk  string  `json:"kode_produk"`
	NamaProduk  string  `json:"nama_produk"`
	JenisProduk *string `json:"jenis_produk,omitempty"` // Pointer string untuk menangani nilai NULL dari database
	Harga       float64 `json:"harga"`
	StokRoti    int     `json:"stok_roti"`
}

// ResponProduk adalah pembungkus standar untuk respon API produk.
// Ini memastikan konsistensi format JSON yang diterima frontend.
type ResponProduk struct {
	Sukses bool         `json:"sukses"`
	Pesan  string       `json:"pesan"`
	Data   []ProdukRoti `json:"data"`
	Jumlah int          `json:"jumlah"`
}
