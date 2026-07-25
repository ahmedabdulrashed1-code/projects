
-- Cleaning Data in SQL Queries

select *
from Marketing; 

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Total the raw volum per campaign
/* What this does: collapses 28 days of daily rows 
into one row per campaign, so every metric after this step is 
a campaign-level total not a daily one.
*/

select campaign_name, 
	sum(impressions) As impressions,
	sum(clicks) As clicks,
	sum(leads) As leads,
	sum(orders) as orders, 
	Round(sum(mark_spent),2) as spend,
	Round(sum(revenue), 2) as revenue
from
	Marketing
group by campaign_name;


/* Result; banner_ partner has by far the most impressions (1.07B) despit modest
 spend; youtube_blogger brings in the most revenue (15.3M) from far fewer Impressions (43.7M) the first sign that raw volume won't tell the real story. 
*/


------------------------------------------------------------------------------------------------------------------------------------------------------------
-- click-through rate (CTR) is the audience actually engaging?
-- What this does: divides clicks by impressions per campaign. This measures attention, not money a campaign can have a great CTR and still lose cash,
-- which is exactly what shows up two steps from now.

SELECT campaign_name,
       ROUND(SUM(clicks) * 100.0 / SUM(impressions), 2) AS ctr_pct
FROM marketing
GROUP BY campaign_name
ORDER BY ctr_pct DESC;
 
-- RESULT: facebook_retargeting has the best CTR (3.07%) makes sense, retargeting
-- reaches people who already showed interest. banner_partner is worst (0.04%) huge reach, almost nobody clicks.

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Cost efficiency _ CPC, cost per lead, cost per order

SELECT campaign_name,
       ROUND(SUM(mark_spent) / SUM(clicks), 2)              AS cpc,
       ROUND(SUM(mark_spent) / SUM(leads), 2)                AS cpl,
       ROUND(SUM(mark_spent) / NULLIF(SUM(orders), 0), 2)    AS cpa
FROM Marketing
GROUP BY campaign_name
ORDER BY cpa DESC;

-- RESULT: facebook_lal is the most expensive campaign on every single cost
-- measure  $22.01 per click, $1,383.94 per lead, $8,986.19 per completed order.
-- That's the first hard signal something is wrong with this campaign
-- specifically, not just underperforming.


------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Return on ad spend (ROAS) — does the campaign actually make money?

SELECT campaign_name,
       ROUND(SUM(revenue), 2)      AS revenue,
       ROUND(SUM(mark_spent), 2)   AS spend,
       ROUND(SUM(revenue) / SUM(mark_spent), 2) AS roas,
       RANK() OVER (ORDER BY SUM(revenue) / SUM(mark_spent) DESC) AS performance_rank
FROM marketing
GROUP BY campaign_name
ORDER BY roas DESC;

-- RESULT: youtube_blogger ranks #1 (ROAS 3.77 ;  every $1 spent returns $3.77).
-- facebook_lal ranks dead last (ROAS 0.11 ;  every $1 spent returns 11 cents).
-- This is the number a client cares about most: everything above CTR was
-- diagnostic, this is the verdict.

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Roll it up to category level — the executive-summary view

SELECT category,
       ROUND(SUM(mark_spent), 2) AS spend,
       ROUND(SUM(revenue), 2)    AS revenue,
       ROUND(SUM(revenue) / SUM(mark_spent), 2) AS roas
FROM marketing
GROUP BY category
ORDER BY roas DESC;


-- RESULT: influencer campaigns return $2.54 per $1 spent the best category byfar, even though they get less total budget than social. Social gets the
-- LARGEST share of spend (13.8M) but returns the WORST ROAS (0.86) - spending
-- most on the category performing worst is the single clearest budget
-- misallocation in this dataset.


