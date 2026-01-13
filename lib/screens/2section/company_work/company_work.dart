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

  // Cache للبيانات
  final Map<String, List<Map<String, dynamic>>> _companyWorkCache = {};
  final Map<String, List<Map<String, dynamic>>> _companyInvoicesCache = {};
  final Map<String, List<Map<String, dynamic>>> _availableTripsCache = {};
  final Map<String, List<String>> _invoicedTripIdsCache = {};

  // متغيرات عامة
  List<Map<String, dynamic>> _allCompanies = [];
  List<Map<String, dynamic>> _filteredCompanies = [];
  String? _selectedCompany;
  String? _selectedCompanyId;
  bool _isLoading = false;
  String _searchQuery = '';

  // Pagination للرحلات
  int _tripsPageSize = 50;
  int _tripsCurrentPage = 0;
  bool _hasMoreTrips = true;
  bool _isLoadingMoreTrips = false;

  // Pagination للفواتير
  int _invoicesPageSize = 30;
  int _invoicesCurrentPage = 0;
  bool _hasMoreInvoices = true;
  bool _isLoadingMoreInvoices = false;

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
  String _selectedMonthFilter = 'كل الشهور'; // فلترة حسب الشهر
  String _selectedYearFilter = DateTime.now().year
      .toString(); // فلترة حسب السنة
  bool _showCollected = false;
  bool _showNotCollected = true;
  int _currentInvoiceView = 0;

  // متغير للمزامنة التلقائية
  bool _hasSyncedOnEnter = false;
  bool _isInitialLoadComplete = false;

  // Cache للخط واللوجو
  Uint8List? _logoImageBytes;
  Completer<pdfLib.Font>? _fontCompleter;

  String x = '';
  String xx = '';

  // فلترة الشهر والسنة
  String _selectedYear = DateTime.now().year.toString();
  String _selectedMonthWork = 'كل الشهور';
  String _selectedFilterMonth = 'كل الشهور';
  List<String> _yearsList = [];

  // Cache للإحصائيات
  Map<String, Map<String, dynamic>> _companyStatsCache = {};
  Map<String, bool> _companyTRStatusCache = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    // تحميل البيانات الأساسية غير المتزامنة
    final now = DateTime.now();

    // تعيين القيم الافتراضية
    _selectedMonth = _monthsList[now.month - 1];
    _selectedMonthFilter = _monthsList[now.month - 1];
    _selectedMonthWork = _monthsList[now.month - 1];
    _selectedYearFilter = now.year.toString();

    // إنشاء قائمة السنوات
    int currentYear = now.year;
    for (int year = 2025; year <= currentYear + 1; year++) {
      _yearsList.add(year.toString());
    }

    // تحميل البيانات الأساسية
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadCompaniesOptimized();
      _loadAssetsInBackground();
    });
  }

  Future<void> _loadAssetsInBackground() async {
    try {
      await Future.wait([_loadArabicFont(), _loadLogoImage()]);
    } catch (e) {
      debugPrint('خطأ في تحميل الموارد: $e');
    }
  }

  @override
  void dispose() {
    _invoiceNameController.dispose();
    _invoiceNotesController.dispose();
    // تنظيف cache
    _companyWorkCache.clear();
    _companyInvoicesCache.clear();
    _availableTripsCache.clear();
    _invoicedTripIdsCache.clear();
    _companyStatsCache.clear();
    _companyTRStatusCache.clear();
    super.dispose();
  }

  // ================================
  // تحميل صورة اللوجو
  // ================================
  Future<void> _loadLogoImage() async {
    try {
      if (_logoImageBytes == null) {
        final ByteData data = await rootBundle.load('assets/image/logoo.jpeg');
        if (mounted) {
          setState(() {
            _logoImageBytes = data.buffer.asUint8List();
          });
        }
        debugPrint('تم تحميل صورة اللوجو بنجاح');
      }
    } catch (e) {
      debugPrint('فشل تحميل صورة اللوجو: $e');
    }
  }

  // ================================
  // تحميل الخط العربي للطباعة
  // ================================
  Future<void> _loadArabicFont() async {
    try {
      if (_arabicFont == null && _fontCompleter == null) {
        _fontCompleter = Completer<pdfLib.Font>();
        final fontData = await rootBundle.load(
          'assets/fonts/Amiri/Amiri-Regular.ttf',
        );
        final font = pdfLib.Font.ttf(fontData);
        if (mounted) {
          setState(() {
            _arabicFont = font;
          });
        }
        _fontCompleter!.complete(font);
        debugPrint('تم تحميل الخط العربي بنجاح');
      } else if (_fontCompleter != null) {
        _arabicFont = await _fontCompleter!.future;
      }
    } catch (e) {
      debugPrint('فشل تحميل الخط العربي: $e');
      if (mounted) {
        setState(() {
          _arabicFont = pdfLib.Font.courier();
        });
      }
      _fontCompleter?.complete(pdfLib.Font.courier());
    }
  }

  // ================================
  // نظام مزامنة companySummaries تلقائياً
  // ================================
  Future<void> _syncDataOnPageEnter() async {
    debugPrint('🔄 بدء التحديث التلقائي لحسابات الشركات...');

    try {
      // استخدام batch للعمليات المتعددة
      final batch = _firestore.batch();
      final summariesRef = _firestore.collection('companySummaries');

      // جلب البيانات مع cache
      final companySummaries = await _firestore
          .collection('companySummaries')
          .get(const GetOptions(source: Source.cache))
          .then((snapshot) => snapshot)
          .catchError((_) => _firestore.collection('companySummaries').get());

      final dailyWorkSnapshot = await _firestore
          .collection('dailyWork')
          .limit(1000) // تحديد الحد الأقصى
          .get(const GetOptions(source: Source.cache))
          .then((snapshot) => snapshot)
          .catchError(
            (_) => _firestore.collection('dailyWork').limit(1000).get(),
          );

      Map<String, int> dailyWorkTripCounts = {};
      Map<String, double> dailyWorkTotalDebts = {};
      Map<String, String> companyNames = {};

      // معالجة البيانات بشكل أكثر كفاءة
      for (final doc in dailyWorkSnapshot.docs) {
        final data = doc.data();
        final companyId = data['companyId'] as String?;
        final companyName = data['companyName'] as String?;

        if (companyId != null && companyName != null) {
          dailyWorkTripCounts[companyId] =
              (dailyWorkTripCounts[companyId] ?? 0) + 1;
          companyNames[companyId] = companyName;

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

      int updatedCount = 0;

      // تحديث الحسابات الموجودة
      for (final doc in companySummaries.docs) {
        final data = doc.data();
        final companyId = doc.id;
        final companyName = companyNames[companyId];

        if (companyName != null) {
          final dailyWorkTrips = dailyWorkTripCounts[companyId] ?? 0;
          final totalDebt = dailyWorkTotalDebts[companyId] ?? 0.0;

          final summaryTrips = (data['totalTrips'] ?? 0).toInt();
          final summaryDebt = (data['totalCompanyDebt'] ?? 0).toDouble();

          if (dailyWorkTrips != summaryTrips || totalDebt != summaryDebt) {
            final totalPaidAmount = (data['totalPaidAmount'] ?? 0).toDouble();
            final totalRemaining = totalDebt - totalPaidAmount;

            String status = _calculateStatus(totalRemaining, totalPaidAmount);

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
        }
      }

      // إضافة شركات جديدة
      for (final companyId in dailyWorkTripCounts.keys) {
        if (!companySummaries.docs.any((doc) => doc.id == companyId)) {
          final companyName = companyNames[companyId] ?? 'غير معروف';
          final totalDebt = dailyWorkTotalDebts[companyId] ?? 0.0;
          final dailyWorkTrips = dailyWorkTripCounts[companyId] ?? 0;

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

      if (updatedCount > 0) {
        await batch.commit();
        debugPrint('✅ تم تحديث $updatedCount حساب شركة تلقائياً');
        _showSuccess('تم تحديث حسابات $updatedCount شركة تلقائياً');
      } else {
        debugPrint('✅ جميع الحسابات محدثة بالفعل');
      }
    } catch (e) {
      debugPrint('❌ خطأ في التحديث التلقائي: $e');
    }
  }

  String _calculateStatus(double totalRemaining, double totalPaidAmount) {
    if (totalRemaining <= 0) {
      return 'منتهية';
    } else if (totalPaidAmount > 0) {
      return 'شبه منتهية';
    } else {
      return 'جارية';
    }
  }

  // ================================
  // تحميل البيانات من السيرفر فقط (لزر التحديث)
  // ================================
  Future<void> _refreshFromServer() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      // مسح الكاش أولاً
      _clearAllCache();

      // تحميل من السيرفر مباشرة
      final companiesSnapshot = await _firestore
          .collection('companies')
          .get(GetOptions(source: Source.server));

      final dailyWorkSnapshot = await _firestore
          .collection('dailyWork')
          .limit(1000)
          .get(GetOptions(source: Source.server));

      final List<Map<String, dynamic>> companiesList = [];

      final Map<String, List<Map<String, dynamic>>> tripsByCompany = {};

      for (final doc in dailyWorkSnapshot.docs) {
        final data = doc.data();
        final companyId = data['companyId'] as String?;
        if (companyId != null) {
          if (!tripsByCompany.containsKey(companyId)) {
            tripsByCompany[companyId] = [];
          }
          tripsByCompany[companyId]!.add(data);
        }
      }

      for (final companyDoc in companiesSnapshot.docs) {
        final companyData = companyDoc.data();
        final companyId = companyDoc.id;
        final companyName =
            (companyData['name'] ??
                    companyData['companyName'] ??
                    'شركة غير معروفة')
                .toString()
                .trim();

        final companyTrips = tripsByCompany[companyId] ?? [];

        double totalNolon = 0.0;
        double totalOvernight = 0.0;
        double totalHoliday = 0.0;

        for (var trip in companyTrips) {
          totalNolon += (trip['noLon'] ?? trip['nolon'] ?? 0).toDouble();
          totalOvernight += (trip['companyOvernight'] ?? 0).toDouble();
          totalHoliday += (trip['companyHoliday'] ?? 0).toDouble();
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
          _filteredCompanies = companiesList;
          _isLoading = false;
        });
      }

      _showSuccess('✅ تم تحديث البيانات من السيرفر');
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      _showError('خطأ في تحديث البيانات: $e');
    }
  }

  // ================================
  // تحديث بيانات شركة من السيرفر
  // ================================
  Future<void> _refreshCompanyFromServer() async {
    if (_selectedCompany == null || _selectedCompanyId == null) return;

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      // مسح كاش الشركة المحددة
      _clearCompanyCache(_selectedCompanyId!);

      // تحميل من السيرفر
      final invoicedTripIds = await _loadInvoicedTripIdsFromServer(
        _selectedCompanyId!,
      );
      await _loadCompanyTripsFromServer(
        _selectedCompanyId!,
        _selectedCompany!,
        invoicedTripIds,
      );
      await _loadCompanyInvoicesFromServer(_selectedCompanyId!);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      _showSuccess('✅ تم تحديث بيانات الشركة من السيرفر');
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      _showError('خطأ في تحديث بيانات الشركة: $e');
    }
  }

  Future<List<String>> _loadInvoicedTripIdsFromServer(String companyId) async {
    try {
      final invoicesSnapshot = await _firestore
          .collection('invoices')
          .where('companyId', isEqualTo: companyId)
          .get(GetOptions(source: Source.server));

      final List<String> invoicedTripIds = [];

      for (final doc in invoicesSnapshot.docs) {
        final data = doc.data();
        final tripIds = (data['tripIds'] as List<dynamic>? ?? []);
        for (var tripId in tripIds) {
          invoicedTripIds.add(tripId.toString());
        }
      }

      return invoicedTripIds;
    } catch (e) {
      debugPrint('خطأ في تحميل ID الرحلات المفوتورة من السيرفر: $e');
      return [];
    }
  }

  Future<void> _loadCompanyTripsFromServer(
    String companyId,
    String companyName,
    List<String> invoicedTripIds,
  ) async {
    final workSnapshot = await _firestore
        .collection('dailyWork')
        .where('companyId', isEqualTo: companyId)
        .orderBy('date', descending: false)
        .limit(_tripsPageSize)
        .get(GetOptions(source: Source.server));

    final List<Map<String, dynamic>> allTrips = [];

    for (final doc in workSnapshot.docs) {
      final data = doc.data();
      final tripDate = (data['date'] as Timestamp?)?.toDate();
      final tripId = doc.id;

      final hasInvoice = invoicedTripIds.contains(tripId);

      allTrips.add({
        'id': tripId,
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
        'hasInvoice': hasInvoice,
      });
    }

    final sortedAvailableTrips = _sortAndGroupTripsForInvoice(
      allTrips.where((trip) => !trip['hasInvoice']).toList(),
    );

    if (mounted) {
      setState(() {
        _companyWork = allTrips;
        _availableTripsForInvoice = sortedAvailableTrips;
        if (workSnapshot.docs.length < _tripsPageSize) {
          _hasMoreTrips = false;
        }
      });
    }
  }

  Future<void> _loadCompanyInvoicesFromServer(String companyId) async {
    final invoicesSnapshot = await _firestore
        .collection('invoices')
        .where('companyId', isEqualTo: companyId)
        .orderBy('createdAt', descending: true)
        .limit(_invoicesPageSize)
        .get(GetOptions(source: Source.server));

    final List<Map<String, dynamic>> invoicesList = [];

    for (final doc in invoicesSnapshot.docs) {
      final data = doc.data();
      final tripIds = (data['tripIds'] as List<dynamic>? ?? []);

      List<Map<String, dynamic>> invoiceTrips = [];
      double totalNolon = 0;
      double totalOvernight = 0;
      double totalHoliday = 0;
      double totalKartaValue = 0;

      for (var tripId in tripIds) {
        try {
          final tripDoc = await _firestore
              .collection('dailyWork')
              .doc(tripId.toString())
              .get(GetOptions(source: Source.server));

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
              'selectedRoute': tripData['selectedRoute'] ?? '',
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
        } catch (e) {
          debugPrint('خطأ في جلب تفاصيل الرحلة $tripId: $e');
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
        'notes': data['notes'] ?? '',
        'month': data['month'] ?? 'غير محدد',
        'isCollected': data['isCollected'] ?? false,
        'collectedAt': (data['collectedAt'] as Timestamp?)?.toDate(),
      });
    }

    if (mounted) {
      setState(() {
        _companyInvoices = invoicesList;
        if (invoicesSnapshot.docs.length < _invoicesPageSize) {
          _hasMoreInvoices = false;
        }
      });
    }
  }

  // ================================
  // تحميل بيانات الشركات مع الإحصائيات (متحسن)
  // ================================

  Future<void> _loadCompaniesOptimized() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      // تحميل البيانات مع cache (للسرعة)
      final companiesSnapshot = await _firestore
          .collection('companies')
          .get(const GetOptions(source: Source.cache))
          .then((snapshot) => snapshot)
          .catchError((_) => _firestore.collection('companies').get());

      final dailyWorkSnapshot = await _firestore
          .collection('dailyWork')
          .limit(1000)
          .get(const GetOptions(source: Source.cache))
          .then((snapshot) => snapshot)
          .catchError(
            (_) => _firestore.collection('dailyWork').limit(1000).get(),
          );

      // استخدام Map لتجميع الرحلات
      final Map<String, List<Map<String, dynamic>>> tripsByCompany = {};

      for (final doc in dailyWorkSnapshot.docs) {
        final data = doc.data();
        final companyId = data['companyId'] as String?;
        if (companyId != null) {
          if (!tripsByCompany.containsKey(companyId)) {
            tripsByCompany[companyId] = [];
          }
          tripsByCompany[companyId]!.add(data);
        }
      }

      final List<Map<String, dynamic>> companiesList = [];

      // معالجة كل شركة
      for (final companyDoc in companiesSnapshot.docs) {
        final companyData = companyDoc.data();
        final companyId = companyDoc.id;
        final companyName =
            (companyData['name'] ??
                    companyData['companyName'] ??
                    'شركة غير معروفة')
                .toString()
                .trim();

        final companyTrips = tripsByCompany[companyId] ?? [];

        // حساب الإجماليات
        double totalNolon = 0.0;
        double totalOvernight = 0.0;
        double totalHoliday = 0.0;

        for (var trip in companyTrips) {
          totalNolon += (trip['noLon'] ?? trip['nolon'] ?? 0).toDouble();
          totalOvernight += (trip['companyOvernight'] ?? 0).toDouble();
          totalHoliday += (trip['companyHoliday'] ?? 0).toDouble();
        }

        // حفظ في cache
        _companyStatsCache[companyId] = {
          'totalTrips': companyTrips.length,
          'totalNolon': totalNolon,
          'totalOvernight': totalOvernight,
          'totalHoliday': totalHoliday,
        };

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
          _isInitialLoadComplete = true;
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
    }
  }
  // Future<void> _loadCompaniesOptimized() async {
  //   if (mounted) {
  //     setState(() => _isLoading = true);
  //   }

  //   try {
  //     // تحميل البيانات مع cache
  //     final companiesSnapshot = await _firestore
  //         .collection('companies')
  //         .get(const GetOptions(source: Source.cache))
  //         .then((snapshot) => snapshot)
  //         .catchError((_) => _firestore.collection('companies').get());

  //     final dailyWorkSnapshot = await _firestore
  //         .collection('dailyWork')
  //         .limit(1000)
  //         .get(const GetOptions(source: Source.cache))
  //         .then((snapshot) => snapshot)
  //         .catchError(
  //           (_) => _firestore.collection('dailyWork').limit(1000).get(),
  //         );

  //     // استخدام Map لتجميع الرحلات
  //     final Map<String, List<Map<String, dynamic>>> tripsByCompany = {};

  //     for (final doc in dailyWorkSnapshot.docs) {
  //       final data = doc.data();
  //       final companyId = data['companyId'] as String?;
  //       if (companyId != null) {
  //         if (!tripsByCompany.containsKey(companyId)) {
  //           tripsByCompany[companyId] = [];
  //         }
  //         tripsByCompany[companyId]!.add(data);
  //       }
  //     }

  //     final List<Map<String, dynamic>> companiesList = [];

  //     // معالجة كل شركة
  //     for (final companyDoc in companiesSnapshot.docs) {
  //       final companyData = companyDoc.data();
  //       final companyId = companyDoc.id;
  //       final companyName =
  //           (companyData['name'] ??
  //                   companyData['companyName'] ??
  //                   'شركة غير معروفة')
  //               .toString()
  //               .trim();

  //       final companyTrips = tripsByCompany[companyId] ?? [];

  //       // حساب الإجماليات
  //       double totalNolon = 0.0;
  //       double totalOvernight = 0.0;
  //       double totalHoliday = 0.0;

  //       for (var trip in companyTrips) {
  //         totalNolon += (trip['noLon'] ?? trip['nolon'] ?? 0).toDouble();
  //         totalOvernight += (trip['companyOvernight'] ?? 0).toDouble();
  //         totalHoliday += (trip['companyHoliday'] ?? 0).toDouble();
  //       }

  //       // حفظ في cache
  //       _companyStatsCache[companyId] = {
  //         'totalTrips': companyTrips.length,
  //         'totalNolon': totalNolon,
  //         'totalOvernight': totalOvernight,
  //         'totalHoliday': totalHoliday,
  //       };

  //       companiesList.add({
  //         'companyId': companyId,
  //         'companyName': companyName,
  //         'companyData': companyData,
  //         'totalTrips': companyTrips.length,
  //         'totalNolon': totalNolon,
  //         'totalOvernight': totalOvernight,
  //         'totalHoliday': totalHoliday,
  //       });
  //     }

  //     companiesList.sort(
  //       (a, b) => a['companyName'].compareTo(b['companyName']),
  //     );

  //     if (mounted) {
  //       setState(() {
  //         _allCompanies = companiesList;
  //         _filteredCompanies = _applySearchFilter(companiesList);
  //         _isLoading = false;
  //         _isInitialLoadComplete = true;
  //       });
  //     }

  //     // تحديث تلقائي عند دخول الصفحة الرئيسية فقط
  //     if (!_hasSyncedOnEnter && _selectedCompany == null) {
  //       await _syncDataOnPageEnter();
  //       _hasSyncedOnEnter = true;
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() => _isLoading = false);
  //     }
  //     debugPrint('خطأ في تحميل بيانات الشركات: $e');
  //   }
  // }

  // ================================
  // تحميل قائمة ID الرحلات المفوتورة فقط (سريع)
  // ================================
  Future<List<String>> _loadInvoicedTripIds(String companyId) async {
    // التحقق من cache أولاً
    if (_invoicedTripIdsCache.containsKey(companyId)) {
      return _invoicedTripIdsCache[companyId]!;
    }

    try {
      // استعلام بسيط للحصول على tripIds فقط
      final invoicesSnapshot = await _firestore
          .collection('invoices')
          .where('companyId', isEqualTo: companyId)
          .get(const GetOptions(source: Source.cache))
          .then((snapshot) => snapshot)
          .catchError(
            (_) => _firestore
                .collection('invoices')
                .where('companyId', isEqualTo: companyId)
                .get(),
          );

      final List<String> invoicedTripIds = [];

      for (final doc in invoicesSnapshot.docs) {
        final data = doc.data();
        final tripIds = (data['tripIds'] as List<dynamic>? ?? []);
        for (var tripId in tripIds) {
          invoicedTripIds.add(tripId.toString());
        }
      }

      // حفظ في cache
      _invoicedTripIdsCache[companyId] = invoicedTripIds;

      return invoicedTripIds;
    } catch (e) {
      debugPrint('خطأ في تحميل ID الرحلات المفوتورة: $e');
      return [];
    }
  }

  // ================================
  // تحميل بيانات الشركة المختارة (متحسن)
  // ================================

  Future<void> _loadCompanyData(String companyName, String companyId) async {
    // دائماً تحميل من الشبكة أولاً
    await _clearCompanyCache(companyId);

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
        _tripsCurrentPage = 0;
        _invoicesCurrentPage = 0;
        _hasMoreTrips = true;
        _hasMoreInvoices = true;
      });
    }

    try {
      // تحميل قائمة ID الرحلات المفوتورة من الشبكة فقط
      final invoicedTripIds = await _loadInvoicedTripIdsFromNetwork(companyId);

      // ثم تحميل الرحلات من الشبكة فقط
      await _loadCompanyTripsFromNetwork(
        companyId,
        companyName,
        invoicedTripIds,
      );

      // أخيراً تحميل تفاصيل الفواتير من الشبكة فقط
      await _loadCompanyInvoicesFromNetwork(companyId);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // حفظ في cache بعد التحميل من الشبكة
      _companyWorkCache[companyId] = List.from(_companyWork);
      _companyInvoicesCache[companyId] = List.from(_companyInvoices);
      _availableTripsCache[companyId] = List.from(_availableTripsForInvoice);
      _invoicedTripIdsCache[companyId] = List.from(invoicedTripIds);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      _showError('خطأ في تحميل بيانات الشركة: $e');
    }
  }

  Future<List<String>> _loadInvoicedTripIdsFromNetwork(String companyId) async {
    try {
      final invoicesSnapshot = await _firestore
          .collection('invoices')
          .where('companyId', isEqualTo: companyId)
          .get(GetOptions(source: Source.server));

      final List<String> invoicedTripIds = [];

      for (final doc in invoicesSnapshot.docs) {
        final data = doc.data();
        final tripIds = (data['tripIds'] as List<dynamic>? ?? []);
        for (var tripId in tripIds) {
          invoicedTripIds.add(tripId.toString());
        }
      }

      return invoicedTripIds;
    } catch (e) {
      debugPrint('خطأ في تحميل ID الرحلات المفوتورة من الشبكة: $e');
      return [];
    }
  }

  Future<void> _loadCompanyTripsFromNetwork(
    String companyId,
    String companyName,
    List<String> invoicedTripIds,
  ) async {
    final workSnapshot = await _firestore
        .collection('dailyWork')
        .where('companyId', isEqualTo: companyId)
        .orderBy('date', descending: false)
        .limit(_tripsPageSize)
        .get(GetOptions(source: Source.server));

    final List<Map<String, dynamic>> allTrips = [];

    for (final doc in workSnapshot.docs) {
      final data = doc.data();
      final tripDate = (data['date'] as Timestamp?)?.toDate();
      final tripId = doc.id;

      final hasInvoice = invoicedTripIds.contains(tripId);

      allTrips.add({
        'id': tripId,
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
        'hasInvoice': hasInvoice,
      });
    }

    final sortedAvailableTrips = _sortAndGroupTripsForInvoice(
      allTrips.where((trip) => !trip['hasInvoice']).toList(),
    );

    if (mounted) {
      setState(() {
        _companyWork = allTrips;
        _availableTripsForInvoice = sortedAvailableTrips;
        if (workSnapshot.docs.length < _tripsPageSize) {
          _hasMoreTrips = false;
        }
      });
    }
  }

  Future<void> _loadCompanyInvoicesFromNetwork(String companyId) async {
    final invoicesSnapshot = await _firestore
        .collection('invoices')
        .where('companyId', isEqualTo: companyId)
        .orderBy('createdAt', descending: true)
        .limit(_invoicesPageSize)
        .get(GetOptions(source: Source.server));

    final List<Map<String, dynamic>> invoicesList = [];

    for (final doc in invoicesSnapshot.docs) {
      final data = doc.data();
      final tripIds = (data['tripIds'] as List<dynamic>? ?? []);

      List<Map<String, dynamic>> invoiceTrips = [];
      double totalNolon = 0;
      double totalOvernight = 0;
      double totalHoliday = 0;
      double totalKartaValue = 0;

      for (var tripId in tripIds) {
        try {
          final tripDoc = await _firestore
              .collection('dailyWork')
              .doc(tripId.toString())
              .get(GetOptions(source: Source.server));

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
              'selectedRoute': tripData['selectedRoute'] ?? '',
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
        } catch (e) {
          debugPrint('خطأ في جلب تفاصيل الرحلة $tripId: $e');
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
        'notes': data['notes'] ?? '',
        'month': data['month'] ?? 'غير محدد',
        'isCollected': data['isCollected'] ?? false,
        'collectedAt': (data['collectedAt'] as Timestamp?)?.toDate(),
      });
    }

    if (mounted) {
      setState(() {
        _companyInvoices = invoicesList;
        if (invoicesSnapshot.docs.length < _invoicesPageSize) {
          _hasMoreInvoices = false;
        }
      });
    }
  }

  Future<void> _clearCompanyCache(String companyId) async {
    _companyWorkCache.remove(companyId);
    _companyInvoicesCache.remove(companyId);
    _availableTripsCache.remove(companyId);
    _invoicedTripIdsCache.remove(companyId);
  }
  // Future<void> _loadCompanyData(String companyName, String companyId) async {
  //   // التحقق من cache
  //   if (_companyWorkCache.containsKey(companyId) &&
  //       _companyInvoicesCache.containsKey(companyId) &&
  //       _availableTripsCache.containsKey(companyId)) {
  //     if (mounted) {
  //       setState(() {
  //         _selectedCompany = companyName;
  //         _selectedCompanyId = companyId;
  //         _companyWork = _companyWorkCache[companyId]!;
  //         _availableTripsForInvoice = _availableTripsCache[companyId]!;
  //         _companyInvoices = _companyInvoicesCache[companyId]!;
  //         _isLoading = false;
  //       });
  //     }
  //     return;
  //   }

  //   if (mounted) {
  //     setState(() {
  //       _selectedCompany = companyName;
  //       _selectedCompanyId = companyId;
  //       _isLoading = true;
  //       _companyWork.clear();
  //       _availableTripsForInvoice.clear();
  //       _companyInvoices.clear();
  //       _selectedTripsForInvoice.clear();
  //       _invoiceNameController.clear();
  //       _invoiceNotesController.clear();
  //       _tripsCurrentPage = 0;
  //       _invoicesCurrentPage = 0;
  //       _hasMoreTrips = true;
  //       _hasMoreInvoices = true;
  //     });
  //   }

  //   try {
  //     // تحميل قائمة ID الرحلات المفوتورة أولاً (سريع)
  //     final invoicedTripIds = await _loadInvoicedTripIds(companyId);

  //     // ثم تحميل الرحلات مع تحديث الحالة مباشرة
  //     await _loadCompanyTrips(companyId, companyName, invoicedTripIds);

  //     // أخيراً تحميل تفاصيل الفواتير الكاملة
  //     await _loadCompanyInvoices(companyId);

  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }

  //     // حفظ في cache
  //     _companyWorkCache[companyId] = List.from(_companyWork);
  //     _companyInvoicesCache[companyId] = List.from(_companyInvoices);
  //     _availableTripsCache[companyId] = List.from(_availableTripsForInvoice);
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() => _isLoading = false);
  //     }
  //     _showError('خطأ في تحميل بيانات الشركة: $e');
  //   }
  // }

  Future<void> _loadCompanyTrips(
    String companyId,
    String companyName,
    List<String> invoicedTripIds,
  ) async {
    // جلب الرحلات مع pagination
    final workSnapshot = await _firestore
        .collection('dailyWork')
        .where('companyId', isEqualTo: companyId)
        .orderBy('date', descending: false)
        .limit(_tripsPageSize)
        .get(const GetOptions(source: Source.cache))
        .then((snapshot) => snapshot)
        .catchError(
          (_) => _firestore
              .collection('dailyWork')
              .where('companyId', isEqualTo: companyId)
              .orderBy('date', descending: false)
              .limit(_tripsPageSize)
              .get(),
        );

    final List<Map<String, dynamic>> allTrips = [];

    for (final doc in workSnapshot.docs) {
      final data = doc.data();
      final tripDate = (data['date'] as Timestamp?)?.toDate();
      final tripId = doc.id;

      // تحديث الحالة مباشرة باستخدام invoicedTripIds
      final hasInvoice = invoicedTripIds.contains(tripId);

      allTrips.add({
        'id': tripId,
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
        'hasInvoice': hasInvoice, // تحديث مباشر
      });
    }

    // تحديث الرحلات المتاحة للفاتورة
    final sortedAvailableTrips = _sortAndGroupTripsForInvoice(
      allTrips.where((trip) => !trip['hasInvoice']).toList(),
    );

    if (mounted) {
      setState(() {
        _companyWork = allTrips;
        _availableTripsForInvoice = sortedAvailableTrips;
        if (workSnapshot.docs.length < _tripsPageSize) {
          _hasMoreTrips = false;
        }
      });
    }
  }

  Future<void> _loadCompanyInvoices(String companyId) async {
    // جلب الفواتير مع pagination
    final invoicesSnapshot = await _firestore
        .collection('invoices')
        .where('companyId', isEqualTo: companyId)
        .orderBy('createdAt', descending: true)
        .limit(_invoicesPageSize)
        .get(const GetOptions(source: Source.cache))
        .then((snapshot) => snapshot)
        .catchError(
          (_) => _firestore
              .collection('invoices')
              .where('companyId', isEqualTo: companyId)
              .orderBy('createdAt', descending: true)
              .limit(_invoicesPageSize)
              .get(),
        );

    final List<Map<String, dynamic>> invoicesList = [];

    for (final doc in invoicesSnapshot.docs) {
      final data = doc.data();
      final tripIds = (data['tripIds'] as List<dynamic>? ?? []);

      List<Map<String, dynamic>> invoiceTrips = [];
      double totalNolon = 0;
      double totalOvernight = 0;
      double totalHoliday = 0;
      double totalKartaValue = 0;

      // استخدام الرحلات المحملة مسبقاً من _companyWork إذا كانت موجودة
      for (var tripId in tripIds) {
        // البحث في الرحلات المحملة مسبقاً
        final existingTrip = _companyWork.firstWhere(
          (trip) => trip['id'] == tripId.toString(),
          orElse: () => {},
        );

        if (existingTrip.isNotEmpty) {
          final karta = existingTrip['karta']?.toString() ?? '';
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
            'selectedRoute': existingTrip['selectedRoute'] ?? '',
            'selectedRoute2': existingTrip['selectedRoute2'] ?? '',
            'vehicleType': existingTrip['vehicleType'] ?? '',
            'nolon': existingTrip['nolon'] ?? 0,
            'companyOvernight': existingTrip['companyOvernight'] ?? 0,
            'companyHoliday': existingTrip['companyHoliday'] ?? 0,
            'tr': existingTrip['tr'] ?? '',
            'companyLocationName': existingTrip['companyLocationName'] ?? '',
            'date': existingTrip['date'],
            'karta': karta,
            'kartaValue': kartaValue,
          });

          totalNolon += existingTrip['nolon'] ?? 0;
          totalOvernight += existingTrip['companyOvernight'] ?? 0;
          totalHoliday += existingTrip['companyHoliday'] ?? 0;
        } else {
          // إذا لم توجد الرحلة في cache، جلبها من Firestore
          try {
            final tripDoc = await _firestore
                .collection('dailyWork')
                .doc(tripId.toString())
                .get(const GetOptions(source: Source.cache))
                .then((snapshot) => snapshot)
                .catchError(
                  (_) => _firestore
                      .collection('dailyWork')
                      .doc(tripId.toString())
                      .get(),
                );

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
                'selectedRoute': tripData['selectedRoute'] ?? '',
                'selectedRoute2': tripData['unloadingLocation'] ?? '',
                'vehicleType': tripData['selectedVehicleType'] ?? '',
                'nolon': (tripData['noLon'] ?? tripData['nolon'] ?? 0)
                    .toDouble(),
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
          } catch (e) {
            debugPrint('خطأ في جلب تفاصيل الرحلة $tripId: $e');
          }
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
        'notes': data['notes'] ?? '',
        'month': data['month'] ?? 'غير محدد',
        'isCollected': data['isCollected'] ?? false,
        'collectedAt': (data['collectedAt'] as Timestamp?)?.toDate(),
      });
    }

    if (mounted) {
      setState(() {
        _companyInvoices = invoicesList;
        if (invoicesSnapshot.docs.length < _invoicesPageSize) {
          _hasMoreInvoices = false;
        }
      });
    }
  }

  // ================================
  // الحصول على حالة نظام TR للشركة (مع cache)
  // ================================
  Future<bool> _getCompanyTRStatus(String companyId) async {
    if (_companyTRStatusCache.containsKey(companyId)) {
      return _companyTRStatusCache[companyId]!;
    }

    try {
      final companyDoc = await _firestore
          .collection('companies')
          .doc(companyId)
          .get(const GetOptions(source: Source.cache))
          .then((snapshot) => snapshot)
          .catchError(
            (_) => _firestore.collection('companies').doc(companyId).get(),
          );

      if (companyDoc.exists) {
        final data = companyDoc.data() as Map<String, dynamic>;
        x = data['commercialRegister'];
        xx = data['taxCard'];
        final status = data['usesTRSystem'] ?? false;

        _companyTRStatusCache[companyId] = status;
        return status;
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

    trips.sort((a, b) {
      final dateA = a['date'] as DateTime? ?? DateTime(1900);
      final dateB = b['date'] as DateTime? ?? DateTime(1900);
      return dateA.compareTo(dateB);
    });

    final Map<String, List<Map<String, dynamic>>> groupedTrips = {};

    for (var trip in trips) {
      final date = trip['date'] as DateTime?;
      final tr = trip['tr']?.toString() ?? '';
      final dateKey = date != null
          ? DateFormat('yyyy-MM-dd').format(date)
          : 'unknown_date';
      final key = '$dateKey|$tr';

      if (!groupedTrips.containsKey(key)) {
        groupedTrips[key] = [];
      }
      groupedTrips[key]!.add(trip);
    }

    final List<Map<String, dynamic>> result = [];
    final sortedKeys = groupedTrips.keys.toList()
      ..sort((a, b) {
        final datePartA = a.split('|')[0];
        final datePartB = b.split('|')[0];
        return datePartA.compareTo(datePartB);
      });

    for (var key in sortedKeys) {
      final tripsInGroup = groupedTrips[key]!;
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
  // فلترة الفواتير حسب الشهر والسنة وحالة التحصيل
  // ================================
  List<Map<String, dynamic>> _getFilteredInvoices(bool collected) {
    List<Map<String, dynamic>> filtered = _companyInvoices.where((invoice) {
      return invoice['isCollected'] == collected;
    }).toList();

    if (_selectedMonthFilter != 'كل الشهور') {
      filtered = filtered.where((invoice) {
        final month = invoice['month'] ?? 'غير محدد';
        return month == _selectedMonthFilter;
      }).toList();
    }

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
  List<Map<String, dynamic>> _getFilteredTrips(
    List<Map<String, dynamic>> trips,
  ) {
    return trips.where((trip) {
      final date = trip['date'] as DateTime?;
      if (date == null) return false;

      bool matchesYear = true;
      bool matchesMonth = true;

      if (_selectedYear != null) {
        matchesYear = date.year.toString() == _selectedYear;
      }

      if (_selectedMonthWork != null) {
        final monthIndex = _monthsList.indexOf(_selectedMonthWork);
        if (monthIndex != -1) {
          matchesMonth = date.month == (monthIndex + 1);
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

      // استخدام batch للعمليات المتعددة
      final batch = _firestore.batch();
      final invoiceRef = _firestore.collection('invoices').doc();

      final invoiceData = {
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
        'notes': _invoiceNotesController.text.trim(),
        'month': _selectedMonth,
        'isCollected': false,
        'createdAt': Timestamp.now(),
        'status': 'غير مدفوعة',
      };

      batch.set(invoiceRef, invoiceData);

      for (var tripId in tripIds) {
        batch.update(_firestore.collection('dailyWork').doc(tripId), {
          'hasInvoice': true,
        });
      }

      await batch.commit();

      // تحديث cache مباشرة
      if (_companyWorkCache.containsKey(_selectedCompanyId!)) {
        // تحديث حالة الرحلات في cache
        for (var trip in _companyWorkCache[_selectedCompanyId!]!) {
          if (tripIds.contains(trip['id'])) {
            trip['hasInvoice'] = true;
          }
        }

        // تحديث الرحلات المتاحة في cache
        _availableTripsCache[_selectedCompanyId!] =
            _companyWorkCache[_selectedCompanyId!]!
                .where((trip) => !trip['hasInvoice'])
                .toList();
      }

      // تحديث قائمة invoicedTripIds في cache
      if (_invoicedTripIdsCache.containsKey(_selectedCompanyId!)) {
        _invoicedTripIdsCache[_selectedCompanyId!]!.addAll(tripIds);
      } else {
        _invoicedTripIdsCache[_selectedCompanyId!] = List.from(tripIds);
      }

      // إضافة الفاتورة الجديدة مباشرة إلى قائمة الفواتير المحلية
      final newInvoice = {
        'id': invoiceRef.id,
        'name': _invoiceNameController.text.trim(),
        'companyName': _selectedCompany!,
        'companyId': _selectedCompanyId!,
        'totalAmount': totalAmount,
        'createdAt': DateTime.now(),
        'tripIds': tripIds,
        'tripCount': tripIds.length,
        'invoiceTrips': invoiceTripDetails,
        'nolonTotal': totalNolon,
        'overnightTotal': totalOvernight,
        'holidayTotal': totalHoliday,
        'kartaDetails': _selectedTripsForInvoice
            .map((trip) => trip['karta'] ?? '')
            .toList(),
        'kartaValue': totalKartaValue,
        'totalWithKarta': totalAmount + totalKartaValue,
        'notes': _invoiceNotesController.text.trim(),
        'month': _selectedMonth,
        'isCollected': false,
        'collectedAt': null,
      };

      // تحديث UI مباشرة
      if (mounted) {
        setState(() {
          // تحديث الرحلات المحلية
          for (var trip in _companyWork) {
            if (tripIds.contains(trip['id'])) {
              trip['hasInvoice'] = true;
            }
          }

          // تحديث الرحلات المتاحة للفاتورة
          _availableTripsForInvoice = _availableTripsForInvoice
              .where((trip) => !tripIds.contains(trip['id']))
              .toList();

          // إضافة الفاتورة الجديدة إلى قائمة الفواتير
          _companyInvoices.insert(0, newInvoice);

          // تحديث cache للفواتير
          if (_companyInvoicesCache.containsKey(_selectedCompanyId!)) {
            _companyInvoicesCache[_selectedCompanyId!]!.insert(0, newInvoice);
          }
        });
      }

      _showSuccess('تم إنشاء الفاتورة بنجاح');

      // تحديث حساب الشركة في الخلفية
      _updateCompanySummaryAfterInvoice(totalAmount);

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
  // تحديث قائمة الفواتير بعد التغييرات
  // ================================
  Future<void> _refreshInvoices() async {
    if (_selectedCompanyId == null) return;

    try {
      // تحديث الفواتير مباشرة دون إعادة تحميل كامل الصفحة
      await _loadCompanyInvoices(_selectedCompanyId!);

      _showSuccess('تم تحديث الفواتير');
    } catch (e) {
      debugPrint('خطأ في تحديث الفواتير: $e');
    }
  }

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

  //       // استخدام batch للعمليات المتعددة
  //       final batch = _firestore.batch();
  //       final invoiceRef = _firestore.collection('invoices').doc();

  //       batch.set(invoiceRef, {
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
  //         'notes': _invoiceNotesController.text.trim(),
  //         'month': _selectedMonth,
  //         'isCollected': false,
  //         'createdAt': Timestamp.now(),
  //         'status': 'غير مدفوعة',
  //       });

  //       for (var tripId in tripIds) {
  //         batch.update(_firestore.collection('dailyWork').doc(tripId), {
  //           'hasInvoice': true,
  //         });
  //       }

  //       await batch.commit();

  //       // تحديث cache مباشرة
  //       if (_companyWorkCache.containsKey(_selectedCompanyId!)) {
  //         // تحديث حالة الرحلات في cache
  //         for (var trip in _companyWorkCache[_selectedCompanyId!]!) {
  //           if (tripIds.contains(trip['id'])) {
  //             trip['hasInvoice'] = true;
  //           }
  //         }

  //         // تحديث الرحلات المتاحة في cache
  //         _availableTripsCache[_selectedCompanyId!] =
  //             _companyWorkCache[_selectedCompanyId!]!
  //                 .where((trip) => !trip['hasInvoice'])
  //                 .toList();
  //       }

  //       // تحديث قائمة invoicedTripIds في cache
  //       if (_invoicedTripIdsCache.containsKey(_selectedCompanyId!)) {
  //         _invoicedTripIdsCache[_selectedCompanyId!]!.addAll(tripIds);
  //       } else {
  //         _invoicedTripIdsCache[_selectedCompanyId!] = List.from(tripIds);
  //       }

  //       // تحديث UI مباشرة
  //       if (mounted) {
  //         setState(() {
  //           // تحديث الرحلات المحلية
  //           for (var trip in _companyWork) {
  //             if (tripIds.contains(trip['id'])) {
  //               trip['hasInvoice'] = true;
  //             }
  //           }

  //           // تحديث الرحلات المتاحة للفاتورة
  //           _availableTripsForInvoice = _availableTripsForInvoice
  //               .where((trip) => !tripIds.contains(trip['id']))
  //               .toList();
  //         });
  //       }

  //       _showSuccess('تم إنشاء الفاتورة بنجاح');

  //       // تحديث حساب الشركة في الخلفية
  //       _updateCompanySummaryAfterInvoice(totalAmount);

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

  // ================================
  // تحديث حالة تحصيل الفاتورة
  // ================================

  // ================================
  // تحميل البيانات من الشبكة فقط (بدون كاش)
  // ================================
  Future<void> _loadDataFromNetworkOnly() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      // مسح كل الكاش أولاً
      _clearAllCache();

      // إجبار Firestore على استخدام الشبكة فقط
      await _firestore.disableNetwork();
      await _firestore.enableNetwork();

      // تحميل الشركات من الشبكة فقط
      final companiesSnapshot = await _firestore
          .collection('companies')
          .get(GetOptions(source: Source.server));

      final dailyWorkSnapshot = await _firestore
          .collection('dailyWork')
          .get(GetOptions(source: Source.server));

      final List<Map<String, dynamic>> companiesList = [];

      final Map<String, List<Map<String, dynamic>>> tripsByCompany = {};

      for (final doc in dailyWorkSnapshot.docs) {
        final data = doc.data();
        final companyId = data['companyId'] as String?;
        if (companyId != null) {
          if (!tripsByCompany.containsKey(companyId)) {
            tripsByCompany[companyId] = [];
          }
          tripsByCompany[companyId]!.add(data);
        }
      }

      for (final companyDoc in companiesSnapshot.docs) {
        final companyData = companyDoc.data();
        final companyId = companyDoc.id;
        final companyName =
            (companyData['name'] ??
                    companyData['companyName'] ??
                    'شركة غير معروفة')
                .toString()
                .trim();

        final companyTrips = tripsByCompany[companyId] ?? [];

        double totalNolon = 0.0;
        double totalOvernight = 0.0;
        double totalHoliday = 0.0;

        for (var trip in companyTrips) {
          totalNolon += (trip['noLon'] ?? trip['nolon'] ?? 0).toDouble();
          totalOvernight += (trip['companyOvernight'] ?? 0).toDouble();
          totalHoliday += (trip['companyHoliday'] ?? 0).toDouble();
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
          _filteredCompanies = companiesList;
          _isLoading = false;
        });
      }

      _showSuccess('تم تحميل أحدث البيانات من السيرفر');
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      _showError('خطأ في تحميل البيانات: $e');
    }
  }

  // ================================
  // مسح كل الكاش وإعادة التحميل
  // ================================
  Future<void> _clearAllCache() async {
    try {
      // مسح كل أنواع الكاش الداخلي
      _companyWorkCache.clear();
      _companyInvoicesCache.clear();
      _availableTripsCache.clear();
      _invoicedTripIdsCache.clear();
      _companyStatsCache.clear();
      _companyTRStatusCache.clear();

      // مسح كاش Firestore
      await _firestore.clearPersistence();

      // إعادة تعيين المتغيرات
      if (mounted) {
        setState(() {
          _allCompanies.clear();
          _filteredCompanies.clear();
          _companyWork.clear();
          _availableTripsForInvoice.clear();
          _companyInvoices.clear();
          _selectedTripsForInvoice.clear();
          _hasSyncedOnEnter = false;
          _isInitialLoadComplete = false;
        });
      }

      debugPrint('✅ تم مسح كل الكاش بنجاح');
    } catch (e) {
      debugPrint('⚠️ خطأ في مسح الكاش: $e');
    }
  }

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

      // تحديث UI مباشرة
      if (mounted) {
        setState(() {
          final invoiceIndex = _companyInvoices.indexWhere(
            (inv) => inv['id'] == invoiceId,
          );
          if (invoiceIndex != -1) {
            _companyInvoices[invoiceIndex]['isCollected'] = isCollected;
            _companyInvoices[invoiceIndex]['collectedAt'] = isCollected
                ? DateTime.now()
                : null;
            _companyInvoices[invoiceIndex]['collectedDate'] = isCollected
                ? DateFormat('dd/MM/yyyy').format(DateTime.now())
                : null;
          }

          // تحديث cache
          if (_companyInvoicesCache.containsKey(_selectedCompanyId!)) {
            final cacheIndex = _companyInvoicesCache[_selectedCompanyId!]!
                .indexWhere((inv) => inv['id'] == invoiceId);
            if (cacheIndex != -1) {
              _companyInvoicesCache[_selectedCompanyId!]![cacheIndex]['isCollected'] =
                  isCollected;
              _companyInvoicesCache[_selectedCompanyId!]![cacheIndex]['collectedAt'] =
                  isCollected ? DateTime.now() : null;
            }
          }
        });
      }

      _showSuccess(
        isCollected ? 'تم تحديد الفاتورة كمحصلة' : 'تم إلغاء تحصيل الفاتورة',
      );
    } catch (e) {
      _showError('خطأ في تحديث حالة الفاتورة: $e');
    }
  }
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

  //       // تحديث UI مباشرة
  //       if (mounted) {
  //         setState(() {
  //           final invoiceIndex = _companyInvoices.indexWhere(
  //             (inv) => inv['id'] == invoiceId,
  //           );
  //           if (invoiceIndex != -1) {
  //             _companyInvoices[invoiceIndex]['isCollected'] = isCollected;
  //             _companyInvoices[invoiceIndex]['collectedAt'] = isCollected
  //                 ? DateTime.now()
  //                 : null;
  //           }

  //           // تحديث cache
  //           if (_companyInvoicesCache.containsKey(_selectedCompanyId!)) {
  //             _companyInvoicesCache[_selectedCompanyId!] = List.from(
  //               _companyInvoices,
  //             );
  //           }
  //         });
  //       }

  //       _showSuccess(
  //         isCollected ? 'تم تحديد الفاتورة كمحصلة' : 'تم إلغاء تحصيل الفاتورة',
  //       );
  //     } catch (e) {
  //       _showError('خطأ في تحديث حالة الفاتورة: $e');
  //     }
  //   }

  // ================================
  // طباعة جميع فواتير الشهر (محصلة أو غير محصلة)
  // ================================
  Future<void> _printMonthInvoices(bool collected) async {
    if (_arabicFont == null && _fontCompleter != null) {
      _arabicFont = await _fontCompleter!.future;
    }

    if (mounted) {
      setState(() => _isGeneratingPDF = true);
    }

    try {
      final invoices = _getFilteredInvoices(collected);

      if (invoices.isEmpty) {
        _showError(
          'لا توجد فواتير ${collected ? 'محصلة' : 'غير محصلة'} للشهر المحدد',
        );
        return;
      }

      double totalInvoices = 0;
      double totalKarta = 0;
      double totalWithKarta = 0;

      for (var invoice in invoices) {
        totalInvoices += invoice['totalAmount'] ?? 0;
        totalKarta += invoice['kartaValue'] ?? 0;
        totalWithKarta += invoice['totalWithKarta'] ?? 0;
      }

      final pdf = pdfLib.Document(
        theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
      );

      pdf.addPage(
        pdfLib.MultiPage(
          pageFormat: pdfLib.PdfPageFormat.a4,
          margin: pdfLib.EdgeInsets.all(20),
          build: (context) => [
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

            _buildReportInfoPdf(
              collected,
              invoices.length,
              totalInvoices,
              totalKarta,
              totalWithKarta,
            ),
            pdfLib.SizedBox(height: 15),

            _buildInvoicesTablePdf(invoices),
            pdfLib.SizedBox(height: 10),

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
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
    _loadCompaniesOptimized();
  }

  Future<void> _printKartaRequest(Map<String, dynamic> invoice) async {
    if (_arabicFont == null && _fontCompleter != null) {
      _arabicFont = await _fontCompleter!.future;
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

      String monthYear = 'غير محدد';
      if (createdAt != null) {
        monthYear = '${createdAt.month}/${createdAt.year}';
      }

      String companyLocation = '';
      for (var trip in trips) {
        final location = trip['companyLocationName']?.toString() ?? '';
        if (location.isNotEmpty) {
          companyLocation = location;
          break;
        }
      }

      if (companyLocation.isEmpty) {
        companyLocation = 'الموقع';
      }

      final List<Map<String, dynamic>> sortedTrips = List.from(trips)
        ..sort((a, b) {
          final dateA = a['date'] as DateTime? ?? DateTime(1900);
          final dateB = b['date'] as DateTime? ?? DateTime(1900);
          return dateA.compareTo(dateB);
        });

      final List<Map<String, dynamic>> tableRows = [];
      double totalKartasValue = 0;
      int rowNumber = 1;

      for (var trip in sortedTrips) {
        final date = trip['date'] as DateTime?;
        final karta = trip['karta']?.toString() ?? '';
        final ohda = trip['ohda']?.toString() ?? '';

        double kartaValue = 0;
        try {
          final cleanedKarta = karta.trim();
          if (cleanedKarta.isNotEmpty) {
            kartaValue = double.tryParse(cleanedKarta) ?? 0;
          }
        } catch (e) {
          debugPrint('خطأ في تحويل الكارتة إلى رقم: $karta');
        }

        totalKartasValue += kartaValue;

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
        pdfLib.TableRow(
          decoration: pdfLib.BoxDecoration(color: pdfLib.PdfColors.grey300),
          children: [
            _kartaTableCell('القيمة', isHeader: true),
            _kartaTableCell('التاريخ', isHeader: true),
            _kartaTableCell('المسلسل', isHeader: true),
          ],
        ),

        ...rows.map(
          (row) => pdfLib.TableRow(
            children: [
              _kartaTableCell(row['karta']?.toString() ?? ''),
              _kartaTableCell(row['date']),
              _kartaTableCell(row['rowNumber']),
            ],
          ),
        ),

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
    if (_arabicFont == null && _fontCompleter != null) {
      _arabicFont = await _fontCompleter!.future;
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
            _buildLogoWidget(),
          ],
        ),
        pdfLib.Divider(),
      ],
    );
  }

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
    if (usesTRSystem) {
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

  // Widget _buildCustomAppBar() {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //     decoration: const BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.centerRight,
  //         end: Alignment.centerLeft,
  //         colors: [Color(0xFF1B4F72), Color(0xFF3498DB)],
  //       ),
  //       boxShadow: [
  //         BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
  //       ],
  //     ),
  //     child: SafeArea(
  //       child: Row(
  //         children: [
  //           IconButton(
  //             icon: Icon(
  //               _selectedCompany == null ? Icons.business : Icons.arrow_back,
  //               color: Colors.white,
  //               size: 28,
  //             ),
  //             onPressed: _selectedCompany != null ? _backToCompanies : null,
  //           ),

  //           const SizedBox(width: 8),

  //           Expanded(
  //             child: Center(
  //               child: Text(
  //                 _selectedCompany == null ? 'اختر شركة' : '$_selectedCompany',
  //                 style: const TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //           ),

  //           if (_selectedCompany == null)
  //             IconButton(
  //               icon: const Icon(Icons.sync, color: Colors.white),
  //               onPressed: _syncDataOnPageEnter,
  //               tooltip: 'مزامنة حسابات الشركات',
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // زر تحديث البيانات
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                if (_selectedCompany == null) {
                  // تحديث قائمة الشركات من السيرفر
                  _refreshFromServer();
                } else {
                  // تحديث بيانات الشركة المحددة من السيرفر
                  _refreshCompanyFromServer();
                }
              },
              tooltip: _selectedCompany == null
                  ? 'تحديث قائمة الشركات من السيرفر'
                  : 'تحديث بيانات الشركة من السيرفر',
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
    if (_isLoading && !_isInitialLoadComplete) {
      return const Center(child: CircularProgressIndicator());
    }

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

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.blue[50],
      child: Row(
        children: [
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

          IconButton(
            icon: Icon(Icons.refresh, color: Color(0xFF3498DB)),
            onPressed: () {
              final now = DateTime.now();
              setState(() {
                _selectedMonthWork = _monthsList[now.month - 1];
                _selectedYear = now.year.toString();
              });
            },
            tooltip: 'إعادة تعيين الفلاتر',
          ),
        ],
      ),
    );
  }

  Widget _buildWorkTable() {
    if (_isLoading && _companyWork.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final filteredTrips = _getFilteredTrips(_companyWork);

    final sortedWork = List<Map<String, dynamic>>.from(filteredTrips)
      ..sort((a, b) {
        final dateA = a['date'] as DateTime? ?? DateTime(1900);
        final dateB = b['date'] as DateTime? ?? DateTime(1900);
        return dateB.compareTo(dateA);
      });

    return Column(
      children: [
        _buildFilterBar(),
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
    if (_isLoading && _availableTripsForInvoice.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

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

  bool get _isMobile {
    final size = MediaQuery.of(context).size;
    return size.width < 600;
  }

  Widget _buildInvoicesSection() {
    if (_isLoading && _companyInvoices.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final notCollectedInvoices = _getFilteredInvoices(false);
    final collectedInvoices = _getFilteredInvoices(true);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(_isMobile ? 12 : 16),
          color: Colors.blue[50],
          child: Column(
            children: [
              if (_isMobile)
                Column(
                  children: [
                    // فلترة الشهر
                    Container(
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
                    const SizedBox(height: 8),

                    // فلترة السنة
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedYearFilter,
                                isExpanded: true,
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
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                )
              else
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
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Icon(Icons.print, size: _isMobile ? 16 : 18),
                      label: Text(
                        _isGeneratingPDF
                            ? 'جاري الطباعة...'
                            : _isMobile
                            ? 'غير محصلة'
                            : 'طباعة فواتير الشهر غير المحصلة',
                        style: TextStyle(fontSize: _isMobile ? 12 : 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: _isMobile ? 8 : 10,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: _isMobile ? 6 : 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isGeneratingPDF
                          ? null
                          : () => _printMonthInvoices(true),
                      icon: _isGeneratingPDF
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Icon(Icons.print, size: _isMobile ? 16 : 18),
                      label: Text(
                        _isGeneratingPDF
                            ? 'جاري الطباعة...'
                            : _isMobile
                            ? 'محصلة'
                            : 'طباعة فواتير الشهر المحصلة',
                        style: TextStyle(fontSize: _isMobile ? 12 : 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: _isMobile ? 8 : 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(_isMobile ? 6 : 8),
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
                          padding: EdgeInsets.symmetric(
                            vertical: _isMobile ? 10 : 12,
                          ),
                          decoration: BoxDecoration(
                            color: _currentInvoiceView == 0
                                ? const Color.fromARGB(255, 254, 21, 0)
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
                                size: _isMobile ? 18 : 20,
                              ),
                              Text(
                                _isMobile
                                    ? 'غير محصلة (${notCollectedInvoices.length})'
                                    : 'غير المحصلة (${notCollectedInvoices.length})',
                                style: TextStyle(
                                  color: _currentInvoiceView == 0
                                      ? Colors.white
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: _isMobile ? 10 : 11,
                                ),
                                textAlign: TextAlign.center,
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
                          padding: EdgeInsets.symmetric(
                            vertical: _isMobile ? 10 : 12,
                          ),
                          decoration: BoxDecoration(
                            color: _currentInvoiceView == 1
                                ? const Color.fromARGB(255, 255, 0, 0)
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
                                size: _isMobile ? 18 : 20,
                              ),
                              Text(
                                _isMobile
                                    ? 'محصلة (${collectedInvoices.length})'
                                    : 'المحصلة (${collectedInvoices.length})',
                                style: TextStyle(
                                  color: _currentInvoiceView == 1
                                      ? Colors.white
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: _isMobile ? 10 : 11,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
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
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(_isMobile ? 4 : 8),
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
      margin: EdgeInsets.symmetric(
        vertical: _isMobile ? 4 : 6,
        horizontal: _isMobile ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: isCollected ? Colors.green[50] : Colors.white,
        borderRadius: BorderRadius.circular(_isMobile ? 8 : 12),
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
          radius: _isMobile ? 16 : 20,
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: _isMobile ? 12 : 14,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    invoice['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: _isMobile ? 14 : 16,
                      color: isCollected
                          ? Colors.green[800]
                          : const Color(0xFF2C3E50),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isCollected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'محصلة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _isMobile ? 8 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '${createdAt != null ? _formatDate(createdAt) : 'غير معروف'}  ---  رحلة >>> ${invoice['tripCount']}',
              style: TextStyle(
                fontSize: _isMobile ? 10 : 12,
                color: isCollected ? Colors.green[600] : Colors.grey,
              ),
            ),
          ],
        ),
        trailing: _isMobile
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _formatCurrency(invoice['totalAmount'] ?? 0),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: _isMobile ? 14 : 16,
                      color: isCollected
                          ? Colors.green[800]
                          : const Color(0xFF2E7D32),
                    ),
                  ),
                  Text(
                    'إجمالي',
                    style: TextStyle(
                      fontSize: _isMobile ? 10 : 12,
                      color: isCollected ? Colors.green[600] : Colors.grey[600],
                    ),
                  ),
                ],
              )
            : Row(
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
                          color: isCollected
                              ? Colors.green[600]
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),

                  IconButton(
                    icon: Icon(
                      isCollected ? Icons.undo : Icons.check_circle,
                      color: isCollected ? Colors.orange : Colors.green,
                      size: _isMobile ? 20 : 24,
                    ),
                    onPressed: () =>
                        _toggleInvoiceCollection(invoice['id'], !isCollected),
                    tooltip: isCollected ? 'إلغاء التحصيل' : 'تم التحصيل',
                  ),

                  IconButton(
                    icon: Icon(
                      Icons.credit_card,
                      color: Color(0xFF9C27B0),
                      size: _isMobile ? 20 : 24,
                    ),
                    onPressed: _isGeneratingPDF
                        ? null
                        : () => _printKartaRequest(invoice),
                    tooltip: 'مطالبة كارتات',
                  ),
                  const SizedBox(width: 5),
                  IconButton(
                    icon: Icon(
                      Icons.print,
                      color: Color(0xFF3498DB),
                      size: _isMobile ? 20 : 24,
                    ),
                    onPressed: _isGeneratingPDF
                        ? null
                        : () => _printInvoice(invoice),
                    tooltip: 'طباعة الفاتورة',
                  ),
                ],
              ),
        children: [
          Padding(
            padding: EdgeInsets.all(_isMobile ? 8 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(_isMobile ? 8 : 12),
                  decoration: BoxDecoration(
                    color: isCollected ? Colors.green[50] : Colors.blue[50],
                    borderRadius: BorderRadius.circular(_isMobile ? 6 : 8),
                  ),
                  child: Column(
                    children: [
                      _buildInvoiceSummaryRow(
                        'عدد الرحلات:',
                        '${invoice['tripCount']}',
                      ),
                      SizedBox(height: _isMobile ? 2 : 4),
                      _buildInvoiceSummaryRow(
                        'إجمالي النولون:',
                        _formatCurrency(invoice['nolonTotal'] ?? 0),
                        color: Colors.green,
                      ),
                      SizedBox(height: _isMobile ? 2 : 4),
                      _buildInvoiceSummaryRow(
                        'إجمالي المبيت:',
                        _formatCurrency(invoice['overnightTotal'] ?? 0),
                        color: Colors.orange,
                      ),
                      SizedBox(height: _isMobile ? 2 : 4),
                      _buildInvoiceSummaryRow(
                        'إجمالي العطلة:',
                        _formatCurrency(invoice['holidayTotal'] ?? 0),
                        color: Colors.red,
                      ),
                      SizedBox(height: _isMobile ? 2 : 4),
                      _buildInvoiceSummaryRow(
                        'قيمة الكارتة:',
                        _formatCurrency(kartaValue),
                        color: Color(0xFF9C27B0),
                      ),
                      SizedBox(height: _isMobile ? 2 : 4),
                      _buildInvoiceSummaryRow(
                        'الإجمالي النهائي:',
                        _formatCurrency(totalWithKarta),
                        color: Color(0xFF2E7D32),
                        isBold: true,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: _isMobile ? 8 : 12),

                if (_isMobile)
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _toggleInvoiceCollection(
                            invoice['id'],
                            !isCollected,
                          ),
                          icon: Icon(
                            isCollected ? Icons.undo : Icons.check_circle,
                            size: 20,
                          ),
                          label: Text(
                            isCollected ? 'إلغاء التحصيل' : ' تحصيل الفاتوره',
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
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
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
                      const SizedBox(height: 8),
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
                  )
                else
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
                            isCollected ? 'إلغاء التحصيل' : ' تحصيل الفاتوره',
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceSummaryRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: _isMobile ? 12 : 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: _isMobile ? 12 : 14,
            color: color ?? Colors.black,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class TableCellHeader extends StatelessWidget {
  final String text;
  const TableCellHeader(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      height: isMobile ? 35 : 40,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: isMobile ? 10 : 12,
          color: const Color(0xFF2C3E50),
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      height: isMobile ? 32 : 38,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: textStyle ?? TextStyle(fontSize: isMobile ? 10 : 12),
      ),
    );
  }
}
