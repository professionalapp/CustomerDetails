import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CloudinaryService {
  static const String cloudName = 'dnx3ypscu';
  static const String uploadPreset = 'imgupload';

  // Firebase instances
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// اختيار صورة من الاستديو
  static Future<XFile?> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw 'خطأ في اختيار الصورة من الاستديو: $e';
    }
  }

  /// اختيار صورة من الكاميرا
  static Future<XFile?> pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw 'خطأ في اختيار الصورة من الكاميرا: $e';
    }
  }

  /// اختيار صورة من الكاميرا أو الاستديو
  static Future<XFile?> pickImageFromCameraOrGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      // إذا فشل من الكاميرا، جرب الاستديو
      try {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );
        return image;
      } catch (e2) {
        throw 'خطأ في اختيار الصورة: $e2';
      }
    }
  }

  /// اختيار عدة صور من الاستديو
  static Future<List<XFile>> pickMultipleImagesFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return images;
    } catch (e) {
      throw 'خطأ في اختيار الصور من الاستديو: $e';
    }
  }

  /// رفع صورة واحدة إلى Cloudinary
  static Future<String?> uploadImageToCloudinary(
    XFile imageFile, {
    String? folder,
    String? publicId,
  }) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder ?? 'employees';

      if (publicId != null) {
        request.fields['public_id'] = publicId;
      }

      // Handle different platforms
      if (kIsWeb) {
        // For web platform
        try {
          if (imageFile.path.isEmpty) {
            throw 'الملف غير صالح أو تم إلغاؤه';
          }

          final bytes = await imageFile.readAsBytes();

          if (bytes.isEmpty) {
            throw 'الملف فارغ أو لا يمكن قراءته';
          }

          final multipartFile = http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: imageFile.name.isNotEmpty
                ? imageFile.name
                : 'image_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );
          request.files.add(multipartFile);
        } catch (e) {
          throw 'خطأ في قراءة الملف: $e';
        }
      } else {
        // For mobile platforms
        final file = await http.MultipartFile.fromPath('file', imageFile.path);
        request.files.add(file);
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseData);
        return data['secure_url'];
      } else {
        throw 'فشل في رفع الصورة: ${response.statusCode} - $responseData';
      }
    } catch (e) {
      throw 'فشل في رفع الصورة إلى Cloudinary: $e';
    }
  }

  /// رفع عدة صور إلى Cloudinary
  static Future<List<String>> uploadMultipleImagesToCloudinary(
    List<XFile> imageFiles, {
    String? folder,
  }) async {
    List<String> uploadedUrls = [];

    for (XFile imageFile in imageFiles) {
      try {
        final url = await uploadImageToCloudinary(imageFile, folder: folder);
        if (url != null) {
          uploadedUrls.add(url);
        }
      } catch (e) {
        print('خطأ في رفع صورة: $e');
        // يمكن إضافة معالجة إضافية للأخطاء هنا
      }
    }

    return uploadedUrls;
  }

  /// حفظ رابط الصورة في Firebase Firestore
  static Future<void> saveImageUrlToFirestore({
    required String imageUrl,
    required String collectionName,
    required String documentId,
    String? fieldName,
  }) async {
    try {
      final Map<String, dynamic> data = {
        fieldName ?? 'imageUrl': imageUrl,
        'uploadedAt': FieldValue.serverTimestamp(),
        'source': 'cloudinary',
      };

      await _firestore
          .collection(collectionName)
          .doc(documentId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw 'فشل في حفظ رابط الصورة في Firebase: $e';
    }
  }

  /// حفظ عدة روابط صور في Firebase Firestore
  static Future<void> saveMultipleImageUrlsToFirestore({
    required List<String> imageUrls,
    required String collectionName,
    required String documentId,
    String? fieldName,
  }) async {
    try {
      final Map<String, dynamic> data = {
        fieldName ?? 'imageUrls': imageUrls,
        'uploadedAt': FieldValue.serverTimestamp(),
        'source': 'cloudinary',
        'imageCount': imageUrls.length,
      };

      await _firestore
          .collection(collectionName)
          .doc(documentId)
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw 'فشل في حفظ روابط الصور في Firebase: $e';
    }
  }

  /// رفع صورة وحفظ الرابط في Firebase (عملية متكاملة)
  static Future<String?> uploadAndSaveToFirebase({
    required XFile imageFile,
    required String collectionName,
    required String documentId,
    String? folder,
    String? fieldName,
  }) async {
    try {
      // رفع الصورة إلى Cloudinary
      final String? imageUrl = await uploadImageToCloudinary(
        imageFile,
        folder: folder,
      );

      if (imageUrl != null) {
        // حفظ الرابط في Firebase
        await saveImageUrlToFirestore(
          imageUrl: imageUrl,
          collectionName: collectionName,
          documentId: documentId,
          fieldName: fieldName,
        );
      }

      return imageUrl;
    } catch (e) {
      throw 'فشل في رفع الصورة وحفظها: $e';
    }
  }

  /// رفع عدة صور وحفظ الروابط في Firebase (عملية متكاملة)
  static Future<List<String>> uploadMultipleAndSaveToFirebase({
    required List<XFile> imageFiles,
    required String collectionName,
    required String documentId,
    String? folder,
    String? fieldName,
  }) async {
    try {
      // رفع الصور إلى Cloudinary
      final List<String> imageUrls = await uploadMultipleImagesToCloudinary(
        imageFiles,
        folder: folder,
      );

      if (imageUrls.isNotEmpty) {
        // حفظ الروابط في Firebase
        await saveMultipleImageUrlsToFirestore(
          imageUrls: imageUrls,
          collectionName: collectionName,
          documentId: documentId,
          fieldName: fieldName,
        );
      }

      return imageUrls;
    } catch (e) {
      throw 'فشل في رفع الصور وحفظها: $e';
    }
  }

  /// حذف صورة من Cloudinary (اختياري)
  static Future<bool> deleteImageFromCloudinary(String publicId) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/destroy',
      );

      final response = await http.post(
        uri,
        body: {'public_id': publicId, 'upload_preset': uploadPreset},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['result'] == 'ok';
      }
      return false;
    } catch (e) {
      print('خطأ في حذف الصورة: $e');
      return false;
    }
  }

  /// حذف رابط الصورة من Firebase
  static Future<void> deleteImageUrlFromFirestore({
    required String collectionName,
    required String documentId,
    String? fieldName,
  }) async {
    try {
      final Map<String, dynamic> data = {
        fieldName ?? 'imageUrl': FieldValue.delete(),
        'deletedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection(collectionName).doc(documentId).update(data);
    } catch (e) {
      throw 'فشل في حذف رابط الصورة من Firebase: $e';
    }
  }

  /// حذف عدة روابط صور من Firebase
  static Future<void> deleteMultipleImageUrlsFromFirestore({
    required String collectionName,
    required String documentId,
    String? fieldName,
  }) async {
    try {
      final Map<String, dynamic> data = {
        fieldName ?? 'imageUrls': FieldValue.delete(),
        'deletedAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection(collectionName).doc(documentId).update(data);
    } catch (e) {
      throw 'فشل في حذف روابط الصور من Firebase: $e';
    }
  }

  /// حذف صورة من Cloudinary و Firebase
  static Future<bool> deleteImageCompletely({
    required String imageUrl,
    required String collectionName,
    required String documentId,
    String? fieldName,
  }) async {
    try {
      // استخراج public_id من URL
      final Uri uri = Uri.parse(imageUrl);
      final String publicId = uri.pathSegments.last.split('.').first;

      // حذف من Cloudinary
      final bool cloudinaryDeleted = await deleteImageFromCloudinary(publicId);

      // حذف من Firebase
      await deleteImageUrlFromFirestore(
        collectionName: collectionName,
        documentId: documentId,
        fieldName: fieldName,
      );

      return cloudinaryDeleted;
    } catch (e) {
      print('خطأ في حذف الصورة بالكامل: $e');
      return false;
    }
  }

  /// جلب الصور من Firebase
  static Future<List<String>> getImagesFromFirebase({
    required String collectionName,
    required String documentId,
    String? fieldName,
  }) async {
    try {
      final doc = await _firestore
          .collection(collectionName)
          .doc(documentId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        final field = fieldName ?? 'imageUrls';

        if (data[field] is List) {
          return List<String>.from(data[field]);
        } else if (data[field] is String) {
          return [data[field]];
        }
      }
      return [];
    } catch (e) {
      throw 'فشل في جلب الصور من Firebase: $e';
    }
  }
}

/// مثال على الاستخدام
class ImageUploadExample {
  /// مثال: رفع صورة واحدة
  static Future<void> uploadSingleImage() async {
    try {
      // اختيار صورة من الاستديو
      final XFile? image = await CloudinaryService.pickImageFromGallery();

      if (image != null) {
        // رفع الصورة وحفظ الرابط في Firebase
        final String? imageUrl =
            await CloudinaryService.uploadAndSaveToFirebase(
              imageFile: image,
              collectionName: 'employees',
              documentId: 'employee_123',
              folder: 'employees',
              fieldName: 'profileImage',
            );

        if (imageUrl != null) {
          print('تم رفع الصورة بنجاح: $imageUrl');
        }
      }
    } catch (e) {
      print('خطأ: $e');
    }
  }

  /// مثال: رفع عدة صور
  static Future<void> uploadMultipleImages() async {
    try {
      // اختيار عدة صور من الاستديو
      final List<XFile> images =
          await CloudinaryService.pickMultipleImagesFromGallery();

      if (images.isNotEmpty) {
        // رفع الصور وحفظ الروابط في Firebase
        final List<String> imageUrls =
            await CloudinaryService.uploadMultipleAndSaveToFirebase(
              imageFiles: images,
              collectionName: 'employees',
              documentId: 'employee_123',
              folder: 'employees',
              fieldName: 'galleryImages',
            );

        print('تم رفع ${imageUrls.length} صورة بنجاح');
        for (String url in imageUrls) {
          print('رابط الصورة: $url');
        }
      }
    } catch (e) {
      print('خطأ: $e');
    }
  }

  /// مثال: جلب الصور من Firebase
  static Future<void> loadImagesFromFirebase() async {
    try {
      final List<String> imageUrls =
          await CloudinaryService.getImagesFromFirebase(
            collectionName: 'employees',
            documentId: 'employee_123',
            fieldName: 'galleryImages',
          );

      print('تم جلب ${imageUrls.length} صورة');
      for (String url in imageUrls) {
        print('رابط الصورة: $url');
      }
    } catch (e) {
      print('خطأ: $e');
    }
  }
}
