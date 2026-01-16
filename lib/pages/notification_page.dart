import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  // Tema Warna Konsisten
  static const Color primaryNavy = Color(0xFF2C3E50);
  static const Color backgroundLight = Color(0xFFF8FAFC);

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
          "Notifikasi",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryNavy,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              "Baca Semua",
              style: TextStyle(color: Colors.blue),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildSectionHeader("Terbaru"),
          _notificationItem(
            icon: Icons.inventory_2_rounded,
            color: Colors.red,
            title: "Stok Menipis!",
            description: "Toner NPG-51 tersisa 2 unit lagi di gudang.",
            time: "10 Menit yang lalu",
            isUnread: true,
          ),
          _notificationItem(
            icon: Icons.settings_suggest_rounded,
            color: Colors.orange,
            title: "Service Selesai",
            description:
                "Mesin Canon iR2525 (Pelanggan: Bp. Budi) telah selesai diperbaiki.",
            time: "2 Jam yang lalu",
            isUnread: true,
          ),
          const Divider(height: 32, indent: 24, endIndent: 24),
          _buildSectionHeader("Kemarin"),
          _notificationItem(
            icon: Icons.account_balance_wallet_rounded,
            color: Colors.green,
            title: "Laporan Terkirim",
            description:
                "Laporan harian tanggal 15 Jan telah berhasil dikirim ke email owner.",
            time: "15 Jan, 18:00",
            isUnread: false,
          ),
          _notificationItem(
            icon: Icons.info_outline_rounded,
            color: primaryNavy,
            title: "Pembaruan Sistem",
            description:
                "Sistem manajemen versi 2.0 telah aktif dengan fitur laporan baru.",
            time: "15 Jan, 09:00",
            isUnread: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _notificationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isUnread ? color.withOpacity(0.03) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            if (isUnread)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  height: 12,
                  width: 12,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
            fontSize: 15,
            color: primaryNavy,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              time,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
