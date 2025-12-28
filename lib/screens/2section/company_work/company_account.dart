// // // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:intl/intl.dart';

// // // // class CompaniesAccountsPage extends StatefulWidget {
// // // //   const CompaniesAccountsPage({super.key});

// // // //   @override
// // // //   State<CompaniesAccountsPage> createState() => _CompaniesAccountsPageState();
// // // // }

// // // // class _CompaniesAccountsPageState extends State<CompaniesAccountsPage> {
// // // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// // // //   List<Map<String, dynamic>> _companies = [];
// // // //   List<Map<String, dynamic>> _filteredCompanies = [];
// // // //   String _searchQuery = '';
// // // //   bool _isLoading = false;

// // // //   // الإجماليات
// // // //   double _totalDebt = 0.0;
// // // //   double _totalPaid = 0.0;
// // // //   double _totalBalance = 0.0;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _loadCompaniesAccounts();
// // // //   }

// // // //   Future<void> _loadCompaniesAccounts() async {
// // // //     setState(() => _isLoading = true);

// // // //     try {
// // // //       // جلب بيانات الشركات من priceOffers
// // // //       final snapshot = await _firestore.collection('priceOffers').get();

// // // //       Map<String, Map<String, dynamic>> companyAccounts = {};

// // // //       for (final doc in snapshot.docs) {
// // // //         final data = doc.data();
// // // //         final companyName = data['companyName'] as String?;
// // // //         final companyId = data['companyId'] as String?;
// // // //         final transportations = data['transportations'] as List<dynamic>?;

// // // //         if (companyName != null &&
// // // //             companyName.isNotEmpty &&
// // // //             transportations != null) {
// // // //           final companyKey = companyId ?? companyName;

// // // //           if (!companyAccounts.containsKey(companyKey)) {
// // // //             companyAccounts[companyKey] = {
// // // //               'companyId': companyId,
// // // //               'companyName': companyName,
// // // //               'totalNolon': 0.0,
// // // //               'totalWheelNolon': 0.0,
// // // //               'totalCompanyOvernight': 0.0,
// // // //               'totalCompanyHoliday': 0.0,
// // // //               'totalTrips': 0,
// // // //               'totalDebt': 0.0,
// // // //               'totalPaid': 0.0,
// // // //               'lastTripDate': null,
// // // //             };
// // // //           }

// // // //           final account = companyAccounts[companyKey]!;

// // // //           for (final trans in transportations) {
// // // //             if (trans is Map<String, dynamic>) {
// // // //               // حساب نولون الشركات (الدين)
// // // //               account['totalNolon'] += (trans['nolon'] ?? trans['noLon'] ?? 0)
// // // //                   .toDouble();
// // // //               account['totalWheelNolon'] +=
// // // //                   (trans['wheelNolon'] ?? trans['wheelNoLon'] ?? 0).toDouble();
// // // //               account['totalCompanyOvernight'] +=
// // // //                   (trans['companyOvernight'] ?? 0).toDouble();
// // // //               account['totalCompanyHoliday'] += (trans['companyHoliday'] ?? 0)
// // // //                   .toDouble();
// // // //               account['totalTrips'] += 1;

// // // //               // الدين الكلي للشركة
// // // //               final companyDebt =
// // // //                   (trans['nolon'] ?? trans['noLon'] ?? 0).toDouble() +
// // // //                   (trans['companyOvernight'] ?? 0).toDouble() +
// // // //                   (trans['companyHoliday'] ?? 0).toDouble();

// // // //               account['totalDebt'] += companyDebt;
// // // //             }
// // // //           }
// // // //         }
// // // //       }

// // // //       // تحويل إلى قائمة
// // // //       final List<Map<String, dynamic>> companiesList = [];
// // // //       companyAccounts.forEach((key, value) {
// // // //         companiesList.add(value);
// // // //       });

// // // //       // ترتيب حسب الدين
// // // //       companiesList.sort((a, b) => b['totalDebt'].compareTo(a['totalDebt']));

// // // //       setState(() {
// // // //         _companies = companiesList;
// // // //         _filteredCompanies = _applySearch(companiesList);
// // // //         _isLoading = false;
// // // //         _calculateTotals();
// // // //       });
// // // //     } catch (e) {
// // // //       setState(() => _isLoading = false);
// // // //       _showError('خطأ في تحميل حسابات الشركات: $e');
// // // //     }
// // // //   }

// // // //   List<Map<String, dynamic>> _applySearch(
// // // //     List<Map<String, dynamic>> companies,
// // // //   ) {
// // // //     if (_searchQuery.isEmpty) return companies;

// // // //     return companies.where((company) {
// // // //       final companyName =
// // // //           company['companyName']?.toString().toLowerCase() ?? '';
// // // //       return companyName.contains(_searchQuery.toLowerCase());
// // // //     }).toList();
// // // //   }

// // // //   void _calculateTotals() {
// // // //     double totalDebt = 0.0;
// // // //     double totalPaid = 0.0;

// // // //     for (var company in _filteredCompanies) {
// // // //       totalDebt += company['totalDebt'];
// // // //       totalPaid += company['totalPaid'];
// // // //     }

// // // //     setState(() {
// // // //       _totalDebt = totalDebt;
// // // //       _totalPaid = totalPaid;
// // // //       _totalBalance = totalDebt - totalPaid;
// // // //     });
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
// // // //             Icon(Icons.search, color: Color(0xFF3498DB), size: 20),
// // // //             const SizedBox(width: 8),
// // // //             Expanded(
// // // //               child: TextField(
// // // //                 onChanged: (value) {
// // // //                   setState(() {
// // // //                     _searchQuery = value;
// // // //                     _filteredCompanies = _applySearch(_companies);
// // // //                     _calculateTotals();
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
// // // //               IconButton(
// // // //                 icon: Icon(Icons.clear, size: 18, color: Colors.grey),
// // // //                 onPressed: () {
// // // //                   setState(() => _searchQuery = '');
// // // //                   _filteredCompanies = _applySearch(_companies);
// // // //                   _calculateTotals();
// // // //                 },
// // // //               ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _buildTotalsSection() {
// // // //     return Container(
// // // //       padding: const EdgeInsets.all(16),
// // // //       color: Colors.blue[50],
// // // //       child: Column(
// // // //         children: [
// // // //           const Text(
// // // //             'الإجماليات',
// // // //             style: TextStyle(
// // // //               fontSize: 18,
// // // //               fontWeight: FontWeight.bold,
// // // //               color: Color(0xFF2C3E50),
// // // //             ),
// // // //           ),
// // // //           const SizedBox(height: 12),

// // // //           Row(
// // // //             mainAxisAlignment: MainAxisAlignment.spaceAround,
// // // //             children: [
// // // //               _buildAccountCard('إجمالي الدين', _totalDebt, Colors.red),
// // // //               _buildAccountCard('إجمالي المدفوع', _totalPaid, Colors.green),
// // // //               _buildAccountCard(
// // // //                 'الرصيد',
// // // //                 _totalBalance,
// // // //                 _totalBalance > 0 ? Colors.orange : Colors.blue,
// // // //               ),
// // // //             ],
// // // //           ),

// // // //           const SizedBox(height: 8),

// // // //           Container(
// // // //             padding: const EdgeInsets.all(12),
// // // //             decoration: BoxDecoration(
// // // //               color: Colors.white,
// // // //               borderRadius: BorderRadius.circular(8),
// // // //               border: Border.all(color: Colors.grey[300]!),
// // // //             ),
// // // //             child: Row(
// // // //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // //               children: [
// // // //                 Text(
// // // //                   'عدد الشركات: ${_filteredCompanies.length}',
// // // //                   style: const TextStyle(fontWeight: FontWeight.bold),
// // // //                 ),
// // // //                 Text(
// // // //                   'إجمالي الرحلات: ${_filteredCompanies.fold<int>(0, (sum, company) => sum + (company['totalTrips'] as int))}',
// // // //                   style: const TextStyle(fontWeight: FontWeight.bold),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _buildAccountCard(String label, double value, Color color) {
// // // //     return Column(
// // // //       children: [
// // // //         Text(
// // // //           label,
// // // //           style: TextStyle(
// // // //             fontSize: 12,
// // // //             color: color,
// // // //             fontWeight: FontWeight.bold,
// // // //           ),
// // // //         ),
// // // //         const SizedBox(height: 4),
// // // //         Text(
// // // //           '${value.toStringAsFixed(2)} ج',
// // // //           style: TextStyle(
// // // //             fontSize: 14,
// // // //             fontWeight: FontWeight.bold,
// // // //             color: color,
// // // //           ),
// // // //         ),
// // // //       ],
// // // //     );
// // // //   }

// // // //   Widget _buildCompaniesList() {
// // // //     if (_isLoading) {
// // // //       return const Center(child: CircularProgressIndicator());
// // // //     }

// // // //     if (_filteredCompanies.isEmpty) {
// // // //       return Center(
// // // //         child: Column(
// // // //           mainAxisAlignment: MainAxisAlignment.center,
// // // //           children: [
// // // //             Icon(Icons.business, size: 60, color: Colors.grey[400]),
// // // //             const SizedBox(height: 16),
// // // //             Text(
// // // //               _companies.isEmpty
// // // //                   ? 'لا توجد شركات مسجلة'
// // // //                   : 'لا توجد شركات مطابقة للبحث',
// // // //               style: const TextStyle(
// // // //                 fontSize: 16,
// // // //                 color: Colors.grey,
// // // //                 fontWeight: FontWeight.bold,
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       );
// // // //     }

// // // //     return ListView.builder(
// // // //       itemCount: _filteredCompanies.length,
// // // //       itemBuilder: (context, index) {
// // // //         final company = _filteredCompanies[index];
// // // //         final debt = company['totalDebt'];
// // // //         final paid = company['totalPaid'];
// // // //         final balance = debt - paid;

// // // //         return Card(
// // // //           margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// // // //           child: ListTile(
// // // //             contentPadding: const EdgeInsets.all(12),
// // // //             leading: CircleAvatar(
// // // //               backgroundColor: balance > 0
// // // //                   ? Colors.red[100]
// // // //                   : Colors.green[100],
// // // //               child: Icon(
// // // //                 Icons.business,
// // // //                 color: balance > 0 ? Colors.red[700] : Colors.green[700],
// // // //               ),
// // // //             ),
// // // //             title: Text(
// // // //               company['companyName'],
// // // //               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
// // // //             ),
// // // //             subtitle: Column(
// // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // //               children: [
// // // //                 const SizedBox(height: 8),
// // // //                 Row(
// // // //                   children: [
// // // //                     Expanded(
// // // //                       child: Text(
// // // //                         'الدين: ${debt.toStringAsFixed(2)} ج',
// // // //                         style: TextStyle(
// // // //                           color: Colors.red,
// // // //                           fontWeight: FontWeight.bold,
// // // //                         ),
// // // //                       ),
// // // //                     ),
// // // //                     Text(
// // // //                       'المدفوع: ${paid.toStringAsFixed(2)} ج',
// // // //                       style: TextStyle(
// // // //                         color: Colors.green,
// // // //                         fontWeight: FontWeight.bold,
// // // //                       ),
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //                 const SizedBox(height: 4),
// // // //                 Text(
// // // //                   'الرصيد: ${balance.toStringAsFixed(2)} ج',
// // // //                   style: TextStyle(
// // // //                     color: balance > 0 ? Colors.orange : Colors.blue,
// // // //                     fontWeight: FontWeight.bold,
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(height: 4),
// // // //                 Text(
// // // //                   'عدد الرحلات: ${company['totalTrips']}',
// // // //                   style: const TextStyle(fontSize: 12, color: Colors.grey),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //             trailing: Icon(
// // // //               Icons.arrow_forward_ios,
// // // //               size: 16,
// // // //               color: Colors.grey,
// // // //             ),
// // // //             onTap: () {
// // // //               _showCompanyDetails(company);
// // // //             },
// // // //           ),
// // // //         );
// // // //       },
// // // //     );
// // // //   }

// // // //   void _showCompanyDetails(Map<String, dynamic> company) {
// // // //     showDialog(
// // // //       context: context,
// // // //       builder: (context) => AlertDialog(
// // // //         title: Text(company['companyName']),
// // // //         content: SingleChildScrollView(
// // // //           child: Column(
// // // //             crossAxisAlignment: CrossAxisAlignment.start,
// // // //             children: [
// // // //               _buildDetailRow('رقم الرحلات', company['totalTrips'].toString()),
// // // //               _buildDetailRow(
// // // //                 'إجمالي نولون الشركات',
// // // //                 '${company['totalNolon'].toStringAsFixed(2)} ج',
// // // //               ),
// // // //               _buildDetailRow(
// // // //                 'إجمالي نولون العجلات',
// // // //                 '${company['totalWheelNolon'].toStringAsFixed(2)} ج',
// // // //               ),
// // // //               _buildDetailRow(
// // // //                 'إجمالي مبيت الشركات',
// // // //                 '${company['totalCompanyOvernight'].toStringAsFixed(2)} ج',
// // // //               ),
// // // //               _buildDetailRow(
// // // //                 'إجمالي عطلة الشركات',
// // // //                 '${company['totalCompanyHoliday'].toStringAsFixed(2)} ج',
// // // //               ),

// // // //               const SizedBox(height: 16),
// // // //               const Divider(),
// // // //               const SizedBox(height: 8),

// // // //               _buildDetailRow(
// // // //                 'إجمالي الدين',
// // // //                 '${company['totalDebt'].toStringAsFixed(2)} ج',
// // // //                 Colors.red,
// // // //               ),
// // // //               _buildDetailRow(
// // // //                 'إجمالي المدفوع',
// // // //                 '${company['totalPaid'].toStringAsFixed(2)} ج',
// // // //                 Colors.green,
// // // //               ),

// // // //               const SizedBox(height: 8),
// // // //               Container(
// // // //                 padding: const EdgeInsets.all(12),
// // // //                 decoration: BoxDecoration(
// // // //                   color: (company['totalDebt'] - company['totalPaid']) > 0
// // // //                       ? Colors.orange[50]
// // // //                       : Colors.blue[50],
// // // //                   borderRadius: BorderRadius.circular(8),
// // // //                   border: Border.all(
// // // //                     color: (company['totalDebt'] - company['totalPaid']) > 0
// // // //                         ? Colors.orange
// // // //                         : Colors.blue,
// // // //                   ),
// // // //                 ),
// // // //                 child: Row(
// // // //                   mainAxisAlignment: MainAxisAlignment.center,
// // // //                   children: [
// // // //                     Icon(
// // // //                       (company['totalDebt'] - company['totalPaid']) > 0
// // // //                           ? Icons.warning
// // // //                           : Icons.check_circle,
// // // //                       color: (company['totalDebt'] - company['totalPaid']) > 0
// // // //                           ? Colors.orange
// // // //                           : Colors.blue,
// // // //                     ),
// // // //                     const SizedBox(width: 8),
// // // //                     Text(
// // // //                       'الرصيد: ${(company['totalDebt'] - company['totalPaid']).toStringAsFixed(2)} ج',
// // // //                       style: TextStyle(
// // // //                         fontWeight: FontWeight.bold,
// // // //                         color: (company['totalDebt'] - company['totalPaid']) > 0
// // // //                             ? Colors.orange
// // // //                             : Colors.blue,
// // // //                       ),
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //         actions: [
// // // //           TextButton(
// // // //             onPressed: () => Navigator.pop(context),
// // // //             child: const Text('إغلاق'),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   Widget _buildDetailRow(String label, String value, [Color? color]) {
// // // //     return Padding(
// // // //       padding: const EdgeInsets.symmetric(vertical: 4),
// // // //       child: Row(
// // // //         children: [
// // // //           Text(
// // // //             '$label: ',
// // // //             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
// // // //           ),
// // // //           Expanded(
// // // //             child: Text(
// // // //               value,
// // // //               style: TextStyle(
// // // //                 fontSize: 14,
// // // //                 color: color,
// // // //                 fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   void _showError(String message) {
// // // //     ScaffoldMessenger.of(context).showSnackBar(
// // // //       SnackBar(content: Text(message), backgroundColor: Colors.red),
// // // //     );
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       backgroundColor: const Color(0xFFF4F6F8),
// // // //       body: Column(
// // // //         children: [
// // // //           // AppBar
// // // //           Container(
// // // //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// // // //             decoration: const BoxDecoration(
// // // //               gradient: LinearGradient(
// // // //                 begin: Alignment.centerRight,
// // // //                 end: Alignment.centerLeft,
// // // //                 colors: [Color(0xFF1B4F72), Color(0xFF3498DB)],
// // // //               ),
// // // //               boxShadow: [
// // // //                 BoxShadow(
// // // //                   color: Colors.black26,
// // // //                   blurRadius: 8,
// // // //                   offset: Offset(0, 2),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //             child: SafeArea(
// // // //               child: Row(
// // // //                 children: [
// // // //                   Icon(Icons.account_balance, color: Colors.white, size: 28),
// // // //                   const SizedBox(width: 8),
// // // //                   const Expanded(
// // // //                     child: Text(
// // // //                       'حسابات الشركات',
// // // //                       style: TextStyle(
// // // //                         color: Colors.white,
// // // //                         fontSize: 20,
// // // //                         fontWeight: FontWeight.bold,
// // // //                       ),
// // // //                     ),
// // // //                   ),
// // // //                   IconButton(
// // // //                     icon: Icon(Icons.refresh, color: Colors.white),
// // // //                     onPressed: _loadCompaniesAccounts,
// // // //                     tooltip: 'تحديث',
// // // //                   ),
// // // //                 ],
// // // //               ),
// // // //             ),
// // // //           ),

// // // //           // شريط البحث
// // // //           _buildSearchBar(),

// // // //           // الإجماليات
// // // //           _buildTotalsSection(),

// // // //           // قائمة الشركات
// // // //           Expanded(child: _buildCompaniesList()),
// // // //         ],
// // // //       ),

// // // //       floatingActionButton: FloatingActionButton(
// // // //         onPressed: _loadCompaniesAccounts,
// // // //         backgroundColor: const Color(0xFF3498DB),
// // // //         child: const Icon(Icons.refresh, color: Colors.white),
// // // //         tooltip: 'تحديث البيانات',
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // // import 'dart:async';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:intl/intl.dart';
// // // import 'package:flutter/widgets.dart' as flutter_widgets;

// // // class CompaniesAccountsPage extends StatefulWidget {
// // //   const CompaniesAccountsPage({super.key});

// // //   @override
// // //   State<CompaniesAccountsPage> createState() => _CompaniesAccountsPageState();
// // // }

// // // class _CompaniesAccountsPageState extends State<CompaniesAccountsPage> {
// // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// // //   List<Map<String, dynamic>> _companySummaries = [];
// // //   List<Map<String, dynamic>> _filteredSummaries = [];
// // //   List<Map<String, dynamic>> _finishedAccounts = [];
// // //   bool _isLoading = false;
// // //   bool _isLoadingFinished = false;
// // //   String _searchQuery = '';
// // //   String _statusFilter = 'جارية'; // الافتراضي: جارية

// // //   // متغيرات الفلتر الزمني
// // //   String _timeFilter = 'الكل';
// // //   int _selectedMonth = DateTime.now().month;
// // //   int _selectedYear = DateTime.now().year;
// // //   DateTime? _selectedDate;
// // //   bool _showFinishedAccounts = false;
// // //   String _finishedFilter = 'الكل';

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _loadCompanySummaries();
// // //     _loadFinishedAccounts();
// // //   }

// // //   // تحميل إجماليات حسابات الشركات
// // //   Future<void> _loadCompanySummaries() async {
// // //     setState(() => _isLoading = true);

// // //     try {
// // //       // محاولة تحميل من collection منفصلة
// // //       final snapshot = await _firestore.collection('companySummaries').get();

// // //       if (snapshot.docs.isEmpty) {
// // //         // إذا لم توجد بيانات، إنشاؤها من dailyWork
// // //         await _createCompanySummariesFromDailyWork();
// // //         return;
// // //       }

// // //       final summariesList = snapshot.docs.map((doc) {
// // //         final data = doc.data();

// // //         final totalCompanyDebt = (data['totalCompanyDebt'] ?? 0).toDouble();
// // //         final totalPaidAmount = (data['totalPaidAmount'] ?? 0).toDouble();
// // //         final totalRemainingAmount = totalCompanyDebt - totalPaidAmount;

// // //         String status;
// // //         if (totalRemainingAmount <= 0) {
// // //           status = 'منتهية';
// // //         } else if (totalPaidAmount > 0 && totalRemainingAmount > 0) {
// // //           status = 'شبه منتهية';
// // //         } else {
// // //           status = 'جارية';
// // //         }

// // //         return {
// // //           'companyId': data['companyId'] ?? '',
// // //           'companyName': data['companyName'] ?? 'غير معروف',
// // //           'totalCompanyDebt': totalCompanyDebt,
// // //           'totalPaidAmount': totalPaidAmount,
// // //           'totalRemainingAmount': totalRemainingAmount,
// // //           'status': status,
// // //           'totalTrips': (data['totalTrips'] ?? 0).toInt(),
// // //           'docId': doc.id,
// // //           'lastUpdated': data['lastUpdated'],
// // //         };
// // //       }).toList();

// // //       summariesList.sort(
// // //         (a, b) =>
// // //             b['totalRemainingAmount'].compareTo(a['totalRemainingAmount']),
// // //       );

// // //       setState(() {
// // //         _companySummaries = summariesList;
// // //         _filteredSummaries = _applyFilters(summariesList);
// // //         _isLoading = false;
// // //       });
// // //     } catch (e) {
// // //       setState(() => _isLoading = false);
// // //       _showError('خطأ في تحميل حسابات الشركات: $e');
// // //     }
// // //   }

// // //   // إنشاء إجماليات الشركات من dailyWork
// // //   Future<void> _createCompanySummariesFromDailyWork() async {
// // //     try {
// // //       final snapshot = await _firestore.collection('dailyWork').get();
// // //       Map<String, Map<String, dynamic>> companyTotals = {};

// // //       for (final doc in snapshot.docs) {
// // //         final data = doc.data();
// // //         final companyId = data['companyId'] as String?;
// // //         final companyName = data['companyName'] as String?;

// // //         if (companyId != null && companyId.isNotEmpty) {
// // //           final companyKey = companyId;

// // //           if (!companyTotals.containsKey(companyKey)) {
// // //             companyTotals[companyKey] = {
// // //               'companyId': companyId,
// // //               'companyName': companyName ?? 'شركة غير معروفة',
// // //               'totalCompanyDebt': 0.0,
// // //               'totalPaidAmount': 0.0,
// // //               'totalTrips': 0,
// // //             };
// // //           }

// // //           final total = companyTotals[companyKey]!;

// // //           // حساب دين الشركة (نولون + مبيت + عطلة)
// // //           final nolon = (data['nolon'] ?? data['noLon'] ?? 0).toDouble();
// // //           final companyOvernight = (data['companyOvernight'] ?? 0).toDouble();
// // //           final companyHoliday = (data['companyHoliday'] ?? 0).toDouble();

// // //           total['totalCompanyDebt'] +=
// // //               nolon + companyOvernight + companyHoliday;
// // //           total['totalTrips'] += 1;
// // //         }
// // //       }

// // //       final batch = _firestore.batch();
// // //       for (var entry in companyTotals.entries) {
// // //         final summary = entry.value;

// // //         final docRef = _firestore.collection('companySummaries').doc(entry.key);
// // //         final existingDoc = await docRef.get();

// // //         if (existingDoc.exists) {
// // //           final existingData = existingDoc.data()!;
// // //           summary['totalPaidAmount'] = existingData['totalPaidAmount'] ?? 0;
// // //         } else {
// // //           summary['totalPaidAmount'] = 0.0;
// // //         }

