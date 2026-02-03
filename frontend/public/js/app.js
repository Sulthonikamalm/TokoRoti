/**
 * BreadHouse Enterprise Experience Layer
 * Version 4.1 (Registration Module)
 */

const CONFIG = {
    API_URL: '/api', 
    TIMEOUT: 8000
};

const Store = {
    state: {
        products: [],
        filter: 'Semua',
        user: { id: 0, isMember: false, role: 'Guest', discount: 0.0, name: 'Pengunjung' },
        cart: [],
        currentModalProduct: null,
        modalQty: 1
    },
    observers: [],
    
    // Actions (Reset User)
    resetApp() {
        location.reload(); 
    },

    setGuest(name) { this.state.user = { id: 0, isMember: false, role: 'Tamu', discount: 0, name: name||'Tamu' }; this.notify('all'); },
    setMember(data) { this.state.user = { id: data.id_pelanggan, isMember: true, role: data.status_member, discount: data.manfaat_member, name: data.nama }; this.notify('all'); },
    setProducts(data) { this.state.products = data; this.notify('catalogue'); },
    setFilter(cat) { this.state.filter = cat; this.notify('catalogue'); },
    
    // Cart Actions (Simplified)
    addToCart(product, qty) {
        const finalPrice = product.harga * (1 - this.state.user.discount);
        const existing = this.state.cart.find(x => x.id === product.id_produk);
        if (existing) { existing.qty += qty; existing.subtotal = existing.qty * finalPrice; } 
        else { this.state.cart.push({ id: product.id_produk, nama: product.nama_produk, harga: finalPrice, qty: qty, subtotal: qty * finalPrice, img: ImageSystem.getUrl(product.nama_produk, product.jenis_produk) }); }
        this.notify('cart');
    },
    removeFromCart(id) { this.state.cart = this.state.cart.filter(x => x.id !== id); this.notify('cart'); },
    clearCart() { this.state.cart = []; this.notify('cart'); },
    subscribe(fn) { this.observers.push(fn); },
    notify(scope) { this.observers.forEach(fn => fn(this.state, scope)); }
};

// =========================================
// UI CONTROLLERS (Identity Gate)
// =========================================
function switchGate(mode) {
    document.getElementById('phase-selection').classList.add('hidden');
    document.getElementById('phase-member').classList.add('hidden');
    document.getElementById('phase-guest').classList.add('hidden');
    document.getElementById('phase-register').classList.add('hidden');

    if(mode === 'member') {
        document.getElementById('phase-member').classList.remove('hidden');
        document.getElementById('input-telepon').focus();
    } else if (mode === 'guest') {
        document.getElementById('phase-guest').classList.remove('hidden');
        document.getElementById('input-nama-tamu').focus();
    } else if (mode === 'register') {
        document.getElementById('phase-register').classList.remove('hidden');
        document.getElementById('reg-nama').focus();
    }
}

function resetGate() {
    document.getElementById('phase-selection').classList.remove('hidden');
    document.getElementById('phase-member').classList.add('hidden');
    document.getElementById('phase-guest').classList.add('hidden');
    document.getElementById('phase-register').classList.add('hidden');
    document.getElementById('pesan-member').className = "mt-4 text-sm font-medium opacity-0";
}

function masukSebagaiTamu() {
    const nama = document.getElementById('input-nama-tamu').value.trim() || 'Tamu';
    Store.setGuest(nama);
    showTempMessage(`Selamat datang, ${nama}. Silakan memesan.`, 'text-emerald-600');
    resetGate(); 
    document.getElementById('grid-katalog').scrollIntoView({behavior: 'smooth'});
}

// =========================================
// API & BUSINESS LOGIC
// =========================================
async function initApp() {
    renderLoading();
    try {
        const res = await fetch(`${CONFIG.API_URL}/produk`);
        const json = await res.json();
        Store.setProducts(json.data || []);
    } catch (e) { document.getElementById('grid-katalog').innerHTML = `<p class="text-center p-10 text-rose-500">Gagal koneksi backend.</p>`; }
}

