import 'package:eauction/screens/login.dart';
import 'package:eauction/screens/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:eauction/screens/home.dart';
import 'package:eauction/screens/add_items.dart';

class BidsScreen extends StatefulWidget {
  const BidsScreen({Key? key}) : super(key: key);

  @override
  _BidsScreenState createState() => _BidsScreenState();
}

class _BidsScreenState extends State<BidsScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;

  int _currentIndex = 3;

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

  //Widget List for Switching Between Different Pages

  final List<Widget> _children = [
    const HomeScreen(),
    const ProfileScreen(),
    const AddItemsScreen(),
    const BidsScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bids Page"),
        centerTitle: true,
      ),
      // body: _pageOptions[selectedPage],

      // body: Center(
      //   child: Padding(
      //     padding: const EdgeInsets.all(20),
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       crossAxisAlignment: CrossAxisAlignment.center,
      //       children: <Widget>[
      //         SizedBox(
      //           height: 150,
      //           child: Image.asset(
      //             "assets/logo.png",
      //             fit: BoxFit.cover,
      //           ),
      //         ),
      //         const Text("Welcome Back"),
      //         const SizedBox(height: 20),
      //         const Text("Name"),
      //         const SizedBox(height: 20),
      //         const Text("Email"),
      //         const SizedBox(height: 20),
      //         ActionChip(label: const Text("Logout"), onPressed: () {}),
      //       ],
      //     ),
      //   ),
      // ),

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