// // //         summary['totalRemainingAmount'] =
// // //             summary['totalCompanyDebt'] - summary['totalPaidAmount'];

// // //         String status;
// // //         if (summary['totalRemainingAmount'] <= 0) {
// // //           status = 'منتهية';
// // //         } else if (summary['totalPaidAmount'] > 0) {
// // //           status = 'شبه منتهية';
// // //         } else {
// // //           status = 'جارية';
// // //         }

// // //         summary['status'] = status;
// // //         summary['lastUpdated'] = Timestamp.now();

// // //         batch.set(docRef, summary);
// // //       }

// // //       await batch.commit();
// // //       _loadCompanySummaries();
// // //     } catch (e) {
// // //       _showError('خطأ في إنشاء بيانات الشركات: $e');
// // //     }
// // //   }

// // //   // تحميل الحسابات المنتهية
// // //   Future<void> _loadFinishedAccounts() async {
// // //     setState(() => _isLoadingFinished = true);

// // //     try {
// // //       final snapshot = await _firestore
// // //           .collection('finishedCompanyAccounts')
// // //           .orderBy('lastUpdated', descending: true)
// // //           .get();

// // //       final finishedList = snapshot.docs.map((doc) {
// // //         final data = doc.data();
// // //         final timestamp = data['lastUpdated'] as Timestamp?;

// // //         return {
// // //           'companyName': data['companyName'] ?? 'غير معروف',
// // //           'totalReceived': (data['totalReceived'] ?? 0).toDouble(),
// // //           'lastUpdated': timestamp,
// // //           'dateFormatted': timestamp != null
// // //               ? DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate())
// // //               : 'غير معروف',
// // //           'docId': doc.id,
// // //         };
// // //       }).toList();

// // //       setState(() {
// // //         _finishedAccounts = _applyFinishedFilters(finishedList);
// // //         _isLoadingFinished = false;
// // //       });
// // //     } catch (e) {
// // //       setState(() => _isLoadingFinished = false);
// // //       print('خطأ في تحميل الحسابات المنتهية: $e');
// // //     }
// // //   }

// // //   // فلترة الحسابات المنتهية
// // //   List<Map<String, dynamic>> _applyFinishedFilters(
// // //     List<Map<String, dynamic>> accounts,
// // //   ) {
// // //     final now = DateTime.now();
// // //     final today = DateTime(now.year, now.month, now.day);
// // //     final firstDayOfMonth = DateTime(now.year, now.month, 1);
// // //     final firstDayOfYear = DateTime(now.year, 1, 1);

// // //     return accounts.where((account) {
// // //       final timestamp = account['lastUpdated'] as Timestamp?;
// // //       if (timestamp == null) return false;

// // //       final date = timestamp.toDate();

// // //       if (_finishedFilter == 'اليوم') {
// // //         final accountDate = DateTime(date.year, date.month, date.day);
// // //         return accountDate == today;
// // //       } else if (_finishedFilter == 'الشهر') {
// // //         return date.isAfter(firstDayOfMonth) ||
// // //             date.isAtSameMomentAs(firstDayOfMonth);
// // //       } else if (_finishedFilter == 'سنة') {
// // //         return date.isAfter(firstDayOfYear) ||
// // //             date.isAtSameMomentAs(firstDayOfYear);
// // //       }

// // //       return true; // 'الكل'
// // //     }).toList();
// // //   }

// // //   // تطبيق الفلاتر
// // //   List<Map<String, dynamic>> _applyFilters(
// // //     List<Map<String, dynamic>> summaries,
// // //   ) {
// // //     return summaries.where((summary) {
// // //       if (_searchQuery.isNotEmpty) {
// // //         if (!summary['companyName'].toLowerCase().contains(
// // //           _searchQuery.toLowerCase(),
// // //         )) {
// // //           return false;
// // //         }
// // //       }

// // //       // تطبيق الفلتر الزمني
// // //       if (_timeFilter != 'الكل') {
// // //         final timestamp = summary['lastUpdated'] as Timestamp?;
// // //         if (timestamp == null) return false;

// // //         final now = DateTime.now();
// // //         final summaryDate = timestamp.toDate();

// // //         switch (_timeFilter) {
// // //           case 'اليوم':
// // //             if (summaryDate.year != now.year ||
// // //                 summaryDate.month != now.month ||
// // //                 summaryDate.day != now.day) {
// // //               return false;
// // //             }
// // //             break;
// // //           case 'هذا الشهر':
// // //             if (summaryDate.year != now.year ||
// // //                 summaryDate.month != now.month) {
// // //               return false;
// // //             }
// // //             break;
// // //           case 'هذه السنة':
// // //             if (summaryDate.year != now.year) {
// // //               return false;
// // //             }
// // //             break;
// // //           case 'مخصص':
// // //             if (_selectedDate != null) {
// // //               final selected = _selectedDate!;
// // //               if (summaryDate.year != selected.year ||
// // //                   summaryDate.month != selected.month ||
// // //                   summaryDate.day != selected.day) {
// // //                 return false;
// // //               }
// // //             }
// // //             break;
// // //         }
// // //       }

// // //       if (_statusFilter == 'جارية') {
// // //         return summary['status'] == 'جارية';
// // //       } else if (_statusFilter == 'شبه منتهية') {
// // //         return summary['status'] == 'شبه منتهية';
// // //       } else if (_statusFilter == 'منتهية') {
// // //         return summary['status'] == 'منتهية';
// // //       }

// // //       return true;
// // //     }).toList();
// // //   }

// // //   // تغيير فلتر الوقت
// // //   void _changeTimeFilter(String filter) {
// // //     setState(() {
// // //       _timeFilter = filter;
// // //       _filteredSummaries = _applyFilters(_companySummaries);
// // //     });
// // //   }

// // //   void _applyMonthYearFilter() {
// // //     setState(() {
// // //       _timeFilter = 'مخصص';
// // //       _filteredSummaries = _applyFilters(_companySummaries);
// // //     });
// // //   }

// // //   // اختيار تاريخ محدد
// // //   Future<void> _selectDate() async {
// // //     final selected = await showDatePicker(
// // //       context: context,
// // //       initialDate: DateTime.now(),
// // //       firstDate: DateTime(2020),
// // //       lastDate: DateTime.now(),
// // //       builder: (context, child) {
// // //         return Directionality(
// // //           textDirection: flutter_widgets.TextDirection.rtl,
// // //           child: child!,
// // //         );
// // //       },
// // //     );

// // //     if (selected != null) {
// // //       setState(() {
// // //         _selectedDate = selected;
// // //         _timeFilter = 'مخصص';
// // //         _filteredSummaries = _applyFilters(_companySummaries);
// // //       });
// // //     }
// // //   }

// // //   // استقبال دفعة من شركة
// // //   Future<void> _receivePayment(Map<String, dynamic> summary) async {
// // //     final amountController = TextEditingController();
// // //     final companyName = summary['companyName'];
// // //     final remainingAmount = summary['totalRemainingAmount'] as double;

// // //     if (remainingAmount <= 0) {
// // //       _showError('الحساب منتهي بالفعل');
// // //       return;
// // //     }

// // //     await showDialog(
// // //       context: context,
// // //       builder: (context) => Directionality(
// // //         textDirection: flutter_widgets.TextDirection.rtl,
// // //         child: Dialog(
// // //           backgroundColor: Colors.white,
// // //           shape: RoundedRectangleBorder(
// // //             borderRadius: BorderRadius.circular(12),
// // //           ),
// // //           child: Container(
// // //             padding: const EdgeInsets.all(16),
// // //             child: Column(
// // //               mainAxisSize: MainAxisSize.min,
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 Row(
// // //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                   children: [
// // //                     Text(
// // //                       'استلام دفعة: $companyName',
// // //                       style: const TextStyle(
// // //                         fontSize: 16,
// // //                         fontWeight: FontWeight.bold,
// // //                         color: Color(0xFF2C3E50),
// // //                       ),
// // //                     ),
// // //                     IconButton(
// // //                       icon: const Icon(Icons.close, size: 18),
// // //                       onPressed: () => Navigator.pop(context),
// // //                       padding: EdgeInsets.zero,
// // //                     ),
// // //                   ],
// // //                 ),
// // //                 const SizedBox(height: 8),
// // //                 const Divider(height: 1),
// // //                 const SizedBox(height: 12),
// // //                 Text(
// // //                   'المستحق: ${remainingAmount.toStringAsFixed(2)} ج',
// // //                   style: const TextStyle(
// // //                     fontSize: 14,
// // //                     color: Colors.red,
// // //                     fontWeight: FontWeight.bold,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 16),
// // //                 TextFormField(
// // //                   controller: amountController,
// // //                   keyboardType: TextInputType.number,
// // //                   decoration: InputDecoration(
// // //                     labelText: 'المبلغ المستلم',
// // //                     border: OutlineInputBorder(
// // //                       borderRadius: BorderRadius.circular(8),
// // //                     ),
// // //                     contentPadding: const EdgeInsets.symmetric(
// // //                       horizontal: 12,
// // //                       vertical: 10,
// // //                     ),
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 20),
// // //                 Row(
// // //                   children: [
// // //                     Expanded(
// // //                       child: OutlinedButton(
// // //                         onPressed: () => Navigator.pop(context),
// // //                         style: OutlinedButton.styleFrom(
// // //                           padding: const EdgeInsets.symmetric(vertical: 10),
// // //                           shape: RoundedRectangleBorder(
// // //                             borderRadius: BorderRadius.circular(8),
// // //                           ),
// // //                         ),
// // //                         child: const Text(
// // //                           'إلغاء',
// // //                           style: TextStyle(fontSize: 14),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                     const SizedBox(width: 8),
// // //                     Expanded(
// // //                       child: ElevatedButton(
// // //                         onPressed: () async {
// // //                           final paymentAmount =
// // //                               double.tryParse(amountController.text) ?? 0.0;

// // //                           if (paymentAmount <= 0) {
// // //                             _showError('أدخل مبلغ صحيح');
// // //                             return;
// // //                           }

// // //                           if (paymentAmount > remainingAmount) {
// // //                             _showError('المبلغ أكبر من المستحق');
// // //                             return;
// // //                           }

// // //                           await _updatePayment(summary, paymentAmount);
// // //                           Navigator.pop(context);
// // //                         },
// // //                         style: ElevatedButton.styleFrom(
// // //                           backgroundColor: const Color(0xFF27AE60),
// // //                           foregroundColor: Colors.white,
// // //                           padding: const EdgeInsets.symmetric(vertical: 10),
// // //                           shape: RoundedRectangleBorder(
// // //                             borderRadius: BorderRadius.circular(8),
// // //                           ),
// // //                         ),
// // //                         child: const Text(
// // //                           'تسجيل الدفعة',
// // //                           style: TextStyle(fontSize: 14),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // تحديث الدفعة في قاعدة البيانات
// // //   Future<void> _updatePayment(
// // //     Map<String, dynamic> summary,
// // //     double paymentAmount,
// // //   ) async {
// // //     try {
// // //       final docRef = _firestore
// // //           .collection('companySummaries')
// // //           .doc(summary['companyId']);
// // //       final doc = await docRef.get();

// // //       if (!doc.exists) return;

// // //       final data = doc.data()!;
// // //       final currentPaidAmount = (data['totalPaidAmount'] ?? 0).toDouble();
// // //       final totalCompanyDebt = (data['totalCompanyDebt'] ?? 0).toDouble();
// // //       final newPaidAmount = currentPaidAmount + paymentAmount;
// // //       final totalRemainingAmount = totalCompanyDebt - newPaidAmount;

// // //       String status;
// // //       if (totalRemainingAmount <= 0) {
// // //         status = 'منتهية';
// // //       } else if (newPaidAmount > 0 && totalRemainingAmount > 0) {
// // //         status = 'شبه منتهية';
// // //       } else {
// // //         status = 'جارية';
// // //       }

// // //       await docRef.update({
// // //         'totalPaidAmount': newPaidAmount,
// // //         'totalRemainingAmount': totalRemainingAmount,
// // //         'status': status,
// // //         'lastUpdated': Timestamp.now(),
// // //       });

// // //       // إذا أصبح الحساب منتهياً، إضافته للحسابات المنتهية
// // //       if (totalRemainingAmount <= 0) {
// // //         final finishedRef = _firestore
// // //             .collection('finishedCompanyAccounts')
// // //             .doc(summary['companyId']);
// // //         final finishedDoc = await finishedRef.get();

// // //         if (finishedDoc.exists) {
// // //           final existingData = finishedDoc.data()!;
// // //           final previousTotal = (existingData['totalReceived'] ?? 0).toDouble();
// // //           await finishedRef.update({
// // //             'totalReceived': previousTotal + newPaidAmount,
// // //             'lastUpdated': Timestamp.now(),
// // //           });
// // //         } else {
// // //           await finishedRef.set({
// // //             'companyId': summary['companyId'],
// // //             'companyName': summary['companyName'],
// // //             'totalReceived': newPaidAmount,
// // //             'lastUpdated': Timestamp.now(),
// // //           });
// // //         }

// // //         await _loadFinishedAccounts();
// // //       }

// // //       _showSuccess('تم تسجيل الدفعة بنجاح');
// // //       _loadCompanySummaries();
// // //     } catch (e) {
// // //       _showError('خطأ في تسجيل الدفعة: $e');
// // //     }
// // //   }

