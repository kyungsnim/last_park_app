import 'package:flutter/material.dart';
import 'package:last_park_app/shared/globals.dart';
import 'package:provider/provider.dart';
import 'package:last_park_app/services/firebase_provider.dart';
import 'package:last_park_app/views/signin.dart';
import 'package:last_park_app/widgets/widgets.dart';

SignUpState pageState;

class SignUp extends StatefulWidget {
  @override
  SignUpState createState() {
    pageState = SignUpState();
    return pageState;
  }
}

class SignUpState extends State<SignUp> {
  TextEditingController _emailCon = TextEditingController();
  TextEditingController _pwCon = TextEditingController();

  String email, password;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseProvider fp;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCon.dispose();
    _pwCon.dispose();
    super.dispose();
  }

  signUp() async {
    if (_formKey.currentState.validate()) {
      _scaffoldKey.currentState
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          duration: Duration(seconds: 10),
          content: Row(
            children: <Widget>[
              CircularProgressIndicator(),
              Text("   회원가입 중...")
            ],
          ),
        ));
      bool result = await fp.signUpWithEmail(_emailCon.text, _pwCon.text);
      _scaffoldKey.currentState.hideCurrentSnackBar();
      if (result) {
        Navigator.pop(context);
      } else {
        showLastFBMessage();
      }
    }
  }

  showLastFBMessage() {
    _scaffoldKey.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        backgroundColor: Colors.red[400],
        duration: Duration(seconds: 10),
        content: Text(fp.getLastFBMessage()),
        action: SnackBarAction(
          label: "확인",
          textColor: Colors.white,
          onPressed: () {},
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    if (fp == null) {
      fp = Provider.of<FirebaseProvider>(context);
    }

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
                  backgroundColor: Global.sRed,
                ),
              )
            : Form(
                key: _formKey,
                child: Container(
                    child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(25, 5, 25, 5),
                        child: TextFormField(
                          controller: _emailCon,
                          cursorColor: Global.sRed,
                          validator: (val) {
                            if (val.isEmpty) {
                              return '이메일주소를 입력하세요';
                            } else return null;
                          },
                          decoration: InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                  // underline 색상 변경
                                  borderSide: BorderSide(color: Global.sRed)),
                              icon: Icon(Icons.email, color: Global.sRed),
                              hintText: '이메일'),
                          onChanged: (val) {
                            email = val;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(25, 5, 25, 25),
                        child: TextFormField(
                          controller: _pwCon,
                          obscureText: true, // 비밀번호 가리기
                          cursorColor: Global.sRed,
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
                                  borderSide: BorderSide(color: Global.sRed)),
                              focusColor: Global.sRed,
                              icon: Icon(
                                Icons.vpn_key,
                                color: Global.sRed,
                              ),
                              hintText: '비밀번호'),
                          onChanged: (val) {
                            password = val;
                          },
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          FocusScope.of(context)
                              .requestFocus(new FocusNode()); // 키보드 감추기
                          signUp();
                        },
                        child: blueButton(context: context, text: '회원 가입'),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '계정이 있으신가요? ',
                            style: TextStyle(fontSize: 18),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SignIn()));
                            },
                            child: Text(
                              '로그인',
                              style: TextStyle(
                                  fontSize: 18,
                                  decoration: TextDecoration.underline),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )),
              ));
  }
}
