class SeriesResModel {
  bool? success;
  int? page;
  int? limit;
  int? total;
  List<Series>? series;

  SeriesResModel({this.success, this.page, this.limit, this.total, this.series});

  SeriesResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    page = json['page'];
    limit = json['limit'];
    total = json['total'];
    if (json['series'] != null) {
      series = <Series>[];
      json['series'].forEach((v) {
        series!.add(Series.fromJson(v));
      });
    }
  }
}

class Series {
  String? sId;
  String? title;
  String? description;
  String? posterImage;
  String? posterPlaybackUrl;
  String? bannerImage;
  String? trailerUrl;
  List<String>? languages;
  List<String>? genres;
  int? totalEpisodes;
  bool? isPopular;
  bool? isTrending;
  bool? isLatest;
  bool? isTopChart;
  bool? isNewRelease;
  bool? isRomantic;
  bool? isRevengeDrama;

  Series(
      {this.sId,
        this.title,
        this.description,
        this.posterPlaybackUrl,
        this.posterImage,
        this.bannerImage,
        this.trailerUrl,
        this.languages,
        this.genres,
        this.totalEpisodes,
        this.isPopular,
        this.isTrending,
        this.isLatest,
        this.isTopChart,
        this.isNewRelease,
        this.isRomantic,
        this.isRevengeDrama});

  Series.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    description = json['description'];
    posterImage = json['posterImage'];
    bannerImage = json['bannerImage'];
    trailerUrl = json['trailerUrl'];
    posterPlaybackUrl = json['posterPlaybackUrl'];
    languages = json['languages'] != null ? List<String>.from(json['languages']) : [];
    genres = json['genres'] != null ? List<String>.from(json['genres']) : [];
    totalEpisodes = json['totalEpisodes'];
    isPopular = json['isPopular'];
    isTrending = json['isTrending'];
    isLatest = json['isLatest'];
    isTopChart = json['isTopChart'];
    isNewRelease = json['isNewRelease'];
    isRomantic = json['isRomantic'];
    isRevengeDrama = json['isRevengeDrama'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
    data['description'] = description;
    data['posterImage'] = posterImage;
    data['bannerImage'] = bannerImage;
    data['trailerUrl'] = trailerUrl;
    data['posterPlaybackUrl'] = posterPlaybackUrl;
    data['languages'] = languages;
    data['genres'] = genres;
    data['totalEpisodes'] = totalEpisodes;
    data['isPopular'] = isPopular;
    data['isTrending'] = isTrending;
    data['isLatest'] = isLatest;
    data['isTopChart'] = isTopChart;
    data['isNewRelease'] = isNewRelease;
    data['isRomantic'] = isRomantic;
    data['isRevengeDrama'] = isRevengeDrama;
    return data;
  }
}
