class ContactUsResModel {
  ContactUsResModel({required this.success, required this.contact});

  final bool? success;
  final ContactData? contact;

  factory ContactUsResModel.fromJson(Map<String, dynamic> json) {
    return ContactUsResModel(
      success: json["success"],
      contact: json["contact"] == null
          ? null
          : ContactData.fromJson(json["contact"]),
    );
  }
}

class ContactData {
  ContactData({
    required this.id,
    required this.email,
    required this.phone,
    required this.address,
    required this.facebook,
    required this.instagram,
    required this.twitter,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  final String? id;
  final String? email;
  final String? phone;
  final String? address;
  final String? facebook;
  final String? instagram;
  final String? twitter;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory ContactData.fromJson(Map<String, dynamic> json) {
    return ContactData(
      id: json["_id"],
      email: json["email"],
      phone: json["phone"],
      address: json["address"],
      facebook: json["facebook"],
      instagram: json["instagram"],
      twitter: json["twitter"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
    );
  }
}
