// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:printing/printing.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pdfLib;
// import 'package:flutter/services.dart' show rootBundle;

// class LoansPage extends StatefulWidget {
//   const LoansPage({super.key});

//   @override
//   State<LoansPage> createState() => _LoansPageState();
// }

// class _LoansPageState extends State<LoansPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final TextEditingController _recipientController = TextEditingController();
//   final TextEditingController _amountController = TextEditingController();
//   final TextEditingController _noteController = TextEditingController();

//   // ================= أنواع الدفع =================
//   final List<Map<String, dynamic>> _paymentTypes = [
//     {'name': 'نقدي', 'icon': Icons.money, 'color': Colors.green},
//     {'name': 'تحويل بنكي', 'icon': Icons.account_balance, 'color': Colors.blue},
//     {'name': 'شيك', 'icon': Icons.description, 'color': Colors.orange},
//   ];

//   String selectedPaymentType = "نقدي";
//   DateTime selectedDate = DateTime.now();
//   String _editingDocId = "";
//   bool _isLoading = false;
//   bool _isGeneratingPDF = false;
//   String _timeFilter = 'الكل';
//   int _selectedMonth = DateTime.now().month;
//   int _selectedYear = DateTime.now().year;
//   pdfLib.Font? _arabicFont;
//   double _treasuryBalance = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _loadArabicFont();
//     _loadTreasuryBalance();
//   }

//   // ================= تحميل رصيد الخزنة =================
//   Future<void> _loadTreasuryBalance() async {
//     try {
//       // مجموع الدخل
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

//       // مجموع الخرج (المصروفات + السلف)
//       final expensesSnapshot = await _firestore
//           .collection('treasury_exits')
//           .get();

//       double totalExpense = 0;
//       for (var doc in expensesSnapshot.docs) {
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
//       debugPrint('Error loading treasury balance: $e');
//     }
//   }

//   // ================= تحميل الخط العربي =================
//   Future<void> _loadArabicFont() async {
//     try {
//       final fontData = await rootBundle.load(
//         'assets/fonts/Amiri/Amiri-Regular.ttf',
//       );
//       _arabicFont = pdfLib.Font.ttf(fontData);
//       debugPrint('تم تحميل الخط العربي بنجاح');
//     } catch (e) {
//       debugPrint('فشل تحميل الخط العربي: $e');
//     }
//   }

//   // ================= إضافة/تعديل سلفة =================
//   Future<void> _saveLoan(String? docId, Map<String, dynamic>? oldData) async {
//     if (_recipientController.text.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("الرجاء إدخال اسم المستلم")));
//       return;
//     }

//     if (_amountController.text.isEmpty) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("الرجاء إدخال المبلغ")));
//       return;
//     }

//     final amount = double.tryParse(_amountController.text);
//     if (amount == null || amount <= 0) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("الرجاء إدخال مبلغ صحيح")));
//       return;
//     }

//     // التحقق من رصيد الخزنة (فقط للإضافة الجديدة)
//     if (docId == null && amount > _treasuryBalance) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             "المبلغ أكبر من الرصيد المتاح (${_treasuryBalance.toStringAsFixed(2)} ج)",
//           ),
//         ),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       // بيانات السلفة للنثريات
//       final loanData = {
//         "recipient": _recipientController.text,
//         "amount": amount,
//         "paymentType": selectedPaymentType,
//         "note": _noteController.text,
//         "date": Timestamp.fromDate(selectedDate),
//         "updatedAt": Timestamp.now(),
//         "createdAt": Timestamp.now(),
//       };

//       if (docId == null) {
//         // ========== إضافة جديد ==========
//         // 1. إضافة في السلف
//         final loanDoc = await _firestore.collection("loans").add(loanData);

//         // 2. إضافة في خزنة الخرج كـ "سلفة" - بنفس طريقة النثريات
//         final treasuryExitData = {
//           'amount': amount,
//           'expenseType': 'سلفة',
//           'description': 'سلفة لـ ${_recipientController.text}',
//           'recipient': _recipientController.text,
//           'date': Timestamp.fromDate(selectedDate),
//           'createdAt': Timestamp.now(),
//           'category': 'خرج',
//           'status': 'سلفة',
//           'source': 'السلف',
//           'sourceId': loanDoc.id,
//           'note': _noteController.text,
//           'paymentType': selectedPaymentType,
//         };

//         await _firestore.collection('treasury_exits').add(treasuryExitData);

//         // 3. تحديث الرصيد المحلي
//         setState(() => _treasuryBalance -= amount);

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("تم إضافة السلفة بنجاح وخصمها من الخزنة"),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         // ========== تحديث موجود ==========
//         final oldAmount = (oldData!['amount'] as num).toDouble();
//         final amountDifference = amount - oldAmount;

//         // 1. تحديث في السلف
//         await _firestore.collection("loans").doc(docId).update(loanData);

//         // 2. تحديث في الخزنة (بنفس طريقة النثريات)
//         final exitSnapshot = await _firestore
//             .collection('treasury_exits')
//             .where('sourceId', isEqualTo: docId)
//             .limit(1)
//             .get();

//         if (exitSnapshot.docs.isNotEmpty) {
//           await _firestore
//               .collection('treasury_exits')
//               .doc(exitSnapshot.docs.first.id)
//               .update({
//                 'amount': amount,
//                 'description': 'سلفة لـ ${_recipientController.text}',
//                 'recipient': _recipientController.text,
//                 'date': Timestamp.fromDate(selectedDate),
//                 'updatedAt': Timestamp.now(),
//                 'paymentType': selectedPaymentType,
//               });
//         }

//         // 3. تحديث الرصيد إذا تغير المبلغ
//         if (amountDifference != 0) {
//           if (amountDifference > 0) {
//             // زيادة المزيد من الخزنة
//             if (amountDifference > _treasuryBalance) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text("لا يمكن زيادة المبلغ، الرصيد غير كافي"),
//                 ),
//               );
//               return;
//             }
//             setState(() => _treasuryBalance -= amountDifference);
//           } else {
//             // إرجاع جزء من المبلغ للخزنة
//             setState(() => _treasuryBalance += -amountDifference);
//           }
//         }

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("تم تحديث السلفة بنجاح"),
//             backgroundColor: Colors.blue,
//           ),
//         );
//       }

//       Navigator.pop(context);
//       _resetForm();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("حدث خطأ: $e"), backgroundColor: Colors.red),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   // ================= حذف سلفة مع ربط بالخزنة =================
//   Future<void> _confirmDelete(
//     String docId,
//     String recipient,
//     double amount,
//   ) async {
//     return showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("تأكيد الحذف"),
//           content: Text(
//             "هل أنت متأكد من حذف سلفة '$recipient' بقيمة ${amount.toStringAsFixed(2)} ج؟",
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("إلغاء"),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.pop(context);
//                 try {
//                   // 1. البحث عن الخروج المقابل في الخزنة وحذفه
//                   final exitSnapshot = await _firestore
//                       .collection('treasury_exits')
//                       .where('sourceId', isEqualTo: docId)
//                       .limit(1)
//                       .get();

//                   if (exitSnapshot.docs.isNotEmpty) {
//                     await _firestore
//                         .collection('treasury_exits')
//                         .doc(exitSnapshot.docs.first.id)
//                         .delete();

//                     // 2. إعادة المبلغ للخزنة
//                     setState(() => _treasuryBalance += amount);
//                   }

//                   // 3. حذف من السلف
//                   await _firestore.collection("loans").doc(docId).delete();

//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text("تم حذف السلفة بنجاح وإرجاع المبلغ للخزنة"),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 } catch (e) {
//                   debugPrint('Error deleting loan: $e');
//                 }
//               },
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//               child: const Text("حذف", style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ================= إنشاء PDF =================

//   // ================== GENERATE PDF ==================
//   Future<void> _generatePDF() async {
//     if (_arabicFont == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('الخط العربي غير محمل')));
//       return;
//     }

//     setState(() => _isGeneratingPDF = true);

//     try {
//       final loans = await _fetchLoansForPDF();

//       if (loans.isEmpty) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('لا توجد سلفات للطباعة')));
//         return;
//       }

//       final pdf = pdfLib.Document(
//         theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
//       );

//       pdf.addPage(
//         pdfLib.MultiPage(
//           pageFormat: PdfPageFormat.a4,
//           margin: const pdfLib.EdgeInsets.all(15),
//           build: (context) => [
//             _buildPdfHeader(),
//             pdfLib.SizedBox(height: 8),
//             _buildPdfTitle(),
//             pdfLib.SizedBox(height: 12),
//             _buildPdfTable(loans),
//             pdfLib.SizedBox(height: 12),
//             _buildPdfTotalSection(loans),
//           ],
//         ),
//       );

//       await Printing.layoutPdf(
//         name: 'السلفات_${_getPDFFileName()}',
//         onLayout: (format) async => pdf.save(),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('خطأ في إنشاء PDF: $e')));
//     } finally {
//       setState(() => _isGeneratingPDF = false);
//     }
//   }

