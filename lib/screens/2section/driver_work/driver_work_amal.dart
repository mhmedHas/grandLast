// // // import 'dart:async';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:intl/intl.dart';

// // // class DriverWorkPage extends StatefulWidget {
// // //   const DriverWorkPage({super.key});

// // //   @override
// // //   State<DriverWorkPage> createState() => _DriverWorkPageState();
// // // }

// // // class _DriverWorkPageState extends State<DriverWorkPage> {
// // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// // //   // البيانات الأساسية
// // //   List<String> _contractors = []; // قائمة المقاولين
// // //   List<Map<String, dynamic>> _driversByContractor = []; // السائقين حسب المقاول

// // //   // بيانات شغل السائق (من الكود القديم)
// // //   List<Map<String, dynamic>> _driverWork = [];
// // //   List<Map<String, dynamic>> _filteredDriverWork = [];

// // //   // حالات التحديد
// // //   String? _selectedContractor;
// // //   String? _selectedDriver;

// // //   // حالات التحميل
// // //   bool _isLoading = false;
// // //   bool _isLoadingDrivers = false;
// // //   bool _isLoadingWork = false;

// // //   // الفلاتر
// // //   String _searchContractorQuery = '';
// // //   String _searchDriverQuery = '';
// // //   String _timeFilter = 'الكل';
// // //   int _selectedMonth = DateTime.now().month;
// // //   int _selectedYear = DateTime.now().year;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadContractors();
// // //   }

// // //   // ---------------------------
// // //   // تحميل قائمة المقاولين
// // //   // ---------------------------
// // //   Future<void> _loadContractors() async {
// // //     setState(() => _isLoading = true);
// // //     try {
// // //       final snapshot = await _firestore.collection('drivers').get();

// // //       // استخراج المقاولين الفريدين
// // //       Set<String> contractorsSet = {};

// // //       for (final doc in snapshot.docs) {
// // //         final data = doc.data();
// // //         final contractor = (data['contractor'] ?? '').toString().trim();
// // //         if (contractor.isNotEmpty) {
// // //           contractorsSet.add(contractor);
// // //         }
// // //       }

// // //       // تحويل إلى قائمة وترتيب أبجدي
// // //       List<String> contractorsList = contractorsSet.toList()..sort();

// // //       setState(() {
// // //         _contractors = contractorsList;
// // //         _isLoading = false;
// // //       });
// // //     } catch (e) {
// // //       setState(() => _isLoading = false);
// // //       _showError('خطأ في تحميل المقاولين: $e');
// // //     }
// // //   }

// // //   // ---------------------------
// // //   // تحميل السائقين التابعين لمقاول محدد
// // //   // ---------------------------
// // //   Future<void> _loadDriversByContractor(String contractor) async {
// // //     if (contractor.isEmpty) return;

// // //     setState(() {
// // //       _selectedContractor = contractor;
// // //       _isLoadingDrivers = true;
// // //       _driversByContractor.clear();
// // //       _selectedDriver = null;
// // //       _driverWork.clear();
// // //       _filteredDriverWork.clear();
// // //     });

// // //     try {
// // //       final snapshot = await _firestore
// // //           .collection('drivers')
// // //           .where('contractor', isEqualTo: contractor)
// // //           .get();

// // //       // تجميع السائقين الفريدين
// // //       Map<String, Map<String, dynamic>> driversMap = {};

// // //       for (final doc in snapshot.docs) {
// // //         final data = doc.data();
// // //         final driverName = (data['driverName'] ?? '').toString().trim();
// // //         if (driverName.isEmpty) continue;

// // //         if (!driversMap.containsKey(driverName)) {
// // //           driversMap[driverName] = {
// // //             'driverName': driverName,
// // //             'contractor': contractor,
// // //             'totalTrips': 0,
// // //             'lastTripDate': null,
// // //           };
// // //         }

// // //         final driverData = driversMap[driverName]!;

// // //         // تحديث الإحصائيات
// // //         driverData['totalTrips'] = driverData['totalTrips']! + 1;

// // //         // تاريخ آخر رحلة
// // //         final tripDate = (data['date'] as Timestamp?)?.toDate();
// // //         if (tripDate != null) {
// // //           if (driverData['lastTripDate'] == null ||
// // //               tripDate.isAfter(driverData['lastTripDate'])) {
// // //             driverData['lastTripDate'] = tripDate;
// // //           }
// // //         }
// // //       }

// // //       // تحويل القائمة وترتيب أبجدي
// // //       List<Map<String, dynamic>> driversList = driversMap.values.toList();
// // //       driversList.sort((a, b) => a['driverName'].compareTo(b['driverName']));

// // //       setState(() {
// // //         _driversByContractor = driversList;
// // //         _isLoadingDrivers = false;
// // //       });
// // //     } catch (e) {
// // //       setState(() => _isLoadingDrivers = false);
// // //       _showError('خطأ في تحميل السائقين: $e');
// // //     }
// // //   }

// // //   // ---------------------------
// // //   // تحميل شغل سائق محدد - من الكود القديم
// // //   // ---------------------------
// // //   Future<void> _loadDriverWork(String driverName) async {
// // //     setState(() {
// // //       _selectedDriver = driverName;
// // //       _isLoadingWork = true;
// // //       _driverWork.clear();
// // //       _filteredDriverWork.clear();
// // //     });

// // //     try {
// // //       final snapshot = await _firestore
// // //           .collection('drivers')
// // //           .where('driverName', isEqualTo: driverName)
// // //           .orderBy('date', descending: true)
// // //           .get();

// // //       List<Map<String, dynamic>> workList = [];

// // //       for (final doc in snapshot.docs) {
// // //         final data = doc.data();
// // //         DateTime? date = (data['date'] as Timestamp?)?.toDate();

// // //         workList.add({
// // //           'id': doc.id,
// // //           'date': date,
// // //           'companyName': data['companyName'] ?? 'غير معروف',
// // //           'loadingLocation': data['loadingLocation'] ?? '',
// // //           'unloadingLocation': data['unloadingLocation'] ?? '',
// // //           'selectedRoute': data['selectedRoute'] ?? '',
// // //           'ohda': data['ohda'] ?? '',
// // //           'karta': data['karta'] ?? '',
// // //           'wheelNolon': (data['wheelNolon'] ?? 0).toDouble(),
// // //           'wheelOvernight': (data['wheelOvernight'] ?? 0).toDouble(),
// // //           'wheelHoliday': (data['wheelHoliday'] ?? 0).toDouble(),
// // //           'selectedPrice': (data['selectedPrice'] ?? 0).toDouble(),
// // //           'isPaid': data['isPaid'] ?? false,
// // //           'paidAmount': (data['paidAmount'] ?? 0).toDouble(),
// // //           'remainingAmount': (data['remainingAmount'] ?? 0).toDouble(),
// // //           'paymentDate': data['paymentDate'] as Timestamp?,
// // //           'driverNotes': data['driverNotes'] ?? '',
// // //         });
// // //       }

// // //       setState(() {
// // //         _driverWork = workList;
// // //         _filteredDriverWork = _filterWorkByDate(workList);
// // //         _isLoadingWork = false;
// // //       });
// // //     } catch (e) {
// // //       setState(() => _isLoadingWork = false);
// // //       _showError('خطأ في تحميل الشغل');
// // //     }
// // //   }

// // //   // ---------------------------
// // //   // تصفية الشغل حسب التاريخ - من الكود القديم
// // //   // ---------------------------
// // //   List<Map<String, dynamic>> _filterWorkByDate(
// // //     List<Map<String, dynamic>> workList,
// // //   ) {
// // //     return workList.where((work) {
// // //       final workDate = work['date'] as DateTime?;
// // //       if (workDate == null) return false;
// // //       final now = DateTime.now();
// // //       switch (_timeFilter) {
// // //         case 'اليوم':
// // //           return workDate.year == now.year &&
// // //               workDate.month == now.month &&
// // //               workDate.day == now.day;
// // //         case 'هذا الشهر':
// // //           return workDate.year == now.year && workDate.month == now.month;
// // //         case 'هذه السنة':
// // //           return workDate.year == now.year;
// // //         case 'مخصص':
// // //           return workDate.year == _selectedYear &&
// // //               workDate.month == _selectedMonth;
// // //         case 'الكل':
// // //         default:
// // //           return true;
// // //       }
// // //     }).toList();
// // //   }

// // //   // ---------------------------
// // //   // تصفية المقاولين حسب البحث
// // //   // ---------------------------
// // //   List<String> _getFilteredContractors() {
// // //     if (_searchContractorQuery.isEmpty) return _contractors;
// // //     return _contractors
// // //         .where(
// // //           (contractor) => contractor.toLowerCase().contains(
// // //             _searchContractorQuery.toLowerCase(),
// // //           ),
// // //         )
// // //         .toList();
// // //   }

// // //   // ---------------------------
// // //   // تصفية السائقين حسب البحث
// // //   // ---------------------------
// // //   List<Map<String, dynamic>> _getFilteredDrivers() {
// // //     if (_searchDriverQuery.isEmpty) return _driversByContractor;
// // //     return _driversByContractor
// // //         .where(
// // //           (driver) => driver['driverName'].toLowerCase().contains(
// // //             _searchDriverQuery.toLowerCase(),
// // //           ),
// // //         )
// // //         .toList();
// // //   }

// // //   // ---------------------------
// // //   // تغيير فلتر الوقت
// // //   // ---------------------------
// // //   void _changeTimeFilter(String filter) {
// // //     setState(() => _timeFilter = filter);
// // //     if (_selectedDriver != null) {
// // //       _filteredDriverWork = _filterWorkByDate(_driverWork);
// // //     }
// // //   }

// // //   // ---------------------------
// // //   // تطبيق فلتر الشهر والسنة
// // //   // ---------------------------
// // //   void _applyMonthYearFilter() {
// // //     setState(() => _timeFilter = 'مخصص');
// // //     if (_selectedDriver != null) {
// // //       _filteredDriverWork = _filterWorkByDate(_driverWork);
// // //     }
// // //   }

// // //   // ---------------------------
// // //   // العودة للخلف
// // //   // ---------------------------
// // //   void _goBack() {
// // //     if (_selectedDriver != null) {
// // //       // العودة لقائمة السائقين
// // //       setState(() {
// // //         _selectedDriver = null;
// // //         _driverWork.clear();
// // //         _filteredDriverWork.clear();
// // //       });
// // //     } else if (_selectedContractor != null) {
// // //       // العودة لقائمة المقاولين
// // //       setState(() {
// // //         _selectedContractor = null;
// // //         _selectedDriver = null;
// // //         _driversByContractor.clear();
// // //         _driverWork.clear();
// // //         _filteredDriverWork.clear();
// // //       });
// // //     }
// // //   }

// // //   // ---------------------------
// // //   // الرسائل
// // //   // ---------------------------
// // //   void _showError(String message) {
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Text(message),
// // //         backgroundColor: Colors.red,
// // //         duration: Duration(seconds: 3),
// // //       ),
// // //     );
// // //   }

// // //   void _showSuccess(String message) {
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Text(message),
// // //         backgroundColor: Colors.green,
// // //         duration: Duration(seconds: 2),
// // //       ),
// // //     );
// // //   }

// // //   String _formatDate(DateTime? date) {
// // //     if (date == null) return '-';
// // //     return DateFormat('dd/MM/yyyy').format(date);
// // //   }

// // //   // ---------------------------
// // //   // AppBar
// // //   // ---------------------------
// // //   Widget _buildCustomAppBar() {
// // //     String title = 'شغل السائقين';

// // //     if (_selectedContractor != null) {
// // //       title = 'المقاول: $_selectedContractor';
// // //     }
// // //     if (_selectedDriver != null) {
// // //       title = 'السائق: $_selectedDriver';
// // //     }

// // //     return Container(
// // //       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// // //       decoration: const BoxDecoration(
// // //         gradient: LinearGradient(
// // //           begin: Alignment.centerRight,
// // //           end: Alignment.centerLeft,
// // //           colors: [Color(0xFF1B4F72), Color(0xFF3498DB)],
// // //         ),
// // //         boxShadow: [
// // //           BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
// // //         ],
// // //       ),
// // //       child: SafeArea(
// // //         bottom: false,
// // //         child: Row(
// // //           children: [
// // //             // زر العودة إذا كان هناك اختيار
// // //             if (_selectedContractor != null || _selectedDriver != null)
// // //               IconButton(
// // //                 icon: Icon(Icons.arrow_back, color: Colors.white),
// // //                 onPressed: _goBack,
// // //               ),

// // //             Icon(Icons.people, color: Colors.white, size: 28),
// // //             SizedBox(width: 12),
// // //             Expanded(
// // //               child: Text(
// // //                 title,
// // //                 style: const TextStyle(
// // //                   color: Colors.white,
// // //                   fontSize: 20,
// // //                   fontWeight: FontWeight.bold,
// // //                 ),
// // //                 overflow: TextOverflow.ellipsis,
// // //               ),
// // //             ),

// // //             // الوقت
// // //             StreamBuilder<DateTime>(
// // //               stream: Stream.periodic(
// // //                 const Duration(seconds: 1),
// // //                 (_) => DateTime.now(),
// // //               ),
// // //               builder: (context, snapshot) {
// // //                 final now = snapshot.data ?? DateTime.now();
// // //                 int hour12 = now.hour % 12;
// // //                 if (hour12 == 0) hour12 = 12;

// // //                 return Container(
// // //                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// // //                   child: Text(
// // //                     '${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
// // //                     style: const TextStyle(
// // //                       color: Colors.white,
// // //                       fontSize: 18,
// // //                       fontWeight: FontWeight.bold,
// // //                     ),
// // //                   ),
// // //                 );
// // //               },
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ---------------------------
// // //   // واجهة اختيار المقاولين
// // //   // ---------------------------
// // //   Widget _buildContractorsList() {
// // //     final filteredContractors = _getFilteredContractors();

// // //     if (_isLoading) {
// // //       return const Center(
// // //         child: CircularProgressIndicator(
// // //           valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
// // //         ),
// // //       );
// // //     }

// // //     return Column(
// // //       children: [
// // //         // حقل البحث
// // //         Container(
// // //           padding: EdgeInsets.all(16),
// // //           child: TextField(
// // //             decoration: InputDecoration(
// // //               hintText: 'ابحث عن مقاول...',
// // //               prefixIcon: Icon(Icons.search, color: Color(0xFF3498DB)),
// // //               border: OutlineInputBorder(
// // //                 borderRadius: BorderRadius.circular(12),
// // //                 borderSide: BorderSide(color: Color(0xFF3498DB)),
// // //               ),
// // //               filled: true,
// // //               fillColor: Colors.white,
// // //               contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
// // //             ),
// // //             onChanged: (value) {
// // //               setState(() {
// // //                 _searchContractorQuery = value;
// // //               });
// // //             },
// // //           ),
// // //         ),

// // //         // قائمة المقاولين
// // //         Expanded(
// // //           child: filteredContractors.isEmpty
// // //               ? Center(
// // //                   child: Column(
// // //                     mainAxisAlignment: MainAxisAlignment.center,
// // //                     children: [
// // //                       Icon(Icons.business, size: 60, color: Colors.grey),
// // //                       SizedBox(height: 16),
// // //                       Text(
// // //                         _searchContractorQuery.isEmpty
// // //                             ? 'لا يوجد مقاولين مسجلين'
// // //                             : 'لا توجد نتائج للبحث',
// // //                         style: TextStyle(color: Colors.grey, fontSize: 16),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 )
// // //               : ListView.builder(
// // //                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// // //                   itemCount: filteredContractors.length,
// // //                   itemBuilder: (context, index) {
// // //                     final contractor = filteredContractors[index];

// // //                     return Container(
// // //                       margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
// // //                       decoration: BoxDecoration(
// // //                         color: Colors.white,
// // //                         borderRadius: BorderRadius.circular(12),
// // //                         border: Border.all(
// // //                           color: Color(0xFF3498DB).withOpacity(0.3),
// // //                         ),
// // //                         boxShadow: [
// // //                           BoxShadow(
// // //                             color: Colors.black12,
// // //                             blurRadius: 4,
// // //                             offset: Offset(0, 2),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       child: ListTile(
// // //                         leading: Container(
// // //                           width: 50,
// // //                           height: 50,
// // //                           decoration: BoxDecoration(
// // //                             color: Color(0xFF3498DB),
// // //                             borderRadius: BorderRadius.circular(25),
// // //                           ),
// // //                           child: Center(
// // //                             child: Text(
// // //                               contractor.substring(0, 1).toUpperCase(),
// // //                               style: TextStyle(
// // //                                 color: Colors.white,
// // //                                 fontSize: 20,
// // //                                 fontWeight: FontWeight.bold,
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ),
// // //                         title: Text(
// // //                           contractor,
// // //                           style: TextStyle(
// // //                             fontWeight: FontWeight.bold,
// // //                             fontSize: 16,
// // //                             color: Color(0xFF2C3E50),
// // //                           ),
// // //                         ),
// // //                         subtitle: Text(
// // //                           'انقر لعرض السائقين',
// // //                           style: TextStyle(color: Colors.grey),
// // //                         ),
// // //                         trailing: Icon(
// // //                           Icons.arrow_forward_ios,
// // //                           color: Color(0xFF3498DB),
// // //                           size: 16,
// // //                         ),
// // //                         onTap: () => _loadDriversByContractor(contractor),
// // //                       ),
// // //                     );
// // //                   },
// // //                 ),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   // ---------------------------
// // //   // واجهة اختيار السائقين
// // //   // ---------------------------
// // //   Widget _buildDriversList() {
// // //     final filteredDrivers = _getFilteredDrivers();

// // //     if (_isLoadingDrivers) {
// // //       return const Center(
// // //         child: CircularProgressIndicator(
// // //           valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
// // //         ),
// // //       );
// // //     }

// // //     return Column(
// // //       children: [
// // //         // شريط البحث
// // //         Container(
// // //           padding: EdgeInsets.all(16),
// // //           child: TextField(
// // //             decoration: InputDecoration(
// // //               hintText: 'ابحث عن سائق...',
// // //               prefixIcon: Icon(Icons.search, color: Color(0xFF3498DB)),
// // //               border: OutlineInputBorder(
// // //                 borderRadius: BorderRadius.circular(12),
// // //                 borderSide: BorderSide(color: Color(0xFF3498DB)),
// // //               ),
// // //               filled: true,
// // //               fillColor: Colors.white,
// // //               contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
// // //             ),
// // //             onChanged: (value) {
// // //               setState(() {
// // //                 _searchDriverQuery = value;
// // //               });
// // //             },
// // //           ),
// // //         ),

// // //         // معلومات المقاول
// // //         Container(
// // //           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // //           child: Row(
// // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //             children: [
// // //               Text(
// // //                 'عدد السائقين: ${filteredDrivers.length}',
// // //                 style: TextStyle(
// // //                   color: Color(0xFF3498DB),
// // //                   fontWeight: FontWeight.bold,
// // //                 ),
// // //               ),
// // //               Container(
// // //                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// // //                 decoration: BoxDecoration(
// // //                   color: Color(0xFF3498DB).withOpacity(0.1),
// // //                   borderRadius: BorderRadius.circular(20),
// // //                 ),
// // //                 child: Text(
// // //                   'المقاول: $_selectedContractor',
// // //                   style: TextStyle(
// // //                     color: Color(0xFF3498DB),
// // //                     fontWeight: FontWeight.bold,
// // //                   ),
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ),

// // //         // قائمة السائقين
// // //         Expanded(
// // //           child: filteredDrivers.isEmpty
// // //               ? Center(
// // //                   child: Column(
// // //                     mainAxisAlignment: MainAxisAlignment.center,
// // //                     children: [
// // //                       Icon(Icons.person_off, size: 60, color: Colors.grey),
// // //                       SizedBox(height: 16),
// // //                       Text(
// // //                         _searchDriverQuery.isEmpty
// // //                             ? 'لا يوجد سائقين لهذا المقاول'
// // //                             : 'لا توجد نتائج للبحث',
// // //                         style: TextStyle(color: Colors.grey, fontSize: 16),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 )
// // //               : ListView.builder(
// // //                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// // //                   itemCount: filteredDrivers.length,
// // //                   itemBuilder: (context, index) {
// // //                     final driver = filteredDrivers[index];

