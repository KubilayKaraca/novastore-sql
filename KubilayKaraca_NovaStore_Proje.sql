-- =============================================================
-- NovaStore E-Ticaret Veri Yönetim Sistemi
-- Veri Tabanı ve SQL Projesi
-- Hazırlayan: Kubilay Karaca
-- =============================================================


-- =============================================================
-- BÖLÜM 1: Veri Tabanı Tasarımı (Logical Design ve DDL)
-- =============================================================

-- 1. Veri Tabanı Oluşturma: NovaStoreDB
CREATE DATABASE NovaStoreDB;
GO
USE NovaStoreDB;
GO


-- 2. Tablo Gereksinimleri
-- Not: Foreign Key bağımlılıkları nedeniyle önce ana tablolar
-- (Categories, Customers), sonra bağımlı tablolar (Products, Orders,
-- OrderDetails) oluşturulmuştur.

-- A. Tablo: Categories (Kategoriler)
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL
);


-- C. Tablo: Customers (Müşteriler)
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(50),
    City VARCHAR(20),
    Email VARCHAR(100) UNIQUE
);


-- B. Tablo: Products (Ürünler)
CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2),
    Stock INT DEFAULT 0,
    CategoryID INT,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);


-- D. Tablo: Orders (Siparişler)
CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT,
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);


-- E. Tablo: OrderDetails (Sipariş Detayları - Ara Tablo)
CREATE TABLE OrderDetails (
    DetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);


-- =============================================================
-- BÖLÜM 2: Veri Girişi (DML - Insert)
-- =============================================================

-- Görev 1: 5 adet kategori ekleme
INSERT INTO Categories (CategoryName)
VALUES
    ('Elektronik'),
    ('Giyim'),
    ('Kitap'),
    ('Kozmetik'),
    ('Ev ve Yaşam');


-- Görev 2: Her kategoriye ait olacak şekilde toplam 12 ürün ekleme
INSERT INTO Products (ProductName, Price, Stock, CategoryID)
VALUES
    ('Akıllı Telefon', 25000.00, 15, 1),
    ('Dizüstü Bilgisayar', 45000.00, 8, 1),
    ('Bluetooth Kulaklık', 1500.00, 50, 1),
    ('Kışlık Kaban', 3000.00, 20, 2),
    ('Spor Ayakkabı', 2500.00, 35, 2),
    ('Roman: Suç ve Ceza', 150.00, 100, 3),
    ('Tarih Kitabı', 200.00, 45, 3),
    ('Güneş Kremi', 400.00, 60, 4),
    ('Parfüm', 1200.00, 25, 4),
    ('Kahve Makinesi', 4000.00, 12, 5),
    ('Çaydanlık', 800.00, 30, 5),
    ('Yastık Kılıfı', 150.00, 80, 5);


-- Görev 3: 5 adet müşteri kaydı oluşturma
INSERT INTO Customers (FullName, City, Email)
VALUES
    ('Ahmet Yılmaz', 'İstanbul', 'ahmet.yilmaz@email.com'),
    ('Ayşe Kaya', 'Ankara', 'ayse.kaya@email.com'),
    ('Mehmet Demir', 'İzmir', 'mehmet.demir@email.com'),
    ('Fatma Çelik', 'Bursa', 'fatma.celik@email.com'),
    ('Ali Can', 'Antalya', 'ali.can@email.com');


-- Görev 4 (a): Farklı tarihlerde yapılmış 8 sipariş ekleme
INSERT INTO Orders (CustomerID, OrderDate, TotalAmount)
VALUES
    (1, '2023-10-01 10:30:00', 25000.00),
    (2, '2023-10-05 14:15:00', 4000.00),
    (3, '2023-10-10 09:45:00', 150.00),
    (1, '2023-10-15 16:20:00', 3150.00),
    (4, '2023-10-20 11:10:00', 1200.00),
    (5, '2023-10-25 13:50:00', 3300.00),
    (2, '2023-10-28 15:30:00', 800.00),
    (3, '2023-11-02 10:00:00', 2500.00);


