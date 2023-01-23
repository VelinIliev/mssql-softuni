USE SoftUni

-- 01. Find Names of All Employees by First Name

SELECT FirstName, LastName FROM Employees
WHERE FirstName LIKE 'Sa%'

-- 02. Find Names of All Employees by Last Name

SELECT FirstName, LastName FROM Employees
WHERE LastName LIKE '%ei%'

--03. Find First Names of All Employees

SELECT FirstName FROM Employees
WHERE (DepartmentID = 3 OR DepartmentID = 10) 
AND (YEAR(HireDate) >= 1995 AND YEAR(HireDate) <= 2005)


--04. Find All Employees Except Engineers

SELECT FirstName, LastName FROM Employees
WHERE JobTitle NOT LIKE '%engineer%'


--05. Find Towns with Name Length

SELECT [Name] FROM Towns
WHERE LEN([Name]) IN (5,6)
ORDER BY [Name]

--06. Find Towns Starting With

SELECT TownId, [Name] FROM Towns
WHERE LEFT([Name], 1) IN ('M', 'K', 'B', 'E')
ORDER BY [Name]

--07. Find Towns Not Starting With
	
SELECT TownId, [Name] FROM Towns
WHERE LEFT([Name], 1) != 'R' 
	AND LEFT([Name], 1) != 'B' 
	AND LEFT([Name], 1) != 'D'
ORDER BY [Name]

--08. Create View Employees Hired After 2000 Year
GO

CREATE VIEW V_EmployeesHiredAfter2000 AS
SELECT FirstName, LastName FROM Employees
WHERE YEAR(HireDate)> 2000

GO

--09. Length of Last Name

SELECT FirstName, LastName FROM Employees
WHERE LEN(LastName) = 5

--10. Rank Employees by Salary

SELECT EmployeeID, FirstName, LastName, Salary, DENSE_RANK() OVER (
	PARTITION BY Salary
	ORDER BY EmployeeID
	) AS [Rank]
FROM Employees
WHERE Salary >= 10000 AND Salary <= 50000
ORDER BY Salary DESC

--11. Find All Employees with Rank 2
SELECT * FROM (
	SELECT EmployeeID, FirstName, LastName, Salary, DENSE_RANK() OVER (
		PARTITION BY Salary
		ORDER BY EmployeeID
		) AS [Rank]
	FROM Employees
	WHERE Salary >= 10000 AND Salary <= 50000
	) AS v
WHERE [Rank] = 2
ORDER BY Salary DESC

USE Geography

--12. Countries Holding 'A' 3 or More Times
--Method 1
SELECT CountryName, IsoCode FROM Countries
WHERE LEN(CountryName) - LEN(REPLACE(LOWER(CountryName), 'a', '')) >= 3
ORDER BY IsoCode
--Method 2
SELECT CountryName, IsoCode FROM Countries
WHERE LOWER(CountryName) LIKE '%a%a%a%'
ORDER BY IsoCode

--13. Mix of Peak and River Names

SELECT PeakName, RiverName, 
	LOWER(CONCAT(SUBSTRING(PeakName, 1, LEN(PeakName) - 1), RiverName)) AS Mix 
	FROM Peaks, Rivers
WHERE RIGHT(LOWER(PeakName), 1) = LEFT(LOWER(RiverName), 1) 
ORDER BY Mix

--14. Games From 2011 and 2012 Year
USE Diablo

SELECT TOP(50) [Name], 
	FORMAT([Start], 'yyyy-MM-dd', 'bg-BG' ) AS [Start] 
	FROM Games
WHERE YEAR([Start]) = 2012 OR YEAR([Start]) = 2011
ORDER BY [Start], [Name]

--15. User Email Providers
SELECT Username,
	SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email)) AS [Email Provider]
	FROM Users
ORDER BY [Email Provider], Username

--16. Get Users with IP Address Like Pattern
SELECT Username, IpAddress FROM Users
WHERE IpAddress LIKE '___.1%.%.___'
ORDER BY Username

--17. Show All Games with Duration & Part of the Day
SELECT [Name], 
	CASE 
		WHEN DATEPART(HOUR, [Start]) >= 0 AND DATEPART(HOUR, [Start]) < 12 THEN 'Morning'
		WHEN DATEPART(HOUR, [Start])  >= 12 AND DATEPART(HOUR, [Start])  < 18 THEN 'Afternoon'
		WHEN DATEPART(HOUR, [Start])  >= 18 AND DATEPART(HOUR, [Start])  < 24 THEN 'Evening'
	END AS [Part of the Day],
	CASE 
		WHEN Duration <= 3 THEN 'Extra Short'
		WHEN Duration >=4 AND Duration <= 6 THEN 'Short'
		WHEN Duration >= 6 THEN 'Long'
		WHEN Duration IS NULL THEN 'Extra Long'
	END AS Duration
	FROM Games
	AS g
ORDER BY [Name], Duration, [Part of the Day]

--18. Orders Table
USE Orders

SELECT ProductName, OrderDate,  
	DATEADD(DAY, 3, OrderDate), 
	DATEADD(MONTH, 1, OrderDate) 
FROM Orders

--19. People Table
CREATE TABLE People (
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(20) NOT NULL,
	Birthdate DATETIME2 NOT NULL,
	)

INSERT INTO People([Name], Birthdate)
VALUES 
	('Victor', '2000-12-07 00:00:00.000'),
	('Steven', '1992-09-10 00:00:00.000'),
	('Stephen', '1910-09-19 00:00:00.000'),
	('John', '2010-01-06 00:00:00.000')

SELECT *, 
	DATEDIFF(YEAR, Birthdate, GETDATE()) AS [Age in Years],
	DATEDIFF(MONTH, Birthdate, GETDATE()) AS [Age in Months],
	DATEDIFF(DAY, Birthdate, GETDATE()) AS [Age in Days],
	DATEDIFF(MINUTE, Birthdate, GETDATE()) AS [Age in Minutes]
	FROM People