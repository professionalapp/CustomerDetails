import 'package:flutter/material.dart';
import 'employee_edit_widget.dart';
import 'cloudinary_service_improved.dart';

/// مثال شامل لإدارة الموظفين
class EmployeeManagementExample extends StatefulWidget {
  const EmployeeManagementExample({Key? key}) : super(key: key);

  @override
  State<EmployeeManagementExample> createState() =>
      _EmployeeManagementExampleState();
}

class _EmployeeManagementExampleState extends State<EmployeeManagementExample> {
  List<EmployeeData> employees = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  /// تحميل قائمة الموظفين
  Future<void> _loadEmployees() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // في التطبيق الحقيقي، ستجلب البيانات من Firebase
      // هنا سنستخدم بيانات وهمية للعرض
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        employees = [
          EmployeeData(
            id: 'emp_001',
            name: 'أحمد محمد',
            position: 'مطور تطبيقات',
            email: 'ahmed@company.com',
            phone: '+966501234567',
            profileImageUrl: null,
            galleryImageUrls: [],
            createdAt: DateTime.now().subtract(const Duration(days: 30)),
          ),
          EmployeeData(
            id: 'emp_002',
            name: 'فاطمة علي',
            position: 'مصممة واجهات',
            email: 'fatima@company.com',
            phone: '+966507654321',
            profileImageUrl: null,
            galleryImageUrls: [],
            createdAt: DateTime.now().subtract(const Duration(days: 15)),
          ),
        ];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'خطأ في تحميل الموظفين: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الموظفين'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _addNewEmployee, icon: const Icon(Icons.add)),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? _buildErrorWidget()
          : employees.isEmpty
          ? _buildEmptyWidget()
          : _buildEmployeesList(),
    );
  }

  /// بناء قائمة الموظفين
  Widget _buildEmployeesList() {
    return RefreshIndicator(
      onRefresh: _loadEmployees,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: employees.length,
        itemBuilder: (context, index) {
          final employee = employees[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue.shade100,
                backgroundImage: employee.profileImageUrl != null
                    ? NetworkImage(employee.profileImageUrl!)
                    : null,
                child: employee.profileImageUrl == null
                    ? const Icon(Icons.person, size: 30)
                    : null,
              ),
              title: Text(
                employee.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(employee.position),
                  Text(employee.email),
                  if (employee.phone != null) Text(employee.phone!),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _editEmployee(employee);
                      break;
                    case 'delete':
                      _deleteEmployee(employee);
                      break;
                    case 'view':
                      _viewEmployee(employee);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(
                      children: [
                        Icon(Icons.visibility),
                        SizedBox(width: 8),
                        Text('عرض'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('تعديل'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('حذف', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
              onTap: () => _viewEmployee(employee),
            ),
          );
        },
      ),
    );
  }

  /// بناء واجهة الخطأ
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            errorMessage!,
            style: TextStyle(fontSize: 16, color: Colors.red.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadEmployees,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  /// بناء واجهة فارغة
  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'لا يوجد موظفين',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'اضغط على + لإضافة موظف جديد',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _addNewEmployee,
            icon: const Icon(Icons.add),
            label: const Text('إضافة موظف'),
          ),
        ],
      ),
    );
  }

  /// إضافة موظف جديد
  void _addNewEmployee() {
    final newEmployee = EmployeeData(
      id: 'emp_${DateTime.now().millisecondsSinceEpoch}',
      name: '',
      position: '',
      email: '',
      createdAt: DateTime.now(),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EmployeeEditWidget(
          employee: newEmployee,
          onEmployeeUpdated: (updatedEmployee) {
            setState(() {
              employees.add(updatedEmployee);
            });
            _showSuccessMessage('تم إضافة الموظف بنجاح');
          },
          onError: (error) {
            _showErrorMessage('خطأ في إضافة الموظف: $error');
          },
        ),
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
            _showSuccessMessage('تم تحديث بيانات الموظف بنجاح');
          },
          onError: (error) {
            _showErrorMessage('خطأ في تحديث الموظف: $error');
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
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // الصورة الشخصية
              if (employee.profileImageUrl != null)
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        employee.profileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.person, size: 50),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // تفاصيل الموظف
              _buildDetailRow('المنصب', employee.position),
              _buildDetailRow('البريد الإلكتروني', employee.email),
              if (employee.phone != null)
                _buildDetailRow('رقم الهاتف', employee.phone!),
              _buildDetailRow(
                'تاريخ الإنشاء',
                employee.createdAt?.toString().split(' ')[0] ?? 'غير محدد',
              ),
              if (employee.updatedAt != null)
                _buildDetailRow(
                  'آخر تحديث',
                  employee.updatedAt?.toString().split(' ')[0] ?? 'غير محدد',
                ),

              // الصور الإضافية
              if (employee.galleryImageUrls.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'الصور الإضافية:',
                  style: TextStyle(fontWeight: FontWeight.bold),
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
                  itemCount: employee.galleryImageUrls.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          employee.galleryImageUrls[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
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

  /// بناء صف تفاصيل
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// حذف موظف
  void _deleteEmployee(EmployeeData employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الموظف "${employee.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _confirmDeleteEmployee(employee);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  /// تأكيد حذف الموظف
  Future<void> _confirmDeleteEmployee(EmployeeData employee) async {
    try {
      setState(() {
        isLoading = true;
      });

      // حذف الصور من Cloudinary و Firebase
      if (employee.profileImageUrl != null) {
        await CloudinaryService.deleteImageCompletely(
          imageUrl: employee.profileImageUrl!,
          collectionName: 'employees',
          documentId: employee.id,
          fieldName: 'profileImage',
        );
      }

      for (String imageUrl in employee.galleryImageUrls) {
        await CloudinaryService.deleteImageCompletely(
          imageUrl: imageUrl,
          collectionName: 'employees',
          documentId: employee.id,
          fieldName: 'galleryImages',
        );
      }

      // حذف من القائمة المحلية
      setState(() {
        employees.removeWhere((e) => e.id == employee.id);
        isLoading = false;
      });

      _showSuccessMessage('تم حذف الموظف بنجاح');
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorMessage('خطأ في حذف الموظف: $e');
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
