from typing import List, Dict
import pandas as pd
import csv


def _find_trades(data: List[Dict]):

    data = sorted(data, key=lambda i: (i['map_id'], i['round_number'], i['seconds_elapsed']))
    previous_row = data[0]
    potential_trades = []

    # I already have to loop through it here, so why dont I just calc weapon vals here
    def inner(row):
        # non local variable ==> will use pre_value from the new_fun function
        nonlocal previous_row
        nonlocal potential_trades

        if (row['round_id'] == previous_row['round_id'] and
                (row['victim_steam_id'] == previous_row['killer_steam_id']) and
                (row['killer_steam_id'] == previous_row['victim_steam_id'])):

            potential_trades.append({
                'map_id': row['map_id'],
                'round_number': row['round_number'],
                'time_between': row['seconds_elapsed'] - previous_row['seconds_elapsed'],
                'previous_row_time': previous_row['seconds_elapsed'],
                'current_row_time': row['seconds_elapsed']
            })

        previous_row = row

    for row in data:
        inner(row)
    return potential_trades


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
    data = read_in_csv_as_list('output/trades.csv')
    trades = _find_trades(data)
    df = pd.DataFrame(trades)
    df.to_csv('output/trades_found.csv')

