--01. Employee Address
USE SoftUni

SELECT TOP(5) e.EmployeeID, e.JobTitle, e.AddressID, a.AddressText FROM Employees AS e
LEFT JOIN Addresses as a
ON e.AddressID = a.AddressID
ORDER BY AddressID 

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
LEFT JOIN EmployeesProjects AS ep
ON e.EmployeeID = ep.EmployeeID
LEFT JOIN Projects AS p
ON ep.ProjectID = p.ProjectID
WHERE ep.ProjectID IS NOT NULL AND p.StartDate > '08-13-2002'
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
 WHERE e.ManagerID = 3 OR e.ManagerID = 7
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
WHERE mc.CountryCode = 'BG' OR mc.CountryCode = 'RU' or mc.CountryCode = 'US'
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
SELECT * FROM Countries
SELECT * FROM Continents
SELECT * FROM Currencies