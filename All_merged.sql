-- All scripts merged 

-- -----------------------------------------------------
-- ACLS | DDAS | Project
-- Create Database
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Database
-- -----------------------------------------------------
DROP DATABASE IF EXISTS the_lab_db;
CREATE DATABASE the_lab_db;
USE the_lab_db;

-- -----------------------------------------------------
-- Table for laboratory benches
-- -----------------------------------------------------
CREATE TABLE benches (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(45) NOT NULL,
    exp_class TINYINT NOT NULL,
    PRIMARY KEY (id)
    );

-- -----------------------------------------------------
-- Table for toxicity classes
-- -----------------------------------------------------
CREATE TABLE toxicities (
    class INT NOT NULL,
    description VARCHAR(45) NOT NULL,
    PRIMARY KEY (class)
    );

-- -----------------------------------------------------
-- Table for chemicals
-- -----------------------------------------------------
CREATE TABLE chemicals (
    name VARCHAR(50) NOT NULL,
    tox_class INT NOT NULL,
    PRIMARY KEY (name),
    FOREIGN KEY (tox_class) REFERENCES toxicities(class)
    );

-- -----------------------------------------------------
-- Table for operational units
-- -----------------------------------------------------
CREATE TABLE op_units (
    id INT NOT NULL AUTO_INCREMENT,
    name VARCHAR(45) NULL,
    head INT NULL,
    PRIMARY KEY (id)
    );

-- -----------------------------------------------------
-- Table for scientists
-- -----------------------------------------------------
CREATE TABLE scientists (
    id INT NOT NULL AUTO_INCREMENT,
    first_name VARCHAR(45) NOT NULL,
    last_name VARCHAR(45) NOT NULL,
    birth_date DATE,
    graduation_year YEAR,
    op_unit_id INT NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (op_unit_id) REFERENCES op_units(id)
    );
    
    
-- -----------------------------------------------------
-- Add scientists foreign key to operational unit
-- -----------------------------------------------------
ALTER TABLE op_units ADD 
FOREIGN KEY (head) REFERENCES scientists(id); 


-- -----------------------------------------------------
-- Table for experiments
-- -----------------------------------------------------
CREATE TABLE experiments (
    id INT NOT NULL AUTO_INCREMENT,
    scientist_id INT NOT NULL,
    date DATE NOT NULL,
    duration TIME,
    success TINYINT,
    exp_class TINYINT,
    PRIMARY KEY (id),
    FOREIGN KEY (scientist_id) REFERENCES scientists(id)
    );

-- -----------------------------------------------------
-- Table for chemicals in experiments
-- -----------------------------------------------------
CREATE TABLE exp_chem (
    id INT NOT NULL AUTO_INCREMENT,
    exp_id INT NOT NULL,
    chem_name VARCHAR(45) NOT NULL,
    PRIMARY KEY (id),
    FOREIGN KEY (exp_id) REFERENCES experiments(id),
    FOREIGN KEY (chem_name) REFERENCES chemicals(name)
    );

-- View 
-- ======================================================================
--   Views
-- ======================================================================

USE employees;

CREATE OR REPLACE VIEW foxes AS
SELECT * 
FROM employees
WHERE employees.hire_date<'1985-02-01';

-- test
SELECT * FROM foxes;

-- just for demonstration (also update would work)
INSERT INTO foxes(emp_no, birth_date, first_name, last_name, gender, hire_date)
			VALUES(2000000, '2000-01-01', 'Tony', 'Romeo', 'M', '2023-01-02');
            
-- remark: delete DELETE FROM on a view does't work in most cases (in MySQL)
-- the DELETE FROM must be performed directly on the underlying table
DELETE FROM employees WHERE emp_no = 2000000;

-- remove view to clean up
DROP VIEW foxes;

-- ----------------------------------------------------------------------

CREATE OR REPLACE VIEW engineers AS 
SELECT employees.emp_no, first_name, last_name FROM employees
INNER JOIN titles ON employees.emp_no=titles.emp_no
WHERE titles.title = 'Engineer';

-- test
SELECT * FROM engineers LIMIT 30;

-- remark: it is not possible to insert data over this view (beacuse you have no access to the notnull attributes and the foreign key)

-- just for demonstration
UPDATE engineers SET first_name = "Josef" WHERE emp_no = 10001;

-- remove view to clean up
DROP VIEW engineers;

-- ======================================================================
--   Procedures
-- ======================================================================