// // //   // عرض تفاصيل الشركة
// // //   void _showCompanyDetails(Map<String, dynamic> summary) {
// // //     showDialog(
// // //       context: context,
// // //       builder: (context) => Directionality(
// // //         textDirection: flutter_widgets.TextDirection.rtl,
// // //         child: Dialog(
// // //           backgroundColor: Colors.white,
// // //           shape: RoundedRectangleBorder(
// // //             borderRadius: BorderRadius.circular(12),
// // //           ),
// // //           child: Container(
// // //             padding: const EdgeInsets.all(16),
// // //             child: Column(
// // //               mainAxisSize: MainAxisSize.min,
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 Row(
// // //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                   children: [
// // //                     Text(
// // //                       'تفاصيل حساب: ${summary['companyName']}',
// // //                       style: const TextStyle(
// // //                         fontSize: 16,
// // //                         fontWeight: FontWeight.bold,
// // //                         color: Color(0xFF2C3E50),
// // //                       ),
// // //                     ),
// // //                     IconButton(
// // //                       icon: const Icon(Icons.close, size: 18),
// // //                       onPressed: () => Navigator.pop(context),
// // //                       padding: EdgeInsets.zero,
// // //                     ),
// // //                   ],
// // //                 ),
// // //                 const SizedBox(height: 8),
// // //                 const Divider(height: 1),
// // //                 const SizedBox(height: 12),

// // //                 // معلومات الحساب
// // //                 _buildDetailItem(
// // //                   'إجمالي الدين',
// // //                   '${summary['totalCompanyDebt'].toStringAsFixed(2)} ج',
// // //                   Colors.red,
// // //                 ),
// // //                 _buildDetailItem(
// // //                   'المبلغ المدفوع',
// // //                   '${summary['totalPaidAmount'].toStringAsFixed(2)} ج',
// // //                   Colors.green,
// // //                 ),
// // //                 _buildDetailItem(
// // //                   'المبلغ المتبقي',
// // //                   '${summary['totalRemainingAmount'].toStringAsFixed(2)} ج',
// // //                   summary['totalRemainingAmount'] > 0
// // //                       ? Colors.orange
// // //                       : Colors.blue,
// // //                 ),

// // //                 const SizedBox(height: 8),
// // //                 const Divider(),
// // //                 const SizedBox(height: 8),

// // //                 _buildDetailItem('عدد الرحلات', '${summary['totalTrips']}'),
// // //                 _buildDetailItem(
// // //                   'الحالة',
// // //                   summary['status'],
// // //                   _getStatusColor(summary['status']),
// // //                 ),

// // //                 const SizedBox(height: 20),
// // //                 SizedBox(
// // //                   width: double.infinity,
// // //                   child: ElevatedButton(
// // //                     onPressed: () => Navigator.pop(context),
// // //                     style: ElevatedButton.styleFrom(
// // //                       backgroundColor: const Color(0xFF3498DB),
// // //                       foregroundColor: Colors.white,
// // //                       padding: const EdgeInsets.symmetric(vertical: 10),
// // //                       shape: RoundedRectangleBorder(
// // //                         borderRadius: BorderRadius.circular(8),
// // //                       ),
// // //                     ),
// // //                     child: const Text('إغلاق'),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // بناء عنصر التفاصيل
// // //   Widget _buildDetailItem(String label, String value, [Color? color]) {
// // //     return Padding(
// // //       padding: const EdgeInsets.symmetric(vertical: 6),
// // //       child: Row(
// // //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //         children: [
// // //           Text(
// // //             label,
// // //             style: const TextStyle(fontSize: 14, color: Color(0xFF2C3E50)),
// // //           ),
// // //           Text(
// // //             value,
// // //             style: TextStyle(
// // //               fontSize: 14,
// // //               fontWeight: FontWeight.bold,
// // //               color: color ?? const Color(0xFF3498DB),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // المربعات الثلاثة العلوية
// // //   Widget _buildStatusRow() {
// // //     if (_showFinishedAccounts) return const SizedBox();

// // //     return Container(
// // //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// // //       child: Row(
// // //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //         children: [
// // //           _buildStatusBox('جارية', const Color(0xFFE74C3C), Icons.access_time),
// // //           _buildStatusBox(
// // //             'شبه منتهية',
// // //             const Color(0xFFF39C12),
// // //             Icons.hourglass_bottom,
// // //           ),
// // //           _buildStatusBox(
// // //             'منتهية',
// // //             const Color(0xFF27AE60),
// // //             Icons.check_circle,
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildStatusBox(String status, Color color, IconData icon) {
// // //     final count = _companySummaries.where((s) => s['status'] == status).length;
// // //     final isSelected = _statusFilter == status;

// // //     return GestureDetector(
// // //       onTap: () {
// // //         setState(() {
// // //           _statusFilter = status;
// // //           _filteredSummaries = _applyFilters(_companySummaries);
// // //         });
// // //       },
// // //       child: Container(
// // //         width: 100,
// // //         padding: const EdgeInsets.symmetric(vertical: 10),
// // //         decoration: BoxDecoration(
// // //           color: isSelected ? color : color.withOpacity(0.1),
// // //           borderRadius: BorderRadius.circular(10),
// // //           border: Border.all(
// // //             color: isSelected ? color : color.withOpacity(0.3),
// // //             width: 1.5,
// // //           ),
// // //         ),
// // //         child: Column(
// // //           mainAxisAlignment: MainAxisAlignment.center,
// // //           children: [
// // //             Icon(icon, color: isSelected ? Colors.white : color, size: 22),
// // //             const SizedBox(height: 4),
// // //             Text(
// // //               status,
// // //               style: TextStyle(
// // //                 color: isSelected ? Colors.white : color,
// // //                 fontWeight: FontWeight.bold,
// // //                 fontSize: 12,
// // //               ),
// // //             ),
// // //             const SizedBox(height: 4),
// // //             Text(
// // //               '$count',
// // //               style: TextStyle(
// // //                 color: isSelected ? Colors.white : color,
// // //                 fontWeight: FontWeight.bold,
// // //                 fontSize: 14,
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // قسم الفلتر الزمني
// // //   Widget _buildTimeFilterSection() {
// // //     if (_showFinishedAccounts) return const SizedBox();

// // //     return Container(
// // //       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
// // //       color: Colors.white,
// // //       child: Column(
// // //         children: [
// // //           SingleChildScrollView(
// // //             scrollDirection: Axis.horizontal,
// // //             child: Row(
// // //               children: ['الكل', 'اليوم', 'هذا الشهر', 'هذه السنة', 'مخصص']
// // //                   .map(
// // //                     (filter) => Padding(
// // //                       padding: const EdgeInsets.symmetric(horizontal: 4),
// // //                       child: ChoiceChip(
// // //                         label: Text(filter),
// // //                         selected: _timeFilter == filter,
// // //                         onSelected: (selected) {
// // //                           if (selected) _changeTimeFilter(filter);
// // //                         },
// // //                         selectedColor: const Color(0xFF3498DB),
// // //                         labelStyle: TextStyle(
// // //                           color: _timeFilter == filter
// // //                               ? Colors.white
// // //                               : const Color(0xFF2C3E50),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   )
// // //                   .toList(),
// // //             ),
// // //           ),
// // //           const SizedBox(height: 12),
// // //           if (_timeFilter == 'مخصص')
// // //             Row(
// // //               mainAxisAlignment: MainAxisAlignment.center,
// // //               children: [
// // //                 const Icon(Icons.calendar_month, color: Color(0xFF3498DB)),
// // //                 const SizedBox(width: 8),
// // //                 DropdownButton<int>(
// // //                   value: _selectedMonth,
// // //                   onChanged: (value) {
// // //                     if (value != null) {
// // //                       setState(() => _selectedMonth = value);
// // //                       _applyMonthYearFilter();
// // //                     }
// // //                   },
// // //                   items: List.generate(12, (index) {
// // //                     final monthNumber = index + 1;
// // //                     return DropdownMenuItem(
// // //                       value: monthNumber,
// // //                       child: Text('شهر $monthNumber'),
// // //                     );
// // //                   }),
// // //                 ),
// // //                 const SizedBox(width: 20),
// // //                 DropdownButton<int>(
// // //                   value: _selectedYear,
// // //                   onChanged: (value) {
// // //                     if (value != null) {
// // //                       setState(() => _selectedYear = value);
// // //                       _applyMonthYearFilter();
// // //                     }
// // //                   },
// // //                   items: [
// // //                     for (
// // //                       int i = DateTime.now().year - 2;
// // //                       i <= DateTime.now().year + 2;
// // //                       i++
// // //                     )
// // //                       DropdownMenuItem(value: i, child: Text('$i')),
// // //                   ],
// // //                 ),
// // //               ],
// // //             ),
// // //           if (_timeFilter == 'مخصص') const SizedBox(height: 12),
// // //           if (_timeFilter == 'مخصص')
// // //             Row(
// // //               mainAxisAlignment: MainAxisAlignment.center,
// // //               children: [
// // //                 ElevatedButton.icon(
// // //                   onPressed: _selectDate,
// // //                   icon: const Icon(Icons.calendar_today, size: 16),
// // //                   label: Text(
// // //                     _selectedDate != null
// // //                         ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
// // //                         : 'اختر تاريخ محدد',
// // //                     style: const TextStyle(fontSize: 12),
// // //                   ),
// // //                   style: ElevatedButton.styleFrom(
// // //                     backgroundColor: const Color(0xFF2C3E50),
// // //                     foregroundColor: Colors.white,
// // //                     padding: const EdgeInsets.symmetric(
// // //                       horizontal: 16,
// // //                       vertical: 8,
// // //                     ),
// // //                   ),
// // //                 ),
// // //                 if (_selectedDate != null)
// // //                   IconButton(
// // //                     onPressed: () {
// // //                       setState(() {
// // //                         _selectedDate = null;
// // //                         _filteredSummaries = _applyFilters(_companySummaries);
// // //                       });
// // //                     },
// // //                     icon: const Icon(Icons.clear, color: Colors.red),
// // //                   ),
// // //               ],
// // //             ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // فلتر الحسابات المنتهية
// // //   Widget _buildFinishedFilter() {
// // //     if (!_showFinishedAccounts) return const SizedBox();

// // //     return Container(
// // //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // //       child: Wrap(
// // //         spacing: 8,
// // //         runSpacing: 8,
// // //         children: [
// // //           _buildFilterChip('الكل', _finishedFilter == 'الكل', () {
// // //             setState(() {
// // //               _finishedFilter = 'الكل';
// // //               _finishedAccounts = _applyFinishedFilters(_finishedAccounts);
// // //             });
// // //           }),
// // //           _buildFilterChip('اليوم', _finishedFilter == 'اليوم', () {
// // //             setState(() {
// // //               _finishedFilter = 'اليوم';
// // //               _finishedAccounts = _applyFinishedFilters(_finishedAccounts);
// // //             });
// // //           }),
// // //           _buildFilterChip('الشهر', _finishedFilter == 'الشهر', () {
// // //             setState(() {
// // //               _finishedFilter = 'الشهر';
// // //               _finishedAccounts = _applyFinishedFilters(_finishedAccounts);
// // //             });
// // //           }),
// // //           _buildFilterChip('سنة', _finishedFilter == 'سنة', () {
// // //             setState(() {
// // //               _finishedFilter = 'سنة';
// // //               _finishedAccounts = _applyFinishedFilters(_finishedAccounts);
// // //             });
// // //           }),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
// // //     return GestureDetector(
// // //       onTap: onTap,
// // //       child: Container(
// // //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// // //         decoration: BoxDecoration(
// // //           color: selected ? const Color(0xFF3498DB) : Colors.white,
// // //           borderRadius: BorderRadius.circular(20),
// // //           border: Border.all(
// // //             color: selected ? const Color(0xFF3498DB) : const Color(0xFFDEE2E6),
// // //           ),
// // //         ),
// // //         child: Text(
// // //           label,
// // //           style: TextStyle(
// // //             color: selected ? Colors.white : Colors.black,
// // //             fontSize: 12,
// // //             fontWeight: FontWeight.w500,
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // قائمة الشركات
// // //   Widget _buildCompanyList() {
// // //     if (_showFinishedAccounts) {
// // //       return _buildFinishedAccountsList();
// // //     }

// // //     if (_isLoading) {
// // //       return const Expanded(child: Center(child: CircularProgressIndicator()));
// // //     }

// // //     if (_filteredSummaries.isEmpty) {
// // //       return Expanded(
// // //         child: Center(
// // //           child: Column(
// // //             mainAxisAlignment: MainAxisAlignment.center,
// // //             children: [
// // //               Icon(Icons.business, size: 50, color: Colors.grey[400]),
// // //               const SizedBox(height: 12),
// // //               Text(
// // //                 _companySummaries.isEmpty
// // //                     ? 'لا توجد شركات مسجلة'
// // //                     : 'لا توجد حسابات في هذه الفئة',
// // //                 style: TextStyle(color: Colors.grey[600], fontSize: 14),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       );
// // //     }

// // //     return Expanded(
// // //       child: ListView.builder(
// // //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // //         itemCount: _filteredSummaries.length,
// // //         itemBuilder: (context, index) {
// // //           return _buildCompanyItem(_filteredSummaries[index]);
// // //         },
// // //       ),
// // //     );
// // //   }

// // //   // قائمة الحسابات المنتهية
// // //   Widget _buildFinishedAccountsList() {
// // //     if (_isLoadingFinished) {
// // //       return const Expanded(child: Center(child: CircularProgressIndicator()));
// // //     }

// // //     if (_finishedAccounts.isEmpty) {
// // //       return Expanded(
// // //         child: Center(
// // //           child: Column(
// // //             mainAxisAlignment: MainAxisAlignment.center,
// // //             children: [
// // //               Icon(Icons.history, size: 50, color: Colors.grey[400]),
// // //               const SizedBox(height: 12),
// // //               Text(
// // //                 'لا توجد حسابات منتهية',
// // //                 style: TextStyle(color: Colors.grey[600], fontSize: 14),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       );
// // //     }

// // //     // حساب إجمالي الحسابات المنتهية
// // //     final totalAmount = _finishedAccounts.fold(
// // //       0.0,
// // //       (sum, account) => sum + (account['totalReceived'] as double),
// // //     );

// // //     return Expanded(
// // //       child: Column(
// // //         children: [
// // //           Container(
// // //             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // //             padding: const EdgeInsets.all(12),
// // //             decoration: BoxDecoration(
// // //               color: const Color(0xFF2C3E50),
// // //               borderRadius: BorderRadius.circular(8),
// // //             ),
// // //             child: Row(
// // //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //               children: [
// // //                 Text(
// // //                   'إجمالي المسدد:',
// // //                   style: const TextStyle(
// // //                     color: Colors.white,
// // //                     fontSize: 14,
// // //                     fontWeight: FontWeight.bold,
// // //                   ),
// // //                 ),
// // //                 Text(
// // //                   '${totalAmount.toStringAsFixed(2)} ج',
// // //                   style: const TextStyle(
// // //                     color: Colors.white,
// // //                     fontSize: 16,
// // //                     fontWeight: FontWeight.bold,
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //           Expanded(
// // //             child: ListView.builder(
// // //               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // //               itemCount: _finishedAccounts.length,
// // //               itemBuilder: (context, index) {
// // //                 return _buildFinishedAccountItem(_finishedAccounts[index]);
// // //               },
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // عنصر الشركة
// // //   Widget _buildCompanyItem(Map<String, dynamic> summary) {
// // //     final companyName = summary['companyName'];
// // //     final remainingAmount = summary['totalRemainingAmount'] as double;
// // //     final totalPaid = summary['totalPaidAmount'] as double;
// // //     final status = summary['status'];
// // //     final isCompleted = status == 'منتهية';

// // //     return Container(
// // //       margin: const EdgeInsets.only(bottom: 8),
// // //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// // //       decoration: BoxDecoration(
// // //         color: Colors.white,
// // //         borderRadius: BorderRadius.circular(8),
// // //         border: Border.all(
// // //           color: isCompleted
// // //               ? Colors.green.withOpacity(0.3)
// // //               : const Color(0xFF3498DB).withOpacity(0.3),
// // //         ),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: Colors.black.withOpacity(0.03),
// // //             blurRadius: 3,
// // //             offset: const Offset(0, 1),
// // //           ),
// // //         ],
// // //       ),
// // //       child: Row(
// // //         children: [
// // //           Expanded(
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 Text(
// // //                   companyName,
// // //                   style: const TextStyle(
// // //                     fontWeight: FontWeight.bold,
// // //                     fontSize: 14,
// // //                     color: Color(0xFF2C3E50),
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 2),
// // //                 Row(
// // //                   children: [
// // //                     Container(
// // //                       padding: const EdgeInsets.symmetric(
// // //                         horizontal: 6,
// // //                         vertical: 2,
// // //                       ),
// // //                       decoration: BoxDecoration(
// // //                         color: _getStatusColor(status).withOpacity(0.1),
// // //                         borderRadius: BorderRadius.circular(4),
// // //                       ),
// // //                       child: Text(
// // //                         status,
// // //                         style: TextStyle(
// // //                           color: _getStatusColor(status),
// // //                           fontSize: 10,
// // //                           fontWeight: FontWeight.bold,
// // //                         ),
// // //                       ),
// // //                     ),
// // //                     const SizedBox(width: 8),
// // //                     Text(
// // //                       '${summary['totalTrips']} رحلة',
// // //                       style: TextStyle(fontSize: 10, color: Colors.grey[600]),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //           Column(
// // //             crossAxisAlignment: CrossAxisAlignment.end,
// // //             children: [
// // //               Text(
// // //                 !isCompleted && remainingAmount > 0
// // //                     ? '${remainingAmount.toStringAsFixed(2)} ج'
// // //                     : '${totalPaid.toStringAsFixed(2)} ج',
// // //                 style: TextStyle(
// // //                   fontSize: 14,
// // //                   fontWeight: FontWeight.bold,
// // //                   color: isCompleted ? Colors.green : Colors.red,
// // //                 ),
// // //               ),
// // //               Text(
// // //                 !isCompleted && remainingAmount > 0 ? 'مستحق' : 'مسدد',
// // //                 style: TextStyle(fontSize: 10, color: Colors.grey[600]),
// // //               ),
// // //             ],
// // //           ),
// // //           const SizedBox(width: 12),
// // //           if (!isCompleted && remainingAmount > 0)
// // //             SizedBox(
// // //               height: 32,
// // //               child: ElevatedButton(
// // //                 onPressed: () => _receivePayment(summary),
// // //                 style: ElevatedButton.styleFrom(
// // //                   backgroundColor: const Color(0xFF27AE60),
// // //                   foregroundColor: Colors.white,
// // //                   padding: const EdgeInsets.symmetric(horizontal: 12),
// // //                   shape: RoundedRectangleBorder(
// // //                     borderRadius: BorderRadius.circular(6),
// // //                   ),
// // //                   elevation: 0,
// // //                 ),
// // //                 child: const Text('استلام', style: TextStyle(fontSize: 12)),
// // //               ),
// // //             )
// // //           else if (!isCompleted)
// // //             SizedBox(
// // //               height: 32,
// // //               child: ElevatedButton(
// // //                 onPressed: () => _showCompanyDetails(summary),
// // //                 style: ElevatedButton.styleFrom(
// // //                   backgroundColor: const Color(0xFF3498DB),
// // //                   foregroundColor: Colors.white,
// // //                   padding: const EdgeInsets.symmetric(horizontal: 12),
// // //                   shape: RoundedRectangleBorder(
// // //                     borderRadius: BorderRadius.circular(6),
// // //                   ),
// // //                   elevation: 0,
// // //                 ),
// // //                 child: const Text('تفاصيل', style: TextStyle(fontSize: 12)),
// // //               ),
// // //             )
// // //           else
// // //             Container(
// // //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// // //               decoration: BoxDecoration(
// // //                 color: Colors.grey[100],
// // //                 borderRadius: BorderRadius.circular(6),
// // //               ),
// // //               child: Text(
// // //                 'منتهي',
// // //                 style: TextStyle(fontSize: 12, color: Colors.grey[600]),
// // //               ),
// // //             ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // عنصر الحساب المنتهي
// // //   Widget _buildFinishedAccountItem(Map<String, dynamic> account) {
// // //     final companyName = account['companyName'];
// // //     final totalReceived = account['totalReceived'] as double;
// // //     final dateFormatted = account['dateFormatted'] as String;

// // //     return Container(
// // //       margin: const EdgeInsets.only(bottom: 8),
// // //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// // //       decoration: BoxDecoration(
// // //         color: Colors.white,
// // //         borderRadius: BorderRadius.circular(8),
// // //         border: Border.all(color: Colors.green.withOpacity(0.3)),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: Colors.black.withOpacity(0.03),
// // //             blurRadius: 3,
// // //             offset: const Offset(0, 1),
// // //           ),
// // //         ],
// // //       ),
// // //       child: Row(
// // //         children: [
// // //           Expanded(
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 Text(
// // //                   companyName,
// // //                   style: const TextStyle(
// // //                     fontWeight: FontWeight.bold,
// // //                     fontSize: 14,
// // //                     color: Color(0xFF2C3E50),
// // //                   ),
// // //                 ),
// // //                 const SizedBox(height: 2),
// // //                 Text(
// // //                   dateFormatted,
// // //                   style: TextStyle(fontSize: 10, color: Colors.grey[600]),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //           Column(
// // //             crossAxisAlignment: CrossAxisAlignment.end,
// // //             children: [
// // //               Text(
// // //                 '${totalReceived.toStringAsFixed(2)} ج',
// // //                 style: const TextStyle(
// // //                   fontSize: 14,
// // //                   fontWeight: FontWeight.bold,
// // //                   color: Colors.green,
// // //                 ),
// // //               ),
// // //               Text(
// // //                 'إجمالي المسدد',
// // //                 style: TextStyle(fontSize: 10, color: Colors.grey[600]),
// // //               ),
// // //             ],
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }

// // //   // شريط البحث
// // //   Widget _buildSearchBar() {
// // //     return Container(
// // //       padding: const EdgeInsets.all(12),
// // //       color: Colors.white,
// // //       child: Container(
// // //         height: 40,
// // //         padding: const EdgeInsets.symmetric(horizontal: 12),
// // //         decoration: BoxDecoration(
// // //           color: const Color(0xFFF1F3F5),
// // //           borderRadius: BorderRadius.circular(8),
// // //           border: Border.all(color: const Color(0xFFDEE2E6)),
// // //         ),
// // //         child: Row(
// // //           children: [
// // //             Icon(Icons.search, color: Colors.grey[600], size: 18),
// // //             const SizedBox(width: 8),
// // //             Expanded(
// // //               child: TextField(
// // //                 onChanged: (value) {
// // //                   setState(() {
// // //                     _searchQuery = value;
// // //                     if (!_showFinishedAccounts) {
// // //                       _filteredSummaries = _applyFilters(_companySummaries);
// // //                     }
// // //                   });
// // //                 },
// // //                 decoration: const InputDecoration(
// // //                   hintText: 'ابحث عن شركة...',
// // //                   border: InputBorder.none,
// // //                   hintStyle: TextStyle(fontSize: 14),
// // //                 ),
// // //                 style: const TextStyle(fontSize: 14),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // AppBar مخصص
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
// // //         bottom: false,
// // //         child: Row(
// // //           children: [
// // //             Icon(
// // //               _showFinishedAccounts ? Icons.history : Icons.business,
// // //               color: Colors.white,
// // //               size: 28,
// // //             ),
// // //             const SizedBox(width: 12),
// // //             Expanded(
// // //               child: Text(
// // //                 _showFinishedAccounts ? 'الحسابات المنتهية' : 'حسابات الشركات',
// // //                 style: const TextStyle(
// // //                   color: Colors.white,
// // //                   fontSize: 20,
// // //                   fontWeight: FontWeight.bold,
// // //                 ),
// // //               ),
// // //             ),
// // //             IconButton(
// // //               onPressed: _showFinishedAccounts
// // //                   ? _loadFinishedAccounts
// // //                   : _loadCompanySummaries,
// // //               icon: const Icon(Icons.refresh, size: 20, color: Colors.white),
// // //               tooltip: 'تحديث',
// // //             ),
// // //             IconButton(
// // //               onPressed: () {
// // //                 setState(() {
// // //                   _showFinishedAccounts = !_showFinishedAccounts;
// // //                 });
// // //               },
// // //               icon: Icon(
// // //                 _showFinishedAccounts ? Icons.business : Icons.history,
// // //                 size: 20,
// // //                 color: Colors.white,
// // //               ),
// // //               tooltip: _showFinishedAccounts
// // //                   ? 'العودة للحسابات'
// // //                   : 'عرض الحسابات المنتهية',
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }

// // //   // دوال مساعدة
// // //   Color _getStatusColor(String status) {
// // //     switch (status) {
// // //       case 'جارية':
// // //         return const Color(0xFFE74C3C);
// // //       case 'شبه منتهية':
// // //         return const Color(0xFFF39C12);
// // //       case 'منتهية':
// // //         return const Color(0xFF27AE60);
// // //       default:
// // //         return const Color(0xFF3498DB);
// // //     }
// // //   }

// // //   void _showError(String message) {
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Text(message),
// // //         backgroundColor: Colors.red,
// // //         duration: const Duration(seconds: 2),
// // //       ),
// // //     );
// // //   }

// // //   void _showSuccess(String message) {
// // //     ScaffoldMessenger.of(context).showSnackBar(
// // //       SnackBar(
// // //         content: Text(message),
// // //         backgroundColor: Colors.green,
// // //         duration: const Duration(seconds: 2),
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: const Color(0xFFF8F9FA),
// // //       body: Column(
// // //         children: [
// // //           _buildCustomAppBar(),
// // //           if (!_showFinishedAccounts) _buildTimeFilterSection(),
// // //           _buildSearchBar(),
// // //           if (!_showFinishedAccounts) _buildStatusRow(),
// // //           _buildFinishedFilter(),
// // //           _buildCompanyList(),
// // //         ],
// // //       ),
// // //       floatingActionButton: FloatingActionButton(
// // //         onPressed: _showFinishedAccounts
// // //             ? _loadFinishedAccounts
// // //             : _loadCompanySummaries,
// // //         backgroundColor: const Color(0xFF3498DB),
// // //         child: Icon(
// // //           _showFinishedAccounts ? Icons.history : Icons.business,
// // //           color: Colors.white,
// // //         ),
// // //         tooltip: 'تحديث البيانات',
// // //       ),
// // //     );
// // //   }
// // // }
// // import 'dart:async';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import 'package:flutter/widgets.dart' as flutter_widgets;

// // class CompaniesAccountsPage extends StatefulWidget {
// //   const CompaniesAccountsPage({super.key});

// //   @override
// //   State<CompaniesAccountsPage> createState() => _CompaniesAccountsPageState();
// // }

// // class _CompaniesAccountsPageState extends State<CompaniesAccountsPage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   List<Map<String, dynamic>> _companySummaries = [];
// //   List<Map<String, dynamic>> _filteredSummaries = [];
// //   List<Map<String, dynamic>> _finishedAccounts = [];
// //   bool _isLoading = false;
// //   bool _isLoadingFinished = false;
// //   bool _isRecalculating = false;
// //   String _searchQuery = '';
// //   String _statusFilter = 'جارية'; // الافتراضي: جارية

// //   // متغيرات الفلتر الزمني
// //   String _timeFilter = 'الكل';
// //   int _selectedMonth = DateTime.now().month;
// //   int _selectedYear = DateTime.now().year;
// //   DateTime? _selectedDate;
// //   bool _showFinishedAccounts = false;
// //   String _finishedFilter = 'الكل';

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadCompanySummaries();
// //     _loadFinishedAccounts();
// //     // التحقق من التزامن عند فتح الصفحة
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _checkDataSync();
// //     });
// //   }

// //   // ================================
// //   // تحميل إجماليات حسابات الشركات
// //   // ================================
// //   Future<void> _loadCompanySummaries() async {
// //     setState(() => _isLoading = true);

// //     try {
// //       // محاولة تحميل من collection منفصلة
// //       final snapshot = await _firestore.collection('companySummaries').get();

// //       if (snapshot.docs.isEmpty) {
// //         // إذا لم توجد بيانات، إنشاؤها من dailyWork
// //         await _recalculateAllCompanySummaries();
// //         return;
// //       }

// //       final summariesList = snapshot.docs.map((doc) {
// //         final data = doc.data();

// //         final totalCompanyDebt = (data['totalCompanyDebt'] ?? 0).toDouble();
// //         final totalPaidAmount = (data['totalPaidAmount'] ?? 0).toDouble();
// //         final totalRemainingAmount = totalCompanyDebt - totalPaidAmount;

// //         String status;
// //         if (totalRemainingAmount <= 0) {
// //           status = 'منتهية';
// //         } else if (totalPaidAmount > 0 && totalRemainingAmount > 0) {
// //           status = 'شبه منتهية';
// //         } else {
// //           status = 'جارية';
// //         }

// //         return {
// //           'companyId': data['companyId'] ?? '',
// //           'companyName': data['companyName'] ?? 'غير معروف',
// //           'totalCompanyDebt': totalCompanyDebt,
// //           'totalPaidAmount': totalPaidAmount,
// //           'totalRemainingAmount': totalRemainingAmount,
// //           'status': status,
// //           'totalTrips': (data['totalTrips'] ?? 0).toInt(),
// //           'docId': doc.id,
// //           'lastUpdated': data['lastUpdated'],
// //         };
// //       }).toList();

// //       summariesList.sort(
// //         (a, b) =>
// //             b['totalRemainingAmount'].compareTo(a['totalRemainingAmount']),
// //       );

// //       setState(() {
// //         _companySummaries = summariesList;
// //         _filteredSummaries = _applyFilters(summariesList);
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() => _isLoading = false);
// //       _showError('خطأ في تحميل حسابات الشركات: $e');
// //     }
// //   }

// //   // ================================
// //   // التحقق من تزامن البيانات مع dailyWork
// //   // ================================
// //   Future<void> _checkDataSync() async {
// //     try {
// //       // جلب آخر تحديث للحسابات
// //       final lastSummary = await _firestore
// //           .collection('companySummaries')
// //           .orderBy('lastUpdated', descending: true)
// //           .limit(1)
// //           .get();

// //       // جلب آخر رحلة في dailyWork
// //       final lastDailyWork = await _firestore
// //           .collection('dailyWork')
// //           .orderBy('date', descending: true)
// //           .limit(1)
// //           .get();

// //       if (lastSummary.docs.isEmpty && lastDailyWork.docs.isNotEmpty) {
// //         // يوجد رحلات ولكن لا توجد حسابات
// //         await _recalculateAllCompanySummaries();
// //         return;
// //       }

// //       if (lastSummary.docs.isNotEmpty && lastDailyWork.docs.isNotEmpty) {
// //         final summaryUpdate =
// //             lastSummary.docs.first.data()['lastUpdated'] as Timestamp;
// //         final lastTripDate =
// //             lastDailyWork.docs.first.data()['date'] as Timestamp;

// //         // إذا كانت آخر رحلة بعد آخر تحديث للحسابات
// //         if (lastTripDate.toDate().isAfter(summaryUpdate.toDate())) {
// //           await _recalculateAllCompanySummaries();
// //         }
// //       }
// //     } catch (e) {
// //       debugPrint('خطأ في التحقق من التزامن: $e');
// //     }
// //   }

// //   // ================================
// //   // إعادة حساب جميع حسابات الشركات من dailyWork
// //   // ================================
// //   Future<void> _recalculateAllCompanySummaries() async {
// //     setState(() => _isRecalculating = true);

// //     try {
// //       // جلب جميع رحلات dailyWork
// //       final dailyWorkSnapshot = await _firestore.collection('dailyWork').get();

// //       if (dailyWorkSnapshot.docs.isEmpty) {
// //         setState(() => _isRecalculating = false);
// //         return;
// //       }

// //       // حساب ملخصات الشركات
// //       final companySummaries = await _calculateCompanySummariesFromDailyWork();

// //       // حفظ جميع الحسابات
// //       final batch = _firestore.batch();
// //       final summariesCollection = _firestore.collection('companySummaries');

// //       // حذف القديم
// //       final oldSummaries = await summariesCollection.get();
// //       for (final doc in oldSummaries.docs) {
// //         batch.delete(doc.reference);
// //       }

// //       // إضافة الجديد
// //       for (final entry in companySummaries.entries) {
// //         final summary = entry.value;
// //         final docRef = summariesCollection.doc(entry.key);

// //         batch.set(docRef, {
// //           'companyId': summary['companyId'],
// //           'companyName': summary['companyName'],
// //           'totalCompanyDebt': summary['totalCompanyDebt'],
// //           'totalPaidAmount': summary['totalPaidAmount'],
// //           'totalRemainingAmount': summary['totalRemainingAmount'],
// //           'status': summary['status'],
// //           'totalTrips': summary['totalTrips'],
// //           'lastUpdated': Timestamp.now(),
// //         });
// //       }

// //       await batch.commit();

// //       _showSuccess('تم إعادة حساب جميع حسابات الشركات');

// //       // إعادة تحميل البيانات
// //       await _loadCompanySummaries();
// //     } catch (e) {
// //       _showError('خطأ في إعادة حساب الحسابات: $e');
// //     } finally {
// //       setState(() => _isRecalculating = false);
// //     }
// //   }

// //   // ================================
// //   // حساب ملخصات الشركات من dailyWork
// //   // ================================
// //   Future<Map<String, Map<String, dynamic>>>
// //   _calculateCompanySummariesFromDailyWork() async {
// //     final snapshot = await _firestore.collection('dailyWork').get();
// //     Map<String, Map<String, dynamic>> companyTotals = {};

// //     for (final doc in snapshot.docs) {
// //       final data = doc.data();
// //       final companyId = data['companyId'] as String?;
// //       final companyName = data['companyName'] as String?;

// //       if (companyId != null && companyId.isNotEmpty && companyName != null) {
// //         final companyKey = companyId;

// //         if (!companyTotals.containsKey(companyKey)) {
// //           companyTotals[companyKey] = {
// //             'companyId': companyId,
// //             'companyName': companyName,
// //             'totalCompanyDebt': 0.0,
// //             'totalPaidAmount': 0.0,
// //             'totalTrips': 0,
// //           };
// //         }

