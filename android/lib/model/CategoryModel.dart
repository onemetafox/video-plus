class CategoryModel {
  int? id;
  String? categoryName;
  String? image;
  String? description;
  int? sequence;
  String? date;
  int? totalVideo;

  CategoryModel(
      {this.id,
      this.categoryName,
      this.image,
      this.description,
      this.sequence,
      this.date,
      this.totalVideo});

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    categoryName = json['category_name'] ?? "";
    image = json['image'] ?? "";
    description = json['description'] ?? "";
    sequence = json['sequence'] ?? 0;
    date = json['date'] ?? "";
    totalVideo = json['total_video'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['category_name'] = categoryName;
    data['image'] = image;
    data['description'] = description;
    data['sequence'] = sequence;
    data['date'] = date;
    data['total_video'] = totalVideo;
    return data;
  }
}
