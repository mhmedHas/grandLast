// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';

// // class ExpensePage extends StatefulWidget {
// //   const ExpensePage({super.key});

// //   @override
// //   State<ExpensePage> createState() => _ExpensePageState();
// // }

// // class _ExpensePageState extends State<ExpensePage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   final TextEditingController _amountController = TextEditingController();
// //   final TextEditingController _descriptionController = TextEditingController();
// //   final TextEditingController _recipientController = TextEditingController();

// //   // أنواع الخروج المالي
// //   final List<Map<String, dynamic>> _expenseTypes = [
// //     {'name': 'نقدي', 'icon': Icons.money_off, 'color': Colors.red},
// //     {'name': 'شيك تم صرفه', 'icon': Icons.check_circle, 'color': Colors.blue},
// //     {'name': 'نثريات', 'icon': Icons.shopping_cart, 'color': Colors.purple},
// //     {'name': 'مصروفات تشغيل', 'icon': Icons.business, 'color': Colors.orange},
// //     {'name': 'مرتبات', 'icon': Icons.people, 'color': Colors.teal},
// //     {'name': 'فاتورة كهرباء', 'icon': Icons.lightbulb, 'color': Colors.yellow},
// //     {'name': 'فاتورة مياه', 'icon': Icons.water_drop, 'color': Colors.blue},
// //     {'name': 'أخرى', 'icon': Icons.more_horiz, 'color': Colors.grey},
// //   ];

// //   String _selectedExpenseType = 'نقدي';
// //   DateTime _selectedDate = DateTime.now();
// //   bool _isLoading = false;
// //   double _totalExpenses = 0.0;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadTotalExpenses();
// //   }

// //   Future<void> _loadTotalExpenses() async {
// //     try {
// //       final snapshot = await _firestore.collection('treasury_exits').get();

// //       double total = 0;
// //       for (var doc in snapshot.docs) {
// //         total += (doc.data()['amount'] as num).toDouble();
// //       }

// //       setState(() {
// //         _totalExpenses = total;
// //       });
// //     } catch (e) {
// //       print('Error loading expenses: $e');
// //     }
// //   }

// //   Future<void> _addExpense() async {
// //     if (_amountController.text.isEmpty) {
// //       _showSnackBar('الرجاء إدخال المبلغ', Colors.red);
// //       return;
// //     }

// //     final amount = double.tryParse(_amountController.text);
// //     if (amount == null || amount <= 0) {
// //       _showSnackBar('الرجاء إدخال مبلغ صحيح', Colors.red);
// //       return;
// //     }

// //     setState(() => _isLoading = true);

// //     try {
// //       final expenseData = {
// //         'amount': amount,
// //         'expenseType': _selectedExpenseType,
// //         'description': _descriptionController.text,
// //         'recipient': _recipientController.text,
// //         'date': Timestamp.fromDate(_selectedDate),
// //         'createdAt': Timestamp.now(),
// //         'category': 'خرج',
// //       };

// //       await _firestore.collection('treasury_exits').add(expenseData);

// //       // تحديث الإجمالي
// //       setState(() => _totalExpenses += amount);

// //       // إضافة لسجل الحركات العام
// //       await _firestore.collection('treasury_movements').add({
// //         'amount': amount,
// //         'type': 'expense',
// //         'description':
// //             '${_selectedExpenseType}: ${_descriptionController.text.isNotEmpty ? _descriptionController.text : 'مصروف نقدي'}',
// //         'date': Timestamp.now(),
// //         'expenseType': _selectedExpenseType,
// //       });

// //       _showSnackBar('تم إضافة المصروف بنجاح', Colors.green);
// //       _resetForm();
// //     } catch (e) {
// //       _showSnackBar('حدث خطأ: $e', Colors.red);
// //     } finally {
// //       setState(() => _isLoading = false);
// //     }
// //   }

// //   Widget _buildExpenseForm() {
// //     return SingleChildScrollView(
// //       padding: const EdgeInsets.all(16),
// //       child: Column(
// //         children: [
// //           // بطاقة الإجمالي
// //           Card(
// //             elevation: 3,
// //             child: Padding(
// //               padding: const EdgeInsets.all(16),
// //               child: Row(
// //                 children: [
// //                   Icon(Icons.trending_down, color: Colors.red, size: 32),
// //                   const SizedBox(width: 16),
// //                   Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       const Text(
// //                         'إجمالي المصروفات',
// //                         style: TextStyle(fontSize: 14, color: Colors.grey),
// //                       ),
// //                       Text(
// //                         '${_totalExpenses.toStringAsFixed(2)} ج',
// //                         style: const TextStyle(
// //                           fontSize: 24,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.red,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),

