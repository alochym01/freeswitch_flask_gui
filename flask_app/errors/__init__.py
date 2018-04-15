from flask import Blueprint

error = Blueprint('errors', __name__, url_prefix='errors')

from flask_app.errors import handlers