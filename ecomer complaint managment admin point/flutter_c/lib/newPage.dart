import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Storage.dart';
import 'storagetwo.dart'; 
class NewPage extends StatefulWidget {
  final Map<String, dynamic> productData;

  const NewPage({Key? key, required this.productData}) : super(key: key);

  @override
  _NewPageState createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  late TextEditingController _senderNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _productNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  String? _selectedCategory; // Variable to store the selected category
  List<String> selectedImages = [];
  List<String> categories = []; // List of categories

  @override
  void initState() {
    super.initState();
    _senderNameController = TextEditingController(text: widget.productData['senderName']);
    _addressController = TextEditingController(text: widget.productData['address']);
    _phoneNumberController = TextEditingController(text: widget.productData['phoneNumber']);
    _productNameController = TextEditingController(text: widget.productData['productName']);
    _descriptionController = TextEditingController(text: widget.productData['description']);
    _priceController = TextEditingController(text: widget.productData['price'].toString());
    _selectedCategory = widget.productData['category'] ?? null; // Initialize selected category

    // Load categories from Firestore
    _loadCategories();
  }

  @override
  void dispose() {
    _senderNameController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    _productNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('categories').get();
      final List<String> loadedCategories = [];
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

  Future<void> _addCategoryToFirestore(String newCategory) async {
    try {
      await FirebaseFirestore.instance.collection('categories').add({'name': newCategory});
    } catch (error) {
      print('Error adding category to Firestore: $error');
    }
  }

  void _addNewCategory(String newCategory) {
    setState(() {
      categories.add(newCategory);
      _selectedCategory = newCategory; // Select the newly added category
    });

    // Add the new category to Firestore
    _addCategoryToFirestore(newCategory);
  }

  Future<void> _sendDataToFirebase(Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance.collection('chut').add(data);
      // Navigate to Storage.dart and pass the selected data as arguments
    } catch (error) {
      print('Error sending data to Firebase: $error');
      // Optionally, show an error message to the user
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to send data to Firebase.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selected Product'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _senderNameController,
            decoration: InputDecoration(labelText: 'Sender Name'),
          ),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(labelText: 'Address'),
          ),
          TextFormField(
            controller: _phoneNumberController,
            decoration: InputDecoration(labelText: 'Phone Number'),
          ),
          TextFormField(
            controller: _productNameController,
            decoration: InputDecoration(labelText: 'Product Name'),
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          TextFormField(
            controller: _priceController,
            decoration: InputDecoration(labelText: 'Price'),
          ),
          SizedBox(height: 20), // Add some space between text and images
          DropdownButtonFormField<String>(
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
            decoration: InputDecoration(labelText: 'Category'),
          ),
          if (widget.productData['imageUrls'] != null) // Check if images exist
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.productData['imageUrls'].length,
                itemBuilder: (context, index) {
                  final imageUrl = widget.productData['imageUrls'][index];
                  final isSelected = selectedImages.contains(imageUrl);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedImages.remove(imageUrl);
                        } else {
                          selectedImages.add(imageUrl);
                        }
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.transparent, // Change border color if selected
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.network(
                          imageUrl,
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ElevatedButton(
            onPressed: () {
              // Create a Map with selected data
              final selectedData = {
                'sender_name': _senderNameController.text,
                'address': _addressController.text,
                'phone_number': _phoneNumberController.text,
                'product_name': _productNameController.text,
                'description': _descriptionController.text,
                'price': double.tryParse(_priceController.text) ?? 0,
                'selected_images': selectedImages,
                'category': _selectedCategory, // Include category in the data
              };
              // Send data to Firebase Firestore
              _sendDataToFirebase(selectedData);
            },
            child: Text('Send to Storage'),
          ),






          
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCategoryDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddCategoryDialog() {
    String newCategory = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Category'),
          content: TextField(
            onChanged: (value) {
              newCategory = value;
            },
            decoration: InputDecoration(hintText: 'Enter category name'),
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
                _addNewCategory(newCategory);
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
