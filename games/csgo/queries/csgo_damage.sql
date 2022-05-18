SELECT cpr.match_id,
       cpr.steam_id,
       COUNT(crp.hit_group)                                                                                                                                        AS total_shots_hit,
       SUM(crp.health_damage_taken)                                                                                                                                AS health_damage_inflicted,
       ROUND(SUM(crp.health_damage_taken) / nullif(COUNT(DISTINCT cpr.map_id)::NUMERIC, 4), 0)                                                                                AS health_damage_inflicted_per_map,
       SUM(crp.armor_damage_taken)                                                                                                                                 AS armor_damage_inflicted,
       ROUND(SUM(crp.armor_damage_taken) / nullif(COUNT(DISTINCT cpr.map_id)::NUMERIC, 4), 0)                                                                                 AS armor_damage_inflicted_per_map,
       ROUND(COUNT(crp.hit_group) FILTER (WHERE crp.hit_group = 1) / COUNT(crp.hit_group)::NUMERIC, 4)                                                             AS head_hit_perc,
       ROUND(COUNT(crp.hit_group) FILTER (WHERE crp.hit_group = 2) / COUNT(crp.hit_group)::NUMERIC, 4)                                                             AS chect_hit_perc,
       ROUND(COUNT(crp.hit_group) FILTER (WHERE crp.hit_group = 3) / COUNT(crp.hit_group)::NUMERIC, 4)                                                             AS stomach_hit_perc,
       ROUND(COUNT(crp.hit_group) FILTER (WHERE crp.hit_group = 4) / COUNT(crp.hit_group)::NUMERIC, 4)                                                             AS leftarm_hit_perc,
       ROUND(COUNT(crp.hit_group) FILTER (WHERE crp.hit_group = 5) / COUNT(crp.hit_group)::NUMERIC, 4)                                                             AS rightarm_hit_perc,
       ROUND(COUNT(crp.hit_group) FILTER (WHERE crp.hit_group = 6) / COUNT(crp.hit_group)::NUMERIC, 4)                                                             AS leftleg_hit_perc,
       ROUND(COUNT(crp.hit_group) FILTER (WHERE crp.hit_group = 7) / COUNT(crp.hit_group)::NUMERIC, 4)                                                             AS righleg_hit_perc,
       ROUND(COUNT(crp.hit_group) FILTER (WHERE crp.hit_group = 8) / COUNT(crp.hit_group)::NUMERIC, 4)                                                             AS neck_hit_perc,
       ROUND(COUNT(crp.hit_group) FILTER (WHERE crp.hit_group NOT IN (1, 2, 3, 4, 5, 6, 7, 8)) / COUNT(crp.hit_group)::NUMERIC,
             4)                                                                                                                                                    AS other_hit_perc,
       ROUND((COUNT(crp.hit_group) FILTER (WHERE crp.hit_group = 1) / COUNT(crp.hit_group)::NUMERIC) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS head_hit_perc_per_map,
       ROUND((COUNT(crp.hit_group) FILTER (WHERE crp.hit_group = 2) / COUNT(crp.hit_group)::NUMERIC) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS chest_hit_perc_per_map,
       ROUND((COUNT(crp.hit_group) FILTER (WHERE crp.hit_group = 3) / COUNT(crp.hit_group)::NUMERIC) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS stomach_hit_perc_per_map,
       ROUND((COUNT(crp.hit_group) FILTER (WHERE crp.hit_group = 4) / COUNT(crp.hit_group)::NUMERIC) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS leftarm_hit_perc_per_map,
       ROUND((COUNT(crp.hit_group) FILTER (WHERE crp.hit_group = 5) / COUNT(crp.hit_group)::NUMERIC) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS rightarm_hit_perc_per_map,
       ROUND((COUNT(crp.hit_group) FILTER (WHERE crp.hit_group = 6) / COUNT(crp.hit_group)::NUMERIC) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS leftleg_hit_perc_per_map,
       ROUND((COUNT(crp.hit_group) FILTER (WHERE crp.hit_group = 7) / COUNT(crp.hit_group)::NUMERIC) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS rightleg_hit_perc_per_map,
       ROUND((COUNT(crp.hit_group) FILTER (WHERE crp.hit_group = 8) / COUNT(crp.hit_group)::NUMERIC) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS neck_hit_perc_per_map,
       ROUND((COUNT(crp.hit_group) FILTER (WHERE crp.hit_group NOT IN (1, 2, 3, 4, 5, 6, 7, 8) ) / COUNT(crp.hit_group)::NUMERIC) / COUNT(DISTINCT cpr.map_id), 4) AS other_hit_perc_per_map,
       SUM(crp.health_damage_taken) FILTER (WHERE crp.hit_group = 1)                                                                                               AS head_damage,
       ROUND(SUM(crp.health_damage_taken) FILTER (WHERE crp.hit_group = 1) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS head_damage_per_map,
       SUM(crp.health_damage_taken) FILTER (WHERE crp.hit_group = 2)                                                                                               AS chest_damage,
       ROUND(SUM(crp.health_damage_taken) FILTER (WHERE crp.hit_group = 2) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS chest_damage_per_map,
       SUM(crp.health_damage_taken) FILTER (WHERE crp.hit_group = 3)                                                                                               AS stomach_damage,
       ROUND(SUM(crp.health_damage_taken) FILTER (WHERE crp.hit_group = 3) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS stomach_damage_per_map,
       SUM(crp.health_damage_taken) FILTER (WHERE crp.hit_group = 4)                                                                                               AS leftarm_damage,
       ROUND(SUM(crp.health_damage_taken) FILTER (WHERE crp.hit_group = 4) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS leftarm_damage_per_map,
       SUM(crp.health_damage_taken) FILTER (WHERE crp.hit_group = 5)                                                                                               AS rightarm_damage,
       ROUND(SUM(crp.health_damage_taken) FILTER (WHERE crp.hit_group = 5) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS rightarm_damage_per_map,
       SUM(crp.health_damage_taken) FILTER (WHERE crp.hit_group = 6)                                                                                               AS leftleg_damage,
       ROUND(SUM(crp.health_damage_taken) FILTER (WHERE crp.hit_group = 6) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS leftleg_damage_per_map,
     SUM(crp.health_damage_taken) FILTER (WHERE crp.hit_group = 7)                                                                                               AS rightleg_damage,
       ROUND(SUM(crp.health_damage_taken) FILTER (WHERE crp.hit_group = 7) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS rightleg_damage_per_map,
       SUM(crp.health_damage_taken) FILTER (WHERE crp.hit_group = 8)                                                                                               AS neck_damage,
       ROUND(SUM(crp.health_damage_taken) FILTER (WHERE crp.hit_group = 8) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS neck_damage_per_map,
       SUM(crp.health_damage_taken) FILTER (WHERE crp.hit_group NOT IN (1, 2, 3, 4, 5, 6, 7, 8))                                                                   AS other_damage,
       ROUND(SUM(crp.health_damage_taken) FILTER (WHERE crp.hit_group NOT IN (1, 2, 3, 4, 5, 6, 7, 8)) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS other_damage_per_map,
       SUM(crp.armor_damage_taken) FILTER (WHERE crp.hit_group = 1)                                                                                                AS head_armor_damage,
       ROUND(SUM(crp.armor_damage_taken) FILTER (WHERE crp.hit_group = 1) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS head_armor_damage_per_map,
       SUM(crp.armor_damage_taken) FILTER (WHERE crp.hit_group = 2)                                                                                                AS chest_armor_damage,
       ROUND(SUM(crp.armor_damage_taken) FILTER (WHERE crp.hit_group = 2) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS chest_armor_damage_per_map,
       SUM(crp.armor_damage_taken) FILTER (WHERE crp.hit_group = 3)                                                                                                AS stomach_armor_damage,
       ROUND(SUM(crp.armor_damage_taken) FILTER (WHERE crp.hit_group = 3) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS stomach_armor_damage_per_map,
       SUM(crp.armor_damage_taken) FILTER (WHERE crp.hit_group = 4)                                                                                                AS leftarm_armor_damage,
       ROUND(SUM(crp.armor_damage_taken) FILTER (WHERE crp.hit_group = 4) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS leftarm_armor_damage_per_map,
       SUM(crp.armor_damage_taken) FILTER (WHERE crp.hit_group = 5)                                                                                                AS rightarm_armor_damage,
       ROUND(SUM(crp.armor_damage_taken) FILTER (WHERE crp.hit_group = 5) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS rightarm_armor_damage_per_map,
       SUM(crp.armor_damage_taken) FILTER (WHERE crp.hit_group = 6)                                                                                                AS leftleg_armor_damage,
       ROUND(SUM(crp.armor_damage_taken) FILTER (WHERE crp.hit_group = 6) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS leftleg_armor_damage_per_map,
       SUM(crp.armor_damage_taken) FILTER (WHERE crp.hit_group = 7)                                                                                                AS rightleg_armor_damage,
       ROUND(SUM(crp.armor_damage_taken) FILTER (WHERE crp.hit_group = 7) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS rightleg_armor_damage_per_map,
       SUM(crp.armor_damage_taken) FILTER (WHERE crp.hit_group = 8)                                                                                                AS neck_armor_damage,
       ROUND(SUM(crp.armor_damage_taken) FILTER (WHERE crp.hit_group = 8) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS neck_armor_damage_per_map,
       SUM(crp.armor_damage_taken) FILTER (WHERE crp.hit_group NOT IN (1, 2, 3, 4, 5, 6, 7, 8))                                                                    AS other_armor_damage,
       ROUND(SUM(crp.armor_damage_taken) FILTER (WHERE crp.hit_group NOT IN (1, 2, 3, 4, 5, 6, 7, 8)) / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS other_armor_damage_per_map,
       SUM(crp.health_damage_taken) FILTER ( WHERE cw.eq_class = 'AR')                                                                                             AS rifle_damage,
       ROUND(SUM(crp.health_damage_taken) FILTER ( WHERE cw.eq_class = 'AR') / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS rifle_damage_per_map,
       SUM(crp.health_damage_taken) FILTER ( WHERE cw.eq_class = 'Sniper')                                                                                         AS sniper_damage,
       ROUND(SUM(crp.health_damage_taken) FILTER ( WHERE cw.eq_class = 'Sniper') / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS sniper_damage_per_map,
       SUM(crp.health_damage_taken) FILTER ( WHERE cw.eq_class = 'Grenade')                                                                                        AS grenade_damage,
       ROUND(SUM(crp.health_damage_taken) FILTER ( WHERE cw.eq_class = 'Grenade') / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS grenade_damage_per_map,
       SUM(crp.health_damage_taken) FILTER ( WHERE cw.eq_class = 'LMG')                                                                                            AS lmg_damage,
       ROUND(SUM(crp.health_damage_taken) FILTER ( WHERE cw.eq_class = 'LMG') / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS lmg_damage_per_map,
       SUM(crp.health_damage_taken) FILTER ( WHERE cw.eq_class = 'Shotgun')                                                                                        AS shotgun_damage,
       ROUND(SUM(crp.health_damage_taken) FILTER ( WHERE cw.eq_class = 'Shotgun') / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS shotgun_damage_per_map,
       SUM(crp.health_damage_taken) FILTER ( WHERE cw.eq_class = 'SMG')                                                                                            AS smg_damage,
       ROUND(SUM(crp.health_damage_taken) FILTER ( WHERE cw.eq_class = 'SMG') / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS smg_damage_per_map,
       SUM(crp.health_damage_taken) FILTER ( WHERE cw.eq_class = 'Pistol')                                                                                         AS pistol_damage,
       ROUND(SUM(crp.health_damage_taken) FILTER ( WHERE cw.eq_class = 'Pistol') / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS pistol_damage_per_map,
       SUM(crp.armor_damage_taken) FILTER ( WHERE cw.eq_class = 'AR')                                                                                              AS rifle_armor_damage,
       ROUND(SUM(crp.armor_damage_taken) FILTER ( WHERE cw.eq_class = 'AR') / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS rifle_armor_damage_per_map,
       SUM(crp.armor_damage_taken) FILTER ( WHERE cw.eq_class = 'Sniper')                                                                                          AS sniper_armor_damage,
       ROUND(SUM(crp.armor_damage_taken) FILTER ( WHERE cw.eq_class = 'Sniper') / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS sniper_armor_damage_per_map,
       SUM(crp.armor_damage_taken) FILTER ( WHERE cw.eq_class = 'Grenade')                                                                                         AS grenade_armor_damage,
       ROUND(SUM(crp.armor_damage_taken) FILTER ( WHERE cw.eq_class = 'Grenade') / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS grenade_armor_damage_per_map,
       SUM(crp.armor_damage_taken) FILTER ( WHERE cw.eq_class = 'LMG')                                                                                             AS lmg_armor_damage,
       ROUND(SUM(crp.armor_damage_taken) FILTER ( WHERE cw.eq_class = 'LMG') / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS lmg_armor_damage_per_map,
       SUM(crp.armor_damage_taken) FILTER ( WHERE cw.eq_class = 'Shotgun')                                                                                         AS shotgun_armor_damage,
       ROUND(SUM(crp.armor_damage_taken) FILTER ( WHERE cw.eq_class = 'Shotgun') / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS shotgun_armor_damage_per_map,
       SUM(crp.armor_damage_taken) FILTER ( WHERE cw.eq_class = 'SMG')                                                                                             AS smg_armor_damage,
       ROUND(SUM(crp.armor_damage_taken) FILTER ( WHERE cw.eq_class = 'SMG') / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                    AS smg_armor_damage_per_map,
       SUM(crp.armor_damage_taken) FILTER ( WHERE cw.eq_class = 'Pistol')                                                                                          AS pistol_armor_damage,
       ROUND(SUM(crp.armor_damage_taken) FILTER ( WHERE cw.eq_class = 'Pistol') / COUNT(DISTINCT cpr.map_id)::NUMERIC,
             4)                                                                                                                                                      AS pistol_armor_damage_per_map
from historical_csgo.csgo_player_rounds cpr
    left JOIN historical_csgo.csgo_rounds_ph crp ON cpr.round_id = crp.round_id AND cpr.steam_id = crp.shooter_steam_id
         LEFT JOIN historical_csgo.csgo_weapons cw ON cw.weapon_id = crp.weapon_id
WHERE (cw.weapon_id + 100 - 1) / 100 NOT IN (0) and
      cpr.map_id IN (
    SELECT map_id
    FROM historical_csgo.csgo_match_maps
    WHERE map_id NOT IN (
        SELECT DISTINCT(map_id)
        FROM historical_csgo.csgo_map_rounds cmr
        WHERE round_number != "t_score" + "ct_score"
        ORDER BY 1
    )
      AND map_id NOT IN (
        SELECT DISTINCT(map_id)
        FROM historical_csgo.csgo_map_rounds cmr
        GROUP BY 1
        HAVING MAX(round_number) < 16
        ORDER BY 1
    )
      AND map_id NOT IN (
        SELECT DISTINCT(map_id)
        FROM historical_csgo.csgo_match_maps cmm
        WHERE cmm.winner IS NULL
           OR cmm.winner = ''
    )
      AND match_id NOT IN (
        SELECT match_id
        FROM historical_csgo.csgo_match_data cmd
        WHERE cmd.date < {date}
    )
)-- Remove generic damage
GROUP BY 1, 2;