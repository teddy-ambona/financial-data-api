from schema import Schema


def test_time_series(client, populate_db):
    """
    GIVEN a StocksOHLCV model
    WHEN the '/stocks/time-series/<symbol> endpoint is requested (GET)
    THEN ensure the endpoint is up and running and the data is correctly formatted.
    """
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
    r = client.get('/stocks/time-series/AMZN')

    assert r.status_code == 200
    assert len(r.json) == 754
    validation_schema.validate(r.json)
