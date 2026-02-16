/* =========================================================
   MSSQL - 3 táblás adatbázis + tesztadat + tesztlekérdezések
   Téma: telefonok (márka, kiadás, típus, ár) + eladások (mennyit, melyik boltban) + boltok
   ========================================================= */

-- 0) Új adatbázis (ha létezik, eldobjuk és újra létrehozzuk)
USE master;
GO

IF DB_ID(N'TelefonBoltDB') IS NOT NULL
BEGIN
    ALTER DATABASE TelefonBoltDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE TelefonBoltDB;
END
GO

CREATE DATABASE TelefonBoltDB;
GO

USE TelefonBoltDB;
GO

/* =========================================================
   1) Táblák
   ========================================================= */

-- 1. tábla: Telefonok (márka, kiadás, típus, ár)
CREATE TABLE dbo.Telefonok
(
    TelefonId      INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Telefonok PRIMARY KEY,
    Marka          NVARCHAR(50) NOT NULL,
    Kiadas         NVARCHAR(50) NOT NULL,     -- pl. "2024 Q4", "iPhone 15", "S24"
    Tipus          NVARCHAR(80) NOT NULL,     -- pl. "Pro 256GB", "Ultra 512GB"
    Ar             INT NOT NULL,              -- Ft (egyszerűség kedvéért int)
    CONSTRAINT CK_Telefonok_Ar_Positive CHECK (Ar > 0),
    CONSTRAINT UQ_Telefonok_MarkaKiadasTipus UNIQUE (Marka, Kiadas, Tipus)
);
GO

-- 3. tábla: Boltok (boltok adatai)
CREATE TABLE dbo.Boltok
(
    BoltId         INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Boltok PRIMARY KEY,
    BoltNev        NVARCHAR(100) NOT NULL,
    Varos          NVARCHAR(60)  NOT NULL,
    Cim            NVARCHAR(150) NOT NULL,
    Telefon        NVARCHAR(30)  NULL,
    Email          NVARCHAR(120) NULL,
    CONSTRAINT UQ_Boltok_BoltNevCim UNIQUE (BoltNev, Cim)
);
GO

-- 2. tábla: Eladások (adott típusból mennyit adtak el, és melyik boltban)
CREATE TABLE dbo.Eladasok
(
    EladasId       INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Eladasok PRIMARY KEY,
    TelefonId      INT NOT NULL,
    BoltId         INT NOT NULL,
    EladottDb      INT NOT NULL,
    EladasDatum    DATE NOT NULL CONSTRAINT DF_Eladasok_EladasDatum DEFAULT (CAST(GETDATE() AS DATE)),

    CONSTRAINT CK_Eladasok_EladottDb_Positive CHECK (EladottDb > 0),

    CONSTRAINT FK_Eladasok_Telefonok FOREIGN KEY (TelefonId)
        REFERENCES dbo.Telefonok (TelefonId),

    CONSTRAINT FK_Eladasok_Boltok FOREIGN KEY (BoltId)
        REFERENCES dbo.Boltok (BoltId)
);
GO

-- Indexek (gyorsabb join / szűrés)
CREATE INDEX IX_Eladasok_TelefonId ON dbo.Eladasok(TelefonId);
CREATE INDEX IX_Eladasok_BoltId ON dbo.Eladasok(BoltId);
CREATE INDEX IX_Eladasok_Datum ON dbo.Eladasok(EladasDatum);
GO


/* =========================================================
   2) Tesztadatok (INSERT)
   ========================================================= */

-- Boltok
INSERT INTO dbo.Boltok (BoltNev, Varos, Cim, Telefon, Email)
VALUES
(N'MobilPont',   N'Budapest', N'Váci út 12.',     N'+36 1 111 1111', N'info@mobilpont.hu'),
(N'TeleCenter',  N'Győr',     N'Baross Gábor út 5.', N'+36 96 222 222', N'gyor@telecenter.hu'),
(N'OkosShop',    N'Szeged',   N'Kárász u. 9.',    N'+36 62 333 333', N'szeged@okosshop.hu');
GO

-- Telefonok
INSERT INTO dbo.Telefonok (Marka, Kiadas, Tipus, Ar)
VALUES
(N'Apple',   N'iPhone 15',     N'Pro 256GB',     549990),
(N'Apple',   N'iPhone 15',     N'Pro Max 256GB', 599990),
(N'Samsung', N'Galaxy S24',    N'Ultra 512GB',   579990),
(N'Samsung', N'Galaxy A55',    N'128GB',         179990),
(N'Xiaomi',  N'Redmi Note 13', N'Pro 256GB',     139990),
(N'Google',  N'Pixel 8',       N'128GB',         329990);
GO

-- Eladások (TelefonId és BoltId a fenti insert alapján, de biztosra megyünk SELECT-tel)
DECLARE @Bolt_MobilPont INT = (SELECT BoltId FROM dbo.Boltok WHERE BoltNev = N'MobilPont'  AND Cim = N'Váci út 12.');
DECLARE @Bolt_TeleCenter INT = (SELECT BoltId FROM dbo.Boltok WHERE BoltNev = N'TeleCenter' AND Cim = N'Baross Gábor út 5.');
DECLARE @Bolt_OkosShop INT = (SELECT BoltId FROM dbo.Boltok WHERE BoltNev = N'OkosShop'    AND Cim = N'Kárász u. 9.');

