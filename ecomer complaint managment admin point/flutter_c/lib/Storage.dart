import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view.dart';

class Storage extends StatefulWidget {
  @override
  _StorageState createState() => _StorageState();
}

class _StorageState extends State<Storage> {
  String? _selectedCategory; // Variable to store the selected category
  String _searchQuery = ''; // Variable to store the search query
  List<String> categories = ['All']; // List of categories including "All"

  @override
  void initState() {
    super.initState();
    // Load categories from Firestore
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('categories').get();
      final List<String> loadedCategories = ['All']; // Include "All" option
      snapshot.docs.forEach((doc) {
        loadedCategories.add(doc['name']);
      });
      setState(() {
        categories = loadedCategories;
      });
    } catch (error) {
      print('Error loading categories: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Storage Page'),
        actions: [
          DropdownButton<String>(
            value: _selectedCategory,
            items: categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _selectedCategory = null;
                _searchQuery = '';
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chut').snapshots(),
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
          if (documents.isEmpty) {
            return Center(
              child: Text('No data available.'),
            );
          }
          // Filter documents based on selected category and search query
          final filteredDocuments = documents.where((document) {
            final chutData = document.data() as Map<String, dynamic>;
            final categoryMatch = _selectedCategory == null || _selectedCategory == 'All' || _selectedCategory == chutData['category'];
            final searchMatch = chutData['product_name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
            return categoryMatch && searchMatch;
          }).toList();
          return ListView.builder(
            itemCount: filteredDocuments.length,
            itemBuilder: (BuildContext context, int index) {
              final Map<String, dynamic> chutData = filteredDocuments[index].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sender: ${chutData['sender_name']}'),
                      Text('Address: ${chutData['address']}'),
                      Text('Phone: ${chutData['phone_number']}'),
                      Text('Product: ${chutData['product_name']}'),
                      Text('Description: ${chutData['description']}'),
                      Text('Price: ${chutData['price']}'),
                      Text('Category: ${chutData['category'] ?? 'Not specified'}'), // Display category
                      SizedBox(height: 20),
                      Text('Selected Images:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      if (chutData['selected_images'] != null)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                            chutData['selected_images'].length,
                            (index) => GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => _buildPhotoView(chutData['selected_images'][index]),
                                  ),
                                );
                              },
                              child: Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Image.network(
                                  chutData['selected_images'][index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Button to delete the product
                      ElevatedButton(
                        onPressed: () {
                          _showDeleteConfirmationDialog(filteredDocuments[index].id);
                        },
                        child: Text('Delete Product'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPhotoView(String imageUrl) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 2,
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search by Product Name'),
          content: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Enter product name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Product'),
          content: Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteProduct(documentId);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteProduct(String documentId) async {
    try {
      await FirebaseFirestore.instance.collection('chut').doc(documentId).delete();
      // Optionally, you can show a confirmation message here
    } catch (error) {
      print('Error deleting product: $error');
      // Optionally, you can show an error message here
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: Storage(),
  ));
}
