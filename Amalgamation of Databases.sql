-- Task 1
-- Since Messy is in de-normalized form  we only transfer values of parent table such as customer, product category.
-- since child table such as order details/purchase details has too much dependencies and conditions which does not allow any null value.
-- creating INSERTCUSTOMERDETAILS, INSERTPROSUCTCATALOGUE stored procedures to insert values into the database.
-- using insert_cursor, insert_cursor1 to fetch customer and product details from the messy table and use cursor to insert data one by on by passing values to procedures one by one.


-- Inserting values into customer table


GO
CREATE  or ALTER PROCEDURE InsertCustomerDetails
       
       @name varchar(50),
       @companyName varchar(40),
	   @address_delivery varchar(100),
	   @address_city varchar(50),
	   @address_postcode varchar(20),
	   @phone varchar(20)
       
AS
BEGIN
       SET NOCOUNT ON;
	   BEGIN TRY
    -- Insert statements for procedure here
       INSERT INTO [NewBigCo].[dbo].[Customer]
       ([name]
      ,[companyname]
      ,[address_delivery]
      ,[address_city]
      ,[address_postcode]
      ,[phone])
       VALUES (@name, @companyName, @address_delivery, @address_city,@address_postcode,@phone) 
	   END TRY
	BEGIN CATCH
		PRINT('Error! Cannot Insert a NULL Value into the "Products" Table')
	END CATCH
	    
END
GO
USE NF
DECLARE insert_cursor CURSOR FOR 
SELECT [CustomerName]      ,[CustomerAddress1]
      ,[CustomerAddress2]
      ,[CustomerAddress3]
	  ,[CustomerAddress4]
      ,[CustomerAddress5]
      ,[CustomerPhoneNo]
  FROM [NF].[dbo].[Messy]
Declare @CustomerName varchar(100), @CustomerAddress1 varchar(100), @CustomerAddress2 varchar(100),@CustomerAddress3 varchar(100),@CustomerAddress4 varchar(100),@CustomerAddress5 varchar(100),@CustomerPhoneNo varchar(20)
OPEN insert_cursor
FETCH NEXT FROM insert_cursor into @CustomerName, @CustomerAddress1, @CustomerAddress2, @CustomerAddress3,@CustomerAddress4,@CustomerAddress5,@CustomerPhoneNo

-- check for a new row
WHILE @@FETCH_STATUS=0
BEGIN
EXEC InsertCustomerDetails @CustomerName, "NOT KNOWN", @CustomerAddress1, @CustomerAddress4, @CustomerAddress5,@CustomerPhoneNo
FETCH NEXT FROM insert_cursor into @CustomerName, @CustomerAddress1, @CustomerAddress2, @CustomerAddress3, @CustomerAddress3,@CustomerAddress4,@CustomerAddress5,@CustomerPhoneNo
END
close insert_cursor
Deallocate insert_cursor
GO

-- Inserting values into Product catalogue table
GO
CREATE  or ALTER PROCEDURE InsertProductCatelogue
       
       @categoryname varchar(15),
       @description varchar(200)
AS
BEGIN
       SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRY
       INSERT INTO [NewBigCo].[dbo].[Categories]
       ([categoryname]
      ,[description])
       VALUES (@categoryname,@description ) 
	END TRY
	BEGIN CATCH
		PRINT('Error! Cannot Insert a NULL Value into the "Products" Table')
	END CATCH
	    
END
GO
USE NF
DECLARE insert_cursor1 CURSOR FOR 
SELECT [ProductTags]
  FROM [NF].[dbo].[Messy]
  where ProductTags is not null


Declare @Productcat varchar(500)
OPEN insert_cursor1
FETCH NEXT FROM insert_cursor1 into @Productcat
-- check for a new row
WHILE @@FETCH_STATUS=0
BEGIN
EXEC InsertProductCatelogue @Productcat, "NOT KNOWN"
FETCH NEXT FROM insert_cursor1 into @Productcat
END
close insert_cursor1
Deallocate insert_cursor1

-------------------------------------------------------TASK 2---------------------------------------------------------------------


SELECT  * FROM [NewBigCo].[dbo].[Customer]
SELECT * FROM [NewBigCo].[dbo].[Employees]
SELECT * FROM [NewBigCo].[dbo].[Product]


--1. THIS TRIGGER GIVES THE AUDIT DETAILS OF CUSTOMER IN A CUSTOMER AUDIT TABLE WHEN NEW CUSTOMER IS INSERTED