async function cekMember() {
    const input = document.getElementById('input-telepon');
    const btn = document.getElementById('btn-cek-member');
    if (!input.value.trim()) return input.focus();

    const oriText = btn.innerHTML; btn.innerHTML = '<i class="ph-bold ph-spinner animate-spin"></i>'; btn.disabled = true;
    try {
        const res = await fetch(`${CONFIG.API_URL}/pelanggan/cek?no_telepon=${input.value}`);
        const json = await res.json();
        if (json.sukses && json.data) {
            Store.setMember(json.data);
            showTempMessage(`Login Berhasil! Hai ${json.data.nama}.`, 'text-emerald-600');
            document.getElementById('grid-katalog').scrollIntoView({behavior: 'smooth'});
            document.getElementById('phase-member').innerHTML = `<div class="bg-emerald-50 text-emerald-700 p-3 rounded-lg text-sm font-bold text-center"><i class="ph-fill ph-check-circle"></i> Terverifikasi: ${json.data.nama}</div>`;
        } else { showTempMessage('Nomor member tidak ditemukan.', 'text-rose-500'); }
    } catch (e) { showTempMessage('Network Error.', 'text-rose-500'); }
    finally { btn.innerHTML = oriText; btn.disabled = false; }
}

async function daftarMember() {
    const nama = document.getElementById('reg-nama').value.trim();
    const telp = document.getElementById('reg-telepon').value.trim();
    const btn = document.getElementById('btn-daftar');

    if (!nama || !telp) return alert("Isi semua data!");

    const oriText = btn.innerHTML; btn.innerHTML = '<i class="ph-bold ph-spinner animate-spin"></i> Memproses...'; btn.disabled = true;

    try {
        const res = await fetch(`${CONFIG.API_URL}/pelanggan/baru`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ nama: nama, no_telepon: telp })
        });
        const json = await res.json();

        if (res.ok) {
            alert(`Registrasi Berhasil!\nSilakan login dengan nomor HP Anda: ${telp}`);
            resetGate();
            switchGate('member');
            document.getElementById('input-telepon').value = telp;
        } else {
            alert(`Gagal: ${json.pesan || 'Nomor mungkin sudah dipakai.'}`);
        }
    } catch (e) { alert("Gagal menghubungi server."); }
    finally { btn.innerHTML = oriText; btn.disabled = false; }
}

