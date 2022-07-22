import datetime as dt

import pandas as pd

from src.helpers import resample_ohlcv_dataframe


def test_resample_ohlcv_dataframe():
    df = pd.DataFrame(
        {
            "symbol": ["AMZN", "AMZN", "AMZN", "AMZN"],
            "date": [dt.date(2022, 1, 5), dt.date(2022, 1, 6), dt.date(2022, 2, 5), dt.date(2022, 2, 6)],
            "open": [150, 155, 160, 165],
            "high": [154, 160, 172, 168],
            "low": [152, 151, 159, 162],
            "close": [154, 158, 171, 168],
            "volume": [1000, 700, 1200, 2000]
        }
    )
    df_output = resample_ohlcv_dataframe(df, 1, "Monthly")

    df_expected = pd.DataFrame(
        {
            "symbol": ["AMZN", "AMZN"],
            "period_start": [dt.date(2022, 1, 1), dt.date(2022, 2, 1)],
            "open": [150, 160],
            "high": [160, 172],
            "low": [151, 159],
            "close": [158, 168],
            "volume": [1700, 3200]
        }
    )
    pd.testing.assert_frame_equal(df_output, df_expected)
