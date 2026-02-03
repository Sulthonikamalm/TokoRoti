package handler

import (
	"net/http"
)

// MiddlewareCORS menangani header Cross-Origin Resource Sharing.
// VERSI DEV: Diizinkan untuk SEMUA asal (Allow All) agar mudah dites di lokal.
func MiddlewareCORS(handlerSelanjutnya http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// PENTING: Untuk development lokal yang mudah, kita izinkan semua (*)
		// Nanti saat deploy produksi, ubah "*" menjadi domain spesifik Anda.
		w.Header().Set("Access-Control-Allow-Origin", "*")

		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Accept, Authorization, Content-Type, X-CSRF-Token")
		w.Header().Set("Access-Control-Allow-Credentials", "true")

		// Jika permintaan adalah preflight (OPTIONS), langsung beri lampu hijau (OK)
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusOK)
			return
		}

		handlerSelanjutnya.ServeHTTP(w, r)
	})
}
