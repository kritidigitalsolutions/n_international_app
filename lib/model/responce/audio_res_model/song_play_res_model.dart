class SongPlayResModel {
  bool? success;
  String? message;
  PlayData? playData;

  SongPlayResModel({this.success, this.message, this.playData});

  SongPlayResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    playData = json['playData'] != null ? PlayData.fromJson(json['playData']) : null;
  }
}

class PlayData {
  String? id;
  String? title;
  String? artist;
  String? thumbnailUrl;
  String? audioUrl;
  String? thumbnailPlaybackUrl;
  String? audioPlaybackUrl; // ✅ ADD THIS
  int? durationMinutes;

  PlayData({
    this.id,
    this.title,
    this.artist,
    this.thumbnailUrl,
    this.audioUrl,
    this.audioPlaybackUrl, // ✅ ADD
    this.durationMinutes,
  });

  PlayData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    artist = json['artist'];
    thumbnailUrl = json['thumbnailUrl'];
    audioUrl = json['audioUrl'];
    audioPlaybackUrl = json['audioPlaybackUrl']; // ✅ ADD
    durationMinutes = json['durationMinutes'];
    thumbnailPlaybackUrl = json['thumbnailPlaybackUrl'];
  }
}

class VdoCipherPlayback {
  String? otp;
  String? playbackInfo;
  int? ttl;

  VdoCipherPlayback({this.otp, this.playbackInfo, this.ttl});

  VdoCipherPlayback.fromJson(Map<String, dynamic> json) {
    otp = json['otp'];
    playbackInfo = json['playbackInfo'];
    ttl = json['ttl'];
  }
}
