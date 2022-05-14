CT_REASONS = ['BombDefused', 'CTWin', 'TargetSaved']
T_REASONS = ['TerroristsWin', 'TargetBombed']

LOSING_BONUS = {
    1: 1400,
    2: 1900,
    3: 2400,
    4: 2900,
    5: 3400
    # 5+ is 3400
}

AFTER_2_WIN_LOSS_BONUS = {
    0: 1400,
    1: 1500,
    2: 2000,
    3: 2500,
    4: 3000
    # 4+ is 3000
}

PLAYER_BOMB_PLANT_BONUS = 300
PLAYER_BOMB_DEFUSE_BONUS = 300
TEAM_BOMB_DEFUSE_BONUS = 250
TEAM_BOMB_PLANT_BONUS = 250
ROUND_WIN_BASE = 3250
LOSS_AND_BOMB_PLANT_BONUS = 800

WEAPON_MONEY = {
    'pistol': 300,
    'melee': 1500,
    'cz75': 100,
    'smg': 600,
    'p90': 300,
    'shotgun': 900,
    'rifle': 300,
    'sniper': 300,
    'lmg': 300,
    'awp': 100,
    'grenade': 300,
    'zeus': 0
}
