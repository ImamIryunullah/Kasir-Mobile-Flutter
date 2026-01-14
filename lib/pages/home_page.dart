import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'kasir_page.dart';
import 'laporan_page.dart';
import 'services_page.dart';
import 'stok_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateFormat(
      'EEEE, dd MMM yyyy',
      'id_ID',
    ).format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Mitra Global',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              'Dashboard Kasir',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black54),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HEADER INFO =====
            Text(today, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 14),

            _buildSummaryCard(),

            const SizedBox(height: 30),

            // ===== MENU =====
            const Text(
              "Menu Utama",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.15,
              ),
              children: [
                _menuCard(
                  context,
                  icon: Icons.point_of_sale,
                  title: "Kasir",
                  subtitle: "Catat transaksi",
                  color: Colors.blue,
                  page: const KasirPage(),
                ),
                _menuCard(
                  context,
                  icon: Icons.bar_chart_rounded,
                  title: "Laporan",
                  subtitle: "Penjualan & laba",
                  color: Colors.orange,
                  page: const LaporanPage(),
                ),
                _menuCard(
                  context,
                  icon: Icons.inventory_2_rounded,
                  title: "Stok",
                  subtitle: "Barang & toner",
                  color: Colors.green,
                  page: const StokBarangPage(),
                ),
                _menuCard(
                  context,
                  icon: Icons.build_circle_rounded,
                  title: "Service",
                  subtitle: "Mesin & teknisi",
                  color: Colors.purple,
                  page: const ServicePage(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===================== SUMMARY =====================
  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Ringkasan Hari Ini",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            "Rp 12.500.000",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "45 Transaksi • +12% dari kemarin",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ===================== MENU CARD =====================
  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Widget page,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
