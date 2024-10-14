import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class InstagramImagePicker extends StatefulWidget {
  const InstagramImagePicker({super.key});
  @override
  State<InstagramImagePicker> createState() => _InstagramImagePickerState();
}

class _InstagramImagePickerState extends State<InstagramImagePicker> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _selectedImages = [];

  Future<void> _pickImages() async {
    // ignore: unnecessary_nullable_for_final_variable_declarations
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _selectedImages = images;
      });
    }
  }

  Future<void> _captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImages?.add(image);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Images'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: _captureImage,
          ),
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _pickImages,
          ),
        ],
      ),
      body: _selectedImages == null || _selectedImages!.isEmpty
          ? const Center(child: Text('No images selected'))
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _selectedImages!.length,
              itemBuilder: (context, index) {
                return Image.file(
                  File(_selectedImages![index].path),
                  fit: BoxFit.cover,
                );
              },
            ),
    );
  }
}
