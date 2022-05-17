import itertools
from tracemalloc import start
from typing import List, Dict
from itertools import groupby
from zipapp import create_archive
from constants import *
from query_reader import QueryReader
import pandas as pd
import psycopg2
import time
import csv


# takes about 40-45 secs with using List[Dict] as input, using Dataframe takes about 5min. With ~2m rows
# really shits the bed when we pass it ~14m
def run_econ_rebuild_return_df(data: List[Dict]) -> pd.DataFrame:
    data = run_econ_rebuild(data)
    return create_match_money_df(data)


def create_match_money_df(data: List[Dict]) -> pd.DataFrame:
    df = pd.DataFrame(data)
    df.to_csv('output/raw_econ_rebuild.csv', index=False)
    money_df = df.groupby(['match_id', 'map_id', 'steam_id']).sum().reset_index()
    money_df.to_csv('output/raw_econ_rebuild_group1.csv', index=False)
    # money_df2 = df.groupby(['match_id', , 'steam_id']).sum().reset_index()
    # money_df2.to_csv('output/raw_econ_rebuild_group1.csv', index=False)
    match_money_df = money_df.groupby(['match_id', 'steam_id']).mean()
    return match_money_df


def run_econ_rebuild(data: List[Dict]) -> pd.DataFrame:
    gbs = time.time()
    data = _group_bomb_data(data)
    gbe = time.time()
    print('Time take to group for bomb', gbe-gbs)
    ss = time.time()
    data = sorted(data, key=lambda i: (i['map_id'], i['steam_id'], i['round_number']))
    se = time.time()
    print('Time taken to sort for calcing round money', se-ss)
    scm = time.time()
    data = _calc_round_money(data)
    ecm = time.time()
    print('time taken to calc round money', ecm-scm)
    return data


def _calc_round_money(data: List[Dict]):
    previous_row = data[0]
    prev_steam_id = previous_row['steam_id']
    prev_win_value = 0
    prev_loss_value = 0
    two_win_streak_achieved = False

    # I already have to loop through it here, so why dont I just calc weapon vals here
    def inner(row):
        # non local variable ==> will use pre_value from the new_fun function
        nonlocal prev_win_value
        nonlocal prev_loss_value
        nonlocal prev_steam_id
        nonlocal previous_row
        nonlocal two_win_streak_achieved

        if prev_steam_id != row['steam_id']:
            # so this means that we are switching to a new player.
            prev_steam_id = row['steam_id']
            two_win_streak_achieved = False

            if row['won'] == 1:
                prev_win_value = 1
                prev_loss_value = 0
                round_end_bonus = ROUND_WIN_BASE
            else:
                prev_win_value = 0
                prev_loss_value = 1
                round_end_bonus = LOSING_BONUS[prev_loss_value]
        else:
            if row['won'] == 1:
                prev_win_value = prev_win_value + 1
                if prev_win_value >= 2:
                    two_win_streak_achieved = True
                else:
                    two_win_streak_achieved = False
                prev_loss_value = 0
                round_end_bonus = ROUND_WIN_BASE
            else:
                prev_loss_value = prev_loss_value + 1
                prev_win_value = 0
                round_end_bonus = _round_end_bonus_check(prev_loss_value, two_win_streak_achieved)

        previous_row = row
        return prev_win_value, prev_loss_value, round_end_bonus

    # weapon_kills: weapon_name
    key_list = {x: x.split('_')[0] for x in data[0].keys() if x.endswith('_kills')}

    for row in data:
        row['win_streak'], row['loss_streak'], row['round_end_bonus'] = inner(row)
        row = _apply_weapon_bonus(row, key_list)
        row = _apply_bomb_bonus(row)
        row = _calc_total_money_made(row)
    return data


def _round_end_bonus_check(current_loss_streak: int, two_win_streak_achieved: bool):
    if two_win_streak_achieved:
        if current_loss_streak >= 4:
            round_end_bonus = AFTER_2_WIN_LOSS_BONUS[4]
        else:
            round_end_bonus = AFTER_2_WIN_LOSS_BONUS[current_loss_streak]
    else:
        if current_loss_streak >= 5:
            round_end_bonus = LOSING_BONUS[5]
        else:
            round_end_bonus = LOSING_BONUS[current_loss_streak]

    return round_end_bonus


def _group_bomb_data(data: List[Dict]):
    # takes ~10 secs total, df was taking over a min
    groupped_data = [{
        'map_id': k[0],
        'round_number': k[1],
        'side': k[2],
        'data': list(group)
    } for k, group in _group_list(data)]

    new_data = []
    for var in groupped_data:
        # not all players will have this, only one per team needs it. We must map it to the
        # rest of the team
        bomb_defused, bomb_exploded, bomb_plants = zip(*[[x['bomb_defused'], x['bomb_exploded'], x['bomb_plants']] for x in var['data']])
        update_vals = {
            'team_bomb_defused': max(bomb_defused),
            'team_bomb_exploded': max(bomb_exploded),
            'team_bomb_plants': max(bomb_plants)
        }
        new_data.extend([{**v, **update_vals} for v in var['data']])

    return new_data


