SELECT cpr.match_id,
       cpr.map_id,
       cpr.round_id,
       cpr.steam_id,
       SUM(crp.health_damage_taken) AS health_damage_inflicted,
       SUM(crp.armor_damage_taken)  AS armor_damage_inflicted
FROM historical_csgo.csgo_player_rounds cpr
         LEFT JOIN historical_csgo.csgo_rounds_ph crp ON cpr.round_id = crp.round_id AND cpr.steam_id = crp.shooter_steam_id
         LEFT JOIN historical_csgo.csgo_weapons cw ON cw.weapon_id = crp.weapon_id
WHERE (cw.weapon_id + 100 - 1) / 100 NOT IN (0)
  AND cpr.map_id IN (
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
GROUP BY 1, 2, 3, 4;