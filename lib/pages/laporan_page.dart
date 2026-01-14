import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  DateTime selectedDate = DateTime.now();
  final fmt = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // Data Dummy yang lebih variatif
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
            colorScheme: ColorScheme.light(primary: Colors.blue[800]!),
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Laporan Keuangan",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        children: [
          _buildHeaderPilihTanggal(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMainSummaryCard(),
                  const SizedBox(height: 25),
                  const Text(
                    "Detail Transaksi",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: Colors.white,
      child: InkWell(
        onTap: pilihTanggal,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[100]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.calendar_month_rounded,
                color: Colors.blue[800],
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(selectedDate),
                style: TextStyle(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.arrow_drop_down, color: Colors.blue[800]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[900]!, Colors.blue[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Pendapatan Bersih",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            fmt.format(totalPendapatan),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _miniStat(
                Icons.shopping_bag_outlined,
                "${transaksiTerpilih.length} Item",
              ),
              const SizedBox(width: 15),
              _miniStat(Icons.trending_up, "+12.5%"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
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
            const SizedBox(height: 50),
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 10),
            Text(
              "Tidak ada transaksi hari ini",
              style: TextStyle(color: Colors.grey[500]),
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
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 5,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isJasa ? Colors.orange[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isJasa
                    ? Icons.settings_suggest_rounded
                    : Icons.inventory_2_rounded,
                color: isJasa ? Colors.orange : Colors.green,
              ),
            ),
            title: Text(
              t["judul"],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text(
              t["tipe"],
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            trailing: Text(
              fmt.format(t["total"]),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
        );
      },
    );
  }
}