def _group_list(data: List[Dict]) -> itertools.groupby:
    return groupby(data, lambda x: [x['map_id'], x['round_number'], x['side']])


def _apply_weapon_bonus(row: Dict, weapon_dict: Dict[str, str]) -> Dict:
    for weapon_key, weapon_name in weapon_dict.items():
        row[weapon_name + '_bonus'] = row[weapon_key] * WEAPON_MONEY[weapon_name]
    return row


def _apply_bomb_bonus(row: Dict) -> Dict:
    # In Bomb Defusal, surviving Terrorists will not receive any round-end money if the round is lost by running out of time.
    # How do we account for the above ^
    row['bomb_plant_bonus'] = 0
    row['team_bomb_explode_bonus'] = 0
    row['plant_but_lost_bonus'] = 0
    row['bomb_defuse_bonus'] = 0
    row['team_bomb_defuse_bonus'] = 0

    if row['side'] == 'T':
        row['bomb_plant_bonus'] = PLAYER_BOMB_PLANT_BONUS if row['bomb_plants'] else 0
        if row['won'] == 1:
            row['team_bomb_explode_bonus'] = TEAM_BOMB_PLANT_BONUS if row['team_bomb_exploded'] else 0
        else:
            row['plant_but_lost_bonus'] = LOSS_AND_BOMB_PLANT_BONUS if row['team_bomb_plants'] else 0
    else:
        row['bomb_defuse_bonus'] = PLAYER_BOMB_DEFUSE_BONUS if row['bomb_defused'] else 0
        row['team_bomb_defuse_bonus'] = TEAM_BOMB_DEFUSE_BONUS if row['team_bomb_defused'] else 0

    return row


def _calc_total_money_made(row: Dict) -> Dict:
    row['total_money_made'] = sum([v for k,v in row.items() if k.endswith('_bonus')])
    return row


def read_in_csv_as_list(path):
    csv_data = []
    with open(path) as f:
        for row in csv.DictReader(f, skipinitialspace=True):
            new_row = {}
            for k, v in row.items():
                if k == 'team_name' or k == 'round_end_reason':
                    new_row[k] = str(v)
                else:
                    new_row[k] = int(v)
            csv_data.append(new_row)
    return csv_data


def result_group_check(data: List[Dict]):
    # If one player on a map has incorrect row count, then they will keep being added to pending data
    valid_data = []
    pending_data = []
    grouped_data = groupby(data, lambda x: x['map_id'])
    for key, group in grouped_data:
        group = list(group)
        steam_id_group = {steam_id: len([x for x in data])
                          for steam_id, data in groupby(group, lambda x: x['steam_id'])}
        if len(steam_id_group) != 10:
            # not enough steam_ids
            pending_data.extend(group)
            continue

        vals = list(steam_id_group.values())
        max_value = max(vals)

        if vals.count(max_value) != len(vals):
            # not all steam_ids have mac row
            pending_data.extend(group)
        else:
            valid_data.extend(group)

    return valid_data, pending_data


def create_connection(): 
    return psycopg2.connect(
        dbname='main',
        host='main-us-e2.cmbsiiqeauby.us-east-2.rds.amazonaws.com',
        port=5432,
        user='doadmin',
        password='i39kew8n7jcat7l9'
    )


def big_fetch(connection, query, cursor=None, fetch_size=30000):
    if cursor:
        cursor = connection.cursor('big_fetch_cursor', cursor_factory = cursor)
    else:
        cursor = connection.cursor('big_fetch_crusor')

    pending_results = []
    results = []
    cols = []
    cursor.execute(query)

    start_total_time = time.time()
    while True:
        start_time = time.time()
        rows = cursor.fetchmany(fetch_size)
        if not cols:
            cols = [desc[0] for desc in cursor.description]
        if not rows:
            break
        end_time = time.time()
        print('Time elapsed', end_time - start_time)

        rows = [dict(zip(cols, x)) for x in rows]
        rows.extend(pending_results)
        valid_rows, pending_rows = result_group_check(rows)
        processed_rows = run_econ_rebuild(valid_rows)
        results.extend(processed_rows)
        pending_results = pending_rows

    end_total_time = time.time()

    print('Total time elapsed', end_total_time - start_total_time)
    print(f'Length of Results: {len(results)}')
    print(f'Sample Result: {results[0]}')
    cursor.close()
    return results


if __name__ == '__main__':
    qr = QueryReader('queries')
    econ_query = qr.read_query('econ_mat_view.sql').format(date="'2021-05-01'")
    # print('Reading in csv')
    # raw_data = read_in_csv_as_list('data/base_econ_df.csv')
    conn = create_connection()
    econ_data = big_fetch(conn, econ_query, fetch_size=500000)
    econ_df = create_match_money_df(econ_data)
    econ_df.to_csv('output/match_money_df.csv', index=False)
    # run_econ_rebuild(raw_data)
    # run_econ_rebuild(econ_df)
