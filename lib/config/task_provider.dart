import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/config/task.dart';

class TaskProvider extends ChangeNotifier {
  Stream<List<Task>> getUserTasks() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value([]);

    return FirebaseFirestore.instance
        .collection("tasks")
        .doc(user.uid)
        .collection("userTasks")
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Task.fromMap(doc.data())).toList());
  }
}
