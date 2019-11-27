--creation and use of database

create database Bikes;
use Bikes;


-- creation of tables

-- create product table
create table Product
(ProductID varchar(50) NOT NULL,
ProductName varchar(50),
Cost float,
WholeSalePrice float,
MSRP varchar(50),
constraint ProductPK Primary key (ProductID));


-- create customer table
create table Customer 
(CustomerID varchar(50) NOT NULL,
CustomerFirstName varchar(50),
CustomerLastName varchar(50),
CustomerAddress varchar(50),
CustomerAge int,
CustomerExperience varchar(50),
constraint CustomerPK Primary key (CustomerID));


-- create department table
create table Department  
(DepartmentID varchar(50) NOT NULL,
DepartmentName varchar(50),
constraint DepartmentPK Primary key (DepartmentID));


-- create region table
create table Region  
(RegionID varchar(50) NOT NULL,
RegionName varchar(50),
constraint RegionPK Primary key (RegionID));


-- create employee table
create table Employee
(EmployeeID varchar(50) NOT NULL,
EmployeeFirstName varchar(50),
EmployeeLastName varchar(50),
DepartmentID varchar(50),
EmployeeAddress varchar(50),
Gender varchar(10),
EmployeeBirthDate date,
Salary float,
RegionID varchar(50),
constraint EmployeePK Primary key (EmployeeID),
constraint DepartmentFK1 foreign key (DepartmentID) references Department(DepartmentID),
constraint RegionFK2 foreign key (RegionID) references Region(RegionID));


-- create table salesorder
create table SalesOrder 
(OrderID varchar(50),
PODate varchar(50),
ProductID varchar(50),
CustomerID varchar(50),
CustomerPO varchar(50),
EmployeeID varchar(50),
Quantity int,
UnitPrice float,
constraint OrderPK Primary key (OrderID),
constraint ProductFK1 foreign key (ProductID) references Product(ProductID),
constraint CustomerFK2 foreign key (CustomerID) references Customer(CustomerID),
constraint EmployeeFK3 foreign key (EmployeeID) references Employee(EmployeeID));


-- Bulk insertion of data into tables
-- Bulk insert table product data
BULK
INSERT Product
FROM 'C:\Users\it7529\Documents\MounikaT_P3\Data_Files\Product.txt'
WITH
(FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n')
GO

-- Bulk insert table customer data
BULK
INSERT Customer
FROM 'C:\Users\it7529\Documents\MounikaT_P3\Data_Files\Customer.txt'
WITH
(FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n')
GO

-- Bulk insert table department data
BULK
INSERT Department
FROM 'C:\Users\it7529\Documents\MounikaT_P3\Data_Files\Department.txt'
WITH
(FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n')
GO

-- Bulk insert table region data
BULK
INSERT Region
FROM 'C:\Users\it7529\Documents\MounikaT_P3\Data_Files\Region.txt'
WITH
(FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n')
GO

-- Bulk insert table employee data
BULK
INSERT Employee
FROM 'C:\Users\it7529\Documents\MounikaT_P3\Data_Files\Employee.txt'
WITH
(FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n')
GO

-- Bulk insert table salesorder data
BULK
INSERT SalesOrder
FROM 'C:\Users\it7529\Documents\MounikaT_P3\Data_Files\SalesOrder.txt'
WITH
(FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n')
GO

-- Queries
-- Query 1- Display the total sales in each region for products Extreme Mountain Bike, Extreme Plus Mountain Bike,
-- and Extreme Ultra Mountain Bike. Total Sales is quantity times unit price for each transaction.

select distinct(Region.RegionName), (sum(A.UnitPrice*A.Quantity))
from ( Select * from SalesOrder where ProductID in ('30000100','30000200','30000300'))A inner join Employee on A.EmployeeID = Employee.EmployeeID 
inner join Region on Region.RegionID = Employee.RegionID group by Region.RegionName;


 -- Query 2- Display the ProductID, ProductName, and Cost of the products which are NOT purchased by the customer Dan Connor.

select distinct(Product.ProductID), Product.ProductName, Product.Cost
from Product 
where ProductID NOT IN 
	(select Product.ProductID
	from Customer inner join  SalesOrder
	on Customer.CustomerID = SalesOrder.CustomerID inner join Product on Product.ProductID = SalesOrder.ProductID
	where Customer.CustomerFirstName = 'Dan' and Customer.CustomerLastName = 'Connor');


-- Query 3-Display the CustomerID, CustomerFirstName, CustomerLastName, CustomerAge of the customers whose age is above average and has created more than 1000 OrderIDs. 
--Your query should also display the average age as ‘AvgAge’ of the customers.

select Customer.CustomerID, Customer.CustomerFirstName, Customer.CustomerLastName, Customer.CustomerAge,(select AVG(CustomerAge) from Customer)as 'AvgAge'
from  Customer inner join SalesOrder B on Customer.CustomerID = B.CustomerID 
where Customer.CustomerAge> (select AVG(CustomerAge) as 'AvgAge'
from Customer) 
group by Customer.CustomerID ,Customer.CustomerFirstName, Customer.CustomerLastName,Customer.CustomerAge
having count(B.OrderID)>1000;




--Query 4- Display the maximum sales by a customer in each quarter.

select top 1

(select TOP 1 sum(SO.Quantity*SO.UnitPrice)
from
SalesOrder SO inner join Customer C
on SO.CustomerID = C.CustomerID
WHERE month(SO.PODate) > 0 and month(SO.PODate) <=3
group by C.CustomerID
order by sum(SO.Quantity*SO.UnitPrice) DESC)  as 'Max_Sales_Q1',

(select TOP 1 sum(SO.Quantity*SO.UnitPrice)
from
SalesOrder SO inner join Customer C
on SO.CustomerID = C.CustomerID
WHERE month(SO.PODate) > 3 and month(SO.PODate) <=6
group by C.CustomerID
order by sum(SO.Quantity*SO.UnitPrice) DESC)  as 'Max_Sales_Q2',

(select TOP 1 sum(SO.Quantity*SO.UnitPrice)
from
SalesOrder SO inner join Customer C
on SO.CustomerID = C.CustomerID
WHERE month(SO.PODate) > 6 and month(SO.PODate) <=9
group by C.CustomerID
order by sum(SO.Quantity*SO.UnitPrice) DESC)  as 'Max_Sales_Q3',

(select TOP 1 sum(SO.Quantity*SO.UnitPrice)
from
SalesOrder SO inner join Customer C
on SO.CustomerID = C.CustomerID
WHERE month(SO.PODate) > 9 and month(SO.PODate) <=12
group by C.CustomerID
order by sum(SO.Quantity*SO.UnitPrice) DESC)  as 'Max_Sales_Q4'

from
SalesOrder SO inner join Customer C
on SO.CustomerID = C.CustomerID




-- Quer 5- Display the ProductName and ‘Over Avg Profit’ for the products whose total profit from all the transactions is above the average profit. 
-- The profit is given by Quantity * (UnitPrice – Cost). 

select prod1.productname, sum(so1.quantity * (so1.unitprice - prod1.cost)) "Over_Avg_Profit"
from product prod1,salesorder so1 ,
	  (select avg(query1.profit) "avgprofit"
	  from(select prod.productname, sum(so.quantity * (so.unitprice - prod.cost)) "profit"
			from product prod, salesorder so
where so.productid= prod.productid
group by prod.productname) query1) avgerageprofit
where so1.productid= prod1.productid
group by prod1.productname, avgerageprofit.avgprofit
having  sum(so1.quantity * (so1.unitprice - prod1.cost)) > avgerageprofit.avgprofit;



