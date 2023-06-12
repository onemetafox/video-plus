class NotificationModel {
  int? id;
  String? title;
  String? message;
  String? image;
  String? type;
  int? typeId;
  String? users;
  String? userId;
  String? date;

  NotificationModel(
      {this.id,
      this.title,
      this.message,
      this.image,
      this.type,
      this.typeId,
      this.users,
      this.userId,
      this.date});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    title = json['title'] ?? "";
    message = json['message'] ?? "";
    image = json['image'] ?? "";
    type = json['type'] ?? "";
    typeId = json['type_id'] ?? 0;
    users = json['users'] ?? "";
    userId = json['user_id'] ?? "";
    date = json['date'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['message'] = message;
    data['image'] = image;
    data['type'] = type;
    data['type_id'] = typeId;
    data['users'] = users;
    data['user_id'] = userId;
    data['date'] = date;
    return data;
  }
}
