from flask import render_template
from flask_app.main import main
from flask_login import login_required

@main.route('/', methods=['GET'])
@login_required
def index():
    return render_template('main/index.html')

