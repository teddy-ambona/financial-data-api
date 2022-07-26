import pytest

from src.app import create_app, db


@pytest.fixture(scope="session")
def app():
    return create_app()


@pytest.fixture(scope="module")
def client(app):
    return app.test_client()


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
    """Populate DB with the CSVs located in /tests/integration/test_data."""
    db.engine.execute("CREATE SCHEMA IF NOT EXISTS market_data;")

    # Create tables with SQLAlchemy
    db.create_all()

    # Truncate the tables in case a test got interrupted before the teardown happened
    db.engine.execute("TRUNCATE market_data.stocks_ohlcv;")

    import_csv_into_db("tests/integration/test_data/stocks_ohlcv.csv", "market_data.stocks_ohlcv", db.engine)


@pytest.fixture()
def db_fixture():
    """
    Set state of the database.

    This function is intended to be called before each test to make sure
    it starts and ends with a fresh DB.
    """
    app = create_app()

    with app.app_context():
        populate_db()

        # Any teardown code for that fixture is placed after the yield.
        yield

        # Make function idempotent so that it can be called before each functional test
        db.engine.execute("TRUNCATE market_data.stocks_ohlcv;")


def populate_db_for_local_testing():
    """
    Populate DB.

    This function is intended to be called from the Makefile to populate the database for local testing.
    """
    app = create_app()

    with app.app_context():
        populate_db()
