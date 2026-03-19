import 'series_res_model.dart';

class FavoriteResModel {
  bool? success;
  int? count;
  List<FavoriteItem>? items;

  FavoriteResModel({this.success, this.count, this.items});

  FavoriteResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    count = json['count'];
    if (json['items'] != null) {
      items = <FavoriteItem>[];
      json['items'].forEach((v) {
        items!.add(FavoriteItem.fromJson(v));
      });
    }
  }
}

class FavoriteItem {
  String? favoriteId;
  DateTime? addedAt;
  Series? series;

  FavoriteItem({this.favoriteId, this.addedAt, this.series});

  FavoriteItem.fromJson(Map<String, dynamic> json) {
    favoriteId = json['favoriteId'];
    addedAt = DateTime.tryParse(json['addedAt'] ?? "");
    series = json['series'] != null ? Series.fromJson(json['series']) : null;
  }
}
