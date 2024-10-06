import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_c/Home.dart';
import 'package:flutter_c/Home2.dart';

class AdminPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _login(BuildContext context) async {
    try {
      // Retrieve credentials from Firestore
      QuerySnapshot querySnapshot = await _firestore.collection('credentials').get();
      final List<QueryDocumentSnapshot> documents = querySnapshot.docs;

      // Check if credentials match
      bool credentialsMatch = false;
      for (var document in documents) {
        if (document['email'] == emailController.text.trim() &&
            document['password'] == passwordController.text.trim()) {
          credentialsMatch = true;
          break;
        }
      }

      // If credentials match, navigate to Home2
      if (credentialsMatch) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home2()),
        );
      } else {
        // Show error message if credentials don't match
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Login Failed'),
              content: Text('Invalid email or password.'),
              actions: <Widget>[
                ElevatedButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Handle errors
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Login'),
        backgroundColor: Colors.green[800], // Dark green for the app bar
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green[50]!, Colors.green[200]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.green[700]), // Green label color
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green[400]!), // Light green border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green[600]!), // Medium green border
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.green[700]), // Green label color
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green[400]!), // Light green border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green[600]!), // Medium green border
                  ),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () => _login(context),
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromARGB(255, 51, 193, 232), // Green button color
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
