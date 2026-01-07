// // // import 'dart:async';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:intl/intl.dart';

// // // class MonthlyProfitsPage extends StatefulWidget {
// // //   const MonthlyProfitsPage({super.key});

// // //   @override
// // //   State<MonthlyProfitsPage> createState() => _MonthlyProfitsPageState();
// // // }

// // // class _MonthlyProfitsPageState extends State<MonthlyProfitsPage> {
// // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// // //   // ================================
// // //   // بيانات الشهر الحالي
// // //   // ================================
// // //   int _selectedYear = DateTime.now().year;
// // //   int _selectedMonth = DateTime.now().month;
// // //   String _selectedMonthName = '';

// // //   // ================================
// // //   // إجماليات الشهر
// // //   // ================================
// // //   double _totalCompanyIncome = 0.0; // إجمالي دخل الشركات
// // //   double _totalDriversExpenses = 0.0; // إجمالي حساب السائقين
// // //   double _totalTaxes = 0.0; // إجمالي الضرائب
// // //   double _netProfit = 0.0; // صافي الربح (الدخل - السائقين - الضرائب)

// // //   // ================================
// // //   // بيانات الشركات المنفصلة
// // //   // ================================
// // //   List<Map<String, dynamic>> _companyProfits = [];

// // //   // ================================
// // //   // بيانات الشركاء والتوزيع
// // //   // ================================
// // //   List<Map<String, dynamic>> _partners = [];
// // //   double _totalDistributed = 0.0;
// // //   double _remainingProfit = 0.0;
// // //   bool _isDistributionCompleted = false;

// // //   // ================================
// // //   // Controllers
// // //   // ================================
// // //   final TextEditingController _partnerNameController = TextEditingController();
// // //   final TextEditingController _partnerPercentageController =
// // //       TextEditingController();
// // //   final TextEditingController _editPartnerNameController =
// // //       TextEditingController();
// // //   final TextEditingController _editPartnerPercentageController =
// // //       TextEditingController();

// // //   // ================================
// // //   // متغيرات التحكم
// // //   // ================================
// // //   bool _isLoading = false;
// // //   bool _showAddPartnerForm = false;
// // //   Map<String, dynamic>? _editingPartner;
// // //   int _currentTab = 0;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _selectedMonthName = _getMonthName(_selectedMonth);
// // //     _loadAllData();
// // //   }

// // //   // ================================
// // //   // تحميل كل البيانات
// // //   // ================================
// // //   Future<void> _loadAllData() async {
// // //     if (mounted) {
// // //       setState(() => _isLoading = true);
// // //     }

// // //     try {
// // //       await _calculateMonthlyTotals();
// // //       await _loadCompanyProfits();
// // //       await _loadPartners();
// // //       _calculateDistribution();
// // //     } catch (e) {
// // //       print('خطأ في تحميل البيانات: $e');
// // //       _showError('خطأ في تحميل البيانات');
// // //     } finally {
// // //       if (mounted) {
// // //         setState(() => _isLoading = false);
// // //       }
// // //     }
// // //   }

// // //   // ================================
// // //   // حساب إجماليات الشهر
// // //   // ================================
// // //   Future<void> _calculateMonthlyTotals() async {
// // //     try {
// // //       double totalCompanyIncome = 0;
// // //       double totalDriversExpenses = 0;
// // //       double totalTaxes = 0;

// // //       // ================================
// // //       // 1. حساب إجمالي دخل الشركات من dailyWork
// // //       // ================================
// // //       final companySnapshot = await _firestore
// // //           .collection('dailyWork')
// // //           .where(
// // //             'date',
// // //             isGreaterThanOrEqualTo: Timestamp.fromDate(
// // //               DateTime(_selectedYear, _selectedMonth, 1),
// // //             ),
// // //           )
// // //           .where(
// // //             'date',
// // //             isLessThan: Timestamp.fromDate(
// // //               DateTime(_selectedYear, _selectedMonth + 1, 1),
// // //             ),
// // //           )
// // //           .get();

// // //       for (var doc in companySnapshot.docs) {
// // //         final data = doc.data();

// // //         // دخل الشركة من الرحلات
// // //         final nolon = (data['nolon'] ?? data['noLon'] ?? 0).toDouble();
// // //         final companyOvernight = (data['companyOvernight'] ?? 0).toDouble();
// // //         final companyHoliday = (data['companyHoliday'] ?? 0).toDouble();

// // //         totalCompanyIncome += nolon + companyOvernight + companyHoliday;
// // //       }

// // //       // ================================
// // //       // 2. حساب إجمالي حساب السائقين
// // //       // ================================
// // //       final driversSnapshot = await _firestore
// // //           .collection('drivers')
// // //           .where(
// // //             'date',
// // //             isGreaterThanOrEqualTo: Timestamp.fromDate(
// // //               DateTime(_selectedYear, _selectedMonth, 1),
// // //             ),
// // //           )
// // //           .where(
// // //             'date',
// // //             isLessThan: Timestamp.fromDate(
// // //               DateTime(_selectedYear, _selectedMonth + 1, 1),
// // //             ),
// // //           )
// // //           .get();

// // //       for (var doc in driversSnapshot.docs) {
// // //         final data = doc.data();

// // //         // حساب السائقين
// // //         final wheelNolon = (data['wheelNolon'] ?? 0).toDouble();
// // //         final wheelOvernight = (data['wheelOvernight'] ?? 0).toDouble();
// // //         final wheelHoliday = (data['wheelHoliday'] ?? 0).toDouble();

// // //         totalDriversExpenses += wheelNolon + wheelOvernight + wheelHoliday;
// // //       }

// // //       // ================================
// // //       // 3. حساب إجمالي الضرائب الشهرية من الفواتير
// // //       // ================================
// // //       // الحصول على أول وآخر يوم من الشهر
// // //       final firstDayOfMonth = DateTime(_selectedYear, _selectedMonth, 1);
// // //       final lastDayOfMonth = DateTime(_selectedYear, _selectedMonth + 1, 0);

// // //       // جلب جميع الفواتير في هذا الشهر
// // //       final invoicesSnapshot = await _firestore
// // //           .collection('invoices')
// // //           .where(
// // //             'createdAt',
// // //             isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth),
// // //           )
// // //           .where(
// // //             'createdAt',
// // //             isLessThanOrEqualTo: Timestamp.fromDate(
// // //               lastDayOfMonth.add(const Duration(days: 1)),
// // //             ),
// // //           )
// // //           .get();

// // //       // حساب الضرائب من الفواتير
// // //       for (var doc in invoicesSnapshot.docs) {
// // //         final data = doc.data();

// // //         // إذا كان للفاتورة ضرائب مفعلة
// // //         if (data['has3PercentTax'] == true || data['has14PercentTax'] == true) {
// // //           final tax3Percent = (data['tax3Percent'] ?? 0).toDouble();
// // //           final tax14Percent = (data['tax14Percent'] ?? 0).toDouble();

// // //           totalTaxes += tax3Percent + tax14Percent;
// // //         }
// // //       }

// // //       // ================================
// // //       // 4. حساب صافي الربح
// // //       // ================================
// // //       final netProfit = totalCompanyIncome - totalDriversExpenses - totalTaxes;

// // //       if (mounted) {
// // //         setState(() {
// // //           _totalCompanyIncome = totalCompanyIncome;
// // //           _totalDriversExpenses = totalDriversExpenses;
// // //           _totalTaxes = totalTaxes;
// // //           _netProfit = netProfit;
// // //         });
// // //       }
// // //     } catch (e) {
// // //       print('خطأ في حساب الإجماليات: $e');
// // //       throw e;
// // //     }
// // //   }

// // //   // ================================
// // //   // تحميل أرباح كل شركة منفصلة
// // //   // ================================
// // //   Future<void> _loadCompanyProfits() async {
// // //     try {
// // //       // جلب جميع الرحلات لهذا الشهر
// // //       final snapshot = await _firestore
// // //           .collection('dailyWork')
// // //           .where(
// // //             'date',
// // //             isGreaterThanOrEqualTo: Timestamp.fromDate(
// // //               DateTime(_selectedYear, _selectedMonth, 1),
// // //             ),
// // //           )
// // //           .where(
// // //             'date',
// // //             isLessThan: Timestamp.fromDate(
// // //               DateTime(_selectedYear, _selectedMonth + 1, 1),
// // //             ),
// // //           )
// // //           .get();

// // //       Map<String, Map<String, dynamic>> companyProfitsMap = {};

// // //       for (var doc in snapshot.docs) {
// // //         final data = doc.data();
// // //         final companyId = data['companyId'] as String?;
// // //         final companyName = data['companyName'] as String?;

// // //         if (companyId != null && companyId.isNotEmpty && companyName != null) {
// // //           if (!companyProfitsMap.containsKey(companyId)) {
// // //             companyProfitsMap[companyId] = {
// // //               'companyId': companyId,
// // //               'companyName': companyName,
// // //               'totalIncome': 0.0, // دخل الشركة
// // //               'totalDriversCost': 0.0, // تكلفة السائقين لهذه الشركة
// // //               'companyProfit': 0.0, // ربح الشركة (الدخل - السائقين)
// // //             };
// // //           }

// // //           final companyData = companyProfitsMap[companyId]!;

// // //           // إضافة دخل الشركة
// // //           final nolon = (data['nolon'] ?? data['noLon'] ?? 0).toDouble();
// // //           final companyOvernight = (data['companyOvernight'] ?? 0).toDouble();
// // //           final companyHoliday = (data['companyHoliday'] ?? 0).toDouble();

// // //           companyData['totalIncome'] +=
// // //               nolon + companyOvernight + companyHoliday;

// // //           // حساب تكلفة السائقين لهذه الرحلة
// // //           final driverName = data['driverName'] as String?;
// // //           final contractor = data['contractor'] as String?;

// // //           if (driverName != null && contractor != null) {
// // //             // البحث عن حساب السائق لهذه الرحلة
// // //             final driverQuery = await _firestore
// // //                 .collection('drivers')
// // //                 .where('date', isEqualTo: data['date'])
// // //                 .where('driverName', isEqualTo: driverName)
// // //                 .where('contractor', isEqualTo: contractor)
// // //                 .limit(1)
// // //                 .get();

// // //             if (driverQuery.docs.isNotEmpty) {
// // //               final driverData = driverQuery.docs.first.data();
// // //               final wheelNolon = (driverData['wheelNolon'] ?? 0).toDouble();
// // //               final wheelOvernight = (driverData['wheelOvernight'] ?? 0)
// // //                   .toDouble();
// // //               final wheelHoliday = (driverData['wheelHoliday'] ?? 0).toDouble();

// // //               companyData['totalDriversCost'] +=
// // //                   wheelNolon + wheelOvernight + wheelHoliday;
// // //             }
// // //           }
// // //         }
// // //       }

// // //       // حساب ربح كل شركة
// // //       List<Map<String, dynamic>> companyProfitsList = [];

// // //       for (var entry in companyProfitsMap.entries) {
// // //         final companyData = entry.value;
// // //         final companyProfit =
// // //             companyData['totalIncome'] - companyData['totalDriversCost'];

// // //         companyData['companyProfit'] = companyProfit;
// // //         companyProfitsList.add(companyData);
// // //       }

// // //       // ترتيب حسب الربح (الأكبر أولاً)
// // //       companyProfitsList.sort(
// // //         (a, b) => b['companyProfit'].compareTo(a['companyProfit']),
// // //       );

// // //       if (mounted) {
// // //         setState(() {
// // //           _companyProfits = companyProfitsList;
// // //         });
// // //       }
// // //     } catch (e) {
// // //       print('خطأ في تحميل أرباح الشركات: $e');
// // //     }
// // //   }

// // //   // ================================
// // //   // تحميل الشركاء
// // //   // ================================
// // //   Future<void> _loadPartners() async {
// // //     try {
// // //       final partnersSnapshot = await _firestore
// // //           .collection('company_partners')
// // //           .orderBy('createdAt', descending: true)
// // //           .get();

// // //       List<Map<String, dynamic>> partnersList = [];

// // //       for (var doc in partnersSnapshot.docs) {
// // //         final data = doc.data();

// // //         partnersList.add({
// // //           'id': doc.id,
// // //           'name': data['name']?.toString() ?? 'غير معروف',
// // //           'percentage': (data['percentage'] as num?)?.toDouble() ?? 0.0,
// // //           'createdAt':
// // //               (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
// // //           'updatedAt': data['updatedAt'] != null
// // //               ? (data['updatedAt'] as Timestamp).toDate()
// // //               : null,
// // //         });
// // //       }

// // //       if (mounted) {
// // //         setState(() {
// // //           _partners = partnersList;
// // //         });
// // //       }
// // //     } catch (e) {
// // //       print('Error loading partners: $e');
// // //       if (mounted) {
// // //         setState(() {
// // //           _partners = [];
// // //         });
// // //       }
// // //     }
// // //   }

// // //   // ================================
// // //   // حساب توزيع الربح على الشركاء
// // //   // ================================
// // //   void _calculateDistribution() {
// // //     if (_partners.isEmpty || _netProfit <= 0) {
// // //       if (mounted) {
// // //         setState(() {
// // //           _totalDistributed = 0;
// // //           _remainingProfit = _netProfit;
// // //           _isDistributionCompleted = false;
// // //         });
// // //       }
// // //       return;
// // //     }

// // //     double totalDistributed = 0;

// // //     // حساب حصة كل شريك
// // //     for (var partner in _partners) {
// // //       final percentage = (partner['percentage'] as num?)?.toDouble() ?? 0.0;
// // //       final amount = (_netProfit * percentage) / 100;
// // //       partner['profitShare'] = amount;
// // //       partner['shareFormatted'] = _formatCurrency(amount);
// // //       totalDistributed += amount;
// // //     }

// // //     if (mounted) {
// // //       setState(() {
// // //         _totalDistributed = totalDistributed;
// // //         _remainingProfit = _netProfit - totalDistributed;
// // //         _isDistributionCompleted = (totalDistributed == _netProfit);
// // //       });
// // //     }
// // //   }

// // //   // ================================
// // //   // تغيير الشهر
// // //   // ================================
// // //   Future<void> _changeMonth(int month) async {
// // //     if (mounted) {
// // //       setState(() {
// // //         _selectedMonth = month;
// // //         _selectedMonthName = _getMonthName(month);
// // //         _isLoading = true;
// // //       });
// // //     }

// // //     try {
// // //       await _calculateMonthlyTotals();
// // //       await _loadCompanyProfits();
// // //       _calculateDistribution();
// // //     } catch (e) {
// // //       _showError('خطأ في تحميل بيانات الشهر');
// // //     } finally {
// // //       if (mounted) {
// // //         setState(() => _isLoading = false);
// // //       }
// // //     }
// // //   }

// // //   Future<void> _changeYear(int year) async {
// // //     if (mounted) {
// // //       setState(() {
// // //         _selectedYear = year;
// // //         _isLoading = true;
// // //       });
// // //     }

// // //     try {
// // //       await _calculateMonthlyTotals();
// // //       await _loadCompanyProfits();
// // //       _calculateDistribution();
// // //     } catch (e) {
// // //       _showError('خطأ في تحميل بيانات السنة');
// // //     } finally {
// // //       if (mounted) {
// // //         setState(() => _isLoading = false);
// // //       }
// // //     }
// // //   }

// // //   // ================================
// // //   // إضافة شريك جديد
// // //   // ================================
// // //   Future<void> _addPartner() async {
// // //     final name = _partnerNameController.text.trim();
// // //     final percentageText = _partnerPercentageController.text.trim();

// // //     if (name.isEmpty) {
// // //       _showError('أدخل اسم الشريك');
// // //       return;
// // //     }

// // //     if (percentageText.isEmpty) {
// // //       _showError('أدخل نسبة الشريك');
// // //       return;
// // //     }

// // //     final percentage = double.tryParse(percentageText);
// // //     if (percentage == null || percentage <= 0 || percentage > 100) {
// // //       _showError('النسبة يجب أن تكون بين 1 و 100');
// // //       return;
// // //     }

// // //     double currentTotal = 0;
// // //     for (var partner in _partners) {
// // //       currentTotal += (partner['percentage'] as num).toDouble();
// // //     }

// // //     if (currentTotal + percentage > 100) {
// // //       _showError('مجموع النسب يتجاوز 100%');
// // //       return;
// // //     }

// // //     if (mounted) {
// // //       setState(() => _isLoading = true);
// // //     }

// // //     try {
// // //       await _firestore.collection('company_partners').add({
// // //         'name': name,
// // //         'percentage': percentage,
// // //         'createdAt': Timestamp.now(),
// // //         'updatedAt': Timestamp.now(),
// // //       });

// // //       _showSuccess('تم إضافة الشريك');
// // //       _partnerNameController.clear();
// // //       _partnerPercentageController.clear();

// // //       if (mounted) {
// // //         setState(() => _showAddPartnerForm = false);
// // //       }

// // //       await _loadPartners();
// // //       _calculateDistribution();
// // //     } catch (e) {
// // //       _showError('خطأ في الإضافة');
// // //     } finally {
// // //       if (mounted) {
// // //         setState(() => _isLoading = false);
// // //       }
// // //     }
// // //   }

// // //   // ================================
// // //   // تعديل شريك
// // //   // ================================
// // //   Future<void> _editPartner(Map<String, dynamic> partner) async {
// // //     final name = _editPartnerNameController.text.trim();
// // //     final percentageText = _editPartnerPercentageController.text.trim();

// // //     if (name.isEmpty) {
// // //       _showError('أدخل اسم الشريك');
// // //       return;
// // //     }

// // //     if (percentageText.isEmpty) {
// // //       _showError('أدخل نسبة الشريك');
// // //       return;
// // //     }

// // //     final newPercentage = double.tryParse(percentageText);
// // //     if (newPercentage == null || newPercentage <= 0 || newPercentage > 100) {
// // //       _showError('النسبة يجب أن تكون بين 1 و 100');
// // //       return;
// // //     }

// // //     double currentTotal = 0;
// // //     final oldPercentage = (partner['percentage'] as num).toDouble();

// // //     for (var p in _partners) {
// // //       if (p['id'] != partner['id']) {
// // //         currentTotal += (p['percentage'] as num).toDouble();
// // //       }
// // //     }

// // //     if (currentTotal + newPercentage > 100) {
// // //       _showError('مجموع النسب يتجاوز 100%');
// // //       return;
// // //     }

// // //     if (mounted) {
// // //       setState(() => _isLoading = true);
// // //     }

// // //     try {
// // //       await _firestore.collection('company_partners').doc(partner['id']).update(
// // //         {
// // //           'name': name,
// // //           'percentage': newPercentage,
// // //           'updatedAt': Timestamp.now(),
// // //         },
// // //       );

// // //       _showSuccess('تم تعديل الشريك');

// // //       if (mounted) {
// // //         setState(() => _editingPartner = null);
// // //       }

// // //       await _loadPartners();
// // //       _calculateDistribution();
// // //     } catch (e) {
// // //       _showError('خطأ في التعديل');
// // //     } finally {
// // //       if (mounted) {
// // //         setState(() => _isLoading = false);
// // //       }
// // //     }
// // //   }

// // //   // ================================
// // //   // حذف شريك
// // //   // ================================
// // //   Future<void> _deletePartner(String partnerId) async {
// // //     try {
// // //       Map<String, dynamic>? partner;
// // //       for (var p in _partners) {
// // //         if (p['id'] == partnerId) {
// // //           partner = p;
// // //           break;
// // //         }
// // //       }

// // //       if (partner == null) {
// // //         _showError('الشريك غير موجود');
// // //         return;
// // //       }

// // //       bool? confirm = await showDialog<bool>(
// // //         context: context,
// // //         builder: (context) => AlertDialog(
// // //           title: const Text('حذف الشريك'),
// // //           content: Text('هل تريد حذف الشريك ${partner!['name']}؟'),
// // //           actions: [
// // //             TextButton(
// // //               onPressed: () => Navigator.pop(context, false),
// // //               child: const Text('لا'),
// // //             ),
// // //             TextButton(
// // //               onPressed: () => Navigator.pop(context, true),
// // //               child: const Text('نعم'),
// // //             ),
// // //           ],
// // //         ),
// // //       );

// // //       if (confirm != true) return;

// // //       if (mounted) {
// // //         setState(() => _isLoading = true);
// // //       }

// // //       try {
// // //         await _firestore.collection('company_partners').doc(partnerId).delete();
// // //         _showSuccess('تم حذف الشريك');
// // //         await _loadPartners();
// // //         _calculateDistribution();
// // //       } catch (e) {
// // //         _showError('خطأ في الحذف');
// // //       } finally {
// // //         if (mounted) {
// // //           setState(() => _isLoading = false);
// // //         }
// // //       }
// // //     } catch (e) {
// // //       _showError('خطأ في العملية');
// // //     }
// // //   }

// // //   // ================================
// // //   // تبويب إجماليات الشهر
// // //   // ================================
// // //   Widget _buildMonthlyTotalsTab() {
// // //     return SingleChildScrollView(
// // //       padding: const EdgeInsets.all(16),
// // //       child: Column(
// // //         children: [
// // //           // فلتر الشهر والسنة
// // //           _buildMonthYearFilter(),

// // //           const SizedBox(height: 20),

// // //           // بطاقة الإجماليات
// // //           Card(
// // //             elevation: 4,
// // //             shape: RoundedRectangleBorder(
// // //               borderRadius: BorderRadius.circular(16),
// // //             ),
// // //             child: Container(
// // //               padding: const EdgeInsets.all(20),
// // //               decoration: BoxDecoration(
// // //                 gradient: const LinearGradient(
// // //                   begin: Alignment.centerRight,
// // //                   end: Alignment.centerLeft,
// // //                   colors: [Color(0xFF1B4F72), Color(0xFF3498DB)],
// // //                 ),
// // //                 borderRadius: BorderRadius.circular(16),
// // //               ),
// // //               child: Column(
// // //                 children: [
// // //                   Row(
// // //                     children: [
// // //                       const Icon(
// // //                         Icons.calendar_month,
// // //                         color: Colors.white,
// // //                         size: 28,
// // //                       ),
// // //                       const SizedBox(width: 12),
// // //                       Column(
// // //                         crossAxisAlignment: CrossAxisAlignment.start,
// // //                         children: [
// // //                           const Text(
// // //                             'إجماليات الشهر',
// // //                             style: TextStyle(
// // //                               color: Colors.white,
// // //                               fontSize: 20,
// // //                               fontWeight: FontWeight.bold,
// // //                             ),
// // //                           ),
// // //                           Text(
// // //                             '$_selectedMonthName $_selectedYear',
// // //                             style: const TextStyle(
// // //                               color: Colors.white70,
// // //                               fontSize: 14,
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ],
// // //                   ),

