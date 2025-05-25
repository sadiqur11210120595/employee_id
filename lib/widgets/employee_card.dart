import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:employee_id/models/employee_model.dart';
import 'package:employee_id/widgets/id_card_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class EmployeeCard extends StatefulWidget {
  final Employee employee;
  
  const EmployeeCard({super.key, required this.employee});

  @override
  State<EmployeeCard> createState() => _EmployeeCardState();
}

class _EmployeeCardState extends State<EmployeeCard> {
  final GlobalKey _globalKey = GlobalKey();

  Future<void> _printCard() async {
    try {
      // Add slight delay to ensure widget is rendered
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Capture the widget as an image
      final RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List imageBytes = byteData!.buffer.asUint8List();

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) => _generatePdf(imageBytes, format),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Printing failed: ${e.toString()}')),
        );
      }
    }
  }

  Future<Uint8List> _generatePdf(Uint8List imageBytes, PdfPageFormat format) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Image(
              pw.MemoryImage(imageBytes),
              fit: pw.BoxFit.contain,
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
              child: IdCardWidget(employee: widget.employee),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _printCard,
              icon: const Icon(Icons.print),
              label: const Text('Print ID Card'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}