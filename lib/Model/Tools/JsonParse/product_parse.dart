import 'package:hive/hive.dart';

part 'product_parse.g.dart';

@HiveType(typeId: 0)
class ProductEntity {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final double price;
  @HiveField(3)
  final String imageUrl;
  @HiveField(4)
  final String productType;
  @HiveField(5)
  final String description;

  ProductEntity(this.id, this.name, this.price, this.imageUrl, this.productType,
      this.description);

  ProductEntity.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int? ?? 0,
      name = json['name'] as String? ?? "",
      price = double.tryParse(json['price'].toString()) ?? 0,
      imageUrl = json['image_link'] as String? ?? "",
      productType = json['product_type'] as String? ?? "",
      description = json['description'] as String? ?? "";
}
