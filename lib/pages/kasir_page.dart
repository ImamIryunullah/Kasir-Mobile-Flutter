import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/barang.dart';
import '../repositories/barang_repository.dart';

class KasirPage extends StatefulWidget {
  const KasirPage({super.key});

  @override
  State<KasirPage> createState() => _KasirPageState();
}

class _KasirPageState extends State<KasirPage> {
  final BarangRepository repo = BarangRepository();
  final TextEditingController searchCtrl = TextEditingController();

  List<Barang> allBarang = [];
  List<Barang> filteredBarang = [];
  Map<int, int> cartQty = {}; // id barang -> quantity di keranjang

  final currencyFormatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await repo.getAllBarang();
    setState(() {
      allBarang = data;
      filteredBarang = data;
    });
  }

  void _search(String keyword) {
    setState(() {
      if (keyword.isEmpty) {
        filteredBarang = allBarang;
      } else {
        filteredBarang = allBarang
            .where(
              (b) =>
                  b.nama.toLowerCase().contains(keyword.toLowerCase()) ||
                  b.kategori.toLowerCase().contains(keyword.toLowerCase()),
            )
            .toList();
      }
    });
  }

  int get totalHarga {
    int total = 0;
    for (var barang in allBarang) {
      if (cartQty.containsKey(barang.id)) {
        total += barang.harga * cartQty[barang.id!]!;
      }
    }
    return total;
  }

  int getCartQty(int? id) {
    if (id == null) return 0;
    return cartQty[id] ?? 0;
  }

  void updateQty(Barang barang, int delta) {
    setState(() {
      int currentQty = getCartQty(barang.id);
      int newQty = currentQty + delta;

      // Cek stok tersedia
      if (newQty > barang.stok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stok ${barang.nama} tidak mencukupi!'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (newQty <= 0) {
        cartQty.remove(barang.id);
      } else {
        cartQty[barang.id!] = newQty;
      }
    });
  }

  Future<void> _processCheckout() async {
    if (cartQty.isEmpty) return;

    // Update stok di database
    for (var entry in cartQty.entries) {
      int barangId = entry.key;
      int qtyDibeli = entry.value;

      Barang? barang = allBarang.firstWhere((b) => b.id == barangId);

      // Kurangi stok
      await repo.updateBarang(
        Barang(
          id: barang.id,
          nama: barang.nama,
          harga: barang.harga,
          stok: barang.stok - qtyDibeli,
          kategori: barang.kategori,
        ),
      );
    }

    // Reset keranjang
    setState(() {
      cartQty.clear();
    });

    // Reload data untuk update tampilan
    await _loadData();
  }

  void showCheckoutSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CheckoutSheet(
        total: totalHarga,
        onSuccess: () async {
          await _processCheckout();
          if (mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Transaksi Berhasil!"),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Catat Transaksi",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchCtrl,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: 'Cari barang...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          Expanded(
            child: filteredBarang.isEmpty
                ? const Center(
                    child: Text(
                      'Tidak ada barang ditemukan',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredBarang.length,
                    itemBuilder: (context, index) {
                      final barang = filteredBarang[index];
                      final qtyInCart = getCartQty(barang.id);
                      final stokTersedia = barang.stok - qtyInCart;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                _getCategoryIcon(barang.kategori),
                                color: Colors.blue[700],
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    barang.nama,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    currencyFormatter.format(barang.harga),
                                    style: TextStyle(
                                      color: Colors.blue[800],
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Stok: $stokTersedia',
                                    style: TextStyle(
                                      color: stokTersedia <= 5
                                          ? Colors.red
                                          : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                _qtyBtn(
                                  Icons.remove,
                                  () => updateQty(barang, -1),
                                  qtyInCart == 0,
                                ),
                                SizedBox(
                                  width: 30,
                                  child: Center(
                                    child: Text(
                                      "$qtyInCart",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                _qtyBtn(
                                  Icons.add,
                                  () => updateQty(barang, 1),
                                  stokTersedia == 0,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'mesin':
        return Icons.settings;
      case 'sparepart':
        return Icons.build;
      case 'kertas':
        return Icons.description;
      default:
        return Icons.shopping_bag;
    }
  }

  Widget _qtyBtn(IconData icon, VoidCallback onPressed, bool disabled) {
    return IconButton(
      onPressed: disabled ? null : onPressed,
      icon: Icon(icon, size: 20),
      constraints: const BoxConstraints(),
      padding: const EdgeInsets.all(8),
      style: IconButton.styleFrom(
        backgroundColor: disabled ? Colors.grey[200] : Colors.white,
        side: BorderSide(color: Colors.grey[300]!),
        disabledBackgroundColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Tagihan",
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  currencyFormatter.format(totalHarga),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: totalHarga > 0 ? showCheckoutSheet : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "CHECKOUT",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// WIDGET CHECKOUT
class CheckoutSheet extends StatefulWidget {
  final int total;
  final VoidCallback onSuccess;
  const CheckoutSheet({
    super.key,
    required this.total,
    required this.onSuccess,
  });

  @override
  State<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<CheckoutSheet> {
  String method = "Cash";
  final TextEditingController _bayarCtrl = TextEditingController();
  int kembalian = 0;
  final fmt = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  void hitungKembalian(String value) {
    int bayar = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    setState(() {
      kembalian = bayar - widget.total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Metode Pembayaran",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _methodChip("Cash", Icons.money),
              const SizedBox(width: 10),
              _methodChip("Transfer", Icons.account_balance),
            ],
          ),
          const SizedBox(height: 25),
          if (method == "Cash") ...[
            TextField(
              controller: _bayarCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              onChanged: hitungKembalian,
              decoration: InputDecoration(
                labelText: "Jumlah yang Dibayar",
                prefixText: "Rp ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: kembalian < 0 ? Colors.red[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Kembalian:",
                    style: TextStyle(
                      color: kembalian < 0 ? Colors.red : Colors.green[800],
                    ),
                  ),
                  Text(
                    fmt.format(kembalian < 0 ? 0 : kembalian),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kembalian < 0 ? Colors.red : Colors.green[800],
                    ),
                  ),
                ],
              ),
            ),
          ] else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Silahkan scan QRIS atau cek mutasi bank.",
                textAlign: TextAlign.center,
              ),
            ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (method == "Cash" && kembalian < 0)
                  ? null
                  : widget.onSuccess,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                padding: const EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "DONE",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _methodChip(String label, IconData icon) {
    bool isSelected = method == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => method = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[800] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue[800]! : Colors.grey[300]!,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
