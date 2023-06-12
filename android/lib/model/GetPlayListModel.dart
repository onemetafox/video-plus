class GetPlayListModel {
  int? id;
  String? name;
  int? userId;
  String? date;
  List<Videos>? videos;

  GetPlayListModel({this.id, this.name, this.userId, this.date, this.videos});

  GetPlayListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    name = json['name'] ?? "";
    userId = json['user_id'] ?? 0;
    date = json['date'] ?? "";
    if (json['videos'] != null) {
      videos = <Videos>[];
      json['videos'].forEach((v) {
        videos!.add(Videos.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['user_id'] = userId;
    data['date'] = date;
    if (videos != null) {
      data['videos'] = videos!.map((v) => v.toJson()).toSet().toList();
    }
    return data;
  }
}

class Videos {
  int? playlistVideoId;
  int? playlistId;
  int? userId;
  int? id;
  int? categoryId;
  String? categoryName;
  String? title;
  int? videoType;
  String? videoId;
  String? duration;
  String? description;
  int? type;
  String? date;
  String? image;
  Videos(
      {this.playlistVideoId,
      this.playlistId,
      this.userId,
      this.id,
      this.categoryId,
      this.title,
      this.videoId,
      this.duration,
      this.description,
      this.type,
      this.date,
      this.categoryName,
      this.videoType,
      this.image});

  Videos.fromJson(Map<String, dynamic> json) {
    playlistVideoId = json['playlist_video_id'] ?? 0;
    playlistId = json['playlist_id'] ?? 0;
    userId = json['user_id'] ?? 0;
    id = json['id'] ?? 0;
    categoryId = json['category_id'] ?? 0;
    title = json['title'] ?? "";
    videoType = json['video_type'] ?? 0;
    videoId = json['video_id'] ?? "";
    duration = json['duration'] ?? "";
    description = json['description'] ?? "";
    type = json['type'] ?? 0;
    date = json['date'] ?? "";
    categoryName = json['category_name'] ?? "";
    image = json["image"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['playlist_video_id'] = playlistVideoId;
    data['playlist_id'] = playlistId;
    data['user_id'] = userId;
    data['id'] = id;
    data['category_id'] = categoryId;
    data['title'] = title;
    data['video_type'] = videoType;
    data['video_id'] = videoId;
    data['duration'] = duration;
    data['description'] = description;
    data['type'] = type;
    data['date'] = date;
    data['category_name'] = categoryName;
    data["image"] = image;
    return data;
  }
}
