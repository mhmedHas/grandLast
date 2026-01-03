// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';

// // class CompanyPage extends StatefulWidget {
// //   const CompanyPage({super.key});

// //   @override
// //   State<CompanyPage> createState() => _CompanyPageState();
// // }

// // class _CompanyPageState extends State<CompanyPage> {
// //   final _formKey = GlobalKey<FormState>();
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// //   final _companyNameController = TextEditingController();
// //   final _addressController = TextEditingController();
// //   final _emailController = TextEditingController();
// //   final _phoneController = TextEditingController();

// //   List<Representative> representatives = [Representative()];
// //   bool isSaving = false;
// //   bool isEditing = false;
// //   String? editingCompanyId;

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF4F6F8),
// //       body: LayoutBuilder(
// //         builder: (context, constraints) {
// //           bool isMobile = constraints.maxWidth < 600;
// //           bool isTablet = constraints.maxWidth < 1000;

// //           return Column(
// //             children: [
// //               _buildCustomAppBar(isMobile),
// //               Expanded(
// //                 child: SingleChildScrollView(
// //                   padding: EdgeInsets.all(isMobile ? 16 : 24),
// //                   child: Center(
// //                     child: ConstrainedBox(
// //                       constraints: BoxConstraints(maxWidth: 1200),
// //                       child: Column(
// //                         children: [
// //                           // Form Card
// //                           Card(
// //                             elevation: 8,
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(
// //                                 isMobile ? 16 : 22,
// //                               ),
// //                             ),
// //                             child: Padding(
// //                               padding: EdgeInsets.all(isMobile ? 16 : 32),
// //                               child: Form(
// //                                 key: _formKey,
// //                                 child: Column(
// //                                   children: [
// //                                     SizedBox(height: isMobile ? 16 : 32),
// //                                     _buildCompanyInfoSection(isMobile),
// //                                     SizedBox(height: isMobile ? 16 : 32),
// //                                     _buildRepresentativesSection(isMobile),
// //                                     SizedBox(height: isMobile ? 20 : 40),
// //                                     _buildActionButtons(isMobile),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                           SizedBox(height: isMobile ? 16 : 24),
// //                           // Companies List
// //                           _buildCompaniesList(isMobile),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   // =================== APP BAR ===================
// //   Widget _buildCustomAppBar(bool isMobile) {
// //     return Container(
// //       padding: EdgeInsets.symmetric(
// //         horizontal: isMobile ? 16 : 24,
// //         vertical: isMobile ? 12 : 20,
// //       ),
// //       decoration: const BoxDecoration(
// //         gradient: LinearGradient(
// //           begin: Alignment.centerRight,
// //           end: Alignment.centerLeft,
// //           colors: [Color(0xFF1B4F72), Color(0xFF3498DB)],
// //         ),
// //         boxShadow: [
// //           BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
// //         ],
// //       ),
// //       child: SafeArea(
// //         child: Row(
// //           children: [
// //             Icon(Icons.business, color: Colors.white, size: isMobile ? 24 : 32),
// //             SizedBox(width: isMobile ? 8 : 12),
// //             Text(
// //               'إدارة الشركات',
// //               style: TextStyle(
// //                 color: Colors.white,
// //                 fontSize: isMobile ? 18 : 24,
// //                 fontWeight: FontWeight.bold,
// //                 fontFamily: 'Cairo',
// //               ),
// //             ),
// //             const Spacer(),
// //             // الوقت - نخفيه في الشاشات الصغيرة جداً
// //             _buildTimeWidget(),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildTimeWidget() {
// //     return StreamBuilder<DateTime>(
// //       stream: Stream.periodic(
// //         const Duration(seconds: 1),
// //         (_) => DateTime.now(),
// //       ),
// //       builder: (context, snapshot) {
// //         final now = snapshot.data ?? DateTime.now();

// //         // تحويل إلى نظام 12 ساعة
// //         int hour12 = now.hour % 12;
// //         if (hour12 == 0) hour12 = 12; // تحويل 0 إلى 12

// //         // تحديد AM/PM
// //         String period = now.hour < 12 ? 'AM' : 'PM';

// //         return Column(
// //           crossAxisAlignment: CrossAxisAlignment.center,
// //           children: [
// //             Container(
// //               height: 50,
// //               width: 150,
// //               decoration: BoxDecoration(
// //                 color: Colors.transparent,
// //                 borderRadius: BorderRadius.circular(16),
// //               ),
// //               child: Center(
// //                 child: Text(
// //                   '${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ',
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 36,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   // =================== COMPANY INFO ===================
// //   Widget _buildCompanyInfoSection(bool isMobile) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Center(
// //           child: Text(
// //             isEditing ? 'تعديل بيانات الشركة' : 'بيانات الشركة',
// //             style: TextStyle(
// //               fontSize: isMobile ? 18 : 20,
// //               fontWeight: FontWeight.bold,
// //               color: const Color(0xFF2C3E50),
// //             ),
// //           ),
// //         ),
// //         SizedBox(height: isMobile ? 12 : 20),
// //         _buildField(
// //           _companyNameController,
// //           'اسم الشركة',
// //           Icons.business,
// //           isMobile,
// //         ),
// //         SizedBox(height: isMobile ? 12 : 16),
// //         // في الشاشات الصغيرة نضع الحقول تحت بعض، في الكبيرة بجوار بعض
// //         isMobile
// //             ? Column(
// //                 children: [
// //                   _buildField(
// //                     _emailController,
// //                     'example@company.com',
// //                     Icons.email,
// //                     isMobile,
// //                     keyboardType: TextInputType.emailAddress,
// //                     validator: _validateEmail,
// //                   ),
// //                   SizedBox(height: isMobile ? 12 : 16),
// //                   _buildField(
// //                     _phoneController,
// //                     '01XXXXXXXXX',
// //                     Icons.phone,
// //                     isMobile,
// //                     keyboardType: TextInputType.phone,
// //                     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
// //                   ),
// //                 ],
// //               )
// //             : Row(
// //                 children: [
// //                   Expanded(
// //                     child: _buildField(
// //                       _emailController,
// //                       'example@company.com',
// //                       Icons.email,
// //                       isMobile,
// //                       keyboardType: TextInputType.emailAddress,
// //                       validator: _validateEmail,
// //                     ),
// //                   ),
// //                   SizedBox(width: 16),
// //                   Expanded(
// //                     child: _buildField(
// //                       _phoneController,
// //                       '01XXXXXXXXX',
// //                       Icons.phone,
// //                       isMobile,
// //                       keyboardType: TextInputType.phone,
// //                       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //         SizedBox(height: isMobile ? 12 : 16),
// //         _buildField(
// //           _addressController,
// //           'العنوان التفصيلي للشركة',
// //           Icons.location_on,
// //           isMobile,
// //           maxLines: 2,
// //         ),
// //       ],
// //     );
// //   }

// //   // =================== REPRESENTATIVES ===================
// //   Widget _buildRepresentativesSection(bool isMobile) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         if (!isMobile) // نخفي العنوان في الشاشات الصغيرة لتوفير المساحة
// //           const Text(
// //             'المندوبون',
// //             style: TextStyle(
// //               fontSize: 18,
// //               fontWeight: FontWeight.bold,
// //               color: Color(0xFF2C3E50),
// //             ),
// //           ),
// //         if (!isMobile) SizedBox(height: 16),
// //         ListView.builder(
// //           shrinkWrap: true,
// //           physics: const NeverScrollableScrollPhysics(),
// //           itemCount: representatives.length,
// //           itemBuilder: (context, index) =>
// //               _buildRepresentativeCard(index, isMobile),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildRepresentativeCard(int index, bool isMobile) {
// //     return Card(
// //       margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
// //       elevation: 4,
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
// //       ),
// //       child: Padding(
// //         padding: EdgeInsets.all(isMobile ? 12 : 20),
// //         child: Column(
// //           children: [
// //             Row(
// //               children: [
// //                 Text(
// //                   'مندوب ${index + 1}',
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: isMobile ? 14 : 16,
// //                   ),
// //                 ),
// //                 const Spacer(),
// //                 if (representatives.length > 1)
// //                   IconButton(
// //                     onPressed: () => _removeRepresentative(index),
// //                     icon: Icon(
// //                       Icons.delete,
// //                       color: Colors.red,
// //                       size: isMobile ? 18 : 24,
// //                     ),
// //                     padding: EdgeInsets.zero,
// //                     constraints: BoxConstraints(),
// //                   ),
// //               ],
// //             ),
// //             SizedBox(height: isMobile ? 8 : 12),
// //             _buildField(
// //               representatives[index].nameController,
// //               'اسم المندوب',
// //               Icons.person,
// //               isMobile,
// //             ),
// //             SizedBox(height: isMobile ? 8 : 12),
// //             isMobile
// //                 ? Column(
// //                     children: [
// //                       _buildField(
// //                         representatives[index].jobController,
// //                         'الوظيفة',
// //                         Icons.work,
// //                         isMobile,
// //                       ),
// //                       SizedBox(height: isMobile ? 8 : 12),
// //                       _buildField(
// //                         representatives[index].phoneController,
// //                         '01XXXXXXXXX',
// //                         Icons.phone_android,
// //                         isMobile,
// //                         keyboardType: TextInputType.phone,
// //                         inputFormatters: [
// //                           FilteringTextInputFormatter.digitsOnly,
// //                         ],
// //                       ),
// //                     ],
// //                   )
// //                 : Row(
// //                     children: [
// //                       Expanded(
// //                         child: _buildField(
// //                           representatives[index].jobController,
// //                           'الوظيفة',
// //                           Icons.work,
// //                           isMobile,
// //                         ),
// //                       ),
// //                       SizedBox(width: 16),
// //                       Expanded(
// //                         child: _buildField(
// //                           representatives[index].phoneController,
// //                           '01XXXXXXXXX',
// //                           Icons.phone_android,
// //                           isMobile,
// //                           keyboardType: TextInputType.phone,
// //                           inputFormatters: [
// //                             FilteringTextInputFormatter.digitsOnly,
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //             SizedBox(height: isMobile ? 8 : 12),
// //             if (index == representatives.length - 1)
// //               SizedBox(
// //                 width: double.infinity,
// //                 child: ElevatedButton.icon(
// //                   onPressed: _addRepresentative,
// //                   icon: Icon(
// //                     Icons.add,
// //                     color: Colors.white,
// //                     size: isMobile ? 16 : 20,
// //                   ),
// //                   label: Text(
// //                     'إضافة مندوب',
// //                     style: TextStyle(
// //                       fontSize: isMobile ? 14 : 16,
// //                       color: Colors.white,
// //                     ),
// //                   ),
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: Colors.green,
// //                     foregroundColor: Colors.white,
// //                     padding: EdgeInsets.symmetric(
// //                       horizontal: isMobile ? 12 : 16,
// //                       vertical: isMobile ? 10 : 12,
// //                     ),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // =================== ACTION BUTTONS ===================
// //   Widget _buildActionButtons(bool isMobile) {
// //     return isMobile
// //         ? Column(
// //             children: [
// //               ElevatedButton(
// //                 onPressed: isSaving ? null : _saveCompanyData,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: isEditing
// //                       ? Colors.orange
// //                       : const Color(0xFF2E86C1),
// //                   minimumSize: const Size(double.infinity, 50),
// //                 ),
// //                 child: isSaving
// //                     ? const CircularProgressIndicator(color: Colors.white)
// //                     : Text(
// //                         isEditing ? 'تحديث البيانات' : 'حفظ البيانات',
// //                         style: const TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.white,
// //                         ),
// //                       ),
// //               ),
// //               if (isEditing) ...[
// //                 SizedBox(height: 12),
// //                 ElevatedButton(
// //                   onPressed: isSaving ? null : _cancelEdit,
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: Colors.grey,
// //                     minimumSize: const Size(double.infinity, 50),
// //                   ),
// //                   child: const Text(
// //                     'إلغاء',
// //                     style: TextStyle(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.white,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ],
// //           )
// //         : Row(
// //             children: [
// //               if (isEditing) ...[
// //                 Expanded(
// //                   child: ElevatedButton(
// //                     onPressed: isSaving ? null : _cancelEdit,
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: Colors.grey,
// //                       padding: const EdgeInsets.symmetric(vertical: 18),
// //                     ),
// //                     child: const Text(
// //                       'إلغاء',
// //                       style: TextStyle(
// //                         fontSize: 18,
// //                         fontWeight: FontWeight.bold,
// //                         color: Colors.white,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //                 SizedBox(width: 16),
// //               ],
// //               Expanded(
// //                 child: ElevatedButton(
// //                   onPressed: isSaving ? null : _saveCompanyData,
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: isEditing
// //                         ? Colors.orange
// //                         : const Color(0xFF2E86C1),
// //                     padding: const EdgeInsets.symmetric(vertical: 18),
// //                   ),
// //                   child: isSaving
// //                       ? const CircularProgressIndicator(color: Colors.white)
// //                       : Text(
// //                           isEditing ? 'تحديث البيانات' : 'حفظ البيانات',
// //                           style: const TextStyle(
// //                             fontSize: 18,
// //                             fontWeight: FontWeight.bold,
// //                             color: Colors.white,
// //                           ),
// //                         ),
// //                 ),
// //               ),
// //             ],
// //           );
// //   }

// //   // =================== COMPANIES LIST ===================
// //   Widget _buildCompaniesList(bool isMobile) {
// //     return Card(
// //       elevation: 8,
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(isMobile ? 16 : 22),
// //       ),
// //       child: Padding(
// //         padding: EdgeInsets.all(isMobile ? 16 : 24),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               'قائمة الشركات',
// //               style: TextStyle(
// //                 fontSize: isMobile ? 18 : 20,
// //                 fontWeight: FontWeight.bold,
// //                 color: const Color(0xFF2C3E50),
// //               ),
// //             ),
// //             SizedBox(height: isMobile ? 12 : 16),
// //             StreamBuilder<QuerySnapshot>(
// //               stream: _firestore.collection('companies').snapshots(),
// //               builder: (context, snapshot) {
// //                 if (snapshot.hasError) {
// //                   return Center(child: Text('Error: ${snapshot.error}'));
// //                 }

// //                 if (snapshot.connectionState == ConnectionState.waiting) {
// //                   return const Center(child: CircularProgressIndicator());
// //                 }

// //                 final companies = snapshot.data!.docs;

// //                 if (companies.isEmpty) {
// //                   return const Center(
// //                     child: Text(
// //                       'لا توجد شركات مسجلة',
// //                       style: TextStyle(fontSize: 16, color: Colors.grey),
// //                     ),
// //                   );
// //                 }

// //                 return isMobile
// //                     ? _buildMobileCompaniesList(companies)
// //                     : _buildDesktopCompaniesList(companies);
// //               },
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildMobileCompaniesList(List<QueryDocumentSnapshot> companies) {
// //     return ListView.builder(
// //       shrinkWrap: true,
// //       physics: const NeverScrollableScrollPhysics(),
// //       itemCount: companies.length,
// //       itemBuilder: (context, index) {
// //         final company = companies[index];
// //         final data = company.data() as Map<String, dynamic>;
// //         return _buildMobileCompanyItem(company.id, data);
// //       },
// //     );
// //   }

// //   Widget _buildDesktopCompaniesList(List<QueryDocumentSnapshot> companies) {
// //     return ListView.builder(
// //       shrinkWrap: true,
// //       physics: const NeverScrollableScrollPhysics(),
// //       itemCount: companies.length,
// //       itemBuilder: (context, index) {
// //         final company = companies[index];
// //         final data = company.data() as Map<String, dynamic>;
// //         return _buildDesktopCompanyItem(company.id, data);
// //       },
// //     );
// //   }

// //   Widget _buildMobileCompanyItem(String companyId, Map<String, dynamic> data) {
// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 8),
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// //       child: ListTile(
// //         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //         leading: const Icon(Icons.business, color: Color(0xFF3498DB), size: 20),
// //         title: Text(
// //           data['companyName'] ?? '',
// //           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
// //         ),
// //         subtitle: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               '${data['email'] ?? ''}',
// //               style: const TextStyle(fontSize: 12),
// //             ),
// //             Text(
// //               '${data['phone'] ?? ''}',
// //               style: const TextStyle(fontSize: 12),
// //             ),
// //           ],
// //         ),
// //         trailing: PopupMenuButton<String>(
// //           icon: const Icon(Icons.more_vert, size: 20),
// //           onSelected: (value) {
// //             if (value == 'edit') {
// //               _editCompany(companyId, data);
// //             } else if (value == 'delete') {
// //               _deleteCompany(companyId, data['companyName'] ?? '');
// //             }
// //           },
// //           itemBuilder: (context) => [
// //             const PopupMenuItem(value: 'edit', child: Text('تعديل')),
// //             const PopupMenuItem(value: 'delete', child: Text('حذف')),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildDesktopCompanyItem(String companyId, Map<String, dynamic> data) {
// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 12),
// //       elevation: 3,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: ListTile(
// //         leading: const Icon(Icons.business, color: Color(0xFF3498DB)),
// //         title: Text(
// //           data['companyName'] ?? '',
// //           style: const TextStyle(fontWeight: FontWeight.bold),
// //         ),
// //         subtitle: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text('البريد: ${data['email'] ?? ''}'),
// //             Text('الهاتف: ${data['phone'] ?? ''}'),
// //             Text('عدد المندوبين: ${data['representatives']?.length ?? 0}'),
// //           ],
// //         ),
// //         trailing: Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             IconButton(
// //               icon: const Icon(Icons.edit, color: Colors.blue),
// //               onPressed: () => _editCompany(companyId, data),
// //             ),
// //             IconButton(
// //               icon: const Icon(Icons.delete, color: Colors.red),
// //               onPressed: () =>
// //                   _deleteCompany(companyId, data['companyName'] ?? ''),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // =================== SHARED FIELD ===================
// //   Widget _buildField(
// //     TextEditingController controller,
// //     String label,
// //     IconData icon,
// //     bool isMobile, {
// //     TextInputType keyboardType = TextInputType.text,
// //     String? Function(String?)? validator,
// //     List<TextInputFormatter>? inputFormatters,
// //     int maxLines = 1,
// //   }) {
// //     return TextFormField(
// //       controller: controller,
// //       keyboardType: keyboardType,
// //       inputFormatters: inputFormatters,
// //       maxLines: maxLines,
// //       style: TextStyle(fontSize: isMobile ? 14 : 16),
// //       decoration: InputDecoration(
// //         labelText: label,
// //         prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
// //         filled: true,
// //         fillColor: Colors.white,
// //         border: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //         ),
// //         contentPadding: EdgeInsets.symmetric(
// //           horizontal: isMobile ? 12 : 16,
// //           vertical: isMobile ? 12 : 16,
// //         ),
// //       ),
// //       validator:
// //           validator ??
// //           (value) => value == null || value.isEmpty ? 'هذا الحقل مطلوب' : null,
// //     );
// //   }

// //   // =================== FIREBASE OPERATIONS ===================
// //   void _saveCompanyData() async {
// //     if (!_formKey.currentState!.validate()) return;

// //     setState(() => isSaving = true);

// //     try {
// //       final companyData = {
// //         'companyName': _companyNameController.text.trim(),
// //         'email': _emailController.text.trim(),
// //         'phone': _phoneController.text.trim(),
// //         'address': _addressController.text.trim(),
// //         'representatives': representatives
// //             .map(
// //               (rep) => {
// //                 'name': rep.nameController.text.trim(),
// //                 'job': rep.jobController.text.trim(),
// //                 'phone': rep.phoneController.text.trim(),
// //               },
// //             )
// //             .toList(),
// //         'createdAt': FieldValue.serverTimestamp(),
// //         'updatedAt': FieldValue.serverTimestamp(),
// //       };

// //       if (isEditing) {
// //         await _firestore
// //             .collection('companies')
// //             .doc(editingCompanyId)
// //             .update(companyData);
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(
// //             content: Text('تم تحديث بيانات الشركة بنجاح'),
// //             backgroundColor: Colors.green,
// //           ),
// //         );
// //       } else {
// //         await _firestore.collection('companies').add(companyData);
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(
// //             content: Text('تم حفظ البيانات بنجاح'),
// //             backgroundColor: Colors.green,
// //           ),
// //         );
// //       }

// //       _clearForm();
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text('خطأ في الحفظ: $e'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //     } finally {
// //       setState(() => isSaving = false);
// //     }
// //   }

// //   void _editCompany(String companyId, Map<String, dynamic> data) {
// //     setState(() {
// //       isEditing = true;
// //       editingCompanyId = companyId;

// //       // تعبئة البيانات الحالية في النموذج
// //       _companyNameController.text = data['companyName'] ?? '';
// //       _emailController.text = data['email'] ?? '';
// //       _phoneController.text = data['phone'] ?? '';
// //       _addressController.text = data['address'] ?? '';

// //       // تنظيف المندوبين الحاليين وإضافة الجدد
// //       for (var rep in representatives) {
// //         rep.nameController.dispose();
// //         rep.jobController.dispose();
// //         rep.phoneController.dispose();
// //       }

// //       representatives = [];
// //       final repsData = data['representatives'] ?? [];
// //       if (repsData.isEmpty) {
// //         representatives.add(Representative());
// //       } else {
// //         for (var repData in repsData) {
// //           final rep = Representative();
// //           rep.nameController.text = repData['name'] ?? '';
// //           rep.jobController.text = repData['job'] ?? '';
// //           rep.phoneController.text = repData['phone'] ?? '';
// //           representatives.add(rep);
// //         }
// //       }
// //     });
// //   }

// //   void _deleteCompany(String companyId, String companyName) async {
// //     final confirmed = await showDialog<bool>(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         title: const Text('تأكيد الحذف'),
// //         content: Text('هل أنت متأكد من حذف الشركة "$companyName"؟'),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.of(context).pop(false),
// //             child: const Text('إلغاء'),
// //           ),
// //           TextButton(
// //             onPressed: () => Navigator.of(context).pop(true),
// //             child: const Text('حذف', style: TextStyle(color: Colors.red)),
// //           ),
// //         ],
// //       ),
// //     );

// //     if (confirmed == true) {
// //       try {
// //         await _firestore.collection('companies').doc(companyId).delete();
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(
// //             content: Text('تم حذف الشركة بنجاح'),
// //             backgroundColor: Colors.green,
// //           ),
// //         );
// //       } catch (e) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text('خطأ في الحذف: $e'),
// //             backgroundColor: Colors.red,
// //           ),
// //         );
// //       }
// //     }
// //   }

// //   void _cancelEdit() {
// //     setState(() {
// //       isEditing = false;
// //       editingCompanyId = null;
// //       _clearForm();
// //     });
// //   }

// //   // =================== HELPER METHODS ===================
// //   void _addRepresentative() {
// //     setState(() => representatives.add(Representative()));
// //   }

// //   void _removeRepresentative(int index) {
// //     setState(() => representatives.removeAt(index));
// //   }

// //   void _clearForm() {
// //     _formKey.currentState?.reset();
// //     _companyNameController.clear();
// //     _addressController.clear();
// //     _emailController.clear();
// //     _phoneController.clear();

// //     for (var rep in representatives) {
// //       rep.nameController.dispose();
// //       rep.jobController.dispose();
// //       rep.phoneController.dispose();
// //     }

// //     setState(() {
// //       representatives = [Representative()];
// //       isEditing = false;
// //       editingCompanyId = null;
// //     });
// //   }

// //   String? _validateEmail(String? value) {
// //     if (value == null || value.isEmpty) return 'البريد الإلكتروني مطلوب';
// //     if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
// //       return 'بريد غير صحيح';
// //     }
// //     return null;
// //   }

// //   @override
// //   void dispose() {
// //     _companyNameController.dispose();
// //     _addressController.dispose();
// //     _emailController.dispose();
// //     _phoneController.dispose();
// //     for (var rep in representatives) {
// //       rep.nameController.dispose();
// //       rep.jobController.dispose();
// //       rep.phoneController.dispose();
// //     }
// //     super.dispose();
// //   }
// // }

// // // =================== MODEL ===================
// // class Representative {
// //   final TextEditingController nameController = TextEditingController();
// //   final TextEditingController jobController = TextEditingController();
// //   final TextEditingController phoneController = TextEditingController();
// // }
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class CompanyPage extends StatefulWidget {
//   const CompanyPage({super.key});

//   @override
//   State<CompanyPage> createState() => _CompanyPageState();
// }

// class _CompanyPageState extends State<CompanyPage> {
//   final _formKey = GlobalKey<FormState>();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   final _companyNameController = TextEditingController();
//   final _addressController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();

//   List<Representative> representatives = [Representative()];
//   bool isSaving = false;
//   bool isEditing = false;
//   String? editingCompanyId;

//   // متغيرات لإدارة المواقع
//   final _locationNameController = TextEditingController();
//   final _locationAddressController = TextEditingController();
//   String? _selectedCompanyId;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6F8),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           bool isMobile = constraints.maxWidth < 600;
//           bool isTablet = constraints.maxWidth < 1000;

//           return Column(
//             children: [
//               _buildCustomAppBar(isMobile),
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.all(isMobile ? 16 : 24),
//                   child: Center(
//                     child: ConstrainedBox(
//                       constraints: BoxConstraints(maxWidth: 1200),
//                       child: Column(
//                         children: [
//                           // Form Card
//                           Card(
//                             elevation: 8,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(
//                                 isMobile ? 16 : 22,
//                               ),
//                             ),
//                             child: Padding(
//                               padding: EdgeInsets.all(isMobile ? 16 : 32),
//                               child: Form(
//                                 key: _formKey,
//                                 child: Column(
//                                   children: [
//                                     SizedBox(height: isMobile ? 16 : 32),
//                                     _buildCompanyInfoSection(isMobile),
//                                     SizedBox(height: isMobile ? 16 : 32),
//                                     _buildRepresentativesSection(isMobile),
//                                     SizedBox(height: isMobile ? 20 : 40),
//                                     _buildActionButtons(isMobile),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: isMobile ? 16 : 24),
//                           // Companies List
//                           _buildCompaniesList(isMobile),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   // =================== APP BAR ===================
//   Widget _buildCustomAppBar(bool isMobile) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: isMobile ? 16 : 24,
//         vertical: isMobile ? 12 : 20,
//       ),
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.centerRight,
//           end: Alignment.centerLeft,
//           colors: [Color(0xFF1B4F72), Color(0xFF3498DB)],
//         ),
//         boxShadow: [
//           BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
//         ],
//       ),
//       child: SafeArea(
//         child: Row(
//           children: [
//             Icon(Icons.business, color: Colors.white, size: isMobile ? 24 : 32),
//             SizedBox(width: isMobile ? 8 : 12),
//             Text(
//               'إدارة الشركات',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: isMobile ? 18 : 24,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Cairo',
//               ),
//             ),
//             const Spacer(),
//             _buildTimeWidget(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTimeWidget() {
//     return StreamBuilder<DateTime>(
//       stream: Stream.periodic(
//         const Duration(seconds: 1),
//         (_) => DateTime.now(),
//       ),
//       builder: (context, snapshot) {
//         final now = snapshot.data ?? DateTime.now();

//         int hour12 = now.hour % 12;
//         if (hour12 == 0) hour12 = 12;

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               height: 50,
//               width: 150,
//               decoration: BoxDecoration(
//                 color: Colors.transparent,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Center(
//                 child: Text(
//                   '${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 36,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // =================== COMPANY INFO ===================
//   Widget _buildCompanyInfoSection(bool isMobile) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Center(
//           child: Text(
//             isEditing ? 'تعديل بيانات الشركة' : 'بيانات الشركة',
//             style: TextStyle(
//               fontSize: isMobile ? 18 : 20,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xFF2C3E50),
//             ),
//           ),
//         ),
//         SizedBox(height: isMobile ? 12 : 20),
//         _buildField(
//           _companyNameController,
//           'اسم الشركة',
//           Icons.business,
//           isMobile,
//         ),
//         SizedBox(height: isMobile ? 12 : 16),
//         isMobile
//             ? Column(
//                 children: [
//                   _buildField(
//                     _emailController,
//                     'example@company.com',
//                     Icons.email,
//                     isMobile,
//                     keyboardType: TextInputType.emailAddress,
//                     validator: _validateEmail,
//                   ),
//                   SizedBox(height: isMobile ? 12 : 16),
//                   _buildField(
//                     _phoneController,
//                     '01XXXXXXXXX',
//                     Icons.phone,
//                     isMobile,
//                     keyboardType: TextInputType.phone,
//                     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                   ),
//                 ],
//               )
//             : Row(
//                 children: [
//                   Expanded(
//                     child: _buildField(
//                       _emailController,
//                       'example@company.com',
//                       Icons.email,
//                       isMobile,
//                       keyboardType: TextInputType.emailAddress,
//                       validator: _validateEmail,
//                     ),
//                   ),
//                   SizedBox(width: 16),
//                   Expanded(
//                     child: _buildField(
//                       _phoneController,
//                       '01XXXXXXXXX',
//                       Icons.phone,
//                       isMobile,
//                       keyboardType: TextInputType.phone,
//                       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                     ),
//                   ),
//                 ],
//               ),
//         SizedBox(height: isMobile ? 12 : 16),
//         _buildField(
//           _addressController,
//           'العنوان التفصيلي للشركة',
//           Icons.location_on,
//           isMobile,
//           maxLines: 2,
//         ),
//       ],
//     );
//   }

//   // =================== REPRESENTATIVES ===================
//   Widget _buildRepresentativesSection(bool isMobile) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (!isMobile)
//           const Text(
//             'المندوبون',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2C3E50),
//             ),
//           ),
//         if (!isMobile) SizedBox(height: 16),
//         ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: representatives.length,
//           itemBuilder: (context, index) =>
//               _buildRepresentativeCard(index, isMobile),
//         ),
//       ],
//     );
//   }

//   Widget _buildRepresentativeCard(int index, bool isMobile) {
//     return Card(
//       margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(isMobile ? 12 : 20),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Text(
//                   'مندوب ${index + 1}',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: isMobile ? 14 : 16,
//                   ),
//                 ),
//                 const Spacer(),
//                 if (representatives.length > 1)
//                   IconButton(
//                     onPressed: () => _removeRepresentative(index),
//                     icon: Icon(
//                       Icons.delete,
//                       color: Colors.red,
//                       size: isMobile ? 18 : 24,
//                     ),
//                     padding: EdgeInsets.zero,
//                     constraints: BoxConstraints(),
//                   ),
//               ],
//             ),
//             SizedBox(height: isMobile ? 8 : 12),
//             _buildField(
//               representatives[index].nameController,
//               'اسم المندوب',
//               Icons.person,
//               isMobile,
//             ),
//             SizedBox(height: isMobile ? 8 : 12),
//             isMobile
//                 ? Column(
//                     children: [
//                       _buildField(
//                         representatives[index].jobController,
//                         'الوظيفة',
//                         Icons.work,
//                         isMobile,
//                       ),
//                       SizedBox(height: isMobile ? 8 : 12),
//                       _buildField(
//                         representatives[index].phoneController,
//                         '01XXXXXXXXX',
//                         Icons.phone_android,
//                         isMobile,
//                         keyboardType: TextInputType.phone,
//                         inputFormatters: [
//                           FilteringTextInputFormatter.digitsOnly,
//                         ],
//                       ),
//                     ],
//                   )
//                 : Row(
//                     children: [
//                       Expanded(
//                         child: _buildField(
//                           representatives[index].jobController,
//                           'الوظيفة',
//                           Icons.work,
//                           isMobile,
//                         ),
//                       ),
//                       SizedBox(width: 16),
//                       Expanded(
//                         child: _buildField(
//                           representatives[index].phoneController,
//                           '01XXXXXXXXX',
//                           Icons.phone_android,
//                           isMobile,
//                           keyboardType: TextInputType.phone,
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly,
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//             SizedBox(height: isMobile ? 8 : 12),
//             if (index == representatives.length - 1)
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: _addRepresentative,
//                   icon: Icon(
//                     Icons.add,
//                     color: Colors.white,
//                     size: isMobile ? 16 : 20,
//                   ),
//                   label: Text(
//                     'إضافة مندوب',
//                     style: TextStyle(
//                       fontSize: isMobile ? 14 : 16,
//                       color: Colors.white,
//                     ),
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     foregroundColor: Colors.white,
//                     padding: EdgeInsets.symmetric(
//                       horizontal: isMobile ? 12 : 16,
//                       vertical: isMobile ? 10 : 12,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
//                     ),
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   // =================== ACTION BUTTONS ===================
//   Widget _buildActionButtons(bool isMobile) {
//     return isMobile
//         ? Column(
//             children: [
//               ElevatedButton(
//                 onPressed: isSaving ? null : _saveCompanyData,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: isEditing
//                       ? Colors.orange
//                       : const Color(0xFF2E86C1),
//                   minimumSize: const Size(double.infinity, 50),
//                 ),
//                 child: isSaving
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : Text(
//                         isEditing ? 'تحديث البيانات' : 'حفظ البيانات',
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//               ),
//               if (isEditing) ...[
//                 SizedBox(height: 12),
//                 ElevatedButton(
//                   onPressed: isSaving ? null : _cancelEdit,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey,
//                     minimumSize: const Size(double.infinity, 50),
//                   ),
//                   child: const Text(
//                     'إلغاء',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ],
//           )
//         : Row(
//             children: [
//               if (isEditing) ...[
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: isSaving ? null : _cancelEdit,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.grey,
//                       padding: const EdgeInsets.symmetric(vertical: 18),
//                     ),
//                     child: const Text(
//                       'إلغاء',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 16),
//               ],
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: isSaving ? null : _saveCompanyData,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: isEditing
//                         ? Colors.orange
//                         : const Color(0xFF2E86C1),
//                     padding: const EdgeInsets.symmetric(vertical: 18),
//                   ),
//                   child: isSaving
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : Text(
//                           isEditing ? 'تحديث البيانات' : 'حفظ البيانات',
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           );
//   }

//   // =================== COMPANIES LIST ===================
//   Widget _buildCompaniesList(bool isMobile) {
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
//               'قائمة الشركات',
//               style: TextStyle(
//                 fontSize: isMobile ? 18 : 20,
//                 fontWeight: FontWeight.bold,
//                 color: const Color(0xFF2C3E50),
//               ),
//             ),
//             SizedBox(height: isMobile ? 12 : 16),
//             StreamBuilder<QuerySnapshot>(
//               stream: _firestore.collection('companies').snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }

//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final companies = snapshot.data!.docs;

//                 if (companies.isEmpty) {
//                   return const Center(
//                     child: Text(
//                       'لا توجد شركات مسجلة',
//                       style: TextStyle(fontSize: 16, color: Colors.grey),
//                     ),
//                   );
//                 }

//                 return isMobile
//                     ? _buildMobileCompaniesList(companies)
//                     : _buildDesktopCompaniesList(companies);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMobileCompaniesList(List<QueryDocumentSnapshot> companies) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: companies.length,
//       itemBuilder: (context, index) {
//         final company = companies[index];
//         final data = company.data() as Map<String, dynamic>;
//         return _buildMobileCompanyItem(company.id, data);
//       },
//     );
//   }

//   Widget _buildDesktopCompaniesList(List<QueryDocumentSnapshot> companies) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: companies.length,
//       itemBuilder: (context, index) {
//         final company = companies[index];
//         final data = company.data() as Map<String, dynamic>;
//         return _buildDesktopCompanyItem(company.id, data);
//       },
//     );
//   }

//   Widget _buildMobileCompanyItem(String companyId, Map<String, dynamic> data) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 8),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       child: ListTile(
//         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         leading: const Icon(Icons.business, color: Color(0xFF3498DB), size: 20),
//         title: Text(
//           data['companyName'] ?? '',
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '${data['email'] ?? ''}',
//               style: const TextStyle(fontSize: 12),
//             ),
//             Text(
//               '${data['phone'] ?? ''}',
//               style: const TextStyle(fontSize: 12),
//             ),
//             Text(
//               'مواقع: ${data['locations']?.length ?? 0}',
//               style: const TextStyle(fontSize: 11, color: Colors.grey),
//             ),
//           ],
//         ),
//         trailing: PopupMenuButton<String>(
//           icon: const Icon(Icons.more_vert, size: 20),
//           onSelected: (value) {
//             if (value == 'edit') {
//               _editCompany(companyId, data);
//             } else if (value == 'delete') {
//               _deleteCompany(companyId, data['companyName'] ?? '');
//             } else if (value == 'add_location') {
//               _showAddLocationDialog(companyId, data['companyName'] ?? '');
//             } else if (value == 'view_locations') {
//               _viewLocations(companyId, data);
//             }
//           },
//           itemBuilder: (context) => [
//             const PopupMenuItem(value: 'edit', child: Text('تعديل')),
//             const PopupMenuItem(
//               value: 'add_location',
//               child: Text('إضافة موقع'),
//             ),
//             const PopupMenuItem(
//               value: 'view_locations',
//               child: Text('عرض المواقع'),
//             ),
//             const PopupMenuItem(value: 'delete', child: Text('حذف')),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDesktopCompanyItem(String companyId, Map<String, dynamic> data) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ListTile(
//         leading: const Icon(Icons.business, color: Color(0xFF3498DB)),
//         title: Text(
//           data['companyName'] ?? '',
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('البريد: ${data['email'] ?? ''}'),
//             Text('الهاتف: ${data['phone'] ?? ''}'),
//             Text('عدد المندوبين: ${data['representatives']?.length ?? 0}'),
//             Text('عدد المواقع: ${data['locations']?.length ?? 0}'),
//           ],
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.add_location, color: Colors.purple),
//               onPressed: () =>
//                   _showAddLocationDialog(companyId, data['companyName'] ?? ''),
//               tooltip: 'إضافة موقع',
//             ),
//             IconButton(
//               icon: const Icon(Icons.location_on, color: Colors.green),
//               onPressed: () => _viewLocations(companyId, data),
//               tooltip: 'عرض المواقع',
//             ),
//             IconButton(
//               icon: const Icon(Icons.edit, color: Colors.blue),
//               onPressed: () => _editCompany(companyId, data),
//               tooltip: 'تعديل',
//             ),
//             IconButton(
//               icon: const Icon(Icons.delete, color: Colors.red),
//               onPressed: () =>
//                   _deleteCompany(companyId, data['companyName'] ?? ''),
//               tooltip: 'حذف',
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // =================== SHARED FIELD ===================
//   Widget _buildField(
//     TextEditingController controller,
//     String label,
//     IconData icon,
//     bool isMobile, {
//     TextInputType keyboardType = TextInputType.text,
//     String? Function(String?)? validator,
//     List<TextInputFormatter>? inputFormatters,
//     int maxLines = 1,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       inputFormatters: inputFormatters,
//       maxLines: maxLines,
//       style: TextStyle(fontSize: isMobile ? 14 : 16),
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
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

//   // =================== FUNCTIONS FOR LOCATIONS ===================
//   void _showAddLocationDialog(String companyId, String companyName) {
//     _selectedCompanyId = companyId;
//     _locationNameController.clear();
//     _locationAddressController.clear();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('إضافة موقع لشركة: $companyName'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextFormField(
//               controller: _locationNameController,
//               decoration: const InputDecoration(
//                 labelText: 'اسم الموقع',
//                 prefixIcon: Icon(Icons.business),
//               ),
//               validator: (value) =>
//                   value == null || value.isEmpty ? 'هذا الحقل مطلوب' : null,
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: _locationAddressController,
//               decoration: const InputDecoration(
//                 labelText: 'عنوان الموقع',
//                 prefixIcon: Icon(Icons.location_on),
//               ),
//               maxLines: 3,
//               validator: (value) =>
//                   value == null || value.isEmpty ? 'هذا الحقل مطلوب' : null,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: _addLocationToFirebase,
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
//             child: const Text('إضافة'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _addLocationToFirebase() async {
//     if (_locationNameController.text.isEmpty ||
//         _locationAddressController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('يرجى ملء جميع الحقول'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     if (_selectedCompanyId == null) return;

//     try {
//       final companyDoc = await _firestore
//           .collection('companies')
//           .doc(_selectedCompanyId!)
//           .get();
//       final companyData = companyDoc.data() as Map<String, dynamic>;

//       List<dynamic> currentLocations = companyData['locations'] ?? [];

//       final newLocation = {
//         'name': _locationNameController.text.trim(),
//         'address': _locationAddressController.text.trim(),
//         'createdAt': DateTime.now().toIso8601String(),
//       };

//       currentLocations.add(newLocation);

//       await _firestore.collection('companies').doc(_selectedCompanyId!).update({
//         'locations': currentLocations,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('تم إضافة الموقع بنجاح'),
//           backgroundColor: Colors.green,
//         ),
//       );

//       _locationNameController.clear();
//       _locationAddressController.clear();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('خطأ في إضافة الموقع: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   void _viewLocations(String companyId, Map<String, dynamic> data) {
//     final locations = data['locations'] ?? [];

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.all(20),
//           height: MediaQuery.of(context).size.height * 0.7,
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'مواقع ${data['companyName'] ?? ''}',
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: const Icon(Icons.close),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),

//               ElevatedButton.icon(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   _showAddLocationDialog(companyId, data['companyName'] ?? '');
//                 },
//                 icon: const Icon(Icons.add_location),
//                 label: const Text('إضافة موقع جديد'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.purple,
//                   foregroundColor: Colors.white,
//                   minimumSize: const Size(double.infinity, 50),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               Expanded(
//                 child: locations.isEmpty
//                     ? const Center(
//                         child: Text(
//                           'لا توجد مواقع لهذه الشركة',
//                           style: TextStyle(color: Colors.grey, fontSize: 16),
//                         ),
//                       )
//                     : ListView.builder(
//                         itemCount: locations.length,
//                         itemBuilder: (context, index) {
//                           final location = locations[index];
//                           return Card(
//                             margin: const EdgeInsets.only(bottom: 10),
//                             child: ListTile(
//                               leading: const Icon(
//                                 Icons.location_on,
//                                 color: Colors.blue,
//                               ),
//                               title: Text(
//                                 location['name'] ?? 'موقع غير مسمى',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               subtitle: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(location['address'] ?? ''),
//                                   if (location['createdAt'] != null)
//                                     Text(
//                                       'تم الإضافة: ${_formatTimestamp(location['createdAt'])}',
//                                       style: const TextStyle(
//                                         fontSize: 12,
//                                         color: Colors.grey,
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                               trailing: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   IconButton(
//                                     icon: const Icon(
//                                       Icons.edit,
//                                       size: 20,
//                                       color: Colors.blue,
//                                     ),
//                                     onPressed: () => _editLocation(
//                                       companyId,
//                                       index,
//                                       location,
//                                     ),
//                                   ),
//                                   IconButton(
//                                     icon: const Icon(
//                                       Icons.delete,
//                                       size: 20,
//                                       color: Colors.red,
//                                     ),
//                                     onPressed: () => _deleteLocation(
//                                       companyId,
//                                       index,
//                                       location['name'] ?? '',
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _editLocation(
//     String companyId,
//     int index,
//     Map<String, dynamic> location,
//   ) async {
//     final locationNameController = TextEditingController(
//       text: location['name'] ?? '',
//     );
//     final locationAddressController = TextEditingController(
//       text: location['address'] ?? '',
//     );

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('تعديل الموقع'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextFormField(
//               controller: locationNameController,
//               decoration: const InputDecoration(
//                 labelText: 'اسم الموقع',
//                 prefixIcon: Icon(Icons.business),
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: locationAddressController,
//               decoration: const InputDecoration(
//                 labelText: 'عنوان الموقع',
//                 prefixIcon: Icon(Icons.location_on),
//               ),
//               maxLines: 3,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () async {
//               try {
//                 final companyDoc = await _firestore
//                     .collection('companies')
//                     .doc(companyId)
//                     .get();
//                 final companyData = companyDoc.data() as Map<String, dynamic>;

//                 List<dynamic> currentLocations = companyData['locations'] ?? [];

//                 if (index < currentLocations.length) {
//                   currentLocations[index] = {
//                     ...currentLocations[index],
//                     'name': locationNameController.text.trim(),
//                     'address': locationAddressController.text.trim(),
//                     'updatedAt': DateTime.now().toIso8601String(),
//                   };

//                   await _firestore
//                       .collection('companies')
//                       .doc(companyId)
//                       .update({
//                         'locations': currentLocations,
//                         'updatedAt': FieldValue.serverTimestamp(),
//                       });

//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('تم تعديل الموقع بنجاح'),
//                       backgroundColor: Colors.green,
//                     ),
//                   );
//                 }
//               } catch (e) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(
//                     content: Text('خطأ في تعديل الموقع: $e'),
//                     backgroundColor: Colors.red,
//                   ),
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
//             child: const Text('حفظ التعديلات'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _deleteLocation(String companyId, int index, String locationName) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('تأكيد الحذف'),
//         content: Text('هل أنت متأكد من حذف الموقع "$locationName"؟'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('إلغاء'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('حذف', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       try {
//         final companyDoc = await _firestore
//             .collection('companies')
//             .doc(companyId)
//             .get();
//         final companyData = companyDoc.data() as Map<String, dynamic>;

//         List<dynamic> currentLocations = companyData['locations'] ?? [];

//         if (index < currentLocations.length) {
//           currentLocations.removeAt(index);

//           await _firestore.collection('companies').doc(companyId).update({
//             'locations': currentLocations,
//             'updatedAt': FieldValue.serverTimestamp(),
//           });

//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('تم حذف الموقع بنجاح'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('خطأ في حذف الموقع: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   String _formatTimestamp(dynamic timestamp) {
//     if (timestamp == null) return 'غير محدد';

//     if (timestamp is String) {
//       try {
//         final date = DateTime.parse(timestamp);
//         return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
//       } catch (e) {
//         return timestamp;
//       }
//     }

//     return 'غير محدد';
//   }

//   // =================== FIREBASE OPERATIONS ===================
//   void _saveCompanyData() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => isSaving = true);

//     try {
//       final companyData = {
//         'companyName': _companyNameController.text.trim(),
//         'email': _emailController.text.trim(),
//         'phone': _phoneController.text.trim(),
//         'address': _addressController.text.trim(),
//         'representatives': representatives
//             .map(
//               (rep) => {
//                 'name': rep.nameController.text.trim(),
//                 'job': rep.jobController.text.trim(),
//                 'phone': rep.phoneController.text.trim(),
//               },
//             )
//             .toList(),
//         'locations': [],
//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       };

//       if (isEditing) {
//         final currentDoc = await _firestore
//             .collection('companies')
//             .doc(editingCompanyId)
//             .get();
//         final currentData = currentDoc.data() as Map<String, dynamic>;
//         if (currentData['locations'] != null) {
//           companyData['locations'] = currentData['locations'];
//         }

//         await _firestore
//             .collection('companies')
//             .doc(editingCompanyId)
//             .update(companyData);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('تم تحديث بيانات الشركة بنجاح'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         await _firestore.collection('companies').add(companyData);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('تم حفظ البيانات بنجاح'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }

//       _clearForm();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('خطأ في الحفظ: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() => isSaving = false);
//     }
//   }

//   void _editCompany(String companyId, Map<String, dynamic> data) {
//     setState(() {
//       isEditing = true;
//       editingCompanyId = companyId;

//       _companyNameController.text = data['companyName'] ?? '';
//       _emailController.text = data['email'] ?? '';
//       _phoneController.text = data['phone'] ?? '';
//       _addressController.text = data['address'] ?? '';

//       for (var rep in representatives) {
//         rep.nameController.dispose();
//         rep.jobController.dispose();
//         rep.phoneController.dispose();
//       }

//       representatives = [];
//       final repsData = data['representatives'] ?? [];
//       if (repsData.isEmpty) {
//         representatives.add(Representative());
//       } else {
//         for (var repData in repsData) {
//           final rep = Representative();
//           rep.nameController.text = repData['name'] ?? '';
//           rep.jobController.text = repData['job'] ?? '';
//           rep.phoneController.text = repData['phone'] ?? '';
//           representatives.add(rep);
//         }
//       }
//     });
//   }

//   void _deleteCompany(String companyId, String companyName) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('تأكيد الحذف'),
//         content: Text('هل أنت متأكد من حذف الشركة "$companyName"؟'),
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
//         await _firestore.collection('companies').doc(companyId).delete();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('تم حذف الشركة بنجاح'),
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

//   void _cancelEdit() {
//     setState(() {
//       isEditing = false;
//       editingCompanyId = null;
//       _clearForm();
//     });
//   }

//   // =================== HELPER METHODS ===================
//   void _addRepresentative() {
//     setState(() => representatives.add(Representative()));
//   }

//   void _removeRepresentative(int index) {
//     setState(() => representatives.removeAt(index));
//   }

//   void _clearForm() {
//     _formKey.currentState?.reset();
//     _companyNameController.clear();
//     _addressController.clear();
//     _emailController.clear();
//     _phoneController.clear();

//     for (var rep in representatives) {
//       rep.nameController.dispose();
//       rep.jobController.dispose();
//       rep.phoneController.dispose();
//     }

//     setState(() {
//       representatives = [Representative()];
//       isEditing = false;
//       editingCompanyId = null;
//     });
//   }

//   String? _validateEmail(String? value) {
//     if (value == null || value.isEmpty) return 'البريد الإلكتروني مطلوب';
//     if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
//       return 'بريد غير صحيح';
//     }
//     return null;
//   }

//   @override
//   void dispose() {
//     _companyNameController.dispose();
//     _addressController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _locationNameController.dispose();
//     _locationAddressController.dispose();
//     for (var rep in representatives) {
//       rep.nameController.dispose();
//       rep.jobController.dispose();
//       rep.phoneController.dispose();
//     }
//     super.dispose();
//   }
// }

// // =================== MODEL ===================
// class Representative {
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController jobController = TextEditingController();
//   final TextEditingController phoneController = TextEditingController();
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompanyPage extends StatefulWidget {
  const CompanyPage({super.key});

  @override
  State<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _companyNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _commercialRegisterController = TextEditingController(); // جديد
  final _taxCardController = TextEditingController(); // جديد

  List<Representative> representatives = [Representative()];
  bool isSaving = false;
  bool isEditing = false;
  String? editingCompanyId;

  bool _usesTRSystem = false; // جديد - سويتش لنظام TR

  // متغيرات لإدارة المواقع
  final _locationNameController = TextEditingController();
  final _locationAddressController = TextEditingController();
  String? _selectedCompanyId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          bool isTablet = constraints.maxWidth < 1000;

          return Column(
            children: [
              _buildCustomAppBar(isMobile),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 1200),
                      child: Column(
                        children: [
                          // Form Card
                          Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                isMobile ? 16 : 22,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(isMobile ? 16 : 32),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    SizedBox(height: isMobile ? 16 : 32),
                                    _buildCompanyInfoSection(isMobile),
                                    SizedBox(height: isMobile ? 16 : 32),
                                    _buildTRSystemSection(isMobile), // جديد
                                    SizedBox(height: isMobile ? 16 : 32),
                                    _buildRepresentativesSection(isMobile),
                                    SizedBox(height: isMobile ? 20 : 40),
                                    _buildActionButtons(isMobile),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isMobile ? 16 : 24),
                          // Companies List
                          _buildCompaniesList(isMobile),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // =================== APP BAR ===================
  Widget _buildCustomAppBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 12 : 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Color(0xFF1B4F72), Color(0xFF3498DB)],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Icon(Icons.business, color: Colors.white, size: isMobile ? 24 : 32),
            SizedBox(width: isMobile ? 8 : 12),
            Text(
              'إدارة الشركات',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 18 : 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            const Spacer(),
            _buildTimeWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeWidget() {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(
        const Duration(seconds: 1),
        (_) => DateTime.now(),
      ),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();

        int hour12 = now.hour % 12;
        if (hour12 == 0) hour12 = 12;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 50,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // =================== COMPANY INFO ===================
  Widget _buildCompanyInfoSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            isEditing ? 'تعديل بيانات الشركة' : 'بيانات الشركة',
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
        ),
        SizedBox(height: isMobile ? 12 : 20),
        _buildField(
          _companyNameController,
          'اسم الشركة',
          Icons.business,
          isMobile,
        ),
        SizedBox(height: isMobile ? 12 : 16),
        isMobile
            ? Column(
                children: [
                  _buildField(
                    _emailController,
                    'example@company.com',
                    Icons.email,
                    isMobile,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  SizedBox(height: isMobile ? 12 : 16),
                  _buildField(
                    _phoneController,
                    '01XXXXXXXXX',
                    Icons.phone,
                    isMobile,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _buildField(
                      _emailController,
                      'example@company.com',
                      Icons.email,
                      isMobile,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildField(
                      _phoneController,
                      '01XXXXXXXXX',
                      Icons.phone,
                      isMobile,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
        SizedBox(height: isMobile ? 12 : 16),
        _buildField(
          _addressController,
          'العنوان التفصيلي للشركة',
          Icons.location_on,
          isMobile,
          maxLines: 2,
        ),
      ],
    );
  }

  // =================== TR SYSTEM SECTION - جديد ===================
  Widget _buildTRSystemSection(bool isMobile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'نظام TR والمستندات',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: isMobile ? 12 : 16),

            // سويتش لنظام TR
            SwitchListTile.adaptive(
              title: Text(
                'هل الشركة تعمل بنظام TR؟',
                style: TextStyle(fontSize: isMobile ? 14 : 16),
              ),
              value: _usesTRSystem,
              onChanged: (value) {
                setState(() {
                  _usesTRSystem = value;
                });
              },
              activeColor: Colors.green,
            ),

            SizedBox(height: isMobile ? 12 : 16),

            // حقل السجل التجاري
            _buildField(
              _commercialRegisterController,
              'رقم السجل التجاري',
              Icons.description,
              isMobile,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            SizedBox(height: isMobile ? 12 : 16),

            // حقل البطاقة الضريبية
            _buildField(
              _taxCardController,
              'رقم البطاقة الضريبية',
              Icons.credit_card,
              isMobile,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
      ),
    );
  }

  // =================== REPRESENTATIVES ===================
  Widget _buildRepresentativesSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isMobile)
          const Text(
            'المندوبون',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
        if (!isMobile) SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: representatives.length,
          itemBuilder: (context, index) =>
              _buildRepresentativeCard(index, isMobile),
        ),
      ],
    );
  }

  Widget _buildRepresentativeCard(int index, bool isMobile) {
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'مندوب ${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
                const Spacer(),
                if (representatives.length > 1)
                  IconButton(
                    onPressed: () => _removeRepresentative(index),
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: isMobile ? 18 : 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
              ],
            ),
            SizedBox(height: isMobile ? 8 : 12),
            _buildField(
              representatives[index].nameController,
              'اسم المندوب',
              Icons.person,
              isMobile,
            ),
            SizedBox(height: isMobile ? 8 : 12),
            isMobile
                ? Column(
                    children: [
                      _buildField(
                        representatives[index].jobController,
                        'الوظيفة',
                        Icons.work,
                        isMobile,
                      ),
                      SizedBox(height: isMobile ? 8 : 12),
                      _buildField(
                        representatives[index].phoneController,
                        '01XXXXXXXXX',
                        Icons.phone_android,
                        isMobile,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          representatives[index].jobController,
                          'الوظيفة',
                          Icons.work,
                          isMobile,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildField(
                          representatives[index].phoneController,
                          '01XXXXXXXXX',
                          Icons.phone_android,
                          isMobile,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    ],
                  ),
            SizedBox(height: isMobile ? 8 : 12),
            if (index == representatives.length - 1)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addRepresentative,
                  icon: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: isMobile ? 16 : 20,
                  ),
                  label: Text(
                    'إضافة مندوب',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 16,
                      vertical: isMobile ? 10 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // =================== ACTION BUTTONS ===================
  Widget _buildActionButtons(bool isMobile) {
    return isMobile
        ? Column(
            children: [
              ElevatedButton(
                onPressed: isSaving ? null : _saveCompanyData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEditing
                      ? Colors.orange
                      : const Color(0xFF2E86C1),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isEditing ? 'تحديث البيانات' : 'حفظ البيانات',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
              if (isEditing) ...[
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: isSaving ? null : _cancelEdit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          )
        : Row(
            children: [
              if (isEditing) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _cancelEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: isSaving ? null : _saveCompanyData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEditing
                        ? Colors.orange
                        : const Color(0xFF2E86C1),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEditing ? 'تحديث البيانات' : 'حفظ البيانات',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          );
  }

  // =================== COMPANIES LIST ===================
  Widget _buildCompaniesList(bool isMobile) {
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
              'قائمة الشركات',
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: isMobile ? 12 : 16),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('companies').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final companies = snapshot.data!.docs;

                if (companies.isEmpty) {
                  return const Center(
                    child: Text(
                      'لا توجد شركات مسجلة',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return isMobile
                    ? _buildMobileCompaniesList(companies)
                    : _buildDesktopCompaniesList(companies);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileCompaniesList(List<QueryDocumentSnapshot> companies) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: companies.length,
      itemBuilder: (context, index) {
        final company = companies[index];
        final data = company.data() as Map<String, dynamic>;
        return _buildMobileCompanyItem(company.id, data);
      },
    );
  }

  Widget _buildDesktopCompaniesList(List<QueryDocumentSnapshot> companies) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: companies.length,
      itemBuilder: (context, index) {
        final company = companies[index];
        final data = company.data() as Map<String, dynamic>;
        return _buildDesktopCompanyItem(company.id, data);
      },
    );
  }

  Widget _buildMobileCompanyItem(String companyId, Map<String, dynamic> data) {
    final usesTR = data['usesTRSystem'] ?? false; // جديد

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: const Icon(Icons.business, color: Color(0xFF3498DB), size: 20),
        title: Text(
          data['companyName'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${data['email'] ?? ''}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              '${data['phone'] ?? ''}',
              style: const TextStyle(fontSize: 12),
            ),
            // جديد - عرض حالة نظام TR
            Text(
              usesTR ? 'تعمل بـ TR' : 'لا تعمل بـ TR',
              style: TextStyle(
                fontSize: 11,
                color: usesTR ? Colors.green : Colors.grey,
              ),
            ),
            Text(
              'مواقع: ${data['locations']?.length ?? 0}',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 20),
          onSelected: (value) {
            if (value == 'edit') {
              _editCompany(companyId, data);
            } else if (value == 'delete') {
              _deleteCompany(companyId, data['companyName'] ?? '');
            } else if (value == 'add_location') {
              _showAddLocationDialog(companyId, data['companyName'] ?? '');
            } else if (value == 'view_locations') {
              _viewLocations(companyId, data);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('تعديل')),
            const PopupMenuItem(
              value: 'add_location',
              child: Text('إضافة موقع'),
            ),
            const PopupMenuItem(
              value: 'view_locations',
              child: Text('عرض المواقع'),
            ),
            const PopupMenuItem(value: 'delete', child: Text('حذف')),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopCompanyItem(String companyId, Map<String, dynamic> data) {
    final usesTR = data['usesTRSystem'] ?? false; // جديد

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.business, color: Color(0xFF3498DB)),
        title: Text(
          data['companyName'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('البريد: ${data['email'] ?? ''}'),
            Text('الهاتف: ${data['phone'] ?? ''}'),
            // جديد - عرض نظام TR
            Text('نظام TR: ${usesTR ? 'نعم' : 'لا'}'),
            Text('عدد المندوبين: ${data['representatives']?.length ?? 0}'),
            Text('عدد المواقع: ${data['locations']?.length ?? 0}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add_location, color: Colors.purple),
              onPressed: () =>
                  _showAddLocationDialog(companyId, data['companyName'] ?? ''),
              tooltip: 'إضافة موقع',
            ),
            IconButton(
              icon: const Icon(Icons.location_on, color: Colors.green),
              onPressed: () => _viewLocations(companyId, data),
              tooltip: 'عرض المواقع',
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editCompany(companyId, data),
              tooltip: 'تعديل',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  _deleteCompany(companyId, data['companyName'] ?? ''),
              tooltip: 'حذف',
            ),
          ],
        ),
      ),
    );
  }

  // =================== SHARED FIELD ===================
  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon,
    bool isMobile, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: TextStyle(fontSize: isMobile ? 14 : 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
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

  // =================== FUNCTIONS FOR LOCATIONS ===================
  void _showAddLocationDialog(String companyId, String companyName) {
    _selectedCompanyId = companyId;
    _locationNameController.clear();
    _locationAddressController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة موقع لشركة: $companyName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _locationNameController,
              decoration: const InputDecoration(
                labelText: 'اسم الموقع',
                prefixIcon: Icon(Icons.business),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'هذا الحقل مطلوب' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationAddressController,
              decoration: const InputDecoration(
                labelText: 'عنوان الموقع',
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 3,
              validator: (value) =>
                  value == null || value.isEmpty ? 'هذا الحقل مطلوب' : null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: _addLocationToFirebase,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _addLocationToFirebase() async {
    if (_locationNameController.text.isEmpty ||
        _locationAddressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى ملء جميع الحقول'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCompanyId == null) return;

    try {
      final companyDoc = await _firestore
          .collection('companies')
          .doc(_selectedCompanyId!)
          .get();
      final companyData = companyDoc.data() as Map<String, dynamic>;

      List<dynamic> currentLocations = companyData['locations'] ?? [];

      final newLocation = {
        'name': _locationNameController.text.trim(),
        'address': _locationAddressController.text.trim(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      currentLocations.add(newLocation);

      await _firestore.collection('companies').doc(_selectedCompanyId!).update({
        'locations': currentLocations,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إضافة الموقع بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      _locationNameController.clear();
      _locationAddressController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في إضافة الموقع: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewLocations(String companyId, Map<String, dynamic> data) {
    final locations = data['locations'] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'مواقع ${data['companyName'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showAddLocationDialog(companyId, data['companyName'] ?? '');
                },
                icon: const Icon(Icons.add_location),
                label: const Text('إضافة موقع جديد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: locations.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد مواقع لهذه الشركة',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      )
                    : ListView.builder(
                        itemCount: locations.length,
                        itemBuilder: (context, index) {
                          final location = locations[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: const Icon(
                                Icons.location_on,
                                color: Colors.blue,
                              ),
                              title: Text(
                                location['name'] ?? 'موقع غير مسمى',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(location['address'] ?? ''),
                                  if (location['createdAt'] != null)
                                    Text(
                                      'تم الإضافة: ${_formatTimestamp(location['createdAt'])}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 20,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => _editLocation(
                                      companyId,
                                      index,
                                      location,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _deleteLocation(
                                      companyId,
                                      index,
                                      location['name'] ?? '',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editLocation(
    String companyId,
    int index,
    Map<String, dynamic> location,
  ) async {
    final locationNameController = TextEditingController(
      text: location['name'] ?? '',
    );
    final locationAddressController = TextEditingController(
      text: location['address'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الموقع'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: locationNameController,
              decoration: const InputDecoration(
                labelText: 'اسم الموقع',
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: locationAddressController,
              decoration: const InputDecoration(
                labelText: 'عنوان الموقع',
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final companyDoc = await _firestore
                    .collection('companies')
                    .doc(companyId)
                    .get();
                final companyData = companyDoc.data() as Map<String, dynamic>;

                List<dynamic> currentLocations = companyData['locations'] ?? [];

                if (index < currentLocations.length) {
                  currentLocations[index] = {
                    ...currentLocations[index],
                    'name': locationNameController.text.trim(),
                    'address': locationAddressController.text.trim(),
                    'updatedAt': DateTime.now().toIso8601String(),
                  };

                  await _firestore
                      .collection('companies')
                      .doc(companyId)
                      .update({
                        'locations': currentLocations,
                        'updatedAt': FieldValue.serverTimestamp(),
                      });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تعديل الموقع بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ في تعديل الموقع: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('حفظ التعديلات'),
          ),
        ],
      ),
    );
  }

  void _deleteLocation(String companyId, int index, String locationName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الموقع "$locationName"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final companyDoc = await _firestore
            .collection('companies')
            .doc(companyId)
            .get();
        final companyData = companyDoc.data() as Map<String, dynamic>;

        List<dynamic> currentLocations = companyData['locations'] ?? [];

        if (index < currentLocations.length) {
          currentLocations.removeAt(index);

          await _firestore.collection('companies').doc(companyId).update({
            'locations': currentLocations,
            'updatedAt': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف الموقع بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حذف الموقع: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'غير محدد';

    if (timestamp is String) {
      try {
        final date = DateTime.parse(timestamp);
        return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
      } catch (e) {
        return timestamp;
      }
    }

    return 'غير محدد';
  }

  // =================== FIREBASE OPERATIONS ===================
  void _saveCompanyData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSaving = true);

    try {
      final companyData = {
        'companyName': _companyNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'usesTRSystem': _usesTRSystem, // جديد
        'commercialRegister': _commercialRegisterController.text.trim(), // جديد
        'taxCard': _taxCardController.text.trim(), // جديد
        'representatives': representatives
            .map(
              (rep) => {
                'name': rep.nameController.text.trim(),
                'job': rep.jobController.text.trim(),
                'phone': rep.phoneController.text.trim(),
              },
            )
            .toList(),
        'locations': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (isEditing) {
        final currentDoc = await _firestore
            .collection('companies')
            .doc(editingCompanyId)
            .get();
        final currentData = currentDoc.data() as Map<String, dynamic>;
        if (currentData['locations'] != null) {
          companyData['locations'] = currentData['locations'];
        }

        await _firestore
            .collection('companies')
            .doc(editingCompanyId)
            .update(companyData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث بيانات الشركة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await _firestore.collection('companies').add(companyData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ البيانات بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }

      _clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في الحفظ: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isSaving = false);
    }
  }

  void _editCompany(String companyId, Map<String, dynamic> data) {
    setState(() {
      isEditing = true;
      editingCompanyId = companyId;

      _companyNameController.text = data['companyName'] ?? '';
      _emailController.text = data['email'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _addressController.text = data['address'] ?? '';
      _usesTRSystem = data['usesTRSystem'] ?? false; // جديد
      _commercialRegisterController.text =
          data['commercialRegister'] ?? ''; // جديد
      _taxCardController.text = data['taxCard'] ?? ''; // جديد

      for (var rep in representatives) {
        rep.nameController.dispose();
        rep.jobController.dispose();
        rep.phoneController.dispose();
      }

      representatives = [];
      final repsData = data['representatives'] ?? [];
      if (repsData.isEmpty) {
        representatives.add(Representative());
      } else {
        for (var repData in repsData) {
          final rep = Representative();
          rep.nameController.text = repData['name'] ?? '';
          rep.jobController.text = repData['job'] ?? '';
          rep.phoneController.text = repData['phone'] ?? '';
          representatives.add(rep);
        }
      }
    });
  }

  void _deleteCompany(String companyId, String companyName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الشركة "$companyName"؟'),
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
        await _firestore.collection('companies').doc(companyId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الشركة بنجاح'),
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

  void _cancelEdit() {
    setState(() {
      isEditing = false;
      editingCompanyId = null;
      _clearForm();
    });
  }

  // =================== HELPER METHODS ===================
  void _addRepresentative() {
    setState(() => representatives.add(Representative()));
  }

  void _removeRepresentative(int index) {
    setState(() => representatives.removeAt(index));
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _companyNameController.clear();
    _addressController.clear();
    _emailController.clear();
    _phoneController.clear();
    _commercialRegisterController.clear(); // جديد
    _taxCardController.clear(); // جديد
    _usesTRSystem = false; // جديد

    for (var rep in representatives) {
      rep.nameController.dispose();
      rep.jobController.dispose();
      rep.phoneController.dispose();
    }

    setState(() {
      representatives = [Representative()];
      isEditing = false;
      editingCompanyId = null;
    });
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'البريد الإلكتروني مطلوب';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'بريد غير صحيح';
    }
    return null;
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _commercialRegisterController.dispose(); // جديد
    _taxCardController.dispose(); // جديد
    _locationNameController.dispose();
    _locationAddressController.dispose();
    for (var rep in representatives) {
      rep.nameController.dispose();
      rep.jobController.dispose();
      rep.phoneController.dispose();
    }
    super.dispose();
  }
}

// =================== MODEL ===================
class Representative {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
}
