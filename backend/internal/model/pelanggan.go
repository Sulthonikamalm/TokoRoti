package model

// InfoPelanggan merepresentasikan data pelanggan yang digabung dengan status membernya.
// Ini adalah hasil JOIN antara tabel Pelanggan dan Keanggotaan.
type InfoPelanggan struct {
	IDPelanggan   int     `json:"id_pelanggan"`
	Nama          string  `json:"nama"`
	NoTelepon     string  `json:"no_telepon"`
	StatusMember  string  `json:"status_member"`  // Contoh: 'Gold', 'Diamond'
	ManfaatMember float64 `json:"manfaat_member"` // Contoh: 0.10 (Diskon 10%)
}

type ResponCekMember struct {
	Sukses bool           `json:"sukses"`
	Pesan  string         `json:"pesan"`
	Data   *InfoPelanggan `json:"data,omitempty"`
}
