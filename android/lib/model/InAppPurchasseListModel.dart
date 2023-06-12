/*class InAppPurchaseListModel {
  int? id;
  String? type, name, product_id, days;
  InAppPurchaseListModel(
      this.name, this.type, this.id, this.days, this.product_id);
  InAppPurchaseListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    name = json['name'];
    product_id = json['product_id'];
    days = json['days'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = id;
    data['type'] = type;
    data['name'] = name;
    data['product_id'] = product_id;
    data['days'] = days;
    return data;
  }
}*/
class InAppPurchaseListModel {
  int? id;
  String? type;
  String? name;
  String? productId;
  String? days;
  int? status;
  int? isActive;

  InAppPurchaseListModel(
      {this.id,
      this.type,
      this.name,
      this.productId,
      this.days,
      this.status,
      this.isActive});

  InAppPurchaseListModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? 0;
    type = json['type'] ?? "";
    name = json['name'] ?? "";
    productId = json['product_id'] ?? "";
    days = json['days'] ?? "";
    status = json['status'] ?? 0;
    isActive = json['is_active'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['name'] = name;
    data['product_id'] = productId;
    data['days'] = days;
    data['status'] = status;
    data['is_active'] = isActive;
    return data;
  }
}
