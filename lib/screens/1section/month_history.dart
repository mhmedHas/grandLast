// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:last/models/models.dart';

// // class MonthlyRecordPage extends StatefulWidget {
// //   const MonthlyRecordPage({super.key});

// //   @override
// //   State<MonthlyRecordPage> createState() => _MonthlyRecordPageState();
// // }

// // class _MonthlyRecordPageState extends State<MonthlyRecordPage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   String _searchQuery = '';
// //   DateTime? _selectedDate;

// //   // دالة مساعدة لتحويل البيانات بأمان
// //   Map<String, dynamic> _safeConvertDocumentData(Object? data) {
// //     if (data == null) {
// //       return {};
// //     }

// //     if (data is Map<String, dynamic>) {
// //       return data;
// //     }

// //     if (data is Map<dynamic, dynamic>) {
// //       return data.cast<String, dynamic>();
// //     }

// //     return {};
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF4F6F8),
// //       body: LayoutBuilder(
// //         builder: (context, constraints) {
// //           final bool isMobile = constraints.maxWidth < 600;

// //           return Column(
// //             children: [
// //               _buildCustomAppBar(isMobile),
// //               _buildFilterSection(isMobile),
// //               Expanded(child: _buildCompaniesWithWorkList(isMobile)),
// //             ],
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   Widget _buildCustomAppBar(bool isMobile) {
// //     return Container(
// //       padding: EdgeInsets.symmetric(
// //         horizontal: isMobile ? 16 : 24,
// //         vertical: isMobile ? 16 : 20,
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
// //             Icon(
// //               Icons.calendar_month,
// //               color: Colors.white,
// //               size: isMobile ? 28 : 32,
// //             ),
// //             SizedBox(width: isMobile ? 8 : 12),
// //             Text(
// //               'السجل الشهري',
// //               style: TextStyle(
// //                 color: Colors.white,
// //                 fontSize: isMobile ? 20 : 24,
// //                 fontWeight: FontWeight.bold,
// //                 fontFamily: 'Cairo',
// //               ),
// //             ),
// //             const Spacer(flex: 12),
// //             StreamBuilder<DateTime>(
// //               stream: Stream.periodic(
// //                 const Duration(seconds: 1),
// //                 (_) => DateTime.now(),
// //               ),
// //               builder: (context, snapshot) {
// //                 final now = snapshot.data ?? DateTime.now();

// //                 // تحويل إلى نظام 12 ساعة
// //                 int hour12 = now.hour % 12;
// //                 if (hour12 == 0) hour12 = 12; // تحويل 0 إلى 12

// //                 // تحديد AM/PM
// //                 String period = now.hour < 12 ? 'AM' : 'PM';

// //                 return Column(
// //                   crossAxisAlignment: CrossAxisAlignment.center,
// //                   children: [
// //                     Container(
// //                       height: 50,
// //                       width: 150,
// //                       decoration: BoxDecoration(
// //                         color: Colors.transparent,
// //                         borderRadius: BorderRadius.circular(16),
// //                       ),
// //                       child: Center(
// //                         child: Text(
// //                           '${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ',
// //                           style: const TextStyle(
// //                             color: Colors.white,
// //                             fontSize: 36,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 );
// //               },
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildFilterSection(bool isMobile) {
// //     return Container(
// //       padding: EdgeInsets.all(isMobile ? 12 : 16),
// //       color: Colors.white,
// //       child: Column(
// //         children: [
// //           _buildSearchBar(isMobile),
// //           SizedBox(height: isMobile ? 12 : 16),
// //           _buildDateFilter(isMobile),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildSearchBar(bool isMobile) {
// //     return Container(
// //       padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
// //       decoration: BoxDecoration(
// //         color: const Color(0xFFF4F6F8),
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: const Color(0xFF3498DB)),
// //       ),
// //       child: Row(
// //         children: [
// //           Icon(
// //             Icons.search,
// //             color: const Color(0xFF3498DB),
// //             size: isMobile ? 20 : 24,
// //           ),
// //           SizedBox(width: isMobile ? 8 : 12),
// //           Expanded(
// //             child: TextField(
// //               onChanged: (value) => setState(() => _searchQuery = value),
// //               decoration: const InputDecoration(
// //                 hintText: 'ابحث عن شركة...',
// //                 border: InputBorder.none,
// //                 hintStyle: TextStyle(color: Colors.grey),
// //               ),
// //             ),
// //           ),
// //           if (_searchQuery.isNotEmpty)
// //             GestureDetector(
// //               onTap: () => setState(() => _searchQuery = ''),
// //               child: Icon(
// //                 Icons.clear,
// //                 size: isMobile ? 18 : 20,
// //                 color: Colors.grey,
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildDateFilter(bool isMobile) {
// //     return Row(
// //       children: [
// //         Expanded(
// //           child: InkWell(
// //             onTap: () => _selectDate(context),
// //             child: Container(
// //               padding: EdgeInsets.symmetric(
// //                 horizontal: isMobile ? 12 : 16,
// //                 vertical: isMobile ? 10 : 12,
// //               ),
// //               decoration: BoxDecoration(
// //                 color: const Color(0xFFF4F6F8),
// //                 borderRadius: BorderRadius.circular(12),
// //                 border: Border.all(color: const Color(0xFF3498DB)),
// //               ),
// //               child: Row(
// //                 children: [
// //                   Icon(
// //                     Icons.calendar_today,
// //                     color: const Color(0xFF3498DB),
// //                     size: isMobile ? 18 : 20,
// //                   ),
// //                   SizedBox(width: isMobile ? 8 : 12),
// //                   Expanded(
// //                     child: Text(
// //                       _selectedDate != null
// //                           ? _formatDate(_selectedDate!)
// //                           : 'جميع التواريخ',
// //                       style: TextStyle(
// //                         fontSize: isMobile ? 13 : 14,
// //                         color: _selectedDate != null
// //                             ? Colors.black
// //                             : Colors.grey,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //         SizedBox(width: isMobile ? 8 : 12),
// //         if (_selectedDate != null)
// //           IconButton(
// //             icon: Icon(
// //               Icons.clear,
// //               color: Colors.red,
// //               size: isMobile ? 20 : 24,
// //             ),
// //             onPressed: () => setState(() => _selectedDate = null),
// //           ),
// //       ],
// //     );
// //   }

// //   Widget _buildCompaniesWithWorkList(bool isMobile) {
// //     return FutureBuilder<List<Map<String, dynamic>>>(
// //       future: _getCompaniesWithWork(),
// //       builder: (context, snapshot) {
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Center(child: CircularProgressIndicator());
// //         }

// //         if (snapshot.hasError) {
// //           return Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(Icons.error, size: isMobile ? 48 : 64, color: Colors.red),
// //                 SizedBox(height: isMobile ? 12 : 16),
// //                 Text(
// //                   'خطأ في تحميل البيانات: ${snapshot.error}',
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(fontSize: isMobile ? 14 : 16),
// //                 ),
// //               ],
// //             ),
// //           );
// //         }

// //         final companiesList = snapshot.data ?? [];

// //         final filteredCompanies = companiesList
// //             .where((company) {
// //               if (_searchQuery.isEmpty) return true;
// //               final companyName =
// //                   company['companyName']?.toString().toLowerCase() ?? '';
// //               return companyName.contains(_searchQuery.toLowerCase());
// //             })
// //             .where((company) {
// //               return (company['workCount'] as int) > 0;
// //             })
// //             .toList();

// //         if (filteredCompanies.isEmpty) {
// //           return Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(
// //                   Icons.business,
// //                   size: isMobile ? 60 : 80,
// //                   color: Colors.grey,
// //                 ),
// //                 SizedBox(height: isMobile ? 12 : 16),
// //                 Text(
// //                   'لا توجد شركات لديها شغل يومي',
// //                   style: TextStyle(
// //                     fontSize: isMobile ? 16 : 18,
// //                     color: Colors.grey,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                   textAlign: TextAlign.center,
// //                 ),
// //                 SizedBox(height: isMobile ? 4 : 8),
// //                 Text(
// //                   _searchQuery.isEmpty
// //                       ? 'أضف شغل يومي جديد للبدء'
// //                       : 'لم يتم العثور على نتائج البحث',
// //                   style: TextStyle(
// //                     color: Colors.grey,
// //                     fontSize: isMobile ? 12 : 14,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           );
// //         }

// //         return ListView.builder(
// //           padding: EdgeInsets.all(isMobile ? 12 : 16),
// //           itemCount: filteredCompanies.length,
// //           itemBuilder: (context, index) {
// //             final companyData = filteredCompanies[index];
// //             return _buildCompanyItem(
// //               companyData['companyId'] as String,
// //               companyData,
// //               isMobile,
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }

// //   Future<List<Map<String, dynamic>>> _getCompaniesWithWork() async {
// //     try {
// //       final dailyWorksSnapshot = await _firestore
// //           .collection('dailyWork')
// //           .where(
// //             'date',
// //             isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(2020)),
// //           )
// //           .get();

// //       final companyData = <String, Map<String, dynamic>>{};

// //       for (final work in dailyWorksSnapshot.docs) {
// //         final data = _safeConvertDocumentData(work.data());
// //         final companyId = data['companyId']?.toString() ?? '';
// //         final companyName = data['companyName']?.toString() ?? '';
// //         final workDate = (data['date'] as Timestamp?)?.toDate();

// //         if (companyId.isEmpty || companyName.isEmpty) continue;

// //         if (_selectedDate != null && workDate != null) {
// //           final startOfDay = DateTime(
// //             _selectedDate!.year,
// //             _selectedDate!.month,
// //             _selectedDate!.day,
// //           );
// //           final endOfDay = DateTime(
// //             _selectedDate!.year,
// //             _selectedDate!.month,
// //             _selectedDate!.day,
// //             23,
// //             59,
// //             59,
// //           );

// //           if (workDate.isBefore(startOfDay) || workDate.isAfter(endOfDay)) {
// //             continue;
// //           }
// //         }

// //         if (!companyData.containsKey(companyId)) {
// //           companyData[companyId] = {
// //             'companyId': companyId,
// //             'companyName': companyName,
// //             'workCount': 0,
// //           };
// //         }

// //         companyData[companyId]!['workCount'] =
// //             (companyData[companyId]!['workCount'] as int) + 1;
// //       }

// //       return companyData.values.toList();
// //     } catch (e) {
// //       print('Error getting companies with work: $e');
// //       throw e;
// //     }
// //   }

// //   Widget _buildCompanyItem(
// //     String companyId,
// //     Map<String, dynamic> data,
// //     bool isMobile,
// //   ) {
// //     final companyName = data['companyName']?.toString() ?? '';
// //     final workCount = data['workCount'] as int? ?? 0;

// //     return Container(
// //       margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: const Color(0xFF3498DB).withOpacity(0.3)),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 8,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: ListTile(
// //         onTap: () => _showCompanyDetails(companyId, companyName, isMobile),
// //         leading: Container(
// //           width: isMobile ? 45 : 50,
// //           height: isMobile ? 45 : 50,
// //           decoration: BoxDecoration(
// //             color: const Color(0xFF3498DB),
// //             borderRadius: BorderRadius.circular(isMobile ? 22.5 : 25),
// //           ),
// //           child: Center(
// //             child: Text(
// //               workCount.toString(),
// //               style: TextStyle(
// //                 color: Colors.white,
// //                 fontSize: isMobile ? 14 : 16,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           ),
// //         ),
// //         title: Text(
// //           companyName,
// //           style: TextStyle(
// //             fontSize: isMobile ? 15 : 16,
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //           ),
// //         ),
// //         subtitle: Text(
// //           '$workCount نقلة',
// //           style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.grey),
// //         ),
// //         trailing: Icon(
// //           Icons.arrow_forward_ios,
// //           color: const Color(0xFF3498DB),
// //           size: isMobile ? 14 : 16,
// //         ),
// //       ),
// //     );
// //   }

// //   // ====================================================
// //   // دالة تعديل الشغل اليومي
// //   // ====================================================
// //   void _editDailyWork(DailyWork dailyWork, String companyName, bool isMobile) {
// //     // Controllers للحقول
// //     final driverNameController = TextEditingController(
// //       text: dailyWork.driverName,
// //     );
// //     final loadingLocationController = TextEditingController(
// //       text: dailyWork.loadingLocation,
// //     );
// //     final unloadingLocationController = TextEditingController(
// //       text: dailyWork.unloadingLocation,
// //     );
// //     final ohdaController = TextEditingController(text: dailyWork.ohda);
// //     final kartaController = TextEditingController(text: dailyWork.karta);

// //     showDialog(
// //       context: context,
// //       builder: (context) => Directionality(
// //         textDirection: TextDirection.rtl,
// //         child: Dialog(
// //           backgroundColor: Colors.white,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(16),
// //           ),
// //           child: SingleChildScrollView(
// //             child: Container(
// //               padding: EdgeInsets.all(isMobile ? 16 : 24),
// //               width:
// //                   MediaQuery.of(context).size.width * (isMobile ? 0.95 : 0.9),
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   // العنوان
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       Text(
// //                         'تعديل النقلة',
// //                         style: TextStyle(
// //                           fontSize: isMobile ? 18 : 20,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                       IconButton(
// //                         icon: Icon(Icons.close, size: isMobile ? 20 : 24),
// //                         onPressed: () => Navigator.pop(context),
// //                       ),
// //                     ],
// //                   ),

// //                   SizedBox(height: isMobile ? 4 : 8),
// //                   Divider(color: const Color(0xFF3498DB).withOpacity(0.3)),

// //                   // معلومات الشركة
// //                   Container(
// //                     padding: EdgeInsets.all(isMobile ? 10 : 12),
// //                     decoration: BoxDecoration(
// //                       color: const Color(0xFF3498DB).withOpacity(0.1),
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: Row(
// //                       children: [
// //                         Icon(
// //                           Icons.business,
// //                           color: const Color(0xFF3498DB),
// //                           size: isMobile ? 18 : 20,
// //                         ),
// //                         SizedBox(width: isMobile ? 6 : 8),
// //                         Text(
// //                           companyName,
// //                           style: TextStyle(
// //                             fontWeight: FontWeight.bold,
// //                             color: const Color(0xFF2C3E50),
// //                             fontSize: isMobile ? 14 : 16,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),

// //                   // عرض اسم الموقع (للقراءة فقط)
// //                   Container(
// //                     margin: EdgeInsets.only(top: 12),
// //                     padding: EdgeInsets.all(isMobile ? 10 : 12),
// //                     decoration: BoxDecoration(
// //                       color: Colors.blue[50],
// //                       borderRadius: BorderRadius.circular(8),
// //                       border: Border.all(color: Colors.blue),
// //                     ),
// //                     child: Row(
// //                       children: [
// //                         Icon(
// //                           Icons.map,
// //                           color: Colors.blue[700],
// //                           size: isMobile ? 16 : 18,
// //                         ),
// //                         SizedBox(width: isMobile ? 6 : 8),
// //                         Expanded(
// //                           child: Column(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               Text(
// //                                 'اسم الموقع (من عرض السعر):',
// //                                 style: TextStyle(
// //                                   fontSize: isMobile ? 12 : 14,
// //                                   color: Colors.grey[600],
// //                                 ),
// //                               ),
// //                               SizedBox(height: 4),
// //                               Text(
// //                                 dailyWork.selectedRoute ?? '',
// //                                 style: TextStyle(
// //                                   fontSize: isMobile ? 14 : 16,
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Colors.blue[700],
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),

// //                   SizedBox(height: isMobile ? 16 : 20),

// //                   // حقل اسم السائق
// //                   _buildEditField(
// //                     'اسم السائق',
// //                     'أدخل اسم السائق',
// //                     driverNameController,
// //                     Icons.person,
// //                     isMobile,
// //                   ),

// //                   SizedBox(height: isMobile ? 12 : 16),

// //                   // حقل مكان التحميل
// //                   _buildEditField(
// //                     'مكان التحميل',
// //                     'أدخل مكان التحميل',
// //                     loadingLocationController,
// //                     Icons.location_on,
// //                     isMobile,
// //                   ),

// //                   SizedBox(height: isMobile ? 12 : 16),

// //                   // حقل مكان التعتيق
// //                   _buildEditField(
// //                     'مكان التعتيق',
// //                     'أدخل مكان التعتيق',
// //                     unloadingLocationController,
// //                     Icons.location_on,
// //                     isMobile,
// //                   ),

// //                   SizedBox(height: isMobile ? 12 : 16),

// //                   // صف العهدة والكارتة
// //                   Row(
// //                     children: [
// //                       Expanded(
// //                         child: _buildEditField(
// //                           'العهدة',
// //                           'أدخل العهدة',
// //                           ohdaController,
// //                           Icons.assignment,
// //                           isMobile,
// //                         ),
// //                       ),
// //                       SizedBox(width: isMobile ? 8 : 12),
// //                       Expanded(
// //                         child: _buildEditField(
// //                           'الكارتة',
// //                           'أدخل الكارتة',
// //                           kartaController,
// //                           Icons.credit_card,
// //                           isMobile,
// //                         ),
// //                       ),
// //                     ],
// //                   ),

// //                   SizedBox(height: isMobile ? 20 : 24),

// //                   // أزرار الحفظ والإلغاء
// //                   Row(
// //                     children: [
// //                       Expanded(
// //                         child: OutlinedButton(
// //                           onPressed: () => Navigator.pop(context),
// //                           style: OutlinedButton.styleFrom(
// //                             padding: EdgeInsets.symmetric(
// //                               vertical: isMobile ? 10 : 12,
// //                             ),
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(8),
// //                             ),
// //                           ),
// //                           child: Text(
// //                             'إلغاء',
// //                             style: TextStyle(
// //                               color: const Color(0xFF2C3E50),
// //                               fontWeight: FontWeight.bold,
// //                               fontSize: isMobile ? 14 : 16,
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                       SizedBox(width: isMobile ? 8 : 12),
// //                       Expanded(
// //                         child: ElevatedButton(
// //                           onPressed: () async {
// //                             // عرض تأكيد التعديل
// //                             final confirmed = await _showConfirmEditDialog(
// //                               context,
// //                             );
// //                             if (confirmed) {
// //                               await _updateDailyWork(
// //                                 dailyWork,
// //                                 driverNameController.text,
// //                                 loadingLocationController.text,
// //                                 unloadingLocationController.text,
// //                                 ohdaController.text,
// //                                 kartaController.text,
// //                               );
// //                               Navigator.pop(context);
// //                             }
// //                           },
// //                           style: ElevatedButton.styleFrom(
// //                             backgroundColor: const Color(0xFF3498DB),
// //                             foregroundColor: Colors.white,
// //                             padding: EdgeInsets.symmetric(
// //                               vertical: isMobile ? 10 : 12,
// //                             ),
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(8),
// //                             ),
// //                           ),
// //                           child: Text(
// //                             'حفظ التعديلات',
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               fontSize: isMobile ? 14 : 16,
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ====================================================
// //   // دالة تأكيد التعديل
// //   // ====================================================
// //   Future<bool> _showConfirmEditDialog(BuildContext context) async {
// //     return await showDialog<bool>(
// //           context: context,
// //           builder: (context) => Directionality(
// //             textDirection: TextDirection.rtl,
// //             child: AlertDialog(
// //               title: Row(
// //                 children: [
// //                   Icon(Icons.info, color: Colors.blue),
// //                   SizedBox(width: 8),
// //                   Text('تأكيد التعديل'),
// //                 ],
// //               ),
// //               content: Text(
// //                 'هل تريد تعديل النقلة؟\n',
// //                 textAlign: TextAlign.right,
// //               ),
// //               actions: [
// //                 TextButton(
// //                   onPressed: () => Navigator.pop(context, false),
// //                   child: Text('إلغاء'),
// //                 ),
// //                 ElevatedButton(
// //                   onPressed: () => Navigator.pop(context, true),
// //                   child: Text('تأكيد'),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ) ??
// //         false;
// //   }

// //   // ====================================================
// //   // دالة لبناء حقل التعديل
// //   // ====================================================
// //   Widget _buildEditField(
// //     String label,
// //     String hint,
// //     TextEditingController controller,
// //     IconData icon,
// //     bool isMobile,
// //   ) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           label,
// //           style: TextStyle(
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //             fontSize: isMobile ? 13 : 14,
// //           ),
// //         ),
// //         SizedBox(height: isMobile ? 4 : 6),
// //         TextFormField(
// //           controller: controller,
// //           decoration: InputDecoration(
// //             hintText: hint,
// //             prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
// //             filled: true,
// //             fillColor: const Color(0xFFF4F6F8),
// //             border: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(8),
// //               borderSide: BorderSide.none,
// //             ),
// //             contentPadding: EdgeInsets.symmetric(
// //               horizontal: isMobile ? 12 : 16,
// //               vertical: isMobile ? 10 : 12,
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   // ====================================================
// //   // دالة تحديث الشغل اليومي
// //   // ====================================================
// //   Future<void> _updateDailyWork(
// //     DailyWork dailyWork,
// //     String driverName,
// //     String loadingLocation,
// //     String unloadingLocation,
// //     String ohda,
// //     String karta,
// //   ) async {
// //     try {
// //       // 1. تحديث في collection "dailyWork"
// //       await _firestore.collection('dailyWork').doc(dailyWork.id).update({
// //         'driverName': driverName.trim(),
// //         'loadingLocation': loadingLocation.trim(),
// //         'unloadingLocation': unloadingLocation.trim(),
// //         'ohda': ohda.trim(),
// //         'karta': karta.trim(),
// //         'updatedAt': Timestamp.now(),
// //       });

// //       // 2. البحث عن وثائق السائق المرتبطة
// //       final driverDocIds = await _findDriverDocumentIds(
// //         dailyWork.id!,
// //         driverName.trim(),
// //         dailyWork.date,
// //       );

// //       // 3. إذا وجدت وثائق سائق مرتبطة، قم بتحديثها
// //       if (driverDocIds.isNotEmpty) {
// //         final batch = _firestore.batch();

// //         for (final docId in driverDocIds) {
// //           final docRef = _firestore.collection('drivers').doc(docId);

// //           // تحديث جميع الحقول المرتبطة
// //           batch.update(docRef, {
// //             'driverName': driverName.trim(),
// //             'loadingLocation': loadingLocation.trim(),
// //             'unloadingLocation': unloadingLocation.trim(),
// //             'ohda': ohda.trim(),
// //             'karta': karta.trim(),
// //             'updatedAt': Timestamp.now(),
// //           });
// //         }

// //         await batch.commit();
// //       }

// //       // إظهار رسالة نجاح
// //       if (mounted) {
// //         _showSuccess('تم تعديل النقلة بنجاح');
// //       }
// //     } catch (e) {
// //       print('Error updating daily work: $e');
// //       if (mounted) {
// //         _showError('خطأ في التعديل: $e');
// //       }
// //     }
// //   }

// //   // ====================================================
// //   // دالة البحث عن وثائق السائق المرتبطة
// //   // ====================================================
// //   Future<List<String>> _findDriverDocumentIds(
// //     String dailyWorkId,
// //     String driverName,
// //     DateTime date,
// //   ) async {
// //     try {
// //       // البحث باستخدام dailyWorkId
// //       if (dailyWorkId.isNotEmpty) {
// //         final queryById = await _firestore
// //             .collection('drivers')
// //             .where('dailyWorkId', isEqualTo: dailyWorkId)
// //             .get();

// //         if (queryById.docs.isNotEmpty) {
// //           return queryById.docs.map((doc) => doc.id).toList();
// //         }
// //       }

// //       // البحث باستخدام اسم السائق والتاريخ
// //       final startOfDay = DateTime(date.year, date.month, date.day);
// //       final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

// //       final queryByDriver = await _firestore
// //           .collection('drivers')
// //           .where('driverName', isEqualTo: driverName)
// //           .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
// //           .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
// //           .get();

// //       return queryByDriver.docs.map((doc) => doc.id).toList();
// //     } catch (e) {
// //       print('خطأ في البحث عن وثائق السائق: $e');
// //       return [];
// //     }
// //   }

// //   // ====================================================
// //   // دالة حذف الشغل اليومي
// //   // ====================================================
// //   void _deleteDailyWork(DailyWork dailyWork, bool isMobile) {
// //     showDialog(
// //       context: context,
// //       builder: (context) => Directionality(
// //         textDirection: TextDirection.rtl,
// //         child: AlertDialog(
// //           backgroundColor: Colors.white,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(16),
// //           ),
// //           title: Row(
// //             children: [
// //               Icon(
// //                 Icons.warning,
// //                 color: Colors.orange,
// //                 size: isMobile ? 20 : 24,
// //               ),
// //               SizedBox(width: isMobile ? 6 : 8),
// //               Text(
// //                 'تأكيد الحذف',
// //                 style: TextStyle(
// //                   fontWeight: FontWeight.bold,
// //                   color: const Color(0xFF2C3E50),
// //                   fontSize: isMobile ? 16 : 18,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           content: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text(
// //                 'هل أنت متأكد من حذف هذه النقلة؟',
// //                 style: TextStyle(fontSize: isMobile ? 14 : 16),
// //               ),
// //               SizedBox(height: isMobile ? 6 : 8),
// //               Text(
// //                 'السائق: ${dailyWork.driverName}',
// //                 style: const TextStyle(color: Colors.grey),
// //               ),
// //               Text(
// //                 'المسار: ${dailyWork.loadingLocation} → ${dailyWork.unloadingLocation}',
// //                 style: const TextStyle(color: Colors.grey),
// //               ),
// //               Text(
// //                 'اسم الموقع: ${dailyWork.selectedRoute}',
// //                 style: TextStyle(
// //                   color: Colors.blue[700],
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //               SizedBox(height: isMobile ? 12 : 16),
// //               Text(
// //                 '⚠️ لا يمكن التراجع عن هذا الإجراء',
// //                 style: TextStyle(
// //                   color: Colors.red,
// //                   fontSize: isMobile ? 10 : 12,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.pop(context),
// //               child: Text(
// //                 'إلغاء',
// //                 style: TextStyle(
// //                   color: const Color(0xFF2C3E50),
// //                   fontSize: isMobile ? 14 : 16,
// //                 ),
// //               ),
// //             ),
// //             ElevatedButton(
// //               onPressed: () {
// //                 _confirmDeleteDailyWork(dailyWork);
// //                 Navigator.pop(context);
// //               },
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: Colors.red,
// //                 foregroundColor: Colors.white,
// //               ),
// //               child: Text(
// //                 'حذف',
// //                 style: TextStyle(fontSize: isMobile ? 14 : 16),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ====================================================
// //   // دالة تأكيد الحذف
// //   // ====================================================
// //   Future<void> _confirmDeleteDailyWork(DailyWork dailyWork) async {
// //     try {
// //       await _firestore.collection('dailyWork').doc(dailyWork.id).delete();

// //       // إظهار رسالة نجاح
// //       if (mounted) {
// //         _showSuccess('تم حذف النقلة بنجاح');
// //       }
// //     } catch (e) {
// //       print('Error deleting daily work: $e');
// //       if (mounted) {
// //         _showError('خطأ في الحذف: $e');
// //       }
// //     }
// //   }

// //   void _showCompanyDetails(
// //     String companyId,
// //     String companyName,
// //     bool isMobile,
// //   ) {
// //     showDialog(
// //       context: context,
// //       builder: (context) => Directionality(
// //         textDirection: TextDirection.rtl,
// //         child: Dialog(
// //           backgroundColor: Colors.transparent,
// //           insetPadding: EdgeInsets.all(isMobile ? 8 : 16),
// //           child: Container(
// //             width: MediaQuery.of(context).size.width * (isMobile ? 0.98 : 0.95),
// //             constraints: BoxConstraints(
// //               maxHeight: MediaQuery.of(context).size.height * 0.9,
// //             ),
// //             padding: EdgeInsets.all(isMobile ? 16 : 20),
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(16),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black.withOpacity(0.15),
// //                   blurRadius: 20,
// //                 ),
// //               ],
// //             ),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 // العنوان
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     IconButton(
// //                       icon: Icon(Icons.close, size: isMobile ? 20 : 24),
// //                       onPressed: () => Navigator.pop(context),
// //                     ),
// //                     Text(
// //                       'نقلات $companyName',
// //                       style: TextStyle(
// //                         fontSize: isMobile ? 18 : 20,
// //                         fontWeight: FontWeight.bold,
// //                         color: const Color(0xFF2C3E50),
// //                       ),
// //                     ),
// //                     SizedBox(width: isMobile ? 40 : 48),
// //                   ],
// //                 ),

// //                 SizedBox(height: isMobile ? 4 : 8),
// //                 Divider(color: const Color(0xFF3498DB).withOpacity(0.3)),

// //                 // معلومات الشركة والفلتر
// //                 Container(
// //                   padding: EdgeInsets.all(isMobile ? 10 : 12),
// //                   decoration: BoxDecoration(
// //                     color: const Color(0xFF3498DB).withOpacity(0.1),
// //                     borderRadius: BorderRadius.circular(10),
// //                   ),
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
// //                     children: [
// //                       Column(
// //                         children: [
// //                           Text(
// //                             'اسم الشركة',
// //                             style: TextStyle(
// //                               fontSize: isMobile ? 10 : 11,
// //                               color: Colors.grey,
// //                             ),
// //                           ),
// //                           Text(
// //                             companyName,
// //                             style: TextStyle(
// //                               fontSize: isMobile ? 14 : 16,
// //                               fontWeight: FontWeight.bold,
// //                               color: const Color(0xFF2C3E50),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       Column(
// //                         children: [
// //                           Text(
// //                             'فلتر التاريخ',
// //                             style: TextStyle(
// //                               fontSize: isMobile ? 10 : 11,
// //                               color: Colors.grey,
// //                             ),
// //                           ),
// //                           InkWell(
// //                             onTap: () => _selectDateForDetails(context),
// //                             child: Container(
// //                               padding: EdgeInsets.symmetric(
// //                                 horizontal: isMobile ? 10 : 12,
// //                                 vertical: isMobile ? 5 : 6,
// //                               ),
// //                               decoration: BoxDecoration(
// //                                 color: Colors.white,
// //                                 borderRadius: BorderRadius.circular(6),
// //                                 border: Border.all(
// //                                   color: const Color(0xFF3498DB),
// //                                 ),
// //                               ),
// //                               child: Row(
// //                                 children: [
// //                                   Icon(
// //                                     Icons.calendar_today,
// //                                     size: isMobile ? 14 : 16,
// //                                     color: const Color(0xFF3498DB),
// //                                   ),
// //                                   SizedBox(width: isMobile ? 4 : 6),
// //                                   Text(
// //                                     _selectedDate != null
// //                                         ? _formatDate(_selectedDate!)
// //                                         : 'جميع التواريخ',
// //                                     style: TextStyle(
// //                                       fontSize: isMobile ? 11 : 12,
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                 ),

// //                 SizedBox(height: isMobile ? 12 : 16),
// //                 Expanded(
// //                   child: _buildCompanyWorkTable(
// //                     companyId,
// //                     companyName,
// //                     isMobile,
// //                   ),
// //                 ),
// //                 SizedBox(height: isMobile ? 12 : 16),

// //                 // زر الإغلاق
// //                 ElevatedButton(
// //                   onPressed: () => Navigator.pop(context),
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: const Color(0xFF3498DB),
// //                     foregroundColor: Colors.white,
// //                     elevation: 2,
// //                     padding: EdgeInsets.symmetric(
// //                       horizontal: isMobile ? 30 : 40,
// //                       vertical: isMobile ? 10 : 12,
// //                     ),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                   ),
// //                   child: Text(
// //                     'إغلاق',
// //                     style: TextStyle(fontSize: isMobile ? 14 : 16),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Future<void> _selectDateForDetails(BuildContext context) async {
// //     final DateTime? picked = await showDatePicker(
// //       context: context,
// //       initialDate: _selectedDate ?? DateTime.now(),
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime(2030),
// //     );
// //     if (picked != null) {
// //       setState(() {
// //         _selectedDate = picked;
// //       });
// //     }
// //   }

// //   Widget _buildCompanyWorkTable(
// //     String companyId,
// //     String companyName,
// //     bool isMobile,
// //   ) {
// //     return StreamBuilder<QuerySnapshot>(
// //       stream: _getCompanyDailyWorkStream(companyId),
// //       builder: (context, snapshot) {
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Center(child: CircularProgressIndicator());
// //         }

// //         if (snapshot.hasError) {
// //           return Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(Icons.error, size: isMobile ? 40 : 48, color: Colors.red),
// //                 SizedBox(height: isMobile ? 6 : 8),
// //                 Text(
// //                   'خطأ في تحميل البيانات: ${snapshot.error}',
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                     fontSize: isMobile ? 12 : 14,
// //                     color: Colors.red,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           );
// //         }

// //         final dailyWorks = _convertSnapshotToDailyWorkList(snapshot.data);

// //         if (dailyWorks.isEmpty) {
// //           return Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(
// //                   Icons.work_outline,
// //                   size: isMobile ? 50 : 64,
// //                   color: Colors.grey,
// //                 ),
// //                 SizedBox(height: isMobile ? 12 : 16),
// //                 Text(
// //                   'لا توجد نقلات',
// //                   style: TextStyle(
// //                     fontSize: isMobile ? 14 : 16,
// //                     color: Colors.grey,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           );
// //         }

// //         return Container(
// //           decoration: BoxDecoration(
// //             borderRadius: BorderRadius.circular(10),
// //             border: Border.all(color: Colors.transparent, width: 1.5),
// //           ),
// //           child: SingleChildScrollView(
// //             scrollDirection: Axis.horizontal,
// //             child: SingleChildScrollView(
// //               scrollDirection: Axis.vertical,
// //               child: Table(
// //                 defaultColumnWidth: FixedColumnWidth(isMobile ? 120 : 150),
// //                 border: TableBorder.all(
// //                   color: const Color(0xFF3498DB),
// //                   width: 1,
// //                 ),
// //                 children: [
// //                   TableRow(
// //                     decoration: BoxDecoration(
// //                       color: const Color(0xFF3498DB).withOpacity(0.15),
// //                     ),
// //                     children: [
// //                       _TableCellHeader('م', isMobile),
// //                       _TableCellHeader('التاريخ', isMobile),
// //                       _TableCellHeader('اسم السائق', isMobile),
// //                       _TableCellHeader('مكان التحميل', isMobile),
// //                       _TableCellHeader('مكان التعتيق', isMobile),
// //                       _TableCellHeader('اسم الموقع', isMobile),
// //                       _TableCellHeader('العهدة', isMobile),
// //                       _TableCellHeader('الكارتة', isMobile),
// //                       _TableCellHeader('الإجراءات', isMobile),
// //                     ],
// //                   ),
// //                   ...dailyWorks.asMap().entries.map((entry) {
// //                     final index = entry.key;
// //                     final dailyWork = entry.value;

// //                     return TableRow(
// //                       decoration: BoxDecoration(
// //                         color: index.isEven
// //                             ? Colors.white
// //                             : const Color(0xFFF8F9FA),
// //                       ),
// //                       children: [
// //                         _TableCellBody('${index + 1}', isMobile),
// //                         _TableCellBody(_formatDate(dailyWork.date), isMobile),
// //                         _TableCellBody(dailyWork.driverName, isMobile),
// //                         _TableCellBody(dailyWork.loadingLocation, isMobile),
// //                         _TableCellBody(dailyWork.unloadingLocation, isMobile),
// //                         _TableCellBody(
// //                           dailyWork.selectedRoute,
// //                           isMobile,
// //                           textStyle: TextStyle(
// //                             fontWeight: FontWeight.bold,
// //                             color: Colors.blue[700],
// //                           ),
// //                         ),
// //                         _TableCellBody(
// //                           dailyWork.ohda,
// //                           isMobile,
// //                           textStyle: const TextStyle(
// //                             fontWeight: FontWeight.bold,
// //                             color: Color(0xFF2E7D32),
// //                           ),
// //                         ),
// //                         _TableCellBody(
// //                           dailyWork.karta,
// //                           isMobile,
// //                           textStyle: const TextStyle(
// //                             fontWeight: FontWeight.bold,
// //                             color: Color(0xFFD35400),
// //                           ),
// //                         ),
// //                         _TableCellActionsWithHolidayAndOvernight(
// //                           dailyWork: dailyWork,
// //                           companyName: companyName,
// //                           isMobile: isMobile,
// //                           onEdit: () =>
// //                               _editDailyWork(dailyWork, companyName, isMobile),
// //                           onDelete: () => _deleteDailyWork(dailyWork, isMobile),
// //                           onAddHoliday: () =>
// //                               _addHoliday(dailyWork, companyName, isMobile),
// //                           onAddOvernight: () =>
// //                               _addOvernight(dailyWork, companyName, isMobile),
// //                         ),
// //                       ],
// //                     );
// //                   }).toList(),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   // دالة لإنشاء Stream للبيانات
// //   Stream<QuerySnapshot> _getCompanyDailyWorkStream(String companyId) {
// //     Query query = _firestore
// //         .collection('dailyWork')
// //         .where('companyId', isEqualTo: companyId);

// //     if (_selectedDate != null) {
// //       final startOfDay = DateTime(
// //         _selectedDate!.year,
// //         _selectedDate!.month,
// //         _selectedDate!.day,
// //       );
// //       final endOfDay = DateTime(
// //         _selectedDate!.year,
// //         _selectedDate!.month,
// //         _selectedDate!.day,
// //         23,
// //         59,
// //         59,
// //       );

// //       query = query
// //           .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
// //           .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));
// //     }

// //     return query.snapshots();
// //   }

// //   // دالة لتحويل الـ Snapshot إلى قائمة DailyWork
// //   List<DailyWork> _convertSnapshotToDailyWorkList(QuerySnapshot? snapshot) {
// //     if (snapshot == null) return [];

// //     final dailyWorks = snapshot.docs.map((doc) {
// //       final data = _safeConvertDocumentData(doc.data());
// //       return DailyWork.fromMap(data, doc.id);
// //     }).toList();

// //     dailyWorks.sort((a, b) => b.date.compareTo(a.date));
// //     return dailyWorks;
// //   }

// //   // ====================================================
// //   // الدوال الجديدة لإضافة العطلة والمبيت (باستخدام priceOfferId)
// //   // ====================================================

// //   // دالة لجلب بيانات عرض السعر للشركة باستخدام priceOfferId
// //   Future<Map<String, dynamic>?> _getPriceOfferData(
// //     String companyId,
// //     String priceOfferId,
// //   ) async {
// //     try {
// //       print('🔍 جلب بيانات عرض السعر:');
// //       print('   companyId: $companyId');
// //       print('   priceOfferId: $priceOfferId');

// //       // التحقق من وجود قيم
// //       if (companyId.isEmpty || priceOfferId.isEmpty) {
// //         print('❌ companyId أو priceOfferId فارغ');
// //         return null;
// //       }

// //       // المسار في Firestore: companies/{companyId}/priceOffers/{priceOfferId}
// //       final snapshot = await _firestore
// //           .collection('companies')
// //           .doc(companyId)
// //           .collection('priceOffers')
// //           .doc(priceOfferId)
// //           .get();

// //       if (snapshot.exists) {
// //         print('✅ تم العثور على عرض السعر');
// //         return snapshot.data();
// //       } else {
// //         print('❌ عرض السعر غير موجود في Firestore');
// //         return null;
// //       }
// //     } catch (e) {
// //       print('🚨 خطأ في جلب بيانات عرض السعر: $e');
// //       return null;
// //     }
// //   }

// //   // دالة إضافة عطلة
// //   void _addHoliday(DailyWork dailyWork, String companyName, bool isMobile) {
// //     _addHolidayOrOvernight(dailyWork, companyName, isMobile, true);
// //   }

// //   // دالة إضافة مبيت
// //   void _addOvernight(DailyWork dailyWork, String companyName, bool isMobile) {
// //     _addHolidayOrOvernight(dailyWork, companyName, isMobile, false);
// //   }

// //   // دالة مشتركة لإضافة عطلة أو مبيت
// //   void _addHolidayOrOvernight(
// //     DailyWork dailyWork,
// //     String companyName,
// //     bool isMobile,
// //     bool isHoliday,
// //   ) async {
// //     try {
// //       print('🎯 بدء إضافة ${isHoliday ? 'عطلة' : 'مبيت'}');
// //       print('   السائق: ${dailyWork.driverName}');
// //       print('   المسار: ${dailyWork.selectedRoute}');
// //       print('   companyId: ${dailyWork.companyId}');
// //       print('   priceOfferId: ${dailyWork.priceOfferId}');

// //       // التحقق من وجود priceOfferId
// //       if (dailyWork.priceOfferId == null || dailyWork.priceOfferId!.isEmpty) {
// //         _showError('❌ لا يوجد عرض سعر مرتبط بهذه النقلة');
// //         return;
// //       }

// //       // جلب بيانات عرض السعر
// //       final priceOfferData = await _getPriceOfferData(
// //         dailyWork.companyId,
// //         dailyWork.priceOfferId!,
// //       );

// //       if (priceOfferData == null) {
// //         _showError('❌ عرض السعر غير موجود');
// //         return;
// //       }

// //       // استخراج قائمة النقلات
// //       final transportations = priceOfferData['transportations'] as List? ?? [];
// //       print('   عدد النقلات في العرض: ${transportations.length}');

// //       if (transportations.isEmpty) {
// //         _showError('❌ لا توجد نقلات في عرض السعر');
// //         return;
// //       }

// //       // البحث عن النقل المناسب
// //       Map<String, dynamic>? selectedTransportation;

// //       for (final transport in transportations) {
// //         final transportMap = transport as Map<String, dynamic>;
// //         final unloadingLocation =
// //             transportMap['unloadingLocation']?.toString() ?? '';
// //         final selectedRoute = dailyWork.selectedRoute?.toString() ?? '';

// //         print('   🔍 مقارنة: "$unloadingLocation" مع "$selectedRoute"');

// //         if (unloadingLocation == selectedRoute) {
// //           selectedTransportation = transportMap;
// //           print('   ✅ تم العثور على نقل مطابق');
// //           break;
// //         }
// //       }

// //       // إذا لم نجد تطابق، نستخدم أول نقل
// //       if (selectedTransportation == null) {
// //         selectedTransportation = transportations.first as Map<String, dynamic>;
// //         print('   ⚠️ استخدام أول نقل (لم يتم العثور على تطابق دقيق)');
// //       }

// //       // استخراج المبالغ
// //       double companyAmount = 0.0;
// //       double wheelAmount = 0.0;

// //       if (isHoliday) {
// //         // استخراج قيم العطلة
// //         companyAmount = _extractValue(selectedTransportation, [
// //           'companyHoliday',
// //           'company_holiday',
// //           'holiday_company',
// //           'companyHolidayPrice',
// //         ]);

// //         wheelAmount = _extractValue(selectedTransportation, [
// //           'wheelHoliday',
// //           'wheel_holiday',
// //           'holiday_wheel',
// //           'wheelHolidayPrice',
// //         ]);
// //       } else {
// //         // استخراج قيم المبيت
// //         companyAmount = _extractValue(selectedTransportation, [
// //           'companyOvernight',
// //           'company_overnight',
// //           'overnight_company',
// //           'companyOvernightPrice',
// //         ]);

// //         wheelAmount = _extractValue(selectedTransportation, [
// //           'wheelOvernight',
// //           'wheel_overnight',
// //           'overnight_wheel',
// //           'wheelOvernightPrice',
// //         ]);
// //       }

// //       print('💰 القيم المستخرجة:');
// //       print('   ${isHoliday ? 'عطلة الشركة' : 'مبيت الشركة'}: $companyAmount');
// //       print('   ${isHoliday ? 'عطلة العجلات' : 'مبيت العجلات'}: $wheelAmount');

// //       // إظهار تأكيد
// //       final confirmed = await _showSimpleConfirmation(
// //         context,
// //         isHoliday,
// //         companyAmount,
// //         wheelAmount,
// //         isMobile,
// //       );

// //       if (confirmed != null && confirmed) {
// //         // تحديث البيانات في Firestore
// //         await _updateHolidayOrOvernight(
// //           dailyWork,
// //           isHoliday,
// //           companyAmount,
// //           wheelAmount,
// //         );
// //       }
// //     } catch (e) {
// //       print('🚨 خطأ في إضافة العطلة/المبيت: $e');
// //       _showError('❌ خطأ في إضافة العطلة/المبيت: ${e.toString()}');
// //     }
// //   }

// //   // دالة مساعدة لاستخراج قيمة
// //   double _extractValue(Map<String, dynamic> data, List<String> keys) {
// //     for (final key in keys) {
// //       final value = data[key];
// //       if (value != null) {
// //         if (value is int) return value.toDouble();
// //         if (value is double) return value;
// //         if (value is String) {
// //           final parsed = double.tryParse(value);
// //           if (parsed != null) return parsed;
// //         }
// //       }
// //     }
// //     return 0.0;
// //   }

// //   // دالة تأكيد بسيطة
// //   Future<bool?> _showSimpleConfirmation(
// //     BuildContext context,
// //     bool isHoliday,
// //     double companyAmount,
// //     double wheelAmount,
// //     bool isMobile,
// //   ) {
// //     return showDialog<bool>(
// //       context: context,
// //       builder: (context) => Directionality(
// //         textDirection: TextDirection.rtl,
// //         child: AlertDialog(
// //           backgroundColor: Colors.white,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(16),
// //           ),
// //           title: Row(
// //             children: [
// //               Icon(
// //                 isHoliday ? Icons.celebration : Icons.hotel,
// //                 color: isHoliday ? Colors.orange : Colors.blue,
// //                 size: isMobile ? 24 : 28,
// //               ),
// //               SizedBox(width: isMobile ? 8 : 12),
// //               Text(
// //                 isHoliday ? 'إضافة عطلة' : 'إضافة مبيت',
// //                 style: TextStyle(
// //                   fontWeight: FontWeight.bold,
// //                   fontSize: isMobile ? 16 : 18,
// //                   color: const Color(0xFF2C3E50),
// //                 ),
// //               ),
// //             ],
// //           ),
// //           content: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text(
// //                 isHoliday ? 'سيتم إضافة عطلة بقيمة:' : 'سيتم إضافة مبيت بقيمة:',
// //                 style: TextStyle(fontSize: isMobile ? 14 : 16),
// //               ),
// //               SizedBox(height: isMobile ? 8 : 12),
// //               // عطلة/مبيت الشركة
// //               _buildAmountItem(
// //                 isHoliday ? 'عطلة الشركة' : 'مبيت الشركة',
// //                 companyAmount,
// //                 isHoliday ? Colors.orange : Colors.blue,
// //                 isMobile,
// //               ),
// //               SizedBox(height: 6),
// //               // عطلة/مبيت العجلات
// //               _buildAmountItem(
// //                 isHoliday ? 'عطلة العجلات' : 'مبيت العجلات',
// //                 wheelAmount,
// //                 isHoliday ? Colors.orange[700]! : Colors.blue[700]!,
// //                 isMobile,
// //               ),
// //               SizedBox(height: isMobile ? 8 : 12),
// //               Divider(color: Colors.grey[300]),
// //               SizedBox(height: isMobile ? 8 : 12),

// //             ],
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.pop(context, false),
// //               child: Text(
// //                 'إلغاء',
// //                 style: TextStyle(fontSize: isMobile ? 14 : 16),
// //               ),
// //             ),
// //             ElevatedButton(
// //               onPressed: () => Navigator.pop(context, true),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: isHoliday ? Colors.orange : Colors.blue,
// //                 foregroundColor: Colors.white,
// //               ),
// //               child: Text(
// //                 'تأكيد',
// //                 style: TextStyle(fontSize: isMobile ? 14 : 16),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // دالة لعرض عنصر المبلغ
// //   Widget _buildAmountItem(
// //     String label,
// //     double amount,
// //     Color color,
// //     bool isMobile,
// //   ) {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         Text(
// //           label,
// //           style: TextStyle(fontSize: isMobile ? 13 : 14, color: color),
// //         ),
// //         Text(
// //           '$amount ج',
// //           style: TextStyle(
// //             fontSize: isMobile ? 13 : 14,
// //             fontWeight: FontWeight.bold,
// //             color: color,
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   // دالة تحديث العطلة أو المبيت
// //   Future<void> _updateHolidayOrOvernight(
// //     DailyWork dailyWork,
// //     bool isHoliday,
// //     double companyAmount,
// //     double wheelAmount,
// //   ) async {
// //     try {
// //       print('🔄 تحديث البيانات في Firestore...');

// //       // 1. تحديث dailyWork collection
// //       final updateData = <String, dynamic>{'updatedAt': Timestamp.now()};

// //       if (isHoliday) {
// //         updateData.addAll({
// //           'companyHoliday': companyAmount,
// //           'wheelHoliday': wheelAmount,
// //         });
// //       } else {
// //         updateData.addAll({
// //           'companyOvernight': companyAmount,
// //           'wheelOvernight': wheelAmount,
// //         });
// //       }

// //       // تحديث مستند dailyWork
// //       await _firestore
// //           .collection('dailyWork')
// //           .doc(dailyWork.id)
// //           .update(updateData);

// //       print('✅ تم تحديث dailyWork');

// //       // 2. تحديث drivers collection
// //       await _updateDriversCollection(
// //         dailyWork,
// //         isHoliday,
// //         companyAmount,
// //         wheelAmount,
// //       );

// //       print('✅ تم تحديث drivers collection');

// //       // رسالة نجاح
// //       _showSuccess(
// //         isHoliday ? '✅ تم إضافة العطلة بنجاح' : '✅ تم إضافة المبيت بنجاح',
// //       );
// //     } catch (e) {
// //       print('🚨 خطأ في تحديث Firestore: $e');
// //       _showError('❌ خطأ في تحديث البيانات: ${e.toString()}');
// //     }
// //   }

// //   // دالة تحديث drivers collection
// //   Future<void> _updateDriversCollection(
// //     DailyWork dailyWork,
// //     bool isHoliday,
// //     double companyAmount,
// //     double wheelAmount,
// //   ) async {
// //     try {
// //       // البحث عن سجلات السائق المرتبطة
// //       final query = await _firestore
// //           .collection('drivers')
// //           .where('dailyWorkId', isEqualTo: dailyWork.id)
// //           .limit(10)
// //           .get();

// //       print('   عدد سجلات السائق المرتبطة: ${query.docs.length}');

// //       if (query.docs.isNotEmpty) {
// //         final batch = _firestore.batch();
// //         final totalAmount = companyAmount + wheelAmount;

// //         for (final doc in query.docs) {
// //           final updateData = <String, dynamic>{'updatedAt': Timestamp.now()};

// //           if (isHoliday) {
// //             updateData.addAll({
// //               'companyHoliday': companyAmount,
// //               'wheelHoliday': wheelAmount,
// //             });
// //           } else {
// //             updateData.addAll({
// //               'companyOvernight': companyAmount,
// //               'wheelOvernight': wheelAmount,
// //             });
// //           }

// //           // تحديث المبلغ المتبقي
// //           updateData['remainingAmount'] = FieldValue.increment(totalAmount);

// //           batch.update(doc.reference, updateData);
// //         }

// //         await batch.commit();
// //         print('✅ تم تحديث ${query.docs.length} سجل للسائق');
// //       } else {
// //         print('⚠️ لم يتم العثور على سجلات سائق مرتبطة');
// //       }
// //     } catch (e) {
// //       print('🚨 خطأ في تحديث سجلات السائقين: $e');
// //       throw e;
// //     }
// //   }

// //   // ====================================================
// //   // باقي الدوال الحالية
// //   // ====================================================

// //   // دالة إظهار خطأ
// //   void _showError(String message) {
// //     if (mounted) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text(message),
// //           backgroundColor: Colors.red,
// //           duration: const Duration(seconds: 3),
// //         ),
// //       );
// //     }
// //   }

// //   // دالة إظهار نجاح
// //   void _showSuccess(String message) {
// //     if (mounted) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text(message),
// //           backgroundColor: Colors.green,
// //           duration: const Duration(seconds: 2),
// //         ),
// //       );
// //     }
// //   }

// //   Future<void> _selectDate(BuildContext context) async {
// //     final DateTime? picked = await showDatePicker(
// //       context: context,
// //       initialDate: _selectedDate ?? DateTime.now(),
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime(2030),
// //     );
// //     if (picked != null) {
// //       setState(() {
// //         _selectedDate = picked;
// //       });
// //     }
// //   }

// //   String _formatDate(DateTime date) {
// //     return '${date.day}/${date.month}/${date.year}';
// //   }
// // }

// // class _TableCellBody extends StatelessWidget {
// //   final String text;
// //   final bool isMobile;
// //   final TextStyle? textStyle;

// //   const _TableCellBody(this.text, this.isMobile, {this.textStyle});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       height: isMobile ? 40 : 48,
// //       alignment: Alignment.center,
// //       padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
// //       child: Text(
// //         text,
// //         maxLines: 2,
// //         overflow: TextOverflow.ellipsis,
// //         textAlign: TextAlign.center,
// //         style: textStyle ?? TextStyle(fontSize: isMobile ? 11 : 14),
// //       ),
// //     );
// //   }
// // }

// // class _TableCellHeader extends StatelessWidget {
// //   final String text;
// //   final bool isMobile;

// //   const _TableCellHeader(this.text, this.isMobile);

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       height: isMobile ? 42 : 50,
// //       alignment: Alignment.center,
// //       padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
// //       child: Text(
// //         text,
// //         style: TextStyle(
// //           fontWeight: FontWeight.bold,
// //           fontSize: isMobile ? 11 : 14,
// //           color: const Color(0xFF2C3E50),
// //         ),
// //         textAlign: TextAlign.center,
// //       ),
// //     );
// //   }
// // }

// // class _TableCellActionsWithHolidayAndOvernight extends StatelessWidget {
// //   final DailyWork dailyWork;
// //   final String companyName;
// //   final bool isMobile;
// //   final VoidCallback onEdit;
// //   final VoidCallback onDelete;
// //   final VoidCallback onAddHoliday;
// //   final VoidCallback onAddOvernight;

// //   const _TableCellActionsWithHolidayAndOvernight({
// //     required this.dailyWork,
// //     required this.companyName,
// //     required this.isMobile,
// //     required this.onEdit,
// //     required this.onDelete,
// //     required this.onAddHoliday,
// //     required this.onAddOvernight,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       height: isMobile ? 40 : 48,
// //       alignment: Alignment.center,
// //       padding: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 4),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           // زر إضافة عطلة (يظهر دائماً)
// //           IconButton(
// //             icon: Container(
// //               padding: EdgeInsets.all(isMobile ? 3 : 5),
// //               decoration: BoxDecoration(
// //                 color: Colors.orange.withOpacity(0.1),
// //                 borderRadius: BorderRadius.circular(6),
// //               ),
// //               child: Icon(
// //                 Icons.celebration,
// //                 size: isMobile ? 12 : 14,
// //                 color: Colors.orange,
// //               ),
// //             ),
// //             onPressed: onAddHoliday,
// //             padding: EdgeInsets.zero,
// //             constraints: const BoxConstraints(),
// //             tooltip: 'إضافة عطلة',
// //           ),
// //           SizedBox(width: isMobile ? 2 : 4),

// //           // زر إضافة مبيت (يظهر دائماً)
// //           IconButton(
// //             icon: Container(
// //               padding: EdgeInsets.all(isMobile ? 3 : 5),
// //               decoration: BoxDecoration(
// //                 color: Colors.blue.withOpacity(0.1),
// //                 borderRadius: BorderRadius.circular(6),
// //               ),
// //               child: Icon(
// //                 Icons.hotel,
// //                 size: isMobile ? 12 : 14,
// //                 color: Colors.blue,
// //               ),
// //             ),
// //             onPressed: onAddOvernight,
// //             padding: EdgeInsets.zero,
// //             constraints: const BoxConstraints(),
// //             tooltip: 'إضافة مبيت',
// //           ),
// //           SizedBox(width: isMobile ? 2 : 4),

// //           // زر التعديل
// //           IconButton(
// //             icon: Container(
// //               padding: EdgeInsets.all(isMobile ? 4 : 6),
// //               decoration: BoxDecoration(
// //                 color: Colors.blue.withOpacity(0.1),
// //                 borderRadius: BorderRadius.circular(6),
// //               ),
// //               child: Icon(
// //                 Icons.edit,
// //                 size: isMobile ? 14 : 16,
// //                 color: Colors.blue,
// //               ),
// //             ),
// //             onPressed: onEdit,
// //             padding: EdgeInsets.zero,
// //             constraints: const BoxConstraints(),
// //           ),
// //           SizedBox(width: isMobile ? 2 : 4),

// //           // زر الحذف
// //           IconButton(
// //             icon: Container(
// //               padding: EdgeInsets.all(isMobile ? 4 : 6),
// //               decoration: BoxDecoration(
// //                 color: Colors.red.withOpacity(0.1),
// //                 borderRadius: BorderRadius.circular(6),
// //               ),
// //               child: Icon(
// //                 Icons.delete,
// //                 size: isMobile ? 14 : 16,
// //                 color: Colors.red,
// //               ),
// //             ),
// //             onPressed: onDelete,
// //             padding: EdgeInsets.zero,
// //             constraints: const BoxConstraints(),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:last/models/models.dart';

// class MonthlyRecordPage extends StatefulWidget {
//   const MonthlyRecordPage({super.key});

//   @override
//   State<MonthlyRecordPage> createState() => _MonthlyRecordPageState();
// }

// class _MonthlyRecordPageState extends State<MonthlyRecordPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   String _searchQuery = '';
//   DateTime? _selectedDate;

//   // دالة مساعدة لتحويل البيانات بأمان
//   Map<String, dynamic> _safeConvertDocumentData(Object? data) {
//     if (data == null) {
//       return {};
//     }

//     if (data is Map<String, dynamic>) {
//       return data;
//     }

//     if (data is Map<dynamic, dynamic>) {
//       return data.cast<String, dynamic>();
//     }

//     return {};
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6F8),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           final bool isMobile = constraints.maxWidth < 600;

//           return Column(
//             children: [
//               _buildCustomAppBar(isMobile),
//               _buildFilterSection(isMobile),
//               Expanded(child: _buildCompaniesWithWorkList(isMobile)),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildCustomAppBar(bool isMobile) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: isMobile ? 16 : 24,
//         vertical: isMobile ? 16 : 20,
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
//             Icon(
//               Icons.calendar_month,
//               color: Colors.white,
//               size: isMobile ? 28 : 32,
//             ),
//             SizedBox(width: isMobile ? 8 : 12),
//             Text(
//               'السجل الشهري',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: isMobile ? 20 : 24,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Cairo',
//               ),
//             ),
//             const Spacer(flex: 12),
//             StreamBuilder<DateTime>(
//               stream: Stream.periodic(
//                 const Duration(seconds: 1),
//                 (_) => DateTime.now(),
//               ),
//               builder: (context, snapshot) {
//                 final now = snapshot.data ?? DateTime.now();

//                 // تحويل إلى نظام 12 ساعة
//                 int hour12 = now.hour % 12;
//                 if (hour12 == 0) hour12 = 12; // تحويل 0 إلى 12

//                 // تحديد AM/PM
//                 String period = now.hour < 12 ? 'AM' : 'PM';

//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Container(
//                       height: 50,
//                       width: 150,
//                       decoration: BoxDecoration(
//                         color: Colors.transparent,
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Center(
//                         child: Text(
//                           '${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 36,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterSection(bool isMobile) {
//     return Container(
//       padding: EdgeInsets.all(isMobile ? 12 : 16),
//       color: Colors.white,
//       child: Column(
//         children: [
//           _buildSearchBar(isMobile),
//           SizedBox(height: isMobile ? 12 : 16),
//           _buildDateFilter(isMobile),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchBar(bool isMobile) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF4F6F8),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFF3498DB)),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             Icons.search,
//             color: const Color(0xFF3498DB),
//             size: isMobile ? 20 : 24,
//           ),
//           SizedBox(width: isMobile ? 8 : 12),
//           Expanded(
//             child: TextField(
//               onChanged: (value) => setState(() => _searchQuery = value),
//               decoration: const InputDecoration(
//                 hintText: 'ابحث عن شركة...',
//                 border: InputBorder.none,
//                 hintStyle: TextStyle(color: Colors.grey),
//               ),
//             ),
//           ),
//           if (_searchQuery.isNotEmpty)
//             GestureDetector(
//               onTap: () => setState(() => _searchQuery = ''),
//               child: Icon(
//                 Icons.clear,
//                 size: isMobile ? 18 : 20,
//                 color: Colors.grey,
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDateFilter(bool isMobile) {
//     return Row(
//       children: [
//         Expanded(
//           child: InkWell(
//             onTap: () => _selectDate(context),
//             child: Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: isMobile ? 12 : 16,
//                 vertical: isMobile ? 10 : 12,
//               ),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF4F6F8),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: const Color(0xFF3498DB)),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.calendar_today,
//                     color: const Color(0xFF3498DB),
//                     size: isMobile ? 18 : 20,
//                   ),
//                   SizedBox(width: isMobile ? 8 : 12),
//                   Expanded(
//                     child: Text(
//                       _selectedDate != null
//                           ? _formatDate(_selectedDate!)
//                           : 'جميع التواريخ',
//                       style: TextStyle(
//                         fontSize: isMobile ? 13 : 14,
//                         color: _selectedDate != null
//                             ? Colors.black
//                             : Colors.grey,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         SizedBox(width: isMobile ? 8 : 12),
//         if (_selectedDate != null)
//           IconButton(
//             icon: Icon(
//               Icons.clear,
//               color: Colors.red,
//               size: isMobile ? 20 : 24,
//             ),
//             onPressed: () => setState(() => _selectedDate = null),
//           ),
//       ],
//     );
//   }

//   Widget _buildCompaniesWithWorkList(bool isMobile) {
//     return FutureBuilder<List<Map<String, dynamic>>>(
//       future: _getCompaniesWithWork(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.error, size: isMobile ? 48 : 64, color: Colors.red),
//                 SizedBox(height: isMobile ? 12 : 16),
//                 Text(
//                   'خطأ في تحميل البيانات: ${snapshot.error}',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: isMobile ? 14 : 16),
//                 ),
//               ],
//             ),
//           );
//         }

//         final companiesList = snapshot.data ?? [];

//         final filteredCompanies = companiesList
//             .where((company) {
//               if (_searchQuery.isEmpty) return true;
//               final companyName =
//                   company['companyName']?.toString().toLowerCase() ?? '';
//               return companyName.contains(_searchQuery.toLowerCase());
//             })
//             .where((company) {
//               return (company['workCount'] as int) > 0;
//             })
//             .toList();

//         if (filteredCompanies.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.business,
//                   size: isMobile ? 60 : 80,
//                   color: Colors.grey,
//                 ),
//                 SizedBox(height: isMobile ? 12 : 16),
//                 Text(
//                   'لا توجد شركات لديها شغل يومي',
//                   style: TextStyle(
//                     fontSize: isMobile ? 16 : 18,
//                     color: Colors.grey,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: isMobile ? 4 : 8),
//                 Text(
//                   _searchQuery.isEmpty
//                       ? 'أضف شغل يومي جديد للبدء'
//                       : 'لم يتم العثور على نتائج البحث',
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontSize: isMobile ? 12 : 14,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         return ListView.builder(
//           padding: EdgeInsets.all(isMobile ? 12 : 16),
//           itemCount: filteredCompanies.length,
//           itemBuilder: (context, index) {
//             final companyData = filteredCompanies[index];
//             return _buildCompanyItem(
//               companyData['companyId'] as String,
//               companyData,
//               isMobile,
//             );
//           },
//         );
//       },
//     );
//   }

//   Future<List<Map<String, dynamic>>> _getCompaniesWithWork() async {
//     try {
//       final dailyWorksSnapshot = await _firestore
//           .collection('dailyWork')
//           .where(
//             'date',
//             isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(2020)),
//           )
//           .get();

//       final companyData = <String, Map<String, dynamic>>{};

//       for (final work in dailyWorksSnapshot.docs) {
//         final data = _safeConvertDocumentData(work.data());
//         final companyId = data['companyId']?.toString() ?? '';
//         final companyName = data['companyName']?.toString() ?? '';
//         final workDate = (data['date'] as Timestamp?)?.toDate();

//         if (companyId.isEmpty || companyName.isEmpty) continue;

//         if (_selectedDate != null && workDate != null) {
//           final startOfDay = DateTime(
//             _selectedDate!.year,
//             _selectedDate!.month,
//             _selectedDate!.day,
//           );
//           final endOfDay = DateTime(
//             _selectedDate!.year,
//             _selectedDate!.month,
//             _selectedDate!.day,
//             23,
//             59,
//             59,
//           );

//           if (workDate.isBefore(startOfDay) || workDate.isAfter(endOfDay)) {
//             continue;
//           }
//         }

//         if (!companyData.containsKey(companyId)) {
//           companyData[companyId] = {
//             'companyId': companyId,
//             'companyName': companyName,
//             'workCount': 0,
//           };
//         }

//         companyData[companyId]!['workCount'] =
//             (companyData[companyId]!['workCount'] as int) + 1;
//       }

//       return companyData.values.toList();
//     } catch (e) {
//       print('Error getting companies with work: $e');
//       throw e;
//     }
//   }

//   Widget _buildCompanyItem(
//     String companyId,
//     Map<String, dynamic> data,
//     bool isMobile,
//   ) {
//     final companyName = data['companyName']?.toString() ?? '';
//     final workCount = data['workCount'] as int? ?? 0;

//     return Container(
//       margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFF3498DB).withOpacity(0.3)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         onTap: () => _showCompanyDetails(companyId, companyName, isMobile),
//         leading: Container(
//           width: isMobile ? 45 : 50,
//           height: isMobile ? 45 : 50,
//           decoration: BoxDecoration(
//             color: const Color(0xFF3498DB),
//             borderRadius: BorderRadius.circular(isMobile ? 22.5 : 25),
//           ),
//           child: Center(
//             child: Text(
//               workCount.toString(),
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: isMobile ? 14 : 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//         title: Text(
//           companyName,
//           style: TextStyle(
//             fontSize: isMobile ? 15 : 16,
//             fontWeight: FontWeight.bold,
//             color: const Color(0xFF2C3E50),
//           ),
//         ),
//         subtitle: Text(
//           '$workCount نقلة',
//           style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.grey),
//         ),
//         trailing: Icon(
//           Icons.arrow_forward_ios,
//           color: const Color(0xFF3498DB),
//           size: isMobile ? 14 : 16,
//         ),
//       ),
//     );
//   }

//   // ====================================================
//   // دالة تعديل الشغل اليومي (محدثة لتشمل TR)
//   // ====================================================
//   void _editDailyWork(DailyWork dailyWork, String companyName, bool isMobile) {
//     // Controllers للحقول
//     final driverNameController = TextEditingController(
//       text: dailyWork.driverName,
//     );
//     final loadingLocationController = TextEditingController(
//       text: dailyWork.loadingLocation,
//     );
//     final unloadingLocationController = TextEditingController(
//       text: dailyWork.unloadingLocation,
//     );
//     final ohdaController = TextEditingController(text: dailyWork.ohda);
//     final kartaController = TextEditingController(text: dailyWork.karta);
//     final trController = TextEditingController(
//       text: dailyWork.tr ?? '',
//     ); // إضافة TR

//     showDialog(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: Dialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: SingleChildScrollView(
//             child: Container(
//               padding: EdgeInsets.all(isMobile ? 16 : 24),
//               width:
//                   MediaQuery.of(context).size.width * (isMobile ? 0.95 : 0.9),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // العنوان
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'تعديل النقلة',
//                         style: TextStyle(
//                           fontSize: isMobile ? 18 : 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.close, size: isMobile ? 20 : 24),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                     ],
//                   ),

//                   SizedBox(height: isMobile ? 4 : 8),
//                   Divider(color: const Color(0xFF3498DB).withOpacity(0.3)),

//                   // معلومات الشركة
//                   Container(
//                     padding: EdgeInsets.all(isMobile ? 10 : 12),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF3498DB).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.business,
//                           color: const Color(0xFF3498DB),
//                           size: isMobile ? 18 : 20,
//                         ),
//                         SizedBox(width: isMobile ? 6 : 8),
//                         Text(
//                           companyName,
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: const Color(0xFF2C3E50),
//                             fontSize: isMobile ? 14 : 16,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // عرض اسم الموقع (للقراءة فقط)
//                   Container(
//                     margin: EdgeInsets.only(top: 12),
//                     padding: EdgeInsets.all(isMobile ? 10 : 12),
//                     decoration: BoxDecoration(
//                       color: Colors.blue[50],
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.blue),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.map,
//                           color: Colors.blue[700],
//                           size: isMobile ? 16 : 18,
//                         ),
//                         SizedBox(width: isMobile ? 6 : 8),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'اسم الموقع (من عرض السعر):',
//                                 style: TextStyle(
//                                   fontSize: isMobile ? 12 : 14,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 dailyWork.selectedRoute ?? '',
//                                 style: TextStyle(
//                                   fontSize: isMobile ? 14 : 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blue[700],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   SizedBox(height: isMobile ? 16 : 20),

//                   // حقل اسم السائق
//                   _buildEditField(
//                     'اسم السائق',
//                     'أدخل اسم السائق',
//                     driverNameController,
//                     Icons.person,
//                     isMobile,
//                   ),

//                   SizedBox(height: isMobile ? 12 : 16),

//                   // حقل TR
//                   _buildEditField(
//                     'TR',
//                     'أدخل رقم TR',
//                     trController,
//                     Icons.numbers,
//                     isMobile,
//                     isRequired: false, // TR اختياري
//                   ),

//                   SizedBox(height: isMobile ? 12 : 16),

//                   // حقل مكان التحميل
//                   _buildEditField(
//                     'مكان التحميل',
//                     'أدخل مكان التحميل',
//                     loadingLocationController,
//                     Icons.location_on,
//                     isMobile,
//                   ),

//                   SizedBox(height: isMobile ? 12 : 16),

//                   // حقل مكان التعتيق
//                   _buildEditField(
//                     'مكان التعتيق',
//                     'أدخل مكان التعتيق',
//                     unloadingLocationController,
//                     Icons.location_on,
//                     isMobile,
//                   ),

//                   SizedBox(height: isMobile ? 12 : 16),

//                   // صف العهدة والكارتة
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _buildEditField(
//                           'العهدة',
//                           'أدخل العهدة',
//                           ohdaController,
//                           Icons.assignment,
//                           isMobile,
//                         ),
//                       ),
//                       SizedBox(width: isMobile ? 8 : 12),
//                       Expanded(
//                         child: _buildEditField(
//                           'الكارتة',
//                           'أدخل الكارتة',
//                           kartaController,
//                           Icons.credit_card,
//                           isMobile,
//                         ),
//                       ),
//                     ],
//                   ),

//                   SizedBox(height: isMobile ? 20 : 24),

//                   // أزرار الحفظ والإلغاء
//                   Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton(
//                           onPressed: () => Navigator.pop(context),
//                           style: OutlinedButton.styleFrom(
//                             padding: EdgeInsets.symmetric(
//                               vertical: isMobile ? 10 : 12,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: Text(
//                             'إلغاء',
//                             style: TextStyle(
//                               color: const Color(0xFF2C3E50),
//                               fontWeight: FontWeight.bold,
//                               fontSize: isMobile ? 14 : 16,
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: isMobile ? 8 : 12),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             // عرض تأكيد التعديل
//                             final confirmed = await _showConfirmEditDialog(
//                               context,
//                             );
//                             if (confirmed) {
//                               await _updateDailyWork(
//                                 dailyWork,
//                                 driverNameController.text,
//                                 loadingLocationController.text,
//                                 unloadingLocationController.text,
//                                 ohdaController.text,
//                                 kartaController.text,
//                                 trController.text, // إضافة TR
//                               );
//                               Navigator.pop(context);
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF3498DB),
//                             foregroundColor: Colors.white,
//                             padding: EdgeInsets.symmetric(
//                               vertical: isMobile ? 10 : 12,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: Text(
//                             'حفظ التعديلات',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: isMobile ? 14 : 16,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ====================================================
//   // دالة تأكيد التعديل
//   // ====================================================
//   Future<bool> _showConfirmEditDialog(BuildContext context) async {
//     return await showDialog<bool>(
//           context: context,
//           builder: (context) => Directionality(
//             textDirection: TextDirection.rtl,
//             child: AlertDialog(
//               title: Row(
//                 children: [
//                   Icon(Icons.info, color: Colors.blue),
//                   SizedBox(width: 8),
//                   Text('تأكيد التعديل'),
//                 ],
//               ),
//               content: Text(
//                 'هل تريد تعديل النقلة؟\n',
//                 textAlign: TextAlign.right,
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context, false),
//                   child: Text('إلغاء'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context, true),
//                   child: Text('تأكيد'),
//                 ),
//               ],
//             ),
//           ),
//         ) ??
//         false;
//   }

//   // ====================================================
//   // دالة لبناء حقل التعديل (محدثة)
//   // ====================================================
//   Widget _buildEditField(
//     String label,
//     String hint,
//     TextEditingController controller,
//     IconData icon,
//     bool isMobile, {
//     bool isRequired = true,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: const Color(0xFF2C3E50),
//                 fontSize: isMobile ? 13 : 14,
//               ),
//             ),
//             if (!isRequired)
//               Padding(
//                 padding: const EdgeInsets.only(right: 4),
//                 child: Text(
//                   '(اختياري)',
//                   style: TextStyle(
//                     fontSize: isMobile ? 10 : 11,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         SizedBox(height: isMobile ? 4 : 6),
//         TextFormField(
//           controller: controller,
//           decoration: InputDecoration(
//             hintText: isRequired ? hint : '$hint (اختياري)',
//             prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
//             filled: true,
//             fillColor: const Color(0xFFF4F6F8),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide.none,
//             ),
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: isMobile ? 12 : 16,
//               vertical: isMobile ? 10 : 12,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ====================================================
//   // دالة تحديث الشغل اليومي (محدثة لتشمل TR)
//   // ====================================================
//   Future<void> _updateDailyWork(
//     DailyWork dailyWork,
//     String driverName,
//     String loadingLocation,
//     String unloadingLocation,
//     String ohda,
//     String karta,
//     String tr, // إضافة TR
//   ) async {
//     try {
//       // 1. تحديث في collection "dailyWork"
//       await _firestore.collection('dailyWork').doc(dailyWork.id).update({
//         'driverName': driverName.trim(),
//         'loadingLocation': loadingLocation.trim(),
//         'unloadingLocation': unloadingLocation.trim(),
//         'ohda': ohda.trim(),
//         'karta': karta.trim(),
//         'tr': tr.trim(), // إضافة TR
//         'updatedAt': Timestamp.now(),
//       });

//       // 2. البحث عن وثائق السائق المرتبطة
//       final driverDocIds = await _findDriverDocumentIds(
//         dailyWork.id!,
//         driverName.trim(),
//         dailyWork.date,
//       );

//       // 3. إذا وجدت وثائق سائق مرتبطة، قم بتحديثها
//       if (driverDocIds.isNotEmpty) {
//         final batch = _firestore.batch();

//         for (final docId in driverDocIds) {
//           final docRef = _firestore.collection('drivers').doc(docId);

//           // تحديث جميع الحقول المرتبطة
//           batch.update(docRef, {
//             'driverName': driverName.trim(),
//             'loadingLocation': loadingLocation.trim(),
//             'unloadingLocation': unloadingLocation.trim(),
//             'ohda': ohda.trim(),
//             'karta': karta.trim(),
//             'tr': tr.trim(), // إضافة TR
//             'updatedAt': Timestamp.now(),
//           });
//         }

//         await batch.commit();
//       }

//       // إظهار رسالة نجاح
//       if (mounted) {
//         _showSuccess('تم تعديل النقلة بنجاح');
//       }
//     } catch (e) {
//       print('Error updating daily work: $e');
//       if (mounted) {
//         _showError('خطأ في التعديل: $e');
//       }
//     }
//   }

//   // ====================================================
//   // دالة البحث عن وثائق السائق المرتبطة
//   // ====================================================
//   Future<List<String>> _findDriverDocumentIds(
//     String dailyWorkId,
//     String driverName,
//     DateTime date,
//   ) async {
//     try {
//       // البحث باستخدام dailyWorkId
//       if (dailyWorkId.isNotEmpty) {
//         final queryById = await _firestore
//             .collection('drivers')
//             .where('dailyWorkId', isEqualTo: dailyWorkId)
//             .get();

//         if (queryById.docs.isNotEmpty) {
//           return queryById.docs.map((doc) => doc.id).toList();
//         }
//       }

//       // البحث باستخدام اسم السائق والتاريخ
//       final startOfDay = DateTime(date.year, date.month, date.day);
//       final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

//       final queryByDriver = await _firestore
//           .collection('drivers')
//           .where('driverName', isEqualTo: driverName)
//           .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
//           .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
//           .get();

//       return queryByDriver.docs.map((doc) => doc.id).toList();
//     } catch (e) {
//       print('خطأ في البحث عن وثائق السائق: $e');
//       return [];
//     }
//   }

//   // ====================================================
//   // دالة حذف الشغل اليومي
//   // ====================================================
//   void _deleteDailyWork(DailyWork dailyWork, bool isMobile) {
//     showDialog(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           title: Row(
//             children: [
//               Icon(
//                 Icons.warning,
//                 color: Colors.orange,
//                 size: isMobile ? 20 : 24,
//               ),
//               SizedBox(width: isMobile ? 6 : 8),
//               Text(
//                 'تأكيد الحذف',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFF2C3E50),
//                   fontSize: isMobile ? 16 : 18,
//                 ),
//               ),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'هل أنت متأكد من حذف هذه النقلة؟',
//                 style: TextStyle(fontSize: isMobile ? 14 : 16),
//               ),
//               SizedBox(height: isMobile ? 6 : 8),
//               Text(
//                 'السائق: ${dailyWork.driverName}',
//                 style: const TextStyle(color: Colors.grey),
//               ),
//               Text(
//                 'المسار: ${dailyWork.loadingLocation} → ${dailyWork.unloadingLocation}',
//                 style: const TextStyle(color: Colors.grey),
//               ),
//               Text(
//                 'اسم الموقع: ${dailyWork.selectedRoute}',
//                 style: TextStyle(
//                   color: Colors.blue[700],
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               if (dailyWork.tr?.isNotEmpty ?? false) // إضافة TR
//                 Text(
//                   'TR: ${dailyWork.tr}',
//                   style: TextStyle(
//                     color: Colors.green[700],
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               SizedBox(height: isMobile ? 12 : 16),
//               Text(
//                 '⚠️ لا يمكن التراجع عن هذا الإجراء',
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontSize: isMobile ? 10 : 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text(
//                 'إلغاء',
//                 style: TextStyle(
//                   color: const Color(0xFF2C3E50),
//                   fontSize: isMobile ? 14 : 16,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 _confirmDeleteDailyWork(dailyWork);
//                 Navigator.pop(context);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//               ),
//               child: Text(
//                 'حذف',
//                 style: TextStyle(fontSize: isMobile ? 14 : 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ====================================================
//   // دالة تأكيد الحذف
//   // ====================================================
//   Future<void> _confirmDeleteDailyWork(DailyWork dailyWork) async {
//     try {
//       await _firestore.collection('dailyWork').doc(dailyWork.id).delete();

//       // إظهار رسالة نجاح
//       if (mounted) {
//         _showSuccess('تم حذف النقلة بنجاح');
//       }
//     } catch (e) {
//       print('Error deleting daily work: $e');
//       if (mounted) {
//         _showError('خطأ في الحذف: $e');
//       }
//     }
//   }

//   void _showCompanyDetails(
//     String companyId,
//     String companyName,
//     bool isMobile,
//   ) {
//     showDialog(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: Dialog(
//           backgroundColor: Colors.transparent,
//           insetPadding: EdgeInsets.all(isMobile ? 8 : 16),
//           child: Container(
//             width: MediaQuery.of(context).size.width * (isMobile ? 0.98 : 0.95),
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.9,
//             ),
//             padding: EdgeInsets.all(isMobile ? 16 : 20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.15),
//                   blurRadius: 20,
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // العنوان
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.close, size: isMobile ? 20 : 24),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                     Text(
//                       'نقلات $companyName',
//                       style: TextStyle(
//                         fontSize: isMobile ? 18 : 20,
//                         fontWeight: FontWeight.bold,
//                         color: const Color(0xFF2C3E50),
//                       ),
//                     ),
//                     SizedBox(width: isMobile ? 40 : 48),
//                   ],
//                 ),

//                 SizedBox(height: isMobile ? 4 : 8),
//                 Divider(color: const Color(0xFF3498DB).withOpacity(0.3)),

//                 // معلومات الشركة والفلتر
//                 Container(
//                   padding: EdgeInsets.all(isMobile ? 10 : 12),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF3498DB).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       Column(
//                         children: [
//                           Text(
//                             'اسم الشركة',
//                             style: TextStyle(
//                               fontSize: isMobile ? 10 : 11,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           Text(
//                             companyName,
//                             style: TextStyle(
//                               fontSize: isMobile ? 14 : 16,
//                               fontWeight: FontWeight.bold,
//                               color: const Color(0xFF2C3E50),
//                             ),
//                           ),
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           Text(
//                             'فلتر التاريخ',
//                             style: TextStyle(
//                               fontSize: isMobile ? 10 : 11,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           InkWell(
//                             onTap: () => _selectDateForDetails(context),
//                             child: Container(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: isMobile ? 10 : 12,
//                                 vertical: isMobile ? 5 : 6,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(6),
//                                 border: Border.all(
//                                   color: const Color(0xFF3498DB),
//                                 ),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Icon(
//                                     Icons.calendar_today,
//                                     size: isMobile ? 14 : 16,
//                                     color: const Color(0xFF3498DB),
//                                   ),
//                                   SizedBox(width: isMobile ? 4 : 6),
//                                   Text(
//                                     _selectedDate != null
//                                         ? _formatDate(_selectedDate!)
//                                         : 'جميع التواريخ',
//                                     style: TextStyle(
//                                       fontSize: isMobile ? 11 : 12,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 SizedBox(height: isMobile ? 12 : 16),
//                 Expanded(
//                   child: _buildCompanyWorkTable(
//                     companyId,
//                     companyName,
//                     isMobile,
//                   ),
//                 ),
//                 SizedBox(height: isMobile ? 12 : 16),

//                 // زر الإغلاق
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF3498DB),
//                     foregroundColor: Colors.white,
//                     elevation: 2,
//                     padding: EdgeInsets.symmetric(
//                       horizontal: isMobile ? 30 : 40,
//                       vertical: isMobile ? 10 : 12,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: Text(
//                     'إغلاق',
//                     style: TextStyle(fontSize: isMobile ? 14 : 16),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _selectDateForDetails(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   Widget _buildCompanyWorkTable(
//     String companyId,
//     String companyName,
//     bool isMobile,
//   ) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _getCompanyDailyWorkStream(companyId),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.error, size: isMobile ? 40 : 48, color: Colors.red),
//                 SizedBox(height: isMobile ? 6 : 8),
//                 Text(
//                   'خطأ في تحميل البيانات: ${snapshot.error}',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: isMobile ? 12 : 14,
//                     color: Colors.red,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         final dailyWorks = _convertSnapshotToDailyWorkList(snapshot.data);

//         if (dailyWorks.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.work_outline,
//                   size: isMobile ? 50 : 64,
//                   color: Colors.grey,
//                 ),
//                 SizedBox(height: isMobile ? 12 : 16),
//                 Text(
//                   'لا توجد نقلات',
//                   style: TextStyle(
//                     fontSize: isMobile ? 14 : 16,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         return Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: Colors.transparent, width: 1.5),
//           ),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.vertical,
//               child: Table(
//                 defaultColumnWidth: FixedColumnWidth(isMobile ? 120 : 140),
//                 border: TableBorder.all(
//                   color: const Color(0xFF3498DB),
//                   width: 1,
//                 ),
//                 children: [
//                   TableRow(
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF3498DB).withOpacity(0.15),
//                     ),
//                     children: [
//                       _TableCellHeader('م', isMobile),
//                       _TableCellHeader('التاريخ', isMobile),
//                       _TableCellHeader('اسم السائق', isMobile),
//                       _TableCellHeader('مكان التحميل', isMobile),
//                       _TableCellHeader('مكان التعتيق', isMobile),
//                       _TableCellHeader('اسم الموقع', isMobile),
//                       _TableCellHeader('TR', isMobile), // إضافة TR
//                       _TableCellHeader('العهدة', isMobile),
//                       _TableCellHeader('الكارتة', isMobile),
//                       _TableCellHeader('الإجراءات', isMobile),
//                     ],
//                   ),
//                   ...dailyWorks.asMap().entries.map((entry) {
//                     final index = entry.key;
//                     final dailyWork = entry.value;

//                     return TableRow(
//                       decoration: BoxDecoration(
//                         color: index.isEven
//                             ? Colors.white
//                             : const Color(0xFFF8F9FA),
//                       ),
//                       children: [
//                         _TableCellBody('${index + 1}', isMobile),
//                         _TableCellBody(_formatDate(dailyWork.date), isMobile),
//                         _TableCellBody(dailyWork.driverName, isMobile),
//                         _TableCellBody(dailyWork.loadingLocation, isMobile),
//                         _TableCellBody(dailyWork.unloadingLocation, isMobile),
//                         _TableCellBody(
//                           dailyWork.selectedRoute,
//                           isMobile,
//                           textStyle: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue[700],
//                           ),
//                         ),
//                         _TableCellBody(
//                           dailyWork.tr ?? '', // عرض TR
//                           isMobile,
//                           textStyle: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.green[700],
//                           ),
//                         ),
//                         _TableCellBody(
//                           dailyWork.ohda,
//                           isMobile,
//                           textStyle: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF2E7D32),
//                           ),
//                         ),
//                         _TableCellBody(
//                           dailyWork.karta,
//                           isMobile,
//                           textStyle: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFFD35400),
//                           ),
//                         ),
//                         _TableCellActionsWithHolidayAndOvernight(
//                           dailyWork: dailyWork,
//                           companyName: companyName,
//                           isMobile: isMobile,
//                           onEdit: () =>
//                               _editDailyWork(dailyWork, companyName, isMobile),
//                           onDelete: () => _deleteDailyWork(dailyWork, isMobile),
//                           onAddHoliday: () =>
//                               _addHoliday(dailyWork, companyName, isMobile),
//                           onAddOvernight: () =>
//                               _addOvernight(dailyWork, companyName, isMobile),
//                         ),
//                       ],
//                     );
//                   }).toList(),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // دالة لإنشاء Stream للبيانات
//   Stream<QuerySnapshot> _getCompanyDailyWorkStream(String companyId) {
//     Query query = _firestore
//         .collection('dailyWork')
//         .where('companyId', isEqualTo: companyId);

//     if (_selectedDate != null) {
//       final startOfDay = DateTime(
//         _selectedDate!.year,
//         _selectedDate!.month,
//         _selectedDate!.day,
//       );
//       final endOfDay = DateTime(
//         _selectedDate!.year,
//         _selectedDate!.month,
//         _selectedDate!.day,
//         23,
//         59,
//         59,
//       );

//       query = query
//           .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
//           .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));
//     }

//     return query.snapshots();
//   }

//   // دالة لتحويل الـ Snapshot إلى قائمة DailyWork
//   List<DailyWork> _convertSnapshotToDailyWorkList(QuerySnapshot? snapshot) {
//     if (snapshot == null) return [];

//     final dailyWorks = snapshot.docs.map((doc) {
//       final data = _safeConvertDocumentData(doc.data());
//       return DailyWork.fromMap(data, doc.id);
//     }).toList();

//     dailyWorks.sort((a, b) => b.date.compareTo(a.date));
//     return dailyWorks;
//   }

//   // ====================================================
//   // الدوال الجديدة لإضافة العطلة والمبيت (باستخدام priceOfferId)
//   // ====================================================

//   // دالة لجلب بيانات عرض السعر للشركة باستخدام priceOfferId
//   Future<Map<String, dynamic>?> _getPriceOfferData(
//     String companyId,
//     String priceOfferId,
//   ) async {
//     try {
//       print('🔍 جلب بيانات عرض السعر:');
//       print('   companyId: $companyId');
//       print('   priceOfferId: $priceOfferId');

//       // التحقق من وجود قيم
//       if (companyId.isEmpty || priceOfferId.isEmpty) {
//         print('❌ companyId أو priceOfferId فارغ');
//         return null;
//       }

//       // المسار في Firestore: companies/{companyId}/priceOffers/{priceOfferId}
//       final snapshot = await _firestore
//           .collection('companies')
//           .doc(companyId)
//           .collection('priceOffers')
//           .doc(priceOfferId)
//           .get();

//       if (snapshot.exists) {
//         print('✅ تم العثور على عرض السعر');
//         return snapshot.data();
//       } else {
//         print('❌ عرض السعر غير موجود في Firestore');
//         return null;
//       }
//     } catch (e) {
//       print('🚨 خطأ في جلب بيانات عرض السعر: $e');
//       return null;
//     }
//   }

//   // دالة إضافة عطلة
//   void _addHoliday(DailyWork dailyWork, String companyName, bool isMobile) {
//     _addHolidayOrOvernight(dailyWork, companyName, isMobile, true);
//   }

//   // دالة إضافة مبيت
//   void _addOvernight(DailyWork dailyWork, String companyName, bool isMobile) {
//     _addHolidayOrOvernight(dailyWork, companyName, isMobile, false);
//   }

//   // دالة مشتركة لإضافة عطلة أو مبيت
//   void _addHolidayOrOvernight(
//     DailyWork dailyWork,
//     String companyName,
//     bool isMobile,
//     bool isHoliday,
//   ) async {
//     try {
//       print('🎯 بدء إضافة ${isHoliday ? 'عطلة' : 'مبيت'}');
//       print('   السائق: ${dailyWork.driverName}');
//       print('   المسار: ${dailyWork.selectedRoute}');
//       print('   companyId: ${dailyWork.companyId}');
//       print('   priceOfferId: ${dailyWork.priceOfferId}');

//       // التحقق من وجود priceOfferId
//       if (dailyWork.priceOfferId == null || dailyWork.priceOfferId!.isEmpty) {
//         _showError('❌ لا يوجد عرض سعر مرتبط بهذه النقلة');
//         return;
//       }

//       // جلب بيانات عرض السعر
//       final priceOfferData = await _getPriceOfferData(
//         dailyWork.companyId,
//         dailyWork.priceOfferId!,
//       );

//       if (priceOfferData == null) {
//         _showError('❌ عرض السعر غير موجود');
//         return;
//       }

//       // استخراج قائمة النقلات
//       final transportations = priceOfferData['transportations'] as List? ?? [];
//       print('   عدد النقلات في العرض: ${transportations.length}');

//       if (transportations.isEmpty) {
//         _showError('❌ لا توجد نقلات في عرض السعر');
//         return;
//       }

//       // البحث عن النقل المناسب
//       Map<String, dynamic>? selectedTransportation;

//       for (final transport in transportations) {
//         final transportMap = transport as Map<String, dynamic>;
//         final unloadingLocation =
//             transportMap['unloadingLocation']?.toString() ?? '';
//         final selectedRoute = dailyWork.selectedRoute?.toString() ?? '';

//         print('   🔍 مقارنة: "$unloadingLocation" مع "$selectedRoute"');

//         if (unloadingLocation == selectedRoute) {
//           selectedTransportation = transportMap;
//           print('   ✅ تم العثور على نقل مطابق');
//           break;
//         }
//       }

//       // إذا لم نجد تطابق، نستخدم أول نقل
//       if (selectedTransportation == null) {
//         selectedTransportation = transportations.first as Map<String, dynamic>;
//         print('   ⚠️ استخدام أول نقل (لم يتم العثور على تطابق دقيق)');
//       }

//       // استخراج المبالغ
//       double companyAmount = 0.0;
//       double wheelAmount = 0.0;

//       if (isHoliday) {
//         // استخراج قيم العطلة
//         companyAmount = _extractValue(selectedTransportation, [
//           'companyHoliday',
//           'company_holiday',
//           'holiday_company',
//           'companyHolidayPrice',
//         ]);

//         wheelAmount = _extractValue(selectedTransportation, [
//           'wheelHoliday',
//           'wheel_holiday',
//           'holiday_wheel',
//           'wheelHolidayPrice',
//         ]);
//       } else {
//         // استخراج قيم المبيت
//         companyAmount = _extractValue(selectedTransportation, [
//           'companyOvernight',
//           'company_overnight',
//           'overnight_company',
//           'companyOvernightPrice',
//         ]);

//         wheelAmount = _extractValue(selectedTransportation, [
//           'wheelOvernight',
//           'wheel_overnight',
//           'overnight_wheel',
//           'wheelOvernightPrice',
//         ]);
//       }

//       print('💰 القيم المستخرجة:');
//       print('   ${isHoliday ? 'عطلة الشركة' : 'مبيت الشركة'}: $companyAmount');
//       print('   ${isHoliday ? 'عطلة العجلات' : 'مبيت العجلات'}: $wheelAmount');

//       // إظهار تأكيد
//       final confirmed = await _showSimpleConfirmation(
//         context,
//         isHoliday,
//         companyAmount,
//         wheelAmount,
//         isMobile,
//       );

//       if (confirmed != null && confirmed) {
//         // تحديث البيانات في Firestore
//         await _updateHolidayOrOvernight(
//           dailyWork,
//           isHoliday,
//           companyAmount,
//           wheelAmount,
//         );
//       }
//     } catch (e) {
//       print('🚨 خطأ في إضافة العطلة/المبيت: $e');
//       _showError('❌ خطأ في إضافة العطلة/المبيت: ${e.toString()}');
//     }
//   }

//   // دالة مساعدة لاستخراج قيمة
//   double _extractValue(Map<String, dynamic> data, List<String> keys) {
//     for (final key in keys) {
//       final value = data[key];
//       if (value != null) {
//         if (value is int) return value.toDouble();
//         if (value is double) return value;
//         if (value is String) {
//           final parsed = double.tryParse(value);
//           if (parsed != null) return parsed;
//         }
//       }
//     }
//     return 0.0;
//   }

//   // دالة تأكيد بسيطة
//   Future<bool?> _showSimpleConfirmation(
//     BuildContext context,
//     bool isHoliday,
//     double companyAmount,
//     double wheelAmount,
//     bool isMobile,
//   ) {
//     return showDialog<bool>(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           title: Row(
//             children: [
//               Icon(
//                 isHoliday ? Icons.celebration : Icons.hotel,
//                 color: isHoliday ? Colors.orange : Colors.blue,
//                 size: isMobile ? 24 : 28,
//               ),
//               SizedBox(width: isMobile ? 8 : 12),
//               Text(
//                 isHoliday ? 'إضافة عطلة' : 'إضافة مبيت',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: isMobile ? 16 : 18,
//                   color: const Color(0xFF2C3E50),
//                 ),
//               ),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 isHoliday ? 'سيتم إضافة عطلة بقيمة:' : 'سيتم إضافة مبيت بقيمة:',
//                 style: TextStyle(fontSize: isMobile ? 14 : 16),
//               ),
//               SizedBox(height: isMobile ? 8 : 12),
//               // عطلة/مبيت الشركة
//               _buildAmountItem(
//                 isHoliday ? 'عطلة الشركة' : 'مبيت الشركة',
//                 companyAmount,
//                 isHoliday ? Colors.orange : Colors.blue,
//                 isMobile,
//               ),
//               SizedBox(height: 6),
//               // عطلة/مبيت العجلات
//               _buildAmountItem(
//                 isHoliday ? 'عطلة العجلات' : 'مبيت العجلات',
//                 wheelAmount,
//                 isHoliday ? Colors.orange[700]! : Colors.blue[700]!,
//                 isMobile,
//               ),
//               SizedBox(height: isMobile ? 8 : 12),
//               Divider(color: Colors.grey[300]),
//               SizedBox(height: isMobile ? 8 : 12),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: Text(
//                 'إلغاء',
//                 style: TextStyle(fontSize: isMobile ? 14 : 16),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context, true),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: isHoliday ? Colors.orange : Colors.blue,
//                 foregroundColor: Colors.white,
//               ),
//               child: Text(
//                 'تأكيد',
//                 style: TextStyle(fontSize: isMobile ? 14 : 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // دالة لعرض عنصر المبلغ
//   Widget _buildAmountItem(
//     String label,
//     double amount,
//     Color color,
//     bool isMobile,
//   ) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(fontSize: isMobile ? 13 : 14, color: color),
//         ),
//         Text(
//           '$amount ج',
//           style: TextStyle(
//             fontSize: isMobile ? 13 : 14,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }

//   // دالة تحديث العطلة أو المبيت
//   Future<void> _updateHolidayOrOvernight(
//     DailyWork dailyWork,
//     bool isHoliday,
//     double companyAmount,
//     double wheelAmount,
//   ) async {
//     try {
//       print('🔄 تحديث البيانات في Firestore...');

//       // 1. تحديث dailyWork collection
//       final updateData = <String, dynamic>{'updatedAt': Timestamp.now()};

//       if (isHoliday) {
//         updateData.addAll({
//           'companyHoliday': companyAmount,
//           'wheelHoliday': wheelAmount,
//         });
//       } else {
//         updateData.addAll({
//           'companyOvernight': companyAmount,
//           'wheelOvernight': wheelAmount,
//         });
//       }

//       // تحديث مستند dailyWork
//       await _firestore
//           .collection('dailyWork')
//           .doc(dailyWork.id)
//           .update(updateData);

//       print('✅ تم تحديث dailyWork');

//       // 2. تحديث drivers collection
//       await _updateDriversCollection(
//         dailyWork,
//         isHoliday,
//         companyAmount,
//         wheelAmount,
//       );

//       print('✅ تم تحديث drivers collection');

//       // رسالة نجاح
//       _showSuccess(
//         isHoliday ? '✅ تم إضافة العطلة بنجاح' : '✅ تم إضافة المبيت بنجاح',
//       );
//     } catch (e) {
//       print('🚨 خطأ في تحديث Firestore: $e');
//       _showError('❌ خطأ في تحديث البيانات: ${e.toString()}');
//     }
//   }

//   // دالة تحديث drivers collection
//   Future<void> _updateDriversCollection(
//     DailyWork dailyWork,
//     bool isHoliday,
//     double companyAmount,
//     double wheelAmount,
//   ) async {
//     try {
//       // البحث عن سجلات السائق المرتبطة
//       final query = await _firestore
//           .collection('drivers')
//           .where('dailyWorkId', isEqualTo: dailyWork.id)
//           .limit(10)
//           .get();

//       print('   عدد سجلات السائق المرتبطة: ${query.docs.length}');

//       if (query.docs.isNotEmpty) {
//         final batch = _firestore.batch();
//         final totalAmount = companyAmount + wheelAmount;

//         for (final doc in query.docs) {
//           final updateData = <String, dynamic>{'updatedAt': Timestamp.now()};

//           if (isHoliday) {
//             updateData.addAll({
//               'companyHoliday': companyAmount,
//               'wheelHoliday': wheelAmount,
//             });
//           } else {
//             updateData.addAll({
//               'companyOvernight': companyAmount,
//               'wheelOvernight': wheelAmount,
//             });
//           }

//           // تحديث المبلغ المتبقي
//           updateData['remainingAmount'] = FieldValue.increment(totalAmount);

//           batch.update(doc.reference, updateData);
//         }

//         await batch.commit();
//         print('✅ تم تحديث ${query.docs.length} سجل للسائق');
//       } else {
//         print('⚠️ لم يتم العثور على سجلات سائق مرتبطة');
//       }
//     } catch (e) {
//       print('🚨 خطأ في تحديث سجلات السائقين: $e');
//       throw e;
//     }
//   }

//   // ====================================================
//   // باقي الدوال الحالية
//   // ====================================================

//   // دالة إظهار خطأ
//   void _showError(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   // دالة إظهار نجاح
//   void _showSuccess(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.green,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }

// class _TableCellBody extends StatelessWidget {
//   final String text;
//   final bool isMobile;
//   final TextStyle? textStyle;

//   const _TableCellBody(this.text, this.isMobile, {this.textStyle});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: isMobile ? 40 : 48,
//       alignment: Alignment.center,
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
//       child: Text(
//         text,
//         maxLines: 2,
//         overflow: TextOverflow.ellipsis,
//         textAlign: TextAlign.center,
//         style: textStyle ?? TextStyle(fontSize: isMobile ? 11 : 14),
//       ),
//     );
//   }
// }

// class _TableCellHeader extends StatelessWidget {
//   final String text;
//   final bool isMobile;

//   const _TableCellHeader(this.text, this.isMobile);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: isMobile ? 42 : 50,
//       alignment: Alignment.center,
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: isMobile ? 11 : 14,
//           color: const Color(0xFF2C3E50),
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
// }

// class _TableCellActionsWithHolidayAndOvernight extends StatelessWidget {
//   final DailyWork dailyWork;
//   final String companyName;
//   final bool isMobile;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//   final VoidCallback onAddHoliday;
//   final VoidCallback onAddOvernight;

//   const _TableCellActionsWithHolidayAndOvernight({
//     required this.dailyWork,
//     required this.companyName,
//     required this.isMobile,
//     required this.onEdit,
//     required this.onDelete,
//     required this.onAddHoliday,
//     required this.onAddOvernight,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: isMobile ? 40 : 48,
//       alignment: Alignment.center,
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // زر إضافة عطلة (يظهر دائماً)
//           IconButton(
//             icon: Container(
//               padding: EdgeInsets.all(isMobile ? 3 : 5),
//               decoration: BoxDecoration(
//                 color: Colors.orange.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Icon(
//                 Icons.celebration,
//                 size: isMobile ? 12 : 14,
//                 color: Colors.orange,
//               ),
//             ),
//             onPressed: onAddHoliday,
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//             tooltip: 'إضافة عطلة',
//           ),
//           SizedBox(width: isMobile ? 2 : 4),

//           // زر إضافة مبيت (يظهر دائماً)
//           IconButton(
//             icon: Container(
//               padding: EdgeInsets.all(isMobile ? 3 : 5),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Icon(
//                 Icons.hotel,
//                 size: isMobile ? 12 : 14,
//                 color: Colors.blue,
//               ),
//             ),
//             onPressed: onAddOvernight,
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//             tooltip: 'إضافة مبيت',
//           ),
//           SizedBox(width: isMobile ? 2 : 4),

//           // زر التعديل
//           IconButton(
//             icon: Container(
//               padding: EdgeInsets.all(isMobile ? 4 : 6),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Icon(
//                 Icons.edit,
//                 size: isMobile ? 14 : 16,
//                 color: Colors.blue,
//               ),
//             ),
//             onPressed: onEdit,
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//           ),
//           SizedBox(width: isMobile ? 2 : 4),

//           // زر الحذف
//           IconButton(
//             icon: Container(
//               padding: EdgeInsets.all(isMobile ? 4 : 6),
//               decoration: BoxDecoration(
//                 color: Colors.red.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Icon(
//                 Icons.delete,
//                 size: isMobile ? 14 : 16,
//                 color: Colors.red,
//               ),
//             ),
//             onPressed: onDelete,
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//           ),
//         ],
//       ),
//     );
//   }
// // }
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:last/models/models.dart';

// class MonthlyRecordPage extends StatefulWidget {
//   const MonthlyRecordPage({super.key});

//   @override
//   State<MonthlyRecordPage> createState() => _MonthlyRecordPageState();
// }

// class _MonthlyRecordPageState extends State<MonthlyRecordPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   String _searchQuery = '';
//   DateTime? _selectedDate;

//   // دالة مساعدة لتحويل البيانات بأمان
//   Map<String, dynamic> _safeConvertDocumentData(Object? data) {
//     if (data == null) {
//       return {};
//     }

//     if (data is Map<String, dynamic>) {
//       return data;
//     }

//     if (data is Map<dynamic, dynamic>) {
//       return data.cast<String, dynamic>();
//     }

//     return {};
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6F8),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           final bool isMobile = constraints.maxWidth < 600;

