class ScannedItemModal {
  final String? id; // Primary Key or UUID from SQLite/API
  final String serialNumber; // The scanned serial number
  final String format; // The barcode format (QR, Code128, etc.)
  final String scannedAt; // When it was scanned (as String or ISO timestamp)

  ScannedItemModal({
    this.id,
    required this.serialNumber,
    required this.format,
    required this.scannedAt,
  });

  // ✅ Factory constructor to read data from SQLite/API JSON
  factory ScannedItemModal.fromJson(Map<String, dynamic> json) {
    return ScannedItemModal(
      id: json['id']?.toString(), // SQLite PK NEWID or API ID
      serialNumber: json['serialNumber'] ?? "", // Matches your column/key
      format: json['scanned_type'] ?? "", // Matches your column/key
      scannedAt:
          json['scannedAt']?.toString() ?? "", // Store timestamp as String
    );
  }

  // ✅ Convert model to Map for inserting into SQLite / sending to API
  Map<String, dynamic> mapToJson() {
    return {
      'serialNumber': serialNumber,
      'scanned_type': format,
      'scannedAt': scannedAt,
    };
  }
}

class ListOfScannedDataAndResponseMessage {
  final List<ScannedItemModal>? listOfScannedData;
  final String responseMessage;

  ListOfScannedDataAndResponseMessage({
    this.listOfScannedData,
    required this.responseMessage,
  });
}
