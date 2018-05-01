# freeswitch_flask_gui
Using Freeswitch GUI

# using flask
export FLASK_APP=freeswitch.py
export FLASK_DEBUG=True

# using flask shell with click
``` python
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
```
run command `flask initdb`

# freeswitch user table
| username | domain | toll_allow   | context | max_calls | caller_number | outbound_caller_number | caller_name | outbound_caller_name |
|:--------:|:------:|:------------:|:-------:|:---------:|:-------------:|:----------------------:|:-----------:|:-------------------:|
| string   | string | string       | string  | integer   | integer       | integer                | string      | string              |
| 1000     | abc.com|local,domestic|default  | 1         | 1000          | +84966734472           | Do Nguyen Ha| Do Nguyen Ha        |