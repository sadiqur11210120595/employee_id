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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isSmallScreen = screenWidth < 600;
          final padding = screenWidth * 0.02;
          final imageSize = screenWidth * 0.3;
          final fontSize = screenWidth * 0.03;

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: imageSize,
                      height: imageSize,
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
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: imageSize * 0.3),
                                Text(
                                  'Add Photo',
                                  style: TextStyle(fontSize: fontSize),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: padding * 2),
                  if (isSmallScreen) ...[
                    _buildTextField(_nameController, 'Full Name', fontSize),
                    SizedBox(height: padding),
                    _buildTextField(_companyController, 'Company Name', fontSize),
                    SizedBox(height: padding),
                    _buildTextField(_designationController, 'Designation', fontSize),
                    SizedBox(height: padding),
                    _buildTextField(_phoneController, 'Phone', fontSize),
                    SizedBox(height: padding),
                    _buildTextField(_addressController, 'Address', fontSize),
                  ] else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _buildTextField(_nameController, 'Full Name', fontSize),
                              SizedBox(height: padding),
                              _buildTextField(_companyController, 'Company Name', fontSize),
                              SizedBox(height: padding),
                              _buildTextField(_designationController, 'Designation', fontSize),
                            ],
                          ),
                        ),
                        SizedBox(width: padding),
                        Expanded(
                          child: Column(
                            children: [
                              _buildTextField(_phoneController, 'Phone', fontSize),
                              SizedBox(height: padding),
                              _buildTextField(_addressController, 'Address', fontSize),
                            ],
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: padding * 2),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, screenWidth * 0.1),
                          ),
                          child: Text(
                            'Save Employee',
                            style: TextStyle(fontSize: fontSize),
                          ),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, double fontSize) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        labelStyle: TextStyle(fontSize: fontSize),
      ),
      style: TextStyle(fontSize: fontSize),
      validator: (value) => value!.isEmpty ? 'Required' : null,
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