import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'text_recognition_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  Future<void>? _initializeControllerFuture; // Make nullable
  bool _isCameraReady = false;
  final ImagePicker _picker = ImagePicker();

  // Add these class variables inside _CameraPageState
  bool _isFocusing = false;
  double _focusX = 0.5;
  double _focusY = 0.5;

  // Add this variable with other class variables
  bool _isTorchOn = false;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture =
        _initializeCamera(); // Assign future immediately
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller.initialize(); // Wait for initialization

      if (mounted) {
        setState(() {
          _isCameraReady = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing camera: $e')),
        );
      }
    }
  }

  Future<void> _captureImage(BuildContext context) async {
    if (!_isCameraReady) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Camera is not ready yet.')));
      return;
    }

    try {
      await _initializeControllerFuture;

      final XFile image = await _controller.takePicture();
      print("Image captured at: ${image.path}");

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => TextRecognitionPage(
                  imagePath: image.path,
                  imageUrl: '',
                  isFromGallery: false,
                ),
          ),
        );
      }
    } catch (e) {
      print("Error capturing image: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error capturing image: $e')));
      }
    }
  }

  Future<void> _pickImageFromGallery(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image != null) {
        print("Image selected from gallery: ${image.path}");

        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => TextRecognitionPage(
                    imagePath: image.path,
                    imageUrl: '',
                    isFromGallery: true,
                  ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('No image selected.')));
        }
      }
    } catch (e) {
      print("Error picking image from gallery: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error selecting image: $e')));
      }
    }
  }

  // Add this new method to handle focus
  Future<void> _onTapToFocus(
    TapDownDetails details,
    BoxConstraints constraints,
  ) async {
    if (!_isCameraReady || _isFocusing) return;

    _isFocusing = true;

    final double x = details.localPosition.dx / constraints.maxWidth;
    final double y = details.localPosition.dy / constraints.maxHeight;

    setState(() {
      _focusX = x;
      _focusY = y;
    });

    try {
      await _controller.setFocusPoint(Offset(x, y));
      await _controller.setExposurePoint(Offset(x, y));

      // Reset focusing state after a delay
      await Future.delayed(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Error setting focus: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isFocusing = false;
        });
      }
    }
  }

  // Add this widget to show focus indicator
  Widget _buildFocusIndicator() {
    return AnimatedOpacity(
      opacity: _isFocusing ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        height: 80,
        width: 80,
        alignment: Alignment(_focusX * 2 - 1, _focusY * 2 - 1),
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  // Modify the camera preview part in the build method
  // Replace the existing CameraPreview with this:
  Widget _buildCameraPreview() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTapDown:
              (TapDownDetails details) => _onTapToFocus(details, constraints),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AspectRatio(
                aspectRatio: 3 / 4,
                child: ClipRect(child: CameraPreview(_controller)),
              ),
              _buildFocusIndicator(),
            ],
          ),
        );
      },
    );
  }

  // Add this method to toggle torch
  Future<void> _toggleTorch() async {
    try {
      if (_isCameraReady) {
        final bool currentState =
            _controller.value.flashMode == FlashMode.torch;
        await _controller.setFlashMode(
          currentState ? FlashMode.off : FlashMode.torch,
        );
        if (mounted) {
          setState(() {
            _isTorchOn = !currentState;
          });
        }
      }
    } catch (e) {
      debugPrint('Error toggling torch: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to toggle flash')));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Status bar spacing with back button
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top,
              left: 8,
              right: 8,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Camera Preview with 3:4 portrait aspect ratio
          Expanded(
            child: Container(
              width: double.infinity,
              child: FutureBuilder<void>(
                future: _initializeControllerFuture, // Now nullable
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      _isCameraReady) {
                    return Center(child: _buildCameraPreview());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Camera initialization failed',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  }
                },
              ),
            ),
          ),

          // Control buttons
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 30.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery button
                GestureDetector(
                  onTap: () => _pickImageFromGallery(context),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.photo_library_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),

                // Capture button (camera shutter style)
                GestureDetector(
                  onTap: _isCameraReady ? () => _captureImage(context) : null,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isCameraReady ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),
                ),

                // Torch button
                GestureDetector(
                  onTap: _toggleTorch,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _isTorchOn ? Colors.amber : Colors.white,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _isTorchOn ? Icons.flash_on : Icons.flash_off,
                      color: _isTorchOn ? Colors.amber : Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
