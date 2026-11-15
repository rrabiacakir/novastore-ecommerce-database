-- =========================================================================
-- PROJE: NovaStore E-Ticaret Veri Yönetim Sistemi
-- HAZIRLAYAN: Rabia Çakır
-- DOSYA ADI: RabiaCakir_NovaStore_Proje.sql
-- =========================================================================

-- =========================================================================
-- BÖLÜM 1: VERİ TABANI TASARIMI (LOGICAL DESIGN VE DDL)
-- =========================================================================

-- 1. Veri Tabanı Oluşturma
CREATE DATABASE NovaStoreDB;
GO

USE NovaStoreDB;
GO

-- 2. Tablo Gereksinimleri (Önce Ana Tablolar, Sonra Bağımlı Tablolar)

-- A. Tablo: Categories (Kategoriler)
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL
);
GO

-- C. Tablo: Customers (Müşteriler)
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(50),
    City VARCHAR(20),
    Email VARCHAR(100) UNIQUE
);
GO

-- B. Tablo: Products (Ürünler)
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2),
    Stock INT DEFAULT 0,
    CategoryID INT,
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);
GO

-- D. Tablo: Orders (Siparişler)
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT,
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2),
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
GO

-- E. Tablo: OrderDetails (Sipariş Detayları - Ara Tablo)
CREATE TABLE OrderDetails (
    DetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    CONSTRAINT FK_OrderDetails_Products FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- =========================================================================
-- BÖLÜM 2: VERİ GİRİŞİ (DML - INSERT)
-- =========================================================================

-- Görev 1: 5 adet Kategori ekleme
INSERT INTO Categories (CategoryName) VALUES 
('Elektronik'),
('Giyim'),
('Kitap'),
('Kozmetik'),
('Ev ve Yaşam');
GO

-- Görev 2: Her kategoriye ait olacak şekilde toplam 12 Ürün ekleme
INSERT INTO Products (ProductName, Price, Stock, CategoryID) VALUES 
('Kablosuz Kulaklık', 1500.00, 15, 1),
('Mekanik Klavye', 2200.00, 8, 1),
('Akıllı Saat', 3500.00, 25, 1),
('Pamuklu Tişört', 350.00, 50, 2),
('Kot Pantolon', 900.00, 12, 2),
('Kışlık Mont', 2500.00, 5, 2),
('SQL Eğitim Kitabı', 250.00, 40, 3),
('Bilim Kurgu Romanı', 180.00, 18, 3),
('Nemlendirici Krem', 400.00, 30, 4),
('Güneş Kremi', 550.00, 10, 4),
('Kahve Makinesi', 4200.00, 7, 5),
('Çalışma Masası Lambası', 600.00, 22, 5);
GO

-- Görev 3: 6 adet Müşteri kaydı oluşturma
INSERT INTO Customers (FullName, City, Email) VALUES 
('Ahmet Yılmaz', 'İstanbul', 'ahmet.yilmaz@email.com'),
('Ayşe Demir', 'Ankara', 'ayse.demir@email.com'),
('Mehmet Kaya', 'İzmir', 'mehmet.kaya@email.com'),
('Zeynep Çelik', 'Bursa', 'zeynep.celik@email.com'),
('Caner Şahin', 'Antalya', 'caner.sahin@email.com'),
('Elif Öztürk', 'İstanbul', 'elif.ozturk@email.com');
GO

-- Görev 4: Farklı tarihlerde yapılmış 10 Sipariş ve Sipariş Detayları ekleme
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount) VALUES 
(1, '2025-01-10 14:30:00', 3700.00),
(2, '2025-01-12 10:15:00', 1250.00),
(3, '2025-01-15 16:45:00', 4200.00),
(1, '2025-01-20 11:00:00', 650.00),
(4, '2025-01-25 19:20:00', 3500.00),
(5, '2025-02-01 09:10:00', 2850.00),
(6, '2025-02-05 15:50:00', 1100.00),
(2, '2025-02-10 13:25:00', 2200.00),
(3, '2025-02-14 18:05:00', 960.00),
(1, '2025-02-18 20:00:00', 4800.00);
GO

INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES 
(1, 1, 1),
(1, 2, 1),
(2, 4, 1),
(2, 5, 1),
(3, 11, 1),
(4, 7, 1),
(4, 9, 1),
(5, 3, 1),
(6, 6, 1),
(6, 4, 1),
(7, 10, 2),
(8, 2, 1),
(9, 8, 2),
(9, 12, 1),
(10, 11, 1),
(10, 12, 1);
GO

