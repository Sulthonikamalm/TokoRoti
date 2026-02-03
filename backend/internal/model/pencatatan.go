package model

import "time"

// Pencatatan merepresentasikan log aktivitas sistem dari tabel Pencatatan.
// Digunakan untuk keperluan audit dan monitoring aktivitas.
type Pencatatan struct {
	IDPencatatan         int64     `json:"id_pencatatan"`
	IDCabang             *int      `json:"id_cabang,omitempty"`
	NamaCabang           *string   `json:"nama_cabang,omitempty"`
	IDTransaksiPenjualan *int      `json:"id_transaksi_penjualan,omitempty"`
	IDPembelianBahanBaku *int      `json:"id_pembelian_bahan_baku,omitempty"`
	IDPengiriman         *int      `json:"id_pengiriman,omitempty"`
	TanggalPencatatan    time.Time `json:"tanggal_pencatatan"`
	TipeAktivitas        string    `json:"tipe_aktivitas"`
}

// ResponPencatatan adalah format standar respon API untuk data log.
type ResponPencatatan struct {
	Sukses bool         `json:"sukses"`
	Pesan  string       `json:"pesan"`
	Data   []Pencatatan `json:"data"`
	Jumlah int          `json:"jumlah"`
}
