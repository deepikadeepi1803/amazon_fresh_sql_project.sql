create database amazons;
use amazons;

describe customers;
describe products;
describe suppliers;
describe orders;
describe order_details;
describe reviews;

##TASK 3
## Retrieve all customers from a specific city.

select * from customers;

select distinct city from customers;

select * from customers
where city = 'bettyport';

select distinct category from products;

select * from products
where category = 'fruits';


##TASK 4
##Data Definition Language (DDL) and Constraints
-- check customerid primary key

describe customers;

-- validate age
select *
from customers
where age is null or age <= 17;

-- validate duplicate names
select
    name,
    count(*) as total
from customers
group by name
having count(*) > 1;

-- change name datatype
alter table customers
modify column name varchar(100);

-- add age constraints
alter table customers
modify column age int not null,
add constraint chk_customer_age check (age > 17);


##Data Manipulation Language (DML) 
##Task 5
##Insert 3 new rows into the Products table using INSERT statements

describe products;

select * from products;

insert into products
(productid, productname, category, subcategory, priceperunit, stockquantity, supplierid)
values
('a1b2c3d4-1111-4444-8888-123456789001', 'mango', 'fruits', 'sub-fruits-1', 120.00, 100, null),
('b2c3d4e5-2222-4444-8888-123456789002', 'orange', 'fruits', 'sub-fruits-2', 60.00, 150, null),
('c3d4e5f6-3333-4444-8888-123456789003', 'milk', 'dairy', 'sub-dairy-2', 35.00, 80, null);

select * from products
where productid in (
'a1b2c3d4-1111-4444-8888-123456789001',
'b2c3d4e5-2222-4444-8888-123456789002',
'c3d4e5f6-3333-4444-8888-123456789003'
);

##Task 6
##Update the stock quantity of a product where ProductID matches a specific ID.

update products
set stockquantity = 200
where productid = 'a1b2c3d4-1111-4444-8888-123456789001';

select productid, productname, stockquantity
from products
where productid = 'a1b2c3d4-1111-4444-8888-123456789001';

##Task 7
##Delete a supplier from the Suppliers table where their city matches a specific 

select distinct city from suppliers;

select * from suppliers
where city = 'south ana';

select * from products
where supplierid = '03ec3130-f542-432e-b173-f110efd69026';

select * from suppliers
where supplierid = '03ec3130-f542-432e-b173-f110efd69026'
and city = 'south ana';

delete from suppliers
where supplierid = '03ec3130-f542-432e-b173-f110efd69026'
and city = 'south ana'
and not exists (
    select 1
    from products
    where products.supplierid = suppliers.supplierid
);

 ##SQL Constraints and Operators
##Task 8
##Use SQL constraints to:
##Add a CHECK constraint to ensure that ratings in the Reviews table are 
##between 1 and 5

select *
from reviews
where rating < 1 or rating > 5 or rating is null;

select constraint_name, check_clause
from information_schema.check_constraints
where constraint_schema = 'amazons'
and constraint_name = 'chk_review_rating';

##Add a DEFAULT constraint for the PrimeMember column in the Customerstable (default value: "No")
alter table customers
alter column primemember set default 'no';

show create table customers;


##Clauses and Aggregations
##Task 9
##Write queries using:

##WHERE clause to find orders placed after 2024-01-01.


##HAVING clause to list products with average ratings greater than 4.
select *
from orders
where orderdate > '2024-01-01';

select
p.productid,
p.productname,
avg(r.rating) as averagerating
from products p
join reviews r
on p.productid = r.productid
group by p.productid, p.productname
having avg(r.rating) > 4;

##GROUP BY and ORDER BY clauses to rank products by total sales. 

select
p.productid,
p.productname,
sum(od.quantity * od.unitprice) as totalsales
from products p
join order_details od
on p.productid = od.productid
group by p.productid, p.productname
order by totalsales desc;

##Task 10
##Identifying High-Value Customers
##Scenario:
##Amazon Fresh wants to identify top customers based on their total spending. We will:
##Calculate each customer's total spending.
select
    c.customerid,
    c.name,
    sum(o.orderamount) as totalspending
