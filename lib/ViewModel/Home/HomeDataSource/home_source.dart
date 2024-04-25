import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_ecommerce/Model/Tools/JsonParse/product_parse.dart';

abstract class HomeDataSource {
  Future<List<ProductEntity>> getProducts();
  Future<List<ProductEntity>> getProductsWithKeyWord(
      {required String keyWord});
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
  Future<List<ProductEntity>> getProductsWithKeyWord({required String keyWord}) async {
    final QuerySnapshot querySnapshot = await firestore.collection('products').where('name', isEqualTo: keyWord).get();
    return querySnapshot.docs.map((doc) => ProductEntity.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }
}
