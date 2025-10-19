# إصلاح مشكلة "تعذر الاتصال بالخادم" عند إضافة موظف جديد

## المشكلة

كان يظهر خطأ "تعذر الاتصال بالخادم" عند إضافة موظف جديد، رغم أن البيانات كانت تُحفظ في Firebase بنجاح.

## الأسباب المحتملة

1. **معالجة الأخطاء غير كافية** في JavaScript
2. **عدم وجود معالجة شاملة للأخطاء** في Controller
3. **عدم وجود تشخيص** لمعرفة سبب الخطأ

## الحلول المطبقة

### 1. تحسين معالجة الأخطاء في JavaScript (`Pages/AddEmployee.cshtml`)

#### إضافة تشخيص مفصل:

```javascript
try {
  console.log("إرسال البيانات:", payload);
  const res = await fetch("/api/employees", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });

  console.log("استجابة الخادم:", res.status, res.statusText);

  if (res.ok) {
    const result = await res.json();
    // نجح الإرسال
  } else {
    // معالجة أفضل للأخطاء
    const errorText = await res.text();
    let errorMessage = "حدث خطأ غير متوقع";

    try {
      const errorJson = JSON.parse(errorText);
      errorMessage = errorJson.message || errorMessage;
    } catch {
      errorMessage = errorText || errorMessage;
    }

    resultMsg.innerHTML = `<div class="alert alert-danger">فشل: ${errorMessage}</div>`;
  }
} catch (err) {
  console.error("خطأ في الاتصال:", err);
  resultMsg.innerHTML =
    '<div class="alert alert-danger">تعذر الاتصال بالخادم. تأكد من اتصال الإنترنت وحاول مرة أخرى.</div>';
}
```

#### إعادة تعيين الصورة بعد النجاح:

```javascript
// إعادة تعيين الصورة
selectedImageFile = null;
uploadedImageUrl = null;
document.getElementById("imagePreview").style.display = "none";
document.getElementById("imageUploadButtons").style.display = "flex";
document.getElementById("imageInput").value = "";
hideUploadStatus();
```

### 2. تحسين معالجة الأخطاء في Controller (`Controllers/EmployeesController.cs`)

#### إضافة try-catch شامل:

```csharp
[HttpPost]
public async Task<IActionResult> CreateEmployee([FromBody] Employee body)
{
    try
    {
        if (string.IsNullOrWhiteSpace(body.EmployeeId) || string.IsNullOrWhiteSpace(body.Name))
            return BadRequest(new { message = "EmployeeId و Name مطلوبان" });

        var col = _db.Collection(EmployeesCollection);
        // enforce unique employeeId
        var existing = await col.WhereEqualTo("employeeId", body.EmployeeId).Limit(1).GetSnapshotAsync();
        if (existing.Any())
            return Conflict(new { message = "يوجد عميل بنفس الرقم" });

        var doc = col.Document();
        body.CreatedAt ??= Timestamp.FromDateTime(DateTime.UtcNow);
        await doc.SetAsync(body);
        return Ok(new { id = body.EmployeeId, message = "تم إضافة العميل بنجاح" });
    }
    catch (Exception ex)
    {
        Console.WriteLine($"خطأ في إضافة العميل: {ex.Message}");
        return StatusCode(500, new { message = "خطأ في الخادم: " + ex.Message });
    }
}
```

## الميزات الجديدة

### 🔍 **تشخيص مفصل**

- **تسجيل البيانات المرسلة**: عرض البيانات المرسلة في console
- **تسجيل استجابة الخادم**: عرض حالة الاستجابة
- **معالجة أفضل للأخطاء**: عرض رسائل خطأ واضحة

### 🛡️ **معالجة شاملة للأخطاء**

- **معالجة أخطاء الشبكة**: رسائل واضحة لأخطاء الاتصال
- **معالجة أخطاء الخادم**: عرض رسائل الخطأ من الخادم
- **معالجة أخطاء JSON**: التعامل مع استجابات غير صالحة

### 🔄 **إعادة تعيين تلقائي**

- **إعادة تعيين النموذج**: مسح جميع الحقول بعد النجاح
- **إعادة تعيين الصورة**: مسح الصورة المرفوعة
- **إعادة تعيين الحالة**: إخفاء رسائل الحالة

## كيفية التشخيص

### 1. فتح Developer Tools

- اضغط `F12` في المتصفح
- اذهب إلى تبويب "Console"

### 2. مراقبة الرسائل

عند إضافة موظف جديد، ستظهر الرسائل التالية:

```
إرسال البيانات: {employeeId: "123", name: "أحمد", ...}
استجابة الخادم: 200 OK
```

### 3. في حالة الخطأ

ستظهر رسائل خطأ مفصلة:

```
خطأ في الاتصال: TypeError: Failed to fetch
```

## الاختبار

### 1. اختبار النجاح

1. املأ النموذج ببيانات صحيحة
2. اضغط "حفظ"
3. تأكد من ظهور "تمت إضافة العميل بنجاح"
4. تأكد من مسح النموذج

### 2. اختبار الخطأ

1. اترك حقل "رقم العميل" فارغاً
2. اضغط "حفظ"
3. تأكد من ظهور رسالة خطأ واضحة

### 3. اختبار التكرار

1. أضف موظف برقم موجود
2. اضغط "حفظ"
3. تأكد من ظهور "يوجد عميل بنفس الرقم"

## الملفات المحدثة

- `Pages/AddEmployee.cshtml` - تحسين معالجة الأخطاء في JavaScript
- `Controllers/EmployeesController.cs` - إضافة try-catch شامل

## ملاحظات إضافية

- **التشخيص**: استخدم Developer Tools لمراقبة الأخطاء
- **السجلات**: تحقق من console المتصفح و console الخادم
- **الشبكة**: تأكد من اتصال الإنترنت
- **Firebase**: تأكد من إعدادات Firebase

الآن أصبح بإمكانك معرفة السبب الدقيق لأي خطأ يحدث عند إضافة موظف جديد! 🎉
