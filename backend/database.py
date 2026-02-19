import sqlite3

class DatabaseWrapper:
    def __init__(self, db_name="burger_king.db"):
        self.db_name = db_name
        self.init_db()

    def init_db(self):
        # Connettiamo e creiamo le tabelle se non esistono
        conn = sqlite3.connect(self.db_name)
        cursor = conn.cursor()
        try:
            # Tabella Prodotti AGGIORNATA con 'descrizione'
            cursor.execute('''CREATE TABLE IF NOT EXISTS prodotti 
                             (id INTEGER PRIMARY KEY AUTOINCREMENT, 
                              nome TEXT, 
                              prezzo REAL, 
                              categoria TEXT, 
                              immagine TEXT,
                              descrizione TEXT)''')
            
            # Tabella Ordini
            cursor.execute('''CREATE TABLE IF NOT EXISTS ordini 
                             (id INTEGER PRIMARY KEY AUTOINCREMENT, 
                              totale REAL, 
                              dettagli TEXT, 
                              stato TEXT DEFAULT 'In Preparazione')''')
            
            conn.commit()
            print("Database inizializzato correttamente con supporto descrizioni.")
        except Exception as e:
            print(f"Errore inizializzazione database: {e}")
        finally:
            conn.close()

    def aggiungi_prodotto(self, nome, prezzo, categoria, immagine, descrizione=""):
        conn = sqlite3.connect(self.db_name)
        cursor = conn.cursor()
        try:
            cursor.execute("INSERT INTO prodotti (nome, prezzo, categoria, immagine, descrizione) VALUES (?, ?, ?, ?, ?)",
                           (nome, prezzo, categoria, immagine, descrizione))
            conn.commit()
        finally:
            conn.close()

    def get_prodotti(self):
        conn = sqlite3.connect(self.db_name)
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM prodotti")
        rows = cursor.fetchall()
        conn.close()
        # Mappatura aggiornata: r[5] è la descrizione
        return [{
            "id": r[0], 
            "nome": r[1], 
            "prezzo": r[2], 
            "categoria": r[3], 
            "immagine": r[4],
            "descrizione": r[5] if len(r) > 5 else ""
        } for r in rows]

    def elimina_prodotto(self, id_prodotto):
        conn = sqlite3.connect(self.db_name)
        cursor = conn.cursor()
        try:
            cursor.execute("DELETE FROM prodotti WHERE id = ?", (id_prodotto,))
            conn.commit()
            return cursor.rowcount > 0  # True se eliminato
        finally:
            conn.close()

    def crea_ordine(self, totale, dettagli):
        conn = sqlite3.connect(self.db_name)
        cursor = conn.cursor()
        try:
            cursor.execute("INSERT INTO ordini (totale, dettagli) VALUES (?, ?)", (totale, dettagli))
            conn.commit()
        finally:
            conn.close()
            
def elimina_ordine(self, ordine_id):
    conn = sqlite3.connect(self.db_name)
    cursor = conn.cursor()
    try:
        cursor.execute("DELETE FROM ordini WHERE id = ?", (ordine_id,))
        conn.commit()
    finally:
        conn.close()

    def get_ordini(self):
        conn = sqlite3.connect(self.db_name)
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM ordini")
        rows = cursor.fetchall()
        conn.close()
        return [{"id": r[0], "totale": r[1], "dettagli": r[2], "stato": r[3]} for r in rows]