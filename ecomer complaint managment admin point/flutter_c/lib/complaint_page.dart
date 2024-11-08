// complaint_page.dart
import 'package:flutter/material.dart';
import 'initial_complaints.dart';
import 'in_progress_complaints.dart';
import 'resolved_complaints.dart';
import 'load.dart';  // Import load page
import 'video.dart';  // Import VideoPage

class ComplaintStatusPage extends StatelessWidget {
  const ComplaintStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Complaint Management")),
      body: const Center(child: Text("Select a category from the bottom navigation bar")),
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pending), label: 'Initial'),
          BottomNavigationBarItem(icon: Icon(Icons.sync), label: 'In Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Resolved'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const InitialComplaintsPage()));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const InProgressComplaintsPage()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ResolvedComplaintsPage()));
          }
        },
      ),
      
      // Single FloatingActionButton with two actions
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Use a dialog or an action sheet to choose between LoadPage and VideoPage
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text("Choose Action"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: const Text("Go to Load Page"),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoadPage()),
                        );
                      },
                    ),
                    ListTile(
                      title: const Text("Watch Video"),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AdminVideoPage()),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: const Icon(Icons.video_library), // Icon for the button
      ),
    );
  }
}
