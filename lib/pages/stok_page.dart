import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StokBarangPage extends StatefulWidget {
  const StokBarangPage({super.key});

  @override
  State<StokBarangPage> createState() => _StokBarangPageState();
}

class _StokBarangPageState extends State<StokBarangPage> {
  // ================= DATA =================
  final List<Map<String, dynamic>> stokItems = [
    {
      "nama": "Mesin Canon iR2525",
      "harga": 15500000,
      "stok": 5,
      "cat": "Mesin",
    },
    {"nama": "Toner NPG-51", "harga": 250000, "stok": 50, "cat": "Sparepart"},
    {"nama": "Drum Unit", "harga": 850000, "stok": 12, "cat": "Sparepart"},
  ];

  final TextEditingController searchCtrl = TextEditingController();
  String keyword = "";

  final fmt = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // ================= FILTER =================
  List<Map<String, dynamic>> get filteredItems {
    if (keyword.isEmpty) return stokItems;
    return stokItems.where((item) {
      final text = "${item['nama']} ${item['cat']}".toLowerCase();
      return text.contains(keyword.toLowerCase());
    }).toList();
  }

  // ================= CRUD =================
  void _tambahBarang(String nama, int harga, int stok) {
    setState(() {
      stokItems.add({
        "nama": nama,
        "harga": harga,
        "stok": stok,
        "cat": "Umum",
      });
    });
  }

  void _editBarang(int index, String nama, int harga, int stok) {
    setState(() {
      stokItems[index] = {
        "nama": nama,
        "harga": harga,
        "stok": stok,
        "cat": stokItems[index]["cat"],
      };
    });
  }

  void _hapusBarang(int index) {
    setState(() {
      stokItems.removeAt(index);
    });
  }

  // ================= FORM =================
  void _showFormDialog({int? index}) {
    final isEdit = index != null;
    final item = isEdit ? stokItems[index] : null;

    final nameCtrl = TextEditingController(text: item?["nama"] ?? "");
    final hargaCtrl = TextEditingController(
      text: item?["harga"]?.toString() ?? "",
    );
    final stokCtrl = TextEditingController(
      text: item?["stok"]?.toString() ?? "",
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEdit ? "Edit Barang" : "Tambah Barang"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: "Nama Barang"),
            ),
            TextField(
              controller: hargaCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Harga"),
            ),
            TextField(
              controller: stokCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Jumlah Stok"),
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
              final harga = int.tryParse(hargaCtrl.text);
              final stok = int.tryParse(stokCtrl.text);
              if (harga == null || stok == null) return;

              if (isEdit) {
                _editBarang(index!, nameCtrl.text, harga, stok);
              } else {
                _tambahBarang(nameCtrl.text, harga, stok);
              }
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text("Stok Barang"), centerTitle: true),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: searchCtrl,
              onChanged: (val) {
                setState(() => keyword = val);
              },
              decoration: InputDecoration(
                hintText: "Cari barang atau kategori...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // LIST
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(
                    child: Text(
                      "Barang tidak ditemukan",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(15),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.inventory_2,
                              color: Colors.blue,
                            ),
                          ),
                          title: Text(
                            item["nama"],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Text(
                                fmt.format(item["harga"]),
                                style: TextStyle(color: Colors.blue[800]),
                              ),
                              Text("Stok: ${item["stok"]}"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                onPressed: () => _showFormDialog(
                                  index: stokItems.indexOf(item),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    stokItems.remove(item);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFormDialog(),
        icon: const Icon(Icons.add),
        label: const Text("Tambah Barang"),
      ),
    );
  }
}
