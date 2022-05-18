SELECT cpr.match_id,
       cpr.steam_id,
       sum(CASE WHEN cpr.won = true then 1 else 0 end)/count(distinct cpr.map_id) as pistol_rounds_won_per_map
FROM historical_csgo.csgo_player_rounds cpr
LEFT JOIN historical_csgo.csgo_map_rounds cmr ON cpr.round_id = cmr.round_id
WHERE cmr.round_number in (1, 16)
and cpr.map_id IN (
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
group by 1,2;
