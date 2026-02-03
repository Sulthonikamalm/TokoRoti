package model

import "time"

// TransaksiPenjualan merepresentasikan header dari tabel Transaksi_Penjualan.
type TransaksiPenjualan struct {
	IDTransaksiPenjualan int       `json:"id_transaksi_penjualan"`
	IDPelanggan          *int      `json:"id_pelanggan,omitempty"`
	NamaPelanggan        *string   `json:"nama_pelanggan,omitempty"`
	IDCabang             int       `json:"id_cabang"`
	NamaCabang           string    `json:"nama_cabang"`
	TanggalTransaksi     time.Time `json:"tanggal_transaksi"`
	TotalHarga           float64   `json:"total_harga"`
}

// DetailTransaksi merepresentasikan rincian item dalam tabel Detail_Transaksi.
type DetailTransaksi struct {
	IDDetailTransaksi    int     `json:"id_detail_transaksi"`
	IDTransaksiPenjualan int     `json:"id_transaksi_penjualan"`
	IDProduk             int     `json:"id_produk"`
	NamaProduk           string  `json:"nama_produk"`
	Kuantitas            int     `json:"kuantitas"`
	TotalHarga           float64 `json:"total_harga"`
}

// TransaksiLengkap menggabungkan data header transaksi dengan detail itemnya.
// Struktur ini berguna jika ingin menampilkan detail lengkap dalam satu objek.
type TransaksiLengkap struct {
	Transaksi TransaksiPenjualan `json:"transaksi"`
	Detail    []DetailTransaksi  `json:"detail"`
}

// ResponTransaksi adalah format standar respon API untuk data transaksi.
type ResponTransaksi struct {
	Sukses bool                 `json:"sukses"`
	Pesan  string               `json:"pesan"`
	Data   []TransaksiPenjualan `json:"data"`
	Jumlah int                  `json:"jumlah"`
}
