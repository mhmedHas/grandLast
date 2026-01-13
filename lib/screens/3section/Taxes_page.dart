// // import 'dart:async';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';

// // class TaxesPage extends StatefulWidget {
// //   const TaxesPage({super.key});

// //   @override
// //   State<TaxesPage> createState() => _TaxesPageState();
// // }

// // class _TaxesPageState extends State<TaxesPage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// //   // متغيرات عامة
// //   int _currentSection = 0; // 0: الفواتير، 1: صندوق 3%، 2: صندوق 14%
// //   bool _isLoading = false;
// //   String _searchQuery = '';

// //   // بيانات الفواتير
// //   List<Map<String, dynamic>> _allInvoices = [];
// //   List<Map<String, dynamic>> _filteredInvoices = [];
// //   List<Map<String, dynamic>> _3PercentTaxInvoices = [];
// //   List<Map<String, dynamic>> _14PercentTaxInvoices = [];

// //   // بيانات الضرائب
// //   List<Map<String, dynamic>> _taxes3Percent = [];
// //   List<Map<String, dynamic>> _taxes14Percent = [];

// //   // فلتر السنوات
// //   List<int> _availableYears = [];
// //   int _selectedYear = DateTime.now().year;

// //   // متغيرات لعرض التفاصيل
// //   Map<String, dynamic>? _selectedTaxRecord;
// //   List<Map<String, dynamic>> _taxRecordInvoices = [];

// //   // متغيرات للتحكم في التحميل المتقطع (Pagination)
// //   final int _invoicesPerPage = 20;
// //   DocumentSnapshot? _lastInvoiceDocument;
// //   bool _hasMoreInvoices = true;
// //   bool _isLoadingMore = false;

// //   // متغيرات جديدة للأشهر
// //   List<Map<String, dynamic>> _monthlyTaxData = [];
// //   int _selectedMonthIndex = -1; // -1 يعني لا يوجد شهر محدد
// //   List<Map<String, dynamic>> _monthInvoices = [];

// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeYears();
// //     _loadData();
// //   }

// //   // ================================
// //   // تهيئة قائمة السنوات
// //   // ================================
// //   void _initializeYears() {
// //     final currentYear = DateTime.now().year;
// //     _availableYears = List.generate(5, (index) => currentYear - 2 + index);
// //     _selectedYear = currentYear;
// //   }

// //   // ================================
// //   // تحميل جميع البيانات
// //   // ================================
// //   Future<void> _loadData() async {
// //     setState(() {
// //       _isLoading = true;
// //     });

// //     try {
// //       await _loadInvoices();
// //       await _loadTaxes();
// //       // تحضير بيانات الأشهر بعد تحميل الفواتير
// //       _prepareMonthlyData();
// //     } catch (e) {
// //       _showError('خطأ في تحميل البيانات: $e');
// //     } finally {
// //       setState(() {
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   // ================================
// //   // تحميل جميع الفواتير (مع Pagination)
// //   // ================================
// //   Future<void> _loadInvoices({bool loadMore = false}) async {
// //     if (!loadMore) {
// //       setState(() {
// //         _isLoading = true;
// //         _allInvoices = [];
// //         _lastInvoiceDocument = null;
// //         _hasMoreInvoices = true;
// //       });
// //     } else {
// //       if (!_hasMoreInvoices || _isLoadingMore) return;
// //       setState(() => _isLoadingMore = true);
// //     }

// //     try {
// //       Query<Map<String, dynamic>> query = _firestore
// //           .collection('invoices')
// //           .orderBy('createdAt', descending: true)
// //           .limit(_invoicesPerPage);

// //       if (_lastInvoiceDocument != null) {
// //         query = query.startAfterDocument(_lastInvoiceDocument!);
// //       }

// //       final invoicesSnapshot = await query.get();

// //       final List<Map<String, dynamic>> newInvoices = [];

// //       for (final doc in invoicesSnapshot.docs) {
// //         final data = doc.data();

// //         // تحويل البيانات بأمان مع القيم الافتراضية
// //         final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
// //         final tax3PercentDate = (data['tax3PercentDate'] as Timestamp?)
// //             ?.toDate();
// //         final tax14PercentDate = (data['tax14PercentDate'] as Timestamp?)
// //             ?.toDate();
// //         final taxDate = (data['taxDate'] as Timestamp?)?.toDate();

// //         newInvoices.add({
// //           'id': doc.id,
// //           'name': (data['name'] as String?) ?? 'فاتورة بدون اسم',
// //           'companyName': (data['companyName'] as String?) ?? 'شركة غير معروفة',
// //           'companyId': (data['companyId'] as String?) ?? '',
// //           'totalAmount': ((data['totalAmount'] as num?) ?? 0).toDouble(),
// //           'nolonTotal': ((data['nolonTotal'] as num?) ?? 0).toDouble(),
// //           'overnightTotal': ((data['overnightTotal'] as num?) ?? 0).toDouble(),
// //           'holidayTotal': ((data['holidayTotal'] as num?) ?? 0).toDouble(),
// //           'createdAt': createdAt,
// //           'taxDate': taxDate, // تاريخ الضريبة الذي تم اختياره
// //           'tax3Percent': ((data['tax3Percent'] as num?) ?? 0).toDouble(),
// //           'tax14Percent': ((data['tax14Percent'] as num?) ?? 0).toDouble(),
// //           'has3PercentTax': (data['has3PercentTax'] as bool?) ?? false,
// //           'has14PercentTax': (data['has14PercentTax'] as bool?) ?? false,
// //           'tax3PercentDate': tax3PercentDate,
// //           'tax14PercentDate': tax14PercentDate,
// //           'tripCount': (data['tripCount'] as int?) ?? 0,
// //           'isArchived': (data['isArchived'] as bool?) ?? false,
// //         });
// //       }

// //       setState(() {
// //         if (loadMore) {
// //           _allInvoices.addAll(newInvoices);
// //           _isLoadingMore = false;
// //         } else {
// //           _allInvoices = newInvoices;
// //           _isLoading = false;
// //         }

// //         _filteredInvoices = _applySearchFilter(
// //           _allInvoices
// //               .where((invoice) => !(invoice['isArchived'] ?? false))
// //               .toList(),
// //         );
// //         _lastInvoiceDocument = invoicesSnapshot.docs.isNotEmpty
// //             ? invoicesSnapshot.docs.last
// //             : null;
// //         _hasMoreInvoices = newInvoices.length == _invoicesPerPage;
// //       });

// //       // فصل الفواتير حسب نوع الضريبة مع الفلترة بالسنة
// //       _separateTaxInvoices();
// //     } catch (e) {
// //       setState(() {
// //         if (loadMore) {
// //           _isLoadingMore = false;
// //         } else {
// //           _isLoading = false;
// //         }
// //       });
// //       _showError('خطأ في تحميل الفواتير: $e');
// //     }
// //   }

// //   // ================================
// //   // فصل الفواتير حسب نوع الضريبة مع الفلترة بالسنة
// //   // ================================
// //   void _separateTaxInvoices() {
// //     setState(() {
// //       // فلترة فواتير 3% حسب السنة المحددة باستخدام taxDate
// //       _3PercentTaxInvoices = _allInvoices
// //           .where(
// //             (invoice) =>
// //                 invoice['has3PercentTax'] == true &&
// //                 _isInvoiceInSelectedYear(invoice, '3%'),
// //           )
// //           .toList();

// //       // فلترة فواتير 14% حسب السنة المحددة باستخدام taxDate
// //       _14PercentTaxInvoices = _allInvoices
// //           .where(
// //             (invoice) =>
// //                 invoice['has14PercentTax'] == true &&
// //                 _isInvoiceInSelectedYear(invoice, '14%'),
// //           )
// //           .toList();
// //     });

// //     // تحديث بيانات الأشهر بعد فصل الفواتير
// //     _prepareMonthlyData();
// //   }

// //   // ================================
// //   // التحقق مما إذا كانت الفاتورة في السنة المحددة
// //   // ================================
// //   bool _isInvoiceInSelectedYear(Map<String, dynamic> invoice, String taxType) {
// //     DateTime? dateToCheck;

// //     // أولاً: استخدم taxDate (التاريخ الذي تم اختياره عند نقل الفاتورة)
// //     dateToCheck = invoice['taxDate'] as DateTime?;

// //     // ثانياً: إذا لم يكن taxDate موجوداً، استخدم تاريخ الضريبة المحدد
// //     if (dateToCheck == null) {
// //       if (taxType == '3%') {
// //         dateToCheck = invoice['tax3PercentDate'] as DateTime?;
// //       } else {
// //         dateToCheck = invoice['tax14PercentDate'] as DateTime?;
// //       }
// //     }

// //     // ثالثاً: إذا لم يكن هناك تاريخ ضريبة، استخدم تاريخ الإنشاء
// //     dateToCheck ??= invoice['createdAt'] as DateTime?;

// //     return dateToCheck != null && dateToCheck.year == _selectedYear;
// //   }

// //   // ================================
// //   // تحضير بيانات الأشهر
// //   // ================================
// //   void _prepareMonthlyData() {
// //     List<Map<String, dynamic>> invoices = [];

// //     if (_currentSection == 1) {
// //       invoices = _3PercentTaxInvoices;
// //     } else if (_currentSection == 2) {
// //       invoices = _14PercentTaxInvoices;
// //     }

// //     // تجميع الفواتير حسب الشهر
// //     Map<int, List<Map<String, dynamic>>> monthlyInvoices = {};

// //     for (var invoice in invoices) {
// //       DateTime? invoiceDate = invoice['taxDate'] ?? invoice['createdAt'];
// //       if (invoiceDate != null) {
// //         int month = invoiceDate.month;
// //         monthlyInvoices.putIfAbsent(month, () => []);
// //         monthlyInvoices[month]!.add(invoice);
// //       }
// //     }

// //     // تحويل إلى قائمة من بيانات الأشهر
// //     List<Map<String, dynamic>> monthlyData = [];

// //     for (int month = 1; month <= 12; month++) {
// //       if (monthlyInvoices.containsKey(month)) {
// //         List<Map<String, dynamic>> monthInvoices = monthlyInvoices[month]!;
// //         double totalAmount = 0;
// //         double totalTax = 0;

// //         for (var invoice in monthInvoices) {
// //           totalAmount += invoice['totalAmount'];
// //           totalTax += _currentSection == 1
// //               ? invoice['tax3Percent']
// //               : invoice['tax14Percent'];
// //         }

// //         monthlyData.add({
// //           'monthNumber': month,
// //           'monthName': _getMonthName(month),
// //           'invoiceCount': monthInvoices.length,
// //           'totalAmount': totalAmount,
// //           'totalTax': totalTax,
// //           'invoices': monthInvoices,
// //         });
// //       } else {
// //         monthlyData.add({
// //           'monthNumber': month,
// //           'monthName': _getMonthName(month),
// //           'invoiceCount': 0,
// //           'totalAmount': 0.0,
// //           'totalTax': 0.0,
// //           'invoices': [],
// //         });
// //       }
// //     }

// //     setState(() {
// //       _monthlyTaxData = monthlyData;
// //     });
// //   }

// //   // ================================
// //   // الحصول على اسم الشهر
// //   // ================================
// //   String _getMonthName(int month) {
// //     switch (month) {
// //       case 1:
// //         return 'يناير';
// //       case 2:
// //         return 'فبراير';
// //       case 3:
// //         return 'مارس';
// //       case 4:
// //         return 'أبريل';
// //       case 5:
// //         return 'مايو';
// //       case 6:
// //         return 'يونيو';
// //       case 7:
// //         return 'يوليو';
// //       case 8:
// //         return 'أغسطس';
// //       case 9:
// //         return 'سبتمبر';
// //       case 10:
// //         return 'أكتوبر';
// //       case 11:
// //         return 'نوفمبر';
// //       case 12:
// //         return 'ديسمبر';
// //       default:
// //         return '';
// //     }
// //   }

// //   // ================================
// //   // تحديث بيانات الضرائب
// //   // ================================
// //   Future<void> _refreshTaxData() async {
// //     setState(() {
// //       _isLoading = true;
// //     });

// //     try {
// //       await _loadInvoices();
// //       await _loadTaxes();
// //     } catch (e) {
// //       _showError('خطأ في تحديث البيانات: $e');
// //     } finally {
// //       setState(() {
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   // ================================
// //   // تحميل بيانات الضرائب من Firestore
// //   // ================================
// //   Future<void> _loadTaxes({String? taxType}) async {
// //     try {
// //       if (taxType == '3%' || taxType == null) {
// //         QuerySnapshot tax3Snapshot;

// //         try {
// //           tax3Snapshot = await _firestore
// //               .collection('taxes')
// //               .where('taxType', isEqualTo: '3%')
// //               .orderBy('year', descending: true)
// //               .get();
// //         } catch (e) {
// //           // إذا فشل بسبب index، جلب بدون orderBy
// //           tax3Snapshot = await _firestore
// //               .collection('taxes')
// //               .where('taxType', isEqualTo: '3%')
// //               .get();
// //         }

// //         final List<Map<String, dynamic>> tax3List = [];
// //         for (final doc in tax3Snapshot.docs) {
// //           final data = doc.data() as Map<String, dynamic>;
// //           final totalBeforeTax = ((data['totalAmountBeforeTax'] as num?) ?? 0)
// //               .toDouble();
// //           final taxAmount = ((data['totalTaxAmount'] as num?) ?? 0).toDouble();

// //           tax3List.add({
// //             'id': doc.id,
// //             'taxType': data['taxType'] ?? '3%',
// //             'year': data['year'] ?? DateTime.now().year,
// //             'totalInvoices': data['totalInvoices'] ?? 0,
// //             'totalAmountBeforeTax': totalBeforeTax,
// //             'totalTaxAmount': taxAmount,
// //             'totalAmountAfterTax': totalBeforeTax - taxAmount,
// //             'invoiceIds': data['invoiceIds'] ?? [],
// //             'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
// //           });
// //         }

// //         // إذا تم الجلب بدون orderBy، قم بالترتيب محلياً
// //         if (tax3List.isNotEmpty) {
// //           tax3List.sort(
// //             (a, b) => (b['year'] as int).compareTo(a['year'] as int),
// //           );
// //         }

// //         setState(() {
// //           _taxes3Percent = tax3List;
// //         });
// //       }

// //       if (taxType == '14%' || taxType == null) {
// //         QuerySnapshot tax14Snapshot;

// //         try {
// //           tax14Snapshot = await _firestore
// //               .collection('taxes')
// //               .where('taxType', isEqualTo: '14%')
// //               .orderBy('year', descending: true)
// //               .get();
// //         } catch (e) {
// //           // إذا فشل بسبب index، جلب بدون orderBy
// //           tax14Snapshot = await _firestore
// //               .collection('taxes')
// //               .where('taxType', isEqualTo: '14%')
// //               .get();
// //         }

// //         final List<Map<String, dynamic>> tax14List = [];
// //         for (final doc in tax14Snapshot.docs) {
// //           final data = doc.data() as Map<String, dynamic>;
// //           final totalBeforeTax = ((data['totalAmountBeforeTax'] as num?) ?? 0)
// //               .toDouble();
// //           final taxAmount = ((data['totalTaxAmount'] as num?) ?? 0).toDouble();

// //           tax14List.add({
// //             'id': doc.id,
// //             'taxType': data['taxType'] ?? '14%',
// //             'year': data['year'] ?? DateTime.now().year,
// //             'totalInvoices': data['totalInvoices'] ?? 0,
// //             'totalAmountBeforeTax': totalBeforeTax,
// //             'totalTaxAmount': taxAmount,
// //             'totalAmountAfterTax': totalBeforeTax - taxAmount,
// //             'invoiceIds': data['invoiceIds'] ?? [],
// //             'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
// //           });
// //         }

// //         // إذا تم الجلب بدون orderBy، قم بالترتيب محلياً
// //         if (tax14List.isNotEmpty) {
// //           tax14List.sort(
// //             (a, b) => (b['year'] as int).compareTo(a['year'] as int),
// //           );
// //         }

// //         setState(() {
// //           _taxes14Percent = tax14List;
// //         });
// //       }

// //       // تحديث قائمة السنوات بناءً على السجلات الضريبية
// //       _updateAvailableYears();
// //     } catch (e) {
// //       _showError('خطأ في تحميل بيانات الضرائب: $e');
// //     }
// //   }

// //   // ================================
// //   // تحديث قائمة السنوات من السجلات الضريبية
// //   // ================================
// //   void _updateAvailableYears() {
// //     final Set<int> yearsSet = <int>{};

// //     // جمع السنوات من سجلات 3%
// //     for (final record in _taxes3Percent) {
// //       if (record['year'] != null) {
// //         yearsSet.add(record['year']);
// //       }
// //     }

// //     // جمع السنوات من سجلات 14%
// //     for (final record in _taxes14Percent) {
// //       if (record['year'] != null) {
// //         yearsSet.add(record['year']);
// //       }
// //     }

// //     // إضافة السنوات من الفواتير (استخدام taxDate أولاً)
// //     for (final invoice in _allInvoices) {
// //       // أولوية لـ taxDate
// //       final taxDate = invoice['taxDate'] as DateTime?;
// //       if (taxDate != null) {
// //         yearsSet.add(taxDate.year);
// //       } else {
// //         // إذا لم يكن هناك taxDate، استخدم تاريخ الضريبة
// //         final tax3Date = invoice['tax3PercentDate'] as DateTime?;
// //         if (tax3Date != null) {
// //           yearsSet.add(tax3Date.year);
// //         }

// //         final tax14Date = invoice['tax14PercentDate'] as DateTime?;
// //         if (tax14Date != null) {
// //           yearsSet.add(tax14Date.year);
// //         }

// //         // أخيراً، تاريخ الإنشاء
// //         final createdAt = invoice['createdAt'] as DateTime?;
// //         if (createdAt != null) {
// //           yearsSet.add(createdAt.year);
// //         }
// //       }
// //     }

// //     // إضافة السنة الحالية إذا كانت فارغة
// //     if (yearsSet.isEmpty) {
// //       yearsSet.add(DateTime.now().year);
// //     }

// //     // تحويل إلى قائمة وترتيب تنازلي
// //     final List<int> yearsList = yearsSet.toList()
// //       ..sort((a, b) => b.compareTo(a));

// //     setState(() {
// //       _availableYears = yearsList;
// //       if (_availableYears.isNotEmpty &&
// //           !_availableYears.contains(_selectedYear)) {
// //         _selectedYear = _availableYears.first;
// //       }
// //     });
// //   }

// //   // ================================
// //   // دالة التصفية المحلية
// //   // ================================
// //   List<Map<String, dynamic>> _applySearchFilter(
// //     List<Map<String, dynamic>> invoices,
// //   ) {
// //     if (_searchQuery.isEmpty) return invoices;
// //     return invoices
// //         .where(
// //           (invoice) =>
// //               invoice['companyName'].toLowerCase().contains(
// //                 _searchQuery.toLowerCase(),
// //               ) ||
// //               invoice['name'].toLowerCase().contains(
// //                 _searchQuery.toLowerCase(),
// //               ),
// //         )
// //         .toList();
// //   }

// //   // ================================
// //   // نقل فاتورة إلى كلا الضرائب وأرشفتها مع حفظ تلقائي
// //   // ================================
// //   Future<void> _moveToBothTaxBoxes(Map<String, dynamic> invoice) async {
// //     if (_currentSection == 0) {
// //       final selectedDate = await _showDatePickerDialog();
// //       if (selectedDate == null) return;

// //       final totalAmount = invoice['totalAmount'];
// //       final tax3Amount = totalAmount * 0.03;
// //       final tax14Amount = totalAmount * 0.14;
// //       final selectedYear = selectedDate.year;

// //       try {
// //         // تحديث الفاتورة وإضافة أرشفة لكلا الضرائب
// //         await _firestore.collection('invoices').doc(invoice['id']).update({
// //           'taxDate': Timestamp.fromDate(selectedDate),
// //           'tax3Percent': tax3Amount,
// //           'tax14Percent': tax14Amount,
// //           'has3PercentTax': true,
// //           'has14PercentTax': true,
// //           'tax3PercentDate': Timestamp.now(),
// //           'tax14PercentDate': Timestamp.now(),
// //           'isArchived': true,
// //         });

// //         // تحديث الفاتورة محلياً
// //         setState(() {
// //           final index = _allInvoices.indexWhere(
// //             (inv) => inv['id'] == invoice['id'],
// //           );
// //           if (index != -1) {
// //             _allInvoices[index] = {
// //               ..._allInvoices[index],
// //               'taxDate': selectedDate,
// //               'tax3Percent': tax3Amount,
// //               'tax14Percent': tax14Amount,
// //               'has3PercentTax': true,
// //               'has14PercentTax': true,
// //               'tax3PercentDate': DateTime.now(),
// //               'tax14PercentDate': DateTime.now(),
// //               'isArchived': true,
// //             };
// //           }

// //           // إعادة فلترة الفواتير
// //           _filteredInvoices = _applySearchFilter(
// //             _allInvoices.where((inv) => !(inv['isArchived'] ?? false)).toList(),
// //           );

// //           _separateTaxInvoices();
// //         });

// //         // حفظ تلقائي للسجلات الضريبية
// //         await _autoSaveTaxRecords(selectedYear);

// //         _showSuccess(
// //           'تم نقل الفاتورة إلى كلا صندوقي الضرائب وأرشفتها وحفظ السجلات تلقائياً',
// //         );
// //       } catch (e) {
// //         _showError('خطأ في نقل الفاتورة: $e');
// //       }
// //     }
// //   }

// //   // ================================
// //   // حفظ تلقائي للسجلات الضريبية
// //   // ================================
// //   Future<void> _autoSaveTaxRecords(int year) async {
// //     try {
// //       // حفظ سجل 3% للسنة المحددة
// //       await _saveTaxRecordForYear('3%', year);

// //       // حفظ سجل 14% للسنة المحددة
// //       await _saveTaxRecordForYear('14%', year);

// //       // إعادة تحميل بيانات الضرائب
// //       await _loadTaxes();
// //     } catch (e) {
// //       _showError('خطأ في الحفظ التلقائي للسجلات: $e');
// //     }
// //   }

// //   // ================================
// //   // حفظ سجل ضريبي لسنة محددة
// //   // ================================
// //   Future<void> _saveTaxRecordForYear(String taxType, int year) async {
// //     try {
// //       // الحصول على الفواتير المناسبة للسنة ونوع الضريبة
// //       List<Map<String, dynamic>> yearInvoices;

// //       if (taxType == '3%') {
// //         yearInvoices = _3PercentTaxInvoices
// //             .where((invoice) => _getInvoiceYear(invoice, taxType) == year)
// //             .toList();
// //       } else {
// //         yearInvoices = _14PercentTaxInvoices
// //             .where((invoice) => _getInvoiceYear(invoice, taxType) == year)
// //             .toList();
// //       }

// //       if (yearInvoices.isEmpty) {
// //         print('لا توجد فواتير $taxType لسنة $year');
// //         return;
// //       }

// //       // حساب الإجماليات
// //       double totalBeforeTax = 0;
// //       double totalTaxAmount = 0;
// //       List<String> invoiceIds = [];

// //       for (var invoice in yearInvoices) {
// //         totalBeforeTax += invoice['totalAmount'];
// //         totalTaxAmount += taxType == '3%'
// //             ? invoice['tax3Percent']
// //             : invoice['tax14Percent'];
// //         invoiceIds.add(invoice['id']);
// //       }

// //       final totalAfterTax = totalBeforeTax - totalTaxAmount;

// //       // البحث عن سجل موجود لنفس السنة ونوع الضريبة
// //       final existingRecord = await _findExistingTaxRecord(taxType, year);

// //       if (existingRecord != null) {
// //         // تحديث السجل الحالي
// //         await _firestore.collection('taxes').doc(existingRecord['id']).update({
// //           'totalInvoices': yearInvoices.length,
// //           'totalAmountBeforeTax': totalBeforeTax,
// //           'totalTaxAmount': totalTaxAmount,
// //           'totalAmountAfterTax': totalAfterTax,
// //           'invoiceIds': invoiceIds,
// //           'updatedAt': Timestamp.now(),
// //         });
// //         print('تم تحديث سجل $taxType لسنة $year');
// //       } else {
// //         // إنشاء سجل جديد
// //         await _firestore.collection('taxes').add({
// //           'taxType': taxType,
// //           'year': year,
// //           'totalInvoices': yearInvoices.length,
// //           'totalAmountBeforeTax': totalBeforeTax,
// //           'totalTaxAmount': totalTaxAmount,
// //           'totalAmountAfterTax': totalAfterTax,
// //           'invoiceIds': invoiceIds,
// //           'createdAt': Timestamp.now(),
// //         });
// //         print('تم إنشاء سجل جديد $taxType لسنة $year');
// //       }
// //     } catch (e) {
// //       print('خطأ في حفظ سجل $taxType لسنة $year: $e');
// //       rethrow;
// //     }
// //   }

// //   // ================================
// //   // الحصول على سنة الفاتورة بناءً على نوع الضريبة
// //   // ================================
// //   int _getInvoiceYear(Map<String, dynamic> invoice, String taxType) {
// //     // أولوية لـ taxDate
// //     final taxDate = invoice['taxDate'] as DateTime?;
// //     if (taxDate != null) {
// //       return taxDate.year;
// //     }

// //     // إذا لم يكن هناك taxDate، استخدم تاريخ الضريبة المحدد
// //     if (taxType == '3%') {
// //       final tax3Date = invoice['tax3PercentDate'] as DateTime?;
// //       if (tax3Date != null) return tax3Date.year;
// //     } else {
// //       final tax14Date = invoice['tax14PercentDate'] as DateTime?;
// //       if (tax14Date != null) return tax14Date.year;
// //     }

// //     // أخيراً، تاريخ الإنشاء
// //     final createdAt = invoice['createdAt'] as DateTime?;
// //     return createdAt?.year ?? DateTime.now().year;
// //   }

// //   // ================================
// //   // البحث عن سجل ضريبي موجود
// //   // ================================
// //   Future<Map<String, dynamic>?> _findExistingTaxRecord(
// //     String taxType,
// //     int year,
// //   ) async {
// //     try {
// //       final querySnapshot = await _firestore
// //           .collection('taxes')
// //           .where('taxType', isEqualTo: taxType)
// //           .where('year', isEqualTo: year)
// //           .limit(1)
// //           .get();

// //       if (querySnapshot.docs.isNotEmpty) {
// //         final doc = querySnapshot.docs.first;
// //         final data = doc.data();
// //         return {'id': doc.id, ...data};
// //       }
// //       return null;
// //     } catch (e) {
// //       print('خطأ في البحث عن سجل ضريبي: $e');
// //       return null;
// //     }
// //   }

// //   // ================================
// //   // تحميل الفواتير المرتبطة بسجل ضريبي
// //   // ================================
// //   Future<void> _loadTaxRecordInvoices(Map<String, dynamic> taxRecord) async {
// //     final invoiceIds = List<String>.from(taxRecord['invoiceIds'] ?? []);

// //     setState(() {
// //       _taxRecordInvoices = [];
// //       _isLoading = true;
// //     });

// //     try {
// //       final List<Map<String, dynamic>> invoicesList = [];

// //       for (final invoiceId in invoiceIds) {
// //         final doc = await _firestore
// //             .collection('invoices')
// //             .doc(invoiceId)
// //             .get();

// //         if (doc.exists) {
// //           final data = doc.data() as Map<String, dynamic>;
// //           final taxAmount = taxRecord['taxType'] == '3%'
// //               ? ((data['tax3Percent'] as num?) ?? 0).toDouble()
// //               : ((data['tax14Percent'] as num?) ?? 0).toDouble();

// //           invoicesList.add({
// //             'id': doc.id,
// //             'name': (data['name'] as String?) ?? 'فاتورة بدون اسم',
// //             'companyName':
// //                 (data['companyName'] as String?) ?? 'شركة غير معروفة',
// //             'totalAmount': ((data['totalAmount'] as num?) ?? 0).toDouble(),
// //             'taxAmount': taxAmount,
// //             'amountAfterTax':
// //                 ((data['totalAmount'] as num?) ?? 0).toDouble() - taxAmount,
// //             'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
// //           });
// //         }
// //       }

// //       setState(() {
// //         _taxRecordInvoices = invoicesList;
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() => _isLoading = false);
// //       _showError('خطأ في تحميل تفاصيل السجل الضريبي: $e');
// //     }
// //   }

// //   // ================================
// //   // عرض نافذة اختيار التاريخ
// //   // ================================
// //   Future<DateTime?> _showDatePickerDialog() async {
// //     final selectedDate = await showDatePicker(
// //       context: context,
// //       initialDate: DateTime.now(),
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime(2030),
// //       builder: (context, child) {
// //         return Theme(
// //           data: ThemeData.light().copyWith(
// //             primaryColor: const Color(0xFF3498DB),
// //             colorScheme: const ColorScheme.light(primary: Color(0xFF3498DB)),
// //             buttonTheme: const ButtonThemeData(
// //               textTheme: ButtonTextTheme.primary,
// //             ),
// //           ),
// //           child: child!,
// //         );
// //       },
// //     );

// //     if (selectedDate != null) {
// //       // تحديث السنة المحددة عند اختيار تاريخ
// //       setState(() {
// //         _selectedYear = selectedDate.year;
// //       });

// //       // إعادة تحميل البيانات للفلترة حسب السنة الجديدة
// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         _separateTaxInvoices();
// //       });
// //     }

// //     return selectedDate;
// //   }

// //   // ================================
// //   // عرض تفاصيل سجل ضريبي
// //   // ================================
// //   Future<void> _showTaxRecordDetails(Map<String, dynamic> taxRecord) async {
// //     setState(() {
// //       _selectedTaxRecord = taxRecord;
// //       _selectedMonthIndex = -1;
// //       _monthInvoices = [];
// //     });

// //     await _loadTaxRecordInvoices(taxRecord);
// //     _showTaxDetailsSheet(taxRecord);
// //   }

// //   // ================================
// //   // عرض تفاصيل السجل الضريبي
// //   // ================================
// //   void _showTaxDetailsSheet(Map<String, dynamic> taxRecord) {
// //     final taxType = taxRecord['taxType'];
// //     final year = taxRecord['year'];
// //     final totalInvoices = taxRecord['totalInvoices'];
// //     final totalBeforeTax = taxRecord['totalAmountBeforeTax'];
// //     final taxAmount = taxRecord['totalTaxAmount'];
// //     final totalAfterTax = taxRecord['totalAmountAfterTax'];

// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (context) {
// //         return Container(
// //           height: MediaQuery.of(context).size.height * 0.9,
// //           decoration: const BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.only(
// //               topLeft: Radius.circular(20),
// //               topRight: Radius.circular(20),
// //             ),
// //           ),
// //           child: Column(
// //             children: [
// //               // رأس البطاقة
// //               Container(
// //                 padding: const EdgeInsets.all(16),
// //                 decoration: BoxDecoration(
// //                   color: taxType == '3%'
// //                       ? const Color(0xFFE3F2FD)
// //                       : const Color(0xFFE8F5E9),
// //                   borderRadius: const BorderRadius.only(
// //                     topLeft: Radius.circular(20),
// //                     topRight: Radius.circular(20),
// //                   ),
// //                 ),
// //                 child: Row(
// //                   children: [
// //                     Icon(
// //                       Icons.receipt_long,
// //                       color: taxType == '3%'
// //                           ? const Color(0xFF1976D2)
// //                           : const Color(0xFF2E7D32),
// //                       size: 30,
// //                     ),
// //                     const SizedBox(width: 12),
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             'سجل ضريبة $taxType - سنة $year',
// //                             style: TextStyle(
// //                               fontSize: 18,
// //                               fontWeight: FontWeight.bold,
// //                               color: taxType == '3%'
// //                                   ? const Color(0xFF1976D2)
// //                                   : const Color(0xFF2E7D32),
// //                             ),
// //                           ),
// //                           Text(
// //                             'إنشئ في: ${_formatDate(taxRecord['createdAt'])}',
// //                             style: const TextStyle(
// //                               fontSize: 12,
// //                               color: Colors.grey,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     IconButton(
// //                       icon: const Icon(Icons.close, color: Colors.grey),
// //                       onPressed: () => Navigator.pop(context),
// //                     ),
// //                   ],
// //                 ),
// //               ),

// //               // الإجماليات
// //               Padding(
// //                 padding: const EdgeInsets.all(16),
// //                 child: _buildTaxSummaryCard(
// //                   taxType: taxType,
// //                   totalInvoices: totalInvoices,
// //                   totalBeforeTax: totalBeforeTax,
// //                   taxAmount: taxAmount,
// //                   totalAfterTax: totalAfterTax,
// //                 ),
// //               ),

// //               // عنوان الفواتير
// //               Padding(
// //                 padding: const EdgeInsets.symmetric(horizontal: 16),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     const Text(
// //                       'الفواتير المضمنة:',
// //                       style: TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                     Text(
// //                       '(${_taxRecordInvoices.length}) فاتورة',
// //                       style: const TextStyle(color: Colors.grey),
// //                     ),
// //                   ],
// //                 ),
// //               ),

// //               // قائمة الفواتير
// //               Expanded(
// //                 child: _isLoading
// //                     ? const Center(child: CircularProgressIndicator())
// //                     : _taxRecordInvoices.isEmpty
// //                     ? Center(
// //                         child: Column(
// //                           mainAxisAlignment: MainAxisAlignment.center,
// //                           children: [
// //                             Icon(
// //                               Icons.receipt,
// //                               size: 60,
// //                               color: Colors.grey[400],
// //                             ),
// //                             const SizedBox(height: 16),
// //                             const Text(
// //                               'لا توجد فواتير في هذا السجل',
// //                               style: TextStyle(
// //                                 color: Colors.grey,
// //                                 fontSize: 16,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       )
// //                     : ListView.builder(
// //                         padding: const EdgeInsets.all(16),
// //                         itemCount: _taxRecordInvoices.length,
// //                         itemBuilder: (context, index) {
// //                           final invoice = _taxRecordInvoices[index];
// //                           return _buildTaxInvoiceCard(invoice, taxType, index);
// //                         },
// //                       ),
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   // ================================
// //   // بناء بطاقة ملخص الضريبة
// //   // ================================
// //   Widget _buildTaxSummaryCard({
// //     required String taxType,
// //     required int totalInvoices,
// //     required double totalBeforeTax,
// //     required double taxAmount,
// //     required double totalAfterTax,
// //   }) {
// //     return Card(
// //       elevation: 4,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           children: [
// //             // عنوان البطاقة
// //             Text(
// //               'إحصائيات ضريبة $taxType',
// //               style: TextStyle(
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.bold,
// //                 color: taxType == '3%' ? Colors.blue[800] : Colors.green[800],
// //               ),
// //             ),
// //             const SizedBox(height: 20),

// //             // عدد الفواتير
// //             _buildSummaryItem(
// //               icon: Icons.receipt,
// //               label: 'عدد الفواتير',
// //               value: '$totalInvoices',
// //               color: const Color(0xFF3498DB),
// //             ),

// //             const SizedBox(height: 16),

// //             // إجمالي قبل الضريبة
// //             _buildSummaryItem(
// //               icon: Icons.attach_money,
// //               label: 'الإجمالي قبل الضريبة',
// //               value: _formatCurrency(totalBeforeTax),
// //               color: Colors.blue[700]!,
// //             ),

// //             const SizedBox(height: 16),

// //             // قيمة الضريبة
// //             _buildSummaryItem(
// //               icon: taxType == '3%'
// //                   ? Icons.account_balance_wallet
// //                   : Icons.account_balance,
// //               label: 'قيمة الضريبة $taxType',
// //               value: _formatCurrency(taxAmount),
// //               color: taxType == '3%' ? Colors.blue[800]! : Colors.green[800]!,
// //             ),

// //             const SizedBox(height: 16),

