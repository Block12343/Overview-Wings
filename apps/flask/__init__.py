from flask import Flask
from util.models import jsonFile

networkConf = jsonFile('config/network.json')

def createApp():
    app = Flask(__name__)
    app.config['SECRET_KEY'] = networkConf.read().get('flask_secret', 'default_secret_key')

    return app