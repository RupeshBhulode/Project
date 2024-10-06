import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view.dart'; // Import the photo_view package
import 'NewPage.dart'; // Import the NewPage.dart file
import 'Storage.dart'; // Import the Storage.dart file

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('messages').snapshots(),
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
            itemCount: documents.length,
            itemBuilder: (BuildContext context, int index) {
              final Map<String, dynamic> data = documents[index].data() as Map<String, dynamic>;
              final String? senderId = data['userId'];
              final String? senderName = data['senderName']; // Retrieve sender's name
              final String? address = data['address']; // Retrieve address
              final String? phoneNumber = data['phoneNumber']; // Retrieve phone number
              final String? productName = data['productName']; // Retrieve product name
              final String? description = data['description']; // Retrieve description
              final double? price = data['price']; // Retrieve price
              final List<String>? imageURLs = data['imageUrls'] != null ? List<String>.from(data['imageUrls']) : null;
              
              final Timestamp timestamp = data['timestamp'];
              final DateTime dateTime = timestamp.toDate();
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sender: $senderId'),
                      Text('Sender: $senderName'),
                      Text('Address: $address'),
                      Text('Phone: $phoneNumber'),
                      Text('Product: $productName'),
                      Text('Description: $description'),
                      Text('Price: ${price.toString()}'),
                      
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageURLs != null) // Check if image URLs exist
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: imageURLs.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Scaffold(
                                        appBar: AppBar(title: Text('Zoomable Image')),
                                        body: PhotoView(
                                          imageProvider: NetworkImage(imageURLs[index]),
                                          minScale: PhotoViewComputedScale.contained * 0.8,
                                          maxScale: PhotoViewComputedScale.covered * 2,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Image.network(
                                    imageURLs[index],
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to NewPage and pass the product data
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewPage(productData: data),
                              ),
                            );
                          },
                          child: Text('Details'), // Change button text to "Details"
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Sent on: ${dateTime.toString()}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Storage()), // Navigate to Storage.dart
          );
        },
        child: Icon(Icons.cloud_upload), // Add an appropriate icon
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyHomePage(),
  ));
}
