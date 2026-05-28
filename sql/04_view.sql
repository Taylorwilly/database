--Count reviews

CREATE VIEW review_count as 
SELECT 
    br.review_id,
    br.customer_id,
    br.book_id,
    br.rating,
    br.review_text,
    br.review_date,
    COUNT (rv.customer_id) as helpful_votes
FROM book_reviews br LEFT JOIN review_votes rv
        on br.review_id = rv.review_id
GROUP BY 
    br.review_id,
    br.customer_id,
    br.book_id,
    br.rating,
    br.review_text,
    br.review_date;    