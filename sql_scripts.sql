select count(*) from walmart;
select * from walmart;
-- which branch is excelling the most
select count(distinct branch) from walmart; --100
select branch,city,sum(total) as total_earnings
from walmart 
group by branch ,city
order by total_earnings desc ;

-- Find the differrent payment methods and number of transactions and no of units sold
select payment_method,count(invoice_id) no_of_transactions,sum(quantity) as total_units
from walmart
group by payment_method;

-- Identify the highest-rated category in each branch and displaying the branch,category,avg rating
select *
from (
select branch,category, avg(rating)as avg_rating, rank() over(partition by branch order by avg(rating) desc ) as rank 
from walmart
group by branch , category 
)
where rank<=3

-- Identify the busiest day for each branch based on the no of transactions 
select branch,to_char(to_date(date,'DD/MM/YYYY'),'day') as day_name,count(*),
dense_rank() over(partition by branch order by count(*) desc )
from walmart
group by branch , day_name

-- calculate the total profit for each category 
select category , sum(total*profit_margin) as profit 
from walmart
group by category

-- Determine the most common payment method for each branch 
select branch,payment_method,count(*) as total_transactions
from walmart
group by branch ,payment_method
order by branch,total_transactions desc

-- categorize the sales into 3 groups  mornings,evenings,afternoon
with cte as 
(select *,
case 
	when extract(hour from (time::time) )<12 then 'morning'
	when extract(hour from(time::time)) between 12 and 17 then 'afternoon'
	else 'evening'
end day_time
from walmart )
select branch,day_time,count(*) as sales
from cte 
group by branch,day_time 
order by branch,sales desc

-- identify 5 branch with highest decrease ratio in revenue  compared to last year 
with revenue_2022 as 
(
 select branch,sum(total) as revenue 
 from walmart
 where extract(year from to_date(date,'DD/MM/YY'))=2022
 group by branch 
),
revenue_2023 as
(
select branch,sum(total) as revenue 
 from walmart
 where extract(year from to_date(date,'DD/MM/YY'))=2023
 group by branch 
)
select ly.branch,
	   ly.revenue,
	   cy.revenue,
	   (ly.revenue-cy.revenue::numeric)/ly.revenue::numeric*100 as rev_dec_ratio
from revenue_2022 as ly join revenue_2023 as cy
on ly.branch = cy.branch 
where ly.revenue>cy.revenue
order by rev_dec_ratio desc
limit 5