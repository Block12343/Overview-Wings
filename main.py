import docker
import flask

from util.models import jsonFile

networkConf = jsonFile('config/network.json', {"working-url": "node.example.com"})