// --- Cart Logic (Same as before) ---
function bukaModalDetail(id) {
    const p = Store.state.products.find(x => x.id_produk === id);
    if(!p) return;
    Store.state.currentModalProduct = p;
    Store.state.modalQty = 1;
    updateModalUI();
    document.getElementById('modal-detail').classList.add('active');
}
function updateModalUI() {
    const p = Store.state.currentModalProduct;
    const qty = Store.state.modalQty;
    const finalPrice = p.harga * (1 - Store.state.user.discount);
    document.getElementById('modal-img').src = ImageSystem.getUrl(p.nama_produk, p.jenis_produk);
    document.getElementById('modal-title').textContent = p.nama_produk;
    document.getElementById('val-stok').textContent = p.stok_roti;
    document.getElementById('modal-qty').textContent = qty;
    document.getElementById('modal-price').textContent = formatRupiah(finalPrice * qty);
    document.getElementById('btn-tambah-keranjang').onclick = () => { Store.addToCart(p, qty); tutupModal('modal-detail'); animateCartBadge(); };
}
function ubahQty(d) {
    const p = Store.state.currentModalProduct;
    let n = Store.state.modalQty + d;
    if (n < 1) n = 1; if (n > p.stok_roti) n = p.stok_roti;
    Store.state.modalQty = n; updateModalUI();
}
function bukaKeranjang() { renderCartList(); initSwipePay(); document.getElementById('modal-keranjang').classList.add('active'); }
function renderCartList() {
    const el = document.getElementById('list-keranjang');
    const items = Store.state.cart;
    let total = 0; items.forEach(i => total += i.subtotal);
    document.getElementById('cart-total').textContent = formatRupiah(total);
    if (items.length === 0) return el.innerHTML = `<div class="text-center py-10 text-slate-400 flex flex-col items-center"><i class="ph-duotone ph-basket text-4xl mb-2"></i>Keranjang Masih Kosong</div>`;
    el.innerHTML = items.map(i => `<div class="flex items-center gap-4 bg-white p-3 rounded-xl border border-slate-100 shadow-sm"><img src="${i.img}" class="w-16 h-16 object-cover rounded-lg bg-slate-100"><div class="flex-1"><h4 class="font-bold text-slate-800 text-sm">${i.nama}</h4><p class="text-xs text-slate-500">${i.qty} x ${formatRupiah(i.harga)}</p></div><div class="text-right"><p class="font-bold text-orange-600 text-sm">${formatRupiah(i.subtotal)}</p><button onclick="Store.removeFromCart(${i.id}); renderCartList();" class="text-xs text-red-400 hover:text-red-600 mt-1 font-medium">Hapus</button></div></div>`).join('');
}
async function prosesCheckout() {
    if (Store.state.cart.length === 0) return alert("Keranjang kosong!");
    const msgEl = document.getElementById('pesan-checkout');
    msgEl.style.opacity = '1'; msgEl.textContent = 'Menghubungkan ke Kasir...';
    try {
        const res = await fetch(`${CONFIG.API_URL}/transaksi/checkout`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({ items: Store.state.cart.map(i => ({ id_produk: i.id, jumlah: i.qty, harga: i.harga })), id_pelanggan: Store.state.user.id || 0, total_bayar: Store.state.cart.reduce((a,b)=>a+b.subtotal,0) })
        });
        const json = await res.json();
        if (res.ok) {
            msgEl.textContent = `✅ ${json.pesan}`;
            msgEl.className = "text-center text-xs font-bold mt-3 text-emerald-600 transition-opacity";
            setTimeout(() => { Store.clearCart(); tutupModal('modal-keranjang'); initApp(); alert(`Terima kasih ${Store.state.user.name}!\nPesanan sedang dibuat.`); }, 1500);
        } else {
            msgEl.textContent = `❌ Gagal: ${json.pesan}`;
            msgEl.className = "text-center text-xs font-bold mt-3 text-rose-600 transition-opacity";
            resetSwipe();
        }
    } catch (e) { msgEl.textContent = `❌ Error Jaringan`; resetSwipe(); }
}

// Swipe Logic (Same)
function initSwipePay() {
    const c = document.getElementById('swipe-container'); const k = document.getElementById('swipe-knob');
    if(!c || !k) return;
    c.classList.remove('swiped'); k.style.transform = `translateX(0px)`;
    document.getElementById('pesan-checkout').style.opacity = '0';
    let isDragging=false, startX=0; const maxDrag=c.offsetWidth-k.offsetWidth-8;
    const start=(e)=>{if(Store.state.cart.length===0)return;isDragging=true;startX=(e.touches?e.touches[0].clientX:e.clientX);c.classList.add('active');};
    const move=(e)=>{if(!isDragging)return;const curr=(e.touches?e.touches[0].clientX:e.clientX);let diff=curr-startX;if(diff<0)diff=0;if(diff>maxDrag)diff=maxDrag;k.style.transform=`translateX(${diff}px)`;if(diff>maxDrag*0.85){isDragging=false;c.classList.add('swiped');k.style.transform=`translateX(0px)`;prosesCheckout();}};
    const end=()=>{if(!isDragging)return;isDragging=false;k.style.transform=`translateX(0px)`;};
    k.ontouchstart=start;k.onmousedown=start;window.ontouchmove=move;window.onmousemove=move;window.ontouchend=end;window.onmouseup=end;
}

