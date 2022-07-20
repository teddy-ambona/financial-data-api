from flask import Blueprint


healthcheck = Blueprint('healthcheck', __name__)


@healthcheck.route('/_healthcheck', methods=['GET'])
def _healthcheck():
    return ''
