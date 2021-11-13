from flask import Flask


app = Flask(__name__)

print("Booting app2 vassal..." * 100)


@app.route("/")
def hello_world():
    return "hello from app2"


@app.route("/test", methods=["POST"])
def test():
    return "post recieved to app2"
