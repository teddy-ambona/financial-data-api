from flask import Blueprint, jsonify, request
from schema import Schema, Use, Or, Optional
import pandas as pd

from src.models import StocksOHLCV
from src.helpers import resample_ohlcv_dataframe

stocks = Blueprint('stocks', __name__)


@stocks.route('/stocks/time-series/<symbol>', methods=['GET'])
def time_series(symbol):
    # Validate query parameters
    schema_args = Schema(
        {
            Optional("interval"): Use(int),
            Optional("frequency"): Or("Daily", "Weekly", "Monthly", "Quarterly", "Annual")
        }
    )
    try:
        args = schema_args.validate(request.args.to_dict())
    except Exception:
        return jsonify("Bad Request"), 400

    # Query data from the database
    query = StocksOHLCV.query.filter(StocksOHLCV.symbol == symbol)
    df = pd.read_sql(query.statement, query.session.bind)

    # Apply transformation
    if "interval" and "frequency" in args:
        df = resample_ohlcv_dataframe(df, args["interval"], args["frequency"])

    return jsonify(df.to_dict(orient="records"))
