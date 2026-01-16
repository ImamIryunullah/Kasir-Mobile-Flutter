import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  // Tema Warna Konsisten
  static const Color primaryNavy = Color(0xFF2C3E50);
  static const Color accentBlue = Color(0xFF34495E);
  static const Color backgroundLight = Color(0xFFF8FAFC);

  DateTime selectedDate = DateTime.now();
  final fmt = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final List<Map<String, dynamic>> transaksi = [
    {
      "tanggal": DateTime.now(),
      "judul": "Penjualan Toner NPG-51",
      "total": 250000,
      "tipe": "Barang",
    },
    {
      "tanggal": DateTime.now(),
      "judul": "Service Canon iR2525",
      "total": 150000,
      "tipe": "Jasa",
    },
    {
      "tanggal": DateTime.now(),
      "judul": "Penjualan Drum Unit",
      "total": 850000,
      "tipe": "Barang",
    },
    {
      "tanggal": DateTime.now().subtract(const Duration(days: 1)),
      "judul": "Service Kyocera",
      "total": 300000,
      "tipe": "Jasa",
    },
  ];

  List<Map<String, dynamic>> get transaksiTerpilih {
    return transaksi
        .where((t) => DateUtils.isSameDay(t["tanggal"], selectedDate))
        .toList();
  }

  int get totalPendapatan =>
      transaksiTerpilih.fold(0, (sum, item) => sum + (item["total"] as int));

  Future<void> pilihTanggal() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: primaryNavy),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => selectedDate = picked);
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
          "Laporan Keuangan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryNavy,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeaderPilihTanggal(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainSummaryCard(),
                  const SizedBox(height: 32),
                  const Text(
                    "Riwayat Transaksi",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTransactionList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPilihTanggal() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: InkWell(
        onTap: pilihTanggal,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: primaryNavy,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DateFormat(
                      'EEEE, dd MMM yyyy',
                      'id_ID',
                    ).format(selectedDate),
                    style: const TextStyle(
                      color: primaryNavy,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, color: primaryNavy),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainSummaryCard() {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [primaryNavy, accentBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryNavy.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Gambar Background Ikon
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.1,
              child: Icon(
                Icons.analytics_outlined,
                size: 160,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Pendapatan",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  fmt.format(totalPendapatan),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _miniStat(
                      Icons.receipt_long_outlined,
                      "${transaksiTerpilih.length} Transaksi",
                    ),
                    const SizedBox(width: 12),
                    _miniStat(Icons.insights_rounded, "Stabil"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    if (transaksiTerpilih.isEmpty) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(Icons.notes_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "Tidak ada data transaksi",
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transaksiTerpilih.length,
      itemBuilder: (context, index) {
        final t = transaksiTerpilih[index];
        final isJasa = t["tipe"] == "Jasa";

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
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
                  color: isJasa ? Colors.amber.shade50 : Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isJasa ? Icons.handyman_outlined : Icons.inventory_2_outlined,
                  color: isJasa ? Colors.amber.shade800 : Colors.teal.shade800,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t["judul"],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryNavy,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t["tipe"],
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
              ),
              Text(
                fmt.format(t["total"]),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryNavy,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
