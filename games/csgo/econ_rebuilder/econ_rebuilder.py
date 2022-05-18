from games.csgo.econ_rebuilder.round_bonus_calculator import run_econ_rebuild
from games.csgo.econ_rebuilder.buy_quality import get_buy_quality
from games.utils.conn import Conn
from games.utils.query_reader import QueryReader
from datetime import datetime


class EconRebuilder:
    def __init__(self, conn: Conn, base_date: datetime):
        self._conn = conn
        self._qr = QueryReader('../queries')
        self.base_date = base_date.strftime("%Y-%m-%d")
        self.wrapped_base_date = f"'{self.base_date}'"

    def run(self):
        round_bonuses = self.calculate_round_bonuses()
        buy_quality = self.calculate_buy_quality()

    def calculate_round_bonuses(self):
        query = self.read_query("econ_mat_view.sql")
        rows = self._conn.big_fetch(query, as_dict=True)
        data = run_econ_rebuild(rows)
        return data

    def calculate_buy_quality(self):
        query = self.read_query('buy_quality.sql')
        rows = self._conn.big_fetch(query, as_dict=True)
        data = get_buy_quality(rows)
        return data

    def read_query(self, query_name: str) -> str:
        return self._qr.read_query(query_name).format(date=self.wrapped_base_date)

