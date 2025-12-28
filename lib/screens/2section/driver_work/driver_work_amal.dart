// // import 'dart:async';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';

// // class DriverWorkPage extends StatefulWidget {
// //   const DriverWorkPage({super.key});

// //   @override
// //   State<DriverWorkPage> createState() => _DriverWorkPageState();
// // }

// // class _DriverWorkPageState extends State<DriverWorkPage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   List<Map<String, dynamic>> _allDrivers = [];
// //   List<Map<String, dynamic>> _filteredDrivers = [];
// //   List<Map<String, dynamic>> _driverWork = [];
// //   List<Map<String, dynamic>> _filteredDriverWork = [];
// //   String? _selectedDriver;
// //   bool _isLoading = false;
// //   String _searchQuery = '';
// //   String _driverSearchQuery = '';

// //   int _selectedMonth = DateTime.now().month;
// //   int _selectedYear = DateTime.now().year;
// //   String _timeFilter = 'الكل';

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadAllDriverData();
// //     rebuildDriverSummariesNolonOnly();
// //   }

// //   // ---------------------------
// //   // تحميل بيانات السائقين
// //   // ---------------------------
// //   Future<void> _loadAllDriverData() async {
// //     setState(() => _isLoading = true);
// //     try {
// //       final driversSnapshot = await _firestore.collection('drivers').get();

// //       Map<String, List<Map<String, dynamic>>> driverTrips = {};

// //       for (final doc in driversSnapshot.docs) {
// //         final data = doc.data();
// //         final driverName = (data['driverName'] ?? '').toString().trim();
// //         if (driverName.isEmpty) continue;

// //         if (!driverTrips.containsKey(driverName)) {
// //           driverTrips[driverName] = [];
// //         }

// //         final tripDate = (data['date'] as Timestamp?)?.toDate();

// //         driverTrips[driverName]!.add({
// //           'id': doc.id,
// //           'date': tripDate,
// //           'driverName': driverName,
// //           'wheelNolon': (data['wheelNolon'] ?? 0).toDouble(),
// //           'wheelOvernight': (data['wheelOvernight'] ?? 0).toDouble(),
// //           'wheelHoliday': (data['wheelHoliday'] ?? 0).toDouble(),
// //           'selectedPrice': (data['selectedPrice'] ?? 0).toDouble(),
// //           'karta': data['karta'] ?? '',
// //           'ohda': data['ohda'] ?? '',
// //           'isPaid': data['isPaid'] ?? false,
// //           'paidAmount': (data['paidAmount'] ?? 0).toDouble(),
// //           'selectedRoute': data['selectedRoute'] ?? '',
// //         });
// //       }

// //       final List<Map<String, dynamic>> driversList = [];

// //       for (var entry in driverTrips.entries) {
// //         final driverName = entry.key;
// //         final trips = entry.value;
// //         final filteredTrips = _filterTripsByDate(trips);

// //         driversList.add({
// //           'driverName': driverName,
// //           'allTrips': trips,
// //           'filteredTrips': filteredTrips,
// //           'hasTripsInFilter': filteredTrips.isNotEmpty,
// //           'totalTrips': trips.length,
// //           'filteredTripsCount': filteredTrips.length,
// //         });
// //       }

// //       setState(() {
// //         _allDrivers = driversList;
// //         _filteredDrivers = _applySearchFilter(driversList);
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() => _isLoading = false);
// //       _showError('خطأ في تحميل بيانات السائقين: $e');
// //     }
// //   }

// //   List<Map<String, dynamic>> _filterTripsByDate(
// //     List<Map<String, dynamic>> trips,
// //   ) {
// //     if (_timeFilter == 'الكل') return trips;
// //     return trips.where((trip) {
// //       final tripDate = trip['date'] as DateTime?;
// //       if (tripDate == null) return false;
// //       final now = DateTime.now();
// //       switch (_timeFilter) {
// //         case 'اليوم':
// //           return tripDate.year == now.year &&
// //               tripDate.month == now.month &&
// //               tripDate.day == now.day;
// //         case 'هذا الشهر':
// //           return tripDate.year == now.year && tripDate.month == now.month;
// //         case 'هذه السنة':
// //           return tripDate.year == now.year;
// //         case 'مخصص':
// //           return tripDate.year == _selectedYear &&
// //               tripDate.month == _selectedMonth;
// //         default:
// //           return true;
// //       }
// //     }).toList();
// //   }

// //   List<Map<String, dynamic>> _applySearchFilter(
// //     List<Map<String, dynamic>> drivers,
// //   ) {
// //     if (_searchQuery.isEmpty) return drivers;
// //     return drivers
// //         .where(
// //           (d) => d['driverName'].toLowerCase().contains(
// //             _searchQuery.toLowerCase(),
// //           ),
// //         )
// //         .toList();
// //   }

// //   void _updateFilter() {
// //     setState(() {
// //       for (var driver in _allDrivers) {
// //         driver['filteredTrips'] = _filterTripsByDate(driver['allTrips']);
// //         driver['hasTripsInFilter'] = driver['filteredTrips'].isNotEmpty;
// //         driver['filteredTripsCount'] = driver['filteredTrips'].length;
// //       }
// //       _filteredDrivers = _applySearchFilter(_allDrivers);
// //     });
// //   }

