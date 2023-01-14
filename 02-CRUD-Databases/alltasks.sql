--2 Find All the Information About Departments
SELECT * FROM Departments

--3 Find all Department Names
SELECT [Name] FROM Departments 

--4 Find Salary of Each Employee
SELECT FirstName, LastName, Salary FROM Employees

--5 Find Full Name of Each Employee
SELECT FirstName, MiddleName, LastName FROM Employees

--6 Find Email Address of Each Employee
SELECT FirstName + '.' + LastName + '@softuni.bg' AS [Full Email Address] FROM Employees 

--7	Find All Different Employees' Salaries
SELECT DISTINCT Salary FROM Employees

--8 Find All Information About Employees
SELECT * FROM Employees 
WHERE JobTitle = 'Sales Representative'

--9 Find Names of All Employees by Salary in Range
SELECT FirstName, LastName, JobTitle FROM Employees
WHERE Salary >= 20000 AND Salary <= 30000

--10 Find Names of All Employees
--Create a SQL query that finds the full name of all employees whose salary is exactly 25000, 14000, 
--12500 or 23600. The result should be displayed in a column, named "Full Name", which is a 
--combination of the first, middle and last names, separated by a single space.
SELECT FirstName+' '+MiddleName+' '+LastName AS [Full Name] FROM Employees
WHERE Salary = 25000 OR Salary = 14000 OR Salary = 12500 OR Salary = 23600

--11 Find All Employees Without Manager
SELECT FirstName, LastName FROM Employees
WHERE ManagerID IS NULL

--12 Find All Employees with a Salary More Than 50000
SELECT FirstName, LastName, Salary FROM Employees 
WHERE SALARY >= 50000
ORDER BY Salary DESC

--13 Find 5 Best Paid Employees
SELECT TOP(5) FirstName, LastName FROM Employees
ORDER BY SALARY DESC

--14 Find All Employees Except Marketing
SELECT FirstName, LastName FROM Employees
WHERE DepartmentID <> 4

--15 Sort Employees Table
--Create a SQL query that sorts all the records in the Employees table by the following criteria:
--By salary in decreasing order
--Then by the first name alphabetically
--Then by the last name descending
--Then by middle name alphabetically
SELECT * FROM Employees
ORDER BY Salary DESC, FirstName, LastName DESC, MiddleName

--16 Create View Employees with Salaries
--Create a SQL query that creates a view "V_EmployeesSalaries" 
--with first name, last name and salary for each employee.
CREATE VIEW  [V_EmployeesSalaries] 
AS 
SELECT FirstName, LastName, Salary 
FROM Employees

--17 Create a SQL query that creates a view "V_EmployeeNameJobTitle" with a full employee name 
--and a job title. When the middle name is NULL replace it with an empty string ('').
CREATE VIEW [V_EmployeeNameJobTitle] 
AS SELECT FirstName + ' ' + ISNULL(MiddleName, '') + ' ' + LastName AS [Full Name], 
JobTitle AS [Job Title]
FROM Employees

--18 
SELECT DISTINCT JobTitle FROM Employees

--19 Find First 10 Started Projects
--Create a SQL query that finds the first 10 projects which were started, select all the 
--information about them and order the result by starting date, then by name.
SELECT TOP(10) * FROM Projects 
ORDER BY StartDate, [Name]

--20 
--Create a SQL query that finds the last 7 hired employees, select their first, last name 
--and hire date. Order the result by hire date descending.
SELECT TOP(7) FirstName, LastName, HireDate FROM Employees
ORDER BY HireDate DESC

--21 Increase Salaries
--Create a SQL query that increases salaries by 12% for all employees that work in one of the 
--following departments – Engineering, Tool Design, Marketing or Information Services. 
--As a result, select and display only the "Salaries" column from the Employees table. 
--After this, you should restore the database to the original data
UPDATE Employees
SET Salary = Salary*1.12
WHERE DepartmentID IN (
	SELECT DepartmentID FROM Departments
		WHERE	[Name] = 'Engineering' OR 
				[Name] = 'Tool Design' OR
				[Name] = 'Marketing' OR
				[Name] = 'Information Services'
				)
SELECT Salary FROM Employees

--22 All Mountain Peaks
SELECT PeakName FROM Peaks
ORDER BY PeakName

--23
--Find the 30 biggest countries by population, located in Europe. Display the "CountryName" 
--and "Population". Order the results by population (from biggest to smallest), 
--then by country alphabetically.
SELECT TOP(30) CountryName, [Population] FROM Countries
WHERE ContinentCode = 'EU'
ORDER BY [Population] DESC, CountryName

--24. Countries and Currency (Euro / Not Euro)
--Find all the countries with information about their currency. 
--Display the "CountryName", "CountryCode", and information about its "Currency":
--either "Euro" or "Not Euro". Sort the results by country name alphabetically.
SELECT CountryName, CountryCode, 
CASE 
	WHEN [CurrencyCode] = 'EUR' THEN 'Euro'
	ELSE 'Not Euro'
END AS Currency
FROM Countries
ORDER BY CountryName

--25. All Diablo Characters
SELECT [Name] FROM Characters
ORDER BY [Name]