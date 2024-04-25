import 'package:flutter_application_ecommerce/ViewModel/Home/HomeDataSource/home_source.dart';
import 'package:flutter_application_ecommerce/ViewModel/Home/HomeRepository/home_repo.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final HomeRepository homeRepositoryInstance = HomeRepository(
      dataSource: HomeRemoteDataSource());
  HomeRepository get homeRepository => homeRepositoryInstance;
}
