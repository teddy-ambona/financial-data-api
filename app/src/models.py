from dataclasses import dataclass
import datetime as dt

from flask_sqlalchemy import SQLAlchemy


db = SQLAlchemy()


@dataclass
class StocksOHLCV(db.Model):
    """A dataclass decorator is used to enable serialization."""

    __tablename__ = 'stocks_ohlcv'
    __table_args__ = {"schema": "market_data"}

    symbol: int
    date: dt.date
    open: float
    high: float
    low: float
    close: float
    volume: int

    symbol = db.Column(db.String(10), primary_key=True)
    date = db.Column(db.Date, primary_key=True)
    open = db.Column(db.Float(2))
    high = db.Column(db.Float(2))
    low = db.Column(db.Float(2))
    close = db.Column(db.Float(2))
    volume = db.Column(db.Integer)
