from flask import Flask, request, jsonify, make_response
from flask_cors import CORS
from database import DatabaseWrapper

app = Flask(__name__)

# Configurazione CORS super permissiva per GitHub Codespaces
CORS(app, resources={r"/*": {"origins": "*"}}, supports_credentials=True)

# Inizializzazione del wrapper del database
db = DatabaseWrapper()

# Header di sicurezza e CORS per ogni risposta
@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Headers', 'Content-Type,Authorization')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS')
    return response

@app.route('/')
def home():
    return "Il Backend di Hamburgeria di Mitzov e Mancuso è ONLINE! (Supporto Descrizioni Attivo)"

# --- ROTTA PRODOTTI ---
@app.route('/prodotti', methods=['GET', 'POST', 'OPTIONS'])
@app.route('/prodotti/<int:id_prodotto>', methods=['DELETE', 'OPTIONS'])
def gestisci_prodotti(id_prodotto=None):
    if request.method == 'OPTIONS':
        return make_response({}, 200)
        
    if request.method == 'POST':
        try:
            dati = request.json
            # Verifica che i campi obbligatori ci siano
            if not dati.get('nome') or not dati.get('prezzo'):
                return jsonify({"errore": "Nome e prezzo sono obbligatori"}), 400

            # Estrazione dati (con .get() per gestire valori mancanti)
            nome = dati['nome']
            prezzo = dati['prezzo']
            categoria = dati.get('categoria', 'Panini')
            immagine = dati.get('immagine', '')
            descrizione = dati.get('descrizione', '') # Nuovo campo!

            # Validazione prezzo
            if prezzo < 1:
                return jsonify({"errore": "Il prezzo deve essere almeno 1"}), 400

            # Salvataggio nel database
            db.aggiungi_prodotto(nome, prezzo, categoria, immagine, descrizione)
            
            print(f"DEBUG: Aggiunto prodotto {nome} con descrizione: {descrizione}")
            return jsonify({"messaggio": "Prodotto aggiunto con successo!"}), 201
            
        except Exception as e:
            print(f"ERRORE POST /prodotti: {e}")
            return jsonify({"errore": str(e)}), 500
            
    if request.method == 'DELETE':
        try:
            if db.elimina_prodotto(id_prodotto):
                return jsonify({"messaggio": "Prodotto eliminato con successo!"}), 200
            else:
                return jsonify({"errore": "Prodotto non trovato"}), 404
        except Exception as e:
            print(f"ERRORE DELETE /prodotti/{id_prodotto}: {e}")
            return jsonify({"errore": str(e)}), 500
            
    # GET: Restituisce la lista di tutti i prodotti
    return jsonify(db.get_prodotti())

# --- ROTTA ORDINI ---
@app.route('/ordini', methods=['GET', 'POST', 'OPTIONS'])
def gestisci_ordini():
    if request.method == 'OPTIONS':
        return make_response({}, 200)

    if request.method == 'POST':
        try:
            dati = request.json
            # db.crea_ordine accetta totale e dettagli (stringa JSON o testo)
            db.crea_ordine(dati['totale'], dati['dettagli'])
            return jsonify({"messaggio": "Ordine ricevuto e inviato in cucina!"}), 201
        except Exception as e:
            print(f"ERRORE POST /ordini: {e}")
            return jsonify({"errore": str(e)}), 500
            
    # GET: Restituisce lo storico degli ordini per la cucina
    return jsonify(db.get_ordini())

@app.route('/ordini/<int:id>', methods=['DELETE', 'OPTIONS'])
def elimina_ordine(id):
    if request.method == 'OPTIONS':
        return make_response({}, 200)
    try:
        db.elimina_ordine(id)
        return jsonify({"messaggio": "Ordine rimosso correttamente"}), 200
    except Exception as e:
        return jsonify({"errore": str(e)}), 500

if __name__ == '__main__':
    # Avvio del server sulla porta 5000
    # Debug=True permette di vedere le modifiche al codice senza riavviare manualmente
    app.run(host='0.0.0.0', port=5000, debug=True)