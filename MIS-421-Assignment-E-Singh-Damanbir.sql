--Damanbir Singh
--MIS 421
--Individual Assignment E

Select * From tblItem

Select * From tblSale
Select * From tblSaleItem

-- Question 1
Update tblItem
Set ItemDescription = 'Desk Lamps'
Where ItemDescription = 'Desk Lamp'

Select * From tblPersonNames

Insert Into tblSale(CustomerID, EmployeeID, SaleDate, Subtotal, Tax, Total)
Values (3, 3, '2014-05-27', 1500, 100, 1600)

Insert Into tblSaleItem(SaleID, SaleItemID, ItemID, ItemPrice)
Values (4, 16, 27, 1600)

Delete From tblSale
Where tblSale.SaleID = 23

Create View vueSaleSummary As
Select tblSale.SaleID, tblSale.SaleDate, tblSaleItem.SaleItemID, tblSaleItem.ItemID, tblItem.ItemDescription, tblItem.ItemPrice
From tblSale, tblSaleItem, tblItem
Where tblSale.SaleID = tblSaleItem.SaleItemID and tblSaleItem.SaleItemID = tblItem.ItemID

Select * From vueSaleSummary

-- Question 2
Create FUNCTION dbo.ufnGetFirstName (@fullname varchar(100))
returns varchar(50)
AS
BEGIN
--declare the local variable: lastName
DECLARE @firstName varchar(50);
--declare the index variable to find the index of the separator that separates last
--name from first name
Declare @seperatorIndex Int;
--get the separator index value
--check if the default separator (,) exists
Set @seperatorIndex = Charindex(',', @fullname);
If @seperatorIndex > 0
		Begin
			Set @firstName = Substring(@fullname, @seperatorIndex+2, 100);
End
--if it does, use the substring function to find the last name
--if it does not, let's assume the space is the separator and the full name format 
--is FirstName LastName
--find the index for the space, then find the last name
Else
		Begin
			Set @seperatorIndex = CHARINDEX(' ', @fullname)
			Set @firstName = SUBSTRING(@fullname, 1, @seperatorIndex-1);
	End
--return the last name
RETURN @firstName
END

SELECT FullName, dbo.ufnGetFirstName (FullName) as FirstName, dbo.ufnGetLastName 
(FullName) as LastName FROM tblPersonNames;

-- Question 3

CREATE FUNCTION dbo.ufnGetOrderGrandTotalWithoutDiscount (@orderID int)
returns float
AS
BEGIN
--Declare local variables: 
--@grandTotal float, @unitPrice float, @quantity int, @discount float
Declare @grandTotal float, @unitPrice float, @quantity int;
--Initiate the local variables
Set @grandTotal=0;
Set @unitPrice=0;
Set @quantity=0;
--Declare a cursor to get all products from an order
DECLARE cs CURSOR FOR select UnitPrice, Quantity from tblPSMOrderDetail 
where OrderID=@orderID;
--Open the cursor
 OPEN cs;
--Fetch UnitPrice, Quantity, and Discount into @unitPrice, @quantity, and @discount
FETCH next from cs INTO @unitPrice, @quantity
--Use @@FETCH_STATUS to check if there are more records in the cursor
--@@FETCH_STATUS=0 --> it successfully fetched a row; @@FETCH_STATUS=-1 --> no more
WHILE @@FETCH_STATUS=0
BEGIN
		--calculate the grand total without discount
		Set @grandTotal = @grandTotal + @unitPrice * @quantity
		--fetch next row from the OrderDetail table with the same OrderID
		FETCH next from cs INTO @unitPrice, @quantity
END
--close the cursor
CLOSE cs;
--deallocate the cursor in memory
DEALLOCATE cs;
--return @grandTotal
Return @grandTotal;
END

select OrderID, dbo.ufnGetOrderGrandTotalWithoutDiscount(OrderID) as 'Grand Total without
discount' from tblPSMOrder;

Select * From tblPSMOrder