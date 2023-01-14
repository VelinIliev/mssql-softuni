CREATE TABLE People (
	Id BIGINT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(200) NOT NULL,
	Picture VARBINARY,
	[Height] DECIMAL(10, 2),
	[Weight] DECIMAL(10, 2),
	Gender CHAR(1) NOT NULL, 
	CHECK (Gender='f' OR Gender='m'),
	Birthdate DATE NOT NULL,
	Biography VARCHAR(MAX)
)

INSERT INTO People
VALUES 
	('Ivan', null, 1.2, 1.33, 'm', '01-01-2002', 'alsjdlasdj'),
	('Ivanka', null, 2, 3, 'f', '01-01-2002', 'alsjdlasdj'),
	('Ivan', null, 2, 3, 'm', '01-01-2002', 'alsjdlasdj'),
	('Ivanka', null, 2, 3, 'f', '01-01-2002', 'alsjdlasdj'),
	('Ivan', null, 2, 3, 'm', '01-01-2002', 'alsjdlasdj')

SELECT * FROM People