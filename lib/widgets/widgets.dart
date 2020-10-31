import 'package:last_park_app/shared/globals.dart';
import 'package:flutter/material.dart';

// 자주 사용하는 위젯들 따로 빼놓자
Widget appBar(BuildContext context) {
  return RichText(
      text: TextSpan(style: TextStyle(fontSize: 30), children: <TextSpan>[
    TextSpan(
      text: 'Last ',
      style: TextStyle(
          fontSize: 30, fontWeight: FontWeight.w400, color: Global.sBlue),
    ),
    TextSpan(
        text: 'Park',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: Global.sBlue,
        )
    )
  ]));
}

Widget blueButton({BuildContext context, String text, buttonWidth}) {
  return Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Global.sBlue,
      boxShadow: [
        BoxShadow(offset: Offset(1, 2), color: Global.sBlack.withOpacity(0.5), blurRadius: 2)
      ],
      borderRadius: BorderRadius.circular(20),
    ),
    height: MediaQuery.of(context).size.height * 0.06,
    width: buttonWidth != null // width가 파라미터로 넘어오면
        ? buttonWidth // 넘어온 길이로 하고
        : MediaQuery.of(context).size.width * 0.88, // 파라미터값 없으면 이걸로
    child: Text(
      text,
      style: TextStyle(color: Colors.white, fontSize: 20),
    ),
  );
}

Widget redButton({BuildContext context, String text, buttonWidth}) {
  return Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Global.sRed,
      boxShadow: [
        BoxShadow(offset: Offset(1, 2), color: Global.sBlack.withOpacity(0.5), blurRadius: 2)
      ],
      borderRadius: BorderRadius.circular(20),
    ),
    height: MediaQuery.of(context).size.height * 0.06,
    width: buttonWidth != null // width가 파라미터로 넘어오면
        ? buttonWidth // 넘어온 길이로 하고
        : MediaQuery.of(context).size.width * 0.88, // 파라미터값 없으면 이걸로
    child: Text(
      text,
      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
  );
}

Widget greyButton({BuildContext context, String text, buttonWidth}) {
  return Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Colors.grey,
      boxShadow: [
        BoxShadow(offset: Offset(1, 2), color: Global.sBlack.withOpacity(0.25), blurRadius: 2)
      ],
      borderRadius: BorderRadius.circular(20),
    ),
    height: MediaQuery.of(context).size.height * 0.06,
    width: buttonWidth != null // width가 파라미터로 넘어오면
        ? buttonWidth // 넘어온 길이로 하고
        : MediaQuery.of(context).size.width * 0.88, // 파라미터값 없으면 이걸로
    child: Text(
      text,
      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
  );
}

Widget kakaoLoginButton({BuildContext context, String text, buttonWidth}) {
  return Container(
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Global.sYellow,
      boxShadow: [
        BoxShadow(offset: Offset(1, 2), color: Global.sBlack.withOpacity(0.25), blurRadius: 2)
      ],
      borderRadius: BorderRadius.circular(20),
    ),
    height: MediaQuery.of(context).size.height * 0.06,
    width: buttonWidth != null // width가 파라미터로 넘어오면
        ? buttonWidth // 넘어온 길이로 하고
        : MediaQuery.of(context).size.width * 0.88, // 파라미터값 없으면 이걸로
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.chat_bubble, color: Global.sBlack.withOpacity(0.6),),
        SizedBox(width: 10,),
        Text(
          text,
          style: TextStyle(color: Global.sBlack.withOpacity(0.6), fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ],
    )
  );
}