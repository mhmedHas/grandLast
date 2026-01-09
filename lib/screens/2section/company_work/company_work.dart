// // // // import 'dart:async';
// // // // import 'dart:typed_data';
// // // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:intl/intl.dart';
// // // // import 'package:pdf/pdf.dart' as pdfLib;
// // // // import 'package:pdf/widgets.dart' as pdfLib;
// // // // import 'package:printing/printing.dart';
// // // // import 'package:flutter/services.dart' show rootBundle;

// // // // class CompanyWorkPage extends StatefulWidget {
// // // //   const CompanyWorkPage({super.key});

// // // //   @override
// // // //   State<CompanyWorkPage> createState() => _CompanyWorkPageState();
// // // // }

// // // // class _CompanyWorkPageState extends State<CompanyWorkPage> {
// // // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// // // //   pdfLib.Font? _arabicFont;

// // // //   // متغيرات عامة
// // // //   List<Map<String, dynamic>> _allCompanies = [];
// // // //   List<Map<String, dynamic>> _filteredCompanies = [];
// // // //   String? _selectedCompany;
// // // //   String? _selectedCompanyId;
// // // //   bool _isLoading = false;
// // // //   String _searchQuery = '';

// // // //   // متغيرات الأقسام بعد اختيار الشركة
// // // //   int _currentSection = 0; // 0: شغل الشركات، 1: إنشاء فاتورة، 2: الفواتير
// // // //   List<Map<String, dynamic>> _companyWork = []; // جميع الرحلات
// // // //   List<Map<String, dynamic>> _availableTripsForInvoice =
// // // //       []; // الرحلات المتاحة للفاتورة
// // // //   List<Map<String, dynamic>> _companyInvoices = []; // فواتير الشركة

// // // //   // متغيرات قسم إنشاء الفاتورة
// // // //   final List<Map<String, dynamic>> _selectedTripsForInvoice = [];
// // // //   final TextEditingController _invoiceNameController = TextEditingController();
// // // //   bool _isCreatingInvoice = false;
// // // //   bool _isGeneratingPDF = false;

// // // //   // متغير للمزامنة التلقائية
// // // //   bool _hasSyncedOnEnter = false;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _loadCompanies();
// // // //     _loadArabicFont();
// // // //     _loadLogoImage(); // أضف هذا السطر
// // // //   }

// // // //   // أضف هذا المتغير في بداية الكلاس
// // // //   Uint8List? _logoImageBytes;

// // // //   // أضف هذه الدالة
// // // //   Future<void> _loadLogoImage() async {
// // // //     try {
// // // //       // استخدام المسار من pubspec.yaml
// // // //       final ByteData data = await rootBundle.load('assets/image/logoo.jpeg');
// // // //       _logoImageBytes = data.buffer.asUint8List();
// // // //       debugPrint('تم تحميل صورة اللوجو بنجاح');
// // // //     } catch (e) {
// // // //       debugPrint('فشل تحميل صورة اللوجو: $e');
// // // //       _logoImageBytes = null;
// // // //     }
// // // //   }

// // // //   // ================================
// // // //   // تحميل الخط العربي للطباعة
// // // //   // ================================
// // // //   Future<void> _loadArabicFont() async {
// // // //     try {
// // // //       final fontData = await rootBundle.load(
// // // //         'assets/fonts/Amiri/Amiri-Regular.ttf',
// // // //       );

// // // //       _arabicFont = pdfLib.Font.ttf(fontData);
// // // //       debugPrint('تم تحميل الخط العربي بنجاح');
// // // //     } catch (e) {
// // // //       debugPrint('فشل تحميل الخط العربي: $e');
// // // //       _arabicFont = pdfLib.Font.courier();
// // // //     }
// // // //   }

// // // //   // ================================
// // // //   // نظام مزامنة companySummaries تلقائياً
// // // //   // ================================
// // // //   Future<void> _syncDataOnPageEnter() async {
// // // //     debugPrint('🔄 بدء التحديث التلقائي لحسابات الشركات...');

// // // //     try {
// // // //       // 1. جلب جميع حسابات الشركات
// // // //       final companySummaries = await _firestore
// // // //           .collection('companySummaries')
// // // //           .get();

// // // //       // 2. حساب إجمالي الرحلات من dailyWork لكل شركة
// // // //       final dailyWorkSnapshot = await _firestore.collection('dailyWork').get();

// // // //       Map<String, int> dailyWorkTripCounts = {};
// // // //       Map<String, double> dailyWorkTotalDebts = {};
// // // //       Map<String, String> companyNames = {};

// // // //       for (final doc in dailyWorkSnapshot.docs) {
// // // //         final data = doc.data();
// // // //         final companyId = data['companyId'] as String?;
// // // //         final companyName = data['companyName'] as String?;

// // // //         if (companyId != null && companyName != null) {
// // // //           // حساب عدد الرحلات
// // // //           dailyWorkTripCounts[companyId] =
// // // //               (dailyWorkTripCounts[companyId] ?? 0) + 1;
// // // //           companyNames[companyId] = companyName;

// // // //           // حساب إجمالي الدين
// // // //           final nolon = (data['nolon'] ?? data['noLon'] ?? 0).toDouble();
// // // //           final overnight = (data['companyOvernight'] ?? 0).toDouble();
// // // //           final holiday = (data['companyHoliday'] ?? 0).toDouble();

// // // //           dailyWorkTotalDebts[companyId] =
// // // //               (dailyWorkTotalDebts[companyId] ?? 0.0) +
// // // //               nolon +
// // // //               overnight +
// // // //               holiday;
// // // //         }
// // // //       }

// // // //       // 3. المقارنة والتحديث
// // // //       final batch = _firestore.batch();
// // // //       final summariesRef = _firestore.collection('companySummaries');

// // // //       int updatedCount = 0;

// // // //       for (final entry in dailyWorkTripCounts.entries) {
// // // //         final companyId = entry.key;
// // // //         final dailyWorkTrips = entry.value;
// // // //         final companyName = companyNames[companyId] ?? 'غير معروف';
// // // //         final totalDebt = dailyWorkTotalDebts[companyId] ?? 0.0;

// // // //         // البحث عن حساب الشركة
// // // //         DocumentSnapshot? summaryDoc;
// // // //         for (final doc in companySummaries.docs) {
// // // //           final data = doc.data();
// // // //           if (doc.id == companyId || data['companyId'] == companyId) {
// // // //             summaryDoc = doc;
// // // //             break;
// // // //           }
// // // //         }

// // // //         if (summaryDoc != null && summaryDoc.exists) {
// // // //           // تحقق من عدد الرحلات
// // // //           final summaryData = summaryDoc.data() as Map<String, dynamic>;
// // // //           final summaryTrips = (summaryData['totalTrips'] ?? 0).toInt();
// // // //           final summaryDebt = (summaryData['totalCompanyDebt'] ?? 0).toDouble();

// // // //           // إذا كان عدد الرحلات أو المبلغ غير متطابق
// // // //           if (dailyWorkTrips != summaryTrips || totalDebt != summaryDebt) {
// // // //             final totalPaidAmount = (summaryData['totalPaidAmount'] ?? 0)
// // // //                 .toDouble();
// // // //             final totalRemaining = totalDebt - totalPaidAmount;

// // // //             String status;
// // // //             if (totalRemaining <= 0) {
// // // //               status = 'منتهية';
// // // //             } else if (totalPaidAmount > 0) {
// // // //               status = 'شبه منتهية';
// // // //             } else {
// // // //               status = 'جارية';
// // // //             }

// // // //             batch.set(summariesRef.doc(companyId), {
// // // //               'companyId': companyId,
// // // //               'companyName': companyName,
// // // //               'totalCompanyDebt': totalDebt,
// // // //               'totalPaidAmount': totalPaidAmount,
// // // //               'totalRemainingAmount': totalRemaining,
// // // //               'totalTrips': dailyWorkTrips,
// // // //               'status': status,
// // // //               'lastUpdated': Timestamp.now(),
// // // //             }, SetOptions(merge: true));

// // // //             updatedCount++;
// // // //           }
// // // //         } else {
// // // //           // الشركة ليس لها حساب، إنشاء حساب جديد
// // // //           batch.set(summariesRef.doc(companyId), {
// // // //             'companyId': companyId,
// // // //             'companyName': companyName,
// // // //             'totalCompanyDebt': totalDebt,
// // // //             'totalPaidAmount': 0.0,
// // // //             'totalRemainingAmount': totalDebt,
// // // //             'totalTrips': dailyWorkTrips,
// // // //             'status': 'جارية',
// // // //             'lastUpdated': Timestamp.now(),
// // // //           });

// // // //           updatedCount++;
// // // //         }
// // // //       }

// // // //       // 4. حذف حسابات الشركات التي ليس لها رحلات
// // // //       for (final doc in companySummaries.docs) {
// // // //         final companyId = doc.id;
// // // //         if (!dailyWorkTripCounts.containsKey(companyId)) {
// // // //           final data = doc.data();
// // // //           final dataCompanyId = data['companyId'] as String?;

// // // //           // إذا الشركة ليس لها رحلات في dailyWork
// // // //           if (!dailyWorkTripCounts.containsKey(dataCompanyId ?? '')) {
// // // //             // يمكنك اختيار حذفها أو تركها
// // // //             // batch.delete(summariesRef.doc(companyId));
// // // //             debugPrint(
// // // //               '⚠️ الشركة ${data['companyName']} ليس لها رحلات في dailyWork',
// // // //             );
// // // //           }
// // // //         }
// // // //       }

// // // //       if (updatedCount > 0) {
// // // //         await batch.commit();
// // // //         debugPrint('✅ تم تحديث $updatedCount حساب شركة تلقائياً');
// // // //         _showSuccess('تم تحديث حسابات $updatedCount شركة تلقائياً');
// // // //       } else {
// // // //         debugPrint('✅ جميع الحسابات محدثة بالفعل');
// // // //       }
// // // //     } catch (e) {
// // // //       debugPrint('❌ خطأ في التحديث التلقائي: $e');
// // // //       _showError('خطأ في تحديث الحسابات: $e');
// // // //     }
// // // //   }

// // // //   // ================================
// // // //   // تحميل بيانات الشركات مع الإحصائيات
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

// // // //         // حساب الرحلات والإحصائيات
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
// // // //                 'nolon': (data['noLon'] ?? data['nolon'] ?? 0).toDouble(),
// // // //                 'companyOvernight': (data['companyOvernight'] ?? 0).toDouble(),
// // // //                 'companyHoliday': (data['companyHoliday'] ?? 0).toDouble(),
// // // //               };
// // // //             })
// // // //             .toList();

// // // //         // حساب الإجماليات
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
// // // //           'totalTrips': companyTrips.length,
// // // //           'totalNolon': totalNolon,
// // // //           'totalOvernight': totalOvernight,
// // // //           'totalHoliday': totalHoliday,
// // // //         });
// // // //       }

// // // //       companiesList.sort(
// // // //         (a, b) => a['companyName'].compareTo(b['companyName']),
// // // //       );

// // // //       setState(() {
// // // //         _allCompanies = companiesList;
// // // //         _filteredCompanies = _applySearchFilter(companiesList);
// // // //         _isLoading = false;
// // // //       });

// // // //       // تحديث تلقائي عند دخول الصفحة الرئيسية فقط
// // // //       if (!_hasSyncedOnEnter && _selectedCompany == null) {
// // // //         await _syncDataOnPageEnter();
// // // //         _hasSyncedOnEnter = true;
// // // //       }
// // // //     } catch (e) {
// // // //       setState(() => _isLoading = false);
// // // //       debugPrint('خطأ في تحميل بيانات الشركات: $e');
// // // //       _showError('خطأ في تحميل الشركات: $e');
// // // //     }
// // // //   }

// // // //   // ================================
// // // //   // تحميل بيانات الشركة المختارة
// // // //   // ================================
// // // //   Future<void> _loadCompanyData(String companyName, String companyId) async {
// // // //     setState(() {
// // // //       _selectedCompany = companyName;
// // // //       _selectedCompanyId = companyId;
// // // //       _isLoading = true;
// // // //       _companyWork.clear();
// // // //       _availableTripsForInvoice.clear();
// // // //       _companyInvoices.clear();
// // // //       _selectedTripsForInvoice.clear();
// // // //       _invoiceNameController.clear();
// // // //     });

// // // //     try {
// // // //       // 1. تحميل جميع رحلات الشركة من dailyWork
// // // //       final workSnapshot = await _firestore
// // // //           .collection('dailyWork')
// // // //           .where('companyId', isEqualTo: companyId)
// // // //           .orderBy('date', descending: false) // الأقدم أولاً
// // // //           .get();

// // // //       final List<Map<String, dynamic>> allTrips = [];

// // // //       for (final doc in workSnapshot.docs) {
// // // //         final data = doc.data();
// // // //         final tripDate = (data['date'] as Timestamp?)?.toDate();

// // // //         allTrips.add({
// // // //           'id': doc.id,
// // // //           'date': tripDate,
// // // //           'companyName': companyName,
// // // //           'companyId': companyId,
// // // //           'driverName': data['driverName'] ?? 'غير معروف',
// // // //           'nolon': (data['noLon'] ?? data['nolon'] ?? 0).toDouble(),
// // // //           'companyOvernight': (data['companyOvernight'] ?? 0).toDouble(),
// // // //           'companyHoliday': (data['companyHoliday'] ?? 0).toDouble(),
// // // //           'selectedPrice': (data['selectedPrice'] ?? 0).toDouble(),
// // // //           'karta': data['karta'] ?? '', // تخزين الكارتة
// // // //           'ohda': data['ohda'] ?? '',
// // // //           'selectedRoute': data['selectedRoute'] ?? '',
// // // //           'selectedRoute2': data['unloadingLocation'] ?? '',
// // // //           'loadingLocation': data['loadingLocation'] ?? '',
// // // //           'unloadingLocation': data['unloadingLocation'] ?? '',
// // // //           'vehicleType': data['selectedVehicleType'] ?? '',
// // // //           'notes': data['selectedNotes'] ?? '',
// // // //           'tr': data['tr'] ?? '',
// // // //           'companyLocationName': data['companyLocationName'] ?? '',
// // // //           'hasInvoice': false,
// // // //         });
// // // //       }

// // // //       // 2. تحميل فواتير الشركة
// // // //       final invoicesSnapshot = await _firestore
// // // //           .collection('invoices')
// // // //           .where('companyId', isEqualTo: companyId)
// // // //           .orderBy('createdAt', descending: true)
// // // //           .get();

// // // //       final List<Map<String, dynamic>> invoicesList = [];
// // // //       final List<String> invoicedTripIds = [];

// // // //       for (final doc in invoicesSnapshot.docs) {
// // // //         final data = doc.data();
// // // //         final tripIds = (data['tripIds'] as List<dynamic>? ?? []);

// // // //         // جمع ID الرحلات التي تم عمل فاتورة لها
// // // //         for (var tripId in tripIds) {
// // // //           invoicedTripIds.add(tripId.toString());
// // // //         }

// // // //         // جلب تفاصيل الرحلات للفاتورة
// // // //         List<Map<String, dynamic>> invoiceTrips = [];
// // // //         double totalNolon = 0;
// // // //         double totalOvernight = 0;
// // // //         double totalHoliday = 0;

// // // //         for (var tripId in tripIds) {
// // // //           final tripDoc = await _firestore
// // // //               .collection('dailyWork')
// // // //               .doc(tripId.toString())
// // // //               .get();
// // // //           if (tripDoc.exists) {
// // // //             final tripData = tripDoc.data() as Map<String, dynamic>;
// // // //             invoiceTrips.add({
// // // //               'selectedRoute': tripData['loadingLocation'] ?? '',
// // // //               'selectedRoute2': tripData['unloadingLocation'] ?? '',
// // // //               'vehicleType': tripData['selectedVehicleType'] ?? '',
// // // //               'nolon': (tripData['noLon'] ?? tripData['nolon'] ?? 0).toDouble(),
// // // //               'companyOvernight': (tripData['companyOvernight'] ?? 0)
// // // //                   .toDouble(),
// // // //               'companyHoliday': (tripData['companyHoliday'] ?? 0).toDouble(),
// // // //               'tr': tripData['tr'] ?? '',
// // // //               'companyLocationName': tripData['companyLocationName'] ?? '',
// // // //               'date': (tripData['date'] as Timestamp?)?.toDate(),
// // // //               'karta': tripData['karta'] ?? '', // إضافة الكارتة
// // // //             });

// // // //             totalNolon += (tripData['noLon'] ?? tripData['nolon'] ?? 0)
// // // //                 .toDouble();
// // // //             totalOvernight += (tripData['companyOvernight'] ?? 0).toDouble();
// // // //             totalHoliday += (tripData['companyHoliday'] ?? 0).toDouble();
// // // //           }
// // // //         }

// // // //         invoicesList.add({
// // // //           'id': doc.id,
// // // //           'name': data['name'] ?? 'فاتورة بدون اسم',
// // // //           'companyName': data['companyName'] ?? 'شركة غير معروفة',
// // // //           'companyId': data['companyId'] ?? companyId,
// // // //           'totalAmount': (data['totalAmount'] ?? 0).toDouble(),
// // // //           'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
// // // //           'tripIds': tripIds,
// // // //           'tripCount': tripIds.length,
// // // //           'invoiceTrips': invoiceTrips,
// // // //           'nolonTotal': totalNolon,
// // // //           'overnightTotal': totalOvernight,
// // // //           'holidayTotal': totalHoliday,
// // // //           'kartaDetails': invoiceTrips
// // // //               .map((trip) => trip['karta'])
// // // //               .toList(), // تخزين الكارتات
// // // //         });
// // // //       }

// // // //       // 3. تحديث الرحلات لمعرفة أيها تم عمل فاتورة له
// // // //       for (var trip in allTrips) {
// // // //         trip['hasInvoice'] = invoicedTripIds.contains(trip['id']);
// // // //       }

// // // //       // 4. فصل الرحلات: المتاحة للفاتورة (التي ليس لها فاتورة)
// // // //       final availableTrips = allTrips
// // // //           .where((trip) => !trip['hasInvoice'])
// // // //           .toList();

// // // //       // ترتيب الرحلات المتاحة للفاتورة: الأقدم أولاً، ثم تجميع الـ TR المتشابه
// // // //       final sortedAvailableTrips = _sortAndGroupTripsForInvoice(availableTrips);

// // // //       setState(() {
// // // //         _companyWork = allTrips;
// // // //         _availableTripsForInvoice = sortedAvailableTrips;
// // // //         _companyInvoices = invoicesList;
// // // //         _isLoading = false;
// // // //       });
// // // //     } catch (e) {
// // // //       setState(() => _isLoading = false);
// // // //       _showError('خطأ في تحميل بيانات الشركة: $e');
// // // //     }
// // // //   }

// // // //   String x = '';
// // // //   String xx = '';

// // // //   // ================================
// // // //   // الحصول على حالة نظام TR للشركة
// // // //   // ================================
// // // //   Future<bool> _getCompanyTRStatus(String companyId) async {
// // // //     try {
// // // //       final companyDoc = await _firestore
// // // //           .collection('companies')
// // // //           .doc(companyId)
// // // //           .get();
// // // //       if (companyDoc.exists) {
// // // //         final data = companyDoc.data() as Map<String, dynamic>;
// // // //         x = data['commercialRegister'];
// // // //         xx = data['taxCard'];

// // // //         return data['usesTRSystem'] ?? false;
// // // //       }
// // // //       return false;
// // // //     } catch (e) {
// // // //       debugPrint('خطأ في جلب حالة TR: $e');
// // // //       return false;
// // // //     }
// // // //   }

// // // //   // ================================
// // // //   // ترتيب وتجميع الرحلات للفاتورة
// // // //   // ================================
// // // //   List<Map<String, dynamic>> _sortAndGroupTripsForInvoice(
// // // //     List<Map<String, dynamic>> trips,
// // // //   ) {
// // // //     if (trips.isEmpty) return [];

// // // //     // 1. ترتيب الرحلات حسب التاريخ (الأقدم أولاً)
// // // //     trips.sort((a, b) {
// // // //       final dateA = a['date'] as DateTime? ?? DateTime(1900);
// // // //       final dateB = b['date'] as DateTime? ?? DateTime(1900);
// // // //       return dateA.compareTo(dateB);
// // // //     });

// // // //     // 2. تجميع الرحلات حسب التاريخ والـ TR
// // // //     final Map<String, List<Map<String, dynamic>>> groupedTrips = {};

// // // //     for (var trip in trips) {
// // // //       final date = trip['date'] as DateTime?;
// // // //       final tr = trip['tr']?.toString() ?? '';
// // // //       final dateKey = date != null
// // // //           ? DateFormat('yyyy-MM-dd').format(date)
// // // //           : 'unknown_date';

// // // //       // المفتاح: التاريخ + الـ TR
// // // //       final key = '$dateKey|$tr';

// // // //       if (!groupedTrips.containsKey(key)) {
// // // //         groupedTrips[key] = [];
// // // //       }
// // // //       groupedTrips[key]!.add(trip);
// // // //     }

// // // //     // 3. تحويل المجموعات إلى قائمة مرتبة
// // // //     final List<Map<String, dynamic>> result = [];

// // // //     // الحصول على المفاتيح وترتيبها حسب التاريخ
// // // //     final sortedKeys = groupedTrips.keys.toList()
// // // //       ..sort((a, b) {
// // // //         // استخراج التاريخ من المفتاح
// // // //         final datePartA = a.split('|')[0];
// // // //         final datePartB = b.split('|')[0];
// // // //         return datePartA.compareTo(datePartB);
// // // //       });

// // // //     // إضافة الرحلات المجمعة
// // // //     for (var key in sortedKeys) {
// // // //       final tripsInGroup = groupedTrips[key]!;

// // // //       // ترتيب الرحلات داخل المجموعة حسب الوقت إذا كان موجوداً
// // // //       tripsInGroup.sort((a, b) {
// // // //         final timeA = (a['date'] as DateTime?)?.toIso8601String() ?? '';
// // // //         final timeB = (b['date'] as DateTime?)?.toIso8601String() ?? '';
// // // //         return timeA.compareTo(timeB);
// // // //       });

// // // //       result.addAll(tripsInGroup);
// // // //     }

// // // //     return result;
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
// // // //         _selectedTripsForInvoice.addAll(_availableTripsForInvoice);
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

// // // //         // تخزين تفاصيل الرحلة بما فيها الكارتة
// // // //         invoiceTripDetails.add({
// // // //           'selectedRoute': trip['selectedRoute'],
// // // //           'selectedRoute2': trip['selectedRoute2'],
// // // //           'vehicleType': trip['vehicleType'],
// // // //           'nolon': trip['nolon'],
// // // //           'companyOvernight': trip['companyOvernight'],
// // // //           'companyHoliday': trip['companyHoliday'],
// // // //           'tr': trip['tr'],
// // // //           'companyLocationName': trip['companyLocationName'],
// // // //           'date': trip['date'],
// // // //           'karta': trip['karta'] ?? '', // تخزين الكارتة
// // // //         });
// // // //       }

// // // //       double totalAmount = totalNolon + totalOvernight + totalHoliday;

// // // //       // حفظ الفاتورة مع الكارتات
// // // //       await _firestore.collection('invoices').add({
// // // //         'name': _invoiceNameController.text.trim(),
// // // //         'companyName': _selectedCompany!,
// // // //         'companyId': _selectedCompanyId!,
// // // //         'totalAmount': totalAmount,
// // // //         'nolonTotal': totalNolon,
// // // //         'overnightTotal': totalOvernight,
// // // //         'holidayTotal': totalHoliday,
// // // //         'tripIds': tripIds,
// // // //         'tripDetails': invoiceTripDetails,
// // // //         'tripCount': tripIds.length,
// // // //         'kartaDetails': _selectedTripsForInvoice
// // // //             .map((trip) => trip['karta'] ?? '')
// // // //             .toList(), // تخزين الكارتات
// // // //         'createdAt': Timestamp.now(),
// // // //         'status': 'غير مدفوعة',
// // // //       });

// // // //       // تحديث حالة الرحلات في dailyWork
// // // //       final batch = _firestore.batch();
// // // //       for (var tripId in tripIds) {
// // // //         batch.update(_firestore.collection('dailyWork').doc(tripId), {
// // // //           'hasInvoice': true,
// // // //         });
// // // //       }
// // // //       await batch.commit();

// // // //       // تحديث حساب الشركة في companySummaries
// // // //       await _updateCompanySummaryAfterInvoice(totalAmount);

// // // //       _showSuccess('تم إنشاء الفاتورة بنجاح');

// // // //       // إعادة تحميل بيانات الشركة
// // // //       await _loadCompanyData(_selectedCompany!, _selectedCompanyId!);

// // // //       // تنظيف المتغيرات
// // // //       _selectedTripsForInvoice.clear();
// // // //       _invoiceNameController.clear();

// // // //       // الذهاب إلى قسم الفواتير
// // // //       _changeSection(2);
// // // //     } catch (e) {
// // // //       _showError('خطأ في إنشاء الفاتورة: $e');
// // // //     } finally {
// // // //       setState(() => _isCreatingInvoice = false);
// // // //     }
// // // //   }

// // // //   // ================================
// // // //   // تحديث حساب الشركة بعد إنشاء الفاتورة
// // // //   // ================================
// // // //   Future<void> _updateCompanySummaryAfterInvoice(double invoiceAmount) async {
// // // //     try {
// // // //       final summaryRef = _firestore
// // // //           .collection('companySummaries')
// // // //           .doc(_selectedCompanyId!);

// // // //       final summaryDoc = await summaryRef.get();

// // // //       if (summaryDoc.exists) {
// // // //         final data = summaryDoc.data() as Map<String, dynamic>;
// // // //         final currentTotalPaid = (data['totalPaidAmount'] ?? 0).toDouble();
// // // //         final newTotalPaid = currentTotalPaid + invoiceAmount;
// // // //         final totalDebt = (data['totalCompanyDebt'] ?? 0).toDouble();
// // // //         final totalRemaining = totalDebt - newTotalPaid;

// // // //         String status;
// // // //         if (totalRemaining <= 0) {
// // // //           status = 'منتهية';
// // // //         } else if (newTotalPaid > 0) {
// // // //           status = 'شبه منتهية';
// // // //         } else {
// // // //           status = 'جارية';
// // // //         }

// // // //         await summaryRef.update({
// // // //           'totalPaidAmount': newTotalPaid,
// // // //           'totalRemainingAmount': totalRemaining,
// // // //           'status': status,
// // // //           'lastUpdated': Timestamp.now(),
// // // //         });

// // // //         debugPrint('✅ تم تحديث حساب الشركة بعد إنشاء الفاتورة');
// // // //       }
// // // //     } catch (e) {
// // // //       debugPrint('⚠️ خطأ في تحديث حساب الشركة بعد الفاتورة: $e');
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

// // // //   String _formatCurrencyForPDF(double amount) {
// // // //     return amount.toStringAsFixed(2);
// // // //   }

// // // //   void _changeSection(int section) {
// // // //     setState(() {
// // // //       _currentSection = section;
// // // //       if (section == 1) {
// // // //         _selectedTripsForInvoice.clear();
// // // //         _invoiceNameController.clear();
// // // //       }
// // // //     });
// // // //   }

// // // //   void _backToCompanies() {
// // // //     setState(() {
// // // //       _selectedCompany = null;
// // // //       _selectedCompanyId = null;
// // // //       _companyWork.clear();
// // // //       _availableTripsForInvoice.clear();
// // // //       _companyInvoices.clear();
// // // //       _selectedTripsForInvoice.clear();
// // // //       _invoiceNameController.clear();
// // // //       _hasSyncedOnEnter = false; // إعادة تعيين لعند الدخول التالي
// // // //     });
// // // //     _loadCompanies();
// // // //   }

// // // //   // ================================
// // // //   // طباعة مطالبة الكارتات - محدثة
// // // //   // ================================

// // // //   // Future<void> _printKartaRequest(Map<String, dynamic> invoice) async {
// // // //   //   if (_arabicFont == null) {
// // // //   //     await _loadArabicFont();
// // // //   //   }

// // // //   //   setState(() => _isGeneratingPDF = true);

// // // //   //   try {
// // // //   //     final trips =
// // // //   //         invoice['invoiceTrips'] as List<Map<String, dynamic>>? ?? [];
// // // //   //     final invoiceName = invoice['name'] ?? '';
// // // //   //     final companyName = invoice['companyName'] ?? 'غير معروف';
// // // //   //     final createdAt = invoice['createdAt'] as DateTime?;

// // // //   //     // استخراج الشهر من تاريخ الفاتورة
// // // //   //     String monthYear = 'غير محدد';
// // // //   //     if (createdAt != null) {
// // // //   //       monthYear = '${createdAt.month}/${createdAt.year}';
// // // //   //     }

// // // //   //     // الحصول على الموقع الفعلي (companyLocationName) من الرحلات
// // // //   //     String companyLocation = '';
// // // //   //     for (var trip in trips) {
// // // //   //       final location = trip['companyLocationName']?.toString() ?? '';
// // // //   //       if (location.isNotEmpty) {
// // // //   //         companyLocation = location;
// // // //   //         break;
// // // //   //       }
// // // //   //     }

// // // //   //     // إذا لم يوجد موقع، استخدم 'الموقع' كقيمة افتراضية
// // // //   //     if (companyLocation.isEmpty) {
// // // //   //       companyLocation = 'الموقع';
// // // //   //     }

// // // //   //     // تجميع الرحلات حسب التاريخ مع الكارتة
// // // //   //     final Map<String, List<Map<String, dynamic>>> groupedByDate = {};

// // // //   //     for (var trip in trips) {
// // // //   //       final date = trip['date'] as DateTime?;
// // // //   //       if (date != null) {
// // // //   //         final dateKey = DateFormat('d/M/yyyy').format(date);
// // // //   //         if (!groupedByDate.containsKey(dateKey)) {
// // // //   //           groupedByDate[dateKey] = [];
// // // //   //         }
// // // //   //         groupedByDate[dateKey]!.add(trip);
// // // //   //       }
// // // //   //     }

// // // //   //     // إنشاء صفوف الجدول كما في الصورة
// // // //   //     final List<Map<String, dynamic>> tableRows = [];
// // // //   //     int rowNumber = 1;

// // // //   //     // فرز التواريخ
// // // //   //     final sortedDates = groupedByDate.keys.toList()
// // // //   //       ..sort((a, b) {
// // // //   //         final dateA = DateFormat('d/M/yyyy').parse(a);
// // // //   //         final dateB = DateFormat('d/M/yyyy').parse(b);
// // // //   //         return dateA.compareTo(dateB);
// // // //   //       });

// // // //   //     for (var date in sortedDates) {
// // // //   //       final tripsOnDate = groupedByDate[date]!;
// // // //   //       List<String> kartas = [];
// // // //   //       List<String> ohdas = [];

// // // //   //       // جمع الكارتات والعهدات لهذا التاريخ
// // // //   //       for (var trip in tripsOnDate) {
// // // //   //         // جمع الكارتة إذا كانت موجودة
// // // //   //         final karta = trip['karta']?.toString() ?? '';
// // // //   //         if (karta.isNotEmpty && !kartas.contains(karta)) {
// // // //   //           kartas.add(karta);
// // // //   //         }

// // // //   //         // جمع العهدة إذا كانت موجودة
// // // //   //         final tripOhda = trip['ohda']?.toString() ?? '';
// // // //   //         if (tripOhda.isNotEmpty && !ohdas.contains(tripOhda)) {
// // // //   //           ohdas.add(tripOhda);
// // // //   //         }
// // // //   //       }

// // // //   //       // دمج الكارتات والعهدات في سطر واحد
// // // //   //       String kartaText = kartas.join('، ');
// // // //   //       String ohdaText = ohdas.join('، ');

// // // //   //       // تنسيق التاريخ كما في الصورة (يوم/شهر فقط)
// // // //   //       final dateParts = date.split('/');
// // // //   //       String formattedDate = date;
// // // //   //       if (dateParts.length >= 2) {
// // // //   //         formattedDate = '${dateParts[0]}/${dateParts[1]}';
// // // //   //       }

// // // //   //       tableRows.add({
// // // //   //         'rowNumber': rowNumber.toString(),
// // // //   //         'date': formattedDate,
// // // //   //         'karta': kartaText,
// // // //   //         'ohda': ohdaText,
// // // //   //       });

// // // //   //       rowNumber++;
// // // //   //     }

// // // //   //     final pdf = pdfLib.Document(
// // // //   //       theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
// // // //   //     );

// // // //   //     pdf.addPage(
// // // //   //       pdfLib.Page(
// // // //   //         pageFormat: pdfLib.PdfPageFormat.a4,
// // // //   //         margin: const pdfLib.EdgeInsets.only(right: 60, left: 60),
// // // //   //         build: (_) => pdfLib.Directionality(
// // // //   //           textDirection: pdfLib.TextDirection.rtl,
// // // //   //           child: pdfLib.Column(
// // // //   //             crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
// // // //   //             children: [
// // // //   //               // العنوان
// // // //   //               _kartaRequestHeader(
// // // //   //                 invoiceName,
// // // //   //                 monthYear,
// // // //   //                 companyName,
// // // //   //                 companyLocation,
// // // //   //               ),
// // // //   //               pdfLib.SizedBox(height: 20),

// // // //   //               // الجدول كما في الصورة
// // // //   //               _kartaRequestTable(tableRows),

// // // //   //               pdfLib.SizedBox(height: 20),

// // // //   //               // التوقيعات
// // // //   //             ],
// // // //   //           ),
// // // //   //         ),
// // // //   //       ),
// // // //   //     );

// // // //   //     await Printing.layoutPdf(
// // // //   //       name: 'مطالبة كارتات - $invoiceName',
// // // //   //       onLayout: (_) async => pdf.save(),
// // // //   //     );

// // // //   //     _showSuccess('تم طباعة مطالبة الكارتات بنجاح');
// // // //   //   } catch (e) {
// // // //   //     _showError('خطأ في طباعة مطالبة الكارتات: $e');
// // // //   //   } finally {
// // // //   //     setState(() => _isGeneratingPDF = false);
// // // //   //   }
// // // //   // }

// // // //   // // ================================
// // // //   // // ترويسة مطالبة الكارتات
// // // //   // // ================================
// // // //   // pdfLib.Widget _kartaRequestHeader(
// // // //   //   String invoiceName,
// // // //   //   String monthYear,
// // // //   //   String companyName,
// // // //   //   String location,
// // // //   // ) {
// // // //   //   return pdfLib.Column(
// // // //   //     crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
// // // //   //     children: [
// // // //   //       pdfLib.Text(
// // // //   //         'فاتورة رقم ( $invoiceName )',
// // // //   //         style: pdfLib.TextStyle(
// // // //   //           font: _arabicFont,
// // // //   //           fontSize: 18,
// // // //   //           fontWeight: pdfLib.FontWeight.bold,
// // // //   //         ),
// // // //   //         textAlign: pdfLib.TextAlign.center,
// // // //   //       ),
// // // //   //       pdfLib.SizedBox(height: 10),
// // // //   //       pdfLib.Text(
// // // //   //         'مطالبة كارتات فاتورة شهر $monthYear م',
// // // //   //         style: pdfLib.TextStyle(
// // // //   //           font: _arabicFont,
// // // //   //           fontSize: 16,
// // // //   //           fontWeight: pdfLib.FontWeight.bold,
// // // //   //         ),
// // // //   //         textAlign: pdfLib.TextAlign.center,
// // // //   //       ),
// // // //   //       pdfLib.SizedBox(height: 10),
// // // //   //       pdfLib.Text(
// // // //   //         'عن موقع ( $location )( $companyName)',
// // // //   //         style: pdfLib.TextStyle(font: _arabicFont, fontSize: 14),
// // // //   //         textAlign: pdfLib.TextAlign.center,
// // // //   //       ),
// // // //   //       pdfLib.SizedBox(height: 20),
// // // //   //     ],
// // // //   //   );
// // // //   // }

// // // //   // // ================================
// // // //   // // جدول مطالبة الكارتات كما في الصورة
// // // //   // // ================================
// // // //   // pdfLib.Widget _kartaRequestTable(List<Map<String, dynamic>> rows) {
// // // //   //   // حساب عدد الكارتات الكلي
// // // //   //   // حساب مجموع الكارتات الكلي
// // // //   //   double totalKartasValue = 0;
// // // //   //   for (var row in rows) {
// // // //   //     final kartaText = row['karta']?.toString() ?? '';
// // // //   //     if (kartaText.isNotEmpty) {
// // // //   //       // تقسيم النص إلى كارتات فردية (مفصولة بفاصلة)
// // // //   //       final kartas = kartaText;

// // // //   //       // جمع قيم الكارتات كأرقام
// // // //   //       for (var karta in kartas) {
// // // //   //         try {
// // // //   //           // تنظيف النص من المسافات وتحويله إلى رقم
// // // //   //           final cleanedKarta = karta.trim();
// // // //   //           if (cleanedKarta.isNotEmpty) {
// // // //   //             final kartaValue = double.tryParse(cleanedKarta) ?? 0;
// // // //   //             totalKartasValue += kartaValue;
// // // //   //           }
// // // //   //         } catch (e) {
// // // //   //           debugPrint('خطأ في تحويل الكارتة إلى رقم: $karta');
// // // //   //         }
// // // //   //       }
// // // //   //     }
// // // //   //   }

// // // //   //   return pdfLib.Table(
// // // //   //     border: pdfLib.TableBorder.all(color: pdfLib.PdfColors.black, width: 1),
// // // //   //     columnWidths: const {
// // // //   //       0: pdfLib.FlexColumnWidth(1), // المسلسل
// // // //   //       1: pdfLib.FlexColumnWidth(1), // التاريخ
// // // //   //       2: pdfLib.FlexColumnWidth(1.5), // القيمة (الكارتة)
// // // //   //     },
// // // //   //     children: [
// // // //   //       // رأس الجدول كما في الصورة
// // // //   //       pdfLib.TableRow(
// // // //   //         decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
// // // //   //         children: [
// // // //   //           _kartaTableCell('المسلسل', isHeader: true),
// // // //   //           _kartaTableCell('التاريخ', isHeader: true),
// // // //   //           _kartaTableCell('القيمة', isHeader: true),
// // // //   //         ],
// // // //   //       ),

// // // //   //       // صفوف البيانات - القيمة هنا هي الكارتة
// // // //   //       ...rows.map(
// // // //   //         (row) => pdfLib.TableRow(
// // // //   //           children: [
// // // //   //             _kartaTableCell(row['rowNumber']),
// // // //   //             _kartaTableCell(row['date']),
// // // //   //             _kartaTableCell(row['karta']?.toString() ?? ''),
// // // //   //           ],
// // // //   //         ),
// // // //   //       ),

// // // //   //       // الصف الأخير الإجمالي كما في الصورة
// // // //   //       pdfLib.TableRow(
// // // //   //         children: [
// // // //   //           _kartaTableCell('الإجمالي', isTotal: true),
// // // //   //           _kartaTableCell('', isTotal: true),
// // // //   //           _kartaTableCell(
// // // //   //             _formatCurrencyForPDF(totalKartasValue),
// // // //   //             isTotal: true,
// // // //   //           ),
// // // //   //         ],
// // // //   //       ),
// // // //   //     ],
// // // //   //   );
// // // //   // }

// // // //   // // ================================
// // // //   // // خلية جدول مطالبة الكارتات
// // // //   // // ================================
// // // //   // pdfLib.Widget _kartaTableCell(
// // // //   //   String text, {
// // // //   //   bool isHeader = false,
// // // //   //   bool isTotal = false,
// // // //   // }) {
// // // //   //   return pdfLib.Container(
// // // //   //     padding: const pdfLib.EdgeInsets.all(8),
// // // //   //     child: pdfLib.Text(
// // // //   //       text,
// // // //   //       textAlign: pdfLib.TextAlign.center,
// // // //   //       style: pdfLib.TextStyle(
// // // //   //         font: _arabicFont,
// // // //   //         fontSize: isTotal ? 12 : 10,
// // // //   //         fontWeight: isHeader || isTotal
// // // //   //             ? pdfLib.FontWeight.bold
// // // //   //             : pdfLib.FontWeight.normal,
// // // //   //       ),
// // // //   //     ),
// // // //   //   );
// // // //   // }

// // // //   Future<void> _printKartaRequest(Map<String, dynamic> invoice) async {
// // // //     if (_arabicFont == null) {
// // // //       await _loadArabicFont();
// // // //     }

// // // //     setState(() => _isGeneratingPDF = true);

// // // //     try {
// // // //       final trips =
// // // //           invoice['invoiceTrips'] as List<Map<String, dynamic>>? ?? [];
// // // //       final invoiceName = invoice['name'] ?? '';
// // // //       final companyName = invoice['companyName'] ?? 'غير معروف';
// // // //       final createdAt = invoice['createdAt'] as DateTime?;

// // // //       // استخراج الشهر من تاريخ الفاتورة
// // // //       String monthYear = 'غير محدد';
// // // //       if (createdAt != null) {
// // // //         monthYear = '${createdAt.month}/${createdAt.year}';
// // // //       }

// // // //       // الحصول على الموقع الفعلي (companyLocationName) من الرحلات
// // // //       String companyLocation = '';
// // // //       for (var trip in trips) {
// // // //         final location = trip['companyLocationName']?.toString() ?? '';
// // // //         if (location.isNotEmpty) {
// // // //           companyLocation = location;
// // // //           break;
// // // //         }
// // // //       }

// // // //       // إذا لم يوجد موقع، استخدم 'الموقع' كقيمة افتراضية
// // // //       if (companyLocation.isEmpty) {
// // // //         companyLocation = 'الموقع';
// // // //       }

// // // //       // ترتيب الرحلات حسب التاريخ
// // // //       final List<Map<String, dynamic>> sortedTrips = List.from(trips)
// // // //         ..sort((a, b) {
// // // //           final dateA = a['date'] as DateTime? ?? DateTime(1900);
// // // //           final dateB = b['date'] as DateTime? ?? DateTime(1900);
// // // //           return dateA.compareTo(dateB);
// // // //         });

// // // //       // إنشاء صفوف الجدول - كل رحلة في سطر منفصل
// // // //       final List<Map<String, dynamic>> tableRows = [];
// // // //       double totalKartasValue = 0;
// // // //       int rowNumber = 1;

// // // //       for (var trip in sortedTrips) {
// // // //         final date = trip['date'] as DateTime?;
// // // //         final karta = trip['karta']?.toString() ?? '';
// // // //         final ohda = trip['ohda']?.toString() ?? '';

// // // //         // حساب قيمة الكارتة إذا كانت رقماً
// // // //         double kartaValue = 0;
// // // //         try {
// // // //           final cleanedKarta = karta.trim();
// // // //           if (cleanedKarta.isNotEmpty) {
// // // //             kartaValue = double.tryParse(cleanedKarta) ?? 0;
// // // //           }
// // // //         } catch (e) {
// // // //           debugPrint('خطأ في تحويل الكارتة إلى رقم: $karta');
// // // //         }

// // // //         // جمع القيمة الإجمالية
// // // //         totalKartasValue += kartaValue;

// // // //         // تنسيق التاريخ (يوم/شهر فقط)
// // // //         String formattedDate = '-';
// // // //         if (date != null) {
// // // //           formattedDate = '${date.day}/${date.month}';
// // // //         }

// // // //         tableRows.add({
// // // //           'rowNumber': rowNumber.toString(),
// // // //           'date': formattedDate,
// // // //           'karta': karta,
// // // //           'ohda': ohda,
// // // //           'kartaValue': kartaValue,
// // // //         });

// // // //         rowNumber++;
// // // //       }

// // // //       final pdf = pdfLib.Document(
// // // //         theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
// // // //       );

// // // //       pdf.addPage(
// // // //         pdfLib.Page(
// // // //           pageFormat: pdfLib.PdfPageFormat.a4,
// // // //           margin: const pdfLib.EdgeInsets.only(right: 60, left: 60),
// // // //           build: (_) => pdfLib.Directionality(
// // // //             textDirection: pdfLib.TextDirection.rtl,
// // // //             child: pdfLib.Column(
// // // //               crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
// // // //               children: [
// // // //                 // العنوان
// // // //                 _kartaRequestHeader(
// // // //                   invoiceName,
// // // //                   monthYear,
// // // //                   companyName,
// // // //                   companyLocation,
// // // //                 ),
// // // //                 pdfLib.SizedBox(height: 20),

// // // //                 // الجدول كما في الصورة
// // // //                 _kartaRequestTable(tableRows, totalKartasValue),

// // // //                 pdfLib.SizedBox(height: 20),

// // // //                 // التوقيعات
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       );

// // // //       await Printing.layoutPdf(
// // // //         name: 'مطالبة كارتات - $invoiceName',
// // // //         onLayout: (_) async => pdf.save(),
// // // //       );

// // // //       _showSuccess('تم طباعة مطالبة الكارتات بنجاح');
// // // //     } catch (e) {
// // // //       _showError('خطأ في طباعة مطالبة الكارتات: $e');
// // // //     } finally {
// // // //       setState(() => _isGeneratingPDF = false);
// // // //     }
// // // //   }

// // // //   // ================================
// // // //   // ترويسة مطالبة الكارتات
// // // //   // ================================
// // // //   pdfLib.Widget _kartaRequestHeader(
// // // //     String invoiceName,
// // // //     String monthYear,
// // // //     String companyName,
// // // //     String location,
// // // //   ) {
// // // //     return pdfLib.Column(
// // // //       crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
// // // //       children: [
// // // //         pdfLib.Text(
// // // //           'فاتورة رقم ( $invoiceName )',
// // // //           style: pdfLib.TextStyle(
// // // //             font: _arabicFont,
// // // //             fontSize: 18,
// // // //             fontWeight: pdfLib.FontWeight.bold,
// // // //           ),
// // // //           textAlign: pdfLib.TextAlign.center,
// // // //         ),
// // // //         pdfLib.SizedBox(height: 10),
// // // //         pdfLib.Text(
// // // //           'مطالبة كارتات فاتورة شهر $monthYear م',
// // // //           style: pdfLib.TextStyle(
// // // //             font: _arabicFont,
// // // //             fontSize: 16,
// // // //             fontWeight: pdfLib.FontWeight.bold,
// // // //           ),
// // // //           textAlign: pdfLib.TextAlign.center,
// // // //         ),
// // // //         pdfLib.SizedBox(height: 10),
// // // //         pdfLib.Text(
// // // //           'عن موقع ( $location )( $companyName)',
// // // //           style: pdfLib.TextStyle(font: _arabicFont, fontSize: 14),
// // // //           textAlign: pdfLib.TextAlign.center,
// // // //         ),
// // // //         pdfLib.SizedBox(height: 20),
// // // //       ],
// // // //     );
// // // //   }

// // // //   // ================================
// // // //   // جدول مطالبة الكارتات كما في الصورة
// // // //   // ================================
// // // //   pdfLib.Widget _kartaRequestTable(
// // // //     List<Map<String, dynamic>> rows,
// // // //     double totalKartasValue,
// // // //   ) {
// // // //     return pdfLib.Table(
// // // //       border: pdfLib.TableBorder.all(color: pdfLib.PdfColors.black, width: 1),
// // // //       columnWidths: const {
// // // //         0: pdfLib.FlexColumnWidth(1.5), // المسلسل
// // // //         1: pdfLib.FlexColumnWidth(1), // التاريخ
// // // //         2: pdfLib.FlexColumnWidth(1), // القيمة (الكارتة)
// // // //       },
// // // //       children: [
// // // //         // رأس الجدول كما في الصورة
// // // //         pdfLib.TableRow(
// // // //           decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
// // // //           children: [
// // // //             _kartaTableCell('القيمة', isHeader: true),

// // // //             _kartaTableCell('التاريخ', isHeader: true),
// // // //             _kartaTableCell('المسلسل', isHeader: true),
// // // //           ],
// // // //         ),

// // // //         // صفوف البيانات - كل رحلة في سطر منفصل
// // // //         ...rows.map(
// // // //           (row) => pdfLib.TableRow(
// // // //             children: [
// // // //               _kartaTableCell(row['karta']?.toString() ?? ''),

// // // //               _kartaTableCell(row['date']),
// // // //               _kartaTableCell(row['rowNumber']),
// // // //             ],
// // // //           ),
// // // //         ),

// // // //         // الصف الأخير الإجمالي كما في الصورة
// // // //         pdfLib.TableRow(
// // // //           children: [
// // // //             _kartaTableCell(
// // // //               _formatCurrencyForPDF(totalKartasValue),
// // // //               isTotal: true,
// // // //             ),
// // // //             _kartaTableCell('--', isTotal: true),
// // // //             _kartaTableCell('الإجمالي', isTotal: true),
// // // //           ],
// // // //         ),
// // // //       ],
// // // //     );
// // // //   }

// // // //   // ================================
// // // //   // خلية جدول مطالبة الكارتات
// // // //   // ================================
// // // //   pdfLib.Widget _kartaTableCell(
// // // //     String text, {
// // // //     bool isHeader = false,
// // // //     bool isTotal = false,
// // // //   }) {
// // // //     return pdfLib.Container(
// // // //       padding: const pdfLib.EdgeInsets.all(8),
// // // //       child: pdfLib.Text(
// // // //         text,
// // // //         textAlign: pdfLib.TextAlign.center,
// // // //         style: pdfLib.TextStyle(
// // // //           font: _arabicFont,
// // // //           fontSize: isTotal ? 12 : 10,
// // // //           fontWeight: isHeader || isTotal
// // // //               ? pdfLib.FontWeight.bold
// // // //               : pdfLib.FontWeight.normal,
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ================================
// // // //   // دوال الطباعة
// // // //   // ================================
// // // //   Future<void> _printInvoice(Map<String, dynamic> invoice) async {
// // // //     if (_arabicFont == null) {
// // // //       await _loadArabicFont();
// // // //     }

// // // //     setState(() => _isGeneratingPDF = true);

// // // //     try {
// // // //       final trips =
// // // //           invoice['invoiceTrips'] as List<Map<String, dynamic>>? ?? [];
// // // //       final invoiceId = invoice['id']?.toString() ?? '623';
// // // //       final createdAt = invoice['createdAt'] as DateTime?;
// // // //       final companyName = invoice['companyName'] ?? ' ';
// // // //       final name = invoice['name'] ?? '';
// // // //       final companyId = invoice['companyId'] ?? _selectedCompanyId;

// // // //       // التحقق إذا كانت الشركة تعمل بنظام TR
// // // //       final bool usesTRSystem = companyId != null
// // // //           ? await _getCompanyTRStatus(companyId)
// // // //           : false;

// // // //       final groupedTrips = _groupTripsForInvoice(trips);
// // // //       final location = _getCompanyLocationName(trips);

// // // //       final total = groupedTrips.fold<double>(0.0, (sum, e) {
// // // //         final value = e['total'];
// // // //         if (value is num) {
// // // //           return sum + value.toDouble();
// // // //         }
// // // //         return sum;
// // // //       });

// // // //       final tax = total * 0.14;
// // // //       final afterTax = total + tax;

// // // //       final pdf = pdfLib.Document(
// // // //         theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
// // // //       );

// // // //       pdf.addPage(
// // // //         pdfLib.Page(
// // // //           pageFormat: pdfLib.PdfPageFormat.a4,
// // // //           margin: const pdfLib.EdgeInsets.only(right: 60, left: 60),
// // // //           build: (_) => pdfLib.Directionality(
// // // //             textDirection: pdfLib.TextDirection.rtl,
// // // //             child: pdfLib.Column(
// // // //               crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
// // // //               children: [
// // // //                 _invoiceHeader(
// // // //                   invoiceId,
// // // //                   createdAt,
// // // //                   companyName,
// // // //                   location,
// // // //                   name,
// // // //                 ),
// // // //                 pdfLib.SizedBox(height: 10),
// // // //                 _invoiceTable(groupedTrips, usesTRSystem),
// // // //                 _totalsSection(total, tax, afterTax),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       );

// // // //       await Printing.layoutPdf(
// // // //         name: '$name',
// // // //         onLayout: (_) async => pdf.save(),
// // // //       );

// // // //       _showSuccess('تم طباعة الفاتورة بنجاح');
// // // //     } catch (e) {
// // // //       _showError(e.toString());
// // // //     } finally {
// // // //       setState(() => _isGeneratingPDF = false);
// // // //     }
// // // //   }

// // // //   pdfLib.Widget _invoiceHeader(
// // // //     String invoiceId,
// // // //     DateTime? date,
// // // //     String company,
// // // //     String location,
// // // //     String name,
// // // //   ) {
// // // //     return pdfLib.Column(
// // // //       children: [
// // // //         pdfLib.Row(
// // // //           mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
// // // //           crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
// // // //           children: [
// // // //             pdfLib.Column(
// // // //               crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
// // // //               children: [
// // // //                 pdfLib.Text('شركة نيوجراند لخدمات النقل'),
// // // //                 pdfLib.Text('السادة شركة : $company'),
// // // //                 pdfLib.Text('مذكور للمشروعات'),
// // // //                 pdfLib.Text('موقع : ${location.isNotEmpty ? location : '_ '}'),
// // // //               ],
// // // //             ),
// // // //             pdfLib.Column(
// // // //               children: [
// // // //                 pdfLib.Text(
// // // //                   '$name',
// // // //                   style: pdfLib.TextStyle(
// // // //                     font: _arabicFont,
// // // //                     fontSize: 18,
// // // //                     fontWeight: pdfLib.FontWeight.bold,
// // // //                     decoration: pdfLib.TextDecoration.underline,
// // // //                   ),
// // // //                 ),
// // // //                 pdfLib.Text(
// // // //                   date != null
// // // //                       ? DateFormat('d/M/yyyy').format(date)
// // // //                       : '1/2/2023',
// // // //                   style: pdfLib.TextStyle(font: _arabicFont, fontSize: 11),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //             // اللوجو الجديد
// // // //             _buildLogoWidget(),
// // // //           ],
// // // //         ),
// // // //         pdfLib.Divider(),
// // // //       ],
// // // //     );
// // // //   }

// // // //   // دالة منفصلة لبناء اللوجو
// // // //   pdfLib.Widget _buildLogoWidget() {
// // // //     if (_logoImageBytes != null) {
// // // //       return pdfLib.Column(
// // // //         children: [
// // // //           pdfLib.Container(
// // // //             width: 55,
// // // //             height: 55,
// // // //             child: pdfLib.Image(
// // // //               pdfLib.MemoryImage(_logoImageBytes!),
// // // //               fit: pdfLib.BoxFit.contain,
// // // //             ),
// // // //           ),
// // // //           pdfLib.SizedBox(height: 4),
// // // //           pdfLib.Text(
// // // //             'New grand',
// // // //             style: pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold),
// // // //           ),
// // // //         ],
// // // //       );
// // // //     } else {
// // // //       return pdfLib.Column(
// // // //         children: [
// // // //           pdfLib.Container(
// // // //             width: 55,
// // // //             height: 55,
// // // //             decoration: pdfLib.BoxDecoration(
// // // //               color: pdfLib.PdfColors.black,
// // // //               shape: pdfLib.BoxShape.circle,
// // // //             ),
// // // //           ),
// // // //           pdfLib.Text(
// // // //             'New grand',
// // // //             style: pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold),
// // // //           ),
// // // //         ],
// // // //       );
// // // //     }
// // // //   }

// // // //   pdfLib.Widget _invoiceTable(
// // // //     List<Map<String, dynamic>> rows,
// // // //     bool usesTRSystem,
// // // //   ) {
// // // //     // تحديد أعمدة الجدول بناءً على نظام TR
// // // //     if (usesTRSystem) {
// // // //       // جدول مع TR (6 أعمدة)
// // // //       return pdfLib.Table(
// // // //         border: pdfLib.TableBorder.all(
// // // //           color: pdfLib.PdfColors.black,
// // // //           width: 1.3,
// // // //         ),
// // // //         columnWidths: const {
// // // //           5: pdfLib.FlexColumnWidth(1.2), // القيمة الإجمالية
// // // //           4: pdfLib.FlexColumnWidth(1), // السعر
// // // //           3: pdfLib.FlexColumnWidth(3), // البيان
// // // //           2: pdfLib.FlexColumnWidth(1), // عدد/طن
// // // //           1: pdfLib.FlexColumnWidth(1), // TR Number
// // // //           0: pdfLib.FlexColumnWidth(1.2), // التاريخ
// // // //         },
// // // //         children: [
// // // //           pdfLib.TableRow(
// // // //             decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
// // // //             children: [
// // // //               _th('القيمة الإجمالية'),
// // // //               _th('السعر'),
// // // //               _th('عدد/طن'),
// // // //               _th('البيان'),
// // // //               _th('TR\nNumber'),
// // // //               _th('التاريخ'),
// // // //             ],
// // // //           ),
// // // //           ...rows.map(
// // // //             (e) => pdfLib.TableRow(
// // // //               children: [
// // // //                 _td(_format(e['total'])),
// // // //                 _td(_format(e['price'])),
// // // //                 _td(e['count'].toString()),
// // // //                 _td(e['description'], right: true),
// // // //                 _td(e['tr']),
// // // //                 _td(e['date']),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //           ...List.generate(
// // // //             17 - rows.length > 0 ? 17 - rows.length : 0,
// // // //             (_) => pdfLib.TableRow(
// // // //               children: List.generate(6, (i) => _td(i == 5 ? '0' : '')),
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       );
// // // //     } else {
// // // //       // جدول بدون TR (5 أعمدة)
// // // //       return pdfLib.Table(
// // // //         border: pdfLib.TableBorder.all(
// // // //           color: pdfLib.PdfColors.black,
// // // //           width: 1.3,
// // // //         ),
// // // //         columnWidths: const {
// // // //           4: pdfLib.FlexColumnWidth(1.2), // القيمة الإجمالية
// // // //           3: pdfLib.FlexColumnWidth(4), // السعر
// // // //           2: pdfLib.FlexColumnWidth(1), // البيان (أوسع بدون TR)
// // // //           1: pdfLib.FlexColumnWidth(1), // عدد/طن
// // // //           0: pdfLib.FlexColumnWidth(1.2), // التاريخ
// // // //         },
// // // //         children: [
// // // //           pdfLib.TableRow(
// // // //             decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
// // // //             children: [
// // // //               _th('القيمة الإجمالية'),
// // // //               _th('السعر'),
// // // //               _th('عدد/طن'),
// // // //               _th('البيان'),
// // // //               _th('التاريخ'),
// // // //             ],
// // // //           ),
// // // //           ...rows.map(
// // // //             (e) => pdfLib.TableRow(
// // // //               children: [
// // // //                 _td(_format(e['total'])),
// // // //                 _td(_format(e['price'])),
// // // //                 _td(e['count'].toString()),
// // // //                 _td(e['description'], right: true),
// // // //                 _td(e['date']),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //           ...List.generate(
// // // //             17 - rows.length > 0 ? 17 - rows.length : 0,
// // // //             (_) => pdfLib.TableRow(
// // // //               children: List.generate(5, (i) => _td(i == 4 ? '0' : '')),
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       );
// // // //     }
// // // //   }

// // // //   pdfLib.Widget _totalsSection(double total, double tax, double afterTax) {
// // // //     return pdfLib.Column(
// // // //       children: [
// // // //         pdfLib.Table(
// // // //           border: pdfLib.TableBorder.all(),
// // // //           columnWidths: const {
// // // //             1: pdfLib.FlexColumnWidth(6),
// // // //             0: pdfLib.FlexColumnWidth(1),
// // // //           },
// // // //           children: [
// // // //             _totalRow('الإجمالي', total),
// // // //             _totalRow('14% ضريبة مبيعات', tax),
// // // //             _totalRow('الإجمالي بعد الضريبة', afterTax),
// // // //           ],
// // // //         ),
// // // //         pdfLib.SizedBox(height: 5),
// // // //         pdfLib.Align(
// // // //           alignment: pdfLib.Alignment.centerRight,
// // // //           child: pdfLib.Column(
// // // //             crossAxisAlignment: pdfLib.CrossAxisAlignment.end,
// // // //             children: [
// // // //               pdfLib.Text(
// // // //                 'سجل تجاري : $x',
// // // //                 style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
// // // //               ),
// // // //               pdfLib.Text(
// // // //                 'بطاقة ضريبة : $xx',
// // // //                 style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //         pdfLib.Text(
// // // //           'الفاتورة الغير مختومة بختم الشركة لايعتد بها',
// // // //           style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
// // // //         ),
// // // //       ],
// // // //     );
// // // //   }

// // // //   pdfLib.Widget _th(String t) => pdfLib.Padding(
// // // //     padding: const pdfLib.EdgeInsets.all(5),
// // // //     child: pdfLib.Text(
// // // //       t,
// // // //       textAlign: pdfLib.TextAlign.center,
// // // //       style: pdfLib.TextStyle(
// // // //         font: _arabicFont,
// // // //         fontWeight: pdfLib.FontWeight.bold,
// // // //         fontSize: 10,
// // // //       ),
// // // //     ),
// // // //   );

// // // //   pdfLib.Widget _td(String t, {bool right = false}) => pdfLib.Padding(
// // // //     padding: const pdfLib.EdgeInsets.all(5),
// // // //     child: pdfLib.Text(
// // // //       t,
// // // //       textAlign: right ? pdfLib.TextAlign.right : pdfLib.TextAlign.center,
// // // //       style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
// // // //     ),
// // // //   );

// // // //   pdfLib.TableRow _totalRow(String label, double v) {
// // // //     return pdfLib.TableRow(children: [_td(_format(v)), _td(label)]);
// // // //   }

// // // //   String _format(num v) => v.toStringAsFixed(0);

// // // //   String _getCompanyLocationName(List<Map<String, dynamic>> trips) {
// // // //     for (final t in trips) {
// // // //       final l = t['companyLocationName']?.toString() ?? '';
// // // //       if (l.isNotEmpty) return l;
// // // //     }
// // // //     return '';
// // // //   }

// // // //   List<Map<String, dynamic>> _groupTripsForInvoice(
// // // //     List<Map<String, dynamic>> trips,
// // // //   ) {
// // // //     final Map<String, Map<String, dynamic>> grouped = {};

// // // //     for (final trip in trips) {
// // // //       final date = trip['date'] != null
// // // //           ? DateFormat('d/M/yyyy').format((trip['date'] as DateTime))
// // // //           : DateFormat('d/M/yyyy').format(DateTime.now());
// // // //       final tr = trip['tr']?.toString() ?? '';
// // // //       final nolon = (trip['nolon'] ?? 0).toDouble();
// // // //       final companyOvernight = (trip['companyOvernight'] ?? 0).toDouble();
// // // //       final companyHoliday = (trip['companyHoliday'] ?? 0).toDouble();
// // // //       final selectedRoute = trip['selectedRoute']?.toString() ?? '';
// // // //       final selectedRoute2 = trip['selectedRoute2']?.toString() ?? '';
// // // //       final vehicleType = trip['vehicleType']?.toString() ?? '';
// // // //       final karta = trip['karta']?.toString() ?? '';

// // // //       final companyLocationName = trip['companyLocationName']?.toString() ?? '';

// // // //       String description = " ";
// // // //       if (companyLocationName.isNotEmpty) {
// // // //         description +=
// // // //             '   تحميل على ${vehicleType} من  ${selectedRoute}  الى  ${selectedRoute2} ';
// // // //       }

// // // //       // إضافة الكارتة للوصف
// // // //       // if (karta.isNotEmpty) {
// // // //       //   description += ' (كارتة: $karta)';
// // // //       // }

// // // //       final key = '$date|$tr|$nolon|$selectedRoute';

// // // //       if (!grouped.containsKey(key)) {
// // // //         grouped[key] = {
// // // //           'date': date,
// // // //           'tr': tr,
// // // //           'description': description,
// // // //           'nolon': nolon,
// // // //           'nolonCount': 1,
// // // //           'overnight': companyOvernight,
// // // //           'overnightCount': companyOvernight > 0 ? 1 : 0,
// // // //           'holiday': companyHoliday,
// // // //           'holidayCount': companyHoliday > 0 ? 1 : 0,
// // // //           'selectedRoute': selectedRoute,
// // // //           'companyLocationName': companyLocationName,
// // // //           'karta': karta,
// // // //         };
// // // //       } else {
// // // //         final existing = grouped[key]!;
// // // //         existing['nolonCount'] = (existing['nolonCount'] as int) + 1;
// // // //         if (companyOvernight > 0) {
// // // //           existing['overnightCount'] = (existing['overnightCount'] as int) + 1;
// // // //         }
// // // //         if (companyHoliday > 0) {
// // // //           existing['holidayCount'] = (existing['holidayCount'] as int) + 1;
// // // //         }
// // // //         // دمج الكارتات
// // // //         if (karta.isNotEmpty &&
// // // //             !(existing['karta'] as String).contains(karta)) {
// // // //           existing['karta'] = '${existing['karta']}، $karta';
// // // //         }
// // // //       }
// // // //     }

// // // //     final List<Map<String, dynamic>> result = [];

// // // //     grouped.forEach((key, tripGroup) {
// // // //       if (tripGroup['nolonCount'] > 0) {
// // // //         result.add({
// // // //           'type': 'نولون',
// // // //           'date': tripGroup['date'],
// // // //           'tr': tripGroup['tr'],
// // // //           'description': tripGroup['description'],
// // // //           'count': tripGroup['nolonCount'],
// // // //           'price': tripGroup['nolon'],
// // // //           'total':
// // // //               (tripGroup['nolonCount'] as int) * (tripGroup['nolon'] as double),
// // // //         });
// // // //       }
// // // //       if (tripGroup['overnightCount'] > 0) {
// // // //         result.add({
// // // //           'type': 'مبيت',
// // // //           'date': tripGroup['date'],
// // // //           'tr': tripGroup['tr'],
// // // //           'description': 'مبيت >>>${tripGroup['description']}',
// // // //           'count': tripGroup['overnightCount'],
// // // //           'price': tripGroup['overnight'],
// // // //           'total':
// // // //               (tripGroup['overnightCount'] as int) *
// // // //               (tripGroup['overnight'] as double),
// // // //         });
// // // //       }
// // // //       if (tripGroup['holidayCount'] > 0) {
// // // //         result.add({
// // // //           'type': 'عطلة',
// // // //           'date': tripGroup['date'],
// // // //           'tr': tripGroup['tr'],
// // // //           'description': 'عطلة >>>${tripGroup['description']}',
// // // //           'count': tripGroup['holidayCount'],
// // // //           'price': tripGroup['holiday'],
// // // //           'total':
// // // //               (tripGroup['holidayCount'] as int) *
// // // //               (tripGroup['holiday'] as double),
// // // //         });
// // // //       }
// // // //     });

// // // //     return result;
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
// // // //           if (_selectedCompany == null) _buildSearchBar(),
// // // //           Expanded(
// // // //             child: _selectedCompany == null
// // // //                 ? _buildCompanyList()
// // // //                 : _buildCompanySections(),
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
// // // //             /// زر واحد فقط (شركة أو رجوع)
// // // //             IconButton(
// // // //               icon: Icon(
// // // //                 _selectedCompany == null ? Icons.business : Icons.arrow_back,
// // // //                 color: Colors.white,
// // // //                 size: 28,
// // // //               ),
// // // //               onPressed: _selectedCompany != null ? _backToCompanies : null,
// // // //             ),

// // // //             const SizedBox(width: 8),

// // // //             Expanded(
// // // //               child: Center(
// // // //                 child: Text(
// // // //                   _selectedCompany == null ? 'اختر شركة' : '$_selectedCompany',
// // // //                   style: const TextStyle(
// // // //                     color: Colors.white,
// // // //                     fontSize: 20,
// // // //                     fontWeight: FontWeight.bold,
// // // //                   ),
// // // //                 ),
// // // //               ),
// // // //             ),

// // // //             if (_selectedCompany == null)
// // // //               IconButton(
// // // //                 icon: const Icon(Icons.sync, color: Colors.white),
// // // //                 onPressed: _syncDataOnPageEnter,
// // // //                 tooltip: 'مزامنة حسابات الشركات',
// // // //               ),
// // // //           ],
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

// // // //     return _filteredCompanies.isEmpty
// // // //         ? Center(
// // // //             child: Column(
// // // //               mainAxisAlignment: MainAxisAlignment.center,
// // // //               children: [
// // // //                 Icon(Icons.business, size: 80, color: Colors.grey[400]),
// // // //                 const SizedBox(height: 16),
// // // //                 const Text(
// // // //                   'لا توجد شركات',
// // // //                   style: TextStyle(
// // // //                     fontSize: 16,
// // // //                     color: Colors.grey,
// // // //                     fontWeight: FontWeight.bold,
// // // //                   ),
// // // //                   textAlign: TextAlign.center,
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           )
// // // //         : ListView.builder(
// // // //             padding: const EdgeInsets.all(8),
// // // //             itemCount: _filteredCompanies.length,
// // // //             itemBuilder: (context, index) {
// // // //               final company = _filteredCompanies[index];
// // // //               return _buildCompanyCard(company);
// // // //             },
// // // //           );
// // // //   }

// // // //   Widget _buildCompanyCard(Map<String, dynamic> company) {
// // // //     final companyName = company['companyName'];
// // // //     final companyId = company['companyId'];
// // // //     final totalTrips = company['totalTrips'] ?? 0;
// // // //     final totalNolon = company['totalNolon'] ?? 0;

// // // //     return Container(
// // // //       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
// // // //       decoration: BoxDecoration(
// // // //         color: Colors.white,
// // // //         borderRadius: BorderRadius.circular(12),
// // // //         border: Border.all(color: const Color(0xFF3498DB).withOpacity(0.3)),
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
// // // //             color: totalTrips > 0 ? const Color(0xFF3498DB) : Colors.grey,
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
// // // //             color: totalTrips > 0 ? const Color(0xFF2C3E50) : Colors.grey,
// // // //           ),
// // // //         ),
// // // //         subtitle: Text(
// // // //           totalTrips > 0
// // // //               ? '$totalTrips رحلة - ${_formatCurrency(totalNolon)}'
// // // //               : 'لا توجد رحلات',
// // // //           style: TextStyle(
// // // //             color: totalTrips > 0 ? Colors.green : Colors.grey,
// // // //             fontSize: 12,
// // // //           ),
// // // //         ),
// // // //         trailing: const Icon(
// // // //           Icons.arrow_forward_ios,
// // // //           color: Color(0xFF3498DB),
// // // //           size: 16,
// // // //         ),
// // // //         onTap: () => _loadCompanyData(companyName, companyId),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _buildCompanySections() {
// // // //     return Column(
// // // //       children: [
// // // //         // تبويبات الأقسام
// // // //         _buildSectionTabs(),
// // // //         Expanded(
// // // //           child: _currentSection == 0
// // // //               ? _buildWorkTable()
// // // //               : _currentSection == 1
// // // //               ? _buildCreateInvoiceSection()
// // // //               : _buildInvoicesSection(),
// // // //         ),
// // // //       ],
// // // //     );
// // // //   }

// // // //   Widget _buildSectionTabs() {
// // // //     return Container(
// // // //       color: Colors.white,
// // // //       child: Row(
// // // //         children: [
// // // //           _buildSectionTab(0, Icons.list, 'شغل الشركات'),
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

// // // //   Widget _buildWorkTable() {
// // // //     if (_isLoading) return const Center(child: CircularProgressIndicator());

// // // //     // ترتيب الرحلات من الأقدم إلى الأحدث
// // // //     final sortedWork = List<Map<String, dynamic>>.from(_companyWork)
// // // //       ..sort((a, b) {
// // // //         final dateA = a['date'] as DateTime? ?? DateTime(1900);
// // // //         final dateB = b['date'] as DateTime? ?? DateTime(1900);
// // // //         return dateA.compareTo(dateB);
// // // //       });

// // // //     return Column(
// // // //       children: [
// // // //         Expanded(
// // // //           child: Container(
// // // //             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // // //             decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
// // // //             child: sortedWork.isEmpty
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
// // // //                       ],
// // // //                     ),
// // // //                   )
// // // //                 : SingleChildScrollView(
// // // //                     scrollDirection: Axis.horizontal,
// // // //                     child: SingleChildScrollView(
// // // //                       scrollDirection: Axis.vertical,
// // // //                       child: Table(
// // // //                         defaultColumnWidth: const FixedColumnWidth(89),
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
// // // //                               TableCellHeader('الحالة'),
// // // //                               TableCellHeader('TR'),
// // // //                               TableCellHeader('موقع الشركة'),
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
// // // //                           ...sortedWork.asMap().entries.map((entry) {
// // // //                             final index = entry.key;
// // // //                             final work = entry.value;
// // // //                             final hasInvoice = work['hasInvoice'];

// // // //                             return TableRow(
// // // //                               decoration: BoxDecoration(
// // // //                                 color: index.isEven
// // // //                                     ? Colors.white
// // // //                                     : const Color(0xFFF8F9FA),
// // // //                               ),
// // // //                               children: [
// // // //                                 TableCellBody(
// // // //                                   hasInvoice ? 'مفوتورة' : 'متاحة',
// // // //                                   textStyle: TextStyle(
// // // //                                     fontWeight: FontWeight.bold,
// // // //                                     color: hasInvoice
// // // //                                         ? Colors.red
// // // //                                         : Colors.green,
// // // //                                   ),
// // // //                                 ),
// // // //                                 TableCellBody(
// // // //                                   work['tr'] ?? '-',
// // // //                                   textStyle: const TextStyle(
// // // //                                     fontWeight: FontWeight.bold,
// // // //                                     color: Color(0xFF2C3E50),
// // // //                                   ),
// // // //                                 ),
// // // //                                 TableCellBody(
// // // //                                   work['companyLocationName'] ?? '-',
// // // //                                   textStyle: const TextStyle(
// // // //                                     fontWeight: FontWeight.bold,
// // // //                                     color: Color(0xFF3498DB),
// // // //                                   ),
// // // //                                 ),
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
// // // //                           }),
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
// // // //     if (_isLoading) return const Center(child: CircularProgressIndicator());

// // // //     return _availableTripsForInvoice.isEmpty
// // // //         ? Center(
// // // //             child: Column(
// // // //               mainAxisAlignment: MainAxisAlignment.center,
// // // //               children: [
// // // //                 const Icon(Icons.receipt, size: 80, color: Colors.grey),
// // // //                 const SizedBox(height: 20),
// // // //                 const Text(
// // // //                   'لا توجد رحلات متاحة للفاتورة',
// // // //                   style: TextStyle(
// // // //                     fontSize: 18,
// // // //                     color: Colors.grey,
// // // //                     fontWeight: FontWeight.bold,
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(height: 10),
// // // //                 const Text(
// // // //                   'جميع الرحلات تم عمل فاتورة لها',
// // // //                   style: TextStyle(color: Colors.grey),
// // // //                   textAlign: TextAlign.center,
// // // //                 ),
// // // //                 const SizedBox(height: 30),
// // // //                 ElevatedButton.icon(
// // // //                   onPressed: () => _changeSection(0),
// // // //                   icon: const Icon(Icons.list),
// // // //                   label: const Text('عرض جميع الرحلات'),
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

// // // //               // جدول الرحلات المتاحة مع خيار التحديد
// // // //               Expanded(
// // // //                 child: Container(
// // // //                   margin: const EdgeInsets.all(16),
// // // //                   decoration: BoxDecoration(
// // // //                     borderRadius: BorderRadius.circular(12),
// // // //                   ),
// // // //                   child: SingleChildScrollView(
// // // //                     scrollDirection: Axis.horizontal,
// // // //                     child: SingleChildScrollView(
// // // //                       scrollDirection: Axis.vertical,
// // // //                       child: Table(
// // // //                         defaultColumnWidth: const FixedColumnWidth(89),
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
// // // //                               TableCellHeader('تحديد'),
// // // //                               TableCellHeader('TR'),
// // // //                               TableCellHeader('موقع الشركة'),
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
// // // //                           ..._availableTripsForInvoice.asMap().entries.map((
// // // //                             entry,
// // // //                           ) {
// // // //                             final index = entry.key;
// // // //                             final work = entry.value;
// // // //                             final isSelected = _selectedTripsForInvoice.any(
// // // //                               (trip) => trip['id'] == work['id'],
// // // //                             );

// // // //                             return TableRow(
// // // //                               decoration: BoxDecoration(
// // // //                                 color: isSelected
// // // //                                     ? const Color(0xFFE8F5E9)
// // // //                                     : index.isEven
// // // //                                     ? Colors.white
// // // //                                     : const Color(0xFFF8F9FA),
// // // //                               ),
// // // //                               children: [
// // // //                                 TableCell(
// // // //                                   child: Container(
// // // //                                     height: 48,
// // // //                                     alignment: Alignment.center,
// // // //                                     child: Checkbox(
// // // //                                       value: isSelected,
// // // //                                       onChanged: (value) {
// // // //                                         _toggleTripSelection(
// // // //                                           work,
// // // //                                           value ?? false,
// // // //                                         );
// // // //                                       },
// // // //                                     ),
// // // //                                   ),
// // // //                                 ),
// // // //                                 TableCellBody(
// // // //                                   work['tr'] ?? '-',
// // // //                                   textStyle: const TextStyle(
// // // //                                     fontWeight: FontWeight.bold,
// // // //                                     color: Color(0xFF2C3E50),
// // // //                                   ),
// // // //                                 ),
// // // //                                 TableCellBody(
// // // //                                   work['companyLocationName'] ?? '-',
// // // //                                   textStyle: const TextStyle(
// // // //                                     fontWeight: FontWeight.bold,
// // // //                                     color: Color(0xFF3498DB),
// // // //                                   ),
// // // //                                 ),
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
// // // //                           }),
// // // //                         ],
// // // //                       ),
// // // //                     ),
// // // //                   ),
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

// // // //   Widget _buildInvoicesSection() {
// // // //     if (_isLoading) return const Center(child: CircularProgressIndicator());

// // // //     return Column(
// // // //       children: [
// // // //         Container(
// // // //           padding: const EdgeInsets.all(16),
// // // //           color: Colors.blue[50],
// // // //           child: Row(
// // // //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //             children: [
// // // //               const Text(
// // // //                 'فواتير الشركة',
// // // //                 style: TextStyle(
// // // //                   fontWeight: FontWeight.bold,
// // // //                   color: Color(0xFF3498DB),
// // // //                 ),
// // // //               ),
// // // //               Text(
// // // //                 '${_companyInvoices.length} فاتورة',
// // // //                 style: const TextStyle(
// // // //                   fontWeight: FontWeight.bold,
// // // //                   color: Color(0xFF2E7D32),
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //         Expanded(
// // // //           child: _companyInvoices.isEmpty
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
// // // //                   itemCount: _companyInvoices.length,
// // // //                   itemBuilder: (context, index) {
// // // //                     final invoice = _companyInvoices[index];
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
// // // //               ' ${createdAt != null ? _formatDate(createdAt) : 'غير معروف'}  ---  رحلة >>> ${invoice['tripCount']}',
// // // //               style: const TextStyle(fontSize: 12, color: Colors.grey),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //         trailing: Row(
// // // //           mainAxisSize: MainAxisSize.min,
// // // //           children: [
// // // //             Column(
// // // //               mainAxisAlignment: MainAxisAlignment.center,
// // // //               children: [
// // // //                 Text(
// // // //                   _formatCurrency(invoice['totalAmount']),
// // // //                   style: const TextStyle(
// // // //                     fontWeight: FontWeight.bold,
// // // //                     fontSize: 16,
// // // //                     color: Color(0xFF2E7D32),
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(height: 4),
// // // //                 Text(
// // // //                   'إجمالي',
// // // //                   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //             const SizedBox(width: 10),
// // // //             // زر مطالبة الكارتات
// // // //             IconButton(
// // // //               icon: Icon(Icons.credit_card, color: Color(0xFF9C27B0)),
// // // //               onPressed: _isGeneratingPDF
// // // //                   ? null
// // // //                   : () => _printKartaRequest(invoice),
// // // //               tooltip: 'مطالبة كارتات',
// // // //             ),
// // // //             const SizedBox(width: 5),
// // // //             // زر طباعة الفاتورة
// // // //             IconButton(
// // // //               icon: Icon(Icons.print, color: Color(0xFF3498DB)),
// // // //               onPressed: _isGeneratingPDF ? null : () => _printInvoice(invoice),
// // // //               tooltip: 'طباعة الفاتورة',
// // // //             ),
// // // //           ],
// // // //         ),
// // // //         children: [
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
// // // //                       const SizedBox(height: 4),
// // // //                       Row(
// // // //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //                         children: [
// // // //                           const Text(
// // // //                             'عدد الكارتات:',
// // // //                             style: TextStyle(
// // // //                               fontWeight: FontWeight.bold,
// // // //                               color: Color(0xFF9C27B0),
// // // //                             ),
// // // //                           ),
// // // //                           Text(
// // // //                             '${invoice['kartaDetails']?.length ?? 0}',
// // // //                             style: const TextStyle(color: Color(0xFF9C27B0)),
// // // //                           ),
// // // //                         ],
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 ),

// // // //                 const SizedBox(height: 12),

// // // //                 // أزرار الطباعة
// // // //                 Row(
// // // //                   children: [
// // // //                     Expanded(
// // // //                       child: ElevatedButton.icon(
// // // //                         onPressed: _isGeneratingPDF
// // // //                             ? null
// // // //                             : () => _printKartaRequest(invoice),
// // // //                         icon: _isGeneratingPDF
// // // //                             ? const SizedBox(
// // // //                                 width: 20,
// // // //                                 height: 20,
// // // //                                 child: CircularProgressIndicator(
// // // //                                   color: Colors.white,
// // // //                                 ),
// // // //                               )
// // // //                             : const Icon(Icons.credit_card),
// // // //                         label: Text(
// // // //                           _isGeneratingPDF
// // // //                               ? 'جاري الطباعة...'
// // // //                               : 'مطالبة كارتات',
// // // //                           style: const TextStyle(fontSize: 16),
// // // //                         ),
// // // //                         style: ElevatedButton.styleFrom(
// // // //                           backgroundColor: Color(0xFF9C27B0),
// // // //                           foregroundColor: Colors.white,
// // // //                           padding: const EdgeInsets.symmetric(vertical: 12),
// // // //                         ),
// // // //                       ),
// // // //                     ),
// // // //                     const SizedBox(width: 8),
// // // //                     Expanded(
// // // //                       child: ElevatedButton.icon(
// // // //                         onPressed: _isGeneratingPDF
// // // //                             ? null
// // // //                             : () => _printInvoice(invoice),
// // // //                         icon: _isGeneratingPDF
// // // //                             ? const SizedBox(
// // // //                                 width: 20,
// // // //                                 height: 20,
// // // //                                 child: CircularProgressIndicator(
// // // //                                   color: Colors.white,
// // // //                                 ),
// // // //                               )
// // // //                             : const Icon(Icons.print),
// // // //                         label: Text(
// // // //                           _isGeneratingPDF
// // // //                               ? 'جاري الطباعة...'
// // // //                               : 'طباعة الفاتورة',
// // // //                           style: const TextStyle(fontSize: 16),
// // // //                         ),
// // // //                         style: ElevatedButton.styleFrom(
// // // //                           backgroundColor: Color(0xFF2E7D32),
// // // //                           foregroundColor: Colors.white,
// // // //                           padding: const EdgeInsets.symmetric(vertical: 12),
// // // //                         ),
// // // //                       ),
// // // //                     ),
// // // //                   ],
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
// // // //                             TableCellHeader('TR'),
// // // //                             TableCellHeader('موقع الشركة'),
// // // //                             TableCellHeader('النولون'),
// // // //                             TableCellHeader('المبيت'),
// // // //                             TableCellHeader('العطلة'),
// // // //                             TableCellHeader('الكارتة'),
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
// // // //                                 trip['tr'] ?? '-',
// // // //                                 textStyle: const TextStyle(
// // // //                                   fontWeight: FontWeight.bold,
// // // //                                   color: Color(0xFF2C3E50),
// // // //                                 ),
// // // //                               ),
// // // //                               TableCellBody(
// // // //                                 trip['companyLocationName'] ?? '-',
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
// // // //                               TableCellBody(
// // // //                                 trip['karta'] ?? '',
// // // //                                 textStyle: const TextStyle(
// // // //                                   fontWeight: FontWeight.bold,
// // // //                                   color: Color(0xFF9C27B0),
// // // //                                 ),
// // // //                               ),
// // // //                             ],
// // // //                           );
// // // //                         }),
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
// // // import 'dart:typed_data';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:intl/intl.dart';
// // // import 'package:pdf/pdf.dart' as pdfLib;
// // // import 'package:pdf/widgets.dart' as pdfLib;
// // // import 'package:printing/printing.dart';
// // // import 'package:flutter/services.dart' show rootBundle;

// // // class CompanyWorkPage extends StatefulWidget {
// // //   const CompanyWorkPage({super.key});

// // //   @override
// // //   State<CompanyWorkPage> createState() => _CompanyWorkPageState();
// // // }

// // // class _CompanyWorkPageState extends State<CompanyWorkPage> {
// // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// // //   pdfLib.Font? _arabicFont;

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
// // //   bool _isGeneratingPDF = false;

// // //   // متغير للمزامنة التلقائية
// // //   bool _hasSyncedOnEnter = false;

// // //   // أضف هذا المتغير في بداية الكلاس
// // //   Uint8List? _logoImageBytes;

// // //   String x = '';
// // //   String xx = '';

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadCompanies();
// // //     _loadArabicFont();
// // //     _loadLogoImage();
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _invoiceNameController.dispose();
// // //     super.dispose();
// // //   }

// // //   // ================================
// // //   // تحميل صورة اللوجو
// // //   // ================================
// // //   Future<void> _loadLogoImage() async {
// // //     try {
// // //       final ByteData data = await rootBundle.load('assets/image/logoo.jpeg');
// // //       if (mounted) {
// // //         setState(() {
// // //           _logoImageBytes = data.buffer.asUint8List();
// // //         });
// // //       }
// // //       debugPrint('تم تحميل صورة اللوجو بنجاح');
// // //     } catch (e) {
// // //       debugPrint('فشل تحميل صورة اللوجو: $e');
// // //     }
// // //   }

// // //   // ================================
// // //   // تحميل الخط العربي للطباعة
// // //   // ================================
// // //   Future<void> _loadArabicFont() async {
// // //     try {
// // //       final fontData = await rootBundle.load(
// // //         'assets/fonts/Amiri/Amiri-Regular.ttf',
// // //       );

// // //       if (mounted) {
// // //         setState(() {
// // //           _arabicFont = pdfLib.Font.ttf(fontData);
// // //         });
// // //       }
// // //       debugPrint('تم تحميل الخط العربي بنجاح');
// // //     } catch (e) {
// // //       debugPrint('فشل تحميل الخط العربي: $e');
// // //       if (mounted) {
// // //         setState(() {
// // //           _arabicFont = pdfLib.Font.courier();
// // //         });
// // //       }
// // //     }
// // //   }

// // //   // ================================
// // //   // نظام مزامنة companySummaries تلقائياً
// // //   // ================================
// // //   Future<void> _syncDataOnPageEnter() async {
// // //     debugPrint('🔄 بدء التحديث التلقائي لحسابات الشركات...');

// // //     try {
// // //       // 1. جلب جميع حسابات الشركات
// // //       final companySummaries = await _firestore
// // //           .collection('companySummaries')
// // //           .get();

// // //       // 2. حساب إجمالي الرحلات من dailyWork لكل شركة
// // //       final dailyWorkSnapshot = await _firestore.collection('dailyWork').get();

// // //       Map<String, int> dailyWorkTripCounts = {};
// // //       Map<String, double> dailyWorkTotalDebts = {};
// // //       Map<String, String> companyNames = {};

// // //       for (final doc in dailyWorkSnapshot.docs) {
// // //         final data = doc.data();
// // //         final companyId = data['companyId'] as String?;
// // //         final companyName = data['companyName'] as String?;

// // //         if (companyId != null && companyName != null) {
// // //           // حساب عدد الرحلات
// // //           dailyWorkTripCounts[companyId] =
// // //               (dailyWorkTripCounts[companyId] ?? 0) + 1;
// // //           companyNames[companyId] = companyName;

// // //           // حساب إجمالي الدين
// // //           final nolon = (data['nolon'] ?? data['noLon'] ?? 0).toDouble();
// // //           final overnight = (data['companyOvernight'] ?? 0).toDouble();
// // //           final holiday = (data['companyHoliday'] ?? 0).toDouble();

// // //           dailyWorkTotalDebts[companyId] =
// // //               (dailyWorkTotalDebts[companyId] ?? 0.0) +
// // //               nolon +
// // //               overnight +
// // //               holiday;
// // //         }
// // //       }

// // //       // 3. المقارنة والتحديث
// // //       final batch = _firestore.batch();
// // //       final summariesRef = _firestore.collection('companySummaries');

// // //       int updatedCount = 0;

// // //       for (final entry in dailyWorkTripCounts.entries) {
// // //         final companyId = entry.key;
// // //         final dailyWorkTrips = entry.value;
// // //         final companyName = companyNames[companyId] ?? 'غير معروف';
// // //         final totalDebt = dailyWorkTotalDebts[companyId] ?? 0.0;

// // //         // البحث عن حساب الشركة
// // //         DocumentSnapshot? summaryDoc;
// // //         for (final doc in companySummaries.docs) {
// // //           final data = doc.data();
// // //           if (doc.id == companyId || data['companyId'] == companyId) {
// // //             summaryDoc = doc;
// // //             break;
// // //           }
// // //         }

// // //         if (summaryDoc != null && summaryDoc.exists) {
// // //           // تحقق من عدد الرحلات
// // //           final summaryData = summaryDoc.data() as Map<String, dynamic>;
// // //           final summaryTrips = (summaryData['totalTrips'] ?? 0).toInt();
// // //           final summaryDebt = (summaryData['totalCompanyDebt'] ?? 0).toDouble();

// // //           // إذا كان عدد الرحلات أو المبلغ غير متطابق
// // //           if (dailyWorkTrips != summaryTrips || totalDebt != summaryDebt) {
// // //             final totalPaidAmount = (summaryData['totalPaidAmount'] ?? 0)
// // //                 .toDouble();
// // //             final totalRemaining = totalDebt - totalPaidAmount;

// // //             String status;
// // //             if (totalRemaining <= 0) {
// // //               status = 'منتهية';
// // //             } else if (totalPaidAmount > 0) {
// // //               status = 'شبه منتهية';
// // //             } else {
// // //               status = 'جارية';
// // //             }

// // //             batch.set(summariesRef.doc(companyId), {
// // //               'companyId': companyId,
// // //               'companyName': companyName,
// // //               'totalCompanyDebt': totalDebt,
// // //               'totalPaidAmount': totalPaidAmount,
// // //               'totalRemainingAmount': totalRemaining,
// // //               'totalTrips': dailyWorkTrips,
// // //               'status': status,
// // //               'lastUpdated': Timestamp.now(),
// // //             }, SetOptions(merge: true));

// // //             updatedCount++;
// // //           }
// // //         } else {
// // //           // الشركة ليس لها حساب، إنشاء حساب جديد
// // //           batch.set(summariesRef.doc(companyId), {
// // //             'companyId': companyId,
// // //             'companyName': companyName,
// // //             'totalCompanyDebt': totalDebt,
// // //             'totalPaidAmount': 0.0,
// // //             'totalRemainingAmount': totalDebt,
// // //             'totalTrips': dailyWorkTrips,
// // //             'status': 'جارية',
// // //             'lastUpdated': Timestamp.now(),
// // //           });

// // //           updatedCount++;
// // //         }
// // //       }

// // //       // 4. حذف حسابات الشركات التي ليس لها رحلات
// // //       for (final doc in companySummaries.docs) {
// // //         final companyId = doc.id;
// // //         if (!dailyWorkTripCounts.containsKey(companyId)) {
// // //           final data = doc.data();
// // //           final dataCompanyId = data['companyId'] as String?;

// // //           // إذا الشركة ليس لها رحلات في dailyWork
// // //           if (!dailyWorkTripCounts.containsKey(dataCompanyId ?? '')) {
// // //             // يمكنك اختيار حذفها أو تركها
// // //             // batch.delete(summariesRef.doc(companyId));
// // //             debugPrint(
// // //               '⚠️ الشركة ${data['companyName']} ليس لها رحلات في dailyWork',
// // //             );
// // //           }
// // //         }
// // //       }

// // //       if (updatedCount > 0) {
// // //         await batch.commit();
// // //         debugPrint('✅ تم تحديث $updatedCount حساب شركة تلقائياً');
// // //         _showSuccess('تم تحديث حسابات $updatedCount شركة تلقائياً');
// // //       } else {
// // //         debugPrint('✅ جميع الحسابات محدثة بالفعل');
// // //       }
// // //     } catch (e) {
// // //       debugPrint('❌ خطأ في التحديث التلقائي: $e');
// // //       _showError('خطأ في تحديث الحسابات: $e');
// // //     }
// // //   }

// // //   // ================================
// // //   // تحميل بيانات الشركات مع الإحصائيات
// // //   // ================================
// // //   Future<void> _loadCompanies() async {
// // //     if (mounted) {
// // //       setState(() => _isLoading = true);
// // //     }
// // //     try {
// // //       final companiesSnapshot = await _firestore.collection('companies').get();
// // //       final dailyWorkSnapshot = await _firestore.collection('dailyWork').get();

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

// // //         // حساب الرحلات والإحصائيات
// // //         final companyTrips = dailyWorkSnapshot.docs
// // //             .where((doc) {
// // //               final data = doc.data();
// // //               final tripCompanyId = data['companyId'] ?? '';
// // //               return tripCompanyId == companyId;
// // //             })
// // //             .map((doc) {
// // //               final data = doc.data();
// // //               final tripDate = (data['date'] as Timestamp?)?.toDate();

// // //               return {
// // //                 'id': doc.id,
// // //                 'date': tripDate,
// // //                 'nolon': (data['noLon'] ?? data['nolon'] ?? 0).toDouble(),
// // //                 'companyOvernight': (data['companyOvernight'] ?? 0).toDouble(),
// // //                 'companyHoliday': (data['companyHoliday'] ?? 0).toDouble(),
// // //               };
// // //             })
// // //             .toList();

// // //         // حساب الإجماليات
// // //         double totalNolon = 0.0;
// // //         double totalOvernight = 0.0;
// // //         double totalHoliday = 0.0;

// // //         for (var trip in companyTrips) {
// // //           totalNolon += trip['nolon'];
// // //           totalOvernight += trip['companyOvernight'];
// // //           totalHoliday += trip['companyHoliday'];
// // //         }

// // //         companiesList.add({
// // //           'companyId': companyId,
// // //           'companyName': companyName,
// // //           'companyData': companyData,
// // //           'totalTrips': companyTrips.length,
// // //           'totalNolon': totalNolon,
// // //           'totalOvernight': totalOvernight,
// // //           'totalHoliday': totalHoliday,
// // //         });
// // //       }

// // //       companiesList.sort(
// // //         (a, b) => a['companyName'].compareTo(b['companyName']),
// // //       );

// // //       if (mounted) {
// // //         setState(() {
// // //           _allCompanies = companiesList;
// // //           _filteredCompanies = _applySearchFilter(companiesList);
// // //           _isLoading = false;
// // //         });
// // //       }

// // //       // تحديث تلقائي عند دخول الصفحة الرئيسية فقط
// // //       if (!_hasSyncedOnEnter && _selectedCompany == null) {
// // //         await _syncDataOnPageEnter();
// // //         _hasSyncedOnEnter = true;
// // //       }
// // //     } catch (e) {
// // //       if (mounted) {
// // //         setState(() => _isLoading = false);
// // //       }
// // //       debugPrint('خطأ في تحميل بيانات الشركات: $e');
// // //       _showError('خطأ في تحميل الشركات: $e');
// // //     }
// // //   }

// // //   // ================================
// // //   // تحميل بيانات الشركة المختارة
// // //   // ================================
// // //   Future<void> _loadCompanyData(String companyName, String companyId) async {
// // //     if (mounted) {
// // //       setState(() {
// // //         _selectedCompany = companyName;
// // //         _selectedCompanyId = companyId;
// // //         _isLoading = true;
// // //         _companyWork.clear();
// // //         _availableTripsForInvoice.clear();
// // //         _companyInvoices.clear();
// // //         _selectedTripsForInvoice.clear();
// // //         _invoiceNameController.clear();
// // //       });
// // //     }

// // //     try {
// // //       // 1. تحميل جميع رحلات الشركة من dailyWork
// // //       final workSnapshot = await _firestore
// // //           .collection('dailyWork')
// // //           .where('companyId', isEqualTo: companyId)
// // //           .orderBy('date', descending: false) // الأقدم أولاً
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
// // //           'karta': data['karta'] ?? '', // تخزين الكارتة
// // //           'ohda': data['ohda'] ?? '',
// // //           'selectedRoute': data['selectedRoute'] ?? '',
// // //           'selectedRoute2': data['unloadingLocation'] ?? '',
// // //           'loadingLocation': data['loadingLocation'] ?? '',
// // //           'unloadingLocation': data['unloadingLocation'] ?? '',
// // //           'vehicleType': data['selectedVehicleType'] ?? '',
// // //           'notes': data['selectedNotes'] ?? '',
// // //           'tr': data['tr'] ?? '',
// // //           'companyLocationName': data['companyLocationName'] ?? '',
// // //           'hasInvoice': false,
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
// // //               'selectedRoute': tripData['loadingLocation'] ?? '',
// // //               'selectedRoute2': tripData['unloadingLocation'] ?? '',
// // //               'vehicleType': tripData['selectedVehicleType'] ?? '',
// // //               'nolon': (tripData['noLon'] ?? tripData['nolon'] ?? 0).toDouble(),
// // //               'companyOvernight': (tripData['companyOvernight'] ?? 0)
// // //                   .toDouble(),
// // //               'companyHoliday': (tripData['companyHoliday'] ?? 0).toDouble(),
// // //               'tr': tripData['tr'] ?? '',
// // //               'companyLocationName': tripData['companyLocationName'] ?? '',
// // //               'date': (tripData['date'] as Timestamp?)?.toDate(),
// // //               'karta': tripData['karta'] ?? '', // إضافة الكارتة
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
// // //           'companyId': data['companyId'] ?? companyId,
// // //           'totalAmount': (data['totalAmount'] ?? 0).toDouble(),
// // //           'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
// // //           'tripIds': tripIds,
// // //           'tripCount': tripIds.length,
// // //           'invoiceTrips': invoiceTrips,
// // //           'nolonTotal': totalNolon,
// // //           'overnightTotal': totalOvernight,
// // //           'holidayTotal': totalHoliday,
// // //           'kartaDetails': invoiceTrips
// // //               .map((trip) => trip['karta'])
// // //               .toList(), // تخزين الكارتات
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

// // //       // ترتيب الرحلات المتاحة للفاتورة: الأقدم أولاً، ثم تجميع الـ TR المتشابه
// // //       final sortedAvailableTrips = _sortAndGroupTripsForInvoice(availableTrips);

// // //       if (mounted) {
// // //         setState(() {
// // //           _companyWork = allTrips;
// // //           _availableTripsForInvoice = sortedAvailableTrips;
// // //           _companyInvoices = invoicesList;
// // //           _isLoading = false;
// // //         });
// // //       }
// // //     } catch (e) {
// // //       if (mounted) {
// // //         setState(() => _isLoading = false);
// // //       }
// // //       _showError('خطأ في تحميل بيانات الشركة: $e');
// // //     }
// // //   }

// // //   // ================================
// // //   // الحصول على حالة نظام TR للشركة
// // //   // ================================
// // //   Future<bool> _getCompanyTRStatus(String companyId) async {
// // //     try {
// // //       final companyDoc = await _firestore
// // //           .collection('companies')
// // //           .doc(companyId)
// // //           .get();
// // //       if (companyDoc.exists) {
// // //         final data = companyDoc.data() as Map<String, dynamic>;
// // //         x = data['commercialRegister'];
// // //         xx = data['taxCard'];

// // //         return data['usesTRSystem'] ?? false;
// // //       }
// // //       return false;
// // //     } catch (e) {
// // //       debugPrint('خطأ في جلب حالة TR: $e');
// // //       return false;
// // //     }
// // //   }

// // //   // ================================
// // //   // ترتيب وتجميع الرحلات للفاتورة
// // //   // ================================
// // //   List<Map<String, dynamic>> _sortAndGroupTripsForInvoice(
// // //     List<Map<String, dynamic>> trips,
// // //   ) {
// // //     if (trips.isEmpty) return [];

// // //     // 1. ترتيب الرحلات حسب التاريخ (الأقدم أولاً)
// // //     trips.sort((a, b) {
// // //       final dateA = a['date'] as DateTime? ?? DateTime(1900);
// // //       final dateB = b['date'] as DateTime? ?? DateTime(1900);
// // //       return dateA.compareTo(dateB);
// // //     });

// // //     // 2. تجميع الرحلات حسب التاريخ والـ TR
// // //     final Map<String, List<Map<String, dynamic>>> groupedTrips = {};

// // //     for (var trip in trips) {
// // //       final date = trip['date'] as DateTime?;
// // //       final tr = trip['tr']?.toString() ?? '';
// // //       final dateKey = date != null
// // //           ? DateFormat('yyyy-MM-dd').format(date)
// // //           : 'unknown_date';

// // //       // المفتاح: التاريخ + الـ TR
// // //       final key = '$dateKey|$tr';

// // //       if (!groupedTrips.containsKey(key)) {
// // //         groupedTrips[key] = [];
// // //       }
// // //       groupedTrips[key]!.add(trip);
// // //     }

// // //     // 3. تحويل المجموعات إلى قائمة مرتبة
// // //     final List<Map<String, dynamic>> result = [];

// // //     // الحصول على المفاتيح وترتيبها حسب التاريخ
// // //     final sortedKeys = groupedTrips.keys.toList()
// // //       ..sort((a, b) {
// // //         // استخراج التاريخ من المفتاح
// // //         final datePartA = a.split('|')[0];
// // //         final datePartB = b.split('|')[0];
// // //         return datePartA.compareTo(datePartB);
// // //       });

// // //     // إضافة الرحلات المجمعة
// // //     for (var key in sortedKeys) {
// // //       final tripsInGroup = groupedTrips[key]!;

// // //       // ترتيب الرحلات داخل المجموعة حسب الوقت إذا كان موجوداً
// // //       tripsInGroup.sort((a, b) {
// // //         final timeA = (a['date'] as DateTime?)?.toIso8601String() ?? '';
// // //         final timeB = (b['date'] as DateTime?)?.toIso8601String() ?? '';
// // //         return timeA.compareTo(timeB);
// // //       });

// // //       result.addAll(tripsInGroup);
// // //     }

// // //     return result;
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
// // //     if (!mounted) return;
// // //     setState(() {
// // //       if (selected) {
// // //         _selectedTripsForInvoice.add(trip);
// // //       } else {
// // //         _selectedTripsForInvoice.removeWhere((t) => t['id'] == trip['id']);
// // //       }
// // //     });
// // //   }

// // //   void _selectAllTrips(bool select) {
// // //     if (!mounted) return;
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

// // //     if (mounted) {
// // //       setState(() => _isCreatingInvoice = true);
// // //     }

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

// // //         // تخزين تفاصيل الرحلة بما فيها الكارتة
// // //         invoiceTripDetails.add({
// // //           'selectedRoute': trip['selectedRoute'],
// // //           'selectedRoute2': trip['selectedRoute2'],
// // //           'vehicleType': trip['vehicleType'],
// // //           'nolon': trip['nolon'],
// // //           'companyOvernight': trip['companyOvernight'],
// // //           'companyHoliday': trip['companyHoliday'],
// // //           'tr': trip['tr'],
// // //           'companyLocationName': trip['companyLocationName'],
// // //           'date': trip['date'],
// // //           'karta': trip['karta'] ?? '', // تخزين الكارتة
// // //         });
// // //       }

// // //       double totalAmount = totalNolon + totalOvernight + totalHoliday;

// // //       // حفظ الفاتورة مع الكارتات
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
// // //         'kartaDetails': _selectedTripsForInvoice
// // //             .map((trip) => trip['karta'] ?? '')
// // //             .toList(), // تخزين الكارتات
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

// // //       // تحديث حساب الشركة في companySummaries
// // //       await _updateCompanySummaryAfterInvoice(totalAmount);

// // //       _showSuccess('تم إنشاء الفاتورة بنجاح');

// // //       // إعادة تحميل بيانات الشركة
// // //       await _loadCompanyData(_selectedCompany!, _selectedCompanyId!);

// // //       // تنظيف المتغيرات
// // //       if (mounted) {
// // //         setState(() {
// // //           _selectedTripsForInvoice.clear();
// // //           _invoiceNameController.clear();
// // //         });
// // //       }

// // //       // الذهاب إلى قسم الفواتير
// // //       _changeSection(2);
// // //     } catch (e) {
// // //       _showError('خطأ في إنشاء الفاتورة: $e');
// // //     } finally {
// // //       if (mounted) {
// // //         setState(() => _isCreatingInvoice = false);
// // //       }
// // //     }
// // //   }

// // //   // ================================
// // //   // تحديث حساب الشركة بعد إنشاء الفاتورة
// // //   // ================================
// // //   Future<void> _updateCompanySummaryAfterInvoice(double invoiceAmount) async {
// // //     try {
// // //       final summaryRef = _firestore
// // //           .collection('companySummaries')
// // //           .doc(_selectedCompanyId!);

// // //       final summaryDoc = await summaryRef.get();

// // //       if (summaryDoc.exists) {
// // //         final data = summaryDoc.data() as Map<String, dynamic>;
// // //         final currentTotalPaid = (data['totalPaidAmount'] ?? 0).toDouble();
// // //         final newTotalPaid = currentTotalPaid + invoiceAmount;
// // //         final totalDebt = (data['totalCompanyDebt'] ?? 0).toDouble();
// // //         final totalRemaining = totalDebt - newTotalPaid;

// // //         String status;
// // //         if (totalRemaining <= 0) {
// // //           status = 'منتهية';
// // //         } else if (newTotalPaid > 0) {
// // //           status = 'شبه منتهية';
// // //         } else {
// // //           status = 'جارية';
// // //         }

// // //         await summaryRef.update({
// // //           'totalPaidAmount': newTotalPaid,
// // //           'totalRemainingAmount': totalRemaining,
// // //           'status': status,
// // //           'lastUpdated': Timestamp.now(),
// // //         });

// // //         debugPrint('✅ تم تحديث حساب الشركة بعد إنشاء الفاتورة');
// // //       }
// // //     } catch (e) {
// // //       debugPrint('⚠️ خطأ في تحديث حساب الشركة بعد الفاتورة: $e');
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

// // //   String _formatCurrencyForPDF(double amount) {
// // //     return amount.toStringAsFixed(2);
// // //   }

// // //   void _changeSection(int section) {
// // //     if (!mounted) return;
// // //     setState(() {
// // //       _currentSection = section;
// // //       if (section == 1) {
// // //         _selectedTripsForInvoice.clear();
// // //         _invoiceNameController.clear();
// // //       }
// // //     });
// // //   }

// // //   void _backToCompanies() {
// // //     if (!mounted) return;
// // //     setState(() {
// // //       _selectedCompany = null;
// // //       _selectedCompanyId = null;
// // //       _companyWork.clear();
// // //       _availableTripsForInvoice.clear();
// // //       _companyInvoices.clear();
// // //       _selectedTripsForInvoice.clear();
// // //       _invoiceNameController.clear();
// // //       _hasSyncedOnEnter = false; // إعادة تعيين لعند الدخول التالي
// // //     });
// // //     _loadCompanies();
// // //   }

// // //   Future<void> _printKartaRequest(Map<String, dynamic> invoice) async {
// // //     if (_arabicFont == null) {
// // //       await _loadArabicFont();
// // //     }

// // //     if (mounted) {
// // //       setState(() => _isGeneratingPDF = true);
// // //     }

// // //     try {
// // //       final trips =
// // //           invoice['invoiceTrips'] as List<Map<String, dynamic>>? ?? [];
// // //       final invoiceName = invoice['name'] ?? '';
// // //       final companyName = invoice['companyName'] ?? 'غير معروف';
// // //       final createdAt = invoice['createdAt'] as DateTime?;

// // //       // استخراج الشهر من تاريخ الفاتورة
// // //       String monthYear = 'غير محدد';
// // //       if (createdAt != null) {
// // //         monthYear = '${createdAt.month}/${createdAt.year}';
// // //       }

// // //       // الحصول على الموقع الفعلي (companyLocationName) من الرحلات
// // //       String companyLocation = '';
// // //       for (var trip in trips) {
// // //         final location = trip['companyLocationName']?.toString() ?? '';
// // //         if (location.isNotEmpty) {
// // //           companyLocation = location;
// // //           break;
// // //         }
// // //       }

// // //       // إذا لم يوجد موقع، استخدم 'الموقع' كقيمة افتراضية
// // //       if (companyLocation.isEmpty) {
// // //         companyLocation = 'الموقع';
// // //       }

// // //       // ترتيب الرحلات حسب التاريخ
// // //       final List<Map<String, dynamic>> sortedTrips = List.from(trips)
// // //         ..sort((a, b) {
// // //           final dateA = a['date'] as DateTime? ?? DateTime(1900);
// // //           final dateB = b['date'] as DateTime? ?? DateTime(1900);
// // //           return dateA.compareTo(dateB);
// // //         });

// // //       // إنشاء صفوف الجدول - كل رحلة في سطر منفصل
// // //       final List<Map<String, dynamic>> tableRows = [];
// // //       double totalKartasValue = 0;
// // //       int rowNumber = 1;

// // //       for (var trip in sortedTrips) {
// // //         final date = trip['date'] as DateTime?;
// // //         final karta = trip['karta']?.toString() ?? '';
// // //         final ohda = trip['ohda']?.toString() ?? '';

// // //         // حساب قيمة الكارتة إذا كانت رقماً
// // //         double kartaValue = 0;
// // //         try {
// // //           final cleanedKarta = karta.trim();
// // //           if (cleanedKarta.isNotEmpty) {
// // //             kartaValue = double.tryParse(cleanedKarta) ?? 0;
// // //           }
// // //         } catch (e) {
// // //           debugPrint('خطأ في تحويل الكارتة إلى رقم: $karta');
// // //         }

// // //         // جمع القيمة الإجمالية
// // //         totalKartasValue += kartaValue;

// // //         // تنسيق التاريخ (يوم/شهر فقط)
// // //         String formattedDate = '-';
// // //         if (date != null) {
// // //           formattedDate = '${date.day}/${date.month}';
// // //         }
// // //         if (kartaValue != 0) {
// // //           tableRows.add({
// // //             'rowNumber': rowNumber.toString(),
// // //             'date': formattedDate,
// // //             'karta': karta,
// // //             'ohda': ohda,
// // //             'kartaValue': kartaValue,
// // //           });

// // //           rowNumber++;
// // //         }
// // //       }

// // //       final pdf = pdfLib.Document(
// // //         theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
// // //       );
// // //       pdf.addPage(
// // //         pdfLib.MultiPage(
// // //           pageFormat: pdfLib.PdfPageFormat.a4,
// // //           margin: const pdfLib.EdgeInsets.only(right: 60, left: 60),
// // //           build: (context) => [
// // //             pdfLib.Directionality(
// // //               textDirection: pdfLib.TextDirection.rtl,
// // //               child: pdfLib.Column(
// // //                 crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
// // //                 children: [
// // //                   _kartaRequestHeader(
// // //                     invoiceName,
// // //                     monthYear,
// // //                     companyName,
// // //                     companyLocation,
// // //                   ),
// // //                   pdfLib.SizedBox(height: 20),
// // //                   _kartaRequestTable(tableRows, totalKartasValue),
// // //                   pdfLib.SizedBox(height: 20),
// // //                 ],
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       );

// // //       await Printing.layoutPdf(
// // //         name: 'مطالبة كارتات - $invoiceName',
// // //         onLayout: (_) async => pdf.save(),
// // //       );

// // //       _showSuccess('تم طباعة مطالبة الكارتات بنجاح');
// // //     } catch (e) {
// // //       _showError('خطأ في طباعة مطالبة الكارتات: $e');
// // //     } finally {
// // //       if (mounted) {
// // //         setState(() => _isGeneratingPDF = false);
// // //       }
// // //     }
// // //   }

// // //   // ================================
// // //   // ترويسة مطالبة الكارتات
// // //   // ================================
// // //   pdfLib.Widget _kartaRequestHeader(
// // //     String invoiceName,
// // //     String monthYear,
// // //     String companyName,
// // //     String location,
// // //   ) {
// // //     return pdfLib.Column(
// // //       crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
// // //       children: [
// // //         pdfLib.Text(
// // //           'فاتورة رقم ( $invoiceName )',
// // //           style: pdfLib.TextStyle(
// // //             font: _arabicFont,
// // //             fontSize: 18,
// // //             fontWeight: pdfLib.FontWeight.bold,
// // //           ),
// // //           textAlign: pdfLib.TextAlign.center,
// // //         ),
// // //         pdfLib.SizedBox(height: 10),
// // //         pdfLib.Text(
// // //           'مطالبة كارتات فاتورة شهر $monthYear م',
// // //           style: pdfLib.TextStyle(
// // //             font: _arabicFont,
// // //             fontSize: 16,
// // //             fontWeight: pdfLib.FontWeight.bold,
// // //           ),
// // //           textAlign: pdfLib.TextAlign.center,
// // //         ),
// // //         pdfLib.SizedBox(height: 10),
// // //         pdfLib.Text(
// // //           'عن موقع ( $location )( $companyName)',
// // //           style: pdfLib.TextStyle(font: _arabicFont, fontSize: 14),
// // //           textAlign: pdfLib.TextAlign.center,
// // //         ),
// // //         pdfLib.SizedBox(height: 20),
// // //       ],
// // //     );
// // //   }

// // //   // ================================
// // //   // جدول مطالبة الكارتات كما في الصورة
// // //   // ================================
// // //   pdfLib.Widget _kartaRequestTable(
// // //     List<Map<String, dynamic>> rows,
// // //     double totalKartasValue,
// // //   ) {
// // //     return pdfLib.Table(
// // //       border: pdfLib.TableBorder.all(color: pdfLib.PdfColors.black, width: 1),
// // //       columnWidths: const {
// // //         0: pdfLib.FlexColumnWidth(1.5), // المسلسل
// // //         1: pdfLib.FlexColumnWidth(1), // التاريخ
// // //         2: pdfLib.FlexColumnWidth(1), // القيمة (الكارتة)
// // //       },
// // //       children: [
// // //         // رأس الجدول كما في الصورة
// // //         pdfLib.TableRow(
// // //           decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
// // //           children: [
// // //             _kartaTableCell('القيمة', isHeader: true),

// // //             _kartaTableCell('التاريخ', isHeader: true),
// // //             _kartaTableCell('المسلسل', isHeader: true),
// // //           ],
// // //         ),

// // //         // صفوف البيانات - كل رحلة في سطر منفصل
// // //         ...rows.map(
// // //           (row) => pdfLib.TableRow(
// // //             children: [
// // //               _kartaTableCell(row['karta']?.toString() ?? ''),

// // //               _kartaTableCell(row['date']),
// // //               _kartaTableCell(row['rowNumber']),
// // //             ],
// // //           ),
// // //         ),

// // //         // الصف الأخير الإجمالي كما في الصورة
// // //         pdfLib.TableRow(
// // //           children: [
// // //             _kartaTableCell(
// // //               _formatCurrencyForPDF(totalKartasValue),
// // //               isTotal: true,
// // //             ),
// // //             _kartaTableCell('--', isTotal: true),
// // //             _kartaTableCell('الإجمالي', isTotal: true),
// // //           ],
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   // ================================
// // //   // خلية جدول مطالبة الكارتات
// // //   // ================================
// // //   pdfLib.Widget _kartaTableCell(
// // //     String text, {
// // //     bool isHeader = false,
// // //     bool isTotal = false,
// // //   }) {
// // //     return pdfLib.Container(
// // //       padding: const pdfLib.EdgeInsets.all(8),
// // //       child: pdfLib.Text(
// // //         text,
// // //         textAlign: pdfLib.TextAlign.center,
// // //         style: pdfLib.TextStyle(
// // //           font: _arabicFont,
// // //           fontSize: isTotal ? 12 : 10,
// // //           fontWeight: isHeader || isTotal
// // //               ? pdfLib.FontWeight.bold
// // //               : pdfLib.FontWeight.normal,
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ================================
// // //   // دوال الطباعة
// // //   // ================================
// // //   Future<void> _printInvoice(Map<String, dynamic> invoice) async {
// // //     if (_arabicFont == null) {
// // //       await _loadArabicFont();
// // //     }

// // //     if (mounted) {
// // //       setState(() => _isGeneratingPDF = true);
// // //     }

// // //     try {
// // //       final trips =
// // //           invoice['invoiceTrips'] as List<Map<String, dynamic>>? ?? [];
// // //       final invoiceId = invoice['id']?.toString() ?? '623';
// // //       final createdAt = invoice['createdAt'] as DateTime?;
// // //       final companyName = invoice['companyName'] ?? ' ';
// // //       final name = invoice['name'] ?? '';
// // //       final companyId = invoice['companyId'] ?? _selectedCompanyId;

// // //       // التحقق إذا كانت الشركة تعمل بنظام TR
// // //       final bool usesTRSystem = companyId != null
// // //           ? await _getCompanyTRStatus(companyId)
// // //           : false;

// // //       final groupedTrips = _groupTripsForInvoice(trips);
// // //       final location = _getCompanyLocationName(trips);

// // //       final total = groupedTrips.fold<double>(0.0, (sum, e) {
// // //         final value = e['total'];
// // //         if (value is num) {
// // //           return sum + value.toDouble();
// // //         }
// // //         return sum;
// // //       });

// // //       final tax = total * 0.14;
// // //       final afterTax = total + tax;

// // //       final pdf = pdfLib.Document(
// // //         theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
// // //       );

// // //       pdf.addPage(
// // //         pdfLib.MultiPage(
// // //           pageFormat: pdfLib.PdfPageFormat.a4,
// // //           margin: const pdfLib.EdgeInsets.only(right: 60, left: 60),
// // //           build: (context) => [
// // //             pdfLib.Directionality(
// // //               textDirection: pdfLib.TextDirection.rtl,
// // //               child: pdfLib.Column(
// // //                 crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
// // //                 children: [
// // //                   _invoiceHeader(
// // //                     invoiceId,
// // //                     createdAt,
// // //                     companyName,
// // //                     location,
// // //                     name,
// // //                   ),
// // //                   pdfLib.SizedBox(height: 10),
// // //                   _invoiceTable(groupedTrips, usesTRSystem),
// // //                   pdfLib.SizedBox(height: 10),
// // //                   _totalsSection(total, tax, afterTax),
// // //                 ],
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       );

// // //       await Printing.layoutPdf(
// // //         name: '$name',
// // //         onLayout: (_) async => pdf.save(),
// // //       );

// // //       _showSuccess('تم طباعة الفاتورة بنجاح');
// // //     } catch (e) {
// // //       _showError(e.toString());
// // //     } finally {
// // //       if (mounted) {
// // //         setState(() => _isGeneratingPDF = false);
// // //       }
// // //     }
// // //   }

// // //   pdfLib.Widget _invoiceHeader(
// // //     String invoiceId,
// // //     DateTime? date,
// // //     String company,
// // //     String location,
// // //     String name,
// // //   ) {
// // //     return pdfLib.Column(
// // //       children: [
// // //         pdfLib.Row(
// // //           mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
// // //           crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
// // //           children: [
// // //             pdfLib.Column(
// // //               crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
// // //               children: [
// // //                 pdfLib.Text('شركة نيوجراند لخدمات النقل'),
// // //                 pdfLib.Text('السادة شركة : $company'),
// // //                 pdfLib.Text('مذكور للمشروعات'),
// // //                 pdfLib.Text('موقع : ${location.isNotEmpty ? location : '_ '}'),
// // //               ],
// // //             ),
// // //             pdfLib.Column(
// // //               children: [
// // //                 pdfLib.Text(
// // //                   '$name',
// // //                   style: pdfLib.TextStyle(
// // //                     font: _arabicFont,
// // //                     fontSize: 18,
// // //                     fontWeight: pdfLib.FontWeight.bold,
// // //                     decoration: pdfLib.TextDecoration.underline,
// // //                   ),
// // //                 ),
// // //                 pdfLib.Text(
// // //                   date != null
// // //                       ? DateFormat('d/M/yyyy').format(date)
// // //                       : '1/2/2023',
// // //                   style: pdfLib.TextStyle(font: _arabicFont, fontSize: 11),
// // //                 ),
// // //               ],
// // //             ),
// // //             // اللوجو الجديد
// // //             _buildLogoWidget(),
// // //           ],
// // //         ),
// // //         pdfLib.Divider(),
// // //       ],
// // //     );
// // //   }

// // //   // دالة منفصلة لبناء اللوجو
// // //   pdfLib.Widget _buildLogoWidget() {
// // //     if (_logoImageBytes != null) {
// // //       return pdfLib.Column(
// // //         children: [
// // //           pdfLib.Container(
// // //             width: 55,
// // //             height: 55,
// // //             child: pdfLib.Image(
// // //               pdfLib.MemoryImage(_logoImageBytes!),
// // //               fit: pdfLib.BoxFit.contain,
// // //             ),
// // //           ),
// // //           pdfLib.SizedBox(height: 4),
// // //           pdfLib.Text(
// // //             'New grand',
// // //             style: pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold),
// // //           ),
// // //         ],
// // //       );
// // //     } else {
// // //       return pdfLib.Column(
// // //         children: [
// // //           pdfLib.Container(
// // //             width: 55,
// // //             height: 55,
// // //             decoration: pdfLib.BoxDecoration(
// // //               color: pdfLib.PdfColors.black,
// // //               shape: pdfLib.BoxShape.circle,
// // //             ),
// // //           ),
// // //           pdfLib.Text(
// // //             'New grand',
// // //             style: pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold),
// // //           ),
// // //         ],
// // //       );
// // //     }
// // //   }

// // //   pdfLib.Widget _invoiceTable(
// // //     List<Map<String, dynamic>> rows,
// // //     bool usesTRSystem,
// // //   ) {
// // //     // تحديد أعمدة الجدول بناءً على نظام TR
// // //     if (usesTRSystem) {
// // //       // جدول مع TR (6 أعمدة)
// // //       return pdfLib.Table(
// // //         border: pdfLib.TableBorder.all(
// // //           color: pdfLib.PdfColors.black,
// // //           width: 1.3,
// // //         ),
// // //         columnWidths: const {
// // //           5: pdfLib.FlexColumnWidth(1.2), // القيمة الإجمالية
// // //           4: pdfLib.FlexColumnWidth(1), // السعر
// // //           3: pdfLib.FlexColumnWidth(3), // البيان
// // //           2: pdfLib.FlexColumnWidth(1), // عدد/طن
// // //           1: pdfLib.FlexColumnWidth(1), // TR Number
// // //           0: pdfLib.FlexColumnWidth(1.2), // التاريخ
// // //         },
// // //         children: [
// // //           pdfLib.TableRow(
// // //             decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
// // //             children: [
// // //               _th('القيمة الإجمالية'),
// // //               _th('السعر'),
// // //               _th('عدد/طن'),
// // //               _th('البيان'),
// // //               _th('TR\nNumber'),
// // //               _th('التاريخ'),
// // //             ],
// // //           ),
// // //           ...rows.map(
// // //             (e) => pdfLib.TableRow(
// // //               children: [
// // //                 _td(_format(e['total'])),
// // //                 _td(_format(e['price'])),
// // //                 _td(e['count'].toString()),
// // //                 _td(e['description'], right: true),
// // //                 _td(e['tr']),
// // //                 _td(e['date']),
// // //               ],
// // //             ),
// // //           ),
// // //           ...List.generate(
// // //             17 - rows.length > 0 ? 17 - rows.length : 0,
// // //             (_) => pdfLib.TableRow(
// // //               children: List.generate(6, (i) => _td(i == 5 ? '0' : '')),
// // //             ),
// // //           ),
// // //         ],
// // //       );
// // //     } else {
// // //       // جدول بدون TR (5 أعمدة)
// // //       return pdfLib.Table(
// // //         border: pdfLib.TableBorder.all(
// // //           color: pdfLib.PdfColors.black,
// // //           width: 1.3,
// // //         ),
// // //         columnWidths: const {
// // //           4: pdfLib.FlexColumnWidth(1.2), // القيمة الإجمالية
// // //           3: pdfLib.FlexColumnWidth(4), // السعر
// // //           2: pdfLib.FlexColumnWidth(1), // البيان (أوسع بدون TR)
// // //           1: pdfLib.FlexColumnWidth(1), // عدد/طن
// // //           0: pdfLib.FlexColumnWidth(1.2), // التاريخ
// // //         },
// // //         children: [
// // //           pdfLib.TableRow(
// // //             decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
// // //             children: [
// // //               _th('القيمة الإجمالية'),
// // //               _th('السعر'),
// // //               _th('عدد/طن'),
// // //               _th('البيان'),
// // //               _th('التاريخ'),
// // //             ],
// // //           ),
// // //           ...rows.map(
// // //             (e) => pdfLib.TableRow(
// // //               children: [
// // //                 _td(_format(e['total'])),
// // //                 _td(_format(e['price'])),
// // //                 _td(e['count'].toString()),
// // //                 _td(e['description'], right: true),
// // //                 _td(e['date']),
// // //               ],
// // //             ),
// // //           ),
// // //           ...List.generate(
// // //             17 - rows.length > 0 ? 17 - rows.length : 0,
// // //             (_) => pdfLib.TableRow(
// // //               children: List.generate(5, (i) => _td(i == 4 ? '0' : '')),
// // //             ),
// // //           ),
// // //         ],
// // //       );
// // //     }
// // //   }

// // //   pdfLib.Widget _totalsSection(double total, double tax, double afterTax) {
// // //     return pdfLib.Column(
// // //       children: [
// // //         pdfLib.Table(
// // //           border: pdfLib.TableBorder.all(),
// // //           columnWidths: const {
// // //             1: pdfLib.FlexColumnWidth(6),
// // //             0: pdfLib.FlexColumnWidth(1),
// // //           },
// // //           children: [
// // //             _totalRow('الإجمالي', total),
// // //             _totalRow('14% ضريبة مبيعات', tax),
// // //             _totalRow('الإجمالي بعد الضريبة', afterTax),
// // //           ],
// // //         ),
// // //         pdfLib.SizedBox(height: 5),
// // //         pdfLib.Align(
// // //           alignment: pdfLib.Alignment.centerRight,
// // //           child: pdfLib.Column(
// // //             crossAxisAlignment: pdfLib.CrossAxisAlignment.end,
// // //             children: [
// // //               pdfLib.Text(
// // //                 'سجل تجاري : $x',
// // //                 style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
// // //               ),
// // //               pdfLib.Text(
// // //                 'بطاقة ضريبة : $xx',
// // //                 style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //         pdfLib.Text(
// // //           'الفاتورة الغير مختومة بختم الشركة لايعتد بها',
// // //           style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   pdfLib.Widget _th(String t) => pdfLib.Padding(
// // //     padding: const pdfLib.EdgeInsets.all(5),
// // //     child: pdfLib.Text(
// // //       t,
// // //       textAlign: pdfLib.TextAlign.center,
// // //       style: pdfLib.TextStyle(
// // //         font: _arabicFont,
// // //         fontWeight: pdfLib.FontWeight.bold,
// // //         fontSize: 10,
// // //       ),
// // //     ),
// // //   );

// // //   pdfLib.Widget _td(String t, {bool right = false}) => pdfLib.Padding(
// // //     padding: const pdfLib.EdgeInsets.all(5),
// // //     child: pdfLib.Text(
// // //       t,
// // //       textAlign: right ? pdfLib.TextAlign.right : pdfLib.TextAlign.center,
// // //       style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
// // //     ),
// // //   );

// // //   pdfLib.TableRow _totalRow(String label, double v) {
// // //     return pdfLib.TableRow(children: [_td(_format(v)), _td(label)]);
// // //   }

// // //   String _format(num v) => v.toStringAsFixed(0);

// // //   String _getCompanyLocationName(List<Map<String, dynamic>> trips) {
// // //     for (final t in trips) {
// // //       final l = t['companyLocationName']?.toString() ?? '';
// // //       if (l.isNotEmpty) return l;
// // //     }
// // //     return '';
// // //   }

// // //   List<Map<String, dynamic>> _groupTripsForInvoice(
// // //     List<Map<String, dynamic>> trips,
// // //   ) {
// // //     final Map<String, Map<String, dynamic>> grouped = {};

// // //     for (final trip in trips) {
// // //       final date = trip['date'] != null
// // //           ? DateFormat('d/M/yyyy').format((trip['date'] as DateTime))
// // //           : DateFormat('d/M/yyyy').format(DateTime.now());
// // //       final tr = trip['tr']?.toString() ?? '';
// // //       final nolon = (trip['nolon'] ?? 0).toDouble();
// // //       final companyOvernight = (trip['companyOvernight'] ?? 0).toDouble();
// // //       final companyHoliday = (trip['companyHoliday'] ?? 0).toDouble();
// // //       final selectedRoute = trip['selectedRoute']?.toString() ?? '';
// // //       final selectedRoute2 = trip['selectedRoute2']?.toString() ?? '';
// // //       final vehicleType = trip['vehicleType']?.toString() ?? '';
// // //       final karta = trip['karta']?.toString() ?? '';

// // //       final companyLocationName = trip['companyLocationName']?.toString() ?? '';

// // //       String description = " ";
// // //       if (companyLocationName.isNotEmpty) {
// // //         description +=
// // //             '   تحميل على ${vehicleType} من  ${selectedRoute}  الى  ${selectedRoute2} ';
// // //       }

// // //       // إضافة الكارتة للوصف
// // //       // if (karta.isNotEmpty) {
// // //       //   description += ' (كارتة: $karta)';
// // //       // }

// // //       final key = '$date|$tr|$nolon|$selectedRoute';

// // //       if (!grouped.containsKey(key)) {
// // //         grouped[key] = {
// // //           'date': date,
// // //           'tr': tr,
// // //           'description': description,
// // //           'nolon': nolon,
// // //           'nolonCount': 1,
// // //           'overnight': companyOvernight,
// // //           'overnightCount': companyOvernight > 0 ? 1 : 0,
// // //           'holiday': companyHoliday,
// // //           'holidayCount': companyHoliday > 0 ? 1 : 0,
// // //           'selectedRoute': selectedRoute,
// // //           'companyLocationName': companyLocationName,
// // //           'karta': karta,
// // //         };
// // //       } else {
// // //         final existing = grouped[key]!;
// // //         existing['nolonCount'] = (existing['nolonCount'] as int) + 1;
// // //         if (companyOvernight > 0) {
// // //           existing['overnightCount'] = (existing['overnightCount'] as int) + 1;
// // //         }
// // //         if (companyHoliday > 0) {
// // //           existing['holidayCount'] = (existing['holidayCount'] as int) + 1;
// // //         }
// // //         // دمج الكارتات
// // //         if (karta.isNotEmpty &&
// // //             !(existing['karta'] as String).contains(karta)) {
// // //           existing['karta'] = '${existing['karta']}، $karta';
// // //         }
// // //       }
// // //     }

// // //     final List<Map<String, dynamic>> result = [];

// // //     grouped.forEach((key, tripGroup) {
// // //       if (tripGroup['nolonCount'] > 0) {
// // //         result.add({
// // //           'type': 'نولون',
// // //           'date': tripGroup['date'],
// // //           'tr': tripGroup['tr'],
// // //           'description': tripGroup['description'],
// // //           'count': tripGroup['nolonCount'],
// // //           'price': tripGroup['nolon'],
// // //           'total':
// // //               (tripGroup['nolonCount'] as int) * (tripGroup['nolon'] as double),
// // //         });
// // //       }
// // //       if (tripGroup['overnightCount'] > 0) {
// // //         result.add({
// // //           'type': 'مبيت',
// // //           'date': tripGroup['date'],
// // //           'tr': tripGroup['tr'],
// // //           'description': 'مبيت >>>${tripGroup['description']}',
// // //           'count': tripGroup['overnightCount'],
// // //           'price': tripGroup['overnight'],
// // //           'total':
// // //               (tripGroup['overnightCount'] as int) *
// // //               (tripGroup['overnight'] as double),
// // //         });
// // //       }
// // //       if (tripGroup['holidayCount'] > 0) {
// // //         result.add({
// // //           'type': 'عطلة',
// // //           'date': tripGroup['date'],
// // //           'tr': tripGroup['tr'],
// // //           'description': 'عطلة >>>${tripGroup['description']}',
// // //           'count': tripGroup['holidayCount'],
// // //           'price': tripGroup['holiday'],
// // //           'total':
// // //               (tripGroup['holidayCount'] as int) *
// // //               (tripGroup['holiday'] as double),
// // //         });
// // //       }
// // //     });

// // //     return result;
// // //   }

// // //   List<List<Map<String, dynamic>>> _splitRows(
// // //     List<Map<String, dynamic>> rows,
// // //     int pageSize,
// // //   ) {
// // //     final List<List<Map<String, dynamic>>> pages = [];
// // //     for (int i = 0; i < rows.length; i += pageSize) {
// // //       pages.add(
// // //         rows.sublist(
// // //           i,
// // //           i + pageSize > rows.length ? rows.length : i + pageSize,
// // //         ),
// // //       );
// // //     }
// // //     return pages;
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
// // //             /// زر واحد فقط (شركة أو رجوع)
// // //             IconButton(
// // //               icon: Icon(
// // //                 _selectedCompany == null ? Icons.business : Icons.arrow_back,
// // //                 color: Colors.white,
// // //                 size: 28,
// // //               ),
// // //               onPressed: _selectedCompany != null ? _backToCompanies : null,
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

// // //             if (_selectedCompany == null)
// // //               IconButton(
// // //                 icon: const Icon(Icons.sync, color: Colors.white),
// // //                 onPressed: _syncDataOnPageEnter,
// // //                 tooltip: 'مزامنة حسابات الشركات',
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
// // //     final totalTrips = company['totalTrips'] ?? 0;
// // //     final totalNolon = company['totalNolon'] ?? 0;

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
// // //             color: totalTrips > 0 ? const Color(0xFF3498DB) : Colors.grey,
// // //             borderRadius: BorderRadius.circular(22.5),
// // //           ),
// // //           child: Center(
// // //             child: Text(
// // //               totalTrips.toString(),
// // //               style: const TextStyle(
// // //                 color: Colors.white,
// // //                 fontWeight: FontWeight.bold,
// // //                 fontSize: 16,
// // //               ),
// // //             ),
// // //           ),
// // //         ),
// // //         title: Text(
// // //           companyName,
// // //           style: TextStyle(
// // //             fontWeight: FontWeight.bold,
// // //             fontSize: 16,
// // //             color: totalTrips > 0 ? const Color(0xFF2C3E50) : Colors.grey,
// // //           ),
// // //         ),
// // //         subtitle: Text(
// // //           totalTrips > 0
// // //               ? '$totalTrips رحلة - ${_formatCurrency(totalNolon)}'
// // //               : 'لا توجد رحلات',
// // //           style: TextStyle(
// // //             color: totalTrips > 0 ? Colors.green : Colors.grey,
// // //             fontSize: 12,
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

// // //     // ترتيب الرحلات من الأقدم إلى الأحدث
// // //     final sortedWork = List<Map<String, dynamic>>.from(_companyWork)
// // //       ..sort((a, b) {
// // //         final dateA = a['date'] as DateTime? ?? DateTime(1900);
// // //         final dateB = b['date'] as DateTime? ?? DateTime(1900);
// // //         return dateA.compareTo(dateB);
// // //       });

// // //     return Column(
// // //       children: [
// // //         Expanded(
// // //           child: Container(
// // //             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // //             decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
// // //             child: sortedWork.isEmpty
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
// // //                         defaultColumnWidth: const FixedColumnWidth(89),
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
// // //                               TableCellHeader('TR'),
// // //                               TableCellHeader('موقع الشركة'),
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
// // //                           ...sortedWork.asMap().entries.map((entry) {
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
// // //                                   work['tr'] ?? '-',
// // //                                   textStyle: const TextStyle(
// // //                                     fontWeight: FontWeight.bold,
// // //                                     color: Color(0xFF2C3E50),
// // //                                   ),
// // //                                 ),
// // //                                 TableCellBody(
// // //                                   work['companyLocationName'] ?? '-',
// // //                                   textStyle: const TextStyle(
// // //                                     fontWeight: FontWeight.bold,
// // //                                     color: Color(0xFF3498DB),
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
// // //                         defaultColumnWidth: const FixedColumnWidth(89),
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
// // //                               TableCellHeader('تحديد'),
// // //                               TableCellHeader('TR'),
// // //                               TableCellHeader('موقع الشركة'),
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
// // //                                   work['tr'] ?? '-',
// // //                                   textStyle: const TextStyle(
// // //                                     fontWeight: FontWeight.bold,
// // //                                     color: Color(0xFF2C3E50),
// // //                                   ),
// // //                                 ),
// // //                                 TableCellBody(
// // //                                   work['companyLocationName'] ?? '-',
// // //                                   textStyle: const TextStyle(
// // //                                     fontWeight: FontWeight.bold,
// // //                                     color: Color(0xFF3498DB),
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
// // //                           }),
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
// // //               ' ${createdAt != null ? _formatDate(createdAt) : 'غير معروف'}  ---  رحلة >>> ${invoice['tripCount']}',
// // //               style: const TextStyle(fontSize: 12, color: Colors.grey),
// // //             ),
// // //           ],
// // //         ),
// // //         trailing: Row(
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             Column(
// // //               mainAxisAlignment: MainAxisAlignment.center,
// // //               children: [
// // //                 Text(
// // //                   _formatCurrency(invoice['totalAmount']),
// // //                   style: const TextStyle(
// // //                     fontWeight: FontWeight.bold,
// // //                     fontSize: 16,
// // //                     color: Color(0xFF2E7D32),
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 4),
// // //                 Text(
// // //                   'إجمالي',
// // //                   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
// // //                 ),
// // //               ],
// // //             ),
// // //             const SizedBox(width: 10),
// // //             // زر مطالبة الكارتات
// // //             IconButton(
// // //               icon: Icon(Icons.credit_card, color: Color(0xFF9C27B0)),
// // //               onPressed: _isGeneratingPDF
// // //                   ? null
// // //                   : () => _printKartaRequest(invoice),
// // //               tooltip: 'مطالبة كارتات',
// // //             ),
// // //             const SizedBox(width: 5),
// // //             // زر طباعة الفاتورة
// // //             IconButton(
// // //               icon: Icon(Icons.print, color: Color(0xFF3498DB)),
// // //               onPressed: _isGeneratingPDF ? null : () => _printInvoice(invoice),
// // //               tooltip: 'طباعة الفاتورة',
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
// // //                       const SizedBox(height: 4),
// // //                       Row(
// // //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                         children: [
// // //                           const Text(
// // //                             'عدد الكارتات:',
// // //                             style: TextStyle(
// // //                               fontWeight: FontWeight.bold,
// // //                               color: Color(0xFF9C27B0),
// // //                             ),
// // //                           ),
// // //                           Text(
// // //                             '${invoice['kartaDetails']?.length ?? 0}',
// // //                             style: const TextStyle(color: Color(0xFF9C27B0)),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),

// // //                 const SizedBox(height: 12),

// // //                 // أزرار الطباعة
// // //                 Row(
// // //                   children: [
// // //                     Expanded(
// // //                       child: ElevatedButton.icon(
// // //                         onPressed: _isGeneratingPDF
// // //                             ? null
// // //                             : () => _printKartaRequest(invoice),
// // //                         icon: _isGeneratingPDF
// // //                             ? const SizedBox(
// // //                                 width: 20,
// // //                                 height: 20,
// // //                                 child: CircularProgressIndicator(
// // //                                   color: Colors.white,
// // //                                 ),
// // //                               )
// // //                             : const Icon(Icons.credit_card),
// // //                         label: Text(
// // //                           _isGeneratingPDF
// // //                               ? 'جاري الطباعة...'
// // //                               : 'مطالبة كارتات',
// // //                           style: const TextStyle(fontSize: 16),
// // //                         ),
// // //                         style: ElevatedButton.styleFrom(
// // //                           backgroundColor: Color(0xFF9C27B0),
// // //                           foregroundColor: Colors.white,
// // //                           padding: const EdgeInsets.symmetric(vertical: 12),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                     const SizedBox(width: 8),
// // //                     Expanded(
// // //                       child: ElevatedButton.icon(
// // //                         onPressed: _isGeneratingPDF
// // //                             ? null
// // //                             : () => _printInvoice(invoice),
// // //                         icon: _isGeneratingPDF
// // //                             ? const SizedBox(
// // //                                 width: 20,
// // //                                 height: 20,
// // //                                 child: CircularProgressIndicator(
// // //                                   color: Colors.white,
// // //                                 ),
// // //                               )
// // //                             : const Icon(Icons.print),
// // //                         label: Text(
// // //                           _isGeneratingPDF
// // //                               ? 'جاري الطباعة...'
// // //                               : 'طباعة الفاتورة',
// // //                           style: const TextStyle(fontSize: 16),
// // //                         ),
// // //                         style: ElevatedButton.styleFrom(
// // //                           backgroundColor: Color(0xFF2E7D32),
// // //                           foregroundColor: Colors.white,
// // //                           padding: const EdgeInsets.symmetric(vertical: 12),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ],
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
// // //                             TableCellHeader('TR'),
// // //                             TableCellHeader('موقع الشركة'),
// // //                             TableCellHeader('النولون'),
// // //                             TableCellHeader('المبيت'),
// // //                             TableCellHeader('العطلة'),
// // //                             TableCellHeader('الكارتة'),
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
// // //                                 trip['tr'] ?? '-',
// // //                                 textStyle: const TextStyle(
// // //                                   fontWeight: FontWeight.bold,
// // //                                   color: Color(0xFF2C3E50),
// // //                                 ),
// // //                               ),
// // //                               TableCellBody(
// // //                                 trip['companyLocationName'] ?? '-',
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
// // //                               TableCellBody(
// // //                                 trip['karta'] ?? '',
// // //                                 textStyle: const TextStyle(
// // //                                   fontWeight: FontWeight.bold,
// // //                                   color: Color(0xFF9C27B0),
// // //                                 ),
// // //                               ),
// // //                             ],
// // //                           );
// // //                         }),
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
// // import 'dart:typed_data';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import 'package:pdf/pdf.dart' as pdfLib;
// // import 'package:pdf/widgets.dart' as pdfLib;
// // import 'package:printing/printing.dart';
// // import 'package:flutter/services.dart' show rootBundle;

// // class CompanyWorkPage extends StatefulWidget {
// //   const CompanyWorkPage({super.key});

// //   @override
// //   State<CompanyWorkPage> createState() => _CompanyWorkPageState();
// // }

// // class _CompanyWorkPageState extends State<CompanyWorkPage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   pdfLib.Font? _arabicFont;

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
// //   final TextEditingController _invoiceNotesController = TextEditingController();
// //   String _selectedMonth = 'كل الشهور'; // اختيار شهر الإدراج
// //   List<String> _monthsList = [
// //     'كل الشهور',
// //     'يناير',
// //     'فبراير',
// //     'مارس',
// //     'أبريل',
// //     'مايو',
// //     'يونيو',
// //     'يوليو',
// //     'أغسطس',
// //     'سبتمبر',
// //     'أكتوبر',
// //     'نوفمبر',
// //     'ديسمبر',
// //   ];
// //   bool _isCreatingInvoice = false;
// //   bool _isGeneratingPDF = false;

// //   // متغيرات قسم الفواتير
// //   String _selectedMonthFilter = 'كل الشهور'; // فلترة حسب الشهر
// //   bool _showCollected = false; // إظهار الفواتير المحصلة
// //   bool _showNotCollected = true; // إظهار الفواتير غير المحصلة

// //   // متغير للمزامنة التلقائية
// //   bool _hasSyncedOnEnter = false;

// //   // أضف هذا المتغير في بداية الكلاس
// //   Uint8List? _logoImageBytes;

// //   String x = '';
// //   String xx = '';

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadCompanies();
// //     _loadArabicFont();
// //     _loadLogoImage();
// //     // تعيين الشهر الحالي كقيمة افتراضية
// //     _selectedMonth = _monthsList[DateTime.now().month];
// //     _selectedMonthFilter = _monthsList[DateTime.now().month];
// //   }

// //   @override
// //   void dispose() {
// //     _invoiceNameController.dispose();
// //     _invoiceNotesController.dispose();
// //     super.dispose();
// //   }

// //   // ================================
// //   // تحميل صورة اللوجو
// //   // ================================
// //   Future<void> _loadLogoImage() async {
// //     try {
// //       final ByteData data = await rootBundle.load('assets/image/logoo.jpeg');
// //       if (mounted) {
// //         setState(() {
// //           _logoImageBytes = data.buffer.asUint8List();
// //         });
// //       }
// //       debugPrint('تم تحميل صورة اللوجو بنجاح');
// //     } catch (e) {
// //       debugPrint('فشل تحميل صورة اللوجو: $e');
// //     }
// //   }

// //   // ================================
// //   // تحميل الخط العربي للطباعة
// //   // ================================
// //   Future<void> _loadArabicFont() async {
// //     try {
// //       final fontData = await rootBundle.load(
// //         'assets/fonts/Amiri/Amiri-Regular.ttf',
// //       );

// //       if (mounted) {
// //         setState(() {
// //           _arabicFont = pdfLib.Font.ttf(fontData);
// //         });
// //       }
// //       debugPrint('تم تحميل الخط العربي بنجاح');
// //     } catch (e) {
// //       debugPrint('فشل تحميل الخط العربي: $e');
// //       if (mounted) {
// //         setState(() {
// //           _arabicFont = pdfLib.Font.courier();
// //         });
// //       }
// //     }
// //   }

// //   // ================================
// //   // نظام مزامنة companySummaries تلقائياً
// //   // ================================
// //   Future<void> _syncDataOnPageEnter() async {
// //     debugPrint('🔄 بدء التحديث التلقائي لحسابات الشركات...');

// //     try {
// //       // 1. جلب جميع حسابات الشركات
// //       final companySummaries = await _firestore
// //           .collection('companySummaries')
// //           .get();

// //       // 2. حساب إجمالي الرحلات من dailyWork لكل شركة
// //       final dailyWorkSnapshot = await _firestore.collection('dailyWork').get();

// //       Map<String, int> dailyWorkTripCounts = {};
// //       Map<String, double> dailyWorkTotalDebts = {};
// //       Map<String, String> companyNames = {};

// //       for (final doc in dailyWorkSnapshot.docs) {
// //         final data = doc.data();
// //         final companyId = data['companyId'] as String?;
// //         final companyName = data['companyName'] as String?;

// //         if (companyId != null && companyName != null) {
// //           // حساب عدد الرحلات
// //           dailyWorkTripCounts[companyId] =
// //               (dailyWorkTripCounts[companyId] ?? 0) + 1;
// //           companyNames[companyId] = companyName;

// //           // حساب إجمالي الدين
// //           final nolon = (data['nolon'] ?? data['noLon'] ?? 0).toDouble();
// //           final overnight = (data['companyOvernight'] ?? 0).toDouble();
// //           final holiday = (data['companyHoliday'] ?? 0).toDouble();

// //           dailyWorkTotalDebts[companyId] =
// //               (dailyWorkTotalDebts[companyId] ?? 0.0) +
// //               nolon +
// //               overnight +
// //               holiday;
// //         }
// //       }

// //       // 3. المقارنة والتحديث
// //       final batch = _firestore.batch();
// //       final summariesRef = _firestore.collection('companySummaries');

// //       int updatedCount = 0;

// //       for (final entry in dailyWorkTripCounts.entries) {
// //         final companyId = entry.key;
// //         final dailyWorkTrips = entry.value;
// //         final companyName = companyNames[companyId] ?? 'غير معروف';
// //         final totalDebt = dailyWorkTotalDebts[companyId] ?? 0.0;

// //         // البحث عن حساب الشركة
// //         DocumentSnapshot? summaryDoc;
// //         for (final doc in companySummaries.docs) {
// //           final data = doc.data();
// //           if (doc.id == companyId || data['companyId'] == companyId) {
// //             summaryDoc = doc;
// //             break;
// //           }
// //         }

// //         if (summaryDoc != null && summaryDoc.exists) {
// //           // تحقق من عدد الرحلات
// //           final summaryData = summaryDoc.data() as Map<String, dynamic>;
// //           final summaryTrips = (summaryData['totalTrips'] ?? 0).toInt();
// //           final summaryDebt = (summaryData['totalCompanyDebt'] ?? 0).toDouble();

// //           // إذا كان عدد الرحلات أو المبلغ غير متطابق
// //           if (dailyWorkTrips != summaryTrips || totalDebt != summaryDebt) {
// //             final totalPaidAmount = (summaryData['totalPaidAmount'] ?? 0)
// //                 .toDouble();
// //             final totalRemaining = totalDebt - totalPaidAmount;

// //             String status;
// //             if (totalRemaining <= 0) {
// //               status = 'منتهية';
// //             } else if (totalPaidAmount > 0) {
// //               status = 'شبه منتهية';
// //             } else {
// //               status = 'جارية';
// //             }

// //             batch.set(summariesRef.doc(companyId), {
// //               'companyId': companyId,
// //               'companyName': companyName,
// //               'totalCompanyDebt': totalDebt,
// //               'totalPaidAmount': totalPaidAmount,
// //               'totalRemainingAmount': totalRemaining,
// //               'totalTrips': dailyWorkTrips,
// //               'status': status,
// //               'lastUpdated': Timestamp.now(),
// //             }, SetOptions(merge: true));

// //             updatedCount++;
// //           }
// //         } else {
// //           // الشركة ليس لها حساب، إنشاء حساب جديد
// //           batch.set(summariesRef.doc(companyId), {
// //             'companyId': companyId,
// //             'companyName': companyName,
// //             'totalCompanyDebt': totalDebt,
// //             'totalPaidAmount': 0.0,
// //             'totalRemainingAmount': totalDebt,
// //             'totalTrips': dailyWorkTrips,
// //             'status': 'جارية',
// //             'lastUpdated': Timestamp.now(),
// //           });

// //           updatedCount++;
// //         }
// //       }

// //       // 4. حذف حسابات الشركات التي ليس لها رحلات
// //       for (final doc in companySummaries.docs) {
// //         final companyId = doc.id;
// //         if (!dailyWorkTripCounts.containsKey(companyId)) {
// //           final data = doc.data();
// //           final dataCompanyId = data['companyId'] as String?;

// //           // إذا الشركة ليس لها رحلات في dailyWork
// //           if (!dailyWorkTripCounts.containsKey(dataCompanyId ?? '')) {
// //             debugPrint(
// //               '⚠️ الشركة ${data['companyName']} ليس لها رحلات في dailyWork',
// //             );
// //           }
// //         }
// //       }

// //       if (updatedCount > 0) {
// //         await batch.commit();
// //         debugPrint('✅ تم تحديث $updatedCount حساب شركة تلقائياً');
// //         _showSuccess('تم تحديث حسابات $updatedCount شركة تلقائياً');
// //       } else {
// //         debugPrint('✅ جميع الحسابات محدثة بالفعل');
// //       }
// //     } catch (e) {
// //       debugPrint('❌ خطأ في التحديث التلقائي: $e');
// //       _showError('خطأ في تحديث الحسابات: $e');
// //     }
// //   }

// //   // ================================
// //   // تحميل بيانات الشركات مع الإحصائيات
// //   // ================================
// //   Future<void> _loadCompanies() async {
// //     if (mounted) {
// //       setState(() => _isLoading = true);
// //     }
// //     try {
// //       final companiesSnapshot = await _firestore.collection('companies').get();
// //       final dailyWorkSnapshot = await _firestore.collection('dailyWork').get();

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

// //         // حساب الرحلات والإحصائيات
// //         final companyTrips = dailyWorkSnapshot.docs
// //             .where((doc) {
// //               final data = doc.data();
// //               final tripCompanyId = data['companyId'] ?? '';
// //               return tripCompanyId == companyId;
// //             })
// //             .map((doc) {
// //               final data = doc.data();
// //               final tripDate = (data['date'] as Timestamp?)?.toDate();

// //               return {
// //                 'id': doc.id,
// //                 'date': tripDate,
// //                 'nolon': (data['noLon'] ?? data['nolon'] ?? 0).toDouble(),
// //                 'companyOvernight': (data['companyOvernight'] ?? 0).toDouble(),
// //                 'companyHoliday': (data['companyHoliday'] ?? 0).toDouble(),
// //               };
// //             })
// //             .toList();

// //         // حساب الإجماليات
// //         double totalNolon = 0.0;
// //         double totalOvernight = 0.0;
// //         double totalHoliday = 0.0;

// //         for (var trip in companyTrips) {
// //           totalNolon += trip['nolon'];
// //           totalOvernight += trip['companyOvernight'];
// //           totalHoliday += trip['companyHoliday'];
// //         }

// //         companiesList.add({
// //           'companyId': companyId,
// //           'companyName': companyName,
// //           'companyData': companyData,
// //           'totalTrips': companyTrips.length,
// //           'totalNolon': totalNolon,
// //           'totalOvernight': totalOvernight,
// //           'totalHoliday': totalHoliday,
// //         });
// //       }

// //       companiesList.sort(
// //         (a, b) => a['companyName'].compareTo(b['companyName']),
// //       );

// //       if (mounted) {
// //         setState(() {
// //           _allCompanies = companiesList;
// //           _filteredCompanies = _applySearchFilter(companiesList);
// //           _isLoading = false;
// //         });
// //       }

// //       // تحديث تلقائي عند دخول الصفحة الرئيسية فقط
// //       if (!_hasSyncedOnEnter && _selectedCompany == null) {
// //         await _syncDataOnPageEnter();
// //         _hasSyncedOnEnter = true;
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         setState(() => _isLoading = false);
// //       }
// //       debugPrint('خطأ في تحميل بيانات الشركات: $e');
// //       _showError('خطأ في تحميل الشركات: $e');
// //     }
// //   }

// //   // ================================
// //   // تحميل بيانات الشركة المختارة
// //   // ================================
// //   Future<void> _loadCompanyData(String companyName, String companyId) async {
// //     if (mounted) {
// //       setState(() {
// //         _selectedCompany = companyName;
// //         _selectedCompanyId = companyId;
// //         _isLoading = true;
// //         _companyWork.clear();
// //         _availableTripsForInvoice.clear();
// //         _companyInvoices.clear();
// //         _selectedTripsForInvoice.clear();
// //         _invoiceNameController.clear();
// //         _invoiceNotesController.clear();
// //       });
// //     }

// //     try {
// //       // 1. تحميل جميع رحلات الشركة من dailyWork
// //       final workSnapshot = await _firestore
// //           .collection('dailyWork')
// //           .where('companyId', isEqualTo: companyId)
// //           .orderBy('date', descending: false) // الأقدم أولاً
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
// //           'karta': data['karta'] ?? '', // تخزين الكارتة
// //           'ohda': data['ohda'] ?? '',
// //           'selectedRoute': data['selectedRoute'] ?? '',
// //           'selectedRoute2': data['unloadingLocation'] ?? '',
// //           'loadingLocation': data['loadingLocation'] ?? '',
// //           'unloadingLocation': data['unloadingLocation'] ?? '',
// //           'vehicleType': data['selectedVehicleType'] ?? '',
// //           'notes': data['selectedNotes'] ?? '',
// //           'tr': data['tr'] ?? '',
// //           'companyLocationName': data['companyLocationName'] ?? '',
// //           'hasInvoice': false,
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
// //         double totalKartaValue = 0;

// //         for (var tripId in tripIds) {
// //           final tripDoc = await _firestore
// //               .collection('dailyWork')
// //               .doc(tripId.toString())
// //               .get();
// //           if (tripDoc.exists) {
// //             final tripData = tripDoc.data() as Map<String, dynamic>;
// //             final karta = tripData['karta']?.toString() ?? '';
// //             double kartaValue = 0;

// //             try {
// //               final cleanedKarta = karta.trim();
// //               if (cleanedKarta.isNotEmpty) {
// //                 kartaValue = double.tryParse(cleanedKarta) ?? 0;
// //               }
// //             } catch (e) {
// //               debugPrint('خطأ في تحويل الكارتة إلى رقم: $karta');
// //             }

// //             totalKartaValue += kartaValue;

// //             invoiceTrips.add({
// //               'selectedRoute': tripData['loadingLocation'] ?? '',
// //               'selectedRoute2': tripData['unloadingLocation'] ?? '',
// //               'vehicleType': tripData['selectedVehicleType'] ?? '',
// //               'nolon': (tripData['noLon'] ?? tripData['nolon'] ?? 0).toDouble(),
// //               'companyOvernight': (tripData['companyOvernight'] ?? 0)
// //                   .toDouble(),
// //               'companyHoliday': (tripData['companyHoliday'] ?? 0).toDouble(),
// //               'tr': tripData['tr'] ?? '',
// //               'companyLocationName': tripData['companyLocationName'] ?? '',
// //               'date': (tripData['date'] as Timestamp?)?.toDate(),
// //               'karta': karta,
// //               'kartaValue': kartaValue,
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
// //           'companyId': data['companyId'] ?? companyId,
// //           'totalAmount': (data['totalAmount'] ?? 0).toDouble(),
// //           'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
// //           'tripIds': tripIds,
// //           'tripCount': tripIds.length,
// //           'invoiceTrips': invoiceTrips,
// //           'nolonTotal': totalNolon,
// //           'overnightTotal': totalOvernight,
// //           'holidayTotal': totalHoliday,
// //           'kartaDetails': invoiceTrips.map((trip) => trip['karta']).toList(),
// //           'kartaValue': totalKartaValue,
// //           'notes': data['notes'] ?? '', // ملاحظات الفاتورة
// //           'month': data['month'] ?? 'غير محدد', // شهر الإدراج
// //           'isCollected': data['isCollected'] ?? false, // حالة التحصيل
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

// //       // ترتيب الرحلات المتاحة للفاتورة: الأقدم أولاً، ثم تجميع الـ TR المتشابه
// //       final sortedAvailableTrips = _sortAndGroupTripsForInvoice(availableTrips);

// //       if (mounted) {
// //         setState(() {
// //           _companyWork = allTrips;
// //           _availableTripsForInvoice = sortedAvailableTrips;
// //           _companyInvoices = invoicesList;
// //           _isLoading = false;
// //         });
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         setState(() => _isLoading = false);
// //       }
// //       _showError('خطأ في تحميل بيانات الشركة: $e');
// //     }
// //   }

// //   // ================================
// //   // الحصول على حالة نظام TR للشركة
// //   // ================================
// //   Future<bool> _getCompanyTRStatus(String companyId) async {
// //     try {
// //       final companyDoc = await _firestore
// //           .collection('companies')
// //           .doc(companyId)
// //           .get();
// //       if (companyDoc.exists) {
// //         final data = companyDoc.data() as Map<String, dynamic>;
// //         x = data['commercialRegister'];
// //         xx = data['taxCard'];

// //         return data['usesTRSystem'] ?? false;
// //       }
// //       return false;
// //     } catch (e) {
// //       debugPrint('خطأ في جلب حالة TR: $e');
// //       return false;
// //     }
// //   }

// //   // ================================
// //   // ترتيب وتجميع الرحلات للفاتورة
// //   // ================================
// //   List<Map<String, dynamic>> _sortAndGroupTripsForInvoice(
// //     List<Map<String, dynamic>> trips,
// //   ) {
// //     if (trips.isEmpty) return [];

// //     // 1. ترتيب الرحلات حسب التاريخ (الأقدم أولاً)
// //     trips.sort((a, b) {
// //       final dateA = a['date'] as DateTime? ?? DateTime(1900);
// //       final dateB = b['date'] as DateTime? ?? DateTime(1900);
// //       return dateA.compareTo(dateB);
// //     });

// //     // 2. تجميع الرحلات حسب التاريخ والـ TR
// //     final Map<String, List<Map<String, dynamic>>> groupedTrips = {};

// //     for (var trip in trips) {
// //       final date = trip['date'] as DateTime?;
// //       final tr = trip['tr']?.toString() ?? '';
// //       final dateKey = date != null
// //           ? DateFormat('yyyy-MM-dd').format(date)
// //           : 'unknown_date';

// //       // المفتاح: التاريخ + الـ TR
// //       final key = '$dateKey|$tr';

// //       if (!groupedTrips.containsKey(key)) {
// //         groupedTrips[key] = [];
// //       }
// //       groupedTrips[key]!.add(trip);
// //     }

// //     // 3. تحويل المجموعات إلى قائمة مرتبة
// //     final List<Map<String, dynamic>> result = [];

// //     // الحصول على المفاتيح وترتيبها حسب التاريخ
// //     final sortedKeys = groupedTrips.keys.toList()
// //       ..sort((a, b) {
// //         // استخراج التاريخ من المفتاح
// //         final datePartA = a.split('|')[0];
// //         final datePartB = b.split('|')[0];
// //         return datePartA.compareTo(datePartB);
// //       });

// //     // إضافة الرحلات المجمعة
// //     for (var key in sortedKeys) {
// //       final tripsInGroup = groupedTrips[key]!;

// //       // ترتيب الرحلات داخل المجموعة حسب الوقت إذا كان موجوداً
// //       tripsInGroup.sort((a, b) {
// //         final timeA = (a['date'] as DateTime?)?.toIso8601String() ?? '';
// //         final timeB = (b['date'] as DateTime?)?.toIso8601String() ?? '';
// //         return timeA.compareTo(timeB);
// //       });

// //       result.addAll(tripsInGroup);
// //     }

// //     return result;
// //   }

// //   // ================================
// //   // فلترة الفواتير حسب الشهر وحالة التحصيل
// //   // ================================
// //   List<Map<String, dynamic>> _filterInvoices() {
// //     List<Map<String, dynamic>> filtered = _companyInvoices;

// //     // فلترة حسب الشهر
// //     if (_selectedMonthFilter != 'كل الشهور') {
// //       filtered = filtered.where((invoice) {
// //         final month = invoice['month'] ?? 'غير محدد';
// //         return month == _selectedMonthFilter;
// //       }).toList();
// //     }

// //     // فلترة حسب حالة التحصيل
// //     final List<Map<String, dynamic>> result = [];

// //     if (_showNotCollected) {
// //       result.addAll(
// //         filtered.where((invoice) => !(invoice['isCollected'] ?? false)),
// //       );
// //     }

// //     if (_showCollected) {
// //       result.addAll(
// //         filtered.where((invoice) => invoice['isCollected'] ?? false),
// //       );
// //     }

// //     return result;
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
// //     if (!mounted) return;
// //     setState(() {
// //       if (selected) {
// //         _selectedTripsForInvoice.add(trip);
// //       } else {
// //         _selectedTripsForInvoice.removeWhere((t) => t['id'] == trip['id']);
// //       }
// //     });
// //   }

// //   void _selectAllTrips(bool select) {
// //     if (!mounted) return;
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

// //     if (mounted) {
// //       setState(() => _isCreatingInvoice = true);
// //     }

// //     try {
// //       // حساب إجمالي المبالغ
// //       double totalNolon = 0;
// //       double totalOvernight = 0;
// //       double totalHoliday = 0;
// //       double totalKartaValue = 0;
// //       List<String> tripIds = [];
// //       List<Map<String, dynamic>> invoiceTripDetails = [];

// //       for (var trip in _selectedTripsForInvoice) {
// //         totalNolon += trip['nolon'];
// //         totalOvernight += trip['companyOvernight'];
// //         totalHoliday += trip['companyHoliday'];
// //         tripIds.add(trip['id']);

// //         // حساب قيمة الكارتة
// //         final karta = trip['karta']?.toString() ?? '';
// //         double kartaValue = 0;
// //         try {
// //           final cleanedKarta = karta.trim();
// //           if (cleanedKarta.isNotEmpty) {
// //             kartaValue = double.tryParse(cleanedKarta) ?? 0;
// //           }
// //         } catch (e) {
// //           debugPrint('خطأ في تحويل الكارتة إلى رقم: $karta');
// //         }
// //         totalKartaValue += kartaValue;

// //         // تخزين تفاصيل الرحلة بما فيها الكارتة
// //         invoiceTripDetails.add({
// //           'selectedRoute': trip['selectedRoute'],
// //           'selectedRoute2': trip['selectedRoute2'],
// //           'vehicleType': trip['vehicleType'],
// //           'nolon': trip['nolon'],
// //           'companyOvernight': trip['companyOvernight'],
// //           'companyHoliday': trip['companyHoliday'],
// //           'tr': trip['tr'],
// //           'companyLocationName': trip['companyLocationName'],
// //           'date': trip['date'],
// //           'karta': karta,
// //           'kartaValue': kartaValue,
// //         });
// //       }

// //       double totalAmount = totalNolon + totalOvernight + totalHoliday;

// //       // حفظ الفاتورة مع الكارتات
// //       await _firestore.collection('invoices').add({
// //         'name': _invoiceNameController.text.trim(),
// //         'companyName': _selectedCompany!,
// //         'companyId': _selectedCompanyId!,
// //         'totalAmount': totalAmount,
// //         'nolonTotal': totalNolon,
// //         'overnightTotal': totalOvernight,
// //         'holidayTotal': totalHoliday,
// //         'kartaValue': totalKartaValue,
// //         'totalWithKarta': totalAmount + totalKartaValue,
// //         'tripIds': tripIds,
// //         'tripDetails': invoiceTripDetails,
// //         'tripCount': tripIds.length,
// //         'kartaDetails': _selectedTripsForInvoice
// //             .map((trip) => trip['karta'] ?? '')
// //             .toList(),
// //         'notes': _invoiceNotesController.text.trim(), // ملاحظات الفاتورة
// //         'month': _selectedMonth, // شهر الإدراج
// //         'isCollected': false, // حالة التحصيل (افتراضيًا غير محصلة)
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

// //       // تحديث حساب الشركة في companySummaries
// //       await _updateCompanySummaryAfterInvoice(totalAmount);

// //       _showSuccess('تم إنشاء الفاتورة بنجاح');

// //       // إعادة تحميل بيانات الشركة
// //       await _loadCompanyData(_selectedCompany!, _selectedCompanyId!);

// //       // تنظيف المتغيرات
// //       if (mounted) {
// //         setState(() {
// //           _selectedTripsForInvoice.clear();
// //           _invoiceNameController.clear();
// //           _invoiceNotesController.clear();
// //         });
// //       }

// //       // الذهاب إلى قسم الفواتير
// //       _changeSection(2);
// //     } catch (e) {
// //       _showError('خطأ في إنشاء الفاتورة: $e');
// //     } finally {
// //       if (mounted) {
// //         setState(() => _isCreatingInvoice = false);
// //       }
// //     }
// //   }

// //   // ================================
// //   // تحديث حالة تحصيل الفاتورة
// //   // ================================
// //   Future<void> _toggleInvoiceCollection(
// //     String invoiceId,
// //     bool isCollected,
// //   ) async {
// //     try {
// //       await _firestore.collection('invoices').doc(invoiceId).update({
// //         'isCollected': isCollected,
// //         'collectedAt': isCollected ? Timestamp.now() : null,
// //       });

// //       // إعادة تحميل بيانات الشركة
// //       await _loadCompanyData(_selectedCompany!, _selectedCompanyId!);

// //       _showSuccess(
// //         isCollected ? 'تم تحديد الفاتورة كمحصلة' : 'تم إلغاء تحصيل الفاتورة',
// //       );
// //     } catch (e) {
// //       _showError('خطأ في تحديث حالة الفاتورة: $e');
// //     }
// //   }

// //   // ================================
// //   // طباعة جميع فواتير الشهر
// //   // ================================
// //   Future<void> _printMonthInvoices(bool collected) async {
// //     if (_arabicFont == null) {
// //       await _loadArabicFont();
// //     }

// //     if (mounted) {
// //       setState(() => _isGeneratingPDF = true);
// //     }

// //     try {
// //       // فلترة الفواتير حسب الشهر وحالة التحصيل
// //       final filteredInvoices = _companyInvoices.where((invoice) {
// //         final month = invoice['month'] ?? 'غير محدد';
// //         final isInvoiceCollected = invoice['isCollected'] ?? false;
// //         final monthMatch =
// //             _selectedMonthFilter == 'كل الشهور' ||
// //             month == _selectedMonthFilter;
// //         return monthMatch && isInvoiceCollected == collected;
// //       }).toList();

// //       if (filteredInvoices.isEmpty) {
// //         _showError(
// //           'لا توجد فواتير ${collected ? 'محصلة' : 'غير محصلة'} للشهر المحدد',
// //         );
// //         return;
// //       }

// //       final pdf = pdfLib.Document(
// //         theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
// //       );

// //       pdf.addPage(
// //         pdfLib.MultiPage(
// //           pageFormat: pdfLib.PdfPageFormat.a4,
// //           margin: const pdfLib.EdgeInsets.only(right: 60, left: 60),
// //           build: (context) => [
// //             pdfLib.Directionality(
// //               textDirection: pdfLib.TextDirection.rtl,
// //               child: pdfLib.Column(
// //                 crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
// //                 children: [
// //                   // عنوان التقرير
// //                   pdfLib.Container(
// //                     alignment: pdfLib.Alignment.center,
// //                     child: pdfLib.Column(
// //                       children: [
// //                         pdfLib.Text(
// //                           'تقرير فواتير شهر ${_selectedMonthFilter}',
// //                           style: pdfLib.TextStyle(
// //                             font: _arabicFont,
// //                             fontSize: 18,
// //                             fontWeight: pdfLib.FontWeight.bold,
// //                           ),
// //                         ),
// //                         pdfLib.Text(
// //                           '(${collected ? 'المحصلة' : 'غير المحصلة'})',
// //                           style: pdfLib.TextStyle(
// //                             font: _arabicFont,
// //                             fontSize: 16,
// //                           ),
// //                         ),
// //                         pdfLib.Text(
// //                           'شركة: $_selectedCompany',
// //                           style: pdfLib.TextStyle(
// //                             font: _arabicFont,
// //                             fontSize: 14,
// //                           ),
// //                         ),
// //                         pdfLib.Text(
// //                           'تاريخ الطباعة: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
// //                           style: pdfLib.TextStyle(
// //                             font: _arabicFont,
// //                             fontSize: 12,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),

// //                   pdfLib.SizedBox(height: 20),

// //                   // جدول الفواتير
// //                   _monthInvoicesTable(filteredInvoices),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       );

// //       await Printing.layoutPdf(
// //         name:
// //             'فواتير شهر ${_selectedMonthFilter} - ${collected ? 'محصلة' : 'غير محصلة'}',
// //         onLayout: (_) async => pdf.save(),
// //       );

// //       _showSuccess('تم طباعة ${filteredInvoices.length} فاتورة بنجاح');
// //     } catch (e) {
// //       _showError('خطأ في طباعة الفواتير: $e');
// //     } finally {
// //       if (mounted) {
// //         setState(() => _isGeneratingPDF = false);
// //       }
// //     }
// //   }

// //   // ================================
// //   // جدول فواتير الشهر
// //   // ================================
// //   pdfLib.Widget _monthInvoicesTable(List<Map<String, dynamic>> invoices) {
// //     return pdfLib.Table(
// //       border: pdfLib.TableBorder.all(color: pdfLib.PdfColors.black, width: 1),
// //       columnWidths: const {
// //         0: pdfLib.FlexColumnWidth(1), // م
// //         1: pdfLib.FlexColumnWidth(2), // تاريخ التقديم
// //         2: pdfLib.FlexColumnWidth(3), // اسم الفاتورة
// //         3: pdfLib.FlexColumnWidth(2), // قيمة الفاتورة
// //         4: pdfLib.FlexColumnWidth(2), // قيمة الكارتة
// //         5: pdfLib.FlexColumnWidth(2), // الإجمالي
// //         6: pdfLib.FlexColumnWidth(3), // الموقع
// //         7: pdfLib.FlexColumnWidth(4), // الملاحظات
// //       },
// //       children: [
// //         // رأس الجدول
// //         pdfLib.TableRow(
// //           decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
// //           children: [
// //             _monthTableCell('الملاحظات', isHeader: true),
// //             _monthTableCell('الموقع', isHeader: true),
// //             _monthTableCell('الإجمالي', isHeader: true),
// //             _monthTableCell('قيمة الكارتة', isHeader: true),
// //             _monthTableCell('قيمة الفاتورة', isHeader: true),
// //             _monthTableCell('اسم الفاتورة', isHeader: true),
// //             _monthTableCell('تاريخ التقديم', isHeader: true),
// //             _monthTableCell('م', isHeader: true),
// //           ],
// //         ),

// //         // صفوف البيانات
// //         ...invoices.asMap().entries.map((entry) {
// //           final index = entry.key;
// //           final invoice = entry.value;
// //           final createdAt = invoice['createdAt'] as DateTime?;
// //           final location = _getCompanyLocationName(
// //             invoice['invoiceTrips'] ?? [],
// //           );
// //           final totalAmount = invoice['totalAmount'] ?? 0;
// //           final kartaValue = invoice['kartaValue'] ?? 0;
// //           final totalWithKarta = totalAmount + kartaValue;
// //           final notes = invoice['notes'] ?? '';

// //           return pdfLib.TableRow(
// //             children: [
// //               _monthTableCell(notes),
// //               _monthTableCell(location),
// //               _monthTableCell(_formatCurrencyForPDF(totalWithKarta)),
// //               _monthTableCell(_formatCurrencyForPDF(kartaValue)),
// //               _monthTableCell(_formatCurrencyForPDF(totalAmount)),
// //               _monthTableCell(invoice['name']),
// //               _monthTableCell(
// //                 createdAt != null
// //                     ? DateFormat('dd/MM/yyyy').format(createdAt)
// //                     : '-',
// //               ),
// //               _monthTableCell('${index + 1}'),
// //             ],
// //           );
// //         }),
// //       ],
// //     );
// //   }

// //   // ================================
// //   // خلية جدول فواتير الشهر
// //   // ================================
// //   pdfLib.Widget _monthTableCell(String text, {bool isHeader = false}) {
// //     return pdfLib.Container(
// //       padding: const pdfLib.EdgeInsets.all(6),
// //       child: pdfLib.Text(
// //         text,
// //         textAlign: pdfLib.TextAlign.center,
// //         style: pdfLib.TextStyle(
// //           font: _arabicFont,
// //           fontSize: isHeader ? 10 : 9,
// //           fontWeight: isHeader
// //               ? pdfLib.FontWeight.bold
// //               : pdfLib.FontWeight.normal,
// //         ),
// //       ),
// //     );
// //   }

// //   // ================================
// //   // تحديث حساب الشركة بعد إنشاء الفاتورة
// //   // ================================
// //   Future<void> _updateCompanySummaryAfterInvoice(double invoiceAmount) async {
// //     try {
// //       final summaryRef = _firestore
// //           .collection('companySummaries')
// //           .doc(_selectedCompanyId!);

// //       final summaryDoc = await summaryRef.get();

// //       if (summaryDoc.exists) {
// //         final data = summaryDoc.data() as Map<String, dynamic>;
// //         final currentTotalPaid = (data['totalPaidAmount'] ?? 0).toDouble();
// //         final newTotalPaid = currentTotalPaid + invoiceAmount;
// //         final totalDebt = (data['totalCompanyDebt'] ?? 0).toDouble();
// //         final totalRemaining = totalDebt - newTotalPaid;

// //         String status;
// //         if (totalRemaining <= 0) {
// //           status = 'منتهية';
// //         } else if (newTotalPaid > 0) {
// //           status = 'شبه منتهية';
// //         } else {
// //           status = 'جارية';
// //         }

// //         await summaryRef.update({
// //           'totalPaidAmount': newTotalPaid,
// //           'totalRemainingAmount': totalRemaining,
// //           'status': status,
// //           'lastUpdated': Timestamp.now(),
// //         });

// //         debugPrint('✅ تم تحديث حساب الشركة بعد إنشاء الفاتورة');
// //       }
// //     } catch (e) {
// //       debugPrint('⚠️ خطأ في تحديث حساب الشركة بعد الفاتورة: $e');
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

// //   String _formatCurrencyForPDF(double amount) {
// //     return amount.toStringAsFixed(2);
// //   }

// //   void _changeSection(int section) {
// //     if (!mounted) return;
// //     setState(() {
// //       _currentSection = section;
// //       if (section == 1) {
// //         _selectedTripsForInvoice.clear();
// //         _invoiceNameController.clear();
// //         _invoiceNotesController.clear();
// //       }
// //     });
// //   }

// //   void _backToCompanies() {
// //     if (!mounted) return;
// //     setState(() {
// //       _selectedCompany = null;
// //       _selectedCompanyId = null;
// //       _companyWork.clear();
// //       _availableTripsForInvoice.clear();
// //       _companyInvoices.clear();
// //       _selectedTripsForInvoice.clear();
// //       _invoiceNameController.clear();
// //       _invoiceNotesController.clear();
// //       _hasSyncedOnEnter = false;
// //     });
// //     _loadCompanies();
// //   }

// //   Future<void> _printKartaRequest(Map<String, dynamic> invoice) async {
// //     if (_arabicFont == null) {
// //       await _loadArabicFont();
// //     }

// //     if (mounted) {
// //       setState(() => _isGeneratingPDF = true);
// //     }

// //     try {
// //       final trips =
// //           invoice['invoiceTrips'] as List<Map<String, dynamic>>? ?? [];
// //       final invoiceName = invoice['name'] ?? '';
// //       final companyName = invoice['companyName'] ?? 'غير معروف';
// //       final createdAt = invoice['createdAt'] as DateTime?;

// //       // استخراج الشهر من تاريخ الفاتورة
// //       String monthYear = 'غير محدد';
// //       if (createdAt != null) {
// //         monthYear = '${createdAt.month}/${createdAt.year}';
// //       }

// //       // الحصول على الموقع الفعلي (companyLocationName) من الرحلات
// //       String companyLocation = '';
// //       for (var trip in trips) {
// //         final location = trip['companyLocationName']?.toString() ?? '';
// //         if (location.isNotEmpty) {
// //           companyLocation = location;
// //           break;
// //         }
// //       }

// //       // إذا لم يوجد موقع، استخدم 'الموقع' كقيمة افتراضية
// //       if (companyLocation.isEmpty) {
// //         companyLocation = 'الموقع';
// //       }

// //       // ترتيب الرحلات حسب التاريخ
// //       final List<Map<String, dynamic>> sortedTrips = List.from(trips)
// //         ..sort((a, b) {
// //           final dateA = a['date'] as DateTime? ?? DateTime(1900);
// //           final dateB = b['date'] as DateTime? ?? DateTime(1900);
// //           return dateA.compareTo(dateB);
// //         });

// //       // إنشاء صفوف الجدول - كل رحلة في سطر منفصل
// //       final List<Map<String, dynamic>> tableRows = [];
// //       double totalKartasValue = 0;
// //       int rowNumber = 1;

// //       for (var trip in sortedTrips) {
// //         final date = trip['date'] as DateTime?;
// //         final karta = trip['karta']?.toString() ?? '';
// //         final ohda = trip['ohda']?.toString() ?? '';

// //         // حساب قيمة الكارتة إذا كانت رقماً
// //         double kartaValue = 0;
// //         try {
// //           final cleanedKarta = karta.trim();
// //           if (cleanedKarta.isNotEmpty) {
// //             kartaValue = double.tryParse(cleanedKarta) ?? 0;
// //           }
// //         } catch (e) {
// //           debugPrint('خطأ في تحويل الكارتة إلى رقم: $karta');
// //         }

// //         // جمع القيمة الإجمالية
// //         totalKartasValue += kartaValue;

// //         // تنسيق التاريخ (يوم/شهر فقط)
// //         String formattedDate = '-';
// //         if (date != null) {
// //           formattedDate = '${date.day}/${date.month}';
// //         }
// //         if (kartaValue != 0) {
// //           tableRows.add({
// //             'rowNumber': rowNumber.toString(),
// //             'date': formattedDate,
// //             'karta': karta,
// //             'ohda': ohda,
// //             'kartaValue': kartaValue,
// //           });

// //           rowNumber++;
// //         }
// //       }

// //       final pdf = pdfLib.Document(
// //         theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
// //       );
// //       pdf.addPage(
// //         pdfLib.MultiPage(
// //           pageFormat: pdfLib.PdfPageFormat.a4,
// //           margin: const pdfLib.EdgeInsets.only(right: 60, left: 60),
// //           build: (context) => [
// //             pdfLib.Directionality(
// //               textDirection: pdfLib.TextDirection.rtl,
// //               child: pdfLib.Column(
// //                 crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
// //                 children: [
// //                   _kartaRequestHeader(
// //                     invoiceName,
// //                     monthYear,
// //                     companyName,
// //                     companyLocation,
// //                   ),
// //                   pdfLib.SizedBox(height: 20),
// //                   _kartaRequestTable(tableRows, totalKartasValue),
// //                   pdfLib.SizedBox(height: 20),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       );

// //       await Printing.layoutPdf(
// //         name: 'مطالبة كارتات - $invoiceName',
// //         onLayout: (_) async => pdf.save(),
// //       );

// //       _showSuccess('تم طباعة مطالبة الكارتات بنجاح');
// //     } catch (e) {
// //       _showError('خطأ في طباعة مطالبة الكارتات: $e');
// //     } finally {
// //       if (mounted) {
// //         setState(() => _isGeneratingPDF = false);
// //       }
// //     }
// //   }

// //   // ================================
// //   // ترويسة مطالبة الكارتات
// //   // ================================
// //   pdfLib.Widget _kartaRequestHeader(
// //     String invoiceName,
// //     String monthYear,
// //     String companyName,
// //     String location,
// //   ) {
// //     return pdfLib.Column(
// //       crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
// //       children: [
// //         pdfLib.Text(
// //           'فاتورة رقم ( $invoiceName )',
// //           style: pdfLib.TextStyle(
// //             font: _arabicFont,
// //             fontSize: 18,
// //             fontWeight: pdfLib.FontWeight.bold,
// //           ),
// //           textAlign: pdfLib.TextAlign.center,
// //         ),
// //         pdfLib.SizedBox(height: 10),
// //         pdfLib.Text(
// //           'مطالبة كارتات فاتورة شهر $monthYear م',
// //           style: pdfLib.TextStyle(
// //             font: _arabicFont,
// //             fontSize: 16,
// //             fontWeight: pdfLib.FontWeight.bold,
// //           ),
// //           textAlign: pdfLib.TextAlign.center,
// //         ),
// //         pdfLib.SizedBox(height: 10),
// //         pdfLib.Text(
// //           'عن موقع ( $location )( $companyName)',
// //           style: pdfLib.TextStyle(font: _arabicFont, fontSize: 14),
// //           textAlign: pdfLib.TextAlign.center,
// //         ),
// //         pdfLib.SizedBox(height: 20),
// //       ],
// //     );
// //   }

// //   // ================================
// //   // جدول مطالبة الكارتات كما في الصورة
// //   // ================================
// //   pdfLib.Widget _kartaRequestTable(
// //     List<Map<String, dynamic>> rows,
// //     double totalKartasValue,
// //   ) {
// //     return pdfLib.Table(
// //       border: pdfLib.TableBorder.all(color: pdfLib.PdfColors.black, width: 1),
// //       columnWidths: const {
// //         0: pdfLib.FlexColumnWidth(1.5), // المسلسل
// //         1: pdfLib.FlexColumnWidth(1), // التاريخ
// //         2: pdfLib.FlexColumnWidth(1), // القيمة (الكارتة)
// //       },
// //       children: [
// //         // رأس الجدول كما في الصورة
// //         pdfLib.TableRow(
// //           decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
// //           children: [
// //             _kartaTableCell('القيمة', isHeader: true),
// //             _kartaTableCell('التاريخ', isHeader: true),
// //             _kartaTableCell('المسلسل', isHeader: true),
// //           ],
// //         ),

// //         // صفوف البيانات - كل رحلة في سطر منفصل
// //         ...rows.map(
// //           (row) => pdfLib.TableRow(
// //             children: [
// //               _kartaTableCell(row['karta']?.toString() ?? ''),
// //               _kartaTableCell(row['date']),
// //               _kartaTableCell(row['rowNumber']),
// //             ],
// //           ),
// //         ),

// //         // الصف الأخير الإجمالي كما في الصورة
// //         pdfLib.TableRow(
// //           children: [
// //             _kartaTableCell(
// //               _formatCurrencyForPDF(totalKartasValue),
// //               isTotal: true,
// //             ),
// //             _kartaTableCell('--', isTotal: true),
// //             _kartaTableCell('الإجمالي', isTotal: true),
// //           ],
// //         ),
// //       ],
// //     );
// //   }

// //   // ================================
// //   // خلية جدول مطالبة الكارتات
// //   // ================================
// //   pdfLib.Widget _kartaTableCell(
// //     String text, {
// //     bool isHeader = false,
// //     bool isTotal = false,
// //   }) {
// //     return pdfLib.Container(
// //       padding: const pdfLib.EdgeInsets.all(8),
// //       child: pdfLib.Text(
// //         text,
// //         textAlign: pdfLib.TextAlign.center,
// //         style: pdfLib.TextStyle(
// //           font: _arabicFont,
// //           fontSize: isTotal ? 12 : 10,
// //           fontWeight: isHeader || isTotal
// //               ? pdfLib.FontWeight.bold
// //               : pdfLib.FontWeight.normal,
// //         ),
// //       ),
// //     );
// //   }

// //   // ================================
// //   // دوال الطباعة
// //   // ================================
// //   Future<void> _printInvoice(Map<String, dynamic> invoice) async {
// //     if (_arabicFont == null) {
// //       await _loadArabicFont();
// //     }

// //     if (mounted) {
// //       setState(() => _isGeneratingPDF = true);
// //     }

// //     try {
// //       final trips =
// //           invoice['invoiceTrips'] as List<Map<String, dynamic>>? ?? [];
// //       final invoiceId = invoice['id']?.toString() ?? '623';
// //       final createdAt = invoice['createdAt'] as DateTime?;
// //       final companyName = invoice['companyName'] ?? ' ';
// //       final name = invoice['name'] ?? '';
// //       final companyId = invoice['companyId'] ?? _selectedCompanyId;
// //       final notes = invoice['notes'] ?? '';
// //       final month = invoice['month'] ?? 'غير محدد';
// //       final kartaValue = invoice['kartaValue'] ?? 0;
// //       final totalWithKarta =
// //           invoice['totalWithKarta'] ?? invoice['totalAmount'] ?? 0;

// //       // التحقق إذا كانت الشركة تعمل بنظام TR
// //       final bool usesTRSystem = companyId != null
// //           ? await _getCompanyTRStatus(companyId)
// //           : false;

// //       final groupedTrips = _groupTripsForInvoice(trips);
// //       final location = _getCompanyLocationName(trips);

// //       final total = groupedTrips.fold<double>(0.0, (sum, e) {
// //         final value = e['total'];
// //         if (value is num) {
// //           return sum + value.toDouble();
// //         }
// //         return sum;
// //       });

// //       final tax = total * 0.14;
// //       final afterTax = total + tax;

// //       final pdf = pdfLib.Document(
// //         theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
// //       );

// //       pdf.addPage(
// //         pdfLib.MultiPage(
// //           pageFormat: pdfLib.PdfPageFormat.a4,
// //           margin: const pdfLib.EdgeInsets.only(right: 60, left: 60),
// //           build: (context) => [
// //             pdfLib.Directionality(
// //               textDirection: pdfLib.TextDirection.rtl,
// //               child: pdfLib.Column(
// //                 crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
// //                 children: [
// //                   _invoiceHeader(
// //                     invoiceId,
// //                     createdAt,
// //                     companyName,
// //                     location,
// //                     name,
// //                     month,
// //                     notes,
// //                   ),
// //                   pdfLib.SizedBox(height: 10),
// //                   _invoiceTable(groupedTrips, usesTRSystem),
// //                   pdfLib.SizedBox(height: 10),
// //                   _totalsSection(
// //                     total,
// //                     tax,
// //                     afterTax,
// //                     kartaValue,
// //                     totalWithKarta,
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       );

// //       await Printing.layoutPdf(
// //         name: '$name',
// //         onLayout: (_) async => pdf.save(),
// //       );

// //       _showSuccess('تم طباعة الفاتورة بنجاح');
// //     } catch (e) {
// //       _showError(e.toString());
// //     } finally {
// //       if (mounted) {
// //         setState(() => _isGeneratingPDF = false);
// //       }
// //     }
// //   }

// //   pdfLib.Widget _invoiceHeader(
// //     String invoiceId,
// //     DateTime? date,
// //     String company,
// //     String location,
// //     String name,
// //     String month,
// //     String notes,
// //   ) {
// //     return pdfLib.Column(
// //       children: [
// //         pdfLib.Row(
// //           mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
// //           crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
// //           children: [
// //             pdfLib.Column(
// //               crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
// //               children: [
// //                 pdfLib.Text('شركة نيوجراند لخدمات النقل'),
// //                 pdfLib.Text('السادة شركة : $company'),
// //                 pdfLib.Text('مذكور للمشروعات'),
// //                 pdfLib.Text('موقع : ${location.isNotEmpty ? location : '_ '}'),
// //                 if (notes.isNotEmpty) pdfLib.Text('ملاحظات: $notes'),
// //                 pdfLib.Text('شهر الإدراج: $month'),
// //               ],
// //             ),
// //             pdfLib.Column(
// //               children: [
// //                 pdfLib.Text(
// //                   '$name',
// //                   style: pdfLib.TextStyle(
// //                     font: _arabicFont,
// //                     fontSize: 18,
// //                     fontWeight: pdfLib.FontWeight.bold,
// //                     decoration: pdfLib.TextDecoration.underline,
// //                   ),
// //                 ),
// //                 pdfLib.Text(
// //                   date != null
// //                       ? DateFormat('d/M/yyyy').format(date)
// //                       : '1/2/2023',
// //                   style: pdfLib.TextStyle(font: _arabicFont, fontSize: 11),
// //                 ),
// //               ],
// //             ),
// //             // اللوجو الجديد
// //             _buildLogoWidget(),
// //           ],
// //         ),
// //         pdfLib.Divider(),
// //       ],
// //     );
// //   }

// //   // دالة منفصلة لبناء اللوجو
// //   pdfLib.Widget _buildLogoWidget() {
// //     if (_logoImageBytes != null) {
// //       return pdfLib.Column(
// //         children: [
// //           pdfLib.Container(
// //             width: 55,
// //             height: 55,
// //             child: pdfLib.Image(
// //               pdfLib.MemoryImage(_logoImageBytes!),
// //               fit: pdfLib.BoxFit.contain,
// //             ),
// //           ),
// //           pdfLib.SizedBox(height: 4),
// //           pdfLib.Text(
// //             'New grand',
// //             style: pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold),
// //           ),
// //         ],
// //       );
// //     } else {
// //       return pdfLib.Column(
// //         children: [
// //           pdfLib.Container(
// //             width: 55,
// //             height: 55,
// //             decoration: pdfLib.BoxDecoration(
// //               color: pdfLib.PdfColors.black,
// //               shape: pdfLib.BoxShape.circle,
// //             ),
// //           ),
// //           pdfLib.Text(
// //             'New grand',
// //             style: pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold),
// //           ),
// //         ],
// //       );
// //     }
// //   }

// //   pdfLib.Widget _invoiceTable(
// //     List<Map<String, dynamic>> rows,
// //     bool usesTRSystem,
// //   ) {
// //     // تحديد أعمدة الجدول بناءً على نظام TR
// //     if (usesTRSystem) {
// //       // جدول مع TR (6 أعمدة)
// //       return pdfLib.Table(
// //         border: pdfLib.TableBorder.all(
// //           color: pdfLib.PdfColors.black,
// //           width: 1.3,
// //         ),
// //         columnWidths: const {
// //           5: pdfLib.FlexColumnWidth(1.2), // القيمة الإجمالية
// //           4: pdfLib.FlexColumnWidth(1), // السعر
// //           3: pdfLib.FlexColumnWidth(3), // البيان
// //           2: pdfLib.FlexColumnWidth(1), // عدد/طن
// //           1: pdfLib.FlexColumnWidth(1), // TR Number
// //           0: pdfLib.FlexColumnWidth(1.2), // التاريخ
// //         },
// //         children: [
// //           pdfLib.TableRow(
// //             decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
// //             children: [
// //               _th('القيمة الإجمالية'),
// //               _th('السعر'),
// //               _th('عدد/طن'),
// //               _th('البيان'),
// //               _th('TR\nNumber'),
// //               _th('التاريخ'),
// //             ],
// //           ),
// //           ...rows.map(
// //             (e) => pdfLib.TableRow(
// //               children: [
// //                 _td(_format(e['total'])),
// //                 _td(_format(e['price'])),
// //                 _td(e['count'].toString()),
// //                 _td(e['description'], right: true),
// //                 _td(e['tr']),
// //                 _td(e['date']),
// //               ],
// //             ),
// //           ),
// //           ...List.generate(
// //             17 - rows.length > 0 ? 17 - rows.length : 0,
// //             (_) => pdfLib.TableRow(
// //               children: List.generate(6, (i) => _td(i == 5 ? '0' : '')),
// //             ),
// //           ),
// //         ],
// //       );
// //     } else {
// //       // جدول بدون TR (5 أعمدة)
// //       return pdfLib.Table(
// //         border: pdfLib.TableBorder.all(
// //           color: pdfLib.PdfColors.black,
// //           width: 1.3,
// //         ),
// //         columnWidths: const {
// //           4: pdfLib.FlexColumnWidth(1.2), // القيمة الإجمالية
// //           3: pdfLib.FlexColumnWidth(4), // السعر
// //           2: pdfLib.FlexColumnWidth(1), // البيان (أوسع بدون TR)
// //           1: pdfLib.FlexColumnWidth(1), // عدد/طن
// //           0: pdfLib.FlexColumnWidth(1.2), // التاريخ
// //         },
// //         children: [
// //           pdfLib.TableRow(
// //             decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
// //             children: [
// //               _th('القيمة الإجمالية'),
// //               _th('السعر'),
// //               _th('عدد/طن'),
// //               _th('البيان'),
// //               _th('التاريخ'),
// //             ],
// //           ),
// //           ...rows.map(
// //             (e) => pdfLib.TableRow(
// //               children: [
// //                 _td(_format(e['total'])),
// //                 _td(_format(e['price'])),
// //                 _td(e['count'].toString()),
// //                 _td(e['description'], right: true),
// //                 _td(e['date']),
// //               ],
// //             ),
// //           ),
// //           ...List.generate(
// //             17 - rows.length > 0 ? 17 - rows.length : 0,
// //             (_) => pdfLib.TableRow(
// //               children: List.generate(5, (i) => _td(i == 4 ? '0' : '')),
// //             ),
// //           ),
// //         ],
// //       );
// //     }
// //   }

// //   pdfLib.Widget _totalsSection(
// //     double total,
// //     double tax,
// //     double afterTax,
// //     double kartaValue,
// //     double totalWithKarta,
// //   ) {
// //     return pdfLib.Column(
// //       children: [
// //         pdfLib.Table(
// //           border: pdfLib.TableBorder.all(),
// //           columnWidths: const {
// //             1: pdfLib.FlexColumnWidth(6),
// //             0: pdfLib.FlexColumnWidth(1),
// //           },
// //           children: [
// //             _totalRow('الإجمالي', total),
// //             _totalRow('14% ضريبة مبيعات', tax),
// //             _totalRow('الإجمالي بعد الضريبة', afterTax),
// //             _totalRow('قيمة الكارتة', kartaValue),
// //             _totalRow('الإجمالي النهائي', totalWithKarta),
// //           ],
// //         ),
// //         pdfLib.SizedBox(height: 5),
// //         pdfLib.Align(
// //           alignment: pdfLib.Alignment.centerRight,
// //           child: pdfLib.Column(
// //             crossAxisAlignment: pdfLib.CrossAxisAlignment.end,
// //             children: [
// //               pdfLib.Text(
// //                 'سجل تجاري : $x',
// //                 style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
// //               ),
// //               pdfLib.Text(
// //                 'بطاقة ضريبة : $xx',
// //                 style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
// //               ),
// //             ],
// //           ),
// //         ),
// //         pdfLib.Text(
// //           'الفاتورة الغير مختومة بختم الشركة لايعتد بها',
// //           style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
// //         ),
// //       ],
// //     );
// //   }

// //   pdfLib.Widget _th(String t) => pdfLib.Padding(
// //     padding: const pdfLib.EdgeInsets.all(5),
// //     child: pdfLib.Text(
// //       t,
// //       textAlign: pdfLib.TextAlign.center,
// //       style: pdfLib.TextStyle(
// //         font: _arabicFont,
// //         fontWeight: pdfLib.FontWeight.bold,
// //         fontSize: 10,
// //       ),
// //     ),
// //   );

// //   pdfLib.Widget _td(String t, {bool right = false}) => pdfLib.Padding(
// //     padding: const pdfLib.EdgeInsets.all(5),
// //     child: pdfLib.Text(
// //       t,
// //       textAlign: right ? pdfLib.TextAlign.right : pdfLib.TextAlign.center,
// //       style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
// //     ),
// //   );

// //   pdfLib.TableRow _totalRow(String label, double v) {
// //     return pdfLib.TableRow(children: [_td(_format(v)), _td(label)]);
// //   }

// //   String _format(num v) => v.toStringAsFixed(0);

// //   String _getCompanyLocationName(List<Map<String, dynamic>> trips) {
// //     for (final t in trips) {
// //       final l = t['companyLocationName']?.toString() ?? '';
// //       if (l.isNotEmpty) return l;
// //     }
// //     return '';
// //   }

// //   List<Map<String, dynamic>> _groupTripsForInvoice(
// //     List<Map<String, dynamic>> trips,
// //   ) {
// //     final Map<String, Map<String, dynamic>> grouped = {};

// //     for (final trip in trips) {
// //       final date = trip['date'] != null
// //           ? DateFormat('d/M/yyyy').format((trip['date'] as DateTime))
// //           : DateFormat('d/M/yyyy').format(DateTime.now());
// //       final tr = trip['tr']?.toString() ?? '';
// //       final nolon = (trip['nolon'] ?? 0).toDouble();
// //       final companyOvernight = (trip['companyOvernight'] ?? 0).toDouble();
// //       final companyHoliday = (trip['companyHoliday'] ?? 0).toDouble();
// //       final selectedRoute = trip['selectedRoute']?.toString() ?? '';
// //       final selectedRoute2 = trip['selectedRoute2']?.toString() ?? '';
// //       final vehicleType = trip['vehicleType']?.toString() ?? '';
// //       final karta = trip['karta']?.toString() ?? '';

// //       final companyLocationName = trip['companyLocationName']?.toString() ?? '';

// //       String description = " ";
// //       if (companyLocationName.isNotEmpty) {
// //         description +=
// //             '   تحميل على ${vehicleType} من  ${selectedRoute}  الى  ${selectedRoute2} ';
// //       }

// //       final key = '$date|$tr|$nolon|$selectedRoute';

// //       if (!grouped.containsKey(key)) {
// //         grouped[key] = {
// //           'date': date,
// //           'tr': tr,
// //           'description': description,
// //           'nolon': nolon,
// //           'nolonCount': 1,
// //           'overnight': companyOvernight,
// //           'overnightCount': companyOvernight > 0 ? 1 : 0,
// //           'holiday': companyHoliday,
// //           'holidayCount': companyHoliday > 0 ? 1 : 0,
// //           'selectedRoute': selectedRoute,
// //           'companyLocationName': companyLocationName,
// //           'karta': karta,
// //         };
// //       } else {
// //         final existing = grouped[key]!;
// //         existing['nolonCount'] = (existing['nolonCount'] as int) + 1;
// //         if (companyOvernight > 0) {
// //           existing['overnightCount'] = (existing['overnightCount'] as int) + 1;
// //         }
// //         if (companyHoliday > 0) {
// //           existing['holidayCount'] = (existing['holidayCount'] as int) + 1;
// //         }
// //         // دمج الكارتات
// //         if (karta.isNotEmpty &&
// //             !(existing['karta'] as String).contains(karta)) {
// //           existing['karta'] = '${existing['karta']}، $karta';
// //         }
// //       }
// //     }

// //     final List<Map<String, dynamic>> result = [];

// //     grouped.forEach((key, tripGroup) {
// //       if (tripGroup['nolonCount'] > 0) {
// //         result.add({
// //           'type': 'نولون',
// //           'date': tripGroup['date'],
// //           'tr': tripGroup['tr'],
// //           'description': tripGroup['description'],
// //           'count': tripGroup['nolonCount'],
// //           'price': tripGroup['nolon'],
// //           'total':
// //               (tripGroup['nolonCount'] as int) * (tripGroup['nolon'] as double),
// //         });
// //       }
// //       if (tripGroup['overnightCount'] > 0) {
// //         result.add({
// //           'type': 'مبيت',
// //           'date': tripGroup['date'],
// //           'tr': tripGroup['tr'],
// //           'description': 'مبيت >>>${tripGroup['description']}',
// //           'count': tripGroup['overnightCount'],
// //           'price': tripGroup['overnight'],
// //           'total':
// //               (tripGroup['overnightCount'] as int) *
// //               (tripGroup['overnight'] as double),
// //         });
// //       }
// //       if (tripGroup['holidayCount'] > 0) {
// //         result.add({
// //           'type': 'عطلة',
// //           'date': tripGroup['date'],
// //           'tr': tripGroup['tr'],
// //           'description': 'عطلة >>>${tripGroup['description']}',
// //           'count': tripGroup['holidayCount'],
// //           'price': tripGroup['holiday'],
// //           'total':
// //               (tripGroup['holidayCount'] as int) *
// //               (tripGroup['holiday'] as double),
// //         });
// //       }
// //     });

// //     return result;
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
// //             /// زر واحد فقط (شركة أو رجوع)
// //             IconButton(
// //               icon: Icon(
// //                 _selectedCompany == null ? Icons.business : Icons.arrow_back,
// //                 color: Colors.white,
// //                 size: 28,
// //               ),
// //               onPressed: _selectedCompany != null ? _backToCompanies : null,
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

// //             if (_selectedCompany == null)
// //               IconButton(
// //                 icon: const Icon(Icons.sync, color: Colors.white),
// //                 onPressed: _syncDataOnPageEnter,
// //                 tooltip: 'مزامنة حسابات الشركات',
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
// //     final totalTrips = company['totalTrips'] ?? 0;
// //     final totalNolon = company['totalNolon'] ?? 0;

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
// //             color: totalTrips > 0 ? const Color(0xFF3498DB) : Colors.grey,
// //             borderRadius: BorderRadius.circular(22.5),
// //           ),
// //           child: Center(
// //             child: Text(
// //               totalTrips.toString(),
// //               style: const TextStyle(
// //                 color: Colors.white,
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 16,
// //               ),
// //             ),
// //           ),
// //         ),
// //         title: Text(
// //           companyName,
// //           style: TextStyle(
// //             fontWeight: FontWeight.bold,
// //             fontSize: 16,
// //             color: totalTrips > 0 ? const Color(0xFF2C3E50) : Colors.grey,
// //           ),
// //         ),
// //         subtitle: Text(
// //           totalTrips > 0
// //               ? '$totalTrips رحلة - ${_formatCurrency(totalNolon)}'
// //               : 'لا توجد رحلات',
// //           style: TextStyle(
// //             color: totalTrips > 0 ? Colors.green : Colors.grey,
// //             fontSize: 12,
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

// //     // ترتيب الرحلات من الأقدم إلى الأحدث
// //     final sortedWork = List<Map<String, dynamic>>.from(_companyWork)
// //       ..sort((a, b) {
// //         final dateA = a['date'] as DateTime? ?? DateTime(1900);
// //         final dateB = b['date'] as DateTime? ?? DateTime(1900);
// //         return dateA.compareTo(dateB);
// //       });

// //     return Column(
// //       children: [
// //         Expanded(
// //           child: Container(
// //             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //             decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
// //             child: sortedWork.isEmpty
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
// //                         defaultColumnWidth: const FixedColumnWidth(89),
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
// //                               TableCellHeader('TR'),
// //                               TableCellHeader('موقع الشركة'),
// //                               TableCellHeader('عطلة الشركة'),
// //                               TableCellHeader('مبيت الشركة'),
// //                               TableCellHeader('نولون الشركة'),
// //                               TableCellHeader('اسم السائق'),
// //                               TableCellHeader('الكارتة'),
// //                               TableCellHeader('العهدة'),
// //                               TableCellHeader('اسم الموقع'),
// //                               TableCellHeader('مكان التعتيق'),
// //                               TableCellHeader('مكان التحميل'),
// //                               TableCellHeader('التاريخ'),
// //                               TableCellHeader('م'),
// //                             ],
// //                           ),
// //                           ...sortedWork.asMap().entries.map((entry) {
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

// //               // الملاحظات (اختياري)
// //               Padding(
// //                 padding: const EdgeInsets.symmetric(horizontal: 16),
// //                 child: TextField(
// //                   controller: _invoiceNotesController,
// //                   decoration: InputDecoration(
// //                     labelText: 'ملاحظات (اختياري)',
// //                     prefixIcon: const Icon(Icons.note),
// //                     border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                     filled: true,
// //                     fillColor: Colors.white,
// //                   ),
// //                   maxLines: 2,
// //                 ),
// //               ),

// //               // شهر الإدراج
// //               Padding(
// //                 padding: const EdgeInsets.symmetric(
// //                   horizontal: 16,
// //                   vertical: 8,
// //                 ),
// //                 child: DropdownButtonFormField<String>(
// //                   value: _selectedMonth,
// //                   decoration: InputDecoration(
// //                     labelText: 'شهر الإدراج',
// //                     prefixIcon: const Icon(Icons.calendar_month),
// //                     border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                     filled: true,
// //                     fillColor: Colors.white,
// //                   ),
// //                   items: _monthsList.map((String month) {
// //                     return DropdownMenuItem<String>(
// //                       value: month,
// //                       child: Text(month),
// //                     );
// //                   }).toList(),
// //                   onChanged: (String? newValue) {
// //                     if (newValue != null) {
// //                       setState(() {
// //                         _selectedMonth = newValue;
// //                       });
// //                     }
// //                   },
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
// //                         defaultColumnWidth: const FixedColumnWidth(89),
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
// //                               TableCellHeader('TR'),
// //                               TableCellHeader('موقع الشركة'),
// //                               TableCellHeader('عطلة الشركة'),
// //                               TableCellHeader('مبيت الشركة'),
// //                               TableCellHeader('نولون الشركة'),
// //                               TableCellHeader('اسم السائق'),
// //                               TableCellHeader('الكارتة'),
// //                               TableCellHeader('العهدة'),
// //                               TableCellHeader('اسم الموقع'),
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

// //     final filteredInvoices = _filterInvoices();

// //     return Column(
// //       children: [
// //         // فلترة الفواتير
// //         Container(
// //           padding: const EdgeInsets.all(16),
// //           color: Colors.blue[50],
// //           child: Column(
// //             children: [
// //               // فلترة حسب الشهر
// //               Row(
// //                 children: [
// //                   const Icon(Icons.filter_alt, color: Color(0xFF3498DB)),
// //                   const SizedBox(width: 8),
// //                   const Text(
// //                     'فلترة حسب الشهر:',
// //                     style: TextStyle(
// //                       fontWeight: FontWeight.bold,
// //                       color: Color(0xFF3498DB),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 8),
// //                   Expanded(
// //                     child: DropdownButton<String>(
// //                       value: _selectedMonthFilter,
// //                       isExpanded: true,
// //                       items: _monthsList.map((String month) {
// //                         return DropdownMenuItem<String>(
// //                           value: month,
// //                           child: Text(month),
// //                         );
// //                       }).toList(),
// //                       onChanged: (String? newValue) {
// //                         if (newValue != null) {
// //                           setState(() {
// //                             _selectedMonthFilter = newValue;
// //                           });
// //                         }
// //                       },
// //                     ),
// //                   ),
// //                 ],
// //               ),

// //               const SizedBox(height: 12),

// //               // خيارات إظهار الفواتير
// //               Row(
// //                 children: [
// //                   Checkbox(
// //                     value: _showNotCollected,
// //                     onChanged: (value) {
// //                       setState(() {
// //                         _showNotCollected = value ?? false;
// //                       });
// //                     },
// //                   ),
// //                   const Text('إظهار الفواتير غير المحصلة'),

// //                   const SizedBox(width: 20),

// //                   Checkbox(
// //                     value: _showCollected,
// //                     onChanged: (value) {
// //                       setState(() {
// //                         _showCollected = value ?? false;
// //                       });
// //                     },
// //                   ),
// //                   const Text('إظهار الفواتير المحصلة'),
// //                 ],
// //               ),

// //               const SizedBox(height: 12),

// //               // أزرار طباعة جميع فواتير الشهر
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     child: ElevatedButton.icon(
// //                       onPressed: _isGeneratingPDF
// //                           ? null
// //                           : () => _printMonthInvoices(false),
// //                       icon: _isGeneratingPDF
// //                           ? const SizedBox(
// //                               width: 20,
// //                               height: 20,
// //                               child: CircularProgressIndicator(
// //                                 color: Colors.white,
// //                               ),
// //                             )
// //                           : const Icon(Icons.print),
// //                       label: const Text('طباعة فواتير الشهر غير المحصلة'),
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: Colors.orange,
// //                         foregroundColor: Colors.white,
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 8),
// //                   Expanded(
// //                     child: ElevatedButton.icon(
// //                       onPressed: _isGeneratingPDF
// //                           ? null
// //                           : () => _printMonthInvoices(true),
// //                       icon: _isGeneratingPDF
// //                           ? const SizedBox(
// //                               width: 20,
// //                               height: 20,
// //                               child: CircularProgressIndicator(
// //                                 color: Colors.white,
// //                               ),
// //                             )
// //                           : const Icon(Icons.print),
// //                       label: const Text('طباعة فواتير الشهر المحصلة'),
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: Colors.green,
// //                         foregroundColor: Colors.white,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),

// //         // تعداد الفواتير
// //         Padding(
// //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Text(
// //                 'عدد الفواتير: ${filteredInvoices.length}',
// //                 style: const TextStyle(
// //                   fontWeight: FontWeight.bold,
// //                   color: Color(0xFF2C3E50),
// //                 ),
// //               ),
// //               Text(
// //                 'شهر: $_selectedMonthFilter',
// //                 style: const TextStyle(
// //                   fontWeight: FontWeight.bold,
// //                   color: Color(0xFF3498DB),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),

// //         Expanded(
// //           child: filteredInvoices.isEmpty
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
// //                   itemCount: filteredInvoices.length,
// //                   itemBuilder: (context, index) {
// //                     final invoice = filteredInvoices[index];
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
// //     final isCollected = invoice['isCollected'] ?? false;
// //     final month = invoice['month'] ?? 'غير محدد';
// //     final notes = invoice['notes'] ?? '';
// //     final kartaValue = invoice['kartaValue'] ?? 0;
// //     final totalWithKarta =
// //         invoice['totalWithKarta'] ?? invoice['totalAmount'] ?? 0;

// //     return Container(
// //       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
// //       decoration: BoxDecoration(
// //         color: isCollected ? Colors.green[50] : Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(
// //           color: isCollected ? Colors.green : Colors.grey[300]!,
// //           width: isCollected ? 2 : 1,
// //         ),
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
// //           backgroundColor: isCollected ? Colors.green : const Color(0xFF3498DB),
// //           child: Text(
// //             '${index + 1}',
// //             style: const TextStyle(
// //               color: Colors.white,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //         ),
// //         title: Row(
// //           children: [
// //             Text(
// //               invoice['name'],
// //               style: TextStyle(
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 16,
// //                 color: isCollected
// //                     ? Colors.green[800]
// //                     : const Color(0xFF2C3E50),
// //               ),
// //             ),
// //             const SizedBox(width: 8),
// //             if (isCollected)
// //               Container(
// //                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// //                 decoration: BoxDecoration(
// //                   color: Colors.green,
// //                   borderRadius: BorderRadius.circular(4),
// //                 ),
// //                 child: const Text(
// //                   'محصلة',
// //                   style: TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 10,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         ),
// //         subtitle: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               '${createdAt != null ? _formatDate(createdAt) : 'غير معروف'}  ---  رحلة >>> ${invoice['tripCount']}',
// //               style: TextStyle(
// //                 fontSize: 12,
// //                 color: isCollected ? Colors.green[600] : Colors.grey,
// //               ),
// //             ),
// //             if (month.isNotEmpty)
// //               Text(
// //                 'شهر: $month',
// //                 style: TextStyle(
// //                   fontSize: 12,
// //                   color: isCollected ? Colors.green[600] : Colors.grey,
// //                 ),
// //               ),
// //             if (notes.isNotEmpty)
// //               Text(
// //                 'ملاحظات: $notes',
// //                 style: const TextStyle(
// //                   fontSize: 11,
// //                   color: Colors.grey,
// //                   fontStyle: FontStyle.italic,
// //                 ),
// //                 maxLines: 1,
// //                 overflow: TextOverflow.ellipsis,
// //               ),
// //           ],
// //         ),
// //         trailing: Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Text(
// //                   _formatCurrency(invoice['totalAmount']),
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 16,
// //                     color: isCollected
// //                         ? Colors.green[800]
// //                         : const Color(0xFF2E7D32),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 4),
// //                 Text(
// //                   'إجمالي',
// //                   style: TextStyle(
// //                     fontSize: 12,
// //                     color: isCollected ? Colors.green[600] : Colors.grey[600],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(width: 10),

// //             // زر تغيير حالة التحصيل
// //             IconButton(
// //               icon: Icon(
// //                 isCollected ? Icons.undo : Icons.check_circle,
// //                 color: isCollected ? Colors.orange : Colors.green,
// //               ),
// //               onPressed: () =>
// //                   _toggleInvoiceCollection(invoice['id'], !isCollected),
// //               tooltip: isCollected ? 'إلغاء التحصيل' : 'تم التحصيل',
// //             ),

// //             // زر مطالبة الكارتات
// //             IconButton(
// //               icon: Icon(Icons.credit_card, color: Color(0xFF9C27B0)),
// //               onPressed: _isGeneratingPDF
// //                   ? null
// //                   : () => _printKartaRequest(invoice),
// //               tooltip: 'مطالبة كارتات',
// //             ),
// //             const SizedBox(width: 5),
// //             // زر طباعة الفاتورة
// //             IconButton(
// //               icon: Icon(Icons.print, color: Color(0xFF3498DB)),
// //               onPressed: _isGeneratingPDF ? null : () => _printInvoice(invoice),
// //               tooltip: 'طباعة الفاتورة',
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
// //                     color: isCollected ? Colors.green[50] : Colors.blue[50],
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                   child: Column(
// //                     children: [
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           const Text(
// //                             'حالة التحصيل:',
// //                             style: TextStyle(fontWeight: FontWeight.bold),
// //                           ),
// //                           Text(
// //                             isCollected ? 'محصلة' : 'غير محصلة',
// //                             style: TextStyle(
// //                               color: isCollected ? Colors.green : Colors.red,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           const Text(
// //                             'شهر الإدراج:',
// //                             style: TextStyle(fontWeight: FontWeight.bold),
// //                           ),
// //                           Text(month),
// //                         ],
// //                       ),
// //                       if (notes.isNotEmpty) ...[
// //                         const SizedBox(height: 4),
// //                         Row(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             const Text(
// //                               'ملاحظات:',
// //                               style: TextStyle(fontWeight: FontWeight.bold),
// //                             ),
// //                             const SizedBox(width: 8),
// //                             Expanded(child: Text(notes)),
// //                           ],
// //                         ),
// //                       ],
// //                       const SizedBox(height: 4),
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           const Text(
// //                             'عدد الرحلات:',
// //                             style: TextStyle(fontWeight: FontWeight.bold),
// //                           ),
// //                           Text('${invoice['tripCount']}'),
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
// //                       const SizedBox(height: 4),
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           const Text(
// //                             'قيمة الكارتة:',
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               color: Color(0xFF9C27B0),
// //                             ),
// //                           ),
// //                           Text(
// //                             _formatCurrency(kartaValue),
// //                             style: const TextStyle(color: Color(0xFF9C27B0)),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           const Text(
// //                             'الإجمالي النهائي:',
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               color: Color(0xFF2E7D32),
// //                             ),
// //                           ),
// //                           Text(
// //                             _formatCurrency(totalWithKarta),
// //                             style: const TextStyle(
// //                               color: Color(0xFF2E7D32),
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                 ),

// //                 const SizedBox(height: 12),

// //                 // أزرار التحكم
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: ElevatedButton.icon(
// //                         onPressed: () => _toggleInvoiceCollection(
// //                           invoice['id'],
// //                           !isCollected,
// //                         ),
// //                         icon: Icon(
// //                           isCollected ? Icons.undo : Icons.check_circle,
// //                         ),
// //                         label: Text(
// //                           isCollected ? 'إلغاء التحصيل' : 'تم التحصيل',
// //                         ),
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: isCollected
// //                               ? Colors.orange
// //                               : Colors.green,
// //                           foregroundColor: Colors.white,
// //                           padding: const EdgeInsets.symmetric(vertical: 12),
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 8),
// //                     Expanded(
// //                       child: ElevatedButton.icon(
// //                         onPressed: _isGeneratingPDF
// //                             ? null
// //                             : () => _printKartaRequest(invoice),
// //                         icon: _isGeneratingPDF
// //                             ? const SizedBox(
// //                                 width: 20,
// //                                 height: 20,
// //                                 child: CircularProgressIndicator(
// //                                   color: Colors.white,
// //                                 ),
// //                               )
// //                             : const Icon(Icons.credit_card),
// //                         label: Text(
// //                           _isGeneratingPDF
// //                               ? 'جاري الطباعة...'
// //                               : 'مطالبة كارتات',
// //                           style: const TextStyle(fontSize: 16),
// //                         ),
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: Color(0xFF9C27B0),
// //                           foregroundColor: Colors.white,
// //                           padding: const EdgeInsets.symmetric(vertical: 12),
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 8),
// //                     Expanded(
// //                       child: ElevatedButton.icon(
// //                         onPressed: _isGeneratingPDF
// //                             ? null
// //                             : () => _printInvoice(invoice),
// //                         icon: _isGeneratingPDF
// //                             ? const SizedBox(
// //                                 width: 20,
// //                                 height: 20,
// //                                 child: CircularProgressIndicator(
// //                                   color: Colors.white,
// //                                 ),
// //                               )
// //                             : const Icon(Icons.print),
// //                         label: Text(
// //                           _isGeneratingPDF
// //                               ? 'جاري الطباعة...'
// //                               : 'طباعة الفاتورة',
// //                           style: const TextStyle(fontSize: 16),
// //                         ),
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: Color(0xFF2E7D32),
// //                           foregroundColor: Colors.white,
// //                           padding: const EdgeInsets.symmetric(vertical: 12),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
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
// //                             TableCellHeader('الكارتة'),
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
// //                               TableCellBody(
// //                                 trip['karta'] ?? '',
// //                                 textStyle: const TextStyle(
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Color(0xFF9C27B0),
// //                                 ),
// //                               ),
// //                             ],
// //                           );
// //                         }),
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
// import 'dart:typed_data';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:pdf/pdf.dart' as pdfLib;
// import 'package:pdf/widgets.dart' as pdfLib;
// import 'package:printing/printing.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pdfLib;

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
//   final TextEditingController _invoiceNotesController = TextEditingController();
//   String _selectedMonth = 'كل الشهور'; // اختيار شهر الإدراج
//   List<String> _monthsList = [
//     'كل الشهور',
//     'يناير',
//     'فبراير',
//     'مارس',
//     'أبريل',
//     'مايو',
//     'يونيو',
//     'يوليو',
//     'أغسطس',
//     'سبتمبر',
//     'أكتوبر',
//     'نوفمبر',
//     'ديسمبر',
//   ];

//   bool _isCreatingInvoice = false;
//   bool _isGeneratingPDF = false;

//   // متغيرات قسم الفواتير
//   String _selectedMonthFilter = 'كل الشهور'; // فلترة حسب الشهر
//   bool _showCollected = false; // إظهار الفواتير المحصلة
//   bool _showNotCollected = true; // إظهار الفواتير غير المحصلة
//   int _currentInvoiceView = 0; // 0: غير المحصلة، 1: المحصلة

//   // متغير للمزامنة التلقائية
//   bool _hasSyncedOnEnter = false;

//   // أضف هذا المتغير في بداية الكلاس
//   Uint8List? _logoImageBytes;

//   String x = '';
//   String xx = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadCompanies();
//     _loadArabicFont();
//     _loadLogoImage();
//     // تعيين الشهر الحالي كقيمة افتراضية
//     final now = DateTime.now();
//     _selectedMonth = _monthsList[now.month];
//     _selectedMonthFilter = _monthsList[now.month];
//   }

//   @override
//   void dispose() {
//     _invoiceNameController.dispose();
//     _invoiceNotesController.dispose();
//     super.dispose();
//   }

//   // ================================
//   // تحميل صورة اللوجو
//   // ================================
//   Future<void> _loadLogoImage() async {
//     try {
//       final ByteData data = await rootBundle.load('assets/image/logoo.jpeg');
//       if (mounted) {
//         setState(() {
//           _logoImageBytes = data.buffer.asUint8List();
//         });
//       }
//       debugPrint('تم تحميل صورة اللوجو بنجاح');
//     } catch (e) {
//       debugPrint('فشل تحميل صورة اللوجو: $e');
//     }
//   }

//   // ================================
//   // تحميل الخط العربي للطباعة
//   // ================================
//   Future<void> _loadArabicFont() async {
//     try {
//       final fontData = await rootBundle.load(
//         'assets/fonts/Amiri/Amiri-Regular.ttf',
//       );

//       if (mounted) {
//         setState(() {
//           _arabicFont = pdfLib.Font.ttf(fontData);
//         });
//       }
//       debugPrint('تم تحميل الخط العربي بنجاح');
//     } catch (e) {
//       debugPrint('فشل تحميل الخط العربي: $e');
//       if (mounted) {
//         setState(() {
//           _arabicFont = pdfLib.Font.courier();
//         });
//       }
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
//     if (mounted) {
//       setState(() => _isLoading = true);
//     }
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

//       if (mounted) {
//         setState(() {
//           _allCompanies = companiesList;
//           _filteredCompanies = _applySearchFilter(companiesList);
//           _isLoading = false;
//         });
//       }

//       // تحديث تلقائي عند دخول الصفحة الرئيسية فقط
//       if (!_hasSyncedOnEnter && _selectedCompany == null) {
//         await _syncDataOnPageEnter();
//         _hasSyncedOnEnter = true;
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//       debugPrint('خطأ في تحميل بيانات الشركات: $e');
//       _showError('خطأ في تحميل الشركات: $e');
//     }
//   }

//   // ================================
//   // تحميل بيانات الشركة المختارة
//   // ================================
//   Future<void> _loadCompanyData(String companyName, String companyId) async {
//     if (mounted) {
//       setState(() {
//         _selectedCompany = companyName;
//         _selectedCompanyId = companyId;
//         _isLoading = true;
//         _companyWork.clear();
//         _availableTripsForInvoice.clear();
//         _companyInvoices.clear();
//         _selectedTripsForInvoice.clear();
//         _invoiceNameController.clear();
//         _invoiceNotesController.clear();
//       });
//     }

//     try {
//       // 1. تحميل جميع رحلات الشركة من dailyWork
//       final workSnapshot = await _firestore
//           .collection('dailyWork')
//           .where('companyId', isEqualTo: companyId)
//           .orderBy('date', descending: false) // الأقدم أولاً
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
//           'karta': data['karta'] ?? '', // تخزين الكارتة
//           'ohda': data['ohda'] ?? '',
//           'selectedRoute': data['selectedRoute'] ?? '',
//           'selectedRoute2': data['unloadingLocation'] ?? '',
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
//         double totalKartaValue = 0;

//         for (var tripId in tripIds) {
//           final tripDoc = await _firestore
//               .collection('dailyWork')
//               .doc(tripId.toString())
//               .get();
//           if (tripDoc.exists) {
//             final tripData = tripDoc.data() as Map<String, dynamic>;
//             final karta = tripData['karta']?.toString() ?? '';
//             double kartaValue = 0;

//             try {
//               final cleanedKarta = karta.trim();
//               if (cleanedKarta.isNotEmpty) {
//                 kartaValue = double.tryParse(cleanedKarta) ?? 0;
//               }
//             } catch (e) {
//               debugPrint('خطأ في تحويل الكارتة إلى رقم: $karta');
//             }

//             totalKartaValue += kartaValue;

//             invoiceTrips.add({
//               'selectedRoute': tripData['loadingLocation'] ?? '',
//               'selectedRoute2': tripData['unloadingLocation'] ?? '',
//               'vehicleType': tripData['selectedVehicleType'] ?? '',
//               'nolon': (tripData['noLon'] ?? tripData['nolon'] ?? 0).toDouble(),
//               'companyOvernight': (tripData['companyOvernight'] ?? 0)
//                   .toDouble(),
//               'companyHoliday': (tripData['companyHoliday'] ?? 0).toDouble(),
//               'tr': tripData['tr'] ?? '',
//               'companyLocationName': tripData['companyLocationName'] ?? '',
//               'date': (tripData['date'] as Timestamp?)?.toDate(),
//               'karta': karta,
//               'kartaValue': kartaValue,
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
//           'companyId': data['companyId'] ?? companyId,
//           'totalAmount': (data['totalAmount'] ?? 0).toDouble(),
//           'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
//           'tripIds': tripIds,
//           'tripCount': tripIds.length,
//           'invoiceTrips': invoiceTrips,
//           'nolonTotal': totalNolon,
//           'overnightTotal': totalOvernight,
//           'holidayTotal': totalHoliday,
//           'kartaDetails': invoiceTrips.map((trip) => trip['karta']).toList(),
//           'kartaValue': totalKartaValue,
//           'totalWithKarta':
//               (data['totalAmount'] ?? 0).toDouble() + totalKartaValue,
//           'notes': data['notes'] ?? '', // ملاحظات الفاتورة
//           'month': data['month'] ?? 'غير محدد', // شهر الإدراج
//           'isCollected': data['isCollected'] ?? false, // حالة التحصيل
//           'collectedAt': (data['collectedAt'] as Timestamp?)?.toDate(),
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

//       // ترتيب الرحلات المتاحة للفاتورة: الأقدم أولاً، ثم تجميع الـ TR المتشابه
//       final sortedAvailableTrips = _sortAndGroupTripsForInvoice(availableTrips);

//       if (mounted) {
//         setState(() {
//           _companyWork = allTrips;
//           _availableTripsForInvoice = sortedAvailableTrips;
//           _companyInvoices = invoicesList;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//       _showError('خطأ في تحميل بيانات الشركة: $e');
//     }
//   }

//   // ================================
//   // الحصول على حالة نظام TR للشركة
//   // ================================
//   Future<bool> _getCompanyTRStatus(String companyId) async {
//     try {
//       final companyDoc = await _firestore
//           .collection('companies')
//           .doc(companyId)
//           .get();
//       if (companyDoc.exists) {
//         final data = companyDoc.data() as Map<String, dynamic>;
//         x = data['commercialRegister'];
//         xx = data['taxCard'];

//         return data['usesTRSystem'] ?? false;
//       }
//       return false;
//     } catch (e) {
//       debugPrint('خطأ في جلب حالة TR: $e');
//       return false;
//     }
//   }

//   // ================================
//   // ترتيب وتجميع الرحلات للفاتورة
//   // ================================
//   List<Map<String, dynamic>> _sortAndGroupTripsForInvoice(
//     List<Map<String, dynamic>> trips,
//   ) {
//     if (trips.isEmpty) return [];

//     // 1. ترتيب الرحلات حسب التاريخ (الأقدم أولاً)
//     trips.sort((a, b) {
//       final dateA = a['date'] as DateTime? ?? DateTime(1900);
//       final dateB = b['date'] as DateTime? ?? DateTime(1900);
//       return dateA.compareTo(dateB);
//     });

//     // 2. تجميع الرحلات حسب التاريخ والـ TR
//     final Map<String, List<Map<String, dynamic>>> groupedTrips = {};

//     for (var trip in trips) {
//       final date = trip['date'] as DateTime?;
//       final tr = trip['tr']?.toString() ?? '';
//       final dateKey = date != null
//           ? DateFormat('yyyy-MM-dd').format(date)
//           : 'unknown_date';

//       // المفتاح: التاريخ + الـ TR
//       final key = '$dateKey|$tr';

//       if (!groupedTrips.containsKey(key)) {
//         groupedTrips[key] = [];
//       }
//       groupedTrips[key]!.add(trip);
//     }

//     // 3. تحويل المجموعات إلى قائمة مرتبة
//     final List<Map<String, dynamic>> result = [];

//     // الحصول على المفاتيح وترتيبها حسب التاريخ
//     final sortedKeys = groupedTrips.keys.toList()
//       ..sort((a, b) {
//         // استخراج التاريخ من المفتاح
//         final datePartA = a.split('|')[0];
//         final datePartB = b.split('|')[0];
//         return datePartA.compareTo(datePartB);
//       });

//     // إضافة الرحلات المجمعة
//     for (var key in sortedKeys) {
//       final tripsInGroup = groupedTrips[key]!;

//       // ترتيب الرحلات داخل المجموعة حسب الوقت إذا كان موجوداً
//       tripsInGroup.sort((a, b) {
//         final timeA = (a['date'] as DateTime?)?.toIso8601String() ?? '';
//         final timeB = (b['date'] as DateTime?)?.toIso8601String() ?? '';
//         return timeA.compareTo(timeB);
//       });

//       result.addAll(tripsInGroup);
//     }

//     return result;
//   }

//   // ================================
//   // فلترة الفواتير حسب الشهر وحالة التحصيل
//   // ================================
//   List<Map<String, dynamic>> _getFilteredInvoices(bool collected) {
//     List<Map<String, dynamic>> filtered = _companyInvoices.where((invoice) {
//       return invoice['isCollected'] == collected;
//     }).toList();

//     // فلترة حسب الشهر
//     if (_selectedMonthFilter != 'كل الشهور') {
//       filtered = filtered.where((invoice) {
//         final month = invoice['month'] ?? 'غير محدد';
//         return month == _selectedMonthFilter;
//       }).toList();
//     }

//     return filtered;
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
//     if (!mounted) return;
//     setState(() {
//       if (selected) {
//         _selectedTripsForInvoice.add(trip);
//       } else {
//         _selectedTripsForInvoice.removeWhere((t) => t['id'] == trip['id']);
//       }
//     });
//   }

//   void _selectAllTrips(bool select) {
//     if (!mounted) return;
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

//     if (mounted) {
//       setState(() => _isCreatingInvoice = true);
//     }

//     try {
//       // حساب إجمالي المبالغ
//       double totalNolon = 0;
//       double totalOvernight = 0;
//       double totalHoliday = 0;
//       double totalKartaValue = 0;
//       List<String> tripIds = [];
//       List<Map<String, dynamic>> invoiceTripDetails = [];

//       for (var trip in _selectedTripsForInvoice) {
//         totalNolon += trip['nolon'];
//         totalOvernight += trip['companyOvernight'];
//         totalHoliday += trip['companyHoliday'];
//         tripIds.add(trip['id']);

//         // حساب قيمة الكارتة
//         final karta = trip['karta']?.toString() ?? '';
//         double kartaValue = 0;
//         try {
//           final cleanedKarta = karta.trim();
//           if (cleanedKarta.isNotEmpty) {
//             kartaValue = double.tryParse(cleanedKarta) ?? 0;
//           }
//         } catch (e) {
//           debugPrint('خطأ في تحويل الكارتة إلى رقم: $karta');
//         }
//         totalKartaValue += kartaValue;

//         // تخزين تفاصيل الرحلة بما فيها الكارتة
//         invoiceTripDetails.add({
//           'selectedRoute': trip['selectedRoute'],
//           'selectedRoute2': trip['selectedRoute2'],
//           'vehicleType': trip['vehicleType'],
//           'nolon': trip['nolon'],
//           'companyOvernight': trip['companyOvernight'],
//           'companyHoliday': trip['companyHoliday'],
//           'tr': trip['tr'],
//           'companyLocationName': trip['companyLocationName'],
//           'date': trip['date'],
//           'karta': karta,
//           'kartaValue': kartaValue,
//         });
//       }

//       double totalAmount = totalNolon + totalOvernight + totalHoliday;

//       // حفظ الفاتورة مع الكارتات
//       await _firestore.collection('invoices').add({
//         'name': _invoiceNameController.text.trim(),
//         'companyName': _selectedCompany!,
//         'companyId': _selectedCompanyId!,
//         'totalAmount': totalAmount,
//         'nolonTotal': totalNolon,
//         'overnightTotal': totalOvernight,
//         'holidayTotal': totalHoliday,
//         'kartaValue': totalKartaValue,
//         'totalWithKarta': totalAmount + totalKartaValue,
//         'tripIds': tripIds,
//         'tripDetails': invoiceTripDetails,
//         'tripCount': tripIds.length,
//         'kartaDetails': _selectedTripsForInvoice
//             .map((trip) => trip['karta'] ?? '')
//             .toList(),
//         'notes': _invoiceNotesController.text.trim(), // ملاحظات الفاتورة
//         'month': _selectedMonth, // شهر الإدراج
//         'isCollected': false, // حالة التحصيل (افتراضيًا غير محصلة)
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
//       if (mounted) {
//         setState(() {
//           _selectedTripsForInvoice.clear();
//           _invoiceNameController.clear();
//           _invoiceNotesController.clear();
//         });
//       }

//       // الذهاب إلى قسم الفواتير
//       _changeSection(2);
//     } catch (e) {
//       _showError('خطأ في إنشاء الفاتورة: $e');
//     } finally {
//       if (mounted) {
//         setState(() => _isCreatingInvoice = false);
//       }
//     }
//   }

//   // ================================
//   // تحديث حالة تحصيل الفاتورة
//   // ================================
//   Future<void> _toggleInvoiceCollection(
//     String invoiceId,
//     bool isCollected,
//   ) async {
//     try {
//       await _firestore.collection('invoices').doc(invoiceId).update({
//         'isCollected': isCollected,
//         'collectedAt': isCollected ? Timestamp.now() : null,
//         'collectedDate': isCollected
//             ? DateFormat('dd/MM/yyyy').format(DateTime.now())
//             : null,
//       });

//       // إعادة تحميل بيانات الشركة
//       await _loadCompanyData(_selectedCompany!, _selectedCompanyId!);

//       _showSuccess(
//         isCollected ? 'تم تحديد الفاتورة كمحصلة' : 'تم إلغاء تحصيل الفاتورة',
//       );
//     } catch (e) {
//       _showError('خطأ في تحديث حالة الفاتورة: $e');
//     }
//   }

//   // ================================
//   // طباعة جميع فواتير الشهر (محصلة أو غير محصلة)
//   // ================================//////////////////////////////////////////////////////////////////

//   // طباعة فواتير الشهر - بتصميم مشابه لطباعة السائقين
//   Future<void> _printMonthInvoices(bool collected) async {
//     if (_arabicFont == null) {
//       await _loadArabicFont();
//     }

//     if (mounted) {
//       setState(() => _isGeneratingPDF = true);
//     }

//     try {
//       // الحصول على الفواتير المفلترة
//       final invoices = _getFilteredInvoices(collected);

//       if (invoices.isEmpty) {
//         _showError(
//           'لا توجد فواتير ${collected ? 'محصلة' : 'غير محصلة'} للشهر المحدد',
//         );
//         return;
//       }

//       // حساب المجاميع
//       double totalInvoices = 0;
//       double totalKarta = 0;
//       double totalWithKarta = 0;

//       for (var invoice in invoices) {
//         totalInvoices += invoice['totalAmount'] ?? 0;
//         totalKarta += invoice['kartaValue'] ?? 0;
//         totalWithKarta += invoice['totalWithKarta'] ?? 0;
//       }

//       // إنشاء PDF بتصميم مشابه لطباعة السائقين
//       final pdf = pdfLib.Document(
//         theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
//       );

//       pdf.addPage(
//         pdfLib.MultiPage(
//           pageFormat: pdfLib.PdfPageFormat.a4,
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
//                         'تقرير فواتير الشركات',
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

//             // معلومات التقرير
//             _buildReportInfoPdf(
//               collected,
//               invoices.length,
//               totalInvoices,
//               totalKarta,
//               totalWithKarta,
//             ),
//             pdfLib.SizedBox(height: 15),

//             // الجدول
//             _buildInvoicesTablePdf(invoices),
//             pdfLib.SizedBox(height: 10),

//             // الملخص
//             _buildInvoiceSummaryPdf(
//               collected,
//               invoices.length,
//               totalInvoices,
//               totalKarta,
//               totalWithKarta,
//             ),
//           ],
//         ),
//       );

//       // طباعة PDF
//       await Printing.layoutPdf(
//         onLayout: (pdfLib.PdfPageFormat format) async => pdf.save(),
//         name: _getInvoicePDFFileName(collected),
//       );

//       _showSuccess('تم طباعة ${invoices.length} فاتورة بنجاح');
//     } catch (e) {
//       _showError('حدث خطأ في إنشاء PDF: $e');
//     } finally {
//       if (mounted) {
//         setState(() => _isGeneratingPDF = false);
//       }
//     }
//   }

//   // بناء معلومات التقرير للPDF
//   pdfLib.Widget _buildReportInfoPdf(
//     bool collected,
//     int invoiceCount,
//     double totalInvoices,
//     double totalKarta,
//     double totalWithKarta,
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
//             // اسم الشركة ونوع الفواتير في نفس السطر
//             pdfLib.Row(
//               mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
//               children: [
//                 pdfLib.Text(
//                   'الشركة: $_selectedCompany',
//                   style: pdfLib.TextStyle(
//                     fontSize: 12,
//                     fontWeight: pdfLib.FontWeight.bold,
//                     font: _arabicFont,
//                     color: PdfColors.black,
//                   ),
//                 ),
//                 pdfLib.Text(
//                   'الفواتير: ${collected ? 'محصلة' : 'غير محصلة'}',
//                   style: pdfLib.TextStyle(
//                     fontSize: 10,
//                     font: _arabicFont,
//                     color: collected ? PdfColors.green : PdfColors.red,
//                   ),
//                 ),
//               ],
//             ),
//             pdfLib.SizedBox(height: 4),

//             // الشهر وعدد الفواتير في السطر الثاني
//             pdfLib.Row(
//               mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
//               children: [
//                 pdfLib.Text(
//                   'الشهر: $_selectedMonthFilter',
//                   style: pdfLib.TextStyle(
//                     fontSize: 11,
//                     fontWeight: pdfLib.FontWeight.bold,
//                     font: _arabicFont,
//                     color: PdfColors.blue,
//                   ),
//                 ),
//                 pdfLib.Text(
//                   'عدد الفواتير: $invoiceCount',
//                   style: pdfLib.TextStyle(
//                     fontSize: 10,
//                     font: _arabicFont,
//                     color: PdfColors.blue,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // بناء الجدول في PDF
//   pdfLib.Widget _buildInvoicesTablePdf(List<Map<String, dynamic>> invoices) {
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
//           0: pdfLib.Alignment.center,
//           1: pdfLib.Alignment.center,
//           2: pdfLib.Alignment.center,
//           3: pdfLib.Alignment.center,
//           4: pdfLib.Alignment.center,
//           5: pdfLib.Alignment.center,
//           6: pdfLib.Alignment.center,
//           7: pdfLib.Alignment.center,
//         },
//         columnWidths: {
//           7: pdfLib.FlexColumnWidth(0.4),
//           6: pdfLib.FlexColumnWidth(1.0),
//           5: pdfLib.FlexColumnWidth(1.5),
//           4: pdfLib.FlexColumnWidth(0.8),
//           3: pdfLib.FlexColumnWidth(0.8),
//           2: pdfLib.FlexColumnWidth(0.8),
//           1: pdfLib.FlexColumnWidth(1.2),
//           0: pdfLib.FlexColumnWidth(1.5),
//         },
//         headers: [
//           'الملاحظات',
//           'الموقع',
//           'الإجمالي',
//           'قيمة الكارتة',
//           'قيمة الفاتورة',
//           'اسم الفاتورة',
//           'تاريخ التقديم',
//           'م',
//         ],
//         data: List<List<String>>.generate(invoices.length, (index) {
//           final invoice = invoices[index];
//           final createdAt = invoice['createdAt'] as DateTime?;
//           final location = _getCompanyLocationName(
//             invoice['invoiceTrips'] ?? [],
//           );
//           final invoiceAmount = invoice['totalAmount'] ?? 0;
//           final kartaValue = invoice['kartaValue'] ?? 0;
//           final totalWithKarta = invoice['totalWithKarta'] ?? invoiceAmount;
//           final notes = invoice['notes'] ?? '';

//           return [
//             notes.isNotEmpty ? notes : '-',
//             location,
//             totalWithKarta.toStringAsFixed(2),
//             kartaValue.toStringAsFixed(2),
//             invoiceAmount.toStringAsFixed(2),
//             invoice['name'] ?? '',
//             createdAt != null ? DateFormat('dd/MM/yy').format(createdAt) : '-',
//             (index + 1).toString(),
//           ];
//         }),
//       ),
//     );
//   }

//   // بناء ملخص الإجماليات للPDF
//   pdfLib.Widget _buildInvoiceSummaryPdf(
//     bool collected,

//     int invoiceCount,

//     double totalInvoices,
//     double totalKarta,
//     double totalWithKarta,
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
//                 fontSize: 12,
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
//                   'عدد الفواتير: $invoiceCount',
//                   style: pdfLib.TextStyle(
//                     fontSize: 10,
//                     font: _arabicFont,
//                     color: PdfColors.black,
//                   ),
//                 ),
//                 pdfLib.Text(
//                   'إجمالي الفواتير: ${totalInvoices.toStringAsFixed(2)} ج',
//                   style: pdfLib.TextStyle(
//                     fontSize: 10,
//                     font: _arabicFont,
//                     color: PdfColors.blue,
//                   ),
//                 ),
//               ],
//             ),
//             pdfLib.SizedBox(height: 3),
//             pdfLib.Row(
//               mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
//               children: [
//                 pdfLib.Text(
//                   'إجمالي الكارتات: ${totalKarta.toStringAsFixed(2)} ج',
//                   style: pdfLib.TextStyle(
//                     fontSize: 10,
//                     font: _arabicFont,
//                     color: PdfColors.green,
//                   ),
//                 ),
//                 pdfLib.Text(
//                   'إجمالي النهائي: ${totalWithKarta.toStringAsFixed(2)} ج',
//                   style: pdfLib.TextStyle(
//                     fontSize: 10,
//                     font: _arabicFont,
//                     color: PdfColors.red,
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
//                   'إجمالي المبلغ المستحق:',
//                   style: pdfLib.TextStyle(
//                     fontSize: 12,
//                     fontWeight: pdfLib.FontWeight.bold,
//                     font: _arabicFont,
//                     color: PdfColors.black,
//                   ),
//                 ),
//                 pdfLib.Text(
//                   '${collected ? '0' : totalWithKarta.toStringAsFixed(2)} ج',
//                   style: pdfLib.TextStyle(
//                     fontSize: 12,
//                     fontWeight: pdfLib.FontWeight.bold,
//                     font: _arabicFont,
//                     color: PdfColors.red,
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
//   String _getInvoicePDFFileName(bool collected) {
//     final now = DateTime.now();
//     final formattedDate = DateFormat('yyyyMMdd').format(now);
//     return 'فواتير_${_selectedCompany}_${collected ? 'محصلة' : 'غير_محصلة'}_$formattedDate';
//   }

//   // Future<void> _printMonthInvoices(bool collected) async {
//   //   if (_arabicFont == null) {
//   //     await _loadArabicFont();
//   //   }

//   //   if (mounted) {
//   //     setState(() => _isGeneratingPDF = true);
//   //   }

//   //   try {
//   //     // الحصول على الفواتير المفلترة
//   //     final invoices = _getFilteredInvoices(collected);

//   //     if (invoices.isEmpty) {
//   //       _showError(
//   //         'لا توجد فواتير ${collected ? 'محصلة' : 'غير محصلة'} للشهر المحدد',
//   //       );
//   //       return;
//   //     }

//   //     // حساب المجاميع
//   //     double totalInvoices = 0;
//   //     double totalKarta = 0;
//   //     double totalWithKarta = 0;

//   //     for (var invoice in invoices) {
//   //       totalInvoices += invoice['totalAmount'] ?? 0;
//   //       totalKarta += invoice['kartaValue'] ?? 0;
//   //       totalWithKarta += invoice['totalWithKarta'] ?? 0;
//   //     }

//   //     // إنشاء PDF بتصميم احترافي
//   //     final pdf = pdfLib.Document(
//   //       theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
//   //     );

//   //     pdf.addPage(
//   //       pdfLib.MultiPage(
//   //         pageFormat: pdfLib.PdfPageFormat.a4,
//   //         margin: const pdfLib.EdgeInsets.only(right: 40, left: 40),
//   //         build: (context) => [
//   //           pdfLib.Directionality(
//   //             textDirection: pdfLib.TextDirection.rtl,
//   //             child: pdfLib.Column(
//   //               crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
//   //               children: [
//   //                 // الهيدر
//   //                 _buildReportHeader(collected),

//   //                 pdfLib.SizedBox(height: 15),

//   //                 // معلومات الشركة
//   //                 _buildCompanyInfo(),

//   //                 pdfLib.SizedBox(height: 15),

//   //                 // إحصائيات التقرير
//   //                 _buildReportStats(
//   //                   invoices.length,
//   //                   totalInvoices,
//   //                   totalKarta,
//   //                   totalWithKarta,
//   //                 ),

//   //                 pdfLib.SizedBox(height: 15),

//   //                 // جدول الفواتير
//   //                 _buildInvoicesTable(invoices),

//   //                 pdfLib.SizedBox(height: 20),

//   //                 // التوقيعات
//   //                 _buildSignatures(),
//   //               ],
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //     );

//   //     await Printing.layoutPdf(
//   //       name:
//   //           'فواتير ${collected ? 'محصلة' : 'غير محصلة'} - شهر $_selectedMonthFilter - $_selectedCompany',
//   //       onLayout: (_) async => pdf.save(),
//   //     );

//   //     _showSuccess('تم طباعة ${invoices.length} فاتورة بنجاح');
//   //   } catch (e) {
//   //     _showError('خطأ في طباعة الفواتير: $e');
//   //   } finally {
//   //     if (mounted) {
//   //       setState(() => _isGeneratingPDF = false);
//   //     }
//   //   }
//   // }

//   // // ================================
//   // // بناء هيدر التقرير
//   // // ================================
//   // pdfLib.Widget _buildReportHeader(bool collected) {
//   //   final now = DateTime.now();
//   //   return pdfLib.Container(
//   //     decoration: pdfLib.BoxDecoration(
//   //       color: pdfLib.PdfColors.blue50,
//   //       borderRadius: pdfLib.BorderRadius.circular(5),
//   //     ),
//   //     padding: const pdfLib.EdgeInsets.all(15),
//   //     child: pdfLib.Column(
//   //       children: [
//   //         // العنوان الرئيسي
//   //         pdfLib.Row(
//   //           mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
//   //           children: [
//   //             // معلومات الطباعة
//   //             pdfLib.Column(
//   //               crossAxisAlignment: pdfLib.CrossAxisAlignment.end,
//   //               children: [
//   //                 pdfLib.Text(
//   //                   'تاريخ الطباعة: ${DateFormat('dd/MM/yyyy').format(now)}',
//   //                   style: pdfLib.TextStyle(fontSize: 10),
//   //                 ),
//   //                 pdfLib.Text(
//   //                   'وقت الطباعة: ${DateFormat('hh:mm a').format(now)}',
//   //                   style: pdfLib.TextStyle(fontSize: 10),
//   //                 ),
//   //               ],
//   //             ),

//   //             // عنوان التقرير
//   //             pdfLib.Column(
//   //               children: [
//   //                 pdfLib.Text(
//   //                   'شركة نيوجراند لخدمات النقل',
//   //                   style: pdfLib.TextStyle(
//   //                     fontSize: 16,
//   //                     fontWeight: pdfLib.FontWeight.bold,
//   //                     color: pdfLib.PdfColors.blue900,
//   //                   ),
//   //                 ),
//   //                 pdfLib.Text(
//   //                   'تقرير الفواتير ${collected ? 'المحصلة' : 'غير المحصلة'}',
//   //                   style: pdfLib.TextStyle(
//   //                     fontSize: 14,
//   //                     fontWeight: pdfLib.FontWeight.bold,
//   //                     color: collected
//   //                         ? pdfLib.PdfColors.green700
//   //                         : pdfLib.PdfColors.red700,
//   //                   ),
//   //                 ),
//   //                 pdfLib.Text(
//   //                   'شهر: $_selectedMonthFilter',
//   //                   style: pdfLib.TextStyle(
//   //                     fontSize: 12,
//   //                     fontWeight: pdfLib.FontWeight.bold,
//   //                   ),
//   //                 ),
//   //               ],
//   //             ),
//   //           ],
//   //         ),

//   //         pdfLib.SizedBox(height: 5),

//   //         // معلومات الشركة
//   //         pdfLib.Container(
//   //           padding: const pdfLib.EdgeInsets.all(8),
//   //           decoration: pdfLib.BoxDecoration(
//   //             color: pdfLib.PdfColors.white,
//   //             borderRadius: pdfLib.BorderRadius.circular(3),
//   //             border: pdfLib.Border.all(color: pdfLib.PdfColors.blue100),
//   //           ),
//   //           child: pdfLib.Row(
//   //             mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
//   //             children: [
//   //               pdfLib.Text(
//   //                 'الشركة: $_selectedCompany',
//   //                 style: pdfLib.TextStyle(
//   //                   fontSize: 11,
//   //                   fontWeight: pdfLib.FontWeight.bold,
//   //                 ),
//   //               ),
//   //               pdfLib.Text(
//   //                 '${collected ? 'محصلة' : 'غير محصلة'}',
//   //                 style: pdfLib.TextStyle(
//   //                   fontSize: 11,
//   //                   fontWeight: pdfLib.FontWeight.bold,
//   //                   color: collected
//   //                       ? pdfLib.PdfColors.green700
//   //                       : pdfLib.PdfColors.red700,
//   //                 ),
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   // // ================================
//   // // معلومات الشركة
//   // // ================================
//   // pdfLib.Widget _buildCompanyInfo() {
//   //   return pdfLib.Container(
//   //     decoration: pdfLib.BoxDecoration(
//   //       border: pdfLib.Border.all(color: pdfLib.PdfColors.grey300),
//   //       borderRadius: pdfLib.BorderRadius.circular(3),
//   //     ),
//   //     padding: const pdfLib.EdgeInsets.all(10),
//   //     child: pdfLib.Row(
//   //       mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
//   //       children: [
//   //         pdfLib.Column(
//   //           crossAxisAlignment: pdfLib.CrossAxisAlignment.end,
//   //           children: [
//   //             pdfLib.Text(
//   //               'سجل تجاري: $x',
//   //               style: pdfLib.TextStyle(fontSize: 9),
//   //             ),
//   //             pdfLib.Text(
//   //               'بطاقة ضريبة: $xx',
//   //               style: pdfLib.TextStyle(fontSize: 9),
//   //             ),
//   //           ],
//   //         ),
//   //         pdfLib.Text(
//   //           'New grand',
//   //           style: pdfLib.TextStyle(
//   //             fontSize: 12,
//   //             fontWeight: pdfLib.FontWeight.bold,
//   //             color: pdfLib.PdfColors.blue700,
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   // // ================================
//   // // إحصائيات التقرير
//   // // ================================
//   // pdfLib.Widget _buildReportStats(
//   //   int count,
//   //   double invoices,
//   //   double karta,
//   //   double total,
//   // ) {
//   //   return pdfLib.Container(
//   //     decoration: pdfLib.BoxDecoration(
//   //       color: pdfLib.PdfColors.grey50,
//   //       border: pdfLib.Border.all(color: pdfLib.PdfColors.grey300),
//   //       borderRadius: pdfLib.BorderRadius.circular(5),
//   //     ),
//   //     padding: const pdfLib.EdgeInsets.all(10),
//   //     child: pdfLib.Row(
//   //       mainAxisAlignment: pdfLib.MainAxisAlignment.spaceAround,
//   //       children: [
//   //         _statItem('عدد الفواتير', count.toString()),
//   //         _statItem('إجمالي الفواتير', '${invoices.toStringAsFixed(2)} ج'),
//   //         _statItem('إجمالي الكارتات', '${karta.toStringAsFixed(2)} ج'),
//   //         _statItem('الإجمالي النهائي', '${total.toStringAsFixed(2)} ج'),
//   //       ],
//   //     ),
//   //   );
//   // }

//   // pdfLib.Widget _statItem(String label, String value) {
//   //   return pdfLib.Column(
//   //     children: [
//   //       pdfLib.Text(
//   //         label,
//   //         style: pdfLib.TextStyle(fontSize: 9, color: pdfLib.PdfColors.grey600),
//   //       ),
//   //       pdfLib.SizedBox(height: 3),
//   //       pdfLib.Text(
//   //         value,
//   //         style: pdfLib.TextStyle(
//   //           fontSize: 11,
//   //           fontWeight: pdfLib.FontWeight.bold,
//   //           color: pdfLib.PdfColors.blue700,
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // }

//   // // ================================
//   // // جدول الفواتير بتصميم احترافي
//   // // ================================
//   // pdfLib.Widget _buildInvoicesTable(List<Map<String, dynamic>> invoices) {
//   //   return pdfLib.TableHelper.fromTextArray(
//   //     context: null,
//   //     cellAlignment: pdfLib.Alignment.centerRight,
//   //     headerCount: 0,
//   //     cellStyle: pdfLib.TextStyle(fontSize: 8),
//   //     headerDecoration: pdfLib.BoxDecoration(
//   //       color: pdfLib.PdfColors.blue100,
//   //       borderRadius: pdfLib.BorderRadius.circular(2),
//   //     ),
//   //     border: pdfLib.TableBorder.all(
//   //       color: pdfLib.PdfColors.grey300,
//   //       width: 0.5,
//   //     ),
//   //     columnWidths: {
//   //       7: pdfLib.FlexColumnWidth(1.5), // م
//   //       6: pdfLib.FlexColumnWidth(2.5), // تاريخ التقديم
//   //       5: pdfLib.FlexColumnWidth(3), // اسم الفاتورة
//   //       4: pdfLib.FlexColumnWidth(2), // قيمة الفاتورة
//   //       3: pdfLib.FlexColumnWidth(2), // قيمة الكارتة
//   //       2: pdfLib.FlexColumnWidth(2), // الإجمالي
//   //       1: pdfLib.FlexColumnWidth(3), // الموقع
//   //       0: pdfLib.FlexColumnWidth(4), // الملاحظات
//   //     },
//   //     data: [
//   //       [
//   //         'م',
//   //         'تاريخ التقديم',
//   //         'اسم الفاتورة',
//   //         'قيمة الفاتورة',
//   //         'قيمة الكارتة',
//   //         'الإجمالي',
//   //         'الموقع',
//   //         'الملاحظات',
//   //       ],
//   //       ...invoices.asMap().entries.map((entry) {
//   //         final index = entry.key;
//   //         final invoice = entry.value;
//   //         final createdAt = invoice['createdAt'] as DateTime?;
//   //         final location = _getCompanyLocationName(
//   //           invoice['invoiceTrips'] ?? [],
//   //         );
//   //         final invoiceAmount = invoice['totalAmount'] ?? 0;
//   //         final kartaValue = invoice['kartaValue'] ?? 0;
//   //         final totalWithKarta = invoice['totalWithKarta'] ?? invoiceAmount;
//   //         final notes = invoice['notes'] ?? '';

//   //         return [
//   //           '${index + 1}',
//   //           createdAt != null
//   //               ? DateFormat('dd/MM/yyyy').format(createdAt)
//   //               : '-',
//   //           invoice['name'] ?? '',
//   //           '${invoiceAmount.toStringAsFixed(2)} ج',
//   //           '${kartaValue.toStringAsFixed(2)} ج',
//   //           '${totalWithKarta.toStringAsFixed(2)} ج',
//   //           location,
//   //           notes.isNotEmpty ? notes : '-',
//   //         ];
//   //       }),
//   //     ],
//   //   );
//   // }

//   // // ================================
//   // // التوقيعات
//   // // ================================
//   // pdfLib.Widget _buildSignatures() {
//   //   return pdfLib.Row(
//   //     mainAxisAlignment: pdfLib.MainAxisAlignment.spaceAround,
//   //     children: [
//   //       _signatureField('توقيع مدير الحسابات'),
//   //       _signatureField('توقيع المحاسب'),
//   //       _signatureField('توقيع المدير'),
//   //     ],
//   //   );
//   // }

//   // pdfLib.Widget _signatureField(String title) {
//   //   return pdfLib.Column(
//   //     children: [
//   //       pdfLib.Container(
//   //         width: 120,
//   //         height: 40,
//   //         decoration: pdfLib.BoxDecoration(
//   //           border: pdfLib.Border.all(color: pdfLib.PdfColors.grey400),
//   //         ),
//   //       ),
//   //       pdfLib.SizedBox(height: 5),
//   //       pdfLib.Text(
//   //         title,
//   //         style: pdfLib.TextStyle(fontSize: 9, color: pdfLib.PdfColors.grey600),
//   //       ),
//   //     ],
//   //   );
//   // }

//   // // ================================
//   // // تحديث حساب الشركة بعد إنشاء الفاتورة
//   // // ================================
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
//     if (!mounted) return;
//     setState(() {
//       _currentSection = section;
//       if (section == 1) {
//         _selectedTripsForInvoice.clear();
//         _invoiceNameController.clear();
//         _invoiceNotesController.clear();
//       }
//     });
//   }

//   void _backToCompanies() {
//     if (!mounted) return;
//     setState(() {
//       _selectedCompany = null;
//       _selectedCompanyId = null;
//       _companyWork.clear();
//       _availableTripsForInvoice.clear();
//       _companyInvoices.clear();
//       _selectedTripsForInvoice.clear();
//       _invoiceNameController.clear();
//       _invoiceNotesController.clear();
//       _hasSyncedOnEnter = false;
//     });
//     _loadCompanies();
//   }

//   Future<void> _printKartaRequest(Map<String, dynamic> invoice) async {
//     if (_arabicFont == null) {
//       await _loadArabicFont();
//     }

//     if (mounted) {
//       setState(() => _isGeneratingPDF = true);
//     }

//     try {
//       final trips =
//           invoice['invoiceTrips'] as List<Map<String, dynamic>>? ?? [];
//       final invoiceName = invoice['name'] ?? '';
//       final companyName = invoice['companyName'] ?? 'غير معروف';
//       final createdAt = invoice['createdAt'] as DateTime?;

//       // استخراج الشهر من تاريخ الفاتورة
//       String monthYear = 'غير محدد';
//       if (createdAt != null) {
//         monthYear = '${createdAt.month}/${createdAt.year}';
//       }

//       // الحصول على الموقع الفعلي (companyLocationName) من الرحلات
//       String companyLocation = '';
//       for (var trip in trips) {
//         final location = trip['companyLocationName']?.toString() ?? '';
//         if (location.isNotEmpty) {
//           companyLocation = location;
//           break;
//         }
//       }

//       // إذا لم يوجد موقع، استخدم 'الموقع' كقيمة افتراضية
//       if (companyLocation.isEmpty) {
//         companyLocation = 'الموقع';
//       }

//       // ترتيب الرحلات حسب التاريخ
//       final List<Map<String, dynamic>> sortedTrips = List.from(trips)
//         ..sort((a, b) {
//           final dateA = a['date'] as DateTime? ?? DateTime(1900);
//           final dateB = b['date'] as DateTime? ?? DateTime(1900);
//           return dateA.compareTo(dateB);
//         });

//       // إنشاء صفوف الجدول - كل رحلة في سطر منفصل
//       final List<Map<String, dynamic>> tableRows = [];
//       double totalKartasValue = 0;
//       int rowNumber = 1;

//       for (var trip in sortedTrips) {
//         final date = trip['date'] as DateTime?;
//         final karta = trip['karta']?.toString() ?? '';
//         final ohda = trip['ohda']?.toString() ?? '';

//         // حساب قيمة الكارتة إذا كانت رقماً
//         double kartaValue = 0;
//         try {
//           final cleanedKarta = karta.trim();
//           if (cleanedKarta.isNotEmpty) {
//             kartaValue = double.tryParse(cleanedKarta) ?? 0;
//           }
//         } catch (e) {
//           debugPrint('خطأ في تحويل الكارتة إلى رقم: $karta');
//         }

//         // جمع القيمة الإجمالية
//         totalKartasValue += kartaValue;

//         // تنسيق التاريخ (يوم/شهر فقط)
//         String formattedDate = '-';
//         if (date != null) {
//           formattedDate = '${date.day}/${date.month}';
//         }
//         if (kartaValue != 0) {
//           tableRows.add({
//             'rowNumber': rowNumber.toString(),
//             'date': formattedDate,
//             'karta': karta,
//             'ohda': ohda,
//             'kartaValue': kartaValue,
//           });

//           rowNumber++;
//         }
//       }

//       final pdf = pdfLib.Document(
//         theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
//       );
//       pdf.addPage(
//         pdfLib.MultiPage(
//           pageFormat: pdfLib.PdfPageFormat.a4,
//           margin: const pdfLib.EdgeInsets.only(right: 60, left: 60),
//           build: (context) => [
//             pdfLib.Directionality(
//               textDirection: pdfLib.TextDirection.rtl,
//               child: pdfLib.Column(
//                 crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
//                 children: [
//                   _kartaRequestHeader(
//                     invoiceName,
//                     monthYear,
//                     companyName,
//                     companyLocation,
//                   ),
//                   pdfLib.SizedBox(height: 20),
//                   _kartaRequestTable(tableRows, totalKartasValue),
//                   pdfLib.SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );

//       await Printing.layoutPdf(
//         name: 'مطالبة كارتات - $invoiceName',
//         onLayout: (_) async => pdf.save(),
//       );

//       _showSuccess('تم طباعة مطالبة الكارتات بنجاح');
//     } catch (e) {
//       _showError('خطأ في طباعة مطالبة الكارتات: $e');
//     } finally {
//       if (mounted) {
//         setState(() => _isGeneratingPDF = false);
//       }
//     }
//   }

//   // ================================
//   // ترويسة مطالبة الكارتات
//   // ================================
//   pdfLib.Widget _kartaRequestHeader(
//     String invoiceName,
//     String monthYear,
//     String companyName,
//     String location,
//   ) {
//     return pdfLib.Column(
//       crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
//       children: [
//         pdfLib.Text(
//           'فاتورة رقم ( $invoiceName )',
//           style: pdfLib.TextStyle(
//             font: _arabicFont,
//             fontSize: 18,
//             fontWeight: pdfLib.FontWeight.bold,
//           ),
//           textAlign: pdfLib.TextAlign.center,
//         ),
//         pdfLib.SizedBox(height: 10),
//         pdfLib.Text(
//           'مطالبة كارتات فاتورة شهر $monthYear م',
//           style: pdfLib.TextStyle(
//             font: _arabicFont,
//             fontSize: 16,
//             fontWeight: pdfLib.FontWeight.bold,
//           ),
//           textAlign: pdfLib.TextAlign.center,
//         ),
//         pdfLib.SizedBox(height: 10),
//         pdfLib.Text(
//           'عن موقع ( $location )( $companyName)',
//           style: pdfLib.TextStyle(font: _arabicFont, fontSize: 14),
//           textAlign: pdfLib.TextAlign.center,
//         ),
//         pdfLib.SizedBox(height: 20),
//       ],
//     );
//   }

//   // ================================
//   // جدول مطالبة الكارتات كما في الصورة
//   // ================================
//   pdfLib.Widget _kartaRequestTable(
//     List<Map<String, dynamic>> rows,
//     double totalKartasValue,
//   ) {
//     return pdfLib.Table(
//       border: pdfLib.TableBorder.all(color: pdfLib.PdfColors.black, width: 1),
//       columnWidths: const {
//         0: pdfLib.FlexColumnWidth(1.5), // المسلسل
//         1: pdfLib.FlexColumnWidth(1), // التاريخ
//         2: pdfLib.FlexColumnWidth(1), // القيمة (الكارتة)
//       },
//       children: [
//         // رأس الجدول كما في الصورة
//         pdfLib.TableRow(
//           decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
//           children: [
//             _kartaTableCell('القيمة', isHeader: true),
//             _kartaTableCell('التاريخ', isHeader: true),
//             _kartaTableCell('المسلسل', isHeader: true),
//           ],
//         ),

//         // صفوف البيانات - كل رحلة في سطر منفصل
//         ...rows.map(
//           (row) => pdfLib.TableRow(
//             children: [
//               _kartaTableCell(row['karta']?.toString() ?? ''),
//               _kartaTableCell(row['date']),
//               _kartaTableCell(row['rowNumber']),
//             ],
//           ),
//         ),

//         // الصف الأخير الإجمالي كما في الصورة
//         pdfLib.TableRow(
//           children: [
//             _kartaTableCell(
//               _formatCurrencyForPDF(totalKartasValue),
//               isTotal: true,
//             ),
//             _kartaTableCell('--', isTotal: true),
//             _kartaTableCell('الإجمالي', isTotal: true),
//           ],
//         ),
//       ],
//     );
//   }

//   // ================================
//   // خلية جدول مطالبة الكارتات
//   // ================================
//   pdfLib.Widget _kartaTableCell(
//     String text, {
//     bool isHeader = false,
//     bool isTotal = false,
//   }) {
//     return pdfLib.Container(
//       padding: const pdfLib.EdgeInsets.all(8),
//       child: pdfLib.Text(
//         text,
//         textAlign: pdfLib.TextAlign.center,
//         style: pdfLib.TextStyle(
//           font: _arabicFont,
//           fontSize: isTotal ? 12 : 10,
//           fontWeight: isHeader || isTotal
//               ? pdfLib.FontWeight.bold
//               : pdfLib.FontWeight.normal,
//         ),
//       ),
//     );
//   }

//   // ================================
//   // دوال الطباعة
//   // ================================
//   Future<void> _printInvoice(Map<String, dynamic> invoice) async {
//     if (_arabicFont == null) {
//       await _loadArabicFont();
//     }

//     if (mounted) {
//       setState(() => _isGeneratingPDF = true);
//     }

//     try {
//       final trips =
//           invoice['invoiceTrips'] as List<Map<String, dynamic>>? ?? [];
//       final invoiceId = invoice['id']?.toString() ?? '623';
//       final createdAt = invoice['createdAt'] as DateTime?;
//       final companyName = invoice['companyName'] ?? ' ';
//       final name = invoice['name'] ?? '';
//       final companyId = invoice['companyId'] ?? _selectedCompanyId;
//       final notes = invoice['notes'] ?? '';
//       final month = invoice['month'] ?? 'غير محدد';
//       final kartaValue = invoice['kartaValue'] ?? 0;
//       final totalWithKarta =
//           invoice['totalWithKarta'] ?? invoice['totalAmount'] ?? 0;

//       // التحقق إذا كانت الشركة تعمل بنظام TR
//       final bool usesTRSystem = companyId != null
//           ? await _getCompanyTRStatus(companyId)
//           : false;

//       final groupedTrips = _groupTripsForInvoice(trips);
//       final location = _getCompanyLocationName(trips);

//       final total = groupedTrips.fold<double>(0.0, (sum, e) {
//         final value = e['total'];
//         if (value is num) {
//           return sum + value.toDouble();
//         }
//         return sum;
//       });

//       final tax = total * 0.14;
//       final afterTax = total + tax;

//       final pdf = pdfLib.Document(
//         theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
//       );

//       pdf.addPage(
//         pdfLib.MultiPage(
//           pageFormat: pdfLib.PdfPageFormat.a4,
//           margin: const pdfLib.EdgeInsets.only(right: 60, left: 60),
//           build: (context) => [
//             pdfLib.Directionality(
//               textDirection: pdfLib.TextDirection.rtl,
//               child: pdfLib.Column(
//                 crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
//                 children: [
//                   _invoiceHeader(
//                     invoiceId,
//                     createdAt,
//                     companyName,
//                     location,
//                     name,
//                     month,
//                     notes,
//                   ),
//                   pdfLib.SizedBox(height: 10),
//                   _invoiceTable(groupedTrips, usesTRSystem),
//                   // pdfLib.SizedBox(height: 10),
//                   _totalsSection(
//                     total,
//                     tax,
//                     afterTax,
//                     kartaValue,
//                     totalWithKarta,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );

//       await Printing.layoutPdf(
//         name: '$name',
//         onLayout: (_) async => pdf.save(),
//       );

//       _showSuccess('تم طباعة الفاتورة بنجاح');
//     } catch (e) {
//       _showError(e.toString());
//     } finally {
//       if (mounted) {
//         setState(() => _isGeneratingPDF = false);
//       }
//     }
//   }

//   pdfLib.Widget _invoiceHeader(
//     String invoiceId,
//     DateTime? date,
//     String company,
//     String location,
//     String name,
//     String month,
//     String notes,
//   ) {
//     return pdfLib.Column(
//       children: [
//         pdfLib.Row(
//           mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
//           children: [
//             pdfLib.Column(
//               crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
//               children: [
//                 pdfLib.Text('شركة نيوجراند لخدمات النقل'),
//                 pdfLib.Text('السادة شركة : $company'),
//                 pdfLib.Text('مذكور للمشروعات'),
//                 pdfLib.Text('موقع : ${location.isNotEmpty ? location : '_ '}'),
//               ],
//             ),
//             pdfLib.Column(
//               children: [
//                 pdfLib.Text(
//                   '$name',
//                   style: pdfLib.TextStyle(
//                     font: _arabicFont,
//                     fontSize: 18,
//                     fontWeight: pdfLib.FontWeight.bold,
//                     decoration: pdfLib.TextDecoration.underline,
//                   ),
//                 ),
//                 pdfLib.Text(
//                   date != null
//                       ? DateFormat('d/M/yyyy').format(date)
//                       : '1/2/2023',
//                   style: pdfLib.TextStyle(font: _arabicFont, fontSize: 11),
//                 ),
//               ],
//             ),
//             // اللوجو الجديد
//             _buildLogoWidget(),
//           ],
//         ),
//         pdfLib.Divider(),
//       ],
//     );
//   }

//   // دالة منفصلة لبناء اللوجو
//   pdfLib.Widget _buildLogoWidget() {
//     if (_logoImageBytes != null) {
//       return pdfLib.Column(
//         children: [
//           pdfLib.Container(
//             width: 55,
//             height: 55,
//             child: pdfLib.Image(
//               pdfLib.MemoryImage(_logoImageBytes!),
//               fit: pdfLib.BoxFit.contain,
//             ),
//           ),
//           pdfLib.SizedBox(height: 4),
//           pdfLib.Text(
//             'New grand',
//             style: pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold),
//           ),
//         ],
//       );
//     } else {
//       return pdfLib.Column(
//         children: [
//           pdfLib.Container(
//             width: 55,
//             height: 55,
//             decoration: pdfLib.BoxDecoration(
//               color: pdfLib.PdfColors.black,
//               shape: pdfLib.BoxShape.circle,
//             ),
//           ),
//           pdfLib.Text(
//             'New grand',
//             style: pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold),
//           ),
//         ],
//       );
//     }
//   }

//   pdfLib.Widget _invoiceTable(
//     List<Map<String, dynamic>> rows,
//     bool usesTRSystem,
//   ) {
//     // تحديد أعمدة الجدول بناءً على نظام TR
//     if (usesTRSystem) {
//       // جدول مع TR (6 أعمدة)
//       return pdfLib.Table(
//         border: pdfLib.TableBorder.all(
//           color: pdfLib.PdfColors.black,
//           width: 1.3,
//         ),
//         columnWidths: const {
//           5: pdfLib.FlexColumnWidth(1.2), // القيمة الإجمالية
//           4: pdfLib.FlexColumnWidth(1), // السعر
//           3: pdfLib.FlexColumnWidth(3), // البيان
//           2: pdfLib.FlexColumnWidth(1), // عدد/طن
//           1: pdfLib.FlexColumnWidth(1), // TR Number
//           0: pdfLib.FlexColumnWidth(1.2), // التاريخ
//         },
//         children: [
//           pdfLib.TableRow(
//             decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
//             children: [
//               _th('القيمة الإجمالية'),
//               _th('السعر'),
//               _th('عدد/طن'),
//               _th('البيان'),
//               _th('TR\nNumber'),
//               _th('التاريخ'),
//             ],
//           ),
//           ...rows.map(
//             (e) => pdfLib.TableRow(
//               children: [
//                 _td(_format(e['total'])),
//                 _td(_format(e['price'])),
//                 _td(e['count'].toString()),
//                 _td(e['description'], right: true),
//                 _td(e['tr']),
//                 _td(e['date']),
//               ],
//             ),
//           ),
//           ...List.generate(
//             17 - rows.length > 0 ? 17 - rows.length : 0,
//             (_) => pdfLib.TableRow(
//               children: List.generate(6, (i) => _td(i == 5 ? '0' : '')),
//             ),
//           ),
//         ],
//       );
//     } else {
//       // جدول بدون TR (5 أعمدة)
//       return pdfLib.Table(
//         border: pdfLib.TableBorder.all(
//           color: pdfLib.PdfColors.black,
//           width: 1.3,
//         ),
//         columnWidths: const {
//           4: pdfLib.FlexColumnWidth(1.2), // القيمة الإجمالية
//           3: pdfLib.FlexColumnWidth(4), // السعر
//           2: pdfLib.FlexColumnWidth(1), // البيان (أوسع بدون TR)
//           1: pdfLib.FlexColumnWidth(1), // عدد/طن
//           0: pdfLib.FlexColumnWidth(1.2), // التاريخ
//         },
//         children: [
//           pdfLib.TableRow(
//             decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
//             children: [
//               _th('القيمة الإجمالية'),
//               _th('السعر'),
//               _th('عدد/طن'),
//               _th('البيان'),
//               _th('التاريخ'),
//             ],
//           ),
//           ...rows.map(
//             (e) => pdfLib.TableRow(
//               children: [
//                 _td(_format(e['total'])),
//                 _td(_format(e['price'])),
//                 _td(e['count'].toString()),
//                 _td(e['description'], right: true),
//                 _td(e['date']),
//               ],
//             ),
//           ),
//           ...List.generate(
//             17 - rows.length > 0 ? 17 - rows.length : 0,
//             (_) => pdfLib.TableRow(
//               children: List.generate(5, (i) => _td(i == 4 ? '0' : '')),
//             ),
//           ),
//         ],
//       );
//     }
//   }

//   pdfLib.Widget _totalsSection(
//     double total,
//     double tax,
//     double afterTax,
//     double kartaValue,
//     double totalWithKarta,
//   ) {
//     return pdfLib.Column(
//       children: [
//         pdfLib.Table(
//           border: pdfLib.TableBorder.all(),
//           columnWidths: const {
//             1: pdfLib.FlexColumnWidth(6),
//             0: pdfLib.FlexColumnWidth(1),
//           },
//           children: [
//             _totalRow('الإجمالي', total),
//             _totalRow('14% ضريبة مبيعات', tax),
//             _totalRow('الإجمالي بعد الضريبة', afterTax),
//             // _totalRow('قيمة الكارتة', kartaValue),
//             // _totalRow('الإجمالي النهائي', totalWithKarta),
//           ],
//         ),
//         pdfLib.SizedBox(height: 5),
//         pdfLib.Align(
//           alignment: pdfLib.Alignment.centerRight,
//           child: pdfLib.Column(
//             crossAxisAlignment: pdfLib.CrossAxisAlignment.end,
//             children: [
//               pdfLib.Text(
//                 'سجل تجاري : $x',
//                 style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
//               ),
//               pdfLib.Text(
//                 'بطاقة ضريبة : $xx',
//                 style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
//               ),
//             ],
//           ),
//         ),
//         pdfLib.Text(
//           'الفاتورة الغير مختومة بختم الشركة لايعتد بها',
//           style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
//         ),
//       ],
//     );
//   }

//   pdfLib.Widget _th(String t) => pdfLib.Padding(
//     padding: const pdfLib.EdgeInsets.all(5),
//     child: pdfLib.Text(
//       t,
//       textAlign: pdfLib.TextAlign.center,
//       style: pdfLib.TextStyle(
//         font: _arabicFont,
//         fontWeight: pdfLib.FontWeight.bold,
//         fontSize: 10,
//       ),
//     ),
//   );

//   pdfLib.Widget _td(String t, {bool right = false}) => pdfLib.Padding(
//     padding: const pdfLib.EdgeInsets.all(5),
//     child: pdfLib.Text(
//       t,
//       textAlign: right ? pdfLib.TextAlign.right : pdfLib.TextAlign.center,
//       style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
//     ),
//   );

//   pdfLib.TableRow _totalRow(String label, double v) {
//     return pdfLib.TableRow(children: [_td(_format(v)), _td(label)]);
//   }

//   String _format(num v) => v.toStringAsFixed(0);

//   String _getCompanyLocationName(List<Map<String, dynamic>> trips) {
//     for (final t in trips) {
//       final l = t['companyLocationName']?.toString() ?? '';
//       if (l.isNotEmpty) return l;
//     }
//     return '';
//   }

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
//       final selectedRoute2 = trip['selectedRoute2']?.toString() ?? '';
//       final vehicleType = trip['vehicleType']?.toString() ?? '';
//       final karta = trip['karta']?.toString() ?? '';

//       final companyLocationName = trip['companyLocationName']?.toString() ?? '';

//       String description = " ";
//       if (companyLocationName.isNotEmpty) {
//         description +=
//             '   تحميل على ${vehicleType} من  ${selectedRoute}  الى  ${selectedRoute2} ';
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
//           'karta': karta,
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
//         // دمج الكارتات
//         if (karta.isNotEmpty &&
//             !(existing['karta'] as String).contains(karta)) {
//           existing['karta'] = '${existing['karta']}، $karta';
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
//           'description': 'مبيت >>>${tripGroup['description']}',
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
//           'description': 'عطلة >>>${tripGroup['description']}',
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
//             /// زر واحد فقط (شركة أو رجوع)
//             IconButton(
//               icon: Icon(
//                 _selectedCompany == null ? Icons.business : Icons.arrow_back,
//                 color: Colors.white,
//                 size: 28,
//               ),
//               onPressed: _selectedCompany != null ? _backToCompanies : null,
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

//     // ترتيب الرحلات من الأقدم إلى الأحدث
//     final sortedWork = List<Map<String, dynamic>>.from(_companyWork)
//       ..sort((a, b) {
//         final dateA = a['date'] as DateTime? ?? DateTime(1900);
//         final dateB = b['date'] as DateTime? ?? DateTime(1900);
//         return dateA.compareTo(dateB);
//       });

//     return Column(
//       children: [
//         Expanded(
//           child: Container(
//             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
//             child: sortedWork.isEmpty
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
//                         defaultColumnWidth: const FixedColumnWidth(89),
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
//                           ...sortedWork.asMap().entries.map((entry) {
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

//               // الملاحظات (اختياري)
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: TextField(
//                   controller: _invoiceNotesController,
//                   decoration: InputDecoration(
//                     labelText: 'ملاحظات (اختياري)',
//                     prefixIcon: const Icon(Icons.note),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                   maxLines: 2,
//                 ),
//               ),

//               // شهر الإدراج
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 8,
//                 ),
//                 child: DropdownButtonFormField<String>(
//                   value: _selectedMonth,
//                   decoration: InputDecoration(
//                     labelText: 'شهر الإدراج',
//                     prefixIcon: const Icon(Icons.calendar_month),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     filled: true,
//                     fillColor: Colors.white,
//                   ),
//                   items: _monthsList.map((String month) {
//                     return DropdownMenuItem<String>(
//                       value: month,
//                       child: Text(month),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue) {
//                     if (newValue != null) {
//                       setState(() {
//                         _selectedMonth = newValue;
//                       });
//                     }
//                   },
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
//                         defaultColumnWidth: const FixedColumnWidth(89),
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

//     final notCollectedInvoices = _getFilteredInvoices(false);
//     final collectedInvoices = _getFilteredInvoices(true);

//     return Column(
//       children: [
//         // فلترة الفواتير
//         Container(
//           padding: const EdgeInsets.all(16),
//           color: Colors.blue[50],
//           child: Column(
//             children: [
//               // فلترة حسب الشهر
//               Row(
//                 children: [
//                   const Icon(Icons.filter_alt, color: Color(0xFF3498DB)),
//                   const SizedBox(width: 8),
//                   const Text(
//                     'فلترة حسب الشهر:',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF3498DB),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Container(
//                     width: 100,
//                     child: Expanded(
//                       child: DropdownButton<String>(
//                         value: _selectedMonthFilter,
//                         isExpanded: true,
//                         items: _monthsList.map((String month) {
//                           return DropdownMenuItem<String>(
//                             value: month,
//                             child: Text(month),
//                           );
//                         }).toList(),
//                         onChanged: (String? newValue) {
//                           if (newValue != null) {
//                             setState(() {
//                               _selectedMonthFilter = newValue;
//                             });
//                           }
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 12),

//               // تبويب عرض الفواتير (مثل مقاولين الفواتير)
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.grey[300]!),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: InkWell(
//                         onTap: () {
//                           setState(() {
//                             _currentInvoiceView = 0;
//                           });
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           decoration: BoxDecoration(
//                             color: _currentInvoiceView == 0
//                                 ? Color(0xFF27AE60)
//                                 : Colors.white,
//                             borderRadius: const BorderRadius.horizontal(
//                               right: Radius.circular(8),
//                             ),
//                           ),
//                           child: Column(
//                             children: [
//                               Icon(
//                                 Icons.money_off,
//                                 color: _currentInvoiceView == 0
//                                     ? Colors.white
//                                     : Colors.grey,
//                               ),
//                               Text(
//                                 'غير المحصلة (${notCollectedInvoices.length})',
//                                 style: TextStyle(
//                                   color: _currentInvoiceView == 0
//                                       ? Colors.white
//                                       : Colors.grey,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     Container(width: 1, height: 40, color: Colors.grey[300]),
//                     Expanded(
//                       child: InkWell(
//                         onTap: () {
//                           setState(() {
//                             _currentInvoiceView = 1;
//                           });
//                         },
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                           decoration: BoxDecoration(
//                             color: _currentInvoiceView == 1
//                                 ? Color(0xFF3498DB)
//                                 : Colors.white,
//                             borderRadius: const BorderRadius.horizontal(
//                               left: Radius.circular(8),
//                             ),
//                           ),
//                           child: Column(
//                             children: [
//                               Icon(
//                                 Icons.check_circle,
//                                 color: _currentInvoiceView == 1
//                                     ? Colors.white
//                                     : Colors.grey,
//                               ),
//                               Text(
//                                 'المحصلة (${collectedInvoices.length})',
//                                 style: TextStyle(
//                                   color: _currentInvoiceView == 1
//                                       ? Colors.white
//                                       : Colors.grey,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 12),

//               // أزرار طباعة جميع فواتير الشهر
//               Row(
//                 children: [
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: _isGeneratingPDF
//                           ? null
//                           : () => _printMonthInvoices(false),
//                       icon: _isGeneratingPDF
//                           ? const SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                               ),
//                             )
//                           : const Icon(Icons.print),
//                       label: const Text('طباعة فواتير الشهر غير المحصلة'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.orange,
//                         foregroundColor: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: _isGeneratingPDF
//                           ? null
//                           : () => _printMonthInvoices(true),
//                       icon: _isGeneratingPDF
//                           ? const SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 color: Colors.white,
//                               ),
//                             )
//                           : const Icon(Icons.print),
//                       label: const Text('طباعة فواتير الشهر المحصلة'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         foregroundColor: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),

//         // تعداد الفواتير
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 _currentInvoiceView == 0
//                     ? 'عدد الفواتير غير المحصلة: ${notCollectedInvoices.length}'
//                     : 'عدد الفواتير المحصلة: ${collectedInvoices.length}',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2C3E50),
//                 ),
//               ),
//               Text(
//                 'شهر: $_selectedMonthFilter',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF3498DB),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         Expanded(
//           child: _currentInvoiceView == 0
//               ? _buildInvoicesList(notCollectedInvoices, false)
//               : _buildInvoicesList(collectedInvoices, true),
//         ),
//       ],
//     );
//   }

//   Widget _buildInvoicesList(
//     List<Map<String, dynamic>> invoices,
//     bool isCollected,
//   ) {
//     if (invoices.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               isCollected ? Icons.check_circle : Icons.money_off,
//               size: 60,
//               color: Colors.grey,
//             ),
//             const SizedBox(height: 16),
//             Text(
//               isCollected
//                   ? 'لا توجد فواتير محصلة للشهر المحدد'
//                   : 'لا توجد فواتير غير محصلة للشهر المحدد',
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(8),
//       itemCount: invoices.length,
//       itemBuilder: (context, index) {
//         final invoice = invoices[index];
//         return _buildInvoiceCard(invoice, index, isCollected);
//       },
//     );
//   }

//   Widget _buildInvoiceCard(
//     Map<String, dynamic> invoice,
//     int index,
//     bool isCollected,
//   ) {
//     final createdAt = invoice['createdAt'] as DateTime?;
//     final collectedAt = invoice['collectedAt'] as DateTime?;
//     final invoiceTrips = invoice['invoiceTrips'] as List<Map<String, dynamic>>;
//     final month = invoice['month'] ?? 'غير محدد';
//     final notes = invoice['notes'] ?? '';
//     final kartaValue = invoice['kartaValue'] ?? 0;
//     final totalWithKarta =
//         invoice['totalWithKarta'] ?? invoice['totalAmount'] ?? 0;

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
//       decoration: BoxDecoration(
//         color: isCollected ? Colors.green[50] : Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: isCollected ? Colors.green : Colors.grey[300]!,
//           width: isCollected ? 2 : 1,
//         ),
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
//           backgroundColor: isCollected ? Colors.green : const Color(0xFF3498DB),
//           child: Text(
//             '${index + 1}',
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         title: Row(
//           children: [
//             Text(
//               invoice['name'],
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//                 color: isCollected
//                     ? Colors.green[800]
//                     : const Color(0xFF2C3E50),
//               ),
//             ),
//             const SizedBox(width: 8),
//             if (isCollected)
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: Colors.green,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: const Text(
//                   'محصلة',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 10,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '${createdAt != null ? _formatDate(createdAt) : 'غير معروف'}  ---  رحلة >>> ${invoice['tripCount']}',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: isCollected ? Colors.green[600] : Colors.grey,
//               ),
//             ),
//             if (month.isNotEmpty)
//               Text(
//                 'شهر: $month',
//                 style: TextStyle(
//                   fontSize: 12,
//                   color: isCollected ? Colors.green[600] : Colors.grey,
//                 ),
//               ),
//             if (notes.isNotEmpty)
//               Text(
//                 'ملاحظات: $notes',
//                 style: const TextStyle(
//                   fontSize: 11,
//                   color: Colors.grey,
//                   fontStyle: FontStyle.italic,
//                 ),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             if (isCollected && collectedAt != null)
//               Text(
//                 'تاريخ التحصيل: ${_formatDate(collectedAt)}',
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: Colors.green[700],
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//           ],
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   _formatCurrency(invoice['totalAmount'] ?? 0),
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: isCollected
//                         ? Colors.green[800]
//                         : const Color(0xFF2E7D32),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'إجمالي',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: isCollected ? Colors.green[600] : Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(width: 10),

//             // زر تغيير حالة التحصيل
//             IconButton(
//               icon: Icon(
//                 isCollected ? Icons.undo : Icons.check_circle,
//                 color: isCollected ? Colors.orange : Colors.green,
//               ),
//               onPressed: () =>
//                   _toggleInvoiceCollection(invoice['id'], !isCollected),
//               tooltip: isCollected ? 'إلغاء التحصيل' : 'تم التحصيل',
//             ),

//             // زر مطالبة الكارتات
//             IconButton(
//               icon: Icon(Icons.credit_card, color: Color(0xFF9C27B0)),
//               onPressed: _isGeneratingPDF
//                   ? null
//                   : () => _printKartaRequest(invoice),
//               tooltip: 'مطالبة كارتات',
//             ),
//             const SizedBox(width: 5),
//             // زر طباعة الفاتورة
//             IconButton(
//               icon: Icon(Icons.print, color: Color(0xFF3498DB)),
//               onPressed: _isGeneratingPDF ? null : () => _printInvoice(invoice),
//               tooltip: 'طباعة الفاتورة',
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
//                     color: isCollected ? Colors.green[50] : Colors.blue[50],
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'حالة التحصيل:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             isCollected ? 'محصلة' : 'غير محصلة',
//                             style: TextStyle(
//                               color: isCollected ? Colors.green : Colors.red,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'شهر الإدراج:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(month),
//                         ],
//                       ),
//                       if (notes.isNotEmpty) ...[
//                         const SizedBox(height: 4),
//                         Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               'ملاحظات:',
//                               style: TextStyle(fontWeight: FontWeight.bold),
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(child: Text(notes)),
//                           ],
//                         ),
//                       ],
//                       const SizedBox(height: 4),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'عدد الرحلات:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text('${invoice['tripCount']}'),
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
//                             _formatCurrency(invoice['nolonTotal'] ?? 0),
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
//                             _formatCurrency(invoice['overnightTotal'] ?? 0),
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
//                             _formatCurrency(invoice['holidayTotal'] ?? 0),
//                             style: const TextStyle(color: Colors.red),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'قيمة الكارتة:',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF9C27B0),
//                             ),
//                           ),
//                           Text(
//                             _formatCurrency(kartaValue),
//                             style: const TextStyle(color: Color(0xFF9C27B0)),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'الإجمالي النهائي:',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF2E7D32),
//                             ),
//                           ),
//                           Text(
//                             _formatCurrency(totalWithKarta),
//                             style: const TextStyle(
//                               color: Color(0xFF2E7D32),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 12),

//                 // أزرار التحكم
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: () => _toggleInvoiceCollection(
//                           invoice['id'],
//                           !isCollected,
//                         ),
//                         icon: Icon(
//                           isCollected ? Icons.undo : Icons.check_circle,
//                         ),
//                         label: Text(
//                           isCollected ? 'إلغاء التحصيل' : 'تم التحصيل',
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: isCollected
//                               ? Colors.orange
//                               : Colors.green,
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: _isGeneratingPDF
//                             ? null
//                             : () => _printKartaRequest(invoice),
//                         icon: _isGeneratingPDF
//                             ? const SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                 ),
//                               )
//                             : const Icon(Icons.credit_card),
//                         label: Text(
//                           _isGeneratingPDF
//                               ? 'جاري الطباعة...'
//                               : 'مطالبة كارتات',
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Color(0xFF9C27B0),
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         onPressed: _isGeneratingPDF
//                             ? null
//                             : () => _printInvoice(invoice),
//                         icon: _isGeneratingPDF
//                             ? const SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                 ),
//                               )
//                             : const Icon(Icons.print),
//                         label: Text(
//                           _isGeneratingPDF
//                               ? 'جاري الطباعة...'
//                               : 'طباعة الفاتورة',
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Color(0xFF2E7D32),
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 12),
//                         ),
//                       ),
//                     ),
//                   ],
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
//                             TableCellHeader('الكارتة'),
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
//                                 _formatCurrency(trip['nolon'] ?? 0),
//                                 textStyle: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green,
//                                 ),
//                               ),
//                               TableCellBody(
//                                 _formatCurrency(trip['companyOvernight'] ?? 0),
//                                 textStyle: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.orange,
//                                 ),
//                               ),
//                               TableCellBody(
//                                 _formatCurrency(trip['companyHoliday'] ?? 0),
//                                 textStyle: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.red,
//                                 ),
//                               ),
//                               TableCellBody(
//                                 trip['karta'] ?? '',
//                                 textStyle: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF9C27B0),
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
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart' as pdfLib;
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;

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
  final TextEditingController _invoiceNotesController = TextEditingController();
  String _selectedMonth = 'كل الشهور'; // اختيار شهر الإدراج
  List<String> _monthsList = [
    // 'كل الشهور',
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];
  bool _isCreatingInvoice = false;
  bool _isGeneratingPDF = false;

  // متغيرات قسم الفواتير

  // متغيرات قسم الفواتير
  String _selectedMonthFilter = 'كل الشهور'; // فلترة حسب الشهر
  String _selectedYearFilter = DateTime.now().year
      .toString(); // فلترة حسب السنة الجديدة
  bool _showCollected = false; // إظهار الفواتير المحصلة
  bool _showNotCollected = true; // إظهار الفواتير غير المحصلة
  int _currentInvoiceView =
      0; // 0: غير المحصلة، 1: المحصلة // 0: غير المحصلة، 1: المحصلة

  // متغير للمزامنة التلقائية
  bool _hasSyncedOnEnter = false;

  // أضف هذا المتغير في بداية الكلاس
  Uint8List? _logoImageBytes;

  String x = '';
  String xx = '';

  // فلترة الشهر والسنة
  String _selectedYear = DateTime.now().year.toString();
  String _selectedMonthWork = 'كل الشهور'; // للتمييز عن _selectedMonth
  String _selectedFilterMonth = 'كل الشهور'; // للفلترة
  List<String> _yearsList = [];

  @override
  void initState() {
    super.initState();
    _loadCompanies();
    _loadArabicFont();
    _loadLogoImage();
    // تعيين الشهر الحالي كقيمة افتراضية
    final now = DateTime.now();

    _selectedMonth = _monthsList[now.month - 1]; // -1 لأن المؤشر يبدأ من 0
    _selectedMonthFilter = _monthsList[now.month - 1];
    _selectedMonthWork = _monthsList[now.month - 1];
    _selectedYearFilter = now.year.toString(); // السنة الحالية كقيمة افتراضية
    // شهر العمل الحالي
    // شهر العمل الحالي

    // إنشاء قائمة السنوات (من 2020 إلى السنة الحالية + 1)
    int currentYear = now.year;
    for (int year = 2025; year <= currentYear + 1; year++) {
      _yearsList.add(year.toString());
    }
  }

  @override
  void dispose() {
    _invoiceNameController.dispose();
    _invoiceNotesController.dispose();
    super.dispose();
  }

  // ================================
  // تحميل صورة اللوجو
  // ================================
  Future<void> _loadLogoImage() async {
    try {
      final ByteData data = await rootBundle.load('assets/image/logoo.jpeg');
      if (mounted) {
        setState(() {
          _logoImageBytes = data.buffer.asUint8List();
        });
      }
      debugPrint('تم تحميل صورة اللوجو بنجاح');
    } catch (e) {
      debugPrint('فشل تحميل صورة اللوجو: $e');
    }
  }

  // ================================
  // تحميل الخط العربي للطباعة
  // ================================
  Future<void> _loadArabicFont() async {
    try {
      final fontData = await rootBundle.load(
        'assets/fonts/Amiri/Amiri-Regular.ttf',
      );

      if (mounted) {
        setState(() {
          _arabicFont = pdfLib.Font.ttf(fontData);
        });
      }
      debugPrint('تم تحميل الخط العربي بنجاح');
    } catch (e) {
      debugPrint('فشل تحميل الخط العربي: $e');
      if (mounted) {
        setState(() {
          _arabicFont = pdfLib.Font.courier();
        });
      }
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
    if (mounted) {
      setState(() => _isLoading = true);
    }
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

      if (mounted) {
        setState(() {
          _allCompanies = companiesList;
          _filteredCompanies = _applySearchFilter(companiesList);
          _isLoading = false;
        });
      }

      // تحديث تلقائي عند دخول الصفحة الرئيسية فقط
      if (!_hasSyncedOnEnter && _selectedCompany == null) {
        await _syncDataOnPageEnter();
        _hasSyncedOnEnter = true;
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('خطأ في تحميل بيانات الشركات: $e');
      _showError('خطأ في تحميل الشركات: $e');
    }
  }

  // ================================
  // تحميل بيانات الشركة المختارة
  // ================================
  Future<void> _loadCompanyData(String companyName, String companyId) async {
    if (mounted) {
      setState(() {
        _selectedCompany = companyName;
        _selectedCompanyId = companyId;
        _isLoading = true;
        _companyWork.clear();
        _availableTripsForInvoice.clear();
        _companyInvoices.clear();
        _selectedTripsForInvoice.clear();
        _invoiceNameController.clear();
        _invoiceNotesController.clear();
      });
    }

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
          'karta': data['karta'] ?? '', // تخزين الكارتة
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
        double totalKartaValue = 0;

        for (var tripId in tripIds) {
          final tripDoc = await _firestore
              .collection('dailyWork')
              .doc(tripId.toString())
              .get();
          if (tripDoc.exists) {
            final tripData = tripDoc.data() as Map<String, dynamic>;
            final karta = tripData['karta']?.toString() ?? '';
            double kartaValue = 0;

            try {
              final cleanedKarta = karta.trim();
              if (cleanedKarta.isNotEmpty) {
                kartaValue = double.tryParse(cleanedKarta) ?? 0;
              }
            } catch (e) {
              debugPrint('خطأ في تحويل الكارتة إلى رقم: $karta');
            }

            totalKartaValue += kartaValue;

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
              'date': (tripData['date'] as Timestamp?)?.toDate(),
              'karta': karta,
              'kartaValue': kartaValue,
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
          'companyId': data['companyId'] ?? companyId,
          'totalAmount': (data['totalAmount'] ?? 0).toDouble(),
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
          'tripIds': tripIds,
          'tripCount': tripIds.length,
          'invoiceTrips': invoiceTrips,
          'nolonTotal': totalNolon,
          'overnightTotal': totalOvernight,
          'holidayTotal': totalHoliday,
          'kartaDetails': invoiceTrips.map((trip) => trip['karta']).toList(),
          'kartaValue': totalKartaValue,
          'totalWithKarta':
              (data['totalAmount'] ?? 0).toDouble() + totalKartaValue,
          'notes': data['notes'] ?? '', // ملاحظات الفاتورة
          'month': data['month'] ?? 'غير محدد', // شهر الإدراج
          'isCollected': data['isCollected'] ?? false, // حالة التحصيل
          'collectedAt': (data['collectedAt'] as Timestamp?)?.toDate(),
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

      if (mounted) {
        setState(() {
          _companyWork = allTrips;
          _availableTripsForInvoice = sortedAvailableTrips;
          _companyInvoices = invoicesList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      _showError('خطأ في تحميل بيانات الشركة: $e');
    }
  }

  // ================================
  // الحصول على حالة نظام TR للشركة
  // ================================
  Future<bool> _getCompanyTRStatus(String companyId) async {
    try {
      final companyDoc = await _firestore
          .collection('companies')
          .doc(companyId)
          .get();
      if (companyDoc.exists) {
        final data = companyDoc.data() as Map<String, dynamic>;
        x = data['commercialRegister'];
        xx = data['taxCard'];

        return data['usesTRSystem'] ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('خطأ في جلب حالة TR: $e');
      return false;
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
  // فلترة الفواتير حسب الشهر وحالة التحصيل
  // ================================
  // ================================
  // فلترة الفواتير حسب الشهر والسنة وحالة التحصيل
  // ================================
  List<Map<String, dynamic>> _getFilteredInvoices(bool collected) {
    List<Map<String, dynamic>> filtered = _companyInvoices.where((invoice) {
      return invoice['isCollected'] == collected;
    }).toList();

    // فلترة حسب الشهر
    if (_selectedMonthFilter != 'كل الشهور') {
      filtered = filtered.where((invoice) {
        final month = invoice['month'] ?? 'غير محدد';
        return month == _selectedMonthFilter;
      }).toList();
    }

    // فلترة حسب السنة (الجديدة)
    filtered = filtered.where((invoice) {
      final createdAt = invoice['createdAt'] as DateTime?;
      if (createdAt == null) return false;

      return createdAt.year.toString() == _selectedYearFilter;
    }).toList();

    return filtered;
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
  // فلترة الرحلات حسب الشهر والسنة
  // ================================
  // ================================
  // فلترة الرحلات حسب الشهر والسنة
  // ================================
  // ================================
  // فلترة الرحلات حسب الشهر والسنة
  // ================================
  List<Map<String, dynamic>> _getFilteredTrips(
    List<Map<String, dynamic>> trips,
  ) {
    return trips.where((trip) {
      final date = trip['date'] as DateTime?;
      if (date == null) return false;

      bool matchesYear = true;
      bool matchesMonth = true;

      // فلترة السنة
      if (_selectedYear != null) {
        matchesYear = date.year.toString() == _selectedYear;
      }

      // فلترة الشهر - تحويل اسم الشهر إلى رقمه الصحيح
      if (_selectedMonthWork != null) {
        final monthIndex = _monthsList.indexOf(_selectedMonthWork);
        if (monthIndex != -1) {
          matchesMonth =
              date.month == (monthIndex + 1); // +1 لأن القائمة تبدأ من 0
        }
      }

      return matchesYear && matchesMonth;
    }).toList();
  }

  // ================================
  // دوال قسم إنشاء الفاتورة
  // ================================
  void _toggleTripSelection(Map<String, dynamic> trip, bool selected) {
    if (!mounted) return;
    setState(() {
      if (selected) {
        _selectedTripsForInvoice.add(trip);
      } else {
        _selectedTripsForInvoice.removeWhere((t) => t['id'] == trip['id']);
      }
    });
  }

  void _selectAllTrips(bool select) {
    if (!mounted) return;
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

    if (mounted) {
      setState(() => _isCreatingInvoice = true);
    }

    try {
      // حساب إجمالي المبالغ
      double totalNolon = 0;
      double totalOvernight = 0;
      double totalHoliday = 0;
      double totalKartaValue = 0;
      List<String> tripIds = [];
      List<Map<String, dynamic>> invoiceTripDetails = [];

      for (var trip in _selectedTripsForInvoice) {
        totalNolon += trip['nolon'];
        totalOvernight += trip['companyOvernight'];
        totalHoliday += trip['companyHoliday'];
        tripIds.add(trip['id']);

        // حساب قيمة الكارتة
        final karta = trip['karta']?.toString() ?? '';
        double kartaValue = 0;
        try {
          final cleanedKarta = karta.trim();
          if (cleanedKarta.isNotEmpty) {
            kartaValue = double.tryParse(cleanedKarta) ?? 0;
          }
        } catch (e) {
          debugPrint('خطأ في تحويل الكارتة إلى رقم: $karta');
        }
        totalKartaValue += kartaValue;

        // تخزين تفاصيل الرحلة بما فيها الكارتة
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
          'karta': karta,
          'kartaValue': kartaValue,
        });
      }

      double totalAmount = totalNolon + totalOvernight + totalHoliday;

      // حفظ الفاتورة مع الكارتات
      await _firestore.collection('invoices').add({
        'name': _invoiceNameController.text.trim(),
        'companyName': _selectedCompany!,
        'companyId': _selectedCompanyId!,
        'totalAmount': totalAmount,
        'nolonTotal': totalNolon,
        'overnightTotal': totalOvernight,
        'holidayTotal': totalHoliday,
        'kartaValue': totalKartaValue,
        'totalWithKarta': totalAmount + totalKartaValue,
        'tripIds': tripIds,
        'tripDetails': invoiceTripDetails,
        'tripCount': tripIds.length,
        'kartaDetails': _selectedTripsForInvoice
            .map((trip) => trip['karta'] ?? '')
            .toList(),
        'notes': _invoiceNotesController.text.trim(), // ملاحظات الفاتورة
        'month': _selectedMonth, // شهر الإدراج
        'isCollected': false, // حالة التحصيل (افتراضيًا غير محصلة)
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
      if (mounted) {
        setState(() {
          _selectedTripsForInvoice.clear();
          _invoiceNameController.clear();
          _invoiceNotesController.clear();
        });
      }

      // الذهاب إلى قسم الفواتير
      _changeSection(2);
    } catch (e) {
      _showError('خطأ في إنشاء الفاتورة: $e');
    } finally {
      if (mounted) {
        setState(() => _isCreatingInvoice = false);
      }
    }
  }

  // ================================
  // تحديث حالة تحصيل الفاتورة
  // ================================
  Future<void> _toggleInvoiceCollection(
    String invoiceId,
    bool isCollected,
  ) async {
    try {
      await _firestore.collection('invoices').doc(invoiceId).update({
        'isCollected': isCollected,
        'collectedAt': isCollected ? Timestamp.now() : null,
        'collectedDate': isCollected
            ? DateFormat('dd/MM/yyyy').format(DateTime.now())
            : null,
      });

      // إعادة تحميل بيانات الشركة
      await _loadCompanyData(_selectedCompany!, _selectedCompanyId!);

      _showSuccess(
        isCollected ? 'تم تحديد الفاتورة كمحصلة' : 'تم إلغاء تحصيل الفاتورة',
      );
    } catch (e) {
      _showError('خطأ في تحديث حالة الفاتورة: $e');
    }
  }

  // ================================
  // طباعة جميع فواتير الشهر (محصلة أو غير محصلة)
  // ================================
  Future<void> _printMonthInvoices(bool collected) async {
    if (_arabicFont == null) {
      await _loadArabicFont();
    }

    if (mounted) {
      setState(() => _isGeneratingPDF = true);
    }

    try {
      // الحصول على الفواتير المفلترة
      final invoices = _getFilteredInvoices(collected);

      if (invoices.isEmpty) {
        _showError(
          'لا توجد فواتير ${collected ? 'محصلة' : 'غير محصلة'} للشهر المحدد',
        );
        return;
      }

      // حساب المجاميع
      double totalInvoices = 0;
      double totalKarta = 0;
      double totalWithKarta = 0;

      for (var invoice in invoices) {
        totalInvoices += invoice['totalAmount'] ?? 0;
        totalKarta += invoice['kartaValue'] ?? 0;
        totalWithKarta += invoice['totalWithKarta'] ?? 0;
      }

      // إنشاء PDF بتصميم مشابه لطباعة السائقين
      final pdf = pdfLib.Document(
        theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
      );

      pdf.addPage(
        pdfLib.MultiPage(
          pageFormat: pdfLib.PdfPageFormat.a4,
          margin: pdfLib.EdgeInsets.all(20),
          build: (context) => [
            // العنوان الرئيسي
            pdfLib.Directionality(
              textDirection: pdfLib.TextDirection.rtl,
              child: pdfLib.Column(
                children: [
                  pdfLib.Row(
                    mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
                    children: [
                      pdfLib.Text(
                        'تقرير فواتير الشركات',
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
                  pdfLib.Divider(color: PdfColors.black, thickness: 1),
                ],
              ),
            ),
            pdfLib.SizedBox(height: 10),

            // معلومات التقرير
            _buildReportInfoPdf(
              collected,
              invoices.length,
              totalInvoices,
              totalKarta,
              totalWithKarta,
            ),
            pdfLib.SizedBox(height: 15),

            // الجدول
            _buildInvoicesTablePdf(invoices),
            pdfLib.SizedBox(height: 10),

            // الملخص
            _buildInvoiceSummaryPdf(
              collected,
              invoices.length,
              totalInvoices,
              totalKarta,
              totalWithKarta,
            ),
          ],
        ),
      );

      // طباعة PDF
      await Printing.layoutPdf(
        onLayout: (pdfLib.PdfPageFormat format) async => pdf.save(),
        name: _getInvoicePDFFileName(collected),
      );

      _showSuccess('تم طباعة ${invoices.length} فاتورة بنجاح');
    } catch (e) {
      _showError('حدث خطأ في إنشاء PDF: $e');
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPDF = false);
      }
    }
  }

  // بناء معلومات التقرير للPDF
  // بناء معلومات التقرير للPDF
  pdfLib.Widget _buildReportInfoPdf(
    bool collected,
    int invoiceCount,
    double totalInvoices,
    double totalKarta,
    double totalWithKarta,
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
            // اسم الشركة ونوع الفواتير في نفس السطر
            pdfLib.Row(
              mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
              children: [
                pdfLib.Text(
                  'الشركة: $_selectedCompany',
                  style: pdfLib.TextStyle(
                    fontSize: 12,
                    fontWeight: pdfLib.FontWeight.bold,
                    font: _arabicFont,
                    color: PdfColors.black,
                  ),
                ),
                pdfLib.Text(
                  'الفواتير: ${collected ? 'محصلة' : 'غير محصلة'}',
                  style: pdfLib.TextStyle(
                    fontSize: 10,
                    font: _arabicFont,
                    color: collected ? PdfColors.green : PdfColors.red,
                  ),
                ),
              ],
            ),
            pdfLib.SizedBox(height: 4),

            // الشهر والسنة وعدد الفواتير
            pdfLib.Row(
              mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
              children: [
                pdfLib.Text(
                  'الشهر: $_selectedMonthFilter',
                  style: pdfLib.TextStyle(
                    fontSize: 11,
                    fontWeight: pdfLib.FontWeight.bold,
                    font: _arabicFont,
                    color: PdfColors.blue,
                  ),
                ),
                pdfLib.Text(
                  'السنة: $_selectedYearFilter',
                  style: pdfLib.TextStyle(
                    fontSize: 11,
                    fontWeight: pdfLib.FontWeight.bold,
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
                  'عدد الفواتير: $invoiceCount',
                  style: pdfLib.TextStyle(
                    fontSize: 10,
                    font: _arabicFont,
                    color: PdfColors.blue,
                  ),
                ),
                pdfLib.Text(
                  'التاريخ: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                  style: pdfLib.TextStyle(
                    fontSize: 9,
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
  pdfLib.Widget _buildInvoicesTablePdf(List<Map<String, dynamic>> invoices) {
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
        cellAlignments: {
          0: pdfLib.Alignment.center,
          1: pdfLib.Alignment.center,
          2: pdfLib.Alignment.center,
          3: pdfLib.Alignment.center,
          4: pdfLib.Alignment.center,
          5: pdfLib.Alignment.center,
          6: pdfLib.Alignment.center,
          7: pdfLib.Alignment.center,
        },
        columnWidths: {
          7: pdfLib.FlexColumnWidth(0.4),
          6: pdfLib.FlexColumnWidth(1.0),
          5: pdfLib.FlexColumnWidth(1.5),
          4: pdfLib.FlexColumnWidth(0.8),
          3: pdfLib.FlexColumnWidth(0.8),
          2: pdfLib.FlexColumnWidth(0.8),
          1: pdfLib.FlexColumnWidth(1.2),
          0: pdfLib.FlexColumnWidth(1.5),
        },
        headers: [
          'الملاحظات',
          'الموقع',
          'الإجمالي',
          'قيمة الكارتة',
          'قيمة الفاتورة',
          'اسم الفاتورة',
          'تاريخ التقديم',
          'م',
        ],
        data: List<List<String>>.generate(invoices.length, (index) {
          final invoice = invoices[index];
          final createdAt = invoice['createdAt'] as DateTime?;
          final location = _getCompanyLocationName(
            invoice['invoiceTrips'] ?? [],
          );
          final invoiceAmount = invoice['totalAmount'] ?? 0;
          final kartaValue = invoice['kartaValue'] ?? 0;
          final totalWithKarta = invoice['totalWithKarta'] ?? invoiceAmount;
          final notes = invoice['notes'] ?? '';

          return [
            notes.isNotEmpty ? notes : '-',
            location,
            totalWithKarta.toStringAsFixed(2),
            kartaValue.toStringAsFixed(2),
            invoiceAmount.toStringAsFixed(2),
            invoice['name'] ?? '',
            createdAt != null ? DateFormat('dd/MM/yy').format(createdAt) : '-',
            (index + 1).toString(),
          ];
        }),
      ),
    );
  }

  // بناء ملخص الإجماليات للPDF
  pdfLib.Widget _buildInvoiceSummaryPdf(
    bool collected,

    int invoiceCount,

    double totalInvoices,
    double totalKarta,
    double totalWithKarta,
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
                fontSize: 12,
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
                  'عدد الفواتير: $invoiceCount',
                  style: pdfLib.TextStyle(
                    fontSize: 10,
                    font: _arabicFont,
                    color: PdfColors.black,
                  ),
                ),
                pdfLib.Text(
                  'إجمالي الفواتير: ${totalInvoices.toStringAsFixed(2)} ج',
                  style: pdfLib.TextStyle(
                    fontSize: 10,
                    font: _arabicFont,
                    color: PdfColors.blue,
                  ),
                ),
              ],
            ),
            pdfLib.SizedBox(height: 3),
            pdfLib.Row(
              mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
              children: [
                pdfLib.Text(
                  'إجمالي الكارتات: ${totalKarta.toStringAsFixed(2)} ج',
                  style: pdfLib.TextStyle(
                    fontSize: 10,
                    font: _arabicFont,
                    color: PdfColors.green,
                  ),
                ),
                pdfLib.Text(
                  'إجمالي النهائي: ${totalWithKarta.toStringAsFixed(2)} ج',
                  style: pdfLib.TextStyle(
                    fontSize: 10,
                    font: _arabicFont,
                    color: PdfColors.red,
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
                  'إجمالي المبلغ المستحق:',
                  style: pdfLib.TextStyle(
                    fontSize: 12,
                    fontWeight: pdfLib.FontWeight.bold,
                    font: _arabicFont,
                    color: PdfColors.black,
                  ),
                ),
                pdfLib.Text(
                  '${collected ? '0' : totalWithKarta.toStringAsFixed(2)} ج',
                  style: pdfLib.TextStyle(
                    fontSize: 12,
                    fontWeight: pdfLib.FontWeight.bold,
                    font: _arabicFont,
                    color: PdfColors.red,
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
  String _getInvoicePDFFileName(bool collected) {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyyMMdd').format(now);
    return 'فواتير_${_selectedCompany}_${collected ? 'محصلة' : 'غير_محصلة'}_$formattedDate';
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
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text(message), backgroundColor: Colors.red),
    // );
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
    if (!mounted) return;
    setState(() {
      _currentSection = section;
      if (section == 1) {
        _selectedTripsForInvoice.clear();
        _invoiceNameController.clear();
        _invoiceNotesController.clear();
      }
    });
  }

  void _backToCompanies() {
    if (!mounted) return;
    setState(() {
      _selectedCompany = null;
      _selectedCompanyId = null;
      _companyWork.clear();
      _availableTripsForInvoice.clear();
      _companyInvoices.clear();
      _selectedTripsForInvoice.clear();
      _invoiceNameController.clear();
      _invoiceNotesController.clear();
      _hasSyncedOnEnter = false;
    });
    _loadCompanies();
  }

  Future<void> _printKartaRequest(Map<String, dynamic> invoice) async {
    if (_arabicFont == null) {
      await _loadArabicFont();
    }

    if (mounted) {
      setState(() => _isGeneratingPDF = true);
    }

    try {
      final trips =
          invoice['invoiceTrips'] as List<Map<String, dynamic>>? ?? [];
      final invoiceName = invoice['name'] ?? '';
      final companyName = invoice['companyName'] ?? 'غير معروف';
      final createdAt = invoice['createdAt'] as DateTime?;

      // استخراج الشهر من تاريخ الفاتورة
      String monthYear = 'غير محدد';
      if (createdAt != null) {
        monthYear = '${createdAt.month}/${createdAt.year}';
      }

      // الحصول على الموقع الفعلي (companyLocationName) من الرحلات
      String companyLocation = '';
      for (var trip in trips) {
        final location = trip['companyLocationName']?.toString() ?? '';
        if (location.isNotEmpty) {
          companyLocation = location;
          break;
        }
      }

      // إذا لم يوجد موقع، استخدم 'الموقع' كقيمة افتراضية
      if (companyLocation.isEmpty) {
        companyLocation = 'الموقع';
      }

      // ترتيب الرحلات حسب التاريخ
      final List<Map<String, dynamic>> sortedTrips = List.from(trips)
        ..sort((a, b) {
          final dateA = a['date'] as DateTime? ?? DateTime(1900);
          final dateB = b['date'] as DateTime? ?? DateTime(1900);
          return dateA.compareTo(dateB);
        });

      // إنشاء صفوف الجدول - كل رحلة في سطر منفصل
      final List<Map<String, dynamic>> tableRows = [];
      double totalKartasValue = 0;
      int rowNumber = 1;

      for (var trip in sortedTrips) {
        final date = trip['date'] as DateTime?;
        final karta = trip['karta']?.toString() ?? '';
        final ohda = trip['ohda']?.toString() ?? '';

        // حساب قيمة الكارتة إذا كانت رقماً
        double kartaValue = 0;
        try {
          final cleanedKarta = karta.trim();
          if (cleanedKarta.isNotEmpty) {
            kartaValue = double.tryParse(cleanedKarta) ?? 0;
          }
        } catch (e) {
          debugPrint('خطأ في تحويل الكارتة إلى رقم: $karta');
        }

        // جمع القيمة الإجمالية
        totalKartasValue += kartaValue;

        // تنسيق التاريخ (يوم/شهر فقط)
        String formattedDate = '-';
        if (date != null) {
          formattedDate = '${date.day}/${date.month}';
        }
        if (kartaValue != 0) {
          tableRows.add({
            'rowNumber': rowNumber.toString(),
            'date': formattedDate,
            'karta': karta,
            'ohda': ohda,
            'kartaValue': kartaValue,
          });

          rowNumber++;
        }
      }

      final pdf = pdfLib.Document(
        theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
      );
      pdf.addPage(
        pdfLib.MultiPage(
          pageFormat: pdfLib.PdfPageFormat.a4,
          margin: const pdfLib.EdgeInsets.only(right: 60, left: 60),
          build: (context) => [
            pdfLib.Directionality(
              textDirection: pdfLib.TextDirection.rtl,
              child: pdfLib.Column(
                crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
                children: [
                  _kartaRequestHeader(
                    invoiceName,
                    monthYear,
                    companyName,
                    companyLocation,
                  ),
                  pdfLib.SizedBox(height: 20),
                  _kartaRequestTable(tableRows, totalKartasValue),
                  pdfLib.SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        name: 'مطالبة كارتات - $invoiceName',
        onLayout: (_) async => pdf.save(),
      );

      _showSuccess('تم طباعة مطالبة الكارتات بنجاح');
    } catch (e) {
      _showError('خطأ في طباعة مطالبة الكارتات: $e');
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPDF = false);
      }
    }
  }

  // ================================
  // ترويسة مطالبة الكارتات
  // ================================
  pdfLib.Widget _kartaRequestHeader(
    String invoiceName,
    String monthYear,
    String companyName,
    String location,
  ) {
    return pdfLib.Column(
      crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
      children: [
        pdfLib.Text(
          'فاتورة رقم ( $invoiceName )',
          style: pdfLib.TextStyle(
            font: _arabicFont,
            fontSize: 18,
            fontWeight: pdfLib.FontWeight.bold,
          ),
          textAlign: pdfLib.TextAlign.center,
        ),
        pdfLib.SizedBox(height: 10),
        pdfLib.Text(
          'مطالبة كارتات فاتورة شهر $monthYear م',
          style: pdfLib.TextStyle(
            font: _arabicFont,
            fontSize: 16,
            fontWeight: pdfLib.FontWeight.bold,
          ),
          textAlign: pdfLib.TextAlign.center,
        ),
        pdfLib.SizedBox(height: 10),
        pdfLib.Text(
          'عن موقع ( $location )( $companyName)',
          style: pdfLib.TextStyle(font: _arabicFont, fontSize: 14),
          textAlign: pdfLib.TextAlign.center,
        ),
        pdfLib.SizedBox(height: 20),
      ],
    );
  }

  // ================================
  // جدول مطالبة الكارتات كما في الصورة
  // ================================
  pdfLib.Widget _kartaRequestTable(
    List<Map<String, dynamic>> rows,
    double totalKartasValue,
  ) {
    return pdfLib.Table(
      border: pdfLib.TableBorder.all(color: pdfLib.PdfColors.black, width: 1),
      columnWidths: const {
        0: pdfLib.FlexColumnWidth(1.5), // المسلسل
        1: pdfLib.FlexColumnWidth(1), // التاريخ
        2: pdfLib.FlexColumnWidth(1), // القيمة (الكارتة)
      },
      children: [
        // رأس الجدول كما في الصورة
        pdfLib.TableRow(
          decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
          children: [
            _kartaTableCell('القيمة', isHeader: true),
            _kartaTableCell('التاريخ', isHeader: true),
            _kartaTableCell('المسلسل', isHeader: true),
          ],
        ),

        // صفوف البيانات - كل رحلة في سطر منفصل
        ...rows.map(
          (row) => pdfLib.TableRow(
            children: [
              _kartaTableCell(row['karta']?.toString() ?? ''),
              _kartaTableCell(row['date']),
              _kartaTableCell(row['rowNumber']),
            ],
          ),
        ),

        // الصف الأخير الإجمالي كما في الصورة
        pdfLib.TableRow(
          children: [
            _kartaTableCell(
              _formatCurrencyForPDF(totalKartasValue),
              isTotal: true,
            ),
            _kartaTableCell('--', isTotal: true),
            _kartaTableCell('الإجمالي', isTotal: true),
          ],
        ),
      ],
    );
  }

  // ================================
  // خلية جدول مطالبة الكارتات
  // ================================
  pdfLib.Widget _kartaTableCell(
    String text, {
    bool isHeader = false,
    bool isTotal = false,
  }) {
    return pdfLib.Container(
      padding: const pdfLib.EdgeInsets.all(8),
      child: pdfLib.Text(
        text,
        textAlign: pdfLib.TextAlign.center,
        style: pdfLib.TextStyle(
          font: _arabicFont,
          fontSize: isTotal ? 12 : 10,
          fontWeight: isHeader || isTotal
              ? pdfLib.FontWeight.bold
              : pdfLib.FontWeight.normal,
        ),
      ),
    );
  }

  // ================================
  // دوال الطباعة
  // ================================

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
      final companyId = invoice['companyId'] ?? _selectedCompanyId;

      // التحقق إذا كانت الشركة تعمل بنظام TR
      final bool usesTRSystem = companyId != null
          ? await _getCompanyTRStatus(companyId)
          : false;

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
      final afterTax = total + tax;

      final pdf = pdfLib.Document(
        theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
      );

      pdf.addPage(
        pdfLib.Page(
          pageFormat: pdfLib.PdfPageFormat.a4,
          margin: const pdfLib.EdgeInsets.only(right: 60, left: 60),
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
                _invoiceTable(groupedTrips, usesTRSystem),
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
            // اللوجو الجديد
            _buildLogoWidget(),
          ],
        ),
        pdfLib.Divider(),
      ],
    );
  }

  // دالة منفصلة لبناء اللوجو
  pdfLib.Widget _buildLogoWidget() {
    if (_logoImageBytes != null) {
      return pdfLib.Column(
        children: [
          pdfLib.Container(
            width: 55,
            height: 55,
            child: pdfLib.Image(
              pdfLib.MemoryImage(_logoImageBytes!),
              fit: pdfLib.BoxFit.contain,
            ),
          ),
          pdfLib.SizedBox(height: 4),
          pdfLib.Text(
            'New grand',
            style: pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold),
          ),
        ],
      );
    } else {
      return pdfLib.Column(
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
      );
    }
  }

  pdfLib.Widget _invoiceTable(
    List<Map<String, dynamic>> rows,
    bool usesTRSystem,
  ) {
    // تحديد أعمدة الجدول بناءً على نظام TR
    if (usesTRSystem) {
      // جدول مع TR (6 أعمدة)
      return pdfLib.Table(
        border: pdfLib.TableBorder.all(
          color: pdfLib.PdfColors.black,
          width: 1.3,
        ),
        columnWidths: const {
          5: pdfLib.FlexColumnWidth(1.2), // القيمة الإجمالية
          4: pdfLib.FlexColumnWidth(1), // السعر
          3: pdfLib.FlexColumnWidth(3), // البيان
          2: pdfLib.FlexColumnWidth(1), // عدد/طن
          1: pdfLib.FlexColumnWidth(1), // TR Number
          0: pdfLib.FlexColumnWidth(1.2), // التاريخ
        },
        children: [
          pdfLib.TableRow(
            decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
            children: [
              _th('القيمة الإجمالية'),
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
    } else {
      // جدول بدون TR (5 أعمدة)
      return pdfLib.Table(
        border: pdfLib.TableBorder.all(
          color: pdfLib.PdfColors.black,
          width: 1.3,
        ),
        columnWidths: const {
          4: pdfLib.FlexColumnWidth(1.2), // القيمة الإجمالية
          3: pdfLib.FlexColumnWidth(4), // السعر
          2: pdfLib.FlexColumnWidth(1), // البيان (أوسع بدون TR)
          1: pdfLib.FlexColumnWidth(1), // عدد/طن
          0: pdfLib.FlexColumnWidth(1.2), // التاريخ
        },
        children: [
          pdfLib.TableRow(
            decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
            children: [
              _th('القيمة الإجمالية'),
              _th('السعر'),
              _th('عدد/طن'),
              _th('البيان'),
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
                _td(e['date']),
              ],
            ),
          ),
          ...List.generate(
            17 - rows.length > 0 ? 17 - rows.length : 0,
            (_) => pdfLib.TableRow(
              children: List.generate(5, (i) => _td(i == 4 ? '0' : '')),
            ),
          ),
        ],
      );
    }
  }

  pdfLib.Widget _totalsSection(double total, double tax, double afterTax) {
    return pdfLib.Column(
      children: [
        pdfLib.Table(
          border: pdfLib.TableBorder.all(),
          columnWidths: const {
            1: pdfLib.FlexColumnWidth(6),
            0: pdfLib.FlexColumnWidth(1),
          },
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
                'سجل تجاري : $x',
                style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
              ),
              pdfLib.Text(
                'بطاقة ضريبة : $xx',
                style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
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
      final karta = trip['karta']?.toString() ?? '';

      final companyLocationName = trip['companyLocationName']?.toString() ?? '';

      String description = " ";
      if (companyLocationName.isNotEmpty) {
        description +=
            '   تحميل على ${vehicleType} من  ${selectedRoute}  الى  ${selectedRoute2} ';
      }

      // إضافة الكارتة للوصف
      // if (karta.isNotEmpty) {
      //   description += ' (كارتة: $karta)';
      // }

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
          'karta': karta,
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
        // دمج الكارتات
        if (karta.isNotEmpty &&
            !(existing['karta'] as String).contains(karta)) {
          existing['karta'] = '${existing['karta']}، $karta';
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

  // Future<void> _printInvoice(Map<String, dynamic> invoice) async {
  //   if (_arabicFont == null) {
  //     await _loadArabicFont();
  //   }

  //   if (mounted) {
  //     setState(() => _isGeneratingPDF = true);
  //   }

  //   try {
  //     final trips =
  //         invoice['invoiceTrips'] as List<Map<String, dynamic>>? ?? [];
  //     final invoiceId = invoice['id']?.toString() ?? '623';
  //     final createdAt = invoice['createdAt'] as DateTime?;
  //     final companyName = invoice['companyName'] ?? ' ';
  //     final name = invoice['name'] ?? '';
  //     final companyId = invoice['companyId'] ?? _selectedCompanyId;
  //     final notes = invoice['notes'] ?? '';
  //     final month = invoice['month'] ?? 'غير محدد';
  //     final kartaValue = invoice['kartaValue'] ?? 0;
  //     final totalWithKarta =
  //         invoice['totalWithKarta'] ?? invoice['totalAmount'] ?? 0;

  //     // التحقق إذا كانت الشركة تعمل بنظام TR
  //     final bool usesTRSystem = companyId != null
  //         ? await _getCompanyTRStatus(companyId)
  //         : false;

  //     final groupedTrips = _groupTripsForInvoice(trips);
  //     final location = _getCompanyLocationName(trips);

  //     final total = groupedTrips.fold<double>(0.0, (sum, e) {
  //       final value = e['total'];
  //       if (value is num) {
  //         return sum + value.toDouble();
  //       }
  //       return sum;
  //     });

  //     final tax = total * 0.14;
  //     final afterTax = total + tax;

  //     final pdf = pdfLib.Document(
  //       theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
  //     );

  //     pdf.addPage(
  //       pdfLib.MultiPage(
  //         pageFormat: pdfLib.PdfPageFormat.a4,
  //         margin: const pdfLib.EdgeInsets.only(right: 60, left: 60),
  //         build: (context) => [
  //           pdfLib.Directionality(
  //             textDirection: pdfLib.TextDirection.rtl,
  //             child: pdfLib.Column(
  //               crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
  //               children: [
  //                 _invoiceHeader(
  //                   invoiceId,
  //                   createdAt,
  //                   companyName,
  //                   location,
  //                   name,
  //                   month,
  //                   notes,
  //                 ),
  //                 pdfLib.SizedBox(height: 10),
  //                 _invoiceTable(groupedTrips, usesTRSystem),
  //                 // pdfLib.SizedBox(height: 10),
  //                 _totalsSection(
  //                   total,
  //                   tax,
  //                   afterTax,
  //                   kartaValue,
  //                   totalWithKarta,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     );

  //     await Printing.layoutPdf(
  //       name: '$name',
  //       onLayout: (_) async => pdf.save(),
  //     );

  //     _showSuccess('تم طباعة الفاتورة بنجاح');
  //   } catch (e) {
  //     _showError(e.toString());
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isGeneratingPDF = false);
  //     }
  //   }
  // }

  // pdfLib.Widget _invoiceHeader(
  //   String invoiceId,
  //   DateTime? date,
  //   String company,
  //   String location,
  //   String name,
  //   String month,
  //   String notes,
  // ) {
  //   return pdfLib.Column(
  //     children: [
  //       pdfLib.Row(
  //         mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
  //         crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
  //         children: [
  //           pdfLib.Column(
  //             crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
  //             children: [
  //               pdfLib.Text('شركة نيوجراند لخدمات النقل'),
  //               pdfLib.Text('السادة شركة : $company'),
  //               pdfLib.Text('مذكور للمشروعات'),
  //               pdfLib.Text('موقع : ${location.isNotEmpty ? location : '_ '}'),
  //             ],
  //           ),
  //           pdfLib.Column(
  //             children: [
  //               pdfLib.Text(
  //                 '$name',
  //                 style: pdfLib.TextStyle(
  //                   font: _arabicFont,
  //                   fontSize: 18,
  //                   fontWeight: pdfLib.FontWeight.bold,
  //                   decoration: pdfLib.TextDecoration.underline,
  //                 ),
  //               ),
  //               pdfLib.Text(
  //                 date != null
  //                     ? DateFormat('d/M/yyyy').format(date)
  //                     : '1/2/2023',
  //                 style: pdfLib.TextStyle(font: _arabicFont, fontSize: 11),
  //               ),
  //             ],
  //           ),
  //           // اللوجو الجديد
  //           _buildLogoWidget(),
  //         ],
  //       ),
  //       pdfLib.Divider(),
  //     ],
  //   );
  // }

  // // دالة منفصلة لبناء اللوجو
  // pdfLib.Widget _buildLogoWidget() {
  //   if (_logoImageBytes != null) {
  //     return pdfLib.Column(
  //       children: [
  //         pdfLib.Container(
  //           width: 55,
  //           height: 55,
  //           child: pdfLib.Image(
  //             pdfLib.MemoryImage(_logoImageBytes!),
  //             fit: pdfLib.BoxFit.contain,
  //           ),
  //         ),
  //         pdfLib.SizedBox(height: 4),
  //         pdfLib.Text(
  //           'New grand',
  //           style: pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold),
  //         ),
  //       ],
  //     );
  //   } else {
  //     return pdfLib.Column(
  //       children: [
  //         pdfLib.Container(
  //           width: 55,
  //           height: 55,
  //           decoration: pdfLib.BoxDecoration(
  //             color: pdfLib.PdfColors.black,
  //             shape: pdfLib.BoxShape.circle,
  //           ),
  //         ),
  //         pdfLib.Text(
  //           'New grand',
  //           style: pdfLib.TextStyle(fontWeight: pdfLib.FontWeight.bold),
  //         ),
  //       ],
  //     );
  //   }
  // }

  // pdfLib.Widget _invoiceTable(
  //   List<Map<String, dynamic>> rows,
  //   bool usesTRSystem,
  // ) {
  //   // تحديد أعمدة الجدول بناءً على نظام TR
  //   if (usesTRSystem) {
  //     // جدول مع TR (6 أعمدة)
  //     return pdfLib.Table(
  //       border: pdfLib.TableBorder.all(
  //         color: pdfLib.PdfColors.black,
  //         width: 1.3,
  //       ),
  //       columnWidths: const {
  //         5: pdfLib.FlexColumnWidth(1.2), // القيمة الإجمالية
  //         4: pdfLib.FlexColumnWidth(1), // السعر
  //         3: pdfLib.FlexColumnWidth(3), // البيان
  //         2: pdfLib.FlexColumnWidth(1), // عدد/طن
  //         1: pdfLib.FlexColumnWidth(1), // TR Number
  //         0: pdfLib.FlexColumnWidth(1.2), // التاريخ
  //       },
  //       children: [
  //         pdfLib.TableRow(
  //           decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
  //           children: [
  //             _th('القيمة الإجمالية'),
  //             _th('السعر'),
  //             _th('عدد/طن'),
  //             _th('البيان'),
  //             _th('TR\nNumber'),
  //             _th('التاريخ'),
  //           ],
  //         ),
  //         ...rows.map(
  //           (e) => pdfLib.TableRow(
  //             children: [
  //               _td(_format(e['total'])),
  //               _td(_format(e['price'])),
  //               _td(e['count'].toString()),
  //               _td(e['description'], right: true),
  //               _td(e['tr']),
  //               _td(e['date']),
  //             ],
  //           ),
  //         ),
  //         ...List.generate(
  //           17 - rows.length > 0 ? 17 - rows.length : 0,
  //           (_) => pdfLib.TableRow(
  //             children: List.generate(6, (i) => _td(i == 5 ? '0' : '')),
  //           ),
  //         ),
  //       ],
  //     );
  //   } else {
  //     // جدول بدون TR (5 أعمدة)
  //     return pdfLib.Table(
  //       border: pdfLib.TableBorder.all(
  //         color: pdfLib.PdfColors.black,
  //         width: 1.3,
  //       ),
  //       columnWidths: const {
  //         4: pdfLib.FlexColumnWidth(1.2), // القيمة الإجمالية
  //         3: pdfLib.FlexColumnWidth(4), // السعر
  //         2: pdfLib.FlexColumnWidth(1), // البيان (أوسع بدون TR)
  //         1: pdfLib.FlexColumnWidth(1), // عدد/طن
  //         0: pdfLib.FlexColumnWidth(1.2), // التاريخ
  //       },
  //       children: [
  //         pdfLib.TableRow(
  //           decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
  //           children: [
  //             _th('القيمة الإجمالية'),
  //             _th('السعر'),
  //             _th('عدد/طن'),
  //             _th('البيان'),
  //             _th('التاريخ'),
  //           ],
  //         ),
  //         ...rows.map(
  //           (e) => pdfLib.TableRow(
  //             children: [
  //               _td(_format(e['total'])),
  //               _td(_format(e['price'])),
  //               _td(e['count'].toString()),
  //               _td(e['description'], right: true),
  //               _td(e['date']),
  //             ],
  //           ),
  //         ),
  //         ...List.generate(
  //           17 - rows.length > 0 ? 17 - rows.length : 0,
  //           (_) => pdfLib.TableRow(
  //             children: List.generate(5, (i) => _td(i == 4 ? '0' : '')),
  //           ),
  //         ),
  //       ],
  //     );
  //   }
  // }

  // pdfLib.Widget _totalsSection(
  //   double total,
  //   double tax,
  //   double afterTax,
  //   double kartaValue,
  //   double totalWithKarta,
  // ) {
  //   return pdfLib.Column(
  //     children: [
  //       pdfLib.Table(
  //         border: pdfLib.TableBorder.all(),
  //         columnWidths: const {
  //           1: pdfLib.FlexColumnWidth(6),
  //           0: pdfLib.FlexColumnWidth(1),
  //         },
  //         children: [
  //           _totalRow('الإجمالي', total),
  //           _totalRow('14% ضريبة مبيعات', tax),
  //           _totalRow('الإجمالي بعد الضريبة', afterTax),
  //           // _totalRow('قيمة الكارتة', kartaValue),
  //           // _totalRow('الإجمالي النهائي', totalWithKarta),
  //         ],
  //       ),
  //       pdfLib.SizedBox(height: 5),
  //       pdfLib.Align(
  //         alignment: pdfLib.Alignment.centerRight,
  //         child: pdfLib.Column(
  //           crossAxisAlignment: pdfLib.CrossAxisAlignment.end,
  //           children: [
  //             pdfLib.Text(
  //               'سجل تجاري : $x',
  //               style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
  //             ),
  //             pdfLib.Text(
  //               'بطاقة ضريبة : $xx',
  //               style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
  //             ),
  //           ],
  //         ),
  //       ),
  //       pdfLib.Text(
  //         'الفاتورة الغير مختومة بختم الشركة لايعتد بها',
  //         style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
  //       ),
  //     ],
  //   );
  // }

  // pdfLib.Widget _th(String t) => pdfLib.Padding(
  //   padding: const pdfLib.EdgeInsets.all(5),
  //   child: pdfLib.Text(
  //     t,
  //     textAlign: pdfLib.TextAlign.center,
  //     style: pdfLib.TextStyle(
  //       font: _arabicFont,
  //       fontWeight: pdfLib.FontWeight.bold,
  //       fontSize: 10,
  //     ),
  //   ),
  // );

  // pdfLib.Widget _td(String t, {bool right = false}) => pdfLib.Padding(
  //   padding: const pdfLib.EdgeInsets.all(5),
  //   child: pdfLib.Text(
  //     t,
  //     textAlign: right ? pdfLib.TextAlign.right : pdfLib.TextAlign.center,
  //     style: pdfLib.TextStyle(font: _arabicFont, fontSize: 9),
  //   ),
  // );

  // pdfLib.TableRow _totalRow(String label, double v) {
  //   return pdfLib.TableRow(children: [_td(_format(v)), _td(label)]);
  // }

  // String _format(num v) => v.toStringAsFixed(0);

  // String _getCompanyLocationName(List<Map<String, dynamic>> trips) {
  //   for (final t in trips) {
  //     final l = t['companyLocationName']?.toString() ?? '';
  //     if (l.isNotEmpty) return l;
  //   }
  //   return '';
  // }

  // List<Map<String, dynamic>> _groupTripsForInvoice(
  //   List<Map<String, dynamic>> trips,
  // ) {
  //   final Map<String, Map<String, dynamic>> grouped = {};

  //   for (final trip in trips) {
  //     final date = trip['date'] != null
  //         ? DateFormat('d/M/yyyy').format((trip['date'] as DateTime))
  //         : DateFormat('d/M/yyyy').format(DateTime.now());
  //     final tr = trip['tr']?.toString() ?? '';
  //     final nolon = (trip['nolon'] ?? 0).toDouble();
  //     final companyOvernight = (trip['companyOvernight'] ?? 0).toDouble();
  //     final companyHoliday = (trip['companyHoliday'] ?? 0).toDouble();
  //     final selectedRoute = trip['selectedRoute']?.toString() ?? '';
  //     final selectedRoute2 = trip['selectedRoute2']?.toString() ?? '';
  //     final vehicleType = trip['vehicleType']?.toString() ?? '';
  //     final karta = trip['karta']?.toString() ?? '';

  //     final companyLocationName = trip['companyLocationName']?.toString() ?? '';

  //     String description = " ";
  //     if (companyLocationName.isNotEmpty) {
  //       description +=
  //           '   تحميل على ${vehicleType} من  ${selectedRoute}  الى  ${selectedRoute2} ';
  //     }

  //     final key = '$date|$tr|$nolon|$selectedRoute';

  //     if (!grouped.containsKey(key)) {
  //       grouped[key] = {
  //         'date': date,
  //         'tr': tr,
  //         'description': description,
  //         'nolon': nolon,
  //         'nolonCount': 1,
  //         'overnight': companyOvernight,
  //         'overnightCount': companyOvernight > 0 ? 1 : 0,
  //         'holiday': companyHoliday,
  //         'holidayCount': companyHoliday > 0 ? 1 : 0,
  //         'selectedRoute': selectedRoute,
  //         'companyLocationName': companyLocationName,
  //         'karta': karta,
  //       };
  //     } else {
  //       final existing = grouped[key]!;
  //       existing['nolonCount'] = (existing['nolonCount'] as int) + 1;
  //       if (companyOvernight > 0) {
  //         existing['overnightCount'] = (existing['overnightCount'] as int) + 1;
  //       }
  //       if (companyHoliday > 0) {
  //         existing['holidayCount'] = (existing['holidayCount'] as int) + 1;
  //       }
  //       // دمج الكارتات
  //       if (karta.isNotEmpty &&
  //           !(existing['karta'] as String).contains(karta)) {
  //         existing['karta'] = '${existing['karta']}، $karta';
  //       }
  //     }
  //   }

  //   final List<Map<String, dynamic>> result = [];

  //   grouped.forEach((key, tripGroup) {
  //     if (tripGroup['nolonCount'] > 0) {
  //       result.add({
  //         'type': 'نولون',
  //         'date': tripGroup['date'],
  //         'tr': tripGroup['tr'],
  //         'description': tripGroup['description'],
  //         'count': tripGroup['nolonCount'],
  //         'price': tripGroup['nolon'],
  //         'total':
  //             (tripGroup['nolonCount'] as int) * (tripGroup['nolon'] as double),
  //       });
  //     }
  //     if (tripGroup['overnightCount'] > 0) {
  //       result.add({
  //         'type': 'مبيت',
  //         'date': tripGroup['date'],
  //         'tr': tripGroup['tr'],
  //         'description': 'مبيت >>>${tripGroup['description']}',
  //         'count': tripGroup['overnightCount'],
  //         'price': tripGroup['overnight'],
  //         'total':
  //             (tripGroup['overnightCount'] as int) *
  //             (tripGroup['overnight'] as double),
  //       });
  //     }
  //     if (tripGroup['holidayCount'] > 0) {
  //       result.add({
  //         'type': 'عطلة',
  //         'date': tripGroup['date'],
  //         'tr': tripGroup['tr'],
  //         'description': 'عطلة >>>${tripGroup['description']}',
  //         'count': tripGroup['holidayCount'],
  //         'price': tripGroup['holiday'],
  //         'total':
  //             (tripGroup['holidayCount'] as int) *
  //             (tripGroup['holiday'] as double),
  //       });
  //     }
  //   });

  //   return result;
  // }

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
          "اضغط لعرض التفاصيل",
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

  // ================================
  // شريط الفلترة
  // ================================
  // ================================
  // شريط الفلترة
  // ================================
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.blue[50],
      child: Row(
        children: [
          // فلترة الشهر
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedMonthWork,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFF3498DB),
                  ),
                  style: const TextStyle(
                    color: Color(0xFF2C3E50),
                    fontSize: 14,
                  ),
                  items: _monthsList.map((String month) {
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Text(
                        month,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedMonthWork = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // فلترة السنة
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedYear,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF3498DB),
                  ),
                  style: const TextStyle(
                    color: Color(0xFF2C3E50),
                    fontSize: 14,
                  ),
                  items: _yearsList.map((String year) {
                    return DropdownMenuItem<String>(
                      value: year,
                      child: Text(
                        year,
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedYear = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // زر إعادة تعيين الفلترة
          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF3498DB)),
            onPressed: () {
              final now = DateTime.now();
              setState(() {
                _selectedMonthWork = _monthsList[now.month - 1]; // الشهر الحالي
                _selectedYear = now.year.toString(); // السنة الحالية
              });
            },
            tooltip: 'إعادة تعيين الفلاتر',
          ),
        ],
      ),
    );
  }

  // ================================
  // إحصائيات الرحلات المفلترة
  // ================================
  // Widget _buildFilterStats(List<Map<String, dynamic>> trips) {
  //   if (trips.isEmpty) return SizedBox();

  //   double totalNolon = 0;
  //   double totalOvernight = 0;
  //   double totalHoliday = 0;

  //   for (var trip in trips) {
  //     totalNolon += trip['nolon'] ?? 0;
  //     totalOvernight += trip['companyOvernight'] ?? 0;
  //     totalHoliday += trip['companyHoliday'] ?? 0;
  //   }

  //   return Container(
  //     padding: EdgeInsets.all(12),
  //     margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     decoration: BoxDecoration(
  //       color: Colors.blue[50],
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border.all(color: Color(0xFF3498DB)),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       children: [
  //         _buildStatItem('عدد الرحلات', trips.length.toString()),
  //         _buildStatItem(
  //           'إجمالي النولون',
  //           '${totalNolon.toStringAsFixed(2)} ج',
  //         ),
  //         _buildStatItem(
  //           'إجمالي المبيت',
  //           '${totalOvernight.toStringAsFixed(2)} ج',
  //         ),
  //         _buildStatItem(
  //           'إجمالي العطلة',
  //           '${totalHoliday.toStringAsFixed(2)} ج',
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkTable() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    // تطبيق الفلترة
    final filteredTrips = _getFilteredTrips(_companyWork);

    // ترتيب الرحلات من الأحدث إلى الأقدم
    final sortedWork = List<Map<String, dynamic>>.from(filteredTrips)
      ..sort((a, b) {
        final dateA = a['date'] as DateTime? ?? DateTime(1900);
        final dateB = b['date'] as DateTime? ?? DateTime(1900);
        return dateB.compareTo(dateA); // الأحدث أولاً
      });

    return Column(
      children: [
        _buildFilterBar(),
        // _buildFilterStats(filteredTrips),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: sortedWork.isEmpty
                ? _buildNoDataWidget()
                : _buildTripsTable(sortedWork),
          ),
        ),
      ],
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list, size: 60, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'لا توجد رحلات في الفلترة المحددة',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'الشهر: $_selectedMonthWork - السنة: $_selectedYear',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final now = DateTime.now();
              setState(() {
                _selectedMonthWork = _monthsList[now.month - 1];
                _selectedYear = now.year.toString();
              });
            },
            child: Text('إعادة تعيين الفلاتر'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF3498DB),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsTable(List<Map<String, dynamic>> trips) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Table(
          defaultColumnWidth: const FixedColumnWidth(89),
          border: TableBorder.all(color: const Color(0xFF3498DB), width: 1),
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
            ...trips.asMap().entries.map((entry) {
              final index = entry.key;
              final work = entry.value;
              final hasInvoice = work['hasInvoice'];

              return TableRow(
                decoration: BoxDecoration(
                  color: index.isEven ? Colors.white : const Color(0xFFF8F9FA),
                ),
                children: [
                  TableCellBody(
                    hasInvoice ? 'مفوتورة' : 'متاحة',
                    textStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: hasInvoice ? Colors.red : Colors.green,
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

              // الملاحظات (اختياري)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _invoiceNotesController,
                  decoration: InputDecoration(
                    labelText: 'ملاحظات (اختياري)',
                    prefixIcon: const Icon(Icons.note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 2,
                ),
              ),

              // شهر الإدراج
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedMonth,
                  decoration: InputDecoration(
                    labelText: 'شهر الإدراج',
                    prefixIcon: const Icon(Icons.calendar_month),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: _monthsList.map((String month) {
                    return DropdownMenuItem<String>(
                      value: month,
                      child: Text(month),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedMonth = newValue;
                      });
                    }
                  },
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

    final notCollectedInvoices = _getFilteredInvoices(false);
    final collectedInvoices = _getFilteredInvoices(true);

    return Column(
      children: [
        // فلترة الفواتير
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blue[50],
          child: Column(
            children: [
              // صف فلترة الشهر والسنة
              Row(
                children: [
                  const Icon(Icons.filter_alt, color: Color(0xFF3498DB)),
                  const SizedBox(width: 8),
                  const Text(
                    'فلترة حسب:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3498DB),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // فلترة الشهر
                  Container(
                    width: 100,
                    child: Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedMonthFilter,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFF3498DB),
                              size: 20,
                            ),
                            style: const TextStyle(
                              color: Color(0xFF2C3E50),
                              fontSize: 12,
                            ),
                            items: [
                              DropdownMenuItem<String>(
                                value: 'كل الشهور',
                                child: Text('كل الشهور'),
                              ),
                              ..._monthsList.map((String month) {
                                return DropdownMenuItem<String>(
                                  value: month,
                                  child: Text(month),
                                );
                              }).toList(),
                            ],
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedMonthFilter = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // فلترة السنة
                  Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedYearFilter,
                        isExpanded: true,
                        // icon: const Icon(
                        //   Icons.calendar_today,
                        //   color: Color(0xFF3498DB),
                        //   size: 18,
                        // ),
                        style: const TextStyle(
                          color: Color(0xFF2C3E50),
                          fontSize: 12,
                        ),
                        items: _yearsList.map((String year) {
                          return DropdownMenuItem<String>(
                            value: year,
                            child: Text(year),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedYearFilter = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isGeneratingPDF
                          ? null
                          : () => _printMonthInvoices(false),
                      icon: _isGeneratingPDF
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.print, size: 18),
                      label: Text(
                        _isGeneratingPDF
                            ? 'جاري الطباعة...'
                            : 'طباعة فواتير الشهر غير المحصلة',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isGeneratingPDF
                          ? null
                          : () => _printMonthInvoices(true),
                      icon: _isGeneratingPDF
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.print, size: 18),
                      label: Text(
                        _isGeneratingPDF
                            ? 'جاري الطباعة...'
                            : 'طباعة فواتير الشهر المحصلة',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // تبويب عرض الفواتير
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _currentInvoiceView = 0;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _currentInvoiceView == 0
                                ? Color.fromARGB(255, 254, 21, 0)
                                : Colors.white,
                            borderRadius: const BorderRadius.horizontal(
                              right: Radius.circular(8),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.money_off,
                                color: _currentInvoiceView == 0
                                    ? Colors.white
                                    : Colors.grey,
                                size: 20,
                              ),
                              Text(
                                'غير المحصلة (${notCollectedInvoices.length})',
                                style: TextStyle(
                                  color: _currentInvoiceView == 0
                                      ? Colors.white
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.grey[300]),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _currentInvoiceView = 1;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _currentInvoiceView == 1
                                ? Color.fromARGB(255, 255, 0, 0)
                                : Colors.white,
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(8),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: _currentInvoiceView == 1
                                    ? Colors.white
                                    : Colors.grey,
                                size: 20,
                              ),
                              Text(
                                'المحصلة (${collectedInvoices.length})',
                                style: TextStyle(
                                  color: _currentInvoiceView == 1
                                      ? Colors.white
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // أزرار طباعة جميع فواتير الشهر
            ],
          ),
        ),

        // تعداد الفواتير
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Text(
        //         _currentInvoiceView == 0
        //             ? 'عدد الفواتير غير المحصلة: ${notCollectedInvoices.length}'
        //             : 'عدد الفواتير المحصلة: ${collectedInvoices.length}',
        //         style: const TextStyle(
        //           fontWeight: FontWeight.bold,
        //           color: Color(0xFF2C3E50),
        //           fontSize: 14,
        //         ),
        //       ),
        //       Column(
        //         crossAxisAlignment: CrossAxisAlignment.end,
        //         children: [
        //           Text(
        //             'الشهر: $_selectedMonthFilter',
        //             style: const TextStyle(
        //               fontWeight: FontWeight.bold,
        //               color: Color(0xFF3498DB),
        //               fontSize: 12,
        //             ),
        //           ),
        //           Text(
        //             'السنة: $_selectedYearFilter',
        //             style: const TextStyle(
        //               fontWeight: FontWeight.bold,
        //               color: Color(0xFF3498DB),
        //               fontSize: 12,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),
        Expanded(
          child: _currentInvoiceView == 0
              ? _buildInvoicesList(notCollectedInvoices, false)
              : _buildInvoicesList(collectedInvoices, true),
        ),
      ],
    );
  }

  Widget _buildInvoicesList(
    List<Map<String, dynamic>> invoices,
    bool isCollected,
  ) {
    if (invoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isCollected ? Icons.check_circle : Icons.money_off,
              size: 60,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isCollected
                  ? 'لا توجد فواتير محصلة للشهر المحدد'
                  : 'لا توجد فواتير غير محصلة للشهر المحدد',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return _buildInvoiceCard(invoice, index, isCollected);
      },
    );
  }

  Widget _buildInvoiceCard(
    Map<String, dynamic> invoice,
    int index,
    bool isCollected,
  ) {
    final createdAt = invoice['createdAt'] as DateTime?;
    final collectedAt = invoice['collectedAt'] as DateTime?;
    final invoiceTrips = invoice['invoiceTrips'] as List<Map<String, dynamic>>;
    final month = invoice['month'] ?? 'غير محدد';
    final notes = invoice['notes'] ?? '';
    final kartaValue = invoice['kartaValue'] ?? 0;
    final totalWithKarta =
        invoice['totalWithKarta'] ?? invoice['totalAmount'] ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: isCollected ? Colors.green[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCollected ? Colors.green : Colors.grey[300]!,
          width: isCollected ? 2 : 1,
        ),
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
          backgroundColor: isCollected ? Colors.green : const Color(0xFF3498DB),
          child: Text(
            '${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Text(
              invoice['name'],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isCollected
                    ? Colors.green[800]
                    : const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(width: 8),
            if (isCollected)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'محصلة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${createdAt != null ? _formatDate(createdAt) : 'غير معروف'}  ---  رحلة >>> ${invoice['tripCount']}',
              style: TextStyle(
                fontSize: 12,
                color: isCollected ? Colors.green[600] : Colors.grey,
              ),
            ),
            // if (month.isNotEmpty)
            //   Text(
            //     'شهر: $month',
            //     style: TextStyle(
            //       fontSize: 12,
            //       color: isCollected ? Colors.green[600] : Colors.grey,
            //     ),
            //   ),
            // if (notes.isNotEmpty)
            //   Text(
            //     'ملاحظات: $notes',
            //     style: const TextStyle(
            //       fontSize: 11,
            //       color: Colors.grey,
            //       fontStyle: FontStyle.italic,
            //     ),
            //     maxLines: 1,
            //     overflow: TextOverflow.ellipsis,
            //   ),
            // if (isCollected && collectedAt != null)
            //   Text(
            //     'تاريخ التحصيل: ${_formatDate(collectedAt)}',
            //     style: TextStyle(
            //       fontSize: 11,
            //       color: Colors.green[700],
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatCurrency(invoice['totalAmount'] ?? 0),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isCollected
                        ? Colors.green[800]
                        : const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'إجمالي',
                  style: TextStyle(
                    fontSize: 12,
                    color: isCollected ? Colors.green[600] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),

            // زر تغيير حالة التحصيل
            IconButton(
              icon: Icon(
                isCollected ? Icons.undo : Icons.check_circle,
                color: isCollected ? Colors.orange : Colors.green,
              ),
              onPressed: () =>
                  _toggleInvoiceCollection(invoice['id'], !isCollected),
              tooltip: isCollected ? 'إلغاء التحصيل' : 'تم التحصيل',
            ),

            // زر مطالبة الكارتات
            IconButton(
              icon: Icon(Icons.credit_card, color: Color(0xFF9C27B0)),
              onPressed: _isGeneratingPDF
                  ? null
                  : () => _printKartaRequest(invoice),
              tooltip: 'مطالبة كارتات',
            ),
            const SizedBox(width: 5),
            // زر طباعة الفاتورة
            IconButton(
              icon: Icon(Icons.print, color: Color(0xFF3498DB)),
              onPressed: _isGeneratingPDF ? null : () => _printInvoice(invoice),
              tooltip: 'طباعة الفاتورة',
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
                    color: isCollected ? Colors.green[50] : Colors.blue[50],
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
                          Text('${invoice['tripCount']}'),
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
                            _formatCurrency(invoice['nolonTotal'] ?? 0),
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
                            _formatCurrency(invoice['overnightTotal'] ?? 0),
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
                            _formatCurrency(invoice['holidayTotal'] ?? 0),
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'قيمة الكارتة:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9C27B0),
                            ),
                          ),
                          Text(
                            _formatCurrency(kartaValue),
                            style: const TextStyle(color: Color(0xFF9C27B0)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'الإجمالي النهائي:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          Text(
                            _formatCurrency(totalWithKarta),
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // أزرار التحكم
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _toggleInvoiceCollection(
                          invoice['id'],
                          !isCollected,
                        ),
                        icon: Icon(
                          isCollected ? Icons.undo : Icons.check_circle,
                        ),
                        label: Text(
                          isCollected ? 'إلغاء التحصيل' : 'تم التحصيل',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCollected
                              ? Colors.orange
                              : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isGeneratingPDF
                            ? null
                            : () => _printKartaRequest(invoice),
                        icon: _isGeneratingPDF
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.credit_card),
                        label: Text(
                          _isGeneratingPDF
                              ? 'جاري الطباعة...'
                              : 'مطالبة كارتات',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF9C27B0),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
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
                          _isGeneratingPDF
                              ? 'جاري الطباعة...'
                              : 'طباعة الفاتورة',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                // جدول تفاصيل الرحلات
              ],
            ),
          ),
        ],
      ),
    );
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
