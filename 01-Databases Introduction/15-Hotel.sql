CREATE DATABASE Hotel

--•	Employees (Id, FirstName, LastName, Title, Notes)
CREATE TABLE Employees (
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	Title NVARCHAR(30) NOT NULL,
	Notes NVARCHAR(MAX)
	)

INSERT INTO Employees(FirstName, LastName, Title, Notes)
VALUES
	('Ivan', 'Petrov', 'Director', 'asdasdasd'),
	('Ivan', 'Ivanov', 'Manager', 'asdasdasd'),
	('Pesho', 'Petrov', 'Valey', 'asdasdasd')

--•	Customers (AccountNumber, FirstName, LastName, PhoneNumber, EmergencyName, 
--EmergencyNumber, Notes)
CREATE TABLE Customers (
	AccountNumber BIGINT PRIMARY KEY, 
	FirstName NVARCHAR(30) NOT NULL, 
	LastName NVARCHAR(30) NOT NULL, 
	PhoneNumber NVARCHAR(15) NOT NULL, 
	EmergencyName NVARCHAR(30), 
	EmergencyNumber NVARCHAR(15), 
	Notes  NVARCHAR(MAX)
	)

INSERT INTO Customers (AccountNumber, FirstName, LastName, PhoneNumber, 
						EmergencyName, EmergencyNumber, Notes)
VALUES 
	(12345678, 'Ivan', 'Ivanov', '0001258662', 'Goshko Ivanov', '04407070880', 'asdasd'),
	(12345679, 'Ivan', 'Ivanov', '0001258662', 'Goshko Ivanov', '04407070880', 'asdasd'),
	(12345680, 'Ivan', 'Ivanov', '0001258662', 'Goshko Ivanov', '04407070880', 'asdasd')

--•	RoomStatus (RoomStatus, Notes)
CREATE TABLE RoomStatus (
	RoomStatus NVARCHAR(10) PRIMARY KEY,
	Notes NVARCHAR(MAX)
)
INSERT INTO RoomStatus(RoomStatus, Notes)
VALUES 
	('free', 'aspod'),
	('notfree', 'askd'),
	('sakd', 'alskdj')


--•	RoomTypes (RoomType, Notes)
CREATE TABLE RoomTypes (
	RoomType NVARCHAR(30) PRIMARY KEY,
	Notes NVARCHAR(MAX)
	)
	
INSERT INTO RoomTypes(RoomType, Notes)
VALUES 
	('for two', 'aspod'),
	('appartment', 'askd'),
	('for one', 'alskdj')

-- •	BedTypes (BedType, Notes)
CREATE TABLE BedTypes (
	BedType NVARCHAR(30) PRIMARY KEY,
	Notes NVARCHAR(MAX)
	)

INSERT INTO BedTypes(BedType, Notes)
VALUES 
	('king size', 'alksjd'),
	('one', 'alksjd'),
	('two', 'alksjd')

--•	Rooms (RoomNumber, RoomType, BedType, Rate, RoomStatus, Notes)
CREATE TABLE Rooms (
	RoomNumber INT PRIMARY KEY, 
	RoomType NVARCHAR(30) NOT NULL, 
	BedType NVARCHAR(30) NOT NULL, 
	Rate TINYINT, 
	RoomStatus NVARCHAR(10) NOT NULL, 
	Notes NVARCHAR(MAX)
	)

INSERT INTO Rooms(RoomNumber, RoomType, BedType, Rate, RoomStatus, Notes)
VALUES 
	(10, 'for one', 'for one', 5, 'free', 'asdjka'),
	(11, 'for one', 'for one', 5, 'free', 'asdjka'),
	(12, 'for one', 'for one', 5, 'free', 'asdjka')

--•	Payments (Id, EmployeeId, PaymentDate, AccountNumber, FirstDateOccupied, 
--LastDateOccupied, TotalDays, AmountCharged, TaxRate, TaxAmount, PaymentTotal, Notes)
CREATE TABLE Payments (
	Id BIGINT PRIMARY KEY IDENTITY, 
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL, 
	PaymentDate DATETIME2 NOT NULL, 
	AccountNumber BIGINT NOT NULL, 
	FirstDateOccupied DATETIME2 NOT NULL, 
	LastDateOccupied DATETIME2 NOT NULL, 
	TotalDays AS DATEDIFF(Day, FirstDateOccupied, LastDateOccupied),
	AmountCharged DECIMAL(6,2) NOT NULL,
	TaxRate DECIMAL(6,2) NOT NULL, 
	TaxAmount DECIMAL(6,2) NOT NULL, 
	PaymentTotal AS AmountCharged + TaxRate + TaxAmount, 
	Notes NVARCHAR(MAX)
	)

INSERT INTO Payments (EmployeeId, PaymentDate, AccountNumber, FirstDateOccupied, 
		LastDateOccupied, AmountCharged, TaxRate, TaxAmount, Notes)
VALUES
	(1, '10-10-2022', 123456, '10-10-2022', '10-12-2022', 10, 10, 2, 'aslk'),
	(1, '10-10-2022', 123456, '10-10-2022', '10-12-2022', 10, 10, 2, 'aslk'),
	(1, '10-10-2022', 123456, '10-10-2022', '10-12-2022', 10, 10, 2, 'aslk')

--•	Occupancies (Id, EmployeeId, DateOccupied, AccountNumber, 
--RoomNumber, RateApplied, PhoneCharge, Notes)
CREATE TABLE Occupancies (
	Id INT PRIMARY KEY IDENTITY, 
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id) NOT NULL, 
	DateOccupied DATETIME2 NOT NULL, 
	AccountNumber BIGINT NOT NULL, 
	RoomNumber INT NOT NULL, 
	RateApplied DECIMAL(5,2) NOT NULL, 
	PhoneCharge DECIMAL(5,2) NOT NULL, 
	Notes NVARCHAR(MAX)
	)
INSERT INTO Occupancies (EmployeeId, DateOccupied, AccountNumber, 
						RoomNumber, RateApplied, PhoneCharge, Notes)
VALUES
	(1, '10-10-2023', 1234, 1, 10, 10, 'asdds'),
	(1, '10-10-2023', 1234, 1, 10, 10, 'asdds'),
	(1, '10-10-2023', 1234, 1, 10, 10, 'asdds')