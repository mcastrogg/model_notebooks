SELECT cpr.match_id,
       cpr.steam_id,
       COUNT(crk.assister_steam_id)                                                                                    AS assits,
       ROUND(COUNT(crk.assister_steam_id) / COUNT(DISTINCT cpr.map_id)::NUMERIC, 4)                                    AS assists_per_map,
       ROUND(COUNT(crk.assister_steam_id) FILTER (WHERE crk.is_first_kill)::NUMERIC, 4)                                AS first_kill_assists,
       ROUND(COUNT(crk.assister_steam_id) FILTER (WHERE crk.is_first_kill)::NUMERIC / COUNT(DISTINCT cpr.map_id), 4)   AS fka_per_map,
       ROUND(COUNT(crk.assister_steam_id) FILTER (WHERE crk.is_headshot)::NUMERIC, 4)                                  AS headshot_assits_kills,
       ROUND(COUNT(crk.assister_steam_id) FILTER (WHERE crk.is_headshot)::NUMERIC / COUNT(DISTINCT cpr.map_id), 4)     AS hka_per_map,
       ROUND(COUNT(crk.assister_steam_id) FILTER (WHERE crk.is_flash_assist)::NUMERIC, 4)                              AS flash_assist,
       ROUND(COUNT(crk.assister_steam_id) FILTER (WHERE crk.is_flash_assist)::NUMERIC / COUNT(DISTINCT cpr.map_id), 4) AS flash_assist_per_map,
       COUNT(crk.assister_steam_id) FILTER ( WHERE cw.eq_class = 'AR')                                                           AS rifle_assists,
       ROUND(COUNT(crk.assister_steam_id) FILTER ( WHERE cw.eq_class = 'AR') / COUNT(DISTINCT cpr.map_id)::NUMERIC, 4)           AS rifle_assits_per_map,
       COUNT(crk.assister_steam_id) FILTER ( WHERE cw.eq_class = 'Sniper')                                                       AS sniper_assits,
       ROUND(COUNT(crk.assister_steam_id) FILTER ( WHERE cw.eq_class = 'Sniper') / COUNT(DISTINCT cpr.map_id)::NUMERIC, 4)       AS sniper_assits_per_map,
       COUNT(crk.assister_steam_id) FILTER ( WHERE cw.eq_class = 'Grenade')                                                      AS grenade_assits,
       ROUND(COUNT(crk.assister_steam_id) FILTER ( WHERE cw.eq_class = 'Grenade') / COUNT(DISTINCT cpr.map_id)::NUMERIC, 4)      AS grenade_assits_per_map,
       COUNT(crk.assister_steam_id) FILTER ( WHERE cw.eq_class = 'LMG')                                                          AS lmg_assits,
       ROUND(COUNT(crk.assister_steam_id) FILTER ( WHERE cw.eq_class = 'LMG') / COUNT(DISTINCT cpr.map_id)::NUMERIC, 4)          AS lmg_assits_per_map,
       COUNT(crk.assister_steam_id) FILTER ( WHERE cw.eq_class = 'Shotgun')                                                      AS shotgun_assits,
       ROUND(COUNT(crk.assister_steam_id) FILTER ( WHERE cw.eq_class = 'Shotgun') / COUNT(DISTINCT cpr.map_id)::NUMERIC, 4)      AS shotgun_assits_per_map,
       COUNT(crk.assister_steam_id) FILTER ( WHERE cw.eq_class = 'SMG')                                                          AS smg_assits,
       ROUND(COUNT(crk.assister_steam_id) FILTER ( WHERE cw.eq_class = 'SMG') / COUNT(DISTINCT cpr.map_id)::NUMERIC, 4)          AS smg_assits_per_map,
       COUNT(crk.assister_steam_id) FILTER ( WHERE cw.eq_class = 'Pistol')                                                       AS pistol_assits,
       ROUND(COUNT(crk.assister_steam_id) FILTER ( WHERE cw.eq_class = 'Pistol') / COUNT(DISTINCT cpr.map_id)::NUMERIC, 4)       AS pistol_assits_per_map
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
        WHERE cmd.date  >={date}
    )
)
GROUP BY 1, 2;