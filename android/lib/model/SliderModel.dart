class SliderModel {
  int? id;
  String? image;
  String? type;
  int? typeId;
  String? date;
  String? videoId;
  String? typeTitle;
  String? typeDescription;
  int? categoryId;
  int? paymentType;
  int? videoType;

  SliderModel(
      {this.id,
      this.image,
      this.type,
      this.typeId,
      this.date,
      this.typeTitle,
      this.typeDescription,
      this.videoId,
      this.categoryId,
      this.paymentType,
      this.videoType});

  SliderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    image = json['image'] ?? "";
    type = json['type'] ?? "";
    typeId = json['type_id'] ?? 0;
    date = json['date'] ?? "";
    typeTitle = json['type_title'] ?? "";
    typeDescription = json['type_description'] ?? "";
    videoId = json['video_id'] ?? "";
    categoryId = json['category_id'] ?? 0;
    paymentType = json['payment_type'] ?? 0;
    videoType = json['video_type'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['type'] = type;
    data['type_id'] = typeId;
    data['date'] = date;
    data['type_title'] = typeTitle;
    data['type_description'] = typeDescription;
    data['video_id'] = videoId;
    data['category_id'] = categoryId;
    data['payment_type'] = paymentType;
    data['video_type'] = videoType;
    return data;
  }
}
