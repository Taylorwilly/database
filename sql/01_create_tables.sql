-- Platform for a digital bookstore
-- File's name: 01_create_tables.sql

BEGIN;

-- 1. Customers of the store
CREATE TABLE IF NOT EXISTS customers(
    customer_id bigint generated always as identity primary key,
    first_name varchar(100) not null,
    last_name varchar(100) not null,
    email varchar(100) not null unique,
    country varchar(100),
    created_at timestamptz not null default current_timestamp,
    updated_at timestamptz not null default current_timestamp
);

-- 2. publishers table
CREATE TABLE IF NOT EXISTS publishers(
    publisher_id bigint generated always as identity primary key,
    publisher_name varchar(100) not null unique,
    country varchar(100),
    created_at timestamptz not null default current_timestamp
);

--3. Authors of the books
CREATE TABLE IF NOT EXISTS authors(
    author_id bigint not null generated always as identity primary key,
    first_name varchar(100) not null,
    last_name varchar(100) not null,
    country varchar(100),
    created_at timestamptz not null default current_timestamp
);

--4. Books store on the platform
CREATE TABLE IF NOT EXISTS books(
    book_id bigint not null generated always as identity primary key,
    publisher_id bigint references publishers(publisher_id) on delete set null,
    title varchar(200) not null,
    isbn varchar(20) unique,
    language varchar(50) not null default 'English',
    genre varchar(100),
    format varchar(50) not null default 'ebook',
    price numeric(10, 2) not null check (price >= 0),
    publication_date date,
    created_at timestamptz not null default current_timestamp,

    constraint format_ check (format in ('ebook', 'audiobook', 'ebook_and_audiobook'))
);

--5. Book authors
CREATE TABLE IF NOT EXISTS book_authors(
    book_id bigint not null references books(book_id) on delete cascade,
    author_id bigint not null references authors(author_id) on delete cascade,
    author_role varchar(100) default 'Author',
    primary key (book_id, author_id)
);

--6 Books with the audio versions
CREATE TABLE IF NOT EXISTS audiobooks(
    audiobook_id bigint generated always as identity primary key,
    book_id bigint not null references books(book_id) on delete cascade,
    narrator varchar(100),
    duration integer not null check (duration > 0),
    audio_format varchar(50) default 'mp3',
    created_at timestamptz not null default current_timestamp
);

/* 7 Table for the digital inventory
that tracks licence availability
*/
CREATE TABLE IF NOT EXISTS digital_inventory(
    inventory_id bigint generated always as identity primary key,
    book_id bigint not null references books(book_id) on delete cascade,
    available_licences integer not null default 0 check(available_licences >= 0),
    licence_model varchar(50) not null default 'Standard',
    last_update timestamptz not null default current_timestamp,
    constraint licence_model_ check (licence_model in ('standard', 'limited', 'subscription_only', 'unlimited'))
);

--8 Subscription table to store plans
CREATE TABLE IF NOT EXISTS subscriptions(
    subscription_id bigint generated always as identity primary key,
    customer_id bigint not null references customers(customer_id) on delete cascade,
    plan_name varchar(100) not null,
    plan_status varchar(50) not null default 'active',
    start_date date not null default current_date,
    end_date date,

    constraint subs_status check (plan_status in ('active', 'cancelled', 'expired', 'pause')),
    constraint subs_date check (end_date is null or end_date >= start_date)
);

--9 Table to store orders
CREATE TABLE IF NOT EXISTS orders(
    order_id bigint generated always as identity primary key,
    customer_id bigint not null references customers(customer_id) on delete restrict,
    order_date timestamptz not null default current_timestamp,
    order_status varchar(50) not null default 'pending',
    total_amount numeric(10, 2) not null default 0 check (total_amount >= 0),

    constraint order_stat check (order_status in ('pending', 'cancelled', 'completed', 'refunded'))
);

/* 10 Order items
stores books purchased inside each order
and one order can contain many books
*/
CREATE TABLE IF NOT EXISTS order_items (
    order_item_id bigint generated always as identity primary key,
    order_id bigint not null references orders(order_id) on delete cascade,
    book_id bigint not null references books(book_id) on delete restrict,
    quantity integer not null default 1 check (quantity > 0),
    unit_price numeric(10, 2) not null check (unit_price >= 0),
    line_total numeric(10, 2) generated always as (quantity * unit_price) stored
);

--11 Store the payment for oders
CREATE TABLE IF NOT EXISTS payment(
    payment_id bigint generated always as identity primary key,
    order_id bigint not null unique references orders(order_id) on delete cascade,
    payment_method varchar(50) not null,
    payment_status varchar(50) not null default 'pending',
    amount numeric(10,2) not null check (amount >= 0),
    payment_date timestamptz not null default current_timestamp,
    constraint payment_method_ check (payment_method in ('credit_card', 'debit_card', 'paypal', 'gift_card', 'store_credit')),
    constraint pay_status_ check (payment_status in ('pending', 'completed', 'failed', 'refunded'))
);

--12 Track the way customers read books on the platform
CREATE TABLE IF NOT EXISTS reading_sessions (
    reading_session_id bigint generated always as identity primary key,
    customer_id bigint not null references customers(customer_id) on delete cascade,
    book_id bigint not null references books(book_id) on delete cascade,
    device_type varchar(100),
    started_at timestamptz not null,
    ended_at timestamptz,
    minutes_read integer not null check (minutes_read >= 0),
    pages_read integer not null check (pages_read >= 0),
    created_at timestamptz not null default current_timestamp,
    constraint session_time check (ended_at is null or ended_at >= started_at)
);

--13 Customer reviews and ratings
CREATE TABLE IF NOT EXISTS book_reviews (
    review_id bigint generated always as identity primary key,
    customer_id bigint not null references customers(customer_id) on delete cascade,
    book_id bigint not null references books(book_id) on delete cascade,
    rating integer not null check (rating between 1 and 5),
    review_text text,
    review_date timestamptz not null default current_timestamp,
    constraint cust_review unique(customer_id, book_id)
);

--14 Tracking customers with helpful reviews
CREATE TABLE IF NOT EXISTS review_votes (
    review_id bigint not null references book_reviews(review_id) on delete cascade,
    customer_id bigint not null references customers(customer_id) on delete cascade,
    voted_at timestamptz not null default current_timestamp,
    primary key (review_id, customer_id)
);

--15 Audit logs to track important data changes
CREATE TABLE IF NOT EXISTS audi_logs (
    audit_log_id bigint generated always as identity primary key,
    table_name varchar(100) not null,
    record_id bigint not null,
    action_type varchar(50) not null,
    old_value json,
    new_value json,
    changed_by varchar(100),
    changed_at timestamptz not null default current_timestamp,

    constraint action_t check (action_type in ('insert', 'update', 'delete'))
);
COMMIT;