//   // ================== FETCH DATA ==================
//   Future<List<Map<String, dynamic>>> _fetchLoansForPDF() async {
//     try {
//       final snapshot = await _firestore
//           .collection("loans")
//           .orderBy('date', descending: true)
//           .get();

//       final List<Map<String, dynamic>> loans = [];

//       for (var doc in snapshot.docs) {
//         final data = doc.data() as Map<String, dynamic>;
//         final date = (data['date'] as Timestamp).toDate();

//         if (_applyPDFFilter(date)) {
//           loans.add({
//             'id': doc.id,
//             'recipient': data['recipient'] ?? '',
//             'amount': data['amount'] ?? 0.0,
//             'paymentType': data['paymentType'] ?? 'نقدي',
//             'note': data['note'] ?? '',
//             'formattedDate': DateFormat('yyyy/MM/dd').format(date),
//           });
//         }
//       }
//       return loans;
//     } catch (e) {
//       debugPrint('PDF Error: $e');
//       return [];
//     }
//   }

//   // ================== FILTER ==================
//   bool _applyPDFFilter(DateTime date) {
//     final now = DateTime.now();
//     switch (_timeFilter) {
//       case 'اليوم':
//         return date.year == now.year &&
//             date.month == now.month &&
//             date.day == now.day;
//       case 'هذا الشهر':
//         return date.year == now.year && date.month == now.month;
//       case 'هذه السنة':
//         return date.year == now.year;
//       case 'مخصص':
//         return date.month == _selectedMonth && date.year == _selectedYear;
//       default:
//         return true;
//     }
//   }

//   // ================== HEADER ==================
//   pdfLib.Widget _buildPdfHeader() {
//     return pdfLib.Directionality(
//       textDirection: pdfLib.TextDirection.rtl,
//       child: pdfLib.Column(
//         children: [
//           pdfLib.Row(
//             mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
//             children: [
//               pdfLib.Text(
//                 'FN 455.5 - 203/317/22',
//                 style: pdfLib.TextStyle(
//                   fontSize: 12,
//                   fontWeight: pdfLib.FontWeight.bold,
//                   font: _arabicFont,
//                 ),
//               ),
//               pdfLib.Text(
//                 'سجل السلفات',
//                 style: pdfLib.TextStyle(
//                   fontSize: 18,
//                   fontWeight: pdfLib.FontWeight.bold,
//                   font: _arabicFont,
//                 ),
//               ),
//             ],
//           ),
//           pdfLib.Divider(thickness: 1.5),
//         ],
//       ),
//     );
//   }

//   // ================== TITLE ==================
//   pdfLib.Widget _buildPdfTitle() {
//     return pdfLib.Directionality(
//       textDirection: pdfLib.TextDirection.rtl,
//       child: pdfLib.Column(
//         children: [
//           pdfLib.Text(
//             'السلفات لشهر $_selectedMonth',
//             style: pdfLib.TextStyle(
//               fontSize: 14,
//               fontWeight: pdfLib.FontWeight.bold,
//               font: _arabicFont,
//             ),
//           ),
//           pdfLib.SizedBox(height: 4),
//           pdfLib.Text(
//             'تاريخ الطباعة: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}',
//             style: pdfLib.TextStyle(fontSize: 11, font: _arabicFont),
//           ),
//         ],
//       ),
//     );
//   }

//   // ================== TABLE ==================
//   pdfLib.Widget _buildPdfTable(List<Map<String, dynamic>> loans) {
//     return pdfLib.Directionality(
//       textDirection: pdfLib.TextDirection.rtl,
//       child: pdfLib.Transform.scale(
//         scale: 0.9,
//         child: pdfLib.Table(
//           border: pdfLib.TableBorder.all(width: 1),
//           columnWidths: const {
//             0: pdfLib.FlexColumnWidth(2.5),
//             1: pdfLib.FlexColumnWidth(1.3),
//             2: pdfLib.FlexColumnWidth(1.2),
//             3: pdfLib.FlexColumnWidth(1.3),
//             4: pdfLib.FlexColumnWidth(1.7),
//             5: pdfLib.FlexColumnWidth(0.6),
//           },
//           children: [
//             pdfLib.TableRow(
//               decoration: const pdfLib.BoxDecoration(color: PdfColors.grey300),
//               children: [
//                 _buildPdfHeaderCell('ملاحظات'),
//                 _buildPdfHeaderCell('الدفع'),
//                 _buildPdfHeaderCell('المبلغ'),
//                 _buildPdfHeaderCell('التاريخ'),
//                 _buildPdfHeaderCell('المستلم'),
//                 _buildPdfHeaderCell('م'),
//               ],
//             ),
//             ...loans.asMap().entries.map((e) {
//               final i = e.key + 1;
//               final l = e.value;
//               return pdfLib.TableRow(
//                 children: [
//                   _buildPdfDataCell(
//                     l['note'].isEmpty ? '-' : l['note'],
//                     align: pdfLib.TextAlign.right,
//                   ),
//                   _buildPdfDataCell(l['paymentType']),
//                   _buildPdfDataCell(
//                     (l['amount'] as double).toStringAsFixed(2),
//                     bold: true,
//                   ),
//                   _buildPdfDataCell(l['formattedDate']),
//                   _buildPdfDataCell(
//                     l['recipient'],
//                     align: pdfLib.TextAlign.right,
//                   ),
//                   _buildPdfDataCell(i.toString()),
//                 ],
//               );
//             }).toList(),
//           ],
//         ),
//       ),
//     );
//   }

//   // ================== TOTAL ==================
//   pdfLib.Widget _buildPdfTotalSection(List<Map<String, dynamic>> loans) {
//     final total = loans.fold(0.0, (s, l) => s + (l['amount'] as double));

//     return pdfLib.Directionality(
//       textDirection: pdfLib.TextDirection.rtl,
//       child: pdfLib.Container(
//         padding: const pdfLib.EdgeInsets.all(8),
//         decoration: pdfLib.BoxDecoration(border: pdfLib.Border.all()),
//         child: pdfLib.Row(
//           mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
//           children: [
//             pdfLib.Text(
//               'الإجمالي',
//               style: pdfLib.TextStyle(
//                 fontSize: 13,
//                 fontWeight: pdfLib.FontWeight.bold,
//                 font: _arabicFont,
//               ),
//             ),
//             pdfLib.Text(
//               '${total.toStringAsFixed(2)} ج',
//               style: pdfLib.TextStyle(
//                 fontSize: 14,
//                 fontWeight: pdfLib.FontWeight.bold,
//                 font: _arabicFont,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ================== CELLS ==================
//   pdfLib.Widget _buildPdfHeaderCell(String text) {
//     return pdfLib.Padding(
//       padding: const pdfLib.EdgeInsets.all(4),
//       child: pdfLib.Text(
//         text,
//         textAlign: pdfLib.TextAlign.center,
//         style: pdfLib.TextStyle(
//           fontSize: 11,
//           fontWeight: pdfLib.FontWeight.bold,
//           font: _arabicFont,
//         ),
//       ),
//     );
//   }

//   pdfLib.Widget _buildPdfDataCell(
//     String text, {
//     pdfLib.TextAlign align = pdfLib.TextAlign.center,
//     bool bold = false,
//   }) {
//     return pdfLib.Padding(
//       padding: const pdfLib.EdgeInsets.all(4),
//       child: pdfLib.Text(
//         text,
//         maxLines: 2,
//         overflow: pdfLib.TextOverflow.clip,
//         textAlign: align,
//         style: pdfLib.TextStyle(
//           fontSize: 10,
//           fontWeight: bold ? pdfLib.FontWeight.bold : pdfLib.FontWeight.normal,
//           font: _arabicFont,
//         ),
//       ),
//     );
//   }

//   // ================== FILE NAME ==================
//   String _getPDFFileName() {
//     return DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
//   }

//   // ================= فتح نافذة إضافة/تعديل =================
//   Future<void> _openLoanSheet({
//     String? docId,
//     Map<String, dynamic>? data,
//   }) async {
//     _editingDocId = docId ?? "";

//     if (data != null) {
//       // وضع التعديل
//       _recipientController.text = data['recipient'];
//       _amountController.text = data['amount'].toString();
//       _noteController.text = data['note'] ?? '';
//       selectedPaymentType = data['paymentType'] ?? 'نقدي';
//       selectedDate = (data['date'] as Timestamp).toDate();
//     } else {
//       // وضع الإضافة
//       _recipientController.clear();
//       _amountController.clear();
//       _noteController.clear();
//       selectedPaymentType = "نقدي";
//       selectedDate = DateTime.now();
//     }

