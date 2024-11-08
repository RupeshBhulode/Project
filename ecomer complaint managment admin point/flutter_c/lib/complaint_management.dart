// complaint_management.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintManagementHelper {
  // Function to update the status of a complaint
  static Future<void> updateComplaintStatus(
      String complaintId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(complaintId)
          .update({'status': newStatus});

      print("Complaint status updated to $newStatus");
    } catch (e) {
      print("Error updating complaint status: $e");
    }
  }
}
