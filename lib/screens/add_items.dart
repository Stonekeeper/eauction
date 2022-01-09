// ignore_for_file: prefer_const_constructors, unnecessary_new, unnecessary_this, avoid_unnecessary_containers, unused_field, non_constant_identifier_names

import 'dart:io';
import 'dart:math';
import 'package:eauction/screens/home.dart';
import 'package:eauction/screens/login.dart';
import 'package:eauction/screens/users_items.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:eauction/screens/profile.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddItemsScreen extends StatefulWidget {
  const AddItemsScreen({Key? key}) : super(key: key);

  @override
  _AddItemsScreenState createState() => _AddItemsScreenState();
}

class _AddItemsScreenState extends State<AddItemsScreen> {
  //FireBase Auth Instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Future<FirebaseApp> _future = Firebase.initializeApp();

  //Fire Base Real Time Database Instance
  final databaseRef = FirebaseDatabase.instance.ref().child("User");
  //User Variable
  User? user;
  // To check wheather user has logged in or not
  bool isloggedin = false;

  //To Highlight The Logo
  int _currentIndex = 2;
  //To Store the image
  File? sampleImage;
  //To Store Date
  DateTime? _selectedDate;

  // Validate Form
  final _formKey = GlobalKey<FormState>();

  // Editing Controllers for Input
  final imageEditingController = TextEditingController();
  final titleEditingController = TextEditingController();
  final descEditingController = TextEditingController();
  final minPriceEditingController = TextEditingController();
  final endDateTimeEditingController = TextEditingController();
  final confirmPasswordEditingController = TextEditingController();

  //Function to push the page based on index of list _children and Signout
  _onTap() async {
    if (_currentIndex == 4) {
      await _auth.signOut();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => const LoginScreen()));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => _children[_currentIndex]));
    }
  }

  // Generate Random ID for Auction ID
  String randomID() {
    var r = Random();
    return String.fromCharCodes(
        List.generate(7, (index) => r.nextInt(33) + 89));
  }

  // Redirect to Home page after adding an item
  void gotoHomePage() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      Fluttertoast.showToast(msg: "Item added successfully");
      return const HomeScreen();
    }));
  }

  //Widget List for Switching Between Different Pages
  final List<Widget> _children = [
    const HomeScreen(),
    const ProfileScreen(),
    const AddItemsScreen(),
    const UsersItem()
  ];

  //To get Current User Details
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

  //To Check weather the user is signed in or not
  checkAuthentification() async {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => const LoginScreen()));
      }
    });
  }

  //Initialse
  @override
  void initState() {
    super.initState();
    this.checkAuthentification();
    this.getUser();
  }

  // Pick Image from gallery
  Future getImage() async {
    var tempImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      sampleImage = File(tempImage!.path);
    });
  }

  //To view  Image in the Add items Screen
  Widget enableUpload() {
    return Container(
      child: Column(
        children: <Widget>[
          Image.file(sampleImage!, height: 150.0, width: 300.0),
        ],
      ),
    );
  }

  //Date Selector Widget
  _selectDate(BuildContext context) async {
    DateTime? newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate != null ? _selectedDate! : DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2040),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: const ColorScheme.dark(
                primary: Colors.deepPurple,
                onPrimary: Colors.white,
                surface: Colors.blueGrey,
                onSurface: Colors.black54,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child!,
          );
        });

    if (newSelectedDate != null) {
      _selectedDate = newSelectedDate;
      endDateTimeEditingController
        ..text = DateFormat.yMMMd().format(_selectedDate!)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: endDateTimeEditingController.text.length,
            affinity: TextAffinity.upstream));
    }
  }

  //To Push all the items details to Firebase Real time Database
  Future<void> addData(File sampleImage, String name, String des,
      String min_bid, String date) async {
    if (_formKey.currentState!.validate()) {
      try {
        String fileName = sampleImage.path;
        Reference firebaseStorageRef =
            FirebaseStorage.instance.ref().child(fileName);
        UploadTask uploadTask = firebaseStorageRef.putFile(sampleImage);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
        String url = (await taskSnapshot.ref.getDownloadURL());
        //print('URL Is $url');
        databaseRef.push().set({
          'Name': name,
          'Description': des,
          'Minimum_Bid_Price': min_bid,
          'ImageURL': url,
          'End_Date': date,
          'UserID': user!.uid,
          'AuctionID': randomID()
        });
        gotoHomePage();
      } catch (e) {
        Fluttertoast.showToast(msg: "Enter Valid Details");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //Image Upload Button
    final addImageButton = Material(
      elevation: 5,
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      color: Colors.blue,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
        minWidth: MediaQuery.of(context).size.width,
        child: sampleImage == null
            ? const Text("Add image",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ))
            : enableUpload(),
        onPressed: () {
          getImage();
        },
      ),
    );

    //Title Field
    final titleField = TextFormField(
      autofocus: false,
      controller: titleEditingController,
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please Enter Title");
        }
        if (!RegExp("^[a-zA-Z]+").hasMatch(value)) {
          return ("Please enter valid Title");
        }
        return null;
      },
      onSaved: (value) {
        titleEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.production_quantity_limits),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Title",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );

    //Desc Field
    final descField = TextFormField(
      autofocus: false,
      controller: descEditingController,
      keyboardType: TextInputType.multiline,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please Enter Desc of Product");
        }
        if (!RegExp("^[a-zA-Z]+").hasMatch(value)) {
          return ("Please enter valid Title");
        }
        return null;
      },
      onSaved: (value) {
        descEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      maxLines: null,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.description),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Description",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );

    //Miniumun Price Field
    final minPriceField = TextFormField(
      autofocus: false,
      controller: minPriceEditingController,
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please Enter Price");
        }
        if (!RegExp("^[0-9]").hasMatch(value)) {
          return ("Please enter valid Price");
        }
        return null;
      },
      onSaved: (value) {
        minPriceEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      maxLines: null,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.list),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Minimun bid price",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );

    //Date Time Field
    final dateTimeField = TextField(
      autofocus: false,
      controller: endDateTimeEditingController,
      keyboardType: TextInputType.number,
      onTap: () {
        _selectDate(context);
      },
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.date_range),
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Select Date",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    );

    //Add Item Button
    final addItemButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.all(Radius.circular(10)),
      color: Colors.blue,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          Fluttertoast.showToast(msg: "Adding item please wait..");
          Fluttertoast.showToast(msg: "Don't click again");
          addData(
              sampleImage!,
              titleEditingController.text,
              descEditingController.text,
              minPriceEditingController.text,
              endDateTimeEditingController.text);
        },
        child: const Text(
          "Add item",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );

    //Scaffold
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Item"),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Center(
          child: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 30),
                  addImageButton,
                  const SizedBox(height: 25),
                  titleField,
                  const SizedBox(height: 25),
                  descField,
                  const SizedBox(height: 25),
                  minPriceField,
                  const SizedBox(height: 25),
                  dateTimeField,
                  const SizedBox(height: 25),
                  addItemButton,
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      )),

      //Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline_outlined), label: "Sell"),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Bids"),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: "Logout"),
        ],
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.white,
        onTap: (index) {
          // this has changed
          setState(() {
            _currentIndex = index;
          });
          _onTap();
        },
      ),
    );
  }
}
