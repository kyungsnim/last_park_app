import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  Future<void> addParkData(email, text) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection(email)
        .add({
      'email': email,
      'whereIs' : text,
      'createdAt': DateTime.now()
    });
  }

  Future<void> deleteParkData(email, id) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .collection(email)
        .doc(id)
        .delete();
  }
}
