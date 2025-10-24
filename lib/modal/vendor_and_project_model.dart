class VendorModel {
  final int slno;
  final String vendorName;

  VendorModel({
    required this.slno,
    required this.vendorName,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      slno: json['slno'] ?? json['Slno'] ?? 0,
      vendorName: json['vendor_name'] ?? json['Vendor Name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slno': slno,
      'vendor_name': vendorName,
    };
  }
}


class ProjectModel {
  final int vendorId;
  final String projectName;

  ProjectModel({
    required this.vendorId,
    required this.projectName,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      vendorId: json['vendor_id'] ?? json['Vendor ID'] ?? 0,
      projectName: json['project_name'] ?? json['Project Name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendor_id': vendorId,
      'project_name': projectName,
    };
  }
}

