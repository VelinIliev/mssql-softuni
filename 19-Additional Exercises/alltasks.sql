USE Diablo

--1. Number of Users for Email Provider
SELECT 
	u.[Email Provider], COUNT(*)
FROM (
	SELECT SUBSTRING(Email, CHARINDEX('@', Email) + 1, LEN(Email)) AS [Email Provider] 
		FROM Users) AS u
GROUP BY u.[Email Provider]
ORDER BY COUNT(*) DESC, u.[Email Provider]

--02. All Users in Games
SELECT	g.[Name], 
		gt.[Name] AS [Game Type], 
		u.Username, ug.[Level], 
		ug.Cash, 
		c.[Name] AS [Character] 
FROM UsersGames AS ug
JOIN Games AS g
ON ug.GameId = g.Id
JOIN Users AS u
ON ug.UserId = u.id
JOIN GameTypes AS gt
ON g.GameTypeId = gt.Id
JOIN Characters AS c
ON ug.CharacterId = c.Id
ORDER BY ug.[Level] DESC, u.Username, g.[Name]

--03. Users in Games with Their Items
SELECT	u.Username, 
		g.[Name] AS Game, 
		COUNT(i.[Name]) AS [Items Count], 
		SUM(i.Price) AS [Items Price] 
FROM UserGameItems AS ugi
JOIN Items AS i
ON ugi.ItemId = i.Id
JOIN UsersGames AS ug
ON ugi.UserGameId = ug.Id
JOIN Games AS g
ON ug.GameId = g.Id
JOIN Users AS u
ON ug.UserId = u.Id
GROUP BY u.Username, g.[Name]
HAVING COUNT(i.[Name]) >= 10
ORDER BY COUNT(i.[Name]) DESC, SUM(i.Price) DESC, u.Username

--04. *User in Games with Their Statistics