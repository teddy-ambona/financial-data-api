from flask import Blueprint
from sqlalchemy.sql import text

from src.models import db

healthcheck = Blueprint('healthcheck', __name__)


@healthcheck.route('/_healthcheck', methods=['GET'])
def _healthcheck():
    # Ensure DB connection is properly established
    db.engine.execute(text("SELECT 1"))
    return ''
