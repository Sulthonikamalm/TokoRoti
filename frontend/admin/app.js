/**
 * BreadHouse Enterprise Dashboard 
 * Core Logic & Responsiveness
 */

// Konfigurasi Hybrid (Local vs Cloud)
const IS_LOCALHOST = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1';
// ================================================================
// GANTI URL DI BAWAH INI SETELAH DEPLOY BACKEND DI KOYEB
// ================================================================
const PRODUCTION_API = 'https://tokoroti-api.koyeb.app';

const KONFIGURASI = {
    URL_DASAR_API: IS_LOCALHOST ? '' : PRODUCTION_API, // Local pake relatif, Cloud pake Absolute URL Koyeb
    TIMEOUT_REQUEST: 5000, 
    ENDPOINT: {
        PRODUK: '/api/produk',
        TRANSAKSI: '/api/transaksi',
        PENCATATAN: '/api/pencatatan',
        KESEHATAN: '/kesehatan'
    }
};

const StateAplikasi = {
    halamanAktif: 'produk',
    data: { produk: [], transaksi: [], pencatatan: [] },
    status: { sedangMemuat: false, terhubung: false }
};

// ============================================
// UI & MODAL CONTROL (New)
// ============================================

function bukaModalAdmin(mode, id = null) {
    const modal = document.getElementById('modal-admin');
    const content = document.getElementById('modal-content');
    const title = document.getElementById('modal-title');
    const formAdd = document.getElementById('form-tambah-produk');
    const formStok = document.getElementById('form-update-stok');

    modal.classList.remove('opacity-0', 'pointer-events-none');
    content.classList.remove('scale-95');
    content.classList.add('scale-100');

    formAdd.classList.add('hidden');
    formStok.classList.add('hidden');

    if (mode === 'tambah') {
        title.textContent = 'Tambah Produk Baru';
        formAdd.classList.remove('hidden');
    } else if (mode === 'stok') {
        title.textContent = 'Update Stok Fisik';
        formStok.classList.remove('hidden');
        document.getElementById('edit-id').value = id;
        // Cari nama produk untuk label
        const p = StateAplikasi.data.produk.find(x => x.id_produk == id);
        if(p) {
            document.getElementById('label-product-name').textContent = p.nama_produk;
            document.getElementById('edit-stok').value = p.stok_roti;
        }
    }
}

function tutupModalAdmin() {
    const modal = document.getElementById('modal-admin');
    const content = document.getElementById('modal-content');
    modal.classList.add('opacity-0', 'pointer-events-none');
    content.classList.remove('scale-100');
    content.classList.add('scale-95');
}

// ============================================
// API ACTIONS (New)
// ============================================

async function simpanProdukBaru() {
    const payload = {
        kode: document.getElementById('in-kode').value,
        nama: document.getElementById('in-nama').value,
        jenis: document.getElementById('in-jenis').value,
        harga: parseFloat(document.getElementById('in-harga').value),
        stok: parseInt(document.getElementById('in-stok').value)
    };

    if(!payload.kode || !payload.nama) return alert("Lengkapi data!");

    try {
        const res = await fetch('/api/produk/baru', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify(payload)
        });
        const json = await res.json();
        
        if (res.ok) {
            tutupModalAdmin();
            tampilkanToast("✨ Produk berhasil ditambahkan!");
            ambilDataProduk(); // Refresh
        } else {
            alert("Gagal: " + json.pesan);
        }
    } catch (e) {
        alert("Error Jaringan");
    }
}

async function simpanStokBaru() {
    const id = document.getElementById('edit-id').value;
    const stok = parseInt(document.getElementById('edit-stok').value);

    try {
        const res = await fetch(`/api/produk/stok?id=${id}`, {
            method: 'PUT',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ stok: stok })
        });
        const json = await res.json();

        if (res.ok) {
            tutupModalAdmin();
            tampilkanToast("✅ Stok diperbarui!");
            ambilDataProduk(); // Refresh
        } else {
            alert("Gagal: " + json.pesan);
        }
    } catch (e) {
        alert("Error Jaringan");
    }
}

// ============================================
// LOGIKA RESPONSIF (Original)
// ============================================

