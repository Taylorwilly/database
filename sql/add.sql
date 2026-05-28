insert into review_votes (review_id, customer_id, voted_at)
select 
    br.review_id, 
    cust.customer_id,
    br.review_date + (random() * interval '20 days')
from book_reviews br 
join lateral(
    select customer_id
    from customers c
    where c.customer_id <> br.customer_id
    order by random ()
    limit 5
) cust on true;

         

