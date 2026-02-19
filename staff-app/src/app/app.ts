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
  nuovoProdotto = { nome: '', prezzo: 0, categoria: 'panini', immagine: '' };
  // Questa riga capisce da sola l'indirizzo del tuo Codespace
  apiUrl = window.location.protocol + '//' + window.location.hostname.replace('4200', '5000');

  constructor(private http: HttpClient) {}

  ngOnInit() {
    this.caricaDati();
    // Aggiorna gli ordini ogni 5 secondi
    setInterval(() => this.caricaDati(), 5000);
  }

  caricaDati() {
    this.http.get(`${this.apiUrl}/ordini`).subscribe((data: any) => this.ordini = data);
  }

  aggiungiProdotto() {
    this.http.post(`${this.apiUrl}/prodotti`, this.nuovoProdotto).subscribe(() => {
      alert("Prodotto aggiunto con successo al menu!");
      this.nuovoProdotto = { nome: '', prezzo: 0, categoria: 'panini', immagine: '' };
    });
  }
}