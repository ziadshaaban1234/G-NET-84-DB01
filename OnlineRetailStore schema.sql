-- ============================================================
-- Online Retail Store Management System - Database Schema
-- Dialect: T-SQL (SQL Server)
-- ============================================================

CREATE TABLE Category (
    CategoryID          INT IDENTITY(1,1) PRIMARY KEY,
    Name                NVARCHAR(100) NOT NULL,
    Description         NVARCHAR(500) NULL,
    ParentCategoryID    INT NULL,
    CONSTRAINT FK_Category_ParentCategory FOREIGN KEY (ParentCategoryID)
        REFERENCES Category (CategoryID)
);

CREATE TABLE Supplier (
    SupplierID      INT IDENTITY(1,1) PRIMARY KEY,
    Name            NVARCHAR(150) NOT NULL,
    ContactNumber   NVARCHAR(20) NULL,
    Email           NVARCHAR(150) NULL,
    Address         NVARCHAR(250) NULL,
    Country         NVARCHAR(100) NULL
);

CREATE TABLE Product (
    ProductID       INT IDENTITY(1,1) PRIMARY KEY,
    Name            NVARCHAR(150) NOT NULL,
    Description     NVARCHAR(1000) NULL,
    UnitPrice       DECIMAL(10, 2) NOT NULL,
    StockQuantity   INT NOT NULL DEFAULT 0,
    DateAdded       DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CategoryID      INT NOT NULL,
    CONSTRAINT FK_Product_Category FOREIGN KEY (CategoryID)
        REFERENCES Category (CategoryID)
);

-- Many-to-many: a supplier supplies many products, a product may come from many suppliers.
CREATE TABLE ProductSupplier (
    ProductID   INT NOT NULL,
    SupplierID  INT NOT NULL,
    CONSTRAINT PK_ProductSupplier PRIMARY KEY (ProductID, SupplierID),
    CONSTRAINT FK_ProductSupplier_Product FOREIGN KEY (ProductID)
        REFERENCES Product (ProductID),
    CONSTRAINT FK_ProductSupplier_Supplier FOREIGN KEY (SupplierID)
        REFERENCES Supplier (SupplierID)
);

CREATE TABLE Customer (
    CustomerID          INT IDENTITY(1,1) PRIMARY KEY,
    FullName            NVARCHAR(150) NOT NULL,
    Email               NVARCHAR(150) NOT NULL UNIQUE,
    PhoneNumber         NVARCHAR(20) NULL,
    ShippingAddress     NVARCHAR(250) NULL,
    RegistrationDate    DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);

-- Method/status live here; Orders references a Payment instead of repeating them.
CREATE TABLE Payment (
    PaymentID   INT IDENTITY(1,1) PRIMARY KEY,
    PaymentDate DATETIME2 NOT NULL,
    Amount      DECIMAL(10, 2) NOT NULL,
    Method      NVARCHAR(50) NOT NULL, -- credit card, wallet, bank transfer
    Status      NVARCHAR(50) NOT NULL
);

-- A single payment can cover multiple orders (e.g. preloaded store credit), so PaymentID
-- lives on Orders rather than the other way around.
CREATE TABLE Orders (
    OrderID     INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID  INT NOT NULL,
    PaymentID   INT NULL,
    OrderDate   DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    TotalAmount DECIMAL(10, 2) NOT NULL,
    Status      NVARCHAR(50) NOT NULL, -- pending, shipped, delivered, canceled
    CONSTRAINT FK_Orders_Customer FOREIGN KEY (CustomerID)
        REFERENCES Customer (CustomerID),
    CONSTRAINT FK_Orders_Payment FOREIGN KEY (PaymentID)
        REFERENCES Payment (PaymentID)
);

-- Order line items: one row per product within an order, priced at time of purchase.
CREATE TABLE OrderItem (
    OrderID     INT NOT NULL,
    ProductID   INT NOT NULL,
    Quantity    INT NOT NULL,
    UnitPrice   DECIMAL(10, 2) NOT NULL, -- price at the time of purchase
    CONSTRAINT PK_OrderItem PRIMARY KEY (OrderID, ProductID),
    CONSTRAINT FK_OrderItem_Order FOREIGN KEY (OrderID)
        REFERENCES Orders (OrderID),
    CONSTRAINT FK_OrderItem_Product FOREIGN KEY (ProductID)
        REFERENCES Product (ProductID)
);

CREATE TABLE Shipment (
    ShipmentID      INT IDENTITY(1,1) PRIMARY KEY,
    OrderID         INT NOT NULL,
    ShipmentDate    DATETIME2 NOT NULL,
    DeliveryDate    DATETIME2 NULL,
    CarrierName     NVARCHAR(100) NOT NULL,
    TrackingNumber  NVARCHAR(100) NULL,
    Status          NVARCHAR(50) NOT NULL,
    CONSTRAINT FK_Shipment_Order FOREIGN KEY (OrderID)
        REFERENCES Orders (OrderID)
);

-- ReferenceID points to either a SupplierID (Type = 'in') or an OrderID (Type = 'out'),
-- so it is intentionally not a strict foreign key to a single table.
CREATE TABLE StockTransaction (
    TransactionID   INT IDENTITY(1,1) PRIMARY KEY,
    ProductID       INT NOT NULL,
    TransactionDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    QuantityChange  INT NOT NULL,
    Type            NVARCHAR(3) NOT NULL,
    ReferenceID     INT NULL,
    CONSTRAINT FK_StockTransaction_Product FOREIGN KEY (ProductID)
        REFERENCES Product (ProductID),
    CONSTRAINT CK_StockTransaction_Type CHECK (Type IN ('in', 'out'))
);

CREATE TABLE Review (
    ReviewID    INT IDENTITY(1,1) PRIMARY KEY,
    ProductID   INT NOT NULL,
    CustomerID  INT NOT NULL,
    Rating      INT NOT NULL,
    Comment     NVARCHAR(1000) NULL,
    ReviewDate  DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Review_Product FOREIGN KEY (ProductID)
        REFERENCES Product (ProductID),
    CONSTRAINT FK_Review_Customer FOREIGN KEY (CustomerID)
        REFERENCES Customer (CustomerID),
    CONSTRAINT CK_Review_Rating CHECK (Rating BETWEEN 1 AND 5)
);
