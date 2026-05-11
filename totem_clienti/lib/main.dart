import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MaterialApp(
      home: const TotemApp(),
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    ));

// ⚠️ SOSTITUISCI CON IL TUO LINK HTTPS DELLA PORTA 5000 ⚠️
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
      await http.post(
        Uri.parse('$apiUrl/orders'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "total": total,
          "items": cart.map((i) => {"name": i['name'], "quantity": 1, "price": i['price']}).toList()
        }),
      );
      setState(() => cart = []);
      _showSuccess();
    } catch (e) {
      print(e);
    }
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("🍔 Ordine inviato! Prepara il tuo appetito!"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Row(
        children: [
          // SEZIONE SINISTRA: PRODOTTI (75% dello spazio)
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.builder(
                          padding: const EdgeInsets.all(25),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, // Card più piccole (4 per riga)
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                          ),
                          itemCount: products.length,
                          itemBuilder: (ctx, i) => _buildProductCard(products[i]),
                        ),
                ),
              ],
            ),
          ),

          // SEZIONE DESTRA: SIDEBAR CARRELLO (25% dello spazio)
          Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
            ),
            child: _buildCartSidebar(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(left: 30, top: 40, right: 30, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("BURGER SHOP", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
              Text("Digital Self-Service Totem", style: TextStyle(color: Colors.grey, fontSize: 16)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 30),
            onPressed: fetchProducts,
          )
        ],
      ),
    );
  }

  Widget _buildProductCard(dynamic p) {
    return GestureDetector(
      onTap: () => setState(() => cart.add(p)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(p['image'], fit: BoxFit.cover, width: double.infinity, 
                   errorBuilder: (c, e, s) => Container(color: Colors.grey[100], child: const Icon(Icons.fastfood))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${p['price']}€", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 17)),
                      const Icon(Icons.add_circle, color: Colors.orange, size: 28),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSidebar() {
    double total = cart.fold(0, (sum, item) => sum + item['price']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 25, top: 50, bottom: 20),
          child: Text("Il tuo ordine", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: cart.isEmpty
              ? _buildEmptyCart()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: cart.length,
                  itemBuilder: (ctx, i) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(cart[i]['image'], width: 40, height: 40, fit: BoxFit.cover),
                    ),
                    title: Text(cart[i]['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: Text("${cart[i]['price']}€"),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 20),
                      onPressed: () => setState(() => cart.removeAt(i)),
                    ),
                  ),
                ),
        ),
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(top: BorderSide(color: Colors.grey[200]!)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Totale", style: TextStyle(fontSize: 18, color: Colors.grey)),
                  Text("${total.toStringAsFixed(2)}€", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.orange)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: cart.isEmpty ? null : sendOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: const Text("INVIA ORDINE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 20),
          const Text("Il carrello è vuoto", style: TextStyle(color: Colors.grey, fontSize: 16)),
          const Text("Seleziona qualcosa di buono!", style: TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}