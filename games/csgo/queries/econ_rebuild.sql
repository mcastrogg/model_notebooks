SELECT cpr.match_id,
       cpr.map_id,
       cmr.round_number,
       cpr.steam_id,
       MAX(cpr.won::INT)                                                                      AS won,
       max(cpr.side) as side,
      --  MAX(CASE WHEN cpr.side = 'T' THEN 1 ELSE 0 END ) as is_tside,
      --  MAX((cpr.team_name = cmr.t_team)::INT)                                             AS is_tside,
      --  MAX(cpr.round_start_money)                                                         AS parser_money,
       MAX(cmr.round_end_reason)                                                          AS round_end_reason,
       COUNT(crk.killer_steam_id) FILTER ( WHERE cw.eq_class = 'AR')                              AS rifle_kills,
       COUNT(crk.killer_steam_id) FILTER ( WHERE cw.eq_class = 'Sniper' AND crk.weapon_id != 309) AS sniper_kills, -- Remove AWP
       COUNT(crk.killer_steam_id) FILTER ( WHERE cw.eq_class = 'Grenade')                         AS grenade_kills,
       COUNT(crk.killer_steam_id) FILTER ( WHERE cw.eq_class = 'LMG')                             AS lmg_kills,
       COUNT(crk.killer_steam_id) FILTER ( WHERE cw.eq_class = 'Shotgun')                         AS shotgun_kills,
       COUNT(crk.killer_steam_id) FILTER ( WHERE cw.eq_class = 'SMG' AND crk.weapon_id != 106)    AS smg_kills,    --Remove P90
       COUNT(crk.killer_steam_id) FILTER ( WHERE cw.eq_class = 'Pistol' AND crk.weapon_id != 8)   AS pistol_kills, --Remove CZ75
       COUNT(crk.killer_steam_id) FILTER ( WHERE cw.eq_class = 'Melee' AND crk.weapon_id != 401)  AS melee_kills,  -- Remove Zeus
       COUNT(crk.killer_steam_id) FILTER ( WHERE crk.weapon_id = 309)                             AS awp_kills,
       COUNT(crk.killer_steam_id) FILTER ( WHERE crk.weapon_id = 106)                             AS p90_kills,
       COUNT(crk.killer_steam_id) FILTER ( WHERE crk.weapon_id = 8)                               AS cz75_kills,
       COALESCE(MAX(bomb_events.bomb_plant), 0)                                           AS bomb_plants,
       COALESCE(MAX(bomb_events.bomb_defused), 0)                                         AS bomb_defused,
       COALESCE(MAX(bomb_events.bomb_exploded), 0)                                        AS bomb_exploded
FROM historical_csgo.csgo_player_rounds cpr
    LEFT JOIN historical_csgo.csgo_map_rounds cmr ON cpr.round_id = cmr.round_id
         LEFT JOIN historical_csgo.csgo_round_kills crk ON cpr.steam_id = crk.killer_steam_id AND cpr.round_id = crk.round_id
         LEFT JOIN historical_csgo.csgo_weapons cw ON cw.weapon_id = crk.weapon_id
         LEFT JOIN (
    SELECT crb.round_id,
           crb.steam_id,
           COUNT(crb.bomb_event_type) FILTER ( WHERE crb.bomb_event_type = 'BombPlanted')  AS bomb_plant,
           COUNT(crb.bomb_event_type) FILTER ( WHERE crb.bomb_event_type = 'BombDefused')  AS bomb_defused,
           COUNT(crb.bomb_event_type) FILTER ( WHERE crb.bomb_event_type = 'BombExploded') AS bomb_exploded
    FROM historical_csgo.csgo_rounds_be crb
    GROUP BY 1, 2
) AS bomb_events ON bomb_events.round_id = cpr.round_id AND bomb_events.steam_id = cpr.steam_id
WHERE cpr.map_id in (SELECT map_id
    FROM historical_csgo.csgo_match_maps
    WHERE map_id NOT IN (
        SELECT DISTINCT(map_id)
        FROM historical_csgo.csgo_map_rounds cmr
        WHERE round_number != "t_score" + "ct_score"
    )
      AND map_id NOT IN (
        SELECT DISTINCT(map_id)
        FROM historical_csgo.csgo_map_rounds cmr
        GROUP BY 1
        HAVING MAX(round_number) < 16
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
    ))
GROUP BY 1, 2, 3, 4;