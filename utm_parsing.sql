WITH ppc_map AS (
        SELECT users.* except(utm_medium, utm_source, utm_campaign),
               coalesce(map.utm_medium_new,users.utm_medium) AS utm_medium,
               coalesce(map.utm_source_new,users.utm_source) AS utm_source,
               coalesce(map.utm_campaign_new,users.utm_campaign) AS utm_campaign
          FROM `business-intelligence-240201.bi.user_loginid` AS users 
          #google sheet for mapping wrong ppc utm labels to correct labels
          LEFT JOIN `business-intelligence-240201.ppc_model.campaign_utm_map` AS MAP
            ON users.utm_medium = map.utm_medium
           AND users.utm_source = map.utm_source
           AND users.utm_campaign = map.utm_campaign
       ),

#classification for high level channel and source
source_groups AS (
        SELECT *,
               CASE WHEN regexp_contains(utm_source, 'myaffiliate')                                                                                                                                                          THEN 'myaffiliate'
                    WHEN regexp_contains(utm_source,'affiliate')                                                                                                                                                             THEN 'affiliate_source'
                    WHEN regexp_contains(utm_source,'yandex')                                                                                                                                                                THEN 'yandex'
                    WHEN regexp_contains(utm_source,'youtube')                                                                                                                                                               THEN 'youtube'
                    WHEN regexp_contains(utm_source,'oogle')                                                                                                                                                                 THEN 'google'
                    WHEN regexp_contains(utm_source,'baidu')                                                                                                                                                                 THEN 'baidu'
                    WHEN regexp_contains(utm_source,'mql') OR regexp_contains(utm_source,'metatrader') OR regexp_contains(utm_source,'mt5') OR regexp_contains(utm_source,'mt4') OR regexp_contains(utm_source,'metaquotes') THEN 'metatrader'
                    WHEN regexp_contains(utm_source,'yahoo')                                                                                                                                                                 THEN 'yahoo'
                    WHEN regexp_contains(utm_source,'acebook')OR regexp_contains(utm_source,'fb')                                                                                                                            THEN 'fb'
                    WHEN regexp_contains(utm_source,'xm')                                                                                                                                                                    THEN 'xm'
                    WHEN regexp_contains(utm_source,'customer')                                                                                                                                                              THEN 'customerio'
                    WHEN regexp_contains(utm_source,'search')                                                                                                                                                                THEN 'unknown_search_website'
                    WHEN regexp_contains(utm_source,'instagram')                                                                                                                                                             THEN 'ig'
                    WHEN regexp_contains(utm_source,'push')                                                                                                                                                                  THEN 'pushwhoosh'
                    WHEN regexp_contains(utm_source,'bing')                                                                                                                                                                  THEN 'bing'
                    WHEN regexp_contains(utm_source,'medium')                                                                                                                                                                THEN 'medium'
                    WHEN regexp_contains(utm_source,'elegram')                                                                                                                                                               THEN 'telegram'                                                                                                                                                         
                    WHEN regexp_contains(utm_source,'binary')                                                                                                                                                                THEN 'binary'
                    WHEN regexp_contains(utm_source,'deriv')                                                                                                                                                                 THEN 'deriv'
                    WHEN regexp_contains(utm_source,'direct')                                                                                                                                                                THEN 'direct'
                    ELSE utm_source
                     END AS source_group
          FROM ppc_map
       ),
medium_groups AS (
        SELECT *,
               CASE WHEN regexp_contains(utm_medium,'affiliate')                                                                                           THEN 'affiliate'
                    WHEN regexp_contains(utm_medium,'ppc')                                                                                                 THEN 'ppc'
                    WHEN regexp_contains(utm_medium,'email')                                                                                               THEN 'email'
                    WHEN source_group in ('sogou','baidu','unknown_search_website','yahoo','google','bing','alohafind.com','yandex')                       THEN 'organic'
                    WHEN utm_medium IS NULL AND utm_campaign IS NULL AND utm_source IS NOT NULL AND source_group not in ('direct','binary','deriv')        THEN 'referral'                   
                    WHEN utm_medium IS NULL AND utm_campaign IS NULL AND source_group in ('binary','deriv')                                                THEN 'internal_referral'
                    WHEN utm_medium IS NULL AND utm_campaign IS NULL AND (utm_source IS NULL OR source_group in ('direct'))                                THEN 'direct'
                    ELSE 'other'
                    END AS medium_group
          FROM source_groups
       ),
       non_ppc AS (
        SELECT *,
               medium_group AS channel,
               source_group AS source,

          FROM medium_groups
       ),
       #get channel,subchannel,source AND placement from utm_lables for ppc 
ppc AS (
        SELECT loginid,
               utm_medium,
               utm_source,
               utm_campaign,
               #first part OF utm_medium AS chanel, second part AS subchannel 
               #first part OF utm_source AS source, second part AS placement 
               coalesce(regexp_extract(utm_medium, '(.*)-.*'),utm_medium) AS channel,
               coalesce(regexp_extract(utm_medium, '.*-(.*)'),utm_medium) AS subchannel,
               coalesce(regexp_extract(utm_source, '(.*)-.*'),utm_source) AS source,
               coalesce(regexp_extract(utm_source, '.*-(.*)'),utm_source) AS placement,
          FROM medium_groups
         WHERE medium_group = 'ppc'
       ) 
#parse the ppc channel first, if it is non - ppc, parse it USING medium GROUP 

SELECT non_ppc.* except(channel, source),
       coalesce(ppc.channel,non_ppc.channel) AS channel,
       subchannel,
       coalesce(ppc.source,non_ppc.source) AS source,
       placement,
       non_ppc.utm_campaign AS campaign_name
  FROM non_ppc
  LEFT JOIN ppc
    ON non_ppc.loginid = ppc.loginid
