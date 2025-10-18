class VendorModel {
  int? id;
  String? vendorName;

  VendorModel.fromjson(Map<String, dynamic> json) {
    id = json['id'];
    vendorName = json['vendor_name'];
  }
}