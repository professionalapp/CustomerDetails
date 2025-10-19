import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'cloudinary_service_improved.dart';

class ImageUploadWidget extends StatefulWidget {
  final String collectionName;
  final String documentId;
  final String? folder;
  final String? fieldName;
  final bool allowMultiple;
  final bool allowCamera;
  final bool allowGallery;
  final Function(List<String>)? onImagesUploaded;
  final Function(String)? onError;

  const ImageUploadWidget({
    Key? key,
    required this.collectionName,
    required this.documentId,
    this.folder,
    this.fieldName,
    this.allowMultiple = false,
    this.allowCamera = true,
    this.allowGallery = true,
    this.onImagesUploaded,
    this.onError,
  }) : super(key: key);

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  List<String> uploadedImageUrls = [];
  bool isUploading = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // أزرار اختيار الصور
        if (widget.allowCamera && widget.allowGallery && !widget.allowMultiple)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isUploading
                      ? null
                      : () => _pickAndUploadImages(ImageSource.camera),
                  icon: isUploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.camera_alt),
                  label: const Text('الكاميرا'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isUploading
                      ? null
                      : () => _pickAndUploadImages(ImageSource.gallery),
                  icon: isUploading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.photo_library),
                  label: const Text('الاستديو'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          ElevatedButton.icon(
            onPressed: isUploading ? null : _showImageSourceDialog,
            icon: isUploading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_photo_alternate),
            label: Text(
              isUploading
                  ? 'جاري الرفع...'
                  : widget.allowMultiple
                  ? 'اختيار صور'
                  : 'اختيار صورة',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),

        const SizedBox(height: 16),

        // رسالة الخطأ
        if (errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: Colors.red.shade600),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => errorMessage = null),
                  icon: Icon(Icons.close, color: Colors.red.shade600),
                ),
              ],
            ),
          ),

        // عرض الصور المرفوعة
        if (uploadedImageUrls.isNotEmpty) ...[
          Text(
            'الصور المرفوعة (${uploadedImageUrls.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: uploadedImageUrls.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Image.network(
                        uploadedImageUrls[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  /// عرض نافذة اختيار مصدر الصورة
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              if (widget.allowCamera)
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.green),
                  title: const Text('التقاط صورة من الكاميرا'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickAndUploadImages(ImageSource.camera);
                  },
                ),
              if (widget.allowGallery)
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.blue),
                  title: Text(
                    widget.allowMultiple
                        ? 'اختيار صور من الاستديو'
                        : 'اختيار صورة من الاستديو',
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickAndUploadImages(ImageSource.gallery);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// اختيار ورفع الصور
  Future<void> _pickAndUploadImages(ImageSource source) async {
    try {
      setState(() {
        isUploading = true;
        errorMessage = null;
      });

      List<XFile> selectedImages = [];

      if (widget.allowMultiple && source == ImageSource.gallery) {
        selectedImages =
            await CloudinaryService.pickMultipleImagesFromGallery();
      } else {
        XFile? image;
        if (source == ImageSource.camera) {
          image = await CloudinaryService.pickImageFromCamera();
        } else {
          image = await CloudinaryService.pickImageFromGallery();
        }

        if (image != null) {
          selectedImages = [image];
        }
      }

      if (selectedImages.isEmpty) {
        setState(() {
          isUploading = false;
        });
        return;
      }

      List<String> newImageUrls = [];

      if (widget.allowMultiple && selectedImages.length > 1) {
        // رفع عدة صور
        newImageUrls = await CloudinaryService.uploadMultipleAndSaveToFirebase(
          imageFiles: selectedImages,
          collectionName: widget.collectionName,
          documentId: widget.documentId,
          folder: widget.folder ?? 'employees',
          fieldName: widget.fieldName,
        );
      } else {
        // رفع صورة واحدة
        final String? imageUrl =
            await CloudinaryService.uploadAndSaveToFirebase(
              imageFile: selectedImages.first,
              collectionName: widget.collectionName,
              documentId: widget.documentId,
              folder: widget.folder ?? 'employees',
              fieldName: widget.fieldName,
            );

        if (imageUrl != null) {
          newImageUrls = [imageUrl];
        }
      }

      setState(() {
        uploadedImageUrls.addAll(newImageUrls);
        isUploading = false;
      });

      // إشعار الوالد بالصور المرفوعة
      if (widget.onImagesUploaded != null) {
        widget.onImagesUploaded!(uploadedImageUrls);
      }

      // إظهار رسالة نجاح
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم رفع ${newImageUrls.length} صورة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isUploading = false;
        errorMessage = e.toString();
      });

      if (widget.onError != null) {
        widget.onError!(e.toString());
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في رفع الصور: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// حذف صورة
  void _removeImage(int index) {
    setState(() {
      uploadedImageUrls.removeAt(index);
    });

    if (widget.onImagesUploaded != null) {
      widget.onImagesUploaded!(uploadedImageUrls);
    }
  }

  /// تحميل الصور الموجودة من Firebase
  Future<void> loadExistingImages() async {
    try {
      final List<String> existingImages =
          await CloudinaryService.getImagesFromFirebase(
            collectionName: widget.collectionName,
            documentId: widget.documentId,
            fieldName: widget.fieldName,
          );

      setState(() {
        uploadedImageUrls = existingImages;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'خطأ في تحميل الصور: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // تحميل الصور الموجودة عند بدء التشغيل
    loadExistingImages();
  }
}

/// مثال على استخدام الـ Widget للموظفين
class EmployeeFormExample extends StatefulWidget {
  const EmployeeFormExample({Key? key}) : super(key: key);

  @override
  State<EmployeeFormExample> createState() => _EmployeeFormExampleState();
}

class _EmployeeFormExampleState extends State<EmployeeFormExample> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  List<String> employeeImages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة موظف'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // حقل اسم الموظف
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الموظف',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // حقل المنصب
            TextField(
              controller: _positionController,
              decoration: const InputDecoration(
                labelText: 'المنصب',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // حقل البريد الإلكتروني
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'البريد الإلكتروني',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // رفع الصور
            const Text(
              'صور الموظف',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // صورة شخصية واحدة
            const Text(
              'الصورة الشخصية',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ImageUploadWidget(
              collectionName: 'employees',
              documentId: 'employee_${DateTime.now().millisecondsSinceEpoch}',
              folder: 'employees',
              fieldName: 'profileImage',
              allowMultiple: false,
              allowCamera: true,
              allowGallery: true,
              onImagesUploaded: (images) {
                setState(() {
                  employeeImages = images;
                });
              },
              onError: (error) {
                print('خطأ في رفع الصورة الشخصية: $error');
              },
            ),

            const SizedBox(height: 24),

            // صور إضافية
            const Text(
              'صور إضافية (اختياري)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ImageUploadWidget(
              collectionName: 'employees',
              documentId: 'employee_${DateTime.now().millisecondsSinceEpoch}',
              folder: 'employees',
              fieldName: 'galleryImages',
              allowMultiple: true,
              allowCamera: true,
              allowGallery: true,
              onImagesUploaded: (images) {
                print('تم رفع ${images.length} صورة إضافية');
              },
              onError: (error) {
                print('خطأ في رفع الصور الإضافية: $error');
              },
            ),

            const SizedBox(height: 32),

            // زر الحفظ
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveEmployee,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('حفظ الموظف', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveEmployee() {
    if (_nameController.text.isEmpty ||
        _positionController.text.isEmpty ||
        _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى ملء جميع الحقول'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (employeeImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى إضافة صورة شخصية'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // هنا يمكنك إضافة منطق حفظ بيانات الموظف
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ الموظف بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
