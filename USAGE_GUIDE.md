# دليل استخدام خدمة رفع الصور إلى Cloudinary و Firebase

## الميزات الجديدة

### 1. اختيار الصور من الكاميرا والاستديو

- دعم اختيار صورة من الكاميرا
- دعم اختيار صورة من الاستديو
- دعم اختيار تلقائي (كاميرا أولاً، ثم استديو)
- دعم اختيار عدة صور من الاستديو
- تحسين جودة الصور تلقائياً
- دعم منصات الويب والموبايل

### 2. رفع الصور إلى Cloudinary

- رفع آمن وسريع
- ضغط تلقائي للصور
- تنظيم الصور في مجلد `employees`
- دعم أسماء ملفات مخصصة

### 3. حفظ الروابط في Firebase

- حفظ تلقائي لروابط الصور في مجموعة `employees`
- تتبع وقت الرفع ومصدر الصورة
- دعم عدة صور في وثيقة واحدة
- دعم حقول مخصصة للصور

### 4. واجهة مستخدم محسنة

- أزرار منفصلة للكاميرا والاستديو
- نافذة اختيار مصدر الصورة
- عرض الصور المرفوعة
- معالجة الأخطاء وعرض الرسائل

## التثبيت

### 1. إضافة التبعيات إلى `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  image_picker: ^1.0.4
  firebase_core: ^2.24.2
  firebase_storage: ^11.5.6
  cloud_firestore: ^4.13.6
  cupertino_icons: ^1.0.2
```

### 2. تشغيل `flutter pub get`

### 3. إعداد Firebase

- أضف ملف `google-services.json` للمشروع
- أضف ملف `firebase_options.dart`

## الاستخدام

### 1. رفع صورة واحدة من الكاميرا

```dart
// اختيار صورة من الكاميرا
final XFile? image = await CloudinaryService.pickImageFromCamera();

if (image != null) {
  // رفع الصورة وحفظ الرابط في Firebase
  final String? imageUrl = await CloudinaryService.uploadAndSaveToFirebase(
    imageFile: image,
    collectionName: 'employees',
    documentId: 'employee_123',
    folder: 'employees',
    fieldName: 'profileImage',
  );

  if (imageUrl != null) {
    print('تم رفع الصورة: $imageUrl');
  }
}
```

### 2. رفع صورة واحدة من الاستديو

```dart
// اختيار صورة من الاستديو
final XFile? image = await CloudinaryService.pickImageFromGallery();

if (image != null) {
  // رفع الصورة وحفظ الرابط في Firebase
  final String? imageUrl = await CloudinaryService.uploadAndSaveToFirebase(
    imageFile: image,
    collectionName: 'employees',
    documentId: 'employee_123',
    folder: 'employees',
    fieldName: 'profileImage',
  );

  if (imageUrl != null) {
    print('تم رفع الصورة: $imageUrl');
  }
}
```

### 3. رفع تلقائي (كاميرا أو استديو)

```dart
// اختيار صورة تلقائياً (كاميرا أولاً، ثم استديو)
final XFile? image = await CloudinaryService.pickImageFromCameraOrGallery();

if (image != null) {
  // رفع الصورة وحفظ الرابط في Firebase
  final String? imageUrl = await CloudinaryService.uploadAndSaveToFirebase(
    imageFile: image,
    collectionName: 'employees',
    documentId: 'employee_123',
    folder: 'employees',
    fieldName: 'profileImage',
  );

  if (imageUrl != null) {
    print('تم رفع الصورة: $imageUrl');
  }
}
```

### 4. رفع عدة صور

```dart
// اختيار عدة صور من الاستديو
final List<XFile> images = await CloudinaryService.pickMultipleImagesFromGallery();

if (images.isNotEmpty) {
  // رفع الصور وحفظ الروابط في Firebase
  final List<String> imageUrls = await CloudinaryService.uploadMultipleAndSaveToFirebase(
    imageFiles: images,
    collectionName: 'employees',
    documentId: 'employee_123',
    folder: 'employees',
    fieldName: 'galleryImages',
  );

  print('تم رفع ${imageUrls.length} صورة');
}
```

### 5. استخدام الـ Widget الجاهز

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

### 6. جلب الصور من Firebase

```dart
final List<String> imageUrls = await CloudinaryService.getImagesFromFirebase(
  collectionName: 'employees',
  documentId: 'employee_123',
  fieldName: 'profileImage',
);

// عرض الصور
for (String url in imageUrls) {
  Image.network(url);
}
```

## إعدادات Cloudinary

### 1. تحديث الإعدادات في `CloudinaryService`

```dart
class CloudinaryService {
  static const String cloudName = 'your_cloud_name';
  static const String uploadPreset = 'your_upload_preset';
  // ...
}
```

### 2. إعداد Upload Preset في Cloudinary

- اذهب إلى Cloudinary Dashboard
- اختر "Settings" > "Upload"
- أنشئ Upload Preset جديد
- فعّل "Unsigned" للرفع بدون توقيع

## إعدادات Firebase

### 1. إعداد Firestore

- أنشئ قاعدة بيانات Firestore
- فعّل وضع الإنتاج أو التطوير

### 2. إعداد قواعد الأمان (اختياري)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // للاختبار فقط
    }
  }
}
```

## معالجة الأخطاء

### 1. أخطاء اختيار الصور

```dart
try {
  final XFile? image = await CloudinaryService.pickImageFromGallery();
} catch (e) {
  print('خطأ في اختيار الصورة: $e');
}
```

### 2. أخطاء الرفع

```dart
try {
  final String? url = await CloudinaryService.uploadImageToCloudinary(image);
} catch (e) {
  print('خطأ في رفع الصورة: $e');
}
```

### 3. أخطاء Firebase

```dart
try {
  await CloudinaryService.saveImageUrlToFirestore(...);
} catch (e) {
  print('خطأ في حفظ الرابط: $e');
}
```

## نصائح الأداء

### 1. تحسين حجم الصور

- استخدم `maxWidth` و `maxHeight` في `pickImage`
- استخدم `imageQuality` لتقليل حجم الملف

### 2. رفع متوازي

- يمكن رفع عدة صور في نفس الوقت
- استخدم `Future.wait()` للرفع المتوازي

### 3. التخزين المؤقت

- احفظ الصور محلياً بعد الرفع
- استخدم `cached_network_image` لعرض الصور

## الأمان

### 1. التحقق من الصور

- تحقق من نوع الملف
- تحقق من حجم الملف
- استخدم فلاتر الأمان في Cloudinary

### 2. صلاحيات Firebase

- استخدم قواعد أمان مناسبة
- لا تسمح بالوصول المفتوح في الإنتاج

## استكشاف الأخطاء

### 1. مشاكل الرفع

- تحقق من إعدادات Cloudinary
- تحقق من اتصال الإنترنت
- تحقق من حجم الصورة

### 2. مشاكل Firebase

- تحقق من إعدادات Firebase
- تحقق من قواعد الأمان
- تحقق من اتصال قاعدة البيانات

### 3. مشاكل العرض

- تحقق من صحة الروابط
- استخدم `Image.network` مع `errorBuilder`
- تحقق من اتصال الإنترنت
