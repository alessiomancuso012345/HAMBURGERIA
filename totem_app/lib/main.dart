import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(MaterialApp(home: TotemBK(), debugShowCheckedModeBanner: false));

class TotemBK extends StatefulWidget {
  @override
  _TotemBKState createState() => _TotemBKState();
}

class _TotemBKState extends State<TotemBK> {
  List prodotti = [];
  List<Map<String, dynamic>> carrello = [];
  // USA IL TUO URL DEL BACKEND (Porta 5000)
  final String apiUrl = "https://organic-rotary-phone-pjv5vvrwjjjg3764w-5000.app.github.dev/prodotti";

  @override
  void initState() {
    super.initState();
    caricaProdotti();
  }

  caricaProdotti() async {
    var res = await http.get(Uri.parse(apiUrl));
    if (res.statusCode == 200) setState(() => prodotti = json.decode(res.body));
  }

  aggiungiAlCarrello(var p) {
    setState(() {
      int index = carrello.indexWhere((item) => item['prodotto']['id'] == p['id']);
      if (index != -1) {
        carrello[index]['quantita']++;
      } else {
        carrello.add({'prodotto': p, 'quantita': 1});
      }
    });
  }

  modificaQuantita(int index, int delta) {
    setState(() {
      carrello[index]['quantita'] += delta;
      if (carrello[index]['quantita'] <= 0) {
        carrello.removeAt(index);
      }
    });
  }

  double get totale => carrello.fold(0.0, (sum, item) => sum + (item['prodotto']['prezzo'] * item['quantita']));

  inviaOrdine() async {
    if (carrello.isEmpty) return;

    var dettagli = carrello.map((item) => "${item['prodotto']['nome']} x${item['quantita']}").join(', ');
    var ordine = {'totale': totale, 'dettagli': dettagli};

    var res = await http.post(
      Uri.parse("https://organic-rotary-phone-pjv5vvrwjjjg3764w-5000.app.github.dev/ordini"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(ordine),
    );

    if (res.statusCode == 201) {
      setState(() => carrello.clear());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ordine inviato con successo!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Errore nell\'invio dell\'ordine')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF5EBD7), Color(0xFFE8D5B7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // HEADER CON LOGO E TITOLO
            Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: Color(0xFF502314),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Burger_King_Logo.svg/2560px-Burger_King_Logo.svg.png',
                    height: 60,
                  ),
                  SizedBox(width: 20),
                  Text(
                    "BURGER KING",
                    style: GoogleFonts.bebasNeue(fontSize: 36, color: Color(0xFFFA9F18), letterSpacing: 3),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.all(20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20
                ),
                itemCount: prodotti.length,
                itemBuilder: (context, i) {
                  var p = prodotti[i];
                  return Card(
                    elevation: 12,
                    shadowColor: Colors.black38,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Color(0xFF502314).withOpacity(0.2), width: 1),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: () => aggiungiAlCarrello(p),
                      splashColor: Color(0xFFD62300).withOpacity(0.3),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                              child: Image.network(
                                p['immagine'],
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[300],
                                  child: Icon(Icons.fastfood, size: 50, color: Colors.grey),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    p['nome'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF502314),
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Expanded(
                                    child: Text(
                                      p['descrizione'] ?? "Il classico gusto alla griglia",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFFD62300),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      elevation: 5,
                                    ),
                                    onPressed: () => aggiungiAlCarrello(p),
                                    child: Text(
                                      "€${p['prezzo']} - AGGIUNGI",
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          // CARRELLO ESPANDIBILE
          if (carrello.isNotEmpty)
            Card(
              margin: EdgeInsets.all(20),
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ExpansionTile(
                title: Text("🛒 Carrello (${carrello.length} prodotti)", style: TextStyle(color: Color(0xFF502314), fontWeight: FontWeight.bold, fontSize: 18)),
                children: carrello.map((item) {
                  var p = item['prodotto'];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(p['immagine'], width: 50, height: 50, fit: BoxFit.cover),
                    ),
                    title: Text(p['nome'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("€${p['prezzo']} x ${item['quantita']} = €${(p['prezzo'] * item['quantita']).toStringAsFixed(2)}"),
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove, color: Color(0xFFD62300)),
                            onPressed: () => modificaQuantita(carrello.indexOf(item), -1),
                          ),
                          Text("${item['quantita']}", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: Icon(Icons.add, color: Color(0xFFD62300)),
                            onPressed: () => modificaQuantita(carrello.indexOf(item), 1),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          // BARRA INFERIORE TOTALE
          Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2)],
              border: Border.all(color: Color(0xFF502314).withOpacity(0.3), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("TOTALE", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    Text("${totale.toStringAsFixed(2)} €", 
                         style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF502314))),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    elevation: 8,
                  ),
                  onPressed: inviaOrdine,
                  child: Text("🍔 ORDINA ORA", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(10),
        color: Color(0xFF502314),
        child: Text(
          "© 2026 Burger King - Ordina Facilmente",
          style: TextStyle(color: Color(0xFFFA9F18), fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}