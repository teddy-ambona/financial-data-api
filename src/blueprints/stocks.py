from flask import Blueprint, jsonify

from src.models import StocksOHLCV

stocks = Blueprint('stocks', __name__)


@stocks.route('/stocks/time-series/<symbol>', methods=['GET'])
def time_series(symbol):
    r = StocksOHLCV.query.filter(StocksOHLCV.symbol == symbol).all()
    return jsonify(r)
