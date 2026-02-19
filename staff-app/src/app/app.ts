import { Component, OnInit } from '@angular/core';
import { HttpClient, HttpClientModule } from '@angular/common/http';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, HttpClientModule, FormsModule],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class AppComponent implements OnInit {
  ordini: any[] = [];
  prodotti: any[] = [];
  categoriaSelezionata: string = 'tutti';
  nuovoProdotto = { nome: '', prezzo: 0, categoria: 'panini', immagine: '', descrizione: '' };
  // Questa riga capisce da sola l'indirizzo del tuo Codespace
  apiUrl = window.location.protocol + '//' + window.location.hostname.replace('4200', '5000');

  constructor(private http: HttpClient) {}

  ngOnInit() {
    this.caricaDati();
    this.caricaProdotti();
    // Aggiorna gli ordini ogni 5 secondi
    setInterval(() => this.caricaDati(), 5000);
  }

  caricaDati() {
    this.http.get(`${this.apiUrl}/ordini`).subscribe((data: any) => this.ordini = data);
  }

  caricaProdotti() {
    this.http.get(`${this.apiUrl}/prodotti`).subscribe((data: any) => this.prodotti = data);
  }

  filtraProdotti() {
    if (this.categoriaSelezionata === 'tutti') {
      return this.prodotti;
    }
    return this.prodotti.filter(p => p.categoria === this.categoriaSelezionata);
  }

  eliminaProdotto(id: number) {
    if (confirm('Sei sicuro di voler eliminare questo prodotto?')) {
      this.http.delete(`${this.apiUrl}/prodotti/${id}`).subscribe(() => {
        alert('Prodotto eliminato con successo!');
        this.caricaProdotti();
      });
    }
  }
  // Assicurati che l'URL sia quello della tua porta 5000 (Backend)
  apiUrlOrdini = 'https://organic-rotary-phone-pjv5vvrwjjjg3764w-5000.app.github.dev/ordini';

  // Funzione per eliminare l'ordine (Segna come completato)
  completaOrdine(id: number) {
    if(confirm("Vuoi segnare l'ordine #" + id + " come completato?")) {
      this.http.delete(`${this.apiUrlOrdini}/${id}`).subscribe({
        next: () => {
          console.log("Ordine eliminato");
          this.caricaOrdini(); // Riesegue la GET per aggiornare la lista
        },
        error: (err) => console.error("Errore durante l'eliminazione", err)
      });
    }
  }

  // Funzione per caricare gli ordini (da chiamare nel ngOnInit)
  caricaOrdini() {
    this.http.get<any[]>(this.apiUrlOrdini).subscribe(data => {
      this.ordini = data;
    });
  }
  aggiungiProdotto() {
    this.http.post(`${this.apiUrl}/prodotti`, this.nuovoProdotto).subscribe(() => {
      alert("Prodotto aggiunto con successo al menu!");
      this.nuovoProdotto = { nome: '', prezzo: 0, categoria: 'panini', immagine: '', descrizione: '' };
      this.caricaProdotti();
    });
  }
}