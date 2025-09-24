/* Restaurant sales */

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

/*Case Study Questions */

--1. What is the total amount each customer spent at the restaurant?
select s.customer_id, sum(price) as "Total sales" from menu as m
join sales as s on m.product_id = s.product_id
group by s.customer_id
order by sum(price) desc

-- 2. How many days has each customer visited the restaurant?
select customer_id, count(distinct order_date) as noDate from sales
group by customer_id
order by noDate desc

-- 3. What was the first item from the menu purchased by each customer?
with order_sale as 
(select customer_id, s.order_date, product_name,
ROW_NUMBER() over (partition by s.customer_id order by s.order_date) as "rank"
from sales as s
join menu as m on s.product_id = m.product_id)
select DISTINCT customer_id, order_date, product_name from order_sale
where rank = 1
group by customer_id, product_name, order_date

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
select product_name, count(product_name) as notime from sales as s
join menu as m on s.product_id = m.product_id
group by product_name
order by notime desc
limit 1

-- 5. Which item was the most popular for each customer?
with most_popular as (
select s.customer_id, m.product_name, count(m.product_id) as order_count,
dense_rank() over (partition by s.customer_id order by count(s.customer_id)desc) as "rank"
from sales as s
join menu as m on m.product_id = s.product_id
group by s.customer_id, m.product_name
)
select customer_id, product_name, order_count from most_popular
where "rank" = 1

-- 6. Which item was purchased first by the customer after they became a member?
with join_member as (
select s.customer_id, s.product_id,
row_number() over (partition by s.customer_id order by s.order_date) as "rn" from sales as s
join members as mb on s.customer_id = mb.customer_id
and s.order_date > mb.join_date
)
select customer_id, product_name from join_member as jm
join menu as m on m.product_id = jm.product_id
where rn = 1
order by customer_id asc

-- 7. Which item was purchased just before the customer became a member?
with join_member as (
select s.customer_id, s.product_id, s.order_date,
row_number() over (partition by s.customer_id order by s.order_date desc) as "rn" from sales as s
join members as mb on s.customer_id = mb.customer_id
and s.order_date < mb.join_date
)
select customer_id, product_name, order_date from join_member as jm
join menu as m on m.product_id = jm.product_id
where rn = 1
order by customer_id

-- 8. What is the total items and amount spent for each member before they became a member?
select s.customer_id, count(s.product_id) as "total count", sum(m.price) as "total price" 
from sales as s
join menu as m on s.product_id = m.product_id
join members as mb on s.customer_id = mb.customer_id
where s.order_date < mb.join_date
group by s.customer_id
order by s.customer_id

/* 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - 
 how many points would each customer have? */
with points_cte as(
select product_id,
case
when product_id = 1 then price * 20
else price * 10 end as points from menu)
select customer_id, sum(pc.points) from points_cte as pc
join sales as s on s.product_id = pc.product_id
group by customer_id
order by customer_id

/*10. In the first week after a customer joins the program (including their join date) they earn 2x points 
on all items, not just sushi - how many points do customer A and B have at the end of January?*/

WITH dates_cte AS (
  SELECT customer_id, join_date, join_date + 6 AS valid_date, 
      DATE_TRUNC('month', '2021-01-31'::DATE)
        + interval '1 month' 
        - interval '1 day' AS last_date FROM members
)
SELECT s.customer_id, 
  SUM(CASE
    WHEN m.product_name = 'sushi' THEN 2 * 10 * m.price
    WHEN s.order_date BETWEEN dates.join_date AND dates.valid_date THEN 2 * 10 * m.price
    ELSE 10 * m.price END) AS points
FROM sales as s
INNER JOIN dates_cte AS dates
  ON s.customer_id = dates.customer_id
  AND dates.join_date <= s.order_date
  AND s.order_date <= dates.last_date
INNER JOIN menu as m
  ON s.product_id = m.product_id
GROUP BY s.customer_id;

