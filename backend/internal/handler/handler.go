package handler

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"tokoroti/internal/model"
	"tokoroti/internal/repository"
)

// Handler menyatukan seluruh dependensi repository yang dibutuhkan kontroler.
// Ini memungkinkan kita untuk menyuntikkan (inject) akses data ke dalam logika handler.
type Handler struct {
	repoProduk     *repository.RepositoryProduk
	repoTransaksi  *repository.RepositoryTransaksi
	repoPencatatan *repository.RepositoryPencatatan
	repoPelanggan  *repository.RepositoryPelanggan
}

// BuatHandler membangung objek Handler baru dengan dependensi lengkap.
func BuatHandler(
	rp *repository.RepositoryProduk,
	rt *repository.RepositoryTransaksi,
	rpc *repository.RepositoryPencatatan,
	rpl *repository.RepositoryPelanggan,
) *Handler {
	return &Handler{
		repoProduk:     rp,
		repoTransaksi:  rt,
		repoPencatatan: rpc,
		repoPelanggan:  rpl,
	}
}

// CekMemberHandler menangani permintaan cek status member via no telepon.
func (h *Handler) CekMemberHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		kirimResponError(w, http.StatusMethodNotAllowed, "Metode salah")
		return
	}

	noTelepon := r.URL.Query().Get("no_telepon")
	if noTelepon == "" {
		kirimResponError(w, http.StatusBadRequest, "Nomor telepon wajib diisi")
		return
	}

	pelanggan, err := h.repoPelanggan.CekKeanggotaan(noTelepon)
	if err != nil {
		// Asumsikan error adalah "tidak ditemukan"
		respon := model.ResponCekMember{
			Sukses: false,
			Pesan:  "Nomor tidak terdaftar sebagai member",
		}
		kirimResponJSON(w, http.StatusOK, respon) // Return 200 OK tapi sukses false (soft fail)
		return
	}

	respon := model.ResponCekMember{
		Sukses: true,
		Pesan:  "Member ditemukan",
		Data:   pelanggan,
	}
	kirimResponJSON(w, http.StatusOK, respon)
}

// Struct untuk input transaksi JSON
type InputTransaksi struct {
	IDProduk int `json:"id_produk"`
	// IDPelanggan opsional, jika 0 berarti Guest (kita map ke ID 1 di DB atau null)
	IDPelanggan int     `json:"id_pelanggan"`
	Jumlah      int     `json:"jumlah"`
	TotalHarga  float64 `json:"total_harga"`
}

// BuatTransaksiHandler menangani POST /api/transaksi/baru
func (h *Handler) BuatTransaksiHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		kirimResponError(w, http.StatusMethodNotAllowed, "Hanya menerima metode POST")
		return
	}

	var input InputTransaksi
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		kirimResponError(w, http.StatusBadRequest, "Format JSON salah")
		return
	}

	// Validasi Dasar
	if input.IDProduk == 0 || input.Jumlah <= 0 {
		kirimResponError(w, http.StatusBadRequest, "Data produk tidak valid")
		return
	}

	// Default Guest ID jika kosong (Pastikan di DB ada Pelanggan ID 1 bernama 'Guest' atau handle NULL)
	// Untuk keamanan, kita set ID Pelanggan 1 (Guest) jika user mengirim 0
	if input.IDPelanggan == 0 {
		input.IDPelanggan = 1
	}

	err := h.repoTransaksi.TambahTransaksi(input.IDProduk, input.IDPelanggan, input.Jumlah, input.TotalHarga)
	if err != nil {
		kirimResponError(w, http.StatusInternalServerError, "Gagal memproses transaksi: "+err.Error())
		return
	}

	// Kirim sukses
	kirimResponJSON(w, http.StatusOK, map[string]string{
		"pesan":  "Transaksi berhasil! Pesanan diproses ke gudang.",
		"status": "success",
	})
}

