import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:last_park_app/models/park_model.dart';
import 'package:last_park_app/services/firebase_provider.dart';
import 'package:last_park_app/services/database.dart';
import 'package:last_park_app/shared/globals.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

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
  PickedFile _imageFile; // 카메라/갤러리에서 사진 가져올 때 사용함 (image_picker)
  final ImagePicker _picker = ImagePicker(); // 카메라/갤러리에서 사진 가져올 때 사용함 (image_picker)


  @override
  void dispose() {
    _whereIs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    print('<<<<<<<<<<<<<<<<<<<');
    logger.d(fp.getUser());
    logger.d(fp.getUser().emailVerified);
    print('<<<<<<<<<<<<<<<<<<<');

    return Scaffold(
        key: _scaffoldKey,
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _isLoading ? Center(child: CircularProgressIndicator()) : Container(
              child: Container(
                height: MediaQuery.of(context).size.height * 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                    RichText(
                      text: TextSpan(
                          text: 'Where is my \n',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50, color: Global.sBlue),
                          children: [
                            TextSpan(
                              text: 'Last Park?',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 60, color: Colors.redAccent),
                            )
                          ]
                      ),
                    ),

                    SizedBox(height: 40,),
                    ByText(),
                    SizedBox(height: 10,),
                    ByCamera(),
                    SizedBox(height: 10,),
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection('users').doc(fp.getUser().email).collection(fp.getUser().email).orderBy('createdAt', descending: true).snapshots(), // 1
                        builder: (context, snapshot) { // 2
                          if(!snapshot.hasData) { // 3
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final docs = snapshot.data.docs; // 4
                          return Expanded(
                            child: ListView(
                              children: docs.map((doc) => _buildItemWidget(doc)).toList(), // 5
                            ),
                          );
                        }
                    )
                  ],
                ),
              ),
              color: Colors.white
          ),
        )
    );
  }

  Widget bottomSheet() {
    return Container(
        height: 100,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20
        ),
        child: Column(
          children: <Widget>[
            Text(
              'Choose Profile photo',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton.icon(
                  icon: Icon(Icons.camera, size: 50,),
                  onPressed: () {
                    takePhoto(ImageSource.camera);
                  },
                  label: Text('Camera', style: TextStyle(fontSize: 20),),
                ),
//                FlatButton.icon(
//                  icon: Icon(Icons.photo_library, size: 50,),
//                  onPressed: () {
//                    takePhoto(ImageSource.gallery);
//                  },
//                  label: Text('Gallery', style: TextStyle(fontSize: 20),),
//                )
              ],
            )
          ],
        )
    );
  }

  takePhoto(ImageSource source) async {
    Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.camera]);
    print('per1 : $permissions');
    final pickedFile = await _picker.getImage(source: source);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Widget imageProfile() {
    return Center(
      child: Stack(
        children: <Widget>[
          CircleAvatar(
            radius: 80,
            backgroundImage: _imageFile == null
                ? AssetImage('assets/profile.jfif')
                : FileImage(File(_imageFile.path)),
          ),
          Positioned(
              bottom: 20,
              right: 20,
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(context: context, builder: ((builder) => bottomSheet()));
                },
                child: Icon(
                  Icons.camera_alt,
                  color: Global.sBlue,
                  size: 40,
                ),
              )
          )
        ],
      ),
    );
  }

  Widget ByCamera() {
    return Row(
      children: [
        Expanded(
            child: Container(
              color: Colors.blue,
              child: _imageFile == null
                  ? Container(height: 50, color: Colors.grey, child: Center(child: Text('등록된 사진 없음', style: TextStyle(color: Global.sWhite),)))
                  : FileImage(File(_imageFile.path)),
            )
        ),
        SizedBox(width: 10),
        Container(
          height: 50,
          width: MediaQuery.of(context).size.width * 0.2,
          child: RaisedButton(
              color: Global.sBlue,
              onPressed: () {
                takePhoto(ImageSource.camera);
//              showModalBottomSheet(context: context, builder: ((builder) => bottomSheet()));
              },
              child: Icon(Icons.camera_alt, color: Colors.white,)
          ),
        )
      ],
    );
  }
  Widget ByText() {
    return Row(
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
                  hintText: 'B4 F2 (지하4층 F2구역)'
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Container(
          height: 50,
          width: MediaQuery.of(context).size.width * 0.2,
          child: RaisedButton(
            color: Global.sBlue,
            onPressed: () {
              addParkData(fp.getUser().email, _whereIs.text);
            },
            child: Icon(Icons.create, color: Global.sWhite,),
          ),
        )
      ],
    );
  }
  Widget _buildItemWidget(DocumentSnapshot doc) { // DocumentSnapshot 추가
    // title은 생성시 필수값, isDone은 옵셔널
    final park = ParkModel(
      id: doc.id,
      email: doc.data()['email'],
      whereIs: doc.data()['whereIs'],
      createdAt: doc.data()['createdAt'],
    );

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Text('장소', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Global.sBlue),),
                SizedBox(width: 10,),
                Text(park.whereIs, style: TextStyle(fontSize: 12),),
                SizedBox(width: 10,),
                Text('구역', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Global.sBlue),),
                SizedBox(width: 10,),
                Text(park.whereIs, style: TextStyle(fontSize: 12),),
              ],
            ),
            Row(
              children: [
                Text('주차시간', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Global.sBlue),),
                SizedBox(width: 10,),
                Text(park.createdAt.toDate().toString().substring(0, 19), style: TextStyle(fontSize: 12),),
                Spacer(),
                InkWell(onTap:() => databaseService.deleteParkData(park.email, park.id),child: Icon(Icons.delete_forever, color: Global.sGrey,)),
              ],
            )
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