from customers c
join orders o
    on c.customerid = o.customerid
group by c.customerid, c.name;

##Rank customers based on their spending.
select
    c.customerid,
    c.name,
    sum(o.orderamount) as totalspending,
    rank() over (
        order by sum(o.orderamount) desc
    ) as customerrank
from customers c
join orders o
    on c.customerid = o.customerid
group by c.customerid, c.name
order by totalspending desc;

##Identify customers who have spent more than ₹5,000. 
select
    c.customerid,
    c.name,
    sum(o.orderamount) as totalspending
from customers c
join orders o
    on c.customerid = o.customerid
group by c.customerid, c.name
having sum(o.orderamount) > 5000
order by totalspending desc;


##Complex Aggregations and Joins
##task 11
##use sql to:
##join the orders and order_details tables to calculate total revenue per order.

select
    o.orderid,
    sum(od.quantity * od.unitprice) as totalrevenue
from orders o
join order_details od
    on o.orderid = od.orderid
group by o.orderid
order by totalrevenue desc;

##identify customers who placed the most orders in a specific time period.

select
    c.customerid,
    c.name,
    count(o.orderid) as totalorders
from customers c
join orders o
    on c.customerid = o.customerid
where o.orderdate >= '2024-01-01'
and o.orderdate < '2025-01-01'
group by c.customerid, c.name
order by totalorders desc;

##find the supplier with the most products in stock.

select
    s.supplierid,
    s.suppliername,
    count(p.productid) as totalproducts,
    sum(p.stockquantity) as totalstock
from suppliers s
join products p
    on s.supplierid = p.supplierid
group by s.supplierid, s.suppliername
order by totalstock desc
limit 1;



##Normalization
##Task 12
##Normalize the Products table to 3NF:


create table categories (
    categoryid int auto_increment primary key,
    categoryname varchar(100) not null,
    subcategoryname varchar(100) not null,
    unique (categoryname, subcategoryname)
);

##add categoryid column to products

alter table products
add column categoryid int;

## insert categories and subcategories

insert ignore into categories (categoryname, subcategoryname)
select distinct category, subcategory
from products
where category is not null
and subcategory is not null;

## update categoryid in products

set sql_safe_updates = 0;

update products p
join categories c
    on p.category = c.categoryname
    and p.subcategory = c.subcategoryname
set p.categoryid = c.categoryid
where p.productid is not null;

set sql_safe_updates = 1;

## verify categoryid mapping

select
    count(*) as total_products,
    count(categoryid) as products_with_categoryid
from products;

##  create foreign key relationship

alter table products
add constraint fk_product_category
foreign key (categoryid)
references categories(categoryid);

## display normalized data

select
    p.productid,
    p.productname,
    c.categoryname,
    c.subcategoryname
from products p
left join categories c
    on p.categoryid = c.categoryid;

## verify tables

describe categories;
describe products;

select * from categories;

##Subqueries and Nested Queries
##Task 13 
##Write a subquery to:

##Identify the top 3 products based on sales revenue.

select
    p.productid,
    p.productname,
    (
        select sum(od.quantity * od.unitprice)
        from order_details od
        where od.productid = p.productid
    ) as totalrevenue
from products p
where p.productid in (
    select od.productid
    from order_details od
    group by od.productid
)
order by totalrevenue desc
limit 3;

##Find customers who haven’t placed any orders yet.    

select
    c.customerid,
    c.name
from customers c
where c.customerid not in (
    select o.customerid
    from orders o
    where o.customerid is not null
);


##Real-World Analysis
##Task 14
##Provide actionable insights:
##Which cities have the highest concentration of Prime members?

select
    city,
    count(*) as primemembers
from customers
where primemember = 'yes'
group by city
order by primemembers desc;

##What are the top 3 most frequently ordered categories? 

select
    p.category,
    sum(od.quantity) as totalquantityordered
from products p
join order_details od
    on p.productid = od.productid
group by p.category
order by totalquantityordered desc
limit 3;



