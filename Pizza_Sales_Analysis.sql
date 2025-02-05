create database pizzahut;
use pizzahut;
select * from pizzas;
select * from orders;

-- 1.Retrieve the total number of orders placed.
select count(order_id) as total_no_of_order_placed from orders;

-- 2.Calculate the total revenue generated from pizza sales.
 use pizzahut;
select p.pizza_id ,sum(p.price) as total_revenue from pizzas p join order_details o on p.pizza_id = o.pizza_id group by p.pizza_id;
 select *  from pizzas;
 
 select * from order_details ;
 
 
 
 -- Identify the highest-priced pizza.
select max(price) as highest_priced_pizza from pizzas;



-- Identify the most common pizza size ordered.
select * from pizzas;
select max(size) from pizzas GROUP BY SIZE LIMIT 1;
select max(size) from pizzas ;

-- List the top 5 most ordered pizza types along with their quantities.
SELECT pizza_types.name, 
SUM(order_details.quantity) AS quantity 
FROM pizza_types JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id 
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id 
GROUP BY pizza_types.name 
ORDER BY SUM(order_details.quantity) DESC  -- Use the full aggregate expression instead of the alias
LIMIT 5;


-- Intermediate:
-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pz.category,  -- Grouping by category, so we only select it
    SUM(o.quantity) AS total_quantity 
FROM order_details o 
JOIN pizzas p ON o.pizza_id = p.pizza_id 
JOIN pizza_types pz ON pz.pizza_type_id = p.pizza_type_id 
GROUP BY pz.category 
ORDER BY total_quantity DESC;  -- Optional: Sorting by highest order quantity


-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(time) AS order_hour,  -- Extract hour from the order timestamp
    COUNT(order_id) AS total_orders  -- Count total orders per hour
FROM orders  -- Assuming the table storing orders is named 'orders'
GROUP BY order_hour
ORDER BY order_hour;  -- Sorting results in chronological order



-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    pz.category, 
    COUNT(p.pizza_id) AS total_pizzas
FROM pizzas p
JOIN pizza_types pz ON p.pizza_type_id = pz.pizza_type_id
GROUP BY pz.category
ORDER BY total_pizzas DESC;  -- Optional: Sorting from highest to lowest



-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    AVG(daily_orders.total_pizzas) AS avg_pizzas_per_day
FROM (
    SELECT 
	DATE(o.time) AS order_date,  -- Extract the date part from the timestamp
	SUM(od.quantity) AS total_pizzas  -- Calculate total pizzas ordered per day
    FROM orders o JOIN order_details od ON o.order_id = od.order_id
    GROUP BY DATE(o.time)  -- Group by the date of the order
        ) daily_orders;




-- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pt.name AS pizza_type, 
    SUM(od.quantity * p.price) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC LIMIT 3;


-- Advanced:

-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.name AS pizza_type, 
    SUM(od.quantity * p.price) AS total_revenue,
    ROUND((SUM(od.quantity * p.price) / 
    (SELECT SUM(od.quantity * p.price) FROM order_details od 
    JOIN pizzas p ON od.pizza_id = p.pizza_id)) * 100, 2) 
    AS percentage_contribution
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_revenue DESC;



-- Analyze the cumulative revenue generated over time.
SELECT 
    DATE(o.time) AS order_date, 
    SUM(od.quantity * p.price) AS daily_revenue,
    SUM(SUM(od.quantity * p.price)) OVER (ORDER BY DATE(o.time)) AS cumulative_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN orders o ON od.order_id = o.order_id
GROUP BY DATE(o.time)
ORDER BY order_date;



-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
WITH RankedPizzas AS (
    SELECT 
        pt.category, 
        pt.name AS pizza_type, 
        SUM(od.quantity * p.price) AS total_revenue,
        RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity * p.price) DESC) AS revenue_rank
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
)
SELECT category, pizza_type, total_revenue
FROM RankedPizzas
WHERE revenue_rank <= 3
ORDER BY category, revenue_rank;



