import 'package:flutter_application_ecommerce/Model/Tools/JsonParse/product_parse.dart';
import 'package:flutter_application_ecommerce/ViewModel/Home/HomeDataSource/home_source.dart';

class HomeRepository implements HomeDataSource {
  final HomeDataSource dataSource;

  HomeRepository({required this.dataSource});
  @override
  Future<List<ProductEntity>> getProducts() => dataSource.getProducts();

  @override
  Future<List<ProductEntity>> searchProducts(
          {String? keyWord, double? minPrice, double? maxPrice, String? category}) =>
      dataSource.searchProducts(keyWord: keyWord, minPrice: minPrice, maxPrice: maxPrice, category: category);
}
