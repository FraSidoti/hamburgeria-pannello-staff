import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MaterialApp(
      home: const TotemApp(),
      theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true),
      debugShowCheckedModeBanner: false,
    ));

// ⚠️ RICORDATI DI METTERE IL TUO LINK HTTPS DELLA PORTA 5000 ⚠️
const String apiUrl = 'https://friendly-eureka-976g6vg6xp6xhxjgp-5000.app.github.dev';

class TotemApp extends StatefulWidget {
  const TotemApp({super.key});
  @override
  _TotemAppState createState() => _TotemAppState();
}

class _TotemAppState extends State<TotemApp> {
  List products = [];
  List cart = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  fetchProducts() async {
    try {
      final res = await http.get(Uri.parse('$apiUrl/products'));
      if (res.statusCode == 200) {
        setState(() {
          products = json.decode(res.body);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  sendOrder() async {
    if (cart.isEmpty) return;
    double total = cart.fold(0, (sum, item) => sum + item['price']);
    try {
      final res = await http.post(
        Uri.parse('$apiUrl/orders'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "total": total,
          "items": cart.map((i) => {"name": i['name'], "quantity": 1, "price": i['price']}).toList()
        }),
      );
      if (res.statusCode == 200) {
        setState(() => cart = []);
        _showSuccessDialog();
      }
    } catch (e) {
      print("Errore invio: $e");
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("🍔 Ordine Ricevuto!"),
        content: const Text("Il tuo ordine è stato inviato in cucina."),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("CHIUDI"))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: 70,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("BURGER SHOP DIGITAL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
            Text("Qualità in ogni morso", style: TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: Colors.black87, // Colore più moderno
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: fetchProducts)
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(15),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // <--- Aumentato a 3 per fare le card più piccole
                      childAspectRatio: 0.7, // Proporzione card
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                    ),
                    itemCount: products.length,
                    itemBuilder: (ctx, i) {
                      final p = products[i];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                child: Image.network(
                                  p['image'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => Container(color: Colors.grey[200], child: const Icon(Icons.fastfood, size: 30)),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p['category'].toString().toUpperCase(), style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 9)),
                                  Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("${p['price']}€", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          setState(() => cart.add(p));
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("${p['name']} aggiunto!"), duration: const Duration(milliseconds: 400))
                                          );
                                        },
                                        icon: const Icon(Icons.add_circle, color: Colors.orange, size: 30),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (cart.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
                    ),
                    child: SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("${cart.length} item selezionati", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                Text("Totale: ${cart.fold(0.0, (double s, i) => s + i['price']).toStringAsFixed(2)} €", 
                                     style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: sendOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("ORDINA ORA", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          )
                        ],
                      ),
                    ),
                  )
              ],
            ),
    );
  }
}