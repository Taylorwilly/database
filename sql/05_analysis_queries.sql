--Business analysis queries

--Record count 
SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_books FROM books ;
SELECT COUNT(*) AS total_orders FROM orders;
SELECT COUNT(*) AS total_payments FROM payment;
SELECT COUNT(*) AS total_reviews FROM book_reviews;

--Monthly revenue from completed payments

SELECT 
    trunc_date('month', payment_date) as revenue_month,
    sum(amount) as monthly_revenue
FROM payment
WHERE pay_status = 'completed'
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
ORDER BY total_units_sold DESC;
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
JOIN order o
ON o.order_id = p.order_id
WHERE payment_method in ('failed', 'refund')
ORDER BY payment_date DESC;

--Active subscriptions