package repository

import (
	"database/sql"
	"errors"
	"fmt"
	"tokoroti/internal/model"
)

type RepositoryPelanggan struct {
	db *KoneksiDatabase
}

func BuatRepositoryPelanggan(db *KoneksiDatabase) *RepositoryPelanggan {
	return &RepositoryPelanggan{db: db}
}

// CekKeanggotaan mencari pelanggan berdasarkan nomor telepon.
// Melakukan JOIN ke tabel Keanggotaan untuk mendapatkan diskon.
func (r *RepositoryPelanggan) CekKeanggotaan(noTelepon string) (*model.InfoPelanggan, error) {
	kueri := `
		SELECT 
			p.ID_Pelanggan,
			p.Nama,
			p.No_Telepon,
			COALESCE(k.StatusMember, 'Non-Member') AS Status_Member,
			COALESCE(k.ManfaatMember, 0.00) AS Manfaat_Member
		FROM Pelanggan p
		LEFT JOIN Keanggotaan k ON p.ID_Keanggotaan = k.ID_Keanggotaan
		WHERE p.No_Telepon = ?
		LIMIT 1
	`

	var pel model.InfoPelanggan
	err := r.db.QueryRow(kueri, noTelepon).Scan(
		&pel.IDPelanggan,
		&pel.Nama,
		&pel.NoTelepon,
		&pel.StatusMember,
		&pel.ManfaatMember,
	)

	if err != nil {
		if err == sql.ErrNoRows {
			return nil, errors.New("nomor telepon tidak terdaftar")
		}
		return nil, err
	}

	return &pel, nil
}

// RegistrasiPelanggan menambahkan member baru
func (r *RepositoryPelanggan) RegistrasiPelanggan(nama, noTelepon string) error {
	// Cek duplikasi dulu
	var exists int
	err := r.db.QueryRow("SELECT COUNT(*) FROM Pelanggan WHERE No_Telepon = ?", noTelepon).Scan(&exists)
	if err != nil {
		return err
	}
	if exists > 0 {
		return errors.New("nomor telepon sudah terdaftar")
	}

	// Insert Member Baru (Default Level 1001 - Regular)
	_, err = r.db.Exec(`
		INSERT INTO Pelanggan (ID_Keanggotaan, Nama, No_Telepon, Alamat, Email) 
		VALUES (1001, ?, ?, '-', CONCAT(?, '@breadhouse.com'))`,
		nama, noTelepon, noTelepon) // Email dummy dulu dari no hp

	if err != nil {
		return fmt.Errorf("gagal mendaftar: %v", err)
	}

	return nil
}
