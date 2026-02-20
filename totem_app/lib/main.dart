import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(MaterialApp(home: TotemBK(), debugShowCheckedModeBanner: false));

class TotemBK extends StatefulWidget {
  @override
  _TotemBKState createState() => _TotemBKState();
}

class _TotemBKState extends State<TotemBK> with TickerProviderStateMixin {
  List prodotti = [];
  List<Map<String, dynamic>> carrello = [];
  final String apiUrl = "https://organic-rotary-phone-pjv5vvrwjjjg3764w-5000.app.github.dev/prodotti";
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    caricaProdotti();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    if (carrello.isNotEmpty) _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
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
        if (carrello.length == 1) _fabAnimationController.forward();
      }
    });
  }

  modificaQuantita(int index, int delta) {
    setState(() {
      carrello[index]['quantita'] += delta;
      if (carrello[index]['quantita'] <= 0) {
        carrello.removeAt(index);
        if (carrello.isEmpty) _fabAnimationController.reverse();
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
      _fabAnimationController.reverse();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Ordine inviato con successo!'),
            ],
          ),
          backgroundColor: Color(0xFF28A745),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Errore nell\'invio dell\'ordine'),
            ],
          ),
          backgroundColor: Color(0xFFDC3545),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  String getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour;

    String periodo = '';
    if (hour >= 6 && hour < 12) {
      periodo = 'Mattina';
    } else if (hour >= 12 && hour < 18) {
      periodo = 'Pomeriggio';
    } else if (hour >= 18 && hour < 22) {
      periodo = 'Sera';
    } else {
      periodo = 'Notte';
    }

    final oraFormattata = now.hour.toString().padLeft(2, '0');
    return 'Orario: $oraFormattata $periodo';
  }

  String getCurrentDate() {
    final now = DateTime.now();
    final giorno = now.day.toString().padLeft(2, '0');
    final mese = now.month.toString().padLeft(2, '0');
    final anno = now.year.toString();

    return 'Giorno: $giorno/$mese/$anno';
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(140),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFD62308), Color(0xFF502314)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Header principale
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                              ),
                              child: Text('🍔', style: TextStyle(fontSize: 24)),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "HAMBURGERIA DI MITZOV E MANCUSO",
                                  style: GoogleFonts.bebasNeue(
                                    fontSize: 20,
                                    color: Color(0xFFFA9F18),
                                    letterSpacing: 1.2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "Self-Service Ordering",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF28A745),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    "Online",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  getCurrentTime(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  getCurrentDate(),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    fontFeatures: [FontFeature.tabularFigures()],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Tab Bar
                  Container(
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        color: Color(0xFFFA9F18),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFFFA9F18).withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Color(0xFF502314),
                      unselectedLabelColor: Colors.white.withOpacity(0.8),
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🍔', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 6),
                              Text('Panini'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🥤', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 6),
                              Text('Bevande'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🍽️', style: TextStyle(fontSize: 16)),
                              SizedBox(width: 6),
                              Text('Menù'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              // Contatore prodotti
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: Color(0xFF502314).withOpacity(0.1), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant_menu, color: Color(0xFFD62308), size: 20),
                    SizedBox(width: 8),
                    Text(
                      "${prodotti.length} prodotti disponibili",
                      style: TextStyle(
                        color: Color(0xFF502314),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  children: [
                    buildProductGrid('panini'),
                    buildProductGrid('bevande'),
                    buildProductGrid('menu'),
                  ],
                ),
              ),

              // Carrello espandibile
              if (carrello.isNotEmpty)
                AnimatedBuilder(
                  animation: _fabAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _fabAnimation.value,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: Offset(0, 5),
                            ),
                          ],
                          border: Border.all(color: Color(0xFF502314).withOpacity(0.2), width: 1),
                        ),
                        child: ExpansionTile(
                          title: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFD62308).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('🛒', style: TextStyle(fontSize: 16)),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Carrello (${carrello.length} ${carrello.length == 1 ? 'prodotto' : 'prodotti'})",
                                        style: TextStyle(
                                          color: Color(0xFF502314),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        "Totale: €${totale.toStringAsFixed(2)}",
                                        style: TextStyle(
                                          color: Color(0xFF28A745),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          children: carrello.map((item) {
                            var p = item['prodotto'];
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200, width: 1),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      p['immagine'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey.shade300,
                                        child: Icon(Icons.fastfood, size: 25, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p['nome'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: Color(0xFF502314),
                                          ),
                                        ),
                                        Text(
                                          "€${p['prezzo']} x ${item['quantita']} = €${(p['prezzo'] * item['quantita']).toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(25),
                                      border: Border.all(color: Colors.grey.shade300, width: 1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.remove, color: Color(0xFFD62308), size: 16),
                                          onPressed: () => modificaQuantita(carrello.indexOf(item), -1),
                                          padding: EdgeInsets.all(4),
                                          constraints: BoxConstraints(),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: Text(
                                            "${item['quantita']}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF502314),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.add, color: Color(0xFFD62308), size: 16),
                                          onPressed: () => modificaQuantita(carrello.indexOf(item), 1),
                                          padding: EdgeInsets.all(4),
                                          constraints: BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),

              // Barra totale e checkout
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Color(0xFFF8F9FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 3,
                      offset: Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: Color(0xFF502314).withOpacity(0.2), width: 1),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Totale Ordine",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              "€${totale.toStringAsFixed(2)}",
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF502314),
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF28A745),
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 8,
                            shadowColor: Color(0xFF28A745).withOpacity(0.3),
                          ),
                          onPressed: carrello.isEmpty ? null : inviaOrdine,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "🍔 ORDINA ORA",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Footer professionale
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF502314), Color(0xFF3A1A0F)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "© 2026 Hamburgeria di Mitzov e Mancuso Self-Service",
                    style: TextStyle(
                      color: Color(0xFFFA9F18),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    "v2.1.0",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.info_outline, color: Colors.white.withOpacity(0.7), size: 18),
                    onPressed: () {},
                    padding: EdgeInsets.all(4),
                    constraints: BoxConstraints(),
                  ),
                  IconButton(
                    icon: Icon(Icons.help_outline, color: Colors.white.withOpacity(0.7), size: 18),
                    onPressed: () {},
                    padding: EdgeInsets.all(4),
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProductGrid(String categoria) {
    var prodottiFiltrati = prodotti.where((p) => p['categoria'] == categoria).toList();

    if (prodottiFiltrati.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                categoria == 'panini' ? '🍔' : categoria == 'bevande' ? '🥤' : '🍽️',
                style: TextStyle(fontSize: 48),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Nessun prodotto disponibile",
              style: TextStyle(
                color: Color(0xFF502314),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Torna presto per scoprire le nostre novità!",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 5 : MediaQuery.of(context).size.width > 800 ? 4 : 3,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: prodottiFiltrati.length,
        itemBuilder: (context, i) {
          var p = prodottiFiltrati[i];
          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Card(
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Color(0xFF502314).withOpacity(0.1), width: 1),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => aggiungiAlCarrello(p),
                splashColor: Color(0xFFD62308).withOpacity(0.1),
                highlightColor: Color(0xFFD62308).withOpacity(0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Immagine prodotto
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          gradient: LinearGradient(
                            colors: [Colors.white, Color(0xFFF8F9FA)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(
                            p['immagine'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey.shade200,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    categoria == 'panini' ? Icons.lunch_dining :
                                    categoria == 'bevande' ? Icons.local_drink : Icons.restaurant,
                                    size: 32,
                                    color: Colors.grey.shade400,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Immagine\nnon disponibile',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Informazioni prodotto
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nome prodotto
                            Text(
                              p['nome'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Color(0xFF502314),
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            SizedBox(height: 4),

                            // Descrizione
                            Expanded(
                              child: Text(
                                p['descrizione'] ?? 'Delizioso e gustoso',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[700],
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            SizedBox(height: 8),

                            // Prezzo e pulsante
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "€${p['prezzo']}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF28A745),
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFFD62308), Color(0xFFB01E07)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFFD62308).withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    "AGGIUNGI",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}