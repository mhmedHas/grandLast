// // import 'dart:async';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import 'package:flutter/widgets.dart' as flutter_widgets;

// // class DriverAccountsPage extends StatefulWidget {
// //   const DriverAccountsPage({super.key});

// //   @override
// //   State<DriverAccountsPage> createState() => _DriverAccountsPageState();
// // }

// // class _DriverAccountsPageState extends State<DriverAccountsPage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   final TextEditingController _searchController = TextEditingController();

// //   // بيانات المقاولين
// //   List<Map<String, dynamic>> _contractors = [];
// //   List<Map<String, dynamic>> _filteredContractors = [];

// //   // بيانات سائقين المقاول المحدد
// //   List<Map<String, dynamic>> _driversByContractor = [];
// //   List<Map<String, dynamic>> _filteredDrivers = [];

// //   // حالات التحديد
// //   String? _selectedContractor;

// //   // حالات التحميل
// //   bool _isLoading = false;
// //   bool _isLoadingDrivers = false;

// //   // الفلاتر
// //   String _searchContractorQuery = '';
// //   String _searchDriverQuery = '';
// //   String _statusFilter = 'الكل'; // جارية، شبه منتهية، منتهية
// //   String _timeFilter = 'الكل';
// //   int _selectedMonth = DateTime.now().month;
// //   int _selectedYear = DateTime.now().year;

// //   // رصيد الخزنة
// //   double _treasuryBalance = 0.0;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadContractors();
// //     _loadTreasuryBalance();
// //   }

// //   // ---------------------------
// //   // تحميل رصيد الخزنة
// //   // ---------------------------
// //   Future<void> _loadTreasuryBalance() async {
// //     try {
// //       final incomeSnapshot = await _firestore
// //           .collection('treasury_entries')
// //           .where('isCleared', isEqualTo: true)
// //           .get();

// //       double totalIncome = 0;
// //       for (var doc in incomeSnapshot.docs) {
// //         final data = doc.data();
// //         final amount = data['amount'];
// //         if (amount != null) {
// //           totalIncome += (amount as num).toDouble();
// //         }
// //       }

// //       final expenseSnapshot = await _firestore
// //           .collection('treasury_exits')
// //           .get();

// //       double totalExpense = 0;
// //       for (var doc in expenseSnapshot.docs) {
// //         final data = doc.data();
// //         final amount = data['amount'];
// //         if (amount != null) {
// //           totalExpense += (amount as num).toDouble();
// //         }
// //       }

// //       setState(() {
// //         _treasuryBalance = totalIncome - totalExpense;
// //       });
// //     } catch (e) {
// //       print('Error loading treasury balance: $e');
// //     }
// //   }

// //   // ---------------------------
// //   // إضافة مصروف للخزنة
// //   // ---------------------------
// //   Future<void> _addExpenseToTreasury({
// //     required String recipientName,
// //     required double amount,
// //     required String paymentType, // 'سائق' أو 'مقاول'
// //     required String paymentMethod, // 'كامل' أو 'جزئي'
// //     required String? contractorName,
// //     required String? driverName,
// //   }) async {
// //     try {
// //       // إنشاء وصف واضح
// //       String description = '';
// //       String expenseType = '';

// //       if (paymentType == 'سائق') {
// //         expenseType = 'حساب سواق';
// //         description = 'حساب السائق $driverName - المقاول $contractorName';
// //       } else {
// //         expenseType = 'حساب مقاول';
// //         description = 'حساب المقاول $recipientName';
// //       }

// //       // إضافة "كامل" أو "جزئي" للوصف
// //       description += ' ($paymentMethod)';

// //       final expenseData = {
// //         'amount': amount,
// //         'expenseType': expenseType,
// //         'description': description,
// //         'recipient': recipientName,
// //         'date': Timestamp.now(),
// //         'createdAt': Timestamp.now(),
// //         'category': 'خرج',
// //         'status': 'مكتمل',
// //         'paymentMethod': paymentMethod,
// //         'paymentFor': paymentType,
// //         'contractorName': contractorName,
// //         'driverName': driverName,
// //         'timestamp': Timestamp.now(),
// //       };

// //       await _firestore.collection('treasury_exits').add(expenseData);

// //       // تحديث رصيد الخزنة
// //       setState(() {
// //         _treasuryBalance -= amount;
// //       });

// //       return;
// //     } catch (e) {
// //       print('Error adding expense to treasury: $e');
// //       throw e;
// //     }
// //   }

// //   // ---------------------------
// //   // تحميل قائمة المقاولين مع إجمالياتهم
// //   // ---------------------------
// //   Future<void> _loadContractors() async {
// //     setState(() => _isLoading = true);

// //     try {
// //       // جلب جميع بيانات السائقين
// //       final snapshot = await _firestore.collection('drivers').get();

// //       // تجميع البيانات حسب المقاول
// //       Map<String, Map<String, dynamic>> contractorsMap = {};

// //       for (final doc in snapshot.docs) {
// //         final data = doc.data() as Map<String, dynamic>?;
// //         if (data == null) continue;

// //         final contractor = (data['contractor'] ?? '').toString().trim();
// //         if (contractor.isEmpty) continue;

// //         if (!contractorsMap.containsKey(contractor)) {
// //           contractorsMap[contractor] = {
// //             'contractorName': contractor,
// //             'totalWheelNolon': 0.0,
// //             'totalPaidAmount': 0.0,
// //             'totalRemainingAmount': 0.0,
// //             'totalDrivers': 0,
// //             'activeDrivers': 0,
// //             'finishedDrivers': 0,
// //             'lastUpdated': null,
// //           };
// //         }

// //         final contractorData = contractorsMap[contractor]!;

// //         // إضافة أرقام السائق
// //         contractorData['totalDrivers'] = contractorData['totalDrivers']! + 1;

// //         // إضافة النولون
// //         final wheelNolon = (data['wheelNolon'] ?? 0).toDouble();
// //         final wheelOvernight = (data['wheelOvernight'] ?? 0).toDouble();
// //         final wheelHoliday = (data['wheelHoliday'] ?? 0).toDouble();
// //         final paidAmount = (data['paidAmount'] ?? 0).toDouble();

// //         contractorData['totalWheelNolon'] =
// //             contractorData['totalWheelNolon']! +
// //             wheelNolon +
// //             wheelOvernight +
// //             wheelHoliday;
// //         contractorData['totalPaidAmount'] =
// //             contractorData['totalPaidAmount']! + paidAmount;

// //         // تحديث حالة السائقين
// //         final remaining =
// //             (wheelNolon + wheelOvernight + wheelHoliday) - paidAmount;
// //         if (remaining <= 0) {
// //           contractorData['finishedDrivers'] =
// //               contractorData['finishedDrivers']! + 1;
// //         } else {
// //           contractorData['activeDrivers'] =
// //               contractorData['activeDrivers']! + 1;
// //         }

// //         // تاريخ آخر تحديث
// //         final tripDate = (data['date'] as Timestamp?)?.toDate();
// //         if (tripDate != null) {
// //           if (contractorData['lastUpdated'] == null ||
// //               tripDate.isAfter(contractorData['lastUpdated'])) {
// //             contractorData['lastUpdated'] = tripDate;
// //           }
// //         }
// //       }

// //       // حساب الإجماليات النهائية
// //       for (var contractor in contractorsMap.values) {
// //         final totalWheelNolon = contractor['totalWheelNolon']!;
// //         final totalPaidAmount = contractor['totalPaidAmount']!;
// //         contractor['totalRemainingAmount'] = totalWheelNolon - totalPaidAmount;
// //       }

// //       // تحويل إلى قائمة وترتيب
// //       List<Map<String, dynamic>> contractorsList = contractorsMap.values
// //           .toList();
// //       contractorsList.sort(
// //         (a, b) => a['contractorName'].compareTo(b['contractorName']),
// //       );

// //       setState(() {
// //         _contractors = contractorsList;
// //         _filteredContractors = _applyContractorFilters(contractorsList);
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() => _isLoading = false);
// //       _showError('خطأ في تحميل المقاولين: $e');
// //     }
// //   }

// //   // ---------------------------
// //   // تحميل السائقين التابعين لمقاول مع حساب كل سائق
// //   // ---------------------------
// //   Future<void> _loadContractorDrivers(String contractorName) async {
// //     if (contractorName.isEmpty) return;

// //     setState(() {
// //       _selectedContractor = contractorName;
// //       _isLoadingDrivers = true;
// //       _driversByContractor.clear();
// //       _filteredDrivers.clear();
// //     });

// //     try {
// //       final snapshot = await _firestore
// //           .collection('drivers')
// //           .where('contractor', isEqualTo: contractorName)
// //           .get();

// //       // تجميع السائقين الفريدين مع حساب كل سائق
// //       Map<String, Map<String, dynamic>> driversMap = {};

// //       for (final doc in snapshot.docs) {
// //         final data = doc.data() as Map<String, dynamic>?;
// //         if (data == null) continue;

// //         final driverName = (data['driverName'] ?? '').toString().trim();
// //         if (driverName.isEmpty) continue;

// //         if (!driversMap.containsKey(driverName)) {
// //           driversMap[driverName] = {
// //             'driverName': driverName,
// //             'contractor': contractorName,
// //             'totalWheelNolon': 0.0,
// //             'totalPaidAmount': 0.0,
// //             'totalRemainingAmount': 0.0,
// //             'totalTrips': 0,
// //             'lastTripDate': null,
// //           };
// //         }

// //         final driverData = driversMap[driverName]!;

// //         // تحديث الإحصائيات
// //         driverData['totalTrips'] = driverData['totalTrips']! + 1;

// //         // إضافة النولون
// //         final wheelNolon = (data['wheelNolon'] ?? 0).toDouble();
// //         final wheelOvernight = (data['wheelOvernight'] ?? 0).toDouble();
// //         final wheelHoliday = (data['wheelHoliday'] ?? 0).toDouble();
// //         final paidAmount = (data['paidAmount'] ?? 0).toDouble();

// //         driverData['totalWheelNolon'] =
// //             driverData['totalWheelNolon']! +
// //             wheelNolon +
// //             wheelOvernight +
// //             wheelHoliday;
// //         driverData['totalPaidAmount'] =
// //             driverData['totalPaidAmount']! + paidAmount;

// //         // تاريخ آخر رحلة
// //         final tripDate = (data['date'] as Timestamp?)?.toDate();
// //         if (tripDate != null) {
// //           if (driverData['lastTripDate'] == null ||
// //               tripDate.isAfter(driverData['lastTripDate'])) {
// //             driverData['lastTripDate'] = tripDate;
// //           }
// //         }
// //       }

// //       // حساب الإجماليات النهائية وتحديد الحالة
// //       for (var driver in driversMap.values) {
// //         final totalWheelNolon = driver['totalWheelNolon']!;
// //         final totalPaidAmount = driver['totalPaidAmount']!;
// //         final totalRemainingAmount = totalWheelNolon - totalPaidAmount;

// //         driver['totalRemainingAmount'] = totalRemainingAmount;

// //         // تحديد حالة الحساب
// //         String status;
// //         if (totalRemainingAmount <= 0) {
// //           status = 'منتهية';
// //         } else if (totalPaidAmount > 0 && totalRemainingAmount > 0) {
// //           status = 'شبه منتهية';
// //         } else {
// //           status = 'جارية';
// //         }

// //         driver['status'] = status;
// //       }

// //       // تحويل القائمة وترتيب
// //       List<Map<String, dynamic>> driversList = driversMap.values.toList();
// //       driversList.sort(
// //         (a, b) =>
// //             b['totalRemainingAmount'].compareTo(a['totalRemainingAmount']),
// //       );

// //       setState(() {
// //         _driversByContractor = driversList;
// //         _filteredDrivers = _applyDriverFilters(driversList);
// //         _isLoadingDrivers = false;
// //       });
// //     } catch (e) {
// //       setState(() => _isLoadingDrivers = false);
// //       _showError('خطأ في تحميل السائقين: $e');
// //     }
// //   }

// //   // ---------------------------
// //   // سداد حساب مقاول (كامل أو جزئي)
// //   // ---------------------------
// //   Future<void> _payContractor(Map<String, dynamic> contractor) async {
// //     final amountController = TextEditingController();
// //     final contractorName = contractor['contractorName'];
// //     final remainingAmount = contractor['totalRemainingAmount'] as double;
// //     String paymentType = 'كامل'; // القيمة الافتراضية

// //     if (remainingAmount <= 0) {
// //       _showError('حساب المقاول منتهي بالفعل');
// //       return;
// //     }

// //     // حساب مبالغ سائقي المقاول
// //     double driversRemaining = 0;
// //     double driversPaid = 0;

// //     try {
// //       final driversSnapshot = await _firestore
// //           .collection('drivers')
// //           .where('contractor', isEqualTo: contractorName)
// //           .get();

// //       for (final doc in driversSnapshot.docs) {
// //         final data = doc.data() as Map<String, dynamic>?;
// //         if (data == null) continue;

// //         final wheelNolon = (data['wheelNolon'] ?? 0).toDouble();
// //         final wheelOvernight = (data['wheelOvernight'] ?? 0).toDouble();
// //         final wheelHoliday = (data['wheelHoliday'] ?? 0).toDouble();
// //         final paidAmount = (data['paidAmount'] ?? 0).toDouble();

// //         final totalWheelNolon = wheelNolon + wheelOvernight + wheelHoliday;
// //         driversRemaining += (totalWheelNolon - paidAmount);
// //         driversPaid += paidAmount;
// //       }
// //     } catch (e) {
// //       print('Error calculating drivers amounts: $e');
// //     }

