import 'song_res_model.dart';

class PlaylistResModel {
  bool? success;
  List<Song>? playlist;

  PlaylistResModel({this.success, this.playlist});

  PlaylistResModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['playlist'] != null) {
      playlist = <Song>[];
      json['playlist'].forEach((v) {
        playlist!.add(Song.fromJson(v));
      });
    }
  }
}
