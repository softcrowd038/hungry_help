// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:quick_social/provider/post_provider.dart';
import 'package:quick_social/widgets/review_post.dart';

class CaptureImageOrVideoPage extends StatefulWidget {
  const CaptureImageOrVideoPage({super.key});

  @override
  State<CaptureImageOrVideoPage> createState() =>
      _CaptureImageOrVideoPageState();
}

class _CaptureImageOrVideoPageState extends State<CaptureImageOrVideoPage> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  XFile? _capturedFile;
  int _selectedCameraIndex = 0;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras![_selectedCameraIndex],
      ResolutionPreset.high,
    );

    await _cameraController!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _captureImage() async {
    try {
      final XFile image = await _cameraController!.takePicture();
      final File croppedImage =
          await _cropImageToAspectRatio(File(image.path), 1 / 1);
      setState(() {
        _capturedFile = XFile(croppedImage.path);
      });

      Provider.of<PostProvider>(context, listen: false)
          .setPostUrl(File(_capturedFile!.path));
      Provider.of<PostProvider>(context, listen: false).setType('image');
      _navigateToReviewPage();
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  Future<File> _cropImageToAspectRatio(File image, double aspectRatio) async {
    final imageBytes = await image.readAsBytes();
    final originalImage = decodeImage(imageBytes);
    if (originalImage == null) {
      throw Exception('Failed to decode image');
    }

    final width = originalImage.width;
    final height = originalImage.height;

    final targetWidth = width;
    final targetHeight = (width / aspectRatio).toInt();

    final top = (height - targetHeight) ~/ 2;

    final croppedImage = copyCrop(originalImage,
        x: 0, y: top, width: targetWidth, height: targetHeight);
    final croppedFile = File('${image.path}_cropped')
      ..writeAsBytesSync(encodeJpg(croppedImage));
    return croppedFile;
  }

  void _navigateToReviewPage() {
    if (_capturedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ReviewPostPage(),
        ),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _capturedFile = pickedFile;
        });
        Provider.of<PostProvider>(context, listen: false)
            .setPostUrl(File(_capturedFile!.path));
        Provider.of<PostProvider>(context, listen: false).setType('image');
        _navigateToReviewPage();
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
    }
  }

  void _switchCamera() {
    setState(() {
      _selectedCameraIndex =
          (_selectedCameraIndex + 1) % (_cameras?.length ?? 1);
      _initializeCamera();
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        automaticallyImplyLeading: false,
      ),
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(
                  child: AspectRatio(
                    aspectRatio: _cameraController!.value.aspectRatio,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
                Positioned(
                  bottom: 20.0,
                  left: MediaQuery.of(context).size.width * 0.40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.090,
                        width: MediaQuery.of(context).size.height * 0.090,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.height * 0.090,
                          ),
                        ),
                        child: IconButton(
                          onPressed: _captureImage,
                          icon: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.height * 0.040,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      IconButton(
                        icon: Icon(
                          Icons.restart_alt_rounded,
                          color: Colors.white,
                          size: MediaQuery.of(context).size.height * 0.040,
                        ),
                        onPressed: _switchCamera,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.photo_library,
                          color: Colors.white,
                          size: MediaQuery.of(context).size.height * 0.040,
                        ),
                        onPressed: _pickFromGallery,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
