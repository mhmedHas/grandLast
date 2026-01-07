// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// class CapitalManagementPage extends StatefulWidget {
//   const CapitalManagementPage({super.key});

//   @override
//   State<CapitalManagementPage> createState() => _CapitalManagementPageState();
// }

// class _CapitalManagementPageState extends State<CapitalManagementPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // متغيرات الحالة
//   double _currentCapital = 0.0;
//   bool _isLoading = true;
//   List<Map<String, dynamic>> _transactions = [];
//   int _selectedTab = 0; // 0: رأس المال، 1: السجل

//   // إحصائيات
//   double _totalDeposits = 0.0;
//   double _totalWithdrawals = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _loadCapitalData();
//   }

//   // ================================
//   // تحميل بيانات رأس المال والعمليات
//   // ================================
//   Future<void> _loadCapitalData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // تحميل رأس المال الحالي
//       final capitalDoc = await _firestore
//           .collection('capital')
//           .doc('current')
//           .get();

//       if (capitalDoc.exists) {
//         final data = capitalDoc.data();
//         setState(() {
//           _currentCapital = ((data?['amount'] as num?) ?? 0).toDouble();
//         });
//       } else {
//         // إنشاء رأس المال إذا لم يكن موجوداً
//         await _firestore.collection('capital').doc('current').set({
//           'amount': 0.0,
//           'lastUpdated': Timestamp.now(),
//         });
//       }

//       // تحميل العمليات
//       await _loadTransactions();
//     } catch (e) {
//       _showError('خطأ في تحميل البيانات: $e');
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // ================================
//   // تحميل العمليات
//   // ================================
//   Future<void> _loadTransactions() async {
//     try {
//       final transactionsSnapshot = await _firestore
//           .collection('capital_transactions')
//           .orderBy('date', descending: true)
//           .limit(100)
//           .get();

//       final List<Map<String, dynamic>> transactionsList = [];
//       double deposits = 0.0;
//       double withdrawals = 0.0;

//       for (final doc in transactionsSnapshot.docs) {
//         final data = doc.data();
//         final type = data['type'] ?? 'إيداع';
//         final amount = ((data['amount'] as num?) ?? 0).toDouble();

//         if (type == 'إيداع') {
//           deposits += amount;
//         } else {
//           withdrawals += amount;
//         }

//         transactionsList.add({
//           'id': doc.id,
//           'amount': amount,
//           'type': type,
//           'description': data['description'] ?? 'لا توجد ملاحظات',
//           'date': (data['date'] as Timestamp?)?.toDate(),
//           'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
//           'previousBalance': ((data['previousBalance'] as num?) ?? 0)
//               .toDouble(),
//           'newBalance': ((data['newBalance'] as num?) ?? 0).toDouble(),
//         });
//       }

//       setState(() {
//         _transactions = transactionsList;
//         _totalDeposits = deposits;
//         _totalWithdrawals = withdrawals;
//       });
//     } catch (e) {
//       _showError('خطأ في تحميل العمليات: $e');
//     }
//   }

//   // ================================
//   // إضافة معاملة جديدة
//   // ================================
//   Future<void> _addTransaction(String type) async {
//     final TextEditingController amountController = TextEditingController();
//     final TextEditingController descriptionController = TextEditingController();
//     DateTime? transactionDate = DateTime.now();

//     final result = await showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: Text(
//                 type == 'إيداع' ? 'إضافة إيداع' : 'إضافة سحب',
//                 style: TextStyle(
//                   color: type == 'إيداع' ? Colors.green : Colors.red,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // المبلغ
//                     TextFormField(
//                       controller: amountController,
//                       decoration: InputDecoration(
//                         labelText: 'المبلغ',
//                         prefixIcon: const Icon(Icons.attach_money),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       keyboardType: TextInputType.number,
//                     ),

//                     const SizedBox(height: 16),

