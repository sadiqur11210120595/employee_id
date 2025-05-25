import 'dart:convert';
import 'package:employee_id/models/employee_model.dart';

import 'package:flutter/material.dart';

class IdCardWidget extends StatelessWidget {
  final Employee employee;
  final double width;
  final double height;

  const IdCardWidget({
    super.key,
    required this.employee,
    this.width = 350,
    this.height = 220,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue, Colors.blueAccent],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              employee.companyName.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'EMPLOYEE ID CARD',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
            const Divider(color: Colors.white, height: 20),
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.memory(
                        base64Decode(employee.imageBase64),
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, error, stack) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildDetailRow('Name', employee.name),
                        _buildDetailRow('Designation', employee.designation),
                        _buildDetailRow('Phone', employee.phone),
                        _buildDetailRow('Address', employee.address),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}