// //             // الإجمالي بعد الضريبة
// //             Container(
// //               padding: const EdgeInsets.all(16),
// //               decoration: BoxDecoration(
// //                 color: Colors.red[50],
// //                 borderRadius: BorderRadius.circular(12),
// //                 border: Border.all(color: Colors.red[100]!),
// //               ),
// //               child: Row(
// //                 children: [
// //                   Icon(Icons.money_off, color: Colors.red[700], size: 24),
// //                   const SizedBox(width: 12),
// //                   Expanded(
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           'الإجمالي بعد خصم الضريبة',
// //                           style: TextStyle(
// //                             fontSize: 14,
// //                             fontWeight: FontWeight.bold,
// //                             color: Colors.red[700],
// //                           ),
// //                         ),
// //                         const SizedBox(height: 4),
// //                         Text(
// //                           _formatCurrency(totalAfterTax),
// //                           style: const TextStyle(
// //                             fontSize: 20,
// //                             fontWeight: FontWeight.bold,
// //                             color: Colors.red,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildSummaryItem({
// //     required IconData icon,
// //     required String label,
// //     required String value,
// //     required Color color,
// //   }) {
// //     return Container(
// //       padding: const EdgeInsets.all(12),
// //       decoration: BoxDecoration(
// //         color: Colors.grey[50],
// //         borderRadius: BorderRadius.circular(10),
// //       ),
// //       child: Row(
// //         children: [
// //           Icon(icon, color: color, size: 22),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   label,
// //                   style: const TextStyle(fontSize: 14, color: Colors.grey),
// //                 ),
// //                 const SizedBox(height: 4),
// //                 Text(
// //                   value,
// //                   style: TextStyle(
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.bold,
// //                     color: color,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ================================
// //   // بناء بطاقة الفاتورة في تفاصيل الضريبة
// //   // ================================
// //   Widget _buildTaxInvoiceCard(
// //     Map<String, dynamic> invoice,
// //     String taxType,
// //     int index,
// //   ) {
// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 12),
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // رأس البطاقة
// //             Row(
// //               children: [
// //                 Container(
// //                   width: 36,
// //                   height: 36,
// //                   decoration: BoxDecoration(
// //                     color: taxType == '3%' ? Colors.blue[50] : Colors.green[50],
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                   child: Center(
// //                     child: Text(
// //                       '${index + 1}',
// //                       style: TextStyle(
// //                         fontWeight: FontWeight.bold,
// //                         color: taxType == '3%'
// //                             ? Colors.blue[800]
// //                             : Colors.green[800],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 12),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         invoice['name'],
// //                         style: const TextStyle(
// //                           fontWeight: FontWeight.bold,
// //                           fontSize: 16,
// //                         ),
// //                       ),
// //                       Text(
// //                         invoice['companyName'],
// //                         style: TextStyle(fontSize: 13, color: Colors.grey[600]),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),

// //             const SizedBox(height: 16),

// //             // تفاصيل المبلغ
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       'سعر الفاتورة',
// //                       style: TextStyle(fontSize: 13, color: Colors.grey[600]),
// //                     ),
// //                     const SizedBox(height: 4),
// //                     Text(
// //                       _formatCurrency(invoice['totalAmount']),
// //                       style: const TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                         color: Colors.blue,
// //                       ),
// //                     ),
// //                   ],
// //                 ),

// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.end,
// //                   children: [
// //                     Text(
// //                       'ضريبة $taxType',
// //                       style: TextStyle(fontSize: 13, color: Colors.grey[600]),
// //                     ),
// //                     const SizedBox(height: 4),
// //                     Text(
// //                       _formatCurrency(invoice['taxAmount']),
// //                       style: TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                         color: taxType == '3%'
// //                             ? Colors.blue[800]
// //                             : Colors.green[800],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),

// //             const SizedBox(height: 12),

// //             // الإجمالي بعد الضريبة
// //             Container(
// //               padding: const EdgeInsets.all(12),
// //               decoration: BoxDecoration(
// //                 color: Colors.red[50],
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Text(
// //                     'الإجمالي بعد الضريبة',
// //                     style: TextStyle(
// //                       fontSize: 14,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.red[700],
// //                     ),
// //                   ),
// //                   Text(
// //                     _formatCurrency(invoice['amountAfterTax']),
// //                     style: const TextStyle(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.red,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),

// //             const SizedBox(height: 12),

// //             // تاريخ الفاتورة
// //             Text(
// //               'تاريخ الفاتورة: ${_formatDate(invoice['createdAt'])}',
// //               style: const TextStyle(fontSize: 12, color: Colors.grey),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ================================
// //   // دوال مساعدة
// //   // ================================
// //   void _showError(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         backgroundColor: Colors.red,
// //         duration: const Duration(seconds: 3),
// //       ),
// //     );
// //   }

// //   void _showSuccess(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         backgroundColor: Colors.green,
// //         duration: const Duration(seconds: 2),
// //       ),
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
// //       _selectedTaxRecord = null;
// //       _taxRecordInvoices.clear();
// //       _selectedMonthIndex = -1;
// //       _monthInvoices = [];
// //     });

// //     // تحضير بيانات الأشهر عند تغيير القسم
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _prepareMonthlyData();
// //     });
// //   }

// //   void _onYearChanged(int? value) {
// //     if (value != null) {
// //       setState(() {
// //         _selectedYear = value;
// //         _selectedTaxRecord = null;
// //         _taxRecordInvoices.clear();
// //         _selectedMonthIndex = -1;
// //         _monthInvoices = [];
// //       });

// //       // إعادة فلترة الفواتير حسب السنة الجديدة
// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         _separateTaxInvoices();
// //       });
// //     }
// //   }

// //   // ================================
// //   // وظائف جديدة للأشهر
// //   // ================================
// //   void _selectMonth(int monthIndex) {
// //     setState(() {
// //       if (_selectedMonthIndex == monthIndex) {
// //         // إذا كان نفس الشهر، إلغاء التحديد
// //         _selectedMonthIndex = -1;
// //         _monthInvoices = [];
// //       } else {
// //         _selectedMonthIndex = monthIndex;
// //         _monthInvoices = _monthlyTaxData[monthIndex]['invoices'];
// //       }
// //     });
// //   }

// //   // ================================
// //   // بناء واجهة
// //   // ================================
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF4F6F8),
// //       body: Column(
// //         children: [
// //           _buildCustomAppBar(),
// //           _buildYearFilter(),
// //           _buildSectionTabs(),
// //           Expanded(
// //             child: _isLoading && _allInvoices.isEmpty
// //                 ? const Center(child: CircularProgressIndicator())
// //                 : _currentSection == 0
// //                 ? _buildInvoicesSection()
// //                 : _currentSection == 1
// //                 ? _build3PercentTaxSection()
// //                 : _build14PercentTaxSection(),
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
// //             const Icon(Icons.request_quote, color: Colors.white, size: 28),
// //             const SizedBox(width: 8),
// //             const Expanded(
// //               child: Center(
// //                 child: Text(
// //                   'إدارة الضرائب',
// //                   style: TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 20,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             // IconButton(
// //             //   icon: const Icon(Icons.refresh, color: Colors.white),
// //             //   onPressed: _refreshTaxData,
// //             //   tooltip: 'تحديث البيانات',
// //             // ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildYearFilter() {
// //     return Container(
// //       padding: const EdgeInsets.all(12),
// //       color: Colors.white,
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           const Text(
// //             'فلتر حسب السنة:',
// //             style: TextStyle(
// //               fontWeight: FontWeight.bold,
// //               color: Color(0xFF2C3E50),
// //             ),
// //           ),
// //           DropdownButton<int>(
// //             value: _selectedYear,
// //             onChanged: _onYearChanged,
// //             items: _availableYears
// //                 .map(
// //                   (year) =>
// //                       DropdownMenuItem(value: year, child: Text('سنة $year')),
// //                 )
// //                 .toList(),
// //             style: const TextStyle(
// //               color: Color(0xFF3498DB),
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildSectionTabs() {
// //     return Container(
// //       color: Colors.white,
// //       child: Row(
// //         children: [
// //           _buildSectionTab(0, Icons.receipt, 'جميع الفواتير'),
// //           _buildSectionTab(1, Icons.account_balance_wallet, 'صندوق 3%'),
// //           _buildSectionTab(2, Icons.account_balance, 'صندوق 14%'),
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
// //             color: isActive
// //                 ? (section == 1
// //                       ? Colors.blue
// //                       : section == 2
// //                       ? Colors.green
// //                       : const Color(0xFF3498DB))
// //                 : Colors.white,
// //             border: Border(
// //               bottom: BorderSide(
// //                 color: isActive
// //                     ? (section == 1
// //                           ? Colors.blue
// //                           : section == 2
// //                           ? Colors.green
// //                           : const Color(0xFF3498DB))
// //                     : Colors.grey[300]!,
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

// //   Widget _buildInvoicesSection() {
// //     return Column(
// //       children: [
// //         // شريط البحث
// //         _buildSearchBar(),

// //         // تبويب السجل
// //         _buildArchiveTab(),

// //         Expanded(
// //           child: _filteredInvoices.isEmpty && !_isLoading
// //               ? Center(
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Icon(Icons.receipt, size: 80, color: Colors.grey[400]),
// //                       const SizedBox(height: 16),
// //                       const Text(
// //                         'لا توجد فواتير',
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           color: Colors.grey,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 )
// //               : NotificationListener<ScrollNotification>(
// //                   onNotification: (ScrollNotification scrollInfo) {
// //                     if (!_isLoadingMore &&
// //                         _hasMoreInvoices &&
// //                         scrollInfo.metrics.pixels ==
// //                             scrollInfo.metrics.maxScrollExtent) {
// //                       _loadInvoices(loadMore: true);
// //                       return true;
// //                     }
// //                     return false;
// //                   },
// //                   child: ListView.builder(
// //                     padding: const EdgeInsets.all(8),
// //                     itemCount:
// //                         _filteredInvoices.length + (_hasMoreInvoices ? 1 : 0),
// //                     itemBuilder: (context, index) {
// //                       if (index == _filteredInvoices.length) {
// //                         return _buildLoadMoreIndicator();
// //                       }
// //                       final invoice = _filteredInvoices[index];
// //                       return _buildInvoiceCard(invoice, index);
// //                     },
// //                   ),
// //                 ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildArchiveTab() {
// //     return Container(
// //       color: Colors.white,
// //       child: Row(
// //         children: [
// //           Expanded(
// //             child: TextButton(
// //               onPressed: () {
// //                 setState(() {
// //                   _filteredInvoices = _applySearchFilter(
// //                     _allInvoices
// //                         .where((invoice) => !(invoice['isArchived'] ?? false))
// //                         .toList(),
// //                   );
// //                 });
// //               },
// //               child: Text(
// //                 'الفواتير النشطة',
// //                 style: TextStyle(
// //                   color: Colors.blue,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ),
// //           ),
// //           Expanded(
// //             child: TextButton(
// //               onPressed: () {
// //                 setState(() {
// //                   _filteredInvoices = _applySearchFilter(
// //                     _allInvoices
// //                         .where((invoice) => (invoice['isArchived'] ?? false))
// //                         .toList(),
// //                   );
// //                 });
// //               },
// //               child: Text(
// //                 'السجل',
// //                 style: TextStyle(
// //                   color: Colors.grey,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildLoadMoreIndicator() {
// //     return Padding(
// //       padding: const EdgeInsets.all(16),
// //       child: Center(
// //         child: _isLoadingMore
// //             ? const CircularProgressIndicator()
// //             : ElevatedButton(
// //                 onPressed: () => _loadInvoices(loadMore: true),
// //                 child: const Text('تحميل المزيد'),
// //               ),
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
// //                     _filteredInvoices = _applySearchFilter(
// //                       _allInvoices
// //                           .where((invoice) => !(invoice['isArchived'] ?? false))
// //                           .toList(),
// //                     );
// //                   });
// //                 },
// //                 decoration: const InputDecoration(
// //                   hintText: 'ابحث عن فاتورة أو شركة...',
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
// //                     _filteredInvoices = _applySearchFilter(
// //                       _allInvoices
// //                           .where((invoice) => !(invoice['isArchived'] ?? false))
// //                           .toList(),
// //                     );
// //                   });
// //                 },
// //                 child: const Icon(Icons.clear, size: 18, color: Colors.grey),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildInvoiceCard(Map<String, dynamic> invoice, int index) {
// //     final has3Percent = invoice['has3PercentTax'] == true;
// //     final has14Percent = invoice['has14PercentTax'] == true;
// //     final isArchived = invoice['isArchived'] == true;
// //     final taxDate = invoice['taxDate'] as DateTime?;

// //     return Card(
// //       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: ExpansionTile(
// //         leading: Container(
// //           width: 40,
// //           height: 40,
// //           decoration: BoxDecoration(
// //             color: isArchived
// //                 ? Colors.grey[200]
// //                 : has3Percent || has14Percent
// //                 ? (has14Percent ? Colors.green[50] : Colors.blue[50])
// //                 : const Color(0xFFF4F6F8),
// //             borderRadius: BorderRadius.circular(8),
// //           ),
// //           child: Center(
// //             child: Text(
// //               '${index + 1}',
// //               style: TextStyle(
// //                 fontWeight: FontWeight.bold,
// //                 color: isArchived
// //                     ? Colors.grey[600]
// //                     : has3Percent || has14Percent
// //                     ? (has14Percent ? Colors.green[800] : Colors.blue[800])
// //                     : const Color(0xFF2C3E50),
// //               ),
// //             ),
// //           ),
// //         ),
// //         title: Text(
// //           invoice['name'],
// //           style: TextStyle(
// //             fontWeight: FontWeight.bold,
// //             fontSize: 16,
// //             color: isArchived ? Colors.grey[600] : const Color(0xFF2C3E50),
// //           ),
// //         ),
// //         subtitle: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               invoice['companyName'],
// //               style: TextStyle(
// //                 fontSize: 14,
// //                 color: isArchived ? Colors.grey[500] : Colors.grey[700],
// //               ),
// //             ),
// //             if (taxDate != null)
// //               Text(
// //                 'تاريخ الضريبة: ${_formatDate(taxDate)}',
// //                 style: const TextStyle(
// //                   fontSize: 12,
// //                   color: Colors.blue,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //           ],
// //         ),
// //         trailing: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Text(
// //               _formatCurrency(invoice['totalAmount']),
// //               style: TextStyle(
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 16,
// //                 color: isArchived ? Colors.grey[600] : const Color(0xFF2E7D32),
// //               ),
// //             ),
// //             const SizedBox(height: 3),
// //             if (has3Percent || has14Percent)
// //               Container(
// //                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// //                 decoration: BoxDecoration(
// //                   color: isArchived
// //                       ? Colors.grey[100]
// //                       : has14Percent
// //                       ? Colors.green[50]
// //                       : Colors.blue[50],
// //                   borderRadius: BorderRadius.circular(10),
// //                   border: Border.all(
// //                     color: isArchived
// //                         ? Colors.grey[300]!
// //                         : has14Percent
// //                         ? Colors.green[100]!
// //                         : Colors.blue[100]!,
// //                   ),
// //                 ),
// //                 child: Row(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     if (has3Percent)
// //                       Text(
// //                         '3%  ',
// //                         style: TextStyle(
// //                           fontSize: 10,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.blue[800],
// //                         ),
// //                       ),
// //                     if (has3Percent && has14Percent)
// //                       const Text(' /  ', style: TextStyle(fontSize: 10)),
// //                     if (has14Percent)
// //                       Text(
// //                         ' 14%',
// //                         style: TextStyle(
// //                           fontSize: 10,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.green[800],
// //                         ),
// //                       ),
// //                   ],
// //                 ),
// //               ),
// //           ],
// //         ),
// //         children: [
// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //             child: Column(
// //               children: [
// //                 // زر نقل إلى الضرائب
// //                 if (!isArchived && (!has3Percent || !has14Percent))
// //                   SizedBox(
// //                     width: double.infinity,
// //                     child: ElevatedButton.icon(
// //                       onPressed: () => _moveToBothTaxBoxes(invoice),
// //                       icon: const Icon(Icons.account_balance_wallet, size: 20),
// //                       label: const Text('نقل إلى الضرائب'),
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: const Color(0xFF3498DB),
// //                         foregroundColor: Colors.white,
// //                         padding: const EdgeInsets.symmetric(vertical: 14),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(10),
// //                         ),
// //                       ),
// //                     ),
// //                   ),

// //                 const SizedBox(height: 12),

// //                 // إحصائيات الفاتورة
// //                 Container(
// //                   padding: const EdgeInsets.all(16),
// //                   decoration: BoxDecoration(
// //                     color: const Color(0xFFF8F9FA),
// //                     borderRadius: BorderRadius.circular(12),
// //                     border: Border.all(color: Colors.grey[200]!),
// //                   ),
// //                   child: Column(
// //                     children: [
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Text(
// //                             'عدد الرحلات:',
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               color: isArchived
// //                                   ? Colors.grey[600]
// //                                   : Colors.black,
// //                             ),
// //                           ),
// //                           Text(
// //                             '${invoice['tripCount']}',
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               color: isArchived
// //                                   ? Colors.grey[600]
// //                                   : const Color(0xFF3498DB),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 8),
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Text(
// //                             'إجمالي النولون:',
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               color: isArchived
// //                                   ? Colors.grey[600]
// //                                   : Colors.green,
// //                             ),
// //                           ),
// //                           Text(
// //                             _formatCurrency(invoice['nolonTotal']),
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               color: isArchived
// //                                   ? Colors.grey[600]
// //                                   : Colors.green,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 8),
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Text(
// //                             'إجمالي المبيت:',
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               color: isArchived
// //                                   ? Colors.grey[600]
// //                                   : Colors.orange,
// //                             ),
// //                           ),
// //                           Text(
// //                             _formatCurrency(invoice['overnightTotal']),
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               color: isArchived
// //                                   ? Colors.grey[600]
// //                                   : Colors.orange,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 8),
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Text(
// //                             'إجمالي العطلة:',
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               color: isArchived ? Colors.grey[600] : Colors.red,
// //                             ),
// //                           ),
// //                           Text(
// //                             _formatCurrency(invoice['holidayTotal']),
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               color: isArchived ? Colors.grey[600] : Colors.red,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _build3PercentTaxSection() {
// //     // استخدام القائمة المحدثة مباشرة
// //     return _buildTaxSection(
// //       taxType: '3%',
// //       invoices: _3PercentTaxInvoices,
// //       taxRecords: _taxes3Percent
// //           .where((record) => record['year'] == _selectedYear)
// //           .toList(),
// //       color: Colors.blue,
// //     );
// //   }

// //   Widget _build14PercentTaxSection() {
// //     // استخدام القائمة المحدثة مباشرة
// //     return _buildTaxSection(
// //       taxType: '14%',
// //       invoices: _14PercentTaxInvoices,
// //       taxRecords: _taxes14Percent
// //           .where((record) => record['year'] == _selectedYear)
// //           .toList(),
// //       color: Colors.green,
// //     );
// //   }

// //   Widget _buildTaxSection({
// //     required String taxType,
// //     required List<Map<String, dynamic>> invoices,
// //     required List<Map<String, dynamic>> taxRecords,
// //     required Color color,
// //   }) {
// //     // حساب الإجماليات للسنة
// //     double totalBeforeTax = 0;
// //     double totalTaxAmount = 0;
// //     for (var invoice in invoices) {
// //       totalBeforeTax += invoice['totalAmount'];
// //       totalTaxAmount += taxType == '3%'
// //           ? invoice['tax3Percent']
// //           : invoice['tax14Percent'];
// //     }
// //     final totalAfterTax = totalBeforeTax - totalTaxAmount;

// //     return Column(
// //       children: [
// //         // إحصائيات السنة
// //         Padding(
// //           padding: const EdgeInsets.all(16),
// //           child: _buildTaxBoxSummaryCard(
// //             taxType: taxType,
// //             year: _selectedYear,
// //             totalInvoices: invoices.length,
// //             totalBeforeTax: totalBeforeTax,
// //             totalTaxAmount: totalTaxAmount,
// //             totalAfterTax: totalAfterTax,
// //             color: color,
// //           ),
// //         ),

// //         // تبويب السجلات والأشهر
// //         Container(
// //           color: Colors.white,
// //           child: Row(
// //             children: [
// //               Expanded(
// //                 child: TextButton(
// //                   onPressed: () {
// //                     setState(() {
// //                       _selectedTaxRecord = null;
// //                       _taxRecordInvoices.clear();
// //                       _selectedMonthIndex = -1;
// //                       _monthInvoices = [];
// //                     });
// //                   },
// //                   child: Text(
// //                     'السجلات الضريبية',
// //                     style: TextStyle(
// //                       color:
// //                           _selectedTaxRecord == null &&
// //                               _selectedMonthIndex == -1
// //                           ? color
// //                           : Colors.grey,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //               Expanded(
// //                 child: TextButton(
// //                   onPressed: () {
// //                     setState(() {
// //                       _selectedTaxRecord = null;
// //                       _taxRecordInvoices.clear();
// //                       _selectedMonthIndex = -1;
// //                       _monthInvoices = [];
// //                     });
// //                   },
// //                   child: Text(
// //                     'الضرائب الشهرية',
// //                     style: TextStyle(
// //                       color: _selectedMonthIndex != -1 ? color : Colors.grey,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),

// //         // قائمة الأشهر أو الفواتير
// //         Expanded(
// //           child: _selectedMonthIndex != -1
// //               ? _buildMonthInvoicesList()
// //               : _buildTaxContent(invoices, taxRecords, taxType, color),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildTaxContent(
// //     List<Map<String, dynamic>> invoices,
// //     List<Map<String, dynamic>> taxRecords,
// //     String taxType,
// //     Color color,
// //   ) {
// //     if (_selectedTaxRecord != null) {
// //       return _buildTaxRecordDetails();
// //     }

// //     // عرض قائمة الأشهر بدلاً من السجلات
// //     return _buildMonthsGrid();
// //   }

// //   Widget _buildMonthsGrid() {
// //     return GridView.builder(
// //       padding: const EdgeInsets.all(16),
// //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //         crossAxisCount: 6,
// //         crossAxisSpacing: 2,
// //         mainAxisSpacing: 2,
// //         childAspectRatio: 1.8,
// //       ),
// //       itemCount: _monthlyTaxData.length,
// //       itemBuilder: (context, index) {
// //         final monthData = _monthlyTaxData[index];
// //         final isSelected = index == _selectedMonthIndex;

// //         return _buildMonthCard(monthData, index, isSelected);
// //       },
// //     );
// //   }

// //   Widget _buildMonthCard(
// //     Map<String, dynamic> monthData,
// //     int index,
// //     bool isSelected,
// //   ) {
// //     final monthName = monthData['monthName'];
// //     final invoiceCount = monthData['invoiceCount'];
// //     final totalTax = monthData['totalTax'];
// //     final color = _currentSection == 1 ? Colors.blue : Colors.green;

// //     return GestureDetector(
// //       onTap: () => _selectMonth(index),
// //       child: Container(
// //         height: 30,
// //         decoration: BoxDecoration(
// //           color: isSelected ? color.withOpacity(0.1) : Colors.white,
// //           borderRadius: BorderRadius.circular(12),
// //           border: Border.all(
// //             color: isSelected ? color : Colors.grey[300]!,
// //             width: isSelected ? 2 : 1,
// //           ),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.grey.withOpacity(0.1),
// //               blurRadius: 4,
// //               offset: const Offset(0, 2),
// //             ),
// //           ],
// //         ),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Text(
// //               monthName,
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.bold,
// //                 color: isSelected ? color : Colors.black,
// //               ),
// //             ),
// //             const SizedBox(height: 8),
// //             if (invoiceCount > 0)
// //               Column(
// //                 children: [
// //                   Text(
// //                     '$invoiceCount فاتورة',
// //                     style: TextStyle(
// //                       fontSize: 12,
// //                       color: isSelected ? color : Colors.grey[600],
// //                     ),
// //                   ),
// //                   const SizedBox(height: 4),
// //                   Text(
// //                     _formatCurrency(totalTax),
// //                     style: TextStyle(
// //                       fontSize: 14,
// //                       fontWeight: FontWeight.bold,
// //                       color: isSelected ? color : Colors.green,
// //                     ),
// //                   ),
// //                 ],
// //               )
// //             else
// //               Text(
// //                 'لا توجد فواتير',
// //                 style: TextStyle(fontSize: 12, color: Colors.grey[400]),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildMonthInvoicesList() {
// //     if (_monthInvoices.isEmpty) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(Icons.receipt, size: 80, color: Colors.grey[400]),
// //             const SizedBox(height: 16),
// //             const Text(
// //               'لا توجد فواتير في هذا الشهر',
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 color: Colors.grey,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           ],
// //         ),
// //       );
// //     }

// //     return Column(
// //       children: [
// //         // عنوان الشهر
// //         Container(
// //           padding: const EdgeInsets.all(16),
// //           color: _currentSection == 1 ? Colors.blue[50] : Colors.green[50],
// //           child: Row(
// //             children: [
// //               Icon(
// //                 Icons.calendar_month,
// //                 color: _currentSection == 1 ? Colors.blue : Colors.green,
// //               ),
// //               const SizedBox(width: 12),
// //               Text(
// //                 _monthlyTaxData[_selectedMonthIndex]['monthName'],
// //                 style: TextStyle(
// //                   fontSize: 18,
// //                   fontWeight: FontWeight.bold,
// //                   color: _currentSection == 1 ? Colors.blue : Colors.green,
// //                 ),
// //               ),
// //               const Spacer(),
// //               Text(
// //                 '(${_monthInvoices.length}) فاتورة',
// //                 style: const TextStyle(fontSize: 14, color: Colors.grey),
// //               ),
// //             ],
// //           ),
// //         ),

// //         // قائمة الفواتير
// //         Expanded(
// //           child: ListView.builder(
// //             padding: const EdgeInsets.all(16),
// //             itemCount: _monthInvoices.length,
// //             itemBuilder: (context, index) {
// //               final invoice = _monthInvoices[index];
// //               return _buildMonthInvoiceCard(invoice, index);
// //             },
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildMonthInvoiceCard(Map<String, dynamic> invoice, int index) {
// //     final taxType = _currentSection == 1 ? '3%' : '14%';
// //     final taxAmount = _currentSection == 1
// //         ? invoice['tax3Percent']
// //         : invoice['tax14Percent'];
// //     final amountAfterTax = invoice['totalAmount'] - taxAmount;
// //     final invoiceDate = invoice['taxDate'] ?? invoice['createdAt'];

// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 12),
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // اسم الفاتورة
// //             Text(
// //               invoice['name'],
// //               style: const TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.bold,
// //                 color: Color(0xFF2C3E50),
// //               ),
// //             ),

// //             const SizedBox(height: 8),

// //             // التاريخ وسعر الفاتورة
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 // التاريخ على اليسار
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       'التاريخ',
// //                       style: TextStyle(fontSize: 12, color: Colors.grey[600]),
// //                     ),
// //                     const SizedBox(height: 4),
// //                     Text(
// //                       _formatDate(invoiceDate),
// //                       style: const TextStyle(
// //                         fontSize: 14,
// //                         fontWeight: FontWeight.bold,
// //                         color: Colors.blue,
// //                       ),
// //                     ),
// //                   ],
// //                 ),

// //                 // سعر الفاتورة في الوسط
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.center,
// //                   children: [
// //                     Text(
// //                       'سعر الفاتورة',
// //                       style: TextStyle(fontSize: 12, color: Colors.grey[600]),
// //                     ),
// //                     const SizedBox(height: 4),
// //                     Text(
// //                       _formatCurrency(invoice['totalAmount']),
// //                       style: const TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                         color: Color(0xFF2E7D32),
// //                       ),
// //                     ),
// //                   ],
// //                 ),

// //                 // الضرائب على اليمين
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.end,
// //                   children: [
// //                     Text(
// //                       'ضريبة $taxType',
// //                       style: TextStyle(fontSize: 12, color: Colors.grey[600]),
// //                     ),
// //                     const SizedBox(height: 4),
// //                     Text(
// //                       _formatCurrency(taxAmount),
// //                       style: TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                         color: _currentSection == 1
// //                             ? Colors.blue
// //                             : Colors.green,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),

// //             const SizedBox(height: 12),

// //             // الإجمالي بعد الضريبة
// //             Container(
// //               padding: const EdgeInsets.all(12),
// //               decoration: BoxDecoration(
// //                 color: Colors.red[50],
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Text(
// //                     'الإجمالي بعد الضريبة',
// //                     style: TextStyle(
// //                       fontSize: 14,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.red[700],
// //                     ),
// //                   ),
// //                   Text(
// //                     _formatCurrency(amountAfterTax),
// //                     style: const TextStyle(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.red,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildTaxBoxSummaryCard({
// //     required String taxType,
// //     required int year,
// //     required int totalInvoices,
// //     required double totalBeforeTax,
// //     required double totalTaxAmount,
// //     required double totalAfterTax,
// //     required Color color,
// //   }) {
// //     return Card(
// //       elevation: 4,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //       color: color.withOpacity(0.05),
// //       child: Padding(
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           children: [
// //             // العنوان
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(
// //                   taxType == '3%'
// //                       ? Icons.account_balance_wallet
// //                       : Icons.account_balance,
// //                   color: color,
// //                   size: 24,
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Text(
// //                   'صندوق $taxType - سنة $year',
// //                   style: TextStyle(
// //                     fontSize: 18,
// //                     fontWeight: FontWeight.bold,
// //                     color: color,
// //                   ),
// //                 ),
// //               ],
// //             ),

// //             const SizedBox(height: 20),

// //             // شبكة الإحصائيات
// //             Row(
// //               children: [
// //                 // عدد الفواتير
// //                 Expanded(
// //                   child: _buildStatBox(
// //                     title: 'عدد الفواتير',
// //                     value: '$totalInvoices',
// //                     icon: Icons.receipt,
// //                     color: const Color(0xFF3498DB),
// //                   ),
// //                 ),

// //                 const SizedBox(width: 12),

// //                 // الإجمالي قبل الضريبة
// //                 Expanded(
// //                   child: _buildStatBox(
// //                     title: 'الإجمالي قبل الضريبة',
// //                     value: _formatCurrency(totalBeforeTax),
// //                     icon: Icons.attach_money,
// //                     color: Colors.blue[700]!,
// //                   ),
// //                 ),
// //               ],
// //             ),

// //             const SizedBox(height: 12),

// //             Row(
// //               children: [
// //                 // قيمة الضريبة
// //                 Expanded(
// //                   child: _buildStatBox(
// //                     title: 'قيمة الضريبة',
// //                     value: _formatCurrency(totalTaxAmount),
// //                     icon: Icons.account_balance_wallet,
// //                     color: color,
// //                   ),
// //                 ),

// //                 const SizedBox(width: 12),

// //                 // الإجمالي بعد الضريبة
// //                 Expanded(
// //                   child: Container(
// //                     padding: const EdgeInsets.all(12),
// //                     decoration: BoxDecoration(
// //                       color: Colors.red[50],
// //                       borderRadius: BorderRadius.circular(12),
// //                       border: Border.all(color: Colors.red[100]!),
// //                     ),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Row(
// //                           children: [
// //                             Icon(
// //                               Icons.money_off,
// //                               color: Colors.red[700],
// //                               size: 20,
// //                             ),
// //                             const SizedBox(width: 8),
// //                             Expanded(
// //                               child: Text(
// //                                 'الإجمالي بعد الضريبة',
// //                                 style: TextStyle(
// //                                   fontSize: 12,
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Colors.red[700],
// //                                 ),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                         const SizedBox(height: 8),
// //                         Text(
// //                           _formatCurrency(totalAfterTax),
// //                           style: const TextStyle(
// //                             fontSize: 18,
// //                             fontWeight: FontWeight.bold,
// //                             color: Colors.red,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildStatBox({
// //     required String title,
// //     required String value,
// //     required IconData icon,
// //     required Color color,
// //   }) {
// //     return Container(
// //       padding: const EdgeInsets.all(12),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: Colors.grey[200]!),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             children: [
// //               Icon(icon, color: color, size: 18),
// //               const SizedBox(width: 8),
// //               Expanded(
// //                 child: Text(
// //                   title,
// //                   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
// //                 ),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 8),
// //           Text(
// //             value,
// //             style: TextStyle(
// //               fontSize: 16,
// //               fontWeight: FontWeight.bold,
// //               color: color,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildTaxRecordsList(List<Map<String, dynamic>> records, Color color) {
// //     return records.isEmpty
// //         ? Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(Icons.history, size: 80, color: Colors.grey[400]),
// //                 const SizedBox(height: 16),
// //                 const Text(
// //                   'لا توجد سجلات ضريبية لهذه السنة',
// //                   style: TextStyle(
// //                     fontSize: 16,
// //                     color: Colors.grey,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           )
// //         : ListView.builder(
// //             padding: const EdgeInsets.all(8),
// //             itemCount: records.length,
// //             itemBuilder: (context, index) {
// //               final record = records[index];
// //               return _buildTaxRecordCard(record, color, index);
// //             },
// //           );
// //   }

// //   Widget _buildTaxRecordCard(
// //     Map<String, dynamic> record,
// //     Color color,
// //     int index,
// //   ) {
// //     final year = record['year'];
// //     final totalInvoices = record['totalInvoices'];
// //     final totalBeforeTax = record['totalAmountBeforeTax'];
// //     final totalTax = record['totalTaxAmount'];
// //     final totalAfterTax = record['totalAmountAfterTax'];

// //     return Card(
// //       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: ListTile(
// //         leading: Container(
// //           width: 50,
// //           height: 50,
// //           decoration: BoxDecoration(
// //             color: color.withOpacity(0.1),
// //             borderRadius: BorderRadius.circular(8),
// //             border: Border.all(color: color.withOpacity(0.3)),
// //           ),
// //           child: Center(
// //             child: Text(
// //               '${index + 1}',
// //               style: TextStyle(
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.bold,
// //                 color: color,
// //               ),
// //             ),
// //           ),
// //         ),
// //         title: Text(
// //           'سنة $year',
// //           style: TextStyle(
// //             fontWeight: FontWeight.bold,
// //             fontSize: 17,
// //             color: color,
// //           ),
// //         ),
// //         subtitle: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             const SizedBox(height: 4),
// //             Text(
// //               'فاتورة :$totalInvoices   ',
// //               style: const TextStyle(fontSize: 13),
// //             ),
// //           ],
// //         ),
// //         trailing: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           crossAxisAlignment: CrossAxisAlignment.end,
// //           children: [
// //             Text(
// //               _formatCurrency(totalTax),
// //               style: const TextStyle(
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 16,
// //                 color: Colors.green,
// //               ),
// //             ),
// //             const SizedBox(height: 4),
// //             Text(
// //               ' الضريبة',
// //               style: TextStyle(fontSize: 11, color: Colors.grey[600]),
// //             ),
// //           ],
// //         ),
// //         onTap: () => _showTaxRecordDetails(record),
// //         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //       ),
// //     );
// //   }

// //   Widget _buildTaxInvoicesList(
// //     List<Map<String, dynamic>> invoices,
// //     String taxType,
// //     Color color,
// //   ) {
// //     return invoices.isEmpty
// //         ? Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(Icons.receipt, size: 80, color: Colors.grey[400]),
// //                 const SizedBox(height: 16),
// //                 Text(
// //                   'لا توجد فواتير لسنة $_selectedYear',
// //                   style: const TextStyle(
// //                     fontSize: 16,
// //                     color: Colors.grey,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           )
// //         : ListView.builder(
// //             padding: const EdgeInsets.all(8),
// //             itemCount: invoices.length,
// //             itemBuilder: (context, index) {
// //               final invoice = invoices[index];
// //               return _buildTaxBoxInvoiceItem(invoice, taxType, color, index);
// //             },
// //           );
// //   }

// //   Widget _buildTaxBoxInvoiceItem(
// //     Map<String, dynamic> invoice,
// //     String taxType,
// //     Color color,
// //     int index,
// //   ) {
// //     final taxAmount = taxType == '3%'
// //         ? invoice['tax3Percent']
// //         : invoice['tax14Percent'];
// //     final amountAfterTax = invoice['totalAmount'] - taxAmount;

// //     return Card(
// //       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // رأس البطاقة
// //             Row(
// //               children: [
// //                 Container(
// //                   width: 36,
// //                   height: 36,
// //                   decoration: BoxDecoration(
// //                     color: color.withOpacity(0.1),
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                   child: Center(
// //                     child: Text(
// //                       '${index + 1}',
// //                       style: TextStyle(
// //                         fontWeight: FontWeight.bold,
// //                         color: color,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 12),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         invoice['name'],
// //                         style: const TextStyle(
// //                           fontWeight: FontWeight.bold,
// //                           fontSize: 16,
// //                         ),
// //                       ),
// //                       Text(
// //                         invoice['companyName'],
// //                         style: TextStyle(fontSize: 13, color: Colors.grey[600]),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),

// //             const SizedBox(height: 16),

// //             // سعر الفاتورة والضريبة
// //             Row(
// //               children: [
// //                 // سعر الفاتورة
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         'سعر الفاتورة',
// //                         style: TextStyle(fontSize: 13, color: Colors.grey[600]),
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Text(
// //                         _formatCurrency(invoice['totalAmount']),
// //                         style: const TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.blue,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),

// //                 // الضريبة
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         'ضريبة $taxType',
// //                         style: TextStyle(fontSize: 13, color: Colors.grey[600]),
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Text(
// //                         _formatCurrency(taxAmount),
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.bold,
// //                           color: color,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),

// //             const SizedBox(height: 12),

// //             // الإجمالي بعد الضريبة
// //             Container(
// //               padding: const EdgeInsets.all(12),
// //               decoration: BoxDecoration(
// //                 color: Colors.red[50],
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Text(
// //                     'الإجمالي بعد الضريبة',
// //                     style: TextStyle(
// //                       fontSize: 14,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.red[700],
// //                     ),
// //                   ),
// //                   Text(
// //                     _formatCurrency(amountAfterTax),
// //                     style: const TextStyle(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.red,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildTaxRecordDetails() {
// //     if (_selectedTaxRecord == null) return Container();

// //     return ListView.builder(
// //       padding: const EdgeInsets.all(8),
// //       itemCount: _taxRecordInvoices.length,
// //       itemBuilder: (context, index) {
// //         final invoice = _taxRecordInvoices[index];
// //         final taxType = _selectedTaxRecord!['taxType'];
// //         final color = taxType == '3%' ? Colors.blue : Colors.green;

// //         return _buildTaxBoxInvoiceItem(invoice, taxType, color, index);
// //       },
// //     );
// //   }
// // // }
// // import 'dart:async';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';

// // class TaxesPage extends StatefulWidget {
// //   const TaxesPage({super.key});

// //   @override
// //   State<TaxesPage> createState() => _TaxesPageState();
// // }

// // class _TaxesPageState extends State<TaxesPage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// //   // متغيرات عامة
// //   int _currentPage = 0; // 0: لوحة السنة، 1: الفواتير، 2: صندوق 3%، 3: صندوق 14%
// //   bool _isLoading = false;
// //   String _searchQuery = '';
// //   int _selectedYear = DateTime.now().year;

// //   // بيانات الفواتير
// //   List<Map<String, dynamic>> _allInvoices = [];
// //   List<Map<String, dynamic>> _filteredInvoices = [];
// //   List<Map<String, dynamic>> _3PercentTaxInvoices = [];
// //   List<Map<String, dynamic>> _14PercentTaxInvoices = [];

// //   // بيانات الضرائب
// //   List<Map<String, dynamic>> _taxes3Percent = [];
// //   List<Map<String, dynamic>> _taxes14Percent = [];

// //   // بيانات الخصومات
// //   List<Map<String, dynamic>> _taxDeductions = [];

// //   // فلتر السنوات
// //   List<int> _availableYears = [];

// //   // إحصائيات السنة
// //   double _yearTotalInvoicesAmount = 0.0;
// //   double _yearTotalBalance = 0.0;
// //   double _yearTotal3PercentTax = 0.0;
// //   double _yearTotal14PercentTax = 0.0;
// //   double _yearTotalTaxes = 0.0;
// //   double _yearTotalDeductions = 0.0;
// //   double _yearTotalTaxesAfterDeductions = 0.0;

// //   // متغيرات لعرض التفاصيل
// //   Map<String, dynamic>? _selectedTaxRecord;
// //   List<Map<String, dynamic>> _taxRecordInvoices = [];

// //   // متغيرات للتحكم في التحميل المتقطع (Pagination)
// //   final int _invoicesPerPage = 20;
// //   DocumentSnapshot? _lastInvoiceDocument;
// //   bool _hasMoreInvoices = true;
// //   bool _isLoadingMore = false;

// //   // متغيرات جديدة للأشهر
// //   List<Map<String, dynamic>> _monthlyTaxData = [];
// //   int _selectedMonthIndex = -1; // -1 يعني لا يوجد شهر محدد
// //   List<Map<String, dynamic>> _monthInvoices = [];

// //   @override
// //   void initState() {
// //     super.initState();
// //     _initializeYears();
// //     _loadDashboardData();
// //   }

// //   // ================================
// //   // تهيئة قائمة السنوات
// //   // ================================
// //   void _initializeYears() {
// //     final currentYear = DateTime.now().year;
// //     _availableYears = List.generate(5, (index) => currentYear - 2 + index);
// //     _selectedYear = currentYear;
// //   }

// //   // ================================
// //   // تحميل بيانات لوحة السنة
// //   // ================================
// //   Future<void> _loadDashboardData() async {
// //     setState(() {
// //       _isLoading = true;
// //     });

// //     try {
// //       if (_currentPage == 0) {
// //         await _loadInvoices();
// //         await _loadTaxes();
// //         await _loadTaxDeductions();
// //         await _calculateYearStatistics();
// //       } else if (_currentPage == 1) {
// //         await _loadInvoices();
// //       } else if (_currentPage == 2 || _currentPage == 3) {
// //         await _loadInvoices();
// //         await _loadTaxes();
// //       }
// //     } catch (e) {
// //       _showError('خطأ في تحميل البيانات: $e');
// //     } finally {
// //       setState(() {
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   // ================================
// //   // تحميل جميع الفواتير
// //   // ================================
// //   Future<void> _loadInvoices({bool loadMore = false}) async {
// //     if (_currentPage == 1 && loadMore) {
// //       if (!_hasMoreInvoices || _isLoadingMore) return;
// //       setState(() => _isLoadingMore = true);
// //     } else if (!loadMore) {
// //       setState(() {
// //         _isLoading = true;
// //         _allInvoices = [];
// //         _lastInvoiceDocument = null;
// //         _hasMoreInvoices = true;
// //       });
// //     }

// //     try {
// //       Query<Map<String, dynamic>> query = _firestore
// //           .collection('invoices')
// //           .orderBy('createdAt', descending: true)
// //           .limit(_invoicesPerPage);

// //       if (_lastInvoiceDocument != null) {
// //         query = query.startAfterDocument(_lastInvoiceDocument!);
// //       }

// //       final invoicesSnapshot = await query.get();

// //       final List<Map<String, dynamic>> newInvoices = [];

// //       for (final doc in invoicesSnapshot.docs) {
// //         final data = doc.data();

// //         // تحويل البيانات بأمان مع القيم الافتراضية
// //         final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
// //         final tax3PercentDate = (data['tax3PercentDate'] as Timestamp?)
// //             ?.toDate();
// //         final tax14PercentDate = (data['tax14PercentDate'] as Timestamp?)
// //             ?.toDate();
// //         final taxDate = (data['taxDate'] as Timestamp?)?.toDate();

// //         newInvoices.add({
// //           'id': doc.id,
// //           'name': (data['name'] as String?) ?? 'فاتورة بدون اسم',
// //           'companyName': (data['companyName'] as String?) ?? 'شركة غير معروفة',
// //           'companyId': (data['companyId'] as String?) ?? '',
// //           'totalAmount': ((data['totalAmount'] as num?) ?? 0).toDouble(),
// //           'nolonTotal': ((data['nolonTotal'] as num?) ?? 0).toDouble(),
// //           'overnightTotal': ((data['overnightTotal'] as num?) ?? 0).toDouble(),
// //           'holidayTotal': ((data['holidayTotal'] as num?) ?? 0).toDouble(),
// //           'createdAt': createdAt,
// //           'taxDate': taxDate,
// //           'tax3Percent': ((data['tax3Percent'] as num?) ?? 0).toDouble(),
// //           'tax14Percent': ((data['tax14Percent'] as num?) ?? 0).toDouble(),
// //           'has3PercentTax': (data['has3PercentTax'] as bool?) ?? false,
// //           'has14PercentTax': (data['has14PercentTax'] as bool?) ?? false,
// //           'tax3PercentDate': tax3PercentDate,
// //           'tax14PercentDate': tax14PercentDate,
// //           'tripCount': (data['tripCount'] as int?) ?? 0,
// //           'isArchived': (data['isArchived'] as bool?) ?? false,
// //         });
// //       }

// //       setState(() {
// //         if (loadMore) {
// //           _allInvoices.addAll(newInvoices);
// //           _isLoadingMore = false;
// //         } else {
// //           _allInvoices = newInvoices;
// //           _isLoading = false;
// //         }

// //         if (_currentPage == 1) {
// //           _filteredInvoices = _applySearchFilter(
// //             _allInvoices
// //                 .where((invoice) => !(invoice['isArchived'] ?? false))
// //                 .toList(),
// //           );
// //         }

// //         _lastInvoiceDocument = invoicesSnapshot.docs.isNotEmpty
// //             ? invoicesSnapshot.docs.last
// //             : null;
// //         _hasMoreInvoices = newInvoices.length == _invoicesPerPage;
// //       });

// //       // فصل الفواتير حسب نوع الضريبة
// //       _separateTaxInvoices();
// //     } catch (e) {
// //       setState(() {
// //         if (loadMore) {
// //           _isLoadingMore = false;
// //         } else {
// //           _isLoading = false;
// //         }
// //       });
// //       _showError('خطأ في تحميل الفواتير: $e');
// //     }
// //   }

// //   // ================================
// //   // فصل الفواتير حسب نوع الضريبة
// //   // ================================
// //   void _separateTaxInvoices() {
// //     setState(() {
// //       // فواتير 3% للسنة المحددة
// //       _3PercentTaxInvoices = _allInvoices.where((invoice) {
// //         if (invoice['has3PercentTax'] != true) return false;

// //         DateTime? dateToCheck;

// //         // أولاً: تاريخ الضريبة 3%
// //         dateToCheck = invoice['tax3PercentDate'] as DateTime?;

// //         // ثانياً: تاريخ الإنشاء
// //         dateToCheck ??= invoice['createdAt'] as DateTime?;

// //         return dateToCheck != null && dateToCheck.year == _selectedYear;
// //       }).toList();

// //       // فواتير 14% للسنة المحددة
// //       _14PercentTaxInvoices = _allInvoices.where((invoice) {
// //         if (invoice['has14PercentTax'] != true) return false;

// //         DateTime? dateToCheck;

// //         // أولاً: تاريخ الضريبة 14%
// //         dateToCheck = invoice['tax14PercentDate'] as DateTime?;

// //         // ثانياً: تاريخ الإنشاء
// //         dateToCheck ??= invoice['createdAt'] as DateTime?;

// //         return dateToCheck != null && dateToCheck.year == _selectedYear;
// //       }).toList();
// //     });

// //     // تحضير بيانات الأشهر
// //     _prepareMonthlyData();
// //   }

// //   // ================================
// //   // تحضير بيانات الأشهر
// //   // ================================
// //   void _prepareMonthlyData() {
// //     List<Map<String, dynamic>> invoices = [];

// //     if (_currentPage == 2) {
// //       invoices = _3PercentTaxInvoices;
// //     } else if (_currentPage == 3) {
// //       invoices = _14PercentTaxInvoices;
// //     }

// //     // تجميع الفواتير حسب الشهر
// //     Map<int, List<Map<String, dynamic>>> monthlyInvoices = {};

// //     for (var invoice in invoices) {
// //       DateTime? invoiceDate = invoice['taxDate'] ?? invoice['createdAt'];
// //       if (invoiceDate != null) {
// //         int month = invoiceDate.month;
// //         monthlyInvoices.putIfAbsent(month, () => []);
// //         monthlyInvoices[month]!.add(invoice);
// //       }
// //     }

// //     // تحويل إلى قائمة من بيانات الأشهر
// //     List<Map<String, dynamic>> monthlyData = [];

// //     for (int month = 1; month <= 12; month++) {
// //       if (monthlyInvoices.containsKey(month)) {
// //         List<Map<String, dynamic>> monthInvoices = monthlyInvoices[month]!;
// //         double totalAmount = 0;
// //         double totalTax = 0;

// //         for (var invoice in monthInvoices) {
// //           totalAmount += invoice['totalAmount'];
// //           totalTax += _currentPage == 2
// //               ? invoice['tax3Percent']
// //               : invoice['tax14Percent'];
// //         }

// //         monthlyData.add({
// //           'monthNumber': month,
// //           'monthName': _getMonthName(month),
// //           'invoiceCount': monthInvoices.length,
// //           'totalAmount': totalAmount,
// //           'totalTax': totalTax,
// //           'invoices': monthInvoices,
// //         });
// //       } else {
// //         monthlyData.add({
// //           'monthNumber': month,
// //           'monthName': _getMonthName(month),
// //           'invoiceCount': 0,
// //           'totalAmount': 0.0,
// //           'totalTax': 0.0,
// //           'invoices': [],
// //         });
// //       }
// //     }

// //     setState(() {
// //       _monthlyTaxData = monthlyData;
// //     });
// //   }

// //   // ================================
// //   // الحصول على اسم الشهر
// //   // ================================
// //   String _getMonthName(int month) {
// //     switch (month) {
// //       case 1:
// //         return 'يناير';
// //       case 2:
// //         return 'فبراير';
// //       case 3:
// //         return 'مارس';
// //       case 4:
// //         return 'أبريل';
// //       case 5:
// //         return 'مايو';
// //       case 6:
// //         return 'يونيو';
// //       case 7:
// //         return 'يوليو';
// //       case 8:
// //         return 'أغسطس';
// //       case 9:
// //         return 'سبتمبر';
// //       case 10:
// //         return 'أكتوبر';
// //       case 11:
// //         return 'نوفمبر';
// //       case 12:
// //         return 'ديسمبر';
// //       default:
// //         return '';
// //     }
// //   }

// //   // ================================
// //   // تحميل بيانات الضرائب
// //   // ================================
// //   Future<void> _loadTaxes() async {
// //     try {
// //       // تحميل ضرائب 3%
// //       QuerySnapshot tax3Snapshot = await _firestore
// //           .collection('taxes')
// //           .where('taxType', isEqualTo: '3%')
// //           .where('year', isEqualTo: _selectedYear)
// //           .get();

// //       final List<Map<String, dynamic>> tax3List = [];
// //       for (final doc in tax3Snapshot.docs) {
// //         final data = doc.data() as Map<String, dynamic>;
// //         tax3List.add({
// //           'id': doc.id,
// //           'taxType': data['taxType'] ?? '3%',
// //           'year': data['year'] ?? _selectedYear,
// //           'totalInvoices': data['totalInvoices'] ?? 0,
// //           'totalAmountBeforeTax': ((data['totalAmountBeforeTax'] as num?) ?? 0)
// //               .toDouble(),
// //           'totalTaxAmount': ((data['totalTaxAmount'] as num?) ?? 0).toDouble(),
// //           'totalAmountAfterTax': ((data['totalAmountAfterTax'] as num?) ?? 0)
// //               .toDouble(),
// //           'invoiceIds': data['invoiceIds'] ?? [],
// //           'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
// //         });
// //       }

// //       // تحميل ضرائب 14%
// //       QuerySnapshot tax14Snapshot = await _firestore
// //           .collection('taxes')
// //           .where('taxType', isEqualTo: '14%')
// //           .where('year', isEqualTo: _selectedYear)
// //           .get();

// //       final List<Map<String, dynamic>> tax14List = [];
// //       for (final doc in tax14Snapshot.docs) {
// //         final data = doc.data() as Map<String, dynamic>;
// //         tax14List.add({
// //           'id': doc.id,
// //           'taxType': data['taxType'] ?? '14%',
// //           'year': data['year'] ?? _selectedYear,
// //           'totalInvoices': data['totalInvoices'] ?? 0,
// //           'totalAmountBeforeTax': ((data['totalAmountBeforeTax'] as num?) ?? 0)
// //               .toDouble(),
// //           'totalTaxAmount': ((data['totalTaxAmount'] as num?) ?? 0).toDouble(),
// //           'totalAmountAfterTax': ((data['totalAmountAfterTax'] as num?) ?? 0)
// //               .toDouble(),
// //           'invoiceIds': data['invoiceIds'] ?? [],
// //           'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
// //         });
// //       }

// //       setState(() {
// //         _taxes3Percent = tax3List;
// //         _taxes14Percent = tax14List;
// //       });
// //     } catch (e) {
// //       _showError('خطأ في تحميل بيانات الضرائب: $e');
// //     }
// //   }

// //   // ================================
// //   // تحميل بيانات الخصومات الضريبية
// //   // ================================
// //   Future<void> _loadTaxDeductions() async {
// //     try {
// //       QuerySnapshot<Map<String, dynamic>> deductionsSnapshot = await _firestore
// //           .collection('tax_deductions')
// //           .where('year', isEqualTo: _selectedYear)
// //           .orderBy('date', descending: true)
// //           .get();

// //       final List<Map<String, dynamic>> deductionsList = [];
// //       for (final doc in deductionsSnapshot.docs) {
// //         final data = doc.data();
// //         deductionsList.add({
// //           'id': doc.id,
// //           'date': (data['date'] as Timestamp?)?.toDate(),
// //           'amount': ((data['amount'] as num?) ?? 0).toDouble(),
// //           'description': (data['description'] as String?) ?? 'لا توجد ملاحظات',
// //           'year': data['year'] ?? _selectedYear,
// //         });
// //       }

// //       setState(() {
// //         _taxDeductions = deductionsList;
// //       });
// //     } catch (e) {
// //       _showError('خطأ في تحميل بيانات الخصومات: $e');
// //     }
// //   }

// //   // ================================
// //   // حساب إحصائيات السنة
// //   // ================================
// //   Future<void> _calculateYearStatistics() async {
// //     // إجمالي فواتير السنة
// //     double totalInvoicesAmount = 0.0;
// //     for (var invoice in _allInvoices) {
// //       final createdAt = invoice['createdAt'] as DateTime?;
// //       if (createdAt != null && createdAt.year == _selectedYear) {
// //         totalInvoicesAmount += invoice['totalAmount'];
// //       }
// //     }

// //     // إجمالي رصيد الفواتير (الفواتير غير المفعلة للضرائب)
// //     double totalBalance = 0.0;
// //     for (var invoice in _allInvoices) {
// //       final createdAt = invoice['createdAt'] as DateTime?;
// //       if (createdAt != null &&
// //           createdAt.year == _selectedYear &&
// //           invoice['has3PercentTax'] != true &&
// //           invoice['has14PercentTax'] != true) {
// //         totalBalance += invoice['totalAmount'];
// //       }
// //     }

// //     // إجمالي ضرائب 3%
// //     double total3PercentTax = 0.0;
// //     for (var invoice in _3PercentTaxInvoices) {
// //       total3PercentTax += invoice['tax3Percent'];
// //     }

// //     // إجمالي ضرائب 14%
// //     double total14PercentTax = 0.0;
// //     for (var invoice in _14PercentTaxInvoices) {
// //       total14PercentTax += invoice['tax14Percent'];
// //     }

// //     // إجمالي الضرائب
// //     double totalTaxes = total3PercentTax + total14PercentTax;

// //     // إجمالي الخصومات
// //     double totalDeductions = 0.0;
// //     for (var deduction in _taxDeductions) {
// //       totalDeductions += deduction['amount'];
// //     }

// //     // إجمالي الضرائب بعد الخصم
// //     double totalTaxesAfterDeductions = totalTaxes - totalDeductions;

// //     setState(() {
// //       _yearTotalInvoicesAmount = totalInvoicesAmount;
// //       _yearTotalBalance = totalBalance;
// //       _yearTotal3PercentTax = total3PercentTax;
// //       _yearTotal14PercentTax = total14PercentTax;
// //       _yearTotalTaxes = totalTaxes;
// //       _yearTotalDeductions = totalDeductions;
// //       _yearTotalTaxesAfterDeductions = totalTaxesAfterDeductions;
// //     });
// //   }

// //   // ================================
// //   // إضافة خصم ضريبي جديد
// //   // ================================
// //   Future<void> _addTaxDeduction() async {
// //     final TextEditingController amountController = TextEditingController();
// //     final TextEditingController descriptionController = TextEditingController();
// //     DateTime? selectedDate = DateTime.now();

// //     await showDialog(
// //       context: context,
// //       builder: (context) {
// //         return StatefulBuilder(
// //           builder: (context, setState) {
// //             return AlertDialog(
// //               title: const Text('إضافة خصم ضريبي'),
// //               content: SingleChildScrollView(
// //                 child: Column(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     // اختيار التاريخ
// //                     ListTile(
// //                       leading: const Icon(Icons.calendar_today),
// //                       title: const Text('تاريخ الخصم'),
// //                       subtitle: Text(
// //                         selectedDate != null
// //                             ? DateFormat('yyyy/MM/dd').format(selectedDate!)
// //                             : 'لم يتم اختيار تاريخ',
// //                       ),
// //                       onTap: () async {
// //                         final pickedDate = await showDatePicker(
// //                           context: context,
// //                           initialDate: DateTime.now(),
// //                           firstDate: DateTime(2000),
// //                           lastDate: DateTime(2100),
// //                         );
// //                         if (pickedDate != null) {
// //                           setState(() {
// //                             selectedDate = pickedDate;
// //                           });
// //                         }
// //                       },
// //                     ),

// //                     const SizedBox(height: 16),

// //                     // مبلغ الخصم
// //                     TextFormField(
// //                       controller: amountController,
// //                       decoration: const InputDecoration(
// //                         labelText: 'مبلغ الخصم',
// //                         prefixIcon: Icon(Icons.attach_money),
// //                         border: OutlineInputBorder(),
// //                       ),
// //                       keyboardType: TextInputType.number,
// //                       validator: (value) {
// //                         if (value == null || value.isEmpty) {
// //                           return 'الرجاء إدخال المبلغ';
// //                         }
// //                         if (double.tryParse(value) == null) {
// //                           return 'الرجاء إدخال رقم صحيح';
// //                         }
// //                         return null;
// //                       },
// //                     ),

// //                     const SizedBox(height: 16),

// //                     // الملاحظات
// //                     TextFormField(
// //                       controller: descriptionController,
// //                       decoration: const InputDecoration(
// //                         labelText: 'ملاحظات (اختياري)',
// //                         prefixIcon: Icon(Icons.note),
// //                         border: OutlineInputBorder(),
// //                       ),
// //                       maxLines: 3,
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               actions: [
// //                 TextButton(
// //                   onPressed: () => Navigator.pop(context),
// //                   child: const Text('إلغاء'),
// //                 ),
// //                 ElevatedButton(
// //                   onPressed: () async {
// //                     if (amountController.text.isEmpty) {
// //                       _showError('الرجاء إدخال مبلغ الخصم');
// //                       return;
// //                     }

// //                     final amount = double.tryParse(amountController.text);
// //                     if (amount == null || amount <= 0) {
// //                       _showError('الرجاء إدخال مبلغ صحيح');
// //                       return;
// //                     }

// //                     try {
// //                       await _firestore.collection('tax_deductions').add({
// //                         'date': Timestamp.fromDate(
// //                           selectedDate ?? DateTime.now(),
// //                         ),
// //                         'amount': amount,
// //                         'description': descriptionController.text.isNotEmpty
// //                             ? descriptionController.text
// //                             : 'لا توجد ملاحظات',
// //                         'year': _selectedYear,
// //                         'createdAt': Timestamp.now(),
// //                       });

// //                       Navigator.pop(context);
// //                       _showSuccess('تم إضافة الخصم بنجاح');

// //                       // إعادة تحميل البيانات
// //                       await _loadTaxDeductions();
// //                       await _calculateYearStatistics();
// //                     } catch (e) {
// //                       _showError('خطأ في إضافة الخصم: $e');
// //                     }
// //                   },
// //                   child: const Text('حفظ'),
// //                 ),
// //               ],
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }

// //   // ================================
// //   // دالة التصفية المحلية
// //   // ================================
// //   List<Map<String, dynamic>> _applySearchFilter(
// //     List<Map<String, dynamic>> invoices,
// //   ) {
// //     if (_searchQuery.isEmpty) return invoices;
// //     return invoices
// //         .where(
// //           (invoice) =>
// //               invoice['companyName'].toLowerCase().contains(
// //                 _searchQuery.toLowerCase(),
// //               ) ||
// //               invoice['name'].toLowerCase().contains(
// //                 _searchQuery.toLowerCase(),
// //               ),
// //         )
// //         .toList();
// //   }

// //   // ================================
// //   // نقل فاتورة إلى كلا الضرائب وأرشفتها مع حفظ تلقائي
// //   // ================================
// //   Future<void> _moveToBothTaxBoxes(Map<String, dynamic> invoice) async {
// //     if (_currentPage == 1) {
// //       final selectedDate = await _showDatePickerDialog();
// //       if (selectedDate == null) return;

// //       final totalAmount = invoice['totalAmount'];
// //       final tax3Amount = totalAmount * 0.03;
// //       final tax14Amount = totalAmount * 0.14;
// //       final selectedYear = selectedDate.year;

// //       try {
// //         // تحديث الفاتورة وإضافة أرشفة لكلا الضرائب
// //         await _firestore.collection('invoices').doc(invoice['id']).update({
// //           'taxDate': Timestamp.fromDate(selectedDate),
// //           'tax3Percent': tax3Amount,
// //           'tax14Percent': tax14Amount,
// //           'has3PercentTax': true,
// //           'has14PercentTax': true,
// //           'tax3PercentDate': Timestamp.now(),
// //           'tax14PercentDate': Timestamp.now(),
// //           'isArchived': true,
// //         });

// //         // تحديث الفاتورة محلياً
// //         setState(() {
// //           final index = _allInvoices.indexWhere(
// //             (inv) => inv['id'] == invoice['id'],
// //           );
// //           if (index != -1) {
// //             _allInvoices[index] = {
// //               ..._allInvoices[index],
// //               'taxDate': selectedDate,
// //               'tax3Percent': tax3Amount,
// //               'tax14Percent': tax14Amount,
// //               'has3PercentTax': true,
// //               'has14PercentTax': true,
// //               'tax3PercentDate': DateTime.now(),
// //               'tax14PercentDate': DateTime.now(),
// //               'isArchived': true,
// //             };
// //           }

// //           // إعادة فلترة الفواتير
// //           _filteredInvoices = _applySearchFilter(
// //             _allInvoices.where((inv) => !(inv['isArchived'] ?? false)).toList(),
// //           );

// //           _separateTaxInvoices();
// //         });

// //         // حفظ تلقائي للسجلات الضريبية
// //         await _autoSaveTaxRecords(selectedYear);

// //         _showSuccess(
// //           'تم نقل الفاتورة إلى كلا صندوقي الضرائب وأرشفتها وحفظ السجلات تلقائياً',
// //         );
// //       } catch (e) {
// //         _showError('خطأ في نقل الفاتورة: $e');
// //       }
// //     }
// //   }

// //   // ================================
// //   // حفظ تلقائي للسجلات الضريبية
// //   // ================================
// //   Future<void> _autoSaveTaxRecords(int year) async {
// //     try {
// //       // حفظ سجل 3% للسنة المحددة
// //       await _saveTaxRecordForYear('3%', year);

// //       // حفظ سجل 14% للسنة المحددة
// //       await _saveTaxRecordForYear('14%', year);

// //       // إعادة تحميل بيانات الضرائب
// //       await _loadTaxes();
// //     } catch (e) {
// //       _showError('خطأ في الحفظ التلقائي للسجلات: $e');
// //     }
// //   }

// //   // ================================
// //   // حفظ سجل ضريبي لسنة محددة
// //   // ================================
// //   Future<void> _saveTaxRecordForYear(String taxType, int year) async {
// //     try {
// //       // الحصول على الفواتير المناسبة للسنة ونوع الضريبة
// //       List<Map<String, dynamic>> yearInvoices;

// //       if (taxType == '3%') {
// //         yearInvoices = _3PercentTaxInvoices
// //             .where((invoice) => _getInvoiceYear(invoice, taxType) == year)
// //             .toList();
// //       } else {
// //         yearInvoices = _14PercentTaxInvoices
// //             .where((invoice) => _getInvoiceYear(invoice, taxType) == year)
// //             .toList();
// //       }

// //       if (yearInvoices.isEmpty) {
// //         print('لا توجد فواتير $taxType لسنة $year');
// //         return;
// //       }

// //       // حساب الإجماليات
// //       double totalBeforeTax = 0;
// //       double totalTaxAmount = 0;
// //       List<String> invoiceIds = [];

// //       for (var invoice in yearInvoices) {
// //         totalBeforeTax += invoice['totalAmount'];
// //         totalTaxAmount += taxType == '3%'
// //             ? invoice['tax3Percent']
// //             : invoice['tax14Percent'];
// //         invoiceIds.add(invoice['id']);
// //       }

// //       final totalAfterTax = totalBeforeTax - totalTaxAmount;

// //       // البحث عن سجل موجود لنفس السنة ونوع الضريبة
// //       final existingRecord = await _findExistingTaxRecord(taxType, year);

// //       if (existingRecord != null) {
// //         // تحديث السجل الحالي
// //         await _firestore.collection('taxes').doc(existingRecord['id']).update({
// //           'totalInvoices': yearInvoices.length,
// //           'totalAmountBeforeTax': totalBeforeTax,
// //           'totalTaxAmount': totalTaxAmount,
// //           'totalAmountAfterTax': totalAfterTax,
// //           'invoiceIds': invoiceIds,
// //           'updatedAt': Timestamp.now(),
// //         });
// //         print('تم تحديث سجل $taxType لسنة $year');
// //       } else {
// //         // إنشاء سجل جديد
// //         await _firestore.collection('taxes').add({
// //           'taxType': taxType,
// //           'year': year,
// //           'totalInvoices': yearInvoices.length,
// //           'totalAmountBeforeTax': totalBeforeTax,
// //           'totalTaxAmount': totalTaxAmount,
// //           'totalAmountAfterTax': totalAfterTax,
// //           'invoiceIds': invoiceIds,
// //           'createdAt': Timestamp.now(),
// //         });
// //         print('تم إنشاء سجل جديد $taxType لسنة $year');
// //       }
// //     } catch (e) {
// //       print('خطأ في حفظ سجل $taxType لسنة $year: $e');
// //       rethrow;
// //     }
// //   }

// //   // ================================
// //   // الحصول على سنة الفاتورة بناءً على نوع الضريبة
// //   // ================================
// //   int _getInvoiceYear(Map<String, dynamic> invoice, String taxType) {
// //     // أولوية لـ taxDate
// //     final taxDate = invoice['taxDate'] as DateTime?;
// //     if (taxDate != null) {
// //       return taxDate.year;
// //     }

// //     // إذا لم يكن هناك taxDate، استخدم تاريخ الضريبة المحدد
// //     if (taxType == '3%') {
// //       final tax3Date = invoice['tax3PercentDate'] as DateTime?;
// //       if (tax3Date != null) return tax3Date.year;
// //     } else {
// //       final tax14Date = invoice['tax14PercentDate'] as DateTime?;
// //       if (tax14Date != null) return tax14Date.year;
// //     }

// //     // أخيراً، تاريخ الإنشاء
// //     final createdAt = invoice['createdAt'] as DateTime?;
// //     return createdAt?.year ?? DateTime.now().year;
// //   }

// //   // ================================
// //   // البحث عن سجل ضريبي موجود
// //   // ================================
// //   Future<Map<String, dynamic>?> _findExistingTaxRecord(
// //     String taxType,
// //     int year,
// //   ) async {
// //     try {
// //       final querySnapshot = await _firestore
// //           .collection('taxes')
// //           .where('taxType', isEqualTo: taxType)
// //           .where('year', isEqualTo: year)
// //           .limit(1)
// //           .get();

// //       if (querySnapshot.docs.isNotEmpty) {
// //         final doc = querySnapshot.docs.first;
// //         final data = doc.data();
// //         return {'id': doc.id, ...data};
// //       }
// //       return null;
// //     } catch (e) {
// //       print('خطأ في البحث عن سجل ضريبي: $e');
// //       return null;
// //     }
// //   }

// //   // ================================
// //   // تحميل الفواتير المرتبطة بسجل ضريبي
// //   // ================================
// //   Future<void> _loadTaxRecordInvoices(Map<String, dynamic> taxRecord) async {
// //     final invoiceIds = List<String>.from(taxRecord['invoiceIds'] ?? []);

// //     setState(() {
// //       _taxRecordInvoices = [];
// //       _isLoading = true;
// //     });

// //     try {
// //       final List<Map<String, dynamic>> invoicesList = [];

// //       for (final invoiceId in invoiceIds) {
// //         final doc = await _firestore
// //             .collection('invoices')
// //             .doc(invoiceId)
// //             .get();

// //         if (doc.exists) {
// //           final data = doc.data() as Map<String, dynamic>;
// //           final taxAmount = taxRecord['taxType'] == '3%'
// //               ? ((data['tax3Percent'] as num?) ?? 0).toDouble()
// //               : ((data['tax14Percent'] as num?) ?? 0).toDouble();

// //           invoicesList.add({
// //             'id': doc.id,
// //             'name': (data['name'] as String?) ?? 'فاتورة بدون اسم',
// //             'companyName':
// //                 (data['companyName'] as String?) ?? 'شركة غير معروفة',
// //             'totalAmount': ((data['totalAmount'] as num?) ?? 0).toDouble(),
// //             'taxAmount': taxAmount,
// //             'amountAfterTax':
// //                 ((data['totalAmount'] as num?) ?? 0).toDouble() - taxAmount,
// //             'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
// //           });
// //         }
// //       }

// //       setState(() {
// //         _taxRecordInvoices = invoicesList;
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() => _isLoading = false);
// //       _showError('خطأ في تحميل تفاصيل السجل الضريبي: $e');
// //     }
// //   }

// //   // ================================
// //   // عرض نافذة اختيار التاريخ
// //   // ================================
// //   Future<DateTime?> _showDatePickerDialog() async {
// //     final selectedDate = await showDatePicker(
// //       context: context,
// //       initialDate: DateTime.now(),
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime(2030),
// //       builder: (context, child) {
// //         return Theme(
// //           data: ThemeData.light().copyWith(
// //             primaryColor: const Color(0xFF3498DB),
// //             colorScheme: const ColorScheme.light(primary: Color(0xFF3498DB)),
// //             buttonTheme: const ButtonThemeData(
// //               textTheme: ButtonTextTheme.primary,
// //             ),
// //           ),
// //           child: child!,
// //         );
// //       },
// //     );

// //     if (selectedDate != null) {
// //       // تحديث السنة المحددة عند اختيار تاريخ
// //       setState(() {
// //         _selectedYear = selectedDate.year;
// //       });

// //       // إعادة تحميل البيانات للفلترة حسب السنة الجديدة
// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         _separateTaxInvoices();
// //       });
// //     }

// //     return selectedDate;
// //   }

// //   // ================================
// //   // عرض تفاصيل سجل ضريبي
// //   // ================================
// //   Future<void> _showTaxRecordDetails(Map<String, dynamic> taxRecord) async {
// //     setState(() {
// //       _selectedTaxRecord = taxRecord;
// //       _selectedMonthIndex = -1;
// //       _monthInvoices = [];
// //     });

// //     await _loadTaxRecordInvoices(taxRecord);
// //     _showTaxDetailsSheet(taxRecord);
// //   }

// //   // ================================
// //   // عرض تفاصيل السجل الضريبي
// //   // ================================
// //   void _showTaxDetailsSheet(Map<String, dynamic> taxRecord) {
// //     final taxType = taxRecord['taxType'];
// //     final year = taxRecord['year'];
// //     final totalInvoices = taxRecord['totalInvoices'];
// //     final totalBeforeTax = taxRecord['totalAmountBeforeTax'];
// //     final taxAmount = taxRecord['totalTaxAmount'];
// //     final totalAfterTax = taxRecord['totalAmountAfterTax'];

// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (context) {
// //         return Container(
// //           height: MediaQuery.of(context).size.height * 0.9,
// //           decoration: const BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.only(
// //               topLeft: Radius.circular(20),
// //               topRight: Radius.circular(20),
// //             ),
// //           ),
// //           child: Column(
// //             children: [
// //               // رأس البطاقة
// //               Container(
// //                 padding: const EdgeInsets.all(16),
// //                 decoration: BoxDecoration(
// //                   color: taxType == '3%'
// //                       ? const Color(0xFFE3F2FD)
// //                       : const Color(0xFFE8F5E9),
// //                   borderRadius: const BorderRadius.only(
// //                     topLeft: Radius.circular(20),
// //                     topRight: Radius.circular(20),
// //                   ),
// //                 ),
// //                 child: Row(
// //                   children: [
// //                     Icon(
// //                       Icons.receipt_long,
// //                       color: taxType == '3%'
// //                           ? const Color(0xFF1976D2)
// //                           : const Color(0xFF2E7D32),
// //                       size: 30,
// //                     ),
// //                     const SizedBox(width: 12),
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             'سجل ضريبة $taxType - سنة $year',
// //                             style: TextStyle(
// //                               fontSize: 18,
// //                               fontWeight: FontWeight.bold,
// //                               color: taxType == '3%'
// //                                   ? const Color(0xFF1976D2)
// //                                   : const Color(0xFF2E7D32),
// //                             ),
// //                           ),
// //                           Text(
// //                             'إنشئ في: ${_formatDate(taxRecord['createdAt'])}',
// //                             style: const TextStyle(
// //                               fontSize: 12,
// //                               color: Colors.grey,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     IconButton(
// //                       icon: const Icon(Icons.close, color: Colors.grey),
// //                       onPressed: () => Navigator.pop(context),
// //                     ),
// //                   ],
// //                 ),
// //               ),

// //               // الإجماليات
// //               Padding(
// //                 padding: const EdgeInsets.all(16),
// //                 child: _buildTaxSummaryCard(
// //                   taxType: taxType,
// //                   totalInvoices: totalInvoices,
// //                   totalBeforeTax: totalBeforeTax,
// //                   taxAmount: taxAmount,
// //                   totalAfterTax: totalAfterTax,
// //                 ),
// //               ),

// //               // عنوان الفواتير
// //               Padding(
// //                 padding: const EdgeInsets.symmetric(horizontal: 16),
// //                 child: Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     const Text(
// //                       'الفواتير المضمنة:',
// //                       style: TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                     Text(
// //                       '(${_taxRecordInvoices.length}) فاتورة',
// //                       style: const TextStyle(color: Colors.grey),
// //                     ),
// //                   ],
// //                 ),
// //               ),

// //               // قائمة الفواتير
// //               Expanded(
// //                 child: _isLoading
// //                     ? const Center(child: CircularProgressIndicator())
// //                     : _taxRecordInvoices.isEmpty
// //                     ? Center(
// //                         child: Column(
// //                           mainAxisAlignment: MainAxisAlignment.center,
// //                           children: [
// //                             Icon(
// //                               Icons.receipt,
// //                               size: 60,
// //                               color: Colors.grey[400],
// //                             ),
// //                             const SizedBox(height: 16),
// //                             const Text(
// //                               'لا توجد فواتير في هذا السجل',
// //                               style: TextStyle(
// //                                 color: Colors.grey,
// //                                 fontSize: 16,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       )
// //                     : ListView.builder(
// //                         padding: const EdgeInsets.all(16),
// //                         itemCount: _taxRecordInvoices.length,
// //                         itemBuilder: (context, index) {
// //                           final invoice = _taxRecordInvoices[index];
// //                           return _buildTaxInvoiceCard(invoice, taxType, index);
// //                         },
// //                       ),
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   // ================================
// //   // بناء بطاقة ملخص الضريبة
// //   // ================================
// //   Widget _buildTaxSummaryCard({
// //     required String taxType,
// //     required int totalInvoices,
// //     required double totalBeforeTax,
// //     required double taxAmount,
// //     required double totalAfterTax,
// //   }) {
// //     return Card(
// //       elevation: 4,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           children: [
// //             // عنوان البطاقة
// //             Text(
// //               'إحصائيات ضريبة $taxType',
// //               style: TextStyle(
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.bold,
// //                 color: taxType == '3%' ? Colors.blue[800] : Colors.green[800],
// //               ),
// //             ),
// //             const SizedBox(height: 20),

// //             // عدد الفواتير
// //             _buildSummaryItem(
// //               icon: Icons.receipt,
// //               label: 'عدد الفواتير',
// //               value: '$totalInvoices',
// //               color: const Color(0xFF3498DB),
// //             ),

// //             const SizedBox(height: 16),

// //             // إجمالي قبل الضريبة
// //             _buildSummaryItem(
// //               icon: Icons.attach_money,
// //               label: 'الإجمالي قبل الضريبة',
// //               value: _formatCurrency(totalBeforeTax),
// //               color: Colors.blue[700]!,
// //             ),

// //             const SizedBox(height: 16),

// //             // قيمة الضريبة
// //             _buildSummaryItem(
// //               icon: taxType == '3%'
// //                   ? Icons.account_balance_wallet
// //                   : Icons.account_balance,
// //               label: 'قيمة الضريبة $taxType',
// //               value: _formatCurrency(taxAmount),
// //               color: taxType == '3%' ? Colors.blue[800]! : Colors.green[800]!,
// //             ),

// //             const SizedBox(height: 16),

// //             // الإجمالي بعد الضريبة
// //             Container(
// //               padding: const EdgeInsets.all(16),
// //               decoration: BoxDecoration(
// //                 color: Colors.red[50],
// //                 borderRadius: BorderRadius.circular(12),
// //                 border: Border.all(color: Colors.red[100]!),
// //               ),
// //               child: Row(
// //                 children: [
// //                   Icon(Icons.money_off, color: Colors.red[700], size: 24),
// //                   const SizedBox(width: 12),
// //                   Expanded(
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           'الإجمالي بعد خصم الضريبة',
// //                           style: TextStyle(
// //                             fontSize: 14,
// //                             fontWeight: FontWeight.bold,
// //                             color: Colors.red[700],
// //                           ),
// //                         ),
// //                         const SizedBox(height: 4),
// //                         Text(
// //                           _formatCurrency(totalAfterTax),
// //                           style: const TextStyle(
// //                             fontSize: 20,
// //                             fontWeight: FontWeight.bold,
// //                             color: Colors.red,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildSummaryItem({
// //     required IconData icon,
// //     required String label,
// //     required String value,
// //     required Color color,
// //   }) {
// //     return Container(
// //       padding: const EdgeInsets.all(12),
// //       decoration: BoxDecoration(
// //         color: Colors.grey[50],
// //         borderRadius: BorderRadius.circular(10),
// //       ),
// //       child: Row(
// //         children: [
// //           Icon(icon, color: color, size: 22),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   label,
// //                   style: const TextStyle(fontSize: 14, color: Colors.grey),
// //                 ),
// //                 const SizedBox(height: 4),
// //                 Text(
// //                   value,
// //                   style: TextStyle(
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.bold,
// //                     color: color,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ================================
// //   // بناء بطاقة الفاتورة في تفاصيل الضريبة
// //   // ================================
// //   Widget _buildTaxInvoiceCard(
// //     Map<String, dynamic> invoice,
// //     String taxType,
// //     int index,
// //   ) {
// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 12),
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // رأس البطاقة
// //             Row(
// //               children: [
// //                 Container(
// //                   width: 36,
// //                   height: 36,
// //                   decoration: BoxDecoration(
// //                     color: taxType == '3%' ? Colors.blue[50] : Colors.green[50],
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                   child: Center(
// //                     child: Text(
// //                       '${index + 1}',
// //                       style: TextStyle(
// //                         fontWeight: FontWeight.bold,
// //                         color: taxType == '3%'
// //                             ? Colors.blue[800]
// //                             : Colors.green[800],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 12),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         invoice['name'],
// //                         style: const TextStyle(
// //                           fontWeight: FontWeight.bold,
// //                           fontSize: 16,
// //                         ),
// //                       ),
// //                       Text(
// //                         invoice['companyName'],
// //                         style: TextStyle(fontSize: 13, color: Colors.grey[600]),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),

// //             const SizedBox(height: 16),

// //             // تفاصيل المبلغ
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       'سعر الفاتورة',
// //                       style: TextStyle(fontSize: 13, color: Colors.grey[600]),
// //                     ),
// //                     const SizedBox(height: 4),
// //                     Text(
// //                       _formatCurrency(invoice['totalAmount']),
// //                       style: const TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                         color: Colors.blue,
// //                       ),
// //                     ),
// //                   ],
// //                 ),

// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.end,
// //                   children: [
// //                     Text(
// //                       'ضريبة $taxType',
// //                       style: TextStyle(fontSize: 13, color: Colors.grey[600]),
// //                     ),
// //                     const SizedBox(height: 4),
// //                     Text(
// //                       _formatCurrency(invoice['taxAmount']),
// //                       style: TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                         color: taxType == '3%'
// //                             ? Colors.blue[800]
// //                             : Colors.green[800],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),

// //             const SizedBox(height: 12),

// //             // الإجمالي بعد الضريبة
// //             Container(
// //               padding: const EdgeInsets.all(12),
// //               decoration: BoxDecoration(
// //                 color: Colors.red[50],
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Text(
// //                     'الإجمالي بعد الضريبة',
// //                     style: TextStyle(
// //                       fontSize: 14,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.red[700],
// //                     ),
// //                   ),
// //                   Text(
// //                     _formatCurrency(invoice['amountAfterTax']),
// //                     style: const TextStyle(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.red,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),

// //             const SizedBox(height: 12),

// //             // تاريخ الفاتورة
// //             Text(
// //               'تاريخ الفاتورة: ${_formatDate(invoice['createdAt'])}',
// //               style: const TextStyle(fontSize: 12, color: Colors.grey),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ================================
// //   // دوال مساعدة
// //   // ================================
// //   void _showError(String message) {
// //     // ScaffoldMessenger.of(context).showSnackBar(
// //     //   SnackBar(
// //     //     content: Text(message),
// //     //     backgroundColor: Colors.red,
// //     //     duration: const Duration(seconds: 3),
// //     //   ),
// //     // );
// //   }

// //   void _showSuccess(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         backgroundColor: Colors.green,
// //         duration: const Duration(seconds: 2),
// //       ),
// //     );
// //   }

// //   String _formatDate(DateTime? date) {
// //     if (date == null) return '-';
// //     return DateFormat('dd/MM/yyyy').format(date);
// //   }

// //   String _formatCurrency(double amount) {
// //     return '${amount.toStringAsFixed(2)} ج';
// //   }

// //   void _changePage(int page) {
// //     setState(() {
// //       _currentPage = page;
// //       _selectedTaxRecord = null;
// //       _taxRecordInvoices.clear();
// //       _selectedMonthIndex = -1;
// //       _monthInvoices = [];
// //     });

// //     // تحميل البيانات الخاصة بالصفحة
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _loadDashboardData();
// //     });
// //   }

// //   void _onYearChanged(int? value) {
// //     if (value != null) {
// //       setState(() {
// //         _selectedYear = value;
// //         _selectedTaxRecord = null;
// //         _taxRecordInvoices.clear();
// //         _selectedMonthIndex = -1;
// //         _monthInvoices = [];
// //       });

// //       // إعادة تحميل البيانات حسب السنة الجديدة
// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         _loadDashboardData();
// //       });
// //     }
// //   }

// //   // ================================
// //   // وظائف جديدة للأشهر
// //   // ================================
// //   void _selectMonth(int monthIndex) {
// //     setState(() {
// //       if (_selectedMonthIndex == monthIndex) {
// //         // إذا كان نفس الشهر، إلغاء التحديد
// //         _selectedMonthIndex = -1;
// //         _monthInvoices = [];
// //       } else {
// //         _selectedMonthIndex = monthIndex;
// //         _monthInvoices = _monthlyTaxData[monthIndex]['invoices'];
// //       }
// //     });
// //   }

// //   // ================================
// //   // حذف خصم ضريبي
// //   // ================================
// //   Future<void> _deleteDeduction(String id) async {
// //     bool confirm =
// //         await showDialog(
// //           context: context,
// //           builder: (context) => AlertDialog(
// //             title: const Text('تأكيد الحذف'),
// //             content: const Text('هل أنت متأكد من حذف هذا الخصم؟'),
// //             actions: [
// //               TextButton(
// //                 onPressed: () => Navigator.pop(context, false),
// //                 child: const Text('إلغاء'),
// //               ),
// //               ElevatedButton(
// //                 onPressed: () => Navigator.pop(context, true),
// //                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
// //                 child: const Text('حذف'),
// //               ),
// //             ],
// //           ),
// //         ) ??
// //         false;

// //     if (confirm) {
// //       try {
// //         await _firestore.collection('tax_deductions').doc(id).delete();
// //         _showSuccess('تم حذف الخصم بنجاح');

// //         // إعادة تحميل البيانات
// //         await _loadTaxDeductions();
// //         await _calculateYearStatistics();
// //       } catch (e) {
// //         _showError('خطأ في حذف الخصم: $e');
// //       }
// //     }
// //   }

// //   // ================================
// //   // بناء واجهة
// //   // ================================
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF4F6F8),
// //       body: Column(
// //         children: [
// //           _buildCustomAppBar(),
// //           _buildYearFilter(),
// //           _buildNavigationTabs(),
// //           Expanded(
// //             child: _isLoading && _currentPage != 1
// //                 ? const Center(child: CircularProgressIndicator())
// //                 : _buildCurrentPage(),
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
// //               _currentPage == 0 ? Icons.dashboard : Icons.request_quote,
// //               color: Colors.white,
// //               size: 28,
// //             ),
// //             const SizedBox(width: 8),
// //             const Expanded(
// //               child: Center(
// //                 child: Text(
// //                   'إدارة الضرائب',
// //                   style: TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 20,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //             IconButton(
// //               icon: const Icon(Icons.refresh, color: Colors.white),
// //               onPressed: _loadDashboardData,
// //               tooltip: 'تحديث البيانات',
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildYearFilter() {
// //     return Container(
// //       padding: const EdgeInsets.all(12),
// //       color: Colors.white,
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           const Text(
// //             'فلتر حسب السنة:',
// //             style: TextStyle(
// //               fontWeight: FontWeight.bold,
// //               color: Color(0xFF2C3E50),
// //             ),
// //           ),
// //           DropdownButton<int>(
// //             value: _selectedYear,
// //             onChanged: _onYearChanged,
// //             items: _availableYears
// //                 .map(
// //                   (year) =>
// //                       DropdownMenuItem(value: year, child: Text('سنة $year')),
// //                 )
// //                 .toList(),
// //             style: const TextStyle(
// //               color: Color(0xFF3498DB),
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildNavigationTabs() {
// //     return Container(
// //       color: Colors.white,
// //       child: Row(
// //         children: [
// //           _buildNavigationTab(0, Icons.dashboard, 'ضرائب السنة'),
// //           _buildNavigationTab(1, Icons.receipt, 'جميع الفواتير'),
// //           _buildNavigationTab(2, Icons.account_balance_wallet, 'صندوق 3%'),
// //           _buildNavigationTab(3, Icons.account_balance, 'صندوق 14%'),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildNavigationTab(int page, IconData icon, String title) {
// //     final isActive = _currentPage == page;
// //     return Expanded(
// //       child: InkWell(
// //         onTap: () => _changePage(page),
// //         child: Container(
// //           padding: const EdgeInsets.symmetric(vertical: 12),
// //           decoration: BoxDecoration(
// //             color: isActive
// //                 ? (page == 2
// //                       ? Colors.blue
// //                       : page == 3
// //                       ? Colors.green
// //                       : const Color(0xFF3498DB))
// //                 : Colors.white,
// //             border: Border(
// //               bottom: BorderSide(
// //                 color: isActive
// //                     ? (page == 2
// //                           ? Colors.blue
// //                           : page == 3
// //                           ? Colors.green
// //                           : const Color(0xFF3498DB))
// //                     : Colors.grey[300]!,
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
// //                   fontSize: 11,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildCurrentPage() {
// //     switch (_currentPage) {
// //       case 0:
// //         return _buildYearDashboard();
// //       case 1:
// //         return _buildInvoicesSection();
// //       case 2:
// //         return _build3PercentTaxSection();
// //       case 3:
// //         return _build14PercentTaxSection();
// //       default:
// //         return _buildYearDashboard();
// //     }
// //   }

// //   // ================================
// //   // بناء صفحة لوحة السنة
// //   // ================================
// //   Widget _buildYearDashboard() {
// //     return SingleChildScrollView(
// //       padding: const EdgeInsets.all(16),
// //       child: Column(
// //         children: [
// //           // بطاقة إحصائيات السنة
// //           _buildYearStatisticsCard(),

// //           const SizedBox(height: 24),

// //           // بطاقة الضرائب والخصومات
// //           _buildTaxesAndDeductionsCard(),

// //           const SizedBox(height: 24),

// //           // قائمة الخصومات
// //           _buildDeductionsList(),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildYearStatisticsCard() {
// //     return Card(
// //       elevation: 4,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           children: [
// //             // عنوان البطاقة
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 const Icon(Icons.bar_chart, color: Color(0xFF3498DB), size: 24),
// //                 const SizedBox(width: 8),
// //                 Text(
// //                   'إحصائيات سنة $_selectedYear',
// //                   style: const TextStyle(
// //                     fontSize: 20,
// //                     fontWeight: FontWeight.bold,
// //                     color: Color(0xFF2C3E50),
// //                   ),
// //                 ),
// //               ],
// //             ),

// //             const SizedBox(height: 24),

// //             // إجمالي فواتير السنة
// //             _buildStatisticRow(
// //               icon: Icons.receipt,
// //               label: 'إجمالي فواتير السنة',
// //               value: _formatCurrency(_yearTotalInvoicesAmount),
// //               color: Colors.blue,
// //             ),

// //             const SizedBox(height: 16),

// //             // إجمالي رصيد الفواتير
// //             // _buildStatisticRow(
// //             //   icon: Icons.account_balance_wallet,
// //             //   label: 'إجمالي رصيد الفواتير',
// //             //   value: _formatCurrency(_yearTotalBalance),
// //             //   color: Colors.green,
// //             // ),
// //             const SizedBox(height: 16),

// //             // إجمالي ضرائب 3%
// //             _buildStatisticRow(
// //               icon: Icons.account_balance_wallet,
// //               label: 'إجمالي ضرائب 3%',
// //               value: _formatCurrency(_yearTotal3PercentTax),
// //               color: Colors.blue[800]!,
// //             ),

// //             const SizedBox(height: 16),

// //             // إجمالي ضرائب 14%
// //             _buildStatisticRow(
// //               icon: Icons.account_balance,
// //               label: 'إجمالي ضرائب 14%',
// //               value: _formatCurrency(_yearTotal14PercentTax),
// //               color: Colors.green[800]!,
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildStatisticRow({
// //     required IconData icon,
// //     required String label,
// //     required String value,
// //     required Color color,
// //   }) {
// //     return Container(
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: Colors.grey[50],
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: Colors.grey[200]!),
// //       ),
// //       child: Row(
// //         children: [
// //           Icon(icon, color: color, size: 28),
// //           const SizedBox(width: 16),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   label,
// //                   style: const TextStyle(fontSize: 14, color: Colors.grey),
// //                 ),
// //                 const SizedBox(height: 4),
// //                 Text(
// //                   value,
// //                   style: TextStyle(
// //                     fontSize: 20,
// //                     fontWeight: FontWeight.bold,
// //                     color: color,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildTaxesAndDeductionsCard() {
// //     return Card(
// //       elevation: 4,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           children: [
// //             // إجمالي الضرائب
// //             _buildTaxSummaryItem(
// //               label: ' إجمالي الضرائب',
// //               value: _formatCurrency(_yearTotalTaxes),
// //               icon: Icons.attach_money,
// //               color: Colors.purple,
// //             ),

// //             const SizedBox(height: 16),

// //             // إجمالي الخصومات
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: _buildTaxSummaryItem(
// //                     label: 'إجمالي الخصومات',
// //                     value: _formatCurrency(_yearTotalDeductions),
// //                     icon: Icons.money_off,
// //                     color: Colors.red,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 16),
// //                 ElevatedButton.icon(
// //                   onPressed: _addTaxDeduction,
// //                   icon: const Icon(Icons.add, size: 18),
// //                   label: const Text('خصم'),
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: Colors.red,
// //                     foregroundColor: Colors.white,
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(10),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),

// //             const SizedBox(height: 16),

// //             // إجمالي الضرائب بعد الخصم
// //             Container(
// //               padding: const EdgeInsets.all(20),
// //               decoration: BoxDecoration(
// //                 color: Colors.orange[50],
// //                 borderRadius: BorderRadius.circular(12),
// //                 border: Border.all(color: Colors.orange[100]!),
// //               ),
// //               child: Row(
// //                 children: [
// //                   Icon(Icons.calculate, color: Colors.orange[800], size: 32),
// //                   const SizedBox(width: 16),
// //                   Expanded(
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text(
// //                           'إجمالي الضرائب بعد الخصم',
// //                           style: TextStyle(
// //                             fontSize: 16,
// //                             fontWeight: FontWeight.bold,
// //                             color: Colors.orange[800],
// //                           ),
// //                         ),
// //                         const SizedBox(height: 8),
// //                         Text(
// //                           _formatCurrency(_yearTotalTaxesAfterDeductions),
// //                           style: const TextStyle(
// //                             fontSize: 24,
// //                             fontWeight: FontWeight.bold,
// //                             color: Colors.deepOrange,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildTaxSummaryItem({
// //     required String label,
// //     required String value,
// //     required IconData icon,
// //     required Color color,
// //   }) {
// //     return Container(
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: color.withOpacity(0.05),
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: color.withOpacity(0.2)),
// //       ),
// //       child: Row(
// //         children: [
// //           Icon(icon, color: color, size: 24),
// //           const SizedBox(width: 16),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(label, style: TextStyle(fontSize: 14, color: color)),
// //                 const SizedBox(height: 4),
// //                 Text(
// //                   value,
// //                   style: TextStyle(
// //                     fontSize: 18,
// //                     fontWeight: FontWeight.bold,
// //                     color: color,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildDeductionsList() {
// //     return Card(
// //       elevation: 4,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // عنوان القائمة
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 const Text(
// //                   'سجل الخصومات',
// //                   style: TextStyle(
// //                     fontSize: 18,
// //                     fontWeight: FontWeight.bold,
// //                     color: Color(0xFF2C3E50),
// //                   ),
// //                 ),
// //                 Text(
// //                   '(${_taxDeductions.length}) خصم',
// //                   style: const TextStyle(fontSize: 14, color: Colors.grey),
// //                 ),
// //               ],
// //             ),

// //             const SizedBox(height: 16),

// //             // قائمة الخصومات
// //             if (_taxDeductions.isEmpty)
// //               Center(
// //                 child: Column(
// //                   children: [
// //                     Icon(Icons.money_off, size: 60, color: Colors.grey[400]),
// //                     const SizedBox(height: 16),
// //                     const Text(
// //                       'لا توجد خصومات',
// //                       style: TextStyle(fontSize: 16, color: Colors.grey),
// //                     ),
// //                   ],
// //                 ),
// //               )
// //             else
// //               ListView.builder(
// //                 shrinkWrap: true,
// //                 physics: const NeverScrollableScrollPhysics(),
// //                 itemCount: _taxDeductions.length,
// //                 itemBuilder: (context, index) {
// //                   final deduction = _taxDeductions[index];
// //                   return _buildDeductionCard(deduction, index);
// //                 },
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildDeductionCard(Map<String, dynamic> deduction, int index) {
// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 12),
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: ListTile(
// //         leading: Container(
// //           width: 40,
// //           height: 40,
// //           decoration: BoxDecoration(
// //             color: Colors.red[50],
// //             borderRadius: BorderRadius.circular(8),
// //           ),
// //           child: Center(
// //             child: Text(
// //               '${index + 1}',
// //               style: const TextStyle(
// //                 fontWeight: FontWeight.bold,
// //                 color: Colors.red,
// //               ),
// //             ),
// //           ),
// //         ),
// //         title: Text(
// //           _formatCurrency(deduction['amount']),
// //           style: const TextStyle(
// //             fontWeight: FontWeight.bold,
// //             fontSize: 16,
// //             color: Colors.red,
// //           ),
// //         ),
// //         subtitle: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               deduction['description'],
// //               style: const TextStyle(fontSize: 13),
// //               maxLines: 2,
// //               overflow: TextOverflow.ellipsis,
// //             ),
// //             const SizedBox(height: 4),
// //             Text(
// //               _formatDate(deduction['date']),
// //               style: const TextStyle(fontSize: 12, color: Colors.grey),
// //             ),
// //           ],
// //         ),
// //         trailing: IconButton(
// //           icon: const Icon(Icons.delete, color: Colors.grey),
// //           onPressed: () async {
// //             await _deleteDeduction(deduction['id']);
// //           },
// //         ),
// //       ),
// //     );
// //   }

// //   // ================================
// //   // بناء صفحة جميع الفواتير
// //   // ================================
// //   Widget _buildInvoicesSection() {
// //     return Column(
// //       children: [
// //         // شريط البحث
// //         _buildSearchBar(),

// //         // تبويب السجل
// //         _buildArchiveTab(),

// //         Expanded(
// //           child: _filteredInvoices.isEmpty && !_isLoading
// //               ? Center(
// //                   child: Column(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       Icon(Icons.receipt, size: 80, color: Colors.grey[400]),
// //                       const SizedBox(height: 16),
// //                       const Text(
// //                         'لا توجد فواتير',
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           color: Colors.grey,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 )
// //               : NotificationListener<ScrollNotification>(
// //                   onNotification: (ScrollNotification scrollInfo) {
// //                     if (!_isLoadingMore &&
// //                         _hasMoreInvoices &&
// //                         scrollInfo.metrics.pixels ==
// //                             scrollInfo.metrics.maxScrollExtent) {
// //                       _loadInvoices(loadMore: true);
// //                       return true;
// //                     }
// //                     return false;
// //                   },
// //                   child: ListView.builder(
// //                     padding: const EdgeInsets.all(8),
// //                     itemCount:
// //                         _filteredInvoices.length + (_hasMoreInvoices ? 1 : 0),
// //                     itemBuilder: (context, index) {
// //                       if (index == _filteredInvoices.length) {
// //                         return _buildLoadMoreIndicator();
// //                       }
// //                       final invoice = _filteredInvoices[index];
// //                       return _buildInvoiceCard(invoice, index);
// //                     },
// //                   ),
// //                 ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildArchiveTab() {
// //     return Container(
// //       color: Colors.white,
// //       child: Row(
// //         children: [
// //           Expanded(
// //             child: TextButton(
// //               onPressed: () {
// //                 setState(() {
// //                   _filteredInvoices = _applySearchFilter(
// //                     _allInvoices
// //                         .where((invoice) => !(invoice['isArchived'] ?? false))
// //                         .toList(),
// //                   );
// //                 });
// //               },
// //               child: Text(
// //                 'الفواتير النشطة',
// //                 style: TextStyle(
// //                   color: Colors.blue,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ),
// //           ),
// //           Expanded(
// //             child: TextButton(
// //               onPressed: () {
// //                 setState(() {
// //                   _filteredInvoices = _applySearchFilter(
// //                     _allInvoices
// //                         .where((invoice) => (invoice['isArchived'] ?? false))
// //                         .toList(),
// //                   );
// //                 });
// //               },
// //               child: Text(
// //                 'السجل',
// //                 style: TextStyle(
// //                   color: Colors.grey,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildLoadMoreIndicator() {
// //     return Padding(
// //       padding: const EdgeInsets.all(16),
// //       child: Center(
// //         child: _isLoadingMore
// //             ? const CircularProgressIndicator()
// //             : ElevatedButton(
// //                 onPressed: () => _loadInvoices(loadMore: true),
// //                 child: const Text('تحميل المزيد'),
// //               ),
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
// //                     _filteredInvoices = _applySearchFilter(
// //                       _allInvoices
// //                           .where((invoice) => !(invoice['isArchived'] ?? false))
// //                           .toList(),
// //                     );
// //                   });
// //                 },
// //                 decoration: const InputDecoration(
// //                   hintText: 'ابحث عن فاتورة أو شركة...',
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
// //                     _filteredInvoices = _applySearchFilter(
// //                       _allInvoices
// //                           .where((invoice) => !(invoice['isArchived'] ?? false))
// //                           .toList(),
// //                     );
// //                   });
// //                 },
// //                 child: const Icon(Icons.clear, size: 18, color: Colors.grey),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildInvoiceCard(Map<String, dynamic> invoice, int index) {
// //     final has3Percent = invoice['has3PercentTax'] == true;
// //     final has14Percent = invoice['has14PercentTax'] == true;
// //     final isArchived = invoice['isArchived'] == true;
// //     final taxDate = invoice['taxDate'] as DateTime?;

// //     return Card(
// //       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: ExpansionTile(
// //         leading: Container(
// //           width: 40,
// //           height: 40,
// //           decoration: BoxDecoration(
// //             color: isArchived
// //                 ? Colors.grey[200]
// //                 : has3Percent || has14Percent
// //                 ? (has14Percent ? Colors.green[50] : Colors.blue[50])
// //                 : const Color(0xFFF4F6F8),
// //             borderRadius: BorderRadius.circular(8),
// //           ),
// //           child: Center(
// //             child: Text(
// //               '${index + 1}',
// //               style: TextStyle(
// //                 fontWeight: FontWeight.bold,
// //                 color: isArchived
// //                     ? Colors.grey[600]
// //                     : has3Percent || has14Percent
// //                     ? (has14Percent ? Colors.green[800] : Colors.blue[800])
// //                     : const Color(0xFF2C3E50),
// //               ),
// //             ),
// //           ),
// //         ),
// //         title: Text(
// //           invoice['name'],
// //           style: TextStyle(
// //             fontWeight: FontWeight.bold,
// //             fontSize: 16,
// //             color: isArchived ? Colors.grey[600] : const Color(0xFF2C3E50),
// //           ),
// //         ),
// //         subtitle: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               invoice['companyName'],
// //               style: TextStyle(
// //                 fontSize: 14,
// //                 color: isArchived ? Colors.grey[500] : Colors.grey[700],
// //               ),
// //             ),
// //             if (taxDate != null)
// //               Text(
// //                 'تاريخ الضريبة: ${_formatDate(taxDate)}',
// //                 style: const TextStyle(
// //                   fontSize: 12,
// //                   color: Colors.blue,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //           ],
// //         ),
// //         trailing: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Text(
// //               _formatCurrency(invoice['totalAmount']),
// //               style: TextStyle(
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 16,
// //                 color: isArchived ? Colors.grey[600] : const Color(0xFF2E7D32),
// //               ),
// //             ),
// //             const SizedBox(height: 3),
// //             if (has3Percent || has14Percent)
// //               Container(
// //                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// //                 decoration: BoxDecoration(
// //                   color: isArchived
// //                       ? Colors.grey[100]
// //                       : has14Percent
// //                       ? Colors.green[50]
// //                       : Colors.blue[50],
// //                   borderRadius: BorderRadius.circular(10),
// //                   border: Border.all(
// //                     color: isArchived
// //                         ? Colors.grey[300]!
// //                         : has14Percent
// //                         ? Colors.green[100]!
// //                         : Colors.blue[100]!,
// //                   ),
// //                 ),
// //                 child: Row(
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     if (has3Percent)
// //                       Text(
// //                         '3%  ',
// //                         style: TextStyle(
// //                           fontSize: 10,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.blue[800],
// //                         ),
// //                       ),
// //                     if (has3Percent && has14Percent)
// //                       const Text(' /  ', style: TextStyle(fontSize: 10)),
// //                     if (has14Percent)
// //                       Text(
// //                         ' 14%',
// //                         style: TextStyle(
// //                           fontSize: 10,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.green[800],
// //                         ),
// //                       ),
// //                   ],
// //                 ),
// //               ),
// //           ],
// //         ),
// //         children: [
// //           Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //             child: Column(
// //               children: [
// //                 // زر نقل إلى الضرائب
// //                 if (!isArchived && (!has3Percent || !has14Percent))
// //                   SizedBox(
// //                     width: double.infinity,
// //                     child: ElevatedButton.icon(
// //                       onPressed: () => _moveToBothTaxBoxes(invoice),
// //                       icon: const Icon(Icons.account_balance_wallet, size: 20),
// //                       label: const Text('نقل إلى الضرائب'),
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: const Color(0xFF3498DB),
// //                         foregroundColor: Colors.white,
// //                         padding: const EdgeInsets.symmetric(vertical: 14),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(10),
// //                         ),
// //                       ),
// //                     ),
// //                   ),

// //                 const SizedBox(height: 12),

// //                 // إحصائيات الفاتورة
// //                 Container(
// //                   padding: const EdgeInsets.all(16),
// //                   decoration: BoxDecoration(
// //                     color: const Color(0xFFF8F9FA),
// //                     borderRadius: BorderRadius.circular(12),
// //                     border: Border.all(color: Colors.grey[200]!),
// //                   ),
// //                   child: Column(
// //                     children: [
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Text(
// //                             'عدد الرحلات:',
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               color: isArchived
// //                                   ? Colors.grey[600]
// //                                   : Colors.black,
// //                             ),
// //                           ),
// //                           Text(
// //                             '${invoice['tripCount']}',
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               color: isArchived
// //                                   ? Colors.grey[600]
// //                                   : const Color(0xFF3498DB),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 8),
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Text(
// //                             'إجمالي النولون:',
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               color: isArchived
// //                                   ? Colors.grey[600]
// //                                   : Colors.green,
// //                             ),
// //                           ),
// //                           Text(
// //                             _formatCurrency(invoice['nolonTotal']),
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               color: isArchived
// //                                   ? Colors.grey[600]
// //                                   : Colors.green,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 8),
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Text(
// //                             'إجمالي المبيت:',
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               color: isArchived
// //                                   ? Colors.grey[600]
// //                                   : Colors.orange,
// //                             ),
// //                           ),
// //                           Text(
// //                             _formatCurrency(invoice['overnightTotal']),
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               color: isArchived
// //                                   ? Colors.grey[600]
// //                                   : Colors.orange,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 8),
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Text(
// //                             'إجمالي العطلة:',
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               color: isArchived ? Colors.grey[600] : Colors.red,
// //                             ),
// //                           ),
// //                           Text(
// //                             _formatCurrency(invoice['holidayTotal']),
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               color: isArchived ? Colors.grey[600] : Colors.red,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ================================
// //   // بناء صفحة ضريبة 3%
// //   // ================================
// //   Widget _build3PercentTaxSection() {
// //     return _buildTaxSection(
// //       taxType: '3%',
// //       invoices: _3PercentTaxInvoices,
// //       taxRecords: _taxes3Percent,
// //       color: Colors.blue,
// //     );
// //   }

// //   // ================================
// //   // بناء صفحة ضريبة 14%
// //   // ================================
// //   Widget _build14PercentTaxSection() {
// //     return _buildTaxSection(
// //       taxType: '14%',
// //       invoices: _14PercentTaxInvoices,
// //       taxRecords: _taxes14Percent,
// //       color: Colors.green,
// //     );
// //   }

// //   Widget _buildTaxSection({
// //     required String taxType,
// //     required List<Map<String, dynamic>> invoices,
// //     required List<Map<String, dynamic>> taxRecords,
// //     required Color color,
// //   }) {
// //     // حساب الإجماليات للسنة
// //     double totalBeforeTax = 0;
// //     double totalTaxAmount = 0;
// //     for (var invoice in invoices) {
// //       totalBeforeTax += invoice['totalAmount'];
// //       totalTaxAmount += taxType == '3%'
// //           ? invoice['tax3Percent']
// //           : invoice['tax14Percent'];
// //     }
// //     final totalAfterTax = totalBeforeTax - totalTaxAmount;

// //     return Column(
// //       children: [
// //         // إحصائيات السنة
// //         Padding(
// //           padding: const EdgeInsets.all(16),
// //           child: _buildTaxBoxSummaryCard(
// //             taxType: taxType,
// //             year: _selectedYear,
// //             totalInvoices: invoices.length,
// //             totalBeforeTax: totalBeforeTax,
// //             totalTaxAmount: totalTaxAmount,
// //             totalAfterTax: totalAfterTax,
// //             color: color,
// //           ),
// //         ),

// //         // تبويب السجلات والأشهر
// //         Container(
// //           color: Colors.white,
// //           child: Row(
// //             children: [
// //               Expanded(
// //                 child: TextButton(
// //                   onPressed: () {
// //                     setState(() {
// //                       _selectedTaxRecord = null;
// //                       _taxRecordInvoices.clear();
// //                       _selectedMonthIndex = -1;
// //                       _monthInvoices = [];
// //                     });
// //                   },
// //                   child: Text(
// //                     'السجلات الضريبية',
// //                     style: TextStyle(
// //                       color:
// //                           _selectedTaxRecord == null &&
// //                               _selectedMonthIndex == -1
// //                           ? color
// //                           : Colors.grey,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //               Expanded(
// //                 child: TextButton(
// //                   onPressed: () {
// //                     setState(() {
// //                       _selectedTaxRecord = null;
// //                       _taxRecordInvoices.clear();
// //                       _selectedMonthIndex = -1;
// //                       _monthInvoices = [];
// //                     });
// //                   },
// //                   child: Text(
// //                     'الضرائب الشهرية',
// //                     style: TextStyle(
// //                       color: _selectedMonthIndex != -1 ? color : Colors.grey,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),

// //         // قائمة الأشهر أو الفواتير
// //         Expanded(
// //           child: _selectedMonthIndex != -1
// //               ? _buildMonthInvoicesList()
// //               : _buildTaxContent(invoices, taxRecords, taxType, color),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildTaxContent(
// //     List<Map<String, dynamic>> invoices,
// //     List<Map<String, dynamic>> taxRecords,
// //     String taxType,
// //     Color color,
// //   ) {
// //     if (_selectedTaxRecord != null) {
// //       return _buildTaxRecordDetails();
// //     }

// //     // عرض قائمة الأشهر بدلاً من السجلات
// //     return _buildMonthsGrid();
// //   }

// //   Widget _buildMonthsGrid() {
// //     return GridView.builder(
// //       padding: const EdgeInsets.all(16),
// //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //         crossAxisCount: 6,
// //         crossAxisSpacing: 2,
// //         mainAxisSpacing: 2,
// //         childAspectRatio: 1.8,
// //       ),
// //       itemCount: _monthlyTaxData.length,
// //       itemBuilder: (context, index) {
// //         final monthData = _monthlyTaxData[index];
// //         final isSelected = index == _selectedMonthIndex;

// //         return _buildMonthCard(monthData, index, isSelected);
// //       },
// //     );
// //   }

// //   Widget _buildMonthCard(
// //     Map<String, dynamic> monthData,
// //     int index,
// //     bool isSelected,
// //   ) {
// //     final monthName = monthData['monthName'];
// //     final invoiceCount = monthData['invoiceCount'];
// //     final totalTax = monthData['totalTax'];
// //     final color = _currentPage == 2 ? Colors.blue : Colors.green;

// //     return GestureDetector(
// //       onTap: () => _selectMonth(index),
// //       child: Container(
// //         height: 30,
// //         decoration: BoxDecoration(
// //           color: isSelected ? color.withOpacity(0.1) : Colors.white,
// //           borderRadius: BorderRadius.circular(12),
// //           border: Border.all(
// //             color: isSelected ? color : Colors.grey[300]!,
// //             width: isSelected ? 2 : 1,
// //           ),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.grey.withOpacity(0.1),
// //               blurRadius: 4,
// //               offset: const Offset(0, 2),
// //             ),
// //           ],
// //         ),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Text(
// //               monthName,
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.bold,
// //                 color: isSelected ? color : Colors.black,
// //               ),
// //             ),
// //             const SizedBox(height: 8),
// //             if (invoiceCount > 0)
// //               Column(
// //                 children: [
// //                   Text(
// //                     '$invoiceCount فاتورة',
// //                     style: TextStyle(
// //                       fontSize: 12,
// //                       color: isSelected ? color : Colors.grey[600],
// //                     ),
// //                   ),
// //                   const SizedBox(height: 4),
// //                   Text(
// //                     _formatCurrency(totalTax),
// //                     style: TextStyle(
// //                       fontSize: 14,
// //                       fontWeight: FontWeight.bold,
// //                       color: isSelected ? color : Colors.green,
// //                     ),
// //                   ),
// //                 ],
// //               )
// //             else
// //               Text(
// //                 'لا توجد فواتير',
// //                 style: TextStyle(fontSize: 12, color: Colors.grey[400]),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildMonthInvoicesList() {
// //     if (_monthInvoices.isEmpty) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(Icons.receipt, size: 80, color: Colors.grey[400]),
// //             const SizedBox(height: 16),
// //             const Text(
// //               'لا توجد فواتير في هذا الشهر',
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 color: Colors.grey,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           ],
// //         ),
// //       );
// //     }

// //     return Column(
// //       children: [
// //         // عنوان الشهر
// //         Container(
// //           padding: const EdgeInsets.all(16),
// //           color: _currentPage == 2 ? Colors.blue[50] : Colors.green[50],
// //           child: Row(
// //             children: [
// //               Icon(
// //                 Icons.calendar_month,
// //                 color: _currentPage == 2 ? Colors.blue : Colors.green,
// //               ),
// //               const SizedBox(width: 12),
// //               Text(
// //                 _monthlyTaxData[_selectedMonthIndex]['monthName'],
// //                 style: TextStyle(
// //                   fontSize: 18,
// //                   fontWeight: FontWeight.bold,
// //                   color: _currentPage == 2 ? Colors.blue : Colors.green,
// //                 ),
// //               ),
// //               const Spacer(),
// //               Text(
// //                 '(${_monthInvoices.length}) فاتورة',
// //                 style: const TextStyle(fontSize: 14, color: Colors.grey),
// //               ),
// //             ],
// //           ),
// //         ),

// //         // قائمة الفواتير
// //         Expanded(
// //           child: ListView.builder(
// //             padding: const EdgeInsets.all(16),
// //             itemCount: _monthInvoices.length,
// //             itemBuilder: (context, index) {
// //               final invoice = _monthInvoices[index];
// //               return _buildMonthInvoiceCard(invoice, index);
// //             },
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildMonthInvoiceCard(Map<String, dynamic> invoice, int index) {
// //     final taxType = _currentPage == 2 ? '3%' : '14%';
// //     final taxAmount = _currentPage == 2
// //         ? invoice['tax3Percent']
// //         : invoice['tax14Percent'];
// //     final amountAfterTax = invoice['totalAmount'] - taxAmount;
// //     final invoiceDate = invoice['taxDate'] ?? invoice['createdAt'];

// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 12),
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // اسم الفاتورة
// //             Text(
// //               invoice['name'],
// //               style: const TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.bold,
// //                 color: Color(0xFF2C3E50),
// //               ),
// //             ),

// //             const SizedBox(height: 8),

// //             // التاريخ وسعر الفاتورة
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 // التاريخ على اليسار
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       'التاريخ',
// //                       style: TextStyle(fontSize: 12, color: Colors.grey[600]),
// //                     ),
// //                     const SizedBox(height: 4),
// //                     Text(
// //                       _formatDate(invoiceDate),
// //                       style: const TextStyle(
// //                         fontSize: 14,
// //                         fontWeight: FontWeight.bold,
// //                         color: Colors.blue,
// //                       ),
// //                     ),
// //                   ],
// //                 ),

// //                 // سعر الفاتورة في الوسط
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.center,
// //                   children: [
// //                     Text(
// //                       'سعر الفاتورة',
// //                       style: TextStyle(fontSize: 12, color: Colors.grey[600]),
// //                     ),
// //                     const SizedBox(height: 4),
// //                     Text(
// //                       _formatCurrency(invoice['totalAmount']),
// //                       style: const TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                         color: Color(0xFF2E7D32),
// //                       ),
// //                     ),
// //                   ],
// //                 ),

// //                 // الضرائب على اليمين
// //                 Column(
// //                   crossAxisAlignment: CrossAxisAlignment.end,
// //                   children: [
// //                     Text(
// //                       'ضريبة $taxType',
// //                       style: TextStyle(fontSize: 12, color: Colors.grey[600]),
// //                     ),
// //                     const SizedBox(height: 4),
// //                     Text(
// //                       _formatCurrency(taxAmount),
// //                       style: TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                         color: _currentPage == 2 ? Colors.blue : Colors.green,
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),

// //             const SizedBox(height: 12),

// //             // // الإجمالي بعد الضريبة
// //             // Container(
// //             //   padding: const EdgeInsets.all(12),
// //             //   decoration: BoxDecoration(
// //             //     color: Colors.red[50],
// //             //     borderRadius: BorderRadius.circular(8),
// //             //   ),
// //             //   child: Row(
// //             //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             //     children: [
// //             //       Text(
// //             //         'الإجمالي بعد الضريبة',
// //             //         style: TextStyle(
// //             //           fontSize: 14,
// //             //           fontWeight: FontWeight.bold,
// //             //           color: Colors.red[700],
// //             //         ),
// //             //       ),
// //             //       Text(
// //             //         _formatCurrency(amountAfterTax),
// //             //         style: const TextStyle(
// //             //           fontSize: 16,
// //             //           fontWeight: FontWeight.bold,
// //             //           color: Colors.red,
// //             //         ),
// //             //       ),
// //             //     ],
// //             //   ),
// //             // ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildTaxBoxSummaryCard({
// //     required String taxType,
// //     required int year,
// //     required int totalInvoices,
// //     required double totalBeforeTax,
// //     required double totalTaxAmount,
// //     required double totalAfterTax,
// //     required Color color,
// //   }) {
// //     return Card(
// //       elevation: 4,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //       color: color.withOpacity(0.05),
// //       child: Padding(
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           children: [
// //             // العنوان
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(
// //                   taxType == '3%'
// //                       ? Icons.account_balance_wallet
// //                       : Icons.account_balance,
// //                   color: color,
// //                   size: 24,
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Text(
// //                   'صندوق $taxType - سنة $year',
// //                   style: TextStyle(
// //                     fontSize: 18,
// //                     fontWeight: FontWeight.bold,
// //                     color: color,
// //                   ),
// //                 ),
// //               ],
// //             ),

// //             const SizedBox(height: 20),

// //             // شبكة الإحصائيات
// //             Row(
// //               children: [
// //                 // عدد الفواتير
// //                 Expanded(
// //                   child: _buildStatBox(
// //                     title: 'عدد الفواتير',
// //                     value: '$totalInvoices',
// //                     icon: Icons.receipt,
// //                     color: const Color(0xFF3498DB),
// //                   ),
// //                 ),

// //                 const SizedBox(width: 12),

// //                 // الإجمالي قبل الضريبة
// //                 Expanded(
// //                   child: _buildStatBox(
// //                     title: 'الإجمالي قبل الضريبة',
// //                     value: _formatCurrency(totalBeforeTax),
// //                     icon: Icons.attach_money,
// //                     color: Colors.blue[700]!,
// //                   ),
// //                 ),
// //               ],
// //             ),

// //             const SizedBox(height: 12),

// //             Row(
// //               children: [
// //                 // قيمة الضريبة
// //                 Expanded(
// //                   child: _buildStatBox(
// //                     title: 'قيمة الضريبة',
// //                     value: _formatCurrency(totalTaxAmount),
// //                     icon: Icons.account_balance_wallet,
// //                     color: color,
// //                   ),
// //                 ),

// //                 const SizedBox(width: 12),

// //                 // الإجمالي بعد الضريبة
// //                 // Expanded(
// //                 // child: Container(
// //                 //   padding: const EdgeInsets.all(12),
// //                 //   decoration: BoxDecoration(
// //                 //     color: Colors.red[50],
// //                 //     borderRadius: BorderRadius.circular(12),
// //                 //     border: Border.all(color: Colors.red[100]!),
// //                 //   ),
// //                 //   child: Column(
// //                 //     crossAxisAlignment: CrossAxisAlignment.start,
// //                 //     children: [
// //                 //       Row(
// //                 //         children: [
// //                 //           Icon(
// //                 //             Icons.money_off,
// //                 //             color: Colors.red[700],
// //                 //             size: 20,
// //                 //           ),
// //                 //           const SizedBox(width: 8),
// //                 //           Expanded(
// //                 //             child: Text(
// //                 //               'الإجمالي بعد الضريبة',
// //                 //               style: TextStyle(
// //                 //                 fontSize: 12,
// //                 //                 fontWeight: FontWeight.bold,
// //                 //                 color: Colors.red[700],
// //                 //               ),
// //                 //             ),
// //                 //           ),
// //                 //         ],
// //                 //       ),
// //                 //       const SizedBox(height: 8),
// //                 //       Text(
// //                 //         _formatCurrency(totalAfterTax),
// //                 //         style: const TextStyle(
// //                 //           fontSize: 18,
// //                 //           fontWeight: FontWeight.bold,
// //                 //           color: Colors.red,
// //                 //         ),
// //                 //       ),
// //                 //     ],
// //                 //   ),
// //                 // ),
// //                 // ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildStatBox({
// //     required String title,
// //     required String value,
// //     required IconData icon,
// //     required Color color,
// //   }) {
// //     return Container(
// //       padding: const EdgeInsets.all(12),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: Colors.grey[200]!),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             children: [
// //               Icon(icon, color: color, size: 18),
// //               const SizedBox(width: 8),
// //               Expanded(
// //                 child: Text(
// //                   title,
// //                   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
// //                 ),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 8),
// //           Text(
// //             value,
// //             style: TextStyle(
// //               fontSize: 16,
// //               fontWeight: FontWeight.bold,
// //               color: color,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildTaxRecordsList(List<Map<String, dynamic>> records, Color color) {
// //     return records.isEmpty
// //         ? Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(Icons.history, size: 80, color: Colors.grey[400]),
// //                 const SizedBox(height: 16),
// //                 const Text(
// //                   'لا توجد سجلات ضريبية لهذه السنة',
// //                   style: TextStyle(
// //                     fontSize: 16,
// //                     color: Colors.grey,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           )
// //         : ListView.builder(
// //             padding: const EdgeInsets.all(8),
// //             itemCount: records.length,
// //             itemBuilder: (context, index) {
// //               final record = records[index];
// //               return _buildTaxRecordCard(record, color, index);
// //             },
// //           );
// //   }

// //   Widget _buildTaxRecordCard(
// //     Map<String, dynamic> record,
// //     Color color,
// //     int index,
// //   ) {
// //     final year = record['year'];
// //     final totalInvoices = record['totalInvoices'];
// //     final totalBeforeTax = record['totalAmountBeforeTax'];
// //     final totalTax = record['totalTaxAmount'];
// //     final totalAfterTax = record['totalAmountAfterTax'];

// //     return Card(
// //       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: ListTile(
// //         leading: Container(
// //           width: 50,
// //           height: 50,
// //           decoration: BoxDecoration(
// //             color: color.withOpacity(0.1),
// //             borderRadius: BorderRadius.circular(8),
// //             border: Border.all(color: color.withOpacity(0.3)),
// //           ),
// //           child: Center(
// //             child: Text(
// //               '${index + 1}',
// //               style: TextStyle(
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.bold,
// //                 color: color,
// //               ),
// //             ),
// //           ),
// //         ),
// //         title: Text(
// //           'سنة $year',
// //           style: TextStyle(
// //             fontWeight: FontWeight.bold,
// //             fontSize: 17,
// //             color: color,
// //           ),
// //         ),
// //         subtitle: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             const SizedBox(height: 4),
// //             Text(
// //               'فاتورة :$totalInvoices   ',
// //               style: const TextStyle(fontSize: 13),
// //             ),
// //           ],
// //         ),
// //         trailing: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           crossAxisAlignment: CrossAxisAlignment.end,
// //           children: [
// //             Text(
// //               _formatCurrency(totalTax),
// //               style: const TextStyle(
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 16,
// //                 color: Colors.green,
// //               ),
// //             ),
// //             const SizedBox(height: 4),
// //             Text(
// //               ' الضريبة',
// //               style: TextStyle(fontSize: 11, color: Colors.grey[600]),
// //             ),
// //           ],
// //         ),
// //         onTap: () => _showTaxRecordDetails(record),
// //         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //       ),
// //     );
// //   }

// //   Widget _buildTaxInvoicesList(
// //     List<Map<String, dynamic>> invoices,
// //     String taxType,
// //     Color color,
// //   ) {
// //     return invoices.isEmpty
// //         ? Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(Icons.receipt, size: 80, color: Colors.grey[400]),
// //                 const SizedBox(height: 16),
// //                 Text(
// //                   'لا توجد فواتير لسنة $_selectedYear',
// //                   style: const TextStyle(
// //                     fontSize: 16,
// //                     color: Colors.grey,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           )
// //         : ListView.builder(
// //             padding: const EdgeInsets.all(8),
// //             itemCount: invoices.length,
// //             itemBuilder: (context, index) {
// //               final invoice = invoices[index];
// //               return _buildTaxBoxInvoiceItem(invoice, taxType, color, index);
// //             },
// //           );
// //   }

// //   Widget _buildTaxBoxInvoiceItem(
// //     Map<String, dynamic> invoice,
// //     String taxType,
// //     Color color,
// //     int index,
// //   ) {
// //     final taxAmount = taxType == '3%'
// //         ? invoice['tax3Percent']
// //         : invoice['tax14Percent'];
// //     final amountAfterTax = invoice['totalAmount'] - taxAmount;

// //     return Card(
// //       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // رأس البطاقة
// //             Row(
// //               children: [
// //                 Container(
// //                   width: 36,
// //                   height: 36,
// //                   decoration: BoxDecoration(
// //                     color: color.withOpacity(0.1),
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                   child: Center(
// //                     child: Text(
// //                       '${index + 1}',
// //                       style: TextStyle(
// //                         fontWeight: FontWeight.bold,
// //                         color: color,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 12),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         invoice['name'],
// //                         style: const TextStyle(
// //                           fontWeight: FontWeight.bold,
// //                           fontSize: 16,
// //                         ),
// //                       ),
// //                       Text(
// //                         invoice['companyName'],
// //                         style: TextStyle(fontSize: 13, color: Colors.grey[600]),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),

// //             const SizedBox(height: 16),

// //             // سعر الفاتورة والضريبة
// //             Row(
// //               children: [
// //                 // سعر الفاتورة
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         'سعر الفاتورة',
// //                         style: TextStyle(fontSize: 13, color: Colors.grey[600]),
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Text(
// //                         _formatCurrency(invoice['totalAmount']),
// //                         style: const TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.blue,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),

// //                 // الضريبة
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         'ضريبة $taxType',
// //                         style: TextStyle(fontSize: 13, color: Colors.grey[600]),
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Text(
// //                         _formatCurrency(taxAmount),
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.bold,
// //                           color: color,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),

// //             const SizedBox(height: 12),

// //             // الإجمالي بعد الضريبة
// //             Container(
// //               padding: const EdgeInsets.all(12),
// //               decoration: BoxDecoration(
// //                 color: Colors.red[50],
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Text(
// //                     'الإجمالي بعد الضريبة',
// //                     style: TextStyle(
// //                       fontSize: 14,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.red[700],
// //                     ),
// //                   ),
// //                   Text(
// //                     _formatCurrency(amountAfterTax),
// //                     style: const TextStyle(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.red,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildTaxRecordDetails() {
// //     if (_selectedTaxRecord == null) return Container();

// //     return ListView.builder(
// //       padding: const EdgeInsets.all(8),
// //       itemCount: _taxRecordInvoices.length,
// //       itemBuilder: (context, index) {
// //         final invoice = _taxRecordInvoices[index];
// //         final taxType = _selectedTaxRecord!['taxType'];
// //         final color = taxType == '3%' ? Colors.blue : Colors.green;

// //         return _buildTaxBoxInvoiceItem(invoice, taxType, color, index);
// //       },
// //     );
// //   }
// // }
// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class TaxesPage extends StatefulWidget {
//   const TaxesPage({super.key});

//   @override
//   State<TaxesPage> createState() => _TaxesPageState();
// }

// class _TaxesPageState extends State<TaxesPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // متغيرات عامة
//   int _currentPage = 0; // 0: لوحة السنة، 1: الفواتير، 2: صندوق 3%، 3: صندوق 14%
//   bool _isLoading = false;
//   String _searchQuery = '';
//   int _selectedYear = DateTime.now().year;
//   bool _isMounted = false;

//   // بيانات الفواتير
//   List<Map<String, dynamic>> _allInvoices = [];
//   List<Map<String, dynamic>> _filteredInvoices = [];
//   List<Map<String, dynamic>> _3PercentTaxInvoices = [];
//   List<Map<String, dynamic>> _14PercentTaxInvoices = [];

//   // بيانات الضرائب
//   List<Map<String, dynamic>> _taxes3Percent = [];
//   List<Map<String, dynamic>> _taxes14Percent = [];

//   // بيانات الخصومات
//   List<Map<String, dynamic>> _taxDeductions = [];

//   // فلتر السنوات
//   List<int> _availableYears = [];

//   // إحصائيات السنة
//   double _yearTotalInvoicesAmount = 0.0;
//   double _yearTotalBalance = 0.0;
//   double _yearTotal3PercentTax = 0.0;
//   double _yearTotal14PercentTax = 0.0;
//   double _yearTotalTaxes = 0.0;
//   double _yearTotalDeductions = 0.0;
//   double _yearTotalTaxesAfterDeductions = 0.0;

//   // متغيرات لعرض التفاصيل
//   Map<String, dynamic>? _selectedTaxRecord;
//   List<Map<String, dynamic>> _taxRecordInvoices = [];

//   // متغيرات للتحكم في التحميل المتقطع (Pagination)
//   final int _invoicesPerPage = 20;
//   DocumentSnapshot? _lastInvoiceDocument;
//   bool _hasMoreInvoices = true;
//   bool _isLoadingMore = false;

//   // متغيرات جديدة للأشهر
//   List<Map<String, dynamic>> _monthlyTaxData = [];
//   int _selectedMonthIndex = -1; // -1 يعني لا يوجد شهر محدد
//   List<Map<String, dynamic>> _monthInvoices = [];

//   // Completer للتحكم في العمليات غير المتزامنة
//   Completer<void>? _dataLoadingCompleter;

//   @override
//   void initState() {
//     super.initState();
//     _isMounted = true;
//     _initializeYears();
//     _loadDashboardData();
//   }

//   @override
//   void dispose() {
//     _isMounted = false;
//     if (_dataLoadingCompleter != null && !_dataLoadingCompleter!.isCompleted) {
//       _dataLoadingCompleter!.complete(null);
//     }
//     // _dataLoadingCompleter?.completeError('Disposed');
//     super.dispose();
//   }

//   // ================================
//   // دالة مساعدة لـ setState الآمن
//   // ================================
//   void _safeSetState(VoidCallback callback) {
//     if (_isMounted) {
//       setState(callback);
//     }
//   }

//   // ================================
//   // تهيئة قائمة السنوات
//   // ================================
//   void _initializeYears() {
//     if (!_isMounted) return;
//     final currentYear = DateTime.now().year;
//     _availableYears = List.generate(5, (index) => currentYear - 2 + index);
//     _selectedYear = currentYear;
//   }

//   // ================================
//   // تحميل بيانات لوحة السنة
//   // ================================
//   Future<void> _loadDashboardData() async {
//     if (!_isMounted) return;

//     _dataLoadingCompleter = Completer();

//     _safeSetState(() {
//       _isLoading = true;
//     });

//     try {
//       if (_currentPage == 0) {
//         await _loadInvoices();
//         await _loadTaxes();
//         await _loadTaxDeductions();
//         await _calculateYearStatistics();
//       } else if (_currentPage == 1) {
//         await _loadInvoices();
//       } else if (_currentPage == 2 || _currentPage == 3) {
//         await _loadInvoices();
//         await _loadTaxes();
//       }

//       if (!_isMounted) return;

//       _dataLoadingCompleter?.complete();
//     } catch (e) {
//       if (_isMounted) {
//         _showError('خطأ في تحميل البيانات: $e');
//       }
//       _dataLoadingCompleter?.completeError(e);
//     } finally {
//       if (_isMounted) {
//         _safeSetState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   // ================================
//   // تحميل جميع الفواتير
//   // ================================
//   Future<void> _loadInvoices({bool loadMore = false}) async {
//     if (!_isMounted) return;

//     if (_currentPage == 1 && loadMore) {
//       if (!_hasMoreInvoices || _isLoadingMore) return;
//       _safeSetState(() => _isLoadingMore = true);
//     } else if (!loadMore) {
//       _safeSetState(() {
//         _isLoading = true;
//         _allInvoices = [];
//         _lastInvoiceDocument = null;
//         _hasMoreInvoices = true;
//       });
//     }

//     try {
//       Query<Map<String, dynamic>> query = _firestore
//           .collection('invoices')
//           .orderBy('createdAt', descending: true)
//           .limit(_invoicesPerPage);

//       if (_lastInvoiceDocument != null) {
//         query = query.startAfterDocument(_lastInvoiceDocument!);
//       }

//       final invoicesSnapshot = await query.get();

//       final List<Map<String, dynamic>> newInvoices = [];

//       for (final doc in invoicesSnapshot.docs) {
//         if (!_isMounted) return;

//         final data = doc.data();

//         // تحويل البيانات بأمان مع القيم الافتراضية
//         final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
//         final tax3PercentDate = (data['tax3PercentDate'] as Timestamp?)
//             ?.toDate();
//         final tax14PercentDate = (data['tax14PercentDate'] as Timestamp?)
//             ?.toDate();
//         final taxDate = (data['taxDate'] as Timestamp?)?.toDate();

//         newInvoices.add({
//           'id': doc.id,
//           'name': (data['name'] as String?) ?? 'فاتورة بدون اسم',
//           'companyName': (data['companyName'] as String?) ?? 'شركة غير معروفة',
//           'companyId': (data['companyId'] as String?) ?? '',
//           'totalAmount': ((data['totalAmount'] as num?) ?? 0).toDouble(),
//           'nolonTotal': ((data['nolonTotal'] as num?) ?? 0).toDouble(),
//           'overnightTotal': ((data['overnightTotal'] as num?) ?? 0).toDouble(),
//           'holidayTotal': ((data['holidayTotal'] as num?) ?? 0).toDouble(),
//           'createdAt': createdAt,
//           'taxDate': taxDate,
//           'tax3Percent': ((data['tax3Percent'] as num?) ?? 0).toDouble(),
//           'tax14Percent': ((data['tax14Percent'] as num?) ?? 0).toDouble(),
//           'has3PercentTax': (data['has3PercentTax'] as bool?) ?? false,
//           'has14PercentTax': (data['has14PercentTax'] as bool?) ?? false,
//           'tax3PercentDate': tax3PercentDate,
//           'tax14PercentDate': tax14PercentDate,
//           'tripCount': (data['tripCount'] as int?) ?? 0,
//           'isArchived': (data['isArchived'] as bool?) ?? false,
//         });
//       }

//       if (!_isMounted) return;

//       _safeSetState(() {
//         if (loadMore) {
//           _allInvoices.addAll(newInvoices);
//           _isLoadingMore = false;
//         } else {
//           _allInvoices = newInvoices;
//           _isLoading = false;
//         }

//         if (_currentPage == 1) {
//           _filteredInvoices = _applySearchFilter(
//             _allInvoices
//                 .where((invoice) => !(invoice['isArchived'] ?? false))
//                 .toList(),
//           );
//         }

//         _lastInvoiceDocument = invoicesSnapshot.docs.isNotEmpty
//             ? invoicesSnapshot.docs.last
//             : null;
//         _hasMoreInvoices = newInvoices.length == _invoicesPerPage;
//       });

//       // فصل الفواتير حسب نوع الضريبة
//       _separateTaxInvoices();
//     } catch (e) {
//       if (_isMounted) {
//         _safeSetState(() {
//           if (loadMore) {
//             _isLoadingMore = false;
//           } else {
//             _isLoading = false;
//           }
//         });
//         _showError('خطأ في تحميل الفواتير: $e');
//       }
//     }
//   }

//   // ================================
//   // فصل الفواتير حسب نوع الضريبة
//   // ================================
//   void _separateTaxInvoices() {
//     if (!_isMounted) return;

//     _safeSetState(() {
//       // فواتير 3% للسنة المحددة
//       _3PercentTaxInvoices = _allInvoices.where((invoice) {
//         if (invoice['has3PercentTax'] != true) return false;

//         DateTime? dateToCheck;

//         // أولاً: تاريخ الضريبة 3%
//         dateToCheck = invoice['tax3PercentDate'] as DateTime?;

//         // ثانياً: تاريخ الإنشاء
//         dateToCheck ??= invoice['createdAt'] as DateTime?;

//         return dateToCheck != null && dateToCheck.year == _selectedYear;
//       }).toList();

//       // فواتير 14% للسنة المحددة
//       _14PercentTaxInvoices = _allInvoices.where((invoice) {
//         if (invoice['has14PercentTax'] != true) return false;

//         DateTime? dateToCheck;

//         // أولاً: تاريخ الضريبة 14%
//         dateToCheck = invoice['tax14PercentDate'] as DateTime?;

//         // ثانياً: تاريخ الإنشاء
//         dateToCheck ??= invoice['createdAt'] as DateTime?;

//         return dateToCheck != null && dateToCheck.year == _selectedYear;
//       }).toList();
//     });

//     // تحضير بيانات الأشهر
//     _prepareMonthlyData();
//   }

//   // ================================
//   // تحضير بيانات الأشهر
//   // ================================
//   void _prepareMonthlyData() {
//     if (!_isMounted) return;

//     List<Map<String, dynamic>> invoices = [];

//     if (_currentPage == 2) {
//       invoices = _3PercentTaxInvoices;
//     } else if (_currentPage == 3) {
//       invoices = _14PercentTaxInvoices;
//     }

//     // تجميع الفواتير حسب الشهر
//     Map<int, List<Map<String, dynamic>>> monthlyInvoices = {};

//     for (var invoice in invoices) {
//       DateTime? invoiceDate = invoice['taxDate'] ?? invoice['createdAt'];
//       if (invoiceDate != null) {
//         int month = invoiceDate.month;
//         monthlyInvoices.putIfAbsent(month, () => []);
//         monthlyInvoices[month]!.add(invoice);
//       }
//     }

//     // تحويل إلى قائمة من بيانات الأشهر
//     List<Map<String, dynamic>> monthlyData = [];

//     for (int month = 1; month <= 12; month++) {
//       if (monthlyInvoices.containsKey(month)) {
//         List<Map<String, dynamic>> monthInvoices = monthlyInvoices[month]!;
//         double totalAmount = 0;
//         double totalTax = 0;

//         for (var invoice in monthInvoices) {
//           totalAmount += invoice['totalAmount'];
//           totalTax += _currentPage == 2
//               ? invoice['tax3Percent']
//               : invoice['tax14Percent'];
//         }

//         monthlyData.add({
//           'monthNumber': month,
//           'monthName': _getMonthName(month),
//           'invoiceCount': monthInvoices.length,
//           'totalAmount': totalAmount,
//           'totalTax': totalTax,
//           'invoices': monthInvoices,
//         });
//       } else {
//         monthlyData.add({
//           'monthNumber': month,
//           'monthName': _getMonthName(month),
//           'invoiceCount': 0,
//           'totalAmount': 0.0,
//           'totalTax': 0.0,
//           'invoices': [],
//         });
//       }
//     }

//     if (!_isMounted) return;

//     _safeSetState(() {
//       _monthlyTaxData = monthlyData;
//     });
//   }

//   // ================================
//   // الحصول على اسم الشهر
//   // ================================
//   String _getMonthName(int month) {
//     switch (month) {
//       case 1:
//         return 'يناير';
//       case 2:
//         return 'فبراير';
//       case 3:
//         return 'مارس';
//       case 4:
//         return 'أبريل';
//       case 5:
//         return 'مايو';
//       case 6:
//         return 'يونيو';
//       case 7:
//         return 'يوليو';
//       case 8:
//         return 'أغسطس';
//       case 9:
//         return 'سبتمبر';
//       case 10:
//         return 'أكتوبر';
//       case 11:
//         return 'نوفمبر';
//       case 12:
//         return 'ديسمبر';
//       default:
//         return '';
//     }
//   }

//   // ================================
//   // تحميل بيانات الضرائب
//   // ================================
//   Future<void> _loadTaxes() async {
//     try {
//       // تحميل ضرائب 3%
//       QuerySnapshot tax3Snapshot = await _firestore
//           .collection('taxes')
//           .where('taxType', isEqualTo: '3%')
//           .where('year', isEqualTo: _selectedYear)
//           .get();

//       final List<Map<String, dynamic>> tax3List = [];
//       for (final doc in tax3Snapshot.docs) {
//         if (!_isMounted) return;
//         final data = doc.data() as Map<String, dynamic>;
//         tax3List.add({
//           'id': doc.id,
//           'taxType': data['taxType'] ?? '3%',
//           'year': data['year'] ?? _selectedYear,
//           'totalInvoices': data['totalInvoices'] ?? 0,
//           'totalAmountBeforeTax': ((data['totalAmountBeforeTax'] as num?) ?? 0)
//               .toDouble(),
//           'totalTaxAmount': ((data['totalTaxAmount'] as num?) ?? 0).toDouble(),
//           'totalAmountAfterTax': ((data['totalAmountAfterTax'] as num?) ?? 0)
//               .toDouble(),
//           'invoiceIds': data['invoiceIds'] ?? [],
//           'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
//         });
//       }

//       // تحميل ضرائب 14%
//       QuerySnapshot tax14Snapshot = await _firestore
//           .collection('taxes')
//           .where('taxType', isEqualTo: '14%')
//           .where('year', isEqualTo: _selectedYear)
//           .get();

//       final List<Map<String, dynamic>> tax14List = [];
//       for (final doc in tax14Snapshot.docs) {
//         if (!_isMounted) return;
//         final data = doc.data() as Map<String, dynamic>;
//         tax14List.add({
//           'id': doc.id,
//           'taxType': data['taxType'] ?? '14%',
//           'year': data['year'] ?? _selectedYear,
//           'totalInvoices': data['totalInvoices'] ?? 0,
//           'totalAmountBeforeTax': ((data['totalAmountBeforeTax'] as num?) ?? 0)
//               .toDouble(),
//           'totalTaxAmount': ((data['totalTaxAmount'] as num?) ?? 0).toDouble(),
//           'totalAmountAfterTax': ((data['totalAmountAfterTax'] as num?) ?? 0)
//               .toDouble(),
//           'invoiceIds': data['invoiceIds'] ?? [],
//           'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
//         });
//       }

//       if (!_isMounted) return;

//       _safeSetState(() {
//         _taxes3Percent = tax3List;
//         _taxes14Percent = tax14List;
//       });
//     } catch (e) {
//       if (_isMounted) {
//         _showError('خطأ في تحميل بيانات الضرائب: $e');
//       }
//     }
//   }

//   // ================================
//   // تحميل بيانات الخصومات الضريبية
//   // ================================
//   Future<void> _loadTaxDeductions() async {
//     try {
//       QuerySnapshot<Map<String, dynamic>> deductionsSnapshot = await _firestore
//           .collection('tax_deductions')
//           .where('year', isEqualTo: _selectedYear)
//           .orderBy('date', descending: true)
//           .get();

//       final List<Map<String, dynamic>> deductionsList = [];
//       for (final doc in deductionsSnapshot.docs) {
//         if (!_isMounted) return;
//         final data = doc.data();
//         deductionsList.add({
//           'id': doc.id,
//           'date': (data['date'] as Timestamp?)?.toDate(),
//           'amount': ((data['amount'] as num?) ?? 0).toDouble(),
//           'description': (data['description'] as String?) ?? 'لا توجد ملاحظات',
//           'year': data['year'] ?? _selectedYear,
//         });
//       }

//       if (!_isMounted) return;

//       _safeSetState(() {
//         _taxDeductions = deductionsList;
//       });
//     } catch (e) {
//       if (_isMounted) {
//         _showError('خطأ في تحميل بيانات الخصومات: $e');
//       }
//     }
//   }

//   // ================================
//   // حساب إحصائيات السنة
//   // ================================
//   Future<void> _calculateYearStatistics() async {
//     // إجمالي فواتير السنة
//     double totalInvoicesAmount = 0.0;
//     for (var invoice in _allInvoices) {
//       final createdAt = invoice['createdAt'] as DateTime?;
//       if (createdAt != null && createdAt.year == _selectedYear) {
//         totalInvoicesAmount += invoice['totalAmount'];
//       }
//     }

//     // إجمالي رصيد الفواتير (الفواتير غير المفعلة للضرائب)
//     double totalBalance = 0.0;
//     for (var invoice in _allInvoices) {
//       final createdAt = invoice['createdAt'] as DateTime?;
//       if (createdAt != null &&
//           createdAt.year == _selectedYear &&
//           invoice['has3PercentTax'] != true &&
//           invoice['has14PercentTax'] != true) {
//         totalBalance += invoice['totalAmount'];
//       }
//     }

//     // إجمالي ضرائب 3%
//     double total3PercentTax = 0.0;
//     for (var invoice in _3PercentTaxInvoices) {
//       total3PercentTax += invoice['tax3Percent'];
//     }

//     // إجمالي ضرائب 14%
//     double total14PercentTax = 0.0;
//     for (var invoice in _14PercentTaxInvoices) {
//       total14PercentTax += invoice['tax14Percent'];
//     }

//     // إجمالي الضرائب
//     double totalTaxes = total3PercentTax + total14PercentTax;

//     // إجمالي الخصومات
//     double totalDeductions = 0.0;
//     for (var deduction in _taxDeductions) {
//       totalDeductions += deduction['amount'];
//     }

//     // إجمالي الضرائب بعد الخصم
//     double totalTaxesAfterDeductions = totalTaxes - totalDeductions;

//     if (!_isMounted) return;

//     _safeSetState(() {
//       _yearTotalInvoicesAmount = totalInvoicesAmount;
//       _yearTotalBalance = totalBalance;
//       _yearTotal3PercentTax = total3PercentTax;
//       _yearTotal14PercentTax = total14PercentTax;
//       _yearTotalTaxes = totalTaxes;
//       _yearTotalDeductions = totalDeductions;
//       _yearTotalTaxesAfterDeductions = totalTaxesAfterDeductions;
//     });
//   }

//   // ================================
//   // إضافة خصم ضريبي جديد
//   // ================================
//   Future<void> _addTaxDeduction() async {
//     final TextEditingController amountController = TextEditingController();
//     final TextEditingController descriptionController = TextEditingController();
//     DateTime? selectedDate = DateTime.now();

//     await showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: const Text('إضافة خصم ضريبي'),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // اختيار التاريخ
//                     ListTile(
//                       leading: const Icon(Icons.calendar_today),
//                       title: const Text('تاريخ الخصم'),
//                       subtitle: Text(
//                         selectedDate != null
//                             ? DateFormat('yyyy/MM/dd').format(selectedDate!)
//                             : 'لم يتم اختيار تاريخ',
//                       ),
//                       onTap: () async {
//                         final pickedDate = await showDatePicker(
//                           context: context,
//                           initialDate: DateTime.now(),
//                           firstDate: DateTime(2000),
//                           lastDate: DateTime(2100),
//                         );
//                         if (pickedDate != null) {
//                           setState(() {
//                             selectedDate = pickedDate;
//                           });
//                         }
//                       },
//                     ),

//                     const SizedBox(height: 16),

//                     // مبلغ الخصم
//                     TextFormField(
//                       controller: amountController,
//                       decoration: const InputDecoration(
//                         labelText: 'مبلغ الخصم',
//                         prefixIcon: Icon(Icons.attach_money),
//                         border: OutlineInputBorder(),
//                       ),
//                       keyboardType: TextInputType.number,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'الرجاء إدخال المبلغ';
//                         }
//                         if (double.tryParse(value) == null) {
//                           return 'الرجاء إدخال رقم صحيح';
//                         }
//                         return null;
//                       },
//                     ),

//                     const SizedBox(height: 16),

//                     // الملاحظات
//                     TextFormField(
//                       controller: descriptionController,
//                       decoration: const InputDecoration(
//                         labelText: 'ملاحظات (اختياري)',
//                         prefixIcon: Icon(Icons.note),
//                         border: OutlineInputBorder(),
//                       ),
//                       maxLines: 3,
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('إلغاء'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () async {
//                     if (amountController.text.isEmpty) {
//                       _showError('الرجاء إدخال مبلغ الخصم');
//                       return;
//                     }

//                     final amount = double.tryParse(amountController.text);
//                     if (amount == null || amount <= 0) {
//                       _showError('الرجاء إدخال مبلغ صحيح');
//                       return;
//                     }

//                     try {
//                       await _firestore.collection('tax_deductions').add({
//                         'date': Timestamp.fromDate(
//                           selectedDate ?? DateTime.now(),
//                         ),
//                         'amount': amount,
//                         'description': descriptionController.text.isNotEmpty
//                             ? descriptionController.text
//                             : 'لا توجد ملاحظات',
//                         'year': _selectedYear,
//                         'createdAt': Timestamp.now(),
//                       });

//                       Navigator.pop(context);
//                       _showSuccess('تم إضافة الخصم بنجاح');

//                       // إعادة تحميل البيانات
//                       if (_isMounted) {
//                         await _loadTaxDeductions();
//                         await _calculateYearStatistics();
//                       }
//                     } catch (e) {
//                       _showError('خطأ في إضافة الخصم: $e');
//                     }
//                   },
//                   child: const Text('حفظ'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   // ================================
//   // دالة التصفية المحلية
//   // ================================
//   List<Map<String, dynamic>> _applySearchFilter(
//     List<Map<String, dynamic>> invoices,
//   ) {
//     if (_searchQuery.isEmpty) return invoices;
//     return invoices
//         .where(
//           (invoice) =>
//               invoice['companyName'].toLowerCase().contains(
//                 _searchQuery.toLowerCase(),
//               ) ||
//               invoice['name'].toLowerCase().contains(
//                 _searchQuery.toLowerCase(),
//               ),
//         )
//         .toList();
//   }

//   // ================================
//   // نقل فاتورة إلى كلا الضرائب وأرشفتها مع حفظ تلقائي
//   // ================================
//   Future<void> _moveToBothTaxBoxes(Map<String, dynamic> invoice) async {
//     if (_currentPage == 1) {
//       final selectedDate = await _showDatePickerDialog();
//       if (selectedDate == null) return;

//       final totalAmount = invoice['totalAmount'];
//       final tax3Amount = totalAmount * 0.03;
//       final tax14Amount = totalAmount * 0.14;
//       final selectedYear = selectedDate.year;

//       try {
//         // تحديث الفاتورة وإضافة أرشفة لكلا الضرائب
//         await _firestore.collection('invoices').doc(invoice['id']).update({
//           'taxDate': Timestamp.fromDate(selectedDate),
//           'tax3Percent': tax3Amount,
//           'tax14Percent': tax14Amount,
//           'has3PercentTax': true,
//           'has14PercentTax': true,
//           'tax3PercentDate': Timestamp.now(),
//           'tax14PercentDate': Timestamp.now(),
//           'isArchived': true,
//         });

//         // تحديث الفاتورة محلياً
//         if (!_isMounted) return;

//         _safeSetState(() {
//           final index = _allInvoices.indexWhere(
//             (inv) => inv['id'] == invoice['id'],
//           );
//           if (index != -1) {
//             _allInvoices[index] = {
//               ..._allInvoices[index],
//               'taxDate': selectedDate,
//               'tax3Percent': tax3Amount,
//               'tax14Percent': tax14Amount,
//               'has3PercentTax': true,
//               'has14PercentTax': true,
//               'tax3PercentDate': DateTime.now(),
//               'tax14PercentDate': DateTime.now(),
//               'isArchived': true,
//             };
//           }

//           // إعادة فلترة الفواتير
//           _filteredInvoices = _applySearchFilter(
//             _allInvoices.where((inv) => !(inv['isArchived'] ?? false)).toList(),
//           );

//           _separateTaxInvoices();
//         });

//         // حفظ تلقائي للسجلات الضريبية
//         if (_isMounted) {
//           await _autoSaveTaxRecords(selectedYear);
//         }

//         _showSuccess(
//           'تم نقل الفاتورة إلى كلا صندوقي الضرائب وأرشفتها وحفظ السجلات تلقائياً',
//         );
//       } catch (e) {
//         _showError('خطأ في نقل الفاتورة: $e');
//       }
//     }
//   }

//   // ================================
//   // حفظ تلقائي للسجلات الضريبية
//   // ================================
//   Future<void> _autoSaveTaxRecords(int year) async {
//     try {
//       // حفظ سجل 3% للسنة المحددة
//       await _saveTaxRecordForYear('3%', year);

//       // حفظ سجل 14% للسنة المحددة
//       await _saveTaxRecordForYear('14%', year);

//       // إعادة تحميل بيانات الضرائب
//       if (_isMounted) {
//         await _loadTaxes();
//       }
//     } catch (e) {
//       if (_isMounted) {
//         _showError('خطأ في الحفظ التلقائي للسجلات: $e');
//       }
//     }
//   }

//   // ================================
//   // حفظ سجل ضريبي لسنة محددة
//   // ================================
//   Future<void> _saveTaxRecordForYear(String taxType, int year) async {
//     try {
//       // الحصول على الفواتير المناسبة للسنة ونوع الضريبة
//       List<Map<String, dynamic>> yearInvoices;

//       if (taxType == '3%') {
//         yearInvoices = _3PercentTaxInvoices
//             .where((invoice) => _getInvoiceYear(invoice, taxType) == year)
//             .toList();
//       } else {
//         yearInvoices = _14PercentTaxInvoices
//             .where((invoice) => _getInvoiceYear(invoice, taxType) == year)
//             .toList();
//       }

//       if (yearInvoices.isEmpty) {
//         print('لا توجد فواتير $taxType لسنة $year');
//         return;
//       }

//       // حساب الإجماليات
//       double totalBeforeTax = 0;
//       double totalTaxAmount = 0;
//       List<String> invoiceIds = [];

//       for (var invoice in yearInvoices) {
//         totalBeforeTax += invoice['totalAmount'];
//         totalTaxAmount += taxType == '3%'
//             ? invoice['tax3Percent']
//             : invoice['tax14Percent'];
//         invoiceIds.add(invoice['id']);
//       }

//       final totalAfterTax = totalBeforeTax - totalTaxAmount;

//       // البحث عن سجل موجود لنفس السنة ونوع الضريبة
//       final existingRecord = await _findExistingTaxRecord(taxType, year);

//       if (existingRecord != null) {
//         // تحديث السجل الحالي
//         await _firestore.collection('taxes').doc(existingRecord['id']).update({
//           'totalInvoices': yearInvoices.length,
//           'totalAmountBeforeTax': totalBeforeTax,
//           'totalTaxAmount': totalTaxAmount,
//           'totalAmountAfterTax': totalAfterTax,
//           'invoiceIds': invoiceIds,
//           'updatedAt': Timestamp.now(),
//         });
//         print('تم تحديث سجل $taxType لسنة $year');
//       } else {
//         // إنشاء سجل جديد
//         await _firestore.collection('taxes').add({
//           'taxType': taxType,
//           'year': year,
//           'totalInvoices': yearInvoices.length,
//           'totalAmountBeforeTax': totalBeforeTax,
//           'totalTaxAmount': totalTaxAmount,
//           'totalAmountAfterTax': totalAfterTax,
//           'invoiceIds': invoiceIds,
//           'createdAt': Timestamp.now(),
//         });
//         print('تم إنشاء سجل جديد $taxType لسنة $year');
//       }
//     } catch (e) {
//       print('خطأ في حفظ سجل $taxType لسنة $year: $e');
//       rethrow;
//     }
//   }

//   // ================================
//   // الحصول على سنة الفاتورة بناءً على نوع الضريبة
//   // ================================
//   int _getInvoiceYear(Map<String, dynamic> invoice, String taxType) {
//     // أولوية لـ taxDate
//     final taxDate = invoice['taxDate'] as DateTime?;
//     if (taxDate != null) {
//       return taxDate.year;
//     }

//     // إذا لم يكن هناك taxDate، استخدم تاريخ الضريبة المحدد
//     if (taxType == '3%') {
//       final tax3Date = invoice['tax3PercentDate'] as DateTime?;
//       if (tax3Date != null) return tax3Date.year;
//     } else {
//       final tax14Date = invoice['tax14PercentDate'] as DateTime?;
//       if (tax14Date != null) return tax14Date.year;
//     }

//     // أخيراً، تاريخ الإنشاء
//     final createdAt = invoice['createdAt'] as DateTime?;
//     return createdAt?.year ?? DateTime.now().year;
//   }

//   // ================================
//   // البحث عن سجل ضريبي موجود
//   // ================================
//   Future<Map<String, dynamic>?> _findExistingTaxRecord(
//     String taxType,
//     int year,
//   ) async {
//     try {
//       final querySnapshot = await _firestore
//           .collection('taxes')
//           .where('taxType', isEqualTo: taxType)
//           .where('year', isEqualTo: year)
//           .limit(1)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         final doc = querySnapshot.docs.first;
//         final data = doc.data();
//         return {'id': doc.id, ...data};
//       }
//       return null;
//     } catch (e) {
//       print('خطأ في البحث عن سجل ضريبي: $e');
//       return null;
//     }
//   }

//   // ================================
//   // تحميل الفواتير المرتبطة بسجل ضريبي
//   // ================================
//   Future<void> _loadTaxRecordInvoices(Map<String, dynamic> taxRecord) async {
//     final invoiceIds = List<String>.from(taxRecord['invoiceIds'] ?? []);

//     if (!_isMounted) return;

//     _safeSetState(() {
//       _taxRecordInvoices = [];
//       _isLoading = true;
//     });

//     try {
//       final List<Map<String, dynamic>> invoicesList = [];

//       for (final invoiceId in invoiceIds) {
//         if (!_isMounted) return;

//         final doc = await _firestore
//             .collection('invoices')
//             .doc(invoiceId)
//             .get();

//         if (doc.exists) {
//           final data = doc.data() as Map<String, dynamic>;
//           final taxAmount = taxRecord['taxType'] == '3%'
//               ? ((data['tax3Percent'] as num?) ?? 0).toDouble()
//               : ((data['tax14Percent'] as num?) ?? 0).toDouble();

//           invoicesList.add({
//             'id': doc.id,
//             'name': (data['name'] as String?) ?? 'فاتورة بدون اسم',
//             'companyName':
//                 (data['companyName'] as String?) ?? 'شركة غير معروفة',
//             'totalAmount': ((data['totalAmount'] as num?) ?? 0).toDouble(),
//             'taxAmount': taxAmount,
//             'amountAfterTax':
//                 ((data['totalAmount'] as num?) ?? 0).toDouble() - taxAmount,
//             'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
//           });
//         }
//       }

//       if (!_isMounted) return;

//       _safeSetState(() {
//         _taxRecordInvoices = invoicesList;
//         _isLoading = false;
//       });
//     } catch (e) {
//       if (_isMounted) {
//         _safeSetState(() => _isLoading = false);
//         _showError('خطأ في تحميل تفاصيل السجل الضريبي: $e');
//       }
//     }
//   }

//   // ================================
//   // عرض نافذة اختيار التاريخ
//   // ================================
//   Future<DateTime?> _showDatePickerDialog() async {
//     final selectedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//       builder: (context, child) {
//         return Theme(
//           data: ThemeData.light().copyWith(
//             primaryColor: const Color(0xFF3498DB),
//             colorScheme: const ColorScheme.light(primary: Color(0xFF3498DB)),
//             buttonTheme: const ButtonThemeData(
//               textTheme: ButtonTextTheme.primary,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (selectedDate != null) {
//       // تحديث السنة المحددة عند اختيار تاريخ
//       if (!_isMounted) return selectedDate;

//       _safeSetState(() {
//         _selectedYear = selectedDate.year;
//       });

//       // إعادة تحميل البيانات للفلترة حسب السنة الجديدة
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_isMounted) {
//           _separateTaxInvoices();
//         }
//       });
//     }

//     return selectedDate;
//   }

//   // ================================
//   // عرض تفاصيل سجل ضريبي
//   // ================================
//   Future<void> _showTaxRecordDetails(Map<String, dynamic> taxRecord) async {
//     if (!_isMounted) return;

//     _safeSetState(() {
//       _selectedTaxRecord = taxRecord;
//       _selectedMonthIndex = -1;
//       _monthInvoices = [];
//     });

//     await _loadTaxRecordInvoices(taxRecord);
//     if (_isMounted) {
//       _showTaxDetailsSheet(taxRecord);
//     }
//   }

//   // ================================
//   // عرض تفاصيل السجل الضريبي
//   // ================================
//   void _showTaxDetailsSheet(Map<String, dynamic> taxRecord) {
//     final taxType = taxRecord['taxType'];
//     final year = taxRecord['year'];
//     final totalInvoices = taxRecord['totalInvoices'];
//     final totalBeforeTax = taxRecord['totalAmountBeforeTax'];
//     final taxAmount = taxRecord['totalTaxAmount'];
//     final totalAfterTax = taxRecord['totalAmountAfterTax'];

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) {
//         return Container(
//           height: MediaQuery.of(context).size.height * 0.9,
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(20),
//               topRight: Radius.circular(20),
//             ),
//           ),
//           child: Column(
//             children: [
//               // رأس البطاقة
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: taxType == '3%'
//                       ? const Color(0xFFE3F2FD)
//                       : const Color(0xFFE8F5E9),
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(20),
//                     topRight: Radius.circular(20),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(
//                       Icons.receipt_long,
//                       color: taxType == '3%'
//                           ? const Color(0xFF1976D2)
//                           : const Color(0xFF2E7D32),
//                       size: 30,
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'سجل ضريبة $taxType - سنة $year',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: taxType == '3%'
//                                   ? const Color(0xFF1976D2)
//                                   : const Color(0xFF2E7D32),
//                             ),
//                           ),
//                           Text(
//                             'إنشئ في: ${_formatDate(taxRecord['createdAt'])}',
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close, color: Colors.grey),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//               ),

//               // الإجماليات
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: _buildTaxSummaryCard(
//                   taxType: taxType,
//                   totalInvoices: totalInvoices,
//                   totalBeforeTax: totalBeforeTax,
//                   taxAmount: taxAmount,
//                   totalAfterTax: totalAfterTax,
//                 ),
//               ),

//               // عنوان الفواتير
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       'الفواتير المضمنة:',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       '(${_taxRecordInvoices.length}) فاتورة',
//                       style: const TextStyle(color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               ),

//               // قائمة الفواتير
//               Expanded(
//                 child: _isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : _taxRecordInvoices.isEmpty
//                     ? Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               Icons.receipt,
//                               size: 60,
//                               color: Colors.grey[400],
//                             ),
//                             const SizedBox(height: 16),
//                             const Text(
//                               'لا توجد فواتير في هذا السجل',
//                               style: TextStyle(
//                                 color: Colors.grey,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     : ListView.builder(
//                         padding: const EdgeInsets.all(16),
//                         itemCount: _taxRecordInvoices.length,
//                         itemBuilder: (context, index) {
//                           final invoice = _taxRecordInvoices[index];
//                           return _buildTaxInvoiceCard(invoice, taxType, index);
//                         },
//                       ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   // ================================
//   // بناء بطاقة ملخص الضريبة
//   // ================================
//   Widget _buildTaxSummaryCard({
//     required String taxType,
//     required int totalInvoices,
//     required double totalBeforeTax,
//     required double taxAmount,
//     required double totalAfterTax,
//   }) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // عنوان البطاقة
//             Text(
//               'إحصائيات ضريبة $taxType',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: taxType == '3%' ? Colors.blue[800] : Colors.green[800],
//               ),
//             ),
//             const SizedBox(height: 20),

//             // عدد الفواتير
//             _buildSummaryItem(
//               icon: Icons.receipt,
//               label: 'عدد الفواتير',
//               value: '$totalInvoices',
//               color: const Color(0xFF3498DB),
//             ),

//             const SizedBox(height: 16),

//             // إجمالي قبل الضريبة
//             _buildSummaryItem(
//               icon: Icons.attach_money,
//               label: 'الإجمالي قبل الضريبة',
//               value: _formatCurrency(totalBeforeTax),
//               color: Colors.blue[700]!,
//             ),

//             const SizedBox(height: 16),

//             // قيمة الضريبة
//             _buildSummaryItem(
//               icon: taxType == '3%'
//                   ? Icons.account_balance_wallet
//                   : Icons.account_balance,
//               label: 'قيمة الضريبة $taxType',
//               value: _formatCurrency(taxAmount),
//               color: taxType == '3%' ? Colors.blue[800]! : Colors.green[800]!,
//             ),

//             const SizedBox(height: 16),

//             // الإجمالي بعد الضريبة
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.red[50],
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.red[100]!),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.money_off, color: Colors.red[700], size: 24),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'الإجمالي بعد خصم الضريبة',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.red[700],
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           _formatCurrency(totalAfterTax),
//                           style: const TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.red,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSummaryItem({
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 22),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: const TextStyle(fontSize: 14, color: Colors.grey),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: color,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ================================
//   // بناء بطاقة الفاتورة في تفاصيل الضريبة
//   // ================================
//   Widget _buildTaxInvoiceCard(
//     Map<String, dynamic> invoice,
//     String taxType,
//     int index,
//   ) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // رأس البطاقة
//             Row(
//               children: [
//                 Container(
//                   width: 36,
//                   height: 36,
//                   decoration: BoxDecoration(
//                     color: taxType == '3%' ? Colors.blue[50] : Colors.green[50],
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Center(
//                     child: Text(
//                       '${index + 1}',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: taxType == '3%'
//                             ? Colors.blue[800]
//                             : Colors.green[800],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         invoice['name'],
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       Text(
//                         invoice['companyName'],
//                         style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             // تفاصيل المبلغ
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'سعر الفاتورة',
//                       style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       _formatCurrency(invoice['totalAmount']),
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blue,
//                       ),
//                     ),
//                   ],
//                 ),

//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       'ضريبة $taxType',
//                       style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       _formatCurrency(invoice['taxAmount']),
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: taxType == '3%'
//                             ? Colors.blue[800]
//                             : Colors.green[800],
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),

//             const SizedBox(height: 12),

//             // الإجمالي بعد الضريبة
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.red[50],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'الإجمالي بعد الضريبة',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.red[700],
//                     ),
//                   ),
//                   Text(
//                     _formatCurrency(invoice['amountAfterTax']),
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.red,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 12),

//             // تاريخ الفاتورة
//             Text(
//               'تاريخ الفاتورة: ${_formatDate(invoice['createdAt'])}',
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ================================
//   // دوال مساعدة
//   // ================================
//   void _showError(String message) {
//     if (!_isMounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   void _showSuccess(String message) {
//     if (!_isMounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   String _formatDate(DateTime? date) {
//     if (date == null) return '-';
//     return DateFormat('dd/MM/yyyy').format(date);
//   }

//   String _formatCurrency(double amount) {
//     return '${amount.toStringAsFixed(2)} ج';
//   }

//   void _changePage(int page) {
//     if (!_isMounted) return;

//     _safeSetState(() {
//       _currentPage = page;
//       _selectedTaxRecord = null;
//       _taxRecordInvoices.clear();
//       _selectedMonthIndex = -1;
//       _monthInvoices = [];
//     });

//     // تحميل البيانات الخاصة بالصفحة
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_isMounted) {
//         _loadDashboardData();
//       }
//     });
//   }

//   void _onYearChanged(int? value) {
//     if (value != null) {
//       if (!_isMounted) return;

//       _safeSetState(() {
//         _selectedYear = value;
//         _selectedTaxRecord = null;
//         _taxRecordInvoices.clear();
//         _selectedMonthIndex = -1;
//         _monthInvoices = [];
//       });

//       // إعادة تحميل البيانات حسب السنة الجديدة
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (_isMounted) {
//           _loadDashboardData();
//         }
//       });
//     }
//   }

//   // ================================
//   // وظائف جديدة للأشهر
//   // ================================
//   // ================================
//   // وظائف جديدة للأشهر
//   // ================================
//   void _selectMonth(int monthIndex) {
//     if (!_isMounted) return;

//     // تحقق أن monthIndex ضمن النطاق الصحيح
//     if (monthIndex < 0 || monthIndex >= _monthlyTaxData.length) {
//       return;
//     }

//     // تحقق أن بيانات الشهر موجودة
//     if (_monthlyTaxData.isEmpty) {
//       return;
//     }

//     final monthData = _monthlyTaxData[monthIndex];

//     _safeSetState(() {
//       if (_selectedMonthIndex == monthIndex) {
//         // إذا كان نفس الشهر، إلغاء التحديد
//         _selectedMonthIndex = -1;
//         _monthInvoices = [];
//       } else {
//         _selectedMonthIndex = monthIndex;

//         // تأكد أن invoices موجود في البيانات
//         if (monthData.containsKey('invoices')) {
//           _monthInvoices = List<Map<String, dynamic>>.from(
//             monthData['invoices'] ?? [],
//           );
//         } else {
//           _monthInvoices = [];
//         }
//       }
//     });
//   }

//   // ================================
//   // حذف خصم ضريبي
//   // ================================
//   Future<void> _deleteDeduction(String id) async {
//     bool confirm =
//         await showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('تأكيد الحذف'),
//             content: const Text('هل أنت متأكد من حذف هذا الخصم؟'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context, false),
//                 child: const Text('إلغاء'),
//               ),
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context, true),
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//                 child: const Text('حذف'),
//               ),
//             ],
//           ),
//         ) ??
//         false;

//     if (confirm) {
//       try {
//         await _firestore.collection('tax_deductions').doc(id).delete();
//         _showSuccess('تم حذف الخصم بنجاح');

//         // إعادة تحميل البيانات
//         if (_isMounted) {
//           await _loadTaxDeductions();
//           await _calculateYearStatistics();
//         }
//       } catch (e) {
//         _showError('خطأ في حذف الخصم: $e');
//       }
//     }
//   }

//   // ================================
//   // بناء واجهة
//   // ================================
//   @override
//   Widget build(BuildContext context) {
//     if (!_isMounted) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6F8),
//       body: Column(
//         children: [
//           _buildCustomAppBar(),
//           _buildYearFilter(),
//           _buildNavigationTabs(),
//           Expanded(
//             child: _isLoading && _currentPage != 1
//                 ? const Center(child: CircularProgressIndicator())
//                 : _buildCurrentPage(),
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
//               _currentPage == 0 ? Icons.dashboard : Icons.request_quote,
//               color: Colors.white,
//               size: 28,
//             ),
//             const SizedBox(width: 8),
//             const Expanded(
//               child: Center(
//                 child: Text(
//                   'إدارة الضرائب',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//             IconButton(
//               icon: const Icon(Icons.refresh, color: Colors.white),
//               onPressed: _loadDashboardData,
//               tooltip: 'تحديث البيانات',
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildYearFilter() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       color: Colors.white,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Text(
//             'فلتر حسب السنة:',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2C3E50),
//             ),
//           ),
//           DropdownButton<int>(
//             value: _selectedYear,
//             onChanged: _onYearChanged,
//             items: _availableYears
//                 .map(
//                   (year) =>
//                       DropdownMenuItem(value: year, child: Text('سنة $year')),
//                 )
//                 .toList(),
//             style: const TextStyle(
//               color: Color(0xFF3498DB),
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavigationTabs() {
//     return Container(
//       color: Colors.white,
//       child: Row(
//         children: [
//           _buildNavigationTab(0, Icons.dashboard, 'ضرائب السنة'),
//           _buildNavigationTab(1, Icons.receipt, 'جميع الفواتير'),
//           _buildNavigationTab(2, Icons.account_balance_wallet, 'صندوق 3%'),
//           _buildNavigationTab(3, Icons.account_balance, 'صندوق 14%'),
//         ],
//       ),
//     );
//   }

//   Widget _buildNavigationTab(int page, IconData icon, String title) {
//     final isActive = _currentPage == page;
//     return Expanded(
//       child: InkWell(
//         onTap: () => _changePage(page),
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             color: isActive
//                 ? (page == 2
//                       ? Colors.blue
//                       : page == 3
//                       ? Colors.green
//                       : const Color(0xFF3498DB))
//                 : Colors.white,
//             border: Border(
//               bottom: BorderSide(
//                 color: isActive
//                     ? (page == 2
//                           ? Colors.blue
//                           : page == 3
//                           ? Colors.green
//                           : const Color(0xFF3498DB))
//                     : Colors.grey[300]!,
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
//                   fontSize: 11,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCurrentPage() {
//     switch (_currentPage) {
//       case 0:
//         return _buildYearDashboard();
//       case 1:
//         return _buildInvoicesSection();
//       case 2:
//         return _build3PercentTaxSection();
//       case 3:
//         return _build14PercentTaxSection();
//       default:
//         return _buildYearDashboard();
//     }
//   }

//   // ================================
//   // بناء صفحة لوحة السنة
//   // ================================
//   Widget _buildYearDashboard() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // بطاقة إحصائيات السنة
//           _buildYearStatisticsCard(),

//           const SizedBox(height: 24),

//           // بطاقة الضرائب والخصومات
//           _buildTaxesAndDeductionsCard(),

//           const SizedBox(height: 24),

//           // قائمة الخصومات
//           _buildDeductionsList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildYearStatisticsCard() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // عنوان البطاقة
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.bar_chart, color: Color(0xFF3498DB), size: 24),
//                 const SizedBox(width: 8),
//                 Text(
//                   'إحصائيات سنة $_selectedYear',
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF2C3E50),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 24),

//             // إجمالي فواتير السنة
//             _buildStatisticRow(
//               icon: Icons.receipt,
//               label: 'إجمالي فواتير السنة',
//               value: _formatCurrency(_yearTotalInvoicesAmount),
//               color: Colors.blue,
//             ),

//             const SizedBox(height: 16),

//             // إجمالي ضرائب 3%
//             _buildStatisticRow(
//               icon: Icons.account_balance_wallet,
//               label: 'إجمالي ضرائب 3%',
//               value: _formatCurrency(_yearTotal3PercentTax),
//               color: Colors.blue[800]!,
//             ),

//             const SizedBox(height: 16),

//             // إجمالي ضرائب 14%
//             _buildStatisticRow(
//               icon: Icons.account_balance,
//               label: 'إجمالي ضرائب 14%',
//               value: _formatCurrency(_yearTotal14PercentTax),
//               color: Colors.green[800]!,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatisticRow({
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 28),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: const TextStyle(fontSize: 14, color: Colors.grey),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: color,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTaxesAndDeductionsCard() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // إجمالي الضرائب
//             _buildTaxSummaryItem(
//               label: ' إجمالي الضرائب',
//               value: _formatCurrency(_yearTotalTaxes),
//               icon: Icons.attach_money,
//               color: Colors.purple,
//             ),

//             const SizedBox(height: 16),

//             // إجمالي الخصومات
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildTaxSummaryItem(
//                     label: 'إجمالي الخصومات',
//                     value: _formatCurrency(_yearTotalDeductions),
//                     icon: Icons.money_off,
//                     color: Colors.red,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 ElevatedButton.icon(
//                   onPressed: _addTaxDeduction,
//                   icon: const Icon(Icons.add, size: 18),
//                   label: const Text('خصم'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             // إجمالي الضرائب بعد الخصم
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.orange[50],
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.orange[100]!),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.calculate, color: Colors.orange[800], size: 32),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'إجمالي الضرائب بعد الخصم',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.orange[800],
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           _formatCurrency(_yearTotalTaxesAfterDeductions),
//                           style: const TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.deepOrange,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTaxSummaryItem({
//     required String label,
//     required String value,
//     required IconData icon,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.2)),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 24),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label, style: TextStyle(fontSize: 14, color: color)),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: color,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDeductionsList() {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // عنوان القائمة
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'سجل الخصومات',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF2C3E50),
//                   ),
//                 ),
//                 Text(
//                   '(${_taxDeductions.length}) خصم',
//                   style: const TextStyle(fontSize: 14, color: Colors.grey),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             // قائمة الخصومات
//             if (_taxDeductions.isEmpty)
//               Center(
//                 child: Column(
//                   children: [
//                     Icon(Icons.money_off, size: 60, color: Colors.grey[400]),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'لا توجد خصومات',
//                       style: TextStyle(fontSize: 16, color: Colors.grey),
//                     ),
//                   ],
//                 ),
//               )
//             else
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: _taxDeductions.length,
//                 itemBuilder: (context, index) {
//                   final deduction = _taxDeductions[index];
//                   return _buildDeductionCard(deduction, index);
//                 },
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDeductionCard(Map<String, dynamic> deduction, int index) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ListTile(
//         leading: Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: Colors.red[50],
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Center(
//             child: Text(
//               '${index + 1}',
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.red,
//               ),
//             ),
//           ),
//         ),
//         title: Text(
//           _formatCurrency(deduction['amount']),
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//             color: Colors.red,
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               deduction['description'],
//               style: const TextStyle(fontSize: 13),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               _formatDate(deduction['date']),
//               style: const TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//           ],
//         ),
//         trailing: IconButton(
//           icon: const Icon(Icons.delete, color: Colors.grey),
//           onPressed: () async {
//             await _deleteDeduction(deduction['id']);
//           },
//         ),
//       ),
//     );
//   }

//   // ================================
//   // بناء صفحة جميع الفواتير
//   // ================================
//   Widget _buildInvoicesSection() {
//     return Column(
//       children: [
//         // شريط البحث
//         _buildSearchBar(),

//         // تبويب السجل
//         _buildArchiveTab(),

//         Expanded(
//           child: _filteredInvoices.isEmpty && !_isLoading
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.receipt, size: 80, color: Colors.grey[400]),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'لا توجد فواتير',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : NotificationListener<ScrollNotification>(
//                   onNotification: (ScrollNotification scrollInfo) {
//                     if (!_isLoadingMore &&
//                         _hasMoreInvoices &&
//                         scrollInfo.metrics.pixels ==
//                             scrollInfo.metrics.maxScrollExtent) {
//                       _loadInvoices(loadMore: true);
//                       return true;
//                     }
//                     return false;
//                   },
//                   child: ListView.builder(
//                     padding: const EdgeInsets.all(8),
//                     itemCount:
//                         _filteredInvoices.length + (_hasMoreInvoices ? 1 : 0),
//                     itemBuilder: (context, index) {
//                       if (index == _filteredInvoices.length) {
//                         return _buildLoadMoreIndicator();
//                       }
//                       final invoice = _filteredInvoices[index];
//                       return _buildInvoiceCard(invoice, index);
//                     },
//                   ),
//                 ),
//         ),
//       ],
//     );
//   }

//   Widget _buildArchiveTab() {
//     return Container(
//       color: Colors.white,
//       child: Row(
//         children: [
//           Expanded(
//             child: TextButton(
//               onPressed: () {
//                 if (!_isMounted) return;

//                 _safeSetState(() {
//                   _filteredInvoices = _applySearchFilter(
//                     _allInvoices
//                         .where((invoice) => !(invoice['isArchived'] ?? false))
//                         .toList(),
//                   );
//                 });
//               },
//               child: Text(
//                 'الفواتير النشطة',
//                 style: TextStyle(
//                   color: Colors.blue,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           Expanded(
//             child: TextButton(
//               onPressed: () {
//                 if (!_isMounted) return;

//                 _safeSetState(() {
//                   _filteredInvoices = _applySearchFilter(
//                     _allInvoices
//                         .where((invoice) => (invoice['isArchived'] ?? false))
//                         .toList(),
//                   );
//                 });
//               },
//               child: Text(
//                 'السجل',
//                 style: TextStyle(
//                   color: Colors.grey,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildLoadMoreIndicator() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Center(
//         child: _isLoadingMore
//             ? const CircularProgressIndicator()
//             : ElevatedButton(
//                 onPressed: () => _loadInvoices(loadMore: true),
//                 child: const Text('تحميل المزيد'),
//               ),
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
//                   if (!_isMounted) return;

//                   _safeSetState(() {
//                     _searchQuery = value;
//                     _filteredInvoices = _applySearchFilter(
//                       _allInvoices
//                           .where((invoice) => !(invoice['isArchived'] ?? false))
//                           .toList(),
//                     );
//                   });
//                 },
//                 decoration: const InputDecoration(
//                   hintText: 'ابحث عن فاتورة أو شركة...',
//                   border: InputBorder.none,
//                   hintStyle: TextStyle(color: Colors.grey),
//                 ),
//               ),
//             ),
//             if (_searchQuery.isNotEmpty)
//               GestureDetector(
//                 onTap: () {
//                   if (!_isMounted) return;

//                   _safeSetState(() {
//                     _searchQuery = '';
//                     _filteredInvoices = _applySearchFilter(
//                       _allInvoices
//                           .where((invoice) => !(invoice['isArchived'] ?? false))
//                           .toList(),
//                     );
//                   });
//                 },
//                 child: const Icon(Icons.clear, size: 18, color: Colors.grey),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInvoiceCard(Map<String, dynamic> invoice, int index) {
//     final has3Percent = invoice['has3PercentTax'] == true;
//     final has14Percent = invoice['has14PercentTax'] == true;
//     final isArchived = invoice['isArchived'] == true;
//     final taxDate = invoice['taxDate'] as DateTime?;

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ExpansionTile(
//         leading: Container(
//           width: 40,
//           height: 40,
//           decoration: BoxDecoration(
//             color: isArchived
//                 ? Colors.grey[200]
//                 : has3Percent || has14Percent
//                 ? (has14Percent ? Colors.green[50] : Colors.blue[50])
//                 : const Color(0xFFF4F6F8),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Center(
//             child: Text(
//               '${index + 1}',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: isArchived
//                     ? Colors.grey[600]
//                     : has3Percent || has14Percent
//                     ? (has14Percent ? Colors.green[800] : Colors.blue[800])
//                     : const Color(0xFF2C3E50),
//               ),
//             ),
//           ),
//         ),
//         title: Text(
//           invoice['name'],
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//             color: isArchived ? Colors.grey[600] : const Color(0xFF2C3E50),
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               invoice['companyName'],
//               style: TextStyle(
//                 fontSize: 14,
//                 color: isArchived ? Colors.grey[500] : Colors.grey[700],
//               ),
//             ),
//             if (taxDate != null)
//               Text(
//                 'تاريخ الضريبة: ${_formatDate(taxDate)}',
//                 style: const TextStyle(
//                   fontSize: 12,
//                   color: Colors.blue,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//           ],
//         ),
//         trailing: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               _formatCurrency(invoice['totalAmount']),
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//                 color: isArchived ? Colors.grey[600] : const Color(0xFF2E7D32),
//               ),
//             ),
//             const SizedBox(height: 3),
//             if (has3Percent || has14Percent)
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                 decoration: BoxDecoration(
//                   color: isArchived
//                       ? Colors.grey[100]
//                       : has14Percent
//                       ? Colors.green[50]
//                       : Colors.blue[50],
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                     color: isArchived
//                         ? Colors.grey[300]!
//                         : has14Percent
//                         ? Colors.green[100]!
//                         : Colors.blue[100]!,
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     if (has3Percent)
//                       Text(
//                         '3%  ',
//                         style: TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue[800],
//                         ),
//                       ),
//                     if (has3Percent && has14Percent)
//                       const Text(' /  ', style: TextStyle(fontSize: 10)),
//                     if (has14Percent)
//                       Text(
//                         ' 14%',
//                         style: TextStyle(
//                           fontSize: 10,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green[800],
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             child: Column(
//               children: [
//                 // زر نقل إلى الضرائب
//                 if (!isArchived && (!has3Percent || !has14Percent))
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed: () => _moveToBothTaxBoxes(invoice),
//                       icon: const Icon(Icons.account_balance_wallet, size: 20),
//                       label: const Text('نقل إلى الضرائب'),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF3498DB),
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                       ),
//                     ),
//                   ),

//                 const SizedBox(height: 12),

//                 // إحصائيات الفاتورة
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF8F9FA),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.grey[200]!),
//                   ),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'عدد الرحلات:',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: isArchived
//                                   ? Colors.grey[600]
//                                   : Colors.black,
//                             ),
//                           ),
//                           Text(
//                             '${invoice['tripCount']}',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: isArchived
//                                   ? Colors.grey[600]
//                                   : const Color(0xFF3498DB),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'إجمالي النولون:',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: isArchived
//                                   ? Colors.grey[600]
//                                   : Colors.green,
//                             ),
//                           ),
//                           Text(
//                             _formatCurrency(invoice['nolonTotal']),
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: isArchived
//                                   ? Colors.grey[600]
//                                   : Colors.green,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'إجمالي المبيت:',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: isArchived
//                                   ? Colors.grey[600]
//                                   : Colors.orange,
//                             ),
//                           ),
//                           Text(
//                             _formatCurrency(invoice['overnightTotal']),
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: isArchived
//                                   ? Colors.grey[600]
//                                   : Colors.orange,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'إجمالي العطلة:',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: isArchived ? Colors.grey[600] : Colors.red,
//                             ),
//                           ),
//                           Text(
//                             _formatCurrency(invoice['holidayTotal']),
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: isArchived ? Colors.grey[600] : Colors.red,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ================================
//   // بناء صفحة ضريبة 3%
//   // ================================
//   Widget _build3PercentTaxSection() {
//     return _buildTaxSection(
//       taxType: '3%',
//       invoices: _3PercentTaxInvoices,
//       taxRecords: _taxes3Percent,
//       color: Colors.blue,
//     );
//   }

//   // ================================
//   // بناء صفحة ضريبة 14%
//   // ================================
//   Widget _build14PercentTaxSection() {
//     return _buildTaxSection(
//       taxType: '14%',
//       invoices: _14PercentTaxInvoices,
//       taxRecords: _taxes14Percent,
//       color: Colors.green,
//     );
//   }

//   Widget _buildTaxSection({
//     required String taxType,
//     required List<Map<String, dynamic>> invoices,
//     required List<Map<String, dynamic>> taxRecords,
//     required Color color,
//   }) {
//     // حساب الإجماليات للسنة
//     double totalBeforeTax = 0;
//     double totalTaxAmount = 0;
//     for (var invoice in invoices) {
//       totalBeforeTax += invoice['totalAmount'];
//       totalTaxAmount += taxType == '3%'
//           ? invoice['tax3Percent']
//           : invoice['tax14Percent'];
//     }
//     final totalAfterTax = totalBeforeTax - totalTaxAmount;

//     return Column(
//       children: [
//         // إحصائيات السنة
//         Padding(
//           padding: const EdgeInsets.all(16),
//           child: _buildTaxBoxSummaryCard(
//             taxType: taxType,
//             year: _selectedYear,
//             totalInvoices: invoices.length,
//             totalBeforeTax: totalBeforeTax,
//             totalTaxAmount: totalTaxAmount,
//             totalAfterTax: totalAfterTax,
//             color: color,
//           ),
//         ),

//         // تبويب السجلات والأشهر
//         Container(
//           color: Colors.white,
//           child: Row(
//             children: [
//               Expanded(
//                 child: TextButton(
//                   onPressed: () {
//                     if (!_isMounted) return;

//                     _safeSetState(() {
//                       _selectedTaxRecord = null;
//                       _taxRecordInvoices.clear();
//                       _selectedMonthIndex = -1;
//                       _monthInvoices = [];
//                     });
//                   },
//                   child: Text(
//                     'السجلات الضريبية',
//                     style: TextStyle(
//                       color:
//                           _selectedTaxRecord == null &&
//                               _selectedMonthIndex == -1
//                           ? color
//                           : Colors.grey,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: TextButton(
//                   onPressed: () {
//                     if (!_isMounted) return;

//                     _safeSetState(() {
//                       _selectedTaxRecord = null;
//                       _taxRecordInvoices.clear();
//                       _selectedMonthIndex = -1;
//                       _monthInvoices = [];
//                     });
//                   },
//                   child: Text(
//                     'الضرائب الشهرية',
//                     style: TextStyle(
//                       color: _selectedMonthIndex != -1 ? color : Colors.grey,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // قائمة الأشهر أو الفواتير
//         Expanded(
//           child: _selectedMonthIndex != -1
//               ? _buildMonthInvoicesList()
//               : _buildTaxContent(invoices, taxRecords, taxType, color),
//         ),
//       ],
//     );
//   }

//   Widget _buildTaxContent(
//     List<Map<String, dynamic>> invoices,
//     List<Map<String, dynamic>> taxRecords,
//     String taxType,
//     Color color,
//   ) {
//     if (_selectedTaxRecord != null) {
//       return _buildTaxRecordDetails();
//     }

//     // عرض قائمة الأشهر بدلاً من السجلات
//     return _buildMonthsGrid();
//   }

//   Widget _buildMonthsGrid() {
//     return GridView.builder(
//       padding: const EdgeInsets.all(16),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 6,
//         crossAxisSpacing: 2,
//         mainAxisSpacing: 2,
//         childAspectRatio: 1.8,
//       ),
//       itemCount: _monthlyTaxData.length,
//       itemBuilder: (context, index) {
//         final monthData = _monthlyTaxData[index];
//         final isSelected = index == _selectedMonthIndex;

//         return _buildMonthCard(monthData, index, isSelected);
//       },
//     );
//   }

//   Widget _buildMonthCard(
//     Map<String, dynamic> monthData,
//     int index,
//     bool isSelected,
//   ) {
//     final monthName = monthData['monthName'];
//     final invoiceCount = monthData['invoiceCount'];
//     final totalTax = monthData['totalTax'];
//     final color = _currentPage == 2 ? Colors.blue : Colors.green;

//     return GestureDetector(
//       onTap: () => _selectMonth(index),
//       child: Container(
//         height: 30,
//         decoration: BoxDecoration(
//           color: isSelected ? color.withOpacity(0.1) : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? color : Colors.grey[300]!,
//             width: isSelected ? 2 : 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               monthName,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: isSelected ? color : Colors.black,
//               ),
//             ),
//             const SizedBox(height: 8),
//             if (invoiceCount > 0)
//               Column(
//                 children: [
//                   Text(
//                     '$invoiceCount فاتورة',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: isSelected ? color : Colors.grey[600],
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     _formatCurrency(totalTax),
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: isSelected ? color : Colors.green,
//                     ),
//                   ),
//                 ],
//               )
//             else
//               Text(
//                 'لا توجد فواتير',
//                 style: TextStyle(fontSize: 12, color: Colors.grey[400]),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMonthInvoicesList() {
//     if (_monthInvoices.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.receipt, size: 80, color: Colors.grey[400]),
//             const SizedBox(height: 16),
//             const Text(
//               'لا توجد فواتير في هذا الشهر',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return Column(
//       children: [
//         // عنوان الشهر
//         Container(
//           padding: const EdgeInsets.all(16),
//           color: _currentPage == 2 ? Colors.blue[50] : Colors.green[50],
//           child: Row(
//             children: [
//               Icon(
//                 Icons.calendar_month,
//                 color: _currentPage == 2 ? Colors.blue : Colors.green,
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 _monthlyTaxData[_selectedMonthIndex]['monthName'],
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: _currentPage == 2 ? Colors.blue : Colors.green,
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 '(${_monthInvoices.length}) فاتورة',
//                 style: const TextStyle(fontSize: 14, color: Colors.grey),
//               ),
//             ],
//           ),
//         ),

//         // قائمة الفواتير
//         Expanded(
//           child: ListView.builder(
//             padding: const EdgeInsets.all(16),
//             itemCount: _monthInvoices.length,
//             itemBuilder: (context, index) {
//               final invoice = _monthInvoices[index];
//               return _buildMonthInvoiceCard(invoice, index);
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMonthInvoiceCard(Map<String, dynamic> invoice, int index) {
//     final taxType = _currentPage == 2 ? '3%' : '14%';
//     final taxAmount = _currentPage == 2
//         ? invoice['tax3Percent']
//         : invoice['tax14Percent'];
//     final amountAfterTax = invoice['totalAmount'] - taxAmount;
//     final invoiceDate = invoice['taxDate'] ?? invoice['createdAt'];

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // اسم الفاتورة
//             Text(
//               invoice['name'],
//               style: const TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF2C3E50),
//               ),
//             ),

//             const SizedBox(height: 8),

//             // التاريخ وسعر الفاتورة
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 // التاريخ على اليسار
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'التاريخ',
//                       style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       _formatDate(invoiceDate),
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blue,
//                       ),
//                     ),
//                   ],
//                 ),

//                 // سعر الفاتورة في الوسط
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       'سعر الفاتورة',
//                       style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       _formatCurrency(invoice['totalAmount']),
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF2E7D32),
//                       ),
//                     ),
//                   ],
//                 ),

//                 // الضرائب على اليمين
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       'ضريبة $taxType',
//                       style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       _formatCurrency(taxAmount),
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: _currentPage == 2 ? Colors.blue : Colors.green,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTaxBoxSummaryCard({
//     required String taxType,
//     required int year,
//     required int totalInvoices,
//     required double totalBeforeTax,
//     required double totalTaxAmount,
//     required double totalAfterTax,
//     required Color color,
//   }) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       color: color.withOpacity(0.05),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             // العنوان
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(
//                   taxType == '3%'
//                       ? Icons.account_balance_wallet
//                       : Icons.account_balance,
//                   color: color,
//                   size: 24,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   'صندوق $taxType - سنة $year',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: color,
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // شبكة الإحصائيات
//             Row(
//               children: [
//                 // عدد الفواتير
//                 Expanded(
//                   child: _buildStatBox(
//                     title: 'عدد الفواتير',
//                     value: '$totalInvoices',
//                     icon: Icons.receipt,
//                     color: const Color(0xFF3498DB),
//                   ),
//                 ),

//                 const SizedBox(width: 12),

//                 // الإجمالي قبل الضريبة
//                 Expanded(
//                   child: _buildStatBox(
//                     title: 'الإجمالي قبل الضريبة',
//                     value: _formatCurrency(totalBeforeTax),
//                     icon: Icons.attach_money,
//                     color: Colors.blue[700]!,
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 12),

//             Row(
//               children: [
//                 // قيمة الضريبة
//                 Expanded(
//                   child: _buildStatBox(
//                     title: 'قيمة الضريبة',
//                     value: _formatCurrency(totalTaxAmount),
//                     icon: Icons.account_balance_wallet,
//                     color: color,
//                   ),
//                 ),

//                 const SizedBox(width: 12),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatBox({
//     required String title,
//     required String value,
//     required IconData icon,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(icon, color: color, size: 18),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   title,
//                   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTaxRecordsList(List<Map<String, dynamic>> records, Color color) {
//     return records.isEmpty
//         ? Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.history, size: 80, color: Colors.grey[400]),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'لا توجد سجلات ضريبية لهذه السنة',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           )
//         : ListView.builder(
//             padding: const EdgeInsets.all(8),
//             itemCount: records.length,
//             itemBuilder: (context, index) {
//               final record = records[index];
//               return _buildTaxRecordCard(record, color, index);
//             },
//           );
//   }

//   Widget _buildTaxRecordCard(
//     Map<String, dynamic> record,
//     Color color,
//     int index,
//   ) {
//     final year = record['year'];
//     final totalInvoices = record['totalInvoices'];
//     final totalBeforeTax = record['totalAmountBeforeTax'];
//     final totalTax = record['totalTaxAmount'];
//     final totalAfterTax = record['totalAmountAfterTax'];

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: ListTile(
//         leading: Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: color.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//             border: Border.all(color: color.withOpacity(0.3)),
//           ),
//           child: Center(
//             child: Text(
//               '${index + 1}',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//           ),
//         ),
//         title: Text(
//           'سنة $year',
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 17,
//             color: color,
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 4),
//             Text(
//               'فاتورة :$totalInvoices   ',
//               style: const TextStyle(fontSize: 13),
//             ),
//           ],
//         ),
//         trailing: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Text(
//               _formatCurrency(totalTax),
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//                 color: Colors.green,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               ' الضريبة',
//               style: TextStyle(fontSize: 11, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//         onTap: () => _showTaxRecordDetails(record),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       ),
//     );
//   }

//   Widget _buildTaxInvoicesList(
//     List<Map<String, dynamic>> invoices,
//     String taxType,
//     Color color,
//   ) {
//     return invoices.isEmpty
//         ? Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.receipt, size: 80, color: Colors.grey[400]),
//                 const SizedBox(height: 16),
//                 Text(
//                   'لا توجد فواتير لسنة $_selectedYear',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           )
//         : ListView.builder(
//             padding: const EdgeInsets.all(8),
//             itemCount: invoices.length,
//             itemBuilder: (context, index) {
//               final invoice = invoices[index];
//               return _buildTaxBoxInvoiceItem(invoice, taxType, color, index);
//             },
//           );
//   }

//   Widget _buildTaxBoxInvoiceItem(
//     Map<String, dynamic> invoice,
//     String taxType,
//     Color color,
//     int index,
//   ) {
//     final taxAmount = taxType == '3%'
//         ? invoice['tax3Percent']
//         : invoice['tax14Percent'];
//     final amountAfterTax = invoice['totalAmount'] - taxAmount;

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // رأس البطاقة
//             Row(
//               children: [
//                 Container(
//                   width: 36,
//                   height: 36,
//                   decoration: BoxDecoration(
//                     color: color.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Center(
//                     child: Text(
//                       '${index + 1}',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: color,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         invoice['name'],
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       Text(
//                         invoice['companyName'],
//                         style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             // سعر الفاتورة والضريبة
//             Row(
//               children: [
//                 // سعر الفاتورة
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'سعر الفاتورة',
//                         style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         _formatCurrency(invoice['totalAmount']),
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // الضريبة
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'ضريبة $taxType',
//                         style: TextStyle(fontSize: 13, color: Colors.grey[600]),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         _formatCurrency(taxAmount),
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: color,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 12),

//             // الإجمالي بعد الضريبة
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.red[50],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'الإجمالي بعد الضريبة',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.red[700],
//                     ),
//                   ),
//                   Text(
//                     _formatCurrency(amountAfterTax),
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.red,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTaxRecordDetails() {
//     if (_selectedTaxRecord == null) return Container();

//     return ListView.builder(
//       padding: const EdgeInsets.all(8),
//       itemCount: _taxRecordInvoices.length,
//       itemBuilder: (context, index) {
//         final invoice = _taxRecordInvoices[index];
//         final taxType = _selectedTaxRecord!['taxType'];
//         final color = taxType == '3%' ? Colors.blue : Colors.green;

//         return _buildTaxBoxInvoiceItem(invoice, taxType, color, index);
//       },
//     );
//   }
// }
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaxesPage extends StatefulWidget {
  const TaxesPage({super.key});

  @override
  State<TaxesPage> createState() => _TaxesPageState();
}

class _TaxesPageState extends State<TaxesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // متغيرات عامة
  int _currentPage = 0; // 0: لوحة السنة، 1: الفواتير، 2: صندوق 3%، 3: صندوق 14%
  bool _isLoading = false;
  String _searchQuery = '';
  int _selectedYear = DateTime.now().year;
  bool _isMounted = false;

  // بيانات الفواتير
  List<Map<String, dynamic>> _allInvoices = [];
  List<Map<String, dynamic>> _filteredInvoices = [];
  List<Map<String, dynamic>> _3PercentTaxInvoices = [];
  List<Map<String, dynamic>> _14PercentTaxInvoices = [];

  // بيانات الضرائب
  List<Map<String, dynamic>> _taxes3Percent = [];
  List<Map<String, dynamic>> _taxes14Percent = [];

  // بيانات الخصومات
  List<Map<String, dynamic>> _taxDeductions = [];

  // فلتر السنوات
  List<int> _availableYears = [];

  // إحصائيات السنة
  double _yearTotalInvoicesAmount = 0.0;
  double _yearTotalBalance = 0.0;
  double _yearTotal3PercentTax = 0.0;
  double _yearTotal14PercentTax = 0.0;
  double _yearTotalTaxes = 0.0;
  double _yearTotalDeductions = 0.0;
  double _yearTotalTaxesAfterDeductions = 0.0;

  // متغيرات لعرض التفاصيل
  Map<String, dynamic>? _selectedTaxRecord;
  List<Map<String, dynamic>> _taxRecordInvoices = [];

  // متغيرات للتحكم في التحميل المتقطع (Pagination)
  final int _invoicesPerPage = 20;
  DocumentSnapshot? _lastInvoiceDocument;
  bool _hasMoreInvoices = true;
  bool _isLoadingMore = false;

  // متغيرات جديدة للأشهر
  List<Map<String, dynamic>> _monthlyTaxData = [];
  int _selectedMonthIndex = -1; // -1 يعني لا يوجد شهر محدد
  List<Map<String, dynamic>> _monthInvoices = [];

  // Completer للتحكم في العمليات غير المتزامنة
  Completer<void>? _dataLoadingCompleter;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _initializeYears();
    _loadDashboardData();
  }

  @override
  void dispose() {
    _isMounted = false;
    if (_dataLoadingCompleter != null && !_dataLoadingCompleter!.isCompleted) {
      _dataLoadingCompleter!.complete(null);
    }
    super.dispose();
  }

  // ================================
  // دالة مساعدة لـ setState الآمن
  // ================================
  void _safeSetState(VoidCallback callback) {
    if (_isMounted) {
      setState(callback);
    }
  }

  // ================================
  // تهيئة قائمة السنوات
  // ================================
  void _initializeYears() {
    if (!_isMounted) return;
    final currentYear = DateTime.now().year;
    _availableYears = List.generate(5, (index) => currentYear - 2 + index);
    _selectedYear = currentYear;
  }

  // ================================
  // تحميل بيانات لوحة السنة
  // ================================
  Future<void> _loadDashboardData() async {
    if (!_isMounted) return;

    _dataLoadingCompleter = Completer();

    _safeSetState(() {
      _isLoading = true;
    });

    try {
      if (_currentPage == 0) {
        await _loadInvoices();
        await _loadTaxes();
        await _loadTaxDeductions();
        await _calculateYearStatistics();
      } else if (_currentPage == 1) {
        await _loadInvoices();
      } else if (_currentPage == 2 || _currentPage == 3) {
        await _loadInvoices();
        await _loadTaxes();
      }

      if (!_isMounted) return;

      _dataLoadingCompleter?.complete();
    } catch (e) {
      if (_isMounted) {
        _showError('خطأ في تحميل البيانات: $e');
      }
      _dataLoadingCompleter?.completeError(e);
    } finally {
      if (_isMounted) {
        _safeSetState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ================================
  // تحميل جميع الفواتير
  // ================================
  Future<void> _loadInvoices({bool loadMore = false}) async {
    if (!_isMounted) return;

    if (_currentPage == 1 && loadMore) {
      if (!_hasMoreInvoices || _isLoadingMore) return;
      _safeSetState(() => _isLoadingMore = true);
    } else if (!loadMore) {
      _safeSetState(() {
        _isLoading = true;
        _allInvoices = [];
        _lastInvoiceDocument = null;
        _hasMoreInvoices = true;
      });
    }

    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('invoices')
          .orderBy('createdAt', descending: true)
          .limit(_invoicesPerPage);

      if (_lastInvoiceDocument != null) {
        query = query.startAfterDocument(_lastInvoiceDocument!);
      }

      final invoicesSnapshot = await query.get();

      final List<Map<String, dynamic>> newInvoices = [];

      for (final doc in invoicesSnapshot.docs) {
        if (!_isMounted) return;

        final data = doc.data();

        // تحويل البيانات بأمان مع القيم الافتراضية
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
        final tax3PercentDate = (data['tax3PercentDate'] as Timestamp?)
            ?.toDate();
        final tax14PercentDate = (data['tax14PercentDate'] as Timestamp?)
            ?.toDate();
        final taxDate = (data['taxDate'] as Timestamp?)?.toDate();

        newInvoices.add({
          'id': doc.id,
          'name': (data['name'] as String?) ?? 'فاتورة بدون اسم',
          'companyName': (data['companyName'] as String?) ?? 'شركة غير معروفة',
          'companyId': (data['companyId'] as String?) ?? '',
          'totalAmount': ((data['totalAmount'] as num?) ?? 0).toDouble(),
          'nolonTotal': ((data['nolonTotal'] as num?) ?? 0).toDouble(),
          'overnightTotal': ((data['overnightTotal'] as num?) ?? 0).toDouble(),
          'holidayTotal': ((data['holidayTotal'] as num?) ?? 0).toDouble(),
          'createdAt': createdAt,
          'taxDate': taxDate,
          'tax3Percent': ((data['tax3Percent'] as num?) ?? 0).toDouble(),
          'tax14Percent': ((data['tax14Percent'] as num?) ?? 0).toDouble(),
          'has3PercentTax': (data['has3PercentTax'] as bool?) ?? false,
          'has14PercentTax': (data['has14PercentTax'] as bool?) ?? false,
          'tax3PercentDate': tax3PercentDate,
          'tax14PercentDate': tax14PercentDate,
          'tripCount': (data['tripCount'] as int?) ?? 0,
          'isArchived': (data['isArchived'] as bool?) ?? false,
        });
      }

      if (!_isMounted) return;

      _safeSetState(() {
        if (loadMore) {
          _allInvoices.addAll(newInvoices);
          _isLoadingMore = false;
        } else {
          _allInvoices = newInvoices;
          _isLoading = false;
        }

        if (_currentPage == 1) {
          _filteredInvoices = _applySearchFilter(
            _allInvoices
                .where((invoice) => !(invoice['isArchived'] ?? false))
                .toList(),
          );
        }

        _lastInvoiceDocument = invoicesSnapshot.docs.isNotEmpty
            ? invoicesSnapshot.docs.last
            : null;
        _hasMoreInvoices = newInvoices.length == _invoicesPerPage;
      });

      // فصل الفواتير حسب نوع الضريبة
      _separateTaxInvoices();
    } catch (e) {
      if (_isMounted) {
        _safeSetState(() {
          if (loadMore) {
            _isLoadingMore = false;
          } else {
            _isLoading = false;
          }
        });
        _showError('خطأ في تحميل الفواتير: $e');
      }
    }
  }

  // ================================
  // فصل الفواتير حسب نوع الضريبة
  // ================================
  void _separateTaxInvoices() {
    if (!_isMounted) return;

    _safeSetState(() {
      // فواتير 3% للسنة المحددة
      _3PercentTaxInvoices = _allInvoices.where((invoice) {
        if (invoice['has3PercentTax'] != true) return false;

        DateTime? dateToCheck;

        // أولاً: تاريخ الضريبة 3%
        dateToCheck = invoice['tax3PercentDate'] as DateTime?;

        // ثانياً: تاريخ الإنشاء
        dateToCheck ??= invoice['createdAt'] as DateTime?;

        return dateToCheck != null && dateToCheck.year == _selectedYear;
      }).toList();

      // فواتير 14% للسنة المحددة
      _14PercentTaxInvoices = _allInvoices.where((invoice) {
        if (invoice['has14PercentTax'] != true) return false;

        DateTime? dateToCheck;

        // أولاً: تاريخ الضريبة 14%
        dateToCheck = invoice['tax14PercentDate'] as DateTime?;

        // ثانياً: تاريخ الإنشاء
        dateToCheck ??= invoice['createdAt'] as DateTime?;

        return dateToCheck != null && dateToCheck.year == _selectedYear;
      }).toList();
    });

    // تحضير بيانات الأشهر
    _prepareMonthlyData();
  }

  // ================================
  // تحضير بيانات الأشهر
  // ================================
  void _prepareMonthlyData() {
    if (!_isMounted) return;

    List<Map<String, dynamic>> invoices = [];

    if (_currentPage == 2) {
      invoices = _3PercentTaxInvoices;
    } else if (_currentPage == 3) {
      invoices = _14PercentTaxInvoices;
    }

    // تجميع الفواتير حسب الشهر
    Map<int, List<Map<String, dynamic>>> monthlyInvoices = {};

    for (var invoice in invoices) {
      DateTime? invoiceDate = invoice['taxDate'] ?? invoice['createdAt'];
      if (invoiceDate != null) {
        int month = invoiceDate.month;
        monthlyInvoices.putIfAbsent(month, () => []);
        monthlyInvoices[month]!.add(invoice);
      }
    }

    // تحويل إلى قائمة من بيانات الأشهر
    List<Map<String, dynamic>> monthlyData = [];

    for (int month = 1; month <= 12; month++) {
      if (monthlyInvoices.containsKey(month)) {
        List<Map<String, dynamic>> monthInvoices = monthlyInvoices[month]!;
        double totalAmount = 0;
        double totalTax = 0;

        for (var invoice in monthInvoices) {
          totalAmount += invoice['totalAmount'];
          totalTax += _currentPage == 2
              ? invoice['tax3Percent']
              : invoice['tax14Percent'];
        }

        monthlyData.add({
          'monthNumber': month,
          'monthName': _getMonthName(month),
          'invoiceCount': monthInvoices.length,
          'totalAmount': totalAmount,
          'totalTax': totalTax,
          'invoices': monthInvoices,
        });
      } else {
        monthlyData.add({
          'monthNumber': month,
          'monthName': _getMonthName(month),
          'invoiceCount': 0,
          'totalAmount': 0.0,
          'totalTax': 0.0,
          'invoices': [],
        });
      }
    }

    if (!_isMounted) return;

    _safeSetState(() {
      _monthlyTaxData = monthlyData;
    });
  }

  // ================================
  // الحصول على اسم الشهر
  // ================================
  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'يناير';
      case 2:
        return 'فبراير';
      case 3:
        return 'مارس';
      case 4:
        return 'أبريل';
      case 5:
        return 'مايو';
      case 6:
        return 'يونيو';
      case 7:
        return 'يوليو';
      case 8:
        return 'أغسطس';
      case 9:
        return 'سبتمبر';
      case 10:
        return 'أكتوبر';
      case 11:
        return 'نوفمبر';
      case 12:
        return 'ديسمبر';
      default:
        return '';
    }
  }

  // ================================
  // تحميل بيانات الضرائب
  // ================================
  Future<void> _loadTaxes() async {
    try {
      // تحميل ضرائب 3%
      QuerySnapshot tax3Snapshot = await _firestore
          .collection('taxes')
          .where('taxType', isEqualTo: '3%')
          .where('year', isEqualTo: _selectedYear)
          .get();

      final List<Map<String, dynamic>> tax3List = [];
      for (final doc in tax3Snapshot.docs) {
        if (!_isMounted) return;
        final data = doc.data() as Map<String, dynamic>;
        tax3List.add({
          'id': doc.id,
          'taxType': data['taxType'] ?? '3%',
          'year': data['year'] ?? _selectedYear,
          'totalInvoices': data['totalInvoices'] ?? 0,
          'totalAmountBeforeTax': ((data['totalAmountBeforeTax'] as num?) ?? 0)
              .toDouble(),
          'totalTaxAmount': ((data['totalTaxAmount'] as num?) ?? 0).toDouble(),
          'totalAmountAfterTax': ((data['totalAmountAfterTax'] as num?) ?? 0)
              .toDouble(),
          'invoiceIds': data['invoiceIds'] ?? [],
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
        });
      }

      // تحميل ضرائب 14%
      QuerySnapshot tax14Snapshot = await _firestore
          .collection('taxes')
          .where('taxType', isEqualTo: '14%')
          .where('year', isEqualTo: _selectedYear)
          .get();

      final List<Map<String, dynamic>> tax14List = [];
      for (final doc in tax14Snapshot.docs) {
        if (!_isMounted) return;
        final data = doc.data() as Map<String, dynamic>;
        tax14List.add({
          'id': doc.id,
          'taxType': data['taxType'] ?? '14%',
          'year': data['year'] ?? _selectedYear,
          'totalInvoices': data['totalInvoices'] ?? 0,
          'totalAmountBeforeTax': ((data['totalAmountBeforeTax'] as num?) ?? 0)
              .toDouble(),
          'totalTaxAmount': ((data['totalTaxAmount'] as num?) ?? 0).toDouble(),
          'totalAmountAfterTax': ((data['totalAmountAfterTax'] as num?) ?? 0)
              .toDouble(),
          'invoiceIds': data['invoiceIds'] ?? [],
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
        });
      }

      if (!_isMounted) return;

      _safeSetState(() {
        _taxes3Percent = tax3List;
        _taxes14Percent = tax14List;
      });
    } catch (e) {
      if (_isMounted) {
        _showError('خطأ في تحميل بيانات الضرائب: $e');
      }
    }
  }

  // ================================
  // تحميل بيانات الخصومات الضريبية
  // ================================
  Future<void> _loadTaxDeductions() async {
    try {
      QuerySnapshot<Map<String, dynamic>> deductionsSnapshot = await _firestore
          .collection('tax_deductions')
          .where('year', isEqualTo: _selectedYear)
          .orderBy('date', descending: true)
          .get();

      final List<Map<String, dynamic>> deductionsList = [];
      for (final doc in deductionsSnapshot.docs) {
        if (!_isMounted) return;
        final data = doc.data();
        deductionsList.add({
          'id': doc.id,
          'date': (data['date'] as Timestamp?)?.toDate(),
          'amount': ((data['amount'] as num?) ?? 0).toDouble(),
          'description': (data['description'] as String?) ?? 'لا توجد ملاحظات',
          'year': data['year'] ?? _selectedYear,
        });
      }

      if (!_isMounted) return;

      _safeSetState(() {
        _taxDeductions = deductionsList;
      });
    } catch (e) {
      if (_isMounted) {
        _showError('خطأ في تحميل بيانات الخصومات: $e');
      }
    }
  }

  // ================================
  // حساب إحصائيات السنة
  // ================================
  Future<void> _calculateYearStatistics() async {
    // إجمالي فواتير السنة
    double totalInvoicesAmount = 0.0;
    for (var invoice in _allInvoices) {
      final createdAt = invoice['createdAt'] as DateTime?;
      if (createdAt != null && createdAt.year == _selectedYear) {
        totalInvoicesAmount += invoice['totalAmount'];
      }
    }

    // إجمالي رصيد الفواتير (الفواتير غير المفعلة للضرائب)
    double totalBalance = 0.0;
    for (var invoice in _allInvoices) {
      final createdAt = invoice['createdAt'] as DateTime?;
      if (createdAt != null &&
          createdAt.year == _selectedYear &&
          invoice['has3PercentTax'] != true &&
          invoice['has14PercentTax'] != true) {
        totalBalance += invoice['totalAmount'];
      }
    }

    // إجمالي ضرائب 3%
    double total3PercentTax = 0.0;
    for (var invoice in _3PercentTaxInvoices) {
      total3PercentTax += invoice['tax3Percent'];
    }

    // إجمالي ضرائب 14%
    double total14PercentTax = 0.0;
    for (var invoice in _14PercentTaxInvoices) {
      total14PercentTax += invoice['tax14Percent'];
    }

    // إجمالي الضرائب
    double totalTaxes = total3PercentTax + total14PercentTax;

    // إجمالي الخصومات
    double totalDeductions = 0.0;
    for (var deduction in _taxDeductions) {
      totalDeductions += deduction['amount'];
    }

    // إجمالي الضرائب بعد الخصم
    double totalTaxesAfterDeductions = totalTaxes - totalDeductions;

    if (!_isMounted) return;

    _safeSetState(() {
      _yearTotalInvoicesAmount = totalInvoicesAmount;
      _yearTotalBalance = totalBalance;
      _yearTotal3PercentTax = total3PercentTax;
      _yearTotal14PercentTax = total14PercentTax;
      _yearTotalTaxes = totalTaxes;
      _yearTotalDeductions = totalDeductions;
      _yearTotalTaxesAfterDeductions = totalTaxesAfterDeductions;
    });
  }

  // ================================
  // إضافة خصم ضريبي جديد
  // ================================
  Future<void> _addTaxDeduction() async {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    DateTime? selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('إضافة خصم ضريبي'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // اختيار التاريخ
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('تاريخ الخصم'),
                      subtitle: Text(
                        selectedDate != null
                            ? DateFormat('yyyy/MM/dd').format(selectedDate!)
                            : 'لم يتم اختيار تاريخ',
                      ),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // مبلغ الخصم
                    TextFormField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'مبلغ الخصم',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال المبلغ';
                        }
                        if (double.tryParse(value) == null) {
                          return 'الرجاء إدخال رقم صحيح';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // الملاحظات
                    TextFormField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات (اختياري)',
                        prefixIcon: Icon(Icons.note),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (amountController.text.isEmpty) {
                      _showError('الرجاء إدخال مبلغ الخصم');
                      return;
                    }

                    final amount = double.tryParse(amountController.text);
                    if (amount == null || amount <= 0) {
                      _showError('الرجاء إدخال مبلغ صحيح');
                      return;
                    }

                    try {
                      await _firestore.collection('tax_deductions').add({
                        'date': Timestamp.fromDate(
                          selectedDate ?? DateTime.now(),
                        ),
                        'amount': amount,
                        'description': descriptionController.text.isNotEmpty
                            ? descriptionController.text
                            : 'لا توجد ملاحظات',
                        'year': _selectedYear,
                        'createdAt': Timestamp.now(),
                      });

                      Navigator.pop(context);
                      _showSuccess('تم إضافة الخصم بنجاح');

                      // إعادة تحميل البيانات
                      if (_isMounted) {
                        await _loadTaxDeductions();
                        await _calculateYearStatistics();
                      }
                    } catch (e) {
                      _showError('خطأ في إضافة الخصم: $e');
                    }
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================================
  // دالة التصفية المحلية
  // ================================
  List<Map<String, dynamic>> _applySearchFilter(
    List<Map<String, dynamic>> invoices,
  ) {
    if (_searchQuery.isEmpty) return invoices;
    return invoices
        .where(
          (invoice) =>
              invoice['companyName'].toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              invoice['name'].toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ),
        )
        .toList();
  }

  // ================================
  // نقل فاتورة إلى كلا الضرائب وأرشفتها مع حفظ تلقائي
  // ================================
  Future<void> _moveToBothTaxBoxes(Map<String, dynamic> invoice) async {
    if (_currentPage == 1) {
      final selectedDate = await _showDatePickerDialog();
      if (selectedDate == null) return;

      final totalAmount = invoice['totalAmount'];
      final tax3Amount = totalAmount * 0.03;
      final tax14Amount = totalAmount * 0.14;
      final selectedYear = selectedDate.year;

      try {
        // تحديث الفاتورة وإضافة أرشفة لكلا الضرائب
        await _firestore.collection('invoices').doc(invoice['id']).update({
          'taxDate': Timestamp.fromDate(selectedDate),
          'tax3Percent': tax3Amount,
          'tax14Percent': tax14Amount,
          'has3PercentTax': true,
          'has14PercentTax': true,
          'tax3PercentDate': Timestamp.now(),
          'tax14PercentDate': Timestamp.now(),
          'isArchived': true,
        });

        // تحديث الفاتورة محلياً
        if (!_isMounted) return;

        _safeSetState(() {
          final index = _allInvoices.indexWhere(
            (inv) => inv['id'] == invoice['id'],
          );
          if (index != -1) {
            _allInvoices[index] = {
              ..._allInvoices[index],
              'taxDate': selectedDate,
              'tax3Percent': tax3Amount,
              'tax14Percent': tax14Amount,
              'has3PercentTax': true,
              'has14PercentTax': true,
              'tax3PercentDate': DateTime.now(),
              'tax14PercentDate': DateTime.now(),
              'isArchived': true,
            };
          }

          // إعادة فلترة الفواتير
          _filteredInvoices = _applySearchFilter(
            _allInvoices.where((inv) => !(inv['isArchived'] ?? false)).toList(),
          );

          _separateTaxInvoices();
        });

        // حفظ تلقائي للسجلات الضريبية
        if (_isMounted) {
          await _autoSaveTaxRecords(selectedYear);
        }

        _showSuccess(
          'تم نقل الفاتورة إلى كلا صندوقي الضرائب وأرشفتها وحفظ السجلات تلقائياً',
        );
      } catch (e) {
        _showError('خطأ في نقل الفاتورة: $e');
      }
    }
  }

  // ================================
  // حفظ تلقائي للسجلات الضريبية
  // ================================
  Future<void> _autoSaveTaxRecords(int year) async {
    try {
      // حفظ سجل 3% للسنة المحددة
      await _saveTaxRecordForYear('3%', year);

      // حفظ سجل 14% للسنة المحددة
      await _saveTaxRecordForYear('14%', year);

      // إعادة تحميل بيانات الضرائب
      if (_isMounted) {
        await _loadTaxes();
      }
    } catch (e) {
      if (_isMounted) {
        _showError('خطأ في الحفظ التلقائي للسجلات: $e');
      }
    }
  }

  // ================================
  // حفظ سجل ضريبي لسنة محددة
  // ================================
  Future<void> _saveTaxRecordForYear(String taxType, int year) async {
    try {
      // الحصول على الفواتير المناسبة للسنة ونوع الضريبة
      List<Map<String, dynamic>> yearInvoices;

      if (taxType == '3%') {
        yearInvoices = _3PercentTaxInvoices
            .where((invoice) => _getInvoiceYear(invoice, taxType) == year)
            .toList();
      } else {
        yearInvoices = _14PercentTaxInvoices
            .where((invoice) => _getInvoiceYear(invoice, taxType) == year)
            .toList();
      }

      if (yearInvoices.isEmpty) {
        return;
      }

      // حساب الإجماليات
      double totalBeforeTax = 0;
      double totalTaxAmount = 0;
      List<String> invoiceIds = [];

      for (var invoice in yearInvoices) {
        totalBeforeTax += invoice['totalAmount'];
        totalTaxAmount += taxType == '3%'
            ? invoice['tax3Percent']
            : invoice['tax14Percent'];
        invoiceIds.add(invoice['id']);
      }

      final totalAfterTax = totalBeforeTax - totalTaxAmount;

      // البحث عن سجل موجود لنفس السنة ونوع الضريبة
      final existingRecord = await _findExistingTaxRecord(taxType, year);

      if (existingRecord != null) {
        // تحديث السجل الحالي
        await _firestore.collection('taxes').doc(existingRecord['id']).update({
          'totalInvoices': yearInvoices.length,
          'totalAmountBeforeTax': totalBeforeTax,
          'totalTaxAmount': totalTaxAmount,
          'totalAmountAfterTax': totalAfterTax,
          'invoiceIds': invoiceIds,
          'updatedAt': Timestamp.now(),
        });
      } else {
        // إنشاء سجل جديد
        await _firestore.collection('taxes').add({
          'taxType': taxType,
          'year': year,
          'totalInvoices': yearInvoices.length,
          'totalAmountBeforeTax': totalBeforeTax,
          'totalTaxAmount': totalTaxAmount,
          'totalAmountAfterTax': totalAfterTax,
          'invoiceIds': invoiceIds,
          'createdAt': Timestamp.now(),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // ================================
  // الحصول على سنة الفاتورة بناءً على نوع الضريبة
  // ================================
  int _getInvoiceYear(Map<String, dynamic> invoice, String taxType) {
    // أولوية لـ taxDate
    final taxDate = invoice['taxDate'] as DateTime?;
    if (taxDate != null) {
      return taxDate.year;
    }

    // إذا لم يكن هناك taxDate، استخدم تاريخ الضريبة المحدد
    if (taxType == '3%') {
      final tax3Date = invoice['tax3PercentDate'] as DateTime?;
      if (tax3Date != null) return tax3Date.year;
    } else {
      final tax14Date = invoice['tax14PercentDate'] as DateTime?;
      if (tax14Date != null) return tax14Date.year;
    }

    // أخيراً، تاريخ الإنشاء
    final createdAt = invoice['createdAt'] as DateTime?;
    return createdAt?.year ?? DateTime.now().year;
  }

  // ================================
  // البحث عن سجل ضريبي موجود
  // ================================
  Future<Map<String, dynamic>?> _findExistingTaxRecord(
    String taxType,
    int year,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('taxes')
          .where('taxType', isEqualTo: taxType)
          .where('year', isEqualTo: year)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        return {'id': doc.id, ...data};
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ================================
  // تحميل الفواتير المرتبطة بسجل ضريبي
  // ================================
  Future<void> _loadTaxRecordInvoices(Map<String, dynamic> taxRecord) async {
    final invoiceIds = List<String>.from(taxRecord['invoiceIds'] ?? []);

    if (!_isMounted) return;

    _safeSetState(() {
      _taxRecordInvoices = [];
      _isLoading = true;
    });

    try {
      final List<Map<String, dynamic>> invoicesList = [];

      for (final invoiceId in invoiceIds) {
        if (!_isMounted) return;

        final doc = await _firestore
            .collection('invoices')
            .doc(invoiceId)
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          final taxAmount = taxRecord['taxType'] == '3%'
              ? ((data['tax3Percent'] as num?) ?? 0).toDouble()
              : ((data['tax14Percent'] as num?) ?? 0).toDouble();

          invoicesList.add({
            'id': doc.id,
            'name': (data['name'] as String?) ?? 'فاتورة بدون اسم',
            'companyName':
                (data['companyName'] as String?) ?? 'شركة غير معروفة',
            'totalAmount': ((data['totalAmount'] as num?) ?? 0).toDouble(),
            'taxAmount': taxAmount,
            'amountAfterTax':
                ((data['totalAmount'] as num?) ?? 0).toDouble() - taxAmount,
            'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
          });
        }
      }

      if (!_isMounted) return;

      _safeSetState(() {
        _taxRecordInvoices = invoicesList;
        _isLoading = false;
      });
    } catch (e) {
      if (_isMounted) {
        _safeSetState(() => _isLoading = false);
        _showError('خطأ في تحميل تفاصيل السجل الضريبي: $e');
      }
    }
  }

  // ================================
  // عرض نافذة اختيار التاريخ
  // ================================
  Future<DateTime?> _showDatePickerDialog() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF3498DB),
            colorScheme: const ColorScheme.light(primary: Color(0xFF3498DB)),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      // تحديث السنة المحددة عند اختيار تاريخ
      if (!_isMounted) return selectedDate;

      _safeSetState(() {
        _selectedYear = selectedDate.year;
      });

      // إعادة تحميل البيانات للفلترة حسب السنة الجديدة
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isMounted) {
          _separateTaxInvoices();
        }
      });
    }

    return selectedDate;
  }

  // ================================
  // عرض تفاصيل سجل ضريبي
  // ================================
  Future<void> _showTaxRecordDetails(Map<String, dynamic> taxRecord) async {
    if (!_isMounted) return;

    _safeSetState(() {
      _selectedTaxRecord = taxRecord;
      _selectedMonthIndex = -1;
      _monthInvoices = [];
    });

    await _loadTaxRecordInvoices(taxRecord);
    if (_isMounted) {
      _showTaxDetailsSheet(taxRecord);
    }
  }

  // ================================
  // عرض تفاصيل السجل الضريبي
  // ================================
  void _showTaxDetailsSheet(Map<String, dynamic> taxRecord) {
    final taxType = taxRecord['taxType'];
    final year = taxRecord['year'];
    final totalInvoices = taxRecord['totalInvoices'];
    final totalBeforeTax = taxRecord['totalAmountBeforeTax'];
    final taxAmount = taxRecord['totalTaxAmount'];
    final totalAfterTax = taxRecord['totalAmountAfterTax'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // رأس البطاقة
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: taxType == '3%'
                      ? const Color(0xFFE3F2FD)
                      : const Color(0xFFE8F5E9),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: taxType == '3%'
                          ? const Color(0xFF1976D2)
                          : const Color(0xFF2E7D32),
                      size: 30,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'سجل ضريبة $taxType - سنة $year',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: taxType == '3%'
                                  ? const Color(0xFF1976D2)
                                  : const Color(0xFF2E7D32),
                            ),
                          ),
                          Text(
                            'إنشئ في: ${_formatDate(taxRecord['createdAt'])}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // الإجماليات
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildTaxSummaryCard(
                  taxType: taxType,
                  totalInvoices: totalInvoices,
                  totalBeforeTax: totalBeforeTax,
                  taxAmount: taxAmount,
                  totalAfterTax: totalAfterTax,
                ),
              ),

              // عنوان الفواتير
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'الفواتير المضمنة:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '(${_taxRecordInvoices.length}) فاتورة',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // قائمة الفواتير
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _taxRecordInvoices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'لا توجد فواتير في هذا السجل',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _taxRecordInvoices.length,
                        itemBuilder: (context, index) {
                          final invoice = _taxRecordInvoices[index];
                          return _buildTaxInvoiceCard(invoice, taxType, index);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================================
  // بناء بطاقة ملخص الضريبة
  // ================================
  Widget _buildTaxSummaryCard({
    required String taxType,
    required int totalInvoices,
    required double totalBeforeTax,
    required double taxAmount,
    required double totalAfterTax,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // عنوان البطاقة
            Text(
              'إحصائيات ضريبة $taxType',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: taxType == '3%' ? Colors.blue[800] : Colors.green[800],
              ),
            ),
            const SizedBox(height: 20),

            // عدد الفواتير
            _buildSummaryItem(
              icon: Icons.receipt,
              label: 'عدد الفواتير',
              value: '$totalInvoices',
              color: const Color(0xFF3498DB),
            ),

            const SizedBox(height: 16),

            // إجمالي قبل الضريبة
            _buildSummaryItem(
              icon: Icons.attach_money,
              label: 'الإجمالي قبل الضريبة',
              value: _formatCurrency(totalBeforeTax),
              color: Colors.blue[700]!,
            ),

            const SizedBox(height: 16),

            // قيمة الضريبة
            _buildSummaryItem(
              icon: taxType == '3%'
                  ? Icons.account_balance_wallet
                  : Icons.account_balance,
              label: 'قيمة الضريبة $taxType',
              value: _formatCurrency(taxAmount),
              color: taxType == '3%' ? Colors.blue[800]! : Colors.green[800]!,
            ),

            const SizedBox(height: 16),

            // الإجمالي بعد الضريبة
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[100]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.money_off, color: Colors.red[700], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الإجمالي بعد خصم الضريبة',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCurrency(totalAfterTax),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================================
  // بناء بطاقة الفاتورة في تفاصيل الضريبة
  // ================================
  Widget _buildTaxInvoiceCard(
    Map<String, dynamic> invoice,
    String taxType,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس البطاقة
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: taxType == '3%' ? Colors.blue[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: taxType == '3%'
                            ? Colors.blue[800]
                            : Colors.green[800],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        invoice['companyName'],
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // تفاصيل المبلغ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'سعر الفاتورة',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(invoice['totalAmount']),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ضريبة $taxType',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(invoice['taxAmount']),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: taxType == '3%'
                            ? Colors.blue[800]
                            : Colors.green[800],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // الإجمالي بعد الضريبة
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الإجمالي بعد الضريبة',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  Text(
                    _formatCurrency(invoice['amountAfterTax']),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // تاريخ الفاتورة
            Text(
              'تاريخ الفاتورة: ${_formatDate(invoice['createdAt'])}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ================================
  // دوال مساعدة
  // ================================
  void _showError(String message) {
    if (!_isMounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!_isMounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} ج';
  }

  void _changePage(int page) {
    if (!_isMounted) return;

    _safeSetState(() {
      _currentPage = page;
      _selectedTaxRecord = null;
      _taxRecordInvoices.clear();
      _selectedMonthIndex = -1;
      _monthInvoices = [];
    });

    // تحميل البيانات الخاصة بالصفحة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isMounted) {
        _loadDashboardData();
      }
    });
  }

  void _onYearChanged(int? value) {
    if (value != null) {
      if (!_isMounted) return;

      _safeSetState(() {
        _selectedYear = value;
        _selectedTaxRecord = null;
        _taxRecordInvoices.clear();
        _selectedMonthIndex = -1;
        _monthInvoices = [];
      });

      // إعادة تحميل البيانات حسب السنة الجديدة
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_isMounted) {
          _loadDashboardData();
        }
      });
    }
  }

  // ================================
  // وظائف جديدة للأشهر
  // ================================
  void _selectMonth(int monthIndex) {
    if (!_isMounted) return;

    // تحقق أن monthIndex ضمن النطاق الصحيح
    if (monthIndex < 0 || monthIndex >= _monthlyTaxData.length) {
      return;
    }

    // تحقق أن بيانات الشهر موجودة
    if (_monthlyTaxData.isEmpty) {
      return;
    }

    final monthData = _monthlyTaxData[monthIndex];

    _safeSetState(() {
      if (_selectedMonthIndex == monthIndex) {
        // إذا كان نفس الشهر، إلغاء التحديد
        _selectedMonthIndex = -1;
        _monthInvoices = [];
      } else {
        _selectedMonthIndex = monthIndex;

        // تأكد أن invoices موجود في البيانات
        if (monthData.containsKey('invoices')) {
          _monthInvoices = List<Map<String, dynamic>>.from(
            monthData['invoices'] ?? [],
          );
        } else {
          _monthInvoices = [];
        }
      }
    });
  }

  // ================================
  // حذف خصم ضريبي
  // ================================
  Future<void> _deleteDeduction(String id) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الخصم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firestore.collection('tax_deductions').doc(id).delete();
        _showSuccess('تم حذف الخصم بنجاح');

        // إعادة تحميل البيانات
        if (_isMounted) {
          await _loadTaxDeductions();
          await _calculateYearStatistics();
        }
      } catch (e) {
        _showError('خطأ في حذف الخصم: $e');
      }
    }
  }

  // ================================
  // بناء واجهة متجاوبة
  // ================================
  @override
  Widget build(BuildContext context) {
    if (!_isMounted) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          bool isTablet = constraints.maxWidth < 1000;

          return Column(
            children: [
              _buildCustomAppBar(isMobile),
              _buildYearFilter(isMobile),
              _buildNavigationTabs(isMobile),
              Expanded(
                child: _isLoading && _currentPage != 1
                    ? const Center(child: CircularProgressIndicator())
                    : _buildCurrentPage(isMobile, isTablet),
              ),
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
            Icon(
              _currentPage == 0 ? Icons.dashboard : Icons.request_quote,
              color: Colors.white,
              size: isMobile ? 24 : 28,
            ),
            SizedBox(width: isMobile ? 8 : 12),
            Expanded(
              child: Center(
                child: Text(
                  'إدارة الضرائب',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
                size: isMobile ? 20 : 24,
              ),
              onPressed: _loadDashboardData,
              tooltip: 'تحديث البيانات',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearFilter(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'فلتر حسب السنة:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
              fontSize: isMobile ? 14 : 16,
            ),
          ),
          DropdownButton<int>(
            value: _selectedYear,
            onChanged: _onYearChanged,
            items: _availableYears
                .map(
                  (year) =>
                      DropdownMenuItem(value: year, child: Text('سنة $year')),
                )
                .toList(),
            style: TextStyle(
              color: const Color(0xFF3498DB),
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTabs(bool isMobile) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _buildNavigationTab(0, Icons.dashboard, 'ضرائب السنة', isMobile),
          _buildNavigationTab(1, Icons.receipt, 'جميع الفواتير', isMobile),
          _buildNavigationTab(
            2,
            Icons.account_balance_wallet,
            'صندوق 3%',
            isMobile,
          ),
          _buildNavigationTab(3, Icons.account_balance, 'صندوق 14%', isMobile),
        ],
      ),
    );
  }

  Widget _buildNavigationTab(
    int page,
    IconData icon,
    String title,
    bool isMobile,
  ) {
    final isActive = _currentPage == page;
    return Expanded(
      child: InkWell(
        onTap: () => _changePage(page),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
          decoration: BoxDecoration(
            color: isActive
                ? (page == 2
                      ? Colors.blue
                      : page == 3
                      ? Colors.green
                      : const Color(0xFF3498DB))
                : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isActive
                    ? (page == 2
                          ? Colors.blue
                          : page == 3
                          ? Colors.green
                          : const Color(0xFF3498DB))
                    : Colors.grey[300]!,
                width: 3,
              ),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.grey,
                size: isMobile ? 18 : 22,
              ),
              SizedBox(height: isMobile ? 2 : 4),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey,
                  fontSize: isMobile ? 10 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPage(bool isMobile, bool isTablet) {
    switch (_currentPage) {
      case 0:
        return _buildYearDashboard(isMobile);
      case 1:
        return _buildInvoicesSection(isMobile);
      case 2:
        return _build3PercentTaxSection(isMobile, isTablet);
      case 3:
        return _build14PercentTaxSection(isMobile, isTablet);
      default:
        return _buildYearDashboard(isMobile);
    }
  }

  // ================================
  // بناء صفحة لوحة السنة
  // ================================
  Widget _buildYearDashboard(bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 1200,
        ),
        child: Column(
          children: [
            // بطاقة إحصائيات السنة
            _buildYearStatisticsCard(isMobile),

            SizedBox(height: isMobile ? 16 : 24),

            // بطاقة الضرائب والخصومات
            _buildTaxesAndDeductionsCard(isMobile),

            SizedBox(height: isMobile ? 16 : 24),

            // قائمة الخصومات
            _buildDeductionsList(isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildYearStatisticsCard(bool isMobile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          children: [
            // عنوان البطاقة
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bar_chart,
                  color: const Color(0xFF3498DB),
                  size: isMobile ? 20 : 24,
                ),
                SizedBox(width: isMobile ? 6 : 8),
                Text(
                  'إحصائيات سنة $_selectedYear',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 16 : 24),

            // إجمالي فواتير السنة
            _buildStatisticRow(
              icon: Icons.receipt,
              label: 'إجمالي فواتير السنة',
              value: _formatCurrency(_yearTotalInvoicesAmount),
              color: Colors.blue,
              isMobile: isMobile,
            ),

            SizedBox(height: isMobile ? 12 : 16),

            // إجمالي ضرائب 3%
            _buildStatisticRow(
              icon: Icons.account_balance_wallet,
              label: 'إجمالي ضرائب 3%',
              value: _formatCurrency(_yearTotal3PercentTax),
              color: Colors.blue[800]!,
              isMobile: isMobile,
            ),

            SizedBox(height: isMobile ? 12 : 16),

            // إجمالي ضرائب 14%
            _buildStatisticRow(
              icon: Icons.account_balance,
              label: 'إجمالي ضرائب 14%',
              value: _formatCurrency(_yearTotal14PercentTax),
              color: Colors.green[800]!,
              isMobile: isMobile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: isMobile ? 24 : 28),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxesAndDeductionsCard(bool isMobile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          children: [
            // إجمالي الضرائب
            _buildTaxSummaryItem(
              label: ' إجمالي الضرائب',
              value: _formatCurrency(_yearTotalTaxes),
              icon: Icons.attach_money,
              color: Colors.purple,
              isMobile: isMobile,
            ),

            SizedBox(height: isMobile ? 12 : 16),

            // إجمالي الخصومات
            Row(
              children: [
                Expanded(
                  child: _buildTaxSummaryItem(
                    label: 'إجمالي الخصومات',
                    value: _formatCurrency(_yearTotalDeductions),
                    icon: Icons.money_off,
                    color: Colors.red,
                    isMobile: isMobile,
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 16),
                ElevatedButton.icon(
                  onPressed: _addTaxDeduction,
                  icon: Icon(Icons.add, size: isMobile ? 16 : 18),
                  label: Text(
                    'خصم',
                    style: TextStyle(fontSize: isMobile ? 12 : 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 16,
                      vertical: isMobile ? 10 : 12,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 12 : 16),

            // إجمالي الضرائب بعد الخصم
            Container(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                border: Border.all(color: Colors.orange[100]!),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calculate,
                    color: Colors.orange[800],
                    size: isMobile ? 28 : 32,
                  ),
                  SizedBox(width: isMobile ? 12 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إجمالي الضرائب بعد الخصم',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[800],
                          ),
                        ),
                        SizedBox(height: isMobile ? 4 : 8),
                        Text(
                          _formatCurrency(_yearTotalTaxesAfterDeductions),
                          style: TextStyle(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxSummaryItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: isMobile ? 20 : 24),
          SizedBox(width: isMobile ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: isMobile ? 12 : 14, color: color),
                ),
                SizedBox(height: isMobile ? 2 : 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeductionsList(bool isMobile) {
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
            // عنوان القائمة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'سجل الخصومات',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                Text(
                  '(${_taxDeductions.length}) خصم',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 12 : 16),

            // قائمة الخصومات
            if (_taxDeductions.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.money_off,
                      size: isMobile ? 50 : 60,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                    Text(
                      'لا توجد خصومات',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _taxDeductions.length,
                itemBuilder: (context, index) {
                  final deduction = _taxDeductions[index];
                  return _buildDeductionCard(deduction, index, isMobile);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeductionCard(
    Map<String, dynamic> deduction,
    int index,
    bool isMobile,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
      ),
      child: ListTile(
        leading: Container(
          width: isMobile ? 36 : 40,
          height: isMobile ? 36 : 40,
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: isMobile ? 14 : 16,
              ),
            ),
          ),
        ),
        title: Text(
          _formatCurrency(deduction['amount']),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 14 : 16,
            color: Colors.red,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              deduction['description'],
              style: TextStyle(fontSize: isMobile ? 11 : 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isMobile ? 2 : 4),
            Text(
              _formatDate(deduction['date']),
              style: TextStyle(
                fontSize: isMobile ? 10 : 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete,
            color: Colors.grey,
            size: isMobile ? 18 : 22,
          ),
          onPressed: () async {
            await _deleteDeduction(deduction['id']);
          },
        ),
      ),
    );
  }

  // ================================
  // بناء صفحة جميع الفواتير
  // ================================
  Widget _buildInvoicesSection(bool isMobile) {
    return Column(
      children: [
        // شريط البحث
        _buildSearchBar(isMobile),

        // تبويب السجل
        _buildArchiveTab(isMobile),

        Expanded(
          child: _filteredInvoices.isEmpty && !_isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt,
                        size: isMobile ? 60 : 80,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      Text(
                        'لا توجد فواتير',
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (!_isLoadingMore &&
                        _hasMoreInvoices &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      _loadInvoices(loadMore: true);
                      return true;
                    }
                    return false;
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.all(isMobile ? 4 : 8),
                    itemCount:
                        _filteredInvoices.length + (_hasMoreInvoices ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _filteredInvoices.length) {
                        return _buildLoadMoreIndicator(isMobile);
                      }
                      final invoice = _filteredInvoices[index];
                      return _buildInvoiceCard(invoice, index, isMobile);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildArchiveTab(bool isMobile) {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {
                if (!_isMounted) return;

                _safeSetState(() {
                  _filteredInvoices = _applySearchFilter(
                    _allInvoices
                        .where((invoice) => !(invoice['isArchived'] ?? false))
                        .toList(),
                  );
                });
              },
              child: Text(
                'الفواتير النشطة',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () {
                if (!_isMounted) return;

                _safeSetState(() {
                  _filteredInvoices = _applySearchFilter(
                    _allInvoices
                        .where((invoice) => (invoice['isArchived'] ?? false))
                        .toList(),
                  );
                });
              },
              child: Text(
                'السجل',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator(bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Center(
        child: _isLoadingMore
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () => _loadInvoices(loadMore: true),
                child: Text(
                  'تحميل المزيد',
                  style: TextStyle(fontSize: isMobile ? 12 : 14),
                ),
              ),
      ),
    );
  }

  Widget _buildSearchBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      color: Colors.white,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
          border: Border.all(color: const Color(0xFF3498DB)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: const Color(0xFF3498DB),
              size: isMobile ? 18 : 20,
            ),
            SizedBox(width: isMobile ? 6 : 8),
            Expanded(
              child: TextField(
                onChanged: (value) {
                  if (!_isMounted) return;

                  _safeSetState(() {
                    _searchQuery = value;
                    _filteredInvoices = _applySearchFilter(
                      _allInvoices
                          .where((invoice) => !(invoice['isArchived'] ?? false))
                          .toList(),
                    );
                  });
                },
                decoration: InputDecoration(
                  hintText: 'ابحث عن فاتورة أو شركة...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              GestureDetector(
                onTap: () {
                  if (!_isMounted) return;

                  _safeSetState(() {
                    _searchQuery = '';
                    _filteredInvoices = _applySearchFilter(
                      _allInvoices
                          .where((invoice) => !(invoice['isArchived'] ?? false))
                          .toList(),
                    );
                  });
                },
                child: Icon(
                  Icons.clear,
                  size: isMobile ? 16 : 18,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(
    Map<String, dynamic> invoice,
    int index,
    bool isMobile,
  ) {
    final has3Percent = invoice['has3PercentTax'] == true;
    final has14Percent = invoice['has14PercentTax'] == true;
    final isArchived = invoice['isArchived'] == true;
    final taxDate = invoice['taxDate'] as DateTime?;

    return Card(
      margin: EdgeInsets.symmetric(
        vertical: isMobile ? 4 : 6,
        horizontal: isMobile ? 6 : 8,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
      ),
      child: ExpansionTile(
        leading: Container(
          width: isMobile ? 36 : 40,
          height: isMobile ? 36 : 40,
          decoration: BoxDecoration(
            color: isArchived
                ? Colors.grey[200]
                : has3Percent || has14Percent
                ? (has14Percent ? Colors.green[50] : Colors.blue[50])
                : const Color(0xFFF4F6F8),
            borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isArchived
                    ? Colors.grey[600]
                    : has3Percent || has14Percent
                    ? (has14Percent ? Colors.green[800] : Colors.blue[800])
                    : const Color(0xFF2C3E50),
              ),
            ),
          ),
        ),
        title: Text(
          invoice['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 14 : 16,
            color: isArchived ? Colors.grey[600] : const Color(0xFF2C3E50),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              invoice['companyName'],
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: isArchived ? Colors.grey[500] : Colors.grey[700],
              ),
            ),
            if (taxDate != null)
              Text(
                'تاريخ الضريبة: ${_formatDate(taxDate)}',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatCurrency(invoice['totalAmount']),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 14 : 16,
                color: isArchived ? Colors.grey[600] : const Color(0xFF2E7D32),
              ),
            ),
            SizedBox(height: isMobile ? 2 : 3),
            if (has3Percent || has14Percent)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 6 : 8,
                  vertical: isMobile ? 1 : 2,
                ),
                decoration: BoxDecoration(
                  color: isArchived
                      ? Colors.grey[100]
                      : has14Percent
                      ? Colors.green[50]
                      : Colors.blue[50],
                  borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
                  border: Border.all(
                    color: isArchived
                        ? Colors.grey[300]!
                        : has14Percent
                        ? Colors.green[100]!
                        : Colors.blue[100]!,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (has3Percent)
                      Text(
                        '3%  ',
                        style: TextStyle(
                          fontSize: isMobile ? 8 : 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    if (has3Percent && has14Percent)
                      Text(
                        ' /  ',
                        style: TextStyle(fontSize: isMobile ? 8 : 10),
                      ),
                    if (has14Percent)
                      Text(
                        ' 14%',
                        style: TextStyle(
                          fontSize: isMobile ? 8 : 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 8 : 12,
            ),
            child: Column(
              children: [
                // زر نقل إلى الضرائب
                if (!isArchived && (!has3Percent || !has14Percent))
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _moveToBothTaxBoxes(invoice),
                      icon: Icon(
                        Icons.account_balance_wallet,
                        size: isMobile ? 18 : 20,
                      ),
                      label: Text(
                        'نقل إلى الضرائب',
                        style: TextStyle(fontSize: isMobile ? 12 : 14),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498DB),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: isMobile ? 12 : 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            isMobile ? 8 : 10,
                          ),
                        ),
                      ),
                    ),
                  ),

                SizedBox(height: isMobile ? 8 : 12),

                // إحصائيات الفاتورة
                Container(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'عدد الرحلات:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isArchived
                                  ? Colors.grey[600]
                                  : Colors.black,
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                          Text(
                            '${invoice['tripCount']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isArchived
                                  ? Colors.grey[600]
                                  : const Color(0xFF3498DB),
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 4 : 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'إجمالي النولون:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isArchived
                                  ? Colors.grey[600]
                                  : Colors.green,
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                          Text(
                            _formatCurrency(invoice['nolonTotal']),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isArchived
                                  ? Colors.grey[600]
                                  : Colors.green,
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 4 : 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'إجمالي المبيت:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isArchived
                                  ? Colors.grey[600]
                                  : Colors.orange,
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                          Text(
                            _formatCurrency(invoice['overnightTotal']),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isArchived
                                  ? Colors.grey[600]
                                  : Colors.orange,
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 4 : 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'إجمالي العطلة:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isArchived ? Colors.grey[600] : Colors.red,
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                          Text(
                            _formatCurrency(invoice['holidayTotal']),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isArchived ? Colors.grey[600] : Colors.red,
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                        ],
                      ),
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

  // ================================
  // بناء صفحة ضريبة 3%
  // ================================
  Widget _build3PercentTaxSection(bool isMobile, bool isTablet) {
    return _buildTaxSection(
      taxType: '3%',
      invoices: _3PercentTaxInvoices,
      taxRecords: _taxes3Percent,
      color: Colors.blue,
      isMobile: isMobile,
      isTablet: isTablet,
    );
  }

  // ================================
  // بناء صفحة ضريبة 14%
  // ================================
  Widget _build14PercentTaxSection(bool isMobile, bool isTablet) {
    return _buildTaxSection(
      taxType: '14%',
      invoices: _14PercentTaxInvoices,
      taxRecords: _taxes14Percent,
      color: Colors.green,
      isMobile: isMobile,
      isTablet: isTablet,
    );
  }

  Widget _buildTaxSection({
    required String taxType,
    required List<Map<String, dynamic>> invoices,
    required List<Map<String, dynamic>> taxRecords,
    required Color color,
    required bool isMobile,
    required bool isTablet,
  }) {
    // حساب الإجماليات للسنة
    double totalBeforeTax = 0;
    double totalTaxAmount = 0;
    for (var invoice in invoices) {
      totalBeforeTax += invoice['totalAmount'];
      totalTaxAmount += taxType == '3%'
          ? invoice['tax3Percent']
          : invoice['tax14Percent'];
    }
    final totalAfterTax = totalBeforeTax - totalTaxAmount;

    return Column(
      children: [
        // إحصائيات السنة
        Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: _buildTaxBoxSummaryCard(
            taxType: taxType,
            year: _selectedYear,
            totalInvoices: invoices.length,
            totalBeforeTax: totalBeforeTax,
            totalTaxAmount: totalTaxAmount,
            totalAfterTax: totalAfterTax,
            color: color,
            isMobile: isMobile,
          ),
        ),

        // تبويب السجلات والأشهر
        Container(
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    if (!_isMounted) return;

                    _safeSetState(() {
                      _selectedTaxRecord = null;
                      _taxRecordInvoices.clear();
                      _selectedMonthIndex = -1;
                      _monthInvoices = [];
                    });
                  },
                  child: Text(
                    'السجلات الضريبية',
                    style: TextStyle(
                      color:
                          _selectedTaxRecord == null &&
                              _selectedMonthIndex == -1
                          ? color
                          : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    if (!_isMounted) return;

                    _safeSetState(() {
                      _selectedTaxRecord = null;
                      _taxRecordInvoices.clear();
                      _selectedMonthIndex = -1;
                      _monthInvoices = [];
                    });
                  },
                  child: Text(
                    'الضرائب الشهرية',
                    style: TextStyle(
                      color: _selectedMonthIndex != -1 ? color : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // قائمة الأشهر أو الفواتير
        Expanded(
          child: _selectedMonthIndex != -1
              ? _buildMonthInvoicesList(isMobile)
              : _buildTaxContent(
                  invoices,
                  taxRecords,
                  taxType,
                  color,
                  isMobile,
                  isTablet,
                ),
        ),
      ],
    );
  }

  Widget _buildTaxContent(
    List<Map<String, dynamic>> invoices,
    List<Map<String, dynamic>> taxRecords,
    String taxType,
    Color color,
    bool isMobile,
    bool isTablet,
  ) {
    if (_selectedTaxRecord != null) {
      return _buildTaxRecordDetails(isMobile);
    }

    // عرض قائمة الأشهر بدلاً من السجلات
    return _buildMonthsGrid(isMobile, isTablet);
  }

  Widget _buildMonthsGrid(bool isMobile, bool isTablet) {
    int crossAxisCount;
    if (isMobile) {
      crossAxisCount = 3; // 3 أعمدة للموبايل
    } else if (isTablet) {
      crossAxisCount = 4; // 4 أعمدة للتابلت
    } else {
      crossAxisCount = 6; // 6 أعمدة للشاشات الكبيرة
    }

    return GridView.builder(
      padding: EdgeInsets.all(isMobile ? 8 : 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isMobile ? 4 : 8,
        mainAxisSpacing: isMobile ? 4 : 8,
        childAspectRatio: isMobile ? 1.2 : 1.5,
      ),
      itemCount: _monthlyTaxData.length,
      itemBuilder: (context, index) {
        final monthData = _monthlyTaxData[index];
        final isSelected = index == _selectedMonthIndex;

        return _buildMonthCard(monthData, index, isSelected, isMobile);
      },
    );
  }

  Widget _buildMonthCard(
    Map<String, dynamic> monthData,
    int index,
    bool isSelected,
    bool isMobile,
  ) {
    final monthName = monthData['monthName'];
    final invoiceCount = monthData['invoiceCount'];
    final totalTax = monthData['totalTax'];
    final color = _currentPage == 2 ? Colors.blue : Colors.green;

    return GestureDetector(
      onTap: () => _selectMonth(index),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              monthName,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.black,
              ),
            ),
            SizedBox(height: isMobile ? 4 : 8),
            if (invoiceCount > 0)
              Column(
                children: [
                  Text(
                    '$invoiceCount فاتورة',
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 12,
                      color: isSelected ? color : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: isMobile ? 2 : 4),
                  Text(
                    _formatCurrency(totalTax),
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.green,
                    ),
                  ),
                ],
              )
            else
              Text(
                'لا توجد فواتير',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: Colors.grey[400],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthInvoicesList(bool isMobile) {
    if (_monthInvoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt,
              size: isMobile ? 60 : 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: isMobile ? 12 : 16),
            Text(
              'لا توجد فواتير في هذا الشهر',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // عنوان الشهر
        Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          color: _currentPage == 2 ? Colors.blue[50] : Colors.green[50],
          child: Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: _currentPage == 2 ? Colors.blue : Colors.green,
                size: isMobile ? 20 : 24,
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Text(
                _monthlyTaxData[_selectedMonthIndex]['monthName'],
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: _currentPage == 2 ? Colors.blue : Colors.green,
                ),
              ),
              const Spacer(),
              Text(
                '(${_monthInvoices.length}) فاتورة',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        // قائمة الفواتير
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            itemCount: _monthInvoices.length,
            itemBuilder: (context, index) {
              final invoice = _monthInvoices[index];
              return _buildMonthInvoiceCard(invoice, index, isMobile);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthInvoiceCard(
    Map<String, dynamic> invoice,
    int index,
    bool isMobile,
  ) {
    final taxType = _currentPage == 2 ? '3%' : '14%';
    final taxAmount = _currentPage == 2
        ? invoice['tax3Percent']
        : invoice['tax14Percent'];
    final amountAfterTax = invoice['totalAmount'] - taxAmount;
    final invoiceDate = invoice['taxDate'] ?? invoice['createdAt'];

    return Card(
      margin: EdgeInsets.only(bottom: isMobile ? 8 : 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // اسم الفاتورة
            Text(
              invoice['name'],
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
            ),

            SizedBox(height: isMobile ? 6 : 8),

            // التاريخ وسعر الفاتورة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // التاريخ على اليسار
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التاريخ',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    Text(
                      _formatDate(invoiceDate),
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),

                // سعر الفاتورة في الوسط
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'سعر الفاتورة',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    Text(
                      _formatCurrency(invoice['totalAmount']),
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),

                // الضرائب على اليمين
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ضريبة $taxType',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    Text(
                      _formatCurrency(taxAmount),
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.bold,
                        color: _currentPage == 2 ? Colors.blue : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxBoxSummaryCard({
    required String taxType,
    required int year,
    required int totalInvoices,
    required double totalBeforeTax,
    required double totalTaxAmount,
    required double totalAfterTax,
    required Color color,
    required bool isMobile,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
      ),
      color: color.withOpacity(0.05),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          children: [
            // العنوان
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  taxType == '3%'
                      ? Icons.account_balance_wallet
                      : Icons.account_balance,
                  color: color,
                  size: isMobile ? 20 : 24,
                ),
                SizedBox(width: isMobile ? 6 : 8),
                Text(
                  'صندوق $taxType - سنة $year',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 16 : 20),

            // شبكة الإحصائيات
            Column(
              children: [
                // الصف الأول: عدد الفواتير والإجمالي قبل الضريبة
                Row(
                  children: [
                    // عدد الفواتير
                    Expanded(
                      child: _buildStatBox(
                        title: 'عدد الفواتير',
                        value: '$totalInvoices',
                        icon: Icons.receipt,
                        color: const Color(0xFF3498DB),
                        isMobile: isMobile,
                      ),
                    ),

                    SizedBox(width: isMobile ? 8 : 12),

                    // الإجمالي قبل الضريبة
                    Expanded(
                      child: _buildStatBox(
                        title: 'الإجمالي قبل الضريبة',
                        value: _formatCurrency(totalBeforeTax),
                        icon: Icons.attach_money,
                        color: Colors.blue[700]!,
                        isMobile: isMobile,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isMobile ? 8 : 12),

                // الصف الثاني: قيمة الضريبة
                _buildStatBox(
                  title: 'قيمة الضريبة',
                  value: _formatCurrency(totalTaxAmount),
                  icon: Icons.account_balance_wallet,
                  color: color,
                  isMobile: isMobile,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: isMobile ? 16 : 18),
              SizedBox(width: isMobile ? 6 : 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 4 : 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxRecordsList(
    List<Map<String, dynamic>> records,
    Color color,
    bool isMobile,
  ) {
    return records.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: isMobile ? 60 : 80,
                  color: Colors.grey[400],
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  'لا توجد سجلات ضريبية لهذه السنة',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(isMobile ? 4 : 8),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return _buildTaxRecordCard(record, color, index, isMobile);
            },
          );
  }

  Widget _buildTaxRecordCard(
    Map<String, dynamic> record,
    Color color,
    int index,
    bool isMobile,
  ) {
    final year = record['year'];
    final totalInvoices = record['totalInvoices'];
    final totalBeforeTax = record['totalAmountBeforeTax'];
    final totalTax = record['totalTaxAmount'];
    final totalAfterTax = record['totalAmountAfterTax'];

    return Card(
      margin: EdgeInsets.symmetric(
        vertical: isMobile ? 4 : 6,
        horizontal: isMobile ? 6 : 8,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
      ),
      child: ListTile(
        leading: Container(
          width: isMobile ? 44 : 50,
          height: isMobile ? 44 : 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        title: Text(
          'سنة $year',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 15 : 17,
            color: color,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: isMobile ? 2 : 4),
            Text(
              'فاتورة :$totalInvoices   ',
              style: TextStyle(fontSize: isMobile ? 11 : 13),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatCurrency(totalTax),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 14 : 16,
                color: Colors.green,
              ),
            ),
            SizedBox(height: isMobile ? 2 : 4),
            Text(
              ' الضريبة',
              style: TextStyle(
                fontSize: isMobile ? 9 : 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        onTap: () => _showTaxRecordDetails(record),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 6 : 8,
        ),
      ),
    );
  }

  Widget _buildTaxInvoicesList(
    List<Map<String, dynamic>> invoices,
    String taxType,
    Color color,
    bool isMobile,
  ) {
    return invoices.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt,
                  size: isMobile ? 60 : 80,
                  color: Colors.grey[400],
                ),
                SizedBox(height: isMobile ? 12 : 16),
                Text(
                  'لا توجد فواتير لسنة $_selectedYear',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(isMobile ? 4 : 8),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return _buildTaxBoxInvoiceItem(
                invoice,
                taxType,
                color,
                index,
                isMobile,
              );
            },
          );
  }

  Widget _buildTaxBoxInvoiceItem(
    Map<String, dynamic> invoice,
    String taxType,
    Color color,
    int index,
    bool isMobile,
  ) {
    final taxAmount = taxType == '3%'
        ? invoice['tax3Percent']
        : invoice['tax14Percent'];
    final amountAfterTax = invoice['totalAmount'] - taxAmount;

    return Card(
      margin: EdgeInsets.symmetric(
        vertical: isMobile ? 4 : 6,
        horizontal: isMobile ? 6 : 8,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس البطاقة
            Row(
              children: [
                Container(
                  width: isMobile ? 32 : 36,
                  height: isMobile ? 32 : 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 14 : 16,
                        ),
                      ),
                      Text(
                        invoice['companyName'],
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 12 : 16),

            // سعر الفاتورة والضريبة
            Row(
              children: [
                // سعر الفاتورة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سعر الفاتورة',
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: isMobile ? 2 : 4),
                      Text(
                        _formatCurrency(invoice['totalAmount']),
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),

                // الضريبة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ضريبة $taxType',
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: isMobile ? 2 : 4),
                      Text(
                        _formatCurrency(taxAmount),
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: isMobile ? 8 : 12),

            // الإجمالي بعد الضريبة
            Container(
              padding: EdgeInsets.all(isMobile ? 10 : 12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الإجمالي بعد الضريبة',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  Text(
                    _formatCurrency(amountAfterTax),
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxRecordDetails(bool isMobile) {
    if (_selectedTaxRecord == null) return Container();

    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? 4 : 8),
      itemCount: _taxRecordInvoices.length,
      itemBuilder: (context, index) {
        final invoice = _taxRecordInvoices[index];
        final taxType = _selectedTaxRecord!['taxType'];
        final color = taxType == '3%' ? Colors.blue : Colors.green;

        return _buildTaxBoxInvoiceItem(
          invoice,
          taxType,
          color,
          index,
          isMobile,
        );
      },
    );
  }
}
