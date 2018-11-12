from flask_app.sipaccounts import sip_account
from flask_app.sipaccounts.sipform import SipAccount
from flask_app.models.sip_account import SipAcc
from flask import render_template, redirect, url_for, flash, request
from flask_login import login_required
from flask_app import db
import redis

@sip_account.route('/')
@login_required
def index():
    sipaccs = SipAcc.query.all()
    return render_template('sipaccs/index.html', sipaccs=sipaccs)

@sip_account.route('/create')
@login_required
def create():
    form = SipAccount()
    return render_template('sipaccs/create.html', form=form)

@sip_account.route('/store', methods=['POST'])
@login_required
def store():
    form = SipAccount()
    if form.validate_on_submit():
        sipacc = SipAcc.query.filter_by(username=form.username.data).first()
        if sipacc:
            flash('username is already used')
            return redirect(url_for('sip-account.create'))
        print(form)
        # todo should be save as a record in database
        sip = SipAcc(
                username=form.username.data,
                domain=form.domain.data,
                toll_allow=form.toll_allow.data,
                context=form.context.data,
                max_calls=form.max_calls.data,
                caller_number=form.caller_number.data,
                outbound_caller_number=form.outbound_caller_number.data,
                caller_name=form.caller_name.data,
                outbound_caller_name=form.outbound_caller_name.data
            )
        sip.set_password(form.password.data)
        db.session.add(sip)
        db.session.commit()
        flash('Congratulations, Created successfully!')
        return redirect(url_for('sip-account.index'))

    # debug errors of form submit
    # https://stackoverflow.com/questions/6463035/wtforms-getting-the-errors
    # for field, errors in form.errors.items():
    #     print(form[field].label)
    #     print(', '.join(errors))
    return redirect(url_for('sip-account.create', form=form))

@sip_account.route('/show/<int:id>')
@login_required
def show(id):
    sipacc = SipAcc.query.filter_by(id=id).first()
    return render_template('sipaccs/show.html', sipacc=sipacc)

@sip_account.route('/edit/<int:id>')
@login_required
def edit(id):
    form = SipAccount()
    sipacc = SipAcc.query.filter_by(id=id).first()
    return render_template('sipaccs/edit.html', sipacc=sipacc, form=form)

@sip_account.route('/update/<int:id>', methods=['POST'])
@login_required
def update(id):
    form = SipAccount()
    sipacc = SipAcc.query.filter_by(id=id).first()
    if form.validate_on_submit():
        sipacc.username=form.username.data
        sipacc.domain=form.domain.data
        sipacc.toll_allow=form.toll_allow.data
        sipacc.context=form.context.data
        sipacc.max_calls=form.max_calls.data
        sipacc.caller_number=form.caller_number.data
        sipacc.outbound_caller_number=form.outbound_caller_number.data
        sipacc.caller_name=form.caller_name.data
        sipacc.outbound_caller_name=form.outbound_caller_name.data
        sipacc.set_password(form.password.data)
        db.session.commit()
        redis_key = sipacc.username + '_' + sipacc.domain
        try:
            r = redis.StrictRedis(host='localhost', port=6379, db=0)
            r.delete(redis_key)
            r.connection_pool.disconnect()
        except:
            pass
        flash('Update successfully')
        return redirect(url_for('sip-account.index'))
    return render_template('sipaccs/edit.html', sipacc=sipacc, form=form)

@sip_account.route('/delete/<int:id>', methods=['GET', 'POST'])
@login_required
def delete(id):
    form = SipAccount()
    sipacc = SipAcc.query.filter_by(id=id).first()
    if request.method == 'GET':
        return render_template('sipaccs/delete.html', sipacc=sipacc, form=form)
    redis_key = sipacc.username + '_' + sipacc.domain
    try:
        r = redis.StrictRedis(host='localhost', port=6379, db=0)
        r.delete(redis_key)
        r.connection_pool.disconnect()
    except:
        pass
    db.session.delete(sipacc)
    db.session.commit()
    flash('Delete successfully')
    return redirect(url_for('sip-account.index'))