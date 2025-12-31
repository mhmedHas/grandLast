// // // // // // // import 'dart:async';
// // // // // // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // // // // // import 'package:flutter/material.dart';
// // // // // // // import 'package:intl/intl.dart';

// // // // // // // class CompanyWorkPage extends StatefulWidget {
// // // // // // //   const CompanyWorkPage({super.key});

// // // // // // //   @override
// // // // // // //   State<CompanyWorkPage> createState() => _CompanyWorkPageState();
// // // // // // // }

// // // // // // // class _CompanyWorkPageState extends State<CompanyWorkPage> {
// // // // // // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// // // // // // //   List<Map<String, dynamic>> _allCompanies = [];
// // // // // // //   List<Map<String, dynamic>> _filteredCompanies = [];
// // // // // // //   List<Map<String, dynamic>> _companyWork = [];
// // // // // // //   List<Map<String, dynamic>> _filteredCompanyWork = [];
// // // // // // //   String? _selectedCompany;
// // // // // // //   bool _isLoading = false;
// // // // // // //   String _searchQuery = '';

// // // // // // //   int _selectedMonth = DateTime.now().month;
// // // // // // //   int _selectedYear = DateTime.now().year;
// // // // // // //   String _timeFilter = 'الكل';

// // // // // // //   bool _hasSyncedOnEnter = false; // للتحقق من التحديث مرة واحدة عند الدخول

// // // // // // //   @override
// // // // // // //   void initState() {
// // // // // // //     super.initState();
// // // // // // //     _loadCompanies();
// // // // // // //   }

// // // // // // //   // ================================
// // // // // // //   // تحميل بيانات الشركات
// // // // // // //   // ================================
// // // // // // //   Future<void> _loadCompanies() async {
// // // // // // //     setState(() => _isLoading = true);
// // // // // // //     try {
// // // // // // //       final companiesSnapshot = await _firestore.collection('companies').get();
// // // // // // //       final dailyWorkSnapshot = await _firestore.collection('dailyWork').get();

// // // // // // //       final List<Map<String, dynamic>> companiesList = [];

// // // // // // //       for (final companyDoc in companiesSnapshot.docs) {
// // // // // // //         final companyData = companyDoc.data();
// // // // // // //         final companyId = companyDoc.id;
// // // // // // //         final companyName =
// // // // // // //             (companyData['name'] ??
// // // // // // //                     companyData['companyName'] ??
// // // // // // //                     'شركة غير معروفة')
// // // // // // //                 .toString()
// // // // // // //                 .trim();

// // // // // // //         final companyTrips = dailyWorkSnapshot.docs
// // // // // // //             .where((doc) {
// // // // // // //               final data = doc.data();
// // // // // // //               final tripCompanyId = data['companyId'] ?? '';
// // // // // // //               return tripCompanyId == companyId;
// // // // // // //             })
// // // // // // //             .map((doc) {
// // // // // // //               final data = doc.data();
// // // // // // //               final tripDate = (data['date'] as Timestamp?)?.toDate();

// // // // // // //               return {
// // // // // // //                 'id': doc.id,
// // // // // // //                 'date': tripDate,
// // // // // // //                 'companyName': companyName,
// // // // // // //                 'companyId': companyId,
// // // // // // //                 'driverName': data['driverName'] ?? 'غير معروف',
// // // // // // //                 'nolon': (data['noLon'] ?? data['nolon'] ?? 0).toDouble(),
// // // // // // //                 'companyOvernight': (data['companyOvernight'] ?? 0).toDouble(),
// // // // // // //                 'companyHoliday': (data['companyHoliday'] ?? 0).toDouble(),
// // // // // // //                 'selectedPrice': (data['selectedPrice'] ?? 0).toDouble(),
// // // // // // //                 'karta': data['karta'] ?? '',
// // // // // // //                 'ohda': data['ohda'] ?? '',
// // // // // // //                 'selectedRoute': data['selectedRoute'] ?? '',
// // // // // // //                 'loadingLocation': data['loadingLocation'] ?? '',
// // // // // // //                 'unloadingLocation': data['unloadingLocation'] ?? '',
// // // // // // //                 'vehicleType': data['selectedVehicleType'] ?? '',
// // // // // // //                 'notes': data['selectedNotes'] ?? '',
// // // // // // //               };
// // // // // // //             })
// // // // // // //             .toList();

// // // // // // //         final filteredTrips = _filterTripsByDate(companyTrips);

// // // // // // //         double totalNolon = 0.0;
// // // // // // //         double totalOvernight = 0.0;
// // // // // // //         double totalHoliday = 0.0;

// // // // // // //         for (var trip in companyTrips) {
// // // // // // //           totalNolon += trip['nolon'];
// // // // // // //           totalOvernight += trip['companyOvernight'];
// // // // // // //           totalHoliday += trip['companyHoliday'];
// // // // // // //         }

// // // // // // //         companiesList.add({
// // // // // // //           'companyId': companyId,
// // // // // // //           'companyName': companyName,
// // // // // // //           'companyData': companyData,
// // // // // // //           'allTrips': companyTrips,
// // // // // // //           'filteredTrips': filteredTrips,
// // // // // // //           'hasTripsInFilter': filteredTrips.isNotEmpty,
// // // // // // //           'totalTrips': companyTrips.length,
// // // // // // //           'filteredTripsCount': filteredTrips.length,
// // // // // // //           'totalNolon': totalNolon,
// // // // // // //           'totalOvernight': totalOvernight,
// // // // // // //           'totalHoliday': totalHoliday,
// // // // // // //         });
// // // // // // //       }

// // // // // // //       companiesList.sort((a, b) => b['totalNolon'].compareTo(a['totalNolon']));

// // // // // // //       setState(() {
// // // // // // //         _allCompanies = companiesList;
// // // // // // //         _filteredCompanies = _applySearchFilter(companiesList);
// // // // // // //         _isLoading = false;
// // // // // // //       });

// // // // // // //       // تحديث تلقائي عند دخول الصفحة الرئيسية فقط
// // // // // // //       if (!_hasSyncedOnEnter && _selectedCompany == null) {
// // // // // // //         await _syncDataOnPageEnter();
// // // // // // //         _hasSyncedOnEnter = true;
// // // // // // //       }
// // // // // // //     } catch (e) {
// // // // // // //       setState(() => _isLoading = false);
// // // // // // //       debugPrint('خطأ في تحميل بيانات الشركات: $e');
// // // // // // //     }
// // // // // // //   }

// // // // // // //   // ================================
// // // // // // //   // تحديث تلقائي عند دخول الصفحة
// // // // // // //   // ================================
// // // // // // //   Future<void> _syncDataOnPageEnter() async {
// // // // // // //     debugPrint('🔄 بدء التحديث التلقائي عند دخول الصفحة...');

// // // // // // //     try {
// // // // // // //       // 1. جلب جميع حسابات الشركات
// // // // // // //       final companySummaries = await _firestore
// // // // // // //           .collection('companySummaries')
// // // // // // //           .get();

// // // // // // //       // 2. حساب إجمالي الرحلات من dailyWork لكل شركة
// // // // // // //       final dailyWorkSnapshot = await _firestore.collection('dailyWork').get();

// // // // // // //       Map<String, int> dailyWorkTripCounts = {};
// // // // // // //       Map<String, double> dailyWorkTotalDebts = {};
// // // // // // //       Map<String, String> companyNames = {};

// // // // // // //       for (final doc in dailyWorkSnapshot.docs) {
// // // // // // //         final data = doc.data();
// // // // // // //         final companyId = data['companyId'] as String?;
// // // // // // //         final companyName = data['companyName'] as String?;

// // // // // // //         if (companyId != null && companyName != null) {
// // // // // // //           // حساب عدد الرحلات
// // // // // // //           dailyWorkTripCounts[companyId] =
// // // // // // //               (dailyWorkTripCounts[companyId] ?? 0) + 1;
// // // // // // //           companyNames[companyId] = companyName;

// // // // // // //           // حساب إجمالي الدين
// // // // // // //           final nolon = (data['nolon'] ?? data['noLon'] ?? 0).toDouble();
// // // // // // //           final overnight = (data['companyOvernight'] ?? 0).toDouble();
// // // // // // //           final holiday = (data['companyHoliday'] ?? 0).toDouble();

// // // // // // //           dailyWorkTotalDebts[companyId] =
// // // // // // //               (dailyWorkTotalDebts[companyId] ?? 0.0) +
// // // // // // //               nolon +
// // // // // // //               overnight +
// // // // // // //               holiday;
// // // // // // //         }
// // // // // // //       }

// // // // // // //       // 3. المقارنة والتحديث
// // // // // // //       final batch = _firestore.batch();
// // // // // // //       final summariesRef = _firestore.collection('companySummaries');

// // // // // // //       int updatedCount = 0;

// // // // // // //       for (final entry in dailyWorkTripCounts.entries) {
// // // // // // //         final companyId = entry.key;
// // // // // // //         final dailyWorkTrips = entry.value;
// // // // // // //         final companyName = companyNames[companyId] ?? 'غير معروف';
// // // // // // //         final totalDebt = dailyWorkTotalDebts[companyId] ?? 0.0;

// // // // // // //         // البحث عن حساب الشركة
// // // // // // //         DocumentSnapshot? summaryDoc;
// // // // // // //         for (final doc in companySummaries.docs) {
// // // // // // //           final data = doc.data();
// // // // // // //           if (doc.id == companyId || data['companyId'] == companyId) {
// // // // // // //             summaryDoc = doc;
// // // // // // //             break;
// // // // // // //           }
// // // // // // //         }

// // // // // // //         if (summaryDoc != null && summaryDoc.exists) {
// // // // // // //           // تحقق من عدد الرحلات
// // // // // // //           final summaryData = summaryDoc.data() as Map<String, dynamic>;
// // // // // // //           final summaryTrips = (summaryData['totalTrips'] ?? 0).toInt();
// // // // // // //           final summaryDebt = (summaryData['totalCompanyDebt'] ?? 0).toDouble();

// // // // // // //           // إذا كان عدد الرحلات أو المبلغ غير متطابق
// // // // // // //           if (dailyWorkTrips != summaryTrips || totalDebt != summaryDebt) {
// // // // // // //             final totalPaidAmount = (summaryData['totalPaidAmount'] ?? 0)
// // // // // // //                 .toDouble();
// // // // // // //             final totalRemaining = totalDebt - totalPaidAmount;

// // // // // // //             String status;
// // // // // // //             if (totalRemaining <= 0) {
// // // // // // //               status = 'منتهية';
// // // // // // //             } else if (totalPaidAmount > 0) {
// // // // // // //               status = 'شبه منتهية';
// // // // // // //             } else {
// // // // // // //               status = 'جارية';
// // // // // // //             }

// // // // // // //             batch.set(summariesRef.doc(companyId), {
// // // // // // //               'companyId': companyId,
// // // // // // //               'companyName': companyName,
// // // // // // //               'totalCompanyDebt': totalDebt,
// // // // // // //               'totalPaidAmount': totalPaidAmount,
// // // // // // //               'totalRemainingAmount': totalRemaining,
// // // // // // //               'totalTrips': dailyWorkTrips,
// // // // // // //               'status': status,
// // // // // // //               'lastUpdated': Timestamp.now(),
// // // // // // //             }, SetOptions(merge: true));

// // // // // // //             updatedCount++;
// // // // // // //           }
// // // // // // //         } else {
// // // // // // //           // الشركة ليس لها حساب، إنشاء حساب جديد
// // // // // // //           batch.set(summariesRef.doc(companyId), {
// // // // // // //             'companyId': companyId,
// // // // // // //             'companyName': companyName,
// // // // // // //             'totalCompanyDebt': totalDebt,
// // // // // // //             'totalPaidAmount': 0.0,
// // // // // // //             'totalRemainingAmount': totalDebt,
// // // // // // //             'totalTrips': dailyWorkTrips,
// // // // // // //             'status': 'جارية',
// // // // // // //             'lastUpdated': Timestamp.now(),
// // // // // // //           });

// // // // // // //           updatedCount++;
// // // // // // //         }
// // // // // // //       }

// // // // // // //       // 4. حذف حسابات الشركات التي ليس لها رحلات
// // // // // // //       for (final doc in companySummaries.docs) {
// // // // // // //         final companyId = doc.id;
// // // // // // //         if (!dailyWorkTripCounts.containsKey(companyId)) {
// // // // // // //           final data = doc.data();
// // // // // // //           final dataCompanyId = data['companyId'] as String?;

// // // // // // //           // إذا الشركة ليس لها رحلات في dailyWork
// // // // // // //           if (!dailyWorkTripCounts.containsKey(dataCompanyId ?? '')) {
// // // // // // //             // يمكنك اختيار حذفها أو تركها
// // // // // // //             // batch.delete(summariesRef.doc(companyId));
// // // // // // //             debugPrint('⚠️ الشركة ${data['companyName']} ليس لها رحلات');
// // // // // // //           }
// // // // // // //         }
// // // // // // //       }

// // // // // // //       if (updatedCount > 0) {
// // // // // // //         await batch.commit();
// // // // // // //         debugPrint('✅ تم تحديث $updatedCount حساب شركة تلقائياً');
// // // // // // //       } else {
// // // // // // //         debugPrint('✅ جميع الحسابات محدثة بالفعل');
// // // // // // //       }
// // // // // // //     } catch (e) {
// // // // // // //       debugPrint('❌ خطأ في التحديث التلقائي: $e');
// // // // // // //     }
// // // // // // //   }

// // // // // // //   // ================================
// // // // // // //   // تحميل شغل شركة محددة بدون تحديث
// // // // // // //   // ================================
// // // // // // //   Future<void> _loadCompanyWork(String companyName) async {
// // // // // // //     setState(() {
// // // // // // //       _selectedCompany = companyName;
// // // // // // //       _isLoading = true;
// // // // // // //       _companyWork.clear();
// // // // // // //       _filteredCompanyWork.clear();
// // // // // // //     });

// // // // // // //     try {
// // // // // // //       final company = _allCompanies.firstWhere(
// // // // // // //         (c) => c['companyName'] == companyName,
// // // // // // //         orElse: () => {},
// // // // // // //       );

// // // // // // //       if (company.isEmpty) {
// // // // // // //         _showError('الشركة غير موجودة');
// // // // // // //         return;
// // // // // // //       }

// // // // // // //       final companyId = company['companyId'];

// // // // // // //       // جلب شغل الشركة فقط، بدون تحديث الحساب
// // // // // // //       final snapshot = await _firestore
// // // // // // //           .collection('dailyWork')
// // // // // // //           .where('companyId', isEqualTo: companyId)
// // // // // // //           .orderBy('date', descending: true)
// // // // // // //           .get();

// // // // // // //       List<Map<String, dynamic>> workList = [];

// // // // // // //       for (final doc in snapshot.docs) {
// // // // // // //         final data = doc.data();
// // // // // // //         DateTime? date = (data['date'] as Timestamp?)?.toDate();

// // // // // // //         workList.add({
// // // // // // //           'id': doc.id,
// // // // // // //           'date': date,
// // // // // // //           'companyName': data['companyName'] ?? 'غير معروف',
// // // // // // //           'driverName': data['driverName'] ?? 'غير معروف',
// // // // // // //           'loadingLocation': data['loadingLocation'] ?? '',
// // // // // // //           'unloadingLocation': data['unloadingLocation'] ?? '',
// // // // // // //           'selectedRoute': data['selectedRoute'] ?? '',
// // // // // // //           'ohda': data['ohda'] ?? '',
// // // // // // //           'karta': data['karta'] ?? '',
// // // // // // //           'nolon': (data['noLon'] ?? data['nolon'] ?? 0).toDouble(),
// // // // // // //           'companyOvernight': (data['companyOvernight'] ?? 0).toDouble(),
// // // // // // //           'companyHoliday': (data['companyHoliday'] ?? 0).toDouble(),
// // // // // // //           'selectedPrice': (data['selectedPrice'] ?? 0).toDouble(),
// // // // // // //           'vehicleType': data['selectedVehicleType'] ?? '',
// // // // // // //           'notes': data['selectedNotes'] ?? '',
// // // // // // //         });
// // // // // // //       }

// // // // // // //       setState(() {
// // // // // // //         _companyWork = workList;
// // // // // // //         _filteredCompanyWork = _filterWorkByDate(workList);
// // // // // // //         _isLoading = false;
// // // // // // //       });
// // // // // // //     } catch (e) {
// // // // // // //       setState(() => _isLoading = false);
// // // // // // //       _showError('خطأ في تحميل شغل الشركة: $e');
// // // // // // //     }
// // // // // // //   }

// // // // // // //   // ================================
// // // // // // //   // دوال التصفية والبحث
// // // // // // //   // ================================
// // // // // // //   List<Map<String, dynamic>> _filterTripsByDate(
// // // // // // //     List<Map<String, dynamic>> trips,
// // // // // // //   ) {
// // // // // // //     if (_timeFilter == 'الكل') return trips;
// // // // // // //     return trips.where((trip) {
// // // // // // //       final tripDate = trip['date'] as DateTime?;
// // // // // // //       if (tripDate == null) return false;
// // // // // // //       final now = DateTime.now();
// // // // // // //       switch (_timeFilter) {
// // // // // // //         case 'اليوم':
// // // // // // //           return tripDate.year == now.year &&
// // // // // // //               tripDate.month == now.month &&
// // // // // // //               tripDate.day == now.day;
// // // // // // //         case 'هذا الشهر':
// // // // // // //           return tripDate.year == now.year && tripDate.month == now.month;
// // // // // // //         case 'هذه السنة':
// // // // // // //           return tripDate.year == now.year;
// // // // // // //         case 'مخصص':
// // // // // // //           return tripDate.year == _selectedYear &&
// // // // // // //               tripDate.month == _selectedMonth;
// // // // // // //         default:
// // // // // // //           return true;
// // // // // // //       }
// // // // // // //     }).toList();
// // // // // // //   }

// // // // // // //   List<Map<String, dynamic>> _filterWorkByDate(
// // // // // // //     List<Map<String, dynamic>> workList,
// // // // // // //   ) {
// // // // // // //     return workList.where((work) {
// // // // // // //       final workDate = work['date'] as DateTime?;
// // // // // // //       if (workDate == null) return false;
// // // // // // //       final now = DateTime.now();
// // // // // // //       switch (_timeFilter) {
// // // // // // //         case 'اليوم':
// // // // // // //           return workDate.year == now.year &&
// // // // // // //               workDate.month == now.month &&
// // // // // // //               workDate.day == now.day;
// // // // // // //         case 'هذا الشهر':
// // // // // // //           return workDate.year == now.year && workDate.month == now.month;
// // // // // // //         case 'هذه السنة':
// // // // // // //           return workDate.year == now.year;
// // // // // // //         case 'مخصص':
// // // // // // //           return workDate.year == _selectedYear &&
// // // // // // //               workDate.month == _selectedMonth;
// // // // // // //         case 'الكل':
// // // // // // //         default:
// // // // // // //           return true;
// // // // // // //       }
// // // // // // //     }).toList();
// // // // // // //   }

// // // // // // //   List<Map<String, dynamic>> _applySearchFilter(
// // // // // // //     List<Map<String, dynamic>> companies,
// // // // // // //   ) {
// // // // // // //     if (_searchQuery.isEmpty) return companies;
// // // // // // //     return companies
// // // // // // //         .where(
// // // // // // //           (c) => c['companyName'].toLowerCase().contains(
// // // // // // //             _searchQuery.toLowerCase(),
// // // // // // //           ),
// // // // // // //         )
// // // // // // //         .toList();
// // // // // // //   }

// // // // // // //   void _updateFilter() {
// // // // // // //     setState(() {
// // // // // // //       for (var company in _allCompanies) {
// // // // // // //         final filteredTrips = _filterTripsByDate(company['allTrips']);
// // // // // // //         company['filteredTrips'] = filteredTrips;
// // // // // // //         company['hasTripsInFilter'] = filteredTrips.isNotEmpty;
// // // // // // //         company['filteredTripsCount'] = filteredTrips.length;
// // // // // // //       }
// // // // // // //       _filteredCompanies = _applySearchFilter(_allCompanies);
// // // // // // //     });
// // // // // // //   }

// // // // // // //   void _changeTimeFilter(String filter) {
// // // // // // //     setState(() => _timeFilter = filter);
// // // // // // //     _updateFilter();
// // // // // // //   }

// // // // // // //   void _applyMonthYearFilter() {
// // // // // // //     setState(() => _timeFilter = 'مخصص');
// // // // // // //     _updateFilter();
// // // // // // //   }

// // // // // // //   // ================================
// // // // // // //   // دوال مساعدة
// // // // // // //   // ================================
// // // // // // //   void _showError(String message) {
// // // // // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // // // // //       SnackBar(content: Text(message), backgroundColor: Colors.red),
// // // // // // //     );
// // // // // // //   }

// // // // // // //   void _showSuccess(String message) {
// // // // // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // // // // //       SnackBar(content: Text(message), backgroundColor: Colors.green),
// // // // // // //     );
// // // // // // //   }

// // // // // // //   String _formatDate(DateTime? date) {
// // // // // // //     if (date == null) return '-';
// // // // // // //     return DateFormat('dd/MM/yyyy').format(date);
// // // // // // //   }

// // // // // // //   // ================================
// // // // // // //   // عند الرجوع للصفحة الرئيسية
// // // // // // //   // ================================
// // // // // // //   void _backToMainPage() {
// // // // // // //     setState(() {
// // // // // // //       _selectedCompany = null;
// // // // // // //       _companyWork.clear();
// // // // // // //       _filteredCompanyWork.clear();
// // // // // // //       _hasSyncedOnEnter = false; // إعادة تعيين لعند الدخول التالي
// // // // // // //     });
// // // // // // //     _loadCompanies();
// // // // // // //   }

// // // // // // //   // ================================
// // // // // // //   // بناء الواجهة
// // // // // // //   // ================================
// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     return Scaffold(
// // // // // // //       backgroundColor: const Color(0xFFF4F6F8),
// // // // // // //       body: Column(
// // // // // // //         children: [
// // // // // // //           _buildCustomAppBar(),
// // // // // // //           if (_selectedCompany == null) _buildTimeFilterSection(),
// // // // // // //           if (_selectedCompany == null) _buildSearchBar(),
// // // // // // //           Expanded(
// // // // // // //             child: _selectedCompany == null
// // // // // // //                 ? _buildCompanyList()
// // // // // // //                 : _buildWorkTable(),
// // // // // // //           ),
// // // // // // //         ],
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }

// // // // // // //   Widget _buildCustomAppBar() {
// // // // // // //     return Container(
// // // // // // //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// // // // // // //       decoration: const BoxDecoration(
// // // // // // //         gradient: LinearGradient(
// // // // // // //           begin: Alignment.centerRight,
// // // // // // //           end: Alignment.centerLeft,
// // // // // // //           colors: [Color(0xFF1B4F72), Color(0xFF3498DB)],
// // // // // // //         ),
// // // // // // //         boxShadow: [
// // // // // // //           BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
// // // // // // //         ],
// // // // // // //       ),
// // // // // // //       child: SafeArea(
// // // // // // //         child: Row(
// // // // // // //           children: [
// // // // // // //             const Icon(Icons.business, color: Colors.white, size: 28),
// // // // // // //             const SizedBox(width: 8),
// // // // // // //             Expanded(
// // // // // // //               child: Center(
// // // // // // //                 child: Text(
// // // // // // //                   _selectedCompany == null
// // // // // // //                       ? 'شغل الشركات'
// // // // // // //                       : 'شغل شركة  $_selectedCompany',
// // // // // // //                   style: const TextStyle(
// // // // // // //                     color: Colors.white,
// // // // // // //                     fontSize: 20,
// // // // // // //                     fontWeight: FontWeight.bold,
// // // // // // //                   ),
// // // // // // //                 ),
// // // // // // //               ),
// // // // // // //             ),
// // // // // // //             if (_selectedCompany != null)
// // // // // // //               IconButton(
// // // // // // //                 icon: const Icon(Icons.arrow_back, color: Colors.white),
// // // // // // //                 onPressed: _backToMainPage,
// // // // // // //               ),
// // // // // // //           ],
// // // // // // //         ),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }

// // // // // // //   Widget _buildSearchBar() {
// // // // // // //     return Container(
// // // // // // //       padding: const EdgeInsets.all(12),
// // // // // // //       color: Colors.white,
// // // // // // //       child: Container(
// // // // // // //         padding: const EdgeInsets.symmetric(horizontal: 12),
// // // // // // //         decoration: BoxDecoration(
// // // // // // //           color: const Color(0xFFF4F6F8),
// // // // // // //           borderRadius: BorderRadius.circular(12),
// // // // // // //           border: Border.all(color: const Color(0xFF3498DB)),
// // // // // // //         ),
// // // // // // //         child: Row(
// // // // // // //           children: [
// // // // // // //             const Icon(Icons.search, color: Color(0xFF3498DB), size: 20),
// // // // // // //             const SizedBox(width: 8),
// // // // // // //             Expanded(
// // // // // // //               child: TextField(
// // // // // // //                 onChanged: (value) {
// // // // // // //                   setState(() {
// // // // // // //                     _searchQuery = value;
// // // // // // //                     _filteredCompanies = _applySearchFilter(_allCompanies);
// // // // // // //                   });
// // // // // // //                 },
// // // // // // //                 decoration: const InputDecoration(
// // // // // // //                   hintText: 'ابحث عن شركة...',
// // // // // // //                   border: InputBorder.none,
// // // // // // //                   hintStyle: TextStyle(color: Colors.grey),
// // // // // // //                 ),
// // // // // // //               ),
// // // // // // //             ),
// // // // // // //             if (_searchQuery.isNotEmpty)
// // // // // // //               GestureDetector(
// // // // // // //                 onTap: () {
// // // // // // //                   setState(() {
// // // // // // //                     _searchQuery = '';
// // // // // // //                     _filteredCompanies = _applySearchFilter(_allCompanies);
// // // // // // //                   });
// // // // // // //                 },
// // // // // // //                 child: const Icon(Icons.clear, size: 18, color: Colors.grey),
// // // // // // //               ),
// // // // // // //           ],
// // // // // // //         ),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }

// // // // // // //   Widget _buildTimeFilterSection() {
// // // // // // //     return Container(
// // // // // // //       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
// // // // // // //       color: Colors.white,
// // // // // // //       child: Column(
// // // // // // //         children: [
// // // // // // //           SingleChildScrollView(
// // // // // // //             scrollDirection: Axis.horizontal,
// // // // // // //             child: Row(
// // // // // // //               // يمكنك تفعيل الفلترات هنا إذا أردت
// // // // // // //             ),
// // // // // // //           ),
// // // // // // //           const SizedBox(height: 12),
// // // // // // //           Row(
// // // // // // //             mainAxisAlignment: MainAxisAlignment.center,
// // // // // // //             children: [
// // // // // // //               const Icon(Icons.calendar_month, color: Color(0xFF3498DB)),
// // // // // // //               const SizedBox(width: 8),
// // // // // // //               DropdownButton<int>(
// // // // // // //                 value: _selectedMonth,
// // // // // // //                 onChanged: (value) {
// // // // // // //                   if (value != null) {
// // // // // // //                     setState(() => _selectedMonth = value);
// // // // // // //                     _applyMonthYearFilter();
// // // // // // //                   }
// // // // // // //                 },
// // // // // // //                 items: List.generate(12, (index) {
// // // // // // //                   final monthNumber = index + 1;
// // // // // // //                   return DropdownMenuItem(
// // // // // // //                     value: monthNumber,
// // // // // // //                     child: Text('شهر $monthNumber'),
// // // // // // //                   );
// // // // // // //                 }),
// // // // // // //               ),
// // // // // // //               const SizedBox(width: 20),
// // // // // // //               DropdownButton<int>(
// // // // // // //                 value: _selectedYear,
// // // // // // //                 onChanged: (value) {
// // // // // // //                   if (value != null) {
// // // // // // //                     setState(() => _selectedYear = value);
// // // // // // //                     _applyMonthYearFilter();
// // // // // // //                   }
// // // // // // //                 },
// // // // // // //                 items: [
// // // // // // //                   for (
// // // // // // //                     int i = DateTime.now().year - 2;
// // // // // // //                     i <= DateTime.now().year + 2;
// // // // // // //                     i++
// // // // // // //                   )
// // // // // // //                     DropdownMenuItem(value: i, child: Text('$i')),
// // // // // // //                 ],
// // // // // // //               ),
// // // // // // //             ],
// // // // // // //           ),
// // // // // // //         ],
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }

// // // // // // //   Widget _buildCompanyList() {
// // // // // // //     if (_isLoading) return const Center(child: CircularProgressIndicator());

// // // // // // //     final companiesWithTrips = _filteredCompanies
// // // // // // //         .where((c) => c['hasTripsInFilter'])
// // // // // // //         .toList();
// // // // // // //     final companiesWithoutTrips = _filteredCompanies
// // // // // // //         .where((c) => !c['hasTripsInFilter'])
// // // // // // //         .toList();

// // // // // // //     return ListView(
// // // // // // //       padding: const EdgeInsets.all(8),
// // // // // // //       children: [
// // // // // // //         ...companiesWithTrips.map((company) => _buildCompanyCard(company)),
// // // // // // //         if (companiesWithTrips.isEmpty && companiesWithoutTrips.isNotEmpty)
// // // // // // //           Container(
// // // // // // //             margin: const EdgeInsets.all(16),
// // // // // // //             padding: const EdgeInsets.all(20),
// // // // // // //             decoration: BoxDecoration(
// // // // // // //               color: Colors.white,
// // // // // // //               borderRadius: BorderRadius.circular(12),
// // // // // // //               border: Border.all(color: Colors.grey[300]!),
// // // // // // //             ),
// // // // // // //             child: Column(
// // // // // // //               children: [
// // // // // // //                 Icon(Icons.business, size: 60, color: Colors.grey[400]),
// // // // // // //                 const SizedBox(height: 16),
// // // // // // //                 Text(
// // // // // // //                   _timeFilter == 'مخصص'
// // // // // // //                       ? 'لا توجد رحلات في شهر $_selectedMonth سنة $_selectedYear'
// // // // // // //                       : 'لا توجد رحلات في الفترة المحددة',
// // // // // // //                   style: const TextStyle(
// // // // // // //                     fontSize: 16,
// // // // // // //                     color: Colors.grey,
// // // // // // //                     fontWeight: FontWeight.bold,
// // // // // // //                   ),
// // // // // // //                   textAlign: TextAlign.center,
// // // // // // //                 ),
// // // // // // //               ],
// // // // // // //             ),
// // // // // // //           ),
// // // // // // //       ],
// // // // // // //     );
// // // // // // //   }

// // // // // // //   Widget _buildCompanyCard(Map<String, dynamic> company) {
// // // // // // //     final companyName = company['companyName'];
// // // // // // //     final filteredTripsCount = company['filteredTripsCount'];
// // // // // // //     final hasTrips = company['hasTripsInFilter'];

// // // // // // //     return Container(
// // // // // // //       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
// // // // // // //       decoration: BoxDecoration(
// // // // // // //         color: Colors.white,
// // // // // // //         borderRadius: BorderRadius.circular(12),
// // // // // // //         border: Border.all(
// // // // // // //           color: hasTrips
// // // // // // //               ? const Color(0xFF3498DB).withOpacity(0.3)
// // // // // // //               : Colors.grey.withOpacity(0.3),
// // // // // // //         ),
// // // // // // //         boxShadow: [
// // // // // // //           BoxShadow(
// // // // // // //             color: Colors.black.withOpacity(0.05),
// // // // // // //             blurRadius: 8,
// // // // // // //             offset: const Offset(0, 2),
// // // // // // //           ),
// // // // // // //         ],
// // // // // // //       ),
// // // // // // //       child: ListTile(
// // // // // // //         leading: Container(
// // // // // // //           width: 45,
// // // // // // //           height: 45,
// // // // // // //           decoration: BoxDecoration(
// // // // // // //             color: hasTrips ? const Color(0xFF3498DB) : Colors.grey,
// // // // // // //             borderRadius: BorderRadius.circular(22.5),
// // // // // // //           ),
// // // // // // //           child: Center(
// // // // // // //             child: Text(
// // // // // // //               filteredTripsCount.toString(),
// // // // // // //               style: const TextStyle(
// // // // // // //                 color: Colors.white,
// // // // // // //                 fontWeight: FontWeight.bold,
// // // // // // //                 fontSize: 16,
// // // // // // //               ),
// // // // // // //             ),
// // // // // // //           ),
// // // // // // //         ),
// // // // // // //         title: Text(
// // // // // // //           companyName,
// // // // // // //           style: TextStyle(
// // // // // // //             fontWeight: FontWeight.bold,
// // // // // // //             fontSize: 16,
// // // // // // //             color: hasTrips ? const Color(0xFF2C3E50) : Colors.grey,
// // // // // // //           ),
// // // // // // //         ),
// // // // // // //         subtitle: Column(
// // // // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // //           children: [
// // // // // // //             Text(
// // // // // // //               hasTrips
// // // // // // //                   ? '$filteredTripsCount :عدد الرحلات  '
// // // // // // //                   : 'لا توجد رحلات في الفترة المحددة',
// // // // // // //               style: TextStyle(
// // // // // // //                 color: hasTrips ? Colors.green : Colors.grey,
// // // // // // //                 fontSize: 12,
// // // // // // //               ),
// // // // // // //             ),
// // // // // // //           ],
// // // // // // //         ),
// // // // // // //         trailing: Icon(
// // // // // // //           Icons.arrow_forward_ios,
// // // // // // //           color: hasTrips ? const Color(0xFF3498DB) : Colors.grey,
// // // // // // //           size: 16,
// // // // // // //         ),
// // // // // // //         onTap: hasTrips ? () => _loadCompanyWork(companyName) : null,
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }

// // // // // // //   Widget _buildWorkTable() {
// // // // // // //     if (_isLoading) return const Center(child: CircularProgressIndicator());

// // // // // // //     return Column(
// // // // // // //       children: [
// // // // // // //         Container(
// // // // // // //           padding: const EdgeInsets.all(12),
// // // // // // //           color: Colors.blue[50],
// // // // // // //           child: Row(
// // // // // // //             mainAxisAlignment: MainAxisAlignment.center,
// // // // // // //             children: [
// // // // // // //               Icon(Icons.filter_alt, color: Colors.blue[700], size: 16),
// // // // // // //               const SizedBox(width: 8),
// // // // // // //               Text(
// // // // // // //                 _getFilterText(),
// // // // // // //                 style: TextStyle(
// // // // // // //                   color: Colors.blue[700],
// // // // // // //                   fontWeight: FontWeight.bold,
// // // // // // //                 ),
// // // // // // //               ),
// // // // // // //             ],
// // // // // // //           ),
// // // // // // //         ),
// // // // // // //         Expanded(
// // // // // // //           child: Container(
// // // // // // //             margin: const EdgeInsets.all(16),
// // // // // // //             decoration: BoxDecoration(
// // // // // // //               borderRadius: BorderRadius.circular(12),
// // // // // // //               border: Border.all(color: Colors.transparent),
// // // // // // //             ),
// // // // // // //             child: _filteredCompanyWork.isEmpty
// // // // // // //                 ? Center(
// // // // // // //                     child: Column(
// // // // // // //                       mainAxisAlignment: MainAxisAlignment.center,
// // // // // // //                       children: [
// // // // // // //                         const Icon(
// // // // // // //                           Icons.business,
// // // // // // //                           size: 60,
// // // // // // //                           color: Colors.grey,
// // // // // // //                         ),
// // // // // // //                         const SizedBox(height: 16),
// // // // // // //                         Text(
// // // // // // //                           _companyWork.isEmpty
// // // // // // //                               ? 'لا يوجد شغل مسجل لهذه الشركة'
// // // // // // //                               : 'لا يوجد شغل في الفترة المحددة',
// // // // // // //                           style: const TextStyle(
// // // // // // //                             color: Colors.grey,
// // // // // // //                             fontSize: 18,
// // // // // // //                             fontWeight: FontWeight.bold,
// // // // // // //                           ),
// // // // // // //                         ),
// // // // // // //                       ],
// // // // // // //                     ),
// // // // // // //                   )
// // // // // // //                 : SingleChildScrollView(
// // // // // // //                     scrollDirection: Axis.horizontal,
// // // // // // //                     child: SingleChildScrollView(
// // // // // // //                       scrollDirection: Axis.vertical,
// // // // // // //                       child: Table(
// // // // // // //                         defaultColumnWidth: const FixedColumnWidth(110),
// // // // // // //                         border: TableBorder.all(
// // // // // // //                           color: const Color(0xFF3498DB),
// // // // // // //                           width: 1,
// // // // // // //                         ),
// // // // // // //                         children: [
// // // // // // //                           TableRow(
// // // // // // //                             decoration: BoxDecoration(
// // // // // // //                               color: const Color(0xFF3498DB).withOpacity(0.15),
// // // // // // //                             ),
// // // // // // //                             children: const [
// // // // // // //                               TableCellHeader('عطلة الشركة'),
// // // // // // //                               TableCellHeader('مبيت الشركة'),
// // // // // // //                               TableCellHeader('نولون الشركة'),
// // // // // // //                               TableCellHeader('اسم السائق'),
// // // // // // //                               TableCellHeader('الكارتة'),
// // // // // // //                               TableCellHeader('العهدة'),
// // // // // // //                               TableCellHeader('اسم الموقع'),
// // // // // // //                               TableCellHeader('مكان التعتيق'),
// // // // // // //                               TableCellHeader('مكان التحميل'),
// // // // // // //                               TableCellHeader('التاريخ'),
// // // // // // //                               TableCellHeader('م'),
// // // // // // //                             ],
// // // // // // //                           ),
// // // // // // //                           ..._filteredCompanyWork.asMap().entries.map((entry) {
// // // // // // //                             final index = entry.key;
// // // // // // //                             final work = entry.value;

// // // // // // //                             return TableRow(
// // // // // // //                               decoration: BoxDecoration(
// // // // // // //                                 color: index.isEven
// // // // // // //                                     ? Colors.white
// // // // // // //                                     : const Color(0xFFF8F9FA),
// // // // // // //                               ),
// // // // // // //                               children: [
// // // // // // //                                 TableCellBody(
// // // // // // //                                   '${work['companyHoliday']} ج',
// // // // // // //                                   textStyle: const TextStyle(
// // // // // // //                                     fontWeight: FontWeight.bold,
// // // // // // //                                     color: Colors.red,
// // // // // // //                                   ),
// // // // // // //                                 ),
// // // // // // //                                 TableCellBody(
// // // // // // //                                   '${work['companyOvernight']} ج',
// // // // // // //                                   textStyle: TextStyle(
// // // // // // //                                     fontWeight: FontWeight.bold,
// // // // // // //                                     color: Colors.orange[700],
// // // // // // //                                   ),
// // // // // // //                                 ),
// // // // // // //                                 TableCellBody(
// // // // // // //                                   '${work['nolon']} ج',
// // // // // // //                                   textStyle: const TextStyle(
// // // // // // //                                     fontWeight: FontWeight.bold,
// // // // // // //                                     color: Colors.green,
// // // // // // //                                   ),
// // // // // // //                                 ),
// // // // // // //                                 TableCellBody(
// // // // // // //                                   work['driverName'],
// // // // // // //                                   textStyle: const TextStyle(
// // // // // // //                                     fontWeight: FontWeight.bold,
// // // // // // //                                     color: Color(0xFF2C3E50),
// // // // // // //                                   ),
// // // // // // //                                 ),
// // // // // // //                                 TableCellBody(work['karta']),
// // // // // // //                                 TableCellBody(work['ohda']),
// // // // // // //                                 TableCellBody(
// // // // // // //                                   work['selectedRoute'],
// // // // // // //                                   textStyle: const TextStyle(
// // // // // // //                                     fontWeight: FontWeight.bold,
// // // // // // //                                     color: Color(0xFF3498DB),
// // // // // // //                                   ),
// // // // // // //                                 ),
// // // // // // //                                 TableCellBody(work['unloadingLocation']),
// // // // // // //                                 TableCellBody(work['loadingLocation']),
// // // // // // //                                 TableCellBody(_formatDate(work['date'])),
// // // // // // //                                 TableCellBody('${index + 1}'),
// // // // // // //                               ],
// // // // // // //                             );
// // // // // // //                           }).toList(),
// // // // // // //                         ],
// // // // // // //                       ),
// // // // // // //                     ),
// // // // // // //                   ),
// // // // // // //           ),
// // // // // // //         ),
// // // // // // //       ],
// // // // // // //     );
// // // // // // //   }

// // // // // // //   String _getFilterText() {
// // // // // // //     switch (_timeFilter) {
// // // // // // //       case 'اليوم':
// // // // // // //         return 'عرض رحلات اليوم';
// // // // // // //       case 'هذا الشهر':
// // // // // // //         return 'عرض رحلات هذا الشهر';
// // // // // // //       case 'هذه السنة':
// // // // // // //         return 'عرض رحلات هذه السنة';
// // // // // // //       case 'مخصص':
// // // // // // //         return 'عرض رحلات شهر $_selectedMonth سنة $_selectedYear';
// // // // // // //       default:
// // // // // // //         return 'عرض جميع الرحلات';
// // // // // // //     }
// // // // // // //   }
// // // // // // // }

// // // // // // // class TableCellHeader extends StatelessWidget {
// // // // // // //   final String text;
// // // // // // //   const TableCellHeader(this.text, {super.key});

// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     return Container(
// // // // // // //       height: 50,
// // // // // // //       alignment: Alignment.center,
// // // // // // //       padding: const EdgeInsets.symmetric(horizontal: 8),
// // // // // // //       child: Text(
// // // // // // //         text,
// // // // // // //         style: const TextStyle(
// // // // // // //           fontWeight: FontWeight.bold,
// // // // // // //           fontSize: 14,
// // // // // // //           color: Color(0xFF2C3E50),
// // // // // // //         ),
// // // // // // //         textAlign: TextAlign.center,
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }

// // // // // // // class TableCellBody extends StatelessWidget {
// // // // // // //   final String text;
// // // // // // //   final TextStyle? textStyle;
// // // // // // //   const TableCellBody(this.text, {this.textStyle, super.key});

// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     return Container(
// // // // // // //       height: 48,
// // // // // // //       alignment: Alignment.center,
// // // // // // //       padding: const EdgeInsets.symmetric(horizontal: 8),
// // // // // // //       child: Text(
// // // // // // //         text,
// // // // // // //         maxLines: 2,
// // // // // // //         overflow: TextOverflow.ellipsis,
// // // // // // //         textAlign: TextAlign.center,
// // // // // // //         style: textStyle ?? const TextStyle(fontSize: 14),
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }
// // // // // // import 'dart:async';
// // // // // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // // // // import 'package:flutter/material.dart';
// // // // // // import 'package:intl/intl.dart';

// // // // // // class CompanyWorkPage extends StatefulWidget {
// // // // // //   const CompanyWorkPage({super.key});

// // // // // //   @override
// // // // // //   State<CompanyWorkPage> createState() => _CompanyWorkPageState();
// // // // // // }

// // // // // // class _CompanyWorkPageState extends State<CompanyWorkPage> {
// // // // // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// // // // // //   // متغيرات عامة
// // // // // //   int _currentSection = 0; // 0: شغل الشركات، 1: إنشاء فاتورة، 2: الفواتير
// // // // // //   List<Map<String, dynamic>> _allCompanies = [];
// // // // // //   List<Map<String, dynamic>> _filteredCompanies = [];
// // // // // //   String? _selectedCompany;
// // // // // //   List<Map<String, dynamic>> _companyWork = [];
// // // // // //   List<Map<String, dynamic>> _filteredCompanyWork = [];
// // // // // //   bool _isLoading = false;
// // // // // //   String _searchQuery = '';

// // // // // //   // متغيرات قسم إنشاء الفاتورة
// // // // // //   final List<Map<String, dynamic>> _selectedTripsForInvoice = [];
// // // // // //   final TextEditingController _invoiceNameController = TextEditingController();
// // // // // //   bool _isCreatingInvoice = false;

// // // // // //   // متغيرات قسم الفواتير
// // // // // //   List<Map<String, dynamic>> _invoices = [];

// // // // // //   @override
// // // // // //   void initState() {
// // // // // //     super.initState();
// // // // // //     _loadCompanies();
// // // // // //     _loadInvoices();
// // // // // //   }

// // // // // //   // ================================
// // // // // //   // تحميل بيانات الشركات
// // // // // //   // ================================
// // // // // //   Future<void> _loadCompanies() async {
// // // // // //     setState(() => _isLoading = true);
// // // // // //     try {
// // // // // //       final companiesSnapshot = await _firestore.collection('companies').get();
// // // // // //       final dailyWorkSnapshot = await _firestore.collection('dailyWork').get();

// // // // // //       final List<Map<String, dynamic>> companiesList = [];

// // // // // //       for (final companyDoc in companiesSnapshot.docs) {
// // // // // //         final companyData = companyDoc.data();
// // // // // //         final companyId = companyDoc.id;
// // // // // //         final companyName =
// // // // // //             (companyData['name'] ??
// // // // // //                     companyData['companyName'] ??
// // // // // //                     'شركة غير معروفة')
// // // // // //                 .toString()
// // // // // //                 .trim();

// // // // // //         final companyTrips = dailyWorkSnapshot.docs
// // // // // //             .where((doc) {
// // // // // //               final data = doc.data();
// // // // // //               final tripCompanyId = data['companyId'] ?? '';
// // // // // //               return tripCompanyId == companyId;
// // // // // //             })
// // // // // //             .map((doc) {
// // // // // //               final data = doc.data();
// // // // // //               final tripDate = (data['date'] as Timestamp?)?.toDate();

// // // // // //               return {
// // // // // //                 'id': doc.id,
// // // // // //                 'date': tripDate,
// // // // // //                 'companyName': companyName,
// // // // // //                 'companyId': companyId,
// // // // // //                 'driverName': data['driverName'] ?? 'غير معروف',
// // // // // //                 'nolon': (data['noLon'] ?? data['nolon'] ?? 0).toDouble(),
// // // // // //                 'companyOvernight': (data['companyOvernight'] ?? 0).toDouble(),
// // // // // //                 'companyHoliday': (data['companyHoliday'] ?? 0).toDouble(),
// // // // // //                 'selectedPrice': (data['selectedPrice'] ?? 0).toDouble(),
// // // // // //                 'karta': data['karta'] ?? '',
// // // // // //                 'ohda': data['ohda'] ?? '',
// // // // // //                 'selectedRoute': data['selectedRoute'] ?? '',
// // // // // //                 'loadingLocation': data['loadingLocation'] ?? '',
// // // // // //                 'unloadingLocation': data['unloadingLocation'] ?? '',
// // // // // //                 'vehicleType': data['selectedVehicleType'] ?? '',
// // // // // //                 'notes': data['selectedNotes'] ?? '',
// // // // // //                 'isSelected': false, // للحقل الجديد في قسم الفواتير
// // // // // //               };
// // // // // //             })
// // // // // //             .toList();

// // // // // //         // ترتيب الرحلات من الأحدث إلى الأقدم
// // // // // //         companyTrips.sort(
// // // // // //           (a, b) => b['date']?.compareTo(a['date'] ?? DateTime.now()) ?? 0,
// // // // // //         );

// // // // // //         double totalNolon = 0.0;
// // // // // //         double totalOvernight = 0.0;
// // // // // //         double totalHoliday = 0.0;

// // // // // //         for (var trip in companyTrips) {
// // // // // //           totalNolon += trip['nolon'];
// // // // // //           totalOvernight += trip['companyOvernight'];
// // // // // //           totalHoliday += trip['companyHoliday'];
// // // // // //         }

// // // // // //         companiesList.add({
// // // // // //           'companyId': companyId,
// // // // // //           'companyName': companyName,
// // // // // //           'companyData': companyData,
// // // // // //           'allTrips': companyTrips,
// // // // // //           'hasTrips': companyTrips.isNotEmpty,
// // // // // //           'totalTrips': companyTrips.length,
// // // // // //           'totalNolon': totalNolon,
// // // // // //           'totalOvernight': totalOvernight,
// // // // // //           'totalHoliday': totalHoliday,
// // // // // //         });
// // // // // //       }

// // // // // //       // ترتيب الشركات حسب الأحدث (التي بها رحلات حديثة)
// // // // // //       companiesList.sort((a, b) {
// // // // // //         final aLatestTrip = a['allTrips'].isNotEmpty
// // // // // //             ? a['allTrips'].first['date']
// // // // // //             : DateTime(1900);
// // // // // //         final bLatestTrip = b['allTrips'].isNotEmpty
// // // // // //             ? b['allTrips'].first['date']
// // // // // //             : DateTime(1900);
// // // // // //         return bLatestTrip.compareTo(aLatestTrip);
// // // // // //       });

// // // // // //       setState(() {
// // // // // //         _allCompanies = companiesList;
// // // // // //         _filteredCompanies = _applySearchFilter(companiesList);
// // // // // //         _isLoading = false;
// // // // // //       });
// // // // // //     } catch (e) {
// // // // // //       setState(() => _isLoading = false);
// // // // // //       debugPrint('خطأ في تحميل بيانات الشركات: $e');
// // // // // //     }
// // // // // //   }

// // // // // //   // ================================
// // // // // //   // تحميل شغل شركة محددة
// // // // // //   // ================================
// // // // // //   Future<void> _loadCompanyWork(String companyName) async {
// // // // // //     setState(() {
// // // // // //       _selectedCompany = companyName;
// // // // // //       _isLoading = true;
// // // // // //       _companyWork.clear();
// // // // // //     });

// // // // // //     try {
// // // // // //       final company = _allCompanies.firstWhere(
// // // // // //         (c) => c['companyName'] == companyName,
// // // // // //         orElse: () => {},
// // // // // //       );

// // // // // //       if (company.isEmpty) {
// // // // // //         _showError('الشركة غير موجودة');
// // // // // //         return;
// // // // // //       }

// // // // // //       final companyTrips = company['allTrips'] as List<Map<String, dynamic>>;

// // // // // //       setState(() {
// // // // // //         _companyWork = companyTrips;
// // // // // //         _isLoading = false;
// // // // // //       });
// // // // // //     } catch (e) {
// // // // // //       setState(() => _isLoading = false);
// // // // // //       _showError('خطأ في تحميل شغل الشركة: $e');
// // // // // //     }
// // // // // //   }

// // // // // //   // ================================
// // // // // //   // تحميل الفواتير
// // // // // //   // ================================
// // // // // //   Future<void> _loadInvoices() async {
// // // // // //     try {
// // // // // //       final invoicesSnapshot = await _firestore
// // // // // //           .collection('invoices')
// // // // // //           .orderBy('createdAt', descending: true)
// // // // // //           .get();

// // // // // //       final List<Map<String, dynamic>> invoicesList = [];

// // // // // //       for (final doc in invoicesSnapshot.docs) {
// // // // // //         final data = doc.data();
// // // // // //         invoicesList.add({
// // // // // //           'id': doc.id,
// // // // // //           'name': data['name'] ?? 'فاتورة بدون اسم',
// // // // // //           'companyName': data['companyName'] ?? 'شركة غير معروفة',
// // // // // //           'totalAmount': (data['totalAmount'] ?? 0).toDouble(),
// // // // // //           'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
// // // // // //           'tripCount': (data['tripIds'] as List? ?? []).length,
// // // // // //           'nolonTotal': (data['nolonTotal'] ?? 0).toDouble(),
// // // // // //           'overnightTotal': (data['overnightTotal'] ?? 0).toDouble(),
// // // // // //           'holidayTotal': (data['holidayTotal'] ?? 0).toDouble(),
// // // // // //         });
// // // // // //       }

// // // // // //       setState(() {
// // // // // //         _invoices = invoicesList;
// // // // // //       });
// // // // // //     } catch (e) {
// // // // // //       debugPrint('خطأ في تحميل الفواتير: $e');
// // // // // //     }
// // // // // //   }

// // // // // //   // ================================
// // // // // //   // دوال التصفية والبحث
// // // // // //   // ================================
// // // // // //   List<Map<String, dynamic>> _applySearchFilter(
// // // // // //     List<Map<String, dynamic>> companies,
// // // // // //   ) {
// // // // // //     if (_searchQuery.isEmpty) return companies;
// // // // // //     return companies
// // // // // //         .where(
// // // // // //           (c) => c['companyName'].toLowerCase().contains(
// // // // // //             _searchQuery.toLowerCase(),
// // // // // //           ),
// // // // // //         )
// // // // // //         .toList();
// // // // // //   }

// // // // // //   // ================================
// // // // // //   // دوال قسم إنشاء الفاتورة
// // // // // //   // ================================
// // // // // //   void _toggleTripSelection(Map<String, dynamic> trip, bool selected) {
// // // // // //     setState(() {
// // // // // //       trip['isSelected'] = selected;
// // // // // //       if (selected) {
// // // // // //         _selectedTripsForInvoice.add(trip);
// // // // // //       } else {
// // // // // //         _selectedTripsForInvoice.removeWhere((t) => t['id'] == trip['id']);
// // // // // //       }
// // // // // //     });
// // // // // //   }

// // // // // //   void _selectAllTrips(bool select) {
// // // // // //     setState(() {
// // // // // //       for (var trip in _companyWork) {
// // // // // //         trip['isSelected'] = select;
// // // // // //       }

// // // // // //       if (select) {
// // // // // //         _selectedTripsForInvoice.clear();
// // // // // //         _selectedTripsForInvoice.addAll(_companyWork);
// // // // // //       } else {
// // // // // //         _selectedTripsForInvoice.clear();
// // // // // //       }
// // // // // //     });
// // // // // //   }

// // // // // //   Future<void> _createInvoice() async {
// // // // // //     if (_selectedTripsForInvoice.isEmpty) {
// // // // // //       _showError('يرجى اختيار رحلات لإنشاء الفاتورة');
// // // // // //       return;
// // // // // //     }

// // // // // //     if (_invoiceNameController.text.isEmpty) {
// // // // // //       _showError('يرجى إدخال اسم الفاتورة');
// // // // // //       return;
// // // // // //     }

// // // // // //     setState(() => _isCreatingInvoice = true);

// // // // // //     try {
// // // // // //       // حساب إجمالي المبلغ
// // // // // //       double totalNolon = 0;
// // // // // //       double totalOvernight = 0;
// // // // // //       double totalHoliday = 0;
// // // // // //       List<String> tripIds = [];

// // // // // //       for (var trip in _selectedTripsForInvoice) {
// // // // // //         totalNolon += trip['nolon'];
// // // // // //         totalOvernight += trip['companyOvernight'];
// // // // // //         totalHoliday += trip['companyHoliday'];
// // // // // //         tripIds.add(trip['id']);
// // // // // //       }

// // // // // //       double totalAmount = totalNolon + totalOvernight + totalHoliday;

// // // // // //       // حفظ الفاتورة
// // // // // //       await _firestore.collection('invoices').add({
// // // // // //         'name': _invoiceNameController.text.trim(),
// // // // // //         'companyName': _selectedCompany!,
// // // // // //         'companyId': _companyWork.first['companyId'],
// // // // // //         'totalAmount': totalAmount,
// // // // // //         'nolonTotal': totalNolon,
// // // // // //         'overnightTotal': totalOvernight,
// // // // // //         'holidayTotal': totalHoliday,
// // // // // //         'tripIds': tripIds,
// // // // // //         'createdAt': Timestamp.now(),
// // // // // //         'status': 'غير مدفوعة',
// // // // // //       });

// // // // // //       // حذف الرحلات المختارة من dailyWork
// // // // // //       final batch = _firestore.batch();
// // // // // //       for (var tripId in tripIds) {
// // // // // //         batch.delete(_firestore.collection('dailyWork').doc(tripId));
// // // // // //       }
// // // // // //       await batch.commit();

// // // // // //       // تحديث البيانات المحلية
// // // // // //       _companyWork.removeWhere((trip) => tripIds.contains(trip['id']));
// // // // // //       _selectedTripsForInvoice.clear();
// // // // // //       _invoiceNameController.clear();

// // // // // //       _showSuccess('تم إنشاء الفاتورة وحذف الرحلات المختارة بنجاح');
// // // // // //       await _loadCompanies(); // تحديث قائمة الشركات
// // // // // //       await _loadInvoices(); // تحديث قائمة الفواتير

// // // // // //       // الرجوع إلى قسم الفواتير
// // // // // //       _changeSection(2);
// // // // // //     } catch (e) {
// // // // // //       _showError('خطأ في إنشاء الفاتورة: $e');
// // // // // //     } finally {
// // // // // //       setState(() => _isCreatingInvoice = false);
// // // // // //     }
// // // // // //   }

// // // // // //   // ================================
// // // // // //   // دوال مساعدة
// // // // // //   // ================================
// // // // // //   void _showError(String message) {
// // // // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // // // //       SnackBar(content: Text(message), backgroundColor: Colors.red),
// // // // // //     );
// // // // // //   }

// // // // // //   void _showSuccess(String message) {
// // // // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // // // //       SnackBar(content: Text(message), backgroundColor: Colors.green),
// // // // // //     );
// // // // // //   }

// // // // // //   String _formatDate(DateTime? date) {
// // // // // //     if (date == null) return '-';
// // // // // //     return DateFormat('dd/MM/yyyy').format(date);
// // // // // //   }

// // // // // //   String _formatCurrency(double amount) {
// // // // // //     return '${amount.toStringAsFixed(2)} ج';
// // // // // //   }

// // // // // //   void _changeSection(int section) {
// // // // // //     setState(() {
// // // // // //       _currentSection = section;
// // // // // //       if (section == 0) {
// // // // // //         _selectedTripsForInvoice.clear();
// // // // // //         _invoiceNameController.clear();
// // // // // //         if (_companyWork.isNotEmpty) {
// // // // // //           for (var trip in _companyWork) {
// // // // // //             trip['isSelected'] = false;
// // // // // //           }
// // // // // //         }
// // // // // //       }
// // // // // //     });
// // // // // //   }

// // // // // //   // ================================
// // // // // //   // بناء الواجهة
// // // // // //   // ================================
// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return Scaffold(
// // // // // //       backgroundColor: const Color(0xFFF4F6F8),
// // // // // //       body: Column(
// // // // // //         children: [
// // // // // //           _buildCustomAppBar(),
// // // // // //           _buildSectionTabs(),
// // // // // //           if (_currentSection == 0 && _selectedCompany == null)
// // // // // //             _buildSearchBar(),
// // // // // //           Expanded(
// // // // // //             child: _currentSection == 0
// // // // // //                 ? (_selectedCompany == null
// // // // // //                       ? _buildCompanyList()
// // // // // //                       : _buildWorkTable())
// // // // // //                 : _currentSection == 1
// // // // // //                 ? _buildCreateInvoiceSection()
// // // // // //                 : _buildInvoicesSection(),
// // // // // //           ),
// // // // // //         ],
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   Widget _buildCustomAppBar() {
// // // // // //     return Container(
// // // // // //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// // // // // //       decoration: const BoxDecoration(
// // // // // //         gradient: LinearGradient(
// // // // // //           begin: Alignment.centerRight,
// // // // // //           end: Alignment.centerLeft,
// // // // // //           colors: [Color(0xFF1B4F72), Color(0xFF3498DB)],
// // // // // //         ),
// // // // // //         boxShadow: [
// // // // // //           BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
// // // // // //         ],
// // // // // //       ),
// // // // // //       child: SafeArea(
// // // // // //         child: Row(
// // // // // //           children: [
// // // // // //             const Icon(Icons.business, color: Colors.white, size: 28),
// // // // // //             const SizedBox(width: 8),
// // // // // //             Expanded(
// // // // // //               child: Center(
// // // // // //                 child: Text(
// // // // // //                   _selectedCompany == null
// // // // // //                       ? _getSectionTitle()
// // // // // //                       : 'شغل شركة $_selectedCompany',
// // // // // //                   style: const TextStyle(
// // // // // //                     color: Colors.white,
// // // // // //                     fontSize: 20,
// // // // // //                     fontWeight: FontWeight.bold,
// // // // // //                   ),
// // // // // //                 ),
// // // // // //               ),
// // // // // //             ),
// // // // // //             if (_selectedCompany != null)
// // // // // //               IconButton(
// // // // // //                 icon: const Icon(Icons.arrow_back, color: Colors.white),
// // // // // //                 onPressed: () {
// // // // // //                   setState(() {
// // // // // //                     _selectedCompany = null;
// // // // // //                     _companyWork.clear();
// // // // // //                     _selectedTripsForInvoice.clear();
// // // // // //                     _invoiceNameController.clear();
// // // // // //                   });
// // // // // //                 },
// // // // // //               ),
// // // // // //           ],
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   String _getSectionTitle() {
// // // // // //     switch (_currentSection) {
// // // // // //       case 0:
// // // // // //         return 'شغل الشركات';
// // // // // //       case 1:
// // // // // //         return 'إنشاء فاتورة';
// // // // // //       case 2:
// // // // // //         return 'الفواتير';
// // // // // //       default:
// // // // // //         return 'شغل الشركات';
// // // // // //     }
// // // // // //   }

// // // // // //   Widget _buildSectionTabs() {
// // // // // //     return Container(
// // // // // //       color: Colors.white,
// // // // // //       child: Row(
// // // // // //         children: [
// // // // // //           _buildSectionTab(0, Icons.business, 'شغل الشركات'),
// // // // // //           _buildSectionTab(1, Icons.receipt, 'إنشاء فاتورة'),
// // // // // //           _buildSectionTab(2, Icons.list_alt, 'الفواتير'),
// // // // // //         ],
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   Widget _buildSectionTab(int section, IconData icon, String title) {
// // // // // //     final isActive = _currentSection == section;
// // // // // //     return Expanded(
// // // // // //       child: InkWell(
// // // // // //         onTap: () => _changeSection(section),
// // // // // //         child: Container(
// // // // // //           padding: const EdgeInsets.symmetric(vertical: 12),
// // // // // //           decoration: BoxDecoration(
// // // // // //             color: isActive ? const Color(0xFF3498DB) : Colors.white,
// // // // // //             border: Border(
// // // // // //               bottom: BorderSide(
// // // // // //                 color: isActive ? const Color(0xFF3498DB) : Colors.grey[300]!,
// // // // // //                 width: 3,
// // // // // //               ),
// // // // // //             ),
// // // // // //           ),
// // // // // //           child: Column(
// // // // // //             children: [
// // // // // //               Icon(
// // // // // //                 icon,
// // // // // //                 color: isActive ? Colors.white : Colors.grey,
// // // // // //                 size: 22,
// // // // // //               ),
// // // // // //               const SizedBox(height: 4),
// // // // // //               Text(
// // // // // //                 title,
// // // // // //                 style: TextStyle(
// // // // // //                   color: isActive ? Colors.white : Colors.grey,
// // // // // //                   fontSize: 12,
// // // // // //                   fontWeight: FontWeight.bold,
// // // // // //                 ),
// // // // // //               ),
// // // // // //             ],
// // // // // //           ),
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   Widget _buildSearchBar() {
// // // // // //     return Container(
// // // // // //       padding: const EdgeInsets.all(12),
// // // // // //       color: Colors.white,
// // // // // //       child: Container(
// // // // // //         padding: const EdgeInsets.symmetric(horizontal: 12),
// // // // // //         decoration: BoxDecoration(
// // // // // //           color: const Color(0xFFF4F6F8),
// // // // // //           borderRadius: BorderRadius.circular(12),
// // // // // //           border: Border.all(color: const Color(0xFF3498DB)),
// // // // // //         ),
// // // // // //         child: Row(
// // // // // //           children: [
// // // // // //             const Icon(Icons.search, color: Color(0xFF3498DB), size: 20),
// // // // // //             const SizedBox(width: 8),
// // // // // //             Expanded(
// // // // // //               child: TextField(
// // // // // //                 onChanged: (value) {
// // // // // //                   setState(() {
// // // // // //                     _searchQuery = value;
// // // // // //                     _filteredCompanies = _applySearchFilter(_allCompanies);
// // // // // //                   });
// // // // // //                 },
// // // // // //                 decoration: const InputDecoration(
// // // // // //                   hintText: 'ابحث عن شركة...',
// // // // // //                   border: InputBorder.none,
// // // // // //                   hintStyle: TextStyle(color: Colors.grey),
// // // // // //                 ),
// // // // // //               ),
// // // // // //             ),
// // // // // //             if (_searchQuery.isNotEmpty)
// // // // // //               GestureDetector(
// // // // // //                 onTap: () {
// // // // // //                   setState(() {
// // // // // //                     _searchQuery = '';
// // // // // //                     _filteredCompanies = _applySearchFilter(_allCompanies);
// // // // // //                   });
// // // // // //                 },
// // // // // //                 child: const Icon(Icons.clear, size: 18, color: Colors.grey),
// // // // // //               ),
// // // // // //           ],
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   Widget _buildCompanyList() {
// // // // // //     if (_isLoading) return const Center(child: CircularProgressIndicator());

// // // // // //     final companiesWithTrips = _filteredCompanies
// // // // // //         .where((c) => c['hasTrips'])
// // // // // //         .toList();
// // // // // //     final companiesWithoutTrips = _filteredCompanies
// // // // // //         .where((c) => !c['hasTrips'])
// // // // // //         .toList();

// // // // // //     return ListView(
// // // // // //       padding: const EdgeInsets.all(8),
// // // // // //       children: [
// // // // // //         ...companiesWithTrips.map((company) => _buildCompanyCard(company)),
// // // // // //         if (companiesWithTrips.isEmpty && companiesWithoutTrips.isNotEmpty)
// // // // // //           Container(
// // // // // //             margin: const EdgeInsets.all(16),
// // // // // //             padding: const EdgeInsets.all(20),
// // // // // //             decoration: BoxDecoration(
// // // // // //               color: Colors.white,
// // // // // //               borderRadius: BorderRadius.circular(12),
// // // // // //               border: Border.all(color: Colors.grey[300]!),
// // // // // //             ),
// // // // // //             child: Column(
// // // // // //               children: [
// // // // // //                 Icon(Icons.business, size: 60, color: Colors.grey[400]),
// // // // // //                 const SizedBox(height: 16),
// // // // // //                 const Text(
// // // // // //                   'لا توجد شركات لديها رحلات',
// // // // // //                   style: TextStyle(
// // // // // //                     fontSize: 16,
// // // // // //                     color: Colors.grey,
// // // // // //                     fontWeight: FontWeight.bold,
// // // // // //                   ),
// // // // // //                   textAlign: TextAlign.center,
// // // // // //                 ),
// // // // // //               ],
// // // // // //             ),
// // // // // //           ),
// // // // // //       ],
// // // // // //     );
// // // // // //   }

// // // // // //   Widget _buildCompanyCard(Map<String, dynamic> company) {
// // // // // //     final companyName = company['companyName'];
// // // // // //     final totalTrips = company['totalTrips'];
// // // // // //     final hasTrips = company['hasTrips'];
// // // // // //     final totalNolon = company['totalNolon'] ?? 0;

// // // // // //     return Container(
// // // // // //       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
// // // // // //       decoration: BoxDecoration(
// // // // // //         color: Colors.white,
// // // // // //         borderRadius: BorderRadius.circular(12),
// // // // // //         border: Border.all(
// // // // // //           color: hasTrips
// // // // // //               ? const Color(0xFF3498DB).withOpacity(0.3)
// // // // // //               : Colors.grey.withOpacity(0.3),
// // // // // //         ),
// // // // // //         boxShadow: [
// // // // // //           BoxShadow(
// // // // // //             color: Colors.black.withOpacity(0.05),
// // // // // //             blurRadius: 8,
// // // // // //             offset: const Offset(0, 2),
// // // // // //           ),
// // // // // //         ],
// // // // // //       ),
// // // // // //       child: ListTile(
// // // // // //         leading: Container(
// // // // // //           width: 45,
// // // // // //           height: 45,
// // // // // //           decoration: BoxDecoration(
// // // // // //             color: hasTrips ? const Color(0xFF3498DB) : Colors.grey,
// // // // // //             borderRadius: BorderRadius.circular(22.5),
// // // // // //           ),
// // // // // //           child: Center(
// // // // // //             child: Text(
// // // // // //               totalTrips.toString(),
// // // // // //               style: const TextStyle(
// // // // // //                 color: Colors.white,
// // // // // //                 fontWeight: FontWeight.bold,
// // // // // //                 fontSize: 16,
// // // // // //               ),
// // // // // //             ),
// // // // // //           ),
// // // // // //         ),
// // // // // //         title: Text(
// // // // // //           companyName,
// // // // // //           style: TextStyle(
// // // // // //             fontWeight: FontWeight.bold,
// // // // // //             fontSize: 16,
// // // // // //             color: hasTrips ? const Color(0xFF2C3E50) : Colors.grey,
// // // // // //           ),
// // // // // //         ),
// // // // // //         subtitle: Column(
// // // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //           children: [
// // // // // //             Text(
// // // // // //               hasTrips
// // // // // //                   ? '$totalTrips رحلة - ${_formatCurrency(totalNolon)}'
// // // // // //                   : 'لا توجد رحلات',
// // // // // //               style: TextStyle(
// // // // // //                 color: hasTrips ? Colors.green : Colors.grey,
// // // // // //                 fontSize: 12,
// // // // // //               ),
// // // // // //             ),
// // // // // //           ],
// // // // // //         ),
// // // // // //         trailing: Icon(
// // // // // //           Icons.arrow_forward_ios,
// // // // // //           color: hasTrips ? const Color(0xFF3498DB) : Colors.grey,
// // // // // //           size: 16,
// // // // // //         ),
// // // // // //         onTap: hasTrips ? () => _loadCompanyWork(companyName) : null,
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   Widget _buildWorkTable() {
// // // // // //     if (_isLoading) return const Center(child: CircularProgressIndicator());

// // // // // //     return Column(
// // // // // //       children: [
// // // // // //         Padding(
// // // // // //           padding: const EdgeInsets.all(12),
// // // // // //           child: Row(
// // // // // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // // //             children: [
// // // // // //               ElevatedButton.icon(
// // // // // //                 onPressed: () => _changeSection(1),
// // // // // //                 icon: const Icon(Icons.receipt),
// // // // // //                 label: const Text('إنشاء فاتورة من هذه الرحلات'),
// // // // // //                 style: ElevatedButton.styleFrom(
// // // // // //                   backgroundColor: const Color(0xFF2E7D32),
// // // // // //                   foregroundColor: Colors.white,
// // // // // //                 ),
// // // // // //               ),
// // // // // //               Text(
// // // // // //                 '${_companyWork.length} رحلة',
// // // // // //                 style: const TextStyle(
// // // // // //                   fontWeight: FontWeight.bold,
// // // // // //                   color: Color(0xFF3498DB),
// // // // // //                 ),
// // // // // //               ),
// // // // // //             ],
// // // // // //           ),
// // // // // //         ),
// // // // // //         Expanded(
// // // // // //           child: Container(
// // // // // //             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // // // // //             decoration: BoxDecoration(
// // // // // //               borderRadius: BorderRadius.circular(12),
// // // // // //               border: Border.all(color: const Color(0xFF3498DB)),
// // // // // //             ),
// // // // // //             child: _companyWork.isEmpty
// // // // // //                 ? Center(
// // // // // //                     child: Column(
// // // // // //                       mainAxisAlignment: MainAxisAlignment.center,
// // // // // //                       children: [
// // // // // //                         const Icon(
// // // // // //                           Icons.business,
// // // // // //                           size: 60,
// // // // // //                           color: Colors.grey,
// // // // // //                         ),
// // // // // //                         const SizedBox(height: 16),
// // // // // //                         const Text(
// // // // // //                           'لا يوجد شغل مسجل لهذه الشركة',
// // // // // //                           style: TextStyle(
// // // // // //                             color: Colors.grey,
// // // // // //                             fontSize: 18,
// // // // // //                             fontWeight: FontWeight.bold,
// // // // // //                           ),
// // // // // //                         ),
// // // // // //                         const SizedBox(height: 20),
// // // // // //                         ElevatedButton.icon(
// // // // // //                           onPressed: () {
// // // // // //                             setState(() => _selectedCompany = null);
// // // // // //                           },
// // // // // //                           icon: const Icon(Icons.arrow_back),
// // // // // //                           label: const Text('العودة للشركات'),
// // // // // //                         ),
// // // // // //                       ],
// // // // // //                     ),
// // // // // //                   )
// // // // // //                 : ListView.builder(
// // // // // //                     itemCount: _companyWork.length,
// // // // // //                     itemBuilder: (context, index) {
// // // // // //                       final work = _companyWork[index];
// // // // // //                       return _buildWorkItem(work, index);
// // // // // //                     },
// // // // // //                   ),
// // // // // //           ),
// // // // // //         ),
// // // // // //       ],
// // // // // //     );
// // // // // //   }

// // // // // //   Widget _buildWorkItem(Map<String, dynamic> work, int index) {
// // // // // //     final totalAmount =
// // // // // //         work['nolon'] + work['companyOvernight'] + work['companyHoliday'];

// // // // // //     return Container(
// // // // // //       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
// // // // // //       decoration: BoxDecoration(
// // // // // //         color: Colors.white,
// // // // // //         borderRadius: BorderRadius.circular(8),
// // // // // //         border: Border.all(color: Colors.grey[300]!),
// // // // // //       ),
// // // // // //       child: ListTile(
// // // // // //         leading: CircleAvatar(
// // // // // //           backgroundColor: const Color(0xFF3498DB),
// // // // // //           child: Text(
// // // // // //             '${index + 1}',
// // // // // //             style: const TextStyle(
// // // // // //               color: Colors.white,
// // // // // //               fontWeight: FontWeight.bold,
// // // // // //             ),
// // // // // //           ),
// // // // // //         ),
// // // // // //         title: Text(
// // // // // //           work['driverName'],
// // // // // //           style: const TextStyle(fontWeight: FontWeight.bold),
// // // // // //         ),
// // // // // //         subtitle: Column(
// // // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //           children: [
// // // // // //             Text('الطريق: ${work['selectedRoute']}'),
// // // // // //             Text('التاريخ: ${_formatDate(work['date'])}'),
// // // // // //             Row(
// // // // // //               children: [
// // // // // //                 Chip(
// // // // // //                   label: Text('${work['nolon']} ج نولون'),
// // // // // //                   backgroundColor: Colors.green[50],
// // // // // //                   labelStyle: TextStyle(color: Colors.green[700]),
// // // // // //                 ),
// // // // // //                 const SizedBox(width: 4),
// // // // // //                 Chip(
// // // // // //                   label: Text('${work['companyOvernight']} ج مبيت'),
// // // // // //                   backgroundColor: Colors.orange[50],
// // // // // //                   labelStyle: TextStyle(color: Colors.orange[700]),
// // // // // //                 ),
// // // // // //                 const SizedBox(width: 4),
// // // // // //                 Chip(
// // // // // //                   label: Text('${work['companyHoliday']} ج عطلة'),
// // // // // //                   backgroundColor: Colors.red[50],
// // // // // //                   labelStyle: TextStyle(color: Colors.red[700]),
// // // // // //                 ),
// // // // // //               ],
// // // // // //             ),
// // // // // //           ],
// // // // // //         ),
// // // // // //         trailing: Column(
// // // // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // // // //           children: [
// // // // // //             Text(
// // // // // //               _formatCurrency(totalAmount),
// // // // // //               style: const TextStyle(
// // // // // //                 fontWeight: FontWeight.bold,
// // // // // //                 fontSize: 16,
// // // // // //                 color: Color(0xFF2E7D32),
// // // // // //               ),
// // // // // //             ),
// // // // // //             const SizedBox(height: 4),
// // // // // //             Text(
// // // // // //               'إجمالي',
// // // // // //               style: TextStyle(fontSize: 12, color: Colors.grey[600]),
// // // // // //             ),
// // // // // //           ],
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   Widget _buildCreateInvoiceSection() {
// // // // // //     return _selectedCompany == null
// // // // // //         ? Center(
// // // // // //             child: Column(
// // // // // //               mainAxisAlignment: MainAxisAlignment.center,
// // // // // //               children: [
// // // // // //                 const Icon(Icons.business, size: 80, color: Colors.grey),
// // // // // //                 const SizedBox(height: 20),
// // // // // //                 const Text(
// // // // // //                   'يرجى اختيار شركة أولاً',
// // // // // //                   style: TextStyle(
// // // // // //                     fontSize: 18,
// // // // // //                     color: Colors.grey,
// // // // // //                     fontWeight: FontWeight.bold,
// // // // // //                   ),
// // // // // //                 ),
// // // // // //                 const SizedBox(height: 10),
// // // // // //                 const Text(
// // // // // //                   'اذهب إلى قسم "شغل الشركات" واختر شركة',
// // // // // //                   style: TextStyle(color: Colors.grey),
// // // // // //                   textAlign: TextAlign.center,
// // // // // //                 ),
// // // // // //                 const SizedBox(height: 30),
// // // // // //                 ElevatedButton.icon(
// // // // // //                   onPressed: () => _changeSection(0),
// // // // // //                   icon: const Icon(Icons.business),
// // // // // //                   label: const Text('الذهاب إلى شغل الشركات'),
// // // // // //                   style: ElevatedButton.styleFrom(
// // // // // //                     backgroundColor: const Color(0xFF3498DB),
// // // // // //                     foregroundColor: Colors.white,
// // // // // //                     padding: const EdgeInsets.symmetric(
// // // // // //                       horizontal: 20,
// // // // // //                       vertical: 12,
// // // // // //                     ),
// // // // // //                   ),
// // // // // //                 ),
// // // // // //               ],
// // // // // //             ),
// // // // // //           )
// // // // // //         : Column(
// // // // // //             children: [
// // // // // //               // إحصائيات الرحلات المختارة
// // // // // //               Container(
// // // // // //                 padding: const EdgeInsets.all(16),
// // // // // //                 color: Colors.blue[50],
// // // // // //                 child: Row(
// // // // // //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // // //                   children: [
// // // // // //                     Column(
// // // // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //                       children: [
// // // // // //                         const Text(
// // // // // //                           'الرحلات المختارة',
// // // // // //                           style: TextStyle(
// // // // // //                             fontWeight: FontWeight.bold,
// // // // // //                             color: Color(0xFF3498DB),
// // // // // //                           ),
// // // // // //                         ),
// // // // // //                         Text(
// // // // // //                           '${_selectedTripsForInvoice.length} من ${_companyWork.length} رحلة',
// // // // // //                           style: const TextStyle(
// // // // // //                             fontSize: 18,
// // // // // //                             fontWeight: FontWeight.bold,
// // // // // //                             color: Color(0xFF2E7D32),
// // // // // //                           ),
// // // // // //                         ),
// // // // // //                       ],
// // // // // //                     ),
// // // // // //                     Column(
// // // // // //                       crossAxisAlignment: CrossAxisAlignment.end,
// // // // // //                       children: [
// // // // // //                         const Text(
// // // // // //                           'إجمالي الفاتورة',
// // // // // //                           style: TextStyle(
// // // // // //                             fontWeight: FontWeight.bold,
// // // // // //                             color: Color(0xFF3498DB),
// // // // // //                           ),
// // // // // //                         ),
// // // // // //                         Text(
// // // // // //                           _formatCurrency(_calculateInvoiceTotal()),
// // // // // //                           style: const TextStyle(
// // // // // //                             fontSize: 18,
// // // // // //                             fontWeight: FontWeight.bold,
// // // // // //                             color: Color(0xFF2E7D32),
// // // // // //                           ),
// // // // // //                         ),
// // // // // //                       ],
// // // // // //                     ),
// // // // // //                   ],
// // // // // //                 ),
// // // // // //               ),

// // // // // //               // اسم الفاتورة
// // // // // //               Padding(
// // // // // //                 padding: const EdgeInsets.all(16),
// // // // // //                 child: TextField(
// // // // // //                   controller: _invoiceNameController,
// // // // // //                   decoration: InputDecoration(
// // // // // //                     labelText: 'اسم الفاتورة',
// // // // // //                     prefixIcon: const Icon(Icons.receipt),
// // // // // //                     border: OutlineInputBorder(
// // // // // //                       borderRadius: BorderRadius.circular(12),
// // // // // //                     ),
// // // // // //                     filled: true,
// // // // // //                     fillColor: Colors.white,
// // // // // //                   ),
// // // // // //                 ),
// // // // // //               ),

// // // // // //               // أزرار التحكم
// // // // // //               Padding(
// // // // // //                 padding: const EdgeInsets.symmetric(horizontal: 16),
// // // // // //                 child: Row(
// // // // // //                   children: [
// // // // // //                     Expanded(
// // // // // //                       child: ElevatedButton.icon(
// // // // // //                         onPressed: () => _selectAllTrips(true),
// // // // // //                         icon: const Icon(Icons.check_box),
// // // // // //                         label: const Text('تحديد الكل'),
// // // // // //                         style: ElevatedButton.styleFrom(
// // // // // //                           backgroundColor: Colors.green[50],
// // // // // //                           foregroundColor: Colors.green[700],
// // // // // //                         ),
// // // // // //                       ),
// // // // // //                     ),
// // // // // //                     const SizedBox(width: 8),
// // // // // //                     Expanded(
// // // // // //                       child: ElevatedButton.icon(
// // // // // //                         onPressed: () => _selectAllTrips(false),
// // // // // //                         icon: const Icon(Icons.check_box_outline_blank),
// // // // // //                         label: const Text('إلغاء الكل'),
// // // // // //                         style: ElevatedButton.styleFrom(
// // // // // //                           backgroundColor: Colors.red[50],
// // // // // //                           foregroundColor: Colors.red[700],
// // // // // //                         ),
// // // // // //                       ),
// // // // // //                     ),
// // // // // //                   ],
// // // // // //                 ),
// // // // // //               ),

// // // // // //               // قائمة الرحلات مع خيار التحديد
// // // // // //               Expanded(
// // // // // //                 child: Container(
// // // // // //                   margin: const EdgeInsets.all(16),
// // // // // //                   decoration: BoxDecoration(
// // // // // //                     borderRadius: BorderRadius.circular(12),
// // // // // //                     border: Border.all(color: Colors.grey[300]!),
// // // // // //                   ),
// // // // // //                   child: _companyWork.isEmpty
// // // // // //                       ? Center(
// // // // // //                           child: Column(
// // // // // //                             mainAxisAlignment: MainAxisAlignment.center,
// // // // // //                             children: [
// // // // // //                               const Icon(
// // // // // //                                 Icons.list,
// // // // // //                                 size: 60,
// // // // // //                                 color: Colors.grey,
// // // // // //                               ),
// // // // // //                               const SizedBox(height: 16),
// // // // // //                               const Text(
// // // // // //                                 'لا توجد رحلات',
// // // // // //                                 style: TextStyle(
// // // // // //                                   color: Colors.grey,
// // // // // //                                   fontSize: 18,
// // // // // //                                 ),
// // // // // //                               ),
// // // // // //                             ],
// // // // // //                           ),
// // // // // //                         )
// // // // // //                       : ListView.builder(
// // // // // //                           itemCount: _companyWork.length,
// // // // // //                           itemBuilder: (context, index) {
// // // // // //                             final work = _companyWork[index];
// // // // // //                             final totalAmount =
// // // // // //                                 work['nolon'] +
// // // // // //                                 work['companyOvernight'] +
// // // // // //                                 work['companyHoliday'];

// // // // // //                             return CheckboxListTile(
// // // // // //                               value: work['isSelected'] ?? false,
// // // // // //                               onChanged: (value) {
// // // // // //                                 _toggleTripSelection(work, value ?? false);
// // // // // //                               },
// // // // // //                               title: Text(
// // // // // //                                 '${index + 1}. ${work['driverName']}',
// // // // // //                                 style: const TextStyle(
// // // // // //                                   fontWeight: FontWeight.bold,
// // // // // //                                 ),
// // // // // //                               ),
// // // // // //                               subtitle: Column(
// // // // // //                                 crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //                                 children: [
// // // // // //                                   Text(
// // // // // //                                     '${work['selectedRoute']} - ${_formatDate(work['date'])}',
// // // // // //                                   ),
// // // // // //                                   Row(
// // // // // //                                     children: [
// // // // // //                                       Text(
// // // // // //                                         '${work['nolon']} ج',
// // // // // //                                         style: TextStyle(
// // // // // //                                           color: Colors.green[700],
// // // // // //                                         ),
// // // // // //                                       ),
// // // // // //                                       const SizedBox(width: 8),
// // // // // //                                       Text(
// // // // // //                                         '${work['companyOvernight']} ج',
// // // // // //                                         style: TextStyle(
// // // // // //                                           color: Colors.orange[700],
// // // // // //                                         ),
// // // // // //                                       ),
// // // // // //                                       const SizedBox(width: 8),
// // // // // //                                       Text(
// // // // // //                                         '${work['companyHoliday']} ج',
// // // // // //                                         style: TextStyle(
// // // // // //                                           color: Colors.red[700],
// // // // // //                                         ),
// // // // // //                                       ),
// // // // // //                                     ],
// // // // // //                                   ),
// // // // // //                                 ],
// // // // // //                               ),
// // // // // //                               secondary: Text(
// // // // // //                                 _formatCurrency(totalAmount),
// // // // // //                                 style: const TextStyle(
// // // // // //                                   fontWeight: FontWeight.bold,
// // // // // //                                   color: Color(0xFF2E7D32),
// // // // // //                                 ),
// // // // // //                               ),
// // // // // //                             );
// // // // // //                           },
// // // // // //                         ),
// // // // // //                 ),
// // // // // //               ),

// // // // // //               // زر إنشاء الفاتورة
// // // // // //               Padding(
// // // // // //                 padding: const EdgeInsets.all(16),
// // // // // //                 child: SizedBox(
// // // // // //                   width: double.infinity,
// // // // // //                   height: 50,
// // // // // //                   child: ElevatedButton.icon(
// // // // // //                     onPressed:
// // // // // //                         _selectedTripsForInvoice.isEmpty || _isCreatingInvoice
// // // // // //                         ? null
// // // // // //                         : _createInvoice,
// // // // // //                     icon: _isCreatingInvoice
// // // // // //                         ? const SizedBox(
// // // // // //                             width: 20,
// // // // // //                             height: 20,
// // // // // //                             child: CircularProgressIndicator(
// // // // // //                               color: Colors.white,
// // // // // //                             ),
// // // // // //                           )
// // // // // //                         : const Icon(Icons.save),
// // // // // //                     label: Text(
// // // // // //                       _isCreatingInvoice ? 'جاري الإنشاء...' : 'إنشاء الفاتورة',
// // // // // //                       style: const TextStyle(fontSize: 16),
// // // // // //                     ),
// // // // // //                     style: ElevatedButton.styleFrom(
// // // // // //                       backgroundColor: const Color(0xFF2E7D32),
// // // // // //                       foregroundColor: Colors.white,
// // // // // //                       shape: RoundedRectangleBorder(
// // // // // //                         borderRadius: BorderRadius.circular(12),
// // // // // //                       ),
// // // // // //                     ),
// // // // // //                   ),
// // // // // //                 ),
// // // // // //               ),
// // // // // //             ],
// // // // // //           );
// // // // // //   }

// // // // // //   double _calculateInvoiceTotal() {
// // // // // //     double total = 0;
// // // // // //     for (var trip in _selectedTripsForInvoice) {
// // // // // //       total +=
// // // // // //           trip['nolon'] + trip['companyOvernight'] + trip['companyHoliday'];
// // // // // //     }
// // // // // //     return total;
// // // // // //   }

// // // // // //   Widget _buildInvoicesSection() {
// // // // // //     return Column(
// // // // // //       children: [
// // // // // //         Container(
// // // // // //           padding: const EdgeInsets.all(16),
// // // // // //           color: Colors.blue[50],
// // // // // //           child: Row(
// // // // // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // // //             children: [
// // // // // //               const Text(
// // // // // //                 'إجمالي الفواتير',
// // // // // //                 style: TextStyle(
// // // // // //                   fontWeight: FontWeight.bold,
// // // // // //                   color: Color(0xFF3498DB),
// // // // // //                 ),
// // // // // //               ),
// // // // // //               Text(
// // // // // //                 _formatCurrency(_calculateTotalInvoices()),
// // // // // //                 style: const TextStyle(
// // // // // //                   fontSize: 20,
// // // // // //                   fontWeight: FontWeight.bold,
// // // // // //                   color: Color(0xFF2E7D32),
// // // // // //                 ),
// // // // // //               ),
// // // // // //             ],
// // // // // //           ),
// // // // // //         ),
// // // // // //         Expanded(
// // // // // //           child: _invoices.isEmpty
// // // // // //               ? Center(
// // // // // //                   child: Column(
// // // // // //                     mainAxisAlignment: MainAxisAlignment.center,
// // // // // //                     children: [
// // // // // //                       const Icon(
// // // // // //                         Icons.receipt_long,
// // // // // //                         size: 80,
// // // // // //                         color: Colors.grey,
// // // // // //                       ),
// // // // // //                       const SizedBox(height: 20),
// // // // // //                       const Text(
// // // // // //                         'لا توجد فواتير',
// // // // // //                         style: TextStyle(
// // // // // //                           fontSize: 18,
// // // // // //                           color: Colors.grey,
// // // // // //                           fontWeight: FontWeight.bold,
// // // // // //                         ),
// // // // // //                       ),
// // // // // //                       const SizedBox(height: 10),
// // // // // //                       const Text(
// // // // // //                         'قم بإنشاء فاتورة أولاً',
// // // // // //                         style: TextStyle(color: Colors.grey),
// // // // // //                       ),
// // // // // //                       const SizedBox(height: 30),
// // // // // //                       ElevatedButton.icon(
// // // // // //                         onPressed: () => _changeSection(1),
// // // // // //                         icon: const Icon(Icons.add),
// // // // // //                         label: const Text('إنشاء فاتورة'),
// // // // // //                         style: ElevatedButton.styleFrom(
// // // // // //                           backgroundColor: const Color(0xFF3498DB),
// // // // // //                           foregroundColor: Colors.white,
// // // // // //                         ),
// // // // // //                       ),
// // // // // //                     ],
// // // // // //                   ),
// // // // // //                 )
// // // // // //               : ListView.builder(
// // // // // //                   padding: const EdgeInsets.all(8),
// // // // // //                   itemCount: _invoices.length,
// // // // // //                   itemBuilder: (context, index) {
// // // // // //                     final invoice = _invoices[index];
// // // // // //                     return _buildInvoiceCard(invoice, index);
// // // // // //                   },
// // // // // //                 ),
// // // // // //         ),
// // // // // //       ],
// // // // // //     );
// // // // // //   }

// // // // // //   Widget _buildInvoiceCard(Map<String, dynamic> invoice, int index) {
// // // // // //     final createdAt = invoice['createdAt'] as DateTime?;

// // // // // //     return Container(
// // // // // //       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
// // // // // //       decoration: BoxDecoration(
// // // // // //         color: Colors.white,
// // // // // //         borderRadius: BorderRadius.circular(12),
// // // // // //         border: Border.all(color: Colors.grey[300]!),
// // // // // //         boxShadow: [
// // // // // //           BoxShadow(
// // // // // //             color: Colors.black.withOpacity(0.05),
// // // // // //             blurRadius: 6,
// // // // // //             offset: const Offset(0, 2),
// // // // // //           ),
// // // // // //         ],
// // // // // //       ),
// // // // // //       child: ListTile(
// // // // // //         leading: CircleAvatar(
// // // // // //           backgroundColor: const Color(0xFF3498DB),
// // // // // //           child: Text(
// // // // // //             '${index + 1}',
// // // // // //             style: const TextStyle(
// // // // // //               color: Colors.white,
// // // // // //               fontWeight: FontWeight.bold,
// // // // // //             ),
// // // // // //           ),
// // // // // //         ),
// // // // // //         title: Text(
// // // // // //           invoice['name'],
// // // // // //           style: const TextStyle(
// // // // // //             fontWeight: FontWeight.bold,
// // // // // //             fontSize: 16,
// // // // // //             color: Color(0xFF2C3E50),
// // // // // //           ),
// // // // // //         ),
// // // // // //         subtitle: Column(
// // // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //           children: [
// // // // // //             Text(
// // // // // //               invoice['companyName'],
// // // // // //               style: TextStyle(color: Colors.blue[700]),
// // // // // //             ),
// // // // // //             const SizedBox(height: 4),
// // // // // //             Text(
// // // // // //               '${invoice['tripCount']} رحلة - ${createdAt != null ? _formatDate(createdAt) : 'غير معروف'}',
// // // // // //               style: const TextStyle(fontSize: 12, color: Colors.grey),
// // // // // //             ),
// // // // // //             const SizedBox(height: 4),
// // // // // //             Row(
// // // // // //               children: [
// // // // // //                 Chip(
// // // // // //                   label: Text('${invoice['nolonTotal']} ج نولون'),
// // // // // //                   backgroundColor: Colors.green[50],
// // // // // //                   labelStyle: TextStyle(color: Colors.green[700]),
// // // // // //                 ),
// // // // // //                 const SizedBox(width: 4),
// // // // // //                 Chip(
// // // // // //                   label: Text('${invoice['overnightTotal']} ج مبيت'),
// // // // // //                   backgroundColor: Colors.orange[50],
// // // // // //                   labelStyle: TextStyle(color: Colors.orange[700]),
// // // // // //                 ),
// // // // // //                 const SizedBox(width: 4),
// // // // // //                 Chip(
// // // // // //                   label: Text('${invoice['holidayTotal']} ج عطلة'),
// // // // // //                   backgroundColor: Colors.red[50],
// // // // // //                   labelStyle: TextStyle(color: Colors.red[700]),
// // // // // //                 ),
// // // // // //               ],
// // // // // //             ),
// // // // // //           ],
// // // // // //         ),
// // // // // //         trailing: Column(
// // // // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // // // //           children: [
// // // // // //             Text(
// // // // // //               _formatCurrency(invoice['totalAmount']),
// // // // // //               style: const TextStyle(
// // // // // //                 fontWeight: FontWeight.bold,
// // // // // //                 fontSize: 16,
// // // // // //                 color: Color(0xFF2E7D32),
// // // // // //               ),
// // // // // //             ),
// // // // // //             const SizedBox(height: 4),
// // // // // //             Text(
// // // // // //               'إجمالي',
// // // // // //               style: TextStyle(fontSize: 12, color: Colors.grey[600]),
// // // // // //             ),
// // // // // //           ],
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   double _calculateTotalInvoices() {
// // // // // //     double total = 0;
// // // // // //     for (var invoice in _invoices) {
// // // // // //       total += invoice['totalAmount'];
// // // // // //     }
// // // // // //     return total;
// // // // // //   }
// // // // // // }
// // // // // import 'dart:async';
// // // // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:intl/intl.dart';

// // // // // class CompanyWorkPage extends StatefulWidget {
// // // // //   const CompanyWorkPage({super.key});

// // // // //   @override
// // // // //   State<CompanyWorkPage> createState() => _CompanyWorkPageState();
// // // // // }

// // // // // class _CompanyWorkPageState extends State<CompanyWorkPage> {
// // // // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// // // // //   // متغيرات عامة
// // // // //   int _currentSection = 0; // 0: شغل الشركات، 1: إنشاء فاتورة، 2: الفواتير
// // // // //   List<Map<String, dynamic>> _allCompanies = [];
// // // // //   List<Map<String, dynamic>> _filteredCompanies = [];
// // // // //   String? _selectedCompany;
// // // // //   List<Map<String, dynamic>> _companyWork = [];
// // // // //   List<Map<String, dynamic>> _filteredCompanyWork = [];
// // // // //   bool _isLoading = false;
// // // // //   String _searchQuery = '';

// // // // //   // متغيرات قسم إنشاء الفاتورة
// // // // //   final List<Map<String, dynamic>> _selectedTripsForInvoice = [];
// // // // //   final TextEditingController _invoiceNameController = TextEditingController();
// // // // //   bool _isCreatingInvoice = false;

// // // // //   // متغيرات قسم الفواتير
// // // // //   List<Map<String, dynamic>> _invoices = [];

// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     _loadCompanies();
// // // // //     _loadInvoices();
// // // // //   }

// // // // //   // ================================
// // // // //   // تحميل بيانات الشركات
// // // // //   // ================================
// // // // //   Future<void> _loadCompanies() async {
// // // // //     setState(() => _isLoading = true);
// // // // //     try {
// // // // //       final companiesSnapshot = await _firestore.collection('companies').get();
// // // // //       final dailyWorkSnapshot = await _firestore.collection('dailyWork').get();

// // // // //       final List<Map<String, dynamic>> companiesList = [];

// // // // //       for (final companyDoc in companiesSnapshot.docs) {
// // // // //         final companyData = companyDoc.data();
// // // // //         final companyId = companyDoc.id;
// // // // //         final companyName =
// // // // //             (companyData['name'] ??
// // // // //                     companyData['companyName'] ??
// // // // //                     'شركة غير معروفة')
// // // // //                 .toString()
// // // // //                 .trim();

// // // // //         final companyTrips = dailyWorkSnapshot.docs
// // // // //             .where((doc) {
// // // // //               final data = doc.data();
// // // // //               final tripCompanyId = data['companyId'] ?? '';
// // // // //               return tripCompanyId == companyId;
// // // // //             })
// // // // //             .map((doc) {
// // // // //               final data = doc.data();
// // // // //               final tripDate = (data['date'] as Timestamp?)?.toDate();

// // // // //               return {
// // // // //                 'id': doc.id,
// // // // //                 'date': tripDate,
// // // // //                 'companyName': companyName,
// // // // //                 'companyId': companyId,
// // // // //                 'driverName': data['driverName'] ?? 'غير معروف',
// // // // //                 'nolon': (data['noLon'] ?? data['nolon'] ?? 0).toDouble(),
// // // // //                 'companyOvernight': (data['companyOvernight'] ?? 0).toDouble(),
// // // // //                 'companyHoliday': (data['companyHoliday'] ?? 0).toDouble(),
// // // // //                 'selectedPrice': (data['selectedPrice'] ?? 0).toDouble(),
// // // // //                 'karta': data['karta'] ?? '',
// // // // //                 'ohda': data['ohda'] ?? '',
// // // // //                 'selectedRoute': data['selectedRoute'] ?? '',
// // // // //                 'loadingLocation': data['loadingLocation'] ?? '',
// // // // //                 'unloadingLocation': data['unloadingLocation'] ?? '',
// // // // //                 'vehicleType': data['selectedVehicleType'] ?? '',
// // // // //                 'notes': data['selectedNotes'] ?? '',
// // // // //                 'isSelected': false, // للحقل الجديد في قسم الفواتير
// // // // //               };
// // // // //             })
// // // // //             .toList();

// // // // //         // ترتيب الرحلات من الأحدث إلى الأقدم
// // // // //         companyTrips.sort(
// // // // //           (a, b) => b['date']?.compareTo(a['date'] ?? DateTime.now()) ?? 0,
// // // // //         );

// // // // //         double totalNolon = 0.0;
// // // // //         double totalOvernight = 0.0;
// // // // //         double totalHoliday = 0.0;

// // // // //         for (var trip in companyTrips) {
// // // // //           totalNolon += trip['nolon'];
// // // // //           totalOvernight += trip['companyOvernight'];
// // // // //           totalHoliday += trip['companyHoliday'];
// // // // //         }

// // // // //         companiesList.add({
// // // // //           'companyId': companyId,
// // // // //           'companyName': companyName,
// // // // //           'companyData': companyData,
// // // // //           'allTrips': companyTrips,
// // // // //           'hasTrips': companyTrips.isNotEmpty,
// // // // //           'totalTrips': companyTrips.length,
// // // // //           'totalNolon': totalNolon,
// // // // //           'totalOvernight': totalOvernight,
// // // // //           'totalHoliday': totalHoliday,
// // // // //         });
// // // // //       }

// // // // //       // ترتيب الشركات حسب الأحدث (التي بها رحلات حديثة)
// // // // //       companiesList.sort((a, b) {
// // // // //         final aLatestTrip = a['allTrips'].isNotEmpty
// // // // //             ? a['allTrips'].first['date']
// // // // //             : DateTime(1900);
// // // // //         final bLatestTrip = b['allTrips'].isNotEmpty
// // // // //             ? b['allTrips'].first['date']
// // // // //             : DateTime(1900);
// // // // //         return bLatestTrip.compareTo(aLatestTrip);
// // // // //       });

// // // // //       setState(() {
// // // // //         _allCompanies = companiesList;
// // // // //         _filteredCompanies = _applySearchFilter(companiesList);
// // // // //         _isLoading = false;
// // // // //       });
// // // // //     } catch (e) {
// // // // //       setState(() => _isLoading = false);
// // // // //       debugPrint('خطأ في تحميل بيانات الشركات: $e');
// // // // //     }
// // // // //   }

// // // // //   // ================================
// // // // //   // تحميل شغل شركة محددة
// // // // //   // ================================
// // // // //   Future<void> _loadCompanyWork(String companyName) async {
// // // // //     setState(() {
// // // // //       _selectedCompany = companyName;
// // // // //       _isLoading = true;
// // // // //       _companyWork.clear();
// // // // //     });

// // // // //     try {
// // // // //       final company = _allCompanies.firstWhere(
// // // // //         (c) => c['companyName'] == companyName,
// // // // //         orElse: () => {},
// // // // //       );

// // // // //       if (company.isEmpty) {
// // // // //         _showError('الشركة غير موجودة');
// // // // //         return;
// // // // //       }

// // // // //       final companyTrips = company['allTrips'] as List<Map<String, dynamic>>;

// // // // //       setState(() {
// // // // //         _companyWork = companyTrips;
// // // // //         _isLoading = false;
// // // // //       });
// // // // //     } catch (e) {
// // // // //       setState(() => _isLoading = false);
// // // // //       _showError('خطأ في تحميل شغل الشركة: $e');
// // // // //     }
// // // // //   }

// // // // //   // ================================
// // // // //   // تحميل الفواتير
// // // // //   // ================================
// // // // //   Future<void> _loadInvoices() async {
// // // // //     try {
// // // // //       final invoicesSnapshot = await _firestore
// // // // //           .collection('invoices')
// // // // //           .orderBy('createdAt', descending: true)
// // // // //           .get();

// // // // //       final List<Map<String, dynamic>> invoicesList = [];

// // // // //       for (final doc in invoicesSnapshot.docs) {
// // // // //         final data = doc.data();
// // // // //         invoicesList.add({
// // // // //           'id': doc.id,
// // // // //           'name': data['name'] ?? 'فاتورة بدون اسم',
// // // // //           'companyName': data['companyName'] ?? 'شركة غير معروفة',
// // // // //           'totalAmount': (data['totalAmount'] ?? 0).toDouble(),
// // // // //           'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
// // // // //           'tripCount': (data['tripIds'] as List? ?? []).length,
// // // // //           'nolonTotal': (data['nolonTotal'] ?? 0).toDouble(),
// // // // //           'overnightTotal': (data['overnightTotal'] ?? 0).toDouble(),
// // // // //           'holidayTotal': (data['holidayTotal'] ?? 0).toDouble(),
// // // // //         });
// // // // //       }

// // // // //       setState(() {
// // // // //         _invoices = invoicesList;
// // // // //       });
// // // // //     } catch (e) {
// // // // //       debugPrint('خطأ في تحميل الفواتير: $e');
// // // // //     }
// // // // //   }

// // // // //   // ================================
// // // // //   // دوال التصفية والبحث
// // // // //   // ================================
// // // // //   List<Map<String, dynamic>> _applySearchFilter(
// // // // //     List<Map<String, dynamic>> companies,
// // // // //   ) {
// // // // //     if (_searchQuery.isEmpty) return companies;
// // // // //     return companies
// // // // //         .where(
// // // // //           (c) => c['companyName'].toLowerCase().contains(
// // // // //             _searchQuery.toLowerCase(),
// // // // //           ),
// // // // //         )
// // // // //         .toList();
// // // // //   }

// // // // //   // ================================
// // // // //   // دوال قسم إنشاء الفاتورة
// // // // //   // ================================
// // // // //   void _toggleTripSelection(Map<String, dynamic> trip, bool selected) {
// // // // //     setState(() {
// // // // //       trip['isSelected'] = selected;
// // // // //       if (selected) {
// // // // //         _selectedTripsForInvoice.add(trip);
// // // // //       } else {
// // // // //         _selectedTripsForInvoice.removeWhere((t) => t['id'] == trip['id']);
// // // // //       }
// // // // //     });
// // // // //   }

// // // // //   void _selectAllTrips(bool select) {
// // // // //     setState(() {
// // // // //       for (var trip in _companyWork) {
// // // // //         trip['isSelected'] = select;
// // // // //       }

// // // // //       if (select) {
// // // // //         _selectedTripsForInvoice.clear();
// // // // //         _selectedTripsForInvoice.addAll(_companyWork);
// // // // //       } else {
// // // // //         _selectedTripsForInvoice.clear();
// // // // //       }
// // // // //     });
// // // // //   }

// // // // //   Future<void> _createInvoice() async {
// // // // //     if (_selectedTripsForInvoice.isEmpty) {
// // // // //       _showError('يرجى اختيار رحلات لإنشاء الفاتورة');
// // // // //       return;
// // // // //     }

// // // // //     if (_invoiceNameController.text.isEmpty) {
// // // // //       _showError('يرجى إدخال اسم الفاتورة');
// // // // //       return;
// // // // //     }

// // // // //     setState(() => _isCreatingInvoice = true);

// // // // //     try {
// // // // //       // حساب إجمالي المبلغ
// // // // //       double totalNolon = 0;
// // // // //       double totalOvernight = 0;
// // // // //       double totalHoliday = 0;
// // // // //       List<String> tripIds = [];

// // // // //       for (var trip in _selectedTripsForInvoice) {
// // // // //         totalNolon += trip['nolon'];
// // // // //         totalOvernight += trip['companyOvernight'];
// // // // //         totalHoliday += trip['companyHoliday'];
// // // // //         tripIds.add(trip['id']);
// // // // //       }

// // // // //       double totalAmount = totalNolon + totalOvernight + totalHoliday;

// // // // //       // حفظ الفاتورة
// // // // //       await _firestore.collection('invoices').add({
// // // // //         'name': _invoiceNameController.text.trim(),
// // // // //         'companyName': _selectedCompany!,
// // // // //         'companyId': _companyWork.first['companyId'],
// // // // //         'totalAmount': totalAmount,
// // // // //         'nolonTotal': totalNolon,
// // // // //         'overnightTotal': totalOvernight,
// // // // //         'holidayTotal': totalHoliday,
// // // // //         'tripIds': tripIds,
// // // // //         'createdAt': Timestamp.now(),
// // // // //         'status': 'غير مدفوعة',
// // // // //       });

// // // // //       // حذف الرحلات المختارة من dailyWork
// // // // //       final batch = _firestore.batch();
// // // // //       for (var tripId in tripIds) {
// // // // //         batch.delete(_firestore.collection('dailyWork').doc(tripId));
// // // // //       }
// // // // //       await batch.commit();

// // // // //       // تحديث البيانات المحلية
// // // // //       _companyWork.removeWhere((trip) => tripIds.contains(trip['id']));
// // // // //       _selectedTripsForInvoice.clear();
// // // // //       _invoiceNameController.clear();

// // // // //       _showSuccess('تم إنشاء الفاتورة وحذف الرحلات المختارة بنجاح');
// // // // //       await _loadCompanies(); // تحديث قائمة الشركات
// // // // //       await _loadInvoices(); // تحديث قائمة الفواتير

// // // // //       // الرجوع إلى قسم الفواتير
// // // // //       _changeSection(2);
// // // // //     } catch (e) {
// // // // //       _showError('خطأ في إنشاء الفاتورة: $e');
// // // // //     } finally {
// // // // //       setState(() => _isCreatingInvoice = false);
// // // // //     }
// // // // //   }

// // // // //   // ================================
// // // // //   // دوال مساعدة
// // // // //   // ================================
// // // // //   void _showError(String message) {
// // // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // // //       SnackBar(content: Text(message), backgroundColor: Colors.red),
// // // // //     );
// // // // //   }

// // // // //   void _showSuccess(String message) {
// // // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // // //       SnackBar(content: Text(message), backgroundColor: Colors.green),
// // // // //     );
// // // // //   }

// // // // //   String _formatDate(DateTime? date) {
// // // // //     if (date == null) return '-';
// // // // //     return DateFormat('dd/MM/yyyy').format(date);
// // // // //   }

// // // // //   String _formatCurrency(double amount) {
// // // // //     return '${amount.toStringAsFixed(2)} ج';
// // // // //   }

// // // // //   void _changeSection(int section) {
// // // // //     setState(() {
// // // // //       _currentSection = section;
// // // // //       if (section == 0) {
// // // // //         _selectedTripsForInvoice.clear();
// // // // //         _invoiceNameController.clear();
// // // // //         if (_companyWork.isNotEmpty) {
// // // // //           for (var trip in _companyWork) {
// // // // //             trip['isSelected'] = false;
// // // // //           }
// // // // //         }
// // // // //       }
// // // // //     });
// // // // //   }

// // // // //   // ================================
// // // // //   // بناء الواجهة
// // // // //   // ================================
// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Scaffold(
// // // // //       backgroundColor: const Color(0xFFF4F6F8),
// // // // //       body: Column(
// // // // //         children: [
// // // // //           _buildCustomAppBar(),
// // // // //           _buildSectionTabs(),
// // // // //           if (_currentSection == 0 && _selectedCompany == null)
// // // // //             _buildSearchBar(),
// // // // //           Expanded(
// // // // //             child: _currentSection == 0
// // // // //                 ? (_selectedCompany == null
// // // // //                       ? _buildCompanyList()
// // // // //                       : _buildWorkTable())
// // // // //                 : _currentSection == 1
// // // // //                 ? _buildCreateInvoiceSection()
// // // // //                 : _buildInvoicesSection(),
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Widget _buildCustomAppBar() {
// // // // //     return Container(
// // // // //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// // // // //       decoration: const BoxDecoration(
// // // // //         gradient: LinearGradient(
// // // // //           begin: Alignment.centerRight,
// // // // //           end: Alignment.centerLeft,
// // // // //           colors: [Color(0xFF1B4F72), Color(0xFF3498DB)],
// // // // //         ),
// // // // //         boxShadow: [
// // // // //           BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
// // // // //         ],
// // // // //       ),
// // // // //       child: SafeArea(
// // // // //         child: Row(
// // // // //           children: [
// // // // //             const Icon(Icons.business, color: Colors.white, size: 28),
// // // // //             const SizedBox(width: 8),
// // // // //             Expanded(
// // // // //               child: Center(
// // // // //                 child: Text(
// // // // //                   _selectedCompany == null
// // // // //                       ? _getSectionTitle()
// // // // //                       : 'شغل شركة $_selectedCompany',
// // // // //                   style: const TextStyle(
// // // // //                     color: Colors.white,
// // // // //                     fontSize: 20,
// // // // //                     fontWeight: FontWeight.bold,
// // // // //                   ),
// // // // //                 ),
// // // // //               ),
// // // // //             ),
// // // // //             if (_selectedCompany != null)
// // // // //               IconButton(
// // // // //                 icon: const Icon(Icons.arrow_back, color: Colors.white),
// // // // //                 onPressed: () {
// // // // //                   setState(() {
// // // // //                     _selectedCompany = null;
// // // // //                     _companyWork.clear();
// // // // //                     _selectedTripsForInvoice.clear();
// // // // //                     _invoiceNameController.clear();
// // // // //                   });
// // // // //                 },
// // // // //               ),
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   String _getSectionTitle() {
// // // // //     switch (_currentSection) {
// // // // //       case 0:
// // // // //         return 'شغل الشركات';
// // // // //       case 1:
// // // // //         return 'إنشاء فاتورة';
// // // // //       case 2:
// // // // //         return 'الفواتير';
// // // // //       default:
// // // // //         return 'شغل الشركات';
// // // // //     }
// // // // //   }

// // // // //   Widget _buildSectionTabs() {
// // // // //     return Container(
// // // // //       color: Colors.white,
// // // // //       child: Row(
// // // // //         children: [
// // // // //           _buildSectionTab(0, Icons.business, 'شغل الشركات'),
// // // // //           _buildSectionTab(1, Icons.receipt, 'إنشاء فاتورة'),
// // // // //           _buildSectionTab(2, Icons.list_alt, 'الفواتير'),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Widget _buildSectionTab(int section, IconData icon, String title) {
// // // // //     final isActive = _currentSection == section;
// // // // //     return Expanded(
// // // // //       child: InkWell(
// // // // //         onTap: () => _changeSection(section),
// // // // //         child: Container(
// // // // //           padding: const EdgeInsets.symmetric(vertical: 12),
// // // // //           decoration: BoxDecoration(
// // // // //             color: isActive ? const Color(0xFF3498DB) : Colors.white,
// // // // //             border: Border(
// // // // //               bottom: BorderSide(
// // // // //                 color: isActive ? const Color(0xFF3498DB) : Colors.grey[300]!,
// // // // //                 width: 3,
// // // // //               ),
// // // // //             ),
// // // // //           ),
// // // // //           child: Column(
// // // // //             children: [
// // // // //               Icon(
// // // // //                 icon,
// // // // //                 color: isActive ? Colors.white : Colors.grey,
// // // // //                 size: 22,
// // // // //               ),
// // // // //               const SizedBox(height: 4),
// // // // //               Text(
// // // // //                 title,
// // // // //                 style: TextStyle(
// // // // //                   color: isActive ? Colors.white : Colors.grey,
// // // // //                   fontSize: 12,
// // // // //                   fontWeight: FontWeight.bold,
// // // // //                 ),
// // // // //               ),
// // // // //             ],
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Widget _buildSearchBar() {
// // // // //     return Container(
// // // // //       padding: const EdgeInsets.all(12),
// // // // //       color: Colors.white,
// // // // //       child: Container(
// // // // //         padding: const EdgeInsets.symmetric(horizontal: 12),
// // // // //         decoration: BoxDecoration(
// // // // //           color: const Color(0xFFF4F6F8),
// // // // //           borderRadius: BorderRadius.circular(12),
// // // // //           border: Border.all(color: const Color(0xFF3498DB)),
// // // // //         ),
// // // // //         child: Row(
// // // // //           children: [
// // // // //             const Icon(Icons.search, color: Color(0xFF3498DB), size: 20),
// // // // //             const SizedBox(width: 8),
// // // // //             Expanded(
// // // // //               child: TextField(
// // // // //                 onChanged: (value) {
// // // // //                   setState(() {
// // // // //                     _searchQuery = value;
// // // // //                     _filteredCompanies = _applySearchFilter(_allCompanies);
// // // // //                   });
// // // // //                 },
// // // // //                 decoration: const InputDecoration(
// // // // //                   hintText: 'ابحث عن شركة...',
// // // // //                   border: InputBorder.none,
// // // // //                   hintStyle: TextStyle(color: Colors.grey),
// // // // //                 ),
// // // // //               ),
// // // // //             ),
// // // // //             if (_searchQuery.isNotEmpty)
// // // // //               GestureDetector(
// // // // //                 onTap: () {
// // // // //                   setState(() {
// // // // //                     _searchQuery = '';
// // // // //                     _filteredCompanies = _applySearchFilter(_allCompanies);
// // // // //                   });
// // // // //                 },
// // // // //                 child: const Icon(Icons.clear, size: 18, color: Colors.grey),
// // // // //               ),
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Widget _buildCompanyList() {
// // // // //     if (_isLoading) return const Center(child: CircularProgressIndicator());

// // // // //     final companiesWithTrips = _filteredCompanies
// // // // //         .where((c) => c['hasTrips'])
// // // // //         .toList();
// // // // //     final companiesWithoutTrips = _filteredCompanies
// // // // //         .where((c) => !c['hasTrips'])
// // // // //         .toList();

// // // // //     return ListView(
// // // // //       padding: const EdgeInsets.all(8),
// // // // //       children: [
// // // // //         ...companiesWithTrips.map((company) => _buildCompanyCard(company)),
// // // // //         if (companiesWithTrips.isEmpty && companiesWithoutTrips.isNotEmpty)
// // // // //           Container(
// // // // //             margin: const EdgeInsets.all(16),
// // // // //             padding: const EdgeInsets.all(20),
// // // // //             decoration: BoxDecoration(
// // // // //               color: Colors.white,
// // // // //               borderRadius: BorderRadius.circular(12),
// // // // //               border: Border.all(color: Colors.grey[300]!),
// // // // //             ),
// // // // //             child: Column(
// // // // //               children: [
// // // // //                 Icon(Icons.business, size: 60, color: Colors.grey[400]),
// // // // //                 const SizedBox(height: 16),
// // // // //                 const Text(
// // // // //                   'لا توجد شركات لديها رحلات',
// // // // //                   style: TextStyle(
// // // // //                     fontSize: 16,
// // // // //                     color: Colors.grey,
// // // // //                     fontWeight: FontWeight.bold,
// // // // //                   ),
// // // // //                   textAlign: TextAlign.center,
// // // // //                 ),
// // // // //               ],
// // // // //             ),
// // // // //           ),
// // // // //       ],
// // // // //     );
// // // // //   }

// // // // //   Widget _buildCompanyCard(Map<String, dynamic> company) {
// // // // //     final companyName = company['companyName'];
// // // // //     final totalTrips = company['totalTrips'];
// // // // //     final hasTrips = company['hasTrips'];
// // // // //     final totalNolon = company['totalNolon'] ?? 0;

// // // // //     return Container(
// // // // //       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
// // // // //       decoration: BoxDecoration(
// // // // //         color: Colors.white,
// // // // //         borderRadius: BorderRadius.circular(12),
// // // // //         border: Border.all(
// // // // //           color: hasTrips
// // // // //               ? const Color(0xFF3498DB).withOpacity(0.3)
// // // // //               : Colors.grey.withOpacity(0.3),
// // // // //         ),
// // // // //         boxShadow: [
// // // // //           BoxShadow(
// // // // //             color: Colors.black.withOpacity(0.05),
// // // // //             blurRadius: 8,
// // // // //             offset: const Offset(0, 2),
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //       child: ListTile(
// // // // //         leading: Container(
// // // // //           width: 45,
// // // // //           height: 45,
// // // // //           decoration: BoxDecoration(
// // // // //             color: hasTrips ? const Color(0xFF3498DB) : Colors.grey,
// // // // //             borderRadius: BorderRadius.circular(22.5),
// // // // //           ),
// // // // //           child: Center(
// // // // //             child: Text(
// // // // //               totalTrips.toString(),
// // // // //               style: const TextStyle(
// // // // //                 color: Colors.white,
// // // // //                 fontWeight: FontWeight.bold,
// // // // //                 fontSize: 16,
// // // // //               ),
// // // // //             ),
// // // // //           ),
// // // // //         ),
// // // // //         title: Text(
// // // // //           companyName,
// // // // //           style: TextStyle(
// // // // //             fontWeight: FontWeight.bold,
// // // // //             fontSize: 16,
// // // // //             color: hasTrips ? const Color(0xFF2C3E50) : Colors.grey,
// // // // //           ),
// // // // //         ),
// // // // //         subtitle: Column(
// // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // //           children: [
// // // // //             Text(
// // // // //               hasTrips
// // // // //                   ? '$totalTrips رحلة - ${_formatCurrency(totalNolon)}'
// // // // //                   : 'لا توجد رحلات',
// // // // //               style: TextStyle(
// // // // //                 color: hasTrips ? Colors.green : Colors.grey,
// // // // //                 fontSize: 12,
// // // // //               ),
// // // // //             ),
// // // // //           ],
// // // // //         ),
// // // // //         trailing: Icon(
// // // // //           Icons.arrow_forward_ios,
// // // // //           color: hasTrips ? const Color(0xFF3498DB) : Colors.grey,
// // // // //           size: 16,
// // // // //         ),
// // // // //         onTap: hasTrips ? () => _loadCompanyWork(companyName) : null,
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Widget _buildWorkTable() {
// // // // //     if (_isLoading) return const Center(child: CircularProgressIndicator());

// // // // //     return Column(
// // // // //       children: [
// // // // //         Padding(
// // // // //           padding: const EdgeInsets.all(12),
// // // // //           child: Row(
// // // // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // //             children: [
// // // // //               ElevatedButton.icon(
// // // // //                 onPressed: () => _changeSection(1),
// // // // //                 icon: const Icon(Icons.receipt),
// // // // //                 label: const Text('إنشاء فاتورة من هذه الرحلات'),
// // // // //                 style: ElevatedButton.styleFrom(
// // // // //                   backgroundColor: const Color(0xFF2E7D32),
// // // // //                   foregroundColor: Colors.white,
// // // // //                 ),
// // // // //               ),
// // // // //               Text(
// // // // //                 '${_companyWork.length} رحلة',
// // // // //                 style: const TextStyle(
// // // // //                   fontWeight: FontWeight.bold,
// // // // //                   color: Color(0xFF3498DB),
// // // // //                 ),
// // // // //               ),
// // // // //             ],
// // // // //           ),
// // // // //         ),
// // // // //         Expanded(
// // // // //           child: Container(
// // // // //             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // // // //             decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
// // // // //             child: _companyWork.isEmpty
// // // // //                 ? Center(
// // // // //                     child: Column(
// // // // //                       mainAxisAlignment: MainAxisAlignment.center,
// // // // //                       children: [
// // // // //                         const Icon(
// // // // //                           Icons.business,
// // // // //                           size: 60,
// // // // //                           color: Colors.grey,
// // // // //                         ),
// // // // //                         const SizedBox(height: 16),
// // // // //                         const Text(
// // // // //                           'لا يوجد شغل مسجل لهذه الشركة',
// // // // //                           style: TextStyle(
// // // // //                             color: Colors.grey,
// // // // //                             fontSize: 18,
// // // // //                             fontWeight: FontWeight.bold,
// // // // //                           ),
// // // // //                         ),
// // // // //                         const SizedBox(height: 20),
// // // // //                         ElevatedButton.icon(
// // // // //                           onPressed: () {
// // // // //                             setState(() => _selectedCompany = null);
// // // // //                           },
// // // // //                           icon: const Icon(Icons.arrow_back),
// // // // //                           label: const Text('العودة للشركات'),
// // // // //                         ),
// // // // //                       ],
// // // // //                     ),
// // // // //                   )
// // // // //                 : SingleChildScrollView(
// // // // //                     scrollDirection: Axis.horizontal,
// // // // //                     child: SingleChildScrollView(
// // // // //                       scrollDirection: Axis.vertical,
// // // // //                       child: Table(
// // // // //                         defaultColumnWidth: const FixedColumnWidth(110),
// // // // //                         border: TableBorder.all(
// // // // //                           color: const Color(0xFF3498DB),
// // // // //                           width: 1,
// // // // //                         ),
// // // // //                         children: [
// // // // //                           TableRow(
// // // // //                             decoration: BoxDecoration(
// // // // //                               color: const Color(0xFF3498DB).withOpacity(0.15),
// // // // //                             ),
// // // // //                             children: const [
// // // // //                               TableCellHeader('عطلة الشركة'),
// // // // //                               TableCellHeader('مبيت الشركة'),
// // // // //                               TableCellHeader('نولون الشركة'),
// // // // //                               TableCellHeader('اسم السائق'),
// // // // //                               TableCellHeader('الكارتة'),
// // // // //                               TableCellHeader('العهدة'),
// // // // //                               TableCellHeader('اسم الموقع'),
// // // // //                               TableCellHeader('مكان التعتيق'),
// // // // //                               TableCellHeader('مكان التحميل'),
// // // // //                               TableCellHeader('التاريخ'),
// // // // //                               TableCellHeader('م'),
// // // // //                             ],
// // // // //                           ),
// // // // //                           ..._companyWork.asMap().entries.map((entry) {
// // // // //                             final index = entry.key;
// // // // //                             final work = entry.value;

// // // // //                             return TableRow(
// // // // //                               decoration: BoxDecoration(
// // // // //                                 color: index.isEven
// // // // //                                     ? Colors.white
// // // // //                                     : const Color(0xFFF8F9FA),
// // // // //                               ),
// // // // //                               children: [
// // // // //                                 TableCellBody(
// // // // //                                   '${work['companyHoliday']} ج',
// // // // //                                   textStyle: const TextStyle(
// // // // //                                     fontWeight: FontWeight.bold,
// // // // //                                     color: Colors.red,
// // // // //                                   ),
// // // // //                                 ),
// // // // //                                 TableCellBody(
// // // // //                                   '${work['companyOvernight']} ج',
// // // // //                                   textStyle: TextStyle(
// // // // //                                     fontWeight: FontWeight.bold,
// // // // //                                     color: Colors.orange[700],
// // // // //                                   ),
// // // // //                                 ),
// // // // //                                 TableCellBody(
// // // // //                                   '${work['nolon']} ج',
// // // // //                                   textStyle: const TextStyle(
// // // // //                                     fontWeight: FontWeight.bold,
// // // // //                                     color: Colors.green,
// // // // //                                   ),
// // // // //                                 ),
// // // // //                                 TableCellBody(
// // // // //                                   work['driverName'],
// // // // //                                   textStyle: const TextStyle(
// // // // //                                     fontWeight: FontWeight.bold,
// // // // //                                     color: Color(0xFF2C3E50),
// // // // //                                   ),
// // // // //                                 ),
// // // // //                                 TableCellBody(work['karta']),
// // // // //                                 TableCellBody(work['ohda']),
// // // // //                                 TableCellBody(
// // // // //                                   work['selectedRoute'],
// // // // //                                   textStyle: const TextStyle(
// // // // //                                     fontWeight: FontWeight.bold,
// // // // //                                     color: Color(0xFF3498DB),
// // // // //                                   ),
// // // // //                                 ),
// // // // //                                 TableCellBody(work['unloadingLocation']),
// // // // //                                 TableCellBody(work['loadingLocation']),
// // // // //                                 TableCellBody(_formatDate(work['date'])),
// // // // //                                 TableCellBody('${index + 1}'),
// // // // //                               ],
// // // // //                             );
// // // // //                           }).toList(),
// // // // //                         ],
// // // // //                       ),
// // // // //                     ),
// // // // //                   ),
// // // // //           ),
// // // // //         ),
// // // // //       ],
// // // // //     );
// // // // //   }

// // // // //   Widget _buildCreateInvoiceSection() {
// // // // //     return _selectedCompany == null
// // // // //         ? Center(
// // // // //             child: Column(
// // // // //               mainAxisAlignment: MainAxisAlignment.center,
// // // // //               children: [
// // // // //                 const Icon(Icons.business, size: 80, color: Colors.grey),
// // // // //                 const SizedBox(height: 20),
// // // // //                 const Text(
// // // // //                   'يرجى اختيار شركة أولاً',
// // // // //                   style: TextStyle(
// // // // //                     fontSize: 18,
// // // // //                     color: Colors.grey,
// // // // //                     fontWeight: FontWeight.bold,
// // // // //                   ),
// // // // //                 ),
// // // // //                 const SizedBox(height: 10),
// // // // //                 const Text(
// // // // //                   'اذهب إلى قسم "شغل الشركات" واختر شركة',
// // // // //                   style: TextStyle(color: Colors.grey),
// // // // //                   textAlign: TextAlign.center,
// // // // //                 ),
// // // // //                 const SizedBox(height: 30),
// // // // //                 ElevatedButton.icon(
// // // // //                   onPressed: () => _changeSection(0),
// // // // //                   icon: const Icon(Icons.business),
// // // // //                   label: const Text('الذهاب إلى شغل الشركات'),
// // // // //                   style: ElevatedButton.styleFrom(
// // // // //                     backgroundColor: const Color(0xFF3498DB),
// // // // //                     foregroundColor: Colors.white,
// // // // //                     padding: const EdgeInsets.symmetric(
// // // // //                       horizontal: 20,
// // // // //                       vertical: 12,
// // // // //                     ),
// // // // //                   ),
// // // // //                 ),
// // // // //               ],
// // // // //             ),
// // // // //           )
// // // // //         : Column(
// // // // //             children: [
// // // // //               // إحصائيات الرحلات المختارة
// // // // //               Container(
// // // // //                 padding: const EdgeInsets.all(16),
// // // // //                 color: Colors.blue[50],
// // // // //                 child: Row(
// // // // //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // //                   children: [
// // // // //                     Column(
// // // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                       children: [
// // // // //                         const Text(
// // // // //                           'الرحلات المختارة',
// // // // //                           style: TextStyle(
// // // // //                             fontWeight: FontWeight.bold,
// // // // //                             color: Color(0xFF3498DB),
// // // // //                           ),
// // // // //                         ),
// // // // //                         Text(
// // // // //                           '${_selectedTripsForInvoice.length} من ${_companyWork.length} رحلة',
// // // // //                           style: const TextStyle(
// // // // //                             fontSize: 18,
// // // // //                             fontWeight: FontWeight.bold,
// // // // //                             color: Color(0xFF2E7D32),
// // // // //                           ),
// // // // //                         ),
// // // // //                       ],
// // // // //                     ),
// // // // //                     Column(
// // // // //                       crossAxisAlignment: CrossAxisAlignment.end,
// // // // //                       children: [
// // // // //                         const Text(
// // // // //                           'إجمالي الفاتورة',
// // // // //                           style: TextStyle(
// // // // //                             fontWeight: FontWeight.bold,
// // // // //                             color: Color(0xFF3498DB),
// // // // //                           ),
// // // // //                         ),
// // // // //                         Text(
// // // // //                           _formatCurrency(_calculateInvoiceTotal()),
// // // // //                           style: const TextStyle(
// // // // //                             fontSize: 18,
// // // // //                             fontWeight: FontWeight.bold,
// // // // //                             color: Color(0xFF2E7D32),
// // // // //                           ),
// // // // //                         ),
// // // // //                       ],
// // // // //                     ),
// // // // //                   ],
// // // // //                 ),
// // // // //               ),

// // // // //               // اسم الفاتورة
// // // // //               Padding(
// // // // //                 padding: const EdgeInsets.all(16),
// // // // //                 child: TextField(
// // // // //                   controller: _invoiceNameController,
// // // // //                   decoration: InputDecoration(
// // // // //                     labelText: 'اسم الفاتورة',
// // // // //                     prefixIcon: const Icon(Icons.receipt),
// // // // //                     border: OutlineInputBorder(
// // // // //                       borderRadius: BorderRadius.circular(12),
// // // // //                     ),
// // // // //                     filled: true,
// // // // //                     fillColor: Colors.white,
// // // // //                   ),
// // // // //                 ),
// // // // //               ),

// // // // //               // أزرار التحكم
// // // // //               Padding(
// // // // //                 padding: const EdgeInsets.symmetric(horizontal: 16),
// // // // //                 child: Row(
// // // // //                   children: [
// // // // //                     Expanded(
// // // // //                       child: ElevatedButton.icon(
// // // // //                         onPressed: () => _selectAllTrips(true),
// // // // //                         icon: const Icon(Icons.check_box),
// // // // //                         label: const Text('تحديد الكل'),
// // // // //                         style: ElevatedButton.styleFrom(
// // // // //                           backgroundColor: Colors.green[50],
// // // // //                           foregroundColor: Colors.green[700],
// // // // //                         ),
// // // // //                       ),
// // // // //                     ),
// // // // //                     const SizedBox(width: 8),
// // // // //                     Expanded(
// // // // //                       child: ElevatedButton.icon(
// // // // //                         onPressed: () => _selectAllTrips(false),
// // // // //                         icon: const Icon(Icons.check_box_outline_blank),
// // // // //                         label: const Text('إلغاء الكل'),
// // // // //                         style: ElevatedButton.styleFrom(
// // // // //                           backgroundColor: Colors.red[50],
// // // // //                           foregroundColor: Colors.red[700],
// // // // //                         ),
// // // // //                       ),
// // // // //                     ),
// // // // //                   ],
// // // // //                 ),
// // // // //               ),

// // // // //               // جدول الرحلات مع خيار التحديد
// // // // //               Expanded(
// // // // //                 child: Container(
// // // // //                   margin: const EdgeInsets.all(16),
// // // // //                   decoration: BoxDecoration(
// // // // //                     borderRadius: BorderRadius.circular(12),
// // // // //                   ),
// // // // //                   child: _companyWork.isEmpty
// // // // //                       ? Center(
// // // // //                           child: Column(
// // // // //                             mainAxisAlignment: MainAxisAlignment.center,
// // // // //                             children: [
// // // // //                               const Icon(
// // // // //                                 Icons.list,
// // // // //                                 size: 60,
// // // // //                                 color: Colors.grey,
// // // // //                               ),
// // // // //                               const SizedBox(height: 16),
// // // // //                               const Text(
// // // // //                                 'لا توجد رحلات',
// // // // //                                 style: TextStyle(
// // // // //                                   color: Colors.grey,
// // // // //                                   fontSize: 18,
// // // // //                                 ),
// // // // //                               ),
// // // // //                             ],
// // // // //                           ),
// // // // //                         )
// // // // //                       : SingleChildScrollView(
// // // // //                           scrollDirection: Axis.horizontal,
// // // // //                           child: SingleChildScrollView(
// // // // //                             scrollDirection: Axis.vertical,
// // // // //                             child: Table(
// // // // //                               defaultColumnWidth: const FixedColumnWidth(120),
// // // // //                               border: TableBorder.all(
// // // // //                                 color: const Color(0xFF3498DB),
// // // // //                                 width: 1,
// // // // //                               ),
// // // // //                               children: [
// // // // //                                 TableRow(
// // // // //                                   decoration: BoxDecoration(
// // // // //                                     color: const Color(
// // // // //                                       0xFF3498DB,
// // // // //                                     ).withOpacity(0.15),
// // // // //                                   ),
// // // // //                                   children: [
// // // // //                                     const TableCellHeader('تحديد'),
// // // // //                                     const TableCellHeader('عطلة الشركة'),
// // // // //                                     const TableCellHeader('مبيت الشركة'),
// // // // //                                     const TableCellHeader('نولون الشركة'),
// // // // //                                     const TableCellHeader('اسم السائق'),
// // // // //                                     const TableCellHeader('الكارتة'),
// // // // //                                     const TableCellHeader('العهدة'),
// // // // //                                     const TableCellHeader('اسم الموقع'),
// // // // //                                     const TableCellHeader('مكان التعتيق'),
// // // // //                                     const TableCellHeader('مكان التحميل'),
// // // // //                                     const TableCellHeader('التاريخ'),
// // // // //                                     const TableCellHeader('م'),
// // // // //                                   ],
// // // // //                                 ),
// // // // //                                 ..._companyWork.asMap().entries.map((entry) {
// // // // //                                   final index = entry.key;
// // // // //                                   final work = entry.value;
// // // // //                                   final isSelected =
// // // // //                                       work['isSelected'] ?? false;

// // // // //                                   return TableRow(
// // // // //                                     decoration: BoxDecoration(
// // // // //                                       color: isSelected
// // // // //                                           ? const Color(0xFFE8F5E9)
// // // // //                                           : index.isEven
// // // // //                                           ? Colors.white
// // // // //                                           : const Color(0xFFF8F9FA),
// // // // //                                     ),
// // // // //                                     children: [
// // // // //                                       TableCell(
// // // // //                                         child: Checkbox(
// // // // //                                           value: isSelected,
// // // // //                                           onChanged: (value) {
// // // // //                                             _toggleTripSelection(
// // // // //                                               work,
// // // // //                                               value ?? false,
// // // // //                                             );
// // // // //                                           },
// // // // //                                         ),
// // // // //                                       ),
// // // // //                                       TableCellBody(
// // // // //                                         '${work['companyHoliday']} ج',
// // // // //                                         textStyle: const TextStyle(
// // // // //                                           fontWeight: FontWeight.bold,
// // // // //                                           color: Colors.red,
// // // // //                                         ),
// // // // //                                       ),
// // // // //                                       TableCellBody(
// // // // //                                         '${work['companyOvernight']} ج',
// // // // //                                         textStyle: TextStyle(
// // // // //                                           fontWeight: FontWeight.bold,
// // // // //                                           color: Colors.orange[700],
// // // // //                                         ),
// // // // //                                       ),
// // // // //                                       TableCellBody(
// // // // //                                         '${work['nolon']} ج',
// // // // //                                         textStyle: const TextStyle(
// // // // //                                           fontWeight: FontWeight.bold,
// // // // //                                           color: Colors.green,
// // // // //                                         ),
// // // // //                                       ),
// // // // //                                       TableCellBody(
// // // // //                                         work['driverName'],
// // // // //                                         textStyle: const TextStyle(
// // // // //                                           fontWeight: FontWeight.bold,
// // // // //                                           color: Color(0xFF2C3E50),
// // // // //                                         ),
// // // // //                                       ),
// // // // //                                       TableCellBody(work['karta']),
// // // // //                                       TableCellBody(work['ohda']),
// // // // //                                       TableCellBody(
// // // // //                                         work['selectedRoute'],
// // // // //                                         textStyle: const TextStyle(
// // // // //                                           fontWeight: FontWeight.bold,
// // // // //                                           color: Color(0xFF3498DB),
// // // // //                                         ),
// // // // //                                       ),
// // // // //                                       TableCellBody(work['unloadingLocation']),
// // // // //                                       TableCellBody(work['loadingLocation']),
// // // // //                                       TableCellBody(_formatDate(work['date'])),
// // // // //                                       TableCellBody('${index + 1}'),
// // // // //                                     ],
// // // // //                                   );
// // // // //                                 }).toList(),
// // // // //                               ],
// // // // //                             ),
// // // // //                           ),
// // // // //                         ),
// // // // //                 ),
// // // // //               ),

// // // // //               // زر إنشاء الفاتورة
// // // // //               Padding(
// // // // //                 padding: const EdgeInsets.all(16),
// // // // //                 child: SizedBox(
// // // // //                   width: double.infinity,
// // // // //                   height: 50,
// // // // //                   child: ElevatedButton.icon(
// // // // //                     onPressed:
// // // // //                         _selectedTripsForInvoice.isEmpty || _isCreatingInvoice
// // // // //                         ? null
// // // // //                         : _createInvoice,
// // // // //                     icon: _isCreatingInvoice
// // // // //                         ? const SizedBox(
// // // // //                             width: 20,
// // // // //                             height: 20,
// // // // //                             child: CircularProgressIndicator(
// // // // //                               color: Colors.white,
// // // // //                             ),
// // // // //                           )
// // // // //                         : const Icon(Icons.save),
// // // // //                     label: Text(
// // // // //                       _isCreatingInvoice ? 'جاري الإنشاء...' : 'إنشاء الفاتورة',
// // // // //                       style: const TextStyle(fontSize: 16),
// // // // //                     ),
// // // // //                     style: ElevatedButton.styleFrom(
// // // // //                       backgroundColor: const Color(0xFF2E7D32),
// // // // //                       foregroundColor: Colors.white,
// // // // //                       shape: RoundedRectangleBorder(
// // // // //                         borderRadius: BorderRadius.circular(12),
// // // // //                       ),
// // // // //                     ),
// // // // //                   ),
// // // // //                 ),
// // // // //               ),
// // // // //             ],
// // // // //           );
// // // // //   }

// // // // //   double _calculateInvoiceTotal() {
// // // // //     double total = 0;
// // // // //     for (var trip in _selectedTripsForInvoice) {
// // // // //       total +=
// // // // //           trip['nolon'] + trip['companyOvernight'] + trip['companyHoliday'];
// // // // //     }
// // // // //     return total;
// // // // //   }

// // // // //   Widget _buildInvoicesSection() {
// // // // //     return Column(
// // // // //       children: [
// // // // //         Container(
// // // // //           padding: const EdgeInsets.all(16),
// // // // //           color: Colors.blue[50],
// // // // //           child: Row(
// // // // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // //             children: [
// // // // //               const Text(
// // // // //                 'إجمالي الفواتير',
// // // // //                 style: TextStyle(
// // // // //                   fontWeight: FontWeight.bold,
// // // // //                   color: Color(0xFF3498DB),
// // // // //                 ),
// // // // //               ),
// // // // //               Text(
// // // // //                 _formatCurrency(_calculateTotalInvoices()),
// // // // //                 style: const TextStyle(
// // // // //                   fontSize: 20,
// // // // //                   fontWeight: FontWeight.bold,
// // // // //                   color: Color(0xFF2E7D32),
// // // // //                 ),
// // // // //               ),
// // // // //             ],
// // // // //           ),
// // // // //         ),
// // // // //         Expanded(
// // // // //           child: _invoices.isEmpty
// // // // //               ? Center(
// // // // //                   child: Column(
// // // // //                     mainAxisAlignment: MainAxisAlignment.center,
// // // // //                     children: [
// // // // //                       const Icon(
// // // // //                         Icons.receipt_long,
// // // // //                         size: 80,
// // // // //                         color: Colors.grey,
// // // // //                       ),
// // // // //                       const SizedBox(height: 20),
// // // // //                       const Text(
// // // // //                         'لا توجد فواتير',
// // // // //                         style: TextStyle(
// // // // //                           fontSize: 18,
// // // // //                           color: Colors.grey,
// // // // //                           fontWeight: FontWeight.bold,
// // // // //                         ),
// // // // //                       ),
// // // // //                       const SizedBox(height: 10),
// // // // //                       const Text(
// // // // //                         'قم بإنشاء فاتورة أولاً',
// // // // //                         style: TextStyle(color: Colors.grey),
// // // // //                       ),
// // // // //                       const SizedBox(height: 30),
// // // // //                       ElevatedButton.icon(
// // // // //                         onPressed: () => _changeSection(1),
// // // // //                         icon: const Icon(Icons.add),
// // // // //                         label: const Text('إنشاء فاتورة'),
// // // // //                         style: ElevatedButton.styleFrom(
// // // // //                           backgroundColor: const Color(0xFF3498DB),
// // // // //                           foregroundColor: Colors.white,
// // // // //                         ),
// // // // //                       ),
// // // // //                     ],
// // // // //                   ),
// // // // //                 )
// // // // //               : ListView.builder(
// // // // //                   padding: const EdgeInsets.all(8),
// // // // //                   itemCount: _invoices.length,
// // // // //                   itemBuilder: (context, index) {
// // // // //                     final invoice = _invoices[index];
// // // // //                     return _buildInvoiceCard(invoice, index);
// // // // //                   },
// // // // //                 ),
// // // // //         ),
// // // // //       ],
// // // // //     );
// // // // //   }

// // // // //   Widget _buildInvoiceCard(Map<String, dynamic> invoice, int index) {
// // // // //     final createdAt = invoice['createdAt'] as DateTime?;

// // // // //     return Container(
// // // // //       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
// // // // //       decoration: BoxDecoration(
// // // // //         color: Colors.white,
// // // // //         borderRadius: BorderRadius.circular(12),
// // // // //         border: Border.all(color: Colors.grey[300]!),
// // // // //         boxShadow: [
// // // // //           BoxShadow(
// // // // //             color: Colors.black.withOpacity(0.05),
// // // // //             blurRadius: 6,
// // // // //             offset: const Offset(0, 2),
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //       child: ListTile(
// // // // //         leading: CircleAvatar(
// // // // //           backgroundColor: const Color(0xFF3498DB),
// // // // //           child: Text(
// // // // //             '${index + 1}',
// // // // //             style: const TextStyle(
// // // // //               color: Colors.white,
// // // // //               fontWeight: FontWeight.bold,
// // // // //             ),
// // // // //           ),
// // // // //         ),
// // // // //         title: Text(
// // // // //           invoice['name'],
// // // // //           style: const TextStyle(
// // // // //             fontWeight: FontWeight.bold,
// // // // //             fontSize: 16,
// // // // //             color: Color(0xFF2C3E50),
// // // // //           ),
// // // // //         ),
// // // // //         subtitle: Column(
// // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // //           children: [
// // // // //             Text(
// // // // //               invoice['companyName'],
// // // // //               style: TextStyle(color: Colors.blue[700]),
// // // // //             ),
// // // // //             const SizedBox(height: 4),
// // // // //             Text(
// // // // //               '${invoice['tripCount']} رحلة - ${createdAt != null ? _formatDate(createdAt) : 'غير معروف'}',
// // // // //               style: const TextStyle(fontSize: 12, color: Colors.grey),
// // // // //             ),
// // // // //             const SizedBox(height: 4),
// // // // //             Row(
// // // // //               children: [
// // // // //                 Chip(
// // // // //                   label: Text('${invoice['nolonTotal']} ج نولون'),
// // // // //                   backgroundColor: Colors.green[50],
// // // // //                   labelStyle: TextStyle(color: Colors.green[700]),
// // // // //                 ),
// // // // //                 const SizedBox(width: 4),
// // // // //                 Chip(
// // // // //                   label: Text('${invoice['overnightTotal']} ج مبيت'),
// // // // //                   backgroundColor: Colors.orange[50],
// // // // //                   labelStyle: TextStyle(color: Colors.orange[700]),
// // // // //                 ),
// // // // //                 const SizedBox(width: 4),
// // // // //                 Chip(
// // // // //                   label: Text('${invoice['holidayTotal']} ج عطلة'),
// // // // //                   backgroundColor: Colors.red[50],
// // // // //                   labelStyle: TextStyle(color: Colors.red[700]),
// // // // //                 ),
// // // // //               ],
// // // // //             ),
// // // // //           ],
// // // // //         ),
// // // // //         trailing: Column(
// // // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // // //           children: [
// // // // //             Text(
// // // // //               _formatCurrency(invoice['totalAmount']),
// // // // //               style: const TextStyle(
// // // // //                 fontWeight: FontWeight.bold,
// // // // //                 fontSize: 16,
// // // // //                 color: Color(0xFF2E7D32),
// // // // //               ),
// // // // //             ),
// // // // //             const SizedBox(height: 4),
// // // // //             Text(
// // // // //               'إجمالي',
// // // // //               style: TextStyle(fontSize: 12, color: Colors.grey[600]),
// // // // //             ),
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   double _calculateTotalInvoices() {
// // // // //     double total = 0;
// // // // //     for (var invoice in _invoices) {
// // // // //       total += invoice['totalAmount'];
// // // // //     }
// // // // //     return total;
// // // // //   }
// // // // // }

// // // // // class TableCellHeader extends StatelessWidget {
// // // // //   final String text;
// // // // //   const TableCellHeader(this.text, {super.key});

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Container(
// // // // //       height: 50,
// // // // //       alignment: Alignment.center,
// // // // //       padding: const EdgeInsets.symmetric(horizontal: 8),
// // // // //       child: Text(
// // // // //         text,
// // // // //         style: const TextStyle(
// // // // //           fontWeight: FontWeight.bold,
// // // // //           fontSize: 14,
// // // // //           color: Color(0xFF2C3E50),
// // // // //         ),
// // // // //         textAlign: TextAlign.center,
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // // class TableCellBody extends StatelessWidget {
// // // // //   final String text;
// // // // //   final TextStyle? textStyle;
// // // // //   const TableCellBody(this.text, {this.textStyle, super.key});

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Container(
// // // // //       height: 48,
// // // // //       alignment: Alignment.center,
// // // // //       padding: const EdgeInsets.symmetric(horizontal: 8),
// // // // //       child: Text(
// // // // //         text,
// // // // //         maxLines: 2,
// // // // //         overflow: TextOverflow.ellipsis,
// // // // //         textAlign: TextAlign.center,
// // // // //         style: textStyle ?? const TextStyle(fontSize: 14),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }
// // // // import 'dart:async';
// // // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:intl/intl.dart';

// // // // class CompanyWorkPage extends StatefulWidget {
// // // //   const CompanyWorkPage({super.key});

// // // //   @override
// // // //   State<CompanyWorkPage> createState() => _CompanyWorkPageState();
// // // // }

// // // // class _CompanyWorkPageState extends State<CompanyWorkPage> {
// // // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// // // //   // متغيرات عامة
// // // //   int _currentSection = 0; // 0: شغل الشركات، 1: إنشاء فاتورة، 2: الفواتير
// // // //   List<Map<String, dynamic>> _allCompanies = [];
// // // //   List<Map<String, dynamic>> _filteredCompanies = [];
// // // //   String? _selectedCompany;
// // // //   List<Map<String, dynamic>> _companyWork = [];
// // // //   bool _isLoading = false;
// // // //   String _searchQuery = '';

// // // //   // متغيرات قسم إنشاء الفاتورة
// // // //   final List<Map<String, dynamic>> _selectedTripsForInvoice = [];
// // // //   final TextEditingController _invoiceNameController = TextEditingController();
// // // //   bool _isCreatingInvoice = false;

// // // //   // متغيرات قسم الفواتير
// // // //   List<Map<String, dynamic>> _invoices = [];

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _loadCompanies();
// // // //     _loadInvoices();
// // // //   }

// // // //   // ================================
// // // //   // تحميل بيانات الشركات
// // // //   // ================================
// // // //   Future<void> _loadCompanies() async {
// // // //     setState(() => _isLoading = true);
// // // //     try {
// // // //       final companiesSnapshot = await _firestore.collection('companies').get();
// // // //       final dailyWorkSnapshot = await _firestore.collection('dailyWork').get();

// // // //       final List<Map<String, dynamic>> companiesList = [];

// // // //       for (final companyDoc in companiesSnapshot.docs) {
// // // //         final companyData = companyDoc.data();
// // // //         final companyId = companyDoc.id;
// // // //         final companyName =
// // // //             (companyData['name'] ??
// // // //                     companyData['companyName'] ??
// // // //                     'شركة غير معروفة')
// // // //                 .toString()
// // // //                 .trim();

// // // //         final companyTrips = dailyWorkSnapshot.docs
// // // //             .where((doc) {
// // // //               final data = doc.data();
// // // //               final tripCompanyId = data['companyId'] ?? '';
// // // //               return tripCompanyId == companyId;
// // // //             })
// // // //             .map((doc) {
// // // //               final data = doc.data();
// // // //               final tripDate = (data['date'] as Timestamp?)?.toDate();

// // // //               return {
// // // //                 'id': doc.id,
// // // //                 'date': tripDate,
// // // //                 'companyName': companyName,
// // // //                 'companyId': companyId,
// // // //                 'driverName': data['driverName'] ?? 'غير معروف',
// // // //                 'nolon': (data['noLon'] ?? data['nolon'] ?? 0).toDouble(),
// // // //                 'companyOvernight': (data['companyOvernight'] ?? 0).toDouble(),
// // // //                 'companyHoliday': (data['companyHoliday'] ?? 0).toDouble(),
// // // //                 'selectedPrice': (data['selectedPrice'] ?? 0).toDouble(),
// // // //                 'karta': data['karta'] ?? '',
// // // //                 'ohda': data['ohda'] ?? '',
// // // //                 'selectedRoute': data['selectedRoute'] ?? '',
// // // //                 'loadingLocation': data['loadingLocation'] ?? '',
// // // //                 'unloadingLocation': data['unloadingLocation'] ?? '',
// // // //                 'vehicleType': data['selectedVehicleType'] ?? '',
// // // //                 'notes': data['selectedNotes'] ?? '',
// // // //               };
// // // //             })
// // // //             .toList();

// // // //         // ترتيب الرحلات من الأحدث إلى الأقدم
// // // //         companyTrips.sort(
// // // //           (a, b) => b['date']?.compareTo(a['date'] ?? DateTime.now()) ?? 0,
// // // //         );

// // // //         double totalNolon = 0.0;
// // // //         double totalOvernight = 0.0;
// // // //         double totalHoliday = 0.0;

// // // //         for (var trip in companyTrips) {
// // // //           totalNolon += trip['nolon'];
// // // //           totalOvernight += trip['companyOvernight'];
// // // //           totalHoliday += trip['companyHoliday'];
// // // //         }

// // // //         companiesList.add({
// // // //           'companyId': companyId,
// // // //           'companyName': companyName,
// // // //           'companyData': companyData,
// // // //           'allTrips': companyTrips,
// // // //           'hasTrips': companyTrips.isNotEmpty,
// // // //           'totalTrips': companyTrips.length,
// // // //           'totalNolon': totalNolon,
// // // //           'totalOvernight': totalOvernight,
// // // //           'totalHoliday': totalHoliday,
// // // //         });
// // // //       }

// // // //       // ترتيب الشركات حسب الأحدث (التي بها رحلات حديثة)
// // // //       companiesList.sort((a, b) {
// // // //         final aLatestTrip = a['allTrips'].isNotEmpty
// // // //             ? a['allTrips'].first['date']
// // // //             : DateTime(1900);
// // // //         final bLatestTrip = b['allTrips'].isNotEmpty
// // // //             ? b['allTrips'].first['date']
// // // //             : DateTime(1900);
// // // //         return bLatestTrip.compareTo(aLatestTrip);
// // // //       });

// // // //       setState(() {
// // // //         _allCompanies = companiesList;
// // // //         _filteredCompanies = _applySearchFilter(companiesList);
// // // //         _isLoading = false;
// // // //       });
// // // //     } catch (e) {
// // // //       setState(() => _isLoading = false);
// // // //       debugPrint('خطأ في تحميل بيانات الشركات: $e');
// // // //     }
// // // //   }

// // // //   // ================================
// // // //   // تحميل شغل شركة محددة
// // // //   // ================================
// // // //   Future<void> _loadCompanyWork(String companyName) async {
// // // //     setState(() {
// // // //       _selectedCompany = companyName;
// // // //       _isLoading = true;
// // // //       _companyWork.clear();
// // // //       _selectedTripsForInvoice.clear();
// // // //     });

// // // //     try {
// // // //       final company = _allCompanies.firstWhere(
// // // //         (c) => c['companyName'] == companyName,
// // // //         orElse: () => {},
// // // //       );

// // // //       if (company.isEmpty) {
// // // //         _showError('الشركة غير موجودة');
// // // //         return;
// // // //       }

// // // //       final companyTrips = company['allTrips'] as List<Map<String, dynamic>>;

// // // //       setState(() {
// // // //         _companyWork = companyTrips;
// // // //         _isLoading = false;
// // // //       });
// // // //     } catch (e) {
// // // //       setState(() => _isLoading = false);
// // // //       _showError('خطأ في تحميل شغل الشركة: $e');
// // // //     }
// // // //   }

// // // //   // ================================
// // // //   // تحميل الفواتير
// // // //   // ================================
// // // //   Future<void> _loadInvoices() async {
// // // //     try {
// // // //       final invoicesSnapshot = await _firestore
// // // //           .collection('invoices')
// // // //           .orderBy('createdAt', descending: true)
// // // //           .get();

// // // //       final List<Map<String, dynamic>> invoicesList = [];

// // // //       for (final doc in invoicesSnapshot.docs) {
// // // //         final data = doc.data();
// // // //         final tripIds = (data['tripIds'] as List<dynamic>? ?? []);

// // // //         // جلب تفاصيل الرحلات للفاتورة
// // // //         List<Map<String, dynamic>> invoiceTrips = [];
// // // //         double totalNolon = 0;
// // // //         double totalOvernight = 0;
// // // //         double totalHoliday = 0;

// // // //         if (tripIds.isNotEmpty) {
// // // //           for (var tripId in tripIds) {
// // // //             final tripDoc = await _firestore
// // // //                 .collection('dailyWork')
// // // //                 .doc(tripId.toString())
// // // //                 .get();
// // // //             if (tripDoc.exists) {
// // // //               final tripData = tripDoc.data() as Map<String, dynamic>;
// // // //               invoiceTrips.add({
// // // //                 'selectedRoute': tripData['selectedRoute'] ?? '',
// // // //                 'nolon': (tripData['noLon'] ?? tripData['nolon'] ?? 0)
// // // //                     .toDouble(),
// // // //                 'companyOvernight': (tripData['companyOvernight'] ?? 0)
// // // //                     .toDouble(),
// // // //                 'companyHoliday': (tripData['companyHoliday'] ?? 0).toDouble(),
// // // //               });

// // // //               totalNolon += (tripData['noLon'] ?? tripData['nolon'] ?? 0)
// // // //                   .toDouble();
// // // //               totalOvernight += (tripData['companyOvernight'] ?? 0).toDouble();
// // // //               totalHoliday += (tripData['companyHoliday'] ?? 0).toDouble();
// // // //             }
// // // //           }
// // // //         }

// // // //         invoicesList.add({
// // // //           'id': doc.id,
// // // //           'name': data['name'] ?? 'فاتورة بدون اسم',
// // // //           'companyName': data['companyName'] ?? 'شركة غير معروفة',
// // // //           'totalAmount': (data['totalAmount'] ?? 0).toDouble(),
// // // //           'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
// // // //           'tripIds': tripIds,
// // // //           'tripCount': tripIds.length,
// // // //           'invoiceTrips': invoiceTrips,
// // // //           'nolonTotal': totalNolon,
// // // //           'overnightTotal': totalOvernight,
// // // //           'holidayTotal': totalHoliday,
// // // //         });
// // // //       }

// // // //       setState(() {
// // // //         _invoices = invoicesList;
// // // //       });
// // // //     } catch (e) {
// // // //       debugPrint('خطأ في تحميل الفواتير: $e');
// // // //     }
// // // //   }

// // // //   // ================================
// // // //   // دوال التصفية والبحث
// // // //   // ================================
// // // //   List<Map<String, dynamic>> _applySearchFilter(
// // // //     List<Map<String, dynamic>> companies,
// // // //   ) {
// // // //     if (_searchQuery.isEmpty) return companies;
// // // //     return companies
// // // //         .where(
// // // //           (c) => c['companyName'].toLowerCase().contains(
// // // //             _searchQuery.toLowerCase(),
// // // //           ),
// // // //         )
// // // //         .toList();
// // // //   }

// // // //   // ================================
// // // //   // دوال قسم إنشاء الفاتورة
// // // //   // ================================
// // // //   void _toggleTripSelection(Map<String, dynamic> trip, bool selected) {
// // // //     setState(() {
// // // //       if (selected) {
// // // //         _selectedTripsForInvoice.add(trip);
// // // //       } else {
// // // //         _selectedTripsForInvoice.removeWhere((t) => t['id'] == trip['id']);
// // // //       }
// // // //     });
// // // //   }

// // // //   void _selectAllTrips(bool select) {
// // // //     setState(() {
// // // //       if (select) {
// // // //         _selectedTripsForInvoice.clear();
// // // //         _selectedTripsForInvoice.addAll(_companyWork);
// // // //       } else {
// // // //         _selectedTripsForInvoice.clear();
// // // //       }
// // // //     });
// // // //   }

// // // //   Future<void> _createInvoice() async {
// // // //     if (_selectedTripsForInvoice.isEmpty) {
// // // //       _showError('يرجى اختيار رحلات لإنشاء الفاتورة');
// // // //       return;
// // // //     }

// // // //     if (_invoiceNameController.text.isEmpty) {
// // // //       _showError('يرجى إدخال اسم الفاتورة');
// // // //       return;
// // // //     }

// // // //     setState(() => _isCreatingInvoice = true);

// // // //     try {
// // // //       // حساب إجمالي المبالغ
// // // //       double totalNolon = 0;
// // // //       double totalOvernight = 0;
// // // //       double totalHoliday = 0;
// // // //       List<String> tripIds = [];
// // // //       List<Map<String, dynamic>> invoiceTripDetails = [];

// // // //       for (var trip in _selectedTripsForInvoice) {
// // // //         totalNolon += trip['nolon'];
// // // //         totalOvernight += trip['companyOvernight'];
// // // //         totalHoliday += trip['companyHoliday'];
// // // //         tripIds.add(trip['id']);

// // // //         invoiceTripDetails.add({
// // // //           'selectedRoute': trip['selectedRoute'],
// // // //           'nolon': trip['nolon'],
// // // //           'companyOvernight': trip['companyOvernight'],
// // // //           'companyHoliday': trip['companyHoliday'],
// // // //         });
// // // //       }

// // // //       double totalAmount = totalNolon + totalOvernight + totalHoliday;

// // // //       // حفظ الفاتورة
// // // //       await _firestore.collection('invoices').add({
// // // //         'name': _invoiceNameController.text.trim(),
// // // //         'companyName': _selectedCompany!,
// // // //         'companyId': _companyWork.first['companyId'],
// // // //         'totalAmount': totalAmount,
// // // //         'nolonTotal': totalNolon,
// // // //         'overnightTotal': totalOvernight,
// // // //         'holidayTotal': totalHoliday,
// // // //         'tripIds': tripIds,
// // // //         'tripDetails': invoiceTripDetails,
// // // //         'tripCount': tripIds.length,
// // // //         'createdAt': Timestamp.now(),
// // // //         'status': 'غير مدفوعة',
// // // //       });

// // // //       // حذف الرحلات المختارة من dailyWork
// // // //       final batch = _firestore.batch();
// // // //       for (var tripId in tripIds) {
// // // //         batch.delete(_firestore.collection('dailyWork').doc(tripId));
// // // //       }
// // // //       await batch.commit();

// // // //       // تحديث البيانات المحلية
// // // //       _companyWork.removeWhere((trip) => tripIds.contains(trip['id']));
// // // //       _selectedTripsForInvoice.clear();
// // // //       _invoiceNameController.clear();

// // // //       _showSuccess('تم إنشاء الفاتورة وحذف الرحلات المختارة بنجاح');
// // // //       await _loadCompanies(); // تحديث قائمة الشركات
// // // //       await _loadInvoices(); // تحديث قائمة الفواتير

// // // //       // الرجوع إلى قسم الفواتير
// // // //       _changeSection(2);
// // // //     } catch (e) {
// // // //       _showError('خطأ في إنشاء الفاتورة: $e');
// // // //     } finally {
// // // //       setState(() => _isCreatingInvoice = false);
// // // //     }
// // // //   }

// // // //   // ================================
// // // //   // دوال مساعدة
// // // //   // ================================
// // // //   void _showError(String message) {
// // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // //       SnackBar(content: Text(message), backgroundColor: Colors.red),
// // // //     );
// // // //   }

// // // //   void _showSuccess(String message) {
// // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // //       SnackBar(content: Text(message), backgroundColor: Colors.green),
// // // //     );
// // // //   }

// // // //   String _formatDate(DateTime? date) {
// // // //     if (date == null) return '-';
// // // //     return DateFormat('dd/MM/yyyy').format(date);
// // // //   }

// // // //   String _formatCurrency(double amount) {
// // // //     return '${amount.toStringAsFixed(2)} ج';
// // // //   }

// // // //   void _changeSection(int section) {
// // // //     setState(() {
// // // //       _currentSection = section;
// // // //       if (section == 0) {
// // // //         _selectedTripsForInvoice.clear();
// // // //         _invoiceNameController.clear();
// // // //       }
// // // //     });
// // // //   }

// // // //   // ================================
// // // //   // بناء الواجهة
// // // //   // ================================
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       backgroundColor: const Color(0xFFF4F6F8),
// // // //       body: Column(
// // // //         children: [
// // // //           _buildCustomAppBar(),
// // // //           _buildSectionTabs(),
// // // //           if (_currentSection == 0 && _selectedCompany == null)
// // // //             _buildSearchBar(),
// // // //           Expanded(
// // // //             child: _currentSection == 0
// // // //                 ? (_selectedCompany == null
// // // //                       ? _buildCompanyList()
// // // //                       : _buildWorkTable())
// // // //                 : _currentSection == 1
// // // //                 ? _buildCreateInvoiceSection()
// // // //                 : _buildInvoicesSection(),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _buildCustomAppBar() {
// // // //     return Container(
// // // //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// // // //       decoration: const BoxDecoration(
// // // //         gradient: LinearGradient(
// // // //           begin: Alignment.centerRight,
// // // //           end: Alignment.centerLeft,
// // // //           colors: [Color(0xFF1B4F72), Color(0xFF3498DB)],
// // // //         ),
// // // //         boxShadow: [
// // // //           BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
// // // //         ],
// // // //       ),
// // // //       child: SafeArea(
// // // //         child: Row(
// // // //           children: [
// // // //             const Icon(Icons.business, color: Colors.white, size: 28),
// // // //             const SizedBox(width: 8),
// // // //             Expanded(
// // // //               child: Center(
// // // //                 child: Text(
// // // //                   _selectedCompany == null
// // // //                       ? _getSectionTitle()
// // // //                       : 'شغل شركة $_selectedCompany',
// // // //                   style: const TextStyle(
// // // //                     color: Colors.white,
// // // //                     fontSize: 20,
// // // //                     fontWeight: FontWeight.bold,
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //             if (_selectedCompany != null)
// // // //               IconButton(
// // // //                 icon: const Icon(Icons.arrow_back, color: Colors.white),
// // // //                 onPressed: () {
// // // //                   setState(() {
// // // //                     _selectedCompany = null;
// // // //                     _companyWork.clear();
// // // //                     _selectedTripsForInvoice.clear();
// // // //                     _invoiceNameController.clear();
// // // //                   });
// // // //                 },
// // // //               ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   String _getSectionTitle() {
// // // //     switch (_currentSection) {
// // // //       case 0:
// // // //         return 'شغل الشركات';
// // // //       case 1:
// // // //         return 'إنشاء فاتورة';
// // // //       case 2:
// // // //         return 'الفواتير';
// // // //       default:
// // // //         return 'شغل الشركات';
// // // //     }
// // // //   }

// // // //   Widget _buildSectionTabs() {
// // // //     return Container(
// // // //       color: Colors.white,
// // // //       child: Row(
// // // //         children: [
// // // //           _buildSectionTab(0, Icons.business, 'شغل الشركات'),
// // // //           _buildSectionTab(1, Icons.receipt, 'إنشاء فاتورة'),
// // // //           _buildSectionTab(2, Icons.list_alt, 'الفواتير'),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _buildSectionTab(int section, IconData icon, String title) {
// // // //     final isActive = _currentSection == section;
// // // //     return Expanded(
// // // //       child: InkWell(
// // // //         onTap: () => _changeSection(section),
// // // //         child: Container(
// // // //           padding: const EdgeInsets.symmetric(vertical: 12),
// // // //           decoration: BoxDecoration(
// // // //             color: isActive ? const Color(0xFF3498DB) : Colors.white,
// // // //             border: Border(
// // // //               bottom: BorderSide(
// // // //                 color: isActive ? const Color(0xFF3498DB) : Colors.grey[300]!,
// // // //                 width: 3,
// // // //               ),
// // // //             ),
// // // //           ),
// // // //           child: Column(
// // // //             children: [
// // // //               Icon(
// // // //                 icon,
// // // //                 color: isActive ? Colors.white : Colors.grey,
// // // //                 size: 22,
// // // //               ),
// // // //               const SizedBox(height: 4),
// // // //               Text(
// // // //                 title,
// // // //                 style: TextStyle(
// // // //                   color: isActive ? Colors.white : Colors.grey,
// // // //                   fontSize: 12,
// // // //                   fontWeight: FontWeight.bold,
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _buildSearchBar() {
// // // //     return Container(
// // // //       padding: const EdgeInsets.all(12),
// // // //       color: Colors.white,
// // // //       child: Container(
// // // //         padding: const EdgeInsets.symmetric(horizontal: 12),
// // // //         decoration: BoxDecoration(
// // // //           color: const Color(0xFFF4F6F8),
// // // //           borderRadius: BorderRadius.circular(12),
// // // //           border: Border.all(color: const Color(0xFF3498DB)),
// // // //         ),
// // // //         child: Row(
// // // //           children: [
// // // //             const Icon(Icons.search, color: Color(0xFF3498DB), size: 20),
// // // //             const SizedBox(width: 8),
// // // //             Expanded(
// // // //               child: TextField(
// // // //                 onChanged: (value) {
// // // //                   setState(() {
// // // //                     _searchQuery = value;
// // // //                     _filteredCompanies = _applySearchFilter(_allCompanies);
// // // //                   });
// // // //                 },
// // // //                 decoration: const InputDecoration(
// // // //                   hintText: 'ابحث عن شركة...',
// // // //                   border: InputBorder.none,
// // // //                   hintStyle: TextStyle(color: Colors.grey),
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //             if (_searchQuery.isNotEmpty)
// // // //               GestureDetector(
// // // //                 onTap: () {
// // // //                   setState(() {
// // // //                     _searchQuery = '';
// // // //                     _filteredCompanies = _applySearchFilter(_allCompanies);
// // // //                   });
// // // //                 },
// // // //                 child: const Icon(Icons.clear, size: 18, color: Colors.grey),
// // // //               ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _buildCompanyList() {
// // // //     if (_isLoading) return const Center(child: CircularProgressIndicator());

// // // //     final companiesWithTrips = _filteredCompanies
// // // //         .where((c) => c['hasTrips'])
// // // //         .toList();
// // // //     final companiesWithoutTrips = _filteredCompanies
// // // //         .where((c) => !c['hasTrips'])
// // // //         .toList();

// // // //     return ListView(
// // // //       padding: const EdgeInsets.all(8),
// // // //       children: [
// // // //         ...companiesWithTrips.map((company) => _buildCompanyCard(company)),
// // // //         if (companiesWithTrips.isEmpty && companiesWithoutTrips.isNotEmpty)
// // // //           Container(
// // // //             margin: const EdgeInsets.all(16),
// // // //             padding: const EdgeInsets.all(20),
// // // //             decoration: BoxDecoration(
// // // //               color: Colors.white,
// // // //               borderRadius: BorderRadius.circular(12),
// // // //               border: Border.all(color: Colors.grey[300]!),
// // // //             ),
// // // //             child: Column(
// // // //               children: [
// // // //                 Icon(Icons.business, size: 60, color: Colors.grey[400]),
// // // //                 const SizedBox(height: 16),
// // // //                 const Text(
// // // //                   'لا توجد شركات لديها رحلات',
// // // //                   style: TextStyle(
// // // //                     fontSize: 16,
// // // //                     color: Colors.grey,
// // // //                     fontWeight: FontWeight.bold,
// // // //                   ),
// // // //                   textAlign: TextAlign.center,
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //       ],
// // // //     );
// // // //   }

// // // //   Widget _buildCompanyCard(Map<String, dynamic> company) {
// // // //     final companyName = company['companyName'];
// // // //     final totalTrips = company['totalTrips'];
// // // //     final hasTrips = company['hasTrips'];
// // // //     final totalNolon = company['totalNolon'] ?? 0;

// // // //     return Container(
// // // //       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
// // // //       decoration: BoxDecoration(
// // // //         color: Colors.white,
// // // //         borderRadius: BorderRadius.circular(12),
// // // //         border: Border.all(
// // // //           color: hasTrips
// // // //               ? const Color(0xFF3498DB).withOpacity(0.3)
// // // //               : Colors.grey.withOpacity(0.3),
// // // //         ),
// // // //         boxShadow: [
// // // //           BoxShadow(
// // // //             color: Colors.black.withOpacity(0.05),
// // // //             blurRadius: 8,
// // // //             offset: const Offset(0, 2),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //       child: ListTile(
// // // //         leading: Container(
// // // //           width: 45,
// // // //           height: 45,
// // // //           decoration: BoxDecoration(
// // // //             color: hasTrips ? const Color(0xFF3498DB) : Colors.grey,
// // // //             borderRadius: BorderRadius.circular(22.5),
// // // //           ),
// // // //           child: Center(
// // // //             child: Text(
// // // //               totalTrips.toString(),
// // // //               style: const TextStyle(
// // // //                 color: Colors.white,
// // // //                 fontWeight: FontWeight.bold,
// // // //                 fontSize: 16,
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ),
// // // //         title: Text(
// // // //           companyName,
// // // //           style: TextStyle(
// // // //             fontWeight: FontWeight.bold,
// // // //             fontSize: 16,
// // // //             color: hasTrips ? const Color(0xFF2C3E50) : Colors.grey,
// // // //           ),
// // // //         ),
// // // //         subtitle: Column(
// // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // //           children: [
// // // //             Text(
// // // //               hasTrips
// // // //                   ? '$totalTrips رحلة - ${_formatCurrency(totalNolon)}'
// // // //                   : 'لا توجد رحلات',
// // // //               style: TextStyle(
// // // //                 color: hasTrips ? Colors.green : Colors.grey,
// // // //                 fontSize: 12,
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //         trailing: Icon(
// // // //           Icons.arrow_forward_ios,
// // // //           color: hasTrips ? const Color(0xFF3498DB) : Colors.grey,
// // // //           size: 16,
// // // //         ),
// // // //         onTap: hasTrips ? () => _loadCompanyWork(companyName) : null,
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _buildWorkTable() {
// // // //     if (_isLoading) return const Center(child: CircularProgressIndicator());

// // // //     return Column(
// // // //       children: [
// // // //         Padding(
// // // //           padding: const EdgeInsets.all(12),
// // // //           child: Row(
// // // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //             children: [
// // // //               ElevatedButton.icon(
// // // //                 onPressed: () => _changeSection(1),
// // // //                 icon: const Icon(Icons.receipt),
// // // //                 label: const Text('إنشاء فاتورة من هذه الرحلات'),
// // // //                 style: ElevatedButton.styleFrom(
// // // //                   backgroundColor: const Color(0xFF2E7D32),
// // // //                   foregroundColor: Colors.white,
// // // //                 ),
// // // //               ),
// // // //               Text(
// // // //                 '${_companyWork.length} رحلة',
// // // //                 style: const TextStyle(
// // // //                   fontWeight: FontWeight.bold,
// // // //                   color: Color(0xFF3498DB),
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //         Expanded(
// // // //           child: Container(
// // // //             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // // //             decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
// // // //             child: _companyWork.isEmpty
// // // //                 ? Center(
// // // //                     child: Column(
// // // //                       mainAxisAlignment: MainAxisAlignment.center,
// // // //                       children: [
// // // //                         const Icon(
// // // //                           Icons.business,
// // // //                           size: 60,
// // // //                           color: Colors.grey,
// // // //                         ),
// // // //                         const SizedBox(height: 16),
// // // //                         const Text(
// // // //                           'لا يوجد شغل مسجل لهذه الشركة',
// // // //                           style: TextStyle(
// // // //                             color: Colors.grey,
// // // //                             fontSize: 18,
// // // //                             fontWeight: FontWeight.bold,
// // // //                           ),
// // // //                         ),
// // // //                         const SizedBox(height: 20),
// // // //                         ElevatedButton.icon(
// // // //                           onPressed: () {
// // // //                             setState(() => _selectedCompany = null);
// // // //                           },
// // // //                           icon: const Icon(Icons.arrow_back),
// // // //                           label: const Text('العودة للشركات'),
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                   )
// // // //                 : SingleChildScrollView(
// // // //                     scrollDirection: Axis.horizontal,
// // // //                     child: SingleChildScrollView(
// // // //                       scrollDirection: Axis.vertical,
// // // //                       child: Table(
// // // //                         defaultColumnWidth: const FixedColumnWidth(110),
// // // //                         border: TableBorder.all(
// // // //                           color: const Color(0xFF3498DB),
// // // //                           width: 1,
// // // //                         ),
// // // //                         children: [
// // // //                           TableRow(
// // // //                             decoration: BoxDecoration(
// // // //                               color: const Color(0xFF3498DB).withOpacity(0.15),
// // // //                             ),
// // // //                             children: const [
// // // //                               TableCellHeader('عطلة الشركة'),
// // // //                               TableCellHeader('مبيت الشركة'),
// // // //                               TableCellHeader('نولون الشركة'),
// // // //                               TableCellHeader('اسم السائق'),
// // // //                               TableCellHeader('الكارتة'),
// // // //                               TableCellHeader('العهدة'),
// // // //                               TableCellHeader('اسم الموقع'),
// // // //                               TableCellHeader('مكان التعتيق'),
// // // //                               TableCellHeader('مكان التحميل'),
// // // //                               TableCellHeader('التاريخ'),
// // // //                               TableCellHeader('م'),
// // // //                             ],
// // // //                           ),
// // // //                           ..._companyWork.asMap().entries.map((entry) {
// // // //                             final index = entry.key;
// // // //                             final work = entry.value;

// // // //                             return TableRow(
// // // //                               decoration: BoxDecoration(
// // // //                                 color: index.isEven
// // // //                                     ? Colors.white
// // // //                                     : const Color(0xFFF8F9FA),
// // // //                               ),
// // // //                               children: [
// // // //                                 TableCellBody(
// // // //                                   '${work['companyHoliday']} ج',
// // // //                                   textStyle: const TextStyle(
// // // //                                     fontWeight: FontWeight.bold,
// // // //                                     color: Colors.red,
// // // //                                   ),
// // // //                                 ),
// // // //                                 TableCellBody(
// // // //                                   '${work['companyOvernight']} ج',
// // // //                                   textStyle: TextStyle(
// // // //                                     fontWeight: FontWeight.bold,
// // // //                                     color: Colors.orange[700],
// // // //                                   ),
// // // //                                 ),
// // // //                                 TableCellBody(
// // // //                                   '${work['nolon']} ج',
// // // //                                   textStyle: const TextStyle(
// // // //                                     fontWeight: FontWeight.bold,
// // // //                                     color: Colors.green,
// // // //                                   ),
// // // //                                 ),
// // // //                                 TableCellBody(
// // // //                                   work['driverName'],
// // // //                                   textStyle: const TextStyle(
// // // //                                     fontWeight: FontWeight.bold,
// // // //                                     color: Color(0xFF2C3E50),
// // // //                                   ),
// // // //                                 ),
// // // //                                 TableCellBody(work['karta']),
// // // //                                 TableCellBody(work['ohda']),
// // // //                                 TableCellBody(
// // // //                                   work['selectedRoute'],
// // // //                                   textStyle: const TextStyle(
// // // //                                     fontWeight: FontWeight.bold,
// // // //                                     color: Color(0xFF3498DB),
// // // //                                   ),
// // // //                                 ),
// // // //                                 TableCellBody(work['unloadingLocation']),
// // // //                                 TableCellBody(work['loadingLocation']),
// // // //                                 TableCellBody(_formatDate(work['date'])),
// // // //                                 TableCellBody('${index + 1}'),
// // // //                               ],
// // // //                             );
// // // //                           }).toList(),
// // // //                         ],
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //           ),
// // // //         ),
// // // //       ],
// // // //     );
// // // //   }

// // // //   Widget _buildCreateInvoiceSection() {
// // // //     return _selectedCompany == null
// // // //         ? Center(
// // // //             child: Column(
// // // //               mainAxisAlignment: MainAxisAlignment.center,
// // // //               children: [
// // // //                 const Icon(Icons.business, size: 80, color: Colors.grey),
// // // //                 const SizedBox(height: 20),
// // // //                 const Text(
// // // //                   'يرجى اختيار شركة أولاً',
// // // //                   style: TextStyle(
// // // //                     fontSize: 18,
// // // //                     color: Colors.grey,
// // // //                     fontWeight: FontWeight.bold,
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(height: 10),
// // // //                 const Text(
// // // //                   'اذهب إلى قسم "شغل الشركات" واختر شركة',
// // // //                   style: TextStyle(color: Colors.grey),
// // // //                   textAlign: TextAlign.center,
// // // //                 ),
// // // //                 const SizedBox(height: 30),
// // // //                 ElevatedButton.icon(
// // // //                   onPressed: () => _changeSection(0),
// // // //                   icon: const Icon(Icons.business),
// // // //                   label: const Text('الذهاب إلى شغل الشركات'),
// // // //                   style: ElevatedButton.styleFrom(
// // // //                     backgroundColor: const Color(0xFF3498DB),
// // // //                     foregroundColor: Colors.white,
// // // //                     padding: const EdgeInsets.symmetric(
// // // //                       horizontal: 20,
// // // //                       vertical: 12,
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           )
// // // //         : Column(
// // // //             children: [
// // // //               // إحصائيات الرحلات المختارة
// // // //               Container(
// // // //                 padding: const EdgeInsets.all(16),
// // // //                 color: Colors.blue[50],
// // // //                 child: Row(
// // // //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //                   children: [
// // // //                     Column(
// // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // //                       children: [
// // // //                         const Text(
// // // //                           'الرحلات المختارة',
// // // //                           style: TextStyle(
// // // //                             fontWeight: FontWeight.bold,
// // // //                             color: Color(0xFF3498DB),
// // // //                           ),
// // // //                         ),
// // // //                         Text(
// // // //                           '${_selectedTripsForInvoice.length} من ${_companyWork.length} رحلة',
// // // //                           style: const TextStyle(
// // // //                             fontSize: 18,
// // // //                             fontWeight: FontWeight.bold,
// // // //                             color: Color(0xFF2E7D32),
// // // //                           ),
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                     Column(
// // // //                       crossAxisAlignment: CrossAxisAlignment.end,
// // // //                       children: [
// // // //                         const Text(
// // // //                           'إجمالي الفاتورة',
// // // //                           style: TextStyle(
// // // //                             fontWeight: FontWeight.bold,
// // // //                             color: Color(0xFF3498DB),
// // // //                           ),
// // // //                         ),
// // // //                         Text(
// // // //                           _formatCurrency(_calculateInvoiceTotal()),
// // // //                           style: const TextStyle(
// // // //                             fontSize: 18,
// // // //                             fontWeight: FontWeight.bold,
// // // //                             color: Color(0xFF2E7D32),
// // // //                           ),
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //               ),

// // // //               // اسم الفاتورة
// // // //               Padding(
// // // //                 padding: const EdgeInsets.all(16),
// // // //                 child: TextField(
// // // //                   controller: _invoiceNameController,
// // // //                   decoration: InputDecoration(
// // // //                     labelText: 'اسم الفاتورة',
// // // //                     prefixIcon: const Icon(Icons.receipt),
// // // //                     border: OutlineInputBorder(
// // // //                       borderRadius: BorderRadius.circular(12),
// // // //                     ),
// // // //                     filled: true,
// // // //                     fillColor: Colors.white,
// // // //                   ),
// // // //                 ),
// // // //               ),

// // // //               // أزرار التحكم
// // // //               Padding(
// // // //                 padding: const EdgeInsets.symmetric(horizontal: 16),
// // // //                 child: Row(
// // // //                   children: [
// // // //                     Expanded(
// // // //                       child: ElevatedButton.icon(
// // // //                         onPressed: () => _selectAllTrips(true),
// // // //                         icon: const Icon(Icons.check_box),
// // // //                         label: const Text('تحديد الكل'),
// // // //                         style: ElevatedButton.styleFrom(
// // // //                           backgroundColor: Colors.green[50],
// // // //                           foregroundColor: Colors.green[700],
// // // //                         ),
// // // //                       ),
// // // //                     ),
// // // //                     const SizedBox(width: 8),
// // // //                     Expanded(
// // // //                       child: ElevatedButton.icon(
// // // //                         onPressed: () => _selectAllTrips(false),
// // // //                         icon: const Icon(Icons.check_box_outline_blank),
// // // //                         label: const Text('إلغاء الكل'),
// // // //                         style: ElevatedButton.styleFrom(
// // // //                           backgroundColor: Colors.red[50],
// // // //                           foregroundColor: Colors.red[700],
// // // //                         ),
// // // //                       ),
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //               ),

// // // //               // تفاصيل المبالغ المختارة
// // // //               if (_selectedTripsForInvoice.isNotEmpty)
// // // //                 Container(
// // // //                   padding: const EdgeInsets.all(12),
// // // //                   margin: const EdgeInsets.symmetric(
// // // //                     horizontal: 16,
// // // //                     vertical: 8,
// // // //                   ),
// // // //                   decoration: BoxDecoration(
// // // //                     color: Colors.green[50],
// // // //                     borderRadius: BorderRadius.circular(8),
// // // //                     border: Border.all(color: Colors.green[300]!),
// // // //                   ),
// // // //                   child: Column(
// // // //                     crossAxisAlignment: CrossAxisAlignment.start,
// // // //                     children: [
// // // //                       const Text(
// // // //                         'تفاصيل الفاتورة:',
// // // //                         style: TextStyle(
// // // //                           fontWeight: FontWeight.bold,
// // // //                           color: Color(0xFF2E7D32),
// // // //                         ),
// // // //                       ),
// // // //                       const SizedBox(height: 8),
// // // //                       Row(
// // // //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //                         children: [
// // // //                           Column(
// // // //                             crossAxisAlignment: CrossAxisAlignment.start,
// // // //                             children: [
// // // //                               Text(
// // // //                                 'إجمالي النولون: ${_formatCurrency(_calculateNolonTotal())}',
// // // //                                 style: const TextStyle(color: Colors.green),
// // // //                               ),
// // // //                               Text(
// // // //                                 'إجمالي المبيت: ${_formatCurrency(_calculateOvernightTotal())}',
// // // //                                 style: const TextStyle(color: Colors.orange),
// // // //                               ),
// // // //                               Text(
// // // //                                 'إجمالي العطلة: ${_formatCurrency(_calculateHolidayTotal())}',
// // // //                                 style: const TextStyle(color: Colors.red),
// // // //                               ),
// // // //                             ],
// // // //                           ),
// // // //                           Column(
// // // //                             crossAxisAlignment: CrossAxisAlignment.end,
// // // //                             children: [
// // // //                               Text(
// // // //                                 'عدد الرحلات: ${_selectedTripsForInvoice.length}',
// // // //                                 style: const TextStyle(
// // // //                                   fontWeight: FontWeight.bold,
// // // //                                   color: Color(0xFF3498DB),
// // // //                                 ),
// // // //                               ),
// // // //                               Text(
// // // //                                 'الإجمالي الكلي: ${_formatCurrency(_calculateInvoiceTotal())}',
// // // //                                 style: const TextStyle(
// // // //                                   fontWeight: FontWeight.bold,
// // // //                                   fontSize: 16,
// // // //                                   color: Color(0xFF2E7D32),
// // // //                                 ),
// // // //                               ),
// // // //                             ],
// // // //                           ),
// // // //                         ],
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 ),

// // // //               // جدول الرحلات مع خيار التحديد
// // // //               Expanded(
// // // //                 child: Container(
// // // //                   margin: const EdgeInsets.all(16),
// // // //                   decoration: BoxDecoration(
// // // //                     borderRadius: BorderRadius.circular(12),
// // // //                   ),
// // // //                   child: _companyWork.isEmpty
// // // //                       ? Center(
// // // //                           child: Column(
// // // //                             mainAxisAlignment: MainAxisAlignment.center,
// // // //                             children: [
// // // //                               const Icon(
// // // //                                 Icons.list,
// // // //                                 size: 60,
// // // //                                 color: Colors.grey,
// // // //                               ),
// // // //                               const SizedBox(height: 16),
// // // //                               const Text(
// // // //                                 'لا توجد رحلات',
// // // //                                 style: TextStyle(
// // // //                                   color: Colors.grey,
// // // //                                   fontSize: 18,
// // // //                                 ),
// // // //                               ),
// // // //                             ],
// // // //                           ),
// // // //                         )
// // // //                       : SingleChildScrollView(
// // // //                           scrollDirection: Axis.horizontal,
// // // //                           child: SingleChildScrollView(
// // // //                             scrollDirection: Axis.vertical,
// // // //                             child: Table(
// // // //                               defaultColumnWidth: const FixedColumnWidth(110),
// // // //                               border: TableBorder.all(
// // // //                                 color: const Color(0xFF3498DB),
// // // //                                 width: 1,
// // // //                               ),
// // // //                               children: [
// // // //                                 TableRow(
// // // //                                   decoration: BoxDecoration(
// // // //                                     color: const Color(
// // // //                                       0xFF3498DB,
// // // //                                     ).withOpacity(0.15),
// // // //                                   ),
// // // //                                   children: [
// // // //                                     const TableCellHeader('تحديد'),
// // // //                                     const TableCellHeader('عطلة الشركة'),
// // // //                                     const TableCellHeader('مبيت الشركة'),
// // // //                                     const TableCellHeader('نولون الشركة'),
// // // //                                     const TableCellHeader('اسم السائق'),
// // // //                                     const TableCellHeader('الكارتة'),
// // // //                                     const TableCellHeader('العهدة'),
// // // //                                     const TableCellHeader('اسم الموقع'),
// // // //                                     const TableCellHeader('مكان التعتيق'),
// // // //                                     const TableCellHeader('مكان التحميل'),
// // // //                                     const TableCellHeader('التاريخ'),
// // // //                                     const TableCellHeader('م'),
// // // //                                   ],
// // // //                                 ),
// // // //                                 ..._companyWork.asMap().entries.map((entry) {
// // // //                                   final index = entry.key;
// // // //                                   final work = entry.value;
// // // //                                   final isSelected = _selectedTripsForInvoice
// // // //                                       .any((trip) => trip['id'] == work['id']);

// // // //                                   return TableRow(
// // // //                                     decoration: BoxDecoration(
// // // //                                       color: isSelected
// // // //                                           ? const Color(0xFFE8F5E9)
// // // //                                           : index.isEven
// // // //                                           ? Colors.white
// // // //                                           : const Color(0xFFF8F9FA),
// // // //                                     ),
// // // //                                     children: [
// // // //                                       TableCell(
// // // //                                         child: Container(
// // // //                                           height: 48,
// // // //                                           alignment: Alignment.center,
// // // //                                           child: Checkbox(
// // // //                                             value: isSelected,
// // // //                                             onChanged: (value) {
// // // //                                               _toggleTripSelection(
// // // //                                                 work,
// // // //                                                 value ?? false,
// // // //                                               );
// // // //                                             },
// // // //                                           ),
// // // //                                         ),
// // // //                                       ),
// // // //                                       TableCellBody(
// // // //                                         '${work['companyHoliday']} ج',
// // // //                                         textStyle: const TextStyle(
// // // //                                           fontWeight: FontWeight.bold,
// // // //                                           color: Colors.red,
// // // //                                         ),
// // // //                                       ),
// // // //                                       TableCellBody(
// // // //                                         '${work['companyOvernight']} ج',
// // // //                                         textStyle: TextStyle(
// // // //                                           fontWeight: FontWeight.bold,
// // // //                                           color: Colors.orange[700],
// // // //                                         ),
// // // //                                       ),
// // // //                                       TableCellBody(
// // // //                                         '${work['nolon']} ج',
// // // //                                         textStyle: const TextStyle(
// // // //                                           fontWeight: FontWeight.bold,
// // // //                                           color: Colors.green,
// // // //                                         ),
// // // //                                       ),
// // // //                                       TableCellBody(
// // // //                                         work['driverName'],
// // // //                                         textStyle: const TextStyle(
// // // //                                           fontWeight: FontWeight.bold,
// // // //                                           color: Color(0xFF2C3E50),
// // // //                                         ),
// // // //                                       ),
// // // //                                       TableCellBody(work['karta']),
// // // //                                       TableCellBody(work['ohda']),
// // // //                                       TableCellBody(
// // // //                                         work['selectedRoute'],
// // // //                                         textStyle: const TextStyle(
// // // //                                           fontWeight: FontWeight.bold,
// // // //                                           color: Color(0xFF3498DB),
// // // //                                         ),
// // // //                                       ),
// // // //                                       TableCellBody(work['unloadingLocation']),
// // // //                                       TableCellBody(work['loadingLocation']),
// // // //                                       TableCellBody(_formatDate(work['date'])),
// // // //                                       TableCellBody('${index + 1}'),
// // // //                                     ],
// // // //                                   );
// // // //                                 }).toList(),
// // // //                               ],
// // // //                             ),
// // // //                           ),
// // // //                         ),
// // // //                 ),
// // // //               ),

// // // //               // زر إنشاء الفاتورة
// // // //               Padding(
// // // //                 padding: const EdgeInsets.all(16),
// // // //                 child: SizedBox(
// // // //                   width: double.infinity,
// // // //                   height: 50,
// // // //                   child: ElevatedButton.icon(
// // // //                     onPressed:
// // // //                         _selectedTripsForInvoice.isEmpty || _isCreatingInvoice
// // // //                         ? null
// // // //                         : _createInvoice,
// // // //                     icon: _isCreatingInvoice
// // // //                         ? const SizedBox(
// // // //                             width: 20,
// // // //                             height: 20,
// // // //                             child: CircularProgressIndicator(
// // // //                               color: Colors.white,
// // // //                             ),
// // // //                           )
// // // //                         : const Icon(Icons.save),
// // // //                     label: Text(
// // // //                       _isCreatingInvoice ? 'جاري الإنشاء...' : 'إنشاء الفاتورة',
// // // //                       style: const TextStyle(fontSize: 16),
// // // //                     ),
// // // //                     style: ElevatedButton.styleFrom(
// // // //                       backgroundColor: const Color(0xFF2E7D32),
// // // //                       foregroundColor: Colors.white,
// // // //                       shape: RoundedRectangleBorder(
// // // //                         borderRadius: BorderRadius.circular(12),
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           );
// // // //   }

// // // //   double _calculateInvoiceTotal() {
// // // //     double total = 0;
// // // //     for (var trip in _selectedTripsForInvoice) {
// // // //       total +=
// // // //           trip['nolon'] + trip['companyOvernight'] + trip['companyHoliday'];
// // // //     }
// // // //     return total;
// // // //   }

// // // //   double _calculateNolonTotal() {
// // // //     double total = 0;
// // // //     for (var trip in _selectedTripsForInvoice) {
// // // //       total += trip['nolon'];
// // // //     }
// // // //     return total;
// // // //   }

// // // //   double _calculateOvernightTotal() {
// // // //     double total = 0;
// // // //     for (var trip in _selectedTripsForInvoice) {
// // // //       total += trip['companyOvernight'];
// // // //     }
// // // //     return total;
// // // //   }

// // // //   double _calculateHolidayTotal() {
// // // //     double total = 0;
// // // //     for (var trip in _selectedTripsForInvoice) {
// // // //       total += trip['companyHoliday'];
// // // //     }
// // // //     return total;
// // // //   }

// // // //   Widget _buildInvoicesSection() {
// // // //     return Column(
// // // //       children: [
// // // //         Container(
// // // //           padding: const EdgeInsets.all(16),
// // // //           color: Colors.blue[50],
// // // //           child: Row(
// // // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //             children: [
// // // //               const Text(
// // // //                 'إجمالي الفواتير',
// // // //                 style: TextStyle(
// // // //                   fontWeight: FontWeight.bold,
// // // //                   color: Color(0xFF3498DB),
// // // //                 ),
// // // //               ),
// // // //               Text(
// // // //                 _formatCurrency(_calculateTotalInvoices()),
// // // //                 style: const TextStyle(
// // // //                   fontSize: 20,
// // // //                   fontWeight: FontWeight.bold,
// // // //                   color: Color(0xFF2E7D32),
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //         Expanded(
// // // //           child: _invoices.isEmpty
// // // //               ? Center(
// // // //                   child: Column(
// // // //                     mainAxisAlignment: MainAxisAlignment.center,
// // // //                     children: [
// // // //                       const Icon(
// // // //                         Icons.receipt_long,
// // // //                         size: 80,
// // // //                         color: Colors.grey,
// // // //                       ),
// // // //                       const SizedBox(height: 20),
// // // //                       const Text(
// // // //                         'لا توجد فواتير',
// // // //                         style: TextStyle(
// // // //                           fontSize: 18,
// // // //                           color: Colors.grey,
// // // //                           fontWeight: FontWeight.bold,
// // // //                         ),
// // // //                       ),
// // // //                       const SizedBox(height: 10),
// // // //                       const Text(
// // // //                         'قم بإنشاء فاتورة أولاً',
// // // //                         style: TextStyle(color: Colors.grey),
// // // //                       ),
// // // //                       const SizedBox(height: 30),
// // // //                       ElevatedButton.icon(
// // // //                         onPressed: () => _changeSection(1),
// // // //                         icon: const Icon(Icons.add),
// // // //                         label: const Text('إنشاء فاتورة'),
// // // //                         style: ElevatedButton.styleFrom(
// // // //                           backgroundColor: const Color(0xFF3498DB),
// // // //                           foregroundColor: Colors.white,
// // // //                         ),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 )
// // // //               : ListView.builder(
// // // //                   padding: const EdgeInsets.all(8),
// // // //                   itemCount: _invoices.length,
// // // //                   itemBuilder: (context, index) {
// // // //                     final invoice = _invoices[index];
// // // //                     return _buildInvoiceCard(invoice, index);
// // // //                   },
// // // //                 ),
// // // //         ),
// // // //       ],
// // // //     );
// // // //   }

// // // //   Widget _buildInvoiceCard(Map<String, dynamic> invoice, int index) {
// // // //     final createdAt = invoice['createdAt'] as DateTime?;
// // // //     final invoiceTrips = invoice['invoiceTrips'] as List<Map<String, dynamic>>;

// // // //     return Container(
// // // //       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
// // // //       decoration: BoxDecoration(
// // // //         color: Colors.white,
// // // //         borderRadius: BorderRadius.circular(12),
// // // //         border: Border.all(color: Colors.grey[300]!),
// // // //         boxShadow: [
// // // //           BoxShadow(
// // // //             color: Colors.black.withOpacity(0.05),
// // // //             blurRadius: 6,
// // // //             offset: const Offset(0, 2),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //       child: ExpansionTile(
// // // //         leading: CircleAvatar(
// // // //           backgroundColor: const Color(0xFF3498DB),
// // // //           child: Text(
// // // //             '${index + 1}',
// // // //             style: const TextStyle(
// // // //               color: Colors.white,
// // // //               fontWeight: FontWeight.bold,
// // // //             ),
// // // //           ),
// // // //         ),
// // // //         title: Text(
// // // //           invoice['name'],
// // // //           style: const TextStyle(
// // // //             fontWeight: FontWeight.bold,
// // // //             fontSize: 16,
// // // //             color: Color(0xFF2C3E50),
// // // //           ),
// // // //         ),
// // // //         subtitle: Column(
// // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // //           children: [
// // // //             Text(
// // // //               invoice['companyName'],
// // // //               style: TextStyle(color: Colors.blue[700]),
// // // //             ),
// // // //             const SizedBox(height: 4),
// // // //             Text(
// // // //               '${invoice['tripCount']} رحلة - ${createdAt != null ? _formatDate(createdAt) : 'غير معروف'}',
// // // //               style: const TextStyle(fontSize: 12, color: Colors.grey),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //         trailing: Column(
// // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // //           children: [
// // // //             Text(
// // // //               _formatCurrency(invoice['totalAmount']),
// // // //               style: const TextStyle(
// // // //                 fontWeight: FontWeight.bold,
// // // //                 fontSize: 16,
// // // //                 color: Color(0xFF2E7D32),
// // // //               ),
// // // //             ),
// // // //             const SizedBox(height: 4),
// // // //             Text(
// // // //               'إجمالي',
// // // //               style: TextStyle(fontSize: 12, color: Colors.grey[600]),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //         children: [
// // // //           // تفاصيل الفاتورة
// // // //           Padding(
// // // //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // // //             child: Column(
// // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // //               children: [
// // // //                 // إحصائيات الفاتورة
// // // //                 Container(
// // // //                   padding: const EdgeInsets.all(12),
// // // //                   decoration: BoxDecoration(
// // // //                     color: Colors.blue[50],
// // // //                     borderRadius: BorderRadius.circular(8),
// // // //                   ),
// // // //                   child: Column(
// // // //                     children: [
// // // //                       Row(
// // // //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //                         children: [
// // // //                           const Text(
// // // //                             'عدد الرحلات:',
// // // //                             style: TextStyle(fontWeight: FontWeight.bold),
// // // //                           ),
// // // //                           Text(
// // // //                             '${invoice['tripCount']}',
// // // //                             style: const TextStyle(color: Color(0xFF3498DB)),
// // // //                           ),
// // // //                         ],
// // // //                       ),
// // // //                       const SizedBox(height: 4),
// // // //                       Row(
// // // //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //                         children: [
// // // //                           const Text(
// // // //                             'إجمالي النولون:',
// // // //                             style: TextStyle(
// // // //                               fontWeight: FontWeight.bold,
// // // //                               color: Colors.green,
// // // //                             ),
// // // //                           ),
// // // //                           Text(
// // // //                             _formatCurrency(invoice['nolonTotal']),
// // // //                             style: const TextStyle(color: Colors.green),
// // // //                           ),
// // // //                         ],
// // // //                       ),
// // // //                       const SizedBox(height: 4),
// // // //                       Row(
// // // //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //                         children: [
// // // //                           const Text(
// // // //                             'إجمالي المبيت:',
// // // //                             style: TextStyle(
// // // //                               fontWeight: FontWeight.bold,
// // // //                               color: Colors.orange,
// // // //                             ),
// // // //                           ),
// // // //                           Text(
// // // //                             _formatCurrency(invoice['overnightTotal']),
// // // //                             style: const TextStyle(color: Colors.orange),
// // // //                           ),
// // // //                         ],
// // // //                       ),
// // // //                       const SizedBox(height: 4),
// // // //                       Row(
// // // //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //                         children: [
// // // //                           const Text(
// // // //                             'إجمالي العطلة:',
// // // //                             style: TextStyle(
// // // //                               fontWeight: FontWeight.bold,
// // // //                               color: Colors.red,
// // // //                             ),
// // // //                           ),
// // // //                           Text(
// // // //                             _formatCurrency(invoice['holidayTotal']),
// // // //                             style: const TextStyle(color: Colors.red),
// // // //                           ),
// // // //                         ],
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 ),

// // // //                 const SizedBox(height: 12),

// // // //                 // تفاصيل الرحلات
// // // //                 const Text(
// // // //                   'تفاصيل الرحلات:',
// // // //                   style: TextStyle(
// // // //                     fontWeight: FontWeight.bold,
// // // //                     color: Color(0xFF2C3E50),
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(height: 8),

// // // //                 // جدول تفاصيل الرحلات
// // // //                 if (invoiceTrips.isNotEmpty)
// // // //                   SingleChildScrollView(
// // // //                     scrollDirection: Axis.horizontal,
// // // //                     child: Table(
// // // //                       defaultColumnWidth: const FixedColumnWidth(150),
// // // //                       border: TableBorder.all(
// // // //                         color: Colors.grey[300]!,
// // // //                         width: 1,
// // // //                       ),
// // // //                       children: [
// // // //                         TableRow(
// // // //                           decoration: BoxDecoration(color: Colors.grey[100]),
// // // //                           children: const [
// // // //                             TableCellHeader('اسم الموقع'),
// // // //                             TableCellHeader('النولون'),
// // // //                             TableCellHeader('المبيت'),
// // // //                             TableCellHeader('العطلة'),
// // // //                           ],
// // // //                         ),
// // // //                         ...invoiceTrips.map((trip) {
// // // //                           return TableRow(
// // // //                             decoration: BoxDecoration(color: Colors.white),
// // // //                             children: [
// // // //                               TableCellBody(
// // // //                                 trip['selectedRoute'] ?? '',
// // // //                                 textStyle: const TextStyle(
// // // //                                   fontWeight: FontWeight.bold,
// // // //                                   color: Color(0xFF3498DB),
// // // //                                 ),
// // // //                               ),
// // // //                               TableCellBody(
// // // //                                 _formatCurrency(trip['nolon']),
// // // //                                 textStyle: const TextStyle(
// // // //                                   fontWeight: FontWeight.bold,
// // // //                                   color: Colors.green,
// // // //                                 ),
// // // //                               ),
// // // //                               TableCellBody(
// // // //                                 _formatCurrency(trip['companyOvernight']),
// // // //                                 textStyle: const TextStyle(
// // // //                                   fontWeight: FontWeight.bold,
// // // //                                   color: Colors.orange,
// // // //                                 ),
// // // //                               ),
// // // //                               TableCellBody(
// // // //                                 _formatCurrency(trip['companyHoliday']),
// // // //                                 textStyle: const TextStyle(
// // // //                                   fontWeight: FontWeight.bold,
// // // //                                   color: Colors.red,
// // // //                                 ),
// // // //                               ),
// // // //                             ],
// // // //                           );
// // // //                         }).toList(),
// // // //                       ],
// // // //                     ),
// // // //                   ),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   double _calculateTotalInvoices() {
// // // //     double total = 0;
// // // //     for (var invoice in _invoices) {
// // // //       total += invoice['totalAmount'];
// // // //     }
// // // //     return total;
// // // //   }
// // // // }

// // // // class TableCellHeader extends StatelessWidget {
// // // //   final String text;
// // // //   const TableCellHeader(this.text, {super.key});

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Container(
// // // //       height: 40,
// // // //       alignment: Alignment.center,
// // // //       padding: const EdgeInsets.symmetric(horizontal: 8),
// // // //       child: Text(
// // // //         text,
// // // //         style: const TextStyle(
// // // //           fontWeight: FontWeight.bold,
// // // //           fontSize: 12,
// // // //           color: Color(0xFF2C3E50),
// // // //         ),
// // // //         textAlign: TextAlign.center,
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // class TableCellBody extends StatelessWidget {
// // // //   final String text;
// // // //   final TextStyle? textStyle;
// // // //   const TableCellBody(this.text, {this.textStyle, super.key});

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Container(
// // // //       height: 38,
// // // //       alignment: Alignment.center,
// // // //       padding: const EdgeInsets.symmetric(horizontal: 8),
// // // //       child: Text(
// // // //         text,
// // // //         maxLines: 2,
// // // //         overflow: TextOverflow.ellipsis,
// // // //         textAlign: TextAlign.center,
// // // //         style: textStyle ?? const TextStyle(fontSize: 12),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // import 'dart:async';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:intl/intl.dart';

// // // class CompanyWorkPage extends StatefulWidget {
// // //   const CompanyWorkPage({super.key});

// // //   @override
// // //   State<CompanyWorkPage> createState() => _CompanyWorkPageState();
// // // }

// // // class _CompanyWorkPageState extends State<CompanyWorkPage> {
// // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// // //   // متغيرات عامة
// // //   List<Map<String, dynamic>> _allCompanies = [];
// // //   List<Map<String, dynamic>> _filteredCompanies = [];
// // //   String? _selectedCompany;
// // //   String? _selectedCompanyId;
// // //   bool _isLoading = false;
// // //   String _searchQuery = '';

// // //   // متغيرات الأقسام بعد اختيار الشركة
// // //   int _currentSection = 0; // 0: شغل الشركات، 1: إنشاء فاتورة، 2: الفواتير
// // //   List<Map<String, dynamic>> _companyWork = []; // جميع الرحلات
// // //   List<Map<String, dynamic>> _availableTripsForInvoice =
// // //       []; // الرحلات المتاحة للفاتورة
// // //   List<Map<String, dynamic>> _companyInvoices = []; // فواتير الشركة

// // //   // متغيرات قسم إنشاء الفاتورة
// // //   final List<Map<String, dynamic>> _selectedTripsForInvoice = [];
// // //   final TextEditingController _invoiceNameController = TextEditingController();
// // //   bool _isCreatingInvoice = false;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadCompanies();
// // //   }

// // //   // ================================
// // //   // تحميل بيانات الشركات
// // //   // ================================
// // //   Future<void> _loadCompanies() async {
// // //     setState(() => _isLoading = true);
// // //     try {
// // //       final companiesSnapshot = await _firestore.collection('companies').get();

// // //       final List<Map<String, dynamic>> companiesList = [];

// // //       for (final companyDoc in companiesSnapshot.docs) {
// // //         final companyData = companyDoc.data();
// // //         final companyId = companyDoc.id;
// // //         final companyName =
// // //             (companyData['name'] ??
// // //                     companyData['companyName'] ??
// // //                     'شركة غير معروفة')
// // //                 .toString()
// // //                 .trim();

// // //         companiesList.add({
// // //           'companyId': companyId,
// // //           'companyName': companyName,
// // //           'companyData': companyData,
// // //         });
// // //       }

// // //       companiesList.sort(
// // //         (a, b) => a['companyName'].compareTo(b['companyName']),
// // //       );

// // //       setState(() {
// // //         _allCompanies = companiesList;
// // //         _filteredCompanies = _applySearchFilter(companiesList);
// // //         _isLoading = false;
// // //       });
// // //     } catch (e) {
// // //       setState(() => _isLoading = false);
// // //       debugPrint('خطأ في تحميل بيانات الشركات: $e');
// // //     }
// // //   }

// // //   // ================================
// // //   // تحميل بيانات الشركة المختارة
// // //   // ================================
// // //   Future<void> _loadCompanyData(String companyName, String companyId) async {
// // //     setState(() {
// // //       _selectedCompany = companyName;
// // //       _selectedCompanyId = companyId;
// // //       _isLoading = true;
// // //       _companyWork.clear();
// // //       _availableTripsForInvoice.clear();
// // //       _companyInvoices.clear();
// // //       _selectedTripsForInvoice.clear();
// // //       _invoiceNameController.clear();
// // //     });

// // //     try {
// // //       // 1. تحميل جميع رحلات الشركة من dailyWork
// // //       final workSnapshot = await _firestore
// // //           .collection('dailyWork')
// // //           .where('companyId', isEqualTo: companyId)
// // //           .orderBy('date', descending: true)
// // //           .get();

// // //       final List<Map<String, dynamic>> allTrips = [];

// // //       for (final doc in workSnapshot.docs) {
// // //         final data = doc.data();
// // //         final tripDate = (data['date'] as Timestamp?)?.toDate();

// // //         allTrips.add({
// // //           'id': doc.id,
// // //           'date': tripDate,
// // //           'companyName': companyName,
// // //           'companyId': companyId,
// // //           'driverName': data['driverName'] ?? 'غير معروف',
// // //           'nolon': (data['noLon'] ?? data['nolon'] ?? 0).toDouble(),
// // //           'companyOvernight': (data['companyOvernight'] ?? 0).toDouble(),
// // //           'companyHoliday': (data['companyHoliday'] ?? 0).toDouble(),
// // //           'selectedPrice': (data['selectedPrice'] ?? 0).toDouble(),
// // //           'karta': data['karta'] ?? '',
// // //           'ohda': data['ohda'] ?? '',
// // //           'selectedRoute': data['selectedRoute'] ?? '',
// // //           'loadingLocation': data['loadingLocation'] ?? '',
// // //           'unloadingLocation': data['unloadingLocation'] ?? '',
// // //           'vehicleType': data['selectedVehicleType'] ?? '',
// // //           'notes': data['selectedNotes'] ?? '',
// // //           'hasInvoice': false, // ستتم التحديث لاحقاً
// // //         });
// // //       }

// // //       // 2. تحميل فواتير الشركة
// // //       final invoicesSnapshot = await _firestore
// // //           .collection('invoices')
// // //           .where('companyId', isEqualTo: companyId)
// // //           .orderBy('createdAt', descending: true)
// // //           .get();

// // //       final List<Map<String, dynamic>> invoicesList = [];
// // //       final List<String> invoicedTripIds = [];

// // //       for (final doc in invoicesSnapshot.docs) {
// // //         final data = doc.data();
// // //         final tripIds = (data['tripIds'] as List<dynamic>? ?? []);

// // //         // جمع ID الرحلات التي تم عمل فاتورة لها
// // //         for (var tripId in tripIds) {
// // //           invoicedTripIds.add(tripId.toString());
// // //         }

// // //         // جلب تفاصيل الرحلات للفاتورة
// // //         List<Map<String, dynamic>> invoiceTrips = [];
// // //         double totalNolon = 0;
// // //         double totalOvernight = 0;
// // //         double totalHoliday = 0;

// // //         for (var tripId in tripIds) {
// // //           final tripDoc = await _firestore
// // //               .collection('dailyWork')
// // //               .doc(tripId.toString())
// // //               .get();
// // //           if (tripDoc.exists) {
// // //             final tripData = tripDoc.data() as Map<String, dynamic>;
// // //             invoiceTrips.add({
// // //               'selectedRoute': tripData['selectedRoute'] ?? '',
// // //               'nolon': (tripData['noLon'] ?? tripData['nolon'] ?? 0).toDouble(),
// // //               'companyOvernight': (tripData['companyOvernight'] ?? 0)
// // //                   .toDouble(),
// // //               'companyHoliday': (tripData['companyHoliday'] ?? 0).toDouble(),
// // //             });

// // //             totalNolon += (tripData['noLon'] ?? tripData['nolon'] ?? 0)
// // //                 .toDouble();
// // //             totalOvernight += (tripData['companyOvernight'] ?? 0).toDouble();
// // //             totalHoliday += (tripData['companyHoliday'] ?? 0).toDouble();
// // //           }
// // //         }

// // //         invoicesList.add({
// // //           'id': doc.id,
// // //           'name': data['name'] ?? 'فاتورة بدون اسم',
// // //           'companyName': data['companyName'] ?? 'شركة غير معروفة',
// // //           'totalAmount': (data['totalAmount'] ?? 0).toDouble(),
// // //           'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
// // //           'tripIds': tripIds,
// // //           'tripCount': tripIds.length,
// // //           'invoiceTrips': invoiceTrips,
// // //           'nolonTotal': totalNolon,
// // //           'overnightTotal': totalOvernight,
// // //           'holidayTotal': totalHoliday,
// // //         });
// // //       }

// // //       // 3. تحديث الرحلات لمعرفة أيها تم عمل فاتورة له
// // //       for (var trip in allTrips) {
// // //         trip['hasInvoice'] = invoicedTripIds.contains(trip['id']);
// // //       }

// // //       // 4. فصل الرحلات: المتاحة للفاتورة (التي ليس لها فاتورة)
// // //       final availableTrips = allTrips
// // //           .where((trip) => !trip['hasInvoice'])
// // //           .toList();

// // //       setState(() {
// // //         _companyWork = allTrips;
// // //         _availableTripsForInvoice = availableTrips;
// // //         _companyInvoices = invoicesList;
// // //         _isLoading = false;
// // //       });
// // //     } catch (e) {
// // //       setState(() => _isLoading = false);
// // //       _showError('خطأ في تحميل بيانات الشركة: $e');
// // //     }
// // //   }

// // //   // ================================
// // //   // دوال التصفية والبحث
// // //   // ================================
// // //   List<Map<String, dynamic>> _applySearchFilter(
// // //     List<Map<String, dynamic>> companies,
// // //   ) {
// // //     if (_searchQuery.isEmpty) return companies;
// // //     return companies
// // //         .where(
// // //           (c) => c['companyName'].toLowerCase().contains(
// // //             _searchQuery.toLowerCase(),
// // //           ),
// // //         )
// // //         .toList();
// // //   }

// // //   // ================================
// // //   // دوال قسم إنشاء الفاتورة
// // //   // ================================
// // //   void _toggleTripSelection(Map<String, dynamic> trip, bool selected) {
// // //     setState(() {
// // //       if (selected) {
// // //         _selectedTripsForInvoice.add(trip);
// // //       } else {
// // //         _selectedTripsForInvoice.removeWhere((t) => t['id'] == trip['id']);
// // //       }
// // //     });
// // //   }

// // //   void _selectAllTrips(bool select) {
// // //     setState(() {
// // //       if (select) {
// // //         _selectedTripsForInvoice.clear();
// // //         _selectedTripsForInvoice.addAll(_availableTripsForInvoice);
// // //       } else {
// // //         _selectedTripsForInvoice.clear();
// // //       }
// // //     });
// // //   }

// // //   Future<void> _createInvoice() async {
// // //     if (_selectedTripsForInvoice.isEmpty) {
// // //       _showError('يرجى اختيار رحلات لإنشاء الفاتورة');
// // //       return;
// // //     }

// // //     if (_invoiceNameController.text.isEmpty) {
// // //       _showError('يرجى إدخال اسم الفاتورة');
// // //       return;
// // //     }

// // //     setState(() => _isCreatingInvoice = true);

// // //     try {
// // //       // حساب إجمالي المبالغ
// // //       double totalNolon = 0;
// // //       double totalOvernight = 0;
// // //       double totalHoliday = 0;
// // //       List<String> tripIds = [];
// // //       List<Map<String, dynamic>> invoiceTripDetails = [];

// // //       for (var trip in _selectedTripsForInvoice) {
// // //         totalNolon += trip['nolon'];
// // //         totalOvernight += trip['companyOvernight'];
// // //         totalHoliday += trip['companyHoliday'];
// // //         tripIds.add(trip['id']);

// // //         invoiceTripDetails.add({
// // //           'selectedRoute': trip['selectedRoute'],
// // //           'nolon': trip['nolon'],
// // //           'companyOvernight': trip['companyOvernight'],
// // //           'companyHoliday': trip['companyHoliday'],
// // //         });
// // //       }

// // //       double totalAmount = totalNolon + totalOvernight + totalHoliday;

// // //       // حفظ الفاتورة
// // //       await _firestore.collection('invoices').add({
// // //         'name': _invoiceNameController.text.trim(),
// // //         'companyName': _selectedCompany!,
// // //         'companyId': _selectedCompanyId!,
// // //         'totalAmount': totalAmount,
// // //         'nolonTotal': totalNolon,
// // //         'overnightTotal': totalOvernight,
// // //         'holidayTotal': totalHoliday,
// // //         'tripIds': tripIds,
// // //         'tripDetails': invoiceTripDetails,
// // //         'tripCount': tripIds.length,
// // //         'createdAt': Timestamp.now(),
// // //         'status': 'غير مدفوعة',
// // //       });

// // //       // تحديث حالة الرحلات في dailyWork
// // //       final batch = _firestore.batch();
// // //       for (var tripId in tripIds) {
// // //         batch.update(_firestore.collection('dailyWork').doc(tripId), {
// // //           'hasInvoice': true,
// // //         });
// // //       }
// // //       await batch.commit();

// // //       _showSuccess('تم إنشاء الفاتورة بنجاح');

// // //       // إعادة تحميل بيانات الشركة
// // //       await _loadCompanyData(_selectedCompany!, _selectedCompanyId!);

// // //       // تنظيف المتغيرات
// // //       _selectedTripsForInvoice.clear();
// // //       _invoiceNameController.clear();

// // //       // الذهاب إلى قسم الفواتير
// // //       _changeSection(2);
// // //     } catch (e) {
// // //       _showError('خطأ في إنشاء الفاتورة: $e');
// // //     } finally {
// // //       setState(() => _isCreatingInvoice = false);
// // //     }
// // //   }

// // //   // ================================
// // //   // دوال مساعدة
// // //   // ================================
// // //   void _showError(String message) {
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(content: Text(message), backgroundColor: Colors.red),
// // //     );
// // //   }

// // //   void _showSuccess(String message) {
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(content: Text(message), backgroundColor: Colors.green),
// // //     );
// // //   }

// // //   String _formatDate(DateTime? date) {
// // //     if (date == null) return '-';
// // //     return DateFormat('dd/MM/yyyy').format(date);
// // //   }

// // //   String _formatCurrency(double amount) {
// // //     return '${amount.toStringAsFixed(2)} ج';
// // //   }

// // //   void _changeSection(int section) {
// // //     setState(() {
// // //       _currentSection = section;
// // //       if (section == 1) {
// // //         _selectedTripsForInvoice.clear();
// // //         _invoiceNameController.clear();
// // //       }
// // //     });
// // //   }

// // //   void _backToCompanies() {
// // //     setState(() {
// // //       _selectedCompany = null;
// // //       _selectedCompanyId = null;
// // //       _companyWork.clear();
// // //       _availableTripsForInvoice.clear();
// // //       _companyInvoices.clear();
// // //       _selectedTripsForInvoice.clear();
// // //       _invoiceNameController.clear();
// // //     });
// // //   }

// // //   // ================================
// // //   // بناء الواجهة
// // //   // ================================
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: const Color(0xFFF4F6F8),
// // //       body: Column(
// // //         children: [
// // //           _buildCustomAppBar(),
// // //           if (_selectedCompany == null) _buildSearchBar(),
// // //           Expanded(
// // //             child: _selectedCompany == null
// // //                 ? _buildCompanyList()
// // //                 : _buildCompanySections(),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildCustomAppBar() {
// // //     return Container(
// // //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
// // //         child: Row(
// // //           children: [
// // //             Icon(
// // //               _selectedCompany == null ? Icons.business : Icons.arrow_back,
// // //               color: Colors.white,
// // //               size: 28,
// // //             ),
// // //             const SizedBox(width: 8),
// // //             Expanded(
// // //               child: Center(
// // //                 child: Text(
// // //                   _selectedCompany == null ? 'اختر شركة' : '$_selectedCompany',
// // //                   style: const TextStyle(
// // //                     color: Colors.white,
// // //                     fontSize: 20,
// // //                     fontWeight: FontWeight.bold,
// // //                   ),
// // //                 ),
// // //               ),
// // //             ),
// // //             if (_selectedCompany != null)
// // //               IconButton(
// // //                 icon: const Icon(Icons.arrow_back, color: Colors.white),
// // //                 onPressed: _backToCompanies,
// // //               ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildSearchBar() {
// // //     return Container(
// // //       padding: const EdgeInsets.all(12),
// // //       color: Colors.white,
// // //       child: Container(
// // //         padding: const EdgeInsets.symmetric(horizontal: 12),
// // //         decoration: BoxDecoration(
// // //           color: const Color(0xFFF4F6F8),
// // //           borderRadius: BorderRadius.circular(12),
// // //           border: Border.all(color: const Color(0xFF3498DB)),
// // //         ),
// // //         child: Row(
// // //           children: [
// // //             const Icon(Icons.search, color: Color(0xFF3498DB), size: 20),
// // //             const SizedBox(width: 8),
// // //             Expanded(
// // //               child: TextField(
// // //                 onChanged: (value) {
// // //                   setState(() {
// // //                     _searchQuery = value;
// // //                     _filteredCompanies = _applySearchFilter(_allCompanies);
// // //                   });
// // //                 },
// // //                 decoration: const InputDecoration(
// // //                   hintText: 'ابحث عن شركة...',
// // //                   border: InputBorder.none,
// // //                   hintStyle: TextStyle(color: Colors.grey),
// // //                 ),
// // //               ),
// // //             ),
// // //             if (_searchQuery.isNotEmpty)
// // //               GestureDetector(
// // //                 onTap: () {
// // //                   setState(() {
// // //                     _searchQuery = '';
// // //                     _filteredCompanies = _applySearchFilter(_allCompanies);
// // //                   });
// // //                 },
// // //                 child: const Icon(Icons.clear, size: 18, color: Colors.grey),
// // //               ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildCompanyList() {
// // //     if (_isLoading) return const Center(child: CircularProgressIndicator());

// // //     return _filteredCompanies.isEmpty
// // //         ? Center(
// // //             child: Column(
// // //               mainAxisAlignment: MainAxisAlignment.center,
// // //               children: [
// // //                 Icon(Icons.business, size: 80, color: Colors.grey[400]),
// // //                 const SizedBox(height: 16),
// // //                 const Text(
// // //                   'لا توجد شركات',
// // //                   style: TextStyle(
// // //                     fontSize: 16,
// // //                     color: Colors.grey,
// // //                     fontWeight: FontWeight.bold,
// // //                   ),
// // //                   textAlign: TextAlign.center,
// // //                 ),
// // //               ],
// // //             ),
// // //           )
// // //         : ListView.builder(
// // //             padding: const EdgeInsets.all(8),
// // //             itemCount: _filteredCompanies.length,
// // //             itemBuilder: (context, index) {
// // //               final company = _filteredCompanies[index];
// // //               return _buildCompanyCard(company);
// // //             },
// // //           );
// // //   }

// // //   Widget _buildCompanyCard(Map<String, dynamic> company) {
// // //     final companyName = company['companyName'];
// // //     final companyId = company['companyId'];

// // //     return Container(
// // //       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
// // //       decoration: BoxDecoration(
// // //         color: Colors.white,
// // //         borderRadius: BorderRadius.circular(12),
// // //         border: Border.all(color: const Color(0xFF3498DB).withOpacity(0.3)),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: Colors.black.withOpacity(0.05),
// // //             blurRadius: 8,
// // //             offset: const Offset(0, 2),
// // //           ),
// // //         ],
// // //       ),
// // //       child: ListTile(
// // //         leading: Container(
// // //           width: 45,
// // //           height: 45,
// // //           decoration: BoxDecoration(
// // //             color: Color(0xFF3498DB),
// // //             borderRadius: BorderRadius.circular(22.5),
// // //           ),
// // //           child: const Center(child: Icon(Icons.business, color: Colors.white)),
// // //         ),
// // //         title: Text(
// // //           companyName,
// // //           style: const TextStyle(
// // //             fontWeight: FontWeight.bold,
// // //             fontSize: 16,
// // //             color: Color(0xFF2C3E50),
// // //           ),
// // //         ),
// // //         trailing: const Icon(
// // //           Icons.arrow_forward_ios,
// // //           color: Color(0xFF3498DB),
// // //           size: 16,
// // //         ),
// // //         onTap: () => _loadCompanyData(companyName, companyId),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildCompanySections() {
// // //     return Column(
// // //       children: [
// // //         // تبويبات الأقسام
// // //         _buildSectionTabs(),
// // //         Expanded(
// // //           child: _currentSection == 0
// // //               ? _buildWorkTable()
// // //               : _currentSection == 1
// // //               ? _buildCreateInvoiceSection()
// // //               : _buildInvoicesSection(),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildSectionTabs() {
// // //     return Container(
// // //       color: Colors.white,
// // //       child: Row(
// // //         children: [
// // //           _buildSectionTab(0, Icons.list, 'شغل الشركات'),
// // //           _buildSectionTab(1, Icons.receipt, 'إنشاء فاتورة'),
// // //           _buildSectionTab(2, Icons.list_alt, 'الفواتير'),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildSectionTab(int section, IconData icon, String title) {
// // //     final isActive = _currentSection == section;
// // //     return Expanded(
// // //       child: InkWell(
// // //         onTap: () => _changeSection(section),
// // //         child: Container(
// // //           padding: const EdgeInsets.symmetric(vertical: 12),
// // //           decoration: BoxDecoration(
// // //             color: isActive ? const Color(0xFF3498DB) : Colors.white,
// // //             border: Border(
// // //               bottom: BorderSide(
// // //                 color: isActive ? const Color(0xFF3498DB) : Colors.grey[300]!,
// // //                 width: 3,
// // //               ),
// // //             ),
// // //           ),
// // //           child: Column(
// // //             children: [
// // //               Icon(
// // //                 icon,
// // //                 color: isActive ? Colors.white : Colors.grey,
// // //                 size: 22,
// // //               ),
// // //               const SizedBox(height: 4),
// // //               Text(
// // //                 title,
// // //                 style: TextStyle(
// // //                   color: isActive ? Colors.white : Colors.grey,
// // //                   fontSize: 12,
// // //                   fontWeight: FontWeight.bold,
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildWorkTable() {
// // //     if (_isLoading) return const Center(child: CircularProgressIndicator());

// // //     return Column(
// // //       children: [
// // //         Container(
// // //           padding: const EdgeInsets.all(12),
// // //           color: Colors.blue[50],
// // //           child: Row(
// // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //             children: [
// // //               const Text(
// // //                 'جميع الرحلات',
// // //                 style: TextStyle(
// // //                   fontWeight: FontWeight.bold,
// // //                   color: Color(0xFF3498DB),
// // //                 ),
// // //               ),
// // //               Text(
// // //                 '${_companyWork.length} رحلة',
// // //                 style: const TextStyle(
// // //                   fontWeight: FontWeight.bold,
// // //                   color: Color(0xFF2E7D32),
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //         Expanded(
// // //           child: Container(
// // //             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // //             decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
// // //             child: _companyWork.isEmpty
// // //                 ? Center(
// // //                     child: Column(
// // //                       mainAxisAlignment: MainAxisAlignment.center,
// // //                       children: [
// // //                         const Icon(
// // //                           Icons.business,
// // //                           size: 60,
// // //                           color: Colors.grey,
// // //                         ),
// // //                         const SizedBox(height: 16),
// // //                         const Text(
// // //                           'لا يوجد شغل مسجل لهذه الشركة',
// // //                           style: TextStyle(
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
// // //                         defaultColumnWidth: const FixedColumnWidth(110),
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
// // //                               TableCellHeader('الحالة'),
// // //                               TableCellHeader('عطلة الشركة'),
// // //                               TableCellHeader('مبيت الشركة'),
// // //                               TableCellHeader('نولون الشركة'),
// // //                               TableCellHeader('اسم السائق'),
// // //                               TableCellHeader('الكارتة'),
// // //                               TableCellHeader('العهدة'),
// // //                               TableCellHeader('اسم الموقع'),
// // //                               TableCellHeader('مكان التعتيق'),
// // //                               TableCellHeader('مكان التحميل'),
// // //                               TableCellHeader('التاريخ'),
// // //                               TableCellHeader('م'),
// // //                             ],
// // //                           ),
// // //                           ..._companyWork.asMap().entries.map((entry) {
// // //                             final index = entry.key;
// // //                             final work = entry.value;
// // //                             final hasInvoice = work['hasInvoice'];

// // //                             return TableRow(
// // //                               decoration: BoxDecoration(
// // //                                 color: index.isEven
// // //                                     ? Colors.white
// // //                                     : const Color(0xFFF8F9FA),
// // //                               ),
// // //                               children: [
// // //                                 TableCellBody(
// // //                                   hasInvoice ? 'مفوتورة' : 'متاحة',
// // //                                   textStyle: TextStyle(
// // //                                     fontWeight: FontWeight.bold,
// // //                                     color: hasInvoice
// // //                                         ? Colors.red
// // //                                         : Colors.green,
// // //                                   ),
// // //                                 ),
// // //                                 TableCellBody(
// // //                                   '${work['companyHoliday']} ج',
// // //                                   textStyle: const TextStyle(
// // //                                     fontWeight: FontWeight.bold,
// // //                                     color: Colors.red,
// // //                                   ),
// // //                                 ),
// // //                                 TableCellBody(
// // //                                   '${work['companyOvernight']} ج',
// // //                                   textStyle: TextStyle(
// // //                                     fontWeight: FontWeight.bold,
// // //                                     color: Colors.orange[700],
// // //                                   ),
// // //                                 ),
// // //                                 TableCellBody(
// // //                                   '${work['nolon']} ج',
// // //                                   textStyle: const TextStyle(
// // //                                     fontWeight: FontWeight.bold,
// // //                                     color: Colors.green,
// // //                                   ),
// // //                                 ),
// // //                                 TableCellBody(
// // //                                   work['driverName'],
// // //                                   textStyle: const TextStyle(
// // //                                     fontWeight: FontWeight.bold,
// // //                                     color: Color(0xFF2C3E50),
// // //                                   ),
// // //                                 ),
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
// // //                           }).toList(),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   ),
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildCreateInvoiceSection() {
// // //     if (_isLoading) return const Center(child: CircularProgressIndicator());

// // //     return _availableTripsForInvoice.isEmpty
// // //         ? Center(
// // //             child: Column(
// // //               mainAxisAlignment: MainAxisAlignment.center,
// // //               children: [
// // //                 const Icon(Icons.receipt, size: 80, color: Colors.grey),
// // //                 const SizedBox(height: 20),
// // //                 const Text(
// // //                   'لا توجد رحلات متاحة للفاتورة',
// // //                   style: TextStyle(
// // //                     fontSize: 18,
// // //                     color: Colors.grey,
// // //                     fontWeight: FontWeight.bold,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 10),
// // //                 const Text(
// // //                   'جميع الرحلات تم عمل فاتورة لها',
// // //                   style: TextStyle(color: Colors.grey),
// // //                   textAlign: TextAlign.center,
// // //                 ),
// // //                 const SizedBox(height: 30),
// // //                 ElevatedButton.icon(
// // //                   onPressed: () => _changeSection(0),
// // //                   icon: const Icon(Icons.list),
// // //                   label: const Text('عرض جميع الرحلات'),
// // //                   style: ElevatedButton.styleFrom(
// // //                     backgroundColor: const Color(0xFF3498DB),
// // //                     foregroundColor: Colors.white,
// // //                     padding: const EdgeInsets.symmetric(
// // //                       horizontal: 20,
// // //                       vertical: 12,
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           )
// // //         : Column(
// // //             children: [
// // //               // إحصائيات الرحلات المختارة
// // //               Container(
// // //                 padding: const EdgeInsets.all(16),
// // //                 color: Colors.blue[50],
// // //                 child: Row(
// // //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                   children: [
// // //                     Column(
// // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // //                       children: [
// // //                         const Text(
// // //                           'الرحلات المتاحة',
// // //                           style: TextStyle(
// // //                             fontWeight: FontWeight.bold,
// // //                             color: Color(0xFF3498DB),
// // //                           ),
// // //                         ),
// // //                         Text(
// // //                           '${_availableTripsForInvoice.length} رحلة متاحة للفاتورة',
// // //                           style: const TextStyle(
// // //                             fontSize: 18,
// // //                             fontWeight: FontWeight.bold,
// // //                             color: Color(0xFF2E7D32),
// // //                           ),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                     Column(
// // //                       crossAxisAlignment: CrossAxisAlignment.end,
// // //                       children: [
// // //                         const Text(
// // //                           'الرحلات المختارة',
// // //                           style: TextStyle(
// // //                             fontWeight: FontWeight.bold,
// // //                             color: Color(0xFF3498DB),
// // //                           ),
// // //                         ),
// // //                         Text(
// // //                           '${_selectedTripsForInvoice.length} من ${_availableTripsForInvoice.length}',
// // //                           style: const TextStyle(
// // //                             fontSize: 18,
// // //                             fontWeight: FontWeight.bold,
// // //                             color: Color(0xFF2E7D32),
// // //                           ),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),

// // //               // اسم الفاتورة
// // //               Padding(
// // //                 padding: const EdgeInsets.all(16),
// // //                 child: TextField(
// // //                   controller: _invoiceNameController,
// // //                   decoration: InputDecoration(
// // //                     labelText: 'اسم الفاتورة',
// // //                     prefixIcon: const Icon(Icons.receipt),
// // //                     border: OutlineInputBorder(
// // //                       borderRadius: BorderRadius.circular(12),
// // //                     ),
// // //                     filled: true,
// // //                     fillColor: Colors.white,
// // //                   ),
// // //                 ),
// // //               ),

// // //               // أزرار التحكم
// // //               Padding(
// // //                 padding: const EdgeInsets.symmetric(horizontal: 16),
// // //                 child: Row(
// // //                   children: [
// // //                     Expanded(
// // //                       child: ElevatedButton.icon(
// // //                         onPressed: () => _selectAllTrips(true),
// // //                         icon: const Icon(Icons.check_box),
// // //                         label: const Text('تحديد الكل'),
// // //                         style: ElevatedButton.styleFrom(
// // //                           backgroundColor: Colors.green[50],
// // //                           foregroundColor: Colors.green[700],
// // //                         ),
// // //                       ),
// // //                     ),
// // //                     const SizedBox(width: 8),
// // //                     Expanded(
// // //                       child: ElevatedButton.icon(
// // //                         onPressed: () => _selectAllTrips(false),
// // //                         icon: const Icon(Icons.check_box_outline_blank),
// // //                         label: const Text('إلغاء الكل'),
// // //                         style: ElevatedButton.styleFrom(
// // //                           backgroundColor: Colors.red[50],
// // //                           foregroundColor: Colors.red[700],
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),

// // //               // تفاصيل المبالغ المختارة

// // //               // جدول الرحلات المتاحة مع خيار التحديد
// // //               Expanded(
// // //                 child: Container(
// // //                   margin: const EdgeInsets.all(16),
// // //                   decoration: BoxDecoration(
// // //                     borderRadius: BorderRadius.circular(12),
// // //                   ),
// // //                   child: SingleChildScrollView(
// // //                     scrollDirection: Axis.horizontal,
// // //                     child: SingleChildScrollView(
// // //                       scrollDirection: Axis.vertical,
// // //                       child: Table(
// // //                         defaultColumnWidth: const FixedColumnWidth(110),
// // //                         border: TableBorder.all(
// // //                           color: const Color(0xFF3498DB),
// // //                           width: 1,
// // //                         ),
// // //                         children: [
// // //                           TableRow(
// // //                             decoration: BoxDecoration(
// // //                               color: const Color(0xFF3498DB).withOpacity(0.15),
// // //                             ),
// // //                             children: [
// // //                               const TableCellHeader('تحديد'),
// // //                               const TableCellHeader('عطلة الشركة'),
// // //                               const TableCellHeader('مبيت الشركة'),
// // //                               const TableCellHeader('نولون الشركة'),
// // //                               const TableCellHeader('اسم السائق'),
// // //                               const TableCellHeader('الكارتة'),
// // //                               const TableCellHeader('العهدة'),
// // //                               const TableCellHeader('اسم الموقع'),
// // //                               const TableCellHeader('مكان التعتيق'),
// // //                               const TableCellHeader('مكان التحميل'),
// // //                               const TableCellHeader('التاريخ'),
// // //                               const TableCellHeader('م'),
// // //                             ],
// // //                           ),
// // //                           ..._availableTripsForInvoice.asMap().entries.map((
// // //                             entry,
// // //                           ) {
// // //                             final index = entry.key;
// // //                             final work = entry.value;
// // //                             final isSelected = _selectedTripsForInvoice.any(
// // //                               (trip) => trip['id'] == work['id'],
// // //                             );

// // //                             return TableRow(
// // //                               decoration: BoxDecoration(
// // //                                 color: isSelected
// // //                                     ? const Color(0xFFE8F5E9)
// // //                                     : index.isEven
// // //                                     ? Colors.white
// // //                                     : const Color(0xFFF8F9FA),
// // //                               ),
// // //                               children: [
// // //                                 TableCell(
// // //                                   child: Container(
// // //                                     height: 48,
// // //                                     alignment: Alignment.center,
// // //                                     child: Checkbox(
// // //                                       value: isSelected,
// // //                                       onChanged: (value) {
// // //                                         _toggleTripSelection(
// // //                                           work,
// // //                                           value ?? false,
// // //                                         );
// // //                                       },
// // //                                     ),
// // //                                   ),
// // //                                 ),
// // //                                 TableCellBody(
// // //                                   '${work['companyHoliday']} ج',
// // //                                   textStyle: const TextStyle(
// // //                                     fontWeight: FontWeight.bold,
// // //                                     color: Colors.red,
// // //                                   ),
// // //                                 ),
// // //                                 TableCellBody(
// // //                                   '${work['companyOvernight']} ج',
// // //                                   textStyle: TextStyle(
// // //                                     fontWeight: FontWeight.bold,
// // //                                     color: Colors.orange[700],
// // //                                   ),
// // //                                 ),
// // //                                 TableCellBody(
// // //                                   '${work['nolon']} ج',
// // //                                   textStyle: const TextStyle(
// // //                                     fontWeight: FontWeight.bold,
// // //                                     color: Colors.green,
// // //                                   ),
// // //                                 ),
// // //                                 TableCellBody(
// // //                                   work['driverName'],
// // //                                   textStyle: const TextStyle(
// // //                                     fontWeight: FontWeight.bold,
// // //                                     color: Color(0xFF2C3E50),
// // //                                   ),
// // //                                 ),
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
// // //                           }).toList(),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ),

// // //               // زر إنشاء الفاتورة
// // //               Padding(
// // //                 padding: const EdgeInsets.all(16),
// // //                 child: SizedBox(
// // //                   width: double.infinity,
// // //                   height: 50,
// // //                   child: ElevatedButton.icon(
// // //                     onPressed:
// // //                         _selectedTripsForInvoice.isEmpty || _isCreatingInvoice
// // //                         ? null
// // //                         : _createInvoice,
// // //                     icon: _isCreatingInvoice
// // //                         ? const SizedBox(
// // //                             width: 20,
// // //                             height: 20,
// // //                             child: CircularProgressIndicator(
// // //                               color: Colors.white,
// // //                             ),
// // //                           )
// // //                         : const Icon(Icons.save),
// // //                     label: Text(
// // //                       _isCreatingInvoice ? 'جاري الإنشاء...' : 'إنشاء الفاتورة',
// // //                       style: const TextStyle(fontSize: 16),
// // //                     ),
// // //                     style: ElevatedButton.styleFrom(
// // //                       backgroundColor: const Color(0xFF2E7D32),
// // //                       foregroundColor: Colors.white,
// // //                       shape: RoundedRectangleBorder(
// // //                         borderRadius: BorderRadius.circular(12),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ),
// // //             ],
// // //           );
// // //   }

// // //   Widget _buildInvoicesSection() {
// // //     if (_isLoading) return const Center(child: CircularProgressIndicator());

// // //     return Column(
// // //       children: [
// // //         Container(
// // //           padding: const EdgeInsets.all(16),
// // //           color: Colors.blue[50],
// // //           child: Row(
// // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //             children: [
// // //               const Text(
// // //                 'فواتير الشركة',
// // //                 style: TextStyle(
// // //                   fontWeight: FontWeight.bold,
// // //                   color: Color(0xFF3498DB),
// // //                 ),
// // //               ),
// // //               Text(
// // //                 '${_companyInvoices.length} فاتورة',
// // //                 style: const TextStyle(
// // //                   fontWeight: FontWeight.bold,
// // //                   color: Color(0xFF2E7D32),
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //         Expanded(
// // //           child: _companyInvoices.isEmpty
// // //               ? Center(
// // //                   child: Column(
// // //                     mainAxisAlignment: MainAxisAlignment.center,
// // //                     children: [
// // //                       const Icon(
// // //                         Icons.receipt_long,
// // //                         size: 80,
// // //                         color: Colors.grey,
// // //                       ),
// // //                       const SizedBox(height: 20),
// // //                       const Text(
// // //                         'لا توجد فواتير',
// // //                         style: TextStyle(
// // //                           fontSize: 18,
// // //                           color: Colors.grey,
// // //                           fontWeight: FontWeight.bold,
// // //                         ),
// // //                       ),
// // //                       const SizedBox(height: 10),
// // //                       const Text(
// // //                         'قم بإنشاء فاتورة أولاً',
// // //                         style: TextStyle(color: Colors.grey),
// // //                       ),
// // //                       const SizedBox(height: 30),
// // //                       ElevatedButton.icon(
// // //                         onPressed: () => _changeSection(1),
// // //                         icon: const Icon(Icons.add),
// // //                         label: const Text('إنشاء فاتورة'),
// // //                         style: ElevatedButton.styleFrom(
// // //                           backgroundColor: const Color(0xFF3498DB),
// // //                           foregroundColor: Colors.white,
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 )
// // //               : ListView.builder(
// // //                   padding: const EdgeInsets.all(8),
// // //                   itemCount: _companyInvoices.length,
// // //                   itemBuilder: (context, index) {
// // //                     final invoice = _companyInvoices[index];
// // //                     return _buildInvoiceCard(invoice, index);
// // //                   },
// // //                 ),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildInvoiceCard(Map<String, dynamic> invoice, int index) {
// // //     final createdAt = invoice['createdAt'] as DateTime?;
// // //     final invoiceTrips = invoice['invoiceTrips'] as List<Map<String, dynamic>>;

// // //     return Container(
// // //       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
// // //       decoration: BoxDecoration(
// // //         color: Colors.white,
// // //         borderRadius: BorderRadius.circular(12),
// // //         border: Border.all(color: Colors.grey[300]!),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: Colors.black.withOpacity(0.05),
// // //             blurRadius: 6,
// // //             offset: const Offset(0, 2),
// // //           ),
// // //         ],
// // //       ),
// // //       child: ExpansionTile(
// // //         leading: CircleAvatar(
// // //           backgroundColor: const Color(0xFF3498DB),
// // //           child: Text(
// // //             '${index + 1}',
// // //             style: const TextStyle(
// // //               color: Colors.white,
// // //               fontWeight: FontWeight.bold,
// // //             ),
// // //           ),
// // //         ),
// // //         title: Text(
// // //           invoice['name'],
// // //           style: const TextStyle(
// // //             fontWeight: FontWeight.bold,
// // //             fontSize: 16,
// // //             color: Color(0xFF2C3E50),
// // //           ),
// // //         ),
// // //         subtitle: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             Text(
// // //               '${invoice['tripCount']} رحلة - ${createdAt != null ? _formatDate(createdAt) : 'غير معروف'}',
// // //               style: const TextStyle(fontSize: 12, color: Colors.grey),
// // //             ),
// // //           ],
// // //         ),
// // //         trailing: Column(
// // //           mainAxisAlignment: MainAxisAlignment.center,
// // //           children: [
// // //             Text(
// // //               _formatCurrency(invoice['totalAmount']),
// // //               style: const TextStyle(
// // //                 fontWeight: FontWeight.bold,
// // //                 fontSize: 16,
// // //                 color: Color(0xFF2E7D32),
// // //               ),
// // //             ),
// // //             const SizedBox(height: 4),
// // //             Text(
// // //               'إجمالي',
// // //               style: TextStyle(fontSize: 12, color: Colors.grey[600]),
// // //             ),
// // //           ],
// // //         ),
// // //         children: [
// // //           Padding(
// // //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 // إحصائيات الفاتورة
// // //                 Container(
// // //                   padding: const EdgeInsets.all(12),
// // //                   decoration: BoxDecoration(
// // //                     color: Colors.blue[50],
// // //                     borderRadius: BorderRadius.circular(8),
// // //                   ),
// // //                   child: Column(
// // //                     children: [
// // //                       Row(
// // //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                         children: [
// // //                           const Text(
// // //                             'عدد الرحلات:',
// // //                             style: TextStyle(fontWeight: FontWeight.bold),
// // //                           ),
// // //                           Text(
// // //                             '${invoice['tripCount']}',
// // //                             style: const TextStyle(color: Color(0xFF3498DB)),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       const SizedBox(height: 4),
// // //                       Row(
// // //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                         children: [
// // //                           const Text(
// // //                             'إجمالي النولون:',
// // //                             style: TextStyle(
// // //                               fontWeight: FontWeight.bold,
// // //                               color: Colors.green,
// // //                             ),
// // //                           ),
// // //                           Text(
// // //                             _formatCurrency(invoice['nolonTotal']),
// // //                             style: const TextStyle(color: Colors.green),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       const SizedBox(height: 4),
// // //                       Row(
// // //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                         children: [
// // //                           const Text(
// // //                             'إجمالي المبيت:',
// // //                             style: TextStyle(
// // //                               fontWeight: FontWeight.bold,
// // //                               color: Colors.orange,
// // //                             ),
// // //                           ),
// // //                           Text(
// // //                             _formatCurrency(invoice['overnightTotal']),
// // //                             style: const TextStyle(color: Colors.orange),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       const SizedBox(height: 4),
// // //                       Row(
// // //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                         children: [
// // //                           const Text(
// // //                             'إجمالي العطلة:',
// // //                             style: TextStyle(
// // //                               fontWeight: FontWeight.bold,
// // //                               color: Colors.red,
// // //                             ),
// // //                           ),
// // //                           Text(
// // //                             _formatCurrency(invoice['holidayTotal']),
// // //                             style: const TextStyle(color: Colors.red),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),

// // //                 const SizedBox(height: 12),

// // //                 // تفاصيل الرحلات
// // //                 const Text(
// // //                   'تفاصيل الرحلات:',
// // //                   style: TextStyle(
// // //                     fontWeight: FontWeight.bold,
// // //                     color: Color(0xFF2C3E50),
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 8),

// // //                 // جدول تفاصيل الرحلات
// // //                 if (invoiceTrips.isNotEmpty)
// // //                   SingleChildScrollView(
// // //                     scrollDirection: Axis.horizontal,
// // //                     child: Table(
// // //                       defaultColumnWidth: const FixedColumnWidth(150),
// // //                       border: TableBorder.all(
// // //                         color: Colors.grey[300]!,
// // //                         width: 1,
// // //                       ),
// // //                       children: [
// // //                         TableRow(
// // //                           decoration: BoxDecoration(color: Colors.grey[100]),
// // //                           children: const [
// // //                             TableCellHeader('اسم الموقع'),
// // //                             TableCellHeader('النولون'),
// // //                             TableCellHeader('المبيت'),
// // //                             TableCellHeader('العطلة'),
// // //                           ],
// // //                         ),
// // //                         ...invoiceTrips.map((trip) {
// // //                           return TableRow(
// // //                             decoration: BoxDecoration(color: Colors.white),
// // //                             children: [
// // //                               TableCellBody(
// // //                                 trip['selectedRoute'] ?? '',
// // //                                 textStyle: const TextStyle(
// // //                                   fontWeight: FontWeight.bold,
// // //                                   color: Color(0xFF3498DB),
// // //                                 ),
// // //                               ),
// // //                               TableCellBody(
// // //                                 _formatCurrency(trip['nolon']),
// // //                                 textStyle: const TextStyle(
// // //                                   fontWeight: FontWeight.bold,
// // //                                   color: Colors.green,
// // //                                 ),
// // //                               ),
// // //                               TableCellBody(
// // //                                 _formatCurrency(trip['companyOvernight']),
// // //                                 textStyle: const TextStyle(
// // //                                   fontWeight: FontWeight.bold,
// // //                                   color: Colors.orange,
// // //                                 ),
// // //                               ),
// // //                               TableCellBody(
// // //                                 _formatCurrency(trip['companyHoliday']),
// // //                                 textStyle: const TextStyle(
// // //                                   fontWeight: FontWeight.bold,
// // //                                   color: Colors.red,
// // //                                 ),
// // //                               ),
// // //                             ],
// // //                           );
// // //                         }).toList(),
// // //                       ],
// // //                     ),
// // //                   ),
// // //               ],
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   double _calculateInvoiceTotal() {
// // //     double total = 0;
// // //     for (var trip in _selectedTripsForInvoice) {
// // //       total +=
// // //           trip['nolon'] + trip['companyOvernight'] + trip['companyHoliday'];
// // //     }
// // //     return total;
// // //   }

// // //   double _calculateNolonTotal() {
// // //     double total = 0;
// // //     for (var trip in _selectedTripsForInvoice) {
// // //       total += trip['nolon'];
// // //     }
// // //     return total;
// // //   }

// // //   double _calculateOvernightTotal() {
// // //     double total = 0;
// // //     for (var trip in _selectedTripsForInvoice) {
// // //       total += trip['companyOvernight'];
// // //     }
// // //     return total;
// // //   }

// // //   double _calculateHolidayTotal() {
// // //     double total = 0;
// // //     for (var trip in _selectedTripsForInvoice) {
// // //       total += trip['companyHoliday'];
// // //     }
// // //     return total;
// // //   }
// // // }

// // // class TableCellHeader extends StatelessWidget {
// // //   final String text;
// // //   const TableCellHeader(this.text, {super.key});

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Container(
// // //       height: 40,
// // //       alignment: Alignment.center,
// // //       padding: const EdgeInsets.symmetric(horizontal: 8),
// // //       child: Text(
// // //         text,
// // //         style: const TextStyle(
// // //           fontWeight: FontWeight.bold,
// // //           fontSize: 12,
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
// // //       height: 38,
// // //       alignment: Alignment.center,
// // //       padding: const EdgeInsets.symmetric(horizontal: 8),
// // //       child: Text(
// // //         text,
// // //         maxLines: 2,
// // //         overflow: TextOverflow.ellipsis,
// // //         textAlign: TextAlign.center,
// // //         style: textStyle ?? const TextStyle(fontSize: 12),
// // //       ),
// // //     );
// // //   }
// // // }
// // import 'dart:async';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';

// // class CompanyWorkPage extends StatefulWidget {
// //   const CompanyWorkPage({super.key});

// //   @override
// //   State<CompanyWorkPage> createState() => _CompanyWorkPageState();
// // }

// // class _CompanyWorkPageState extends State<CompanyWorkPage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// //   // متغيرات عامة
// //   List<Map<String, dynamic>> _allCompanies = [];
// //   List<Map<String, dynamic>> _filteredCompanies = [];
// //   String? _selectedCompany;
// //   String? _selectedCompanyId;
// //   bool _isLoading = false;
// //   String _searchQuery = '';

// //   // متغيرات الأقسام بعد اختيار الشركة
// //   int _currentSection = 0; // 0: شغل الشركات، 1: إنشاء فاتورة، 2: الفواتير
// //   List<Map<String, dynamic>> _companyWork = []; // جميع الرحلات
// //   List<Map<String, dynamic>> _availableTripsForInvoice =
// //       []; // الرحلات المتاحة للفاتورة
// //   List<Map<String, dynamic>> _companyInvoices = []; // فواتير الشركة

// //   // متغيرات قسم إنشاء الفاتورة
// //   final List<Map<String, dynamic>> _selectedTripsForInvoice = [];
// //   final TextEditingController _invoiceNameController = TextEditingController();
// //   bool _isCreatingInvoice = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadCompanies();
// //   }

// //   // ================================
// //   // تحميل بيانات الشركات
// //   // ================================
// //   Future<void> _loadCompanies() async {
// //     setState(() => _isLoading = true);
// //     try {
// //       final companiesSnapshot = await _firestore.collection('companies').get();

// //       final List<Map<String, dynamic>> companiesList = [];

// //       for (final companyDoc in companiesSnapshot.docs) {
// //         final companyData = companyDoc.data();
// //         final companyId = companyDoc.id;
// //         final companyName =
// //             (companyData['name'] ??
// //                     companyData['companyName'] ??
// //                     'شركة غير معروفة')
// //                 .toString()
// //                 .trim();

// //         companiesList.add({
// //           'companyId': companyId,
// //           'companyName': companyName,
// //           'companyData': companyData,
// //         });
// //       }

// //       companiesList.sort(
// //         (a, b) => a['companyName'].compareTo(b['companyName']),
// //       );

// //       setState(() {
// //         _allCompanies = companiesList;
// //         _filteredCompanies = _applySearchFilter(companiesList);
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() => _isLoading = false);
// //       debugPrint('خطأ في تحميل بيانات الشركات: $e');
// //     }
// //   }

// //   // ================================
// //   // تحميل بيانات الشركة المختارة
// //   // ================================
// //   Future<void> _loadCompanyData(String companyName, String companyId) async {
// //     setState(() {
// //       _selectedCompany = companyName;
// //       _selectedCompanyId = companyId;
// //       _isLoading = true;
// //       _companyWork.clear();
// //       _availableTripsForInvoice.clear();
// //       _companyInvoices.clear();
// //       _selectedTripsForInvoice.clear();
// //       _invoiceNameController.clear();
// //     });

// //     try {
// //       // 1. تحميل جميع رحلات الشركة من dailyWork
// //       final workSnapshot = await _firestore
// //           .collection('dailyWork')
// //           .where('companyId', isEqualTo: companyId)
// //           .orderBy('date', descending: true)
// //           .get();

// //       final List<Map<String, dynamic>> allTrips = [];

// //       for (final doc in workSnapshot.docs) {
// //         final data = doc.data();
// //         final tripDate = (data['date'] as Timestamp?)?.toDate();

// //         allTrips.add({
// //           'id': doc.id,
// //           'date': tripDate,
// //           'companyName': companyName,
// //           'companyId': companyId,
// //           'driverName': data['driverName'] ?? 'غير معروف',
// //           'nolon': (data['noLon'] ?? data['nolon'] ?? 0).toDouble(),
// //           'companyOvernight': (data['companyOvernight'] ?? 0).toDouble(),
// //           'companyHoliday': (data['companyHoliday'] ?? 0).toDouble(),
// //           'selectedPrice': (data['selectedPrice'] ?? 0).toDouble(),
// //           'karta': data['karta'] ?? '',
// //           'ohda': data['ohda'] ?? '',
// //           'selectedRoute': data['selectedRoute'] ?? '',
// //           'loadingLocation': data['loadingLocation'] ?? '',
// //           'unloadingLocation': data['unloadingLocation'] ?? '',
// //           'vehicleType': data['selectedVehicleType'] ?? '',
// //           'notes': data['selectedNotes'] ?? '',
// //           'tr': data['tr'] ?? '', // إضافة حقل TR
// //           'companyLocationName':
// //               data['companyLocationName'] ?? '', // إضافة حقل اسم موقع الشركة
// //           'hasInvoice': false, // ستتم التحديث لاحقاً
// //         });
// //       }

// //       // 2. تحميل فواتير الشركة
// //       final invoicesSnapshot = await _firestore
// //           .collection('invoices')
// //           .where('companyId', isEqualTo: companyId)
// //           .orderBy('createdAt', descending: true)
// //           .get();

// //       final List<Map<String, dynamic>> invoicesList = [];
// //       final List<String> invoicedTripIds = [];

// //       for (final doc in invoicesSnapshot.docs) {
// //         final data = doc.data();
// //         final tripIds = (data['tripIds'] as List<dynamic>? ?? []);

// //         // جمع ID الرحلات التي تم عمل فاتورة لها
// //         for (var tripId in tripIds) {
// //           invoicedTripIds.add(tripId.toString());
// //         }

// //         // جلب تفاصيل الرحلات للفاتورة
// //         List<Map<String, dynamic>> invoiceTrips = [];
// //         double totalNolon = 0;
// //         double totalOvernight = 0;
// //         double totalHoliday = 0;

// //         for (var tripId in tripIds) {
// //           final tripDoc = await _firestore
// //               .collection('dailyWork')
// //               .doc(tripId.toString())
// //               .get();
// //           if (tripDoc.exists) {
// //             final tripData = tripDoc.data() as Map<String, dynamic>;
// //             invoiceTrips.add({
// //               'selectedRoute': tripData['selectedRoute'] ?? '',
// //               'nolon': (tripData['noLon'] ?? tripData['nolon'] ?? 0).toDouble(),
// //               'companyOvernight': (tripData['companyOvernight'] ?? 0)
// //                   .toDouble(),
// //               'companyHoliday': (tripData['companyHoliday'] ?? 0).toDouble(),
// //               'tr': tripData['tr'] ?? '', // إضافة TR
// //               'companyLocationName':
// //                   tripData['companyLocationName'] ??
// //                   '', // إضافة اسم موقع الشركة
// //             });

// //             totalNolon += (tripData['noLon'] ?? tripData['nolon'] ?? 0)
// //                 .toDouble();
// //             totalOvernight += (tripData['companyOvernight'] ?? 0).toDouble();
// //             totalHoliday += (tripData['companyHoliday'] ?? 0).toDouble();
// //           }
// //         }

// //         invoicesList.add({
// //           'id': doc.id,
// //           'name': data['name'] ?? 'فاتورة بدون اسم',
// //           'companyName': data['companyName'] ?? 'شركة غير معروفة',
// //           'totalAmount': (data['totalAmount'] ?? 0).toDouble(),
// //           'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
// //           'tripIds': tripIds,
// //           'tripCount': tripIds.length,
// //           'invoiceTrips': invoiceTrips,
// //           'nolonTotal': totalNolon,
// //           'overnightTotal': totalOvernight,
// //           'holidayTotal': totalHoliday,
// //         });
// //       }

// //       // 3. تحديث الرحلات لمعرفة أيها تم عمل فاتورة له
// //       for (var trip in allTrips) {
// //         trip['hasInvoice'] = invoicedTripIds.contains(trip['id']);
// //       }

// //       // 4. فصل الرحلات: المتاحة للفاتورة (التي ليس لها فاتورة)
// //       final availableTrips = allTrips
// //           .where((trip) => !trip['hasInvoice'])
// //           .toList();

// //       setState(() {
// //         _companyWork = allTrips;
// //         _availableTripsForInvoice = availableTrips;
// //         _companyInvoices = invoicesList;
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() => _isLoading = false);
// //       _showError('خطأ في تحميل بيانات الشركة: $e');
// //     }
// //   }

// //   // ================================
// //   // دوال التصفية والبحث
// //   // ================================
// //   List<Map<String, dynamic>> _applySearchFilter(
// //     List<Map<String, dynamic>> companies,
// //   ) {
// //     if (_searchQuery.isEmpty) return companies;
// //     return companies
// //         .where(
// //           (c) => c['companyName'].toLowerCase().contains(
// //             _searchQuery.toLowerCase(),
// //           ),
// //         )
// //         .toList();
// //   }

// //   // ================================
// //   // دوال قسم إنشاء الفاتورة
// //   // ================================
// //   void _toggleTripSelection(Map<String, dynamic> trip, bool selected) {
// //     setState(() {
// //       if (selected) {
// //         _selectedTripsForInvoice.add(trip);
// //       } else {
// //         _selectedTripsForInvoice.removeWhere((t) => t['id'] == trip['id']);
// //       }
// //     });
// //   }

// //   void _selectAllTrips(bool select) {
// //     setState(() {
// //       if (select) {
// //         _selectedTripsForInvoice.clear();
// //         _selectedTripsForInvoice.addAll(_availableTripsForInvoice);
// //       } else {
// //         _selectedTripsForInvoice.clear();
// //       }
// //     });
// //   }

// //   Future<void> _createInvoice() async {
// //     if (_selectedTripsForInvoice.isEmpty) {
// //       _showError('يرجى اختيار رحلات لإنشاء الفاتورة');
// //       return;
// //     }

// //     if (_invoiceNameController.text.isEmpty) {
// //       _showError('يرجى إدخال اسم الفاتورة');
// //       return;
// //     }

// //     setState(() => _isCreatingInvoice = true);

// //     try {
// //       // حساب إجمالي المبالغ
// //       double totalNolon = 0;
// //       double totalOvernight = 0;
// //       double totalHoliday = 0;
// //       List<String> tripIds = [];
// //       List<Map<String, dynamic>> invoiceTripDetails = [];

// //       for (var trip in _selectedTripsForInvoice) {
// //         totalNolon += trip['nolon'];
// //         totalOvernight += trip['companyOvernight'];
// //         totalHoliday += trip['companyHoliday'];
// //         tripIds.add(trip['id']);

// //         invoiceTripDetails.add({
// //           'selectedRoute': trip['selectedRoute'],
// //           'nolon': trip['nolon'],
// //           'companyOvernight': trip['companyOvernight'],
// //           'companyHoliday': trip['companyHoliday'],
// //           'tr': trip['tr'], // إضافة TR
// //           'companyLocationName':
// //               trip['companyLocationName'], // إضافة اسم موقع الشركة
// //         });
// //       }

// //       double totalAmount = totalNolon + totalOvernight + totalHoliday;

// //       // حفظ الفاتورة
// //       await _firestore.collection('invoices').add({
// //         'name': _invoiceNameController.text.trim(),
// //         'companyName': _selectedCompany!,
// //         'companyId': _selectedCompanyId!,
// //         'totalAmount': totalAmount,
// //         'nolonTotal': totalNolon,
// //         'overnightTotal': totalOvernight,
// //         'holidayTotal': totalHoliday,
// //         'tripIds': tripIds,
// //         'tripDetails': invoiceTripDetails,
// //         'tripCount': tripIds.length,
// //         'createdAt': Timestamp.now(),
// //         'status': 'غير مدفوعة',
// //       });

// //       // تحديث حالة الرحلات في dailyWork
// //       final batch = _firestore.batch();
// //       for (var tripId in tripIds) {
// //         batch.update(_firestore.collection('dailyWork').doc(tripId), {
// //           'hasInvoice': true,
// //         });
// //       }
// //       await batch.commit();

// //       _showSuccess('تم إنشاء الفاتورة بنجاح');

// //       // إعادة تحميل بيانات الشركة
// //       await _loadCompanyData(_selectedCompany!, _selectedCompanyId!);

// //       // تنظيف المتغيرات
// //       _selectedTripsForInvoice.clear();
// //       _invoiceNameController.clear();

// //       // الذهاب إلى قسم الفواتير
// //       _changeSection(2);
// //     } catch (e) {
// //       _showError('خطأ في إنشاء الفاتورة: $e');
// //     } finally {
// //       setState(() => _isCreatingInvoice = false);
// //     }
// //   }

// //   // ================================
// //   // دوال مساعدة
// //   // ================================
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

// //   String _formatCurrency(double amount) {
// //     return '${amount.toStringAsFixed(2)} ج';
// //   }

// //   void _changeSection(int section) {
// //     setState(() {
// //       _currentSection = section;
// //       if (section == 1) {
// //         _selectedTripsForInvoice.clear();
// //         _invoiceNameController.clear();
// //       }
// //     });
// //   }

// //   void _backToCompanies() {
// //     setState(() {
// //       _selectedCompany = null;
// //       _selectedCompanyId = null;
// //       _companyWork.clear();
// //       _availableTripsForInvoice.clear();
// //       _companyInvoices.clear();
// //       _selectedTripsForInvoice.clear();
// //       _invoiceNameController.clear();
// //     });
// //   }

// //   // ================================
// //   // بناء الواجهة
// //   // ================================
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF4F6F8),
// //       body: Column(
// //         children: [
// //           _buildCustomAppBar(),
// //           if (_selectedCompany == null) _buildSearchBar(),
// //           Expanded(
// //             child: _selectedCompany == null
// //                 ? _buildCompanyList()
// //                 : _buildCompanySections(),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildCustomAppBar() {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
// //               _selectedCompany == null ? Icons.business : Icons.arrow_back,
// //               color: Colors.white,
// //               size: 28,
// //             ),
// //             const SizedBox(width: 8),
// //             Expanded(
// //               child: Center(
// //                 child: Text(
// //                   _selectedCompany == null ? 'اختر شركة' : '$_selectedCompany',
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 20,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             if (_selectedCompany != null)
// //               IconButton(
// //                 icon: const Icon(Icons.arrow_back, color: Colors.white),
// //                 onPressed: _backToCompanies,
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildSearchBar() {
// //     return Container(
// //       padding: const EdgeInsets.all(12),
// //       color: Colors.white,
// //       child: Container(
// //         padding: const EdgeInsets.symmetric(horizontal: 12),
// //         decoration: BoxDecoration(
// //           color: const Color(0xFFF4F6F8),
// //           borderRadius: BorderRadius.circular(12),
// //           border: Border.all(color: const Color(0xFF3498DB)),
// //         ),
// //         child: Row(
// //           children: [
// //             const Icon(Icons.search, color: Color(0xFF3498DB), size: 20),
// //             const SizedBox(width: 8),
// //             Expanded(
// //               child: TextField(
// //                 onChanged: (value) {
// //                   setState(() {
// //                     _searchQuery = value;
// //                     _filteredCompanies = _applySearchFilter(_allCompanies);
// //                   });
// //                 },
// //                 decoration: const InputDecoration(
// //                   hintText: 'ابحث عن شركة...',
// //                   border: InputBorder.none,
// //                   hintStyle: TextStyle(color: Colors.grey),
// //                 ),
// //               ),
// //             ),
// //             if (_searchQuery.isNotEmpty)
// //               GestureDetector(
// //                 onTap: () {
// //                   setState(() {
// //                     _searchQuery = '';
// //                     _filteredCompanies = _applySearchFilter(_allCompanies);
// //                   });
// //                 },
// //                 child: const Icon(Icons.clear, size: 18, color: Colors.grey),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildCompanyList() {
// //     if (_isLoading) return const Center(child: CircularProgressIndicator());

// //     return _filteredCompanies.isEmpty
// //         ? Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(Icons.business, size: 80, color: Colors.grey[400]),
// //                 const SizedBox(height: 16),
// //                 const Text(
// //                   'لا توجد شركات',
// //                   style: TextStyle(
// //                     fontSize: 16,
// //                     color: Colors.grey,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                   textAlign: TextAlign.center,
// //                 ),
// //               ],
// //             ),
// //           )
// //         : ListView.builder(
// //             padding: const EdgeInsets.all(8),
// //             itemCount: _filteredCompanies.length,
// //             itemBuilder: (context, index) {
// //               final company = _filteredCompanies[index];
// //               return _buildCompanyCard(company);
// //             },
// //           );
// //   }

// //   Widget _buildCompanyCard(Map<String, dynamic> company) {
// //     final companyName = company['companyName'];
// //     final companyId = company['companyId'];

// //     return Container(
// //       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
// //         leading: Container(
// //           width: 45,
// //           height: 45,
// //           decoration: BoxDecoration(
// //             color: Color(0xFF3498DB),
// //             borderRadius: BorderRadius.circular(22.5),
// //           ),
// //           child: const Center(child: Icon(Icons.business, color: Colors.white)),
// //         ),
// //         title: Text(
// //           companyName,
// //           style: const TextStyle(
// //             fontWeight: FontWeight.bold,
// //             fontSize: 16,
// //             color: Color(0xFF2C3E50),
// //           ),
// //         ),
// //         trailing: const Icon(
// //           Icons.arrow_forward_ios,
// //           color: Color(0xFF3498DB),
// //           size: 16,
// //         ),
// //         onTap: () => _loadCompanyData(companyName, companyId),
// //       ),
// //     );
// //   }

// //   Widget _buildCompanySections() {
// //     return Column(
// //       children: [
// //         // تبويبات الأقسام
// //         _buildSectionTabs(),
// //         Expanded(
// //           child: _currentSection == 0
// //               ? _buildWorkTable()
// //               : _currentSection == 1
// //               ? _buildCreateInvoiceSection()
// //               : _buildInvoicesSection(),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildSectionTabs() {
// //     return Container(
// //       color: Colors.white,
// //       child: Row(
// //         children: [
// //           _buildSectionTab(0, Icons.list, 'شغل الشركات'),
// //           _buildSectionTab(1, Icons.receipt, 'إنشاء فاتورة'),
// //           _buildSectionTab(2, Icons.list_alt, 'الفواتير'),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildSectionTab(int section, IconData icon, String title) {
// //     final isActive = _currentSection == section;
// //     return Expanded(
// //       child: InkWell(
// //         onTap: () => _changeSection(section),
// //         child: Container(
// //           padding: const EdgeInsets.symmetric(vertical: 12),
// //           decoration: BoxDecoration(
// //             color: isActive ? const Color(0xFF3498DB) : Colors.white,
// //             border: Border(
// //               bottom: BorderSide(
// //                 color: isActive ? const Color(0xFF3498DB) : Colors.grey[300]!,
// //                 width: 3,
// //               ),
// //             ),
// //           ),
// //           child: Column(
// //             children: [
// //               Icon(
// //                 icon,
// //                 color: isActive ? Colors.white : Colors.grey,
// //                 size: 22,
// //               ),
// //               const SizedBox(height: 4),
// //               Text(
// //                 title,
// //                 style: TextStyle(
// //                   color: isActive ? Colors.white : Colors.grey,
// //                   fontSize: 12,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
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
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               const Text(
// //                 'جميع الرحلات',
// //                 style: TextStyle(
// //                   fontWeight: FontWeight.bold,
// //                   color: Color(0xFF3498DB),
// //                 ),
// //               ),
// //               Text(
// //                 '${_companyWork.length} رحلة',
// //                 style: const TextStyle(
// //                   fontWeight: FontWeight.bold,
// //                   color: Color(0xFF2E7D32),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //         Expanded(
// //           child: Container(
// //             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //             decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
// //             child: _companyWork.isEmpty
// //                 ? Center(
// //                     child: Column(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         const Icon(
// //                           Icons.business,
// //                           size: 60,
// //                           color: Colors.grey,
// //                         ),
// //                         const SizedBox(height: 16),
// //                         const Text(
// //                           'لا يوجد شغل مسجل لهذه الشركة',
// //                           style: TextStyle(
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
// //                         defaultColumnWidth: const FixedColumnWidth(87),
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
// //                               TableCellHeader('الحالة'),

// //                               TableCellHeader('عطلة الشركة'),
// //                               TableCellHeader('مبيت الشركة'),
// //                               TableCellHeader('نولون الشركة'),
// //                               TableCellHeader('اسم السائق'),
// //                               TableCellHeader('الكارتة'),
// //                               TableCellHeader('العهدة'),
// //                               TableCellHeader('مطابقه نولون'),
// //                               TableCellHeader('TR'),
// //                               TableCellHeader('موقع الشركة'),
// //                               TableCellHeader('مكان التعتيق'),
// //                               TableCellHeader('مكان التحميل'),
// //                               TableCellHeader('التاريخ'),
// //                               TableCellHeader('م'),
// //                             ],
// //                           ),
// //                           ..._companyWork.asMap().entries.map((entry) {
// //                             final index = entry.key;
// //                             final work = entry.value;
// //                             final hasInvoice = work['hasInvoice'];

// //                             return TableRow(
// //                               decoration: BoxDecoration(
// //                                 color: index.isEven
// //                                     ? Colors.white
// //                                     : const Color(0xFFF8F9FA),
// //                               ),
// //                               children: [
// //                                 TableCellBody(
// //                                   hasInvoice ? 'مفوتورة' : 'متاحة',
// //                                   textStyle: TextStyle(
// //                                     fontWeight: FontWeight.bold,
// //                                     color: hasInvoice
// //                                         ? Colors.red
// //                                         : Colors.green,
// //                                   ),
// //                                 ),

// //                                 TableCellBody(
// //                                   '${work['companyHoliday']} ج',
// //                                   textStyle: const TextStyle(
// //                                     fontWeight: FontWeight.bold,
// //                                     color: Colors.red,
// //                                   ),
// //                                 ),
// //                                 TableCellBody(
// //                                   '${work['companyOvernight']} ج',
// //                                   textStyle: TextStyle(
// //                                     fontWeight: FontWeight.bold,
// //                                     color: Colors.orange[700],
// //                                   ),
// //                                 ),
// //                                 TableCellBody(
// //                                   '${work['nolon']} ج',
// //                                   textStyle: const TextStyle(
// //                                     fontWeight: FontWeight.bold,
// //                                     color: Colors.green,
// //                                   ),
// //                                 ),
// //                                 TableCellBody(
// //                                   work['driverName'],
// //                                   textStyle: const TextStyle(
// //                                     fontWeight: FontWeight.bold,
// //                                     color: Color(0xFF2C3E50),
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
// //                                 TableCellBody(
// //                                   work['tr'] ?? '-',
// //                                   textStyle: const TextStyle(
// //                                     fontWeight: FontWeight.bold,
// //                                     color: Color(0xFF2C3E50),
// //                                   ),
// //                                 ),
// //                                 TableCellBody(
// //                                   work['companyLocationName'] ?? '-',
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

// //   Widget _buildCreateInvoiceSection() {
// //     if (_isLoading) return const Center(child: CircularProgressIndicator());

// //     return _availableTripsForInvoice.isEmpty
// //         ? Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 const Icon(Icons.receipt, size: 80, color: Colors.grey),
// //                 const SizedBox(height: 20),
// //                 const Text(
// //                   'لا توجد رحلات متاحة للفاتورة',
// //                   style: TextStyle(
// //                     fontSize: 18,
// //                     color: Colors.grey,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 10),
// //                 const Text(
// //                   'جميع الرحلات تم عمل فاتورة لها',
// //                   style: TextStyle(color: Colors.grey),
// //                   textAlign: TextAlign.center,
// //                 ),
// //                 const SizedBox(height: 30),
// //                 ElevatedButton.icon(
// //                   onPressed: () => _changeSection(0),
// //                   icon: const Icon(Icons.list),
// //                   label: const Text('عرض جميع الرحلات'),
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: const Color(0xFF3498DB),
// //                     foregroundColor: Colors.white,
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 20,
// //                       vertical: 12,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           )
// //         : Column(
// //             children: [
// //               // إحصائيات الرحلات المختارة
// //               Container(
// //                 padding: const EdgeInsets.all(16),
// //                 color: Colors.blue[50],
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         const Text(
// //                           'الرحلات المتاحة',
// //                           style: TextStyle(
// //                             fontWeight: FontWeight.bold,
// //                             color: Color(0xFF3498DB),
// //                           ),
// //                         ),
// //                         Text(
// //                           '${_availableTripsForInvoice.length} رحلة متاحة للفاتورة',
// //                           style: const TextStyle(
// //                             fontSize: 18,
// //                             fontWeight: FontWeight.bold,
// //                             color: Color(0xFF2E7D32),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                     Column(
// //                       crossAxisAlignment: CrossAxisAlignment.end,
// //                       children: [
// //                         const Text(
// //                           'الرحلات المختارة',
// //                           style: TextStyle(
// //                             fontWeight: FontWeight.bold,
// //                             color: Color(0xFF3498DB),
// //                           ),
// //                         ),
// //                         Text(
// //                           '${_selectedTripsForInvoice.length} من ${_availableTripsForInvoice.length}',
// //                           style: const TextStyle(
// //                             fontSize: 18,
// //                             fontWeight: FontWeight.bold,
// //                             color: Color(0xFF2E7D32),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),

// //               // اسم الفاتورة
// //               Padding(
// //                 padding: const EdgeInsets.all(16),
// //                 child: TextField(
// //                   controller: _invoiceNameController,
// //                   decoration: InputDecoration(
// //                     labelText: 'اسم الفاتورة',
// //                     prefixIcon: const Icon(Icons.receipt),
// //                     border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                     filled: true,
// //                     fillColor: Colors.white,
// //                   ),
// //                 ),
// //               ),

// //               // أزرار التحكم
// //               Padding(
// //                 padding: const EdgeInsets.symmetric(horizontal: 16),
// //                 child: Row(
// //                   children: [
// //                     Expanded(
// //                       child: ElevatedButton.icon(
// //                         onPressed: () => _selectAllTrips(true),
// //                         icon: const Icon(Icons.check_box),
// //                         label: const Text('تحديد الكل'),
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: Colors.green[50],
// //                           foregroundColor: Colors.green[700],
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 8),
// //                     Expanded(
// //                       child: ElevatedButton.icon(
// //                         onPressed: () => _selectAllTrips(false),
// //                         icon: const Icon(Icons.check_box_outline_blank),
// //                         label: const Text('إلغاء الكل'),
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: Colors.red[50],
// //                           foregroundColor: Colors.red[700],
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),

// //               // تفاصيل المبالغ المختارة

// //               // جدول الرحلات المتاحة مع خيار التحديد
// //               Expanded(
// //                 child: Container(
// //                   margin: const EdgeInsets.all(16),
// //                   decoration: BoxDecoration(
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                   child: SingleChildScrollView(
// //                     scrollDirection: Axis.horizontal,
// //                     child: SingleChildScrollView(
// //                       scrollDirection: Axis.vertical,
// //                       child: Table(
// //                         defaultColumnWidth: const FixedColumnWidth(87),
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
// //                               TableCellHeader('تحديد'),

// //                               TableCellHeader('عطلة الشركة'),
// //                               TableCellHeader('مبيت الشركة'),
// //                               TableCellHeader('نولون الشركة'),
// //                               TableCellHeader('اسم السائق'),
// //                               TableCellHeader('الكارتة'),
// //                               TableCellHeader('العهدة'),
// //                               TableCellHeader('مطابقه نولون'),
// //                               TableCellHeader('TR'),
// //                               TableCellHeader('موقع الشركة'),
// //                               TableCellHeader('مكان التعتيق'),
// //                               TableCellHeader('مكان التحميل'),
// //                               TableCellHeader('التاريخ'),
// //                               TableCellHeader('م'),
// //                             ],
// //                           ),
// //                           ..._availableTripsForInvoice.asMap().entries.map((
// //                             entry,
// //                           ) {
// //                             final index = entry.key;
// //                             final work = entry.value;
// //                             final isSelected = _selectedTripsForInvoice.any(
// //                               (trip) => trip['id'] == work['id'],
// //                             );

// //                             return TableRow(
// //                               decoration: BoxDecoration(
// //                                 color: isSelected
// //                                     ? const Color(0xFFE8F5E9)
// //                                     : index.isEven
// //                                     ? Colors.white
// //                                     : const Color(0xFFF8F9FA),
// //                               ),
// //                               children: [
// //                                 TableCell(
// //                                   child: Container(
// //                                     height: 48,
// //                                     alignment: Alignment.center,
// //                                     child: Checkbox(
// //                                       value: isSelected,
// //                                       onChanged: (value) {
// //                                         _toggleTripSelection(
// //                                           work,
// //                                           value ?? false,
// //                                         );
// //                                       },
// //                                     ),
// //                                   ),
// //                                 ),

// //                                 TableCellBody(
// //                                   '${work['companyHoliday']} ج',
// //                                   textStyle: const TextStyle(
// //                                     fontWeight: FontWeight.bold,
// //                                     color: Colors.red,
// //                                   ),
// //                                 ),
// //                                 TableCellBody(
// //                                   '${work['companyOvernight']} ج',
// //                                   textStyle: TextStyle(
// //                                     fontWeight: FontWeight.bold,
// //                                     color: Colors.orange[700],
// //                                   ),
// //                                 ),
// //                                 TableCellBody(
// //                                   '${work['nolon']} ج',
// //                                   textStyle: const TextStyle(
// //                                     fontWeight: FontWeight.bold,
// //                                     color: Colors.green,
// //                                   ),
// //                                 ),
// //                                 TableCellBody(
// //                                   work['driverName'],
// //                                   textStyle: const TextStyle(
// //                                     fontWeight: FontWeight.bold,
// //                                     color: Color(0xFF2C3E50),
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
// //                                 TableCellBody(
// //                                   work['tr'] ?? '-',
// //                                   textStyle: const TextStyle(
// //                                     fontWeight: FontWeight.bold,
// //                                     color: Color(0xFF2C3E50),
// //                                   ),
// //                                 ),
// //                                 TableCellBody(
// //                                   work['companyLocationName'] ?? '-',
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
// //                 ),
// //               ),

// //               // زر إنشاء الفاتورة
// //               Padding(
// //                 padding: const EdgeInsets.all(16),
// //                 child: SizedBox(
// //                   width: double.infinity,
// //                   height: 50,
// //                   child: ElevatedButton.icon(
// //                     onPressed:
// //                         _selectedTripsForInvoice.isEmpty || _isCreatingInvoice
// //                         ? null
// //                         : _createInvoice,
// //                     icon: _isCreatingInvoice
// //                         ? const SizedBox(
// //                             width: 20,
// //                             height: 20,
// //                             child: CircularProgressIndicator(
// //                               color: Colors.white,
// //                             ),
// //                           )
// //                         : const Icon(Icons.save),
// //                     label: Text(
// //                       _isCreatingInvoice ? 'جاري الإنشاء...' : 'إنشاء الفاتورة',
// //                       style: const TextStyle(fontSize: 16),
// //                     ),
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: const Color(0xFF2E7D32),
// //                       foregroundColor: Colors.white,
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           );
// //   }

// //   Widget _buildInvoicesSection() {
// //     if (_isLoading) return const Center(child: CircularProgressIndicator());

// //     return Column(
// //       children: [
// //         Container(
// //           padding: const EdgeInsets.all(16),
// //           color: Colors.blue[50],
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               const Text(
// //                 'فواتير الشركة',
// //                 style: TextStyle(
// //                   fontWeight: FontWeight.bold,
// //                   color: Color(0xFF3498DB),
// //                 ),
// //               ),
// //               Text(
// //                 '${_companyInvoices.length} فاتورة',
// //                 style: const TextStyle(
// //                   fontWeight: FontWeight.bold,
// //                   color: Color(0xFF2E7D32),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //         Expanded(
// //           child: _companyInvoices.isEmpty
// //               ? Center(
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       const Icon(
// //                         Icons.receipt_long,
// //                         size: 80,
// //                         color: Colors.grey,
// //                       ),
// //                       const SizedBox(height: 20),
// //                       const Text(
// //                         'لا توجد فواتير',
// //                         style: TextStyle(
// //                           fontSize: 18,
// //                           color: Colors.grey,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 10),
// //                       const Text(
// //                         'قم بإنشاء فاتورة أولاً',
// //                         style: TextStyle(color: Colors.grey),
// //                       ),
// //                       const SizedBox(height: 30),
// //                       ElevatedButton.icon(
// //                         onPressed: () => _changeSection(1),
// //                         icon: const Icon(Icons.add),
// //                         label: const Text('إنشاء فاتورة'),
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: const Color(0xFF3498DB),
// //                           foregroundColor: Colors.white,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 )
// //               : ListView.builder(
// //                   padding: const EdgeInsets.all(8),
// //                   itemCount: _companyInvoices.length,
// //                   itemBuilder: (context, index) {
// //                     final invoice = _companyInvoices[index];
// //                     return _buildInvoiceCard(invoice, index);
// //                   },
// //                 ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildInvoiceCard(Map<String, dynamic> invoice, int index) {
// //     final createdAt = invoice['createdAt'] as DateTime?;
// //     final invoiceTrips = invoice['invoiceTrips'] as List<Map<String, dynamic>>;

// //     return Container(
// //       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: Colors.grey[300]!),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 6,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: ExpansionTile(
// //         leading: CircleAvatar(
// //           backgroundColor: const Color(0xFF3498DB),
// //           child: Text(
// //             '${index + 1}',
// //             style: const TextStyle(
// //               color: Colors.white,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //         ),
// //         title: Text(
// //           invoice['name'],
// //           style: const TextStyle(
// //             fontWeight: FontWeight.bold,
// //             fontSize: 16,
// //             color: Color(0xFF2C3E50),
// //           ),
// //         ),
// //         subtitle: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               '${invoice['tripCount']} رحلة - ${createdAt != null ? _formatDate(createdAt) : 'غير معروف'}',
// //               style: const TextStyle(fontSize: 12, color: Colors.grey),
// //             ),
// //           ],
// //         ),
// //         trailing: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Text(
// //               _formatCurrency(invoice['totalAmount']),
// //               style: const TextStyle(
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 16,
// //                 color: Color(0xFF2E7D32),
// //               ),
// //             ),
// //             const SizedBox(height: 4),
// //             Text(
// //               'إجمالي',
// //               style: TextStyle(fontSize: 12, color: Colors.grey[600]),
// //             ),
// //           ],
// //         ),
// //         children: [
// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 // إحصائيات الفاتورة
// //                 Container(
// //                   padding: const EdgeInsets.all(12),
// //                   decoration: BoxDecoration(
// //                     color: Colors.blue[50],
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                   child: Column(
// //                     children: [
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           const Text(
// //                             'عدد الرحلات:',
// //                             style: TextStyle(fontWeight: FontWeight.bold),
// //                           ),
// //                           Text(
// //                             '${invoice['tripCount']}',
// //                             style: const TextStyle(color: Color(0xFF3498DB)),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           const Text(
// //                             'إجمالي النولون:',
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               color: Colors.green,
// //                             ),
// //                           ),
// //                           Text(
// //                             _formatCurrency(invoice['nolonTotal']),
// //                             style: const TextStyle(color: Colors.green),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           const Text(
// //                             'إجمالي المبيت:',
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               color: Colors.orange,
// //                             ),
// //                           ),
// //                           Text(
// //                             _formatCurrency(invoice['overnightTotal']),
// //                             style: const TextStyle(color: Colors.orange),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           const Text(
// //                             'إجمالي العطلة:',
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               color: Colors.red,
// //                             ),
// //                           ),
// //                           Text(
// //                             _formatCurrency(invoice['holidayTotal']),
// //                             style: const TextStyle(color: Colors.red),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                 ),

// //                 const SizedBox(height: 12),

// //                 // تفاصيل الرحلات
// //                 const Text(
// //                   'تفاصيل الرحلات:',
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     color: Color(0xFF2C3E50),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 8),

// //                 // جدول تفاصيل الرحلات
// //                 if (invoiceTrips.isNotEmpty)
// //                   SingleChildScrollView(
// //                     scrollDirection: Axis.horizontal,
// //                     child: Table(
// //                       defaultColumnWidth: const FixedColumnWidth(150),
// //                       border: TableBorder.all(
// //                         color: Colors.grey[300]!,
// //                         width: 1,
// //                       ),
// //                       children: [
// //                         TableRow(
// //                           decoration: BoxDecoration(color: Colors.grey[100]),
// //                           children: const [
// //                             TableCellHeader('اسم الموقع'),
// //                             TableCellHeader('TR'),
// //                             TableCellHeader('موقع الشركة'),
// //                             TableCellHeader('النولون'),
// //                             TableCellHeader('المبيت'),
// //                             TableCellHeader('العطلة'),
// //                           ],
// //                         ),
// //                         ...invoiceTrips.map((trip) {
// //                           return TableRow(
// //                             decoration: BoxDecoration(color: Colors.white),
// //                             children: [
// //                               TableCellBody(
// //                                 trip['selectedRoute'] ?? '',
// //                                 textStyle: const TextStyle(
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Color(0xFF3498DB),
// //                                 ),
// //                               ),
// //                               TableCellBody(
// //                                 trip['tr'] ?? '-',
// //                                 textStyle: const TextStyle(
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Color(0xFF2C3E50),
// //                                 ),
// //                               ),
// //                               TableCellBody(
// //                                 trip['companyLocationName'] ?? '-',
// //                                 textStyle: const TextStyle(
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Color(0xFF3498DB),
// //                                 ),
// //                               ),
// //                               TableCellBody(
// //                                 _formatCurrency(trip['nolon']),
// //                                 textStyle: const TextStyle(
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Colors.green,
// //                                 ),
// //                               ),
// //                               TableCellBody(
// //                                 _formatCurrency(trip['companyOvernight']),
// //                                 textStyle: const TextStyle(
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Colors.orange,
// //                                 ),
// //                               ),
// //                               TableCellBody(
// //                                 _formatCurrency(trip['companyHoliday']),
// //                                 textStyle: const TextStyle(
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Colors.red,
// //                                 ),
// //                               ),
// //                             ],
// //                           );
// //                         }).toList(),
// //                       ],
// //                     ),
// //                   ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   double _calculateInvoiceTotal() {
// //     double total = 0;
// //     for (var trip in _selectedTripsForInvoice) {
// //       total +=
// //           trip['nolon'] + trip['companyOvernight'] + trip['companyHoliday'];
// //     }
// //     return total;
// //   }

// //   double _calculateNolonTotal() {
// //     double total = 0;
// //     for (var trip in _selectedTripsForInvoice) {
// //       total += trip['nolon'];
// //     }
// //     return total;
// //   }

// //   double _calculateOvernightTotal() {
// //     double total = 0;
// //     for (var trip in _selectedTripsForInvoice) {
// //       total += trip['companyOvernight'];
// //     }
// //     return total;
// //   }

// //   double _calculateHolidayTotal() {
// //     double total = 0;
// //     for (var trip in _selectedTripsForInvoice) {
// //       total += trip['companyHoliday'];
// //     }
// //     return total;
// //   }
// // }

// // class TableCellHeader extends StatelessWidget {
// //   final String text;
// //   const TableCellHeader(this.text, {super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       height: 40,
// //       alignment: Alignment.center,
// //       padding: const EdgeInsets.symmetric(horizontal: 8),
// //       child: Text(
// //         text,
// //         style: const TextStyle(
// //           fontWeight: FontWeight.bold,
// //           fontSize: 12,
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
// //       height: 38,
// //       alignment: Alignment.center,
// //       padding: const EdgeInsets.symmetric(horizontal: 8),
// //       child: Text(
// //         text,
// //         maxLines: 2,
// //         overflow: TextOverflow.ellipsis,
// //         textAlign: TextAlign.center,
// //         style: textStyle ?? const TextStyle(fontSize: 12),
// //       ),
// //     );
// //   }
// // }
// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:pdf/pdf.dart' as pdfLib;
// import 'package:pdf/widgets.dart' as pdfLib;
// import 'package:printing/printing.dart';
// import 'package:flutter/services.dart' show rootBundle;

// class CompanyWorkPage extends StatefulWidget {
//   const CompanyWorkPage({super.key});

//   @override
//   State<CompanyWorkPage> createState() => _CompanyWorkPageState();
// }

// class _CompanyWorkPageState extends State<CompanyWorkPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   pdfLib.Font? _arabicFont;

//   // متغيرات عامة
//   List<Map<String, dynamic>> _allCompanies = [];
//   List<Map<String, dynamic>> _filteredCompanies = [];
//   String? _selectedCompany;
//   String? _selectedCompanyId;
//   bool _isLoading = false;
//   String _searchQuery = '';

//   // متغيرات الأقسام بعد اختيار الشركة
//   int _currentSection = 0; // 0: شغل الشركات، 1: إنشاء فاتورة، 2: الفواتير
//   List<Map<String, dynamic>> _companyWork = []; // جميع الرحلات
//   List<Map<String, dynamic>> _availableTripsForInvoice =
//       []; // الرحلات المتاحة للفاتورة
//   List<Map<String, dynamic>> _companyInvoices = []; // فواتير الشركة

//   // متغيرات قسم إنشاء الفاتورة
//   final List<Map<String, dynamic>> _selectedTripsForInvoice = [];
//   final TextEditingController _invoiceNameController = TextEditingController();
//   bool _isCreatingInvoice = false;
//   bool _isGeneratingPDF = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadCompanies();
//     _loadArabicFont();
//   }

//   // ================================
//   // تحميل الخط العربي للطباعة
//   // ================================
//   Future<void> _loadArabicFont() async {
//     try {
//       final fontData = await rootBundle.load(
//         'assets/fonts/Amiri/Amiri-Regular.ttf',
//       );

//       _arabicFont = pdfLib.Font.ttf(fontData);
//       debugPrint('تم تحميل الخط العربي بنجاح');
//     } catch (e) {
//       debugPrint('فشل تحميل الخط العربي: $e');
//       // بديل إذا لم يوجد الخط
//       _arabicFont = pdfLib.Font.courier();
//     }
//   }

//   // ================================
//   // تحميل بيانات الشركات
//   // ================================
//   Future<void> _loadCompanies() async {
//     setState(() => _isLoading = true);
//     try {
//       final companiesSnapshot = await _firestore.collection('companies').get();

//       final List<Map<String, dynamic>> companiesList = [];

//       for (final companyDoc in companiesSnapshot.docs) {
//         final companyData = companyDoc.data();
//         final companyId = companyDoc.id;
//         final companyName =
//             (companyData['name'] ??
//                     companyData['companyName'] ??
//                     'شركة غير معروفة')
//                 .toString()
//                 .trim();

//         companiesList.add({
//           'companyId': companyId,
//           'companyName': companyName,
//           'companyData': companyData,
//         });
//       }

//       companiesList.sort(
//         (a, b) => a['companyName'].compareTo(b['companyName']),
//       );

//       setState(() {
//         _allCompanies = companiesList;
//         _filteredCompanies = _applySearchFilter(companiesList);
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       debugPrint('خطأ في تحميل بيانات الشركات: $e');
//     }
//   }

//   // ================================
//   // تحميل بيانات الشركة المختارة
//   // ================================
//   Future<void> _loadCompanyData(String companyName, String companyId) async {
//     setState(() {
//       _selectedCompany = companyName;
//       _selectedCompanyId = companyId;
//       _isLoading = true;
//       _companyWork.clear();
//       _availableTripsForInvoice.clear();
//       _companyInvoices.clear();
//       _selectedTripsForInvoice.clear();
//       _invoiceNameController.clear();
//     });

//     try {
//       // 1. تحميل جميع رحلات الشركة من dailyWork
//       final workSnapshot = await _firestore
//           .collection('dailyWork')
//           .where('companyId', isEqualTo: companyId)
//           .orderBy('date', descending: true)
//           .get();

//       final List<Map<String, dynamic>> allTrips = [];

//       for (final doc in workSnapshot.docs) {
//         final data = doc.data();
//         final tripDate = (data['date'] as Timestamp?)?.toDate();

//         allTrips.add({
//           'id': doc.id,
//           'date': tripDate,
//           'companyName': companyName,
//           'companyId': companyId,
//           'driverName': data['driverName'] ?? 'غير معروف',
//           'nolon': (data['noLon'] ?? data['nolon'] ?? 0).toDouble(),
//           'companyOvernight': (data['companyOvernight'] ?? 0).toDouble(),
//           'companyHoliday': (data['companyHoliday'] ?? 0).toDouble(),
//           'selectedPrice': (data['selectedPrice'] ?? 0).toDouble(),
//           'karta': data['karta'] ?? '',
//           'ohda': data['ohda'] ?? '',
//           'selectedRoute': data['selectedRoute'] ?? '',
//           'loadingLocation': data['loadingLocation'] ?? '',
//           'unloadingLocation': data['unloadingLocation'] ?? '',
//           'vehicleType': data['selectedVehicleType'] ?? '',
//           'notes': data['selectedNotes'] ?? '',
//           'tr': data['tr'] ?? '',
//           'companyLocationName': data['companyLocationName'] ?? '',
//           'hasInvoice': false,
//         });
//       }

//       // 2. تحميل فواتير الشركة
//       final invoicesSnapshot = await _firestore
//           .collection('invoices')
//           .where('companyId', isEqualTo: companyId)
//           .orderBy('createdAt', descending: true)
//           .get();

//       final List<Map<String, dynamic>> invoicesList = [];
//       final List<String> invoicedTripIds = [];

//       for (final doc in invoicesSnapshot.docs) {
//         final data = doc.data();
//         final tripIds = (data['tripIds'] as List<dynamic>? ?? []);

//         // جمع ID الرحلات التي تم عمل فاتورة لها
//         for (var tripId in tripIds) {
//           invoicedTripIds.add(tripId.toString());
//         }

//         // جلب تفاصيل الرحلات للفاتورة
//         List<Map<String, dynamic>> invoiceTrips = [];
//         double totalNolon = 0;
//         double totalOvernight = 0;
//         double totalHoliday = 0;

//         for (var tripId in tripIds) {
//           final tripDoc = await _firestore
//               .collection('dailyWork')
//               .doc(tripId.toString())
//               .get();
//           if (tripDoc.exists) {
//             final tripData = tripDoc.data() as Map<String, dynamic>;
//             invoiceTrips.add({
//               'selectedRoute': tripData['selectedRoute'] ?? '',
//               'nolon': (tripData['noLon'] ?? tripData['nolon'] ?? 0).toDouble(),
//               'companyOvernight': (tripData['companyOvernight'] ?? 0)
//                   .toDouble(),
//               'companyHoliday': (tripData['companyHoliday'] ?? 0).toDouble(),
//               'tr': tripData['tr'] ?? '',
//               'companyLocationName': tripData['companyLocationName'] ?? '',
//             });

//             totalNolon += (tripData['noLon'] ?? tripData['nolon'] ?? 0)
//                 .toDouble();
//             totalOvernight += (tripData['companyOvernight'] ?? 0).toDouble();
//             totalHoliday += (tripData['companyHoliday'] ?? 0).toDouble();
//           }
//         }

//         invoicesList.add({
//           'id': doc.id,
//           'name': data['name'] ?? 'فاتورة بدون اسم',
//           'companyName': data['companyName'] ?? 'شركة غير معروفة',
//           'totalAmount': (data['totalAmount'] ?? 0).toDouble(),
//           'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
//           'tripIds': tripIds,
//           'tripCount': tripIds.length,
//           'invoiceTrips': invoiceTrips,
//           'nolonTotal': totalNolon,
//           'overnightTotal': totalOvernight,
//           'holidayTotal': totalHoliday,
//         });
//       }

//       // 3. تحديث الرحلات لمعرفة أيها تم عمل فاتورة له
//       for (var trip in allTrips) {
//         trip['hasInvoice'] = invoicedTripIds.contains(trip['id']);
//       }

//       // 4. فصل الرحلات: المتاحة للفاتورة (التي ليس لها فاتورة)
//       final availableTrips = allTrips
//           .where((trip) => !trip['hasInvoice'])
//           .toList();

//       setState(() {
//         _companyWork = allTrips;
//         _availableTripsForInvoice = availableTrips;
//         _companyInvoices = invoicesList;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showError('خطأ في تحميل بيانات الشركة: $e');
//     }
//   }

//   // ================================
//   // دوال التصفية والبحث
//   // ================================
//   List<Map<String, dynamic>> _applySearchFilter(
//     List<Map<String, dynamic>> companies,
//   ) {
//     if (_searchQuery.isEmpty) return companies;
//     return companies
//         .where(
//           (c) => c['companyName'].toLowerCase().contains(
//             _searchQuery.toLowerCase(),
//           ),
//         )
//         .toList();
//   }

//   // ================================
//   // دوال قسم إنشاء الفاتورة
//   // ================================
//   void _toggleTripSelection(Map<String, dynamic> trip, bool selected) {
//     setState(() {
//       if (selected) {
//         _selectedTripsForInvoice.add(trip);
//       } else {
//         _selectedTripsForInvoice.removeWhere((t) => t['id'] == trip['id']);
//       }
//     });
//   }

//   void _selectAllTrips(bool select) {
//     setState(() {
//       if (select) {
//         _selectedTripsForInvoice.clear();
//         _selectedTripsForInvoice.addAll(_availableTripsForInvoice);
//       } else {
//         _selectedTripsForInvoice.clear();
//       }
//     });
//   }

//   Future<void> _createInvoice() async {
//     if (_selectedTripsForInvoice.isEmpty) {
//       _showError('يرجى اختيار رحلات لإنشاء الفاتورة');
//       return;
//     }

//     if (_invoiceNameController.text.isEmpty) {
//       _showError('يرجى إدخال اسم الفاتورة');
//       return;
//     }

//     setState(() => _isCreatingInvoice = true);

//     try {
//       // حساب إجمالي المبالغ
//       double totalNolon = 0;
//       double totalOvernight = 0;
//       double totalHoliday = 0;
//       List<String> tripIds = [];
//       List<Map<String, dynamic>> invoiceTripDetails = [];

//       for (var trip in _selectedTripsForInvoice) {
//         totalNolon += trip['nolon'];
//         totalOvernight += trip['companyOvernight'];
//         totalHoliday += trip['companyHoliday'];
//         tripIds.add(trip['id']);

//         invoiceTripDetails.add({
//           'selectedRoute': trip['selectedRoute'],
//           'nolon': trip['nolon'],
//           'companyOvernight': trip['companyOvernight'],
//           'companyHoliday': trip['companyHoliday'],
//           'tr': trip['tr'],
//           'companyLocationName': trip['companyLocationName'],
//           'date': trip['date'],
//         });
//       }

//       double totalAmount = totalNolon + totalOvernight + totalHoliday;

//       // حفظ الفاتورة
//       await _firestore.collection('invoices').add({
//         'name': _invoiceNameController.text.trim(),
//         'companyName': _selectedCompany!,
//         'companyId': _selectedCompanyId!,
//         'totalAmount': totalAmount,
//         'nolonTotal': totalNolon,
//         'overnightTotal': totalOvernight,
//         'holidayTotal': totalHoliday,
//         'tripIds': tripIds,
//         'tripDetails': invoiceTripDetails,
//         'tripCount': tripIds.length,
//         'createdAt': Timestamp.now(),
//         'status': 'غير مدفوعة',
//       });

//       // تحديث حالة الرحلات في dailyWork
//       final batch = _firestore.batch();
//       for (var tripId in tripIds) {
//         batch.update(_firestore.collection('dailyWork').doc(tripId), {
//           'hasInvoice': true,
//         });
//       }
//       await batch.commit();

//       _showSuccess('تم إنشاء الفاتورة بنجاح');

//       // إعادة تحميل بيانات الشركة
//       await _loadCompanyData(_selectedCompany!, _selectedCompanyId!);

//       // تنظيف المتغيرات
//       _selectedTripsForInvoice.clear();
//       _invoiceNameController.clear();

//       // الذهاب إلى قسم الفواتير
//       _changeSection(2);
//     } catch (e) {
//       _showError('خطأ في إنشاء الفاتورة: $e');
//     } finally {
//       setState(() => _isCreatingInvoice = false);
//     }
//   }

//   // ================================
//   // دوال مساعدة
//   // ================================
//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.red),
//     );
//   }

//   void _showSuccess(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.green),
//     );
//   }

//   String _formatDate(DateTime? date) {
//     if (date == null) return '-';
//     return DateFormat('dd/MM/yyyy').format(date);
//   }

//   String _formatCurrency(double amount) {
//     return '${amount.toStringAsFixed(2)} ج';
//   }

//   String _formatCurrencyForPDF(double amount) {
//     return '${amount.toStringAsFixed(2)}';
//   }

//   void _changeSection(int section) {
//     setState(() {
//       _currentSection = section;
//       if (section == 1) {
//         _selectedTripsForInvoice.clear();
//         _invoiceNameController.clear();
//       }
//     });
//   }

//   void _backToCompanies() {
//     setState(() {
//       _selectedCompany = null;
//       _selectedCompanyId = null;
//       _companyWork.clear();
//       _availableTripsForInvoice.clear();
//       _companyInvoices.clear();
//       _selectedTripsForInvoice.clear();
//       _invoiceNameController.clear();
//     });
//   }

//   ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

//   Future<void> _printInvoice(Map<String, dynamic> invoice) async {
//     if (_arabicFont == null) {
//       await _loadArabicFont();
//       if (_arabicFont == null) {
//         _showError('تعذر تحميل الخط العربي');
//         return;
//       }
//     }

//     setState(() => _isGeneratingPDF = true);

//     try {
//       final invoiceTrips =
//           invoice['invoiceTrips'] as List<Map<String, dynamic>>;
//       final companyName = invoice['companyName'] ?? 'غير معروف';
//       final invoiceName = invoice['name'] ?? 'فاتورة';
//       final invoiceId = invoice['id'] ?? '';
//       final createdAt = invoice['createdAt'] as DateTime?;
//       final companyLocationName = _getCompanyLocationName(invoiceTrips);

//       final groupedTrips = _groupTripsForInvoice(invoiceTrips);

//       final pdf = pdfLib.Document(
//         theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
//       );

//       pdf.addPage(
//         pdfLib.Page(
//           pageFormat: pdfLib.PdfPageFormat.a4,
//           margin: pdfLib.EdgeInsets.all(20),
//           build: (context) {
//             return pdfLib.Directionality(
//               textDirection: pdfLib.TextDirection.rtl,
//               child: pdfLib.Column(
//                 crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
//                 children: [
//                   _buildInvoiceHeader(
//                     companyName,
//                     invoiceId,
//                     createdAt,
//                     companyLocationName,
//                   ),
//                   pdfLib.SizedBox(height: 20),
//                   _buildInvoiceTable(groupedTrips),
//                   pdfLib.Spacer(),
//                   _buildInvoiceTotals(invoice),
//                 ],
//               ),
//             );
//           },
//         ),
//       );

//       await Printing.layoutPdf(
//         onLayout: (pdfLib.PdfPageFormat format) async => pdf.save(),
//         name:
//             'فاتورة_${invoiceName}_${DateFormat('yyyyMMdd').format(createdAt ?? DateTime.now())}',
//       );

//       _showSuccess('تم طباعة الفاتورة بنجاح');
//     } catch (e) {
//       _showError('خطأ في طباعة الفاتورة: $e');
//       debugPrint('خطأ في طباعة الفاتورة: $e');
//     } finally {
//       setState(() => _isGeneratingPDF = false);
//     }
//   }

//   // ================================
//   // بناء رأس الفاتورة
//   // ================================
//   pdfLib.Widget _buildInvoiceHeader(
//     String companyName,
//     String invoiceId,
//     DateTime? createdAt,
//     String companyLocationName,
//   ) {
//     return pdfLib.Column(
//       children: [
//         // الصف الأول: الشعار والفاتورة والتاريخ
//         pdfLib.Row(
//           mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
//           children: [
//             // الشعار على اليسار
//             pdfLib.Container(
//               width: 80,
//               height: 80,
//               child: pdfLib.Column(
//                 mainAxisAlignment: pdfLib.MainAxisAlignment.center,
//                 children: [
//                   pdfLib.Container(
//                     width: 60,
//                     height: 60,
//                     decoration: pdfLib.BoxDecoration(
//                       shape: pdfLib.BoxShape.circle,
//                       color: pdfLib.PdfColors.black,
//                     ),
//                   ),
//                   pdfLib.SizedBox(height: 5),
//                   pdfLib.Text(
//                     'New grand',
//                     style: pdfLib.TextStyle(
//                       fontSize: 12,
//                       fontWeight: pdfLib.FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // معلومات الفاتورة في المنتصف
//             pdfLib.Expanded(
//               child: pdfLib.Column(
//                 crossAxisAlignment: pdfLib.CrossAxisAlignment.center,
//                 children: [
//                   pdfLib.Row(
//                     mainAxisAlignment: pdfLib.MainAxisAlignment.center,
//                     children: [
//                       pdfLib.Text(
//                         'فاتورة ',
//                         style: pdfLib.TextStyle(
//                           fontSize: 18,
//                           fontWeight: pdfLib.FontWeight.bold,
//                           font: _arabicFont,
//                           decoration: pdfLib.TextDecoration.underline,
//                         ),
//                       ),
//                       pdfLib.Text(
//                         invoiceId,
//                         style: pdfLib.TextStyle(
//                           fontSize: 18,
//                           fontWeight: pdfLib.FontWeight.bold,
//                           font: _arabicFont,
//                           decoration: pdfLib.TextDecoration.underline,
//                         ),
//                       ),
//                     ],
//                   ),
//                   pdfLib.SizedBox(height: 5),
//                   pdfLib.Text(
//                     createdAt != null
//                         ? DateFormat('d/M/yyyy').format(createdAt)
//                         : '1/2/2023',
//                     style: pdfLib.TextStyle(fontSize: 12, font: _arabicFont),
//                   ),
//                 ],
//               ),
//             ),

//             // التاريخ على اليمين
//             pdfLib.Container(
//               width: 80,
//               child: pdfLib.Column(
//                 crossAxisAlignment: pdfLib.CrossAxisAlignment.end,
//                 children: [
//                   pdfLib.Text(
//                     'التاريخ :',
//                     style: pdfLib.TextStyle(fontSize: 11, font: _arabicFont),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),

//         pdfLib.SizedBox(height: 10),

//         // معلومات الشركة
//         pdfLib.Column(
//           crossAxisAlignment: pdfLib.CrossAxisAlignment.end,
//           children: [
//             pdfLib.Row(
//               mainAxisAlignment: pdfLib.MainAxisAlignment.end,
//               children: [
//                 pdfLib.Text(
//                   companyName,
//                   style: pdfLib.TextStyle(fontSize: 11, font: _arabicFont),
//                 ),
//                 pdfLib.SizedBox(width: 10),
//                 pdfLib.Text(
//                   'السادة شركة',
//                   style: pdfLib.TextStyle(fontSize: 11, font: _arabicFont),
//                 ),
//               ],
//             ),
//             pdfLib.SizedBox(height: 3),
//             pdfLib.Text(
//               'مذكور للمشروعات',
//               style: pdfLib.TextStyle(fontSize: 11, font: _arabicFont),
//             ),
//             pdfLib.SizedBox(height: 3),
//             pdfLib.Row(
//               mainAxisAlignment: pdfLib.MainAxisAlignment.end,
//               children: [
//                 pdfLib.Text(
//                   companyLocationName.isNotEmpty
//                       ? companyLocationName
//                       : 'امتداد محور التعمير-195',
//                   style: pdfLib.TextStyle(fontSize: 11, font: _arabicFont),
//                 ),
//                 pdfLib.SizedBox(width: 10),
//                 pdfLib.Text(
//                   'موقع :',
//                   style: pdfLib.TextStyle(fontSize: 11, font: _arabicFont),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   // ================================
//   // بناء جدول الفاتورة
//   // ================================
//   pdfLib.Widget _buildInvoiceTable(List<Map<String, dynamic>> groupedTrips) {
//     return pdfLib.Table(
//       border: pdfLib.TableBorder.all(color: pdfLib.PdfColors.black, width: 1),
//       children: [
//         // رأس الجدول
//         pdfLib.TableRow(
//           decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
//           children: [
//             _buildHeaderCell('التاريخ'),
//             _buildHeaderCell('TR\nNumber'),
//             _buildHeaderCell('البيان'),
//             _buildHeaderCell('عدد/طن'),
//             _buildHeaderCell('السعر'),
//             _buildHeaderCell('القيمة الاجمالية'),
//           ],
//         ),

//         // صفوف البيانات
//         ...groupedTrips.map(
//           (trip) => pdfLib.TableRow(
//             children: [
//               _buildDataCell(trip['date'] ?? '-'),
//               _buildDataCell(trip['tr']?.toString() ?? '-'),
//               _buildDataCell(
//                 trip['description'] ?? '-',
//                 align: pdfLib.TextAlign.right,
//               ),
//               _buildDataCell((trip['count'] ?? 0).toString()),
//               _buildDataCell(_formatCurrencyForPDF(trip['price'] ?? 0)),
//               _buildDataCell(_formatCurrencyForPDF(trip['total'] ?? 0)),
//             ],
//           ),
//         ),

//         // صفوف فارغة إضافية (20 صف كحد أقصى)
//         ...List.generate(
//           20 - groupedTrips.length > 0 ? 20 - groupedTrips.length : 0,
//           (index) => pdfLib.TableRow(
//             children: [
//               _buildDataCell(''),
//               _buildDataCell(''),
//               _buildDataCell(''),
//               _buildDataCell(''),
//               _buildDataCell(''),
//               _buildDataCell('0'),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   pdfLib.Widget _buildHeaderCell(String text) {
//     return pdfLib.Container(
//       padding: pdfLib.EdgeInsets.all(5),
//       alignment: pdfLib.Alignment.center,
//       child: pdfLib.Text(
//         text,
//         style: pdfLib.TextStyle(
//           fontSize: 10,
//           fontWeight: pdfLib.FontWeight.bold,
//           font: _arabicFont,
//         ),
//         textAlign: pdfLib.TextAlign.center,
//       ),
//     );
//   }

//   pdfLib.Widget _buildDataCell(
//     String text, {
//     pdfLib.TextAlign align = pdfLib.TextAlign.center,
//   }) {
//     return pdfLib.Container(
//       padding: pdfLib.EdgeInsets.all(5),
//       alignment: align == pdfLib.TextAlign.right
//           ? pdfLib.Alignment.centerRight
//           : pdfLib.Alignment.center,
//       child: pdfLib.Text(
//         text,
//         style: pdfLib.TextStyle(fontSize: 9, font: _arabicFont),
//         textAlign: align,
//       ),
//     );
//   }

//   // ================================
//   // بناء قسم الإجماليات
//   // ================================
//   pdfLib.Widget _buildInvoiceTotals(Map<String, dynamic> invoice) {
//     final totalAmount = (invoice['totalAmount'] ?? 0).toDouble();
//     final tax = totalAmount * 0.14;
//     final totalAfterTax = totalAmount + tax;

//     return pdfLib.Column(
//       crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
//       children: [
//         pdfLib.Container(
//           decoration: pdfLib.BoxDecoration(
//             border: pdfLib.Border.all(color: pdfLib.PdfColors.black),
//           ),
//           child: pdfLib.Table(
//             border: pdfLib.TableBorder.all(color: pdfLib.PdfColors.black),
//             children: [
//               pdfLib.TableRow(
//                 children: [
//                   _buildTotalCell(_formatCurrencyForPDF(totalAmount)),
//                   _buildTotalCell('الإجمالي', isLabel: true),
//                 ],
//               ),
//               pdfLib.TableRow(
//                 children: [
//                   _buildTotalCell(_formatCurrencyForPDF(tax)),
//                   _buildTotalCell('14%ضريبة مبيعات', isLabel: true),
//                 ],
//               ),
//               pdfLib.TableRow(
//                 children: [
//                   _buildTotalCell(_formatCurrencyForPDF(totalAfterTax)),
//                   _buildTotalCell('الإجمالي بعد الضريبة', isLabel: true),
//                 ],
//               ),
//             ],
//           ),
//         ),

//         pdfLib.SizedBox(height: 10),

//         // معلومات الشركة في الأسفل
//         pdfLib.Row(
//           mainAxisAlignment: pdfLib.MainAxisAlignment.end,
//           children: [
//             pdfLib.Column(
//               crossAxisAlignment: pdfLib.CrossAxisAlignment.end,
//               children: [
//                 pdfLib.Row(
//                   children: [
//                     pdfLib.Text(
//                       '16732',
//                       style: pdfLib.TextStyle(fontSize: 9, font: _arabicFont),
//                     ),
//                     pdfLib.SizedBox(width: 5),
//                     pdfLib.Text(
//                       'سجل تجاري :',
//                       style: pdfLib.TextStyle(fontSize: 9, font: _arabicFont),
//                     ),
//                   ],
//                 ),
//                 pdfLib.SizedBox(height: 2),
//                 pdfLib.Row(
//                   children: [
//                     pdfLib.Text(
//                       '261-525-263',
//                       style: pdfLib.TextStyle(fontSize: 9, font: _arabicFont),
//                     ),
//                     pdfLib.SizedBox(width: 5),
//                     pdfLib.Text(
//                       'بطاقة ضريبة :',
//                       style: pdfLib.TextStyle(fontSize: 9, font: _arabicFont),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),

//         pdfLib.SizedBox(height: 5),

//         pdfLib.Text(
//           'الفاتورة الغير مختومة بختم الشركة لايعتد بها',
//           style: pdfLib.TextStyle(fontSize: 9, font: _arabicFont),
//           textAlign: pdfLib.TextAlign.center,
//         ),
//       ],
//     );
//   }

//   pdfLib.Widget _buildTotalCell(String text, {bool isLabel = false}) {
//     return pdfLib.Container(
//       padding: pdfLib.EdgeInsets.all(5),
//       alignment: pdfLib.Alignment.center,
//       child: pdfLib.Text(
//         text,
//         style: pdfLib.TextStyle(
//           fontSize: 10,
//           font: _arabicFont,
//           fontWeight: isLabel
//               ? pdfLib.FontWeight.bold
//               : pdfLib.FontWeight.normal,
//         ),
//         textAlign: pdfLib.TextAlign.center,
//       ),
//     );
//   }

//   // ================================
//   // تجميع الرحلات
//   // ================================
//   List<Map<String, dynamic>> _groupTripsForInvoice(
//     List<Map<String, dynamic>> trips,
//   ) {
//     final Map<String, Map<String, dynamic>> grouped = {};

//     for (final trip in trips) {
//       final date = trip['date'] != null
//           ? DateFormat('d/M/yyyy').format((trip['date'] as DateTime))
//           : DateFormat('d/M/yyyy').format(DateTime.now());
//       final tr = trip['tr']?.toString() ?? '';
//       final nolon = (trip['nolon'] ?? 0).toDouble();
//       final companyOvernight = (trip['companyOvernight'] ?? 0).toDouble();
//       final companyHoliday = (trip['companyHoliday'] ?? 0).toDouble();
//       final selectedRoute = trip['selectedRoute']?.toString() ?? '';
//       final companyLocationName = trip['companyLocationName']?.toString() ?? '';

//       String description = selectedRoute;
//       if (companyLocationName.isNotEmpty) {
//         description += ' $companyLocationName';
//       }

//       final key = '$date|$tr|$nolon|$selectedRoute';

//       if (!grouped.containsKey(key)) {
//         grouped[key] = {
//           'date': date,
//           'tr': tr,
//           'description': description,
//           'nolon': nolon,
//           'nolonCount': 1,
//           'overnight': companyOvernight,
//           'overnightCount': companyOvernight > 0 ? 1 : 0,
//           'holiday': companyHoliday,
//           'holidayCount': companyHoliday > 0 ? 1 : 0,
//           'selectedRoute': selectedRoute,
//           'companyLocationName': companyLocationName,
//         };
//       } else {
//         final existing = grouped[key]!;
//         existing['nolonCount'] = (existing['nolonCount'] as int) + 1;
//         if (companyOvernight > 0)
//           existing['overnightCount'] = (existing['overnightCount'] as int) + 1;
//         if (companyHoliday > 0)
//           existing['holidayCount'] = (existing['holidayCount'] as int) + 1;
//       }
//     }

//     final List<Map<String, dynamic>> result = [];

//     grouped.forEach((key, tripGroup) {
//       if (tripGroup['nolonCount'] > 0) {
//         result.add({
//           'type': 'نولون',
//           'date': tripGroup['date'],
//           'tr': tripGroup['tr'],
//           'description': tripGroup['description'],
//           'count': tripGroup['nolonCount'],
//           'price': tripGroup['nolon'],
//           'total':
//               (tripGroup['nolonCount'] as int) * (tripGroup['nolon'] as double),
//         });
//       }
//       if (tripGroup['overnightCount'] > 0) {
//         result.add({
//           'type': 'مبيت',
//           'date': tripGroup['date'],
//           'tr': tripGroup['tr'],
//           'description': 'مبيت ${tripGroup['description']}',
//           'count': tripGroup['overnightCount'],
//           'price': tripGroup['overnight'],
//           'total':
//               (tripGroup['overnightCount'] as int) *
//               (tripGroup['overnight'] as double),
//         });
//       }
//       if (tripGroup['holidayCount'] > 0) {
//         result.add({
//           'type': 'عطلة',
//           'date': tripGroup['date'],
//           'tr': tripGroup['tr'],
//           'description': 'عطلة ${tripGroup['description']}',
//           'count': tripGroup['holidayCount'],
//           'price': tripGroup['holiday'],
//           'total':
//               (tripGroup['holidayCount'] as int) *
//               (tripGroup['holiday'] as double),
//         });
//       }
//     });

//     return result;
//   }

//   String _getCompanyLocationName(List<Map<String, dynamic>> trips) {
//     if (trips.isEmpty) return '';
//     for (final trip in trips) {
//       final location = trip['companyLocationName']?.toString() ?? '';
//       if (location.isNotEmpty) return location;
//     }
//     return '';
//   }

//   //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   // ================================
//   // بناء الواجهة
//   // ================================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6F8),
//       body: Column(
//         children: [
//           _buildCustomAppBar(),
//           if (_selectedCompany == null) _buildSearchBar(),
//           Expanded(
//             child: _selectedCompany == null
//                 ? _buildCompanyList()
//                 : _buildCompanySections(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCustomAppBar() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
//               _selectedCompany == null ? Icons.business : Icons.arrow_back,
//               color: Colors.white,
//               size: 28,
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Center(
//                 child: Text(
//                   _selectedCompany == null ? 'اختر شركة' : '$_selectedCompany',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//             if (_selectedCompany != null)
//               IconButton(
//                 icon: const Icon(Icons.arrow_back, color: Colors.white),
//                 onPressed: _backToCompanies,
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       color: Colors.white,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF4F6F8),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: const Color(0xFF3498DB)),
//         ),
//         child: Row(
//           children: [
//             const Icon(Icons.search, color: Color(0xFF3498DB), size: 20),
//             const SizedBox(width: 8),
//             Expanded(
//               child: TextField(
//                 onChanged: (value) {
//                   setState(() {
//                     _searchQuery = value;
//                     _filteredCompanies = _applySearchFilter(_allCompanies);
//                   });
//                 },
//                 decoration: const InputDecoration(
//                   hintText: 'ابحث عن شركة...',
//                   border: InputBorder.none,
//                   hintStyle: TextStyle(color: Colors.grey),
//                 ),
//               ),
//             ),
//             if (_searchQuery.isNotEmpty)
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _searchQuery = '';
//                     _filteredCompanies = _applySearchFilter(_allCompanies);
//                   });
//                 },
//                 child: const Icon(Icons.clear, size: 18, color: Colors.grey),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCompanyList() {
//     if (_isLoading) return const Center(child: CircularProgressIndicator());

//     return _filteredCompanies.isEmpty
//         ? Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.business, size: 80, color: Colors.grey[400]),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'لا توجد شركات',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           )
//         : ListView.builder(
//             padding: const EdgeInsets.all(8),
//             itemCount: _filteredCompanies.length,
//             itemBuilder: (context, index) {
//               final company = _filteredCompanies[index];
//               return _buildCompanyCard(company);
//             },
//           );
//   }

//   Widget _buildCompanyCard(Map<String, dynamic> company) {
//     final companyName = company['companyName'];
//     final companyId = company['companyId'];

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
//         leading: Container(
//           width: 45,
//           height: 45,
//           decoration: BoxDecoration(
//             color: Color(0xFF3498DB),
//             borderRadius: BorderRadius.circular(22.5),
//           ),
//           child: const Center(child: Icon(Icons.business, color: Colors.white)),
//         ),
//         title: Text(
//           companyName,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//             color: Color(0xFF2C3E50),
//           ),
//         ),
//         trailing: const Icon(
//           Icons.arrow_forward_ios,
//           color: Color(0xFF3498DB),
//           size: 16,
//         ),
//         onTap: () => _loadCompanyData(companyName, companyId),
//       ),
//     );
//   }

//   Widget _buildCompanySections() {
//     return Column(
//       children: [
//         // تبويبات الأقسام
//         _buildSectionTabs(),
//         Expanded(
//           child: _currentSection == 0
//               ? _buildWorkTable()
//               : _currentSection == 1
//               ? _buildCreateInvoiceSection()
//               : _buildInvoicesSection(),
//         ),
//       ],
//     );
//   }

//   Widget _buildSectionTabs() {
//     return Container(
//       color: Colors.white,
//       child: Row(
//         children: [
//           _buildSectionTab(0, Icons.list, 'شغل الشركات'),
//           _buildSectionTab(1, Icons.receipt, 'إنشاء فاتورة'),
//           _buildSectionTab(2, Icons.list_alt, 'الفواتير'),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionTab(int section, IconData icon, String title) {
//     final isActive = _currentSection == section;
//     return Expanded(
//       child: InkWell(
//         onTap: () => _changeSection(section),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             color: isActive ? const Color(0xFF3498DB) : Colors.white,
//             border: Border(
//               bottom: BorderSide(
//                 color: isActive ? const Color(0xFF3498DB) : Colors.grey[300]!,
//                 width: 3,
//               ),
//             ),
//           ),
//           child: Column(
//             children: [
//               Icon(
//                 icon,
//                 color: isActive ? Colors.white : Colors.grey,
//                 size: 22,
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: isActive ? Colors.white : Colors.grey,
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildWorkTable() {
//     if (_isLoading) return const Center(child: CircularProgressIndicator());

//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           color: Colors.blue[50],
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'جميع الرحلات',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF3498DB),
//                 ),
//               ),
//               Text(
//                 '${_companyWork.length} رحلة',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2E7D32),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: Container(
//             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
//             child: _companyWork.isEmpty
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(
//                           Icons.business,
//                           size: 60,
//                           color: Colors.grey,
//                         ),
//                         const SizedBox(height: 16),
//                         const Text(
//                           'لا يوجد شغل مسجل لهذه الشركة',
//                           style: TextStyle(
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
//                         defaultColumnWidth: const FixedColumnWidth(110),
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
//                               TableCellHeader('الحالة'),
//                               TableCellHeader('TR'),
//                               TableCellHeader('موقع الشركة'),
//                               TableCellHeader('عطلة الشركة'),
//                               TableCellHeader('مبيت الشركة'),
//                               TableCellHeader('نولون الشركة'),
//                               TableCellHeader('اسم السائق'),
//                               TableCellHeader('الكارتة'),
//                               TableCellHeader('العهدة'),
//                               TableCellHeader('اسم الموقع'),
//                               TableCellHeader('مكان التعتيق'),
//                               TableCellHeader('مكان التحميل'),
//                               TableCellHeader('التاريخ'),
//                               TableCellHeader('م'),
//                             ],
//                           ),
//                           ..._companyWork.asMap().entries.map((entry) {
//                             final index = entry.key;
//                             final work = entry.value;
//                             final hasInvoice = work['hasInvoice'];

//                             return TableRow(
//                               decoration: BoxDecoration(
//                                 color: index.isEven
//                                     ? Colors.white
//                                     : const Color(0xFFF8F9FA),
//                               ),
//                               children: [
//                                 TableCellBody(
//                                   hasInvoice ? 'مفوتورة' : 'متاحة',
//                                   textStyle: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: hasInvoice
//                                         ? Colors.red
//                                         : Colors.green,
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   work['tr'] ?? '-',
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF2C3E50),
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   work['companyLocationName'] ?? '-',
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF3498DB),
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   '${work['companyHoliday']} ج',
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.red,
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   '${work['companyOvernight']} ج',
//                                   textStyle: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.orange[700],
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   '${work['nolon']} ج',
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.green,
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   work['driverName'],
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF2C3E50),
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
//                           }).toList(),
//                         ],
//                       ),
//                     ),
//                   ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCreateInvoiceSection() {
//     if (_isLoading) return const Center(child: CircularProgressIndicator());

//     return _availableTripsForInvoice.isEmpty
//         ? Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.receipt, size: 80, color: Colors.grey),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'لا توجد رحلات متاحة للفاتورة',
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.grey,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   'جميع الرحلات تم عمل فاتورة لها',
//                   style: TextStyle(color: Colors.grey),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 30),
//                 ElevatedButton.icon(
//                   onPressed: () => _changeSection(0),
//                   icon: const Icon(Icons.list),
//                   label: const Text('عرض جميع الرحلات'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF3498DB),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           )
//         : Column(
//             children: [
//               // إحصائيات الرحلات المختارة
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 color: Colors.blue[50],
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'الرحلات المتاحة',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF3498DB),
//                           ),
//                         ),
//                         Text(
//                           '${_availableTripsForInvoice.length} رحلة متاحة للفاتورة',
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF2E7D32),
//                           ),
//                         ),
//                       ],
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         const Text(
//                           'الرحلات المختارة',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF3498DB),
//                           ),
//                         ),
//                         Text(
//                           '${_selectedTripsForInvoice.length} من ${_availableTripsForInvoice.length}',
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF2E7D32),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               // اسم الفاتورة
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: TextField(
//                   controller: _invoiceNameController,
//                   decoration: InputDecoration(
//                     labelText: 'اسم الفاتورة',
//                     prefixIcon: const Icon(Icons.receipt),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                 ),
//               ),

//               // أزرار التحكم
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () => _selectAllTrips(true),
//                         icon: const Icon(Icons.check_box),
//                         label: const Text('تحديد الكل'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green[50],
//                           foregroundColor: Colors.green[700],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () => _selectAllTrips(false),
//                         icon: const Icon(Icons.check_box_outline_blank),
//                         label: const Text('إلغاء الكل'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red[50],
//                           foregroundColor: Colors.red[700],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // تفاصيل المبالغ المختارة
//               if (_selectedTripsForInvoice.isNotEmpty)
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   margin: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.green[50],
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.green),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       Column(
//                         children: [
//                           Text(
//                             _formatCurrency(_calculateNolonTotal()),
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.green,
//                             ),
//                           ),
//                           const Text(
//                             'إجمالي النولون',
//                             style: TextStyle(fontSize: 12, color: Colors.green),
//                           ),
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           Text(
//                             _formatCurrency(_calculateOvernightTotal()),
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.orange,
//                             ),
//                           ),
//                           const Text(
//                             'إجمالي المبيت',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.orange,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           Text(
//                             _formatCurrency(_calculateHolidayTotal()),
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.red,
//                             ),
//                           ),
//                           const Text(
//                             'إجمالي العطلة',
//                             style: TextStyle(fontSize: 12, color: Colors.red),
//                           ),
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           Text(
//                             _formatCurrency(_calculateInvoiceTotal()),
//                             style: const TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF2E7D32),
//                             ),
//                           ),
//                           const Text(
//                             'الإجمالي الكلي',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Color(0xFF2E7D32),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//               // جدول الرحلات المتاحة مع خيار التحديد
//               Expanded(
//                 child: Container(
//                   margin: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.vertical,
//                       child: Table(
//                         defaultColumnWidth: const FixedColumnWidth(110),
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
//                               TableCellHeader('تحديد'),
//                               TableCellHeader('TR'),
//                               TableCellHeader('موقع الشركة'),
//                               TableCellHeader('عطلة الشركة'),
//                               TableCellHeader('مبيت الشركة'),
//                               TableCellHeader('نولون الشركة'),
//                               TableCellHeader('اسم السائق'),
//                               TableCellHeader('الكارتة'),
//                               TableCellHeader('العهدة'),
//                               TableCellHeader('اسم الموقع'),
//                               TableCellHeader('مكان التعتيق'),
//                               TableCellHeader('مكان التحميل'),
//                               TableCellHeader('التاريخ'),
//                               TableCellHeader('م'),
//                             ],
//                           ),
//                           ..._availableTripsForInvoice.asMap().entries.map((
//                             entry,
//                           ) {
//                             final index = entry.key;
//                             final work = entry.value;
//                             final isSelected = _selectedTripsForInvoice.any(
//                               (trip) => trip['id'] == work['id'],
//                             );

//                             return TableRow(
//                               decoration: BoxDecoration(
//                                 color: isSelected
//                                     ? const Color(0xFFE8F5E9)
//                                     : index.isEven
//                                     ? Colors.white
//                                     : const Color(0xFFF8F9FA),
//                               ),
//                               children: [
//                                 TableCell(
//                                   child: Container(
//                                     height: 48,
//                                     alignment: Alignment.center,
//                                     child: Checkbox(
//                                       value: isSelected,
//                                       onChanged: (value) {
//                                         _toggleTripSelection(
//                                           work,
//                                           value ?? false,
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   work['tr'] ?? '-',
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF2C3E50),
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   work['companyLocationName'] ?? '-',
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF3498DB),
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   '${work['companyHoliday']} ج',
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.red,
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   '${work['companyOvernight']} ج',
//                                   textStyle: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.orange[700],
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   '${work['nolon']} ج',
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.green,
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   work['driverName'],
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF2C3E50),
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
//                           }).toList(),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//               // زر إنشاء الفاتورة
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton.icon(
//                     onPressed:
//                         _selectedTripsForInvoice.isEmpty || _isCreatingInvoice
//                         ? null
//                         : _createInvoice,
//                     icon: _isCreatingInvoice
//                         ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                             ),
//                           )
//                         : const Icon(Icons.save),
//                     label: Text(
//                       _isCreatingInvoice ? 'جاري الإنشاء...' : 'إنشاء الفاتورة',
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF2E7D32),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//   }

//   Widget _buildInvoicesSection() {
//     if (_isLoading) return const Center(child: CircularProgressIndicator());

//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(16),
//           color: Colors.blue[50],
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'فواتير الشركة',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF3498DB),
//                 ),
//               ),
//               Text(
//                 '${_companyInvoices.length} فاتورة',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2E7D32),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: _companyInvoices.isEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(
//                         Icons.receipt_long,
//                         size: 80,
//                         color: Colors.grey,
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         'لا توجد فواتير',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.grey,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       const Text(
//                         'قم بإنشاء فاتورة أولاً',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                       const SizedBox(height: 30),
//                       ElevatedButton.icon(
//                         onPressed: () => _changeSection(1),
//                         icon: const Icon(Icons.add),
//                         label: const Text('إنشاء فاتورة'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF3498DB),
//                           foregroundColor: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : ListView.builder(
//                   padding: const EdgeInsets.all(8),
//                   itemCount: _companyInvoices.length,
//                   itemBuilder: (context, index) {
//                     final invoice = _companyInvoices[index];
//                     return _buildInvoiceCard(invoice, index);
//                   },
//                 ),
//         ),
//       ],
//     );
//   }

//   Widget _buildInvoiceCard(Map<String, dynamic> invoice, int index) {
//     final createdAt = invoice['createdAt'] as DateTime?;
//     final invoiceTrips = invoice['invoiceTrips'] as List<Map<String, dynamic>>;

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[300]!),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ExpansionTile(
//         leading: CircleAvatar(
//           backgroundColor: const Color(0xFF3498DB),
//           child: Text(
//             '${index + 1}',
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         title: Text(
//           invoice['name'],
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//             color: Color(0xFF2C3E50),
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '${invoice['tripCount']} رحلة - ${createdAt != null ? _formatDate(createdAt) : 'غير معروف'}',
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//           ],
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   _formatCurrency(invoice['totalAmount']),
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Color(0xFF2E7D32),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'إجمالي',
//                   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//             const SizedBox(width: 10),
//             IconButton(
//               icon: Icon(Icons.print, color: Color(0xFF3498DB)),
//               onPressed: _isGeneratingPDF ? null : () => _printInvoice(invoice),
//             ),
//           ],
//         ),
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // إحصائيات الفاتورة
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.blue[50],
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'عدد الرحلات:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             '${invoice['tripCount']}',
//                             style: const TextStyle(color: Color(0xFF3498DB)),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'إجمالي النولون:',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.green,
//                             ),
//                           ),
//                           Text(
//                             _formatCurrency(invoice['nolonTotal']),
//                             style: const TextStyle(color: Colors.green),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'إجمالي المبيت:',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.orange,
//                             ),
//                           ),
//                           Text(
//                             _formatCurrency(invoice['overnightTotal']),
//                             style: const TextStyle(color: Colors.orange),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'إجمالي العطلة:',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.red,
//                             ),
//                           ),
//                           Text(
//                             _formatCurrency(invoice['holidayTotal']),
//                             style: const TextStyle(color: Colors.red),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 12),

//                 // زر طباعة الفاتورة
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: _isGeneratingPDF
//                         ? null
//                         : () => _printInvoice(invoice),
//                     icon: _isGeneratingPDF
//                         ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                             ),
//                           )
//                         : const Icon(Icons.print),
//                     label: Text(
//                       _isGeneratingPDF ? 'جاري الطباعة...' : 'طباعة الفاتورة',
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFF2E7D32),
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 12),

//                 // تفاصيل الرحلات
//                 const Text(
//                   'تفاصيل الرحلات:',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF2C3E50),
//                   ),
//                 ),
//                 const SizedBox(height: 8),

//                 // جدول تفاصيل الرحلات
//                 if (invoiceTrips.isNotEmpty)
//                   SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Table(
//                       defaultColumnWidth: const FixedColumnWidth(150),
//                       border: TableBorder.all(
//                         color: Colors.grey[300]!,
//                         width: 1,
//                       ),
//                       children: [
//                         TableRow(
//                           decoration: BoxDecoration(color: Colors.grey[100]),
//                           children: const [
//                             TableCellHeader('اسم الموقع'),
//                             TableCellHeader('TR'),
//                             TableCellHeader('موقع الشركة'),
//                             TableCellHeader('النولون'),
//                             TableCellHeader('المبيت'),
//                             TableCellHeader('العطلة'),
//                           ],
//                         ),
//                         ...invoiceTrips.map((trip) {
//                           return TableRow(
//                             decoration: BoxDecoration(color: Colors.white),
//                             children: [
//                               TableCellBody(
//                                 trip['selectedRoute'] ?? '',
//                                 textStyle: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF3498DB),
//                                 ),
//                               ),
//                               TableCellBody(
//                                 trip['tr'] ?? '-',
//                                 textStyle: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF2C3E50),
//                                 ),
//                               ),
//                               TableCellBody(
//                                 trip['companyLocationName'] ?? '-',
//                                 textStyle: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF3498DB),
//                                 ),
//                               ),
//                               TableCellBody(
//                                 _formatCurrency(trip['nolon']),
//                                 textStyle: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green,
//                                 ),
//                               ),
//                               TableCellBody(
//                                 _formatCurrency(trip['companyOvernight']),
//                                 textStyle: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.orange,
//                                 ),
//                               ),
//                               TableCellBody(
//                                 _formatCurrency(trip['companyHoliday']),
//                                 textStyle: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.red,
//                                 ),
//                               ),
//                             ],
//                           );
//                         }).toList(),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   double _calculateInvoiceTotal() {
//     double total = 0;
//     for (var trip in _selectedTripsForInvoice) {
//       total +=
//           trip['nolon'] + trip['companyOvernight'] + trip['companyHoliday'];
//     }
//     return total;
//   }

//   double _calculateNolonTotal() {
//     double total = 0;
//     for (var trip in _selectedTripsForInvoice) {
//       total += trip['nolon'];
//     }
//     return total;
//   }

//   double _calculateOvernightTotal() {
//     double total = 0;
//     for (var trip in _selectedTripsForInvoice) {
//       total += trip['companyOvernight'];
//     }
//     return total;
//   }

//   double _calculateHolidayTotal() {
//     double total = 0;
//     for (var trip in _selectedTripsForInvoice) {
//       total += trip['companyHoliday'];
//     }
//     return total;
//   }
// }

// class TableCellHeader extends StatelessWidget {
//   final String text;
//   const TableCellHeader(this.text, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 40,
//       alignment: Alignment.center,
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 12,
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
//       height: 38,
//       alignment: Alignment.center,
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       child: Text(
//         text,
//         maxLines: 2,
//         overflow: TextOverflow.ellipsis,
//         textAlign: TextAlign.center,
//         style: textStyle ?? const TextStyle(fontSize: 12),
//       ),
//     );
//   }
// // }
// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:pdf/pdf.dart' as pdfLib;
// import 'package:pdf/widgets.dart' as pdfLib;
// import 'package:printing/printing.dart';
// import 'package:flutter/services.dart' show rootBundle;

// class CompanyWorkPage extends StatefulWidget {
//   const CompanyWorkPage({super.key});

//   @override
//   State<CompanyWorkPage> createState() => _CompanyWorkPageState();
// }

// class _CompanyWorkPageState extends State<CompanyWorkPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   pdfLib.Font? _arabicFont;

//   // متغيرات عامة
//   List<Map<String, dynamic>> _allCompanies = [];
//   List<Map<String, dynamic>> _filteredCompanies = [];
//   String? _selectedCompany;
//   String? _selectedCompanyId;
//   bool _isLoading = false;
//   String _searchQuery = '';

//   // متغيرات الأقسام بعد اختيار الشركة
//   int _currentSection = 0; // 0: شغل الشركات، 1: إنشاء فاتورة، 2: الفواتير
//   List<Map<String, dynamic>> _companyWork = []; // جميع الرحلات
//   List<Map<String, dynamic>> _availableTripsForInvoice =
//       []; // الرحلات المتاحة للفاتورة
//   List<Map<String, dynamic>> _companyInvoices = []; // فواتير الشركة

//   // متغيرات قسم إنشاء الفاتورة
//   final List<Map<String, dynamic>> _selectedTripsForInvoice = [];
//   final TextEditingController _invoiceNameController = TextEditingController();
//   bool _isCreatingInvoice = false;
//   bool _isGeneratingPDF = false;

//   // متغير للمزامنة التلقائية
//   bool _hasSyncedOnEnter = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadCompanies();
//     _loadArabicFont();
//   }

//   // ================================
//   // تحميل الخط العربي للطباعة
//   // ================================
//   Future<void> _loadArabicFont() async {
//     try {
//       final fontData = await rootBundle.load(
//         'assets/fonts/Amiri/Amiri-Regular.ttf',
//       );

//       _arabicFont = pdfLib.Font.ttf(fontData);
//       debugPrint('تم تحميل الخط العربي بنجاح');
//     } catch (e) {
//       debugPrint('فشل تحميل الخط العربي: $e');
//       _arabicFont = pdfLib.Font.courier();
//     }
//   }

//   // ================================
//   // نظام مزامنة companySummaries تلقائياً
//   // ================================
//   Future<void> _syncDataOnPageEnter() async {
//     debugPrint('🔄 بدء التحديث التلقائي لحسابات الشركات...');

//     try {
//       // 1. جلب جميع حسابات الشركات
//       final companySummaries = await _firestore
//           .collection('companySummaries')
//           .get();

//       // 2. حساب إجمالي الرحلات من dailyWork لكل شركة
//       final dailyWorkSnapshot = await _firestore.collection('dailyWork').get();

//       Map<String, int> dailyWorkTripCounts = {};
//       Map<String, double> dailyWorkTotalDebts = {};
//       Map<String, String> companyNames = {};

//       for (final doc in dailyWorkSnapshot.docs) {
//         final data = doc.data();
//         final companyId = data['companyId'] as String?;
//         final companyName = data['companyName'] as String?;

//         if (companyId != null && companyName != null) {
//           // حساب عدد الرحلات
//           dailyWorkTripCounts[companyId] =
//               (dailyWorkTripCounts[companyId] ?? 0) + 1;
//           companyNames[companyId] = companyName;

//           // حساب إجمالي الدين
//           final nolon = (data['nolon'] ?? data['noLon'] ?? 0).toDouble();
//           final overnight = (data['companyOvernight'] ?? 0).toDouble();
//           final holiday = (data['companyHoliday'] ?? 0).toDouble();

//           dailyWorkTotalDebts[companyId] =
//               (dailyWorkTotalDebts[companyId] ?? 0.0) +
//               nolon +
//               overnight +
//               holiday;
//         }
//       }

//       // 3. المقارنة والتحديث
//       final batch = _firestore.batch();
//       final summariesRef = _firestore.collection('companySummaries');

//       int updatedCount = 0;

//       for (final entry in dailyWorkTripCounts.entries) {
//         final companyId = entry.key;
//         final dailyWorkTrips = entry.value;
//         final companyName = companyNames[companyId] ?? 'غير معروف';
//         final totalDebt = dailyWorkTotalDebts[companyId] ?? 0.0;

//         // البحث عن حساب الشركة
//         DocumentSnapshot? summaryDoc;
//         for (final doc in companySummaries.docs) {
//           final data = doc.data();
//           if (doc.id == companyId || data['companyId'] == companyId) {
//             summaryDoc = doc;
//             break;
//           }
//         }

//         if (summaryDoc != null && summaryDoc.exists) {
//           // تحقق من عدد الرحلات
//           final summaryData = summaryDoc.data() as Map<String, dynamic>;
//           final summaryTrips = (summaryData['totalTrips'] ?? 0).toInt();
//           final summaryDebt = (summaryData['totalCompanyDebt'] ?? 0).toDouble();

//           // إذا كان عدد الرحلات أو المبلغ غير متطابق
//           if (dailyWorkTrips != summaryTrips || totalDebt != summaryDebt) {
//             final totalPaidAmount = (summaryData['totalPaidAmount'] ?? 0)
//                 .toDouble();
//             final totalRemaining = totalDebt - totalPaidAmount;

//             String status;
//             if (totalRemaining <= 0) {
//               status = 'منتهية';
//             } else if (totalPaidAmount > 0) {
//               status = 'شبه منتهية';
//             } else {
//               status = 'جارية';
//             }

//             batch.set(summariesRef.doc(companyId), {
//               'companyId': companyId,
//               'companyName': companyName,
//               'totalCompanyDebt': totalDebt,
//               'totalPaidAmount': totalPaidAmount,
//               'totalRemainingAmount': totalRemaining,
//               'totalTrips': dailyWorkTrips,
//               'status': status,
//               'lastUpdated': Timestamp.now(),
//             }, SetOptions(merge: true));

//             updatedCount++;
//           }
//         } else {
//           // الشركة ليس لها حساب، إنشاء حساب جديد
//           batch.set(summariesRef.doc(companyId), {
//             'companyId': companyId,
//             'companyName': companyName,
//             'totalCompanyDebt': totalDebt,
//             'totalPaidAmount': 0.0,
//             'totalRemainingAmount': totalDebt,
//             'totalTrips': dailyWorkTrips,
//             'status': 'جارية',
//             'lastUpdated': Timestamp.now(),
//           });

//           updatedCount++;
//         }
//       }

//       // 4. حذف حسابات الشركات التي ليس لها رحلات
//       for (final doc in companySummaries.docs) {
//         final companyId = doc.id;
//         if (!dailyWorkTripCounts.containsKey(companyId)) {
//           final data = doc.data();
//           final dataCompanyId = data['companyId'] as String?;

//           // إذا الشركة ليس لها رحلات في dailyWork
//           if (!dailyWorkTripCounts.containsKey(dataCompanyId ?? '')) {
//             // يمكنك اختيار حذفها أو تركها
//             // batch.delete(summariesRef.doc(companyId));
//             debugPrint(
//               '⚠️ الشركة ${data['companyName']} ليس لها رحلات في dailyWork',
//             );
//           }
//         }
//       }

//       if (updatedCount > 0) {
//         await batch.commit();
//         debugPrint('✅ تم تحديث $updatedCount حساب شركة تلقائياً');
//         _showSuccess('تم تحديث حسابات $updatedCount شركة تلقائياً');
//       } else {
//         debugPrint('✅ جميع الحسابات محدثة بالفعل');
//       }
//     } catch (e) {
//       debugPrint('❌ خطأ في التحديث التلقائي: $e');
//       _showError('خطأ في تحديث الحسابات: $e');
//     }
//   }

//   // ================================
//   // تحميل بيانات الشركات مع الإحصائيات
//   // ================================
//   Future<void> _loadCompanies() async {
//     setState(() => _isLoading = true);
//     try {
//       final companiesSnapshot = await _firestore.collection('companies').get();
//       final dailyWorkSnapshot = await _firestore.collection('dailyWork').get();

//       final List<Map<String, dynamic>> companiesList = [];

//       for (final companyDoc in companiesSnapshot.docs) {
//         final companyData = companyDoc.data();
//         final companyId = companyDoc.id;
//         final companyName =
//             (companyData['name'] ??
//                     companyData['companyName'] ??
//                     'شركة غير معروفة')
//                 .toString()
//                 .trim();

//         // حساب الرحلات والإحصائيات
//         final companyTrips = dailyWorkSnapshot.docs
//             .where((doc) {
//               final data = doc.data();
//               final tripCompanyId = data['companyId'] ?? '';
//               return tripCompanyId == companyId;
//             })
//             .map((doc) {
//               final data = doc.data();
//               final tripDate = (data['date'] as Timestamp?)?.toDate();

//               return {
//                 'id': doc.id,
//                 'date': tripDate,
//                 'nolon': (data['noLon'] ?? data['nolon'] ?? 0).toDouble(),
//                 'companyOvernight': (data['companyOvernight'] ?? 0).toDouble(),
//                 'companyHoliday': (data['companyHoliday'] ?? 0).toDouble(),
//               };
//             })
//             .toList();

//         // حساب الإجماليات
//         double totalNolon = 0.0;
//         double totalOvernight = 0.0;
//         double totalHoliday = 0.0;

//         for (var trip in companyTrips) {
//           totalNolon += trip['nolon'];
//           totalOvernight += trip['companyOvernight'];
//           totalHoliday += trip['companyHoliday'];
//         }

//         companiesList.add({
//           'companyId': companyId,
//           'companyName': companyName,
//           'companyData': companyData,
//           'totalTrips': companyTrips.length,
//           'totalNolon': totalNolon,
//           'totalOvernight': totalOvernight,
//           'totalHoliday': totalHoliday,
//         });
//       }

//       companiesList.sort(
//         (a, b) => a['companyName'].compareTo(b['companyName']),
//       );

//       setState(() {
//         _allCompanies = companiesList;
//         _filteredCompanies = _applySearchFilter(companiesList);
//         _isLoading = false;
//       });

//       // تحديث تلقائي عند دخول الصفحة الرئيسية فقط
//       if (!_hasSyncedOnEnter && _selectedCompany == null) {
//         await _syncDataOnPageEnter();
//         _hasSyncedOnEnter = true;
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       debugPrint('خطأ في تحميل بيانات الشركات: $e');
//       _showError('خطأ في تحميل الشركات: $e');
//     }
//   }

//   // ================================
//   // تحميل بيانات الشركة المختارة
//   // ================================
//   Future<void> _loadCompanyData(String companyName, String companyId) async {
//     setState(() {
//       _selectedCompany = companyName;
//       _selectedCompanyId = companyId;
//       _isLoading = true;
//       _companyWork.clear();
//       _availableTripsForInvoice.clear();
//       _companyInvoices.clear();
//       _selectedTripsForInvoice.clear();
//       _invoiceNameController.clear();
//     });

//     try {
//       // 1. تحميل جميع رحلات الشركة من dailyWork
//       final workSnapshot = await _firestore
//           .collection('dailyWork')
//           .where('companyId', isEqualTo: companyId)
//           .orderBy('date', descending: true)
//           .get();

//       final List<Map<String, dynamic>> allTrips = [];

//       for (final doc in workSnapshot.docs) {
//         final data = doc.data();
//         final tripDate = (data['date'] as Timestamp?)?.toDate();

//         allTrips.add({
//           'id': doc.id,
//           'date': tripDate,
//           'companyName': companyName,
//           'companyId': companyId,
//           'driverName': data['driverName'] ?? 'غير معروف',
//           'nolon': (data['noLon'] ?? data['nolon'] ?? 0).toDouble(),
//           'companyOvernight': (data['companyOvernight'] ?? 0).toDouble(),
//           'companyHoliday': (data['companyHoliday'] ?? 0).toDouble(),
//           'selectedPrice': (data['selectedPrice'] ?? 0).toDouble(),
//           'karta': data['karta'] ?? '',
//           'ohda': data['ohda'] ?? '',
//           'selectedRoute': data['selectedRoute'] ?? '',
//           'loadingLocation': data['loadingLocation'] ?? '',
//           'unloadingLocation': data['unloadingLocation'] ?? '',
//           'vehicleType': data['selectedVehicleType'] ?? '',
//           'notes': data['selectedNotes'] ?? '',
//           'tr': data['tr'] ?? '',
//           'companyLocationName': data['companyLocationName'] ?? '',
//           'hasInvoice': false,
//         });
//       }

//       // 2. تحميل فواتير الشركة
//       final invoicesSnapshot = await _firestore
//           .collection('invoices')
//           .where('companyId', isEqualTo: companyId)
//           .orderBy('createdAt', descending: true)
//           .get();

//       final List<Map<String, dynamic>> invoicesList = [];
//       final List<String> invoicedTripIds = [];

//       for (final doc in invoicesSnapshot.docs) {
//         final data = doc.data();
//         final tripIds = (data['tripIds'] as List<dynamic>? ?? []);

//         // جمع ID الرحلات التي تم عمل فاتورة لها
//         for (var tripId in tripIds) {
//           invoicedTripIds.add(tripId.toString());
//         }

//         // جلب تفاصيل الرحلات للفاتورة
//         List<Map<String, dynamic>> invoiceTrips = [];
//         double totalNolon = 0;
//         double totalOvernight = 0;
//         double totalHoliday = 0;

//         for (var tripId in tripIds) {
//           final tripDoc = await _firestore
//               .collection('dailyWork')
//               .doc(tripId.toString())
//               .get();
//           if (tripDoc.exists) {
//             final tripData = tripDoc.data() as Map<String, dynamic>;
//             invoiceTrips.add({
//               'selectedRoute': tripData['selectedRoute'] ?? '',
//               'nolon': (tripData['noLon'] ?? tripData['nolon'] ?? 0).toDouble(),
//               'companyOvernight': (tripData['companyOvernight'] ?? 0)
//                   .toDouble(),
//               'companyHoliday': (tripData['companyHoliday'] ?? 0).toDouble(),
//               'tr': tripData['tr'] ?? '',
//               'companyLocationName': tripData['companyLocationName'] ?? '',
//             });

//             totalNolon += (tripData['noLon'] ?? tripData['nolon'] ?? 0)
//                 .toDouble();
//             totalOvernight += (tripData['companyOvernight'] ?? 0).toDouble();
//             totalHoliday += (tripData['companyHoliday'] ?? 0).toDouble();
//           }
//         }

//         invoicesList.add({
//           'id': doc.id,
//           'name': data['name'] ?? 'فاتورة بدون اسم',
//           'companyName': data['companyName'] ?? 'شركة غير معروفة',
//           'totalAmount': (data['totalAmount'] ?? 0).toDouble(),
//           'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
//           'tripIds': tripIds,
//           'tripCount': tripIds.length,
//           'invoiceTrips': invoiceTrips,
//           'nolonTotal': totalNolon,
//           'overnightTotal': totalOvernight,
//           'holidayTotal': totalHoliday,
//         });
//       }

//       // 3. تحديث الرحلات لمعرفة أيها تم عمل فاتورة له
//       for (var trip in allTrips) {
//         trip['hasInvoice'] = invoicedTripIds.contains(trip['id']);
//       }

//       // 4. فصل الرحلات: المتاحة للفاتورة (التي ليس لها فاتورة)
//       final availableTrips = allTrips
//           .where((trip) => !trip['hasInvoice'])
//           .toList();

//       setState(() {
//         _companyWork = allTrips;
//         _availableTripsForInvoice = availableTrips;
//         _companyInvoices = invoicesList;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showError('خطأ في تحميل بيانات الشركة: $e');
//     }
//   }

//   // ================================
//   // دوال التصفية والبحث
//   // ================================
//   List<Map<String, dynamic>> _applySearchFilter(
//     List<Map<String, dynamic>> companies,
//   ) {
//     if (_searchQuery.isEmpty) return companies;
//     return companies
//         .where(
//           (c) => c['companyName'].toLowerCase().contains(
//             _searchQuery.toLowerCase(),
//           ),
//         )
//         .toList();
//   }

//   // ================================
//   // دوال قسم إنشاء الفاتورة
//   // ================================
//   void _toggleTripSelection(Map<String, dynamic> trip, bool selected) {
//     setState(() {
//       if (selected) {
//         _selectedTripsForInvoice.add(trip);
//       } else {
//         _selectedTripsForInvoice.removeWhere((t) => t['id'] == trip['id']);
//       }
//     });
//   }

//   void _selectAllTrips(bool select) {
//     setState(() {
//       if (select) {
//         _selectedTripsForInvoice.clear();
//         _selectedTripsForInvoice.addAll(_availableTripsForInvoice);
//       } else {
//         _selectedTripsForInvoice.clear();
//       }
//     });
//   }

//   Future<void> _createInvoice() async {
//     if (_selectedTripsForInvoice.isEmpty) {
//       _showError('يرجى اختيار رحلات لإنشاء الفاتورة');
//       return;
//     }

//     if (_invoiceNameController.text.isEmpty) {
//       _showError('يرجى إدخال اسم الفاتورة');
//       return;
//     }

//     setState(() => _isCreatingInvoice = true);

//     try {
//       // حساب إجمالي المبالغ
//       double totalNolon = 0;
//       double totalOvernight = 0;
//       double totalHoliday = 0;
//       List<String> tripIds = [];
//       List<Map<String, dynamic>> invoiceTripDetails = [];

//       for (var trip in _selectedTripsForInvoice) {
//         totalNolon += trip['nolon'];
//         totalOvernight += trip['companyOvernight'];
//         totalHoliday += trip['companyHoliday'];
//         tripIds.add(trip['id']);

//         invoiceTripDetails.add({
//           'selectedRoute': trip['selectedRoute'],
//           'nolon': trip['nolon'],
//           'companyOvernight': trip['companyOvernight'],
//           'companyHoliday': trip['companyHoliday'],
//           'tr': trip['tr'],
//           'companyLocationName': trip['companyLocationName'],
//           'date': trip['date'],
//         });
//       }

//       double totalAmount = totalNolon + totalOvernight + totalHoliday;

//       // حفظ الفاتورة
//       await _firestore.collection('invoices').add({
//         'name': _invoiceNameController.text.trim(),
//         'companyName': _selectedCompany!,
//         'companyId': _selectedCompanyId!,
//         'totalAmount': totalAmount,
//         'nolonTotal': totalNolon,
//         'overnightTotal': totalOvernight,
//         'holidayTotal': totalHoliday,
//         'tripIds': tripIds,
//         'tripDetails': invoiceTripDetails,
//         'tripCount': tripIds.length,
//         'createdAt': Timestamp.now(),
//         'status': 'غير مدفوعة',
//       });

//       // تحديث حالة الرحلات في dailyWork
//       final batch = _firestore.batch();
//       for (var tripId in tripIds) {
//         batch.update(_firestore.collection('dailyWork').doc(tripId), {
//           'hasInvoice': true,
//         });
//       }
//       await batch.commit();

//       // تحديث حساب الشركة في companySummaries
//       await _updateCompanySummaryAfterInvoice(totalAmount);

//       _showSuccess('تم إنشاء الفاتورة بنجاح');

//       // إعادة تحميل بيانات الشركة
//       await _loadCompanyData(_selectedCompany!, _selectedCompanyId!);

//       // تنظيف المتغيرات
//       _selectedTripsForInvoice.clear();
//       _invoiceNameController.clear();

//       // الذهاب إلى قسم الفواتير
//       _changeSection(2);
//     } catch (e) {
//       _showError('خطأ في إنشاء الفاتورة: $e');
//     } finally {
//       setState(() => _isCreatingInvoice = false);
//     }
//   }

//   // ================================
//   // تحديث حساب الشركة بعد إنشاء الفاتورة
//   // ================================
//   Future<void> _updateCompanySummaryAfterInvoice(double invoiceAmount) async {
//     try {
//       final summaryRef = _firestore
//           .collection('companySummaries')
//           .doc(_selectedCompanyId!);

//       final summaryDoc = await summaryRef.get();

//       if (summaryDoc.exists) {
//         final data = summaryDoc.data() as Map<String, dynamic>;
//         final currentTotalPaid = (data['totalPaidAmount'] ?? 0).toDouble();
//         final newTotalPaid = currentTotalPaid + invoiceAmount;
//         final totalDebt = (data['totalCompanyDebt'] ?? 0).toDouble();
//         final totalRemaining = totalDebt - newTotalPaid;

//         String status;
//         if (totalRemaining <= 0) {
//           status = 'منتهية';
//         } else if (newTotalPaid > 0) {
//           status = 'شبه منتهية';
//         } else {
//           status = 'جارية';
//         }

//         await summaryRef.update({
//           'totalPaidAmount': newTotalPaid,
//           'totalRemainingAmount': totalRemaining,
//           'status': status,
//           'lastUpdated': Timestamp.now(),
//         });

//         debugPrint('✅ تم تحديث حساب الشركة بعد إنشاء الفاتورة');
//       }
//     } catch (e) {
//       debugPrint('⚠️ خطأ في تحديث حساب الشركة بعد الفاتورة: $e');
//     }
//   }

//   // ================================
//   // دوال مساعدة
//   // ================================
//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.red),
//     );
//   }

//   void _showSuccess(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.green),
//     );
//   }

//   String _formatDate(DateTime? date) {
//     if (date == null) return '-';
//     return DateFormat('dd/MM/yyyy').format(date);
//   }

//   String _formatCurrency(double amount) {
//     return '${amount.toStringAsFixed(2)} ج';
//   }

//   String _formatCurrencyForPDF(double amount) {
//     return amount.toStringAsFixed(2);
//   }

//   void _changeSection(int section) {
//     setState(() {
//       _currentSection = section;
//       if (section == 1) {
//         _selectedTripsForInvoice.clear();
//         _invoiceNameController.clear();
//       }
//     });
//   }

//   void _backToCompanies() {
//     setState(() {
//       _selectedCompany = null;
//       _selectedCompanyId = null;
//       _companyWork.clear();
//       _availableTripsForInvoice.clear();
//       _companyInvoices.clear();
//       _selectedTripsForInvoice.clear();
//       _invoiceNameController.clear();
//       _hasSyncedOnEnter = false; // إعادة تعيين لعند الدخول التالي
//     });
//     _loadCompanies();
//   }

//   // ================================
//   // دوال الطباعة
//   // ================================
//   Future<void> _printInvoice(Map<String, dynamic> invoice) async {
//     if (_arabicFont == null) {
//       await _loadArabicFont();
//       if (_arabicFont == null) {
//         _showError('تعذر تحميل الخط العربي');
//         return;
//       }
//     }

//     setState(() => _isGeneratingPDF = true);

//     try {
//       final invoiceTrips =
//           invoice['invoiceTrips'] as List<Map<String, dynamic>>;
//       final companyName = invoice['companyName'] ?? 'غير معروف';
//       final invoiceName = invoice['name'] ?? 'فاتورة';
//       final invoiceId = invoice['id'] ?? '';
//       final createdAt = invoice['createdAt'] as DateTime?;
//       final companyLocationName = _getCompanyLocationName(invoiceTrips);

//       final groupedTrips = _groupTripsForInvoice(invoiceTrips);

//       final pdf = pdfLib.Document(
//         theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
//       );

//       pdf.addPage(
//         pdfLib.Page(
//           pageFormat: pdfLib.PdfPageFormat.a4,
//           margin: pdfLib.EdgeInsets.all(20),
//           build: (context) {
//             return pdfLib.Directionality(
//               textDirection: pdfLib.TextDirection.rtl,
//               child: pdfLib.Column(
//                 crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
//                 children: [
//                   _buildInvoiceHeader(
//                     companyName,
//                     invoiceId,
//                     createdAt,
//                     companyLocationName,
//                   ),
//                   pdfLib.SizedBox(height: 20),
//                   _buildInvoiceTable(groupedTrips),
//                   pdfLib.Spacer(),
//                   _buildInvoiceTotals(invoice),
//                 ],
//               ),
//             );
//           },
//         ),
//       );

//       await Printing.layoutPdf(
//         onLayout: (pdfLib.PdfPageFormat format) async => pdf.save(),
//         name:
//             'فاتورة_${invoiceName}_${DateFormat('yyyyMMdd').format(createdAt ?? DateTime.now())}',
//       );

//       _showSuccess('تم طباعة الفاتورة بنجاح');
//     } catch (e) {
//       _showError('خطأ في طباعة الفاتورة: $e');
//       debugPrint('خطأ في طباعة الفاتورة: $e');
//     } finally {
//       setState(() => _isGeneratingPDF = false);
//     }
//   }

//   pdfLib.Widget _buildInvoiceHeader(
//     String companyName,
//     String invoiceId,
//     DateTime? createdAt,
//     String companyLocationName,
//   ) {
//     return pdfLib.Column(
//       children: [
//         // الصف الأول: الشعار والفاتورة والتاريخ
//         pdfLib.Row(
//           mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
//           children: [
//             // الشعار على اليسار
//             pdfLib.Container(
//               width: 80,
//               height: 80,
//               child: pdfLib.Column(
//                 mainAxisAlignment: pdfLib.MainAxisAlignment.center,
//                 children: [
//                   pdfLib.Container(
//                     width: 60,
//                     height: 60,
//                     decoration: pdfLib.BoxDecoration(
//                       shape: pdfLib.BoxShape.circle,
//                       color: pdfLib.PdfColors.black,
//                     ),
//                   ),
//                   pdfLib.SizedBox(height: 5),
//                   pdfLib.Text(
//                     'New grand',
//                     style: pdfLib.TextStyle(
//                       fontSize: 12,
//                       fontWeight: pdfLib.FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // معلومات الفاتورة في المنتصف
//             pdfLib.Expanded(
//               child: pdfLib.Column(
//                 crossAxisAlignment: pdfLib.CrossAxisAlignment.center,
//                 children: [
//                   pdfLib.Row(
//                     mainAxisAlignment: pdfLib.MainAxisAlignment.center,
//                     children: [
//                       pdfLib.Text(
//                         'فاتورة ',
//                         style: pdfLib.TextStyle(
//                           fontSize: 18,
//                           fontWeight: pdfLib.FontWeight.bold,
//                           font: _arabicFont,
//                           decoration: pdfLib.TextDecoration.underline,
//                         ),
//                       ),
//                       pdfLib.Text(
//                         invoiceId,
//                         style: pdfLib.TextStyle(
//                           fontSize: 18,
//                           fontWeight: pdfLib.FontWeight.bold,
//                           font: _arabicFont,
//                           decoration: pdfLib.TextDecoration.underline,
//                         ),
//                       ),
//                     ],
//                   ),
//                   pdfLib.SizedBox(height: 5),
//                   pdfLib.Text(
//                     createdAt != null
//                         ? DateFormat('d/M/yyyy').format(createdAt)
//                         : '1/2/2023',
//                     style: pdfLib.TextStyle(fontSize: 12, font: _arabicFont),
//                   ),
//                 ],
//               ),
//             ),

//             // التاريخ على اليمين
//             pdfLib.Container(
//               width: 80,
//               child: pdfLib.Column(
//                 crossAxisAlignment: pdfLib.CrossAxisAlignment.end,
//                 children: [
//                   pdfLib.Text(
//                     'التاريخ :',
//                     style: pdfLib.TextStyle(fontSize: 11, font: _arabicFont),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),

//         pdfLib.SizedBox(height: 10),

//         // معلومات الشركة
//         pdfLib.Column(
//           crossAxisAlignment: pdfLib.CrossAxisAlignment.end,
//           children: [
//             pdfLib.Row(
//               mainAxisAlignment: pdfLib.MainAxisAlignment.end,
//               children: [
//                 pdfLib.Text(
//                   companyName,
//                   style: pdfLib.TextStyle(fontSize: 11, font: _arabicFont),
//                 ),
//                 pdfLib.SizedBox(width: 10),
//                 pdfLib.Text(
//                   'السادة شركة',
//                   style: pdfLib.TextStyle(fontSize: 11, font: _arabicFont),
//                 ),
//               ],
//             ),
//             pdfLib.SizedBox(height: 3),
//             pdfLib.Text(
//               'مذكور للمشروعات',
//               style: pdfLib.TextStyle(fontSize: 11, font: _arabicFont),
//             ),
//             pdfLib.SizedBox(height: 3),
//             pdfLib.Row(
//               mainAxisAlignment: pdfLib.MainAxisAlignment.end,
//               children: [
//                 pdfLib.Text(
//                   companyLocationName.isNotEmpty
//                       ? companyLocationName
//                       : 'امتداد محور التعمير-195',
//                   style: pdfLib.TextStyle(fontSize: 11, font: _arabicFont),
//                 ),
//                 pdfLib.SizedBox(width: 10),
//                 pdfLib.Text(
//                   'موقع :',
//                   style: pdfLib.TextStyle(fontSize: 11, font: _arabicFont),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   // ================================
//   // بناء جدول الفاتورة
//   // ================================
//   pdfLib.Widget _buildInvoiceTable(List<Map<String, dynamic>> groupedTrips) {
//     return pdfLib.Table(
//       border: pdfLib.TableBorder.all(color: pdfLib.PdfColors.black, width: 1),
//       children: [
//         // رأس الجدول
//         pdfLib.TableRow(
//           decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
//           children: [
//             _buildHeaderCell('التاريخ'),
//             _buildHeaderCell('TR\nNumber'),
//             _buildHeaderCell('البيان'),
//             _buildHeaderCell('عدد/طن'),
//             _buildHeaderCell('السعر'),
//             _buildHeaderCell('القيمة الاجمالية'),
//           ],
//         ),

//         // صفوف البيانات
//         ...groupedTrips.map(
//           (trip) => pdfLib.TableRow(
//             children: [
//               _buildDataCell(trip['date'] ?? '-'),
//               _buildDataCell(trip['tr']?.toString() ?? '-'),
//               _buildDataCell(
//                 trip['description'] ?? '-',
//                 align: pdfLib.TextAlign.right,
//               ),
//               _buildDataCell((trip['count'] ?? 0).toString()),
//               _buildDataCell(_formatCurrencyForPDF(trip['price'] ?? 0)),
//               _buildDataCell(_formatCurrencyForPDF(trip['total'] ?? 0)),
//             ],
//           ),
//         ),

//         // صفوف فارغة إضافية (20 صف كحد أقصى)
//         ...List.generate(
//           20 - groupedTrips.length > 0 ? 20 - groupedTrips.length : 0,
//           (index) => pdfLib.TableRow(
//             children: [
//               _buildDataCell(''),
//               _buildDataCell(''),
//               _buildDataCell(''),
//               _buildDataCell(''),
//               _buildDataCell(''),
//               _buildDataCell('0'),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   pdfLib.Widget _buildHeaderCell(String text) {
//     return pdfLib.Container(
//       padding: pdfLib.EdgeInsets.all(5),
//       alignment: pdfLib.Alignment.center,
//       child: pdfLib.Text(
//         text,
//         style: pdfLib.TextStyle(
//           fontSize: 10,
//           fontWeight: pdfLib.FontWeight.bold,
//           font: _arabicFont,
//         ),
//         textAlign: pdfLib.TextAlign.center,
//       ),
//     );
//   }

//   pdfLib.Widget _buildDataCell(
//     String text, {
//     pdfLib.TextAlign align = pdfLib.TextAlign.center,
//   }) {
//     return pdfLib.Container(
//       padding: pdfLib.EdgeInsets.all(5),
//       alignment: align == pdfLib.TextAlign.right
//           ? pdfLib.Alignment.centerRight
//           : pdfLib.Alignment.center,
//       child: pdfLib.Text(
//         text,
//         style: pdfLib.TextStyle(fontSize: 9, font: _arabicFont),
//         textAlign: align,
//       ),
//     );
//   }

//   // ================================
//   // بناء قسم الإجماليات
//   // ================================
//   pdfLib.Widget _buildInvoiceTotals(Map<String, dynamic> invoice) {
//     final totalAmount = (invoice['totalAmount'] ?? 0).toDouble();
//     final tax = totalAmount * 0.14;
//     final totalAfterTax = totalAmount + tax;

//     return pdfLib.Column(
//       crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
//       children: [
//         pdfLib.Container(
//           decoration: pdfLib.BoxDecoration(
//             border: pdfLib.Border.all(color: pdfLib.PdfColors.black),
//           ),
//           child: pdfLib.Table(
//             border: pdfLib.TableBorder.all(color: pdfLib.PdfColors.black),
//             children: [
//               pdfLib.TableRow(
//                 children: [
//                   _buildTotalCell(_formatCurrencyForPDF(totalAmount)),
//                   _buildTotalCell('الإجمالي', isLabel: true),
//                 ],
//               ),
//               pdfLib.TableRow(
//                 children: [
//                   _buildTotalCell(_formatCurrencyForPDF(tax)),
//                   _buildTotalCell('14%ضريبة مبيعات', isLabel: true),
//                 ],
//               ),
//               pdfLib.TableRow(
//                 children: [
//                   _buildTotalCell(_formatCurrencyForPDF(totalAfterTax)),
//                   _buildTotalCell('الإجمالي بعد الضريبة', isLabel: true),
//                 ],
//               ),
//             ],
//           ),
//         ),

//         pdfLib.SizedBox(height: 10),

//         // معلومات الشركة في الأسفل
//         pdfLib.Row(
//           mainAxisAlignment: pdfLib.MainAxisAlignment.end,
//           children: [
//             pdfLib.Column(
//               crossAxisAlignment: pdfLib.CrossAxisAlignment.end,
//               children: [
//                 pdfLib.Row(
//                   children: [
//                     pdfLib.Text(
//                       '16732',
//                       style: pdfLib.TextStyle(fontSize: 9, font: _arabicFont),
//                     ),
//                     pdfLib.SizedBox(width: 5),
//                     pdfLib.Text(
//                       'سجل تجاري :',
//                       style: pdfLib.TextStyle(fontSize: 9, font: _arabicFont),
//                     ),
//                   ],
//                 ),
//                 pdfLib.SizedBox(height: 2),
//                 pdfLib.Row(
//                   children: [
//                     pdfLib.Text(
//                       '261-525-263',
//                       style: pdfLib.TextStyle(fontSize: 9, font: _arabicFont),
//                     ),
//                     pdfLib.SizedBox(width: 5),
//                     pdfLib.Text(
//                       'بطاقة ضريبة :',
//                       style: pdfLib.TextStyle(fontSize: 9, font: _arabicFont),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),

//         pdfLib.SizedBox(height: 5),

//         pdfLib.Text(
//           'الفاتورة الغير مختومة بختم الشركة لايعتد بها',
//           style: pdfLib.TextStyle(fontSize: 9, font: _arabicFont),
//           textAlign: pdfLib.TextAlign.center,
//         ),
//       ],
//     );
//   }

//   pdfLib.Widget _buildTotalCell(String text, {bool isLabel = false}) {
//     return pdfLib.Container(
//       padding: pdfLib.EdgeInsets.all(5),
//       alignment: pdfLib.Alignment.center,
//       child: pdfLib.Text(
//         text,
//         style: pdfLib.TextStyle(
//           fontSize: 10,
//           font: _arabicFont,
//           fontWeight: isLabel
//               ? pdfLib.FontWeight.bold
//               : pdfLib.FontWeight.normal,
//         ),
//         textAlign: pdfLib.TextAlign.center,
//       ),
//     );
//   }

//   // ================================
//   // تجميع الرحلات
//   // ================================
//   List<Map<String, dynamic>> _groupTripsForInvoice(
//     List<Map<String, dynamic>> trips,
//   ) {
//     final Map<String, Map<String, dynamic>> grouped = {};

//     for (final trip in trips) {
//       final date = trip['date'] != null
//           ? DateFormat('d/M/yyyy').format((trip['date'] as DateTime))
//           : DateFormat('d/M/yyyy').format(DateTime.now());
//       final tr = trip['tr']?.toString() ?? '';
//       final nolon = (trip['nolon'] ?? 0).toDouble();
//       final companyOvernight = (trip['companyOvernight'] ?? 0).toDouble();
//       final companyHoliday = (trip['companyHoliday'] ?? 0).toDouble();
//       final selectedRoute = trip['selectedRoute']?.toString() ?? '';
//       final companyLocationName = trip['companyLocationName']?.toString() ?? '';

//       String description = selectedRoute;
//       if (companyLocationName.isNotEmpty) {
//         description += ' $companyLocationName';
//       }

//       final key = '$date|$tr|$nolon|$selectedRoute';

//       if (!grouped.containsKey(key)) {
//         grouped[key] = {
//           'date': date,
//           'tr': tr,
//           'description': description,
//           'nolon': nolon,
//           'nolonCount': 1,
//           'overnight': companyOvernight,
//           'overnightCount': companyOvernight > 0 ? 1 : 0,
//           'holiday': companyHoliday,
//           'holidayCount': companyHoliday > 0 ? 1 : 0,
//           'selectedRoute': selectedRoute,
//           'companyLocationName': companyLocationName,
//         };
//       } else {
//         final existing = grouped[key]!;
//         existing['nolonCount'] = (existing['nolonCount'] as int) + 1;
//         if (companyOvernight > 0) {
//           existing['overnightCount'] = (existing['overnightCount'] as int) + 1;
//         }
//         if (companyHoliday > 0) {
//           existing['holidayCount'] = (existing['holidayCount'] as int) + 1;
//         }
//       }
//     }

//     final List<Map<String, dynamic>> result = [];

//     grouped.forEach((key, tripGroup) {
//       if (tripGroup['nolonCount'] > 0) {
//         result.add({
//           'type': 'نولون',
//           'date': tripGroup['date'],
//           'tr': tripGroup['tr'],
//           'description': tripGroup['description'],
//           'count': tripGroup['nolonCount'],
//           'price': tripGroup['nolon'],
//           'total':
//               (tripGroup['nolonCount'] as int) * (tripGroup['nolon'] as double),
//         });
//       }
//       if (tripGroup['overnightCount'] > 0) {
//         result.add({
//           'type': 'مبيت',
//           'date': tripGroup['date'],
//           'tr': tripGroup['tr'],
//           'description': 'مبيت ${tripGroup['description']}',
//           'count': tripGroup['overnightCount'],
//           'price': tripGroup['overnight'],
//           'total':
//               (tripGroup['overnightCount'] as int) *
//               (tripGroup['overnight'] as double),
//         });
//       }
//       if (tripGroup['holidayCount'] > 0) {
//         result.add({
//           'type': 'عطلة',
//           'date': tripGroup['date'],
//           'tr': tripGroup['tr'],
//           'description': 'عطلة ${tripGroup['description']}',
//           'count': tripGroup['holidayCount'],
//           'price': tripGroup['holiday'],
//           'total':
//               (tripGroup['holidayCount'] as int) *
//               (tripGroup['holiday'] as double),
//         });
//       }
//     });

//     return result;
//   }

//   String _getCompanyLocationName(List<Map<String, dynamic>> trips) {
//     if (trips.isEmpty) return '';
//     for (final trip in trips) {
//       final location = trip['companyLocationName']?.toString() ?? '';
//       if (location.isNotEmpty) return location;
//     }
//     return '';
//   }

//   // ================================
//   // بناء الواجهة
//   // ================================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6F8),
//       body: Column(
//         children: [
//           _buildCustomAppBar(),
//           if (_selectedCompany == null) _buildSearchBar(),
//           Expanded(
//             child: _selectedCompany == null
//                 ? _buildCompanyList()
//                 : _buildCompanySections(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCustomAppBar() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
//               _selectedCompany == null ? Icons.business : Icons.arrow_back,
//               color: Colors.white,
//               size: 28,
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Center(
//                 child: Text(
//                   _selectedCompany == null ? 'اختر شركة' : '$_selectedCompany',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//             if (_selectedCompany == null)
//               IconButton(
//                 icon: const Icon(Icons.sync, color: Colors.white),
//                 onPressed: _syncDataOnPageEnter,
//                 tooltip: 'مزامنة حسابات الشركات',
//               ),
//             if (_selectedCompany != null)
//               IconButton(
//                 icon: const Icon(Icons.arrow_back, color: Colors.white),
//                 onPressed: _backToCompanies,
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       color: Colors.white,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF4F6F8),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: const Color(0xFF3498DB)),
//         ),
//         child: Row(
//           children: [
//             const Icon(Icons.search, color: Color(0xFF3498DB), size: 20),
//             const SizedBox(width: 8),
//             Expanded(
//               child: TextField(
//                 onChanged: (value) {
//                   setState(() {
//                     _searchQuery = value;
//                     _filteredCompanies = _applySearchFilter(_allCompanies);
//                   });
//                 },
//                 decoration: const InputDecoration(
//                   hintText: 'ابحث عن شركة...',
//                   border: InputBorder.none,
//                   hintStyle: TextStyle(color: Colors.grey),
//                 ),
//               ),
//             ),
//             if (_searchQuery.isNotEmpty)
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _searchQuery = '';
//                     _filteredCompanies = _applySearchFilter(_allCompanies);
//                   });
//                 },
//                 child: const Icon(Icons.clear, size: 18, color: Colors.grey),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCompanyList() {
//     if (_isLoading) return const Center(child: CircularProgressIndicator());

//     return _filteredCompanies.isEmpty
//         ? Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.business, size: 80, color: Colors.grey[400]),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'لا توجد شركات',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//           )
//         : ListView.builder(
//             padding: const EdgeInsets.all(8),
//             itemCount: _filteredCompanies.length,
//             itemBuilder: (context, index) {
//               final company = _filteredCompanies[index];
//               return _buildCompanyCard(company);
//             },
//           );
//   }

//   Widget _buildCompanyCard(Map<String, dynamic> company) {
//     final companyName = company['companyName'];
//     final companyId = company['companyId'];
//     final totalTrips = company['totalTrips'] ?? 0;
//     final totalNolon = company['totalNolon'] ?? 0;

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
//         leading: Container(
//           width: 45,
//           height: 45,
//           decoration: BoxDecoration(
//             color: totalTrips > 0 ? const Color(0xFF3498DB) : Colors.grey,
//             borderRadius: BorderRadius.circular(22.5),
//           ),
//           child: Center(
//             child: Text(
//               totalTrips.toString(),
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//         ),
//         title: Text(
//           companyName,
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//             color: totalTrips > 0 ? const Color(0xFF2C3E50) : Colors.grey,
//           ),
//         ),
//         subtitle: Text(
//           totalTrips > 0
//               ? '$totalTrips رحلة - ${_formatCurrency(totalNolon)}'
//               : 'لا توجد رحلات',
//           style: TextStyle(
//             color: totalTrips > 0 ? Colors.green : Colors.grey,
//             fontSize: 12,
//           ),
//         ),
//         trailing: const Icon(
//           Icons.arrow_forward_ios,
//           color: Color(0xFF3498DB),
//           size: 16,
//         ),
//         onTap: () => _loadCompanyData(companyName, companyId),
//       ),
//     );
//   }

//   Widget _buildCompanySections() {
//     return Column(
//       children: [
//         // تبويبات الأقسام
//         _buildSectionTabs(),
//         Expanded(
//           child: _currentSection == 0
//               ? _buildWorkTable()
//               : _currentSection == 1
//               ? _buildCreateInvoiceSection()
//               : _buildInvoicesSection(),
//         ),
//       ],
//     );
//   }

//   Widget _buildSectionTabs() {
//     return Container(
//       color: Colors.white,
//       child: Row(
//         children: [
//           _buildSectionTab(0, Icons.list, 'شغل الشركات'),
//           _buildSectionTab(1, Icons.receipt, 'إنشاء فاتورة'),
//           _buildSectionTab(2, Icons.list_alt, 'الفواتير'),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionTab(int section, IconData icon, String title) {
//     final isActive = _currentSection == section;
//     return Expanded(
//       child: InkWell(
//         onTap: () => _changeSection(section),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             color: isActive ? const Color(0xFF3498DB) : Colors.white,
//             border: Border(
//               bottom: BorderSide(
//                 color: isActive ? const Color(0xFF3498DB) : Colors.grey[300]!,
//                 width: 3,
//               ),
//             ),
//           ),
//           child: Column(
//             children: [
//               Icon(
//                 icon,
//                 color: isActive ? Colors.white : Colors.grey,
//                 size: 22,
//               ),
//               const SizedBox(height: 4),
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: isActive ? Colors.white : Colors.grey,
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildWorkTable() {
//     if (_isLoading) return const Center(child: CircularProgressIndicator());

//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(12),
//           color: Colors.blue[50],
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'جميع الرحلات',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF3498DB),
//                 ),
//               ),
//               Text(
//                 '${_companyWork.length} رحلة',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2E7D32),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: Container(
//             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
//             child: _companyWork.isEmpty
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(
//                           Icons.business,
//                           size: 60,
//                           color: Colors.grey,
//                         ),
//                         const SizedBox(height: 16),
//                         const Text(
//                           'لا يوجد شغل مسجل لهذه الشركة',
//                           style: TextStyle(
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
//                         defaultColumnWidth: const FixedColumnWidth(110),
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
//                               TableCellHeader('الحالة'),
//                               TableCellHeader('TR'),
//                               TableCellHeader('موقع الشركة'),
//                               TableCellHeader('عطلة الشركة'),
//                               TableCellHeader('مبيت الشركة'),
//                               TableCellHeader('نولون الشركة'),
//                               TableCellHeader('اسم السائق'),
//                               TableCellHeader('الكارتة'),
//                               TableCellHeader('العهدة'),
//                               TableCellHeader('اسم الموقع'),
//                               TableCellHeader('مكان التعتيق'),
//                               TableCellHeader('مكان التحميل'),
//                               TableCellHeader('التاريخ'),
//                               TableCellHeader('م'),
//                             ],
//                           ),
//                           ..._companyWork.asMap().entries.map((entry) {
//                             final index = entry.key;
//                             final work = entry.value;
//                             final hasInvoice = work['hasInvoice'];

//                             return TableRow(
//                               decoration: BoxDecoration(
//                                 color: index.isEven
//                                     ? Colors.white
//                                     : const Color(0xFFF8F9FA),
//                               ),
//                               children: [
//                                 TableCellBody(
//                                   hasInvoice ? 'مفوتورة' : 'متاحة',
//                                   textStyle: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: hasInvoice
//                                         ? Colors.red
//                                         : Colors.green,
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   work['tr'] ?? '-',
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF2C3E50),
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   work['companyLocationName'] ?? '-',
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF3498DB),
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   '${work['companyHoliday']} ج',
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.red,
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   '${work['companyOvernight']} ج',
//                                   textStyle: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.orange[700],
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   '${work['nolon']} ج',
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.green,
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   work['driverName'],
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF2C3E50),
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

//   Widget _buildCreateInvoiceSection() {
//     if (_isLoading) return const Center(child: CircularProgressIndicator());

//     return _availableTripsForInvoice.isEmpty
//         ? Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.receipt, size: 80, color: Colors.grey),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'لا توجد رحلات متاحة للفاتورة',
//                   style: TextStyle(
//                     fontSize: 18,
//                     color: Colors.grey,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 const Text(
//                   'جميع الرحلات تم عمل فاتورة لها',
//                   style: TextStyle(color: Colors.grey),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 30),
//                 ElevatedButton.icon(
//                   onPressed: () => _changeSection(0),
//                   icon: const Icon(Icons.list),
//                   label: const Text('عرض جميع الرحلات'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF3498DB),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 12,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           )
//         : Column(
//             children: [
//               // إحصائيات الرحلات المختارة
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 color: Colors.blue[50],
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'الرحلات المتاحة',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF3498DB),
//                           ),
//                         ),
//                         Text(
//                           '${_availableTripsForInvoice.length} رحلة متاحة للفاتورة',
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF2E7D32),
//                           ),
//                         ),
//                       ],
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         const Text(
//                           'الرحلات المختارة',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF3498DB),
//                           ),
//                         ),
//                         Text(
//                           '${_selectedTripsForInvoice.length} من ${_availableTripsForInvoice.length}',
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF2E7D32),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               // اسم الفاتورة
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: TextField(
//                   controller: _invoiceNameController,
//                   decoration: InputDecoration(
//                     labelText: 'اسم الفاتورة',
//                     prefixIcon: const Icon(Icons.receipt),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                 ),
//               ),

//               // أزرار التحكم
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () => _selectAllTrips(true),
//                         icon: const Icon(Icons.check_box),
//                         label: const Text('تحديد الكل'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green[50],
//                           foregroundColor: Colors.green[700],
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () => _selectAllTrips(false),
//                         icon: const Icon(Icons.check_box_outline_blank),
//                         label: const Text('إلغاء الكل'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red[50],
//                           foregroundColor: Colors.red[700],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // تفاصيل المبالغ المختارة
//               if (_selectedTripsForInvoice.isNotEmpty)
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   margin: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.green[50],
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.green),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       Column(
//                         children: [
//                           Text(
//                             _formatCurrency(_calculateNolonTotal()),
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.green,
//                             ),
//                           ),
//                           const Text(
//                             'إجمالي النولون',
//                             style: TextStyle(fontSize: 12, color: Colors.green),
//                           ),
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           Text(
//                             _formatCurrency(_calculateOvernightTotal()),
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.orange,
//                             ),
//                           ),
//                           const Text(
//                             'إجمالي المبيت',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.orange,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           Text(
//                             _formatCurrency(_calculateHolidayTotal()),
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.red,
//                             ),
//                           ),
//                           const Text(
//                             'إجمالي العطلة',
//                             style: TextStyle(fontSize: 12, color: Colors.red),
//                           ),
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           Text(
//                             _formatCurrency(_calculateInvoiceTotal()),
//                             style: const TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF2E7D32),
//                             ),
//                           ),
//                           const Text(
//                             'الإجمالي الكلي',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Color(0xFF2E7D32),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//               // جدول الرحلات المتاحة مع خيار التحديد
//               Expanded(
//                 child: Container(
//                   margin: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: SingleChildScrollView(
//                       scrollDirection: Axis.vertical,
//                       child: Table(
//                         defaultColumnWidth: const FixedColumnWidth(110),
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
//                               TableCellHeader('تحديد'),
//                               TableCellHeader('TR'),
//                               TableCellHeader('موقع الشركة'),
//                               TableCellHeader('عطلة الشركة'),
//                               TableCellHeader('مبيت الشركة'),
//                               TableCellHeader('نولون الشركة'),
//                               TableCellHeader('اسم السائق'),
//                               TableCellHeader('الكارتة'),
//                               TableCellHeader('العهدة'),
//                               TableCellHeader('اسم الموقع'),
//                               TableCellHeader('مكان التعتيق'),
//                               TableCellHeader('مكان التحميل'),
//                               TableCellHeader('التاريخ'),
//                               TableCellHeader('م'),
//                             ],
//                           ),
//                           ..._availableTripsForInvoice.asMap().entries.map((
//                             entry,
//                           ) {
//                             final index = entry.key;
//                             final work = entry.value;
//                             final isSelected = _selectedTripsForInvoice.any(
//                               (trip) => trip['id'] == work['id'],
//                             );

//                             return TableRow(
//                               decoration: BoxDecoration(
//                                 color: isSelected
//                                     ? const Color(0xFFE8F5E9)
//                                     : index.isEven
//                                     ? Colors.white
//                                     : const Color(0xFFF8F9FA),
//                               ),
//                               children: [
//                                 TableCell(
//                                   child: Container(
//                                     height: 48,
//                                     alignment: Alignment.center,
//                                     child: Checkbox(
//                                       value: isSelected,
//                                       onChanged: (value) {
//                                         _toggleTripSelection(
//                                           work,
//                                           value ?? false,
//                                         );
//                                       },
//                                     ),
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   work['tr'] ?? '-',
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF2C3E50),
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   work['companyLocationName'] ?? '-',
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF3498DB),
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   '${work['companyHoliday']} ج',
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.red,
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   '${work['companyOvernight']} ج',
//                                   textStyle: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.orange[700],
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   '${work['nolon']} ج',
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.green,
//                                   ),
//                                 ),
//                                 TableCellBody(
//                                   work['driverName'],
//                                   textStyle: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF2C3E50),
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
//                 ),
//               ),

//               // زر إنشاء الفاتورة
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton.icon(
//                     onPressed:
//                         _selectedTripsForInvoice.isEmpty || _isCreatingInvoice
//                         ? null
//                         : _createInvoice,
//                     icon: _isCreatingInvoice
//                         ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                             ),
//                           )
//                         : const Icon(Icons.save),
//                     label: Text(
//                       _isCreatingInvoice ? 'جاري الإنشاء...' : 'إنشاء الفاتورة',
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF2E7D32),
//                       foregroundColor: Colors.white,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//   }

//   Widget _buildInvoicesSection() {
//     if (_isLoading) return const Center(child: CircularProgressIndicator());

//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(16),
//           color: Colors.blue[50],
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'فواتير الشركة',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF3498DB),
//                 ),
//               ),
//               Text(
//                 '${_companyInvoices.length} فاتورة',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2E7D32),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: _companyInvoices.isEmpty
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(
//                         Icons.receipt_long,
//                         size: 80,
//                         color: Colors.grey,
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         'لا توجد فواتير',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.grey,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       const Text(
//                         'قم بإنشاء فاتورة أولاً',
//                         style: TextStyle(color: Colors.grey),
//                       ),
//                       const SizedBox(height: 30),
//                       ElevatedButton.icon(
//                         onPressed: () => _changeSection(1),
//                         icon: const Icon(Icons.add),
//                         label: const Text('إنشاء فاتورة'),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF3498DB),
//                           foregroundColor: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : ListView.builder(
//                   padding: const EdgeInsets.all(8),
//                   itemCount: _companyInvoices.length,
//                   itemBuilder: (context, index) {
//                     final invoice = _companyInvoices[index];
//                     return _buildInvoiceCard(invoice, index);
//                   },
//                 ),
//         ),
//       ],
//     );
//   }

//   Widget _buildInvoiceCard(Map<String, dynamic> invoice, int index) {
//     final createdAt = invoice['createdAt'] as DateTime?;
//     final invoiceTrips = invoice['invoiceTrips'] as List<Map<String, dynamic>>;

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[300]!),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ExpansionTile(
//         leading: CircleAvatar(
//           backgroundColor: const Color(0xFF3498DB),
//           child: Text(
//             '${index + 1}',
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         title: Text(
//           invoice['name'],
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//             color: Color(0xFF2C3E50),
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '${invoice['tripCount']} رحلة - ${createdAt != null ? _formatDate(createdAt) : 'غير معروف'}',
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//           ],
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   _formatCurrency(invoice['totalAmount']),
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Color(0xFF2E7D32),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'إجمالي',
//                   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//             const SizedBox(width: 10),
//             IconButton(
//               icon: Icon(Icons.print, color: Color(0xFF3498DB)),
//               onPressed: _isGeneratingPDF ? null : () => _printInvoice(invoice),
//             ),
//           ],
//         ),
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // إحصائيات الفاتورة
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.blue[50],
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'عدد الرحلات:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             '${invoice['tripCount']}',
//                             style: const TextStyle(color: Color(0xFF3498DB)),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'إجمالي النولون:',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.green,
//                             ),
//                           ),
//                           Text(
//                             _formatCurrency(invoice['nolonTotal']),
//                             style: const TextStyle(color: Colors.green),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'إجمالي المبيت:',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.orange,
//                             ),
//                           ),
//                           Text(
//                             _formatCurrency(invoice['overnightTotal']),
//                             style: const TextStyle(color: Colors.orange),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'إجمالي العطلة:',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Colors.red,
//                             ),
//                           ),
//                           Text(
//                             _formatCurrency(invoice['holidayTotal']),
//                             style: const TextStyle(color: Colors.red),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 12),

//                 // زر طباعة الفاتورة
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton.icon(
//                     onPressed: _isGeneratingPDF
//                         ? null
//                         : () => _printInvoice(invoice),
//                     icon: _isGeneratingPDF
//                         ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                             ),
//                           )
//                         : const Icon(Icons.print),
//                     label: Text(
//                       _isGeneratingPDF ? 'جاري الطباعة...' : 'طباعة الفاتورة',
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Color(0xFF2E7D32),
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 12),

//                 // تفاصيل الرحلات
//                 const Text(
//                   'تفاصيل الرحلات:',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF2C3E50),
//                   ),
//                 ),
//                 const SizedBox(height: 8),

//                 // جدول تفاصيل الرحلات
//                 if (invoiceTrips.isNotEmpty)
//                   SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Table(
//                       defaultColumnWidth: const FixedColumnWidth(150),
//                       border: TableBorder.all(
//                         color: Colors.grey[300]!,
//                         width: 1,
//                       ),
//                       children: [
//                         TableRow(
//                           decoration: BoxDecoration(color: Colors.grey[100]),
//                           children: const [
//                             TableCellHeader('اسم الموقع'),
//                             TableCellHeader('TR'),
//                             TableCellHeader('موقع الشركة'),
//                             TableCellHeader('النولون'),
//                             TableCellHeader('المبيت'),
//                             TableCellHeader('العطلة'),
//                           ],
//                         ),
//                         ...invoiceTrips.map((trip) {
//                           return TableRow(
//                             decoration: BoxDecoration(color: Colors.white),
//                             children: [
//                               TableCellBody(
//                                 trip['selectedRoute'] ?? '',
//                                 textStyle: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF3498DB),
//                                 ),
//                               ),
//                               TableCellBody(
//                                 trip['tr'] ?? '-',
//                                 textStyle: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF2C3E50),
//                                 ),
//                               ),
//                               TableCellBody(
//                                 trip['companyLocationName'] ?? '-',
//                                 textStyle: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF3498DB),
//                                 ),
//                               ),
//                               TableCellBody(
//                                 _formatCurrency(trip['nolon']),
//                                 textStyle: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green,
//                                 ),
//                               ),
//                               TableCellBody(
//                                 _formatCurrency(trip['companyOvernight']),
//                                 textStyle: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.orange,
//                                 ),
//                               ),
//                               TableCellBody(
//                                 _formatCurrency(trip['companyHoliday']),
//                                 textStyle: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.red,
//                                 ),
//                               ),
//                             ],
//                           );
//                         }),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   double _calculateInvoiceTotal() {
//     double total = 0;
//     for (var trip in _selectedTripsForInvoice) {
//       total +=
//           trip['nolon'] + trip['companyOvernight'] + trip['companyHoliday'];
//     }
//     return total;
//   }

//   double _calculateNolonTotal() {
//     double total = 0;
//     for (var trip in _selectedTripsForInvoice) {
//       total += trip['nolon'];
//     }
//     return total;
//   }

//   double _calculateOvernightTotal() {
//     double total = 0;
//     for (var trip in _selectedTripsForInvoice) {
//       total += trip['companyOvernight'];
//     }
//     return total;
//   }

//   double _calculateHolidayTotal() {
//     double total = 0;
//     for (var trip in _selectedTripsForInvoice) {
//       total += trip['companyHoliday'];
//     }
//     return total;
//   }
// }

// class TableCellHeader extends StatelessWidget {
//   final String text;
//   const TableCellHeader(this.text, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 40,
//       alignment: Alignment.center,
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 12,
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
//       height: 38,
//       alignment: Alignment.center,
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       child: Text(
//         text,
//         maxLines: 2,
//         overflow: TextOverflow.ellipsis,
//         textAlign: TextAlign.center,
//         style: textStyle ?? const TextStyle(fontSize: 12),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart' as pdfLib;
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class CompanyWorkPage extends StatefulWidget {
  const CompanyWorkPage({super.key});

  @override
  State<CompanyWorkPage> createState() => _CompanyWorkPageState();
}

class _CompanyWorkPageState extends State<CompanyWorkPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  pdfLib.Font? _arabicFont;

  // متغيرات عامة
  List<Map<String, dynamic>> _allCompanies = [];
  List<Map<String, dynamic>> _filteredCompanies = [];
  String? _selectedCompany;
  String? _selectedCompanyId;
  bool _isLoading = false;
  String _searchQuery = '';

  // متغيرات الأقسام بعد اختيار الشركة
  int _currentSection = 0; // 0: شغل الشركات، 1: إنشاء فاتورة، 2: الفواتير
  List<Map<String, dynamic>> _companyWork = []; // جميع الرحلات
  List<Map<String, dynamic>> _availableTripsForInvoice =
      []; // الرحلات المتاحة للفاتورة
  List<Map<String, dynamic>> _companyInvoices = []; // فواتير الشركة

  // متغيرات قسم إنشاء الفاتورة
  final List<Map<String, dynamic>> _selectedTripsForInvoice = [];
  final TextEditingController _invoiceNameController = TextEditingController();
  bool _isCreatingInvoice = false;
  bool _isGeneratingPDF = false;

  // متغير للمزامنة التلقائية
  bool _hasSyncedOnEnter = false;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
    _loadArabicFont();
  }

  // ================================
  // تحميل الخط العربي للطباعة
  // ================================
  Future<void> _loadArabicFont() async {
    try {
      final fontData = await rootBundle.load(
        'assets/fonts/Amiri/Amiri-Regular.ttf',
      );

      _arabicFont = pdfLib.Font.ttf(fontData);
      debugPrint('تم تحميل الخط العربي بنجاح');
    } catch (e) {
      debugPrint('فشل تحميل الخط العربي: $e');
      _arabicFont = pdfLib.Font.courier();
    }
  }

  // ================================
  // نظام مزامنة companySummaries تلقائياً
  // ================================
  Future<void> _syncDataOnPageEnter() async {
    debugPrint('🔄 بدء التحديث التلقائي لحسابات الشركات...');

    try {
      // 1. جلب جميع حسابات الشركات
      final companySummaries = await _firestore
          .collection('companySummaries')
          .get();

      // 2. حساب إجمالي الرحلات من dailyWork لكل شركة
      final dailyWorkSnapshot = await _firestore.collection('dailyWork').get();

      Map<String, int> dailyWorkTripCounts = {};
      Map<String, double> dailyWorkTotalDebts = {};
      Map<String, String> companyNames = {};

      for (final doc in dailyWorkSnapshot.docs) {
        final data = doc.data();
        final companyId = data['companyId'] as String?;
        final companyName = data['companyName'] as String?;

        if (companyId != null && companyName != null) {
          // حساب عدد الرحلات
          dailyWorkTripCounts[companyId] =
              (dailyWorkTripCounts[companyId] ?? 0) + 1;
          companyNames[companyId] = companyName;

          // حساب إجمالي الدين
          final nolon = (data['nolon'] ?? data['noLon'] ?? 0).toDouble();
          final overnight = (data['companyOvernight'] ?? 0).toDouble();
          final holiday = (data['companyHoliday'] ?? 0).toDouble();

          dailyWorkTotalDebts[companyId] =
              (dailyWorkTotalDebts[companyId] ?? 0.0) +
              nolon +
              overnight +
              holiday;
        }
      }

      // 3. المقارنة والتحديث
      final batch = _firestore.batch();
      final summariesRef = _firestore.collection('companySummaries');

      int updatedCount = 0;

      for (final entry in dailyWorkTripCounts.entries) {
        final companyId = entry.key;
        final dailyWorkTrips = entry.value;
        final companyName = companyNames[companyId] ?? 'غير معروف';
        final totalDebt = dailyWorkTotalDebts[companyId] ?? 0.0;

        // البحث عن حساب الشركة
        DocumentSnapshot? summaryDoc;
        for (final doc in companySummaries.docs) {
          final data = doc.data();
          if (doc.id == companyId || data['companyId'] == companyId) {
            summaryDoc = doc;
            break;
          }
        }

        if (summaryDoc != null && summaryDoc.exists) {
          // تحقق من عدد الرحلات
          final summaryData = summaryDoc.data() as Map<String, dynamic>;
          final summaryTrips = (summaryData['totalTrips'] ?? 0).toInt();
          final summaryDebt = (summaryData['totalCompanyDebt'] ?? 0).toDouble();

          // إذا كان عدد الرحلات أو المبلغ غير متطابق
          if (dailyWorkTrips != summaryTrips || totalDebt != summaryDebt) {
            final totalPaidAmount = (summaryData['totalPaidAmount'] ?? 0)
                .toDouble();
            final totalRemaining = totalDebt - totalPaidAmount;

            String status;
            if (totalRemaining <= 0) {
              status = 'منتهية';
            } else if (totalPaidAmount > 0) {
              status = 'شبه منتهية';
            } else {
              status = 'جارية';
            }

            batch.set(summariesRef.doc(companyId), {
              'companyId': companyId,
              'companyName': companyName,
              'totalCompanyDebt': totalDebt,
              'totalPaidAmount': totalPaidAmount,
              'totalRemainingAmount': totalRemaining,
              'totalTrips': dailyWorkTrips,
              'status': status,
              'lastUpdated': Timestamp.now(),
            }, SetOptions(merge: true));

            updatedCount++;
          }
        } else {
          // الشركة ليس لها حساب، إنشاء حساب جديد
          batch.set(summariesRef.doc(companyId), {
            'companyId': companyId,
            'companyName': companyName,
            'totalCompanyDebt': totalDebt,
            'totalPaidAmount': 0.0,
            'totalRemainingAmount': totalDebt,
            'totalTrips': dailyWorkTrips,
            'status': 'جارية',
            'lastUpdated': Timestamp.now(),
          });

          updatedCount++;
        }
      }

      // 4. حذف حسابات الشركات التي ليس لها رحلات
      for (final doc in companySummaries.docs) {
        final companyId = doc.id;
        if (!dailyWorkTripCounts.containsKey(companyId)) {
          final data = doc.data();
          final dataCompanyId = data['companyId'] as String?;

          // إذا الشركة ليس لها رحلات في dailyWork
          if (!dailyWorkTripCounts.containsKey(dataCompanyId ?? '')) {
            // يمكنك اختيار حذفها أو تركها
            // batch.delete(summariesRef.doc(companyId));
            debugPrint(
              '⚠️ الشركة ${data['companyName']} ليس لها رحلات في dailyWork',
            );
          }
        }
      }

      if (updatedCount > 0) {
        await batch.commit();
        debugPrint('✅ تم تحديث $updatedCount حساب شركة تلقائياً');
        _showSuccess('تم تحديث حسابات $updatedCount شركة تلقائياً');
      } else {
        debugPrint('✅ جميع الحسابات محدثة بالفعل');
      }
    } catch (e) {
      debugPrint('❌ خطأ في التحديث التلقائي: $e');
      _showError('خطأ في تحديث الحسابات: $e');
    }
  }

  // ================================
  // تحميل بيانات الشركات مع الإحصائيات
  // ================================
  Future<void> _loadCompanies() async {
    setState(() => _isLoading = true);
    try {
      final companiesSnapshot = await _firestore.collection('companies').get();
      final dailyWorkSnapshot = await _firestore.collection('dailyWork').get();

      final List<Map<String, dynamic>> companiesList = [];

      for (final companyDoc in companiesSnapshot.docs) {
        final companyData = companyDoc.data();
        final companyId = companyDoc.id;
        final companyName =
            (companyData['name'] ??
                    companyData['companyName'] ??
                    'شركة غير معروفة')
                .toString()
                .trim();

        // حساب الرحلات والإحصائيات
        final companyTrips = dailyWorkSnapshot.docs
            .where((doc) {
              final data = doc.data();
              final tripCompanyId = data['companyId'] ?? '';
              return tripCompanyId == companyId;
            })
            .map((doc) {
              final data = doc.data();
              final tripDate = (data['date'] as Timestamp?)?.toDate();

              return {
                'id': doc.id,
                'date': tripDate,
                'nolon': (data['noLon'] ?? data['nolon'] ?? 0).toDouble(),
                'companyOvernight': (data['companyOvernight'] ?? 0).toDouble(),
                'companyHoliday': (data['companyHoliday'] ?? 0).toDouble(),
              };
            })
            .toList();

        // حساب الإجماليات
        double totalNolon = 0.0;
        double totalOvernight = 0.0;
        double totalHoliday = 0.0;

        for (var trip in companyTrips) {
          totalNolon += trip['nolon'];
          totalOvernight += trip['companyOvernight'];
          totalHoliday += trip['companyHoliday'];
        }

        companiesList.add({
          'companyId': companyId,
          'companyName': companyName,
          'companyData': companyData,
          'totalTrips': companyTrips.length,
          'totalNolon': totalNolon,
          'totalOvernight': totalOvernight,
          'totalHoliday': totalHoliday,
        });
      }

      companiesList.sort(
        (a, b) => a['companyName'].compareTo(b['companyName']),
      );

      setState(() {
        _allCompanies = companiesList;
        _filteredCompanies = _applySearchFilter(companiesList);
        _isLoading = false;
      });

      // تحديث تلقائي عند دخول الصفحة الرئيسية فقط
      if (!_hasSyncedOnEnter && _selectedCompany == null) {
        await _syncDataOnPageEnter();
        _hasSyncedOnEnter = true;
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('خطأ في تحميل بيانات الشركات: $e');
      _showError('خطأ في تحميل الشركات: $e');
    }
  }

  // ================================
  // تحميل بيانات الشركة المختارة
  // ================================
  Future<void> _loadCompanyData(String companyName, String companyId) async {
    setState(() {
      _selectedCompany = companyName;
      _selectedCompanyId = companyId;
      _isLoading = true;
      _companyWork.clear();
      _availableTripsForInvoice.clear();
      _companyInvoices.clear();
      _selectedTripsForInvoice.clear();
      _invoiceNameController.clear();
    });

    try {
      // 1. تحميل جميع رحلات الشركة من dailyWork
      final workSnapshot = await _firestore
          .collection('dailyWork')
          .where('companyId', isEqualTo: companyId)
          .orderBy('date', descending: false) // الأقدم أولاً
          .get();

      final List<Map<String, dynamic>> allTrips = [];

      for (final doc in workSnapshot.docs) {
        final data = doc.data();
        final tripDate = (data['date'] as Timestamp?)?.toDate();

        allTrips.add({
          'id': doc.id,
          'date': tripDate,
          'companyName': companyName,
          'companyId': companyId,
          'driverName': data['driverName'] ?? 'غير معروف',
          'nolon': (data['noLon'] ?? data['nolon'] ?? 0).toDouble(),
          'companyOvernight': (data['companyOvernight'] ?? 0).toDouble(),
          'companyHoliday': (data['companyHoliday'] ?? 0).toDouble(),
          'selectedPrice': (data['selectedPrice'] ?? 0).toDouble(),
          'karta': data['karta'] ?? '',
          'ohda': data['ohda'] ?? '',
          'selectedRoute': data['selectedRoute'] ?? '',
          'selectedRoute2': data['unloadingLocation'] ?? '',

          'loadingLocation': data['loadingLocation'] ?? '',
          'unloadingLocation': data['unloadingLocation'] ?? '',
          'vehicleType': data['selectedVehicleType'] ?? '',
          'notes': data['selectedNotes'] ?? '',
          'tr': data['tr'] ?? '',
          'companyLocationName': data['companyLocationName'] ?? '',
          'hasInvoice': false,
        });
      }

      // 2. تحميل فواتير الشركة
      final invoicesSnapshot = await _firestore
          .collection('invoices')
          .where('companyId', isEqualTo: companyId)
          .orderBy('createdAt', descending: true)
          .get();

      final List<Map<String, dynamic>> invoicesList = [];
      final List<String> invoicedTripIds = [];

      for (final doc in invoicesSnapshot.docs) {
        final data = doc.data();
        final tripIds = (data['tripIds'] as List<dynamic>? ?? []);

        // جمع ID الرحلات التي تم عمل فاتورة لها
        for (var tripId in tripIds) {
          invoicedTripIds.add(tripId.toString());
        }

        // جلب تفاصيل الرحلات للفاتورة
        List<Map<String, dynamic>> invoiceTrips = [];
        double totalNolon = 0;
        double totalOvernight = 0;
        double totalHoliday = 0;

        for (var tripId in tripIds) {
          final tripDoc = await _firestore
              .collection('dailyWork')
              .doc(tripId.toString())
              .get();
          if (tripDoc.exists) {
            final tripData = tripDoc.data() as Map<String, dynamic>;
            invoiceTrips.add({
              'selectedRoute': tripData['loadingLocation'] ?? '',
              'selectedRoute2': tripData['unloadingLocation'] ?? '',
              'vehicleType': tripData['selectedVehicleType'] ?? '',

              'nolon': (tripData['noLon'] ?? tripData['nolon'] ?? 0).toDouble(),
              'companyOvernight': (tripData['companyOvernight'] ?? 0)
                  .toDouble(),
              'companyHoliday': (tripData['companyHoliday'] ?? 0).toDouble(),
              'tr': tripData['tr'] ?? '',
              'companyLocationName': tripData['companyLocationName'] ?? '',
            });

            totalNolon += (tripData['noLon'] ?? tripData['nolon'] ?? 0)
                .toDouble();
            totalOvernight += (tripData['companyOvernight'] ?? 0).toDouble();
            totalHoliday += (tripData['companyHoliday'] ?? 0).toDouble();
          }
        }

        invoicesList.add({
          'id': doc.id,
          'name': data['name'] ?? 'فاتورة بدون اسم',
          'companyName': data['companyName'] ?? 'شركة غير معروفة',
          'totalAmount': (data['totalAmount'] ?? 0).toDouble(),
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
          'tripIds': tripIds,
          'tripCount': tripIds.length,
          'invoiceTrips': invoiceTrips,
          'nolonTotal': totalNolon,
          'overnightTotal': totalOvernight,
          'holidayTotal': totalHoliday,
        });
      }

      // 3. تحديث الرحلات لمعرفة أيها تم عمل فاتورة له
      for (var trip in allTrips) {
        trip['hasInvoice'] = invoicedTripIds.contains(trip['id']);
      }

      // 4. فصل الرحلات: المتاحة للفاتورة (التي ليس لها فاتورة)
      final availableTrips = allTrips
          .where((trip) => !trip['hasInvoice'])
          .toList();

      // ترتيب الرحلات المتاحة للفاتورة: الأقدم أولاً، ثم تجميع الـ TR المتشابه
      final sortedAvailableTrips = _sortAndGroupTripsForInvoice(availableTrips);

      setState(() {
        _companyWork = allTrips;
        _availableTripsForInvoice = sortedAvailableTrips;
        _companyInvoices = invoicesList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('خطأ في تحميل بيانات الشركة: $e');
    }
  }

  // ================================
  // ترتيب وتجميع الرحلات للفاتورة
  // ================================
  List<Map<String, dynamic>> _sortAndGroupTripsForInvoice(
    List<Map<String, dynamic>> trips,
  ) {
    if (trips.isEmpty) return [];

    // 1. ترتيب الرحلات حسب التاريخ (الأقدم أولاً)
    trips.sort((a, b) {
      final dateA = a['date'] as DateTime? ?? DateTime(1900);
      final dateB = b['date'] as DateTime? ?? DateTime(1900);
      return dateA.compareTo(dateB);
    });

    // 2. تجميع الرحلات حسب التاريخ والـ TR
    final Map<String, List<Map<String, dynamic>>> groupedTrips = {};

    for (var trip in trips) {
      final date = trip['date'] as DateTime?;
      final tr = trip['tr']?.toString() ?? '';
      final dateKey = date != null
          ? DateFormat('yyyy-MM-dd').format(date)
          : 'unknown_date';

      // المفتاح: التاريخ + الـ TR
      final key = '$dateKey|$tr';

      if (!groupedTrips.containsKey(key)) {
        groupedTrips[key] = [];
      }
      groupedTrips[key]!.add(trip);
    }

    // 3. تحويل المجموعات إلى قائمة مرتبة
    final List<Map<String, dynamic>> result = [];

    // الحصول على المفاتيح وترتيبها حسب التاريخ
    final sortedKeys = groupedTrips.keys.toList()
      ..sort((a, b) {
        // استخراج التاريخ من المفتاح
        final datePartA = a.split('|')[0];
        final datePartB = b.split('|')[0];
        return datePartA.compareTo(datePartB);
      });

    // إضافة الرحلات المجمعة
    for (var key in sortedKeys) {
      final tripsInGroup = groupedTrips[key]!;

      // ترتيب الرحلات داخل المجموعة حسب الوقت إذا كان موجوداً
      tripsInGroup.sort((a, b) {
        final timeA = (a['date'] as DateTime?)?.toIso8601String() ?? '';
        final timeB = (b['date'] as DateTime?)?.toIso8601String() ?? '';
        return timeA.compareTo(timeB);
      });

      result.addAll(tripsInGroup);
    }

    return result;
  }

  // ================================
  // دوال التصفية والبحث
  // ================================
  List<Map<String, dynamic>> _applySearchFilter(
    List<Map<String, dynamic>> companies,
  ) {
    if (_searchQuery.isEmpty) return companies;
    return companies
        .where(
          (c) => c['companyName'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  // ================================
  // دوال قسم إنشاء الفاتورة
  // ================================
  void _toggleTripSelection(Map<String, dynamic> trip, bool selected) {
    setState(() {
      if (selected) {
        _selectedTripsForInvoice.add(trip);
      } else {
        _selectedTripsForInvoice.removeWhere((t) => t['id'] == trip['id']);
      }
    });
  }

  void _selectAllTrips(bool select) {
    setState(() {
      if (select) {
        _selectedTripsForInvoice.clear();
        _selectedTripsForInvoice.addAll(_availableTripsForInvoice);
      } else {
        _selectedTripsForInvoice.clear();
      }
    });
  }

  Future<void> _createInvoice() async {
    if (_selectedTripsForInvoice.isEmpty) {
      _showError('يرجى اختيار رحلات لإنشاء الفاتورة');
      return;
    }

    if (_invoiceNameController.text.isEmpty) {
      _showError('يرجى إدخال اسم الفاتورة');
      return;
    }

    setState(() => _isCreatingInvoice = true);

    try {
      // حساب إجمالي المبالغ
      double totalNolon = 0;
      double totalOvernight = 0;
      double totalHoliday = 0;
      List<String> tripIds = [];
      List<Map<String, dynamic>> invoiceTripDetails = [];

      for (var trip in _selectedTripsForInvoice) {
        totalNolon += trip['nolon'];
        totalOvernight += trip['companyOvernight'];
        totalHoliday += trip['companyHoliday'];
        tripIds.add(trip['id']);

        invoiceTripDetails.add({
          'selectedRoute': trip['selectedRoute'],
          'selectedRoute2': trip['selectedRoute2'],
          'vehicleType': trip['vehicleType'],

          'nolon': trip['nolon'],
          'companyOvernight': trip['companyOvernight'],
          'companyHoliday': trip['companyHoliday'],
          'tr': trip['tr'],
          'companyLocationName': trip['companyLocationName'],
          'date': trip['date'],
        });
      }

      double totalAmount = totalNolon + totalOvernight + totalHoliday;

      // حفظ الفاتورة
      await _firestore.collection('invoices').add({
        'name': _invoiceNameController.text.trim(),
        'companyName': _selectedCompany!,
        'companyId': _selectedCompanyId!,
        'totalAmount': totalAmount,
        'nolonTotal': totalNolon,
        'overnightTotal': totalOvernight,
        'holidayTotal': totalHoliday,
        'tripIds': tripIds,
        'tripDetails': invoiceTripDetails,
        'tripCount': tripIds.length,
        'createdAt': Timestamp.now(),
        'status': 'غير مدفوعة',
      });

      // تحديث حالة الرحلات في dailyWork
      final batch = _firestore.batch();
      for (var tripId in tripIds) {
        batch.update(_firestore.collection('dailyWork').doc(tripId), {
          'hasInvoice': true,
        });
      }
      await batch.commit();

      // تحديث حساب الشركة في companySummaries
      await _updateCompanySummaryAfterInvoice(totalAmount);

      _showSuccess('تم إنشاء الفاتورة بنجاح');

      // إعادة تحميل بيانات الشركة
      await _loadCompanyData(_selectedCompany!, _selectedCompanyId!);

      // تنظيف المتغيرات
      _selectedTripsForInvoice.clear();
      _invoiceNameController.clear();

      // الذهاب إلى قسم الفواتير
      _changeSection(2);
    } catch (e) {
      _showError('خطأ في إنشاء الفاتورة: $e');
    } finally {
      setState(() => _isCreatingInvoice = false);
    }
  }

  // ================================
  // تحديث حساب الشركة بعد إنشاء الفاتورة
  // ================================
  Future<void> _updateCompanySummaryAfterInvoice(double invoiceAmount) async {
    try {
      final summaryRef = _firestore
          .collection('companySummaries')
          .doc(_selectedCompanyId!);

      final summaryDoc = await summaryRef.get();

      if (summaryDoc.exists) {
        final data = summaryDoc.data() as Map<String, dynamic>;
        final currentTotalPaid = (data['totalPaidAmount'] ?? 0).toDouble();
        final newTotalPaid = currentTotalPaid + invoiceAmount;
        final totalDebt = (data['totalCompanyDebt'] ?? 0).toDouble();
        final totalRemaining = totalDebt - newTotalPaid;

        String status;
        if (totalRemaining <= 0) {
          status = 'منتهية';
        } else if (newTotalPaid > 0) {
          status = 'شبه منتهية';
        } else {
          status = 'جارية';
        }

        await summaryRef.update({
          'totalPaidAmount': newTotalPaid,
          'totalRemainingAmount': totalRemaining,
          'status': status,
          'lastUpdated': Timestamp.now(),
        });

        debugPrint('✅ تم تحديث حساب الشركة بعد إنشاء الفاتورة');
      }
    } catch (e) {
      debugPrint('⚠️ خطأ في تحديث حساب الشركة بعد الفاتورة: $e');
    }
  }

  // ================================
  // دوال مساعدة
  // ================================
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} ج';
  }

  String _formatCurrencyForPDF(double amount) {
    return amount.toStringAsFixed(2);
  }

  void _changeSection(int section) {
    setState(() {
      _currentSection = section;
      if (section == 1) {
        _selectedTripsForInvoice.clear();
        _invoiceNameController.clear();
      }
    });
  }

  void _backToCompanies() {
    setState(() {
      _selectedCompany = null;
      _selectedCompanyId = null;
      _companyWork.clear();
      _availableTripsForInvoice.clear();
      _companyInvoices.clear();
      _selectedTripsForInvoice.clear();
      _invoiceNameController.clear();
      _hasSyncedOnEnter = false; // إعادة تعيين لعند الدخول التالي
    });
    _loadCompanies();
  }

  // ================================
  // دوال الطباعة
  // ================================//////////////////////////////////////////////////////////////////////////////////////

  Future<void> _printInvoice(Map<String, dynamic> invoice) async {
    if (_arabicFont == null) {
      await _loadArabicFont();
    }

    setState(() => _isGeneratingPDF = true);

    try {
      final trips =
          invoice['invoiceTrips'] as List<Map<String, dynamic>>? ?? [];

      final invoiceId = invoice['id']?.toString() ?? '623';
      final createdAt = invoice['createdAt'] as DateTime?;
      final companyName = invoice['companyName'] ?? ' ';
      final name = invoice['name'] ?? '';

      final groupedTrips = _groupTripsForInvoice(trips);
      final location = _getCompanyLocationName(trips);

      final total = groupedTrips.fold<double>(0.0, (sum, e) {
        final value = e['total'];
        if (value is num) {
          return sum + value.toDouble();
        }
        return sum;
      });

      final tax = total * 0.14;
      final afterTax = total - tax;

      final pdf = pdfLib.Document(
        theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
      );

      pdf.addPage(
        pdfLib.Page(
          pageFormat: pdfLib.PdfPageFormat.a4,
          margin: const pdfLib.EdgeInsets.all(20),
          build: (_) => pdfLib.Directionality(
            textDirection: pdfLib.TextDirection.rtl,
            child: pdfLib.Column(
              crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
              children: [
                _invoiceHeader(
                  invoiceId,
                  createdAt,
                  companyName,
                  location,
                  name,
                ),
                pdfLib.SizedBox(height: 10),
                _invoiceTable(groupedTrips),
                pdfLib.SizedBox(height: 5),
                _totalsSection(total, tax, afterTax),
              ],
            ),
          ),
        ),
      );

      await Printing.layoutPdf(
        name: '$name',
        onLayout: (_) async => pdf.save(),
      );

      _showSuccess('تم طباعة الفاتورة بنجاح');
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isGeneratingPDF = false);
    }
  }

  pdfLib.Widget _invoiceHeader(
    String invoiceId,
    DateTime? date,
    String company,
    String location,
    String name,
  ) {
    return pdfLib.Column(
      children: [
        pdfLib.Row(
          mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
          children: [
            pdfLib.Column(
              crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
              children: [
                pdfLib.Text('شركة نيوجراند لخدمات النقل'),
                pdfLib.Text('السادة شركة : $company'),
                pdfLib.Text('مذكور للمشروعات'),
                pdfLib.Text('موقع : ${location.isNotEmpty ? location : '_ '}'),
              ],
            ),
            pdfLib.Column(
              children: [
                pdfLib.Text(
                  '$name',
                  style: pdfLib.TextStyle(
                    font: _arabicFont,
                    fontSize: 18,
                    fontWeight: pdfLib.FontWeight.bold,
                    decoration: pdfLib.TextDecoration.underline,
                  ),
                ),

                pdfLib.Text(
                  date != null
                      ? DateFormat('d/M/yyyy').format(date)
                      : '1/2/2023',
                  style: pdfLib.TextStyle(font: _arabicFont, fontSize: 11),
                ),
              ],
            ),
            pdfLib.Column(
              children: [
                pdfLib.Container(
                  width: 55,
                  height: 55,
                  decoration: pdfLib.BoxDecoration(
                    color: pdfLib.PdfColors.black,
                    shape: pdfLib.BoxShape.circle,
                  ),
                ),
                pdfLib.Text(
                  'New grand',
                  style: pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        pdfLib.Divider(),
      ],
    );
  }

  pdfLib.Widget _invoiceTable(List<Map<String, dynamic>> rows) {
    return pdfLib.Table(
      border: pdfLib.TableBorder.all(color: pdfLib.PdfColors.black, width: 1.3),

      columnWidths: const {
        5: pdfLib.FlexColumnWidth(1.2),
        4: pdfLib.FlexColumnWidth(1),
        3: pdfLib.FlexColumnWidth(3),
        2: pdfLib.FlexColumnWidth(1),
        1: pdfLib.FlexColumnWidth(1),
        0: pdfLib.FlexColumnWidth(1.2),
      },
      children: [
        pdfLib.TableRow(
          decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
          children: [
            _th('القيمة الاجمالية'),
            _th('السعر'),
            _th('عدد/طن'),
            _th('البيان'),
            _th('TR\nNumber'),
            _th('التاريخ'),
          ],
        ),
        ...rows.map(
          (e) => pdfLib.TableRow(
            children: [
              _td(_format(e['total'])),
              _td(_format(e['price'])),

              _td(e['count'].toString()),

              _td(e['description'], right: true),

              _td(e['tr']),
              _td(e['date']),
            ],
          ),
        ),
        ...List.generate(
          17 - rows.length > 0 ? 17 - rows.length : 0,
          (_) => pdfLib.TableRow(
            children: List.generate(6, (i) => _td(i == 5 ? '0' : '')),
          ),
        ),
      ],
    );
  }

  pdfLib.Widget _totalsSection(double total, double tax, double afterTax) {
    return pdfLib.Column(
      children: [
        pdfLib.Table(
          border: pdfLib.TableBorder.all(),

          children: [
            _totalRow('الإجمالي', total),
            _totalRow('14% ضريبة مبيعات', tax),
            _totalRow('الإجمالي بعد الضريبة', afterTax),
          ],
        ),
        pdfLib.SizedBox(height: 5),
        pdfLib.Align(
          alignment: pdfLib.Alignment.centerRight,
          child: pdfLib.Column(
            crossAxisAlignment: pdfLib.CrossAxisAlignment.end,
            children: [
              pdfLib.Text(
                'سجل تجاري : 16732',
                style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
              ),

              pdfLib.Text(
                'بطاقة ضريبة : 261-525-263',
                style: pdfLib.TextStyle(fontSize: 9),
              ),
            ],
          ),
        ),
        pdfLib.Text(
          'الفاتورة الغير مختومة بختم الشركة لايعتد بها',
          style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
        ),
      ],
    );
  }

  pdfLib.Widget _th(String t) => pdfLib.Padding(
    padding: const pdfLib.EdgeInsets.all(5),
    child: pdfLib.Text(
      t,
      textAlign: pdfLib.TextAlign.center,
      style: pdfLib.TextStyle(
        font: _arabicFont,
        fontWeight: pdfLib.FontWeight.bold,
        fontSize: 10,
      ),
    ),
  );

  pdfLib.Widget _td(String t, {bool right = false}) => pdfLib.Padding(
    padding: const pdfLib.EdgeInsets.all(5),
    child: pdfLib.Text(
      t,
      textAlign: right ? pdfLib.TextAlign.right : pdfLib.TextAlign.center,
      style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
    ),
  );

  pdfLib.TableRow _totalRow(String label, double v) {
    return pdfLib.TableRow(children: [_td(_format(v)), _td(label)]);
  }

  String _format(num v) => v.toStringAsFixed(0);

  String _getCompanyLocationName(List<Map<String, dynamic>> trips) {
    for (final t in trips) {
      final l = t['companyLocationName']?.toString() ?? '';
      if (l.isNotEmpty) return l;
    }
    return '';
  }

  // Future<void> _printInvoice(Map<String, dynamic> invoice) async {
  //   if (_arabicFont == null) {
  //     await _loadArabicFont();
  //     if (_arabicFont == null) {
  //       _showError('تعذر تحميل الخط العربي');
  //       return;
  //     }
  //   }

  //   setState(() => _isGeneratingPDF = true);

  //   try {
  //     final invoiceTrips =
  //         invoice['invoiceTrips'] as List<Map<String, dynamic>>;
  //     final companyName = invoice['companyName'] ?? 'غير معروف';
  //     final invoiceName = invoice['name'] ?? 'فاتورة';
  //     final invoiceId = invoice['id'] ?? '';
  //     final createdAt = invoice['createdAt'] as DateTime?;
  //     final companyLocationName = _getCompanyLocationName(invoiceTrips);

  //     final groupedTrips = _groupTripsForInvoice(invoiceTrips);

  //     final pdf = pdfLib.Document(
  //       theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
  //     );

  //     pdf.addPage(
  //       pdfLib.Page(
  //         pageFormat: pdfLib.PdfPageFormat.a4,
  //         margin: pdfLib.EdgeInsets.all(20),
  //         build: (context) {
  //           return pdfLib.Directionality(
  //             textDirection: pdfLib.TextDirection.rtl,
  //             child: pdfLib.Column(
  //               crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
  //               children: [
  //                 _buildInvoiceHeader(
  //                   companyName,
  //                   invoiceId,
  //                   createdAt,
  //                   companyLocationName,
  //                 ),
  //                 pdfLib.SizedBox(height: 20),
  //                 _buildInvoiceTable(groupedTrips),
  //                 pdfLib.Spacer(),
  //                 _buildInvoiceTotals(invoice),
  //               ],
  //             ),
  //           );
  //         },
  //       ),
  //     );

  //     await Printing.layoutPdf(
  //       onLayout: (pdfLib.PdfPageFormat format) async => pdf.save(),
  //       name:
  //           'فاتورة_${invoiceName}_${DateFormat('yyyyMMdd').format(createdAt ?? DateTime.now())}',
  //     );

  //     _showSuccess('تم طباعة الفاتورة بنجاح');
  //   } catch (e) {
  //     _showError('خطأ في طباعة الفاتورة: $e');
  //     debugPrint('خطأ في طباعة الفاتورة: $e');
  //   } finally {
  //     setState(() => _isGeneratingPDF = false);
  //   }
  // }

  // pdfLib.Widget _buildInvoiceHeader(
  //   String companyName,
  //   String invoiceId,
  //   DateTime? createdAt,
  //   String companyLocationName,
  // ) {
  //   return pdfLib.Column(
  //     children: [
  //       // الصف الأول: الشعار والفاتورة والتاريخ
  //       pdfLib.Row(
  //         mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
  //         crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
  //         children: [
  //           // الشعار على اليسار
  //           pdfLib.Container(
  //             width: 80,
  //             height: 80,
  //             child: pdfLib.Column(
  //               mainAxisAlignment: pdfLib.MainAxisAlignment.center,
  //               children: [
  //                 pdfLib.Container(
  //                   width: 60,
  //                   height: 60,
  //                   decoration: pdfLib.BoxDecoration(
  //                     shape: pdfLib.BoxShape.circle,
  //                     color: pdfLib.PdfColors.black,
  //                   ),
  //                 ),
  //                 pdfLib.SizedBox(height: 5),
  //                 pdfLib.Text(
  //                   'New grand',
  //                   style: pdfLib.TextStyle(
  //                     fontSize: 12,
  //                     fontWeight: pdfLib.FontWeight.bold,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),

  //           // معلومات الفاتورة في المنتصف
  //           pdfLib.Expanded(
  //             child: pdfLib.Column(
  //               crossAxisAlignment: pdfLib.CrossAxisAlignment.center,
  //               children: [
  //                 pdfLib.Row(
  //                   mainAxisAlignment: pdfLib.MainAxisAlignment.center,
  //                   children: [
  //                     pdfLib.Text(
  //                       'فاتورة ',
  //                       style: pdfLib.TextStyle(
  //                         fontSize: 18,
  //                         fontWeight: pdfLib.FontWeight.bold,
  //                         font: _arabicFont,
  //                         decoration: pdfLib.TextDecoration.underline,
  //                       ),
  //                     ),
  //                     pdfLib.Text(
  //                       invoiceId,
  //                       style: pdfLib.TextStyle(
  //                         fontSize: 18,
  //                         fontWeight: pdfLib.FontWeight.bold,
  //                         font: _arabicFont,
  //                         decoration: pdfLib.TextDecoration.underline,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 pdfLib.SizedBox(height: 5),
  //                 pdfLib.Text(
  //                   createdAt != null
  //                       ? DateFormat('d/M/yyyy').format(createdAt)
  //                       : '1/2/2023',
  //                   style: pdfLib.TextStyle(fontSize: 12, font: _arabicFont),
  //                 ),
  //               ],
  //             ),
  //           ),

  //           // التاريخ على اليمين
  //           pdfLib.Container(
  //             width: 80,
  //             child: pdfLib.Column(
  //               crossAxisAlignment: pdfLib.CrossAxisAlignment.end,
  //               children: [
  //                 pdfLib.Text(
  //                   'التاريخ :',
  //                   style: pdfLib.TextStyle(fontSize: 11, font: _arabicFont),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),

  //       pdfLib.SizedBox(height: 10),

  //       // معلومات الشركة
  //       pdfLib.Column(
  //         crossAxisAlignment: pdfLib.CrossAxisAlignment.end,
  //         children: [
  //           pdfLib.Row(
  //             mainAxisAlignment: pdfLib.MainAxisAlignment.end,
  //             children: [
  //               pdfLib.Text(
  //                 companyName,
  //                 style: pdfLib.TextStyle(fontSize: 11, font: _arabicFont),
  //               ),
  //               pdfLib.SizedBox(width: 10),
  //               pdfLib.Text(
  //                 'السادة شركة',
  //                 style: pdfLib.TextStyle(fontSize: 11, font: _arabicFont),
  //               ),
  //             ],
  //           ),
  //           pdfLib.SizedBox(height: 3),
  //           pdfLib.Text(
  //             'مذكور للمشروعات',
  //             style: pdfLib.TextStyle(fontSize: 11, font: _arabicFont),
  //           ),
  //           pdfLib.SizedBox(height: 3),
  //           pdfLib.Row(
  //             mainAxisAlignment: pdfLib.MainAxisAlignment.end,
  //             children: [
  //               pdfLib.Text(
  //                 companyLocationName.isNotEmpty
  //                     ? companyLocationName
  //                     : 'امتداد محور التعمير-195',
  //                 style: pdfLib.TextStyle(fontSize: 11, font: _arabicFont),
  //               ),
  //               pdfLib.SizedBox(width: 10),
  //               pdfLib.Text(
  //                 'موقع :',
  //                 style: pdfLib.TextStyle(fontSize: 11, font: _arabicFont),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  // // ================================
  // // بناء جدول الفاتورة
  // // ================================
  // pdfLib.Widget _buildInvoiceTable(List<Map<String, dynamic>> groupedTrips) {
  //   return pdfLib.Table(
  //     border: pdfLib.TableBorder.all(color: pdfLib.PdfColors.black, width: 1),
  //     children: [
  //       // رأس الجدول
  //       pdfLib.TableRow(
  //         decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
  //         children: [
  //           _buildHeaderCell('التاريخ'),
  //           _buildHeaderCell('TR\nNumber'),
  //           _buildHeaderCell('البيان'),
  //           _buildHeaderCell('عدد/طن'),
  //           _buildHeaderCell('السعر'),
  //           _buildHeaderCell('القيمة الاجمالية'),
  //         ],
  //       ),

  //       // صفوف البيانات
  //       ...groupedTrips.map(
  //         (trip) => pdfLib.TableRow(
  //           children: [
  //             _buildDataCell(trip['date'] ?? '-'),
  //             _buildDataCell(trip['tr']?.toString() ?? '-'),
  //             _buildDataCell(
  //               trip['description'] ?? '-',
  //               align: pdfLib.TextAlign.right,
  //             ),
  //             _buildDataCell((trip['count'] ?? 0).toString()),
  //             _buildDataCell(_formatCurrencyForPDF(trip['price'] ?? 0)),
  //             _buildDataCell(_formatCurrencyForPDF(trip['total'] ?? 0)),
  //           ],
  //         ),
  //       ),

  //       // صفوف فارغة إضافية (20 صف كحد أقصى)
  //       ...List.generate(
  //         20 - groupedTrips.length > 0 ? 20 - groupedTrips.length : 0,
  //         (index) => pdfLib.TableRow(
  //           children: [
  //             _buildDataCell(''),
  //             _buildDataCell(''),
  //             _buildDataCell(''),
  //             _buildDataCell(''),
  //             _buildDataCell(''),
  //             _buildDataCell('0'),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // pdfLib.Widget _buildHeaderCell(String text) {
  //   return pdfLib.Container(
  //     padding: pdfLib.EdgeInsets.all(5),
  //     alignment: pdfLib.Alignment.center,
  //     child: pdfLib.Text(
  //       text,
  //       style: pdfLib.TextStyle(
  //         fontSize: 10,
  //         fontWeight: pdfLib.FontWeight.bold,
  //         font: _arabicFont,
  //       ),
  //       textAlign: pdfLib.TextAlign.center,
  //     ),
  //   );
  // }

  // pdfLib.Widget _buildDataCell(
  //   String text, {
  //   pdfLib.TextAlign align = pdfLib.TextAlign.center,
  // }) {
  //   return pdfLib.Container(
  //     padding: pdfLib.EdgeInsets.all(5),
  //     alignment: align == pdfLib.TextAlign.right
  //         ? pdfLib.Alignment.centerRight
  //         : pdfLib.Alignment.center,
  //     child: pdfLib.Text(
  //       text,
  //       style: pdfLib.TextStyle(fontSize: 9, font: _arabicFont),
  //       textAlign: align,
  //     ),
  //   );
  // }

  // // ================================
  // // بناء قسم الإجماليات
  // // ================================
  // pdfLib.Widget _buildInvoiceTotals(Map<String, dynamic> invoice) {
  //   final totalAmount = (invoice['totalAmount'] ?? 0).toDouble();
  //   final tax = totalAmount * 0.14;
  //   final totalAfterTax = totalAmount + tax;

  //   return pdfLib.Column(
  //     crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
  //     children: [
  //       pdfLib.Container(
  //         decoration: pdfLib.BoxDecoration(
  //           border: pdfLib.Border.all(color: pdfLib.PdfColors.black),
  //         ),
  //         child: pdfLib.Table(
  //           border: pdfLib.TableBorder.all(color: pdfLib.PdfColors.black),
  //           children: [
  //             pdfLib.TableRow(
  //               children: [
  //                 _buildTotalCell(_formatCurrencyForPDF(totalAmount)),
  //                 _buildTotalCell('الإجمالي', isLabel: true),
  //               ],
  //             ),
  //             pdfLib.TableRow(
  //               children: [
  //                 _buildTotalCell(_formatCurrencyForPDF(tax)),
  //                 _buildTotalCell('14%ضريبة مبيعات', isLabel: true),
  //               ],
  //             ),
  //             pdfLib.TableRow(
  //               children: [
  //                 _buildTotalCell(_formatCurrencyForPDF(totalAfterTax)),
  //                 _buildTotalCell('الإجمالي بعد الضريبة', isLabel: true),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),

  //       pdfLib.SizedBox(height: 10),

  //       // معلومات الشركة في الأسفل
  //       pdfLib.Row(
  //         mainAxisAlignment: pdfLib.MainAxisAlignment.end,
  //         children: [
  //           pdfLib.Column(
  //             crossAxisAlignment: pdfLib.CrossAxisAlignment.end,
  //             children: [
  //               pdfLib.Row(
  //                 children: [
  //                   pdfLib.Text(
  //                     '16732',
  //                     style: pdfLib.TextStyle(fontSize: 9, font: _arabicFont),
  //                   ),
  //                   pdfLib.SizedBox(width: 5),
  //                   pdfLib.Text(
  //                     'سجل تجاري :',
  //                     style: pdfLib.TextStyle(fontSize: 9, font: _arabicFont),
  //                   ),
  //                 ],
  //               ),
  //               pdfLib.SizedBox(height: 2),
  //               pdfLib.Row(
  //                 children: [
  //                   pdfLib.Text(
  //                     '261-525-263',
  //                     style: pdfLib.TextStyle(fontSize: 9, font: _arabicFont),
  //                   ),
  //                   pdfLib.SizedBox(width: 5),
  //                   pdfLib.Text(
  //                     'بطاقة ضريبة :',
  //                     style: pdfLib.TextStyle(fontSize: 9, font: _arabicFont),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),

  //       pdfLib.SizedBox(height: 5),

  //       pdfLib.Text(
  //         'الفاتورة الغير مختومة بختم الشركة لايعتد بها',
  //         style: pdfLib.TextStyle(fontSize: 9, font: _arabicFont),
  //         textAlign: pdfLib.TextAlign.center,
  //       ),
  //     ],
  //   );
  // }

  // pdfLib.Widget _buildTotalCell(String text, {bool isLabel = false}) {
  //   return pdfLib.Container(
  //     padding: pdfLib.EdgeInsets.all(5),
  //     alignment: pdfLib.Alignment.center,
  //     child: pdfLib.Text(
  //       text,
  //       style: pdfLib.TextStyle(
  //         fontSize: 10,
  //         font: _arabicFont,
  //         fontWeight: isLabel
  //             ? pdfLib.FontWeight.bold
  //             : pdfLib.FontWeight.normal,
  //       ),
  //       textAlign: pdfLib.TextAlign.center,
  //     ),
  //   );
  // }
  ////////////////////////////////////////////////////////////////////////////////////////////////////////
  // ================================
  // تجميع الرحلات
  // ================================
  List<Map<String, dynamic>> _groupTripsForInvoice(
    List<Map<String, dynamic>> trips,
  ) {
    final Map<String, Map<String, dynamic>> grouped = {};

    for (final trip in trips) {
      final date = trip['date'] != null
          ? DateFormat('d/M/yyyy').format((trip['date'] as DateTime))
          : DateFormat('d/M/yyyy').format(DateTime.now());
      final tr = trip['tr']?.toString() ?? '';
      final nolon = (trip['nolon'] ?? 0).toDouble();
      final companyOvernight = (trip['companyOvernight'] ?? 0).toDouble();
      final companyHoliday = (trip['companyHoliday'] ?? 0).toDouble();
      final selectedRoute = trip['selectedRoute']?.toString() ?? '';
      final selectedRoute2 = trip['selectedRoute2']?.toString() ?? '';
      final vehicleType = trip['vehicleType']?.toString() ?? '';

      final companyLocationName = trip['companyLocationName']?.toString() ?? '';

      String description = " ";
      if (companyLocationName.isNotEmpty) {
        description +=
            '   تحميل على ${vehicleType} من  ${selectedRoute}  الى  ${selectedRoute2} ';
      }

      final key = '$date|$tr|$nolon|$selectedRoute';

      if (!grouped.containsKey(key)) {
        grouped[key] = {
          'date': date,
          'tr': tr,
          'description': description,
          'nolon': nolon,
          'nolonCount': 1,
          'overnight': companyOvernight,
          'overnightCount': companyOvernight > 0 ? 1 : 0,
          'holiday': companyHoliday,
          'holidayCount': companyHoliday > 0 ? 1 : 0,
          'selectedRoute': selectedRoute,
          'companyLocationName': companyLocationName,
        };
      } else {
        final existing = grouped[key]!;
        existing['nolonCount'] = (existing['nolonCount'] as int) + 1;
        if (companyOvernight > 0) {
          existing['overnightCount'] = (existing['overnightCount'] as int) + 1;
        }
        if (companyHoliday > 0) {
          existing['holidayCount'] = (existing['holidayCount'] as int) + 1;
        }
      }
    }

    final List<Map<String, dynamic>> result = [];

    grouped.forEach((key, tripGroup) {
      if (tripGroup['nolonCount'] > 0) {
        result.add({
          'type': 'نولون',
          'date': tripGroup['date'],
          'tr': tripGroup['tr'],
          'description': tripGroup['description'],
          'count': tripGroup['nolonCount'],
          'price': tripGroup['nolon'],
          'total':
              (tripGroup['nolonCount'] as int) * (tripGroup['nolon'] as double),
        });
      }
      if (tripGroup['overnightCount'] > 0) {
        result.add({
          'type': 'مبيت',
          'date': tripGroup['date'],
          'tr': tripGroup['tr'],
          'description': 'مبيت >>>${tripGroup['description']}',
          'count': tripGroup['overnightCount'],
          'price': tripGroup['overnight'],
          'total':
              (tripGroup['overnightCount'] as int) *
              (tripGroup['overnight'] as double),
        });
      }
      if (tripGroup['holidayCount'] > 0) {
        result.add({
          'type': 'عطلة',
          'date': tripGroup['date'],
          'tr': tripGroup['tr'],
          'description': 'عطلة >>>${tripGroup['description']}',
          'count': tripGroup['holidayCount'],
          'price': tripGroup['holiday'],
          'total':
              (tripGroup['holidayCount'] as int) *
              (tripGroup['holiday'] as double),
        });
      }
    });

    return result;
  }

  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // ================================
  // بناء الواجهة
  // ================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Column(
        children: [
          _buildCustomAppBar(),
          if (_selectedCompany == null) _buildSearchBar(),
          Expanded(
            child: _selectedCompany == null
                ? _buildCompanyList()
                : _buildCompanySections(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            /// زر واحد فقط (شركة أو رجوع)
            IconButton(
              icon: Icon(
                _selectedCompany == null ? Icons.business : Icons.arrow_back,
                color: Colors.white,
                size: 28,
              ),
              onPressed: _selectedCompany != null ? _backToCompanies : null,
            ),

            const SizedBox(width: 8),

            Expanded(
              child: Center(
                child: Text(
                  _selectedCompany == null ? 'اختر شركة' : '$_selectedCompany',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            if (_selectedCompany == null)
              IconButton(
                icon: const Icon(Icons.sync, color: Colors.white),
                onPressed: _syncDataOnPageEnter,
                tooltip: 'مزامنة حسابات الشركات',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF3498DB)),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF3498DB), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _filteredCompanies = _applySearchFilter(_allCompanies);
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'ابحث عن شركة...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _searchQuery = '';
                    _filteredCompanies = _applySearchFilter(_allCompanies);
                  });
                },
                child: const Icon(Icons.clear, size: 18, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return _filteredCompanies.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.business, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'لا توجد شركات',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _filteredCompanies.length,
            itemBuilder: (context, index) {
              final company = _filteredCompanies[index];
              return _buildCompanyCard(company);
            },
          );
  }

  Widget _buildCompanyCard(Map<String, dynamic> company) {
    final companyName = company['companyName'];
    final companyId = company['companyId'];
    final totalTrips = company['totalTrips'] ?? 0;
    final totalNolon = company['totalNolon'] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: totalTrips > 0 ? const Color(0xFF3498DB) : Colors.grey,
            borderRadius: BorderRadius.circular(22.5),
          ),
          child: Center(
            child: Text(
              totalTrips.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          companyName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: totalTrips > 0 ? const Color(0xFF2C3E50) : Colors.grey,
          ),
        ),
        subtitle: Text(
          totalTrips > 0
              ? '$totalTrips رحلة - ${_formatCurrency(totalNolon)}'
              : 'لا توجد رحلات',
          style: TextStyle(
            color: totalTrips > 0 ? Colors.green : Colors.grey,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF3498DB),
          size: 16,
        ),
        onTap: () => _loadCompanyData(companyName, companyId),
      ),
    );
  }

  Widget _buildCompanySections() {
    return Column(
      children: [
        // تبويبات الأقسام
        _buildSectionTabs(),
        Expanded(
          child: _currentSection == 0
              ? _buildWorkTable()
              : _currentSection == 1
              ? _buildCreateInvoiceSection()
              : _buildInvoicesSection(),
        ),
      ],
    );
  }

  Widget _buildSectionTabs() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _buildSectionTab(0, Icons.list, 'شغل الشركات'),
          _buildSectionTab(1, Icons.receipt, 'إنشاء فاتورة'),
          _buildSectionTab(2, Icons.list_alt, 'الفواتير'),
        ],
      ),
    );
  }

  Widget _buildSectionTab(int section, IconData icon, String title) {
    final isActive = _currentSection == section;
    return Expanded(
      child: InkWell(
        onTap: () => _changeSection(section),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF3498DB) : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isActive ? const Color(0xFF3498DB) : Colors.grey[300]!,
                width: 3,
              ),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.grey,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkTable() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    // ترتيب الرحلات من الأقدم إلى الأحدث
    final sortedWork = List<Map<String, dynamic>>.from(_companyWork)
      ..sort((a, b) {
        final dateA = a['date'] as DateTime? ?? DateTime(1900);
        final dateB = b['date'] as DateTime? ?? DateTime(1900);
        return dateA.compareTo(dateB);
      });

    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: sortedWork.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.business,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'لا يوجد شغل مسجل لهذه الشركة',
                          style: TextStyle(
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
                        defaultColumnWidth: const FixedColumnWidth(89),
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
                              TableCellHeader('الحالة'),
                              TableCellHeader('TR'),
                              TableCellHeader('موقع الشركة'),
                              TableCellHeader('عطلة الشركة'),
                              TableCellHeader('مبيت الشركة'),
                              TableCellHeader('نولون الشركة'),
                              TableCellHeader('اسم السائق'),
                              TableCellHeader('الكارتة'),
                              TableCellHeader('العهدة'),
                              TableCellHeader('اسم الموقع'),
                              TableCellHeader('مكان التعتيق'),
                              TableCellHeader('مكان التحميل'),
                              TableCellHeader('التاريخ'),
                              TableCellHeader('م'),
                            ],
                          ),
                          ...sortedWork.asMap().entries.map((entry) {
                            final index = entry.key;
                            final work = entry.value;
                            final hasInvoice = work['hasInvoice'];

                            return TableRow(
                              decoration: BoxDecoration(
                                color: index.isEven
                                    ? Colors.white
                                    : const Color(0xFFF8F9FA),
                              ),
                              children: [
                                TableCellBody(
                                  hasInvoice ? 'مفوتورة' : 'متاحة',
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: hasInvoice
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                                TableCellBody(
                                  work['tr'] ?? '-',
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                                TableCellBody(
                                  work['companyLocationName'] ?? '-',
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3498DB),
                                  ),
                                ),
                                TableCellBody(
                                  '${work['companyHoliday']} ج',
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                TableCellBody(
                                  '${work['companyOvernight']} ج',
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[700],
                                  ),
                                ),
                                TableCellBody(
                                  '${work['nolon']} ج',
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                TableCellBody(
                                  work['driverName'],
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
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

  Widget _buildCreateInvoiceSection() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return _availableTripsForInvoice.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.receipt, size: 80, color: Colors.grey),
                const SizedBox(height: 20),
                const Text(
                  'لا توجد رحلات متاحة للفاتورة',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'جميع الرحلات تم عمل فاتورة لها',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () => _changeSection(0),
                  icon: const Icon(Icons.list),
                  label: const Text('عرض جميع الرحلات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498DB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          )
        : Column(
            children: [
              // اسم الفاتورة
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _invoiceNameController,
                  decoration: InputDecoration(
                    labelText: 'اسم الفاتورة',
                    prefixIcon: const Icon(Icons.receipt),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),

              // أزرار التحكم
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _selectAllTrips(true),
                        icon: const Icon(Icons.check_box),
                        label: const Text('تحديد الكل'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[50],
                          foregroundColor: Colors.green[700],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _selectAllTrips(false),
                        icon: const Icon(Icons.check_box_outline_blank),
                        label: const Text('إلغاء الكل'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[50],
                          foregroundColor: Colors.red[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // جدول الرحلات المتاحة مع خيار التحديد
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Table(
                        defaultColumnWidth: const FixedColumnWidth(89),
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
                              TableCellHeader('تحديد'),
                              TableCellHeader('TR'),
                              TableCellHeader('موقع الشركة'),
                              TableCellHeader('عطلة الشركة'),
                              TableCellHeader('مبيت الشركة'),
                              TableCellHeader('نولون الشركة'),
                              TableCellHeader('اسم السائق'),
                              TableCellHeader('الكارتة'),
                              TableCellHeader('العهدة'),
                              TableCellHeader('اسم الموقع'),
                              TableCellHeader('مكان التعتيق'),
                              TableCellHeader('مكان التحميل'),
                              TableCellHeader('التاريخ'),
                              TableCellHeader('م'),
                            ],
                          ),
                          ..._availableTripsForInvoice.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final work = entry.value;
                            final isSelected = _selectedTripsForInvoice.any(
                              (trip) => trip['id'] == work['id'],
                            );

                            return TableRow(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFE8F5E9)
                                    : index.isEven
                                    ? Colors.white
                                    : const Color(0xFFF8F9FA),
                              ),
                              children: [
                                TableCell(
                                  child: Container(
                                    height: 48,
                                    alignment: Alignment.center,
                                    child: Checkbox(
                                      value: isSelected,
                                      onChanged: (value) {
                                        _toggleTripSelection(
                                          work,
                                          value ?? false,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                TableCellBody(
                                  work['tr'] ?? '-',
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                                TableCellBody(
                                  work['companyLocationName'] ?? '-',
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3498DB),
                                  ),
                                ),
                                TableCellBody(
                                  '${work['companyHoliday']} ج',
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                TableCellBody(
                                  '${work['companyOvernight']} ج',
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[700],
                                  ),
                                ),
                                TableCellBody(
                                  '${work['nolon']} ج',
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                TableCellBody(
                                  work['driverName'],
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
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

              // زر إنشاء الفاتورة
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed:
                        _selectedTripsForInvoice.isEmpty || _isCreatingInvoice
                        ? null
                        : _createInvoice,
                    icon: _isCreatingInvoice
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      _isCreatingInvoice ? 'جاري الإنشاء...' : 'إنشاء الفاتورة',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
  }

  Widget _buildInvoicesSection() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'فواتير الشركة',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3498DB),
                ),
              ),
              Text(
                '${_companyInvoices.length} فاتورة',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _companyInvoices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.receipt_long,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'لا توجد فواتير',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'قم بإنشاء فاتورة أولاً',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () => _changeSection(1),
                        icon: const Icon(Icons.add),
                        label: const Text('إنشاء فاتورة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3498DB),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _companyInvoices.length,
                  itemBuilder: (context, index) {
                    final invoice = _companyInvoices[index];
                    return _buildInvoiceCard(invoice, index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> invoice, int index) {
    final createdAt = invoice['createdAt'] as DateTime?;
    final invoiceTrips = invoice['invoiceTrips'] as List<Map<String, dynamic>>;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF3498DB),
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          invoice['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF2C3E50),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ' ${createdAt != null ? _formatDate(createdAt) : 'غير معروف'}  ---  رحلة >>> ${invoice['tripCount']}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatCurrency(invoice['totalAmount']),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'إجمالي',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: Icon(Icons.print, color: Color(0xFF3498DB)),
              onPressed: _isGeneratingPDF ? null : () => _printInvoice(invoice),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // إحصائيات الفاتورة
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'عدد الرحلات:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${invoice['tripCount']}',
                            style: const TextStyle(color: Color(0xFF3498DB)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'إجمالي النولون:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            _formatCurrency(invoice['nolonTotal']),
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'إجمالي المبيت:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                          Text(
                            _formatCurrency(invoice['overnightTotal']),
                            style: const TextStyle(color: Colors.orange),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'إجمالي العطلة:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          Text(
                            _formatCurrency(invoice['holidayTotal']),
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // زر طباعة الفاتورة
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isGeneratingPDF
                        ? null
                        : () => _printInvoice(invoice),
                    icon: _isGeneratingPDF
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.print),
                    label: Text(
                      _isGeneratingPDF ? 'جاري الطباعة...' : 'طباعة الفاتورة',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // تفاصيل الرحلات
                const Text(
                  'تفاصيل الرحلات:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 8),

                // جدول تفاصيل الرحلات
                if (invoiceTrips.isNotEmpty)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      defaultColumnWidth: const FixedColumnWidth(150),
                      border: TableBorder.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.grey[100]),
                          children: const [
                            TableCellHeader('اسم الموقع'),
                            TableCellHeader('TR'),
                            TableCellHeader('موقع الشركة'),
                            TableCellHeader('النولون'),
                            TableCellHeader('المبيت'),
                            TableCellHeader('العطلة'),
                          ],
                        ),
                        ...invoiceTrips.map((trip) {
                          return TableRow(
                            decoration: BoxDecoration(color: Colors.white),
                            children: [
                              TableCellBody(
                                trip['selectedRoute'] ?? '',
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3498DB),
                                ),
                              ),
                              TableCellBody(
                                trip['tr'] ?? '-',
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              TableCellBody(
                                trip['companyLocationName'] ?? '-',
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF3498DB),
                                ),
                              ),
                              TableCellBody(
                                _formatCurrency(trip['nolon']),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              TableCellBody(
                                _formatCurrency(trip['companyOvernight']),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                              TableCellBody(
                                _formatCurrency(trip['companyHoliday']),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _calculateInvoiceTotal() {
    double total = 0;
    for (var trip in _selectedTripsForInvoice) {
      total +=
          trip['nolon'] + trip['companyOvernight'] + trip['companyHoliday'];
    }
    return total;
  }

  double _calculateNolonTotal() {
    double total = 0;
    for (var trip in _selectedTripsForInvoice) {
      total += trip['nolon'];
    }
    return total;
  }

  double _calculateOvernightTotal() {
    double total = 0;
    for (var trip in _selectedTripsForInvoice) {
      total += trip['companyOvernight'];
    }
    return total;
  }

  double _calculateHolidayTotal() {
    double total = 0;
    for (var trip in _selectedTripsForInvoice) {
      total += trip['companyHoliday'];
    }
    return total;
  }
}

class TableCellHeader extends StatelessWidget {
  final String text;
  const TableCellHeader(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
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
      height: 38,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: textStyle ?? const TextStyle(fontSize: 12),
      ),
    );
  }
}
