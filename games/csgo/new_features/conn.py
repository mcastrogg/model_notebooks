
import pandas as pd
import psycopg2.extras
import psycopg2
import time
import os

query_dir = os.path.join(os.path.abspath(''), 'queries')

def create_connection(): 
    return psycopg2.connect(
        dbname='main',
        host='main-us-e2.cmbsiiqeauby.us-east-2.rds.amazonaws.com',
        port=5432,
        user='doadmin',
        password='i39kew8n7jcat7l9'
    )

def run_query(connection, query, cursor=None, stats=False):
    if cursor:
        cursor = connection.cursor(cursor_factory = psycopg2.extras.RealDictCursor)
    else:
        cursor = connection.cursor()
    try:
        if stats:
            start_time = time.time()
        cursor.execute(query)
        results = cursor.fetchall()

        if stats:
            end_time = time.time()

        if len(results[0]) == 1:
            results = [x[0] for x in results]
        else:
            results = [x for x in results]
        if stats:
            print(f'Time elapsed: {end_time - start_time}')
            print(f'Length of Results: {len(results)}')
            print(f'Sample Result: {results[0]}')
        return results
    except:
        print('rolling back')
        connection.rollback()
    finally:
        cursor.close()

def big_fetch(connection, query, cursor=None, fetch_size=30000):
    if cursor:
        cursor = connection.cursor('big_fetch_cursor', cursor_factory = cursor)
    else:
        cursor = connection.cursor('big_fetch_crusor')
    results = []
    start_time = time.time()
    cursor.execute(query)
    while True:
        rows = cursor.fetchmany(fetch_size)
        if not rows:
            break
        results.extend(rows)

    end_time = time.time()
    print(f'Time elapsed: {end_time - start_time}')
    print(f'Length of Results: {len(results)}')
    print(f'Sample Result: {results[0]}')
    cursor.close()
    return results


def read_into_df(connection, query, stats=False) -> pd.DataFrame:
    if stats:
        start_time = time.time()
    df = pd.read_sql(query, connection)
    if stats:
        end_time = time.time()
        print(f'Time elapsed: {end_time - start_time}')
        print(f'DF Shape: {df.shape}')
    return df