from flask import Blueprint

main = Blueprint('main', __name__, url_prefix='/')

from flask_app.main import routes