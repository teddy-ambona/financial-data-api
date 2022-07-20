import os
import datetime as dt

from yaml import safe_load
from flask import Flask
from flask.json import JSONEncoder

from src.models import db
from src.blueprints.stocks import stocks
from src.blueprints.healthcheck import healthcheck


class CustomJSONEncoder(JSONEncoder):
    """Allow dates to be returned in YYYY-MM-DD format."""

    def default(self, object):
        if isinstance(object, dt.date):
            return object.isoformat()

        return super().default(object)


def create_app():
    app = Flask(__name__)
    app.register_blueprint(healthcheck)
    app.register_blueprint(stocks)

    # Fetch config
    ENVIRONMENT = os.environ['ENVIRONMENT']
    config = safe_load(open(f"/app/settings/{ENVIRONMENT}/config.yaml", 'r'))

    # Set up flask config
    app.config.update(config['APP'])
    app.json_encoder = CustomJSONEncoder

    string_con = "postgresql://{DB_USERNAME}@{DB_HOST}:{DB_PORT}/{DB_NAME}".format(**config['DB'])
    app.config['SQLALCHEMY_DATABASE_URI'] = string_con
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    db.init_app(app)

    return app


if __name__ == "__main__":
    app = create_app()
    app.run(host='0.0.0.0')