// //   void _changeTimeFilter(String filter) {
// //     setState(() => _timeFilter = filter);
// //     _updateFilter();
// //   }

// //   void _applyMonthYearFilter() {
// //     setState(() => _timeFilter = 'مخصص');
// //     _updateFilter();
// //   }

// //   // ---------------------------
// //   // إعادة بناء ملخص النولون فقط
// //   // ---------------------------
// //   Future<void> rebuildDriverSummariesNolonOnly() async {
// //     try {
// //       final snapshot = await _firestore.collection('drivers').get();
// //       Map<String, Map<String, dynamic>> driverSummaries = {};

// //       for (final doc in snapshot.docs) {
// //         final data = doc.data();
// //         final driverName = (data['driverName'] ?? '').toString().trim();
// //         if (driverName.isEmpty) continue;

// //         if (!driverSummaries.containsKey(driverName)) {
// //           driverSummaries[driverName] = {
// //             'driverName': driverName,
// //             'totalWheelNolon': 0.0,
// //             'totalPaidAmount': 0.0,
// //             'totalRemainingAmount': 0.0,
// //             'totalTrips': 0,
// //             'lastUpdated': Timestamp.now(),
// //             'status': 'جارية',
// //           };
// //         }

// //         final summary = driverSummaries[driverName]!;

// //         summary['totalWheelNolon'] =
// //             (summary['totalWheelNolon'] ?? 0.0) +
// //             ((data['wheelNolon'] ?? 0).toDouble() +
// //                 (data['wheelOvernight'] ?? 0).toDouble() +
// //                 (data['wheelHoliday'] ?? 0).toDouble());
// //         summary['totalPaidAmount'] =
// //             (summary['totalPaidAmount'] ?? 0.0) +
// //             (data['paidAmount'] ?? 0).toDouble();
// //         summary['totalTrips'] = (summary['totalTrips'] ?? 0) + 1;
// //       }

// //       for (var s in driverSummaries.values) {
// //         final totalWheelNolon = (s['totalWheelNolon'] ?? 0.0).toDouble();
// //         final totalPaid = (s['totalPaidAmount'] ?? 0.0).toDouble();
// //         s['totalRemainingAmount'] = totalWheelNolon - totalPaid;
// //         s['status'] = s['totalRemainingAmount'] <= 0 ? 'منتهية' : 'جارية';
// //         s['lastUpdated'] = Timestamp.now();
// //       }

// //       final batch = _firestore.batch();
// //       final summariesCollection = _firestore.collection('driverSummaries');

// //       final old = await summariesCollection.get();
// //       for (final d in old.docs) {
// //         batch.delete(d.reference);
// //       }

// //       driverSummaries.forEach((name, data) {
// //         batch.set(summariesCollection.doc(name), data);
// //       });

// //       await batch.commit();
// //       debugPrint('✅ driverSummaries rebuilt (nolon-only).');
// //     } catch (e) {
// //       debugPrint('❌ error rebuilding driverSummaries: $e');
// //     }
// //   }

// //   // ---------------------------
// //   // إضافة رحلة جديدة مع تحديث الحساب فوري
// //   // ---------------------------
// //   Future<void> _addNewTrip(Map<String, dynamic> tripData) async {
// //     try {
// //       await _firestore.collection('drivers').add(tripData);

// //       // تحديث شغل السائق مباشرة إذا مفتوح
// //       if (_selectedDriver == tripData['driverName']) {
// //         await _loadDriverWork(_selectedDriver!);
// //       }

// //       // تحديث ملخص النولون
// //       await rebuildDriverSummariesNolonOnly();

// //       _showSuccess('تم إضافة الرحلة وتحديث الحساب.');
// //     } catch (e) {
// //       _showError('خطأ في إضافة الرحلة: $e');
// //     }
// //   }

// //   // ---------------------------
// //   // تحميل شغل سائق محدد
// //   // ---------------------------
// //   Future<void> _loadDriverWork(String driverName) async {
// //     setState(() {
// //       _selectedDriver = driverName;
// //       _isLoading = true;
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
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() => _isLoading = false);
// //       _showError('خطأ في تحميل الشغل');
// //     }
// //   }

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

// //   void _showError(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text(message), backgroundColor: Colors.red),
// //     );
// //   }

// //   void _showSuccess(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text(message), backgroundColor: Colors.green),
// //     );
// //   }

// //   String _formatDate(DateTime? date) {
// //     if (date == null) return '-';
// //     return DateFormat('dd/MM/yyyy').format(date);
// //   }

// //   Widget _buildCustomAppBar() {
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
// //             Icon(Icons.people, color: Colors.white, size: 28),
// //             SizedBox(width: 12),
// //             Text(
// //               _selectedDriver == null
// //                   ? 'شغل السائقين'
// //                   : '$_selectedDriverشغل السائق ',
// //               style: const TextStyle(
// //                 color: Colors.white,
// //                 fontSize: 20,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             const Spacer(),
// //             StreamBuilder<DateTime>(
// //               stream: Stream.periodic(
// //                 const Duration(seconds: 1),
// //                 (_) => DateTime.now(),
// //               ),
// //               builder: (context, snapshot) {
// //                 final now = snapshot.data ?? DateTime.now();
// //                 int hour12 = now.hour % 12;
// //                 if (hour12 == 0) hour12 = 12;
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

// //   // ---------------------------
// //   // UI Build
// //   // ---------------------------
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF4F6F8),

