import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_ecommerce/Model/Tools/JsonParse/product_parse.dart';

abstract class HomeDataSource {
  Future<List<ProductEntity>> getProducts();
  Future<List<ProductEntity>> searchProducts(
      {String? keyWord, double? minPrice, double? maxPrice, String? category});
}

class HomeRemoteDataSource implements HomeDataSource {
  final FirebaseFirestore firestore;

  HomeRemoteDataSource() : firestore = FirebaseFirestore.instance;

  @override
  Future<List<ProductEntity>> getProducts() async {
    final QuerySnapshot querySnapshot = await firestore.collection('products').get();
    return querySnapshot.docs.map((doc) => ProductEntity.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ProductEntity>> searchProducts({String? keyWord, double? minPrice, double? maxPrice, String? category}) async {
    Query query = firestore.collection('products');

    if (keyWord != null) {
      query = query.where('name', isEqualTo: keyWord);
    }
    if (category != null) {
      query = query.where('product_type', isEqualTo: category);
    }
    if (minPrice != null) {
      query = query.where('price', isGreaterThanOrEqualTo: minPrice);
    }
    if (maxPrice != null) {
      query = query.where('price', isLessThanOrEqualTo: maxPrice);
    }

    final QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs.map((doc) => ProductEntity.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }
}