//                     // التاريخ
//                     GestureDetector(
//                       onTap: () async {
//                         final selectedDate = await _showDatePicker();
//                         if (selectedDate != null) {
//                           setState(() {
//                             transactionDate = selectedDate;
//                           });
//                         }
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           children: [
//                             const Icon(
//                               Icons.calendar_today,
//                               color: Colors.grey,
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Text(
//                                 transactionDate != null
//                                     ? DateFormat(
//                                         'yyyy/MM/dd',
//                                       ).format(transactionDate!)
//                                     : 'اختر تاريخ',
//                                 style: const TextStyle(fontSize: 16),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 16),

//                     // الملاحظات
//                     TextFormField(
//                       controller: descriptionController,
//                       decoration: InputDecoration(
//                         labelText: 'ملاحظات (اختياري)',
//                         prefixIcon: const Icon(Icons.note),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       maxLines: 3,
//                     ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context, false),
//                   child: const Text('إلغاء'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context, true),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: type == 'إيداع'
//                         ? Colors.green
//                         : Colors.red,
//                   ),
//                   child: const Text('حفظ'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );

//     if (result != true) return;

//     if (amountController.text.isEmpty) {
//       _showError('الرجاء إدخال المبلغ');
//       return;
//     }

//     final amount = double.tryParse(amountController.text);
//     if (amount == null || amount <= 0) {
//       _showError('الرجاء إدخال مبلغ صحيح');
//       return;
//     }

//     if (transactionDate == null) {
//       _showError('الرجاء اختيار تاريخ');
//       return;
//     }

//     final transactionAmount = type == 'سحب' ? -amount : amount;
//     final previousBalance = _currentCapital;
//     final newBalance = previousBalance + transactionAmount;

//     if (type == 'سحب' && newBalance < 0) {
//       _showError('رصيد رأس المال غير كافي للسحب');
//       return;
//     }

//     try {
//       // تحديث رأس المال الحالي
//       await _firestore.collection('capital').doc('current').update({
//         'amount': newBalance,
//         'lastUpdated': Timestamp.now(),
//       });

//       // إضافة العملية إلى السجل
//       await _firestore.collection('capital_transactions').add({
//         'amount': amount,
//         'type': type,
//         'description': descriptionController.text.isNotEmpty
//             ? descriptionController.text
//             : 'لا توجد ملاحظات',
//         'date': Timestamp.fromDate(transactionDate!),
//         'createdAt': Timestamp.now(),
//         'previousBalance': previousBalance,
//         'newBalance': newBalance,
//       });

//       // تحديث الواجهة
//       setState(() {
//         _currentCapital = newBalance;
//       });

//       // إعادة تحميل العمليات
//       await _loadTransactions();

//       _showSuccess('تم ${type == 'إيداع' ? 'الإيداع' : 'السحب'} بنجاح');
//     } catch (e) {
//       _showError('خطأ في إضافة العملية: $e');
//     }
//   }

//   // ================================
//   // حذف معاملة
//   // ================================
//   Future<void> _deleteTransaction(Map<String, dynamic> transaction) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('حذف العملية'),
//         content: const Text('هل أنت متأكد من حذف هذه العملية؟'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('حذف'),
//           ),
//         ],
//       ),
//     );

//     if (confirmed != true) return;

//     try {
//       // التراجع عن تأثير العملية
//       final transactionAmount = transaction['type'] == 'سحب'
//           ? transaction['amount']
//           : -transaction['amount'];

//       final newBalance = _currentCapital + transactionAmount;

//       // تحديث رأس المال
//       await _firestore.collection('capital').doc('current').update({
//         'amount': newBalance,
//         'lastUpdated': Timestamp.now(),
//       });

//       // حذف العملية
//       await _firestore
//           .collection('capital_transactions')
//           .doc(transaction['id'])
//           .delete();

//       // تحديث الواجهة
//       setState(() {
//         _currentCapital = newBalance;
//       });

//       // إعادة تحميل العمليات
//       await _loadTransactions();

//       _showSuccess('تم حذف العملية بنجاح');
//     } catch (e) {
//       _showError('خطأ في حذف العملية: $e');
//     }
//   }

//   // ================================
//   // عرض نافذة اختيار التاريخ
//   // ================================
//   Future<DateTime?> _showDatePicker() async {
//     final selectedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//     );

//     return selectedDate;
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

//   String _formatCurrency(double amount) {
//     return '${amount.toStringAsFixed(2)} ج';
//   }

//   String _formatDate(DateTime? date) {
//     if (date == null) return '-';
//     return DateFormat('dd/MM/yyyy').format(date);
//   }

//   // ================================
//   // بناء الواجهة
//   // ================================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('رأس المال'),
//         backgroundColor: const Color(0xFF1B4F72),
//         foregroundColor: Colors.white,
//       ),
//       body: Column(
//         children: [
//           // تبويبات
//           Container(
//             color: Colors.white,
//             child: Row(
//               children: [
//                 Expanded(
//                   child: _buildTabButton(0, 'رأس المال', Icons.account_balance),
//                 ),
//                 Expanded(child: _buildTabButton(1, 'السجل', Icons.history)),
//               ],
//             ),
//           ),

//           // المحتوى
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : _selectedTab == 0
//                 ? _buildCapitalTab()
//                 : _buildHistoryTab(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTabButton(int tabIndex, String title, IconData icon) {
//     final isSelected = _selectedTab == tabIndex;

//     return Material(
//       color: isSelected ? const Color(0xFF3498DB) : Colors.white,
//       child: InkWell(
//         onTap: () {
//           setState(() {
//             _selectedTab = tabIndex;
//           });
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           child: Column(
//             children: [
//               Icon(icon, color: isSelected ? Colors.white : Colors.grey),
//               const SizedBox(height: 4),
//               Text(
//                 title,
//                 style: TextStyle(
//                   color: isSelected ? Colors.white : Colors.grey,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCapitalTab() {
//     return Column(
//       children: [
//         // بطاقة رأس المال
//         Container(
//           margin: const EdgeInsets.all(16),
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.2),
//                 blurRadius: 8,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               const Text(
//                 'رأس المال الحالي',
//                 style: TextStyle(fontSize: 16, color: Colors.grey),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 _formatCurrency(_currentCapital),
//                 style: const TextStyle(
//                   fontSize: 36,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1B4F72),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // أزرار الإيداع والسحب
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: () => _addTransaction('إيداع'),
//                   icon: const Icon(Icons.add, size: 20),
//                   label: const Text('إيداع'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: () => _addTransaction('سحب'),
//                   icon: const Icon(Icons.remove, size: 20),
//                   label: const Text('سحب'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.red,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // إحصائيات مختصرة
//         Container(
//           margin: const EdgeInsets.all(16),
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.2),
//                 blurRadius: 4,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               Column(
//                 children: [
//                   const Text(
//                     'الإيداعات',
//                     style: TextStyle(fontSize: 14, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     _formatCurrency(_totalDeposits),
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green,
//                     ),
//                   ),
//                 ],
//               ),
//               Column(
//                 children: [
//                   const Text(
//                     'السحوبات',
//                     style: TextStyle(fontSize: 14, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     _formatCurrency(_totalWithdrawals),
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.red,
//                     ),
//                   ),
//                 ],
//               ),
//               Column(
//                 children: [
//                   const Text(
//                     'الصافي',
//                     style: TextStyle(fontSize: 14, color: Colors.grey),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     _formatCurrency(_totalDeposits - _totalWithdrawals),
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1B4F72),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),

