from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField
from wtforms.validators import DataRequired
from flask_app.models.sip_account import SipAcc


class SipAccount(FlaskForm):
    username = StringField('Username', validators=[DataRequired()])
    password = PasswordField('Password', validators=[DataRequired()])
    domain = StringField('Domain', validators=[DataRequired()])
    toll_allow = StringField('Toll Allow', validators=[DataRequired()])
    context = StringField('Context', validators=[DataRequired()])
    max_calls = StringField('Max Calls', validators=[DataRequired()])
    caller_name = StringField('Caller Name', validators=[DataRequired()])
    outbound_caller_name = StringField('Outbound Caller Name', validators=[DataRequired()])
    caller_number = StringField('Caller Number', validators=[DataRequired()])
    outbound_caller_number = StringField('Outbound Caller Number', validators=[DataRequired()])
    # submit = SubmitField('Create')