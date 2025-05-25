import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:employee_id/models/employee_model.dart';


class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<Employee>> getEmployees() async {
    try {
      final querySnapshot = await _firestore.collection('employees')
        .orderBy('createdAt', descending: true)
        .get();
      return querySnapshot.docs
          .map((doc) => Employee.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch employees: $e');
    }
  }

  static Future<void> addEmployee({
    required String name,
    required String companyName,
    required String designation,
    required String phone,
    required String address,
    required String imageBase64,
  }) async {
    try {
      await _firestore.collection('employees').add({
        'name': name,
        'companyName': companyName,
        'designation': designation,
        'phone': phone,
        'address': address,
        'imageBase64': imageBase64,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add employee: $e');
    }
  }

  static Future<void> deleteEmployee(String id) async {
    await _firestore.collection('employees').doc(id).delete();
  }
}