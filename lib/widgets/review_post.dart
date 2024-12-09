// Import the necessary libraries
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_social/pages/post_preview.dart';
import 'package:quick_social/provider/post_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:image_cropper/image_cropper.dart'; // Add this import

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
  VideoPlayerController? _videoController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
  }

  void _initializeVideo(PostProvider postProvider) async {
    _videoController =
        VideoPlayerController.file(File(postProvider.postUrl!.path))
          ..initialize().then((_) {
            setState(() {});
            _videoController!.setLooping(false);
          });
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    print(postProvider.type);
    if (postProvider.type == 'video' && _videoController == null) {
      _initializeVideo(postProvider);
    }

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
                postProvider.setTitle(_titleController.text);
                postProvider.setDescription(_descriptionController.text);
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const PostPreview()));
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
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (postProvider.type == 'video')
                _buildVideoPreview(postProvider)
              else
                _buildImagePreview(postProvider),
              const SizedBox(height: 10),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: 'Add a Title',
                ),
              ),
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

  Widget _buildImagePreview(PostProvider postProvider) {
    return FutureBuilder<Size>(
      future: _getImageSize(File(postProvider.postUrl!.path)),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final size = snapshot.data!;
          final aspectRatio = size.width / size.height;
          return Column(
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
              ElevatedButton(
                onPressed: () async {
                  final croppedFile =
                      await _cropImage(File(postProvider.postUrl!.path));
                  if (croppedFile != null) {
                    // Update the post provider with the cropped image
                    postProvider.setPostUrl(croppedFile);
                  }
                },
                child: const Text('Edit Image'),
              ),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildVideoPreview(PostProvider postProvider) {
    return _videoController != null
        ? Stack(
            children: [
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.35,
                left: MediaQuery.of(context).size.width * 0.35,
                child: IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 40.0,
                    color: Colors.white,
                  ),
                  onPressed: _togglePlayPause,
                ),
              ),
            ],
          )
        : const Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    if (_videoController != null) {
      _videoController!.dispose();
    }
    super.dispose();
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
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio:const  CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Edit Image',
          toolbarColor: Colors.blue,
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
