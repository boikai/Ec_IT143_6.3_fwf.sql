IF OBJECT_ID('dbo.t_w3_schools_customers', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.t_w3_schools_customers (
        CustomerID INT PRIMARY KEY,
        ContactName NVARCHAR(100)
    );

    INSERT INTO dbo.t_w3_schools_customers (CustomerID, ContactName)
    VALUES 
        (1, 'John Smith'),
        (2, 'Jane Doe'),
        (3, 'Alice Brown');
END

IF OBJECT_ID('dbo.t_w3_schools_customers_audit', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.t_w3_schools_customers_audit (
        AuditID INT IDENTITY(1,1) PRIMARY KEY,
        CustomerID INT,
        OldContactName NVARCHAR(100),
        NewContactName NVARCHAR(100),
        AuditDate DATETIME DEFAULT GETDATE()
    );
END;
IF OBJECT_ID('dbo.udf_GetFirstName', 'FN') IS NOT NULL
    DROP FUNCTION dbo.udf_GetFirstName;
GO
CREATE FUNCTION dbo.udf_GetFirstName (@FullName NVARCHAR(100))
RETURNS NVARCHAR(100)
AS
BEGIN
    DECLARE @FirstName NVARCHAR(100);
    IF CHARINDEX(' ', @FullName) > 0
        SET @FirstName = LEFT(@FullName, CHARINDEX(' ', @FullName) - 1);
    ELSE
        SET @FirstName = @FullName;
    RETURN @FirstName;
END;

IF OBJECT_ID('dbo.trg_AuditContactNameChange', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_AuditContactNameChange;

   CREATE TRIGGER dbo.trg_AuditContactNameChange
ON dbo.t_w3_schools_customers
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON

    INSERT INTO dbo.t_w3_schools_customers_audit (CustomerID, OldContactName, NewContactName)
    SELECT d.CustomerID, d.ContactName, i.ContactName
    FROM deleted d
    JOIN inserted i ON d.CustomerID = i.CustomerID
    WHERE d.ContactName <> i.ContactName
END

UPDATE dbo.t_w3_schools_customers
SET ContactName = 'Mary Johnson'
WHERE CustomerID = 2;

SELECT * FROM dbo.t_w3_schools_customers;
SELECT * FROM dbo.t_w3_schools_customers_audit;