import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ImagePickerWidget extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onPickImage;

  const ImagePickerWidget({
    super.key,
    required this.imageFile,
    required this.onPickImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (imageFile != null)
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: kIsWeb
                  ? Image.network(
                      imageFile!.path,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                    )
                  : Image.file(
                      imageFile!,
                      fit: BoxFit.cover,
                    ),
            ),
          )
        else
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person, size: 60, color: Colors.grey),
          ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: onPickImage,
          child: const Text('Upload Photo'),
        ),
      ],
    );
  }
}