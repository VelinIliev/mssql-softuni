--01. Employee Address
USE SoftUni

SELECT TOP(5) e.EmployeeID, e.JobTitle, e.AddressID, a.AddressText FROM Employees AS e
LEFT JOIN Addresses as a
ON e.AddressID = a.AddressID
ORDER BY e.AddressID 

--02. Addresses with Towns
SELECT TOP(50) e.FirstName, e.LastName, t.[Name], a.AddressText FROM Employees AS e
LEFT JOIN Addresses AS a
ON e.AddressID = a.AddressID
LEFT JOIN Towns AS t
ON a.TownID = t.TownID
ORDER BY FirstName, LastName

--03. Sales Employees
SELECT e.EmployeeID, e.FirstName, e.LastName, d.[Name] FROM Employees AS e
LEFT JOIN Departments as d
ON e.DepartmentID = d.DepartmentID
WHERE d.[Name] = 'Sales'
ORDER BY e.EmployeeID

--04. Employee Departments
SELECT TOP(5) e.EmployeeID, e.FirstName, e.Salary, d.[Name] FROM Employees AS e
LEFT JOIN Departments AS d
ON e.DepartmentID = d.DepartmentID
WHERE Salary > 15000
ORDER BY e.DepartmentID

--05. Employees Without Projects
SELECT * FROM EmployeesProjects AS ep
RIGHT JOIN  Employees AS e
ON ep.EmployeeID = e.EmployeeID

SELECT TOP(3) e.EmployeeID, e.FirstName FROM Employees AS e
LEFT JOIN EmployeesProjects AS ep
ON e.EmployeeID = ep.EmployeeID
WHERE ep.ProjectID IS NULL
ORDER BY e.EmployeeID

--06. Employees Hired After
SELECT e.FirstName, e.LastName, e.HireDate, d.[Name] FROM Employees AS e
LEFT JOIN Departments AS d
ON e.DepartmentID = d.DepartmentID
WHERE YEAR(e.HireDate) > 1998 AND (d.[Name] = 'Sales' OR d.[Name] = 'Finance')
ORDER BY e.HireDate

--07. Employees With Project
SELECT TOP(5) e.EmployeeID, e.FirstName, p.[Name] FROM Employees AS e
JOIN EmployeesProjects AS ep
ON e.EmployeeID = ep.EmployeeID
JOIN Projects AS p
ON ep.ProjectID = p.ProjectID
WHERE p.StartDate > '08-13-2002' AND p.EndDate IS NULL
ORDER BY e.EmployeeID

--08. Employee 24
SELECT e.EmployeeID, e.FirstName,
	CASE 
		WHEN YEAR(p.StartDate) >= 2005 THEN NULL
		ELSE p.[Name]
	END
FROM Employees AS e
LEFT JOIN EmployeesProjects AS ep
ON e.EmployeeID = ep.EmployeeID
LEFT JOIN Projects as p
ON ep.ProjectID = p.ProjectID
WHERE e.EmployeeID = 24 
 
 --09. Employee Manager
 SELECT e.EmployeeID, e.FirstName, e.ManagerID, m.FirstName AS ManagerName FROM Employees as e
 JOIN Employees AS m
 ON m.EmployeeID = e.ManagerID
 WHERE e.ManagerID IN (3, 7)
 ORDER BY e.EmployeeID

 --10. Employees Summary
 SELECT TOP(50) e.EmployeeID, 
		CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
		CONCAT(m.FirstName, ' ', m.LastName) AS ManagerName,
		d.[Name]
		FROM Employees AS e
JOIN Employees AS m
ON m.EmployeeID = e.ManagerID
JOIN Departments AS d
ON e.DepartmentID = d.DepartmentID
ORDER BY e.EmployeeID

--11. Min Average Salary
SELECT 
	MIN(a.AverageSalary) AS MinAverageSalaray
	FROM
	(
	SELECT	e.DepartmentID,
			AVG(e.Salary) AS AverageSalary 
	FROM Employees AS e
	GROUP BY e.DepartmentID
	) AS a

--12. Highest Peaks in Bulgaria
USE Geography

