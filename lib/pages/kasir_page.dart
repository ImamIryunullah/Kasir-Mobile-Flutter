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
  // Tema Warna Konsisten dengan HomePage
  static const Color primaryNavy = Color(0xFF2C3E50);
  static const Color accentBlue = Color(0xFF34495E);
  static const Color backgroundLight = Color(0xFFF8FAFC);

  final BarangRepository repo = BarangRepository();
  final TextEditingController searchCtrl = TextEditingController();

  List<Barang> allBarang = [];
  List<Barang> filteredBarang = [];
  Map<int, int> cartQty = {};

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
      filteredBarang = keyword.isEmpty
          ? allBarang
          : allBarang
                .where(
                  (b) =>
                      b.nama.toLowerCase().contains(keyword.toLowerCase()) ||
                      b.kategori.toLowerCase().contains(keyword.toLowerCase()),
                )
                .toList();
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

  int getCartQty(int? id) => cartQty[id] ?? 0;

  void updateQty(Barang barang, int delta) {
    setState(() {
      int currentQty = getCartQty(barang.id);
      int newQty = currentQty + delta;

      if (newQty > barang.stok) {
        _showToast("Stok tidak mencukupi", Colors.orange);
        return;
      }

      if (newQty <= 0) {
        cartQty.remove(barang.id);
      } else {
        cartQty[barang.id!] = newQty;
      }
    });
  }

  void _showToast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showCheckoutSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CheckoutSheet(
        total: totalHarga,
        onSuccess: () async {
          // Logika proses checkout seperti di kode awal Anda
          Navigator.pop(context);
          _showToast("Transaksi Berhasil!", Colors.green);
          setState(() => cartQty.clear());
          _loadData();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primaryNavy,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Catat Transaksi",
          style: TextStyle(
            color: primaryNavy,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: filteredBarang.isEmpty
                ? const Center(
                    child: Text(
                      'Barang tidak ditemukan',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredBarang.length,
                    itemBuilder: (context, index) =>
                        _buildProductCard(filteredBarang[index]),
                  ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: TextField(
        controller: searchCtrl,
        onChanged: _search,
        decoration: InputDecoration(
          hintText: 'Cari produk atau kategori...',
          hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
          prefixIcon: const Icon(Icons.search_rounded, color: primaryNavy),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryNavy, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Barang barang) {
    final qtyInCart = getCartQty(barang.id);
    final isLowStock = (barang.stok - qtyInCart) <= 5;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getCategoryIcon(barang.kategori), color: primaryNavy),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  barang.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryNavy,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currencyFormatter.format(barang.harga),
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Stok: ${barang.stok - qtyInCart}',
                  style: TextStyle(
                    color: isLowStock ? Colors.red : Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _qtyBtn(
                Icons.remove_circle_outline,
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
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              _qtyBtn(
                Icons.add_circle_outline,
                () => updateQty(barang, 1),
                (barang.stok - qtyInCart) == 0,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap, bool disabled) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(
          icon,
          color: disabled ? Colors.grey.shade300 : primaryNavy,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Tagihan",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  currencyFormatter.format(totalHarga),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryNavy,
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: totalHarga > 0 ? showCheckoutSheet : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "CHECKOUT",
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'mesin':
        return Icons.print_rounded;
      case 'sparepart':
        return Icons.settings_input_component_rounded;
      case 'kertas':
        return Icons.layers_rounded;
      default:
        return Icons.widgets_outlined;
    }
  }
}

// ===================== CHECKOUT SHEET CONSISTENT =====================
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
  static const Color primaryNavy = Color(0xFF2C3E50);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Penyelesaian Transaksi",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: primaryNavy,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _methodBtn("Cash", Icons.payments_outlined),
              const SizedBox(width: 12),
              _methodBtn("Transfer", Icons.account_balance_wallet_outlined),
            ],
          ),
          const SizedBox(height: 24),
          if (method == "Cash") ...[
            TextField(
              controller: _bayarCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              onChanged: (v) => setState(
                () => kembalian = (int.tryParse(v) ?? 0) - widget.total,
              ),
              decoration: InputDecoration(
                labelText: "Uang Diterima",
                prefixText: "Rp ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              "Kembalian",
              kembalian < 0
                  ? "Rp 0"
                  : NumberFormat.currency(
                      locale: 'id',
                      symbol: 'Rp ',
                      decimalDigits: 0,
                    ).format(kembalian),
              kembalian < 0 ? Colors.red : Colors.green,
            ),
          ] else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Pastikan dana transfer sudah masuk ke rekening toko.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: primaryNavy),
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (method == "Cash" && kembalian < 0)
                  ? null
                  : widget.onSuccess,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryNavy,
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "KONFIRMASI PEMBAYARAN",
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

  Widget _methodBtn(String label, IconData icon) {
    bool isSelected = method == label;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => method = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? primaryNavy : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryNavy : Colors.grey.shade300,
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

  Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
      ],
    );
  }
}
