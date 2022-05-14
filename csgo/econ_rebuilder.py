import itertools
from typing import List, Dict
from itertools import groupby
from constants import *
import pandas as pd
import time
import csv


# takes about 40-45 secs with using List[Dict] as input, using Dataframe takes about 5min
def run_econ_rebuild(data: List[Dict]) -> pd.DataFrame:
    data = _group_bomb_data(data)
    data = sorted(data, key=lambda i: (i['map_id'], i['steam_id'], i['round_number']))
    data = _calc_round_money(data)
    return pd.DataFrame(data)


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
        'is_tside': k[2],
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
    return groupby(data, lambda x: [x['map_id'], x['round_number'], x['is_tside']])


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

    if row['is_tside'] == 1:
        row['bomb_plant_bonus'] = PLAYER_BOMB_PLANT_BONUS if row['bomb_plants'] else 0
        if row['won'] == 1:
            row['team_bomb_explode_bonus'] = TEAM_BOMB_PLANT_BONUS if row['team_bomb_exploded'] else 0
        else:
            row['plant_but_lost_bonus'] = LOSS_AND_BOMB_PLANT_BONUS if row['team_bomb_plants'] else 0
    else:
        row['bomb_defuse_bonus'] = PLAYER_BOMB_DEFUSE_BONUS if row['bomb_defused'] else 0
        row['team_bomb_defuse_bonus'] = TEAM_BOMB_DEFUSE_BONUS if row['team_bomb_defused'] else 0

    return row


def _calc_total_money(mdf: pd.DataFrame) -> pd.DataFrame:
    mdf['total_money_made'] = mdf[[x for x in mdf.columns if x.endswith('_bonus')]].sum(axis=1)
    money_df = mdf.groupby(['match_id', 'map_id', 'steam_id']).sum()['total_money_made']
    money_df = money_df.reset_index()
    print(f'moneydf: {money_df.shape}')
    match_money_df = money_df.groupby(['match_id', 'steam_id']).agg(total_money_per_map=('total_money_made', 'mean'),
                                                                    total_money=(
                                                                    'total_money_made', 'sum')).reset_index()
    print(f'match_money: {match_money_df.shape}')
    return match_money_df


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


if __name__ == '__main__':
    print('Reading in csv')
    raw_data = read_in_csv_as_list('data/base_econ_df.csv')
    run_econ_rebuild(raw_data)
    # run_econ_rebuild(econ_df)
