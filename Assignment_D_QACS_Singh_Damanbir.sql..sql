create table tblCustomerQACS(
CustomerID Int identity(1,1) not null primary key,
LastName nvarchar(250) null,
FirstName nvarchar(250) null,
Address nvarchar(250) null,
City nvarchar(250) null,
State nvarchar(250) null,
ZIP nvarchar(250) null,
Email nvarchar(250) null unique)

create table tblEmployee(
EmployeeID int identity(1,1) not null primary key,
LastName nvarchar(250) null,
FirstName nvarchar(250) null,
Phone nvarchar(250) null,
Email nvarchar(250) null unique)

create table tblVendor(
VendorId int identity(1,1) not null primary key,
CompanyName nvarchar(250) null,
ContactLastName nvarchar(250) null,
ContactFirstName nvarchar(250) null,
Address nvarchar(250) null,
City nvarchar(250) null,
State nvarchar(250) null,
ZIP nvarchar(250) null,
Phone nvarchar(250) null,
Fax nvarchar(250) null,
Email nvarchar(250) null unique)

create table tblItem(
ItemId int identity(1,1) not null primary key,
ItemDescription nvarchar(250) null,
PurchaseDate nvarchar(250) null,
ItemCost nvarchar(250) null,
ItemPrice nvarchar(250) null,
VendorID int not null,
constraint VendorSubType FOREIGN KEY(VendorID) 
references tblVendor(VendorID)  
on update no action
on delete cascade)

create table tblSale(
SaleID int identity(1,1) not null primary key,
CustomerID int not null,
EmployeeID int not null,
SaleDate nvarchar(250) null,
Subtotal nvarchar(250) null,
Tax nvarchar(250) null,
Total nvarchar(250) null,
Constraint tblSaleFK1 foreign key(CustomerID)
references tblCustomerQACS(CustomerID)
on update no action
on delete no action,
constraint tblSaleFK2 foreign key(EmployeeID)
references tblEmployee(EmployeeID)
on update no action
on delete no action)

create table tblSaleItem(
SaleID int not null,
SaleItemID int not null,
ItemId int not null,
ItemPrice nvarchar(250) null,
Constraint tblSaleItemPK primary key(SaleID, SaleItemID),
constraint tblSaleItemFK1 foreign key(SaleID)
references tblSale(SaleID)
on update no action
on delete cascade,
constraint tblSaleItemFK2 foreign key(ItemID)
references tblItem(ItemID)
on update no action
on delete cascade)


insert into tblCustomerQACS(LastName, FirstName, Address, City, State, ZIP, Email)
select LastName, FirstName, Address, City, State, ZIP, Email
from Customer_Original

insert into tblEmployee(LastName, FirstName, Phone, Email)
select LastName, FirstName, Phone, Email
from Employee_Original

insert into tblVendor(CompanyName, ContactLastName, ContactFirstName, Address, City, State, ZIP, Phone, Fax, Email)
select CompanyName, ContactLastName, ContactFirstName, Address, City, State, ZIP, Phone, Fax, Email
from Vendor_Original

insert into tblItem(ItemDescription, PurchaseDate, ItemCost, ItemPrice, VendorID)
select ItemDescription, PurchaseDate, ItemCost, ItemPrice, VendorID
from Item_Original

insert into tblSale(CustomerID, EmployeeID, SaleDate, Subtotal, Tax, Total)
select CustomerID, EmployeeID, SaleDate, SubTotal, Tax, Total
from Sale_Original

insert into tblSaleItem(SaleID, SaleItemID, ItemId, ItemPrice)
select SaleID, SaleItemID, ItemID, ItemPrice
from SaleItem_Original