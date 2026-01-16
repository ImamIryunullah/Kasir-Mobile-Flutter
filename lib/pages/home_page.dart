import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kasir_offline/pages/notification_page.dart';
import 'kasir_page.dart';
import 'laporan_page.dart';
import 'services_page.dart';
import 'stok_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Tema Warna Konsisten
  static const Color primaryNavy = Color(0xFF2C3E50);
  static const Color accentBlue = Color(0xFF34495E);
  static const Color backgroundLight = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    final today = DateFormat(
      'EEEE, dd MMM yyyy',
      'id_ID',
    ).format(DateTime.now());

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'MITRA GLOBAL',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                fontSize: 18,
                color: primaryNavy,
              ),
            ),
            Text(
              'Sistem Manajemen Kasir',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: backgroundLight,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: primaryNavy,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const NotificationPage()),
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              today,
              style: TextStyle(
                color: accentBlue.withOpacity(0.6),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            _buildSummaryCard(),

            const SizedBox(height: 32),

            const Text(
              "Layanan Utama",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryNavy,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),

            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              children: [
                _menuCard(
                  context,
                  icon: Icons.point_of_sale_outlined,
                  title: "Kasir",
                  subtitle: "Transaksi Baru",
                  page: const KasirPage(),
                ),
                _menuCard(
                  context,
                  icon: Icons.analytics_outlined,
                  title: "Laporan",
                  subtitle: "Analisa Data",
                  page: const LaporanPage(),
                ),
                _menuCard(
                  context,
                  icon: Icons.inventory_2_outlined,
                  title: "Stok",
                  subtitle: "Cek Inventaris",
                  page: const StokBarangPage(),
                ),
                _menuCard(
                  context,
                  icon: Icons.settings_suggest_outlined,
                  title: "Service",
                  subtitle: "Teknisi & Alat",
                  page: const ServicePage(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===================== RINGKASAN DATA =====================
  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryNavy,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryNavy.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryNavy, accentBlue],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total Penjualan Hari Ini",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Icon(
                Icons.trending_up,
                color: Colors.greenAccent.shade100,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Rp 12.500.000",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(
                Icons.confirmation_number_outlined,
                color: Colors.white54,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                "45 Transaksi Terhitung",
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== MENU CARD INTERAKTIF =====================
  Widget _menuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget page,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: backgroundLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: primaryNavy, size: 28),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: primaryNavy,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
