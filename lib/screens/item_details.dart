// ignore_for_file: prefer_const_constructors, unnecessary_new, unnecessary_this, avoid_unnecessary_containers, unused_field, non_constant_identifier_names, avoid_print, unused_local_variable

import 'package:eauction/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:eauction/screens/home.dart';
import 'package:eauction/models/Posts.dart';
import 'package:eauction/models/Bids.dart';

class ItemDetails extends StatefulWidget {
  const ItemDetails({Key? key}) : super(key: key);

  @override
  _ItemDetailsState createState() => _ItemDetailsState();
}

class _ItemDetailsState extends State<ItemDetails> {
  //To Store all the Bids
  List<Bids> bidsList = [];
  // To Store and send the Bid Amount to DB
  final bid = TextEditingController();
  String? post_auction_id;
  int flag = 0;
  int winner = 0;
  String _bidWinner = "No bidder";
  //User Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //Reference to User Collection
  final databaseRef = FirebaseDatabase.instance.ref().child("User");
  //Reference to Bids Collection
  final DatabaseReference bidsRef =
      FirebaseDatabase.instance.ref().child("Bid");
  //Instance of Storage
  FirebaseStorage storage = FirebaseStorage.instance;
  User? user;
  bool isloggedin = false;
  final Future<FirebaseApp> _future = Firebase.initializeApp();

  //Check Auth Status of User
  checkAuthentification() async {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => const LoginScreen()));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentification();
    this.getUser();

    bidsRef.once().then((snap) {
      dynamic keys = snap.snapshot.value;
      dynamic KEYS = keys.keys;

      dynamic DATA = snap.snapshot.value;
      bidsList.clear();

      for (var individualKey in KEYS) {
        Bids bids = Bids(
          DATA[individualKey]['AuctionID'],
          DATA[individualKey]['User_name'],
          DATA[individualKey]['Bid'],
          DATA[individualKey]['UserID'],
        );

        final Posts todo = ModalRoute.of(context)?.settings.arguments as Posts;
        post_auction_id = todo.AuctionID;

        if (DATA[individualKey]['AuctionID'] == post_auction_id) {
          int initValue = int.parse(DATA[individualKey]['Bid']);

          if (initValue > winner) {
            _bidWinner = DATA[individualKey]['User_name'];
            winner = initValue;
          }
          bidsList.add(bids);
        }
        print(_bidWinner);
      }

      setState(() {
        print('Length : ${bidsList.length}');
      });
    });
  }

  //Get Details of Currently logged in user
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

  //To Store Bid data to DB
  void addBid(String bid) {
    final Posts todo = ModalRoute.of(context)?.settings.arguments as Posts;
    if (flag == 0) {
      bidsRef.push().set({
        'Bid': bid,
        'User_name': user?.email,
        'AuctionID': todo.AuctionID,
        'UserID': user?.uid
      });
    } else {
      bidsRef.once().then((snap) {
        dynamic keys = snap.snapshot.value;
        dynamic KEYS = keys.keys;
        dynamic DATA = snap.snapshot.value;

        for (var individualKey in KEYS) {
          Bids bids = Bids(
            DATA[individualKey]['AuctionID'],
            DATA[individualKey]['User_name'],
            DATA[individualKey]['Bid'],
            DATA[individualKey]['UserID'],
          );

          if (DATA[individualKey]['UserID'] == user?.uid &&
              DATA[individualKey]['AuctionID'] == todo.AuctionID) {
            dynamic key = individualKey;
            print("key:$key");

            bidsRef.child(key).remove();

            bidsRef.child(key).set({
              'Bid': bid,
              'User_name': user?.email,
              'AuctionID': todo.AuctionID,
              'UserID': user?.uid
            });
          }
        }
      });
    }

    refresh();
  }

  void refresh() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return HomeScreen();
    }));
  }

  void _showDialog(String txt) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Sorry!"),
          content: Text(txt),
          actions: <Widget>[
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool isNumber(String string) {
    // Null or empty string is not a number
    if (string == null || string.isEmpty) {
      return false;
    }
    final number = num.tryParse(string);

    if (number == null) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final Posts todo = ModalRoute.of(context)?.settings.arguments as Posts;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: Text('Item Details'),
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
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
          Container(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Image.network(
                          todo.ImageURL,
                          height: 300.0,
                          width: 300.0,
                          alignment: Alignment.center,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                ]),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: const <Widget>[
                        Text(
                          "Name: ",
                          textAlign: TextAlign.start,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          todo.Name,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                  ]),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: const <Widget>[
                        Text(
                          "Description: ",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          todo.Description,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                  ]),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: const <Widget>[
                        Text(
                          "Minimum Bid Price: ",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          "${todo.Minimum_Bid_Price} Rupees",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                  ]),
            ),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: const <Widget>[
                        Text(
                          "End Date: ",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          todo.End_Date,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                  ]),
            ),
          ),
          Container(
              child: Column(children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                  autofocus: false,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  controller: bid,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.attach_money_outlined),
                    contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    hintText: "Bid Amount",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  )),
            ),
            SizedBox(height: 10.0),
            Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(30, 0, 30, 5),
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.blue,
                  child: MaterialButton(
                    padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                    minWidth: MediaQuery.of(context).size.width,
                    child: const Text(
                      "Place Bid",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      if (isNumber(bid.text)) {
                        addBid(bid.text);
                      } else {
                        _showDialog("Please enter valid amount ");
                      }
                    },
                  ),
                ),
              ),
            ),
          ])),
          Container(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    children: const <Widget>[
                      Text(
                        "Bid Winner :",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Text(_bidWinner,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                backgroundColor: Colors.red)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                ]),
          ),
          bidsList.length == 0
              ? new Text("")
              : new ListView.builder(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: bidsList.length,
                  itemBuilder: (_, index) {
                    if (bidsList[index].UserID ==
                        FirebaseAuth.instance.currentUser?.uid) {
                      flag = 1;
                    }

                    return PostUI(bidsList[index].AuctionID,
                        bidsList[index].Bid, bidsList[index].User_name);
                  }),
        ])));
  }

  Widget PostUI(String auctionID, String User_name, String bid) {
    return new Container(
        child: Card(
      elevation: 10.0,
      margin: EdgeInsets.all(7.0),
      child: new Container(
        padding: new EdgeInsets.all(14.0),
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Text(
                    User_name,
                    style: Theme.of(context).textTheme.subtitle1,
                    textAlign: TextAlign.center,
                  ),
                  new Text(
                    "${bid} Rupees",
                    style: Theme.of(context).textTheme.subtitle1,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ]),
      ),
    ));
  }
}
