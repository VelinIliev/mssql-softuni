USE Bank

--01. Create Table Logs
CREATE TABLE Logs(
	LogId INT IDENTITY,
	AccountId INT FOREIGN KEY REFERENCES Accounts(Id),
	OldSum DECIMAL(18,4),
	NewSum DECIMAL(18,4)
)

GO

CREATE TRIGGER tr_AddToLog
ON Accounts FOR UPDATE
AS
INSERT INTO Logs
		VALUES
	(
	(SELECT Id FROM inserted),
	(SELECT Balance FROM deleted),
	(SELECT Balance FROM inserted)
	)

GO
--02. Create Table Emails
CREATE TABLE NotificationEmails(
	Id INT IDENTITY,
	Recipient INT,
	[Subject] VARCHAR(250),
	Body VARCHAR(250)
)

GO

CREATE TRIGGER tr_NotificationEmail
ON Logs FOR INSERT
AS
INSERT INTO NotificationEmails
		VALUES
	(
		(SELECT AccountId FROM inserted),
		(SELECT 'Balance change for account: ' + CAST(AccountId AS VARCHAR(250)) FROM inserted),
		(SELECT 'On '
					+ FORMAT(GETDATE(), 'MM dd yyyy h:mmtt')
					+ ' your balance was changed from ' +
					CAST(OldSum AS VARCHAR(250)) + ' to '
					+ CAST(NewSum AS VARCHAR(250)) + '.'
							FROM inserted)
	)

GO

--03. Deposit Money
CREATE OR ALTER PROC usp_DepositMoney (@AccountId INT, @MoneyAmount DECIMAL(18,4))
AS
BEGIN
	IF (@MoneyAmount < 0) THROW 50001, 'Invalid amount. The sum must be a positive digit', 1 
	UPDATE Accounts
	SET Balance += @MoneyAmount
	WHERE Id = @AccountId
END

EXEC usp_DepositMoney 1, 100
EXEC usp_DepositMoney 1, -1000

GO
--04. Withdraw Money Procedure
CREATE OR ALTER PROC usp_WithdrawMoney (@AccountId INT, @MoneyAmount DECIMAL(18,4))
AS
BEGIN
	IF (@MoneyAmount < 0) THROW 50001, 'Invalid amount. The sum must be a positive digit', 1 
	UPDATE Accounts
	SET Balance -= @MoneyAmount
	WHERE Id = @AccountId
END

EXEC usp_WithdrawMoney 5, 100
EXEC usp_WithdrawMoney 5, -10

GO
--05. Money Transfer
CREATE OR ALTER PROC usp_TransferMoney(@SenderId INT, @ReceiverId INT, @Amount DECIMAL(18,2))
AS
BEGIN
	BEGIN TRANSACTION
		BEGIN TRY 
			EXEC usp_DepositMoney @ReceiverId, @Amount
			EXEC usp_WithdrawMoney @SenderId, @Amount
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
		END CATCH
	COMMIT TRANSACTION
END

EXEC usp_TransferMoney 1, 1, 5000

GO

USE Diablo

GO
--06. *Massive Shopping


--07. Employees with Three Projects
USE SoftUni

GO 

CREATE OR ALTER PROC usp_AssignProject(@EmloyeeId INT , @ProjectID INT)
AS
BEGIN TRANSACTION
	DECLARE @ProjectsCount INT = (
		SELECT 
			COUNT(ep.ProjectID)
		FROM EmployeesProjects AS ep
		WHERE ep.EmployeeID = @EmloyeeId
	)
IF (@ProjectsCount >= 3)
BEGIN
	RAISERROR('The employee has too many projects!', 16, 1)
	ROLLBACK
END

INSERT INTO EmployeesProjects
		VALUES
	(@EmloyeeId, @ProjectID)

COMMIT

--09. Delete Employees
CREATE TABLE Deleted_Employees(
	EmployeeId INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(50),
	LastName VARCHAR(50), 
	MiddleName VARCHAR(50), 
	JobTitle VARCHAR(50), 
	DepartmentId INT, 
	Salary DECIMAL(18,2)
)

GO

CREATE TRIGGER tr_DeletedEmployee ON Employees AFTER DELETE
AS
INSERT INTO Deleted_Employees(FirstName, LastName, MiddleName, JobTitle,DepartmentId, Salary)
SELECT 
		d.FirstName, d.LastName, d.MiddleName, d.JobTitle, d.DepartmentID, d.Salary
	FROM deleted AS d
