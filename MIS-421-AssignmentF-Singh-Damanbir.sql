
--Question 1
create function dbo.ufnFullName (@FirstName varchar(100), @LastName varchar(100))
returns varchar(50)
as
begin
declare @FullName varchar(50)
set @FullName = ''
if @FirstName is not null and @FirstName <> ''
	begin
		set @FullName = @FirstName
	end
if @LastName is not null and @LastName <> ''
	begin
		set @FullName = @FullName + ' ' + @LastName
	end
return @FullName
end

select FirstName, LastName, dbo.ufnFullName (FirstName, LastName) as FullName 
from tblEmployee;
select FirstName, LastName, dbo.ufnFullName (FirstName, LastName) as FullName 
from tblCustomer;

--Question 2
create function dbo.ufnEmployeeRevenue (@EmployeeID int)
returns money
as
begin
declare @TotalRevenue money
if @EmployeeID is not null
	begin
	select @TotalRevenue = sum(subtotal)
	from tblSale
	where EmployeeID = @EmployeeID
	end
return @TotalRevenue
end 

select EmployeeID, dbo. ufnEmployeeRevenue (EmployeeID) as TotalRevnue from 
tblEmployee

--Question 3
create view vueCustomerSaleSummaryView
as
select tblSale.SaleID, tblSale.SaleDate, dbo.ufnFullName(FirstName, LastName) as CustomerName, si.SaleItemID, i.ItemID, 
i.ItemDescription, i.ItemPrice from tblSale
	inner join tblSaleItem si on tblSale.SaleID = si.SaleID
	inner join tblCustomerQACS c on tblSale.CustomerID = c.CustomerID
	inner join tblItem i on si.ItemId = i.ItemId

select * from vueCustomerSaleSummaryView

--Question 4
Create view vueCustomerSaleHistoryViewV1
as
select tblSale.SaleID, tblSale.SaleDate, dbo.ufnFullName(tblCustomerQACS.FirstName, tblCustomerQACS.LastName)
as CustomerName, sum(tblSaleItem.ItemPrice) as SumItemPrice,
AVG(tblSaleItem.ItemPrice) as AveragePrice
from tblSale inner join
				tblCustomerQACS on tblsale.CustomerID = tblCustomerQACS.CustomerID inner join
				tblSaleItem on tblSale.SaleID = tblSaleItem.SaleID
group by tblsale.SaleID, tblSale.SaleDate, tblCustomerQACS.LastName, tblCustomerQACS.FirstName

select * from vueCustomerSaleHistoryViewV1

--Question 5
create view vueCustomerSaleCheckViewV3
as
	select shv.SaleID, shv.SaleDate, shv.CustomerName from vueCustomerSaleHistoryViewV1 shv
	inner join tblSale s on shv.SaleID = s.SaleID where shv.SumItemPrice <> s.Subtotal

	insert into tblItem(ItemDescription, PurchaseDate, ItemCost, ItemPrice, VendorID) values ('Test item',
'2016-01-01', 10000, 20000, 10);
DECLARE @itemID int;
SELECT @itemID=max(ItemID) from tblItem;
insert into tblSaleItem (SaleID, SaleItemID, ItemID, ItemPrice)
values (1,10, @itemID,20000);
Update tblSaleItem set ItemPrice=20001 where SaleID=1 and SaleItemID=10;

select * from vueCustomerSaleCheckViewV3

--question 6
create view vueEmployeeRevenueView
as
select distinct dbo.ufnFullName (Firstname, LastName) as EmployeeName,
dbo.ufnEmployeeRevenue (e.EmployeeID) as TotalRevenue from tblSale s
inner join tblEmployee e on e.EmployeeID = s.EmployeeID

select * from vueEmployeeRevenueView

IF OBJECT_ID(N'[tblSCAMembership]') is NOT NULL
	DROP Table [tblSCAMembership];

CREATE TABLE [dbo].[tblSCAMembership](
	[MembershipID] [int] IDENTITY(1,1) NOT NULL Primary Key,
	[MembershipNumber] [int] NULL,
	[isCurrentMember] [bit] NULL,
	[MembershipTypeID] [int] NULL,
	[MembershipFeePaidDate] [Date] NULL
)

