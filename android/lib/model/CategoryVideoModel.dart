import '../Utils/apiParameters.dart';

class CategoryVideoModel {
  int? id;
  int? categoryId;
  String? title;
  int? videoType;
  String? videoId;
  String? description;
  int? type;
  String? date;
  String? categoryName;
  String? duration;
  String? image;
  int? userId;
  int? views;
  String? historyDuration;
  CategoryVideoModel(
      {this.id,
      this.categoryId,
      this.title,
      this.videoId,
      this.description,
      this.type,
      this.date,
      this.categoryName,
      this.duration,
      this.videoType,
      this.image,
      this.userId,
      this.views,
      this.historyDuration});

  CategoryVideoModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    categoryId = json['category_id'] ?? 0;
    title = json['title'] ?? "";
    videoType = json['video_type'] ?? 0;
    videoId = json['video_id'] ?? "";
    description = json['description'];
    type = json['type'] ?? 0;
    date = json['date'] ?? "";
    categoryName = json['category_name'] ?? "";
    duration = json['duration'] ?? "";
    image = json["image"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['category_id'] = categoryId;
    data['title'] = title;
    data['video_type'] = videoType;
    data['video_id'] = videoId;
    data['description'] = description;
    data['type'] = type;
    data['date'] = date;
    data['category_name'] = categoryName;
    data['duration'] = duration;
    data['image'] = image;
    return data;
  }

  CategoryVideoModel.historyFromJson(Map<String, dynamic> json) {
    id = json[idKey] ?? '';
    categoryId = json[catIdApiKey] ?? 0;
    title = json[titleApiKey] ?? "";
    videoType = json[videoTypeApiKey] ?? 0;
    videoId = json[videoIdApiKey] ?? "";
    description = json[descrApiKey];
    type = json[typeApiKey] ?? 0;
    date = json[dateApiKey] ?? "";
    categoryName = json[catNameApiKey] ?? "";
    duration = json[durationApiKey] ?? "";
    image = json[imageApiKey];
    userId = json[userIdApiKey];
    views = json[viewsApiKey];
    historyDuration = json[historyDurationApiKey];
  }
}
