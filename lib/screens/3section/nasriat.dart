// // // // // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // // // // import 'package:flutter/material.dart';
// // // // // // import 'package:intl/intl.dart';

// // // // // // class ExpensesPage extends StatefulWidget {
// // // // // //   const ExpensesPage({super.key});

// // // // // //   @override
// // // // // //   State<ExpensesPage> createState() => _ExpensesPageState();
// // // // // // }

// // // // // // class _ExpensesPageState extends State<ExpensesPage> {
// // // // // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// // // // // //   final TextEditingController _titleController = TextEditingController();
// // // // // //   final TextEditingController _amountController = TextEditingController();
// // // // // //   final TextEditingController _noteController = TextEditingController();

// // // // // //   String selectedCategory = "نثريات";
// // // // // //   DateTime selectedDate = DateTime.now();
// // // // // //   bool _isLoading = false;
// // // // // //   String? _editingDocId;

// // // // // //   // التصنيفات مع ألوان وأيقونات
// // // // // //   final List<Map<String, dynamic>> _categories = [
// // // // // //     {"name": "نثريات", "color": Colors.purple, "icon": Icons.category},
// // // // // //     {"name": "تشغيل", "color": Colors.blue, "icon": Icons.business},
// // // // // //     {"name": "مواصلات", "color": Colors.green, "icon": Icons.directions_car},
// // // // // //     {"name": "أدوات", "color": Colors.orange, "icon": Icons.build},
// // // // // //     {"name": "طعام", "color": Colors.red, "icon": Icons.restaurant},
// // // // // //     {"name": "صحة", "color": Colors.teal, "icon": Icons.medical_services},
// // // // // //     {"name": "أخرى", "color": Colors.grey, "icon": Icons.more_horiz},
// // // // // //   ];

// // // // // //   // ================= فلترة مشابهة لشغل السائقين =================
// // // // // //   int _selectedMonth = DateTime.now().month;
// // // // // //   int _selectedYear = DateTime.now().year;
// // // // // //   String _timeFilter = 'الكل';
// // // // // //   String _searchQuery = '';
// // // // // //   List<QueryDocumentSnapshot> _filteredDocs = [];

// // // // // //   @override
// // // // // //   void initState() {
// // // // // //     super.initState();
// // // // // //     _resetForm();
// // // // // //   }

// // // // // //   // ================= فلترة حسب التاريخ =================
// // // // // //   List<QueryDocumentSnapshot> _filterExpensesByDate(
// // // // // //     List<QueryDocumentSnapshot> allDocs,
// // // // // //   ) {
// // // // // //     return allDocs.where((doc) {
// // // // // //       final data = doc.data() as Map<String, dynamic>;
// // // // // //       final date = (data['date'] as Timestamp).toDate();

// // // // // //       if (_timeFilter == 'الكل') return true;

// // // // // //       final now = DateTime.now();
// // // // // //       switch (_timeFilter) {
// // // // // //         case 'اليوم':
// // // // // //           return date.year == now.year &&
// // // // // //               date.month == now.month &&
// // // // // //               date.day == now.day;
// // // // // //         case 'هذا الشهر':
// // // // // //           return date.year == now.year && date.month == now.month;
// // // // // //         case 'هذه السنة':
// // // // // //           return date.year == now.year;
// // // // // //         case 'مخصص':
// // // // // //           return date.year == _selectedYear && date.month == _selectedMonth;
// // // // // //         default:
// // // // // //           return true;
// // // // // //       }
// // // // // //     }).toList();
// // // // // //   }

// // // // // //   void _changeTimeFilter(String filter) {
// // // // // //     setState(() => _timeFilter = filter);
// // // // // //     _applyFilters();
// // // // // //   }

// // // // // //   void _applyMonthYearFilter() {
// // // // // //     setState(() => _timeFilter = 'مخصص');
// // // // // //     _applyFilters();
// // // // // //   }

// // // // // //   void _applyFilters() {
// // // // // //     // سيعمل مع Stream Builder
// // // // // //     setState(() {});
// // // // // //   }

// // // // // //   // ================= إضافة/تعديل مصروف =================
// // // // // //   Future<void> _openExpenseSheet({
// // // // // //     String? docId,
// // // // // //     Map<String, dynamic>? data,
// // // // // //   }) async {
// // // // // //     _editingDocId = docId;

// // // // // //     if (data != null) {
// // // // // //       // وضع التعديل
// // // // // //       _titleController.text = data['title'];
// // // // // //       _amountController.text = data['amount'].toString();
// // // // // //       _noteController.text = data['note'] ?? '';
// // // // // //       selectedCategory = data['category'];
// // // // // //       selectedDate = (data['date'] as Timestamp).toDate();
// // // // // //     } else {
// // // // // //       // وضع الإضافة
// // // // // //       _titleController.clear();
// // // // // //       _amountController.clear();
// // // // // //       _noteController.clear();
// // // // // //       selectedCategory = "نثريات";
// // // // // //       selectedDate = DateTime.now();
// // // // // //     }

// // // // // //     await showDialog(
// // // // // //       context: context,
// // // // // //       builder: (context) {
// // // // // //         return AlertDialog(
// // // // // //           title: Text(
// // // // // //             docId == null ? "إضافة مصروف جديد" : "تعديل المصروف",
// // // // // //             style: const TextStyle(fontWeight: FontWeight.bold),
// // // // // //           ),
// // // // // //           content: SingleChildScrollView(
// // // // // //             child: Column(
// // // // // //               mainAxisSize: MainAxisSize.min,
// // // // // //               children: [
// // // // // //                 // التاريخ أولاً
// // // // // //                 Container(
// // // // // //                   padding: const EdgeInsets.all(12),
// // // // // //                   decoration: BoxDecoration(
// // // // // //                     border: Border.all(color: Colors.grey.shade300),
// // // // // //                     borderRadius: BorderRadius.circular(8),
// // // // // //                   ),
// // // // // //                   child: Row(
// // // // // //                     children: [
// // // // // //                       const Icon(
// // // // // //                         Icons.calendar_today,
// // // // // //                         size: 20,
// // // // // //                         color: Colors.blue,
// // // // // //                       ),
// // // // // //                       const SizedBox(width: 12),
// // // // // //                       Expanded(
// // // // // //                         child: Column(
// // // // // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //                           children: [
// // // // // //                             const Text(
// // // // // //                               "التاريخ",
// // // // // //                               style: TextStyle(
// // // // // //                                 fontSize: 12,
// // // // // //                                 color: Colors.grey,
// // // // // //                               ),
// // // // // //                             ),
// // // // // //                             Text(
// // // // // //                               DateFormat('yyyy/MM/dd').format(selectedDate),
// // // // // //                               style: const TextStyle(
// // // // // //                                 fontWeight: FontWeight.bold,
// // // // // //                                 fontSize: 16,
// // // // // //                               ),
// // // // // //                             ),
// // // // // //                           ],
// // // // // //                         ),
// // // // // //                       ),
// // // // // //                       IconButton(
// // // // // //                         onPressed: () async {
// // // // // //                           final DateTime? picked = await showDatePicker(
// // // // // //                             context: context,
// // // // // //                             initialDate: selectedDate,
// // // // // //                             firstDate: DateTime(2000),
// // // // // //                             lastDate: DateTime(2100),
// // // // // //                           );
// // // // // //                           if (picked != null) {
// // // // // //                             setState(() {
// // // // // //                               selectedDate = picked;
// // // // // //                             });
// // // // // //                           }
// // // // // //                         },
// // // // // //                         icon: const Icon(Icons.edit, size: 20),
// // // // // //                         style: IconButton.styleFrom(
// // // // // //                           backgroundColor: Colors.blue.shade50,
// // // // // //                         ),
// // // // // //                       ),
// // // // // //                     ],
// // // // // //                   ),
// // // // // //                 ),
// // // // // //                 const SizedBox(height: 16),

// // // // // //                 // المبلغ ثانياً
// // // // // //                 TextField(
// // // // // //                   controller: _amountController,
// // // // // //                   keyboardType: TextInputType.number,
// // // // // //                   decoration: InputDecoration(
// // // // // //                     labelText: "المبلغ",
// // // // // //                     prefixText: "ج ",
// // // // // //                     prefixIcon: const Icon(
// // // // // //                       Icons.attach_money,
// // // // // //                       color: Colors.green,
// // // // // //                     ),
// // // // // //                     border: OutlineInputBorder(
// // // // // //                       borderRadius: BorderRadius.circular(8),
// // // // // //                     ),
// // // // // //                   ),
// // // // // //                 ),
// // // // // //                 const SizedBox(height: 16),

// // // // // //                 // القائمة المنسدلة ثالثاً
// // // // // //                 DropdownButtonFormField<String>(
// // // // // //                   value: selectedCategory,
// // // // // //                   decoration: InputDecoration(
// // // // // //                     labelText: "التصنيف",
// // // // // //                     prefixIcon: const Icon(
// // // // // //                       Icons.category,
// // // // // //                       color: Colors.purple,
// // // // // //                     ),
// // // // // //                     border: OutlineInputBorder(
// // // // // //                       borderRadius: BorderRadius.circular(8),
// // // // // //                     ),
// // // // // //                   ),
// // // // // //                   items: _categories.map((category) {
// // // // // //                     return DropdownMenuItem<String>(
// // // // // //                       value: category['name'],
// // // // // //                       child: Row(
// // // // // //                         children: [
// // // // // //                           Icon(
// // // // // //                             category['icon'],
// // // // // //                             color: category['color'],
// // // // // //                             size: 20,
// // // // // //                           ),
// // // // // //                           const SizedBox(width: 12),
// // // // // //                           Text(category['name']),
// // // // // //                         ],
// // // // // //                       ),
// // // // // //                     );
// // // // // //                   }).toList(),
// // // // // //                   onChanged: (value) {
// // // // // //                     if (value != null) {
// // // // // //                       setState(() {
// // // // // //                         selectedCategory = value;
// // // // // //                       });
// // // // // //                     }
// // // // // //                   },
// // // // // //                 ),
// // // // // //                 const SizedBox(height: 16),

// // // // // //                 // الملاحظات رابعاً
// // // // // //                 TextField(
// // // // // //                   controller: _noteController,
// // // // // //                   maxLines: 3,
// // // // // //                   decoration: InputDecoration(
// // // // // //                     labelText: "ملاحظات",
// // // // // //                     prefixIcon: const Icon(Icons.note, color: Colors.orange),
// // // // // //                     border: OutlineInputBorder(
// // // // // //                       borderRadius: BorderRadius.circular(8),
// // // // // //                     ),
// // // // // //                     hintText: "أضف ملاحظات حول المصروف...",
// // // // // //                   ),
// // // // // //                 ),
// // // // // //               ],
// // // // // //             ),
// // // // // //           ),
// // // // // //           actions: [
// // // // // //             TextButton(
// // // // // //               onPressed: () {
// // // // // //                 Navigator.pop(context);
// // // // // //                 _resetForm();
// // // // // //               },
// // // // // //               child: const Text("إلغاء"),
// // // // // //             ),
// // // // // //             ElevatedButton(
// // // // // //               onPressed: _isLoading
// // // // // //                   ? null
// // // // // //                   : () async {
// // // // // //                       if (_amountController.text.isEmpty) {
// // // // // //                         ScaffoldMessenger.of(context).showSnackBar(
// // // // // //                           const SnackBar(content: Text("الرجاء إدخال المبلغ")),
// // // // // //                         );
// // // // // //                         return;
// // // // // //                       }

// // // // // //                       setState(() {
// // // // // //                         _isLoading = true;
// // // // // //                       });

// // // // // //                       try {
// // // // // //                         final expenseData = {
// // // // // //                           "title": selectedCategory, // نستخدم التصنيف كعنوان
// // // // // //                           "amount": double.parse(_amountController.text),
// // // // // //                           "category": selectedCategory,
// // // // // //                           "note": _noteController.text,
// // // // // //                           "date": Timestamp.fromDate(selectedDate),
// // // // // //                           "updatedAt": Timestamp.now(),
// // // // // //                         };

// // // // // //                         if (docId == null) {
// // // // // //                           // إضافة جديد
// // // // // //                           expenseData["createdAt"] = Timestamp.now();
// // // // // //                           await _firestore
// // // // // //                               .collection("expenses")
// // // // // //                               .add(expenseData);

// // // // // //                           ScaffoldMessenger.of(context).showSnackBar(
// // // // // //                             const SnackBar(
// // // // // //                               content: Text("تم إضافة المصروف بنجاح"),
// // // // // //                               backgroundColor: Colors.green,
// // // // // //                             ),
// // // // // //                           );
// // // // // //                         } else {
// // // // // //                           // تحديث
// // // // // //                           await _firestore
// // // // // //                               .collection("expenses")
// // // // // //                               .doc(docId)
// // // // // //                               .update(expenseData);

// // // // // //                           ScaffoldMessenger.of(context).showSnackBar(
// // // // // //                             const SnackBar(
// // // // // //                               content: Text("تم تحديث المصروف بنجاح"),
// // // // // //                               backgroundColor: Colors.blue,
// // // // // //                             ),
// // // // // //                           );
// // // // // //                         }

// // // // // //                         Navigator.pop(context);
// // // // // //                         _resetForm();
// // // // // //                       } catch (e) {
// // // // // //                         ScaffoldMessenger.of(context).showSnackBar(
// // // // // //                           SnackBar(
// // // // // //                             content: Text("حدث خطأ: $e"),
// // // // // //                             backgroundColor: Colors.red,
// // // // // //                           ),
// // // // // //                         );
// // // // // //                       } finally {
// // // // // //                         setState(() {
// // // // // //                           _isLoading = false;
// // // // // //                         });
// // // // // //                       }
// // // // // //                     },
// // // // // //               child: _isLoading
// // // // // //                   ? const SizedBox(
// // // // // //                       width: 20,
// // // // // //                       height: 20,
// // // // // //                       child: CircularProgressIndicator(strokeWidth: 2),
// // // // // //                     )
// // // // // //                   : Text(docId == null ? "إضافة" : "تحديث"),
// // // // // //             ),
// // // // // //           ],
// // // // // //         );
// // // // // //       },
// // // // // //     );
// // // // // //   }

// // // // // //   // ================= حذف مصروف =================
// // // // // //   Future<void> _confirmDelete(String docId, String title) async {
// // // // // //     return showDialog(
// // // // // //       context: context,
// // // // // //       builder: (context) {
// // // // // //         return AlertDialog(
// // // // // //           title: const Text("تأكيد الحذف"),
// // // // // //           content: Text("هل أنت متأكد من حذف مصروف '$title'؟"),
// // // // // //           actions: [
// // // // // //             TextButton(
// // // // // //               onPressed: () => Navigator.pop(context),
// // // // // //               child: const Text("إلغاء"),
// // // // // //             ),
// // // // // //             ElevatedButton(
// // // // // //               onPressed: () async {
// // // // // //                 Navigator.pop(context);
// // // // // //                 try {
// // // // // //                   await _firestore.collection("expenses").doc(docId).delete();
// // // // // //                   ScaffoldMessenger.of(context).showSnackBar(
// // // // // //                     const SnackBar(
// // // // // //                       content: Text("تم حذف المصروف بنجاح"),
// // // // // //                       backgroundColor: Colors.red,
// // // // // //                     ),
// // // // // //                   );
// // // // // //                 } catch (e) {
// // // // // //                   ScaffoldMessenger.of(context).showSnackBar(
// // // // // //                     SnackBar(
// // // // // //                       content: Text("حدث خطأ أثناء الحذف: $e"),
// // // // // //                       backgroundColor: Colors.red,
// // // // // //                     ),
// // // // // //                   );
// // // // // //                 }
// // // // // //               },
// // // // // //               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
// // // // // //               child: const Text("حذف", style: TextStyle(color: Colors.white)),
// // // // // //             ),
// // // // // //           ],
// // // // // //         );
// // // // // //       },
// // // // // //     );
// // // // // //   }

// // // // // //   // ================= جزء الفلترة =================
// // // // // //   Widget _buildFilterSection() {
// // // // // //     return Container(
// // // // // //       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
// // // // // //       color: Colors.white,
// // // // // //       child: Column(
// // // // // //         children: [
// // // // // //           TextField(
// // // // // //             decoration: InputDecoration(
// // // // // //               hintText: 'ابحث بالمصروف',
// // // // // //               prefixIcon: const Icon(Icons.search, color: Color(0xFF3498DB)),
// // // // // //               border: OutlineInputBorder(
// // // // // //                 borderRadius: BorderRadius.circular(12),
// // // // // //               ),
// // // // // //               contentPadding: const EdgeInsets.symmetric(
// // // // // //                 vertical: 0,
// // // // // //                 horizontal: 12,
// // // // // //               ),
// // // // // //             ),
// // // // // //             onChanged: (value) {
// // // // // //               setState(() {
// // // // // //                 _searchQuery = value;
// // // // // //               });
// // // // // //             },
// // // // // //           ),
// // // // // //           const SizedBox(height: 12),
// // // // // //           SingleChildScrollView(
// // // // // //             scrollDirection: Axis.horizontal,
// // // // // //             child: Row(
// // // // // //               // children: ['الكل', 'اليوم', 'هذا الشهر', 'هذه السنة']
// // // // // //               //     .map(
// // // // // //               //       (filter) => Padding(
// // // // // //               //         padding: const EdgeInsets.symmetric(horizontal: 4),
// // // // // //               //         child: ChoiceChip(
// // // // // //               //           label: Text(filter),
// // // // // //               //           selected: _timeFilter == filter,
// // // // // //               //           onSelected: (selected) {
// // // // // //               //             if (selected) _changeTimeFilter(filter);
// // // // // //               //           },
// // // // // //               //           selectedColor: const Color(0xFF3498DB),
// // // // // //               //           labelStyle: TextStyle(
// // // // // //               //             color: _timeFilter == filter
// // // // // //               //                 ? Colors.white
// // // // // //               //                 : const Color(0xFF2C3E50),
// // // // // //               //           ),
// // // // // //               //         ),
// // // // // //               //       ),
// // // // // //               //     )
// // // // // //               //     .toList(),
// // // // // //             ),
// // // // // //           ),
// // // // // //           const SizedBox(height: 12),
// // // // // //           Row(
// // // // // //             mainAxisAlignment: MainAxisAlignment.center,
// // // // // //             children: [
// // // // // //               const Icon(Icons.calendar_month, color: Color(0xFF3498DB)),
// // // // // //               const SizedBox(width: 8),
// // // // // //               DropdownButton<int>(
// // // // // //                 value: _selectedMonth,
// // // // // //                 onChanged: (value) {
// // // // // //                   if (value != null) {
// // // // // //                     setState(() => _selectedMonth = value);
// // // // // //                     _applyMonthYearFilter();
// // // // // //                   }
// // // // // //                 },
// // // // // //                 items: List.generate(12, (index) {
// // // // // //                   final monthNumber = index + 1;
// // // // // //                   return DropdownMenuItem(
// // // // // //                     value: monthNumber,
// // // // // //                     child: Text('شهر $monthNumber'),
// // // // // //                   );
// // // // // //                 }),
// // // // // //               ),
// // // // // //               const SizedBox(width: 20),
// // // // // //               DropdownButton<int>(
// // // // // //                 value: _selectedYear,
// // // // // //                 onChanged: (value) {
// // // // // //                   if (value != null) {
// // // // // //                     setState(() => _selectedYear = value);
// // // // // //                     _applyMonthYearFilter();
// // // // // //                   }
// // // // // //                 },
// // // // // //                 items: [
// // // // // //                   for (
// // // // // //                     int i = DateTime.now().year - 2;
// // // // // //                     i <= DateTime.now().year + 2;
// // // // // //                     i++
// // // // // //                   )
// // // // // //                     DropdownMenuItem(value: i, child: Text('$i')),
// // // // // //                 ],
// // // // // //               ),
// // // // // //             ],
// // // // // //           ),
// // // // // //         ],
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   // ================= إحصائيات =================
// // // // // //   Widget _buildStats(List<QueryDocumentSnapshot> docs) {
// // // // // //     double total = 0;
// // // // // //     Map<String, double> categoryTotals = {};

// // // // // //     for (var doc in docs) {
// // // // // //       final data = doc.data() as Map<String, dynamic>;
// // // // // //       final amount = data['amount'] as double;
// // // // // //       final category = data['category'] as String;

// // // // // //       total += amount;
// // // // // //       categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
// // // // // //     }

// // // // // //     return Card(
// // // // // //       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// // // // // //       child: Padding(
// // // // // //         padding: const EdgeInsets.all(12),
// // // // // //         child: Column(
// // // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //           children: [
// // // // // //             const Text(
// // // // // //               "إحصائيات المصروفات",
// // // // // //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
// // // // // //             ),
// // // // // //             const SizedBox(height: 8),
// // // // // //             Row(
// // // // // //               children: [
// // // // // //                 Expanded(
// // // // // //                   child: Container(
// // // // // //                     padding: const EdgeInsets.all(12),
// // // // // //                     decoration: BoxDecoration(
// // // // // //                       color: Colors.blue.shade50,
// // // // // //                       borderRadius: BorderRadius.circular(8),
// // // // // //                     ),
// // // // // //                     child: Column(
// // // // // //                       children: [
// // // // // //                         const Text(
// // // // // //                           "المجموع الكلي",
// // // // // //                           style: TextStyle(fontSize: 12),
// // // // // //                         ),
// // // // // //                         const SizedBox(height: 4),
// // // // // //                         Text(
// // // // // //                           "${total.toStringAsFixed(2)} ج",
// // // // // //                           style: const TextStyle(
// // // // // //                             fontWeight: FontWeight.bold,
// // // // // //                             fontSize: 16,
// // // // // //                             color: Colors.blue,
// // // // // //                           ),
// // // // // //                         ),
// // // // // //                       ],
// // // // // //                     ),
// // // // // //                   ),
// // // // // //                 ),
// // // // // //                 const SizedBox(width: 8),
// // // // // //                 Expanded(
// // // // // //                   child: Container(
// // // // // //                     padding: const EdgeInsets.all(12),
// // // // // //                     decoration: BoxDecoration(
// // // // // //                       color: Colors.green.shade50,
// // // // // //                       borderRadius: BorderRadius.circular(8),
// // // // // //                     ),
// // // // // //                     child: Column(
// // // // // //                       children: [
// // // // // //                         const Text(
// // // // // //                           "عدد المصروفات",
// // // // // //                           style: TextStyle(fontSize: 12),
// // // // // //                         ),
// // // // // //                         const SizedBox(height: 4),
// // // // // //                         Text(
// // // // // //                           "${docs.length}",
// // // // // //                           style: const TextStyle(
// // // // // //                             fontWeight: FontWeight.bold,
// // // // // //                             fontSize: 16,
// // // // // //                             color: Colors.green,
// // // // // //                           ),
// // // // // //                         ),
// // // // // //                       ],
// // // // // //                     ),
// // // // // //                   ),
// // // // // //                 ),
// // // // // //               ],
// // // // // //             ),
// // // // // //           ],
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   // ================= إعادة تعيين النموذج =================
// // // // // //   void _resetForm() {
// // // // // //     _titleController.clear();
// // // // // //     _amountController.clear();
// // // // // //     _noteController.clear();
// // // // // //     selectedCategory = "نثريات";
// // // // // //     selectedDate = DateTime.now();
// // // // // //     _editingDocId = null;
// // // // // //   }

