-- list of customers
select * from customers;

-- number of different products
select distinct count(*) from products;

-- count of employees
select count(employee_id) from employees;

-- total overall revenue
select * from order_details;
select sum(unit_price * quantity * (1 - discount)) from order_details;

-- total revenue for one particular year
select * from order_details;
select * from orders;
select sum(unit_price * quantity * (1 - discount)) from order_details
where order_id in (select order_id from orders where order_date between '');

-- list of countries covered by delivery
select distinct ship_country from orders order by ship_country asc;

-- list of available transporters
select * from shippers s;
select s.company_name from shippers s;

-- number of customer per countries
select * from customers c;
select c.country, count(c.customer_id) as cnt from customers c
group by c.country;

-- number of orders which are "ordered" but not shipped
select * from orders;
select * from orders o;
where o.shipped_date is null;

-- all the orders from france and belgium
select * from orders where lower(ship_country) like 'France' or lower(ship_country) like 'Belgium';
select * from orders where ship_country like 'France' or ship_country like 'Belgium';
select * from orders where ship_country in ('France', 'Belgium')

-- most expensive products
with product_price_rank as(
	select product_name, quantity_per_unit, unit_price,
	rank() over (order by unit_price) as rnk
	from products
);

select *, rank() over (order by unit_price desc) from products;

select product_name, quantity_per_unit, unit_price, rnk
from product_price_rank
where rnk <= 5;

select product_name, quantity_per_unit, unit_price, categories, category_name, rnk from(
	select product_name, quantity_per_unit, unit_price, categories, category_name,
	rank() over (partition by products.category_id order by unit_price desc) as rnk
	from products
	join categories on categories.category_id = products.category_id
) as product_price_rank
where rnk <=5

-- list of discontinued products
select * from products

select * from products where discontinued = 0 or discontinued is null;

-- count of product per category
select c.category_name, count(p.product_id) from products p
left join categories c on c.category_id = p.category_id
group by c.category_name;

-- average order price
select avg((1 - discount) * unit_price * quantity) from order_details od;

select avg(sumPerOrder) from
	(select order_id, sum((1-discount) * unit_price * quantity) as sumPerOrder
	from order_details od group by order_id) sumSelect;

-- revenue per category
select * from products;
select * from categories;
select c.category_name, sum((1-discount) * od.unit_price * od.quantity) from products
left join categories c on products.category_id = c.category_id
left join order_details od on od.product_id = products.product_id
group by c.category_id
order by c.category_name;

-- number of orders per shipper
select * from shippers;
select * from orders;

select s.company_name, count(o.order_id) as number_of_orders from orders o
join shippers s on o.ship_via = s.shipper_id
group by s.shipper_id;

-- number of orders per employee
select * from orders;
select * from employees;

select e.employee_id, count(o.order_id) as number_of_orders from orders o
join employees e on o.employee_id = e.employee_id
group by e.employee_id;

-- total revenue per supplier
select s.company_name, cast(sum((1-discount) * od.unit_price * od.quantity) as integer)
from products p
left join suppliers s on p.supplier_id = s.supplier_id
left join order_details od on od.product_id = p.product_id
group by s.supplier_id
order by s.company_name;



