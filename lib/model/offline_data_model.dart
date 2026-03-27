class OfflineItem {
  String id;
  String title;
  String filePath;
  String contentType;
  String? image;
  String? subtitle;

  OfflineItem({
    required this.id,
    required this.title,
    required this.filePath,
    required this.contentType,
    this.image,
    this.subtitle,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "filePath": filePath,
    "contentType": contentType,
    "image": image,
    "subtitle": subtitle,
  };

  factory OfflineItem.fromJson(Map<String, dynamic> json) {
    return OfflineItem(
      id: json["id"],
      title: json["title"],
      filePath: json["filePath"],
      contentType: json["contentType"],
      image: json["image"],
      subtitle: json["subtitle"],
    );
  }
}