// // // // // //   @override
// // // // // //   void dispose() {
// // // // // //     _titleController.dispose();
// // // // // //     _amountController.dispose();
// // // // // //     _noteController.dispose();
// // // // // //     super.dispose();
// // // // // //   }

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return Scaffold(
// // // // // //       appBar: AppBar(
// // // // // //         title: const Text("المصروفات والنثريات"),
// // // // // //         centerTitle: true,
// // // // // //         backgroundColor: const Color(0xFF1B4F72),
// // // // // //       ),
// // // // // //       body: Column(
// // // // // //         children: [
// // // // // //           _buildFilterSection(),
// // // // // //           Expanded(
// // // // // //             child: StreamBuilder<QuerySnapshot>(
// // // // // //               stream: _firestore
// // // // // //                   .collection("expenses")
// // // // // //                   .orderBy('date', descending: true)
// // // // // //                   .snapshots(),
// // // // // //               builder: (context, snapshot) {
// // // // // //                 if (!snapshot.hasData) {
// // // // // //                   return const Center(child: CircularProgressIndicator());
// // // // // //                 }

// // // // // //                 // تطبيق الفلترة
// // // // // //                 List<QueryDocumentSnapshot> allDocs = snapshot.data!.docs;
// // // // // //                 List<QueryDocumentSnapshot> dateFilteredDocs =
// // // // // //                     _filterExpensesByDate(allDocs);

// // // // // //                 // تطبيق البحث
// // // // // //                 List<QueryDocumentSnapshot> filteredDocs = dateFilteredDocs
// // // // // //                     .where((doc) {
// // // // // //                       final data = doc.data() as Map<String, dynamic>;
// // // // // //                       final title =
// // // // // //                           data['title']?.toString().toLowerCase() ?? '';
// // // // // //                       final category =
// // // // // //                           data['category']?.toString().toLowerCase() ?? '';
// // // // // //                       final note = data['note']?.toString().toLowerCase() ?? '';
// // // // // //                       final query = _searchQuery.toLowerCase();

// // // // // //                       return title.contains(query) ||
// // // // // //                           category.contains(query) ||
// // // // // //                           note.contains(query) ||
// // // // // //                           query.isEmpty;
// // // // // //                     })
// // // // // //                     .toList();

// // // // // //                 if (snapshot.data!.docs.isEmpty) {
// // // // // //                   return Center(
// // // // // //                     child: Column(
// // // // // //                       mainAxisAlignment: MainAxisAlignment.center,
// // // // // //                       children: [
// // // // // //                         const Icon(
// // // // // //                           Icons.receipt_long,
// // // // // //                           size: 80,
// // // // // //                           color: Colors.grey,
// // // // // //                         ),
// // // // // //                         const SizedBox(height: 16),
// // // // // //                         const Text(
// // // // // //                           "لا توجد مصروفات",
// // // // // //                           style: TextStyle(fontSize: 18, color: Colors.grey),
// // // // // //                         ),
// // // // // //                         const SizedBox(height: 8),
// // // // // //                         Text(
// // // // // //                           "انقر على زر + لإضافة أول مصروف",
// // // // // //                           style: TextStyle(
// // // // // //                             fontSize: 14,
// // // // // //                             color: Colors.grey.shade600,
// // // // // //                           ),
// // // // // //                         ),
// // // // // //                       ],
// // // // // //                     ),
// // // // // //                   );
// // // // // //                 }

// // // // // //                 return Column(
// // // // // //                   children: [
// // // // // //                     _buildStats(filteredDocs),
// // // // // //                     Expanded(
// // // // // //                       child: ListView.builder(
// // // // // //                         itemCount: filteredDocs.length,
// // // // // //                         itemBuilder: (context, index) {
// // // // // //                           final doc = filteredDocs[index];
// // // // // //                           final data = doc.data() as Map<String, dynamic>;
// // // // // //                           final docId = doc.id;
// // // // // //                           final date = (data['date'] as Timestamp).toDate();
// // // // // //                           final category = _categories.firstWhere(
// // // // // //                             (cat) => cat['name'] == data['category'],
// // // // // //                             orElse: () => _categories.last,
// // // // // //                           );

// // // // // //                           return Card(
// // // // // //                             margin: const EdgeInsets.symmetric(
// // // // // //                               horizontal: 8,
// // // // // //                               vertical: 4,
// // // // // //                             ),
// // // // // //                             child: ListTile(
// // // // // //                               leading: CircleAvatar(
// // // // // //                                 backgroundColor: category['color'].withOpacity(
// // // // // //                                   0.1,
// // // // // //                                 ),
// // // // // //                                 child: Icon(
// // // // // //                                   category['icon'],
// // // // // //                                   color: category['color'],
// // // // // //                                   size: 20,
// // // // // //                                 ),
// // // // // //                               ),
// // // // // //                               title: Text(
// // // // // //                                 "${data['amount'].toStringAsFixed(2)} ج",
// // // // // //                                 style: const TextStyle(
// // // // // //                                   fontWeight: FontWeight.bold,
// // // // // //                                   fontSize: 18,
// // // // // //                                   color: Colors.blue,
// // // // // //                                 ),
// // // // // //                               ),
// // // // // //                               subtitle: Column(
// // // // // //                                 crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //                                 children: [
// // // // // //                                   const SizedBox(height: 4),
// // // // // //                                   Text(
// // // // // //                                     data['category'],
// // // // // //                                     style: TextStyle(
// // // // // //                                       fontSize: 14,
// // // // // //                                       color: category['color'],
// // // // // //                                       fontWeight: FontWeight.bold,
// // // // // //                                     ),
// // // // // //                                   ),
// // // // // //                                   const SizedBox(height: 2),
// // // // // //                                   Text(
// // // // // //                                     DateFormat('yyyy/MM/dd').format(date),
// // // // // //                                     style: const TextStyle(fontSize: 12),
// // // // // //                                   ),
// // // // // //                                   if (data['note'] != null &&
// // // // // //                                       data['note'].isNotEmpty)
// // // // // //                                     Padding(
// // // // // //                                       padding: const EdgeInsets.only(top: 4),
// // // // // //                                       child: Text(
// // // // // //                                         data['note'],
// // // // // //                                         style: TextStyle(
// // // // // //                                           fontSize: 12,
// // // // // //                                           color: Colors.grey.shade600,
// // // // // //                                         ),
// // // // // //                                       ),
// // // // // //                                     ),
// // // // // //                                 ],
// // // // // //                               ),
// // // // // //                               trailing: PopupMenuButton<String>(
// // // // // //                                 icon: const Icon(Icons.more_vert),
// // // // // //                                 onSelected: (value) async {
// // // // // //                                   if (value == 'edit') {
// // // // // //                                     await _openExpenseSheet(
// // // // // //                                       docId: docId,
// // // // // //                                       data: data,
// // // // // //                                     );
// // // // // //                                   } else if (value == 'delete') {
// // // // // //                                     await _confirmDelete(docId, data['title']);
// // // // // //                                   }
// // // // // //                                 },
// // // // // //                                 itemBuilder: (BuildContext context) {
// // // // // //                                   return [
// // // // // //                                     const PopupMenuItem<String>(
// // // // // //                                       value: 'edit',
// // // // // //                                       child: Row(
// // // // // //                                         children: [
// // // // // //                                           Icon(Icons.edit, size: 20),
// // // // // //                                           SizedBox(width: 8),
// // // // // //                                           Text('تعديل'),
// // // // // //                                         ],
// // // // // //                                       ),
// // // // // //                                     ),
// // // // // //                                     const PopupMenuItem<String>(
// // // // // //                                       value: 'delete',
// // // // // //                                       child: Row(
// // // // // //                                         children: [
// // // // // //                                           Icon(
// // // // // //                                             Icons.delete,
// // // // // //                                             color: Colors.red,
// // // // // //                                             size: 20,
// // // // // //                                           ),
// // // // // //                                           SizedBox(width: 8),
// // // // // //                                           Text(
// // // // // //                                             'حذف',
// // // // // //                                             style: TextStyle(color: Colors.red),
// // // // // //                                           ),
// // // // // //                                         ],
// // // // // //                                       ),
// // // // // //                                     ),
// // // // // //                                   ];
// // // // // //                                 },
// // // // // //                               ),
// // // // // //                             ),
// // // // // //                           );
// // // // // //                         },
// // // // // //                       ),
// // // // // //                     ),
// // // // // //                   ],
// // // // // //                 );
// // // // // //               },
// // // // // //             ),
// // // // // //           ),
// // // // // //         ],
// // // // // //       ),
// // // // // //       floatingActionButton: FloatingActionButton.extended(
// // // // // //         onPressed: () => _openExpenseSheet(),
// // // // // //         icon: const Icon(Icons.add),
// // // // // //         label: const Text("إضافة مصروف"),
// // // // // //         backgroundColor: const Color(0xFF3498DB),
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }
// // // // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:intl/intl.dart';

// // // // // class ExpensesPage extends StatefulWidget {
// // // // //   const ExpensesPage({super.key});

// // // // //   @override
// // // // //   State<ExpensesPage> createState() => _ExpensesPageState();
// // // // // }

// // // // // class _ExpensesPageState extends State<ExpensesPage> {
// // // // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// // // // //   final TextEditingController _titleController = TextEditingController();
// // // // //   final TextEditingController _amountController = TextEditingController();
// // // // //   final TextEditingController _noteController = TextEditingController();

// // // // //   String selectedCategory = "نثريات";
// // // // //   DateTime selectedDate = DateTime.now();
// // // // //   bool _isLoading = false;
// // // // //   String? _editingDocId;

// // // // //   // التصنيفات مع ألوان وأيقونات
// // // // //   final List<Map<String, dynamic>> _categories = [
// // // // //     {"name": "نثريات", "color": Colors.purple, "icon": Icons.category},
// // // // //     {"name": "تشغيل", "color": Colors.blue, "icon": Icons.business},
// // // // //     {"name": "مواصلات", "color": Colors.green, "icon": Icons.directions_car},
// // // // //     {"name": "أدوات", "color": Colors.orange, "icon": Icons.build},
// // // // //     {"name": "طعام", "color": Colors.red, "icon": Icons.restaurant},
// // // // //     {"name": "صحة", "color": Colors.teal, "icon": Icons.medical_services},
// // // // //     {"name": "أخرى", "color": Colors.grey, "icon": Icons.more_horiz},
// // // // //   ];

// // // // //   // ================= فلترة مشابهة لشغل السائقين =================
// // // // //   int _selectedMonth = DateTime.now().month;
// // // // //   int _selectedYear = DateTime.now().year;
// // // // //   String _timeFilter = 'الكل';

// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     _resetForm();
// // // // //   }

// // // // //   // ================= فلترة حسب التاريخ =================
// // // // //   List<QueryDocumentSnapshot> _filterExpensesByDate(
// // // // //     List<QueryDocumentSnapshot> allDocs,
// // // // //   ) {
// // // // //     return allDocs.where((doc) {
// // // // //       final data = doc.data() as Map<String, dynamic>;
// // // // //       final date = (data['date'] as Timestamp).toDate();

// // // // //       if (_timeFilter == 'الكل') return true;

// // // // //       final now = DateTime.now();
// // // // //       switch (_timeFilter) {
// // // // //         case 'اليوم':
// // // // //           return date.year == now.year &&
// // // // //               date.month == now.month &&
// // // // //               date.day == now.day;
// // // // //         case 'هذا الشهر':
// // // // //           return date.year == now.year && date.month == now.month;
// // // // //         case 'هذه السنة':
// // // // //           return date.year == now.year;
// // // // //         case 'مخصص':
// // // // //           return date.year == _selectedYear && date.month == _selectedMonth;
// // // // //         default:
// // // // //           return true;
// // // // //       }
// // // // //     }).toList();
// // // // //   }

// // // // //   void _changeTimeFilter(String filter) {
// // // // //     setState(() => _timeFilter = filter);
// // // // //     _applyFilters();
// // // // //   }

// // // // //   void _applyMonthYearFilter() {
// // // // //     setState(() => _timeFilter = 'مخصص');
// // // // //     _applyFilters();
// // // // //   }

// // // // //   void _applyFilters() {
// // // // //     setState(() {});
// // // // //   }

// // // // //   // ================= AppBar مخصص مثل صفحة السائقين =================
// // // // //   Widget _buildCustomAppBar() {
// // // // //     return Container(
// // // // //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// // // // //       decoration: const BoxDecoration(
// // // // //         gradient: LinearGradient(
// // // // //           begin: Alignment.centerRight,
// // // // //           end: Alignment.centerLeft,
// // // // //           colors: [Color(0xFF1B4F72), Color(0xFF3498DB)],
// // // // //         ),
// // // // //         boxShadow: [
// // // // //           BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
// // // // //         ],
// // // // //       ),
// // // // //       child: SafeArea(
// // // // //         bottom: false,
// // // // //         child: Row(
// // // // //           children: [
// // // // //             const Icon(Icons.attach_money, color: Colors.white, size: 28),
// // // // //             const SizedBox(width: 12),
// // // // //             const Text(
// // // // //               ' النثريات',
// // // // //               style: TextStyle(
// // // // //                 color: Colors.white,
// // // // //                 fontSize: 20,
// // // // //                 fontWeight: FontWeight.bold,
// // // // //               ),
// // // // //             ),
// // // // //             const Spacer(),
// // // // //             StreamBuilder<DateTime>(
// // // // //               stream: Stream.periodic(
// // // // //                 const Duration(seconds: 1),
// // // // //                 (_) => DateTime.now(),
// // // // //               ),
// // // // //               builder: (context, snapshot) {
// // // // //                 final now = snapshot.data ?? DateTime.now();
// // // // //                 int hour12 = now.hour % 12;
// // // // //                 if (hour12 == 0) hour12 = 12;
// // // // //                 String period = now.hour < 12 ? 'AM' : 'PM';

// // // // //                 return Column(
// // // // //                   crossAxisAlignment: CrossAxisAlignment.center,
// // // // //                   children: [
// // // // //                     Container(
// // // // //                       height: 50,
// // // // //                       width: 150,
// // // // //                       decoration: BoxDecoration(
// // // // //                         color: Colors.transparent,
// // // // //                         borderRadius: BorderRadius.circular(16),
// // // // //                       ),
// // // // //                       child: Center(
// // // // //                         child: Text(
// // // // //                           '${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period',
// // // // //                           style: const TextStyle(
// // // // //                             color: Colors.white,
// // // // //                             fontSize: 36,
// // // // //                             fontWeight: FontWeight.bold,
// // // // //                           ),
// // // // //                         ),
// // // // //                       ),
// // // // //                     ),
// // // // //                   ],
// // // // //                 );
// // // // //               },
// // // // //             ),
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   // ================= إضافة/تعديل مصروف =================
// // // // //   Future<void> _openExpenseSheet({
// // // // //     String? docId,
// // // // //     Map<String, dynamic>? data,
// // // // //   }) async {
// // // // //     _editingDocId = docId;

// // // // //     if (data != null) {
// // // // //       // وضع التعديل
// // // // //       _titleController.text = data['title'];
// // // // //       _amountController.text = data['amount'].toString();
// // // // //       _noteController.text = data['note'] ?? '';
// // // // //       selectedCategory = data['category'];
// // // // //       selectedDate = (data['date'] as Timestamp).toDate();
// // // // //     } else {
// // // // //       // وضع الإضافة
// // // // //       _titleController.clear();
// // // // //       _amountController.clear();
// // // // //       _noteController.clear();
// // // // //       selectedCategory = "نثريات";
// // // // //       selectedDate = DateTime.now();
// // // // //     }

// // // // //     await showDialog(
// // // // //       context: context,
// // // // //       builder: (context) {
// // // // //         return AlertDialog(
// // // // //           title: Text(
// // // // //             docId == null ? "إضافة مصروف جديد" : "تعديل المصروف",
// // // // //             style: const TextStyle(fontWeight: FontWeight.bold),
// // // // //           ),
// // // // //           content: SingleChildScrollView(
// // // // //             child: Column(
// // // // //               mainAxisSize: MainAxisSize.min,
// // // // //               children: [
// // // // //                 // التاريخ أولاً
// // // // //                 Container(
// // // // //                   padding: const EdgeInsets.all(12),
// // // // //                   decoration: BoxDecoration(
// // // // //                     border: Border.all(color: Colors.grey.shade300),
// // // // //                     borderRadius: BorderRadius.circular(8),
// // // // //                   ),
// // // // //                   child: Row(
// // // // //                     children: [
// // // // //                       const Icon(
// // // // //                         Icons.calendar_today,
// // // // //                         size: 20,
// // // // //                         color: Colors.blue,
// // // // //                       ),
// // // // //                       const SizedBox(width: 12),
// // // // //                       Expanded(
// // // // //                         child: Column(
// // // // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                           children: [
// // // // //                             const Text(
// // // // //                               "التاريخ",
// // // // //                               style: TextStyle(
// // // // //                                 fontSize: 12,
// // // // //                                 color: Colors.grey,
// // // // //                               ),
// // // // //                             ),
// // // // //                             Text(
// // // // //                               DateFormat('yyyy/MM/dd').format(selectedDate),
// // // // //                               style: const TextStyle(
// // // // //                                 fontWeight: FontWeight.bold,
// // // // //                                 fontSize: 16,
// // // // //                               ),
// // // // //                             ),
// // // // //                           ],
// // // // //                         ),
// // // // //                       ),
// // // // //                       IconButton(
// // // // //                         onPressed: () async {
// // // // //                           final DateTime? picked = await showDatePicker(
// // // // //                             context: context,
// // // // //                             initialDate: selectedDate,
// // // // //                             firstDate: DateTime(2000),
// // // // //                             lastDate: DateTime(2100),
// // // // //                           );
// // // // //                           if (picked != null) {
// // // // //                             setState(() {
// // // // //                               selectedDate = picked;
// // // // //                             });
// // // // //                           }
// // // // //                         },
// // // // //                         icon: const Icon(Icons.edit, size: 20),
// // // // //                         style: IconButton.styleFrom(
// // // // //                           backgroundColor: Colors.blue.shade50,
// // // // //                         ),
// // // // //                       ),
// // // // //                     ],
// // // // //                   ),
// // // // //                 ),
// // // // //                 const SizedBox(height: 16),

// // // // //                 // المبلغ ثانياً
// // // // //                 TextField(
// // // // //                   controller: _amountController,
// // // // //                   keyboardType: TextInputType.number,
// // // // //                   decoration: InputDecoration(
// // // // //                     labelText: "المبلغ",
// // // // //                     prefixText: "ج ",
// // // // //                     prefixIcon: const Icon(
// // // // //                       Icons.attach_money,
// // // // //                       color: Colors.green,
// // // // //                     ),
// // // // //                     border: OutlineInputBorder(
// // // // //                       borderRadius: BorderRadius.circular(8),
// // // // //                     ),
// // // // //                   ),
// // // // //                 ),
// // // // //                 const SizedBox(height: 16),

// // // // //                 // القائمة المنسدلة ثالثاً
// // // // //                 DropdownButtonFormField<String>(
// // // // //                   value: selectedCategory,
// // // // //                   decoration: InputDecoration(
// // // // //                     labelText: "التصنيف",
// // // // //                     prefixIcon: const Icon(
// // // // //                       Icons.category,
// // // // //                       color: Colors.purple,
// // // // //                     ),
// // // // //                     border: OutlineInputBorder(
// // // // //                       borderRadius: BorderRadius.circular(8),
// // // // //                     ),
// // // // //                   ),
// // // // //                   items: _categories.map((category) {
// // // // //                     return DropdownMenuItem<String>(
// // // // //                       value: category['name'],
// // // // //                       child: Row(
// // // // //                         children: [
// // // // //                           Icon(
// // // // //                             category['icon'],
// // // // //                             color: category['color'],
// // // // //                             size: 20,
// // // // //                           ),
// // // // //                           const SizedBox(width: 12),
// // // // //                           Text(category['name']),
// // // // //                         ],
// // // // //                       ),
// // // // //                     );
// // // // //                   }).toList(),
// // // // //                   onChanged: (value) {
// // // // //                     if (value != null) {
// // // // //                       setState(() {
// // // // //                         selectedCategory = value;
// // // // //                       });
// // // // //                     }
// // // // //                   },
// // // // //                 ),
// // // // //                 const SizedBox(height: 16),

// // // // //                 // الملاحظات رابعاً
// // // // //                 TextField(
// // // // //                   controller: _noteController,
// // // // //                   maxLines: 3,
// // // // //                   decoration: InputDecoration(
// // // // //                     labelText: "ملاحظات",
// // // // //                     prefixIcon: const Icon(Icons.note, color: Colors.orange),
// // // // //                     border: OutlineInputBorder(
// // // // //                       borderRadius: BorderRadius.circular(8),
// // // // //                     ),
// // // // //                     hintText: "أضف ملاحظات حول المصروف...",
// // // // //                   ),
// // // // //                 ),
// // // // //               ],
// // // // //             ),
// // // // //           ),
// // // // //           actions: [
// // // // //             TextButton(
// // // // //               onPressed: () {
// // // // //                 Navigator.pop(context);
// // // // //                 _resetForm();
// // // // //               },
// // // // //               child: const Text("إلغاء"),
// // // // //             ),
// // // // //             ElevatedButton(
// // // // //               onPressed: _isLoading
// // // // //                   ? null
// // // // //                   : () async {
// // // // //                       if (_amountController.text.isEmpty) {
// // // // //                         ScaffoldMessenger.of(context).showSnackBar(
// // // // //                           const SnackBar(content: Text("الرجاء إدخال المبلغ")),
// // // // //                         );
// // // // //                         return;
// // // // //                       }

// // // // //                       setState(() {
// // // // //                         _isLoading = true;
// // // // //                       });

// // // // //                       try {
// // // // //                         final expenseData = {
// // // // //                           "title": selectedCategory, // نستخدم التصنيف كعنوان
// // // // //                           "amount": double.parse(_amountController.text),
// // // // //                           "category": selectedCategory,
// // // // //                           "note": _noteController.text,
// // // // //                           "date": Timestamp.fromDate(selectedDate),
// // // // //                           "updatedAt": Timestamp.now(),
// // // // //                         };

// // // // //                         if (docId == null) {
// // // // //                           // إضافة جديد
// // // // //                           expenseData["createdAt"] = Timestamp.now();
// // // // //                           await _firestore
// // // // //                               .collection("expenses")
// // // // //                               .add(expenseData);

// // // // //                           ScaffoldMessenger.of(context).showSnackBar(
// // // // //                             const SnackBar(
// // // // //                               content: Text("تم إضافة المصروف بنجاح"),
// // // // //                               backgroundColor: Colors.green,
// // // // //                             ),
// // // // //                           );
// // // // //                         } else {
// // // // //                           // تحديث
// // // // //                           await _firestore
// // // // //                               .collection("expenses")
// // // // //                               .doc(docId)
// // // // //                               .update(expenseData);

// // // // //                           ScaffoldMessenger.of(context).showSnackBar(
// // // // //                             const SnackBar(
// // // // //                               content: Text("تم تحديث المصروف بنجاح"),
// // // // //                               backgroundColor: Colors.blue,
// // // // //                             ),
// // // // //                           );
// // // // //                         }

// // // // //                         Navigator.pop(context);
// // // // //                         _resetForm();
// // // // //                       } catch (e) {
// // // // //                         ScaffoldMessenger.of(context).showSnackBar(
// // // // //                           SnackBar(
// // // // //                             content: Text("حدث خطأ: $e"),
// // // // //                             backgroundColor: Colors.red,
// // // // //                           ),
// // // // //                         );
// // // // //                       } finally {
// // // // //                         setState(() {
// // // // //                           _isLoading = false;
// // // // //                         });
// // // // //                       }
// // // // //                     },
// // // // //               child: _isLoading
// // // // //                   ? const SizedBox(
// // // // //                       width: 20,
// // // // //                       height: 20,
// // // // //                       child: CircularProgressIndicator(strokeWidth: 2),
// // // // //                     )
// // // // //                   : Text(docId == null ? "إضافة" : "تحديث"),
// // // // //             ),
// // // // //           ],
// // // // //         );
// // // // //       },
// // // // //     );
// // // // //   }

// // // // //   // ================= حذف مصروف =================
// // // // //   Future<void> _confirmDelete(String docId, String title) async {
// // // // //     return showDialog(
// // // // //       context: context,
// // // // //       builder: (context) {
// // // // //         return AlertDialog(
// // // // //           title: const Text("تأكيد الحذف"),
// // // // //           content: Text("هل أنت متأكد من حذف مصروف '$title'؟"),
// // // // //           actions: [
// // // // //             TextButton(
// // // // //               onPressed: () => Navigator.pop(context),
// // // // //               child: const Text("إلغاء"),
// // // // //             ),
// // // // //             ElevatedButton(
// // // // //               onPressed: () async {
// // // // //                 Navigator.pop(context);
// // // // //                 try {
// // // // //                   await _firestore.collection("expenses").doc(docId).delete();
// // // // //                   ScaffoldMessenger.of(context).showSnackBar(
// // // // //                     const SnackBar(
// // // // //                       content: Text("تم حذف المصروف بنجاح"),
// // // // //                       backgroundColor: Colors.red,
// // // // //                     ),
// // // // //                   );
// // // // //                 } catch (e) {
// // // // //                   ScaffoldMessenger.of(context).showSnackBar(
// // // // //                     SnackBar(
// // // // //                       content: Text("حدث خطأ أثناء الحذف: $e"),
// // // // //                       backgroundColor: Colors.red,
// // // // //                     ),
// // // // //                   );
// // // // //                 }
// // // // //               },
// // // // //               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
// // // // //               child: const Text("حذف", style: TextStyle(color: Colors.white)),
// // // // //             ),
// // // // //           ],
// // // // //         );
// // // // //       },
// // // // //     );
// // // // //   }

// // // // //   // ================= جزء الفلترة =================
// // // // //   Widget _buildTimeFilterSection() {
// // // // //     return Container(
// // // // //       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
// // // // //       color: Colors.white,
// // // // //       child: Column(
// // // // //         children: [
// // // // //           SingleChildScrollView(
// // // // //             scrollDirection: Axis.horizontal,
// // // // //             child: Row(
// // // // //               // children: ['الكل', 'اليوم', 'هذا الشهر', 'هذه السنة']
// // // // //               //     .map(
// // // // //               //       (filter) => Padding(
// // // // //               //         padding: const EdgeInsets.symmetric(horizontal: 4),
// // // // //               //         child: ChoiceChip(
// // // // //               //           label: Text(filter),
// // // // //               //           selected: _timeFilter == filter,
// // // // //               //           onSelected: (selected) {
// // // // //               //             if (selected) _changeTimeFilter(filter);
// // // // //               //           },
// // // // //               //           selectedColor: const Color(0xFF3498DB),
// // // // //               //           labelStyle: TextStyle(
// // // // //               //             color: _timeFilter == filter
// // // // //               //                 ? Colors.white
// // // // //               //                 : const Color(0xFF2C3E50),
// // // // //               //           ),
// // // // //               //         ),
// // // // //               //       ),
// // // // //               //     )
// // // // //               //     .toList(),
// // // // //             ),
// // // // //           ),
// // // // //           const SizedBox(height: 12),
// // // // //           Row(
// // // // //             mainAxisAlignment: MainAxisAlignment.center,
// // // // //             children: [
// // // // //               const Icon(Icons.calendar_month, color: Color(0xFF3498DB)),
// // // // //               const SizedBox(width: 8),
// // // // //               DropdownButton<int>(
// // // // //                 value: _selectedMonth,
// // // // //                 onChanged: (value) {
// // // // //                   if (value != null) {
// // // // //                     setState(() => _selectedMonth = value);
// // // // //                     _applyMonthYearFilter();
// // // // //                   }
// // // // //                 },
// // // // //                 items: List.generate(12, (index) {
// // // // //                   final monthNumber = index + 1;
// // // // //                   return DropdownMenuItem(
// // // // //                     value: monthNumber,
// // // // //                     child: Text('شهر $monthNumber'),
// // // // //                   );
// // // // //                 }),
// // // // //               ),
// // // // //               const SizedBox(width: 20),
// // // // //               DropdownButton<int>(
// // // // //                 value: _selectedYear,
// // // // //                 onChanged: (value) {
// // // // //                   if (value != null) {
// // // // //                     setState(() => _selectedYear = value);
// // // // //                     _applyMonthYearFilter();
// // // // //                   }
// // // // //                 },
// // // // //                 items: [
// // // // //                   for (
// // // // //                     int i = DateTime.now().year - 2;
// // // // //                     i <= DateTime.now().year + 2;
// // // // //                     i++
// // // // //                   )
// // // // //                     DropdownMenuItem(value: i, child: Text('$i')),
// // // // //                 ],
// // // // //               ),
// // // // //             ],
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   // ================= إحصائيات =================
// // // // //   Widget _buildStats(List<QueryDocumentSnapshot> docs) {
// // // // //     double total = 0;
// // // // //     Map<String, double> categoryTotals = {};

// // // // //     for (var doc in docs) {
// // // // //       final data = doc.data() as Map<String, dynamic>;
// // // // //       final amount = data['amount'] as double;
// // // // //       final category = data['category'] as String;

// // // // //       total += amount;
// // // // //       categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
// // // // //     }

