from games.csgo.constants import *
from typing import Dict, List
import pandas as pd

FULL_BUY = 3
HALF_BUY = 2
HALF_ECO = 1
FULL_ECO = 0


def get_buy_quality(data: List[Dict]):
    for d in data:
        d['round_spend'] = _total_money_spent(d)
        buy_quality = _determine_spend_level(d['round_spend'], d['side'])
        d = _one_hot_encode(d, buy_quality)

    return data


def _one_hot_encode(d: Dict, buy_quality: int):
    d['full_eco'] = 0
    d['half_eco'] = 0
    d['half_buy'] = 0
    d['full_buy'] = 0

    # for one hot encoding
    if buy_quality == FULL_BUY:
        d['full_buy'] = 1
    elif buy_quality == HALF_BUY:
        d['half_buy'] = 1
    elif buy_quality == HALF_ECO:
        d['half_eco'] = 1
    else:
        d['full_eco'] = 1

    return d


def _determine_spend_level(total_spent: int, side: str):
    if side == 'T':
        return _determine_spend_level_t(total_spent)
    return _determine_spend_level_ct(total_spent)


def _determine_spend_level_t(total_spent: int):
    if total_spent >= T_FULL_BUY:
        return FULL_BUY
    if total_spent >= T_HALF_BUY:
        return HALF_BUY
    if total_spent >= T_HALF_ECO:
        return HALF_ECO
    return FULL_ECO


def _determine_spend_level_ct(total_spent: int):
    if total_spent >= CT_FULL_BUY:
        return FULL_BUY
    if total_spent >= CT_HALF_BUY:
        return HALF_BUY
    if total_spent >= CT_HALF_ECO:
        return HALF_ECO
    return FULL_ECO


def _total_money_spent(data: Dict) -> int:
    primary_cost = _weapon_cost(data['primary_weapon_id'])
    he_cost = _grenade_cost(data['starting_he'], HE_ID)
    flash_cost = _grenade_cost(data['starting_flashes'], FLASH_ID)
    smoke_cost = _grenade_cost(data['starting_smoke'], SMOKE_ID)
    defuse_cost = 0
    armor_cost = 0
    if data['side'] == 'T':
        molly_cost = _grenade_cost(data['starting_incendiary'], MOLLY_ID)
    else:
        molly_cost = _grenade_cost(data['starting_incendiary'], INCENDIARY_ID)
        if data['has_defuse']:
            defuse_cost = _defuse_kit_cost()

    if data['armor'] == 100:
        armor_cost = _armor_vest_cost()

    total_money_spent = primary_cost + he_cost + flash_cost + smoke_cost + defuse_cost + armor_cost + molly_cost
    return total_money_spent


def _weapon_cost(weapon_id: int):
    return WEAPON_COSTS[weapon_id]


def _grenade_cost(grenade_count, grenade_id):
    return WEAPON_COSTS[grenade_id] * grenade_count


def _defuse_kit_cost():
    return WEAPON_COSTS[DEFUSE_ID]


def _armor_vest_cost():
    return WEAPON_COSTS[VEST_HELM_ID]


def main():
    from games.utils.query_reader import QueryReader
    from games.utils.conn import Conn
    qr = QueryReader('../queries')
    query = qr.read_query('buy_quality.sql').format(date="'2021-05-01'")
    conn = Conn()
    results = conn.big_fetch(query, as_dict=True, stats=True)
    data = get_buy_quality(results)
    df = pd.DataFrame(data)
    df.to_csv('../output/buy_quality_base.csv', index=False)


if __name__ == '__main__':
    main()

