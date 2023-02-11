USE SoftUni
-- 01. Employees with Salary Above 35000
GO 

CREATE PROC usp_GetEmployeesSalaryAbove35000
AS
SELECT FirstName, LastName FROM Employees
WHERE Salary > 35000

EXEC usp_GetEmployeesSalaryAbove35000

GO

--02. Employees with Salary Above Number
CREATE OR ALTER PROC usp_GetEmployeesSalaryAboveNumber (@salaryAbove DECIMAL(18,4))
AS
SELECT FirstName, LastName FROM Employees
WHERE Salary >= @salaryAbove

EXEC usp_GetEmployeesSalaryAboveNumber 55000

GO

--03. Town Names Starting With

CREATE OR ALTER PROCEDURE usp_GetTownsStartingWith ( @string VARCHAR(10) )
AS
SELECT [Name] FROM Towns
WHERE [Name] LIKE @string+'%'

EXEC usp_GetTownsStartingWith cal

GO

--04. Employees from Town
CREATE OR ALTER PROC usp_GetEmployeesFromTown (@townName VARCHAR(20))
AS
SELECT e.FirstName, e.LastName FROM Employees AS e
JOIN Addresses AS a
ON e.AddressID = a.AddressID
JOIN Towns AS t
ON a.TownID = t.TownID
WHERE t.[Name] = @townName 

EXEC usp_GetEmployeesFromTown Sofia

GO
--05. Salary Level Function

CREATE OR ALTER FUNCTION ufn_GetSalaryLevel(@salary DECIMAL(18,4))
RETURNS VARCHAR(20)
AS
BEGIN
	DECLARE @result VARCHAR(10)
	IF (@salary < 30000)
	BEGIN
		SET @result = 'Low'
	END
	ELSE IF (@salary <= 50000)
	BEGIN
		SET @result = 'Average'
	END
	ELSE
		SET @result = 'High'
	RETURN @result
END

GO

SELECT *, dbo.ufn_GetSalaryLevel(Salary) AS SalaryLevel FROM Employees

GO

--06. Employees by Salary Level

CREATE OR ALTER PROC usp_EmployeesBySalaryLevel (@salaryLevel VARCHAR(20))
AS 
SELECT FirstName, LastName FROM Employees
WHERE dbo.ufn_GetSalaryLevel(Salary) = @salaryLevel

EXEC usp_EmployeesBySalaryLevel 'Low'

GO

--07. Define Function
CREATE OR ALTER FUNCTION ufn_IsWordComprised(@setOfLetters NVARCHAR(MAX), @word NVARCHAR(MAX))
RETURNS BIT
AS
BEGIN
	DECLARE @wordLength INT = LEN(@word)
	DECLARE @index INT = 1
	WHILE (@index <= @wordLength)
		BEGIN
			IF (CHARINDEX(SUBSTRING(@word, @index, 1), @setOfLetters) = 0)
				BEGIN
					RETURN 0
				END
			SET @index += 1
		END
	RETURN 1
END

GO

--08. *Delete Employees and Departments
CREATE OR ALTER PROC usp_DeleteEmployeesFromDepartment (@departmentId INT)
AS
BEGIN
	DELETE FROM EmployeesProjects
	WHERE EmployeeID IN (SELECT EmployeeID FROM Employees WHERE DepartmentID = @departmentId)

	UPDATE Employees 
	SET ManagerID = NULL
	WHERE ManagerID IN (SELECT e.EmployeeID  FROM Employees AS e WHERE e.DepartmentID = @departmentId)

	ALTER TABLE Departments
	ALTER COLUMN ManagerId INT

	UPDATE Departments
	SET ManagerID = NULL
	WHERE ManagerID IN (SELECT e.EmployeeID FROM Employees AS e WHERE DepartmentID = @departmentId)

	DELETE FROM Employees
	WHERE DepartmentID = @departmentId

	DELETE FROM Departments 
	WHERE DepartmentID = @departmentId

	SELECT COUNT(EmployeeID) FROM Employees
	WHERE DepartmentID = @departmentId
END

--09. Find Full Name
USE Bank

GO

CREATE OR ALTER PROC usp_GetHoldersFullName 
AS
SELECT CONCAT(FirstName, ' ', LastName) AS [Full Name] FROM AccountHolders

GO

--10. People with Balance Higher Than

CREATE OR ALTER PROC usp_GetHoldersWithBalanceHigherThan (@money DECIMAL(16,2))
AS
SELECT ah.FirstName AS [First Name], ah.LastName AS [Last Name] FROM (
	SELECT AccountHolderId, SUM(Balance) AS Total FROM Accounts
	GROUP BY AccountHolderId) AS t
JOIN AccountHolders as ah
ON t.AccountHolderId = ah.Id
WHERE t.Total > @money
ORDER BY ah.FirstName, ah.LastName

EXEC usp_GetHoldersWithBalanceHigherThan 20000

GO

--11. Future Value Function
CREATE OR ALTER FUNCTION ufn_CalculateFutureValue (
	@sum DECIMAL(18,4), 
	@yearlyInterestRate FLOAT,
	@numberOfYears INT)
RETURNS DECIMAL(18,4)
AS 
BEGIN
	DECLARE @result DECIMAL(18,4)
		SELECT @result = @sum * POWER((1 + @yearlyInterestRate), @numberOfYears)
	RETURN @result
END

GO

SELECT dbo.ufn_CalculateFutureValue(1000, 0.1, 5)

GO

--12. Calculating Interest

CREATE OR ALTER PROC usp_CalculateFutureValueForAccount (@accountId INT, @interestRate FLOAT)
AS
	SELECT 
		a.Id AS [Account Id],
		ah.FirstName AS [First Name],
		ah.LastName AS [Last Name],
		a.Balance AS [Current Balance],
		dbo.ufn_CalculateFutureValue(a.Balance,  0.1, 5)
		FROM Accounts AS a
	JOIN AccountHolders AS ah
	ON a.AccountHolderId = ah.Id
	WHERE a.Id = 1

GO

EXEC usp_CalculateFutureValueForAccount 1, 0.1

GO

--13. *Cash in User Games Odd Rows

USE Diablo

GO

CREATE OR ALTER FUNCTION ufn_CashInUsersGames(@gameName VARCHAR(50))
RETURNS TABLE
AS
RETURN(
	SELECT SUM(Cash) AS SumCash
	FROM
		(
		SELECT Cash, ROW_NUMBER() OVER (ORDER BY Cash DESC) AS RowNumber
		FROM UsersGames as ug
		JOIN Games AS g
		ON ug.GameId = g.Id
		WHERE g.Name = @gameName
		) AS t
	WHERE RowNumber % 2 = 1
	)

GO

SELECT * FROM ufn_CashInUsersGames('Love in a mist')