-- Görev 4 (b): Bu siparişlere ait sipariş detaylarını ekleme
INSERT INTO OrderDetails (OrderID, ProductID, Quantity)
VALUES
    (1, 1, 1),  -- Ahmet Yılmaz (Sipariş 1), Akıllı Telefon (Ürün 1), 1 Adet
    (2, 10, 1), -- Ayşe Kaya (Sipariş 2), Kahve Makinesi (Ürün 10), 1 Adet
    (3, 6, 1),  -- Mehmet Demir (Sipariş 3), Roman (Ürün 6), 1 Adet
    (4, 4, 1),  -- Ahmet Yılmaz (Sipariş 4), Kışlık Kaban (Ürün 4), 1 Adet
    (4, 6, 1),  -- Ahmet Yılmaz (Sipariş 4), Roman (Ürün 6), 1 Adet
    (5, 9, 1),  -- Fatma Çelik (Sipariş 5), Parfüm (Ürün 9), 1 Adet
    (6, 11, 1), -- Ali Can (Sipariş 6), Çaydanlık (Ürün 11), 1 Adet
    (6, 5, 1),  -- Ali Can (Sipariş 6), Spor Ayakkabı (Ürün 5), 1 Adet
    (7, 11, 1), -- Ayşe Kaya (Sipariş 7), Çaydanlık (Ürün 11), 1 Adet
    (8, 5, 1);  -- Mehmet Demir (Sipariş 8), Spor Ayakkabı (Ürün 5), 1 Adet


-- =============================================================
-- BÖLÜM 3: Sorgulama ve Analiz (DQL - Select ve Joins)
-- =============================================================

-- Soru 1 - Temel Listeleme: Stok miktarı 20'den az olan ürünlerin adı ve
-- stok miktarı (stok miktarına göre AZALAN sırada)
SELECT ProductName, Stock
FROM Products
WHERE Stock < 20
ORDER BY Stock DESC;


-- Soru 2 - Veri Birleştirme (JOIN): Hangi müşteri, hangi tarihte
-- sipariş vermiş?
SELECT c.FullName AS 'Müşteri Adı', c.City AS 'Şehir', o.OrderDate AS 'Sipariş Tarihi', o.TotalAmount AS 'Toplam Tutar'
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID;


-- Soru 3 - Çoklu Birleştirme ve Detay Raporu: "Ahmet Yılmaz" isimli
-- müşterinin aldığı ürünlerin isimleri, fiyatları ve kategorileri
SELECT p.ProductName AS 'Ürün Adı', p.Price AS 'Fiyat', cat.CategoryName AS 'Kategori'
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID
JOIN Categories cat ON p.CategoryID = cat.CategoryID
WHERE c.FullName = 'Ahmet Yılmaz';


-- Soru 4 - Gruplama ve Aggregate Fonksiyonlar: Hangi kategoride
-- toplam kaç adet ürün var?
SELECT cat.CategoryName AS 'Kategori', COUNT(p.ProductID) AS 'Toplam Ürün Sayısı'
FROM Categories cat
LEFT JOIN Products p ON cat.CategoryID = p.CategoryID
GROUP BY cat.CategoryName;


-- Soru 5 - Ciro Analizi: Her müşterinin şirkete kazandırdığı toplam ciro
-- (en çok harcama yapan müşteriden en aza doğru)
SELECT c.FullName AS 'Müşteri Adı', SUM(o.TotalAmount) AS 'Toplam Ciro'
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.FullName
ORDER BY SUM(o.TotalAmount) DESC;


-- Soru 6 - Zaman Analizi: Bugünün tarihine göre siparişlerin
-- üzerinden kaç gün geçtiği
SELECT OrderID, OrderDate, DATEDIFF(DAY, OrderDate, GETDATE()) AS 'Gecen_Gun_Sayisi'
FROM Orders;
GO


-- =============================================================
-- BÖLÜM 4: İleri Seviye Veri Tabanı Nesneleri
-- =============================================================

-- 1. View (Görünüm) Oluşturma: vw_SiparisOzet
-- Not: CREATE VIEW, bulunduğu batch'in ilk komutu olmak zorunda
-- olduğu için önceki sorgulardan GO ile ayrılmıştır.
CREATE VIEW vw_SiparisOzet AS
SELECT
    c.FullName AS 'Müşteri Adı',
    o.OrderDate AS 'Sipariş Tarihi',
    p.ProductName AS 'Ürün Adı',
    od.Quantity AS 'Adet'
FROM Customers c
JOIN Orders o ON c.CustomerID = o.CustomerID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN Products p ON od.ProductID = p.ProductID;
GO


-- 2. Yedekleme (Backup): NovaStoreDB veri tabanının yedeğinin
-- C:\Yedek\ klasörüne alınması
-- Not: Komut çalıştırılmadan önce C:\Yedek klasörü oluşturulmuş
-- olmalıdır.
BACKUP DATABASE NovaStoreDB
TO DISK = 'C:\Yedek\NovaStoreDB.bak';
GO