// //         final total = companyTotals[companyKey]!;

// //         // حساب دين الشركة (نولون + مبيت + عطلة)
// //         final nolon = (data['nolon'] ?? data['noLon'] ?? 0).toDouble();
// //         final companyOvernight = (data['companyOvernight'] ?? 0).toDouble();
// //         final companyHoliday = (data['companyHoliday'] ?? 0).toDouble();

// //         total['totalCompanyDebt'] += nolon + companyOvernight + companyHoliday;
// //         total['totalTrips'] += 1;
// //       }
// //     }

// //     // حساب المدفوعات من السجلات السابقة
// //     for (var entry in companyTotals.entries) {
// //       final docRef = _firestore.collection('companySummaries').doc(entry.key);
// //       final existingDoc = await docRef.get();

// //       if (existingDoc.exists) {
// //         final existingData = existingDoc.data()!;
// //         entry.value['totalPaidAmount'] = existingData['totalPaidAmount'] ?? 0.0;
// //       } else {
// //         entry.value['totalPaidAmount'] = 0.0;
// //       }

// //       final totalRemaining =
// //           entry.value['totalCompanyDebt'] - entry.value['totalPaidAmount'];
// //       entry.value['totalRemainingAmount'] = totalRemaining;

// //       String status;
// //       if (totalRemaining <= 0) {
// //         status = 'منتهية';
// //       } else if (entry.value['totalPaidAmount'] > 0) {
// //         status = 'شبه منتهية';
// //       } else {
// //         status = 'جارية';
// //       }

// //       entry.value['status'] = status;
// //     }

// //     return companyTotals;
// //   }

// //   // ================================
// //   // تحديث حساب شركة معينة بعد إضافة رحلة
// //   // ================================
// //   Future<void> _updateCompanySummaryAfterTrip(
// //     String companyId,
// //     String companyName,
// //     double nolon,
// //     double overnight,
// //     double holiday,
// //   ) async {
// //     try {
// //       final docRef = _firestore.collection('companySummaries').doc(companyId);
// //       final doc = await docRef.get();

// //       if (doc.exists) {
// //         // تحديث البيانات الموجودة
// //         final data = doc.data()!;
// //         final currentDebt = (data['totalCompanyDebt'] ?? 0).toDouble();
// //         final currentPaid = (data['totalPaidAmount'] ?? 0).toDouble();
// //         final currentTrips = (data['totalTrips'] ?? 0).toInt();

// //         final newDebt = currentDebt + nolon + overnight + holiday;
// //         final newRemaining = newDebt - currentPaid;

// //         String status;
// //         if (newRemaining <= 0) {
// //           status = 'منتهية';
// //         } else if (currentPaid > 0) {
// //           status = 'شبه منتهية';
// //         } else {
// //           status = 'جارية';
// //         }

// //         await docRef.update({
// //           'totalCompanyDebt': newDebt,
// //           'totalRemainingAmount': newRemaining,
// //           'totalTrips': currentTrips + 1,
// //           'status': status,
// //           'lastUpdated': Timestamp.now(),
// //         });
// //       } else {
// //         // إنشاء سجل جديد
// //         final totalDebt = nolon + overnight + holiday;

// //         await docRef.set({
// //           'companyId': companyId,
// //           'companyName': companyName,
// //           'totalCompanyDebt': totalDebt,
// //           'totalPaidAmount': 0.0,
// //           'totalRemainingAmount': totalDebt,
// //           'totalTrips': 1,
// //           'status': 'جارية',
// //           'lastUpdated': Timestamp.now(),
// //         });
// //       }

// //       // تحديث القائمة المحلية
// //       await _loadCompanySummaries();
// //     } catch (e) {
// //       debugPrint('❌ خطأ في تحديث حساب الشركة: $e');
// //     }
// //   }

// //   // ================================
// //   // تحميل الحسابات المنتهية
// //   // ================================
// //   Future<void> _loadFinishedAccounts() async {
// //     setState(() => _isLoadingFinished = true);

// //     try {
// //       final snapshot = await _firestore
// //           .collection('finishedCompanyAccounts')
// //           .orderBy('lastUpdated', descending: true)
// //           .get();

// //       final finishedList = snapshot.docs.map((doc) {
// //         final data = doc.data();
// //         final timestamp = data['lastUpdated'] as Timestamp?;

// //         return {
// //           'companyName': data['companyName'] ?? 'غير معروف',
// //           'totalReceived': (data['totalReceived'] ?? 0).toDouble(),
// //           'lastUpdated': timestamp,
// //           'dateFormatted': timestamp != null
// //               ? DateFormat('yyyy-MM-dd HH:mm').format(timestamp.toDate())
// //               : 'غير معروف',
// //           'docId': doc.id,
// //         };
// //       }).toList();

// //       setState(() {
// //         _finishedAccounts = _applyFinishedFilters(finishedList);
// //         _isLoadingFinished = false;
// //       });
// //     } catch (e) {
// //       setState(() => _isLoadingFinished = false);
// //       debugPrint('خطأ في تحميل الحسابات المنتهية: $e');
// //     }
// //   }

// //   // ================================
// //   // فلترة الحسابات المنتهية
// //   // ================================
// //   List<Map<String, dynamic>> _applyFinishedFilters(
// //     List<Map<String, dynamic>> accounts,
// //   ) {
// //     final now = DateTime.now();
// //     final today = DateTime(now.year, now.month, now.day);
// //     final firstDayOfMonth = DateTime(now.year, now.month, 1);
// //     final firstDayOfYear = DateTime(now.year, 1, 1);

// //     return accounts.where((account) {
// //       final timestamp = account['lastUpdated'] as Timestamp?;
// //       if (timestamp == null) return false;

// //       final date = timestamp.toDate();

// //       if (_finishedFilter == 'اليوم') {
// //         final accountDate = DateTime(date.year, date.month, date.day);
// //         return accountDate == today;
// //       } else if (_finishedFilter == 'الشهر') {
// //         return date.isAfter(firstDayOfMonth) ||
// //             date.isAtSameMomentAs(firstDayOfMonth);
// //       } else if (_finishedFilter == 'سنة') {
// //         return date.isAfter(firstDayOfYear) ||
// //             date.isAtSameMomentAs(firstDayOfYear);
// //       }

// //       return true; // 'الكل'
// //     }).toList();
// //   }

// //   // ================================
// //   // تطبيق الفلاتر على حسابات الشركات
// //   // ================================
// //   List<Map<String, dynamic>> _applyFilters(
// //     List<Map<String, dynamic>> summaries,
// //   ) {
// //     return summaries.where((summary) {
// //       if (_searchQuery.isNotEmpty) {
// //         if (!summary['companyName'].toLowerCase().contains(
// //           _searchQuery.toLowerCase(),
// //         )) {
// //           return false;
// //         }
// //       }

// //       // تطبيق الفلتر الزمني
// //       if (_timeFilter != 'الكل') {
// //         final timestamp = summary['lastUpdated'] as Timestamp?;
// //         if (timestamp == null) return false;

// //         final now = DateTime.now();
// //         final summaryDate = timestamp.toDate();

// //         switch (_timeFilter) {
// //           case 'اليوم':
// //             if (summaryDate.year != now.year ||
// //                 summaryDate.month != now.month ||
// //                 summaryDate.day != now.day) {
// //               return false;
// //             }
// //             break;
// //           case 'هذا الشهر':
// //             if (summaryDate.year != now.year ||
// //                 summaryDate.month != now.month) {
// //               return false;
// //             }
// //             break;
// //           case 'هذه السنة':
// //             if (summaryDate.year != now.year) {
// //               return false;
// //             }
// //             break;
// //           case 'مخصص':
// //             if (_selectedDate != null) {
// //               final selected = _selectedDate!;
// //               if (summaryDate.year != selected.year ||
// //                   summaryDate.month != selected.month ||
// //                   summaryDate.day != selected.day) {
// //                 return false;
// //               }
// //             }
// //             break;
// //         }
// //       }

// //       if (_statusFilter == 'جارية') {
// //         return summary['status'] == 'جارية';
// //       } else if (_statusFilter == 'شبه منتهية') {
// //         return summary['status'] == 'شبه منتهية';
// //       } else if (_statusFilter == 'منتهية') {
// //         return summary['status'] == 'منتهية';
// //       }

// //       return true;
// //     }).toList();
// //   }

// //   // ================================
// //   // تغيير فلتر الوقت
// //   // ================================
// //   void _changeTimeFilter(String filter) {
// //     setState(() {
// //       _timeFilter = filter;
// //       _filteredSummaries = _applyFilters(_companySummaries);
// //     });
// //   }

// //   void _applyMonthYearFilter() {
// //     setState(() {
// //       _timeFilter = 'مخصص';
// //       _filteredSummaries = _applyFilters(_companySummaries);
// //     });
// //   }

// //   // ================================
// //   // اختيار تاريخ محدد
// //   // ================================
// //   Future<void> _selectDate() async {
// //     final selected = await showDatePicker(
// //       context: context,
// //       initialDate: DateTime.now(),
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime.now(),
// //       builder: (context, child) {
// //         return Directionality(
// //           textDirection: flutter_widgets.TextDirection.rtl,
// //           child: child!,
// //         );
// //       },
// //     );

// //     if (selected != null) {
// //       setState(() {
// //         _selectedDate = selected;
// //         _timeFilter = 'مخصص';
// //         _filteredSummaries = _applyFilters(_companySummaries);
// //       });
// //     }
// //   }

// //   // ================================
// //   // استقبال دفعة من شركة
// //   // ================================
// //   Future<void> _receivePayment(Map<String, dynamic> summary) async {
// //     final amountController = TextEditingController();
// //     final companyName = summary['companyName'];
// //     final remainingAmount = summary['totalRemainingAmount'] as double;

// //     if (remainingAmount <= 0) {
// //       _showError('الحساب منتهي بالفعل');
// //       return;
// //     }

// //     await showDialog(
// //       context: context,
// //       builder: (context) => Directionality(
// //         textDirection: flutter_widgets.TextDirection.rtl,
// //         child: Dialog(
// //           backgroundColor: Colors.white,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //           child: Container(
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Text(
// //                       'استلام دفعة: $companyName',
// //                       style: const TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                         color: Color(0xFF2C3E50),
// //                       ),
// //                     ),
// //                     IconButton(
// //                       icon: const Icon(Icons.close, size: 18),
// //                       onPressed: () => Navigator.pop(context),
// //                       padding: EdgeInsets.zero,
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 8),
// //                 const Divider(height: 1),
// //                 const SizedBox(height: 12),
// //                 Text(
// //                   'المستحق: ${remainingAmount.toStringAsFixed(2)} ج',
// //                   style: const TextStyle(
// //                     fontSize: 14,
// //                     color: Colors.red,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),
// //                 TextFormField(
// //                   controller: amountController,
// //                   keyboardType: TextInputType.number,
// //                   decoration: InputDecoration(
// //                     labelText: 'المبلغ المستلم',
// //                     border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     contentPadding: const EdgeInsets.symmetric(
// //                       horizontal: 12,
// //                       vertical: 10,
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 20),
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: OutlinedButton(
// //                         onPressed: () => Navigator.pop(context),
// //                         style: OutlinedButton.styleFrom(
// //                           padding: const EdgeInsets.symmetric(vertical: 10),
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(8),
// //                           ),
// //                         ),
// //                         child: const Text(
// //                           'إلغاء',
// //                           style: TextStyle(fontSize: 14),
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 8),
// //                     Expanded(
// //                       child: ElevatedButton(
// //                         onPressed: () async {
// //                           final paymentAmount =
// //                               double.tryParse(amountController.text) ?? 0.0;

// //                           if (paymentAmount <= 0) {
// //                             _showError('أدخل مبلغ صحيح');
// //                             return;
// //                           }

// //                           if (paymentAmount > remainingAmount) {
// //                             _showError('المبلغ أكبر من المستحق');
// //                             return;
// //                           }

// //                           await _updatePayment(summary, paymentAmount);
// //                           Navigator.pop(context);
// //                         },
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: const Color(0xFF27AE60),
// //                           foregroundColor: Colors.white,
// //                           padding: const EdgeInsets.symmetric(vertical: 10),
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(8),
// //                           ),
// //                         ),
// //                         child: const Text(
// //                           'تسجيل الدفعة',
// //                           style: TextStyle(fontSize: 14),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ================================
// //   // تحديث الدفعة في قاعدة البيانات
// //   // ================================
// //   Future<void> _updatePayment(
// //     Map<String, dynamic> summary,
// //     double paymentAmount,
// //   ) async {
// //     try {
// //       final docRef = _firestore
// //           .collection('companySummaries')
// //           .doc(summary['companyId']);
// //       final doc = await docRef.get();

// //       if (!doc.exists) return;

// //       final data = doc.data()!;
// //       final currentPaidAmount = (data['totalPaidAmount'] ?? 0).toDouble();
// //       final totalCompanyDebt = (data['totalCompanyDebt'] ?? 0).toDouble();
// //       final newPaidAmount = currentPaidAmount + paymentAmount;
// //       final totalRemainingAmount = totalCompanyDebt - newPaidAmount;

// //       String status;
// //       if (totalRemainingAmount <= 0) {
// //         status = 'منتهية';
// //       } else if (newPaidAmount > 0 && totalRemainingAmount > 0) {
// //         status = 'شبه منتهية';
// //       } else {
// //         status = 'جارية';
// //       }

// //       await docRef.update({
// //         'totalPaidAmount': newPaidAmount,
// //         'totalRemainingAmount': totalRemainingAmount,
// //         'status': status,
// //         'lastUpdated': Timestamp.now(),
// //       });

// //       // إذا أصبح الحساب منتهياً، إضافته للحسابات المنتهية
// //       if (totalRemainingAmount <= 0) {
// //         final finishedRef = _firestore
// //             .collection('finishedCompanyAccounts')
// //             .doc(summary['companyId']);
// //         final finishedDoc = await finishedRef.get();

// //         if (finishedDoc.exists) {
// //           final existingData = finishedDoc.data()!;
// //           final previousTotal = (existingData['totalReceived'] ?? 0).toDouble();
// //           await finishedRef.update({
// //             'totalReceived': previousTotal + newPaidAmount,
// //             'lastUpdated': Timestamp.now(),
// //           });
// //         } else {
// //           await finishedRef.set({
// //             'companyId': summary['companyId'],
// //             'companyName': summary['companyName'],
// //             'totalReceived': newPaidAmount,
// //             'lastUpdated': Timestamp.now(),
// //           });
// //         }

// //         await _loadFinishedAccounts();
// //       }

// //       _showSuccess('تم تسجيل الدفعة بنجاح');
// //       _loadCompanySummaries();
// //     } catch (e) {
// //       _showError('خطأ في تسجيل الدفعة: $e');
// //     }
// //   }

// //   // ================================
// //   // عرض تفاصيل الشركة
// //   // ================================
// //   void _showCompanyDetails(Map<String, dynamic> summary) {
// //     showDialog(
// //       context: context,
// //       builder: (context) => Directionality(
// //         textDirection: flutter_widgets.TextDirection.rtl,
// //         child: Dialog(
// //           backgroundColor: Colors.white,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //           child: Container(
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Text(
// //                       'تفاصيل حساب: ${summary['companyName']}',
// //                       style: const TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                         color: Color(0xFF2C3E50),
// //                       ),
// //                     ),
// //                     IconButton(
// //                       icon: const Icon(Icons.close, size: 18),
// //                       onPressed: () => Navigator.pop(context),
// //                       padding: EdgeInsets.zero,
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 8),
// //                 const Divider(height: 1),
// //                 const SizedBox(height: 12),

// //                 // معلومات الحساب
// //                 _buildDetailItem(
// //                   'إجمالي الدين',
// //                   '${summary['totalCompanyDebt'].toStringAsFixed(2)} ج',
// //                   Colors.red,
// //                 ),
// //                 _buildDetailItem(
// //                   'المبلغ المدفوع',
// //                   '${summary['totalPaidAmount'].toStringAsFixed(2)} ج',
// //                   Colors.green,
// //                 ),
// //                 _buildDetailItem(
// //                   'المبلغ المتبقي',
// //                   '${summary['totalRemainingAmount'].toStringAsFixed(2)} ج',
// //                   summary['totalRemainingAmount'] > 0
// //                       ? Colors.orange
// //                       : Colors.blue,
// //                 ),

// //                 const SizedBox(height: 8),
// //                 const Divider(),
// //                 const SizedBox(height: 8),

// //                 _buildDetailItem('عدد الرحلات', '${summary['totalTrips']}'),
// //                 _buildDetailItem(
// //                   'الحالة',
// //                   summary['status'],
// //                   _getStatusColor(summary['status']),
// //                 ),

// //                 const SizedBox(height: 20),
// //                 SizedBox(
// //                   width: double.infinity,
// //                   child: ElevatedButton(
// //                     onPressed: () => Navigator.pop(context),
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: const Color(0xFF3498DB),
// //                       foregroundColor: Colors.white,
// //                       padding: const EdgeInsets.symmetric(vertical: 10),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                     ),
// //                     child: const Text('إغلاق'),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ================================
// //   // بناء عنصر التفاصيل
// //   // ================================
// //   Widget _buildDetailItem(String label, String value, [Color? color]) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 6),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           Text(
// //             label,
// //             style: const TextStyle(fontSize: 14, color: Color(0xFF2C3E50)),
// //           ),
// //           Text(
// //             value,
// //             style: TextStyle(
// //               fontSize: 14,
// //               fontWeight: FontWeight.bold,
// //               color: color ?? const Color(0xFF3498DB),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ================================
// //   // المربعات الثلاثة العلوية (الحالات)
// //   // ================================
// //   Widget _buildStatusRow() {
// //     if (_showFinishedAccounts) return const SizedBox();

// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           _buildStatusBox('جارية', const Color(0xFFE74C3C), Icons.access_time),
// //           _buildStatusBox(
// //             'شبه منتهية',
// //             const Color(0xFFF39C12),
// //             Icons.hourglass_bottom,
// //           ),
// //           _buildStatusBox(
// //             'منتهية',
// //             const Color(0xFF27AE60),
// //             Icons.check_circle,
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildStatusBox(String status, Color color, IconData icon) {
// //     final count = _companySummaries.where((s) => s['status'] == status).length;
// //     final isSelected = _statusFilter == status;

// //     return GestureDetector(
// //       onTap: () {
// //         setState(() {
// //           _statusFilter = status;
// //           _filteredSummaries = _applyFilters(_companySummaries);
// //         });
// //       },
// //       child: Container(
// //         width: 100,
// //         padding: const EdgeInsets.symmetric(vertical: 10),
// //         decoration: BoxDecoration(
// //           color: isSelected ? color : color.withOpacity(0.1),
// //           borderRadius: BorderRadius.circular(10),
// //           border: Border.all(
// //             color: isSelected ? color : color.withOpacity(0.3),
// //             width: 1.5,
// //           ),
// //         ),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(icon, color: isSelected ? Colors.white : color, size: 22),
// //             const SizedBox(height: 4),
// //             Text(
// //               status,
// //               style: TextStyle(
// //                 color: isSelected ? Colors.white : color,
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 12,
// //               ),
// //             ),
// //             const SizedBox(height: 4),
// //             Text(
// //               '$count',
// //               style: TextStyle(
// //                 color: isSelected ? Colors.white : color,
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 14,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ================================
// //   // قسم الفلتر الزمني
// //   // ================================
// //   Widget _buildTimeFilterSection() {
// //     if (_showFinishedAccounts) return const SizedBox();

// //     return Container(
// //       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
// //       color: Colors.white,
// //       child: Column(
// //         children: [
// //           SingleChildScrollView(
// //             scrollDirection: Axis.horizontal,
// //             child: Row(
// //               children: ['الكل', 'اليوم', 'هذا الشهر', 'هذه السنة', 'مخصص']
// //                   .map(
// //                     (filter) => Padding(
// //                       padding: const EdgeInsets.symmetric(horizontal: 4),
// //                       child: ChoiceChip(
// //                         label: Text(filter),
// //                         selected: _timeFilter == filter,
// //                         onSelected: (selected) {
// //                           if (selected) _changeTimeFilter(filter);
// //                         },
// //                         selectedColor: const Color(0xFF3498DB),
// //                         labelStyle: TextStyle(
// //                           color: _timeFilter == filter
// //                               ? Colors.white
// //                               : const Color(0xFF2C3E50),
// //                         ),
// //                       ),
// //                     ),
// //                   )
// //                   .toList(),
// //             ),
// //           ),
// //           const SizedBox(height: 12),
// //           if (_timeFilter == 'مخصص')
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 const Icon(Icons.calendar_month, color: Color(0xFF3498DB)),
// //                 const SizedBox(width: 8),
// //                 DropdownButton<int>(
// //                   value: _selectedMonth,
// //                   onChanged: (value) {
// //                     if (value != null) {
// //                       setState(() => _selectedMonth = value);
// //                       _applyMonthYearFilter();
// //                     }
// //                   },
// //                   items: List.generate(12, (index) {
// //                     final monthNumber = index + 1;
// //                     return DropdownMenuItem(
// //                       value: monthNumber,
// //                       child: Text('شهر $monthNumber'),
// //                     );
// //                   }),
// //                 ),
// //                 const SizedBox(width: 20),
// //                 DropdownButton<int>(
// //                   value: _selectedYear,
// //                   onChanged: (value) {
// //                     if (value != null) {
// //                       setState(() => _selectedYear = value);
// //                       _applyMonthYearFilter();
// //                     }
// //                   },
// //                   items: [
// //                     for (
// //                       int i = DateTime.now().year - 2;
// //                       i <= DateTime.now().year + 2;
// //                       i++
// //                     )
// //                       DropdownMenuItem(value: i, child: Text('$i')),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           if (_timeFilter == 'مخصص') const SizedBox(height: 12),
// //           if (_timeFilter == 'مخصص')
// //             Row(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 ElevatedButton.icon(
// //                   onPressed: _selectDate,
// //                   icon: const Icon(Icons.calendar_today, size: 16),
// //                   label: Text(
// //                     _selectedDate != null
// //                         ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
// //                         : 'اختر تاريخ محدد',
// //                     style: const TextStyle(fontSize: 12),
// //                   ),
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: const Color(0xFF2C3E50),
// //                     foregroundColor: Colors.white,
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 16,
// //                       vertical: 8,
// //                     ),
// //                   ),
// //                 ),
// //                 if (_selectedDate != null)
// //                   IconButton(
// //                     onPressed: () {
// //                       setState(() {
// //                         _selectedDate = null;
// //                         _filteredSummaries = _applyFilters(_companySummaries);
// //                       });
// //                     },
// //                     icon: const Icon(Icons.clear, color: Colors.red),
// //                   ),
// //               ],
// //             ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ================================
// //   // فلتر الحسابات المنتهية
// //   // ================================
// //   Widget _buildFinishedFilter() {
// //     if (!_showFinishedAccounts) return const SizedBox();

// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //       child: Wrap(
// //         spacing: 8,
// //         runSpacing: 8,
// //         children: [
// //           _buildFilterChip('الكل', _finishedFilter == 'الكل', () {
// //             setState(() {
// //               _finishedFilter = 'الكل';
// //               _finishedAccounts = _applyFinishedFilters(_finishedAccounts);
// //             });
// //           }),
// //           _buildFilterChip('اليوم', _finishedFilter == 'اليوم', () {
// //             setState(() {
// //               _finishedFilter = 'اليوم';
// //               _finishedAccounts = _applyFinishedFilters(_finishedAccounts);
// //             });
// //           }),
// //           _buildFilterChip('الشهر', _finishedFilter == 'الشهر', () {
// //             setState(() {
// //               _finishedFilter = 'الشهر';
// //               _finishedAccounts = _applyFinishedFilters(_finishedAccounts);
// //             });
// //           }),
// //           _buildFilterChip('سنة', _finishedFilter == 'سنة', () {
// //             setState(() {
// //               _finishedFilter = 'سنة';
// //               _finishedAccounts = _applyFinishedFilters(_finishedAccounts);
// //             });
// //           }),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Container(
// //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //         decoration: BoxDecoration(
// //           color: selected ? const Color(0xFF3498DB) : Colors.white,
// //           borderRadius: BorderRadius.circular(20),
// //           border: Border.all(
// //             color: selected ? const Color(0xFF3498DB) : const Color(0xFFDEE2E6),
// //           ),
// //         ),
// //         child: Text(
// //           label,
// //           style: TextStyle(
// //             color: selected ? Colors.white : Colors.black,
// //             fontSize: 12,
// //             fontWeight: FontWeight.w500,
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ================================
// //   // قائمة الشركات الرئيسية
// //   // ================================
// //   Widget _buildCompanyList() {
// //     if (_isRecalculating) {
// //       return const Expanded(
// //         child: Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               CircularProgressIndicator(),
// //               SizedBox(height: 16),
// //               Text(
// //                 'جاري إعادة حساب جميع الحسابات...',
// //                 style: TextStyle(color: Color(0xFF3498DB)),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }

// //     if (_showFinishedAccounts) {
// //       return _buildFinishedAccountsList();
// //     }

// //     if (_isLoading) {
// //       return const Expanded(child: Center(child: CircularProgressIndicator()));
// //     }

// //     if (_filteredSummaries.isEmpty) {
// //       return Expanded(
// //         child: Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(Icons.business, size: 50, color: Colors.grey[400]),
// //               const SizedBox(height: 12),
// //               Text(
// //                 _companySummaries.isEmpty
// //                     ? 'لا توجد شركات مسجلة'
// //                     : 'لا توجد حسابات في هذه الفئة',
// //                 style: TextStyle(color: Colors.grey[600], fontSize: 14),
// //               ),
// //               const SizedBox(height: 16),
// //               if (_companySummaries.isEmpty)
// //                 ElevatedButton(
// //                   onPressed: _recalculateAllCompanySummaries,
// //                   child: const Text('إعادة حساب الحسابات'),
// //                 ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }

// //     return Expanded(
// //       child: ListView.builder(
// //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //         itemCount: _filteredSummaries.length,
// //         itemBuilder: (context, index) {
// //           return _buildCompanyItem(_filteredSummaries[index]);
// //         },
// //       ),
// //     );
// //   }

// //   // ================================
// //   // قائمة الحسابات المنتهية
// //   // ================================
// //   Widget _buildFinishedAccountsList() {
// //     if (_isLoadingFinished) {
// //       return const Expanded(child: Center(child: CircularProgressIndicator()));
// //     }

// //     if (_finishedAccounts.isEmpty) {
// //       return Expanded(
// //         child: Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(Icons.history, size: 50, color: Colors.grey[400]),
// //               const SizedBox(height: 12),
// //               Text(
// //                 'لا توجد حسابات منتهية',
// //                 style: TextStyle(color: Colors.grey[600], fontSize: 14),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }

// //     // حساب إجمالي الحسابات المنتهية
// //     final totalAmount = _finishedAccounts.fold(
// //       0.0,
// //       (sum, account) => sum + (account['totalReceived'] as double),
// //     );

// //     return Expanded(
// //       child: Column(
// //         children: [
// //           Container(
// //             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //             padding: const EdgeInsets.all(12),
// //             decoration: BoxDecoration(
// //               color: const Color(0xFF2C3E50),
// //               borderRadius: BorderRadius.circular(8),
// //             ),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //               children: [
// //                 Text(
// //                   'إجمالي المسدد:',
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 14,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //                 Text(
// //                   '${totalAmount.toStringAsFixed(2)} ج',
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           Expanded(
// //             child: ListView.builder(
// //               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //               itemCount: _finishedAccounts.length,
// //               itemBuilder: (context, index) {
// //                 return _buildFinishedAccountItem(_finishedAccounts[index]);
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ================================
// //   // عنصر الشركة (كارت)
// //   // ================================
// //   Widget _buildCompanyItem(Map<String, dynamic> summary) {
// //     final companyName = summary['companyName'];
// //     final remainingAmount = summary['totalRemainingAmount'] as double;
// //     final totalPaid = summary['totalPaidAmount'] as double;
// //     final status = summary['status'];
// //     final isCompleted = status == 'منتهية';

// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 8),
// //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(8),
// //         border: Border.all(
// //           color: isCompleted
// //               ? Colors.green.withOpacity(0.3)
// //               : const Color(0xFF3498DB).withOpacity(0.3),
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.03),
// //             blurRadius: 3,
// //             offset: const Offset(0, 1),
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   companyName,
// //                   style: const TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 14,
// //                     color: Color(0xFF2C3E50),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 2),
// //                 Row(
// //                   children: [
// //                     Container(
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 6,
// //                         vertical: 2,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: _getStatusColor(status).withOpacity(0.1),
// //                         borderRadius: BorderRadius.circular(4),
// //                       ),
// //                       child: Text(
// //                         status,
// //                         style: TextStyle(
// //                           color: _getStatusColor(status),
// //                           fontSize: 10,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 8),
// //                     Text(
// //                       '${summary['totalTrips']} رحلة',
// //                       style: TextStyle(fontSize: 10, color: Colors.grey[600]),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //           Column(
// //             crossAxisAlignment: CrossAxisAlignment.end,
// //             children: [
// //               Text(
// //                 !isCompleted && remainingAmount > 0
// //                     ? '${remainingAmount.toStringAsFixed(2)} ج'
// //                     : '${totalPaid.toStringAsFixed(2)} ج',
// //                 style: TextStyle(
// //                   fontSize: 14,
// //                   fontWeight: FontWeight.bold,
// //                   color: isCompleted ? Colors.green : Colors.red,
// //                 ),
// //               ),
// //               Text(
// //                 !isCompleted && remainingAmount > 0 ? 'مستحق' : 'مسدد',
// //                 style: TextStyle(fontSize: 10, color: Colors.grey[600]),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(width: 12),
// //           if (!isCompleted && remainingAmount > 0)
// //             SizedBox(
// //               height: 32,
// //               child: ElevatedButton(
// //                 onPressed: () => _receivePayment(summary),
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: const Color(0xFF27AE60),
// //                   foregroundColor: Colors.white,
// //                   padding: const EdgeInsets.symmetric(horizontal: 12),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(6),
// //                   ),
// //                   elevation: 0,
// //                 ),
// //                 child: const Text('استلام', style: TextStyle(fontSize: 12)),
// //               ),
// //             )
// //           else if (!isCompleted)
// //             SizedBox(
// //               height: 32,
// //               child: ElevatedButton(
// //                 onPressed: () => _showCompanyDetails(summary),
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: const Color(0xFF3498DB),
// //                   foregroundColor: Colors.white,
// //                   padding: const EdgeInsets.symmetric(horizontal: 12),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(6),
// //                   ),
// //                   elevation: 0,
// //                 ),
// //                 child: const Text('تفاصيل', style: TextStyle(fontSize: 12)),
// //               ),
// //             )
// //           else
// //             Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //               decoration: BoxDecoration(
// //                 color: Colors.grey[100],
// //                 borderRadius: BorderRadius.circular(6),
// //               ),
// //               child: Text(
// //                 'منتهي',
// //                 style: TextStyle(fontSize: 12, color: Colors.grey[600]),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ================================
// //   // عنصر الحساب المنتهي
// //   // ================================
// //   Widget _buildFinishedAccountItem(Map<String, dynamic> account) {
// //     final companyName = account['companyName'];
// //     final totalReceived = account['totalReceived'] as double;
// //     final dateFormatted = account['dateFormatted'] as String;

// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 8),
// //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(8),
// //         border: Border.all(color: Colors.green.withOpacity(0.3)),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.03),
// //             blurRadius: 3,
// //             offset: const Offset(0, 1),
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   companyName,
// //                   style: const TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 14,
// //                     color: Color(0xFF2C3E50),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 2),
// //                 Text(
// //                   dateFormatted,
// //                   style: TextStyle(fontSize: 10, color: Colors.grey[600]),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           Column(
// //             crossAxisAlignment: CrossAxisAlignment.end,
// //             children: [
// //               Text(
// //                 '${totalReceived.toStringAsFixed(2)} ج',
// //                 style: const TextStyle(
// //                   fontSize: 14,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.green,
// //                 ),
// //               ),
// //               Text(
// //                 'إجمالي المسدد',
// //                 style: TextStyle(fontSize: 10, color: Colors.grey[600]),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ================================
// //   // شريط البحث
// //   // ================================
// //   Widget _buildSearchBar() {
// //     return Container(
// //       padding: const EdgeInsets.all(12),
// //       color: Colors.white,
// //       child: Container(
// //         height: 40,
// //         padding: const EdgeInsets.symmetric(horizontal: 12),
// //         decoration: BoxDecoration(
// //           color: const Color(0xFFF1F3F5),
// //           borderRadius: BorderRadius.circular(8),
// //           border: Border.all(color: const Color(0xFFDEE2E6)),
// //         ),
// //         child: Row(
// //           children: [
// //             Icon(Icons.search, color: Colors.grey[600], size: 18),
// //             const SizedBox(width: 8),
// //             Expanded(
// //               child: TextField(
// //                 onChanged: (value) {
// //                   setState(() {
// //                     _searchQuery = value;
// //                     if (!_showFinishedAccounts) {
// //                       _filteredSummaries = _applyFilters(_companySummaries);
// //                     }
// //                   });
// //                 },
// //                 decoration: const InputDecoration(
// //                   hintText: 'ابحث عن شركة...',
// //                   border: InputBorder.none,
// //                   hintStyle: TextStyle(fontSize: 14),
// //                 ),
// //                 style: const TextStyle(fontSize: 14),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ================================
// //   // AppBar مخصص
// //   // ================================
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
// //         bottom: false,
// //         child: Row(
// //           children: [
// //             Icon(
// //               _showFinishedAccounts ? Icons.history : Icons.business,
// //               color: Colors.white,
// //               size: 28,
// //             ),
// //             const SizedBox(width: 12),
// //             Expanded(
// //               child: Text(
// //                 _showFinishedAccounts ? 'الحسابات المنتهية' : 'حسابات الشركات',
// //                 style: const TextStyle(
// //                   color: Colors.white,
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ),
// //             if (_isRecalculating)
// //               const Padding(
// //                 padding: EdgeInsets.only(right: 8),
// //                 child: SizedBox(
// //                   width: 16,
// //                   height: 16,
// //                   child: CircularProgressIndicator(
// //                     strokeWidth: 2,
// //                     color: Colors.white,
// //                   ),
// //                 ),
// //               ),
// //             IconButton(
// //               onPressed: _showFinishedAccounts
// //                   ? _loadFinishedAccounts
// //                   : _loadCompanySummaries,
// //               icon: const Icon(Icons.refresh, size: 20, color: Colors.white),
// //               tooltip: 'تحديث',
// //             ),
// //             IconButton(
// //               onPressed: () {
// //                 setState(() {
// //                   _showFinishedAccounts = !_showFinishedAccounts;
// //                 });
// //               },
// //               icon: Icon(
// //                 _showFinishedAccounts ? Icons.business : Icons.history,
// //                 size: 20,
// //                 color: Colors.white,
// //               ),
// //               tooltip: _showFinishedAccounts
// //                   ? 'العودة للحسابات'
// //                   : 'عرض الحسابات المنتهية',
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ================================
// //   // دوال مساعدة
// //   // ================================
// //   Color _getStatusColor(String status) {
// //     switch (status) {
// //       case 'جارية':
// //         return const Color(0xFFE74C3C);
// //       case 'شبه منتهية':
// //         return const Color(0xFFF39C12);
// //       case 'منتهية':
// //         return const Color(0xFF27AE60);
// //       default:
// //         return const Color(0xFF3498DB);
// //     }
// //   }

// //   void _showError(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         backgroundColor: Colors.red,
// //         duration: const Duration(seconds: 2),
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

// //   // ================================
// //   // بناء الواجهة الرئيسية
// //   // ================================
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8F9FA),
// //       body: Column(
// //         children: [
// //           _buildCustomAppBar(),
// //           if (!_showFinishedAccounts) _buildTimeFilterSection(),
// //           _buildSearchBar(),
// //           if (!_showFinishedAccounts) _buildStatusRow(),
// //           _buildFinishedFilter(),
// //           _buildCompanyList(),
// //         ],
// //       ),
// //       floatingActionButton: FloatingActionButton.extended(
// //         onPressed: () {
// //           if (_showFinishedAccounts) {
// //             _loadFinishedAccounts();
// //           } else {
// //             showDialog(
// //               context: context,
// //               builder: (context) => Directionality(
// //                 textDirection: flutter_widgets.TextDirection.rtl,
// //                 child: AlertDialog(
// //                   title: const Text('خيارات التحديث'),
// //                   content: const Text('اختر العملية التي تريد تنفيذها:'),
// //                   actions: [
// //                     TextButton(
// //                       onPressed: () => Navigator.pop(context),
// //                       child: const Text('إلغاء'),
// //                     ),
// //                     TextButton(
// //                       onPressed: () {
// //                         Navigator.pop(context);
// //                         _loadCompanySummaries();
// //                       },
// //                       child: const Text('تحديث القائمة'),
// //                     ),
// //                     ElevatedButton(
// //                       onPressed: () {
// //                         Navigator.pop(context);
// //                         _recalculateAllCompanySummaries();
// //                       },
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: const Color(0xFFE74C3C),
// //                       ),
// //                       child: const Text('إعادة حساب الكل'),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             );
// //           }
// //         },
// //         backgroundColor: _showFinishedAccounts
// //             ? const Color(0xFF2C3E50)
// //             : const Color(0xFF3498DB),
// //         icon: Icon(
// //           _showFinishedAccounts ? Icons.refresh : Icons.calculate,
// //           color: Colors.white,
// //         ),
// //         label: Text(
// //           _showFinishedAccounts ? 'تحديث' : 'إعادة حساب',
// //           style: const TextStyle(color: Colors.white),
// //         ),
// //         tooltip: 'تحديث البيانات',
// //       ),
// //     );
// //   }
// // // }
// // import 'dart:async';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import 'package:flutter/widgets.dart' as flutter_widgets;

// // class CompaniesAccountsPage extends StatefulWidget {
// //   const CompaniesAccountsPage({super.key});

// //   @override
// //   State<CompaniesAccountsPage> createState() => _CompaniesAccountsPageState();
// // }

// // class _CompaniesAccountsPageState extends State<CompaniesAccountsPage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   List<Map<String, dynamic>> _companySummaries = [];
// //   List<Map<String, dynamic>> _filteredSummaries = [];
// //   bool _isLoading = false;
// //   bool _isRecalculating = false;
// //   String _searchQuery = '';
// //   String _statusFilter = 'جارية'; // الافتراضي: جارية

// //   // فلتر زمني
// //   String _timeFilter = 'الكل';
// //   int _selectedMonth = DateTime.now().month;
// //   int _selectedYear = DateTime.now().year;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadCompanySummaries();
// //   }

// //   // ================================
// //   // تحميل حسابات الشركات
// //   // ================================
// //   Future<void> _loadCompanySummaries() async {
// //     setState(() => _isLoading = true);

// //     try {
// //       final snapshot = await _firestore.collection('companySummaries').get();

// //       if (snapshot.docs.isEmpty) {
// //         await _recalculateAllCompanySummaries();
// //         return;
// //       }

// //       final summariesList = snapshot.docs.map((doc) {
// //         final data = doc.data();

// //         final totalCompanyDebt = (data['totalCompanyDebt'] ?? 0).toDouble();
// //         final totalPaidAmount = (data['totalPaidAmount'] ?? 0).toDouble();
// //         final totalRemainingAmount = totalCompanyDebt - totalPaidAmount;

// //         String status;
// //         if (totalRemainingAmount <= 0) {
// //           status = 'منتهية';
// //         } else if (totalPaidAmount > 0 && totalRemainingAmount > 0) {
// //           status = 'شبه منتهية';
// //         } else {
// //           status = 'جارية';
// //         }

// //         return {
// //           'companyId': data['companyId'] ?? '',
// //           'companyName': data['companyName'] ?? 'غير معروف',
// //           'totalCompanyDebt': totalCompanyDebt,
// //           'totalPaidAmount': totalPaidAmount,
// //           'totalRemainingAmount': totalRemainingAmount,
// //           'status': status,
// //           'totalTrips': (data['totalTrips'] ?? 0).toInt(),
// //           'docId': doc.id,
// //           'lastUpdated': data['lastUpdated'],
// //         };
// //       }).toList();

// //       summariesList.sort(
// //         (a, b) =>
// //             b['totalRemainingAmount'].compareTo(a['totalRemainingAmount']),
// //       );

// //       setState(() {
// //         _companySummaries = summariesList;
// //         _filteredSummaries = _applyFilters(summariesList);
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() => _isLoading = false);
// //       _showError('خطأ في تحميل حسابات الشركات: $e');
// //     }
// //   }

// //   // ================================
// //   // إعادة حساب جميع حسابات الشركات
// //   // ================================
// //   Future<void> _recalculateAllCompanySummaries() async {
// //     setState(() => _isRecalculating = true);

// //     try {
// //       final snapshot = await _firestore.collection('dailyWork').get();

// //       if (snapshot.docs.isEmpty) {
// //         setState(() => _isRecalculating = false);
// //         _showError('لا توجد رحلات في قاعدة البيانات');
// //         return;
// //       }

// //       Map<String, Map<String, dynamic>> companyTotals = {};

// //       for (final doc in snapshot.docs) {
// //         final data = doc.data();
// //         final companyId = data['companyId'] as String?;
// //         final companyName = data['companyName'] as String?;

// //         if (companyId != null && companyId.isNotEmpty && companyName != null) {
// //           final companyKey = companyId;

// //           if (!companyTotals.containsKey(companyKey)) {
// //             companyTotals[companyKey] = {
// //               'companyId': companyId,
// //               'companyName': companyName,
// //               'totalCompanyDebt': 0.0,
// //               'totalPaidAmount': 0.0,
// //               'totalTrips': 0,
// //             };
// //           }

// //           final total = companyTotals[companyKey]!;

// //           final nolon = (data['nolon'] ?? data['noLon'] ?? 0).toDouble();
// //           final companyOvernight = (data['companyOvernight'] ?? 0).toDouble();
// //           final companyHoliday = (data['companyHoliday'] ?? 0).toDouble();

// //           total['totalCompanyDebt'] +=
// //               nolon + companyOvernight + companyHoliday;
// //           total['totalTrips'] += 1;
// //         }
// //       }

// //       final batch = _firestore.batch();
// //       final summariesCollection = _firestore.collection('companySummaries');

// //       for (var entry in companyTotals.entries) {
// //         final summary = entry.value;
// //         final docRef = summariesCollection.doc(entry.key);

// //         final existingDoc = await docRef.get();

// //         if (existingDoc.exists) {
// //           final existingData = existingDoc.data()!;
// //           summary['totalPaidAmount'] = existingData['totalPaidAmount'] ?? 0.0;
// //         } else {
// //           summary['totalPaidAmount'] = 0.0;
// //         }

// //         final totalRemaining =
// //             summary['totalCompanyDebt'] - summary['totalPaidAmount'];
// //         summary['totalRemainingAmount'] = totalRemaining;

// //         String status;
// //         if (totalRemaining <= 0) {
// //           status = 'منتهية';
// //         } else if (summary['totalPaidAmount'] > 0) {
// //           status = 'شبه منتهية';
// //         } else {
// //           status = 'جارية';
// //         }

// //         summary['status'] = status;

// //         batch.set(docRef, {...summary, 'lastUpdated': Timestamp.now()});
// //       }

// //       await batch.commit();
// //       _showSuccess('تم إعادة حساب جميع حسابات الشركات');
// //       await _loadCompanySummaries();
// //     } catch (e) {
// //       _showError('خطأ في إعادة حساب الحسابات: $e');
// //     } finally {
// //       setState(() => _isRecalculating = false);
// //     }
// //   }

// //   // ================================
// //   // فلترة البيانات
// //   // ================================
// //   List<Map<String, dynamic>> _applyFilters(
// //     List<Map<String, dynamic>> summaries,
// //   ) {
// //     return summaries.where((summary) {
// //       if (_searchQuery.isNotEmpty) {
// //         if (!summary['companyName'].toLowerCase().contains(
// //           _searchQuery.toLowerCase(),
// //         )) {
// //           return false;
// //         }
// //       }

// //       // تطبيق الفلتر الزمني
// //       if (_timeFilter != 'الكل') {
// //         final timestamp = summary['lastUpdated'] as Timestamp?;
// //         if (timestamp == null) return false;

// //         final now = DateTime.now();
// //         final summaryDate = timestamp.toDate();

// //         switch (_timeFilter) {
// //           case 'اليوم':
// //             if (summaryDate.year != now.year ||
// //                 summaryDate.month != now.month ||
// //                 summaryDate.day != now.day) {
// //               return false;
// //             }
// //             break;
// //           case 'هذا الشهر':
// //             if (summaryDate.year != now.year ||
// //                 summaryDate.month != now.month) {
// //               return false;
// //             }
// //             break;
// //           case 'هذه السنة':
// //             if (summaryDate.year != now.year) {
// //               return false;
// //             }
// //             break;
// //           case 'مخصص':
// //             if (summaryDate.year != _selectedYear ||
// //                 summaryDate.month != _selectedMonth) {
// //               return false;
// //             }
// //             break;
// //         }
// //       }

// //       if (_statusFilter == 'جارية') {
// //         return summary['status'] == 'جارية';
// //       } else if (_statusFilter == 'شبه منتهية') {
// //         return summary['status'] == 'شبه منتهية';
// //       } else if (_statusFilter == 'منتهية') {
// //         return summary['status'] == 'منتهية';
// //       }

// //       return true;
// //     }).toList();
// //   }

// //   void _changeTimeFilter(String filter) {
// //     setState(() {
// //       _timeFilter = filter;
// //       _filteredSummaries = _applyFilters(_companySummaries);
// //     });
// //   }

// //   void _applyMonthYearFilter() {
// //     setState(() {
// //       _timeFilter = 'مخصص';
// //       _filteredSummaries = _applyFilters(_companySummaries);
// //     });
// //   }

// //   // ================================
// //   // استلام دفعة من شركة
// //   // ================================
// //   Future<void> _receivePayment(Map<String, dynamic> summary) async {
// //     final amountController = TextEditingController();
// //     final companyName = summary['companyName'];
// //     final remainingAmount = summary['totalRemainingAmount'] as double;

// //     if (remainingAmount <= 0) {
// //       _showError('الحساب منتهي بالفعل');
// //       return;
// //     }