function bukaMenuMobile() {
    const sidebar = document.getElementById('sidebar-utama');
    const overlay = document.getElementById('mobile-overlay');
    overlay.classList.remove('hidden');
    setTimeout(() => overlay.classList.remove('opacity-0'), 10);
    sidebar.classList.remove('-translate-x-full');
}

function tutupMenuMobile() {
    const sidebar = document.getElementById('sidebar-utama');
    const overlay = document.getElementById('mobile-overlay');
    sidebar.classList.add('-translate-x-full');
    overlay.classList.add('opacity-0');
    setTimeout(() => overlay.classList.add('hidden'), 300);
}

function navigasiKe(target) {
    StateAplikasi.halamanAktif = target;
    document.querySelectorAll('.nav-item').forEach(el => {
        const aktif = el.dataset.target === target;
        el.classList.toggle('active', aktif);
        el.classList.toggle('bg-primary-50', aktif);
        el.classList.toggle('text-primary-600', aktif);
        const ikon = el.querySelector('i');
        if (aktif) {
            ikon.className = ikon.className.replace('text-slate-400', 'text-primary-600');
            if(!ikon.classList.contains('ph-fill')) ikon.classList.replace('ph', 'ph-fill');
        } else {
            ikon.className = ikon.className.replace('text-primary-600', 'text-slate-400');
            if(ikon.classList.contains('ph-fill')) ikon.classList.replace('ph-fill', 'ph');
        }
    });

    ['produk', 'transaksi', 'pencatatan'].forEach(id => {
        const el = document.getElementById(`konten-${id}`);
        if(el) el.classList.add('hidden');
    });
    
    const targetEl = document.getElementById(`konten-${target}`);
    if(targetEl) {
        targetEl.classList.remove('hidden');
        targetEl.classList.add('animasi-masuk');
    }

    const judul = { 'produk': 'Manajemen Produk', 'transaksi': 'Riwayat Transaksi', 'pencatatan': 'Log Aktivitas' };
    document.getElementById('judul-halaman').textContent = judul[target] || 'Dashboard';

    if (target === 'produk') ambilDataProduk();
    if (target === 'transaksi') ambilDataTransaksi();
    if (target === 'pencatatan') ambilDataLog();
    
    if (window.innerWidth < 768) {
        tutupMenuMobile();
    }
}

const formatRupiah = (angka) => new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(angka);
const formatTanggal = (str) => (!str) ? '-' : new Intl.DateTimeFormat('id-ID', { dateStyle: 'long', timeStyle: 'short' }).format(new Date(str));
const bersihkanHTML = (teks) => { const d = document.createElement('div'); d.textContent = teks; return d.innerHTML; };

async function panggilAPI(endpoint, opsi = {}) {
    const k = new AbortController();
    const t = setTimeout(() => k.abort(), KONFIGURASI.TIMEOUT_REQUEST);
    try {
        const r = await fetch(`${KONFIGURASI.URL_DASAR_API}${endpoint}`, { ...opsi, signal: k.signal });
        clearTimeout(t);
        if(!r.ok) throw new Error(r.status);
        const d = await r.json();
        perbaruiStatusKoneksi(true);
        return d;
    } catch (e) {
        clearTimeout(t);
        perbaruiStatusKoneksi(false);
        let msg = 'Gagal terhubung ke Backend.';
        if(e.name === 'AbortError') msg = 'Waktu habis.';
        throw new Error(msg);
    }
}

function perbaruiStatusKoneksi(ok) {
    const el = document.getElementById('status-koneksi');
    if(!el) return;
    el.innerHTML = ok 
        ? `<span class="flex h-2 w-2 relative"><span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span><span class="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span></span> Terhubung`
        : `<span class="flex h-2 w-2 bg-rose-500 rounded-full"></span> Terputus`;
    el.className = `flex items-center gap-2 text-xs font-bold rounded px-3 py-1.5 transition-colors ${ok ? 'bg-emerald-50 text-emerald-700' : 'bg-rose-50 text-rose-700'}`;
}

async function ambilDataProduk() {
    const el = document.getElementById('grid-produk');
    tampilkanSkeleton(el, 4);
    try {
        const h = await panggilAPI(KONFIGURASI.ENDPOINT.PRODUK);
        StateAplikasi.data.produk = h.data || [];
        renderProduk(StateAplikasi.data.produk);
        perbaruiStatistik();
    } catch (e) { el.innerHTML = uiError(e.message); }
}

