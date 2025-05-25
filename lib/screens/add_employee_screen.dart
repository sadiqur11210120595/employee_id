import 'dart:convert';
import 'dart:io';
import 'package:employee_id/seirvices/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _designationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  XFile? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() => _imageFile = pickedFile);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      Fluttertoast.showToast(msg: 'Please select an image');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bytes = await _imageFile!.readAsBytes();
      final imageBase64 = base64Encode(bytes);

      await FirebaseService.addEmployee(
        name: _nameController.text.trim(),
        companyName: _companyController.text.trim(),
        designation: _designationController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        imageBase64: imageBase64,
      );

      Fluttertoast.showToast(msg: 'Employee added successfully');
      if (mounted) {
        _formKey.currentState!.reset();
        setState(() => _imageFile = null);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Employee')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: kIsWeb
                              ? Image.network(
                                  _imageFile!.path,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error),
                                )
                              : Image.file(
                                  File(_imageFile!.path),
                                  fit: BoxFit.cover,
                                ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40),
                            Text('Add Photo'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _designationController,
                decoration: const InputDecoration(
                  labelText: 'designation',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              // Repeat similar fields for company, designation, phone, address
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Save Employee'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _designationController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}