-- ============================================================
-- BREADHOUSE BAKERY MANAGEMENT SYSTEM
-- Database Schema - MySQL / Aiven Compatible
-- ============================================================
-- 
-- Skema ini merupakan migrasi dari Tugas Besar Basis Data Semester 4
-- ke sistem web dinamis modern di Semester 6.
-- 
-- Koneksi: Mendukung TLS untuk Aiven Cloud MySQL
-- Versi: MySQL 8.0+
-- 
-- ============================================================

-- ============================================================
-- BAGIAN 1: DROP TABLES (Hapus tabel jika sudah ada)
-- Urutan disesuaikan untuk menghindari konflik foreign key
-- ============================================================

DROP TABLE IF EXISTS Pencatatan;
DROP TABLE IF EXISTS Detail_Transaksi;
DROP TABLE IF EXISTS Transaksi_Penjualan;
DROP TABLE IF EXISTS Detail_Pembelian;
DROP TABLE IF EXISTS Pembelian_Bahan_Baku;
DROP TABLE IF EXISTS Penggunaan_Bahan_Baku;
DROP TABLE IF EXISTS Detail_Resep;
DROP TABLE IF EXISTS Bahan_Baku;
DROP TABLE IF EXISTS Resep;
DROP TABLE IF EXISTS Produk_Roti;
DROP TABLE IF EXISTS Pengiriman_Produk;
DROP TABLE IF EXISTS Cabang_Penjualan;
DROP TABLE IF EXISTS Cabang_Produksi;
DROP TABLE IF EXISTS Cabang;
DROP TABLE IF EXISTS Pelanggan;
DROP TABLE IF EXISTS Keanggotaan;
DROP TABLE IF EXISTS Pemasok;

-- ============================================================
-- BAGIAN 2: TABEL DASAR DAN MASTER
-- Tabel-tabel ini merupakan fondasi sistem
-- ============================================================

-- Tabel Keanggotaan: Menyimpan level membership pelanggan
CREATE TABLE Keanggotaan (
    ID_Keanggotaan INT AUTO_INCREMENT PRIMARY KEY,
    StatusMember VARCHAR(50) NOT NULL UNIQUE,
    ManfaatMember DECIMAL(4,2) DEFAULT 0.00
);