async function ambilDataTransaksi() {
    const el = document.getElementById('tabel-transaksi');
    el.innerHTML = '<tr><td colspan="5" class="p-6 text-center text-slate-400">Memuat...</td></tr>';
    try {
        const h = await panggilAPI(KONFIGURASI.ENDPOINT.TRANSAKSI);
        StateAplikasi.data.transaksi = h.data || [];
        renderTransaksi(StateAplikasi.data.transaksi);
        perbaruiStatistik();
    } catch (e) { el.innerHTML = `<tr><td colspan="5">${uiError(e.message)}</td></tr>`; }
}

async function ambilDataLog(tipe='') {
    const el = document.getElementById('list-log');
    el.innerHTML = '<div class="p-6 text-center text-slate-400">Memuat log...</div>';
    try {
        const h = await panggilAPI(tipe ? `${KONFIGURASI.ENDPOINT.PENCATATAN}?tipe=${tipe}` : KONFIGURASI.ENDPOINT.PENCATATAN);
        StateAplikasi.data.pencatatan = h.data || [];
        renderLog(StateAplikasi.data.pencatatan);
        perbaruiStatistik();
    } catch (e) { el.innerHTML = uiError(e.message); }
}

function renderProduk(data) {
    const el = document.getElementById('grid-produk');
    if(!data.length) return el.innerHTML = uiKosong('Produk kosong.');
    el.innerHTML = data.map((item, i) => `
        <div class="bg-white rounded-xl border border-slate-200 p-5 group hover:border-primary-200 hover:shadow-lg transition-all duration-300" style="animation: fadeUp 0.5s ease backwards ${i*0.05}s">
            <div class="flex justify-between items-start mb-3">
                <span class="bg-slate-100 text-slate-600 text-[10px] uppercase font-bold px-2 py-1 rounded tracking-wide">${bersihkanHTML(item.kode_produk)}</span>
                <span class="${item.stok_roti < 10 ? 'bg-rose-50 text-rose-600' : 'bg-emerald-50 text-emerald-600'} text-xs font-bold px-2.5 py-1 rounded-full flex items-center gap-1">
                    ${item.stok_roti < 10 ? '<i class="ph-fill ph-warning-circle"></i>' : '<i class="ph-fill ph-check-circle"></i>'}
                    Stok: ${item.stok_roti}
                </span>
            </div>
            <h4 class="font-bold text-slate-800 text-lg mb-1 group-hover:text-primary-600 transition-colors line-clamp-1">${bersihkanHTML(item.nama_produk)}</h4>
            <p class="text-slate-500 text-sm mb-4 line-clamp-1">${bersihkanHTML(item.jenis_produk)}</p>
            <div class="flex items-end justify-between border-t border-slate-50 pt-3">
                <div>
                   <p class="text-[10px] text-slate-400 font-bold uppercase">Harga</p>
                   <p class="text-slate-800 font-bold text-lg">${formatRupiah(item.harga)}</p>
                </div>
                <!-- Tombol Edit Stok (Update) -->
                <button onclick="bukaModalAdmin('stok', ${item.id_produk})" class="w-8 h-8 rounded-lg bg-slate-50 text-slate-400 hover:bg-emerald-50 hover:text-emerald-600 flex items-center justify-center transition-colors">
                    <i class="ph-bold ph-pencil-simple"></i>
                </button>
            </div>
        </div>`).join('');
}

function renderTransaksi(data) {
    const el = document.getElementById('tabel-transaksi');
    if(!data.length) return el.innerHTML = `<tr><td colspan="5">${uiKosong('Belum ada transaksi.')}</td></tr>`;
    el.innerHTML = data.map((t, i) => `
        <tr class="hover:bg-slate-50 border-b border-slate-50 last:border-0 transition-colors" style="animation: fadeUp 0.3s ease backwards ${i*0.03}s">
            <td class="px-6 py-4 font-mono text-xs text-slate-500">#${t.id_transaksi_penjualan}</td>
            <td class="px-6 py-4 font-medium text-slate-700">${bersihkanHTML(t.nama_pelanggan || 'Guest')}</td>
            <td class="px-6 py-4"><span class="inline-flex items-center gap-1 bg-slate-100 px-2 py-1 rounded text-xs font-medium text-slate-600"><i class="ph-bold ph-storefront"></i> ${bersihkanHTML(t.nama_cabang)}</span></td>
            <td class="px-6 py-4 text-slate-500 text-sm">${formatTanggal(t.tanggal_transaksi)}</td>
            <td class="px-6 py-4 text-right font-bold text-slate-800">${formatRupiah(t.total_harga)}</td>
        </tr>`).join('');
}

