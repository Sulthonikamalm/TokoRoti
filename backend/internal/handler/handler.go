package handler

import (
	"encoding/json"
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
}

// BuatHandler membangung objek Handler baru dengan dependensi lengkap.
func BuatHandler(
	rp *repository.RepositoryProduk,
	rt *repository.RepositoryTransaksi,
	rpc *repository.RepositoryPencatatan,
) *Handler {
	return &Handler{
		repoProduk:     rp,
		repoTransaksi:  rt,
		repoPencatatan: rpc,
	}
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
