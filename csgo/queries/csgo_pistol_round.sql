SELECT cpr.match_id, cpr.steam_id, COALESCE(SUM(pistol_round.pistol_round_kills), 0) AS pistol_round_kills
FROM historical_csgo.csgo_player_rounds cpr
         LEFT JOIN (
    SELECT crk.round_id,
           crk.killer_steam_id,
           COUNT(crk.killer_steam_id) AS pistol_round_kills
    FROM historical_csgo.csgo_round_kills crk
             LEFT JOIN historical_csgo.csgo_map_rounds cmr ON cmr.round_id = crk.round_id
             LEFT JOIN historical_csgo.csgo_weapons cw ON cw.weapon_id = crk.weapon_id
    WHERE cw.eq_class = 'Pistol'
      AND cmr.round_number IN (1, 16)
    GROUP BY 1, 2) pistol_round ON cpr.round_id = pistol_round.round_id AND cpr.steam_id = pistol_round.killer_steam_id
WHERE cpr.map_id IN (
    SELECT map_id
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
    )
)
GROUP BY 1, 2;