//         // آخر العمليات
//         Expanded(child: _buildRecentTransactions()),
//       ],
//     );
//   }

//   Widget _buildRecentTransactions() {
//     final recentTransactions = _transactions.take(5).toList();

//     if (recentTransactions.isEmpty) {
//       return const Center(
//         child: Text(
//           'لا توجد عمليات حديثة',
//           style: TextStyle(color: Colors.grey),
//         ),
//       );
//     }

//     return Column(
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: Row(
//             children: [
//               const Text(
//                 'آخر العمليات',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               const Spacer(),
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     _selectedTab = 1;
//                   });
//                 },
//                 child: const Text('عرض الكل'),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: ListView.builder(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             itemCount: recentTransactions.length,
//             itemBuilder: (context, index) {
//               final transaction = recentTransactions[index];
//               return _buildTransactionItem(transaction);
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildHistoryTab() {
//     return Column(
//       children: [
//         // إحصائيات السجل
//         Container(
//           margin: const EdgeInsets.all(16),
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.2),
//                 blurRadius: 4,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'إجمالي الإيداعات:',
//                     style: TextStyle(fontSize: 14),
//                   ),
//                   Text(
//                     _formatCurrency(_totalDeposits),
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.green,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'إجمالي السحوبات:',
//                     style: TextStyle(fontSize: 14),
//                   ),
//                   Text(
//                     _formatCurrency(_totalWithdrawals),
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.red,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               const Divider(),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   const Text(
//                     'الصافي:',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                   ),
//                   Text(
//                     _formatCurrency(_totalDeposits - _totalWithdrawals),
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1B4F72),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),

