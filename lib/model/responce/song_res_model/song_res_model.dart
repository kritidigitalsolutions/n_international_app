class FavoriteSongResModel {
  bool? success;
  List<FavoriteSong>? favorites;

  FavoriteSongResModel({this.success, this.favorites});

  FavoriteSongResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];

    if (json['favorites'] != null) {
      favorites = <FavoriteSong>[];
      json['favorites'].forEach((v) {
        favorites!.add(FavoriteSong.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['success'] = success;

    if (favorites != null) {
      data['favorites'] = favorites!.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class FavoriteSong {
  String? id;
  String? title;
  String? artist;
  String? thumbnailUrl;
  String? audioUrl;
  int? durationMinutes;
  bool? isPopular;
  bool? isTrending;
  bool? isTopChart;
  bool? isNewRelease;
  int? playCount;
  String? createdAt;
  String? updatedAt;
  int? v;

  FavoriteSong({
    this.id,
    this.title,
    this.artist,
    this.thumbnailUrl,
    this.audioUrl,
    this.durationMinutes,
    this.isPopular,
    this.isTrending,
    this.isTopChart,
    this.isNewRelease,
    this.playCount,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  FavoriteSong.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    title = json['title'];
    artist = json['artist'];
    thumbnailUrl = json['thumbnailUrl'];
    audioUrl = json['audioUrl'];
    durationMinutes = json['durationMinutes'];
    isPopular = json['isPopular'];
    isTrending = json['isTrending'];
    isTopChart = json['isTopChart'];
    isNewRelease = json['isNewRelease'];
    playCount = json['playCount'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    data['_id'] = id;
    data['title'] = title;
    data['artist'] = artist;
    data['thumbnailUrl'] = thumbnailUrl;
    data['audioUrl'] = audioUrl;
    data['durationMinutes'] = durationMinutes;
    data['isPopular'] = isPopular;
    data['isTrending'] = isTrending;
    data['isTopChart'] = isTopChart;
    data['isNewRelease'] = isNewRelease;
    data['playCount'] = playCount;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = v;

    return data;
  }
}

