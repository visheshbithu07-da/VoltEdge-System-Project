--Q1.Which products are priced above average?
select avg(productstandardprice) from product;

select productid, 
productdescription,
productstandardprice
from product
where productstandardprice > (select avg(productstandardprice) from product);


--Q2. Customers who have never ordered.
select 
    customerid,
    customername
from customer
where customerid NOT IN (select customerid from orders)
order by customerid;

--left join
select
c.customerid,
c.customername
from customer c 
left join orders o on c.customerid = o.customerid
where o.customerid IS NULL
order by c.customerid;


--Q3. Which are the top 10 revenue-generating products at VoltEdge Systems?

-- simple join
select 
p.productid,
p.productdescription,
SUM(ol.orderedquantity * p.productstandardprice) as revenue
from orderline ol
join product p on p.productid = ol.productid
group by p.productid, p.productdescription
order by revenue desc
limit 10;

-- using CTE

WITH product_revenue as (
select 
p.productid,
p.productdescription,
SUM(ol.orderedquantity * p.productstandardprice) as revenue
from orderline ol
join product p on p.productid = ol.productid
group by p.productid, p.productdescription
)

select * from product_revenue
order by revenue desc
limit 10;


-- what if i want to rank all products
WITH product_revenue as (
select 
p.productid,
p.productdescription,
SUM(ol.orderedquantity * p.productstandardprice) as revenue
from orderline ol
join product p on p.productid = ol.productid
group by p.productid, p.productdescription
)

select *,
RANK() OVER(order by revenue desc) as rnk
from product_revenue;

--Q4.What is the average order value, and which orders are above average?
with order_value as(
select o.orderid,
SUM(ol.orderedquantity * p.productstandardprice) as order_total
from orders o
join orderline ol on o.orderid = ol.orderid
join product p on p.productid = ol.productid
group by o.orderid
)

select * from order_value
where order_total > (select avg(order_total) from order_value);

select avg(order_total) as avg_order_value
from order_value;



--Q5.How do products in the Apex Collection rank based on total demand (quantity ordered)
select p.productdescription,
SUM(ol.orderedquantity) as total_ordered_qty,
RANK() over(order by SUM(ol.orderedquantity)) as rnk,
DENSE_RANK() over(order by SUM(ol.orderedquantity)) as dense_rnk,
row_number() over(order by SUM(ol.orderedquantity)) as row_num
from product p
join productline pl on p.productlineid = pl.productlineid
join orderline ol on ol.productid = p.productid
where pl.productlinename = 'Apex Collection'
group by productdescription;


--Q6.Customer Segmentation by Total Spend
WITH customer_spend as(
select o.customerid,
SUM(ol.orderedquantity * p.productstandardprice) as total_spend
from orders o
join orderline ol on ol.orderid = o.orderid
join product p on ol.productid = p.productid
group by o.customerid
)

select *,
NTILE(3) over(order by total_spend desc) as segment
from customer_spend;

select customerid, total_spend,
CASE 
    WHEN total_spend > 55000 THEN 'High Value'
    WHEN total_spend between 20000 and 55000 THEN 'Medium Value'
    else 'Low Value'
END AS segment
from customer_spend;

w
--Q7. How many products are included in each order?
select orderid, productid,
COUNT(*) over () as total_rows
from orderline;

select orderid, productid,
COUNT(*) over (partition by orderid) as count_of_each_order
from orderline;


--Q8. Previous order date and next order date for each order of each customer
select customerid, orderid, orderdate,
LAG(orderdate) over (partition by customerid order by orderdate) as previous_order_date,
LEAD(orderdate) over (partition by customerid order by orderdate) as next_order_date
from orders;