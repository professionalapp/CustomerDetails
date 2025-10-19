import 'package:flutter/material.dart';
import 'cloudinary_service_improved.dart';

/// مثال بسيط لرفع صورة موظف
class SimpleEmployeeUpload extends StatefulWidget {
  const SimpleEmployeeUpload({Key? key}) : super(key: key);

  @override
  State<SimpleEmployeeUpload> createState() => _SimpleEmployeeUploadState();
}

class _SimpleEmployeeUploadState extends State<SimpleEmployeeUpload> {
  String? uploadedImageUrl;
  bool isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('رفع صورة موظف'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // عرض الصورة المرفوعة
            if (uploadedImageUrl != null) ...[
              const Text(
                'الصورة المرفوعة:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    uploadedImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade200,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 50,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // أزرار الرفع
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isUploading ? null : _uploadFromCamera,
                    icon: isUploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.camera_alt),
                    label: const Text('من الكاميرا'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isUploading ? null : _uploadFromGallery,
                    icon: isUploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.photo_library),
                    label: const Text('من الاستديو'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // زر رفع تلقائي (كاميرا أو استديو)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isUploading ? null : _uploadAuto,
                icon: isUploading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: const Text('رفع تلقائي (كاميرا أو استديو)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // معلومات إضافية
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'معلومات الرفع:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text('• المجلد: employees'),
                  Text('• المجموعة: employees'),
                  Text('• الحقل: profileImage'),
                  Text('• يدعم الكاميرا والاستديو'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// رفع صورة من الكاميرا
  Future<void> _uploadFromCamera() async {
    try {
      setState(() {
        isUploading = true;
      });

      final String? imageUrl = await CloudinaryService.uploadAndSaveToFirebase(
        imageFile: (await CloudinaryService.pickImageFromCamera())!,
        collectionName: 'employees',
        documentId: 'employee_${DateTime.now().millisecondsSinceEpoch}',
        folder: 'employees',
        fieldName: 'profileImage',
      );

      if (imageUrl != null) {
        setState(() {
          uploadedImageUrl = imageUrl;
          isUploading = false;
        });

        _showSuccessMessage('تم رفع الصورة من الكاميرا بنجاح');
      }
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      _showErrorMessage('خطأ في رفع الصورة من الكاميرا: $e');
    }
  }

  /// رفع صورة من الاستديو
  Future<void> _uploadFromGallery() async {
    try {
      setState(() {
        isUploading = true;
      });

      final String? imageUrl = await CloudinaryService.uploadAndSaveToFirebase(
        imageFile: (await CloudinaryService.pickImageFromGallery())!,
        collectionName: 'employees',
        documentId: 'employee_${DateTime.now().millisecondsSinceEpoch}',
        folder: 'employees',
        fieldName: 'profileImage',
      );

      if (imageUrl != null) {
        setState(() {
          uploadedImageUrl = imageUrl;
          isUploading = false;
        });

        _showSuccessMessage('تم رفع الصورة من الاستديو بنجاح');
      }
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      _showErrorMessage('خطأ في رفع الصورة من الاستديو: $e');
    }
  }

  /// رفع تلقائي (كاميرا أو استديو)
  Future<void> _uploadAuto() async {
    try {
      setState(() {
        isUploading = true;
      });

      final String? imageUrl = await CloudinaryService.uploadAndSaveToFirebase(
        imageFile: (await CloudinaryService.pickImageFromCameraOrGallery())!,
        collectionName: 'employees',
        documentId: 'employee_${DateTime.now().millisecondsSinceEpoch}',
        folder: 'employees',
        fieldName: 'profileImage',
      );

      if (imageUrl != null) {
        setState(() {
          uploadedImageUrl = imageUrl;
          isUploading = false;
        });

        _showSuccessMessage('تم رفع الصورة بنجاح');
      }
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      _showErrorMessage('خطأ في رفع الصورة: $e');
    }
  }

  /// عرض رسالة نجاح
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// عرض رسالة خطأ
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