// //     await showDialog(
// //       context: context,
// //       builder: (context) => Directionality(
// //         textDirection: flutter_widgets.TextDirection.rtl,
// //         child: StatefulBuilder(
// //           builder: (context, setState) {
// //             return Dialog(
// //               backgroundColor: Colors.white,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //               child: Container(
// //                 padding: const EdgeInsets.all(16),
// //                 child: Column(
// //                   mainAxisSize: MainAxisSize.min,
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     // Header
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       children: [
// //                         Text(
// //                           'سداد مقاول: $contractorName',
// //                           style: const TextStyle(
// //                             fontSize: 16,
// //                             fontWeight: FontWeight.bold,
// //                             color: Color(0xFF2C3E50),
// //                           ),
// //                         ),
// //                         IconButton(
// //                           icon: const Icon(Icons.close, size: 18),
// //                           onPressed: () => Navigator.pop(context),
// //                           padding: EdgeInsets.zero,
// //                         ),
// //                       ],
// //                     ),
// //                     const SizedBox(height: 8),
// //                     const Divider(height: 1),
// //                     const SizedBox(height: 12),

// //                     // رصيد الخزنة
// //                     Container(
// //                       padding: EdgeInsets.all(12),
// //                       decoration: BoxDecoration(
// //                         color: Colors.blue[50],
// //                         borderRadius: BorderRadius.circular(8),
// //                         border: Border.all(color: Colors.blue[200]!),
// //                       ),
// //                       child: Row(
// //                         children: [
// //                           Icon(
// //                             Icons.account_balance_wallet,
// //                             color: _treasuryBalance < remainingAmount
// //                                 ? Colors.red
// //                                 : Colors.blue,
// //                           ),
// //                           SizedBox(width: 8),
// //                           Expanded(
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Text(
// //                                   'رصيد الخزنة الحالي',
// //                                   style: TextStyle(
// //                                     fontSize: 12,
// //                                     color: Colors.grey[600],
// //                                   ),
// //                                 ),
// //                                 Text(
// //                                   '${_treasuryBalance.toStringAsFixed(2)} ج',
// //                                   style: TextStyle(
// //                                     fontSize: 16,
// //                                     fontWeight: FontWeight.bold,
// //                                     color: _treasuryBalance < remainingAmount
// //                                         ? Colors.red
// //                                         : Colors.blue,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     SizedBox(height: 12),

// //                     // إحصائيات المقاول
// //                     Container(
// //                       padding: EdgeInsets.all(12),
// //                       decoration: BoxDecoration(
// //                         color: Colors.grey[50],
// //                         borderRadius: BorderRadius.circular(8),
// //                         border: Border.all(color: Colors.grey[300]!),
// //                       ),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               Text('العدد الكلي للسائقين:'),
// //                               Text(
// //                                 '${contractor['totalDrivers']}',
// //                                 style: TextStyle(fontWeight: FontWeight.bold),
// //                               ),
// //                             ],
// //                           ),
// //                           SizedBox(height: 4),
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               Text('السائقين النشطين:'),
// //                               Text(
// //                                 '${contractor['activeDrivers']}',
// //                                 style: TextStyle(
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Colors.orange,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                           SizedBox(height: 4),
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               Text('إجمالي مدفوعات السائقين:'),
// //                               Text(
// //                                 '${driversPaid.toStringAsFixed(2)} ج',
// //                                 style: TextStyle(
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Colors.green,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                           SizedBox(height: 4),
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               Text('إجمالي متبقي السائقين:'),
// //                               Text(
// //                                 '${driversRemaining.toStringAsFixed(2)} ج',
// //                                 style: TextStyle(
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Colors.red,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     SizedBox(height: 12),

// //                     // المبلغ المتبقي
// //                     Container(
// //                       padding: EdgeInsets.all(12),
// //                       decoration: BoxDecoration(
// //                         color: Colors.orange[50],
// //                         borderRadius: BorderRadius.circular(8),
// //                         border: Border.all(color: Colors.orange[200]!),
// //                       ),
// //                       child: Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Text(
// //                             'المبلغ المستحق للمقاول:',
// //                             style: TextStyle(fontWeight: FontWeight.bold),
// //                           ),
// //                           Text(
// //                             '${remainingAmount.toStringAsFixed(2)} ج',
// //                             style: TextStyle(
// //                               fontSize: 18,
// //                               color: Colors.red,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     SizedBox(height: 16),

// //                     // نوع الدفع - مبدئي كامل
// //                     if (remainingAmount > 0)
// //                       Row(
// //                         mainAxisAlignment: MainAxisAlignment.start,
// //                         children: [
// //                           ChoiceChip(
// //                             label: Text('دفع كامل'),
// //                             selected: paymentType == 'كامل',
// //                             onSelected: (selected) {
// //                               if (selected) {
// //                                 setState(() {
// //                                   paymentType = 'كامل';
// //                                   amountController.text = remainingAmount
// //                                       .toStringAsFixed(2);
// //                                 });
// //                               }
// //                             },
// //                             selectedColor: Colors.green,
// //                             labelStyle: TextStyle(
// //                               color: paymentType == 'كامل'
// //                                   ? Colors.white
// //                                   : Colors.green,
// //                             ),
// //                           ),
// //                           SizedBox(width: 15),
// //                           ChoiceChip(
// //                             label: Text('دفع جزئي'),
// //                             selected: paymentType == 'جزئي',
// //                             onSelected: (selected) {
// //                               if (selected) {
// //                                 setState(() {
// //                                   paymentType = 'جزئي';
// //                                   amountController.clear();
// //                                 });
// //                               }
// //                             },
// //                             selectedColor: Colors.blue,
// //                             labelStyle: TextStyle(
// //                               color: paymentType == 'جزئي'
// //                                   ? Colors.white
// //                                   : Colors.blue,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     SizedBox(height: 16),

// //                     // حقل المبلغ
// //                     TextFormField(
// //                       controller: amountController,
// //                       keyboardType: TextInputType.number,
// //                       decoration: InputDecoration(
// //                         labelText: paymentType == 'كامل'
// //                             ? 'المبلغ الكامل'
// //                             : 'المبلغ المطلوب دفعه',
// //                         border: OutlineInputBorder(
// //                           borderRadius: BorderRadius.circular(8),
// //                         ),
// //                         contentPadding: const EdgeInsets.symmetric(
// //                           horizontal: 12,
// //                           vertical: 10,
// //                         ),
// //                         prefixIcon: Icon(Icons.attach_money),
// //                       ),
// //                     ),
// //                     SizedBox(height: 20),

// //                     // زر السداد
// //                     Row(
// //                       children: [
// //                         Expanded(
// //                           child: OutlinedButton(
// //                             onPressed: () => Navigator.pop(context),
// //                             style: OutlinedButton.styleFrom(
// //                               padding: const EdgeInsets.symmetric(vertical: 10),
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(8),
// //                               ),
// //                             ),
// //                             child: const Text(
// //                               'إلغاء',
// //                               style: TextStyle(fontSize: 14),
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(width: 8),
// //                         Expanded(
// //                           child: ElevatedButton(
// //                             onPressed: () async {
// //                               final paymentAmount =
// //                                   double.tryParse(amountController.text) ?? 0.0;

// //                               if (paymentAmount <= 0) {
// //                                 _showError('أدخل مبلغ صحيح');
// //                                 return;
// //                               }

// //                               if (paymentAmount > remainingAmount) {
// //                                 _showError('المبلغ أكبر من المستحق');
// //                                 return;
// //                               }

// //                               if (paymentAmount > _treasuryBalance) {
// //                                 _showError(
// //                                   'المبلغ أكبر من الرصيد المتاح في الخزنة',
// //                                 );
// //                                 return;
// //                               }

// //                               // تحديد نوع الدفع بناءً على المبلغ
// //                               final actualPaymentType =
// //                                   paymentAmount == remainingAmount
// //                                   ? 'كامل'
// //                                   : 'جزئي';

// //                               // عرض تأكيد السداد
// //                               final confirmed = await _showPaymentConfirmation(
// //                                 recipientName: contractorName,
// //                                 amount: paymentAmount,
// //                                 paymentMethod: actualPaymentType,
// //                                 paymentFor: 'مقاول',
// //                               );

// //                               if (!confirmed) return;

// //                               await _updateContractorPayment(
// //                                 contractorName,
// //                                 paymentAmount,
// //                                 actualPaymentType,
// //                               );
// //                               Navigator.pop(context);
// //                             },
// //                             style: ElevatedButton.styleFrom(
// //                               backgroundColor: const Color(0xFF27AE60),
// //                               foregroundColor: Colors.white,
// //                               padding: const EdgeInsets.symmetric(vertical: 10),
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(8),
// //                               ),
// //                             ),
// //                             child: Text(
// //                               paymentType == 'كامل' ? 'سداد كامل' : 'سداد جزئي',
// //                               style: TextStyle(fontSize: 14),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }

// //   // ---------------------------
// //   // سداد حساب سائق
// //   // ---------------------------
// //   Future<void> _makePayment(Map<String, dynamic> driver) async {
// //     final amountController = TextEditingController();
// //     final driverName = driver['driverName'];
// //     final contractorName = driver['contractor'];
// //     final remainingAmount = driver['totalRemainingAmount'] as double;
// //     String paymentType = 'كامل'; // القيمة الافتراضية

// //     if (remainingAmount <= 0) {
// //       _showError('الحساب منتهي بالفعل');
// //       return;
// //     }

// //     await showDialog(
// //       context: context,
// //       builder: (context) => Directionality(
// //         textDirection: flutter_widgets.TextDirection.rtl,
// //         child: StatefulBuilder(
// //           builder: (context, setState) {
// //             return Dialog(
// //               backgroundColor: Colors.white,
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //               child: Container(
// //                 padding: const EdgeInsets.all(16),
// //                 child: Column(
// //                   mainAxisSize: MainAxisSize.min,
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     // Header
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       children: [
// //                         Text(
// //                           'سداد سائق: $driverName',
// //                           style: const TextStyle(
// //                             fontSize: 16,
// //                             fontWeight: FontWeight.bold,
// //                             color: Color(0xFF2C3E50),
// //                           ),
// //                         ),
// //                         IconButton(
// //                           icon: const Icon(Icons.close, size: 18),
// //                           onPressed: () => Navigator.pop(context),
// //                           padding: EdgeInsets.zero,
// //                         ),
// //                       ],
// //                     ),
// //                     const SizedBox(height: 8),
// //                     const Divider(height: 1),
// //                     const SizedBox(height: 12),

// //                     // رصيد الخزنة
// //                     Container(
// //                       padding: EdgeInsets.all(12),
// //                       decoration: BoxDecoration(
// //                         color: Colors.blue[50],
// //                         borderRadius: BorderRadius.circular(8),
// //                         border: Border.all(color: Colors.blue[200]!),
// //                       ),
// //                       child: Row(
// //                         children: [
// //                           Icon(
// //                             Icons.account_balance_wallet,
// //                             color: _treasuryBalance < remainingAmount
// //                                 ? Colors.red
// //                                 : Colors.blue,
// //                           ),
// //                           SizedBox(width: 8),
// //                           Expanded(
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Text(
// //                                   'رصيد الخزنة الحالي',
// //                                   style: TextStyle(
// //                                     fontSize: 12,
// //                                     color: Colors.grey[600],
// //                                   ),
// //                                 ),
// //                                 Text(
// //                                   '${_treasuryBalance.toStringAsFixed(2)} ج',
// //                                   style: TextStyle(
// //                                     fontSize: 16,
// //                                     fontWeight: FontWeight.bold,
// //                                     color: _treasuryBalance < remainingAmount
// //                                         ? Colors.red
// //                                         : Colors.blue,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     SizedBox(height: 12),

// //                     // معلومات السائق
// //                     Container(
// //                       padding: EdgeInsets.all(12),
// //                       decoration: BoxDecoration(
// //                         color: Colors.grey[50],
// //                         borderRadius: BorderRadius.circular(8),
// //                         border: Border.all(color: Colors.grey[300]!),
// //                       ),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               Text('المقاول:'),
// //                               Text(
// //                                 contractorName,
// //                                 style: TextStyle(fontWeight: FontWeight.bold),
// //                               ),
// //                             ],
// //                           ),
// //                           SizedBox(height: 4),
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               Text('عدد الرحلات:'),
// //                               Text(
// //                                 '${driver['totalTrips']}',
// //                                 style: TextStyle(fontWeight: FontWeight.bold),
// //                               ),
// //                             ],
// //                           ),
// //                           SizedBox(height: 4),
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               Text('المدفوع:'),
// //                               Text(
// //                                 '${driver['totalPaidAmount'].toStringAsFixed(2)} ج',
// //                                 style: TextStyle(
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Colors.green,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     SizedBox(height: 12),

// //                     // المبلغ المتبقي
// //                     Container(
// //                       padding: EdgeInsets.all(12),
// //                       decoration: BoxDecoration(
// //                         color: Colors.orange[50],
// //                         borderRadius: BorderRadius.circular(8),
// //                         border: Border.all(color: Colors.orange[200]!),
// //                       ),
// //                       child: Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Text(
// //                             'المبلغ المستحق للسائق:',
// //                             style: TextStyle(fontWeight: FontWeight.bold),
// //                           ),
// //                           Text(
// //                             '${remainingAmount.toStringAsFixed(2)} ج',
// //                             style: TextStyle(
// //                               fontSize: 18,
// //                               color: Colors.red,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     SizedBox(height: 16),

// //                     // نوع الدفع
// //                     Row(
// //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                       children: [
// //                         ChoiceChip(
// //                           label: Text('دفع كامل'),
// //                           selected: paymentType == 'كامل',
// //                           onSelected: (selected) {
// //                             if (selected) {
// //                               setState(() {
// //                                 paymentType = 'كامل';
// //                                 amountController.text = remainingAmount
// //                                     .toStringAsFixed(2);
// //                               });
// //                             }
// //                           },
// //                           selectedColor: Colors.green,
// //                           labelStyle: TextStyle(
// //                             color: paymentType == 'كامل'
// //                                 ? Colors.white
// //                                 : Colors.green,
// //                           ),
// //                         ),
// //                         ChoiceChip(
// //                           label: Text('دفع جزئي'),
// //                           selected: paymentType == 'جزئي',
// //                           onSelected: (selected) {
// //                             if (selected) {
// //                               setState(() {
// //                                 paymentType = 'جزئي';
// //                                 amountController.clear();
// //                               });
// //                             }
// //                           },
// //                           selectedColor: Colors.blue,
// //                           labelStyle: TextStyle(
// //                             color: paymentType == 'جزئي'
// //                                 ? Colors.white
// //                                 : Colors.blue,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                     SizedBox(height: 16),

// //                     // حقل المبلغ
// //                     TextFormField(
// //                       controller: amountController,
// //                       keyboardType: TextInputType.number,
// //                       decoration: InputDecoration(
// //                         labelText: paymentType == 'كامل'
// //                             ? 'المبلغ الكامل'
// //                             : 'المبلغ المطلوب دفعه',
// //                         border: OutlineInputBorder(
// //                           borderRadius: BorderRadius.circular(8),
// //                         ),
// //                         contentPadding: const EdgeInsets.symmetric(
// //                           horizontal: 12,
// //                           vertical: 10,
// //                         ),
// //                         prefixIcon: Icon(Icons.attach_money),
// //                       ),
// //                     ),
// //                     SizedBox(height: 20),

// //                     // زر السداد
// //                     Row(
// //                       children: [
// //                         Expanded(
// //                           child: OutlinedButton(
// //                             onPressed: () => Navigator.pop(context),
// //                             style: OutlinedButton.styleFrom(
// //                               padding: const EdgeInsets.symmetric(vertical: 10),
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(8),
// //                               ),
// //                             ),
// //                             child: const Text(
// //                               'إلغاء',
// //                               style: TextStyle(fontSize: 14),
// //                             ),
// //                           ),
// //                         ),
// //                         const SizedBox(width: 8),
// //                         Expanded(
// //                           child: ElevatedButton(
// //                             onPressed: () async {
// //                               final paymentAmount =
// //                                   double.tryParse(amountController.text) ?? 0.0;

// //                               if (paymentAmount <= 0) {
// //                                 _showError('أدخل مبلغ صحيح');
// //                                 return;
// //                               }

// //                               if (paymentAmount > remainingAmount) {
// //                                 _showError('المبلغ أكبر من المستحق');
// //                                 return;
// //                               }

// //                               if (paymentAmount > _treasuryBalance) {
// //                                 _showError(
// //                                   'المبلغ أكبر من الرصيد المتاح في الخزنة',
// //                                 );
// //                                 return;
// //                               }

// //                               // تحديد نوع الدفع بناءً على المبلغ
// //                               final actualPaymentType =
// //                                   paymentAmount == remainingAmount
// //                                   ? 'كامل'
// //                                   : 'جزئي';

// //                               // عرض تأكيد السداد
// //                               final confirmed = await _showPaymentConfirmation(
// //                                 recipientName: driverName,
// //                                 amount: paymentAmount,
// //                                 paymentMethod: actualPaymentType,
// //                                 paymentFor: 'سائق',
// //                                 contractorName: contractorName,
// //                               );

// //                               if (!confirmed) return;

// //                               await _updateDriverPayment(
// //                                 driverName,
// //                                 paymentAmount,
// //                                 actualPaymentType,
// //                               );
// //                               Navigator.pop(context);
// //                             },
// //                             style: ElevatedButton.styleFrom(
// //                               backgroundColor: const Color(0xFF27AE60),
// //                               foregroundColor: Colors.white,
// //                               padding: const EdgeInsets.symmetric(vertical: 10),
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(8),
// //                               ),
// //                             ),
// //                             child: Text(
// //                               paymentType == 'كامل' ? 'سداد كامل' : 'سداد جزئي',
// //                               style: TextStyle(fontSize: 14),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }

// //   // ---------------------------
// //   // تأكيد الدفع
// //   // ---------------------------
// //   Future<bool> _showPaymentConfirmation({
// //     required String recipientName,
// //     required double amount,
// //     required String paymentMethod,
// //     required String paymentFor, // 'سائق' أو 'مقاول'
// //     String? contractorName,
// //   }) async {
// //     bool confirmed = false;

// //     String paymentForText = paymentFor == 'سائق' ? 'سائق' : 'مقاول';
// //     String description = paymentFor == 'سائق'
// //         ? 'سائق $recipientName - المقاول $contractorName'
// //         : 'مقاول $recipientName';

// //     await showDialog(
// //       context: context,
// //       builder: (context) => Directionality(
// //         textDirection: flutter_widgets.TextDirection.rtl,
// //         child: AlertDialog(
// //           title: Row(
// //             children: [
// //               Icon(Icons.payment, color: Colors.orange),
// //               SizedBox(width: 8),
// //               Text('تأكيد الدفع ($paymentMethod)'),
// //             ],
// //           ),
// //           content: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Text('هل أنت متأكد من دفع ${amount.toStringAsFixed(2)} ج'),
// //               Text('لـ$paymentForText $recipientName؟'),
// //               SizedBox(height: 8),
// //               Container(
// //                 padding: EdgeInsets.all(12),
// //                 decoration: BoxDecoration(
// //                   color: paymentMethod == 'كامل'
// //                       ? Colors.green[50]
// //                       : Colors.blue[50],
// //                   borderRadius: BorderRadius.circular(8),
// //                 ),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Row(
// //                       children: [
// //                         Icon(
// //                           paymentMethod == 'كامل'
// //                               ? Icons.check_circle
// //                               : Icons.payment,
// //                           color: paymentMethod == 'كامل'
// //                               ? Colors.green
// //                               : Colors.blue,
// //                           size: 18,
// //                         ),
// //                         SizedBox(width: 8),
// //                         Text(
// //                           'تفاصيل الدفع ($paymentMethod)',
// //                           style: TextStyle(
// //                             fontWeight: FontWeight.bold,
// //                             color: paymentMethod == 'كامل'
// //                                 ? Colors.green[800]
// //                                 : Colors.blue[800],
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                     SizedBox(height: 8),
// //                     Text('النوع: $paymentForText'),
// //                     Text('الاسم: $description'),
// //                     Text('المبلغ: ${amount.toStringAsFixed(2)} ج'),
// //                     Text('طريقة الدفع: $paymentMethod'),
// //                     Text(
// //                       'التاريخ: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}',
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               SizedBox(height: 12),
// //               Container(
// //                 padding: EdgeInsets.all(12),
// //                 decoration: BoxDecoration(
// //                   color: Colors.orange[50],
// //                   borderRadius: BorderRadius.circular(8),
// //                 ),
// //                 child: Text(
// //                   'سيتم خصم المبلغ من الخزنة تلقائياً',
// //                   style: TextStyle(color: Colors.orange[800]),
// //                 ),
// //               ),
// //             ],
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.pop(context),
// //               child: Text('إلغاء'),
// //             ),
// //             ElevatedButton(
// //               onPressed: () {
// //                 confirmed = true;
// //                 Navigator.pop(context);
// //               },
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: paymentMethod == 'كامل'
// //                     ? Colors.green
// //                     : Colors.blue,
// //               ),
// //               child: Text('تأكيد الدفع ($paymentMethod)'),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );

// //     return confirmed;
// //   }

// //   // ---------------------------
// //   // تحديث دفع المقاول
// //   // ---------------------------
// //   Future<void> _updateContractorPayment(
// //     String contractorName,
// //     double paymentAmount,
// //     String paymentMethod,
// //   ) async {
// //     try {
// //       // 1. تحديث رحلات سائقي المقاول
// //       await _updateContractorDriverTrips(contractorName, paymentAmount);

// //       // 2. إضافة المصروف للخزنة
// //       await _addExpenseToTreasury(
// //         recipientName: contractorName,
// //         amount: paymentAmount,
// //         paymentType: 'مقاول',
// //         paymentMethod: paymentMethod,
// //         contractorName: contractorName,
// //         driverName: null,
// //       );

// //       // 3. إعادة تحميل البيانات
// //       await _loadContractors();
// //       if (_selectedContractor != null) {
// //         await _loadContractorDrivers(_selectedContractor!);
// //       }

// //       _showSuccess(
// //         'تم سداد ${paymentAmount.toStringAsFixed(2)} ج للمقاول $contractorName ($paymentMethod)',
// //       );
// //     } catch (e) {
// //       _showError('خطأ في السداد: $e');
// //     }
// //   }

// //   // ---------------------------
// //   // تحديث رحلات سائقي المقاول
// //   // ---------------------------
// //   Future<void> _updateContractorDriverTrips(
// //     String contractorName,
// //     double paymentAmount,
// //   ) async {
// //     try {
// //       // جلب جميع رحلات سائقي المقاول
// //       final snapshot = await _firestore
// //           .collection('drivers')
// //           .where('contractor', isEqualTo: contractorName)
// //           .get();

// //       double remainingPayment = paymentAmount;

// //       // توزيع المبلغ على رحلات السائقين حسب المستحق
// //       List<Map<String, dynamic>> tripsWithRemaining = [];

// //       for (final doc in snapshot.docs) {
// //         final data = doc.data() as Map<String, dynamic>?;
// //         if (data == null) continue;

// //         final wheelNolon = (data['wheelNolon'] ?? 0).toDouble();
// //         final wheelOvernight = (data['wheelOvernight'] ?? 0).toDouble();
// //         final wheelHoliday = (data['wheelHoliday'] ?? 0).toDouble();
// //         final currentPaid = (data['paidAmount'] ?? 0).toDouble();

// //         final tripTotal = wheelNolon + wheelOvernight + wheelHoliday;
// //         final tripRemaining = tripTotal - currentPaid;

// //         if (tripRemaining > 0) {
// //           tripsWithRemaining.add({'doc': doc, 'remaining': tripRemaining});
// //         }
// //       }

// //       // توزيع المدفوعات بالتساوي على الرحلات
// //       for (var trip in tripsWithRemaining) {
// //         if (remainingPayment <= 0) break;

// //         final doc = trip['doc'] as QueryDocumentSnapshot;
// //         final tripRemaining = trip['remaining'] as double;
// //         final data = doc.data() as Map<String, dynamic>?;
// //         if (data == null) continue;

// //         final wheelNolon = (data['wheelNolon'] ?? 0).toDouble();
// //         final wheelOvernight = (data['wheelOvernight'] ?? 0).toDouble();
// //         final wheelHoliday = (data['wheelHoliday'] ?? 0).toDouble();
// //         final currentPaid = (data['paidAmount'] ?? 0).toDouble();

// //         final tripTotal = wheelNolon + wheelOvernight + wheelHoliday;
// //         final toPay = remainingPayment > tripRemaining
// //             ? tripRemaining
// //             : remainingPayment;
// //         final newPaidAmount = currentPaid + toPay;
// //         final isFullyPaid = newPaidAmount >= tripTotal;

// //         await doc.reference.update({
// //           'paidAmount': newPaidAmount,
// //           'isPaid': isFullyPaid,
// //           'remainingAmount': tripTotal - newPaidAmount,
// //         });

// //         remainingPayment -= toPay;
// //       }
// //     } catch (e) {
// //       print('خطأ في تحديث رحلات سائقي المقاول: $e');
// //     }
// //   }

// //   // ---------------------------
// //   // تحديث دفع السائق
// //   // ---------------------------
// //   Future<void> _updateDriverPayment(
// //     String driverName,
// //     double paymentAmount,
// //     String paymentMethod,
// //   ) async {
// //     try {
// //       // 1. تحديث رحلات السائق الفردية
// //       await _updateIndividualDriverTrips(driverName, paymentAmount);

// //       // 2. إضافة المصروف للخزنة
// //       await _addExpenseToTreasury(
// //         recipientName: driverName,
// //         amount: paymentAmount,
// //         paymentType: 'سائق',
// //         paymentMethod: paymentMethod,
// //         contractorName: _selectedContractor,
// //         driverName: driverName,
// //       );

// //       // 3. إعادة تحميل بيانات السائقين بعد السداد
// //       await _loadContractorDrivers(_selectedContractor!);

// //       _showSuccess(
// //         'تم سداد ${paymentAmount.toStringAsFixed(2)} ج للسائق $driverName ($paymentMethod)',
// //       );
// //     } catch (e) {
// //       _showError('خطأ في السداد: $e');
// //     }
// //   }

// //   // ---------------------------
// //   // تحديث رحلات السائق الفردية
// //   // ---------------------------
// //   Future<void> _updateIndividualDriverTrips(
// //     String driverName,
// //     double paymentAmount,
// //   ) async {
// //     try {
// //       final snapshot = await _firestore
// //           .collection('drivers')
// //           .where('driverName', isEqualTo: driverName)
// //           .where('contractor', isEqualTo: _selectedContractor)
// //           .get();

// //       double remainingPayment = paymentAmount;

// //       // جمع الرحلات التي بها متبقي
// //       List<Map<String, dynamic>> tripsWithRemaining = [];

// //       for (final doc in snapshot.docs) {
// //         final data = doc.data() as Map<String, dynamic>?;
// //         if (data == null) continue;

// //         final wheelNolon = (data['wheelNolon'] ?? 0).toDouble();
// //         final wheelOvernight = (data['wheelOvernight'] ?? 0).toDouble();
// //         final wheelHoliday = (data['wheelHoliday'] ?? 0).toDouble();
// //         final currentPaid = (data['paidAmount'] ?? 0).toDouble();

// //         final tripTotal = wheelNolon + wheelOvernight + wheelHoliday;
// //         final tripRemaining = tripTotal - currentPaid;

// //         if (tripRemaining > 0) {
// //           tripsWithRemaining.add({'doc': doc, 'remaining': tripRemaining});
// //         }
// //       }

// //       // ترتيب الرحلات حسب التاريخ (الأقدم أولاً)
// //       tripsWithRemaining.sort((a, b) {
// //         final dateA =
// //             (a['doc'].data()['date'] as Timestamp?)?.toDate() ?? DateTime.now();
// //         final dateB =
// //             (b['doc'].data()['date'] as Timestamp?)?.toDate() ?? DateTime.now();
// //         return dateA.compareTo(dateB);
// //       });

// //       // توزيع المدفوعات
// //       for (var trip in tripsWithRemaining) {
// //         if (remainingPayment <= 0) break;

// //         final doc = trip['doc'] as QueryDocumentSnapshot;
// //         final tripRemaining = trip['remaining'] as double;
// //         final data = doc.data() as Map<String, dynamic>?;
// //         if (data == null) continue;

// //         final wheelNolon = (data['wheelNolon'] ?? 0).toDouble();
// //         final wheelOvernight = (data['wheelOvernight'] ?? 0).toDouble();
// //         final wheelHoliday = (data['wheelHoliday'] ?? 0).toDouble();
// //         final currentPaid = (data['paidAmount'] ?? 0).toDouble();

// //         final tripTotal = wheelNolon + wheelOvernight + wheelHoliday;
// //         final toPay = remainingPayment > tripRemaining
// //             ? tripRemaining
// //             : remainingPayment;
// //         final newPaidAmount = currentPaid + toPay;
// //         final isFullyPaid = newPaidAmount >= tripTotal;

// //         await doc.reference.update({
// //           'paidAmount': newPaidAmount,
// //           'isPaid': isFullyPaid,
// //           'remainingAmount': tripTotal - newPaidAmount,
// //         });

// //         remainingPayment -= toPay;
// //       }
// //     } catch (e) {
// //       print('خطأ في تحديث الرحلات: $e');
// //     }
// //   }

// //   // ---------------------------
// //   // باقي الوظائف غير المتغيرة...
// //   // ---------------------------
// //   List<Map<String, dynamic>> _applyContractorFilters(
// //     List<Map<String, dynamic>> contractors,
// //   ) {
// //     return contractors.where((contractor) {
// //       if (_searchContractorQuery.isNotEmpty) {
// //         if (!contractor['contractorName'].toLowerCase().contains(
// //           _searchContractorQuery.toLowerCase(),
// //         )) {
// //           return false;
// //         }
// //       }

// //       if (_timeFilter != 'الكل') {
// //         final lastUpdated = contractor['lastUpdated'] as DateTime?;
// //         if (lastUpdated == null) return false;

// //         final now = DateTime.now();

// //         switch (_timeFilter) {
// //           case 'اليوم':
// //             if (lastUpdated.year != now.year ||
// //                 lastUpdated.month != now.month ||
// //                 lastUpdated.day != now.day) {
// //               return false;
// //             }
// //             break;
// //           case 'هذا الشهر':
// //             if (lastUpdated.year != now.year ||
// //                 lastUpdated.month != now.month) {
// //               return false;
// //             }
// //             break;
// //           case 'هذه السنة':
// //             if (lastUpdated.year != now.year) {
// //               return false;
// //             }
// //             break;
// //           case 'مخصص':
// //             if (lastUpdated.year != _selectedYear ||
// //                 lastUpdated.month != _selectedMonth) {
// //               return false;
// //             }
// //             break;
// //         }
// //       }

// //       return true;
// //     }).toList();
// //   }

// //   List<Map<String, dynamic>> _applyDriverFilters(
// //     List<Map<String, dynamic>> drivers,
// //   ) {
// //     return drivers.where((driver) {
// //       if (_searchDriverQuery.isNotEmpty) {
// //         if (!driver['driverName'].toLowerCase().contains(
// //           _searchDriverQuery.toLowerCase(),
// //         )) {
// //           return false;
// //         }
// //       }

// //       if (_statusFilter != 'الكل' && driver['status'] != _statusFilter) {
// //         return false;
// //       }

// //       return true;
// //     }).toList();
// //   }

// //   void _changeTimeFilter(String filter) {
// //     setState(() {
// //       _timeFilter = filter;
// //       _filteredContractors = _applyContractorFilters(_contractors);
// //     });
// //   }

// //   void _changeStatusFilter(String filter) {
// //     setState(() {
// //       _statusFilter = filter;
// //       _filteredDrivers = _applyDriverFilters(_driversByContractor);
// //     });
// //   }

// //   void _applyMonthYearFilter() {
// //     setState(() {
// //       _timeFilter = 'مخصص';
// //       _filteredContractors = _applyContractorFilters(_contractors);
// //     });
// //   }

// //   void _goBack() {
// //     setState(() {
// //       _selectedContractor = null;
// //       _driversByContractor.clear();
// //       _filteredDrivers.clear();
// //     });
// //   }

// //   // ---------------------------
// //   // AppBar
// //   // ---------------------------
// //   Widget _buildCustomAppBar() {
// //     String title = 'حسابات المقاولين';

// //     if (_selectedContractor != null) {
// //       title = 'حسابات السائقين - $_selectedContractor';
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
// //             if (_selectedContractor != null)
// //               IconButton(
// //                 icon: Icon(Icons.arrow_back, color: Colors.white),
// //                 onPressed: _goBack,
// //               ),

// //             Icon(
// //               _selectedContractor != null ? Icons.person : Icons.business,
// //               color: Colors.white,
// //               size: 28,
// //             ),
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

// //             // رصيد الخزنة
// //             Container(
// //               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
// //               decoration: BoxDecoration(
// //                 color: Colors.white.withOpacity(0.2),
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //               child: Row(
// //                 children: [
// //                   Icon(
// //                     Icons.account_balance_wallet,
// //                     color: Colors.white,
// //                     size: 16,
// //                   ),
// //                   SizedBox(width: 6),
// //                   Text(
// //                     '${_treasuryBalance.toStringAsFixed(0)} ج',
// //                     style: const TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 14,
// //                       fontWeight: FontWeight.bold,
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

// //   // ---------------------------
// //   // قسم فلتر الوقت للمقاولين
// //   // ---------------------------
// //   Widget _buildTimeFilterSection() {
// //     if (_selectedContractor != null) return SizedBox();

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

// //           if (_timeFilter == 'مخصص')
// //             Container(
// //               margin: EdgeInsets.only(top: 12),
// //               padding: EdgeInsets.all(12),
// //               decoration: BoxDecoration(
// //                 color: Colors.grey[50],
// //                 borderRadius: BorderRadius.circular(8),
// //               ),
// //               child: Row(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   Icon(Icons.calendar_month, color: Color(0xFF3498DB)),
// //                   SizedBox(width: 8),
// //                   DropdownButton<int>(
// //                     value: _selectedMonth,
// //                     onChanged: (value) {
// //                       if (value != null) {
// //                         setState(() => _selectedMonth = value);
// //                         _applyMonthYearFilter();
// //                       }
// //                     },
// //                     items: List.generate(12, (index) {
// //                       final monthNumber = index + 1;
// //                       return DropdownMenuItem(
// //                         value: monthNumber,
// //                         child: Text('شهر $monthNumber'),
// //                       );
// //                     }),
// //                   ),
// //                   SizedBox(width: 20),
// //                   DropdownButton<int>(
// //                     value: _selectedYear,
// //                     onChanged: (value) {
// //                       if (value != null) {
// //                         setState(() => _selectedYear = value);
// //                         _applyMonthYearFilter();
// //                       }
// //                     },
// //                     items: [
// //                       for (
// //                         int i = DateTime.now().year - 2;
// //                         i <= DateTime.now().year + 2;
// //                         i++
// //                       )
// //                         DropdownMenuItem(value: i, child: Text('$i')),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ---------------------------
// //   // قسم فلتر الحالة للسائقين
// //   // ---------------------------
// //   Widget _buildStatusFilterSection() {
// //     if (_selectedContractor == null) return SizedBox();

// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           _buildStatusFilterBox('الكل', Colors.grey, Icons.all_inclusive),
// //           _buildStatusFilterBox('جارية', Color(0xFFE74C3C), Icons.access_time),
// //           _buildStatusFilterBox(
// //             'شبه منتهية',
// //             Color(0xFFF39C12),
// //             Icons.hourglass_bottom,
// //           ),
// //           _buildStatusFilterBox(
// //             'منتهية',
// //             Color(0xFF27AE60),
// //             Icons.check_circle,
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildStatusFilterBox(String status, Color color, IconData icon) {
// //     final isSelected = _statusFilter == status;

// //     return GestureDetector(
// //       onTap: () => _changeStatusFilter(status),
// //       child: Container(
// //         width: 70,
// //         padding: const EdgeInsets.symmetric(vertical: 8),
// //         decoration: BoxDecoration(
// //           color: isSelected ? color : color.withOpacity(0.1),
// //           borderRadius: BorderRadius.circular(8),
// //           border: Border.all(
// //             color: isSelected ? color : color.withOpacity(0.3),
// //             width: 1,
// //           ),
// //         ),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(icon, color: isSelected ? Colors.white : color, size: 18),
// //             const SizedBox(height: 4),
// //             Text(
// //               status,
// //               style: TextStyle(
// //                 color: isSelected ? Colors.white : color,
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 10,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ---------------------------
// //   // واجهة قائمة المقاولين
// //   // ---------------------------
// //   Widget _buildContractorsList() {
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
// //                 _filteredContractors = _applyContractorFilters(_contractors);
// //               });
// //             },
// //           ),
// //         ),

// //         // قائمة المقاولين
// //         Expanded(
// //           child: _filteredContractors.isEmpty
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
// //                   itemCount: _filteredContractors.length,
// //                   itemBuilder: (context, index) {
// //                     final contractor = _filteredContractors[index];
// //                     final remainingAmount =
// //                         contractor['totalRemainingAmount'] as double;
// //                     final activeDrivers = contractor['activeDrivers'] as int;
// //                     final totalDrivers = contractor['totalDrivers'] as int;

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
// //                               contractor['contractorName']
// //                                   .substring(0, 1)
// //                                   .toUpperCase(),
// //                               style: TextStyle(
// //                                 color: Colors.white,
// //                                 fontSize: 20,
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                         title: Text(
// //                           contractor['contractorName'],
// //                           style: TextStyle(
// //                             fontWeight: FontWeight.bold,
// //                             fontSize: 16,
// //                             color: Color(0xFF2C3E50),
// //                           ),
// //                         ),
// //                         subtitle: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             SizedBox(height: 4),
// //                             Row(
// //                               children: [
// //                                 Icon(
// //                                   Icons.person,
// //                                   size: 14,
// //                                   color: Colors.grey,
// //                                 ),
// //                                 SizedBox(width: 4),
// //                                 Text(
// //                                   '$totalDrivers سائق',
// //                                   style: TextStyle(fontSize: 12),
// //                                 ),
// //                                 SizedBox(width: 8),
// //                                 Icon(
// //                                   Icons.access_time,
// //                                   size: 14,
// //                                   color: Colors.orange,
// //                                 ),
// //                                 SizedBox(width: 4),
// //                                 Text(
// //                                   '$activeDrivers نشط',
// //                                   style: TextStyle(
// //                                     fontSize: 12,
// //                                     color: Colors.orange,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                             SizedBox(height: 2),
// //                             Text(
// //                               'المتبقي: ${remainingAmount.toStringAsFixed(2)} ج',
// //                               style: TextStyle(
// //                                 fontSize: 12,
// //                                 color: Colors.red,
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                         trailing: remainingAmount > 0
// //                             ? SizedBox(
// //                                 height: 32,
// //                                 child: ElevatedButton(
// //                                   onPressed: () => _payContractor(contractor),
// //                                   style: ElevatedButton.styleFrom(
// //                                     backgroundColor: Color(0xFF27AE60),
// //                                     foregroundColor: Colors.white,
// //                                     padding: EdgeInsets.symmetric(
// //                                       horizontal: 12,
// //                                     ),
// //                                     shape: RoundedRectangleBorder(
// //                                       borderRadius: BorderRadius.circular(6),
// //                                     ),
// //                                     elevation: 0,
// //                                   ),
// //                                   child: Text(
// //                                     'سداد',
// //                                     style: TextStyle(fontSize: 12),
// //                                   ),
// //                                 ),
// //                               )
// //                             : Icon(
// //                                 Icons.arrow_forward_ios,
// //                                 color: Color(0xFF3498DB),
// //                                 size: 16,
// //                               ),
// //                         onTap: () => _loadContractorDrivers(
// //                           contractor['contractorName'],
// //                         ),
// //                       ),
// //                     );
// //                   },
// //                 ),
// //         ),
// //       ],
// //     );
// //   }

// //   // ---------------------------
// //   // واجهة قائمة السائقين
// //   // ---------------------------
// //   Widget _buildDriversList() {
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
// //                 _filteredDrivers = _applyDriverFilters(_driversByContractor);
// //               });
// //             },
// //           ),
// //         ),

// //         // فلتر الحالة
// //         _buildStatusFilterSection(),

// //         // معلومات المقاول
// //         Container(
// //           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //           child: Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Text(
// //                 'عدد السائقين: ${_filteredDrivers.length}',
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
// //           child: _filteredDrivers.isEmpty
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
// //                   itemCount: _filteredDrivers.length,
// //                   itemBuilder: (context, index) {
// //                     final driver = _filteredDrivers[index];
// //                     final remainingAmount =
// //                         driver['totalRemainingAmount'] as double;
// //                     final paidAmount = driver['totalPaidAmount'] as double;
// //                     final status = driver['status'];
// //                     final isCompleted = status == 'منتهية';

// //                     return Container(
// //                       margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
// //                       decoration: BoxDecoration(
// //                         color: Colors.white,
// //                         borderRadius: BorderRadius.circular(12),
// //                         border: Border.all(
// //                           color: isCompleted
// //                               ? Colors.green.withOpacity(0.3)
// //                               : Color(0xFF3498DB).withOpacity(0.3),
// //                         ),
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
// //                           backgroundColor: _getStatusColor(status),
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
// //                                 SizedBox(width: 8),
// //                                 Container(
// //                                   padding: EdgeInsets.symmetric(
// //                                     horizontal: 6,
// //                                     vertical: 2,
// //                                   ),
// //                                   decoration: BoxDecoration(
// //                                     color: _getStatusColor(
// //                                       status,
// //                                     ).withOpacity(0.1),
// //                                     borderRadius: BorderRadius.circular(4),
// //                                   ),
// //                                   child: Text(
// //                                     status,
// //                                     style: TextStyle(
// //                                       color: _getStatusColor(status),
// //                                       fontSize: 10,
// //                                       fontWeight: FontWeight.bold,
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                             SizedBox(height: 2),
// //                             if (!isCompleted && remainingAmount > 0)
// //                               Text(
// //                                 'المتبقي: ${remainingAmount.toStringAsFixed(2)} ج',
// //                                 style: TextStyle(
// //                                   fontSize: 12,
// //                                   color: Colors.red,
// //                                   fontWeight: FontWeight.bold,
// //                                 ),
// //                               )
// //                             else
// //                               Text(
// //                                 'المدفوع: ${paidAmount.toStringAsFixed(2)} ج',
// //                                 style: TextStyle(
// //                                   fontSize: 12,
// //                                   color: Colors.green,
// //                                   fontWeight: FontWeight.bold,
// //                                 ),
// //                               ),
// //                           ],
// //                         ),
// //                         trailing: !isCompleted && remainingAmount > 0
// //                             ? SizedBox(
// //                                 height: 32,
// //                                 child: ElevatedButton(
// //                                   onPressed: () => _makePayment(driver),
// //                                   style: ElevatedButton.styleFrom(
// //                                     backgroundColor: Color(0xFF27AE60),
// //                                     foregroundColor: Colors.white,
// //                                     padding: EdgeInsets.symmetric(
// //                                       horizontal: 12,
// //                                     ),
// //                                     shape: RoundedRectangleBorder(
// //                                       borderRadius: BorderRadius.circular(6),
// //                                     ),
// //                                     elevation: 0,
// //                                   ),
// //                                   child: Text(
// //                                     'سداد',
// //                                     style: TextStyle(fontSize: 12),
// //                                   ),
// //                                 ),
// //                               )
// //                             : Container(
// //                                 padding: EdgeInsets.symmetric(
// //                                   horizontal: 12,
// //                                   vertical: 6,
// //                                 ),
// //                                 decoration: BoxDecoration(
// //                                   color: Colors.grey[100],
// //                                   borderRadius: BorderRadius.circular(6),
// //                                 ),
// //                                 child: Text(
// //                                   'منتهي',
// //                                   style: TextStyle(
// //                                     fontSize: 12,
// //                                     color: Colors.grey[600],
// //                                   ),
// //                                 ),
// //                               ),
// //                       ),
// //                     );
// //                   },
// //                 ),
// //         ),
// //       ],
// //     );
// //   }

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

// //   // ---------------------------
// //   // الواجهة الرئيسية
// //   // ---------------------------
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8F9FA),
// //       body: Column(
// //         children: [
// //           _buildCustomAppBar(),
// //           if (_selectedContractor == null) _buildTimeFilterSection(),
// //           Expanded(
// //             child: _selectedContractor != null
// //                 ? _buildDriversList()
// //                 : _buildContractorsList(),
// //           ),
// //         ],
// //       ),
// //       floatingActionButton: FloatingActionButton(
// //         onPressed: () {
// //           _loadTreasuryBalance();
// //           if (_selectedContractor != null) {
// //             _loadContractorDrivers(_selectedContractor!);
// //           } else {
// //             _loadContractors();
// //           }
// //         },
// //         backgroundColor: Color(0xFF3498DB),
// //         tooltip: 'تحديث',
// //         child: Icon(Icons.refresh, color: Colors.white),
// //       ),
// //     );
// //   }
// // }
// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:flutter/widgets.dart' as flutter_widgets;

// class DriverAccountsPage extends StatefulWidget {
//   const DriverAccountsPage({super.key});

//   @override
//   State<DriverAccountsPage> createState() => _DriverAccountsPageState();
// }

// class _DriverAccountsPageState extends State<DriverAccountsPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final TextEditingController _searchController = TextEditingController();

//   // بيانات المقاولين
//   List<Map<String, dynamic>> _contractors = [];
//   List<Map<String, dynamic>> _filteredContractors = [];

//   // بيانات سائقين المقاول المحدد
//   List<Map<String, dynamic>> _driversByContractor = [];
//   List<Map<String, dynamic>> _filteredDrivers = [];

//   // حالات التحديد
//   String? _selectedContractor;

//   // حالات التحميل
//   bool _isLoading = false;
//   bool _isLoadingDrivers = false;

//   // الفلاتر
//   String _searchContractorQuery = '';
//   String _searchDriverQuery = '';
//   String _statusFilter = 'الكل'; // جارية، شبه منتهية، منتهية
//   String _timeFilter = 'الكل';
//   int _selectedMonth = DateTime.now().month;
//   int _selectedYear = DateTime.now().year;

//   // رصيد الخزنة
//   double _treasuryBalance = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _loadContractors();
//     _loadTreasuryBalance();
//   }

//   // ---------------------------
//   // تحميل رصيد الخزنة
//   // ---------------------------
//   Future<void> _loadTreasuryBalance() async {
//     try {
//       final incomeSnapshot = await _firestore
//           .collection('treasury_entries')
//           .where('isCleared', isEqualTo: true)
//           .get();

//       double totalIncome = 0;
//       for (var doc in incomeSnapshot.docs) {
//         final data = doc.data();
//         final amount = data['amount'];
//         if (amount != null) {
//           totalIncome += (amount as num).toDouble();
//         }
//       }

//       final expenseSnapshot = await _firestore
//           .collection('treasury_exits')
//           .get();

//       double totalExpense = 0;
//       for (var doc in expenseSnapshot.docs) {
//         final data = doc.data();
//         final amount = data['amount'];
//         if (amount != null) {
//           totalExpense += (amount as num).toDouble();
//         }
//       }

//       setState(() {
//         _treasuryBalance = totalIncome - totalExpense;
//       });
//     } catch (e) {
//       print('Error loading treasury balance: $e');
//     }
//   }

//   // ---------------------------
//   // إضافة مصروف للخزنة
//   // ---------------------------
//   Future<void> _addExpenseToTreasury({
//     required String recipientName,
//     required double amount,
//     required String paymentType, // 'سائق' أو 'مقاول'
//     required String paymentMethod, // 'كامل' أو 'جزئي'
//     required String? contractorName,
//     required String? driverName,
//   }) async {
//     try {
//       // إنشاء وصف واضح
//       String description = '';
//       String expenseType = '';

//       if (paymentType == 'سائق') {
//         expenseType = 'حساب سواق';
//         description = 'حساب السائق $driverName - المقاول $contractorName';
//       } else {
//         expenseType = 'حساب مقاول';
//         description = 'حساب المقاول $recipientName';
//       }

//       // إضافة "كامل" أو "جزئي" للوصف
//       description += ' ($paymentMethod)';

//       final expenseData = {
//         'amount': amount,
//         'expenseType': expenseType,
//         'description': description,
//         'recipient': recipientName,
//         'date': Timestamp.now(),
//         'createdAt': Timestamp.now(),
//         'category': 'خرج',
//         'status': 'مكتمل',
//         'paymentMethod': paymentMethod,
//         'paymentFor': paymentType,
//         'contractorName': contractorName,
//         'driverName': driverName,
//         'timestamp': Timestamp.now(),
//       };

//       await _firestore.collection('treasury_exits').add(expenseData);

//       // تحديث رصيد الخزنة
//       setState(() {
//         _treasuryBalance -= amount;
//       });

//       return;
//     } catch (e) {
//       print('Error adding expense to treasury: $e');
//       throw e;
//     }
//   }

//   // ---------------------------
//   // تحميل قائمة المقاولين مع إجمالياتهم
//   // ---------------------------
//   Future<void> _loadContractors() async {
//     setState(() => _isLoading = true);

//     try {
//       // جلب جميع بيانات السائقين
//       final snapshot = await _firestore.collection('drivers').get();

//       // تجميع البيانات حسب المقاول
//       Map<String, Map<String, dynamic>> contractorsMap = {};

//       for (final doc in snapshot.docs) {
//         final data = doc.data() as Map<String, dynamic>?;
//         if (data == null) continue;

//         final contractor = (data['contractor'] ?? '').toString().trim();
//         if (contractor.isEmpty) continue;

//         if (!contractorsMap.containsKey(contractor)) {
//           contractorsMap[contractor] = {
//             'contractorName': contractor,
//             'totalKarta': 0.0,
//             'totalOhda': 0.0,
//             'totalWheelNolon': 0.0,
//             'totalWheelOvernight': 0.0,
//             'totalWheelHoliday': 0.0,
//             'totalNetAmount': 0.0,
//             'totalPaidAmount': 0.0,
//             'totalRemainingAmount': 0.0,
//             'totalDrivers': 0,
//             'activeDrivers': 0,
//             'finishedDrivers': 0,
//             'lastUpdated': null,
//           };
//         }

//         final contractorData = contractorsMap[contractor]!;

//         // إضافة أرقام السائق
//         contractorData['totalDrivers'] = contractorData['totalDrivers']! + 1;

//         // جمع جميع البيانات للحساب الصحيح
//         final karta = _parseToDouble(data['karta']);
//         final ohda = _parseToDouble(data['ohda']);
//         final wheelNolon = _parseToDouble(data['wheelNolon']);
//         final wheelOvernight = _parseToDouble(data['wheelOvernight']);
//         final wheelHoliday = _parseToDouble(data['wheelHoliday']);
//         final paidAmount = _parseToDouble(data['paidAmount']);

//         // حساب الصافي: (الكارتة + النولون + المبيت + العطلة) - العهدة
//         final netAmount =
//             (karta + wheelNolon + wheelOvernight + wheelHoliday) - ohda;

//         // تحديث الإجماليات
//         contractorData['totalKarta'] = contractorData['totalKarta']! + karta;
//         contractorData['totalOhda'] = contractorData['totalOhda']! + ohda;
//         contractorData['totalWheelNolon'] =
//             contractorData['totalWheelNolon']! + wheelNolon;
//         contractorData['totalWheelOvernight'] =
//             contractorData['totalWheelOvernight']! + wheelOvernight;
//         contractorData['totalWheelHoliday'] =
//             contractorData['totalWheelHoliday']! + wheelHoliday;
//         contractorData['totalNetAmount'] =
//             contractorData['totalNetAmount']! + netAmount;
//         contractorData['totalPaidAmount'] =
//             contractorData['totalPaidAmount']! + paidAmount;

//         // تحديث حالة السائقين
//         final remaining = netAmount - paidAmount;
//         if (remaining <= 0) {
//           contractorData['finishedDrivers'] =
//               contractorData['finishedDrivers']! + 1;
//         } else {
//           contractorData['activeDrivers'] =
//               contractorData['activeDrivers']! + 1;
//         }

//         // تاريخ آخر تحديث
//         final tripDate = (data['date'] as Timestamp?)?.toDate();
//         if (tripDate != null) {
//           if (contractorData['lastUpdated'] == null ||
//               tripDate.isAfter(contractorData['lastUpdated'])) {
//             contractorData['lastUpdated'] = tripDate;
//           }
//         }
//       }

//       // حساب الإجماليات النهائية
//       for (var contractor in contractorsMap.values) {
//         final totalNetAmount = contractor['totalNetAmount']!;
//         final totalPaidAmount = contractor['totalPaidAmount']!;
//         contractor['totalRemainingAmount'] = totalNetAmount - totalPaidAmount;
//       }

//       // تحويل إلى قائمة وترتيب
//       List<Map<String, dynamic>> contractorsList = contractorsMap.values
//           .toList();
//       contractorsList.sort(
//         (a, b) => a['contractorName'].compareTo(b['contractorName']),
//       );

//       setState(() {
//         _contractors = contractorsList;
//         _filteredContractors = _applyContractorFilters(contractorsList);
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showError('خطأ في تحميل المقاولين: $e');
//     }
//   }

//   // ---------------------------
//   // تحميل السائقين التابعين لمقاول مع حساب كل سائق
//   // ---------------------------
//   Future<void> _loadContractorDrivers(String contractorName) async {
//     if (contractorName.isEmpty) return;

//     setState(() {
//       _selectedContractor = contractorName;
//       _isLoadingDrivers = true;
//       _driversByContractor.clear();
//       _filteredDrivers.clear();
//     });

//     try {
//       final snapshot = await _firestore
//           .collection('drivers')
//           .where('contractor', isEqualTo: contractorName)
//           .get();

//       // تجميع السائقين الفريدين مع حساب كل سائق
//       Map<String, Map<String, dynamic>> driversMap = {};

//       for (final doc in snapshot.docs) {
//         final data = doc.data() as Map<String, dynamic>?;
//         if (data == null) continue;

//         final driverName = (data['driverName'] ?? '').toString().trim();
//         if (driverName.isEmpty) continue;

//         if (!driversMap.containsKey(driverName)) {
//           driversMap[driverName] = {
//             'driverName': driverName,
//             'contractor': contractorName,
//             'totalKarta': 0.0,
//             'totalOhda': 0.0,
//             'totalWheelNolon': 0.0,
//             'totalWheelOvernight': 0.0,
//             'totalWheelHoliday': 0.0,
//             'totalNetAmount': 0.0,
//             'totalPaidAmount': 0.0,
//             'totalRemainingAmount': 0.0,
//             'totalTrips': 0,
//             'lastTripDate': null,
//           };
//         }

//         final driverData = driversMap[driverName]!;

//         // تحديث الإحصائيات
//         driverData['totalTrips'] = driverData['totalTrips']! + 1;

//         // جمع جميع البيانات للحساب الصحيح
//         final karta = _parseToDouble(data['karta']);
//         final ohda = _parseToDouble(data['ohda']);
//         final wheelNolon = _parseToDouble(data['wheelNolon']);
//         final wheelOvernight = _parseToDouble(data['wheelOvernight']);
//         final wheelHoliday = _parseToDouble(data['wheelHoliday']);
//         final paidAmount = _parseToDouble(data['paidAmount']);

//         // حساب الصافي: (الكارتة + النولون + المبيت + العطلة) - العهدة
//         final netAmount =
//             (karta + wheelNolon + wheelOvernight + wheelHoliday) - ohda;

//         // تحديث الإجماليات
//         driverData['totalKarta'] = driverData['totalKarta']! + karta;
//         driverData['totalOhda'] = driverData['totalOhda']! + ohda;
//         driverData['totalWheelNolon'] =
//             driverData['totalWheelNolon']! + wheelNolon;
//         driverData['totalWheelOvernight'] =
//             driverData['totalWheelOvernight']! + wheelOvernight;
//         driverData['totalWheelHoliday'] =
//             driverData['totalWheelHoliday']! + wheelHoliday;
//         driverData['totalNetAmount'] =
//             driverData['totalNetAmount']! + netAmount;
//         driverData['totalPaidAmount'] =
//             driverData['totalPaidAmount']! + paidAmount;

//         // تاريخ آخر رحلة
//         final tripDate = (data['date'] as Timestamp?)?.toDate();
//         if (tripDate != null) {
//           if (driverData['lastTripDate'] == null ||
//               tripDate.isAfter(driverData['lastTripDate'])) {
//             driverData['lastTripDate'] = tripDate;
//           }
//         }
//       }

//       // حساب الإجماليات النهائية وتحديد الحالة
//       for (var driver in driversMap.values) {
//         final totalNetAmount = driver['totalNetAmount']!;
//         final totalPaidAmount = driver['totalPaidAmount']!;
//         final totalRemainingAmount = totalNetAmount - totalPaidAmount;

//         driver['totalRemainingAmount'] = totalRemainingAmount;

//         // تحديد حالة الحساب
//         String status;
//         if (totalRemainingAmount <= 0) {
//           status = 'منتهية';
//         } else if (totalPaidAmount > 0 && totalRemainingAmount > 0) {
//           status = 'شبه منتهية';
//         } else {
//           status = 'جارية';
//         }

//         driver['status'] = status;
//       }

//       // تحويل القائمة وترتيب
//       List<Map<String, dynamic>> driversList = driversMap.values.toList();
//       driversList.sort(
//         (a, b) =>
//             b['totalRemainingAmount'].compareTo(a['totalRemainingAmount']),
//       );

//       setState(() {
//         _driversByContractor = driversList;
//         _filteredDrivers = _applyDriverFilters(driversList);
//         _isLoadingDrivers = false;
//       });
//     } catch (e) {
//       setState(() => _isLoadingDrivers = false);
//       _showError('خطأ في تحميل السائقين: $e');
//     }
//   }

//   // ---------------------------
//   // سداد حساب مقاول (كامل أو جزئي)
//   // ---------------------------
//   Future<void> _payContractor(Map<String, dynamic> contractor) async {
//     final amountController = TextEditingController();
//     final contractorName = contractor['contractorName'];
//     final remainingAmount = contractor['totalRemainingAmount'] as double;
//     String paymentType = 'كامل'; // القيمة الافتراضية

//     if (remainingAmount <= 0) {
//       _showError('حساب المقاول منتهي بالفعل');
//       return;
//     }

//     // حساب مبالغ سائقي المقاول
//     double driversRemaining = 0;
//     double driversPaid = 0;

//     try {
//       final driversSnapshot = await _firestore
//           .collection('drivers')
//           .where('contractor', isEqualTo: contractorName)
//           .get();

//       for (final doc in driversSnapshot.docs) {
//         final data = doc.data() as Map<String, dynamic>?;
//         if (data == null) continue;

//         final karta = _parseToDouble(data['karta']);
//         final ohda = _parseToDouble(data['ohda']);
//         final wheelNolon = _parseToDouble(data['wheelNolon']);
//         final wheelOvernight = _parseToDouble(data['wheelOvernight']);
//         final wheelHoliday = _parseToDouble(data['wheelHoliday']);
//         final paidAmount = _parseToDouble(data['paidAmount']);

//         final netAmount =
//             (karta + wheelNolon + wheelOvernight + wheelHoliday) - ohda;
//         driversRemaining += (netAmount - paidAmount);
//         driversPaid += paidAmount;
//       }
//     } catch (e) {
//       print('Error calculating drivers amounts: $e');
//     }

//     await showDialog(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: flutter_widgets.TextDirection.rtl,
//         child: StatefulBuilder(
//           builder: (context, setState) {
//             return Dialog(
//               backgroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'سداد مقاول: $contractorName',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF2C3E50),
//                           ),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.close, size: 18),
//                           onPressed: () => Navigator.pop(context),
//                           padding: EdgeInsets.zero,
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     const Divider(height: 1),
//                     const SizedBox(height: 12),

//                     // رصيد الخزنة
//                     Container(
//                       padding: EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.blue[200]!),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.account_balance_wallet,
//                             color: _treasuryBalance < remainingAmount
//                                 ? Colors.red
//                                 : Colors.blue,
//                           ),
//                           SizedBox(width: 8),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'رصيد الخزنة الحالي',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey[600],
//                                   ),
//                                 ),
//                                 Text(
//                                   '${_treasuryBalance.toStringAsFixed(2)} ج',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: _treasuryBalance < remainingAmount
//                                         ? Colors.red
//                                         : Colors.blue,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 12),

//                     // إحصائيات المقاول مع التفاصيل الجديدة
//                     Container(
//                       padding: EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[50],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.grey[300]!),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('العدد الكلي للسائقين:'),
//                               Text(
//                                 '${contractor['totalDrivers']}',
//                                 style: TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('السائقين النشطين:'),
//                               Text(
//                                 '${contractor['activeDrivers']}',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.orange,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('إجمالي الكارتة:'),
//                               Text(
//                                 '${contractor['totalKarta'].toStringAsFixed(2)} ج',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blue,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('إجمالي العهدة:'),
//                               Text(
//                                 '${contractor['totalOhda'].toStringAsFixed(2)} ج',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.red,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('إجمالي النولون+المبيت+العطلة:'),
//                               Text(
//                                 '${(contractor['totalWheelNolon'] + contractor['totalWheelOvernight'] + contractor['totalWheelHoliday']).toStringAsFixed(2)} ج',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('إجمالي مدفوعات السائقين:'),
//                               Text(
//                                 '${driversPaid.toStringAsFixed(2)} ج',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('إجمالي متبقي السائقين:'),
//                               Text(
//                                 '${driversRemaining.toStringAsFixed(2)} ج',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.red,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 12),

//                     // المبلغ المتبقي
//                     Container(
//                       padding: EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.orange[50],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.orange[200]!),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'المبلغ المستحق للمقاول:',
//                                 style: TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                               Text(
//                                 '(الكارتة + النولون + المبيت + العطلة) - العهدة',
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Text(
//                             '${remainingAmount.toStringAsFixed(2)} ج',
//                             style: TextStyle(
//                               fontSize: 18,
//                               color: Colors.red,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 16),

//                     // نوع الدفع - مبدئي كامل
//                     if (remainingAmount > 0)
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           ChoiceChip(
//                             label: Text('دفع كامل'),
//                             selected: paymentType == 'كامل',
//                             onSelected: (selected) {
//                               if (selected) {
//                                 setState(() {
//                                   paymentType = 'كامل';
//                                   amountController.text = remainingAmount
//                                       .toStringAsFixed(2);
//                                 });
//                               }
//                             },
//                             selectedColor: Colors.green,
//                             labelStyle: TextStyle(
//                               color: paymentType == 'كامل'
//                                   ? Colors.white
//                                   : Colors.green,
//                             ),
//                           ),
//                           SizedBox(width: 15),
//                           ChoiceChip(
//                             label: Text('دفع جزئي'),
//                             selected: paymentType == 'جزئي',
//                             onSelected: (selected) {
//                               if (selected) {
//                                 setState(() {
//                                   paymentType = 'جزئي';
//                                   amountController.clear();
//                                 });
//                               }
//                             },
//                             selectedColor: Colors.blue,
//                             labelStyle: TextStyle(
//                               color: paymentType == 'جزئي'
//                                   ? Colors.white
//                                   : Colors.blue,
//                             ),
//                           ),
//                         ],
//                       ),
//                     SizedBox(height: 16),

//                     // حقل المبلغ
//                     TextFormField(
//                       controller: amountController,
//                       keyboardType: TextInputType.number,
//                       decoration: InputDecoration(
//                         labelText: paymentType == 'كامل'
//                             ? 'المبلغ الكامل'
//                             : 'المبلغ المطلوب دفعه',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 10,
//                         ),
//                         prefixIcon: Icon(Icons.attach_money),
//                       ),
//                     ),
//                     SizedBox(height: 20),

//                     // زر السداد
//                     Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () => Navigator.pop(context),
//                             style: OutlinedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(vertical: 10),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: const Text(
//                               'إلغاء',
//                               style: TextStyle(fontSize: 14),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: () async {
//                               final paymentAmount =
//                                   double.tryParse(amountController.text) ?? 0.0;

//                               if (paymentAmount <= 0) {
//                                 _showError('أدخل مبلغ صحيح');
//                                 return;
//                               }

//                               if (paymentAmount > remainingAmount) {
//                                 _showError('المبلغ أكبر من المستحق');
//                                 return;
//                               }

//                               if (paymentAmount > _treasuryBalance) {
//                                 _showError(
//                                   'المبلغ أكبر من الرصيد المتاح في الخزنة',
//                                 );
//                                 return;
//                               }

//                               // تحديد نوع الدفع بناءً على المبلغ
//                               final actualPaymentType =
//                                   paymentAmount == remainingAmount
//                                   ? 'كامل'
//                                   : 'جزئي';

//                               // عرض تأكيد السداد
//                               final confirmed = await _showPaymentConfirmation(
//                                 recipientName: contractorName,
//                                 amount: paymentAmount,
//                                 paymentMethod: actualPaymentType,
//                                 paymentFor: 'مقاول',
//                               );

//                               if (!confirmed) return;

//                               await _updateContractorPayment(
//                                 contractorName,
//                                 paymentAmount,
//                                 actualPaymentType,
//                               );
//                               Navigator.pop(context);
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF27AE60),
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(vertical: 10),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: Text(
//                               paymentType == 'كامل' ? 'سداد كامل' : 'سداد جزئي',
//                               style: TextStyle(fontSize: 14),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // ---------------------------
//   // سداد حساب سائق
//   // ---------------------------
//   Future<void> _makePayment(Map<String, dynamic> driver) async {
//     final amountController = TextEditingController();
//     final driverName = driver['driverName'];
//     final contractorName = driver['contractor'];
//     final remainingAmount = driver['totalRemainingAmount'] as double;
//     String paymentType = 'كامل'; // القيمة الافتراضية

//     if (remainingAmount <= 0) {
//       _showError('الحساب منتهي بالفعل');
//       return;
//     }

//     await showDialog(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: flutter_widgets.TextDirection.rtl,
//         child: StatefulBuilder(
//           builder: (context, setState) {
//             return Dialog(
//               backgroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'سداد سائق: $driverName',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF2C3E50),
//                           ),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.close, size: 18),
//                           onPressed: () => Navigator.pop(context),
//                           padding: EdgeInsets.zero,
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     const Divider(height: 1),
//                     const SizedBox(height: 12),

//                     // رصيد الخزنة
//                     Container(
//                       padding: EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.blue[200]!),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.account_balance_wallet,
//                             color: _treasuryBalance < remainingAmount
//                                 ? Colors.red
//                                 : Colors.blue,
//                           ),
//                           SizedBox(width: 8),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'رصيد الخزنة الحالي',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey[600],
//                                   ),
//                                 ),
//                                 Text(
//                                   '${_treasuryBalance.toStringAsFixed(2)} ج',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: _treasuryBalance < remainingAmount
//                                         ? Colors.red
//                                         : Colors.blue,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 12),

//                     // معلومات السائق مع التفاصيل الجديدة
//                     Container(
//                       padding: EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[50],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.grey[300]!),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('المقاول:'),
//                               Text(
//                                 contractorName,
//                                 style: TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('عدد الرحلات:'),
//                               Text(
//                                 '${driver['totalTrips']}',
//                                 style: TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('إجمالي الكارتة:'),
//                               Text(
//                                 '${driver['totalKarta'].toStringAsFixed(2)} ج',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blue,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('إجمالي العهدة:'),
//                               Text(
//                                 '${driver['totalOhda'].toStringAsFixed(2)} ج',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.red,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('إجمالي النولون:'),
//                               Text(
//                                 '${driver['totalWheelNolon'].toStringAsFixed(2)} ج',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('إجمالي المبيت:'),
//                               Text(
//                                 '${driver['totalWheelOvernight'].toStringAsFixed(2)} ج',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('إجمالي العطلة:'),
//                               Text(
//                                 '${driver['totalWheelHoliday'].toStringAsFixed(2)} ج',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 4),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('المدفوع:'),
//                               Text(
//                                 '${driver['totalPaidAmount'].toStringAsFixed(2)} ج',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.green,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 12),

//                     // المبلغ المتبقي
//                     Container(
//                       padding: EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.orange[50],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.orange[200]!),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 'المبلغ المستحق للسائق:',
//                                 style: TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                               Text(
//                                 '(الكارتة + النولون + المبيت + العطلة) - العهدة',
//                                 style: TextStyle(
//                                   fontSize: 10,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Text(
//                             '${remainingAmount.toStringAsFixed(2)} ج',
//                             style: TextStyle(
//                               fontSize: 18,
//                               color: Colors.red,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: 16),

//                     // نوع الدفع
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         ChoiceChip(
//                           label: Text('دفع كامل'),
//                           selected: paymentType == 'كامل',
//                           onSelected: (selected) {
//                             if (selected) {
//                               setState(() {
//                                 paymentType = 'كامل';
//                                 amountController.text = remainingAmount
//                                     .toStringAsFixed(2);
//                               });
//                             }
//                           },
//                           selectedColor: Colors.green,
//                           labelStyle: TextStyle(
//                             color: paymentType == 'كامل'
//                                 ? Colors.white
//                                 : Colors.green,
//                           ),
//                         ),
//                         ChoiceChip(
//                           label: Text('دفع جزئي'),
//                           selected: paymentType == 'جزئي',
//                           onSelected: (selected) {
//                             if (selected) {
//                               setState(() {
//                                 paymentType = 'جزئي';
//                                 amountController.clear();
//                               });
//                             }
//                           },
//                           selectedColor: Colors.blue,
//                           labelStyle: TextStyle(
//                             color: paymentType == 'جزئي'
//                                 ? Colors.white
//                                 : Colors.blue,
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 16),

//                     // حقل المبلغ
//                     TextFormField(
//                       controller: amountController,
//                       keyboardType: TextInputType.number,
//                       decoration: InputDecoration(
//                         labelText: paymentType == 'كامل'
//                             ? 'المبلغ الكامل'
//                             : 'المبلغ المطلوب دفعه',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 10,
//                         ),
//                         prefixIcon: Icon(Icons.attach_money),
//                       ),
//                     ),
//                     SizedBox(height: 20),

//                     // زر السداد
//                     Row(
//                       children: [
//                         Expanded(
//                           child: OutlinedButton(
//                             onPressed: () => Navigator.pop(context),
//                             style: OutlinedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(vertical: 10),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: const Text(
//                               'إلغاء',
//                               style: TextStyle(fontSize: 14),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: ElevatedButton(
//                             onPressed: () async {
//                               final paymentAmount =
//                                   double.tryParse(amountController.text) ?? 0.0;

//                               if (paymentAmount <= 0) {
//                                 _showError('أدخل مبلغ صحيح');
//                                 return;
//                               }

//                               if (paymentAmount > remainingAmount) {
//                                 _showError('المبلغ أكبر من المستحق');
//                                 return;
//                               }

//                               if (paymentAmount > _treasuryBalance) {
//                                 _showError(
//                                   'المبلغ أكبر من الرصيد المتاح في الخزنة',
//                                 );
//                                 return;
//                               }

//                               // تحديد نوع الدفع بناءً على المبلغ
//                               final actualPaymentType =
//                                   paymentAmount == remainingAmount
//                                   ? 'كامل'
//                                   : 'جزئي';

//                               // عرض تأكيد السداد
//                               final confirmed = await _showPaymentConfirmation(
//                                 recipientName: driverName,
//                                 amount: paymentAmount,
//                                 paymentMethod: actualPaymentType,
//                                 paymentFor: 'سائق',
//                                 contractorName: contractorName,
//                               );

//                               if (!confirmed) return;

//                               await _updateDriverPayment(
//                                 driverName,
//                                 paymentAmount,
//                                 actualPaymentType,
//                               );
//                               Navigator.pop(context);
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF27AE60),
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(vertical: 10),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                             ),
//                             child: Text(
//                               paymentType == 'كامل' ? 'سداد كامل' : 'سداد جزئي',
//                               style: TextStyle(fontSize: 14),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // ---------------------------
//   // تأكيد الدفع
//   // ---------------------------
//   Future<bool> _showPaymentConfirmation({
//     required String recipientName,
//     required double amount,
//     required String paymentMethod,
//     required String paymentFor, // 'سائق' أو 'مقاول'
//     String? contractorName,
//   }) async {
//     bool confirmed = false;

//     String paymentForText = paymentFor == 'سائق' ? 'سائق' : 'مقاول';
//     String description = paymentFor == 'سائق'
//         ? 'سائق $recipientName - المقاول $contractorName'
//         : 'مقاول $recipientName';

//     await showDialog(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: flutter_widgets.TextDirection.rtl,
//         child: AlertDialog(
//           title: Row(
//             children: [
//               Icon(Icons.payment, color: Colors.orange),
//               SizedBox(width: 8),
//               Text('تأكيد الدفع ($paymentMethod)'),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('هل أنت متأكد من دفع ${amount.toStringAsFixed(2)} ج'),
//               Text('لـ$paymentForText $recipientName؟'),
//               SizedBox(height: 8),
//               Container(
//                 padding: EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: paymentMethod == 'كامل'
//                       ? Colors.green[50]
//                       : Colors.blue[50],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(
//                           paymentMethod == 'كامل'
//                               ? Icons.check_circle
//                               : Icons.payment,
//                           color: paymentMethod == 'كامل'
//                               ? Colors.green
//                               : Colors.blue,
//                           size: 18,
//                         ),
//                         SizedBox(width: 8),
//                         Text(
//                           'تفاصيل الدفع ($paymentMethod)',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: paymentMethod == 'كامل'
//                                 ? Colors.green[800]
//                                 : Colors.blue[800],
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 8),
//                     Text('النوع: $paymentForText'),
//                     Text('الاسم: $description'),
//                     Text('المبلغ: ${amount.toStringAsFixed(2)} ج'),
//                     Text('طريقة الدفع: $paymentMethod'),
//                     Text(
//                       'التاريخ: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}',
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 12),
//               Container(
//                 padding: EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.orange[50],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   'سيتم خصم المبلغ من الخزنة تلقائياً',
//                   style: TextStyle(color: Colors.orange[800]),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('إلغاء'),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 confirmed = true;
//                 Navigator.pop(context);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: paymentMethod == 'كامل'
//                     ? Colors.green
//                     : Colors.blue,
//               ),
//               child: Text('تأكيد الدفع ($paymentMethod)'),
//             ),
//           ],
//         ),
//       ),
//     );

//     return confirmed;
//   }

//   // ---------------------------
//   // تحديث دفع المقاول
//   // ---------------------------
//   Future<void> _updateContractorPayment(
//     String contractorName,
//     double paymentAmount,
//     String paymentMethod,
//   ) async {
//     try {
//       // 1. تحديث رحلات سائقي المقاول
//       await _updateContractorDriverTrips(contractorName, paymentAmount);

//       // 2. إضافة المصروف للخزنة
//       await _addExpenseToTreasury(
//         recipientName: contractorName,
//         amount: paymentAmount,
//         paymentType: 'مقاول',
//         paymentMethod: paymentMethod,
//         contractorName: contractorName,
//         driverName: null,
//       );

//       // 3. إعادة تحميل البيانات
//       await _loadContractors();
//       if (_selectedContractor != null) {
//         await _loadContractorDrivers(_selectedContractor!);
//       }

//       _showSuccess(
//         'تم سداد ${paymentAmount.toStringAsFixed(2)} ج للمقاول $contractorName ($paymentMethod)',
//       );
//     } catch (e) {
//       _showError('خطأ في السداد: $e');
//     }
//   }

//   // ---------------------------
//   // تحديث رحلات سائقي المقاول
//   // ---------------------------
//   Future<void> _updateContractorDriverTrips(
//     String contractorName,
//     double paymentAmount,
//   ) async {
//     try {
//       // جلب جميع رحلات سائقي المقاول
//       final snapshot = await _firestore
//           .collection('drivers')
//           .where('contractor', isEqualTo: contractorName)
//           .get();

//       double remainingPayment = paymentAmount;

//       // توزيع المبلغ على رحلات السائقين حسب المستحق
//       List<Map<String, dynamic>> tripsWithRemaining = [];

//       for (final doc in snapshot.docs) {
//         final data = doc.data() as Map<String, dynamic>?;
//         if (data == null) continue;

//         final karta = _parseToDouble(data['karta']);
//         final ohda = _parseToDouble(data['ohda']);
//         final wheelNolon = _parseToDouble(data['wheelNolon']);
//         final wheelOvernight = _parseToDouble(data['wheelOvernight']);
//         final wheelHoliday = _parseToDouble(data['wheelHoliday']);
//         final currentPaid = _parseToDouble(data['paidAmount']);

//         // حساب الصافي: (الكارتة + النولون + المبيت + العطلة) - العهدة
//         final netAmount =
//             (karta + wheelNolon + wheelOvernight + wheelHoliday) - ohda;
//         final tripRemaining = netAmount - currentPaid;

//         if (tripRemaining > 0) {
//           tripsWithRemaining.add({'doc': doc, 'remaining': tripRemaining});
//         }
//       }

//       // توزيع المدفوعات بالتساوي على الرحلات
//       for (var trip in tripsWithRemaining) {
//         if (remainingPayment <= 0) break;

//         final doc = trip['doc'] as QueryDocumentSnapshot;
//         final tripRemaining = trip['remaining'] as double;
//         final data = doc.data() as Map<String, dynamic>?;
//         if (data == null) continue;

//         final karta = _parseToDouble(data['karta']);
//         final ohda = _parseToDouble(data['ohda']);
//         final wheelNolon = _parseToDouble(data['wheelNolon']);
//         final wheelOvernight = _parseToDouble(data['wheelOvernight']);
//         final wheelHoliday = _parseToDouble(data['wheelHoliday']);
//         final currentPaid = _parseToDouble(data['paidAmount']);

//         // حساب الصافي: (الكارتة + النولون + المبيت + العطلة) - العهدة
//         final netAmount =
//             (karta + wheelNolon + wheelOvernight + wheelHoliday) - ohda;
//         final toPay = remainingPayment > tripRemaining
//             ? tripRemaining
//             : remainingPayment;
//         final newPaidAmount = currentPaid + toPay;
//         final isFullyPaid = newPaidAmount >= netAmount;

//         await doc.reference.update({
//           'paidAmount': newPaidAmount,
//           'isPaid': isFullyPaid,
//           'remainingAmount': netAmount - newPaidAmount,
//         });

//         remainingPayment -= toPay;
//       }
//     } catch (e) {
//       print('خطأ في تحديث رحلات سائقي المقاول: $e');
//     }
//   }

//   // ---------------------------
//   // تحديث دفع السائق
//   // ---------------------------
//   Future<void> _updateDriverPayment(
//     String driverName,
//     double paymentAmount,
//     String paymentMethod,
//   ) async {
//     try {
//       // 1. تحديث رحلات السائق الفردية
//       await _updateIndividualDriverTrips(driverName, paymentAmount);

//       // 2. إضافة المصروف للخزنة
//       await _addExpenseToTreasury(
//         recipientName: driverName,
//         amount: paymentAmount,
//         paymentType: 'سائق',
//         paymentMethod: paymentMethod,
//         contractorName: _selectedContractor,
//         driverName: driverName,
//       );

//       // 3. إعادة تحميل بيانات السائقين بعد السداد
//       await _loadContractorDrivers(_selectedContractor!);

//       _showSuccess(
//         'تم سداد ${paymentAmount.toStringAsFixed(2)} ج للسائق $driverName ($paymentMethod)',
//       );
//     } catch (e) {
//       _showError('خطأ في السداد: $e');
//     }
//   }

//   // ---------------------------
//   // تحديث رحلات السائق الفردية
//   // ---------------------------
//   Future<void> _updateIndividualDriverTrips(
//     String driverName,
//     double paymentAmount,
//   ) async {
//     try {
//       final snapshot = await _firestore
//           .collection('drivers')
//           .where('driverName', isEqualTo: driverName)
//           .where('contractor', isEqualTo: _selectedContractor)
//           .get();

//       double remainingPayment = paymentAmount;

//       // جمع الرحلات التي بها متبقي
//       List<Map<String, dynamic>> tripsWithRemaining = [];

//       for (final doc in snapshot.docs) {
//         final data = doc.data() as Map<String, dynamic>?;
//         if (data == null) continue;

//         final karta = _parseToDouble(data['karta']);
//         final ohda = _parseToDouble(data['ohda']);
//         final wheelNolon = _parseToDouble(data['wheelNolon']);
//         final wheelOvernight = _parseToDouble(data['wheelOvernight']);
//         final wheelHoliday = _parseToDouble(data['wheelHoliday']);
//         final currentPaid = _parseToDouble(data['paidAmount']);

//         // حساب الصافي: (الكارتة + النولون + المبيت + العطلة) - العهدة
//         final netAmount =
//             (karta + wheelNolon + wheelOvernight + wheelHoliday) - ohda;
//         final tripRemaining = netAmount - currentPaid;

//         if (tripRemaining > 0) {
//           tripsWithRemaining.add({'doc': doc, 'remaining': tripRemaining});
//         }
//       }

//       // ترتيب الرحلات حسب التاريخ (الأقدم أولاً)
//       tripsWithRemaining.sort((a, b) {
//         final dateA =
//             (a['doc'].data()['date'] as Timestamp?)?.toDate() ?? DateTime.now();
//         final dateB =
//             (b['doc'].data()['date'] as Timestamp?)?.toDate() ?? DateTime.now();
//         return dateA.compareTo(dateB);
//       });

//       // توزيع المدفوعات
//       for (var trip in tripsWithRemaining) {
//         if (remainingPayment <= 0) break;

//         final doc = trip['doc'] as QueryDocumentSnapshot;
//         final tripRemaining = trip['remaining'] as double;
//         final data = doc.data() as Map<String, dynamic>?;
//         if (data == null) continue;

//         final karta = _parseToDouble(data['karta']);
//         final ohda = _parseToDouble(data['ohda']);
//         final wheelNolon = _parseToDouble(data['wheelNolon']);
//         final wheelOvernight = _parseToDouble(data['wheelOvernight']);
//         final wheelHoliday = _parseToDouble(data['wheelHoliday']);
//         final currentPaid = _parseToDouble(data['paidAmount']);

//         // حساب الصافي: (الكارتة + النولون + المبيت + العطلة) - العهدة
//         final netAmount =
//             (karta + wheelNolon + wheelOvernight + wheelHoliday) - ohda;
//         final toPay = remainingPayment > tripRemaining
//             ? tripRemaining
//             : remainingPayment;
//         final newPaidAmount = currentPaid + toPay;
//         final isFullyPaid = newPaidAmount >= netAmount;

//         await doc.reference.update({
//           'paidAmount': newPaidAmount,
//           'isPaid': isFullyPaid,
//           'remainingAmount': netAmount - newPaidAmount,
//         });

//         remainingPayment -= toPay;
//       }
//     } catch (e) {
//       print('خطأ في تحديث الرحلات: $e');
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

//   // ---------------------------
//   // باقي الوظائف غير المتغيرة...
//   // ---------------------------
//   List<Map<String, dynamic>> _applyContractorFilters(
//     List<Map<String, dynamic>> contractors,
//   ) {
//     return contractors.where((contractor) {
//       if (_searchContractorQuery.isNotEmpty) {
//         if (!contractor['contractorName'].toLowerCase().contains(
//           _searchContractorQuery.toLowerCase(),
//         )) {
//           return false;
//         }
//       }

//       if (_timeFilter != 'الكل') {
//         final lastUpdated = contractor['lastUpdated'] as DateTime?;
//         if (lastUpdated == null) return false;

//         final now = DateTime.now();

//         switch (_timeFilter) {
//           case 'اليوم':
//             if (lastUpdated.year != now.year ||
//                 lastUpdated.month != now.month ||
//                 lastUpdated.day != now.day) {
//               return false;
//             }
//             break;
//           case 'هذا الشهر':
//             if (lastUpdated.year != now.year ||
//                 lastUpdated.month != now.month) {
//               return false;
//             }
//             break;
//           case 'هذه السنة':
//             if (lastUpdated.year != now.year) {
//               return false;
//             }
//             break;
//           case 'مخصص':
//             if (lastUpdated.year != _selectedYear ||
//                 lastUpdated.month != _selectedMonth) {
//               return false;
//             }
//             break;
//         }
//       }

//       return true;
//     }).toList();
//   }

//   List<Map<String, dynamic>> _applyDriverFilters(
//     List<Map<String, dynamic>> drivers,
//   ) {
//     return drivers.where((driver) {
//       if (_searchDriverQuery.isNotEmpty) {
//         if (!driver['driverName'].toLowerCase().contains(
//           _searchDriverQuery.toLowerCase(),
//         )) {
//           return false;
//         }
//       }

//       if (_statusFilter != 'الكل' && driver['status'] != _statusFilter) {
//         return false;
//       }

//       return true;
//     }).toList();
//   }

//   void _changeTimeFilter(String filter) {
//     setState(() {
//       _timeFilter = filter;
//       _filteredContractors = _applyContractorFilters(_contractors);
//     });
//   }

//   void _changeStatusFilter(String filter) {
//     setState(() {
//       _statusFilter = filter;
//       _filteredDrivers = _applyDriverFilters(_driversByContractor);
//     });
//   }

//   void _applyMonthYearFilter() {
//     setState(() {
//       _timeFilter = 'مخصص';
//       _filteredContractors = _applyContractorFilters(_contractors);
//     });
//   }

//   void _goBack() {
//     setState(() {
//       _selectedContractor = null;
//       _driversByContractor.clear();
//       _filteredDrivers.clear();
//     });
//   }

//   // ---------------------------
//   // AppBar
//   // ---------------------------
//   Widget _buildCustomAppBar() {
//     String title = 'حسابات المقاولين';

//     if (_selectedContractor != null) {
//       title = 'حسابات السائقين - $_selectedContractor';
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
//             if (_selectedContractor != null)
//               IconButton(
//                 icon: Icon(Icons.arrow_back, color: Colors.white),
//                 onPressed: _goBack,
//               ),

//             Icon(
//               _selectedContractor != null ? Icons.person : Icons.business,
//               color: Colors.white,
//               size: 28,
//             ),
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

//             // رصيد الخزنة
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.account_balance_wallet,
//                     color: Colors.white,
//                     size: 16,
//                   ),
//                   SizedBox(width: 6),
//                   Text(
//                     '${_treasuryBalance.toStringAsFixed(0)} ج',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
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

//   // ---------------------------
//   // قسم فلتر الوقت للمقاولين
//   // ---------------------------
//   Widget _buildTimeFilterSection() {
//     if (_selectedContractor != null) return SizedBox();

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

//   // ---------------------------
//   // قسم فلتر الحالة للسائقين
//   // ---------------------------
//   Widget _buildStatusFilterSection() {
//     if (_selectedContractor == null) return SizedBox();

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           _buildStatusFilterBox('الكل', Colors.grey, Icons.all_inclusive),
//           _buildStatusFilterBox('جارية', Color(0xFFE74C3C), Icons.access_time),
//           _buildStatusFilterBox(
//             'شبه منتهية',
//             Color(0xFFF39C12),
//             Icons.hourglass_bottom,
//           ),
//           _buildStatusFilterBox(
//             'منتهية',
//             Color(0xFF27AE60),
//             Icons.check_circle,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusFilterBox(String status, Color color, IconData icon) {
//     final isSelected = _statusFilter == status;

//     return GestureDetector(
//       onTap: () => _changeStatusFilter(status),
//       child: Container(
//         width: 70,
//         padding: const EdgeInsets.symmetric(vertical: 8),
//         decoration: BoxDecoration(
//           color: isSelected ? color : color.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(
//             color: isSelected ? color : color.withOpacity(0.3),
//             width: 1,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: isSelected ? Colors.white : color, size: 18),
//             const SizedBox(height: 4),
//             Text(
//               status,
//               style: TextStyle(
//                 color: isSelected ? Colors.white : color,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 10,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ---------------------------
//   // واجهة قائمة المقاولين
//   // ---------------------------
//   Widget _buildContractorsList() {
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
//                 _filteredContractors = _applyContractorFilters(_contractors);
//               });
//             },
//           ),
//         ),

//         // قائمة المقاولين
//         Expanded(
//           child: _filteredContractors.isEmpty
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
//                   itemCount: _filteredContractors.length,
//                   itemBuilder: (context, index) {
//                     final contractor = _filteredContractors[index];
//                     final remainingAmount =
//                         contractor['totalRemainingAmount'] as double;
//                     final activeDrivers = contractor['activeDrivers'] as int;
//                     final totalDrivers = contractor['totalDrivers'] as int;

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
//                               contractor['contractorName']
//                                   .substring(0, 1)
//                                   .toUpperCase(),
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                         title: Text(
//                           contractor['contractorName'],
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: Color(0xFF2C3E50),
//                           ),
//                         ),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(height: 4),
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.person,
//                                   size: 14,
//                                   color: Colors.grey,
//                                 ),
//                                 SizedBox(width: 4),
//                                 Text(
//                                   '$totalDrivers سائق',
//                                   style: TextStyle(fontSize: 12),
//                                 ),
//                                 // SizedBox(width: 8),
//                                 // Icon(
//                                 //   Icons.access_time,
//                                 //   size: 14,
//                                 //   color: Colors.orange,
//                                 // ),
//                                 // SizedBox(width: 4),
//                                 // Text(
//                                 //   '$activeDrivers نشط',
//                                 //   style: TextStyle(
//                                 //     fontSize: 12,
//                                 //     color: Colors.orange,
//                                 //   ),
//                                 // ),
//                               ],
//                             ),
//                             SizedBox(height: 2),
//                             remainingAmount >= 0
//                                 ? Text(
//                                     'المتبقي: ${remainingAmount.toStringAsFixed(2)} ج',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.green,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   )
//                                 : Text(
//                                     'المتبقي: ${remainingAmount.toStringAsFixed(2)} ج',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.red,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                           ],
//                         ),
//                         trailing: remainingAmount > 0
//                             ? SizedBox(
//                                 height: 32,
//                                 child: ElevatedButton(
//                                   onPressed: () => _payContractor(contractor),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Color(0xFF27AE60),
//                                     foregroundColor: Colors.white,
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(6),
//                                     ),
//                                     elevation: 0,
//                                   ),
//                                   child: Text(
//                                     'سداد',
//                                     style: TextStyle(fontSize: 12),
//                                   ),
//                                 ),
//                               )
//                             : Icon(
//                                 Icons.arrow_forward_ios,
//                                 color: Color(0xFF3498DB),
//                                 size: 16,
//                               ),
//                         onTap: () => _loadContractorDrivers(
//                           contractor['contractorName'],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//         ),
//       ],
//     );
//   }

//   // ---------------------------
//   // واجهة قائمة السائقين
//   // ---------------------------
//   Widget _buildDriversList() {
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
//                 _filteredDrivers = _applyDriverFilters(_driversByContractor);
//               });
//             },
//           ),
//         ),

//         // فلتر الحالة
//         _buildStatusFilterSection(),

//         // معلومات المقاول
//         Container(
//           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'عدد السائقين: ${_filteredDrivers.length}',
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
//           child: _filteredDrivers.isEmpty
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
//                   itemCount: _filteredDrivers.length,
//                   itemBuilder: (context, index) {
//                     final driver = _filteredDrivers[index];
//                     final remainingAmount =
//                         driver['totalRemainingAmount'] as double;
//                     final paidAmount = driver['totalPaidAmount'] as double;
//                     final status = driver['status'];
//                     final isCompleted = status == 'منتهية';

//                     // حساب الإجماليات للعرض
//                     final totalKarta = driver['totalKarta'] as double;
//                     final totalOhda = driver['totalOhda'] as double;
//                     final totalWheelNolon = driver['totalWheelNolon'] as double;
//                     final totalWheelOvernight =
//                         driver['totalWheelOvernight'] as double;
//                     final totalWheelHoliday =
//                         driver['totalWheelHoliday'] as double;

//                     return Container(
//                       margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: isCompleted
//                               ? Colors.green.withOpacity(0.3)
//                               : Color(0xFF3498DB).withOpacity(0.3),
//                         ),
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
//                           backgroundColor: _getStatusColor(status),
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
//                                 SizedBox(width: 8),
//                                 Container(
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal: 6,
//                                     vertical: 2,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: _getStatusColor(
//                                       status,
//                                     ).withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                   child: Text(
//                                     status,
//                                     style: TextStyle(
//                                       color: _getStatusColor(status),
//                                       fontSize: 10,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 2),
//                             if (!isCompleted && remainingAmount > 0)
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'المتبقي: ${remainingAmount.toStringAsFixed(2)} ج',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.red,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   Text(
//                                     'الصافي: (${totalKarta.toStringAsFixed(0)} + ${totalWheelNolon.toStringAsFixed(0)} + ${totalWheelOvernight.toStringAsFixed(0)} + ${totalWheelHoliday.toStringAsFixed(0)}) - ${totalOhda.toStringAsFixed(0)}',
//                                     style: TextStyle(
//                                       fontSize: 10,
//                                       color: Colors.grey[600],
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             else
//                               Text(
//                                 'المدفوع: ${paidAmount.toStringAsFixed(2)} ج',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.green,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                           ],
//                         ),
//                         trailing: !isCompleted && remainingAmount > 0
//                             ? SizedBox(
//                                 height: 32,
//                                 child: ElevatedButton(
//                                   onPressed: () => _makePayment(driver),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Color(0xFF27AE60),
//                                     foregroundColor: Colors.white,
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: 12,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(6),
//                                     ),
//                                     elevation: 0,
//                                   ),
//                                   child: Text(
//                                     'سداد',
//                                     style: TextStyle(fontSize: 12),
//                                   ),
//                                 ),
//                               )
//                             : Container(
//                                 padding: EdgeInsets.symmetric(
//                                   horizontal: 12,
//                                   vertical: 6,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: Colors.grey[100],
//                                   borderRadius: BorderRadius.circular(6),
//                                 ),
//                                 child: Text(
//                                   'منتهي',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey[600],
//                                   ),
//                                 ),
//                               ),
//                       ),
//                     );
//                   },
//                 ),
//         ),
//       ],
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

//   // ---------------------------
//   // الواجهة الرئيسية
//   // ---------------------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       body: Column(
//         children: [
//           _buildCustomAppBar(),
//           if (_selectedContractor == null) _buildTimeFilterSection(),
//           Expanded(
//             child: _selectedContractor != null
//                 ? _buildDriversList()
//                 : _buildContractorsList(),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           _loadTreasuryBalance();
//           if (_selectedContractor != null) {
//             _loadContractorDrivers(_selectedContractor!);
//           } else {
//             _loadContractors();
//           }
//         },
//         backgroundColor: Color(0xFF3498DB),
//         tooltip: 'تحديث',
//         child: Icon(Icons.refresh, color: Colors.white),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart' as flutter_widgets;

class DriverAccountsPage extends StatefulWidget {
  const DriverAccountsPage({super.key});

  @override
  State<DriverAccountsPage> createState() => _DriverAccountsPageState();
}

class _DriverAccountsPageState extends State<DriverAccountsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  // بيانات المقاولين
  List<Map<String, dynamic>> _contractors = [];
  List<Map<String, dynamic>> _filteredContractors = [];

  // بيانات سائقين المقاول المحدد
  List<Map<String, dynamic>> _driversByContractor = [];
  List<Map<String, dynamic>> _filteredDrivers = [];

  // حالات التحديد
  String? _selectedContractor;

  // حالات التحميل
  bool _isLoading = false;
  bool _isLoadingDrivers = false;

  // الفلاتر
  String _searchContractorQuery = '';
  String _searchDriverQuery = '';
  String _statusFilter = 'الكل'; // جارية، شبه منتهية، منتهية
  String _timeFilter = 'الكل';
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  // رصيد الخزنة
  double _treasuryBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadContractors();
    _loadTreasuryBalance();
  }

  // ---------------------------
  // تحميل رصيد الخزنة
  // ---------------------------
  Future<void> _loadTreasuryBalance() async {
    try {
      final incomeSnapshot = await _firestore
          .collection('treasury_entries')
          .where('isCleared', isEqualTo: true)
          .get();

      double totalIncome = 0;
      for (var doc in incomeSnapshot.docs) {
        final data = doc.data();
        final amount = data['amount'];
        if (amount != null) {
          totalIncome += (amount as num).toDouble();
        }
      }

      final expenseSnapshot = await _firestore
          .collection('treasury_exits')
          .get();

      double totalExpense = 0;
      for (var doc in expenseSnapshot.docs) {
        final data = doc.data();
        final amount = data['amount'];
        if (amount != null) {
          totalExpense += (amount as num).toDouble();
        }
      }

      setState(() {
        _treasuryBalance = totalIncome - totalExpense;
      });
    } catch (e) {
      print('Error loading treasury balance: $e');
    }
  }

  // ---------------------------
  // إضافة مصروف للخزنة
  // ---------------------------
  Future<void> _addExpenseToTreasury({
    required String recipientName,
    required double amount,
    required String paymentType, // 'سائق' أو 'مقاول'
    required String paymentMethod, // 'كامل' أو 'جزئي'
    required String? contractorName,
    required String? driverName,
  }) async {
    try {
      // إنشاء وصف واضح
      String description = '';
      String expenseType = '';

      if (paymentType == 'سائق') {
        expenseType = 'حساب سواق';
        description = 'حساب السائق $driverName - المقاول $contractorName';
      } else {
        expenseType = 'حساب مقاول';
        description = 'حساب المقاول $recipientName';
      }

      // إضافة "كامل" أو "جزئي" للوصف
      description += ' ($paymentMethod)';

      final expenseData = {
        'amount': amount,
        'expenseType': expenseType,
        'description': description,
        'recipient': recipientName,
        'date': Timestamp.now(),
        'createdAt': Timestamp.now(),
        'category': 'خرج',
        'status': 'مكتمل',
        'paymentMethod': paymentMethod,
        'paymentFor': paymentType,
        'contractorName': contractorName,
        'driverName': driverName,
        'timestamp': Timestamp.now(),
      };

      await _firestore.collection('treasury_exits').add(expenseData);

      // تحديث رصيد الخزنة
      setState(() {
        _treasuryBalance -= amount;
      });

      return;
    } catch (e) {
      print('Error adding expense to treasury: $e');
      throw e;
    }
  }

  // ---------------------------
  // تحميل قائمة المقاولين مع إجمالياتهم
  // ---------------------------
  Future<void> _loadContractors() async {
    setState(() => _isLoading = true);

    try {
      // جلب جميع بيانات السائقين
      final snapshot = await _firestore.collection('drivers').get();

      // تجميع البيانات حسب المقاول
      Map<String, Map<String, dynamic>> contractorsMap = {};

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        final contractor = (data['contractor'] ?? '').toString().trim();
        if (contractor.isEmpty) continue;

        if (!contractorsMap.containsKey(contractor)) {
          contractorsMap[contractor] = {
            'contractorName': contractor,
            'totalKarta': 0.0,
            'totalOhda': 0.0,
            'totalWheelNolon': 0.0,
            'totalWheelOvernight': 0.0,
            'totalWheelHoliday': 0.0,
            'totalNetAmount': 0.0,
            'totalPaidAmount': 0.0,
            'totalRemainingAmount': 0.0,
            'totalDrivers': 0,
            'activeDrivers': 0,
            'finishedDrivers': 0,
            'lastUpdated': null,
          };
        }

        final contractorData = contractorsMap[contractor]!;

        // إضافة أرقام السائق
        contractorData['totalDrivers'] = contractorData['totalDrivers']! + 1;

        // جمع جميع البيانات للحساب الصحيح
        final karta = _parseToDouble(data['karta']);
        final ohda = _parseToDouble(data['ohda']);
        final wheelNolon = _parseToDouble(data['wheelNolon']);
        final wheelOvernight = _parseToDouble(data['wheelOvernight']);
        final wheelHoliday = _parseToDouble(data['wheelHoliday']);
        final paidAmount = _parseToDouble(data['paidAmount']);

        // حساب الصافي: (الكارتة + النولون + المبيت + العطلة) - العهدة
        final netAmount =
            (karta + wheelNolon + wheelOvernight + wheelHoliday) - ohda;

        // تحديث الإجماليات
        contractorData['totalKarta'] = contractorData['totalKarta']! + karta;
        contractorData['totalOhda'] = contractorData['totalOhda']! + ohda;
        contractorData['totalWheelNolon'] =
            contractorData['totalWheelNolon']! + wheelNolon;
        contractorData['totalWheelOvernight'] =
            contractorData['totalWheelOvernight']! + wheelOvernight;
        contractorData['totalWheelHoliday'] =
            contractorData['totalWheelHoliday']! + wheelHoliday;
        contractorData['totalNetAmount'] =
            contractorData['totalNetAmount']! + netAmount;
        contractorData['totalPaidAmount'] =
            contractorData['totalPaidAmount']! + paidAmount;

        // تحديث حالة السائقين
        final remaining = netAmount - paidAmount;
        if (remaining <= 0) {
          contractorData['finishedDrivers'] =
              contractorData['finishedDrivers']! + 1;
        } else {
          contractorData['activeDrivers'] =
              contractorData['activeDrivers']! + 1;
        }

        // تاريخ آخر تحديث
        final tripDate = (data['date'] as Timestamp?)?.toDate();
        if (tripDate != null) {
          if (contractorData['lastUpdated'] == null ||
              tripDate.isAfter(contractorData['lastUpdated'])) {
            contractorData['lastUpdated'] = tripDate;
          }
        }
      }

      // حساب الإجماليات النهائية
      for (var contractor in contractorsMap.values) {
        final totalNetAmount = contractor['totalNetAmount']!;
        final totalPaidAmount = contractor['totalPaidAmount']!;
        contractor['totalRemainingAmount'] = totalNetAmount - totalPaidAmount;
      }

      // تحويل إلى قائمة وترتيب
      List<Map<String, dynamic>> contractorsList = contractorsMap.values
          .toList();
      contractorsList.sort(
        (a, b) => a['contractorName'].compareTo(b['contractorName']),
      );

      setState(() {
        _contractors = contractorsList;
        _filteredContractors = _applyContractorFilters(contractorsList);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('خطأ في تحميل المقاولين: $e');
    }
  }

  // ---------------------------
  // تحميل السائقين التابعين لمقاول مع حساب كل سائق
  // ---------------------------
  Future<void> _loadContractorDrivers(String contractorName) async {
    if (contractorName.isEmpty) return;

    setState(() {
      _selectedContractor = contractorName;
      _isLoadingDrivers = true;
      _driversByContractor.clear();
      _filteredDrivers.clear();
    });

    try {
      final snapshot = await _firestore
          .collection('drivers')
          .where('contractor', isEqualTo: contractorName)
          .get();

      // تجميع السائقين الفريدين مع حساب كل سائق
      Map<String, Map<String, dynamic>> driversMap = {};

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        final driverName = (data['driverName'] ?? '').toString().trim();
        if (driverName.isEmpty) continue;

        if (!driversMap.containsKey(driverName)) {
          driversMap[driverName] = {
            'driverName': driverName,
            'contractor': contractorName,
            'totalKarta': 0.0,
            'totalOhda': 0.0,
            'totalWheelNolon': 0.0,
            'totalWheelOvernight': 0.0,
            'totalWheelHoliday': 0.0,
            'totalNetAmount': 0.0,
            'totalPaidAmount': 0.0,
            'totalRemainingAmount': 0.0,
            'totalTrips': 0,
            'lastTripDate': null,
          };
        }

        final driverData = driversMap[driverName]!;

        // تحديث الإحصائيات
        driverData['totalTrips'] = driverData['totalTrips']! + 1;

        // جمع جميع البيانات للحساب الصحيح
        final karta = _parseToDouble(data['karta']);
        final ohda = _parseToDouble(data['ohda']);
        final wheelNolon = _parseToDouble(data['wheelNolon']);
        final wheelOvernight = _parseToDouble(data['wheelOvernight']);
        final wheelHoliday = _parseToDouble(data['wheelHoliday']);
        final paidAmount = _parseToDouble(data['paidAmount']);

        // حساب الصافي: (الكارتة + النولون + المبيت + العطلة) - العهدة
        final netAmount =
            (karta + wheelNolon + wheelOvernight + wheelHoliday) - ohda;

        // تحديث الإجماليات
        driverData['totalKarta'] = driverData['totalKarta']! + karta;
        driverData['totalOhda'] = driverData['totalOhda']! + ohda;
        driverData['totalWheelNolon'] =
            driverData['totalWheelNolon']! + wheelNolon;
        driverData['totalWheelOvernight'] =
            driverData['totalWheelOvernight']! + wheelOvernight;
        driverData['totalWheelHoliday'] =
            driverData['totalWheelHoliday']! + wheelHoliday;
        driverData['totalNetAmount'] =
            driverData['totalNetAmount']! + netAmount;
        driverData['totalPaidAmount'] =
            driverData['totalPaidAmount']! + paidAmount;

        // تاريخ آخر رحلة
        final tripDate = (data['date'] as Timestamp?)?.toDate();
        if (tripDate != null) {
          if (driverData['lastTripDate'] == null ||
              tripDate.isAfter(driverData['lastTripDate'])) {
            driverData['lastTripDate'] = tripDate;
          }
        }
      }

      // حساب الإجماليات النهائية وتحديد الحالة
      for (var driver in driversMap.values) {
        final totalNetAmount = driver['totalNetAmount']!;
        final totalPaidAmount = driver['totalPaidAmount']!;
        final totalRemainingAmount = totalNetAmount - totalPaidAmount;

        driver['totalRemainingAmount'] = totalRemainingAmount;

        // تحديد حالة الحساب
        String status;
        if (totalRemainingAmount <= 0) {
          status = 'منتهية';
        } else if (totalPaidAmount > 0 && totalRemainingAmount > 0) {
          status = 'شبه منتهية';
        } else {
          status = 'جارية';
        }

        driver['status'] = status;
      }

      // تحويل القائمة وترتيب
      List<Map<String, dynamic>> driversList = driversMap.values.toList();
      driversList.sort(
        (a, b) =>
            b['totalRemainingAmount'].compareTo(a['totalRemainingAmount']),
      );

      setState(() {
        _driversByContractor = driversList;
        _filteredDrivers = _applyDriverFilters(driversList);
        _isLoadingDrivers = false;
      });
    } catch (e) {
      setState(() => _isLoadingDrivers = false);
      _showError('خطأ في تحميل السائقين: $e');
    }
  }

  // ---------------------------
  // تطبيق الفلاتر على المقاولين
  // ---------------------------
  List<Map<String, dynamic>> _applyContractorFilters(
    List<Map<String, dynamic>> contractors,
  ) {
    return contractors.where((contractor) {
      // فلتر البحث
      if (_searchContractorQuery.isNotEmpty) {
        if (!contractor['contractorName'].toLowerCase().contains(
          _searchContractorQuery.toLowerCase(),
        )) {
          return false;
        }
      }

      // فلتر الوقت
      if (_timeFilter != 'الكل') {
        final lastUpdated = contractor['lastUpdated'] as DateTime?;
        if (lastUpdated == null) return false;

        final now = DateTime.now();

        switch (_timeFilter) {
          case 'اليوم':
            if (lastUpdated.year != now.year ||
                lastUpdated.month != now.month ||
                lastUpdated.day != now.day) {
              return false;
            }
            break;
          case 'هذا الشهر':
            if (lastUpdated.year != now.year ||
                lastUpdated.month != now.month) {
              return false;
            }
            break;
          case 'هذه السنة':
            if (lastUpdated.year != now.year) {
              return false;
            }
            break;
          case 'مخصص':
            if (lastUpdated.year != _selectedYear ||
                lastUpdated.month != _selectedMonth) {
              return false;
            }
            break;
        }
      }

      return true;
    }).toList();
  }

  // ---------------------------
  // تطبيق الفلاتر على السائقين
  // ---------------------------
  List<Map<String, dynamic>> _applyDriverFilters(
    List<Map<String, dynamic>> drivers,
  ) {
    return drivers.where((driver) {
      // فلتر البحث
      if (_searchDriverQuery.isNotEmpty) {
        if (!driver['driverName'].toLowerCase().contains(
          _searchDriverQuery.toLowerCase(),
        )) {
          return false;
        }
      }

      // فلتر الحالة
      if (_statusFilter != 'الكل' && driver['status'] != _statusFilter) {
        return false;
      }

      return true;
    }).toList();
  }

  // ---------------------------
  // تغيير فلتر الوقت
  // ---------------------------
  void _changeTimeFilter(String filter) {
    setState(() {
      _timeFilter = filter;
      _filteredContractors = _applyContractorFilters(_contractors);
    });
  }

  // ---------------------------
  // تغيير فلتر الحالة
  // ---------------------------
  void _changeStatusFilter(String filter) {
    setState(() {
      _statusFilter = filter;
      _filteredDrivers = _applyDriverFilters(_driversByContractor);
    });
  }

  // ---------------------------
  // تطبيق فلتر الشهر والسنة
  // ---------------------------
  void _applyMonthYearFilter() {
    setState(() {
      _timeFilter = 'مخصص';
      _filteredContractors = _applyContractorFilters(_contractors);
    });
  }

  // ---------------------------
  // الحصول على نص وصف الفلتر
  // ---------------------------
  String _getFilterText() {
    switch (_timeFilter) {
      case 'اليوم':
        return 'عرض مقاولين اليوم';
      case 'هذا الشهر':
        return 'عرض مقاولين هذا الشهر';
      case 'هذه السنة':
        return 'عرض مقاولين هذه السنة';
      case 'مخصص':
        return 'عرض مقاولين شهر $_selectedMonth سنة $_selectedYear';
      default:
        return 'عرض جميع المقاولين';
    }
  }

  // ---------------------------
  // سداد حساب مقاول (كامل أو جزئي)
  // ---------------------------
  Future<void> _payContractor(Map<String, dynamic> contractor) async {
    final amountController = TextEditingController();
    final contractorName = contractor['contractorName'];
    final remainingAmount = contractor['totalRemainingAmount'] as double;
    String paymentType = 'كامل'; // القيمة الافتراضية

    if (remainingAmount <= 0) {
      _showError('حساب المقاول منتهي بالفعل');
      return;
    }

    // حساب مبالغ سائقي المقاول
    double driversRemaining = 0;
    double driversPaid = 0;

    try {
      final driversSnapshot = await _firestore
          .collection('drivers')
          .where('contractor', isEqualTo: contractorName)
          .get();

      for (final doc in driversSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        final karta = _parseToDouble(data['karta']);
        final ohda = _parseToDouble(data['ohda']);
        final wheelNolon = _parseToDouble(data['wheelNolon']);
        final wheelOvernight = _parseToDouble(data['wheelOvernight']);
        final wheelHoliday = _parseToDouble(data['wheelHoliday']);
        final paidAmount = _parseToDouble(data['paidAmount']);

        final netAmount =
            (karta + wheelNolon + wheelOvernight + wheelHoliday) - ohda;
        driversRemaining += (netAmount - paidAmount);
        driversPaid += paidAmount;
      }
    } catch (e) {
      print('Error calculating drivers amounts: $e');
    }

    await showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: flutter_widgets.TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
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
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'سداد مقاول: $contractorName',
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

                    // رصيد الخزنة
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: _treasuryBalance < remainingAmount
                                ? Colors.red
                                : Colors.blue,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'رصيد الخزنة الحالي',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '${_treasuryBalance.toStringAsFixed(2)} ج',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _treasuryBalance < remainingAmount
                                        ? Colors.red
                                        : Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),

                    // إحصائيات المقاول مع التفاصيل الجديدة
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('العدد الكلي للسائقين:'),
                              Text(
                                '${contractor['totalDrivers']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('السائقين النشطين:'),
                              Text(
                                '${contractor['activeDrivers']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('إجمالي الكارتة:'),
                              Text(
                                '${contractor['totalKarta'].toStringAsFixed(2)} ج',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('إجمالي العهدة:'),
                              Text(
                                '${contractor['totalOhda'].toStringAsFixed(2)} ج',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('إجمالي النولون+المبيت+العطلة:'),
                              Text(
                                '${(contractor['totalWheelNolon'] + contractor['totalWheelOvernight'] + contractor['totalWheelHoliday']).toStringAsFixed(2)} ج',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('إجمالي مدفوعات السائقين:'),
                              Text(
                                '${driversPaid.toStringAsFixed(2)} ج',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('إجمالي متبقي السائقين:'),
                              Text(
                                '${driversRemaining.toStringAsFixed(2)} ج',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),

                    // المبلغ المتبقي
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'المبلغ المستحق للمقاول:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '(الكارتة + النولون + المبيت + العطلة) - العهدة',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${remainingAmount.toStringAsFixed(2)} ج',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // نوع الدفع - مبدئي كامل
                    if (remainingAmount > 0)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ChoiceChip(
                            label: Text('دفع كامل'),
                            selected: paymentType == 'كامل',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  paymentType = 'كامل';
                                  amountController.text = remainingAmount
                                      .toStringAsFixed(2);
                                });
                              }
                            },
                            selectedColor: Colors.green,
                            labelStyle: TextStyle(
                              color: paymentType == 'كامل'
                                  ? Colors.white
                                  : Colors.green,
                            ),
                          ),
                          SizedBox(width: 15),
                          ChoiceChip(
                            label: Text('دفع جزئي'),
                            selected: paymentType == 'جزئي',
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  paymentType = 'جزئي';
                                  amountController.clear();
                                });
                              }
                            },
                            selectedColor: Colors.blue,
                            labelStyle: TextStyle(
                              color: paymentType == 'جزئي'
                                  ? Colors.white
                                  : Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 16),

                    // حقل المبلغ
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: paymentType == 'كامل'
                            ? 'المبلغ الكامل'
                            : 'المبلغ المطلوب دفعه',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
                    SizedBox(height: 20),

                    // زر السداد
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

                              if (paymentAmount > _treasuryBalance) {
                                _showError(
                                  'المبلغ أكبر من الرصيد المتاح في الخزنة',
                                );
                                return;
                              }

                              // تحديد نوع الدفع بناءً على المبلغ
                              final actualPaymentType =
                                  paymentAmount == remainingAmount
                                  ? 'كامل'
                                  : 'جزئي';

                              // عرض تأكيد السداد
                              final confirmed = await _showPaymentConfirmation(
                                recipientName: contractorName,
                                amount: paymentAmount,
                                paymentMethod: actualPaymentType,
                                paymentFor: 'مقاول',
                              );

                              if (!confirmed) return;

                              await _updateContractorPayment(
                                contractorName,
                                paymentAmount,
                                actualPaymentType,
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
                            child: Text(
                              paymentType == 'كامل' ? 'سداد كامل' : 'سداد جزئي',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
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

  // ---------------------------
  // سداد حساب سائق
  // ---------------------------
  Future<void> _makePayment(Map<String, dynamic> driver) async {
    final amountController = TextEditingController();
    final driverName = driver['driverName'];
    final contractorName = driver['contractor'];
    final remainingAmount = driver['totalRemainingAmount'] as double;
    String paymentType = 'كامل'; // القيمة الافتراضية

    if (remainingAmount <= 0) {
      _showError('الحساب منتهي بالفعل');
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: flutter_widgets.TextDirection.rtl,
        child: StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
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
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'سداد سائق: $driverName',
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

                    // رصيد الخزنة
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: _treasuryBalance < remainingAmount
                                ? Colors.red
                                : Colors.blue,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'رصيد الخزنة الحالي',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '${_treasuryBalance.toStringAsFixed(2)} ج',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _treasuryBalance < remainingAmount
                                        ? Colors.red
                                        : Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),

                    // معلومات السائق مع التفاصيل الجديدة
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('المقاول:'),
                              Text(
                                contractorName,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('عدد الرحلات:'),
                              Text(
                                '${driver['totalTrips']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('إجمالي الكارتة:'),
                              Text(
                                '${driver['totalKarta'].toStringAsFixed(2)} ج',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('إجمالي العهدة:'),
                              Text(
                                '${driver['totalOhda'].toStringAsFixed(2)} ج',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('إجمالي النولون:'),
                              Text(
                                '${driver['totalWheelNolon'].toStringAsFixed(2)} ج',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('إجمالي المبيت:'),
                              Text(
                                '${driver['totalWheelOvernight'].toStringAsFixed(2)} ج',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('إجمالي العطلة:'),
                              Text(
                                '${driver['totalWheelHoliday'].toStringAsFixed(2)} ج',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('المدفوع:'),
                              Text(
                                '${driver['totalPaidAmount'].toStringAsFixed(2)} ج',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12),

                    // المبلغ المتبقي
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'المبلغ المستحق للسائق:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '(الكارتة + النولون + المبيت + العطلة) - العهدة',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${remainingAmount.toStringAsFixed(2)} ج',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    // نوع الدفع
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ChoiceChip(
                          label: Text('دفع كامل'),
                          selected: paymentType == 'كامل',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                paymentType = 'كامل';
                                amountController.text = remainingAmount
                                    .toStringAsFixed(2);
                              });
                            }
                          },
                          selectedColor: Colors.green,
                          labelStyle: TextStyle(
                            color: paymentType == 'كامل'
                                ? Colors.white
                                : Colors.green,
                          ),
                        ),
                        ChoiceChip(
                          label: Text('دفع جزئي'),
                          selected: paymentType == 'جزئي',
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                paymentType = 'جزئي';
                                amountController.clear();
                              });
                            }
                          },
                          selectedColor: Colors.blue,
                          labelStyle: TextStyle(
                            color: paymentType == 'جزئي'
                                ? Colors.white
                                : Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // حقل المبلغ
                    TextFormField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: paymentType == 'كامل'
                            ? 'المبلغ الكامل'
                            : 'المبلغ المطلوب دفعه',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                    ),
                    SizedBox(height: 20),

                    // زر السداد
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

                              if (paymentAmount > _treasuryBalance) {
                                _showError(
                                  'المبلغ أكبر من الرصيد المتاح في الخزنة',
                                );
                                return;
                              }

                              // تحديد نوع الدفع بناءً على المبلغ
                              final actualPaymentType =
                                  paymentAmount == remainingAmount
                                  ? 'كامل'
                                  : 'جزئي';

                              // عرض تأكيد السداد
                              final confirmed = await _showPaymentConfirmation(
                                recipientName: driverName,
                                amount: paymentAmount,
                                paymentMethod: actualPaymentType,
                                paymentFor: 'سائق',
                                contractorName: contractorName,
                              );

                              if (!confirmed) return;

                              await _updateDriverPayment(
                                driverName,
                                paymentAmount,
                                actualPaymentType,
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
                            child: Text(
                              paymentType == 'كامل' ? 'سداد كامل' : 'سداد جزئي',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
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

  // ---------------------------
  // تأكيد الدفع
  // ---------------------------
  Future<bool> _showPaymentConfirmation({
    required String recipientName,
    required double amount,
    required String paymentMethod,
    required String paymentFor, // 'سائق' أو 'مقاول'
    String? contractorName,
  }) async {
    bool confirmed = false;

    String paymentForText = paymentFor == 'سائق' ? 'سائق' : 'مقاول';
    String description = paymentFor == 'سائق'
        ? 'سائق $recipientName - المقاول $contractorName'
        : 'مقاول $recipientName';

    await showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: flutter_widgets.TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(Icons.payment, color: Colors.orange),
              SizedBox(width: 8),
              Text('تأكيد الدفع ($paymentMethod)'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('هل أنت متأكد من دفع ${amount.toStringAsFixed(2)} ج'),
              Text('لـ$paymentForText $recipientName؟'),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: paymentMethod == 'كامل'
                      ? Colors.green[50]
                      : Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          paymentMethod == 'كامل'
                              ? Icons.check_circle
                              : Icons.payment,
                          color: paymentMethod == 'كامل'
                              ? Colors.green
                              : Colors.blue,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'تفاصيل الدفع ($paymentMethod)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: paymentMethod == 'كامل'
                                ? Colors.green[800]
                                : Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('النوع: $paymentForText'),
                    Text('الاسم: $description'),
                    Text('المبلغ: ${amount.toStringAsFixed(2)} ج'),
                    Text('طريقة الدفع: $paymentMethod'),
                    Text(
                      'التاريخ: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'سيتم خصم المبلغ من الخزنة تلقائياً',
                  style: TextStyle(color: Colors.orange[800]),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                confirmed = true;
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: paymentMethod == 'كامل'
                    ? Colors.green
                    : Colors.blue,
              ),
              child: Text('تأكيد الدفع ($paymentMethod)'),
            ),
          ],
        ),
      ),
    );

    return confirmed;
  }

  // ---------------------------
  // تحديث دفع المقاول
  // ---------------------------
  Future<void> _updateContractorPayment(
    String contractorName,
    double paymentAmount,
    String paymentMethod,
  ) async {
    try {
      // 1. تحديث رحلات سائقي المقاول
      await _updateContractorDriverTrips(contractorName, paymentAmount);

      // 2. إضافة المصروف للخزنة
      await _addExpenseToTreasury(
        recipientName: contractorName,
        amount: paymentAmount,
        paymentType: 'مقاول',
        paymentMethod: paymentMethod,
        contractorName: contractorName,
        driverName: null,
      );

      // 3. إعادة تحميل البيانات
      await _loadContractors();
      if (_selectedContractor != null) {
        await _loadContractorDrivers(_selectedContractor!);
      }

      _showSuccess(
        'تم سداد ${paymentAmount.toStringAsFixed(2)} ج للمقاول $contractorName ($paymentMethod)',
      );
    } catch (e) {
      _showError('خطأ في السداد: $e');
    }
  }

  // ---------------------------
  // تحديث رحلات سائقي المقاول
  // ---------------------------
  Future<void> _updateContractorDriverTrips(
    String contractorName,
    double paymentAmount,
  ) async {
    try {
      // جلب جميع رحلات سائقي المقاول
      final snapshot = await _firestore
          .collection('drivers')
          .where('contractor', isEqualTo: contractorName)
          .get();

      double remainingPayment = paymentAmount;

      // توزيع المبلغ على رحلات السائقين حسب المستحق
      List<Map<String, dynamic>> tripsWithRemaining = [];

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        final karta = _parseToDouble(data['karta']);
        final ohda = _parseToDouble(data['ohda']);
        final wheelNolon = _parseToDouble(data['wheelNolon']);
        final wheelOvernight = _parseToDouble(data['wheelOvernight']);
        final wheelHoliday = _parseToDouble(data['wheelHoliday']);
        final currentPaid = _parseToDouble(data['paidAmount']);

        // حساب الصافي: (الكارتة + النولون + المبيت + العطلة) - العهدة
        final netAmount =
            (karta + wheelNolon + wheelOvernight + wheelHoliday) - ohda;
        final tripRemaining = netAmount - currentPaid;

        if (tripRemaining > 0) {
          tripsWithRemaining.add({'doc': doc, 'remaining': tripRemaining});
        }
      }

      // توزيع المدفوعات بالتساوي على الرحلات
      for (var trip in tripsWithRemaining) {
        if (remainingPayment <= 0) break;

        final doc = trip['doc'] as QueryDocumentSnapshot;
        final tripRemaining = trip['remaining'] as double;
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        final karta = _parseToDouble(data['karta']);
        final ohda = _parseToDouble(data['ohda']);
        final wheelNolon = _parseToDouble(data['wheelNolon']);
        final wheelOvernight = _parseToDouble(data['wheelOvernight']);
        final wheelHoliday = _parseToDouble(data['wheelHoliday']);
        final currentPaid = _parseToDouble(data['paidAmount']);

        // حساب الصافي: (الكارتة + النولون + المبيت + العطلة) - العهدة
        final netAmount =
            (karta + wheelNolon + wheelOvernight + wheelHoliday) - ohda;
        final toPay = remainingPayment > tripRemaining
            ? tripRemaining
            : remainingPayment;
        final newPaidAmount = currentPaid + toPay;
        final isFullyPaid = newPaidAmount >= netAmount;

        await doc.reference.update({
          'paidAmount': newPaidAmount,
          'isPaid': isFullyPaid,
          'remainingAmount': netAmount - newPaidAmount,
        });

        remainingPayment -= toPay;
      }
    } catch (e) {
      print('خطأ في تحديث رحلات سائقي المقاول: $e');
    }
  }

  // ---------------------------
  // تحديث دفع السائق
  // ---------------------------
  Future<void> _updateDriverPayment(
    String driverName,
    double paymentAmount,
    String paymentMethod,
  ) async {
    try {
      // 1. تحديث رحلات السائق الفردية
      await _updateIndividualDriverTrips(driverName, paymentAmount);

      // 2. إضافة المصروف للخزنة
      await _addExpenseToTreasury(
        recipientName: driverName,
        amount: paymentAmount,
        paymentType: 'سائق',
        paymentMethod: paymentMethod,
        contractorName: _selectedContractor,
        driverName: driverName,
      );

      // 3. إعادة تحميل بيانات السائقين بعد السداد
      await _loadContractorDrivers(_selectedContractor!);

      _showSuccess(
        'تم سداد ${paymentAmount.toStringAsFixed(2)} ج للسائق $driverName ($paymentMethod)',
      );
    } catch (e) {
      _showError('خطأ في السداد: $e');
    }
  }

  // ---------------------------
  // تحديث رحلات السائق الفردية
  // ---------------------------
  Future<void> _updateIndividualDriverTrips(
    String driverName,
    double paymentAmount,
  ) async {
    try {
      final snapshot = await _firestore
          .collection('drivers')
          .where('driverName', isEqualTo: driverName)
          .where('contractor', isEqualTo: _selectedContractor)
          .get();

      double remainingPayment = paymentAmount;

      // جمع الرحلات التي بها متبقي
      List<Map<String, dynamic>> tripsWithRemaining = [];

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        final karta = _parseToDouble(data['karta']);
        final ohda = _parseToDouble(data['ohda']);
        final wheelNolon = _parseToDouble(data['wheelNolon']);
        final wheelOvernight = _parseToDouble(data['wheelOvernight']);
        final wheelHoliday = _parseToDouble(data['wheelHoliday']);
        final currentPaid = _parseToDouble(data['paidAmount']);

        // حساب الصافي: (الكارتة + النولون + المبيت + العطلة) - العهدة
        final netAmount =
            (karta + wheelNolon + wheelOvernight + wheelHoliday) - ohda;
        final tripRemaining = netAmount - currentPaid;

        if (tripRemaining > 0) {
          tripsWithRemaining.add({'doc': doc, 'remaining': tripRemaining});
        }
      }

      // ترتيب الرحلات حسب التاريخ (الأقدم أولاً)
      tripsWithRemaining.sort((a, b) {
        final dateA =
            (a['doc'].data()['date'] as Timestamp?)?.toDate() ?? DateTime.now();
        final dateB =
            (b['doc'].data()['date'] as Timestamp?)?.toDate() ?? DateTime.now();
        return dateA.compareTo(dateB);
      });

      // توزيع المدفوعات
      for (var trip in tripsWithRemaining) {
        if (remainingPayment <= 0) break;

        final doc = trip['doc'] as QueryDocumentSnapshot;
        final tripRemaining = trip['remaining'] as double;
        final data = doc.data() as Map<String, dynamic>?;
        if (data == null) continue;

        final karta = _parseToDouble(data['karta']);
        final ohda = _parseToDouble(data['ohda']);
        final wheelNolon = _parseToDouble(data['wheelNolon']);
        final wheelOvernight = _parseToDouble(data['wheelOvernight']);
        final wheelHoliday = _parseToDouble(data['wheelHoliday']);
        final currentPaid = _parseToDouble(data['paidAmount']);

        // حساب الصافي: (الكارتة + النولون + المبيت + العطلة) - العهدة
        final netAmount =
            (karta + wheelNolon + wheelOvernight + wheelHoliday) - ohda;
        final toPay = remainingPayment > tripRemaining
            ? tripRemaining
            : remainingPayment;
        final newPaidAmount = currentPaid + toPay;
        final isFullyPaid = newPaidAmount >= netAmount;

        await doc.reference.update({
          'paidAmount': newPaidAmount,
          'isPaid': isFullyPaid,
          'remainingAmount': netAmount - newPaidAmount,
        });

        remainingPayment -= toPay;
      }
    } catch (e) {
      print('خطأ في تحديث الرحلات: $e');
    }
  }

  // دالة مساعدة لتحويل إلى double
  double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      try {
        return double.tryParse(value) ?? 0.0;
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  // ---------------------------
  // العودة للخلف
  // ---------------------------
  void _goBack() {
    setState(() {
      _selectedContractor = null;
      _driversByContractor.clear();
      _filteredDrivers.clear();
    });
  }

  // ---------------------------
  // AppBar
  // ---------------------------
  Widget _buildCustomAppBar() {
    String title = 'حسابات المقاولين';

    if (_selectedContractor != null) {
      title = 'حسابات السائقين - $_selectedContractor';
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
            if (_selectedContractor != null)
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _goBack,
              ),

            Icon(
              _selectedContractor != null ? Icons.person : Icons.business,
              color: Colors.white,
              size: 28,
            ),
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

            // رصيد الخزنة
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '${_treasuryBalance.toStringAsFixed(0)} ج',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
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

  // ---------------------------
  // قسم فلتر الوقت للمقاولين
  // ---------------------------
  Widget _buildTimeFilterSection() {
    if (_selectedContractor != null) return SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.white,
      child: Column(
        children: [
          // شريط وصف الفلتر
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.filter_alt, color: Color(0xFF3498DB), size: 16),
                SizedBox(width: 8),
                Text(
                  _getFilterText(),
                  style: TextStyle(
                    color: Color(0xFF3498DB),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['الكل', 'اليوم', 'هذا الشهر', 'هذه السنة', 'مخصص']
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: _timeFilter == filter,
                        onSelected: (selected) {
                          if (selected) _changeTimeFilter(filter);
                        },
                        selectedColor: const Color(0xFF3498DB),
                        labelStyle: TextStyle(
                          color: _timeFilter == filter
                              ? Colors.white
                              : const Color(0xFF2C3E50),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          if (_timeFilter == 'مخصص')
            Container(
              margin: EdgeInsets.only(top: 12),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month, color: Color(0xFF3498DB)),
                  SizedBox(width: 8),
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
                  SizedBox(width: 20),
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
            ),
        ],
      ),
    );
  }

  // ---------------------------
  // قسم فلتر الحالة للسائقين
  // ---------------------------
  Widget _buildStatusFilterSection() {
    if (_selectedContractor == null) return SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatusFilterBox('الكل', Colors.grey, Icons.all_inclusive),
          _buildStatusFilterBox('جارية', Color(0xFFE74C3C), Icons.access_time),
          _buildStatusFilterBox(
            'شبه منتهية',
            Color(0xFFF39C12),
            Icons.hourglass_bottom,
          ),
          _buildStatusFilterBox(
            'منتهية',
            Color(0xFF27AE60),
            Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterBox(String status, Color color, IconData icon) {
    final isSelected = _statusFilter == status;

    return GestureDetector(
      onTap: () => _changeStatusFilter(status),
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 18),
            const SizedBox(height: 4),
            Text(
              status,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------
  // واجهة قائمة المقاولين
  // ---------------------------
  Widget _buildContractorsList() {
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
                _filteredContractors = _applyContractorFilters(_contractors);
              });
            },
          ),
        ),

        // قائمة المقاولين
        Expanded(
          child: _filteredContractors.isEmpty
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
                  itemCount: _filteredContractors.length,
                  itemBuilder: (context, index) {
                    final contractor = _filteredContractors[index];
                    final remainingAmount =
                        contractor['totalRemainingAmount'] as double;
                    final activeDrivers = contractor['activeDrivers'] as int;
                    final totalDrivers = contractor['totalDrivers'] as int;

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
                              contractor['contractorName']
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          contractor['contractorName'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '$totalDrivers سائق',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                            remainingAmount >= 0
                                ? Text(
                                    'المتبقي: ${remainingAmount.toStringAsFixed(2)} ج',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Text(
                                    'المتبقي: ${remainingAmount.toStringAsFixed(2)} ج',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ],
                        ),
                        trailing: remainingAmount > 0
                            ? SizedBox(
                                height: 32,
                                child: ElevatedButton(
                                  onPressed: () => _payContractor(contractor),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF27AE60),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'سداد',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFF3498DB),
                                size: 16,
                              ),
                        onTap: () => _loadContractorDrivers(
                          contractor['contractorName'],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ---------------------------
  // واجهة قائمة السائقين
  // ---------------------------
  Widget _buildDriversList() {
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
                _filteredDrivers = _applyDriverFilters(_driversByContractor);
              });
            },
          ),
        ),

        // فلتر الحالة
        _buildStatusFilterSection(),

        // معلومات المقاول
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'عدد السائقين: ${_filteredDrivers.length}',
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
          child: _filteredDrivers.isEmpty
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
                  itemCount: _filteredDrivers.length,
                  itemBuilder: (context, index) {
                    final driver = _filteredDrivers[index];
                    final remainingAmount =
                        driver['totalRemainingAmount'] as double;
                    final paidAmount = driver['totalPaidAmount'] as double;
                    final status = driver['status'];
                    final isCompleted = status == 'منتهية';

                    // حساب الإجماليات للعرض
                    final totalKarta = driver['totalKarta'] as double;
                    final totalOhda = driver['totalOhda'] as double;
                    final totalWheelNolon = driver['totalWheelNolon'] as double;
                    final totalWheelOvernight =
                        driver['totalWheelOvernight'] as double;
                    final totalWheelHoliday =
                        driver['totalWheelHoliday'] as double;

                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCompleted
                              ? Colors.green.withOpacity(0.3)
                              : Color(0xFF3498DB).withOpacity(0.3),
                        ),
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
                          backgroundColor: _getStatusColor(status),
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
                                SizedBox(width: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      status,
                                    ).withOpacity(0.1),
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
                            SizedBox(height: 2),
                            if (!isCompleted && remainingAmount > 0)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'المتبقي: ${remainingAmount.toStringAsFixed(2)} ج',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'الصافي: (${totalKarta.toStringAsFixed(0)} + ${totalWheelNolon.toStringAsFixed(0)} + ${totalWheelOvernight.toStringAsFixed(0)} + ${totalWheelHoliday.toStringAsFixed(0)}) - ${totalOhda.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              )
                            else
                              Text(
                                'المدفوع: ${paidAmount.toStringAsFixed(2)} ج',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        trailing: !isCompleted && remainingAmount > 0
                            ? SizedBox(
                                height: 32,
                                child: ElevatedButton(
                                  onPressed: () => _makePayment(driver),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF27AE60),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'سداد',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              )
                            : Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'منتهي',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                      ),
                    );
                  },
                ),
        ),
      ],
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

  // ---------------------------
  // الواجهة الرئيسية
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _buildCustomAppBar(),
          if (_selectedContractor == null) _buildTimeFilterSection(),
          Expanded(
            child: _selectedContractor != null
                ? _buildDriversList()
                : _buildContractorsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _loadTreasuryBalance();
          if (_selectedContractor != null) {
            _loadContractorDrivers(_selectedContractor!);
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
