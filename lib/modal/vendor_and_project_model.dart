class VendorAndProjectModel {
  final int? slno;
  final String vendorName;
  final String projectName;

  VendorAndProjectModel({required this.slno, required this.vendorName, required this.projectName});

  factory VendorAndProjectModel.fromJson(Map<String, dynamic> json)
  {
    return VendorAndProjectModel(
      slno: json['slno'],
      vendorName: json['vendor_name'],
      projectName: json['project_name'],
    );
  }
}