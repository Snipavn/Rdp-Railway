from flask import Flask
app = Flask(__name__)

@app.route("/")
def home():
    return "✅ RDP Ubuntu với Chrome đang chạy - port 3389"

app.run(host="0.0.0.0", port=8080)
