import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html; 

void main() {
  runApp(MaterialApp(
    home: TotemBK(),
    debugShowCheckedModeBanner: false,
  ));
}

class TotemBK extends StatefulWidget {
  @override
  _TotemBKState createState() => _TotemBKState();
}

class _TotemBKState extends State<TotemBK> {
  List prodotti = [];
  double totale = 0.0;
  List carrello = [];

  // --- CONFIGURAZIONE URL ---
  // Abbiamo inserito l'indirizzo fisso della tua porta 5000
  final String baseUrl = 'https://organic-rotary-phone-pjv5vvrwjjjg3764w-5000.app.github.dev';

  @override
  void initState() {
    super.initState();
    caricaMenu();
  }

  // Prende i prodotti dal Backend
  caricaMenu() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/prodotti'));
      if (res.statusCode == 200) {
        setState(() {
          prodotti = json.decode(res.body);
        });
      }
    } catch (e) {
      print("Errore caricamento menu: $e");
    }
  }

  // Invia l'ordine alla cucina
  inviaOrdine() async {
    if (carrello.isEmpty) return;
    String nomiArticoli = carrello.map((p) => p['nome']).join(", ");

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/ordini'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"totale": totale, "dettagli": nomiArticoli}),
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        setState(() {
          carrello = [];
          totale = 0.0;
        });
        showDialog(
          context: context,
          builder: (c) => AlertDialog(
            title: Text("🍔 Burger King"),
            content: Text("Ordine inviato! Ritira lo scontrino in cassa."),
            actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text("OK"))],
          ),
        );
      }
    } catch (e) {
      print("Errore invio ordine: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5EBDC),
      appBar: AppBar(
        title: Image.network(
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/cc/Burger_King_2020.svg/1200px-Burger_King_2020.svg.png',
          height: 40,
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF502314),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "BENVENUTO! COSA DESIDERI OGGI?",
              style: TextStyle(color: Color(0xFF502314), fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
          Expanded(
            child: prodotti.isEmpty 
              ? Center(child: CircularProgressIndicator(color: Color(0xFFD62308)))
              : GridView.builder(
                  padding: EdgeInsets.all(15),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, 
                    childAspectRatio: 0.75,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10
                  ),
                  itemCount: prodotti.length,
                  itemBuilder: (ctx, i) => Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.network(
                              prodotti[i]['immagine'], 
                              fit: BoxFit.contain,
                              errorBuilder: (c,e,s) => Icon(Icons.fastfood, size: 50, color: Colors.grey),
                            ),
                          ),
                        ),
                        Text(prodotti[i]['nome'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text("${prodotti[i]['prezzo']} €", style: TextStyle(color: Color(0xFFD62308), fontSize: 16, fontWeight: FontWeight.bold)),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFD62308),
                              shape: StadiumBorder()
                            ),
                            onPressed: () {
                              setState(() {
                                carrello.add(prodotti[i]);
                                totale += double.parse(prodotti[i]['prezzo'].toString());
                              });
                            },
                            child: Text("AGGIUNGI", style: TextStyle(color: Colors.white)),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("TOTALE", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text("${totale.toStringAsFixed(2)} €", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF502314))),
                  ],
                ),
                ElevatedButton(
                  onPressed: inviaOrdine,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700], 
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                  ),
                  child: Text("CONFERMA ORDINE", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}