import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ocr_service_stub.dart';

class OcrService {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> requestGalleryPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted || status.isLimited;
  }

  Future<File?> pickFromCamera() async {
    final granted = await requestCameraPermission();
    if (!granted) return null;

    try {
      final xFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
      );
      return xFile != null ? File(xFile.path) : null;
    } catch (_) {
      return null;
    }
  }

  Future<File?> pickFromGallery() async {
    final granted = await requestGalleryPermission();
    if (!granted) return null;

    try {
      final xFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      return xFile != null ? File(xFile.path) : null;
    } catch (_) {
      return null;
    }
  }

  Future<File?> cropImage(File imageFile) async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 95,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Prescription',
          toolbarColor: const Color(0xFF1565C0),
          toolbarWidgetColor: const Color(0xFFFFFFFF),
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Prescription',
          minimumAspectRatio: 1.0,
        ),
      ],
    );

    return cropped != null ? File(cropped.path) : null;
  }

  Future<OcrResult> extractText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);

    try {
      final recognizedText = await _textRecognizer.processImage(inputImage);
      if (recognizedText.text.trim().isEmpty) {
        return OcrResult.failure('No text detected in the image.');
      }
      return OcrResult.success(recognizedText.text);
    } catch (e) {
      return OcrResult.failure('OCR failed: $e');
    }
  }

  Future<OcrResult> scanPrescription({required bool fromCamera}) async {
    File? imageFile =
        fromCamera ? await pickFromCamera() : await pickFromGallery();
    if (imageFile == null) return OcrResult.failure('No image selected.');

    final cropped = await cropImage(imageFile);
    if (cropped != null) imageFile = cropped;

    return extractText(imageFile);
  }

  void dispose() {
    _textRecognizer.close();
  }
}
