class PlayEpisodeResModel {
  bool? success;
  String? provider;
  String? episodeId;
  bool? unlockedNow;
  bool? alreadyUnlocked;
  int? walletBalance;
  String? videoUrl;
  String? videoId;
  String? otp;
  String? videoPlaybackUrl;
  int? ttl;
  String? seriesId;

  PlayEpisodeResModel({
    this.success,
    this.provider,
    this.episodeId,
    this.unlockedNow,
    this.alreadyUnlocked,
    this.walletBalance,
    this.videoUrl,
    this.videoId,
    this.otp,
    this.videoPlaybackUrl,
    this.ttl,
    this.seriesId,
  });

  PlayEpisodeResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    provider = json['provider'];
    episodeId = json['episodeId'];
    unlockedNow = json['unlockedNow'];
    alreadyUnlocked = json['alreadyUnlocked'];
    walletBalance = json['walletBalance'];
    videoUrl = json['videoUrl'];
    videoId = json['videoId'];
    otp = json['otp'];
    videoPlaybackUrl = json['videoPlaybackUrl'];
    ttl = json['ttl'];
    seriesId = json['seriesId'];
  }
}