DELIMITER %%
CREATE PROCEDURE age_limit
(IN d DATE)
BEGIN
    SELECT * FROM employees
    WHERE birth_date>d;
END; %%
DELIMITER ;

-- test
CALL age_limit('1964-12-31');

-- remove
DROP PROCEDURE age_limit;

-- ----------------------------------------------------------------------

DELIMITER %%
CREATE PROCEDURE by_dept
(IN d VARCHAR(4))
BEGIN
    SELECT first_name, last_name FROM employees
    INNER JOIN dept_emp ON employees.emp_no = dept_emp.emp_no
    WHERE dept_emp.dept_no = d;
END %%
DELIMITER ;

-- test
CALL by_dept('d004');

-- remove
DROP PROCEDURE by_dept;

-- ----------------------------------------------------------------------------
-- Remarks --------------------------------------------------------------------

-- creation of a procedure without special delimiter (only work if we have only one statement)
CREATE PROCEDURE by_dept(d VARCHAR(4))
SELECT first_name, last_name FROM employees INNER JOIN dept_emp ON employees.emp_no = dept_emp.emp_no WHERE dept_emp.dept_no = d;

-- test
CALL by_dept('d004');

-- remove
DROP PROCEDURE by_dept;

-- example where we need the BEGIN AND block
DELIMITER %%
CREATE PROCEDURE by_dept
(IN  d DATE, e VARCHAR(4))
BEGIN
	SELECT * FROM employees WHERE birth_date>d;
    SELECT first_name, last_name FROM employees
    INNER JOIN dept_emp ON employees.emp_no = dept_emp.emp_no
    WHERE dept_emp.dept_no = e;
END %%
DELIMITER ;

-- test
CALL by_dept('1964-12-31', 'd004');

-- remove
DROP PROCEDURE by_dept;


-- Read 
-- use correct database
USE employees;

-- Show the description of the table employees
DESC employees;

-- Retrieve all attributes of the first five employees
SELECT * FROM employees LIMIT 5;

-- Retrieve all attributes of the female employees who are born on September 2, 1953 (i.e. 1953-09-02)
SELECT * FROM employees 
WHERE gender='F' AND birth_date='1953-09-02';

-- Retrieve the full name of the first 20 employees whose last name ends with the string “man” and sort them by their age (youngest first)
SELECT first_name, last_name 
FROM employees 
WHERE last_name LIKE '%man' 
ORDER BY birth_date DESC 
LIMIT 20;

-- Nested 
USE employees;

-- ======================================================================
--   Subquery in the FROM clause
-- ======================================================================

-- Task 1 ---------------------------------------------------------------

SELECT employees.emp_no, employees.last_name, employees.first_name
      FROM employees
      INNER JOIN titles ON employees.emp_no=titles.emp_no
      WHERE employees.gender='F'  AND
	        titles.title='Senior Engineer';
            
-- Task 2 --------------------------------------------------------------

SELECT f_sen_engineers.first_name, f_sen_engineers.last_name, salaries.salary
FROM (SELECT employees.emp_no, employees.last_name, employees.first_name -- \
      FROM employees                                                     --  |
      INNER JOIN titles ON employees.emp_no=titles.emp_no                --   > subquery
      WHERE employees.gender='F'  AND                                    --  |
	        titles.title='Senior Engineer')                              -- /
AS f_sen_engineers                                                 
INNER JOIN salaries ON f_sen_engineers.emp_no=salaries.emp_no
ORDER BY salaries.salary DESC  
LIMIT 30;

-- Task 3 ---------------------------------------------------------------

-- Optional task (advanced): get the last salary of each employee (Female and Senior Engineer)
      
SELECT f_sen_engineers.first_name, f_sen_engineers.last_name, salaries.salary
FROM (SELECT employees.emp_no, employees.last_name, employees.first_name -- \
      FROM employees                                                     --  |
      INNER JOIN titles ON employees.emp_no=titles.emp_no                --   > subquery
      WHERE employees.gender='F'  AND                                    --  |
	        titles.title='Senior Engineer')                              -- /
AS f_sen_engineers                                                 
INNER JOIN salaries ON f_sen_engineers.emp_no=salaries.emp_no
-- -----------------------------------------------------------------------------------------------------------------      
-- This line is not expected since we did not cover function such as MAX.
-- However, this line makes sure we only have one entry per employee taking the one with salary with the latest/highest date
WHERE salaries.from_date=(SELECT MAX(salaries.from_date) FROM salaries WHERE salaries.emp_no=f_sen_engineers.emp_no) 
-- -----------------------------------------------------------------------------------------------------------------
ORDER BY salaries.salary DESC 
LIMIT 30;

