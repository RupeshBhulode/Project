import 'package:flutter/material.dart';
import 'package:flutter_c/text_load.dart';
import 'package:flutter_c/video_load.dart';

class LoadPage extends StatelessWidget {
  const LoadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loading Page')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),  // Space before the buttons

            // Button to navigate to Video Load Page
            ElevatedButton(
              onPressed: () {
                // Navigate to the video load page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  VideoLoadPage()),
                );
              },
              child: const Text('Add Video'),
            ),
            
            const SizedBox(height: 20),  // Space between the buttons

            // Button to navigate to Text Load Page
            ElevatedButton(
              onPressed: () {
                // Navigate to the text load page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TextLoadPage()),
                );
              },
              child: const Text('Add Text'),
            ),
          ],
        ),
      ),
    );
  }
}
