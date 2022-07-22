from schema import Schema

from src.helpers import resample_ohlcv_dataframe


def test_time_series(client, populate_db):
    """
    GIVEN a StocksOHLCV model
    WHEN the '/stocks/time-series/<symbol> endpoint is requested (GET)
    THEN ensure the endpoint is up and running and the data is correctly formatted.
    """
    r = client.get('/stocks/time-series/AMZN')

    assert r.status_code == 200
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
    validation_schema.validate(r.json)
    assert len(r.json) == 754


def test_time_series_resampled(client, populate_db, mocker):
    """
    GIVEN a StocksOHLCV model
    WHEN the '/stocks/time-series/<symbol> endpoint is requested (GET) with interval and frequency parameters
    THEN ensure the endpoint calls the resampling function and the data is correctly formatted.
    """
    # Use wraps=resample_ohlcv_dataframe to avoid obstructing implementation of patched function.
    mock_resample_ohlcv_dataframe = mocker.patch(
        "src.blueprints.stocks.resample_ohlcv_dataframe",
        wraps=resample_ohlcv_dataframe
    )
    r = client.get(
        '/stocks/time-series/AMZN',
        query_string={
            "interval": 1,
            "frequency": "Monthly",
        }
    )

    assert r.status_code == 200
    validation_schema = Schema(
        [
            {
                'symbol': str,
                'period_start': str,
                'open': float,
                'high': float,
                'low': float,
                'close': float,
                'volume': int
            }
        ]
    )
    validation_schema.validate(r.json)
    assert mock_resample_ohlcv_dataframe.called
    assert len(r.json) == 37


def test_time_series_incorrect_params(client, populate_db):
    """
    GIVEN a StocksOHLCV model
    WHEN the '/stocks/time-series/<symbol> endpoint is requested (GET) with wrong HTTP parameters.
    THEN ensure the endpoint returns 400 Bad Request.
    """
    r = client.get(
        '/stocks/time-series/AMZN',
        query_string={
            "interval": 1,
            "frequency": "wrong param",
        }
    )

    assert r.status_code == 400