DECLARE @T_i15Pro INT = (SELECT TelefonId FROM dbo.Telefonok WHERE Marka=N'Apple'   AND Kiadas=N'iPhone 15'     AND Tipus=N'Pro 256GB');
DECLARE @T_i15PM  INT = (SELECT TelefonId FROM dbo.Telefonok WHERE Marka=N'Apple'   AND Kiadas=N'iPhone 15'     AND Tipus=N'Pro Max 256GB');
DECLARE @T_S24U   INT = (SELECT TelefonId FROM dbo.Telefonok WHERE Marka=N'Samsung' AND Kiadas=N'Galaxy S24'    AND Tipus=N'Ultra 512GB');
DECLARE @T_A55    INT = (SELECT TelefonId FROM dbo.Telefonok WHERE Marka=N'Samsung' AND Kiadas=N'Galaxy A55'    AND Tipus=N'128GB');
DECLARE @T_RN13P  INT = (SELECT TelefonId FROM dbo.Telefonok WHERE Marka=N'Xiaomi'  AND Kiadas=N'Redmi Note 13' AND Tipus=N'Pro 256GB');
DECLARE @T_Pixel8 INT = (SELECT TelefonId FROM dbo.Telefonok WHERE Marka=N'Google'  AND Kiadas=N'Pixel 8'       AND Tipus=N'128GB');

INSERT INTO dbo.Eladasok (TelefonId, BoltId, EladottDb, EladasDatum)
VALUES
(@T_i15Pro,  @Bolt_MobilPont,  7, '2026-01-15'),
(@T_i15PM,   @Bolt_MobilPont,  4, '2026-01-20'),
(@T_S24U,    @Bolt_MobilPont,  5, '2026-02-01'),

(@T_A55,     @Bolt_TeleCenter, 9, '2026-01-10'),
(@T_RN13P,   @Bolt_TeleCenter, 12,'2026-01-22'),
(@T_Pixel8,  @Bolt_TeleCenter, 3, '2026-02-03'),

(@T_RN13P,   @Bolt_OkosShop,   8, '2026-01-18'),
(@T_A55,     @Bolt_OkosShop,   6, '2026-02-05'),
(@T_i15Pro,  @Bolt_OkosShop,   2, '2026-02-07');
GO


/* =========================================================
   3) Tesztelések (SELECT-ek / ellenőrzések)
   ========================================================= */

-- 3.1) Minden telefon listája
SELECT TelefonId, Marka, Kiadas, Tipus, Ar
FROM dbo.Telefonok
ORDER BY Marka, Kiadas, Tipus;
GO

-- 3.2) Minden bolt listája
SELECT BoltId, BoltNev, Varos, Cim, Telefon, Email
FROM dbo.Boltok
ORDER BY Varos, BoltNev;
GO

-- 3.3) Eladások join-nal: melyik boltban, melyik telefonból mennyi ment el és mikor
SELECT
    e.EladasId,
    e.EladasDatum,
    b.BoltNev,
    b.Varos,
    t.Marka,
    t.Kiadas,
    t.Tipus,
    t.Ar,
    e.EladottDb,
    (e.EladottDb * t.Ar) AS BevetelFt
FROM dbo.Eladasok e
JOIN dbo.Boltok b   ON b.BoltId = e.BoltId
JOIN dbo.Telefonok t ON t.TelefonId = e.TelefonId
ORDER BY e.EladasDatum DESC, b.BoltNev;
GO

-- 3.4) Összesített eladás telefononként (mennyit adtak el összesen)
SELECT
    t.Marka, t.Kiadas, t.Tipus,
    SUM(e.EladottDb) AS OsszesEladottDb
FROM dbo.Eladasok e
JOIN dbo.Telefonok t ON t.TelefonId = e.TelefonId
GROUP BY t.Marka, t.Kiadas, t.Tipus
ORDER BY OsszesEladottDb DESC;
GO

-- 3.5) Összesített eladás boltonként (db és bevétel)
SELECT
    b.BoltNev,
    b.Varos,
    SUM(e.EladottDb) AS OsszesEladottDb,
    SUM(e.EladottDb * t.Ar) AS OsszesBevetelFt
FROM dbo.Eladasok e
JOIN dbo.Boltok b   ON b.BoltId = e.BoltId
JOIN dbo.Telefonok t ON t.TelefonId = e.TelefonId
GROUP BY b.BoltNev, b.Varos
ORDER BY OsszesBevetelFt DESC;
GO

-- 3.6) TOP 3 legnagyobb bevételt hozó telefon (összes bolt alapján)
SELECT TOP (3)
    t.Marka, t.Kiadas, t.Tipus,
    SUM(e.EladottDb) AS EladottDb,
    SUM(e.EladottDb * t.Ar) AS BevetelFt
FROM dbo.Eladasok e
JOIN dbo.Telefonok t ON t.TelefonId = e.TelefonId
GROUP BY t.Marka, t.Kiadas, t.Tipus
ORDER BY BevetelFt DESC;
GO


/* =========================================================
   4) Negatív tesztek (hibát kell dobniuk) - kézzel futtasd, ha akarod
   =========================================================
   -- 4.1) Ár <= 0 (CHECK miatt hiba)
   INSERT INTO dbo.Telefonok (Marka, Kiadas, Tipus, Ar)
   VALUES (N'Teszt', N'Teszt', N'Teszt', 0);

   -- 4.2) Ugyanaz a (Marka, Kiadas, Tipus) (UNIQUE miatt hiba)
   INSERT INTO dbo.Telefonok (Marka, Kiadas, Tipus, Ar)
   VALUES (N'Apple', N'iPhone 15', N'Pro 256GB', 549990);

   -- 4.3) EladottDb <= 0 (CHECK miatt hiba)
   INSERT INTO dbo.Eladasok (TelefonId, BoltId, EladottDb, EladasDatum)
   VALUES (1, 1, 0, '2026-02-10');
   ========================================================= */
