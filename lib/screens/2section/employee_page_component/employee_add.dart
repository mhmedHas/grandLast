// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class AddEmployeePage extends StatefulWidget {
//   const AddEmployeePage({super.key});

//   @override
//   State<AddEmployeePage> createState() => _AddEmployeePageState();
// }

// class _AddEmployeePageState extends State<AddEmployeePage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _positionController = TextEditingController();
//   final TextEditingController _salaryController = TextEditingController();

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     _positionController.dispose();
//     _salaryController.dispose();
//     super.dispose();
//   }

//   Future<void> _addEmployee() async {
//     if (_formKey.currentState!.validate()) {
//       try {
//         final newEmployee = {
//           'name': _nameController.text.trim(),
//           'phone': _phoneController.text.trim(),
//           'position': _positionController.text.trim(),
//           'salary': double.parse(_salaryController.text),
//           'totalPenalties': 0.0,
//           'joinDate': DateTime.now().toIso8601String(),
//         };

//         await _firestore.collection('employees').add(newEmployee);

//         _formKey.currentState!.reset();

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('تم إضافة الموظف بنجاح'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('خطأ في إضافة الموظف: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         bool isMobile = constraints.maxWidth < 600;

//         return SingleChildScrollView(
//           child: Column(
//             children: [
//               // Form Card
//               Card(
//                 elevation: 8,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(isMobile ? 16 : 22),
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.all(isMobile ? 16 : 32),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       children: [
//                         SizedBox(height: isMobile ? 16 : 32),
//                         _buildFormSection(isMobile),
//                         SizedBox(height: isMobile ? 20 : 40),
//                         _buildActionButton(isMobile),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: isMobile ? 16 : 24),
//               // Employees List
//               _buildEmployeesList(isMobile),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildFormSection(bool isMobile) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Center(
//           child: Text(
//             'إضافة موظف جديد',
//             style: TextStyle(
//               fontSize: isMobile ? 18 : 20,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xFF2C3E50),
//             ),
//           ),
//         ),
//         SizedBox(height: isMobile ? 12 : 20),

//         _buildField(_nameController, 'الاسم', Icons.person, isMobile),
//         SizedBox(height: isMobile ? 12 : 16),

//         isMobile
//             ? Column(
//                 children: [
//                   _buildField(
//                     _phoneController,
//                     'رقم التليفون',
//                     Icons.phone,
//                     isMobile,
//                     keyboardType: TextInputType.phone,
//                   ),
//                   SizedBox(height: isMobile ? 12 : 16),
//                   _buildField(
//                     _positionController,
//                     'الوظيفة',
//                     Icons.work,
//                     isMobile,
//                   ),
//                 ],
//               )
//             : Row(
//                 children: [
//                   Expanded(
//                     child: _buildField(
//                       _phoneController,
//                       'رقم التليفون',
//                       Icons.phone,
//                       isMobile,
//                       keyboardType: TextInputType.phone,
//                     ),
//                   ),
//                   SizedBox(width: 16),
//                   Expanded(
//                     child: _buildField(
//                       _positionController,
//                       'الوظيفة',
//                       Icons.work,
//                       isMobile,
//                     ),
//                   ),
//                 ],
//               ),
//         SizedBox(height: isMobile ? 12 : 16),

//         _buildField(
//           _salaryController,
//           'الراتب',
//           Icons.attach_money,
//           isMobile,
//           keyboardType: TextInputType.number,
//           suffixText: 'جنية',
//         ),
//       ],
//     );
//   }

//   Widget _buildField(
//     TextEditingController controller,
//     String label,
//     IconData icon,
//     bool isMobile, {
//     TextInputType keyboardType = TextInputType.text,
//     String? suffixText,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       style: TextStyle(fontSize: isMobile ? 14 : 16),
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
//         suffixText: suffixText,
//         filled: true,
//         fillColor: Colors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
//         ),
//         contentPadding: EdgeInsets.symmetric(
//           horizontal: isMobile ? 12 : 16,
//           vertical: isMobile ? 12 : 16,
//         ),
//       ),
//       validator:
//           validator ??
//           (value) => value == null || value.isEmpty ? 'هذا الحقل مطلوب' : null,
//     );
//   }

//   Widget _buildActionButton(bool isMobile) {
//     return SizedBox(
//       width: double.infinity,
//       height: isMobile ? 50 : 60,
//       child: ElevatedButton(
//         onPressed: _addEmployee,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF2E86C1),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
//           ),
//         ),
//         child: Text(
//           'إضافة الموظف',
//           style: TextStyle(
//             fontSize: isMobile ? 16 : 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmployeesList(bool isMobile) {
//     return Card(
//       elevation: 8,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(isMobile ? 16 : 22),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(isMobile ? 16 : 24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'الموظفين المضافين',
//               style: TextStyle(
//                 fontSize: isMobile ? 18 : 20,
//                 fontWeight: FontWeight.bold,
//                 color: const Color(0xFF2C3E50),
//               ),
//             ),
//             SizedBox(height: isMobile ? 12 : 16),

//             StreamBuilder<QuerySnapshot>(
//               stream: _firestore.collection('employees').snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }

//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final employees = snapshot.data!.docs;

//                 if (employees.isEmpty) {
//                   return const Center(
//                     child: Text(
//                       'لا يوجد موظفين بعد',
//                       style: TextStyle(fontSize: 16, color: Colors.grey),
//                     ),
//                   );
//                 }

//                 return isMobile
//                     ? _buildMobileEmployeesList(employees)
//                     : _buildDesktopEmployeesList(employees);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMobileEmployeesList(List<QueryDocumentSnapshot> employees) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: employees.length,
//       itemBuilder: (context, index) {
//         final employee = employees[index];
//         final data = employee.data() as Map<String, dynamic>;
//         return Card(
//           margin: const EdgeInsets.only(bottom: 8),
//           elevation: 2,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           child: ListTile(
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 12,
//               vertical: 8,
//             ),
//             leading: const Icon(
//               Icons.person,
//               color: Color(0xFF3498DB),
//               size: 20,
//             ),
//             title: Text(
//               data['name'] ?? '',
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'الوظيفة: ${data['position'] ?? ''}',
//                   style: const TextStyle(fontSize: 12),
//                 ),
//                 Text(
//                   'الراتب: ${data['salary'] ?? 0} جنية',
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ],
//             ),
//             trailing: IconButton(
//               icon: const Icon(Icons.delete, size: 20, color: Colors.red),
//               onPressed: () => _deleteEmployee(employee.id, data['name'] ?? ''),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildDesktopEmployeesList(List<QueryDocumentSnapshot> employees) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: employees.length,
//       itemBuilder: (context, index) {
//         final employee = employees[index];
//         final data = employee.data() as Map<String, dynamic>;
//         return Card(
//           margin: const EdgeInsets.only(bottom: 12),
//           elevation: 3,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: ListTile(
//             leading: const Icon(Icons.person, color: Color(0xFF3498DB)),
//             title: Text(
//               data['name'] ?? '',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text('الوظيفة: ${data['position'] ?? ''}'),
//                 Text('الراتب: ${data['salary'] ?? 0} جنية'),
//                 Text('الهاتف: ${data['phone'] ?? ''}'),
//               ],
//             ),
//             trailing: IconButton(
//               icon: const Icon(Icons.delete, color: Colors.red),
//               onPressed: () => _deleteEmployee(employee.id, data['name'] ?? ''),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _deleteEmployee(String employeeId, String employeeName) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('تأكيد الحذف'),
//         content: Text('هل أنت متأكد من حذف الموظف "$employeeName"؟'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('إلغاء'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: const Text('حذف', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       try {
//         // حذف الموظف
//         await _firestore.collection('employees').doc(employeeId).delete();

//         // حذف جميع جزاءات الموظف
//         final penaltiesQuery = await _firestore
//             .collection('penalties')
//             .where('employeeId', isEqualTo: employeeId)
//             .get();

//         for (final penalty in penaltiesQuery.docs) {
//           await penalty.reference.delete();
//         }

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('تم حذف الموظف وجميع جزاءاته بنجاح'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('خطأ في الحذف: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({super.key});

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _positionController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _addEmployee() async {
    if (_formKey.currentState!.validate()) {
      try {
        final newEmployee = {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'position': _positionController.text.trim(),
          'salary': double.parse(_salaryController.text),
          'totalPenalties': 0.0,
          'joinDate': DateTime.now().toIso8601String(),
        };

        await _firestore.collection('employees').add(newEmployee);

        _formKey.currentState!.reset();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إضافة الموظف بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إضافة الموظف: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editEmployee(QueryDocumentSnapshot employee) {
    final data = employee.data() as Map<String, dynamic>;

    _nameController.text = data['name'] ?? '';
    _phoneController.text = data['phone'] ?? '';
    _positionController.text = data['position'] ?? '';
    _salaryController.text = (data['salary'] ?? 0).toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل بيانات الموظف'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildField(_nameController, 'الاسم', Icons.person, true),
                const SizedBox(height: 12),
                _buildField(
                  _phoneController,
                  'رقم التليفون',
                  Icons.phone,
                  true,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildField(_positionController, 'الوظيفة', Icons.work, true),
                const SizedBox(height: 12),
                _buildField(
                  _salaryController,
                  'الراتب',
                  Icons.attach_money,
                  true,
                  keyboardType: TextInputType.number,
                  suffixText: 'جنية',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                try {
                  await _firestore
                      .collection('employees')
                      .doc(employee.id)
                      .update({
                        'name': _nameController.text.trim(),
                        'phone': _phoneController.text.trim(),
                        'position': _positionController.text.trim(),
                        'salary': double.parse(_salaryController.text),
                      });

                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تعديل بيانات الموظف بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطأ في التعديل: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('حفظ التغييرات'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 600;

        return SingleChildScrollView(
          child: Column(
            children: [
              // Form Card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 22),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: isMobile ? 16 : 32),
                        _buildFormSection(isMobile),
                        SizedBox(height: isMobile ? 20 : 40),
                        _buildActionButton(isMobile),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 16 : 24),
              // Employees List
              _buildEmployeesList(isMobile),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFormSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'إضافة موظف جديد',
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
        ),
        SizedBox(height: isMobile ? 12 : 20),
        _buildField(_nameController, 'الاسم', Icons.person, isMobile),
        SizedBox(height: isMobile ? 12 : 16),
        isMobile
            ? Column(
                children: [
                  _buildField(
                    _phoneController,
                    'رقم التليفون',
                    Icons.phone,
                    isMobile,
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: isMobile ? 12 : 16),
                  _buildField(
                    _positionController,
                    'الوظيفة',
                    Icons.work,
                    isMobile,
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _buildField(
                      _phoneController,
                      'رقم التليفون',
                      Icons.phone,
                      isMobile,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildField(
                      _positionController,
                      'الوظيفة',
                      Icons.work,
                      isMobile,
                    ),
                  ),
                ],
              ),
        SizedBox(height: isMobile ? 12 : 16),
        _buildField(
          _salaryController,
          'الراتب',
          Icons.attach_money,
          isMobile,
          keyboardType: TextInputType.number,
          suffixText: 'جنية',
        ),
      ],
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool isMobile, {
    TextInputType keyboardType = TextInputType.text,
    String? suffixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: isMobile ? 14 : 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
        suffixText: suffixText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 12 : 16,
        ),
      ),
      validator:
          validator ??
          (value) => value == null || value.isEmpty ? 'هذا الحقل مطلوب' : null,
    );
  }

  Widget _buildActionButton(bool isMobile) {
    return SizedBox(
      width: double.infinity,
      height: isMobile ? 50 : 60,
      child: ElevatedButton(
        onPressed: _addEmployee,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E86C1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
          ),
        ),
        child: Text(
          'إضافة الموظف',
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeesList(bool isMobile) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 16 : 22),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الموظفين المضافين',
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: isMobile ? 12 : 16),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('employees').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final employees = snapshot.data!.docs;
                if (employees.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا يوجد موظفين بعد',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }
                return isMobile
                    ? _buildMobileEmployeesList(employees)
                    : _buildDesktopEmployeesList(employees);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileEmployeesList(List<QueryDocumentSnapshot> employees) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        final data = employee.data() as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            leading: const Icon(
              Icons.person,
              color: Color(0xFF3498DB),
              size: 20,
            ),
            title: Text(
              data['name'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الوظيفة: ${data['position'] ?? ''}',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'الراتب: ${data['salary'] ?? 0} جنية',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => _editEmployee(employee),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () =>
                      _deleteEmployee(employee.id, data['name'] ?? ''),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopEmployeesList(List<QueryDocumentSnapshot> employees) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        final data = employee.data() as Map<String, dynamic>;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.person, color: Color(0xFF3498DB)),
            title: Text(
              data['name'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الوظيفة: ${data['position'] ?? ''}'),
                Text('الراتب: ${data['salary'] ?? 0} جنية'),
                Text('الهاتف: ${data['phone'] ?? ''}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => _editEmployee(employee),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      _deleteEmployee(employee.id, data['name'] ?? ''),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _deleteEmployee(String employeeId, String employeeName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الموظف "$employeeName"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestore.collection('employees').doc(employeeId).delete();

        final penaltiesQuery = await _firestore
            .collection('penalties')
            .where('employeeId', isEqualTo: employeeId)
            .get();

        for (final penalty in penaltiesQuery.docs) {
          await penalty.reference.delete();
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الموظف وجميع جزاءاته بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الحذف: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
