package handler

import (
	"net/http"
)

// MiddlewareCORS menangani header Cross-Origin Resource Sharing.
// VERSI DEV: Diizinkan untuk SEMUA asal (Allow All) agar mudah dites di lokal.
func MiddlewareCORS(handlerSelanjutnya http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Logic Keamanan CORS: Izinkan Localhost dan Vercel Production
		origin := r.Header.Get("Origin")
		allowedOrigins := map[string]bool{
			"http://localhost:8080":           true, // Local Backend UI
			"http://127.0.0.1:8080":           true, // Local IP
			"https://toko-roti-nu.vercel.app": true, // Production Vercel
		}

		if allowedOrigins[origin] {
			w.Header().Set("Access-Control-Allow-Origin", origin)
		} else {
			// Fallback aman untuk public API (opsional, atau bisa blokir)
			// w.Header().Set("Access-Control-Allow-Origin", "*")
			// Kita set Vercel sebagai default jika origin tidak match (agar aman)
			w.Header().Set("Access-Control-Allow-Origin", "https://toko-roti-nu.vercel.app")
		}

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
