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
  String? posterImage;
  String? bannerImage;
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
      this.posterImage,
      this.bannerImage,
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
    posterImage = json['posterImage'];
    bannerImage = json['bannerImage'];
    languages = json['languages'].cast<String>();
    genres = json['genres'].cast<String>();
    totalEpisodes = json['totalEpisodes'];
    isPopular = json['isPopular'];
    isTrending = json['isTrending'];
    isLatest = json['isLatest'];
    isTopChart = json['isTopChart'];
    isNewRelease = json['isNewRelease'];
    isRomantic = json['isRomantic'];
    isRevengeDrama = json['isRevengeDrama'];
  }
}
