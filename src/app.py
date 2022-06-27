import os

from yaml import safe_load
from flask import Flask


app = Flask(__name__)

# Fetch config
ENVIRONMENT = os.environ['ENVIRONMENT']
config = safe_load(open(f"/app/config/{ENVIRONMENT}/config.yaml", 'r'))

# Set up flask config
app.config.update(config['APP'])


@app.route('/_healthcheck', methods=['GET'])
def _healthcheck():
    return ''


if __name__ == "__main__":
    app.run(host='0.0.0.0')
