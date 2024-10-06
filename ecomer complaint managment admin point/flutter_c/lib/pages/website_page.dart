import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class WebsitePage extends StatefulWidget {
  const WebsitePage({Key? key}) : super(key: key);

  @override
  _WebsitePageState createState() => _WebsitePageState();
}

class _WebsitePageState extends State<WebsitePage> {
  late Stream<QuerySnapshot> _businessStoresStream;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ownerController = TextEditingController();

  final TextEditingController _searchController = TextEditingController();
  List<String> _categories = [
    'Men',
    'Women',
    'Child',
    'Others',
  ];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _businessStoresStream = FirebaseFirestore.instance.collection('bola').snapshots();
    _selectedCategory = _categories.isNotEmpty ? _categories.first : null;
  }

  Future<void> _addBusinessStore(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Yojan Names'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Yojna Name'),
                ),
                TextFormField(
                  controller: _ownerController,
                  decoration: InputDecoration(labelText: 'Website link'),
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
    await FirebaseFirestore.instance.collection('bola').add({
      'storeName': _nameController.text,
      'owner': _ownerController.text,
      'category': _selectedCategory,
    });
    _nameController.clear();
    _ownerController.clear();
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
        title: Text('Yojan Names'),
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
                  : FirebaseFirestore.instance.collection('bola').where('category', isEqualTo: _selectedCategory).snapshots(),
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
    title: Text('Yojan Name: ${store['storeName']}'),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (store['owner'] != null && store['owner'].isNotEmpty) // Add this condition
          GestureDetector(
            onTap: () async {
              String url = store['owner'];
              if (await canLaunch(url)) {
                await launch(url);
              } else {
                throw 'Could not launch $url';
              }
            },
            child: Text(
              '${store['owner']}',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        Text('Category: ${store['category']}'),
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
  runApp(MaterialApp(home: WebsitePage()));
}
