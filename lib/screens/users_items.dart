// ignore_for_file: prefer_const_constructors, unnecessary_new

import 'package:eauction/screens/home.dart';
import 'package:eauction/screens/item_details.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:eauction/models/Posts.dart';
import 'package:eauction/screens/login.dart';

class UsersItem extends StatefulWidget {
  const UsersItem({Key? key}) : super(key: key);

  @override
  _UsersItemState createState() => _UsersItemState();
}

class _UsersItemState extends State<UsersItem> {
  List<Posts> postsList = [];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseRef = FirebaseDatabase.instance.ref().child("User");
  FirebaseStorage storage = FirebaseStorage.instance;
  User? user;

  bool isloggedin = false;
  final Future<FirebaseApp> _future = Firebase.initializeApp();

  checkAuthentification() async {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => const LoginScreen()));
      }
    });
  }

  getUser() async {
    User? firebaseUser = _auth.currentUser;
    await firebaseUser?.reload();
    firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      setState(() {
        this.user = firebaseUser;
        this.isloggedin = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentification();
    this.getUser();
    DatabaseReference postsRef = FirebaseDatabase.instance.ref().child("User");
    final String current_user_id = _auth.currentUser!.uid;

    postsRef.once().then((snap) {
      dynamic keys = snap.snapshot.value;
      dynamic KEYS = keys.keys;

      dynamic DATA = snap.snapshot.value;

      postsList.clear();

      for (var individualKey in KEYS) {
        Posts posts = Posts(
            DATA[individualKey]['Name'],
            DATA[individualKey]['Description'],
            DATA[individualKey]['Minimum_Bid_Price'],
            DATA[individualKey]['ImageURL'],
            DATA[individualKey]['End_Date'],
            DATA[individualKey]['AuctionID']);

        print(current_user_id);
        if (DATA[individualKey]['UserID'] == current_user_id) {
          postsList.add(posts);
        }
      }

      setState(() {
        print('Length : $postsList.length');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('My Items'),
        leading: IconButton(
          onPressed: () {
            debugPrint("Form button clicked");
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return const HomeScreen();
            }));
          },
          icon: Icon(Icons.home),
        ),
      ),
      body: Container(
        child: postsList.length == 0
            ? Text("")
            : ListView.builder(
                itemCount: postsList.length,
                itemBuilder: (_, index) {
                  return PostUI(
                      index,
                      postsList[index].ImageURL,
                      postsList[index].Description,
                      postsList[index].End_Date,
                      postsList[index].Minimum_Bid_Price,
                      postsList[index].Name,
                      postsList[index].AuctionID);
                }),
      ),
    );
  }

  Widget PostUI(int index, String image, String description, String date,
      String minBid, String name, String auctionID) {
    return new GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDetails(),
              settings: RouteSettings(
                arguments: postsList[index],
              ),
            ),
          );
        },
        child: Card(
          elevation: 10.0,
          margin: EdgeInsets.all(15.0),
          child: new Container(
            padding: new EdgeInsets.all(14.0),
            child: new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text(
                        name,
                        style: Theme.of(context).textTheme.subtitle2,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  new Image.network(image, fit: BoxFit.cover),
                  SizedBox(
                    height: 10.0,
                  ),
                ]),
          ),
        ));
  }
}
