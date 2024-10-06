import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyCallsPage extends StatefulWidget {
  const EmergencyCallsPage({Key? key}) : super(key: key);

  @override
  _EmergencyCallsPageState createState() => _EmergencyCallsPageState();
}

class _EmergencyCallsPageState extends State<EmergencyCallsPage> {
  late Stream<QuerySnapshot> _emergencyServicesStream;
  String _searchQuery = '';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emergencyServicesStream = FirebaseFirestore.instance.collection('emergency_services').snapshots();
  }

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery;
    });
  }

  void _addEmergencyService(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Emergency Service'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: _emailController,
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
                _saveEmergencyService();
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveEmergencyService() async {
    await FirebaseFirestore.instance.collection('emergency_services').add({
      'name': _nameController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
    });
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
  }

  void _makeCall(String phoneNumber) async {
    String url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _sendEmail(String emailAddress) async {
    String url = 'mailto:$emailAddress';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Calls'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _emergencyServicesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final List<DocumentSnapshot> documents = snapshot.data!.docs;
                List<Map<String, dynamic>> _filteredServices = documents.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return {
                    'id': doc.id,
                    'name': data['name'],
                    'phone': data['phone'],
                    'email': data['email'],
                  };
                }).toList();

                if (_searchQuery.isNotEmpty) {
                  _filteredServices = _filteredServices.where((service) {
                    return service['name'].toLowerCase().contains(_searchQuery.toLowerCase());
                  }).toList();
                }

                return ListView.builder(
  itemCount: _filteredServices.length,
  itemBuilder: (context, index) {
    var service = _filteredServices[index];
    return ListTile(
      title: Text(service['name']),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Phone: ${service['phone']}'),
              ),
              IconButton(
                icon: Icon(Icons.phone),
                onPressed: () {
                  _makeCall(service['phone']);
                },
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text('Email: ${service['email']}'),
              ),
              IconButton(
                icon: Icon(Icons.email),
                onPressed: () {
                  _sendEmail(service['email']);
                },
              ),
            ],
          ),
        ],
      ),
      onTap: () {
        // Action for tapping the list item
      },
      onLongPress: () {
        // Action for long-pressing the list item
      },
    );
  },
);

              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addEmergencyService(context),
        child: Icon(Icons.add),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(home: EmergencyCallsPage()));
}
