class PlayEpisodeResModel {
  bool? success;
  String? provider;
  String? episodeId;
  String? videoId;
  String? otp;
  String? playbackInfo;
  int? ttl;

  PlayEpisodeResModel({
    this.success,
    this.provider,
    this.episodeId,
    this.videoId,
    this.otp,
    this.playbackInfo,
    this.ttl,
  });

  PlayEpisodeResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    provider = json['provider'];
    episodeId = json['episodeId'];
    videoId = json['videoId'];
    otp = json['otp'];
    playbackInfo = json['playbackInfo'];
    ttl = json['ttl'];
  }
}