// // //                     return Container(
// // //                       margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
// // //                       decoration: BoxDecoration(
// // //                         color: Colors.white,
// // //                         borderRadius: BorderRadius.circular(12),
// // //                         border: Border.all(color: Colors.grey[300]!),
// // //                         boxShadow: [
// // //                           BoxShadow(
// // //                             color: Colors.black12,
// // //                             blurRadius: 2,
// // //                             offset: Offset(0, 1),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       child: ListTile(
// // //                         leading: CircleAvatar(
// // //                           backgroundColor: Color(0xFF3498DB),
// // //                           child: Text(
// // //                             driver['driverName'].substring(0, 1).toUpperCase(),
// // //                             style: TextStyle(
// // //                               color: Colors.white,
// // //                               fontWeight: FontWeight.bold,
// // //                             ),
// // //                           ),
// // //                         ),
// // //                         title: Text(
// // //                           driver['driverName'],
// // //                           style: TextStyle(
// // //                             fontWeight: FontWeight.bold,
// // //                             fontSize: 16,
// // //                           ),
// // //                         ),
// // //                         subtitle: Column(
// // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // //                           children: [
// // //                             SizedBox(height: 4),
// // //                             Row(
// // //                               children: [
// // //                                 Icon(
// // //                                   Icons.directions_car,
// // //                                   size: 14,
// // //                                   color: Colors.grey,
// // //                                 ),
// // //                                 SizedBox(width: 4),
// // //                                 Text(
// // //                                   '${driver['totalTrips']} رحلة',
// // //                                   style: TextStyle(fontSize: 12),
// // //                                 ),
// // //                               ],
// // //                             ),
// // //                           ],
// // //                         ),
// // //                         trailing: Icon(
// // //                           Icons.arrow_forward_ios,
// // //                           color: Color(0xFF3498DB),
// // //                           size: 16,
// // //                         ),
// // //                         onTap: () => _loadDriverWork(driver['driverName']),
// // //                       ),
// // //                     );
// // //                   },
// // //                 ),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   // ---------------------------
// // //   // واجهة جدول شغل السائق - من الكود القديم (بدون تغييرات)
// // //   // ---------------------------
// // //   Widget _buildWorkTable() {
// // //     if (_isLoadingWork) return const Center(child: CircularProgressIndicator());

// // //     return Column(
// // //       children: [
// // //         Container(
// // //           padding: const EdgeInsets.all(12),
// // //           color: Colors.blue[50],
// // //           child: Row(
// // //             mainAxisAlignment: MainAxisAlignment.center,
// // //             children: [
// // //               Icon(Icons.filter_alt, color: Colors.blue[700], size: 16),
// // //               const SizedBox(width: 8),
// // //               Text(
// // //                 _getFilterText(),
// // //                 style: TextStyle(
// // //                   color: Colors.blue[700],
// // //                   fontWeight: FontWeight.bold,
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //         Expanded(
// // //           child: Container(
// // //             margin: const EdgeInsets.all(16),
// // //             child: _filteredDriverWork.isEmpty
// // //                 ? Center(
// // //                     child: Column(
// // //                       mainAxisAlignment: MainAxisAlignment.center,
// // //                       children: [
// // //                         const Icon(
// // //                           Icons.work_off,
// // //                           size: 60,
// // //                           color: Colors.grey,
// // //                         ),
// // //                         const SizedBox(height: 16),
// // //                         Text(
// // //                           _driverWork.isEmpty
// // //                               ? 'لا يوجد شغل مسجل لهذا السائق'
// // //                               : 'لا يوجد شغل في الفترة المحددة',
// // //                           style: const TextStyle(
// // //                             color: Colors.grey,
// // //                             fontSize: 18,
// // //                             fontWeight: FontWeight.bold,
// // //                           ),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   )
// // //                 : SingleChildScrollView(
// // //                     scrollDirection: Axis.horizontal,
// // //                     child: SingleChildScrollView(
// // //                       scrollDirection: Axis.vertical,
// // //                       child: Table(
// // //                         defaultColumnWidth: const FixedColumnWidth(120),
// // //                         border: TableBorder.all(
// // //                           color: const Color(0xFF3498DB),
// // //                           width: 1,
// // //                         ),
// // //                         children: [
// // //                           TableRow(
// // //                             decoration: BoxDecoration(
// // //                               color: const Color(0xFF3498DB).withOpacity(0.15),
// // //                             ),
// // //                             children: const [
// // //                               TableCellHeader('عطلة العجل'),
// // //                               TableCellHeader('مبيت العجل'),
// // //                               TableCellHeader('نولون العجل'),
// // //                               // العمود المضاف
// // //                               TableCellHeader('الكارتة'),
// // //                               TableCellHeader('العهدة'),
// // //                               TableCellHeader('اسم الموقع'),
// // //                               TableCellHeader('مكان التعتيق'),
// // //                               TableCellHeader('مكان التحميل'),
// // //                               TableCellHeader('التاريخ'),
// // //                               TableCellHeader('م'),
// // //                             ],
// // //                           ),
// // //                           ..._filteredDriverWork.asMap().entries.map((entry) {
// // //                             final index = entry.key;
// // //                             final work = entry.value;
// // //                             final totalNolonRow =
// // //                                 (work['wheelNolon'] ?? 0.0) +
// // //                                 (work['wheelOvernight'] ?? 0.0) +
// // //                                 (work['wheelHoliday'] ?? 0.0);

