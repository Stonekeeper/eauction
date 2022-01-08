// ignore_for_file: prefer_const_constructors, unnecessary_new
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eauction/models/user_model.dart';
import 'package:eauction/screens/add_items.dart';
import 'package:eauction/screens/home.dart';
import 'package:eauction/screens/login.dart';
import 'package:eauction/screens/users_items.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  UserModel loggedInUser = new UserModel();
  int _currentIndex = 1;

  String? name;
  //Function to push the page based on index of list _children and Signout
  _onTap() async {
    if (_currentIndex == 4) {
      await _auth.signOut();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => const LoginScreen()));
    } else {
      // this has changed
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) =>
              _children[_currentIndex])); // this has changed
    }
  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      name = loggedInUser.name;
      print(name);

      setState(() {});
    });
  }

  //Widget List for Switching Between Different Pages
  final List<Widget> _children = [
    const HomeScreen(),
    const ProfileScreen(),
    const AddItemsScreen(),
    const UsersItem()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Center(
          child: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  "Bidders Bazzar",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Race'),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 100,
                  child: Image.asset(
                    "assets/logo.png",
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.person,
                      size: 50,
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.black, // Set border color
                              width: 2.0), // Set border width
                          borderRadius: BorderRadius.all(Radius.circular(
                              10.0)), // Set rounded corner radius
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 0,
                                color: Colors.black,
                                offset: Offset(1, 3))
                          ] // Make rounded corner of border
                          ),
                      child: Text(
                        "Name : ${loggedInUser.name}",
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.phone,
                      size: 50,
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.black, // Set border color
                              width: 2.0), // Set border width
                          borderRadius: BorderRadius.all(Radius.circular(
                              10.0)), // Set rounded corner radius
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 0,
                                color: Colors.black,
                                offset: Offset(1, 3))
                          ] // Make rounded corner of border
                          ),
                      child: Text(
                        "Mobile:91${loggedInUser.mobileno}",
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.mail,
                      size: 50,
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.black, // Set border color
                              width: 2.0), // Set border width
                          borderRadius: BorderRadius.all(Radius.circular(
                              10.0)), // Set rounded corner radius
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 0,
                                color: Colors.black,
                                offset: Offset(1, 3))
                          ] // Make rounded corner of border
                          ),
                      child: Text(
                        "Mail:${loggedInUser.email}",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.document_scanner,
                      size: 50,
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.black, // Set border color
                              width: 2.0), // Set border width
                          borderRadius: BorderRadius.all(Radius.circular(
                              10.0)), // Set rounded corner radius
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 0,
                                color: Colors.black,
                                offset: Offset(1, 3))
                          ] // Make rounded corner of border
                          ),
                      child: Text(
                        "Aadhar:${loggedInUser.aadharid}",
                        style: TextStyle(fontSize: 20),
                      ),
                    )
                  ],
                ),

                // emailField,
                // const SizedBox(height: 20),
                // mobileField,
                // const SizedBox(height: 20),
                // aadharField,
                // const SizedBox(height: 20),
                // passwordField,
                // const SizedBox(height: 20),
                // confirmPasswordField,
                // const SizedBox(height: 15),
                // signupButton,
                // const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      )),
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
