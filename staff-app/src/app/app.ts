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
  mostraInformazioni: boolean = false;
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

  // Funzione per eliminare l'ordine (Segna come completato)
  completaOrdine(id: number) {
    if(confirm("Vuoi segnare l'ordine #" + id + " come completato?")) {
      this.http.delete(`${this.apiUrl}/ordini/${id}`).subscribe({
        next: () => {
          console.log("Ordine eliminato");
          this.caricaDati(); // Riesegue la GET per aggiornare la lista
        },
        error: (err) => console.error("Errore durante l'eliminazione", err)
      });
    }
  }
  // Funzione per ottenere l'ora corrente
  getCurrentTime(): string {
    const now = new Date();
    const hour = now.getHours();

    let periodo = '';
    if (hour >= 6 && hour < 12) {
      periodo = 'Mattina';
    } else if (hour >= 12 && hour < 18) {
      periodo = 'Pomeriggio';
    } else if (hour >= 18 && hour < 22) {
      periodo = 'Sera';
    } else {
      periodo = 'Notte';
    }

    const oraFormattata = now.toLocaleTimeString('it-IT', {
      hour: '2-digit'
    });

    return `Orario: ${oraFormattata} ${periodo}`;
  }

  // Funzione per ottenere la data corrente
  getCurrentDate(): string {
    const now = new Date();
    const giorno = now.getDate().toString().padStart(2, '0');
    const mese = (now.getMonth() + 1).toString().padStart(2, '0');
    const anno = now.getFullYear();

    return `Giorno: ${giorno}/${mese}/${anno}`;
  }

  aggiungiProdotto() {
    if (this.nuovoProdotto.prezzo < 1) {
      alert("Il prezzo deve essere almeno 1€");
      return;
    }
    this.http.post(`${this.apiUrl}/prodotti`, this.nuovoProdotto).subscribe({
      next: () => {
        alert("Prodotto aggiunto con successo al menu!");
        this.nuovoProdotto = { nome: '', prezzo: 0, categoria: 'panini', immagine: '', descrizione: '' };
        this.caricaProdotti();
      },
      error: (err: any) => {
        alert("Errore: " + (err.error?.errore || "Errore sconosciuto"));
      }
    });
  }

  // Funzione per formattare i prezzi con 2 decimali
  formattaPrezzo(prezzo: number): string {
    return prezzo.toFixed(2);
  }
}