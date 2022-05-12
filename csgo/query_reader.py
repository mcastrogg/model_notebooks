import os


class QueryReader:
    def __init__(self, query_dir) -> None:
        self.query_dir = query_dir
    
    def read_query(self, query_name):
        query_path = os.path.join(self.query_dir, query_name)
        with open(query_path, 'r') as f:
            return f.read()
