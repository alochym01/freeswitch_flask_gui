from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_login import LoginManager
from config import Config
from flask_debugtoolbar import DebugToolbarExtension

db = SQLAlchemy()
migrate = Migrate()
login = LoginManager()
login.login_view = 'auth.login'
login.login_message = 'Please log in to access this page.'
toolbar = DebugToolbarExtension()

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(Config)

    db.init_app(app)
    migrate.init_app(app, db)
    login.init_app(app)
    toolbar.init_app(app)

    # register main blueprint
    from flask_app.main import main
    app.register_blueprint(main)    

    # register authentication blueprint
    from flask_app.auth import auth
    app.register_blueprint(auth)

    # register errors blueprint
    from flask_app.errors import error
    app.register_blueprint(error)

    # register sip accounts blueprint
    from flask_app.sipaccounts import sip_account
    app.register_blueprint(sip_account)

    # if not app.debug and not app.testing:
    #     # ... no changes to logging setup

    return app