//         // عنوان العمليات
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: Row(
//             children: [
//               const Text(
//                 'جميع العمليات',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               const Spacer(),
//               Text(
//                 '(${_transactions.length}) عملية',
//                 style: const TextStyle(color: Colors.grey),
//               ),
//             ],
//           ),
//         ),

//         // قائمة العمليات
//         Expanded(
//           child: _transactions.isEmpty
//               ? const Center(
//                   child: Text(
//                     'لا توجد عمليات',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 )
//               : ListView.builder(
//                   padding: const EdgeInsets.symmetric(horizontal: 16),
//                   itemCount: _transactions.length,
//                   itemBuilder: (context, index) {
//                     final transaction = _transactions[index];
//                     return _buildTransactionItem(transaction, showDelete: true);
//                   },
//                 ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTransactionItem(
//     Map<String, dynamic> transaction, {
//     bool showDelete = false,
//   }) {
//     final type = transaction['type'];
//     final amount = transaction['amount'];
//     final description = transaction['description'];
//     final date = transaction['date'];
//     final color = type == 'إيداع' ? Colors.green : Colors.red;
//     final icon = type == 'إيداع' ? Icons.add_circle : Icons.remove_circle;

//     return Card(
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         leading: Icon(icon, color: color),
//         title: Row(
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     type,
//                     style: TextStyle(fontWeight: FontWeight.bold, color: color),
//                   ),
//                   if (description.isNotEmpty &&
//                       description != 'لا توجد ملاحظات')
//                     Text(
//                       description,
//                       style: const TextStyle(fontSize: 12, color: Colors.grey),
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                 ],
//               ),
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   _formatCurrency(amount),
//                   style: TextStyle(fontWeight: FontWeight.bold, color: color),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   _formatDate(date),
//                   style: const TextStyle(fontSize: 12, color: Colors.grey),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         trailing: showDelete
//             ? IconButton(
//                 icon: const Icon(Icons.delete, color: Colors.grey),
//                 onPressed: () => _deleteTransaction(transaction),
//               )
//             : null,
//         onTap: showDelete
//             ? null
//             : () {
//                 // عرض تفاصيل العملية
//                 showDialog(
//                   context: context,
//                   builder: (context) => AlertDialog(
//                     title: Text(type),
//                     content: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('المبلغ: ${_formatCurrency(amount)}'),
//                         Text('التاريخ: ${_formatDate(date)}'),
//                         if (description.isNotEmpty &&
//                             description != 'لا توجد ملاحظات')
//                           Text('الملاحظات: $description'),
//                         const SizedBox(height: 8),
//                         const Divider(),
//                         const SizedBox(height: 8),
//                         Text(
//                           'الرصيد السابق: ${_formatCurrency(transaction['previousBalance'])}',
//                         ),
//                         Text(
//                           'الرصيد الجديد: ${_formatCurrency(transaction['newBalance'])}',
//                         ),
//                       ],
//                     ),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         child: const Text('إغلاق'),
//                       ),
//                       ElevatedButton(
//                         onPressed: () {
//                           Navigator.pop(context);
//                           _deleteTransaction(transaction);
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red,
//                         ),
//                         child: const Text('حذف'),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CapitalManagementPage extends StatefulWidget {
  const CapitalManagementPage({super.key});

  @override
  State<CapitalManagementPage> createState() => _CapitalManagementPageState();
}

