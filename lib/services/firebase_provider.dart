import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';

Logger logger = Logger();

class FirebaseProvider with ChangeNotifier {
  final FirebaseAuth fAuth = FirebaseAuth.instance; // Firebase 인증 인스턴스
  User _user; // Firebase 로그인된 사용자 정보

  String _lastFirebaseResponse = ""; // Firebase로부터 받은 메시지(에러용)

  FirebaseProvider() {
    logger.d("init FirebaseProvider");
    _prepareUser();
  }

  // Firebase에 로그인한 사용자 정보 얻기
  _prepareUser() {
    fAuth.currentUser;
  }

  User getUser() {
    return _user;
  }

  void setUser(User value) {
    _user = value;
    notifyListeners();
  }

  // 이메일/비밀번호로 Firebase 회원가입
  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      UserCredential result = await fAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (result.user != null) {
        // 인증메일 발송
        result.user.sendEmailVerification();
        // 새로운 계정생성이 성공했다면 기존계정 있을 경우 로그아웃 하기
        signOut();

        return true;
      }
    } catch (e) {
      logger.e(e.toString());
      List<String> result = e.toString().split(", ");
      setLastFBMessage(result[1]);
      return false;
    }
  }

  // 이메일/비밀번호로 Firebase 로그인
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      var result = await fAuth.signInWithEmailAndPassword(
          email: email, password: password);
      if (result != null) {
        setUser(result.user);
        logger.d(getUser());
        return true;
      }
      return false;
    } catch (e) {
      logger.e(e.toString());
      List<String> result = e.toString().split(", ");
      setLastFBMessage(result[1]);
      return false;
    }
  }

  // Firebase로부터 로그아웃
  signOut() async {
    await fAuth.signOut();
    setUser(null);
  }

  // 사용자에게 비밀번호 재설정 메일 영어로 전송 시도
  sendPasswordResetEmailByEnglish() async {
    await fAuth.setLanguageCode("en");
    sendPasswordResetEmail();
  }

  // 사용자에게 비밀번호 재설정 메일을 한글로 전송 시도
  sendPasswordResetEmail() async {
    fAuth.sendPasswordResetEmail(email: getUser().email);
  }

  // Firebase로부터 회원 탈퇴
  withdrawalAccount() async {
    await getUser().delete();
    setUser(null);
  }

  // Firebase로부터 수신한 메시지 설정
  setLastFBMessage(String msg) {
    _lastFirebaseResponse = msg;
  }

  // Firebase로부터 수신한 메시지 반환하고 삭제
  getLastFBMessage() {
    String returnValue = _lastFirebaseResponse;
    _lastFirebaseResponse = null;
    return returnValue;
  }
}
