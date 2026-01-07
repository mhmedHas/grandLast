// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class IncomePage extends StatefulWidget {
//   const IncomePage({super.key});

//   @override
//   State<IncomePage> createState() => _IncomePageState();
// }

// class _IncomePageState extends State<IncomePage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _checkNumberController = TextEditingController();
//   final TextEditingController _companyNameController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();

//   // أنواع الدخول المالية
//   final List<Map<String, dynamic>> _entryTypes = [
//     {'name': 'نقدي', 'icon': Icons.money, 'color': Colors.green},
//     {'name': 'شيك تم صرفه', 'icon': Icons.check_circle, 'color': Colors.blue},
//     {'name': 'شيك لم يتم صرفه', 'icon': Icons.pending, 'color': Colors.orange},
//     {
//       'name': 'تحويل بنكي',
//       'icon': Icons.account_balance,
//       'color': Colors.purple,
//     },
//   ];

//   String _selectedEntryType = 'نقدي';
//   DateTime _selectedDate = DateTime.now();
//   DateTime? _checkDueDate;
//   bool _isLoading = false;
//   bool _showCheckFields = false;
//   double _totalIncome = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _loadTotalIncome();
//   }

//   Future<void> _loadTotalIncome() async {
//     try {
//       final snapshot = await _firestore
//           .collection('treasury_entries')
//           .where('isCleared', isEqualTo: true)
//           .get();

//       double total = 0;
//       for (var doc in snapshot.docs) {
//         total += (doc.data()['amount'] as num).toDouble();
//       }

//       setState(() {
//         _totalIncome = total;
//       });
//     } catch (e) {
//       print('Error loading income: $e');
//     }
//   }

//   Future<void> _addIncome() async {
//     if (_amountController.text.isEmpty) {
//       _showSnackBar('الرجاء إدخال المبلغ', Colors.red);
//       return;
//     }

//     final amount = double.tryParse(_amountController.text);
//     if (amount == null || amount <= 0) {
//       _showSnackBar('الرجاء إدخال مبلغ صحيح', Colors.red);
//       return;
//     }

//     if (_showCheckFields) {
//       if (_checkNumberController.text.isEmpty) {
//         _showSnackBar('الرجاء إدخال رقم الشيك', Colors.red);
//         return;
//       }
//       if (_companyNameController.text.isEmpty) {
//         _showSnackBar('الرجاء إدخال اسم الشركة', Colors.red);
//         return;
//       }
//       if (_selectedEntryType == 'شيك لم يتم صرفه' && _checkDueDate == null) {
//         _showSnackBar('الرجاء إدخال تاريخ استحقاق الشيك', Colors.red);
//         return;
//       }
//     }

//     setState(() => _isLoading = true);

//     try {
//       final incomeData = {
//         'amount': amount,
//         'entryType': _selectedEntryType,
//         'description': _descriptionController.text,
//         'date': Timestamp.fromDate(_selectedDate),
//         'createdAt': Timestamp.now(),
//         'isCleared': _selectedEntryType != 'شيك لم يتم صرفه',
//         'category': 'دخل',
//         'status': _selectedEntryType == 'شيك لم يتم صرفه' ? 'معلق' : 'مصروف',
//       };

//       // إضافة بيانات الشيك إذا كان نوع الدخل شيك
//       if (_showCheckFields) {
//         incomeData['checkNumber'] = _checkNumberController.text;
//         incomeData['companyName'] = _companyNameController.text;
//         incomeData['checkType'] = _selectedEntryType;

//         if (_selectedEntryType == 'شيك لم يتم صرفه') {
//           incomeData['checkDueDate'] = Timestamp.fromDate(_checkDueDate!);
//         } else {
//           incomeData['clearedDate'] = Timestamp.now();
//         }
//       }

//       await _firestore.collection('treasury_entries').add(incomeData);

//       // تحديث الإجمالي إذا كان نقدي أو شيك مصروف
//       if (_selectedEntryType != 'شيك لم يتم صرفه') {
//         setState(() => _totalIncome += amount);
//       }