// // //                   const SizedBox(height: 24),

// // //                   _buildTotalItem(
// // //                     icon: Icons.business,
// // //                     label: 'إجمالي دخل الشركات',
// // //                     value: _formatCurrency(_totalCompanyIncome),
// // //                     color: Colors.green[300]!,
// // //                     iconColor: Colors.green,
// // //                   ),

// // //                   const SizedBox(height: 12),

// // //                   _buildTotalItem(
// // //                     icon: Icons.person,
// // //                     label: 'إجمالي حساب السائقين',
// // //                     value: _formatCurrency(_totalDriversExpenses),
// // //                     color: Colors.orange[300]!,
// // //                     iconColor: Colors.orange,
// // //                   ),

// // //                   const SizedBox(height: 12),

// // //                   _buildTotalItem(
// // //                     icon: Icons.receipt_long,
// // //                     label: 'إجمالي الضرائب',
// // //                     value: _formatCurrency(_totalTaxes),
// // //                     color: Colors.red[300]!,
// // //                     iconColor: Colors.red,
// // //                   ),

// // //                   const SizedBox(height: 24),

// // //                   Container(
// // //                     padding: const EdgeInsets.all(16),
// // //                     decoration: BoxDecoration(
// // //                       color: Colors.white.withOpacity(0.1),
// // //                       borderRadius: BorderRadius.circular(12),
// // //                       border: Border.all(color: Colors.white.withOpacity(0.3)),
// // //                     ),
// // //                     child: Column(
// // //                       children: [
// // //                         Row(
// // //                           children: [
// // //                             const Icon(
// // //                               Icons.attach_money,
// // //                               color: Colors.white,
// // //                               size: 24,
// // //                             ),
// // //                             const SizedBox(width: 12),
// // //                             const Text(
// // //                               'صافي الربح الشهري',
// // //                               style: TextStyle(
// // //                                 color: Colors.white,
// // //                                 fontSize: 16,
// // //                                 fontWeight: FontWeight.bold,
// // //                               ),
// // //                             ),
// // //                             const Spacer(),
// // //                             Text(
// // //                               _formatCurrency(_netProfit),
// // //                               style: TextStyle(
// // //                                 color: _netProfit >= 0
// // //                                     ? Colors.green[300]!
// // //                                     : Colors.red[300]!,
// // //                                 fontSize: 24,
// // //                                 fontWeight: FontWeight.bold,
// // //                               ),
// // //                             ),
// // //                           ],
// // //                         ),
// // //                         const SizedBox(height: 8),
// // //                         Text(
// // //                           'الدخل - السائقين - الضرائب',
// // //                           style: TextStyle(
// // //                             color: Colors.white.withOpacity(0.8),
// // //                             fontSize: 12,
// // //                           ),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ),

// // //           const SizedBox(height: 20),

// // //           // الانتقال إلى تبويب الشركاء
// // //           SizedBox(
// // //             width: double.infinity,
// // //             child: ElevatedButton.icon(
// // //               onPressed: () {
// // //                 _calculateDistribution();
// // //                 _changeTab(2);
// // //               },
// // //               icon: const Icon(Icons.groups, size: 20),
// // //               label: const Text('توزيع الربح على الشركاء'),
// // //               style: ElevatedButton.styleFrom(
// // //                 backgroundColor: const Color(0xFF3498DB),
// // //                 padding: const EdgeInsets.symmetric(vertical: 14),
// // //                 shape: RoundedRectangleBorder(
// // //                   borderRadius: BorderRadius.circular(10),
// // //                 ),
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // ================================
// // //   // تبويب أرباح الشركات
// // //   // ================================
// // //   Widget _buildCompaniesProfitsTab() {
// // //     return SingleChildScrollView(
// // //       padding: const EdgeInsets.all(16),
// // //       child: Column(
// // //         children: [
// // //           Card(
// // //             elevation: 2,
// // //             shape: RoundedRectangleBorder(
// // //               borderRadius: BorderRadius.circular(12),
// // //             ),
// // //             child: Padding(
// // //               padding: const EdgeInsets.all(16),
// // //               child: Row(
// // //                 children: [
// // //                   const Icon(
// // //                     Icons.business,
// // //                     color: Color(0xFF1B4F72),
// // //                     size: 24,
// // //                   ),
// // //                   const SizedBox(width: 12),
// // //                   const Text(
// // //                     'أرباح الشركات',
// // //                     style: TextStyle(
// // //                       fontSize: 18,
// // //                       fontWeight: FontWeight.bold,
// // //                       color: Color(0xFF1B4F72),
// // //                     ),
// // //                   ),
// // //                   const Spacer(),
// // //                   Container(
// // //                     padding: const EdgeInsets.symmetric(
// // //                       horizontal: 12,
// // //                       vertical: 6,
// // //                     ),
// // //                     decoration: BoxDecoration(
// // //                       color: Colors.blue[50],
// // //                       borderRadius: BorderRadius.circular(20),
// // //                     ),
// // //                     child: Text(
// // //                       '${_companyProfits.length} شركة',
// // //                       style: const TextStyle(
// // //                         fontWeight: FontWeight.bold,
// // //                         color: Colors.blue,
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ),

// // //           const SizedBox(height: 16),

// // //           if (_companyProfits.isNotEmpty)
// // //             ..._companyProfits.map(
// // //               (company) => _buildCompanyProfitCard(company),
// // //             )
// // //           else
// // //             _buildNoDataCard('لا توجد بيانات للشركات هذا الشهر'),

// // //           const SizedBox(height: 20),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // ================================
// // //   // تبويب توزيع الربح
// // //   // ================================
// // //   Widget _buildDistributionTab() {
// // //     return SingleChildScrollView(
// // //       padding: const EdgeInsets.all(16),
// // //       child: Column(
// // //         children: [
// // //           Card(
// // //             elevation: 4,
// // //             shape: RoundedRectangleBorder(
// // //               borderRadius: BorderRadius.circular(16),
// // //             ),
// // //             child: Padding(
// // //               padding: const EdgeInsets.all(16),
// // //               child: Column(
// // //                 children: [
// // //                   Row(
// // //                     children: [
// // //                       const Icon(
// // //                         Icons.pie_chart,
// // //                         color: Color(0xFF1B4F72),
// // //                         size: 28,
// // //                       ),
// // //                       const SizedBox(width: 12),
// // //                       Column(
// // //                         crossAxisAlignment: CrossAxisAlignment.start,
// // //                         children: [
// // //                           const Text(
// // //                             'توزيع صافي الربح',
// // //                             style: TextStyle(
// // //                               fontSize: 18,
// // //                               fontWeight: FontWeight.bold,
// // //                             ),
// // //                           ),
// // //                           Text(
// // //                             'الشهر: $_selectedMonthName $_selectedYear',
// // //                             style: const TextStyle(
// // //                               color: Colors.grey,
// // //                               fontSize: 12,
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                       const Spacer(),
// // //                       Container(
// // //                         padding: const EdgeInsets.symmetric(
// // //                           horizontal: 12,
// // //                           vertical: 6,
// // //                         ),
// // //                         decoration: BoxDecoration(
// // //                           color: _netProfit >= 0
// // //                               ? Colors.green[50]
// // //                               : Colors.red[50],
// // //                           borderRadius: BorderRadius.circular(20),
// // //                         ),
// // //                         child: Text(
// // //                           _formatCurrency(_netProfit),
// // //                           style: TextStyle(
// // //                             fontWeight: FontWeight.bold,
// // //                             color: _netProfit >= 0 ? Colors.green : Colors.red,
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),

// // //                   const SizedBox(height: 16),

// // //                   Container(
// // //                     padding: const EdgeInsets.all(16),
// // //                     decoration: BoxDecoration(
// // //                       color: Colors.grey[50],
// // //                       borderRadius: BorderRadius.circular(12),
// // //                     ),
// // //                     child: Column(
// // //                       children: [
// // //                         Row(
// // //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                           children: [
// // //                             const Text('إجمالي الموزع:'),
// // //                             Text(
// // //                               _formatCurrency(_totalDistributed),
// // //                               style: const TextStyle(
// // //                                 fontWeight: FontWeight.bold,
// // //                                 color: Colors.green,
// // //                               ),
// // //                             ),
// // //                           ],
// // //                         ),
// // //                         const SizedBox(height: 8),
// // //                         Row(
// // //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                           children: [
// // //                             const Text('المتبقي للتوزيع:'),
// // //                             Text(
// // //                               _formatCurrency(_remainingProfit),
// // //                               style: const TextStyle(
// // //                                 fontWeight: FontWeight.bold,
// // //                                 color: Colors.orange,
// // //                               ),
// // //                             ),
// // //                           ],
// // //                         ),
// // //                         const SizedBox(height: 12),
// // //                         if (_isDistributionCompleted)
// // //                           Container(
// // //                             padding: const EdgeInsets.all(8),
// // //                             decoration: BoxDecoration(
// // //                               color: Colors.green[50],
// // //                               borderRadius: BorderRadius.circular(8),
// // //                             ),
// // //                             child: const Row(
// // //                               mainAxisAlignment: MainAxisAlignment.center,
// // //                               children: [
// // //                                 Icon(Icons.check_circle, color: Colors.green),
// // //                                 SizedBox(width: 8),
// // //                                 Text(
// // //                                   'تم توزيع كامل الربح',
// // //                                   style: TextStyle(
// // //                                     color: Colors.green,
// // //                                     fontWeight: FontWeight.bold,
// // //                                   ),
// // //                                 ),
// // //                               ],
// // //                             ),
// // //                           ),
// // //                       ],
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ),

// // //           const SizedBox(height: 20),

// // //           // قائمة الشركاء
// // //           if (_partners.isNotEmpty)
// // //             ..._partners.map(
// // //               (partner) => _buildPartnerDistributionCard(partner),
// // //             )
// // //           else
// // //             _buildNoDataCard('لا يوجد شركاء مضافة'),

// // //           const SizedBox(height: 16),

// // //           if (!_showAddPartnerForm)
// // //             SizedBox(
// // //               width: double.infinity,
// // //               child: ElevatedButton.icon(
// // //                 onPressed: () {
// // //                   if (mounted) {
// // //                     setState(() => _showAddPartnerForm = true);
// // //                   }
// // //                 },
// // //                 icon: const Icon(Icons.person_add, size: 20),
// // //                 label: const Text('إضافة شريك جديد'),
// // //                 style: ElevatedButton.styleFrom(
// // //                   backgroundColor: const Color(0xFF3498DB),
// // //                   padding: const EdgeInsets.symmetric(vertical: 14),
// // //                   shape: RoundedRectangleBorder(
// // //                     borderRadius: BorderRadius.circular(10),
// // //                   ),
// // //                 ),
// // //               ),
// // //             ),

// // //           if (_showAddPartnerForm) _buildAddPartnerForm(),

// // //           const SizedBox(height: 16),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // ================================
// // //   // Widgets المساعدة
// // //   // ================================

// // //   Widget _buildMonthYearFilter() {
// // //     return Card(
// // //       elevation: 2,
// // //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // //       child: Padding(
// // //         padding: const EdgeInsets.all(16),
// // //         child: Column(
// // //           children: [
// // //             const Text(
// // //               'اختر الشهر والسنة',
// // //               style: TextStyle(
// // //                 fontWeight: FontWeight.bold,
// // //                 fontSize: 16,
// // //                 color: Color(0xFF2C3E50),
// // //               ),
// // //             ),
// // //             const SizedBox(height: 16),
// // //             Row(
// // //               mainAxisAlignment: MainAxisAlignment.center,
// // //               children: [
// // //                 DropdownButton<int>(
// // //                   value: _selectedMonth,
// // //                   onChanged: (value) {
// // //                     if (value != null) {
// // //                       _changeMonth(value);
// // //                     }
// // //                   },
// // //                   items: List.generate(12, (index) {
// // //                     final monthNumber = index + 1;
// // //                     return DropdownMenuItem(
// // //                       value: monthNumber,
// // //                       child: Text(_getMonthName(monthNumber)),
// // //                     );
// // //                   }),
// // //                 ),
// // //                 const SizedBox(width: 20),
// // //                 DropdownButton<int>(
// // //                   value: _selectedYear,
// // //                   onChanged: (value) {
// // //                     if (value != null) {
// // //                       _changeYear(value);
// // //                     }
// // //                   },
// // //                   items: [
// // //                     for (
// // //                       int i = DateTime.now().year - 5;
// // //                       i <= DateTime.now().year + 1;
// // //                       i++
// // //                     )
// // //                       DropdownMenuItem(value: i, child: Text('$i')),
// // //                   ],
// // //                 ),
// // //               ],
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildTotalItem({
// // //     required IconData icon,
// // //     required String label,
// // //     required String value,
// // //     required Color color,
// // //     required Color iconColor,
// // //   }) {
// // //     return Container(
// // //       padding: const EdgeInsets.all(12),
// // //       decoration: BoxDecoration(
// // //         color: Colors.white.withOpacity(0.05),
// // //         borderRadius: BorderRadius.circular(10),
// // //         border: Border.all(color: Colors.white.withOpacity(0.1)),
// // //       ),
// // //       child: Row(
// // //         children: [
// // //           Icon(icon, color: iconColor, size: 22),
// // //           const SizedBox(width: 12),
// // //           Expanded(
// // //             child: Text(
// // //               label,
// // //               style: const TextStyle(color: Colors.white, fontSize: 16),
// // //             ),
// // //           ),
// // //           Text(
// // //             value,
// // //             style: TextStyle(
// // //               color: color,
// // //               fontSize: 18,
// // //               fontWeight: FontWeight.bold,
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildCompanyProfitCard(Map<String, dynamic> company) {
// // //     final companyName = company['companyName'];
// // //     final totalIncome = company['totalIncome'] as double;
// // //     final driversCost = company['totalDriversCost'] as double;
// // //     final profit = (totalIncome - _totalDriversExpenses - _totalTaxes);

// // //     return Card(
// // //       margin: const EdgeInsets.only(bottom: 12),
// // //       elevation: 2,
// // //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // //       child: Padding(
// // //         padding: const EdgeInsets.all(16),
// // //         child: Row(
// // //           children: [
// // //             Container(
// // //               width: 50,
// // //               height: 50,
// // //               decoration: BoxDecoration(
// // //                 color: _getCompanyColor(companyName),
// // //                 borderRadius: BorderRadius.circular(25),
// // //               ),
// // //               child: Center(
// // //                 child: Text(
// // //                   _getCompanyInitials(companyName),
// // //                   style: const TextStyle(
// // //                     color: Colors.white,
// // //                     fontSize: 18,
// // //                     fontWeight: FontWeight.bold,
// // //                   ),
// // //                 ),
// // //               ),
// // //             ),

// // //             const SizedBox(width: 16),

// // //             Expanded(
// // //               child: Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   Text(
// // //                     companyName,
// // //                     style: const TextStyle(
// // //                       fontSize: 16,
// // //                       fontWeight: FontWeight.bold,
// // //                       color: Color(0xFF2C3E50),
// // //                     ),
// // //                   ),

// // //                   const SizedBox(height: 8),

// // //                   Row(
// // //                     children: [
// // //                       Expanded(
// // //                         child: Column(
// // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // //                           children: [
// // //                             Text(
// // //                               'الدخل',
// // //                               style: TextStyle(
// // //                                 fontSize: 12,
// // //                                 color: Colors.grey[600],
// // //                               ),
// // //                             ),
// // //                             Text(
// // //                               _formatCurrency(totalIncome),
// // //                               style: const TextStyle(
// // //                                 fontSize: 14,
// // //                                 fontWeight: FontWeight.bold,
// // //                                 color: Colors.green,
// // //                               ),
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       ),

// // //                       Expanded(
// // //                         child: Column(
// // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // //                           children: [
// // //                             Text(
// // //                               'حساب السائقين',
// // //                               style: TextStyle(
// // //                                 fontSize: 12,
// // //                                 color: Colors.grey[600],
// // //                               ),
// // //                             ),
// // //                             Text(
// // //                               _formatCurrency(_totalDriversExpenses),
// // //                               style: const TextStyle(
// // //                                 fontSize: 14,
// // //                                 fontWeight: FontWeight.bold,
// // //                                 color: Colors.orange,
// // //                               ),
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       ),

// // //                       Expanded(
// // //                         child: Column(
// // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // //                           children: [
// // //                             Text(
// // //                               'الضرائب',
// // //                               style: TextStyle(
// // //                                 fontSize: 12,
// // //                                 color: Colors.grey[600],
// // //                               ),
// // //                             ),
// // //                             Text(
// // //                               _formatCurrency(_totalTaxes),
// // //                               style: const TextStyle(
// // //                                 fontSize: 14,
// // //                                 fontWeight: FontWeight.bold,
// // //                                 color: Colors.green,
// // //                               ),
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       ),

// // //                       Expanded(
// // //                         child: Column(
// // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // //                           children: [
// // //                             Text(
// // //                               'صافي الربح',
// // //                               style: TextStyle(
// // //                                 fontSize: 12,
// // //                                 color: Colors.grey[600],
// // //                               ),
// // //                             ),
// // //                             Text(
// // //                               _formatCurrency(profit),
// // //                               style: TextStyle(
// // //                                 fontSize: 14,
// // //                                 fontWeight: FontWeight.bold,
// // //                                 color: profit >= 0 ? Colors.blue : Colors.red,
// // //                               ),
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildPartnerDistributionCard(Map<String, dynamic> partner) {
// // //     final percentage = (partner['percentage'] as num?)?.toDouble() ?? 0.0;
// // //     final share = (partner['profitShare'] as num?)?.toDouble() ?? 0.0;
// // //     final isEditing = _editingPartner?['id'] == partner['id'];

// // //     return Card(
// // //       margin: const EdgeInsets.only(bottom: 12),
// // //       elevation: 2,
// // //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // //       child: Padding(
// // //         padding: const EdgeInsets.all(16),
// // //         child: Column(
// // //           children: [
// // //             if (isEditing)
// // //               _buildEditPartnerForm(partner)
// // //             else
// // //               Row(
// // //                 children: [
// // //                   Container(
// // //                     width: 50,
// // //                     height: 50,
// // //                     decoration: BoxDecoration(
// // //                       color: _getPartnerColor(partner['name']),
// // //                       borderRadius: BorderRadius.circular(25),
// // //                     ),
// // //                     child: Center(
// // //                       child: Text(
// // //                         _getInitials(partner['name']),
// // //                         style: const TextStyle(
// // //                           color: Colors.white,
// // //                           fontSize: 18,
// // //                           fontWeight: FontWeight.bold,
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ),

// // //                   const SizedBox(width: 16),

// // //                   Expanded(
// // //                     child: Column(
// // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // //                       children: [
// // //                         Row(
// // //                           children: [
// // //                             Expanded(
// // //                               child: Text(
// // //                                 partner['name'],
// // //                                 style: const TextStyle(
// // //                                   fontSize: 16,
// // //                                   fontWeight: FontWeight.bold,
// // //                                   color: Color(0xFF2C3E50),
// // //                                 ),
// // //                               ),
// // //                             ),
// // //                             Container(
// // //                               padding: const EdgeInsets.symmetric(
// // //                                 horizontal: 12,
// // //                                 vertical: 4,
// // //                               ),
// // //                               decoration: BoxDecoration(
// // //                                 color: Colors.blue[50],
// // //                                 borderRadius: BorderRadius.circular(20),
// // //                               ),
// // //                               child: Text(
// // //                                 '${percentage.toStringAsFixed(1)}%',
// // //                                 style: const TextStyle(
// // //                                   fontWeight: FontWeight.bold,
// // //                                   color: Colors.blue,
// // //                                   fontSize: 14,
// // //                                 ),
// // //                               ),
// // //                             ),
// // //                           ],
// // //                         ),

// // //                         const SizedBox(height: 8),

// // //                         Row(
// // //                           children: [
// // //                             Expanded(
// // //                               child: Column(
// // //                                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                                 children: [
// // //                                   Text(
// // //                                     'حصة الشريك',
// // //                                     style: TextStyle(
// // //                                       fontSize: 12,
// // //                                       color: Colors.grey[600],
// // //                                     ),
// // //                                   ),
// // //                                   Text(
// // //                                     _formatCurrency(share),
// // //                                     style: const TextStyle(
// // //                                       fontSize: 16,
// // //                                       fontWeight: FontWeight.bold,
// // //                                       color: Colors.green,
// // //                                     ),
// // //                                   ),
// // //                                 ],
// // //                               ),
// // //                             ),

// // //                             Column(
// // //                               crossAxisAlignment: CrossAxisAlignment.end,
// // //                               children: [
// // //                                 Text(
// // //                                   'نسبة من الربح',
// // //                                   style: TextStyle(
// // //                                     fontSize: 12,
// // //                                     color: Colors.grey[600],
// // //                                   ),
// // //                                 ),
// // //                                 Text(
// // //                                   '${((share / _netProfit) * 100).toStringAsFixed(1)}%',
// // //                                   style: const TextStyle(
// // //                                     fontSize: 14,
// // //                                     fontWeight: FontWeight.bold,
// // //                                     color: Colors.blue,
// // //                                   ),
// // //                                 ),
// // //                               ],
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ),

// // //                   PopupMenuButton<String>(
// // //                     icon: const Icon(Icons.more_vert, color: Colors.grey),
// // //                     itemBuilder: (context) => [
// // //                       const PopupMenuItem(
// // //                         value: 'edit',
// // //                         child: Row(
// // //                           children: [
// // //                             Icon(Icons.edit, size: 18, color: Colors.blue),
// // //                             SizedBox(width: 8),
// // //                             Text('تعديل'),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                       const PopupMenuItem(
// // //                         value: 'delete',
// // //                         child: Row(
// // //                           children: [
// // //                             Icon(Icons.delete, color: Colors.red, size: 18),
// // //                             SizedBox(width: 8),
// // //                             Text('حذف'),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ],
// // //                     onSelected: (value) {
// // //                       if (value == 'edit') {
// // //                         _editPartnerNameController.text = partner['name'];
// // //                         _editPartnerPercentageController.text = percentage
// // //                             .toStringAsFixed(1);
// // //                         if (mounted) {
// // //                           setState(() => _editingPartner = partner);
// // //                         }
// // //                       } else if (value == 'delete') {
// // //                         _deletePartner(partner['id']);
// // //                       }
// // //                     },
// // //                   ),
// // //                 ],
// // //               ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildEditPartnerForm(Map<String, dynamic> partner) {
// // //     return Column(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         Row(
// // //           children: [
// // //             const Icon(Icons.edit, color: Colors.blue, size: 20),
// // //             const SizedBox(width: 8),
// // //             const Text(
// // //               'تعديل بيانات الشريك',
// // //               style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
// // //             ),
// // //             const Spacer(),
// // //             IconButton(
// // //               icon: const Icon(Icons.close, size: 18, color: Colors.grey),
// // //               onPressed: () {
// // //                 if (mounted) {
// // //                   setState(() => _editingPartner = null);
// // //                 }
// // //               },
// // //             ),
// // //           ],
// // //         ),

