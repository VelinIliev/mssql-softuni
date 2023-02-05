CREATE DATABASE Bakery

GO 

USE Bakery

--01. DDL
CREATE TABLE Countries (
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) UNIQUE NOT NULL
	)

CREATE TABLE Customers (
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(25) NOT NULL,
	LastName VARCHAR (25) NOT NULL,
	Gender CHAR(1) CHECK(Gender IN ('M', 'F')),
	Age INT,
	PhoneNumber CHAR(10) NOT NULL,
	CountryId INT FOREIGN KEY REFERENCES Countries(Id)
	)

CREATE TABLE Products (
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(25) UNIQUE NOT NULL,
	[Description] VARCHAR(250),
	Recipe VARCHAR(MAX),
	Price DECIMAL(10,2) NOT NULL CHECK(Price > 0)
	)

CREATE TABLE Feedbacks (
	Id INT PRIMARY KEY IDENTITY,
	[Description] VARCHAR(255),
	Rate DECIMAL(4,2) NOT NULL CHECK(Rate >= 0 AND Rate <= 10),
	ProductId INT FOREIGN KEY REFERENCES Products(Id) NOT NULL,
	CustomerId INT FOREIGN KEY REFERENCES Customers(Id) NOT NULL
	)

CREATE TABLE Distributors (
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(25) NOT NULL UNIQUE,
	AddressText VARCHAR(30) NOT NULL,
	Summary VARCHAR(200),
	CountryId INT FOREIGN KEY REFERENCES Countries(Id) NOT NULL
	)

CREATE TABLE Ingredients (
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL,
	[Description] VARCHAR(200),
	OriginCountryId INT FOREIGN KEY REFERENCES Countries(Id) NOT NULL,
	DistributorId INT FOREIGN KEY REFERENCES Distributors(Id) NOT NULL
	)

CREATE TABLE ProductsIngredients (
	ProductId INT FOREIGN KEY REFERENCES Products(Id) NOT NULL,
	IngredientId INT FOREIGN KEY REFERENCES Ingredients(Id) NOT NULL,
	PRIMARY KEY (ProductId, IngredientId)
	)

--02. Insert
INSERT INTO Distributors ([Name], CountryId, AddressText, Summary)
VALUES 
	('Deloitte & Touche', 2, '6 Arch St #9757', 'Customizable neutral traveling'),
	('Congress Title', 13, '58 Hancock St', 'Customer loyalty'),
	('Kitchen People', 1, '3 E 31st St #77', 'Triple-buffered stable delivery'),
	('General Color Co Inc', 21, '6185 Bohn St #72', 'Focus group'),
	('Beck Corporation', 23, '21 E 64th Ave', 'Quality-focused 4th generation hardware')

INSERT INTO Customers(FirstName, LastName, Age, Gender, PhoneNumber, CountryId)
VALUES
	('Francoise', 'Rautenstrauch', 15, 'M', '0195698399', 5),
	('Kendra', 'Loud', 22, 'F', '0063631526', 11),
	('Lourdes', 'Bauswell', 50, 'M', '0139037043', 8),
	('Hannah', 'Edmison', 18, 'F', '0043343686', 1),
	('Tom', 'Loeza', 31, 'M', '0144876096', 23),
	('Queenie', 'Kramarczyk', 30, 'F', '0064215793', 29),
	('Hiu', 'Portaro', 25, 'M', '0068277755', 16),
	('Josefa', 'Opitz', 43, 'F', '0197887645', 17)

--03. Update
UPDATE Ingredients
SET DistributorId = 35
WHERE [Name] IN ('Bay Leaf', 'Paprika', 'Poppy')

UPDATE Ingredients
SET OriginCountryId = 14
WHERE OriginCountryId = 8

--04. Delete
DELETE Feedbacks
WHERE CustomerId = 14 OR ProductId = 5

--05. Products By Price
SELECT [Name], Price, [Description] FROM Products
ORDER BY Price DESC, [Name]

--06. Negative Feedback
SELECT f.ProductId, f.Rate, f.[Description],
	f.CustomerId, c.Age, c.Gender
	FROM Feedbacks AS f
JOIN Customers AS c
ON f.CustomerId = c.Id
WHERE f.Rate < 5
ORDER BY f.ProductId DESC, f.Rate

--07. Customers without Feedback
SELECT 
	CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
	c.PhoneNumber,
	c.Gender
FROM Customers AS c
LEFT JOIN Feedbacks AS f
ON f.CustomerId = c.Id
WHERE f.CustomerId IS NULL
ORDER BY c.Id

--08. Customers by Criteria
SELECT cu.FirstName, cu.Age, cu.PhoneNumber FROM Customers AS cu
JOIN Countries AS co
ON cu.CountryId = co.Id
WHERE	(cu.Age >= 21 AND 
		cu.FirstName LIKE '%an%') OR
		(cu.PhoneNumber LIKE '%38' AND
		co.[Name] <> 'Greece')
ORDER BY cu.FirstName, cu.Age DESC

--09. Middle Range Distributors
SELECT	d.[Name] AS DistributorName, 
		i.[Name] AS IngredientName, 
		p.[Name] AS ProductName,
		AVG(f.Rate) AS AverageRate FROM Distributors AS d
LEFT JOIN Ingredients AS i
ON i.DistributorId = d.Id
LEFT JOIN ProductsIngredients AS [pi]
ON [pi].IngredientId = i.Id
LEFT JOIN Products AS p
ON [pi].ProductId = p.Id
LEFT JOIN Feedbacks AS f
ON f.ProductId = p.id
WHERE i.DistributorId IS NOT NULL
GROUP BY d.id, d.[Name], i.[Name], p.[Name]
HAVING AVG(f.Rate) BETWEEN 5 AND 8
ORDER BY d.[Name], i.[Name], p.[Name]

--10. Country Representative

--11. Customers With Countries
GO 

CREATE VIEW v_UserWithCountries 
AS
SELECT CONCAT(cu.FirstName, ' ', cu.LastName) AS CustomerName,
	cu.Age, cu.Gender, co.Name AS CountryName
FROM Customers AS cu
JOIN Countries AS co
ON cu.CountryId = co.Id

GO

SELECT TOP 5 *
  FROM v_UserWithCountries
ORDER BY Age

--12. Delete Products