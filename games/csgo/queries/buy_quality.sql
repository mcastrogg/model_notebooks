SELECT cpr.match_id, cpr.map_id, cpr.round_id, cpr.steam_id, cpr.primary_weapon_id, cpr.side,
has_helmet, armor, has_defuse,
starting_flashes, starting_incendiary, starting_smoke, starting_he, starting_decoy
FROM historical_csgo.csgo_player_rounds cpr
LEFT JOIN historical_csgo.csgo_map_rounds cmr ON cmr.round_id = cpr.round_id
LEFT JOIN historical_csgo.csgo_weapons cw ON cw.weapon_id = cpr.primary_weapon_id
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
    ));
