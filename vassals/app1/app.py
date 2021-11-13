from flask import Flask


app = Flask(__name__)

print("Booting app vassal..." * 100)


@app.route("/")
def hello_world():
    return "hello world"


@app.route("/test", methods=["POST"])
def test():
    return "post recieved"