// // //                             return TableRow(
// // //                               decoration: BoxDecoration(
// // //                                 color: index.isEven
// // //                                     ? Colors.white
// // //                                     : const Color(0xFFF8F9FA),
// // //                               ),
// // //                               children: [
// // //                                 TableCellBody(
// // //                                   '${work['wheelHoliday']} ج',
// // //                                   textStyle: const TextStyle(
// // //                                     fontWeight: FontWeight.bold,
// // //                                     color: Colors.red,
// // //                                   ),
// // //                                 ),
// // //                                 TableCellBody(
// // //                                   '${work['wheelOvernight']} ج',
// // //                                   textStyle: const TextStyle(
// // //                                     fontWeight: FontWeight.bold,
// // //                                   ),
// // //                                 ),
// // //                                 TableCellBody(
// // //                                   '${work['wheelNolon']} ج',
// // //                                   textStyle: const TextStyle(
// // //                                     fontWeight: FontWeight.bold,
// // //                                     color: Colors.green,
// // //                                   ),
// // //                                 ),
// // //                                 // TableCellBody(
// // //                                 //   '${totalNolonRow.toStringAsFixed(2)} ج',
// // //                                 //   textStyle: const TextStyle(
// // //                                 //     fontWeight: FontWeight.bold,
// // //                                 //     color: Colors.blue,
// // //                                 //   ),
// // //                                 // ), // إجمالي النولون للسطر
// // //                                 TableCellBody(work['karta']),
// // //                                 TableCellBody(work['ohda']),
// // //                                 TableCellBody(
// // //                                   work['selectedRoute'],
// // //                                   textStyle: const TextStyle(
// // //                                     fontWeight: FontWeight.bold,
// // //                                     color: Color(0xFF3498DB),
// // //                                   ),
// // //                                 ),
// // //                                 TableCellBody(work['unloadingLocation']),
// // //                                 TableCellBody(work['loadingLocation']),
// // //                                 TableCellBody(_formatDate(work['date'])),
// // //                                 TableCellBody('${index + 1}'),
// // //                               ],
// // //                             );
// // //                           }),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   ),
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   String _getFilterText() {
// // //     switch (_timeFilter) {
// // //       case 'اليوم':
// // //         return 'عرض رحلات اليوم';
// // //       case 'هذا الشهر':
// // //         return 'عرض رحلات هذا الشهر';
// // //       case 'هذه السنة':
// // //         return 'عرض رحلات هذه السنة';
// // //       case 'مخصص':
// // //         return 'عرض رحلات شهر $_selectedMonth سنة $_selectedYear';
// // //       default:
// // //         return 'عرض جميع الرحلات';
// // //     }
// // //   }

// // //   // ---------------------------
// // //   // قسم فلتر الوقت - من الكود القديم
// // //   // ---------------------------
// // //   Widget _buildTimeFilterSection() {
// // //     return Container(
// // //       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
// // //       color: Colors.white,
// // //       child: Column(
// // //         children: [
// // //           TextField(
// // //             decoration: InputDecoration(
// // //               hintText: 'ابحث باسم السائق',
// // //               prefixIcon: const Icon(Icons.search, color: Color(0xFF3498DB)),
// // //               border: OutlineInputBorder(
// // //                 borderRadius: BorderRadius.circular(12),
// // //               ),
// // //               contentPadding: const EdgeInsets.symmetric(
// // //                 vertical: 0,
// // //                 horizontal: 12,
// // //               ),
// // //             ),
// // //             onChanged: (value) {
// // //               setState(() {
// // //                 _searchDriverQuery = value;
// // //               });
// // //             },
// // //           ),
// // //           const SizedBox(height: 12),
// // //           Row(
// // //             mainAxisAlignment: MainAxisAlignment.center,
// // //             children: [
// // //               const Icon(Icons.calendar_month, color: Color(0xFF3498DB)),
// // //               const SizedBox(width: 8),
// // //               DropdownButton<int>(
// // //                 value: _selectedMonth,
// // //                 onChanged: (value) {
// // //                   if (value != null) {
// // //                     setState(() => _selectedMonth = value);
// // //                     _applyMonthYearFilter();
// // //                   }
// // //                 },
// // //                 items: List.generate(12, (index) {
// // //                   final monthNumber = index + 1;
// // //                   return DropdownMenuItem(
// // //                     value: monthNumber,
// // //                     child: Text('شهر $monthNumber'),
// // //                   );
// // //                 }),
// // //               ),
// // //               const SizedBox(width: 20),
// // //               DropdownButton<int>(
// // //                 value: _selectedYear,
// // //                 onChanged: (value) {
// // //                   if (value != null) {
// // //                     setState(() => _selectedYear = value);
// // //                     _applyMonthYearFilter();
// // //                   }
// // //                 },
// // //                 items: [
// // //                   for (
// // //                     int i = DateTime.now().year - 2;
// // //                     i <= DateTime.now().year + 2;
// // //                     i++
// // //                   )
// // //                     DropdownMenuItem(value: i, child: Text('$i')),
// // //                 ],
// // //               ),
// // //             ],
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // ---------------------------
// // //   // الواجهة الرئيسية
// // //   // ---------------------------
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: Color(0xFFF4F6F8),
// // //       body: Column(
// // //         children: [
// // //           _buildCustomAppBar(),
// // //           if (_selectedDriver == null && _selectedContractor == null)
// // //             _buildTimeFilterSection(),
// // //           Expanded(
// // //             child: _selectedDriver != null
// // //                 ? _buildWorkTable() // جدول شغل السائق (من الكود القديم)
// // //                 : (_selectedContractor != null
// // //                       ? _buildDriversList()
// // //                       : _buildContractorsList()),
// // //           ),
// // //         ],
// // //       ),
// // //       floatingActionButton: FloatingActionButton(
// // //         onPressed: () {
// // //           if (_selectedDriver != null) {
// // //             _loadDriverWork(_selectedDriver!);
// // //           } else if (_selectedContractor != null) {
// // //             _loadDriversByContractor(_selectedContractor!);
// // //           } else {
// // //             _loadContractors();
// // //           }
// // //         },
// // //         backgroundColor: Color(0xFF3498DB),
// // //         tooltip: 'تحديث',
// // //         child: Icon(Icons.refresh, color: Colors.white),
// // //       ),
// // //     );
// // //   }
// // // }

// // // // ===== TableCellHeader & TableCellBody components =====
// // // class TableCellHeader extends StatelessWidget {
// // //   final String text;
// // //   const TableCellHeader(this.text, {super.key});
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Container(
// // //       height: 50,
// // //       alignment: Alignment.center,
// // //       padding: const EdgeInsets.symmetric(horizontal: 8),
// // //       child: Text(
// // //         text,
// // //         style: const TextStyle(
// // //           fontWeight: FontWeight.bold,
// // //           fontSize: 14,
// // //           color: Color(0xFF2C3E50),
// // //         ),
// // //         textAlign: TextAlign.center,
// // //       ),
// // //     );
// // //   }
// // // }

// // // class TableCellBody extends StatelessWidget {
// // //   final String text;
// // //   final TextStyle? textStyle;
// // //   const TableCellBody(this.text, {this.textStyle, super.key});
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Container(
// // //       height: 48,
// // //       alignment: Alignment.center,
// // //       padding: const EdgeInsets.symmetric(horizontal: 8),
// // //       child: Text(
// // //         text,
// // //         maxLines: 2,
// // //         overflow: TextOverflow.ellipsis,
// // //         textAlign: TextAlign.center,
// // //         style: textStyle ?? const TextStyle(fontSize: 14),
// // //       ),
// // //     );
// // //   }
// // // }
// // import 'dart:async';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import 'package:pdf/pdf.dart';
// // import 'package:pdf/widgets.dart' as pdfLib;
// // import 'package:printing/printing.dart';
// // import 'package:flutter/services.dart';

// // class DriverWorkPage extends StatefulWidget {
// //   const DriverWorkPage({super.key});

// //   @override
// //   State<DriverWorkPage> createState() => _DriverWorkPageState();
// // }

// // class _DriverWorkPageState extends State<DriverWorkPage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// //   // البيانات الأساسية
// //   List<String> _contractors = []; // قائمة المقاولين
// //   List<Map<String, dynamic>> _driversByContractor = []; // السائقين حسب المقاول

// //   // بيانات شغل السائق
// //   List<Map<String, dynamic>> _driverWork = [];
// //   List<Map<String, dynamic>> _filteredDriverWork = [];

// //   // حالات التحديد
// //   String? _selectedContractor;
// //   String? _selectedDriver;

// //   // حالات التحميل
// //   bool _isLoading = false;
// //   bool _isLoadingDrivers = false;
// //   bool _isLoadingWork = false;
// //   bool _isGeneratingPDF = false;

// //   // الفلاتر
// //   String _searchContractorQuery = '';
// //   String _searchDriverQuery = '';
// //   String _timeFilter = 'الكل';
// //   int _selectedMonth = DateTime.now().month;
// //   int _selectedYear = DateTime.now().year;

// //   // للطباعة
// //   pdfLib.Font? _arabicFont;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadContractors();
// //     _loadArabicFont();
// //   }

// //   // تحميل الخط العربي للطباعة
// //   Future<void> _loadArabicFont() async {
// //     try {
// //       final fontData = await rootBundle.load(
// //         'assets/fonts/Amiri/Amiri-Regular.ttf',
// //       );
// //       _arabicFont = pdfLib.Font.ttf(fontData);
// //     } catch (e) {
// //       debugPrint('فشل تحميل الخط العربي: $e');
// //     }
// //   }

// //   // ---------------------------
// //   // تحميل قائمة المقاولين
// //   // ---------------------------
// //   Future<void> _loadContractors() async {
// //     setState(() => _isLoading = true);
// //     try {
// //       final snapshot = await _firestore.collection('drivers').get();

// //       // استخراج المقاولين الفريدين
// //       Set<String> contractorsSet = {};

// //       for (final doc in snapshot.docs) {
// //         final data = doc.data();
// //         final contractor = (data['contractor'] ?? '').toString().trim();
// //         if (contractor.isNotEmpty) {
// //           contractorsSet.add(contractor);
// //         }
// //       }

// //       // تحويل إلى قائمة وترتيب أبجدي
// //       List<String> contractorsList = contractorsSet.toList()..sort();

// //       setState(() {
// //         _contractors = contractorsList;
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() => _isLoading = false);
// //       _showError('خطأ في تحميل المقاولين: $e');
// //     }
// //   }

// //   // ---------------------------
// //   // تحميل السائقين التابعين لمقاول محدد
// //   // ---------------------------
// //   Future<void> _loadDriversByContractor(String contractor) async {
// //     if (contractor.isEmpty) return;

// //     setState(() {
// //       _selectedContractor = contractor;
// //       _isLoadingDrivers = true;
// //       _driversByContractor.clear();
// //       _selectedDriver = null;
// //       _driverWork.clear();
// //       _filteredDriverWork.clear();
// //     });

// //     try {
// //       final snapshot = await _firestore
// //           .collection('drivers')
// //           .where('contractor', isEqualTo: contractor)
// //           .get();

// //       // تجميع السائقين الفريدين
// //       Map<String, Map<String, dynamic>> driversMap = {};

// //       for (final doc in snapshot.docs) {
// //         final data = doc.data();
// //         final driverName = (data['driverName'] ?? '').toString().trim();
// //         if (driverName.isEmpty) continue;

// //         if (!driversMap.containsKey(driverName)) {
// //           driversMap[driverName] = {
// //             'driverName': driverName,
// //             'contractor': contractor,
// //             'totalTrips': 0,
// //             'lastTripDate': null,
// //           };
// //         }

// //         final driverData = driversMap[driverName]!;

// //         // تحديث الإحصائيات
// //         driverData['totalTrips'] = driverData['totalTrips']! + 1;

// //         // تاريخ آخر رحلة
// //         final tripDate = (data['date'] as Timestamp?)?.toDate();
// //         if (tripDate != null) {
// //           if (driverData['lastTripDate'] == null ||
// //               tripDate.isAfter(driverData['lastTripDate'])) {
// //             driverData['lastTripDate'] = tripDate;
// //           }
// //         }
// //       }

// //       // تحويل القائمة وترتيب أبجدي
// //       List<Map<String, dynamic>> driversList = driversMap.values.toList();
// //       driversList.sort((a, b) => a['driverName'].compareTo(b['driverName']));

// //       setState(() {
// //         _driversByContractor = driversList;
// //         _isLoadingDrivers = false;
// //       });
// //     } catch (e) {
// //       setState(() => _isLoadingDrivers = false);
// //       _showError('خطأ في تحميل السائقين: $e');
// //     }
// //   }

// //   // ---------------------------
// //   // تحميل شغل سائق محدد
// //   // ---------------------------
// //   Future<void> _loadDriverWork(String driverName) async {
// //     setState(() {
// //       _selectedDriver = driverName;
// //       _isLoadingWork = true;
// //       _driverWork.clear();
// //       _filteredDriverWork.clear();
// //     });

// //     try {
// //       final snapshot = await _firestore
// //           .collection('drivers')
// //           .where('driverName', isEqualTo: driverName)
// //           .orderBy('date', descending: true)
// //           .get();

// //       List<Map<String, dynamic>> workList = [];

// //       for (final doc in snapshot.docs) {
// //         final data = doc.data();
// //         DateTime? date = (data['date'] as Timestamp?)?.toDate();

// //         workList.add({
// //           'id': doc.id,
// //           'date': date,
// //           'companyName': data['companyName'] ?? 'غير معروف',
// //           'loadingLocation': data['loadingLocation'] ?? '',
// //           'unloadingLocation': data['unloadingLocation'] ?? '',
// //           'selectedRoute': data['selectedRoute'] ?? '',
// //           'ohda': data['ohda'] ?? '',
// //           'karta': data['karta'] ?? '',
// //           'wheelNolon': (data['wheelNolon'] ?? 0).toDouble(),
// //           'wheelOvernight': (data['wheelOvernight'] ?? 0).toDouble(),
// //           'wheelHoliday': (data['wheelHoliday'] ?? 0).toDouble(),
// //           'selectedPrice': (data['selectedPrice'] ?? 0).toDouble(),
// //           'isPaid': data['isPaid'] ?? false,
// //           'paidAmount': (data['paidAmount'] ?? 0).toDouble(),
// //           'remainingAmount': (data['remainingAmount'] ?? 0).toDouble(),
// //           'paymentDate': data['paymentDate'] as Timestamp?,
// //           'driverNotes': data['driverNotes'] ?? '',
// //         });
// //       }

// //       setState(() {
// //         _driverWork = workList;
// //         _filteredDriverWork = _filterWorkByDate(workList);
// //         _isLoadingWork = false;
// //       });
// //     } catch (e) {
// //       setState(() => _isLoadingWork = false);
// //       _showError('خطأ في تحميل الشغل');
// //     }
// //   }

// //   // ---------------------------
// //   // تصفية الشغل حسب التاريخ
// //   // ---------------------------
// //   List<Map<String, dynamic>> _filterWorkByDate(
// //     List<Map<String, dynamic>> workList,
// //   ) {
// //     return workList.where((work) {
// //       final workDate = work['date'] as DateTime?;
// //       if (workDate == null) return false;
// //       final now = DateTime.now();
// //       switch (_timeFilter) {
// //         case 'اليوم':
// //           return workDate.year == now.year &&
// //               workDate.month == now.month &&
// //               workDate.day == now.day;
// //         case 'هذا الشهر':
// //           return workDate.year == now.year && workDate.month == now.month;
// //         case 'هذه السنة':
// //           return workDate.year == now.year;
// //         case 'مخصص':
// //           return workDate.year == _selectedYear &&
// //               workDate.month == _selectedMonth;
// //         case 'الكل':
// //         default:
// //           return true;
// //       }
// //     }).toList();
// //   }

// //   // ---------------------------
// //   // تصفية المقاولين حسب البحث
// //   // ---------------------------
// //   List<String> _getFilteredContractors() {
// //     if (_searchContractorQuery.isEmpty) return _contractors;
// //     return _contractors
// //         .where(
// //           (contractor) => contractor.toLowerCase().contains(
// //             _searchContractorQuery.toLowerCase(),
// //           ),
// //         )
// //         .toList();
// //   }

// //   // ---------------------------
// //   // تصفية السائقين حسب البحث
// //   // ---------------------------
// //   List<Map<String, dynamic>> _getFilteredDrivers() {
// //     if (_searchDriverQuery.isEmpty) return _driversByContractor;
// //     return _driversByContractor
// //         .where(
// //           (driver) => driver['driverName'].toLowerCase().contains(
// //             _searchDriverQuery.toLowerCase(),
// //           ),
// //         )
// //         .toList();
// //   }

// //   // ---------------------------
// //   // تغيير فلتر الوقت
// //   // ---------------------------
// //   void _changeTimeFilter(String filter) {
// //     setState(() => _timeFilter = filter);
// //     if (_selectedDriver != null) {
// //       _filteredDriverWork = _filterWorkByDate(_driverWork);
// //     }
// //   }

// //   // ---------------------------
// //   // تطبيق فلتر الشهر والسنة
// //   // ---------------------------
// //   void _applyMonthYearFilter() {
// //     setState(() => _timeFilter = 'مخصص');
// //     if (_selectedDriver != null) {
// //       _filteredDriverWork = _filterWorkByDate(_driverWork);
// //     }
// //   }

// //   // ---------------------------
// //   // العودة للخلف
// //   // ---------------------------
// //   void _goBack() {
// //     if (_selectedDriver != null) {
// //       // العودة لقائمة السائقين
// //       setState(() {
// //         _selectedDriver = null;
// //         _driverWork.clear();
// //         _filteredDriverWork.clear();
// //       });
// //     } else if (_selectedContractor != null) {
// //       // العودة لقائمة المقاولين
// //       setState(() {
// //         _selectedContractor = null;
// //         _selectedDriver = null;
// //         _driversByContractor.clear();
// //         _driverWork.clear();
// //         _filteredDriverWork.clear();
// //       });
// //     }
// //   }

// //   // ---------------------------
// //   // إنشاء PDF للتقرير
// //   // ---------------------------
// //   Future<void> _generatePDF() async {
// //     if (_arabicFont == null) {
// //       _showError('الخط العربي غير محمل');
// //       return;
// //     }

// //     if (_selectedDriver == null || _filteredDriverWork.isEmpty) {
// //       _showError('لا توجد بيانات للطباعة');
// //       return;
// //     }

// //     setState(() => _isGeneratingPDF = true);

// //     try {
// //       // حساب الإجماليات
// //       double totalKarta = 0;
// //       double totalOhda = 0;
// //       double totalNolon = 0;
// //       double totalOvernight = 0;
// //       double totalHoliday = 0;
// //       int totalTrips = _filteredDriverWork.length;

// //       for (final work in _filteredDriverWork) {
// //         totalKarta += _parseToDouble(work['karta']);
// //         totalOhda += _parseToDouble(work['ohda']);
// //         totalNolon += _parseToDouble(work['wheelNolon']);
// //         totalOvernight += _parseToDouble(work['wheelOvernight']);
// //         totalHoliday += _parseToDouble(work['wheelHoliday']);
// //       }

// //       double netAmount =
// //           (totalKarta + totalNolon + totalOvernight + totalHoliday) - totalOhda;

// //       // إنشاء PDF
// //       final pdf = pdfLib.Document(
// //         theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
// //       );

// //       pdf.addPage(
// //         pdfLib.MultiPage(
// //           pageFormat: PdfPageFormat.a4,
// //           margin: pdfLib.EdgeInsets.all(20),
// //           build: (context) => [
// //             // العنوان الرئيسي
// //             pdfLib.Directionality(
// //               textDirection: pdfLib.TextDirection.rtl,
// //               child: pdfLib.Column(
// //                 children: [
// //                   pdfLib.Row(
// //                     mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       pdfLib.Text(
// //                         'تقرير شغل السائقين',
// //                         style: pdfLib.TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: pdfLib.FontWeight.bold,
// //                           font: _arabicFont,
// //                           color: PdfColors.black,
// //                         ),
// //                       ),
// //                       pdfLib.Text(
// //                         DateFormat('yyyy/MM/dd').format(DateTime.now()),
// //                         style: pdfLib.TextStyle(
// //                           fontSize: 10,
// //                           font: _arabicFont,
// //                           color: PdfColors.grey,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   pdfLib.Divider(color: PdfColors.black, thickness: 1),
// //                 ],
// //               ),
// //             ),
// //             pdfLib.SizedBox(height: 10),

// //             // معلومات السائق
// //             _buildDriverInfoPdf(
// //               _selectedDriver!,
// //               totalTrips,
// //               netAmount,
// //               _selectedContractor ?? '',
// //             ),
// //             pdfLib.SizedBox(height: 15),

// //             // الجدول
// //             _buildPdfTable(_filteredDriverWork),
// //             pdfLib.SizedBox(height: 10),

// //             // الملخص
// //             _buildSummaryPdf(
// //               totalKarta,
// //               totalOhda,
// //               totalNolon,
// //               totalOvernight,
// //               totalHoliday,
// //               netAmount,
// //             ),
// //           ],
// //         ),
// //       );

// //       // طباعة PDF
// //       await Printing.layoutPdf(
// //         onLayout: (PdfPageFormat format) async => pdf.save(),
// //         name: _getPDFFileName(),
// //       );
// //     } catch (e) {
// //       _showError('حدث خطأ في إنشاء PDF: $e');
// //     } finally {
// //       setState(() => _isGeneratingPDF = false);
// //     }
// //   }

// //   // دالة مساعدة لتحويل إلى double
// //   double _parseToDouble(dynamic value) {
// //     if (value == null) return 0.0;
// //     if (value is num) return value.toDouble();
// //     if (value is String) {
// //       try {
// //         return double.tryParse(value) ?? 0.0;
// //       } catch (e) {
// //         return 0.0;
// //       }
// //     }
// //     return 0.0;
// //   }

// //   // بناء معلومات السائق للPDF
// //   pdfLib.Widget _buildDriverInfoPdf(
// //     String driverName,
// //     int totalTrips,
// //     double netAmount,
// //     String contractor,
// //   ) {
// //     return pdfLib.Directionality(
// //       textDirection: pdfLib.TextDirection.rtl,
// //       child: pdfLib.Container(
// //         padding: pdfLib.EdgeInsets.all(8),
// //         decoration: pdfLib.BoxDecoration(
// //           border: pdfLib.Border.all(color: PdfColors.blue, width: 0.5),
// //           borderRadius: pdfLib.BorderRadius.circular(5),
// //         ),
// //         child: pdfLib.Column(
// //           crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
// //           children: [
// //             // اسم السائق وعدد الرحلات في نفس السطر
// //             pdfLib.Row(
// //               mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
// //               children: [
// //                 pdfLib.Text(
// //                   'اسم السائق: $driverName',
// //                   style: pdfLib.TextStyle(
// //                     fontSize: 12,
// //                     fontWeight: pdfLib.FontWeight.bold,
// //                     font: _arabicFont,
// //                     color: PdfColors.black,
// //                   ),
// //                 ),
// //                 pdfLib.Text(
// //                   'عدد الرحلات: $totalTrips',
// //                   style: pdfLib.TextStyle(
// //                     fontSize: 10,
// //                     font: _arabicFont,
// //                     color: PdfColors.blue,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             pdfLib.SizedBox(height: 4),

// //             // الصافي في السطر الثاني
// //             pdfLib.Row(
// //               mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
// //               children: [
// //                 pdfLib.Text(
// //                   'الصافي: ${netAmount.toStringAsFixed(2)} ج',
// //                   style: pdfLib.TextStyle(
// //                     fontSize: 12,
// //                     fontWeight: pdfLib.FontWeight.bold,
// //                     font: _arabicFont,
// //                     color: netAmount >= 0 ? PdfColors.green : PdfColors.red,
// //                   ),
// //                 ),
// //                 if (contractor.isNotEmpty)
// //                   pdfLib.Text(
// //                     'المقاول: $contractor',
// //                     style: pdfLib.TextStyle(
// //                       fontSize: 10,
// //                       font: _arabicFont,
// //                       color: PdfColors.grey,
// //                     ),
// //                   ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // بناء الجدول في PDF
// //   pdfLib.Widget _buildPdfTable(List<Map<String, dynamic>> workList) {
// //     return pdfLib.Directionality(
// //       textDirection: pdfLib.TextDirection.rtl,
// //       child: pdfLib.Table.fromTextArray(
// //         border: pdfLib.TableBorder.all(color: PdfColors.grey, width: 0.5),
// //         cellAlignment: pdfLib.Alignment.center,
// //         headerDecoration: pdfLib.BoxDecoration(color: PdfColors.grey200),
// //         headerStyle: pdfLib.TextStyle(
// //           fontSize: 9,
// //           fontWeight: pdfLib.FontWeight.bold,
// //           font: _arabicFont,
// //           color: PdfColors.black,
// //         ),
// //         cellStyle: pdfLib.TextStyle(
// //           fontSize: 8,
// //           font: _arabicFont,
// //           color: PdfColors.black,
// //         ),
// //         cellAlignments: {
// //           0: pdfLib.Alignment.center, // م
// //           1: pdfLib.Alignment.center, // التاريخ
// //           2: pdfLib.Alignment.center, // من
// //           3: pdfLib.Alignment.center, // إلى
// //           4: pdfLib.Alignment.center, // العهدة
// //           5: pdfLib.Alignment.center, // الكارتة
// //           6: pdfLib.Alignment.center, // النولون
// //           7: pdfLib.Alignment.center, // المبيت
// //           8: pdfLib.Alignment.center, // العطلة
// //         },
// //         columnWidths: {
// //           0: pdfLib.FlexColumnWidth(0.4), // م
// //           1: pdfLib.FlexColumnWidth(1.0), // التاريخ
// //           2: pdfLib.FlexColumnWidth(1.2), // من
// //           3: pdfLib.FlexColumnWidth(1.2), // إلى
// //           4: pdfLib.FlexColumnWidth(0.8), // العهدة
// //           5: pdfLib.FlexColumnWidth(0.8), // الكارتة
// //           6: pdfLib.FlexColumnWidth(0.8), // النولون
// //           7: pdfLib.FlexColumnWidth(0.8), // المبيت
// //           8: pdfLib.FlexColumnWidth(0.8), // العطلة
// //         },
// //         headers: [
// //           'م',
// //           'التاريخ',
// //           'من',
// //           'إلى',
// //           'العهدة',
// //           'الكارتة',
// //           'النولون',
// //           'المبيت',
// //           'العطلة',
// //         ],
// //         data: List<List<String>>.generate(workList.length, (index) {
// //           final work = workList[index];
// //           final date = work['date'] as DateTime?;
// //           return [
// //             (index + 1).toString(),
// //             date != null ? DateFormat('dd/MM/yy').format(date) : '-',
// //             work['loadingLocation'] ?? '',
// //             work['unloadingLocation'] ?? '',
// //             _parseToDouble(work['ohda']).toStringAsFixed(2),
// //             _parseToDouble(work['karta']).toStringAsFixed(2),
// //             _parseToDouble(work['wheelNolon']).toStringAsFixed(2),
// //             _parseToDouble(work['wheelOvernight']).toStringAsFixed(2),
// //             _parseToDouble(work['wheelHoliday']).toStringAsFixed(2),
// //           ];
// //         }),
// //       ),
// //     );
// //   }

// //   // بناء ملخص الإجماليات للPDF
// //   pdfLib.Widget _buildSummaryPdf(
// //     double totalKarta,
// //     double totalOhda,
// //     double totalNolon,
// //     double totalOvernight,
// //     double totalHoliday,
// //     double netAmount,
// //   ) {
// //     return pdfLib.Directionality(
// //       textDirection: pdfLib.TextDirection.rtl,
// //       child: pdfLib.Container(
// //         padding: pdfLib.EdgeInsets.all(8),
// //         decoration: pdfLib.BoxDecoration(
// //           border: pdfLib.Border.all(color: PdfColors.black, width: 0.5),
// //           borderRadius: pdfLib.BorderRadius.circular(5),
// //         ),
// //         child: pdfLib.Column(
// //           crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
// //           children: [
// //             pdfLib.Text(
// //               'ملخص الإجماليات',
// //               style: pdfLib.TextStyle(
// //                 fontSize: 10,
// //                 fontWeight: pdfLib.FontWeight.bold,
// //                 font: _arabicFont,
// //                 color: PdfColors.black,
// //               ),
// //             ),
// //             pdfLib.SizedBox(height: 5),
// //             pdfLib.Row(
// //               mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
// //               children: [
// //                 pdfLib.Text(
// //                   'إجمالي الكارتة: ${totalKarta.toStringAsFixed(2)} ج',
// //                   style: pdfLib.TextStyle(
// //                     fontSize: 8,
// //                     font: _arabicFont,
// //                     color: PdfColors.black,
// //                   ),
// //                 ),
// //                 pdfLib.Text(
// //                   'إجمالي العهدة: ${totalOhda.toStringAsFixed(2)} ج',
// //                   style: pdfLib.TextStyle(
// //                     fontSize: 8,
// //                     font: _arabicFont,
// //                     color: PdfColors.red,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             pdfLib.SizedBox(height: 3),
// //             pdfLib.Row(
// //               mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
// //               children: [
// //                 pdfLib.Text(
// //                   'إجمالي النولون: ${totalNolon.toStringAsFixed(2)} ج',
// //                   style: pdfLib.TextStyle(
// //                     fontSize: 8,
// //                     font: _arabicFont,
// //                     color: PdfColors.green,
// //                   ),
// //                 ),
// //                 pdfLib.Text(
// //                   'إجمالي المبيت: ${totalOvernight.toStringAsFixed(2)} ج',
// //                   style: pdfLib.TextStyle(
// //                     fontSize: 8,
// //                     font: _arabicFont,
// //                     color: PdfColors.blue,
// //                   ),
// //                 ),
// //                 pdfLib.Text(
// //                   'إجمالي العطلة: ${totalHoliday.toStringAsFixed(2)} ج',
// //                   style: pdfLib.TextStyle(
// //                     fontSize: 8,
// //                     font: _arabicFont,
// //                     color: PdfColors.orange,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             pdfLib.SizedBox(height: 5),
// //             pdfLib.Divider(color: PdfColors.grey, thickness: 0.5),
// //             pdfLib.Row(
// //               mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
// //               children: [
// //                 pdfLib.Text(
// //                   'الصافي النهائي:',
// //                   style: pdfLib.TextStyle(
// //                     fontSize: 10,
// //                     fontWeight: pdfLib.FontWeight.bold,
// //                     font: _arabicFont,
// //                     color: PdfColors.black,
// //                   ),
// //                 ),
// //                 pdfLib.Text(
// //                   '${netAmount.toStringAsFixed(2)} ج',
// //                   style: pdfLib.TextStyle(
// //                     fontSize: 12,
// //                     fontWeight: pdfLib.FontWeight.bold,
// //                     font: _arabicFont,
// //                     color: netAmount >= 0 ? PdfColors.green : PdfColors.red,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // الحصول على اسم الملف
// //   String _getPDFFileName() {
// //     final now = DateTime.now();
// //     final formattedDate = DateFormat('yyyyMMdd').format(now);
// //     return 'تقرير_${_selectedDriver}_$formattedDate';
// //   }

// //   // ---------------------------
// //   // الرسائل
// //   // ---------------------------
// //   void _showError(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         backgroundColor: Colors.red,
// //         duration: Duration(seconds: 3),
// //       ),
// //     );
// //   }

// //   void _showSuccess(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         backgroundColor: Colors.green,
// //         duration: Duration(seconds: 2),
// //       ),
// //     );
// //   }

// //   String _formatDate(DateTime? date) {
// //     if (date == null) return '-';
// //     return DateFormat('dd/MM/yyyy').format(date);
// //   }

// //   // ---------------------------
// //   // AppBar معدل لإضافة زر الطباعة
// //   // ---------------------------
// //   Widget _buildCustomAppBar() {
// //     String title = 'شغل السائقين';

// //     if (_selectedContractor != null) {
// //       title = 'المقاول: $_selectedContractor';
// //     }
// //     if (_selectedDriver != null) {
// //       title = 'السائق: $_selectedDriver';
// //     }

// //     return Container(
// //       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
// //         bottom: false,
// //         child: Row(
// //           children: [
// //             // زر العودة إذا كان هناك اختيار
// //             if (_selectedContractor != null || _selectedDriver != null)
// //               IconButton(
// //                 icon: Icon(Icons.arrow_back, color: Colors.white),
// //                 onPressed: _goBack,
// //               ),

// //             Icon(Icons.people, color: Colors.white, size: 28),
// //             SizedBox(width: 12),
// //             Expanded(
// //               child: Text(
// //                 title,
// //                 style: const TextStyle(
// //                   color: Colors.white,
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //                 overflow: TextOverflow.ellipsis,
// //               ),
// //             ),

// //             // زر الطباعة إذا كان هناك سائق محدد
// //             if (_selectedDriver != null && _filteredDriverWork.isNotEmpty)
// //               IconButton(
// //                 icon: _isGeneratingPDF
// //                     ? SizedBox(
// //                         width: 20,
// //                         height: 20,
// //                         child: CircularProgressIndicator(
// //                           strokeWidth: 2,
// //                           valueColor: AlwaysStoppedAnimation<Color>(
// //                             Colors.white,
// //                           ),
// //                         ),
// //                       )
// //                     : Icon(Icons.print, color: Colors.white),
// //                 onPressed: _isGeneratingPDF ? null : _generatePDF,
// //               ),

// //             // الوقت
// //             StreamBuilder<DateTime>(
// //               stream: Stream.periodic(
// //                 const Duration(seconds: 1),
// //                 (_) => DateTime.now(),
// //               ),
// //               builder: (context, snapshot) {
// //                 final now = snapshot.data ?? DateTime.now();
// //                 int hour12 = now.hour % 12;
// //                 if (hour12 == 0) hour12 = 12;

// //                 return Container(
// //                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// //                   child: Text(
// //                     '${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
// //                     style: const TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 );
// //               },
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ---------------------------
// //   // واجهة اختيار المقاولين
// //   // ---------------------------
// //   Widget _buildContractorsList() {
// //     final filteredContractors = _getFilteredContractors();

// //     if (_isLoading) {
// //       return const Center(
// //         child: CircularProgressIndicator(
// //           valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
// //         ),
// //       );
// //     }

// //     return Column(
// //       children: [
// //         // حقل البحث
// //         Container(
// //           padding: EdgeInsets.all(16),
// //           child: TextField(
// //             decoration: InputDecoration(
// //               hintText: 'ابحث عن مقاول...',
// //               prefixIcon: Icon(Icons.search, color: Color(0xFF3498DB)),
// //               border: OutlineInputBorder(
// //                 borderRadius: BorderRadius.circular(12),
// //                 borderSide: BorderSide(color: Color(0xFF3498DB)),
// //               ),
// //               filled: true,
// //               fillColor: Colors.white,
// //               contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
// //             ),
// //             onChanged: (value) {
// //               setState(() {
// //                 _searchContractorQuery = value;
// //               });
// //             },
// //           ),
// //         ),

// //         // قائمة المقاولين
// //         Expanded(
// //           child: filteredContractors.isEmpty
// //               ? Center(
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Icon(Icons.business, size: 60, color: Colors.grey),
// //                       SizedBox(height: 16),
// //                       Text(
// //                         _searchContractorQuery.isEmpty
// //                             ? 'لا يوجد مقاولين مسجلين'
// //                             : 'لا توجد نتائج للبحث',
// //                         style: TextStyle(color: Colors.grey, fontSize: 16),
// //                       ),
// //                     ],
// //                   ),
// //                 )
// //               : ListView.builder(
// //                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                   itemCount: filteredContractors.length,
// //                   itemBuilder: (context, index) {
// //                     final contractor = filteredContractors[index];

// //                     return Container(
// //                       margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
// //                       decoration: BoxDecoration(
// //                         color: Colors.white,
// //                         borderRadius: BorderRadius.circular(12),
// //                         border: Border.all(
// //                           color: Color(0xFF3498DB).withOpacity(0.3),
// //                         ),
// //                         boxShadow: [
// //                           BoxShadow(
// //                             color: Colors.black12,
// //                             blurRadius: 4,
// //                             offset: Offset(0, 2),
// //                           ),
// //                         ],
// //                       ),
// //                       child: ListTile(
// //                         leading: Container(
// //                           width: 50,
// //                           height: 50,
// //                           decoration: BoxDecoration(
// //                             color: Color(0xFF3498DB),
// //                             borderRadius: BorderRadius.circular(25),
// //                           ),
// //                           child: Center(
// //                             child: Text(
// //                               contractor.substring(0, 1).toUpperCase(),
// //                               style: TextStyle(
// //                                 color: Colors.white,
// //                                 fontSize: 20,
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                         title: Text(
// //                           contractor,
// //                           style: TextStyle(
// //                             fontWeight: FontWeight.bold,
// //                             fontSize: 16,
// //                             color: Color(0xFF2C3E50),
// //                           ),
// //                         ),
// //                         subtitle: Text(
// //                           'انقر لعرض السائقين',
// //                           style: TextStyle(color: Colors.grey),
// //                         ),
// //                         trailing: Icon(
// //                           Icons.arrow_forward_ios,
// //                           color: Color(0xFF3498DB),
// //                           size: 16,
// //                         ),
// //                         onTap: () => _loadDriversByContractor(contractor),
// //                       ),
// //                     );
// //                   },
// //                 ),
// //         ),
// //       ],
// //     );
// //   }

// //   // ---------------------------
// //   // واجهة اختيار السائقين
// //   // ---------------------------
// //   Widget _buildDriversList() {
// //     final filteredDrivers = _getFilteredDrivers();

// //     if (_isLoadingDrivers) {
// //       return const Center(
// //         child: CircularProgressIndicator(
// //           valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
// //         ),
// //       );
// //     }

// //     return Column(
// //       children: [
// //         // شريط البحث
// //         Container(
// //           padding: EdgeInsets.all(16),
// //           child: TextField(
// //             decoration: InputDecoration(
// //               hintText: 'ابحث عن سائق...',
// //               prefixIcon: Icon(Icons.search, color: Color(0xFF3498DB)),
// //               border: OutlineInputBorder(
// //                 borderRadius: BorderRadius.circular(12),
// //                 borderSide: BorderSide(color: Color(0xFF3498DB)),
// //               ),
// //               filled: true,
// //               fillColor: Colors.white,
// //               contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
// //             ),
// //             onChanged: (value) {
// //               setState(() {
// //                 _searchDriverQuery = value;
// //               });
// //             },
// //           ),
// //         ),

// //         // معلومات المقاول
// //         Container(
// //           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Text(
// //                 'عدد السائقين: ${filteredDrivers.length}',
// //                 style: TextStyle(
// //                   color: Color(0xFF3498DB),
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //               Container(
// //                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //                 decoration: BoxDecoration(
// //                   color: Color(0xFF3498DB).withOpacity(0.1),
// //                   borderRadius: BorderRadius.circular(20),
// //                 ),
// //                 child: Text(
// //                   'المقاول: $_selectedContractor',
// //                   style: TextStyle(
// //                     color: Color(0xFF3498DB),
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),

// //         // قائمة السائقين
// //         Expanded(
// //           child: filteredDrivers.isEmpty
// //               ? Center(
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Icon(Icons.person_off, size: 60, color: Colors.grey),
// //                       SizedBox(height: 16),
// //                       Text(
// //                         _searchDriverQuery.isEmpty
// //                             ? 'لا يوجد سائقين لهذا المقاول'
// //                             : 'لا توجد نتائج للبحث',
// //                         style: TextStyle(color: Colors.grey, fontSize: 16),
// //                       ),
// //                     ],
// //                   ),
// //                 )
// //               : ListView.builder(
// //                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                   itemCount: filteredDrivers.length,
// //                   itemBuilder: (context, index) {
// //                     final driver = filteredDrivers[index];

// //                     return Container(
// //                       margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
// //                       decoration: BoxDecoration(
// //                         color: Colors.white,
// //                         borderRadius: BorderRadius.circular(12),
// //                         border: Border.all(color: Colors.grey[300]!),
// //                         boxShadow: [
// //                           BoxShadow(
// //                             color: Colors.black12,
// //                             blurRadius: 2,
// //                             offset: Offset(0, 1),
// //                           ),
// //                         ],
// //                       ),
// //                       child: ListTile(
// //                         leading: CircleAvatar(
// //                           backgroundColor: Color(0xFF3498DB),
// //                           child: Text(
// //                             driver['driverName'].substring(0, 1).toUpperCase(),
// //                             style: TextStyle(
// //                               color: Colors.white,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                         ),
// //                         title: Text(
// //                           driver['driverName'],
// //                           style: TextStyle(
// //                             fontWeight: FontWeight.bold,
// //                             fontSize: 16,
// //                           ),
// //                         ),
// //                         subtitle: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             SizedBox(height: 4),
// //                             Row(
// //                               children: [
// //                                 Icon(
// //                                   Icons.directions_car,
// //                                   size: 14,
// //                                   color: Colors.grey,
// //                                 ),
// //                                 SizedBox(width: 4),
// //                                 Text(
// //                                   '${driver['totalTrips']} رحلة',
// //                                   style: TextStyle(fontSize: 12),
// //                                 ),
// //                               ],
// //                             ),
// //                           ],
// //                         ),
// //                         trailing: Icon(
// //                           Icons.arrow_forward_ios,
// //                           color: Color(0xFF3498DB),
// //                           size: 16,
// //                         ),
// //                         onTap: () => _loadDriverWork(driver['driverName']),
// //                       ),
// //                     );
// //                   },
// //                 ),
// //         ),
// //       ],
// //     );
// //   }

// //   // ---------------------------
// //   // واجهة جدول شغل السائق
// //   // ---------------------------
// //   Widget _buildWorkTable() {
// //     if (_isLoadingWork) return const Center(child: CircularProgressIndicator());

// //     return Column(
// //       children: [
// //         Container(
// //           padding: const EdgeInsets.all(12),
// //           color: Colors.blue[50],
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(Icons.filter_alt, color: Colors.blue[700], size: 16),
// //               const SizedBox(width: 8),
// //               Text(
// //                 _getFilterText(),
// //                 style: TextStyle(
// //                   color: Colors.blue[700],
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //         Expanded(
// //           child: Container(
// //             margin: const EdgeInsets.all(16),
// //             child: _filteredDriverWork.isEmpty
// //                 ? Center(
// //                     child: Column(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         const Icon(
// //                           Icons.work_off,
// //                           size: 60,
// //                           color: Colors.grey,
// //                         ),
// //                         const SizedBox(height: 16),
// //                         Text(
// //                           _driverWork.isEmpty
// //                               ? 'لا يوجد شغل مسجل لهذا السائق'
// //                               : 'لا يوجد شغل في الفترة المحددة',
// //                           style: const TextStyle(
// //                             color: Colors.grey,
// //                             fontSize: 18,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   )
// //                 : SingleChildScrollView(
// //                     scrollDirection: Axis.horizontal,
// //                     child: SingleChildScrollView(
// //                       scrollDirection: Axis.vertical,
// //                       child: Table(
// //                         defaultColumnWidth: const FixedColumnWidth(120),
// //                         border: TableBorder.all(
// //                           color: const Color(0xFF3498DB),
// //                           width: 1,
// //                         ),
// //                         children: [
// //                           TableRow(
// //                             decoration: BoxDecoration(
// //                               color: const Color(0xFF3498DB).withOpacity(0.15),
// //                             ),
// //                             children: const [
// //                               TableCellHeader('عطلة العجل'),
// //                               TableCellHeader('مبيت العجل'),
// //                               TableCellHeader('نولون العجل'),
// //                               TableCellHeader('الكارتة'),
// //                               TableCellHeader('العهدة'),
// //                               TableCellHeader('اسم الموقع'),
// //                               TableCellHeader('مكان التعتيق'),
// //                               TableCellHeader('مكان التحميل'),
// //                               TableCellHeader('التاريخ'),
// //                               TableCellHeader('م'),
// //                             ],
// //                           ),
// //                           ..._filteredDriverWork.asMap().entries.map((entry) {
// //                             final index = entry.key;
// //                             final work = entry.value;

// //                             return TableRow(
// //                               decoration: BoxDecoration(
// //                                 color: index.isEven
// //                                     ? Colors.white
// //                                     : const Color(0xFFF8F9FA),
// //                               ),
// //                               children: [
// //                                 TableCellBody(
// //                                   '${work['wheelHoliday']} ج',
// //                                   textStyle: const TextStyle(
// //                                     fontWeight: FontWeight.bold,
// //                                     color: Colors.red,
// //                                   ),
// //                                 ),
// //                                 TableCellBody(
// //                                   '${work['wheelOvernight']} ج',
// //                                   textStyle: const TextStyle(
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                                 TableCellBody(
// //                                   '${work['wheelNolon']} ج',
// //                                   textStyle: const TextStyle(
// //                                     fontWeight: FontWeight.bold,
// //                                     color: Colors.green,
// //                                   ),
// //                                 ),
// //                                 TableCellBody(work['karta']),
// //                                 TableCellBody(work['ohda']),
// //                                 TableCellBody(
// //                                   work['selectedRoute'],
// //                                   textStyle: const TextStyle(
// //                                     fontWeight: FontWeight.bold,
// //                                     color: Color(0xFF3498DB),
// //                                   ),
// //                                 ),
// //                                 TableCellBody(work['unloadingLocation']),
// //                                 TableCellBody(work['loadingLocation']),
// //                                 TableCellBody(_formatDate(work['date'])),
// //                                 TableCellBody('${index + 1}'),
// //                               ],
// //                             );
// //                           }),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   String _getFilterText() {
// //     switch (_timeFilter) {
// //       case 'اليوم':
// //         return 'عرض رحلات اليوم';
// //       case 'هذا الشهر':
// //         return 'عرض رحلات هذا الشهر';
// //       case 'هذه السنة':
// //         return 'عرض رحلات هذه السنة';
// //       case 'مخصص':
// //         return 'عرض رحلات شهر $_selectedMonth سنة $_selectedYear';
// //       default:
// //         return 'عرض جميع الرحلات';
// //     }
// //   }

// //   // ---------------------------
// //   // قسم فلتر الوقت
// //   // ---------------------------
// //   Widget _buildTimeFilterSection() {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
// //       color: Colors.white,
// //       child: Column(
// //         children: [
// //           TextField(
// //             decoration: InputDecoration(
// //               hintText: 'ابحث باسم المقاول',
// //               prefixIcon: const Icon(Icons.search, color: Color(0xFF3498DB)),
// //               border: OutlineInputBorder(
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //               contentPadding: const EdgeInsets.symmetric(
// //                 vertical: 0,
// //                 horizontal: 12,
// //               ),
// //             ),
// //             onChanged: (value) {
// //               setState(() {
// //                 _searchContractorQuery = value;
// //               });
// //             },
// //           ),
// //           const SizedBox(height: 12),
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               const Icon(Icons.calendar_month, color: Color(0xFF3498DB)),
// //               const SizedBox(width: 8),
// //               DropdownButton<int>(
// //                 value: _selectedMonth,
// //                 onChanged: (value) {
// //                   if (value != null) {
// //                     setState(() => _selectedMonth = value);
// //                     _applyMonthYearFilter();
// //                   }
// //                 },
// //                 items: List.generate(12, (index) {
// //                   final monthNumber = index + 1;
// //                   return DropdownMenuItem(
// //                     value: monthNumber,
// //                     child: Text('شهر $monthNumber'),
// //                   );
// //                 }),
// //               ),
// //               const SizedBox(width: 20),
// //               DropdownButton<int>(
// //                 value: _selectedYear,
// //                 onChanged: (value) {
// //                   if (value != null) {
// //                     setState(() => _selectedYear = value);
// //                     _applyMonthYearFilter();
// //                   }
// //                 },
// //                 items: [
// //                   for (
// //                     int i = DateTime.now().year - 2;
// //                     i <= DateTime.now().year + 2;
// //                     i++
// //                   )
// //                     DropdownMenuItem(value: i, child: Text('$i')),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ---------------------------
// //   // الواجهة الرئيسية
// //   // ---------------------------
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Color(0xFFF4F6F8),
// //       body: Column(
// //         children: [
// //           _buildCustomAppBar(),
// //           if (_selectedDriver == null && _selectedContractor == null)
// //             _buildTimeFilterSection(),
// //           Expanded(
// //             child: _selectedDriver != null
// //                 ? _buildWorkTable()
// //                 : (_selectedContractor != null
// //                       ? _buildDriversList()
// //                       : _buildContractorsList()),
// //           ),
// //         ],
// //       ),
// //       floatingActionButton: _isGeneratingPDF
// //           ? FloatingActionButton(
// //               onPressed: null,
// //               backgroundColor: Colors.grey,
// //               child: CircularProgressIndicator(
// //                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
// //               ),
// //             )
// //           : FloatingActionButton(
// //               onPressed: () {
// //                 if (_selectedDriver != null) {
// //                   _loadDriverWork(_selectedDriver!);
// //                 } else if (_selectedContractor != null) {
// //                   _loadDriversByContractor(_selectedContractor!);
// //                 } else {
// //                   _loadContractors();
// //                 }
// //               },
// //               backgroundColor: Color(0xFF3498DB),
// //               tooltip: 'تحديث',
// //               child: Icon(Icons.refresh, color: Colors.white),
// //             ),
// //     );
// //   }
// // }

// // // ===== TableCellHeader & TableCellBody components =====
// // class TableCellHeader extends StatelessWidget {
// //   final String text;
// //   const TableCellHeader(this.text, {super.key});
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       height: 50,
// //       alignment: Alignment.center,
// //       padding: const EdgeInsets.symmetric(horizontal: 8),
// //       child: Text(
// //         text,
// //         style: const TextStyle(
// //           fontWeight: FontWeight.bold,
// //           fontSize: 14,
// //           color: Color(0xFF2C3E50),
// //         ),
// //         textAlign: TextAlign.center,
// //       ),
// //     );
// //   }
// // }

// // class TableCellBody extends StatelessWidget {
// //   final String text;
// //   final TextStyle? textStyle;
// //   const TableCellBody(this.text, {this.textStyle, super.key});
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       height: 48,
// //       alignment: Alignment.center,
// //       padding: const EdgeInsets.symmetric(horizontal: 8),
// //       child: Text(
// //         text,
// //         maxLines: 2,
// //         overflow: TextOverflow.ellipsis,
// //         textAlign: TextAlign.center,
// //         style: textStyle ?? const TextStyle(fontSize: 14),
// //       ),
// //     );
// //   }
// // }
// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pdfLib;
// import 'package:printing/printing.dart';
// import 'package:flutter/services.dart';

// class DriverWorkPage extends StatefulWidget {
//   const DriverWorkPage({super.key});

//   @override
//   State<DriverWorkPage> createState() => _DriverWorkPageState();
// }

// class _DriverWorkPageState extends State<DriverWorkPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // البيانات الأساسية
//   List<String> _contractors = []; // قائمة المقاولين
//   List<Map<String, dynamic>> _driversByContractor = []; // السائقين حسب المقاول

//   // بيانات شغل السائق
//   List<Map<String, dynamic>> _driverWork = [];
//   List<Map<String, dynamic>> _filteredDriverWork = [];

//   // حالات التحديد
//   String? _selectedContractor;
//   String? _selectedDriver;

//   // حالات التحميل
//   bool _isLoading = false;
//   bool _isLoadingDrivers = false;
//   bool _isLoadingWork = false;
//   bool _isGeneratingPDF = false;

//   // الفلاتر
//   String _searchContractorQuery = '';
//   String _searchDriverQuery = '';
//   String _timeFilter = 'الكل';
//   int _selectedMonth = DateTime.now().month;
//   int _selectedYear = DateTime.now().year;

//   // للطباعة
//   pdfLib.Font? _arabicFont;

//   @override
//   void initState() {
//     super.initState();
//     _loadContractors();
//     _loadArabicFont();
//   }

//   // تحميل الخط العربي للطباعة
//   Future<void> _loadArabicFont() async {
//     try {
//       final fontData = await rootBundle.load(
//         'assets/fonts/Amiri/Amiri-Regular.ttf',
//       );
//       _arabicFont = pdfLib.Font.ttf(fontData);
//     } catch (e) {
//       debugPrint('فشل تحميل الخط العربي: $e');
//     }
//   }

//   // ---------------------------
//   // تحميل قائمة المقاولين
//   // ---------------------------
//   Future<void> _loadContractors() async {
//     setState(() => _isLoading = true);
//     try {
//       final snapshot = await _firestore.collection('drivers').get();

//       // استخراج المقاولين الفريدين
//       Set<String> contractorsSet = {};

//       for (final doc in snapshot.docs) {
//         final data = doc.data();
//         final contractor = (data['contractor'] ?? '').toString().trim();
//         if (contractor.isNotEmpty) {
//           contractorsSet.add(contractor);
//         }
//       }

//       // تحويل إلى قائمة وترتيب أبجدي
//       List<String> contractorsList = contractorsSet.toList()..sort();

//       setState(() {
//         _contractors = contractorsList;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showError('خطأ في تحميل المقاولين: $e');
//     }
//   }

//   // ---------------------------
//   // تحميل السائقين التابعين لمقاول محدد
//   // ---------------------------
//   Future<void> _loadDriversByContractor(String contractor) async {
//     if (contractor.isEmpty) return;

//     setState(() {
//       _selectedContractor = contractor;
//       _isLoadingDrivers = true;
//       _driversByContractor.clear();
//       _selectedDriver = null;
//       _driverWork.clear();
//       _filteredDriverWork.clear();
//     });

//     try {
//       final snapshot = await _firestore
//           .collection('drivers')
//           .where('contractor', isEqualTo: contractor)
//           .get();

//       // تجميع السائقين الفريدين
//       Map<String, Map<String, dynamic>> driversMap = {};

//       for (final doc in snapshot.docs) {
//         final data = doc.data();
//         final driverName = (data['driverName'] ?? '').toString().trim();
//         if (driverName.isEmpty) continue;

//         if (!driversMap.containsKey(driverName)) {
//           driversMap[driverName] = {
//             'driverName': driverName,
//             'contractor': contractor,
//             'totalTrips': 0,
//             'lastTripDate': null,
//           };
//         }

//         final driverData = driversMap[driverName]!;

//         // تحديث الإحصائيات
//         driverData['totalTrips'] = driverData['totalTrips']! + 1;

//         // تاريخ آخر رحلة
//         final tripDate = (data['date'] as Timestamp?)?.toDate();
//         if (tripDate != null) {
//           if (driverData['lastTripDate'] == null ||
//               tripDate.isAfter(driverData['lastTripDate'])) {
//             driverData['lastTripDate'] = tripDate;
//           }
//         }
//       }

//       // تحويل القائمة وترتيب أبجدي
//       List<Map<String, dynamic>> driversList = driversMap.values.toList();
//       driversList.sort((a, b) => a['driverName'].compareTo(b['driverName']));

//       setState(() {
//         _driversByContractor = driversList;
//         _isLoadingDrivers = false;
//       });
//     } catch (e) {
//       setState(() => _isLoadingDrivers = false);
//       _showError('خطأ في تحميل السائقين: $e');
//     }
//   }

//   // ---------------------------
//   // تحميل شغل سائق محدد
//   // ---------------------------
//   Future<void> _loadDriverWork(String driverName) async {
//     setState(() {
//       _selectedDriver = driverName;
//       _isLoadingWork = true;
//       _driverWork.clear();
//       _filteredDriverWork.clear();
//     });

//     try {
//       final snapshot = await _firestore
//           .collection('drivers')
//           .where('driverName', isEqualTo: driverName)
//           .orderBy('date', descending: true)
//           .get();

//       List<Map<String, dynamic>> workList = [];

//       for (final doc in snapshot.docs) {
//         final data = doc.data();
//         DateTime? date = (data['date'] as Timestamp?)?.toDate();

//         workList.add({
//           'id': doc.id,
//           'date': date,
//           'companyName': data['companyName'] ?? 'غير معروف',
//           'loadingLocation': data['loadingLocation'] ?? '',
//           'unloadingLocation': data['unloadingLocation'] ?? '',
//           'selectedRoute': data['selectedRoute'] ?? '',
//           'ohda': data['ohda'] ?? '',
//           'karta': data['karta'] ?? '',
//           'wheelNolon': (data['wheelNolon'] ?? 0).toDouble(),
//           'wheelOvernight': (data['wheelOvernight'] ?? 0).toDouble(),
//           'wheelHoliday': (data['wheelHoliday'] ?? 0).toDouble(),
//           'selectedPrice': (data['selectedPrice'] ?? 0).toDouble(),
//           'isPaid': data['isPaid'] ?? false,
//           'paidAmount': (data['paidAmount'] ?? 0).toDouble(),
//           'remainingAmount': (data['remainingAmount'] ?? 0).toDouble(),
//           'paymentDate': data['paymentDate'] as Timestamp?,
//           'driverNotes': data['driverNotes'] ?? '',
//         });
//       }

//       setState(() {
//         _driverWork = workList;
//         _filteredDriverWork = _filterWorkByDate(workList);
//         _isLoadingWork = false;
//       });
//     } catch (e) {
//       setState(() => _isLoadingWork = false);
//       _showError('خطأ في تحميل الشغل');
//     }
//   }

//   // ---------------------------
//   // تصفية الشغل حسب التاريخ
//   // ---------------------------
//   List<Map<String, dynamic>> _filterWorkByDate(
//     List<Map<String, dynamic>> workList,
//   ) {
//     return workList.where((work) {
//       final workDate = work['date'] as DateTime?;
//       if (workDate == null) return false;
//       final now = DateTime.now();
//       switch (_timeFilter) {
//         case 'اليوم':
//           return workDate.year == now.year &&
//               workDate.month == now.month &&
//               workDate.day == now.day;
//         case 'هذا الشهر':
//           return workDate.year == now.year && workDate.month == now.month;
//         case 'هذه السنة':
//           return workDate.year == now.year;
//         case 'مخصص':
//           return workDate.year == _selectedYear &&
//               workDate.month == _selectedMonth;
//         case 'الكل':
//         default:
//           return true;
//       }
//     }).toList();
//   }

//   // ---------------------------
//   // تصفية المقاولين حسب البحث
//   // ---------------------------
//   List<String> _getFilteredContractors() {
//     if (_searchContractorQuery.isEmpty) return _contractors;
//     return _contractors
//         .where(
//           (contractor) => contractor.toLowerCase().contains(
//             _searchContractorQuery.toLowerCase(),
//           ),
//         )
//         .toList();
//   }

//   // ---------------------------
//   // تصفية السائقين حسب البحث
//   // ---------------------------
//   List<Map<String, dynamic>> _getFilteredDrivers() {
//     if (_searchDriverQuery.isEmpty) return _driversByContractor;
//     return _driversByContractor
//         .where(
//           (driver) => driver['driverName'].toLowerCase().contains(
//             _searchDriverQuery.toLowerCase(),
//           ),
//         )
//         .toList();
//   }

//   // ---------------------------
//   // تغيير فلتر الوقت
//   // ---------------------------
//   void _changeTimeFilter(String filter) {
//     setState(() => _timeFilter = filter);
//     if (_selectedDriver != null) {
//       _filteredDriverWork = _filterWorkByDate(_driverWork);
//     }
//   }

//   // ---------------------------
//   // تطبيق فلتر الشهر والسنة
//   // ---------------------------
//   void _applyMonthYearFilter() {
//     setState(() => _timeFilter = 'مخصص');
//     if (_selectedDriver != null) {
//       _filteredDriverWork = _filterWorkByDate(_driverWork);
//     }
//   }

//   // ---------------------------
//   // العودة للخلف
//   // ---------------------------
//   void _goBack() {
//     if (_selectedDriver != null) {
//       // العودة لقائمة السائقين
//       setState(() {
//         _selectedDriver = null;
//         _driverWork.clear();
//         _filteredDriverWork.clear();
//       });
//     } else if (_selectedContractor != null) {
//       // العودة لقائمة المقاولين
//       setState(() {
//         _selectedContractor = null;
//         _selectedDriver = null;
//         _driversByContractor.clear();
//         _driverWork.clear();
//         _filteredDriverWork.clear();
//       });
//     }
//   }

//   // ---------------------------
//   // إنشاء PDF للتقرير
//   // ---------------------------
//   Future<void> _generatePDF() async {
//     if (_arabicFont == null) {
//       _showError('الخط العربي غير محمل');
//       return;
//     }

//     if (_selectedDriver == null || _filteredDriverWork.isEmpty) {
//       _showError('لا توجد بيانات للطباعة');
//       return;
//     }

//     setState(() => _isGeneratingPDF = true);

//     try {
//       // حساب الإجماليات
//       double totalKarta = 0;
//       double totalOhda = 0;
//       double totalNolon = 0;
//       double totalOvernight = 0;
//       double totalHoliday = 0;
//       int totalTrips = _filteredDriverWork.length;

//       for (final work in _filteredDriverWork) {
//         totalKarta += _parseToDouble(work['karta']);
//         totalOhda += _parseToDouble(work['ohda']);
//         totalNolon += _parseToDouble(work['wheelNolon']);
//         totalOvernight += _parseToDouble(work['wheelOvernight']);
//         totalHoliday += _parseToDouble(work['wheelHoliday']);
//       }

//       double netAmount =
//           (totalKarta + totalNolon + totalOvernight + totalHoliday) - totalOhda;

//       // إنشاء PDF
//       final pdf = pdfLib.Document(
//         theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
//       );

//       pdf.addPage(
//         pdfLib.MultiPage(
//           pageFormat: PdfPageFormat.a4,
//           margin: pdfLib.EdgeInsets.all(20),
//           build: (context) => [
//             // العنوان الرئيسي
//             pdfLib.Directionality(
//               textDirection: pdfLib.TextDirection.rtl,
//               child: pdfLib.Column(
//                 children: [
//                   pdfLib.Row(
//                     mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
//                     children: [
//                       pdfLib.Text(
//                         'تقرير شغل السائقين',
//                         style: pdfLib.TextStyle(
//                           fontSize: 16,
//                           fontWeight: pdfLib.FontWeight.bold,
//                           font: _arabicFont,
//                           color: PdfColors.black,
//                         ),
//                       ),
//                       pdfLib.Text(
//                         DateFormat('yyyy/MM/dd').format(DateTime.now()),
//                         style: pdfLib.TextStyle(
//                           fontSize: 10,
//                           font: _arabicFont,
//                           color: PdfColors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                   pdfLib.Divider(color: PdfColors.black, thickness: 1),
//                 ],
//               ),
//             ),
//             pdfLib.SizedBox(height: 10),

//             // معلومات السائق
//             _buildDriverInfoPdf(
//               _selectedDriver!,
//               totalTrips,
//               netAmount,
//               _selectedContractor ?? '',
//             ),
//             pdfLib.SizedBox(height: 15),

//             // الجدول
//             _buildPdfTable(_filteredDriverWork),
//             pdfLib.SizedBox(height: 10),

//             // الملخص
//             _buildSummaryPdf(
//               totalKarta,
//               totalOhda,
//               totalNolon,
//               totalOvernight,
//               totalHoliday,
//               netAmount,
//             ),
//           ],
//         ),
//       );

//       // طباعة PDF
//       await Printing.layoutPdf(
//         onLayout: (PdfPageFormat format) async => pdf.save(),
//         name: _getPDFFileName(),
//       );
//     } catch (e) {
//       _showError('حدث خطأ في إنشاء PDF: $e');
//     } finally {
//       setState(() => _isGeneratingPDF = false);
//     }
//   }

//   // دالة مساعدة لتحويل إلى double
//   double _parseToDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is num) return value.toDouble();
//     if (value is String) {
//       try {
//         return double.tryParse(value) ?? 0.0;
//       } catch (e) {
//         return 0.0;
//       }
//     }
//     return 0.0;
//   }

//   // بناء معلومات السائق للPDF
//   pdfLib.Widget _buildDriverInfoPdf(
//     String driverName,
//     int totalTrips,
//     double netAmount,
//     String contractor,
//   ) {
//     return pdfLib.Directionality(
//       textDirection: pdfLib.TextDirection.rtl,
//       child: pdfLib.Container(
//         padding: pdfLib.EdgeInsets.all(8),
//         decoration: pdfLib.BoxDecoration(
//           border: pdfLib.Border.all(color: PdfColors.blue, width: 0.5),
//           borderRadius: pdfLib.BorderRadius.circular(5),
//         ),
//         child: pdfLib.Column(
//           crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
//           children: [
//             // اسم السائق وعدد الرحلات في نفس السطر
//             pdfLib.Row(
//               mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
//               children: [
//                 pdfLib.Text(
//                   'اسم السائق: $driverName',
//                   style: pdfLib.TextStyle(
//                     fontSize: 12,
//                     fontWeight: pdfLib.FontWeight.bold,
//                     font: _arabicFont,
//                     color: PdfColors.black,
//                   ),
//                 ),
//                 pdfLib.Text(
//                   'عدد الرحلات: $totalTrips',
//                   style: pdfLib.TextStyle(
//                     fontSize: 10,
//                     font: _arabicFont,
//                     color: PdfColors.blue,
//                   ),
//                 ),
//               ],
//             ),
//             pdfLib.SizedBox(height: 4),

//             // الصافي في السطر الثاني
//             pdfLib.Row(
//               mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
//               children: [
//                 pdfLib.Text(
//                   'الصافي: ${netAmount.toStringAsFixed(2)} ج',
//                   style: pdfLib.TextStyle(
//                     fontSize: 12,
//                     fontWeight: pdfLib.FontWeight.bold,
//                     font: _arabicFont,
//                     color: netAmount >= 0 ? PdfColors.green : PdfColors.red,
//                   ),
//                 ),
//                 if (contractor.isNotEmpty)
//                   pdfLib.Text(
//                     'المقاول: $contractor',
//                     style: pdfLib.TextStyle(
//                       fontSize: 10,
//                       font: _arabicFont,
//                       color: PdfColors.grey,
//                     ),
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // بناء الجدول في PDF
//   pdfLib.Widget _buildPdfTable(List<Map<String, dynamic>> workList) {
//     return pdfLib.Directionality(
//       textDirection: pdfLib.TextDirection.rtl,
//       child: pdfLib.Table.fromTextArray(
//         border: pdfLib.TableBorder.all(color: PdfColors.grey, width: 0.5),
//         cellAlignment: pdfLib.Alignment.center,
//         headerDecoration: pdfLib.BoxDecoration(color: PdfColors.grey200),
//         headerStyle: pdfLib.TextStyle(
//           fontSize: 9,
//           fontWeight: pdfLib.FontWeight.bold,
//           font: _arabicFont,
//           color: PdfColors.black,
//         ),
//         cellStyle: pdfLib.TextStyle(
//           fontSize: 8,
//           font: _arabicFont,
//           color: PdfColors.black,
//         ),
//         cellAlignments: {
//           0: pdfLib.Alignment.center, // م
//           1: pdfLib.Alignment.center, // التاريخ
//           2: pdfLib.Alignment.center, // من
//           3: pdfLib.Alignment.center, // إلى
//           4: pdfLib.Alignment.center, // العهدة
//           5: pdfLib.Alignment.center, // الكارتة
//           6: pdfLib.Alignment.center, // النولون
//           7: pdfLib.Alignment.center, // المبيت
//           8: pdfLib.Alignment.center, // العطلة
//         },
//         columnWidths: {
//           8: pdfLib.FlexColumnWidth(0.4), // م
//           7: pdfLib.FlexColumnWidth(1.0), // التاريخ
//           6: pdfLib.FlexColumnWidth(1.2), // من
//           5: pdfLib.FlexColumnWidth(1.2), // إلى
//           4: pdfLib.FlexColumnWidth(0.8), // العهدة
//           3: pdfLib.FlexColumnWidth(0.8), // الكارتة
//           2: pdfLib.FlexColumnWidth(0.8), // النولون
//           1: pdfLib.FlexColumnWidth(0.8), // المبيت
//           0: pdfLib.FlexColumnWidth(0.8), // العطلة
//         },
//         headers: [
//           'العطلة',
//           'المبيت',
//           'النولون',
//           'الكارتة',

//           'العهدة',
//           'إلى',

//           'من',
//           'التاريخ',

//           'م',
//         ],
//         data: List<List<String>>.generate(workList.length, (index) {
//           final work = workList[index];
//           final date = work['date'] as DateTime?;
//           return [
//             _parseToDouble(work['wheelHoliday']).toStringAsFixed(2),
//             _parseToDouble(work['wheelOvernight']).toStringAsFixed(2),
//             _parseToDouble(work['wheelNolon']).toStringAsFixed(2),
//             _parseToDouble(work['karta']).toStringAsFixed(2),
//             _parseToDouble(work['ohda']).toStringAsFixed(2),
//             work['unloadingLocation'] ?? '',
//             work['loadingLocation'] ?? '',
//             date != null ? DateFormat('dd/MM/yy').format(date) : '-',
//             (index + 1).toString(),
//           ];
//         }),
//       ),
//     );
//   }

//   // بناء ملخص الإجماليات للPDF
//   pdfLib.Widget _buildSummaryPdf(
//     double totalKarta,
//     double totalOhda,
//     double totalNolon,
//     double totalOvernight,
//     double totalHoliday,
//     double netAmount,
//   ) {
//     return pdfLib.Directionality(
//       textDirection: pdfLib.TextDirection.rtl,
//       child: pdfLib.Container(
//         padding: pdfLib.EdgeInsets.all(8),
//         decoration: pdfLib.BoxDecoration(
//           border: pdfLib.Border.all(color: PdfColors.black, width: 0.5),
//           borderRadius: pdfLib.BorderRadius.circular(5),
//         ),
//         child: pdfLib.Column(
//           crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
//           children: [
//             pdfLib.Text(
//               'ملخص الإجماليات',
//               style: pdfLib.TextStyle(
//                 fontSize: 10,
//                 fontWeight: pdfLib.FontWeight.bold,
//                 font: _arabicFont,
//                 color: PdfColors.black,
//               ),
//             ),
//             pdfLib.SizedBox(height: 5),
//             pdfLib.Row(
//               mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
//               children: [
//                 pdfLib.Text(
//                   'إجمالي الكارتة: ${totalKarta.toStringAsFixed(2)} ج',
//                   style: pdfLib.TextStyle(
//                     fontSize: 8,
//                     font: _arabicFont,
//                     color: PdfColors.black,
//                   ),
//                 ),
//                 pdfLib.Text(
//                   'إجمالي العهدة: ${totalOhda.toStringAsFixed(2)} ج',
//                   style: pdfLib.TextStyle(
//                     fontSize: 8,
//                     font: _arabicFont,
//                     color: PdfColors.red,
//                   ),
//                 ),
//               ],
//             ),
//             pdfLib.SizedBox(height: 3),
//             pdfLib.Row(
//               mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
//               children: [
//                 pdfLib.Text(
//                   'إجمالي النولون: ${totalNolon.toStringAsFixed(2)} ج',
//                   style: pdfLib.TextStyle(
//                     fontSize: 8,
//                     font: _arabicFont,
//                     color: PdfColors.green,
//                   ),
//                 ),
//                 pdfLib.Text(
//                   'إجمالي المبيت: ${totalOvernight.toStringAsFixed(2)} ج',
//                   style: pdfLib.TextStyle(
//                     fontSize: 8,
//                     font: _arabicFont,
//                     color: PdfColors.blue,
//                   ),
//                 ),
//                 pdfLib.Text(
//                   'إجمالي العطلة: ${totalHoliday.toStringAsFixed(2)} ج',
//                   style: pdfLib.TextStyle(
//                     fontSize: 8,
//                     font: _arabicFont,
//                     color: PdfColors.orange,
//                   ),
//                 ),
//               ],
//             ),
//             pdfLib.SizedBox(height: 5),
//             pdfLib.Divider(color: PdfColors.grey, thickness: 0.5),
//             pdfLib.Row(
//               mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
//               children: [
//                 pdfLib.Text(
//                   'الصافي النهائي:',
//                   style: pdfLib.TextStyle(
//                     fontSize: 10,
//                     fontWeight: pdfLib.FontWeight.bold,
//                     font: _arabicFont,
//                     color: PdfColors.black,
//                   ),
//                 ),
//                 pdfLib.Text(
//                   '${netAmount.toStringAsFixed(2)} ج',
//                   style: pdfLib.TextStyle(
//                     fontSize: 12,
//                     fontWeight: pdfLib.FontWeight.bold,
//                     font: _arabicFont,
//                     color: netAmount >= 0 ? PdfColors.green : PdfColors.red,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // الحصول على اسم الملف
//   String _getPDFFileName() {
//     final now = DateTime.now();
//     final formattedDate = DateFormat('yyyyMMdd').format(now);
//     return 'تقرير_${_selectedDriver}_$formattedDate';
//   }

//   // ---------------------------
//   // الرسائل
//   // ---------------------------
//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: Duration(seconds: 3),
//       ),
//     );
//   }

//   void _showSuccess(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   String _formatDate(DateTime? date) {
//     if (date == null) return '-';
//     return DateFormat('dd/MM/yyyy').format(date);
//   }

//   // ---------------------------
//   // AppBar بدون زر الطباعة
//   // ---------------------------
//   Widget _buildCustomAppBar() {
//     String title = 'شغل السائقين';

//     if (_selectedContractor != null) {
//       title = 'المقاول: $_selectedContractor';
//     }
//     if (_selectedDriver != null) {
//       title = 'السائق: $_selectedDriver';
//     }

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
//         bottom: false,
//         child: Row(
//           children: [
//             // زر العودة إذا كان هناك اختيار
//             if (_selectedContractor != null || _selectedDriver != null)
//               IconButton(
//                 icon: Icon(Icons.arrow_back, color: Colors.white),
//                 onPressed: _goBack,
//               ),

//             Icon(Icons.people, color: Colors.white, size: 28),
//             SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 title,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),

//             // الوقت
//             StreamBuilder<DateTime>(
//               stream: Stream.periodic(
//                 const Duration(seconds: 1),
//                 (_) => DateTime.now(),
//               ),
//               builder: (context, snapshot) {
//                 final now = snapshot.data ?? DateTime.now();
//                 int hour12 = now.hour % 12;
//                 if (hour12 == 0) hour12 = 12;

//                 return Container(
//                   padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//                   child: Text(
//                     '${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ---------------------------
//   // واجهة اختيار المقاولين
//   // ---------------------------
//   Widget _buildContractorsList() {
//     final filteredContractors = _getFilteredContractors();

//     if (_isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(
//           valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
//         ),
//       );
//     }

//     return Column(
//       children: [
//         // حقل البحث
//         Container(
//           padding: EdgeInsets.all(16),
//           child: TextField(
//             decoration: InputDecoration(
//               hintText: 'ابحث عن مقاول...',
//               prefixIcon: Icon(Icons.search, color: Color(0xFF3498DB)),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: Color(0xFF3498DB)),
//               ),
//               filled: true,
//               fillColor: Colors.white,
//               contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//             ),
//             onChanged: (value) {
//               setState(() {
//                 _searchContractorQuery = value;
//               });
//             },
//           ),
//         ),

//         // قائمة المقاولين
//         Expanded(
//           child: filteredContractors.isEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.business, size: 60, color: Colors.grey),
//                       SizedBox(height: 16),
//                       Text(
//                         _searchContractorQuery.isEmpty
//                             ? 'لا يوجد مقاولين مسجلين'
//                             : 'لا توجد نتائج للبحث',
//                         style: TextStyle(color: Colors.grey, fontSize: 16),
//                       ),
//                     ],
//                   ),
//                 )
//               : ListView.builder(
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   itemCount: filteredContractors.length,
//                   itemBuilder: (context, index) {
//                     final contractor = filteredContractors[index];

//                     return Container(
//                       margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: Color(0xFF3498DB).withOpacity(0.3),
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 4,
//                             offset: Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: ListTile(
//                         leading: Container(
//                           width: 50,
//                           height: 50,
//                           decoration: BoxDecoration(
//                             color: Color(0xFF3498DB),
//                             borderRadius: BorderRadius.circular(25),
//                           ),
//                           child: Center(
//                             child: Text(
//                               contractor.substring(0, 1).toUpperCase(),
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                         title: Text(
//                           contractor,
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: Color(0xFF2C3E50),
//                           ),
//                         ),
//                         subtitle: Text(
//                           'انقر لعرض السائقين',
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                         trailing: Icon(
//                           Icons.arrow_forward_ios,
//                           color: Color(0xFF3498DB),
//                           size: 16,
//                         ),
//                         onTap: () => _loadDriversByContractor(contractor),
//                       ),
//                     );
//                   },
//                 ),
//         ),
//       ],
//     );
//   }

//   // ---------------------------
//   // واجهة اختيار السائقين
//   // ---------------------------
//   Widget _buildDriversList() {
//     final filteredDrivers = _getFilteredDrivers();

//     if (_isLoadingDrivers) {
//       return const Center(
//         child: CircularProgressIndicator(
//           valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
//         ),
//       );
//     }

//     return Column(
//       children: [
//         // شريط البحث
//         Container(
//           padding: EdgeInsets.all(16),
//           child: TextField(
//             decoration: InputDecoration(
//               hintText: 'ابحث عن سائق...',
//               prefixIcon: Icon(Icons.search, color: Color(0xFF3498DB)),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide(color: Color(0xFF3498DB)),
//               ),
//               filled: true,
//               fillColor: Colors.white,
//               contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//             ),
//             onChanged: (value) {
//               setState(() {
//                 _searchDriverQuery = value;
//               });
//             },
//           ),
//         ),

//         // معلومات المقاول
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'عدد السائقين: ${filteredDrivers.length}',
//                 style: TextStyle(
//                   color: Color(0xFF3498DB),
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Color(0xFF3498DB).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   'المقاول: $_selectedContractor',
//                   style: TextStyle(
//                     color: Color(0xFF3498DB),
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // قائمة السائقين
//         Expanded(
//           child: filteredDrivers.isEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.person_off, size: 60, color: Colors.grey),
//                       SizedBox(height: 16),
//                       Text(
//                         _searchDriverQuery.isEmpty
//                             ? 'لا يوجد سائقين لهذا المقاول'
//                             : 'لا توجد نتائج للبحث',
//                         style: TextStyle(color: Colors.grey, fontSize: 16),
//                       ),
//                     ],
//                   ),
//                 )
//               : ListView.builder(
//                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   itemCount: filteredDrivers.length,
//                   itemBuilder: (context, index) {
//                     final driver = filteredDrivers[index];

//                     return Container(
//                       margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: Colors.grey[300]!),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 2,
//                             offset: Offset(0, 1),
//                           ),
//                         ],
//                       ),
//                       child: ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor: Color(0xFF3498DB),
//                           child: Text(
//                             driver['driverName'].substring(0, 1).toUpperCase(),
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         title: Text(
//                           driver['driverName'],
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(height: 4),
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.directions_car,
//                                   size: 14,
//                                   color: Colors.grey,
//                                 ),
//                                 SizedBox(width: 4),
//                                 Text(
//                                   '${driver['totalTrips']} رحلة',
//                                   style: TextStyle(fontSize: 12),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                         trailing: Icon(
//                           Icons.arrow_forward_ios,
//                           color: Color(0xFF3498DB),
//                           size: 16,
//                         ),
//                         onTap: () => _loadDriverWork(driver['driverName']),
//                       ),
//                     );
//                   },
//                 ),
//         ),
//       ],
//     );
//   }

//   // ---------------------------
//   // واجهة جدول شغل السائق
//   // ---------------------------
//   Widget _buildWorkTable() {
//     if (_isLoadingWork) return const Center(child: CircularProgressIndicator());

//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           color: Colors.blue[50],
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.filter_alt, color: Colors.blue[700], size: 16),
//               const SizedBox(width: 8),
//               Text(
//                 _getFilterText(),
//                 style: TextStyle(
//                   color: Colors.blue[700],
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: Container(
//             margin: const EdgeInsets.all(16),
//             child: _filteredDriverWork.isEmpty
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(
//                           Icons.work_off,
//                           size: 60,
//                           color: Colors.grey,
//                         ),
//                         const SizedBox(height: 16),
//                         Text(
//                           _driverWork.isEmpty
//                               ? 'لا يوجد شغل مسجل لهذا السائق'
//                               : 'لا يوجد شغل في الفترة المحددة',
//                           style: const TextStyle(
//                             color: Colors.grey,
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.vertical,
//                       child: Table(
//                         defaultColumnWidth: const FixedColumnWidth(120),
//                         border: TableBorder.all(
//                           color: const Color(0xFF3498DB),
//                           width: 1,
//                         ),
//                         children: [
//                           TableRow(
//                             decoration: BoxDecoration(
//                               color: const Color(0xFF3498DB).withOpacity(0.15),
//                             ),
//                             children: const [
//                               TableCellHeader('عطلة العجل'),
//                               TableCellHeader('مبيت العجل'),
//                               TableCellHeader('نولون العجل'),
//                               TableCellHeader('الكارتة'),
//                               TableCellHeader('العهدة'),
//                               TableCellHeader('اسم الموقع'),
//                               TableCellHeader('مكان التعتيق'),
//                               TableCellHeader('مكان التحميل'),
//                               TableCellHeader('التاريخ'),
//                               TableCellHeader('م'),
//                             ],
//                           ),
//                           ..._filteredDriverWork.asMap().entries.map((entry) {
//                             final index = entry.key;
//                             final work = entry.value;

//                             return TableRow(
//                               decoration: BoxDecoration(
//                                 color: index.isEven
//                                     ? Colors.white
//                                     : const Color(0xFFF8F9FA),
//                               ),
//                               children: [
//                                 TableCellBody(
//                                   '${work['wheelHoliday']} ج',
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.red,
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   '${work['wheelOvernight']} ج',
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   '${work['wheelNolon']} ج',
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.green,
//                                   ),
//                                 ),
//                                 TableCellBody(work['karta']),
//                                 TableCellBody(work['ohda']),
//                                 TableCellBody(
//                                   work['selectedRoute'],
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF3498DB),
//                                   ),
//                                 ),
//                                 TableCellBody(work['unloadingLocation']),
//                                 TableCellBody(work['loadingLocation']),
//                                 TableCellBody(_formatDate(work['date'])),
//                                 TableCellBody('${index + 1}'),
//                               ],
//                             );
//                           }),
//                         ],
//                       ),
//                     ),
//                   ),
//           ),
//         ),
//       ],
//     );
//   }

//   String _getFilterText() {
//     switch (_timeFilter) {
//       case 'اليوم':
//         return 'عرض رحلات اليوم';
//       case 'هذا الشهر':
//         return 'عرض رحلات هذا الشهر';
//       case 'هذه السنة':
//         return 'عرض رحلات هذه السنة';
//       case 'مخصص':
//         return 'عرض رحلات شهر $_selectedMonth سنة $_selectedYear';
//       default:
//         return 'عرض جميع الرحلات';
//     }
//   }

//   // ---------------------------
//   // قسم فلتر الوقت
//   // ---------------------------
//   Widget _buildTimeFilterSection() {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//       color: Colors.white,
//       child: Column(
//         children: [
//           TextField(
//             decoration: InputDecoration(
//               hintText: 'ابحث باسم المقاول',
//               prefixIcon: const Icon(Icons.search, color: Color(0xFF3498DB)),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               contentPadding: const EdgeInsets.symmetric(
//                 vertical: 0,
//                 horizontal: 12,
//               ),
//             ),
//             onChanged: (value) {
//               setState(() {
//                 _searchContractorQuery = value;
//               });
//             },
//           ),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.calendar_month, color: Color(0xFF3498DB)),
//               const SizedBox(width: 8),
//               DropdownButton<int>(
//                 value: _selectedMonth,
//                 onChanged: (value) {
//                   if (value != null) {
//                     setState(() => _selectedMonth = value);
//                     _applyMonthYearFilter();
//                   }
//                 },
//                 items: List.generate(12, (index) {
//                   final monthNumber = index + 1;
//                   return DropdownMenuItem(
//                     value: monthNumber,
//                     child: Text('شهر $monthNumber'),
//                   );
//                 }),
//               ),
//               const SizedBox(width: 20),
//               DropdownButton<int>(
//                 value: _selectedYear,
//                 onChanged: (value) {
//                   if (value != null) {
//                     setState(() => _selectedYear = value);
//                     _applyMonthYearFilter();
//                   }
//                 },
//                 items: [
//                   for (
//                     int i = DateTime.now().year - 2;
//                     i <= DateTime.now().year + 2;
//                     i++
//                   )
//                     DropdownMenuItem(value: i, child: Text('$i')),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ---------------------------
//   // الواجهة الرئيسية مع FloatingActionButton للطباعة
//   // ---------------------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF4F6F8),
//       body: Column(
//         children: [
//           _buildCustomAppBar(),
//           if (_selectedDriver == null && _selectedContractor == null)
//             _buildTimeFilterSection(),
//           Expanded(
//             child: _selectedDriver != null
//                 ? _buildWorkTable()
//                 : (_selectedContractor != null
//                       ? _buildDriversList()
//                       : _buildContractorsList()),
//           ),
//         ],
//       ),
//       // هنا يتم التحكم في FloatingActionButton حسب الحالة
//       floatingActionButton: _getFloatingActionButton(),
//     );
//   }

//   // دالة لإنشاء الـ FloatingActionButton المناسب
//   Widget? _getFloatingActionButton() {
//     // إذا كان هناك سائق محدد، أظهر زر الطباعة
//     if (_selectedDriver != null && _filteredDriverWork.isNotEmpty) {
//       return FloatingActionButton(
//         onPressed: _isGeneratingPDF ? null : _generatePDF,
//         backgroundColor: _isGeneratingPDF ? Colors.grey : Colors.red,
//         tooltip: 'طباعة التقرير',
//         child: _isGeneratingPDF
//             ? CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//               )
//             : Icon(Icons.print, color: Colors.white),
//       );
//     }
//     // إذا لم يكن هناك سائق محدد، أظهر زر التحديث
//     // else {
//     //   return FloatingActionButton(
//     //     onPressed: () {
//     //       if (_selectedDriver != null) {
//     //         _loadDriverWork(_selectedDriver!);
//     //       } else if (_selectedContractor != null) {
//     //         _loadDriversByContractor(_selectedContractor!);
//     //       } else {
//     //         _loadContractors();
//     //       }
//     //     },
//     //     backgroundColor: Color(0xFF3498DB),
//     //     tooltip: 'تحديث',
//     //     child: Icon(Icons.refresh, color: Colors.white),
//     //   );
//     // }
//   }
// }

// // ===== TableCellHeader & TableCellBody components =====
// class TableCellHeader extends StatelessWidget {
//   final String text;
//   const TableCellHeader(this.text, {super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 50,
//       alignment: Alignment.center,
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 14,
//           color: Color(0xFF2C3E50),
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
// }

// class TableCellBody extends StatelessWidget {
//   final String text;
//   final TextStyle? textStyle;
//   const TableCellBody(this.text, {this.textStyle, super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 48,
//       alignment: Alignment.center,
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       child: Text(
//         text,
//         maxLines: 2,
//         overflow: TextOverflow.ellipsis,
//         textAlign: TextAlign.center,
//         style: textStyle ?? const TextStyle(fontSize: 14),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';

class DriverWorkPage extends StatefulWidget {
  const DriverWorkPage({super.key});

  @override
  State<DriverWorkPage> createState() => _DriverWorkPageState();
}

class _DriverWorkPageState extends State<DriverWorkPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // البيانات الأساسية
  List<String> _contractors = []; // قائمة المقاولين
  List<Map<String, dynamic>> _driversByContractor = []; // السائقين حسب المقاول

  // بيانات شغل السائق
  List<Map<String, dynamic>> _driverWork = [];
  List<Map<String, dynamic>> _filteredDriverWork = [];

  // حالات التحديد
  String? _selectedContractor;
  String? _selectedDriver;

  // حالات التحميل
  bool _isLoading = false;
  bool _isLoadingDrivers = false;
  bool _isLoadingWork = false;
  bool _isGeneratingPDF = false;

  // الفلاتر
  String _searchContractorQuery = '';
  String _searchDriverQuery = '';
  String _timeFilter = 'الكل';
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  // للطباعة
  pdfLib.Font? _arabicFont;

  @override
  void initState() {
    super.initState();
    _loadContractors();
    _loadArabicFont();
  }

  // تحميل الخط العربي للطباعة
  Future<void> _loadArabicFont() async {
    try {
      final fontData = await rootBundle.load(
        'assets/fonts/Amiri/Amiri-Regular.ttf',
      );
      _arabicFont = pdfLib.Font.ttf(fontData);
    } catch (e) {
      debugPrint('فشل تحميل الخط العربي: $e');
      // استخدام خط افتراضي إذا لم يتم تحميل الخط العربي
      _arabicFont = pdfLib.Font.ttf(
        await rootBundle.load('assets/fonts/Amiri/Amiri-Regular.ttf'),
      );
    }
  }

  // ---------------------------
  // تحميل قائمة المقاولين
  // ---------------------------
  Future<void> _loadContractors() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await _firestore.collection('drivers').get();

      // استخراج المقاولين الفريدين
      Set<String> contractorsSet = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final contractor = (data['contractor'] ?? '').toString().trim();
        if (contractor.isNotEmpty) {
          contractorsSet.add(contractor);
        }
      }

      // تحويل إلى قائمة وترتيب أبجدي
      List<String> contractorsList = contractorsSet.toList()..sort();

      setState(() {
        _contractors = contractorsList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('خطأ في تحميل المقاولين: $e');
    }
  }

  // ---------------------------
  // تحميل السائقين التابعين لمقاول محدد
  // ---------------------------
  Future<void> _loadDriversByContractor(String contractor) async {
    if (contractor.isEmpty) return;

    setState(() {
      _selectedContractor = contractor;
      _isLoadingDrivers = true;
      _driversByContractor.clear();
      _selectedDriver = null;
      _driverWork.clear();
      _filteredDriverWork.clear();
    });

    try {
      // استعلام بدون ترتيب لتجنب مشكلة الفهرسة
      final snapshot = await _firestore
          .collection('drivers')
          .where('contractor', isEqualTo: contractor)
          .get();

      // تجميع السائقين الفريدين
      Map<String, Map<String, dynamic>> driversMap = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final driverName = (data['driverName'] ?? '').toString().trim();
        if (driverName.isEmpty) continue;

        if (!driversMap.containsKey(driverName)) {
          driversMap[driverName] = {
            'driverName': driverName,
            'contractor': contractor,
            'totalTrips': 0,
            'lastTripDate': null,
          };
        }

        final driverData = driversMap[driverName]!;

        // تحديث الإحصائيات
        driverData['totalTrips'] = driverData['totalTrips']! + 1;

        // تاريخ آخر رحلة
        final tripDate = (data['date'] as Timestamp?)?.toDate();
        if (tripDate != null) {
          if (driverData['lastTripDate'] == null ||
              tripDate.isAfter(driverData['lastTripDate'])) {
            driverData['lastTripDate'] = tripDate;
          }
        }
      }

      // تحويل القائمة وترتيب أبجدي
      List<Map<String, dynamic>> driversList = driversMap.values.toList();
      driversList.sort((a, b) => a['driverName'].compareTo(b['driverName']));

      setState(() {
        _driversByContractor = driversList;
        _isLoadingDrivers = false;
      });
    } catch (e) {
      setState(() => _isLoadingDrivers = false);
      _showError('خطأ في تحميل السائقين: $e');
    }
  }

  // ---------------------------
  // تحميل شغل سائق محدد
  // ---------------------------

  // ---------------------------
  // تحميل شغل سائق محدد
  // ---------------------------
  Future<void> _loadDriverWork(String driverName) async {
    if (_selectedContractor == null || driverName.isEmpty) return;

    setState(() {
      _selectedDriver = driverName;
      _isLoadingWork = true;
      _driverWork.clear();
      _filteredDriverWork.clear();
    });

    try {
      // أضف شرط المقاول في الاستعلام
      final snapshot = await _firestore
          .collection('drivers')
          .where('driverName', isEqualTo: driverName)
          .where('contractor', isEqualTo: _selectedContractor!) // ← هنا التعديل
          .get();

      List<Map<String, dynamic>> workList = [];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        DateTime? date = (data['date'] as Timestamp?)?.toDate();

        workList.add({
          'id': doc.id,
          'date': date,
          'companyName': data['companyName'] ?? 'غير معروف',
          'loadingLocation': data['loadingLocation'] ?? '',
          'unloadingLocation': data['unloadingLocation'] ?? '',
          'selectedRoute': data['selectedRoute'] ?? '',
          'ohda': data['ohda'] ?? '0',
          'karta': data['karta'] ?? '0',
          'wheelNolon': data['wheelNolon'] ?? 0,
          'wheelOvernight': data['wheelOvernight'] ?? 0,
          'wheelHoliday': data['wheelHoliday'] ?? 0,
          'selectedPrice': data['selectedPrice'] ?? 0,
          'isPaid': data['isPaid'] ?? false,
          'paidAmount': data['paidAmount'] ?? 0,
          'remainingAmount': data['remainingAmount'] ?? 0,
          'paymentDate': data['paymentDate'] as Timestamp?,
          'driverNotes': data['driverNotes'] ?? '',
        });
      }

      // ترتيب حسب التاريخ تنازلياً يدوياً
      workList.sort((a, b) {
        final dateA = a['date'] as DateTime?;
        final dateB = b['date'] as DateTime?;
        if (dateA == null && dateB == null) return 0;
        if (dateA == null) return 1;
        if (dateB == null) return -1;
        return dateB.compareTo(dateA);
      });

      setState(() {
        _driverWork = workList;
        _filteredDriverWork = _filterWorkByDate(workList);
        _isLoadingWork = false;
      });
    } catch (e) {
      setState(() => _isLoadingWork = false);
      _showError('خطأ في تحميل الشغل: $e');
    }
  }
  // Future<void> _loadDriverWork(String driverName) async {
  //   setState(() {
  //     _selectedDriver = driverName;
  //     _isLoadingWork = true;
  //     _driverWork.clear();
  //     _filteredDriverWork.clear();
  //   });

  //   try {
  //     // استعلام بدون ترتيب لتجنب مشكلة الفهرسة
  //     final snapshot = await _firestore
  //         .collection('drivers')
  //         .where('driverName', isEqualTo: driverName)
  //         .get();

  //     List<Map<String, dynamic>> workList = [];

  //     for (final doc in snapshot.docs) {
  //       final data = doc.data();
  //       DateTime? date = (data['date'] as Timestamp?)?.toDate();

  //       workList.add({
  //         'id': doc.id,
  //         'date': date,
  //         'companyName': data['companyName'] ?? 'غير معروف',
  //         'loadingLocation': data['loadingLocation'] ?? '',
  //         'unloadingLocation': data['unloadingLocation'] ?? '',
  //         'selectedRoute': data['selectedRoute'] ?? '',
  //         'ohda': data['ohda'] ?? '0',
  //         'karta': data['karta'] ?? '0',
  //         'wheelNolon': data['wheelNolon'] ?? 0,
  //         'wheelOvernight': data['wheelOvernight'] ?? 0,
  //         'wheelHoliday': data['wheelHoliday'] ?? 0,
  //         'selectedPrice': data['selectedPrice'] ?? 0,
  //         'isPaid': data['isPaid'] ?? false,
  //         'paidAmount': data['paidAmount'] ?? 0,
  //         'remainingAmount': data['remainingAmount'] ?? 0,
  //         'paymentDate': data['paymentDate'] as Timestamp?,
  //         'driverNotes': data['driverNotes'] ?? '',
  //       });
  //     }

  //     // ترتيب حسب التاريخ تنازلياً يدوياً
  //     workList.sort((a, b) {
  //       final dateA = a['date'] as DateTime?;
  //       final dateB = b['date'] as DateTime?;
  //       if (dateA == null && dateB == null) return 0;
  //       if (dateA == null) return 1;
  //       if (dateB == null) return -1;
  //       return dateB.compareTo(dateA);
  //     });

  //     setState(() {
  //       _driverWork = workList;
  //       _filteredDriverWork = _filterWorkByDate(workList);
  //       _isLoadingWork = false;
  //     });
  //   } catch (e) {
  //     setState(() => _isLoadingWork = false);
  //     _showError('خطأ في تحميل الشغل: $e');
  //   }
  // }

  // ---------------------------
  // دالة مساعدة لتحويل القيم إلى double بأمان
  // ---------------------------
  double _safeParseToDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      try {
        // إزالة أي مسافات أو أحرف غير مرغوب فيها
        String cleanedValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
        return double.tryParse(cleanedValue) ?? 0.0;
      } catch (e) {
        return 0.0;
      }
    }

    return 0.0;
  }

  // ---------------------------
  // دالة مساعدة لتنسيق الرقم مع منزلتين عشريتين
  // ---------------------------
  String _formatDouble(dynamic value) {
    return _safeParseToDouble(value).toStringAsFixed(2);
  }

  // ---------------------------
  // تصفية الشغل حسب التاريخ
  // ---------------------------
  List<Map<String, dynamic>> _filterWorkByDate(
    List<Map<String, dynamic>> workList,
  ) {
    return workList.where((work) {
      final workDate = work['date'] as DateTime?;
      if (workDate == null) return false;
      final now = DateTime.now();
      switch (_timeFilter) {
        case 'اليوم':
          return workDate.year == now.year &&
              workDate.month == now.month &&
              workDate.day == now.day;
        case 'هذا الشهر':
          return workDate.year == now.year && workDate.month == now.month;
        case 'هذه السنة':
          return workDate.year == now.year;
        case 'مخصص':
          return workDate.year == _selectedYear &&
              workDate.month == _selectedMonth;
        case 'الكل':
        default:
          return true;
      }
    }).toList();
  }

  // ---------------------------
  // تصفية المقاولين حسب البحث
  // ---------------------------
  List<String> _getFilteredContractors() {
    if (_searchContractorQuery.isEmpty) return _contractors;
    return _contractors
        .where(
          (contractor) => contractor.toLowerCase().contains(
            _searchContractorQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  // ---------------------------
  // تصفية السائقين حسب البحث
  // ---------------------------
  List<Map<String, dynamic>> _getFilteredDrivers() {
    if (_searchDriverQuery.isEmpty) return _driversByContractor;
    return _driversByContractor
        .where(
          (driver) => driver['driverName'].toLowerCase().contains(
            _searchDriverQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  // ---------------------------
  // تغيير فلتر الوقت
  // ---------------------------
  void _changeTimeFilter(String filter) {
    setState(() => _timeFilter = filter);
    if (_selectedDriver != null) {
      _filteredDriverWork = _filterWorkByDate(_driverWork);
    }
  }

  // ---------------------------
  // تطبيق فلتر الشهر والسنة
  // ---------------------------
  void _applyMonthYearFilter() {
    setState(() => _timeFilter = 'مخصص');
    if (_selectedDriver != null) {
      _filteredDriverWork = _filterWorkByDate(_driverWork);
    }
  }

  // ---------------------------
  // العودة للخلف
  // ---------------------------
  void _goBack() {
    if (_selectedDriver != null) {
      // العودة لقائمة السائقين
      setState(() {
        _selectedDriver = null;
        _driverWork.clear();
        _filteredDriverWork.clear();
      });
    } else if (_selectedContractor != null) {
      // العودة لقائمة المقاولين
      setState(() {
        _selectedContractor = null;
        _selectedDriver = null;
        _driversByContractor.clear();
        _driverWork.clear();
        _filteredDriverWork.clear();
      });
    }
  }

  // ---------------------------
  // إنشاء PDF لتقرير المقاول
  // ---------------------------
  Future<void> _generateContractorPDF() async {
    if (_selectedContractor == null) {
      _showError('لم يتم تحديد مقاول');
      return;
    }

    setState(() => _isGeneratingPDF = true);

    try {
      // جلب جميع رحلات السائقين التابعين للمقاول
      final snapshot = await _firestore
          .collection('drivers')
          .where('contractor', isEqualTo: _selectedContractor!)
          .get();

      if (snapshot.docs.isEmpty) {
        _showError('لا توجد رحلات لهذا المقاول');
        setState(() => _isGeneratingPDF = false);
        return;
      }

      // تجميع البيانات حسب السائق
      Map<String, List<Map<String, dynamic>>> driversWork = {};
      Map<String, Map<String, double>> driverTotals = {};
      double contractorTotalKarta = 0;
      double contractorTotalOhda = 0;
      double contractorTotalNolon = 0;
      double contractorTotalOvernight = 0;
      double contractorTotalHoliday = 0;
      int contractorTotalTrips = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final driverName = (data['driverName'] ?? '').toString().trim();
        if (driverName.isEmpty) continue;

        final work = {
          'date': (data['date'] as Timestamp?)?.toDate(),
          'loadingLocation': data['loadingLocation'] ?? '',
          'unloadingLocation': data['unloadingLocation'] ?? '',
          'selectedRoute': data['selectedRoute'] ?? '',
          'ohda': _safeParseToDouble(data['ohda']),
          'karta': _safeParseToDouble(data['karta']),
          'wheelNolon': _safeParseToDouble(data['wheelNolon']),
          'wheelOvernight': _safeParseToDouble(data['wheelOvernight']),
          'wheelHoliday': _safeParseToDouble(data['wheelHoliday']),
        };

        // إضافة إلى قائمة السائق
        if (!driversWork.containsKey(driverName)) {
          driversWork[driverName] = [];
          driverTotals[driverName] = {
            'karta': 0.0,
            'ohda': 0.0,
            'nolon': 0.0,
            'overnight': 0.0,
            'holiday': 0.0,
          };
        }

        driversWork[driverName]!.add(work);

        // تحديث إجماليات السائق
        final totals = driverTotals[driverName]!;
        totals['karta'] = totals['karta']! + work['karta'];
        totals['ohda'] = totals['ohda']! + work['ohda'];
        totals['nolon'] = totals['nolon']! + work['wheelNolon'];
        totals['overnight'] = totals['overnight']! + work['wheelOvernight'];
        totals['holiday'] = totals['holiday']! + work['wheelHoliday'];

        // تحديث إجماليات المقاول
        contractorTotalKarta += work['karta'];
        contractorTotalOhda += work['ohda'];
        contractorTotalNolon += work['wheelNolon'];
        contractorTotalOvernight += work['wheelOvernight'];
        contractorTotalHoliday += work['wheelHoliday'];
        contractorTotalTrips++;
      }

      // ترتيب السائقين أبجدياً
      List<String> sortedDriverNames = driversWork.keys.toList()..sort();

      // إنشاء PDF
      final pdf = pdfLib.Document(
        theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
      );

      pdf.addPage(
        pdfLib.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pdfLib.EdgeInsets.all(20),
          build: (context) => [
            // العنوان الرئيسي
            _buildContractorPdfHeader(_selectedContractor!),
            pdfLib.SizedBox(height: 10),

            // إجماليات المقاول
            _buildContractorSummaryPdf(
              contractorTotalTrips,
              contractorTotalKarta,
              contractorTotalOhda,
              contractorTotalNolon,
              contractorTotalOvernight,
              contractorTotalHoliday,
            ),
            pdfLib.SizedBox(height: 15),

            // جداول السائقين
            for (final driverName in sortedDriverNames)
              ..._buildDriverPdfSection(
                driverName,
                driversWork[driverName]!,
                driverTotals[driverName]!,
                sortedDriverNames.indexOf(driverName) + 1,
              ),
          ],
        ),
      );

      // طباعة PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name:
            'تقرير_المقاول_${_selectedContractor}_${DateFormat('yyyyMMdd').format(DateTime.now())}',
      );
    } catch (e) {
      _showError('حدث خطأ في إنشاء PDF: $e');
    } finally {
      setState(() => _isGeneratingPDF = false);
    }
  }

  // ---------------------------
  // إنشاء PDF لتقرير السائق
  // ---------------------------

  // ---------------------------
  // إنشاء PDF لتقرير السائق
  // ---------------------------
  Future<void> _generateDriverPDF() async {
    if (_selectedDriver == null ||
        _selectedContractor == null ||
        _filteredDriverWork.isEmpty) {
      _showError('لا توجد بيانات للطباعة');
      return;
    }

    setState(() => _isGeneratingPDF = true);

    try {
      // استخدام البيانات المصفاة بالفعل (_filteredDriverWork)
      // بدلاً من جلبها من Firebase مرة أخرى
      double totalKarta = 0;
      double totalOhda = 0;
      double totalNolon = 0;
      double totalOvernight = 0;
      double totalHoliday = 0;
      int totalTrips = _filteredDriverWork.length;

      for (final work in _filteredDriverWork) {
        totalKarta += _safeParseToDouble(work['karta']);
        totalOhda += _safeParseToDouble(work['ohda']);
        totalNolon += _safeParseToDouble(work['wheelNolon']);
        totalOvernight += _safeParseToDouble(work['wheelOvernight']);
        totalHoliday += _safeParseToDouble(work['wheelHoliday']);
      }

      double netAmount =
          (totalKarta + totalNolon + totalOvernight + totalHoliday) - totalOhda;

      // إنشاء PDF باستخدام البيانات الموجودة
      final pdf = pdfLib.Document(
        theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
      );

      pdf.addPage(
        pdfLib.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pdfLib.EdgeInsets.all(20),
          build: (context) => [
            // العنوان الرئيسي مع اسم المقاول
            pdfLib.Directionality(
              textDirection: pdfLib.TextDirection.rtl,
              child: pdfLib.Column(
                children: [
                  pdfLib.Row(
                    mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
                    children: [
                      pdfLib.Text(
                        'تقرير شغل السائقين',
                        style: pdfLib.TextStyle(
                          fontSize: 16,
                          fontWeight: pdfLib.FontWeight.bold,
                          font: _arabicFont,
                          color: PdfColors.black,
                        ),
                      ),
                      pdfLib.Text(
                        DateFormat('yyyy/MM/dd').format(DateTime.now()),
                        style: pdfLib.TextStyle(
                          fontSize: 10,
                          font: _arabicFont,
                          color: PdfColors.grey,
                        ),
                      ),
                    ],
                  ),
                  pdfLib.SizedBox(height: 4),
                  pdfLib.Row(
                    mainAxisAlignment: pdfLib.MainAxisAlignment.center,
                    children: [
                      pdfLib.Text(
                        'المقاول: $_selectedContractor',
                        style: pdfLib.TextStyle(
                          fontSize: 12,
                          font: _arabicFont,
                          color: PdfColors.blue,
                        ),
                      ),
                    ],
                  ),
                  pdfLib.Divider(color: PdfColors.black, thickness: 1),
                ],
              ),
            ),
            pdfLib.SizedBox(height: 10),

            // معلومات السائق
            _buildDriverInfoPdf(
              _selectedDriver!,
              totalTrips,
              netAmount,
              _selectedContractor ?? '',
            ),
            pdfLib.SizedBox(height: 15),

            // الجدول
            _buildPdfTable(_filteredDriverWork),
            pdfLib.SizedBox(height: 10),

            // الملخص
            _buildSummaryPdf(
              totalKarta,
              totalOhda,
              totalNolon,
              totalOvernight,
              totalHoliday,
              netAmount,
            ),
          ],
        ),
      );

      // طباعة PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: _getPDFFileName(),
      );
    } catch (e) {
      _showError('حدث خطأ في إنشاء PDF: $e');
    } finally {
      setState(() => _isGeneratingPDF = false);
    }
  }
  // Future<void> _generateDriverPDF() async {
  //   if (_selectedDriver == null || _filteredDriverWork.isEmpty) {
  //     _showError('لا توجد بيانات للطباعة');
  //     return;
  //   }

  //   setState(() => _isGeneratingPDF = true);

  //   try {
  //     // حساب الإجماليات
  //     double totalKarta = 0;
  //     double totalOhda = 0;
  //     double totalNolon = 0;
  //     double totalOvernight = 0;
  //     double totalHoliday = 0;
  //     int totalTrips = _filteredDriverWork.length;

  //     for (final work in _filteredDriverWork) {
  //       totalKarta += _safeParseToDouble(work['karta']);
  //       totalOhda += _safeParseToDouble(work['ohda']);
  //       totalNolon += _safeParseToDouble(work['wheelNolon']);
  //       totalOvernight += _safeParseToDouble(work['wheelOvernight']);
  //       totalHoliday += _safeParseToDouble(work['wheelHoliday']);
  //     }

  //     double netAmount =
  //         (totalKarta + totalNolon + totalOvernight + totalHoliday) - totalOhda;

  //     // إنشاء PDF
  //     final pdf = pdfLib.Document(
  //       theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
  //     );

  //     pdf.addPage(
  //       pdfLib.MultiPage(
  //         pageFormat: PdfPageFormat.a4,
  //         margin: pdfLib.EdgeInsets.all(20),
  //         build: (context) => [
  //           // العنوان الرئيسي
  //           pdfLib.Directionality(
  //             textDirection: pdfLib.TextDirection.rtl,
  //             child: pdfLib.Column(
  //               children: [
  //                 pdfLib.Row(
  //                   mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     pdfLib.Text(
  //                       'تقرير شغل السائقين',
  //                       style: pdfLib.TextStyle(
  //                         fontSize: 16,
  //                         fontWeight: pdfLib.FontWeight.bold,
  //                         font: _arabicFont,
  //                         color: PdfColors.black,
  //                       ),
  //                     ),
  //                     pdfLib.Text(
  //                       DateFormat('yyyy/MM/dd').format(DateTime.now()),
  //                       style: pdfLib.TextStyle(
  //                         fontSize: 10,
  //                         font: _arabicFont,
  //                         color: PdfColors.grey,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 pdfLib.Divider(color: PdfColors.black, thickness: 1),
  //               ],
  //             ),
  //           ),
  //           pdfLib.SizedBox(height: 10),

  //           // معلومات السائق
  //           _buildDriverInfoPdf(
  //             _selectedDriver!,
  //             totalTrips,
  //             netAmount,
  //             _selectedContractor ?? '',
  //           ),
  //           pdfLib.SizedBox(height: 15),

  //           // الجدول
  //           _buildPdfTable(_filteredDriverWork),
  //           pdfLib.SizedBox(height: 10),

  //           // الملخص
  //           _buildSummaryPdf(
  //             totalKarta,
  //             totalOhda,
  //             totalNolon,
  //             totalOvernight,
  //             totalHoliday,
  //             netAmount,
  //           ),
  //         ],
  //       ),
  //     );

  //     // طباعة PDF
  //     await Printing.layoutPdf(
  //       onLayout: (PdfPageFormat format) async => pdf.save(),
  //       name: _getPDFFileName(),
  //     );
  //   } catch (e) {
  //     _showError('حدث خطأ في إنشاء PDF: $e');
  //   } finally {
  //     setState(() => _isGeneratingPDF = false);
  //   }
  // }

  // ---------------------------
  // بناء أقسام PDF
  // ---------------------------

  // بناء رأس تقرير المقاول
  pdfLib.Widget _buildContractorPdfHeader(String contractorName) {
    return pdfLib.Directionality(
      textDirection: pdfLib.TextDirection.rtl,
      child: pdfLib.Column(
        children: [
          pdfLib.Row(
            mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
            children: [
              pdfLib.Text(
                'تقرير المقاول: $contractorName',
                style: pdfLib.TextStyle(
                  fontSize: 18,
                  fontWeight: pdfLib.FontWeight.bold,
                  font: _arabicFont,
                  color: PdfColors.blue,
                ),
              ),
              pdfLib.Text(
                DateFormat('yyyy/MM/dd').format(DateTime.now()),
                style: pdfLib.TextStyle(
                  fontSize: 10,
                  font: _arabicFont,
                  color: PdfColors.grey,
                ),
              ),
            ],
          ),
          pdfLib.SizedBox(height: 5),
          pdfLib.Text(
            'إجمالي رحلات جميع السائقين',
            style: pdfLib.TextStyle(
              fontSize: 12,
              font: _arabicFont,
              color: PdfColors.grey,
            ),
          ),
          pdfLib.Divider(color: PdfColors.black, thickness: 1),
        ],
      ),
    );
  }

  // بناء ملخص المقاول
  pdfLib.Widget _buildContractorSummaryPdf(
    int totalTrips,
    double totalKarta,
    double totalOhda,
    double totalNolon,
    double totalOvernight,
    double totalHoliday,
  ) {
    double netAmount =
        (totalKarta + totalNolon + totalOvernight + totalHoliday) - totalOhda;

    return pdfLib.Directionality(
      textDirection: pdfLib.TextDirection.rtl,
      child: pdfLib.Container(
        padding: pdfLib.EdgeInsets.all(12),
        decoration: pdfLib.BoxDecoration(
          border: pdfLib.Border.all(color: PdfColors.blue, width: 1),
          borderRadius: pdfLib.BorderRadius.circular(8),
        ),
        child: pdfLib.Column(
          children: [
            pdfLib.Text(
              'إجماليات المقاول',
              style: pdfLib.TextStyle(
                fontSize: 14,
                fontWeight: pdfLib.FontWeight.bold,
                font: _arabicFont,
                color: PdfColors.blue,
              ),
            ),
            pdfLib.SizedBox(height: 8),
            pdfLib.Row(
              mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
              children: [
                pdfLib.Text(
                  'عدد الرحلات: $totalTrips',
                  style: pdfLib.TextStyle(
                    fontSize: 11,
                    font: _arabicFont,
                    color: PdfColors.black,
                  ),
                ),
                pdfLib.Text(
                  'عدد السائقين: ${_driversByContractor.length}',
                  style: pdfLib.TextStyle(
                    fontSize: 11,
                    font: _arabicFont,
                    color: PdfColors.black,
                  ),
                ),
              ],
            ),
            pdfLib.SizedBox(height: 6),
            pdfLib.Row(
              mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
              children: [
                pdfLib.Text(
                  'إجمالي الكارتة: ${totalKarta.toStringAsFixed(2)} ج',
                  style: pdfLib.TextStyle(
                    fontSize: 10,
                    font: _arabicFont,
                    color: PdfColors.green,
                  ),
                ),
                pdfLib.Text(
                  'إجمالي العهدة: ${totalOhda.toStringAsFixed(2)} ج',
                  style: pdfLib.TextStyle(
                    fontSize: 10,
                    font: _arabicFont,
                    color: PdfColors.red,
                  ),
                ),
              ],
            ),
            pdfLib.SizedBox(height: 4),
            pdfLib.Row(
              mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
              children: [
                pdfLib.Text(
                  'إجمالي النولون: ${totalNolon.toStringAsFixed(2)} ج',
                  style: pdfLib.TextStyle(
                    fontSize: 10,
                    font: _arabicFont,
                    color: PdfColors.green,
                  ),
                ),
                pdfLib.Text(
                  'إجمالي المبيت: ${totalOvernight.toStringAsFixed(2)} ج',
                  style: pdfLib.TextStyle(
                    fontSize: 10,
                    font: _arabicFont,
                    color: PdfColors.blue,
                  ),
                ),
                pdfLib.Text(
                  'إجمالي العطلة: ${totalHoliday.toStringAsFixed(2)} ج',
                  style: pdfLib.TextStyle(
                    fontSize: 10,
                    font: _arabicFont,
                    color: PdfColors.orange,
                  ),
                ),
              ],
            ),
            pdfLib.SizedBox(height: 8),
            pdfLib.Divider(color: PdfColors.grey, thickness: 0.5),
            pdfLib.Row(
              mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
              children: [
                pdfLib.Text(
                  'صافي المقاول:',
                  style: pdfLib.TextStyle(
                    fontSize: 12,
                    fontWeight: pdfLib.FontWeight.bold,
                    font: _arabicFont,
                    color: PdfColors.black,
                  ),
                ),
                pdfLib.Text(
                  '${netAmount.toStringAsFixed(2)} ج',
                  style: pdfLib.TextStyle(
                    fontSize: 14,
                    fontWeight: pdfLib.FontWeight.bold,
                    font: _arabicFont,
                    color: netAmount >= 0 ? PdfColors.green : PdfColors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // بناء قسم السائق في PDF
  List<pdfLib.Widget> _buildDriverPdfSection(
    String driverName,
    List<Map<String, dynamic>> workList,
    Map<String, double> totals,
    int driverIndex,
  ) {
    final netAmount =
        (totals['karta']! +
            totals['nolon']! +
            totals['overnight']! +
            totals['holiday']!) -
        totals['ohda']!;

    // ترتيب رحلات السائق حسب التاريخ
    workList.sort((a, b) {
      final dateA = a['date'] as DateTime?;
      final dateB = b['date'] as DateTime?;
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateB.compareTo(dateA);
    });

    return [
      pdfLib.SizedBox(height: 20),
      pdfLib.Directionality(
        textDirection: pdfLib.TextDirection.rtl,
        child: pdfLib.Container(
          padding: pdfLib.EdgeInsets.all(10),
          decoration: pdfLib.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pdfLib.BorderRadius.circular(5),
          ),
          child: pdfLib.Row(
            mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
            children: [
              pdfLib.Text(
                'السائق $driverIndex: $driverName',
                style: pdfLib.TextStyle(
                  fontSize: 12,
                  fontWeight: pdfLib.FontWeight.bold,
                  font: _arabicFont,
                  color: PdfColors.black,
                ),
              ),
              pdfLib.Text(
                'عدد الرحلات: ${workList.length}',
                style: pdfLib.TextStyle(
                  fontSize: 10,
                  font: _arabicFont,
                  color: PdfColors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
      pdfLib.SizedBox(height: 10),

      // جدول رحلات السائق
      _buildDriverPdfTable(workList),
      pdfLib.SizedBox(height: 10),

      // إجماليات السائق
      pdfLib.Directionality(
        textDirection: pdfLib.TextDirection.rtl,
        child: pdfLib.Container(
          padding: pdfLib.EdgeInsets.all(8),
          decoration: pdfLib.BoxDecoration(
            border: pdfLib.Border.all(color: PdfColors.grey400, width: 0.5),
            borderRadius: pdfLib.BorderRadius.circular(5),
          ),
          child: pdfLib.Column(
            children: [
              pdfLib.Text(
                'إجماليات السائق:',
                style: pdfLib.TextStyle(
                  fontSize: 10,
                  fontWeight: pdfLib.FontWeight.bold,
                  font: _arabicFont,
                  color: PdfColors.black,
                ),
              ),
              pdfLib.SizedBox(height: 4),
              pdfLib.Row(
                mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
                children: [
                  pdfLib.Text(
                    'كارتة: ${totals['karta']!.toStringAsFixed(2)} ج',
                    style: pdfLib.TextStyle(
                      fontSize: 9,
                      font: _arabicFont,
                      color: PdfColors.green,
                    ),
                  ),
                  pdfLib.Text(
                    'عهدة: ${totals['ohda']!.toStringAsFixed(2)} ج',
                    style: pdfLib.TextStyle(
                      fontSize: 9,
                      font: _arabicFont,
                      color: PdfColors.red,
                    ),
                  ),
                  pdfLib.Text(
                    'نولون: ${totals['nolon']!.toStringAsFixed(2)} ج',
                    style: pdfLib.TextStyle(
                      fontSize: 9,
                      font: _arabicFont,
                      color: PdfColors.green,
                    ),
                  ),
                ],
              ),
              pdfLib.SizedBox(height: 3),
              pdfLib.Row(
                mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
                children: [
                  pdfLib.Text(
                    'مبيت: ${totals['overnight']!.toStringAsFixed(2)} ج',
                    style: pdfLib.TextStyle(
                      fontSize: 9,
                      font: _arabicFont,
                      color: PdfColors.blue,
                    ),
                  ),
                  pdfLib.Text(
                    'عطلة: ${totals['holiday']!.toStringAsFixed(2)} ج',
                    style: pdfLib.TextStyle(
                      fontSize: 9,
                      font: _arabicFont,
                      color: PdfColors.orange,
                    ),
                  ),
                  pdfLib.Text(
                    'الصافي: ${netAmount.toStringAsFixed(2)} ج',
                    style: pdfLib.TextStyle(
                      fontSize: 10,
                      fontWeight: pdfLib.FontWeight.bold,
                      font: _arabicFont,
                      color: netAmount >= 0 ? PdfColors.green : PdfColors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      pdfLib.Divider(color: PdfColors.grey300, thickness: 0.5, height: 20),
    ];
  }

  // بناء جدول السائق في PDF
  pdfLib.Widget _buildDriverPdfTable(List<Map<String, dynamic>> workList) {
    return pdfLib.Directionality(
      textDirection: pdfLib.TextDirection.rtl,
      child: pdfLib.Table.fromTextArray(
        border: pdfLib.TableBorder.all(color: PdfColors.grey, width: 0.3),
        cellAlignment: pdfLib.Alignment.center,
        headerDecoration: pdfLib.BoxDecoration(color: PdfColors.grey100),
        headerStyle: pdfLib.TextStyle(
          fontSize: 8,
          fontWeight: pdfLib.FontWeight.bold,
          font: _arabicFont,
          color: PdfColors.black,
        ),
        cellStyle: pdfLib.TextStyle(
          fontSize: 7,
          font: _arabicFont,
          color: PdfColors.black,
        ),
        columnWidths: {
          8: pdfLib.FlexColumnWidth(0.3), // م
          7: pdfLib.FlexColumnWidth(0.6), // التاريخ
          6: pdfLib.FlexColumnWidth(1.0), // من
          5: pdfLib.FlexColumnWidth(1.0), // إلى
          4: pdfLib.FlexColumnWidth(0.5), // العهدة
          3: pdfLib.FlexColumnWidth(0.5), // الكارتة
          2: pdfLib.FlexColumnWidth(0.5), // النولون
          1: pdfLib.FlexColumnWidth(0.5), // المبيت
          0: pdfLib.FlexColumnWidth(0.5), // العطلة
        },
        headers: [
          'العطلة',
          'المبيت',
          'النولون',
          'الكارتة',
          'العهدة',
          'إلى',
          'من',
          'التاريخ',
          'م',
        ],
        data: List<List<String>>.generate(workList.length, (index) {
          final work = workList[index];
          final date = work['date'] as DateTime?;
          return [
            _formatDouble(work['wheelHoliday']),
            _formatDouble(work['wheelOvernight']),

            _formatDouble(work['wheelNolon']),

            _formatDouble(work['karta']),

            _formatDouble(work['ohda']),

            work['unloadingLocation'] ?? '',

            work['loadingLocation'] ?? '',

            date != null ? DateFormat('dd/MM/yy').format(date) : '-',

            (index + 1).toString(),
          ];
        }),
      ),
    );
  }

  // بناء معلومات السائق للPDF
  pdfLib.Widget _buildDriverInfoPdf(
    String driverName,
    int totalTrips,
    double netAmount,
    String contractor,
  ) {
    return pdfLib.Directionality(
      textDirection: pdfLib.TextDirection.rtl,
      child: pdfLib.Container(
        padding: pdfLib.EdgeInsets.all(8),
        decoration: pdfLib.BoxDecoration(
          border: pdfLib.Border.all(color: PdfColors.blue, width: 0.5),
          borderRadius: pdfLib.BorderRadius.circular(5),
        ),
        child: pdfLib.Column(
          crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
          children: [
            pdfLib.Row(
              mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
              children: [
                pdfLib.Text(
                  'اسم السائق: $driverName',
                  style: pdfLib.TextStyle(
                    fontSize: 12,
                    fontWeight: pdfLib.FontWeight.bold,
                    font: _arabicFont,
                    color: PdfColors.black,
                  ),
                ),
                pdfLib.Text(
                  'عدد الرحلات: $totalTrips',
                  style: pdfLib.TextStyle(
                    fontSize: 10,
                    font: _arabicFont,
                    color: PdfColors.blue,
                  ),
                ),
              ],
            ),
            pdfLib.SizedBox(height: 4),
            pdfLib.Row(
              mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
              children: [
                pdfLib.Text(
                  'الصافي: ${netAmount.toStringAsFixed(2)} ج',
                  style: pdfLib.TextStyle(
                    fontSize: 12,
                    fontWeight: pdfLib.FontWeight.bold,
                    font: _arabicFont,
                    color: netAmount >= 0 ? PdfColors.green : PdfColors.red,
                  ),
                ),
                if (contractor.isNotEmpty)
                  pdfLib.Text(
                    'المقاول: $contractor',
                    style: pdfLib.TextStyle(
                      fontSize: 10,
                      font: _arabicFont,
                      color: PdfColors.grey,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // بناء الجدول في PDF
  pdfLib.Widget _buildPdfTable(List<Map<String, dynamic>> workList) {
    return pdfLib.Directionality(
      textDirection: pdfLib.TextDirection.rtl,
      child: pdfLib.Table.fromTextArray(
        border: pdfLib.TableBorder.all(color: PdfColors.grey, width: 0.5),
        cellAlignment: pdfLib.Alignment.center,
        headerDecoration: pdfLib.BoxDecoration(color: PdfColors.grey200),
        headerStyle: pdfLib.TextStyle(
          fontSize: 9,
          fontWeight: pdfLib.FontWeight.bold,
          font: _arabicFont,
          color: PdfColors.black,
        ),
        cellStyle: pdfLib.TextStyle(
          fontSize: 8,
          font: _arabicFont,
          color: PdfColors.black,
        ),
        columnWidths: {
          8: pdfLib.FlexColumnWidth(0.3), // م
          7: pdfLib.FlexColumnWidth(0.6), // التاريخ
          6: pdfLib.FlexColumnWidth(1.2), // من
          5: pdfLib.FlexColumnWidth(1.2), // إلى
          4: pdfLib.FlexColumnWidth(0.6), // العهدة
          3: pdfLib.FlexColumnWidth(0.6), // الكارتة
          2: pdfLib.FlexColumnWidth(0.6), // النولون
          1: pdfLib.FlexColumnWidth(0.6), // المبيت
          0: pdfLib.FlexColumnWidth(0.6), // العطلة
        },
        headers: [
          'العطلة',
          'المبيت',
          'النولون',
          'الكارتة',
          'العهدة',
          'إلى',
          'من',
          'التاريخ',
          'م',
        ],
        data: List<List<String>>.generate(workList.length, (index) {
          final work = workList[index];
          final date = work['date'] as DateTime?;
          return [
            _formatDouble(work['wheelHoliday']),

            _formatDouble(work['wheelOvernight']),
            _formatDouble(work['wheelNolon']),

            _formatDouble(work['karta']),

            _formatDouble(work['ohda']),

            work['unloadingLocation'] ?? '',

            work['loadingLocation'] ?? '',

            date != null ? DateFormat('dd/MM/yy').format(date) : '-',

            (index + 1).toString(),
          ];
        }),
      ),
    );
  }

  // بناء ملخص الإجماليات للPDF
  pdfLib.Widget _buildSummaryPdf(
    double totalKarta,
    double totalOhda,
    double totalNolon,
    double totalOvernight,
    double totalHoliday,
    double netAmount,
  ) {
    return pdfLib.Directionality(
      textDirection: pdfLib.TextDirection.rtl,
      child: pdfLib.Container(
        padding: pdfLib.EdgeInsets.all(8),
        decoration: pdfLib.BoxDecoration(
          border: pdfLib.Border.all(color: PdfColors.black, width: 0.5),
          borderRadius: pdfLib.BorderRadius.circular(5),
        ),
        child: pdfLib.Column(
          crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
          children: [
            pdfLib.Text(
              'ملخص الإجماليات',
              style: pdfLib.TextStyle(
                fontSize: 10,
                fontWeight: pdfLib.FontWeight.bold,
                font: _arabicFont,
                color: PdfColors.black,
              ),
            ),
            pdfLib.SizedBox(height: 5),
            pdfLib.Row(
              mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
              children: [
                pdfLib.Text(
                  'إجمالي الكارتة: ${totalKarta.toStringAsFixed(2)} ج',
                  style: pdfLib.TextStyle(
                    fontSize: 8,
                    font: _arabicFont,
                    color: PdfColors.black,
                  ),
                ),
                pdfLib.Text(
                  'إجمالي العهدة: ${totalOhda.toStringAsFixed(2)} ج',
                  style: pdfLib.TextStyle(
                    fontSize: 8,
                    font: _arabicFont,
                    color: PdfColors.red,
                  ),
                ),
              ],
            ),
            pdfLib.SizedBox(height: 3),
            pdfLib.Row(
              mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
              children: [
                pdfLib.Text(
                  'إجمالي النولون: ${totalNolon.toStringAsFixed(2)} ج',
                  style: pdfLib.TextStyle(
                    fontSize: 8,
                    font: _arabicFont,
                    color: PdfColors.green,
                  ),
                ),
                pdfLib.Text(
                  'إجمالي المبيت: ${totalOvernight.toStringAsFixed(2)} ج',
                  style: pdfLib.TextStyle(
                    fontSize: 8,
                    font: _arabicFont,
                    color: PdfColors.blue,
                  ),
                ),
                pdfLib.Text(
                  'إجمالي العطلة: ${totalHoliday.toStringAsFixed(2)} ج',
                  style: pdfLib.TextStyle(
                    fontSize: 8,
                    font: _arabicFont,
                    color: PdfColors.orange,
                  ),
                ),
              ],
            ),
            pdfLib.SizedBox(height: 5),
            pdfLib.Divider(color: PdfColors.grey, thickness: 0.5),
            pdfLib.Row(
              mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
              children: [
                pdfLib.Text(
                  'الصافي النهائي:',
                  style: pdfLib.TextStyle(
                    fontSize: 10,
                    fontWeight: pdfLib.FontWeight.bold,
                    font: _arabicFont,
                    color: PdfColors.black,
                  ),
                ),
                pdfLib.Text(
                  '${netAmount.toStringAsFixed(2)} ج',
                  style: pdfLib.TextStyle(
                    fontSize: 12,
                    fontWeight: pdfLib.FontWeight.bold,
                    font: _arabicFont,
                    color: netAmount >= 0 ? PdfColors.green : PdfColors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // الحصول على اسم الملف
  String _getPDFFileName() {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyyMMdd').format(now);
    return 'تقرير_${_selectedDriver}_$formattedDate';
  }

  // ---------------------------
  // الرسائل
  // ---------------------------
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // ---------------------------
  // AppBar مخصص
  // ---------------------------
  Widget _buildCustomAppBar() {
    String title = 'شغل السائقين';

    if (_selectedContractor != null) {
      title = 'المقاول: $_selectedContractor';
    }
    if (_selectedDriver != null) {
      title = 'السائق: $_selectedDriver';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        bottom: false,
        child: Row(
          children: [
            // زر العودة إذا كان هناك اختيار
            if (_selectedContractor != null || _selectedDriver != null)
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _goBack,
              ),

            Icon(Icons.people, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // الوقت
            StreamBuilder<DateTime>(
              stream: Stream.periodic(
                const Duration(seconds: 1),
                (_) => DateTime.now(),
              ),
              builder: (context, snapshot) {
                final now = snapshot.data ?? DateTime.now();
                int hour12 = now.hour % 12;
                if (hour12 == 0) hour12 = 12;

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Text(
                    '${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------
  // واجهة اختيار المقاولين
  // ---------------------------
  Widget _buildContractorsList() {
    final filteredContractors = _getFilteredContractors();

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
        ),
      );
    }

    return Column(
      children: [
        // حقل البحث
        Container(
          padding: EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'ابحث عن مقاول...',
              prefixIcon: Icon(Icons.search, color: Color(0xFF3498DB)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF3498DB)),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: (value) {
              setState(() {
                _searchContractorQuery = value;
              });
            },
          ),
        ),

        // قائمة المقاولين
        Expanded(
          child: filteredContractors.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.business, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        _searchContractorQuery.isEmpty
                            ? 'لا يوجد مقاولين مسجلين'
                            : 'لا توجد نتائج للبحث',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  itemCount: filteredContractors.length,
                  itemBuilder: (context, index) {
                    final contractor = filteredContractors[index];

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFF3498DB).withOpacity(0.3),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Color(0xFF3498DB),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              contractor.substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          contractor,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        subtitle: Text(
                          'انقر لعرض السائقين',
                          style: TextStyle(color: Colors.grey),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF3498DB),
                          size: 16,
                        ),
                        onTap: () => _loadDriversByContractor(contractor),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ---------------------------
  // واجهة اختيار السائقين
  // ---------------------------
  Widget _buildDriversList() {
    final filteredDrivers = _getFilteredDrivers();

    if (_isLoadingDrivers) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
        ),
      );
    }

    return Column(
      children: [
        // شريط البحث
        Container(
          padding: EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'ابحث عن سائق...',
              prefixIcon: Icon(Icons.search, color: Color(0xFF3498DB)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFF3498DB)),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: (value) {
              setState(() {
                _searchDriverQuery = value;
              });
            },
          ),
        ),

        // معلومات المقاول
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'عدد السائقين: ${filteredDrivers.length}',
                style: TextStyle(
                  color: Color(0xFF3498DB),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF3498DB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'المقاول: $_selectedContractor',
                  style: TextStyle(
                    color: Color(0xFF3498DB),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),

        // قائمة السائقين
        Expanded(
          child: filteredDrivers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        _searchDriverQuery.isEmpty
                            ? 'لا يوجد سائقين لهذا المقاول'
                            : 'لا توجد نتائج للبحث',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  itemCount: filteredDrivers.length,
                  itemBuilder: (context, index) {
                    final driver = filteredDrivers[index];

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xFF3498DB),
                          child: Text(
                            driver['driverName'].substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          driver['driverName'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '${driver['totalTrips']} رحلة',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF3498DB),
                          size: 16,
                        ),
                        onTap: () => _loadDriverWork(driver['driverName']),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ---------------------------
  // واجهة جدول شغل السائق
  // ---------------------------
  Widget _buildWorkTable() {
    if (_isLoadingWork) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.blue[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.filter_alt, color: Colors.blue[700], size: 16),
              const SizedBox(width: 8),
              Text(
                _getFilterText(),
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: _filteredDriverWork.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.work_off,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _driverWork.isEmpty
                              ? 'لا يوجد شغل مسجل لهذا السائق'
                              : 'لا يوجد شغل في الفترة المحددة',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Table(
                        defaultColumnWidth: const FixedColumnWidth(120),
                        border: TableBorder.all(
                          color: const Color(0xFF3498DB),
                          width: 1,
                        ),
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: const Color(0xFF3498DB).withOpacity(0.15),
                            ),
                            children: const [
                              TableCellHeader('عطلة العجل'),
                              TableCellHeader('مبيت العجل'),
                              TableCellHeader('نولون العجل'),
                              TableCellHeader('الكارتة'),
                              TableCellHeader('العهدة'),
                              TableCellHeader('اسم الموقع'),
                              TableCellHeader('مكان التعتيق'),
                              TableCellHeader('مكان التحميل'),
                              TableCellHeader('التاريخ'),
                              TableCellHeader('م'),
                            ],
                          ),
                          ..._filteredDriverWork.asMap().entries.map((entry) {
                            final index = entry.key;
                            final work = entry.value;

                            return TableRow(
                              decoration: BoxDecoration(
                                color: index.isEven
                                    ? Colors.white
                                    : const Color(0xFFF8F9FA),
                              ),
                              children: [
                                TableCellBody(
                                  '${_formatDouble(work['wheelHoliday'])} ج',
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                TableCellBody(
                                  '${_formatDouble(work['wheelOvernight'])} ج',
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TableCellBody(
                                  '${_formatDouble(work['wheelNolon'])} ج',
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                TableCellBody(
                                  '${_formatDouble(work['karta'])} ج',
                                ),
                                TableCellBody(
                                  '${_formatDouble(work['ohda'])} ج',
                                ),
                                TableCellBody(
                                  work['selectedRoute'],
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3498DB),
                                  ),
                                ),
                                TableCellBody(work['unloadingLocation']),
                                TableCellBody(work['loadingLocation']),
                                TableCellBody(_formatDate(work['date'])),
                                TableCellBody('${index + 1}'),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  String _getFilterText() {
    switch (_timeFilter) {
      case 'اليوم':
        return 'عرض رحلات اليوم';
      case 'هذا الشهر':
        return 'عرض رحلات هذا الشهر';
      case 'هذه السنة':
        return 'عرض رحلات هذه السنة';
      case 'مخصص':
        return 'عرض رحلات شهر $_selectedMonth سنة $_selectedYear';
      default:
        return 'عرض جميع الرحلات';
    }
  }

  // ---------------------------
  // قسم فلتر الوقت
  // ---------------------------
  Widget _buildTimeFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'ابحث باسم المقاول',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF3498DB)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 12,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchContractorQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_month, color: Color(0xFF3498DB)),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: _selectedMonth,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedMonth = value);
                    _applyMonthYearFilter();
                  }
                },
                items: List.generate(12, (index) {
                  final monthNumber = index + 1;
                  return DropdownMenuItem(
                    value: monthNumber,
                    child: Text('شهر $monthNumber'),
                  );
                }),
              ),
              const SizedBox(width: 20),
              DropdownButton<int>(
                value: _selectedYear,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedYear = value);
                    _applyMonthYearFilter();
                  }
                },
                items: [
                  for (
                    int i = DateTime.now().year - 2;
                    i <= DateTime.now().year + 2;
                    i++
                  )
                    DropdownMenuItem(value: i, child: Text('$i')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // الواجهة الرئيسية مع FloatingActionButton المناسب
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF4F6F8),
      body: Column(
        children: [
          _buildCustomAppBar(),
          if (_selectedDriver == null && _selectedContractor == null)
            _buildTimeFilterSection(),
          Expanded(
            child: _selectedDriver != null
                ? _buildWorkTable()
                : (_selectedContractor != null
                      ? _buildDriversList()
                      : _buildContractorsList()),
          ),
        ],
      ),
      floatingActionButton: _getFloatingActionButton(),
    );
  }

  // دالة لإنشاء الـ FloatingActionButton المناسب
  Widget? _getFloatingActionButton() {
    if (_selectedDriver != null && _filteredDriverWork.isNotEmpty) {
      // زر طباعة تقرير السائق
      return FloatingActionButton(
        onPressed: _isGeneratingPDF ? null : _generateDriverPDF,
        backgroundColor: _isGeneratingPDF ? Colors.grey : Colors.blue,
        tooltip: 'طباعة تقرير السائق',
        child: _isGeneratingPDF
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : Icon(Icons.print, color: Colors.white),
      );
    } else if (_selectedContractor != null && _driversByContractor.isNotEmpty) {
      // زر طباعة تقرير المقاول
      return FloatingActionButton(
        onPressed: _isGeneratingPDF ? null : _generateContractorPDF,
        backgroundColor: _isGeneratingPDF ? Colors.grey : Colors.red,
        tooltip: 'طباعة تقرير المقاول',
        child: _isGeneratingPDF
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : Icon(Icons.business_center, color: Colors.white),
      );
    }
    // زر التحديث
    return FloatingActionButton(
      onPressed: () {
        if (_selectedDriver != null) {
          _loadDriverWork(_selectedDriver!);
        } else if (_selectedContractor != null) {
          _loadDriversByContractor(_selectedContractor!);
        } else {
          _loadContractors();
        }
      },
      backgroundColor: Color(0xFF3498DB),
      tooltip: 'تحديث',
      child: Icon(Icons.refresh, color: Colors.white),
    );
  }
}

// ===== TableCellHeader & TableCellBody components =====
class TableCellHeader extends StatelessWidget {
  final String text;
  const TableCellHeader(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Color(0xFF2C3E50),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class TableCellBody extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  const TableCellBody(this.text, {this.textStyle, super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: textStyle ?? const TextStyle(fontSize: 14),
      ),
    );
  }
}
