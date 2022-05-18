select cpr.match_id, cpr.steam_id, (CASE WHEN max(cpr.team_name) = max(cmd.winner) THEN 1 ELSE 0 END) as won
from historical_csgo.csgo_match_data cmd
LEFT JOIN historical_csgo.csgo_player_rounds cpr ON cpr.match_id = cmd.match_id
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
        WHERE cmd.date  >= {date}
    )
)
GROUP BY 1,2;