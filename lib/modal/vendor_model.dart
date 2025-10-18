class VendorModel {
  final String vendorName;
  VendorModel({required this.vendorName});
  factory VendorModel.fromjson(Map<String, dynamic> json) {
    return VendorModel(vendorName: json['vendor_name']);
  }
  Map<String, dynamic> toJson() {
    return {"vendor_name": vendorName};
  }
}
