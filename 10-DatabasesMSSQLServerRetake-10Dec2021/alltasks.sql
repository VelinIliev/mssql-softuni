CREATE DATABASE Airport

GO

--01. DDL
USE Airport

CREATE TABLE Passengers (
	Id INT PRIMARY KEY IDENTITY,
	FullName VARCHAR(100) UNIQUE NOT NULL,
	Email VARCHAR(50) UNIQUE NOT NULL
	)

CREATE TABLE Pilots (
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(30) UNIQUE NOT NULL,
	LastName VARCHAR(30) UNIQUE NOT NULL,
	Age TINYINT CHECK(Age BETWEEN 21 AND 62) NOT NULL,
	Rating FLOAT CHECK(Rating BETWEEN 0.0 AND 10.0)
	)

CREATE TABLE AircraftTypes (
	Id INT PRIMARY KEY IDENTITY,
	TypeName VARCHAR(30) UNIQUE NOT NULL
	)

CREATE TABLE Aircraft (
	Id INT PRIMARY KEY IDENTITY,
	Manufacturer VARCHAR(25) NOT NULL,
	Model VARCHAR(30) NOT NULL,
	[Year] INT NOT NULL,
	FlightHours INT,
	Condition CHAR(1) NOT NULL,
	TypeId INT FOREIGN KEY REFERENCES AircraftTypes(Id) NOT NULL
	)

CREATE TABLE PilotsAircraft (
	AircraftId INT FOREIGN KEY REFERENCES Aircraft(Id) NOT NULL,
	PilotId INT FOREIGN KEY REFERENCES Pilots(Id) NOT NULL,
	PRIMARY KEY(AircraftId, PilotId) 
	)

CREATE TABLE Airports (
	Id INT PRIMARY KEY IDENTITY,
	AirportName VARCHAR(70) UNIQUE NOT NULL,
	Country VARCHAR(100) UNIQUE NOT NULL
	)

CREATE TABLE FlightDestinations (
	Id INT PRIMARY KEY IDENTITY,
	AirportId INT FOREIGN KEY REFERENCES Airports(Id) NOT NULL,
	[Start] DATETIME NOT NULL,
	AircraftId INT FOREIGN KEY REFERENCES Aircraft(Id) NOT NULL,
	PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL,
	TicketPrice DECIMAL(18,2) DEFAULT 15 NOT NULL
	)

--02. Insert
INSERT INTO Passengers (FullName, Email)  
	SELECT 
		CONCAT(p.FirstName, ' ', p.LastName) AS FullName,
		CONCAT(p.FirstName, p.LastName, '@gmail.com') AS Email
		FROM Pilots AS p
	WHERE p.Id >= 5 AND p.Id <= 15
	
--03. Update
UPDATE Aircraft
SET Condition = 'A'
WHERE Condition IN ('C', 'B')
	AND (FlightHours IS NULL OR FlightHours <= 100) 
	AND [Year] >= 2013

--04. Delete
DELETE Passengers
WHERE LEN(FullName) <= 10

--05. Aircraft
SELECT Manufacturer, Model, FlightHours, Condition  FROM Aircraft
ORDER BY FlightHours DESC

--06. Pilots and Aircraft
SELECT 
	p.FirstName, 
	p.LastName, 
	a.Manufacturer, 
	a.Model, 
	a.FlightHours 
FROM PilotsAircraft as pa
JOIN Pilots AS p
ON pa.PilotId = p.Id
JOIN Aircraft AS a
ON pa.AircraftId = a.Id
WHERE a.FlightHours IS NOT NULL AND a.FlightHours < 304
ORDER BY a.FlightHours DESC, p.FirstName

--07. Top 20 Flight Destinations

SELECT TOP(20) 
	fd.Id, 
	fd.[Start], 
	p.FullName, 
	a.AirportName, 
	fd.TicketPrice 
FROM FlightDestinations AS fd
JOIN Airports AS a
ON fd.AirportId = a.Id
JOIN Passengers AS p
ON fd.PassengerId = p.Id
WHERE DAY(fd.[Start]) % 2 = 0
ORDER BY fd.TicketPrice DESC, a.AirportName

--08. Number of Flights for Each Aircraft
SELECT	a.Id, 
		a.Manufacturer, 
		a.FlightHours, 
		f.FlightDestinationsCount, 
		f.AvgPrice 
FROM (
	SELECT	fd.AircraftId, 
			COUNT(*) AS FlightDestinationsCount, 
			ROUND(AVG(fd.TicketPrice), 2) AS AvgPrice 
	FROM FlightDestinations AS fd
	GROUP BY AircraftId 
	HAVING COUNT(*) > 1) as f
JOIN Aircraft AS a
ON f.AircraftId = a.Id
ORDER BY f.FlightDestinationsCount DESC, a.Id

--09. Regular Passengers
SELECT p.FullName, g.CountOfAircraft, g.TotalPayed
FROM (
	SELECT	
			PassengerId, 
			COUNT(*) AS CountOfAircraft,
			SUM(fd.TicketPrice) AS TotalPayed 
	FROM FlightDestinations AS fd
	GROUP BY PassengerId
	HAVING COUNT(*) > 1
	) AS g
JOIN Passengers as p
ON g.PassengerId = p.Id
WHERE SUBSTRING(p.FullName, 2, 1) = 'a'
ORDER BY p.FullName

--10. Full Info for Flight Destinations
SELECT
		a.AirportName, 
		fd.[Start] AS DayTime,
		fd.TicketPrice,
		p.FullName,
		air.Manufacturer,
		air.Model
FROM FlightDestinations AS fd
JOIN Airports AS a
ON fd.AirportId = a.Id
JOIN Passengers as p
ON fd.PassengerId = p.Id
JOIN Aircraft AS air
ON fd.AircraftId = air.Id
WHERE DATEPART(HOUR, fd.[Start]) >= 6 
		AND DATEPART(HOUR, fd.[Start]) <= 20 
		AND fd.TicketPrice > 2500
ORDER BY air.Model

--11. Find all Destinations by Email Address
GO

CREATE OR ALTER FUNCTION udf_FlightDestinationsByEmail(@email VARCHAR(50))
RETURNS INT
AS 
BEGIN
	RETURN (
		SELECT COUNT(*) FROM FlightDestinations AS fd
		JOIN Passengers as p
		ON fd.PassengerId = p.Id
		WHERE p.Email = @email 
		)
END

GO

SELECT dbo.udf_FlightDestinationsByEmail('Montacute@gmail.com')
SELECT dbo.udf_FlightDestinationsByEmail('MerisShale@gmail.com')

--12. Full Info for Airports
GO

CREATE OR ALTER PROC usp_SearchByAirportName (@airportName VARCHAR(70))
AS
SELECT	a.AirportName, 
		p.FullName,
		CASE 
			WHEN fd.TicketPrice <= 400 THEN 'Low'
			WHEN fd.TicketPrice <= 1500 THEN 'Medium'
			ELSE 'High'
		END AS LevelOfTickerPrice,
		air.Manufacturer,
		air.Condition,
		t.TypeName

FROM FlightDestinations AS fd
JOIN Airports AS a
ON fd.AirportId = a.Id
JOIN Passengers AS p
ON fd.PassengerId = p.Id
JOIN Aircraft AS air
ON fd.AircraftId = air.Id
JOIN AircraftTypes AS t
ON air.TypeId = t.Id
WHERE a.AirportName = @airportName
ORDER BY air.Manufacturer, p.FullName

EXEC usp_SearchByAirportName 'Sir Seretse Khama International Airport'