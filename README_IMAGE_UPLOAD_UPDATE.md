# تحديث نظام رفع الصور - استبدال رابط الصورة بخيار اختيار الصورة

## المشكلة

كان المستخدمون يحتاجون لإدخال رابط الصورة يدوياً في حقل "رابط الصورة الشخصية"، مما يجعل العملية معقدة وغير عملية.

## الحل المطبق

### 1. تحديث نموذج إضافة العميل (`Pages/AddEmployee.cshtml`)

#### التغييرات المطبقة:

- **استبدال حقل النص**: تم استبدال `<input type="text">` بخيارات اختيار الصورة
- **أزرار اختيار الصورة**:
  - زر "الكاميرا" لالتقاط صورة جديدة
  - زر "الاستديو" لاختيار صورة من المعرض
- **معاينة الصورة**: عرض الصورة المختارة قبل الرفع
- **رفع تلقائي**: رفع الصورة إلى Cloudinary تلقائياً عند الاختيار

#### الميزات الجديدة:

```html
<!-- أزرار اختيار الصورة -->
<button type="button" class="btn btn-success" onclick="selectImageFromCamera()">
  <i class="fas fa-camera"></i> الكاميرا
</button>
<button
  type="button"
  class="btn btn-primary"
  onclick="selectImageFromGallery()"
>
  <i class="fas fa-images"></i> الاستديو
</button>

<!-- معاينة الصورة -->
<div id="imagePreview" class="image-preview">
  <img id="previewImg" src="" alt="معاينة الصورة" />
  <button type="button" class="btn btn-sm btn-danger" onclick="removeImage()">
    <i class="fas fa-times"></i> حذف
  </button>
</div>
```

### 2. تحديث نموذج تعديل العميل (`Pages/Employees.cshtml`)

#### التغييرات المطبقة:

- **نفس الميزات**: تطبيق نفس نظام اختيار الصور في نموذج التعديل
- **عرض الصورة الحالية**: عرض الصورة الموجودة عند فتح نموذج التعديل
- **تحديث الصورة**: إمكانية استبدال الصورة الحالية بصورة جديدة

### 3. وظائف JavaScript المضافة

#### وظائف اختيار الصورة:

```javascript
// اختيار من الكاميرا
function selectImageFromCamera() {
  const input = document.getElementById("imageInput");
  input.setAttribute("capture", "camera");
  input.click();
}

// اختيار من الاستديو
function selectImageFromGallery() {
  const input = document.getElementById("imageInput");
  input.removeAttribute("capture");
  input.click();
}
```

#### رفع الصورة إلى Cloudinary:

```javascript
async function uploadImageToCloudinary(file) {
  const formData = new FormData();
  formData.append("file", file);
  formData.append("upload_preset", "imgupload");
  formData.append("folder", "employees");

  const response = await fetch(
    "https://api.cloudinary.com/v1_1/dnx3ypscu/image/upload",
    {
      method: "POST",
      body: formData,
    }
  );

  if (response.ok) {
    const data = await response.json();
    uploadedImageUrl = data.secure_url;
  }
}
```

### 4. تصميم CSS محسن

#### أنماط الحاوية:

```css
.image-upload-container {
  border: 2px dashed #dee2e6;
  border-radius: 8px;
  padding: 20px;
  text-align: center;
  background-color: #f8f9fa;
  transition: all 0.3s ease;
}

.image-upload-container:hover {
  border-color: #007bff;
  background-color: #e3f2fd;
}
```

#### معاينة الصورة:

```css
.preview-image {
  max-width: 200px;
  max-height: 200px;
  border-radius: 8px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}
```

## الميزات الجديدة

### 🎯 **سهولة الاستخدام**

- **اختيار سهل**: نقرة واحدة لاختيار الصورة
- **معاينة فورية**: عرض الصورة قبل الرفع
- **حذف سهل**: إمكانية حذف الصورة المختارة

### 📱 **دعم الأجهزة المختلفة**

- **الكاميرا**: التقاط صورة جديدة مباشرة
- **الاستديو**: اختيار صورة من المعرض
- **الويب**: دعم كامل للمتصفحات الحديثة

### ⚡ **رفع تلقائي**

- **رفع فوري**: رفع الصورة تلقائياً عند الاختيار
- **حالة الرفع**: عرض حالة الرفع (جاري الرفع، نجح، فشل)
- **Cloudinary**: رفع مباشر إلى خدمة Cloudinary

### 🎨 **تصميم محسن**

- **واجهة جذابة**: تصميم حديث وسهل الاستخدام
- **تأثيرات بصرية**: تأثيرات hover وانتقالات سلسة
- **ألوان متناسقة**: ألوان متناسقة مع تصميم الموقع

## كيفية الاستخدام

### في نموذج إضافة عميل جديد:

1. **اختر مصدر الصورة**: اضغط على "الكاميرا" أو "الاستديو"
2. **اختر الصورة**: اختر الصورة من الجهاز أو التقط صورة جديدة
3. **معاينة**: ستظهر معاينة للصورة المختارة
4. **رفع تلقائي**: ستُرفع الصورة تلقائياً إلى Cloudinary
5. **حفظ**: اضغط "حفظ" لحفظ بيانات العميل مع الصورة

### في نموذج تعديل العميل:

1. **عرض الصورة الحالية**: ستظهر الصورة الموجودة (إن وجدت)
2. **تغيير الصورة**: اضغط على "الكاميرا" أو "الاستديو" لاختيار صورة جديدة
3. **حذف الصورة**: اضغط على زر "حذف" لإزالة الصورة
4. **حفظ التعديلات**: اضغط "حفظ" لحفظ التعديلات

## الملفات المحدثة

- `Pages/AddEmployee.cshtml` - نموذج إضافة العميل
- `Pages/Employees.cshtml` - نموذج تعديل العميل

## الاختبار

لاختبار الميزات الجديدة:

1. **اذهب إلى صفحة إضافة عميل جديد**
2. **اضغط على زر "الكاميرا" أو "الاستديو"**
3. **اختر صورة من الجهاز**
4. **تأكد من ظهور معاينة الصورة**
5. **تأكد من رفع الصورة بنجاح**
6. **احفظ النموذج وتأكد من حفظ الصورة**

## ملاحظات إضافية

- **دعم Cloudinary**: الصور تُرفع إلى مجلد `employees` في Cloudinary
- **تنسيقات مدعومة**: JPG, PNG, WebP, GIF
- **حجم الصورة**: لا توجد قيود على حجم الصورة (Cloudinary يتعامل مع التحسين)
- **الأمان**: رفع آمن عبر HTTPS
- **الأداء**: رفع سريع ومحسن

الآن أصبح بإمكان المستخدمين رفع الصور بسهولة دون الحاجة لإدخال الروابط يدوياً! 🎉