-- Task 4 ---------------------------------------------------------------

-- Optional task (advanced): get the max salary of each employee (Female and Senior Engineer), sorted by salary

SELECT f_sen_engineers.first_name, f_sen_engineers.last_name, MAX(salaries.salary)
FROM (SELECT employees.emp_no, employees.last_name, employees.first_name -- \
      FROM employees                                                     --  |
      INNER JOIN titles ON employees.emp_no=titles.emp_no                --   > subquery
      WHERE employees.gender='F'  AND                                    --  |
	        titles.title='Senior Engineer')                              -- /
AS f_sen_engineers                                                 
INNER JOIN salaries ON f_sen_engineers.emp_no=salaries.emp_no
GROUP BY f_sen_engineers.first_name, f_sen_engineers.last_name
ORDER BY MAX(salaries.salary) DESC 	 
LIMIT 30;

-- ======================================================================
--   Subquery in the WHERE clause
-- ======================================================================

-- Task 1 ---------------------------------------------------------------

SELECT employees.last_name, employees.gender, employees.birth_date, titles.title
FROM employees
INNER JOIN titles ON employees.emp_no=titles.emp_no
LIMIT 30;

-- Task 2 ---------------------------------------------------------------

SELECT employees.last_name, employees.gender, employees.birth_date, titles.title
FROM employees
INNER JOIN titles ON employees.emp_no=titles.emp_no
WHERE titles.title=(SELECT title FROM titles WHERE emp_no=10500)  -- subquery
LIMIT 30;

-- Joins 
-- ======================================================================
--   INNER JOIN
-- ======================================================================

-- Task 1 ---------------------------------------------------------------

USE employees;

SELECT employees.first_name, employees.last_name, titles.title
FROM employees
INNER JOIN titles ON employees.emp_no=titles.emp_no
LIMIT 30;

 -- Task 2 ----------------------------------------------------------------

SELECT salaries.salary, titles.title
FROM salaries
INNER JOIN titles ON salaries.emp_no=titles.emp_no
WHERE salaries.salary > 155000;

-- just for demonstration, also return employee name

SELECT salaries.salary, titles.title, employees.first_name, employees.last_name
FROM salaries
INNER JOIN titles ON salaries.emp_no=titles.emp_no
INNER JOIN employees ON salaries.emp_no=employees.emp_no
WHERE salaries.salary > 155000;

-- ======================================================================
--   LEFT JOIN
-- ======================================================================

SELECT employees.emp_no, employees.first_name, employees.birth_date, dept_manager.dept_no, dept_manager.to_date
FROM employees
LEFT JOIN dept_manager ON employees.emp_no=dept_manager.emp_no
WHERE employees.emp_no BETWEEN 109990 AND 110200;

-- just for demonstration, with INNER JOIN
-- only employees who are or were department heads would be listed

SELECT employees.emp_no, employees.first_name, employees.birth_date, dept_manager.dept_no, dept_manager.to_date
FROM employees
INNER JOIN dept_manager ON employees.emp_no=dept_manager.emp_no
WHERE employees.emp_no BETWEEN 109990 AND 110200;

-- just for demonstration, with the IS NOT NULL we would get be the same result as with INNER JOIN
-- only employees who are or were department heads would be listed

SELECT employees.first_name, employees.birth_date, dept_manager.dept_no, dept_manager.to_date
FROM employees
LEFT JOIN dept_manager ON employees.emp_no=dept_manager.emp_no
WHERE employees.emp_no BETWEEN 109990 AND 110200 AND dept_manager.dept_no IS NOT NULL;

-- ======================================================================
--   RIGHT JOIN
-- ======================================================================

SELECT DISTINCT employees.last_name, employees.gender
FROM salaries
RIGHT JOIN employees ON salaries.emp_no=employees.emp_no
WHERE salaries.salary > 155000;

-- just for demonstration, same query but with LEFT JOIN

SELECT DISTINCT employees.last_name, employees.gender
FROM employees
LEFT JOIN salaries ON salaries.emp_no=employees.emp_no
WHERE salaries.salary > 155000;

-- ======================================================================
--   Create Database
-- ======================================================================
DROP DATABASE IF EXISTS projectscmd; 
CREATE DATABASE projectscmd;
USE projectscmd;

