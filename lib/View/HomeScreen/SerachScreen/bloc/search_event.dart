part of 'search_bloc.dart';

@immutable
abstract class SearchEvent {}

class InitialSearchScreen extends SearchEvent {}

class SearchStart extends SearchEvent {
  final String? searchKeyWord;
  final String? minPrice;
  final String? maxPrice;
  final String? selectedCategory;

  SearchStart({required this.searchKeyWord, required this.minPrice, required this.maxPrice, required this.selectedCategory});
}