//     await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(
//             docId == null ? "إضافة سلفة جديدة" : "تعديل السلفة",
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // عرض رصيد الخزنة
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.blue[50],
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.blue[200]!),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.account_balance_wallet,
//                         color: Colors.blue[800],
//                       ),
//                       const SizedBox(width: 10),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               "الرصيد المتاح في الخزنة",
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.blue,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               "${_treasuryBalance.toStringAsFixed(2)} ج",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: _treasuryBalance > 1000
//                                     ? Colors.green[800]
//                                     : Colors.red[800],
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // التاريخ
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade300),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(
//                         Icons.calendar_today,
//                         size: 20,
//                         color: Colors.blue,
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Text(
//                               "التاريخ",
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                             Text(
//                               DateFormat('yyyy/MM/dd').format(selectedDate),
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () async {
//                           final DateTime? picked = await showDatePicker(
//                             context: context,
//                             initialDate: selectedDate,
//                             firstDate: DateTime(2000),
//                             lastDate: DateTime(2100),
//                           );
//                           if (picked != null) {
//                             setState(() {
//                               selectedDate = picked;
//                             });
//                           }
//                         },
//                         icon: const Icon(Icons.edit, size: 20),
//                         style: IconButton.styleFrom(
//                           backgroundColor: Colors.blue.shade50,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // اسم الشخص
//                 TextField(
//                   controller: _recipientController,
//                   decoration: InputDecoration(
//                     labelText: "اسم الشخص *",
//                     prefixIcon: const Icon(Icons.person, color: Colors.blue),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // المبلغ
//                 TextField(
//                   controller: _amountController,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     labelText: "المبلغ *",
//                     prefixText: "ج ",
//                     prefixIcon: const Icon(
//                       Icons.attach_money,
//                       color: Colors.red,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     suffixText: "ج",
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // طريقة الدفع
//                 DropdownButtonFormField<String>(
//                   value: selectedPaymentType,
//                   decoration: InputDecoration(
//                     labelText: "طريقة الدفع",
//                     prefixIcon: const Icon(Icons.payment, color: Colors.purple),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   items: _paymentTypes.map((type) {
//                     return DropdownMenuItem<String>(
//                       value: type['name'],
//                       child: Row(
//                         children: [
//                           Icon(type['icon'], color: type['color'], size: 20),
//                           const SizedBox(width: 12),
//                           Text(type['name']),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     if (value != null) {
//                       setState(() {
//                         selectedPaymentType = value;
//                       });
//                     }
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // الملاحظات
//                 TextField(
//                   controller: _noteController,
//                   maxLines: 3,
//                   decoration: InputDecoration(
//                     labelText: "ملاحظات",
//                     prefixIcon: const Icon(Icons.note, color: Colors.orange),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     hintText: "أضف ملاحظات حول السلفة...",
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _resetForm();
//               },
//               child: const Text("إلغاء"),
//             ),
//             ElevatedButton(
//               onPressed: _isLoading ? null : () async => _saveLoan(docId, data),
//               child: _isLoading
//                   ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     )
//                   : Text(docId == null ? "إضافة" : "تحديث"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ================= فلترة حسب التاريخ =================
//   List<QueryDocumentSnapshot> _filterLoansByDate(
//     List<QueryDocumentSnapshot> allDocs,
//   ) {
//     return allDocs.where((doc) {
//       final data = doc.data() as Map<String, dynamic>;
//       final date = (data['date'] as Timestamp).toDate();

//       if (_timeFilter == 'الكل') return true;

//       final now = DateTime.now();
//       switch (_timeFilter) {
//         case 'اليوم':
//           return date.year == now.year &&
//               date.month == now.month &&
//               date.day == now.day;
//         case 'هذا الشهر':
//           return date.year == now.year && date.month == now.month;
//         case 'هذه السنة':
//           return date.year == now.year;
//         case 'مخصص':
//           return date.year == _selectedYear && date.month == _selectedMonth;
//         default:
//           return true;
//       }
//     }).toList();
//   }

//   void _applyMonthYearFilter() {
//     setState(() => _timeFilter = 'مخصص');
//   }

//   // ================= AppBar مخصص =================
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
//         bottom: false,
//         child: Row(
//           children: [
//             const Icon(Icons.credit_card, color: Colors.white, size: 28),
//             const SizedBox(width: 12),
//             const Text(
//               'إدارة السلفات',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const Spacer(),
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
//                           '${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} $period',
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
//                           if (selected) {
//                             setState(() => _timeFilter = filter);
//                           }
//                         },
//                         selectedColor: const Color(0xFF27AE60),
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
//               const Icon(Icons.calendar_month, color: Color(0xFF27AE60)),
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

//   Widget _buildStats(List<QueryDocumentSnapshot> docs) {
//     double total = 0;
//     double cashTotal = 0;
//     double transferTotal = 0;
//     double checkTotal = 0;

//     for (var doc in docs) {
//       final data = doc.data() as Map<String, dynamic>;
//       final amount = data['amount'] as double;
//       final paymentType = data['paymentType'] as String;

//       total += amount;

//       switch (paymentType) {
//         case 'نقدي':
//           cashTotal += amount;
//           break;
//         case 'تحويل بنكي':
//           transferTotal += amount;
//           break;
//         case 'شيك':
//           checkTotal += amount;
//           break;
//       }
//     }

//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "إحصائيات السلفات",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.blue.shade50,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Column(
//                       children: [
//                         const Text(
//                           "المجموع الكلي",
//                           style: TextStyle(fontSize: 12),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           "${total.toStringAsFixed(2)} ج",
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: Colors.blue,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.green.shade50,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Column(
//                       children: [
//                         const Text("نقدي", style: TextStyle(fontSize: 12)),
//                         const SizedBox(height: 4),
//                         Text(
//                           "${cashTotal.toStringAsFixed(2)} ج",
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: Colors.green,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.blue.shade50,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Column(
//                       children: [
//                         const Text("تحويل", style: TextStyle(fontSize: 12)),
//                         const SizedBox(height: 4),
//                         Text(
//                           "${transferTotal.toStringAsFixed(2)} ج",
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: Colors.blue,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.orange.shade50,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Column(
//                       children: [
//                         const Text("شيك", style: TextStyle(fontSize: 12)),
//                         const SizedBox(height: 4),
//                         Text(
//                           "${checkTotal.toStringAsFixed(2)} ج",
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                             color: Colors.orange,
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

//   Widget _buildLoanCard(QueryDocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;
//     final docId = doc.id;
//     final date = (data['date'] as Timestamp).toDate();
//     final paymentType = data['paymentType'] as String;

//     Color paymentColor;
//     IconData paymentIcon;

//     switch (paymentType) {
//       case 'نقدي':
//         paymentColor = Colors.green;
//         paymentIcon = Icons.money;
//         break;
//       case 'تحويل بنكي':
//         paymentColor = Colors.blue;
//         paymentIcon = Icons.account_balance;
//         break;
//       case 'شيك':
//         paymentColor = Colors.orange;
//         paymentIcon = Icons.description;
//         break;
//       default:
//         paymentColor = Colors.grey;
//         paymentIcon = Icons.more_horiz;
//     }

//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: paymentColor.withOpacity(0.1),
//           child: Icon(paymentIcon, color: paymentColor, size: 20),
//         ),
//         title: Text(
//           data['recipient'],
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 4),
//             Row(
//               children: [
//                 Icon(paymentIcon, size: 16, color: paymentColor),
//                 const SizedBox(width: 4),
//                 Text(
//                   paymentType,
//                   style: TextStyle(fontSize: 14, color: paymentColor),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 2),
//             Text(
//               "${data['amount'].toStringAsFixed(2)} ج",
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue,
//               ),
//             ),
//             const SizedBox(height: 2),
//             Text(
//               DateFormat('yyyy/MM/dd').format(date),
//               style: const TextStyle(fontSize: 12),
//             ),
//             if (data['note'] != null && data['note'].isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.only(top: 4),
//                 child: Text(
//                   data['note'],
//                   style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//                 ),
//               ),
//           ],
//         ),
//         trailing: PopupMenuButton<String>(
//           icon: const Icon(Icons.more_vert),
//           onSelected: (value) async {
//             if (value == 'edit') {
//               await _openLoanSheet(docId: docId, data: data);
//             } else if (value == 'delete') {
//               await _confirmDelete(
//                 docId,
//                 data['recipient'],
//                 (data['amount'] as double),
//               );
//             }
//           },
//           itemBuilder: (BuildContext context) {
//             return [
//               const PopupMenuItem<String>(
//                 value: 'edit',
//                 child: Row(
//                   children: [
//                     Icon(Icons.edit, size: 20),
//                     SizedBox(width: 8),
//                     Text('تعديل'),
//                   ],
//                 ),
//               ),
//               const PopupMenuItem<String>(
//                 value: 'delete',
//                 child: Row(
//                   children: [
//                     Icon(Icons.delete, color: Colors.red, size: 20),
//                     SizedBox(width: 8),
//                     Text('حذف', style: TextStyle(color: Colors.red)),
//                   ],
//                 ),
//               ),
//             ];
//           },
//         ),
//       ),
//     );
//   }

//   void _resetForm() {
//     _recipientController.clear();
//     _amountController.clear();
//     _noteController.clear();
//     selectedPaymentType = "نقدي";
//     selectedDate = DateTime.now();
//     _editingDocId = "";
//   }

//   @override
//   void dispose() {
//     _recipientController.dispose();
//     _amountController.dispose();
//     _noteController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6F8),
//       body: Column(
//         children: [
//           _buildCustomAppBar(),
//           _buildTimeFilterSection(),
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream: _firestore
//                   .collection("loans")
//                   .orderBy('date', descending: true)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 List<QueryDocumentSnapshot> allDocs = snapshot.data!.docs;
//                 List<QueryDocumentSnapshot> filteredDocs = _filterLoansByDate(
//                   allDocs,
//                 );

//                 if (snapshot.data!.docs.isEmpty) {
//                   return Column(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         margin: const EdgeInsets.all(8),
//                         decoration: BoxDecoration(
//                           color: Colors.blue.shade50,
//                           borderRadius: BorderRadius.circular(8),
//                           border: Border.all(color: Colors.blue.shade100),
//                         ),
//                         child: Row(
//                           children: [
//                             Icon(
//                               Icons.account_balance_wallet,
//                               color: Colors.blue[800],
//                             ),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     "رصيد الخزنة الحالي",
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.blue,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     "${_treasuryBalance.toStringAsFixed(2)} ج",
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: _treasuryBalance > 1000
//                                           ? Colors.green[800]
//                                           : Colors.red[800],
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Expanded(
//                         child: Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const Icon(
//                                 Icons.credit_card,
//                                 size: 80,
//                                 color: Colors.grey,
//                               ),
//                               const SizedBox(height: 16),
//                               const Text(
//                                 "لا توجد سلفات",
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Text(
//                                 "انقر على زر + لإضافة أول سلفة",
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.grey.shade600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   );
//                 }

//                 return Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       margin: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.blue.shade50,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.blue.shade100),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.account_balance_wallet,
//                             color: Colors.blue[800],
//                           ),
//                           const SizedBox(width: 10),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   "رصيد الخزنة الحالي",
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.blue,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   "${_treasuryBalance.toStringAsFixed(2)} ج",
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: _treasuryBalance > 1000
//                                         ? Colors.green[800]
//                                         : Colors.red[800],
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     _buildStats(filteredDocs),
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount: filteredDocs.length,
//                         itemBuilder: (context, index) {
//                           final doc = filteredDocs[index];
//                           return _buildLoanCard(doc);
//                         },
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             heroTag: 'pdf_btn_loans',
//             onPressed: _isGeneratingPDF ? null : _generatePDF,
//             backgroundColor: _isGeneratingPDF ? Colors.grey : Colors.red,
//             mini: true,
//             child: _isGeneratingPDF
//                 ? const CircularProgressIndicator(color: Colors.white)
//                 : const Icon(Icons.picture_as_pdf, color: Colors.white),
//           ),
//           const SizedBox(width: 10),
//           FloatingActionButton.extended(
//             onPressed: () {
//               if (_treasuryBalance <= 0) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text("لا يمكن إضافة سلفة - رصيد الخزنة غير كافي"),
//                     backgroundColor: Colors.red,
//                   ),
//                 );
//                 return;
//               }
//               _openLoanSheet();
//             },
//             icon: const Icon(Icons.add),
//             label: const Text("إضافة سلفة"),
//             backgroundColor: const Color(0xFF27AE60),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart' as x;

class LoansPage extends StatefulWidget {
  const LoansPage({super.key});

  @override
  State<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends State<LoansPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _paymentAmountController =
      TextEditingController();

  // ================= أنواع الدفع =================
  final List<Map<String, dynamic>> _paymentTypes = [
    {'name': 'نقدي', 'icon': Icons.money, 'color': Colors.green},
    {'name': 'تحويل بنكي', 'icon': Icons.account_balance, 'color': Colors.blue},
    {'name': 'شيك', 'icon': Icons.description, 'color': Colors.orange},
  ];

  String selectedPaymentType = "نقدي";
  String selectedPaymentTypeForSettlement = "نقدي";
  DateTime selectedDate = DateTime.now();
  String _editingDocId = "";
  bool _isLoading = false;
  bool _isGeneratingPDF = false;
  bool _isProcessingPayment = false;
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

      // مجموع الخرج (المصروفات + السلف)
      final expensesSnapshot = await _firestore
          .collection('treasury_exits')
          .get();

      double totalExpense = 0;
      for (var doc in expensesSnapshot.docs) {
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

  // ================= إضافة/تعديل سلفة =================
  Future<void> _saveLoan(String? docId, Map<String, dynamic>? oldData) async {
    if (_recipientController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("الرجاء إدخال اسم المستلم")));
      return;
    }

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
      // بيانات السلفة للنثريات
      final loanData = {
        "recipient": _recipientController.text,
        "amount": amount,
        "originalAmount": amount, // لحفظ المبلغ الأصلي
        "paidAmount": 0.0, // المبلغ المدفوع
        "remainingAmount": amount, // المبلغ المتبقي
        "paymentType": selectedPaymentType,
        "note": _noteController.text,
        "date": Timestamp.fromDate(selectedDate),
        "status": "مستحقة", // مستحقة، مدفوعة جزئياً، مكتملة
        "updatedAt": Timestamp.now(),
        "createdAt": Timestamp.now(),
      };

      if (docId == null) {
        // ========== إضافة جديد ==========
        // 1. إضافة في السلف
        final loanDoc = await _firestore.collection("loans").add(loanData);

        // 2. إضافة في خزنة الخرج كـ "سلفة" - بنفس طريقة النثريات
        final treasuryExitData = {
          'amount': amount,
          'expenseType': 'سلفة',
          'description': 'سلفة لـ ${_recipientController.text}',
          'recipient': _recipientController.text,
          'date': Timestamp.fromDate(selectedDate),
          'createdAt': Timestamp.now(),
          'category': 'خرج',
          'status': 'سلفة',
          'source': 'السلف',
          'sourceId': loanDoc.id,
          'note': _noteController.text,
          'paymentType': selectedPaymentType,
        };

        await _firestore.collection('treasury_exits').add(treasuryExitData);

        // 3. تحديث الرصيد المحلي
        setState(() => _treasuryBalance -= amount);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم إضافة السلفة بنجاح وخصمها من الخزنة"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // ========== تحديث موجود ==========
        final oldAmount =
            (oldData!['originalAmount'] ?? oldData['amount'] as num).toDouble();
        final amountDifference = amount - oldAmount;

        // 1. تحديث في السلف
        await _firestore.collection("loans").doc(docId).update({
          ...loanData,
          'originalAmount': amount,
          'remainingAmount': amount - (oldData['paidAmount'] ?? 0.0),
        });

        // 2. تحديث في الخزنة (بنفس طريقة النثريات)
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
                'description': 'سلفة لـ ${_recipientController.text}',
                'recipient': _recipientController.text,
                'date': Timestamp.fromDate(selectedDate),
                'updatedAt': Timestamp.now(),
                'paymentType': selectedPaymentType,
              });
        }

        // 3. تحديث الرصيد إذا تغير المبلغ
        if (amountDifference != 0) {
          if (amountDifference > 0) {
            // زيادة المزيد من الخزنة
            if (amountDifference > _treasuryBalance) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
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
            content: Text("تم تحديث السلفة بنجاح"),
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

  // ================= سداد السلفة =================
  Future<void> _makePayment(String docId, Map<String, dynamic> loanData) async {
    final recipient = loanData['recipient'] ?? '';
    final remainingAmount =
        (loanData['remainingAmount'] ?? loanData['amount'] as num).toDouble();
    final paidAmount = (loanData['paidAmount'] ?? 0.0) as double;
    final originalAmount =
        (loanData['originalAmount'] ?? loanData['amount'] as num).toDouble();
    String paymentType = 'كامل'; // كامل أو جزئي
    double paymentAmount = remainingAmount; // القيمة الافتراضية كاملة

    if (remainingAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("هذه السلفة مدفوعة بالكامل")),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Directionality(
            textDirection: x.TextDirection.rtl,
            child: AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.payment, color: Colors.green),
                  SizedBox(width: 8),
                  Text('سداد سلفة - $recipient'),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // معلومات السلفة
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
                              Text('المبلغ الأصلي:'),
                              Text(
                                '${originalAmount.toStringAsFixed(2)} ج',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('المدفوع:'),
                              Text(
                                '${paidAmount.toStringAsFixed(2)} ج',
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
                              Text('المتبقي:'),
                              Text(
                                '${remainingAmount.toStringAsFixed(2)} ج',
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
                    SizedBox(height: 16),

                    // نوع السداد
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
                                _paymentAmountController.text = remainingAmount
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
                                _paymentAmountController.clear();
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

                    // مبلغ السداد
                    TextFormField(
                      controller: _paymentAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: paymentType == 'كامل'
                            ? 'المبلغ الكامل'
                            : 'المبلغ المطلوب دفعه',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        prefixIcon: Icon(Icons.attach_money),
                        suffixText: 'ج',
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          final enteredAmount = double.tryParse(value) ?? 0.0;
                          if (enteredAmount == remainingAmount) {
                            setState(() => paymentType = 'كامل');
                          } else if (enteredAmount > 0 &&
                              enteredAmount < remainingAmount) {
                            setState(() => paymentType = 'جزئي');
                          }
                        }
                      },
                    ),
                    SizedBox(height: 16),

                    // طريقة الدفع للسداد
                    DropdownButtonFormField<String>(
                      value: selectedPaymentTypeForSettlement,
                      decoration: InputDecoration(
                        labelText: "طريقة السداد",
                        prefixIcon: Icon(Icons.payment, color: Colors.purple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: _paymentTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type['name'],
                          child: Row(
                            children: [
                              Icon(
                                type['icon'],
                                color: type['color'],
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(type['name']),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedPaymentTypeForSettlement = value;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16),

                    // ملاحظات السداد
                    TextField(
                      controller: _noteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: "ملاحظات السداد",
                        prefixIcon: Icon(Icons.note, color: Colors.orange),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: "أضف ملاحظات حول عملية السداد...",
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _paymentAmountController.clear();
                    _noteController.clear();
                  },
                  child: Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: _isProcessingPayment
                      ? null
                      : () async {
                          final paymentAmount =
                              double.tryParse(_paymentAmountController.text) ??
                              0.0;

                          if (paymentAmount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("أدخل مبلغ صحيح")),
                            );
                            return;
                          }

                          if (paymentAmount > remainingAmount) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("المبلغ أكبر من المبلغ المتبقي"),
                              ),
                            );
                            return;
                          }

                          // تأكيد السداد
                          final confirmed = await _showPaymentConfirmation(
                            recipient: recipient,
                            amount: paymentAmount,
                            paymentType: paymentType,
                            paymentMethod: selectedPaymentTypeForSettlement,
                          );

                          if (confirmed) {
                            setState(() => _isProcessingPayment = true);
                            await _processPayment(
                              docId,
                              loanData,
                              paymentAmount,
                              paymentType,
                              selectedPaymentTypeForSettlement,
                            );
                            setState(() => _isProcessingPayment = false);
                            Navigator.pop(context);
                            _paymentAmountController.clear();
                            _noteController.clear();
                          }
                        },
                  child: _isProcessingPayment
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('سداد ($paymentType)'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= تأكيد السداد =================
  Future<bool> _showPaymentConfirmation({
    required String recipient,
    required double amount,
    required String paymentType,
    required String paymentMethod,
  }) async {
    bool confirmed = false;

    await showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: x.TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(Icons.payment, color: Colors.green),
              SizedBox(width: 8),
              Text('تأكيد السداد'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('هل أنت متأكد من سداد ${amount.toStringAsFixed(2)} ج'),
              Text('لـ $recipient؟'),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تفاصيل السداد ($paymentType)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('المستلم: $recipient'),
                    Text('المبلغ: ${amount.toStringAsFixed(2)} ج'),
                    Text('نوع السداد: $paymentType'),
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
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'سيتم إضافة المبلغ للخزنة تلقائياً',
                  style: TextStyle(color: Colors.blue[800]),
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('تأكيد السداد ($paymentType)'),
            ),
          ],
        ),
      ),
    );

    return confirmed;
  }

  // ================= معالجة عملية السداد =================
  Future<void> _processPayment(
    String docId,
    Map<String, dynamic> loanData,
    double paymentAmount,
    String paymentType,
    String paymentMethod,
  ) async {
    try {
      final originalAmount =
          (loanData['originalAmount'] ?? loanData['amount'] as num).toDouble();
      final currentPaidAmount = (loanData['paidAmount'] ?? 0.0) as double;
      final currentRemainingAmount =
          (loanData['remainingAmount'] ?? loanData['amount'] as num).toDouble();

      final newPaidAmount = currentPaidAmount + paymentAmount;
      final newRemainingAmount = originalAmount - newPaidAmount;

      // تحديث حالة السلفة
      String newStatus;
      if (newRemainingAmount <= 0) {
        newStatus = 'مكتملة';
      } else if (newPaidAmount > 0 && newRemainingAmount > 0) {
        newStatus = 'مدفوعة جزئياً';
      } else {
        newStatus = 'مستحقة';
      }

      // 1. تحديث السلفة
      await _firestore.collection("loans").doc(docId).update({
        'paidAmount': newPaidAmount,
        'remainingAmount': newRemainingAmount,
        'status': newStatus,
        'lastPaymentDate': Timestamp.now(),
        'lastPaymentAmount': paymentAmount,
        'updatedAt': Timestamp.now(),
      });

      // 2. إضافة دفعة جديدة في مجموعة منفصلة للسداد
      final paymentData = {
        'loanId': docId,
        'recipient': loanData['recipient'],
        'amount': paymentAmount,
        'paymentType': paymentMethod,
        'note': _noteController.text.isNotEmpty
            ? _noteController.text
            : 'سداد سلفة',
        'date': Timestamp.now(),
        'createdAt': Timestamp.now(),
        'settlementType': paymentType,
      };

      await _firestore.collection("loan_payments").add(paymentData);

      // 3. إضافة المبلغ للخزنة كدخل
      final treasuryEntryData = {
        'amount': paymentAmount,

        'description': 'سداد سلفة من ${loanData['recipient']} ($paymentType)',
        'entryType': 'سداد سلفة',
        'date': Timestamp.now(),
        'createdAt': Timestamp.now(),
        'category': 'دخل',
        'status': 'مكتمل',
        'recipient': loanData['recipient'],
        'paymentType': paymentMethod,
        'sourceId': docId,
        'note': _noteController.text.isNotEmpty
            ? _noteController.text
            : 'سداد سلفة',
      };

      await _firestore.collection('treasury_entries').add(treasuryEntryData);

      // 4. تحديث رصيد الخزنة
      setState(() => _treasuryBalance += paymentAmount);

      // 5. إضافة ملاحظة في السلفة الرئيسية
      if (_noteController.text.isNotEmpty) {
        final List<dynamic> existingNotes = loanData['paymentNotes'] ?? [];
        existingNotes.add({
          'date': Timestamp.now(),
          'amount': paymentAmount,
          'note': _noteController.text,
          'type': 'سداد',
        });

        await _firestore.collection("loans").doc(docId).update({
          'paymentNotes': existingNotes,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم سداد ${paymentAmount.toStringAsFixed(2)} ج بنجاح ($paymentType)',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // إعادة تحميل البيانات
      _loadTreasuryBalance();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في عملية السداد: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ================= حذف سلفة مع ربط بالخزنة =================
  Future<void> _confirmDelete(
    String docId,
    String recipient,
    double amount,
    double paidAmount,
  ) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("تأكيد الحذف"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "هل أنت متأكد من حذف سلفة '$recipient'؟",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text("المبلغ الأصلي: ${amount.toStringAsFixed(2)} ج"),
              Text("المبلغ المدفوع: ${paidAmount.toStringAsFixed(2)} ج"),
              Text(
                "المبلغ المتبقي: ${(amount - paidAmount).toStringAsFixed(2)} ج",
              ),
              SizedBox(height: 12),
              if (paidAmount > 0)
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'تحذير: هناك مدفوعات مسجلة لهذه السلفة',
                    style: TextStyle(color: Colors.orange[800]),
                  ),
                ),
            ],
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
                  }

                  // 2. البحث عن الدفعات وحذفها
                  final paymentsSnapshot = await _firestore
                      .collection('loan_payments')
                      .where('loanId', isEqualTo: docId)
                      .get();

                  for (var doc in paymentsSnapshot.docs) {
                    await doc.reference.delete();
                  }

                  // 3. حذف من السلف
                  await _firestore.collection("loans").doc(docId).delete();

                  // 4. إعادة المبلغ غير المدفوع للخزنة
                  final remainingAmount = amount - paidAmount;
                  if (remainingAmount > 0) {
                    setState(() => _treasuryBalance += remainingAmount);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("تم حذف السلفة بنجاح"),
                      backgroundColor: Colors.red,
                    ),
                  );
                } catch (e) {
                  debugPrint('Error deleting loan: $e');
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
      final loans = await _fetchLoansForPDF();

      if (loans.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('لا توجد سلفات للطباعة')));
        return;
      }

      final pdf = pdfLib.Document(
        theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
      );

      pdf.addPage(
        pdfLib.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pdfLib.EdgeInsets.all(15),
          build: (context) => [
            _buildPdfHeader(),
            pdfLib.SizedBox(height: 8),
            _buildPdfTitle(),
            pdfLib.SizedBox(height: 12),
            _buildPdfTable(loans),
            pdfLib.SizedBox(height: 12),
            _buildPdfTotalSection(loans),
          ],
        ),
      );

      await Printing.layoutPdf(
        name: 'السلفات_${_getPDFFileName()}',
        onLayout: (format) async => pdf.save(),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ في إنشاء PDF: $e')));
    } finally {
      setState(() => _isGeneratingPDF = false);
    }
  }

  // ================== FETCH DATA ==================
  Future<List<Map<String, dynamic>>> _fetchLoansForPDF() async {
    try {
      final snapshot = await _firestore
          .collection("loans")
          .orderBy('date', descending: true)
          .get();

      final List<Map<String, dynamic>> loans = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final date = (data['date'] as Timestamp).toDate();

        if (_applyPDFFilter(date)) {
          final originalAmount =
              (data['originalAmount'] ?? data['amount'] as num).toDouble();
          final paidAmount = (data['paidAmount'] ?? 0.0) as double;
          final remainingAmount = originalAmount - paidAmount;

          loans.add({
            'id': doc.id,
            'recipient': data['recipient'] ?? '',
            'amount': originalAmount,
            'paidAmount': paidAmount,
            'remainingAmount': remainingAmount,
            'status': data['status'] ?? 'مستحقة',
            'paymentType': data['paymentType'] ?? 'نقدي',
            'note': data['note'] ?? '',
            'formattedDate': DateFormat('yyyy/MM/dd').format(date),
          });
        }
      }
      return loans;
    } catch (e) {
      debugPrint('PDF Error: $e');
      return [];
    }
  }

  // ================== FILTER ==================
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
      default:
        return true;
    }
  }

  // ================== HEADER ==================
  pdfLib.Widget _buildPdfHeader() {
    return pdfLib.Directionality(
      textDirection: pdfLib.TextDirection.rtl,
      child: pdfLib.Column(
        children: [
          pdfLib.Row(
            mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
            children: [
              pdfLib.Text(
                'FN 455.5 - 203/317/22',
                style: pdfLib.TextStyle(
                  fontSize: 12,
                  fontWeight: pdfLib.FontWeight.bold,
                  font: _arabicFont,
                ),
              ),
              pdfLib.Text(
                'سجل السلفات',
                style: pdfLib.TextStyle(
                  fontSize: 18,
                  fontWeight: pdfLib.FontWeight.bold,
                  font: _arabicFont,
                ),
              ),
            ],
          ),
          pdfLib.Divider(thickness: 1.5),
        ],
      ),
    );
  }

  // ================== TITLE ==================
  pdfLib.Widget _buildPdfTitle() {
    return pdfLib.Directionality(
      textDirection: pdfLib.TextDirection.rtl,
      child: pdfLib.Column(
        children: [
          pdfLib.Text(
            'السلفات لشهر $_selectedMonth',
            style: pdfLib.TextStyle(
              fontSize: 14,
              fontWeight: pdfLib.FontWeight.bold,
              font: _arabicFont,
            ),
          ),
          pdfLib.SizedBox(height: 4),
          pdfLib.Text(
            'تاريخ الطباعة: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}',
            style: pdfLib.TextStyle(fontSize: 11, font: _arabicFont),
          ),
        ],
      ),
    );
  }

  // ================== TABLE ==================
  pdfLib.Widget _buildPdfTable(List<Map<String, dynamic>> loans) {
    return pdfLib.Directionality(
      textDirection: pdfLib.TextDirection.rtl,
      child: pdfLib.Transform.scale(
        scale: 0.9,
        child: pdfLib.Table(
          border: pdfLib.TableBorder.all(width: 1),
          columnWidths: const {
            0: pdfLib.FlexColumnWidth(2.5),
            1: pdfLib.FlexColumnWidth(1.3),
            2: pdfLib.FlexColumnWidth(1.2),
            3: pdfLib.FlexColumnWidth(1.2),
            4: pdfLib.FlexColumnWidth(1.2),
            5: pdfLib.FlexColumnWidth(1.3),
            6: pdfLib.FlexColumnWidth(1.3),
            7: pdfLib.FlexColumnWidth(0.6),
          },
          children: [
            pdfLib.TableRow(
              decoration: const pdfLib.BoxDecoration(color: PdfColors.grey300),
              children: [
                _buildPdfHeaderCell('ملاحظات'),
                _buildPdfHeaderCell('الحالة'),
                _buildPdfHeaderCell('المتبقي'),
                _buildPdfHeaderCell('المدفوع'),
                _buildPdfHeaderCell('المبلغ'),
                _buildPdfHeaderCell('الدفع'),
                _buildPdfHeaderCell('التاريخ'),
                _buildPdfHeaderCell('المستلم'),
                _buildPdfHeaderCell('م'),
              ],
            ),
            ...loans.asMap().entries.map((e) {
              final i = e.key + 1;
              final l = e.value;
              return pdfLib.TableRow(
                children: [
                  _buildPdfDataCell(
                    l['note'].isEmpty ? '-' : l['note'],
                    align: pdfLib.TextAlign.right,
                  ),
                  _buildPdfDataCell(
                    l['status'],
                    color: _getStatusColorForPDF(l['status']),
                  ),
                  _buildPdfDataCell(
                    (l['remainingAmount'] as double).toStringAsFixed(2),
                    color: PdfColors.red,
                    bold: true,
                  ),
                  _buildPdfDataCell(
                    (l['paidAmount'] as double).toStringAsFixed(2),
                    color: PdfColors.green,
                  ),
                  _buildPdfDataCell(
                    (l['amount'] as double).toStringAsFixed(2),
                    bold: true,
                  ),
                  _buildPdfDataCell(l['paymentType']),
                  _buildPdfDataCell(l['formattedDate']),
                  _buildPdfDataCell(
                    l['recipient'],
                    align: pdfLib.TextAlign.right,
                  ),
                  _buildPdfDataCell(i.toString()),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  PdfColor _getStatusColorForPDF(String status) {
    switch (status) {
      case 'مكتملة':
        return PdfColors.green;
      case 'مدفوعة جزئياً':
        return PdfColors.blue;
      case 'مستحقة':
        return PdfColors.orange;
      default:
        return PdfColors.black;
    }
  }

  // ================== TOTAL ==================
  pdfLib.Widget _buildPdfTotalSection(List<Map<String, dynamic>> loans) {
    final totalAmount = loans.fold(0.0, (s, l) => s + (l['amount'] as double));
    final totalPaid = loans.fold(
      0.0,
      (s, l) => s + (l['paidAmount'] as double),
    );
    final totalRemaining = totalAmount - totalPaid;

    return pdfLib.Directionality(
      textDirection: pdfLib.TextDirection.rtl,
      child: pdfLib.Column(
        children: [
          pdfLib.Container(
            padding: const pdfLib.EdgeInsets.all(8),
            decoration: pdfLib.BoxDecoration(border: pdfLib.Border.all()),
            child: pdfLib.Row(
              mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
              children: [
                pdfLib.Text(
                  'إجمالي المبلغ',
                  style: pdfLib.TextStyle(
                    fontSize: 13,
                    fontWeight: pdfLib.FontWeight.bold,
                    font: _arabicFont,
                  ),
                ),
                pdfLib.Text(
                  '${totalAmount.toStringAsFixed(2)} ج',
                  style: pdfLib.TextStyle(
                    fontSize: 14,
                    fontWeight: pdfLib.FontWeight.bold,
                    font: _arabicFont,
                  ),
                ),
              ],
            ),
          ),
          pdfLib.SizedBox(height: 4),
          pdfLib.Container(
            padding: const pdfLib.EdgeInsets.all(8),
            decoration: pdfLib.BoxDecoration(border: pdfLib.Border.all()),
            child: pdfLib.Row(
              mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
              children: [
                pdfLib.Text(
                  'إجمالي المدفوع',
                  style: pdfLib.TextStyle(
                    fontSize: 13,
                    fontWeight: pdfLib.FontWeight.bold,
                    font: _arabicFont,
                    color: PdfColors.green,
                  ),
                ),
                pdfLib.Text(
                  '${totalPaid.toStringAsFixed(2)} ج',
                  style: pdfLib.TextStyle(
                    fontSize: 14,
                    fontWeight: pdfLib.FontWeight.bold,
                    font: _arabicFont,
                    color: PdfColors.green,
                  ),
                ),
              ],
            ),
          ),
          pdfLib.SizedBox(height: 4),
          pdfLib.Container(
            padding: const pdfLib.EdgeInsets.all(8),
            decoration: pdfLib.BoxDecoration(border: pdfLib.Border.all()),
            child: pdfLib.Row(
              mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
              children: [
                pdfLib.Text(
                  'إجمالي المتبقي',
                  style: pdfLib.TextStyle(
                    fontSize: 13,
                    fontWeight: pdfLib.FontWeight.bold,
                    font: _arabicFont,
                    color: PdfColors.red,
                  ),
                ),
                pdfLib.Text(
                  '${totalRemaining.toStringAsFixed(2)} ج',
                  style: pdfLib.TextStyle(
                    fontSize: 14,
                    fontWeight: pdfLib.FontWeight.bold,
                    font: _arabicFont,
                    color: PdfColors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================== CELLS ==================
  pdfLib.Widget _buildPdfHeaderCell(String text) {
    return pdfLib.Padding(
      padding: const pdfLib.EdgeInsets.all(4),
      child: pdfLib.Text(
        text,
        textAlign: pdfLib.TextAlign.center,
        style: pdfLib.TextStyle(
          fontSize: 11,
          fontWeight: pdfLib.FontWeight.bold,
          font: _arabicFont,
        ),
      ),
    );
  }

  pdfLib.Widget _buildPdfDataCell(
    String text, {
    pdfLib.TextAlign align = pdfLib.TextAlign.center,
    bool bold = false,
    PdfColor? color,
  }) {
    return pdfLib.Padding(
      padding: const pdfLib.EdgeInsets.all(4),
      child: pdfLib.Text(
        text,
        maxLines: 2,
        overflow: pdfLib.TextOverflow.clip,
        textAlign: align,
        style: pdfLib.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pdfLib.FontWeight.bold : pdfLib.FontWeight.normal,
          font: _arabicFont,
          color: color,
        ),
      ),
    );
  }

  // ================== FILE NAME ==================
  String _getPDFFileName() {
    return DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
  }

  // ================= فتح نافذة إضافة/تعديل =================
  Future<void> _openLoanSheet({
    String? docId,
    Map<String, dynamic>? data,
  }) async {
    _editingDocId = docId ?? "";

    if (data != null) {
      // وضع التعديل
      _recipientController.text = data['recipient'];
      _amountController.text = (data['originalAmount'] ?? data['amount'])
          .toString();
      _noteController.text = data['note'] ?? '';
      selectedPaymentType = data['paymentType'] ?? 'نقدي';
      selectedDate = (data['date'] as Timestamp).toDate();
    } else {
      // وضع الإضافة
      _recipientController.clear();
      _amountController.clear();
      _noteController.clear();
      selectedPaymentType = "نقدي";
      selectedDate = DateTime.now();
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            docId == null ? "إضافة سلفة جديدة" : "تعديل السلفة",
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

                // اسم الشخص
                TextField(
                  controller: _recipientController,
                  decoration: InputDecoration(
                    labelText: "اسم الشخص *",
                    prefixIcon: const Icon(Icons.person, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // المبلغ
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "المبلغ *",
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

                // طريقة الدفع
                DropdownButtonFormField<String>(
                  value: selectedPaymentType,
                  decoration: InputDecoration(
                    labelText: "طريقة الدفع",
                    prefixIcon: const Icon(Icons.payment, color: Colors.purple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: _paymentTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type['name'],
                      child: Row(
                        children: [
                          Icon(type['icon'], color: type['color'], size: 20),
                          const SizedBox(width: 12),
                          Text(type['name']),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedPaymentType = value;
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
                    hintText: "أضف ملاحظات حول السلفة...",
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
              onPressed: _isLoading ? null : () async => _saveLoan(docId, data),
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

  // ================= فلترة حسب التاريخ =================
  List<QueryDocumentSnapshot> _filterLoansByDate(
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
            const Icon(Icons.credit_card, color: Colors.white, size: 28),
            const SizedBox(width: 12),
            const Text(
              'إدارة السلفات',
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
              // children: ['الكل', 'اليوم', 'هذا الشهر', 'هذه السنة']
              //     .map(
              //       (filter) => Padding(
              //         padding: const EdgeInsets.symmetric(horizontal: 4),
              //         child: ChoiceChip(
              //           label: Text(filter),
              //           selected: _timeFilter == filter,
              //           onSelected: (selected) {
              //             if (selected) {
              //               setState(() => _timeFilter = filter);
              //             }
              //           },
              //           selectedColor: const Color(0xFF27AE60),
              //           labelStyle: TextStyle(
              //             color: _timeFilter == filter
              //                 ? Colors.white
              //                 : const Color(0xFF2C3E50),
              //           ),
              //         ),
              //       ),
              //     )
              //     .toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_month, color: Color(0xFF27AE60)),
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
    double totalAmount = 0;
    double totalPaid = 0;
    double totalRemaining = 0;
    int completedLoans = 0;
    int partialLoans = 0;
    int pendingLoans = 0;

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final originalAmount = (data['originalAmount'] ?? data['amount'] as num)
          .toDouble();
      final paidAmount = (data['paidAmount'] ?? 0.0) as double;
      final remainingAmount = originalAmount - paidAmount;
      final status = data['status'] ?? 'مستحقة';

      totalAmount += originalAmount;
      totalPaid += paidAmount;
      totalRemaining += remainingAmount;

      switch (status) {
        case 'مكتملة':
          completedLoans++;
          break;
        case 'مدفوعة جزئياً':
          partialLoans++;
          break;
        case 'مستحقة':
          pendingLoans++;
          break;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "إحصائيات السلفات",
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
                          "${totalAmount.toStringAsFixed(2)} ج",
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
                        const Text("المدفوع", style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          "${totalPaid.toStringAsFixed(2)} ج",
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
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text("المتبقي", style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          "${totalRemaining.toStringAsFixed(2)} ج",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red,
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
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text("السلفات", style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          "${docs.length}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 8),
            // Container(
            //   padding: const EdgeInsets.all(12),
            //   decoration: BoxDecoration(
            //     color: Colors.grey[50],
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       _buildStatusChip('مكتملة', completedLoans, Colors.green),
            //       _buildStatusChip('جزئية', partialLoans, Colors.blue),
            //       _buildStatusChip('مستحقة', pendingLoans, Colors.orange),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String text, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(text, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildLoanCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final docId = doc.id;
    final date = (data['date'] as Timestamp).toDate();
    final paymentType = data['paymentType'] as String;
    final originalAmount = (data['originalAmount'] ?? data['amount'] as num)
        .toDouble();
    final paidAmount = (data['paidAmount'] ?? 0.0) as double;
    final remainingAmount = originalAmount - paidAmount;
    final status = data['status'] ?? 'مستحقة';

    Color paymentColor;
    IconData paymentIcon;
    Color statusColor;

    switch (paymentType) {
      case 'نقدي':
        paymentColor = Colors.green;
        paymentIcon = Icons.money;
        break;
      case 'تحويل بنكي':
        paymentColor = Colors.blue;
        paymentIcon = Icons.account_balance;
        break;
      case 'شيك':
        paymentColor = Colors.orange;
        paymentIcon = Icons.description;
        break;
      default:
        paymentColor = Colors.grey;
        paymentIcon = Icons.more_horiz;
    }

    switch (status) {
      case 'مكتملة':
        statusColor = Colors.green;
        break;
      case 'مدفوعة جزئياً':
        statusColor = Colors.blue;
        break;
      case 'مستحقة':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: paymentColor.withOpacity(0.1),
          child: Icon(paymentIcon, color: paymentColor, size: 20),
        ),
        title: Row(
          children: [
            Text(
              data['recipient'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 10,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(paymentIcon, size: 16, color: paymentColor),
                const SizedBox(width: 4),
                Text(
                  paymentType,
                  style: TextStyle(fontSize: 14, color: paymentColor),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "المبلغ الأصلي",
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      Text(
                        "${originalAmount.toStringAsFixed(2)} ج",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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
                        "المدفوع",
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      Text(
                        "${paidAmount.toStringAsFixed(2)} ج",
                        style: TextStyle(
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
                        "المتبقي",
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      Text(
                        "${remainingAmount.toStringAsFixed(2)} ج",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('yyyy/MM/dd').format(date),
              style: const TextStyle(fontSize: 12),
            ),
            if (data['note'] != null && data['note'].isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  data['note'],
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // زر السداد ElevatedButton
            if (remainingAmount > 0)
              ElevatedButton.icon(
                onPressed: () async {
                  await _makePayment(docId, data);
                },
                icon: Icon(Icons.payment, size: 16),
                label: Text('سداد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size(80, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                  shadowColor: Colors.green.withOpacity(0.3),
                ),
              ),

            const SizedBox(width: 8),

            // زر القائمة (ثلاث نقاط)
            PopupMenuButton<String>(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.more_vert, color: Colors.grey),
              ),
              onSelected: (value) async {
                if (value == 'edit') {
                  await _openLoanSheet(docId: docId, data: data);
                } else if (value == 'delete') {
                  await _confirmDelete(
                    docId,
                    data['recipient'],
                    originalAmount,
                    paidAmount,
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('تعديل'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('حذف', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
  // Widget _buildLoanCard(QueryDocumentSnapshot doc) {
  //   final data = doc.data() as Map<String, dynamic>;
  //   final docId = doc.id;
  //   final date = (data['date'] as Timestamp).toDate();
  //   final paymentType = data['paymentType'] as String;
  //   final originalAmount = (data['originalAmount'] ?? data['amount'] as num)
  //       .toDouble();
  //   final paidAmount = (data['paidAmount'] ?? 0.0) as double;
  //   final remainingAmount = originalAmount - paidAmount;
  //   final status = data['status'] ?? 'مستحقة';

  //   Color paymentColor;
  //   IconData paymentIcon;
  //   Color statusColor;

  //   switch (paymentType) {
  //     case 'نقدي':
  //       paymentColor = Colors.green;
  //       paymentIcon = Icons.money;
  //       break;
  //     case 'تحويل بنكي':
  //       paymentColor = Colors.blue;
  //       paymentIcon = Icons.account_balance;
  //       break;
  //     case 'شيك':
  //       paymentColor = Colors.orange;
  //       paymentIcon = Icons.description;
  //       break;
  //     default:
  //       paymentColor = Colors.grey;
  //       paymentIcon = Icons.more_horiz;
  //   }

  //   switch (status) {
  //     case 'مكتملة':
  //       statusColor = Colors.green;
  //       break;
  //     case 'مدفوعة جزئياً':
  //       statusColor = Colors.blue;
  //       break;
  //     case 'مستحقة':
  //       statusColor = Colors.orange;
  //       break;
  //     default:
  //       statusColor = Colors.grey;
  //   }

  //   return Card(
  //     margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //     child: ListTile(
  //       leading: CircleAvatar(
  //         backgroundColor: paymentColor.withOpacity(0.1),
  //         child: Icon(paymentIcon, color: paymentColor, size: 20),
  //       ),
  //       title: Row(
  //         children: [
  //           Text(
  //             data['recipient'],
  //             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  //           ),
  //           const SizedBox(width: 8),
  //           Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  //             decoration: BoxDecoration(
  //               color: statusColor.withOpacity(0.1),
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             child: Text(
  //               status,
  //               style: TextStyle(
  //                 fontSize: 10,
  //                 color: statusColor,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //       subtitle: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const SizedBox(height: 4),
  //           Row(
  //             children: [
  //               Icon(paymentIcon, size: 16, color: paymentColor),
  //               const SizedBox(width: 4),
  //               Text(
  //                 paymentType,
  //                 style: TextStyle(fontSize: 14, color: paymentColor),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 4),
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       "المبلغ الأصلي",
  //                       style: TextStyle(fontSize: 11, color: Colors.grey[600]),
  //                     ),
  //                     Text(
  //                       "${originalAmount.toStringAsFixed(2)} ج",
  //                       style: const TextStyle(
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.bold,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       "المدفوع",
  //                       style: TextStyle(fontSize: 11, color: Colors.grey[600]),
  //                     ),
  //                     Text(
  //                       "${paidAmount.toStringAsFixed(2)} ج",
  //                       style: TextStyle(
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.bold,
  //                         color: Colors.green,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       "المتبقي",
  //                       style: TextStyle(fontSize: 11, color: Colors.grey[600]),
  //                     ),
  //                     Text(
  //                       "${remainingAmount.toStringAsFixed(2)} ج",
  //                       style: TextStyle(
  //                         fontSize: 14,
  //                         fontWeight: FontWeight.bold,
  //                         color: Colors.red,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //           const SizedBox(height: 4),
  //           Text(
  //             DateFormat('yyyy/MM/dd').format(date),
  //             style: const TextStyle(fontSize: 12),
  //           ),
  //           if (data['note'] != null && data['note'].isNotEmpty)
  //             Padding(
  //               padding: const EdgeInsets.only(top: 4),
  //               child: Text(
  //                 data['note'],
  //                 style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
  //               ),
  //             ),
  //         ],
  //       ),
  //       trailing: PopupMenuButton<String>(
  //         icon: const Icon(Icons.more_vert),
  //         onSelected: (value) async {
  //           if (value == 'edit') {
  //             await _openLoanSheet(docId: docId, data: data);
  //           } else if (value == 'pay') {
  //             await _makePayment(docId, data);
  //           } else if (value == 'delete') {
  //             await _confirmDelete(
  //               docId,
  //               data['recipient'],
  //               originalAmount,
  //               paidAmount,
  //             );
  //           }
  //         },
  //         itemBuilder: (BuildContext context) {
  //           return [
  //             if (remainingAmount > 0)
  //               PopupMenuItem<String>(
  //                 value: 'pay',
  //                 child: Row(
  //                   children: [
  //                     Icon(Icons.payment, color: Colors.green, size: 20),
  //                     SizedBox(width: 8),
  //                     Text('سداد'),
  //                   ],
  //                 ),
  //               ),
  //             PopupMenuItem<String>(
  //               value: 'edit',
  //               child: Row(
  //                 children: [
  //                   Icon(Icons.edit, size: 20),
  //                   SizedBox(width: 8),
  //                   Text('تعديل'),
  //                 ],
  //               ),
  //             ),
  //             PopupMenuItem<String>(
  //               value: 'delete',
  //               child: Row(
  //                 children: [
  //                   Icon(Icons.delete, color: Colors.red, size: 20),
  //                   SizedBox(width: 8),
  //                   Text('حذف', style: TextStyle(color: Colors.red)),
  //                 ],
  //               ),
  //             ),
  //           ];
  //         },
  //       ),
  //     ),
  //   );
  // }

  void _resetForm() {
    _recipientController.clear();
    _amountController.clear();
    _noteController.clear();
    _paymentAmountController.clear();
    selectedPaymentType = "نقدي";
    selectedPaymentTypeForSettlement = "نقدي";
    selectedDate = DateTime.now();
    _editingDocId = "";
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _paymentAmountController.dispose();
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
                  .collection("loans")
                  .orderBy('date', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<QueryDocumentSnapshot> allDocs = snapshot.data!.docs;
                List<QueryDocumentSnapshot> filteredDocs = _filterLoansByDate(
                  allDocs,
                );

                // if (snapshot.data!.docs.isEmpty) {
                //   return Column(
                //     children: [
                //       Container(
                //         padding: const EdgeInsets.all(12),
                //         margin: const EdgeInsets.all(8),
                //         decoration: BoxDecoration(
                //           color: Colors.blue.shade50,
                //           borderRadius: BorderRadius.circular(8),
                //           border: Border.all(color: Colors.blue.shade100),
                //         ),
                //         child: Row(
                //           children: [
                //             Icon(
                //               Icons.account_balance_wallet,
                //               color: Colors.blue[800],
                //             ),
                //             const SizedBox(width: 10),
                //             Expanded(
                //               child: Column(
                //                 crossAxisAlignment: CrossAxisAlignment.start,
                //                 children: [
                //                   const Text(
                //                     "رصيد الخزنة الحالي",
                //                     style: TextStyle(
                //                       fontSize: 12,
                //                       color: Colors.blue,
                //                     ),
                //                   ),
                //                   const SizedBox(height: 4),
                //                   Text(
                //                     "${_treasuryBalance.toStringAsFixed(2)} ج",
                //                     style: TextStyle(
                //                       fontWeight: FontWeight.bold,
                //                       color: _treasuryBalance > 1000
                //                           ? Colors.green[800]
                //                           : Colors.red[800],
                //                       fontSize: 16,
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //       Expanded(
                //         child: Center(
                //           child: Column(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             children: [
                //               const Icon(
                //                 Icons.credit_card,
                //                 size: 80,
                //                 color: Colors.grey,
                //               ),
                //               const SizedBox(height: 16),
                //               const Text(
                //                 "لا توجد سلفات",
                //                 style: TextStyle(
                //                   fontSize: 18,
                //                   color: Colors.grey,
                //                 ),
                //               ),
                //               const SizedBox(height: 8),
                //               Text(
                //                 "انقر على زر + لإضافة أول سلفة",
                //                 style: TextStyle(
                //                   fontSize: 14,
                //                   color: Colors.grey.shade600,
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ],
                //   );
                // }

                return Column(
                  children: [
                    // Container(
                    //   padding: const EdgeInsets.all(12),
                    //   margin: const EdgeInsets.all(8),
                    //   decoration: BoxDecoration(
                    //     color: Colors.blue.shade50,
                    //     borderRadius: BorderRadius.circular(8),
                    //     border: Border.all(color: Colors.blue.shade100),
                    //   ),
                    //   child: Row(
                    //     children: [
                    //       Icon(
                    //         Icons.account_balance_wallet,
                    //         color: Colors.blue[800],
                    //       ),
                    //       const SizedBox(width: 10),
                    //       Expanded(
                    //         child: Column(
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             const Text(
                    //               "رصيد الخزنة الحالي",
                    //               style: TextStyle(
                    //                 fontSize: 12,
                    //                 color: Colors.blue,
                    //               ),
                    //             ),
                    //             const SizedBox(height: 4),
                    //             Text(
                    //               "${_treasuryBalance.toStringAsFixed(2)} ج",
                    //               style: TextStyle(
                    //                 fontWeight: FontWeight.bold,
                    //                 color: _treasuryBalance > 1000
                    //                     ? Colors.green[800]
                    //                     : Colors.red[800],
                    //                 fontSize: 16,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    _buildStats(filteredDocs),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          final doc = filteredDocs[index];
                          return _buildLoanCard(doc);
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
            heroTag: 'pdf_btn_loans',
            onPressed: _isGeneratingPDF ? null : _generatePDF,
            backgroundColor: _isGeneratingPDF ? Colors.grey : Colors.red,
            mini: true,
            child: _isGeneratingPDF
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.picture_as_pdf, color: Colors.white),
          ),
          const SizedBox(width: 10),
          FloatingActionButton.extended(
            onPressed: () {
              if (_treasuryBalance <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("لا يمكن إضافة سلفة - رصيد الخزنة غير كافي"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              _openLoanSheet();
            },
            icon: const Icon(Icons.add),
            label: const Text("إضافة سلفة"),
            backgroundColor: const Color(0xFF27AE60),
          ),
        ],
      ),
    );
  }
}
