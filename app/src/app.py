import os
import json
import datetime as dt

import boto3
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
    config = safe_load(open(f'/app/settings/{ENVIRONMENT}/config.yaml', 'r'))

    # Fetch secrets from AWS Secrets Manager
    if "LOCALSTACK" in config:
        boto_client = boto3.client('secretsmanager', endpoint_url=config['LOCALSTACK']['ENDPOINT_URL'])
    else:
        boto_client = boto3.client('secretsmanager')

    response = boto_client.get_secret_value(SecretId='db/credentials')
    db_secrets = json.loads(response['SecretString'])

    # Set up flask config
    app.config.update(config['APP'])
    app.json_encoder = CustomJSONEncoder

    string_con = "postgresql://{DB_USERNAME}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}".format(**db_secrets, **config['DB'])
    app.config['SQLALCHEMY_DATABASE_URI'] = string_con
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    db.init_app(app)

    return app


if __name__ == "__main__":
    app = create_app()
    app.run(host='0.0.0.0')
