import unittest

from src.app import app


class TestHealthCheck(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()

    def test_healthcheck(self):
        r = self.app.get('/_healthcheck')

        self.assertEqual(r.status_code, 200)