SELECT mc.CountryCode, m.MountainRange, p.PeakName, p.Elevation FROM Peaks as p
JOIN MountainsCountries as mc
ON p.MountainId = mc.MountainId
JOIN Mountains as m
ON p.MountainId = m.Id
WHERE mc.CountryCode = 'BG' AND p.Elevation > 2835
ORDER BY Elevation DESC

--13. Count Mountain Ranges
SELECT mc.CountryCode, 
		COUNT(mc.CountryCode) AS MountainRanges 
		FROM MountainsCountries AS mc
WHERE mc.CountryCode IN (
							SELECT CountryCode FROM Countries 
							WHERE CountryName IN ('Bulgaria', 'Russia', 'United States')
							)
GROUP BY mc.CountryCode

--14. Countries With or Without Rivers
SELECT TOP(5) c.CountryName, r.RiverName FROM Countries AS c 
LEFT JOIN CountriesRivers as cr
ON c.CountryCode = cr.CountryCode
LEFT JOIN Rivers as r
ON cr.RiverId = r.Id
WHERE c.ContinentCode = 'AF'
ORDER BY c.CountryName

--15. Continents and Currencies
--Create a query that selects:
	--ContinentCode
	--CurrencyCode
	--CurrencyUsage
--Find all continents and their most used currency. 
--Filter any currency, which is used in only one country. Sort your results by ContinentCode.
SELECT
	r.ContinentCode, 
	r.CurrencyCode, 
	r.CurrencyUsage
FROM
	(
		SELECT 
			c.ContinentCode, 
			c.CurrencyCode, 
			COUNT(*) AS CurrencyUsage,
			DENSE_RANK() OVER (PARTITION BY c.ContinentCode ORDER BY COUNT(*) DESC) AS Ranked
		FROM Countries as c
		GROUP BY c.ContinentCode, c.CurrencyCode
	) AS r
WHERE r.Ranked = 1 AND r.CurrencyUsage != 1
ORDER BY r.ContinentCode, r.CurrencyCode



--16. Countries Without any Mountains
SELECT COUNT(*) AS [Count]  FROM Countries AS c
LEFT JOIN MountainsCountries as m
ON c.CountryCode = m.CountryCode
WHERE m.MountainId IS NULL

--17. Highest Peak and Longest River by Country
SELECT TOP(5)
	c.CountryName, 
	MAX(p.Elevation) AS HighestPeakElevation, 
	MAX(r.Length) AS LongestRiverLength
	FROM Countries AS c
JOIN CountriesRivers AS cr
ON c.CountryCode = cr.CountryCode
JOIN Rivers AS r
ON cr.RiverId = r.Id
JOIN MountainsCountries AS mc
ON c.CountryCode = mc.CountryCode
JOIN Mountains AS m
ON mc.MountainId = m.Id
JOIN Peaks AS p
ON mc.MountainId = p.MountainId
GROUP BY c.CountryName
ORDER BY HighestPeakElevation DESC, LongestRiverLength DESC, c.CountryName

--18 Highest Peak Name and Elevation by Country
SELECT TOP(5)
	cmp.Country,
	ISNULL(cmp.[Highest Peak Name], '(no highest peak)') AS [Highest Peak Name],
	ISNULL(cmp.[Highest Peak Elevation], 0) AS [Highest Peak Elevation],
	ISNULL(cmp.Mountain, '(no mountain)') AS Mountain
FROM
	(	SELECT 
			c.CountryName AS Country, 
			p.PeakName AS [Highest Peak Name], 
			p.Elevation AS [Highest Peak Elevation], 
			m.MountainRange AS Mountain,
			DENSE_RANK() OVER (PARTITION BY c.CountryName ORDER BY p.Elevation DESC) AS Ranked
			FROM Countries as c
			LEFT JOIN MountainsCountries as mc
			ON c.CountryCode = mc.CountryCode
			LEFT JOIN Mountains as m
			ON mc.MountainId = m.Id
			LEFT JOIN Peaks as p 
			ON m.Id = p.MountainId
		) AS cmp
WHERE cmp.Ranked = 1
ORDER BY cmp.Country, cmp.[Highest Peak Name]