function renderLog(data) {
    const el = document.getElementById('list-log');
    if(!data.length) return el.innerHTML = uiKosong('Kosong.');
    el.innerHTML = data.map((l, i) => `
        <div class="px-6 py-4 hover:bg-slate-50 transition-colors flex gap-4 items-start" style="animation: fadeUp 0.3s ease backwards ${i*0.03}s">
            <div class="w-8 h-8 rounded-full bg-slate-100 flex items-center justify-center text-slate-500 mt-1 flex-shrink-0"><i class="ph-fill ph-info"></i></div>
            <div class="flex-1 min-w-0">
                <div class="flex justify-between">
                    <p class="font-bold text-slate-800 text-sm truncate">${l.tipe_aktivitas}</p>
                    <span class="text-[10px] text-slate-400 font-medium whitespace-nowrap ml-2">${formatTanggal(l.tanggal_pencatatan)}</span>
                </div>
                <p class="text-xs text-slate-500 mt-0.5 truncate">Ref ID: #${l.id_pencatatan} • <i class="ph-bold ph-map-pin"></i> ${bersihkanHTML(l.nama_cabang || '-')}</p>
            </div>
        </div>`).join('');
}

function uiError(msg) { return `<div class="col-span-full p-8 text-center bg-rose-50 rounded-xl border border-rose-100"><i class="ph-fill ph-warning text-3xl text-rose-400 mb-2"></i><p class="text-rose-700 text-sm font-bold">Koneksi Gagal</p><p class="text-rose-600 text-xs mb-3 opacity-80">${bersihkanHTML(msg)}</p><button onclick="muatUlangData()" class="text-xs bg-rose-600 text-white px-3 py-1.5 rounded hover:bg-rose-700 transition">Coba Lagi</button></div>`; }
function uiKosong(msg) { return `<div class="p-12 text-center text-slate-300 flex flex-col items-center"><i class="ph-duotone ph-folder-open text-4xl mb-2"></i><span class="text-sm font-medium">${msg}</span></div>`; }
function tampilkanSkeleton(el, n) { el.innerHTML = Array(n).fill('<div class="h-[180px] bg-slate-50 rounded-xl animate-pulse border border-slate-100"></div>').join(''); }

function muatUlangData() { const h = StateAplikasi.halamanAktif; if(h==='produk')ambilDataProduk(); if(h==='transaksi')ambilDataTransaksi(); if(h==='pencatatan')ambilDataLog(); tampilkanToast('Data diperbarui'); }
function terapkanFilterLog() { ambilDataLog(document.getElementById('filter-log').value); }
function perbaruiStatistik() {
    ['produk','transaksi'].forEach(k => {
        const el = document.getElementById(`stat-${k}`);
        if(el) el.textContent = (StateAplikasi.data[k] || []).length;
    });
    const s = document.getElementById('stat-stok');
    if(s) s.textContent = (StateAplikasi.data.produk||[]).reduce((a,b)=>a+(b.stok_roti||0),0);
}

function tampilkanToast(msg) {
    const t = document.getElementById('notifikasi-toast');
    if(t) {
        document.getElementById('judul-toast').textContent = 'Informasi';
        document.getElementById('pesan-toast').textContent = msg;
        t.classList.remove('translate-y-20', 'opacity-0');
        setTimeout(()=>t.classList.add('translate-y-20', 'opacity-0'),2000);
    }
}

document.addEventListener('DOMContentLoaded', () => { 
    ambilDataProduk(); 
    panggilAPI(KONFIGURASI.ENDPOINT.KESEHATAN).catch(()=>{});
});
