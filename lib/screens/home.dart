import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 150,
                child: Image.asset(
                  "assets/logo.png",
                  fit: BoxFit.cover,
                ),
              ),
              const Text("Welcome Back"),
              const SizedBox(height: 20),
              const Text("Name"),
              const SizedBox(height: 20),
              const Text("Email"),
              const SizedBox(height: 20),
              ActionChip(label: const Text("Logout"), onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
