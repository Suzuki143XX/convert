from flask import Flask, render_template, request, jsonify
import requests
import os

app = Flask(__name__)
RAPIDAPI_KEY = "19944b7749msh77a81c947752d8bp10ec7ejsn6e6afe8d0832"
RAPIDAPI_HOST = "youtube-mp36.p.rapidapi.com"

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/convert", methods=["POST"])
def convert():
    url = request.form.get("url")
    if not url:
        return jsonify({"error": "No URL provided"}), 400
    
    try:
        api_url = "https://youtube-mp36.p.rapidapi.com/mp3"
        headers = {
            "X-RapidAPI-Key": RAPIDAPI_KEY,
            "X-RapidAPI-Host": RAPIDAPI_HOST
        }
        response = requests.get(api_url, headers=headers, params={"url": url}, timeout=30)
        data = response.json()
        
        if response.status_code == 200 and data.get("status") == "ok":
            return jsonify({
                "success": True,
                "download_url": data.get("link"),
                "title": data.get("title", "YouTube Video")
            })
        else:
            return jsonify({"error": data.get("msg", "Conversion failed")}), 500
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
