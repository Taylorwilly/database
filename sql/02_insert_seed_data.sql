--Import generated csv

BEGIN;

TRUNCATE TABLE
    audi_logs,
    book_reviews,
    reading_sessions,
    payment,
    order_items,
    order_items,
    orders,
    subscriptions,
    digital_inventory,
    audiobooks,
    book_authors,
    books,
    authors,
    publishers,
    customers
RESTART IDENTITY CASCADE;
--We use copy since we are using 'generated always as identity'
COPY customers(customer_id, first_name, last_name, email, country, created_at, updated_at)
FROM '/data/customers.csv'
WITH (format csv, header true);

COPY publishers(publisher_id, publisher_name, country, created_at)
FROM '/data/publishers.csv'
WITH (format csv, header true);

COPY authors(author_id, first_name, last_name, country, created_at)
FROM '/data/authors.csv'
WITH (format csv, header true);

COPY books(book_id, publisher_id, title, isbn, language, genre, format, price, publication_date, created_at, updated_at)
FROM '/data/books.csv'
WITH (format csv, header true);

COPY book_authors(book_id, author_id, author_role)
FROM '/data/book_authors.csv'
WITH (format csv, header true);

COPY audiobooks(audiobook_id, book_id, narrator, duration, audio_format, created_at)
FROM '/data/audiobooks.csv'
WITH (format csv, header true);

COPY digital_inventory(inventory_id, book_id, available_licences, licence_model, last_update)
FROM '/data/digital_inventory.csv'
WITH (format csv, header true);

COPY subscriptions(subscription_id, customer_id, plan_name, plan_status, start_date, end_date, monthly_price, created_at)
FROM '/data/subscriptions.csv'
WITH (format csv, header true);

COPY orders(order_id, customer_id, order_date, order_status, total_amount, created_at, updated_at)
FROM '/data/orders.csv'
WITH (format csv, header true);

COPY order_items(order_item_id, order_id, book_id, quantity, unit_price)
FROM '/data/order_items.csv'
WITH (format csv, header true);

COPY payment(payment_id, order_id, payment_method, payment_status, amount, payment_date)
FROM '/data/payments.csv'
WITH (format csv, header true);

COPY reading_sessions(reading_session_id, customer_id, book_id, device_type, started_at, ended_at, minutes_read, pages_read, created_at)
FROM '/data/reading_sessions.csv'
WITH (format csv, header true);

COPY book_reviews(review_id, customer_id, book_id, rating, review_text, review_date)
FROM '/data/book_reviews.csv'
WITH (format csv, header true);

COPY audi_logs(audit_log_id, table_name, record_id, action_type, old_value, new_value, changed_by, changed_at)
FROM '/data/audit_logs.csv'
WITH (format csv, header true);

--Then we reset the identity sequences so that next insertions continue after the imported IDs.

SELECT setval(pg_get_serial_sequence('customers', 'customer_id'), (SELECT MAX(customer_id) FROM Customers));
SELECT setval(pg_get_serial_sequence('publishers', 'publisher_id'), (SELECT MAX(publisher_id) FROM publishers));
SELECT setval(pg_get_serial_sequence('authors', 'author_id'), (SELECT MAX(author_id) FROM authors));
SELECT setval(pg_get_serial_sequence('books', 'book_id'), (SELECT MAX(book_id) FROM books));
SELECT setval(pg_get_serial_sequence('audiobooks', 'audiobook_id'), (SELECT MAX(audiobook_id) FROM audiobooks));
SELECT setval(pg_get_serial_sequence('digital_inventory', 'inventory_id'), (SELECT MAX(inventory_id) FROM digital_inventory));
SELECT setval(pg_get_serial_sequence('subscriptions', 'subscription_id'), (SELECT MAX(subscription_id) FROM subscriptions));
SELECT setval(pg_get_serial_sequence('orders', 'order_id'), (SELECT MAX(order_id) FROM orders));
SELECT setval(pg_get_serial_sequence('order_items', 'order_item_id'), (SELECT MAX(order_item_id) FROM order_items));
SELECT setval(pg_get_serial_sequence('payment', 'payment_id'), (SELECT MAX(payment_id) FROM payment));
SELECT setval(pg_get_serial_sequence('reading_sessions', 'reading_session_id'), (SELECT MAX(reading_session_id) FROM reading_sessions));
SELECT setval(pg_get_serial_sequence('book_reviews', 'review_id'), (SELECT MAX(review_id) FROM book_reviews));
SELECT setval(pg_get_serial_sequence('audi_logs', 'audit_log_id'), (SELECT MAX(audit_log_id) FROM audi_logs));

COMMIT;

    
