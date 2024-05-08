import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_application_ecommerce/Model/GetX/Controller/profile_controller.dart';
import 'package:flutter_application_ecommerce/Model/Tools/JsonParse/product_parse.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class ProfileFunctions {
  final String imageStorge = "ImageSotrge";
  final GetStorage storage = GetStorage();
  final String favoriteBox = "Favorite Box";

  Future<bool> saveImageInStorage({required String path}) async {
    await storage.write(imageStorge, path);
    return true;
  }

  bool deleteImageFromStorage()  {
    final ProfileController profileController = Get.find<ProfileController>();
    final String? imagePath = storage.read(imageStorge);
    if (imagePath != null) {
      final File imageFile = File(imagePath);
      if (imageFile.existsSync()) {
        imageFile.deleteSync();
        profileController.userSetImageInstance.value = false;
        return true;
      }
    }
    return false;
  }

  Future<bool> getUserImage() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final ProfileController profileController = Get.find<ProfileController>();
    if (user != null) {
      final ImagePicker picker = ImagePicker();
      final XFile? xFile = await picker.pickImage(source: ImageSource.gallery);
      if (xFile != null) {
        // Create a reference to the location you want to upload to in Firebase Storage
        Reference storageReference = FirebaseStorage.instance.ref().child('users/${user.uid}/${Path.basename(xFile.path)}');

        // Upload the file to Firebase Storage
        UploadTask uploadTask = storageReference.putFile(File(xFile.path));

        // Wait until the file is uploaded then store the download URL
        await uploadTask.whenComplete(() async {
          String downloadUrl = await storageReference.getDownloadURL();

          // Update the user's document in Firestore to have the URL to the image
          await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
            'imageUrl': downloadUrl,
          });

          deleteImageFromStorage();

          // Create a temporary directory
          final Directory tempDir = Directory.systemTemp;
          // Create a new file in the temporary directory
          final File tempFile = File('${tempDir.path}/${Path.basename(xFile.path)}');

          // Download the file from Firebase Storage
          await FirebaseStorage.instance.refFromURL(downloadUrl).writeToFile(tempFile);

          // Save the image in local storage
          bool isSaved = await saveImageInStorage(path: tempFile.path);
          profileController.userSetImageInstance.value = isSaved;
        }).catchError((onError) {
          print(onError);
          profileController.userSetImageInstance.value = false;
        });

        return profileController.userSetImageInstance.value;
      }
    }
    return false;
  }

  Future<bool> downloadUserImage() async {
    final ProfileController profileController = Get.find<ProfileController>();
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String? imagePath = await FirebaseFirestore.instance.collection('users').doc(user.uid).get().then((doc) => doc.data()?['imageUrl']);
      if (imagePath != null) {
        final Directory tempDir = Directory.systemTemp;
        final File file = File('${tempDir.path}/tempImage.jpg');

        final Reference ref = FirebaseStorage.instance.refFromURL(imagePath);
        final DownloadTask task = ref.writeToFile(file);

        if (await task.whenComplete(() {}) != null) {
          // Save the image in local storage
          bool isSaved = await saveImageInStorage(path: file.path);
          profileController.userSetImageInstance.value = isSaved;
          return isSaved;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  File? imageFile() {
    String? imagePath = storage.read(imageStorge);
    if (imagePath != null) {
      return File(imagePath);
    } else {
      return null;
    }
  }

  bool isUserSavedImage() {
    final File? file = imageFile();
    if (file != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> openFavoriteBox() async {
    await Hive.openBox<ProductEntity>(favoriteBox);
  }

  Future<bool> addToFavorite({required ProductEntity productEntity}) async {
    final box = Hive.box<ProductEntity>(favoriteBox);
    await box.put(productEntity.id, productEntity);
    return true;
  }

  Future<List<ProductEntity>> getFavoriteProducts() async {
    final box = Hive.box<ProductEntity>(favoriteBox);

    final List<ProductEntity> productList = [];
    for (var element in (box.values.toList())) {
      productList.add(element);
    }
    return productList;
  }

  bool isInFavoriteBox({required ProductEntity productEntity}) {
    final box = Hive.box<ProductEntity>(favoriteBox);
    for (var element in box.values) {
      if (productEntity.id == element.id) {
        return true;
      }
    }
    return false;
  }

  Future<bool> removeFavorite({required ProductEntity productEntity}) async {
    final box = Hive.box<ProductEntity>(favoriteBox);
    await box.delete(productEntity.id);
    return true;
  }

  ValueListenable favoriteListenable() {
    final box = Hive.box<ProductEntity>(favoriteBox);
    return box.listenable();
  }
}
