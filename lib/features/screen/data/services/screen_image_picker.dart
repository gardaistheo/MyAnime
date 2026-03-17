import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

abstract class ScreenImagePicker {
  Future<Uint8List?> pickScreenshot();
}

class GalleryScreenImagePicker implements ScreenImagePicker {
  GalleryScreenImagePicker(this._picker);

  final ImagePicker _picker;

  @override
  Future<Uint8List?> pickScreenshot() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    return file?.readAsBytes();
  }
}
