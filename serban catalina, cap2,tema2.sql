select
	ad_date,
	campaign_id ,
	adset_id ,
	spend ,
	impressions ,
	reach ,
	clicks ,
	leads,
	value ,
	url_parameters ,
	total
from
	facebook_ads_basic_daily
order by
	ad_date ;


select ad_date,
campaign_id,
sum(spend) as spend,
sum (impressions) as impressions ,
sum (clicks) as clikcs,
sum(value) as value
from
facebook_ads_basic_daily
group by
ad_date ,
campaign_id
order by
ad_date asc;



CPC

select
	ad_date,
	campaign_id,
	sum(spend) as spend,
	sum (clicks) as clikcs,
	sum (spend)/ sum(clicks) as cpc
from
	facebook_ads_basic_daily
where
	clicks >0
group by
	ad_date ,
	campaign_id
order by
	ad_date ;

CTR

select
	ad_date,
	campaign_id,
	sum (clicks) as clikcs,
	sum (impressions) as impressions ,
	sum (cast (clicks as float))/ sum (cast (impressions as float))* 100 as ctr
from
	facebook_ads_basic_daily
where
	impressions >0
group by
	ad_date ,
	campaign_id
order by
	ad_date ;



CPM

select
	ad_date,
	campaign_id,
	sum (spend) as spend ,
	sum (impressions) as impressions ,
	sum (cast(spend as float))/ sum(cast (impressions as float))* 1000 as cpm
from
	facebook_ads_basic_daily
where
	impressions >0
group by
	ad_date ,
	campaign_id
order by
	ad_date ;


ROMI

select
	ad_date,
	campaign_id,
	sum (value :: float) as value_sum ,
	sum (spend) as spend,
	((sum (value :: float) - sum(spend :: float)) / sum (spend :: float))* 100 as romi
from
	facebook_ads_basic_daily
where
	spend >0
group by
	ad_date ,
	campaign_id
order by
	ad_date ;


PUNEM TOTUL INTR O SINGURA INTEROGARE

select
	ad_date,
	campaign_id,
	sum(spend) as total_spend,
	sum(impressions) as total_impressions,
	sum(clicks) as total_clicks,
	sum(value) as total_value,
	sum(spend)/ sum(clicks) as cpc,
	1000 * sum(spend)/ sum(impressions) as cpm,
	sum(clicks)::numeric / sum(impressions) as ctr,
	sum(value)::numeric / sum(spend) as romi
from
	facebook_ads_basic_daily fabd
where
	clicks > 0
	and impressions > 0
	and spend > 0
group by
	ad_date,
	campaign_id
order by
	ad_date desc;






TEMA SUPLIMENTARA 


select
	campaign_id,
	sum (spend) as total_spend,
	sum (value::float) as total_value,
	((sum (value :: float) - sum(spend :: float)) / sum (spend :: float))* 100 as romi
from
	facebook_ads_basic_daily
group by
	campaign_id
having
	sum(spend) >500000
order by
	romi desc
limit 1;




