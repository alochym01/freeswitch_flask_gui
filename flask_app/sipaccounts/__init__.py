from flask import Blueprint

sip_account = Blueprint('sip-account', __name__, url_prefix='/sip-accounts')

from flask_app.sipaccounts import sipaccount