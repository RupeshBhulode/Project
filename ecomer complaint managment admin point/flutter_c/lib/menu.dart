import 'package:flutter/material.dart';
import 'pages/calls_page.dart'; // Import the pages you want to navigate to
import 'pages/website_page.dart';
import 'pages/emergency_calls_page.dart';
import 'pages/business_page.dart';
import 'pages/address_page.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu'),
        backgroundColor: Colors.teal, // Set AppBar color to teal
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children to take full width
          children: [
            _buildButton(context, 'Calls', CallsPage()),
            _buildButton(context, 'Website', WebsitePage()),
            _buildButton(context, 'Emergency Calls', EmergencyCallsPage()),
            _buildButton(context, 'Business', BusinessPage()),
            _buildButton(context, 'Address', MyHomePage()),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String title, Widget page) {
    return Container(
      height: 60, // Fixed height for all buttons
      margin: EdgeInsets.symmetric(vertical: 8.0), // Space between buttons
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.teal, // Button color
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Explicitly set text color to white
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MenuScreen(),
  ));
}
