with combined_data as (
select
	fbd.ad_date,
	coalesce(fbd.url_parameters, fbd.url_parameters, gad.url_parameters)as url_parameters,
	coalesce(fbd.spend,
	0) as spend,
	coalesce(fbd.impressions,
	0) as impressions,
	coalesce(fbd.reach,
	0) as reach,
	coalesce(fbd.clicks,
	0) as clicks,
	coalesce(fbd.leads,
	0) as leads,
	coalesce(fbd.value,
	0) as value,
	coalesce(gad.spend,
	0) as google_spend,
	coalesce(gad.impressions,
	0) as google_impressions,
	coalesce(gad.clicks,
	0) as google_clicks,
	coalesce(gad.leads,
	0) as google_leads,
	coalesce(gad.value,
	0) as google_value
from
	facebook_ads_basic_daily fbd
left join facebook_adset fb_adset on
	fbd.adset_id = fb_adset.adset_id
left join facebook_campaign fbcs on
	fbd.campaign_id = fbcs.campaign_id
left join google_ads_basic_daily gad on
	fbd.ad_date = gad.ad_date
),
processed_data as (
select
	ad_date,
	LOWER(nullif(SUBSTRING(url_parameters from 'utm_campaign=([^&]*)'), 'nan')) as utm_campaign,
	(spend + google_spend) as total_spend,
	(impressions + google_impressions) as total_impressions,
	(clicks + google_clicks) as total_clicks,
	(value + google_value) as total_value
from
	combined_data
)
select
	ad_date,
	utm_campaign,
	total_spend as "Total Cost",
	total_impressions as "Number of Impressions",
	total_clicks as "Number of Clicks",
	total_value as "Total Conversion Value",
	case
		when total_impressions > 0 then (total_clicks * 100.0) / total_impressions
		else 0
	end as CTR,
	case
		when total_clicks > 0 then total_spend / total_clicks
		else 0
	end as CPC,
	case
		when total_impressions > 0 then (total_spend * 1000.0) / total_impressions
		else 0
	end as CPM,
	case
		when total_spend > 0 then total_value - total_spend / total_spend  * 100
		else 0
	end as romi
from
	processed_data;
	


TEMA SUPLIMENTARA

create or replace
function pg_temp.decode_url_part(p varchar) returns varchar as $$
select
	convert_from(cast(E'\\x' || string_agg(case
		when length(r.m[1]) = 1 then encode(convert_to(r.m[1],
		'SQL_ASCII'),
		'hex')
		else substring(r.m[1]
	from
		2 for 2)
	end,
	'') as bytea),
	'UTF8')
from
	regexp_matches($1,
	'%[0-9a-f][0-9a-f]|.',
	'gi') as r(m);

$$ language sql immutable strict;

