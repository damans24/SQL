--Question #1

Select * from Products

--Question #2

Select CategoryID, CategoryName, Picture, Description
from Categories

--Question #3

Select Description, CategoryID
from Categories 

--Question #4

select distinct ProductID
from OrderDetails

--question #5

select *
from Products
where UnitsInStock < 20

--question #6

select CategoryName, ProductName
from Products
where UnitsInStock = 0 and UnitsOnOrder > 10

--question #7

select CategoryName, ProductID, ProductName
from Products
where UnitsInStock = 0 or UnitsOnOrder > UnitsInStock
order by CategoryName desc

--question#8

select CategoryName, ProductID, ProductName, UnitsInStock
from Products
where UnitsInStock between 1 and 10;

--question#9

select distinct CategoryName, ProductName 
from Products
where ProductName like 'ch%''

--question#10

select distinct CategoryName, ProductName 
from Products
where ProductName like '%Tof%''

--question #11

select distinct CategoryName, ProductName
from Products
where ProductName like '%s____';

--question#12

select concat(rtrim(CategoryName),'-',(ProductName)) as Category_Product
from Products;

--question#13

select sum(UnitsInStock) as Sum_of_Units,
avg(UnitsInStock) as Avg_of_Units,
max(UnitsInStock) as Max_of_Units,
min(UnitsInStock) as Min_of_Units
from Products;

--question#14

--/* the COUNT function counts up how many rows there are,
-- and the SUM function adds up all the values in a column*/

--question#15

select ProductID, count(ProductID) as NumOfItemsOrdered
from OrderDetails
group by ProductID

--question#16

select CategoryID, CategoryName,
sum(UnitsInStock) as TotalProductsOnHand
from Products
where UnitsInStock <= 100
group by CategoryID, CategoryName
having sum(UnitsInStock) > 200
order by TotalProductsOnHand desc;

--question#17


--/*the WHERE clause was applied first because the UnitsInStock need to be less than or equal to 100 and then the HAVING clause should be applied. 
--if the WHERE clause is not applied, then it will show all UnitsInStock, not just less than or equal to 100*\