// //       body: Column(
// //         children: [
// //           // AppBar
// //           _buildCustomAppBar(),

// //           // Container(
// //           //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //           //   decoration: const BoxDecoration(
// //           //     gradient: LinearGradient(
// //           //       begin: Alignment.centerRight,
// //           //       end: Alignment.centerLeft,
// //           //       colors: [Color(0xFF1B4F72), Color(0xFF3498DB)],
// //           //     ),
// //           //     boxShadow: [
// //           //       BoxShadow(
// //           //         color: Colors.black26,
// //           //         blurRadius: 8,
// //           //         offset: Offset(0, 2),
// //           //       ),
// //           //     ],
// //           //   ),
// //           //   child: SafeArea(
// //           //     child: Row(
// //           //       children: [
// //           //         const Icon(Icons.person, color: Colors.white, size: 28),
// //           //         const SizedBox(width: 8),
// //           //         Expanded(
// //           //           child:
// //           //         ),
// //           //         if (_selectedDriver != null)
// //           //           IconButton(
// //           //             icon: const Icon(Icons.arrow_back, color: Colors.white),
// //           //             onPressed: () {
// //           //               setState(() {
// //           //                 _selectedDriver = null;
// //           //                 _driverWork.clear();
// //           //                 _filteredDriverWork.clear();
// //           //               });
// //           //               _loadAllDriverData();
// //           //             },
// //           //           ),
// //           //       ],
// //           //     ),
// //           //   ),
// //           // ),
// //           if (_selectedDriver == null) _buildTimeFilterSection(),

// //           Expanded(
// //             child: _selectedDriver == null
// //                 ? _buildDriverList()
// //                 : _buildWorkTable(),
// //           ),
// //         ],
// //       ),
// //       // floatingActionButton: FloatingActionButton(
// //       //   onPressed: () async {
// //       //     await _loadAllDriverData();
// //       //     await rebuildDriverSummariesNolonOnly();
// //       //   },
// //       //   backgroundColor: const Color(0xFF3498DB),
// //       //   child: const Icon(Icons.refresh, color: Colors.white),
// //       //   tooltip: 'تحديث',
// //       // ),
// //     );
// //   }

// //   Widget _buildDriverList() {
// //     if (_isLoading) return const Center(child: CircularProgressIndicator());

// //     final driversWithTrips = _filteredDrivers
// //         .where((d) => d['hasTripsInFilter'])
// //         .toList();
// //     final driversWithoutTrips = _filteredDrivers
// //         .where((d) => !d['hasTripsInFilter'])
// //         .toList();

// //     return ListView(
// //       padding: const EdgeInsets.all(8),
// //       children: [
// //         ...driversWithTrips.map((driver) => _buildDriverCard(driver)),
// //         if (driversWithTrips.isEmpty && driversWithoutTrips.isNotEmpty)
// //           Container(
// //             margin: const EdgeInsets.all(16),
// //             padding: const EdgeInsets.all(20),
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(12),
// //               border: Border.all(color: Colors.grey[300]!),
// //             ),
// //             child: Column(
// //               children: [
// //                 Icon(Icons.calendar_today, size: 60, color: Colors.grey[400]),
// //                 const SizedBox(height: 16),
// //                 Text(
// //                   _timeFilter == 'مخصص'
// //                       ? 'لا توجد رحلات في شهر $_selectedMonth سنة $_selectedYear'
// //                       : 'لا توجد رحلات في الفترة المحددة',
// //                   style: const TextStyle(
// //                     fontSize: 16,
// //                     color: Colors.grey,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                   textAlign: TextAlign.center,
// //                 ),
// //                 const SizedBox(height: 8),
// //                 const Text(
// //                   'اختر فترة زمنية مختلفة',
// //                   style: TextStyle(fontSize: 14, color: Colors.grey),
// //                   textAlign: TextAlign.center,
// //                 ),
// //               ],
// //             ),
// //           ),
// //       ],
// //     );
// //   }

// //   Widget _buildDriverCard(Map<String, dynamic> driver) {
// //     final driverName = driver['driverName'];
// //     final filteredTripsCount = driver['filteredTripsCount'];
// //     final totalTrips = driver['totalTrips'];
// //     final hasTrips = driver['hasTripsInFilter'];

// //     return Container(
// //       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(
// //           color: hasTrips
// //               ? const Color(0xFF3498DB).withOpacity(0.3)
// //               : Colors.grey.withOpacity(0.3),
// //         ),
// //       ),
// //       child: ListTile(
// //         leading: Container(
// //           width: 45,
// //           height: 45,
// //           decoration: BoxDecoration(
// //             color: hasTrips ? const Color(0xFF3498DB) : Colors.grey,
// //             borderRadius: BorderRadius.circular(22.5),
// //           ),
// //           child: Center(
// //             child: Text(
// //               filteredTripsCount.toString(),
// //               style: const TextStyle(
// //                 color: Colors.white,
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 16,
// //               ),
// //             ),
// //           ),
// //         ),
// //         title: Text(
// //           driverName,
// //           style: TextStyle(
// //             fontWeight: FontWeight.bold,
// //             fontSize: 16,
// //             color: hasTrips ? const Color(0xFF2C3E50) : Colors.grey,
// //           ),
// //         ),
// //         subtitle: Text(
// //           'إجمالي الرحلات: $totalTrips',
// //           style: const TextStyle(color: Colors.grey, fontSize: 12),
// //         ),
// //         trailing: Icon(
// //           Icons.arrow_forward_ios,
// //           color: hasTrips ? const Color(0xFF3498DB) : Colors.grey,
// //           size: 16,
// //         ),
// //         onTap: hasTrips ? () => _loadDriverWork(driverName) : null,
// //       ),
// //     );
// //   }