// //           const SizedBox(height: 20),

// //           // نوع المصروف
// //           DropdownButtonFormField<String>(
// //             value: _selectedExpenseType,
// //             decoration: InputDecoration(
// //               labelText: 'نوع المصروف',
// //               prefixIcon: Icon(Icons.category, color: Colors.red),
// //               border: OutlineInputBorder(
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //             ),
// //             items: _expenseTypes.map((type) {
// //               return DropdownMenuItem<String>(
// //                 value: type['name'],
// //                 child: Row(
// //                   children: [
// //                     Icon(type['icon'], color: type['color'], size: 20),
// //                     const SizedBox(width: 12),
// //                     Text(type['name']),
// //                   ],
// //                 ),
// //               );
// //             }).toList(),
// //             onChanged: (value) {
// //               setState(() => _selectedExpenseType = value!);
// //             },
// //           ),

// //           const SizedBox(height: 16),

// //           // المبلغ
// //           TextField(
// //             controller: _amountController,
// //             keyboardType: TextInputType.number,
// //             decoration: InputDecoration(
// //               labelText: 'المبلغ',
// //               prefixText: 'ج ',
// //               prefixIcon: Icon(Icons.attach_money, color: Colors.red),
// //               border: OutlineInputBorder(
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //             ),
// //           ),

// //           const SizedBox(height: 16),

// //           // المستلم (للشيكات)
// //           if (_selectedExpenseType.contains('شيك'))
// //             TextField(
// //               controller: _recipientController,
// //               decoration: InputDecoration(
// //                 labelText: 'المستلم',
// //                 prefixIcon: Icon(Icons.person, color: Colors.blue),
// //                 border: OutlineInputBorder(
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //                 hintText: 'اسم الشخص/الشركة المستلم',
// //               ),
// //             ),

// //           if (_selectedExpenseType.contains('شيك')) const SizedBox(height: 16),

// //           // التاريخ
// //           Container(
// //             padding: const EdgeInsets.all(12),
// //             decoration: BoxDecoration(
// //               border: Border.all(color: Colors.grey[300]!),
// //               borderRadius: BorderRadius.circular(12),
// //             ),
// //             child: Row(
// //               children: [
// //                 Icon(Icons.calendar_today, color: Colors.red, size: 20),
// //                 const SizedBox(width: 12),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       const Text(
// //                         'تاريخ المصروف',
// //                         style: TextStyle(fontSize: 12, color: Colors.grey),
// //                       ),
// //                       Text(
// //                         DateFormat('yyyy/MM/dd').format(_selectedDate),
// //                         style: const TextStyle(
// //                           fontWeight: FontWeight.bold,
// //                           fontSize: 16,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 IconButton(
// //                   onPressed: () async {
// //                     final DateTime? picked = await showDatePicker(
// //                       context: context,
// //                       initialDate: _selectedDate,
// //                       firstDate: DateTime(2000),
// //                       lastDate: DateTime(2100),
// //                     );
// //                     if (picked != null) {
// //                       setState(() => _selectedDate = picked);
// //                     }
// //                   },
// //                   icon: Icon(Icons.edit, size: 20),
// //                   style: IconButton.styleFrom(
// //                     backgroundColor: Colors.red.withOpacity(0.1),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),

// //           const SizedBox(height: 16),

// //           // الوصف
// //           TextField(
// //             controller: _descriptionController,
// //             maxLines: 2,
// //             decoration: InputDecoration(
// //               labelText: 'الوصف / الملاحظات',
// //               prefixIcon: Icon(Icons.description, color: Colors.grey),
// //               border: OutlineInputBorder(
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //               hintText: 'أضف وصفاً للمصروف...',
// //             ),
// //           ),

// //           const SizedBox(height: 24),

