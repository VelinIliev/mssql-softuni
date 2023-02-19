CREATE DATABASE Boardgames

GO

USE Boardgames

GO
--01 DDL

CREATE TABLE Categories (
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL
	)

CREATE TABLE Addresses (
	Id INT PRIMARY KEY IDENTITY,
	StreetName VARCHAR(100) NOT NULL,
	StreetNumber INT NOT NULL,
	Town VARCHAR(30) NOT NULL,
	Country VARCHAR(50) NOT NULL,
	ZIP INT NOT NULL
	)

CREATE TABLE Publishers (
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) UNIQUE NOT NULL,
	AddressId INT FOREIGN KEY REFERENCES Addresses(Id) NOT NULL,
	Website VARCHAR(40),
	Phone VARCHAR(20)
	)

CREATE TABLE PlayersRanges (
	Id INT PRIMARY KEY IDENTITY,
	PlayersMin INT NOT NULL,
	PlayersMax INT NOT NULL
	)

CREATE TABLE Boardgames (
	Id INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(30) NOT NULL,
	YearPublished INT NOT NULL,
	Rating DECIMAL(5,2) NOT NULL,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	PublisherId INT FOREIGN KEY REFERENCES Publishers(Id) NOT NULL,
	PlayersRangeId INT FOREIGN KEY REFERENCES PlayersRanges(Id) NOT NULL
	)

CREATE TABLE Creators (
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(30) NOT NULL,
	LastName VARCHAR(30) NOT NULL,
	Email VARCHAR(30) NOT NULL
	)

CREATE TABLE CreatorsBoardgames (
	CreatorId INT FOREIGN KEY REFERENCES Creators(Id) NOT NULL,
	BoardgameId INT FOREIGN KEY REFERENCES Boardgames(Id) NOT NULL,
	PRIMARY KEY (CreatorId, BoardgameId)
	)

--02. Insert

INSERT INTO Boardgames([Name], YearPublished, Rating, CategoryId, PublisherId, PlayersRangeId)
VALUES
	('Deep Blue', 2019, 5.67, 1, 15, 7),
	('Paris', 2016, 9.78, 7, 1, 5),
	('Catan: Starfarers', 2021, 9.87, 7, 13, 6),
	('Bleeding Kansas', 2020, 3.25, 3, 7, 4),
	('One Small Step', 2019, 5.75, 5, 9, 2)

INSERT INTO Publishers ([Name], AddressId, Website, Phone)
VALUES
	('Agman Games', 5, 'www.agmangames.com', '+16546135542'),
	('Amethyst Games', 7, 'www.amethystgames.com', '+15558889992'),
	('BattleBooks', 13, 'www.battlebooks.com', '+12345678907')


--03. Update
UPDATE PlayersRanges
SET PlayersMax = PlayersMax + 1
WHERE PlayersMin = 2 AND PlayersMax = 2

UPDATE Boardgames
SET [Name] = CONCAT([Name], 'V2')
WHERE YearPublished >= 2020


--04. Delete
DELETE CreatorsBoardgames 
WHERE BoardgameId IN (1,16,31,47)

DELETE Boardgames
WHERE PublisherId IN (1, 16)

DELETE Publishers
WHERE AddressId = 5

DELETE Addresses
WHERE Town LIKE 'L%'

--05. Boardgames by Year of Publication

SELECT [Name], Rating FROM Boardgames
ORDER BY YearPublished, [Name] DESC

--06. Boardgames by Category
SELECT bg.Id, bg.[Name], bg.YearPublished, c.[Name] FROM Boardgames AS bg
JOIN Categories AS c
ON bg.CategoryId = c.Id
WHERE c.[Name] IN ('Strategy Games', 'Wargames')
ORDER BY bg.YearPublished DESC

--07. Creators without Boardgames
SELECT c.Id, CONCAT(c.FirstName, ' ', c.LastName) AS CreatorName, c.Email FROM Creators AS c
LEFT JOIN CreatorsBoardgames AS cb
ON cb.CreatorId = c.Id
WHERE CreatorId IS NULL

--08. First 5 Boardgames
SELECT TOP(5) bg.[Name], bg.Rating, c.[Name] FROM Boardgames AS bg
JOIN PlayersRanges AS pr
ON bg.PlayersRangeId = pr.Id
JOIN Categories AS c
ON bg.CategoryId = c.Id
WHERE (bg.Rating > 7 AND bg.[Name] LIKE '%a%') 
		OR (bg.Rating > 7.5 AND pr.PlayersMin = 2 AND pr.PlayersMax = 5)
ORDER BY bg.[Name], bg.Rating DESC

--09. Creators with Emails
SELECT CONCAT(r.FirstName, ' ', r.LastName) AS FullName, r.Email, r.Rating FROM (
SELECT c.FirstName, c.LastName, c.Email, 
	DENSE_RANK() OVER (
	PARTITION BY c.ID
	ORDER BY b.Rating DESC
	) AS Ranked,
	b.Rating
	FROM CreatorsBoardgames AS bg
	JOIN Creators AS c
	ON bg.CreatorId = c.Id
	JOIN Boardgames AS b
	ON bg.BoardgameId = b.Id
	WHERE c.Email LIKE '%.com'
	) AS r
WHERE r.Ranked = 1
ORDER BY r.FirstName, r.LastName

--GROUP BY c.Id, c.[FirstName], c.LastName, b.[Name], b.Rating
--
ORDER BY r.FirstName, b.Rating DESC

--10. Creators by Rating

SELECT c.LastName, CEILING(AVG(bg.Rating)), p.[Name] AS PublisherName FROM CreatorsBoardgames AS cb
JOIN Creators AS c
ON cb.CreatorId = c.Id
JOIN Boardgames AS bg 
ON cb.BoardgameId = bg.Id
JOIN Publishers AS p
ON bg.PublisherId = p.Id
WHERE p.[Name] = 'Stonemaier Games'
GROUP BY c.LastName, p.[Name]
ORDER BY AVG(bg.Rating) DESC

GO
--11. Creator with Boardgames
CREATE OR ALTER FUNCTION udf_CreatorWithBoardgames(@name VARCHAR(30))
RETURNS INT
AS 
BEGIN
	RETURN(
		SELECT COUNT(*) FROM CreatorsBoardgames AS cb
		JOIN Creators AS c
		ON cb.CreatorId = c.Id
		WHERE c.FirstName = @name
		)
END

GO

SELECT dbo.udf_CreatorWithBoardgames('Bruno')

--12. Search for Boardgame with Specific Category

GO 

CREATE OR ALTER PROC usp_SearchByCategory(@category VARCHAR(50))
AS
	SELECT 
		bg.[Name], 
		bg.YearPublished, 
		bg.Rating, 
		c.[Name] AS CategoryName,
		p.[Name] AS PublisherName,
		CONCAT(pr.PlayersMin, ' people') AS MinPlayers, 
		CONCAT(pr.PlayersMax, ' people') AS MaxPlayers
	FROM Boardgames AS bg
	JOIN Categories AS c
	ON bg.CategoryId = c.id
	JOIN Publishers AS p
	ON bg.PublisherId = p.Id
	JOIN PlayersRanges AS pr
	ON bg.PlayersRangeId = pr.id
	WHERE c.[Name] = @category
	ORDER BY p.[Name], bg.YearPublished DESC

EXEC usp_SearchByCategory 'Wargames'