--01. Records' Count
SELECT COUNT(Id) AS Count FROM WizzardDeposits

--02. Longest Magic Wand
SELECT MAX(MagicWandSize) AS LongestMagicWand FROM WizzardDeposits

--03. Longest Magic Wand per Deposit Groups
SELECT DepositGroup, MAX(MagicWandSize) AS LongestMagicWand FROM WizzardDeposits
GROUP BY DepositGroup

--04. Smallest Deposit Group per Magic Wand Size
SELECT TOP(2) DepositGroup FROM WizzardDeposits
GROUP BY DepositGroup
ORDER BY AVG(MagicWandSize)

--05. Deposits Sum
SELECT DepositGroup, SUM(DepositAmount) AS TotalSum FROM WizzardDeposits
GROUP BY DepositGroup

--06. Deposits Sum for Ollivander Family
SELECT DepositGroup, SUM(DepositAmount) AS TotalSum FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
HAVING MagicWandCreator = 'Ollivander family'

--07. Deposits Filter
SELECT * FROM (
	SELECT DepositGroup, SUM(DepositAmount) AS TotalSum FROM WizzardDeposits
	GROUP BY DepositGroup, MagicWandCreator
	HAVING MagicWandCreator = 'Ollivander family'
	) AS g
WHERE g.TotalSum < 150000
ORDER BY TotalSum DESC

--08. Deposit Charge
SELECT DepositGroup, MagicWandCreator, MIN(DepositCharge) AS MinDepositCharge FROM WizzardDeposits
GROUP BY DepositGroup, MagicWandCreator
ORDER BY MagicWandCreator, DepositGroup

--09. Age Groups
SELECT g.AgeGroup, COUNT(*) AS WizardCount FROM (
	SELECT  
		CASE
			WHEN Age > 0 AND Age <= 10 THEN '[0-10]'
			WHEN Age > 10 AND Age <= 20 THEN '[11-20]'
			WHEN Age > 20 AND Age <= 30 THEN '[21-30]'
			WHEN Age > 30 AND Age <= 40 THEN '[31-40]'
			WHEN Age > 40 AND Age <= 50 THEN '[41-50]'
			WHEN Age > 50 AND Age <= 60 THEN '[51-60]'
			ELSE '[61+]'
		END AS AgeGroup
		FROM WizzardDeposits
		) AS g
GROUP BY g.AgeGroup

--10. First Letter
SELECT * FROM (
	SELECT LEFT(FirstName, 1) AS FirstLetter FROM WizzardDeposits
	WHERE DepositGroup  = 'Troll Chest'
	) as l
GROUP BY FirstLetter
ORDER BY FirstLetter

--11. Average Interest
--Mr. Bodrog is highly interested in profitability. He wants to know the average interest of all 
--deposit groups, split by whether the deposit has expired or not. But that's not all. 
--He wants you to select deposits with start date after 01/01/1985. Order the data descending 
--by Deposit Group and ascending by Expiration Flag
SELECT * FROM WizzardDeposits


SELECT DepositGroup, IsDepositExpired, AVG(DepositInterest) AS AverageInterest FROM (
	SELECT DepositGroup, IsDepositExpired, DepositInterest FROM WizzardDeposits
	WHERE DepositStartDate > '01/01/1985') as a
GROUP BY DepositGroup, IsDepositExpired
ORDER BY DepositGroup DESC, IsDepositExpired

--12. *Rich Wizard, Poor Wizard 
SELECT SUM([Difference]) AS SumDifference
	FROM (
		SELECT *, d.[Host Wizard Deposit] - d.[Guest Wizard Deposit] AS [Difference] 
		FROM (
			SELECT 
				h.FirstName AS [Host Wizard], 
				h.DepositAmount AS[Host Wizard Deposit], 
				g.FirstName [Guest Wizard], 
				g.DepositAmount [Guest Wizard Deposit] 
			FROM WizzardDeposits AS h
			JOIN WizzardDeposits AS g
			ON h.Id + 1 = g.id
			) AS d 
	) AS s

--13. Departments Total Salaries
USE SoftUni

SELECT DepartmentID, SUM(Salary) AS TotalSalary FROM Employees
GROUP BY DepartmentID
ORDER BY DepartmentID

--14. Employees Minimum Salaries

SELECT d.DepartmentID, MIN(d.Salary) AS MinimumSalary FROM (
	SELECT * FROM Employees
	WHERE HireDate > '01/01/2000'
	) AS d
GROUP BY d.DepartmentID
HAVING d.DepartmentID IN (2,5,7) 

--15. Employees Average Salaries
SELECT DepartmentID, EmployeeID, ManagerID, Salary
INTO EmployeeWithSalaryOver30000
FROM Employees
WHERE Salary > 30000

DELETE FROM EmployeeWithSalaryOver30000
WHERE ManagerID	 = 42

UPDATE EmployeeWithSalaryOver30000
SET Salary = Salary + 5000
WHERE DepartmentID = 1

SELECT DepartmentID, AVG(Salary) FROM EmployeeWithSalaryOver30000
GROUP BY DepartmentID 

--16. Employees Maximum Salaries
SELECT DepartmentID, MAX(Salary) AS MaxSalary FROM Employees
GROUP BY DepartmentID
HAVING Max(Salary) < 30000 OR MAX(Salary) > 70000

--17. Employees Count Salaries
SELECT COUNT(*) AS Count FROM Employees
WHERE ManagerID IS NULL

--18. *3rd Highest Salary
SELECT r.DepartmentID, AVG(r.Salary) AS ThirdHighestSalary
FROM (
	SELECT 
		DepartmentID, 
		Salary, 
		DENSE_RANK () OVER(PARTITION BY DepartmentId ORDER BY Salary DESC) AS Ranked
	FROM Employees
	) AS r
WHERE r.Ranked = 3
GROUP BY r.DepartmentID

--19. **Salary Challenge
--Fn, Ln, DId
--Select all employees who have salary higher than the average salary of their respective departments. 
--Select only the first 10 rows. Order them by DepartmentID.
SELECT TOP(10) e.FirstName, e.LastName, e.DepartmentID 
FROM Employees as e
JOIN ( 
	SELECT DepartmentID, AVG(Salary) AS AvarageDepartmentsSalary FROM Employees
	GROUP BY DepartmentID
	) AS AverageSalary
ON AverageSalary.DepartmentID = e.DepartmentID
WHERE e.Salary > AverageSalary.AvarageDepartmentsSalary
ORDER BY e.DepartmentID

