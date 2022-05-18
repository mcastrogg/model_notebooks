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



WEAPON_COSTS = {
    0: 0,  # Unkown

    # Pistols
    1: 200,  # P2000
    2: 200,  # Glock
    3: 300,  # p250
    4: 700,  # Desert Eagle
    5: 500,  # Five Seven
    6: 300,  # Dual Berettas
    7: 500,  # Tec9
    8: 500,  # CZ75
    9: 200,  # USPS
    10: 600,  # R8

    # SMG
    101: 1500,  # MP7
    102: 1250,  # MP9
    103: 1400,  # PP-Bizon
    104: 1050,  # Mac-10
    105: 1200,  # UMP
    106: 2350,  # P90
    107: 1500,  # MP5-SD

    # Shotgun
    201: 1100,  # Saw off
    202: 1050,  # Nova
    203: 1300,  # Mag-7
    204: 2000,  # XM1014
    205: 5200,  # M249
    206: 1700,  # Negev

    # Rifles
    301: 1800,  # Galil
    302: 2050,  # Famas
    303: 2700,  # AK47
    304: 3100,  # M4A4
    305: 2900,  # M4A1
    306: 1700,  # SSG 08
    307: 3000,  # SG 553
    308: 3300,  # Aug
    309: 4750,  # AWP
    310: 5000,  # SCAR
    311: 5000,  # G3SG1

    # Equipment
    401: 200,  # Zues
    403: 1000,  # Vest Helmet
    406: 400,  # Defuse Kit

    # Grenade
    501: 50,  # Decoy
    502: 400,  # Molly
    503: 600,  # Incendiary
    504: 200,  # Flash
    505: 300,  # Smoke
    506: 300,  # HE
}

_AK_COST = 2700
_MOLOTOV = 400

_M4A1S_COST = 2900
_INCENDIARY = 600
_DEFUSE_KIT = 400

_MP5_COST = 1500
_DESERT_EAGLE = 800

_VEST_HELMET = 1000
_FLASHBANG = 200
_HE = 300
_SMOKE_GRENADE = 300

MOLLY_ID = 502
INCENDIARY_ID = 503
FLASH_ID = 504
SMOKE_ID = 505
HE_ID = 506
DECOY_ID = 501
DEFUSE_ID = 406
VEST_HELM_ID = 403

T_FULL_BUY = _AK_COST + _VEST_HELMET + _SMOKE_GRENADE + _FLASHBANG + _HE
CT_FULL_BUY = _M4A1S_COST + _VEST_HELMET + _SMOKE_GRENADE + _FLASHBANG + _DEFUSE_KIT + _HE

T_HALF_BUY = _MP5_COST + _VEST_HELMET + _FLASHBANG
CT_HALF_BUY = _MP5_COST + _VEST_HELMET + _FLASHBANG

T_HALF_ECO = _DESERT_EAGLE + _FLASHBANG + _SMOKE_GRENADE + _MOLOTOV
CT_HALF_ECO = _DESERT_EAGLE + _FLASHBANG + _SMOKE_GRENADE + _INCENDIARY