class _CapitalManagementPageState extends State<CapitalManagementPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // متغيرات الحالة
  double _currentCapital = 0.0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _partners = [];
  int _selectedTab = 0; // 0: رأس المال، 1: السجل، 2: الشركاء

  // إحصائيات
  double _totalDeposits = 0.0;
  double _totalWithdrawals = 0.0;
  double _totalShares = 0.0;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // ================================
  // تحميل جميع البيانات
  // ================================
  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([
        _loadCapitalData(),
        _loadTransactions(),
        _loadPartners(),
      ]);
    } catch (e) {
      _showError('خطأ في تحميل البيانات: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ================================
  // تحميل بيانات رأس المال
  // ================================
  Future<void> _loadCapitalData() async {
    try {
      final capitalDoc = await _firestore
          .collection('capital')
          .doc('current')
          .get();

      if (capitalDoc.exists) {
        final data = capitalDoc.data();
        setState(() {
          _currentCapital = ((data?['amount'] as num?) ?? 0).toDouble();
        });
      } else {
        await _firestore.collection('capital').doc('current').set({
          'amount': 0.0,
          'lastUpdated': Timestamp.now(),
        });
      }
    } catch (e) {
      _showError('خطأ في تحميل رأس المال: $e');
    }
  }

  // ================================
  // تحميل العمليات
  // ================================
  Future<void> _loadTransactions() async {
    try {
      final transactionsSnapshot = await _firestore
          .collection('capital_transactions')
          .orderBy('date', descending: true)
          .limit(100)
          .get();

      final List<Map<String, dynamic>> transactionsList = [];
      double deposits = 0.0;
      double withdrawals = 0.0;

      for (final doc in transactionsSnapshot.docs) {
        final data = doc.data();
        final type = data['type'] ?? 'إيداع';
        final amount = ((data['amount'] as num?) ?? 0).toDouble();

        if (type == 'إيداع') {
          deposits += amount;
        } else {
          withdrawals += amount;
        }

        transactionsList.add({
          'id': doc.id,
          'amount': amount,
          'type': type,
          'description': data['description'] ?? 'لا توجد ملاحظات',
          'date': (data['date'] as Timestamp?)?.toDate(),
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
          'previousBalance': ((data['previousBalance'] as num?) ?? 0)
              .toDouble(),
          'newBalance': ((data['newBalance'] as num?) ?? 0).toDouble(),
        });
      }

      setState(() {
        _transactions = transactionsList;
        _totalDeposits = deposits;
        _totalWithdrawals = withdrawals;
      });
    } catch (e) {
      _showError('خطأ في تحميل العمليات: $e');
    }
  }

  // ================================
  // تحميل بيانات الشركاء
  // ================================
  Future<void> _loadPartners() async {
    try {
      final partnersSnapshot = await _firestore
          .collection('partners')
          .orderBy('createdAt', descending: false)
          .get();

      final List<Map<String, dynamic>> partnersList = [];
      double totalShares = 0.0;

      for (final doc in partnersSnapshot.docs) {
        final data = doc.data();
        final share = ((data['share'] as num?) ?? 0).toDouble();
        totalShares += share;

        partnersList.add({
          'id': doc.id,
          'name': data['name'] ?? '',
          'share': share,
          'notes': data['notes'] ?? '',
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
          'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate(),
        });
      }

      setState(() {
        _partners = partnersList;
        _totalShares = totalShares;
      });
    } catch (e) {
      _showError('خطأ في تحميل بيانات الشركاء: $e');
    }
  }

  // ================================
  // إضافة/تعديل شريك
  // ================================
  Future<void> _showAddEditPartnerDialog([
    Map<String, dynamic>? partner,
  ]) async {
    final bool isEditing = partner != null;

    final TextEditingController nameController = TextEditingController(
      text: partner?['name'] ?? '',
    );
    final TextEditingController shareController = TextEditingController(
      text: partner?['share']?.toString() ?? '',
    );
    final TextEditingController notesController = TextEditingController(
      text: partner?['notes'] ?? '',
    );

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                isEditing ? 'تعديل الشريك' : 'إضافة شريك جديد',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4F72),
                ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // الاسم
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'اسم الشريك *',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال اسم الشريك';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // النسبة
                      TextFormField(
                        controller: shareController,
                        decoration: InputDecoration(
                          labelText: 'نسبة الملكية (%) *',
                          prefixIcon: const Icon(Icons.percent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال النسبة';
                          }
                          final share = double.tryParse(value);
                          if (share == null || share <= 0) {
                            return 'الرجاء إدخال نسبة صحيحة';
                          }
                          if (share > 100) {
                            return 'النسبة لا يمكن أن تزيد عن 100%';
                          }

                          // حساب النسبة الإجمالية بدون النسبة الحالية (في حالة التعديل)
                          double currentTotal = _totalShares;
                          if (isEditing) {
                            currentTotal -= partner!['share'];
                          }
                          if (currentTotal + share > 100) {
                            return 'إجمالي النسب يتجاوز 100%';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // ملاحظات
                      TextFormField(
                        controller: notesController,
                        decoration: InputDecoration(
                          labelText: 'ملاحظات',
                          prefixIcon: const Icon(Icons.note),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 3,
                      ),

                      // ملخص النسب الحالية
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'النسب الحالية:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'الإجمالي: ${_totalShares.toStringAsFixed(2)}%',
                              style: TextStyle(
                                color: _totalShares > 100
                                    ? Colors.red
                                    : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'المتبقي: ${(100 - _totalShares).toStringAsFixed(2)}%',
                              style: const TextStyle(
                                color: Colors.blue,
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final share = double.parse(shareController.text);

                      // حساب النسبة الإجمالية
                      double newTotalShares = _totalShares;
                      if (isEditing) {
                        newTotalShares -= partner!['share'];
                      }
                      newTotalShares += share;

                      if (newTotalShares > 100) {
                        _showError('إجمالي النسب يتجاوز 100%');
                        return;
                      }

                      Navigator.pop(context, true);

                      await _savePartner(
                        isEditing: isEditing,
                        partnerId: partner?['id'],
                        name: nameController.text,
                        share: share,
                        notes: notesController.text,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B4F72),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isEditing ? 'حفظ التعديلات' : 'إضافة'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================================
  // حفظ الشريك في Firebase
  // ================================
  Future<void> _savePartner({
    required bool isEditing,
    String? partnerId,
    required String name,
    required double share,
    required String notes,
  }) async {
    try {
      final partnerData = {
        'name': name,
        'share': share,
        'notes': notes.isNotEmpty ? notes : '',
        'updatedAt': Timestamp.now(),
      };

      if (isEditing && partnerId != null) {
        await _firestore
            .collection('partners')
            .doc(partnerId)
            .update(partnerData);
        _showSuccess('تم تعديل الشريك بنجاح');
      } else {
        partnerData['createdAt'] = Timestamp.now();
        await _firestore.collection('partners').add(partnerData);
        _showSuccess('تم إضافة الشريك بنجاح');
      }

      await _loadPartners();
    } catch (e) {
      _showError('خطأ في حفظ بيانات الشريك: $e');
    }
  }

  // ================================
  // حذف شريك
  // ================================
  Future<void> _deletePartner(Map<String, dynamic> partner) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الشريك'),
        content: Text('هل أنت متأكد من حذف الشريك "${partner['name']}"؟'),
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

    if (confirmed != true) return;

    try {
      await _firestore.collection('partners').doc(partner['id']).delete();

      _showSuccess('تم حذف الشريك بنجاح');
      await _loadPartners();
    } catch (e) {
      _showError('خطأ في حذف الشريك: $e');
    }
  }

  // ================================
  // عرض توزيع رأس المال على الشركاء
  // ================================
  void _showCapitalDistribution() {
    if (_partners.isEmpty) {
      _showError('لا يوجد شركاء لعرض التوزيع');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('توزيع رأس المال على الشركاء'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B4F72).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'رأس المال الإجمالي:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _formatCurrency(_currentCapital),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1B4F72),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                ..._partners.map((partner) {
                  final share = partner['share'] ?? 0.0;
                  final shareAmount = (_currentCapital * share) / 100;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                partner['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '${share.toStringAsFixed(2)}%',
                              style: const TextStyle(
                                color: Color(0xFF3498DB),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'القيمة: ${_formatCurrency(shareAmount)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (partner['notes'].isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'ملاحظات: ${partner['notes']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                }).toList(),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('عدد الشركاء:'),
                          Text(
                            _partners.length.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('إجمالي النسب:'),
                          Text(
                            '${_totalShares.toStringAsFixed(2)}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _totalShares == 100
                                  ? Colors.green
                                  : _totalShares > 100
                                  ? Colors.red
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      if (_totalShares != 100) const SizedBox(height: 8),
                      if (_totalShares != 100)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('الحالة:'),
                            Text(
                              _totalShares < 100
                                  ? 'ناقص ${(100 - _totalShares).toStringAsFixed(2)}%'
                                  : 'زائد عن الحد',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _totalShares < 100
                                    ? Colors.orange
                                    : Colors.red,
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  // ================================
  // إضافة معاملة جديدة (إيداع/سحب)
  // ================================
  Future<void> _addTransaction(String type) async {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    DateTime? transactionDate = DateTime.now();

    final result = await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                type == 'إيداع' ? 'إضافة إيداع' : 'إضافة سحب',
                style: TextStyle(
                  color: type == 'إيداع' ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: amountController,
                      decoration: InputDecoration(
                        labelText: 'المبلغ',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: () async {
                        final selectedDate = await _showDatePicker();
                        if (selectedDate != null) {
                          setState(() {
                            transactionDate = selectedDate;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                transactionDate != null
                                    ? DateFormat(
                                        'yyyy/MM/dd',
                                      ).format(transactionDate!)
                                    : 'اختر تاريخ',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'ملاحظات (اختياري)',
                        prefixIcon: const Icon(Icons.note),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: type == 'إيداع'
                        ? Colors.green
                        : Colors.red,
                  ),
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) return;

    if (amountController.text.isEmpty) {
      _showError('الرجاء إدخال المبلغ');
      return;
    }

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      _showError('الرجاء إدخال مبلغ صحيح');
      return;
    }

    if (transactionDate == null) {
      _showError('الرجاء اختيار تاريخ');
      return;
    }

    final transactionAmount = type == 'سحب' ? -amount : amount;
    final previousBalance = _currentCapital;
    final newBalance = previousBalance + transactionAmount;

    if (type == 'سحب' && newBalance < 0) {
      _showError('رصيد رأس المال غير كافي للسحب');
      return;
    }

    try {
      await _firestore.collection('capital').doc('current').update({
        'amount': newBalance,
        'lastUpdated': Timestamp.now(),
      });

      await _firestore.collection('capital_transactions').add({
        'amount': amount,
        'type': type,
        'description': descriptionController.text.isNotEmpty
            ? descriptionController.text
            : 'لا توجد ملاحظات',
        'date': Timestamp.fromDate(transactionDate!),
        'createdAt': Timestamp.now(),
        'previousBalance': previousBalance,
        'newBalance': newBalance,
      });

      setState(() {
        _currentCapital = newBalance;
      });

      await _loadTransactions();
      _showSuccess('تم ${type == 'إيداع' ? 'الإيداع' : 'السحب'} بنجاح');
    } catch (e) {
      _showError('خطأ في إضافة العملية: $e');
    }
  }

  // ================================
  // حذف معاملة
  // ================================
  Future<void> _deleteTransaction(Map<String, dynamic> transaction) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف العملية'),
        content: const Text('هل أنت متأكد من حذف هذه العملية؟'),
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

    if (confirmed != true) return;

    try {
      final transactionAmount = transaction['type'] == 'سحب'
          ? transaction['amount']
          : -transaction['amount'];

      final newBalance = _currentCapital + transactionAmount;

      await _firestore.collection('capital').doc('current').update({
        'amount': newBalance,
        'lastUpdated': Timestamp.now(),
      });

      await _firestore
          .collection('capital_transactions')
          .doc(transaction['id'])
          .delete();

      setState(() {
        _currentCapital = newBalance;
      });

      await _loadTransactions();
      _showSuccess('تم حذف العملية بنجاح');
    } catch (e) {
      _showError('خطأ في حذف العملية: $e');
    }
  }

  // ================================
  // دوال مساعدة
  // ================================
  Future<DateTime?> _showDatePicker() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    return selectedDate;
  }

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

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} ج';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // ================================
  // بناء الواجهة
  // ================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة رأس المال والشركاء'),
        backgroundColor: const Color(0xFF1B4F72),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // تبويبات
          Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(0, 'رأس المال', Icons.account_balance),
                ),
                Expanded(child: _buildTabButton(1, 'السجل', Icons.history)),
                Expanded(child: _buildTabButton(2, 'الشركاء', Icons.group)),
              ],
            ),
          ),

          // المحتوى
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedTab == 0
                ? _buildCapitalTab()
                : _selectedTab == 1
                ? _buildHistoryTab()
                : _buildPartnersTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int tabIndex, String title, IconData icon) {
    final isSelected = _selectedTab == tabIndex;

    return Material(
      color: isSelected ? const Color(0xFF3498DB) : Colors.white,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = tabIndex;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.grey),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapitalTab() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'رأس المال الحالي',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                _formatCurrency(_currentCapital),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4F72),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _addTransaction('إيداع'),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('إيداع'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _addTransaction('سحب'),
                  icon: const Icon(Icons.remove, size: 20),
                  label: const Text('سحب'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text(
                    'الإيداعات',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(_totalDeposits),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text(
                    'السحوبات',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(_totalWithdrawals),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text(
                    'الصافي',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCurrency(_totalDeposits - _totalWithdrawals),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4F72),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Expanded(child: _buildRecentTransactions()),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    final recentTransactions = _transactions.take(5).toList();

    if (recentTransactions.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد عمليات حديثة',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text(
                'آخر العمليات',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedTab = 1;
                  });
                },
                child: const Text('عرض الكل'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recentTransactions.length,
            itemBuilder: (context, index) {
              final transaction = recentTransactions[index];
              return _buildTransactionItem(transaction);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'إجمالي الإيداعات:',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    _formatCurrency(_totalDeposits),
                    style: const TextStyle(
                      fontSize: 16,
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
                  const Text(
                    'إجمالي السحوبات:',
                    style: TextStyle(fontSize: 14),
                  ),
                  Text(
                    _formatCurrency(_totalWithdrawals),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'الصافي:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    _formatCurrency(_totalDeposits - _totalWithdrawals),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4F72),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Text(
                'جميع العمليات',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              Text(
                '(${_transactions.length}) عملية',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),

        Expanded(
          child: _transactions.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد عمليات',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _transactions[index];
                    return _buildTransactionItem(transaction, showDelete: true);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPartnersTab() {
    return Column(
      children: [
        // إحصائيات الشركاء
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Text(
                        'عدد الشركاء',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _partners.length.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B4F72),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'إجمالي النسب',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_totalShares.toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _totalShares == 100
                              ? Colors.green
                              : _totalShares > 100
                              ? Colors.red
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text(
                        'المتبقي',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(100 - _totalShares).toStringAsFixed(2)}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3498DB),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddEditPartnerDialog(),
                      icon: const Icon(Icons.person_add, size: 20),
                      label: const Text('إضافة شريك'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B4F72),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showCapitalDistribution,
                      icon: const Icon(Icons.pie_chart, size: 20),
                      label: const Text('عرض التوزيع'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498DB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // عنوان القائمة
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'قائمة الشركاء',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const Spacer(),
              if (_partners.isNotEmpty)
                Text(
                  '${_partners.length} شريك',
                  style: const TextStyle(color: Colors.grey),
                ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // قائمة الشركاء
        Expanded(
          child: _partners.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'لا يوجد شركاء',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'انقر على زر "إضافة شريك" لإضافة شركاء جدد',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _partners.length,
                  itemBuilder: (context, index) {
                    final partner = _partners[index];
                    return _buildPartnerCard(partner);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(
    Map<String, dynamic> transaction, {
    bool showDelete = false,
  }) {
    final type = transaction['type'];
    final amount = transaction['amount'];
    final description = transaction['description'];
    final date = transaction['date'];
    final color = type == 'إيداع' ? Colors.green : Colors.red;
    final icon = type == 'إيداع' ? Icons.add_circle : Icons.remove_circle;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type,
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                  if (description.isNotEmpty &&
                      description != 'لا توجد ملاحظات')
                    Text(
                      description,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatCurrency(amount),
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(date),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        trailing: showDelete
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.grey),
                onPressed: () => _deleteTransaction(transaction),
              )
            : null,
        onTap: showDelete
            ? null
            : () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(type),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('المبلغ: ${_formatCurrency(amount)}'),
                        Text('التاريخ: ${_formatDate(date)}'),
                        if (description.isNotEmpty &&
                            description != 'لا توجد ملاحظات')
                          Text('الملاحظات: $description'),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        Text(
                          'الرصيد السابق: ${_formatCurrency(transaction['previousBalance'])}',
                        ),
                        Text(
                          'الرصيد الجديد: ${_formatCurrency(transaction['newBalance'])}',
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إغلاق'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteTransaction(transaction);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('حذف'),
                      ),
                    ],
                  ),
                );
              },
      ),
    );
  }

  Widget _buildPartnerCard(Map<String, dynamic> partner) {
    final share = partner['share'] ?? 0.0;
    final shareAmount = (_currentCapital * share) / 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    partner['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498DB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${share.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Color(0xFF3498DB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('قيمة الحصة:', style: TextStyle(fontSize: 14)),
                  Text(
                    _formatCurrency(shareAmount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            if (partner['notes'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'ملاحظات:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    partner['notes'],
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'تم الإضافة: ${_formatDate(partner['createdAt'])}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.blue,
                      ),
                      onPressed: () => _showAddEditPartnerDialog(partner),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.red,
                      ),
                      onPressed: () => _deletePartner(partner),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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
}
