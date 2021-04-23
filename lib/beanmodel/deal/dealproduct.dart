import 'package:groshop/baseurl/baseurlg.dart';

class DealProductModel{
  dynamic status;
  dynamic message;
  List<DealProductDataModel> data;

  DealProductModel(this.status, this.message, this.data);

  factory DealProductModel.fromJson(dynamic json) {
    var subc = json['data'] as List;
    List<DealProductDataModel> subchildRe = [];
    if (subc.length > 0) {
      subchildRe = subc.map((e) => DealProductDataModel.fromJson(e)).toList();
    }
    return DealProductModel(json['status'], json['message'], subchildRe);
  }

  @override
  String toString() {
    return '{status: $status, message: $message, data: $data}';
  }
}

class DealProductDataModel{
  dynamic del_range;
  dynamic store_id;
  dynamic stock;
  dynamic price;
  dynamic varient_image;
  dynamic quantity;
  dynamic unit;
  dynamic mrp;
  dynamic description;
  dynamic product_name;
  dynamic product_image;
  dynamic varient_id;
  dynamic product_id;
  dynamic valid_to;
  dynamic valid_from;
  dynamic timediff;
  dynamic hoursmin;

  DealProductDataModel(
      this.del_range,
      this.store_id,
      this.stock,
      this.price,
      this.varient_image,
      this.quantity,
      this.unit,
      this.mrp,
      this.description,
      this.product_name,
      this.product_image,
      this.varient_id,
      this.product_id,
      this.valid_to,
      this.valid_from,
      this.timediff,
      this.hoursmin);

  factory DealProductDataModel.fromJson(dynamic json){
    return DealProductDataModel(json['del_range'], json['store_id'], json['stock'], json['price'], '$imagebaseUrl${json['varient_image']}', json['quantity'], json['unit'], json['mrp'], json['description'], json['product_name'], '$imagebaseUrl${json['product_image']}', json['varient_id'], json['product_id'], json['valid_to'], json['valid_from'], json['timediff'], json['hoursmin']);
  }

  @override
  String toString() {
    return '{del_range: $del_range, store_id: $store_id, stock: $stock, price: $price, varient_image: $varient_image, quantity: $quantity, unit: $unit, mrp: $mrp, description: $description, product_name: $product_name, product_image: $product_image, varient_id: $varient_id, product_id: $product_id, valid_to: $valid_to, valid_from: $valid_from, timediff: $timediff, hoursmin: $hoursmin}';
  }
}