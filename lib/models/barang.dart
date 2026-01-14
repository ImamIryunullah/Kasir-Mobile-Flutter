class Barang {
  final int? id;
  final String nama;
  final int harga;
  final int stok;
  final String kategori;

  Barang({
    this.id,
    required this.nama,
    required this.harga,
    required this.stok,
    required this.kategori,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'kategori': kategori,
    };
  }

  factory Barang.fromMap(Map<String, dynamic> map) {
    return Barang(
      id: map['id'],
      nama: map['nama'],
      harga: map['harga'],
      stok: map['stok'],
      kategori: map['kategori'],
    );
  }
}
