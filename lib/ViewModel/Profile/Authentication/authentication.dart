import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_ecommerce/Model/GetX/Controller/profile_controller.dart';
import 'package:flutter_application_ecommerce/Model/Tools/Entities/entities.dart';
import 'package:get/get.dart';

class AuthenticationFunctions {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> saveInformation({required UserInformation information}) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: information.userName,
        password: (information.password)!,
      );

      // Get the uid of the newly created user
      String uid = userCredential.user!.uid;

      // Create a new document for the user with the uid
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'fullName': information.name,
        'email': information.userName,
        'role': 'user',
      });

      return true;
    } on FirebaseAuthException catch (e) {
      print(e.message);

      return false;
    }
  }

  Future<UserInformation?> getUserInformation() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        return UserInformation(
          password: null,
          userName: data['email'],
          name: data['fullName'],
        );
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<bool> signOut() async {
    final profileController = Get.find<ProfileController>();
    await _auth.signOut();
    profileController.informationInstance.value =
        UserInformation(name: "", userName: "", password: "");
    profileController.rememberMeStatusInstance.value = false;
    profileController.isLoginInstanse.value = false;
    return true;
  }

  Future<bool> signUser({required UserInformation information}) async {
    final profileController = Get.find<ProfileController>();
    if (!await saveInformation(information: information)) {
      return false;
    }
    profileController.informationInstance.value = information;
    profileController.isLoginInstanse.value = true;
    return true;
  }

  Future<bool> loginUser({required UserInformation i}) async {
    try {
      // Sign in the user with Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: i.userName,
        password: i.password!,
      );

      // If the sign in was successful, update the profile controller
      final profileController = Get.find<ProfileController>();
      profileController.informationInstance.value = (await getUserInformation())!;
      profileController.isLoginInstanse.value = true;

      return true;
    } on FirebaseAuthException catch (e) {
      // If there was an error signing in the user, print the error message
      print(e.message);
      return false;
    }
  }

  bool isUserLogin() {
    final profileController = Get.find<ProfileController>();
    profileController.information.userName.isNotEmpty;
    if (profileController.information.password != null) {
      profileController.information.password!.isNotEmpty;
    }
    final User? user = _auth.currentUser;
    if (user != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateUserInformation({required UserInformation i}) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.verifyBeforeUpdateEmail(i.userName);
      await user.updatePassword(i.password!);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> isAdmin() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (docSnapshot.exists) {
        Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
        if (data['role'] == 'admin') {
          return true;
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


  Future<bool> saveRemember({required bool remember}) async {
    // This function can be implemented based on your app's specific requirements
    return true;
  }
}
