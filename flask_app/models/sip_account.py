from flask_app import db
from hashlib import md5
from datetime import datetime

class SipAcc(db.Model):
    __tablename__ = "sip_accounts"
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(64), index=True, unique=True)
    password = db.Column(db.String(128))
    domain = db.Column(db.String(120))
    toll_allow = db.Column(db.String(120))
    context = db.Column(db.String(120), default='default')
    max_calls = db.Column(db.Integer)
    caller_name = db.Column(db.String(120))
    outbound_caller_name = db.Column(db.String(120))
    caller_number = db.Column(db.String(120))
    outbound_caller_number = db.Column(db.String(120))
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)
    
    def __repr__(self):
        return '<SIP ACCOUNT {} and {}>'.format(self.username, self.password)

    def set_password(self, password):
        temp = '%s:%s:%s' % (self.username, self.domain, password)
        self.password = md5(temp.encode()).hexdigest()