-- ============================================================
-- Hotel Reservation Management System
-- Database Schema based on ER Diagram / Assignment
-- Dialect: T-SQL (SQL Server)
-- ============================================================


CREATE TABLE Hotel
(
    HotelID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL,
    StarRating INT NOT NULL,
    Address NVARCHAR(250) NOT NULL,
    City NVARCHAR(100) NOT NULL,
    ContactNumber NVARCHAR(20) NULL,
    ManagerStaffID INT NULL UNIQUE,

    CONSTRAINT CK_Hotel_StarRating
        CHECK (StarRating BETWEEN 1 AND 5)
);


CREATE TABLE Staff
(
    StaffID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(150) NOT NULL,
    Position NVARCHAR(50) NOT NULL,
    Salary DECIMAL(10,2) NOT NULL,
    HotelID INT NOT NULL,

    CONSTRAINT FK_Staff_Hotel
        FOREIGN KEY (HotelID)
        REFERENCES Hotel(HotelID)
);


ALTER TABLE Hotel
ADD CONSTRAINT FK_Hotel_Manager
    FOREIGN KEY (ManagerStaffID)
    REFERENCES Staff(StaffID);


CREATE TABLE Room
(
    HotelID INT NOT NULL,
    RoomNumber NVARCHAR(10) NOT NULL,
    RoomType NVARCHAR(50) NOT NULL,
    Capacity INT NOT NULL,
    DailyRate DECIMAL(10,2) NOT NULL,
    Status NVARCHAR(50) NOT NULL,

    CONSTRAINT PK_Room
        PRIMARY KEY (HotelID, RoomNumber),

    CONSTRAINT FK_Room_Hotel
        FOREIGN KEY (HotelID)
        REFERENCES Hotel(HotelID)
);


-- Amenities required by the assignment.
CREATE TABLE Amenity
(
    AmenityID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);


-- A room can have multiple amenities,
-- and an amenity can belong to multiple rooms.
CREATE TABLE RoomAmenity
(
    HotelID INT NOT NULL,
    RoomNumber NVARCHAR(10) NOT NULL,
    AmenityID INT NOT NULL,

    CONSTRAINT PK_RoomAmenity
        PRIMARY KEY (HotelID, RoomNumber, AmenityID),

    CONSTRAINT FK_RoomAmenity_Room
        FOREIGN KEY (HotelID, RoomNumber)
        REFERENCES Room(HotelID, RoomNumber),

    CONSTRAINT FK_RoomAmenity_Amenity
        FOREIGN KEY (AmenityID)
        REFERENCES Amenity(AmenityID)
);


CREATE TABLE Guest
(
    GuestID INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(150) NOT NULL,
    DateOfBirth DATE NOT NULL,
    ContactDetails NVARCHAR(250) NULL,
    Nationality NVARCHAR(100) NULL,
    PassportNumber NVARCHAR(50) NOT NULL UNIQUE
);


CREATE TABLE Reservation
(
    ReservationID INT IDENTITY(1,1) PRIMARY KEY,
    CheckInDate DATE NOT NULL,
    CheckOutDate DATE NOT NULL,
    BookingDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    NumberOfChildren INT NOT NULL DEFAULT 0,
    TotalPrice DECIMAL(10,2) NOT NULL,
    Status NVARCHAR(50) NOT NULL,
    NumberOfAdults INT NOT NULL,

    CONSTRAINT CK_Reservation_Dates
        CHECK (CheckOutDate > CheckInDate)
);


-- Book: Room (M) -- Reservation (M)
CREATE TABLE ReservationRoom
(
    ReservationID INT NOT NULL,
    HotelID INT NOT NULL,
    RoomNumber NVARCHAR(10) NOT NULL,

    CONSTRAINT PK_ReservationRoom
        PRIMARY KEY (ReservationID, HotelID, RoomNumber),

    CONSTRAINT FK_ReservationRoom_Reservation
        FOREIGN KEY (ReservationID)
        REFERENCES Reservation(ReservationID),

    CONSTRAINT FK_ReservationRoom_Room
        FOREIGN KEY (HotelID, RoomNumber)
        REFERENCES Room(HotelID, RoomNumber)
);


-- Make: Guest (M) -- Reservation (M)
CREATE TABLE ReservationGuest
(
    ReservationID INT NOT NULL,
    GuestID INT NOT NULL,

    CONSTRAINT PK_ReservationGuest
        PRIMARY KEY (ReservationID, GuestID),

    CONSTRAINT FK_ReservationGuest_Reservation
        FOREIGN KEY (ReservationID)
        REFERENCES Reservation(ReservationID),

    CONSTRAINT FK_ReservationGuest_Guest
        FOREIGN KEY (GuestID)
        REFERENCES Guest(GuestID)
);


CREATE TABLE Payment
(
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    Date DATETIME2 NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    Method NVARCHAR(50) NOT NULL,
    ConfirmationNumber NVARCHAR(50) NULL
);


-- Paid: Reservation (M) -- Payment (M)
CREATE TABLE ReservationPayment
(
    ReservationID INT NOT NULL,
    PaymentID INT NOT NULL,

    CONSTRAINT PK_ReservationPayment
        PRIMARY KEY (ReservationID, PaymentID),

    CONSTRAINT FK_ReservationPayment_Reservation
        FOREIGN KEY (ReservationID)
        REFERENCES Reservation(ReservationID),

    CONSTRAINT FK_ReservationPayment_Payment
        FOREIGN KEY (PaymentID)
        REFERENCES Payment(PaymentID)
);


-- Service requests are connected to both the reservation
-- and the staff member who provides the service.
CREATE TABLE Service
(
    ServiceID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceName NVARCHAR(100) NOT NULL,
    RequestDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    Charge DECIMAL(10,2) NOT NULL,
    ReservationID INT NOT NULL,
    StaffID INT NOT NULL,

    CONSTRAINT FK_Service_Reservation
        FOREIGN KEY (ReservationID)
        REFERENCES Reservation(ReservationID),

    CONSTRAINT FK_Service_Staff
        FOREIGN KEY (StaffID)
        REFERENCES Staff(StaffID)
);


-- Assist: Staff (M) -- Reservation (M)
CREATE TABLE ReservationStaff
(
    ReservationID INT NOT NULL,
    StaffID INT NOT NULL,

    CONSTRAINT PK_ReservationStaff
        PRIMARY KEY (ReservationID, StaffID),

    CONSTRAINT FK_ReservationStaff_Reservation
        FOREIGN KEY (ReservationID)
        REFERENCES Reservation(ReservationID),

    CONSTRAINT FK_ReservationStaff_Staff
        FOREIGN KEY (StaffID)
        REFERENCES Staff(StaffID)
);