// // //         const SizedBox(height: 16),

// // //         TextField(
// // //           controller: _editPartnerNameController,
// // //           decoration: InputDecoration(
// // //             labelText: 'اسم الشريك',
// // //             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
// // //             contentPadding: const EdgeInsets.symmetric(
// // //               horizontal: 16,
// // //               vertical: 12,
// // //             ),
// // //           ),
// // //         ),

// // //         const SizedBox(height: 12),

// // //         TextField(
// // //           controller: _editPartnerPercentageController,
// // //           keyboardType: TextInputType.number,
// // //           decoration: InputDecoration(
// // //             labelText: 'نسبة الشريك (%)',
// // //             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
// // //             contentPadding: const EdgeInsets.symmetric(
// // //               horizontal: 16,
// // //               vertical: 12,
// // //             ),
// // //             suffixText: '%',
// // //           ),
// // //         ),

// // //         const SizedBox(height: 16),

// // //         Row(
// // //           children: [
// // //             Expanded(
// // //               child: OutlinedButton(
// // //                 onPressed: () {
// // //                   if (mounted) {
// // //                     setState(() => _editingPartner = null);
// // //                   }
// // //                 },
// // //                 style: OutlinedButton.styleFrom(
// // //                   padding: const EdgeInsets.symmetric(vertical: 12),
// // //                   shape: RoundedRectangleBorder(
// // //                     borderRadius: BorderRadius.circular(8),
// // //                   ),
// // //                 ),
// // //                 child: const Text('إلغاء'),
// // //               ),
// // //             ),

// // //             const SizedBox(width: 12),

// // //             Expanded(
// // //               child: ElevatedButton(
// // //                 onPressed: () => _editPartner(partner),
// // //                 style: ElevatedButton.styleFrom(
// // //                   backgroundColor: Colors.green,
// // //                   padding: const EdgeInsets.symmetric(vertical: 12),
// // //                   shape: RoundedRectangleBorder(
// // //                     borderRadius: BorderRadius.circular(8),
// // //                   ),
// // //                 ),
// // //                 child: const Text('حفظ التعديلات'),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ],
// // //     );
// // //   }