-- ======================================================================
--   Create Tables
-- ======================================================================
CREATE TABLE projects(
					   ID int NOT NULL AUTO_INCREMENT, 
					   Name varchar(30), 
					   ManagerID int, 
					   Budget int, 
					   StartDate date, 
					   Progress decimal(5,2), 
					   Status boolean, 
					   PRIMARY KEY (ID)
					   );
                       
CREATE TABLE persons(
						 ID int NOT NULL AUTO_INCREMENT,
						 FirstName varchar(25),
						 FamilyName varchar(25),
						 DepartmentID int,
						 PRIMARY KEY (ID)
						 );                       
                       
CREATE TABLE departments(
						 ID int NOT NULL AUTO_INCREMENT,
						 Name varchar(25),
						 PRIMARY KEY (ID)
						 );                       

CREATE TABLE work(
					 ID int NOT NULL AUTO_INCREMENT,
					 Date date,
					 ProjectID int,
					 PersonID int,
					 Hours float,
					 PRIMARY KEY (ID),
					 FOREIGN KEY (ProjectID) REFERENCES projects(ID),                     
					 FOREIGN KEY (PersonID) REFERENCES persons(ID)
					 );

ALTER TABLE persons ADD FOREIGN KEY (DepartmentID) REFERENCES departments(ID);
ALTER TABLE projects ADD FOREIGN KEY (ManagerID) REFERENCES persons(ID);

/*
-- Alternatively you can generate the tables in a different order (master tables first and transactional data later)
-- Like this there is no need to add the foreign keys after the table creation 
CREATE TABLE departments(
						 ID int NOT NULL AUTO_INCREMENT,
						 Name varchar(25),
						 PRIMARY KEY (ID)
						 );                       
CREATE TABLE persons(
						 ID int NOT NULL AUTO_INCREMENT,
						 FirstName varchar(25),
						 FamilyName varchar(25),
						 DepartmentID int,
						 PRIMARY KEY (ID),
						 FOREIGN KEY (DepartmentID) REFERENCES departments(ID)
						 );
                     
CREATE TABLE projects(
					   ID int NOT NULL AUTO_INCREMENT, 
					   Name varchar(30), 
					   ManagerID int, 
					   Budget int, 
					   StartDate date, 
					   Progress decimal(5,2), 
					   Status boolean, 
					   PRIMARY KEY (ID),
                       FOREIGN KEY (ManagerID) REFERENCES persons(ID)
					   );

CREATE TABLE work(
					 ID int NOT NULL AUTO_INCREMENT,
					 Date date,
					 ProjectID int,
					 PersonID int,
					 Hours float,
					 PRIMARY KEY (ID),
					 FOREIGN KEY (ProjectID) REFERENCES projects(ID),                     
					 FOREIGN KEY (PersonID) REFERENCES persons(ID)
					 );
*/                     
         
-- ======================================================================
--   Insert Records
-- ======================================================================
INSERT INTO projects(Name, Budget, StartDate, Progress, Status)
            VALUES('BioCraft', 2500000, '2016-03-12', 74, true);
INSERT INTO projects(Name, Budget, StartDate, Progress, Status)
            VALUES('ChemTrail', 750000, '2017-08-04', 32, true);
INSERT INTO projects(Name, Budget, StartDate, Progress, Status)
            VALUES('ClimatePro', 1800000, '2012-11-01', 100, true);
            
INSERT INTO persons(FirstName, FamilyName)
            VALUES('Thomas', 'Sawyer');
INSERT INTO persons(FirstName, FamilyName)
            VALUES('Huckelberry', 'Finn');
INSERT INTO persons(FirstName, FamilyName)
            VALUES('Dorothy', 'Gale');
INSERT INTO persons(FirstName, FamilyName)
            VALUES('Alice', 'Liddell');
INSERT INTO persons(FirstName, FamilyName)
            VALUES('Oliver', 'Twist');
            
INSERT INTO departments(Name) VALUES('Biology');
INSERT INTO departments(Name) VALUES('Chemistry');
INSERT INTO departments(Name) VALUES('Environment');

INSERT INTO work(Date, ProjectID, PersonID, Hours)
            VALUES('2016-03-14', 1, 2, 8.25);
INSERT INTO work(Date, ProjectID, PersonID, Hours)
            VALUES('2016-03-14', 1, 4, 4.50);