-- Tabel Pelanggan: Data pelanggan toko roti
CREATE TABLE Pelanggan (
    ID_Pelanggan INT AUTO_INCREMENT PRIMARY KEY,
    ID_Keanggotaan INT NULL,
    Nama VARCHAR(100) NOT NULL,
    Alamat TEXT,
    No_Telepon VARCHAR(20) UNIQUE,
    Email VARCHAR(100) UNIQUE,
    FOREIGN KEY (ID_Keanggotaan) REFERENCES Keanggotaan(ID_Keanggotaan) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Tabel Cabang: Informasi cabang toko
CREATE TABLE Cabang (
    ID_Cabang INT AUTO_INCREMENT PRIMARY KEY,
    Nama_Cabang VARCHAR(100) NOT NULL UNIQUE,
    Alamat TEXT NOT NULL,
    Luas_Area DECIMAL(10,2)
);

-- Tabel Cabang Produksi: Cabang yang memiliki fasilitas produksi
CREATE TABLE Cabang_Produksi (
    ID_CabangProduk INT PRIMARY KEY,
    Dapur_Produksi BOOLEAN DEFAULT TRUE,
    Gudang_Penyimpanan BOOLEAN DEFAULT TRUE,
    Area_Penjualan BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (ID_CabangProduk) REFERENCES Cabang(ID_Cabang) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabel Cabang Penjualan: Cabang yang hanya untuk penjualan
CREATE TABLE Cabang_Penjualan (
    ID_CabangPenjualan INT PRIMARY KEY,
    Area_Penjualan BOOLEAN DEFAULT TRUE,
    Gudang_Penyimpanan BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (ID_CabangPenjualan) REFERENCES Cabang(ID_Cabang) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabel Pemasok: Data supplier bahan baku
CREATE TABLE Pemasok (
    ID_Pemasok INT AUTO_INCREMENT PRIMARY KEY,
    Nama_Pemasok VARCHAR(100) NOT NULL,
    Alamat_Pemasok TEXT
);

-- Tabel Produk Roti: Katalog produk
CREATE TABLE Produk_Roti (
    ID_Produk INT AUTO_INCREMENT PRIMARY KEY,
    Kode_Produk VARCHAR(20) NOT NULL UNIQUE,
    Nama_Produk VARCHAR(100) NOT NULL,
    Jenis_Produk VARCHAR(50),
    Harga DECIMAL(10, 2) NOT NULL,
    Stok_Roti INT DEFAULT 0
);

-- ============================================================
-- BAGIAN 3: TABEL RESEP DAN BAHAN BAKU
-- Struktur untuk manajemen resep pembuatan roti
-- ============================================================

-- Tabel Resep: Resep untuk setiap produk
CREATE TABLE Resep (
    ID_Resep INT AUTO_INCREMENT PRIMARY KEY,
    ID_Produk INT NOT NULL UNIQUE,
    Nama_Resep VARCHAR(100) NOT NULL,
    Cara_Pembuatan TEXT,
    FOREIGN KEY (ID_Produk) REFERENCES Produk_Roti(ID_Produk) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabel Bahan Baku: Inventaris bahan baku
CREATE TABLE Bahan_Baku (
    ID_BahanBaku INT AUTO_INCREMENT PRIMARY KEY,
    Kode_BahanBaku VARCHAR(20) NOT NULL UNIQUE,
    Nama_Bahan_Baku VARCHAR(100) NOT NULL,
    JumlahStok DECIMAL(10, 2) DEFAULT 0,
    Satuan_Bahan VARCHAR(20) NOT NULL
);

-- Tabel Detail Resep: Relasi many-to-many antara Resep dan Bahan Baku
CREATE TABLE Detail_Resep (
    ID_Detail_Resep INT AUTO_INCREMENT PRIMARY KEY,
    ID_Resep INT NOT NULL,
    ID_BahanBaku INT NOT NULL,
    Jumlah_Bahan_Dibutuhkan DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (ID_Resep) REFERENCES Resep(ID_Resep) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ID_BahanBaku) REFERENCES Bahan_Baku(ID_BahanBaku) ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE KEY (ID_Resep, ID_BahanBaku)
);

-- ============================================================
-- BAGIAN 4: TABEL TRANSAKSIONAL
-- Tabel untuk mencatat transaksi bisnis
-- ============================================================

-- Tabel Transaksi Penjualan: Header transaksi penjualan
CREATE TABLE Transaksi_Penjualan (
    ID_Transaksi_Penjualan INT AUTO_INCREMENT PRIMARY KEY,
    ID_Pelanggan INT NULL,
    ID_Cabang INT NOT NULL,
    Tanggal_Transaksi DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Total_Harga DECIMAL(12, 2) NOT NULL DEFAULT 0,
    FOREIGN KEY (ID_Pelanggan) REFERENCES Pelanggan(ID_Pelanggan) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (ID_Cabang) REFERENCES Cabang(ID_Cabang) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Tabel Detail Transaksi: Item-item dalam transaksi
CREATE TABLE Detail_Transaksi (
    ID_Detail_Transaksi INT AUTO_INCREMENT PRIMARY KEY,
    ID_Transaksi_Penjualan INT NOT NULL,
    ID_Produk INT NOT NULL,
    Quantity INT NOT NULL,
    Total_Harga DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (ID_Transaksi_Penjualan) REFERENCES Transaksi_Penjualan(ID_Transaksi_Penjualan) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ID_Produk) REFERENCES Produk_Roti(ID_Produk) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Tabel Pembelian Bahan Baku: Transaksi pembelian dari pemasok
CREATE TABLE Pembelian_Bahan_Baku (
    ID_Pembelian INT AUTO_INCREMENT PRIMARY KEY,
    ID_Cabang INT NOT NULL,
    ID_Pemasok INT NOT NULL,
    Tanggal_Pembelian DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Total_Harga DECIMAL(12, 2) DEFAULT 0.00,
    FOREIGN KEY (ID_Cabang) REFERENCES Cabang_Produksi(ID_CabangProduk) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (ID_Pemasok) REFERENCES Pemasok(ID_Pemasok) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Tabel Detail Pembelian: Item dalam transaksi pembelian
CREATE TABLE Detail_Pembelian (
    ID_DetailPembelian INT AUTO_INCREMENT PRIMARY KEY,
    ID_Pembelian INT NOT NULL,
    ID_BahanBaku INT NOT NULL,
    Jumlah_Dibeli DECIMAL(10, 2) NOT NULL,
    Harga_Satuan DECIMAL(10, 2) NOT NULL,
    Total_Harga DECIMAL(12, 2) AS (Jumlah_Dibeli * Harga_Satuan) STORED,
    FOREIGN KEY (ID_Pembelian) REFERENCES Pembelian_Bahan_Baku(ID_Pembelian) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ID_BahanBaku) REFERENCES Bahan_Baku(ID_BahanBaku) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Tabel Penggunaan Bahan Baku: Pencatatan penggunaan bahan
CREATE TABLE Penggunaan_Bahan_Baku (
    ID_Penggunaan INT AUTO_INCREMENT PRIMARY KEY,
    ID_BahanBaku INT NOT NULL,
    ID_Cabang INT NOT NULL,
    Tanggal_Penggunaan DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Jumlah_Bahan_Digunakan DECIMAL(10, 2) NOT NULL,
    ID_Produk_Yang_Dibuat INT NULL,
    FOREIGN KEY (ID_BahanBaku) REFERENCES Bahan_Baku(ID_BahanBaku) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (ID_Cabang) REFERENCES Cabang_Produksi(ID_CabangProduk) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (ID_Produk_Yang_Dibuat) REFERENCES Produk_Roti(ID_Produk) ON DELETE SET NULL ON UPDATE CASCADE
);

-- Tabel Pengiriman Produk: Distribusi produk antar cabang
CREATE TABLE Pengiriman_Produk (
    ID_Pengiriman INT AUTO_INCREMENT PRIMARY KEY,
    ID_CabangProduk INT NOT NULL,
    ID_CabangPenjualan INT NOT NULL,
    ID_Produk INT NOT NULL,
    Tanggal_Pengiriman DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Jumlah_Produk INT NOT NULL,
    FOREIGN KEY (ID_CabangProduk) REFERENCES Cabang_Produksi(ID_CabangProduk) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (ID_CabangPenjualan) REFERENCES Cabang_Penjualan(ID_CabangPenjualan) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (ID_Produk) REFERENCES Produk_Roti(ID_Produk) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ============================================================
-- BAGIAN 5: TABEL PENCATATAN (AUDIT LOG)
-- Tabel untuk mencatat seluruh aktivitas sistem
-- ============================================================

CREATE TABLE Pencatatan (
    ID_Pencatatan BIGINT AUTO_INCREMENT PRIMARY KEY,
    ID_Cabang INT NULL,
    ID_Transaksi_Penjualan INT NULL,
    ID_Pembelian_BahanBaku INT NULL,
    ID_Pengiriman INT NULL,
    Tanggal_Pencatatan DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ID_Cabang) REFERENCES Cabang(ID_Cabang) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (ID_Transaksi_Penjualan) REFERENCES Transaksi_Penjualan(ID_Transaksi_Penjualan) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (ID_Pembelian_BahanBaku) REFERENCES Pembelian_Bahan_Baku(ID_Pembelian) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (ID_Pengiriman) REFERENCES Pengiriman_Produk(ID_Pengiriman) ON DELETE SET NULL ON UPDATE CASCADE
);

-- ============================================================
-- BAGIAN 6: DATA SAMPLE
-- Data contoh untuk testing dan demonstrasi
-- ============================================================

-- 1. Data Keanggotaan
INSERT INTO Keanggotaan (ID_Keanggotaan, StatusMember, ManfaatMember) VALUES
(1001, 'Regular', 0.00),
(1002, 'Silver', 0.10),
(1003, 'Gold', 0.15),
(1004, 'Diamond', 0.25);

-- 2. Data Pelanggan
INSERT INTO Pelanggan (ID_Pelanggan, ID_Keanggotaan, Nama, Alamat, No_Telepon, Email) VALUES
(2001, NULL, 'Budi Santoso', 'Jl. Merdeka No. 123, Jakarta', '081234567890', 'budi@example.com'),
(2002, 1002, 'Siti Rahayu', 'Jl. Pahlawan No. 45, Bandung', '082345678901', 'siti@example.com'),
(2003, 1003, 'Ahmad Hidayat', 'Jl. Diponegoro No. 67, Surabaya', '083456789012', 'ahmad@example.com'),
(2004, 1004, 'Dewi Sulistiawati', 'Jl. Gajah Mada No. 89, Semarang', '084567890123', 'dewi@example.com'),
(2005, NULL, 'Joko Widodo', 'Jl. Veteran No. 101, Solo', '085678901234', 'joko@example.com'),
(2006, 1002, 'Ani Yudhoyono', 'Jl. Sudirman No. 202, Jakarta', '086789012345', 'ani@example.com'),
(2007, NULL, 'Rizki Pratama', 'Jl. Ahmad Yani No. 303, Medan', '087890123456', 'rizki@example.com'),
(2008, 1003, 'Nina Sari', 'Jl. Pemuda No. 404, Yogyakarta', '088901234567', 'nina@example.com'),
(2009, NULL, 'Dodi Irawan', 'Jl. Hayam Wuruk No. 505, Bali', '089012345678', 'dodi@example.com'),
(2010, 1002, 'Lisa Permata', 'Jl. Thamrin No. 606, Jakarta', '081123456789', 'lisa@example.com');

-- 3. Data Cabang
INSERT INTO Cabang (ID_Cabang, Nama_Cabang, Alamat, Luas_Area) VALUES
(3001, 'BreadHouse Central', 'Jl. Gatot Subroto No. 123, Jakarta Selatan', 250.00),
(3002, 'BreadHouse Bandung', 'Jl. Asia Afrika No. 456, Bandung', 180.00),
(3003, 'BreadHouse Surabaya', 'Jl. Tunjungan No. 789, Surabaya', 220.00),
(3004, 'BreadHouse Outlet Mall', 'Mall Kota Kasablanka Lt. 3, Jakarta', 120.00),
(3005, 'BreadHouse Express', 'Terminal Pulogebang, Jakarta Timur', 80.00);

-- 4. Data Cabang Produksi
INSERT INTO Cabang_Produksi (ID_CabangProduk, Dapur_Produksi, Gudang_Penyimpanan, Area_Penjualan) VALUES
(3001, TRUE, TRUE, TRUE),
(3002, TRUE, TRUE, TRUE),
(3003, TRUE, TRUE, TRUE);

-- 5. Data Cabang Penjualan
INSERT INTO Cabang_Penjualan (ID_CabangPenjualan, Area_Penjualan, Gudang_Penyimpanan) VALUES
(3004, TRUE, TRUE),
(3005, TRUE, FALSE);

-- 6. Data Pemasok
INSERT INTO Pemasok (ID_Pemasok, Nama_Pemasok, Alamat_Pemasok) VALUES
(4001, 'PT Tepung Sejahtera', 'Jl. Industri No. 123, Bekasi'),
(4002, 'CV Gula Manis', 'Jl. Pabrik No. 456, Tangerang'),
(4003, 'PT Telur Prima', 'Jl. Peternakan No. 789, Bogor'),
(4004, 'CV Dairy Fresh', 'Jl. Susu No. 101, Lembang'),
(4005, 'PT Cokelat Nikmat', 'Jl. Kakao No. 202, Malang');

-- 7. Data Produk Roti
INSERT INTO Produk_Roti (ID_Produk, Kode_Produk, Nama_Produk, Jenis_Produk, Harga, Stok_Roti) VALUES
(5001, 'RTI-20230001', 'Roti Tawar Original', 'Roti Tawar', 15000.00, 50),
(5002, 'RTI-20230002', 'Roti Gandum', 'Roti Tawar', 18000.00, 40),
(5003, 'DNS-20230001', 'Donat Cokelat', 'Donat', 8000.00, 75),
(5004, 'DNS-20230002', 'Donat Stroberi', 'Donat', 8000.00, 60),
(5005, 'DNS-20230003', 'Donat Vanilla', 'Donat', 7500.00, 65),
(5006, 'CRS-20230001', 'Croissant Plain', 'Pastry', 12000.00, 45),
(5007, 'CRS-20230002', 'Croissant Almond', 'Pastry', 15000.00, 35),
(5008, 'BGL-20230001', 'Bagel Sesame', 'Bagel', 10000.00, 30),
(5009, 'BGL-20230002', 'Bagel Garlic', 'Bagel', 11000.00, 25),
(5010, 'CKE-20230001', 'Red Velvet Cake', 'Kue', 25000.00, 20),
(5011, 'CKE-20230002', 'Choco Lava Cake', 'Kue', 22000.00, 15),
(5012, 'BRD-20230001', 'Bread Pudding', 'Pudding', 20000.00, 25);

-- 8. Data Resep
INSERT INTO Resep (ID_Resep, ID_Produk, Nama_Resep, Cara_Pembuatan) VALUES
(6001, 5001, 'Resep Roti Tawar', 'Campurkan tepung, air, ragi, garam, dan gula. Aduk hingga kalis. Diamkan 1 jam, panggang 30 menit pada suhu 180°C.'),
(6002, 5002, 'Resep Roti Gandum', 'Campurkan tepung gandum, air, ragi, garam, dan madu. Aduk hingga kalis. Diamkan 1 jam, panggang 35 menit pada suhu 180°C.'),
(6003, 5003, 'Resep Donat Cokelat', 'Campurkan tepung, susu, ragi, gula, dan telur. Aduk hingga kalis. Diamkan 30 menit, goreng hingga keemasan, celupkan ke glaze cokelat.'),
(6004, 5004, 'Resep Donat Stroberi', 'Campurkan tepung, susu, ragi, gula, dan telur. Aduk hingga kalis. Diamkan 30 menit, goreng hingga keemasan, celupkan ke glaze stroberi.'),
(6005, 5005, 'Resep Donat Vanilla', 'Campurkan tepung, susu, ragi, gula, dan telur. Aduk hingga kalis. Diamkan 30 menit, goreng hingga keemasan, celupkan ke glaze vanilla.'),
(6006, 5006, 'Resep Croissant Plain', 'Campurkan tepung, air, ragi, garam, dan gula. Lapisi dengan mentega. Lipat dan giling berulang kali. Panggang 25 menit pada suhu 190°C.'),
(6007, 5007, 'Resep Croissant Almond', 'Campurkan tepung, air, ragi, garam, dan gula. Lapisi dengan mentega. Lipat dan giling berulang kali. Taburi dengan almond. Panggang 25 menit pada suhu 190°C.'),
(6008, 5008, 'Resep Bagel Sesame', 'Campurkan tepung, air, ragi, garam, dan madu. Bentuk melingkar dengan lubang di tengah. Rebus sebentar, taburi wijen, panggang 20 menit pada suhu 200°C.'),
(6009, 5009, 'Resep Bagel Garlic', 'Campurkan tepung, air, ragi, garam, dan madu. Bentuk melingkar dengan lubang di tengah. Rebus sebentar, taburi bawang putih, panggang 20 menit pada suhu 200°C.'),
(6010, 5010, 'Resep Red Velvet Cake', 'Campurkan tepung, gula, cokelat, pewarna merah, telur, dan mentega. Panggang 45 menit pada suhu 175°C. Lapisi dengan cream cheese frosting.'),
(6011, 5011, 'Resep Choco Lava Cake', 'Campurkan tepung, cokelat, telur, gula, dan mentega. Panggang 15 menit pada suhu 200°C hingga bagian luar matang dan bagian dalam lembut.'),
(6012, 5012, 'Resep Bread Pudding', 'Potong roti tawar menjadi dadu. Rendam dalam campuran susu, telur, gula, dan kayu manis. Panggang 35 menit pada suhu 160°C.');

-- 9. Data Bahan Baku
INSERT INTO Bahan_Baku (ID_BahanBaku, Kode_BahanBaku, Nama_Bahan_Baku, JumlahStok, Satuan_Bahan) VALUES
(7001, 'TPG-001', 'Tepung Terigu', 500.00, 'kg'),
(7002, 'TPG-002', 'Tepung Gandum', 300.00, 'kg'),
(7003, 'GLA-001', 'Gula Pasir', 250.00, 'kg'),
(7004, 'TLR-001', 'Telur Ayam', 1000.00, 'butir'),
(7005, 'MNT-001', 'Mentega', 150.00, 'kg'),
(7006, 'SSU-001', 'Susu Cair', 300.00, 'liter'),
(7007, 'SSU-002', 'Susu Bubuk', 100.00, 'kg'),
(7008, 'CKL-001', 'Cokelat Batang', 80.00, 'kg'),
(7009, 'CKL-002', 'Cokelat Bubuk', 50.00, 'kg'),
(7010, 'RGI-001', 'Ragi Instan', 30.00, 'kg'),
(7011, 'GRM-001', 'Garam', 40.00, 'kg'),
(7012, 'STR-001', 'Pasta Stroberi', 25.00, 'kg'),
(7013, 'VNL-001', 'Pasta Vanilla', 20.00, 'kg'),
(7014, 'ALM-001', 'Almond Slice', 15.00, 'kg'),
(7015, 'WJN-001', 'Biji Wijen', 10.00, 'kg'),
(7016, 'BWP-001', 'Bawang Putih Bubuk', 5.00, 'kg'),
(7017, 'MDU-001', 'Madu', 20.00, 'kg'),
(7018, 'PRM-001', 'Pewarna Makanan Merah', 5.00, 'liter'),
(7019, 'CRM-001', 'Cream Cheese', 30.00, 'kg'),
(7020, 'KYM-001', 'Kayu Manis', 8.00, 'kg');

-- 10. Data Detail Resep
INSERT INTO Detail_Resep (ID_Detail_Resep, ID_Resep, ID_BahanBaku, Jumlah_Bahan_Dibutuhkan) VALUES
-- Resep Roti Tawar Original (ID_Resep: 6001)
(8001, 6001, 7001, 1.00),
(8002, 6001, 7003, 0.10),
(8003, 6001, 7010, 0.02),
(8004, 6001, 7011, 0.01),
(8005, 6001, 7005, 0.10),
-- Resep Roti Gandum (ID_Resep: 6002)
(8006, 6002, 7002, 1.00),
(8007, 6002, 7017, 0.10),
(8008, 6002, 7010, 0.02),
(8009, 6002, 7011, 0.01),
(8010, 6002, 7005, 0.10),
-- Resep Donat Cokelat (ID_Resep: 6003)
(8011, 6003, 7001, 0.50),
(8012, 6003, 7003, 0.15),
(8013, 6003, 7010, 0.01),
(8014, 6003, 7004, 4.00),
(8015, 6003, 7005, 0.10),
(8016, 6003, 7006, 0.20),
(8017, 6003, 7008, 0.15),
-- Resep Donat Stroberi (ID_Resep: 6004)
(8018, 6004, 7001, 0.50),
(8019, 6004, 7003, 0.15),
(8020, 6004, 7010, 0.01),
(8021, 6004, 7004, 4.00),
(8022, 6004, 7005, 0.10),
(8023, 6004, 7006, 0.20),
(8024, 6004, 7012, 0.10),
-- Resep Donat Vanilla (ID_Resep: 6005)
(8025, 6005, 7001, 0.50),
(8026, 6005, 7003, 0.15),
(8027, 6005, 7010, 0.01),
(8028, 6005, 7004, 4.00),
(8029, 6005, 7005, 0.10),
(8030, 6005, 7006, 0.20),
(8031, 6005, 7013, 0.08),
-- Croissant Plain (ID_Resep: 6006)
(8032, 6006, 7001, 0.70),
(8033, 6006, 7005, 0.30),
(8034, 6006, 7010, 0.02),
-- Croissant Almond (ID_Resep: 6007)
(8035, 6007, 7001, 0.70),
(8036, 6007, 7005, 0.30),
(8037, 6007, 7014, 0.15),
-- Red Velvet Cake (ID_Resep: 6010)
(8038, 6010, 7001, 0.50),
(8039, 6010, 7003, 0.40),
(8040, 6010, 7009, 0.10),
(8041, 6010, 7018, 0.03),
(8042, 6010, 7019, 0.25);

-- 11. Data Pembelian Bahan Baku
INSERT INTO Pembelian_Bahan_Baku (ID_Pembelian, ID_Cabang, ID_Pemasok, Tanggal_Pembelian, Total_Harga) VALUES
(9001, 3001, 4001, '2023-05-01 08:30:00', 5000000.00),
(9002, 3001, 4003, '2023-05-02 09:15:00', 3000000.00),
(9003, 3002, 4002, '2023-05-03 10:00:00', 2500000.00),
(9004, 3003, 4001, '2023-05-04 11:30:00', 4500000.00),
(9005, 3001, 4004, '2023-05-05 13:45:00', 1800000.00),
(9006, 3002, 4005, '2023-05-06 14:30:00', 3200000.00),
(9007, 3003, 4003, '2023-05-07 09:00:00', 2700000.00),
(9008, 3001, 4002, '2023-05-08 10:15:00', 1500000.00);

-- 12. Data Detail Pembelian
INSERT INTO Detail_Pembelian (ID_DetailPembelian, ID_Pembelian, ID_BahanBaku, Jumlah_Dibeli, Harga_Satuan) VALUES
(10001, 9001, 7001, 200.00, 15000.00),
(10002, 9001, 7002, 100.00, 20000.00),
(10003, 9002, 7004, 500.00, 2000.00),
(10004, 9002, 7010, 10.00, 100000.00),
(10005, 9003, 7003, 100.00, 15000.00),
(10006, 9003, 7011, 20.00, 10000.00),
(10007, 9003, 7017, 10.00, 80000.00),
(10008, 9004, 7001, 150.00, 15000.00),
(10009, 9004, 7005, 50.00, 30000.00),
(10010, 9004, 7006, 100.00, 15000.00),
(10011, 9005, 7006, 80.00, 15000.00),
(10012, 9005, 7007, 30.00, 20000.00),
(10013, 9006, 7008, 30.00, 80000.00),
(10014, 9006, 7009, 20.00, 60000.00),
(10015, 9007, 7004, 400.00, 2000.00),
(10016, 9007, 7019, 15.00, 100000.00),
(10017, 9008, 7012, 10.00, 60000.00),
(10018, 9008, 7013, 8.00, 70000.00),
(10019, 9008, 7014, 5.00, 120000.00);

-- 13. Data Penggunaan Bahan Baku
INSERT INTO Penggunaan_Bahan_Baku (ID_Penggunaan, ID_BahanBaku, ID_Cabang, Tanggal_Penggunaan, Jumlah_Bahan_Digunakan, ID_Produk_Yang_Dibuat) VALUES
(11001, 7001, 3001, '2023-05-10 07:00:00', 10.00, 5001),
(11002, 7003, 3001, '2023-05-10 07:00:00', 1.00, 5001),
(11003, 7010, 3001, '2023-05-10 07:00:00', 0.20, 5001),
(11004, 7001, 3002, '2023-05-10 08:00:00', 5.00, 5003),
(11005, 7003, 3002, '2023-05-10 08:00:00', 1.50, 5003),
(11006, 7004, 3002, '2023-05-10 08:00:00', 40.00, 5003),
(11007, 7008, 3002, '2023-05-10 08:00:00', 1.50, 5003),
(11008, 7001, 3003, '2023-05-10 09:00:00', 7.00, 5007),
(11009, 7005, 3003, '2023-05-10 09:00:00', 3.00, 5007),
(11010, 7014, 3003, '2023-05-10 09:00:00', 1.50, 5007),
(11011, 7001, 3001, '2023-05-11 07:30:00', 5.00, 5010),
(11012, 7003, 3001, '2023-05-11 07:30:00', 4.00, 5010),
(11013, 7009, 3001, '2023-05-11 07:30:00', 1.00, 5010),
(11014, 7018, 3001, '2023-05-11 07:30:00', 0.30, 5010),
(11015, 7019, 3001, '2023-05-11 07:30:00', 2.50, 5010);

-- 14. Data Pengiriman Produk
INSERT INTO Pengiriman_Produk (ID_Pengiriman, ID_CabangProduk, ID_CabangPenjualan, ID_Produk, Tanggal_Pengiriman, Jumlah_Produk) VALUES
(12001, 3001, 3004, 5001, '2023-05-12 06:00:00', 20),
(12002, 3001, 3004, 5002, '2023-05-12 06:00:00', 15),
(12003, 3002, 3004, 5003, '2023-05-12 07:30:00', 30),
(12004, 3002, 3004, 5004, '2023-05-12 07:30:00', 25),
(12005, 3003, 3005, 5006, '2023-05-12 08:45:00', 20),
(12006, 3003, 3005, 5007, '2023-05-12 08:45:00', 15),
(12007, 3001, 3005, 5010, '2023-05-13 06:30:00', 10),
(12008, 3001, 3005, 5011, '2023-05-13 06:30:00', 8),
(12009, 3002, 3004, 5005, '2023-05-13 07:15:00', 30),
(12010, 3001, 3004, 5012, '2023-05-13 08:00:00', 15);

-- 15. Data Transaksi Penjualan
INSERT INTO Transaksi_Penjualan (ID_Transaksi_Penjualan, ID_Pelanggan, ID_Cabang, Tanggal_Transaksi, Total_Harga) VALUES
(13001, 2002, 3001, '2023-05-15 10:30:00', 43200.00),
(13002, NULL, 3001, '2023-05-15 11:45:00', 38000.00),
(13003, 2003, 3002, '2023-05-15 13:20:00', 51000.00),
(13004, 2001, 3003, '2023-05-15 14:35:00', 30000.00),
(13005, 2004, 3004, '2023-05-16 09:15:00', 33750.00),
(13006, NULL, 3004, '2023-05-16 10:30:00', 24000.00),
(13007, 2006, 3005, '2023-05-16 12:45:00', 32400.00),
(13008, 2008, 3001, '2023-05-16 15:20:00', 61200.00),
(13009, NULL, 3002, '2023-05-17 09:45:00', 15000.00),
(13010, 2010, 3003, '2023-05-17 11:10:00', 25200.00),
(13011, NULL, 3004, '2023-05-17 13:30:00', 30000.00),
(13012, 2004, 3005, '2023-05-17 16:15:00', 33750.00);

-- 16. Data Detail Transaksi
INSERT INTO Detail_Transaksi (ID_Detail_Transaksi, ID_Transaksi_Penjualan, ID_Produk, Quantity, Total_Harga) VALUES
(14001, 13001, 5001, 2, 27000.00),
(14002, 13001, 5003, 2, 14400.00),
(14003, 13001, 5006, 1, 10800.00),
(14004, 13002, 5003, 3, 24000.00),
(14005, 13002, 5005, 2, 15000.00),
(14006, 13003, 5002, 2, 30600.00),
(14007, 13003, 5007, 1, 12750.00),
(14008, 13003, 5008, 1, 8500.00),
(14009, 13004, 5001, 2, 30000.00),
(14010, 13005, 5010, 1, 18750.00),
(14011, 13005, 5011, 1, 16500.00),
(14012, 13006, 5003, 3, 24000.00),
(14013, 13007, 5006, 3, 32400.00),
(14014, 13008, 5002, 2, 30600.00),
(14015, 13008, 5010, 1, 21250.00),
(14016, 13008, 5008, 1, 8500.00),
(14017, 13009, 5001, 1, 15000.00),
(14018, 13010, 5007, 1, 13500.00),
(14019, 13010, 5009, 1, 9900.00),
(14020, 13010, 5003, 1, 7200.00),
(14021, 13011, 5001, 2, 30000.00),
(14022, 13012, 5010, 1, 18750.00),
(14023, 13012, 5011, 1, 16500.00);

-- 17. Data Pencatatan (Audit Log)
INSERT INTO Pencatatan (ID_Pencatatan, ID_Cabang, ID_Transaksi_Penjualan, ID_Pembelian_BahanBaku, ID_Pengiriman, Tanggal_Pencatatan) VALUES
-- Pencatatan untuk Pembelian Bahan Baku
(15001, 3001, NULL, 9001, NULL, '2023-05-01 08:30:00'),
(15002, 3001, NULL, 9002, NULL, '2023-05-02 09:15:00'),
(15003, 3002, NULL, 9003, NULL, '2023-05-03 10:00:00'),
(15004, 3003, NULL, 9004, NULL, '2023-05-04 11:30:00'),
(15005, 3001, NULL, 9005, NULL, '2023-05-05 13:45:00'),
(15006, 3002, NULL, 9006, NULL, '2023-05-06 14:30:00'),
(15007, 3003, NULL, 9007, NULL, '2023-05-07 09:00:00'),
(15008, 3001, NULL, 9008, NULL, '2023-05-08 10:15:00'),
-- Pencatatan untuk Pengiriman Produk
(15009, 3001, NULL, NULL, 12001, '2023-05-12 06:00:00'),
(15010, 3001, NULL, NULL, 12002, '2023-05-12 06:00:00'),
(15011, 3002, NULL, NULL, 12003, '2023-05-12 07:30:00'),
(15012, 3002, NULL, NULL, 12004, '2023-05-12 07:30:00'),
(15013, 3003, NULL, NULL, 12005, '2023-05-12 08:45:00'),
(15014, 3003, NULL, NULL, 12006, '2023-05-12 08:45:00'),
(15015, 3001, NULL, NULL, 12007, '2023-05-13 06:30:00'),
(15016, 3001, NULL, NULL, 12008, '2023-05-13 06:30:00'),
(15017, 3002, NULL, NULL, 12009, '2023-05-13 07:15:00'),
(15018, 3001, NULL, NULL, 12010, '2023-05-13 08:00:00'),
-- Pencatatan untuk Transaksi Penjualan
(15019, 3001, 13001, NULL, NULL, '2023-05-15 10:30:00'),
(15020, 3001, 13002, NULL, NULL, '2023-05-15 11:45:00'),
(15021, 3002, 13003, NULL, NULL, '2023-05-15 13:20:00'),
(15022, 3003, 13004, NULL, NULL, '2023-05-15 14:35:00'),
(15023, 3004, 13005, NULL, NULL, '2023-05-16 09:15:00'),
(15024, 3004, 13006, NULL, NULL, '2023-05-16 10:30:00'),
(15025, 3005, 13007, NULL, NULL, '2023-05-16 12:45:00'),
(15026, 3001, 13008, NULL, NULL, '2023-05-16 15:20:00'),
(15027, 3002, 13009, NULL, NULL, '2023-05-17 09:45:00'),
(15028, 3003, 13010, NULL, NULL, '2023-05-17 11:10:00'),
(15029, 3004, 13011, NULL, NULL, '2023-05-17 13:30:00'),
(15030, 3005, 13012, NULL, NULL, '2023-05-17 16:15:00');

-- ============================================================
-- END OF SCHEMA
-- ============================================================
