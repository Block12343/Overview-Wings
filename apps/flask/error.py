from flask import Blueprint, render_template

error = Blueprint('error', __name__)

@error.app_errorhandler(404)
def not_found(e):
    return render_template("404.html"), 404

@error.app_errorhandler(500)
def internal_error(e):
    return render_template("500.html"), 500

@error.app_errorhandler(403)
def forbidden(e):
    return render_template("403.html"), 403