class DownloadResModel {
  bool? success;
  int? count;
  List<DownloadItem>? downloads;

  DownloadResModel({this.success, this.count, this.downloads});

  DownloadResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    count = json['count'];
    if (json['downloads'] != null) {
      downloads = <DownloadItem>[];
      json['downloads'].forEach((v) {
        downloads!.add(DownloadItem.fromJson(v));
      });
    }
  }
}

class DownloadItem {
  String? sId;
  String? title;
  String? contentType;
  String? mediaPlaybackUrl;
  String? thumbnailPlaybackUrl;
  SeriesInDownload? series;
  EpisodeInDownload? episode;
  SongInDownload? song;

  DownloadItem({
    this.sId,
    this.title,
    this.contentType,
    this.mediaPlaybackUrl,
    this.thumbnailPlaybackUrl,
    this.series,
    this.episode,
    this.song,
  });

  DownloadItem.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    contentType = json['contentType'];
    mediaPlaybackUrl = json['mediaPlaybackUrl'];
    thumbnailPlaybackUrl = json['thumbnailPlaybackUrl'];
    series = json['series'] != null ? SeriesInDownload.fromJson(json['series']) : null;
    episode = json['episode'] != null ? EpisodeInDownload.fromJson(json['episode']) : null;
    song = json['song'] != null ? SongInDownload.fromJson(json['song']) : null;
  }
}

class SeriesInDownload {
  String? sId;
  String? title;
  String? posterPlaybackUrl;

  SeriesInDownload({this.sId, this.title, this.posterPlaybackUrl});

  SeriesInDownload.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    posterPlaybackUrl = json['posterPlaybackUrl'];
  }
}

class EpisodeInDownload {
  String? sId;
  int? episodeNumber;
  String? title;

  EpisodeInDownload({this.sId, this.episodeNumber, this.title});

  EpisodeInDownload.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    episodeNumber = json['episodeNumber'];
    title = json['title'];
  }
}

class SongInDownload {
  String? sId;
  String? title;
  String? artist;
  String? thumbnailUrl;
  String? thumbnailPlaybackUrl;

  SongInDownload({this.sId, this.title, this.artist, this.thumbnailUrl, this.thumbnailPlaybackUrl});

  SongInDownload.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    artist = json['artist'];
    thumbnailUrl = json['thumbnailUrl'];
    thumbnailPlaybackUrl = json['thumbnailPlaybackUrl'];
  }
}
