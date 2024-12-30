CREATE DATABASE DE1 
CREATE TABLE TACGIA (
    MaTG CHAR(5) PRIMARY KEY,
    HoTen VARCHAR(20),
    DiaChi VARCHAR(50),
    NgSinh SMALLDATETIME,
    SoDT VARCHAR(15)
);

CREATE TABLE SACH (
    MaSach CHAR(5) PRIMARY KEY,
    TenSach VARCHAR(25),
    TheLoai VARCHAR(25)
);

CREATE TABLE TACGIA_SACH (
    MaTG CHAR(5),
    MaSach CHAR(5),
    PRIMARY KEY (MaTG, MaSach),
    FOREIGN KEY (MaTG) REFERENCES TACGIA(MaTG),
    FOREIGN KEY (MaSach) REFERENCES SACH(MaSach)
);

CREATE TABLE PHATHANH (
    MaPH CHAR(5) PRIMARY KEY,
    MaSach CHAR(5),
    NgayPH SMALLDATETIME,
    SoLuong INT,
    NhaXuatBan VARCHAR(20),
    FOREIGN KEY (MaSach) REFERENCES SACH(MaSach)
);
-- 2.1.
ALTER TABLE PHATHANH
ADD CONSTRAINT CK_NgayPH_NgSinh
CHECK (NgayPH > (SELECT MIN(NgSinh) FROM TACGIA));

-- 2.2. 
GO
CREATE TRIGGER TR_TheLoai_GiaoKhoa
ON PHATHANH
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INSERTED I
        JOIN SACH S ON I.MaSach = S.MaSach
        WHERE S.TheLoai = 'Giao khoa' AND I.NhaXuatBan <> 'Giao duc'
    )
    BEGIN
        ROLLBACK;
        THROW 50001, 'Sach the loai Giao khoa chi duoc phat hanh boi Nha xuat ban Giao duc.', 1;
    END
END;
GO
-- 3.1.
SELECT DISTINCT T.MaTG, T.HoTen, T.SoDT
FROM TACGIA T
JOIN TACGIA_SACH TS ON T.MaTG = TS.MaTG
JOIN SACH S ON TS.MaSach = S.MaSach
JOIN PHATHANH P ON S.MaSach = P.MaSach
WHERE S.TheLoai = N'Van hoc' AND P.NhaXuatBan = N'Tre';

-- 3.2. 
SELECT TOP 1 P.NhaXuatBan, COUNT(DISTINCT S.TheLoai) AS SoLuongTheLoai
FROM PHATHANH P
JOIN SACH S ON P.MaSach = S.MaSach
GROUP BY P.NhaXuatBan
ORDER BY SoLuongTheLoai DESC;

-- 3.3. 
WITH TacGia_PhatHanh AS (
    SELECT P.NhaXuatBan, T.MaTG, T.HoTen, COUNT(P.MaPH) AS SoLanPhatHanh
    FROM PHATHANH P
    JOIN SACH S ON P.MaSach = S.MaSach
    JOIN TACGIA_SACH TS ON S.MaSach = TS.MaSach
    JOIN TACGIA T ON TS.MaTG = T.MaTG
    GROUP BY P.NhaXuatBan, T.MaTG, T.HoTen
),
MaxPhatHanh AS (
    SELECT NhaXuatBan, MAX(SoLanPhatHanh) AS MaxLanPhatHanh
    FROM TacGia_PhatHanh
    GROUP BY NhaXuatBan
)
SELECT T.NhaXuatBan, T.MaTG, T.HoTen, T.SoLanPhatHanh
FROM TacGia_PhatHanh T
JOIN MaxPhatHanh M ON T.NhaXuatBan = M.NhaXuatBan AND T.SoLanPhatHanh = M.MaxLanPhatHanh;
