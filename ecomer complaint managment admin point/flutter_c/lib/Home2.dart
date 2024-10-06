import 'package:flutter/material.dart';
import 'package:flutter_c/menu.dart';
import 'Home.dart';
import 'info.dart';

class Home2 extends StatelessWidget {
  const Home2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal, // Dark green for the app bar
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.teal.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                  );
                },
                 child: const Text(
                  'Agrishop',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Make text bold
                    color: Colors.white, // Text color white
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700, // Green button color
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(height: 20), // Space between buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MenuScreen()),
                  );
                },
               // child: const Text('Emergency'),
                 child: const Text(
                  'Emergency',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Make text bold
                    color: Colors.white, // Text color white
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade700, // Green button color
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              SizedBox(height: 20), // Space between buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => info()),
                  );
                },
                //child: const Text('Info'),
                child: const Text(
                  'Info',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Make text bold
                    color: Colors.white, // Text color white
                  ),
                ),

                style: ElevatedButton.styleFrom(
               backgroundColor: Colors.teal.shade700, // Green button color
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
