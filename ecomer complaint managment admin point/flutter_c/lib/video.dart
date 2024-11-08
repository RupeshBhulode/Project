import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminVideoPage extends StatefulWidget {
  @override
  _AdminVideoPageState createState() => _AdminVideoPageState();
}

class _AdminVideoPageState extends State<AdminVideoPage> {
  TextEditingController _videoUrlController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Flower farming';
  List<Map<String, dynamic>> _videoList = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to fetch data from Firestore
  Future<void> _fetchVideos() async {
    QuerySnapshot snapshot = await _firestore.collection('videos').get();
    setState(() {
      _videoList = snapshot.docs.map((doc) {
        return {
          'id': doc.id,  // Store document ID
          'title': doc['title'],
          'url': doc['url'],
          'thumbnail': doc['thumbnail'],
          'description': doc['description'],
          'category': doc['category'],
        };
      }).toList();
    });
  }

  // Function to extract video ID from YouTube URL (handles multiple URL formats)
  String? _extractVideoId(String url) {
    RegExp regExp = RegExp(
        r"(https?:\/\/(?:www\.)?(?:youtube\.com\/(?:v\/|watch\?v=|embed\/)|youtu\.be\/)([a-zA-Z0-9_-]{11}))");
    Match? match = regExp.firstMatch(url);
    if (match != null) {
      return match.group(2); // Return the video ID
    }
    return null;
  }

  // Function to get YouTube video thumbnail URL from video ID
  String _getThumbnailUrl(String videoId) {
    return 'https://img.youtube.com/vi/$videoId/0.jpg';
  }

  // Function to handle video URL submission
  Future<void> _submitVideoUrl() async {
    String url = _videoUrlController.text.trim();
    String? videoId = _extractVideoId(url);
    if (videoId != null) {
      String thumbnailUrl = _getThumbnailUrl(videoId);
      try {
        await _firestore.collection('videos').add({
          'title': _titleController.text.trim(),
          'url': url,
          'thumbnail': thumbnailUrl,
          'description': _descriptionController.text.trim(),
          'category': _selectedCategory,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Video added successfully!"),
        ));
        _fetchVideos(); // Refresh the list after adding the video
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error adding video: $e"),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Invalid YouTube URL"),
      ));
    }
  }

  // Function to delete a video from Firestore
  Future<void> _deleteVideo(String docId) async {
    try {
      await _firestore.collection('videos').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Video deleted successfully!'),
      ));
      _fetchVideos();  // Refresh the list after deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error deleting video: $e'),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchVideos(); // Fetch video list when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Video Manager'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Enter Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _videoUrlController,
              decoration: InputDecoration(
                labelText: 'Enter YouTube Video URL',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Enter Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: _selectedCategory,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
              items: <String>['Flower farming', 'Crop production', 'Plant Protection', 'Seasonal tips']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitVideoUrl,
              child: Text('Add Video'),
            ),
            SizedBox(height: 16),
            Text(
              'Videos added so far:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _videoList.length,
                itemBuilder: (context, index) {
                  String url = _videoList[index]['url']!;
                  String thumbnail = _videoList[index]['thumbnail']!;
                  String docId = _videoList[index]['id']!;
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Image.network(
                        thumbnail,
                        width: 80,
                        height: 45,
                        fit: BoxFit.cover,
                      ),
                      title: Text(url),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Title: ${_videoList[index]['title']}'),
                          Text('Category: ${_videoList[index]['category']}'),
                          Text('Description: ${_videoList[index]['description']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteVideo(docId);  // Pass docId for deletion
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
