class ScannedItemModal {
  final String? id; // Store NEWID as String for UI convenience
  final String serialNumber;
  final String format;
  final String scannedAt;

  ScannedItemModal({
    this.id,
    required this.serialNumber,
    required this.format,
    required this.scannedAt,
  });

  factory ScannedItemModal.fromMap(Map<String, dynamic> json) {
    return ScannedItemModal(
      id: json['id']?.toString(), // map SQLite PK NEWID
      serialNumber: json['serialNumber'] ?? "",
      format: json['scanned_type'] ?? "",
      scannedAt: json['scannedAt'] ?? "", // convert int → bool
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serialNumber': serialNumber,
      'scanned_type': format,
      'scannedAt': scannedAt,
    };
  }
}
