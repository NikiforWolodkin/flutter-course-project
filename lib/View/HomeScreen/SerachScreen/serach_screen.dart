import 'package:flutter/material.dart';
import 'package:flutter_application_ecommerce/Model/GetX/Controller/duplicate_controller.dart';
import 'package:flutter_application_ecommerce/Model/GetX/Controller/home_controller.dart';
import 'package:flutter_application_ecommerce/Model/Tools/Color/color.dart';
import 'package:flutter_application_ecommerce/Model/Tools/Constant/const.dart';
import 'package:flutter_application_ecommerce/Model/Tools/Font/font.dart';
import 'package:flutter_application_ecommerce/Model/Widget/widget.dart';
import 'package:flutter_application_ecommerce/View/HomeScreen/SerachScreen/bloc/search_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  SearchBloc? searchBloc;
  final homeController = Get.find<HomeController>();
  final duplicateController = Get.find<DuplicateController>();
  late CustomColors colors = duplicateController.colors;
  late CustomTextStyle textStyle = duplicateController.textStyle;
  String? selectedCategory;
  @override
  void dispose() {
    searchBloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) {
          final bloc =
              SearchBloc(homeRepository: homeController.homeRepository);
          searchBloc = bloc;
          bloc.add(InitialSearchScreen());
          return bloc;
        },
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (state is SearchingScreen) {
              final TextEditingController searchController =
                  TextEditingController();
              final TextEditingController minPriceController =
                  TextEditingController();
              final TextEditingController maxPriceController =
                  TextEditingController();
              final GlobalKey<FormState> formKey = GlobalKey();
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: colors.whiteColor,
                  foregroundColor: colors.blackColor,
                  title: Text('Search', style: textStyle.bodyNormal,)
                ),
                body: Form(
                  key: formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(8.0),
                    children: [
                      TextFormField(
                        style: textStyle.bodyNormal,
                        validator: (value) {
                          if (value!.isNotEmpty) {
                            return null;
                          } else {
                            snackBar(
                                title: "Name",
                                message: "please type something...",
                                textStyle: textStyle,
                                colors: colors);
                            return "";
                          }
                        },
                        controller: searchController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintText: "Name...",
                          hintStyle: textStyle.bodyNormal,
                        ),
                      ),
                      TextFormField(
                        style: textStyle.bodyNormal,
                        validator: (value) {
                          if (value!.isNotEmpty) {
                            return null;
                          } else {
                            snackBar(
                                title: "Price",
                                message: "please enter minimum price ...",
                                textStyle: textStyle,
                                colors: colors);
                            return "";
                          }
                        },
                        controller: minPriceController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintText: "Min Price...",
                          hintStyle: textStyle.bodyNormal,
                        ),
                      ),
                      TextFormField(
                        style: textStyle.bodyNormal,
                        validator: (value) {
                          if (value!.isNotEmpty) {
                            return null;
                          } else {
                            snackBar(
                                title: "Price",
                                message: "please enter maximum price ...",
                                textStyle: textStyle,
                                colors: colors);
                            return "";
                          }
                        },
                        controller: maxPriceController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintText: "Max Price...",
                          hintStyle: textStyle.bodyNormal,
                        ),
                      ),
                      DropdownButtonFormField<String?>(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                          hintText: selectedCategory ?? "Select a category...",
                          hintStyle: textStyle.bodyNormal,
                        ),
                        items: <String>['Category 1', 'Category 2', 'Category 3']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: textStyle.bodyNormal),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue!;
                          });
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.search, color: Colors.white),
                        label: Text('Search', style: textStyle.bodyNormal.copyWith(color: colors.whiteColor)),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(CustomColors().primary),
                        ),
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            searchBloc!.add(SearchStart(
                                searchKeyWord: searchController.text,
                                minPrice: minPriceController.text,
                                maxPrice: maxPriceController.text,
                                selectedCategory: selectedCategory));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is SearchSuccess) {
              return Scaffold(
                backgroundColor: colors.blackColor,
                appBar: AppBar(
                  foregroundColor: colors.whiteColor,
                  backgroundColor: colors.blackColor,
                  title: Text(
                    "Search Result",
                    style:
                        textStyle.titleLarge.copyWith(color: colors.whiteColor),
                  ),
                ),
                body: gridViewScreensContainer(
                    colors: colors,
                    child: ProductGrideView(
                        productList: state.productList,
                        uiDuplicate: duplicateController.uiDuplicate,
                        colors: colors,
                        textStyle: textStyle)),
              );
            } else if (state is SearchEmptyScreen) {
              return EmptyScreen(
                  colors: colors,
                  textStyle: textStyle,
                  title: "Search Result",
                  content: "Nothing found",
                  lottieName: emtySearchLottie);
            } else if (state is SearchLoading) {
              return const CustomLoading();
            } else if (state is SearchError) {
              return AppException(
                callback: () {
                  searchBloc!.add(InitialSearchScreen());
                },
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
