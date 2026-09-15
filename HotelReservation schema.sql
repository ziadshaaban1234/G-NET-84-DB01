-- ============================================================
-- Hotel Reservation Management System - Database Schema
-- Dialect: T-SQL (SQL Server)
-- ============================================================

-- ManagerStaffID's FK to Staff is added after Staff exists below: a hotel has a manager who
-- is a staff member, and every staff member belongs to a hotel (circular reference).
CREATE TABLE Hotel (
    HotelID         INT IDENTITY(1,1) PRIMARY KEY,
    Name            NVARCHAR(150) NOT NULL,
    StarRating      INT NOT NULL,
    Address         NVARCHAR(250) NOT NULL,
    City            NVARCHAR(100) NOT NULL,
    ContactNumber   NVARCHAR(20) NULL,
    ManagerStaffID  INT NULL,
    CONSTRAINT CK_Hotel_StarRating CHECK (StarRating BETWEEN 1 AND 5)
);

CREATE TABLE Staff (
    StaffID     INT IDENTITY(1,1) PRIMARY KEY,
    FullName    NVARCHAR(150) NOT NULL,
    Position    NVARCHAR(50) NOT NULL, -- receptionist, cleaner, manager, ...
    Salary      DECIMAL(10, 2) NOT NULL,
    HotelID     INT NOT NULL,
    CONSTRAINT FK_Staff_Hotel FOREIGN KEY (HotelID)
        REFERENCES Hotel (HotelID)
);

ALTER TABLE Hotel
    ADD CONSTRAINT FK_Hotel_Manager FOREIGN KEY (ManagerStaffID)
        REFERENCES Staff (StaffID);

CREATE TABLE Amenity (
    AmenityID   INT IDENTITY(1,1) PRIMARY KEY,
    Name        NVARCHAR(50) NOT NULL UNIQUE -- sea view, balcony, kitchen, ...
);

-- RoomNumber is only unique within a hotel, so the primary key is composite.
CREATE TABLE Room (
    HotelID             INT NOT NULL,
    RoomNumber          NVARCHAR(10) NOT NULL,
    RoomType            NVARCHAR(50) NOT NULL, -- single, double, suite
    Capacity            INT NOT NULL,
    DailyRate           DECIMAL(10, 2) NOT NULL,
    AvailabilityStatus  NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_Room PRIMARY KEY (HotelID, RoomNumber),
    CONSTRAINT FK_Room_Hotel FOREIGN KEY (HotelID)
        REFERENCES Hotel (HotelID)
);

-- Many-to-many: a room can offer several amenities, an amenity applies to many rooms.
CREATE TABLE RoomAmenity (
    HotelID     INT NOT NULL,
    RoomNumber  NVARCHAR(10) NOT NULL,
    AmenityID   INT NOT NULL,
    CONSTRAINT PK_RoomAmenity PRIMARY KEY (HotelID, RoomNumber, AmenityID),
    CONSTRAINT FK_RoomAmenity_Room FOREIGN KEY (HotelID, RoomNumber)
        REFERENCES Room (HotelID, RoomNumber),
    CONSTRAINT FK_RoomAmenity_Amenity FOREIGN KEY (AmenityID)
        REFERENCES Amenity (AmenityID)
);

CREATE TABLE Guest (
    GuestID             INT IDENTITY(1,1) PRIMARY KEY,
    FullName            NVARCHAR(150) NOT NULL,
    DateOfBirth         DATE NOT NULL,
    ContactDetails      NVARCHAR(250) NULL,
    Nationality         NVARCHAR(100) NULL,
    IdPassportNumber    NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Reservation (
    ReservationID   INT IDENTITY(1,1) PRIMARY KEY,
    HotelID         INT NOT NULL,
    CheckInDate     DATE NOT NULL,
    CheckOutDate    DATE NOT NULL,
    BookingDate     DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    NumAdults       INT NOT NULL,
    NumChildren     INT NOT NULL DEFAULT 0,
    TotalPrice      DECIMAL(10, 2) NOT NULL,
    Status          NVARCHAR(50) NOT NULL, -- confirmed, checked-in, canceled, completed
    CONSTRAINT FK_Reservation_Hotel FOREIGN KEY (HotelID)
        REFERENCES Hotel (HotelID),
    CONSTRAINT CK_Reservation_Dates CHECK (CheckOutDate > CheckInDate)
);

-- Many-to-many: a reservation can book several rooms, a room can appear in many reservations.
CREATE TABLE ReservationRoom (
    ReservationID   INT NOT NULL,
    HotelID         INT NOT NULL,
    RoomNumber      NVARCHAR(10) NOT NULL,
    CONSTRAINT PK_ReservationRoom PRIMARY KEY (ReservationID, HotelID, RoomNumber),
    CONSTRAINT FK_ReservationRoom_Reservation FOREIGN KEY (ReservationID)
        REFERENCES Reservation (ReservationID),
    CONSTRAINT FK_ReservationRoom_Room FOREIGN KEY (HotelID, RoomNumber)
        REFERENCES Room (HotelID, RoomNumber)
);

-- Many-to-many: a reservation can include several guests, a guest can appear on many
-- reservations.
CREATE TABLE ReservationGuest (
    ReservationID   INT NOT NULL,
    GuestID         INT NOT NULL,
    CONSTRAINT PK_ReservationGuest PRIMARY KEY (ReservationID, GuestID),
    CONSTRAINT FK_ReservationGuest_Reservation FOREIGN KEY (ReservationID)
        REFERENCES Reservation (ReservationID),
    CONSTRAINT FK_ReservationGuest_Guest FOREIGN KEY (GuestID)
        REFERENCES Guest (GuestID)
);

CREATE TABLE Payment (
    PaymentID           INT IDENTITY(1,1) PRIMARY KEY,
    PaymentDate         DATETIME2 NOT NULL,
    Amount              DECIMAL(10, 2) NOT NULL,
    Method              NVARCHAR(50) NOT NULL, -- credit card, cash, online
    ConfirmationNumber  NVARCHAR(50) NULL
);

-- Many-to-many: a reservation may be paid in installments, and one payment (e.g. from a
-- travel agency) may cover multiple reservations.
CREATE TABLE ReservationPayment (
    ReservationID   INT NOT NULL,
    PaymentID       INT NOT NULL,
    CONSTRAINT PK_ReservationPayment PRIMARY KEY (ReservationID, PaymentID),
    CONSTRAINT FK_ReservationPayment_Reservation FOREIGN KEY (ReservationID)
        REFERENCES Reservation (ReservationID),
    CONSTRAINT FK_ReservationPayment_Payment FOREIGN KEY (PaymentID)
        REFERENCES Payment (PaymentID)
);

CREATE TABLE ServiceRequest (
    ServiceID       INT IDENTITY(1,1) PRIMARY KEY,
    ServiceName     NVARCHAR(100) NOT NULL, -- laundry, spa, transportation
    RequestDate     DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    Charge          DECIMAL(10, 2) NOT NULL,
    ReservationID   INT NOT NULL,
    StaffID         INT NOT NULL,
    CONSTRAINT FK_ServiceRequest_Reservation FOREIGN KEY (ReservationID)
        REFERENCES Reservation (ReservationID),
    CONSTRAINT FK_ServiceRequest_Staff FOREIGN KEY (StaffID)
        REFERENCES Staff (StaffID)
);
