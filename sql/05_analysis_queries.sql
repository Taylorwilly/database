--Business analysis queries

--Record count 
SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_books FROM books ;
SELECT COUNT(*) AS total_orders FROM orders;
SELECT COUNT(*) AS total_payments FROM payment;
SELECT COUNT(*) AS total_reviews FROM book_reviews;

--Monthly revenue from completed payments

SELECT 
    date_trunc('month', payment_date) as revenue_month,
    sum(amount) as monthly_revenue
FROM payment
WHERE payment_status = 'completed'
GROUP BY revenue_month
ORDER BY monthly_revenue;

--Top selling books by quantity

SELECT 
    b.book_id, 
    b.title,
    sum(oi.quantity) as total_units_sold,
    sum(oi.quantity * oi.unit_price) as total_sales
FROM order_items oi 
JOIN books b 
ON b.book_id = oi.book_id
GROUP BY b.book_id, b.title
ORDER BY total_units_sold DESC
LIMIT 10;

--Failed or refunded payments

SELECT 
    p.payment_id,
    p.order_id,
    o.customer_id,
    p.payment_method,
    p.payment_status,
    p.amount,
    p.payment_date
FROM payment p
JOIN orders o
ON o.order_id = p.order_id
WHERE payment_method in ('failed', 'refund')
ORDER BY payment_date DESC;

--Active subscriptions

SELECT 
    s.subscription_id,
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    s.plan_name,
    s.plan_status,
    s.monthly_price,
    s.start_date,
    s.end_date
FROM 
    subscriptions s
JOIN customers c
ON c.customer_id = s.customer_id
WHERE s.plan_status = 'active'
ORDER BY s.monthly_price DESC;

--Most active readers by total reading time

select 
    rs.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    sum(rs.minutes_read) as total_minutes_read,
    sum(rs.pages_read) as total_pages_read,
    count(rs.reading_session_id) as total_reading_sessions

from reading_sessions rs
join customers c 
on c.customer_id = rs.customer_id
group by 
    rs.customer_id,
    c.first_name,
    c.last_name,
    c.email
order by total_minutes_read;

--Highest-rated books

select 
    b.book_id,
    b.title,
    round(avg(br.rating)) as average_rating,
    count(br.review_id) as total_reviews
from book_reviews br
join books b
on b.book_id = br.book_id
group by b.book_id, b.title
order by average_rating desc, total_reviews desc
limit 10;

--We can select the most Helpfull reviews using the review_account view

select 
    rc.review_id,
    b.book_id,
    c.first_name,
    c.last_name,
    rc.rating,
    rc.review_text,
    rc.helpful_votes
from review_count rc
join books b on rc.book_id = b.book_id
join customers c on c.customer_id = rc.customer_id
order by rc.helpful_votes desc
limit 10;

--Low inventory books

select 
    b.book_id,
    b.title,
    di.available_licences,
    di.licence_model
from digital_inventory di 
join books b on b.book_id = di.book_id
where di.available_licences < 50
order by di.available_licences asc;

--Purchase history
select 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    o.order_id,
    o.order_date,
    o.order_status,
    b.title,
    oi.quantity,
    oi.unit_price,
    oi.quantity * oi.unit_price as line_total
from customers c
join orders o 
    on o.customer_id = c.customer_id
join order_items oi 
    on  oi.order_id = o.order_id
join books b 
    on oi.book_id = b.book_id
order by c.customer_id, o.order_date;

--Revenue by payment method

select 
    payment_method, 
    count(*) as number_of_payment,
    sum(amount) as total_revenue
from payment
where payment_status = 'completed'
group by payment_method
order by total_revenue desc;

--Query orders by status

select 
    order_status,
    count(*) as total_orders
from orders
group by order_status
order by total_orders desc;

--Books with the most reviews

select
    b.book_id,
    b.title,
    count(br.review_id) as total_reviews
from book_reviews br 
join books b
on b.book_id = br.book_id
group by 
    b.book_id,
    b.title
order by total_reviews desc
limit 10;

--Customers with the most orders

select 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    count(o.order_id) as total_orders
from orders o
join customers c 
on o.customer_id = c.customer_id
group by 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email
order by total_orders desc
limit 10;

--Total revenue per customer

select 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    sum(p.amount) as revenue_per_customer
from customers c 
join orders o on o.customer_id = c.customer_id
join payment p on p.amount = o.total_amount
where payment_status = 'completed'
group by 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email
order by revenue_per_customer desc
limit 10;