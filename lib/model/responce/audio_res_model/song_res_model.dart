class SongResModel {
  bool? success;
  List<Song>? songs;

  SongResModel({this.success, this.songs});

  SongResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['songs'] != null) {
      songs = <Song>[];
      json['songs'].forEach((v) {
        songs!.add(Song.fromJson(v));
      });
    }
  }
}

class Song {
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
  DateTime? createdAt;
  DateTime? updatedAt;
  String? thumbnail;

  Song({
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
    this.createdAt,
    this.updatedAt,
    this.thumbnail,
  });

  Song.fromJson(Map<String, dynamic> json) {
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
    createdAt = DateTime.tryParse(json["createdAt"] ?? "");
    updatedAt = DateTime.tryParse(json["updatedAt"] ?? "");
    thumbnail = json['thumbnail'];
  }
}