// //           // زر الإضافة
// //           SizedBox(
// //             width: double.infinity,
// //             child: ElevatedButton(
// //               onPressed: _isLoading ? null : _addExpense,
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: Colors.red,
// //                 padding: const EdgeInsets.symmetric(vertical: 16),
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //               ),
// //               child: _isLoading
// //                   ? SizedBox(
// //                       width: 24,
// //                       height: 24,
// //                       child: CircularProgressIndicator(
// //                         strokeWidth: 2,
// //                         color: Colors.white,
// //                       ),
// //                     )
// //                   : const Row(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         Icon(Icons.add, color: Colors.white),
// //                         SizedBox(width: 8),
// //                         Text(
// //                           'إضافة مصروف',
// //                           style: TextStyle(
// //                             fontSize: 18,
// //                             fontWeight: FontWeight.bold,
// //                             color: Colors.white,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildRecentExpenses() {
// //     return StreamBuilder<QuerySnapshot>(
// //       stream: _firestore
// //           .collection('treasury_exits')
// //           .orderBy('date', descending: true)
// //           .limit(20)
// //           .snapshots(),
// //       builder: (context, snapshot) {
// //         if (!snapshot.hasData) {
// //           return const Center(child: CircularProgressIndicator());
// //         }

// //         final docs = snapshot.data!.docs;

