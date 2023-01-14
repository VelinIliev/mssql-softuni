-- 16 Create SoftUni Database
CREATE DATABASE SoftUni

CREATE TABLE Towns (
    Id INT PRIMARY KEY IDENTITY,
    [Name] NVARCHAR(50) NOT NULL
    )

-- Addresses (Id, AddressText, TownId)
CREATE TABLE Addresses (
    Id INT PRIMARY KEY IDENTITY,
    AddressText NVARCHAR(100) NOT NULL,
    TownId INT FOREIGN KEY REFERENCES Towns(Id)
)

--Departments (Id, Name)
CREATE TABLE Departments (
    Id INT PRIMARY KEY IDENTITY,
    Name NVARCHAR(100) NOT NULL
)

--Employees (Id, FirstName, MiddleName, LastName, JobTitle, DepartmentId, HireDate, Salary, AddressId)
CREATE TABLE Employees (
    Id INT PRIMARY KEY IDENTITY, 
    FirstName NVARCHAR(100) NOT NULL, 
    MiddleName NVARCHAR(100), 
    LastName NVARCHAR(100) NOT NULL, 
    JobTitle NVARCHAR(100) NOT NULL, 
    DepartmentId INT FOREIGN KEY REFERENCES Departments(Id), 
    HireDate DATETIME2 NOT NULL, 
    Salary DeCIMAL(6, 2) NOT NULL, 
    AddressId INT FOREIGN KEY REFERENCES Addresses(Id) 
)

--18 Basic Insert
-- Towns: Sofia, Plovdiv, Varna, Burgas
INSERT INTO Towns
VALUES
    ('Sofia'),
    ('Plovdiv'),
    ('Varna'),
    ('Burgas')

--Departments: Engineering, Sales, Marketing, Software Development, Quality Assurance
INSERT INTO Departments
VALUES 
    ('Engineering'),
    ('Sales'),
    ('Marketing'),
    ('Software Development'),
    ('Quality Assurance')

--Employees
INSERT INTO Employees(FirstName, MiddleName, LastName, JobTitle, DepartmentId, 
					HireDate, Salary)
VALUES 
    ('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '02/01/2013', 3500.00),
	('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '03/02/2004', 4000.00),
	('Maria', 'Petrova', 'Ivanova', 'Intern', 5, '08/28/2016', 525.25),
	('Georgi', 'Teziev', 'Ivanov', 'CEO', 2, '12/09/2007', 3000.00),
	('Peter', 'Pan', 'Pan', 'Intern', 3, '08/28/2016', 599.88)

--19 Basic Select All Fields
SELECT * FROM [Towns]
SELECT * FROM [Departments]
SELECT * FROM [Employees]

--20 Basic Select All Fields and Order Them

SELECT * FROM Towns ORDER BY [Name]
SELECT * FROM Departments ORDER BY [Name]
SELECT * FROM Employees ORDER BY [Salary] DESC

-- 21 Basic Select Some Fields
SELECT [Name] FROM Towns ORDER BY [Name]
SELECT [Name] FROM Departments ORDER BY [Name]
SELECT FirstName, LastName, JobTitle, Salary FROM Employees ORDER BY [Salary] DESC

--22 Increase Employees Salary
UPDATE Employees SET Salary = Salary * 1.10
SELECT Salary FROM Employees

--23 Decrease Tax Rate
UPDATE Payments SET TaxRate = TaxRate * 0.97
SELECT TaxRate FROM Payments

--24 Occupancies 
TRUNCATE TABLE Occupancies
SELECT * FROM Occupancies
