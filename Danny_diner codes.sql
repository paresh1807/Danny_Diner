/*What is the total amount each customer spent at the restaurant?*/
select customer_id,sum(price) from sales
Inner join menu on sales.product_id=menu.product_id
group by customer_id

/*How many days has each customer visited the restaurant?*/
select customer_id,count(distinct(order_date)) as total_days from sales
group by customer_id

/*What was the first item from the menu purchased by each customer?*/
WITH CTE AS (
SELECT customer_id,product_name,order_date,
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date)as rn
from sales
Inner join menu on sales.product_id=menu.product_id
	)
SELECT customer_id,product_name from CTE
WHERE rn='1'

/*What is the most purchased item on the menu and how many times was it purchased by all customers?*/
select count(sales.product_id) as orders,product_name from sales
Inner join menu on sales.product_id=menu.product_id
group by product_name
limit 1

/*Which item was the most popular for each customer?*/
WITH CTE AS (
select customer_id,count(sales.product_id) as orders,product_name,
RANK() OVER(PARTITION BY customer_id ORDER BY count(sales.product_id)DESC)as rnk
from sales
Inner join menu on sales.product_id=menu.product_id
group by customer_id,product_name
	)
SELECT customer_id,product_name from CTE
where rnk='1'

/*Which item was purchased first by the customer after they became a member?*/
WITH CTE AS (
select sales.customer_id,order_date,join_date,product_name,
RANK() OVER(PARTITION BY sales.customer_id ORDER BY order_date)as rnk
from sales
Inner join members on sales.customer_id=members.customer_id
Inner join menu on sales.product_id=menu.product_id
where order_date>=join_date
	)
SELECT customer_id,product_name from CTE
WHERE rnk='1'

/*Which item was purchased just before the customer became a member?*/
WITH CTE AS(
select sales.customer_id,product_name,order_date,join_date,
RANK() OVER(PARTITION BY sales.customer_id ORDER BY order_date DESC)as rnk
from sales
Inner join members on sales.customer_id=members.customer_id
Inner join menu on sales.product_id=menu.product_id
WHERE order_date<join_date
	)
SELECT customer_id,product_name from CTE
WHERE rnk='1'

/*What is the total items and amount spent for each member before they became a member?*/
select sales.customer_id,count(product_name)as total_items,sum(price)as total_amount_spent from sales
Inner join members on sales.customer_id=members.customer_id
Inner join menu on sales.product_id=menu.product_id
where order_date<join_date
group by sales.customer_id
order by customer_id

/*If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?*/
Select customer_id, SUM(CASE WHEN product_name='sushi' THEN price*10*2 ELSE price*10 END) AS points
from menu
Inner join sales on sales.product_id=menu.product_id
GROUP BY customer_id
ORDER BY customer_id

/*After a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have?*/
select sales.customer_id,SUM(CASE
            WHEN product_name='sushi' THEN price*10*2
			WHEN product_name='curry' THEN price*10*2
			WHEN product_name='ramen' THEN price*10*2
			END) AS points
from sales
Inner join members on sales.customer_id=members.customer_id
Inner join menu on sales.product_id=menu.product_id
where order_date>=join_date
GROUP BY sales.customer_id
ORDER BY sales.customer_id
