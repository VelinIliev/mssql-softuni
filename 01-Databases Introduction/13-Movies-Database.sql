CREATE DATABASE Movies;

-- •	Directors (Id, DirectorName, Notes)
CREATE TABLE Directors (
	Id INT PRIMARY KEY IDENTITY,
	DirectorName VARCHAR(100) NOT NULL,
	Notes VARCHAR(MAX)
	);

--•	Genres (Id, GenreName, Notes)
CREATE TABLE Genres (
	Id INT PRIMARY KEY IDENTITY,
	GenreName VARCHAR(200) NOT NULL,
	Notes VARCHAR(MAX)
	);

-- •	Categories (Id, CategoryName, Notes)
CREATE TABLE Categories (
	Id INT PRIMARY KEY IDENTITY,
	CategoryName VARCHAR(200) NOT NULL,
	Notes VARCHAR(MAX)
	);

-- •	Movies (Id, Title, DirectorId, CopyrightYear, Length, GenreId, CategoryId, Rating, Notes)
CREATE TABLE Movies (
	Id INT PRIMARY KEY IDENTITY,
	Title VARCHAR(200) NOT NULL,
	DirectorId INT FOREIGN KEY REFERENCES Directors(Id),
	CopyrightYear INT,
	[Length] DECIMAL(10, 2),
	GenreId INT FOREIGN KEY REFERENCES Genres(Id),
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id),
	Rating DECIMAL(10,2),
	Notes VARCHAR(MAX)
	);

INSERT INTO Directors
VALUES 
	('Ivan', 'laskjsf'),
	('Ivan2', 'laskjsf'),
	('Ivan', 'laskjsf'),
	('Ivan2', 'laskjsf'),
	('Ivan', 'laskjsf')

INSERT INTO Genres
VALUES 
	('Action', 'laskjsf'),
	('Drama', 'laskjsf'),
	('Comedy', 'laskjsf'),
	('Comedy', 'laskjsf'),
	('Comedy', 'laskjsf')

INSERT INTO Categories
VALUES 
	('1', 'laskjsf'),
	('2', 'laskjsf'),
	('3', 'laskjsf'),
	('4', 'laskjsf'),
	('5', 'laskjsf')

-- •	Movies (Id, Title, DirectorId, CopyrightYear, Length, GenreId, CategoryId, Rating, Notes)
INSERT INTO Movies
VALUES 
	('XXX', 1, 2002, 100.2, 2, 2, 10, 'askjd'),
	('XXX', 1, 2002, 100.2, 2, 2, 10, 'askjd'),
	('XXX', 1, 2002, 100.2, 2, 2, 10, 'askjd'),
	('XXX', 1, 2002, 100.2, 2, 2, 10, 'askjd'),
	('XXX', 1, 2002, 100.2, 2, 2, 10, 'askjd')


