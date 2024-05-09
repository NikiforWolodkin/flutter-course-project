import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_ecommerce/Model/Tools/Entities/OrderEntity/order_entity.dart';
import 'package:hive/hive.dart';

class OrderFunctions {
  final String orderBoxName = "Order Box";
  Future<void> openOrderBox() async {
    bool isOpen = Hive.isBoxOpen(orderBoxName);
    if (!isOpen) {
      await Hive.openBox<OrderEntity>(orderBoxName);
    }
  }

  Future<bool> addToOrderBox({required OrderEntity orderEntity}) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await openOrderBox();
      final box = Hive.box<OrderEntity>(orderBoxName);
      await box.add(orderEntity);
      await box.close();

      CollectionReference userOrders = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('orders');
      await userOrders.add(orderEntity.toMap());
    }

    return true;
  }

  Future<void> clearOrders() async {
    Box<OrderEntity> box;
    if (Hive.isBoxOpen(orderBoxName)) {
      box = Hive.box<OrderEntity>(orderBoxName);
    } else {
      box = await Hive.openBox<OrderEntity>(orderBoxName);
    }
    await box.clear();
  }

  Future<void> refreshOrders() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Box<OrderEntity> box;
      if (Hive.isBoxOpen(orderBoxName)) {
        box = Hive.box<OrderEntity>(orderBoxName);
      } else {
        box = await Hive.openBox<OrderEntity>(orderBoxName);
      }
      await box.clear();

      CollectionReference userOrders = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('orders');
      QuerySnapshot snapshot = await userOrders.get();
      for (var doc in snapshot.docs) {
        OrderEntity orderEntity = OrderEntity.fromMap(doc.data() as Map<String, dynamic>);
        await box.add(orderEntity);
      }
    } else {
      print("No user is logged in.");
    }
  }

  Future<List<OrderEntity>> getOrderList() async {
    await openOrderBox();
    final box = Hive.box<OrderEntity>(orderBoxName);
    final List<OrderEntity> orderList = box.values.toList();
    await box.close();
    return orderList;
  }
}
