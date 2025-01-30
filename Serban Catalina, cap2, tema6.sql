WITH combined_data AS (
    SELECT
        fbd.ad_date,
        COALESCE(fbd.url_parameters, gad.url_parameters) AS url_parameters,
        COALESCE(fbd.spend, 0) AS spend,
        COALESCE(fbd.impressions, 0) AS impressions,
        COALESCE(fbd.reach, 0) AS reach,
        COALESCE(fbd.clicks, 0) AS clicks,
        COALESCE(fbd.leads, 0) AS leads,
        COALESCE(fbd.value, 0) AS value,
        COALESCE(gad.spend, 0) AS google_spend,
        COALESCE(gad.impressions, 0) AS google_impressions,
        COALESCE(gad.clicks, 0) AS google_clicks,
        COALESCE(gad.leads, 0) AS google_leads,
        COALESCE(gad.value, 0) AS google_value
    FROM
        facebook_ads_basic_daily fbd
    LEFT JOIN facebook_adset fb_adset USING (adset_id)
    LEFT JOIN facebook_campaign fbcs USING (campaign_id)
    LEFT JOIN google_ads_basic_daily gad USING (ad_date)
),
processed_data AS (
    SELECT
        DATE_TRUNC('month', ad_date) AS ad_month,
        LOWER(NULLIF(SUBSTRING(url_parameters FROM 'utm_campaign=([^&]*)'), 'nan')) AS utm_campaign,
        (spend + google_spend) AS total_spend,
        (impressions + google_impressions) AS total_impressions,
        (clicks + google_clicks) AS total_clicks,
        (value + google_value) AS total_value
    FROM
        combined_data
),
monthly_metrics AS (
    SELECT
        ad_month,
        utm_campaign,
        SUM(total_spend) AS total_cost,
        SUM(total_impressions) AS number_of_impressions,
        SUM(total_clicks) AS number_of_clicks,
        SUM(total_value) AS conversion_value,
        CASE
            WHEN SUM(total_impressions) > 0 THEN (SUM(total_clicks) * 100.0) / SUM(total_impressions)
            ELSE 0
        END AS CTR,
        CASE
            WHEN SUM(total_clicks) > 0 THEN SUM(total_spend) / SUM(total_clicks)
            ELSE 0
        END AS CPC,
        CASE
            WHEN SUM(total_impressions) > 0 THEN (SUM(total_spend) * 1000.0) / SUM(total_impressions)
            ELSE 0
        END AS CPM,
        CASE
            WHEN SUM(total_spend) > 0 THEN SUM(total_value) - SUM(total_spend) / SUM(total_spend) * 100
            ELSE 0
        END AS ROMI
    FROM
        processed_data
    GROUP BY
        ad_month,
        utm_campaign
),
metrics_with_previous AS (
    SELECT
        a.ad_month,
        a.utm_campaign,
        a.total_cost,
        a.number_of_impressions,
        a.number_of_clicks,
        a.conversion_value,
        a.CTR,
        a.CPC,
        a.CPM,
        a.ROMI,
        COALESCE((a.CPM - b.CPM) / NULLIF(b.CPM, 0) * 100, 0) AS CPM_diff_percentage,
        COALESCE((a.CTR - b.CTR) / NULLIF(b.CTR, 0) * 100, 0) AS CTR_diff_percentage,
        COALESCE((a.ROMI - b.ROMI) / NULLIF(b.ROMI, 0) * 100, 0) AS ROMI_diff_percentage
    FROM
        monthly_metrics a
    LEFT JOIN monthly_metrics b USING (utm_campaign)
    WHERE
        a.ad_month = b.ad_month + INTERVAL '1 month'
)
SELECT
    ad_month,
    utm_campaign,
    total_cost AS "Total Cost",
    number_of_impressions AS "Number of Impressions",
    number_of_clicks AS "Number of Clicks",
    conversion_value AS "Total Conversion Value",
    CTR,
    CPC,
    CPM,
    ROMI,
    CPM_diff_percentage AS "CPM Difference (%)",
    CTR_diff_percentage AS "CTR Difference (%)",
    ROMI_diff_percentage AS "ROMI Difference (%)"
FROM
    metrics_with_previous
ORDER BY
    ad_month,
    utm_campaign;
