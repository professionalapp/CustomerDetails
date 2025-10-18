# دليل رفع المشروع إلى Render.com

## ✅ تم إنجازه:

- ✅ رفع الكود إلى GitHub
- ✅ إضافة حزمة FirebaseAdmin
- ✅ تحديث Dockerfile للعمل مع Render
- ✅ تحديث Program.cs للتعامل مع متغيرات البيئة
- ✅ إنشاء ملف render.yaml

## 🚀 الخطوات التالية على Render.com:

### 1. سجل دخول إلى Render.com

- اذهب إلى: https://render.com
- اضغط "Get Started for Free"
- سجل دخول بحساب GitHub

### 2. أنشئ خدمة جديدة

- اضغط "New +" في أعلى الصفحة
- اختر "Web Service"
- اختر المستودع: `professionalapp/CustomerDetails`
- اضغط "Connect"

### 3. إعدادات الخدمة

```
Name: customer-details-app
Environment: Docker
Region: Oregon (US West)
Branch: master
Dockerfile Path: ./Dockerfile
Docker Context: .
```

### 4. إضافة متغيرات البيئة

في قسم "Environment Variables"، أضف:

**ASPNETCORE_ENVIRONMENT**

```
Production
```

**FIREBASE_SERVICE_ACCOUNT_JSON**

```
انسخ محتوى ملف employee-services-60fa4-firebase-adminsdk-o405k-d21a9b72c4.json هنا
```

### 5. خطة التسعير

- اختر "Free" للبداية

### 6. نشر المشروع

- اضغط "Create Web Service"
- انتظر البناء (5-10 دقائق)

## 📋 معلومات مهمة:

### رابط المستودع:

https://github.com/professionalapp/CustomerDetails

### ملف Firebase المطلوب:

يجب نسخ محتوى ملف `employee-services-60fa4-firebase-adminsdk-o405k-d21a9b72c4.json`
وإضافته كمتغير بيئة `FIREBASE_SERVICE_ACCOUNT_JSON`

### بعد النشر:

ستحصل على رابط مثل: `https://customer-details-app.onrender.com`

## 🔧 استكشاف الأخطاء:

### إذا فشل البناء:

1. تحقق من متغيرات البيئة
2. تأكد من صحة محتوى Firebase JSON
3. راجع logs في Render dashboard

### إذا فشل التطبيق في التشغيل:

1. تحقق من Firebase credentials
2. تأكد من إعدادات Firestore
3. راجع console logs

## 📞 الدعم:

إذا واجهت أي مشاكل، راجع:

- Render Documentation: https://render.com/docs
- Firebase Admin SDK: https://firebase.google.com/docs/admin/setup
