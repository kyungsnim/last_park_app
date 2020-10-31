import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:last_park_app/models/park_model.dart';
import 'package:last_park_app/services/firebase_provider.dart';
import 'package:last_park_app/services/database.dart';
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

  @override
  void dispose() {
    _whereIs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    logger.d(fp.getUser());

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
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                RichText(
                  text: TextSpan(
                    text: 'Where is my \n',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50, color: Colors.indigo),
                    children: [
                      TextSpan(
                        text: 'Last Park?',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 60, color: Colors.redAccent),
                      )
                    ]
                  ),
                ),

                SizedBox(height: 40,),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _whereIs,
                        cursorWidth: 10,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(), // 테두리
                          labelText: '주차 장소 어디 ?',
                          hintText: 'B4 F2 (지하4층 F2구역)'
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: RaisedButton(
                        onPressed: () {
                          addParkData(fp.getUser().email, _whereIs.text);
                        },
                        child: Text('주차완료', style: TextStyle(fontSize: 20),),
                      ),
                    )
                  ],
                ),
                StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc(fp.getUser().email).collection(fp.getUser().email).snapshots(), // 1
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
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Text('장소', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.indigo),),
                SizedBox(width: 10,),
                Text(park.whereIs, style: TextStyle(fontSize: 12),),
                Spacer(),
                Text('시간', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.indigo),),
                SizedBox(width: 10,),
                Text(park.createdAt.toDate().toString().substring(0, 19), style: TextStyle(fontSize: 12),),
                SizedBox(width: 15,),
                InkWell(onTap:() => databaseService.deleteParkData(park.email, park.id),child: Icon(Icons.delete_forever)),
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
