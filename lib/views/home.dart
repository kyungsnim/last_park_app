import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

// import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:last_park_app/models/park_model.dart';
import 'package:last_park_app/services/firebase_provider.dart';
import 'package:last_park_app/services/database.dart';
import 'package:last_park_app/shared/globals.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _whereIs = TextEditingController();
  String whereIs;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseProvider fp;
  DatabaseService databaseService = new DatabaseService();
  String result = "";
  File image;
  Future<File> imageFile;
  ImagePicker imagePicker;
  var index;
  var admobBannerId;

  @override
  void initState() {
    admobBannerId = Platform.isIOS ? 'ca-app-pub-6109556651195087/8636552625' : 'ca-app-pub-6109556651195087/7354414059';
    imagePicker = ImagePicker();
    super.initState();
    index = 0;
  }

  @override
  void dispose() {
    _whereIs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    // logger.d(fp.getUser());
    // logger.d(fp.getUser().emailVerified);

    return Scaffold(
        key: _scaffoldKey,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Container(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05),
                        RichText(
                          text: TextSpan(
                              text: 'Where is my \n',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 50,
                                  color: Global.sBlue),
                              children: [
                                TextSpan(
                                  text: 'Last Park?',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 60,
                                      color: Colors.redAccent),
                                )
                              ]),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Container(height: 120, child: inputData()),
                        SizedBox(height: 10),
                        Center(
                          child: Container(
                            child: AdmobBanner(
                              adUnitId: admobBannerId,//'ca-app-pub-6109556651195087~8378172956', //
                              adSize: AdmobBannerSize.BANNER,
                              onBannerCreated:
                                  (AdmobBannerController controller) {
                              },
                            ),
                          ),
                        ),
                        StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(fp.getUser().email)
                                .collection(fp.getUser().email)
                                .orderBy('createdAt', descending: true)
                                .snapshots(), // 1
                            builder: (context, snapshot) {
                              // 2
                              if (!snapshot.hasData) {
                                // 3
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final docs = snapshot.data.docs; // 4
                              return Expanded(
                                child: ListView(
                                  children: docs
                                      .map((doc) => _buildItemWidget(doc))
                                      .toList(), // 5
                                ),
                              );
                            }),
                        Center(
                          child: Container(
                            child: AdmobBanner(
                              adUnitId: admobBannerId,//'ca-app-pub-6109556651195087~8378172956', //
                              adSize: AdmobBannerSize.BANNER,
                              onBannerCreated:
                                  (AdmobBannerController controller) {
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  color: Colors.white),
        ));
  }

  void showSnackBar(String content) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(content),
        duration: Duration(milliseconds: 1500),
      ),
    );
  }

  void handleEvent(
      AdmobAdEvent event, Map<String, dynamic> args, String adType) {
    switch (event) {
      case AdmobAdEvent.loaded:
        showSnackBar('New Admob $adType Ad loaded!');
        break;
      case AdmobAdEvent.opened:
        showSnackBar('Admob $adType Ad opened!');
        break;
      case AdmobAdEvent.closed:
        showSnackBar('Admob $adType Ad closed!');
        break;
      case AdmobAdEvent.failedToLoad:
        showSnackBar('Admob $adType failed to load. :(');
        break;
      default:
    }
  }

  Widget inputData() {
    return Column(
      children: [
        Expanded(
          child: Container(
            height: 50,
            child: TextField(
              controller: _whereIs,
              cursorColor: Global.sBlue,
              cursorWidth: 5,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), // 테두리
                  labelText: '주차 장소 어디 ?',
                  hintText: 'B4 F2 (지하4층 F2구역)'),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width * 0.4,
              child: RaisedButton(
                color: Global.sBlue,
                onPressed: () {
                  addParkData(fp.getUser().email, _whereIs.text);
                },
                child: Icon(
                  Icons.create,
                  color: Global.sWhite,
                ),
              ),
            ),
            Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: RaisedButton(
                        color: Global.sBlue,
                        onPressed: () {
                          captureImageWithCamera();
                          // takePhoto(ImageSource.camera);
//              showModalBottomSheet(context: context, builder: ((builder) => bottomSheet()));
                        },
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        )),
            )
          ],
        )
      ],
    );
  }

  captureImageWithCamera() async {
    PickedFile pickedFile =
        await imagePicker.getImage(source: ImageSource.camera);

    Future.delayed(const Duration(milliseconds: 8000), () async {
      image = File(pickedFile.path);
      print('image : $image}');
      setState(() {
        image;

        // 사진에서 실제 텍스트 추출하는 작업
        performImageLabeling();
      });
    });
  }

  performImageLabeling() async {
    final FirebaseVisionImage firebaseVisionImage =
        FirebaseVisionImage.fromFile(image);

    final TextRecognizer recognizer = FirebaseVision.instance.textRecognizer();

    VisionText visionText = await recognizer.processImage(firebaseVisionImage);

    _whereIs.text = "";

    setState(() {
      for (TextBlock block in visionText.blocks) {
        final String text = block.text;

        for (TextLine line in block.lines) {
          for (TextElement element in line.elements) {
            _whereIs.text += '${element.text} ';
          }
        }

        result += ' / ';
      }
    });

    recognizer.close();
  }

  Widget _buildItemWidget(DocumentSnapshot doc) {
    // DocumentSnapshot 추가
    // title은 생성시 필수값, isDone은 옵셔널
    final park = ParkModel(
      id: doc.id,
      email: doc.data()['email'],
      whereIs: doc.data()['whereIs'],
      createdAt: doc.data()['createdAt'],
    );
    index++;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Text(
                      '층 및 구역',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Global.sBlue),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      park.whereIs,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                      '주차시간',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Global.sBlue),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      park.createdAt.toDate().toString().substring(0, 19),
                      style: TextStyle(fontSize: 12),
                    ),
                    // Spacer(),
                  ],
                )
              ],
            ),
            Spacer(),
            InkWell(
                onTap: () =>
                    databaseService.deleteParkData(park.email, park.id),
                child: Icon(
                  Icons.delete_forever,
                  color: Global.sGrey,
                )),
          ],
        ),
      ),
    );
  }

  addParkData(email, text) async {
    setState(() {
      _isLoading = true;
    });
    await databaseService.addParkData(email, text).then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }
}
