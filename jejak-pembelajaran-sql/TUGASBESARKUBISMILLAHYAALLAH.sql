-- tugasbesarbismillah-- Hapus tabel jika sudah ada (urutan disesuaikan untuk foreign key constraints)
/*
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
DROP TABLE IF EXISTS pemasok;
*/
-- TABEL DASAR DAN MASTER
CREATE TABLE Keanggotaan (
    ID_Keanggotaan INT AUTO_INCREMENT PRIMARY KEY,
    StatusMember VARCHAR(50) NOT NULL UNIQUE,
    ManfaatMember DECIMAL(4,2) DEFAULT 0.00
);

CREATE TABLE Pelanggan (
    ID_Pelanggan INT AUTO_INCREMENT PRIMARY KEY,
    ID_Keanggotaan INT NULL,
    Nama VARCHAR(100) NOT NULL,
    Alamat TEXT,
    No_Telepon VARCHAR(20) UNIQUE,
    Email VARCHAR(100) UNIQUE,
    FOREIGN KEY (ID_Keanggotaan) REFERENCES Keanggotaan(ID_Keanggotaan) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE Cabang (
    ID_Cabang INT AUTO_INCREMENT PRIMARY KEY,
    Nama_Cabang VARCHAR(100) NOT NULL UNIQUE,
    Alamat TEXT NOT NULL,
    Luas_Area DECIMAL(10,2)
);

CREATE TABLE Cabang_Produksi (
    ID_CabangProduk INT PRIMARY KEY,
    Dapur_Produksi BOOLEAN DEFAULT TRUE,
    Gudang_Penyimpanan BOOLEAN DEFAULT TRUE,
    Area_Penjualan BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (ID_CabangProduk) REFERENCES Cabang(ID_Cabang) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Cabang_Penjualan (
    ID_CabangPenjualan INT PRIMARY KEY,
    Area_Penjualan BOOLEAN DEFAULT TRUE,
    Gudang_Penyimpanan BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (ID_CabangPenjualan) REFERENCES Cabang(ID_Cabang) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Pemasok (
    ID_Pemasok INT AUTO_INCREMENT PRIMARY KEY,
    Nama_Pemasok VARCHAR(100) NOT NULL,
    Alamat_Pemasok TEXT
);

CREATE TABLE Produk_Roti (
    ID_Produk INT AUTO_INCREMENT PRIMARY KEY,
    Kode_Produk VARCHAR(20) NOT NULL UNIQUE,
    Nama_Produk VARCHAR(100) NOT NULL,
    Jenis_Produk VARCHAR(50),
    Harga DECIMAL(10, 2) NOT NULL,
    Stok_Roti INT DEFAULT 0
);

-- Tabel Resep yang sudah diperbaiki
CREATE TABLE Resep (
    ID_Resep INT AUTO_INCREMENT PRIMARY KEY,
    ID_Produk INT NOT NULL UNIQUE,
    Nama_Resep VARCHAR(100) NOT NULL,
    Cara_Pembuatan TEXT,
    FOREIGN KEY (ID_Produk) REFERENCES Produk_Roti(ID_Produk) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabel Bahan Baku yang diperbaiki, menghilangkan ID_Resep
CREATE TABLE Bahan_Baku (
    ID_BahanBaku INT AUTO_INCREMENT PRIMARY KEY,
    Kode_BahanBaku VARCHAR(20) NOT NULL UNIQUE,
    Nama_Bahan_Baku VARCHAR(100) NOT NULL,
    JumlahStok DECIMAL(10, 2) DEFAULT 0,
    Satuan_Bahan VARCHAR(20) NOT NULL
);

-- Tabel Detail_Resep baru untuk menghubungkan Resep dan Bahan Baku
CREATE TABLE Detail_Resep (
    ID_Detail_Resep INT AUTO_INCREMENT PRIMARY KEY,
    ID_Resep INT NOT NULL,
    ID_BahanBaku INT NOT NULL,
    Jumlah_Bahan_Dibutuhkan DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (ID_Resep) REFERENCES Resep(ID_Resep) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ID_BahanBaku) REFERENCES Bahan_Baku(ID_BahanBaku) ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE KEY (ID_Resep, ID_BahanBaku)
);

-- TABEL TRANSAKSIONAL
CREATE TABLE Transaksi_Penjualan (
    ID_Transaksi_Penjualan INT AUTO_INCREMENT PRIMARY KEY,
    ID_Pelanggan INT NULL,
    ID_Cabang INT NOT NULL,
    Tanggal_Transaksi DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Total_Harga DECIMAL(12, 2) NOT NULL DEFAULT 0,
    FOREIGN KEY (ID_Pelanggan) REFERENCES Pelanggan(ID_Pelanggan) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (ID_Cabang) REFERENCES Cabang(ID_Cabang) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Detail_Transaksi (
    ID_Detail_Transaksi INT AUTO_INCREMENT PRIMARY KEY,
    ID_Transaksi_Penjualan INT NOT NULL,
    ID_Produk INT NOT NULL,
    Quantity INT NOT NULL,
    Total_Harga DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (ID_Transaksi_Penjualan) REFERENCES Transaksi_Penjualan(ID_Transaksi_Penjualan) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ID_Produk) REFERENCES Produk_Roti(ID_Produk) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Pembelian_Bahan_Baku (
    ID_Pembelian INT AUTO_INCREMENT PRIMARY KEY,
    ID_Cabang INT NOT NULL,
    ID_Pemasok INT NOT NULL,
    Tanggal_Pembelian DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Total_Harga DECIMAL(12, 2) DEFAULT 0.00,
    FOREIGN KEY (ID_Cabang) REFERENCES Cabang_Produksi(ID_CabangProduk) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (ID_Pemasok) REFERENCES Pemasok(ID_Pemasok) ON DELETE RESTRICT ON UPDATE CASCADE
);

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



-- MENGISI DATA UNTUK SISTEM MANAJEMEN TOKO ROTI

-- 1. Data Keanggotaan
INSERT INTO Keanggotaan (ID_Keanggotaan, StatusMember, ManfaatMember) VALUES
(1001, 'Regular', 0.00),
(1002, 'Silver', 0.10),
(1003, 'Gold', 0.15),
(1004, 'Diamond', 0.25);

-- 2. Data Pelanggan
INSERT INTO Pelanggan (ID_Pelanggan, ID_Keanggotaan, Nama, Alamat, No_Telepon, Email) VALUES
(2001, 1001, 'Budi Santoso', 'Jl. Merdeka No. 123, Jakarta', '081234567890', 'budi@example.com'),
(2002, 1002, 'Siti Rahayu', 'Jl. Pahlawan No. 45, Bandung', '082345678901', 'siti@example.com'),
(2003, 1003, 'Ahmad Hidayat', 'Jl. Diponegoro No. 67, Surabaya', '083456789012', 'ahmad@example.com'),
(2004, 1004, 'Dewi Sulistiawati', 'Jl. Gajah Mada No. 89, Semarang', '084567890123', 'dewi@example.com'),
(2005, 1001, 'Joko Widodo', 'Jl. Veteran No. 101, Solo', '085678901234', 'joko@example.com'),
(2006, 1002, 'Ani Yudhoyono', 'Jl. Sudirman No. 202, Jakarta', '086789012345', 'ani@example.com'),
(2007, 1001, 'Rizki Pratama', 'Jl. Ahmad Yani No. 303, Medan', '087890123456', 'rizki@example.com'),
(2008, 1003, 'Nina Sari', 'Jl. Pemuda No. 404, Yogyakarta', '088901234567', 'nina@example.com'),
(2009, 1001, 'Dodi Irawan', 'Jl. Hayam Wuruk No. 505, Bali', '089012345678', 'dodi@example.com'),
(2010, 1002, 'Lisa Permata', 'Jl. Thamrin No. 606, Jakarta', '081123456789', 'lisa@example.com');

-- 3. Data Cabang
INSERT INTO Cabang (ID_Cabang, Nama_Cabang, Alamat, Luas_Area) VALUES
(3001, 'BreadHouse Central', 'Jl. Gatot Subroto No. 123, Jakarta Selatan', 250.00),
(3002, 'BreadHouse Bandung', 'Jl. Asia Afrika No. 456, Bandung', 180.00),
(3003, 'BreadHouse Surabaya', 'Jl. Tunjungan No. 789, Surabaya', 220.00),
(3004, 'BreadHouse Outlet Mall', 'Mall Kota Kasablanka Lt. 3, Jakarta', 120.00),
(3005, 'BreadHouse Express', 'Terminal Pulogebang, Jakarta Timur', 80.00);

-- 4. Data Cabang Produksi (cabang yang memiliki fasilitas produksi)
INSERT INTO Cabang_Produksi (ID_CabangProduk, Dapur_Produksi, Gudang_Penyimpanan, Area_Penjualan) VALUES
(3001, TRUE, TRUE, TRUE),
(3002, TRUE, TRUE, TRUE),
(3003, TRUE, TRUE, TRUE);

-- 5. Data Cabang Penjualan (cabang yang hanya untuk penjualan)
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
(8001, 6001, 7001, 1.00),    -- 1 kg Tepung Terigu
(8002, 6001, 7003, 0.10),    -- 0.1 kg Gula Pasir
(8003, 6001, 7010, 0.02),    -- 0.02 kg Ragi Instan
(8004, 6001, 7011, 0.01),    -- 0.01 kg Garam
(8005, 6001, 7005, 0.10),    -- 0.1 kg Mentega

-- Resep Roti Gandum (ID_Resep: 6002)
(8006, 6002, 7002, 1.00),    -- 1 kg Tepung Gandum
(8007, 6002, 7017, 0.10),    -- 0.1 kg Madu
(8008, 6002, 7010, 0.02),    -- 0.02 kg Ragi Instan
(8009, 6002, 7011, 0.01),    -- 0.01 kg Garam
(8010, 6002, 7005, 0.10),    -- 0.1 kg Mentega

-- Resep Donat Cokelat (ID_Resep: 6003)
(8011, 6003, 7001, 0.50),    -- 0.5 kg Tepung Terigu
(8012, 6003, 7003, 0.15),    -- 0.15 kg Gula Pasir
(8013, 6003, 7010, 0.01),    -- 0.01 kg Ragi Instan
(8014, 6003, 7004, 4.00),    -- 4 butir Telur Ayam
(8015, 6003, 7005, 0.10),    -- 0.1 kg Mentega
(8016, 6003, 7006, 0.20),    -- 0.2 liter Susu Cair
(8017, 6003, 7008, 0.15),    -- 0.15 kg Cokelat Batang (untuk glaze)

-- Resep Donat Stroberi (ID_Resep: 6004)
(8018, 6004, 7001, 0.50),    -- 0.5 kg Tepung Terigu
(8019, 6004, 7003, 0.15),    -- 0.15 kg Gula Pasir
(8020, 6004, 7010, 0.01),    -- 0.01 kg Ragi Instan
(8021, 6004, 7004, 4.00),    -- 4 butir Telur Ayam
(8022, 6004, 7005, 0.10),    -- 0.1 kg Mentega
(8023, 6004, 7006, 0.20),    -- 0.2 liter Susu Cair
(8024, 6004, 7012, 0.10),    -- 0.1 kg Pasta Stroberi (untuk glaze)

-- Resep Donat Vanilla (ID_Resep: 6005)
(8025, 6005, 7001, 0.50),    -- 0.5 kg Tepung Terigu
(8026, 6005, 7003, 0.15),    -- 0.15 kg Gula Pasir
(8027, 6005, 7010, 0.01),    -- 0.01 kg Ragi Instan
(8028, 6005, 7004, 4.00),    -- 4 butir Telur Ayam
(8029, 6005, 7005, 0.10),    -- 0.1 kg Mentega
(8030, 6005, 7006, 0.20),    -- 0.2 liter Susu Cair
(8031, 6005, 7013, 0.08),    -- 0.08 kg Pasta Vanilla (untuk glaze)

-- Resep untuk produk lainnya diisi sebagian untuk menyingkat
-- Croissant Plain (ID_Resep: 6006)
(8032, 6006, 7001, 0.70),    -- 0.7 kg Tepung Terigu
(8033, 6006, 7005, 0.30),    -- 0.3 kg Mentega
(8034, 6006, 7010, 0.02),    -- 0.02 kg Ragi Instan

-- Croissant Almond (ID_Resep: 6007)
(8035, 6007, 7001, 0.70),    -- 0.7 kg Tepung Terigu
(8036, 6007, 7005, 0.30),    -- 0.3 kg Mentega
(8037, 6007, 7014, 0.15),    -- 0.15 kg Almond Slice

-- Red Velvet Cake (ID_Resep: 6010)
(8038, 6010, 7001, 0.50),    -- 0.5 kg Tepung Terigu
(8039, 6010, 7003, 0.40),    -- 0.4 kg Gula Pasir
(8040, 6010, 7009, 0.10),    -- 0.1 kg Cokelat Bubuk
(8041, 6010, 7018, 0.03),    -- 0.03 liter Pewarna Makanan Merah
(8042, 6010, 7019, 0.25);    -- 0.25 kg Cream Cheese

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
-- Pembelian ID 9001
(10001, 9001, 7001, 200.00, 15000.00),    -- 200 kg Tepung Terigu @ Rp 15,000/kg
(10002, 9001, 7002, 100.00, 20000.00),    -- 100 kg Tepung Gandum @ Rp 20,000/kg

-- Pembelian ID 9002
(10003, 9002, 7004, 500.00, 2000.00),     -- 500 butir Telur Ayam @ Rp 2,000/butir
(10004, 9002, 7010, 10.00, 100000.00),    -- 10 kg Ragi Instan @ Rp 100,000/kg

-- Pembelian ID 9003
(10005, 9003, 7003, 100.00, 15000.00),    -- 100 kg Gula Pasir @ Rp 15,000/kg
(10006, 9003, 7011, 20.00, 10000.00),     -- 20 kg Garam @ Rp 10,000/kg
(10007, 9003, 7017, 10.00, 80000.00),     -- 10 kg Madu @ Rp 80,000/kg

-- Pembelian ID 9004
(10008, 9004, 7001, 150.00, 15000.00),    -- 150 kg Tepung Terigu @ Rp 15,000/kg
(10009, 9004, 7005, 50.00, 30000.00),     -- 50 kg Mentega @ Rp 30,000/kg
(10010, 9004, 7006, 100.00, 15000.00),    -- 100 liter Susu Cair @ Rp 15,000/liter

-- Pembelian ID 9005
(10011, 9005, 7006, 80.00, 15000.00),     -- 80 liter Susu Cair @ Rp 15,000/liter
(10012, 9005, 7007, 30.00, 20000.00),     -- 30 kg Susu Bubuk @ Rp 20,000/kg

-- Pembelian ID 9006
(10013, 9006, 7008, 30.00, 80000.00),     -- 30 kg Cokelat Batang @ Rp 80,000/kg
(10014, 9006, 7009, 20.00, 60000.00),     -- 20 kg Cokelat Bubuk @ Rp 60,000/kg

-- Pembelian ID 9007
(10015, 9007, 7004, 400.00, 2000.00),     -- 400 butir Telur Ayam @ Rp 2,000/butir
(10016, 9007, 7019, 15.00, 100000.00),    -- 15 kg Cream Cheese @ Rp 100,000/kg

-- Pembelian ID 9008
(10017, 9008, 7012, 10.00, 60000.00),     -- 10 kg Pasta Stroberi @ Rp 60,000/kg
(10018, 9008, 7013, 8.00, 70000.00),      -- 8 kg Pasta Vanilla @ Rp 70,000/kg
(10019, 9008, 7014, 5.00, 120000.00);     -- 5 kg Almond Slice @ Rp 120,000/kg

-- 13. Data Penggunaan Bahan Baku
INSERT INTO Penggunaan_Bahan_Baku (ID_Penggunaan, ID_BahanBaku, ID_Cabang, Tanggal_Penggunaan, Jumlah_Bahan_Digunakan, ID_Produk_Yang_Dibuat) VALUES
-- Penggunaan untuk Roti Tawar Original
(11001, 7001, 3001, '2023-05-10 07:00:00', 10.00, 5001),    -- 10 kg Tepung Terigu
(11002, 7003, 3001, '2023-05-10 07:00:00', 1.00, 5001),     -- 1 kg Gula Pasir
(11003, 7010, 3001, '2023-05-10 07:00:00', 0.20, 5001),     -- 0.2 kg Ragi Instan

-- Penggunaan untuk Donat Cokelat
(11004, 7001, 3002, '2023-05-10 08:00:00', 5.00, 5003),     -- 5 kg Tepung Terigu
(11005, 7003, 3002, '2023-05-10 08:00:00', 1.50, 5003),     -- 1.5 kg Gula Pasir
(11006, 7004, 3002, '2023-05-10 08:00:00', 40.00, 5003),    -- 40 butir Telur Ayam
(11007, 7008, 3002, '2023-05-10 08:00:00', 1.50, 5003),     -- 1.5 kg Cokelat Batang

-- Penggunaan untuk Croissant Almond
(11008, 7001, 3003, '2023-05-10 09:00:00', 7.00, 5007),     -- 7 kg Tepung Terigu
(11009, 7005, 3003, '2023-05-10 09:00:00', 3.00, 5007),     -- 3 kg Mentega
(11010, 7014, 3003, '2023-05-10 09:00:00', 1.50, 5007),     -- 1.5 kg Almond Slice

-- Penggunaan untuk Red Velvet Cake
(11011, 7001, 3001, '2023-05-11 07:30:00', 5.00, 5010),     -- 5 kg Tepung Terigu
(11012, 7003, 3001, '2023-05-11 07:30:00', 4.00, 5010),     -- 4 kg Gula Pasir
(11013, 7009, 3001, '2023-05-11 07:30:00', 1.00, 5010),     -- 1 kg Cokelat Bubuk
(11014, 7018, 3001, '2023-05-11 07:30:00', 0.30, 5010),     -- 0.3 liter Pewarna Makanan Merah
(11015, 7019, 3001, '2023-05-11 07:30:00', 2.50, 5010);     -- 2.5 kg Cream Cheese

-- 14. Data Pengiriman Produk
INSERT INTO Pengiriman_Produk (ID_Pengiriman, ID_CabangProduk, ID_CabangPenjualan, ID_Produk, Tanggal_Pengiriman, Jumlah_Produk) VALUES
(12001, 3001, 3004, 5001, '2023-05-12 06:00:00', 20),   -- 20 Roti Tawar Original dari Cabang 3001 ke 3004
(12002, 3001, 3004, 5002, '2023-05-12 06:00:00', 15),   -- 15 Roti Gandum dari Cabang 3001 ke 3004
(12003, 3002, 3004, 5003, '2023-05-12 07:30:00', 30),   -- 30 Donat Cokelat dari Cabang 3002 ke 3004
(12004, 3002, 3004, 5004, '2023-05-12 07:30:00', 25),   -- 25 Donat Stroberi dari Cabang 3002 ke 3004
(12005, 3003, 3005, 5006, '2023-05-12 08:45:00', 20),   -- 20 Croissant Plain dari Cabang 3003 ke 3005
(12006, 3003, 3005, 5007, '2023-05-12 08:45:00', 15),   -- 15 Croissant Almond dari Cabang 3003 ke 3005
(12007, 3001, 3005, 5010, '2023-05-13 06:30:00', 10),   -- 10 Red Velvet Cake dari Cabang 3001 ke 3005
(12008, 3001, 3005, 5011, '2023-05-13 06:30:00', 8),    -- 8 Choco Lava Cake dari Cabang 3001 ke 3005
(12009, 3002, 3004, 5005, '2023-05-13 07:15:00', 30),   -- 30 Donat Vanilla dari Cabang 3002 ke 3004
(12010, 3001, 3004, 5012, '2023-05-13 08:00:00', 15);   -- 15 Bread Pudding dari Cabang 3001 ke 3004

-- 15. Data Transaksi Penjualan
INSERT INTO Transaksi_Penjualan (ID_Transaksi_Penjualan, ID_Pelanggan, ID_Cabang, Tanggal_Transaksi, Total_Harga) VALUES
(13001, 2002, 3001, '2023-05-15 10:30:00', 43200.00),  -- Member Silver (10% diskon)
(13002, NULL, 3001, '2023-05-15 11:45:00', 38000.00),  -- Non-member
(13003, 2003, 3002, '2023-05-15 13:20:00', 51000.00),  -- Member Gold (15% diskon)
(13004, 2001, 3003, '2023-05-15 14:35:00', 30000.00),  -- Non-member
(13005, 2004, 3004, '2023-05-16 09:15:00', 33750.00),  -- Member Diamond (25% diskon)
(13006, NULL, 3004, '2023-05-16 10:30:00', 24000.00),  -- Non-member
(13007, 2006, 3005, '2023-05-16 12:45:00', 32400.00),  -- Member Silver (10% diskon)
(13008, 2008, 3001, '2023-05-16 15:20:00', 61200.00),  -- Member Gold (15% diskon)
(13009, NULL, 3002, '2023-05-17 09:45:00', 15000.00),  -- Non-member
(13010, 2010, 3003, '2023-05-17 11:10:00', 25200.00),  -- Member Silver (10% diskon)
(13011, NULL, 3004, '2023-05-17 13:30:00', 30000.00),  -- Non-member
(13012, 2004, 3005, '2023-05-17 16:15:00', 33750.00);  -- Member Diamond (25% diskon)

-- 16. Data Detail Transaksi
INSERT INTO Detail_Transaksi (ID_Detail_Transaksi, ID_Transaksi_Penjualan, ID_Produk, Quantity, Total_Harga) VALUES
-- Transaksi ID 13001 (Member Silver - 10% diskon)
(14001, 13001, 5001, 2, 27000.00),  -- 2 Roti Tawar Original: 2 x 15000 = 30000 - 10% = 27000
(14002, 13001, 5003, 2, 14400.00),  -- 2 Donat Cokelat: 2 x 8000 = 16000 - 10% = 14400
(14003, 13001, 5006, 1, 10800.00),  -- 1 Croissant Plain: 1 x 12000 = 12000 - 10% = 10800

-- Transaksi ID 13002 (Non-member)
(14004, 13002, 5003, 3, 24000.00),  -- 3 Donat Cokelat: 3 x 8000 = 24000
(14005, 13002, 5005, 2, 15000.00),  -- 2 Donat Vanilla: 2 x 7500 = 15000

-- Transaksi ID 13003 (Member Gold - 15% diskon)
(14006, 13003, 5002, 2, 30600.00),  -- 2 Roti Gandum: 2 x 18000 = 36000 - 15% = 30600
(14007, 13003, 5007, 1, 12750.00),  -- 1 Croissant Almond: 1 x 15000 = 15000 - 15% = 12750
(14008, 13003, 5008, 1, 8500.00),   -- 1 Bagel Sesame: 1 x 10000 = 10000 - 15% = 8500

-- Transaksi ID 13004 (Non-member)
(14009, 13004, 5001, 2, 30000.00),  -- 2 Roti Tawar Original: 2 x 15000 = 30000

-- Transaksi ID 13005 (Member Diamond - 25% diskon)
(14010, 13005, 5010, 1, 18750.00),  -- 1 Red Velvet Cake: 1 x 25000 = 25000 - 25% = 18750
(14011, 13005, 5011, 1, 16500.00),  -- 1 Choco Lava Cake: 1 x 22000 = 22000 - 25% = 16500

-- Transaksi ID 13006 (Non-member)
(14012, 13006, 5003, 3, 24000.00),  -- 3 Donat Cokelat: 3 x 8000 = 24000

-- Transaksi ID 13007 (Member Silver - 10% diskon)
(14013, 13007, 5006, 3, 32400.00),  -- 3 Croissant Plain: 3 x 12000 = 36000 - 10% = 32400

-- Transaksi ID 13008 (Member Gold - 15% diskon)
(14014, 13008, 5002, 2, 30600.00),  -- 2 Roti Gandum: 2 x 18000 = 36000 - 15% = 30600
(14015, 13008, 5010, 1, 21250.00),  -- 1 Red Velvet Cake: 1 x 25000 = 25000 - 15% = 21250
(14016, 13008, 5008, 1, 8500.00),   -- 1 Bagel Sesame: 1 x 10000 = 10000 - 15% = 8500

-- Transaksi ID 13009 (Non-member)
(14017, 13009, 5001, 1, 15000.00),  -- 1 Roti Tawar Original: 1 x 15000 = 15000

-- Transaksi ID 13010 (Member Silver - 10% diskon)
(14018, 13010, 5007, 1, 13500.00),  -- 1 Croissant Almond: 1 x 15000 = 15000 - 10% = 13500
(14019, 13010, 5009, 1, 9900.00),   -- 1 Bagel Garlic: 1 x 11000 = 11000 - 10% = 9900
(14020, 13010, 5003, 1, 7200.00),   -- 1 Donat Cokelat: 1 x 8000 = 8000 - 10% = 7200

-- Transaksi ID 13011 (Non-member)
(14021, 13011, 5001, 2, 30000.00),  -- 2 Roti Tawar Original: 2 x 15000 = 30000

-- Transaksi ID 13012 (Member Diamond - 25% diskon)
(14022, 13012, 5010, 1, 18750.00),  -- 1 Red Velvet Cake: 1 x 25000 = 25000 - 25% = 18750
(14023, 13012, 5011, 1, 16500.00);  -- 1 Choco Lava Cake: 1 x 22000 = 22000 - 25% = 16500

-- 17. Data Pencatatan
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

-- ================================================================================================
INSERT INTO Pelanggan (ID_Pelanggan, ID_Keanggotaan, Nama, Alamat, No_Telepon, Email) VALUES
(2011, 1001, 'Roni Wicaksono', 'Jl. Danau Toba No. 45, Jakarta', '081234987654', 'roni@example.com'),
(2012, 1001, 'Maria Anggraini', 'Jl. Kebon Jeruk No. 78, Jakarta', '082345098765', 'maria@example.com'),
(2013, 1001, 'Taufik Rahman', 'Jl. Ciliwung No. 23, Bandung', '083456109876', 'taufik@example.com'),
(2014, 1001, 'Sinta Dewi', 'Jl. Panglima Polim No. 55, Jakarta', '084567210987', 'sinta@example.com');

-- Mengupdate data transaksi penjualan yang sebelumnya NULL
UPDATE Transaksi_Penjualan SET ID_Pelanggan = 2011 WHERE ID_Transaksi_Penjualan = 13002;
UPDATE Transaksi_Penjualan SET ID_Pelanggan = 2012 WHERE ID_Transaksi_Penjualan = 13006;
UPDATE Transaksi_Penjualan SET ID_Pelanggan = 2013 WHERE ID_Transaksi_Penjualan = 13009;
UPDATE Transaksi_Penjualan SET ID_Pelanggan = 2014 WHERE ID_Transaksi_Penjualan = 13011;



-- Query untuk menampilkan data transaksi dengan informasi cabang
SELECT 
    tp.ID_Transaksi_Penjualan,
    p.Nama AS Nama_Pelanggan,
    k.StatusMember,
    c.Nama_Cabang,
    c.Alamat,  -- Menyesuaikan nama kolom dengan yang ada di tabel Cabang
    tp.Tanggal_Transaksi,
    pr.Nama_Produk,
    dt.Quantity,
    dt.Total_Harga,
    CASE 
        WHEN cp.ID_CabangProduk IS NOT NULL THEN 'Cabang Produksi'  -- Jika Cabang_Produksi ada, berarti cabang produksi
        ELSE 'Cabang Penjualan'  -- Jika tidak ada Cabang_Produksi, berarti cabang penjualan
    END AS Jenis_Cabang
FROM Transaksi_Penjualan tp
JOIN Pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN Keanggotaan k ON p.ID_Keanggotaan = k.ID_Keanggotaan
JOIN Cabang c ON tp.ID_Cabang = c.ID_Cabang
LEFT JOIN Cabang_Produksi cp ON c.ID_Cabang = cp.ID_CabangProduk  -- Menambahkan join dengan Cabang_Produksi
JOIN Detail_Transaksi dt ON tp.ID_Transaksi_Penjualan = dt.ID_Transaksi_Penjualan
JOIN Produk_Roti pr ON dt.ID_Produk = pr.ID_Produk
ORDER BY tp.Tanggal_Transaksi, tp.ID_Transaksi_Penjualan;



-- ============================================================
-- latihan soal mudah  

-- soal 1 dimana harus menampilkan nama produk dan harga tapi dengan
-- harga dari terbesar ke terkecil
SELECT nama_produk, harga
FROM produk_roti
ORDER BY harga DESC;


-- soal 2 dimana harus menampilkan harga_produk, stokroti, haraga dan nilait total
-- nilai total diambil dari harga kali jumlah stok roti
-- llalu di desc terkait nilai tottal nya
SELECT nama_produk, 
Stok_Roti AS jumlahstok, 
Harga AS hargaasli,
(Harga * Stok_Roti) AS nilaitotal
FROM produk_roti
ORDER BY nilaitotal DESC;


-- soal 3;
-- Tampilkan nama pelanggan dan alamat mereka dari tabel Pelanggan.
SELECT 
Id_Pelanggan AS ktp,
Nama AS nama_pelanggan, 
Alamat
FROM pelanggan
ORDER BY Nama ASC, ktp DESC;



SELECT p.Nama, SUM(t.Total_Harga * k.ManfaatMember) AS Total_Diskon, k.StatusMember AS LEVEL, k.ManfaatMember AS diskonnya
FROM Transaksi_Penjualan t
JOIN Pelanggan p ON t.ID_Pelanggan = p.ID_Pelanggan
JOIN Keanggotaan k ON p.ID_Keanggotaan = k.ID_Keanggotaan
GROUP BY p.Nama;









-- soal dimana suruh menampilkan id, nama, alamt dan jenis cabang
SELECT
c.Id_Cabang AS nomorinduk,
c.Nama_cabang AS namacabang,
c.Alamat,
CASE
WHEN cp.ID_CabangPenjualan IS NOT NULL THEN 'Penjualan'
ELSE 'Produksi'
END AS jenis_cabang
FROM cabang c
LEFT JOIN Cabang_Penjualan cp ON c.ID_Cabang = cp.ID_CabangPenjualan
ORDER BY c.ID_Cabang DESC;	


SELECT
c.ID_Cabang AS NOMORINDUK,
c.Nama_Cabang AS NAMACABANG,
c.Alamat,
CASE
WHEN cp.ID_CabangProduk IS NOT NULL THEN 'produksi'
ELSE 'penjualan'
END AS jeniscabang
FROM cabang c
LEFT JOIN Cabang_Produksi cp on c.ID_Cabang = cp.ID_CabangProduk
ORDER BY c.ID_Cabang ASC;



-- menampikan semua transaksi penjualan
SELECT * FROM transaksi_penjualan
SELECT
tp.ID_Transaksi_Penjualan, tp.ID_Cabang, tp.Tanggal_Transaksi,
p.Nama AS namapelanggan,k.StatusMember, tp.Total_Harga
FROM transaksi_penjualan tp
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN keanggotaan k ON p.ID_Keanggotaan = k.ID_Keanggotaan
ORDER BY p.Nama ASC;


-- Tampilkan nama pelanggan yang melakukan transaksi pada cabang 'BreadHouse Central'.
SELECT
p.Nama,
k.StatusMember,
tp.Tanggal_Transaksi,pr.Nama_Produk AS produkyangdibeli
FROM transaksi_penjualan tp
JOIN detail_transaksi dt ON tp.ID_Transaksi_Penjualan = dt.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
JOIN keanggotaan k ON p.ID_Keanggotaan = k.ID_Keanggotaan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
WHERE c.Nama_Cabang = 'BreadHouse Central'
ORDER BY p.Nama ASC;




-- Tampilkan nama pelanggan dan alamat mereka beserta nama cabang tempat mereka bertransaksi.
SELECT
	p.Nama AS NamaPelanggan,
	p.Alamat,
	c.Nama_Cabang AS NamaCabangTempatBertransaksi,
	pr.Nama_Produk AS RotiYangDipesan,
	tp.Tanggal_Transaksi AS TanggalCO
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
ORDER BY p.Nama ASC;


-- Tampilkan semua transaksi yang dilakukan oleh pelanggan dengan status 'Gold' atau 'Diamond', beserta total harga dan nama cabang.
SELECT
	p.Nama AS NamaPelanggan,
	k.StatusMember AS STATUS,
	pr.Nama_Produk AS NamaRoti,
	c.Nama_Cabang,
	pr.Harga AS HargaAsli,
	dt.Quantity AS JumlahYangDibeli,
	dt.Total_Harga,
	tp.Tanggal_Transaksi
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = dt.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = tp.ID_Pelanggan
JOIN keanggotaan k ON p.ID_Keanggotaan = k.ID_Keanggotaan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
WHERE k.StatusMember IN ('Gold', 'Diamond')
ORDER BY p.Nama ASC;



-- Tampilkan nama pemasok dan nama bahan baku yang mereka pasok, beserta jumlah yang dibeli dalam pembelian tertentu.
SELECT
	pm.Nama_Pemasok,
	bp.Nama_Bahan_Baku,
	dp.Jumlah_Dibeli,
	dp.Harga_Satuan,
	dp.Total_Harga
FROM detail_pembelian dp
JOIN bahan_baku bp ON dp.ID_BahanBaku = bp.ID_BahanBaku
JOIN pembelian_bahan_baku pb ON dp.ID_Pembelian = pb.ID_Pembelian
JOIN pemasok pm ON pb.ID_Pemasok = pm.ID_Pemasok
GROUP BY bp.Nama_Bahan_Baku
ORDER BY dp.Total_Harga ASC;


--Tampilkan transaksi penjualan beserta nama pelanggan dan status keanggotaan mereka yang telah bertransaksi di cabang produksi.
SELECT
	p.Nama,
	k.StatusMember AS STATUS,
	tp.ID_Transaksi_Penjualan,
	cp.Dapur_Produksi
FROM transaksi_penjualan tp
JOIN pelanggan p ON tp.ID_pelanggan = p.ID_Pelanggan
JOIN keanggotaan k ON p.ID_Keanggotaan = k.ID_Keanggotaan
JOIN cabang_produksi cp ON tp.ID_Cabang = cp.ID_CabangProduk
WHERE cp.ID_CabangProduk IS NOT NULL;




--
Tampilkan nama cabang dan jumlah produk yang dikirim ke setiap cabang penjualan.
--

SELECT 
	c.Nama_Cabang,
	SUM(pp.Jumlah_Produk)
FROM pengiriman_produk pp 
JOIN cabang_penjualan cp ON pp.ID_CabangPenjualan = cp.ID_CabangPenjualan
JOIN cabang c ON cp.ID_CabangPenjualan = c.ID_Cabang
GROUP BY c.Nama_Cabang;
 
 

-- Tampilkan nama produk, jumlah produk yang terjual, dan 
-- total transaksi yang terjadi di setiap cabang. Kelompokkan berdasarkan cabang dan produk.

SELECT
	pr.Nama_Produk,
	SUM(dt.Quantity) AS jumlahprodukyangterjual,
	CASE 
		WHEN cp.ID_CabangProduk IS NOT NULL THEN 'PRODUKSI'
	ELSE 
	'PENJUALAN'
	END AS 'JENISCABANG'
FROM transaksi_penjualan tp
JOIN detail_transaksi dt ON tp.ID_Transaksi_Penjualan = dt.ID_Transaksi_Penjualan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
LEFT JOIN cabang_produksi cp ON c.ID_Cabang = cp.ID_CabangProduk
GROUP BY Cabang, pr.Nama_Produk;


--- pelajaran baru
SELECT
	pr.Nama_Produk,
	SUM(dt.Quantity) AS jumlahprodukyangterjual,
	c.Nama_Cabang,
	CASE 
		WHEN cp.ID_CabangProduk IS NOT NULL THEN 'PRODUKSI'
		ELSE 'PENJUALAN'
	END AS 'JENISCABANG'
FROM transaksi_penjualan tp
JOIN detail_transaksi dt ON tp.ID_Transaksi_Penjualan = dt.ID_Transaksi_Penjualan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
LEFT JOIN cabang_produksi cp ON c.ID_Cabang = cp.ID_CabangProduk
GROUP BY c.Nama_Cabang, pr.Nama_Produk
ORDER BY pr.Nama_Produk ASC;


-- Tampilkan nama produk dan jumlah produk yang terjual dari tabel transaksi_penjualan dan 
-- detail_transaksi. Kelompokkan data berdasarkan 
-- Nama_Produk dan urutkan berdasarkan jumlahprodukyangterjual secara menurun (DESC).

SELECT 
	p.Nama_Produk,
	SUM(dt.Quantity) AS jumlahyangterjual
FROM detail_transaksi dt
JOIN produk_roti p ON dt.ID_Produk = p.ID_Produk
GROUP BY p.Nama_Produk
ORDER BY jumlahyangterjual DESC;


-- Tampilkan nama cabang dan total produk yang terjual di setiap cabang.
-- Kelompokkan berdasarkan Nama_Cabang, urutkan berdasarkan total_produk_terjual secara menurun (DESC), 
 -- dan juga tampilkan JENISCABANG yang dapat bernilai 
-- PRODUKSI atau PENJUALAN berdasarkan apakah cabang tersebut memiliki fasilitas produksi.
SELECT
	c.Nama_Cabang,
	SUM(dt.Quantity) AS totalprodukyangterjual,
	case
		when cp.ID_CabangProduk IS NOT NULL THEN 'CABANG PRODUKSI'
	ELSE
	 'PENJUALAN'
	END AS JENIS_CABANG
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
LEFT JOIN cabang_produksi cp ON c.ID_Cabang = cp.ID_CabangProduk
GROUP BY c.Nama_Cabang
ORDER BY totalprodukyangterjual DESC;

-- pengecekan apakah benar berjumlah yang sesuai soal diatas
SELECT
	SUM(dt.Quantity)
FROM detail_transaksi dt
ORDER BY dt.Quantity


-- Di sebuah toko roti, manajer ingin mengetahui produk roti apa saja yang paling banyak terjual 
 -- pada setiap cabang. Tugas Anda adalah menampilkan nama produk dan jumlah produk yang terjual 
-- di masing-masing cabang. Urutkan hasilnya 
-- berdasarkan jumlah produk yang terjual secara menurun (DESC), agar dapat dengan mudah 
-- melihat produk terlaris.

SELECT
	c.Nama_Cabang,
	pr.Nama_Produk,
	SUM(dt.Quantity) AS jumlahyangterjual
FROM detail_transaksi dt
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
GROUP BY  pr.Nama_Produk, c.Nama_Cabang
ORDER BY jumlahyangterjual DESC;


 -- Di cabang "BreadHouse Surabaya", manajer ingin mengetahui produk yang terjual pada bulan ini. 
 -- Hasilnya harus mencakup produk dan jumlah unit yang terjual. Data harus dipilah berdasarkan nama cabang.
SELECT
	pr.Nama_Produk,
	SUM(dt.Quantity) AS jumlahterjual
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
WHERE c.Nama_Cabang = 'BreadHouse Surabaya'
GROUP BY pr.Nama_Produk
ORDER BY jumlahterjual DESC;
-- 
-- pelanggan dan produk roti

SELECT
	p.Nama,
	pr.Nama_Produk
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_transaksi_penjualan = tp.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
ORDER BY p.Nama DESC;


SELECT
    p.Nama,
    pr.Nama_Produk
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
ORDER BY p.Nama ASC;

-- Tampilkan daftar produk roti dengan penjualan tertinggi 
-- di "BreadHouse Bandung". Jangan lupa untuk menampilkan jumlah unit yang terjual.
SELECT 
    pr.Nama_Produk,
    SUM(dt.Quantity) AS jumlahprodukyangterjual
FROM transaksi_penjualan tp
JOIN detail_transaksi dt ON tp.ID_Transaksi_Penjualan = dt.ID_Transaksi_Penjualan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
WHERE c.Nama_Cabang = 'BreadHouse Bandung'
GROUP BY pr.Nama_Produk
ORDER BY jumlahprodukyangterjual DESC;

/*
Manajer BreadHouse ingin mengetahui bagaimana distribusi penjualan di setiap cabang. 
Mereka ingin melihat daftar 
produk yang paling laku di setiap cabang, serta jumlahnya.
Namun, mereka juga ingin mengetahui apakah cabang tersebut
merupakan cabang produksi atau penjualan, agar bisa mengambil keputusan lebih lanjut.
Pertanyaan:
Tampilkan nama produk, jumlah penjualan, 
dan jenis cabang (produksi/pengiriman) untuk setiap transaksi, 
kelompokkan berdasarkan produk dan cabang, lalu urutkan berdasarkan 
jumlah penjualan dari yang terbesar ke terkecil.
*/

SELECT 
	p.Nama,
	pr.Nama_Produk,
	k.StatusMember,
	SUM(dt.Quantity) AS JumlahPenjualan,
	c.Nama_Cabang,
	CASE
		WHEN cp.ID_CabangProduk IS NOT NULL THEN 'PRODUKSI'
	ELSE
	'PENJUALAN'
	END AS JENISCABANG
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN keanggotaan k ON p.ID_Keanggotaan = k.ID_Keanggotaan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
LEFT JOIN cabang_produksi cp ON c.ID_Cabang = cp.ID_CabangProduk
GROUP BY p.Nama, pr.Nama_Produk, c.Nama_Cabang
ORDER BY JumlahPenjualan DESC;
/*
BreadHouse ingin mengetahui berapa banyak pelanggan yang melakukan 
transaksi di setiap cabang. Mereka ingin mengetahui data ini untuk mengevaluasi kinerja cabang.
Pertanyaan:
Tampilkan nama cabang dan jumlah pelanggan yang melakukan transaksi di setiap cabang, 
urutkan berdasarkan jumlah pelanggan dari yang paling sedikit ke yang paling banyak.
*/

SELECT 
	c.Nama_Cabang,
	COUNT(DISTINCT tp.ID_Pelanggan) AS Jumlah_Pelanggan
FROM transaksi_penjualan tp
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
GROUP BY c.Nama_Cabang
ORDER BY Jumlah_Pelanggan DESC;

/*
Manajer produksi ingin mengevaluasi efisiensi penggunaan berbagai bahan baku di dapur.
 Ia ingin tahu bahan baku mana yang digunakan paling banyak, sehingga dapat dipertimbangkan 
 untuk pengadaan ulang. Buatlah daftar nama bahan baku beserta total penggunaannya, 
dan susun daftar tersebut mulai dari bahan yang paling banyak digunakan.
*/

SELECT 
	bb.Nama_Bahan_Baku,
	SUM(pbb.Jumlah_Bahan_Digunakan) AS totalpenggunaan
FROM penggunaan_bahan_baku pbb
JOIN bahan_baku bb ON pbb.ID_BahanBaku
GROUP BY bb.Nama_Bahan_Baku
ORDER BY totalpenggunaan DESC ;

/*
Divisi logistik ingin menilai kontribusi masing-masing pemasok terhadap total 
pasokan bahan baku yang digunakan dalam produksi. Mereka ingin tahu 
pemasok mana yang secara total bahan bakunya paling sering digunakan. Susun daftar 
nama pemasok berdasarkan total jumlah bahan baku yang dikirimkan dan telah digunakan dalam produksi.
*/

SELECT
p.Nama_Pemasok,
SUM(pb.Jumlah_Digunakan) AS total_penggunaan_bahan
FROM penggunaan_bahan_baku pb
JOIN bahan_baku bb ON pb.ID_BahanBaku = bb.ID_BahanBaku
JOIN pemasok p ON bb.ID_Pemasok = p.ID_Pemasok
GROUP BY p.Nama_Pemasok
ORDER BY total_penggunaan_bahan DESC;



SELECT 
	pm.Nama_Pemasok,
	bb.Nama_Bahan_Baku,
	SUM(pbc.Jumlah_Bahan_Digunakan) AS Total_Penggunaan
FROM detail_pembelian dp
JOIN pembelian_bahan_baku pbb ON dp.ID_Pembelian
JOIN pemasok pm ON pbb.ID_Pemasok = pm.ID_Pemasok
JOIN bahan_baku bb ON dp.ID_BahanBaku = bb.ID_BahanBaku
JOIN penggunaan_bahan_baku pbc ON bb.ID_BahanBaku = pbc.ID_BahanBaku
GROUP BY pm.Nama_Pemasok, bb.Nama_Bahan_Baku
ORDER BY Total_Penggunaan DESC;

/*
Seorang analis ingin tahu toko cabang mana yang paling aktif menggunakan 
bahan baku untuk membuat produk roti. Ia ingin menilai performa tiap 
 berdasarkan total jumlah bahan baku yang digunakan dalam proses produksi.
Tampilkan nama cabang dan total seluruh bahan baku yang digunakan oleh cabang 
tersebut untuk memproduksi roti. Urutkan agar cabang dengan penggunaan tertinggi muncul paling atas.
Hint: Data penggunaan bahan baku per produk, lalu hubungkan ke transaksi penjualan dan cabang.
*/ 
SELECT
	c.Nama_Cabang,
	SUM(pbb.Jumlah_Bahan_Digunakan) AS jumlahyangdigunakan
FROM penggunaan_bahan_baku pbb 
JOIN cabang c ON pbb.ID_Cabang = c.ID_Cabang
JOIN bahan_baku bb ON pbb.ID_BahanBaku = bb.ID_BahanBaku
WHERE pbb.ID_Produk_Yang_Dibuat IN
	(SELECT dt.ID_Produk
	FROM detail_transaksi dt
	)
GROUP BY c.Nama_Cabang
ORDER BY jumlahyangdigunakan DESC;

/*
Divisi kontrol kualitas ingin tahu produk roti mana yang
 diproduksi menggunakan bahan baku paling bervariasi (berbeda-beda).
Tampilkan nama produk roti dan jumlah bahan baku
 unik yang digunakan dalam produksinya. 
Urutkan agar yang paling kompleks (bahan terbanyak) muncul paling atas.
Hint: COUNT DISTINCT bahan baku untuk setiap produk.
*/ 
SELECT
	pr.Nama_Produk,
	COUNT(DISTINCT bb.ID_BahanBaku) AS jumlahbahanbaku
FROM detail_resep dr
JOIN resep r ON dr.ID_Resep = r.ID_Resep
JOIN produk_roti pr ON r.ID_Produk = pr.ID_Produk
JOIN bahan_baku bb ON dr.ID_BahanBaku = bb.ID_BahanBaku
GROUP BY pr.Nama_Produk
ORDER BY jumlahbahanbaku DESC;
/*
Lalu bagaiamana jika sayaingin menampilkan produk, 
dan produk tersebut apa nama resepnya dancarapembuatannya bagaimana dan membutuhkan bahanbaku apa saja
*/ 
SELECT
	pr.Nama_Produk,
	r.Nama_Resep,
	r.Cara_Pembuatan,
	bb.Nama_Bahan_Baku
FROM detail_resep dr
JOIN resep r ON dr.ID_Resep = r.ID_Resep
JOIN produk_roti pr ON r.ID_Produk = pr.ID_Produk
JOIN bahan_baku bb ON dr.ID_BahanBaku = bb.ID_BahanBaku
WHERE pr.Nama_Produk = 'Donat Cokelat'
ORDER BY bb.Nama_Bahan_Baku;
/*
🧠 Soal 1 — Rata-rata, Total, dan Jumlah Produk yang Dijual per Cabang
Manajer regional ingin tahu bagaimana performa masing-masinh
 cabang toko. Untuk itu, ia ingin melihat:
Nama cabang
Jumlah transaksi penjualan yang terjadi
Total quantity produk roti yang terjual
Rata-rata quantity produk per transaksi
Urutkan berdasarkan rata-rata quantity per transaksi dari yang tertinggi.
Petunjuk: Gunakan COUNT(ID_Transaksi_Penjualan), 
SUM(Quantity), dan AVG(Quantity) yang digabungkan lewat GROUP BY cabang.
*/ 

SELECT 
	c.Nama_Cabang,
	COUNT(DISTINCT tp.ID_Transaksi_Penjualan) AS jumlahtransaksi,
	SUM(dt.Quantity) AS jumlahproduk,
	AVG(dt.Quantity) AS rataratapenjualan
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
GROUP BY c.Nama_Cabang
ORDER BY rataratapenjualan DESC;

/*
Supervisor gudang ingin mengevaluasi performa masing-masing pemasok. Ia ingin melihat:
	• Nama pemasok
	• Jumlah pembelian (berapa kali beli dari pemasok itu)
	• Total quantity bahan baku yang dibeli dari pemasok
	• Rata-rata quantity bahan baku per pembelian
Urutkan berdasarkan total quantity terbanyak.
Clue: Gunakan tabel pembelian_bahan_baku + detail_pembelian + pemasok. 
Gunakan fungsi COUNT, SUM, dan AVG dalam konteks pembelian.
*/ 
SELECT 
	p.Nama_Pemasok,
	p.Alamat_Pemasok,
	COUNT(DISTINCT dp.ID_DetailPembelian) AS jumlahpembelian,
	SUM(dp.Jumlah_Dibeli) AS totalbahanbakuyangdibeli,
	AVG(dp.Jumlah_Dibeli) AS rataratapembelian
FROM detail_pembelian dp
JOIN pembelian_bahan_baku pbb ON dp.ID_Pembelian = pbb.ID_Pembelian
JOIN pemasok p ON pbb.ID_Pemasok = p.ID_Pemasok
GROUP BY p.Nama_Pemasok, p.Alamat_Pemasok
ORDER BY rataratapembelian DESC;

SELECT * FROM pemasok;

SELECT 
	p.Nama,
	COUNT(DISTINCT p.ID_Pelanggan) AS Jumlah_Transaksi,
	SUM(dt.Quantity) AS totalproduk,
	SUM(dt.Quantity) * 1.0 / COUNT(DISTINCT tp.ID_Transaksi_Penjualan) AS rataratapenjualan
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
GROUP BY  p.Nama
ORDER BY  rataratapenjualan DESC;



/*
Tampilkan semua pelanggan 
yang tidak pernah melakukan transaksi di cabang dengan nama 'BreadHouse Jakarta'.
Hint: Gabungkan pelanggan dan transaksi_penjualan, 
lalu gunakan filtering dengan NOT IN atau LEFT JOIN dan IS NULL
*/
--  INI PUNYA KU
SELECT
p.Nama
FROM pelanggan p
LEFT JOIN transaksi_penjualan tp ON p.ID_Pelanggan = tp.ID_Pelanggan
LEFT JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
WHERE c.Nama_Cabang ='BreadHouse Central'
	AND tp.ID_Transaksi_Penjualan IS NULL
GROUP BY p.Nama;
-- INI PUNYA AI
SELECT p.Nama
FROM Pelanggan p
LEFT JOIN Transaksi_Penjualan tp 
    ON p.ID_Pelanggan = tp.ID_Pelanggan
    AND tp.ID_Cabang = (
        SELECT ID_Cabang 
        FROM Cabang 
        WHERE Nama_Cabang = 'BreadHouse Central'
    )
WHERE tp.ID_Transaksi_Penjualan IS NULL;



/*
Soal 3 (melibatkan logika rasio):
Untuk setiap pelanggan, tampilkan:
	• Nama pelanggan
	• Jumlah total produk yang pernah dibeli (SUM)
	• Jumlah transaksi unik (COUNT DISTINCT)
	• Rata-rata produk yang dibeli per transaksi
Urutkan hasilnya berdasarkan rata-rata produk per transaksi dari tertinggi ke terendah.
*/

SELECT 
	p.Nama,
	SUM(dt.Quantity) AS Jumlah_Produk_Yangpernahdibeli,
	pr.Nama_Produk AS namaprodukyangdibeli,
	COUNT(dt.ID_Detail_Transaksi) AS jumlahtransaksi,
	AVG(dt.Quantity) ratarata_pembelian
FROM detail_transaksi dt
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
GROUP BY p.Nama
ORDER BY ratarata_pembelian DESC;


/*
tampilkan:
• Nama cabang

• Total jumlah produk roti yang terjual di cabang tersebut dalam periode yang sama
• Rata-rata jumlah produk per pelanggan (total produk / jumlah pelanggan unik)
• Tambahkan kolom: Jenis Cabang (Produksi/Penjualan/Produksi & Penjualan), berdasarkan 
status cabang (Gunakan Cabang_Produksi dan Cabang_Penjualan)
• Urutkan berdasarkan rata-rata produk per pelanggan, dari tertinggi ke terendah.
⚠️ Catatan: 
• Gunakan DISTINCT ID_Pelanggan untuk menghitung jumlah pelanggan unik

• Gunakan CASE WHEN untuk menentukan jenis cabang
• Gunakan LEFT JOIN agar semua cabang tetap muncul, termasuk yang belum ada transaksi

*/

SELECT * FROM transaksi_penjualan;

SELECT 
	p.Nama,
	SUM(dt.Quantity) AS jumlahtransaksi,
	SUM(dt.Total_Harga) AS uangyangdikeluarkan,
	pr.Nama_Produk AS produkyangdibeli,
	CASE
		WHEN cp.ID_CabangProduk IS NOT NULL THEN 'Produksi'
	ELSE 
		'Penjualan'
	END AS 'jeniscabang'
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN cabang c ON tp.ID_Cabang =  c.ID_Cabang
LEFT JOIN cabang_produksi cp ON c.ID_Cabang = cp.ID_CabangProduk
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
GROUP BY p.Nama, pr.Nama_Produk
ORDER BY jumlahtransaksi DESC, uangyangdikeluarkan DESC ;

-- salah memahami soal


📊 Soal 1 (Menggunakan COUNT DISTINCT dan SUM):
Di toko roti, manajer ingin melihat jumlah produk yang dibeli 
oleh setiap pelanggan, dengan rincian sebagai berikut:
	• Nama pelanggan
	• Total produk yang dibeli (jumlah produk terjual, SUM)
	• Jumlah transaksi unik (COUNT DISTINCT)
Tampilkan hasilnya berdasarkan jumlah transaksi unik yang paling banyak,
 dari yang tertinggi hingga terendah.

SELECT
	p.Nama,
	SUM(dt.Quantity) AS jumlahprodukyangdibeli,
	COUNT(DISTINCT tp.ID_Transaksi_Penjualan) AS jumlahtransaksi,
	CASE 
		WHEN cp.ID_CabangProduk IS NOT NULL THEN 'produksi'
	ELSE 
		'penjualan'
	END AS 'jeniscabang'
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
LEFT JOIN cabang_produksi cp ON c.ID_Cabang = cp.ID_CabangProduk
GROUP BY p.Nama, jeniscabang
ORDER BY jumlahtransaksi DESC;


Soal 2 (Menggunakan AVG dan CASE WHEN ELSE):
Manajer ingin melihat total penjualan dan
 rata-rata jumlah transaksi per produk roti di setiap cabang.
 Buatlah query yang menghasilkan data berikut:
	• Nama produk
	• Total produk yang terjual (SUM)
	• Rata-rata produk yang terjual per transaksi (AVG)
	• Jenis cabang yang memproduksi produk tersebut: "PRODUKSI" jika cabang
	 tersebut memiliki fasilitas produksi dan "PENJUALAN" jika tidak.
Tampilkan hasil berdasarkan total produk yang terjual, dari yang tertinggi hingga terendah.

SELECT
	pr.Nama_Produk,
	SUM(dt.Quantity) AS jumlahprodukyangdibeli,
	AVG(dt.Quantity) AS ratarataprodukterjual,
	CASE 
		WHEN cp.ID_CabangProduk IS NOT NULL THEN 'produksi'
	ELSE 
		'penjualan'
	END AS 'jeniscabang'
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
LEFT JOIN cabang_produksi cp ON c.ID_Cabang = cp.ID_CabangProduk
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
GROUP BY pr.Nama_Produk, jeniscabang
ORDER BY jumlahprodukyangdibeli DESC;


Soal 3 (Menggunakan COUNT DISTINCT, SUM, AVG, dan CASE WHEN ELSE):
Toko roti ingin mengetahui performa penjualan berdasarkan kategori produk yang dibeli oleh pelanggan:
	• Nama pelanggan
	• Kategori produk yang dibeli
	• Jumlah total produk yang dibeli (SUM)
	• Rata-rata produk yang dibeli per transaksi (AVG)
	• Jumlah transaksi unik berdasarkan kategori produk (COUNT DISTINCT)
Gunakan CASE WHEN ELSE untuk menampilkan kategori produk berdasarkan jenisnya: "Roti Tawar", "Donat", atau "Pastry". Urutkan hasilnya berdasarkan rata-rata produk yang dibeli per transaksi, dari yang tertinggi hingga terendah.

SELECT 
	p.Nama,
	CASE 
		WHEN pr.Jenis_Produk = 'Roti Tawar' THEN 'Roti Tawar'
		WHEN pr.Jenis_Produk = 'Donat' THEN 'Donat'
		WHEN pr.Jenis_Produk = 'Pastry' THEN 'Pastry'
	ELSE 'lainnya'
	END AS 'jenisproduk',
	tp.Tanggal_Transaksi,
	SUM(dt.Quantity) AS jumlahtotalprodukyangdibeli,
	AVG(dt.Quantity) AS ratarataproduk,
	COUNT(DISTINCT tp.ID_Transaksi_Penjualan) AS idpenjualanunik
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
GROUP BY p.Nama, jenisproduk, tp.Tanggal_Transaksi
ORDER BY jumlahtotalprodukyangdibeli DESC;




SELECT
	p.Nama,
	pr.Nama_Produk,
	tp.Tanggal_Transaksi,
	c.Nama_Cabang,
	CASE 
		WHEN cp.ID_CabangProduk IS NOT NULL THEN 'PRODUKSI'
	ELSE 
		'PENJUALAN'
	END AS 'JENISCABANG'
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
LEFT JOIN cabang_produksi cp ON c.ID_Cabang = cp.ID_CabangProduk
GROUP BY p.Nama
ORDER BY pr.Nama_Produk ASC;
/*
Manajer ingin mengetahui jumlah transaksi penjualan yang terjadi di setiap cabang. 
Tampilkan nama cabang dan jumlah transaksi yang terjadi di setiap cabang. 
Urutkan hasilnya berdasarkan jumlah transaksi.
Yang perlu dikuasai:
Gunakan COUNT, GROUP BY, dan ORDER BY.
*/
SELECT 
	c.Nama_Cabang,
	COUNT(DISTINCT dt.ID_Detail_Transaksi) AS jumlahtransaksi
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
GROUP BY c.Nama_Cabang
ORDER BY jumlahtransaksi DESC;
/*
Di toko roti, manajer ingin mengetahui total jumlah produk yang terjual pada setiap 
cabang penjualan, tetapi hanya untuk pelanggan yang memiliki keanggotaan Silver dan Gold.
Tampilkan nama cabang penjualan, nama produk, dan jumlah produk yang terjual.
Urutkan berdasarkan nama produk secara menurun.
Yang perlu dikuasai:
JOIN antar tabel Keanggotaan, Pelanggan, Cabang Penjualan, dan Produk Roti.
WHERE untuk memfilter keanggotaan, SUM, GROUP BY, dan ORDER BY.
*/
SELECT
	c.Nama_Cabang,
	pr.Nama_Produk,
	SUM(dt.Quantity) AS jumlahprodukyangterjual,
	p.Nama, k.StatusMember,
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN keanggotaan k ON p.ID_Keanggotaan = k.ID_Keanggotaan
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
WHERE k.StatusMember IN  ('Silver','Gold') 
GROUP BY c.Nama_Cabang, pr.Nama_Produk, p.Nama
ORDER BY jumlahprodukyangterjual DESC;





-- tugasbesarbismillah-- Hapus tabel jika sudah ada (urutan disesuaikan untuk foreign key constraints)
/*
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
DROP TABLE IF EXISTS pemasok;
*/
-- TABEL DASAR DAN MASTER
CREATE TABLE Keanggotaan (
    ID_Keanggotaan INT AUTO_INCREMENT PRIMARY KEY,
    StatusMember VARCHAR(50) NOT NULL UNIQUE,
    ManfaatMember DECIMAL(4,2) DEFAULT 0.00
);

CREATE TABLE Pelanggan (
    ID_Pelanggan INT AUTO_INCREMENT PRIMARY KEY,
    ID_Keanggotaan INT NULL,
    Nama VARCHAR(100) NOT NULL,
    Alamat TEXT,
    No_Telepon VARCHAR(20) UNIQUE,
    Email VARCHAR(100) UNIQUE,
    FOREIGN KEY (ID_Keanggotaan) REFERENCES Keanggotaan(ID_Keanggotaan) ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE TABLE Cabang (
    ID_Cabang INT AUTO_INCREMENT PRIMARY KEY,
    Nama_Cabang VARCHAR(100) NOT NULL UNIQUE,
    Alamat TEXT NOT NULL,
    Luas_Area DECIMAL(10,2)
);

CREATE TABLE Cabang_Produksi (
    ID_CabangProduk INT PRIMARY KEY,
    Dapur_Produksi BOOLEAN DEFAULT TRUE,
    Gudang_Penyimpanan BOOLEAN DEFAULT TRUE,
    Area_Penjualan BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (ID_CabangProduk) REFERENCES Cabang(ID_Cabang) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Cabang_Penjualan (
    ID_CabangPenjualan INT PRIMARY KEY,
    Area_Penjualan BOOLEAN DEFAULT TRUE,
    Gudang_Penyimpanan BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (ID_CabangPenjualan) REFERENCES Cabang(ID_Cabang) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Pemasok (
    ID_Pemasok INT AUTO_INCREMENT PRIMARY KEY,
    Nama_Pemasok VARCHAR(100) NOT NULL,
    Alamat_Pemasok TEXT
);

CREATE TABLE Produk_Roti (
    ID_Produk INT AUTO_INCREMENT PRIMARY KEY,
    Kode_Produk VARCHAR(20) NOT NULL UNIQUE,
    Nama_Produk VARCHAR(100) NOT NULL,
    Jenis_Produk VARCHAR(50),
    Harga DECIMAL(10, 2) NOT NULL,
    Stok_Roti INT DEFAULT 0
);

-- Tabel Resep yang sudah diperbaiki
CREATE TABLE Resep (
    ID_Resep INT AUTO_INCREMENT PRIMARY KEY,
    ID_Produk INT NOT NULL UNIQUE,
    Nama_Resep VARCHAR(100) NOT NULL,
    Cara_Pembuatan TEXT,
    FOREIGN KEY (ID_Produk) REFERENCES Produk_Roti(ID_Produk) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Tabel Bahan Baku yang diperbaiki, menghilangkan ID_Resep
CREATE TABLE Bahan_Baku (
    ID_BahanBaku INT AUTO_INCREMENT PRIMARY KEY,
    Kode_BahanBaku VARCHAR(20) NOT NULL UNIQUE,
    Nama_Bahan_Baku VARCHAR(100) NOT NULL,
    JumlahStok DECIMAL(10, 2) DEFAULT 0,
    Satuan_Bahan VARCHAR(20) NOT NULL
);

-- Tabel Detail_Resep baru untuk menghubungkan Resep dan Bahan Baku
CREATE TABLE Detail_Resep (
    ID_Detail_Resep INT AUTO_INCREMENT PRIMARY KEY,
    ID_Resep INT NOT NULL,
    ID_BahanBaku INT NOT NULL,
    Jumlah_Bahan_Dibutuhkan DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (ID_Resep) REFERENCES Resep(ID_Resep) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ID_BahanBaku) REFERENCES Bahan_Baku(ID_BahanBaku) ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE KEY (ID_Resep, ID_BahanBaku)
);

-- TABEL TRANSAKSIONAL
CREATE TABLE Transaksi_Penjualan (
    ID_Transaksi_Penjualan INT AUTO_INCREMENT PRIMARY KEY,
    ID_Pelanggan INT NULL,
    ID_Cabang INT NOT NULL,
    Tanggal_Transaksi DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Total_Harga DECIMAL(12, 2) NOT NULL DEFAULT 0,
    FOREIGN KEY (ID_Pelanggan) REFERENCES Pelanggan(ID_Pelanggan) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (ID_Cabang) REFERENCES Cabang(ID_Cabang) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Detail_Transaksi (
    ID_Detail_Transaksi INT AUTO_INCREMENT PRIMARY KEY,
    ID_Transaksi_Penjualan INT NOT NULL,
    ID_Produk INT NOT NULL,
    Quantity INT NOT NULL,
    Total_Harga DECIMAL(12, 2) NOT NULL,
    FOREIGN KEY (ID_Transaksi_Penjualan) REFERENCES Transaksi_Penjualan(ID_Transaksi_Penjualan) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ID_Produk) REFERENCES Produk_Roti(ID_Produk) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE Pembelian_Bahan_Baku (
    ID_Pembelian INT AUTO_INCREMENT PRIMARY KEY,
    ID_Cabang INT NOT NULL,
    ID_Pemasok INT NOT NULL,
    Tanggal_Pembelian DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    Total_Harga DECIMAL(12, 2) DEFAULT 0.00,
    FOREIGN KEY (ID_Cabang) REFERENCES Cabang_Produksi(ID_CabangProduk) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (ID_Pemasok) REFERENCES Pemasok(ID_Pemasok) ON DELETE RESTRICT ON UPDATE CASCADE
);

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



-- MENGISI DATA UNTUK SISTEM MANAJEMEN TOKO ROTI

-- 1. Data Keanggotaan
INSERT INTO Keanggotaan (ID_Keanggotaan, StatusMember, ManfaatMember) VALUES
(1001, 'Regular', 0.00),
(1002, 'Silver', 0.10),
(1003, 'Gold', 0.15),
(1004, 'Diamond', 0.25);

-- 2. Data Pelanggan
INSERT INTO Pelanggan (ID_Pelanggan, ID_Keanggotaan, Nama, Alamat, No_Telepon, Email) VALUES
(2001, 1001, 'Budi Santoso', 'Jl. Merdeka No. 123, Jakarta', '081234567890', 'budi@example.com'),
(2002, 1002, 'Siti Rahayu', 'Jl. Pahlawan No. 45, Bandung', '082345678901', 'siti@example.com'),
(2003, 1003, 'Ahmad Hidayat', 'Jl. Diponegoro No. 67, Surabaya', '083456789012', 'ahmad@example.com'),
(2004, 1004, 'Dewi Sulistiawati', 'Jl. Gajah Mada No. 89, Semarang', '084567890123', 'dewi@example.com'),
(2005, 1001, 'Joko Widodo', 'Jl. Veteran No. 101, Solo', '085678901234', 'joko@example.com'),
(2006, 1002, 'Ani Yudhoyono', 'Jl. Sudirman No. 202, Jakarta', '086789012345', 'ani@example.com'),
(2007, 1001, 'Rizki Pratama', 'Jl. Ahmad Yani No. 303, Medan', '087890123456', 'rizki@example.com'),
(2008, 1003, 'Nina Sari', 'Jl. Pemuda No. 404, Yogyakarta', '088901234567', 'nina@example.com'),
(2009, 1001, 'Dodi Irawan', 'Jl. Hayam Wuruk No. 505, Bali', '089012345678', 'dodi@example.com'),
(2010, 1002, 'Lisa Permata', 'Jl. Thamrin No. 606, Jakarta', '081123456789', 'lisa@example.com');

-- 3. Data Cabang
INSERT INTO Cabang (ID_Cabang, Nama_Cabang, Alamat, Luas_Area) VALUES
(3001, 'BreadHouse Central', 'Jl. Gatot Subroto No. 123, Jakarta Selatan', 250.00),
(3002, 'BreadHouse Bandung', 'Jl. Asia Afrika No. 456, Bandung', 180.00),
(3003, 'BreadHouse Surabaya', 'Jl. Tunjungan No. 789, Surabaya', 220.00),
(3004, 'BreadHouse Outlet Mall', 'Mall Kota Kasablanka Lt. 3, Jakarta', 120.00),
(3005, 'BreadHouse Express', 'Terminal Pulogebang, Jakarta Timur', 80.00);

-- 4. Data Cabang Produksi (cabang yang memiliki fasilitas produksi)
INSERT INTO Cabang_Produksi (ID_CabangProduk, Dapur_Produksi, Gudang_Penyimpanan, Area_Penjualan) VALUES
(3001, TRUE, TRUE, TRUE),
(3002, TRUE, TRUE, TRUE),
(3003, TRUE, TRUE, TRUE);

-- 5. Data Cabang Penjualan (cabang yang hanya untuk penjualan)
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
(8001, 6001, 7001, 1.00),    -- 1 kg Tepung Terigu
(8002, 6001, 7003, 0.10),    -- 0.1 kg Gula Pasir
(8003, 6001, 7010, 0.02),    -- 0.02 kg Ragi Instan
(8004, 6001, 7011, 0.01),    -- 0.01 kg Garam
(8005, 6001, 7005, 0.10),    -- 0.1 kg Mentega

-- Resep Roti Gandum (ID_Resep: 6002)
(8006, 6002, 7002, 1.00),    -- 1 kg Tepung Gandum
(8007, 6002, 7017, 0.10),    -- 0.1 kg Madu
(8008, 6002, 7010, 0.02),    -- 0.02 kg Ragi Instan
(8009, 6002, 7011, 0.01),    -- 0.01 kg Garam
(8010, 6002, 7005, 0.10),    -- 0.1 kg Mentega

-- Resep Donat Cokelat (ID_Resep: 6003)
(8011, 6003, 7001, 0.50),    -- 0.5 kg Tepung Terigu
(8012, 6003, 7003, 0.15),    -- 0.15 kg Gula Pasir
(8013, 6003, 7010, 0.01),    -- 0.01 kg Ragi Instan
(8014, 6003, 7004, 4.00),    -- 4 butir Telur Ayam
(8015, 6003, 7005, 0.10),    -- 0.1 kg Mentega
(8016, 6003, 7006, 0.20),    -- 0.2 liter Susu Cair
(8017, 6003, 7008, 0.15),    -- 0.15 kg Cokelat Batang (untuk glaze)

-- Resep Donat Stroberi (ID_Resep: 6004)
(8018, 6004, 7001, 0.50),    -- 0.5 kg Tepung Terigu
(8019, 6004, 7003, 0.15),    -- 0.15 kg Gula Pasir
(8020, 6004, 7010, 0.01),    -- 0.01 kg Ragi Instan
(8021, 6004, 7004, 4.00),    -- 4 butir Telur Ayam
(8022, 6004, 7005, 0.10),    -- 0.1 kg Mentega
(8023, 6004, 7006, 0.20),    -- 0.2 liter Susu Cair
(8024, 6004, 7012, 0.10),    -- 0.1 kg Pasta Stroberi (untuk glaze)

-- Resep Donat Vanilla (ID_Resep: 6005)
(8025, 6005, 7001, 0.50),    -- 0.5 kg Tepung Terigu
(8026, 6005, 7003, 0.15),    -- 0.15 kg Gula Pasir
(8027, 6005, 7010, 0.01),    -- 0.01 kg Ragi Instan
(8028, 6005, 7004, 4.00),    -- 4 butir Telur Ayam
(8029, 6005, 7005, 0.10),    -- 0.1 kg Mentega
(8030, 6005, 7006, 0.20),    -- 0.2 liter Susu Cair
(8031, 6005, 7013, 0.08),    -- 0.08 kg Pasta Vanilla (untuk glaze)

-- Resep untuk produk lainnya diisi sebagian untuk menyingkat
-- Croissant Plain (ID_Resep: 6006)
(8032, 6006, 7001, 0.70),    -- 0.7 kg Tepung Terigu
(8033, 6006, 7005, 0.30),    -- 0.3 kg Mentega
(8034, 6006, 7010, 0.02),    -- 0.02 kg Ragi Instan

-- Croissant Almond (ID_Resep: 6007)
(8035, 6007, 7001, 0.70),    -- 0.7 kg Tepung Terigu
(8036, 6007, 7005, 0.30),    -- 0.3 kg Mentega
(8037, 6007, 7014, 0.15),    -- 0.15 kg Almond Slice

-- Red Velvet Cake (ID_Resep: 6010)
(8038, 6010, 7001, 0.50),    -- 0.5 kg Tepung Terigu
(8039, 6010, 7003, 0.40),    -- 0.4 kg Gula Pasir
(8040, 6010, 7009, 0.10),    -- 0.1 kg Cokelat Bubuk
(8041, 6010, 7018, 0.03),    -- 0.03 liter Pewarna Makanan Merah
(8042, 6010, 7019, 0.25);    -- 0.25 kg Cream Cheese

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
-- Pembelian ID 9001
(10001, 9001, 7001, 200.00, 15000.00),    -- 200 kg Tepung Terigu @ Rp 15,000/kg
(10002, 9001, 7002, 100.00, 20000.00),    -- 100 kg Tepung Gandum @ Rp 20,000/kg

-- Pembelian ID 9002
(10003, 9002, 7004, 500.00, 2000.00),     -- 500 butir Telur Ayam @ Rp 2,000/butir
(10004, 9002, 7010, 10.00, 100000.00),    -- 10 kg Ragi Instan @ Rp 100,000/kg

-- Pembelian ID 9003
(10005, 9003, 7003, 100.00, 15000.00),    -- 100 kg Gula Pasir @ Rp 15,000/kg
(10006, 9003, 7011, 20.00, 10000.00),     -- 20 kg Garam @ Rp 10,000/kg
(10007, 9003, 7017, 10.00, 80000.00),     -- 10 kg Madu @ Rp 80,000/kg

-- Pembelian ID 9004
(10008, 9004, 7001, 150.00, 15000.00),    -- 150 kg Tepung Terigu @ Rp 15,000/kg
(10009, 9004, 7005, 50.00, 30000.00),     -- 50 kg Mentega @ Rp 30,000/kg
(10010, 9004, 7006, 100.00, 15000.00),    -- 100 liter Susu Cair @ Rp 15,000/liter

-- Pembelian ID 9005
(10011, 9005, 7006, 80.00, 15000.00),     -- 80 liter Susu Cair @ Rp 15,000/liter
(10012, 9005, 7007, 30.00, 20000.00),     -- 30 kg Susu Bubuk @ Rp 20,000/kg

-- Pembelian ID 9006
(10013, 9006, 7008, 30.00, 80000.00),     -- 30 kg Cokelat Batang @ Rp 80,000/kg
(10014, 9006, 7009, 20.00, 60000.00),     -- 20 kg Cokelat Bubuk @ Rp 60,000/kg

-- Pembelian ID 9007
(10015, 9007, 7004, 400.00, 2000.00),     -- 400 butir Telur Ayam @ Rp 2,000/butir
(10016, 9007, 7019, 15.00, 100000.00),    -- 15 kg Cream Cheese @ Rp 100,000/kg

-- Pembelian ID 9008
(10017, 9008, 7012, 10.00, 60000.00),     -- 10 kg Pasta Stroberi @ Rp 60,000/kg
(10018, 9008, 7013, 8.00, 70000.00),      -- 8 kg Pasta Vanilla @ Rp 70,000/kg
(10019, 9008, 7014, 5.00, 120000.00);     -- 5 kg Almond Slice @ Rp 120,000/kg

-- 13. Data Penggunaan Bahan Baku
INSERT INTO Penggunaan_Bahan_Baku (ID_Penggunaan, ID_BahanBaku, ID_Cabang, Tanggal_Penggunaan, Jumlah_Bahan_Digunakan, ID_Produk_Yang_Dibuat) VALUES
-- Penggunaan untuk Roti Tawar Original
(11001, 7001, 3001, '2023-05-10 07:00:00', 10.00, 5001),    -- 10 kg Tepung Terigu
(11002, 7003, 3001, '2023-05-10 07:00:00', 1.00, 5001),     -- 1 kg Gula Pasir
(11003, 7010, 3001, '2023-05-10 07:00:00', 0.20, 5001),     -- 0.2 kg Ragi Instan

-- Penggunaan untuk Donat Cokelat
(11004, 7001, 3002, '2023-05-10 08:00:00', 5.00, 5003),     -- 5 kg Tepung Terigu
(11005, 7003, 3002, '2023-05-10 08:00:00', 1.50, 5003),     -- 1.5 kg Gula Pasir
(11006, 7004, 3002, '2023-05-10 08:00:00', 40.00, 5003),    -- 40 butir Telur Ayam
(11007, 7008, 3002, '2023-05-10 08:00:00', 1.50, 5003),     -- 1.5 kg Cokelat Batang

-- Penggunaan untuk Croissant Almond
(11008, 7001, 3003, '2023-05-10 09:00:00', 7.00, 5007),     -- 7 kg Tepung Terigu
(11009, 7005, 3003, '2023-05-10 09:00:00', 3.00, 5007),     -- 3 kg Mentega
(11010, 7014, 3003, '2023-05-10 09:00:00', 1.50, 5007),     -- 1.5 kg Almond Slice

-- Penggunaan untuk Red Velvet Cake
(11011, 7001, 3001, '2023-05-11 07:30:00', 5.00, 5010),     -- 5 kg Tepung Terigu
(11012, 7003, 3001, '2023-05-11 07:30:00', 4.00, 5010),     -- 4 kg Gula Pasir
(11013, 7009, 3001, '2023-05-11 07:30:00', 1.00, 5010),     -- 1 kg Cokelat Bubuk
(11014, 7018, 3001, '2023-05-11 07:30:00', 0.30, 5010),     -- 0.3 liter Pewarna Makanan Merah
(11015, 7019, 3001, '2023-05-11 07:30:00', 2.50, 5010);     -- 2.5 kg Cream Cheese

-- 14. Data Pengiriman Produk
INSERT INTO Pengiriman_Produk (ID_Pengiriman, ID_CabangProduk, ID_CabangPenjualan, ID_Produk, Tanggal_Pengiriman, Jumlah_Produk) VALUES
(12001, 3001, 3004, 5001, '2023-05-12 06:00:00', 20),   -- 20 Roti Tawar Original dari Cabang 3001 ke 3004
(12002, 3001, 3004, 5002, '2023-05-12 06:00:00', 15),   -- 15 Roti Gandum dari Cabang 3001 ke 3004
(12003, 3002, 3004, 5003, '2023-05-12 07:30:00', 30),   -- 30 Donat Cokelat dari Cabang 3002 ke 3004
(12004, 3002, 3004, 5004, '2023-05-12 07:30:00', 25),   -- 25 Donat Stroberi dari Cabang 3002 ke 3004
(12005, 3003, 3005, 5006, '2023-05-12 08:45:00', 20),   -- 20 Croissant Plain dari Cabang 3003 ke 3005
(12006, 3003, 3005, 5007, '2023-05-12 08:45:00', 15),   -- 15 Croissant Almond dari Cabang 3003 ke 3005
(12007, 3001, 3005, 5010, '2023-05-13 06:30:00', 10),   -- 10 Red Velvet Cake dari Cabang 3001 ke 3005
(12008, 3001, 3005, 5011, '2023-05-13 06:30:00', 8),    -- 8 Choco Lava Cake dari Cabang 3001 ke 3005
(12009, 3002, 3004, 5005, '2023-05-13 07:15:00', 30),   -- 30 Donat Vanilla dari Cabang 3002 ke 3004
(12010, 3001, 3004, 5012, '2023-05-13 08:00:00', 15);   -- 15 Bread Pudding dari Cabang 3001 ke 3004

-- 15. Data Transaksi Penjualan
INSERT INTO Transaksi_Penjualan (ID_Transaksi_Penjualan, ID_Pelanggan, ID_Cabang, Tanggal_Transaksi, Total_Harga) VALUES
(13001, 2002, 3001, '2023-05-15 10:30:00', 43200.00),  -- Member Silver (10% diskon)
(13002, NULL, 3001, '2023-05-15 11:45:00', 38000.00),  -- Non-member
(13003, 2003, 3002, '2023-05-15 13:20:00', 51000.00),  -- Member Gold (15% diskon)
(13004, 2001, 3003, '2023-05-15 14:35:00', 30000.00),  -- Non-member
(13005, 2004, 3004, '2023-05-16 09:15:00', 33750.00),  -- Member Diamond (25% diskon)
(13006, NULL, 3004, '2023-05-16 10:30:00', 24000.00),  -- Non-member
(13007, 2006, 3005, '2023-05-16 12:45:00', 32400.00),  -- Member Silver (10% diskon)
(13008, 2008, 3001, '2023-05-16 15:20:00', 61200.00),  -- Member Gold (15% diskon)
(13009, NULL, 3002, '2023-05-17 09:45:00', 15000.00),  -- Non-member
(13010, 2010, 3003, '2023-05-17 11:10:00', 25200.00),  -- Member Silver (10% diskon)
(13011, NULL, 3004, '2023-05-17 13:30:00', 30000.00),  -- Non-member
(13012, 2004, 3005, '2023-05-17 16:15:00', 33750.00);  -- Member Diamond (25% diskon)

-- 16. Data Detail Transaksi
INSERT INTO Detail_Transaksi (ID_Detail_Transaksi, ID_Transaksi_Penjualan, ID_Produk, Quantity, Total_Harga) VALUES
-- Transaksi ID 13001 (Member Silver - 10% diskon)
(14001, 13001, 5001, 2, 27000.00),  -- 2 Roti Tawar Original: 2 x 15000 = 30000 - 10% = 27000
(14002, 13001, 5003, 2, 14400.00),  -- 2 Donat Cokelat: 2 x 8000 = 16000 - 10% = 14400
(14003, 13001, 5006, 1, 10800.00),  -- 1 Croissant Plain: 1 x 12000 = 12000 - 10% = 10800

-- Transaksi ID 13002 (Non-member)
(14004, 13002, 5003, 3, 24000.00),  -- 3 Donat Cokelat: 3 x 8000 = 24000
(14005, 13002, 5005, 2, 15000.00),  -- 2 Donat Vanilla: 2 x 7500 = 15000

-- Transaksi ID 13003 (Member Gold - 15% diskon)
(14006, 13003, 5002, 2, 30600.00),  -- 2 Roti Gandum: 2 x 18000 = 36000 - 15% = 30600
(14007, 13003, 5007, 1, 12750.00),  -- 1 Croissant Almond: 1 x 15000 = 15000 - 15% = 12750
(14008, 13003, 5008, 1, 8500.00),   -- 1 Bagel Sesame: 1 x 10000 = 10000 - 15% = 8500

-- Transaksi ID 13004 (Non-member)
(14009, 13004, 5001, 2, 30000.00),  -- 2 Roti Tawar Original: 2 x 15000 = 30000

-- Transaksi ID 13005 (Member Diamond - 25% diskon)
(14010, 13005, 5010, 1, 18750.00),  -- 1 Red Velvet Cake: 1 x 25000 = 25000 - 25% = 18750
(14011, 13005, 5011, 1, 16500.00),  -- 1 Choco Lava Cake: 1 x 22000 = 22000 - 25% = 16500

-- Transaksi ID 13006 (Non-member)
(14012, 13006, 5003, 3, 24000.00),  -- 3 Donat Cokelat: 3 x 8000 = 24000

-- Transaksi ID 13007 (Member Silver - 10% diskon)
(14013, 13007, 5006, 3, 32400.00),  -- 3 Croissant Plain: 3 x 12000 = 36000 - 10% = 32400

-- Transaksi ID 13008 (Member Gold - 15% diskon)
(14014, 13008, 5002, 2, 30600.00),  -- 2 Roti Gandum: 2 x 18000 = 36000 - 15% = 30600
(14015, 13008, 5010, 1, 21250.00),  -- 1 Red Velvet Cake: 1 x 25000 = 25000 - 15% = 21250
(14016, 13008, 5008, 1, 8500.00),   -- 1 Bagel Sesame: 1 x 10000 = 10000 - 15% = 8500

-- Transaksi ID 13009 (Non-member)
(14017, 13009, 5001, 1, 15000.00),  -- 1 Roti Tawar Original: 1 x 15000 = 15000

-- Transaksi ID 13010 (Member Silver - 10% diskon)
(14018, 13010, 5007, 1, 13500.00),  -- 1 Croissant Almond: 1 x 15000 = 15000 - 10% = 13500
(14019, 13010, 5009, 1, 9900.00),   -- 1 Bagel Garlic: 1 x 11000 = 11000 - 10% = 9900
(14020, 13010, 5003, 1, 7200.00),   -- 1 Donat Cokelat: 1 x 8000 = 8000 - 10% = 7200

-- Transaksi ID 13011 (Non-member)
(14021, 13011, 5001, 2, 30000.00),  -- 2 Roti Tawar Original: 2 x 15000 = 30000

-- Transaksi ID 13012 (Member Diamond - 25% diskon)
(14022, 13012, 5010, 1, 18750.00),  -- 1 Red Velvet Cake: 1 x 25000 = 25000 - 25% = 18750
(14023, 13012, 5011, 1, 16500.00);  -- 1 Choco Lava Cake: 1 x 22000 = 22000 - 25% = 16500

-- 17. Data Pencatatan
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

-- ================================================================================================
INSERT INTO Pelanggan (ID_Pelanggan, ID_Keanggotaan, Nama, Alamat, No_Telepon, Email) VALUES
(2011, 1001, 'Roni Wicaksono', 'Jl. Danau Toba No. 45, Jakarta', '081234987654', 'roni@example.com'),
(2012, 1001, 'Maria Anggraini', 'Jl. Kebon Jeruk No. 78, Jakarta', '082345098765', 'maria@example.com'),
(2013, 1001, 'Taufik Rahman', 'Jl. Ciliwung No. 23, Bandung', '083456109876', 'taufik@example.com'),
(2014, 1001, 'Sinta Dewi', 'Jl. Panglima Polim No. 55, Jakarta', '084567210987', 'sinta@example.com');

-- Mengupdate data transaksi penjualan yang sebelumnya NULL
UPDATE Transaksi_Penjualan SET ID_Pelanggan = 2011 WHERE ID_Transaksi_Penjualan = 13002;
UPDATE Transaksi_Penjualan SET ID_Pelanggan = 2012 WHERE ID_Transaksi_Penjualan = 13006;
UPDATE Transaksi_Penjualan SET ID_Pelanggan = 2013 WHERE ID_Transaksi_Penjualan = 13009;
UPDATE Transaksi_Penjualan SET ID_Pelanggan = 2014 WHERE ID_Transaksi_Penjualan = 13011;



-- Query untuk menampilkan data transaksi dengan informasi cabang
SELECT 
    tp.ID_Transaksi_Penjualan,
    p.Nama AS Nama_Pelanggan,
    k.StatusMember,
    c.Nama_Cabang,
    c.Alamat,  -- Menyesuaikan nama kolom dengan yang ada di tabel Cabang
    tp.Tanggal_Transaksi,
    pr.Nama_Produk,
    dt.Quantity,
    dt.Total_Harga,
    CASE 
        WHEN cp.ID_CabangProduk IS NOT NULL THEN 'Cabang Produksi'  -- Jika Cabang_Produksi ada, berarti cabang produksi
        ELSE 'Cabang Penjualan'  -- Jika tidak ada Cabang_Produksi, berarti cabang penjualan
    END AS Jenis_Cabang
FROM Transaksi_Penjualan tp
JOIN Pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN Keanggotaan k ON p.ID_Keanggotaan = k.ID_Keanggotaan
JOIN Cabang c ON tp.ID_Cabang = c.ID_Cabang
LEFT JOIN Cabang_Produksi cp ON c.ID_Cabang = cp.ID_CabangProduk  -- Menambahkan join dengan Cabang_Produksi
JOIN Detail_Transaksi dt ON tp.ID_Transaksi_Penjualan = dt.ID_Transaksi_Penjualan
JOIN Produk_Roti pr ON dt.ID_Produk = pr.ID_Produk
ORDER BY tp.Tanggal_Transaksi, tp.ID_Transaksi_Penjualan;



-- ============================================================
-- latihan soal mudah  

-- soal 1 dimana harus menampilkan nama produk dan harga tapi dengan
-- harga dari terbesar ke terkecil
SELECT nama_produk, harga
FROM produk_roti
ORDER BY harga DESC;


-- soal 2 dimana harus menampilkan harga_produk, stokroti, haraga dan nilait total
-- nilai total diambil dari harga kali jumlah stok roti
-- llalu di desc terkait nilai tottal nya
SELECT nama_produk, 
Stok_Roti AS jumlahstok, 
Harga AS hargaasli,
(Harga * Stok_Roti) AS nilaitotal
FROM produk_roti
ORDER BY nilaitotal DESC;


-- soal 3;
-- Tampilkan nama pelanggan dan alamat mereka dari tabel Pelanggan.
SELECT 
Id_Pelanggan AS ktp,
Nama AS nama_pelanggan, 
Alamat
FROM pelanggan
ORDER BY Nama ASC, ktp DESC;



SELECT p.Nama, SUM(t.Total_Harga * k.ManfaatMember) AS Total_Diskon, k.StatusMember AS LEVEL, k.ManfaatMember AS diskonnya
FROM Transaksi_Penjualan t
JOIN Pelanggan p ON t.ID_Pelanggan = p.ID_Pelanggan
JOIN Keanggotaan k ON p.ID_Keanggotaan = k.ID_Keanggotaan
GROUP BY p.Nama;









-- soal dimana suruh menampilkan id, nama, alamt dan jenis cabang
SELECT
c.Id_Cabang AS nomorinduk,
c.Nama_cabang AS namacabang,
c.Alamat,
CASE
WHEN cp.ID_CabangPenjualan IS NOT NULL THEN 'Penjualan'
ELSE 'Produksi'
END AS jenis_cabang
FROM cabang c
LEFT JOIN Cabang_Penjualan cp ON c.ID_Cabang = cp.ID_CabangPenjualan
ORDER BY c.ID_Cabang DESC;	


SELECT
c.ID_Cabang AS NOMORINDUK,
c.Nama_Cabang AS NAMACABANG,
c.Alamat,
CASE
WHEN cp.ID_CabangProduk IS NOT NULL THEN 'produksi'
ELSE 'penjualan'
END AS jeniscabang
FROM cabang c
LEFT JOIN Cabang_Produksi cp on c.ID_Cabang = cp.ID_CabangProduk
ORDER BY c.ID_Cabang ASC;



-- menampikan semua transaksi penjualan
SELECT * FROM transaksi_penjualan
SELECT
tp.ID_Transaksi_Penjualan, tp.ID_Cabang, tp.Tanggal_Transaksi,
p.Nama AS namapelanggan,k.StatusMember, tp.Total_Harga
FROM transaksi_penjualan tp
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN keanggotaan k ON p.ID_Keanggotaan = k.ID_Keanggotaan
ORDER BY p.Nama ASC;


-- Tampilkan nama pelanggan yang melakukan transaksi pada cabang 'BreadHouse Central'.
SELECT
p.Nama,
k.StatusMember,
tp.Tanggal_Transaksi,pr.Nama_Produk AS produkyangdibeli
FROM transaksi_penjualan tp
JOIN detail_transaksi dt ON tp.ID_Transaksi_Penjualan = dt.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
JOIN keanggotaan k ON p.ID_Keanggotaan = k.ID_Keanggotaan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
WHERE c.Nama_Cabang = 'BreadHouse Central'
ORDER BY p.Nama ASC;




-- Tampilkan nama pelanggan dan alamat mereka beserta nama cabang tempat mereka bertransaksi.
SELECT
	p.Nama AS NamaPelanggan,
	p.Alamat,
	c.Nama_Cabang AS NamaCabangTempatBertransaksi,
	pr.Nama_Produk AS RotiYangDipesan,
	tp.Tanggal_Transaksi AS TanggalCO
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
ORDER BY p.Nama ASC;


-- Tampilkan semua transaksi yang dilakukan oleh pelanggan dengan status 'Gold' atau 'Diamond', beserta total harga dan nama cabang.
SELECT
	p.Nama AS NamaPelanggan,
	k.StatusMember AS STATUS,
	pr.Nama_Produk AS NamaRoti,
	c.Nama_Cabang,
	pr.Harga AS HargaAsli,
	dt.Quantity AS JumlahYangDibeli,
	dt.Total_Harga,
	tp.Tanggal_Transaksi
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = dt.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = tp.ID_Pelanggan
JOIN keanggotaan k ON p.ID_Keanggotaan = k.ID_Keanggotaan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
WHERE k.StatusMember IN ('Gold', 'Diamond')
ORDER BY p.Nama ASC;



-- Tampilkan nama pemasok dan nama bahan baku yang mereka pasok, beserta jumlah yang dibeli dalam pembelian tertentu.
SELECT
	pm.Nama_Pemasok,
	bp.Nama_Bahan_Baku,
	dp.Jumlah_Dibeli,
	dp.Harga_Satuan,
	dp.Total_Harga
FROM detail_pembelian dp
JOIN bahan_baku bp ON dp.ID_BahanBaku = bp.ID_BahanBaku
JOIN pembelian_bahan_baku pb ON dp.ID_Pembelian = pb.ID_Pembelian
JOIN pemasok pm ON pb.ID_Pemasok = pm.ID_Pemasok
GROUP BY bp.Nama_Bahan_Baku
ORDER BY dp.Total_Harga ASC;


--Tampilkan transaksi penjualan beserta nama pelanggan dan status keanggotaan mereka yang telah bertransaksi di cabang produksi.
SELECT
	p.Nama,
	k.StatusMember AS STATUS,
	tp.ID_Transaksi_Penjualan,
	cp.Dapur_Produksi
FROM transaksi_penjualan tp
JOIN pelanggan p ON tp.ID_pelanggan = p.ID_Pelanggan
JOIN keanggotaan k ON p.ID_Keanggotaan = k.ID_Keanggotaan
JOIN cabang_produksi cp ON tp.ID_Cabang = cp.ID_CabangProduk
WHERE cp.ID_CabangProduk IS NOT NULL;




--
Tampilkan nama cabang dan jumlah produk yang dikirim ke setiap cabang penjualan.
--

SELECT 
	c.Nama_Cabang,
	SUM(pp.Jumlah_Produk)
FROM pengiriman_produk pp 
JOIN cabang_penjualan cp ON pp.ID_CabangPenjualan = cp.ID_CabangPenjualan
JOIN cabang c ON cp.ID_CabangPenjualan = c.ID_Cabang
GROUP BY c.Nama_Cabang;
 
 

-- Tampilkan nama produk, jumlah produk yang terjual, dan 
-- total transaksi yang terjadi di setiap cabang. Kelompokkan berdasarkan cabang dan produk.

SELECT
	pr.Nama_Produk,
	SUM(dt.Quantity) AS jumlahprodukyangterjual,
	CASE 
		WHEN cp.ID_CabangProduk IS NOT NULL THEN 'PRODUKSI'
	ELSE 
	'PENJUALAN'
	END AS 'JENISCABANG'
FROM transaksi_penjualan tp
JOIN detail_transaksi dt ON tp.ID_Transaksi_Penjualan = dt.ID_Transaksi_Penjualan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
LEFT JOIN cabang_produksi cp ON c.ID_Cabang = cp.ID_CabangProduk
GROUP BY Cabang, pr.Nama_Produk;


--- pelajaran baru
SELECT
	pr.Nama_Produk,
	SUM(dt.Quantity) AS jumlahprodukyangterjual,
	c.Nama_Cabang,
	CASE 
		WHEN cp.ID_CabangProduk IS NOT NULL THEN 'PRODUKSI'
		ELSE 'PENJUALAN'
	END AS 'JENISCABANG'
FROM transaksi_penjualan tp
JOIN detail_transaksi dt ON tp.ID_Transaksi_Penjualan = dt.ID_Transaksi_Penjualan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
LEFT JOIN cabang_produksi cp ON c.ID_Cabang = cp.ID_CabangProduk
GROUP BY c.Nama_Cabang, pr.Nama_Produk
ORDER BY pr.Nama_Produk ASC;


-- Tampilkan nama produk dan jumlah produk yang terjual dari tabel transaksi_penjualan dan 
-- detail_transaksi. Kelompokkan data berdasarkan 
-- Nama_Produk dan urutkan berdasarkan jumlahprodukyangterjual secara menurun (DESC).

SELECT 
	p.Nama_Produk,
	SUM(dt.Quantity) AS jumlahyangterjual
FROM detail_transaksi dt
JOIN produk_roti p ON dt.ID_Produk = p.ID_Produk
GROUP BY p.Nama_Produk
ORDER BY jumlahyangterjual DESC;


-- Tampilkan nama cabang dan total produk yang terjual di setiap cabang.
-- Kelompokkan berdasarkan Nama_Cabang, urutkan berdasarkan total_produk_terjual secara menurun (DESC), 
 -- dan juga tampilkan JENISCABANG yang dapat bernilai 
-- PRODUKSI atau PENJUALAN berdasarkan apakah cabang tersebut memiliki fasilitas produksi.
SELECT
	c.Nama_Cabang,
	SUM(dt.Quantity) AS totalprodukyangterjual,
	case
		when cp.ID_CabangProduk IS NOT NULL THEN 'CABANG PRODUKSI'
	ELSE
	 'PENJUALAN'
	END AS JENIS_CABANG
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
LEFT JOIN cabang_produksi cp ON c.ID_Cabang = cp.ID_CabangProduk
GROUP BY c.Nama_Cabang
ORDER BY totalprodukyangterjual DESC;

-- pengecekan apakah benar berjumlah yang sesuai soal diatas
SELECT
	SUM(dt.Quantity)
FROM detail_transaksi dt
ORDER BY dt.Quantity


-- Di sebuah toko roti, manajer ingin mengetahui produk roti apa saja yang paling banyak terjual 
 -- pada setiap cabang. Tugas Anda adalah menampilkan nama produk dan jumlah produk yang terjual 
-- di masing-masing cabang. Urutkan hasilnya 
-- berdasarkan jumlah produk yang terjual secara menurun (DESC), agar dapat dengan mudah 
-- melihat produk terlaris.

SELECT
	c.Nama_Cabang,
	pr.Nama_Produk,
	SUM(dt.Quantity) AS jumlahyangterjual
FROM detail_transaksi dt
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
GROUP BY  pr.Nama_Produk, c.Nama_Cabang
ORDER BY jumlahyangterjual DESC;


 -- Di cabang "BreadHouse Surabaya", manajer ingin mengetahui produk yang terjual pada bulan ini. 
 -- Hasilnya harus mencakup produk dan jumlah unit yang terjual. Data harus dipilah berdasarkan nama cabang.
SELECT
	pr.Nama_Produk,
	SUM(dt.Quantity) AS jumlahterjual
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
WHERE c.Nama_Cabang = 'BreadHouse Surabaya'
GROUP BY pr.Nama_Produk
ORDER BY jumlahterjual DESC;
-- 
-- pelanggan dan produk roti

SELECT
	p.Nama,
	pr.Nama_Produk
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_transaksi_penjualan = tp.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
ORDER BY p.Nama DESC;


SELECT
    p.Nama,
    pr.Nama_Produk
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
ORDER BY p.Nama ASC;

-- Tampilkan daftar produk roti dengan penjualan tertinggi 
-- di "BreadHouse Bandung". Jangan lupa untuk menampilkan jumlah unit yang terjual.
SELECT 
    pr.Nama_Produk,
    SUM(dt.Quantity) AS jumlahprodukyangterjual
FROM transaksi_penjualan tp
JOIN detail_transaksi dt ON tp.ID_Transaksi_Penjualan = dt.ID_Transaksi_Penjualan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
WHERE c.Nama_Cabang = 'BreadHouse Bandung'
GROUP BY pr.Nama_Produk
ORDER BY jumlahprodukyangterjual DESC;

/*
Manajer BreadHouse ingin mengetahui bagaimana distribusi penjualan di setiap cabang. 
Mereka ingin melihat daftar 
produk yang paling laku di setiap cabang, serta jumlahnya.
Namun, mereka juga ingin mengetahui apakah cabang tersebut
merupakan cabang produksi atau penjualan, agar bisa mengambil keputusan lebih lanjut.
Pertanyaan:
Tampilkan nama produk, jumlah penjualan, 
dan jenis cabang (produksi/pengiriman) untuk setiap transaksi, 
kelompokkan berdasarkan produk dan cabang, lalu urutkan berdasarkan 
jumlah penjualan dari yang terbesar ke terkecil.
*/

SELECT 
	p.Nama,
	pr.Nama_Produk,
	k.StatusMember,
	SUM(dt.Quantity) AS JumlahPenjualan,
	c.Nama_Cabang,
	CASE
		WHEN cp.ID_CabangProduk IS NOT NULL THEN 'PRODUKSI'
	ELSE
	'PENJUALAN'
	END AS JENISCABANG
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN keanggotaan k ON p.ID_Keanggotaan = k.ID_Keanggotaan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
LEFT JOIN cabang_produksi cp ON c.ID_Cabang = cp.ID_CabangProduk
GROUP BY p.Nama, pr.Nama_Produk, c.Nama_Cabang
ORDER BY JumlahPenjualan DESC;
/*
BreadHouse ingin mengetahui berapa banyak pelanggan yang melakukan 
transaksi di setiap cabang. Mereka ingin mengetahui data ini untuk mengevaluasi kinerja cabang.
Pertanyaan:
Tampilkan nama cabang dan jumlah pelanggan yang melakukan transaksi di setiap cabang, 
urutkan berdasarkan jumlah pelanggan dari yang paling sedikit ke yang paling banyak.
*/

SELECT 
	c.Nama_Cabang,
	COUNT(DISTINCT tp.ID_Pelanggan) AS Jumlah_Pelanggan
FROM transaksi_penjualan tp
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
GROUP BY c.Nama_Cabang
ORDER BY Jumlah_Pelanggan DESC;

/*
Manajer produksi ingin mengevaluasi efisiensi penggunaan berbagai bahan baku di dapur.
 Ia ingin tahu bahan baku mana yang digunakan paling banyak, sehingga dapat dipertimbangkan 
 untuk pengadaan ulang. Buatlah daftar nama bahan baku beserta total penggunaannya, 
dan susun daftar tersebut mulai dari bahan yang paling banyak digunakan.
*/

SELECT 
	bb.Nama_Bahan_Baku,
	SUM(pbb.Jumlah_Bahan_Digunakan) AS totalpenggunaan
FROM penggunaan_bahan_baku pbb
JOIN bahan_baku bb ON pbb.ID_BahanBaku
GROUP BY bb.Nama_Bahan_Baku
ORDER BY totalpenggunaan DESC ;

/*
Divisi logistik ingin menilai kontribusi masing-masing pemasok terhadap total 
pasokan bahan baku yang digunakan dalam produksi. Mereka ingin tahu 
pemasok mana yang secara total bahan bakunya paling sering digunakan. Susun daftar 
nama pemasok berdasarkan total jumlah bahan baku yang dikirimkan dan telah digunakan dalam produksi.
*/

SELECT
p.Nama_Pemasok,
SUM(pb.Jumlah_Digunakan) AS total_penggunaan_bahan
FROM penggunaan_bahan_baku pb
JOIN bahan_baku bb ON pb.ID_BahanBaku = bb.ID_BahanBaku
JOIN pemasok p ON bb.ID_Pemasok = p.ID_Pemasok
GROUP BY p.Nama_Pemasok
ORDER BY total_penggunaan_bahan DESC;



SELECT 
	pm.Nama_Pemasok,
	bb.Nama_Bahan_Baku,
	SUM(pbc.Jumlah_Bahan_Digunakan) AS Total_Penggunaan
FROM detail_pembelian dp
JOIN pembelian_bahan_baku pbb ON dp.ID_Pembelian
JOIN pemasok pm ON pbb.ID_Pemasok = pm.ID_Pemasok
JOIN bahan_baku bb ON dp.ID_BahanBaku = bb.ID_BahanBaku
JOIN penggunaan_bahan_baku pbc ON bb.ID_BahanBaku = pbc.ID_BahanBaku
GROUP BY pm.Nama_Pemasok, bb.Nama_Bahan_Baku
ORDER BY Total_Penggunaan DESC;

/*
Seorang analis ingin tahu toko cabang mana yang paling aktif menggunakan 
bahan baku untuk membuat produk roti. Ia ingin menilai performa tiap 
 berdasarkan total jumlah bahan baku yang digunakan dalam proses produksi.
Tampilkan nama cabang dan total seluruh bahan baku yang digunakan oleh cabang 
tersebut untuk memproduksi roti. Urutkan agar cabang dengan penggunaan tertinggi muncul paling atas.
Hint: Data penggunaan bahan baku per produk, lalu hubungkan ke transaksi penjualan dan cabang.
*/ 
SELECT
	c.Nama_Cabang,
	SUM(pbb.Jumlah_Bahan_Digunakan) AS jumlahyangdigunakan
FROM penggunaan_bahan_baku pbb 
JOIN cabang c ON pbb.ID_Cabang = c.ID_Cabang
JOIN bahan_baku bb ON pbb.ID_BahanBaku = bb.ID_BahanBaku
WHERE pbb.ID_Produk_Yang_Dibuat IN
	(SELECT dt.ID_Produk
	FROM detail_transaksi dt
	)
GROUP BY c.Nama_Cabang
ORDER BY jumlahyangdigunakan DESC;

/*
Divisi kontrol kualitas ingin tahu produk roti mana yang
 diproduksi menggunakan bahan baku paling bervariasi (berbeda-beda).
Tampilkan nama produk roti dan jumlah bahan baku
 unik yang digunakan dalam produksinya. 
Urutkan agar yang paling kompleks (bahan terbanyak) muncul paling atas.
Hint: COUNT DISTINCT bahan baku untuk setiap produk.
*/ 
SELECT
	pr.Nama_Produk,
	COUNT(DISTINCT bb.ID_BahanBaku) AS jumlahbahanbaku
FROM detail_resep dr
JOIN resep r ON dr.ID_Resep = r.ID_Resep
JOIN produk_roti pr ON r.ID_Produk = pr.ID_Produk
JOIN bahan_baku bb ON dr.ID_BahanBaku = bb.ID_BahanBaku
GROUP BY pr.Nama_Produk
ORDER BY jumlahbahanbaku DESC;
/*
Lalu bagaiamana jika sayaingin menampilkan produk, 
dan produk tersebut apa nama resepnya dancarapembuatannya bagaimana dan membutuhkan bahanbaku apa saja
*/ 
SELECT
	pr.Nama_Produk,
	r.Nama_Resep,
	r.Cara_Pembuatan,
	bb.Nama_Bahan_Baku
FROM detail_resep dr
JOIN resep r ON dr.ID_Resep = r.ID_Resep
JOIN produk_roti pr ON r.ID_Produk = pr.ID_Produk
JOIN bahan_baku bb ON dr.ID_BahanBaku = bb.ID_BahanBaku
WHERE pr.Nama_Produk = 'Donat Cokelat'
ORDER BY bb.Nama_Bahan_Baku;
/*
🧠 Soal 1 — Rata-rata, Total, dan Jumlah Produk yang Dijual per Cabang
Manajer regional ingin tahu bagaimana performa masing-masinh
 cabang toko. Untuk itu, ia ingin melihat:
Nama cabang
Jumlah transaksi penjualan yang terjadi
Total quantity produk roti yang terjual
Rata-rata quantity produk per transaksi
Urutkan berdasarkan rata-rata quantity per transaksi dari yang tertinggi.
Petunjuk: Gunakan COUNT(ID_Transaksi_Penjualan), 
SUM(Quantity), dan AVG(Quantity) yang digabungkan lewat GROUP BY cabang.
*/ 

SELECT 
	c.Nama_Cabang,
	COUNT(DISTINCT tp.ID_Transaksi_Penjualan) AS jumlahtransaksi,
	SUM(dt.Quantity) AS jumlahproduk,
	AVG(dt.Quantity) AS rataratapenjualan
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
GROUP BY c.Nama_Cabang
ORDER BY rataratapenjualan DESC;

/*
Supervisor gudang ingin mengevaluasi performa masing-masing pemasok. Ia ingin melihat:
	• Nama pemasok
	• Jumlah pembelian (berapa kali beli dari pemasok itu)
	• Total quantity bahan baku yang dibeli dari pemasok
	• Rata-rata quantity bahan baku per pembelian
Urutkan berdasarkan total quantity terbanyak.
Clue: Gunakan tabel pembelian_bahan_baku + detail_pembelian + pemasok. 
Gunakan fungsi COUNT, SUM, dan AVG dalam konteks pembelian.
*/ 
SELECT 
	p.Nama_Pemasok,
	p.Alamat_Pemasok,
	COUNT(DISTINCT dp.ID_DetailPembelian) AS jumlahpembelian,
	SUM(dp.Jumlah_Dibeli) AS totalbahanbakuyangdibeli,
	AVG(dp.Jumlah_Dibeli) AS rataratapembelian
FROM detail_pembelian dp
JOIN pembelian_bahan_baku pbb ON dp.ID_Pembelian = pbb.ID_Pembelian
JOIN pemasok p ON pbb.ID_Pemasok = p.ID_Pemasok
GROUP BY p.Nama_Pemasok, p.Alamat_Pemasok
ORDER BY rataratapembelian DESC;

SELECT * FROM pemasok;

SELECT 
	p.Nama,
	COUNT(DISTINCT p.ID_Pelanggan) AS Jumlah_Transaksi,
	SUM(dt.Quantity) AS totalproduk,
	SUM(dt.Quantity) * 1.0 / COUNT(DISTINCT tp.ID_Transaksi_Penjualan) AS rataratapenjualan
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
GROUP BY  p.Nama
ORDER BY  rataratapenjualan DESC;



/*
Tampilkan semua pelanggan 
yang tidak pernah melakukan transaksi di cabang dengan nama 'BreadHouse Jakarta'.
Hint: Gabungkan pelanggan dan transaksi_penjualan, 
lalu gunakan filtering dengan NOT IN atau LEFT JOIN dan IS NULL
*/
--  INI PUNYA KU
SELECT
p.Nama
FROM pelanggan p
LEFT JOIN transaksi_penjualan tp ON p.ID_Pelanggan = tp.ID_Pelanggan
LEFT JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
WHERE c.Nama_Cabang ='BreadHouse Central'
	AND tp.ID_Transaksi_Penjualan IS NULL
GROUP BY p.Nama;
-- INI PUNYA AI
SELECT p.Nama
FROM Pelanggan p
LEFT JOIN Transaksi_Penjualan tp 
    ON p.ID_Pelanggan = tp.ID_Pelanggan
    AND tp.ID_Cabang = (
        SELECT ID_Cabang 
        FROM Cabang 
        WHERE Nama_Cabang = 'BreadHouse Central'
    )
WHERE tp.ID_Transaksi_Penjualan IS NULL;



/*
Soal 3 (melibatkan logika rasio):
Untuk setiap pelanggan, tampilkan:
	• Nama pelanggan
	• Jumlah total produk yang pernah dibeli (SUM)
	• Jumlah transaksi unik (COUNT DISTINCT)
	• Rata-rata produk yang dibeli per transaksi
Urutkan hasilnya berdasarkan rata-rata produk per transaksi dari tertinggi ke terendah.
*/

SELECT 
	p.Nama,
	SUM(dt.Quantity) AS Jumlah_Produk_Yangpernahdibeli,
	pr.Nama_Produk AS namaprodukyangdibeli,
	COUNT(dt.ID_Detail_Transaksi) AS jumlahtransaksi,
	AVG(dt.Quantity) ratarata_pembelian
FROM detail_transaksi dt
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
GROUP BY p.Nama
ORDER BY ratarata_pembelian DESC;


/*
tampilkan:
• Nama cabang

• Total jumlah produk roti yang terjual di cabang tersebut dalam periode yang sama
• Rata-rata jumlah produk per pelanggan (total produk / jumlah pelanggan unik)
• Tambahkan kolom: Jenis Cabang (Produksi/Penjualan/Produksi & Penjualan), berdasarkan 
status cabang (Gunakan Cabang_Produksi dan Cabang_Penjualan)
• Urutkan berdasarkan rata-rata produk per pelanggan, dari tertinggi ke terendah.
⚠️ Catatan: 
• Gunakan DISTINCT ID_Pelanggan untuk menghitung jumlah pelanggan unik

• Gunakan CASE WHEN untuk menentukan jenis cabang
• Gunakan LEFT JOIN agar semua cabang tetap muncul, termasuk yang belum ada transaksi

*/

SELECT * FROM transaksi_penjualan;

SELECT 
	p.Nama,
	SUM(dt.Quantity) AS jumlahtransaksi,
	SUM(dt.Total_Harga) AS uangyangdikeluarkan,
	pr.Nama_Produk AS produkyangdibeli,
	CASE
		WHEN cp.ID_CabangProduk IS NOT NULL THEN 'Produksi'
	ELSE 
		'Penjualan'
	END AS 'jeniscabang'
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN cabang c ON tp.ID_Cabang =  c.ID_Cabang
LEFT JOIN cabang_produksi cp ON c.ID_Cabang = cp.ID_CabangProduk
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
GROUP BY p.Nama, pr.Nama_Produk
ORDER BY jumlahtransaksi DESC, uangyangdikeluarkan DESC ;

-- salah memahami soal


📊 Soal 1 (Menggunakan COUNT DISTINCT dan SUM):
Di toko roti, manajer ingin melihat jumlah produk yang dibeli 
oleh setiap pelanggan, dengan rincian sebagai berikut:
	• Nama pelanggan
	• Total produk yang dibeli (jumlah produk terjual, SUM)
	• Jumlah transaksi unik (COUNT DISTINCT)
Tampilkan hasilnya berdasarkan jumlah transaksi unik yang paling banyak,
 dari yang tertinggi hingga terendah.

SELECT
	p.Nama,
	SUM(dt.Quantity) AS jumlahprodukyangdibeli,
	COUNT(DISTINCT tp.ID_Transaksi_Penjualan) AS jumlahtransaksi,
	CASE 
		WHEN cp.ID_CabangProduk IS NOT NULL THEN 'produksi'
	ELSE 
		'penjualan'
	END AS 'jeniscabang'
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
LEFT JOIN cabang_produksi cp ON c.ID_Cabang = cp.ID_CabangProduk
GROUP BY p.Nama, jeniscabang
ORDER BY jumlahtransaksi DESC;


Soal 2 (Menggunakan AVG dan CASE WHEN ELSE):
Manajer ingin melihat total penjualan dan
 rata-rata jumlah transaksi per produk roti di setiap cabang.
 Buatlah query yang menghasilkan data berikut:
	• Nama produk
	• Total produk yang terjual (SUM)
	• Rata-rata produk yang terjual per transaksi (AVG)
	• Jenis cabang yang memproduksi produk tersebut: "PRODUKSI" jika cabang
	 tersebut memiliki fasilitas produksi dan "PENJUALAN" jika tidak.
Tampilkan hasil berdasarkan total produk yang terjual, dari yang tertinggi hingga terendah.

SELECT
	pr.Nama_Produk,
	SUM(dt.Quantity) AS jumlahprodukyangdibeli,
	AVG(dt.Quantity) AS ratarataprodukterjual,
	CASE 
		WHEN cp.ID_CabangProduk IS NOT NULL THEN 'produksi'
	ELSE 
		'penjualan'
	END AS 'jeniscabang'
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
LEFT JOIN cabang_produksi cp ON c.ID_Cabang = cp.ID_CabangProduk
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
GROUP BY pr.Nama_Produk, jeniscabang
ORDER BY jumlahprodukyangdibeli DESC;


Soal 3 (Menggunakan COUNT DISTINCT, SUM, AVG, dan CASE WHEN ELSE):
Toko roti ingin mengetahui performa penjualan berdasarkan kategori produk yang dibeli oleh pelanggan:
	• Nama pelanggan
	• Kategori produk yang dibeli
	• Jumlah total produk yang dibeli (SUM)
	• Rata-rata produk yang dibeli per transaksi (AVG)
	• Jumlah transaksi unik berdasarkan kategori produk (COUNT DISTINCT)
Gunakan CASE WHEN ELSE untuk menampilkan kategori produk berdasarkan jenisnya: "Roti Tawar", "Donat", atau "Pastry". Urutkan hasilnya berdasarkan rata-rata produk yang dibeli per transaksi, dari yang tertinggi hingga terendah.

SELECT 
	p.Nama,
	CASE 
		WHEN pr.Jenis_Produk = 'Roti Tawar' THEN 'Roti Tawar'
		WHEN pr.Jenis_Produk = 'Donat' THEN 'Donat'
		WHEN pr.Jenis_Produk = 'Pastry' THEN 'Pastry'
	ELSE 'lainnya'
	END AS 'jenisproduk',
	tp.Tanggal_Transaksi,
	SUM(dt.Quantity) AS jumlahtotalprodukyangdibeli,
	AVG(dt.Quantity) AS ratarataproduk,
	COUNT(DISTINCT tp.ID_Transaksi_Penjualan) AS idpenjualanunik
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
GROUP BY p.Nama, jenisproduk, tp.Tanggal_Transaksi
ORDER BY jumlahtotalprodukyangdibeli DESC;




SELECT
	p.Nama,
	pr.Nama_Produk,
	tp.Tanggal_Transaksi,
	c.Nama_Cabang,
	CASE 
		WHEN cp.ID_CabangProduk IS NOT NULL THEN 'PRODUKSI'
	ELSE 
		'PENJUALAN'
	END AS 'JENISCABANG'
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
LEFT JOIN cabang_produksi cp ON c.ID_Cabang = cp.ID_CabangProduk
GROUP BY p.Nama
ORDER BY pr.Nama_Produk ASC;
/*
Manajer ingin mengetahui jumlah transaksi penjualan yang terjadi di setiap cabang. 
Tampilkan nama cabang dan jumlah transaksi yang terjadi di setiap cabang. 
Urutkan hasilnya berdasarkan jumlah transaksi.
Yang perlu dikuasai:
Gunakan COUNT, GROUP BY, dan ORDER BY.
*/
SELECT 
	c.Nama_Cabang,
	COUNT(DISTINCT dt.ID_Detail_Transaksi) AS jumlahtransaksi
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
GROUP BY c.Nama_Cabang
ORDER BY jumlahtransaksi DESC;
/*
Di toko roti, manajer ingin mengetahui total jumlah produk yang terjual pada setiap 
cabang penjualan, tetapi hanya untuk pelanggan yang memiliki keanggotaan Silver dan Gold.
Tampilkan nama cabang penjualan, nama produk, dan jumlah produk yang terjual.
Urutkan berdasarkan nama produk secara menurun.
Yang perlu dikuasai:
JOIN antar tabel Keanggotaan, Pelanggan, Cabang Penjualan, dan Produk Roti.
WHERE untuk memfilter keanggotaan, SUM, GROUP BY, dan ORDER BY.
*/
SELECT
	c.Nama_Cabang,
	pr.Nama_Produk,
	SUM(dt.Quantity) AS jumlahprodukyangterjual,
	p.Nama, k.StatusMember,
FROM detail_transaksi dt
JOIN transaksi_penjualan tp ON dt.ID_Transaksi_Penjualan = tp.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN keanggotaan k ON p.ID_Keanggotaan = k.ID_Keanggotaan
JOIN cabang c ON tp.ID_Cabang = c.ID_Cabang
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
WHERE k.StatusMember IN  ('Silver','Gold') 
GROUP BY c.Nama_Cabang, pr.Nama_Produk, p.Nama
ORDER BY jumlahprodukyangterjual DESC;

Tampilkan nama pelanggan
yang sudah melakukan lebih dari 3 transaksi,
serta jumlah total produk yang mereka beli dan rata-rata produk per transaksi. 
Urutkan hasil berdasarkan total produk terbanyak.

SELECT 
	p.Nama,
	pr.Nama_Produk,
	COUNT(DISTINCT tp.ID_Transaksi_Penjualan) AS jumlahtransaksi,
	SUM(dt.Quantity) AS jumlahproduk,
	AVG(dt.Quantity) AS ratarataproduk
FROM transaksi_penjualan tp
JOIN detail_transaksi dt ON tp.ID_Transaksi_Penjualan = dt.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
JOIN produk_roti pr ON dt.ID_Produk = pr.ID_Produk
GROUP BY p.Nama
HAVING COUNT(DISTINCT tp.ID_Transaksi_Penjualan) > 3
ORDER BY jumlahproduk DESC;


SELECT 
    p.Nama AS Nama_Pelanggan,
    COUNT(DISTINCT tp.ID_Transaksi_Penjualan) AS Jumlah_Transaksi,
    SUM(dt.Quantity) AS Total_Quantity,
    SUM(dt.Quantity) * 1.0 / COUNT(DISTINCT tp.ID_Transaksi_Penjualan) AS Rata_Rata_Quantity_Per_Transaksi
FROM transaksi_penjualan tp
JOIN detail_transaksi dt ON tp.ID_Transaksi_Penjualan = dt.ID_Transaksi_Penjualan
JOIN pelanggan p ON tp.ID_Pelanggan = p.ID_Pelanggan
GROUP BY p.ID_Pelanggan, p.Nama
HAVING COUNT(DISTINCT tp.ID_Transaksi_Penjualan) >= 2
ORDER BY Rata_Rata_Quantity_Per_Transaksi DESC;


Tampilkan daftar pasangan (pemasok, bahan baku) yang produknya digunakan dalam lebih dari 3 
transaksi penjualan.
Tampilkan nama pemasok, nama bahan baku, total quantity bahan yang digunakan, 
dan jumlah produk roti yang menggunakan bahan tersebut.
Hint: Gunakan JOIN dari pemasok 
→ pembelian_bahan_baku → detail_pembelian → bahan_baku → 
penggunaan_bahan_baku → produk_roti → detail_transaksi.

SELECT 
FROM detail_pembelian dp
JOIN pembelian_bahan_baku pbb ON dp.ID_Pembelian = pbb.ID_Pembelian
JOIN pemasok p ON pbb.ID_Pemasok = p.ID_Pemasok
JOIN bahan_baku bb ON dp.ID_BahanBaku = bb.ID_BahanBaku	
JOIN penggunaan_bahan_baku pbu ON bb.ID_BahanBaku = pbu.ID_BahanBaku
JOIN cabang c ON  pbu.ID_Cabang = c.ID_Cabang
JOIN transaksi_penjualan tp ON c.ID_Cabang =tp.ID_Transaksi_Penjualan
JOIN detail_transaksi dt ON tp.
GROUP BY
ORDER BY


SELECT 
    p.Nama_Pemasok,
    bb.Nama_Bahan_Baku,
    SUM(pbu.Jumlah_Bahan_Digunakan) AS Total_Bahan_Digunakan,
    COUNT(DISTINCT dt.ID_Produk) AS Jumlah_Produk_Roti,
    COUNT(DISTINCT tp.ID_Transaksi_Penjualan) AS jumlahorangyangbeli
FROM detail_pembelian dp
JOIN pembelian_bahan_baku pbb ON dp.ID_Pembelian = pbb.ID_Pembelian
JOIN pemasok p ON pbb.ID_Pemasok = p.ID_Pemasok
JOIN bahan_baku bb ON dp.ID_BahanBaku = bb.ID_BahanBaku	
JOIN penggunaan_bahan_baku pbu ON bb.ID_BahanBaku = pbu.ID_BahanBaku
JOIN cabang c ON pbu.ID_Cabang = c.ID_Cabang
JOIN transaksi_penjualan tp ON c.ID_Cabang = tp.ID_Cabang
JOIN detail_transaksi dt ON tp.ID_Transaksi_Penjualan = dt.ID_Transaksi_Penjualan
GROUP BY p.Nama_Pemasok, bb.Nama_Bahan_Baku
HAVING COUNT(DISTINCT jumlahorangyangbeli) > 3
ORDER BY Total_Bahan_Digunakan DESC;

SELECT 
    p.Nama_Pemasok,
    bb.Nama_Bahan_Baku,
    SUM(pbu.Jumlah_Bahan_Digunakan) AS Total_Bahan_Digunakan,
    COUNT(DISTINCT dt.ID_Produk) AS Jumlah_Produk_Roti,
    COUNT(DISTINCT tp.ID_Transaksi_Penjualan) AS jumlahorangyangbeli
FROM detail_pembelian dp
JOIN pembelian_bahan_baku pbb ON dp.ID_Pembelian = pbb.ID_Pembelian
JOIN pemasok p ON pbb.ID_Pemasok = p.ID_Pemasok
JOIN bahan_baku bb ON dp.ID_BahanBaku = bb.ID_BahanBaku	
LEFT JOIN penggunaan_bahan_baku pbu ON bb.ID_BahanBaku = pbu.ID_BahanBaku
LEFT JOIN cabang c ON pbu.ID_Cabang = c.ID_Cabang
LEFT JOIN transaksi_penjualan tp ON c.ID_Cabang = tp.ID_Cabang
LEFT JOIN detail_transaksi dt ON tp.ID_Transaksi_Penjualan = dt.ID_Transaksi_Penjualan
GROUP BY p.Nama_Pemasok, bb.Nama_Bahan_Baku
HAVING COUNT(DISTINCT tp.ID_Transaksi_Penjualan) > 3
ORDER BY Total_Bahan_Digunakan DESC;


SELECT 
    p.Nama_Pemasok,
    bb.Nama_Bahan_Baku,
    SUM(pbu.Jumlah_Bahan_Digunakan) AS Total_Bahan_Digunakan,
    COUNT(DISTINCT dt.ID_Produk) AS Jumlah_Produk_Roti,
    COUNT(DISTINCT tp.ID_Transaksi_Penjualan) AS jumlahorangyangbeli
FROM detail_pembelian dp
JOIN pembelian_bahan_baku pbb ON dp.ID_Pembelian = pbb.ID_Pembelian
JOIN pemasok p ON pbb.ID_Pemasok = p.ID_Pemasok
JOIN bahan_baku bb ON dp.ID_BahanBaku = bb.ID_BahanBaku	
JOIN penggunaan_bahan_baku pbu ON bb.ID_BahanBaku = pbu.ID_BahanBaku
JOIN cabang c ON pbu.ID_Cabang = c.ID_Cabang
JOIN transaksi_penjualan tp ON c.ID_Cabang = tp.ID_Cabang
JOIN detail_transaksi dt ON tp.ID_Transaksi_Penjualan = dt.ID_Transaksi_Penjualan
GROUP BY p.Nama_Pemasok, bb.Nama_Bahan_Baku
HAVING COUNT(DISTINCT tp.ID_Transaksi_Penjualan) > 3
ORDER BY Total_Bahan_Digunakan DESC;