INSERT INTO work(Date, ProjectID, PersonID, Hours)
            VALUES('2016-03-14', 1, 1, 9.00);
INSERT INTO work(Date, ProjectID, PersonID, Hours)
            VALUES('2011-05-12', 3, 5, 8.75);


-- ======================================================================
--   Modify Table
-- ======================================================================
    
ALTER TABLE departments ADD HeadID int;
ALTER TABLE departments ADD FOREIGN KEY(HeadID) REFERENCES Persons(ID);


-- ======================================================================
--   Modify Records
-- ======================================================================

UPDATE projects SET ManagerID=1 WHERE ID=1;
/*
-- Alternatively you can lookup die ID in table persons for the ManagerID with a nested query 
UPDATE projects SET ManagerID=1 WHERE ID=(SELECT ID FROM persons WHERE FirstName = 'Thomas' AND FamilyName = 'Sawyer'); 
*/ 
UPDATE projects SET ManagerID=3 WHERE ID=2; 
UPDATE projects SET ManagerID=5, Status=false WHERE Id=3; 

UPDATE persons SET DepartmentID=1 WHERE ID=1;
UPDATE persons SET DepartmentID=1 WHERE ID=2;
UPDATE persons SET DepartmentID=2 WHERE ID=3;
UPDATE persons SET DepartmentID=1 WHERE ID=4;
UPDATE persons SET DepartmentID=3 WHERE ID=5;

UPDATE departments SET HeadID=1 WHERE ID=1;
UPDATE departments SET HeadID=3 WHERE ID=2;
UPDATE departments SET HeadID=5 WHERE ID=3;

UPDATE work SET Hours=7.50 WHERE ID=2;


-- ======================================================================
--   Delete Record
-- ======================================================================

DELETE FROM work WHERE ID=1;

--  Create Database LabDB 

DROP DATABASE IF EXISTS labdb; 
CREATE DATABASE labdb;
USE labdb;

--   Create Tables

CREATE TABLE laboratory_benches(
					   Bench_ID int NOT NULL AUTO_INCREMENT, 
					   Bench_name varchar(30),
                       Experiment_class ENUM('1','2','3'),
                       PRIMARY KEY (Bench_ID));
                       
CREATE TABLE Operational_Units(
						 Unit_ID int NOT NULL AUTO_INCREMENT,
						 Unit_name varchar(25),
                         Head int,
						 PRIMARY KEY (Unit_ID));   
                         
CREATE TABLE Scientists(
						 Scientist_ID int NOT NULL AUTO_INCREMENT,
						 Name varchar(25),
						 Surname varchar(25),
						 Date_birth date,
                         Year_graduation year,
                         Operational_unit int,
						 PRIMARY KEY (Scientist_ID),
                         FOREIGN KEY (Operational_unit) REFERENCES Operational_Units(Unit_ID));                       
                                           
CREATE TABLE Toxicity_classes(
					 ToxicClass_ID int NOT NULL AUTO_INCREMENT,
					 Class_number int,
					 Description varchar(25),
					 PRIMARY KEY (ToxicClass_ID));
                     
CREATE TABLE Chemicals(
					 Chemical_ID int NOT NULL AUTO_INCREMENT,
					 Chemical_name varchar(25),
					 Toxicity_class int,
					 PRIMARY KEY (Chemical_ID),
                     FOREIGN KEY (Toxicity_class) REFERENCES Toxicity_classes(ToxicClass_ID));

CREATE TABLE Experiments(
					 Experiment_ID int NOT NULL AUTO_INCREMENT,
					 Performing_scientist int,
					 Date_execution date,
                     Duration time, 
                     Outcome ENUM('success', 'no success'),
                     Experiment_class ENUM('1','2','3'),
					 PRIMARY KEY (Experiment_ID),
                     FOREIGN KEY (Performing_scientist) REFERENCES Scientists(Scientist_ID));
                     
CREATE TABLE Chemicals_Experiments(
					 ID int NOT NULL AUTO_INCREMENT,
					 Chemical int,
					 Experiment int,
					 PRIMARY KEY (ID),
                     FOREIGN KEY (Chemical) REFERENCES Chemicals(Chemical_ID),
                     FOREIGN KEY (Experiment) REFERENCES Experiments(Experiment_ID));

-- Add Foreign Keys 
ALTER TABLE Operational_Units ADD FOREIGN KEY (Head) REFERENCES Scientists(Scientist_ID);
