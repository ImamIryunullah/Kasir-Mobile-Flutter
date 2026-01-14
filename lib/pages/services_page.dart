import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/service.dart';
import '../repositories/service_repository.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  final ServiceRepository repo = ServiceRepository();
  final TextEditingController searchCtrl = TextEditingController();

  List<Service> serviceLogs = [];
  String filterStatus = "Semua"; // "Semua", "Proses", "Selesai"

  final fmt = NumberFormat.currency(
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
    final data = await repo.getAllService();
    setState(() {
      serviceLogs = data;
    });
  }

  Future<void> _search(String keyword) async {
    if (keyword.isEmpty) {
      _loadData();
    } else {
      final result = await repo.searchService(keyword);
      setState(() {
        serviceLogs = result;
      });
    }
  }

  List<Service> get filteredLogs {
    if (filterStatus == "Semua") return serviceLogs;
    return serviceLogs.where((s) => s.status == filterStatus).toList();
  }

  Future<void> _tandaiSelesai(Service service) async {
    final updated = service.copyWith(status: "Selesai");
    await repo.updateService(updated);
    _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Service ${service.pelanggan} selesai!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _tambahService(
    String pelanggan,
    String mesin,
    String lokasi,
    int biaya,
  ) async {
    final service = Service(
      pelanggan: pelanggan,
      mesin: mesin,
      lokasi: lokasi,
      biaya: biaya,
      status: "Proses",
      tanggal: DateFormat('dd MMM yyyy', 'id').format(DateTime.now()),
    );

    await repo.insertService(service);
    _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Service berhasil dicatat!'),
          backgroundColor: Colors.blue,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _editService(Service service) async {
    final pelangganCtrl = TextEditingController(text: service.pelanggan);
    final mesinCtrl = TextEditingController(text: service.mesin);
    final lokasiCtrl = TextEditingController(text: service.lokasi);
    final biayaCtrl = TextEditingController(text: service.biaya.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Edit Service"),
        content: SingleChildScrollView(
          child: Column(
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
                decoration: const InputDecoration(labelText: "Lokasi"),
              ),
              TextField(
                controller: biayaCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Biaya",
                  prefixText: "Rp ",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (pelangganCtrl.text.isEmpty ||
                  lokasiCtrl.text.isEmpty ||
                  biayaCtrl.text.isEmpty)
                return;

              final biaya = int.tryParse(biayaCtrl.text);
              if (biaya == null) return;

              final updated = service.copyWith(
                pelanggan: pelangganCtrl.text,
                mesin: mesinCtrl.text,
                lokasi: lokasiCtrl.text,
                biaya: biaya,
              );

              await repo.updateService(updated);
              if (mounted) Navigator.pop(context);
              _loadData();
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String pelanggan) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Hapus Service?'),
            content: Text(
              'Apakah Anda yakin ingin menghapus service untuk "$pelanggan"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Batal',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showServiceDialog() {
    final pelangganCtrl = TextEditingController();
    final mesinCtrl = TextEditingController();
    final lokasiCtrl = TextEditingController();
    final biayaCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Catat Jasa Service"),
        content: SingleChildScrollView(
          child: Column(
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
                decoration: const InputDecoration(
                  labelText: "Lokasi Pengerjaan",
                ),
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
    final displayedLogs = filteredLogs;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Jasa Service Mesin",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
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
                hintText: 'Cari pelanggan, mesin, atau lokasi...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _filterChip("Semua"),
                const SizedBox(width: 8),
                _filterChip("Proses"),
                const SizedBox(width: 8),
                _filterChip("Selesai"),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Service List
          Expanded(
            child: displayedLogs.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada data service',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: displayedLogs.length,
                    itemBuilder: (context, index) {
                      final service = displayedLogs[index];
                      final selesai = service.status == "Selesai";

                      return Opacity(
                        opacity: selesai ? 0.7 : 1,
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.grey[200]!),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      service.tanggal,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    _buildStatusBadge(service.status),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  children: [
                                    if (selesai)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 20,
                                      ),
                                    if (selesai) const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        service.pelanggan,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          decoration: selesai
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${service.mesin} • ${service.lokasi}",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      fmt.format(service.biaya),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        if (!selesai) ...[
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              color: Colors.orange,
                                              size: 20,
                                            ),
                                            onPressed: () =>
                                                _editService(service),
                                            tooltip: "Edit",
                                          ),
                                          const SizedBox(width: 4),
                                          ElevatedButton.icon(
                                            onPressed: () =>
                                                _tandaiSelesai(service),
                                            icon: const Icon(
                                              Icons.done,
                                              size: 18,
                                            ),
                                            label: const Text("Selesai"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                          ),
                                        ] else
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                              size: 20,
                                            ),
                                            onPressed: () async {
                                              bool yakin = await _confirmDelete(
                                                context,
                                                service.pelanggan,
                                              );
                                              if (yakin) {
                                                await repo.deleteService(
                                                  service.id!,
                                                );
                                                _loadData();
                                                if (mounted) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'Service ${service.pelanggan} dihapus',
                                                      ),
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            tooltip: "Hapus",
                                          ),
                                      ],
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showServiceDialog,
        backgroundColor: Colors.blue[800],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Catat Service",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _filterChip(String label) {
    bool isSelected = filterStatus == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          filterStatus = label;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[800],
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue[800] : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? Colors.blue[800]! : Colors.grey[300]!,
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
