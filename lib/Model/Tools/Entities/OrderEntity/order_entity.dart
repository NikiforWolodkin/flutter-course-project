import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_ecommerce/Model/Tools/JsonParse/product_parse.dart';
import 'package:hive/hive.dart';

part 'order_entity.g.dart';

@HiveType(typeId: 2)
class OrderEntity {
  @HiveField(0)
  final List<ProductEntity> productList;
  @HiveField(1)
  final String totalPrice;
  @HiveField(2)
  final DateTime time;

  OrderEntity(
      {required this.productList,
       required this.totalPrice,
       required this.time});

  Map<String, dynamic> toMap() {
    return {
      'productList': productList.map((product) => product.toDocument()).toList(),
      'totalPrice': totalPrice,
      'time': time,
    };
  }

  factory OrderEntity.fromMap(Map<String, dynamic> map) {
    return OrderEntity(
      productList: (map['productList'] as List).map((item) => ProductEntity.fromJson(item)).toList(),
      totalPrice: map['totalPrice'] as String,
      time: (map['time'] as Timestamp).toDate(),
    );
  }
}