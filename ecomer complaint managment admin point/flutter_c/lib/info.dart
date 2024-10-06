import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class info extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Person List'),
        backgroundColor: Colors.teal, // Teal color for the AppBar
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('people').snapshots(),
        builder: (context, snapshot) {
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

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  color: Colors.teal[50], // Light teal color for the card
                  child: ListTile(
                    title: Text(
                      doc['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[900], // Darker teal color for text
                      ),
                    ),
                    subtitle: Text('Age: ${doc['age']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PersonDetailPage(doc),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }

          return Center(
            child: Text('No data available'),
          );
        },
      ),
    );
  }
}

class PersonDetailPage extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> doc;

  const PersonDetailPage(this.doc);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doc['name']),
        backgroundColor: Colors.teal, // Teal color for the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildDetailCard('Name', doc['name']),
            _buildDetailCard('Age', doc['age'].toString()),
            _buildDetailCard('Gender', doc['gender']),
            _buildDetailCard('Caste', doc['caste']),
            _buildDetailCard('Occupation', doc['occupation']),
            _buildDetailCard('Marital Status', doc['maritalStatus']),
            if (doc['maritalStatus'] == 'Married') 
              _buildDetailCard('Spouse Name', doc['spouseName']),
            if (doc['maritalStatus'] == 'Married') 
              _buildDetailCard('Spouse Age', doc['spouseAge'].toString()),
            _buildDetailCard('Number of Children', doc['children'].length.toString()),
            if (doc['children'] != null)
              ...List.generate(
                doc['children'].length,
                (index) {
                  var child = doc['children'][index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    color: Colors.teal[100], // Light teal color for child cards
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Child ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold)),
                          _buildDetailCard('Name', child['name']),
                          _buildDetailCard('Age', child['age'].toString()),
                          _buildDetailCard('School Name', child['schoolName']),
                          _buildDetailCard('Standard', child['standard']),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String value) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.teal[100], // Light teal color for detail cards
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.teal[900], // Darker teal color for text
              ),
            ),
            Text(value),
          ],
        ),
      ),
    );
  }
}
