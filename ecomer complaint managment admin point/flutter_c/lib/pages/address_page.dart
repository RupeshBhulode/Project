import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _senderNameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController(); // Added text controller for message
  String? _selectedCategory;
  List<String> _imageURLs = [];
  int _imageCount = 0;
  final int _maxImageCount = 5;

  Future<void> _launchGoogleMaps() async {
    const double latitude = 40.7128;
    const double longitude = -74.0060;
    const String address = 'New York City, NY'; // Set the address manually
    final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude'; // Use the latitude and longitude
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  Future<void> _pickImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      final imageData = base64Encode(pickedImage.data!);
      final dataUrl = 'data:image/jpeg;base64,$imageData';
      setState(() {
        _imageURLs.add(dataUrl);
        _imageCount++;
      });
    }
  }

  Future<MediaInfo?> pickImage() async {
    if (_imageCount < _maxImageCount) {
      MediaInfo? mediaInfo = await ImagePickerWeb.getImageInfo;
      return mediaInfo;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Maximum image limit reached ($_maxImageCount images)'),
      ));
      return null;
    }
  }

  void _sendMessage() {
    FirebaseFirestore.instance.collection('messagesss').add({
      'senderName': _senderNameController.text.trim(),
      'message': _messageController.text.trim(), // Send the message
      'category': _selectedCategory,
      'imageUrls': _imageURLs,
      'timestamp': Timestamp.now(),
    }).then((_) {
      _senderNameController.clear();
      _messageController.clear(); // Clear the message text field
      _selectedCategory = null;
      setState(() {
        _imageURLs.clear();
        _imageCount = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Message sent successfully!'),
      ));
    }).catchError((error) {
      print('Error sending message: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send message.'),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Address'),
        
        actions: [
          IconButton(
            icon: Icon(Icons.location_on),
            onPressed: _launchGoogleMaps,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: Icon(Icons.storage),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var imageURL in _imageURLs)
                SizedBox(
                  height: 150,
                  width: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      imageURL,
                    ),
                  ),
                ),
              if (_imageCount < _maxImageCount)
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Pick Image'),
                ),
              SizedBox(height: 16.0),
              TextField(
                controller: _senderNameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _messageController, // Added controller for message
                decoration: InputDecoration(
                  labelText: 'Address', // Added message text field
                ),
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Category',
                ),
                items: ['Mandir', 'Hospital', 'Railway Station', 'Lake','Schools', 'Colleges'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _sendMessage,
                child: Text('Send'),
              ),
              SizedBox(height: 16.0),
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection('messagesss').snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: documents.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Map<String, dynamic> data = documents[index].data() as Map<String, dynamic>;
                      final String senderName = data['senderName'] ?? '';
                      final String message = data['message'] ?? ''; // Get message from Firestore
                      final String category = data['category'] ?? '';
                      final List<dynamic>? imageURLs = data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : null;
                      final Timestamp timestamp = data['timestamp'];
                      final DateTime dateTime = timestamp.toDate();
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Name: $senderName'),
                              Text('Address: $message'), // Display the message
                              Text('Category: $category'),
                              Text('Sent on: ${dateTime.toString()}'),
                            ],
                          ),
                          subtitle: imageURLs != null
                              ? SizedBox(
                                  height: 150,
                                  width: 150,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: imageURLs.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: Image.network(
                                          imageURLs[index],
                                          height: 150,
                                          width: 150,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyHomePage(),
    debugShowCheckedModeBanner: false,
  ));
}
