class AboutUsResModel {
  AboutUsResModel({required this.success, required this.about});

  final bool? success;
  final AboutData? about;

  factory AboutUsResModel.fromJson(Map<String, dynamic> json) {
    return AboutUsResModel(
      success: json["success"],
      about: json["about"] == null
          ? null
          : AboutData.fromJson(json["about"]),
    );
  }
}

class AboutData {
  AboutData({
    required this.id,
    required this.companyName,
    required this.tagline,
    required this.whoWeAre,
    required this.vision,
    required this.mission,
    required this.downloads,
    required this.rating,
    required this.countries,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  final String? id;
  final String? companyName;
  final String? tagline;
  final String? whoWeAre;
  final String? vision;
  final String? mission;
  final String? downloads;
  final String? rating;
  final String? countries;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory AboutData.fromJson(Map<String, dynamic> json) {
    return AboutData(
      id: json["_id"],
      companyName: json["companyName"],
      tagline: json["tagline"],
      whoWeAre: json["whoWeAre"],
      vision: json["vision"],
      mission: json["mission"],
      downloads: json["downloads"],
      rating: json["rating"],
      countries: json["countries"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
    );
  }
}