// InputCheckout merepresentasikan payload JSON untuk keranjang
type InputCheckout struct {
	Items       []repository.ItemKeranjang `json:"items"`
	IDPelanggan int                        `json:"id_pelanggan"`
	TotalBayar  float64                    `json:"total_bayar"`
}

// CheckoutKeranjangHandler menangani POST /api/transaksi/checkout
func (h *Handler) CheckoutKeranjangHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		kirimResponError(w, http.StatusMethodNotAllowed, "Metode salah")
		return
	}

	var input InputCheckout
	if err := json.NewDecoder(r.Body).Decode(&input); err != nil {
		kirimResponError(w, http.StatusBadRequest, "Format JSON salah")
		return
	}

	// Validasi User
	// Jika IDPelanggan 0, kita biarkan 0 agar repository menganggapnya sebagai Guest (NULL)
	if input.TotalBayar <= 0 {
		kirimResponError(w, http.StatusBadRequest, "Total bayar tidak valid")
		return
	}

	err := h.repoTransaksi.TambahTransaksiBulk(input.Items, input.IDPelanggan, input.TotalBayar)
	if err != nil {
		kirimResponError(w, http.StatusInternalServerError, "Checkout Gagal: "+err.Error())
		return
	}

	kirimResponJSON(w, http.StatusOK, map[string]string{
		"pesan":  "Pembayaran Berhasil! Pesanan sedang disiapkan.",
		"status": "success",
	})
}

// AmbilDaftarProduk menangani permintaan GET ke /api/produk.
func (h *Handler) AmbilDaftarProduk(w http.ResponseWriter, r *http.Request) {
	// Validasi metode HTTP
	if r.Method != http.MethodGet {
		kirimResponError(w, http.StatusMethodNotAllowed, "Metode HTTP tidak diizinkan")
		return
	}

	daftarProduk, err := h.repoProduk.AmbilSemua()
	if err != nil {
		log.Printf("Error mengambil data produk: %v", err)
		kirimResponError(w, http.StatusInternalServerError, "Gagal memuat data produk")
		return
	}

	// Bungkus data dalam format standar respon
	respon := model.ResponProduk{
		Sukses: true,
		Pesan:  "Data produk berhasil diambil",
		Data:   daftarProduk,
		Jumlah: len(daftarProduk),
	}

	kirimResponJSON(w, http.StatusOK, respon)
}

// AmbilRiwayatTransaksi menangani permintaan GET ke /api/transaksi.
func (h *Handler) AmbilRiwayatTransaksi(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		kirimResponError(w, http.StatusMethodNotAllowed, "Metode HTTP tidak diizinkan")
		return
	}

	riwayatTransaksi, err := h.repoTransaksi.AmbilSemua()
	if err != nil {
		log.Printf("Error mengambil data transaksi: %v", err)
		kirimResponError(w, http.StatusInternalServerError, "Gagal memuat riwayat transaksi")
		return
	}

	respon := model.ResponTransaksi{
		Sukses: true,
		Pesan:  "Data transaksi berhasil diambil",
		Data:   riwayatTransaksi,
		Jumlah: len(riwayatTransaksi),
	}

	kirimResponJSON(w, http.StatusOK, respon)
}

// AmbilLogAktivitas menangani permintaan GET ke /api/pencatatan.
// Mendukung parameter query 'tipe' untuk filtering (contoh: ?tipe=PENJUALAN).
func (h *Handler) AmbilLogAktivitas(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		kirimResponError(w, http.StatusMethodNotAllowed, "Metode HTTP tidak diizinkan")
		return
	}

	// Baca parameter filter opsional dari URL
	filterTipe := r.URL.Query().Get("tipe")

	var daftarLog []model.Pencatatan
	var err error

	if filterTipe != "" {
		daftarLog, err = h.repoPencatatan.AmbilBerdasarkanTipe(filterTipe)
	} else {
		daftarLog, err = h.repoPencatatan.AmbilSemua()
	}

	if err != nil {
		log.Printf("Error mengambil log aktivitas: %v", err)
		kirimResponError(w, http.StatusInternalServerError, "Gagal memuat log aktivitas")
		return
	}

	respon := model.ResponPencatatan{
		Sukses: true,
		Pesan:  "Data pencatatan berhasil diambil",
		Data:   daftarLog,
		Jumlah: len(daftarLog),
	}

	kirimResponJSON(w, http.StatusOK, respon)
}