CREATE OR ALTER TRIGGER CustomerInsert ON Customer
AFTER INSERT
AS 
BEGIN
	DECLARE @customer_id INT
	SELECT @customer_id = customer_id FROM inserted
	INSERT INTO customeraudit (customer_id,audit)
	VALUES(@customer_id,'New Employee with Id = ' + CAST(@customer_id as nvarchar(5)) + ' is added at ' + CAST(GETDATE() AS nvarchar(20)))
END
GO

SET IDENTITY_INSERT [NewBigCo].[dbo].[Customer] ON;
INSERT INTO [NewBigCo].[dbo].[Customer] (customer_id,name,companyname,address_delivery,address_city,address_postcode,phone) VALUES(14, 'A' ,'AA', '1773 BASELINE', 'OTTAWA', 'K2C 0C1', 6132635989)
SET IDENTITY_INSERT [NewBigCo].[dbo].[Customer] OFF;




--2. THIS TRIGGER GIVES THE AUDIT DETAILS OF CUSTOMER IN A CUSTOMER AUDIT TABLE WHEN NEW CUSTOMER IS DELETED

CREATE OR ALTER TRIGGER CustomerDelete ON Customer
AFTER delete
AS 
BEGIN
	DECLARE @customer_id INT
	SELECT @customer_id = customer_id FROM deleted
	INSERT INTO customeraudit (customer_id,audit)
	VALUES(@customer_id,'New Employee with Id = ' + CAST(@customer_id as nvarchar(5)) + ' is deleted at ' + CAST(GETDATE() AS nvarchar(20)))
END
GO

DELETE [NewBigCo].[dbo].[Customer] WHERE customer_id = 14




--3. THIS TRIGGER GIVES THE AUDIT DETAILS OF CUSTOMER IN A CUSTOMER AUDIT TABLE WHEN NEW CUSTOMER IS UPDATED

CREATE OR ALTER TRIGGER CustomerUpdate ON Customer
AFTER UPDATE
AS 
BEGIN
	DECLARE @customer_id INT
	SELECT @customer_id = customer_id FROM inserted
	INSERT INTO customeraudit (customer_id,audit)
	VALUES(@customer_id,'New Employee with Id = ' + CAST(@customer_id as nvarchar(5)) + ' is updated at ' + CAST(GETDATE() AS nvarchar(20)))
END
GO


Update [NewBigCo].[dbo].[Customer] set companyname = 'BB' where customer_id = 13





--4. THIS TRIGGER GIVES THE AUDIT DETAILS OF EMPLOYEES IN A EMPLOYEE AUDIT TABLE WHEN NEW EMPLOYEE IS INSERTED

CREATE or alter TRIGGER EmployeeInsert ON Employees
AFTER INSERT
AS 
BEGIN
	DECLARE @employee_id INT
	SELECT @employee_id = empid FROM inserted
	INSERT INTO employeesaudit (empid,audit)
	VALUES(@employee_id,'New Employee with Id = ' + CAST(@employee_id as nvarchar(5)) + ' is added at ' + CAST(GETDATE() AS nvarchar(20)))
END
GO

SET IDENTITY_INSERT [NewBigCo].[dbo].[Employees] ON;
INSERT INTO [NewBigCo].[dbo].[Employees] (empid,lastname,firstname,title,titleofcourtesy, birthdate,hiredate,address,city,region, postalcode,country,phone) VALUES(12, 'Aa' ,'AA', 'manager','rs', 2018-09-21 ,2018-09-21 ,'212 - 29 ave','seatle','WA',231,'USA', 6132635989)
SET IDENTITY_INSERT [NewBigCo].[dbo].[Employees] OFF;





--5. THIS TRIGGER GIVES THE AUDIT DETAILS OF EMPLOYEES IN A EMPLOYEE AUDIT TABLE WHEN NEW EMPLOYEE IS INSERTED

CREATE or alter TRIGGER EmployeeDelete ON Employees
AFTER DELETE
AS 
BEGIN
	DECLARE @employee_id INT
	SELECT @employee_id = empid FROM deleted
	INSERT INTO employeesaudit (empid,audit)
	VALUES(@employee_id,'New Employee with Id = ' + CAST(@employee_id as nvarchar(5)) + ' is deleted at ' + CAST(GETDATE() AS nvarchar(20)))
END
GO


DELETE [NewBigCo].[dbo].[Employees] WHERE empid = 12





--6. THIS TRIGGER GIVES THE AUDIT DETAILS OF EMPLOYEES IN A EMPLOYEE AUDIT TABLE WHEN NEW EMPLOYEE IS UPDATED

CREATE or alter TRIGGER EmployeeUpdate ON Employees
AFTER UPDATE
AS 
BEGIN
	DECLARE @employee_id INT
	SELECT @employee_id = empid FROM inserted
	INSERT INTO employeesaudit (empid,audit)
	VALUES(@employee_id,'New Employee with Id = ' + CAST(@employee_id as nvarchar(5)) + ' is updated at ' + CAST(GETDATE() AS nvarchar(20)))