//           return Column(
//             children: [
//               _buildCustomAppBar(isMobile),
//               _buildFilterSection(isMobile),
//               Expanded(child: _buildCompaniesWithWorkList(isMobile)),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildCustomAppBar(bool isMobile) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: isMobile ? 16 : 24,
//         vertical: isMobile ? 16 : 20,
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
//             Icon(
//               Icons.calendar_month,
//               color: Colors.white,
//               size: isMobile ? 28 : 32,
//             ),
//             SizedBox(width: isMobile ? 8 : 12),
//             Text(
//               'السجل الشهري',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: isMobile ? 20 : 24,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Cairo',
//               ),
//             ),
//             const Spacer(flex: 12),
//             StreamBuilder<DateTime>(
//               stream: Stream.periodic(
//                 const Duration(seconds: 1),
//                 (_) => DateTime.now(),
//               ),
//               builder: (context, snapshot) {
//                 final now = snapshot.data ?? DateTime.now();

//                 // تحويل إلى نظام 12 ساعة
//                 int hour12 = now.hour % 12;
//                 if (hour12 == 0) hour12 = 12; // تحويل 0 إلى 12

//                 // تحديد AM/PM
//                 String period = now.hour < 12 ? 'AM' : 'PM';

//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Container(
//                       height: 50,
//                       width: 150,
//                       decoration: BoxDecoration(
//                         color: Colors.transparent,
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Center(
//                         child: Text(
//                           '${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 36,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterSection(bool isMobile) {
//     return Container(
//       padding: EdgeInsets.all(isMobile ? 12 : 16),
//       color: Colors.white,
//       child: Column(
//         children: [
//           _buildSearchBar(isMobile),
//           SizedBox(height: isMobile ? 12 : 16),
//           _buildDateFilter(isMobile),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchBar(bool isMobile) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF4F6F8),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFF3498DB)),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             Icons.search,
//             color: const Color(0xFF3498DB),
//             size: isMobile ? 20 : 24,
//           ),
//           SizedBox(width: isMobile ? 8 : 12),
//           Expanded(
//             child: TextField(
//               onChanged: (value) => setState(() => _searchQuery = value),
//               decoration: const InputDecoration(
//                 hintText: 'ابحث عن شركة...',
//                 border: InputBorder.none,
//                 hintStyle: TextStyle(color: Colors.grey),
//               ),
//             ),
//           ),
//           if (_searchQuery.isNotEmpty)
//             GestureDetector(
//               onTap: () => setState(() => _searchQuery = ''),
//               child: Icon(
//                 Icons.clear,
//                 size: isMobile ? 18 : 20,
//                 color: Colors.grey,
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDateFilter(bool isMobile) {
//     return Row(
//       children: [
//         Expanded(
//           child: InkWell(
//             onTap: () => _selectDate(context),
//             child: Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: isMobile ? 12 : 16,
//                 vertical: isMobile ? 10 : 12,
//               ),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF4F6F8),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: const Color(0xFF3498DB)),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.calendar_today,
//                     color: const Color(0xFF3498DB),
//                     size: isMobile ? 18 : 20,
//                   ),
//                   SizedBox(width: isMobile ? 8 : 12),
//                   Expanded(
//                     child: Text(
//                       _selectedDate != null
//                           ? _formatDate(_selectedDate!)
//                           : 'جميع التواريخ',
//                       style: TextStyle(
//                         fontSize: isMobile ? 13 : 14,
//                         color: _selectedDate != null
//                             ? Colors.black
//                             : Colors.grey,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         SizedBox(width: isMobile ? 8 : 12),
//         if (_selectedDate != null)
//           IconButton(
//             icon: Icon(
//               Icons.clear,
//               color: Colors.red,
//               size: isMobile ? 20 : 24,
//             ),
//             onPressed: () => setState(() => _selectedDate = null),
//           ),
//       ],
//     );
//   }

//   Widget _buildCompaniesWithWorkList(bool isMobile) {
//     return FutureBuilder<List<Map<String, dynamic>>>(
//       future: _getCompaniesWithWork(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.error, size: isMobile ? 48 : 64, color: Colors.red),
//                 SizedBox(height: isMobile ? 12 : 16),
//                 Text(
//                   'خطأ في تحميل البيانات: ${snapshot.error}',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: isMobile ? 14 : 16),
//                 ),
//               ],
//             ),
//           );
//         }

//         final companiesList = snapshot.data ?? [];

//         final filteredCompanies = companiesList
//             .where((company) {
//               if (_searchQuery.isEmpty) return true;
//               final companyName =
//                   company['companyName']?.toString().toLowerCase() ?? '';
//               return companyName.contains(_searchQuery.toLowerCase());
//             })
//             .where((company) {
//               return (company['workCount'] as int) > 0;
//             })
//             .toList();

//         if (filteredCompanies.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.business,
//                   size: isMobile ? 60 : 80,
//                   color: Colors.grey,
//                 ),
//                 SizedBox(height: isMobile ? 12 : 16),
//                 Text(
//                   'لا توجد شركات لديها شغل يومي',
//                   style: TextStyle(
//                     fontSize: isMobile ? 16 : 18,
//                     color: Colors.grey,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: isMobile ? 4 : 8),
//                 Text(
//                   _searchQuery.isEmpty
//                       ? 'أضف شغل يومي جديد للبدء'
//                       : 'لم يتم العثور على نتائج البحث',
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontSize: isMobile ? 12 : 14,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         return ListView.builder(
//           padding: EdgeInsets.all(isMobile ? 12 : 16),
//           itemCount: filteredCompanies.length,
//           itemBuilder: (context, index) {
//             final companyData = filteredCompanies[index];
//             return _buildCompanyItem(
//               companyData['companyId'] as String,
//               companyData,
//               isMobile,
//             );
//           },
//         );
//       },
//     );
//   }

//   Future<List<Map<String, dynamic>>> _getCompaniesWithWork() async {
//     try {
//       final dailyWorksSnapshot = await _firestore
//           .collection('dailyWork')
//           .where(
//             'date',
//             isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(2020)),
//           )
//           .get();

//       final companyData = <String, Map<String, dynamic>>{};

//       for (final work in dailyWorksSnapshot.docs) {
//         final data = _safeConvertDocumentData(work.data());
//         final companyId = data['companyId']?.toString() ?? '';
//         final companyName = data['companyName']?.toString() ?? '';
//         final workDate = (data['date'] as Timestamp?)?.toDate();

//         if (companyId.isEmpty || companyName.isEmpty) continue;

//         if (_selectedDate != null && workDate != null) {
//           final startOfDay = DateTime(
//             _selectedDate!.year,
//             _selectedDate!.month,
//             _selectedDate!.day,
//           );
//           final endOfDay = DateTime(
//             _selectedDate!.year,
//             _selectedDate!.month,
//             _selectedDate!.day,
//             23,
//             59,
//             59,
//           );

//           if (workDate.isBefore(startOfDay) || workDate.isAfter(endOfDay)) {
//             continue;
//           }
//         }

//         if (!companyData.containsKey(companyId)) {
//           companyData[companyId] = {
//             'companyId': companyId,
//             'companyName': companyName,
//             'workCount': 0,
//           };
//         }

//         companyData[companyId]!['workCount'] =
//             (companyData[companyId]!['workCount'] as int) + 1;
//       }

//       return companyData.values.toList();
//     } catch (e) {
//       print('Error getting companies with work: $e');
//       rethrow;
//     }
//   }

//   Widget _buildCompanyItem(
//     String companyId,
//     Map<String, dynamic> data,
//     bool isMobile,
//   ) {
//     final companyName = data['companyName']?.toString() ?? '';
//     final workCount = data['workCount'] as int? ?? 0;

//     return Container(
//       margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFF3498DB).withOpacity(0.3)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         onTap: () => _showCompanyDetails(companyId, companyName, isMobile),
//         leading: Container(
//           width: isMobile ? 45 : 50,
//           height: isMobile ? 45 : 50,
//           decoration: BoxDecoration(
//             color: const Color(0xFF3498DB),
//             borderRadius: BorderRadius.circular(isMobile ? 22.5 : 25),
//           ),
//           child: Center(
//             child: Text(
//               workCount.toString(),
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: isMobile ? 14 : 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//         title: Text(
//           companyName,
//           style: TextStyle(
//             fontSize: isMobile ? 15 : 16,
//             fontWeight: FontWeight.bold,
//             color: const Color(0xFF2C3E50),
//           ),
//         ),
//         subtitle: Text(
//           '$workCount نقلة',
//           style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.grey),
//         ),
//         trailing: Icon(
//           Icons.arrow_forward_ios,
//           color: const Color(0xFF3498DB),
//           size: isMobile ? 14 : 16,
//         ),
//       ),
//     );
//   }

//   // ====================================================
//   // دالة تعديل الشغل اليومي (محدثة لتشمل TR)
//   // ====================================================
//   void _editDailyWork(DailyWork dailyWork, String companyName, bool isMobile) {
//     // Controllers للحقول
//     final driverNameController = TextEditingController(
//       text: dailyWork.driverName,
//     );
//     final loadingLocationController = TextEditingController(
//       text: dailyWork.loadingLocation,
//     );
//     final unloadingLocationController = TextEditingController(
//       text: dailyWork.unloadingLocation,
//     );
//     final ohdaController = TextEditingController(text: dailyWork.ohda);
//     final kartaController = TextEditingController(text: dailyWork.karta);
//     final trController = TextEditingController(text: dailyWork.tr ?? '');

//     showDialog(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: Dialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: SingleChildScrollView(
//             child: Container(
//               padding: EdgeInsets.all(isMobile ? 16 : 24),
//               width:
//                   MediaQuery.of(context).size.width * (isMobile ? 0.95 : 0.9),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // العنوان
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'تعديل النقلة',
//                         style: TextStyle(
//                           fontSize: isMobile ? 18 : 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.close, size: isMobile ? 20 : 24),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                     ],
//                   ),

//                   SizedBox(height: isMobile ? 4 : 8),
//                   Divider(color: const Color(0xFF3498DB).withOpacity(0.3)),

//                   // معلومات الشركة
//                   Container(
//                     padding: EdgeInsets.all(isMobile ? 10 : 12),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF3498DB).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.business,
//                           color: const Color(0xFF3498DB),
//                           size: isMobile ? 18 : 20,
//                         ),
//                         SizedBox(width: isMobile ? 6 : 8),
//                         Text(
//                           companyName,
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: const Color(0xFF2C3E50),
//                             fontSize: isMobile ? 14 : 16,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // عرض اسم الموقع (للقراءة فقط)
//                   Container(
//                     margin: EdgeInsets.only(top: 12),
//                     padding: EdgeInsets.all(isMobile ? 10 : 12),
//                     decoration: BoxDecoration(
//                       color: Colors.blue[50],
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.blue),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(
//                           Icons.map,
//                           color: Colors.blue[700],
//                           size: isMobile ? 16 : 18,
//                         ),
//                         SizedBox(width: isMobile ? 6 : 8),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'اسم الموقع (من عرض السعر):',
//                                 style: TextStyle(
//                                   fontSize: isMobile ? 12 : 14,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                               SizedBox(height: 4),
//                               Text(
//                                 dailyWork.selectedRoute ?? '',
//                                 style: TextStyle(
//                                   fontSize: isMobile ? 14 : 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blue[700],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   SizedBox(height: isMobile ? 16 : 20),

//                   // حقل اسم السائق
//                   _buildEditField(
//                     'اسم السائق',
//                     'أدخل اسم السائق',
//                     driverNameController,
//                     Icons.person,
//                     isMobile,
//                   ),

//                   SizedBox(height: isMobile ? 12 : 16),

//                   // حقل TR
//                   _buildEditField(
//                     'TR',
//                     'أدخل رقم TR',
//                     trController,
//                     Icons.numbers,
//                     isMobile,
//                     isRequired: false,
//                   ),

//                   SizedBox(height: isMobile ? 12 : 16),

//                   // حقل مكان التحميل
//                   _buildEditField(
//                     'مكان التحميل',
//                     'أدخل مكان التحميل',
//                     loadingLocationController,
//                     Icons.location_on,
//                     isMobile,
//                   ),

//                   SizedBox(height: isMobile ? 12 : 16),

//                   // حقل مكان التعتيق
//                   _buildEditField(
//                     'مكان التعتيق',
//                     'أدخل مكان التعتيق',
//                     unloadingLocationController,
//                     Icons.location_on,
//                     isMobile,
//                   ),

//                   SizedBox(height: isMobile ? 12 : 16),

//                   // صف العهدة والكارتة
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _buildEditField(
//                           'العهدة',
//                           'أدخل العهدة',
//                           ohdaController,
//                           Icons.assignment,
//                           isMobile,
//                         ),
//                       ),
//                       SizedBox(width: isMobile ? 8 : 12),
//                       Expanded(
//                         child: _buildEditField(
//                           'الكارتة',
//                           'أدخل الكارتة',
//                           kartaController,
//                           Icons.credit_card,
//                           isMobile,
//                         ),
//                       ),
//                     ],
//                   ),

//                   SizedBox(height: isMobile ? 20 : 24),

//                   // أزرار الحفظ والإلغاء
//                   Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton(
//                           onPressed: () => Navigator.pop(context),
//                           style: OutlinedButton.styleFrom(
//                             padding: EdgeInsets.symmetric(
//                               vertical: isMobile ? 10 : 12,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: Text(
//                             'إلغاء',
//                             style: TextStyle(
//                               color: const Color(0xFF2C3E50),
//                               fontWeight: FontWeight.bold,
//                               fontSize: isMobile ? 14 : 16,
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: isMobile ? 8 : 12),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () async {
//                             // عرض تأكيد التعديل
//                             final confirmed = await _showConfirmEditDialog(
//                               context,
//                             );
//                             if (confirmed) {
//                               await _updateDailyWork(
//                                 dailyWork,
//                                 driverNameController.text,
//                                 loadingLocationController.text,
//                                 unloadingLocationController.text,
//                                 ohdaController.text,
//                                 kartaController.text,
//                                 trController.text,
//                               );
//                               Navigator.pop(context);
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF3498DB),
//                             foregroundColor: Colors.white,
//                             padding: EdgeInsets.symmetric(
//                               vertical: isMobile ? 10 : 12,
//                             ),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: Text(
//                             'حفظ التعديلات',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: isMobile ? 14 : 16,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ====================================================
//   // دالة تأكيد التعديل
//   // ====================================================
//   Future<bool> _showConfirmEditDialog(BuildContext context) async {
//     return await showDialog<bool>(
//           context: context,
//           builder: (context) => Directionality(
//             textDirection: TextDirection.rtl,
//             child: AlertDialog(
//               title: Row(
//                 children: [
//                   Icon(Icons.info, color: Colors.blue),
//                   SizedBox(width: 8),
//                   Text('تأكيد التعديل'),
//                 ],
//               ),
//               content: Text(
//                 'هل تريد تعديل النقلة؟\n',
//                 textAlign: TextAlign.right,
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context, false),
//                   child: Text('إلغاء'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context, true),
//                   child: Text('تأكيد'),
//                 ),
//               ],
//             ),
//           ),
//         ) ??
//         false;
//   }

//   // ====================================================
//   // دالة لبناء حقل التعديل (محدثة)
//   // ====================================================
//   Widget _buildEditField(
//     String label,
//     String hint,
//     TextEditingController controller,
//     IconData icon,
//     bool isMobile, {
//     bool isRequired = true,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: const Color(0xFF2C3E50),
//                 fontSize: isMobile ? 13 : 14,
//               ),
//             ),
//             if (!isRequired)
//               Padding(
//                 padding: const EdgeInsets.only(right: 4),
//                 child: Text(
//                   '(اختياري)',
//                   style: TextStyle(
//                     fontSize: isMobile ? 10 : 11,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         SizedBox(height: isMobile ? 4 : 6),
//         TextFormField(
//           controller: controller,
//           decoration: InputDecoration(
//             hintText: isRequired ? hint : '$hint (اختياري)',
//             prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
//             filled: true,
//             fillColor: const Color(0xFFF4F6F8),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide.none,
//             ),
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: isMobile ? 12 : 16,
//               vertical: isMobile ? 10 : 12,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ====================================================
//   // دالة تحديث الشغل اليومي (محدثة لتشمل TR)
//   // ====================================================
//   Future<void> _updateDailyWork(
//     DailyWork dailyWork,
//     String driverName,
//     String loadingLocation,
//     String unloadingLocation,
//     String ohda,
//     String karta,
//     String tr,
//   ) async {
//     try {
//       // 1. تحديث في collection "dailyWork"
//       await _firestore.collection('dailyWork').doc(dailyWork.id).update({
//         'driverName': driverName.trim(),
//         'loadingLocation': loadingLocation.trim(),
//         'unloadingLocation': unloadingLocation.trim(),
//         'ohda': ohda.trim(),
//         'karta': karta.trim(),
//         'tr': tr.trim(),
//         'updatedAt': Timestamp.now(),
//       });

//       // 2. البحث عن وثائق السائق المرتبطة
//       final driverDocIds = await _findDriverDocumentIds(
//         dailyWork.id!,
//         driverName.trim(),
//         dailyWork.date,
//       );

//       // 3. إذا وجدت وثائق سائق مرتبطة، قم بتحديثها
//       if (driverDocIds.isNotEmpty) {
//         final batch = _firestore.batch();

//         for (final docId in driverDocIds) {
//           final docRef = _firestore.collection('drivers').doc(docId);

//           // تحديث جميع الحقول المرتبطة
//           batch.update(docRef, {
//             'driverName': driverName.trim(),
//             'loadingLocation': loadingLocation.trim(),
//             'unloadingLocation': unloadingLocation.trim(),
//             'ohda': ohda.trim(),
//             'karta': karta.trim(),
//             'tr': tr.trim(),
//             'updatedAt': Timestamp.now(),
//           });
//         }

//         await batch.commit();
//       }

//       // إظهار رسالة نجاح
//       if (mounted) {
//         _showSuccess('تم تعديل النقلة بنجاح');
//       }
//     } catch (e) {
//       print('Error updating daily work: $e');
//       if (mounted) {
//         _showError('خطأ في التعديل: $e');
//       }
//     }
//   }

//   // ====================================================
//   // دالة البحث عن وثائق السائق المرتبطة
//   // ====================================================
//   Future<List<String>> _findDriverDocumentIds(
//     String dailyWorkId,
//     String driverName,
//     DateTime date,
//   ) async {
//     try {
//       // البحث باستخدام dailyWorkId
//       if (dailyWorkId.isNotEmpty) {
//         final queryById = await _firestore
//             .collection('drivers')
//             .where('dailyWorkId', isEqualTo: dailyWorkId)
//             .get();

//         if (queryById.docs.isNotEmpty) {
//           return queryById.docs.map((doc) => doc.id).toList();
//         }
//       }

//       // البحث باستخدام اسم السائق والتاريخ
//       final startOfDay = DateTime(date.year, date.month, date.day);
//       final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

//       final queryByDriver = await _firestore
//           .collection('drivers')
//           .where('driverName', isEqualTo: driverName)
//           .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
//           .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
//           .get();

//       return queryByDriver.docs.map((doc) => doc.id).toList();
//     } catch (e) {
//       print('خطأ في البحث عن وثائق السائق: $e');
//       return [];
//     }
//   }

//   // ====================================================
//   // دالة حذف الشغل اليومي
//   // ====================================================
//   void _deleteDailyWork(DailyWork dailyWork, bool isMobile) {
//     showDialog(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           title: Row(
//             children: [
//               Icon(
//                 Icons.warning,
//                 color: Colors.orange,
//                 size: isMobile ? 20 : 24,
//               ),
//               SizedBox(width: isMobile ? 6 : 8),
//               Text(
//                 'تأكيد الحذف',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFF2C3E50),
//                   fontSize: isMobile ? 16 : 18,
//                 ),
//               ),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'هل أنت متأكد من حذف هذه النقلة؟',
//                 style: TextStyle(fontSize: isMobile ? 14 : 16),
//               ),
//               SizedBox(height: isMobile ? 6 : 8),
//               Text(
//                 'السائق: ${dailyWork.driverName}',
//                 style: const TextStyle(color: Colors.grey),
//               ),
//               Text(
//                 'المسار: ${dailyWork.loadingLocation} → ${dailyWork.unloadingLocation}',
//                 style: const TextStyle(color: Colors.grey),
//               ),
//               Text(
//                 'اسم الموقع: ${dailyWork.selectedRoute}',
//                 style: TextStyle(
//                   color: Colors.blue[700],
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               if (dailyWork.tr.isNotEmpty ?? false)
//                 Text(
//                   'TR: ${dailyWork.tr}',
//                   style: TextStyle(
//                     color: Colors.green[700],
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               SizedBox(height: isMobile ? 12 : 16),
//               Text(
//                 '⚠️ لا يمكن التراجع عن هذا الإجراء',
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontSize: isMobile ? 10 : 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text(
//                 'إلغاء',
//                 style: TextStyle(
//                   color: const Color(0xFF2C3E50),
//                   fontSize: isMobile ? 14 : 16,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 _confirmDeleteDailyWork(dailyWork);
//                 Navigator.pop(context);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//               ),
//               child: Text(
//                 'حذف',
//                 style: TextStyle(fontSize: isMobile ? 14 : 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ====================================================
//   // دالة تأكيد الحذف
//   // ====================================================
//   Future<void> _confirmDeleteDailyWork(DailyWork dailyWork) async {
//     try {
//       await _firestore.collection('dailyWork').doc(dailyWork.id).delete();

//       // إظهار رسالة نجاح
//       if (mounted) {
//         _showSuccess('تم حذف النقلة بنجاح');
//       }
//     } catch (e) {
//       print('Error deleting daily work: $e');
//       if (mounted) {
//         _showError('خطأ في الحذف: $e');
//       }
//     }
//   }

//   void _showCompanyDetails(
//     String companyId,
//     String companyName,
//     bool isMobile,
//   ) {
//     showDialog(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: Dialog(
//           backgroundColor: Colors.transparent,
//           insetPadding: EdgeInsets.all(isMobile ? 8 : 16),
//           child: Container(
//             width: MediaQuery.of(context).size.width * (isMobile ? 0.98 : 0.95),
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.9,
//             ),
//             padding: EdgeInsets.all(isMobile ? 16 : 20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.15),
//                   blurRadius: 20,
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // العنوان
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.close, size: isMobile ? 20 : 24),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                     Text(
//                       'نقلات $companyName',
//                       style: TextStyle(
//                         fontSize: isMobile ? 18 : 20,
//                         fontWeight: FontWeight.bold,
//                         color: const Color(0xFF2C3E50),
//                       ),
//                     ),
//                     SizedBox(width: isMobile ? 40 : 48),
//                   ],
//                 ),

//                 SizedBox(height: isMobile ? 4 : 8),
//                 Divider(color: const Color(0xFF3498DB).withOpacity(0.3)),

//                 // معلومات الشركة والفلتر
//                 Container(
//                   padding: EdgeInsets.all(isMobile ? 10 : 12),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF3498DB).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       Column(
//                         children: [
//                           Text(
//                             'اسم الشركة',
//                             style: TextStyle(
//                               fontSize: isMobile ? 10 : 11,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           Text(
//                             companyName,
//                             style: TextStyle(
//                               fontSize: isMobile ? 14 : 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           Text(
//                             'فلتر التاريخ',
//                             style: TextStyle(
//                               fontSize: isMobile ? 10 : 11,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           InkWell(
//                             onTap: () => _selectDateForDetails(context),
//                             child: Container(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: isMobile ? 10 : 12,
//                                 vertical: isMobile ? 5 : 6,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(6),
//                                 border: Border.all(
//                                   color: const Color(0xFF3498DB),
//                                 ),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Icon(
//                                     Icons.calendar_today,
//                                     size: isMobile ? 14 : 16,
//                                     color: const Color(0xFF3498DB),
//                                   ),
//                                   SizedBox(width: isMobile ? 4 : 6),
//                                   Text(
//                                     _selectedDate != null
//                                         ? _formatDate(_selectedDate!)
//                                         : 'جميع التواريخ',
//                                     style: TextStyle(
//                                       fontSize: isMobile ? 11 : 12,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 SizedBox(height: isMobile ? 12 : 16),
//                 Expanded(
//                   child: _buildCompanyWorkTable(
//                     companyId,
//                     companyName,
//                     isMobile,
//                   ),
//                 ),
//                 SizedBox(height: isMobile ? 12 : 16),

//                 // زر الإغلاق
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF3498DB),
//                     foregroundColor: Colors.white,
//                     elevation: 2,
//                     padding: EdgeInsets.symmetric(
//                       horizontal: isMobile ? 30 : 40,
//                       vertical: isMobile ? 10 : 12,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: Text(
//                     'إغلاق',
//                     style: TextStyle(fontSize: isMobile ? 14 : 16),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _selectDateForDetails(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   Widget _buildCompanyWorkTable(
//     String companyId,
//     String companyName,
//     bool isMobile,
//   ) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _getCompanyDailyWorkStream(companyId),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.error, size: isMobile ? 40 : 48, color: Colors.red),
//                 SizedBox(height: isMobile ? 6 : 8),
//                 Text(
//                   'خطأ في تحميل البيانات: ${snapshot.error}',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: isMobile ? 12 : 14,
//                     color: Colors.red,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         final dailyWorks = _convertSnapshotToDailyWorkList(snapshot.data);

//         if (dailyWorks.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.work_outline,
//                   size: isMobile ? 50 : 64,
//                   color: Colors.grey,
//                 ),
//                 SizedBox(height: isMobile ? 12 : 16),
//                 Text(
//                   'لا توجد نقلات',
//                   style: TextStyle(
//                     fontSize: isMobile ? 14 : 16,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         return Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: Colors.transparent, width: 1.5),
//           ),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.vertical,
//               child: Table(
//                 defaultColumnWidth: FixedColumnWidth(isMobile ? 110 : 130),
//                 border: TableBorder.all(
//                   color: const Color(0xFF3498DB),
//                   width: 1,
//                 ),
//                 children: [
//                   TableRow(
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF3498DB).withOpacity(0.15),
//                     ),
//                     children: [
//                       _TableCellHeader('م', isMobile),
//                       _TableCellHeader('التاريخ', isMobile),
//                       _TableCellHeader('اسم السائق', isMobile),
//                       _TableCellHeader('مكان التحميل', isMobile),
//                       _TableCellHeader('مكان التعتيق', isMobile),
//                       _TableCellHeader('مطابقه نولون', isMobile),
//                       _TableCellHeader('TR', isMobile),
//                       _TableCellHeader('العهدة', isMobile),
//                       _TableCellHeader('الكارتة', isMobile),
//                       _TableCellHeader('الإجراءات', isMobile),
//                     ],
//                   ),
//                   ...dailyWorks.asMap().entries.map((entry) {
//                     final index = entry.key;
//                     final dailyWork = entry.value;

//                     return TableRow(
//                       decoration: BoxDecoration(
//                         color: index.isEven
//                             ? Colors.white
//                             : const Color(0xFFF8F9FA),
//                       ),
//                       children: [
//                         _TableCellBody('${index + 1}', isMobile),
//                         _TableCellBody(_formatDate(dailyWork.date), isMobile),
//                         _TableCellBody(dailyWork.driverName, isMobile),
//                         _TableCellBody(dailyWork.loadingLocation, isMobile),
//                         _TableCellBody(dailyWork.unloadingLocation, isMobile),
//                         _TableCellBody(
//                           dailyWork.selectedRoute,
//                           isMobile,
//                           textStyle: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue[700],
//                           ),
//                         ),
//                         _TableCellBody(
//                           dailyWork.tr ?? '',
//                           isMobile,
//                           textStyle: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.green[700],
//                           ),
//                         ),
//                         _TableCellBody(
//                           dailyWork.ohda,
//                           isMobile,
//                           textStyle: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF2E7D32),
//                           ),
//                         ),
//                         _TableCellKartaWithAdd(
//                           dailyWork: dailyWork,
//                           isMobile: isMobile,
//                           onAddBalance: () =>
//                               _showAddBalanceDialog(dailyWork, isMobile),
//                         ),
//                         _TableCellActionsWithHolidayAndOvernight(
//                           dailyWork: dailyWork,
//                           companyName: companyName,
//                           isMobile: isMobile,
//                           onEdit: () =>
//                               _editDailyWork(dailyWork, companyName, isMobile),
//                           onDelete: () => _deleteDailyWork(dailyWork, isMobile),
//                           onAddHoliday: () =>
//                               _addHoliday(dailyWork, companyName, isMobile),
//                           onAddOvernight: () =>
//                               _addOvernight(dailyWork, companyName, isMobile),
//                         ),
//                       ],
//                     );
//                   }),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ====================================================
//   // دالة إضافة ميزان الشركات للكارتة - مٌصَحَّحة
//   // ====================================================
//   void _showAddBalanceDialog(DailyWork dailyWork, bool isMobile) {
//     final balanceController = TextEditingController();
//     final currentKarta = double.tryParse(dailyWork.karta) ?? 0.0;
//     bool showNewTotal = false;
//     double newTotal = currentKarta;

//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Directionality(
//               textDirection: TextDirection.rtl,
//               child: AlertDialog(
//                 backgroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 title: Row(
//                   children: [
//                     Icon(
//                       Icons.add_circle,
//                       color: Colors.orange[700],
//                       size: isMobile ? 24 : 28,
//                     ),
//                     SizedBox(width: isMobile ? 8 : 12),
//                     Text(
//                       'إضافة ميزان الشركه',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: isMobile ? 16 : 18,
//                         color: const Color(0xFF2C3E50),
//                       ),
//                     ),
//                   ],
//                 ),
//                 content: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // عرض الكارتة الحالية
//                     Container(
//                       padding: EdgeInsets.all(isMobile ? 10 : 12),
//                       decoration: BoxDecoration(
//                         color: Colors.orange[50],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.orange),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'قيمة الكارتة الحالية:',
//                             style: TextStyle(
//                               fontSize: isMobile ? 12 : 14,
//                               color: Colors.orange[800],
//                             ),
//                           ),
//                           Text(
//                             '$currentKarta ج',
//                             style: TextStyle(
//                               fontSize: isMobile ? 14 : 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.orange[800],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: isMobile ? 16 : 20),

//                     // حقل إدخال الميزان
//                     Text(
//                       'قيمة الميزان الإضافية:',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: isMobile ? 13 : 14,
//                         color: const Color(0xFF2C3E50),
//                       ),
//                     ),
//                     SizedBox(height: isMobile ? 6 : 8),
//                     TextFormField(
//                       controller: balanceController,
//                       keyboardType: TextInputType.number,
//                       onChanged: (value) {
//                         final balanceValue = double.tryParse(value) ?? 0.0;
//                         newTotal = currentKarta + balanceValue;
//                         setState(() {
//                           showNewTotal = value.isNotEmpty && balanceValue > 0;
//                         });
//                       },
//                       decoration: InputDecoration(
//                         hintText: 'أدخل قيمة الميزان',
//                         prefixIcon: Icon(
//                           Icons.attach_money,
//                           color: Colors.orange[700],
//                         ),
//                         filled: true,
//                         fillColor: const Color(0xFFF4F6F8),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide.none,
//                         ),
//                         contentPadding: EdgeInsets.symmetric(
//                           horizontal: isMobile ? 12 : 16,
//                           vertical: isMobile ? 12 : 16,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: isMobile ? 8 : 12),

//                     // عرض القيمة الجديدة
//                     if (showNewTotal)
//                       Container(
//                         padding: EdgeInsets.all(isMobile ? 10 : 12),
//                         decoration: BoxDecoration(
//                           color: Colors.green[50],
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.green),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'القيمة الإجمالية الجديدة:',
//                               style: TextStyle(
//                                 fontSize: isMobile ? 12 : 14,
//                                 color: Colors.green[800],
//                               ),
//                             ),
//                             Text(
//                               '$newTotal ج',
//                               style: TextStyle(
//                                 fontSize: isMobile ? 14 : 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.green[800],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text(
//                       'إلغاء',
//                       style: TextStyle(fontSize: isMobile ? 14 : 16),
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: () async {
//                       if (balanceController.text.isEmpty) {
//                         _showError('يرجى إدخال قيمة الميزان');
//                         return;
//                       }

//                       final balanceValue =
//                           double.tryParse(balanceController.text) ?? 0.0;
//                       if (balanceValue <= 0) {
//                         _showError('القيمة يجب أن تكون أكبر من صفر');
//                         return;
//                       }

//                       await _updateKartaWithBalance(dailyWork, balanceValue);
//                       Navigator.pop(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.orange,
//                       foregroundColor: Colors.white,
//                     ),
//                     child: Text(
//                       'حفظ',
//                       style: TextStyle(fontSize: isMobile ? 14 : 16),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   // ====================================================
//   // دالة تحديث الكارتة بالميزان
//   // ====================================================
//   Future<void> _updateKartaWithBalance(
//     DailyWork dailyWork,
//     double balanceValue,
//   ) async {
//     try {
//       final currentKarta = double.tryParse(dailyWork.karta) ?? 0.0;
//       final newKarta = currentKarta + balanceValue;
//       final kartaString = newKarta.toStringAsFixed(2);
//       final kartaString2 = currentKarta.toStringAsFixed(2);

//       // 1. تحديث في collection "dailyWork"
//       await _firestore.collection('dailyWork').doc(dailyWork.id).update({
//         'karta': kartaString,
//         'companyBalance': FieldValue.increment(balanceValue),
//         'updatedAt': Timestamp.now(),
//       });

//       // 2. تحديث سجلات السائقين المرتبطة
//       final driverDocIds = await _findDriverDocumentIds(
//         dailyWork.id!,
//         dailyWork.driverName,
//         dailyWork.date,
//       );

//       if (driverDocIds.isNotEmpty) {
//         final batch = _firestore.batch();

//         for (final docId in driverDocIds) {
//           final docRef = _firestore.collection('drivers').doc(docId);
//           batch.update(docRef, {
//             'karta': kartaString2,
//             'companyBalance': FieldValue.increment(balanceValue),
//             'updatedAt': Timestamp.now(),
//           });
//         }

//         await batch.commit();
//       }

//       // إظهار رسالة نجاح
//       if (mounted) {
//         _showSuccess(
//           'تم إضافة ميزان بقيمة $balanceValue ج\nالقيمة الجديدة للكارتة: $kartaString ج',
//         );
//       }
//     } catch (e) {
//       print('خطأ في تحديث الكارتة: $e');
//       if (mounted) {
//         _showError('خطأ في إضافة الميزان: $e');
//       }
//     }
//   }

//   // ====================================================
//   // بقية الدوال الموجودة مسبقاً (بدون تغيير)
//   // ====================================================

//   // دالة لإنشاء Stream للبيانات
//   Stream<QuerySnapshot> _getCompanyDailyWorkStream(String companyId) {
//     Query query = _firestore
//         .collection('dailyWork')
//         .where('companyId', isEqualTo: companyId);

//     if (_selectedDate != null) {
//       final startOfDay = DateTime(
//         _selectedDate!.year,
//         _selectedDate!.month,
//         _selectedDate!.day,
//       );
//       final endOfDay = DateTime(
//         _selectedDate!.year,
//         _selectedDate!.month,
//         _selectedDate!.day,
//         23,
//         59,
//         59,
//       );

//       query = query
//           .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
//           .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));
//     }

//     return query.snapshots();
//   }

//   // دالة لتحويل الـ Snapshot إلى قائمة DailyWork
//   List<DailyWork> _convertSnapshotToDailyWorkList(QuerySnapshot? snapshot) {
//     if (snapshot == null) return [];

//     final dailyWorks = snapshot.docs.map((doc) {
//       final data = _safeConvertDocumentData(doc.data());
//       return DailyWork.fromMap(data, doc.id);
//     }).toList();

//     dailyWorks.sort((a, b) => b.date.compareTo(a.date));
//     return dailyWorks;
//   }

//   // ====================================================
//   // الدوال الجديدة لإضافة العطلة والمبيت
//   // ====================================================

//   // دالة لجلب بيانات عرض السعر للشركة باستخدام priceOfferId
//   Future<Map<String, dynamic>?> _getPriceOfferData(
//     String companyId,
//     String priceOfferId,
//   ) async {
//     try {
//       print('🔍 جلب بيانات عرض السعر:');
//       print('   companyId: $companyId');
//       print('   priceOfferId: $priceOfferId');

//       if (companyId.isEmpty || priceOfferId.isEmpty) {
//         print('❌ companyId أو priceOfferId فارغ');
//         return null;
//       }

//       final snapshot = await _firestore
//           .collection('companies')
//           .doc(companyId)
//           .collection('priceOffers')
//           .doc(priceOfferId)
//           .get();

//       if (snapshot.exists) {
//         print('✅ تم العثور على عرض السعر');
//         return snapshot.data();
//       } else {
//         print('❌ عرض السعر غير موجود في Firestore');
//         return null;
//       }
//     } catch (e) {
//       print('🚨 خطأ في جلب بيانات عرض السعر: $e');
//       return null;
//     }
//   }

//   // دالة إضافة عطلة
//   void _addHoliday(DailyWork dailyWork, String companyName, bool isMobile) {
//     _addHolidayOrOvernight(dailyWork, companyName, isMobile, true);
//   }

//   // دالة إضافة مبيت
//   void _addOvernight(DailyWork dailyWork, String companyName, bool isMobile) {
//     _addHolidayOrOvernight(dailyWork, companyName, isMobile, false);
//   }

//   // دالة مشتركة لإضافة عطلة أو مبيت
//   void _addHolidayOrOvernight(
//     DailyWork dailyWork,
//     String companyName,
//     bool isMobile,
//     bool isHoliday,
//   ) async {
//     try {
//       print('🎯 بدء إضافة ${isHoliday ? 'عطلة' : 'مبيت'}');
//       print('   السائق: ${dailyWork.driverName}');
//       print('   المسار: ${dailyWork.selectedRoute}');
//       print('   companyId: ${dailyWork.companyId}');
//       print('   priceOfferId: ${dailyWork.priceOfferId}');

//       if (dailyWork.priceOfferId.isEmpty) {
//         _showError('❌ لا يوجد عرض سعر مرتبط بهذه النقلة');
//         return;
//       }

//       final priceOfferData = await _getPriceOfferData(
//         dailyWork.companyId,
//         dailyWork.priceOfferId,
//       );

//       if (priceOfferData == null) {
//         _showError('❌ عرض السعر غير موجود');
//         return;
//       }

//       final transportations = priceOfferData['transportations'] as List? ?? [];
//       print('   عدد النقلات في العرض: ${transportations.length}');

//       if (transportations.isEmpty) {
//         _showError('❌ لا توجد نقلات في عرض السعر');
//         return;
//       }

//       Map<String, dynamic>? selectedTransportation;

//       for (final transport in transportations) {
//         final transportMap = transport as Map<String, dynamic>;
//         final unloadingLocation =
//             transportMap['unloadingLocation']?.toString() ?? '';
//         final selectedRoute = dailyWork.selectedRoute.toString() ?? '';

//         print('   🔍 مقارنة: "$unloadingLocation" مع "$selectedRoute"');

//         if (unloadingLocation == selectedRoute) {
//           selectedTransportation = transportMap;
//           print('   ✅ تم العثور على نقل مطابق');
//           break;
//         }
//       }

//       if (selectedTransportation == null) {
//         selectedTransportation = transportations.first as Map<String, dynamic>;
//         print('   ⚠️ استخدام أول نقل (لم يتم العثور على تطابق دقيق)');
//       }

//       double companyAmount = 0.0;
//       double wheelAmount = 0.0;

//       if (isHoliday) {
//         companyAmount = _extractValue(selectedTransportation, [
//           'companyHoliday',
//           'company_holiday',
//           'holiday_company',
//           'companyHolidayPrice',
//         ]);

//         wheelAmount = _extractValue(selectedTransportation, [
//           'wheelHoliday',
//           'wheel_holiday',
//           'holiday_wheel',
//           'wheelHolidayPrice',
//         ]);
//       } else {
//         companyAmount = _extractValue(selectedTransportation, [
//           'companyOvernight',
//           'company_overnight',
//           'overnight_company',
//           'companyOvernightPrice',
//         ]);

//         wheelAmount = _extractValue(selectedTransportation, [
//           'wheelOvernight',
//           'wheel_overnight',
//           'overnight_wheel',
//           'wheelOvernightPrice',
//         ]);
//       }

//       print('💰 القيم المستخرجة:');
//       print('   ${isHoliday ? 'عطلة الشركة' : 'مبيت الشركة'}: $companyAmount');
//       print('   ${isHoliday ? 'عطلة العجلات' : 'مبيت العجلات'}: $wheelAmount');

//       final confirmed = await _showSimpleConfirmation(
//         context,
//         isHoliday,
//         companyAmount,
//         wheelAmount,
//         isMobile,
//       );

//       if (confirmed != null && confirmed) {
//         await _updateHolidayOrOvernight(
//           dailyWork,
//           isHoliday,
//           companyAmount,
//           wheelAmount,
//         );
//       }
//     } catch (e) {
//       print('🚨 خطأ في إضافة العطلة/المبيت: $e');
//       _showError('❌ خطأ في إضافة العطلة/المبيت: ${e.toString()}');
//     }
//   }

//   // دالة مساعدة لاستخراج قيمة
//   double _extractValue(Map<String, dynamic> data, List<String> keys) {
//     for (final key in keys) {
//       final value = data[key];
//       if (value != null) {
//         if (value is int) return value.toDouble();
//         if (value is double) return value;
//         if (value is String) {
//           final parsed = double.tryParse(value);
//           if (parsed != null) return parsed;
//         }
//       }
//     }
//     return 0.0;
//   }

//   // دالة تأكيد بسيطة
//   Future<bool?> _showSimpleConfirmation(
//     BuildContext context,
//     bool isHoliday,
//     double companyAmount,
//     double wheelAmount,
//     bool isMobile,
//   ) {
//     return showDialog<bool>(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           title: Row(
//             children: [
//               Icon(
//                 isHoliday ? Icons.celebration : Icons.hotel,
//                 color: isHoliday ? Colors.orange : Colors.blue,
//                 size: isMobile ? 24 : 28,
//               ),
//               SizedBox(width: isMobile ? 8 : 12),
//               Text(
//                 isHoliday ? 'إضافة عطلة' : 'إضافة مبيت',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: isMobile ? 16 : 18,
//                   color: const Color(0xFF2C3E50),
//                 ),
//               ),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 isHoliday ? 'سيتم إضافة عطلة بقيمة:' : 'سيتم إضافة مبيت بقيمة:',
//                 style: TextStyle(fontSize: isMobile ? 14 : 16),
//               ),
//               SizedBox(height: isMobile ? 8 : 12),
//               _buildAmountItem(
//                 isHoliday ? 'عطلة الشركة' : 'مبيت الشركة',
//                 companyAmount,
//                 isHoliday ? Colors.orange : Colors.blue,
//                 isMobile,
//               ),
//               SizedBox(height: 6),
//               _buildAmountItem(
//                 isHoliday ? 'عطلة العجلات' : 'مبيت العجلات',
//                 wheelAmount,
//                 isHoliday ? Colors.orange[700]! : Colors.blue[700]!,
//                 isMobile,
//               ),
//               SizedBox(height: isMobile ? 8 : 12),
//               Divider(color: Colors.grey[300]),
//               SizedBox(height: isMobile ? 8 : 12),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: Text(
//                 'إلغاء',
//                 style: TextStyle(fontSize: isMobile ? 14 : 16),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context, true),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: isHoliday ? Colors.orange : Colors.blue,
//                 foregroundColor: Colors.white,
//               ),
//               child: Text(
//                 'تأكيد',
//                 style: TextStyle(fontSize: isMobile ? 14 : 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // دالة لعرض عنصر المبلغ
//   Widget _buildAmountItem(
//     String label,
//     double amount,
//     Color color,
//     bool isMobile,
//   ) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(fontSize: isMobile ? 13 : 14, color: color),
//         ),
//         Text(
//           '$amount ج',
//           style: TextStyle(
//             fontSize: isMobile ? 13 : 14,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }

//   // دالة تحديث العطلة أو المبيت
//   Future<void> _updateHolidayOrOvernight(
//     DailyWork dailyWork,
//     bool isHoliday,
//     double companyAmount,
//     double wheelAmount,
//   ) async {
//     try {
//       print('🔄 تحديث البيانات في Firestore...');

//       final updateData = <String, dynamic>{'updatedAt': Timestamp.now()};

//       if (isHoliday) {
//         updateData.addAll({
//           'companyHoliday': companyAmount,
//           'wheelHoliday': wheelAmount,
//         });
//       } else {
//         updateData.addAll({
//           'companyOvernight': companyAmount,
//           'wheelOvernight': wheelAmount,
//         });
//       }

//       await _firestore
//           .collection('dailyWork')
//           .doc(dailyWork.id)
//           .update(updateData);

//       print('✅ تم تحديث dailyWork');

//       await _updateDriversCollection(
//         dailyWork,
//         isHoliday,
//         companyAmount,
//         wheelAmount,
//       );

//       print('✅ تم تحديث drivers collection');

//       _showSuccess(
//         isHoliday ? '✅ تم إضافة العطلة بنجاح' : '✅ تم إضافة المبيت بنجاح',
//       );
//     } catch (e) {
//       print('🚨 خطأ في تحديث Firestore: $e');
//       _showError('❌ خطأ في تحديث البيانات: ${e.toString()}');
//     }
//   }

//   // دالة تحديث drivers collection
//   Future<void> _updateDriversCollection(
//     DailyWork dailyWork,
//     bool isHoliday,
//     double companyAmount,
//     double wheelAmount,
//   ) async {
//     try {
//       final query = await _firestore
//           .collection('drivers')
//           .where('dailyWorkId', isEqualTo: dailyWork.id)
//           .limit(10)
//           .get();

//       print('   عدد سجلات السائق المرتبطة: ${query.docs.length}');

//       if (query.docs.isNotEmpty) {
//         final batch = _firestore.batch();
//         final totalAmount = companyAmount + wheelAmount;

//         for (final doc in query.docs) {
//           final updateData = <String, dynamic>{'updatedAt': Timestamp.now()};

//           if (isHoliday) {
//             updateData.addAll({
//               'companyHoliday': companyAmount,
//               'wheelHoliday': wheelAmount,
//             });
//           } else {
//             updateData.addAll({
//               'companyOvernight': companyAmount,
//               'wheelOvernight': wheelAmount,
//             });
//           }

//           updateData['remainingAmount'] = FieldValue.increment(totalAmount);

//           batch.update(doc.reference, updateData);
//         }

//         await batch.commit();
//         print('✅ تم تحديث ${query.docs.length} سجل للسائق');
//       } else {
//         print('⚠️ لم يتم العثور على سجلات سائق مرتبطة');
//       }
//     } catch (e) {
//       print('🚨 خطأ في تحديث سجلات السائقين: $e');
//       rethrow;
//     }
//   }

//   // ====================================================
//   // باقي الدوال الحالية
//   // ====================================================

//   // دالة إظهار خطأ
//   void _showError(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   // دالة إظهار نجاح
//   void _showSuccess(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.green,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }

// // ====================================================
// // Widget جديد للخلية مع زر إضافة
// // ====================================================
// class _TableCellKartaWithAdd extends StatelessWidget {
//   final DailyWork dailyWork;
//   final bool isMobile;
//   final VoidCallback onAddBalance;

//   const _TableCellKartaWithAdd({
//     required this.dailyWork,
//     required this.isMobile,
//     required this.onAddBalance,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: isMobile ? 40 : 48,
//       alignment: Alignment.center,
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // عرض قيمة الكارتة
//           Expanded(
//             child: Text(
//               dailyWork.karta,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFFD35400),
//               ),
//             ),
//           ),

//           // زر الإضافة
//           IconButton(
//             icon: Container(
//               padding: EdgeInsets.all(isMobile ? 3 : 5),
//               decoration: BoxDecoration(
//                 color: Colors.orange.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Icon(
//                 Icons.add,
//                 size: isMobile ? 12 : 14,
//                 color: Colors.orange,
//               ),
//             ),
//             onPressed: onAddBalance,
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//             tooltip: 'إضافة ميزان للكارتة',
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _TableCellBody extends StatelessWidget {
//   final String text;
//   final bool isMobile;
//   final TextStyle? textStyle;

//   const _TableCellBody(this.text, this.isMobile, {this.textStyle});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: isMobile ? 40 : 48,
//       alignment: Alignment.center,
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
//       child: Text(
//         text,
//         maxLines: 2,
//         overflow: TextOverflow.ellipsis,
//         textAlign: TextAlign.center,
//         style: textStyle ?? TextStyle(fontSize: isMobile ? 11 : 14),
//       ),
//     );
//   }
// }

// class _TableCellHeader extends StatelessWidget {
//   final String text;
//   final bool isMobile;

//   const _TableCellHeader(this.text, this.isMobile);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: isMobile ? 42 : 50,
//       alignment: Alignment.center,
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: isMobile ? 11 : 14,
//           color: const Color(0xFF2C3E50),
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
// }

// class _TableCellActionsWithHolidayAndOvernight extends StatelessWidget {
//   final DailyWork dailyWork;
//   final String companyName;
//   final bool isMobile;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//   final VoidCallback onAddHoliday;
//   final VoidCallback onAddOvernight;

//   const _TableCellActionsWithHolidayAndOvernight({
//     required this.dailyWork,
//     required this.companyName,
//     required this.isMobile,
//     required this.onEdit,
//     required this.onDelete,
//     required this.onAddHoliday,
//     required this.onAddOvernight,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: isMobile ? 40 : 48,
//       alignment: Alignment.center,
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           IconButton(
//             icon: Container(
//               padding: EdgeInsets.all(isMobile ? 3 : 5),
//               decoration: BoxDecoration(
//                 color: Colors.orange.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Icon(
//                 Icons.celebration,
//                 size: isMobile ? 12 : 14,
//                 color: Colors.orange,
//               ),
//             ),
//             onPressed: onAddHoliday,
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//             tooltip: 'إضافة عطلة',
//           ),
//           SizedBox(width: isMobile ? 2 : 4),

//           IconButton(
//             icon: Container(
//               padding: EdgeInsets.all(isMobile ? 3 : 5),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Icon(
//                 Icons.hotel,
//                 size: isMobile ? 12 : 14,
//                 color: Colors.blue,
//               ),
//             ),
//             onPressed: onAddOvernight,
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//             tooltip: 'إضافة مبيت',
//           ),
//           SizedBox(width: isMobile ? 2 : 4),

//           IconButton(
//             icon: Container(
//               padding: EdgeInsets.all(isMobile ? 4 : 6),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Icon(
//                 Icons.edit,
//                 size: isMobile ? 14 : 16,
//                 color: Colors.blue,
//               ),
//             ),
//             onPressed: onEdit,
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//           ),
//           SizedBox(width: isMobile ? 2 : 4),

//           IconButton(
//             icon: Container(
//               padding: EdgeInsets.all(isMobile ? 4 : 6),
//               decoration: BoxDecoration(
//                 color: Colors.red.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Icon(
//                 Icons.delete,
//                 size: isMobile ? 14 : 16,
//                 color: Colors.red,
//               ),
//             ),
//             onPressed: onDelete,
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//           ),
//         ],
//       ),
//     );
//   }
// // }
// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:last/models/models.dart';

// class MonthlyRecordPage extends StatefulWidget {
//   const MonthlyRecordPage({super.key});

//   @override
//   State<MonthlyRecordPage> createState() => _MonthlyRecordPageState();
// }

// class _MonthlyRecordPageState extends State<MonthlyRecordPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   String _searchQuery = '';
//   DateTime? _selectedDate;

//   // دالة مساعدة لتحويل البيانات بأمان
//   Map<String, dynamic> _safeConvertDocumentData(Object? data) {
//     if (data == null) {
//       return {};
//     }

//     if (data is Map<String, dynamic>) {
//       return data;
//     }

//     if (data is Map<dynamic, dynamic>) {
//       return data.cast<String, dynamic>();
//     }

//     return {};
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6F8),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           final bool isMobile = constraints.maxWidth < 600;

//           return Column(
//             children: [
//               _buildCustomAppBar(isMobile),
//               _buildFilterSection(isMobile),
//               Expanded(child: _buildCompaniesWithWorkList(isMobile)),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildCustomAppBar(bool isMobile) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: isMobile ? 16 : 24,
//         vertical: isMobile ? 16 : 20,
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
//             Icon(
//               Icons.calendar_month,
//               color: Colors.white,
//               size: isMobile ? 28 : 32,
//             ),
//             SizedBox(width: isMobile ? 8 : 12),
//             Text(
//               'السجل الشهري',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: isMobile ? 20 : 24,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Cairo',
//               ),
//             ),
//             const Spacer(flex: 12),
//             StreamBuilder<DateTime>(
//               stream: Stream.periodic(
//                 const Duration(seconds: 1),
//                 (_) => DateTime.now(),
//               ),
//               builder: (context, snapshot) {
//                 final now = snapshot.data ?? DateTime.now();

//                 // تحويل إلى نظام 12 ساعة
//                 int hour12 = now.hour % 12;
//                 if (hour12 == 0) hour12 = 12; // تحويل 0 إلى 12

//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Container(
//                       height: 50,
//                       width: 150,
//                       decoration: BoxDecoration(
//                         color: Colors.transparent,
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       child: Center(
//                         child: Text(
//                           '${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 36,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterSection(bool isMobile) {
//     return Container(
//       padding: EdgeInsets.all(isMobile ? 12 : 16),
//       color: Colors.white,
//       child: Column(
//         children: [
//           _buildSearchBar(isMobile),
//           SizedBox(height: isMobile ? 12 : 16),
//           _buildDateFilter(isMobile),
//         ],
//       ),
//     );
//   }

//   Widget _buildSearchBar(bool isMobile) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF4F6F8),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFF3498DB)),
//       ),
//       child: Row(
//         children: [
//           Icon(
//             Icons.search,
//             color: const Color(0xFF3498DB),
//             size: isMobile ? 20 : 24,
//           ),
//           SizedBox(width: isMobile ? 8 : 12),
//           Expanded(
//             child: TextField(
//               onChanged: (value) => setState(() => _searchQuery = value),
//               decoration: const InputDecoration(
//                 hintText: 'ابحث عن شركة...',
//                 border: InputBorder.none,
//                 hintStyle: TextStyle(color: Colors.grey),
//               ),
//             ),
//           ),
//           if (_searchQuery.isNotEmpty)
//             GestureDetector(
//               onTap: () => setState(() => _searchQuery = ''),
//               child: Icon(
//                 Icons.clear,
//                 size: isMobile ? 18 : 20,
//                 color: Colors.grey,
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDateFilter(bool isMobile) {
//     return Row(
//       children: [
//         Expanded(
//           child: InkWell(
//             onTap: () => _selectDate(context),
//             child: Container(
//               padding: EdgeInsets.symmetric(
//                 horizontal: isMobile ? 12 : 16,
//                 vertical: isMobile ? 10 : 12,
//               ),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF4F6F8),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: const Color(0xFF3498DB)),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.calendar_today,
//                     color: const Color(0xFF3498DB),
//                     size: isMobile ? 18 : 20,
//                   ),
//                   SizedBox(width: isMobile ? 8 : 12),
//                   Expanded(
//                     child: Text(
//                       _selectedDate != null
//                           ? _formatDate(_selectedDate!)
//                           : 'جميع التواريخ',
//                       style: TextStyle(
//                         fontSize: isMobile ? 13 : 14,
//                         color: _selectedDate != null
//                             ? Colors.black
//                             : Colors.grey,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         SizedBox(width: isMobile ? 8 : 12),
//         if (_selectedDate != null)
//           IconButton(
//             icon: Icon(
//               Icons.clear,
//               color: Colors.red,
//               size: isMobile ? 20 : 24,
//             ),
//             onPressed: () => setState(() => _selectedDate = null),
//           ),
//       ],
//     );
//   }

//   Widget _buildCompaniesWithWorkList(bool isMobile) {
//     return FutureBuilder<List<Map<String, dynamic>>>(
//       future: _getCompaniesWithWork(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.error, size: isMobile ? 48 : 64, color: Colors.red),
//                 SizedBox(height: isMobile ? 12 : 16),
//                 Text(
//                   'خطأ في تحميل البيانات: ${snapshot.error}',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: isMobile ? 14 : 16),
//                 ),
//               ],
//             ),
//           );
//         }

//         final companiesList = snapshot.data ?? [];

//         final filteredCompanies = companiesList
//             .where((company) {
//               if (_searchQuery.isEmpty) return true;
//               final companyName =
//                   company['companyName']?.toString().toLowerCase() ?? '';
//               return companyName.contains(_searchQuery.toLowerCase());
//             })
//             .where((company) {
//               return (company['workCount'] as int) > 0;
//             })
//             .toList();

//         if (filteredCompanies.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.business,
//                   size: isMobile ? 60 : 80,
//                   color: Colors.grey,
//                 ),
//                 SizedBox(height: isMobile ? 12 : 16),
//                 Text(
//                   'لا توجد شركات لديها شغل يومي',
//                   style: TextStyle(
//                     fontSize: isMobile ? 16 : 18,
//                     color: Colors.grey,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: isMobile ? 4 : 8),
//                 Text(
//                   _searchQuery.isEmpty
//                       ? 'أضف شغل يومي جديد للبدء'
//                       : 'لم يتم العثور على نتائج البحث',
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontSize: isMobile ? 12 : 14,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         return ListView.builder(
//           padding: EdgeInsets.all(isMobile ? 12 : 16),
//           itemCount: filteredCompanies.length,
//           itemBuilder: (context, index) {
//             final companyData = filteredCompanies[index];
//             return _buildCompanyItem(
//               companyData['companyId'] as String,
//               companyData,
//               isMobile,
//             );
//           },
//         );
//       },
//     );
//   }

//   Future<List<Map<String, dynamic>>> _getCompaniesWithWork() async {
//     try {
//       final dailyWorksSnapshot = await _firestore
//           .collection('dailyWork')
//           .where(
//             'date',
//             isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(2020)),
//           )
//           .get();

//       final companyData = <String, Map<String, dynamic>>{};

//       for (final work in dailyWorksSnapshot.docs) {
//         final data = _safeConvertDocumentData(work.data());
//         final companyId = data['companyId']?.toString() ?? '';
//         final companyName = data['companyName']?.toString() ?? '';
//         final workDate = (data['date'] as Timestamp?)?.toDate();

//         if (companyId.isEmpty || companyName.isEmpty) continue;

//         if (_selectedDate != null && workDate != null) {
//           final startOfDay = DateTime(
//             _selectedDate!.year,
//             _selectedDate!.month,
//             _selectedDate!.day,
//           );
//           final endOfDay = DateTime(
//             _selectedDate!.year,
//             _selectedDate!.month,
//             _selectedDate!.day,
//             23,
//             59,
//             59,
//           );

//           if (workDate.isBefore(startOfDay) || workDate.isAfter(endOfDay)) {
//             continue;
//           }
//         }

//         if (!companyData.containsKey(companyId)) {
//           companyData[companyId] = {
//             'companyId': companyId,
//             'companyName': companyName,
//             'workCount': 0,
//           };
//         }

//         companyData[companyId]!['workCount'] =
//             (companyData[companyId]!['workCount'] as int) + 1;
//       }

//       return companyData.values.toList();
//     } catch (e) {
//       print('Error getting companies with work: $e');
//       rethrow;
//     }
//   }

//   Widget _buildCompanyItem(
//     String companyId,
//     Map<String, dynamic> data,
//     bool isMobile,
//   ) {
//     final companyName = data['companyName']?.toString() ?? '';
//     final workCount = data['workCount'] as int? ?? 0;

//     return Container(
//       margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFF3498DB).withOpacity(0.3)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         onTap: () => _showCompanyDetails(companyId, companyName, isMobile),
//         leading: Container(
//           width: isMobile ? 45 : 50,
//           height: isMobile ? 45 : 50,
//           decoration: BoxDecoration(
//             color: const Color(0xFF3498DB),
//             borderRadius: BorderRadius.circular(isMobile ? 22.5 : 25),
//           ),
//           child: Center(
//             child: Text(
//               workCount.toString(),
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: isMobile ? 14 : 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//         title: Text(
//           companyName,
//           style: TextStyle(
//             fontSize: isMobile ? 15 : 16,
//             fontWeight: FontWeight.bold,
//             color: const Color(0xFF2C3E50),
//           ),
//         ),
//         subtitle: Text(
//           '$workCount نقلة',
//           style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.grey),
//         ),
//         trailing: Icon(
//           Icons.arrow_forward_ios,
//           color: const Color(0xFF3498DB),
//           size: isMobile ? 14 : 16,
//         ),
//       ),
//     );
//   }

//   // ====================================================
//   // دالة تعديل الشغل اليومي (محدثة مع ملاحظات)
//   // ====================================================
//   void _editDailyWork(DailyWork dailyWork, String companyName, bool isMobile) {
//     // Controllers للحقول
//     final driverNameController = TextEditingController(
//       text: dailyWork.driverName,
//     );
//     final loadingLocationController = TextEditingController(
//       text: dailyWork.loadingLocation,
//     );
//     final unloadingLocationController = TextEditingController(
//       text: dailyWork.unloadingLocation,
//     );
//     final ohdaController = TextEditingController(text: dailyWork.ohda);
//     final kartaController = TextEditingController(text: dailyWork.karta);
//     final trController = TextEditingController(text: dailyWork.tr ?? '');
//     final notesController = TextEditingController(
//       text: dailyWork.selectedNotes ?? '',
//     );

//     // متغيرات لعروض الأسعار
//     List<Map<String, dynamic>> _priceOffers = [];
//     Map<String, dynamic>? _selectedPriceOffer;
//     bool _isDropdownOpen = false;

//     // جلب عروض الأسعار للشركة
//     Future<void> _loadPriceOffers() async {
//       if (dailyWork.companyId.isEmpty) return;

//       try {
//         final snapshot = await _firestore
//             .collection('companies')
//             .doc(dailyWork.companyId)
//             .collection('priceOffers')
//             .get();

//         List<Map<String, dynamic>> allTransportations = [];

//         for (final offerDoc in snapshot.docs) {
//           final offerData = offerDoc.data();
//           final transportations = offerData['transportations'] as List? ?? [];

//           for (final transport in transportations) {
//             final transportMap = transport as Map<String, dynamic>;

//             allTransportations.add({
//               'offerId': offerDoc.id,
//               'loadingLocation': transportMap['loadingLocation'] ?? '',
//               'unloadingLocation': transportMap['unloadingLocation'] ?? '',
//               'vehicleType': transportMap['vehicleType'] ?? '',
//               'nolon': (transportMap['nolon'] ?? transportMap['noLon'] ?? 0.0)
//                   .toDouble(),
//               'wheelNolon':
//                   (transportMap['wheelNolon'] ??
//                           transportMap['wheelNoLon'] ??
//                           0.0)
//                       .toDouble(),
//               'companyOvernight': (transportMap['companyOvernight'] ?? 0.0)
//                   .toDouble(),
//               'companyHoliday': (transportMap['companyHoliday'] ?? 0.0)
//                   .toDouble(),
//               'wheelOvernight': (transportMap['wheelOvernight'] ?? 0.0)
//                   .toDouble(),
//               'wheelHoliday': (transportMap['wheelHoliday'] ?? 0.0).toDouble(),
//               'notes': transportMap['notes'] ?? '',
//             });
//           }
//         }

//         // تحديد عرض السعر الحالي إن وجد
//         if (dailyWork.priceOfferId.isNotEmpty &&
//             allTransportations.isNotEmpty) {
//           for (var offer in allTransportations) {
//             if (offer['offerId'] == dailyWork.priceOfferId) {
//               _selectedPriceOffer = offer;
//               break;
//             }
//           }
//         }
//       } catch (e) {
//         print('خطأ في تحميل عروض الأسعار: $e');
//       }
//     }

//     showDialog(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: StatefulBuilder(
//           builder: (context, setState) {
//             // تحميل عروض الأسعار عند فتح النافذة
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               if (_priceOffers.isEmpty) {
//                 _loadPriceOffers().then((_) {
//                   setState(() {});
//                 });
//               }
//             });

//             return Dialog(
//               backgroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: SingleChildScrollView(
//                 child: Container(
//                   padding: EdgeInsets.all(isMobile ? 16 : 24),
//                   width:
//                       MediaQuery.of(context).size.width *
//                       (isMobile ? 0.95 : 0.9),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // العنوان
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'تعديل النقلة',
//                             style: TextStyle(
//                               fontSize: isMobile ? 18 : 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.close, size: isMobile ? 20 : 24),
//                             onPressed: () => Navigator.pop(context),
//                           ),
//                         ],
//                       ),

//                       SizedBox(height: isMobile ? 4 : 8),
//                       Divider(color: const Color(0xFF3498DB).withOpacity(0.3)),

//                       // معلومات الشركة
//                       Container(
//                         padding: EdgeInsets.all(isMobile ? 10 : 12),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF3498DB).withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.business,
//                               color: const Color(0xFF3498DB),
//                               size: isMobile ? 18 : 20,
//                             ),
//                             SizedBox(width: isMobile ? 6 : 8),
//                             Text(
//                               companyName,
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: const Color(0xFF2C3E50),
//                                 fontSize: isMobile ? 14 : 16,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       SizedBox(height: isMobile ? 16 : 20),

//                       // حقل اسم السائق
//                       _buildEditField(
//                         'اسم السائق',
//                         'أدخل اسم السائق',
//                         driverNameController,
//                         Icons.person,
//                         isMobile,
//                       ),

//                       SizedBox(height: isMobile ? 12 : 16),

//                       // حقل TR
//                       _buildEditField(
//                         'TR',
//                         'أدخل رقم TR',
//                         trController,
//                         Icons.numbers,
//                         isMobile,
//                         isRequired: false,
//                       ),

//                       SizedBox(height: isMobile ? 12 : 16),

//                       // حقل مكان التحميل
//                       _buildEditField(
//                         'مكان التحميل',
//                         'أدخل مكان التحميل',
//                         loadingLocationController,
//                         Icons.location_on,
//                         isMobile,
//                       ),

//                       SizedBox(height: isMobile ? 12 : 16),

//                       // حقل مكان التعتيق
//                       _buildEditField(
//                         'مكان التعتيق',
//                         'أدخل مكان التعتيق',
//                         unloadingLocationController,
//                         Icons.location_on,
//                         isMobile,
//                       ),

//                       SizedBox(height: isMobile ? 12 : 16),

//                       // صف العهدة والكارتة
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _buildEditField(
//                               'العهدة',
//                               'أدخل العهدة',
//                               ohdaController,
//                               Icons.assignment,
//                               isMobile,
//                             ),
//                           ),
//                           SizedBox(width: isMobile ? 8 : 12),
//                           Expanded(
//                             child: _buildEditField(
//                               'الكارتة',
//                               'أدخل الكارتة',
//                               kartaController,
//                               Icons.credit_card,
//                               isMobile,
//                             ),
//                           ),
//                         ],
//                       ),

//                       SizedBox(height: isMobile ? 12 : 16),

//                       // حقل الملاحظات
//                       _buildEditField(
//                         'ملاحظات',
//                         'أدخل ملاحظات إضافية',
//                         notesController,
//                         Icons.note,
//                         isMobile,
//                         isRequired: false,
//                         maxLines: 3,
//                       ),

//                       SizedBox(height: isMobile ? 16 : 20),

//                       // عرض السعر الحالي
//                       if (_selectedPriceOffer != null ||
//                           dailyWork.selectedRoute != null)
//                         Container(
//                           padding: EdgeInsets.all(isMobile ? 10 : 12),
//                           decoration: BoxDecoration(
//                             color: Colors.blue[50],
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(color: Colors.blue),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Icon(
//                                     Icons.attach_money,
//                                     color: Colors.blue[700],
//                                     size: isMobile ? 16 : 18,
//                                   ),
//                                   SizedBox(width: isMobile ? 6 : 8),
//                                   Text(
//                                     'عرض السعر الحالي:',
//                                     style: TextStyle(
//                                       fontSize: isMobile ? 13 : 14,
//                                       fontWeight: FontWeight.bold,
//                                       color: const Color(0xFF2C3E50),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 6),
//                               if (_selectedPriceOffer != null)
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       '${_selectedPriceOffer!['loadingLocation']} → ${_selectedPriceOffer!['unloadingLocation']}',
//                                       style: TextStyle(
//                                         fontSize: isMobile ? 12 : 13,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     SizedBox(height: 4),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           'نولون الشركة:',
//                                           style: TextStyle(
//                                             fontSize: isMobile ? 11 : 12,
//                                             color: Colors.grey[600],
//                                           ),
//                                         ),
//                                         Text(
//                                           '${_selectedPriceOffer!['nolon']} ج',
//                                           style: TextStyle(
//                                             fontSize: isMobile ? 11 : 12,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.blue[700],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Text(
//                                           'نولون العجلات:',
//                                           style: TextStyle(
//                                             fontSize: isMobile ? 11 : 12,
//                                             color: Colors.grey[600],
//                                           ),
//                                         ),
//                                         Text(
//                                           '${_selectedPriceOffer!['wheelNolon']} ج',
//                                           style: TextStyle(
//                                             fontSize: isMobile ? 11 : 12,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.green[700],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 )
//                               else if (dailyWork.selectedRoute != null)
//                                 Text(
//                                   dailyWork.selectedRoute!,
//                                   style: TextStyle(
//                                     fontSize: isMobile ? 12 : 13,
//                                     color: Colors.blue[700],
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),

//                       SizedBox(height: isMobile ? 16 : 20),

//                       // زر لتغيير عرض السعر
//                       Container(
//                         decoration: BoxDecoration(
//                           color: Colors.orange[50],
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.orange),
//                         ),
//                         child: ListTile(
//                           leading: Icon(
//                             Icons.change_circle,
//                             color: Colors.orange[700],
//                           ),
//                           title: Text(
//                             'تغيير عرض السعر',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.orange[700],
//                             ),
//                           ),
//                           trailing: Icon(
//                             Icons.arrow_forward_ios,
//                             size: isMobile ? 16 : 18,
//                             color: Colors.orange[700],
//                           ),
//                           onTap: () {
//                             _showChangePriceOfferDialog(
//                               context,
//                               dailyWork,
//                               companyName,
//                               driverNameController.text,
//                               loadingLocationController.text,
//                               unloadingLocationController.text,
//                               ohdaController.text,
//                               kartaController.text,
//                               trController.text,
//                               notesController.text,
//                               isMobile,
//                             );
//                           },
//                         ),
//                       ),

//                       SizedBox(height: isMobile ? 20 : 24),

//                       // أزرار الحفظ والإلغاء
//                       Row(
//                         children: [
//                           Expanded(
//                             child: OutlinedButton(
//                               onPressed: () => Navigator.pop(context),
//                               style: OutlinedButton.styleFrom(
//                                 padding: EdgeInsets.symmetric(
//                                   vertical: isMobile ? 10 : 12,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                               ),
//                               child: Text(
//                                 'إلغاء',
//                                 style: TextStyle(
//                                   color: const Color(0xFF2C3E50),
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: isMobile ? 14 : 16,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: isMobile ? 8 : 12),
//                           Expanded(
//                             child: ElevatedButton(
//                               onPressed: () async {
//                                 final confirmed = await _showConfirmEditDialog(
//                                   context,
//                                 );
//                                 if (confirmed) {
//                                   await _updateDailyWork(
//                                     dailyWork,
//                                     driverNameController.text,
//                                     loadingLocationController.text,
//                                     unloadingLocationController.text,
//                                     ohdaController.text,
//                                     kartaController.text,
//                                     trController.text,
//                                     notesController.text,
//                                   );
//                                   Navigator.pop(context);
//                                 }
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFF3498DB),
//                                 foregroundColor: Colors.white,
//                                 padding: EdgeInsets.symmetric(
//                                   vertical: isMobile ? 10 : 12,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                               ),
//                               child: Text(
//                                 'حفظ التعديلات',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: isMobile ? 14 : 16,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // ====================================================
//   // نافذة تغيير عرض السعر مع البحث والاقتراحات
//   // ====================================================
//   void _showChangePriceOfferDialog(
//     BuildContext context,
//     DailyWork dailyWork,
//     String companyName,
//     String driverName,
//     String loadingLocation,
//     String unloadingLocation,
//     String ohda,
//     String karta,
//     String tr,
//     String notes,
//     bool isMobile,
//   ) {
//     List<Map<String, dynamic>> _priceOffers = [];
//     Map<String, dynamic>? _selectedPriceOffer;
//     bool _isLoading = true;
//     final TextEditingController _searchController = TextEditingController();

//     // جلب عروض الأسعار
//     Future<void> _loadPriceOffers() async {
//       if (dailyWork.companyId.isEmpty) return;

//       try {
//         final snapshot = await _firestore
//             .collection('companies')
//             .doc(dailyWork.companyId)
//             .collection('priceOffers')
//             .get();

//         List<Map<String, dynamic>> allTransportations = [];

//         for (final offerDoc in snapshot.docs) {
//           final offerData = offerDoc.data();
//           final transportations = offerData['transportations'] as List? ?? [];

//           for (final transport in transportations) {
//             final transportMap = transport as Map<String, dynamic>;

//             allTransportations.add({
//               'offerId': offerDoc.id,
//               'loadingLocation': transportMap['loadingLocation'] ?? '',
//               'unloadingLocation': transportMap['unloadingLocation'] ?? '',
//               'vehicleType': transportMap['vehicleType'] ?? '',
//               'nolon': (transportMap['nolon'] ?? transportMap['noLon'] ?? 0.0)
//                   .toDouble(),
//               'wheelNolon':
//                   (transportMap['wheelNolon'] ??
//                           transportMap['wheelNoLon'] ??
//                           0.0)
//                       .toDouble(),
//               'companyOvernight': (transportMap['companyOvernight'] ?? 0.0)
//                   .toDouble(),
//               'companyHoliday': (transportMap['companyHoliday'] ?? 0.0)
//                   .toDouble(),
//               'wheelOvernight': (transportMap['wheelOvernight'] ?? 0.0)
//                   .toDouble(),
//               'wheelHoliday': (transportMap['wheelHoliday'] ?? 0.0).toDouble(),
//               'notes': transportMap['notes'] ?? '',
//             });
//           }
//         }

//         _priceOffers = allTransportations;
//       } catch (e) {
//         print('خطأ في تحميل عروض الأسعار: $e');
//       } finally {
//         _isLoading = false;
//       }
//     }

//     // تصفية العروض بناءً على البحث
//     List<Map<String, dynamic>> getFilteredOffers() {
//       if (_searchController.text.isEmpty) {
//         return _priceOffers;
//       }

//       final query = _searchController.text.toLowerCase();
//       return _priceOffers.where((offer) {
//         final loading = (offer['loadingLocation'] ?? '').toLowerCase();
//         final unloading = (offer['unloadingLocation'] ?? '').toLowerCase();
//         final vehicleType = (offer['vehicleType'] ?? '').toLowerCase();

//         return loading.contains(query) ||
//             unloading.contains(query) ||
//             vehicleType.contains(query);
//       }).toList();
//     }

//     showDialog(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: StatefulBuilder(
//           builder: (context, setState) {
//             // تحميل العروض عند فتح النافذة
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               if (_priceOffers.isEmpty && _isLoading) {
//                 _loadPriceOffers().then((_) {
//                   setState(() {});
//                 });
//               }
//             });

//             final filteredOffers = getFilteredOffers();

//             return Dialog(
//               backgroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Container(
//                 width: MediaQuery.of(context).size.width * 0.95,
//                 constraints: BoxConstraints(
//                   maxHeight: MediaQuery.of(context).size.height * 0.8,
//                 ),
//                 padding: EdgeInsets.all(isMobile ? 16 : 20),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // العنوان
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'اختر عرض سعر جديد',
//                           style: TextStyle(
//                             fontSize: isMobile ? 18 : 20,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.close, size: isMobile ? 20 : 24),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                       ],
//                     ),

//                     SizedBox(height: isMobile ? 12 : 16),

//                     // شريط البحث
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.grey[50],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.grey),
//                       ),
//                       child: TextField(
//                         controller: _searchController,
//                         onChanged: (value) => setState(() {}),
//                         decoration: InputDecoration(
//                           hintText: 'ابحث بالمحطة أو الوجهة...',
//                           prefixIcon: Icon(Icons.search, color: Colors.orange),
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.symmetric(
//                             horizontal: isMobile ? 12 : 16,
//                           ),
//                         ),
//                       ),
//                     ),

//                     SizedBox(height: isMobile ? 12 : 16),

//                     // قائمة العروض
//                     Expanded(
//                       child: _isLoading
//                           ? Center(child: CircularProgressIndicator())
//                           : filteredOffers.isEmpty
//                           ? Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.search_off,
//                                     size: isMobile ? 48 : 60,
//                                     color: Colors.grey,
//                                   ),
//                                   SizedBox(height: isMobile ? 12 : 16),
//                                   Text(
//                                     'لا توجد عروض مطابقة',
//                                     style: TextStyle(
//                                       fontSize: isMobile ? 14 : 16,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             )
//                           : ListView.builder(
//                               itemCount: filteredOffers.length,
//                               itemBuilder: (context, index) {
//                                 final offer = filteredOffers[index];
//                                 return _buildPriceOfferItem(
//                                   offer,
//                                   isMobile,
//                                   _selectedPriceOffer,
//                                   () {
//                                     setState(() {
//                                       _selectedPriceOffer = offer;
//                                     });
//                                   },
//                                 );
//                               },
//                             ),
//                     ),

//                     SizedBox(height: isMobile ? 16 : 20),

//                     // زر تأكيد
//                     if (_selectedPriceOffer != null)
//                       ElevatedButton(
//                         onPressed: () async {
//                           final confirmed = await _showConfirmChangePriceDialog(
//                             context,
//                             dailyWork,
//                             _selectedPriceOffer!,
//                             isMobile,
//                           );

//                           if (confirmed) {
//                             // تحديث بيانات النقلة مع العرض الجديد
//                             await _updateDailyWorkWithNewPrice(
//                               dailyWork,
//                               driverName,
//                               loadingLocation,
//                               unloadingLocation,
//                               ohda,
//                               karta,
//                               tr,
//                               notes,
//                               _selectedPriceOffer!,
//                             );

//                             Navigator.pop(context); // إغلاق نافذة اختيار العرض
//                             Navigator.pop(context); // إغلاق نافذة التعديل
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.orange,
//                           foregroundColor: Colors.white,
//                           minimumSize: Size(
//                             double.infinity,
//                             isMobile ? 44 : 52,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: Text(
//                           'تأكيد التغيير',
//                           style: TextStyle(
//                             fontSize: isMobile ? 14 : 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildPriceOfferItem(
//     Map<String, dynamic> offer,
//     bool isMobile,
//     Map<String, dynamic>? selectedOffer,
//     VoidCallback onTap,
//   ) {
//     final isSelected =
//         selectedOffer != null && selectedOffer['offerId'] == offer['offerId'];

//     return Container(
//       margin: EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         color: isSelected ? Colors.orange[50] : Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: isSelected ? Colors.orange : Colors.grey,
//           width: isSelected ? 2 : 1,
//         ),
//       ),
//       child: ListTile(
//         leading: Icon(
//           Icons.route,
//           color: isSelected ? Colors.orange : Colors.blue,
//         ),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '${offer['loadingLocation']} → ${offer['unloadingLocation']}',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: isSelected ? Colors.orange[700] : Colors.blue[700],
//               ),
//             ),
//             SizedBox(height: 4),
//             Text(
//               'نوع: ${offer['vehicleType']}',
//               style: TextStyle(
//                 fontSize: isMobile ? 11 : 12,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//         subtitle: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'نولون الشركة: ${offer['nolon']}',
//               style: TextStyle(
//                 fontSize: isMobile ? 11 : 12,
//                 color: Colors.green[700],
//               ),
//             ),
//             Text(
//               'نولون العجلات: ${offer['wheelNolon']}',
//               style: TextStyle(
//                 fontSize: isMobile ? 11 : 12,
//                 color: Colors.red[700],
//               ),
//             ),
//           ],
//         ),
//         trailing: isSelected
//             ? Icon(Icons.check_circle, color: Colors.green)
//             : null,
//         onTap: onTap,
//       ),
//     );
//   }

//   Future<bool> _showConfirmChangePriceDialog(
//     BuildContext context,
//     DailyWork dailyWork,
//     Map<String, dynamic> newPriceOffer,
//     bool isMobile,
//   ) async {
//     return await showDialog<bool>(
//           context: context,
//           builder: (context) => Directionality(
//             textDirection: TextDirection.rtl,
//             child: AlertDialog(
//               title: Row(
//                 children: [
//                   Icon(Icons.warning, color: Colors.orange),
//                   SizedBox(width: 8),
//                   Text('تغيير عرض السعر'),
//                 ],
//               ),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'سيتم تغيير عرض السعر الحالي إلى:',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 12),
//                   Container(
//                     padding: EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.orange[50],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           '${newPriceOffer['loadingLocation']} → ${newPriceOffer['unloadingLocation']}',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.orange[700],
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text('نولون الشركة:'),
//                             Text(
//                               '${newPriceOffer['nolon']} ج',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.green[700],
//                               ),
//                             ),
//                           ],
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text('نولون العجلات:'),
//                             Text(
//                               '${newPriceOffer['wheelNolon']} ج',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.red[700],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     'سيتم تحديث جميع الحقول المرتبطة بما في ذلك:',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 8),
//                   Text('• قيمة النولون للشركة'),
//                   Text('• قيمة النولون للعجلات'),
//                   Text('• جميع سجلات السائقين المرتبطة'),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context, false),
//                   child: Text('إلغاء'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context, true),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                   ),
//                   child: Text('تأكيد التغيير'),
//                 ),
//               ],
//             ),
//           ),
//         ) ??
//         false;
//   }

//   // ====================================================
//   // دالة تحديث النقلة بعرض سعر جديد
//   // ====================================================
//   Future<void> _updateDailyWorkWithNewPrice(
//     DailyWork dailyWork,
//     String driverName,
//     String loadingLocation,
//     String unloadingLocation,
//     String ohda,
//     String karta,
//     String tr,
//     String notes,
//     Map<String, dynamic> priceOffer,
//   ) async {
//     try {
//       final newSelectedRoute = '${priceOffer['unloadingLocation']}';
//       final newPrice = priceOffer['nolon'] ?? 0.0;
//       final newWheelNolon = priceOffer['wheelNolon'] ?? 0.0;
//       final newVehicleType = priceOffer['vehicleType'] ?? '';
//       final newOfferId = priceOffer['offerId'] ?? '';

//       // تحديث dailyWork
//       await _firestore.collection('dailyWork').doc(dailyWork.id).update({
//         'driverName': driverName.trim(),
//         'loadingLocation': loadingLocation.trim(),
//         'unloadingLocation': unloadingLocation.trim(),
//         'ohda': ohda.trim(),
//         'karta': karta.trim(),
//         'tr': tr.trim(),
//         'selectedNotes': notes.trim(),
//         'selectedRoute': newSelectedRoute,
//         'selectedPrice': newPrice,
//         'wheelNolon': newWheelNolon,
//         'selectedVehicleType': newVehicleType,
//         'priceOfferId': newOfferId,
//         'nolon': newPrice,
//         'updatedAt': Timestamp.now(),
//       });

//       // تحديث سجلات السائقين
//       await _updateDriversWithNewPrice(
//         dailyWork,
//         driverName,
//         loadingLocation,
//         unloadingLocation,
//         ohda,
//         karta,
//         tr,
//         notes,
//         newSelectedRoute,
//         newPrice,
//         newWheelNolon,
//         newVehicleType,
//         newOfferId,
//       );

//       _showSuccess('تم تحديث عرض السعر بنجاح');
//     } catch (e) {
//       print('خطأ في تحديث عرض السعر: $e');
//       _showError('خطأ في تحديث عرض السعر: $e');
//     }
//   }

//   // ====================================================
//   // دالة تحديث سجلات السائقين بعرض سعر جديد
//   // ====================================================
//   Future<void> _updateDriversWithNewPrice(
//     DailyWork dailyWork,
//     String driverName,
//     String loadingLocation,
//     String unloadingLocation,
//     String ohda,
//     String karta,
//     String tr,
//     String notes,
//     String selectedRoute,
//     double selectedPrice,
//     double wheelNolon,
//     String vehicleType,
//     String priceOfferId,
//   ) async {
//     try {
//       final query = await _firestore
//           .collection('drivers')
//           .where('dailyWorkId', isEqualTo: dailyWork.id)
//           .limit(10)
//           .get();

//       if (query.docs.isNotEmpty) {
//         final batch = _firestore.batch();

//         for (final doc in query.docs) {
//           batch.update(doc.reference, {
//             'driverName': driverName.trim(),
//             'loadingLocation': loadingLocation.trim(),
//             'unloadingLocation': unloadingLocation.trim(),
//             'ohda': ohda.trim(),
//             'karta': karta.trim(),
//             'tr': tr.trim(),
//             'selectedNotes': notes.trim(),
//             'selectedRoute': selectedRoute,
//             'selectedPrice': selectedPrice,
//             'wheelNolon': wheelNolon,
//             'selectedVehicleType': vehicleType,
//             'priceOfferId': priceOfferId,
//             'nolon': selectedPrice,
//             'remainingAmount': wheelNolon,
//             'updatedAt': Timestamp.now(),
//           });
//         }

//         await batch.commit();
//       }
//     } catch (e) {
//       print('خطأ في تحديث سجلات السائقين: $e');
//       rethrow;
//     }
//   }

//   // ====================================================
//   // دالة تأكيد التعديل
//   // ====================================================
//   Future<bool> _showConfirmEditDialog(BuildContext context) async {
//     return await showDialog<bool>(
//           context: context,
//           builder: (context) => Directionality(
//             textDirection: TextDirection.rtl,
//             child: AlertDialog(
//               title: Row(
//                 children: [
//                   Icon(Icons.info, color: Colors.blue),
//                   SizedBox(width: 8),
//                   Text('تأكيد التعديل'),
//                 ],
//               ),
//               content: Text(
//                 'هل تريد تعديل النقلة؟\n',
//                 textAlign: TextAlign.right,
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context, false),
//                   child: Text('إلغاء'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context, true),
//                   child: Text('تأكيد'),
//                 ),
//               ],
//             ),
//           ),
//         ) ??
//         false;
//   }

//   // ====================================================
//   // دالة لبناء حقل التعديل
//   // ====================================================
//   Widget _buildEditField(
//     String label,
//     String hint,
//     TextEditingController controller,
//     IconData icon,
//     bool isMobile, {
//     bool isRequired = true,
//     int maxLines = 1,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               label,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: const Color(0xFF2C3E50),
//                 fontSize: isMobile ? 13 : 14,
//               ),
//             ),
//             if (!isRequired)
//               Padding(
//                 padding: const EdgeInsets.only(right: 4),
//                 child: Text(
//                   '(اختياري)',
//                   style: TextStyle(
//                     fontSize: isMobile ? 10 : 11,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         SizedBox(height: isMobile ? 4 : 6),
//         TextFormField(
//           controller: controller,
//           maxLines: maxLines,
//           decoration: InputDecoration(
//             hintText: isRequired ? hint : '$hint (اختياري)',
//             prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
//             filled: true,
//             fillColor: const Color(0xFFF4F6F8),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide.none,
//             ),
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: isMobile ? 12 : 16,
//               vertical: isMobile ? 10 : 12,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ====================================================
//   // دالة تحديث الشغل اليومي
//   // ====================================================
//   Future<void> _updateDailyWork(
//     DailyWork dailyWork,
//     String driverName,
//     String loadingLocation,
//     String unloadingLocation,
//     String ohda,
//     String karta,
//     String tr,
//     String notes,
//   ) async {
//     try {
//       // 1. تحديث في collection "dailyWork"
//       await _firestore.collection('dailyWork').doc(dailyWork.id).update({
//         'driverName': driverName.trim(),
//         'loadingLocation': loadingLocation.trim(),
//         'unloadingLocation': unloadingLocation.trim(),
//         'ohda': ohda.trim(),
//         'karta': karta.trim(),
//         'tr': tr.trim(),
//         'selectedNotes': notes.trim(),
//         'updatedAt': Timestamp.now(),
//       });

//       // 2. البحث عن وثائق السائق المرتبطة
//       final driverDocIds = await _findDriverDocumentIds(
//         dailyWork.id!,
//         driverName.trim(),
//         dailyWork.date,
//       );

//       // 3. إذا وجدت وثائق سائق مرتبطة، قم بتحديثها
//       if (driverDocIds.isNotEmpty) {
//         final batch = _firestore.batch();

//         for (final docId in driverDocIds) {
//           final docRef = _firestore.collection('drivers').doc(docId);

//           // تحديث جميع الحقول المرتبطة
//           batch.update(docRef, {
//             'driverName': driverName.trim(),
//             'loadingLocation': loadingLocation.trim(),
//             'unloadingLocation': unloadingLocation.trim(),
//             'ohda': ohda.trim(),
//             'karta': karta.trim(),
//             'tr': tr.trim(),
//             'selectedNotes': notes.trim(),
//             'updatedAt': Timestamp.now(),
//           });
//         }

//         await batch.commit();
//       }

//       // إظهار رسالة نجاح
//       if (mounted) {
//         _showSuccess('تم تعديل النقلة بنجاح');
//       }
//     } catch (e) {
//       print('Error updating daily work: $e');
//       if (mounted) {
//         _showError('خطأ في التعديل: $e');
//       }
//     }
//   }

//   // ====================================================
//   // دالة البحث عن وثائق السائق المرتبطة
//   // ====================================================
//   Future<List<String>> _findDriverDocumentIds(
//     String dailyWorkId,
//     String driverName,
//     DateTime date,
//   ) async {
//     try {
//       // البحث باستخدام dailyWorkId
//       if (dailyWorkId.isNotEmpty) {
//         final queryById = await _firestore
//             .collection('drivers')
//             .where('dailyWorkId', isEqualTo: dailyWorkId)
//             .get();

//         if (queryById.docs.isNotEmpty) {
//           return queryById.docs.map((doc) => doc.id).toList();
//         }
//       }

//       // البحث باستخدام اسم السائق والتاريخ
//       final startOfDay = DateTime(date.year, date.month, date.day);
//       final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

//       final queryByDriver = await _firestore
//           .collection('drivers')
//           .where('driverName', isEqualTo: driverName)
//           .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
//           .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
//           .get();

//       return queryByDriver.docs.map((doc) => doc.id).toList();
//     } catch (e) {
//       print('خطأ في البحث عن وثائق السائق: $e');
//       return [];
//     }
//   }

//   // ====================================================
//   // دالة حذف الشغل اليومي
//   // ====================================================
//   void _deleteDailyWork(DailyWork dailyWork, bool isMobile) {
//     showDialog(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           title: Row(
//             children: [
//               Icon(
//                 Icons.warning,
//                 color: Colors.orange,
//                 size: isMobile ? 20 : 24,
//               ),
//               SizedBox(width: isMobile ? 6 : 8),
//               Text(
//                 'تأكيد الحذف',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: const Color(0xFF2C3E50),
//                   fontSize: isMobile ? 16 : 18,
//                 ),
//               ),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'هل أنت متأكد من حذف هذه النقلة؟',
//                 style: TextStyle(fontSize: isMobile ? 14 : 16),
//               ),
//               SizedBox(height: isMobile ? 6 : 8),
//               Text(
//                 'السائق: ${dailyWork.driverName}',
//                 style: const TextStyle(color: Colors.grey),
//               ),
//               Text(
//                 'المسار: ${dailyWork.loadingLocation} → ${dailyWork.unloadingLocation}',
//                 style: const TextStyle(color: Colors.grey),
//               ),
//               if (dailyWork.selectedRoute != null)
//                 Text(
//                   'اسم الموقع: ${dailyWork.selectedRoute}',
//                   style: TextStyle(
//                     color: Colors.blue[700],
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               if (dailyWork.tr.isNotEmpty ?? false)
//                 Text(
//                   'TR: ${dailyWork.tr}',
//                   style: TextStyle(
//                     color: Colors.green[700],
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               if (dailyWork.selectedNotes != null &&
//                   dailyWork.selectedNotes!.isNotEmpty)
//                 Text(
//                   'ملاحظات: ${dailyWork.selectedNotes}',
//                   style: TextStyle(
//                     color: Colors.purple[700],
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               SizedBox(height: isMobile ? 12 : 16),
//               Text(
//                 '⚠️ لا يمكن التراجع عن هذا الإجراء',
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontSize: isMobile ? 10 : 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text(
//                 'إلغاء',
//                 style: TextStyle(
//                   color: const Color(0xFF2C3E50),
//                   fontSize: isMobile ? 14 : 16,
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 _confirmDeleteDailyWork(dailyWork);
//                 Navigator.pop(context);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//               ),
//               child: Text(
//                 'حذف',
//                 style: TextStyle(fontSize: isMobile ? 14 : 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ====================================================
//   // دالة تأكيد الحذف
//   // ====================================================
//   Future<void> _confirmDeleteDailyWork(DailyWork dailyWork) async {
//     try {
//       await _firestore.collection('dailyWork').doc(dailyWork.id).delete();

//       // إظهار رسالة نجاح
//       if (mounted) {
//         _showSuccess('تم حذف النقلة بنجاح');
//       }
//     } catch (e) {
//       print('Error deleting daily work: $e');
//       if (mounted) {
//         _showError('خطأ في الحذف: $e');
//       }
//     }
//   }

//   void _showCompanyDetails(
//     String companyId,
//     String companyName,
//     bool isMobile,
//   ) {
//     showDialog(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: Dialog(
//           backgroundColor: Colors.transparent,
//           insetPadding: EdgeInsets.all(isMobile ? 8 : 16),
//           child: Container(
//             width: MediaQuery.of(context).size.width * (isMobile ? 0.98 : 0.95),
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.9,
//             ),
//             padding: EdgeInsets.all(isMobile ? 16 : 20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.15),
//                   blurRadius: 20,
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // العنوان
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.close, size: isMobile ? 20 : 24),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                     Text(
//                       'نقلات $companyName',
//                       style: TextStyle(
//                         fontSize: isMobile ? 18 : 20,
//                         fontWeight: FontWeight.bold,
//                         color: const Color(0xFF2C3E50),
//                       ),
//                     ),
//                     SizedBox(width: isMobile ? 40 : 48),
//                   ],
//                 ),

//                 SizedBox(height: isMobile ? 4 : 8),
//                 Divider(color: const Color(0xFF3498DB).withOpacity(0.3)),

//                 // معلومات الشركة والفلتر
//                 Container(
//                   padding: EdgeInsets.all(isMobile ? 10 : 12),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF3498DB).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       Column(
//                         children: [
//                           Text(
//                             'اسم الشركة',
//                             style: TextStyle(
//                               fontSize: isMobile ? 10 : 11,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           Text(
//                             companyName,
//                             style: TextStyle(
//                               fontSize: isMobile ? 14 : 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           Text(
//                             'فلتر التاريخ',
//                             style: TextStyle(
//                               fontSize: isMobile ? 10 : 11,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           InkWell(
//                             onTap: () => _selectDateForDetails(context),
//                             child: Container(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: isMobile ? 10 : 12,
//                                 vertical: isMobile ? 5 : 6,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(6),
//                                 border: Border.all(
//                                   color: const Color(0xFF3498DB),
//                                 ),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Icon(
//                                     Icons.calendar_today,
//                                     size: isMobile ? 14 : 16,
//                                     color: const Color(0xFF3498DB),
//                                   ),
//                                   SizedBox(width: isMobile ? 4 : 6),
//                                   Text(
//                                     _selectedDate != null
//                                         ? _formatDate(_selectedDate!)
//                                         : 'جميع التواريخ',
//                                     style: TextStyle(
//                                       fontSize: isMobile ? 11 : 12,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 SizedBox(height: isMobile ? 12 : 16),
//                 Expanded(
//                   child: _buildCompanyWorkTable(
//                     companyId,
//                     companyName,
//                     isMobile,
//                   ),
//                 ),
//                 SizedBox(height: isMobile ? 12 : 16),

//                 // زر الإغلاق
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF3498DB),
//                     foregroundColor: Colors.white,
//                     elevation: 2,
//                     padding: EdgeInsets.symmetric(
//                       horizontal: isMobile ? 30 : 40,
//                       vertical: isMobile ? 10 : 12,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: Text(
//                     'إغلاق',
//                     style: TextStyle(fontSize: isMobile ? 14 : 16),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _selectDateForDetails(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   Widget _buildCompanyWorkTable(
//     String companyId,
//     String companyName,
//     bool isMobile,
//   ) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _getCompanyDailyWorkStream(companyId),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.error, size: isMobile ? 40 : 48, color: Colors.red),
//                 SizedBox(height: isMobile ? 6 : 8),
//                 Text(
//                   'خطأ في تحميل البيانات: ${snapshot.error}',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: isMobile ? 12 : 14,
//                     color: Colors.red,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         final dailyWorks = _convertSnapshotToDailyWorkList(snapshot.data);

//         if (dailyWorks.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   Icons.work_outline,
//                   size: isMobile ? 50 : 64,
//                   color: Colors.grey,
//                 ),
//                 SizedBox(height: isMobile ? 12 : 16),
//                 Text(
//                   'لا توجد نقلات',
//                   style: TextStyle(
//                     fontSize: isMobile ? 14 : 16,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }

//         return Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: Colors.transparent, width: 1.5),
//           ),
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.vertical,
//               child: Table(
//                 defaultColumnWidth: FixedColumnWidth(isMobile ? 110 : 130),
//                 border: TableBorder.all(
//                   color: const Color(0xFF3498DB),
//                   width: 1,
//                 ),
//                 children: [
//                   TableRow(
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF3498DB).withOpacity(0.15),
//                     ),
//                     children: [
//                       _TableCellHeader('م', isMobile),
//                       _TableCellHeader('التاريخ', isMobile),
//                       _TableCellHeader('اسم السائق', isMobile),
//                       _TableCellHeader('مكان التحميل', isMobile),
//                       _TableCellHeader('مكان التعتيق', isMobile),
//                       _TableCellHeader('مطابقه نولون', isMobile),
//                       _TableCellHeader('TR', isMobile),
//                       _TableCellHeader('العهدة', isMobile),
//                       _TableCellHeader('الكارتة', isMobile),
//                       _TableCellHeader(
//                         'ملاحظات',
//                         isMobile,
//                       ), // عمود جديد للملاحظات
//                       _TableCellHeader('الإجراءات', isMobile),
//                     ],
//                   ),
//                   ...dailyWorks.asMap().entries.map((entry) {
//                     final index = entry.key;
//                     final dailyWork = entry.value;

//                     return TableRow(
//                       decoration: BoxDecoration(
//                         color: index.isEven
//                             ? Colors.white
//                             : const Color(0xFFF8F9FA),
//                       ),
//                       children: [
//                         _TableCellBody('${index + 1}', isMobile),
//                         _TableCellBody(_formatDate(dailyWork.date), isMobile),
//                         _TableCellBody(dailyWork.driverName, isMobile),
//                         _TableCellBody(dailyWork.loadingLocation, isMobile),
//                         _TableCellBody(dailyWork.unloadingLocation, isMobile),
//                         _TableCellBody(
//                           dailyWork.selectedRoute,
//                           isMobile,
//                           textStyle: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue[700],
//                           ),
//                         ),
//                         _TableCellBody(
//                           dailyWork.tr ?? '',
//                           isMobile,
//                           textStyle: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.green[700],
//                           ),
//                         ),
//                         _TableCellBody(
//                           dailyWork.ohda,
//                           isMobile,
//                           textStyle: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF2E7D32),
//                           ),
//                         ),
//                         _TableCellKartaWithAdd(
//                           dailyWork: dailyWork,
//                           isMobile: isMobile,
//                           onAddBalance: () =>
//                               _showAddBalanceDialog(dailyWork, isMobile),
//                         ),
//                         _TableCellBody(
//                           // خلية الملاحظات الجديدة
//                           dailyWork.selectedNotes ?? '',
//                           isMobile,
//                           textStyle: TextStyle(color: Colors.purple[700]),
//                         ),
//                         _TableCellActionsWithHolidayAndOvernight(
//                           dailyWork: dailyWork,
//                           companyName: companyName,
//                           isMobile: isMobile,
//                           onEdit: () =>
//                               _editDailyWork(dailyWork, companyName, isMobile),
//                           onDelete: () => _deleteDailyWork(dailyWork, isMobile),
//                           onAddHoliday: () =>
//                               _addHoliday(dailyWork, companyName, isMobile),
//                           onAddOvernight: () =>
//                               _addOvernight(dailyWork, companyName, isMobile),
//                         ),
//                       ],
//                     );
//                   }),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // ====================================================
//   // دالة إضافة ميزان الشركات للكارتة
//   // ====================================================
//   void _showAddBalanceDialog(DailyWork dailyWork, bool isMobile) {
//     final balanceController = TextEditingController();
//     final currentKarta = double.tryParse(dailyWork.karta) ?? 0.0;
//     bool showNewTotal = false;
//     double newTotal = currentKarta;

//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Directionality(
//               textDirection: TextDirection.rtl,
//               child: AlertDialog(
//                 backgroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 title: Row(
//                   children: [
//                     Icon(
//                       Icons.add_circle,
//                       color: Colors.orange[700],
//                       size: isMobile ? 24 : 28,
//                     ),
//                     SizedBox(width: isMobile ? 8 : 12),
//                     Text(
//                       'إضافة ميزان الشركه',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: isMobile ? 16 : 18,
//                         color: const Color(0xFF2C3E50),
//                       ),
//                     ),
//                   ],
//                 ),
//                 content: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // عرض الكارتة الحالية
//                     Container(
//                       padding: EdgeInsets.all(isMobile ? 10 : 12),
//                       decoration: BoxDecoration(
//                         color: Colors.orange[50],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.orange),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'قيمة الكارتة الحالية:',
//                             style: TextStyle(
//                               fontSize: isMobile ? 12 : 14,
//                               color: Colors.orange[800],
//                             ),
//                           ),
//                           Text(
//                             '$currentKarta ج',
//                             style: TextStyle(
//                               fontSize: isMobile ? 14 : 16,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.orange[800],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: isMobile ? 16 : 20),

//                     // حقل إدخال الميزان
//                     Text(
//                       'قيمة الميزان الإضافية:',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: isMobile ? 13 : 14,
//                         color: const Color(0xFF2C3E50),
//                       ),
//                     ),
//                     SizedBox(height: isMobile ? 6 : 8),
//                     TextFormField(
//                       controller: balanceController,
//                       keyboardType: TextInputType.number,
//                       onChanged: (value) {
//                         final balanceValue = double.tryParse(value) ?? 0.0;
//                         newTotal = currentKarta + balanceValue;
//                         setState(() {
//                           showNewTotal = value.isNotEmpty && balanceValue > 0;
//                         });
//                       },
//                       decoration: InputDecoration(
//                         hintText: 'أدخل قيمة الميزان',
//                         prefixIcon: Icon(
//                           Icons.attach_money,
//                           color: Colors.orange[700],
//                         ),
//                         filled: true,
//                         fillColor: const Color(0xFFF4F6F8),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide.none,
//                         ),
//                         contentPadding: EdgeInsets.symmetric(
//                           horizontal: isMobile ? 12 : 16,
//                           vertical: isMobile ? 12 : 16,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: isMobile ? 8 : 12),

//                     // عرض القيمة الجديدة
//                     if (showNewTotal)
//                       Container(
//                         padding: EdgeInsets.all(isMobile ? 10 : 12),
//                         decoration: BoxDecoration(
//                           color: Colors.green[50],
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.green),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'القيمة الإجمالية الجديدة:',
//                               style: TextStyle(
//                                 fontSize: isMobile ? 12 : 14,
//                                 color: Colors.green[800],
//                               ),
//                             ),
//                             Text(
//                               '$newTotal ج',
//                               style: TextStyle(
//                                 fontSize: isMobile ? 14 : 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.green[800],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text(
//                       'إلغاء',
//                       style: TextStyle(fontSize: isMobile ? 14 : 16),
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: () async {
//                       if (balanceController.text.isEmpty) {
//                         _showError('يرجى إدخال قيمة الميزان');
//                         return;
//                       }

//                       final balanceValue =
//                           double.tryParse(balanceController.text) ?? 0.0;
//                       if (balanceValue <= 0) {
//                         _showError('القيمة يجب أن تكون أكبر من صفر');
//                         return;
//                       }

//                       await _updateKartaWithBalance(dailyWork, balanceValue);
//                       Navigator.pop(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.orange,
//                       foregroundColor: Colors.white,
//                     ),
//                     child: Text(
//                       'حفظ',
//                       style: TextStyle(fontSize: isMobile ? 14 : 16),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   // ====================================================
//   // دالة تحديث الكارتة بالميزان
//   // ====================================================
//   Future<void> _updateKartaWithBalance(
//     DailyWork dailyWork,
//     double balanceValue,
//   ) async {
//     try {
//       final currentKarta = double.tryParse(dailyWork.karta) ?? 0.0;
//       final newKarta = currentKarta + balanceValue;
//       final kartaString = newKarta.toStringAsFixed(2);

//       // 1. تحديث في collection "dailyWork"
//       await _firestore.collection('dailyWork').doc(dailyWork.id).update({
//         'karta': kartaString,
//         'companyBalance': FieldValue.increment(balanceValue),
//         'updatedAt': Timestamp.now(),
//       });

//       // 2. تحديث سجلات السائقين المرتبطة
//       final driverDocIds = await _findDriverDocumentIds(
//         dailyWork.id!,
//         dailyWork.driverName,
//         dailyWork.date,
//       );

//       if (driverDocIds.isNotEmpty) {
//         final batch = _firestore.batch();

//         for (final docId in driverDocIds) {
//           final docRef = _firestore.collection('drivers').doc(docId);
//           batch.update(docRef, {
//             'karta': kartaString,
//             'companyBalance': FieldValue.increment(balanceValue),
//             'updatedAt': Timestamp.now(),
//           });
//         }

//         await batch.commit();
//       }

//       // إظهار رسالة نجاح
//       if (mounted) {
//         _showSuccess(
//           'تم إضافة ميزان بقيمة $balanceValue ج\nالقيمة الجديدة للكارتة: $kartaString ج',
//         );
//       }
//     } catch (e) {
//       print('خطأ في تحديث الكارتة: $e');
//       if (mounted) {
//         _showError('خطأ في إضافة الميزان: $e');
//       }
//     }
//   }

//   // دالة لإنشاء Stream للبيانات
//   Stream<QuerySnapshot> _getCompanyDailyWorkStream(String companyId) {
//     Query query = _firestore
//         .collection('dailyWork')
//         .where('companyId', isEqualTo: companyId);

//     if (_selectedDate != null) {
//       final startOfDay = DateTime(
//         _selectedDate!.year,
//         _selectedDate!.month,
//         _selectedDate!.day,
//       );
//       final endOfDay = DateTime(
//         _selectedDate!.year,
//         _selectedDate!.month,
//         _selectedDate!.day,
//         23,
//         59,
//         59,
//       );

//       query = query
//           .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
//           .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));
//     }

//     return query.snapshots();
//   }

//   // دالة لتحويل الـ Snapshot إلى قائمة DailyWork
//   List<DailyWork> _convertSnapshotToDailyWorkList(QuerySnapshot? snapshot) {
//     if (snapshot == null) return [];

//     final dailyWorks = snapshot.docs.map((doc) {
//       final data = _safeConvertDocumentData(doc.data());
//       return DailyWork.fromMap(data, doc.id);
//     }).toList();

//     dailyWorks.sort((a, b) => b.date.compareTo(a.date));
//     return dailyWorks;
//   }

//   // ====================================================
//   // الدوال الجديدة لإضافة العطلة والمبيت
//   // ====================================================

//   // دالة لجلب بيانات عرض السعر للشركة باستخدام priceOfferId
//   Future<Map<String, dynamic>?> _getPriceOfferData(
//     String companyId,
//     String priceOfferId,
//   ) async {
//     try {
//       if (companyId.isEmpty || priceOfferId.isEmpty) {
//         return null;
//       }

//       final snapshot = await _firestore
//           .collection('companies')
//           .doc(companyId)
//           .collection('priceOffers')
//           .doc(priceOfferId)
//           .get();

//       if (snapshot.exists) {
//         return snapshot.data();
//       } else {
//         return null;
//       }
//     } catch (e) {
//       print('🚨 خطأ في جلب بيانات عرض السعر: $e');
//       return null;
//     }
//   }

//   // دالة إضافة عطلة
//   void _addHoliday(DailyWork dailyWork, String companyName, bool isMobile) {
//     _addHolidayOrOvernight(dailyWork, companyName, isMobile, true);
//   }

//   // دالة إضافة مبيت
//   void _addOvernight(DailyWork dailyWork, String companyName, bool isMobile) {
//     _addHolidayOrOvernight(dailyWork, companyName, isMobile, false);
//   }

//   // دالة مشتركة لإضافة عطلة أو مبيت
//   void _addHolidayOrOvernight(
//     DailyWork dailyWork,
//     String companyName,
//     bool isMobile,
//     bool isHoliday,
//   ) async {
//     try {
//       if (dailyWork.priceOfferId.isEmpty) {
//         _showError('❌ لا يوجد عرض سعر مرتبط بهذه النقلة');
//         return;
//       }

//       final priceOfferData = await _getPriceOfferData(
//         dailyWork.companyId,
//         dailyWork.priceOfferId,
//       );

//       if (priceOfferData == null) {
//         _showError('❌ عرض السعر غير موجود');
//         return;
//       }

//       final transportations = priceOfferData['transportations'] as List? ?? [];

//       if (transportations.isEmpty) {
//         _showError('❌ لا توجد نقلات في عرض السعر');
//         return;
//       }

//       Map<String, dynamic>? selectedTransportation;

//       for (final transport in transportations) {
//         final transportMap = transport as Map<String, dynamic>;
//         final unloadingLocation =
//             transportMap['unloadingLocation']?.toString() ?? '';
//         final selectedRoute = dailyWork.selectedRoute.toString() ?? '';

//         if (unloadingLocation == selectedRoute) {
//           selectedTransportation = transportMap;
//           break;
//         }
//       }

//       if (selectedTransportation == null) {
//         selectedTransportation = transportations.first as Map<String, dynamic>;
//       }

//       double companyAmount = 0.0;
//       double wheelAmount = 0.0;

//       if (isHoliday) {
//         companyAmount = _extractValue(selectedTransportation, [
//           'companyHoliday',
//           'company_holiday',
//           'holiday_company',
//           'companyHolidayPrice',
//         ]);

//         wheelAmount = _extractValue(selectedTransportation, [
//           'wheelHoliday',
//           'wheel_holiday',
//           'holiday_wheel',
//           'wheelHolidayPrice',
//         ]);
//       } else {
//         companyAmount = _extractValue(selectedTransportation, [
//           'companyOvernight',
//           'company_overnight',
//           'overnight_company',
//           'companyOvernightPrice',
//         ]);

//         wheelAmount = _extractValue(selectedTransportation, [
//           'wheelOvernight',
//           'wheel_overnight',
//           'overnight_wheel',
//           'wheelOvernightPrice',
//         ]);
//       }

//       final confirmed = await _showSimpleConfirmation(
//         context,
//         isHoliday,
//         companyAmount,
//         wheelAmount,
//         isMobile,
//       );

//       if (confirmed != null && confirmed) {
//         await _updateHolidayOrOvernight(
//           dailyWork,
//           isHoliday,
//           companyAmount,
//           wheelAmount,
//         );
//       }
//     } catch (e) {
//       print('🚨 خطأ في إضافة العطلة/المبيت: $e');
//       _showError('❌ خطأ في إضافة العطلة/المبيت: ${e.toString()}');
//     }
//   }

//   // دالة مساعدة لاستخراج قيمة
//   double _extractValue(Map<String, dynamic> data, List<String> keys) {
//     for (final key in keys) {
//       final value = data[key];
//       if (value != null) {
//         if (value is int) return value.toDouble();
//         if (value is double) return value;
//         if (value is String) {
//           final parsed = double.tryParse(value);
//           if (parsed != null) return parsed;
//         }
//       }
//     }
//     return 0.0;
//   }

//   // دالة تأكيد بسيطة
//   Future<bool?> _showSimpleConfirmation(
//     BuildContext context,
//     bool isHoliday,
//     double companyAmount,
//     double wheelAmount,
//     bool isMobile,
//   ) {
//     return showDialog<bool>(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           title: Row(
//             children: [
//               Icon(
//                 isHoliday ? Icons.celebration : Icons.hotel,
//                 color: isHoliday ? Colors.orange : Colors.blue,
//                 size: isMobile ? 24 : 28,
//               ),
//               SizedBox(width: isMobile ? 8 : 12),
//               Text(
//                 isHoliday ? 'إضافة عطلة' : 'إضافة مبيت',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: isMobile ? 16 : 18,
//                   color: const Color(0xFF2C3E50),
//                 ),
//               ),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 isHoliday ? 'سيتم إضافة عطلة بقيمة:' : 'سيتم إضافة مبيت بقيمة:',
//                 style: TextStyle(fontSize: isMobile ? 14 : 16),
//               ),
//               SizedBox(height: isMobile ? 8 : 12),
//               _buildAmountItem(
//                 isHoliday ? 'عطلة الشركة' : 'مبيت الشركة',
//                 companyAmount,
//                 isHoliday ? Colors.orange : Colors.blue,
//                 isMobile,
//               ),
//               SizedBox(height: 6),
//               _buildAmountItem(
//                 isHoliday ? 'عطلة العجلات' : 'مبيت العجلات',
//                 wheelAmount,
//                 isHoliday ? Colors.orange[700]! : Colors.blue[700]!,
//                 isMobile,
//               ),
//               SizedBox(height: isMobile ? 8 : 12),
//               Divider(color: Colors.grey[300]),
//               SizedBox(height: isMobile ? 8 : 12),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context, false),
//               child: Text(
//                 'إلغاء',
//                 style: TextStyle(fontSize: isMobile ? 14 : 16),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () => Navigator.pop(context, true),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: isHoliday ? Colors.orange : Colors.blue,
//                 foregroundColor: Colors.white,
//               ),
//               child: Text(
//                 'تأكيد',
//                 style: TextStyle(fontSize: isMobile ? 14 : 16),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // دالة لعرض عنصر المبلغ
//   Widget _buildAmountItem(
//     String label,
//     double amount,
//     Color color,
//     bool isMobile,
//   ) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(fontSize: isMobile ? 13 : 14, color: color),
//         ),
//         Text(
//           '$amount ج',
//           style: TextStyle(
//             fontSize: isMobile ? 13 : 14,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }

//   // دالة تحديث العطلة أو المبيت
//   Future<void> _updateHolidayOrOvernight(
//     DailyWork dailyWork,
//     bool isHoliday,
//     double companyAmount,
//     double wheelAmount,
//   ) async {
//     try {
//       final updateData = <String, dynamic>{'updatedAt': Timestamp.now()};

//       if (isHoliday) {
//         updateData.addAll({
//           'companyHoliday': companyAmount,
//           'wheelHoliday': wheelAmount,
//         });
//       } else {
//         updateData.addAll({
//           'companyOvernight': companyAmount,
//           'wheelOvernight': wheelAmount,
//         });
//       }

//       await _firestore
//           .collection('dailyWork')
//           .doc(dailyWork.id)
//           .update(updateData);

//       await _updateDriversCollection(
//         dailyWork,
//         isHoliday,
//         companyAmount,
//         wheelAmount,
//       );

//       _showSuccess(
//         isHoliday ? '✅ تم إضافة العطلة بنجاح' : '✅ تم إضافة المبيت بنجاح',
//       );
//     } catch (e) {
//       print('🚨 خطأ في تحديث Firestore: $e');
//       _showError('❌ خطأ في تحديث البيانات: ${e.toString()}');
//     }
//   }

//   // دالة تحديث drivers collection
//   Future<void> _updateDriversCollection(
//     DailyWork dailyWork,
//     bool isHoliday,
//     double companyAmount,
//     double wheelAmount,
//   ) async {
//     try {
//       final query = await _firestore
//           .collection('drivers')
//           .where('dailyWorkId', isEqualTo: dailyWork.id)
//           .limit(10)
//           .get();

//       if (query.docs.isNotEmpty) {
//         final batch = _firestore.batch();
//         final totalAmount = companyAmount + wheelAmount;

//         for (final doc in query.docs) {
//           final updateData = <String, dynamic>{'updatedAt': Timestamp.now()};

//           if (isHoliday) {
//             updateData.addAll({
//               'companyHoliday': companyAmount,
//               'wheelHoliday': wheelAmount,
//             });
//           } else {
//             updateData.addAll({
//               'companyOvernight': companyAmount,
//               'wheelOvernight': wheelAmount,
//             });
//           }

//           updateData['remainingAmount'] = FieldValue.increment(totalAmount);

//           batch.update(doc.reference, updateData);
//         }

//         await batch.commit();
//       }
//     } catch (e) {
//       print('🚨 خطأ في تحديث سجلات السائقين: $e');
//       rethrow;
//     }
//   }

//   // ====================================================
//   // باقي الدوال الحالية
//   // ====================================================

//   // دالة إظهار خطأ
//   void _showError(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   // دالة إظهار نجاح
//   void _showSuccess(String message) {
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: Colors.green,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//     );
//     if (picked != null) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }

// // ====================================================
// // Widget جديد للخلية مع زر إضافة
// // ====================================================
// class _TableCellKartaWithAdd extends StatelessWidget {
//   final DailyWork dailyWork;
//   final bool isMobile;
//   final VoidCallback onAddBalance;

//   const _TableCellKartaWithAdd({
//     required this.dailyWork,
//     required this.isMobile,
//     required this.onAddBalance,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: isMobile ? 40 : 48,
//       alignment: Alignment.center,
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // عرض قيمة الكارتة
//           Expanded(
//             child: Text(
//               dailyWork.karta,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFFD35400),
//               ),
//             ),
//           ),

//           // زر الإضافة
//           IconButton(
//             icon: Container(
//               padding: EdgeInsets.all(isMobile ? 3 : 5),
//               decoration: BoxDecoration(
//                 color: Colors.orange.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Icon(
//                 Icons.add,
//                 size: isMobile ? 12 : 14,
//                 color: Colors.orange,
//               ),
//             ),
//             onPressed: onAddBalance,
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//             tooltip: 'إضافة ميزان للكارتة',
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _TableCellBody extends StatelessWidget {
//   final String text;
//   final bool isMobile;
//   final TextStyle? textStyle;

//   const _TableCellBody(this.text, this.isMobile, {this.textStyle});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: isMobile ? 40 : 48,
//       alignment: Alignment.center,
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
//       child: Text(
//         text,
//         maxLines: 2,
//         overflow: TextOverflow.ellipsis,
//         textAlign: TextAlign.center,
//         style: textStyle ?? TextStyle(fontSize: isMobile ? 11 : 14),
//       ),
//     );
//   }
// }

// class _TableCellHeader extends StatelessWidget {
//   final String text;
//   final bool isMobile;

//   const _TableCellHeader(this.text, this.isMobile);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: isMobile ? 42 : 50,
//       alignment: Alignment.center,
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: isMobile ? 11 : 14,
//           color: const Color(0xFF2C3E50),
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
// }

// class _TableCellActionsWithHolidayAndOvernight extends StatelessWidget {
//   final DailyWork dailyWork;
//   final String companyName;
//   final bool isMobile;
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;
//   final VoidCallback onAddHoliday;
//   final VoidCallback onAddOvernight;

//   const _TableCellActionsWithHolidayAndOvernight({
//     required this.dailyWork,
//     required this.companyName,
//     required this.isMobile,
//     required this.onEdit,
//     required this.onDelete,
//     required this.onAddHoliday,
//     required this.onAddOvernight,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: isMobile ? 40 : 48,
//       alignment: Alignment.center,
//       padding: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           IconButton(
//             icon: Container(
//               padding: EdgeInsets.all(isMobile ? 3 : 5),
//               decoration: BoxDecoration(
//                 color: Colors.orange.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Icon(
//                 Icons.celebration,
//                 size: isMobile ? 12 : 14,
//                 color: Colors.orange,
//               ),
//             ),
//             onPressed: onAddHoliday,
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//             tooltip: 'إضافة عطلة',
//           ),
//           SizedBox(width: isMobile ? 2 : 4),

//           IconButton(
//             icon: Container(
//               padding: EdgeInsets.all(isMobile ? 3 : 5),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Icon(
//                 Icons.hotel,
//                 size: isMobile ? 12 : 14,
//                 color: Colors.blue,
//               ),
//             ),
//             onPressed: onAddOvernight,
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//             tooltip: 'إضافة مبيت',
//           ),
//           SizedBox(width: isMobile ? 2 : 4),

//           IconButton(
//             icon: Container(
//               padding: EdgeInsets.all(isMobile ? 4 : 6),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Icon(
//                 Icons.edit,
//                 size: isMobile ? 14 : 16,
//                 color: Colors.blue,
//               ),
//             ),
//             onPressed: onEdit,
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//           ),
//           SizedBox(width: isMobile ? 2 : 4),

//           IconButton(
//             icon: Container(
//               padding: EdgeInsets.all(isMobile ? 4 : 6),
//               decoration: BoxDecoration(
//                 color: Colors.red.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Icon(
//                 Icons.delete,
//                 size: isMobile ? 14 : 16,
//                 color: Colors.red,
//               ),
//             ),
//             onPressed: onDelete,
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:last/models/models.dart';

class MonthlyRecordPage extends StatefulWidget {
  const MonthlyRecordPage({super.key});

  @override
  State<MonthlyRecordPage> createState() => _MonthlyRecordPageState();
}

class _MonthlyRecordPageState extends State<MonthlyRecordPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  DateTime? _selectedDate;

  // متغيرات للتحكم في الـ Stream
  StreamSubscription<QuerySnapshot>? _companyWorkStreamSubscription;
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _companyWorkStreamSubscription?.cancel();
    super.dispose();
  }

  // دالة مساعدة لتحويل البيانات بأمان
  Map<String, dynamic> _safeConvertDocumentData(Object? data) {
    if (data == null) {
      return {};
    }

    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map<dynamic, dynamic>) {
      return data.cast<String, dynamic>();
    }

    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isMobile = constraints.maxWidth < 600;

          return Column(
            children: [
              _buildCustomAppBar(isMobile),
              _buildFilterSection(isMobile),
              Expanded(child: _buildCompaniesWithWorkList(isMobile)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCustomAppBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 16 : 20,
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
            Icon(
              Icons.calendar_month,
              color: Colors.white,
              size: isMobile ? 28 : 32,
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Text(
              'السجل الشهري',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            const Spacer(flex: 12),
            StreamBuilder<DateTime>(
              stream: Stream.periodic(
                const Duration(seconds: 1),
                (_) => DateTime.now(),
              ),
              builder: (context, snapshot) {
                final now = snapshot.data ?? DateTime.now();

                // تحويل إلى نظام 12 ساعة
                int hour12 = now.hour % 12;
                if (hour12 == 0) hour12 = 12; // تحويل 0 إلى 12

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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      color: Colors.white,
      child: Column(
        children: [
          _buildSearchBar(isMobile),
          SizedBox(height: isMobile ? 12 : 16),
          _buildDateFilter(isMobile),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3498DB)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: const Color(0xFF3498DB),
            size: isMobile ? 20 : 24,
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: const InputDecoration(
                hintText: 'ابحث عن شركة...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => _searchQuery = ''),
              child: Icon(
                Icons.clear,
                size: isMobile ? 18 : 20,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateFilter(bool isMobile) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _selectDate(context),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 10 : 12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF3498DB)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: const Color(0xFF3498DB),
                    size: isMobile ? 18 : 20,
                  ),
                  SizedBox(width: isMobile ? 8 : 12),
                  Expanded(
                    child: Text(
                      _selectedDate != null
                          ? _formatDate(_selectedDate!)
                          : 'جميع التواريخ',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: _selectedDate != null
                            ? Colors.black
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: isMobile ? 8 : 12),
        if (_selectedDate != null)
          IconButton(
            icon: Icon(
              Icons.clear,
              color: Colors.red,
              size: isMobile ? 20 : 24,
            ),
            onPressed: () => setState(() => _selectedDate = null),
          ),
      ],
    );
  }

  Widget _buildCompaniesWithWorkList(bool isMobile) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getCompaniesWithWork(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: isMobile ? 48 : 64, color: Colors.red),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  'خطأ في تحميل البيانات: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: isMobile ? 14 : 16),
                ),
              ],
            ),
          );
        }

        final companiesList = snapshot.data ?? [];

        final filteredCompanies = companiesList
            .where((company) {
              if (_searchQuery.isEmpty) return true;
              final companyName =
                  company['companyName']?.toString().toLowerCase() ?? '';
              return companyName.contains(_searchQuery.toLowerCase());
            })
            .where((company) {
              return (company['workCount'] as int) > 0;
            })
            .toList();

        if (filteredCompanies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.business,
                  size: isMobile ? 60 : 80,
                  color: Colors.grey,
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  'لا توجد شركات لديها شغل يومي',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isMobile ? 4 : 8),
                Text(
                  _searchQuery.isEmpty
                      ? 'أضف شغل يومي جديد للبدء'
                      : 'لم يتم العثور على نتائج البحث',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          itemCount: filteredCompanies.length,
          itemBuilder: (context, index) {
            final companyData = filteredCompanies[index];
            return _buildCompanyItem(
              companyData['companyId'] as String,
              companyData,
              isMobile,
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getCompaniesWithWork() async {
    try {
      final dailyWorksSnapshot = await _firestore
          .collection('dailyWork')
          .where(
            'date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(2020)),
          )
          .get();

      final companyData = <String, Map<String, dynamic>>{};

      for (final work in dailyWorksSnapshot.docs) {
        final data = _safeConvertDocumentData(work.data());
        final companyId = data['companyId']?.toString() ?? '';
        final companyName = data['companyName']?.toString() ?? '';
        final workDate = (data['date'] as Timestamp?)?.toDate();

        if (companyId.isEmpty || companyName.isEmpty) continue;

        if (_selectedDate != null && workDate != null) {
          final startOfDay = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
          );
          final endOfDay = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            23,
            59,
            59,
          );

          if (workDate.isBefore(startOfDay) || workDate.isAfter(endOfDay)) {
            continue;
          }
        }

        if (!companyData.containsKey(companyId)) {
          companyData[companyId] = {
            'companyId': companyId,
            'companyName': companyName,
            'workCount': 0,
          };
        }

        companyData[companyId]!['workCount'] =
            (companyData[companyId]!['workCount'] as int) + 1;
      }

      return companyData.values.toList();
    } catch (e) {
      print('Error getting companies with work: $e');
      rethrow;
    }
  }

  Widget _buildCompanyItem(
    String companyId,
    Map<String, dynamic> data,
    bool isMobile,
  ) {
    final companyName = data['companyName']?.toString() ?? '';
    final workCount = data['workCount'] as int? ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3498DB).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: () => _showCompanyDetails(companyId, companyName, isMobile),
        leading: Container(
          width: isMobile ? 45 : 50,
          height: isMobile ? 45 : 50,
          decoration: BoxDecoration(
            color: const Color(0xFF3498DB),
            borderRadius: BorderRadius.circular(isMobile ? 22.5 : 25),
          ),
          child: Center(
            child: Text(
              workCount.toString(),
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          companyName,
          style: TextStyle(
            fontSize: isMobile ? 15 : 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        subtitle: Text(
          '$workCount نقلة',
          style: TextStyle(fontSize: isMobile ? 12 : 14, color: Colors.grey),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: const Color(0xFF3498DB),
          size: isMobile ? 14 : 16,
        ),
      ),
    );
  }

  // ====================================================
  // دالة تعديل الشغل اليومي (محدثة مع ملاحظات)
  // ====================================================
  void _editDailyWork(DailyWork dailyWork, String companyName, bool isMobile) {
    // Controllers للحقول
    final driverNameController = TextEditingController(
      text: dailyWork.driverName,
    );
    final loadingLocationController = TextEditingController(
      text: dailyWork.loadingLocation,
    );
    final unloadingLocationController = TextEditingController(
      text: dailyWork.unloadingLocation,
    );
    final ohdaController = TextEditingController(text: dailyWork.ohda);
    final kartaController = TextEditingController(text: dailyWork.karta);
    final trController = TextEditingController(text: dailyWork.tr ?? '');
    final notesController = TextEditingController(
      text: dailyWork.selectedNotes ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  width:
                      MediaQuery.of(context).size.width *
                      (isMobile ? 0.95 : 0.9),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // العنوان
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'تعديل النقلة',
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, size: isMobile ? 20 : 24),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),

                      SizedBox(height: isMobile ? 4 : 8),
                      Divider(color: const Color(0xFF3498DB).withOpacity(0.3)),

                      // معلومات الشركة
                      Container(
                        padding: EdgeInsets.all(isMobile ? 10 : 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3498DB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.business,
                              color: const Color(0xFF3498DB),
                              size: isMobile ? 18 : 20,
                            ),
                            SizedBox(width: isMobile ? 6 : 8),
                            Text(
                              companyName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C3E50),
                                fontSize: isMobile ? 14 : 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isMobile ? 16 : 20),

                      // حقل اسم السائق
                      _buildEditField(
                        'اسم السائق',
                        'أدخل اسم السائق',
                        driverNameController,
                        Icons.person,
                        isMobile,
                      ),

                      SizedBox(height: isMobile ? 12 : 16),

                      // حقل TR
                      _buildEditField(
                        'TR',
                        'أدخل رقم TR',
                        trController,
                        Icons.numbers,
                        isMobile,
                        isRequired: false,
                      ),

                      SizedBox(height: isMobile ? 12 : 16),

                      // حقل مكان التحميل
                      _buildEditField(
                        'مكان التحميل',
                        'أدخل مكان التحميل',
                        loadingLocationController,
                        Icons.location_on,
                        isMobile,
                      ),

                      SizedBox(height: isMobile ? 12 : 16),

                      // حقل مكان التعتيق
                      _buildEditField(
                        'مكان التعتيق',
                        'أدخل مكان التعتيق',
                        unloadingLocationController,
                        Icons.location_on,
                        isMobile,
                      ),

                      SizedBox(height: isMobile ? 12 : 16),

                      // صف العهدة والكارتة
                      Row(
                        children: [
                          Expanded(
                            child: _buildEditField(
                              'العهدة',
                              'أدخل العهدة',
                              ohdaController,
                              Icons.assignment,
                              isMobile,
                            ),
                          ),
                          SizedBox(width: isMobile ? 8 : 12),
                          Expanded(
                            child: _buildEditField(
                              'الكارتة',
                              'أدخل الكارتة',
                              kartaController,
                              Icons.credit_card,
                              isMobile,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: isMobile ? 12 : 16),

                      // حقل الملاحظات
                      _buildEditField(
                        'ملاحظات',
                        'أدخل ملاحظات إضافية',
                        notesController,
                        Icons.note,
                        isMobile,
                        isRequired: false,
                        maxLines: 3,
                      ),

                      SizedBox(height: isMobile ? 16 : 20),

                      // زر لتغيير عرض السعر
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.change_circle,
                            color: Colors.orange[700],
                          ),
                          title: Text(
                            'تغيير عرض السعر',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: isMobile ? 16 : 18,
                            color: Colors.orange[700],
                          ),
                          onTap: () {
                            Navigator.pop(
                              context,
                            ); // إغلاق نافذة التعديل الحالية
                            _showChangePriceOfferDialog(
                              context,
                              dailyWork,
                              companyName,
                              driverNameController.text,
                              loadingLocationController.text,
                              unloadingLocationController.text,
                              ohdaController.text,
                              kartaController.text,
                              trController.text,
                              notesController.text,
                              isMobile,
                            );
                          },
                        ),
                      ),

                      SizedBox(height: isMobile ? 20 : 24),

                      // أزرار الحفظ والإلغاء
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: isMobile ? 10 : 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'إلغاء',
                                style: TextStyle(
                                  color: const Color(0xFF2C3E50),
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 14 : 16,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: isMobile ? 8 : 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final confirmed = await _showConfirmEditDialog(
                                  context,
                                );
                                if (confirmed != null && confirmed) {
                                  await _updateDailyWork(
                                    dailyWork,
                                    driverNameController.text,
                                    loadingLocationController.text,
                                    unloadingLocationController.text,
                                    ohdaController.text,
                                    kartaController.text,
                                    trController.text,
                                    notesController.text,
                                  );
                                  Navigator.pop(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3498DB),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: isMobile ? 10 : 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'حفظ التعديلات',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 14 : 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ====================================================
  // نافذة تغيير عرض السعر مع البحث والاقتراحات
  // ====================================================
  void _showChangePriceOfferDialog(
    BuildContext context,
    DailyWork dailyWork,
    String companyName,
    String driverName,
    String loadingLocation,
    String unloadingLocation,
    String ohda,
    String karta,
    String tr,
    String notes,
    bool isMobile,
  ) {
    List<Map<String, dynamic>> _priceOffers = [];
    String? _selectedOfferId;
    bool _isLoading = true;
    final TextEditingController _searchController = TextEditingController();

    // جلب عروض الأسعار
    Future<void> _loadPriceOffers() async {
      if (dailyWork.companyId.isEmpty) return;

      try {
        final snapshot = await _firestore
            .collection('companies')
            .doc(dailyWork.companyId)
            .collection('priceOffers')
            .get();

        List<Map<String, dynamic>> allTransportations = [];

        for (final offerDoc in snapshot.docs) {
          final offerData = offerDoc.data();
          final transportations = offerData['transportations'] as List? ?? [];

          for (final transport in transportations) {
            final transportMap = transport as Map<String, dynamic>;

            // إنشاء معرف فريد لكل عرض
            String uniqueId =
                '${offerDoc.id}_${transportMap['loadingLocation']}_${transportMap['unloadingLocation']}_${transportMap['vehicleType']}';

            allTransportations.add({
              'uniqueId': uniqueId, // معرف فريد لكل نقل
              'offerId': offerDoc.id,
              'loadingLocation': transportMap['loadingLocation'] ?? '',
              'unloadingLocation': transportMap['unloadingLocation'] ?? '',
              'vehicleType': transportMap['vehicleType'] ?? '',
              'nolon': (transportMap['nolon'] ?? transportMap['noLon'] ?? 0.0)
                  .toDouble(),
              'wheelNolon':
                  (transportMap['wheelNolon'] ??
                          transportMap['wheelNoLon'] ??
                          0.0)
                      .toDouble(),
              'companyOvernight': (transportMap['companyOvernight'] ?? 0.0)
                  .toDouble(),
              'companyHoliday': (transportMap['companyHoliday'] ?? 0.0)
                  .toDouble(),
              'wheelOvernight': (transportMap['wheelOvernight'] ?? 0.0)
                  .toDouble(),
              'wheelHoliday': (transportMap['wheelHoliday'] ?? 0.0).toDouble(),
              'notes': transportMap['notes'] ?? '',
            });
          }
        }

        _priceOffers = allTransportations;

        // تحديد العرض الحالي إذا كان موجوداً
        if (dailyWork.priceOfferId.isNotEmpty) {
          for (var offer in _priceOffers) {
            if (offer['offerId'] == dailyWork.priceOfferId) {
              _selectedOfferId = offer['uniqueId'];
              break;
            }
          }
        }
      } catch (e) {
        print('خطأ في تحميل عروض الأسعار: $e');
      } finally {
        _isLoading = false;
      }
    }

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setState) {
            // تحميل العروض عند فتح النافذة
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_priceOffers.isEmpty && _isLoading) {
                _loadPriceOffers().then((_) {
                  if (!_isDisposed) {
                    setState(() {});
                  }
                });
              }
            });

            // تصفية العروض بناءً على البحث
            List<Map<String, dynamic>> getFilteredOffers() {
              if (_searchController.text.isEmpty) {
                return _priceOffers;
              }

              final query = _searchController.text.toLowerCase();
              return _priceOffers.where((offer) {
                final loading = (offer['loadingLocation'] ?? '').toLowerCase();
                final unloading = (offer['unloadingLocation'] ?? '')
                    .toLowerCase();
                final vehicleType = (offer['vehicleType'] ?? '').toLowerCase();

                return loading.contains(query) ||
                    unloading.contains(query) ||
                    vehicleType.contains(query);
              }).toList();
            }

            final filteredOffers = getFilteredOffers();

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.95,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // العنوان
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'اختر عرض سعر جديد',
                          style: TextStyle(
                            fontSize: isMobile ? 18 : 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: isMobile ? 20 : 24),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    SizedBox(height: isMobile ? 12 : 16),

                    // شريط البحث
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'ابحث بالمحطة أو الوجهة...',
                          prefixIcon: Icon(Icons.search, color: Colors.orange),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12 : 16,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isMobile ? 12 : 16),

                    // قائمة العروض
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : filteredOffers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: isMobile ? 48 : 60,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: isMobile ? 12 : 16),
                                  Text(
                                    'لا توجد عروض مطابقة',
                                    style: TextStyle(
                                      fontSize: isMobile ? 14 : 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredOffers.length,
                              itemBuilder: (context, index) {
                                final offer = filteredOffers[index];
                                final isSelected =
                                    _selectedOfferId == offer['uniqueId'];

                                return _buildPriceOfferItem(
                                  offer,
                                  isMobile,
                                  isSelected,
                                  () {
                                    setState(() {
                                      _selectedOfferId = offer['uniqueId'];
                                    });
                                  },
                                );
                              },
                            ),
                    ),

                    SizedBox(height: isMobile ? 16 : 20),

                    // زر تأكيد
                    if (_selectedOfferId != null)
                      ElevatedButton(
                        onPressed: () async {
                          final selectedOffer = _priceOffers.firstWhere(
                            (offer) => offer['uniqueId'] == _selectedOfferId,
                          );

                          final confirmed = await _showConfirmChangePriceDialog(
                            context,
                            dailyWork,
                            selectedOffer,
                            isMobile,
                          );

                          if (confirmed != null && confirmed) {
                            // تحديث بيانات النقلة مع العرض الجديد
                            await _updateDailyWorkWithNewPrice(
                              dailyWork,
                              driverName,
                              loadingLocation,
                              unloadingLocation,
                              ohda,
                              karta,
                              tr,
                              notes,
                              selectedOffer,
                            );

                            Navigator.pop(context); // إغلاق نافذة اختيار العرض
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          minimumSize: Size(
                            double.infinity,
                            isMobile ? 44 : 52,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'تأكيد التغيير',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPriceOfferItem(
    Map<String, dynamic> offer,
    bool isMobile,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange[50] : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.orange : Colors.grey,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.route,
          color: isSelected ? Colors.orange : Colors.blue,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${offer['loadingLocation']} → ${offer['unloadingLocation']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.orange[700] : Colors.blue[700],
              ),
            ),
            SizedBox(height: 4),
            Text(
              'نوع: ${offer['vehicleType']}',
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'نولون الشركة: ${offer['nolon']}',
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: Colors.green[700],
              ),
            ),
            Text(
              'نولون العجلات: ${offer['wheelNolon']}',
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                color: Colors.red[700],
              ),
            ),
          ],
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
        onTap: onTap,
      ),
    );
  }

  Future<bool?> _showConfirmChangePriceDialog(
    BuildContext context,
    DailyWork dailyWork,
    Map<String, dynamic> newPriceOffer,
    bool isMobile,
  ) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('تغيير عرض السعر'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سيتم تغيير عرض السعر الحالي إلى:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${newPriceOffer['loadingLocation']} → ${newPriceOffer['unloadingLocation']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('نولون الشركة:'),
                        Text(
                          '${newPriceOffer['nolon']} ج',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('نولون العجلات:'),
                        Text(
                          '${newPriceOffer['wheelNolon']} ج',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'سيتم تحديث جميع الحقول المرتبطة بما في ذلك:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• قيمة النولون للشركة'),
              Text('• قيمة النولون للعجلات'),
              Text('• جميع سجلات السائقين المرتبطة'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text('تأكيد التغيير'),
            ),
          ],
        ),
      ),
    );
  }

  // ====================================================
  // دالة تحديث النقلة بعرض سعر جديد
  // ====================================================
  Future<void> _updateDailyWorkWithNewPrice(
    DailyWork dailyWork,
    String driverName,
    String loadingLocation,
    String unloadingLocation,
    String ohda,
    String karta,
    String tr,
    String notes,
    Map<String, dynamic> priceOffer,
  ) async {
    try {
      final newSelectedRoute = '${priceOffer['unloadingLocation']}';
      final newPrice = priceOffer['nolon'] ?? 0.0;
      final newWheelNolon = priceOffer['wheelNolon'] ?? 0.0;
      final newVehicleType = priceOffer['vehicleType'] ?? '';
      final newOfferId = priceOffer['offerId'] ?? '';

      // تحديث dailyWork
      await _firestore.collection('dailyWork').doc(dailyWork.id).update({
        'driverName': driverName.trim(),
        'loadingLocation': loadingLocation.trim(),
        'unloadingLocation': unloadingLocation.trim(),
        'ohda': ohda.trim(),
        'karta': karta.trim(),
        'tr': tr.trim(),
        'selectedNotes': notes.trim(),
        'selectedRoute': newSelectedRoute,
        'selectedPrice': newPrice,
        'wheelNolon': newWheelNolon,
        'selectedVehicleType': newVehicleType,
        'priceOfferId': newOfferId,
        'nolon': newPrice,
        'updatedAt': Timestamp.now(),
      });

      // تحديث سجلات السائقين
      await _updateDriversWithNewPrice(
        dailyWork,
        driverName,
        loadingLocation,
        unloadingLocation,
        ohda,
        karta,
        tr,
        notes,
        newSelectedRoute,
        newPrice,
        newWheelNolon,
        newVehicleType,
        newOfferId,
      );

      _showSuccess('تم تحديث عرض السعر بنجاح');
    } catch (e) {
      print('خطأ في تحديث عرض السعر: $e');
      _showError('خطأ في تحديث عرض السعر: $e');
    }
  }

  // ====================================================
  // دالة تحديث سجلات السائقين بعرض سعر جديد
  // ====================================================
  Future<void> _updateDriversWithNewPrice(
    DailyWork dailyWork,
    String driverName,
    String loadingLocation,
    String unloadingLocation,
    String ohda,
    String karta,
    String tr,
    String notes,
    String selectedRoute,
    double selectedPrice,
    double wheelNolon,
    String vehicleType,
    String priceOfferId,
  ) async {
    try {
      final query = await _firestore
          .collection('drivers')
          .where('dailyWorkId', isEqualTo: dailyWork.id)
          .limit(10)
          .get();

      if (query.docs.isNotEmpty) {
        final batch = _firestore.batch();

        for (final doc in query.docs) {
          batch.update(doc.reference, {
            'driverName': driverName.trim(),
            'loadingLocation': loadingLocation.trim(),
            'unloadingLocation': unloadingLocation.trim(),
            'ohda': ohda.trim(),
            'karta': karta.trim(),
            'tr': tr.trim(),
            'selectedNotes': notes.trim(),
            'selectedRoute': selectedRoute,
            'selectedPrice': selectedPrice,
            'wheelNolon': wheelNolon,
            'selectedVehicleType': vehicleType,
            'priceOfferId': priceOfferId,
            'nolon': selectedPrice,
            'remainingAmount': wheelNolon,
            'updatedAt': Timestamp.now(),
          });
        }

        await batch.commit();
      }
    } catch (e) {
      print('خطأ في تحديث سجلات السائقين: $e');
      rethrow;
    }
  }

  // ====================================================
  // دالة تأكيد التعديل
  // ====================================================
  Future<bool?> _showConfirmEditDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(Icons.info, color: Colors.blue),
              SizedBox(width: 8),
              Text('تأكيد التعديل'),
            ],
          ),
          content: Text('هل تريد تعديل النقلة؟\n', textAlign: TextAlign.right),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('تأكيد'),
            ),
          ],
        ),
      ),
    );
  }

  // ====================================================
  // دالة لبناء حقل التعديل
  // ====================================================
  Widget _buildEditField(
    String label,
    String hint,
    TextEditingController controller,
    IconData icon,
    bool isMobile, {
    bool isRequired = true,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
                fontSize: isMobile ? 13 : 14,
              ),
            ),
            if (!isRequired)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  '(اختياري)',
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: isMobile ? 4 : 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: isRequired ? hint : '$hint (اختياري)',
            prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
            filled: true,
            fillColor: const Color(0xFFF4F6F8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 10 : 12,
            ),
          ),
        ),
      ],
    );
  }

  // ====================================================
  // دالة تحديث الشغل اليومي
  // ====================================================
  Future<void> _updateDailyWork(
    DailyWork dailyWork,
    String driverName,
    String loadingLocation,
    String unloadingLocation,
    String ohda,
    String karta,
    String tr,
    String notes,
  ) async {
    try {
      // 1. تحديث في collection "dailyWork"
      await _firestore.collection('dailyWork').doc(dailyWork.id).update({
        'driverName': driverName.trim(),
        'loadingLocation': loadingLocation.trim(),
        'unloadingLocation': unloadingLocation.trim(),
        'ohda': ohda.trim(),
        'karta': karta.trim(),
        'tr': tr.trim(),
        'selectedNotes': notes.trim(),
        'updatedAt': Timestamp.now(),
      });

      // 2. البحث عن وثائق السائق المرتبطة
      final driverDocIds = await _findDriverDocumentIds(
        dailyWork.id!,
        driverName.trim(),
        dailyWork.date,
      );

      // 3. إذا وجدت وثائق سائق مرتبطة، قم بتحديثها
      if (driverDocIds.isNotEmpty) {
        final batch = _firestore.batch();

        for (final docId in driverDocIds) {
          final docRef = _firestore.collection('drivers').doc(docId);

          // تحديث جميع الحقول المرتبطة
          batch.update(docRef, {
            'driverName': driverName.trim(),
            'loadingLocation': loadingLocation.trim(),
            'unloadingLocation': unloadingLocation.trim(),
            'ohda': ohda.trim(),
            'karta': karta.trim(),
            'tr': tr.trim(),
            'selectedNotes': notes.trim(),
            'updatedAt': Timestamp.now(),
          });
        }

        await batch.commit();
      }

      // إظهار رسالة نجاح
      if (mounted && !_isDisposed) {
        _showSuccess('تم تعديل النقلة بنجاح');
      }
    } catch (e) {
      print('Error updating daily work: $e');
      if (mounted && !_isDisposed) {
        _showError('خطأ في التعديل: $e');
      }
    }
  }

  // ====================================================
  // دالة البحث عن وثائق السائق المرتبطة
  // ====================================================
  Future<List<String>> _findDriverDocumentIds(
    String dailyWorkId,
    String driverName,
    DateTime date,
  ) async {
    try {
      // البحث باستخدام dailyWorkId
      if (dailyWorkId.isNotEmpty) {
        final queryById = await _firestore
            .collection('drivers')
            .where('dailyWorkId', isEqualTo: dailyWorkId)
            .get();

        if (queryById.docs.isNotEmpty) {
          return queryById.docs.map((doc) => doc.id).toList();
        }
      }

      // البحث باستخدام اسم السائق والتاريخ
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final queryByDriver = await _firestore
          .collection('drivers')
          .where('driverName', isEqualTo: driverName)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      return queryByDriver.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('خطأ في البحث عن وثائق السائق: $e');
      return [];
    }
  }

  // ====================================================
  // دالة حذف الشغل اليومي
  // ====================================================
  void _deleteDailyWork(DailyWork dailyWork, bool isMobile) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.orange,
                size: isMobile ? 20 : 24,
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Text(
                'تأكيد الحذف',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                  fontSize: isMobile ? 16 : 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'هل أنت متأكد من حذف هذه النقلة؟',
                style: TextStyle(fontSize: isMobile ? 14 : 16),
              ),
              SizedBox(height: isMobile ? 6 : 8),
              Text(
                'السائق: ${dailyWork.driverName}',
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                'المسار: ${dailyWork.loadingLocation} → ${dailyWork.unloadingLocation}',
                style: const TextStyle(color: Colors.grey),
              ),
              if (dailyWork.selectedRoute != null)
                Text(
                  'اسم الموقع: ${dailyWork.selectedRoute}',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (dailyWork.tr.isNotEmpty)
                Text(
                  'TR: ${dailyWork.tr}',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (dailyWork.selectedNotes != null &&
                  dailyWork.selectedNotes!.isNotEmpty)
                Text(
                  'ملاحظات: ${dailyWork.selectedNotes}',
                  style: TextStyle(
                    color: Colors.purple[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              SizedBox(height: isMobile ? 12 : 16),
              Text(
                '⚠️ لا يمكن التراجع عن هذا الإجراء',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: isMobile ? 10 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  color: const Color(0xFF2C3E50),
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _confirmDeleteDailyWork(dailyWork);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'حذف',
                style: TextStyle(fontSize: isMobile ? 14 : 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====================================================
  // دالة تأكيد الحذف
  // ====================================================
  Future<void> _confirmDeleteDailyWork(DailyWork dailyWork) async {
    try {
      await _firestore.collection('dailyWork').doc(dailyWork.id).delete();

      // إظهار رسالة نجاح
      if (mounted && !_isDisposed) {
        _showSuccess('تم حذف النقلة بنجاح');
      }
    } catch (e) {
      print('Error deleting daily work: $e');
      if (mounted && !_isDisposed) {
        _showError('خطأ في الحذف: $e');
      }
    }
  }

  void _showCompanyDetails(
    String companyId,
    String companyName,
    bool isMobile,
  ) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(isMobile ? 8 : 16),
          child: Container(
            width: MediaQuery.of(context).size.width * (isMobile ? 0.98 : 0.95),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // العنوان
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, size: isMobile ? 20 : 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'نقلات $companyName',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    SizedBox(width: isMobile ? 40 : 48),
                  ],
                ),

                SizedBox(height: isMobile ? 4 : 8),
                Divider(color: const Color(0xFF3498DB).withOpacity(0.3)),

                // معلومات الشركة والفلتر
                Container(
                  padding: EdgeInsets.all(isMobile ? 10 : 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498DB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            'اسم الشركة',
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 11,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            companyName,
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'فلتر التاريخ',
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 11,
                              color: Colors.grey,
                            ),
                          ),
                          InkWell(
                            onTap: () => _selectDateForDetails(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 10 : 12,
                                vertical: isMobile ? 5 : 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: const Color(0xFF3498DB),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: isMobile ? 14 : 16,
                                    color: const Color(0xFF3498DB),
                                  ),
                                  SizedBox(width: isMobile ? 4 : 6),
                                  Text(
                                    _selectedDate != null
                                        ? _formatDate(_selectedDate!)
                                        : 'جميع التواريخ',
                                    style: TextStyle(
                                      fontSize: isMobile ? 11 : 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: isMobile ? 12 : 16),
                Expanded(
                  child: _buildCompanyWorkTable(
                    companyId,
                    companyName,
                    isMobile,
                  ),
                ),
                SizedBox(height: isMobile ? 12 : 16),

                // زر الإغلاق
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498DB),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 30 : 40,
                      vertical: isMobile ? 10 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'إغلاق',
                    style: TextStyle(fontSize: isMobile ? 14 : 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateForDetails(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildCompanyWorkTable(
    String companyId,
    String companyName,
    bool isMobile,
  ) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getCompanyDailyWorkStream(companyId),
      builder: (context, snapshot) {
        // التحقق من حالة التصريف
        if (_isDisposed) {
          return const Center(child: Text('الصفحة مغلقة'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: isMobile ? 40 : 48, color: Colors.red),
                SizedBox(height: isMobile ? 6 : 8),
                Text(
                  'خطأ في تحميل البيانات',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          );
        }

        final dailyWorks = _convertSnapshotToDailyWorkList(snapshot.data);

        if (dailyWorks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.work_outline,
                  size: isMobile ? 50 : 64,
                  color: Colors.grey,
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  'لا توجد نقلات',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.transparent, width: 1.5),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Table(
                defaultColumnWidth: FixedColumnWidth(isMobile ? 110 : 130),
                border: TableBorder.all(
                  color: const Color(0xFF3498DB),
                  width: 1,
                ),
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: const Color(0xFF3498DB).withOpacity(0.15),
                    ),
                    children: [
                      _TableCellHeader('م', isMobile),
                      _TableCellHeader('التاريخ', isMobile),
                      _TableCellHeader('اسم السائق', isMobile),
                      _TableCellHeader('مكان التحميل', isMobile),
                      _TableCellHeader('مكان التعتيق', isMobile),
                      _TableCellHeader('مطابقه نولون', isMobile),
                      _TableCellHeader('TR', isMobile),
                      _TableCellHeader('العهدة', isMobile),
                      _TableCellHeader('الكارتة', isMobile),
                      _TableCellHeader('ملاحظات', isMobile),
                      _TableCellHeader('الإجراءات', isMobile),
                    ],
                  ),
                  ...dailyWorks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final dailyWork = entry.value;

                    return TableRow(
                      decoration: BoxDecoration(
                        color: index.isEven
                            ? Colors.white
                            : const Color(0xFFF8F9FA),
                      ),
                      children: [
                        _TableCellBody('${index + 1}', isMobile),
                        _TableCellBody(_formatDate(dailyWork.date), isMobile),
                        _TableCellBody(dailyWork.driverName, isMobile),
                        _TableCellBody(dailyWork.loadingLocation, isMobile),
                        _TableCellBody(dailyWork.unloadingLocation, isMobile),
                        _TableCellBody(
                          dailyWork.selectedRoute ?? '',
                          isMobile,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        _TableCellBody(
                          dailyWork.tr ?? '',
                          isMobile,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        _TableCellBody(
                          dailyWork.ohda,
                          isMobile,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        _TableCellKartaWithAdd(
                          dailyWork: dailyWork,
                          isMobile: isMobile,
                          onAddBalance: () =>
                              _showAddBalanceDialog(dailyWork, isMobile),
                        ),
                        _TableCellBody(
                          dailyWork.selectedNotes ?? '',
                          isMobile,
                          textStyle: TextStyle(color: Colors.purple[700]),
                        ),
                        _TableCellActionsWithHolidayAndOvernight(
                          dailyWork: dailyWork,
                          companyName: companyName,
                          isMobile: isMobile,
                          onEdit: () =>
                              _editDailyWork(dailyWork, companyName, isMobile),
                          onDelete: () => _deleteDailyWork(dailyWork, isMobile),
                          onAddHoliday: () =>
                              _addHoliday(dailyWork, companyName, isMobile),
                          onAddOvernight: () =>
                              _addOvernight(dailyWork, companyName, isMobile),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ====================================================
  // دالة إضافة ميزان الشركات للكارتة
  // ====================================================
  void _showAddBalanceDialog(DailyWork dailyWork, bool isMobile) {
    final balanceController = TextEditingController();
    final currentKarta = double.tryParse(dailyWork.karta) ?? 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final balanceValue = double.tryParse(balanceController.text) ?? 0.0;
            final newTotal = currentKarta + balanceValue;
            final showNewTotal =
                balanceController.text.isNotEmpty && balanceValue > 0;

            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.add_circle,
                      color: Colors.orange[700],
                      size: isMobile ? 24 : 28,
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    Text(
                      'إضافة ميزان الشركه',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 16 : 18,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عرض الكارتة الحالية
                    Container(
                      padding: EdgeInsets.all(isMobile ? 10 : 12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'قيمة الكارتة الحالية:',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              color: Colors.orange[800],
                            ),
                          ),
                          Text(
                            '$currentKarta ج',
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 20),

                    // حقل إدخال الميزان
                    Text(
                      'قيمة الميزان الإضافية:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 13 : 14,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    SizedBox(height: isMobile ? 6 : 8),
                    TextFormField(
                      controller: balanceController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'أدخل قيمة الميزان',
                        prefixIcon: Icon(
                          Icons.attach_money,
                          color: Colors.orange[700],
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF4F6F8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isMobile ? 12 : 16,
                          vertical: isMobile ? 12 : 16,
                        ),
                      ),
                    ),
                    SizedBox(height: isMobile ? 8 : 12),

                    // عرض القيمة الجديدة
                    if (showNewTotal)
                      Container(
                        padding: EdgeInsets.all(isMobile ? 10 : 12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'القيمة الإجمالية الجديدة:',
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 14,
                                color: Colors.green[800],
                              ),
                            ),
                            Text(
                              '$newTotal ج',
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'إلغاء',
                      style: TextStyle(fontSize: isMobile ? 14 : 16),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (balanceController.text.isEmpty) {
                        _showError('يرجى إدخال قيمة الميزان');
                        return;
                      }

                      final balanceValue =
                          double.tryParse(balanceController.text) ?? 0.0;
                      if (balanceValue <= 0) {
                        _showError('القيمة يجب أن تكون أكبر من صفر');
                        return;
                      }

                      await _updateKartaWithBalance(dailyWork, balanceValue);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'حفظ',
                      style: TextStyle(fontSize: isMobile ? 14 : 16),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ====================================================
  // دالة تحديث الكارتة بالميزان
  // ====================================================
  Future<void> _updateKartaWithBalance(
    DailyWork dailyWork,
    double balanceValue,
  ) async {
    try {
      final currentKarta = double.tryParse(dailyWork.karta) ?? 0.0;
      final newKarta = currentKarta + balanceValue;
      final kartaString = newKarta.toStringAsFixed(2);

      // 1. تحديث في collection "dailyWork"
      await _firestore.collection('dailyWork').doc(dailyWork.id).update({
        'karta': kartaString,
        'companyBalance': FieldValue.increment(balanceValue),
        'updatedAt': Timestamp.now(),
      });

      // 2. تحديث سجلات السائقين المرتبطة
      final driverDocIds = await _findDriverDocumentIds(
        dailyWork.id!,
        dailyWork.driverName,
        dailyWork.date,
      );

      if (driverDocIds.isNotEmpty) {
        final batch = _firestore.batch();

        for (final docId in driverDocIds) {
          final docRef = _firestore.collection('drivers').doc(docId);
          batch.update(docRef, {
            'karta': kartaString,
            'companyBalance': FieldValue.increment(balanceValue),
            'updatedAt': Timestamp.now(),
          });
        }

        await batch.commit();
      }

      // إظهار رسالة نجاح
      if (mounted && !_isDisposed) {
        _showSuccess(
          'تم إضافة ميزان بقيمة $balanceValue ج\nالقيمة الجديدة للكارتة: $kartaString ج',
        );
      }
    } catch (e) {
      print('خطأ في تحديث الكارتة: $e');
      if (mounted && !_isDisposed) {
        _showError('خطأ في إضافة الميزان: $e');
      }
    }
  }

  // دالة لإنشاء Stream للبيانات
  Stream<QuerySnapshot> _getCompanyDailyWorkStream(String companyId) {
    Query query = _firestore
        .collection('dailyWork')
        .where('companyId', isEqualTo: companyId);

    if (_selectedDate != null) {
      final startOfDay = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
      );
      final endOfDay = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        23,
        59,
        59,
      );

      query = query
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay));
    }

    final stream = query.snapshots();

    // حفظ الاشتراك للتحكم فيه لاحقاً
    _companyWorkStreamSubscription = stream.listen(
      (_) {},
      onError: (error) {
        print('Stream error: $error');
      },
    );

    return stream;
  }

  // دالة لتحويل الـ Snapshot إلى قائمة DailyWork
  List<DailyWork> _convertSnapshotToDailyWorkList(QuerySnapshot? snapshot) {
    if (snapshot == null) return [];

    final dailyWorks = snapshot.docs.map((doc) {
      final data = _safeConvertDocumentData(doc.data());
      return DailyWork.fromMap(data, doc.id);
    }).toList();

    dailyWorks.sort((a, b) => b.date.compareTo(a.date));
    return dailyWorks;
  }

  // ====================================================
  // الدوال الجديدة لإضافة العطلة والمبيت
  // ====================================================

  // دالة لجلب بيانات عرض السعر للشركة باستخدام priceOfferId
  Future<Map<String, dynamic>?> _getPriceOfferData(
    String companyId,
    String priceOfferId,
  ) async {
    try {
      if (companyId.isEmpty || priceOfferId.isEmpty) {
        return null;
      }

      final snapshot = await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('priceOffers')
          .doc(priceOfferId)
          .get();

      if (snapshot.exists) {
        return snapshot.data();
      } else {
        return null;
      }
    } catch (e) {
      print('🚨 خطأ في جلب بيانات عرض السعر: $e');
      return null;
    }
  }

  // دالة إضافة عطلة
  void _addHoliday(DailyWork dailyWork, String companyName, bool isMobile) {
    _addHolidayOrOvernight(dailyWork, companyName, isMobile, true);
  }

  // دالة إضافة مبيت
  void _addOvernight(DailyWork dailyWork, String companyName, bool isMobile) {
    _addHolidayOrOvernight(dailyWork, companyName, isMobile, false);
  }

  // دالة مشتركة لإضافة عطلة أو مبيت
  void _addHolidayOrOvernight(
    DailyWork dailyWork,
    String companyName,
    bool isMobile,
    bool isHoliday,
  ) async {
    try {
      if (dailyWork.priceOfferId.isEmpty) {
        _showError('❌ لا يوجد عرض سعر مرتبط بهذه النقلة');
        return;
      }

      final priceOfferData = await _getPriceOfferData(
        dailyWork.companyId,
        dailyWork.priceOfferId,
      );

      if (priceOfferData == null) {
        _showError('❌ عرض السعر غير موجود');
        return;
      }

      final transportations = priceOfferData['transportations'] as List? ?? [];

      if (transportations.isEmpty) {
        _showError('❌ لا توجد نقلات في عرض السعر');
        return;
      }

      Map<String, dynamic>? selectedTransportation;

      for (final transport in transportations) {
        final transportMap = transport as Map<String, dynamic>;
        final unloadingLocation =
            transportMap['unloadingLocation']?.toString() ?? '';
        final selectedRoute = dailyWork.selectedRoute?.toString() ?? '';

        if (unloadingLocation == selectedRoute) {
          selectedTransportation = transportMap;
          break;
        }
      }

      if (selectedTransportation == null) {
        selectedTransportation = transportations.first as Map<String, dynamic>;
      }

      double companyAmount = 0.0;
      double wheelAmount = 0.0;

      if (isHoliday) {
        companyAmount = _extractValue(selectedTransportation, [
          'companyHoliday',
          'company_holiday',
          'holiday_company',
          'companyHolidayPrice',
        ]);

        wheelAmount = _extractValue(selectedTransportation, [
          'wheelHoliday',
          'wheel_holiday',
          'holiday_wheel',
          'wheelHolidayPrice',
        ]);
      } else {
        companyAmount = _extractValue(selectedTransportation, [
          'companyOvernight',
          'company_overnight',
          'overnight_company',
          'companyOvernightPrice',
        ]);

        wheelAmount = _extractValue(selectedTransportation, [
          'wheelOvernight',
          'wheel_overnight',
          'overnight_wheel',
          'wheelOvernightPrice',
        ]);
      }

      final confirmed = await _showSimpleConfirmation(
        context,
        isHoliday,
        companyAmount,
        wheelAmount,
        isMobile,
      );

      if (confirmed != null && confirmed) {
        await _updateHolidayOrOvernight(
          dailyWork,
          isHoliday,
          companyAmount,
          wheelAmount,
        );
      }
    } catch (e) {
      print('🚨 خطأ في إضافة العطلة/المبيت: $e');
      _showError('❌ خطأ في إضافة العطلة/المبيت: ${e.toString()}');
    }
  }

  // دالة مساعدة لاستخراج قيمة
  double _extractValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null) {
        if (value is int) return value.toDouble();
        if (value is double) return value;
        if (value is String) {
          final parsed = double.tryParse(value);
          if (parsed != null) return parsed;
        }
      }
    }
    return 0.0;
  }

  // دالة تأكيد بسيطة
  Future<bool?> _showSimpleConfirmation(
    BuildContext context,
    bool isHoliday,
    double companyAmount,
    double wheelAmount,
    bool isMobile,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                isHoliday ? Icons.celebration : Icons.hotel,
                color: isHoliday ? Colors.orange : Colors.blue,
                size: isMobile ? 24 : 28,
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Text(
                isHoliday ? 'إضافة عطلة' : 'إضافة مبيت',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 16 : 18,
                  color: const Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isHoliday ? 'سيتم إضافة عطلة بقيمة:' : 'سيتم إضافة مبيت بقيمة:',
                style: TextStyle(fontSize: isMobile ? 14 : 16),
              ),
              SizedBox(height: isMobile ? 8 : 12),
              _buildAmountItem(
                isHoliday ? 'عطلة الشركة' : 'مبيت الشركة',
                companyAmount,
                isHoliday ? Colors.orange : Colors.blue,
                isMobile,
              ),
              SizedBox(height: 6),
              _buildAmountItem(
                isHoliday ? 'عطلة العجلات' : 'مبيت العجلات',
                wheelAmount,
                isHoliday ? Colors.orange[700]! : Colors.blue[700]!,
                isMobile,
              ),
              SizedBox(height: isMobile ? 8 : 12),
              Divider(color: Colors.grey[300]),
              SizedBox(height: isMobile ? 8 : 12),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'إلغاء',
                style: TextStyle(fontSize: isMobile ? 14 : 16),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isHoliday ? Colors.orange : Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'تأكيد',
                style: TextStyle(fontSize: isMobile ? 14 : 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دالة لعرض عنصر المبلغ
  Widget _buildAmountItem(
    String label,
    double amount,
    Color color,
    bool isMobile,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: isMobile ? 13 : 14, color: color),
        ),
        Text(
          '$amount ج',
          style: TextStyle(
            fontSize: isMobile ? 13 : 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  // دالة تحديث العطلة أو المبيت
  Future<void> _updateHolidayOrOvernight(
    DailyWork dailyWork,
    bool isHoliday,
    double companyAmount,
    double wheelAmount,
  ) async {
    try {
      final updateData = <String, dynamic>{'updatedAt': Timestamp.now()};

      if (isHoliday) {
        updateData.addAll({
          'companyHoliday': companyAmount,
          'wheelHoliday': wheelAmount,
        });
      } else {
        updateData.addAll({
          'companyOvernight': companyAmount,
          'wheelOvernight': wheelAmount,
        });
      }

      await _firestore
          .collection('dailyWork')
          .doc(dailyWork.id)
          .update(updateData);

      await _updateDriversCollection(
        dailyWork,
        isHoliday,
        companyAmount,
        wheelAmount,
      );

      if (mounted && !_isDisposed) {
        _showSuccess(
          isHoliday ? '✅ تم إضافة العطلة بنجاح' : '✅ تم إضافة المبيت بنجاح',
        );
      }
    } catch (e) {
      print('🚨 خطأ في تحديث Firestore: $e');
      if (mounted && !_isDisposed) {
        _showError('❌ خطأ في تحديث البيانات: ${e.toString()}');
      }
    }
  }

  // دالة تحديث drivers collection
  Future<void> _updateDriversCollection(
    DailyWork dailyWork,
    bool isHoliday,
    double companyAmount,
    double wheelAmount,
  ) async {
    try {
      final query = await _firestore
          .collection('drivers')
          .where('dailyWorkId', isEqualTo: dailyWork.id)
          .limit(10)
          .get();

      if (query.docs.isNotEmpty) {
        final batch = _firestore.batch();
        final totalAmount = companyAmount + wheelAmount;

        for (final doc in query.docs) {
          final updateData = <String, dynamic>{'updatedAt': Timestamp.now()};

          if (isHoliday) {
            updateData.addAll({
              'companyHoliday': companyAmount,
              'wheelHoliday': wheelAmount,
            });
          } else {
            updateData.addAll({
              'companyOvernight': companyAmount,
              'wheelOvernight': wheelAmount,
            });
          }

          updateData['remainingAmount'] = FieldValue.increment(totalAmount);

          batch.update(doc.reference, updateData);
        }

        await batch.commit();
      }
    } catch (e) {
      print('🚨 خطأ في تحديث سجلات السائقين: $e');
      rethrow;
    }
  }

  // ====================================================
  // باقي الدوال الحالية
  // ====================================================

  // دالة إظهار خطأ
  void _showError(String message) {
    if (mounted && !_isDisposed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // دالة إظهار نجاح
  void _showSuccess(String message) {
    if (mounted && !_isDisposed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// ====================================================
// Widget جديد للخلية مع زر إضافة
// ====================================================
class _TableCellKartaWithAdd extends StatelessWidget {
  final DailyWork dailyWork;
  final bool isMobile;
  final VoidCallback onAddBalance;

  const _TableCellKartaWithAdd({
    required this.dailyWork,
    required this.isMobile,
    required this.onAddBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 40 : 48,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // عرض قيمة الكارتة
          Expanded(
            child: Text(
              dailyWork.karta,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFD35400),
              ),
            ),
          ),

          // زر الإضافة
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(isMobile ? 3 : 5),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.add,
                size: isMobile ? 12 : 14,
                color: Colors.orange,
              ),
            ),
            onPressed: onAddBalance,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'إضافة ميزان للكارتة',
          ),
        ],
      ),
    );
  }
}

class _TableCellBody extends StatelessWidget {
  final String text;
  final bool isMobile;
  final TextStyle? textStyle;

  const _TableCellBody(this.text, this.isMobile, {this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 40 : 48,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: textStyle ?? TextStyle(fontSize: isMobile ? 11 : 14),
      ),
    );
  }
}

class _TableCellHeader extends StatelessWidget {
  final String text;
  final bool isMobile;

  const _TableCellHeader(this.text, this.isMobile);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 42 : 50,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: isMobile ? 11 : 14,
          color: const Color(0xFF2C3E50),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TableCellActionsWithHolidayAndOvernight extends StatelessWidget {
  final DailyWork dailyWork;
  final String companyName;
  final bool isMobile;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddHoliday;
  final VoidCallback onAddOvernight;

  const _TableCellActionsWithHolidayAndOvernight({
    required this.dailyWork,
    required this.companyName,
    required this.isMobile,
    required this.onEdit,
    required this.onDelete,
    required this.onAddHoliday,
    required this.onAddOvernight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 40 : 48,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(isMobile ? 3 : 5),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.celebration,
                size: isMobile ? 12 : 14,
                color: Colors.orange,
              ),
            ),
            onPressed: onAddHoliday,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'إضافة عطلة',
          ),
          SizedBox(width: isMobile ? 2 : 4),

          IconButton(
            icon: Container(
              padding: EdgeInsets.all(isMobile ? 3 : 5),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.hotel,
                size: isMobile ? 12 : 14,
                color: Colors.blue,
              ),
            ),
            onPressed: onAddOvernight,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'إضافة مبيت',
          ),
          SizedBox(width: isMobile ? 2 : 4),

          IconButton(
            icon: Container(
              padding: EdgeInsets.all(isMobile ? 4 : 6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.edit,
                size: isMobile ? 14 : 16,
                color: Colors.blue,
              ),
            ),
            onPressed: onEdit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(width: isMobile ? 2 : 4),

          IconButton(
            icon: Container(
              padding: EdgeInsets.all(isMobile ? 4 : 6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.delete,
                size: isMobile ? 14 : 16,
                color: Colors.red,
              ),
            ),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
