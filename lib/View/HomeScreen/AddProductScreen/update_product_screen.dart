import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_ecommerce/Model/GetX/Controller/duplicate_controller.dart';
import 'package:flutter_application_ecommerce/Model/Tools/Color/color.dart';
import 'package:flutter_application_ecommerce/Model/Tools/Font/font.dart';
import 'package:flutter_application_ecommerce/Model/Tools/JsonParse/product_parse.dart';
import 'package:flutter_application_ecommerce/Model/Widget/widget.dart';
import 'package:flutter_application_ecommerce/View/HomeScreen/bloc/home_bloc.dart';
import 'package:flutter_application_ecommerce/View/HomeScreen/home_screen.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';

class UpdateProductPage extends StatefulWidget {
  final ProductEntity product;

  UpdateProductPage({required this.product});

  @override
  _UpdateProductPageState createState() => _UpdateProductPageState();
}

class _UpdateProductPageState extends State<UpdateProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final duplicateController = Get.find<DuplicateController>();
  late CustomTextStyle textStyle = duplicateController.textStyle;
  late CustomColors colors = duplicateController.colors;
  XFile? _image;
  String id = '';
  String name = '';
  String description = '';
  String price = '';
  String category = '';

  @override
  void initState() {
    super.initState();
    id = widget.product.id.toString();
    name = widget.product.name;
    description = widget.product.description;
    price = widget.product.price.toString();
    category = widget.product.productType;
  }

  Future<void> uploadImage() async {
    // Select an image from the gallery
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  Future<void> updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      snackBar(
        title: "Form Validation",
        message: "Form is invalid. Please check your inputs.",
        textStyle: textStyle,
        colors: colors
      );
      return;
    }

    if (_image != null) {
      // Create a reference to the location you want to upload to in firebase
      Reference ref = FirebaseStorage.instance
          .ref()
          .child('images/$id');

      // Upload the file to firebase
      UploadTask uploadTask = ref.putFile(File(_image?.path as String));

      // Waits till the file is uploaded then stores the download url 
      await uploadTask.whenComplete(() => null);

      // Retrieves the download url
      String url = await ref.getDownloadURL();

      // Create a new product with the download url
      ProductEntity product = ProductEntity(int.parse(id), name, double.parse(price), url, category, description);

      CollectionReference products = FirebaseFirestore.instance.collection('products');

      // Check if product with provided id already exists
      var docs = await products.where('id', isEqualTo: int.parse(id)).get();
      if (docs.size > 0) {
        // Update the existing product
        products.doc(docs.docs[0].id).update(product.toDocument());
        snackBar(
          title: "Product Update",
          message: "Product with provided ID has been updated.",
          textStyle: textStyle,
          colors: colors
        );
      } else {
        snackBar(
          title: "Product ID",
          message: "No product with provided ID exists.",
          textStyle: textStyle,
          colors: colors
        );
        return;
      }

      homeBloc?.add(HomeStart());

      Get.to(HomeScreen());
    } else {
      snackBar(
        title: "Image Selection",
        message: "No Image Selected. Please select an image.",
        textStyle: textStyle,
        colors: colors
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product', style: textStyle.bodyNormal),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: widget.product.id.toString(),
                style: textStyle.bodyNormal,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  hintText: "ID...",
                  hintStyle: textStyle.bodyNormal,
                ),
                onChanged: (value) {
                  setState(() {
                    id = value;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter an ID';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid integer';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: widget.product.name,
                style: textStyle.bodyNormal,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  hintText: "Name...",
                  hintStyle: textStyle.bodyNormal,
                ),
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: widget.product.description,
                style: textStyle.bodyNormal,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  hintText: "Description...",
                  hintStyle: textStyle.bodyNormal,
                ),
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: widget.product.price.toString(),
                style: textStyle.bodyNormal,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  hintText: "Price...",
                  hintStyle: textStyle.bodyNormal,
                ),
                onChanged: (value) {
                  setState(() {
                    price = value;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: widget.product.productType,
                style: textStyle.bodyNormal,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  hintText: "Category...",
                  hintStyle: textStyle.bodyNormal,
                ),
                onChanged: (value) {
                  setState(() {
                    category = value;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
                },
              ),
              Expanded(child: Container()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.image, color: Colors.white),
                    label: Text('Upload image', style: textStyle.bodyNormal.copyWith(color: CustomColors().whiteColor)),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(CustomColors().primary),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    onPressed: uploadImage,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.upload, color: Colors.white),
                    label: Text('Update product', style: textStyle.bodyNormal.copyWith(color: CustomColors().whiteColor)),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(CustomColors().primary),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                    onPressed: updateProduct,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