// //   Widget _buildWorkTable() {
// //     if (_isLoading) return const Center(child: CircularProgressIndicator());

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
// //                               // العمود المضاف
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
// //                             final totalNolonRow =
// //                                 (work['wheelNolon'] ?? 0.0) +
// //                                 (work['wheelOvernight'] ?? 0.0) +
// //                                 (work['wheelHoliday'] ?? 0.0);

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
// //                                 // TableCellBody(
// //                                 //   '${totalNolonRow.toStringAsFixed(2)} ج',
// //                                 //   textStyle: const TextStyle(
// //                                 //     fontWeight: FontWeight.bold,
// //                                 //     color: Colors.blue,
// //                                 //   ),
// //                                 // ), // إجمالي النولون للسطر
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
// //                           }).toList(),
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

// //   Widget _buildTimeFilterSection() {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
// //       color: Colors.white,
// //       child: Column(
// //         children: [
// //           TextField(
// //             decoration: InputDecoration(
// //               hintText: 'ابحث باسم السائق',
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
// //                 _driverSearchQuery = value;
// //                 _filteredDrivers = _allDrivers
// //                     .where(
// //                       (d) => d['driverName'].toLowerCase().contains(
// //                         _driverSearchQuery.toLowerCase(),
// //                       ),
// //                     )
// //                     .toList();
// //               });
// //             },
// //           ),
// //           const SizedBox(height: 12),
// //           SingleChildScrollView(
// //             scrollDirection: Axis.horizontal,
// //             child: Row(
// //               // children: ['الكل', 'اليوم', 'هذا الشهر', 'هذه السنة']
// //               //     .map(
// //               //       (filter) => Padding(
// //               //         padding: const EdgeInsets.symmetric(horizontal: 4),
// //               //         child: ChoiceChip(
// //               //           label: Text(filter),
// //               //           selected: _timeFilter == filter,
// //               //           onSelected: (selected) {
// //               //             if (selected) _changeTimeFilter(filter);
// //               //           },
// //               //           selectedColor: const Color(0xFF3498DB),
// //               //           labelStyle: TextStyle(
// //               //             color: _timeFilter == filter
// //               //                 ? Colors.white
// //               //                 : const Color(0xFF2C3E50),
// //               //           ),
// //               //         ),
// //               //       ),
// //               //     )
// //               //     .toList(),
// //             ),
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
//   List<Map<String, dynamic>> _driverWork = []; // شغل السائق المحدد
//   List<Map<String, dynamic>> _filteredDriverWork = []; // شغل السائق المصفى

//   // حالات التحديد
//   String? _selectedContractor;
//   String? _selectedDriver;

//   // حالات التحميل
//   bool _isLoading = false;
//   bool _isLoadingDrivers = false;
//   bool _isLoadingWork = false;

//   // الفلاتر
//   String _searchContractorQuery = '';
//   String _searchDriverQuery = '';
//   String _timeFilter = 'الكل';
//   int _selectedMonth = DateTime.now().month;
//   int _selectedYear = DateTime.now().year;

//   @override
//   void initState() {
//     super.initState();
//     _loadContractors();
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
//             'totalWheelNolon': 0.0,
//             'totalPaid': 0.0,
//             'lastTripDate': null,
//           };
//         }

//         final driverData = driversMap[driverName]!;

//         // تحديث الإحصائيات
//         driverData['totalTrips'] = driverData['totalTrips']! + 1;
//         driverData['totalWheelNolon'] =
//             (driverData['totalWheelNolon'] ?? 0.0) +
//             ((data['wheelNolon'] ?? 0).toDouble() +
//                 (data['wheelOvernight'] ?? 0).toDouble() +
//                 (data['wheelHoliday'] ?? 0).toDouble());
//         driverData['totalPaid'] =
//             (driverData['totalPaid'] ?? 0.0) +
//             (data['paidAmount'] ?? 0).toDouble();

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
//   // تحميل شغل سائق محدد - الإصدار المعدل
//   // ---------------------------
//   Future<void> _loadDriverWork(String driverName) async {
//     if (driverName.isEmpty || _selectedContractor == null) return;

//     setState(() {
//       _selectedDriver = driverName;
//       _isLoadingWork = true;
//       _driverWork.clear();
//       _filteredDriverWork.clear();
//     });

//     try {
//       print('جارٍ تحميل شغل السائق: $driverName');
//       print('للمقاول: $_selectedContractor');

//       // استعلام واحد فقط حسب اسم السائق (لأن المقاول قد لا يكون صحيحاً في البيانات القديمة)
//       final snapshot = await _firestore
//           .collection('drivers')
//           .where('driverName', isEqualTo: driverName)
//           .orderBy('date', descending: true)
//           .get();

//       print('تم العثور على ${snapshot.docs.length} مستند');

//       List<Map<String, dynamic>> workList = [];