-- =========================================================================
-- BÖLÜM 3: SORGULAMA VE ANALİZ (DQL - SELECT VE JOINS)
-- =========================================================================

-- 1. Temel Listeleme: Stok miktarı 20'den az olan ürünlerin azalan sırada listelenmesi
SELECT 
    ProductName AS [Ürün Adı], 
    Stock AS [Stok Miktarı]
FROM Products
WHERE Stock < 20
ORDER BY Stock DESC;
GO

-- 2. Veri Birleştirme (JOIN): Müşteri siparişlerinin tarih ve tutar bilgileriyle listelenmesi
SELECT 
    C.FullName AS [Müşteri Adı], 
    C.City AS [Şehir], 
    O.OrderDate AS [Sipariş Tarihi], 
    O.TotalAmount AS [Toplam Tutar]
FROM Customers C
INNER JOIN Orders O ON C.CustomerID = O.CustomerID;
GO

-- 3. Çoklu Birleştirme ve Detay Raporu: Ahmet Yılmaz'ın aldığı ürünlerin detaylı listesi
SELECT 
    C.FullName AS [Müşteri Adı],
    P.ProductName AS [Ürün Adı], 
    P.Price AS [Fiyat], 
    Cat.CategoryName AS [Kategori]
FROM Customers C
INNER JOIN Orders O ON C.CustomerID = O.CustomerID
INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
INNER JOIN Products P ON OD.ProductID = P.ProductID
INNER JOIN Categories Cat ON P.CategoryID = Cat.CategoryID
WHERE C.FullName = 'Ahmet Yılmaz';
GO

-- 4. Gruplama ve Aggregate Fonksiyonlar: Kategorilere göre toplam ürün sayısı
SELECT 
    Cat.CategoryName AS [Kategori Adı], 
    COUNT(P.ProductID) AS [Ürün Sayısı]
FROM Categories Cat
LEFT JOIN Products P ON Cat.CategoryID = P.CategoryID
GROUP BY Cat.CategoryName;
GO

-- 5. Ciro Analizi (Zor): Müşterilerin şirkete kazandırdığı toplam ciro (Azalan sırada)
SELECT 
    C.FullName AS [Müşteri Adı], 
    SUM(O.TotalAmount) AS [Toplam Ciro]
FROM Customers C
INNER JOIN Orders O ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerID, C.FullName
ORDER BY [Toplam Ciro] DESC;
GO

-- 6. Zaman Analizi: Siparişlerin üzerinden bugüne kadar geçen gün sayısının hesaplanması
SELECT 
    O.OrderID AS [Sipariş No], 
    C.FullName AS [Müşteri Adı],
    O.OrderDate AS [Sipariş Tarihi], 
    GETDATE() AS [Bugünün Tarihi],
    DATEDIFF(DAY, O.OrderDate, GETDATE()) AS [Geçen Gün Sayısı]
FROM Orders O
INNER JOIN Customers C ON O.CustomerID = C.CustomerID;
GO

-- =========================================================================
-- BÖLÜM 4: İLERİ SEVİYE VERİ TABANI NESNELERİ
-- =========================================================================

-- 1. View (Görünüm) Oluşturma: vw_SiparisOzet
CREATE VIEW vw_SiparisOzet AS
SELECT 
    C.FullName AS [Müşteri Adı],
    O.OrderDate AS [Sipariş Tarihi],
    P.ProductName AS [Ürün Adı],
    OD.Quantity AS [Adet]
FROM Customers C
INNER JOIN Orders O ON C.CustomerID = O.CustomerID
INNER JOIN OrderDetails OD ON O.OrderID = OD.OrderID
INNER JOIN Products P ON OD.ProductID = P.ProductID;
GO

-- View Test Sorgusu
SELECT * FROM vw_SiparisOzet;
GO

-- 2. Yedekleme (Backup): NovaStoreDB veri tabanının C:\Yedek klasörüne yedeklenmesi
BACKUP DATABASE NovaStoreDB
TO DISK = 'C:\Yedek\NovaStoreDB_Yedek.bak'
WITH FORMAT,
     MEDIANAME = 'NovaStoreDB_Backup',
     NAME = 'NovaStoreDB Tam Yedek (Full Backup)';
GO
