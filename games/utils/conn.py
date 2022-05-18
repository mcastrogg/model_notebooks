
import pandas as pd
import psycopg2.extras
import psycopg2
import time
import os

query_dir = os.path.join(os.path.abspath(''), '../csgo/queries')


def create_connection(): 
    return psycopg2.connect(
        dbname='main',
        host='main-us-e2.cmbsiiqeauby.us-east-2.rds.amazonaws.com',
        port=5432,
        user='doadmin',
        password='i39kew8n7jcat7l9'
    )


class Conn:
    def __init__(self):
        self.conn = create_connection()

    def run_query(self, query, cursor=None, stats=False):
        if cursor:
            cursor = self.conn.cursor(cursor_factory = psycopg2.extras.RealDictCursor)
        else:
            cursor = self.conn.cursor()

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
        except Exception as e:
            print('rolling back')
            print(e)
            self.conn.rollback()
        finally:
            cursor.close()

    def big_fetch(self, query, as_dict=False, fetch_size=30000, stats=False):
        cursor = self.conn.cursor('big_fetch_crusor')
        results = []
        if stats:
            start_time = time.time()
        try:
            cursor.execute(query)
            cols = []
            while True:
                rows = cursor.fetchmany(fetch_size)
                if not rows:
                    break
                if as_dict:
                    if not cols:
                        cols = [x[0] for x in cursor.description]

                    rows = [dict(zip(cols, x)) for x in rows]
                results.extend(rows)

            if stats:
                end_time = time.time()
                print(f'Time elapsed: {end_time - start_time}')
                print(f'Length of Results: {len(results)}')
                print(f'Sample Result: {results[0]}')
            cursor.close()
            return results
        except Exception as e:
            print('rolling back')
            print(e)
            self.conn.rollback()
        finally:
            cursor.close()

    def read_into_df(self, query, stats=False) -> pd.DataFrame:
        if stats:
            start_time = time.time()

        df = pd.read_sql(query, self.conn)

        if stats:
            end_time = time.time()
            print(f'Time elapsed: {end_time - start_time}')
            print(f'DF Shape: {df.shape}')

        return df
