import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TextLoadPage extends StatefulWidget {
  const TextLoadPage({super.key});

  @override
  _TextLoadPageState createState() => _TextLoadPageState();
}

class _TextLoadPageState extends State<TextLoadPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Function to add text to Firestore
  Future<void> _addText() async {
    final title = _titleController.text;
    final description = _descriptionController.text;

    if (title.isEmpty || description.isEmpty) {
      // Show error if any field is empty
      return;
    }

    try {
      // Save the data to Firestore
      await FirebaseFirestore.instance.collection('texts').add({
        'title': title,
        'description': description,
        'timestamp': FieldValue.serverTimestamp(), // Optional: Add a timestamp
      });

      // Clear input fields after submitting
      _titleController.clear();
      _descriptionController.clear();

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Text Data Submitted Successfully!')),
      );
    } catch (error) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit text data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Text Information',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Title input field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),

            // Description input field
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),

            // Button to submit text data
            ElevatedButton(
              onPressed: _addText,
              child: const Text('Add Text'),
            ),
            const SizedBox(height: 40),

            const Text(
              'Submitted Text Information:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // StreamBuilder to display all the texts from Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('texts')
                    .orderBy('timestamp', descending: true) // Optional: to order by timestamp
                    .snapshots(),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading data'));
                  }

                  final textDocs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: textDocs.length,
                    itemBuilder: (ctx, index) {
                      final textData = textDocs[index].data() as Map<String, dynamic>;
                      final title = textData['title'];
                      final description = textData['description'];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Text(description),
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
      ),
    );
  }
}