// // // // //     return Card(
// // // // //       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// // // // //       child: Padding(
// // // // //         padding: const EdgeInsets.all(12),
// // // // //         child: Column(
// // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // //           children: [
// // // // //             const Text(
// // // // //               "إحصائيات المصروفات",
// // // // //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
// // // // //             ),
// // // // //             const SizedBox(height: 8),
// // // // //             Row(
// // // // //               children: [
// // // // //                 Expanded(
// // // // //                   child: Container(
// // // // //                     padding: const EdgeInsets.all(12),
// // // // //                     decoration: BoxDecoration(
// // // // //                       color: Colors.blue.shade50,
// // // // //                       borderRadius: BorderRadius.circular(8),
// // // // //                     ),
// // // // //                     child: Column(
// // // // //                       children: [
// // // // //                         const Text(
// // // // //                           "المجموع الكلي",
// // // // //                           style: TextStyle(fontSize: 12),
// // // // //                         ),
// // // // //                         const SizedBox(height: 4),
// // // // //                         Text(
// // // // //                           "${total.toStringAsFixed(2)} ج",
// // // // //                           style: const TextStyle(
// // // // //                             fontWeight: FontWeight.bold,
// // // // //                             fontSize: 16,
// // // // //                             color: Colors.blue,
// // // // //                           ),
// // // // //                         ),
// // // // //                       ],
// // // // //                     ),
// // // // //                   ),
// // // // //                 ),
// // // // //                 const SizedBox(width: 8),
// // // // //                 Expanded(
// // // // //                   child: Container(
// // // // //                     padding: const EdgeInsets.all(12),
// // // // //                     decoration: BoxDecoration(
// // // // //                       color: Colors.green.shade50,
// // // // //                       borderRadius: BorderRadius.circular(8),
// // // // //                     ),
// // // // //                     child: Column(
// // // // //                       children: [
// // // // //                         const Text(
// // // // //                           "عدد المصروفات",
// // // // //                           style: TextStyle(fontSize: 12),
// // // // //                         ),
// // // // //                         const SizedBox(height: 4),
// // // // //                         Text(
// // // // //                           "${docs.length}",
// // // // //                           style: const TextStyle(
// // // // //                             fontWeight: FontWeight.bold,
// // // // //                             fontSize: 16,
// // // // //                             color: Colors.green,
// // // // //                           ),
// // // // //                         ),
// // // // //                       ],
// // // // //                     ),
// // // // //                   ),
// // // // //                 ),
// // // // //               ],
// // // // //             ),
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   // ================= إعادة تعيين النموذج =================
// // // // //   void _resetForm() {
// // // // //     _titleController.clear();
// // // // //     _amountController.clear();
// // // // //     _noteController.clear();
// // // // //     selectedCategory = "نثريات";
// // // // //     selectedDate = DateTime.now();
// // // // //     _editingDocId = null;
// // // // //   }

// // // // //   @override
// // // // //   void dispose() {
// // // // //     _titleController.dispose();
// // // // //     _amountController.dispose();
// // // // //     _noteController.dispose();
// // // // //     super.dispose();
// // // // //   }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Scaffold(
// // // // //       backgroundColor: const Color(0xFFF4F6F8),
// // // // //       body: Column(
// // // // //         children: [
// // // // //           // AppBar مخصص مثل صفحة السائقين
// // // // //           _buildCustomAppBar(),

// // // // //           // جزء الفلترة
// // // // //           _buildTimeFilterSection(),

// // // // //           // المحتوى الرئيسي
// // // // //           Expanded(
// // // // //             child: StreamBuilder<QuerySnapshot>(
// // // // //               stream: _firestore
// // // // //                   .collection("expenses")
// // // // //                   .orderBy('date', descending: true)
// // // // //                   .snapshots(),
// // // // //               builder: (context, snapshot) {
// // // // //                 if (!snapshot.hasData) {
// // // // //                   return const Center(child: CircularProgressIndicator());
// // // // //                 }

// // // // //                 // تطبيق الفلترة حسب التاريخ
// // // // //                 List<QueryDocumentSnapshot> allDocs = snapshot.data!.docs;
// // // // //                 List<QueryDocumentSnapshot> filteredDocs =
// // // // //                     _filterExpensesByDate(allDocs);

// // // // //                 if (snapshot.data!.docs.isEmpty) {
// // // // //                   return Center(
// // // // //                     child: Column(
// // // // //                       mainAxisAlignment: MainAxisAlignment.center,
// // // // //                       children: [
// // // // //                         const Icon(
// // // // //                           Icons.receipt_long,
// // // // //                           size: 80,
// // // // //                           color: Colors.grey,
// // // // //                         ),
// // // // //                         const SizedBox(height: 16),
// // // // //                         const Text(
// // // // //                           "لا توجد مصروفات",
// // // // //                           style: TextStyle(fontSize: 18, color: Colors.grey),
// // // // //                         ),
// // // // //                         const SizedBox(height: 8),
// // // // //                         Text(
// // // // //                           "انقر على زر + لإضافة أول مصروف",
// // // // //                           style: TextStyle(
// // // // //                             fontSize: 14,
// // // // //                             color: Colors.grey.shade600,
// // // // //                           ),
// // // // //                         ),
// // // // //                       ],
// // // // //                     ),
// // // // //                   );
// // // // //                 }

// // // // //                 return Column(
// // // // //                   children: [
// // // // //                     _buildStats(filteredDocs),
// // // // //                     Expanded(
// // // // //                       child: ListView.builder(
// // // // //                         itemCount: filteredDocs.length,
// // // // //                         itemBuilder: (context, index) {
// // // // //                           final doc = filteredDocs[index];
// // // // //                           final data = doc.data() as Map<String, dynamic>;
// // // // //                           final docId = doc.id;
// // // // //                           final date = (data['date'] as Timestamp).toDate();
// // // // //                           final category = _categories.firstWhere(
// // // // //                             (cat) => cat['name'] == data['category'],
// // // // //                             orElse: () => _categories.last,
// // // // //                           );

// // // // //                           return Card(
// // // // //                             margin: const EdgeInsets.symmetric(
// // // // //                               horizontal: 8,
// // // // //                               vertical: 4,
// // // // //                             ),
// // // // //                             child: ListTile(
// // // // //                               leading: CircleAvatar(
// // // // //                                 backgroundColor: category['color'].withOpacity(
// // // // //                                   0.1,
// // // // //                                 ),
// // // // //                                 child: Icon(
// // // // //                                   category['icon'],
// // // // //                                   color: category['color'],
// // // // //                                   size: 20,
// // // // //                                 ),
// // // // //                               ),
// // // // //                               title: Text(
// // // // //                                 "${data['amount'].toStringAsFixed(2)} ج",
// // // // //                                 style: const TextStyle(
// // // // //                                   fontWeight: FontWeight.bold,
// // // // //                                   fontSize: 18,
// // // // //                                   color: Colors.blue,
// // // // //                                 ),
// // // // //                               ),
// // // // //                               subtitle: Column(
// // // // //                                 crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                                 children: [
// // // // //                                   const SizedBox(height: 4),
// // // // //                                   Text(
// // // // //                                     data['category'],
// // // // //                                     style: TextStyle(
// // // // //                                       fontSize: 14,
// // // // //                                       color: category['color'],
// // // // //                                       fontWeight: FontWeight.bold,
// // // // //                                     ),
// // // // //                                   ),
// // // // //                                   const SizedBox(height: 2),
// // // // //                                   Text(
// // // // //                                     DateFormat('yyyy/MM/dd').format(date),
// // // // //                                     style: const TextStyle(fontSize: 12),
// // // // //                                   ),
// // // // //                                   if (data['note'] != null &&
// // // // //                                       data['note'].isNotEmpty)
// // // // //                                     Padding(
// // // // //                                       padding: const EdgeInsets.only(top: 4),
// // // // //                                       child: Text(
// // // // //                                         data['note'],
// // // // //                                         style: TextStyle(
// // // // //                                           fontSize: 12,
// // // // //                                           color: Colors.grey.shade600,
// // // // //                                         ),
// // // // //                                       ),
// // // // //                                     ),
// // // // //                                 ],
// // // // //                               ),
// // // // //                               trailing: PopupMenuButton<String>(
// // // // //                                 icon: const Icon(Icons.more_vert),
// // // // //                                 onSelected: (value) async {
// // // // //                                   if (value == 'edit') {
// // // // //                                     await _openExpenseSheet(
// // // // //                                       docId: docId,
// // // // //                                       data: data,
// // // // //                                     );
// // // // //                                   } else if (value == 'delete') {
// // // // //                                     await _confirmDelete(docId, data['title']);
// // // // //                                   }
// // // // //                                 },
// // // // //                                 itemBuilder: (BuildContext context) {
// // // // //                                   return [
// // // // //                                     const PopupMenuItem<String>(
// // // // //                                       value: 'edit',
// // // // //                                       child: Row(
// // // // //                                         children: [
// // // // //                                           Icon(Icons.edit, size: 20),
// // // // //                                           SizedBox(width: 8),
// // // // //                                           Text('تعديل'),
// // // // //                                         ],
// // // // //                                       ),
// // // // //                                     ),
// // // // //                                     const PopupMenuItem<String>(
// // // // //                                       value: 'delete',
// // // // //                                       child: Row(
// // // // //                                         children: [
// // // // //                                           Icon(
// // // // //                                             Icons.delete,
// // // // //                                             color: Colors.red,
// // // // //                                             size: 20,
// // // // //                                           ),
// // // // //                                           SizedBox(width: 8),
// // // // //                                           Text(
// // // // //                                             'حذف',
// // // // //                                             style: TextStyle(color: Colors.red),
// // // // //                                           ),
// // // // //                                         ],
// // // // //                                       ),
// // // // //                                     ),
// // // // //                                   ];
// // // // //                                 },
// // // // //                               ),
// // // // //                             ),
// // // // //                           );
// // // // //                         },
// // // // //                       ),
// // // // //                     ),
// // // // //                   ],
// // // // //                 );
// // // // //               },
// // // // //             ),
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //       floatingActionButton: FloatingActionButton.extended(
// // // // //         onPressed: () => _openExpenseSheet(),
// // // // //         icon: const Icon(Icons.add),
// // // // //         label: const Text("إضافة مصروف"),
// // // // //         backgroundColor: const Color(0xFF3498DB),
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }
// // // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:intl/intl.dart';

// // // // class ExpensesPage extends StatefulWidget {
// // // //   const ExpensesPage({super.key});

// // // //   @override
// // // //   State<ExpensesPage> createState() => _ExpensesPageState();
// // // // }

// // // // class _ExpensesPageState extends State<ExpensesPage> {
// // // //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// // // //   final TextEditingController _titleController = TextEditingController();
// // // //   final TextEditingController _amountController = TextEditingController();
// // // //   final TextEditingController _noteController = TextEditingController();

// // // //   String selectedCategory = "تشغيل"; // تغيير من "نثريات" إلى "تشغيل"
// // // //   DateTime selectedDate = DateTime.now();
// // // //   bool _isLoading = false;
// // // //   String? _editingDocId;

// // // //   // التصنيفات بعد الحذف
// // // //   final List<Map<String, dynamic>> _categories = [
// // // //     {"name": "تشغيل", "color": Colors.blue, "icon": Icons.business},
// // // //     {"name": "مواصلات", "color": Colors.green, "icon": Icons.directions_car},
// // // //     {"name": "أدوات", "color": Colors.orange, "icon": Icons.build},
// // // //     {"name": "طعام", "color": Colors.red, "icon": Icons.restaurant},
// // // //     {"name": "أخرى", "color": Colors.grey, "icon": Icons.more_horiz},
// // // //   ];

// // // //   // ================= فلترة مشابهة لشغل السائقين =================
// // // //   int _selectedMonth = DateTime.now().month;
// // // //   int _selectedYear = DateTime.now().year;
// // // //   String _timeFilter = 'الكل';

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     selectedCategory = "تشغيل"; // تأكيد التغيير
// // // //     _resetForm();
// // // //   }

// // // //   // ================= فلترة حسب التاريخ =================
// // // //   List<QueryDocumentSnapshot> _filterExpensesByDate(
// // // //     List<QueryDocumentSnapshot> allDocs,
// // // //   ) {
// // // //     return allDocs.where((doc) {
// // // //       final data = doc.data() as Map<String, dynamic>;
// // // //       final date = (data['date'] as Timestamp).toDate();

// // // //       if (_timeFilter == 'الكل') return true;

// // // //       final now = DateTime.now();
// // // //       switch (_timeFilter) {
// // // //         case 'اليوم':
// // // //           return date.year == now.year &&
// // // //               date.month == now.month &&
// // // //               date.day == now.day;
// // // //         case 'هذا الشهر':
// // // //           return date.year == now.year && date.month == now.month;
// // // //         case 'هذه السنة':
// // // //           return date.year == now.year;
// // // //         case 'مخصص':
// // // //           return date.year == _selectedYear && date.month == _selectedMonth;
// // // //         default:
// // // //           return true;
// // // //       }
// // // //     }).toList();
// // // //   }

// // // //   void _changeTimeFilter(String filter) {
// // // //     setState(() => _timeFilter = filter);
// // // //     _applyFilters();
// // // //   }

// // // //   void _applyMonthYearFilter() {
// // // //     setState(() => _timeFilter = 'مخصص');
// // // //     _applyFilters();
// // // //   }

// // // //   void _applyFilters() {
// // // //     setState(() {});
// // // //   }

// // // //   // ================= AppBar مخصص مثل صفحة السائقين =================
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
// // // //         bottom: false,
// // // //         child: Row(
// // // //           children: [
// // // //             const Icon(Icons.attach_money, color: Colors.white, size: 28),
// // // //             const SizedBox(width: 12),
// // // //             const Text(
// // // //               'المصروفات والنثريات',
// // // //               style: TextStyle(
// // // //                 color: Colors.white,
// // // //                 fontSize: 20,
// // // //                 fontWeight: FontWeight.bold,
// // // //               ),
// // // //             ),
// // // //             const Spacer(),
// // // //             StreamBuilder<DateTime>(
// // // //               stream: Stream.periodic(
// // // //                 const Duration(seconds: 1),
// // // //                 (_) => DateTime.now(),
// // // //               ),
// // // //               builder: (context, snapshot) {
// // // //                 final now = snapshot.data ?? DateTime.now();
// // // //                 int hour12 = now.hour % 12;
// // // //                 if (hour12 == 0) hour12 = 12;
// // // //                 String period = now.hour < 12 ? 'AM' : 'PM';

// // // //                 return Column(
// // // //                   crossAxisAlignment: CrossAxisAlignment.center,
// // // //                   children: [
// // // //                     Container(
// // // //                       height: 50,
// // // //                       width: 150,
// // // //                       decoration: BoxDecoration(
// // // //                         color: Colors.transparent,
// // // //                         borderRadius: BorderRadius.circular(16),
// // // //                       ),
// // // //                       child: Center(
// // // //                         child: Text(
// // // //                           '${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period',
// // // //                           style: const TextStyle(
// // // //                             color: Colors.white,
// // // //                             fontSize: 36,
// // // //                             fontWeight: FontWeight.bold,
// // // //                           ),
// // // //                         ),
// // // //                       ),
// // // //                     ),
// // // //                   ],
// // // //                 );
// // // //               },
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ================= إضافة/تعديل مصروف =================
// // // //   Future<void> _openExpenseSheet({
// // // //     String? docId,
// // // //     Map<String, dynamic>? data,
// // // //   }) async {
// // // //     _editingDocId = docId;

// // // //     if (data != null) {
// // // //       // وضع التعديل
// // // //       _titleController.text = data['title'];
// // // //       _amountController.text = data['amount'].toString();
// // // //       _noteController.text = data['note'] ?? '';
// // // //       selectedCategory = data['category'];
// // // //       selectedDate = (data['date'] as Timestamp).toDate();
// // // //     } else {
// // // //       // وضع الإضافة
// // // //       _titleController.clear();
// // // //       _amountController.clear();
// // // //       _noteController.clear();
// // // //       selectedCategory = "تشغيل"; // تغيير من "نثريات" إلى "تشغيل"
// // // //       selectedDate = DateTime.now();
// // // //     }

// // // //     await showDialog(
// // // //       context: context,
// // // //       builder: (context) {
// // // //         return AlertDialog(
// // // //           title: Text(
// // // //             docId == null ? "إضافة مصروف جديد" : "تعديل المصروف",
// // // //             style: const TextStyle(fontWeight: FontWeight.bold),
// // // //           ),
// // // //           content: SingleChildScrollView(
// // // //             child: Column(
// // // //               mainAxisSize: MainAxisSize.min,
// // // //               children: [
// // // //                 // التاريخ أولاً
// // // //                 Container(
// // // //                   padding: const EdgeInsets.all(12),
// // // //                   decoration: BoxDecoration(
// // // //                     border: Border.all(color: Colors.grey.shade300),
// // // //                     borderRadius: BorderRadius.circular(8),
// // // //                   ),
// // // //                   child: Row(
// // // //                     children: [
// // // //                       const Icon(
// // // //                         Icons.calendar_today,
// // // //                         size: 20,
// // // //                         color: Colors.blue,
// // // //                       ),
// // // //                       const SizedBox(width: 12),
// // // //                       Expanded(
// // // //                         child: Column(
// // // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // // //                           children: [
// // // //                             const Text(
// // // //                               "التاريخ",
// // // //                               style: TextStyle(
// // // //                                 fontSize: 12,
// // // //                                 color: Colors.grey,
// // // //                               ),
// // // //                             ),
// // // //                             Text(
// // // //                               DateFormat('yyyy/MM/dd').format(selectedDate),
// // // //                               style: const TextStyle(
// // // //                                 fontWeight: FontWeight.bold,
// // // //                                 fontSize: 16,
// // // //                               ),
// // // //                             ),
// // // //                           ],
// // // //                         ),
// // // //                       ),
// // // //                       IconButton(
// // // //                         onPressed: () async {
// // // //                           final DateTime? picked = await showDatePicker(
// // // //                             context: context,
// // // //                             initialDate: selectedDate,
// // // //                             firstDate: DateTime(2000),
// // // //                             lastDate: DateTime(2100),
// // // //                           );
// // // //                           if (picked != null) {
// // // //                             setState(() {
// // // //                               selectedDate = picked;
// // // //                             });
// // // //                           }
// // // //                         },
// // // //                         icon: const Icon(Icons.edit, size: 20),
// // // //                         style: IconButton.styleFrom(
// // // //                           backgroundColor: Colors.blue.shade50,
// // // //                         ),
// // // //                       ),
// // // //                     ],
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(height: 16),

// // // //                 // المبلغ ثانياً
// // // //                 TextField(
// // // //                   controller: _amountController,
// // // //                   keyboardType: TextInputType.number,
// // // //                   decoration: InputDecoration(
// // // //                     labelText: "المبلغ",
// // // //                     prefixText: "ج ",
// // // //                     prefixIcon: const Icon(
// // // //                       Icons.attach_money,
// // // //                       color: Colors.green,
// // // //                     ),
// // // //                     border: OutlineInputBorder(
// // // //                       borderRadius: BorderRadius.circular(8),
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(height: 16),

// // // //                 // القائمة المنسدلة ثالثاً
// // // //                 DropdownButtonFormField<String>(
// // // //                   value: selectedCategory,
// // // //                   decoration: InputDecoration(
// // // //                     labelText: "التصنيف",
// // // //                     prefixIcon: const Icon(
// // // //                       Icons.category,
// // // //                       color: Colors.purple,
// // // //                     ),
// // // //                     border: OutlineInputBorder(
// // // //                       borderRadius: BorderRadius.circular(8),
// // // //                     ),
// // // //                   ),
// // // //                   items: _categories.map((category) {
// // // //                     return DropdownMenuItem<String>(
// // // //                       value: category['name'],
// // // //                       child: Row(
// // // //                         children: [
// // // //                           Icon(
// // // //                             category['icon'],
// // // //                             color: category['color'],
// // // //                             size: 20,
// // // //                           ),
// // // //                           const SizedBox(width: 12),
// // // //                           Text(category['name']),
// // // //                         ],
// // // //                       ),
// // // //                     );
// // // //                   }).toList(),
// // // //                   onChanged: (value) {
// // // //                     if (value != null) {
// // // //                       setState(() {
// // // //                         selectedCategory = value;
// // // //                       });
// // // //                     }
// // // //                   },
// // // //                 ),
// // // //                 const SizedBox(height: 16),

// // // //                 // الملاحظات رابعاً
// // // //                 TextField(
// // // //                   controller: _noteController,
// // // //                   maxLines: 3,
// // // //                   decoration: InputDecoration(
// // // //                     labelText: "ملاحظات",
// // // //                     prefixIcon: const Icon(Icons.note, color: Colors.orange),
// // // //                     border: OutlineInputBorder(
// // // //                       borderRadius: BorderRadius.circular(8),
// // // //                     ),
// // // //                     hintText: "أضف ملاحظات حول المصروف...",
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //           actions: [
// // // //             TextButton(
// // // //               onPressed: () {
// // // //                 Navigator.pop(context);
// // // //                 _resetForm();
// // // //               },
// // // //               child: const Text("إلغاء"),
// // // //             ),
// // // //             ElevatedButton(
// // // //               onPressed: _isLoading
// // // //                   ? null
// // // //                   : () async {
// // // //                       if (_amountController.text.isEmpty) {
// // // //                         ScaffoldMessenger.of(context).showSnackBar(
// // // //                           const SnackBar(content: Text("الرجاء إدخال المبلغ")),
// // // //                         );
// // // //                         return;
// // // //                       }

// // // //                       setState(() {
// // // //                         _isLoading = true;
// // // //                       });

// // // //                       try {
// // // //                         final expenseData = {
// // // //                           "title": selectedCategory,
// // // //                           "amount": double.parse(_amountController.text),
// // // //                           "category": selectedCategory,
// // // //                           "note": _noteController.text,
// // // //                           "date": Timestamp.fromDate(selectedDate),
// // // //                           "updatedAt": Timestamp.now(),
// // // //                         };

// // // //                         if (docId == null) {
// // // //                           // إضافة جديد
// // // //                           expenseData["createdAt"] = Timestamp.now();
// // // //                           await _firestore
// // // //                               .collection("expenses")
// // // //                               .add(expenseData);

// // // //                           ScaffoldMessenger.of(context).showSnackBar(
// // // //                             const SnackBar(
// // // //                               content: Text("تم إضافة المصروف بنجاح"),
// // // //                               backgroundColor: Colors.green,
// // // //                             ),
// // // //                           );
// // // //                         } else {
// // // //                           // تحديث
// // // //                           await _firestore
// // // //                               .collection("expenses")
// // // //                               .doc(docId)
// // // //                               .update(expenseData);

// // // //                           ScaffoldMessenger.of(context).showSnackBar(
// // // //                             const SnackBar(
// // // //                               content: Text("تم تحديث المصروف بنجاح"),
// // // //                               backgroundColor: Colors.blue,
// // // //                             ),
// // // //                           );
// // // //                         }

// // // //                         Navigator.pop(context);
// // // //                         _resetForm();
// // // //                       } catch (e) {
// // // //                         ScaffoldMessenger.of(context).showSnackBar(
// // // //                           SnackBar(
// // // //                             content: Text("حدث خطأ: $e"),
// // // //                             backgroundColor: Colors.red,
// // // //                           ),
// // // //                         );
// // // //                       } finally {
// // // //                         setState(() {
// // // //                           _isLoading = false;
// // // //                         });
// // // //                       }
// // // //                     },
// // // //               child: _isLoading
// // // //                   ? const SizedBox(
// // // //                       width: 20,
// // // //                       height: 20,
// // // //                       child: CircularProgressIndicator(strokeWidth: 2),
// // // //                     )
// // // //                   : Text(docId == null ? "إضافة" : "تحديث"),
// // // //             ),
// // // //           ],
// // // //         );
// // // //       },
// // // //     );
// // // //   }

// // // //   // ================= حذف مصروف =================
// // // //   Future<void> _confirmDelete(String docId, String title) async {
// // // //     return showDialog(
// // // //       context: context,
// // // //       builder: (context) {
// // // //         return AlertDialog(
// // // //           title: const Text("تأكيد الحذف"),
// // // //           content: Text("هل أنت متأكد من حذف مصروف '$title'؟"),
// // // //           actions: [
// // // //             TextButton(
// // // //               onPressed: () => Navigator.pop(context),
// // // //               child: const Text("إلغاء"),
// // // //             ),
// // // //             ElevatedButton(
// // // //               onPressed: () async {
// // // //                 Navigator.pop(context);
// // // //                 try {
// // // //                   await _firestore.collection("expenses").doc(docId).delete();
// // // //                   ScaffoldMessenger.of(context).showSnackBar(
// // // //                     const SnackBar(
// // // //                       content: Text("تم حذف المصروف بنجاح"),
// // // //                       backgroundColor: Colors.red,
// // // //                     ),
// // // //                   );
// // // //                 } catch (e) {
// // // //                   ScaffoldMessenger.of(context).showSnackBar(
// // // //                     SnackBar(
// // // //                       content: Text("حدث خطأ أثناء الحذف: $e"),
// // // //                       backgroundColor: Colors.red,
// // // //                     ),
// // // //                   );
// // // //                 }
// // // //               },
// // // //               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
// // // //               child: const Text("حذف", style: TextStyle(color: Colors.white)),
// // // //             ),
// // // //           ],
// // // //         );
// // // //       },
// // // //     );
// // // //   }

