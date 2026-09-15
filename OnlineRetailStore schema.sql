-- ============================================================
-- Online Retail Store Management System
-- Database Schema based on ER Diagram
-- Dialect: T-SQL (SQL Server)
-- ============================================================


-- Category
-- Has: Category (1) -- Category (M)
CREATE TABLE Category
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(500) NULL,
    MainCategoryID INT NULL,

    CONSTRAINT FK_Category_MainCategory
        FOREIGN KEY (MainCategoryID)
        REFERENCES Category(ID)
);


-- Supplier
CREATE TABLE Supplier
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL,
    ContactNum NVARCHAR(20) NULL,
    Email NVARCHAR(150) NULL,
    Address NVARCHAR(250) NULL,
    Country NVARCHAR(100) NULL
);


-- Product
-- Belongs: Product (M) -- Category (1)
CREATE TABLE Product
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL,
    Description NVARCHAR(1000) NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    Quantity INT NOT NULL DEFAULT 0,
    Date DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CategoryID INT NOT NULL,

    CONSTRAINT FK_Product_Category
        FOREIGN KEY (CategoryID)
        REFERENCES Category(ID)
);


-- Supply: Supplier (M) -- Product (M)
CREATE TABLE ProductSupplier
(
    ProductID INT NOT NULL,
    SupplierID INT NOT NULL,

    CONSTRAINT PK_ProductSupplier
        PRIMARY KEY (ProductID, SupplierID),

    CONSTRAINT FK_ProductSupplier_Product
        FOREIGN KEY (ProductID)
        REFERENCES Product(ID),

    CONSTRAINT FK_ProductSupplier_Supplier
        FOREIGN KEY (SupplierID)
        REFERENCES Supplier(ID)
);


-- Customer
CREATE TABLE Customer
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    FName NVARCHAR(150) NOT NULL,
    Email NVARCHAR(150) NOT NULL UNIQUE,
    PhNumber NVARCHAR(20) NULL,
    Address NVARCHAR(250) NULL,
    RegisterDate DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);


-- Payment
CREATE TABLE Payment
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Date DATETIME2 NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    Method NVARCHAR(50) NOT NULL,
    Status NVARCHAR(50) NOT NULL
);


-- Order
-- Place: Customer (1) -- Order (M)
-- Paid: Payment (1) -- Order (M)
CREATE TABLE [Order]
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    OrderDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    TotalAmount DECIMAL(10,2) NOT NULL,
    Status NVARCHAR(50) NOT NULL,
    PaymentMethod NVARCHAR(50) NOT NULL,
    CustomerID INT NOT NULL,
    PaymentID INT NULL,

    CONSTRAINT FK_Order_Customer
        FOREIGN KEY (CustomerID)
        REFERENCES Customer(ID),

    CONSTRAINT FK_Order_Payment
        FOREIGN KEY (PaymentID)
        REFERENCES Payment(ID)
);


-- Shipment
-- Has: Product (1) -- Shipment (M)
-- Have: Order (1) -- Shipment (M)
CREATE TABLE Shipment
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Date DATETIME2 NOT NULL,
    DeliveryDate DATETIME2 NULL,
    CarrierName NVARCHAR(100) NOT NULL,
    TrachNumber NVARCHAR(100) NULL,
    Status NVARCHAR(50) NOT NULL,
    ProductID INT NOT NULL,
    OrderID INT NOT NULL,

    CONSTRAINT FK_Shipment_Product
        FOREIGN KEY (ProductID)
        REFERENCES Product(ID),

    CONSTRAINT FK_Shipment_Order
        FOREIGN KEY (OrderID)
        REFERENCES [Order](ID)
);


-- Transaction
-- Has: Product (1) -- Transaction (M)
CREATE TABLE [Transaction]
(
    TransctionID INT IDENTITY(1,1) PRIMARY KEY,
    Date DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    QuantityChange INT NOT NULL,
    Type NVARCHAR(3) NOT NULL,
    Reference INT NULL,
    ProductID INT NOT NULL,

    CONSTRAINT FK_Transaction_Product
        FOREIGN KEY (ProductID)
        REFERENCES Product(ID),

    CONSTRAINT CK_Transaction_Type
        CHECK (Type IN ('in', 'out'))
);


-- OrderItem
-- Contains: Order (1) -- OrderItem (M)
-- Represented: Product (1) -- OrderItem (M)
CREATE TABLE OrderItem
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,

    CONSTRAINT FK_OrderItem_Order
        FOREIGN KEY (OrderID)
        REFERENCES [Order](ID),

    CONSTRAINT FK_OrderItem_Product
        FOREIGN KEY (ProductID)
        REFERENCES Product(ID)
);


-- Review
-- Has: Product (1) -- Review (M)
-- Write: Customer (1) -- Review (M)
CREATE TABLE Review
(
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Rating INT NOT NULL,
    Comment NVARCHAR(1000) NULL,
    Date DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    ProductID INT NOT NULL,
    CustomerID INT NOT NULL,

    CONSTRAINT FK_Review_Product
        FOREIGN KEY (ProductID)
        REFERENCES Product(ID),

    CONSTRAINT FK_Review_Customer
        FOREIGN KEY (CustomerID)
        REFERENCES Customer(ID),

    CONSTRAINT CK_Review_Rating
        CHECK (Rating BETWEEN 1 AND 5)
);