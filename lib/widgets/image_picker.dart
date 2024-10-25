// ignore_for_file: avoid_print

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
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
  int _selectedCameraIndex = 0; // To track the selected camera
  bool isVideoSelected = false; // Track selected option

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras![_selectedCameraIndex], // Use the selected camera
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
      _navigateToReviewPage();
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  Future<void> _captureVideo() async {
    try {
      await _cameraController!.startVideoRecording();
      await Future.delayed(
          const Duration(seconds: 5)); // Capture 5 seconds of video
      final XFile video = await _cameraController!.stopVideoRecording();
      setState(() {
        _capturedFile = video;
      });
      _navigateToReviewPage();
    } catch (e) {
      print('Error capturing video: $e');
    }
  }

  void _navigateToReviewPage() {
    if (_capturedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>const ReviewPage(),
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

  void _onSelect(String type) {
    setState(() {
      isVideoSelected = type == 'Video'; // Update the selection state
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
        title: const Text('Create Post'),
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
                  right: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.050,
                    width: MediaQuery.of(context).size.width * 0.40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                            MediaQuery.of(context).size.height * 0.090),
                        bottomLeft: Radius.circular(
                            MediaQuery.of(context).size.height * 0.090),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _onSelect('Post');
                          },
                          child: Text(
                            'Post',
                            style: TextStyle(
                              color: isVideoSelected
                                  ? Colors.white
                                  : Colors.yellow,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.0180,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        GestureDetector(
                          onTap: () {
                            _onSelect('Video');
                          },
                          child: Text(
                            'Video',
                            style: TextStyle(
                              color: isVideoSelected
                                  ? Colors.yellow
                                  : Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.0180,
                            ),
                          ),
                        ),
                      ],
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
                          onPressed:
                              isVideoSelected ? _captureVideo : _captureImage,
                          icon: Icon(
                            isVideoSelected
                                ? Icons.video_camera_back
                                : Icons.camera_alt,
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
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