// //         return Card(
// //           margin: const EdgeInsets.all(16),
// //           child: Padding(
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 const Text(
// //                   'آخر المصروفات',
// //                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
// //                 ),
// //                 const SizedBox(height: 12),
// //                 ...docs.map((doc) {
// //                   final data = doc.data() as Map<String, dynamic>;
// //                   final date = (data['date'] as Timestamp).toDate();
// //                   final expenseType = data['expenseType'] as String;
// //                   final amount = (data['amount'] as num).toDouble();

// //                   return Card(
// //                     margin: const EdgeInsets.only(bottom: 8),
// //                     child: ListTile(
// //                       leading: CircleAvatar(
// //                         backgroundColor: _getTypeColor(
// //                           expenseType,
// //                         ).withOpacity(0.1),
// //                         child: Icon(
// //                           _getTypeIcon(expenseType),
// //                           color: _getTypeColor(expenseType),
// //                           size: 20,
// //                         ),
// //                       ),
// //                       title: Text(
// //                         '${amount.toStringAsFixed(2)} ج',
// //                         style: TextStyle(
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.red,
// //                           fontSize: 16,
// //                         ),
// //                       ),
// //                       subtitle: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           const SizedBox(height: 4),
// //                           Text(expenseType),
// //                           const SizedBox(height: 2),
// //                           Text(
// //                             DateFormat('yyyy/MM/dd').format(date),
// //                             style: const TextStyle(fontSize: 12),
// //                           ),
// //                           if (data['description'] != null &&
// //                               data['description'].isNotEmpty)
// //                             Padding(
// //                               padding: const EdgeInsets.only(top: 4),
// //                               child: Text(
// //                                 data['description'],
// //                                 style: TextStyle(
// //                                   fontSize: 12,
// //                                   color: Colors.grey[600],
// //                                 ),
// //                               ),
// //                             ),
// //                           if (data['recipient'] != null &&
// //                               data['recipient'].isNotEmpty)
// //                             Padding(
// //                               padding: const EdgeInsets.only(top: 2),
// //                               child: Text(
// //                                 'المستلم: ${data['recipient']}',
// //                                 style: TextStyle(
// //                                   fontSize: 11,
// //                                   color: Colors.blue[600],
// //                                 ),
// //                               ),
// //                             ),
// //                         ],
// //                       ),
// //                       trailing: PopupMenuButton<String>(
// //                         itemBuilder: (context) => [
// //                           const PopupMenuItem(
// //                             value: 'edit',
// //                             child: Row(
// //                               children: [
// //                                 Icon(Icons.edit, size: 18),
// //                                 SizedBox(width: 8),
// //                                 Text('تعديل'),
// //                               ],
// //                             ),
// //                           ),
// //                           const PopupMenuItem(
// //                             value: 'delete',
// //                             child: Row(
// //                               children: [
// //                                 Icon(Icons.delete, color: Colors.red, size: 18),
// //                                 SizedBox(width: 8),
// //                                 Text(
// //                                   'حذف',
// //                                   style: TextStyle(color: Colors.red),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ],
// //                         onSelected: (value) {
// //                           // تنفيذ التعديل أو الحذف
// //                         },
// //                       ),
// //                     ),
// //                   );
// //                 }).toList(),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Color _getTypeColor(String type) {
// //     for (var expenseType in _expenseTypes) {
// //       if (expenseType['name'] == type) {
// //         return expenseType['color'];
// //       }
// //     }
// //     return Colors.grey;
// //   }

// //   IconData _getTypeIcon(String type) {
// //     for (var expenseType in _expenseTypes) {
// //       if (expenseType['name'] == type) {
// //         return expenseType['icon'];
// //       }
// //     }
// //     return Icons.money_off;
// //   }

// //   void _resetForm() {
// //     _amountController.clear();
// //     _descriptionController.clear();
// //     _recipientController.clear();
// //     _selectedExpenseType = 'نقدي';
// //     _selectedDate = DateTime.now();
// //   }

// //   void _showSnackBar(String message, Color color) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         backgroundColor: color,
// //         behavior: SnackBarBehavior.floating,
// //       ),
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return DefaultTabController(
// //       length: 2,
// //       child: Scaffold(
// //         appBar: AppBar(
// //           title: const Text('الخارج من الخزنة'),
// //           centerTitle: true,
// //           backgroundColor: const Color(0xFF1B4F72),
// //           elevation: 0,
// //           actions: [
// //             IconButton(
// //               onPressed: _loadTotalExpenses,
// //               icon: const Icon(Icons.refresh),
// //             ),
// //           ],
// //           bottom: const TabBar(
// //             tabs: [
// //               Tab(icon: Icon(Icons.add), text: 'إضافة مصروف'),
// //               Tab(icon: Icon(Icons.list), text: 'السجل'),
// //             ],
// //           ),
// //         ),
// //         body: TabBarView(
// //           children: [
// //             _buildExpenseForm(),
// //             SingleChildScrollView(child: _buildRecentExpenses()),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _amountController.dispose();
// //     _descriptionController.dispose();
// //     _recipientController.dispose();
// //     super.dispose();
// //   }
// // }
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class ExpensePage extends StatefulWidget {
//   const ExpensePage({super.key});

//   @override
//   State<ExpensePage> createState() => _ExpensePageState();
// }

// class _ExpensePageState extends State<ExpensePage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _recipientController = TextEditingController();

//   // أنواع الخروج المالي
//   final List<Map<String, dynamic>> _expenseTypes = [
//     {'name': 'نقدي', 'icon': Icons.money_off, 'color': Colors.red},
//     {'name': 'شيك تم صرفه', 'icon': Icons.check_circle, 'color': Colors.blue},
//     {'name': 'نثريات', 'icon': Icons.shopping_cart, 'color': Colors.purple},
//     {'name': 'مصروفات تشغيل', 'icon': Icons.business, 'color': Colors.orange},
//     {'name': 'أخرى', 'icon': Icons.more_horiz, 'color': Colors.grey},
//   ];

//   String _selectedExpenseType = 'نقدي';
//   DateTime _selectedDate = DateTime.now();
//   bool _isLoading = false;
//   double _treasuryBalance = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _loadTreasuryBalance();
//   }

//   // تحميل رصيد الخزنة
//   Future<void> _loadTreasuryBalance() async {
//     try {
//       final incomeSnapshot = await _firestore
//           .collection('treasury_entries')
//           .where('isCleared', isEqualTo: true)
//           .get();

//       double totalIncome = 0;
//       for (var doc in incomeSnapshot.docs) {
//         totalIncome += (doc.data()['amount'] as num).toDouble();
//       }

//       final expenseSnapshot = await _firestore
//           .collection('treasury_exits')
//           .get();

//       double totalExpense = 0;
//       for (var doc in expenseSnapshot.docs) {
//         totalExpense += (doc.data()['amount'] as num).toDouble();
//       }

//       setState(() {
//         _treasuryBalance = totalIncome - totalExpense;
//       });
//     } catch (e) {
//       print('Error loading treasury balance: $e');
//     }
//   }

//   Future<void> _addExpense() async {
//     if (_amountController.text.isEmpty) {
//       _showSnackBar('الرجاء إدخال المبلغ', Colors.red);
//       return;
//     }

//     final amount = double.tryParse(_amountController.text);
//     if (amount == null || amount <= 0) {
//       _showSnackBar('الرجاء إدخال مبلغ صحيح', Colors.red);
//       return;
//     }

//     if (amount > _treasuryBalance) {
//       _showSnackBar('المبلغ أكبر من الرصيد المتاح', Colors.red);
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final expenseData = {
//         'amount': amount,
//         'expenseType': _selectedExpenseType,
//         'description': _descriptionController.text,
//         'recipient': _recipientController.text,
//         'date': Timestamp.fromDate(_selectedDate),
//         'createdAt': Timestamp.now(),
//         'category': 'خرج',
//       };

//       await _firestore.collection('treasury_exits').add(expenseData);

//       // تحديث الرصيد
//       setState(() => _treasuryBalance -= amount);

//       _showSnackBar('تم إضافة المصروف بنجاح', Colors.green);
//       _resetForm();
//     } catch (e) {
//       _showSnackBar('حدث خطأ: $e', Colors.red);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Widget _buildExpenseForm() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // بطاقة رصيد الخزنة
//           Card(
//             elevation: 4,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
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
//                       Icon(
//                         Icons.account_balance_wallet,
//                         color: Colors.white,
//                         size: 28,
//                       ),
//                       SizedBox(width: 12),
//                       Text(
//                         'رصيد الخزنة الحالي',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     '${_treasuryBalance.toStringAsFixed(2)} ج',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 36,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 12),
//                   if (_treasuryBalance < 1000)
//                     Container(
//                       padding: EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.red.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(Icons.warning, color: Colors.white, size: 16),
//                           SizedBox(width: 4),
//                           Text(
//                             'الرصيد منخفض',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),

//           SizedBox(height: 24),

//           // نوع المصروف
//           Card(
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: DropdownButton<String>(
//                 value: _selectedExpenseType,
//                 isExpanded: true,
//                 underline: SizedBox(),
//                 items: _expenseTypes.map((type) {
//                   return DropdownMenuItem<String>(
//                     value: type['name'],
//                     child: Row(
//                       children: [
//                         Icon(type['icon'], color: type['color'], size: 20),
//                         SizedBox(width: 12),
//                         Text(
//                           type['name'],
//                           style: TextStyle(fontSize: 16, color: Colors.black87),
//                         ),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() => _selectedExpenseType = value!);
//                 },
//               ),
//             ),
//           ),

//           SizedBox(height: 16),

//           // المبلغ
//           Card(
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: TextField(
//                 controller: _amountController,
//                 keyboardType: TextInputType.number,
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//                 decoration: InputDecoration(
//                   labelText: 'المبلغ',
//                   labelStyle: TextStyle(color: Colors.grey[700]),
//                   prefixText: 'ج ',
//                   prefixStyle: TextStyle(
//                     fontSize: 18,
//                     color: Colors.red,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   border: InputBorder.none,
//                   icon: Icon(Icons.money_off, color: Colors.red),
//                 ),
//               ),
//             ),
//           ),

//           // المستلم (للشيكات)
//           if (_selectedExpenseType.contains('شيك'))
//             Padding(
//               padding: const EdgeInsets.only(top: 16),
//               child: Card(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   child: TextField(
//                     controller: _recipientController,
//                     style: TextStyle(fontSize: 16),
//                     decoration: InputDecoration(
//                       labelText: 'المستلم',
//                       labelStyle: TextStyle(color: Colors.grey[700]),
//                       border: InputBorder.none,
//                       icon: Icon(Icons.person, color: Colors.blue),
//                       hintText: 'اسم الشخص/الشركة المستلم',
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//           SizedBox(height: 16),

//           // التاريخ
//           Card(
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   Icon(Icons.calendar_today, color: Colors.red, size: 24),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'تاريخ المصروف',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         Text(
//                           DateFormat('yyyy/MM/dd').format(_selectedDate),
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: Colors.black87,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () async {
//                       final DateTime? picked = await showDatePicker(
//                         context: context,
//                         initialDate: _selectedDate,
//                         firstDate: DateTime(2000),
//                         lastDate: DateTime(2100),
//                       );
//                       if (picked != null) {
//                         setState(() => _selectedDate = picked);
//                       }
//                     },
//                     icon: Icon(Icons.edit, color: Colors.red),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           SizedBox(height: 16),

//           // الوصف
//           Card(
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: TextField(
//                 controller: _descriptionController,
//                 maxLines: 2,
//                 style: TextStyle(fontSize: 16),
//                 decoration: InputDecoration(
//                   labelText: 'الوصف / الملاحظات',
//                   labelStyle: TextStyle(color: Colors.grey[700]),
//                   border: InputBorder.none,
//                   icon: Icon(Icons.description, color: Colors.grey[700]),
//                   hintText: 'أضف وصفاً للمصروف...',
//                   hintStyle: TextStyle(color: Colors.grey[500]),
//                 ),
//               ),
//             ),
//           ),

//           SizedBox(height: 24),

//           // زر الإضافة
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: _isLoading ? null : _addExpense,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: 3,
//               ),
//               child: _isLoading
//                   ? SizedBox(
//                       width: 24,
//                       height: 24,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         color: Colors.white,
//                       ),
//                     )
//                   : Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.remove, color: Colors.white, size: 24),
//                         SizedBox(width: 12),
//                         Text(
//                           'إضافة مصروف',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showSnackBar(String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message, style: TextStyle(fontWeight: FontWeight.bold)),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     );
//   }

//   void _resetForm() {
//     _amountController.clear();
//     _descriptionController.clear();
//     _recipientController.clear();
//     _selectedExpenseType = 'نقدي';
//     _selectedDate = DateTime.now();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'الخارج من الخزنة',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         backgroundColor: Color(0xFF1B4F72),
//         elevation: 4,
//       ),
//       body: _buildExpenseForm(),
//     );
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _descriptionController.dispose();
//     _recipientController.dispose();
//     super.dispose();
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();

  // أنواع الخروج المالي - تمت إضافة المزيد من التصنيفات
  final List<Map<String, dynamic>> _expenseTypes = [
    {'name': 'نقدي', 'icon': Icons.money_off, 'color': Colors.red},
    {'name': 'شيك تم صرفه', 'icon': Icons.check_circle, 'color': Colors.blue},
    {'name': 'نثريات', 'icon': Icons.shopping_cart, 'color': Colors.purple},
    {'name': 'مصروفات تشغيل', 'icon': Icons.business, 'color': Colors.orange},
    {'name': 'مرتبات', 'icon': Icons.people, 'color': Colors.teal},
    {
      'name': 'فاتورة كهرباء',
      'icon': Icons.lightbulb,
      'color': Colors.yellow[700]!,
    },
    {
      'name': 'فاتورة مياه',
      'icon': Icons.water_drop,
      'color': Colors.blue[400]!,
    },
    {'name': 'إيجار', 'icon': Icons.home, 'color': Colors.brown},
    {'name': 'صيانة', 'icon': Icons.build, 'color': Colors.deepOrange},
    {'name': 'أخرى', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ];

  String _selectedExpenseType = 'نقدي';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  double _treasuryBalance = 0.0;
  bool _showRecipientField = false;

  @override
  void initState() {
    super.initState();
    _loadTreasuryBalance();
  }

  // تحميل رصيد الخزنة مع معالجة الأخطاء
  Future<void> _loadTreasuryBalance() async {
    try {
      // مجموع الدخل النقدي والمصروف
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

      // مجموع الخرج
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
      _showSnackBar('خطأ في تحميل بيانات الخزنة', Colors.red);
    }
  }

  Future<void> _addExpense() async {
    if (_amountController.text.isEmpty) {
      _showSnackBar('الرجاء إدخال المبلغ', Colors.red);
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showSnackBar('الرجاء إدخال مبلغ صحيح', Colors.red);
      return;
    }

    if (amount > _treasuryBalance) {
      _showSnackBar('المبلغ أكبر من الرصيد المتاح في الخزنة', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final expenseData = {
        'amount': amount,
        'expenseType': _selectedExpenseType,
        'description': _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : _selectedExpenseType,
        'recipient': _recipientController.text,
        'date': Timestamp.fromDate(_selectedDate),
        'createdAt': Timestamp.now(),
        'category': 'خرج',
        'status': 'مكتمل',
      };

      await _firestore.collection('treasury_exits').add(expenseData);

      // تحديث الرصيد
      setState(() => _treasuryBalance -= amount);

      _showSnackBar('تم إضافة المصروف بنجاح', Colors.green);
      _resetForm();
    } catch (e) {
      _showSnackBar('حدث خطأ: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildExpenseForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // بطاقة رصيد الخزنة
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
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
                      Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'رصيد الخزنة الحالي',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    '${_treasuryBalance.toStringAsFixed(2)} ج',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12),
                  if (_treasuryBalance < 1000)
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'الرصيد منخفض',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // نوع المصروف مع تحسين التصميم
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.category, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'نوع المصروف',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _selectedExpenseType,
                    isExpanded: true,
                    underline: SizedBox(),
                    items: _expenseTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type['name'],
                        child: Row(
                          children: [
                            Icon(type['icon'], color: type['color'], size: 20),
                            SizedBox(width: 12),
                            Text(
                              type['name'],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedExpenseType = value!;
                        _showRecipientField = value.contains('شيك');
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // المبلغ مع تحسين التصميم
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.attach_money, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'المبلغ',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'أدخل المبلغ',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixText: 'ج ',
                      prefixStyle: TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // المستلم (للشيكات)
          if (_showRecipientField) ...[
            SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'المستلم',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _recipientController,
                      style: TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'اسم الشخص أو الشركة المستلم',
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          SizedBox(height: 16),

          // التاريخ مع تحسين التصميم
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.blue, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تاريخ الصرف',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          DateFormat('yyyy/MM/dd').format(_selectedDate),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              colorScheme: ColorScheme.light(
                                primary: Color(0xFF1B4F72),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                    icon: Icon(Icons.edit, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // الوصف مع تحسين التصميم
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description,
                        color: Colors.grey[700],
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'الوصف / الملاحظات',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    style: TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'أضف وصفاً للمصروف (اختياري)...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // زر الإضافة مع تحسين التصميم
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _addExpense,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.remove_circle_outline,
                          color: Colors.white,
                          size: 26,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'طرح من الخزنة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseHistory() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('treasury_exits')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 50),
                SizedBox(height: 16),
                Text(
                  'حدث خطأ في تحميل البيانات',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];
        double totalExpenses = 0;

        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final amount = data['amount'];
          if (amount != null) {
            totalExpenses += (amount as num).toDouble();
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة إجمالي المصروفات
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.red.withOpacity(0.1),
                        child: Icon(
                          Icons.trending_down,
                          color: Colors.red,
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إجمالي المصروفات',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '${totalExpenses.toStringAsFixed(2)} ج',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Chip(
                                  label: Text(
                                    '${docs.length} معاملة',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),

              // قسم سجل المصروفات
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Color(0xFF1B4F72).withOpacity(0.1),
                            child: Icon(
                              Icons.history,
                              color: Color(0xFF1B4F72),
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'سجل المصروفات',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B4F72),
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            onPressed: _loadTreasuryBalance,
                            icon: Icon(Icons.refresh, color: Colors.blue),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Divider(color: Colors.grey[300]),
                      SizedBox(height: 8),

                      if (docs.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 60,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'لا توجد مصروفات مسجلة',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'ابدأ بإضافة أول مصروف',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final date = (data['date'] as Timestamp).toDate();
                          final expenseType = data['expenseType'] ?? 'أخرى';
                          final amount =
                              (data['amount'] as num?)?.toDouble() ?? 0;
                          final description = data['description'] ?? '';
                          final recipient = data['recipient'] ?? '';

                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundColor: _getTypeColor(
                                  expenseType,
                                ).withOpacity(0.1),
                                child: Icon(
                                  _getTypeIcon(expenseType),
                                  color: _getTypeColor(expenseType),
                                  size: 20,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      expenseType,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${amount.toStringAsFixed(2)} ج',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[700],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        DateFormat('yyyy/MM/dd').format(date),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (description.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        description,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  if (recipient.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.person_outline,
                                            size: 14,
                                            color: Colors.blue[600],
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'المستلم: $recipient',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue[600],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              // trailing: PopupMenuButton<String>(
                              //   // icon: Icon(
                              //   //   Icons.more_vert,
                              //   //   color: Colors.grey[600],
                              //   // ),
                              //   // itemBuilder: (context) => [
                              //   //   PopupMenuItem(
                              //   //     value: 'edit',
                              //   //     child: Row(
                              //   //       children: [
                              //   //         Icon(
                              //   //           Icons.edit,
                              //   //           size: 18,
                              //   //           color: Colors.blue,
                              //   //         ),
                              //   //         SizedBox(width: 8),
                              //   //         Text(
                              //   //           'تعديل',
                              //   //           style: TextStyle(color: Colors.blue),
                              //   //         ),
                              //   //       ],
                              //   //     ),
                              //   //   ),
                              //   //   PopupMenuItem(
                              //   //     value: 'delete',
                              //   //     child: Row(
                              //   //       children: [
                              //   //         Icon(
                              //   //           Icons.delete,
                              //   //           color: Colors.red,
                              //   //           size: 18,
                              //   //         ),
                              //   //         SizedBox(width: 8),
                              //   //         Text(
                              //   //           'حذف',
                              //   //           style: TextStyle(color: Colors.red),
                              //   //         ),
                              //   //       ],
                              //   //     ),
                              //   //   ),
                              //   // ],
                              //   onSelected: (value) {
                              //     if (value == 'delete') {
                              //       _confirmDelete(doc.id, expenseType, amount);
                              //     } else if (value == 'edit') {
                              //       _editExpense(doc.id, data);
                              //     }
                              //   },
                              // ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editExpense(String docId, Map<String, dynamic> data) async {
    _amountController.text = data['amount'].toString();
    _descriptionController.text = data['description']?.toString() ?? '';
    _recipientController.text = data['recipient']?.toString() ?? '';
    _selectedExpenseType = data['expenseType']?.toString() ?? 'نقدي';
    _selectedDate = (data['date'] as Timestamp).toDate();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تعديل المصروف', textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // نوع المصروف
                DropdownButtonFormField<String>(
                  initialValue: _selectedExpenseType,
                  decoration: InputDecoration(
                    labelText: 'نوع المصروف',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: _expenseTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type['name'],
                      child: Row(
                        children: [
                          Icon(type['icon'], color: type['color'], size: 20),
                          SizedBox(width: 8),
                          Text(type['name']),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedExpenseType = value!;
                      _showRecipientField = value.contains('شيك');
                    });
                  },
                ),
                SizedBox(height: 16),

                // المبلغ
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'المبلغ',
                    prefixText: 'ج ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // المستلم (إذا كان شيك)
                if (_showRecipientField)
                  Column(
                    children: [
                      TextField(
                        controller: _recipientController,
                        decoration: InputDecoration(
                          labelText: 'المستلم',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),

                // الوصف
                TextField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'الوصف',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetForm();
              },
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(_amountController.text);
                if (amount == null || amount <= 0) {
                  _showSnackBar('الرجاء إدخال مبلغ صحيح', Colors.red);
                  return;
                }

                try {
                  final oldAmount = (data['amount'] as num).toDouble();
                  final difference = amount - oldAmount;

                  if (difference > _treasuryBalance) {
                    _showSnackBar('المبلغ أكبر من الرصيد المتاح', Colors.red);
                    return;
                  }

                  await _firestore
                      .collection('treasury_exits')
                      .doc(docId)
                      .update({
                        'amount': amount,
                        'expenseType': _selectedExpenseType,
                        'description': _descriptionController.text,
                        'recipient': _recipientController.text,
                        'date': Timestamp.fromDate(_selectedDate),
                        'updatedAt': Timestamp.now(),
                      });

                  setState(() {
                    _treasuryBalance -= difference;
                  });

                  _showSnackBar('تم تعديل المصروف بنجاح', Colors.green);
                  Navigator.pop(context);
                  _resetForm();
                } catch (e) {
                  _showSnackBar('حدث خطأ: $e', Colors.red);
                }
              },
              child: Text('حفظ التعديلات'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(
    String docId,
    String expenseType,
    double amount,
  ) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("تأكيد الحذف", textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning, color: Colors.red, size: 50),
              SizedBox(height: 16),
              Text(
                "هل أنت متأكد من حذف $expenseType بقيمة ${amount.toStringAsFixed(2)} ج؟",
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                    ),
                    child: Text("إلغاء", style: TextStyle(color: Colors.black)),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      try {
                        await _firestore
                            .collection("treasury_exits")
                            .doc(docId)
                            .delete();

                        setState(() {
                          _treasuryBalance += amount;
                        });

                        _showSnackBar("تم حذف المصروف بنجاح", Colors.red);
                      } catch (e) {
                        _showSnackBar("حدث خطأ أثناء الحذف: $e", Colors.red);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text("حذف", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Color _getTypeColor(String type) {
    for (var expenseType in _expenseTypes) {
      if (expenseType['name'] == type) {
        return expenseType['color'];
      }
    }
    return Colors.grey;
  }

  IconData _getTypeIcon(String type) {
    for (var expenseType in _expenseTypes) {
      if (expenseType['name'] == type) {
        return expenseType['icon'];
      }
    }
    return Icons.money_off;
  }

  void _resetForm() {
    _amountController.clear();
    _descriptionController.clear();
    _recipientController.clear();
    _selectedExpenseType = 'نقدي';
    _showRecipientField = false;
    _selectedDate = DateTime.now();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'الخارج من الخزنة',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFF1B4F72),
          elevation: 4,
          actions: [
            IconButton(
              onPressed: () {
                _loadTreasuryBalance();
              },
              icon: Icon(Icons.refresh, color: Colors.white),
              tooltip: 'تحديث',
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(
                icon: Icon(Icons.add_circle_outline, size: 22),
                text: 'إضافة مصروف',
              ),
              Tab(icon: Icon(Icons.history, size: 22), text: 'سجل المصروفات'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildExpenseForm(), _buildExpenseHistory()],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _recipientController.dispose();
    super.dispose();
  }
}
