# freeswitch_flask_gui
- Using Freeswitch GUI

# using flask
- export FLASK_APP=freeswitch.py
- export FLASK_DEBUG=True
- setting flask using postgresql
    + export DATABASE_URL="postgresql://freeswitch:password@127.0.0.1:5432/freeswitch"
    + edit config.py and set `DATABASE_URL="postgresql://freeswitch:password@127.0.0.1:5432/freeswitch"`

# using flask with flask-migrate
- step 1: `flask db init`
- step 2: `flask db migrate`
- step 1: `flask db upgrade`

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
- run command `flask initdb`

# Postgres SQL Configuration
- Create user
    ```
        postgres# CREATE USER "freeswitch" WITH PASSWORD 'password';
    ```
- Create database
    ```
        postgres# CREATE DATABASE freeswitch;
    ```
- Grant privileges
    ```
        postgres# grant all privileges on database freeswitch to freeswitch;
    ```
- Testing connection to database
    ```
        [hadn@localhost ~]$ psql -d freeswitch -U freeswitch -W -h 127.0.0.1
    ```

# freeswitch user table
| username | domain | toll_allow   | context | max_calls | caller_number | outbound_caller_number | caller_name | outbound_caller_name |
|:--------:|:------:|:------------:|:-------:|:---------:|:-------------:|:----------------------:|:-----------:|:-------------------:|
| string   | string | string       | string  | integer   | integer       | integer                | string      | string              |
| 1000     | abc.com|local,domestic|default  | 1         | 1000          | +84966734472           | Do Nguyen Ha| Do Nguyen Ha        |

# Running flask with gunicorn, nginx web proxy and systemd
- create flask_app.service in `/etc/systemd/system/`
- the content:
```
[Unit]
Description = Flask GUI for Freeswitch
After = network.target
After = postgresql-9.6.service

[Service]
PermissionsStartOnly = true
PIDFile = /run/flask_app/flask_app.pid
User = hadn
Group = hadn
WorkingDirectory = /mnt/fs_gui
ExecStartPre = /bin/mkdir /run/flask_app
ExecStartPre = /bin/chown -R hadn:hadn /run/flask_app
ExecStart = /home/hadn/.local/share/virtualenvs/flask_large_admin_gui-EPTiH8UD/bin/gunicorn freeswitch:app -b 127.0.0.1:8000 -w 4 --pid /run/flask_app/flask_app.pid
ExecReload = /bin/kill -s HUP $MAINPID
ExecStop = /bin/kill -s TERM $MAINPID
ExecStopPost = /bin/rm -rf /run/flask_app
PrivateTmp = true

[Install]
WantedBy = multi-user.target
```
- create folder and change own to user who running flask
    + `/bin/mkdir /run/flask_app`
    + `/bin/chown -R hadn:hadn /run/flask_app`
- [reference link](https://bartsimons.me/gunicorn-as-a-systemd-service/)
- nginx configuration and [reference link](https://blog.miguelgrinberg.com/post/the-flask-mega-tutorial-part-xvii-deployment-on-linux)
```
server {
    # listen on port 80 (http)
    listen 80;
    server_name _;
    location / {
        # redirect any requests to the same URL but on https
        return 301 https://$host$request_uri;
    }
}
server {
    # listen on port 443 (https)
    listen 443 ssl;
    server_name _;

    # location of the self-signed SSL certificate
    ssl_certificate /home/ubuntu/microblog/certs/cert.pem;
    ssl_certificate_key /home/ubuntu/microblog/certs/key.pem;

    # write access and error logs to /var/log
    access_log /var/log/microblog_access.log;
    error_log /var/log/microblog_error.log;

    location / {
        # forward application requests to the gunicorn server
        proxy_pass http://localhost:8000;
        proxy_redirect off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /static {
        # handle static files directly, without forwarding to the application
        alias /mnt/fs_gui/flask_app/static;
        expires 30d;
    }
}
```