import 'package:groshop/baseurl/baseurlg.dart';

class AddToCartMainModel{

  dynamic status;
  dynamic message;
  dynamic total_price;
  List<AddToCartItem> cart_items;

  AddToCartMainModel(this.status, this.message, this.total_price, this.cart_items);

  factory AddToCartMainModel.fromJson(dynamic json){

    var jsData = json['cart_items'] as List;
    List<AddToCartItem> ct = [];
    if(jsData!=null && jsData.length>0){
      ct = jsData.map((e) => AddToCartItem.fromJson(e)).toList();
    }
    return AddToCartMainModel(json['status'], json['message'], json['total_price'], ct);
  }

  @override
  String toString() {
    return '{status: $status, message: $message, total_price: $total_price, cart_items: $cart_items}';
  }
}

class AddToCartItem{
  dynamic store_order_id;
  dynamic product_name;
  dynamic varient_image;
  dynamic quantity;
  dynamic unit;
  dynamic varient_id;
  dynamic qty;
  dynamic price;
  dynamic total_mrp;
  dynamic order_cart_id;
  dynamic order_date;
  dynamic store_approval;
  dynamic store_id;
  dynamic description;

  AddToCartItem(
      this.store_order_id,
      this.product_name,
      this.varient_image,
      this.quantity,
      this.unit,
      this.varient_id,
      this.qty,
      this.price,
      this.total_mrp,
      this.order_cart_id,
      this.order_date,
      this.store_approval,
      this.store_id,
      this.description);

  factory AddToCartItem.fromJson(dynamic json){
    return AddToCartItem(json['store_order_id'], json['product_name'], '$imagebaseUrl${json['varient_image']}', json['quantity'], json['unit'], json['varient_id'], json['qty'], json['price'], json['total_mrp'], json['order_cart_id'], json['order_date'], json['store_approval'], json['store_id'], json['description']);
  }

  @override
  String toString() {
    return '{store_order_id: $store_order_id, product_name: $product_name, varient_image: $varient_image, quantity: $quantity, unit: $unit, varient_id: $varient_id, qty: $qty, price: $price, total_mrp: $total_mrp, order_cart_id: $order_cart_id, order_date: $order_date, store_approval: $store_approval, store_id: $store_id, description: $description}';
  }
}