// // // //   // ================= جزء الفلترة =================
// // // //   Widget _buildTimeFilterSection() {
// // // //     return Container(
// // // //       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
// // // //       color: Colors.white,
// // // //       child: Column(
// // // //         children: [
// // // //           SingleChildScrollView(
// // // //             scrollDirection: Axis.horizontal,
// // // //             child: Row(
// // // //               // children: ['الكل', 'اليوم', 'هذا الشهر', 'هذه السنة']
// // // //               //     .map(
// // // //               //       (filter) => Padding(
// // // //               //         padding: const EdgeInsets.symmetric(horizontal: 4),
// // // //               //         child: ChoiceChip(
// // // //               //           label: Text(filter),
// // // //               //           selected: _timeFilter == filter,
// // // //               //           onSelected: (selected) {
// // // //               //             if (selected) _changeTimeFilter(filter);
// // // //               //           },
// // // //               //           selectedColor: const Color(0xFF3498DB),
// // // //               //           labelStyle: TextStyle(
// // // //               //             color: _timeFilter == filter
// // // //               //                 ? Colors.white
// // // //               //                 : const Color(0xFF2C3E50),
// // // //               //           ),
// // // //               //         ),
// // // //               //       ),
// // // //               //     )
// // // //               //     .toList(),
// // // //             ),
// // // //           ),
// // // //           const SizedBox(height: 12),
// // // //           Row(
// // // //             mainAxisAlignment: MainAxisAlignment.center,
// // // //             children: [
// // // //               const Icon(Icons.calendar_month, color: Color(0xFF3498DB)),
// // // //               const SizedBox(width: 8),
// // // //               DropdownButton<int>(
// // // //                 value: _selectedMonth,
// // // //                 onChanged: (value) {
// // // //                   if (value != null) {
// // // //                     setState(() => _selectedMonth = value);
// // // //                     _applyMonthYearFilter();
// // // //                   }
// // // //                 },
// // // //                 items: List.generate(12, (index) {
// // // //                   final monthNumber = index + 1;
// // // //                   return DropdownMenuItem(
// // // //                     value: monthNumber,
// // // //                     child: Text('شهر $monthNumber'),
// // // //                   );
// // // //                 }),
// // // //               ),
// // // //               const SizedBox(width: 20),
// // // //               DropdownButton<int>(
// // // //                 value: _selectedYear,
// // // //                 onChanged: (value) {
// // // //                   if (value != null) {
// // // //                     setState(() => _selectedYear = value);
// // // //                     _applyMonthYearFilter();
// // // //                   }
// // // //                 },
// // // //                 items: [
// // // //                   for (
// // // //                     int i = DateTime.now().year - 2;
// // // //                     i <= DateTime.now().year + 2;
// // // //                     i++
// // // //                   )
// // // //                     DropdownMenuItem(value: i, child: Text('$i')),
// // // //                 ],
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ================= إحصائيات =================
// // // //   Widget _buildStats(List<QueryDocumentSnapshot> docs) {
// // // //     double total = 0;
// // // //     Map<String, double> categoryTotals = {};

// // // //     for (var doc in docs) {
// // // //       final data = doc.data() as Map<String, dynamic>;
// // // //       final amount = data['amount'] as double;
// // // //       final category = data['category'] as String;

// // // //       total += amount;
// // // //       categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
// // // //     }

// // // //     return Card(
// // // //       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// // // //       child: Padding(
// // // //         padding: const EdgeInsets.all(12),
// // // //         child: Column(
// // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // //           children: [
// // // //             const Text(
// // // //               "إحصائيات المصروفات",
// // // //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
// // // //             ),
// // // //             const SizedBox(height: 8),
// // // //             Row(
// // // //               children: [
// // // //                 Expanded(
// // // //                   child: Container(
// // // //                     padding: const EdgeInsets.all(12),
// // // //                     decoration: BoxDecoration(
// // // //                       color: Colors.blue.shade50,
// // // //                       borderRadius: BorderRadius.circular(8),
// // // //                     ),
// // // //                     child: Column(
// // // //                       children: [
// // // //                         const Text(
// // // //                           "المجموع الكلي",
// // // //                           style: TextStyle(fontSize: 12),
// // // //                         ),
// // // //                         const SizedBox(height: 4),
// // // //                         Text(
// // // //                           "${total.toStringAsFixed(2)} ج",
// // // //                           style: const TextStyle(
// // // //                             fontWeight: FontWeight.bold,
// // // //                             fontSize: 16,
// // // //                             color: Colors.blue,
// // // //                           ),
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //                 const SizedBox(width: 8),
// // // //                 Expanded(
// // // //                   child: Container(
// // // //                     padding: const EdgeInsets.all(12),
// // // //                     decoration: BoxDecoration(
// // // //                       color: Colors.green.shade50,
// // // //                       borderRadius: BorderRadius.circular(8),
// // // //                     ),
// // // //                     child: Column(
// // // //                       children: [
// // // //                         const Text(
// // // //                           "عدد المصروفات",
// // // //                           style: TextStyle(fontSize: 12),
// // // //                         ),
// // // //                         const SizedBox(height: 4),
// // // //                         Text(
// // // //                           "${docs.length}",
// // // //                           style: const TextStyle(
// // // //                             fontWeight: FontWeight.bold,
// // // //                             fontSize: 16,
// // // //                             color: Colors.green,
// // // //                           ),
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                   ),
// // // //                 ),
// // // //               ],
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   // ================= إعادة تعيين النموذج =================
// // // //   void _resetForm() {
// // // //     _titleController.clear();
// // // //     _amountController.clear();
// // // //     _noteController.clear();
// // // //     selectedCategory = "تشغيل"; // تغيير من "نثريات" إلى "تشغيل"
// // // //     selectedDate = DateTime.now();
// // // //     _editingDocId = null;
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _titleController.dispose();
// // // //     _amountController.dispose();
// // // //     _noteController.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       backgroundColor: const Color(0xFFF4F6F8),
// // // //       body: Column(
// // // //         children: [
// // // //           // AppBar مخصص مثل صفحة السائقين
// // // //           _buildCustomAppBar(),

// // // //           // جزء الفلترة
// // // //           _buildTimeFilterSection(),

// // // //           // المحتوى الرئيسي
// // // //           Expanded(
// // // //             child: StreamBuilder<QuerySnapshot>(
// // // //               stream: _firestore
// // // //                   .collection("expenses")
// // // //                   .orderBy('date', descending: true)
// // // //                   .snapshots(),
// // // //               builder: (context, snapshot) {
// // // //                 if (!snapshot.hasData) {
// // // //                   return const Center(child: CircularProgressIndicator());
// // // //                 }

// // // //                 // تطبيق الفلترة حسب التاريخ
// // // //                 List<QueryDocumentSnapshot> allDocs = snapshot.data!.docs;
// // // //                 List<QueryDocumentSnapshot> filteredDocs =
// // // //                     _filterExpensesByDate(allDocs);

// // // //                 if (snapshot.data!.docs.isEmpty) {
// // // //                   return Center(
// // // //                     child: Column(
// // // //                       mainAxisAlignment: MainAxisAlignment.center,
// // // //                       children: [
// // // //                         const Icon(
// // // //                           Icons.receipt_long,
// // // //                           size: 80,
// // // //                           color: Colors.grey,
// // // //                         ),
// // // //                         const SizedBox(height: 16),
// // // //                         const Text(
// // // //                           "لا توجد مصروفات",
// // // //                           style: TextStyle(fontSize: 18, color: Colors.grey),
// // // //                         ),
// // // //                         const SizedBox(height: 8),
// // // //                         Text(
// // // //                           "انقر على زر + لإضافة أول مصروف",
// // // //                           style: TextStyle(
// // // //                             fontSize: 14,
// // // //                             color: Colors.grey.shade600,
// // // //                           ),
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                   );
// // // //                 }

// // // //                 return Column(
// // // //                   children: [
// // // //                     _buildStats(filteredDocs),
// // // //                     Expanded(
// // // //                       child: ListView.builder(
// // // //                         itemCount: filteredDocs.length,
// // // //                         itemBuilder: (context, index) {
// // // //                           final doc = filteredDocs[index];
// // // //                           final data = doc.data() as Map<String, dynamic>;
// // // //                           final docId = doc.id;
// // // //                           final date = (data['date'] as Timestamp).toDate();
// // // //                           final category = _categories.firstWhere(
// // // //                             (cat) => cat['name'] == data['category'],
// // // //                             orElse: () => _categories.last,
// // // //                           );

// // // //                           return Card(
// // // //                             margin: const EdgeInsets.symmetric(
// // // //                               horizontal: 8,
// // // //                               vertical: 4,
// // // //                             ),
// // // //                             child: ListTile(
// // // //                               leading: CircleAvatar(
// // // //                                 backgroundColor: category['color'].withOpacity(
// // // //                                   0.1,
// // // //                                 ),
// // // //                                 child: Icon(
// // // //                                   category['icon'],
// // // //                                   color: category['color'],
// // // //                                   size: 20,
// // // //                                 ),
// // // //                               ),
// // // //                               title: Text(
// // // //                                 "${data['amount'].toStringAsFixed(2)} ج",
// // // //                                 style: const TextStyle(
// // // //                                   fontWeight: FontWeight.bold,
// // // //                                   fontSize: 18,
// // // //                                   color: Colors.blue,
// // // //                                 ),
// // // //                               ),
// // // //                               subtitle: Column(
// // // //                                 crossAxisAlignment: CrossAxisAlignment.start,
// // // //                                 children: [
// // // //                                   const SizedBox(height: 4),
// // // //                                   Text(
// // // //                                     data['category'],
// // // //                                     style: TextStyle(
// // // //                                       fontSize: 14,
// // // //                                       color: category['color'],
// // // //                                       fontWeight: FontWeight.bold,
// // // //                                     ),
// // // //                                   ),
// // // //                                   const SizedBox(height: 2),
// // // //                                   Text(
// // // //                                     DateFormat('yyyy/MM/dd').format(date),
// // // //                                     style: const TextStyle(fontSize: 12),
// // // //                                   ),
// // // //                                   if (data['note'] != null &&
// // // //                                       data['note'].isNotEmpty)
// // // //                                     Padding(
// // // //                                       padding: const EdgeInsets.only(top: 4),
// // // //                                       child: Text(
// // // //                                         data['note'],
// // // //                                         style: TextStyle(
// // // //                                           fontSize: 12,
// // // //                                           color: Colors.grey.shade600,
// // // //                                         ),
// // // //                                       ),
// // // //                                     ),
// // // //                                 ],
// // // //                               ),
// // // //                               trailing: PopupMenuButton<String>(
// // // //                                 icon: const Icon(Icons.more_vert),
// // // //                                 onSelected: (value) async {
// // // //                                   if (value == 'edit') {
// // // //                                     await _openExpenseSheet(
// // // //                                       docId: docId,
// // // //                                       data: data,
// // // //                                     );
// // // //                                   } else if (value == 'delete') {
// // // //                                     await _confirmDelete(docId, data['title']);
// // // //                                   }
// // // //                                 },
// // // //                                 itemBuilder: (BuildContext context) {
// // // //                                   return [
// // // //                                     const PopupMenuItem<String>(
// // // //                                       value: 'edit',
// // // //                                       child: Row(
// // // //                                         children: [
// // // //                                           Icon(Icons.edit, size: 20),
// // // //                                           SizedBox(width: 8),
// // // //                                           Text('تعديل'),
// // // //                                         ],
// // // //                                       ),
// // // //                                     ),
// // // //                                     const PopupMenuItem<String>(
// // // //                                       value: 'delete',
// // // //                                       child: Row(
// // // //                                         children: [
// // // //                                           Icon(
// // // //                                             Icons.delete,
// // // //                                             color: Colors.red,
// // // //                                             size: 20,
// // // //                                           ),
// // // //                                           SizedBox(width: 8),
// // // //                                           Text(
// // // //                                             'حذف',
// // // //                                             style: TextStyle(color: Colors.red),
// // // //                                           ),
// // // //                                         ],
// // // //                                       ),
// // // //                                     ),
// // // //                                   ];
// // // //                                 },
// // // //                               ),
// // // //                             ),
// // // //                           );
// // // //                         },
// // // //                       ),
// // // //                     ),
// // // //                   ],
// // // //                 );
// // // //               },
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //       floatingActionButton: FloatingActionButton.extended(
// // // //         onPressed: () => _openExpenseSheet(),
// // // //         icon: const Icon(Icons.add),
// // // //         label: const Text("إضافة مصروف"),
// // // //         backgroundColor: const Color(0xFF3498DB),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:intl/intl.dart';
// // import 'package:pdf/pdf.dart';
// // import 'package:pdf/widgets.dart' as pdfLib;
// // import 'package:printing/printing.dart';

// // class ExpensesPage extends StatefulWidget {
// //   const ExpensesPage({super.key});

// //   @override
// //   State<ExpensesPage> createState() => _ExpensesPageState();
// // }

// // class _ExpensesPageState extends State<ExpensesPage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   final TextEditingController _titleController = TextEditingController();
// //   final TextEditingController _amountController = TextEditingController();
// //   final TextEditingController _noteController = TextEditingController();

// //   String selectedCategory = "تشغيل";
// //   DateTime selectedDate = DateTime.now();
// //   bool _isLoading = false;
// //   bool _isGeneratingPDF = false;
// //   String? _editingDocId;

// //   // التصنيفات
// //   final List<Map<String, dynamic>> _categories = [
// //     {"name": "تشغيل", "color": Colors.blue, "icon": Icons.business},
// //     {"name": "مواصلات", "color": Colors.green, "icon": Icons.directions_car},
// //     {"name": "أدوات", "color": Colors.orange, "icon": Icons.build},
// //     {"name": "طعام", "color": Colors.red, "icon": Icons.restaurant},
// //     {"name": "أخرى", "color": Colors.grey, "icon": Icons.more_horiz},
// //   ];

// //   // ================= فلترة =================
// //   int _selectedMonth = DateTime.now().month;
// //   int _selectedYear = DateTime.now().year;
// //   String _timeFilter = 'الكل';

// //   // ================= PDF Generator =================
// //   pdfLib.Font? _arabicFont;

// //   @override
// //   void initState() {
// //     super.initState();
// //     selectedCategory = "تشغيل";
// //     _resetForm();
// //     _loadArabicFont();
// //   }

// //   Future<void> _loadArabicFont() async {
// //     try {
// //       final fontData = await rootBundle.load(
// //         'assets/fonts/Amiri/Amiri-Regular.ttf',
// //       );

// //       _arabicFont = pdfLib.Font.ttf(fontData);
// //       debugPrint('تم تحميل الخط العربي بنجاح');
// //     } catch (e) {
// //       debugPrint('فشل تحميل الخط العربي: $e');
// //     }
// //   }

// //   // ================= إنشاء PDF =================
// //   // Future<void> _generatePDF() async {
// //   //   if (_arabicFont == null) {
// //   //     ScaffoldMessenger.of(
// //   //       context,
// //   //     ).showSnackBar(const SnackBar(content: Text('الخط العربي غير محمل')));
// //   //     return;
// //   //   }

// //   //   setState(() => _isGeneratingPDF = true);

// //   //   try {
// //   //     // جلب البيانات مع التصفية
// //   //     final expenses = await _fetchExpensesForPDF();

// //   //     if (expenses.isEmpty) {
// //   //       ScaffoldMessenger.of(context).showSnackBar(
// //   //         const SnackBar(content: Text('لا توجد مصروفات للطباعة')),
// //   //       );
// //   //       return;
// //   //     }

// //   //     // إنشاء PDF
// //   //     final pdf = pdfLib.Document(
// //   //       theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
// //   //     );

// //   //     // صفحة العنوان والإحصائيات
// //   //     pdf.addPage(
// //   //       pdfLib.MultiPage(
// //   //         pageFormat: PdfPageFormat.a4,
// //   //         build: (context) => [_buildPdfTitlePage(expenses)],
// //   //       ),
// //   //     );

// //   //     // صفحة الجدول التفصيلي
// //   //     pdf.addPage(
// //   //       pdfLib.MultiPage(
// //   //         pageFormat: PdfPageFormat.a4,
// //   //         build: (context) => [_buildPdfTablePage(expenses)],
// //   //       ),
// //   //     );

// //   //     // طباعة PDF
// //   //     await Printing.layoutPdf(
// //   //       onLayout: (PdfPageFormat format) async => pdf.save(),
// //   //       name: 'تقرير_المصروفات_${DateTime.now().millisecondsSinceEpoch}',
// //   //     );
// //   //   } catch (e) {
// //   //     ScaffoldMessenger.of(
// //   //       context,
// //   //     ).showSnackBar(SnackBar(content: Text('حدث خطأ في إنشاء PDF: $e')));
// //   //   } finally {
// //   //     setState(() => _isGeneratingPDF = false);
// //   //   }
// //   // }

// //   // Future<List<Map<String, dynamic>>> _fetchExpensesForPDF() async {
// //   //   try {
// //   //     Query query = _firestore
// //   //         .collection("expenses")
// //   //         .orderBy('date', descending: true);

// //   //     final snapshot = await query.get();
// //   //     List<Map<String, dynamic>> filteredExpenses = [];

// //   //     for (var doc in snapshot.docs) {
// //   //       final data = doc.data() as Map<String, dynamic>;
// //   //       final date = (data['date'] as Timestamp).toDate();
// //   //       final docId = doc.id;

// //   //       // تطبيق الفلترة
// //   //       if (_applyPDFFilter(date)) {
// //   //         filteredExpenses.add({
// //   //           'id': docId,
// //   //           'title': data['title'] ?? '',
// //   //           'amount': data['amount'] ?? 0.0,
// //   //           'category': data['category'] ?? 'أخرى',
// //   //           'note': data['note'] ?? '',
// //   //           'date': date,
// //   //           'formattedDate': DateFormat('yyyy/MM/dd').format(date),
// //   //         });
// //   //       }
// //   //     }

// //   //     return filteredExpenses;
// //   //   } catch (e) {
// //   //     debugPrint('خطأ في جلب المصروفات للPDF: $e');
// //   //     return [];
// //   //   }
// //   // }

// //   // bool _applyPDFFilter(DateTime date) {
// //   //   final now = DateTime.now();

// //   //   switch (_timeFilter) {
// //   //     case 'اليوم':
// //   //       return date.year == now.year &&
// //   //           date.month == now.month &&
// //   //           date.day == now.day;
// //   //     case 'هذا الشهر':
// //   //       return date.year == now.year && date.month == now.month;
// //   //     case 'هذه السنة':
// //   //       return date.year == now.year;
// //   //     case 'مخصص':
// //   //       return date.month == _selectedMonth && date.year == _selectedYear;
// //   //     case 'الكل':
// //   //     default:
// //   //       return true;
// //   //   }
// //   // }

// //   // pdfLib.Widget _buildPdfTitlePage(List<Map<String, dynamic>> expenses) {
// //   //   // حساب الإحصائيات
// //   //   double totalAmount = expenses.fold(
// //   //     0.0,
// //   //     (sum, exp) => sum + (exp['amount'] as double),
// //   //   );
// //   //   int count = expenses.length;

// //   //   Map<String, double> categoryTotals = {};
// //   //   for (var exp in expenses) {
// //   //     String category = exp['category'] as String;
// //   //     double amount = exp['amount'] as double;
// //   //     categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
// //   //   }

// //   //   String filterText = _getPDFFilterText();

// //   //   return pdfLib.Directionality(
// //   //     textDirection: pdfLib.TextDirection.rtl,
// //   //     child: pdfLib.Column(
// //   //       crossAxisAlignment: pdfLib.CrossAxisAlignment.center,
// //   //       children: [
// //   //         // العنوان الرئيسي
// //   //         pdfLib.Text(
// //   //           'تقرير المصروفات والنثريات',
// //   //           style: pdfLib.TextStyle(
// //   //             fontSize: 28,
// //   //             fontWeight: pdfLib.FontWeight.bold,
// //   //             font: _arabicFont,
// //   //             color: PdfColors.blue.shade(900),
// //   //           ),
// //   //           textAlign: pdfLib.TextAlign.center,
// //   //         ),

// //   //         pdfLib.SizedBox(height: 10),

// //   //         // فترة التقرير
// //   //         pdfLib.Text(
// //   //           filterText,
// //   //           style: pdfLib.TextStyle(
// //   //             fontSize: 18,
// //   //             font: _arabicFont,
// //   //             color: PdfColors.blue.shade(700),
// //   //           ),
// //   //           textAlign: pdfLib.TextAlign.center,
// //   //         ),

// //   //         pdfLib.SizedBox(height: 20),

// //   //         // تاريخ الإنشاء
// //   //         pdfLib.Text(
// //   //           'تاريخ الإنشاء: ${DateFormat('yyyy/MM/dd - hh:mm a').format(DateTime.now())}',
// //   //           style: pdfLib.TextStyle(
// //   //             fontSize: 14,
// //   //             font: _arabicFont,
// //   //             color: PdfColors.blue.shade(600),
// //   //           ),
// //   //         ),

// //   //         pdfLib.SizedBox(height: 40),

// //   //         // بطاقات الإحصائيات
// //   //         pdfLib.Row(
// //   //           mainAxisAlignment: pdfLib.MainAxisAlignment.spaceEvenly,
// //   //           children: [
// //   //             _buildPdfStatCard(
// //   //               'إجمالي المصروفات',
// //   //               '${totalAmount.toStringAsFixed(2)} ج',
// //   //               PdfColors.blue.shade(900),
// //   //             ),
// //   //             _buildPdfStatCard(
// //   //               'عدد المصروفات',
// //   //               '$count',
// //   //               PdfColors.blue.shade(900),
// //   //             ),
// //   //           ],
// //   //         ),

// //   //         pdfLib.SizedBox(height: 40),

// //   //         // جدول توزيع المصروفات حسب الفئة
// //   //         pdfLib.Text(
// //   //           'توزيع المصروفات حسب الفئة',
// //   //           style: pdfLib.TextStyle(
// //   //             fontSize: 20,
// //   //             fontWeight: pdfLib.FontWeight.bold,
// //   //             font: _arabicFont,
// //   //             color: PdfColors.blue.shade(900),
// //   //           ),
// //   //         ),

// //   //         pdfLib.SizedBox(height: 20),

// //   //         pdfLib.Table(
// //   //           border: pdfLib.TableBorder.all(
// //   //             color: PdfColors.blue.shade(900),
// //   //             width: 1,
// //   //           ),
// //   //           columnWidths: {
// //   //             0: pdfLib.FlexColumnWidth(3),
// //   //             1: pdfLib.FlexColumnWidth(2),
// //   //             2: pdfLib.FlexColumnWidth(2),
// //   //           },
// //   //           children: [
// //   //             // رأس الجدول
// //   //             pdfLib.TableRow(
// //   //               decoration: pdfLib.BoxDecoration(
// //   //                 color: PdfColors.blue.shade(900),
// //   //               ),
// //   //               children: [
// //   //                 _buildPdfHeaderCell('الفئة'),
// //   //                 _buildPdfHeaderCell('المبلغ'),
// //   //                 _buildPdfHeaderCell('النسبة %'),
// //   //               ],
// //   //             ),

// //   //             // بيانات الفئات
// //   //             ...categoryTotals.entries.map((entry) {
// //   //               double percentage = totalAmount > 0
// //   //                   ? (entry.value / totalAmount) * 100
// //   //                   : 0;
// //   //               return pdfLib.TableRow(
// //   //                 children: [
// //   //                   _buildPdfDataCell(entry.key),
// //   //                   _buildPdfDataCell('${entry.value.toStringAsFixed(2)} ج'),
// //   //                   _buildPdfDataCell('${percentage.toStringAsFixed(1)}%'),
// //   //                 ],
// //   //               );
// //   //             }).toList(),
// //   //           ],
// //   //         ),
// //   //       ],
// //   //     ),
// //   //   );
// //   // }

// //   // pdfLib.Widget _buildPdfTablePage(List<Map<String, dynamic>> expenses) {
// //   //   return pdfLib.Directionality(
// //   //     textDirection: pdfLib.TextDirection.rtl,
// //   //     child: pdfLib.Column(
// //   //       crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
// //   //       children: [
// //   //         // عنوان صفحة الجدول
// //   //         pdfLib.Text(
// //   //           'تفاصيل المصروفات',
// //   //           style: pdfLib.TextStyle(
// //   //             fontSize: 24,
// //   //             fontWeight: pdfLib.FontWeight.bold,
// //   //             font: _arabicFont,
// //   //             color: PdfColors.blue.shade(900),
// //   //           ),
// //   //         ),

// //   //         pdfLib.SizedBox(height: 20),

// //   //         // الجدول التفصيلي
// //   //         pdfLib.Table(
// //   //           border: pdfLib.TableBorder.all(
// //   //             color: PdfColors.blue.shade(900),
// //   //             width: 1.5,
// //   //           ),
// //   //           columnWidths: {
// //   //             0: pdfLib.FlexColumnWidth(0.8), // مسلسل
// //   //             1: pdfLib.FlexColumnWidth(1.2), // التاريخ
// //   //             2: pdfLib.FlexColumnWidth(1.5), // المبلغ
// //   //             3: pdfLib.FlexColumnWidth(2.0), // النوع (الفئة)
// //   //             4: pdfLib.FlexColumnWidth(3.0), // الملاحظات
// //   //           },
// //   //           children: [
// //   //             // رأس الجدول
// //   //             pdfLib.TableRow(
// //   //               decoration: pdfLib.BoxDecoration(
// //   //                 color: PdfColors.blue.shade(100),
// //   //               ),
// //   //               children: [
// //   //                 _buildPdfHeaderCell('م'),
// //   //                 _buildPdfHeaderCell('التاريخ'),
// //   //                 _buildPdfHeaderCell('المبلغ'),
// //   //                 _buildPdfHeaderCell('النوع'),
// //   //                 _buildPdfHeaderCell('ملاحظات'),
// //   //               ],
// //   //             ),

// //   //             // بيانات المصروفات
// //   //             ...expenses.asMap().entries.map((entry) {
// //   //               int index = entry.key + 1;
// //   //               Map<String, dynamic> expense = entry.value;

// //   //               PdfColor cellColor = index.isEven
// //   //                   ? PdfColors.blue.shade(100)
// //   //                   : PdfColors.white;

// //   //               return pdfLib.TableRow(
// //   //                 decoration: pdfLib.BoxDecoration(color: cellColor),
// //   //                 children: [
// //   //                   _buildPdfDataCell(index.toString()),
// //   //                   _buildPdfDataCell(
// //   //                     expense['formattedDate']?.toString() ?? '',
// //   //                   ),
// //   //                   _buildPdfDataCell(
// //   //                     '${(expense['amount'] as double).toStringAsFixed(2)} ج',
// //   //                   ),
// //   //                   _buildPdfDataCell(expense['category']?.toString() ?? ''),
// //   //                   _buildPdfDataCell(expense['note']?.toString() ?? '-'),
// //   //                 ],
// //   //               );
// //   //             }).toList(),
// //   //           ],
// //   //         ),

// //   //         pdfLib.SizedBox(height: 30),

