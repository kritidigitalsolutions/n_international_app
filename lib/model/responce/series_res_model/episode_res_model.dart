class EpisodeResModel {
  bool? success;
  int? count;
  List<Episode>? episodes;

  EpisodeResModel({this.success, this.count, this.episodes});

  EpisodeResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    count = json['count'];

    if (json['episodes'] != null) {
      episodes = <Episode>[];
      json['episodes'].forEach((v) {
        episodes!.add(Episode.fromJson(v));
      });
    }
  }
}
class Episode {
  String? id;
  int? episodeNumber;
  String? title;
  String? description;
  String? thumbnail;
  String? videoUrl;
  int? durationMinutes;
  bool? isLocked;

  Episode.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    episodeNumber = json['episodeNumber'];
    title = json['title'];
    description = json['description'];
    thumbnail = json['thumbnail'];
    videoUrl = json['videoUrl'];
    durationMinutes = json['durationMinutes'];
    isLocked = json['isLocked'];
  }
}
