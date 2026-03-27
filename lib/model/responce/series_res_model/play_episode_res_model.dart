class PlayEpisodeResModel {
  bool? success;String? provider;
  String? episodeId;
  String? videoUrl; // Added for R2
  String? videoId;  // Keep for backward compatibility
  String? otp;
  String? videoPlaybackUrl;
  int? ttl;
  String? seriesId;

  PlayEpisodeResModel({
    this.success,
    this.provider,
    this.episodeId,
    this.videoUrl,
    this.videoId,
    this.otp,
    this.videoPlaybackUrl,
    this.ttl,
    this.seriesId
  });

  PlayEpisodeResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    provider = json['provider'];
    episodeId = json['episodeId'];
    videoUrl = json['videoUrl']; // Added for R2
    videoId = json['videoId'];
    otp = json['otp'];
    videoPlaybackUrl = json['videoPlaybackUrl'];
    ttl = json['ttl'];
    seriesId = json['seriesId'];
  }
}