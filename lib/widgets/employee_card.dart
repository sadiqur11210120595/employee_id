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
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            RepaintBoundary(
              key: _globalKey,
              child: IdCardWidget(
                employee: widget.employee,
                width: 350, // Display size for preview
                height: 220,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _printCard,
                    icon: const Icon(Icons.print),
                    label: const Text('Print ID Card'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isDeleting ? null : _deleteEmployee,
                    icon: _isDeleting 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete, color: Colors.red),
                    label: Text(
                      _isDeleting ? 'Deleting...' : 'Delete',
                      style: const TextStyle(color: Colors.red),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}