//       // إضافة لسجل الحركات العام
//       await _firestore.collection('treasury_movements').add({
//         'amount': amount,
//         'type': 'income',
//         'description':
//             '${_selectedEntryType}: ${_descriptionController.text.isNotEmpty ? _descriptionController.text : 'دخل نقدي'}',
//         'date': Timestamp.now(),
//         'entryType': _selectedEntryType,
//       });

//       _showSnackBar('تم إضافة الدخل بنجاح', Colors.green);
//       _resetForm();
//     } catch (e) {
//       _showSnackBar('حدث خطأ: $e', Colors.red);
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Widget _buildIncomeForm() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // بطاقة الإجمالي
//           Card(
//             elevation: 3,
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   Icon(Icons.trending_up, color: Colors.green, size: 32),
//                   const SizedBox(width: 16),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         'إجمالي الدخل',
//                         style: TextStyle(fontSize: 14, color: Colors.grey),
//                       ),
//                       Text(
//                         '${_totalIncome.toStringAsFixed(2)} ج',
//                         style: const TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 20),

//           // نوع الدخل
//           DropdownButtonFormField<String>(
//             value: _selectedEntryType,
//             decoration: InputDecoration(
//               labelText: 'نوع الدخل',
//               prefixIcon: Icon(Icons.category, color: Colors.blue),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             items: _entryTypes.map((type) {
//               return DropdownMenuItem<String>(
//                 value: type['name'],
//                 child: Row(
//                   children: [
//                     Icon(type['icon'], color: type['color'], size: 20),
//                     const SizedBox(width: 12),
//                     Text(type['name']),
//                   ],
//                 ),
//               );
//             }).toList(),
//             onChanged: (value) {
//               setState(() {
//                 _selectedEntryType = value!;
//                 _showCheckFields = value.contains('شيك');
//               });
//             },
//           ),

//           const SizedBox(height: 16),

//           // المبلغ
//           TextField(
//             controller: _amountController,
//             keyboardType: TextInputType.number,
//             decoration: InputDecoration(
//               labelText: 'المبلغ',
//               prefixText: 'ج ',
//               prefixIcon: Icon(Icons.attach_money, color: Colors.green),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//           ),

//           const SizedBox(height: 16),

//           // التاريخ
//           _buildDateField(
//             'تاريخ الدخل',
//             _selectedDate,
//             (picked) {
//               if (picked != null) {
//                 setState(() => _selectedDate = picked);
//               }
//             },
//             Icons.calendar_today,
//             Colors.blue,
//           ),

//           // حقول الشيك (تظهر فقط إذا كان نوع الدخل شيك)
//           if (_showCheckFields) ...[
//             const SizedBox(height: 16),

//             // رقم الشيك
//             TextField(
//               controller: _checkNumberController,
//               decoration: InputDecoration(
//                 labelText: 'رقم الشيك',
//                 prefixIcon: Icon(
//                   Icons.confirmation_number,
//                   color: Colors.orange,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // اسم الشركة
//             TextField(
//               controller: _companyNameController,
//               decoration: InputDecoration(
//                 labelText: 'اسم الشركة / الجهة',
//                 prefixIcon: Icon(Icons.business, color: Colors.purple),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),

//             // تاريخ استحقاق الشيك (لـ "شيك لم يتم صرفه")
//             if (_selectedEntryType == 'شيك لم يتم صرفه') ...[
//               const SizedBox(height: 16),

//               _buildDateField(
//                 'تاريخ استحقاق الشيك',
//                 _checkDueDate ?? DateTime.now().add(Duration(days: 30)),
//                 (picked) {
//                   if (picked != null) {
//                     setState(() => _checkDueDate = picked);
//                   }
//                 },
//                 Icons.calendar_month,
//                 Colors.orange,
//               ),
//             ],
//           ],

//           const SizedBox(height: 16),

//           // الوصف
//           TextField(
//             controller: _descriptionController,
//             maxLines: 2,
//             decoration: InputDecoration(
//               labelText: 'الوصف / الملاحظات',
//               prefixIcon: Icon(Icons.description, color: Colors.grey),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               hintText: 'أضف وصفاً للدخل...',
//             ),
//           ),

