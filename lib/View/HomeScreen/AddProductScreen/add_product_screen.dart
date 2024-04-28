import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_ecommerce/Model/Tools/JsonParse/product_parse.dart';
import 'package:flutter_application_ecommerce/View/HomeScreen/bloc/home_bloc.dart';
import 'package:flutter_application_ecommerce/View/HomeScreen/home_screen.dart';
import 'package:image_picker/image_picker.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  String id = '';
  String name = '';
  String description = '';
  String price = '';
  String category = '';

  Future<void> uploadImage() async {
    // Select an image from the gallery
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _image = image;
    });
  }

  Future<void> addProduct() async {
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

      // Add the product to your database
      // You'll need to implement this according to your database
      CollectionReference products = FirebaseFirestore.instance.collection('products');
      products.add(product.toDocument());

      homeBloc?.add(HomeStart());
    } else {
      print('No Image Selected');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: 'ID'),
                onChanged: (value) {
                  setState(() {
                    id = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price'),
                onChanged: (value) {
                  setState(() {
                    price = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Category'),
                onChanged: (value) {
                  setState(() {
                    category = value;
                  });
                },
              ),
              ElevatedButton(
                onPressed: uploadImage,
                child: Text('Upload Image'),
              ),
              ElevatedButton(
                onPressed: addProduct,
                child: Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
