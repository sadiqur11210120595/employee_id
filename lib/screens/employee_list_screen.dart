import 'package:employee_id/models/employee_model.dart';
import 'package:employee_id/seirvices/firebase_service.dart';
import 'package:employee_id/widgets/employee_card.dart';
import 'package:flutter/material.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  late Future<List<Employee>> _employeesFuture;

  @override
  void initState() {
    super.initState();
    _employeesFuture = FirebaseService.getEmployees();
  }

  Future<void> _refreshEmployees() async {
    setState(() {
      _employeesFuture = FirebaseService.getEmployees();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee List'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshEmployees,
        child: FutureBuilder<List<Employee>>(
          future: _employeesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No employees found'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final employee = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: EmployeeCard(
                    employee: employee,
                    onDelete: _refreshEmployees,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}