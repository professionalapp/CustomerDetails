import 'package:flutter/material.dart';
import 'employee_edit_widget.dart';

/// مثال بسيط لتعديل موظف
class SimpleEditExample extends StatelessWidget {
  const SimpleEditExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // بيانات موظف وهمية للعرض
    final employee = EmployeeData(
      id: 'emp_001',
      name: 'أحمد محمد',
      position: 'مطور تطبيقات',
      email: 'ahmed@company.com',
      phone: '+966501234567',
      profileImageUrl: null,
      galleryImageUrls: [],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('مثال تعديل الموظف'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'مثال على تعديل بيانات الموظف',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'اضغط على الزر أدناه لفتح نموذج التعديل',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _openEditForm(context, employee),
              icon: const Icon(Icons.edit),
              label: const Text('تعديل الموظف'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الميزات المتاحة:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text('• تعديل البيانات الأساسية'),
                  Text('• رفع صورة شخصية من الكاميرا أو الاستديو'),
                  Text('• حذف الصورة الشخصية'),
                  Text('• إضافة صور إضافية'),
                  Text('• حذف الصور الإضافية'),
                  Text('• حفظ التعديلات في Firebase'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// فتح نموذج التعديل
  void _openEditForm(BuildContext context, EmployeeData employee) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EmployeeEditWidget(
          employee: employee,
          onEmployeeUpdated: (updatedEmployee) {
            // معالجة التحديث
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم تحديث ${updatedEmployee.name} بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          },
          onError: (error) {
            // معالجة الخطأ
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطأ: $error'),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      ),
    );
  }
}

/// مثال على استخدام Widget التعديل في صفحة أخرى
class EmployeeListPage extends StatefulWidget {
  const EmployeeListPage({Key? key}) : super(key: key);

  @override
  State<EmployeeListPage> createState() => _EmployeeListPageState();
}

class _EmployeeListPageState extends State<EmployeeListPage> {
  final List<EmployeeData> employees = [
    EmployeeData(
      id: 'emp_001',
      name: 'أحمد محمد',
      position: 'مطور تطبيقات',
      email: 'ahmed@company.com',
      phone: '+966501234567',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    EmployeeData(
      id: 'emp_002',
      name: 'فاطمة علي',
      position: 'مصممة واجهات',
      email: 'fatima@company.com',
      phone: '+966507654321',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الموظفين'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  employee.name[0],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              title: Text(
                employee.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(employee.position),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _editEmployee(employee),
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'تعديل',
                  ),
                  IconButton(
                    onPressed: () => _viewEmployee(employee),
                    icon: const Icon(Icons.visibility, color: Colors.green),
                    tooltip: 'عرض',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// تعديل موظف
  void _editEmployee(EmployeeData employee) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EmployeeEditWidget(
          employee: employee,
          onEmployeeUpdated: (updatedEmployee) {
            setState(() {
              final index = employees.indexWhere((e) => e.id == employee.id);
              if (index != -1) {
                employees[index] = updatedEmployee;
              }
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم تحديث ${updatedEmployee.name} بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          },
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطأ في التحديث: $error'),
                backgroundColor: Colors.red,
              ),
            );
          },
        ),
      ),
    );
  }

  /// عرض تفاصيل الموظف
  void _viewEmployee(EmployeeData employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(employee.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المنصب: ${employee.position}'),
            Text('البريد الإلكتروني: ${employee.email}'),
            if (employee.phone != null) Text('الهاتف: ${employee.phone}'),
            Text(
              'تاريخ الإنشاء: ${employee.createdAt?.toString().split(' ')[0] ?? 'غير محدد'}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _editEmployee(employee);
            },
            child: const Text('تعديل'),
          ),
        ],
      ),
    );
  }
}
