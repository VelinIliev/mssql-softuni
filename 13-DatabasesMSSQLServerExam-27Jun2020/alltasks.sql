CREATE DATABASE WMS

GO

USE WMS

--01. DDL
CREATE TABLE Clients (
	ClientId INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Phone CHAR(12) NOT NULL
	)

CREATE TABLE Mechanics (
	MechanicId INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	[Address] VARCHAR(255) NOT NULL
	)

CREATE TABLE Models (
	ModelId INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) UNIQUE NOT NULL
	)

CREATE TABLE Jobs (
	JobId INT PRIMARY KEY IDENTITY,
	ModelId INT FOREIGN KEY REFERENCES Models(ModelId) NOT NULL, 
	[Status] VARCHAR(11) CHECK([Status] IN ('Pending', 'In Progress', 'Finished')) DEFAULT 'Pending' NOT NULL,
	ClientId INT FOREIGN KEY REFERENCES Clients(ClientId) NOT NULL,
	MechanicId INT FOREIGN KEY REFERENCES Mechanics(MechanicId),
	IssueDate DATE NOT NULL,
	FinishDate DATE
	)

CREATE TABLE Orders (
	OrderId INT PRIMARY KEY IDENTITY,
	JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL,
	IssueDate DATE,
	Delivered BIT NOT NULL DEFAULT 0
	)

CREATE TABLE Vendors (
	VendorId INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) UNIQUE NOT NULL
	)

CREATE TABLE Parts (
	PartId INT PRIMARY KEY IDENTITY,
	SerialNumber VARCHAR(50) UNIQUE NOT NULL,
	[Description] VARCHAR(255),
	Price MONEY CHECK(Price >= 0 AND Price <= 9999.99) NOT NULL,
	VendorId INT FOREIGN KEY REFERENCES Vendors(VendorId) NOT NULL,
	StockQty INT CHECK(StockQty >= 0) DEFAULT 0 NOT NULL
	)

CREATE TABLE OrderParts (
	OrderId INT FOREIGN KEY REFERENCES Orders(OrderId),
	PartId INT FOREIGN KEY REFERENCES Parts(PartId) NOT NULL,
	Quantity INT CHECK(Quantity >= 1) DEFAULT 1 NOT NULL,
	PRIMARY KEY(OrderId, PartId)
	)

CREATE TABLE PartsNeeded(
	JobId INT FOREIGN KEY REFERENCES Jobs(JobId),
	PartId INT FOREIGN KEY REFERENCES Parts(PartId),
	PRIMARY KEY (JobId, PartId),
	Quantity INT CHECK(Quantity >= 1) DEFAULT 1 NOT NULL,
	)

-- 02. Insert
INSERT INTO Clients (FirstName, LastName, Phone)
VALUES 
	('Teri', 'Ennaco', '570-889-5187'),
	('Merlyn', 'Lawler', '201-588-7810'),
	('Georgene', 'Montezuma', '925-615-5185'),
	('Jettie', 'Mconnell', '908-802-3564'),
	('Lemuel', 'Latzke', '631-748-6479'),
	('Melodie', 'Knipp', '805-690-1682'),
	('Candida', 'Corbley', '908-275-8357')

INSERT INTO Parts (SerialNumber, [Description], Price, VendorId)
VALUES 
	('WP8182119', 'Door Boot Seal', 117.86, 2),
	('W10780048', 'Suspension Rod', 42.81, 1),
	('W10841140', 'Silicone Adhesive', 6.77, 4),
	('WPY055980', 'High Temperature Adhesive', 13.94, 3)

--03. Update
UPDATE Jobs
SET MechanicId = 3, [Status] = 'In Progress'
WHERE [Status] = 'Pending'

--04. Delete
DELETE OrderParts
WHERE OrderId = 19

DELETE Orders
WHERE OrderId = 19

--05. Mechanic Assignments
SELECT
	CONCAT(m.FirstName, ' ', m.LastName) AS Mechanic,
	j.[Status],
	j.IssueDate
FROM Mechanics AS m
JOIN Jobs AS j
ON m.MechanicId = j.MechanicId
ORDER BY m.MechanicId, j.IssueDate, j.JobId

--06. Current Clients
SELECT 
	CONCAT(c.FirstName, ' ', c.LastName) AS Client,
	DATEDIFF(DAY, j.IssueDate, '04-24-2017') AS [Days going],
	j.[Status]
FROM Clients AS c
JOIN Jobs AS j
ON c.ClientId = j.ClientId
WHERE j.Status IN ('In Progress', 'Pending')
ORDER BY [Days going] DESC, c.ClientId

--07. Mechanic Performance

SELECT 
	CONCAT(m.FirstName, ' ', m.LastName),
	g.[Average Days]
FROM (
	SELECT j.MechanicId, 
		AVG(DATEDIFF(DAY, j.IssueDate, j.FinishDate)) AS [Average Days]
	FROM Jobs AS j
	WHERE [Status] = 'Finished'
	GROUP BY j.MechanicId
) AS g
JOIN Mechanics as m
ON g.MechanicId = m.MechanicId
ORDER BY m.MechanicId

--08. Available Mechanics

SELECT 
	CONCAT(FirstName, ' ', LastName) AS Available
FROM Mechanics
WHERE MechanicId NOT IN (
		SELECT MechanicId FROM Jobs
		WHERE [Status] <> 'Finished' AND MechanicId IS NOT NULL
		GROUP BY MechanicId
		)
ORDER BY MechanicId

--09. Past Expenses
SELECT 
	j.JobId, 
	ISNULL(SUM(p.Price * op.Quantity), 0) AS Total
FROM Jobs AS j 
LEFT JOIN Orders AS o
ON o.JobId = j.JobId
LEFT JOIN OrderParts AS op
ON op.OrderId = o.OrderId
LEFT JOIN Parts AS p
ON p.PartId = op.PartId
WHERE j.Status = 'Finished'
GROUP BY j.JobId
ORDER BY Total DESC, JobId

--10. Missing Parts
SELECT 
	p.PartId,
	p.[Description],
	SUM(pn.Quantity) AS [Required],
	SUM(p.StockQty) AS [In Stock],
	ISNULL(SUM(g.Quantity), 0) AS Ordered
FROM Parts AS p
LEFT JOIN PartsNeeded AS pn 
ON pn.PartId = p.PartId
LEFT JOIN Jobs AS j 
ON j.JobId = pn.JobId
LEFT JOIN (
		SELECT 
			op.PartId,
			op.Quantity
		FROM Orders AS o
		JOIN OrderParts AS op ON op.OrderId = o.OrderId
		WHERE o.Delivered = 0
		) AS g ON g.PartId = p.PartId
WHERE j.Status <> 'Finished'
GROUP BY p.PartId, p.[Description]
HAVING SUM(pn.Quantity) > SUM(p.StockQty) + ISNULL(SUM(g.Quantity), 0)
ORDER BY p.PartId
