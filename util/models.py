import json
import os

class jsonFile:

    def __init__(self, path, default={}):
        self.path = path

        # If path exists and is a directory, raise an error
        if os.path.isdir(self.path):
            raise ValueError(f"{self.path} is a directory, not a file.")

        # If file does not exist, create an empty JSON file
        if not os.path.exists(self.path):
            with open(self.path, 'w') as file:
                json.dump(default, file)

    def read(self):
        with open(self.path, 'r') as file:
            return json.load(file)

    def write(self, data):
        with open(self.path, 'w') as file:
            json.dump(data, file, indent=4)