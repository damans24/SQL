/*
This stored procedure is called when a sales order with one or more items is created.
The OrderNumber (@orderNum) is passed to the stored procedure with a line item represented by @sku along with 
the warehouseID, quantity, price, and extended price of the ordered item, and order total for the sale.

The stored procedure needs to verify the information to see if the business can fulfill the transaction, including whether
the warehouse has enough inventory for the purchase. 
if the information of the ordered item passes the check, the stored procedure needs to record the transaction information 
in the necesary tables: it needs to record the general sales order information in tblUSPRetailOrder if the order information
does not exist in the table; it also needs to record the item specific information in tblUSPOrderItem table. If anything goes wrong
in recording the information in the tables, all tables need to roll back to the state before the stored procedure starts.

This is a simple stored procedure to demonstrate
1. a stored procedure can be used to implement a business operation (logic)
2. the stored procedure can be reused by different applications, such as a web application, a mobile application, 
   or a point of sales application
3. this stored procedure can be extended to automate more business operations, such as sending the order information 
   to a fulfillment center or the accounting department

See uspOrderTransaction-test scripts.sql for how to call the stored procedure in an application
*/

Create PROCEDURE uspPersistentTran
@sku int, @orderNum int, @warehouseID int, @quantity int, @price float, 
@extendedPrice float, @orderTotal float, @resultCode int OUTPUT, @message varchar(100) OUTPUT

AS
BEGIN
	--use an inclusive BEGIN TRY...END TRY and BEGIN CATCH...END CATCH to catch all unexpected errors
	BEGIN TRY
		SET @message = '';
		BEGIN TRANSACTION
			
			--print the values for debugging
			PRINT 'Warehouse ID ' + cast(@warehouseID as varchar(10));
			PRINT 'SKU ' + cast(@sku as varchar(10));
			PRINT 'Ordered quantity ' + CAST(@quantity as varchar(10));
			--Check if the item (SKU) exists in the warehouse: 
			--decalre a variable @quantityOnHand, use a SELECT statement to get quantity on hand 
			--for the item (SKU) in the warehouse, then use the result to determine if the item exists in the warehouse
			DECLARE @quantityOnHand int;
			select @quantityOnHand=QuantityOnHand from tblUSPInventory where WarehouseID=@warehouseID and SKU=@sku
			--If it does not exist, stop the transaction and return an error code. A global varible may be used.
			--Here, we declare a variable to store how many records affected by the above SQL DML statement, which is
			--stored in the global variable @@ROWCOUNT.
			--There are other options too, e.g., you can use IF @quantityOnHand IS NULL to determine if the item exists
			--in the warehouse

			DECLARE @count int;
			SET @count=@@ROWCOUNT
			if @count<=0
			begin
				set @resultCode=-1
				set @message='No such SKU ' + CAST(@sku as varchar(10)) + ' in the warehouse ' + CAST(@warehouseID as varchar(10))
				rollback transaction
				return 
			end
			PRINT 'Quantity on hand=' + CAST(@quantityOnHand as varchar(100));
			
			--Check if we have enough quantity of the item available for the order.
			--If not, stop the transaction and return an error code. We check dissatisfying condition first because if the 
			--condition is not satisfying, we will not proceed.
			if @quantityOnHand<=0 or @quantityOnHand<@quantity
			begin
				print 'Not enough inventory'
				set @resultCode=-2
				set @message='Not enough inventory for the order'
				rollback transaction
				return
			end
			--If we have enough quantity of the item, reduce the available number of SKU in inventory: use an UPDATE statement
			PRINT 'Update the tblUSPInventory'
			update tblUSPInventory set QuantityOnHand=QuantityOnHand-@quantity, QuantityOnOrder=QuantityOnOrder+@quantity
			where WarehouseID=@warehouseID and SKU=@sku		
			PRINT 'Check the tblUSPRetailOrder table'
			--Record the transaction in tblUSPRetailOrder
			--Check if the order is already stored in the tblUSPRetailOrder table. 
					
			SELECT @count = COUNT(*) from tblUSPRetailOrder where OrderNumber = @orderNum;
			--If the order does not exist in the table, add it; otherwise do nothing to tblUSPRetailOrder. 
			if @count<1
			begin
				print 'Insert into tblUSPRetailOrder table'
				begin try
					insert into tblUSPRetailOrder (OrderNumber, StoreNumber, StoreZip, OrderMonth, OrderYear, OrderTotal)
					values (@orderNum, 10, '98110', 'January', '2015', @orderTotal)
				end try
				begin catch
					set @resultCode=-3
					set @message='Issue in inserting into tblUSPRetailOrder table'
					rollback transaction
					return
				end catch
			end				
			PRINT 'Insert into the tblUSPOrderItem table'
			begin try
				insert into tblUSPOrderItem (OrderNumber, SKU, Quantity, Price, ExtendedPrice)
				values (@orderNum, @sku, @quantity, @price, @extendedPrice)
			end try
			begin catch
				set @resultCode=-4
				set @message='Issue in inserting into tblUSPOrderItem table'
				rollback transaction
				return
			end catch
			--If everyting is fine. Set the code and message and commit the transaction
			--set the result code and message
			SET @resultCode=1;
			SET @message='Transaction item recorded';
			COMMIT TRANSACTION;
			
	END TRY --this is the inclusive BEGIN TRY...END TRY
	BEGIN CATCH
		SET @resultCode=-5;
		--use the built-in ERROR_MESSAGE() function to print what happened
		SET @message= ERROR_MESSAGE();
		PRINT 'unexpected error: ' + ERROR_MESSAGE();
	END CATCH
	
END
GO