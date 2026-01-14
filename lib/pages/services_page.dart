import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final List<Map<String, dynamic>> serviceLogs = [
    {
      "pelanggan": "Percetakan Jaya",
      "mesin": "Canon iR2525",
      "toko": "Cabang Utama",
      "biaya": 150000,
      "status": "Selesai",
      "tanggal": "14 Jan 2026",
    },
    {
      "pelanggan": "Bapak Budi",
      "mesin": "Kyocera M2040",
      "toko": "Onsite Pelanggan",
      "biaya": 200000,
      "status": "Proses",
      "tanggal": "14 Jan 2026",
    },
  ];

  final fmt = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  void _tandaiSelesai(int index) {
    setState(() {
      serviceLogs[index]["status"] = "Selesai";
    });
  }

  void _tambahService(
    String pelanggan,
    String mesin,
    String lokasi,
    int biaya,
  ) {
    setState(() {
      serviceLogs.insert(0, {
        "pelanggan": pelanggan,
        "mesin": mesin,
        "toko": lokasi,
        "biaya": biaya,
        "status": "Proses",
        "tanggal": DateFormat('dd MMM yyyy').format(DateTime.now()),
      });
    });
  }

  void _showServiceDialog() {
    final pelangganCtrl = TextEditingController();
    final mesinCtrl = TextEditingController();
    final lokasiCtrl = TextEditingController();
    final biayaCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Catat Jasa Service"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pelangganCtrl,
              decoration: const InputDecoration(labelText: "Nama Pelanggan"),
            ),
            TextField(
              controller: mesinCtrl,
              decoration: const InputDecoration(labelText: "Tipe Mesin"),
            ),
            TextField(
              controller: lokasiCtrl,
              decoration: const InputDecoration(labelText: "Lokasi Pengerjaan"),
            ),
            TextField(
              controller: biayaCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Estimasi Biaya",
                prefixText: "Rp ",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (pelangganCtrl.text.isEmpty ||
                  lokasiCtrl.text.isEmpty ||
                  biayaCtrl.text.isEmpty)
                return;

              final biaya = int.tryParse(biayaCtrl.text);
              if (biaya == null) return;

              _tambahService(
                pelangganCtrl.text,
                mesinCtrl.text,
                lokasiCtrl.text,
                biaya,
              );
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Jasa Service Mesin"),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: serviceLogs.length,
        itemBuilder: (context, index) {
          final log = serviceLogs[index];
          final selesai = log["status"] == "Selesai";

          return Opacity(
            opacity: selesai ? 0.6 : 1,
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          log["tanggal"],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        _buildStatusBadge(log["status"]),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        if (selesai)
                          const Icon(Icons.check_circle, color: Colors.green),
                        if (selesai) const SizedBox(width: 6),
                        Text(
                          log["pelanggan"],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            decoration: selesai
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text("${log["mesin"]} • ${log["toko"]}"),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          fmt.format(log["biaya"]),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        if (!selesai)
                          ElevatedButton.icon(
                            onPressed: () => _tandaiSelesai(index),
                            icon: const Icon(Icons.done),
                            label: const Text("Tandai Selesai"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showServiceDialog,
        icon: const Icon(Icons.add),
        label: const Text("Catat Service"),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: status == "Selesai" ? Colors.green[100] : Colors.orange[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: status == "Selesai" ? Colors.green : Colors.orange,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