// //   //         // ملخص في نهاية الصفحة
// //   //         pdfLib.Container(
// //   //           padding: const pdfLib.EdgeInsets.all(15),
// //   //           decoration: pdfLib.BoxDecoration(
// //   //             border: pdfLib.Border.all(
// //   //               color: PdfColors.blue.shade(900),
// //   //               width: 1,
// //   //             ),
// //   //             borderRadius: pdfLib.BorderRadius.circular(8),
// //   //           ),
// //   //           child: pdfLib.Row(
// //   //             mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
// //   //             children: [
// //   //               pdfLib.Text(
// //   //                 'الإجمالي النهائي',
// //   //                 style: pdfLib.TextStyle(
// //   //                   fontSize: 16,
// //   //                   fontWeight: pdfLib.FontWeight.bold,
// //   //                   font: _arabicFont,
// //   //                 ),
// //   //               ),
// //   //               pdfLib.Text(
// //   //                 '${_calculatePdfTotal(expenses).toStringAsFixed(2)} ج',
// //   //                 style: pdfLib.TextStyle(
// //   //                   fontSize: 18,
// //   //                   fontWeight: pdfLib.FontWeight.bold,
// //   //                   font: _arabicFont,
// //   //                   color: PdfColors.blue.shade(900),
// //   //                 ),
// //   //               ),
// //   //             ],
// //   //           ),
// //   //         ),
// //   //       ],
// //   //     ),
// //   //   );
// //   // }

// //   // pdfLib.Widget _buildPdfStatCard(String title, String value, PdfColor color) {
// //   //   return pdfLib.Container(
// //   //     width: 200,
// //   //     padding: const pdfLib.EdgeInsets.all(20),
// //   //     decoration: pdfLib.BoxDecoration(
// //   //       color: color,
// //   //       borderRadius: pdfLib.BorderRadius.circular(10),
// //   //     ),
// //   //     child: pdfLib.Column(
// //   //       children: [
// //   //         pdfLib.Text(
// //   //           title,
// //   //           style: pdfLib.TextStyle(
// //   //             fontSize: 14,
// //   //             font: _arabicFont,
// //   //             color: PdfColors.white,
// //   //           ),
// //   //           textAlign: pdfLib.TextAlign.center,
// //   //         ),
// //   //         pdfLib.SizedBox(height: 10),
// //   //         pdfLib.Text(
// //   //           value,
// //   //           style: pdfLib.TextStyle(
// //   //             fontSize: 24,
// //   //             fontWeight: pdfLib.FontWeight.bold,
// //   //             font: _arabicFont,
// //   //             color: PdfColors.white,
// //   //           ),
// //   //         ),
// //   //       ],
// //   //     ),
// //   //   );
// //   // }

// //   // pdfLib.Widget _buildPdfHeaderCell(String text) {
// //   //   return pdfLib.Padding(
// //   //     padding: const pdfLib.EdgeInsets.all(8),
// //   //     child: pdfLib.Text(
// //   //       text,
// //   //       style: pdfLib.TextStyle(
// //   //         fontSize: 13,
// //   //         fontWeight: pdfLib.FontWeight.bold,
// //   //         font: _arabicFont,
// //   //         color: PdfColors.blue.shade(900),
// //   //       ),
// //   //       textAlign: pdfLib.TextAlign.center,
// //   //     ),
// //   //   );
// //   // }

// //   // pdfLib.Widget _buildPdfDataCell(String text) {
// //   //   return pdfLib.Padding(
// //   //     padding: const pdfLib.EdgeInsets.all(8),
// //   //     child: pdfLib.Text(
// //   //       text,
// //   //       style: pdfLib.TextStyle(fontSize: 12, font: _arabicFont),
// //   //       textAlign: pdfLib.TextAlign.center,
// //   //     ),
// //   //   );
// //   // }

// //   // String _getPDFFilterText() {
// //   //   switch (_timeFilter) {
// //   //     case 'اليوم':
// //   //       return 'تقرير مصروفات اليوم';
// //   //     case 'هذا الشهر':
// //   //       return 'تقرير مصروفات هذا الشهر';
// //   //     case 'هذه السنة':
// //   //       return 'تقرير مصروفات هذه السنة';
// //   //     case 'مخصص':
// //   //       return 'تقرير مصروفات شهر $_selectedMonth سنة $_selectedYear';
// //   //     case 'الكل':
// //   //     default:
// //   //       return 'تقرير المصروفات الكامل';
// //   //   }
// //   // }

// //   // double _calculatePdfTotal(List<Map<String, dynamic>> expenses) {
// //   //   return expenses.fold(0.0, (sum, exp) => sum + (exp['amount'] as double));
// //   // }

// //   // ================= إنشاء PDF =================
// // Future<void> _generatePDF() async {
// //   if (_arabicFont == null) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(content: Text('الخط العربي غير محمل'))
// //     );
// //     return;
// //   }

// //   setState(() => _isGeneratingPDF = true);

// //   try {
// //     // جلب البيانات مع التصفية
// //     final expenses = await _fetchExpensesForPDF();

// //     if (expenses.isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('لا توجد مصروفات للطباعة')),
// //       );
// //       return;
// //     }

// //     // إنشاء PDF
// //     final pdf = pdfLib.Document(
// //       theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
// //     );

// //     // إضافة صفحة واحدة فقط تحتوي على كل شيء
// //     pdf.addPage(
// //       pdfLib.MultiPage(
// //         pageFormat: PdfPageFormat.a4,
// //         margin: pdfLib.EdgeInsets.all(25),
// //         build: (context) => [
// //           _buildPdfHeader(),
// //           pdfLib.SizedBox(height: 10),
// //           _buildPdfDateSection(),
// //           pdfLib.SizedBox(height: 20),
// //           _buildPdfTable(expenses),
// //           pdfLib.SizedBox(height: 20),
// //           _buildPdfTotalSection(expenses),
// //         ],
// //       ),
// //     );

// //     // طباعة PDF
// //     await Printing.layoutPdf(
// //       onLayout: (PdfPageFormat format) async => pdf.save(),
// //       name: 'تقرير_المصروفات_${_getPDFFileName()}',
// //     );
// //   } catch (e) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text('حدث خطأ في إنشاء PDF: $e'))
// //     );
// //   } finally {
// //     setState(() => _isGeneratingPDF = false);
// //   }
// // }

// // // ================= بناء رأس التقرير =================
// // pdfLib.Widget _buildPdfHeader() {
// //   return pdfLib.Directionality(
// //     textDirection: pdfLib.TextDirection.rtl,
// //     child: pdfLib.Column(
// //       crossAxisAlignment: pdfLib.CrossAxisAlignment.center,
// //       children: [
// //         // العنوان الرئيسي
// //         pdfLib.Container(
// //           padding: pdfLib.EdgeInsets.all(15),
// //           decoration: pdfLib.BoxDecoration(
// //             color: PdfColors.blue.shade(900),
// //             borderRadius: pdfLib.BorderRadius.circular(10),
// //           ),
// //           child: pdfLib.Center(
// //             child: pdfLib.Text(
// //               'تقرير المصروفات والنثريات',
// //               style: pdfLib.TextStyle(
// //                 fontSize: 22, // حجم أصغر للوضوح
// //                 fontWeight: pdfLib.FontWeight.bold,
// //                 font: _arabicFont,
// //                 color: PdfColors.white,
// //               ),
// //               textAlign: pdfLib.TextAlign.center,
// //             ),
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// // }

// // // ================= قسم التاريخ =================
// // pdfLib.Widget _buildPdfDateSection() {
// //   return pdfLib.Directionality(
// //     textDirection: pdfLib.TextDirection.rtl,
// //     child: pdfLib.Container(
// //       padding: pdfLib.EdgeInsets.all(12),
// //       decoration: pdfLib.BoxDecoration(
// //         border: pdfLib.Border.all(color: PdfColors.blue.shade(700), width: 1.5),
// //         borderRadius: pdfLib.BorderRadius.circular(8),
// //       ),
// //       child: pdfLib.Row(
// //         mainAxisAlignment: pdfLib.MainAxisAlignment.center,
// //         children: [
// //           pdfLib.Icon(
// //             pdfLib.IconData(0xe192), // رمز التقويم
// //             size: 16,
// //             color: PdfColors.blue.shade(700),
// //           ),
// //           pdfLib.SizedBox(width: 8),
// //           pdfLib.Text(
// //             _getPDFFilterText(),
// //             style: pdfLib.TextStyle(
// //               fontSize: 16, // حجم أصغر
// //               fontWeight: pdfLib.FontWeight.bold,
// //               font: _arabicFont,
// //               color: PdfColors.blue.shade(700),
// //             ),
// //           ),
// //           pdfLib.SizedBox(width: 8),
// //           pdfLib.Text(
// //             'تاريخ الطباعة: ${DateFormat('yyyy/MM/dd - hh:mm a').format(DateTime.now())}',
// //             style: pdfLib.TextStyle(
// //               fontSize: 12, // حجم أصغر
// //               font: _arabicFont,
// //               color: PdfColors.grey.shade(600),
// //             ),
// //           ),
// //         ],
// //       ),
// //     ),
// //   );
// // }

// // // ================= بناء الجدول =================
// // pdfLib.Widget _buildPdfTable(List<Map<String, dynamic>> expenses) {
// //   return pdfLib.Directionality(
// //     textDirection: pdfLib.TextDirection.rtl,
// //     child: pdfLib.Column(
// //       children: [
// //         // عنوان الجدول
// //         pdfLib.Container(
// //           padding: pdfLib.EdgeInsets.all(10),
// //           decoration: pdfLib.BoxDecoration(
// //             color: PdfColors.blue.shade(100),
// //             borderRadius: pdfLib.BorderRadius.only(
// //               topLeft: pdfLib.Radius.circular(8),
// //               topRight: pdfLib.Radius.circular(8),
// //             ),
// //           ),
// //           child: pdfLib.Row(
// //             children: [
// //               pdfLib.Text(
// //                 'تفاصيل المصروفات',
// //                 style: pdfLib.TextStyle(
// //                   fontSize: 16, // حجم أصغر
// //                   fontWeight: pdfLib.FontWeight.bold,
// //                   font: _arabicFont,
// //                   color: PdfColors.blue.shade(900),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),

// //         // الجدول
// //         pdfLib.Table(
// //           border: pdfLib.TableBorder.all(
// //             color: PdfColors.blue.shade(300),
// //             width: 1,
// //           ),
// //           columnWidths: {
// //             // المسلسل - 0.7
// //             0: pdfLib.FlexColumnWidth(0.7),
// //             // التاريخ - 1.2
// //             1: pdfLib.FlexColumnWidth(1.2),
// //             // المبلغ - 1.5
// //             2: pdfLib.FlexColumnWidth(1.5),
// //             // الملاحظات - 4.0 (أوسع للتفاصيل)
// //             3: pdfLib.FlexColumnWidth(4.0),
// //           },
// //           defaultVerticalAlignment: pdfLib.TableCellVerticalAlignment.middle,
// //           children: [
// //             // رأس الجدول
// //             pdfLib.TableRow(
// //               decoration: pdfLib.BoxDecoration(
// //                 color: PdfColors.blue.shade(900),
// //               ),
// //               children: [
// //                 _buildPdfHeaderCell('م', PdfColors.white),
// //                 _buildPdfHeaderCell('التاريخ', PdfColors.white),
// //                 _buildPdfHeaderCell('المبلغ', PdfColors.white),
// //                 _buildPdfHeaderCell('الملاحظات', PdfColors.white),
// //               ],
// //             ),

// //             // بيانات المصروفات
// //             ...expenses.asMap().entries.map((entry) {
// //               int index = entry.key + 1;
// //               Map<String, dynamic> expense = entry.value;

// //               PdfColor rowColor = index.isEven
// //                   ? PdfColors.blue.shade(50)
// //                   : PdfColors.white;

// //               return pdfLib.TableRow(
// //                 decoration: pdfLib.BoxDecoration(color: rowColor),
// //                 children: [
// //                   _buildPdfDataCell(
// //                     index.toString(),
// //                     textAlign: pdfLib.TextAlign.center,
// //                   ),
// //                   _buildPdfDataCell(
// //                     expense['formattedDate']?.toString() ?? '',
// //                     textAlign: pdfLib.TextAlign.center,
// //                   ),
// //                   _buildPdfDataCell(
// //                     '${(expense['amount'] as double).toStringAsFixed(2)} ج',
// //                     textAlign: pdfLib.TextAlign.center,
// //                     textColor: PdfColors.green.shade(700),
// //                   ),
// //                   _buildPdfDataCell(
// //                     expense['note']?.toString().isNotEmpty == true
// //                         ? expense['note'].toString()
// //                         : '-',
// //                     textAlign: pdfLib.TextAlign.right,
// //                   ),
// //                 ],
// //               );
// //             }).toList(),
// //           ],
// //         ),
// //       ],
// //     ),
// //   );
// // }

// // // ================= قسم الإجمالي =================
// // pdfLib.Widget _buildPdfTotalSection(List<Map<String, dynamic>> expenses) {
// //   double total = expenses.fold(
// //     0.0,
// //     (sum, exp) => sum + (exp['amount'] as double),
// //   );

// //   return pdfLib.Directionality(
// //     textDirection: pdfLib.TextDirection.rtl,
// //     child: pdfLib.Container(
// //       padding: pdfLib.EdgeInsets.all(15),
// //       decoration: pdfLib.BoxDecoration(
// //         color: PdfColors.blue.shade(900),
// //         borderRadius: pdfLib.BorderRadius.circular(8),
// //       ),
// //       child: pdfLib.Row(
// //         mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
// //         children: [
// //           pdfLib.Text(
// //             'إجمالي المصروفات',
// //             style: pdfLib.TextStyle(
// //               fontSize: 18, // حجم أصفر
// //               fontWeight: pdfLib.FontWeight.bold,
// //               font: _arabicFont,
// //               color: PdfColors.white,
// //             ),
// //           ),
// //           pdfLib.Text(
// //             '${total.toStringAsFixed(2)} ج',
// //             style: pdfLib.TextStyle(
// //               fontSize: 20, // حجم متوسط
// //               fontWeight: pdfLib.FontWeight.bold,
// //               font: _arabicFont,
// //               color: PdfColors.yellow,
// //             ),
// //           ),
// //         ],
// //       ),
// //     ),
// //   );
// // }

// // // ================= بناء خلية رأس الجدول =================
// // pdfLib.Widget _buildPdfHeaderCell(String text, PdfColor textColor) {
// //   return pdfLib.Container(
// //     padding: pdfLib.EdgeInsets.all(8),
// //     child: pdfLib.Text(
// //       text,
// //       style: pdfLib.TextStyle(
// //         fontSize: 11, // حجم صغير للوضوح
// //         fontWeight: pdfLib.FontWeight.bold,
// //         font: _arabicFont,
// //         color: textColor,
// //       ),
// //       textAlign: pdfLib.TextAlign.center,
// //     ),
// //   );
// // }

// // // ================= بناء خلية بيانات الجدول =================
// // pdfLib.Widget _buildPdfDataCell(
// //   String text, {
// //   pdfLib.TextAlign textAlign = pdfLib.TextAlign.center,
// //   PdfColor textColor = PdfColors.black,
// // }) {
// //   return pdfLib.Container(
// //     padding: pdfLib.EdgeInsets.all(6),
// //     child: pdfLib.Text(
// //       text,
// //       style: pdfLib.TextStyle(
// //         fontSize: 10, // حجم صغير جداً للوضوح
// //         font: _arabicFont,
// //         color: textColor,
// //       ),
// //       textAlign: textAlign,
// //       maxLines: 2,
// //       overflow: pdfLib.TextOverflow.visible,
// //     ),
// //   );
// // }

// // // ================= الحصول على اسم الملف =================
// // String _getPDFFileName() {
// //   final now = DateTime.now();
// //   String filterSuffix = '';

// //   switch (_timeFilter) {
// //     case 'اليوم':
// //       filterSuffix = 'اليوم_${DateFormat('yyyyMMdd').format(now)}';
// //       break;
// //     case 'هذا الشهر':
// //       filterSuffix = 'شهر_${now.month}_${now.year}';
// //       break;
// //     case 'هذه السنة':
// //       filterSuffix = 'سنة_${now.year}';
// //       break;
// //     case 'مخصص':
// //       filterSuffix = 'شهر_${_selectedMonth}_سنة_${_selectedYear}';
// //       break;
// //     default:
// //       filterSuffix = 'الكامل';
// //   }

// //   return 'المصروفات_$filterSuffix';
// // }

// // // ================= الحصول على نص الفلترة =================
// // String _getPDFFilterText() {
// //   final now = DateTime.now();

// //   switch (_timeFilter) {
// //     case 'اليوم':
// //       return 'مصروفات اليوم ${DateFormat('yyyy/MM/dd').format(now)}';
// //     case 'هذا الشهر':
// //       return 'مصروفات شهر ${now.month} سنة ${now.year}';
// //     case 'هذه السنة':
// //       return 'مصروفات سنة ${now.year}';
// //     case 'مخصص':
// //       return 'مصروفات شهر $_selectedMonth سنة $_selectedYear';
// //     case 'الكل':
// //     default:
// //       return 'المصروفات الكاملة';
// //   }
// // }

// //   // ================= فلترة حسب التاريخ =================
// //   List<QueryDocumentSnapshot> _filterExpensesByDate(
// //     List<QueryDocumentSnapshot> allDocs,
// //   ) {
// //     return allDocs.where((doc) {
// //       final data = doc.data() as Map<String, dynamic>;
// //       final date = (data['date'] as Timestamp).toDate();

// //       if (_timeFilter == 'الكل') return true;

// //       final now = DateTime.now();
// //       switch (_timeFilter) {
// //         case 'اليوم':
// //           return date.year == now.year &&
// //               date.month == now.month &&
// //               date.day == now.day;
// //         case 'هذا الشهر':
// //           return date.year == now.year && date.month == now.month;
// //         case 'هذه السنة':
// //           return date.year == now.year;
// //         case 'مخصص':
// //           return date.year == _selectedYear && date.month == _selectedMonth;
// //         default:
// //           return true;
// //       }
// //     }).toList();
// //   }

// //   void _changeTimeFilter(String filter) {
// //     setState(() => _timeFilter = filter);
// //   }

// //   void _applyMonthYearFilter() {
// //     setState(() => _timeFilter = 'مخصص');
// //   }

// //   // ================= AppBar مخصص =================
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
// //             const Icon(Icons.attach_money, color: Colors.white, size: 28),
// //             const SizedBox(width: 12),
// //             const Text(
// //               'المصروفات والنثريات',
// //               style: TextStyle(
// //                 color: Colors.white,
// //                 fontSize: 20,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             const Spacer(),
// //             StreamBuilder<DateTime>(
// //               stream: Stream.periodic(
// //                 const Duration(seconds: 1),
// //                 (_) => DateTime.now(),
// //               ),
// //               builder: (context, snapshot) {
// //                 final now = snapshot.data ?? DateTime.now();
// //                 int hour12 = now.hour % 12;
// //                 if (hour12 == 0) hour12 = 12;
// //                 String period = now.hour < 12 ? 'AM' : 'PM';

// //                 return Column(
// //                   crossAxisAlignment: CrossAxisAlignment.center,
// //                   children: [
// //                     Container(
// //                       height: 50,
// //                       width: 150,
// //                       decoration: BoxDecoration(
// //                         color: Colors.transparent,
// //                         borderRadius: BorderRadius.circular(16),
// //                       ),
// //                       child: Center(
// //                         child: Text(
// //                           '${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period',
// //                           style: const TextStyle(
// //                             color: Colors.white,
// //                             fontSize: 36,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 );
// //               },
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ================= إضافة/تعديل مصروف =================
// //   Future<void> _openExpenseSheet({
// //     String? docId,
// //     Map<String, dynamic>? data,
// //   }) async {
// //     _editingDocId = docId;

// //     if (data != null) {
// //       // وضع التعديل
// //       _titleController.text = data['title'];
// //       _amountController.text = data['amount'].toString();
// //       _noteController.text = data['note'] ?? '';
// //       selectedCategory = data['category'];
// //       selectedDate = (data['date'] as Timestamp).toDate();
// //     } else {
// //       // وضع الإضافة
// //       _titleController.clear();
// //       _amountController.clear();
// //       _noteController.clear();
// //       selectedCategory = "تشغيل";
// //       selectedDate = DateTime.now();
// //     }

