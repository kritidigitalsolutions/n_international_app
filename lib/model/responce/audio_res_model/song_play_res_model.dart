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
  int? durationMinutes;
  VdoCipherPlayback? vdoCipherPlayback;

  PlayData({
    this.id,
    this.title,
    this.artist,
    this.thumbnailUrl,
    this.audioUrl,
    this.durationMinutes,
    this.vdoCipherPlayback,
  });

  PlayData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    artist = json['artist'];
    thumbnailUrl = json['thumbnailUrl'];
    audioUrl = json['audioUrl'];
    durationMinutes = json['durationMinutes'];
    vdoCipherPlayback = json['vdoCipherPlayback'] != null
        ? VdoCipherPlayback.fromJson(json['vdoCipherPlayback'])
        : null;
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
