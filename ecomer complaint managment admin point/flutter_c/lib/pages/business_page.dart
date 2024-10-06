import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class BusinessPage extends StatefulWidget {
  const BusinessPage({Key? key}) : super(key: key);

  @override
  _BusinessPageState createState() => _BusinessPageState();
}

class _BusinessPageState extends State<BusinessPage> {
  late Stream<QuerySnapshot> _businessStoresStream;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<String> _categories = [
    'Grocery, Supermarket',
    'Watches, Jewelry, Eyewear',
    'Hypermarket, Supermarket',
    'Coffee Shop, Cafe',
    'Footwear, Accessories',
  ];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _businessStoresStream = FirebaseFirestore.instance.collection('business_stores').snapshots();
    _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
  }
  Future<void> _addBusinessStore(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Business Store'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Store Name'),
                ),
                TextFormField(
                  controller: _ownerController,
                  decoration: InputDecoration(labelText: 'Owner'),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  items: _categories.map((category) => DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  )).toList(),
                  decoration: InputDecoration(labelText: 'Category'),
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Phone No'),
                ),
              ],
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
              onPressed: () async {
                _saveBusinessStore();
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveBusinessStore() async {
    await FirebaseFirestore.instance.collection('business_stores').add({
      'storeName': _nameController.text,
      'owner': _ownerController.text,
      'category': _selectedCategory,
      'address': _addressController.text,
      'phoneNo': _phoneController.text,
    });
    _nameController.clear();
    _ownerController.clear();
    _addressController.clear();
    _phoneController.clear();
  }

  Future<void> _launchMaps(String address) async {
    String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  void _makeCall(String phoneNumber) async {
    String url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _addCategory(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newCategory = '';
        return AlertDialog(
          title: Text('Add Category'),
          content: TextField(
            onChanged: (value) {
              newCategory = value;
            },
            decoration: InputDecoration(labelText: 'Category Name'),
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
                if (newCategory.isNotEmpty) {
                  setState(() {
                    _categories.add(newCategory);
                    _selectedCategory = newCategory;
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Business Stores'),
        actions: [
          IconButton(
            onPressed: () => _addCategory(context),
            icon: Icon(Icons.add),
            tooltip: 'Add Category',
          ),
          DropdownButton<String>(
            value: _selectedCategory,
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue;
              });
            },
            items: ['All', ..._categories].map((String? category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category ?? 'All'),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _selectedCategory == null || _selectedCategory == 'All'
                  ? _businessStoresStream
                  : FirebaseFirestore.instance
                  .collection('business_stores')
                  .where('category', isEqualTo: _selectedCategory)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                final List<DocumentSnapshot> documents = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    var store = documents[index];
                    return Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(store['storeName']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Owner: ${store['owner']}'),
                            Text('Category: ${store['category']}'),
                            Row(
                              children: [
                                Expanded(child: Text('Address: ${store['address']}')),
                                IconButton(
                                  icon: Icon(Icons.location_on),
                                  onPressed: () {
                                    _launchMaps(store['address']);
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text('Phone: ${store['phoneNo']}'),
                                IconButton(
                                  icon: Icon(Icons.phone),
                                  onPressed: () {
                                    _makeCall(store['phoneNo']);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addBusinessStore(context),
        child: Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: BusinessPage()));
}