//       for (final doc in snapshot.docs) {
//         final data = doc.data();
//         final docContractor = (data['contractor'] ?? '').toString().trim();
//         final docDriverName = (data['driverName'] ?? '').toString().trim();

//         // تحقق من أن السائق هو المطلوب
//         if (docDriverName != driverName) continue;

//         DateTime? date = (data['date'] as Timestamp?)?.toDate();

//         workList.add({
//           'id': doc.id,
//           'date': date,
//           'companyName': data['companyName'] ?? 'غير معروف',
//           'companyId': data['companyId'] ?? '',
//           'loadingLocation': data['loadingLocation'] ?? '',
//           'unloadingLocation': data['unloadingLocation'] ?? '',
//           'selectedRoute': data['selectedRoute'] ?? '',
//           'ohda': data['ohda'] ?? '',
//           'karta': data['karta'] ?? '',
//           'wheelNolon': (data['wheelNolon'] ?? 0).toDouble(),
//           'wheelOvernight': (data['wheelOvernight'] ?? 0).toDouble(),
//           'wheelHoliday': (data['wheelHoliday'] ?? 0).toDouble(),
//           'selectedPrice': (data['selectedPrice'] ?? 0).toDouble(),
//           'contractor': docContractor,
//           'tr': data['tr'] ?? '',
//           'isPaid': data['isPaid'] ?? false,
//           'paidAmount': (data['paidAmount'] ?? 0).toDouble(),
//           'remainingAmount': (data['remainingAmount'] ?? 0).toDouble(),
//           'paymentDate': data['paymentDate'] as Timestamp?,
//           'driverNotes': data['driverNotes'] ?? '',
//           'selectedVehicleType': data['selectedVehicleType'] ?? '',
//           'selectedNotes': data['selectedNotes'] ?? '',
//           'priceOfferId': data['priceOfferId'] ?? '',
//           'createdAt': data['createdAt'] as Timestamp?,
//           'updatedAt': data['updatedAt'] as Timestamp?,
//         });
//       }

//       // إذا لم نجد رحلات، نحاول البحث بدون شرط المقاول (للبيانات القديمة)
//       if (workList.isEmpty) {
//         print('لم يتم العثور على رحلات، جارٍ البحث بدون شرط المقاول...');

//         final fallbackSnapshot = await _firestore
//             .collection('drivers')
//             .where('driverName', isEqualTo: driverName)
//             .orderBy('date', descending: true)
//             .get();

//         for (final doc in fallbackSnapshot.docs) {
//           final data = doc.data();
//           final docDriverName = (data['driverName'] ?? '').toString().trim();

//           if (docDriverName == driverName) {
//             DateTime? date = (data['date'] as Timestamp?)?.toDate();

//             workList.add({
//               'id': doc.id,
//               'date': date,
//               'companyName': data['companyName'] ?? 'غير معروف',
//               'companyId': data['companyId'] ?? '',
//               'loadingLocation': data['loadingLocation'] ?? '',
//               'unloadingLocation': data['unloadingLocation'] ?? '',
//               'selectedRoute': data['selectedRoute'] ?? '',
//               'ohda': data['ohda'] ?? '',
//               'karta': data['karta'] ?? '',
//               'wheelNolon': (data['wheelNolon'] ?? 0).toDouble(),
//               'wheelOvernight': (data['wheelOvernight'] ?? 0).toDouble(),
//               'wheelHoliday': (data['wheelHoliday'] ?? 0).toDouble(),
//               'selectedPrice': (data['selectedPrice'] ?? 0).toDouble(),
//               'contractor': data['contractor'] ?? 'غير محدد',
//               'tr': data['tr'] ?? '',
//               'isPaid': data['isPaid'] ?? false,
//               'paidAmount': (data['paidAmount'] ?? 0).toDouble(),
//               'remainingAmount': (data['remainingAmount'] ?? 0).toDouble(),
//               'paymentDate': data['paymentDate'] as Timestamp?,
//               'driverNotes': data['driverNotes'] ?? '',
//               'selectedVehicleType': data['selectedVehicleType'] ?? '',
//               'selectedNotes': data['selectedNotes'] ?? '',
//               'priceOfferId': data['priceOfferId'] ?? '',
//               'createdAt': data['createdAt'] as Timestamp?,
//               'updatedAt': data['updatedAt'] as Timestamp?,
//             });
//           }
//         }
//       }

//       // ترتيب حسب التاريخ (تنازلياً)
//       workList.sort((a, b) {
//         final dateA = a['date'] as DateTime?;
//         final dateB = b['date'] as DateTime?;
//         if (dateA == null && dateB == null) return 0;
//         if (dateA == null) return 1;
//         if (dateB == null) return -1;
//         return dateB.compareTo(dateA);
//       });

//       print('تم تحميل ${workList.length} رحلة');

//       setState(() {
//         _driverWork = workList;
//         _filteredDriverWork = _filterWorkByDate(workList);
//         _isLoadingWork = false;
//       });

//       if (workList.isEmpty) {
//         _showMessage('لا يوجد شغل مسجل لهذا السائق');
//       }
//     } catch (e) {
//       print('خطأ في تحميل الشغل: $e');
//       setState(() => _isLoadingWork = false);
//       _showError('خطأ في تحميل الشغل: $e');
//     }
//   }

