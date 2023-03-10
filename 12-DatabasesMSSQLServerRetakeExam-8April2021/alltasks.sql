CREATE DATABASE Service

GO

USE Service

--01. DDL
CREATE TABLE Users (
	Id INT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) UNIQUE NOT NULL,
	[Password] VARCHAR(50) NOT NULL,
	[Name] VARCHAR(50),
	Birthdate DATETIME,
	Age INT CHECK(Age BETWEEN 14 AND 110) NOT NULL,
	Email VARCHAR(50) NOT NULL
	)

CREATE TABLE Departments (
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
	)

CREATE TABLE Employees (
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(25),
	LastName VARCHAR(25),
	Birthdate DATETIME,
	Age INT CHECK(Age BETWEEN 18 AND 110),
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id)
	)

CREATE TABLE Categories (
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL,
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL
	)

CREATE TABLE Status (
	Id INT PRIMARY KEY IDENTITY,
	[Label] VARCHAR(20)
	)

CREATE TABLE Reports (
	Id INT PRIMARY KEY IDENTITY,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	StatusId INT FOREIGN KEY REFERENCES Status(Id) NOT NULL,
	OpenDate DATETIME NOT NULL,
	CloseDate DATETIME,
	[Description] VARCHAR(200) NOT NULL,
	UserId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
	EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
	)

--02. Insert
INSERT INTO Employees (FirstName, LastName, Birthdate, DepartmentId)
VALUES
	('Marlo', 'O''Malley', '1958-9-21', 1),
	('Niki', 'Stanaghan', '1969-11-26', 4),
	('Ayrton', 'Senna', '1960-03-21', 9),
	('Ronnie', 'Peterson', '1944-02-14',9),
	('Giovanna', 'Amati', '1959-07-20', 5)

INSERT INTO Reports (CategoryId, StatusId, OpenDate, CloseDate, [Description], UserId, EmployeeId)
VALUES
	(1, 1, '2017-04-13', NULL, 'Stuck Road on Str.133', 6, 2),
	(6, 3, '2015-09-05', '2015-12-06', 'Charity trail running', 3, 5),
	(14, 2, '2015-09-07', NULL, 'Falling bricks on Str.58', 5, 2),
	(4, 3, '2017-07-03', '2017-07-06', 'Cut off streetlight on Str.11', 1, 1)

--03. Update
UPDATE Reports 
SET CloseDate = GETDATE()
WHERE CloseDate IS NULL

--04. Delete
DELETE Reports
WHERE StatusId = 4

--05. Unassigned Reports
SELECT [Description], FORMAT(OpenDate, 'dd-MM-yyyy') FROM Reports
WHERE EmployeeId IS NULL
ORDER BY OpenDate, Description

--06. Reports & Categories
SELECT r.[Description], c.[Name] AS CategoryName FROM Reports AS r
JOIN Categories AS c
ON r.CategoryId = c.Id
WHERE CategoryId IS NOT NULL

ORDER BY r.[Description], c.[Name]

--07. Most Reported Category
SELECT	TOP(5)
		c.[Name] AS CategoryName,
		COUNT(*) AS ReportsNumber  
FROM Reports AS r
JOIN Categories AS c
ON r.CategoryId = c.Id
GROUP BY c.[Name]
ORDER BY COUNT(*) DESC, c.[Name]

--08. Birthday Report
SELECT u.Username, c.[Name] AS CategoryName FROM Reports AS r
JOIN Users AS u
ON r.UserId = u.Id
JOIN Categories AS c
ON r.CategoryId = c.Id
WHERE DATEPART(DAY, r.OpenDate) = DATEPART(DAY, u.Birthdate)
		AND
		DATEPART(MONTH, r.OpenDate) = DATEPART(MONTH, u.Birthdate)
ORDER BY u.Username, c.[Name]

--09. User per Employee
SELECT CONCAT(e.FirstName, ' ', e.LastName) AS FullName, 
		CASE
			WHEN g.UsersCount IS NULL THEN 0
			ELSE g.UsersCount
		END AS UsersCount
FROM (
	SELECT EmployeeId, COUNT(*) AS UsersCount FROM Reports
	GROUP BY EmployeeId 
	) AS g
RIGHT JOIN Employees AS e
ON g.EmployeeId = e.Id
ORDER BY g.UsersCount DESC, e.FirstName

--10. Full Info
SELECT 
	CASE 
		WHEN e.Id IS NULL THEN 'None'
		ELSE CONCAT(e.FirstName, ' ', e.LastName) 
	END AS Employee,
	ISNULL(d.[Name], 'None') AS Department,
	c.[Name] AS Category,
	r.[Description],
	FORMAT(r.OpenDate, 'dd.MM.yyyy') AS OpenDate,
	s.[Label] AS [Status],
	u.[Name]	
FROM Reports AS r
LEFT JOIN Employees AS e
ON r.EmployeeId = e.Id
LEFT JOIN Departments AS d
ON e.DepartmentId = d.Id
LEFT JOIN Categories AS c
ON r.CategoryId = c.Id
LEFT JOIN Users AS u
ON r.UserId = u.Id
LEFT JOIN Status AS s
ON r.StatusId = s.Id
ORDER BY	e.FirstName DESC, 
			e.LastName DESC, 
			d.[Name], 
			c.[Name], 
			r.[Description],
			r.OpenDate,
			s.[Label],
			u.Username

GO
--11. Hours to Complete
CREATE OR ALTER FUNCTION udf_HoursToComplete(@StartDate DATETIME, @EndDate DATETIME)
RETURNS INT
AS 
BEGIN
	DECLARE @result INT
	IF @StartDate IS NULL OR @EndDate IS NULL
		BEGIN
			SET @result = 0
		END
	ELSE 
		SET @result = DATEDIFF(HOUR, @StartDate, @EndDate)
	RETURN @result
END

GO

SELECT dbo.udf_HoursToComplete(OpenDate, CloseDate) AS TotalHours
   FROM Reports

GO

--12. Assign Employee
CREATE OR ALTER PROC usp_AssignEmployeeToReport(@EmployeeId INT, @ReportId INT)
AS
BEGIN 
	DECLARE @departmentIdEmployee INT = (
			SELECT e.DepartmentId FROM Employees AS e
			WHERE e.Id = @EmployeeId
			)
	DECLARE @departmentIdReport INT = (
			SELECT c.DepartmentId FROM Reports AS r
			JOIN Categories AS c
			ON r.CategoryId = c.Id
			WHERE r.Id = @ReportId
			)
	IF @departmentIdReport = @departmentIdEmployee
		UPDATE Reports
		SET EmployeeId = @EmployeeId
		WHERE Id = @ReportId
	ELSE
	THROW 51000, 'Employee doesn''t belong to the appropriate department!', 1;  
END

GO

EXEC usp_AssignEmployeeToReport 30, 1
EXEC usp_AssignEmployeeToReport 17, 2
