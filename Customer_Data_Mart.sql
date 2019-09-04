--Customer Mart SQL Code

Create Table Customer (
Customer_ID varchar(12) Primary key,
Customer_Name varchar(255),
Customer_Address varchar(255),
Customer_State varchar(32),
Customer_Region varchar(32),
Customer_Priority int
)

Create Table Customer_Contacts(
Contact_ID int Primary key,
Customer_ID varchar(12) references Customer(Customer_ID),
First_Name varchar(16),
Last_Name varchar(16),
Phone varchar(12),
Email varchar(32),
C_Address varchar(255)
)

Create Table TimeTable (
Time_ID int Primary Key,
YearOf int
)

Create Table Employee(
Employee_ID varchar(12) Primary key,
First_Name varchar(16),
Last_Name varchar(16),
Phone varchar(12),
Email varchar(32),
E_Address varchar(255),
SSN varchar(10),
Salary decimal(10,2)
)

Create Table Current_FY_Data (
Customer_ID varchar(12) references Customer(Customer_ID),
Employee_ID varchar(12) references Employee(Employee_ID),
Contracted_Amount decimal(10,2),
Leads_Amount decimal(10,2),
Proposals_Amount decimal(10,2),
WinPercent decimal(10,2))

Create Table Annual_Data (
Customer_ID varchar(12) references Customer(Customer_ID),
Employee_ID varchar(12) references Employee(Employee_ID),
Time_ID int references TimeTable(Time_ID),
Workbooked_Amount decimal(10,2),
Revenue_Amount decimal(10,2),
Proposals_Amount decimal(10,2))

Create Table TopLeads (
Customer_ID varchar(12) references Customer(Customer_ID),
Employee_ID varchar(12) references Employee(Employee_ID),
Lead_Name varchar(255),
Lead_Amount decimal(10,2),
Bid_Date DATE,
WinPercent decimal(10,2))

Create Index i1 on TopLeads(Customer_ID)
Create Index i2 on Annual_Data(Customer_ID)
Create Index i3 on Current_FY_Data(Customer_ID)
Create Index i4 on Annual_Data(Time_ID)

--Creating Data Masking

Insert into Customer values (1,'MDOT','250 Comm Ave, Boston, MA', 'Massachusetts', 'Northeast', 1)
Insert into Customer_Contacts values(1,1,'Jeff', 'Donahue', '978-555-0000','donahuej@bu.edu', '274 Comm Ave, Boston, MA')

Select * from Customer_Contacts

Alter Table Customer_Contacts
ALTER Column Phone ADD MASKED WITH (FUNCTION = 'default()')


Alter Table Customer_Contacts
ALTER Column Email ADD MASKED WITH (FUNCTION = 'default()')


Alter Table Customer_Contacts
ALTER Column C_Address ADD MASKED WITH (FUNCTION = 'default()')


Alter Table Employee
ALTER Column E_Address ADD MASKED WITH (FUNCTION = 'default()')

Alter Table Employee
ALTER Column Phone ADD MASKED WITH (FUNCTION = 'default()')

GO
  CREATE USER user4 WITHOUT LOGIN;
  GRANT SELECT ON OBJECT::dbo.Customer_Contacts TO user4;  
  GO

EXECUTE AS USER = 'user4';
Select * from Customer_Contacts

CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Password123!'
GO

select name, is_master_key_encrypted_by_server from sys.databases where name= 'CustomerMart'

CREATE CERTIFICATE EmployeeSSN 
   WITH SUBJECT = 'Employee Social Security Numbers';  
GO  

CREATE SYMMETRIC KEY SSN_Key_01  
    WITH ALGORITHM = AES_256  --advanced encryption standard 256
    ENCRYPTION BY CERTIFICATE EmployeeSSN;  
GO  


INsert into Employee values (1,'Jeff','Donahue','987-652-1234','donahuej@bu.edu','123 Comm AVe, Boston, MA','123-45-678',50000)
INsert into Employee values (2,'Mark','Smith','987-000-1234','msmith@bu.edu','1200 Comm AVe, Boston, MA','123-45-008',50000)

	select * from Employee;

	update Employee
	set SSN_ENCRYPT = NULL

UPDATE CUSTOMER
set SSN='001-11-1111' where CUSTOMER_ID=1
UPDATE CUSTOMER
set SSN='002-22-1112' where CUSTOMER_ID=2
	
ALTER TABLE Employee
	ADD SSN_ENCRYPT  varbinary(128);	

ALTER TABLE Employee
drop column SSN_ENCRYPT


OPEN SYMMETRIC KEY SSN_Key_01  
   DECRYPTION BY CERTIFICATE EmployeeSSN;

UPDATE Employee
SET SSN_ENCRYPT = EncryptByKey(Key_GUID('SSN_Key_01'), SSN);  
GO  



SELECT Employee.*,
    CONVERT(varchar, DecryptByKey(SSN_ENCRYPT))   
    AS 'Decrypted SSN'  
    FROM Employee;  



