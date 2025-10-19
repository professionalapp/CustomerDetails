# خدمة رفع صور الموظفين إلى Cloudinary و Firebase

## نظرة عامة

هذه الخدمة تتيح رفع صور الموظفين من الكاميرا أو الاستديو إلى Cloudinary وحفظ الروابط في Firebase. تم تصميمها خصيصاً لمجلد `employees` بدلاً من `hotmarket/products`.

## الميزات الجديدة ✨

### 📸 اختيار الصور

- **من الكاميرا**: التقاط صورة جديدة مباشرة
- **من الاستديو**: اختيار صورة موجودة
- **تلقائي**: محاولة الكاميرا أولاً، ثم الاستديو
- **عدة صور**: دعم رفع عدة صور من الاستديو

### 🗂️ تنظيم الملفات

- **المجلد**: `employees` (بدلاً من `hotmarket/products`)
- **المجموعة**: `employees` في Firebase
- **الحقول**: `profileImage`, `galleryImages`

### 🎨 واجهة مستخدم محسنة

- أزرار منفصلة للكاميرا والاستديو
- نافذة اختيار مصدر الصورة
- عرض الصور المرفوعة
- معالجة الأخطاء المتقدمة

### ✏️ تعديل البيانات

- **تعديل شامل**: تعديل جميع بيانات الموظف
- **إدارة الصور**: حذف وإضافة صور جديدة
- **حفظ تلقائي**: حفظ التعديلات في Firebase
- **واجهة سهلة**: واجهة مستخدم بديهية للتعديل

## الاستخدام السريع

### 1. رفع صورة من الكاميرا

```dart
final XFile? image = await CloudinaryService.pickImageFromCamera();
if (image != null) {
  final String? url = await CloudinaryService.uploadAndSaveToFirebase(
    imageFile: image,
    collectionName: 'employees',
    documentId: 'employee_123',
    folder: 'employees',
    fieldName: 'profileImage',
  );
}
```

### 2. رفع صورة من الاستديو

```dart
final XFile? image = await CloudinaryService.pickImageFromGallery();
if (image != null) {
  final String? url = await CloudinaryService.uploadAndSaveToFirebase(
    imageFile: image,
    collectionName: 'employees',
    documentId: 'employee_123',
    folder: 'employees',
    fieldName: 'profileImage',
  );
}
```

### 3. رفع تلقائي

```dart
final XFile? image = await CloudinaryService.pickImageFromCameraOrGallery();
if (image != null) {
  final String? url = await CloudinaryService.uploadAndSaveToFirebase(
    imageFile: image,
    collectionName: 'employees',
    documentId: 'employee_123',
    folder: 'employees',
    fieldName: 'profileImage',
  );
}
```

### 4. استخدام الـ Widget

```dart
ImageUploadWidget(
  collectionName: 'employees',
  documentId: 'employee_123',
  folder: 'employees',
  fieldName: 'profileImage',
  allowMultiple: false,
  allowCamera: true,
  allowGallery: true,
  onImagesUploaded: (images) {
    print('تم رفع ${images.length} صورة');
  },
  onError: (error) {
    print('خطأ: $error');
  },
)
```

## الملفات المحدثة

### 1. `cloudinary_service_improved.dart`

- ✅ إضافة `pickImageFromCamera()`
- ✅ إضافة `pickImageFromCameraOrGallery()`
- ✅ تحديث المجلد الافتراضي إلى `employees`
- ✅ تحديث الأمثلة لاستخدام `employees`

### 2. `image_upload_widget.dart`

- ✅ إضافة خيارات `allowCamera` و `allowGallery`
- ✅ أزرار منفصلة للكاميرا والاستديو
- ✅ نافذة اختيار مصدر الصورة
- ✅ تحديث المجلد الافتراضي إلى `employees`

### 3. `simple_employee_upload_example.dart`

- ✅ مثال بسيط لرفع صور الموظفين
- ✅ أزرار منفصلة للكاميرا والاستديو
- ✅ عرض الصور المرفوعة
- ✅ معالجة الأخطاء

## الإعدادات المطلوبة

### 1. Cloudinary

```dart
class CloudinaryService {
  static const String cloudName = 'dnx3ypscu';
  static const String uploadPreset = 'imgupload';
  // ...
}
```

### 2. Firebase

- مجموعة: `employees`
- مجلد: `employees`
- حقول: `profileImage`, `galleryImages`

