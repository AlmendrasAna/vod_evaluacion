from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
    return "Bienvenido a Vod futura pagina de peliculas", 200

@app.route('/health')
def health():
    return "OK, están probando la ruta web", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)