//           const SizedBox(height: 24),

//           // زر الإضافة
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: _isLoading ? null : _addIncome,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.green,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
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
//                   : const Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.add, color: Colors.white),
//                         SizedBox(width: 8),
//                         Text(
//                           'إضافة دخل',
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

//   Widget _buildDateField(
//     String label,
//     DateTime date,
//     Function(DateTime?) onDatePicked,
//     IconData icon,
//     Color color,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey[300]!),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, color: color, size: 20),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                 ),
//                 Text(
//                   DateFormat('yyyy/MM/dd').format(date),
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           IconButton(
//             onPressed: () async {
//               final DateTime? picked = await showDatePicker(
//                 context: context,
//                 initialDate: date,
//                 firstDate: DateTime(2000),
//                 lastDate: DateTime(2100),
//               );
//               onDatePicked(picked);
//             },
//             icon: Icon(Icons.edit, size: 20),
//             style: IconButton.styleFrom(
//               backgroundColor: color.withOpacity(0.1),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRecentIncome() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _firestore
//           .collection('treasury_entries')
//           .orderBy('date', descending: true)
//           .limit(20)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final docs = snapshot.data!.docs;

//         return Card(
//           margin: const EdgeInsets.all(16),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'آخر الإيرادات',
//                   style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                 ),
//                 const SizedBox(height: 12),
//                 ...docs.map((doc) {
//                   final data = doc.data() as Map<String, dynamic>;
//                   final date = (data['date'] as Timestamp).toDate();
//                   final entryType = data['entryType'] as String;
//                   final amount = (data['amount'] as num).toDouble();
//                   final isCleared = data['isCleared'] ?? true;

//                   return Card(
//                     margin: const EdgeInsets.only(bottom: 8),
//                     child: ListTile(
//                       leading: CircleAvatar(
//                         backgroundColor: _getTypeColor(
//                           entryType,
//                         ).withOpacity(0.1),
//                         child: Icon(
//                           _getTypeIcon(entryType),
//                           color: _getTypeColor(entryType),
//                           size: 20,
//                         ),
//                       ),
//                       title: Text(
//                         '${amount.toStringAsFixed(2)} ج',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Colors.green,
//                           fontSize: 16,
//                         ),
//                       ),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: 4),
//                           Text(entryType),
//                           const SizedBox(height: 2),
//                           Text(
//                             DateFormat('yyyy/MM/dd').format(date),
//                             style: const TextStyle(fontSize: 12),
//                           ),
//                           if (data['description'] != null &&
//                               data['description'].isNotEmpty)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 4),
//                               child: Text(
//                                 data['description'],
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey[600],
//                                 ),
//                               ),
//                             ),
//                           if (!isCleared)
//                             Container(
//                               margin: const EdgeInsets.only(top: 4),
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 8,
//                                 vertical: 2,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.orange.withOpacity(0.1),
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               child: Text(
//                                 'معلق',
//                                 style: TextStyle(
//                                   color: Colors.orange,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                         ],
//                       ),
//                       trailing: PopupMenuButton<String>(
//                         itemBuilder: (context) => [
//                           const PopupMenuItem(
//                             value: 'edit',
//                             child: Row(
//                               children: [
//                                 Icon(Icons.edit, size: 18),
//                                 SizedBox(width: 8),
//                                 Text('تعديل'),
//                               ],
//                             ),
//                           ),
//                           const PopupMenuItem(
//                             value: 'delete',
//                             child: Row(
//                               children: [
//                                 Icon(Icons.delete, color: Colors.red, size: 18),
//                                 SizedBox(width: 8),
//                                 Text(
//                                   'حذف',
//                                   style: TextStyle(color: Colors.red),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                         onSelected: (value) {
//                           // تنفيذ التعديل أو الحذف
//                         },
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Color _getTypeColor(String type) {
//     for (var entryType in _entryTypes) {
//       if (entryType['name'] == type) {
//         return entryType['color'];
//       }
//     }
//     return Colors.grey;
//   }

//   IconData _getTypeIcon(String type) {
//     for (var entryType in _entryTypes) {
//       if (entryType['name'] == type) {
//         return entryType['icon'];
//       }
//     }
//     return Icons.money;
//   }

//   void _resetForm() {
//     _amountController.clear();
//     _checkNumberController.clear();
//     _companyNameController.clear();
//     _descriptionController.clear();
//     _selectedEntryType = 'نقدي';
//     _showCheckFields = false;
//     _selectedDate = DateTime.now();
//     _checkDueDate = null;
//   }

//   void _showSnackBar(String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('الداخل للخزنة'),
//           centerTitle: true,
//           backgroundColor: const Color(0xFF1B4F72),
//           elevation: 0,
//           actions: [
//             IconButton(
//               onPressed: _loadTotalIncome,
//               icon: const Icon(Icons.refresh),
//             ),
//           ],
//           bottom: const TabBar(
//             tabs: [
//               Tab(icon: Icon(Icons.add), text: 'إضافة دخل'),
//               Tab(icon: Icon(Icons.list), text: 'السجل'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             _buildIncomeForm(),
//             SingleChildScrollView(child: _buildRecentIncome()),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _amountController.dispose();
//     _checkNumberController.dispose();
//     _companyNameController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _checkNumberController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // أنواع الدخول المالية
  final List<Map<String, dynamic>> _entryTypes = [
    {'name': 'نقدي', 'icon': Icons.money, 'color': Colors.green},
    {'name': 'شيك تم صرفه', 'icon': Icons.check_circle, 'color': Colors.blue},
    {'name': 'شيك لم يتم صرفه', 'icon': Icons.pending, 'color': Colors.orange},
  ];

  String _selectedEntryType = 'نقدي';
  DateTime _selectedDate = DateTime.now();
  DateTime _checkDueDate = DateTime.now().add(Duration(days: 30));
  bool _isLoading = false;
  bool _showCheckFields = false;
  double _treasuryBalance = 0.0;
  double _pendingChecksTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTreasuryBalance();
    _loadPendingChecks();
  }

  // ================= تحميل رصيد الخزنة =================
  Future<void> _loadTreasuryBalance() async {
    try {
      // مجموع الدخل النقدي والمصروف
      final incomeSnapshot = await _firestore
          .collection('treasury_entries')
          .where('isCleared', isEqualTo: true)
          .get();

      double totalIncome = 0;
      for (var doc in incomeSnapshot.docs) {
        totalIncome += (doc.data()['amount'] as num).toDouble();
      }

      // مجموع الخرج
      final expenseSnapshot = await _firestore
          .collection('treasury_exits')
          .get();

      double totalExpense = 0;
      for (var doc in expenseSnapshot.docs) {
        totalExpense += (doc.data()['amount'] as num).toDouble();
      }

      setState(() {
        _treasuryBalance = totalIncome - totalExpense;
      });
    } catch (e) {
      print('Error loading treasury balance: $e');
    }
  }

  // ================= تحميل الشيكات المعلقة =================
  Future<void> _loadPendingChecks() async {
    try {
      final snapshot = await _firestore
          .collection('treasury_entries')
          .where('entryType', isEqualTo: 'شيك لم يتم صرفه')
          .where('isCleared', isEqualTo: false)
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['amount'] as num).toDouble();
      }

      setState(() {
        _pendingChecksTotal = total;
      });
    } catch (e) {
      print('Error loading pending checks: $e');
    }
  }

  Future<void> _addIncome() async {
    if (_amountController.text.isEmpty) {
      _showSnackBar('الرجاء إدخال المبلغ', Colors.red);
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showSnackBar('الرجاء إدخال مبلغ صحيح', Colors.red);
      return;
    }

    if (_showCheckFields) {
      if (_checkNumberController.text.isEmpty) {
        _showSnackBar('الرجاء إدخال رقم الشيك', Colors.red);
        return;
      }
      if (_companyNameController.text.isEmpty) {
        _showSnackBar('الرجاء إدخال اسم الشركة', Colors.red);
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final isCleared = _selectedEntryType != 'شيك لم يتم صرفه';

      final incomeData = {
        'amount': amount,
        'entryType': _selectedEntryType,
        'description': _descriptionController.text,
        'date': Timestamp.fromDate(_selectedDate),
        'createdAt': Timestamp.now(),
        'isCleared': isCleared,
        'status': isCleared ? 'مصروف' : 'معلق',
      };

      // إضافة بيانات الشيك إذا كان نوع الدخل شيك
      if (_showCheckFields) {
        incomeData['checkNumber'] = _checkNumberController.text;
        incomeData['companyName'] = _companyNameController.text;

        if (_selectedEntryType == 'شيك لم يتم صرفه') {
          incomeData['checkDueDate'] = Timestamp.fromDate(_checkDueDate);
        } else {
          incomeData['clearedDate'] = Timestamp.now();
        }
      }

      await _firestore.collection('treasury_entries').add(incomeData);

      // تحديث الرصيد إذا كان نقدي أو شيك مصروف
      if (isCleared) {
        setState(() => _treasuryBalance += amount);
      } else {
        // إذا كان شيك معلق، نضيفه للمجموع
        setState(() => _pendingChecksTotal += amount);
      }

      _showSnackBar('تم إضافة الدخل بنجاح', Colors.green);
      _resetForm();
    } catch (e) {
      _showSnackBar('حدث خطأ: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ================= تأكيد صرف الشيك =================
  Future<void> _confirmCheckClearing(String checkId, double amount) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تأكيد صرف الشيك'),
          content: const Text(
            'هل أنت متأكد من صرف هذا الشيك وإضافة قيمته للخزنة؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _clearCheck(checkId, amount);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                'تأكيد الصرف',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearCheck(String checkId, double amount) async {
    try {
      await _firestore.collection('treasury_entries').doc(checkId).update({
        'isCleared': true,
        'clearedDate': Timestamp.now(),
        'status': 'مصروف',
      });

      setState(() {
        _treasuryBalance += amount;
        _pendingChecksTotal -= amount;
      });

      _showSnackBar('تم صرف الشيك وإضافة المبلغ للخزنة', Colors.green);
      _loadPendingChecks();
    } catch (e) {
      _showSnackBar('حدث خطأ: $e', Colors.red);
    }
  }

  Widget _buildIncomeForm() {
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Icon(
                            Icons.pending_actions,
                            color: Colors.orange,
                            size: 20,
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${_pendingChecksTotal.toStringAsFixed(2)} ج',
                            style: TextStyle(
                              color: Colors.orange[200],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'شيكات معلقة',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 24),

          // نوع الدخل
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: DropdownButton<String>(
                value: _selectedEntryType,
                isExpanded: true,
                underline: SizedBox(),
                items: _entryTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type['name'],
                    child: Row(
                      children: [
                        Icon(type['icon'], color: type['color'], size: 20),
                        SizedBox(width: 12),
                        Text(
                          type['name'],
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEntryType = value!;
                    _showCheckFields = value.contains('شيك');
                  });
                },
              ),
            ),
          ),

          SizedBox(height: 16),

          // المبلغ
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  labelText: 'المبلغ',
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  prefixText: 'ج ',
                  prefixStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                  border: InputBorder.none,
                  icon: Icon(Icons.attach_money, color: Colors.green),
                ),
              ),
            ),
          ),

          SizedBox(height: 16),

          // التاريخ
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
                          'التاريخ',
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

          // حقول الشيك (تظهر فقط إذا كان نوع الدخل شيك)
          if (_showCheckFields) ...[
            SizedBox(height: 16),

            // رقم الشيك
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _checkNumberController,
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'رقم الشيك',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                    border: InputBorder.none,
                    icon: Icon(Icons.confirmation_number, color: Colors.orange),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),

            // اسم الشركة
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _companyNameController,
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'اسم الشركة / الجهة',
                    labelStyle: TextStyle(color: Colors.grey[700]),
                    border: InputBorder.none,
                    icon: Icon(Icons.business, color: Colors.purple),
                  ),
                ),
              ),
            ),

            // تاريخ استحقاق الشيك (لـ "شيك لم يتم صرفه")
            if (_selectedEntryType == 'شيك لم يتم صرفه') ...[
              SizedBox(height: 16),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: Colors.orange,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'تاريخ استحقاق الشيك',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              DateFormat('yyyy/MM/dd').format(_checkDueDate),
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
                            initialDate: _checkDueDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 365)),
                          );
                          if (picked != null) {
                            setState(() => _checkDueDate = picked);
                          }
                        },
                        icon: Icon(Icons.edit, color: Colors.orange),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],

          SizedBox(height: 16),

          // الوصف
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _descriptionController,
                maxLines: 2,
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'الوصف / الملاحظات',
                  labelStyle: TextStyle(color: Colors.grey[700]),
                  border: InputBorder.none,
                  icon: Icon(Icons.description, color: Colors.grey[700]),
                  hintText: 'أضف وصفاً للدخل...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
          ),

          SizedBox(height: 24),

          // زر الإضافة
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _addIncome,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
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
                        Icon(Icons.add, color: Colors.white, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'إضافة دخل',
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

  Widget _buildRecentIncome() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('treasury_entries')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final allDocs = snapshot.data!.docs;
        final pendingChecks = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['entryType'] == 'شيك لم يتم صرفه' &&
              data['isCleared'] == false;
        }).toList();

        final otherEntries = allDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return data['entryType'] != 'شيك لم يتم صرفه' ||
              data['isCleared'] == true;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // قسم الشيكات المعلقة
              if (pendingChecks.isNotEmpty) ...[
                Card(
                  elevation: 3,
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
                            Icon(
                              Icons.pending_actions,
                              color: Colors.orange,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'الشيكات المعلقة',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[800],
                              ),
                            ),
                            Spacer(),
                            Chip(
                              label: Text('${pendingChecks.length} شيك'),
                              backgroundColor: Colors.orange[100],
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Divider(color: Colors.grey[300]),
                        SizedBox(height: 8),
                        ...pendingChecks.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final date = (data['date'] as Timestamp).toDate();
                          final dueDate = data['checkDueDate'] != null
                              ? (data['checkDueDate'] as Timestamp).toDate()
                              : date;
                          final amount = (data['amount'] as num).toDouble();
                          final daysRemaining = dueDate
                              .difference(DateTime.now())
                              .inDays;

                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: daysRemaining <= 3
                                  ? Colors.orange[50]
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.orange[100],
                                child: Icon(
                                  Icons.credit_card,
                                  color: Colors.orange,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    data['companyName'] ?? 'غير معروف',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Chip(
                                    label: Text(
                                      '${amount.toStringAsFixed(2)} ج',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.orange,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
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
                                        Icons.confirmation_number,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'رقم: ${data['checkNumber'] ?? 'غير معروف'}',
                                      ),
                                      SizedBox(width: 16),
                                      Icon(
                                        Icons.calendar_month,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        DateFormat(
                                          'yyyy/MM/dd',
                                        ).format(dueDate),
                                        style: TextStyle(
                                          color: daysRemaining <= 3
                                              ? Colors.red
                                              : null,
                                          fontWeight: daysRemaining <= 3
                                              ? FontWeight.bold
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: daysRemaining <= 3
                                              ? Colors.red[100]
                                              : Colors.green[100],
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          daysRemaining > 0
                                              ? '$daysRemaining يوم متبقي'
                                              : 'منتهي',
                                          style: TextStyle(
                                            color: daysRemaining <= 3
                                                ? Colors.red
                                                : Colors.green,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      ElevatedButton(
                                        onPressed: () => _confirmCheckClearing(
                                          doc.id,
                                          amount,
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 6,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'تم الصرف',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],

              // قسم باقي الإيرادات
              // Card(
              //   elevation: 3,
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   child: Padding(
              //     padding: const EdgeInsets.all(16),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         Row(
              //           children: [
              //             Icon(Icons.list, color: Color(0xFF1B4F72), size: 24),
              //             SizedBox(width: 8),
              //             Text(
              //               'سجل الإيرادات',
              //               style: TextStyle(
              //                 fontSize: 18,
              //                 fontWeight: FontWeight.bold,
              //                 color: Color(0xFF1B4F72),
              //               ),
              //             ),
              //           ],
              //         ),
              //         SizedBox(height: 12),
              //         Divider(color: Colors.grey[300]),
              //         SizedBox(height: 8),
              //         ...otherEntries.map((doc) {
              //           final data = doc.data() as Map<String, dynamic>;
              //           final date = (data['date'] as Timestamp).toDate();
              //           final entryType = data['entryType'] as String;
              //           final amount = (data['amount'] as num).toDouble();
              //           final isCleared = data['isCleared'] ?? true;

              //           return Container(
              //             margin: EdgeInsets.only(bottom: 8),
              //             decoration: BoxDecoration(
              //               border: Border(
              //                 bottom: BorderSide(color: Colors.grey[200]!),
              //               ),
              //             ),
              //             child: ListTile(
              //               contentPadding: EdgeInsets.zero,
              //               leading: CircleAvatar(
              //                 backgroundColor: _getTypeColor(
              //                   entryType,
              //                 ).withOpacity(0.1),
              //                 child: Icon(
              //                   _getTypeIcon(entryType),
              //                   color: _getTypeColor(entryType),
              //                   size: 22,
              //                 ),
              //               ),
              //               title: Row(
              //                 children: [
              //                   Expanded(
              //                     child: Text(
              //                       entryType,
              //                       style: TextStyle(
              //                         fontWeight: FontWeight.bold,
              //                         fontSize: 16,
              //                       ),
              //                     ),
              //                   ),
              //                   Text(
              //                     '${amount.toStringAsFixed(2)} ج',
              //                     style: TextStyle(
              //                       fontWeight: FontWeight.bold,
              //                       color: Colors.green[700],
              //                       fontSize: 16,
              //                     ),
              //                   ),
              //                 ],
              //               ),
              //               subtitle: Column(
              //                 crossAxisAlignment: CrossAxisAlignment.start,
              //                 children: [
              //                   SizedBox(height: 4),
              //                   Text(
              //                     DateFormat(
              //                       'yyyy/MM/dd - hh:mm a',
              //                     ).format(date),
              //                     style: TextStyle(
              //                       fontSize: 13,
              //                       color: Colors.grey[600],
              //                     ),
              //                   ),
              //                   if (data['description'] != null &&
              //                       data['description'].isNotEmpty)
              //                     Padding(
              //                       padding: const EdgeInsets.only(top: 4),
              //                       child: Text(
              //                         data['description'],
              //                         style: TextStyle(
              //                           fontSize: 13,
              //                           color: Colors.grey[700],
              //                         ),
              //                       ),
              //                     ),
              //                   if (!isCleared)
              //                     Container(
              //                       margin: const EdgeInsets.only(top: 4),
              //                       padding: const EdgeInsets.symmetric(
              //                         horizontal: 8,
              //                         vertical: 2,
              //                       ),
              //                       decoration: BoxDecoration(
              //                         color: Colors.orange.withOpacity(0.1),
              //                         borderRadius: BorderRadius.circular(4),
              //                       ),
              //                       child: Text(
              //                         'معلق',
              //                         style: TextStyle(
              //                           color: Colors.orange,
              //                           fontSize: 11,
              //                           fontWeight: FontWeight.bold,
              //                         ),
              //                       ),
              //                     ),
              //                 ],
              //               ),
              //               trailing: PopupMenuButton<String>(
              //                 icon: Icon(
              //                   Icons.more_vert,
              //                   color: Colors.grey[600],
              //                 ),
              //                 itemBuilder: (context) => [
              //                   PopupMenuItem(
              //                     value: 'edit',
              //                     child: Row(
              //                       children: [
              //                         Icon(
              //                           Icons.edit,
              //                           size: 18,
              //                           color: Colors.blue,
              //                         ),
              //                         SizedBox(width: 8),
              //                         Text(
              //                           'تعديل',
              //                           style: TextStyle(color: Colors.blue),
              //                         ),
              //                       ],
              //                     ),
              //                   ),
              //                   PopupMenuItem(
              //                     value: 'delete',
              //                     child: Row(
              //                       children: [
              //                         Icon(
              //                           Icons.delete,
              //                           color: Colors.red,
              //                           size: 18,
              //                         ),
              //                         SizedBox(width: 8),
              //                         Text(
              //                           'حذف',
              //                           style: TextStyle(color: Colors.red),
              //                         ),
              //                       ],
              //                     ),
              //                   ),
              //                 ],
              //                 onSelected: (value) {
              //                   if (value == 'delete') {
              //                     _confirmDelete(doc.id, entryType, amount);
              //                   }
              //                 },
              //               ),
              //             ),
              //           );
              //         }),
              //       ],
              //     ),
              //   ),
              // ),
              Card(
                elevation: 3,
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
                          Icon(Icons.list, color: Color(0xFF1B4F72), size: 24),
                          SizedBox(width: 8),
                          Text(
                            'سجل الإيرادات',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B4F72),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Divider(color: Colors.grey[300]),
                      SizedBox(height: 8),
                      ...otherEntries.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final dateTimestamp = data['date'] as Timestamp?;
                        final date = dateTimestamp?.toDate() ?? DateTime.now();

                        // التحقق من وجود entryType وعرض قيمة بديلة إذا كانت null
                        final entryType =
                            data['entryType']?.toString() ?? 'غير محدد';

                        final amountNum = data['amount'];
                        final amount = amountNum != null
                            ? (amountNum as num).toDouble()
                            : 0.0;

                        final isCleared = data['isCleared'] ?? true;
                        final description =
                            data['description']?.toString() ?? '';

                        return Container(
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: _getTypeColor(
                                entryType,
                              ).withOpacity(0.1),
                              child: Icon(
                                _getTypeIcon(entryType),
                                color: _getTypeColor(entryType),
                                size: 22,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    entryType,
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
                                    color: Colors.green[700],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 4),
                                Text(
                                  DateFormat(
                                    'yyyy/MM/dd - hh:mm a',
                                  ).format(date),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
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
                                if (!isCleared)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'معلق',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.grey[600],
                              ),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'تعديل',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'حذف',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _confirmDelete(doc.id, entryType, amount);
                                }
                              },
                            ),
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

  Future<void> _confirmDelete(
    String docId,
    String entryType,
    double amount,
  ) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("تأكيد الحذف"),
          content: Text(
            "هل أنت متأكد من حذف $entryType بقيمة ${amount.toStringAsFixed(2)} ج؟",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _firestore
                      .collection("treasury_entries")
                      .doc(docId)
                      .delete();
                  _showSnackBar("تم الحذف بنجاح", Colors.red);
                  _loadTreasuryBalance();
                  _loadPendingChecks();
                } catch (e) {
                  _showSnackBar("حدث خطأ أثناء الحذف: $e", Colors.red);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("حذف", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Color _getTypeColor(String type) {
    for (var entryType in _entryTypes) {
      if (entryType['name'] == type) {
        return entryType['color'];
      }
    }
    return Colors.grey;
  }

  IconData _getTypeIcon(String type) {
    for (var entryType in _entryTypes) {
      if (entryType['name'] == type) {
        return entryType['icon'];
      }
    }
    return Icons.money;
  }

  void _resetForm() {
    _amountController.clear();
    _checkNumberController.clear();
    _companyNameController.clear();
    _descriptionController.clear();
    _selectedEntryType = 'نقدي';
    _showCheckFields = false;
    _selectedDate = DateTime.now();
    _checkDueDate = DateTime.now().add(Duration(days: 30));
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
            'الداخل للخزنة',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Color(0xFF1B4F72),
          elevation: 4,
          actions: [
            IconButton(
              onPressed: () {
                _loadTreasuryBalance();
                _loadPendingChecks();
              },
              icon: Icon(Icons.refresh, color: Colors.white),
            ),
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(
                icon: Icon(Icons.add_circle_outline, size: 22),
                text: 'إضافة دخل',
              ),
              Tab(icon: Icon(Icons.list_alt, size: 22), text: 'سجل الإيرادات'),
            ],
          ),
        ),
        body: TabBarView(children: [_buildIncomeForm(), _buildRecentIncome()]),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _checkNumberController.dispose();
    _companyNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
