import unittest

from schema import Schema

from tests.integration.test_app import app, populate_db


class TestStocks(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.app = app.test_client()

    def setUp(self):
        populate_db()

    def test_time_series(self):
        """Ensure the endpoint is up and running and the data is correctly formatted."""
        validation_schema = Schema(
            [
                {
                    'symbol': str,
                    'date': str,
                    'open': float,
                    'high': float,
                    'low': float,
                    'close': float,
                    'volume': int
                }
            ]
        )
        r = TestStocks.app.get('/stocks/time-series/AMZN')

        self.assertEqual(r.status_code, 200)
        validation_schema.validate(r.json)
