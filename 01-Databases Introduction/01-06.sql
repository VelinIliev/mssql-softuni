CREATE DATABASE Minions

USE [Minions]

-- first task
CREATE TABLE Minions (
	Id INT PRIMARY KEY,
	[Name] VARCHAR(50),
	Age INT
	);

-- second task

CREATE TABLE Towns (
	Id INT PRIMARY KEY,
	[Name] VARCHAR(50),
	);

--ALTER TABLE Minions
--ADD CONSTRAINT PK_id PRIMARY KEY (Id);

--ALTER TABLE Towns
--ADD CONSTRAINT PK_id PRIMARY KEY (Id);

-- third task

ALTER TABLE [Minions]
	ADD [TownId] INT FOREIGN KEY REFERENCES Towns(Id)

-- 4 task
INSERT INTO Towns (Id, [Name])
VALUES 
	(1, 'Sofia'),
	(2, 'Plovdiv'),
	(3, 'Varna')

INSERT INTO Minions (Id, [Name], Age, TownId)
VALUES
	(1, 'Kevin', 22, 1),
	(2, 'Bob', 15, 3),
	(3, 'Steward', NULL, 2)

SELECT * FROM Minions

-- 5 task
TRUNCATE TABLE [Minions]
SELECT * FROM Minions

-- 6 task
DROP TABLE Minions
DROP TABLE [dbo].[Towns]