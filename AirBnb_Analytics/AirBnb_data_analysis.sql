-- Top 20 most successful

USE airbnb; 
SELECT id, listing_url, name, 30 - availability_30 AS booked_out_30 , 
CAST(REPLACE(Price,'$','') AS UNSIGNED) AS price_clean, 
CAST(REPLACE(Price,'$','') AS UNSIGNED)*(30 - availability_30) / beds AS proj_rev_30
FROM listings ORDER BY proj_rev_30 DESC LIMIT 20; 



SELECT host_id, host_url, host_name, COUNT(*) AS num_dirty_reviews FROM reviews INNER JOIN listings ON reviews.listing_id = listings.id
WHERE comments LIKE "%dirty%"
GROUP BY host_id, host_url, host_name ORDER BY num_dirty_reviews DESC;