import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class CameraService {
  CameraController? _controller;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );

  CameraController? get controller => _controller;

  Future<void> initialize() async {
    try {
      final cameras = await availableCameras();
      final front = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => throw 'No front camera found',
      );

      _controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
    } catch (e) {
      throw 'Failed to initialize camera: $e';
    }
  }

  // Fungsi untuk mengonversi gambar menjadi Base64
  Future<String> convertToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      throw 'Failed to convert image to Base64: $e';
    }
  }

  Future<File?> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw 'Camera not initialized';
    }

    try {
      // Ambil gambar dari kamera
      final XFile picture = await _controller!.takePicture();

      // Deteksi wajah pada gambar
      final inputImage = InputImage.fromFilePath(picture.path);
      final faces = await _faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        throw 'No face detected. Please try again.';
      }
      if (faces.length > 1) {
        throw 'Multiple faces detected. Ensure only one face is in the frame.';
      }

      // Simpan gambar ke direktori sementara
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'attendance_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = File(path.join(tempDir.path, fileName));
      await File(picture.path).copy(savedImage.path);

      // Kembalikan file yang telah disimpan
      return savedImage;
    } catch (e) {
      throw 'Error taking picture: $e';
    }
  }

  // Fungsi tambahan untuk mengambil gambar dan mengonversinya ke Base64
  Future<String> takePictureAndConvertToBase64() async {
    final file = await takePicture();
    if (file == null) {
      throw 'Failed to take picture';
    }
    return convertToBase64(file);
  }

  void dispose() {
    _controller?.dispose();
    _faceDetector.close();
  }
}
