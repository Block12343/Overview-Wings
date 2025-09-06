import flask


def createApp():
    app = flask.Flask(__name__)
    return app