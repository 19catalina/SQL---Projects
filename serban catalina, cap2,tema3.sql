SARCINA 1

with facebook_data as (
select
	fb_daily.ad_date,
	fb_campaign.campaign_name,
	fb_daily.spend,
	fb_daily.impressions,
	fb_daily.reach,
	fb_daily.clicks,
	fb_daily.leads,
	fb_daily.value
from
	facebook_ads_basic_daily fb_daily
join
        facebook_adset fb_adset
        on
	fb_daily.adset_id = fb_adset.adset_id
join
        facebook_campaign fb_campaign
        on
	fb_daily.campaign_id = fb_campaign.campaign_id
),
google_data as (
select
	ad_date,
	campaign_name,
	spend,
	impressions,
	reach,
	clicks,
	leads,
	value
from
	google_ads_basic_daily
)
select
	ad_date,
	campaign_name,
	SUM(spend) as total_spend,
	SUM(impressions) as total_impressions,
	SUM(reach) as total_reach,
	SUM(clicks) as total_clicks,
	SUM(leads) as total_leads,
	SUM(value) as total_value
from
	(
	select
		*
	from
		facebook_data
union all
	select
		*
	from
		google_data
) as combined_data
group by
	ad_date,
	campaign_name
order by
	ad_date,
	campaign_name;






   
   
  SARCINA 2
  
  with facebook_data as (
select
	fb_daily.ad_date,
	fb_campaign.campaign_name,
	fb_daily.spend as total_cost,
	fb_daily.impressions,
	fb_daily.clicks,
	fb_daily.value as total_conversion_value
from
	facebook_ads_basic_daily fb_daily
join 
        facebook_adset fb_adset 
        on
	fb_daily.adset_id = fb_adset.adset_id
join 
        facebook_campaign fb_campaign 
        on
	fb_daily.campaign_id  = fb_campaign.campaign_id
),
google_data as (
select
	ad_date,
	campaign_name,
	spend as total_cost,
	impressions,
	clicks,
	value as total_conversion_value
from
	google_ads_basic_daily
)
select
	ad_date,
	campaign_name,
	SUM(total_cost) as total_cost,
	SUM(impressions) as total_impressions,
	SUM(clicks) as total_clicks,
	SUM(total_conversion_value) as total_conversion_value
from
	(
	select
		*
	from
		facebook_data
union all
	select
		*
	from
		google_data
) as combined_data
group by
	ad_date,
	campaign_name
order by
	ad_date,
	campaign_name;





    
   
   
TEMA SUPLIMENTARA

with facebook_data as (
select
	fb_daily.ad_date,
	fb_campaign.campaign_name,
	fb_adset.adset_id,
	fb_adset.adset_name,
	fb_daily.spend as total_cost,
	fb_daily.value as total_conversion_value
from
	facebook_ads_basic_daily fb_daily
join 
        facebook_adset fb_adset 
        on
	fb_daily.adset_id = fb_adset.adset_id
join 
        facebook_campaign fb_campaign 
        on
	fb_daily.campaign_id = fb_campaign.campaign_id
),
google_data as (
select
	ad_date,
	campaign_name,
	null as adset_id,
	null as adset_name,
	spend as total_cost,
	value as total_conversion_value
from
	google_ads_basic_daily
),
combined_data as (
select
	ad_date,
	campaign_name,
	adset_id,
	adset_name,
	SUM(total_cost) as total_spend,
	SUM(total_conversion_value) as total_conversion_value,
	case
		when SUM(total_cost) = 0 then 0
		else (SUM(total_conversion_value) - SUM(total_cost)) / SUM(total_cost)
	end as romi
from
	(
	select
		*
	from
		facebook_data
union all
	select
		*
	from
		google_data
    ) as combined_data
group by
	ad_date,
	campaign_name,
	adset_id,
	adset_name
	
having
	SUM(total_cost) > 0
),
campaigns_with_high_spend as (
select
	campaign_name,
	SUM(total_spend) as total_spend,
	SUM(total_conversion_value) as total_conversion_value,
	case
		when SUM(total_spend) = 0 then 0
		else (SUM(total_conversion_value) - SUM(total_spend)) / SUM(total_spend)
	end as romi
from
	combined_data
group by
	campaign_name
having
	SUM(total_spend) > 500000
)
select
	cwhs.campaign_name,
	cwhs.romi as campaign_romi,
	cd.adset_name,
	cd.romi as adset_romi
from
	campaigns_with_high_spend cwhs
join 
    combined_data cd 
    on
	cwhs.campaign_name = cd.campaign_name
where
	cwhs.romi = (
	select
		MAX(romi)
	from
		campaigns_with_high_spend)
order by
	cd.romi desc
limit 1;





SARCINA 1 SI SARCINA 2 INTR UN SINGUR QUERY 


with facebook_ads as (
select
	ad_date,
	campaign_name,
	spend as facebook_spend,
	impressions as facebook_impressions,
	reach as facebook_reach,
	clicks as facebook_clicks,
	leads as facebook_leads,
	value as facebook_value
from
	facebook_ads_basic_daily
join facebook_adset on
	facebook_ads_basic_daily.adset_id = facebook_adset.adset_id
join facebook_campaign on
	facebook_ads_basic_daily.campaign_id = facebook_campaign.campaign_id
),
google_ads as (
select
	ad_date,
	campaign_name,
	spend as google_spend,
	impressions as google_impressions,
	reach as google_reach,
	clicks as google_clicks,
	leads as google_leads,
	value as google_value
from
	Google_ads_basic_daily
),
combined_ads as (
select
	ad_date,
	campaign_name,
	facebook_spend as spend,
	facebook_impressions as impressions,
	facebook_reach as reach,
	facebook_clicks as clicks,
	facebook_leads as leads,
	facebook_value as value
from
	facebook_ads
union all
select
	ad_date,
	campaign_name,
	google_spend as spend,
	google_impressions as impressions,
	google_reach as reach,
	google_clicks as clicks,
	google_leads as leads,
	google_value as value
from
	google_ads
)
select
	ad_date,
	campaign_name,
	SUM(spend) as total_cost,
	SUM(impressions) as total_impressions,
	SUM(clicks) as total_clicks,
	SUM(value) as total_conversion_value
from
	combined_ads
group by
	ad_date,
	campaign_name
ORDER by ad_date,
campaign_name;

