import 'package:cloud_firestore/cloud_firestore.dart';

class ParkModel {
  String id;
  String email;
  String whereIs;
  Timestamp createdAt;

  ParkModel ({
    this.id, this.email, this.whereIs, this.createdAt
  });

  factory ParkModel.fromDocument(DocumentSnapshot doc, Map docData) {
    return ParkModel(
      id: doc.id,
      email: docData['email'],
      whereIs: docData['text'],
      createdAt: docData['createdAt']
    );
  }
}