### 3. التبعيات

```yaml
dependencies:
  http: ^1.1.0
  image_picker: ^1.0.4
  firebase_core: ^2.24.2
  firebase_storage: ^11.5.6
  cloud_firestore: ^4.13.6
```

## أمثلة الاستخدام

### مثال 1: تعديل بيانات الموظف

```dart
// استخدام Widget التعديل
EmployeeEditWidget(
  employee: employeeData,
  onEmployeeUpdated: (updatedEmployee) {
    print('تم تحديث ${updatedEmployee.name}');
  },
  onError: (error) {
    print('خطأ: $error');
  },
)
```

### مثال 2: رفع صورة شخصية

```dart
class EmployeeProfile extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return ImageUploadWidget(
      collectionName: 'employees',
      documentId: 'employee_123',
      folder: 'employees',
      fieldName: 'profileImage',
      allowMultiple: false,
      allowCamera: true,
      allowGallery: true,
    );
  }
}
```

### مثال 3: حذف الصور

```dart
// حذف صورة من Cloudinary و Firebase
final bool deleted = await CloudinaryService.deleteImageCompletely(
  imageUrl: imageUrl,
  collectionName: 'employees',
  documentId: 'employee_123',
  fieldName: 'profileImage',
);

if (deleted) {
  print('تم حذف الصورة بنجاح');
}
```

### مثال 4: رفع عدة صور

```dart
class EmployeeGallery extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return ImageUploadWidget(
      collectionName: 'employees',
      documentId: 'employee_123',
      folder: 'employees',
      fieldName: 'galleryImages',
      allowMultiple: true,
      allowCamera: false, // الكاميرا لا تدعم عدة صور
      allowGallery: true,
    );
  }
}
```

### مثال 5: رفع مخصص

```dart
Future<void> uploadEmployeePhoto() async {
  try {
    // اختيار من الكاميرا
    final XFile? image = await CloudinaryService.pickImageFromCamera();

    if (image != null) {
      // رفع إلى Cloudinary
      final String? url = await CloudinaryService.uploadImageToCloudinary(
        image,
        folder: 'employees',
      );

      if (url != null) {
        // حفظ في Firebase
        await CloudinaryService.saveImageUrlToFirestore(
          imageUrl: url,
          collectionName: 'employees',
          documentId: 'employee_123',
          fieldName: 'profileImage',
        );

        print('تم رفع الصورة: $url');
      }
    }
  } catch (e) {
    print('خطأ: $e');
  }
}
```

## معالجة الأخطاء

### أخطاء الكاميرا

```dart
try {
  final XFile? image = await CloudinaryService.pickImageFromCamera();
} catch (e) {
  print('خطأ في الكاميرا: $e');
  // جرب الاستديو كبديل
}
```

### أخطاء الرفع

```dart
try {
  final String? url = await CloudinaryService.uploadImageToCloudinary(image);
} catch (e) {
  print('خطأ في الرفع: $e');
  // عرض رسالة خطأ للمستخدم
}
```

### أخطاء Firebase

```dart
try {
  await CloudinaryService.saveImageUrlToFirestore(...);
} catch (e) {
  print('خطأ في Firebase: $e');
  // إعادة المحاولة أو حفظ محلياً
}
```

## نصائح الأداء

### 1. تحسين الصور

- استخدم `maxWidth: 1920, maxHeight: 1080`
- استخدم `imageQuality: 85`
- ضغط الصور قبل الرفع

### 2. التخزين المؤقت

- احفظ الصور محلياً بعد الرفع
- استخدم `cached_network_image` للعرض
- تحقق من وجود الصورة قبل الرفع

### 3. معالجة الأخطاء

- أضف retry logic للرفع
- استخدم fallback للكاميرا
- اعرض رسائل واضحة للمستخدم

## الأمان

### 1. التحقق من الصور

- تحقق من نوع الملف
- تحقق من حجم الملف
- استخدم فلاتر الأمان في Cloudinary

### 2. صلاحيات Firebase

- استخدم قواعد أمان مناسبة
- لا تسمح بالوصول المفتوح
- تحقق من صلاحيات المستخدم

## الدعم

للمساعدة أو الاستفسارات:

- راجع `USAGE_GUIDE.md` للتفاصيل الكاملة
- تحقق من الأمثلة في الملفات
- راجع logs الأخطاء للتشخيص
