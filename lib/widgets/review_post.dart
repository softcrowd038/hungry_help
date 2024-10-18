import 'dart:io';
import 'dart:async'; // For Completer
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quick_social/pages/add_meal_details.dart';

class ReviewPage extends StatefulWidget {
  final XFile? mediaFile;
  const ReviewPage({super.key, required this.mediaFile});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Add description',
              style: TextStyle(color: Colors.black),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AddMealDetails(
                        mediaFile: widget.mediaFile,
                        description: _descriptionController.text)));
              },
              child: Text(
                'Next',
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height * 0.022),
              ),
            )
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              FutureBuilder<Size>(
                future: _getImageSize(File(widget.mediaFile!.path)),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final size = snapshot.data!;
                    final aspectRatio = size.width / size.height;
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        double screenHeight =
                            MediaQuery.of(context).size.height;

                        return SizedBox(
                          height: aspectRatio == 0.5625
                              ? screenHeight * 0.75
                              : null,
                          child: AspectRatio(
                            aspectRatio: aspectRatio,
                            child: Image.file(
                              File(widget.mediaFile!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: 'Add a description',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Size> _getImageSize(File imageFile) async {
    final completer = Completer<Size>();
    final image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(
            Size(info.image.width.toDouble(), info.image.height.toDouble()));
      }),
    );
    return completer.future;
  }
}
