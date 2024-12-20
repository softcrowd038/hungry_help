import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_social/pages/add_meal_details.dart';
import 'package:quick_social/provider/donor_data_provider.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final donorProfileProvider = Provider.of<DonorDataProvider>(context);

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
                if (_descriptionController.text.trim().isEmpty) {
                  _showSnackBar('Description cannot be empty.');
                  return;
                }

                if (donorProfileProvider.imageurl == null) {
                  _showSnackBar(
                      'No image selected. Please go back and add an image.');
                  return;
                }

                donorProfileProvider
                    .setDescription(_descriptionController.text);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddMealDetails(),
                  ),
                );
              },
              child: Text(
                'Next',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.height * 0.022,
                ),
              ),
            )
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
                  EdgeInsets.all(MediaQuery.of(context).size.height * 0.015),
              child: TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(),
                  hintText: 'Add a description',
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (donorProfileProvider.imageurl != null)
              FutureBuilder<Size>(
                future:
                    _getImageSize(File(donorProfileProvider.imageurl!.path)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'Failed to load image.',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (snapshot.hasData) {
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
                              File(donorProfileProvider.imageurl!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Text(
                        'No image available.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                },
              )
            else
              const Center(
                child: Text(
                  'No image selected.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<Size> _getImageSize(File imageFile) async {
    try {
      final completer = Completer<Size>();
      final image = Image.file(imageFile);
      image.image.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          completer.complete(
            Size(info.image.width.toDouble(), info.image.height.toDouble()),
          );
        }),
      );
      return completer.future;
    } catch (e) {
      throw Exception('Failed to get image size: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
