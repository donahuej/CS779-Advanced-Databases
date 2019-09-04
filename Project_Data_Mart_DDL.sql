Create Table Customer (
    Customer_ID varchar(32) PRIMARY KEY,
    Customer_Name varchar(255),
    Customer_State varchar(32),
    Customer_Region varchar(32)
    )

 

create table Project (
    Project_ID varchar(12) Primary Key,
    Project_Name varchar(255),
    Project_Start_Date Date,
    Project_End_Date Date,
    Project_Manager varchar(64),
    Customer_ID varchar(32) references Customer(Customer_ID)
    )

   

Create Table Employee (
    Employee_ID varchar(12) Primary Key,
    Employee_First varchar(32),
    Employee_Last varchar(32),
    Employee_Office varchar(32),
    Employee_Rate decimal(10,2)
    )

 

Create Table Subcontractor (
    Subcontractor_ID varchar(32) Primary Key,
    Sub_Name varchar(255),
    Sub_Location varchar(255),
    Sub_Phone varchar(16),
    Sub_Email varchar(32)
    )

   

Create Table DailyTime (
    DayTime_ID int Primary Key, --This is just the day count from a given point
    DateOfRecord Date,
    MonthOfRecord int,
    QuarterOfRecord int,
    YearOfRecord int
    )

 

Create Table MonthlyTime (
    MonthTime_ID int Primary Key, --This is just the month count from a given point
    MonthOfRecord int,
    QuarterOfRecord int,
    YearOfRecord int
    )

   

Create Table Account (
    Account_ID varchar(32) Primary Key,
    Account_Name varchar(255),
    Account_Group varchar(255)
    )

   

Create Table Processed_Summary (
    Project_ID varchar(12) references Project(Project_ID),
    Account_ID varchar(32) references Account(Account_ID),
    Budget decimal(10,2),
    Cost_Spent decimal(10,2),
    Remaining decimal(10,2),
    PercentOf decimal(3,2),
    Primary Key(Project_ID, Account_ID)
    )

   

Create Table Processed_History (
    Project_ID varchar(12) references Project(Project_ID),
    Account_ID varchar(32) references Account(Account_ID),
    Time_ID int references MonthlyTime(MonthTime_ID),
    Cost_Spent decimal(10,2),
    Primary key(Project_ID, Account_ID, Time_ID)
    )

   

Create Table Project_Comment_Field (
    Comment_ID int Primary Key,
    Project_ID varchar(12) references Project(Project_ID),
    Time_ID int references DailyTime(DayTime_ID),
    Comment varchar(255),
    Author varchar(64)
    )

   

Create Table Processed_Hours (
    Project_ID varchar(12) references Project(Project_ID),
    Time_ID int references MonthlyTime(MonthTime_ID),
    Employee_ID varchar(12) references Employee(Employee_ID),
    Total_Hours decimal(10,1),
    Revenue decimal(10,2),
    Primary Key(Project_ID,Time_ID,Employee_ID)
    )

   

Create Table Expenses (
    Expense_ID varchar(12) Primary Key,
    Project_ID varchar(12) references Project(Project_ID),
    Employee_ID varchar(12) references Employee(Employee_ID),
    Time_ID int references DailyTime(DayTime_ID),
    Account_ID varchar(32) references Account(Account_ID),
    Expense_Amount decimal(10,2),
    Comment varchar(255),
    CurrStatus varchar(12)
    )

   

Create Table Subcontractor_Fact (
    Project_ID varchar(12) references Project(Project_ID),
    Subcontractor_ID varchar(32) references Subcontractor(Subcontractor_ID),
    Time_ID int references MonthlyTime(MonthTime_ID),
    Account_ID varchar(32) references Account(Account_ID),
    Sub_Amount decimal(10,2)
    )

   

--Unprocessed Table

 

Create Table Unprocessed_Hours (
    Line_ID int Primary Key,
    Project_ID varchar(12) references Project(Project_ID),
    Employee_ID varchar(12) references Employee(Employee_ID),
    Account_ID varchar(32) references Account(Account_ID),
    DateOfRecord Date,
    Rate decimal(10,2),
    Hours decimal(10,1),
    Cost decimal(10,2),
    Role varchar(64),
    Comment varchar(255),
    ProcessedStatus varchar(12)
    )



--Indexes

Create index i1 on Processed_Summary(Project_ID);
Create index i2 on Processed_History(Project_ID);
Create index i3 on Processed_Hours(Project_ID);
Create index i4 on Processed_Summary(Project_ID);
Create index i5 on Expenses(Project_ID);
Create index i6 on Subcontractor_Fact(Project_ID);
Create index i7 on Project_Comment_Field(Project_ID);
Create index i10 on Unprocessed_Hours(Project_ID);

Create index i8 on Processed_History(Time_ID);
Create index i9 on Unprocessed_Hours(DateOfRecord);


Create View Unprocessed_Summary AS
Select Project_ID, Account_ID, 0 as Budget, Cost, 0 as Remaining, 0 as PercentOf
from Unprocessed_Hours
--Unprocessed hours have no budgets and do not directly effect the official amount remaining or percentage until they become processed, so we zero out those columns

Create View Unprocessed_Hours_View AS
Select Project_ID, Account_iD, NULL as Time_ID, Cost
from Unprocessed_Hours
where DateOfRecord >= DATEADD(mm, DATEDIFF(mm, 0, GETDATE()) - 1, 0)
--Select all data from the current month since this is the only unprocessed month, the time_ID is going to be null so it can be easily pulled out in the reporting product

Create View Unprocessed_Hours_2 AS
 Select Project_ID,NULL as Time_ID,Employee_ID,Hours,Hours*Rate as Revenue
 from Unprocessed_Hours



Create View Summary_Final AS
Select * from Processed_Summary
UNION 
Select * from Unprocessed_Summary

Create View History_Final AS
Select * from Processed_History
UNION 
Select * from Unprocessed_Hours_View

Create View Hours_Final as
Select * from Processed_Hours
UNION 
Select * from Unprocessed_Hours_2


Create Table Timesheet_History (
    Line_ID int Primary Key,
    Project_ID varchar(12) references Project(Project_ID),
    Employee_ID varchar(12) references Employee(Employee_ID),
    Account_ID varchar(32) references Account(Account_ID),
    DateOfRecord Date,
    Rate decimal(10,2),
    Hours decimal(10,1),
    Cost decimal(10,2),
    Role varchar(64),
    Comment varchar(255),
    ProcessedStatus varchar(12)
    )


--Sample stored Procedure for visual studio

Create procedure LoadProcessedHours
@ProjectID varchar(12),
@Time_ID int,
@Employee_ID varchar(12),
@Total_Hours decimal(10,1),
@Revenue decimal(10,2)
as Begin
insert into Processed_Hours
values(@ProjectID,@Time_ID,@Employee_ID,@Total_Hours,@Revenue)
End

Exec LoadProcessedHours


Insert into Timesheet_History
Select * from Unprocessed_Hours
where DateOfRecord <= DATEADD(d, -1095, getdate())
--3 years is 1095 days
