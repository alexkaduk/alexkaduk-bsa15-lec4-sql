-- task #2, 3
CREATE DATABASE bsa15_lec4_sql;
GO

USE bsa15_lec4_sql;
GO

CREATE TABLE dbo.Drivers
(
Number int PRIMARY KEY NOT NULL,
FullName varchar(255) NOT NULL,
Birthday datetime NULL
);
GO

CREATE TABLE dbo.Outlets
(
O_Id int IDENTITY(1,1) PRIMARY KEY,
Name varchar(255) NOT NULL,
OutletsAddress varchar(255) NULL
);
GO

CREATE TABLE dbo.Itinerary
(
I_id int IDENTITY(1,1) PRIMARY KEY,
DepartureDate datetime NOT NULL,
ReturnDate datetime NOT NULL,
D_Number int FOREIGN KEY REFERENCES Drivers(Number),
O_Id int FOREIGN KEY REFERENCES Outlets(O_Id)
);
GO

-- task #4
INSERT INTO dbo.Drivers (Number, FullName, Birthday) VALUES 
(101, 'Mike Kyiv', '1980-01-01'),
(102, 'Nick Lviv', '1981-02-02'),
(103, 'Bob Odesa', '1982-03-03'),
(104, 'Alex Vinnytsia', '1983-04-04'),
(105, 'Tom Kharkiv', '1984-05-05');
GO

INSERT INTO dbo.Outlets (Name, OutletsAddress) VALUES
('allo', 'St. 1, Kyiv'),
('itbox', 'St. 2, Kyiv'),
('skidka', 'St. 1, Lviv'),
('ttt', 'St. 2, Lviv'),
('repka', 'St. 1, Odesa'),
('foxtrot', 'St. 2, Odesa'),
('eldorado', 'St. 1, Vinnytsia'),
('rozetka', 'St. 1, Kharkiv');
GO

INSERT INTO dbo.Itinerary (DepartureDate, ReturnDate, D_Number, O_Id) VALUES
('2015-07-14', '2015-07-20', 101, 1),
('2015-07-10', '2015-07-15', 101, 2),/**/
('2015-07-16', '2015-07-21', 101, 2),
('2015-07-02', '2015-07-06', 101, 6),/**/
('2015-07-07', '2015-07-07', 101, 6),/**/
('2015-07-01', '2015-07-10', 102, 3),/**/
('2015-07-02', '2015-07-09', 102, 4),
('2015-07-03', '2015-07-15', 102, 5),
('2015-07-11', '2015-07-20', 102, 6),/**/
('2015-07-21', '2015-07-25', 102, 2),/**/
('2015-07-26', '2015-07-30', 102, 5),/**/
('2015-07-01', '2015-07-10', 103, 7),
('2015-07-09', '2015-07-11', 103, 2),
('2015-07-12', '2015-07-20', 103, 5),/**/
('2015-07-21', '2015-07-30', 103, 6),/**/
('2015-07-12', '2015-07-13', 104, 8),
('2015-07-10', '2015-07-15', 104, 4),
('2015-07-16', '2015-07-20', 104, 7),/**/
('2015-07-21', '2015-07-22', 104, 3),/**/
('2015-07-26', '2015-07-30', 105, 1),
('2015-07-27', '2015-07-29', 105, 3),
('2015-07-01', '2015-07-25', 105, 2);/**/
GO

/* task #5*/
DELETE FROM dbo.Itinerary 
WHERE I_id IN (SELECT DISTINCT i1.I_id FROM dbo.Itinerary AS i1, dbo.Itinerary AS i2
WHERE i1.D_Number = i2.D_Number AND (
(i1.DepartureDate > i2.DepartureDate
AND i1.ReturnDate < i2.ReturnDate)
OR((i1.DepartureDate < i2.DepartureDate
AND i1.ReturnDate > i2.ReturnDate))
OR((i1.DepartureDate > i2.DepartureDate)
AND(i1.DepartureDate < i2.ReturnDate))
OR((i1.DepartureDate < i2.DepartureDate)
AND(i1.ReturnDate > i2.DepartureDate))
)
AND i1.DepartureDate > i2.DepartureDate
);
GO

/* task #6*/
CREATE TRIGGER Trigger_Check_Dates_Before_Insert_Itinerary ON dbo.Itinerary
FOR INSERT, UPDATE
AS 
IF EXISTS (	SELECT i.D_Number FROM dbo.Itinerary AS i
	INNER JOIN inserted AS i_new
	ON i.I_id = i_new.I_id
	WHERE	i.D_Number = i_new.D_Number 
			AND (
				(i_new.DepartureDate > i.DepartureDate AND i_new.DepartureDate < i.ReturnDate)
			OR
				(i_new.ReturnDate > i.DepartureDate AND i_new.ReturnDate < i.ReturnDate)
			)
	)
	BEGIN
		RAISERROR ('Busy dates: intersection date ranges', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN
	END
GO

/* additional trigger - DepartureDate should be less ReturnDate*/
CREATE TRIGGER Trigger_DepartureDate_Less_ReturnDate_Single_Before_Insert_Itinerary ON dbo.Itinerary
FOR INSERT, UPDATE
AS 
IF @@ROWCOUNT=1
BEGIN
	IF (SELECT DepartureDate FROM inserted) > (SELECT ReturnDate FROM inserted) 
		BEGIN
			RAISERROR ('Bad dates: DepartureDate should be less ReturnDate', 16, 1);
			ROLLBACK TRANSACTION;
			RETURN
		END
	END;
GO

CREATE TRIGGER Trigger_DepartureDate_Less_ReturnDate_Before_Insert_Itinerary ON dbo.Itinerary
FOR INSERT, UPDATE
AS 
IF EXISTS (	SELECT * 
			FROM inserted 
			WHERE DepartureDate > ReturnDate)
	BEGIN
		RAISERROR ('Bad dates for few entries inserted: DepartureDate should be less ReturnDate', 16, 1);
		ROLLBACK TRANSACTION;
		RETURN
	END;
GO

/* working query */
INSERT INTO dbo.Itinerary (DepartureDate, ReturnDate, D_Number, O_Id) VALUES
('2015-07-03', '2020-07-03', 101, 3)
GO

SELECT * FROM dbo.Itinerary
ORDER BY D_Number ASC, DepartureDate ASC;
GO

DELETE FROM dbo.Itinerary;
GO