import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReviewPage extends StatefulWidget {
  final XFile? mediaFile;
  const ReviewPage({Key? key, required this.mediaFile}) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TextEditingController _descriptionController = TextEditingController();

  void _submitToDatabase() {
    final String description = _descriptionController.text;
    final File media = File(widget.mediaFile!.path);

    // Simulate database submission logic here
    print('Submitted to database');
    print('Description: $description');
    print('Media Path: ${media.path}');

    // Once submitted, show a confirmation or return to the home page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post submitted!')),
    );

    // Optionally, navigate back to the main page
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review & Post')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: widget.mediaFile!.path.contains('.mp4')
                  ? Center(
                      child: Text('Video Captured: ${widget.mediaFile!.name}'),
                    )
                  : Image.file(
                      File(widget.mediaFile!.path),
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Add a description',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitToDatabase,
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
