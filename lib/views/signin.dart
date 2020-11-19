import 'package:flutter/material.dart';
import 'package:last_park_app/shared/globals.dart';
import 'package:provider/provider.dart';
import 'package:last_park_app/services/firebase_provider.dart';
import 'package:last_park_app/views/signup.dart';
import 'package:last_park_app/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

SignInState pageState;

class SignIn extends StatefulWidget {
  @override
  SignInState createState() {
    pageState = SignInState();
    return pageState;
  }
}

class SignInState extends State<SignIn> {
  TextEditingController _emailCon = TextEditingController();
  TextEditingController _pwCon = TextEditingController();
  String email, password;
  bool _isLoading = false;
  bool doRemember = false;

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseProvider fp;

  @override
  void initState() {
    super.initState();
    getRememberInfo();
  }

  @override
  void dispose() {
    setRememberInfo();
    _emailCon.dispose();
    _pwCon.dispose();
    super.dispose();
  }

  void signIn() async {
    if (_formKey.currentState.validate()) {
      _scaffoldKey.currentState
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
            duration: Duration(seconds: 10),
            content: Row(
              children: <Widget>[
                CircularProgressIndicator(),
                Text('   Login...')
              ],
            )));
      bool result = await fp.signInWithEmail(_emailCon.text, _pwCon.text);
      _scaffoldKey.currentState.hideCurrentSnackBar();
      if (result == false) showLastFBMessage();
    }
  }

  getRememberInfo() async {
    logger.d(doRemember);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      doRemember = (prefs.getBool('doRemember') ?? false);
    });
    if (doRemember) {
      setState(() {
        _emailCon.text = (prefs.getString('userEmail') ?? "");
        _pwCon.text = (prefs.getString('userPassword') ?? "");
      });
    }
  }

  setRememberInfo() async {
    logger.d(doRemember);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('doRemember', doRemember);
    if (doRemember) {
      prefs.setString('userEmail', _emailCon.text);
      prefs.setString('userPassword', _pwCon.text);
    }
  }

  showLastFBMessage() {
    _scaffoldKey.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        backgroundColor: Global.sBlue,
        duration: Duration(seconds: 10),
        content: Text(fp.getLastFBMessage()),
        action: SnackBarAction(
            label: '확인', textColor: Colors.white, onPressed: () {}),
      ));
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);

    logger.d(fp.getUser());
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: appBar(context),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        brightness: Brightness.light,
        leading: Container(),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Global.sBlue,
              ),
            )
          : Form(
              key: _formKey,
              // isLoading에 따라 화면 보여주냐 마느냐 결정
              child: Container(
                  child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 25, 25, 5),
                      child: TextFormField(
                        controller: _emailCon,
                        cursorColor: Global.sBlue,
                        validator: (val) {
                          if (val.isEmpty) {
                            return '이메일주소를 입력하세요';
                          } else return null;
                        },
                        decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                                // underline 색상 변경
                                borderSide: BorderSide(color: Global.sBlue)),
                            icon: Icon(Icons.email, color: Global.sBlue),
                            hintText: '이메일'),
                        onChanged: (val) {
                          email = val;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 5, 25, 5),
                      child: TextFormField(
                        controller: _pwCon,
                        obscureText: true, // 비밀번호 가리기
                        cursorColor: Global.sBlue,
                        validator: (val) {
                          if (val.length < 6) {
                            return '6자 이상의 비밀번호를 사용하세요.';
                          } else {
                            return val.isEmpty ? '비밀번호를 입력하세요' : null;
                          }
                        },
                        decoration: InputDecoration(
                            focusedBorder: UnderlineInputBorder(
                                // underline 색상 변경
                                borderSide: BorderSide(color: Global.sBlue)),
                            focusColor: Global.sBlue,
                            icon: Icon(
                              Icons.vpn_key,
                              color: Global.sBlue,
                            ),
                            hintText: '비밀번호'),
                        onChanged: (val) {
                          password = val;
                        },
                      ),
                    ),
                    // Remember me
                    Container(
                        margin: const EdgeInsets.fromLTRB(25, 5, 25, 25),
                        child: Row(
                          children: <Widget>[
                            Checkbox(
                              activeColor: Global.sBlue,
                              value: doRemember,
                              onChanged: (newValue) {
                                setState(() {
                                  doRemember = newValue;
                                });
                              },
                            ),
                            Text('이메일 기억하기')
                          ],
                        )),
                    // Alert Box
                    (fp.getUser() != null &&
                            fp.getUser().emailVerified == false)
                        ? Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 10),
                            decoration: BoxDecoration(color: Colors.white),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(
                                    '이메일 인증이 되지 않았습니다.\n인증을 완료해주세요.',
                                    style: TextStyle(color: Global.sBlue),
                                  ),
                                ),
                                RaisedButton(
                                  color: Global.sBlue,
                                  textColor: Colors.white,
                                  child: Text('인증메일 다시 보내기'),
                                  onPressed: () {
                                    FocusScope.of(context).requestFocus(
                                        new FocusNode()); // 키보드 감추기
                                    fp.getUser().sendEmailVerification();
                                  },
                                )
                              ],
                            ),
                          )
                        : Container(),
                    InkWell(
                      onTap: () {
                        FocusScope.of(context)
                            .requestFocus(new FocusNode()); // 키보드 감추기
                        signIn();
                      },
                      child: blueButton(context: context, text: '로그인'),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '아이디가 없으세요? ',
                          style: TextStyle(fontSize: 18),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUp()));
                          },
                          child: Text(
                            '회원가입',
                            style: TextStyle(
                                fontSize: 20,
                                decoration: TextDecoration.underline),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              )),
            ),
    );
  }
}