//   // ---------------------------
//   // تصفية الشغل حسب التاريخ - الإصدار المعدل
//   // ---------------------------
//   List<Map<String, dynamic>> _filterWorkByDate(
//     List<Map<String, dynamic>> workList,
//   ) {
//     if (_timeFilter == 'الكل') return List.from(workList);

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

//   void _showMessage(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.blue,
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   String _formatDate(DateTime? date) {
//     if (date == null) return '-';
//     return DateFormat('dd/MM/yyyy').format(date);
//   }

//   // ---------------------------
//   // AppBar
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
//                     final totalWheelNolon = driver['totalWheelNolon'] ?? 0.0;
//                     final totalPaid = driver['totalPaid'] ?? 0.0;
//                     final totalRemaining = totalWheelNolon - totalPaid;

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
//                             SizedBox(height: 2),
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.attach_money,
//                                   size: 14,
//                                   color: Colors.grey,
//                                 ),
//                                 SizedBox(width: 4),
//                                 Text(
//                                   'المتبقي: ${totalRemaining.toStringAsFixed(2)} ج',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: totalRemaining > 0
//                                         ? Colors.red
//                                         : Colors.green,
//                                     fontWeight: FontWeight.bold,
//                                   ),
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
//   // واجهة جدول شغل السائق - الإصدار المعدل
//   // ---------------------------
//   Widget _buildDriverWorkTable() {
//     if (_isLoadingWork) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
//             ),
//             SizedBox(height: 16),
//             Text('جارٍ تحميل شغل السائق...'),
//           ],
//         ),
//       );
//     }

//     return Column(
//       children: [
//         // فلتر الوقت
//         _buildTimeFilterSection(),

//         // معلومات السائق
//         Container(
//           padding: EdgeInsets.all(16),
//           color: Colors.blue[50],
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'السائق: $_selectedDriver',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: Color(0xFF2C3E50),
//                     ),
//                   ),
//                   Text(
//                     'المقاول: $_selectedContractor',
//                     style: TextStyle(color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     'عدد الرحلات: ${_filteredDriverWork.length}',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF3498DB),
//                     ),
//                   ),
//                   Text(
//                     'عرض: ${_getFilterText()}',
//                     style: TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),

//         // الجدول
//         Expanded(
//           child: _filteredDriverWork.isEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.work_off, size: 60, color: Colors.grey),
//                       SizedBox(height: 16),
//                       Text(
//                         _driverWork.isEmpty
//                             ? 'لا يوجد شغل مسجل لهذا السائق'
//                             : 'لا يوجد شغل في الفترة المحددة',
//                         style: TextStyle(
//                           color: Colors.grey,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       if (_timeFilter != 'الكل')
//                         ElevatedButton(
//                           onPressed: () {
//                             setState(() => _timeFilter = 'الكل');
//                             _filteredDriverWork = _driverWork;
//                           },
//                           child: Text('عرض كل الرحلات'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Color(0xFF3498DB),
//                           ),
//                         ),
//                     ],
//                   ),
//                 )
//               : _buildWorkTableContent(),
//         ),
//       ],
//     );
//   }

//   // ---------------------------
//   // محتوى جدول الشغل
//   // ---------------------------
//   Widget _buildWorkTableContent() {
//     // حساب الإجماليات
//     double totalWheelNolon = 0;
//     double totalOvernight = 0;
//     double totalHoliday = 0;
//     double totalPaid = 0;

//     for (final work in _filteredDriverWork) {
//       totalWheelNolon += (work['wheelNolon'] ?? 0).toDouble();
//       totalOvernight += (work['wheelOvernight'] ?? 0).toDouble();
//       totalHoliday += (work['wheelHoliday'] ?? 0).toDouble();
//       totalPaid += (work['paidAmount'] ?? 0).toDouble();
//     }

//     final totalAll = totalWheelNolon + totalOvernight + totalHoliday;
//     final totalRemaining = totalAll - totalPaid;

//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           // الإجماليات
//           Container(
//             padding: EdgeInsets.all(12),
//             color: Colors.green[50],
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildSummaryItem('نولون العجل', totalWheelNolon, Colors.blue),
//                 _buildSummaryItem('مبيت العجل', totalOvernight, Colors.orange),
//                 _buildSummaryItem('عطلة العجل', totalHoliday, Colors.red),
//                 _buildSummaryItem('الإجمالي', totalAll, Colors.green),
//                 _buildSummaryItem(
//                   'المتبقي',
//                   totalRemaining,
//                   totalRemaining > 0 ? Colors.red : Colors.green,
//                 ),
//               ],
//             ),
//           ),

//           // الجدول
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: DataTable(
//               columnSpacing: 12,
//               horizontalMargin: 12,
//               headingRowHeight: 60,
//               dataRowHeight: 50,
//               headingRowColor: MaterialStateProperty.all(
//                 Color(0xFF3498DB).withOpacity(0.1),
//               ),
//               columns: [
//                 DataColumn(label: _buildTableHeader('م')),
//                 DataColumn(label: _buildTableHeader('التاريخ')),
//                 DataColumn(label: _buildTableHeader('الشركة')),
//                 DataColumn(label: _buildTableHeader('مكان التحميل')),
//                 DataColumn(label: _buildTableHeader('مكان التعتيق')),
//                 DataColumn(label: _buildTableHeader('المسار')),
//                 DataColumn(label: _buildTableHeader('العهدة')),
//                 DataColumn(label: _buildTableHeader('الكارتة')),
//                 DataColumn(label: _buildTableHeader('نولون العجل')),
//                 DataColumn(label: _buildTableHeader('مبيت العجل')),
//                 DataColumn(label: _buildTableHeader('عطلة العجل')),
//                 DataColumn(label: _buildTableHeader('الإجمالي')),
//                 DataColumn(label: _buildTableHeader('المقاول')),
//                 DataColumn(label: _buildTableHeader('TR')),
//                 DataColumn(label: _buildTableHeader('الحالة')),
//               ],
//               rows: _filteredDriverWork.asMap().entries.map((entry) {
//                 final index = entry.key;
//                 final work = entry.value;

//                 final wheelNolon = (work['wheelNolon'] ?? 0).toDouble();
//                 final overnight = (work['wheelOvernight'] ?? 0).toDouble();
//                 final holiday = (work['wheelHoliday'] ?? 0).toDouble();
//                 final rowTotal = wheelNolon + overnight + holiday;
//                 final isPaid = work['isPaid'] ?? false;
//                 final paidAmount = (work['paidAmount'] ?? 0).toDouble();
//                 final remaining = rowTotal - paidAmount;

//                 return DataRow(
//                   color: MaterialStateProperty.resolveWith<Color?>((
//                     Set<MaterialState> states,
//                   ) {
//                     if (index.isEven) {
//                       return Colors.grey[50];
//                     }
//                     return null;
//                   }),
//                   cells: [
//                     DataCell(Text('${index + 1}')),
//                     DataCell(Text(_formatDate(work['date']))),
//                     DataCell(
//                       Container(
//                         width: 100,
//                         child: Text(
//                           work['companyName'],
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ),
//                     DataCell(
//                       Container(
//                         width: 100,
//                         child: Text(
//                           work['loadingLocation'],
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ),
//                     DataCell(
//                       Container(
//                         width: 100,
//                         child: Text(
//                           work['unloadingLocation'],
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ),
//                     DataCell(
//                       Container(
//                         width: 120,
//                         child: Text(
//                           work['selectedRoute'],
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             color: Color(0xFF3498DB),
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                     DataCell(Text(work['ohda'])),
//                     DataCell(Text(work['karta'])),
//                     DataCell(
//                       Text(
//                         '${wheelNolon.toStringAsFixed(2)} ج',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     DataCell(
//                       Text(
//                         '${overnight.toStringAsFixed(2)} ج',
//                         style: TextStyle(color: Colors.orange),
//                       ),
//                     ),
//                     DataCell(
//                       Text(
//                         '${holiday.toStringAsFixed(2)} ج',
//                         style: TextStyle(color: Colors.red),
//                       ),
//                     ),
//                     DataCell(
//                       Text(
//                         '${rowTotal.toStringAsFixed(2)} ج',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green,
//                         ),
//                       ),
//                     ),
//                     DataCell(Text(work['contractor'])),
//                     DataCell(Text(work['tr'])),
//                     DataCell(
//                       Container(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: isPaid ? Colors.green[100] : Colors.red[100],
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Text(
//                           isPaid ? 'مدفوع' : 'غير مدفوع',
//                           style: TextStyle(
//                             color: isPaid ? Colors.green[800] : Colors.red[800],
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryItem(String label, double value, Color color) {
//     return Column(
//       children: [
//         Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
//         SizedBox(height: 4),
//         Text(
//           '${value.toStringAsFixed(2)} ج',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTableHeader(String text) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8),
//       child: Text(
//         text,
//         style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }

//   // ---------------------------
//   // قسم فلتر الوقت
//   // ---------------------------
//   Widget _buildTimeFilterSection() {
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//       color: Colors.white,
//       child: Column(
//         children: [
//           // الفلاتر السريعة
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: ['الكل', 'اليوم', 'هذا الشهر', 'هذه السنة', 'مخصص']
//                   .map(
//                     (filter) => Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 4),
//                       child: ChoiceChip(
//                         label: Text(filter),
//                         selected: _timeFilter == filter,
//                         onSelected: (selected) {
//                           if (selected) _changeTimeFilter(filter);
//                         },
//                         selectedColor: Color(0xFF3498DB),
//                         labelStyle: TextStyle(
//                           color: _timeFilter == filter
//                               ? Colors.white
//                               : Color(0xFF2C3E50),
//                         ),
//                       ),
//                     ),
//                   )
//                   .toList(),
//             ),
//           ),

//           // فلتر مخصص (شهر/سنة)
//           if (_timeFilter == 'مخصص')
//             Container(
//               margin: EdgeInsets.only(top: 12),
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.grey[50],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.calendar_month, color: Color(0xFF3498DB)),
//                   SizedBox(width: 8),
//                   DropdownButton<int>(
//                     value: _selectedMonth,
//                     onChanged: (value) {
//                       if (value != null) {
//                         setState(() => _selectedMonth = value);
//                         _applyMonthYearFilter();
//                       }
//                     },
//                     items: List.generate(12, (index) {
//                       final monthNumber = index + 1;
//                       return DropdownMenuItem(
//                         value: monthNumber,
//                         child: Text('شهر $monthNumber'),
//                       );
//                     }),
//                   ),
//                   SizedBox(width: 20),
//                   DropdownButton<int>(
//                     value: _selectedYear,
//                     onChanged: (value) {
//                       if (value != null) {
//                         setState(() => _selectedYear = value);
//                         _applyMonthYearFilter();
//                       }
//                     },
//                     items: [
//                       for (
//                         int i = DateTime.now().year - 2;
//                         i <= DateTime.now().year + 2;
//                         i++
//                       )
//                         DropdownMenuItem(value: i, child: Text('$i')),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   String _getFilterText() {
//     switch (_timeFilter) {
//       case 'اليوم':
//         return 'اليوم';
//       case 'هذا الشهر':
//         return 'هذا الشهر';
//       case 'هذه السنة':
//         return 'هذه السنة';
//       case 'مخصص':
//         return 'شهر $_selectedMonth سنة $_selectedYear';
//       default:
//         return 'الكل';
//     }
//   }

//   // ---------------------------
//   // الواجهة الرئيسية
//   // ---------------------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF4F6F8),
//       body: Column(
//         children: [
//           _buildCustomAppBar(),
//           Expanded(
//             child: _selectedDriver != null
//                 ? _buildDriverWorkTable()
//                 : (_selectedContractor != null
//                       ? _buildDriversList()
//                       : _buildContractorsList()),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           if (_selectedDriver != null) {
//             _loadDriverWork(_selectedDriver!);
//           } else if (_selectedContractor != null) {
//             _loadDriversByContractor(_selectedContractor!);
//           } else {
//             _loadContractors();
//           }
//         },
//         backgroundColor: Color(0xFF3498DB),
//         child: Icon(Icons.refresh, color: Colors.white),
//         tooltip: 'تحديث',
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  // بيانات شغل السائق (من الكود القديم)
  List<Map<String, dynamic>> _driverWork = [];
  List<Map<String, dynamic>> _filteredDriverWork = [];

  // حالات التحديد
  String? _selectedContractor;
  String? _selectedDriver;

  // حالات التحميل
  bool _isLoading = false;
  bool _isLoadingDrivers = false;
  bool _isLoadingWork = false;

  // الفلاتر
  String _searchContractorQuery = '';
  String _searchDriverQuery = '';
  String _timeFilter = 'الكل';
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadContractors();
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
  // تحميل شغل سائق محدد - من الكود القديم
  // ---------------------------
  Future<void> _loadDriverWork(String driverName) async {
    setState(() {
      _selectedDriver = driverName;
      _isLoadingWork = true;
      _driverWork.clear();
      _filteredDriverWork.clear();
    });

    try {
      final snapshot = await _firestore
          .collection('drivers')
          .where('driverName', isEqualTo: driverName)
          .orderBy('date', descending: true)
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
          'ohda': data['ohda'] ?? '',
          'karta': data['karta'] ?? '',
          'wheelNolon': (data['wheelNolon'] ?? 0).toDouble(),
          'wheelOvernight': (data['wheelOvernight'] ?? 0).toDouble(),
          'wheelHoliday': (data['wheelHoliday'] ?? 0).toDouble(),
          'selectedPrice': (data['selectedPrice'] ?? 0).toDouble(),
          'isPaid': data['isPaid'] ?? false,
          'paidAmount': (data['paidAmount'] ?? 0).toDouble(),
          'remainingAmount': (data['remainingAmount'] ?? 0).toDouble(),
          'paymentDate': data['paymentDate'] as Timestamp?,
          'driverNotes': data['driverNotes'] ?? '',
        });
      }

      setState(() {
        _driverWork = workList;
        _filteredDriverWork = _filterWorkByDate(workList);
        _isLoadingWork = false;
      });
    } catch (e) {
      setState(() => _isLoadingWork = false);
      _showError('خطأ في تحميل الشغل');
    }
  }

  // ---------------------------
  // تصفية الشغل حسب التاريخ - من الكود القديم
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
  // AppBar
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
  // واجهة جدول شغل السائق - من الكود القديم (بدون تغييرات)
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
                              // العمود المضاف
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
                            final totalNolonRow =
                                (work['wheelNolon'] ?? 0.0) +
                                (work['wheelOvernight'] ?? 0.0) +
                                (work['wheelHoliday'] ?? 0.0);

                            return TableRow(
                              decoration: BoxDecoration(
                                color: index.isEven
                                    ? Colors.white
                                    : const Color(0xFFF8F9FA),
                              ),
                              children: [
                                TableCellBody(
                                  '${work['wheelHoliday']} ج',
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                TableCellBody(
                                  '${work['wheelOvernight']} ج',
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TableCellBody(
                                  '${work['wheelNolon']} ج',
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                // TableCellBody(
                                //   '${totalNolonRow.toStringAsFixed(2)} ج',
                                //   textStyle: const TextStyle(
                                //     fontWeight: FontWeight.bold,
                                //     color: Colors.blue,
                                //   ),
                                // ), // إجمالي النولون للسطر
                                TableCellBody(work['karta']),
                                TableCellBody(work['ohda']),
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
  // قسم فلتر الوقت - من الكود القديم
  // ---------------------------
  Widget _buildTimeFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'ابحث باسم السائق',
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
                _searchDriverQuery = value;
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
  // الواجهة الرئيسية
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
                ? _buildWorkTable() // جدول شغل السائق (من الكود القديم)
                : (_selectedContractor != null
                      ? _buildDriversList()
                      : _buildContractorsList()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
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
      ),
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
