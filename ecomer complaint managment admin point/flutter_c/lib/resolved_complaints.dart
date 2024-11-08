// resolved_complaints.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'dart:convert';
import 'complaint_management.dart';
class ResolvedComplaintsPage extends StatefulWidget {
  const ResolvedComplaintsPage({super.key});

  @override
  _ResolvedComplaintsPageState createState() => _ResolvedComplaintsPageState();
}

class _ResolvedComplaintsPageState extends State<ResolvedComplaintsPage> {
  String? _selectedCategory;
  final List<String> _categories = [
    'Agriculture and Farmer Issues',
    'Water Supply and Sanitation',
    'Electricity and Power Supply',
    'Road and Transportation',
    'Ration Issues'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resolved Complaints')),
      body: Column(
        children: [
          DropdownButton<String>(
            value: _selectedCategory,
            hint: const Text('Filter by Category'),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('complaints')
                  .where('status', isEqualTo: 'Resolved')
                  .where('category', isEqualTo: _selectedCategory)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No complaints resolved.'));
                }
                final complaints = snapshot.data!.docs;
                 return ListView.builder(
                  itemCount: complaints.length,
                  itemBuilder: (context, index) {
                    final complaint = complaints[index];
                    List<dynamic> complaintImages = complaint['imageUrls'];
                    return ListTile(
                      title: Text(complaint['title']),
                      subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Category: ${complaint['category']}'),
                            Text('Description: ${complaint['description']}'),
                            Text('Status: ${complaint['status']}'),
                            Text(
                              'Submitted on: ${complaint['timestamp'] != null ? complaint['timestamp'].toDate().toString() : 'N/A'}',
                            ),
                            Row(
                              children: [
                               // Icon(
                                //  _getStatusIcon(complaint['status']),
                               //   color: _getStatusColor(complaint['status']),
                               // ),
                                const SizedBox(width: 8),
                                Text(complaint['status']),
                              ],
                            ),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: [
                                for (var image in complaintImages)
                                  SizedBox(
                                    height: 100,
                                    width: 100,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.memory(
                                        base64Decode(image.split(',').last), // Decode base64 string
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      trailing: IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          // Change status to "In Progress"
                          ComplaintManagementHelper.updateComplaintStatus(
                              complaint.id, 'In Progress');
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
