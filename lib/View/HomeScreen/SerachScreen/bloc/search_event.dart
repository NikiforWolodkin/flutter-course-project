part of 'search_bloc.dart';

@immutable
abstract class SearchEvent {}

class InitialSearchScreen extends SearchEvent {}

class SearchStart extends SearchEvent {
  final String? searchKeyWord;
  final double? minPrice;
  final double? maxPrice;
  final String? category;

  SearchStart({required this.searchKeyWord, required this.minPrice, required this.maxPrice, required this.category});
}