// //     await showDialog(
// //       context: context,
// //       builder: (context) {
// //         return AlertDialog(
// //           title: Text(
// //             docId == null ? "إضافة مصروف جديد" : "تعديل المصروف",
// //             style: const TextStyle(fontWeight: FontWeight.bold),
// //           ),
// //           content: SingleChildScrollView(
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 // التاريخ أولاً
// //                 Container(
// //                   padding: const EdgeInsets.all(12),
// //                   decoration: BoxDecoration(
// //                     border: Border.all(color: Colors.grey.shade300),
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       const Icon(
// //                         Icons.calendar_today,
// //                         size: 20,
// //                         color: Colors.blue,
// //                       ),
// //                       const SizedBox(width: 12),
// //                       Expanded(
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             const Text(
// //                               "التاريخ",
// //                               style: TextStyle(
// //                                 fontSize: 12,
// //                                 color: Colors.grey,
// //                               ),
// //                             ),
// //                             Text(
// //                               DateFormat('yyyy/MM/dd').format(selectedDate),
// //                               style: const TextStyle(
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize: 16,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                       IconButton(
// //                         onPressed: () async {
// //                           final DateTime? picked = await showDatePicker(
// //                             context: context,
// //                             initialDate: selectedDate,
// //                             firstDate: DateTime(2000),
// //                             lastDate: DateTime(2100),
// //                           );
// //                           if (picked != null) {
// //                             setState(() {
// //                               selectedDate = picked;
// //                             });
// //                           }
// //                         },
// //                         icon: const Icon(Icons.edit, size: 20),
// //                         style: IconButton.styleFrom(
// //                           backgroundColor: Colors.blue.shade50,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),

// //                 // المبلغ ثانياً
// //                 TextField(
// //                   controller: _amountController,
// //                   keyboardType: TextInputType.number,
// //                   decoration: InputDecoration(
// //                     labelText: "المبلغ",
// //                     prefixText: "ج ",
// //                     prefixIcon: const Icon(
// //                       Icons.attach_money,
// //                       color: Colors.green,
// //                     ),
// //                     border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),

// //                 // القائمة المنسدلة ثالثاً
// //                 DropdownButtonFormField<String>(
// //                   value: selectedCategory,
// //                   decoration: InputDecoration(
// //                     labelText: "التصنيف",
// //                     prefixIcon: const Icon(
// //                       Icons.category,
// //                       color: Colors.purple,
// //                     ),
// //                     border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                   ),
// //                   items: _categories.map((category) {
// //                     return DropdownMenuItem<String>(
// //                       value: category['name'],
// //                       child: Row(
// //                         children: [
// //                           Icon(
// //                             category['icon'],
// //                             color: category['color'],
// //                             size: 20,
// //                           ),
// //                           const SizedBox(width: 12),
// //                           Text(category['name']),
// //                         ],
// //                       ),
// //                     );
// //                   }).toList(),
// //                   onChanged: (value) {
// //                     if (value != null) {
// //                       setState(() {
// //                         selectedCategory = value;
// //                       });
// //                     }
// //                   },
// //                 ),
// //                 const SizedBox(height: 16),

// //                 // الملاحظات رابعاً
// //                 TextField(
// //                   controller: _noteController,
// //                   maxLines: 3,
// //                   decoration: InputDecoration(
// //                     labelText: "ملاحظات",
// //                     prefixIcon: const Icon(Icons.note, color: Colors.orange),
// //                     border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     hintText: "أضف ملاحظات حول المصروف...",
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () {
// //                 Navigator.pop(context);
// //                 _resetForm();
// //               },
// //               child: const Text("إلغاء"),
// //             ),
// //             ElevatedButton(
// //               onPressed: _isLoading
// //                   ? null
// //                   : () async {
// //                       if (_amountController.text.isEmpty) {
// //                         ScaffoldMessenger.of(context).showSnackBar(
// //                           const SnackBar(content: Text("الرجاء إدخال المبلغ")),
// //                         );
// //                         return;
// //                       }

// //                       setState(() {
// //                         _isLoading = true;
// //                       });

// //                       try {
// //                         final expenseData = {
// //                           "title": selectedCategory,
// //                           "amount": double.parse(_amountController.text),
// //                           "category": selectedCategory,
// //                           "note": _noteController.text,
// //                           "date": Timestamp.fromDate(selectedDate),
// //                           "updatedAt": Timestamp.now(),
// //                         };

// //                         if (docId == null) {
// //                           // إضافة جديد
// //                           expenseData["createdAt"] = Timestamp.now();
// //                           await _firestore
// //                               .collection("expenses")
// //                               .add(expenseData);

// //                           ScaffoldMessenger.of(context).showSnackBar(
// //                             const SnackBar(
// //                               content: Text("تم إضافة المصروف بنجاح"),
// //                               backgroundColor: Colors.green,
// //                             ),
// //                           );
// //                         } else {
// //                           // تحديث
// //                           await _firestore
// //                               .collection("expenses")
// //                               .doc(docId)
// //                               .update(expenseData);

// //                           ScaffoldMessenger.of(context).showSnackBar(
// //                             const SnackBar(
// //                               content: Text("تم تحديث المصروف بنجاح"),
// //                               backgroundColor: Colors.blue,
// //                             ),
// //                           );
// //                         }

// //                         Navigator.pop(context);
// //                         _resetForm();
// //                       } catch (e) {
// //                         ScaffoldMessenger.of(context).showSnackBar(
// //                           SnackBar(
// //                             content: Text("حدث خطأ: $e"),
// //                             backgroundColor: Colors.red,
// //                           ),
// //                         );
// //                       } finally {
// //                         setState(() {
// //                           _isLoading = false;
// //                         });
// //                       }
// //                     },
// //               child: _isLoading
// //                   ? const SizedBox(
// //                       width: 20,
// //                       height: 20,
// //                       child: CircularProgressIndicator(strokeWidth: 2),
// //                     )
// //                   : Text(docId == null ? "إضافة" : "تحديث"),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   // ================= حذف مصروف =================
// //   Future<void> _confirmDelete(String docId, String title) async {
// //     return showDialog(
// //       context: context,
// //       builder: (context) {
// //         return AlertDialog(
// //           title: const Text("تأكيد الحذف"),
// //           content: Text("هل أنت متأكد من حذف مصروف '$title'؟"),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.pop(context),
// //               child: const Text("إلغاء"),
// //             ),
// //             ElevatedButton(
// //               onPressed: () async {
// //                 Navigator.pop(context);
// //                 try {
// //                   await _firestore.collection("expenses").doc(docId).delete();
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     const SnackBar(
// //                       content: Text("تم حذف المصروف بنجاح"),
// //                       backgroundColor: Colors.red,
// //                     ),
// //                   );
// //                 } catch (e) {
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     SnackBar(
// //                       content: Text("حدث خطأ أثناء الحذف: $e"),
// //                       backgroundColor: Colors.red,
// //                     ),
// //                   );
// //                 }
// //               },
// //               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
// //               child: const Text("حذف", style: TextStyle(color: Colors.white)),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   // ================= جزء الفلترة =================
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
// //                           if (selected) {
// //                             setState(() => _timeFilter = filter);
// //                           }
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

// //   // ================= إحصائيات =================
// //   Widget _buildStats(List<QueryDocumentSnapshot> docs) {
// //     double total = 0;
// //     Map<String, double> categoryTotals = {};

// //     for (var doc in docs) {
// //       final data = doc.data() as Map<String, dynamic>;
// //       final amount = data['amount'] as double;
// //       final category = data['category'] as String;

// //       total += amount;
// //       categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
// //     }

// //     return Card(
// //       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //       child: Padding(
// //         padding: const EdgeInsets.all(12),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             const Text(
// //               "إحصائيات المصروفات",
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
// //             ),
// //             const SizedBox(height: 8),
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: Container(
// //                     padding: const EdgeInsets.all(12),
// //                     decoration: BoxDecoration(
// //                       color: Colors.blue.shade50,
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: Column(
// //                       children: [
// //                         const Text(
// //                           "المجموع الكلي",
// //                           style: TextStyle(fontSize: 12),
// //                         ),
// //                         const SizedBox(height: 4),
// //                         Text(
// //                           "${total.toStringAsFixed(2)} ج",
// //                           style: const TextStyle(
// //                             fontWeight: FontWeight.bold,
// //                             fontSize: 16,
// //                             color: Colors.blue,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Expanded(
// //                   child: Container(
// //                     padding: const EdgeInsets.all(12),
// //                     decoration: BoxDecoration(
// //                       color: Colors.green.shade50,
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: Column(
// //                       children: [
// //                         const Text(
// //                           "عدد المصروفات",
// //                           style: TextStyle(fontSize: 12),
// //                         ),
// //                         const SizedBox(height: 4),
// //                         Text(
// //                           "${docs.length}",
// //                           style: const TextStyle(
// //                             fontWeight: FontWeight.bold,
// //                             fontSize: 16,
// //                             color: Colors.green,
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

// //   // ================= إعادة تعيين النموذج =================
// //   void _resetForm() {
// //     _titleController.clear();
// //     _amountController.clear();
// //     _noteController.clear();
// //     selectedCategory = "تشغيل";
// //     selectedDate = DateTime.now();
// //     _editingDocId = null;
// //   }

// //   @override
// //   void dispose() {
// //     _titleController.dispose();
// //     _amountController.dispose();
// //     _noteController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF4F6F8),
// //       body: Column(
// //         children: [
// //           // AppBar مخصص
// //           _buildCustomAppBar(),

// //           // جزء الفلترة
// //           _buildTimeFilterSection(),

// //           // المحتوى الرئيسي
// //           Expanded(
// //             child: StreamBuilder<QuerySnapshot>(
// //               stream: _firestore
// //                   .collection("expenses")
// //                   .orderBy('date', descending: true)
// //                   .snapshots(),
// //               builder: (context, snapshot) {
// //                 if (!snapshot.hasData) {
// //                   return const Center(child: CircularProgressIndicator());
// //                 }

// //                 // تطبيق الفلترة حسب التاريخ
// //                 List<QueryDocumentSnapshot> allDocs = snapshot.data!.docs;
// //                 List<QueryDocumentSnapshot> filteredDocs =
// //                     _filterExpensesByDate(allDocs);

// //                 if (snapshot.data!.docs.isEmpty) {
// //                   return Center(
// //                     child: Column(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         const Icon(
// //                           Icons.receipt_long,
// //                           size: 80,
// //                           color: Colors.grey,
// //                         ),
// //                         const SizedBox(height: 16),
// //                         const Text(
// //                           "لا توجد مصروفات",
// //                           style: TextStyle(fontSize: 18, color: Colors.grey),
// //                         ),
// //                         const SizedBox(height: 8),
// //                         Text(
// //                           "انقر على زر + لإضافة أول مصروف",
// //                           style: TextStyle(
// //                             fontSize: 14,
// //                             color: Colors.grey.shade600,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   );
// //                 }

// //                 return Column(
// //                   children: [
// //                     _buildStats(filteredDocs),
// //                     Expanded(
// //                       child: ListView.builder(
// //                         itemCount: filteredDocs.length,
// //                         itemBuilder: (context, index) {
// //                           final doc = filteredDocs[index];
// //                           final data = doc.data() as Map<String, dynamic>;
// //                           final docId = doc.id;
// //                           final date = (data['date'] as Timestamp).toDate();
// //                           final category = _categories.firstWhere(
// //                             (cat) => cat['name'] == data['category'],
// //                             orElse: () => _categories.last,
// //                           );

// //                           return Card(
// //                             margin: const EdgeInsets.symmetric(
// //                               horizontal: 8,
// //                               vertical: 4,
// //                             ),
// //                             child: ListTile(
// //                               leading: CircleAvatar(
// //                                 backgroundColor: category['color'].withOpacity(
// //                                   0.1,
// //                                 ),
// //                                 child: Icon(
// //                                   category['icon'],
// //                                   color: category['color'],
// //                                   size: 20,
// //                                 ),
// //                               ),
// //                               title: Text(
// //                                 "${data['amount'].toStringAsFixed(2)} ج",
// //                                 style: const TextStyle(
// //                                   fontWeight: FontWeight.bold,
// //                                   fontSize: 18,
// //                                   color: Colors.blue,
// //                                 ),
// //                               ),
// //                               subtitle: Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 children: [
// //                                   const SizedBox(height: 4),
// //                                   Text(
// //                                     data['category'],
// //                                     style: TextStyle(
// //                                       fontSize: 14,
// //                                       color: category['color'],
// //                                       fontWeight: FontWeight.bold,
// //                                     ),
// //                                   ),
// //                                   const SizedBox(height: 2),
// //                                   Text(
// //                                     DateFormat('yyyy/MM/dd').format(date),
// //                                     style: const TextStyle(fontSize: 12),
// //                                   ),
// //                                   if (data['note'] != null &&
// //                                       data['note'].isNotEmpty)
// //                                     Padding(
// //                                       padding: const EdgeInsets.only(top: 4),
// //                                       child: Text(
// //                                         data['note'],
// //                                         style: TextStyle(
// //                                           fontSize: 12,
// //                                           color: Colors.grey.shade600,
// //                                         ),
// //                                       ),
// //                                     ),
// //                                 ],
// //                               ),
// //                               trailing: PopupMenuButton<String>(
// //                                 icon: const Icon(Icons.more_vert),
// //                                 onSelected: (value) async {
// //                                   if (value == 'edit') {
// //                                     await _openExpenseSheet(
// //                                       docId: docId,
// //                                       data: data,
// //                                     );
// //                                   } else if (value == 'delete') {
// //                                     await _confirmDelete(docId, data['title']);
// //                                   }
// //                                 },
// //                                 itemBuilder: (BuildContext context) {
// //                                   return [
// //                                     const PopupMenuItem<String>(
// //                                       value: 'edit',
// //                                       child: Row(
// //                                         children: [
// //                                           Icon(Icons.edit, size: 20),
// //                                           SizedBox(width: 8),
// //                                           Text('تعديل'),
// //                                         ],
// //                                       ),
// //                                     ),
// //                                     const PopupMenuItem<String>(
// //                                       value: 'delete',
// //                                       child: Row(
// //                                         children: [
// //                                           Icon(
// //                                             Icons.delete,
// //                                             color: Colors.red,
// //                                             size: 20,
// //                                           ),
// //                                           SizedBox(width: 8),
// //                                           Text(
// //                                             'حذف',
// //                                             style: TextStyle(color: Colors.red),
// //                                           ),
// //                                         ],
// //                                       ),
// //                                     ),
// //                                   ];
// //                                 },
// //                               ),
// //                             ),
// //                           );
// //                         },
// //                       ),
// //                     ),
// //                   ],
// //                 );
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //       floatingActionButton: Row(
// //         mainAxisAlignment: MainAxisAlignment.end,
// //         children: [
// //           // زر PDF
// //           FloatingActionButton(
// //             heroTag: 'pdf_btn',
// //             onPressed: _isGeneratingPDF ? null : _generatePDF,
// //             backgroundColor: _isGeneratingPDF ? Colors.grey : Colors.red,
// //             mini: true,
// //             child: _isGeneratingPDF
// //                 ? const CircularProgressIndicator(color: Colors.white)
// //                 : const Icon(Icons.picture_as_pdf, color: Colors.white),
// //           ),
// //           const SizedBox(width: 10),
// //           // زر إضافة مصروف
// //           FloatingActionButton.extended(
// //             onPressed: () => _openExpenseSheet(),
// //             icon: const Icon(Icons.add),
// //             label: const Text("إضافة مصروف"),
// //             backgroundColor: const Color(0xFF3498DB),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pdfLib;
// import 'package:printing/printing.dart';

// class ExpensesPage extends StatefulWidget {
//   const ExpensesPage({super.key});

//   @override
//   State<ExpensesPage> createState() => _ExpensesPageState();
// }

// class _ExpensesPageState extends State<ExpensesPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _noteController = TextEditingController();

//   String selectedCategory = "تشغيل";
//   DateTime selectedDate = DateTime.now();
//   bool _isLoading = false;
//   bool _isGeneratingPDF = false;
//   String? _editingDocId;

//   // التصنيفات
//   final List<Map<String, dynamic>> _categories = [
//     {"name": "تشغيل", "color": Colors.blue, "icon": Icons.business},
//     {"name": "مواصلات", "color": Colors.green, "icon": Icons.directions_car},
//     {"name": "أدوات", "color": Colors.orange, "icon": Icons.build},
//     {"name": "طعام", "color": Colors.red, "icon": Icons.restaurant},
//     {"name": "أخرى", "color": Colors.grey, "icon": Icons.more_horiz},
//   ];

//   // ================= فلترة =================
//   int _selectedMonth = DateTime.now().month;
//   int _selectedYear = DateTime.now().year;
//   String _timeFilter = 'الكل';

//   // ================= PDF Generator =================
//   pdfLib.Font? _arabicFont;

//   @override
//   void initState() {
//     super.initState();
//     selectedCategory = "تشغيل";
//     _resetForm();
//     _loadArabicFont();
//   }
//   //////////////////////////////////////////////////////////////////////////////
//   // Future<void> _loadArabicFont() async {
//   //   try {
//   //     final fontData = await rootBundle.load(
//   //       'assets/fonts/Amiri/Amiri-Regular.ttf',
//   //     );

//   //     _arabicFont = pdfLib.Font.ttf(fontData);
//   //     debugPrint('تم تحميل الخط العربي بنجاح');
//   //   } catch (e) {
//   //     debugPrint('فشل تحميل الخط العربي: $e');
//   //   }
//   // }

//   // // ================= إنشاء PDF =================
//   // Future<void> _generatePDF() async {
//   //   if (_arabicFont == null) {
//   //     ScaffoldMessenger.of(
//   //       context,
//   //     ).showSnackBar(const SnackBar(content: Text('الخط العربي غير محمل')));
//   //     return;
//   //   }

//   //   setState(() => _isGeneratingPDF = true);

//   //   try {
//   //     // جلب البيانات مع التصفية
//   //     final expenses = await _fetchExpensesForPDF();

//   //     if (expenses.isEmpty) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(content: Text('لا توجد مصروفات للطباعة')),
//   //       );
//   //       return;
//   //     }

//   //     // إنشاء PDF
//   //     final pdf = pdfLib.Document(
//   //       theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
//   //     );

//   //     // إضافة صفحة واحدة فقط تحتوي على كل شيء
//   //     pdf.addPage(
//   //       pdfLib.MultiPage(
//   //         pageFormat: PdfPageFormat.a4,
//   //         margin: pdfLib.EdgeInsets.all(25),
//   //         build: (context) => [
//   //           _buildPdfHeader(),
//   //           pdfLib.SizedBox(height: 10),
//   //           _buildPdfDateSection(),
//   //           pdfLib.SizedBox(height: 20),
//   //           _buildPdfTable(expenses),
//   //           pdfLib.SizedBox(height: 20),
//   //           _buildPdfTotalSection(expenses),
//   //         ],
//   //       ),
//   //     );

//   //     // طباعة PDF
//   //     await Printing.layoutPdf(
//   //       onLayout: (PdfPageFormat format) async => pdf.save(),
//   //       name: 'تقرير_المصروفات_${_getPDFFileName()}',
//   //     );
//   //   } catch (e) {
//   //     ScaffoldMessenger.of(
//   //       context,
//   //     ).showSnackBar(SnackBar(content: Text('حدث خطأ في إنشاء PDF: $e')));
//   //   } finally {
//   //     setState(() => _isGeneratingPDF = false);
//   //   }
//   // }

//   // Future<List<Map<String, dynamic>>> _fetchExpensesForPDF() async {
//   //   try {
//   //     Query query = _firestore
//   //         .collection("expenses")
//   //         .orderBy('date', descending: true);

//   //     final snapshot = await query.get();
//   //     List<Map<String, dynamic>> filteredExpenses = [];

//   //     for (var doc in snapshot.docs) {
//   //       final data = doc.data() as Map<String, dynamic>;
//   //       final date = (data['date'] as Timestamp).toDate();
//   //       final docId = doc.id;

//   //       // تطبيق الفلترة
//   //       if (_applyPDFFilter(date)) {
//   //         filteredExpenses.add({
//   //           'id': docId,
//   //           'title': data['title'] ?? '',
//   //           'amount': data['amount'] ?? 0.0,
//   //           'category': data['category'] ?? 'أخرى',
//   //           'note': data['note'] ?? '',
//   //           'date': date,
//   //           'formattedDate': DateFormat('yyyy/MM/dd').format(date),
//   //         });
//   //       }
//   //     }

//   //     return filteredExpenses;
//   //   } catch (e) {
//   //     debugPrint('خطأ في جلب المصروفات للPDF: $e');
//   //     return [];
//   //   }
//   // }

//   // bool _applyPDFFilter(DateTime date) {
//   //   final now = DateTime.now();

//   //   switch (_timeFilter) {
//   //     case 'اليوم':
//   //       return date.year == now.year &&
//   //           date.month == now.month &&
//   //           date.day == now.day;
//   //     case 'هذا الشهر':
//   //       return date.year == now.year && date.month == now.month;
//   //     case 'هذه السنة':
//   //       return date.year == now.year;
//   //     case 'مخصص':
//   //       return date.month == _selectedMonth && date.year == _selectedYear;
//   //     case 'الكل':
//   //     default:
//   //       return true;
//   //   }
//   // }

//   // // ================= بناء رأس التقرير =================
//   // pdfLib.Widget _buildPdfHeader() {
//   //   return pdfLib.Directionality(
//   //     textDirection: pdfLib.TextDirection.rtl,
//   //     child: pdfLib.Column(
//   //       crossAxisAlignment: pdfLib.CrossAxisAlignment.center,
//   //       children: [
//   //         // العنوان الرئيسي
//   //         pdfLib.Container(
//   //           padding: pdfLib.EdgeInsets.all(15),
//   //           decoration: pdfLib.BoxDecoration(
//   //             color: PdfColors.blue.shade(900),
//   //             borderRadius: pdfLib.BorderRadius.circular(10),
//   //           ),
//   //           child: pdfLib.Center(
//   //             child: pdfLib.Text(
//   //               'تقرير المصروفات والنثريات',
//   //               style: pdfLib.TextStyle(
//   //                 fontSize: 22,
//   //                 fontWeight: pdfLib.FontWeight.bold,
//   //                 font: _arabicFont,
//   //                 color: PdfColors.white,
//   //               ),
//   //               textAlign: pdfLib.TextAlign.center,
//   //             ),
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   // // ================= قسم التاريخ =================
//   // pdfLib.Widget _buildPdfDateSection() {
//   //   return pdfLib.Directionality(
//   //     textDirection: pdfLib.TextDirection.rtl,
//   //     child: pdfLib.Container(
//   //       padding: pdfLib.EdgeInsets.all(12),
//   //       decoration: pdfLib.BoxDecoration(
//   //         border: pdfLib.Border.all(
//   //           color: PdfColors.blue.shade(700),
//   //           width: 1.5,
//   //         ),
//   //         borderRadius: pdfLib.BorderRadius.circular(8),
//   //       ),
//   //       child: pdfLib.Row(
//   //         mainAxisAlignment: pdfLib.MainAxisAlignment.center,
//   //         children: [
//   //           pdfLib.Icon(
//   //             pdfLib.IconData(0xe192), // رمز التقويم
//   //             size: 16,
//   //             color: PdfColors.blue.shade(700),
//   //           ),
//   //           pdfLib.SizedBox(width: 8),
//   //           pdfLib.Text(
//   //             _getPDFFilterText(),
//   //             style: pdfLib.TextStyle(
//   //               fontSize: 16,
//   //               fontWeight: pdfLib.FontWeight.bold,
//   //               font: _arabicFont,
//   //               color: PdfColors.blue.shade(700),
//   //             ),
//   //           ),
//   //           pdfLib.SizedBox(width: 8),
//   //           pdfLib.Text(
//   //             'تاريخ الطباعة: ${DateFormat('yyyy/MM/dd - hh:mm a').format(DateTime.now())}',
//   //             style: pdfLib.TextStyle(
//   //               fontSize: 12,
//   //               font: _arabicFont,
//   //               color: PdfColors.grey.shade(600),
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }

//   // // ================= بناء الجدول =================
//   // pdfLib.Widget _buildPdfTable(List<Map<String, dynamic>> expenses) {
//   //   return pdfLib.Directionality(
//   //     textDirection: pdfLib.TextDirection.rtl,
//   //     child: pdfLib.Column(
//   //       children: [
//   //         // عنوان الجدول
//   //         pdfLib.Container(
//   //           padding: pdfLib.EdgeInsets.all(10),
//   //           decoration: pdfLib.BoxDecoration(
//   //             color: PdfColors.blue.shade(100),
//   //             borderRadius: pdfLib.BorderRadius.only(
//   //               topLeft: pdfLib.Radius.circular(8),
//   //               topRight: pdfLib.Radius.circular(8),
//   //             ),
//   //           ),
//   //           child: pdfLib.Row(
//   //             children: [
//   //               pdfLib.Text(
//   //                 'تفاصيل المصروفات',
//   //                 style: pdfLib.TextStyle(
//   //                   fontSize: 16,
//   //                   fontWeight: pdfLib.FontWeight.bold,
//   //                   font: _arabicFont,
//   //                   color: PdfColors.blue.shade(900),
//   //                 ),
//   //               ),
//   //             ],
//   //           ),
//   //         ),

//   //         // الجدول
//   //         pdfLib.Table(
//   //           border: pdfLib.TableBorder.all(
//   //             color: PdfColors.blue.shade(300),
//   //             width: 1,
//   //           ),
//   //           columnWidths: {
//   //             // المسلسل - 0.7
//   //             0: pdfLib.FlexColumnWidth(0.7),
//   //             // التاريخ - 1.2
//   //             1: pdfLib.FlexColumnWidth(1.2),
//   //             // المبلغ - 1.5
//   //             2: pdfLib.FlexColumnWidth(1.5),
//   //             // الملاحظات - 4.0 (أوسع للتفاصيل)
//   //             3: pdfLib.FlexColumnWidth(4.0),
//   //           },
//   //           defaultVerticalAlignment: pdfLib.TableCellVerticalAlignment.middle,
//   //           children: [
//   //             // رأس الجدول
//   //             pdfLib.TableRow(
//   //               decoration: pdfLib.BoxDecoration(
//   //                 color: PdfColors.blue.shade(900),
//   //               ),
//   //               children: [
//   //                 _buildPdfHeaderCell('م', PdfColors.white),
//   //                 _buildPdfHeaderCell('التاريخ', PdfColors.white),
//   //                 _buildPdfHeaderCell('المبلغ', PdfColors.white),
//   //                 _buildPdfHeaderCell('الملاحظات', PdfColors.white),
//   //               ],
//   //             ),

//   //             // بيانات المصروفات
//   //             ...expenses.asMap().entries.map((entry) {
//   //               int index = entry.key + 1;
//   //               Map<String, dynamic> expense = entry.value;

//   //               PdfColor rowColor = index.isEven
//   //                   ? PdfColors.blue.shade(50)
//   //                   : PdfColors.white;

//   //               return pdfLib.TableRow(
//   //                 decoration: pdfLib.BoxDecoration(color: rowColor),
//   //                 children: [
//   //                   _buildPdfDataCell(
//   //                     index.toString(),
//   //                     textAlign: pdfLib.TextAlign.center,
//   //                   ),
//   //                   _buildPdfDataCell(
//   //                     expense['formattedDate']?.toString() ?? '',
//   //                     textAlign: pdfLib.TextAlign.center,
//   //                   ),
//   //                   _buildPdfDataCell(
//   //                     '${(expense['amount'] as double).toStringAsFixed(2)} ج',
//   //                     textAlign: pdfLib.TextAlign.center,
//   //                     textColor: PdfColors.green.shade(700),
//   //                   ),
//   //                   _buildPdfDataCell(
//   //                     expense['note']?.toString().isNotEmpty == true
//   //                         ? expense['note'].toString()
//   //                         : '-',
//   //                     textAlign: pdfLib.TextAlign.right,
//   //                   ),
//   //                 ],
//   //               );
//   //             }).toList(),
//   //           ],
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   // // ================= قسم الإجمالي =================
//   // pdfLib.Widget _buildPdfTotalSection(List<Map<String, dynamic>> expenses) {
//   //   double total = expenses.fold(
//   //     0.0,
//   //     (sum, exp) => sum + (exp['amount'] as double),
//   //   );

//   //   return pdfLib.Directionality(
//   //     textDirection: pdfLib.TextDirection.rtl,
//   //     child: pdfLib.Container(
//   //       padding: pdfLib.EdgeInsets.all(15),
//   //       decoration: pdfLib.BoxDecoration(
//   //         color: PdfColors.blue.shade(900),
//   //         borderRadius: pdfLib.BorderRadius.circular(8),
//   //       ),
//   //       child: pdfLib.Row(
//   //         mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
//   //         children: [
//   //           pdfLib.Text(
//   //             'إجمالي المصروفات',
//   //             style: pdfLib.TextStyle(
//   //               fontSize: 18,
//   //               fontWeight: pdfLib.FontWeight.bold,
//   //               font: _arabicFont,
//   //               color: PdfColors.white,
//   //             ),
//   //           ),
//   //           pdfLib.Text(
//   //             '${total.toStringAsFixed(2)} ج',
//   //             style: pdfLib.TextStyle(
//   //               fontSize: 20,
//   //               fontWeight: pdfLib.FontWeight.bold,
//   //               font: _arabicFont,
//   //               color: PdfColors.yellow,
//   //             ),
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }

//   // // ================= بناء خلية رأس الجدول =================
//   // pdfLib.Widget _buildPdfHeaderCell(String text, PdfColor textColor) {
//   //   return pdfLib.Container(
//   //     padding: pdfLib.EdgeInsets.all(8),
//   //     child: pdfLib.Text(
//   //       text,
//   //       style: pdfLib.TextStyle(
//   //         fontSize: 11,
//   //         fontWeight: pdfLib.FontWeight.bold,
//   //         font: _arabicFont,
//   //         color: textColor,
//   //       ),
//   //       textAlign: pdfLib.TextAlign.center,
//   //     ),
//   //   );
//   // }

//   // // ================= بناء خلية بيانات الجدول =================
//   // pdfLib.Widget _buildPdfDataCell(
//   //   String text, {
//   //   pdfLib.TextAlign textAlign = pdfLib.TextAlign.center,
//   //   PdfColor textColor = PdfColors.black,
//   // }) {
//   //   return pdfLib.Container(
//   //     padding: pdfLib.EdgeInsets.all(6),
//   //     child: pdfLib.Text(
//   //       text,
//   //       style: pdfLib.TextStyle(
//   //         fontSize: 10,
//   //         font: _arabicFont,
//   //         color: textColor,
//   //       ),
//   //       textAlign: textAlign,
//   //       maxLines: 2,
//   //       overflow: pdfLib.TextOverflow.span,
//   //     ),
//   //   );
//   // }

//   // // ================= الحصول على اسم الملف =================
//   // String _getPDFFileName() {
//   //   final now = DateTime.now();
//   //   String filterSuffix = '';

//   //   switch (_timeFilter) {
//   //     case 'اليوم':
//   //       filterSuffix = 'اليوم_${DateFormat('yyyyMMdd').format(now)}';
//   //       break;
//   //     case 'هذا الشهر':
//   //       filterSuffix = 'شهر_${now.month}_${now.year}';
//   //       break;
//   //     case 'هذه السنة':
//   //       filterSuffix = 'سنة_${now.year}';
//   //       break;
//   //     case 'مخصص':
//   //       filterSuffix = 'شهر_${_selectedMonth}_سنة_${_selectedYear}';
//   //       break;
//   //     default:
//   //       filterSuffix = 'الكامل';
//   //   }

//   //   return 'المصروفات_$filterSuffix';
//   // }

//   // // ================= الحصول على نص الفلترة =================
//   // String _getPDFFilterText() {
//   //   final now = DateTime.now();

//   //   switch (_timeFilter) {
//   //     case 'اليوم':
//   //       return 'مصروفات اليوم ${DateFormat('yyyy/MM/dd').format(now)}';
//   //     case 'هذا الشهر':
//   //       return 'مصروفات شهر ${now.month} سنة ${now.year}';
//   //     case 'هذه السنة':
//   //       return 'مصروفات سنة ${now.year}';
//   //     case 'مخصص':
//   //       return 'مصروفات شهر $_selectedMonth سنة $_selectedYear';
//   //     case 'الكل':
//   //     default:
//   //       return 'المصروفات الكاملة';
//   //   }
//   // }

// //   Future<void> _loadArabicFont() async {
// //     try {
// //       final fontData = await rootBundle.load(
// //         'assets/fonts/Amiri/Amiri-Regular.ttf',
// //       );

// //       _arabicFont = pdfLib.Font.ttf(fontData);
// //       debugPrint('تم تحميل الخط العربي بنجاح');
// //     } catch (e) {
// //       debugPrint('فشل تحميل الخط العربي: $e');
// //     }
// //   }

// //   // ================= إنشاء PDF =================
// //   Future<void> _generatePDF() async {
// //     if (_arabicFont == null) {
// //       ScaffoldMessenger.of(
// //         context,
// //       ).showSnackBar(const SnackBar(content: Text('الخط العربي غير محمل')));
// //       return;
// //     }

// //     setState(() => _isGeneratingPDF = true);

// //     try {
// //       // جلب البيانات مع التصفية
// //       final expenses = await _fetchExpensesForPDF();

// //       if (expenses.isEmpty) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('لا توجد مصروفات للطباعة')),
// //         );
// //         return;
// //       }

// //       // إنشاء PDF
// //       final pdf = pdfLib.Document(
// //         theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
// //       );

// //       // إضافة صفحة واحدة فقط تحتوي على كل شيء
// //       pdf.addPage(
// //         pdfLib.MultiPage(
// //           pageFormat: PdfPageFormat.a4,
// //           margin: pdfLib.EdgeInsets.all(25),
// //           build: (context) => [
// //             _buildPdfHeader(),
// //             pdfLib.SizedBox(height: 15),
// //             _buildPdfTitle(),
// //             pdfLib.SizedBox(height: 25),
// //             _buildPdfTable(expenses),
// //             pdfLib.SizedBox(height: 20),
// //             _buildPdfTotalSection(expenses),
// //           ],
// //         ),
// //       );

// //       // طباعة PDF
// //       await Printing.layoutPdf(
// //         onLayout: (PdfPageFormat format) async => pdf.save(),
// //         name: 'المصروفات_${_getPDFFileName()}',
// //       );
// //     } catch (e) {
// //       ScaffoldMessenger.of(
// //         context,
// //       ).showSnackBar(SnackBar(content: Text('حدث خطأ في إنشاء PDF: $e')));
// //     } finally {
// //       setState(() => _isGeneratingPDF = false);
// //     }
// //   }

// //   Future<List<Map<String, dynamic>>> _fetchExpensesForPDF() async {
// //     try {
// //       Query query = _firestore
// //           .collection("expenses")
// //           .orderBy('date', descending: true);

// //       final snapshot = await query.get();
// //       List<Map<String, dynamic>> filteredExpenses = [];

// //       for (var doc in snapshot.docs) {
// //         final data = doc.data() as Map<String, dynamic>;
// //         final date = (data['date'] as Timestamp).toDate();
// //         final docId = doc.id;

// //         // تطبيق الفلترة
// //         if (_applyPDFFilter(date)) {
// //           filteredExpenses.add({
// //             'id': docId,
// //             'title': data['title'] ?? '',
// //             'amount': data['amount'] ?? 0.0,
// //             'category': data['category'] ?? 'أخرى',
// //             'note': data['note'] ?? '',
// //             'date': date,
// //             'formattedDate': DateFormat('yyyy/MM/dd').format(date),
// //           });
// //         }
// //       }

// //       return filteredExpenses;
// //     } catch (e) {
// //       debugPrint('خطأ في جلب المصروفات للPDF: $e');
// //       return [];
// //     }
// //   }

// //   bool _applyPDFFilter(DateTime date) {
// //     final now = DateTime.now();

// //     switch (_timeFilter) {
// //       case 'اليوم':
// //         return date.year == now.year &&
// //             date.month == now.month &&
// //             date.day == now.day;
// //       case 'هذا الشهر':
// //         return date.year == now.year && date.month == now.month;
// //       case 'هذه السنة':
// //         return date.year == now.year;
// //       case 'مخصص':
// //         return date.month == _selectedMonth && date.year == _selectedYear;
// //       case 'الكل':
// //       default:
// //         return true;
// //     }
// //   }

// //   // ================= بناء رأس التقرير =================
// //   pdfLib.Widget _buildPdfHeader() {
// //     return pdfLib.Directionality(
// //       textDirection: pdfLib.TextDirection.rtl,
// //       child: pdfLib.Column(
// //         crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
// //         children: [
// //           pdfLib.Row(
// //             mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
// //             children: [
// //               pdfLib.Text(
// //                 'FN 454.4 - 203/317/21',
// //                 style: pdfLib.TextStyle(
// //                   fontSize: 14,
// //                   fontWeight: pdfLib.FontWeight.bold,
// //                   font: _arabicFont,
// //                   color: PdfColors.black,
// //                 ),
// //               ),
// //               pdfLib.Text(
// //                 'المصروفات والنثريات',
// //                 style: pdfLib.TextStyle(
// //                   fontSize: 20,
// //                   fontWeight: pdfLib.FontWeight.bold,
// //                   font: _arabicFont,
// //                   color: PdfColors.black,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           pdfLib.Divider(color: PdfColors.black, thickness: 2),
// //         ],
// //       ),
// //     );
// //   }

// //   // ================= بناء عنوان التقرير =================
// //   pdfLib.Widget _buildPdfTitle() {
// //     return pdfLib.Directionality(
// //       textDirection: pdfLib.TextDirection.rtl,
// //       child: pdfLib.Column(
// //         crossAxisAlignment: pdfLib.CrossAxisAlignment.center,
// //         children: [
// //           pdfLib.Text(
// //             'المصروفات الكاملة لشهر $_selectedMonth',
// //             style: pdfLib.TextStyle(
// //               fontSize: 18,
// //               fontWeight: pdfLib.FontWeight.bold,
// //               font: _arabicFont,
// //               color: PdfColors.black,
// //             ),
// //             textAlign: pdfLib.TextAlign.center,
// //           ),
// //           pdfLib.SizedBox(height: 10),
// //           pdfLib.Text(
// //             'تاريخ الطباعة: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}',
// //             style: pdfLib.TextStyle(
// //               fontSize: 14,
// //               font: _arabicFont,
// //               color: PdfColors.black,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ================= بناء الجدول =================
// //   pdfLib.Widget _buildPdfTable(List<Map<String, dynamic>> expenses) {
// //     return pdfLib.Directionality(
// //       textDirection: pdfLib.TextDirection.rtl,
// //       child: pdfLib.Column(
// //         children: [
// //           // الجدول
// //           pdfLib.Table(
// //             border: pdfLib.TableBorder.all(color: PdfColors.black, width: 1.5),
// //             columnWidths: {
// //               // المسلسل - 0.7 (من اليمين)
// //               4: pdfLib.FlexColumnWidth(0.7),
// //               // التاريخ - 1.5
// //               3: pdfLib.FlexColumnWidth(1.5),
// //               // المبلغ - 1.5
// //               2: pdfLib.FlexColumnWidth(1.5),
// //               // النوع - 2.0
// //               1: pdfLib.FlexColumnWidth(2.0),
// //               // الملاحظات - 3.0
// //               0: pdfLib.FlexColumnWidth(3.0),
// //             },
// //             defaultVerticalAlignment: pdfLib.TableCellVerticalAlignment.middle,
// //             children: [
// //               // رأس الجدول
// //               pdfLib.TableRow(
// //                 children: [
// //                   _buildPdfHeaderCell('الملاحظات'),
// //                   _buildPdfHeaderCell('النوع'),

// //                   _buildPdfHeaderCell('المبلغ'),
// //                   _buildPdfHeaderCell('التاريخ'),

// //                   _buildPdfHeaderCell('م'),
// //                 ],
// //               ),

// //               // بيانات المصروفات
// //               ...expenses.asMap().entries.map((entry) {
// //                 int index = entry.key + 1;
// //                 Map<String, dynamic> expense = entry.value;

// //                 return pdfLib.TableRow(
// //                   children: [
// //                     _buildPdfDataCell(
// //                       expense['note']?.toString().isNotEmpty == true
// //                           ? expense['note'].toString()
// //                           : '-',
// //                       textAlign: pdfLib.TextAlign.right,
// //                     ),
// //                     _buildPdfDataCell(
// //                       expense['category']?.toString() ?? 'أخرى',
// //                       textAlign: pdfLib.TextAlign.center,
// //                     ),

// //                     _buildPdfDataCell(
// //                       '${(expense['amount'] as double).toStringAsFixed(2)}',
// //                       textAlign: pdfLib.TextAlign.center,
// //                       isAmount: true,
// //                     ),

// //                     _buildPdfDataCell(
// //                       expense['formattedDate']?.toString() ?? '',
// //                       textAlign: pdfLib.TextAlign.center,
// //                     ),
// //                     _buildPdfDataCell(
// //                       index.toString(),
// //                       textAlign: pdfLib.TextAlign.center,
// //                     ),
// //                   ],
// //                 );
// //               }).toList(),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // ================= قسم الإجمالي =================
// //   pdfLib.Widget _buildPdfTotalSection(List<Map<String, dynamic>> expenses) {
// //     double total = expenses.fold(
// //       0.0,
// //       (sum, exp) => sum + (exp['amount'] as double),
// //     );

// //     return pdfLib.Directionality(
// //       textDirection: pdfLib.TextDirection.rtl,
// //       child: pdfLib.Container(
// //         padding: pdfLib.EdgeInsets.all(12),
// //         decoration: pdfLib.BoxDecoration(
// //           border: pdfLib.Border.all(color: PdfColors.black, width: 2),
// //         ),
// //         child: pdfLib.Row(
// //           mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
// //           children: [
// //             pdfLib.Text(
// //               'إجمالي المصروفات',
// //               style: pdfLib.TextStyle(
// //                 fontSize: 18,
// //                 fontWeight: pdfLib.FontWeight.bold,
// //                 font: _arabicFont,
// //                 color: PdfColors.black,
// //               ),
// //             ),
// //             pdfLib.Text(
// //               '${total.toStringAsFixed(2)} ج',
// //               style: pdfLib.TextStyle(
// //                 fontSize: 20,
// //                 fontWeight: pdfLib.FontWeight.bold,
// //                 font: _arabicFont,
// //                 color: PdfColors.black,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ================= بناء خلية رأس الجدول =================
// //   pdfLib.Widget _buildPdfHeaderCell(String text) {
// //     return pdfLib.Container(
// //       padding: pdfLib.EdgeInsets.all(10),
// //       child: pdfLib.Text(
// //         text,
// //         style: pdfLib.TextStyle(
// //           fontSize: 14,
// //           fontWeight: pdfLib.FontWeight.bold,
// //           font: _arabicFont,
// //           color: PdfColors.black,
// //         ),
// //         textAlign: pdfLib.TextAlign.center,
// //       ),
// //     );
// //   }

// //   // ================= بناء خلية بيانات الجدول =================
// //   pdfLib.Widget _buildPdfDataCell(
// //     String text, {
// //     pdfLib.TextAlign textAlign = pdfLib.TextAlign.center,
// //     bool isAmount = false,
// //   }) {
// //     return pdfLib.Container(
// //       padding: pdfLib.EdgeInsets.all(8),
// //       child: pdfLib.Text(
// //         text,
// //         style: pdfLib.TextStyle(
// //           fontSize: 13,
// //           fontWeight: isAmount
// //               ? pdfLib.FontWeight.bold
// //               : pdfLib.FontWeight.normal,
// //           font: _arabicFont,
// //           color: PdfColors.black,
// //         ),
// //         textAlign: textAlign,
// //         maxLines: 2,
// //       ),
// //     );
// //   }

// //   // ================= الحصول على اسم الملف =================
// //   String _getPDFFileName() {
// //     final now = DateTime.now();
// //     String filterSuffix = '';

// //     switch (_timeFilter) {
// //       case 'اليوم':
// //         filterSuffix = 'اليوم_${DateFormat('yyyyMMdd').format(now)}';
// //         break;
// //       case 'هذا الشهر':
// //         filterSuffix = 'شهر_${now.month}_${now.year}';
// //         break;
// //       case 'هذه السنة':
// //         filterSuffix = 'سنة_${now.year}';
// //         break;
// //       case 'مخصص':
// //         filterSuffix = 'شهر_${_selectedMonth}_سنة_${_selectedYear}';
// //         break;
// //       default:
// //         filterSuffix = 'الكامل';
// //     }

// //     return 'المصروفات_$filterSuffix';
// //   }

// //   // ================= الحصول على نص الفلترة =================
// //   String _getPDFFilterText() {
// //     final now = DateTime.now();

// //     switch (_timeFilter) {
// //       case 'اليوم':
// //         return 'مصروفات اليوم ${DateFormat('yyyy/MM/dd').format(now)}';
// //       case 'هذا الشهر':
// //         return 'مصروفات شهر ${now.month} سنة ${now.year}';
// //       case 'هذه السنة':
// //         return 'مصروفات سنة ${now.year}';
// //       case 'مخصص':
// //         return 'مصروفات شهر $_selectedMonth سنة $_selectedYear';
// //       case 'الكل':
// //       default:
// //         return 'المصروفات الكاملة';
// //     }
// //   }

// //   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// //   // ================= فلترة حسب التاريخ =================
// //   List<QueryDocumentSnapshot> _filterExpensesByDate(
// //     List<QueryDocumentSnapshot> allDocs,
// //   ) {
// //     return allDocs.where((doc) {
// //       final data = doc.data() as Map<String, dynamic>;
// //       final date = (data['date'] as Timestamp).toDate();

// //       if (_timeFilter == 'الكل') return true;

// //       final now = DateTime.now();
// //       switch (_timeFilter) {
// //         case 'اليوم':
// //           return date.year == now.year &&
// //               date.month == now.month &&
// //               date.day == now.day;
// //         case 'هذا الشهر':
// //           return date.year == now.year && date.month == now.month;
// //         case 'هذه السنة':
// //           return date.year == now.year;
// //         case 'مخصص':
// //           return date.year == _selectedYear && date.month == _selectedMonth;
// //         default:
// //           return true;
// //       }
// //     }).toList();
// //   }

// //   void _changeTimeFilter(String filter) {
// //     setState(() => _timeFilter = filter);
// //   }

// //   void _applyMonthYearFilter() {
// //     setState(() => _timeFilter = 'مخصص');
// //   }

// //   // ================= AppBar مخصص =================
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
// //             const Icon(Icons.attach_money, color: Colors.white, size: 28),
// //             const SizedBox(width: 12),
// //             const Text(
// //               'المصروفات والنثريات',
// //               style: TextStyle(
// //                 color: Colors.white,
// //                 fontSize: 20,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             const Spacer(),
// //             StreamBuilder<DateTime>(
// //               stream: Stream.periodic(
// //                 const Duration(seconds: 1),
// //                 (_) => DateTime.now(),
// //               ),
// //               builder: (context, snapshot) {
// //                 final now = snapshot.data ?? DateTime.now();
// //                 int hour12 = now.hour % 12;
// //                 if (hour12 == 0) hour12 = 12;
// //                 String period = now.hour < 12 ? 'AM' : 'PM';

// //                 return Column(
// //                   crossAxisAlignment: CrossAxisAlignment.center,
// //                   children: [
// //                     Container(
// //                       height: 50,
// //                       width: 150,
// //                       decoration: BoxDecoration(
// //                         color: Colors.transparent,
// //                         borderRadius: BorderRadius.circular(16),
// //                       ),
// //                       child: Center(
// //                         child: Text(
// //                           '${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period',
// //                           style: const TextStyle(
// //                             color: Colors.white,
// //                             fontSize: 36,
// //                             fontWeight: FontWeight.bold,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 );
// //               },
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // ================= إضافة/تعديل مصروف =================
// //   Future<void> _openExpenseSheet({
// //     String? docId,
// //     Map<String, dynamic>? data,
// //   }) async {
// //     _editingDocId = docId;

// //     if (data != null) {
// //       // وضع التعديل
// //       _titleController.text = data['title'];
// //       _amountController.text = data['amount'].toString();
// //       _noteController.text = data['note'] ?? '';
// //       selectedCategory = data['category'];
// //       selectedDate = (data['date'] as Timestamp).toDate();
// //     } else {
// //       // وضع الإضافة
// //       _titleController.clear();
// //       _amountController.clear();
// //       _noteController.clear();
// //       selectedCategory = "تشغيل";
// //       selectedDate = DateTime.now();
// //     }

// //     await showDialog(
// //       context: context,
// //       builder: (context) {
// //         return AlertDialog(
// //           title: Text(
// //             docId == null ? "إضافة مصروف جديد" : "تعديل المصروف",
// //             style: const TextStyle(fontWeight: FontWeight.bold),
// //           ),
// //           content: SingleChildScrollView(
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 // التاريخ أولاً
// //                 Container(
// //                   padding: const EdgeInsets.all(12),
// //                   decoration: BoxDecoration(
// //                     border: Border.all(color: Colors.grey.shade300),
// //                     borderRadius: BorderRadius.circular(8),
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       const Icon(
// //                         Icons.calendar_today,
// //                         size: 20,
// //                         color: Colors.blue,
// //                       ),
// //                       const SizedBox(width: 12),
// //                       Expanded(
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             const Text(
// //                               "التاريخ",
// //                               style: TextStyle(
// //                                 fontSize: 12,
// //                                 color: Colors.grey,
// //                               ),
// //                             ),
// //                             Text(
// //                               DateFormat('yyyy/MM/dd').format(selectedDate),
// //                               style: const TextStyle(
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize: 16,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                       IconButton(
// //                         onPressed: () async {
// //                           final DateTime? picked = await showDatePicker(
// //                             context: context,
// //                             initialDate: selectedDate,
// //                             firstDate: DateTime(2000),
// //                             lastDate: DateTime(2100),
// //                           );
// //                           if (picked != null) {
// //                             setState(() {
// //                               selectedDate = picked;
// //                             });
// //                           }
// //                         },
// //                         icon: const Icon(Icons.edit, size: 20),
// //                         style: IconButton.styleFrom(
// //                           backgroundColor: Colors.blue.shade50,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),

// //                 // المبلغ ثانياً
// //                 TextField(
// //                   controller: _amountController,
// //                   keyboardType: TextInputType.number,
// //                   decoration: InputDecoration(
// //                     labelText: "المبلغ",
// //                     prefixText: "ج ",
// //                     prefixIcon: const Icon(
// //                       Icons.attach_money,
// //                       color: Colors.green,
// //                     ),
// //                     border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),

// //                 // القائمة المنسدلة ثالثاً
// //                 DropdownButtonFormField<String>(
// //                   value: selectedCategory,
// //                   decoration: InputDecoration(
// //                     labelText: "التصنيف",
// //                     prefixIcon: const Icon(
// //                       Icons.category,
// //                       color: Colors.purple,
// //                     ),
// //                     border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                   ),
// //                   items: _categories.map((category) {
// //                     return DropdownMenuItem<String>(
// //                       value: category['name'],
// //                       child: Row(
// //                         children: [
// //                           Icon(
// //                             category['icon'],
// //                             color: category['color'],
// //                             size: 20,
// //                           ),
// //                           const SizedBox(width: 12),
// //                           Text(category['name']),
// //                         ],
// //                       ),
// //                     );
// //                   }).toList(),
// //                   onChanged: (value) {
// //                     if (value != null) {
// //                       setState(() {
// //                         selectedCategory = value;
// //                       });
// //                     }
// //                   },
// //                 ),
// //                 const SizedBox(height: 16),

// //                 // الملاحظات رابعاً
// //                 TextField(
// //                   controller: _noteController,
// //                   maxLines: 3,
// //                   decoration: InputDecoration(
// //                     labelText: "ملاحظات",
// //                     prefixIcon: const Icon(Icons.note, color: Colors.orange),
// //                     border: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     hintText: "أضف ملاحظات حول المصروف...",
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () {
// //                 Navigator.pop(context);
// //                 _resetForm();
// //               },
// //               child: const Text("إلغاء"),
// //             ),
// //             ElevatedButton(
// //               onPressed: _isLoading
// //                   ? null
// //                   : () async {
// //                       if (_amountController.text.isEmpty) {
// //                         ScaffoldMessenger.of(context).showSnackBar(
// //                           const SnackBar(content: Text("الرجاء إدخال المبلغ")),
// //                         );
// //                         return;
// //                       }

// //                       setState(() {
// //                         _isLoading = true;
// //                       });

// //                       try {
// //                         final expenseData = {
// //                           "title": selectedCategory,
// //                           "amount": double.parse(_amountController.text),
// //                           "category": selectedCategory,
// //                           "note": _noteController.text,
// //                           "date": Timestamp.fromDate(selectedDate),
// //                           "updatedAt": Timestamp.now(),
// //                         };

// //                         if (docId == null) {
// //                           // إضافة جديد
// //                           expenseData["createdAt"] = Timestamp.now();
// //                           await _firestore
// //                               .collection("expenses")
// //                               .add(expenseData);

// //                           ScaffoldMessenger.of(context).showSnackBar(
// //                             const SnackBar(
// //                               content: Text("تم إضافة المصروف بنجاح"),
// //                               backgroundColor: Colors.green,
// //                             ),
// //                           );
// //                         } else {
// //                           // تحديث
// //                           await _firestore
// //                               .collection("expenses")
// //                               .doc(docId)
// //                               .update(expenseData);

// //                           ScaffoldMessenger.of(context).showSnackBar(
// //                             const SnackBar(
// //                               content: Text("تم تحديث المصروف بنجاح"),
// //                               backgroundColor: Colors.blue,
// //                             ),
// //                           );
// //                         }

// //                         Navigator.pop(context);
// //                         _resetForm();
// //                       } catch (e) {
// //                         ScaffoldMessenger.of(context).showSnackBar(
// //                           SnackBar(
// //                             content: Text("حدث خطأ: $e"),
// //                             backgroundColor: Colors.red,
// //                           ),
// //                         );
// //                       } finally {
// //                         setState(() {
// //                           _isLoading = false;
// //                         });
// //                       }
// //                     },
// //               child: _isLoading
// //                   ? const SizedBox(
// //                       width: 20,
// //                       height: 20,
// //                       child: CircularProgressIndicator(strokeWidth: 2),
// //                     )
// //                   : Text(docId == null ? "إضافة" : "تحديث"),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   // ================= حذف مصروف =================
// //   Future<void> _confirmDelete(String docId, String title) async {
// //     return showDialog(
// //       context: context,
// //       builder: (context) {
// //         return AlertDialog(
// //           title: const Text("تأكيد الحذف"),
// //           content: Text("هل أنت متأكد من حذف مصروف '$title'؟"),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.pop(context),
// //               child: const Text("إلغاء"),
// //             ),
// //             ElevatedButton(
// //               onPressed: () async {
// //                 Navigator.pop(context);
// //                 try {
// //                   await _firestore.collection("expenses").doc(docId).delete();
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     const SnackBar(
// //                       content: Text("تم حذف المصروف بنجاح"),
// //                       backgroundColor: Colors.red,
// //                     ),
// //                   );
// //                 } catch (e) {
// //                   ScaffoldMessenger.of(context).showSnackBar(
// //                     SnackBar(
// //                       content: Text("حدث خطأ أثناء الحذف: $e"),
// //                       backgroundColor: Colors.red,
// //                     ),
// //                   );
// //                 }
// //               },
// //               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
// //               child: const Text("حذف", style: TextStyle(color: Colors.white)),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   // ================= جزء الفلترة =================
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
// //                           if (selected) {
// //                             setState(() => _timeFilter = filter);
// //                           }
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

// //   // ================= إحصائيات =================
// //   Widget _buildStats(List<QueryDocumentSnapshot> docs) {
// //     double total = 0;
// //     Map<String, double> categoryTotals = {};

// //     for (var doc in docs) {
// //       final data = doc.data() as Map<String, dynamic>;
// //       final amount = data['amount'] as double;
// //       final category = data['category'] as String;

// //       total += amount;
// //       categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
// //     }

// //     return Card(
// //       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //       child: Padding(
// //         padding: const EdgeInsets.all(12),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             const Text(
// //               "إحصائيات المصروفات",
// //               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
// //             ),
// //             const SizedBox(height: 8),
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: Container(
// //                     padding: const EdgeInsets.all(12),
// //                     decoration: BoxDecoration(
// //                       color: Colors.blue.shade50,
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: Column(
// //                       children: [
// //                         const Text(
// //                           "المجموع الكلي",
// //                           style: TextStyle(fontSize: 12),
// //                         ),
// //                         const SizedBox(height: 4),
// //                         Text(
// //                           "${total.toStringAsFixed(2)} ج",
// //                           style: const TextStyle(
// //                             fontWeight: FontWeight.bold,
// //                             fontSize: 16,
// //                             color: Colors.blue,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 8),
// //                 Expanded(
// //                   child: Container(
// //                     padding: const EdgeInsets.all(12),
// //                     decoration: BoxDecoration(
// //                       color: Colors.green.shade50,
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: Column(
// //                       children: [
// //                         const Text(
// //                           "عدد المصروفات",
// //                           style: TextStyle(fontSize: 12),
// //                         ),
// //                         const SizedBox(height: 4),
// //                         Text(
// //                           "${docs.length}",
// //                           style: const TextStyle(
// //                             fontWeight: FontWeight.bold,
// //                             fontSize: 16,
// //                             color: Colors.green,
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

// //   // ================= إعادة تعيين النموذج =================
// //   void _resetForm() {
// //     _titleController.clear();
// //     _amountController.clear();
// //     _noteController.clear();
// //     selectedCategory = "تشغيل";
// //     selectedDate = DateTime.now();
// //     _editingDocId = null;
// //   }

// //   @override
// //   void dispose() {
// //     _titleController.dispose();
// //     _amountController.dispose();
// //     _noteController.dispose();
// //     super.dispose();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF4F6F8),
// //       body: Column(
// //         children: [
// //           // AppBar مخصص
// //           _buildCustomAppBar(),

// //           // جزء الفلترة
// //           _buildTimeFilterSection(),

// //           // المحتوى الرئيسي
// //           Expanded(
// //             child: StreamBuilder<QuerySnapshot>(
// //               stream: _firestore
// //                   .collection("expenses")
// //                   .orderBy('date', descending: true)
// //                   .snapshots(),
// //               builder: (context, snapshot) {
// //                 if (!snapshot.hasData) {
// //                   return const Center(child: CircularProgressIndicator());
// //                 }

// //                 // تطبيق الفلترة حسب التاريخ
// //                 List<QueryDocumentSnapshot> allDocs = snapshot.data!.docs;
// //                 List<QueryDocumentSnapshot> filteredDocs =
// //                     _filterExpensesByDate(allDocs);

// //                 if (snapshot.data!.docs.isEmpty) {
// //                   return Center(
// //                     child: Column(
// //                       mainAxisAlignment: MainAxisAlignment.center,
// //                       children: [
// //                         const Icon(
// //                           Icons.receipt_long,
// //                           size: 80,
// //                           color: Colors.grey,
// //                         ),
// //                         const SizedBox(height: 16),
// //                         const Text(
// //                           "لا توجد مصروفات",
// //                           style: TextStyle(fontSize: 18, color: Colors.grey),
// //                         ),
// //                         const SizedBox(height: 8),
// //                         Text(
// //                           "انقر على زر + لإضافة أول مصروف",
// //                           style: TextStyle(
// //                             fontSize: 14,
// //                             color: Colors.grey.shade600,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   );
// //                 }

// //                 return Column(
// //                   children: [
// //                     _buildStats(filteredDocs),
// //                     Expanded(
// //                       child: ListView.builder(
// //                         itemCount: filteredDocs.length,
// //                         itemBuilder: (context, index) {
// //                           final doc = filteredDocs[index];
// //                           final data = doc.data() as Map<String, dynamic>;
// //                           final docId = doc.id;
// //                           final date = (data['date'] as Timestamp).toDate();
// //                           final category = _categories.firstWhere(
// //                             (cat) => cat['name'] == data['category'],
// //                             orElse: () => _categories.last,
// //                           );

// //                           return Card(
// //                             margin: const EdgeInsets.symmetric(
// //                               horizontal: 8,
// //                               vertical: 4,
// //                             ),
// //                             child: ListTile(
// //                               leading: CircleAvatar(
// //                                 backgroundColor: category['color'].withOpacity(
// //                                   0.1,
// //                                 ),
// //                                 child: Icon(
// //                                   category['icon'],
// //                                   color: category['color'],
// //                                   size: 20,
// //                                 ),
// //                               ),
// //                               title: Text(
// //                                 "${data['amount'].toStringAsFixed(2)} ج",
// //                                 style: const TextStyle(
// //                                   fontWeight: FontWeight.bold,
// //                                   fontSize: 18,
// //                                   color: Colors.blue,
// //                                 ),
// //                               ),
// //                               subtitle: Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 children: [
// //                                   const SizedBox(height: 4),
// //                                   Text(
// //                                     data['category'],
// //                                     style: TextStyle(
// //                                       fontSize: 14,
// //                                       color: category['color'],
// //                                       fontWeight: FontWeight.bold,
// //                                     ),
// //                                   ),
// //                                   const SizedBox(height: 2),
// //                                   Text(
// //                                     DateFormat('yyyy/MM/dd').format(date),
// //                                     style: const TextStyle(fontSize: 12),
// //                                   ),
// //                                   if (data['note'] != null &&
// //                                       data['note'].isNotEmpty)
// //                                     Padding(
// //                                       padding: const EdgeInsets.only(top: 4),
// //                                       child: Text(
// //                                         data['note'],
// //                                         style: TextStyle(
// //                                           fontSize: 12,
// //                                           color: Colors.grey.shade600,
// //                                         ),
// //                                       ),
// //                                     ),
// //                                 ],
// //                               ),
// //                               trailing: PopupMenuButton<String>(
// //                                 icon: const Icon(Icons.more_vert),
// //                                 onSelected: (value) async {
// //                                   if (value == 'edit') {
// //                                     await _openExpenseSheet(
// //                                       docId: docId,
// //                                       data: data,
// //                                     );
// //                                   } else if (value == 'delete') {
// //                                     await _confirmDelete(docId, data['title']);
// //                                   }
// //                                 },
// //                                 itemBuilder: (BuildContext context) {
// //                                   return [
// //                                     const PopupMenuItem<String>(
// //                                       value: 'edit',
// //                                       child: Row(
// //                                         children: [
// //                                           Icon(Icons.edit, size: 20),
// //                                           SizedBox(width: 8),
// //                                           Text('تعديل'),
// //                                         ],
// //                                       ),
// //                                     ),
// //                                     const PopupMenuItem<String>(
// //                                       value: 'delete',
// //                                       child: Row(
// //                                         children: [
// //                                           Icon(
// //                                             Icons.delete,
// //                                             color: Colors.red,
// //                                             size: 20,
// //                                           ),
// //                                           SizedBox(width: 8),
// //                                           Text(
// //                                             'حذف',
// //                                             style: TextStyle(color: Colors.red),
// //                                           ),
// //                                         ],
// //                                       ),
// //                                     ),
// //                                   ];
// //                                 },
// //                               ),
// //                             ),
// //                           );
// //                         },
// //                       ),
// //                     ),
// //                   ],
// //                 );
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //       floatingActionButton: Row(
// //         mainAxisAlignment: MainAxisAlignment.end,
// //         children: [
// //           // زر PDF
// //           FloatingActionButton(
// //             heroTag: 'pdf_btn',
// //             onPressed: _isGeneratingPDF ? null : _generatePDF,
// //             backgroundColor: _isGeneratingPDF ? Colors.grey : Colors.red,
// //             mini: true,
// //             child: _isGeneratingPDF
// //                 ? const CircularProgressIndicator(color: Colors.white)
// //                 : const Icon(Icons.picture_as_pdf, color: Colors.white),
// //           ),
// //           const SizedBox(width: 10),
// //           // زر إضافة مصروف
// //           FloatingActionButton.extended(
// //             onPressed: () => _openExpenseSheet(),
// //             icon: const Icon(Icons.add),
// //             label: const Text("إضافة مصروف"),
// //             backgroundColor: const Color(0xFF3498DB),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:flutter/services.dart' show rootBundle;

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({super.key});

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // ================= أنواع النثريات =================
  final List<Map<String, dynamic>> _categories = [
    {'name': 'نثريات', 'icon': Icons.shopping_cart, 'color': Colors.purple},
    {'name': 'تشغيل', 'icon': Icons.business, 'color': Colors.orange},
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

  String selectedCategory = "نثريات";
  DateTime selectedDate = DateTime.now();
  String _editingDocId = "";
  bool _isLoading = false;
  bool _isGeneratingPDF = false;
  String _timeFilter = 'الكل';
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  pdfLib.Font? _arabicFont;
  double _treasuryBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _loadArabicFont();
    _loadTreasuryBalance();
  }

  // ================= تحميل رصيد الخزنة =================
  Future<void> _loadTreasuryBalance() async {
    try {
      // مجموع الدخل
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
      debugPrint('Error loading treasury balance: $e');
    }
  }

  // ================= تحميل الخط العربي =================
  Future<void> _loadArabicFont() async {
    try {
      final fontData = await rootBundle.load(
        'assets/fonts/Amiri/Amiri-Regular.ttf',
      );
      _arabicFont = pdfLib.Font.ttf(fontData);
      debugPrint('تم تحميل الخط العربي بنجاح');
    } catch (e) {
      debugPrint('فشل تحميل الخط العربي: $e');
    }
  }

  // ================= إضافة/تعديل مصروف =================
  Future<void> _saveExpense(
    String? docId,
    Map<String, dynamic>? oldData,
  ) async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("الرجاء إدخال المبلغ")));
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("الرجاء إدخال مبلغ صحيح")));
      return;
    }

    // التحقق من رصيد الخزنة (فقط للإضافة الجديدة)
    if (docId == null && amount > _treasuryBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "المبلغ أكبر من الرصيد المتاح (${_treasuryBalance.toStringAsFixed(2)} ج)",
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // بيانات المصروف للنثريات
      final expenseData = {
        "title": selectedCategory,
        "amount": amount,
        "category": selectedCategory,
        "note": _noteController.text,
        "date": Timestamp.fromDate(selectedDate),
        "updatedAt": Timestamp.now(),
        "createdAt": Timestamp.now(),
      };

      if (docId == null) {
        // ========== إضافة جديد ==========
        // 1. إضافة في النثريات
        final expenseDoc = await _firestore
            .collection("expenses")
            .add(expenseData);

        // 2. إضافة في خزنة الخرج كـ "نثريات"
        final treasuryExitData = {
          'amount': amount,
          'expenseType': 'نثريات',
          'description': _noteController.text.isNotEmpty
              ? _noteController.text
              : selectedCategory,
          'recipient': '',
          'date': Timestamp.fromDate(selectedDate),
          'createdAt': Timestamp.now(),
          'category': 'خرج',
          'status': 'مكتمل',
          'source': 'النثريات',
          'sourceId': expenseDoc.id,
          'expenseNote': _noteController.text,
        };

        await _firestore.collection('treasury_exits').add(treasuryExitData);

        // 3. تحديث الرصيد المحلي
        setState(() => _treasuryBalance -= amount);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم إضافة المصروف بنجاح وخصمه من الخزنة"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // ========== تحديث موجود ==========
        final oldAmount = (oldData!['amount'] as num).toDouble();
        final amountDifference = amount - oldAmount;

        // 1. تحديث في النثريات
        await _firestore.collection("expenses").doc(docId).update(expenseData);

        // 2. تحديث في الخزنة
        final exitSnapshot = await _firestore
            .collection('treasury_exits')
            .where('sourceId', isEqualTo: docId)
            .limit(1)
            .get();

        if (exitSnapshot.docs.isNotEmpty) {
          await _firestore
              .collection('treasury_exits')
              .doc(exitSnapshot.docs.first.id)
              .update({
                'amount': amount,
                'description': _noteController.text.isNotEmpty
                    ? _noteController.text
                    : selectedCategory,
                'date': Timestamp.fromDate(selectedDate),
                'updatedAt': Timestamp.now(),
              });
        }

        // 3. تحديث الرصيد إذا تغير المبلغ
        if (amountDifference != 0) {
          if (amountDifference > 0) {
            // زيادة المزيد من الخزنة
            if (amountDifference > _treasuryBalance) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("لا يمكن زيادة المبلغ، الرصيد غير كافي"),
                ),
              );
              return;
            }
            setState(() => _treasuryBalance -= amountDifference);
          } else {
            // إرجاع جزء من المبلغ للخزنة
            setState(() => _treasuryBalance += -amountDifference);
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم تحديث المصروف بنجاح"),
            backgroundColor: Colors.blue,
          ),
        );
      }

      Navigator.pop(context);
      _resetForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("حدث خطأ: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ================= حذف مصروف مع ربط بالخزنة =================
  Future<void> _confirmDelete(String docId, String title, double amount) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("تأكيد الحذف"),
          content: Text(
            "هل أنت متأكد من حذف مصروف '$title' بقيمة ${amount.toStringAsFixed(2)} ج؟",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  // 1. البحث عن الخروج المقابل في الخزنة وحذفه
                  final exitSnapshot = await _firestore
                      .collection('treasury_exits')
                      .where('sourceId', isEqualTo: docId)
                      .limit(1)
                      .get();

                  if (exitSnapshot.docs.isNotEmpty) {
                    await _firestore
                        .collection('treasury_exits')
                        .doc(exitSnapshot.docs.first.id)
                        .delete();

                    // 2. إعادة المبلغ للخزنة
                    setState(() => _treasuryBalance += amount);
                  }

                  // 3. حذف من النثريات
                  await _firestore.collection("expenses").doc(docId).delete();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "تم حذف المصروف بنجاح وإرجاع المبلغ للخزنة",
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                } catch (e) {
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(
                  //     content: Text("حدث خطأ أثناء الحذف: $e"),
                  //     backgroundColor: Colors.red,
                  //   ),
                  // );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("حذف", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // ================= فتح نافذة إضافة/تعديل =================
  Future<void> _openExpenseSheet({
    String? docId,
    Map<String, dynamic>? data,
  }) async {
    _editingDocId = docId ?? "";

    if (data != null) {
      // وضع التعديل
      _titleController.text = data['title'];
      _amountController.text = data['amount'].toString();
      _noteController.text = data['note'] ?? '';
      selectedCategory = data['category'];
      selectedDate = (data['date'] as Timestamp).toDate();
    } else {
      // وضع الإضافة
      _titleController.clear();
      _amountController.clear();
      _noteController.clear();
      selectedCategory = "نثريات";
      selectedDate = DateTime.now();
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            docId == null ? "إضافة مصروف جديد" : "تعديل المصروف",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // عرض رصيد الخزنة
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: Colors.blue[800],
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "الرصيد المتاح في الخزنة",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${_treasuryBalance.toStringAsFixed(2)} ج",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _treasuryBalance > 1000
                                    ? Colors.green[800]
                                    : Colors.red[800],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // التاريخ
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "التاريخ",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              DateFormat('yyyy/MM/dd').format(selectedDate),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                        icon: const Icon(Icons.edit, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blue.shade50,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // المبلغ
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "المبلغ",
                    prefixText: "ج ",
                    prefixIcon: const Icon(
                      Icons.attach_money,
                      color: Colors.red,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixText: "ج",
                  ),
                ),
                const SizedBox(height: 16),

                // التصنيف
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: "التصنيف",
                    prefixIcon: const Icon(
                      Icons.category,
                      color: Colors.purple,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['name'],
                      child: Row(
                        children: [
                          Icon(
                            category['icon'],
                            color: category['color'],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(category['name']),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // الملاحظات
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "ملاحظات",
                    prefixIcon: const Icon(Icons.note, color: Colors.orange),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: "أضف ملاحظات حول المصروف...",
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
              child: const Text("إلغاء"),
            ),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async => _saveExpense(docId, data),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(docId == null ? "إضافة" : "تحديث"),
            ),
          ],
        );
      },
    );
  }

  // ================= إنشاء PDF =================
  Future<void> _generatePDF() async {
    if (_arabicFont == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('الخط العربي غير محمل')));
      return;
    }

    setState(() => _isGeneratingPDF = true);

    try {
      final expenses = await _fetchExpensesForPDF();

      if (expenses.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا توجد مصروفات للطباعة')),
        );
        return;
      }

      final pdf = pdfLib.Document(
        theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
      );

      pdf.addPage(
        pdfLib.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: pdfLib.EdgeInsets.all(25),
          build: (context) => [
            _buildPdfHeader(),
            pdfLib.SizedBox(height: 15),
            _buildPdfTitle(),
            pdfLib.SizedBox(height: 25),
            _buildPdfTable(expenses),
            pdfLib.SizedBox(height: 20),
            _buildPdfTotalSection(expenses),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'المصروفات_${_getPDFFileName()}',
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ في إنشاء PDF: $e')));
    } finally {
      setState(() => _isGeneratingPDF = false);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchExpensesForPDF() async {
    try {
      Query query = _firestore
          .collection("expenses")
          .orderBy('date', descending: true);

      final snapshot = await query.get();
      List<Map<String, dynamic>> filteredExpenses = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final date = (data['date'] as Timestamp).toDate();
        final docId = doc.id;

        if (_applyPDFFilter(date)) {
          filteredExpenses.add({
            'id': docId,
            'title': data['title'] ?? '',
            'amount': data['amount'] ?? 0.0,
            'category': data['category'] ?? 'أخرى',
            'note': data['note'] ?? '',
            'date': date,
            'formattedDate': DateFormat('yyyy/MM/dd').format(date),
          });
        }
      }

      return filteredExpenses;
    } catch (e) {
      debugPrint('خطأ في جلب المصروفات للPDF: $e');
      return [];
    }
  }

  bool _applyPDFFilter(DateTime date) {
    final now = DateTime.now();

    switch (_timeFilter) {
      case 'اليوم':
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
      case 'هذا الشهر':
        return date.year == now.year && date.month == now.month;
      case 'هذه السنة':
        return date.year == now.year;
      case 'مخصص':
        return date.month == _selectedMonth && date.year == _selectedYear;
      case 'الكل':
      default:
        return true;
    }
  }

  pdfLib.Widget _buildPdfHeader() {
    return pdfLib.Directionality(
      textDirection: pdfLib.TextDirection.rtl,
      child: pdfLib.Column(
        crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
        children: [
          pdfLib.Row(
            mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
            children: [
              pdfLib.Text(
                'FN 454.4 - 203/317/21',
                style: pdfLib.TextStyle(
                  fontSize: 14,
                  fontWeight: pdfLib.FontWeight.bold,
                  font: _arabicFont,
                  color: PdfColors.black,
                ),
              ),
              pdfLib.Text(
                'المصروفات والنثريات',
                style: pdfLib.TextStyle(
                  fontSize: 20,
                  fontWeight: pdfLib.FontWeight.bold,
                  font: _arabicFont,
                  color: PdfColors.black,
                ),
              ),
            ],
          ),
          pdfLib.Divider(color: PdfColors.black, thickness: 2),
        ],
      ),
    );
  }

  pdfLib.Widget _buildPdfTitle() {
    return pdfLib.Directionality(
      textDirection: pdfLib.TextDirection.rtl,
      child: pdfLib.Column(
        crossAxisAlignment: pdfLib.CrossAxisAlignment.center,
        children: [
          pdfLib.Text(
            'المصروفات الكاملة لشهر $_selectedMonth',
            style: pdfLib.TextStyle(
              fontSize: 18,
              fontWeight: pdfLib.FontWeight.bold,
              font: _arabicFont,
              color: PdfColors.black,
            ),
            textAlign: pdfLib.TextAlign.center,
          ),
          pdfLib.SizedBox(height: 10),
          pdfLib.Text(
            'تاريخ الطباعة: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}',
            style: pdfLib.TextStyle(
              fontSize: 14,
              font: _arabicFont,
              color: PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  pdfLib.Widget _buildPdfTable(List<Map<String, dynamic>> expenses) {
    return pdfLib.Directionality(
      textDirection: pdfLib.TextDirection.rtl,
      child: pdfLib.Column(
        children: [
          pdfLib.Table(
            border: pdfLib.TableBorder.all(color: PdfColors.black, width: 1.5),
            columnWidths: {
              4: pdfLib.FlexColumnWidth(0.7),
              3: pdfLib.FlexColumnWidth(1.5),
              2: pdfLib.FlexColumnWidth(1.5),
              1: pdfLib.FlexColumnWidth(2.0),
              0: pdfLib.FlexColumnWidth(3.0),
            },
            defaultVerticalAlignment: pdfLib.TableCellVerticalAlignment.middle,
            children: [
              pdfLib.TableRow(
                children: [
                  _buildPdfHeaderCell('الملاحظات'),
                  _buildPdfHeaderCell('النوع'),
                  _buildPdfHeaderCell('المبلغ'),
                  _buildPdfHeaderCell('التاريخ'),
                  _buildPdfHeaderCell('م'),
                ],
              ),
              ...expenses.asMap().entries.map((entry) {
                int index = entry.key + 1;
                Map<String, dynamic> expense = entry.value;

                return pdfLib.TableRow(
                  children: [
                    _buildPdfDataCell(
                      expense['note']?.toString().isNotEmpty == true
                          ? expense['note'].toString()
                          : '-',
                      textAlign: pdfLib.TextAlign.right,
                    ),
                    _buildPdfDataCell(
                      expense['category']?.toString() ?? 'أخرى',
                      textAlign: pdfLib.TextAlign.center,
                    ),
                    _buildPdfDataCell(
                      '${(expense['amount'] as double).toStringAsFixed(2)}',
                      textAlign: pdfLib.TextAlign.center,
                      isAmount: true,
                    ),
                    _buildPdfDataCell(
                      expense['formattedDate']?.toString() ?? '',
                      textAlign: pdfLib.TextAlign.center,
                    ),
                    _buildPdfDataCell(
                      index.toString(),
                      textAlign: pdfLib.TextAlign.center,
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  pdfLib.Widget _buildPdfTotalSection(List<Map<String, dynamic>> expenses) {
    double total = expenses.fold(
      0.0,
      (sum, exp) => sum + (exp['amount'] as double),
    );

    return pdfLib.Directionality(
      textDirection: pdfLib.TextDirection.rtl,
      child: pdfLib.Container(
        padding: pdfLib.EdgeInsets.all(12),
        decoration: pdfLib.BoxDecoration(
          border: pdfLib.Border.all(color: PdfColors.black, width: 2),
        ),
        child: pdfLib.Row(
          mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
          children: [
            pdfLib.Text(
              'إجمالي المصروفات',
              style: pdfLib.TextStyle(
                fontSize: 18,
                fontWeight: pdfLib.FontWeight.bold,
                font: _arabicFont,
                color: PdfColors.black,
              ),
            ),
            pdfLib.Text(
              '${total.toStringAsFixed(2)} ج',
              style: pdfLib.TextStyle(
                fontSize: 20,
                fontWeight: pdfLib.FontWeight.bold,
                font: _arabicFont,
                color: PdfColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pdfLib.Widget _buildPdfHeaderCell(String text) {
    return pdfLib.Container(
      padding: pdfLib.EdgeInsets.all(10),
      child: pdfLib.Text(
        text,
        style: pdfLib.TextStyle(
          fontSize: 14,
          fontWeight: pdfLib.FontWeight.bold,
          font: _arabicFont,
          color: PdfColors.black,
        ),
        textAlign: pdfLib.TextAlign.center,
      ),
    );
  }

  pdfLib.Widget _buildPdfDataCell(
    String text, {
    pdfLib.TextAlign textAlign = pdfLib.TextAlign.center,
    bool isAmount = false,
  }) {
    return pdfLib.Container(
      padding: pdfLib.EdgeInsets.all(8),
      child: pdfLib.Text(
        text,
        style: pdfLib.TextStyle(
          fontSize: 13,
          fontWeight: isAmount
              ? pdfLib.FontWeight.bold
              : pdfLib.FontWeight.normal,
          font: _arabicFont,
          color: PdfColors.black,
        ),
        textAlign: textAlign,
        maxLines: 2,
      ),
    );
  }

  String _getPDFFileName() {
    final now = DateTime.now();
    String filterSuffix = '';

    switch (_timeFilter) {
      case 'اليوم':
        filterSuffix = 'اليوم_${DateFormat('yyyyMMdd').format(now)}';
        break;
      case 'هذا الشهر':
        filterSuffix = 'شهر_${now.month}_${now.year}';
        break;
      case 'هذه السنة':
        filterSuffix = 'سنة_${now.year}';
        break;
      case 'مخصص':
        filterSuffix = 'شهر_${_selectedMonth}_سنة_${_selectedYear}';
        break;
      default:
        filterSuffix = 'الكامل';
    }

    return 'المصروفات_$filterSuffix';
  }

  // ================= فلترة حسب التاريخ =================
  List<QueryDocumentSnapshot> _filterExpensesByDate(
    List<QueryDocumentSnapshot> allDocs,
  ) {
    return allDocs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final date = (data['date'] as Timestamp).toDate();

      if (_timeFilter == 'الكل') return true;

      final now = DateTime.now();
      switch (_timeFilter) {
        case 'اليوم':
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        case 'هذا الشهر':
          return date.year == now.year && date.month == now.month;
        case 'هذه السنة':
          return date.year == now.year;
        case 'مخصص':
          return date.year == _selectedYear && date.month == _selectedMonth;
        default:
          return true;
      }
    }).toList();
  }

  void _applyMonthYearFilter() {
    setState(() => _timeFilter = 'مخصص');
  }

  // ================= AppBar مخصص =================
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
        bottom: false,
        child: Row(
          children: [
            const Icon(Icons.attach_money, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            const Text(
              'المصروفات والنثريات',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
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
                          '${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period',
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['الكل', 'اليوم', 'هذا الشهر', 'هذه السنة']
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: _timeFilter == filter,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _timeFilter = filter);
                          }
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

  Widget _buildStats(List<QueryDocumentSnapshot> docs) {
    double total = 0;
    Map<String, double> categoryTotals = {};

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = data['amount'] as double;
      final category = data['category'] as String;

      total += amount;
      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "إحصائيات المصروفات",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "المجموع الكلي",
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${total.toStringAsFixed(2)} ج",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "عدد المصروفات",
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${docs.length}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
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

  void _resetForm() {
    _titleController.clear();
    _amountController.clear();
    _noteController.clear();
    selectedCategory = "نثريات";
    selectedDate = DateTime.now();
    _editingDocId = "";
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Column(
        children: [
          _buildCustomAppBar(),
          _buildTimeFilterSection(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection("expenses")
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<QueryDocumentSnapshot> allDocs = snapshot.data!.docs;
                List<QueryDocumentSnapshot> filteredDocs =
                    _filterExpensesByDate(allDocs);

                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "لا توجد مصروفات",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "انقر على زر + لإضافة أول مصروف",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    _buildStats(filteredDocs),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          final doc = filteredDocs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final docId = doc.id;
                          final date = (data['date'] as Timestamp).toDate();
                          final category = _categories.firstWhere(
                            (cat) => cat['name'] == data['category'],
                            orElse: () => _categories.last,
                          );

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: category['color'].withOpacity(
                                  0.1,
                                ),
                                child: Icon(
                                  category['icon'],
                                  color: category['color'],
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                "${data['amount'].toStringAsFixed(2)} ج",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.blue,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    data['category'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: category['color'],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    DateFormat('yyyy/MM/dd').format(date),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  if (data['note'] != null &&
                                      data['note'].isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        data['note'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    await _openExpenseSheet(
                                      docId: docId,
                                      data: data,
                                    );
                                  } else if (value == 'delete') {
                                    await _confirmDelete(
                                      docId,
                                      data['title'],
                                      (data['amount'] as double),
                                    );
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return [
                                    const PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 20),
                                          SizedBox(width: 8),
                                          Text('تعديل'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'حذف',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ];
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'pdf_btn',
            onPressed: _isGeneratingPDF ? null : _generatePDF,
            backgroundColor: _isGeneratingPDF ? Colors.grey : Colors.red,
            mini: true,
            child: _isGeneratingPDF
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.picture_as_pdf, color: Colors.white),
          ),
          const SizedBox(width: 10),
          FloatingActionButton.extended(
            onPressed: () => _openExpenseSheet(),
            icon: const Icon(Icons.add),
            label: const Text("إضافة مصروف"),
            backgroundColor: const Color(0xFF3498DB),
          ),
        ],
      ),
    );
  }
}
