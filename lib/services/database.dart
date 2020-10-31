import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // db 구조 : Quiz > Quiz범주(title) > 각QuizData
  Future<void> addQuizData(Map quizMap, String quizId) async {
    // random id 부여,
    await FirebaseFirestore.instance
        .collection("Quiz")
        .document(quizId)
        .setData(quizMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  // 제출결과 정답여부 db에 반영
  Future<void> addResultData(
      Map resultMap, String quizId, String questionId) async {
    // random id 부여,
    await FirebaseFirestore.instance
        .collection("Quiz")
        .document(quizId)
        .collection("QnA")
        .document(questionId)
        .updateData(resultMap)
        .catchError((e) {
      print(e.toString());
    });
  }

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
