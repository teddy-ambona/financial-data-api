import pandas as pd


def resample_ohlcv_dataframe(df, interval, frequency):
    """
    Resample dataframe with specified time interval.

    Parameters
    ----------
    df: pd.DataFrame
    interval: int
    frequency: str("Daily", "Weekly", "Monthly", "Quarterly", "Annual")

    Returns
    -------
    pd.DataFrame
    """
    frequency_map = {
        "Daily": "D",
        "Weekly": "W",
        "Monthly": "MS",
        "Quarterly": "QS",
        "Annual": "AS",
    }
    frequency = frequency_map[frequency]

    df["date"] = pd.to_datetime(df["date"])
    df.set_index("date", inplace=True)
    df = df.groupby('symbol').resample(f"{interval}{frequency}")
    df = df.agg(
        {
            "open": "first",
            "high": "max",
            "low": "min",
            "close": "last",
            "volume": "sum",
        }
    )
    df = df.reset_index().rename(columns={"date": "period_start"})
    df["period_start"] = df["period_start"].dt.date
    return df
