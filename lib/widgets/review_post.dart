// Import the necessary libraries
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_social/pages/post_preview.dart';
import 'package:quick_social/provider/post_provider.dart';
import 'package:image_cropper/image_cropper.dart';

class ReviewPostPage extends StatefulWidget {
  const ReviewPostPage({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _ReviewPostPageState();
}

class _ReviewPostPageState extends State<ReviewPostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);

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
                if (_formKey.currentState!.validate()) {
                  postProvider.setTitle(_titleController.text);
                  postProvider.setDescription(_descriptionController.text);
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const PostPreview()));
                }
              },
              child: Text(
                'Next',
                style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height * 0.022),
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.015),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildImagePreview(postProvider),
                SizedBox(height: MediaQuery.of(context).size.height * 0.010),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: 'Add a Title',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: 'Add a description',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(PostProvider postProvider) {
    return FutureBuilder<Size>(
      future: _getImageSize(File(postProvider.postUrl!.path)),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final size = snapshot.data!;
          final aspectRatio = size.width / size.height;
          return Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  double screenHeight = MediaQuery.of(context).size.height;
                  return SizedBox(
                    height: aspectRatio == 0.5625 ? screenHeight * 0.75 : null,
                    child: AspectRatio(
                      aspectRatio: aspectRatio,
                      child: Image.file(
                        File(postProvider.postUrl!.path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.010,
                right: MediaQuery.of(context).size.height * 0.010,
                child: GestureDetector(
                  onTap: () async {
                    final croppedFile =
                        await _cropImage(File(postProvider.postUrl!.path));
                    if (croppedFile != null) {
                      postProvider.setPostUrl(croppedFile);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.height * 0.040)),
                    child: Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.height * 0.008),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: MediaQuery.of(context).size.height * 0.020,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
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

  Future<File?> _cropImage(File imageFile) async {
    final ThemeData theme = Theme.of(context);
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Edit Image',
          toolbarColor: theme.colorScheme.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Edit Image',
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }
}
