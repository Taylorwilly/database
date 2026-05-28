alter table orders
add created_at timestamptz not null default current_date,
add updated_at timestamptz not null default current_date;
