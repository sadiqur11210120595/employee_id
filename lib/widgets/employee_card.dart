import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:employee_id/models/employee_model.dart';
import 'package:employee_id/widgets/id_card_widget.dart';
import 'package:employee_id/seirvices/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EmployeeCard extends StatefulWidget {
  final Employee employee;
  final VoidCallback onDelete;
  
  const EmployeeCard({
    super.key, 
    required this.employee,
    required this.onDelete,
  });

  @override
  State<EmployeeCard> createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<EmployeeCard> {
  final GlobalKey _globalKey = GlobalKey();
  bool _isDeleting = false;

  // Standard ID card size in mm (CR-80)
  static const double idCardWidth = 85.6;
  static const double idCardHeight = 53.98;

  Future<void> _printCard() async {
    try {
      // Add slight delay to ensure widget is rendered
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Capture the widget as an image
      final RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List imageBytes = byteData!.buffer.asUint8List();

      // Create custom page format for ID card size
      final customFormat = PdfPageFormat(
        idCardWidth * PdfPageFormat.mm,
        idCardHeight * PdfPageFormat.mm,
        marginAll: 0,
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) => _generatePdf(imageBytes, customFormat),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Printing failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteEmployee() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: const Text('Are you sure you want to delete this employee?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isDeleting = true);
      try {
        await FirebaseService.deleteEmployee(widget.employee.id);
        Fluttertoast.showToast(msg: 'Employee deleted successfully');
        widget.onDelete();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isDeleting = false);
        }
      }
    }
  }

  Future<Uint8List> _generatePdf(Uint8List imageBytes, PdfPageFormat format) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Container(
            width: format.width,
            height: format.height,
            child: pw.Image(
              pw.MemoryImage(imageBytes),
              fit: pw.BoxFit.cover,
            ),
          );
        },
      ),
    );
    
    return pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenWidth < 600;
        
        return Card(
          elevation: 4,
          margin: EdgeInsets.all(screenWidth * 0.02),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Column(
              children: [
                RepaintBoundary(
                  key: _globalKey,
                  child: IdCardWidget(
                    employee: widget.employee,
                    width: screenWidth * 0.9,
                    height: screenWidth * 0.6,
                  ),
                ),
                SizedBox(height: screenWidth * 0.04),
                isSmallScreen
                    ? Column(
                        children: [
                          _buildButton(
                            onPressed: _printCard,
                            icon: Icons.print,
                            label: 'Print ID Card',
                            screenWidth: screenWidth,
                          ),
                          SizedBox(height: screenWidth * 0.02),
                          _buildButton(
                            onPressed: _isDeleting ? null : _deleteEmployee,
                            icon: _isDeleting ? null : Icons.delete,
                            label: _isDeleting ? 'Deleting...' : 'Delete',
                            screenWidth: screenWidth,
                            isDelete: true,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _buildButton(
                              onPressed: _printCard,
                              icon: Icons.print,
                              label: 'Print ID Card',
                              screenWidth: screenWidth,
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Expanded(
                            child: _buildButton(
                              onPressed: _isDeleting ? null : _deleteEmployee,
                              icon: _isDeleting ? null : Icons.delete,
                              label: _isDeleting ? 'Deleting...' : 'Delete',
                              screenWidth: screenWidth,
                              isDelete: true,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton({
    required VoidCallback? onPressed,
    IconData? icon,
    required String label,
    required double screenWidth,
    bool isDelete = false,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null
          ? Icon(icon, color: isDelete ? Colors.red : null)
          : SizedBox(
              width: screenWidth * 0.04,
              height: screenWidth * 0.04,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
      label: Text(
        label,
        style: TextStyle(
          color: isDelete ? Colors.red : null,
          fontSize: screenWidth * 0.03,
        ),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(double.infinity, screenWidth * 0.1),
        backgroundColor: isDelete ? Colors.white : null,
        foregroundColor: isDelete ? Colors.red : null,
      ),
    );
  }
}