// //     await showDialog(
// //       context: context,
// //       builder: (context) => Directionality(
// //         textDirection: flutter_widgets.TextDirection.rtl,
// //         child: Dialog(
// //           backgroundColor: Colors.white,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //           child: Container(
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Text(
// //                       'استلام دفعة: $companyName',
// //                       style: const TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                         color: Color(0xFF2C3E50),
// //                       ),
// //                     ),
// //                     IconButton(
// //                       icon: const Icon(Icons.close, size: 18),
// //                       onPressed: () => Navigator.pop(context),
// //                       padding: EdgeInsets.zero,
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 8),
// //                 const Divider(height: 1),
// //                 const SizedBox(height: 12),
// //                 Text(
// //                   'المستحق: ${remainingAmount.toStringAsFixed(2)} ج',
// //                   style: const TextStyle(
// //                     fontSize: 14,
// //                     color: Colors.red,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),
// //                 TextFormField(
// //                   controller: amountController,
// //                   keyboardType: TextInputType.number,
// //                   decoration: InputDecoration(
// //                     labelText: 'المبلغ المستلم',
// //                     border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     contentPadding: const EdgeInsets.symmetric(
// //                       horizontal: 12,
// //                       vertical: 10,
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 20),
// //                 Row(
// //                   children: [
// //                     Expanded(
// //                       child: OutlinedButton(
// //                         onPressed: () => Navigator.pop(context),
// //                         style: OutlinedButton.styleFrom(
// //                           padding: const EdgeInsets.symmetric(vertical: 10),
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(8),
// //                           ),
// //                         ),
// //                         child: const Text(
// //                           'إلغاء',
// //                           style: TextStyle(fontSize: 14),
// //                         ),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 8),
// //                     Expanded(
// //                       child: ElevatedButton(
// //                         onPressed: () async {
// //                           final paymentAmount =
// //                               double.tryParse(amountController.text) ?? 0.0;

// //                           if (paymentAmount <= 0) {
// //                             _showError('أدخل مبلغ صحيح');
// //                             return;
// //                           }

// //                           if (paymentAmount > remainingAmount) {
// //                             _showError('المبلغ أكبر من المستحق');
// //                             return;
// //                           }

// //                           await _updatePayment(summary, paymentAmount);
// //                           Navigator.pop(context);
// //                         },
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: const Color(0xFF27AE60),
// //                           foregroundColor: Colors.white,
// //                           padding: const EdgeInsets.symmetric(vertical: 10),
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(8),
// //                           ),
// //                         ),
// //                         child: const Text(
// //                           'تسجيل الدفعة',
// //                           style: TextStyle(fontSize: 14),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // ================================
// //   // تحديث الدفعة في قاعدة البيانات
// //   // ================================
// //   Future<void> _updatePayment(
// //     Map<String, dynamic> summary,
// //     double paymentAmount,
// //   ) async {
// //     try {
// //       final docRef = _firestore
// //           .collection('companySummaries')
// //           .doc(summary['companyId']);
// //       final doc = await docRef.get();

// //       if (!doc.exists) return;

// //       final data = doc.data()!;
// //       final currentPaidAmount = (data['totalPaidAmount'] ?? 0).toDouble();
// //       final totalCompanyDebt = (data['totalCompanyDebt'] ?? 0).toDouble();
// //       final newPaidAmount = currentPaidAmount + paymentAmount;
// //       final totalRemainingAmount = totalCompanyDebt - newPaidAmount;

// //       String status;
// //       if (totalRemainingAmount <= 0) {
// //         status = 'منتهية';
// //       } else if (newPaidAmount > 0 && totalRemainingAmount > 0) {
// //         status = 'شبه منتهية';
// //       } else {
// //         status = 'جارية';
// //       }

// //       await docRef.update({
// //         'totalPaidAmount': newPaidAmount,
// //         'totalRemainingAmount': totalRemainingAmount,
// //         'status': status,
// //         'lastUpdated': Timestamp.now(),
// //       });

// //       _showSuccess('تم تسجيل الدفعة بنجاح');
// //       _loadCompanySummaries();
// //     } catch (e) {
// //       _showError('خطأ في تسجيل الدفعة: $e');
// //     }
// //   }

// //   // ================================
// //   // عرض تفاصيل الشركة
// //   // ================================
// //   void _showCompanyDetails(Map<String, dynamic> summary) {
// //     showDialog(
// //       context: context,
// //       builder: (context) => Directionality(
// //         textDirection: flutter_widgets.TextDirection.rtl,
// //         child: Dialog(
// //           backgroundColor: Colors.white,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(12),
// //           ),
// //           child: Container(
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Text(
// //                       'تفاصيل حساب: ${summary['companyName']}',
// //                       style: const TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                         color: Color(0xFF2C3E50),
// //                       ),
// //                     ),
// //                     IconButton(
// //                       icon: const Icon(Icons.close, size: 18),
// //                       onPressed: () => Navigator.pop(context),
// //                       padding: EdgeInsets.zero,
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 8),
// //                 const Divider(height: 1),
// //                 const SizedBox(height: 12),

// //                 // معلومات الحساب
// //                 _buildDetailItem(
// //                   'إجمالي الدين',
// //                   '${summary['totalCompanyDebt'].toStringAsFixed(2)} ج',
// //                   Colors.red,
// //                 ),
// //                 _buildDetailItem(
// //                   'المبلغ المدفوع',
// //                   '${summary['totalPaidAmount'].toStringAsFixed(2)} ج',
// //                   Colors.green,
// //                 ),
// //                 _buildDetailItem(
// //                   'المبلغ المتبقي',
// //                   '${summary['totalRemainingAmount'].toStringAsFixed(2)} ج',
// //                   summary['totalRemainingAmount'] > 0
// //                       ? Colors.orange
// //                       : Colors.blue,
// //                 ),

// //                 const SizedBox(height: 8),
// //                 const Divider(),
// //                 const SizedBox(height: 8),

// //                 _buildDetailItem('عدد الرحلات', '${summary['totalTrips']}'),
// //                 _buildDetailItem(
// //                   'الحالة',
// //                   summary['status'],
// //                   _getStatusColor(summary['status']),
// //                 ),

// //                 const SizedBox(height: 20),
// //                 SizedBox(
// //                   width: double.infinity,
// //                   child: ElevatedButton(
// //                     onPressed: () => Navigator.pop(context),
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: const Color(0xFF3498DB),
// //                       foregroundColor: Colors.white,
// //                       padding: const EdgeInsets.symmetric(vertical: 10),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                     ),
// //                     child: const Text('إغلاق'),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildDetailItem(String label, String value, [Color? color]) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 6),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           Text(
// //             label,
// //             style: const TextStyle(fontSize: 14, color: Color(0xFF2C3E50)),
// //           ),
// //           Text(
// //             value,
// //             style: TextStyle(
// //               fontSize: 14,
// //               fontWeight: FontWeight.bold,
// //               color: color ?? const Color(0xFF3498DB),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ================================
// //   // المربعات الثلاثة العلوية (الحالات)
// //   // ================================
// //   Widget _buildStatusRow() {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           _buildStatusBox('جارية', const Color(0xFFE74C3C), Icons.access_time),
// //           _buildStatusBox(
// //             'شبه منتهية',
// //             const Color(0xFFF39C12),
// //             Icons.hourglass_bottom,
// //           ),
// //           _buildStatusBox(
// //             'منتهية',
// //             const Color(0xFF27AE60),
// //             Icons.check_circle,
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildStatusBox(String status, Color color, IconData icon) {
// //     final count = _companySummaries.where((s) => s['status'] == status).length;
// //     final isSelected = _statusFilter == status;

// //     return GestureDetector(
// //       onTap: () {
// //         setState(() {
// //           _statusFilter = status;
// //           _filteredSummaries = _applyFilters(_companySummaries);
// //         });
// //       },
// //       child: Container(
// //         width: 100,
// //         padding: const EdgeInsets.symmetric(vertical: 10),
// //         decoration: BoxDecoration(
// //           color: isSelected ? color : color.withOpacity(0.1),
// //           borderRadius: BorderRadius.circular(10),
// //           border: Border.all(
// //             color: isSelected ? color : color.withOpacity(0.3),
// //             width: 1.5,
// //           ),
// //         ),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(icon, color: isSelected ? Colors.white : color, size: 22),
// //             const SizedBox(height: 4),
// //             Text(
// //               status,
// //               style: TextStyle(
// //                 color: isSelected ? Colors.white : color,
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 12,
// //               ),
// //             ),
// //             const SizedBox(height: 4),
// //             Text(
// //               '$count',
// //               style: TextStyle(
// //                 color: isSelected ? Colors.white : color,
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 14,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ================================
// //   // AppBar مخصص - مشابه لصفحة السائقين
// //   // ================================
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
// //             Icon(Icons.business, color: Colors.white, size: 28),
// //             SizedBox(width: 12),
// //             Text(
// //               'حسابات الشركات',
// //               style: const TextStyle(
// //                 color: Colors.white,
// //                 fontSize: 20,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             const Spacer(),
// //             if (_isRecalculating)
// //               Padding(
// //                 padding: EdgeInsets.only(right: 8),
// //                 child: SizedBox(
// //                   width: 16,
// //                   height: 16,
// //                   child: CircularProgressIndicator(
// //                     strokeWidth: 2,
// //                     color: Colors.white,
// //                   ),
// //                 ),
// //               ),
// //             IconButton(
// //               onPressed: _loadCompanySummaries,
// //               icon: Icon(Icons.refresh, color: Colors.white, size: 20),
// //               tooltip: 'تحديث',
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ================================
// //   // قسم الفلتر الزمني - مشابه لصفحة السائقين
// //   // ================================
// //   Widget _buildTimeFilterSection() {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
// //       color: Colors.white,
// //       child: Column(
// //         children: [
// //           SingleChildScrollView(
// //             scrollDirection: Axis.horizontal,
// //             child: Row(
// //               children: ['الكل', 'اليوم', 'هذا الشهر', 'هذه السنة']
// //                   .map(
// //                     (filter) => Padding(
// //                       padding: const EdgeInsets.symmetric(horizontal: 4),
// //                       child: ChoiceChip(
// //                         label: Text(filter),
// //                         selected: _timeFilter == filter,
// //                         onSelected: (selected) {
// //                           if (selected) _changeTimeFilter(filter);
// //                         },
// //                         selectedColor: const Color(0xFF3498DB),
// //                         labelStyle: TextStyle(
// //                           color: _timeFilter == filter
// //                               ? Colors.white
// //                               : const Color(0xFF2C3E50),
// //                         ),
// //                       ),
// //                     ),
// //                   )
// //                   .toList(),
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

// //   // ================================
// //   // شريط البحث - مشابه لصفحة السائقين
// //   // ================================
// //   Widget _buildSearchBar() {
// //     return Container(
// //       padding: const EdgeInsets.all(12),
// //       color: Colors.white,
// //       child: Container(
// //         height: 40,
// //         padding: const EdgeInsets.symmetric(horizontal: 12),
// //         decoration: BoxDecoration(
// //           color: const Color(0xFFF1F3F5),
// //           borderRadius: BorderRadius.circular(8),
// //           border: Border.all(color: const Color(0xFFDEE2E6)),
// //         ),
// //         child: Row(
// //           children: [
// //             Icon(Icons.search, color: Colors.grey[600], size: 18),
// //             const SizedBox(width: 8),
// //             Expanded(
// //               child: TextField(
// //                 onChanged: (value) {
// //                   setState(() {
// //                     _searchQuery = value;
// //                     _filteredSummaries = _applyFilters(_companySummaries);
// //                   });
// //                 },
// //                 decoration: const InputDecoration(
// //                   hintText: 'ابحث عن شركة...',
// //                   border: InputBorder.none,
// //                   hintStyle: TextStyle(fontSize: 14),
// //                 ),
// //                 style: const TextStyle(fontSize: 14),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ================================
// //   // قائمة الشركات - مشابهة لصفحة السائقين
// //   // ================================
// //   Widget _buildCompanyList() {
// //     if (_isRecalculating) {
// //       return const Expanded(
// //         child: Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               CircularProgressIndicator(),
// //               SizedBox(height: 16),
// //               Text(
// //                 'جاري إعادة حساب جميع الحسابات...',
// //                 style: TextStyle(color: Color(0xFF3498DB)),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }

// //     if (_isLoading) {
// //       return const Expanded(child: Center(child: CircularProgressIndicator()));
// //     }

// //     if (_filteredSummaries.isEmpty) {
// //       return Expanded(
// //         child: Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(Icons.business, size: 50, color: Colors.grey[400]),
// //               const SizedBox(height: 12),
// //               Text(
// //                 _companySummaries.isEmpty
// //                     ? 'لا توجد شركات مسجلة'
// //                     : 'لا توجد حسابات في هذه الفئة',
// //                 style: TextStyle(color: Colors.grey[600], fontSize: 14),
// //               ),
// //               const SizedBox(height: 16),
// //               if (_companySummaries.isEmpty)
// //                 ElevatedButton(
// //                   onPressed: _recalculateAllCompanySummaries,
// //                   child: const Text('إعادة حساب الحسابات'),
// //                 ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }

// //     return Expanded(
// //       child: ListView.builder(
// //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //         itemCount: _filteredSummaries.length,
// //         itemBuilder: (context, index) {
// //           return _buildCompanyItem(_filteredSummaries[index]);
// //         },
// //       ),
// //     );
// //   }

// //   // ================================
// //   // عنصر الشركة (كارت) - مشابه لصفحة السائقين
// //   // ================================
// //   Widget _buildCompanyItem(Map<String, dynamic> summary) {
// //     final companyName = summary['companyName'];
// //     final remainingAmount = summary['totalRemainingAmount'] as double;
// //     final totalPaid = summary['totalPaidAmount'] as double;

// //     final status = summary['status'];
// //     final isCompleted = status == 'منتهية';

// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 8),
// //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(8),
// //         border: Border.all(
// //           color: isCompleted
// //               ? Colors.green.withOpacity(0.3)
// //               : const Color(0xFF3498DB).withOpacity(0.3),
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.03),
// //             blurRadius: 3,
// //             offset: const Offset(0, 1),
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         children: [
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   companyName,
// //                   style: const TextStyle(
// //                     fontWeight: FontWeight.bold,
// //                     fontSize: 14,
// //                     color: Color(0xFF2C3E50),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 2),
// //                 Container(
// //                   padding: const EdgeInsets.symmetric(
// //                     horizontal: 6,
// //                     vertical: 2,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     color: _getStatusColor(status).withOpacity(0.1),
// //                     borderRadius: BorderRadius.circular(4),
// //                   ),
// //                   child: Text(
// //                     status,
// //                     style: TextStyle(
// //                       color: _getStatusColor(status),
// //                       fontSize: 10,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           Column(
// //             crossAxisAlignment: CrossAxisAlignment.end,
// //             children: [
// //               if (!isCompleted && remainingAmount > 0)
// //                 Text(
// //                   '${remainingAmount.toStringAsFixed(2)} ج',
// //                   style: TextStyle(
// //                     fontSize: 14,
// //                     fontWeight: FontWeight.bold,
// //                     color: isCompleted ? Colors.green : Colors.red,
// //                   ),
// //                 )
// //               else
// //                 Text(
// //                   '${totalPaid.toStringAsFixed(2)} ج',
// //                   style: TextStyle(
// //                     fontSize: 14,
// //                     fontWeight: FontWeight.bold,
// //                     color: isCompleted ? Colors.green : Colors.red,
// //                   ),
// //                 ),
// //               if (!isCompleted && remainingAmount > 0)
// //                 Text(
// //                   'مستحق',
// //                   style: TextStyle(fontSize: 10, color: Colors.grey[600]),
// //                 )
// //               else
// //                 Text(
// //                   'مسدد',
// //                   style: TextStyle(fontSize: 10, color: Colors.grey[600]),
// //                 ),
// //             ],
// //           ),
// //           const SizedBox(width: 12),
// //           if (!isCompleted && remainingAmount > 0)
// //             SizedBox(
// //               height: 32,
// //               child: ElevatedButton(
// //                 onPressed: () => _receivePayment(summary),
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: const Color(0xFF27AE60),
// //                   foregroundColor: Colors.white,
// //                   padding: const EdgeInsets.symmetric(horizontal: 12),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(6),
// //                   ),
// //                   elevation: 0,
// //                 ),
// //                 child: const Text('استلام', style: TextStyle(fontSize: 12)),
// //               ),
// //             )
// //           else
// //             Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //               decoration: BoxDecoration(
// //                 color: Colors.grey[100],
// //                 borderRadius: BorderRadius.circular(6),
// //               ),
// //               child: Text(
// //                 'منتهي',
// //                 style: TextStyle(fontSize: 12, color: Colors.grey[600]),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ================================
// //   // دوال مساعدة
// //   // ================================
// //   Color _getStatusColor(String status) {
// //     switch (status) {
// //       case 'جارية':
// //         return const Color(0xFFE74C3C);
// //       case 'شبه منتهية':
// //         return const Color(0xFFF39C12);
// //       case 'منتهية':
// //         return const Color(0xFF27AE60);
// //       default:
// //         return const Color(0xFF3498DB);
// //     }
// //   }

// //   void _showError(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         backgroundColor: Colors.red,
// //         duration: const Duration(seconds: 2),
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

// //   // ================================
// //   // بناء الواجهة الرئيسية
// //   // ================================
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8F9FA),
// //       body: Column(
// //         children: [
// //           _buildCustomAppBar(),
// //           _buildSearchBar(),
// //           _buildTimeFilterSection(),
// //           _buildStatusRow(),
// //           _buildCompanyList(),
// //         ],
// //       ),
// //       floatingActionButton: FloatingActionButton.extended(
// //         onPressed: () {
// //           showDialog(
// //             context: context,
// //             builder: (context) => Directionality(
// //               textDirection: flutter_widgets.TextDirection.rtl,
// //               child: AlertDialog(
// //                 title: const Text('خيارات التحديث'),
// //                 content: const Text('اختر العملية التي تريد تنفيذها:'),
// //                 actions: [
// //                   TextButton(
// //                     onPressed: () => Navigator.pop(context),
// //                     child: const Text('إلغاء'),
// //                   ),
// //                   TextButton(
// //                     onPressed: () {
// //                       Navigator.pop(context);
// //                       _loadCompanySummaries();
// //                     },
// //                     child: const Text('تحديث القائمة'),
// //                   ),
// //                   ElevatedButton(
// //                     onPressed: () {
// //                       Navigator.pop(context);
// //                       _recalculateAllCompanySummaries();
// //                     },
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: const Color(0xFFE74C3C),
// //                     ),
// //                     child: const Text('إعادة حساب الكل'),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           );
// //         },
// //         backgroundColor: const Color(0xFF3498DB),
// //         icon: Icon(Icons.calculate, color: Colors.white),
// //         label: const Text('إعادة حساب', style: TextStyle(color: Colors.white)),
// //         tooltip: 'إعادة حساب الحسابات',
// //       ),
// //     );
// //   }
// // }
// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart' as flutter_widgets;

// class CompaniesAccountsPage extends StatefulWidget {
//   const CompaniesAccountsPage({super.key});

//   @override
//   State<CompaniesAccountsPage> createState() => _CompaniesAccountsPageState();
// }

// class _CompaniesAccountsPageState extends State<CompaniesAccountsPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   List<Map<String, dynamic>> _companySummaries = [];
//   List<Map<String, dynamic>> _filteredSummaries = [];
//   bool _isLoading = false;
//   String _searchQuery = '';
//   String _statusFilter = 'جارية'; // الافتراضي: جارية

//   @override
//   void initState() {
//     super.initState();
//     _loadCompanySummaries();
//   }

//   Future<void> _loadCompanySummaries() async {
//     setState(() => _isLoading = true);

//     try {
//       final snapshot = await _firestore.collection('companySummaries').get();

//       if (snapshot.docs.isEmpty) {
//         await _createCompanySummariesFromDailyWork();
//         return;
//       }

//       final summariesList = snapshot.docs.map((doc) {
//         final data = doc.data();

//         final totalCompanyDebt = (data['totalCompanyDebt'] ?? 0).toDouble();
//         final totalPaidAmount = (data['totalPaidAmount'] ?? 0).toDouble();
//         final totalRemainingAmount = totalCompanyDebt - totalPaidAmount;

//         String status;
//         if (totalRemainingAmount <= 0) {
//           status = 'منتهية';
//         } else if (totalPaidAmount > 0 && totalRemainingAmount > 0) {
//           status = 'شبه منتهية';
//         } else {
//           status = 'جارية';
//         }

//         return {
//           'companyId': data['companyId'] ?? '',
//           'companyName': data['companyName'] ?? 'غير معروف',
//           'totalCompanyDebt': totalCompanyDebt,
//           'totalPaidAmount': totalPaidAmount,
//           'totalRemainingAmount': totalRemainingAmount,
//           'status': status,
//           'docId': doc.id,
//           'lastUpdated': data['lastUpdated'],
//         };
//       }).toList();

//       summariesList.sort(
//         (a, b) =>
//             b['totalRemainingAmount'].compareTo(a['totalRemainingAmount']),
//       );

//       setState(() {
//         _companySummaries = summariesList;
//         _filteredSummaries = _applyFilters(summariesList);
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showError('خطأ في تحميل حسابات الشركات: $e');
//     }
//   }

//   Future<void> _createCompanySummariesFromDailyWork() async {
//     try {
//       final snapshot = await _firestore.collection('dailyWork').get();
//       Map<String, Map<String, dynamic>> companyTotals = {};

//       for (final doc in snapshot.docs) {
//         final data = doc.data();
//         final companyId = data['companyId'] as String?;
//         final companyName = data['companyName'] as String?;

//         if (companyId != null && companyId.isNotEmpty && companyName != null) {
//           if (!companyTotals.containsKey(companyId)) {
//             companyTotals[companyId] = {
//               'companyId': companyId,
//               'companyName': companyName,
//               'totalCompanyDebt': 0.0,
//               'totalPaidAmount': 0.0,
//             };
//           }

//           final total = companyTotals[companyId]!;

//           final nolon = (data['nolon'] ?? data['noLon'] ?? 0).toDouble();
//           final companyOvernight = (data['companyOvernight'] ?? 0).toDouble();
//           final companyHoliday = (data['companyHoliday'] ?? 0).toDouble();

//           total['totalCompanyDebt'] +=
//               nolon + companyOvernight + companyHoliday;
//         }
//       }

//       final batch = _firestore.batch();
//       for (var entry in companyTotals.entries) {
//         final summary = entry.value;
//         final companyId = entry.key;

//         final docRef = _firestore.collection('companySummaries').doc(companyId);
//         final existingDoc = await docRef.get();

//         if (existingDoc.exists) {
//           final existingData = existingDoc.data()!;
//           summary['totalPaidAmount'] = existingData['totalPaidAmount'] ?? 0;
//         } else {
//           summary['totalPaidAmount'] = 0.0;
//         }

//         summary['totalRemainingAmount'] =
//             summary['totalCompanyDebt'] - summary['totalPaidAmount'];

//         String status;
//         if (summary['totalRemainingAmount'] <= 0) {
//           status = 'منتهية';
//         } else if (summary['totalPaidAmount'] > 0) {
//           status = 'شبه منتهية';
//         } else {
//           status = 'جارية';
//         }

//         summary['status'] = status;
//         summary['lastUpdated'] = Timestamp.now();

//         batch.set(docRef, summary);
//       }

//       await batch.commit();
//       _loadCompanySummaries();
//     } catch (e) {
//       _showError('خطأ في إنشاء بيانات الشركات: $e');
//     }
//   }

//   List<Map<String, dynamic>> _applyFilters(
//     List<Map<String, dynamic>> summaries,
//   ) {
//     return summaries.where((summary) {
//       if (_searchQuery.isNotEmpty) {
//         if (!summary['companyName'].toLowerCase().contains(
//           _searchQuery.toLowerCase(),
//         )) {
//           return false;
//         }
//       }

//       if (_statusFilter == 'جارية') {
//         return summary['status'] == 'جارية';
//       } else if (_statusFilter == 'شبه منتهية') {
//         return summary['status'] == 'شبه منتهية';
//       } else if (_statusFilter == 'منتهية') {
//         return summary['status'] == 'منتهية';
//       }

//       return true;
//     }).toList();
//   }

//   Future<void> _receivePayment(Map<String, dynamic> summary) async {
//     final amountController = TextEditingController();
//     final companyName = summary['companyName'];
//     final companyId = summary['companyId'];
//     final remainingAmount = summary['totalRemainingAmount'] as double;

//     if (remainingAmount <= 0) {
//       _showError('الحساب منتهي بالفعل');
//       return;
//     }

