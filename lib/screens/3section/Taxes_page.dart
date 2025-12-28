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
  int _currentSection = 0; // 0: الفواتير، 1: صندوق 3%، 2: صندوق 14%
  bool _isLoading = false;
  String _searchQuery = '';

  // بيانات الفواتير
  List<Map<String, dynamic>> _allInvoices = [];
  List<Map<String, dynamic>> _filteredInvoices = [];
  List<Map<String, dynamic>> _3PercentTaxInvoices = [];
  List<Map<String, dynamic>> _14PercentTaxInvoices = [];

  // بيانات الضرائب
  List<Map<String, dynamic>> _taxes3Percent = [];
  List<Map<String, dynamic>> _taxes14Percent = [];

  // فلتر السنوات
  List<int> _availableYears = [];
  int _selectedYear = DateTime.now().year;

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

  @override
  void initState() {
    super.initState();
    _initializeYears();
    _loadData();
  }

  // ================================
  // تهيئة قائمة السنوات
  // ================================
  void _initializeYears() {
    final currentYear = DateTime.now().year;
    _availableYears = List.generate(5, (index) => currentYear - 2 + index);
    _selectedYear = currentYear;
  }

  // ================================
  // تحميل جميع البيانات
  // ================================
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _loadInvoices();
      await _loadTaxes();
      // تحضير بيانات الأشهر بعد تحميل الفواتير
      _prepareMonthlyData();
    } catch (e) {
      _showError('خطأ في تحميل البيانات: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ================================
  // تحميل جميع الفواتير (مع Pagination)
  // ================================
  Future<void> _loadInvoices({bool loadMore = false}) async {
    if (!loadMore) {
      setState(() {
        _isLoading = true;
        _allInvoices = [];
        _lastInvoiceDocument = null;
        _hasMoreInvoices = true;
      });
    } else {
      if (!_hasMoreInvoices || _isLoadingMore) return;
      setState(() => _isLoadingMore = true);
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
          'taxDate': taxDate, // تاريخ الضريبة الذي تم اختياره
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

      setState(() {
        if (loadMore) {
          _allInvoices.addAll(newInvoices);
          _isLoadingMore = false;
        } else {
          _allInvoices = newInvoices;
          _isLoading = false;
        }

        _filteredInvoices = _applySearchFilter(
          _allInvoices
              .where((invoice) => !(invoice['isArchived'] ?? false))
              .toList(),
        );
        _lastInvoiceDocument = invoicesSnapshot.docs.isNotEmpty
            ? invoicesSnapshot.docs.last
            : null;
        _hasMoreInvoices = newInvoices.length == _invoicesPerPage;
      });

      // فصل الفواتير حسب نوع الضريبة مع الفلترة بالسنة
      _separateTaxInvoices();
    } catch (e) {
      setState(() {
        if (loadMore) {
          _isLoadingMore = false;
        } else {
          _isLoading = false;
        }
      });
      _showError('خطأ في تحميل الفواتير: $e');
    }
  }

  // ================================
  // فصل الفواتير حسب نوع الضريبة مع الفلترة بالسنة
  // ================================
  void _separateTaxInvoices() {
    setState(() {
      // فلترة فواتير 3% حسب السنة المحددة باستخدام taxDate
      _3PercentTaxInvoices = _allInvoices
          .where(
            (invoice) =>
                invoice['has3PercentTax'] == true &&
                _isInvoiceInSelectedYear(invoice, '3%'),
          )
          .toList();

      // فلترة فواتير 14% حسب السنة المحددة باستخدام taxDate
      _14PercentTaxInvoices = _allInvoices
          .where(
            (invoice) =>
                invoice['has14PercentTax'] == true &&
                _isInvoiceInSelectedYear(invoice, '14%'),
          )
          .toList();
    });

    // تحديث بيانات الأشهر بعد فصل الفواتير
    _prepareMonthlyData();
  }

  // ================================
  // التحقق مما إذا كانت الفاتورة في السنة المحددة
  // ================================
  bool _isInvoiceInSelectedYear(Map<String, dynamic> invoice, String taxType) {
    DateTime? dateToCheck;

    // أولاً: استخدم taxDate (التاريخ الذي تم اختياره عند نقل الفاتورة)
    dateToCheck = invoice['taxDate'] as DateTime?;

    // ثانياً: إذا لم يكن taxDate موجوداً، استخدم تاريخ الضريبة المحدد
    if (dateToCheck == null) {
      if (taxType == '3%') {
        dateToCheck = invoice['tax3PercentDate'] as DateTime?;
      } else {
        dateToCheck = invoice['tax14PercentDate'] as DateTime?;
      }
    }

    // ثالثاً: إذا لم يكن هناك تاريخ ضريبة، استخدم تاريخ الإنشاء
    dateToCheck ??= invoice['createdAt'] as DateTime?;

    return dateToCheck != null && dateToCheck.year == _selectedYear;
  }

  // ================================
  // تحضير بيانات الأشهر
  // ================================
  void _prepareMonthlyData() {
    List<Map<String, dynamic>> invoices = [];

    if (_currentSection == 1) {
      invoices = _3PercentTaxInvoices;
    } else if (_currentSection == 2) {
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
          totalTax += _currentSection == 1
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

    setState(() {
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
  // تحديث بيانات الضرائب
  // ================================
  Future<void> _refreshTaxData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _loadInvoices();
      await _loadTaxes();
    } catch (e) {
      _showError('خطأ في تحديث البيانات: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ================================
  // تحميل بيانات الضرائب من Firestore
  // ================================
  Future<void> _loadTaxes({String? taxType}) async {
    try {
      if (taxType == '3%' || taxType == null) {
        QuerySnapshot tax3Snapshot;

        try {
          tax3Snapshot = await _firestore
              .collection('taxes')
              .where('taxType', isEqualTo: '3%')
              .orderBy('year', descending: true)
              .get();
        } catch (e) {
          // إذا فشل بسبب index، جلب بدون orderBy
          tax3Snapshot = await _firestore
              .collection('taxes')
              .where('taxType', isEqualTo: '3%')
              .get();
        }

        final List<Map<String, dynamic>> tax3List = [];
        for (final doc in tax3Snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final totalBeforeTax = ((data['totalAmountBeforeTax'] as num?) ?? 0)
              .toDouble();
          final taxAmount = ((data['totalTaxAmount'] as num?) ?? 0).toDouble();

          tax3List.add({
            'id': doc.id,
            'taxType': data['taxType'] ?? '3%',
            'year': data['year'] ?? DateTime.now().year,
            'totalInvoices': data['totalInvoices'] ?? 0,
            'totalAmountBeforeTax': totalBeforeTax,
            'totalTaxAmount': taxAmount,
            'totalAmountAfterTax': totalBeforeTax - taxAmount,
            'invoiceIds': data['invoiceIds'] ?? [],
            'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
          });
        }

        // إذا تم الجلب بدون orderBy، قم بالترتيب محلياً
        if (tax3List.isNotEmpty) {
          tax3List.sort(
            (a, b) => (b['year'] as int).compareTo(a['year'] as int),
          );
        }

        setState(() {
          _taxes3Percent = tax3List;
        });
      }

      if (taxType == '14%' || taxType == null) {
        QuerySnapshot tax14Snapshot;

        try {
          tax14Snapshot = await _firestore
              .collection('taxes')
              .where('taxType', isEqualTo: '14%')
              .orderBy('year', descending: true)
              .get();
        } catch (e) {
          // إذا فشل بسبب index، جلب بدون orderBy
          tax14Snapshot = await _firestore
              .collection('taxes')
              .where('taxType', isEqualTo: '14%')
              .get();
        }

        final List<Map<String, dynamic>> tax14List = [];
        for (final doc in tax14Snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final totalBeforeTax = ((data['totalAmountBeforeTax'] as num?) ?? 0)
              .toDouble();
          final taxAmount = ((data['totalTaxAmount'] as num?) ?? 0).toDouble();

          tax14List.add({
            'id': doc.id,
            'taxType': data['taxType'] ?? '14%',
            'year': data['year'] ?? DateTime.now().year,
            'totalInvoices': data['totalInvoices'] ?? 0,
            'totalAmountBeforeTax': totalBeforeTax,
            'totalTaxAmount': taxAmount,
            'totalAmountAfterTax': totalBeforeTax - taxAmount,
            'invoiceIds': data['invoiceIds'] ?? [],
            'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
          });
        }

        // إذا تم الجلب بدون orderBy، قم بالترتيب محلياً
        if (tax14List.isNotEmpty) {
          tax14List.sort(
            (a, b) => (b['year'] as int).compareTo(a['year'] as int),
          );
        }

        setState(() {
          _taxes14Percent = tax14List;
        });
      }

      // تحديث قائمة السنوات بناءً على السجلات الضريبية
      _updateAvailableYears();
    } catch (e) {
      _showError('خطأ في تحميل بيانات الضرائب: $e');
    }
  }

  // ================================
  // تحديث قائمة السنوات من السجلات الضريبية
  // ================================
  void _updateAvailableYears() {
    final Set<int> yearsSet = <int>{};

    // جمع السنوات من سجلات 3%
    for (final record in _taxes3Percent) {
      if (record['year'] != null) {
        yearsSet.add(record['year']);
      }
    }

    // جمع السنوات من سجلات 14%
    for (final record in _taxes14Percent) {
      if (record['year'] != null) {
        yearsSet.add(record['year']);
      }
    }

    // إضافة السنوات من الفواتير (استخدام taxDate أولاً)
    for (final invoice in _allInvoices) {
      // أولوية لـ taxDate
      final taxDate = invoice['taxDate'] as DateTime?;
      if (taxDate != null) {
        yearsSet.add(taxDate.year);
      } else {
        // إذا لم يكن هناك taxDate، استخدم تاريخ الضريبة
        final tax3Date = invoice['tax3PercentDate'] as DateTime?;
        if (tax3Date != null) {
          yearsSet.add(tax3Date.year);
        }

        final tax14Date = invoice['tax14PercentDate'] as DateTime?;
        if (tax14Date != null) {
          yearsSet.add(tax14Date.year);
        }

        // أخيراً، تاريخ الإنشاء
        final createdAt = invoice['createdAt'] as DateTime?;
        if (createdAt != null) {
          yearsSet.add(createdAt.year);
        }
      }
    }

    // إضافة السنة الحالية إذا كانت فارغة
    if (yearsSet.isEmpty) {
      yearsSet.add(DateTime.now().year);
    }

    // تحويل إلى قائمة وترتيب تنازلي
    final List<int> yearsList = yearsSet.toList()
      ..sort((a, b) => b.compareTo(a));

    setState(() {
      _availableYears = yearsList;
      if (_availableYears.isNotEmpty &&
          !_availableYears.contains(_selectedYear)) {
        _selectedYear = _availableYears.first;
      }
    });
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
    if (_currentSection == 0) {
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
        setState(() {
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
        await _autoSaveTaxRecords(selectedYear);

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
      await _loadTaxes();
    } catch (e) {
      _showError('خطأ في الحفظ التلقائي للسجلات: $e');
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
        print('لا توجد فواتير $taxType لسنة $year');
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
        print('تم تحديث سجل $taxType لسنة $year');
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
        print('تم إنشاء سجل جديد $taxType لسنة $year');
      }
    } catch (e) {
      print('خطأ في حفظ سجل $taxType لسنة $year: $e');
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
      print('خطأ في البحث عن سجل ضريبي: $e');
      return null;
    }
  }

  // ================================
  // تحميل الفواتير المرتبطة بسجل ضريبي
  // ================================
  Future<void> _loadTaxRecordInvoices(Map<String, dynamic> taxRecord) async {
    final invoiceIds = List<String>.from(taxRecord['invoiceIds'] ?? []);

    setState(() {
      _taxRecordInvoices = [];
      _isLoading = true;
    });

    try {
      final List<Map<String, dynamic>> invoicesList = [];

      for (final invoiceId in invoiceIds) {
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

      setState(() {
        _taxRecordInvoices = invoicesList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('خطأ في تحميل تفاصيل السجل الضريبي: $e');
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
      setState(() {
        _selectedYear = selectedDate.year;
      });

      // إعادة تحميل البيانات للفلترة حسب السنة الجديدة
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _separateTaxInvoices();
      });
    }

    return selectedDate;
  }

  // ================================
  // عرض تفاصيل سجل ضريبي
  // ================================
  Future<void> _showTaxRecordDetails(Map<String, dynamic> taxRecord) async {
    setState(() {
      _selectedTaxRecord = taxRecord;
      _selectedMonthIndex = -1;
      _monthInvoices = [];
    });

    await _loadTaxRecordInvoices(taxRecord);
    _showTaxDetailsSheet(taxRecord);
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
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

  void _changeSection(int section) {
    setState(() {
      _currentSection = section;
      _selectedTaxRecord = null;
      _taxRecordInvoices.clear();
      _selectedMonthIndex = -1;
      _monthInvoices = [];
    });

    // تحضير بيانات الأشهر عند تغيير القسم
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prepareMonthlyData();
    });
  }

  void _onYearChanged(int? value) {
    if (value != null) {
      setState(() {
        _selectedYear = value;
        _selectedTaxRecord = null;
        _taxRecordInvoices.clear();
        _selectedMonthIndex = -1;
        _monthInvoices = [];
      });

      // إعادة فلترة الفواتير حسب السنة الجديدة
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _separateTaxInvoices();
      });
    }
  }

  // ================================
  // وظائف جديدة للأشهر
  // ================================
  void _selectMonth(int monthIndex) {
    setState(() {
      if (_selectedMonthIndex == monthIndex) {
        // إذا كان نفس الشهر، إلغاء التحديد
        _selectedMonthIndex = -1;
        _monthInvoices = [];
      } else {
        _selectedMonthIndex = monthIndex;
        _monthInvoices = _monthlyTaxData[monthIndex]['invoices'];
      }
    });
  }

  // ================================
  // بناء واجهة
  // ================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Column(
        children: [
          _buildCustomAppBar(),
          _buildYearFilter(),
          _buildSectionTabs(),
          Expanded(
            child: _isLoading && _allInvoices.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _currentSection == 0
                ? _buildInvoicesSection()
                : _currentSection == 1
                ? _build3PercentTaxSection()
                : _build14PercentTaxSection(),
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
            const Icon(Icons.request_quote, color: Colors.white, size: 28),
            const SizedBox(width: 8),
            const Expanded(
              child: Center(
                child: Text(
                  'إدارة الضرائب',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // IconButton(
            //   icon: const Icon(Icons.refresh, color: Colors.white),
            //   onPressed: _refreshTaxData,
            //   tooltip: 'تحديث البيانات',
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearFilter() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'فلتر حسب السنة:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
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
            style: const TextStyle(
              color: Color(0xFF3498DB),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTabs() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _buildSectionTab(0, Icons.receipt, 'جميع الفواتير'),
          _buildSectionTab(1, Icons.account_balance_wallet, 'صندوق 3%'),
          _buildSectionTab(2, Icons.account_balance, 'صندوق 14%'),
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
            color: isActive
                ? (section == 1
                      ? Colors.blue
                      : section == 2
                      ? Colors.green
                      : const Color(0xFF3498DB))
                : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isActive
                    ? (section == 1
                          ? Colors.blue
                          : section == 2
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

  Widget _buildInvoicesSection() {
    return Column(
      children: [
        // شريط البحث
        _buildSearchBar(),

        // تبويب السجل
        _buildArchiveTab(),

        Expanded(
          child: _filteredInvoices.isEmpty && !_isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'لا توجد فواتير',
                        style: TextStyle(
                          fontSize: 16,
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
                    padding: const EdgeInsets.all(8),
                    itemCount:
                        _filteredInvoices.length + (_hasMoreInvoices ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _filteredInvoices.length) {
                        return _buildLoadMoreIndicator();
                      }
                      final invoice = _filteredInvoices[index];
                      return _buildInvoiceCard(invoice, index);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildArchiveTab() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {
                setState(() {
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
                ),
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () {
                setState(() {
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: _isLoadingMore
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () => _loadInvoices(loadMore: true),
                child: const Text('تحميل المزيد'),
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
                    _filteredInvoices = _applySearchFilter(
                      _allInvoices
                          .where((invoice) => !(invoice['isArchived'] ?? false))
                          .toList(),
                    );
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'ابحث عن فاتورة أو شركة...',
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
                    _filteredInvoices = _applySearchFilter(
                      _allInvoices
                          .where((invoice) => !(invoice['isArchived'] ?? false))
                          .toList(),
                    );
                  });
                },
                child: const Icon(Icons.clear, size: 18, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> invoice, int index) {
    final has3Percent = invoice['has3PercentTax'] == true;
    final has14Percent = invoice['has14PercentTax'] == true;
    final isArchived = invoice['isArchived'] == true;
    final taxDate = invoice['taxDate'] as DateTime?;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isArchived
                ? Colors.grey[200]
                : has3Percent || has14Percent
                ? (has14Percent ? Colors.green[50] : Colors.blue[50])
                : const Color(0xFFF4F6F8),
            borderRadius: BorderRadius.circular(8),
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
            fontSize: 16,
            color: isArchived ? Colors.grey[600] : const Color(0xFF2C3E50),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              invoice['companyName'],
              style: TextStyle(
                fontSize: 14,
                color: isArchived ? Colors.grey[500] : Colors.grey[700],
              ),
            ),
            if (taxDate != null)
              Text(
                'تاريخ الضريبة: ${_formatDate(taxDate)}',
                style: const TextStyle(
                  fontSize: 12,
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
                fontSize: 16,
                color: isArchived ? Colors.grey[600] : const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 3),
            if (has3Percent || has14Percent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isArchived
                      ? Colors.grey[100]
                      : has14Percent
                      ? Colors.green[50]
                      : Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
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
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    if (has3Percent && has14Percent)
                      const Text(' /  ', style: TextStyle(fontSize: 10)),
                    if (has14Percent)
                      Text(
                        ' 14%',
                        style: TextStyle(
                          fontSize: 10,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // زر نقل إلى الضرائب
                if (!isArchived && (!has3Percent || !has14Percent))
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _moveToBothTaxBoxes(invoice),
                      icon: const Icon(Icons.account_balance_wallet, size: 20),
                      label: const Text('نقل إلى الضرائب'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498DB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // إحصائيات الفاتورة
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
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
                            ),
                          ),
                          Text(
                            '${invoice['tripCount']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isArchived
                                  ? Colors.grey[600]
                                  : const Color(0xFF3498DB),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
                            ),
                          ),
                          Text(
                            _formatCurrency(invoice['nolonTotal']),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isArchived
                                  ? Colors.grey[600]
                                  : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
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
                            ),
                          ),
                          Text(
                            _formatCurrency(invoice['overnightTotal']),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isArchived
                                  ? Colors.grey[600]
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'إجمالي العطلة:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isArchived ? Colors.grey[600] : Colors.red,
                            ),
                          ),
                          Text(
                            _formatCurrency(invoice['holidayTotal']),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isArchived ? Colors.grey[600] : Colors.red,
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

  Widget _build3PercentTaxSection() {
    // استخدام القائمة المحدثة مباشرة
    return _buildTaxSection(
      taxType: '3%',
      invoices: _3PercentTaxInvoices,
      taxRecords: _taxes3Percent
          .where((record) => record['year'] == _selectedYear)
          .toList(),
      color: Colors.blue,
    );
  }

  Widget _build14PercentTaxSection() {
    // استخدام القائمة المحدثة مباشرة
    return _buildTaxSection(
      taxType: '14%',
      invoices: _14PercentTaxInvoices,
      taxRecords: _taxes14Percent
          .where((record) => record['year'] == _selectedYear)
          .toList(),
      color: Colors.green,
    );
  }

  Widget _buildTaxSection({
    required String taxType,
    required List<Map<String, dynamic>> invoices,
    required List<Map<String, dynamic>> taxRecords,
    required Color color,
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
          padding: const EdgeInsets.all(16),
          child: _buildTaxBoxSummaryCard(
            taxType: taxType,
            year: _selectedYear,
            totalInvoices: invoices.length,
            totalBeforeTax: totalBeforeTax,
            totalTaxAmount: totalTaxAmount,
            totalAfterTax: totalAfterTax,
            color: color,
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
                    setState(() {
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
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
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
              ? _buildMonthInvoicesList()
              : _buildTaxContent(invoices, taxRecords, taxType, color),
        ),
      ],
    );
  }

  Widget _buildTaxContent(
    List<Map<String, dynamic>> invoices,
    List<Map<String, dynamic>> taxRecords,
    String taxType,
    Color color,
  ) {
    if (_selectedTaxRecord != null) {
      return _buildTaxRecordDetails();
    }

    // عرض قائمة الأشهر بدلاً من السجلات
    return _buildMonthsGrid();
  }

  Widget _buildMonthsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1.8,
      ),
      itemCount: _monthlyTaxData.length,
      itemBuilder: (context, index) {
        final monthData = _monthlyTaxData[index];
        final isSelected = index == _selectedMonthIndex;

        return _buildMonthCard(monthData, index, isSelected);
      },
    );
  }

  Widget _buildMonthCard(
    Map<String, dynamic> monthData,
    int index,
    bool isSelected,
  ) {
    final monthName = monthData['monthName'];
    final invoiceCount = monthData['invoiceCount'];
    final totalTax = monthData['totalTax'];
    final color = _currentSection == 1 ? Colors.blue : Colors.green;

    return GestureDetector(
      onTap: () => _selectMonth(index),
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            if (invoiceCount > 0)
              Column(
                children: [
                  Text(
                    '$invoiceCount فاتورة',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? color : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(totalTax),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.green,
                    ),
                  ),
                ],
              )
            else
              Text(
                'لا توجد فواتير',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthInvoicesList() {
    if (_monthInvoices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'لا توجد فواتير في هذا الشهر',
              style: TextStyle(
                fontSize: 16,
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
          padding: const EdgeInsets.all(16),
          color: _currentSection == 1 ? Colors.blue[50] : Colors.green[50],
          child: Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: _currentSection == 1 ? Colors.blue : Colors.green,
              ),
              const SizedBox(width: 12),
              Text(
                _monthlyTaxData[_selectedMonthIndex]['monthName'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _currentSection == 1 ? Colors.blue : Colors.green,
                ),
              ),
              const Spacer(),
              Text(
                '(${_monthInvoices.length}) فاتورة',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),

        // قائمة الفواتير
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _monthInvoices.length,
            itemBuilder: (context, index) {
              final invoice = _monthInvoices[index];
              return _buildMonthInvoiceCard(invoice, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthInvoiceCard(Map<String, dynamic> invoice, int index) {
    final taxType = _currentSection == 1 ? '3%' : '14%';
    final taxAmount = _currentSection == 1
        ? invoice['tax3Percent']
        : invoice['tax14Percent'];
    final amountAfterTax = invoice['totalAmount'] - taxAmount;
    final invoiceDate = invoice['taxDate'] ?? invoice['createdAt'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // اسم الفاتورة
            Text(
              invoice['name'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),

            const SizedBox(height: 8),

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
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(invoiceDate),
                      style: const TextStyle(
                        fontSize: 14,
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
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(invoice['totalAmount']),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
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
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(taxAmount),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _currentSection == 1
                            ? Colors.blue
                            : Colors.green,
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
                    _formatCurrency(amountAfterTax),
                    style: const TextStyle(
                      fontSize: 16,
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

  Widget _buildTaxBoxSummaryCard({
    required String taxType,
    required int year,
    required int totalInvoices,
    required double totalBeforeTax,
    required double totalTaxAmount,
    required double totalAfterTax,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'صندوق $taxType - سنة $year',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // شبكة الإحصائيات
            Row(
              children: [
                // عدد الفواتير
                Expanded(
                  child: _buildStatBox(
                    title: 'عدد الفواتير',
                    value: '$totalInvoices',
                    icon: Icons.receipt,
                    color: const Color(0xFF3498DB),
                  ),
                ),

                const SizedBox(width: 12),

                // الإجمالي قبل الضريبة
                Expanded(
                  child: _buildStatBox(
                    title: 'الإجمالي قبل الضريبة',
                    value: _formatCurrency(totalBeforeTax),
                    icon: Icons.attach_money,
                    color: Colors.blue[700]!,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                // قيمة الضريبة
                Expanded(
                  child: _buildStatBox(
                    title: 'قيمة الضريبة',
                    value: _formatCurrency(totalTaxAmount),
                    icon: Icons.account_balance_wallet,
                    color: color,
                  ),
                ),

                const SizedBox(width: 12),

                // الإجمالي بعد الضريبة
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[100]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.money_off,
                              color: Colors.red[700],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'الإجمالي بعد الضريبة',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatCurrency(totalAfterTax),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
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
    );
  }

  Widget _buildStatBox({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
    );
  }

  Widget _buildTaxRecordsList(List<Map<String, dynamic>> records, Color color) {
    return records.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text(
                  'لا توجد سجلات ضريبية لهذه السنة',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return _buildTaxRecordCard(record, color, index);
            },
          );
  }

  Widget _buildTaxRecordCard(
    Map<String, dynamic> record,
    Color color,
    int index,
  ) {
    final year = record['year'];
    final totalInvoices = record['totalInvoices'];
    final totalBeforeTax = record['totalAmountBeforeTax'];
    final totalTax = record['totalTaxAmount'];
    final totalAfterTax = record['totalAmountAfterTax'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: 18,
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
            fontSize: 17,
            color: color,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'فاتورة :$totalInvoices   ',
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatCurrency(totalTax),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              ' الضريبة',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
        onTap: () => _showTaxRecordDetails(record),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildTaxInvoicesList(
    List<Map<String, dynamic>> invoices,
    String taxType,
    Color color,
  ) {
    return invoices.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'لا توجد فواتير لسنة $_selectedYear',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: invoices.length,
            itemBuilder: (context, index) {
              final invoice = invoices[index];
              return _buildTaxBoxInvoiceItem(invoice, taxType, color, index);
            },
          );
  }

  Widget _buildTaxBoxInvoiceItem(
    Map<String, dynamic> invoice,
    String taxType,
    Color color,
    int index,
  ) {
    final taxAmount = taxType == '3%'
        ? invoice['tax3Percent']
        : invoice['tax14Percent'];
    final amountAfterTax = invoice['totalAmount'] - taxAmount;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
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
                ),

                // الضريبة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ضريبة $taxType',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(taxAmount),
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
                    _formatCurrency(amountAfterTax),
                    style: const TextStyle(
                      fontSize: 16,
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

  Widget _buildTaxRecordDetails() {
    if (_selectedTaxRecord == null) return Container();

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _taxRecordInvoices.length,
      itemBuilder: (context, index) {
        final invoice = _taxRecordInvoices[index];
        final taxType = _selectedTaxRecord!['taxType'];
        final color = taxType == '3%' ? Colors.blue : Colors.green;

        return _buildTaxBoxInvoiceItem(invoice, taxType, color, index);
      },
    );
  }
}

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
//   int _currentSection = 0; // 0: الفواتير، 1: صندوق 3%، 2: صندوق 14%
//   bool _isLoading = false;
//   String _searchQuery = '';

//   // بيانات الفواتير
//   List<Map<String, dynamic>> _allInvoices = [];
//   List<Map<String, dynamic>> _filteredInvoices = [];
//   List<Map<String, dynamic>> _3PercentTaxInvoices = [];
//   List<Map<String, dynamic>> _14PercentTaxInvoices = [];

//   // بيانات الضرائب
//   List<Map<String, dynamic>> _taxes3Percent = [];
//   List<Map<String, dynamic>> _taxes14Percent = [];

//   // فلتر السنوات
//   List<int> _availableYears = [];
//   int _selectedYear = DateTime.now().year;

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

//   @override
//   void initState() {
//     super.initState();
//     _initializeYears();
//     _loadData();
//   }

//   // ================================
//   // تهيئة قائمة السنوات
//   // ================================
//   void _initializeYears() {
//     final currentYear = DateTime.now().year;
//     _availableYears = List.generate(5, (index) => currentYear - 2 + index);
//     _selectedYear = currentYear;
//   }

//   // ================================
//   // تحميل جميع البيانات
//   // ================================
//   Future<void> _loadData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await _loadInvoices();
//       await _loadTaxes();
//       // تحضير بيانات الأشهر بعد تحميل الفواتير
//       _prepareMonthlyData();
//     } catch (e) {
//       _showError('خطأ في تحميل البيانات: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // ================================
//   // تحميل جميع الفواتير (مع Pagination)
//   // ================================
//   Future<void> _loadInvoices({bool loadMore = false}) async {
//     if (!loadMore) {
//       setState(() {
//         _isLoading = true;
//         _allInvoices = [];
//         _lastInvoiceDocument = null;
//         _hasMoreInvoices = true;
//       });
//     } else {
//       if (!_hasMoreInvoices || _isLoadingMore) return;
//       setState(() => _isLoadingMore = true);
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
//           'taxDate': taxDate, // تاريخ الضريبة الذي تم اختياره
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

//       setState(() {
//         if (loadMore) {
//           _allInvoices.addAll(newInvoices);
//           _isLoadingMore = false;
//         } else {
//           _allInvoices = newInvoices;
//           _isLoading = false;
//         }

//         _filteredInvoices = _applySearchFilter(
//           _allInvoices
//               .where((invoice) => !(invoice['isArchived'] ?? false))
//               .toList(),
//         );
//         _lastInvoiceDocument = invoicesSnapshot.docs.isNotEmpty
//             ? invoicesSnapshot.docs.last
//             : null;
//         _hasMoreInvoices = newInvoices.length == _invoicesPerPage;
//       });

//       // فصل الفواتير حسب نوع الضريبة مع الفلترة بالسنة
//       _separateTaxInvoices();
//     } catch (e) {
//       setState(() {
//         if (loadMore) {
//           _isLoadingMore = false;
//         } else {
//           _isLoading = false;
//         }
//       });
//       _showError('خطأ في تحميل الفواتير: $e');
//     }
//   }

//   // ================================
//   // فصل الفواتير حسب نوع الضريبة مع الفلترة بالسنة
//   // ================================
//   void _separateTaxInvoices() {
//     setState(() {
//       // فلترة فواتير 3% حسب السنة المحددة باستخدام taxDate
//       _3PercentTaxInvoices = _allInvoices
//           .where(
//             (invoice) =>
//                 invoice['has3PercentTax'] == true &&
//                 _isInvoiceInSelectedYear(invoice, '3%'),
//           )
//           .toList();

//       // فلترة فواتير 14% حسب السنة المحددة باستخدام taxDate
//       _14PercentTaxInvoices = _allInvoices
//           .where(
//             (invoice) =>
//                 invoice['has14PercentTax'] == true &&
//                 _isInvoiceInSelectedYear(invoice, '14%'),
//           )
//           .toList();
//     });

//     // تحديث بيانات الأشهر بعد فصل الفواتير
//     _prepareMonthlyData();
//   }

//   // ================================
//   // التحقق مما إذا كانت الفاتورة في السنة المحددة
//   // ================================
//   bool _isInvoiceInSelectedYear(Map<String, dynamic> invoice, String taxType) {
//     DateTime? dateToCheck;

//     // أولاً: استخدم taxDate (التاريخ الذي تم اختياره عند نقل الفاتورة)
//     dateToCheck = invoice['taxDate'] as DateTime?;

//     // ثانياً: إذا لم يكن taxDate موجوداً، استخدم تاريخ الضريبة المحدد
//     if (dateToCheck == null) {
//       if (taxType == '3%') {
//         dateToCheck = invoice['tax3PercentDate'] as DateTime?;
//       } else {
//         dateToCheck = invoice['tax14PercentDate'] as DateTime?;
//       }
//     }

//     // ثالثاً: إذا لم يكن هناك تاريخ ضريبة، استخدم تاريخ الإنشاء
//     dateToCheck ??= invoice['createdAt'] as DateTime?;

//     return dateToCheck != null && dateToCheck.year == _selectedYear;
//   }

//   // ================================
//   // تحضير بيانات الأشهر
//   // ================================
//   void _prepareMonthlyData() {
//     List<Map<String, dynamic>> invoices = [];

//     if (_currentSection == 1) {
//       invoices = _3PercentTaxInvoices;
//     } else if (_currentSection == 2) {
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
//           totalTax += _currentSection == 1
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
//           'invoices': <Map<String, dynamic>>[],
//         });
//       }
//     }

//     setState(() {
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
//   // اسم الشهر المختصر (3 أحرف)
//   // ================================
//   String _getShortMonthName(int month) {
//     switch (month) {
//       case 1:
//         return 'ينا';
//       case 2:
//         return 'فبر';
//       case 3:
//         return 'مار';
//       case 4:
//         return 'أبر';
//       case 5:
//         return 'ماي';
//       case 6:
//         return 'يون';
//       case 7:
//         return 'يول';
//       case 8:
//         return 'أغس';
//       case 9:
//         return 'سبت';
//       case 10:
//         return 'أكت';
//       case 11:
//         return 'نوف';
//       case 12:
//         return 'ديس';
//       default:
//         return '';
//     }
//   }

//   // ================================
//   // تحديث بيانات الضرائب
//   // ================================
//   Future<void> _refreshTaxData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await _loadInvoices();
//       await _loadTaxes();
//     } catch (e) {
//       _showError('خطأ في تحديث البيانات: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // ================================
//   // تحميل بيانات الضرائب من Firestore
//   // ================================
//   Future<void> _loadTaxes({String? taxType}) async {
//     try {
//       if (taxType == '3%' || taxType == null) {
//         QuerySnapshot tax3Snapshot;

//         try {
//           tax3Snapshot = await _firestore
//               .collection('taxes')
//               .where('taxType', isEqualTo: '3%')
//               .orderBy('year', descending: true)
//               .get();
//         } catch (e) {
//           // إذا فشل بسبب index، جلب بدون orderBy
//           tax3Snapshot = await _firestore
//               .collection('taxes')
//               .where('taxType', isEqualTo: '3%')
//               .get();
//         }

//         final List<Map<String, dynamic>> tax3List = [];
//         for (final doc in tax3Snapshot.docs) {
//           final data = doc.data() as Map<String, dynamic>;
//           final totalBeforeTax = ((data['totalAmountBeforeTax'] as num?) ?? 0)
//               .toDouble();
//           final taxAmount = ((data['totalTaxAmount'] as num?) ?? 0).toDouble();

//           tax3List.add({
//             'id': doc.id,
//             'taxType': data['taxType'] ?? '3%',
//             'year': data['year'] ?? DateTime.now().year,
//             'totalInvoices': data['totalInvoices'] ?? 0,
//             'totalAmountBeforeTax': totalBeforeTax,
//             'totalTaxAmount': taxAmount,
//             'totalAmountAfterTax': totalBeforeTax - taxAmount,
//             'invoiceIds': data['invoiceIds'] ?? [],
//             'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
//           });
//         }

//         // إذا تم الجلب بدون orderBy، قم بالترتيب محلياً
//         if (tax3List.isNotEmpty) {
//           tax3List.sort(
//             (a, b) => (b['year'] as int).compareTo(a['year'] as int),
//           );
//         }

//         setState(() {
//           _taxes3Percent = tax3List;
//         });
//       }

//       if (taxType == '14%' || taxType == null) {
//         QuerySnapshot tax14Snapshot;

//         try {
//           tax14Snapshot = await _firestore
//               .collection('taxes')
//               .where('taxType', isEqualTo: '14%')
//               .orderBy('year', descending: true)
//               .get();
//         } catch (e) {
//           // إذا فشل بسبب index، جلب بدون orderBy
//           tax14Snapshot = await _firestore
//               .collection('taxes')
//               .where('taxType', isEqualTo: '14%')
//               .get();
//         }

//         final List<Map<String, dynamic>> tax14List = [];
//         for (final doc in tax14Snapshot.docs) {
//           final data = doc.data() as Map<String, dynamic>;
//           final totalBeforeTax = ((data['totalAmountBeforeTax'] as num?) ?? 0)
//               .toDouble();
//           final taxAmount = ((data['totalTaxAmount'] as num?) ?? 0).toDouble();

//           tax14List.add({
//             'id': doc.id,
//             'taxType': data['taxType'] ?? '14%',
//             'year': data['year'] ?? DateTime.now().year,
//             'totalInvoices': data['totalInvoices'] ?? 0,
//             'totalAmountBeforeTax': totalBeforeTax,
//             'totalTaxAmount': taxAmount,
//             'totalAmountAfterTax': totalBeforeTax - taxAmount,
//             'invoiceIds': data['invoiceIds'] ?? [],
//             'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
//           });
//         }

//         // إذا تم الجلب بدون orderBy، قم بالترتيب محلياً
//         if (tax14List.isNotEmpty) {
//           tax14List.sort(
//             (a, b) => (b['year'] as int).compareTo(a['year'] as int),
//           );
//         }

//         setState(() {
//           _taxes14Percent = tax14List;
//         });
//       }

//       // تحديث قائمة السنوات بناءً على السجلات الضريبية
//       _updateAvailableYears();
//     } catch (e) {
//       _showError('خطأ في تحميل بيانات الضرائب: $e');
//     }
//   }

//   // ================================
//   // تحديث قائمة السنوات من السجلات الضريبية
//   // ================================
//   void _updateAvailableYears() {
//     final Set<int> yearsSet = <int>{};

//     // جمع السنوات من سجلات 3%
//     for (final record in _taxes3Percent) {
//       if (record['year'] != null) {
//         yearsSet.add(record['year']);
//       }
//     }

//     // جمع السنوات من سجلات 14%
//     for (final record in _taxes14Percent) {
//       if (record['year'] != null) {
//         yearsSet.add(record['year']);
//       }
//     }

//     // إضافة السنوات من الفواتير (استخدام taxDate أولاً)
//     for (final invoice in _allInvoices) {
//       // أولوية لـ taxDate
//       final taxDate = invoice['taxDate'] as DateTime?;
//       if (taxDate != null) {
//         yearsSet.add(taxDate.year);
//       } else {
//         // إذا لم يكن هناك taxDate، استخدم تاريخ الضريبة
//         final tax3Date = invoice['tax3PercentDate'] as DateTime?;
//         if (tax3Date != null) {
//           yearsSet.add(tax3Date.year);
//         }

//         final tax14Date = invoice['tax14PercentDate'] as DateTime?;
//         if (tax14Date != null) {
//           yearsSet.add(tax14Date.year);
//         }

//         // أخيراً، تاريخ الإنشاء
//         final createdAt = invoice['createdAt'] as DateTime?;
//         if (createdAt != null) {
//           yearsSet.add(createdAt.year);
//         }
//       }
//     }

//     // إضافة السنة الحالية إذا كانت فارغة
//     if (yearsSet.isEmpty) {
//       yearsSet.add(DateTime.now().year);
//     }

//     // تحويل إلى قائمة وترتيب تنازلي
//     final List<int> yearsList = yearsSet.toList()
//       ..sort((a, b) => b.compareTo(a));

//     setState(() {
//       _availableYears = yearsList;
//       if (_availableYears.isNotEmpty &&
//           !_availableYears.contains(_selectedYear)) {
//         _selectedYear = _availableYears.first;
//       }
//     });
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
//     if (_currentSection == 0) {
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
//         setState(() {
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
//         await _autoSaveTaxRecords(selectedYear);

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
//       await _loadTaxes();
//     } catch (e) {
//       _showError('خطأ في الحفظ التلقائي للسجلات: $e');
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

//     setState(() {
//       _taxRecordInvoices = [];
//       _isLoading = true;
//     });

//     try {
//       final List<Map<String, dynamic>> invoicesList = [];

//       for (final invoiceId in invoiceIds) {
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

//       setState(() {
//         _taxRecordInvoices = invoicesList;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showError('خطأ في تحميل تفاصيل السجل الضريبي: $e');
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
//       setState(() {
//         _selectedYear = selectedDate.year;
//       });

//       // إعادة تحميل البيانات للفلترة حسب السنة الجديدة
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _separateTaxInvoices();
//       });
//     }

//     return selectedDate;
//   }

//   // ================================
//   // عرض تفاصيل سجل ضريبي
//   // ================================
//   Future<void> _showTaxRecordDetails(Map<String, dynamic> taxRecord) async {
//     setState(() {
//       _selectedTaxRecord = taxRecord;
//       _selectedMonthIndex = -1;
//       _monthInvoices = [];
//     });

//     await _loadTaxRecordInvoices(taxRecord);
//     _showTaxDetailsSheet(taxRecord);
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
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }

//   void _showSuccess(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   // دالة لعرض رسالة عندما لا توجد فواتير
//   void _showNoInvoicesMessage(String monthName) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('شهر $monthName لا يحتوي على فواتير'),
//         duration: const Duration(seconds: 2),
//         backgroundColor: Colors.orange,
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

//   // تنسيق مختصر لقيمة الضرائب
//   String _formatTaxAmountShort(double amount) {
//     if (amount == 0) return '٠';

//     if (amount >= 1000000) {
//       return '${(amount / 1000000).toStringAsFixed(1)}M';
//     } else if (amount >= 1000) {
//       return '${(amount / 1000).toStringAsFixed(1)}K';
//     }

//     return amount.toStringAsFixed(0);
//   }

//   void _changeSection(int section) {
//     setState(() {
//       _currentSection = section;
//       _selectedTaxRecord = null;
//       _taxRecordInvoices.clear();
//       _selectedMonthIndex = -1;
//       _monthInvoices = [];
//     });

//     // تحضير بيانات الأشهر عند تغيير القسم
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _prepareMonthlyData();
//     });
//   }

//   void _onYearChanged(int? value) {
//     if (value != null) {
//       setState(() {
//         _selectedYear = value;
//         _selectedTaxRecord = null;
//         _taxRecordInvoices.clear();
//         _selectedMonthIndex = -1;
//         _monthInvoices = [];
//       });

//       // إعادة فلترة الفواتير حسب السنة الجديدة
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _separateTaxInvoices();
//       });
//     }
//   }

//   // ================================
//   // وظائف جديدة للأشهر
//   // ================================
//   void _selectMonth(int monthIndex) {
//     try {
//       final monthData = _monthlyTaxData[monthIndex];
//       final invoiceCount = monthData['invoiceCount'] ?? 0;

//       if (invoiceCount == 0) {
//         // إذا لم يكن هناك فواتير، عرض رسالة ولا تغيير الحالة
//         _showNoInvoicesMessage(monthData['monthName']);
//         return;
//       }

//       // تحويل القائمة بأمان
//       final dynamic invoices = monthData['invoices'];
//       List<Map<String, dynamic>> monthInvoices = [];

//       if (invoices is List) {
//         for (var item in invoices) {
//           if (item is Map<String, dynamic>) {
//             monthInvoices.add(item);
//           }
//         }
//       }

//       setState(() {
//         if (_selectedMonthIndex == monthIndex) {
//           // إذا كان نفس الشهر، إلغاء التحديد
//           _selectedMonthIndex = -1;
//           _monthInvoices = [];
//         } else {
//           _selectedMonthIndex = monthIndex;
//           _monthInvoices = monthInvoices;
//         }
//       });
//     } catch (e) {
//       print('خطأ في تحميل فواتير الشهر: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('خطأ في تحميل فواتير الشهر'),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 2),
//         ),
//       );
//     }
//   }

//   // ================================
//   // بناء واجهة
//   // ================================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6F8),
//       body: Column(
//         children: [
//           _buildCustomAppBar(),
//           _buildYearFilter(),
//           _buildSectionTabs(),
//           Expanded(
//             child: _isLoading && _allInvoices.isEmpty
//                 ? const Center(child: CircularProgressIndicator())
//                 : _currentSection == 0
//                 ? _buildInvoicesSection()
//                 : _currentSection == 1
//                 ? _build3PercentTaxSection()
//                 : _build14PercentTaxSection(),
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
//             const Icon(Icons.request_quote, color: Colors.white, size: 28),
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

//   Widget _buildSectionTabs() {
//     return Container(
//       color: Colors.white,
//       child: Row(
//         children: [
//           _buildSectionTab(0, Icons.receipt, 'جميع الفواتير'),
//           _buildSectionTab(1, Icons.account_balance_wallet, 'صندوق 3%'),
//           _buildSectionTab(2, Icons.account_balance, 'صندوق 14%'),
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
//             color: isActive
//                 ? (section == 1
//                       ? Colors.blue
//                       : section == 2
//                       ? Colors.green
//                       : const Color(0xFF3498DB))
//                 : Colors.white,
//             border: Border(
//               bottom: BorderSide(
//                 color: isActive
//                     ? (section == 1
//                           ? Colors.blue
//                           : section == 2
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
//                 setState(() {
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
//                 setState(() {
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
//                   setState(() {
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
//                   setState(() {
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

//   Widget _build3PercentTaxSection() {
//     return _buildTaxSection(
//       taxType: '3%',
//       invoices: _3PercentTaxInvoices,
//       taxRecords: _taxes3Percent
//           .where((record) => record['year'] == _selectedYear)
//           .toList(),
//       color: Colors.blue,
//     );
//   }

//   Widget _build14PercentTaxSection() {
//     return _buildTaxSection(
//       taxType: '14%',
//       invoices: _14PercentTaxInvoices,
//       taxRecords: _taxes14Percent
//           .where((record) => record['year'] == _selectedYear)
//           .toList(),
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
//                     setState(() {
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
//                     setState(() {
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
//       padding: const EdgeInsets.all(8),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 6,
//         crossAxisSpacing: 2,
//         mainAxisSpacing: 2,
//         childAspectRatio: 2.5,
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
//     final color = _currentSection == 1 ? Colors.blue : Colors.green;

//     return GestureDetector(
//       onTap: () {
//         if (invoiceCount == 0) {
//           _showNoInvoicesMessage(monthName);
//         } else {
//           _selectMonth(index);
//         }
//       },
//       child: Container(
//         margin: const EdgeInsets.all(1),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? color.withOpacity(0.15)
//               : (invoiceCount == 0 ? Colors.grey[100] : Colors.grey[50]),
//           borderRadius: BorderRadius.circular(4),
//           border: Border.all(
//             color: isSelected
//                 ? color
//                 : (invoiceCount == 0 ? Colors.grey[200]! : Colors.grey[300]!),
//             width: 0.5,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // اسم الشهر مختصر
//             Text(
//               _getShortMonthName(monthData['monthNumber']),
//               style: TextStyle(
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//                 color: isSelected
//                     ? color
//                     : (invoiceCount == 0 ? Colors.grey[500] : Colors.black),
//               ),
//             ),
//             const SizedBox(height: 1),

//             // عدد الفواتير
//             Text(
//               '$invoiceCount',
//               style: TextStyle(
//                 fontSize: 9,
//                 color: isSelected
//                     ? color
//                     : (invoiceCount == 0 ? Colors.grey[400] : Colors.grey[700]),
//               ),
//             ),

//             // قيمة الضرائب
//             if (invoiceCount > 0)
//               Text(
//                 _formatTaxAmountShort(totalTax),
//                 style: TextStyle(
//                   fontSize: 9,
//                   fontWeight: FontWeight.bold,
//                   color: isSelected ? color : Colors.green[700],
//                 ),
//               )
//             else
//               Text(
//                 'لا توجد',
//                 style: TextStyle(fontSize: 8, color: Colors.grey[400]),
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
//             Icon(Icons.receipt, size: 60, color: Colors.grey[400]),
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
//           padding: const EdgeInsets.all(12),
//           color: _currentSection == 1 ? Colors.blue[50] : Colors.green[50],
//           child: Row(
//             children: [
//               Icon(
//                 Icons.calendar_month,
//                 color: _currentSection == 1 ? Colors.blue : Colors.green,
//                 size: 20,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 _monthlyTaxData[_selectedMonthIndex]['monthName'],
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: _currentSection == 1 ? Colors.blue : Colors.green,
//                 ),
//               ),
//               const Spacer(),
//               Text(
//                 '(${_monthInvoices.length}) فاتورة',
//                 style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//               ),
//               IconButton(
//                 icon: Icon(
//                   Icons.close,
//                   color: _currentSection == 1 ? Colors.blue : Colors.green,
//                   size: 18,
//                 ),
//                 onPressed: () {
//                   setState(() {
//                     _selectedMonthIndex = -1;
//                     _monthInvoices = [];
//                   });
//                 },
//               ),
//             ],
//           ),
//         ),

//         // قائمة الفواتير - تم تصغير حجمها
//         Expanded(
//           child: ListView.builder(
//             padding: const EdgeInsets.all(8),
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

//   // ================================
//   // بطاقة الفاتورة المصغرة للشهر
//   // ================================
//   Widget _buildMonthInvoiceCard(Map<String, dynamic> invoice, int index) {
//     final taxType = _currentSection == 1 ? '3%' : '14%';
//     final taxAmount = _currentSection == 1
//         ? invoice['tax3Percent']
//         : invoice['tax14Percent'];
//     final amountAfterTax = invoice['totalAmount'] - taxAmount;
//     final invoiceDate = invoice['taxDate'] ?? invoice['createdAt'];

//     return Container(
//       margin: const EdgeInsets.only(bottom: 6),
//       padding: const EdgeInsets.all(10), // تصغير الهوامش الداخلية
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[200]!),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 2,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // اسم الفاتورة
//           Row(
//             children: [
//               Container(
//                 width: 24,
//                 height: 24,
//                 decoration: BoxDecoration(
//                   color: _currentSection == 1
//                       ? Colors.blue[50]
//                       : Colors.green[50],
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '${index + 1}',
//                     style: TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                       color: _currentSection == 1 ? Colors.blue : Colors.green,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Expanded(
//                 child: Text(
//                   invoice['name'],
//                   style: const TextStyle(
//                     fontSize: 14, // تصغير حجم الخط
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF2C3E50),
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ),
//             ],
//           ),

//           const SizedBox(height: 8),

//           // الصف الأول: التاريخ وسعر الفاتورة
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // التاريخ على اليسار
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'التاريخ',
//                     style: TextStyle(
//                       fontSize: 10, // تصغير حجم الخط
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     _formatDate(invoiceDate),
//                     style: TextStyle(
//                       fontSize: 12, // تصغير حجم الخط
//                       fontWeight: FontWeight.bold,
//                       color: Colors.blue,
//                     ),
//                   ),
//                 ],
//               ),

//               // سعر الفاتورة في الوسط
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Text(
//                     'سعر الفاتورة',
//                     style: TextStyle(
//                       fontSize: 10, // تصغير حجم الخط
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     _formatCurrency(invoice['totalAmount']),
//                     style: const TextStyle(
//                       fontSize: 14, // تصغير حجم الخط
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF2E7D32),
//                     ),
//                   ),
//                 ],
//               ),

//               // الضرائب على اليمين
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   Text(
//                     'ضريبة $taxType',
//                     style: TextStyle(
//                       fontSize: 10, // تصغير حجم الخط
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     _formatCurrency(taxAmount),
//                     style: TextStyle(
//                       fontSize: 14, // تصغير حجم الخط
//                       fontWeight: FontWeight.bold,
//                       color: _currentSection == 1 ? Colors.blue : Colors.green,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),

//           const SizedBox(height: 8),

//           // الصف الثاني: الإجمالي بعد الضريبة
//           Container(
//             padding: const EdgeInsets.all(8), // تصغير الهوامش الداخلية
//             decoration: BoxDecoration(
//               color: Colors.red[50],
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'الإجمالي بعد الضريبة',
//                   style: TextStyle(
//                     fontSize: 12, // تصغير حجم الخط
//                     fontWeight: FontWeight.bold,
//                     color: Colors.red[700],
//                   ),
//                 ),
//                 Text(
//                   _formatCurrency(amountAfterTax),
//                   style: TextStyle(
//                     fontSize: 14, // تصغير حجم الخط
//                     fontWeight: FontWeight.bold,
//                     color: Colors.red,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 4),

//           // اسم الشركة
//           Text(
//             invoice['companyName'] ?? 'شركة غير معروفة',
//             style: TextStyle(fontSize: 10, color: Colors.grey[500]),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
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

//                 // الإجمالي بعد الضريبة
//                 Expanded(
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.red[50],
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.red[100]!),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.money_off,
//                               color: Colors.red[700],
//                               size: 20,
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 'الإجمالي بعد الضريبة',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.red[700],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           _formatCurrency(totalAfterTax),
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.red,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
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
