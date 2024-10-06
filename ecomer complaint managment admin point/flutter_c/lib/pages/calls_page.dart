import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CallsPage extends StatefulWidget {
  const CallsPage({Key? key}) : super(key: key);

  @override
  _CallsPageState createState() => _CallsPageState();
}

class _CallsPageState extends State<CallsPage> {
  late Stream<QuerySnapshot> _peopleStream;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _peopleStream = FirebaseFirestore.instance.collection('peopleuu').snapshots();
  }

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
    });
  }

  void _showAddPersonDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController designationController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Person'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: designationController,
                decoration: InputDecoration(labelText: 'Designation'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ],
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
                // Add person to Firestore
                FirebaseFirestore.instance.collection('peopleuu').add({
                  'name': nameController.text,
                  'designation': designationController.text,
                  'phone': phoneController.text,
                  'email': emailController.text,
                });
                Navigator.of(context).pop();
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
        title: const Text('Calls'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) => _updateSearchQuery(value),
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _peopleStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final List<DocumentSnapshot> documents = snapshot.data!.docs;
                List<Map<String, dynamic>> _filteredPeople = documents.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return {
                    'name': data['name'],
                    'designation': data['designation'],
                    'phone': data['phone'],
                    'email': data['email'],
                  };
                }).toList();

                if (_searchQuery.isNotEmpty) {
                  _filteredPeople = _filteredPeople.where((person) {
                    return person['name']!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        person['designation']!.toLowerCase().contains(_searchQuery.toLowerCase());
                  }).toList();
                }

                return ListView.builder(
                  itemCount: _filteredPeople.length,
                  itemBuilder: (context, index) {
                    var person = _filteredPeople[index];
                    return Card(
                      child: ListTile(
                        title: Text(person['name']!),
                        subtitle: Text('${person['designation']} - ${person['phone']}'),
                        trailing: Text(person['email']!),
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
        onPressed: () => _showAddPersonDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: CallsPage()));
}
