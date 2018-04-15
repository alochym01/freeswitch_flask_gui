from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_login import LoginManager
from config import Config

db = SQLAlchemy()
migrate = Migrate()
login = LoginManager()
login.login_view = 'auth.login'
login.login_message = 'Please log in to access this page.'

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(Config)

    db.init_app(app)
    migrate.init_app(app, db)
    login.init_app(app)

    # ... no changes to blueprint registration
    from flask_app.auth import auth
    app.register_blueprint(auth)

    # ... no changes to blueprint registration
    from flask_app.errors import error
    app.register_blueprint(error)

    from flask_app.main import main
    app.register_blueprint(main)    
    # if not app.debug and not app.testing:
    #     # ... no changes to logging setup

    return app

