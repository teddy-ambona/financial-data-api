import unittest

from src.app import create_app, db


app = create_app()


class TestHealthCheck(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()

    def test_healthcheck(self):
        r = self.app.get('/_healthcheck')

        self.assertEqual(r.status_code, 200)


def import_csv_into_db(fpath, table_name, engine):
    """
    Use COPY command to populate the database.

    Parameters
    ----------
    fpath: str
    table_name: str(should contain schema name)
    engine: object

    Returns
    -------
    None
    """
    with open(fpath, 'r') as f:
        conn = engine.raw_connection()
        cursor = conn.cursor()
        cmd = f"COPY {table_name} FROM STDIN WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',')"
        cursor.copy_expert(cmd, f)
        conn.commit()


def populate_db():
    """
    Populate DB with the CSVs located in /tests/integration/test_data.

    This function is intended to be called before each test to make sure it starts
    with a fresh DB.
    """
    with app.app_context():
        db.engine.execute("CREATE SCHEMA IF NOT EXISTS market_data;")

        # Create tables with SQLAlchemy
        db.create_all()

        # Make function idempotent so that it can be called before each functional test
        db.engine.execute("TRUNCATE market_data.stocks_ohlcv;")

        import_csv_into_db("tests/integration/test_data/stocks_ohlcv.csv", "market_data.stocks_ohlcv", db.engine)