END
GO


Update [NewBigCo].[dbo].[Employees] set lastname = 'BB' where empid = 11





--7. THIS TRIGGER GIVES THE AUDIT DETAILS OF PRODUCT IN A PRODUCT AUDIT TABLE WHEN NEW PRODUCT IS UPDATED

CREATE or alter TRIGGER ProductInsert ON product
AFTER INSERT
AS 
BEGIN
	DECLARE @product_id INT
	SELECT @product_id = product_id FROM inserted
	INSERT INTO productaudit (product_id,audit)
	VALUES(@product_id,'New Employee with Id = ' + CAST(@product_id as nvarchar(5)) + ' is inserted at ' + CAST(GETDATE() AS nvarchar(20)))
END
GO

SET IDENTITY_INSERT [NewBigCo].[dbo].[product] ON;
INSERT INTO [NewBigCo].[dbo].[product] (product_id,supplierid,categoryid,product_name,unit_price) VALUES(11, '5' ,'5', 'hp',600)
INSERT INTO [NewBigCo].[dbo].[product] (product_id,supplierid,categoryid,product_name,unit_price) VALUES(12, '5' ,'5', 'hp',600)
SET IDENTITY_INSERT [NewBigCo].[dbo].[product] OFF;





--8. THIS TRIGGER GIVES THE AUDIT DETAILS OF PRODUCT IN A PRODUCT AUDIT TABLE WHEN NEW PRODUCT IS DELETED

CREATE or alter TRIGGER ProductDelete ON product
AFTER DELETE
AS 
BEGIN
	DECLARE @product_id INT
	SELECT @product_id = product_id FROM deleted
	INSERT INTO productaudit (product_id,audit)
	VALUES(@product_id,'New Employee with Id = ' + CAST(@product_id as nvarchar(5)) + ' is deleted at ' + CAST(GETDATE() AS nvarchar(20)))
END
GO

DELETE [NewBigCo].[dbo].[product] WHERE product_id = 12


--9. IN THIS NESTED TRIGGER, FIRST TRIGGER GIVES THE AUDIT DETAILS OF PRODUCT IN A PRODUCT AUDIT TABLE AND SECOND TRIGGER GIVES WHETHER THE AUDIT DATAS ARE SUCCESSFULLY IMPLEMENTED OR NOT.

CREATE or alter TRIGGER Product_nested_Insert ON product
AFTER INSERT
AS 
BEGIN
  
	DECLARE @product_id INT
	SELECT @product_id = product_id FROM inserted
	INSERT INTO productaudit (product_id,audit)
	VALUES(@product_id,'New Employee with Id = ' + CAST(@product_id as nvarchar(5)) + ' is inserted at ' + CAST(GETDATE() AS nvarchar(20)))
END
GO

CREATE or alter TRIGGER customeraudit1 ON [NewBigCo].[dbo].[productaudit]
AFTER INSERT
AS 
BEGIN
  
	DECLARE @product_id INT
	SELECT @product_id = product_id FROM inserted
	IF @product_id IS NOT NULL
    PRINT 'AUDIT TRIGGER WORKED SUCCESSFULLY'
	ELSE PRINT 'AUDIT TRIGGER NOT WORKING'
END
GO







--10. IN THIS NESTED TRIGGER, FIRST TRIGGER GIVES THE AUDIT DETAILS OF CUSTOMER IN A CUSTOMER AUDIT TABLE AND SECOND TRIGGER GIVES WHETHER THE AUDIT DATAS ARE SUCCESSFULLY IMPLEMENTED OR NOT.

CREATE OR ALTER TRIGGER Customer_nested_Insert ON Customer
AFTER INSERT
AS 
BEGIN
	DECLARE @customer_id INT
	SELECT @customer_id = customer_id FROM inserted
	INSERT INTO [NewBigCo].[dbo].[customeraudit] (customer_id,audit)
	VALUES(@customer_id,'New Employee with Id = ' + CAST(@customer_id as nvarchar(5)) + ' is added at ' + CAST(GETDATE() AS nvarchar(20)))
END
GO

CREATE OR ALTER TRIGGER customeraudit1 ON [NewBigCo].[dbo].[customeraudit]
AFTER INSERT
AS 
BEGIN
	DECLARE @customer_id INT
	SELECT @customer_id = customer_id FROM inserted
	IF @customer_id IS NOT NULL
    PRINT 'AUDIT TRIGGER WORKED SUCCESSFULLY'
	ELSE PRINT 'AUDIT TRIGGER NOT WORKING'
END
GO