// // //   Widget _buildNoDataCard(String message) {
// // //     return Card(
// // //       elevation: 2,
// // //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // //       child: Padding(
// // //         padding: const EdgeInsets.all(32),
// // //         child: Column(
// // //           children: [
// // //             Icon(Icons.info_outline, size: 60, color: Colors.grey[400]),
// // //             const SizedBox(height: 16),
// // //             Text(
// // //               message,
// // //               textAlign: TextAlign.center,
// // //               style: TextStyle(
// // //                 fontSize: 16,
// // //                 color: Colors.grey[600],
// // //                 fontWeight: FontWeight.bold,
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildAddPartnerForm() {
// // //     return Card(
// // //       elevation: 2,
// // //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// // //       child: Padding(
// // //         padding: const EdgeInsets.all(16),
// // //         child: Column(
// // //           crossAxisAlignment: CrossAxisAlignment.start,
// // //           children: [
// // //             Row(
// // //               children: [
// // //                 const Icon(Icons.person_add, color: Colors.green, size: 20),
// // //                 const SizedBox(width: 8),
// // //                 const Text(
// // //                   'إضافة شريك جديد',
// // //                   style: TextStyle(
// // //                     fontWeight: FontWeight.bold,
// // //                     color: Colors.green,
// // //                   ),
// // //                 ),
// // //                 const Spacer(),
// // //                 IconButton(
// // //                   icon: const Icon(Icons.close, size: 18, color: Colors.grey),
// // //                   onPressed: () {
// // //                     if (mounted) {
// // //                       setState(() => _showAddPartnerForm = false);
// // //                     }
// // //                   },
// // //                 ),
// // //               ],
// // //             ),

// // //             const SizedBox(height: 16),

// // //             TextField(
// // //               controller: _partnerNameController,
// // //               decoration: InputDecoration(
// // //                 labelText: 'اسم الشريك',
// // //                 border: OutlineInputBorder(
// // //                   borderRadius: BorderRadius.circular(8),
// // //                 ),
// // //                 contentPadding: const EdgeInsets.symmetric(
// // //                   horizontal: 16,
// // //                   vertical: 12,
// // //                 ),
// // //               ),
// // //             ),

// // //             const SizedBox(height: 12),

// // //             TextField(
// // //               controller: _partnerPercentageController,
// // //               keyboardType: TextInputType.number,
// // //               decoration: InputDecoration(
// // //                 labelText: 'نسبة الشريك (%)',
// // //                 border: OutlineInputBorder(
// // //                   borderRadius: BorderRadius.circular(8),
// // //                 ),
// // //                 contentPadding: const EdgeInsets.symmetric(
// // //                   horizontal: 16,
// // //                   vertical: 12,
// // //                 ),
// // //                 suffixText: '%',
// // //               ),
// // //             ),

// // //             const SizedBox(height: 16),

// // //             Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: OutlinedButton(
// // //                     onPressed: () {
// // //                       if (mounted) {
// // //                         setState(() => _showAddPartnerForm = false);
// // //                       }
// // //                     },
// // //                     style: OutlinedButton.styleFrom(
// // //                       padding: const EdgeInsets.symmetric(vertical: 12),
// // //                       shape: RoundedRectangleBorder(
// // //                         borderRadius: BorderRadius.circular(8),
// // //                       ),
// // //                     ),
// // //                     child: const Text('إلغاء'),
// // //                   ),
// // //                 ),

// // //                 const SizedBox(width: 12),

// // //                 Expanded(
// // //                   child: ElevatedButton(
// // //                     onPressed: _addPartner,
// // //                     style: ElevatedButton.styleFrom(
// // //                       backgroundColor: Colors.green,
// // //                       padding: const EdgeInsets.symmetric(vertical: 12),
// // //                       shape: RoundedRectangleBorder(
// // //                         borderRadius: BorderRadius.circular(8),
// // //                       ),
// // //                     ),
// // //                     child: const Text('إضافة الشريك'),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // ================================
// // //   // دوال مساعدة
// // //   // ================================

// // //   String _getMonthName(int month) {
// // //     switch (month) {
// // //       case 1:
// // //         return 'يناير';
// // //       case 2:
// // //         return 'فبراير';
// // //       case 3:
// // //         return 'مارس';
// // //       case 4:
// // //         return 'أبريل';
// // //       case 5:
// // //         return 'مايو';
// // //       case 6:
// // //         return 'يونيو';
// // //       case 7:
// // //         return 'يوليو';
// // //       case 8:
// // //         return 'أغسطس';
// // //       case 9:
// // //         return 'سبتمبر';
// // //       case 10:
// // //         return 'أكتوبر';
// // //       case 11:
// // //         return 'نوفمبر';
// // //       case 12:
// // //         return 'ديسمبر';
// // //       default:
// // //         return 'غير معروف';
// // //     }
// // //   }

// // //   Color _getPartnerColor(String name) {
// // //     final hash = name.hashCode;
// // //     return Color(hash & 0xFFFFFF).withOpacity(1.0).withBlue(150);
// // //   }

// // //   Color _getCompanyColor(String name) {
// // //     final hash = name.hashCode;
// // //     return Color(hash & 0xFFFFFF).withOpacity(1.0).withGreen(150);
// // //   }

// // //   String _getInitials(String name) {
// // //     if (name.isEmpty) return '??';

// // //     final trimmedName = name.trim();
// // //     final words = trimmedName.split(' ');

// // //     final validWords = words.where((word) => word.isNotEmpty).toList();

// // //     if (validWords.isEmpty) return '??';

// // //     if (validWords.length >= 2) {
// // //       return '${validWords[0][0]}${validWords[1][0]}'.toUpperCase();
// // //     } else {
// // //       final word = validWords[0];
// // //       if (word.length >= 2) {
// // //         return word.substring(0, 2).toUpperCase();
// // //       } else {
// // //         return word.toUpperCase();
// // //       }
// // //     }
// // //   }

// // //   String _getCompanyInitials(String name) {
// // //     if (name.isEmpty) return '??';

// // //     final trimmedName = name.trim();
// // //     final words = trimmedName.split(' ');

// // //     final validWords = words.where((word) => word.isNotEmpty).toList();

// // //     if (validWords.isEmpty) return '??';

// // //     // للحصول على أول حرف من أول كلمة
// // //     return validWords[0][0].toUpperCase();
// // //   }

// // //   String _formatCurrency(double amount) {
// // //     return '${amount.toStringAsFixed(2)} ج';
// // //   }

// // //   void _changeTab(int index) {
// // //     if (mounted) {
// // //       setState(() {
// // //         _currentTab = index;
// // //       });
// // //     }
// // //   }

// // //   void _showError(String message) {
// // //     if (mounted) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(
// // //           content: Text(message),
// // //           backgroundColor: Colors.red,
// // //           duration: const Duration(seconds: 2),
// // //         ),
// // //       );
// // //     }
// // //   }

// // //   void _showSuccess(String message) {
// // //     if (mounted) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(
// // //           content: Text(message),
// // //           backgroundColor: Colors.green,
// // //           duration: const Duration(seconds: 2),
// // //         ),
// // //       );
// // //     }
// // //   }

// // //   // ================================
// // //   // بناء الواجهة الرئيسية
// // //   // ================================

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return DefaultTabController(
// // //       length: 3,
// // //       initialIndex: _currentTab,
// // //       child: Scaffold(
// // //         appBar: AppBar(
// // //           title: const Text(
// // //             'توزيع الأرباح الشهرية',
// // //             style: TextStyle(color: Colors.white),
// // //           ),
// // //           centerTitle: true,
// // //           backgroundColor: const Color(0xFF1B4F72),
// // //           bottom: TabBar(
// // //             onTap: _changeTab,
// // //             indicatorColor: Colors.amber,
// // //             labelColor: Colors.amber,
// // //             unselectedLabelColor: Colors.white,
// // //             tabs: const [
// // //               Tab(icon: Icon(Icons.calculate), text: 'إجماليات الشهر'),
// // //               Tab(icon: Icon(Icons.business), text: 'أرباح الشركات'),
// // //               Tab(icon: Icon(Icons.groups), text: 'توزيع الربح'),
// // //             ],
// // //           ),
// // //         ),
// // //         body: _isLoading
// // //             ? const Center(child: CircularProgressIndicator())
// // //             : TabBarView(
// // //                 children: [
// // //                   _buildMonthlyTotalsTab(),
// // //                   _buildCompaniesProfitsTab(),
// // //                   _buildDistributionTab(),
// // //                 ],
// // //               ),
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _partnerNameController.dispose();
// // //     _partnerPercentageController.dispose();
// // //     _editPartnerNameController.dispose();
// // //     _editPartnerPercentageController.dispose();
// // //     super.dispose();
// // //   }
// // // }
// // import 'dart:async';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';

// // class MonthlyProfitsPage extends StatefulWidget {
// //   const MonthlyProfitsPage({super.key});

// //   @override
// //   State<MonthlyProfitsPage> createState() => _MonthlyProfitsPageState();
// // }

// // class _MonthlyProfitsPageState extends State<MonthlyProfitsPage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// //   // ================================
// //   // بيانات الشهر الحالي
// //   // ================================
// //   int _selectedYear = DateTime.now().year;
// //   int _selectedMonth = DateTime.now().month;
// //   String _selectedMonthName = '';

// //   // ================================
// //   // إجماليات الشهر
// //   // ================================
// //   double _totalCompanyIncome = 0.0; // إجمالي دخل الشركات
// //   double _totalDriversExpenses = 0.0; // إجمالي حساب السائقين
// //   double _netProfit = 0.0; // صافي الربح (الدخل - السائقين)

// //   // ================================
// //   // بيانات الشركات المنفصلة
// //   // ================================
// //   List<Map<String, dynamic>> _companyProfits = [];

// //   // ================================
// //   // بيانات الشركاء والتوزيع
// //   // ================================
// //   List<Map<String, dynamic>> _partners = [];
// //   double _totalDistributed = 0.0;
// //   double _remainingProfit = 0.0;
// //   bool _isDistributionCompleted = false;
// //   Map<String, double> _partnerShares = {};

// //   // ================================
// //   // متغيرات التحكم
// //   // ================================
// //   bool _isLoading = false;
// //   int _currentTab = 0;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _selectedMonthName = _getMonthName(_selectedMonth);
// //     _loadAllData();
// //   }

// //   // ================================
// //   // تحميل كل البيانات
// //   // ================================
// //   Future<void> _loadAllData() async {
// //     if (mounted) {
// //       setState(() => _isLoading = true);
// //     }

// //     try {
// //       await _calculateMonthlyTotals();
// //       await _loadCompanyProfits();
// //       await _loadPartnersFromCapitalPage();
// //       _calculateDistribution();
// //     } catch (e) {
// //       print('خطأ في تحميل البيانات: $e');
// //       _showError('خطأ في تحميل البيانات');
// //     } finally {
// //       if (mounted) {
// //         setState(() => _isLoading = false);
// //       }
// //     }
// //   }

// //   // ================================
// //   // حساب إجماليات الشهر
// //   // ================================
// //   Future<void> _calculateMonthlyTotals() async {
// //     try {
// //       double totalCompanyIncome = 0;
// //       double totalDriversExpenses = 0;

// //       // ================================
// //       // 1. حساب إجمالي دخل الشركات من dailyWork
// //       // ================================
// //       final companySnapshot = await _firestore
// //           .collection('dailyWork')
// //           .where(
// //             'date',
// //             isGreaterThanOrEqualTo: Timestamp.fromDate(
// //               DateTime(_selectedYear, _selectedMonth, 1),
// //             ),
// //           )
// //           .where(
// //             'date',
// //             isLessThan: Timestamp.fromDate(
// //               DateTime(_selectedYear, _selectedMonth + 1, 1),
// //             ),
// //           )
// //           .get();

// //       for (var doc in companySnapshot.docs) {
// //         final data = doc.data();

// //         // دخل الشركة من الرحلات
// //         final nolon = (data['nolon'] ?? data['noLon'] ?? 0).toDouble();
// //         final companyOvernight = (data['companyOvernight'] ?? 0).toDouble();
// //         final companyHoliday = (data['companyHoliday'] ?? 0).toDouble();

// //         totalCompanyIncome += nolon + companyOvernight + companyHoliday;
// //       }

// //       // ================================
// //       // 2. حساب إجمالي حساب السائقين
// //       // ================================
// //       final driversSnapshot = await _firestore
// //           .collection('drivers')
// //           .where(
// //             'date',
// //             isGreaterThanOrEqualTo: Timestamp.fromDate(
// //               DateTime(_selectedYear, _selectedMonth, 1),
// //             ),
// //           )
// //           .where(
// //             'date',
// //             isLessThan: Timestamp.fromDate(
// //               DateTime(_selectedYear, _selectedMonth + 1, 1),
// //             ),
// //           )
// //           .get();

// //       for (var doc in driversSnapshot.docs) {
// //         final data = doc.data();

// //         // حساب السائقين
// //         final wheelNolon = (data['wheelNolon'] ?? 0).toDouble();
// //         final wheelOvernight = (data['wheelOvernight'] ?? 0).toDouble();
// //         final wheelHoliday = (data['wheelHoliday'] ?? 0).toDouble();

// //         totalDriversExpenses += wheelNolon + wheelOvernight + wheelHoliday;
// //       }

// //       // ================================
// //       // 3. حساب صافي الربح (بدون ضرائب)
// //       // ================================
// //       final netProfit = totalCompanyIncome - totalDriversExpenses;

// //       if (mounted) {
// //         setState(() {
// //           _totalCompanyIncome = totalCompanyIncome;
// //           _totalDriversExpenses = totalDriversExpenses;
// //           _netProfit = netProfit;
// //         });
// //       }
// //     } catch (e) {
// //       print('خطأ في حساب الإجماليات: $e');
// //       throw e;
// //     }
// //   }

// //   // ================================
// //   // تحميل أرباح كل شركة منفصلة
// //   // ================================
// //   Future<void> _loadCompanyProfits() async {
// //     try {
// //       // جلب جميع الرحلات لهذا الشهر
// //       final snapshot = await _firestore
// //           .collection('dailyWork')
// //           .where(
// //             'date',
// //             isGreaterThanOrEqualTo: Timestamp.fromDate(
// //               DateTime(_selectedYear, _selectedMonth, 1),
// //             ),
// //           )
// //           .where(
// //             'date',
// //             isLessThan: Timestamp.fromDate(
// //               DateTime(_selectedYear, _selectedMonth + 1, 1),
// //             ),
// //           )
// //           .get();

// //       Map<String, Map<String, dynamic>> companyProfitsMap = {};

// //       for (var doc in snapshot.docs) {
// //         final data = doc.data();
// //         final companyId = data['companyId'] as String?;
// //         final companyName = data['companyName'] as String?;

// //         if (companyId != null && companyId.isNotEmpty && companyName != null) {
// //           if (!companyProfitsMap.containsKey(companyId)) {
// //             companyProfitsMap[companyId] = {
// //               'companyId': companyId,
// //               'companyName': companyName,
// //               'totalIncome': 0.0, // دخل الشركة
// //               'totalDriversCost': 0.0, // تكلفة السائقين لهذه الشركة
// //               'companyProfit': 0.0, // ربح الشركة (الدخل - السائقين)
// //             };
// //           }

// //           final companyData = companyProfitsMap[companyId]!;

// //           // إضافة دخل الشركة
// //           final nolon = (data['nolon'] ?? data['noLon'] ?? 0).toDouble();
// //           final companyOvernight = (data['companyOvernight'] ?? 0).toDouble();
// //           final companyHoliday = (data['companyHoliday'] ?? 0).toDouble();

// //           companyData['totalIncome'] +=
// //               nolon + companyOvernight + companyHoliday;

// //           // حساب تكلفة السائقين لهذه الرحلة
// //           final driverName = data['driverName'] as String?;
// //           final contractor = data['contractor'] as String?;

// //           if (driverName != null && contractor != null) {
// //             // البحث عن حساب السائق لهذه الرحلة
// //             final driverQuery = await _firestore
// //                 .collection('drivers')
// //                 .where('date', isEqualTo: data['date'])
// //                 .where('driverName', isEqualTo: driverName)
// //                 .where('contractor', isEqualTo: contractor)
// //                 .limit(1)
// //                 .get();

// //             if (driverQuery.docs.isNotEmpty) {
// //               final driverData = driverQuery.docs.first.data();
// //               final wheelNolon = (driverData['wheelNolon'] ?? 0).toDouble();
// //               final wheelOvernight = (driverData['wheelOvernight'] ?? 0)
// //                   .toDouble();
// //               final wheelHoliday = (driverData['wheelHoliday'] ?? 0).toDouble();

// //               companyData['totalDriversCost'] +=
// //                   wheelNolon + wheelOvernight + wheelHoliday;
// //             }
// //           }
// //         }
// //       }

// //       // حساب ربح كل شركة
// //       List<Map<String, dynamic>> companyProfitsList = [];

// //       for (var entry in companyProfitsMap.entries) {
// //         final companyData = entry.value;
// //         final companyProfit =
// //             companyData['totalIncome'] - companyData['totalDriversCost'];

// //         companyData['companyProfit'] = companyProfit;
// //         companyProfitsList.add(companyData);
// //       }

// //       // ترتيب حسب الربح (الأكبر أولاً)
// //       companyProfitsList.sort(
// //         (a, b) => b['companyProfit'].compareTo(a['companyProfit']),
// //       );

// //       if (mounted) {
// //         setState(() {
// //           _companyProfits = companyProfitsList;
// //         });
// //       }
// //     } catch (e) {
// //       print('خطأ في تحميل أرباح الشركات: $e');
// //     }
// //   }

// //   // ================================
// //   // تحميل الشركاء من صفحة رأس المال
// //   // ================================
// //   Future<void> _loadPartnersFromCapitalPage() async {
// //     try {
// //       final partnersSnapshot = await _firestore
// //           .collection('partners')
// //           .orderBy('createdAt', descending: false)
// //           .get();

// //       List<Map<String, dynamic>> partnersList = [];
// //       Map<String, double> partnerShares = {};

// //       for (var doc in partnersSnapshot.docs) {
// //         final data = doc.data();
// //         final name = data['name']?.toString() ?? 'غير معروف';
// //         final share = (data['share'] as num?)?.toDouble() ?? 0.0;

// //         partnersList.add({
// //           'id': doc.id,
// //           'name': name,
// //           'share': share,
// //           'notes': data['notes'] ?? '',
// //           'createdAt':
// //               (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
// //           'updatedAt': data['updatedAt'] != null
// //               ? (data['updatedAt'] as Timestamp).toDate()
// //               : null,
// //         });

// //         partnerShares[name] = share;
// //       }

// //       if (mounted) {
// //         setState(() {
// //           _partners = partnersList;
// //           _partnerShares = partnerShares;
// //         });
// //       }
// //     } catch (e) {
// //       print('خطأ في تحميل الشركاء: $e');
// //       if (mounted) {
// //         setState(() {
// //           _partners = [];
// //           _partnerShares = {};
// //         });
// //       }
// //     }
// //   }

// //   // ================================
// //   // حساب توزيع الربح على الشركاء
// //   // ================================
// //   void _calculateDistribution() {
// //     if (_partners.isEmpty || _netProfit <= 0) {
// //       if (mounted) {
// //         setState(() {
// //           _totalDistributed = 0;
// //           _remainingProfit = _netProfit;
// //           _isDistributionCompleted = false;
// //         });
// //       }
// //       return;
// //     }

// //     double totalDistributed = 0;

// //     // حساب حصة كل شريك
// //     for (var partner in _partners) {
// //       final percentage = (partner['share'] as num?)?.toDouble() ?? 0.0;
// //       final amount = (_netProfit * percentage) / 100;
// //       partner['profitShare'] = amount;
// //       partner['shareFormatted'] = _formatCurrency(amount);
// //       totalDistributed += amount;
// //     }

// //     if (mounted) {
// //       setState(() {
// //         _totalDistributed = totalDistributed;
// //         _remainingProfit = _netProfit - totalDistributed;
// //         _isDistributionCompleted = (totalDistributed == _netProfit);
// //       });
// //     }
// //   }

// //   // ================================
// //   // تغيير الشهر
// //   // ================================
// //   Future<void> _changeMonth(int month) async {
// //     if (mounted) {
// //       setState(() {
// //         _selectedMonth = month;
// //         _selectedMonthName = _getMonthName(month);
// //         _isLoading = true;
// //       });
// //     }

// //     try {
// //       await _calculateMonthlyTotals();
// //       await _loadCompanyProfits();
// //       _calculateDistribution();
// //     } catch (e) {
// //       _showError('خطأ في تحميل بيانات الشهر');
// //     } finally {
// //       if (mounted) {
// //         setState(() => _isLoading = false);
// //       }
// //     }
// //   }

// //   Future<void> _changeYear(int year) async {
// //     if (mounted) {
// //       setState(() {
// //         _selectedYear = year;
// //         _isLoading = true;
// //       });
// //     }

// //     try {
// //       await _calculateMonthlyTotals();
// //       await _loadCompanyProfits();
// //       _calculateDistribution();
// //     } catch (e) {
// //       _showError('خطأ في تحميل بيانات السنة');
// //     } finally {
// //       if (mounted) {
// //         setState(() => _isLoading = false);
// //       }
// //     }
// //   }

// //   // ================================
// //   // تبويب إجماليات الشهر
// //   // ================================
// //   Widget _buildMonthlyTotalsTab() {
// //     return SingleChildScrollView(
// //       padding: const EdgeInsets.all(16),
// //       child: Column(
// //         children: [
// //           // فلتر الشهر والسنة
// //           _buildMonthYearFilter(),

// //           const SizedBox(height: 20),

// //           // بطاقة الإجماليات
// //           Card(
// //             elevation: 4,
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(16),
// //             ),
// //             child: Container(
// //               padding: const EdgeInsets.all(20),
// //               decoration: BoxDecoration(
// //                 gradient: const LinearGradient(
// //                   begin: Alignment.centerRight,
// //                   end: Alignment.centerLeft,
// //                   colors: [Color(0xFF1B4F72), Color(0xFF3498DB)],
// //                 ),
// //                 borderRadius: BorderRadius.circular(16),
// //               ),
// //               child: Column(
// //                 children: [
// //                   Row(
// //                     children: [
// //                       const Icon(
// //                         Icons.calendar_month,
// //                         color: Colors.white,
// //                         size: 28,
// //                       ),
// //                       const SizedBox(width: 12),
// //                       Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           const Text(
// //                             'إجماليات الشهر',
// //                             style: TextStyle(
// //                               color: Colors.white,
// //                               fontSize: 20,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                           Text(
// //                             '$_selectedMonthName $_selectedYear',
// //                             style: const TextStyle(
// //                               color: Colors.white70,
// //                               fontSize: 14,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),

// //                   const SizedBox(height: 24),

// //                   _buildTotalItem(
// //                     icon: Icons.business,
// //                     label: 'إجمالي دخل الشركات',
// //                     value: _formatCurrency(_totalCompanyIncome),
// //                     color: Colors.green[300]!,
// //                     iconColor: Colors.green,
// //                   ),

// //                   const SizedBox(height: 12),

// //                   _buildTotalItem(
// //                     icon: Icons.person,
// //                     label: 'إجمالي حساب السائقين',
// //                     value: _formatCurrency(_totalDriversExpenses),
// //                     color: Colors.orange[300]!,
// //                     iconColor: Colors.orange,
// //                   ),

// //                   const SizedBox(height: 24),

// //                   Container(
// //                     padding: const EdgeInsets.all(16),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white.withOpacity(0.1),
// //                       borderRadius: BorderRadius.circular(12),
// //                       border: Border.all(color: Colors.white.withOpacity(0.3)),
// //                     ),
// //                     child: Column(
// //                       children: [
// //                         Row(
// //                           children: [
// //                             const Icon(
// //                               Icons.attach_money,
// //                               color: Colors.white,
// //                               size: 24,
// //                             ),
// //                             const SizedBox(width: 12),
// //                             const Text(
// //                               'صافي الربح الشهري',
// //                               style: TextStyle(
// //                                 color: Colors.white,
// //                                 fontSize: 16,
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                             const Spacer(),
// //                             Text(
// //                               _formatCurrency(_netProfit),
// //                               style: TextStyle(
// //                                 color: _netProfit >= 0
// //                                     ? Colors.green[300]!
// //                                     : Colors.red[300]!,
// //                                 fontSize: 24,
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                         const SizedBox(height: 8),
// //                         const Text(
// //                           'الدخل - السائقين',
// //                           style: TextStyle(color: Colors.white70, fontSize: 12),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),

// //           const SizedBox(height: 20),

// //           // إحصائيات الشركاء
// //           if (_partners.isNotEmpty) _buildPartnersSummary(),

// //           const SizedBox(height: 20),

// //           // الانتقال إلى تبويب الشركاء
// //           SizedBox(
// //             width: double.infinity,
// //             child: ElevatedButton.icon(
// //               onPressed: () {
// //                 _calculateDistribution();
// //                 _changeTab(2);
// //               },
// //               icon: const Icon(Icons.groups, size: 20),
// //               label: const Text('عرض توزيع الربح على الشركاء'),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: const Color(0xFF3498DB),
// //                 padding: const EdgeInsets.symmetric(vertical: 14),
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(10),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ================================
// //   // تبويب أرباح الشركات
// //   // ================================
// //   Widget _buildCompaniesProfitsTab() {
// //     return SingleChildScrollView(
// //       padding: const EdgeInsets.all(16),
// //       child: Column(
// //         children: [
// //           Card(
// //             elevation: 2,
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(12),
// //             ),
// //             child: Padding(
// //               padding: const EdgeInsets.all(16),
// //               child: Row(
// //                 children: [
// //                   const Icon(
// //                     Icons.business,
// //                     color: Color(0xFF1B4F72),
// //                     size: 24,
// //                   ),
// //                   const SizedBox(width: 12),
// //                   const Text(
// //                     'أرباح الشركات',
// //                     style: TextStyle(
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.bold,
// //                       color: Color(0xFF1B4F72),
// //                     ),
// //                   ),
// //                   const Spacer(),
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 12,
// //                       vertical: 6,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: Colors.blue[50],
// //                       borderRadius: BorderRadius.circular(20),
// //                     ),
// //                     child: Text(
// //                       '${_companyProfits.length} شركة',
// //                       style: const TextStyle(
// //                         fontWeight: FontWeight.bold,
// //                         color: Colors.blue,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),

// //           const SizedBox(height: 16),

// //           if (_companyProfits.isNotEmpty)
// //             ..._companyProfits.map(
// //               (company) => _buildCompanyProfitCard(company),
// //             )
// //           else
// //             _buildNoDataCard('لا توجد بيانات للشركات هذا الشهر'),

// //           const SizedBox(height: 20),
// //         ],
// //       ),
// //     );
// //   }

// //   // ================================
// //   // تبويب توزيع الربح
// //   // ================================
// //   Widget _buildDistributionTab() {
// //     return SingleChildScrollView(
// //       padding: const EdgeInsets.all(16),
// //       child: Column(
// //         children: [
// //           Card(
// //             elevation: 4,
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(16),
// //             ),
// //             child: Padding(
// //               padding: const EdgeInsets.all(16),
// //               child: Column(
// //                 children: [
// //                   Row(
// //                     children: [
// //                       const Icon(
// //                         Icons.pie_chart,
// //                         color: Color(0xFF1B4F72),
// //                         size: 28,
// //                       ),
// //                       const SizedBox(width: 12),
// //                       Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           const Text(
// //                             'توزيع صافي الربح',
// //                             style: TextStyle(
// //                               fontSize: 18,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                           Text(
// //                             'الشهر: $_selectedMonthName $_selectedYear',
// //                             style: const TextStyle(
// //                               color: Colors.grey,
// //                               fontSize: 12,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const Spacer(),
// //                       Container(
// //                         padding: const EdgeInsets.symmetric(
// //                           horizontal: 12,
// //                           vertical: 6,
// //                         ),
// //                         decoration: BoxDecoration(
// //                           color: _netProfit >= 0
// //                               ? Colors.green[50]
// //                               : Colors.red[50],
// //                           borderRadius: BorderRadius.circular(20),
// //                         ),
// //                         child: Text(
// //                           _formatCurrency(_netProfit),
// //                           style: TextStyle(
// //                             fontWeight: FontWeight.bold,
// //                             color: _netProfit >= 0 ? Colors.green : Colors.red,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),

// //                   const SizedBox(height: 16),

// //                   Container(
// //                     padding: const EdgeInsets.all(16),
// //                     decoration: BoxDecoration(
// //                       color: Colors.grey[50],
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                     child: Column(
// //                       children: [
// //                         Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             const Text('إجمالي الموزع:'),
// //                             Text(
// //                               _formatCurrency(_totalDistributed),
// //                               style: const TextStyle(
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.green,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                         const SizedBox(height: 8),
// //                         Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             const Text('المتبقي للتوزيع:'),
// //                             Text(
// //                               _formatCurrency(_remainingProfit),
// //                               style: const TextStyle(
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.orange,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                         const SizedBox(height: 12),
// //                         if (_isDistributionCompleted)
// //                           Container(
// //                             padding: const EdgeInsets.all(8),
// //                             decoration: BoxDecoration(
// //                               color: Colors.green[50],
// //                               borderRadius: BorderRadius.circular(8),
// //                             ),
// //                             child: const Row(
// //                               mainAxisAlignment: MainAxisAlignment.center,
// //                               children: [
// //                                 Icon(Icons.check_circle, color: Colors.green),
// //                                 SizedBox(width: 8),
// //                                 Text(
// //                                   'تم توزيع كامل الربح',
// //                                   style: TextStyle(
// //                                     color: Colors.green,
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),

// //           const SizedBox(height: 20),

// //           // معلومات هامة
// //           Card(
// //             elevation: 2,
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(12),
// //             ),
// //             child: Padding(
// //               padding: const EdgeInsets.all(16),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Row(
// //                     children: [
// //                       const Icon(Icons.info, color: Colors.blue, size: 20),
// //                       const SizedBox(width: 8),
// //                       const Text(
// //                         'معلومات هامة',
// //                         style: TextStyle(
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.blue,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 8),
// //                   const Text(
// //                     '• يتم توزيع الأرباح بناءً على نسب الشركاء المضافة في صفحة رأس المال',
// //                     style: TextStyle(fontSize: 12, color: Colors.grey),
// //                   ),
// //                   const SizedBox(height: 4),
// //                   const Text(
// //                     '• لإضافة أو تعديل أو حذف الشركاء، يرجى الذهاب إلى صفحة رأس المال',
// //                     style: TextStyle(fontSize: 12, color: Colors.grey),
// //                   ),
// //                   const SizedBox(height: 4),
// //                   const Text(
// //                     '• إجمالي نسب الشركاء: يجب أن يساوي 100% للتوزيع الكامل',
// //                     style: TextStyle(fontSize: 12, color: Colors.grey),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),

// //           const SizedBox(height: 20),

// //           // قائمة الشركاء
// //           if (_partners.isNotEmpty)
// //             ..._partners.map(
// //               (partner) => _buildPartnerDistributionCard(partner),
// //             )
// //           else
// //             _buildNoPartnersCard(),

// //           const SizedBox(height: 20),

// //           // زر تحديث التوزيع
// //           SizedBox(
// //             width: double.infinity,
// //             child: ElevatedButton.icon(
// //               onPressed: () {
// //                 _calculateDistribution();
// //                 _showSuccess('تم تحديث التوزيع');
// //               },
// //               icon: const Icon(Icons.refresh, size: 20),
// //               label: const Text('تحديث التوزيع'),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: const Color(0xFF1B4F72),
// //                 padding: const EdgeInsets.symmetric(vertical: 14),
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(10),
// //                 ),
// //               ),
// //             ),
// //           ),

// //           const SizedBox(height: 16),
// //         ],
// //       ),
// //     );
// //   }

// //   // ================================
// //   // Widgets المساعدة
// //   // ================================

// //   Widget _buildMonthYearFilter() {
// //     return Card(
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           children: [
// //             const Text(
// //               'اختر الشهر والسنة',
// //               style: TextStyle(
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 16,
// //                 color: Color(0xFF2C3E50),
// //               ),
// //             ),
// //             const SizedBox(height: 16),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 DropdownButton<int>(
// //                   value: _selectedMonth,
// //                   onChanged: (value) {
// //                     if (value != null) {
// //                       _changeMonth(value);
// //                     }
// //                   },
// //                   items: List.generate(12, (index) {
// //                     final monthNumber = index + 1;
// //                     return DropdownMenuItem(
// //                       value: monthNumber,
// //                       child: Text(_getMonthName(monthNumber)),
// //                     );
// //                   }),
// //                 ),
// //                 const SizedBox(width: 20),
// //                 DropdownButton<int>(
// //                   value: _selectedYear,
// //                   onChanged: (value) {
// //                     if (value != null) {
// //                       _changeYear(value);
// //                     }
// //                   },
// //                   items: [
// //                     for (
// //                       int i = DateTime.now().year - 5;
// //                       i <= DateTime.now().year + 1;
// //                       i++
// //                     )
// //                       DropdownMenuItem(value: i, child: Text('$i')),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildTotalItem({
// //     required IconData icon,
// //     required String label,
// //     required String value,
// //     required Color color,
// //     required Color iconColor,
// //   }) {
// //     return Container(
// //       padding: const EdgeInsets.all(12),
// //       decoration: BoxDecoration(
// //         color: Colors.white.withOpacity(0.05),
// //         borderRadius: BorderRadius.circular(10),
// //         border: Border.all(color: Colors.white.withOpacity(0.1)),
// //       ),
// //       child: Row(
// //         children: [
// //           Icon(icon, color: iconColor, size: 22),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: Text(
// //               label,
// //               style: const TextStyle(color: Colors.white, fontSize: 16),
// //             ),
// //           ),
// //           Text(
// //             value,
// //             style: TextStyle(
// //               color: color,
// //               fontSize: 18,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildPartnersSummary() {
// //     if (_partners.isEmpty) return const SizedBox();

// //     double totalPercentage = 0;
// //     for (var partner in _partners) {
// //       totalPercentage += (partner['share'] as num?)?.toDouble() ?? 0;
// //     }

// //     return Card(
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           children: [
// //             Row(
// //               children: [
// //                 const Icon(Icons.group, color: Color(0xFF3498DB), size: 24),
// //                 const SizedBox(width: 12),
// //                 const Text(
// //                   'ملخص الشركاء',
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 16,
// //                     color: Color(0xFF2C3E50),
// //                   ),
// //                 ),
// //                 const Spacer(),
// //                 Container(
// //                   padding: const EdgeInsets.symmetric(
// //                     horizontal: 12,
// //                     vertical: 6,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     color: totalPercentage == 100
// //                         ? Colors.green[50]
// //                         : Colors.orange[50],
// //                     borderRadius: BorderRadius.circular(20),
// //                   ),
// //                   child: Text(
// //                     '${_partners.length} شريك',
// //                     style: TextStyle(
// //                       fontWeight: FontWeight.bold,
// //                       color: totalPercentage == 100
// //                           ? Colors.green
// //                           : Colors.orange,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 12),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 const Text('إجمالي النسب:'),
// //                 Text(
// //                   '${totalPercentage.toStringAsFixed(2)}%',
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     color: totalPercentage == 100
// //                         ? Colors.green
// //                         : totalPercentage > 100
// //                         ? Colors.red
// //                         : Colors.orange,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 8),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 const Text('المتبقي:'),
// //                 Text(
// //                   '${(100 - totalPercentage).toStringAsFixed(2)}%',
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.blue,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildCompanyProfitCard(Map<String, dynamic> company) {
// //     final companyName = company['companyName'];
// //     final totalIncome = company['totalIncome'] as double;
// //     final driversCost = company['totalDriversCost'] as double;
// //     final profit = totalIncome - driversCost;

// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 12),
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Row(
// //           children: [
// //             Container(
// //               width: 50,
// //               height: 50,
// //               decoration: BoxDecoration(
// //                 color: _getCompanyColor(companyName),
// //                 borderRadius: BorderRadius.circular(25),
// //               ),
// //               child: Center(
// //                 child: Text(
// //                   _getCompanyInitials(companyName),
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 18,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ),
// //             ),

// //             const SizedBox(width: 16),

// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     companyName,
// //                     style: const TextStyle(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.bold,
// //                       color: Color(0xFF2C3E50),
// //                     ),
// //                   ),

// //                   const SizedBox(height: 8),

// //                   Row(
// //                     children: [
// //                       Expanded(
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Text(
// //                               'الدخل',
// //                               style: TextStyle(
// //                                 fontSize: 12,
// //                                 color: Colors.grey[600],
// //                               ),
// //                             ),
// //                             Text(
// //                               _formatCurrency(totalIncome),
// //                               style: const TextStyle(
// //                                 fontSize: 14,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.green,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),

// //                       Expanded(
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Text(
// //                               'حساب السائقين',
// //                               style: TextStyle(
// //                                 fontSize: 12,
// //                                 color: Colors.grey[600],
// //                               ),
// //                             ),
// //                             Text(
// //                               _formatCurrency(driversCost),
// //                               style: const TextStyle(
// //                                 fontSize: 14,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.orange,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),

// //                       Expanded(
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Text(
// //                               'صافي الربح',
// //                               style: TextStyle(
// //                                 fontSize: 12,
// //                                 color: Colors.grey[600],
// //                               ),
// //                             ),
// //                             Text(
// //                               _formatCurrency(profit),
// //                               style: TextStyle(
// //                                 fontSize: 14,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: profit >= 0 ? Colors.blue : Colors.red,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildPartnerDistributionCard(Map<String, dynamic> partner) {
// //     final percentage = (partner['share'] as num?)?.toDouble() ?? 0.0;
// //     final share = (partner['profitShare'] as num?)?.toDouble() ?? 0.0;
// //     final notes = partner['notes']?.toString() ?? '';

// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 12),
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           children: [
// //             Row(
// //               children: [
// //                 Container(
// //                   width: 50,
// //                   height: 50,
// //                   decoration: BoxDecoration(
// //                     color: _getPartnerColor(partner['name']),
// //                     borderRadius: BorderRadius.circular(25),
// //                   ),
// //                   child: Center(
// //                     child: Text(
// //                       _getInitials(partner['name']),
// //                       style: const TextStyle(
// //                         color: Colors.white,
// //                         fontSize: 18,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                   ),
// //                 ),

// //                 const SizedBox(width: 16),

// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Row(
// //                         children: [
// //                           Expanded(
// //                             child: Text(
// //                               partner['name'],
// //                               style: const TextStyle(
// //                                 fontSize: 16,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Color(0xFF2C3E50),
// //                               ),
// //                             ),
// //                           ),
// //                           Container(
// //                             padding: const EdgeInsets.symmetric(
// //                               horizontal: 12,
// //                               vertical: 4,
// //                             ),
// //                             decoration: BoxDecoration(
// //                               color: Colors.blue[50],
// //                               borderRadius: BorderRadius.circular(20),
// //                             ),
// //                             child: Text(
// //                               '${percentage.toStringAsFixed(1)}%',
// //                               style: const TextStyle(
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.blue,
// //                                 fontSize: 14,
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),

// //                       const SizedBox(height: 8),

// //                       Row(
// //                         children: [
// //                           Expanded(
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Text(
// //                                   'حصة الشريك',
// //                                   style: TextStyle(
// //                                     fontSize: 12,
// //                                     color: Colors.grey[600],
// //                                   ),
// //                                 ),
// //                                 Text(
// //                                   _formatCurrency(share),
// //                                   style: const TextStyle(
// //                                     fontSize: 16,
// //                                     fontWeight: FontWeight.bold,
// //                                     color: Colors.green,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),

// //                           Column(
// //                             crossAxisAlignment: CrossAxisAlignment.end,
// //                             children: [
// //                               Text(
// //                                 'نسبة من الربح',
// //                                 style: TextStyle(
// //                                   fontSize: 12,
// //                                   color: Colors.grey[600],
// //                                 ),
// //                               ),
// //                               Text(
// //                                 _netProfit > 0
// //                                     ? '${((share / _netProfit) * 100).toStringAsFixed(1)}%'
// //                                     : '0%',
// //                                 style: const TextStyle(
// //                                   fontSize: 14,
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Colors.blue,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),

// //             // عرض الملاحظات إذا وجدت
// //             if (notes.isNotEmpty)
// //               Column(
// //                 children: [
// //                   const SizedBox(height: 8),
// //                   Container(
// //                     padding: const EdgeInsets.all(8),
// //                     width: double.infinity,
// //                     decoration: BoxDecoration(
// //                       color: Colors.grey[50],
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         const Text(
// //                           'ملاحظات:',
// //                           style: TextStyle(
// //                             fontSize: 12,
// //                             fontWeight: FontWeight.bold,
// //                             color: Colors.grey,
// //                           ),
// //                         ),
// //                         Text(notes, style: const TextStyle(fontSize: 12)),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildNoPartnersCard() {
// //     return Card(
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(32),
// //         child: Column(
// //           children: [
// //             Icon(Icons.group, size: 60, color: Colors.grey[400]),
// //             const SizedBox(height: 16),
// //             const Text(
// //               'لا يوجد شركاء مضافة',
// //               textAlign: TextAlign.center,
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 color: Colors.grey,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             const SizedBox(height: 8),
// //             const Text(
// //               'يجب إضافة الشركاء أولاً من صفحة رأس المال',
// //               textAlign: TextAlign.center,
// //               style: TextStyle(fontSize: 12, color: Colors.grey),
// //             ),
// //             const SizedBox(height: 16),
// //             ElevatedButton.icon(
// //               onPressed: () {
// //                 Navigator.pop(context);
// //               },
// //               icon: const Icon(Icons.arrow_back, size: 18),
// //               label: const Text('العودة لصفحة رأس المال'),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: const Color(0xFF1B4F72),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildNoDataCard(String message) {
// //     return Card(
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(32),
// //         child: Column(
// //           children: [
// //             Icon(Icons.info_outline, size: 60, color: Colors.grey[400]),
// //             const SizedBox(height: 16),
// //             Text(
// //               message,
// //               textAlign: TextAlign.center,
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 color: Colors.grey[600],
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ================================
// //   // دوال مساعدة
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
// //         return 'غير معروف';
// //     }
// //   }

// //   Color _getPartnerColor(String name) {
// //     final hash = name.hashCode;
// //     return Color(hash & 0xFFFFFF).withOpacity(1.0).withBlue(150);
// //   }

// //   Color _getCompanyColor(String name) {
// //     final hash = name.hashCode;
// //     return Color(hash & 0xFFFFFF).withOpacity(1.0).withGreen(150);
// //   }

// //   String _getInitials(String name) {
// //     if (name.isEmpty) return '??';

// //     final trimmedName = name.trim();
// //     final words = trimmedName.split(' ');

// //     final validWords = words.where((word) => word.isNotEmpty).toList();

// //     if (validWords.isEmpty) return '??';

// //     if (validWords.length >= 2) {
// //       return '${validWords[0][0]}${validWords[1][0]}'.toUpperCase();
// //     } else {
// //       final word = validWords[0];
// //       if (word.length >= 2) {
// //         return word.substring(0, 2).toUpperCase();
// //       } else {
// //         return word.toUpperCase();
// //       }
// //     }
// //   }

// //   String _getCompanyInitials(String name) {
// //     if (name.isEmpty) return '??';

// //     final trimmedName = name.trim();
// //     final words = trimmedName.split(' ');

// //     final validWords = words.where((word) => word.isNotEmpty).toList();

// //     if (validWords.isEmpty) return '??';

// //     // للحصول على أول حرف من أول كلمة
// //     return validWords[0][0].toUpperCase();
// //   }

// //   String _formatCurrency(double amount) {
// //     return '${amount.toStringAsFixed(2)} ج';
// //   }

// //   void _changeTab(int index) {
// //     if (mounted) {
// //       setState(() {
// //         _currentTab = index;
// //       });
// //     }
// //   }

// //   void _showError(String message) {
// //     if (mounted) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text(message),
// //           backgroundColor: Colors.red,
// //           duration: const Duration(seconds: 2),
// //         ),
// //       );
// //     }
// //   }

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

// //   // ================================
// //   // بناء الواجهة الرئيسية
// //   // ================================

// //   @override
// //   Widget build(BuildContext context) {
// //     return DefaultTabController(
// //       length: 3,
// //       initialIndex: _currentTab,
// //       child: Scaffold(
// //         appBar: AppBar(
// //           title: const Text(
// //             'توزيع الأرباح الشهرية',
// //             style: TextStyle(color: Colors.white),
// //           ),
// //           centerTitle: true,
// //           backgroundColor: const Color(0xFF1B4F72),
// //           bottom: TabBar(
// //             onTap: _changeTab,
// //             indicatorColor: Colors.amber,
// //             labelColor: Colors.amber,
// //             unselectedLabelColor: Colors.white,
// //             tabs: const [
// //               Tab(icon: Icon(Icons.calculate), text: 'إجماليات الشهر'),
// //               Tab(icon: Icon(Icons.business), text: 'أرباح الشركات'),
// //               Tab(icon: Icon(Icons.groups), text: 'توزيع الربح'),
// //             ],
// //           ),
// //         ),
// //         body: _isLoading
// //             ? const Center(child: CircularProgressIndicator())
// //             : TabBarView(
// //                 children: [
// //                   _buildMonthlyTotalsTab(),
// //                   _buildCompaniesProfitsTab(),
// //                   _buildDistributionTab(),
// //                 ],
// //               ),
// //       ),
// //     );
// //   }
// // // }
// // import 'dart:async';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';

// // class MonthlyProfitsPage extends StatefulWidget {
// //   const MonthlyProfitsPage({super.key});

// //   @override
// //   State<MonthlyProfitsPage> createState() => _MonthlyProfitsPageState();
// // }

// // class _MonthlyProfitsPageState extends State<MonthlyProfitsPage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// //   // ================================
// //   // بيانات الشهر الحالي
// //   // ================================
// //   int _selectedYear = DateTime.now().year;
// //   int _selectedMonth = DateTime.now().month;
// //   String _selectedMonthName = '';

// //   // ================================
// //   // إجماليات الشهر
// //   // ================================
// //   double _totalCompanyIncome = 0.0; // إجمالي دخل الشركات
// //   double _totalDriversExpenses = 0.0; // إجمالي حساب السائقين
// //   double _netProfit = 0.0; // صافي الربح (الدخل - السائقين)

// //   // ================================
// //   // بيانات الشركات المنفصلة
// //   // ================================
// //   List<Map<String, dynamic>> _companyProfits = [];

// //   // ================================
// //   // بيانات الشركاء والتوزيع
// //   // ================================
// //   List<Map<String, dynamic>> _partners = [];
// //   double _totalDistributed = 0.0;
// //   double _remainingProfit = 0.0;
// //   bool _isDistributionCompleted = false;

// //   // ================================
// //   // متغيرات التحكم
// //   // ================================
// //   bool _isLoading = false;
// //   int _currentTab = 0;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _selectedMonthName = _getMonthName(_selectedMonth);
// //     _loadAllData();
// //   }

// //   // ================================
// //   // تحميل كل البيانات
// //   // ================================
// //   Future<void> _loadAllData() async {
// //     if (mounted) {
// //       setState(() => _isLoading = true);
// //     }

// //     try {
// //       await _calculateMonthlyTotals();
// //       await _loadCompanyProfits();
// //       await _loadPartnersFromCapitalPage();
// //       _calculateDistribution();
// //     } catch (e) {
// //       print('خطأ في تحميل البيانات: $e');
// //       _showError('خطأ في تحميل البيانات');
// //     } finally {
// //       if (mounted) {
// //         setState(() => _isLoading = false);
// //       }
// //     }
// //   }

// //   // ================================
// //   // حساب إجماليات الشهر
// //   // ================================
// //   Future<void> _calculateMonthlyTotals() async {
// //     try {
// //       double totalCompanyIncome = 0;
// //       double totalDriversExpenses = 0;

// //       // ================================
// //       // 1. حساب إجمالي دخل الشركات من dailyWork
// //       // ================================
// //       final companySnapshot = await _firestore
// //           .collection('dailyWork')
// //           .where(
// //             'date',
// //             isGreaterThanOrEqualTo: Timestamp.fromDate(
// //               DateTime(_selectedYear, _selectedMonth, 1),
// //             ),
// //           )
// //           .where(
// //             'date',
// //             isLessThan: Timestamp.fromDate(
// //               DateTime(_selectedYear, _selectedMonth + 1, 1),
// //             ),
// //           )
// //           .get();

// //       for (var doc in companySnapshot.docs) {
// //         final data = doc.data();

// //         // دخل الشركة من الرحلات
// //         final nolon = (data['nolon'] ?? data['noLon'] ?? 0).toDouble();
// //         final companyOvernight = (data['companyOvernight'] ?? 0).toDouble();
// //         final companyHoliday = (data['companyHoliday'] ?? 0).toDouble();

// //         totalCompanyIncome += nolon + companyOvernight + companyHoliday;
// //       }

// //       // ================================
// //       // 2. حساب إجمالي حساب السائقين
// //       // ================================
// //       final driversSnapshot = await _firestore
// //           .collection('drivers')
// //           .where(
// //             'date',
// //             isGreaterThanOrEqualTo: Timestamp.fromDate(
// //               DateTime(_selectedYear, _selectedMonth, 1),
// //             ),
// //           )
// //           .where(
// //             'date',
// //             isLessThan: Timestamp.fromDate(
// //               DateTime(_selectedYear, _selectedMonth + 1, 1),
// //             ),
// //           )
// //           .get();

// //       for (var doc in driversSnapshot.docs) {
// //         final data = doc.data();

// //         // حساب السائقين
// //         final wheelNolon = (data['wheelNolon'] ?? 0).toDouble();
// //         final wheelOvernight = (data['wheelOvernight'] ?? 0).toDouble();
// //         final wheelHoliday = (data['wheelHoliday'] ?? 0).toDouble();

// //         totalDriversExpenses += wheelNolon + wheelOvernight + wheelHoliday;
// //       }

// //       // ================================
// //       // 3. حساب صافي الربح (بدون ضرائب)
// //       // ================================
// //       final netProfit = totalCompanyIncome - totalDriversExpenses;

// //       if (mounted) {
// //         setState(() {
// //           _totalCompanyIncome = totalCompanyIncome;
// //           _totalDriversExpenses = totalDriversExpenses;
// //           _netProfit = netProfit;
// //         });
// //       }
// //     } catch (e) {
// //       print('خطأ في حساب الإجماليات: $e');
// //       throw e;
// //     }
// //   }

// //   // ================================
// //   // تحميل أرباح كل شركة منفصلة (مصححة)
// //   // ================================
// //   Future<void> _loadCompanyProfits() async {
// //     try {
// //       // جلب جميع الرحلات لهذا الشهر
// //       final companySnapshot = await _firestore
// //           .collection('dailyWork')
// //           .where(
// //             'date',
// //             isGreaterThanOrEqualTo: Timestamp.fromDate(
// //               DateTime(_selectedYear, _selectedMonth, 1),
// //             ),
// //           )
// //           .where(
// //             'date',
// //             isLessThan: Timestamp.fromDate(
// //               DateTime(_selectedYear, _selectedMonth + 1, 1),
// //             ),
// //           )
// //           .get();

// //       // جلب جميع بيانات السائقين لهذا الشهر
// //       final driversSnapshot = await _firestore
// //           .collection('drivers')
// //           .where(
// //             'date',
// //             isGreaterThanOrEqualTo: Timestamp.fromDate(
// //               DateTime(_selectedYear, _selectedMonth, 1),
// //             ),
// //           )
// //           .where(
// //             'date',
// //             isLessThan: Timestamp.fromDate(
// //               DateTime(_selectedYear, _selectedMonth + 1, 1),
// //             ),
// //           )
// //           .get();

// //       // تحويل بيانات السائقين إلى Map لتسهيل البحث
// //       Map<String, List<Map<String, dynamic>>> driversByDate = {};

// //       for (var doc in driversSnapshot.docs) {
// //         final data = doc.data();
// //         final date = data['date'] as Timestamp?;

// //         if (date != null) {
// //           final dateString = _formatTimestampToDateKey(date);
// //           final driverName = data['driverName']?.toString() ?? '';
// //           final contractor = data['contractor']?.toString() ?? '';

// //           if (!driversByDate.containsKey(dateString)) {
// //             driversByDate[dateString] = [];
// //           }

// //           driversByDate[dateString]!.add({
// //             'driverName': driverName,
// //             'contractor': contractor,
// //             'wheelNolon': (data['wheelNolon'] ?? 0).toDouble(),
// //             'wheelOvernight': (data['wheelOvernight'] ?? 0).toDouble(),
// //             'wheelHoliday': (data['wheelHoliday'] ?? 0).toDouble(),
// //           });
// //         }
// //       }

// //       Map<String, Map<String, dynamic>> companyProfitsMap = {};

// //       // معالجة بيانات dailyWork
// //       for (var doc in companySnapshot.docs) {
// //         final data = doc.data();
// //         final companyId = data['companyId'] as String?;
// //         final companyName = data['companyName'] as String?;

// //         if (companyId != null && companyId.isNotEmpty && companyName != null) {
// //           if (!companyProfitsMap.containsKey(companyId)) {
// //             companyProfitsMap[companyId] = {
// //               'companyId': companyId,
// //               'companyName': companyName,
// //               'totalIncome': 0.0,
// //               'totalDriversCost': 0.0,
// //               'companyProfit': 0.0,
// //               'tripCount': 0,
// //             };
// //           }

// //           final companyData = companyProfitsMap[companyId]!;

// //           // إضافة دخل الشركة
// //           final nolon = (data['nolon'] ?? data['noLon'] ?? 0).toDouble();
// //           final companyOvernight = (data['companyOvernight'] ?? 0).toDouble();
// //           final companyHoliday = (data['companyHoliday'] ?? 0).toDouble();

// //           companyData['totalIncome'] +=
// //               nolon + companyOvernight + companyHoliday;
// //           companyData['tripCount'] = (companyData['tripCount'] ?? 0) + 1;

// //           // البحث عن تكاليف السائق لهذه الرحلة
// //           final driverName = data['driverName'] as String?;
// //           final contractor = data['contractor'] as String?;
// //           final tripDate = data['date'] as Timestamp?;

// //           if (driverName != null &&
// //               contractor != null &&
// //               tripDate != null &&
// //               driverName.isNotEmpty &&
// //               contractor.isNotEmpty) {
// //             final dateString = _formatTimestampToDateKey(tripDate);

// //             if (driversByDate.containsKey(dateString)) {
// //               // البحث عن السائق في هذا التاريخ
// //               final driversForDate = driversByDate[dateString]!;

// //               for (var driverData in driversForDate) {
// //                 final currentDriverName = driverData['driverName'] as String;
// //                 final currentContractor = driverData['contractor'] as String;

// //                 // مطابقة اسم السائق والمقاول
// //                 if (_normalizeString(currentDriverName) ==
// //                         _normalizeString(driverName) &&
// //                     _normalizeString(currentContractor) ==
// //                         _normalizeString(contractor)) {
// //                   // وجدنا بيانات السائق المناسبة
// //                   final wheelNolon = driverData['wheelNolon'] as double;
// //                   final wheelOvernight = driverData['wheelOvernight'] as double;
// //                   final wheelHoliday = driverData['wheelHoliday'] as double;

// //                   companyData['totalDriversCost'] +=
// //                       wheelNolon + wheelOvernight + wheelHoliday;
// //                   break;
// //                 }
// //               }
// //             }
// //           }
// //         }
// //       }

// //       // حساب ربح كل شركة
// //       List<Map<String, dynamic>> companyProfitsList = [];

// //       for (var entry in companyProfitsMap.entries) {
// //         final companyData = entry.value;
// //         final companyProfit =
// //             companyData['totalIncome'] - companyData['totalDriversCost'];

// //         companyData['companyProfit'] = companyProfit;
// //         companyData.remove('tripCount'); // إزالة حقل العد المؤقت
// //         companyProfitsList.add(companyData);
// //       }

// //       // ترتيب حسب الربح (الأكبر أولاً)
// //       companyProfitsList.sort(
// //         (a, b) => b['companyProfit'].compareTo(a['companyProfit']),
// //       );

// //       if (mounted) {
// //         setState(() {
// //           _companyProfits = companyProfitsList;
// //         });
// //       }
// //     } catch (e) {
// //       print('خطأ في تحميل أرباح الشركات: $e');
// //       if (mounted) {
// //         setState(() {
// //           _companyProfits = [];
// //         });
// //       }
// //     }
// //   }

// //   // ================================
// //   // تحويل Timestamp إلى مفتاح تاريخ
// //   // ================================
// //   String _formatTimestampToDateKey(Timestamp timestamp) {
// //     try {
// //       final date = timestamp.toDate();
// //       return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
// //     } catch (e) {
// //       return '';
// //     }
// //   }

// //   // ================================
// //   // تطبيع النصوص للمقارنة
// //   // ================================
// //   String _normalizeString(String text) {
// //     return text.trim().toLowerCase();
// //   }

// //   // ================================
// //   // تحميل الشركاء من صفحة رأس المال
// //   // ================================
// //   Future<void> _loadPartnersFromCapitalPage() async {
// //     try {
// //       final partnersSnapshot = await _firestore
// //           .collection('partners')
// //           .orderBy('createdAt', descending: false)
// //           .get();

// //       List<Map<String, dynamic>> partnersList = [];

// //       for (var doc in partnersSnapshot.docs) {
// //         final data = doc.data();
// //         final name = data['name']?.toString() ?? 'غير معروف';
// //         final share = (data['share'] as num?)?.toDouble() ?? 0.0;

// //         partnersList.add({
// //           'id': doc.id,
// //           'name': name,
// //           'share': share,
// //           'notes': data['notes'] ?? '',
// //           'createdAt':
// //               (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
// //           'updatedAt': data['updatedAt'] != null
// //               ? (data['updatedAt'] as Timestamp).toDate()
// //               : null,
// //         });
// //       }

// //       if (mounted) {
// //         setState(() {
// //           _partners = partnersList;
// //         });
// //       }
// //     } catch (e) {
// //       print('خطأ في تحميل الشركاء: $e');
// //       if (mounted) {
// //         setState(() {
// //           _partners = [];
// //         });
// //       }
// //     }
// //   }

// //   // ================================
// //   // حساب توزيع الربح على الشركاء
// //   // ================================
// //   void _calculateDistribution() {
// //     if (_partners.isEmpty || _netProfit <= 0) {
// //       if (mounted) {
// //         setState(() {
// //           _totalDistributed = 0;
// //           _remainingProfit = _netProfit;
// //           _isDistributionCompleted = false;
// //         });
// //       }
// //       return;
// //     }

// //     double totalDistributed = 0;

// //     // حساب حصة كل شريك
// //     for (var partner in _partners) {
// //       final percentage = (partner['share'] as num?)?.toDouble() ?? 0.0;
// //       final amount = (_netProfit * percentage) / 100;
// //       partner['profitShare'] = amount;
// //       partner['shareFormatted'] = _formatCurrency(amount);
// //       totalDistributed += amount;
// //     }

// //     if (mounted) {
// //       setState(() {
// //         _totalDistributed = totalDistributed;
// //         _remainingProfit = _netProfit - totalDistributed;
// //         _isDistributionCompleted = (totalDistributed == _netProfit);
// //       });
// //     }
// //   }

// //   // ================================
// //   // تغيير الشهر
// //   // ================================
// //   Future<void> _changeMonth(int month) async {
// //     if (mounted) {
// //       setState(() {
// //         _selectedMonth = month;
// //         _selectedMonthName = _getMonthName(month);
// //         _isLoading = true;
// //       });
// //     }

// //     try {
// //       await _calculateMonthlyTotals();
// //       await _loadCompanyProfits();
// //       _calculateDistribution();
// //     } catch (e) {
// //       _showError('خطأ في تحميل بيانات الشهر');
// //     } finally {
// //       if (mounted) {
// //         setState(() => _isLoading = false);
// //       }
// //     }
// //   }

// //   Future<void> _changeYear(int year) async {
// //     if (mounted) {
// //       setState(() {
// //         _selectedYear = year;
// //         _isLoading = true;
// //       });
// //     }

// //     try {
// //       await _calculateMonthlyTotals();
// //       await _loadCompanyProfits();
// //       _calculateDistribution();
// //     } catch (e) {
// //       _showError('خطأ في تحميل بيانات السنة');
// //     } finally {
// //       if (mounted) {
// //         setState(() => _isLoading = false);
// //       }
// //     }
// //   }

// //   // ================================
// //   // تبويب إجماليات الشهر
// //   // ================================
// //   Widget _buildMonthlyTotalsTab() {
// //     return SingleChildScrollView(
// //       padding: const EdgeInsets.all(16),
// //       child: Column(
// //         children: [
// //           // فلتر الشهر والسنة
// //           _buildMonthYearFilter(),

// //           const SizedBox(height: 20),

// //           // بطاقة الإجماليات
// //           Card(
// //             elevation: 4,
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(16),
// //             ),
// //             child: Container(
// //               padding: const EdgeInsets.all(20),
// //               decoration: BoxDecoration(
// //                 gradient: const LinearGradient(
// //                   begin: Alignment.centerRight,
// //                   end: Alignment.centerLeft,
// //                   colors: [Color(0xFF1B4F72), Color(0xFF3498DB)],
// //                 ),
// //                 borderRadius: BorderRadius.circular(16),
// //               ),
// //               child: Column(
// //                 children: [
// //                   Row(
// //                     children: [
// //                       const Icon(
// //                         Icons.calendar_month,
// //                         color: Colors.white,
// //                         size: 28,
// //                       ),
// //                       const SizedBox(width: 12),
// //                       Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           const Text(
// //                             'إجماليات الشهر',
// //                             style: TextStyle(
// //                               color: Colors.white,
// //                               fontSize: 20,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                           Text(
// //                             '$_selectedMonthName $_selectedYear',
// //                             style: const TextStyle(color: Colors.white70),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),

// //                   const SizedBox(height: 24),

// //                   _buildTotalItem(
// //                     icon: Icons.business,
// //                     label: 'إجمالي دخل الشركات',
// //                     value: _formatCurrency(_totalCompanyIncome),
// //                     color: Colors.green[300]!,
// //                     iconColor: Colors.green,
// //                   ),

// //                   const SizedBox(height: 12),

// //                   _buildTotalItem(
// //                     icon: Icons.person,
// //                     label: 'إجمالي حساب السائقين',
// //                     value: _formatCurrency(_totalDriversExpenses),
// //                     color: Colors.orange[300]!,
// //                     iconColor: Colors.orange,
// //                   ),

// //                   const SizedBox(height: 24),

// //                   Container(
// //                     padding: const EdgeInsets.all(16),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white.withOpacity(0.1),
// //                       borderRadius: BorderRadius.circular(12),
// //                       border: Border.all(color: Colors.white.withOpacity(0.3)),
// //                     ),
// //                     child: Column(
// //                       children: [
// //                         Row(
// //                           children: [
// //                             const Icon(
// //                               Icons.attach_money,
// //                               color: Colors.white,
// //                               size: 24,
// //                             ),
// //                             const SizedBox(width: 12),
// //                             const Text(
// //                               'صافي الربح الشهري',
// //                               style: TextStyle(
// //                                 color: Colors.white,
// //                                 fontSize: 16,
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                             const Spacer(),
// //                             Text(
// //                               _formatCurrency(_netProfit),
// //                               style: TextStyle(
// //                                 color: _netProfit >= 0
// //                                     ? Colors.green[300]!
// //                                     : Colors.red[300]!,
// //                                 fontSize: 24,
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                         const SizedBox(height: 8),
// //                         const Text(
// //                           'الدخل - السائقين',
// //                           style: TextStyle(color: Colors.white70, fontSize: 12),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),

// //           const SizedBox(height: 20),

// //           // إحصائيات الشركاء
// //           if (_partners.isNotEmpty) _buildPartnersSummary(),

// //           const SizedBox(height: 20),

// //           // الانتقال إلى تبويب الشركاء
// //           SizedBox(
// //             width: double.infinity,
// //             child: ElevatedButton.icon(
// //               onPressed: () {
// //                 _calculateDistribution();
// //                 _changeTab(2);
// //               },
// //               icon: const Icon(Icons.groups, size: 20),
// //               label: const Text('عرض توزيع الربح على الشركاء'),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: const Color(0xFF3498DB),
// //                 padding: const EdgeInsets.symmetric(vertical: 14),
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(10),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ================================
// //   // تبويب أرباح الشركات
// //   // ================================
// //   Widget _buildCompaniesProfitsTab() {
// //     return SingleChildScrollView(
// //       padding: const EdgeInsets.all(16),
// //       child: Column(
// //         children: [
// //           Card(
// //             elevation: 2,
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(12),
// //             ),
// //             child: Padding(
// //               padding: const EdgeInsets.all(16),
// //               child: Row(
// //                 children: [
// //                   const Icon(
// //                     Icons.business,
// //                     color: Color(0xFF1B4F72),
// //                     size: 24,
// //                   ),
// //                   const SizedBox(width: 12),
// //                   const Text(
// //                     'أرباح الشركات',
// //                     style: TextStyle(
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.bold,
// //                       color: Color(0xFF1B4F72),
// //                     ),
// //                   ),
// //                   const Spacer(),
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 12,
// //                       vertical: 6,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: Colors.blue[50],
// //                       borderRadius: BorderRadius.circular(20),
// //                     ),
// //                     child: Text(
// //                       '${_companyProfits.length} شركة',
// //                       style: const TextStyle(
// //                         fontWeight: FontWeight.bold,
// //                         color: Colors.blue,
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),

// //           const SizedBox(height: 16),

// //           if (_companyProfits.isNotEmpty)
// //             ..._companyProfits.map(
// //               (company) => _buildCompanyProfitCard(company),
// //             )
// //           else
// //             _buildNoDataCard('لا توجد بيانات للشركات هذا الشهر'),

// //           const SizedBox(height: 20),
// //         ],
// //       ),
// //     );
// //   }

// //   // ================================
// //   // تبويب توزيع الربح
// //   // ================================
// //   Widget _buildDistributionTab() {
// //     return SingleChildScrollView(
// //       padding: const EdgeInsets.all(16),
// //       child: Column(
// //         children: [
// //           Card(
// //             elevation: 4,
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(16),
// //             ),
// //             child: Padding(
// //               padding: const EdgeInsets.all(16),
// //               child: Column(
// //                 children: [
// //                   Row(
// //                     children: [
// //                       const Icon(
// //                         Icons.pie_chart,
// //                         color: Color(0xFF1B4F72),
// //                         size: 28,
// //                       ),
// //                       const SizedBox(width: 12),
// //                       Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           const Text(
// //                             'توزيع صافي الربح',
// //                             style: TextStyle(
// //                               fontSize: 18,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                           Text(
// //                             'الشهر: $_selectedMonthName $_selectedYear',
// //                             style: const TextStyle(
// //                               color: Colors.grey,
// //                               fontSize: 12,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       const Spacer(),
// //                       Container(
// //                         padding: const EdgeInsets.symmetric(
// //                           horizontal: 12,
// //                           vertical: 6,
// //                         ),
// //                         decoration: BoxDecoration(
// //                           color: _netProfit >= 0
// //                               ? Colors.green[50]
// //                               : Colors.red[50],
// //                           borderRadius: BorderRadius.circular(20),
// //                         ),
// //                         child: Text(
// //                           _formatCurrency(_netProfit),
// //                           style: TextStyle(
// //                             fontWeight: FontWeight.bold,
// //                             color: _netProfit >= 0 ? Colors.green : Colors.red,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),

// //                   const SizedBox(height: 16),

// //                   Container(
// //                     padding: const EdgeInsets.all(16),
// //                     decoration: BoxDecoration(
// //                       color: Colors.grey[50],
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                     child: Column(
// //                       children: [
// //                         Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             const Text('إجمالي الموزع:'),
// //                             Text(
// //                               _formatCurrency(_totalDistributed),
// //                               style: const TextStyle(
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.green,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                         const SizedBox(height: 8),
// //                         Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                           children: [
// //                             const Text('المتبقي للتوزيع:'),
// //                             Text(
// //                               _formatCurrency(_remainingProfit),
// //                               style: const TextStyle(
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.orange,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                         const SizedBox(height: 12),
// //                         if (_isDistributionCompleted)
// //                           Container(
// //                             padding: const EdgeInsets.all(8),
// //                             decoration: BoxDecoration(
// //                               color: Colors.green[50],
// //                               borderRadius: BorderRadius.circular(8),
// //                             ),
// //                             child: const Row(
// //                               mainAxisAlignment: MainAxisAlignment.center,
// //                               children: [
// //                                 Icon(Icons.check_circle, color: Colors.green),
// //                                 SizedBox(width: 8),
// //                                 Text(
// //                                   'تم توزيع كامل الربح',
// //                                   style: TextStyle(
// //                                     color: Colors.green,
// //                                     fontWeight: FontWeight.bold,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),

// //           const SizedBox(height: 20),

// //           // معلومات هامة
// //           Card(
// //             elevation: 2,
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(12),
// //             ),
// //             child: Padding(
// //               padding: const EdgeInsets.all(16),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Row(
// //                     children: [
// //                       const Icon(Icons.info, color: Colors.blue, size: 20),
// //                       const SizedBox(width: 8),
// //                       const Text(
// //                         'معلومات هامة',
// //                         style: TextStyle(
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.blue,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 8),
// //                   const Text(
// //                     '• يتم توزيع الأرباح بناءً على نسب الشركاء المضافة في صفحة رأس المال',
// //                     style: TextStyle(fontSize: 12, color: Colors.grey),
// //                   ),
// //                   const SizedBox(height: 4),
// //                   const Text(
// //                     '• لإضافة أو تعديل أو حذف الشركاء، يرجى الذهاب إلى صفحة رأس المال',
// //                     style: TextStyle(fontSize: 12, color: Colors.grey),
// //                   ),
// //                   const SizedBox(height: 4),
// //                   const Text(
// //                     '• إجمالي نسب الشركاء: يجب أن يساوي 100% للتوزيع الكامل',
// //                     style: TextStyle(fontSize: 12, color: Colors.grey),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),

// //           const SizedBox(height: 20),

// //           // قائمة الشركاء
// //           if (_partners.isNotEmpty)
// //             ..._partners.map(
// //               (partner) => _buildPartnerDistributionCard(partner),
// //             )
// //           else
// //             _buildNoPartnersCard(),

// //           const SizedBox(height: 20),

// //           // زر تحديث التوزيع
// //           SizedBox(
// //             width: double.infinity,
// //             child: ElevatedButton.icon(
// //               onPressed: () {
// //                 _calculateDistribution();
// //                 _showSuccess('تم تحديث التوزيع');
// //               },
// //               icon: const Icon(Icons.refresh, size: 20),
// //               label: const Text('تحديث التوزيع'),
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: const Color(0xFF1B4F72),
// //                 padding: const EdgeInsets.symmetric(vertical: 14),
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(10),
// //                 ),
// //               ),
// //             ),
// //           ),

// //           const SizedBox(height: 16),
// //         ],
// //       ),
// //     );
// //   }

// //   // ================================
// //   // Widgets المساعدة
// //   // ================================

// //   Widget _buildMonthYearFilter() {
// //     return Card(
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           children: [
// //             const Text(
// //               'اختر الشهر والسنة',
// //               style: TextStyle(
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 16,
// //                 color: Color(0xFF2C3E50),
// //               ),
// //             ),
// //             const SizedBox(height: 16),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 DropdownButton<int>(
// //                   value: _selectedMonth,
// //                   onChanged: (value) {
// //                     if (value != null) {
// //                       _changeMonth(value);
// //                     }
// //                   },
// //                   items: List.generate(12, (index) {
// //                     final monthNumber = index + 1;
// //                     return DropdownMenuItem(
// //                       value: monthNumber,
// //                       child: Text(_getMonthName(monthNumber)),
// //                     );
// //                   }),
// //                 ),
// //                 const SizedBox(width: 20),
// //                 DropdownButton<int>(
// //                   value: _selectedYear,
// //                   onChanged: (value) {
// //                     if (value != null) {
// //                       _changeYear(value);
// //                     }
// //                   },
// //                   items: [
// //                     for (
// //                       int i = DateTime.now().year - 5;
// //                       i <= DateTime.now().year + 1;
// //                       i++
// //                     )
// //                       DropdownMenuItem(value: i, child: Text('$i')),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildTotalItem({
// //     required IconData icon,
// //     required String label,
// //     required String value,
// //     required Color color,
// //     required Color iconColor,
// //   }) {
// //     return Container(
// //       padding: const EdgeInsets.all(12),
// //       decoration: BoxDecoration(
// //         color: Colors.white.withOpacity(0.05),
// //         borderRadius: BorderRadius.circular(10),
// //         border: Border.all(color: Colors.white.withOpacity(0.1)),
// //       ),
// //       child: Row(
// //         children: [
// //           Icon(icon, color: iconColor, size: 22),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: Text(
// //               label,
// //               style: const TextStyle(color: Colors.white, fontSize: 16),
// //             ),
// //           ),
// //           Text(
// //             value,
// //             style: TextStyle(
// //               color: color,
// //               fontSize: 18,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildPartnersSummary() {
// //     if (_partners.isEmpty) return const SizedBox();

// //     double totalPercentage = 0;
// //     for (var partner in _partners) {
// //       totalPercentage += (partner['share'] as num?)?.toDouble() ?? 0;
// //     }

// //     return Card(
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           children: [
// //             Row(
// //               children: [
// //                 const Icon(Icons.group, color: Color(0xFF3498DB), size: 24),
// //                 const SizedBox(width: 12),
// //                 const Text(
// //                   'ملخص الشركاء',
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 16,
// //                     color: Color(0xFF2C3E50),
// //                   ),
// //                 ),
// //                 const Spacer(),
// //                 Container(
// //                   padding: const EdgeInsets.symmetric(
// //                     horizontal: 12,
// //                     vertical: 6,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     color: totalPercentage == 100
// //                         ? Colors.green[50]
// //                         : Colors.orange[50],
// //                     borderRadius: BorderRadius.circular(20),
// //                   ),
// //                   child: Text(
// //                     '${_partners.length} شريك',
// //                     style: TextStyle(
// //                       fontWeight: FontWeight.bold,
// //                       color: totalPercentage == 100
// //                           ? Colors.green
// //                           : Colors.orange,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 12),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 const Text('إجمالي النسب:'),
// //                 Text(
// //                   '${totalPercentage.toStringAsFixed(2)}%',
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     color: totalPercentage == 100
// //                         ? Colors.green
// //                         : totalPercentage > 100
// //                         ? Colors.red
// //                         : Colors.orange,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //             const SizedBox(height: 8),
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 const Text('المتبقي:'),
// //                 Text(
// //                   '${(100 - totalPercentage).toStringAsFixed(2)}%',
// //                   style: TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.blue,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildCompanyProfitCard(Map<String, dynamic> company) {
// //     final companyName = company['companyName'] ?? 'غير معروف';
// //     final totalIncome = (company['totalIncome'] ?? 0).toDouble();
// //     final driversCost = (company['totalDriversCost'] ?? 0).toDouble();
// //     final profit = (company['companyProfit'] ?? 0).toDouble();

// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 12),
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Row(
// //               children: [
// //                 Container(
// //                   width: 50,
// //                   height: 50,
// //                   decoration: BoxDecoration(
// //                     color: _getCompanyColor(companyName),
// //                     borderRadius: BorderRadius.circular(25),
// //                   ),
// //                   child: Center(
// //                     child: Text(
// //                       _getCompanyInitials(companyName),
// //                       style: const TextStyle(
// //                         color: Colors.white,
// //                         fontSize: 18,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                   ),
// //                 ),

// //                 const SizedBox(width: 16),

// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         companyName,
// //                         style: const TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.bold,
// //                           color: Color(0xFF2C3E50),
// //                         ),
// //                       ),

// //                       const SizedBox(height: 8),

// //                       Row(
// //                         children: [
// //                           Expanded(
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Text(
// //                                   'الدخل',
// //                                   style: TextStyle(
// //                                     fontSize: 12,
// //                                     color: Colors.grey[600],
// //                                   ),
// //                                 ),
// //                                 Text(
// //                                   _formatCurrency(totalIncome),
// //                                   style: const TextStyle(
// //                                     fontSize: 14,
// //                                     fontWeight: FontWeight.bold,
// //                                     color: Colors.green,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),

// //                           Expanded(
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Text(
// //                                   'حساب السائقين',
// //                                   style: TextStyle(
// //                                     fontSize: 12,
// //                                     color: Colors.grey[600],
// //                                   ),
// //                                 ),
// //                                 Text(
// //                                   _formatCurrency(driversCost),
// //                                   style: const TextStyle(
// //                                     fontSize: 14,
// //                                     fontWeight: FontWeight.bold,
// //                                     color: Colors.orange,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),

// //                           Expanded(
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Text(
// //                                   'صافي الربح',
// //                                   style: TextStyle(
// //                                     fontSize: 12,
// //                                     color: Colors.grey[600],
// //                                   ),
// //                                 ),
// //                                 Text(
// //                                   _formatCurrency(profit),
// //                                   style: TextStyle(
// //                                     fontSize: 14,
// //                                     fontWeight: FontWeight.bold,
// //                                     color: profit >= 0
// //                                         ? Colors.blue
// //                                         : Colors.red,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),

// //             const SizedBox(height: 12),

// //             // شريط تقدم يوضح النسبة المئوية للربح
// //             if (profit > 0 && totalIncome > 0)
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       Text(
// //                         'نسبة الربحية:',
// //                         style: TextStyle(fontSize: 12, color: Colors.grey[600]),
// //                       ),
// //                       Text(
// //                         '${((profit / totalIncome) * 100).toStringAsFixed(1)}%',
// //                         style: TextStyle(
// //                           fontSize: 12,
// //                           fontWeight: FontWeight.bold,
// //                           color: profit >= 0 ? Colors.green : Colors.red,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 4),
// //                   Container(
// //                     height: 6,
// //                     decoration: BoxDecoration(
// //                       color: Colors.grey[200],
// //                       borderRadius: BorderRadius.circular(3),
// //                     ),
// //                     child: FractionallySizedBox(
// //                       widthFactor: (profit / totalIncome).clamp(0.0, 1.0),
// //                       child: Container(
// //                         decoration: BoxDecoration(
// //                           color: profit >= 0 ? Colors.green : Colors.red,
// //                           borderRadius: BorderRadius.circular(3),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildPartnerDistributionCard(Map<String, dynamic> partner) {
// //     final percentage = (partner['share'] as num?)?.toDouble() ?? 0.0;
// //     final share = (partner['profitShare'] as num?)?.toDouble() ?? 0.0;
// //     final notes = partner['notes']?.toString() ?? '';

// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 12),
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           children: [
// //             Row(
// //               children: [
// //                 Container(
// //                   width: 50,
// //                   height: 50,
// //                   decoration: BoxDecoration(
// //                     color: _getPartnerColor(partner['name']),
// //                     borderRadius: BorderRadius.circular(25),
// //                   ),
// //                   child: Center(
// //                     child: Text(
// //                       _getInitials(partner['name']),
// //                       style: const TextStyle(
// //                         color: Colors.white,
// //                         fontSize: 18,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                   ),
// //                 ),

// //                 const SizedBox(width: 16),

// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Row(
// //                         children: [
// //                           Expanded(
// //                             child: Text(
// //                               partner['name'],
// //                               style: const TextStyle(
// //                                 fontSize: 16,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Color(0xFF2C3E50),
// //                               ),
// //                             ),
// //                           ),
// //                           Container(
// //                             padding: const EdgeInsets.symmetric(
// //                               horizontal: 12,
// //                               vertical: 4,
// //                             ),
// //                             decoration: BoxDecoration(
// //                               color: Colors.blue[50],
// //                               borderRadius: BorderRadius.circular(20),
// //                             ),
// //                             child: Text(
// //                               '${percentage.toStringAsFixed(1)}%',
// //                               style: const TextStyle(
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.blue,
// //                                 fontSize: 14,
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),

// //                       const SizedBox(height: 8),

// //                       Row(
// //                         children: [
// //                           Expanded(
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Text(
// //                                   'حصة الشريك',
// //                                   style: TextStyle(
// //                                     fontSize: 12,
// //                                     color: Colors.grey[600],
// //                                   ),
// //                                 ),
// //                                 Text(
// //                                   _formatCurrency(share),
// //                                   style: const TextStyle(
// //                                     fontSize: 16,
// //                                     fontWeight: FontWeight.bold,
// //                                     color: Colors.green,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),

// //                           Column(
// //                             crossAxisAlignment: CrossAxisAlignment.end,
// //                             children: [
// //                               Text(
// //                                 'نسبة من الربح',
// //                                 style: TextStyle(
// //                                   fontSize: 12,
// //                                   color: Colors.grey[600],
// //                                 ),
// //                               ),
// //                               Text(
// //                                 _netProfit > 0
// //                                     ? '${((share / _netProfit) * 100).toStringAsFixed(1)}%'
// //                                     : '0%',
// //                                 style: const TextStyle(
// //                                   fontSize: 14,
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Colors.blue,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),

// //             // عرض الملاحظات إذا وجدت
// //             if (notes.isNotEmpty)
// //               Column(
// //                 children: [
// //                   const SizedBox(height: 8),
// //                   Container(
// //                     padding: const EdgeInsets.all(8),
// //                     width: double.infinity,
// //                     decoration: BoxDecoration(
// //                       color: Colors.grey[50],
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         const Text(
// //                           'ملاحظات:',
// //                           style: TextStyle(
// //                             fontSize: 12,
// //                             fontWeight: FontWeight.bold,
// //                             color: Colors.grey,
// //                           ),
// //                         ),
// //                         Text(notes, style: const TextStyle(fontSize: 12)),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildNoPartnersCard() {
// //     return Card(
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(32),
// //         child: Column(
// //           children: [
// //             Icon(Icons.group, size: 60, color: Colors.grey[400]),
// //             const SizedBox(height: 16),
// //             const Text(
// //               'لا يوجد شركاء مضافة',
// //               textAlign: TextAlign.center,
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 color: Colors.grey,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             const SizedBox(height: 8),
// //             const Text(
// //               'يجب إضافة الشركاء أولاً من صفحة رأس المال',
// //               textAlign: TextAlign.center,
// //               style: TextStyle(fontSize: 12, color: Colors.grey),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildNoDataCard(String message) {
// //     return Card(
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       child: Padding(
// //         padding: const EdgeInsets.all(32),
// //         child: Column(
// //           children: [
// //             Icon(Icons.info_outline, size: 60, color: Colors.grey[400]),
// //             const SizedBox(height: 16),
// //             Text(
// //               message,
// //               textAlign: TextAlign.center,
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 color: Colors.grey[600],
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ================================
// //   // دوال مساعدة
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
// //         return 'غير معروف';
// //     }
// //   }

// //   Color _getPartnerColor(String name) {
// //     final hash = name.hashCode;
// //     return Color(hash & 0xFFFFFF).withOpacity(1.0).withBlue(150);
// //   }

// //   Color _getCompanyColor(String name) {
// //     final hash = name.hashCode;
// //     return Color(hash & 0xFFFFFF).withOpacity(1.0).withGreen(150);
// //   }

// //   String _getInitials(String name) {
// //     if (name.isEmpty) return '??';

// //     final trimmedName = name.trim();
// //     final words = trimmedName.split(' ');

// //     final validWords = words.where((word) => word.isNotEmpty).toList();

// //     if (validWords.isEmpty) return '??';

// //     if (validWords.length >= 2) {
// //       return '${validWords[0][0]}${validWords[1][0]}'.toUpperCase();
// //     } else {
// //       final word = validWords[0];
// //       if (word.length >= 2) {
// //         return word.substring(0, 2).toUpperCase();
// //       } else {
// //         return word.toUpperCase();
// //       }
// //     }
// //   }

// //   String _getCompanyInitials(String name) {
// //     if (name.isEmpty) return '??';

// //     final trimmedName = name.trim();
// //     final words = trimmedName.split(' ');

// //     final validWords = words.where((word) => word.isNotEmpty).toList();

// //     if (validWords.isEmpty) return '??';

// //     // للحصول على أول حرف من أول كلمة
// //     return validWords[0][0].toUpperCase();
// //   }

// //   String _formatCurrency(double amount) {
// //     return '${amount.toStringAsFixed(2)} ج';
// //   }

// //   void _changeTab(int index) {
// //     if (mounted) {
// //       setState(() {
// //         _currentTab = index;
// //       });
// //     }
// //   }

// //   void _showError(String message) {
// //     if (mounted) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text(message),
// //           backgroundColor: Colors.red,
// //           duration: const Duration(seconds: 2),
// //         ),
// //       );
// //     }
// //   }

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

// //   // ================================
// //   // بناء الواجهة الرئيسية
// //   // ================================

// //   @override
// //   Widget build(BuildContext context) {
// //     return DefaultTabController(
// //       length: 3,
// //       initialIndex: _currentTab,
// //       child: Scaffold(
// //         appBar: AppBar(
// //           title: const Text(
// //             'توزيع الأرباح الشهرية',
// //             style: TextStyle(color: Colors.white),
// //           ),
// //           centerTitle: true,
// //           backgroundColor: const Color(0xFF1B4F72),
// //           bottom: TabBar(
// //             onTap: _changeTab,
// //             indicatorColor: Colors.amber,
// //             labelColor: Colors.amber,
// //             unselectedLabelColor: Colors.white,
// //             tabs: const [
// //               Tab(icon: Icon(Icons.calculate), text: 'إجماليات الشهر'),
// //               Tab(icon: Icon(Icons.business), text: 'أرباح الشركات'),
// //               Tab(icon: Icon(Icons.groups), text: 'توزيع الربح'),
// //             ],
// //           ),
// //         ),
// //         body: _isLoading
// //             ? const Center(child: CircularProgressIndicator())
// //             : TabBarView(
// //                 children: [
// //                   _buildMonthlyTotalsTab(),
// //                   _buildCompaniesProfitsTab(),
// //                   _buildDistributionTab(),
// //                 ],
// //               ),
// //       ),
// //     );
// //   }
// // }
// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class MonthlyProfitsPage extends StatefulWidget {
//   const MonthlyProfitsPage({super.key});

//   @override
//   State<MonthlyProfitsPage> createState() => _MonthlyProfitsPageState();
// }

// class _MonthlyProfitsPageState extends State<MonthlyProfitsPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // ================================
//   // بيانات الشهر الحالي
//   // ================================
//   int _selectedYear = DateTime.now().year;
//   int _selectedMonth = DateTime.now().month;
//   String _selectedMonthName = '';

//   // ================================
//   // إجماليات الشهر
//   // ================================
//   double _totalCompanyIncome = 0.0;
//   double _totalDriversExpenses = 0.0;
//   double _netProfit = 0.0;

//   // ================================
//   // بيانات الشركات المنفصلة
//   // ================================
//   List<Map<String, dynamic>> _companyProfits = [];

//   // ================================
//   // بيانات الشركاء والتوزيع
//   // ================================
//   List<Map<String, dynamic>> _partners = [];
//   double _totalDistributed = 0.0;
//   double _remainingProfit = 0.0;
//   bool _isDistributionCompleted = false;

//   // ================================
//   // متغيرات التحكم
//   // ================================
//   bool _isLoading = false;
//   int _currentTab = 0;

//   @override
//   void initState() {
//     super.initState();
//     _selectedMonthName = _getMonthName(_selectedMonth);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadAllData();
//     });
//   }

//   // ================================
//   // تحميل كل البيانات
//   // ================================
//   Future<void> _loadAllData() async {
//     if (!mounted) return;

//     setState(() => _isLoading = true);

//     try {
//       await _calculateMonthlyTotals();
//       await _loadCompanyProfits();
//       await _loadPartnersFromCapitalPage();
//       _calculateDistribution();
//     } catch (e) {
//       print('خطأ في تحميل البيانات: $e');
//       _showError('خطأ في تحميل البيانات');
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   // ================================
//   // حساب إجماليات الشهر
//   // ================================
//   Future<void> _calculateMonthlyTotals() async {
//     try {
//       double totalCompanyIncome = 0;
//       double totalDriversExpenses = 0;

//       // تاريخ بداية ونهاية الشهر
//       final startDate = DateTime(_selectedYear, _selectedMonth, 1);
//       final endDate = DateTime(_selectedYear, _selectedMonth + 1, 1);

//       // ================================
//       // 1. حساب إجمالي دخل الشركات من dailyWork
//       // ================================
//       final companySnapshot = await _firestore
//           .collection('dailyWork')
//           .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
//           .where('date', isLessThan: Timestamp.fromDate(endDate))
//           .get();

//       for (var doc in companySnapshot.docs) {
//         final data = doc.data();

//         final nolon = _safeParseDouble(data['nolon'] ?? data['noLon'] ?? 0);
//         final companyOvernight = _safeParseDouble(
//           data['companyOvernight'] ?? 0,
//         );
//         final companyHoliday = _safeParseDouble(data['companyHoliday'] ?? 0);

//         totalCompanyIncome += nolon + companyOvernight + companyHoliday;
//       }

//       // ================================
//       // 2. حساب إجمالي حساب السائقين
//       // ================================
//       final driversSnapshot = await _firestore
//           .collection('drivers')
//           .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
//           .where('date', isLessThan: Timestamp.fromDate(endDate))
//           .get();

//       for (var doc in driversSnapshot.docs) {
//         final data = doc.data();

//         final wheelNolon = _safeParseDouble(data['wheelNolon'] ?? 0);
//         final wheelOvernight = _safeParseDouble(data['wheelOvernight'] ?? 0);
//         final wheelHoliday = _safeParseDouble(data['wheelHoliday'] ?? 0);

//         totalDriversExpenses += wheelNolon + wheelOvernight + wheelHoliday;
//       }

//       // ================================
//       // 3. حساب صافي الربح
//       // ================================
//       final netProfit = totalCompanyIncome - totalDriversExpenses;

//       if (mounted) {
//         setState(() {
//           _totalCompanyIncome = totalCompanyIncome;
//           _totalDriversExpenses = totalDriversExpenses;
//           _netProfit = netProfit;
//         });
//       }
//     } catch (e) {
//       print('خطأ في حساب الإجماليات: $e');
//       throw e;
//     }
//   }

//   // ================================
//   // تحميل أرباح كل شركة منفصلة - الحل الجديد
//   // ================================
//   Future<void> _loadCompanyProfits() async {
//     try {
//       // تاريخ بداية ونهاية الشهر
//       final startDate = DateTime(_selectedYear, _selectedMonth, 1);
//       final endDate = DateTime(_selectedYear, _selectedMonth + 1, 1);

//       // جلب جميع الرحلات من dailyWork
//       final companySnapshot = await _firestore
//           .collection('dailyWork')
//           .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
//           .where('date', isLessThan: Timestamp.fromDate(endDate))
//           .get();

//       // جلب جميع الرحلات من drivers
//       final driversSnapshot = await _firestore
//           .collection('drivers')
//           .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
//           .where('date', isLessThan: Timestamp.fromDate(endDate))
//           .get();

//       // تحويل بيانات drivers إلى Map للبحث السريع
//       Map<String, List<Map<String, dynamic>>> driversMap = {};

//       for (var doc in driversSnapshot.docs) {
//         final data = doc.data();
//         final driverName = (data['driverName'] ?? '').toString().trim();
//         final contractor = (data['contractor'] ?? '').toString().trim();
//         final date = data['date'] as Timestamp?;

//         if (driverName.isNotEmpty && contractor.isNotEmpty && date != null) {
//           final dateStr = DateFormat('yyyy-MM-dd').format(date.toDate());
//           final key = '$driverName|$contractor|$dateStr';

//           if (!driversMap.containsKey(key)) {
//             driversMap[key] = [];
//           }

//           driversMap[key]!.add({
//             'id': doc.id,
//             'wheelNolon': _safeParseDouble(data['wheelNolon'] ?? 0),
//             'wheelOvernight': _safeParseDouble(data['wheelOvernight'] ?? 0),
//             'wheelHoliday': _safeParseDouble(data['wheelHoliday'] ?? 0),
//           });
//         }
//       }

//       // تجميع بيانات الشركات
//       Map<String, Map<String, dynamic>> companiesMap = {};

//       for (var doc in companySnapshot.docs) {
//         final data = doc.data();
//         final companyId = (data['companyId'] ?? '').toString();
//         final companyName = (data['companyName'] ?? 'غير معروف').toString();

//         if (companyId.isEmpty) continue;

//         if (!companiesMap.containsKey(companyId)) {
//           companiesMap[companyId] = {
//             'companyId': companyId,
//             'companyName': companyName,
//             'totalIncome': 0.0,
//             'totalDriversCost': 0.0,
//             'companyProfit': 0.0,
//             'tripCount': 0,
//           };
//         }

//         final company = companiesMap[companyId]!;

//         // حساب دخل الشركة من هذه الرحلة
//         final nolon = _safeParseDouble(data['nolon'] ?? data['noLon'] ?? 0);
//         final companyOvernight = _safeParseDouble(
//           data['companyOvernight'] ?? 0,
//         );
//         final companyHoliday = _safeParseDouble(data['companyHoliday'] ?? 0);
//         final tripIncome = nolon + companyOvernight + companyHoliday;

//         company['totalIncome'] =
//             (company['totalIncome'] as double) + tripIncome;
//         company['tripCount'] = (company['tripCount'] as int) + 1;

//         // البحث عن تكاليف السائق
//         final driverName = (data['driverName'] ?? '').toString().trim();
//         final contractor = (data['contractor'] ?? '').toString().trim();
//         final tripDate = data['date'] as Timestamp?;

//         if (driverName.isNotEmpty &&
//             contractor.isNotEmpty &&
//             tripDate != null) {
//           final dateStr = DateFormat('yyyy-MM-dd').format(tripDate.toDate());
//           final key = '$driverName|$contractor|$dateStr';

//           if (driversMap.containsKey(key)) {
//             // أخذ أول نتيجة (يفضل أن يكون هناك رحلة واحدة فقط)
//             final driverData = driversMap[key]!.first;
//             final driverCost =
//                 (driverData['wheelNolon'] ?? 0) +
//                 (driverData['wheelOvernight'] ?? 0) +
//                 (driverData['wheelHoliday'] ?? 0);

//             company['totalDriversCost'] =
//                 (company['totalDriversCost'] as double) + driverCost;
//           }
//         }
//       }

//       // تحويل إلى قائمة وحساب الأرباح
//       List<Map<String, dynamic>> companyProfitsList = [];

//       for (var entry in companiesMap.entries) {
//         final company = entry.value;
//         final companyProfit =
//             (company['totalIncome'] as double) -
//             (company['totalDriversCost'] as double);

//         companyProfitsList.add({
//           'companyId': company['companyId'],
//           'companyName': company['companyName'],
//           'totalIncome': company['totalIncome'],
//           'totalDriversCost': company['totalDriversCost'],
//           'companyProfit': companyProfit,
//           'tripCount': company['tripCount'],
//         });
//       }

//       // ترتيب حسب الربح (الأكبر أولاً)
//       companyProfitsList.sort(
//         (a, b) => b['companyProfit'].compareTo(a['companyProfit']),
//       );

//       if (mounted) {
//         setState(() {
//           _companyProfits = companyProfitsList;
//         });
//       }
//     } catch (e) {
//       print('خطأ في تحميل أرباح الشركات: $e');
//       if (mounted) {
//         setState(() {
//           _companyProfits = [];
//         });
//       }
//     }
//   }

//   // ================================
//   // تحميل الشركاء من صفحة رأس المال
//   // ================================
//   Future<void> _loadPartnersFromCapitalPage() async {
//     try {
//       final partnersSnapshot = await _firestore
//           .collection('partners')
//           .orderBy('createdAt', descending: false)
//           .get();

//       List<Map<String, dynamic>> partnersList = [];

//       for (var doc in partnersSnapshot.docs) {
//         final data = doc.data();
//         final name = (data['name'] ?? 'غير معروف').toString();
//         final share = _safeParseDouble(data['share'] ?? 0);

//         partnersList.add({
//           'id': doc.id,
//           'name': name,
//           'share': share,
//           'notes': data['notes'] ?? '',
//           'createdAt':
//               (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
//         });
//       }

//       if (mounted) {
//         setState(() {
//           _partners = partnersList;
//         });
//       }
//     } catch (e) {
//       print('خطأ في تحميل الشركاء: $e');
//       if (mounted) {
//         setState(() {
//           _partners = [];
//         });
//       }
//     }
//   }

//   // ================================
//   // حساب توزيع الربح على الشركاء
//   // ================================
//   void _calculateDistribution() {
//     if (_partners.isEmpty || _netProfit <= 0) {
//       if (mounted) {
//         setState(() {
//           _totalDistributed = 0;
//           _remainingProfit = _netProfit;
//           _isDistributionCompleted = false;
//         });
//       }
//       return;
//     }

//     double totalDistributed = 0;
//     final List<Map<String, dynamic>> updatedPartners = [];

//     // حساب حصة كل شريك
//     for (var partner in _partners) {
//       final percentage = (partner['share'] as num?)?.toDouble() ?? 0.0;
//       final amount = (_netProfit * percentage) / 100;

//       final updatedPartner = Map<String, dynamic>.from(partner);
//       updatedPartner['profitShare'] = amount;
//       updatedPartner['shareFormatted'] = _formatCurrency(amount);

//       updatedPartners.add(updatedPartner);
//       totalDistributed += amount;
//     }

//     if (mounted) {
//       setState(() {
//         _partners = updatedPartners;
//         _totalDistributed = totalDistributed;
//         _remainingProfit = _netProfit - totalDistributed;
//         _isDistributionCompleted =
//             (totalDistributed - _netProfit).abs() < 0.01; // تسامح 0.01
//       });
//     }
//   }

//   // ================================
//   // تغيير الشهر
//   // ================================
//   Future<void> _changeMonth(int month) async {
//     if (!mounted) return;

//     setState(() {
//       _selectedMonth = month;
//       _selectedMonthName = _getMonthName(month);
//       _isLoading = true;
//     });

//     try {
//       await _calculateMonthlyTotals();
//       await _loadCompanyProfits();
//       _calculateDistribution();
//     } catch (e) {
//       _showError('خطأ في تحميل بيانات الشهر');
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   Future<void> _changeYear(int year) async {
//     if (!mounted) return;

//     setState(() {
//       _selectedYear = year;
//       _isLoading = true;
//     });

//     try {
//       await _calculateMonthlyTotals();
//       await _loadCompanyProfits();
//       _calculateDistribution();
//     } catch (e) {
//       _showError('خطأ في تحميل بيانات السنة');
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   // ================================
//   // دوال المساعدة
//   // ================================
//   double _safeParseDouble(dynamic value) {
//     if (value == null) return 0.0;
//     if (value is num) return value.toDouble();
//     if (value is String) {
//       try {
//         return double.tryParse(value.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0.0;
//       } catch (e) {
//         return 0.0;
//       }
//     }
//     return 0.0;
//   }

//   String _getMonthName(int month) {
//     final months = [
//       'يناير',
//       'فبراير',
//       'مارس',
//       'أبريل',
//       'مايو',
//       'يونيو',
//       'يوليو',
//       'أغسطس',
//       'سبتمبر',
//       'أكتوبر',
//       'نوفمبر',
//       'ديسمبر',
//     ];
//     return months[month - 1];
//   }

//   Color _getPartnerColor(String name) {
//     final hash = name.hashCode;
//     final colors = [
//       const Color(0xFF3498DB), // أزرق
//       const Color(0xFF2ECC71), // أخضر
//       const Color(0xFFE74C3C), // أحمر
//       const Color(0xFFF39C12), // برتقالي
//       const Color(0xFF9B59B6), // بنفسجي
//       const Color(0xFF1ABC9C), // تركواز
//     ];
//     return colors[hash.abs() % colors.length];
//   }

//   Color _getCompanyColor(String name) {
//     final hash = name.hashCode;
//     final colors = [
//       const Color(0xFF2980B9), // أزرق داكن
//       const Color(0xFF27AE60), // أخضر داكن
//       const Color(0xFFC0392B), // أحمر داكن
//       const Color(0xFFD35400), // برتقالي داكن
//       const Color(0xFF8E44AD), // بنفسجي داكن
//       const Color(0xFF16A085), // تركواز داكن
//     ];
//     return colors[hash.abs() % colors.length];
//   }

//   String _getInitials(String name) {
//     if (name.isEmpty) return '??';
//     final words = name
//         .trim()
//         .split(' ')
//         .where((word) => word.isNotEmpty)
//         .toList();
//     if (words.isEmpty) return '??';
//     if (words.length >= 2) {
//       return '${words[0][0]}${words[1][0]}'.toUpperCase();
//     }
//     return words[0].length >= 2
//         ? words[0].substring(0, 2).toUpperCase()
//         : words[0].toUpperCase();
//   }

//   String _getCompanyInitials(String name) {
//     if (name.isEmpty) return '??';
//     final firstWord = name
//         .trim()
//         .split(' ')
//         .firstWhere((word) => word.isNotEmpty, orElse: () => '');
//     if (firstWord.isEmpty) return '??';
//     return firstWord[0].toUpperCase();
//   }

//   String _formatCurrency(double amount) {
//     return '${amount.toStringAsFixed(2)} ج';
//   }

//   void _changeTab(int index) {
//     if (mounted) {
//       setState(() {
//         _currentTab = index;
//       });
//     }
//   }

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

//   // ================================
//   // Widgets المساعدة
//   // ================================

//   Widget _buildMonthYearFilter() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             const Text(
//               'اختر الشهر والسنة',
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//                 color: Color(0xFF2C3E50),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 DropdownButton<int>(
//                   value: _selectedMonth,
//                   onChanged: (value) {
//                     if (value != null) {
//                       _changeMonth(value);
//                     }
//                   },
//                   items: List.generate(12, (index) {
//                     final monthNumber = index + 1;
//                     return DropdownMenuItem(
//                       value: monthNumber,
//                       child: Text(_getMonthName(monthNumber)),
//                     );
//                   }),
//                 ),
//                 const SizedBox(width: 20),
//                 DropdownButton<int>(
//                   value: _selectedYear,
//                   onChanged: (value) {
//                     if (value != null) {
//                       _changeYear(value);
//                     }
//                   },
//                   items: [
//                     for (
//                       int i = DateTime.now().year - 2;
//                       i <= DateTime.now().year + 1;
//                       i++
//                     )
//                       DropdownMenuItem(value: i, child: Text('$i')),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTotalItem({
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color color,
//     required Color iconColor,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.white.withOpacity(0.1)),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: iconColor, size: 22),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               label,
//               style: const TextStyle(color: Colors.white, fontSize: 16),
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               color: color,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPartnersSummary() {
//     if (_partners.isEmpty) return const SizedBox();

//     double totalPercentage = 0;
//     for (var partner in _partners) {
//       totalPercentage += (partner['share'] as num?)?.toDouble() ?? 0;
//     }

//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 const Icon(Icons.group, color: Color(0xFF3498DB), size: 24),
//                 const SizedBox(width: 12),
//                 const Text(
//                   'ملخص الشركاء',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: Color(0xFF2C3E50),
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: totalPercentage == 100
//                         ? Colors.green[50]
//                         : Colors.orange[50],
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     '${_partners.length} شريك',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: totalPercentage == 100
//                           ? Colors.green
//                           : Colors.orange,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text('إجمالي النسب:'),
//                 Text(
//                   '${totalPercentage.toStringAsFixed(2)}%',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: totalPercentage == 100
//                         ? Colors.green
//                         : totalPercentage > 100
//                         ? Colors.red
//                         : Colors.orange,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text('المتبقي:'),
//                 Text(
//                   '${(100 - totalPercentage).toStringAsFixed(2)}%',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCompanyProfitCard(Map<String, dynamic> company) {
//     final companyName = company['companyName'] ?? 'غير معروف';
//     final totalIncome = _safeParseDouble(company['totalIncome']);
//     final driversCost = _safeParseDouble(company['totalDriversCost']);
//     final profit = _safeParseDouble(company['companyProfit']);
//     final tripCount = (company['tripCount'] as int?) ?? 0;

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 50,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color: _getCompanyColor(companyName),
//                     borderRadius: BorderRadius.circular(25),
//                   ),
//                   child: Center(
//                     child: Text(
//                       _getCompanyInitials(companyName),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         companyName,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF2C3E50),
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '$tripCount رحلة',
//                         style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'الدخل',
//                         style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                       ),
//                       Text(
//                         _formatCurrency(totalIncome),
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'حساب السائقين',
//                         style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                       ),
//                       Text(
//                         _formatCurrency(driversCost),
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.orange,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'صافي الربح',
//                         style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                       ),
//                       Text(
//                         _formatCurrency(profit),
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.bold,
//                           color: profit >= 0 ? Colors.blue : Colors.red,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             if (totalIncome > 0)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'نسبة الربحية:',
//                         style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                       ),
//                       Text(
//                         '${((profit / totalIncome) * 100).toStringAsFixed(1)}%',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: profit >= 0 ? Colors.green : Colors.red,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Container(
//                     height: 6,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       borderRadius: BorderRadius.circular(3),
//                     ),
//                     child: FractionallySizedBox(
//                       widthFactor: (profit / totalIncome).clamp(0.0, 1.0),
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: profit >= 0 ? Colors.green : Colors.red,
//                           borderRadius: BorderRadius.circular(3),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPartnerDistributionCard(Map<String, dynamic> partner) {
//     final percentage = _safeParseDouble(partner['share']);
//     final share = _safeParseDouble(partner['profitShare'] ?? 0);
//     final notes = (partner['notes'] ?? '').toString();

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 50,
//                   height: 50,
//                   decoration: BoxDecoration(
//                     color: _getPartnerColor(partner['name']),
//                     borderRadius: BorderRadius.circular(25),
//                   ),
//                   child: Center(
//                     child: Text(
//                       _getInitials(partner['name']),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               partner['name'],
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF2C3E50),
//                               ),
//                             ),
//                           ),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.blue[50],
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Text(
//                               '${percentage.toStringAsFixed(1)}%',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.blue,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'حصة الشريك',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey[600],
//                                   ),
//                                 ),
//                                 Text(
//                                   _formatCurrency(share),
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.green,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text(
//                                 'نسبة من الربح',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                               Text(
//                                 _netProfit > 0
//                                     ? '${((share / _netProfit) * 100).toStringAsFixed(1)}%'
//                                     : '0%',
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blue,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             if (notes.isNotEmpty)
//               Column(
//                 children: [
//                   const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[50],
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'ملاحظات:',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.grey,
//                           ),
//                         ),
//                         Text(notes, style: const TextStyle(fontSize: 12)),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNoPartnersCard() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           children: [
//             Icon(Icons.group, size: 60, color: Colors.grey[400]),
//             const SizedBox(height: 16),
//             const Text(
//               'لا يوجد شركاء مضافة',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'يجب إضافة الشركاء أولاً من صفحة رأس المال',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 12, color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNoDataCard(String message) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           children: [
//             Icon(Icons.info_outline, size: 60, color: Colors.grey[400]),
//             const SizedBox(height: 16),
//             Text(
//               message,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ================================
//   // تبويب إجماليات الشهر
//   // ================================
//   Widget _buildMonthlyTotalsTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           _buildMonthYearFilter(),
//           const SizedBox(height: 20),
//           Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   begin: Alignment.centerRight,
//                   end: Alignment.centerLeft,
//                   colors: [Color(0xFF1B4F72), Color(0xFF3498DB)],
//                 ),
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.calendar_month,
//                         color: Colors.white,
//                         size: 28,
//                       ),
//                       const SizedBox(width: 12),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'إجماليات الشهر',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             '$_selectedMonthName $_selectedYear',
//                             style: const TextStyle(color: Colors.white70),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 24),
//                   _buildTotalItem(
//                     icon: Icons.business,
//                     label: 'إجمالي دخل الشركات',
//                     value: _formatCurrency(_totalCompanyIncome),
//                     color: Colors.green[300]!,
//                     iconColor: Colors.green,
//                   ),
//                   const SizedBox(height: 12),
//                   _buildTotalItem(
//                     icon: Icons.person,
//                     label: 'إجمالي حساب السائقين',
//                     value: _formatCurrency(_totalDriversExpenses),
//                     color: Colors.orange[300]!,
//                     iconColor: Colors.orange,
//                   ),
//                   const SizedBox(height: 24),
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(color: Colors.white.withOpacity(0.3)),
//                     ),
//                     child: Column(
//                       children: [
//                         Row(
//                           children: [
//                             const Icon(
//                               Icons.attach_money,
//                               color: Colors.white,
//                               size: 24,
//                             ),
//                             const SizedBox(width: 12),
//                             const Text(
//                               'صافي الربح الشهري',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const Spacer(),
//                             Text(
//                               _formatCurrency(_netProfit),
//                               style: TextStyle(
//                                 color: _netProfit >= 0
//                                     ? Colors.green[300]!
//                                     : Colors.red[300]!,
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         const Text(
//                           'الدخل - السائقين',
//                           style: TextStyle(color: Colors.white70, fontSize: 12),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           if (_partners.isNotEmpty) _buildPartnersSummary(),
//           const SizedBox(height: 20),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 _calculateDistribution();
//                 _changeTab(2);
//               },
//               icon: const Icon(Icons.groups, size: 20),
//               label: const Text('عرض توزيع الربح على الشركاء'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF3498DB),
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ================================
//   // تبويب أرباح الشركات
//   // ================================
//   Widget _buildCompaniesProfitsTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           Card(
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   const Icon(
//                     Icons.business,
//                     color: Color(0xFF1B4F72),
//                     size: 24,
//                   ),
//                   const SizedBox(width: 12),
//                   const Text(
//                     'أرباح الشركات',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1B4F72),
//                     ),
//                   ),
//                   const Spacer(),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.blue[50],
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       '${_companyProfits.length} شركة',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blue,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           if (_companyProfits.isNotEmpty)
//             ..._companyProfits.map(
//               (company) => _buildCompanyProfitCard(company),
//             )
//           else
//             _buildNoDataCard('لا توجد بيانات للشركات هذا الشهر'),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   // ================================
//   // تبويب توزيع الربح
//   // ================================
//   Widget _buildDistributionTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 children: [
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.pie_chart,
//                         color: Color(0xFF1B4F72),
//                         size: 28,
//                       ),
//                       const SizedBox(width: 12),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'توزيع صافي الربح',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             'الشهر: $_selectedMonthName $_selectedYear',
//                             style: const TextStyle(
//                               color: Colors.grey,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const Spacer(),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: _netProfit >= 0
//                               ? Colors.green[50]
//                               : Colors.red[50],
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           _formatCurrency(_netProfit),
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: _netProfit >= 0 ? Colors.green : Colors.red,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[50],
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text('إجمالي الموزع:'),
//                             Text(
//                               _formatCurrency(_totalDistributed),
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.green,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text('المتبقي للتوزيع:'),
//                             Text(
//                               _formatCurrency(_remainingProfit),
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.orange,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 12),
//                         if (_isDistributionCompleted)
//                           Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.green[50],
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: const Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.check_circle, color: Colors.green),
//                                 SizedBox(width: 8),
//                                 Text(
//                                   'تم توزيع كامل الربح',
//                                   style: TextStyle(
//                                     color: Colors.green,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Card(
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       const Icon(Icons.info, color: Colors.blue, size: 20),
//                       const SizedBox(width: 8),
//                       const Text(
//                         'معلومات هامة',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.blue,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     '• يتم توزيع الأرباح بناءً على نسب الشركاء المضافة في صفحة رأس المال',
//                     style: TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 4),
//                   const Text(
//                     '• لإضافة أو تعديل أو حذف الشركاء، يرجى الذهاب إلى صفحة رأس المال',
//                     style: TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 4),
//                   const Text(
//                     '• إجمالي نسب الشركاء: يجب أن يساوي 100% للتوزيع الكامل',
//                     style: TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           if (_partners.isNotEmpty)
//             ..._partners.map(
//               (partner) => _buildPartnerDistributionCard(partner),
//             )
//           else
//             _buildNoPartnersCard(),
//           const SizedBox(height: 20),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: () {
//                 _calculateDistribution();
//                 _showSuccess('تم تحديث التوزيع');
//               },
//               icon: const Icon(Icons.refresh, size: 20),
//               label: const Text('تحديث التوزيع'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF1B4F72),
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//         ],
//       ),
//     );
//   }

//   // ================================
//   // بناء الواجهة الرئيسية
//   // ================================

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       initialIndex: _currentTab,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'توزيع الأرباح الشهرية',
//             style: TextStyle(color: Colors.white),
//           ),
//           centerTitle: true,
//           backgroundColor: const Color(0xFF1B4F72),
//           bottom: TabBar(
//             onTap: _changeTab,
//             indicatorColor: Colors.amber,
//             labelColor: Colors.amber,
//             unselectedLabelColor: Colors.white,
//             tabs: const [
//               Tab(icon: Icon(Icons.calculate), text: 'إجماليات الشهر'),
//               Tab(icon: Icon(Icons.business), text: 'أرباح الشركات'),
//               Tab(icon: Icon(Icons.groups), text: 'توزيع الربح'),
//             ],
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.refresh),
//               onPressed: _loadAllData,
//               tooltip: 'تحديث البيانات',
//             ),
//           ],
//         ),
//         body: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : TabBarView(
//                 children: [
//                   _buildMonthlyTotalsTab(),
//                   _buildCompaniesProfitsTab(),
//                   _buildDistributionTab(),
//                 ],
//               ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyProfitsPage extends StatefulWidget {
  const MonthlyProfitsPage({super.key});

  @override
  State<MonthlyProfitsPage> createState() => _MonthlyProfitsPageState();
}

class _MonthlyProfitsPageState extends State<MonthlyProfitsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================================
  // بيانات الشهر الحالي
  // ================================
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  String _selectedMonthName = '';

  // ================================
  // إجماليات الشهر
  // ================================
  double _totalCompanyIncome = 0.0;
  double _totalDriversExpenses = 0.0;
  double _netProfit = 0.0;

  // ================================
  // بيانات الشركات المنفصلة
  // ================================
  List<Map<String, dynamic>> _companyProfits = [];

  // ================================
  // بيانات الشركاء والتوزيع
  // ================================
  List<Map<String, dynamic>> _partners = [];
  double _totalDistributed = 0.0;
  double _remainingProfit = 0.0;
  bool _isDistributionCompleted = false;

  // ================================
  // متغيرات التحكم
  // ================================
  bool _isLoading = false;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _selectedMonthName = _getMonthName(_selectedMonth);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllData();
    });
  }

  // ================================
  // تحميل كل البيانات
  // ================================
  Future<void> _loadAllData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      await _calculateMonthlyTotals();
      await _loadCompanyProfits();
      await _loadPartnersFromCapitalPage();
      _calculateDistribution();
    } catch (e) {
      debugPrint('خطأ في تحميل البيانات: $e');
      _showError('خطأ في تحميل البيانات');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ================================
  // حساب إجماليات الشهر (من كوليكشنين)
  // ================================
  Future<void> _calculateMonthlyTotals() async {
    try {
      // تاريخ بداية ونهاية الشهر
      final startDate = DateTime(_selectedYear, _selectedMonth, 1);
      final endDate = DateTime(_selectedYear, _selectedMonth + 1, 1);

      // 1. حساب إجمالي دخل الشركات من dailyWork
      final companySnapshot = await _firestore
          .collection('dailyWork')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThan: Timestamp.fromDate(endDate))
          .get();

      double totalCompanyIncome = 0;
      for (var doc in companySnapshot.docs) {
        final data = doc.data();
        final nolon = _safeParseDouble(data['nolon'] ?? data['noLon'] ?? 0);
        final companyOvernight = _safeParseDouble(
          data['companyOvernight'] ?? 0,
        );
        final companyHoliday = _safeParseDouble(data['companyHoliday'] ?? 0);
        totalCompanyIncome += nolon + companyOvernight + companyHoliday;
      }

      // 2. حساب إجمالي تكاليف السائقين من drivers
      final driversSnapshot = await _firestore
          .collection('drivers')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThan: Timestamp.fromDate(endDate))
          .get();

      double totalDriversExpenses = 0;
      for (var doc in driversSnapshot.docs) {
        final data = doc.data();
        final wheelNolon = _safeParseDouble(data['wheelNolon'] ?? 0);
        final wheelOvernight = _safeParseDouble(data['wheelOvernight'] ?? 0);
        final wheelHoliday = _safeParseDouble(data['wheelHoliday'] ?? 0);
        totalDriversExpenses += wheelNolon + wheelOvernight + wheelHoliday;
      }

      // 3. حساب صافي الربح
      final netProfit = totalCompanyIncome - totalDriversExpenses;

      if (mounted) {
        setState(() {
          _totalCompanyIncome = totalCompanyIncome;
          _totalDriversExpenses = totalDriversExpenses;
          _netProfit = netProfit;
        });
      }
    } catch (e) {
      debugPrint('خطأ في حساب الإجماليات: $e');
      throw e;
    }
  }

  // ================================
  // تحميل أرباح كل شركة منفصلة
  // ================================
  Future<void> _loadCompanyProfits() async {
    try {
      // تاريخ بداية ونهاية الشهر
      final startDate = DateTime(_selectedYear, _selectedMonth, 1);
      final endDate = DateTime(_selectedYear, _selectedMonth + 1, 1);

      // 1. تجميع دخل الشركات من dailyWork
      final companySnapshot = await _firestore
          .collection('dailyWork')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThan: Timestamp.fromDate(endDate))
          .get();

      Map<String, Map<String, dynamic>> companiesMap = {};

      // تجميع دخل كل شركة
      for (var doc in companySnapshot.docs) {
        final data = doc.data();
        final companyId = (data['companyId'] ?? '').toString();
        final companyName = (data['companyName'] ?? 'غير معروف').toString();

        if (companyId.isEmpty || companyName.isEmpty) continue;

        final companyKey = '$companyId|$companyName'; // مفتاح فريد

        if (!companiesMap.containsKey(companyKey)) {
          companiesMap[companyKey] = {
            'companyId': companyId,
            'companyName': companyName,
            'totalIncome': 0.0,
            'totalDriversCost': 0.0,
            'companyProfit': 0.0,
            'tripCount': 0,
          };
        }

        final company = companiesMap[companyKey]!;

        // حساب دخل الشركة من هذه الرحلة
        final nolon = _safeParseDouble(data['nolon'] ?? data['noLon'] ?? 0);
        final companyOvernight = _safeParseDouble(
          data['companyOvernight'] ?? 0,
        );
        final companyHoliday = _safeParseDouble(data['companyHoliday'] ?? 0);
        final tripIncome = nolon + companyOvernight + companyHoliday;

        company['totalIncome'] =
            (company['totalIncome'] as double) + tripIncome;
        company['tripCount'] = (company['tripCount'] as int) + 1;
      }

      // 2. تجميع تكاليف السائقين لكل شركة من drivers
      final driversSnapshot = await _firestore
          .collection('drivers')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThan: Timestamp.fromDate(endDate))
          .get();

      for (var doc in driversSnapshot.docs) {
        final data = doc.data();
        final companyName = (data['companyName'] ?? '').toString().trim();

        if (companyName.isEmpty) continue;

        // البحث عن الشركة في الـ Map
        Map<String, dynamic>? foundCompany;
        for (var company in companiesMap.values) {
          if ((company['companyName'] as String).contains(companyName) ||
              companyName.contains(company['companyName'] as String)) {
            foundCompany = company;
            break;
          }
        }

        // إذا لم نجد الشركة، نضيفها جديدة
        if (foundCompany == null) {
          final companyKey = 'new|$companyName';
          companiesMap[companyKey] = {
            'companyId': 'new',
            'companyName': companyName,
            'totalIncome': 0.0,
            'totalDriversCost': 0.0,
            'companyProfit': 0.0,
            'tripCount': 0,
          };
          foundCompany = companiesMap[companyKey]!;
        }

        // إضافة تكاليف السائق
        final wheelNolon = _safeParseDouble(data['wheelNolon'] ?? 0);
        final wheelOvernight = _safeParseDouble(data['wheelOvernight'] ?? 0);
        final wheelHoliday = _safeParseDouble(data['wheelHoliday'] ?? 0);
        final driverCost = wheelNolon + wheelOvernight + wheelHoliday;

        foundCompany['totalDriversCost'] =
            (foundCompany['totalDriversCost'] as double) + driverCost;
      }

      // 3. حساب الربح لكل شركة
      for (var company in companiesMap.values) {
        company['companyProfit'] =
            (company['totalIncome'] as double) -
            (company['totalDriversCost'] as double);
      }

      // 4. تحويل إلى قائمة وترتيب حسب الربح
      List<Map<String, dynamic>> companyProfitsList = companiesMap.values
          .toList();

      // ترتيب حسب الربح (الأكبر أولاً)
      companyProfitsList.sort(
        (a, b) => b['companyProfit'].compareTo(a['companyProfit']),
      );

      // 5. إزالة الشركات التي ليس لها دخل ولا تكاليف
      companyProfitsList = companyProfitsList.where((company) {
        return company['totalIncome'] > 0 || company['totalDriversCost'] > 0;
      }).toList();

      if (mounted) {
        setState(() {
          _companyProfits = companyProfitsList;
        });
      }
    } catch (e) {
      debugPrint('خطأ في تحميل أرباح الشركات: $e');
      if (mounted) {
        setState(() {
          _companyProfits = [];
        });
      }
    }
  }

  // ================================
  // تحميل الشركاء من صفحة رأس المال
  // ================================
  Future<void> _loadPartnersFromCapitalPage() async {
    try {
      final partnersSnapshot = await _firestore
          .collection('partners')
          .orderBy('createdAt', descending: false)
          .get();

      List<Map<String, dynamic>> partnersList = [];

      for (var doc in partnersSnapshot.docs) {
        final data = doc.data();
        final name = (data['name'] ?? 'غير معروف').toString();
        final share = _safeParseDouble(data['share'] ?? 0);

        partnersList.add({
          'id': doc.id,
          'name': name,
          'share': share,
          'notes': data['notes'] ?? '',
          'createdAt':
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        });
      }

      if (mounted) {
        setState(() {
          _partners = partnersList;
        });
      }
    } catch (e) {
      debugPrint('خطأ في تحميل الشركاء: $e');
      if (mounted) {
        setState(() {
          _partners = [];
        });
      }
    }
  }

  // ================================
  // حساب توزيع الربح على الشركاء
  // ================================
  void _calculateDistribution() {
    if (_partners.isEmpty || _netProfit <= 0) {
      if (mounted) {
        setState(() {
          _totalDistributed = 0;
          _remainingProfit = _netProfit;
          _isDistributionCompleted = false;
        });
      }
      return;
    }

    double totalDistributed = 0;
    final List<Map<String, dynamic>> updatedPartners = [];

    // حساب حصة كل شريك
    for (var partner in _partners) {
      final percentage = (partner['share'] as num?)?.toDouble() ?? 0.0;
      final amount = (_netProfit * percentage) / 100;

      final updatedPartner = Map<String, dynamic>.from(partner);
      updatedPartner['profitShare'] = amount;
      updatedPartner['shareFormatted'] = _formatCurrency(amount);

      updatedPartners.add(updatedPartner);
      totalDistributed += amount;
    }

    if (mounted) {
      setState(() {
        _partners = updatedPartners;
        _totalDistributed = totalDistributed;
        _remainingProfit = _netProfit - totalDistributed;
        _isDistributionCompleted =
            (totalDistributed - _netProfit).abs() < 0.01; // تسامح 0.01
      });
    }
  }

  // ================================
  // تغيير الشهر
  // ================================
  Future<void> _changeMonth(int month) async {
    if (!mounted) return;

    setState(() {
      _selectedMonth = month;
      _selectedMonthName = _getMonthName(month);
      _isLoading = true;
    });

    try {
      await _calculateMonthlyTotals();
      await _loadCompanyProfits();
      _calculateDistribution();
    } catch (e) {
      _showError('خطأ في تحميل بيانات الشهر');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _changeYear(int year) async {
    if (!mounted) return;

    setState(() {
      _selectedYear = year;
      _isLoading = true;
    });

    try {
      await _calculateMonthlyTotals();
      await _loadCompanyProfits();
      _calculateDistribution();
    } catch (e) {
      _showError('خطأ في تحميل بيانات السنة');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ================================
  // دوال المساعدة
  // ================================
  double _safeParseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.tryParse(value.replaceAll(RegExp(r'[^\d.-]'), '')) ?? 0.0;
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  String _getMonthName(int month) {
    final months = [
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
    return months[month - 1];
  }

  Color _getPartnerColor(String name) {
    final hash = name.hashCode;
    final colors = [
      const Color(0xFF3498DB), // أزرق
      const Color(0xFF2ECC71), // أخضر
      const Color(0xFFE74C3C), // أحمر
      const Color(0xFFF39C12), // برتقالي
      const Color(0xFF9B59B6), // بنفسجي
      const Color(0xFF1ABC9C), // تركواز
    ];
    return colors[hash.abs() % colors.length];
  }

  Color _getCompanyColor(String name) {
    final hash = name.hashCode;
    final colors = [
      const Color(0xFF2980B9), // أزرق داكن
      const Color(0xFF27AE60), // أخضر داكن
      const Color(0xFFC0392B), // أحمر داكن
      const Color(0xFFD35400), // برتقالي داكن
      const Color(0xFF8E44AD), // بنفسجي داكن
      const Color(0xFF16A085), // تركواز داكن
    ];
    return colors[hash.abs() % colors.length];
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '??';
    final words = name
        .trim()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '??';
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return words[0].length >= 2
        ? words[0].substring(0, 2).toUpperCase()
        : words[0].toUpperCase();
  }

  String _getCompanyInitials(String name) {
    if (name.isEmpty) return '??';
    final firstWord = name
        .trim()
        .split(' ')
        .firstWhere((word) => word.isNotEmpty, orElse: () => '');
    if (firstWord.isEmpty) return '??';
    return firstWord[0].toUpperCase();
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} ج';
  }

  void _changeTab(int index) {
    if (mounted) {
      setState(() {
        _currentTab = index;
      });
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ================================
  // Widgets المساعدة
  // ================================
  Widget _buildMonthYearFilter() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'اختر الشهر والسنة',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  value: _selectedMonth,
                  onChanged: (value) {
                    if (value != null) {
                      _changeMonth(value);
                    }
                  },
                  items: List.generate(12, (index) {
                    final monthNumber = index + 1;
                    return DropdownMenuItem(
                      value: monthNumber,
                      child: Text(_getMonthName(monthNumber)),
                    );
                  }),
                ),
                const SizedBox(width: 20),
                DropdownButton<int>(
                  value: _selectedYear,
                  onChanged: (value) {
                    if (value != null) {
                      _changeYear(value);
                    }
                  },
                  items: [
                    for (
                      int i = DateTime.now().year - 2;
                      i <= DateTime.now().year + 1;
                      i++
                    )
                      DropdownMenuItem(value: i, child: Text('$i')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnersSummary() {
    if (_partners.isEmpty) return const SizedBox();

    double totalPercentage = 0;
    for (var partner in _partners) {
      totalPercentage += (partner['share'] as num?)?.toDouble() ?? 0;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.group, color: Color(0xFF3498DB), size: 24),
                const SizedBox(width: 12),
                const Text(
                  'ملخص الشركاء',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: totalPercentage == 100
                        ? Colors.green[50]
                        : Colors.orange[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_partners.length} شريك',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: totalPercentage == 100
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('إجمالي النسب:'),
                Text(
                  '${totalPercentage.toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: totalPercentage == 100
                        ? Colors.green
                        : totalPercentage > 100
                        ? Colors.red
                        : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('المتبقي:'),
                Text(
                  '${(100 - totalPercentage).toStringAsFixed(2)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyProfitCard(Map<String, dynamic> company) {
    final companyName = company['companyName'] ?? 'غير معروف';
    final totalIncome = _safeParseDouble(company['totalIncome']);
    final driversCost = _safeParseDouble(company['totalDriversCost']);
    final profit = _safeParseDouble(company['companyProfit']);
    final tripCount = (company['tripCount'] as int?) ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getCompanyColor(companyName),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      _getCompanyInitials(companyName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companyName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$tripCount رحلة',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الدخل',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        _formatCurrency(totalIncome),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'حساب السائقين',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        _formatCurrency(driversCost),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'صافي الربح',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        _formatCurrency(profit),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: profit >= 0 ? Colors.blue : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (totalIncome > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'نسبة الربحية:',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        '${((profit / totalIncome) * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: profit >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: (profit / totalIncome).clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: profit >= 0 ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(3),
                        ),
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

  Widget _buildPartnerDistributionCard(Map<String, dynamic> partner) {
    final percentage = _safeParseDouble(partner['share']);
    final share = _safeParseDouble(partner['profitShare'] ?? 0);
    final notes = (partner['notes'] ?? '').toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getPartnerColor(partner['name']),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(partner['name']),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              partner['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'حصة الشريك',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  _formatCurrency(share),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'نسبة من الربح',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                _netProfit > 0
                                    ? '${((share / _netProfit) * 100).toStringAsFixed(1)}%'
                                    : '0%',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (notes.isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ملاحظات:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        Text(notes, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoPartnersCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.group, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'لا يوجد شركاء مضافة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'يجب إضافة الشركاء أولاً من صفحة رأس المال',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataCard(String message) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================
  // تبويب إجماليات الشهر
  // ================================
  Widget _buildMonthlyTotalsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMonthYearFilter(),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [Color(0xFF1B4F72), Color(0xFF3498DB)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'إجماليات الشهر',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$_selectedMonthName $_selectedYear',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildTotalItem(
                    icon: Icons.business,
                    label: 'إجمالي دخل الشركات',
                    value: _formatCurrency(_totalCompanyIncome),
                    color: Colors.green[300]!,
                    iconColor: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildTotalItem(
                    icon: Icons.person,
                    label: 'إجمالي حساب السائقين',
                    value: _formatCurrency(_totalDriversExpenses),
                    color: Colors.orange[300]!,
                    iconColor: Colors.orange,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.attach_money,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'صافي الربح الشهري',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatCurrency(_netProfit),
                              style: TextStyle(
                                color: _netProfit >= 0
                                    ? Colors.green[300]!
                                    : Colors.red[300]!,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'الدخل - السائقين',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_partners.isNotEmpty) _buildPartnersSummary(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _calculateDistribution();
                _changeTab(2);
              },
              icon: const Icon(Icons.groups, size: 20),
              label: const Text('عرض توزيع الربح على الشركاء'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================
  // تبويب أرباح الشركات
  // ================================
  Widget _buildCompaniesProfitsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.business,
                    color: Color(0xFF1B4F72),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'أرباح الشركات',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4F72),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_companyProfits.length} شركة',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_companyProfits.isNotEmpty)
            ..._companyProfits.map(
              (company) => _buildCompanyProfitCard(company),
            )
          else
            _buildNoDataCard('لا توجد بيانات للشركات هذا الشهر'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ================================
  // تبويب توزيع الربح
  // ================================
  Widget _buildDistributionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.pie_chart,
                        color: Color(0xFF1B4F72),
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'توزيع صافي الربح',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'الشهر: $_selectedMonthName $_selectedYear',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _netProfit >= 0
                              ? Colors.green[50]
                              : Colors.red[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _formatCurrency(_netProfit),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _netProfit >= 0 ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('إجمالي الموزع:'),
                            Text(
                              _formatCurrency(_totalDistributed),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('المتبقي للتوزيع:'),
                            Text(
                              _formatCurrency(_remainingProfit),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_isDistributionCompleted)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: Colors.green),
                                SizedBox(width: 8),
                                Text(
                                  'تم توزيع كامل الربح',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
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
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'معلومات هامة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• يتم توزيع الأرباح بناءً على نسب الشركاء المضافة في صفحة رأس المال',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• لإضافة أو تعديل أو حذف الشركاء، يرجى الذهاب إلى صفحة رأس المال',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '• إجمالي نسب الشركاء: يجب أن يساوي 100% للتوزيع الكامل',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_partners.isNotEmpty)
            ..._partners.map(
              (partner) => _buildPartnerDistributionCard(partner),
            )
          else
            _buildNoPartnersCard(),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _calculateDistribution();
                _showSuccess('تم تحديث التوزيع');
              },
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('تحديث التوزيع'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B4F72),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ================================
  // بناء الواجهة الرئيسية
  // ================================

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: _currentTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'توزيع الأرباح الشهرية',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFF1B4F72),
          bottom: TabBar(
            onTap: _changeTab,
            indicatorColor: Colors.amber,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.white,
            tabs: const [
              Tab(icon: Icon(Icons.calculate), text: 'إجماليات الشهر'),
              Tab(icon: Icon(Icons.business), text: 'أرباح الشركات'),
              Tab(icon: Icon(Icons.groups), text: 'توزيع الربح'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadAllData,
              tooltip: 'تحديث البيانات',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildMonthlyTotalsTab(),
                  _buildCompaniesProfitsTab(),
                  _buildDistributionTab(),
                ],
              ),
      ),
    );
  }
}
