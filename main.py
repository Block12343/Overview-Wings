import docker
import flask

from flask import createApp
from util.models import jsonFile


networkConf = jsonFile('config/network.json', {"working-url": "node.example.com"})

app = createApp()

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=9000)
    