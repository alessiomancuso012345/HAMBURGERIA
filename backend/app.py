from flask import Flask, request, jsonify, make_response
from flask_cors import CORS
from database import DatabaseWrapper

app = Flask(__name__)

# Configurazione CORS super permissiva per Codespaces
CORS(app, resources={r"/*": {"origins": "*"}}, supports_credentials=True)

db = DatabaseWrapper()

# Questo pezzo di codice forza gli header corretti su ogni risposta
@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
    return response

@app.route('/')
def home():
    return "Il Backend di Burger King è ONLINE!"

@app.route('/prodotti', methods=['GET', 'POST', 'OPTIONS'])
def gestisci_prodotti():
    if request.method == 'OPTIONS':
        return make_response({}, 200)
        
    if request.method == 'POST':
        try:
            dati = request.json
            db.aggiungi_prodotto(dati['nome'], dati['prezzo'], dati['categoria'], dati['immagine'])
            return jsonify({"messaggio": "Prodotto aggiunto!"}), 201
        except Exception as e:
            return jsonify({"errore": str(e)}), 500
            
    return jsonify(db.get_prodotti())

@app.route('/ordini', methods=['GET', 'POST', 'OPTIONS'])
def gestisci_ordini():
    if request.method == 'OPTIONS':
        return make_response({}, 200)

    if request.method == 'POST':
        try:
            dati = request.json
            db.crea_ordine(dati['totale'], dati['dettagli'])
            return jsonify({"messaggio": "Ordine ricevuto!"}), 201
        except Exception as e:
            return jsonify({"errore": str(e)}), 500
            
    return jsonify(db.get_ordini())

if __name__ == '__main__':
    # Debug=True aiuta a vedere gli errori nel terminale
    app.run(host='0.0.0.0', port=5000, debug=True)