// Renderers
Store.subscribe((state, scope) => {
    if (scope === 'all' || scope === 'catalogue') renderProducts(state);
    if (scope === 'all' || scope === 'cart') updateCartBadge(state);
    if (scope === 'all') updateUserUI(state.user);
});
function updateCartBadge(state) { const qty = state.cart.reduce((a,b)=>a+b.qty,0); const b = document.getElementById('badge-cart'); b.textContent = qty; b.classList.toggle('scale-0', qty===0); }
function animateCartBadge() { const b = document.getElementById('badge-cart'); b.classList.add('cart-counter-anim'); setTimeout(()=>b.classList.remove('cart-counter-anim'),300); }
function renderProducts(state) {
    const container = document.getElementById('grid-katalog');
    const filtered = state.filter === 'Semua' ? state.products : state.products.filter(p => (p.jenis_produk||'').includes(state.filter));
    if(filtered.length === 0 && state.products.length > 0) return container.innerHTML = `<div class="col-span-full text-center py-20 text-slate-400">Item habis.</div>`;
    container.innerHTML = filtered.map(p => {
        const finalPrice = p.harga * (1 - state.user.discount);
        return `<div class="card-product bg-white rounded-2xl overflow-hidden cursor-pointer group border border-slate-100" onclick="bukaModalDetail(${p.id_produk})"><div class="card-image-wrapper h-64 bg-slate-100 relative"><img src="${ImageSystem.getUrl(p.nama_produk, p.jenis_produk)}" class="w-full h-full object-cover" onerror="ImageSystem.handleError(this)" loading="lazy">${p.stok_roti<5?`<div class="absolute top-3 right-3 bg-rose-500 text-white px-2 py-1 rounded text-[10px] font-bold shadow-sm">Sisa ${p.stok_roti}</div>`:''}</div><div class="p-5"><h3 class="font-bold text-slate-900 text-lg mb-1 group-hover:text-orange-600 transition-colors line-clamp-1">${p.nama_produk}</h3><p class="text-xs font-bold text-slate-400 uppercase tracking-widest mb-4">${p.jenis_produk}</p><div class="flex justify-between items-center border-t border-slate-50 pt-3"><span class="text-orange-600 font-bold text-lg">${formatRupiah(finalPrice)}</span><button class="w-8 h-8 rounded-full bg-slate-50 text-slate-400 flex items-center justify-center group-hover:bg-orange-600 group-hover:text-white transition-all"><i class="ph-bold ph-plus"></i></button></div></div></div>`;
    }).join('');
}
function updateUserUI(user) {
    const el = document.getElementById('status-user'); document.getElementById('label-user').textContent = user.role==='Guest'?`Tamu: ${user.name}`:`${user.role}: ${user.name}`;
    if(user.isMember) { el.className = "hidden md:flex items-center gap-2 text-xs font-bold uppercase tracking-wide text-orange-700 bg-orange-50 px-4 py-2 rounded-full border border-orange-200"; }
    else if (user.name !== 'Pengunjung') { el.className = "hidden md:flex items-center gap-2 text-xs font-bold uppercase tracking-wide text-slate-700 bg-slate-100 px-4 py-2 rounded-full border border-slate-200"; }
}
const ImageSystem = { getUrl(n,c){return`https://images.unsplash.com/photo-${(n.includes('Donat')?'1551024709-8f23befc6f87':(n.includes('Tawar')?'1598373182133-52452f7691ef':'1509440159596-0249088772ff'))}?auto=format&fit=crop&w=600&q=80`}, handleError(i){i.src='https://placehold.co/600x400/fff7ed/ea580c?text=Fresh+Bakery'} };
const formatRupiah = (n) => new Intl.NumberFormat('id-ID', {style:'currency',currency:'IDR',minimumFractionDigits:0}).format(n);
function showTempMessage(t,c){const e=document.getElementById('pesan-member');e.textContent=t;e.className=`mt-4 text-sm font-medium opacity-100 ${c}`;setTimeout(()=>e.className="mt-4 text-sm font-medium opacity-0",3000);}
function renderLoading(){document.getElementById('grid-katalog').innerHTML='<div class="col-span-full text-center text-slate-400 py-20 animate-pulse">Memuat Katalog...</div>';}
function tutupModal(id){document.getElementById(id).classList.remove('active');}
document.addEventListener('DOMContentLoaded', initApp);
