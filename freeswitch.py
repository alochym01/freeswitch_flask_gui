from flask_app import create_app, db
from flask_app.models.user import User
import click

app = create_app()

@app.shell_context_processor
def make_shell_context():
    return dict(app=app, db=db, User=User)

@app.cli.command(with_appcontext=False)
def initdb():
    """Initialize the database."""
    # Flask pushes an application context, which brings current_app and g to life. 
    # When the request is complete, the context is removed, along with these variables
    app.app_context().push()
    u = User(username='admin@example.com', domain='abc.com')
    u.set_password('password')
    try:
        db.session.add(u)
        db.session.commit()
        click.echo('Create User/Password successful with admin/password')
    except Exception as e:
        pass
        print(str(e))