//     await showDialog(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: flutter_widgets.TextDirection.rtl,
//         child: Dialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'استلام دفعة: $companyName',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF2C3E50),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close, size: 18),
//                       onPressed: () => Navigator.pop(context),
//                       padding: EdgeInsets.zero,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 const Divider(height: 1),
//                 const SizedBox(height: 12),
//                 Text(
//                   'المستحق: ${remainingAmount.toStringAsFixed(2)} ج',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.red,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: amountController,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     labelText: 'المبلغ المستلم',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 10,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () => Navigator.pop(context),
//                         style: OutlinedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 10),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: const Text(
//                           'إلغاء',
//                           style: TextStyle(fontSize: 14),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () async {
//                           final paymentAmount =
//                               double.tryParse(amountController.text) ?? 0.0;

//                           if (paymentAmount <= 0) {
//                             _showError('أدخل مبلغ صحيح');
//                             return;
//                           }

//                           if (paymentAmount > remainingAmount) {
//                             _showError('المبلغ أكبر من المستحق');
//                             return;
//                           }

//                           await _updatePayment(
//                             companyId,
//                             companyName,
//                             paymentAmount,
//                           );
//                           Navigator.pop(context);
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF27AE60),
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 10),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: const Text(
//                           'تسجيل الدفعة',
//                           style: TextStyle(fontSize: 14),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _updatePayment(
//     String companyId,
//     String companyName,
//     double paymentAmount,
//   ) async {
//     try {
//       final docRef = _firestore.collection('companySummaries').doc(companyId);
//       final doc = await docRef.get();

//       if (!doc.exists) return;

//       final data = doc.data()!;
//       final currentPaidAmount = (data['totalPaidAmount'] ?? 0).toDouble();
//       final totalCompanyDebt = (data['totalCompanyDebt'] ?? 0).toDouble();
//       final newPaidAmount = currentPaidAmount + paymentAmount;
//       final totalRemainingAmount = totalCompanyDebt - newPaidAmount;

//       String status;
//       if (totalRemainingAmount <= 0) {
//         status = 'منتهية';
//       } else if (newPaidAmount > 0 && totalRemainingAmount > 0) {
//         status = 'شبه منتهية';
//       } else {
//         status = 'جارية';
//       }

//       await docRef.update({
//         'totalPaidAmount': newPaidAmount,
//         'totalRemainingAmount': totalRemainingAmount,
//         'status': status,
//         'lastUpdated': Timestamp.now(),
//       });

//       // تحديث الرحلات الفردية للشركة
//       await _updateIndividualCompanyTrips(companyId, paymentAmount);
//       _showSuccess('تم تسجيل الدفعة بنجاح');

//       // نقل الحسابات المنتهية إلى مجموعة finishedAccounts
//       if (totalRemainingAmount <= 0) {
//         final finishedRef = _firestore
//             .collection('finishedCompanyAccounts')
//             .doc(companyId);
//         final finishedDoc = await finishedRef.get();

//         if (finishedDoc.exists) {
//           final existingData = finishedDoc.data()!;
//           final previousTotal = (existingData['totalReceived'] ?? 0).toDouble();
//           await finishedRef.update({
//             'totalReceived': previousTotal + newPaidAmount,
//             'companyName': companyName,
//             'lastUpdated': Timestamp.now(),
//           });
//         } else {
//           await finishedRef.set({
//             'companyId': companyId,
//             'companyName': companyName,
//             'totalReceived': newPaidAmount,
//             'lastUpdated': Timestamp.now(),
//           });
//         }
//       }

//       _loadCompanySummaries();
//     } catch (e) {
//       _showError('خطأ في تسجيل الدفعة: $e');
//     }
//   }

//   Future<void> _updateIndividualCompanyTrips(
//     String companyId,
//     double paymentAmount,
//   ) async {
//     try {
//       final snapshot = await _firestore
//           .collection('dailyWork')
//           .where('companyId', isEqualTo: companyId)
//           .where('isPaid', isEqualTo: false)
//           .get();

//       double remainingPayment = paymentAmount;

//       for (final doc in snapshot.docs) {
//         if (remainingPayment <= 0) break;

//         final data = doc.data();
//         final nolon = (data['nolon'] ?? data['noLon'] ?? 0).toDouble();
//         final companyOvernight = (data['companyOvernight'] ?? 0).toDouble();
//         final companyHoliday = (data['companyHoliday'] ?? 0).toDouble();
//         final currentPaid = (data['companyPaidAmount'] ?? 0).toDouble();

//         final tripTotal = nolon + companyOvernight + companyHoliday;
//         final tripRemaining = tripTotal - currentPaid;

//         final toPay = remainingPayment > tripRemaining
//             ? tripRemaining
//             : remainingPayment;
//         final newPaidAmount = currentPaid + toPay;
//         final isFullyPaid = newPaidAmount >= tripTotal;

//         await doc.reference.update({
//           'companyPaidAmount': newPaidAmount,
//           'isPaid': isFullyPaid,
//           'remainingAmount': tripTotal - newPaidAmount,
//         });

//         remainingPayment -= toPay;
//       }
//     } catch (e) {
//       print('خطأ في تحديث رحلات الشركة: $e');
//     }
//   }

//   Widget _buildStatusRow() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           _buildStatusBox('جارية', const Color(0xFFE74C3C), Icons.access_time),
//           _buildStatusBox(
//             'شبه منتهية',
//             const Color(0xFFF39C12),
//             Icons.hourglass_bottom,
//           ),
//           _buildStatusBox(
//             'منتهية',
//             const Color(0xFF27AE60),
//             Icons.check_circle,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusBox(String status, Color color, IconData icon) {
//     final count = _companySummaries.where((s) => s['status'] == status).length;
//     final isSelected = _statusFilter == status;

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _statusFilter = status;
//           _filteredSummaries = _applyFilters(_companySummaries);
//         });
//       },
//       child: Container(
//         width: 100,
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//           color: isSelected ? color : color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color: isSelected ? color : color.withOpacity(0.3),
//             width: 1.5,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: isSelected ? Colors.white : color, size: 22),
//             const SizedBox(height: 4),
//             Text(
//               status,
//               style: TextStyle(
//                 color: isSelected ? Colors.white : color,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               '$count',
//               style: TextStyle(
//                 color: isSelected ? Colors.white : color,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCustomAppBar() {
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
//             Icon(Icons.business, color: Colors.white, size: 28),
//             SizedBox(width: 12),
//             Text(
//               'حسابات الشركات',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const Spacer(),
//             IconButton(
//               onPressed: _loadCompanySummaries,
//               icon: Icon(Icons.refresh, color: Colors.white, size: 20),
//               tooltip: 'تحديث',
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCompanyList() {
//     if (_isLoading) {
//       return const Expanded(child: Center(child: CircularProgressIndicator()));
//     }

//     if (_filteredSummaries.isEmpty) {
//       return Expanded(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.business, size: 50, color: Colors.grey[400]),
//               const SizedBox(height: 12),
//               Text(
//                 'لا يوجد حسابات في هذه الفئة',
//                 style: TextStyle(color: Colors.grey[600], fontSize: 14),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Expanded(
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         itemCount: _filteredSummaries.length,
//         itemBuilder: (context, index) {
//           return _buildCompanyItem(_filteredSummaries[index]);
//         },
//       ),
//     );
//   }

//   Widget _buildCompanyItem(Map<String, dynamic> summary) {
//     final companyName = summary['companyName'];
//     final remainingAmount = summary['totalRemainingAmount'] as double;
//     final totalPaid = summary['totalPaidAmount'] as double;

//     final status = summary['status'];
//     final isCompleted = status == 'منتهية';

//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: isCompleted
//               ? Colors.green.withOpacity(0.3)
//               : const Color(0xFF3498DB).withOpacity(0.3),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 3,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   companyName,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                     color: Color(0xFF2C3E50),
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 6,
//                     vertical: 2,
//                   ),
//                   decoration: BoxDecoration(
//                     color: _getStatusColor(status).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     status,
//                     style: TextStyle(
//                       color: _getStatusColor(status),
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               if (!isCompleted && remainingAmount > 0)
//                 Text(
//                   '${remainingAmount.toStringAsFixed(2)} ج',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: isCompleted ? Colors.green : Colors.red,
//                   ),
//                 )
//               else
//                 Text(
//                   '${totalPaid.toStringAsFixed(2)} ج',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: isCompleted ? Colors.green : Colors.red,
//                   ),
//                 ),
//               if (!isCompleted && remainingAmount > 0)
//                 Text(
//                   'مستحق',
//                   style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                 )
//               else
//                 Text(
//                   'مسدد',
//                   style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                 ),
//             ],
//           ),
//           const SizedBox(width: 12),
//           if (!isCompleted && remainingAmount > 0)
//             SizedBox(
//               height: 32,
//               child: ElevatedButton(
//                 onPressed: () => _receivePayment(summary),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF27AE60),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: const Text('استلام', style: TextStyle(fontSize: 12)),
//               ),
//             )
//           else
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Text(
//                 'منتهي',
//                 style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'جارية':
//         return const Color(0xFFE74C3C);
//       case 'شبه منتهية':
//         return const Color(0xFFF39C12);
//       case 'منتهية':
//         return const Color(0xFF27AE60);
//       default:
//         return const Color(0xFF3498DB);
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 2),
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       body: Column(
//         children: [
//           _buildCustomAppBar(),
//           Container(
//             padding: const EdgeInsets.all(12),
//             color: Colors.white,
//             child: Container(
//               height: 40,
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF1F3F5),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: const Color(0xFFDEE2E6)),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.search, color: Colors.grey[600], size: 18),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: TextField(
//                       onChanged: (value) {
//                         setState(() {
//                           _searchQuery = value;
//                           _filteredSummaries = _applyFilters(_companySummaries);
//                         });
//                       },
//                       decoration: const InputDecoration(
//                         hintText: 'ابحث عن شركة...',
//                         border: InputBorder.none,
//                         hintStyle: TextStyle(fontSize: 14),
//                       ),
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           _buildStatusRow(),
//           _buildCompanyList(),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           setState(() => _isLoading = true);
//           await _createCompanySummariesFromDailyWork();
//           setState(() => _isLoading = false);
//           _showSuccess('تم إعادة حساب جميع حسابات الشركات');
//         },
//         backgroundColor: const Color(0xFF3498DB),
//         child: Icon(Icons.calculate, color: Colors.white),
//         tooltip: 'إعادة حساب الحسابات',
//       ),
//     );
//   }
// // }
// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart' as flutter_widgets;

// class CompaniesAccountsPage extends StatefulWidget {
//   const CompaniesAccountsPage({super.key});

//   @override
//   State<CompaniesAccountsPage> createState() => _CompaniesAccountsPageState();
// }

// class _CompaniesAccountsPageState extends State<CompaniesAccountsPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   List<Map<String, dynamic>> _companySummaries = [];
//   List<Map<String, dynamic>> _filteredSummaries = [];
//   bool _isLoading = false;
//   String _searchQuery = '';
//   String _statusFilter = 'جارية'; // الافتراضي: جارية

//   // فلتر زمني
//   String _timeFilter = 'الكل';
//   int _selectedMonth = DateTime.now().month;
//   int _selectedYear = DateTime.now().year;

//   @override
//   void initState() {
//     super.initState();
//     _loadCompanySummaries();
//   }

//   Future<void> _loadCompanySummaries() async {
//     setState(() => _isLoading = true);

//     try {
//       final snapshot = await _firestore.collection('companySummaries').get();

//       if (snapshot.docs.isEmpty) {
//         await _createCompanySummariesFromDailyWork();
//         return;
//       }

//       final summariesList = snapshot.docs.map((doc) {
//         final data = doc.data();

//         final totalCompanyDebt = (data['totalCompanyDebt'] ?? 0).toDouble();
//         final totalPaidAmount = (data['totalPaidAmount'] ?? 0).toDouble();
//         final totalRemainingAmount = totalCompanyDebt - totalPaidAmount;

//         String status;
//         if (totalRemainingAmount <= 0) {
//           status = 'منتهية';
//         } else if (totalPaidAmount > 0 && totalRemainingAmount > 0) {
//           status = 'شبه منتهية';
//         } else {
//           status = 'جارية';
//         }

//         return {
//           'companyId': data['companyId'] ?? '',
//           'companyName': data['companyName'] ?? 'غير معروف',
//           'totalCompanyDebt': totalCompanyDebt,
//           'totalPaidAmount': totalPaidAmount,
//           'totalRemainingAmount': totalRemainingAmount,
//           'status': status,
//           'docId': doc.id,
//           'lastUpdated': data['lastUpdated'],
//         };
//       }).toList();

//       summariesList.sort(
//         (a, b) =>
//             b['totalRemainingAmount'].compareTo(a['totalRemainingAmount']),
//       );

//       setState(() {
//         _companySummaries = summariesList;
//         _filteredSummaries = _applyFilters(summariesList);
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showError('خطأ في تحميل حسابات الشركات: $e');
//     }
//   }

//   Future<void> _createCompanySummariesFromDailyWork() async {
//     try {
//       final snapshot = await _firestore.collection('dailyWork').get();
//       Map<String, Map<String, dynamic>> companyTotals = {};

//       for (final doc in snapshot.docs) {
//         final data = doc.data();
//         final companyId = data['companyId'] as String?;
//         final companyName = data['companyName'] as String?;

//         if (companyId != null && companyId.isNotEmpty && companyName != null) {
//           if (!companyTotals.containsKey(companyId)) {
//             companyTotals[companyId] = {
//               'companyId': companyId,
//               'companyName': companyName,
//               'totalCompanyDebt': 0.0,
//               'totalPaidAmount': 0.0,
//             };
//           }

//           final total = companyTotals[companyId]!;

//           final nolon = (data['nolon'] ?? data['noLon'] ?? 0).toDouble();
//           final companyOvernight = (data['companyOvernight'] ?? 0).toDouble();
//           final companyHoliday = (data['companyHoliday'] ?? 0).toDouble();

//           total['totalCompanyDebt'] +=
//               nolon + companyOvernight + companyHoliday;
//         }
//       }

//       final batch = _firestore.batch();
//       for (var entry in companyTotals.entries) {
//         final summary = entry.value;
//         final companyId = entry.key;

//         final docRef = _firestore.collection('companySummaries').doc(companyId);
//         final existingDoc = await docRef.get();

//         if (existingDoc.exists) {
//           final existingData = existingDoc.data()!;
//           summary['totalPaidAmount'] = existingData['totalPaidAmount'] ?? 0;
//         } else {
//           summary['totalPaidAmount'] = 0.0;
//         }

//         summary['totalRemainingAmount'] =
//             summary['totalCompanyDebt'] - summary['totalPaidAmount'];

//         String status;
//         if (summary['totalRemainingAmount'] <= 0) {
//           status = 'منتهية';
//         } else if (summary['totalPaidAmount'] > 0) {
//           status = 'شبه منتهية';
//         } else {
//           status = 'جارية';
//         }

//         summary['status'] = status;
//         summary['lastUpdated'] = Timestamp.now();

//         batch.set(docRef, summary);
//       }

//       await batch.commit();
//       _loadCompanySummaries();
//     } catch (e) {
//       _showError('خطأ في إنشاء بيانات الشركات: $e');
//     }
//   }

//   List<Map<String, dynamic>> _applyFilters(
//     List<Map<String, dynamic>> summaries,
//   ) {
//     return summaries.where((summary) {
//       if (_searchQuery.isNotEmpty) {
//         if (!summary['companyName'].toLowerCase().contains(
//           _searchQuery.toLowerCase(),
//         )) {
//           return false;
//         }
//       }

//       // تطبيق الفلتر الزمني
//       if (_timeFilter != 'الكل') {
//         final timestamp = summary['lastUpdated'] as Timestamp?;
//         if (timestamp == null) return false;

//         final now = DateTime.now();
//         final summaryDate = timestamp.toDate();

//         switch (_timeFilter) {
//           case 'اليوم':
//             if (summaryDate.year != now.year ||
//                 summaryDate.month != now.month ||
//                 summaryDate.day != now.day) {
//               return false;
//             }
//             break;
//           case 'هذا الشهر':
//             if (summaryDate.year != now.year ||
//                 summaryDate.month != now.month) {
//               return false;
//             }
//             break;
//           case 'هذه السنة':
//             if (summaryDate.year != now.year) {
//               return false;
//             }
//             break;
//           case 'مخصص':
//             if (summaryDate.year != _selectedYear ||
//                 summaryDate.month != _selectedMonth) {
//               return false;
//             }
//             break;
//         }
//       }

//       if (_statusFilter == 'جارية') {
//         return summary['status'] == 'جارية';
//       } else if (_statusFilter == 'شبه منتهية') {
//         return summary['status'] == 'شبه منتهية';
//       } else if (_statusFilter == 'منتهية') {
//         return summary['status'] == 'منتهية';
//       }

//       return true;
//     }).toList();
//   }

//   void _changeTimeFilter(String filter) {
//     setState(() {
//       _timeFilter = filter;
//       _filteredSummaries = _applyFilters(_companySummaries);
//     });
//   }

//   void _applyMonthYearFilter() {
//     setState(() {
//       _timeFilter = 'مخصص';
//       _filteredSummaries = _applyFilters(_companySummaries);
//     });
//   }

//   Future<void> _receivePayment(Map<String, dynamic> summary) async {
//     final amountController = TextEditingController();
//     final companyName = summary['companyName'];
//     final companyId = summary['companyId'];
//     final remainingAmount = summary['totalRemainingAmount'] as double;

//     if (remainingAmount <= 0) {
//       _showError('الحساب منتهي بالفعل');
//       return;
//     }

//     await showDialog(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: flutter_widgets.TextDirection.rtl,
//         child: Dialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'استلام دفعة: $companyName',
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF2C3E50),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.close, size: 18),
//                       onPressed: () => Navigator.pop(context),
//                       padding: EdgeInsets.zero,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 const Divider(height: 1),
//                 const SizedBox(height: 12),
//                 Text(
//                   'المستحق: ${remainingAmount.toStringAsFixed(2)} ج',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.red,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextFormField(
//                   controller: amountController,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     labelText: 'المبلغ المستلم',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 10,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: () => Navigator.pop(context),
//                         style: OutlinedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 10),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: const Text(
//                           'إلغاء',
//                           style: TextStyle(fontSize: 14),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: () async {
//                           final paymentAmount =
//                               double.tryParse(amountController.text) ?? 0.0;

//                           if (paymentAmount <= 0) {
//                             _showError('أدخل مبلغ صحيح');
//                             return;
//                           }

//                           if (paymentAmount > remainingAmount) {
//                             _showError('المبلغ أكبر من المستحق');
//                             return;
//                           }

