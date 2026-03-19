class PolicyResModel {
  PolicyResModel({required this.success, required this.legal});

  final bool? success;
  final LegalData? legal;

  factory PolicyResModel.fromJson(Map<String, dynamic> json) {
    return PolicyResModel(
      success: json["success"],
      legal: json["legal"] == null ? null : LegalData.fromJson(json["legal"]),
    );
  }
}

class LegalData {
  LegalData({
    required this.id,
    required this.type,
    required this.sections,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  final String? id;
  final String? type;
  final List<Section>? sections;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  factory LegalData.fromJson(Map<String, dynamic> json) {
    return LegalData(
      id: json["_id"],
      type: json["type"],
      sections: json["sections"] == null
          ? []
          : List<Section>.from(json["sections"]!.map((x) => Section.fromJson(x))),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
    );
  }
}

class Section {
  Section({
    required this.title,
    required this.content,
    required this.id,
  });

  final String? title;
  final String? content;
  final String? id;

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      title: json["title"],
      content: json["content"],
      id: json["_id"],
    );
  }
}
