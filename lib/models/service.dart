class Service {
  final int? id;
  final String pelanggan;
  final String mesin;
  final String lokasi;
  final int biaya;
  final String status; // "Proses" atau "Selesai"
  final String tanggal;

  Service({
    this.id,
    required this.pelanggan,
    required this.mesin,
    required this.lokasi,
    required this.biaya,
    required this.status,
    required this.tanggal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pelanggan': pelanggan,
      'mesin': mesin,
      'lokasi': lokasi,
      'biaya': biaya,
      'status': status,
      'tanggal': tanggal,
    };
  }

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id'],
      pelanggan: map['pelanggan'],
      mesin: map['mesin'],
      lokasi: map['lokasi'],
      biaya: map['biaya'],
      status: map['status'],
      tanggal: map['tanggal'],
    );
  }

  Service copyWith({
    int? id,
    String? pelanggan,
    String? mesin,
    String? lokasi,
    int? biaya,
    String? status,
    String? tanggal,
  }) {
    return Service(
      id: id ?? this.id,
      pelanggan: pelanggan ?? this.pelanggan,
      mesin: mesin ?? this.mesin,
      lokasi: lokasi ?? this.lokasi,
      biaya: biaya ?? this.biaya,
      status: status ?? this.status,
      tanggal: tanggal ?? this.tanggal,
    );
  }
}