//                           await _updatePayment(
//                             companyId,
//                             companyName,
//                             paymentAmount,
//                           );
//                           Navigator.pop(context);
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF27AE60),
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 10),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         child: const Text(
//                           'تسجيل الدفعة',
//                           style: TextStyle(fontSize: 14),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _updatePayment(
//     String companyId,
//     String companyName,
//     double paymentAmount,
//   ) async {
//     try {
//       final docRef = _firestore.collection('companySummaries').doc(companyId);
//       final doc = await docRef.get();

//       if (!doc.exists) return;

//       final data = doc.data()!;
//       final currentPaidAmount = (data['totalPaidAmount'] ?? 0).toDouble();
//       final totalCompanyDebt = (data['totalCompanyDebt'] ?? 0).toDouble();
//       final newPaidAmount = currentPaidAmount + paymentAmount;
//       final totalRemainingAmount = totalCompanyDebt - newPaidAmount;

//       String status;
//       if (totalRemainingAmount <= 0) {
//         status = 'منتهية';
//       } else if (newPaidAmount > 0 && totalRemainingAmount > 0) {
//         status = 'شبه منتهية';
//       } else {
//         status = 'جارية';
//       }

//       await docRef.update({
//         'totalPaidAmount': newPaidAmount,
//         'totalRemainingAmount': totalRemainingAmount,
//         'status': status,
//         'lastUpdated': Timestamp.now(),
//       });

//       // تحديث الرحلات الفردية للشركة
//       await _updateIndividualCompanyTrips(companyId, paymentAmount);
//       _showSuccess('تم تسجيل الدفعة بنجاح');

//       // نقل الحسابات المنتهية إلى مجموعة finishedAccounts
//       if (totalRemainingAmount <= 0) {
//         final finishedRef = _firestore
//             .collection('finishedCompanyAccounts')
//             .doc(companyId);
//         final finishedDoc = await finishedRef.get();

//         if (finishedDoc.exists) {
//           final existingData = finishedDoc.data()!;
//           final previousTotal = (existingData['totalReceived'] ?? 0).toDouble();
//           await finishedRef.update({
//             'totalReceived': previousTotal + newPaidAmount,
//             'companyName': companyName,
//             'lastUpdated': Timestamp.now(),
//           });
//         } else {
//           await finishedRef.set({
//             'companyId': companyId,
//             'companyName': companyName,
//             'totalReceived': newPaidAmount,
//             'lastUpdated': Timestamp.now(),
//           });
//         }
//       }

//       _loadCompanySummaries();
//     } catch (e) {
//       _showError('خطأ في تسجيل الدفعة: $e');
//     }
//   }

//   Future<void> _updateIndividualCompanyTrips(
//     String companyId,
//     double paymentAmount,
//   ) async {
//     try {
//       final snapshot = await _firestore
//           .collection('dailyWork')
//           .where('companyId', isEqualTo: companyId)
//           .where('isPaid', isEqualTo: false)
//           .get();

//       double remainingPayment = paymentAmount;

//       for (final doc in snapshot.docs) {
//         if (remainingPayment <= 0) break;

//         final data = doc.data();
//         final nolon = (data['nolon'] ?? data['noLon'] ?? 0).toDouble();
//         final companyOvernight = (data['companyOvernight'] ?? 0).toDouble();
//         final companyHoliday = (data['companyHoliday'] ?? 0).toDouble();
//         final currentPaid = (data['companyPaidAmount'] ?? 0).toDouble();

//         final tripTotal = nolon + companyOvernight + companyHoliday;
//         final tripRemaining = tripTotal - currentPaid;

//         final toPay = remainingPayment > tripRemaining
//             ? tripRemaining
//             : remainingPayment;
//         final newPaidAmount = currentPaid + toPay;
//         final isFullyPaid = newPaidAmount >= tripTotal;

//         await doc.reference.update({
//           'companyPaidAmount': newPaidAmount,
//           'isPaid': isFullyPaid,
//           'remainingAmount': tripTotal - newPaidAmount,
//         });

//         remainingPayment -= toPay;
//       }
//     } catch (e) {
//       print('خطأ في تحديث رحلات الشركة: $e');
//     }
//   }

//   Widget _buildStatusRow() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           _buildStatusBox('جارية', const Color(0xFFE74C3C), Icons.access_time),
//           _buildStatusBox(
//             'شبه منتهية',
//             const Color(0xFFF39C12),
//             Icons.hourglass_bottom,
//           ),
//           _buildStatusBox(
//             'منتهية',
//             const Color(0xFF27AE60),
//             Icons.check_circle,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusBox(String status, Color color, IconData icon) {
//     final count = _companySummaries.where((s) => s['status'] == status).length;
//     final isSelected = _statusFilter == status;

//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _statusFilter = status;
//           _filteredSummaries = _applyFilters(_companySummaries);
//         });
//       },
//       child: Container(
//         width: 100,
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         decoration: BoxDecoration(
//           color: isSelected ? color : color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(
//             color: isSelected ? color : color.withOpacity(0.3),
//             width: 1.5,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: isSelected ? Colors.white : color, size: 22),
//             const SizedBox(height: 4),
//             Text(
//               status,
//               style: TextStyle(
//                 color: isSelected ? Colors.white : color,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               '$count',
//               style: TextStyle(
//                 color: isSelected ? Colors.white : color,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCustomAppBar() {
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
//             Icon(Icons.business, color: Colors.white, size: 28),
//             SizedBox(width: 12),
//             Text(
//               'حسابات الشركات',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const Spacer(),
//             // الساعة الزمنية مثل صفحة السائقين
//             StreamBuilder<DateTime>(
//               stream: Stream.periodic(
//                 const Duration(seconds: 1),
//                 (_) => DateTime.now(),
//               ),
//               builder: (context, snapshot) {
//                 final now = snapshot.data ?? DateTime.now();
//                 int hour12 = now.hour % 12;
//                 if (hour12 == 0) hour12 = 12;
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

//   Widget _buildTimeFilterSection() {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//       color: Colors.white,
//       child: Column(
//         children: [
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: ['الكل', 'اليوم', 'هذا الشهر', 'هذه السنة']
//                   .map(
//                     (filter) => Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 4),
//                       child: ChoiceChip(
//                         label: Text(filter),
//                         selected: _timeFilter == filter,
//                         onSelected: (selected) {
//                           if (selected) _changeTimeFilter(filter);
//                         },
//                         selectedColor: const Color(0xFF3498DB),
//                         labelStyle: TextStyle(
//                           color: _timeFilter == filter
//                               ? Colors.white
//                               : const Color(0xFF2C3E50),
//                         ),
//                       ),
//                     ),
//                   )
//                   .toList(),
//             ),
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

//   Widget _buildCompanyList() {
//     if (_isLoading) {
//       return const Expanded(child: Center(child: CircularProgressIndicator()));
//     }

//     if (_filteredSummaries.isEmpty) {
//       return Expanded(
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.business, size: 50, color: Colors.grey[400]),
//               const SizedBox(height: 12),
//               Text(
//                 'لا يوجد حسابات في هذه الفئة',
//                 style: TextStyle(color: Colors.grey[600], fontSize: 14),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Expanded(
//       child: ListView.builder(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         itemCount: _filteredSummaries.length,
//         itemBuilder: (context, index) {
//           return _buildCompanyItem(_filteredSummaries[index]);
//         },
//       ),
//     );
//   }

//   Widget _buildCompanyItem(Map<String, dynamic> summary) {
//     final companyName = summary['companyName'];
//     final remainingAmount = summary['totalRemainingAmount'] as double;
//     final totalPaid = summary['totalPaidAmount'] as double;

//     final status = summary['status'];
//     final isCompleted = status == 'منتهية';

//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: isCompleted
//               ? Colors.green.withOpacity(0.3)
//               : const Color(0xFF3498DB).withOpacity(0.3),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 3,
//             offset: const Offset(0, 1),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   companyName,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                     color: Color(0xFF2C3E50),
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 6,
//                     vertical: 2,
//                   ),
//                   decoration: BoxDecoration(
//                     color: _getStatusColor(status).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Text(
//                     status,
//                     style: TextStyle(
//                       color: _getStatusColor(status),
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               if (!isCompleted && remainingAmount > 0)
//                 Text(
//                   '${remainingAmount.toStringAsFixed(2)} ج',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: isCompleted ? Colors.green : Colors.red,
//                   ),
//                 )
//               else
//                 Text(
//                   '${totalPaid.toStringAsFixed(2)} ج',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: isCompleted ? Colors.green : Colors.red,
//                   ),
//                 ),
//               if (!isCompleted && remainingAmount > 0)
//                 Text(
//                   'مستحق',
//                   style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                 )
//               else
//                 Text(
//                   'مسدد',
//                   style: TextStyle(fontSize: 10, color: Colors.grey[600]),
//                 ),
//             ],
//           ),
//           const SizedBox(width: 12),
//           if (!isCompleted && remainingAmount > 0)
//             SizedBox(
//               height: 32,
//               child: ElevatedButton(
//                 onPressed: () => _receivePayment(summary),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF27AE60),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: const Text('استلام', style: TextStyle(fontSize: 12)),
//               ),
//             )
//           else
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Text(
//                 'منتهي',
//                 style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'جارية':
//         return const Color(0xFFE74C3C);
//       case 'شبه منتهية':
//         return const Color(0xFFF39C12);
//       case 'منتهية':
//         return const Color(0xFF27AE60);
//       default:
//         return const Color(0xFF3498DB);
//     }
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//         duration: const Duration(seconds: 2),
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       body: Column(
//         children: [
//           _buildCustomAppBar(),
//           Container(
//             padding: const EdgeInsets.all(12),
//             color: Colors.white,
//             child: Container(
//               height: 40,
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF1F3F5),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: const Color(0xFFDEE2E6)),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.search, color: Colors.grey[600], size: 18),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: TextField(
//                       onChanged: (value) {
//                         setState(() {
//                           _searchQuery = value;
//                           _filteredSummaries = _applyFilters(_companySummaries);
//                         });
//                       },
//                       decoration: const InputDecoration(
//                         hintText: 'ابحث عن شركة...',
//                         border: InputBorder.none,
//                         hintStyle: TextStyle(fontSize: 14),
//                       ),
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           _buildTimeFilterSection(),
//           _buildStatusRow(),
//           _buildCompanyList(),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           setState(() => _isLoading = true);
//           await _createCompanySummariesFromDailyWork();
//           setState(() => _isLoading = false);
//           _showSuccess('تم إعادة حساب جميع حسابات الشركات');
//         },
//         backgroundColor: const Color(0xFF3498DB),
//         child: Icon(Icons.refresh, color: Colors.white),
//         tooltip: 'تحديث الحسابات',
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as flutter_widgets;

class CompaniesAccountsPage extends StatefulWidget {
  const CompaniesAccountsPage({super.key});

  @override
  State<CompaniesAccountsPage> createState() => _CompaniesAccountsPageState();
}

class _CompaniesAccountsPageState extends State<CompaniesAccountsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _companySummaries = [];
  List<Map<String, dynamic>> _filteredSummaries = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _statusFilter = 'جارية'; // الافتراضي: جارية

  // فلتر زمني
  String _timeFilter = 'الكل';
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadCompanySummaries();
  }

  Future<void> _loadCompanySummaries() async {
    setState(() => _isLoading = true);

    try {
      // تحميل الحسابات النشطة
      final activeSnapshot = await _firestore
          .collection('companySummaries')
          .where('status', whereIn: ['جارية', 'شبه منتهية'])
          .get();

      // تحميل الحسابات المنتهية
      final finishedSnapshot = await _firestore
          .collection('finishedCompanyAccounts')
          .get();

      List<Map<String, dynamic>> summariesList = [];

      // إضافة الحسابات النشطة
      for (final doc in activeSnapshot.docs) {
        final data = doc.data();
        summariesList.add(_processSummaryData(data, doc.id));
      }

      // إضافة الحسابات المنتهية
      for (final doc in finishedSnapshot.docs) {
        final data = doc.data();
        summariesList.add({
          'companyId': data['companyId'] ?? '',
          'companyName': data['companyName'] ?? 'غير معروف',
          'totalCompanyDebt': (data['totalDebt'] ?? 0).toDouble(),
          'totalPaidAmount': (data['totalPaidAmount'] ?? 0).toDouble(),
          'totalRemainingAmount': 0.0, // صفر لأنها منتهية
          'status': 'منتهية',
          'isFinishedAccount':
              true, // علامة أنها من قاعدة finishedCompanyAccounts
          'finishedDocId': doc.id,
          'lastUpdated': data['lastUpdated'],
        });
      }

      // ترتيب حسب المتبقي (الحسابات النشطة أولاً) ثم المنتهية
      summariesList.sort((a, b) {
        if (a['status'] == 'منتهية' && b['status'] != 'منتهية') return 1;
        if (a['status'] != 'منتهية' && b['status'] == 'منتهية') return -1;
        return b['totalRemainingAmount'].compareTo(a['totalRemainingAmount']);
      });

      setState(() {
        _companySummaries = summariesList;
        _filteredSummaries = _applyFilters(summariesList);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('خطأ في تحميل حسابات الشركات: $e');
    }
  }

  // دالة مساعدة لمعالجة بيانات الحسابات
  Map<String, dynamic> _processSummaryData(
    Map<String, dynamic> data,
    String docId,
  ) {
    final totalCompanyDebt = (data['totalCompanyDebt'] ?? 0).toDouble();
    final totalPaidAmount = (data['totalPaidAmount'] ?? 0).toDouble();
    final totalRemainingAmount = totalCompanyDebt - totalPaidAmount;

    String status;
    if (totalRemainingAmount <= 0) {
      status = 'منتهية';
    } else if (totalPaidAmount > 0 && totalRemainingAmount > 0) {
      status = 'شبه منتهية';
    } else {
      status = 'جارية';
    }

    return {
      'companyId': data['companyId'] ?? '',
      'companyName': data['companyName'] ?? 'غير معروف',
      'totalCompanyDebt': totalCompanyDebt,
      'totalPaidAmount': totalPaidAmount,
      'totalRemainingAmount': totalRemainingAmount,
      'status': status,
      'docId': docId,
      'isFinishedAccount': false,
      'lastUpdated': data['lastUpdated'],
    };
  }

  Future<void> _createCompanySummariesFromDailyWork() async {
    try {
      final snapshot = await _firestore.collection('dailyWork').get();
      Map<String, Map<String, dynamic>> companyTotals = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final companyId = data['companyId'] as String?;
        final companyName = data['companyName'] as String?;

        if (companyId != null && companyId.isNotEmpty && companyName != null) {
          if (!companyTotals.containsKey(companyId)) {
            companyTotals[companyId] = {
              'companyId': companyId,
              'companyName': companyName,
              'totalCompanyDebt': 0.0,
              'totalPaidAmount': 0.0,
            };
          }

          final total = companyTotals[companyId]!;

          final nolon = (data['nolon'] ?? data['noLon'] ?? 0).toDouble();
          final companyOvernight = (data['companyOvernight'] ?? 0).toDouble();
          final companyHoliday = (data['companyHoliday'] ?? 0).toDouble();

          total['totalCompanyDebt'] +=
              nolon + companyOvernight + companyHoliday;
        }
      }

      final batch = _firestore.batch();
      for (var entry in companyTotals.entries) {
        final summary = entry.value;
        final companyId = entry.key;

        final docRef = _firestore.collection('companySummaries').doc(companyId);
        final existingDoc = await docRef.get();

        if (existingDoc.exists) {
          final existingData = existingDoc.data()!;
          summary['totalPaidAmount'] = existingData['totalPaidAmount'] ?? 0;
        } else {
          summary['totalPaidAmount'] = 0.0;
        }

        summary['totalRemainingAmount'] =
            summary['totalCompanyDebt'] - summary['totalPaidAmount'];

        String status;
        if (summary['totalRemainingAmount'] <= 0) {
          status = 'منتهية';
        } else if (summary['totalPaidAmount'] > 0) {
          status = 'شبه منتهية';
        } else {
          status = 'جارية';
        }

        summary['status'] = status;
        summary['lastUpdated'] = Timestamp.now();

        batch.set(docRef, summary);
      }

      await batch.commit();
      _loadCompanySummaries();
    } catch (e) {
      _showError('خطأ في إنشاء بيانات الشركات: $e');
    }
  }

  List<Map<String, dynamic>> _applyFilters(
    List<Map<String, dynamic>> summaries,
  ) {
    return summaries.where((summary) {
      if (_searchQuery.isNotEmpty) {
        if (!summary['companyName'].toLowerCase().contains(
          _searchQuery.toLowerCase(),
        )) {
          return false;
        }
      }

      // تطبيق الفلتر الزمني
      if (_timeFilter != 'الكل') {
        final timestamp = summary['lastUpdated'] as Timestamp?;
        if (timestamp == null) return false;

        final now = DateTime.now();
        final summaryDate = timestamp.toDate();

        switch (_timeFilter) {
          case 'اليوم':
            if (summaryDate.year != now.year ||
                summaryDate.month != now.month ||
                summaryDate.day != now.day) {
              return false;
            }
            break;
          case 'هذا الشهر':
            if (summaryDate.year != now.year ||
                summaryDate.month != now.month) {
              return false;
            }
            break;
          case 'هذه السنة':
            if (summaryDate.year != now.year) {
              return false;
            }
            break;
          case 'مخصص':
            if (summaryDate.year != _selectedYear ||
                summaryDate.month != _selectedMonth) {
              return false;
            }
            break;
        }
      }

      if (_statusFilter == 'جارية') {
        return summary['status'] == 'جارية';
      } else if (_statusFilter == 'شبه منتهية') {
        return summary['status'] == 'شبه منتهية';
      } else if (_statusFilter == 'منتهية') {
        return summary['status'] == 'منتهية';
      }

      return true;
    }).toList();
  }

  void _changeTimeFilter(String filter) {
    setState(() {
      _timeFilter = filter;
      _filteredSummaries = _applyFilters(_companySummaries);
    });
  }

  void _applyMonthYearFilter() {
    setState(() {
      _timeFilter = 'مخصص';
      _filteredSummaries = _applyFilters(_companySummaries);
    });
  }

  Future<void> _receivePayment(Map<String, dynamic> summary) async {
    // منع الدفع للحسابات المنتهية المخزنة في finishedCompanyAccounts
    if (summary['isFinishedAccount'] == true) {
      _showError('لا يمكن استلام دفعات لحساب منتهي');
      return;
    }

    final amountController = TextEditingController();
    final companyName = summary['companyName'];
    final companyId = summary['companyId'];
    final remainingAmount = summary['totalRemainingAmount'] as double;

    if (remainingAmount <= 0) {
      _showError('الحساب منتهي بالفعل');
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: flutter_widgets.TextDirection.rtl,
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'استلام دفعة: $companyName',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Text(
                  'المستحق: ${remainingAmount.toStringAsFixed(2)} ج',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'المبلغ المستلم',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final paymentAmount =
                              double.tryParse(amountController.text) ?? 0.0;

                          if (paymentAmount <= 0) {
                            _showError('أدخل مبلغ صحيح');
                            return;
                          }

                          if (paymentAmount > remainingAmount) {
                            _showError('المبلغ أكبر من المستحق');
                            return;
                          }

                          await _updatePayment(
                            companyId,
                            companyName,
                            paymentAmount,
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF27AE60),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'تسجيل الدفعة',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updatePayment(
    String companyId,
    String companyName,
    double paymentAmount,
  ) async {
    try {
      final docRef = _firestore.collection('companySummaries').doc(companyId);
      final doc = await docRef.get();

      if (!doc.exists) return;

      final data = doc.data()!;
      final currentPaidAmount = (data['totalPaidAmount'] ?? 0).toDouble();
      final totalCompanyDebt = (data['totalCompanyDebt'] ?? 0).toDouble();
      final newPaidAmount = currentPaidAmount + paymentAmount;
      final totalRemainingAmount = totalCompanyDebt - newPaidAmount;

      String status;
      if (totalRemainingAmount <= 0) {
        status = 'منتهية';

        // نقل الحساب إلى الحسابات المنتهية
        await _moveToFinishedAccounts(
          companyId,
          companyName,
          totalCompanyDebt, // إجمالي الدين
          newPaidAmount, // المبلغ المسدد بالكامل
        );
      } else if (newPaidAmount > 0 && totalRemainingAmount > 0) {
        status = 'شبه منتهية';
      } else {
        status = 'جارية';
      }

      await docRef.update({
        'totalPaidAmount': newPaidAmount,
        'totalRemainingAmount': totalRemainingAmount,
        'status': status,
        'lastUpdated': Timestamp.now(),
      });

      // تحديث الرحلات الفردية للشركة
      await _updateIndividualCompanyTrips(companyId, paymentAmount);
      _showSuccess('تم تسجيل الدفعة بنجاح');

      _loadCompanySummaries();
    } catch (e) {
      _showError('خطأ في تسجيل الدفعة: $e');
    }
  }

  // دالة جديدة لنقل الحسابات المنتهية
  Future<void> _moveToFinishedAccounts(
    String companyId,
    String companyName,
    double totalDebt,
    double totalPaid,
  ) async {
    try {
      final finishedRef = _firestore
          .collection('finishedCompanyAccounts')
          .doc(companyId);

      await finishedRef.set({
        'companyId': companyId,
        'companyName': companyName,
        'totalDebt': totalDebt, // إجمالي الدين
        'totalPaidAmount': totalPaid, // المبلغ المسدد بالكامل
        'lastUpdated': Timestamp.now(),
      });

      print('تم نقل حساب $companyName إلى الحسابات المنتهية');
    } catch (e) {
      print('خطأ في نقل الحساب المنتهي: $e');
    }
  }

  Future<void> _updateIndividualCompanyTrips(
    String companyId,
    double paymentAmount,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('dailyWork')
          .where('companyId', isEqualTo: companyId)
          .where('isPaid', isEqualTo: false)
          .get();

      double remainingPayment = paymentAmount;

      for (final doc in snapshot.docs) {
        if (remainingPayment <= 0) break;

        final data = doc.data();
        final nolon = (data['nolon'] ?? data['noLon'] ?? 0).toDouble();
        final companyOvernight = (data['companyOvernight'] ?? 0).toDouble();
        final companyHoliday = (data['companyHoliday'] ?? 0).toDouble();
        final currentPaid = (data['companyPaidAmount'] ?? 0).toDouble();

        final tripTotal = nolon + companyOvernight + companyHoliday;
        final tripRemaining = tripTotal - currentPaid;

        final toPay = remainingPayment > tripRemaining
            ? tripRemaining
            : remainingPayment;
        final newPaidAmount = currentPaid + toPay;
        final isFullyPaid = newPaidAmount >= tripTotal;

        await doc.reference.update({
          'companyPaidAmount': newPaidAmount,
          'isPaid': isFullyPaid,
          'remainingAmount': tripTotal - newPaidAmount,
        });

        remainingPayment -= toPay;
      }
    } catch (e) {
      print('خطأ في تحديث رحلات الشركة: $e');
    }
  }

  Future<void> _deleteFinishedAccount(String docId, String companyName) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
          'هل تريد حذف حساب الشركة "$companyName" من الحسابات المنتهية؟',
        ),
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

    if (confirm == true) {
      try {
        await _firestore
            .collection('finishedCompanyAccounts')
            .doc(docId)
            .delete();

        _showSuccess('تم حذف الحساب المنتهي');
        _loadCompanySummaries();
      } catch (e) {
        _showError('خطأ في حذف الحساب المنتهي: $e');
      }
    }
  }

  Widget _buildStatusRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatusBox('جارية', const Color(0xFFE74C3C), Icons.access_time),
          _buildStatusBox(
            'شبه منتهية',
            const Color(0xFFF39C12),
            Icons.hourglass_bottom,
          ),
          _buildStatusBox(
            'منتهية',
            const Color(0xFF27AE60),
            Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBox(String status, Color color, IconData icon) {
    final count = _companySummaries.where((s) => s['status'] == status).length;
    final isSelected = _statusFilter == status;

    return GestureDetector(
      onTap: () {
        setState(() {
          _statusFilter = status;
          _filteredSummaries = _applyFilters(_companySummaries);
        });
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 22),
            const SizedBox(height: 4),
            Text(
              status,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
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
            Icon(Icons.business, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Text(
              'حسابات الشركات',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            // الساعة الزمنية مثل صفحة السائقين
            StreamBuilder<DateTime>(
              stream: Stream.periodic(
                const Duration(seconds: 1),
                (_) => DateTime.now(),
              ),
              builder: (context, snapshot) {
                final now = snapshot.data ?? DateTime.now();
                int hour12 = now.hour % 12;
                if (hour12 == 0) hour12 = 12;
                String period = now.hour < 12 ? 'AM' : 'PM';

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

  Widget _buildTimeFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.white,
      child: Column(
        children: [
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row()),
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

  Widget _buildCompanyList() {
    if (_isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    if (_filteredSummaries.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.business, size: 50, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'لا يوجد حسابات في هذه الفئة',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _filteredSummaries.length,
        itemBuilder: (context, index) {
          return _buildCompanyItem(_filteredSummaries[index]);
        },
      ),
    );
  }

  Widget _buildCompanyItem(Map<String, dynamic> summary) {
    final companyName = summary['companyName'];
    final remainingAmount = summary['totalRemainingAmount'] as double;
    final totalPaid = summary['totalPaidAmount'] as double;
    final totalDebt = summary['totalCompanyDebt'] as double;

    final status = summary['status'];
    final isCompleted = status == 'منتهية';
    final isFinishedAccount = summary['isFinishedAccount'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted
              ? Colors.green.withOpacity(0.3)
              : const Color(0xFF3498DB).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // علامة الحساب المنتهي
          if (isCompleted && isFinishedAccount)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.green,
              ),
            ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),

                // // معلومات إضافية للحسابات المنتهية
                // if (isCompleted && isFinishedAccount)
                //   Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Text(
                //         'المبلغ الإجمالي: ${totalDebt.toStringAsFixed(2)} ج',
                //         style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                //       ),
                //       Text(
                //         'المبلغ المسدد: ${totalPaid.toStringAsFixed(2)} ج',
                //         style: TextStyle(
                //           fontSize: 11,
                //           color: Colors.green,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ],
                //   ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isCompleted && isFinishedAccount)
                Text(
                  '${totalPaid.toStringAsFixed(2)} ج',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                )
              else if (!isCompleted && remainingAmount > 0)
                Text(
                  '${remainingAmount.toStringAsFixed(2)} ج',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                )
              else
                Text(
                  '${totalPaid.toStringAsFixed(2)} ج',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.green : Colors.red,
                  ),
                ),

              if (isCompleted && isFinishedAccount)
                Text(
                  'تم التسديد',
                  style: TextStyle(fontSize: 10, color: Colors.green[700]),
                )
              else if (!isCompleted && remainingAmount > 0)
                Text(
                  'مستحق',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                )
              else
                Text(
                  'مسدد',
                  style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                ),
            ],
          ),

          const SizedBox(width: 12),

          if (!isCompleted && remainingAmount > 0)
            SizedBox(
              height: 32,
              child: ElevatedButton(
                onPressed: () => _receivePayment(summary),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27AE60),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                child: const Text('استلام', style: TextStyle(fontSize: 12)),
              ),
            )
          // else if (isCompleted && isFinishedAccount)
          // PopupMenuButton<String>(
          //   icon: Icon(Icons.more_vert, size: 20, color: Colors.grey[600]),
          //   itemBuilder: (context) => [
          //     PopupMenuItem(
          //       value: 'delete',
          //       child: Row(
          //         children: [
          //           Icon(Icons.delete, color: Colors.red),
          //           SizedBox(width: 8),
          //           Text('حذف من المنتهية'),
          //         ],
          //       ),
          //     ),
          //   ],
          //   onSelected: (value) {
          //     if (value == 'delete') {
          //       _deleteFinishedAccount(summary['finishedDocId'], companyName);
          //     }
          //   },
          // )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'منتهي',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'جارية':
        return const Color(0xFFE74C3C);
      case 'شبه منتهية':
        return const Color(0xFFF39C12);
      case 'منتهية':
        return const Color(0xFF27AE60);
      default:
        return const Color(0xFF3498DB);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildCustomAppBar(),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFDEE2E6)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[600], size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _filteredSummaries = _applyFilters(_companySummaries);
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'ابحث عن شركة...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(fontSize: 14),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildTimeFilterSection(),
          _buildStatusRow(),
          _buildCompanyList(),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     setState(() => _isLoading = true);
      //     await _createCompanySummariesFromDailyWork();
      //     setState(() => _isLoading = false);
      //     _showSuccess('تم إعادة حساب جميع حسابات الشركات');
      //   },
      //   backgroundColor: const Color(0xFF3498DB),
      //   child: Icon(Icons.refresh, color: Colors.white),
      //   tooltip: 'تحديث الحسابات',
      // ),
    );
  }
}
