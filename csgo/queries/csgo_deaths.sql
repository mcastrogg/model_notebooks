SELECT cpr.match_id,
       cpr.steam_id,
       COUNT(crk.victim_steam_id)                                                                                    AS deaths,
       ROUND(COUNT(crk.victim_steam_id) / COUNT(DISTINCT cpr.map_id)::NUMERIC, 4)                                    AS deaths_per_map,
       ROUND(COUNT(crk.victim_steam_id) FILTER (WHERE crk.is_first_kill)::NUMERIC, 4)                                AS first_round_deaths,
       ROUND(COUNT(crk.victim_steam_id) FILTER (WHERE crk.is_first_kill)::NUMERIC / COUNT(DISTINCT cpr.map_id), 4)   AS frd_per_map,
       ROUND(COUNT(crk.victim_steam_id) FILTER (WHERE crk.is_headshot)::NUMERIC, 4)                                  AS headshot_deaths_kills,
       ROUND(COUNT(crk.victim_steam_id) FILTER (WHERE crk.is_headshot)::NUMERIC / COUNT(DISTINCT cpr.map_id), 4)     AS hsd_per_map,
       ROUND(COUNT(crk.victim_steam_id) FILTER (WHERE crk.is_flash_assist)::NUMERIC, 4)                              AS flash_deaths,
       ROUND(COUNT(crk.victim_steam_id) FILTER (WHERE crk.is_flash_assist)::NUMERIC / COUNT(DISTINCT cpr.map_id), 4) AS flash_deaths_per_map,
       COUNT(crk.victim_steam_id) FILTER ( WHERE cw.eq_class = 'AR')                                                         AS rifle_deaths,
       ROUND(COUNT(crk.victim_steam_id) FILTER ( WHERE cw.eq_class = 'AR') / COUNT(DISTINCT cpr.map_id)::NUMERIC, 4)         AS rifle_deaths_per_map,
       COUNT(crk.victim_steam_id) FILTER ( WHERE cw.eq_class = 'Sniper')                                                     AS sniper_deaths,
       ROUND(COUNT(crk.victim_steam_id) FILTER ( WHERE cw.eq_class = 'Sniper') / COUNT(DISTINCT cpr.map_id)::NUMERIC, 4)     AS sniper_deaths_per_map,
       COUNT(crk.victim_steam_id) FILTER ( WHERE cw.eq_class = 'Grenade')                                                    AS grenade_deaths,
       ROUND(COUNT(crk.victim_steam_id) FILTER ( WHERE cw.eq_class = 'Grenade') / COUNT(DISTINCT cpr.map_id)::NUMERIC, 4)    AS grenade_deaths_per_map,
       COUNT(crk.victim_steam_id) FILTER ( WHERE cw.eq_class = 'LMG')                                                        AS lmg_deaths,
       ROUND(COUNT(crk.victim_steam_id) FILTER ( WHERE cw.eq_class = 'LMG') / COUNT(DISTINCT cpr.map_id)::NUMERIC, 4)        AS lmg_deaths_per_map,
       COUNT(crk.victim_steam_id) FILTER ( WHERE cw.eq_class = 'Shotgun')                                                    AS shotgun_deaths,
       ROUND(COUNT(crk.victim_steam_id) FILTER ( WHERE cw.eq_class = 'Shotgun') / COUNT(DISTINCT cpr.map_id)::NUMERIC, 4)    AS shotgun_deaths_per_map,
       COUNT(crk.victim_steam_id) FILTER ( WHERE cw.eq_class = 'SMG')                                                        AS smg_deaths,
       ROUND(COUNT(crk.victim_steam_id) FILTER ( WHERE cw.eq_class = 'SMG') / COUNT(DISTINCT cpr.map_id)::NUMERIC, 4)        AS smg_deaths_per_map,
       COUNT(crk.victim_steam_id) FILTER ( WHERE cw.eq_class = 'Pistol')                                                     AS pistol_deaths,
       ROUND(COUNT(crk.victim_steam_id) FILTER ( WHERE cw.eq_class = 'Pistol') / COUNT(DISTINCT cpr.map_id)::NUMERIC, 4)     AS pistol_deaths_per_map
FROM historical_csgo.csgo_player_rounds cpr
         LEFT JOIN historical_csgo.csgo_round_kills crk ON cpr.round_id = crk.round_id and cpr.steam_id = crk.assister_steam_id
         LEFT JOIN historical_csgo.csgo_weapons cw ON cw.weapon_id = crk.weapon_id
WHERE cpr.map_id IN (
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
)
GROUP BY 1, 2;