import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraService {
  CameraController? _controller;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );

  Future<void> initialize() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _controller = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize();
  }

  Future<File?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw 'Camera not initialized';
    }

    // Take picture
    final XFile picture = await _controller!.takePicture();

    // Detect faces
    final inputImage = InputImage.fromFilePath(picture.path);
    final faces = await _faceDetector.processImage(inputImage);

    // Verify one face is detected
    if (faces.isEmpty) {
      throw 'No face detected';
    }
    if (faces.length > 1) {
      throw 'Multiple faces detected';
    }

    // Save image to temporary directory
    final tempDir = await getTemporaryDirectory();
    final fileName = 'attendance_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedImage = File(path.join(tempDir.path, fileName));
    await File(picture.path).copy(savedImage.path);

    return savedImage;
  }

  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
  }
}