// InputRegistrasi Payload
type InputRegistrasi struct {
	Nama      string `json:"nama"`
	NoTelepon string `json:"no_telepon"`
}

// RegistrasiPelangganHandler menangani POST /api/pelanggan/baru
func (h *Handler) RegistrasiPelangganHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		kirimResponError(w, http.StatusMethodNotAllowed, "Hanya Post")
		return
	}
	var in InputRegistrasi
	if err := json.NewDecoder(r.Body).Decode(&in); err != nil {
		kirimResponError(w, http.StatusBadRequest, "JSON Salah")
		return
	}
	if in.Nama == "" || in.NoTelepon == "" {
		kirimResponError(w, http.StatusBadRequest, "Nama dan No Telepon wajib diisi")
		return
	}

	err := h.repoPelanggan.RegistrasiPelanggan(in.Nama, in.NoTelepon)
	if err != nil {
		kirimResponError(w, http.StatusInternalServerError, err.Error())
		return
	}

	kirimResponJSON(w, http.StatusOK, map[string]string{
		"pesan":  "Registrasi Berhasil! Silakan Login.",
		"status": "success",
	})
}

// InputProduk Baru
type InputProduk struct {
	Kode  string  `json:"kode"`
	Nama  string  `json:"nama"`
	Jenis string  `json:"jenis"`
	Harga float64 `json:"harga"`
	Stok  int     `json:"stok"`
}

type InputStok struct {
	Stok int `json:"stok"`
}

func (h *Handler) TambahProdukHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		kirimResponError(w, http.StatusMethodNotAllowed, "Hanya POST")
		return
	}
	var in InputProduk
	if err := json.NewDecoder(r.Body).Decode(&in); err != nil {
		kirimResponError(w, http.StatusBadRequest, "Data tidak valid")
		return
	}
	err := h.repoProduk.TambahProduk(in.Kode, in.Nama, in.Jenis, in.Harga, in.Stok)
	if err != nil {
		kirimResponError(w, http.StatusInternalServerError, err.Error())
		return
	}
	kirimResponJSON(w, http.StatusOK, map[string]string{"pesan": "Produk berhasil ditambah", "status": "success"})
}

func (h *Handler) UpdateStokHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPut {
		kirimResponError(w, http.StatusMethodNotAllowed, "Hanya PUT")
		return
	}
	idStr := r.URL.Query().Get("id")
	if idStr == "" {
		kirimResponError(w, http.StatusBadRequest, "ID Produk wajib ada")
		return
	}
	// Parse Int via Sscanf simple trick
	var id int
	fmt.Sscanf(idStr, "%d", &id)

	var in InputStok
	if err := json.NewDecoder(r.Body).Decode(&in); err != nil {
		kirimResponError(w, http.StatusBadRequest, "Data tidak valid")
		return
	}

	err := h.repoProduk.UpdateStok(id, in.Stok)
	if err != nil {
		kirimResponError(w, http.StatusInternalServerError, err.Error())
		return
	}
	kirimResponJSON(w, http.StatusOK, map[string]string{"pesan": "Stok berhasil diupdate", "status": "success"})
}

// kirimResponJSON adalah helper untuk mengirim respon format JSON yang konsisten.
func kirimResponJSON(w http.ResponseWriter, status int, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)

	if err := json.NewEncoder(w).Encode(data); err != nil {
		log.Printf("Error saat encoding JSON: %v", err)
	}
}

// kirimResponError adalah helper khusus untuk mengirim pesan error standar.
func kirimResponError(w http.ResponseWriter, status int, pesan string) {
	respon := map[string]interface{}{
		"sukses": false,
		"pesan":  pesan,
		"data":   nil,
	}
	kirimResponJSON(w, status, respon)
}
