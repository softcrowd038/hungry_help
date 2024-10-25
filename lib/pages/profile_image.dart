// ignore_for_file: avoid_print

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:quick_social/provider/profile_data_provider.dart';
import 'dart:io';
import 'profile_data_page.dart';

class ProfileImagePage extends StatefulWidget {
  const ProfileImagePage({super.key});

  @override
  State<ProfileImagePage> createState() => _ProfileImagePage();
}

class _ProfileImagePage extends State<ProfileImagePage> {
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
      setState(() {
        _capturedFile = image;
      });
      _saveImageToProvider(File(_capturedFile!.path));
    } catch (e) {
      print('Error capturing image: $e');
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
        _saveImageToProvider(File(_capturedFile!.path));
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
    }
  }

  void _saveImageToProvider(File imageFile) {
    final userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    userProfileProvider.setProfileImage(imageFile);
    _navigateToReviewPage();
  }

  void _navigateToReviewPage() {
    if (_capturedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileDataPage(),
        ),
      );
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
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Capture Image',
              style: TextStyle(color: Colors.white),
            ),
            TextButton(
              onPressed: () {
                _navigateToReviewPage();
              },
              child: Text(
                'Next',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.height * 0.022,
                ),
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(
                  child: CameraPreview(_cameraController!),
                ),
                Positioned(
                  bottom: 100.0,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.050,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                            MediaQuery.of(context).size.height * 0.090),
                        bottomLeft: Radius.circular(
                            MediaQuery.of(context).size.height * 0.090),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Either Capture or Choose image from gallery',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.height * 0.0180,
                        ),
                      ),
                    ),
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
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(
                            MediaQuery.of(context).size.height * 0.090,
                          ),
                        ),
                        child: IconButton(
                          onPressed: _captureImage,
                          icon: Icon(
                            Icons.camera_alt,
                            color: const Color.fromARGB(255, 255, 255, 255),
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
                      const SizedBox(width: 10.0),
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