--Insert the data
SET IDENTITY_INSERT [dbo].[tblSCAMembership] ON 
INSERT [dbo].[tblSCAMembership] ([MembershipID], [MembershipNumber], [isCurrentMember], [MembershipTypeID], [MembershipFeePaidDate]) VALUES (49, 1628, 1, 22, '12/1/2017')
INSERT [dbo].[tblSCAMembership] ([MembershipID], [MembershipNumber], [isCurrentMember], [MembershipTypeID], [MembershipFeePaidDate]) VALUES (50, 5806, 1, 22, '12/1/2017')
INSERT [dbo].[tblSCAMembership] ([MembershipID], [MembershipNumber], [isCurrentMember], [MembershipTypeID], [MembershipFeePaidDate]) VALUES (51, 8131, 1, 22, '12/1/2017')
INSERT [dbo].[tblSCAMembership] ([MembershipID], [MembershipNumber], [isCurrentMember], [MembershipTypeID], [MembershipFeePaidDate]) VALUES (52, 499, 1, 23, '12/1/2018')
INSERT [dbo].[tblSCAMembership] ([MembershipID], [MembershipNumber], [isCurrentMember], [MembershipTypeID], [MembershipFeePaidDate]) VALUES (53, 3638, 1, 23, '12/1/2017')
INSERT [dbo].[tblSCAMembership] ([MembershipID], [MembershipNumber], [isCurrentMember], [MembershipTypeID], [MembershipFeePaidDate]) VALUES (54, 5082, 1, 23, '12/1/2017')
INSERT [dbo].[tblSCAMembership] ([MembershipID], [MembershipNumber], [isCurrentMember], [MembershipTypeID], [MembershipFeePaidDate]) VALUES (55, 6812, 0, 23, '12/1/2016')
INSERT [dbo].[tblSCAMembership] ([MembershipID], [MembershipNumber], [isCurrentMember], [MembershipTypeID], [MembershipFeePaidDate]) VALUES (56, 9854, 0, 23, '12/1/2016')
INSERT [dbo].[tblSCAMembership] ([MembershipID], [MembershipNumber], [isCurrentMember], [MembershipTypeID], [MembershipFeePaidDate]) VALUES (57, 410, 0, 24, '12/1/2016')
INSERT [dbo].[tblSCAMembership] ([MembershipID], [MembershipNumber], [isCurrentMember], [MembershipTypeID], [MembershipFeePaidDate]) VALUES (58, 668, 0, 24, NULL)
INSERT [dbo].[tblSCAMembership] ([MembershipID], [MembershipNumber], [isCurrentMember], [MembershipTypeID], [MembershipFeePaidDate]) VALUES (59, 959, 0, 24, NULL)
INSERT [dbo].[tblSCAMembership] ([MembershipID], [MembershipNumber], [isCurrentMember], [MembershipTypeID], [MembershipFeePaidDate]) VALUES (60, 1345, 0, 24, NULL)
INSERT [dbo].[tblSCAMembership] ([MembershipID], [MembershipNumber], [isCurrentMember], [MembershipTypeID], [MembershipFeePaidDate]) VALUES (61, 1633, 0, 24, NULL)
INSERT [dbo].[tblSCAMembership] ([MembershipID], [MembershipNumber], [isCurrentMember], [MembershipTypeID], [MembershipFeePaidDate]) VALUES (62, 1949, 1, 24, '12/1/2019')
INSERT [dbo].[tblSCAMembership] ([MembershipID], [MembershipNumber], [isCurrentMember], [MembershipTypeID], [MembershipFeePaidDate]) VALUES (63, 2226, 1, 24, '12/1/2019')
INSERT [dbo].[tblSCAMembership] ([MembershipID], [MembershipNumber], [isCurrentMember], [MembershipTypeID], [MembershipFeePaidDate]) VALUES (64, 2281, 1, 24, '12/1/2019')
SET IDENTITY_INSERT [dbo].[tblSCAMembership] OFF

create trigger utrInsteadUpdateTblSCAMembership on tblSCAMembership
instead of update
as
begin
declare @oldMembershipFeePaidDate date, @newMembershipFeePaidDate date
declare @membershipNumber int
select @oldMembershipFeePaidDate = MembershipFeePaidDate from deleted
select @newMembershipFeePaidDate = MembershipFeePaidDate from inserted
select @membershipNumber = MembershipNumber
from inserted

if @oldMembershipFeePaidDate is not null and @oldMembershipFeePaidDate < @newMembershipFeePaidDate
	begin
		update tblSCAMembership set MembershipFeePaidDate=@newMembershipFeePaidDate where MembershipNumber=@membershipNumber
		print 'Membership Number: ' + cast(@membershipNumber as varchar(10)) + ' payment date is ' + cast(@newMembershipFeePaidDate as varchar(20))
		+ '; prior payment date is ' + cast(@oldMembershipFeePaidDate as varchar(20))
	end
else if @oldMembershipFeePaidDate is not null and @oldMembershipFeePaidDate > @newMembershipFeePaidDate
	begin
		print 'Membership Number: ' + cast(@membershipNumber as varchar(10)) + ' new payment date is ' + cast(@newMembershipFeePaidDate as varchar(20))
		+ ' is earlier than prior payment date ' + cast(@oldMembershipFeePaidDate as varchar(20)) + '; No change made'
	end
else
	begin
		update tblSCAMembership set MembershipFeePaidDate=@newMembershipFeePaidDate where MembershipNumber=@membershipNumber
		print 'Membership Number: ' + cast(@membershipNumber as varchar(10)) + ' payment date is ' + cast(@newMembershipFeePaidDate as varchar(20))
		+ '; no prior payment date';
	end
end

Update tblSCAMembership set MembershipFeePaidDate = '11/17/2017'
where MembershipID = 58;

Update tblSCAMembership set MembershipFeePaidDate = '11/17/2017' 
where MembershipID = 56;

Update tblSCAMembership set MembershipFeePaidDate = '11/17/2017' 
where MembershipID = 62;

