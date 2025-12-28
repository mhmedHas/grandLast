// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class CompanyCapitalPage extends StatefulWidget {
//   const CompanyCapitalPage({super.key});

//   @override
//   State<CompanyCapitalPage> createState() => _CompanyCapitalPageState();
// }

// class _CompanyCapitalPageState extends State<CompanyCapitalPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   // متغيرات رأس المال
//   double _companyCapital = 0.0;
//   double _treasuryBalance = 0.0;
//   double _yearlyTaxes = 0.0;
//   double _totalDistributed = 0.0;
//   double _remainingCapital = 0.0;

//   // قائمة الشركاء
//   List<Map<String, dynamic>> _partners = [];
//   final TextEditingController _partnerNameController = TextEditingController();
//   final TextEditingController _partnerPercentageController =
//       TextEditingController();
//   final TextEditingController _editPartnerNameController =
//       TextEditingController();
//   final TextEditingController _editPartnerPercentageController =
//       TextEditingController();

//   // متغيرات عامة
//   int _selectedYear = DateTime.now().year;
//   List<int> _availableYears = [];
//   bool _isLoading = false;
//   bool _showAddPartnerForm = false;
//   Map<String, dynamic>? _editingPartner;

//   // التحكم في التبويبات
//   int _currentTab = 0; // 0: رأس المال، 1: الشركاء

//   @override
//   void initState() {
//     super.initState();
//     _initializeYears();
//     _loadAllData();
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
//   Future<void> _loadAllData() async {
//     setState(() => _isLoading = true);

//     try {
//       await Future.wait([_loadTreasuryBalance(), _loadYearlyTaxes()]);

//       _calculateCompanyCapital();
//       await _loadPartners();
//     } catch (e) {
//       _showError('خطأ في تحميل البيانات: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   // ================================
//   // تحميل رصيد الخزنة
//   // ================================
//   Future<void> _loadTreasuryBalance() async {
//     try {
//       // مجموع الدخل النقدي والمصروف
//       final incomeSnapshot = await _firestore
//           .collection('treasury_entries')
//           .where('isCleared', isEqualTo: true)
//           .get();

//       double totalIncome = 0;
//       for (var doc in incomeSnapshot.docs) {
//         totalIncome += (doc.data()['amount'] as num).toDouble();
//       }

//       // مجموع الخرج
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

//   // ================================
//   // تحميل ضرائب السنة
//   // ================================
//   Future<void> _loadYearlyTaxes() async {
//     try {
//       double totalTaxes = 0;

//       // ضرائب 3% للعام الحالي
//       final tax3Snapshot = await _firestore
//           .collection('taxes')
//           .where('taxType', isEqualTo: '3%')
//           .where('year', isEqualTo: _selectedYear)
//           .get();

//       for (var doc in tax3Snapshot.docs) {
//         final data = doc.data();
//         totalTaxes += ((data['totalTaxAmount'] as num?) ?? 0).toDouble();
//       }

//       // ضرائب 14% للعام الحالي
//       final tax14Snapshot = await _firestore
//           .collection('taxes')
//           .where('taxType', isEqualTo: '14%')
//           .where('year', isEqualTo: _selectedYear)
//           .get();

//       for (var doc in tax14Snapshot.docs) {
//         final data = doc.data();
//         totalTaxes += ((data['totalTaxAmount'] as num?) ?? 0).toDouble();
//       }

//       setState(() {
//         _yearlyTaxes = totalTaxes;
//       });
//     } catch (e) {
//       print('Error loading yearly taxes: $e');
//     }
//   }

//   // ================================
//   // تحميل بيانات الشركاء
//   // ================================
//   Future<void> _loadPartners() async {
//     try {
//       final partnersSnapshot = await _firestore
//           .collection('company_partners')
//           .orderBy('createdAt', descending: true)
//           .get();

//       final List<Map<String, dynamic>> partnersList = [];

//       for (var doc in partnersSnapshot.docs) {
//         final data = doc.data();
//         final percentage = ((data['percentage'] as num?) ?? 0).toDouble();

//         // حساب المبلغ المستحق للشريك
//         final amount = (_companyCapital * percentage) / 100;

//         partnersList.add({
//           'id': doc.id,
//           'name': data['name'] ?? 'غير معروف',
//           'percentage': percentage,
//           'calculatedAmount': amount, // تخزين المبلغ المحسوب
//           'createdAt': (data['createdAt'] as Timestamp?)?.toDate(),
//           'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate(),
//         });
//       }

//       // تطبيع النسب إذا لزم الأمر
//       _normalizePercentages(partnersList);

//       setState(() {
//         _partners = partnersList;
//       });

//       // حساب التوزيع بعد تحميل الشركاء
//       _calculateDistribution();
//     } catch (e) {
//       print('Error loading partners: $e');
//     }
//   }

//   // ================================
//   // حساب رأس مال الشركة
//   // ================================
//   void _calculateCompanyCapital() {
//     setState(() {
//       _companyCapital = _treasuryBalance - _yearlyTaxes;
//       if (_companyCapital < 0) _companyCapital = 0;
//     });
//   }

//   // ================================
//   // حساب توزيع رأس المال
//   // ================================
//   void _calculateDistribution() {
//     double totalDistributed = 0;

//     for (var partner in _partners) {
//       final percentage = partner['percentage'];
//       final amount = (_companyCapital * percentage) / 100;
//       partner['calculatedAmount'] = amount; // تحديث المبلغ المحسوب
//       totalDistributed += amount;
//     }

//     setState(() {
//       _totalDistributed = totalDistributed;
//       _remainingCapital = _companyCapital - _totalDistributed;
//     });
//   }

//   // ================================
//   // إضافة شريك جديد
//   // ================================
//   Future<void> _addPartner() async {
//     if (_partnerNameController.text.isEmpty) {
//       _showError('الرجاء إدخال اسم الشريك');
//       return;
//     }

//     final percentageText = _partnerPercentageController.text;
//     if (percentageText.isEmpty) {
//       _showError('الرجاء إدخال نسبة الشريك');
//       return;
//     }

//     final percentage = double.tryParse(percentageText);
//     if (percentage == null || percentage <= 0 || percentage > 100) {
//       _showError('الرجاء إدخال نسبة صحيحة بين 1 و 100');
//       return;
//     }

//     // التحقق من أن مجموع النسب لا يتجاوز 100%
//     double currentTotal = _calculateTotalPercentage();

//     if (currentTotal + percentage > 100) {
//       _showError(
//         'النسبة المتبقية هي ${(100 - currentTotal).toStringAsFixed(1)}% فقط',
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       await _firestore.collection('company_partners').add({
//         'name': _partnerNameController.text,
//         'percentage': percentage,
//         'createdAt': Timestamp.now(),
//         'updatedAt': Timestamp.now(),
//       });

//       _showSuccess('تم إضافة الشريك بنجاح');
//       _partnerNameController.clear();
//       _partnerPercentageController.clear();
//       setState(() => _showAddPartnerForm = false);

//       await _loadPartners();
//     } catch (e) {
//       _showError('خطأ في إضافة الشريك: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   // ================================
//   // تعديل شريك
//   // ================================
//   Future<void> _editPartner(Map<String, dynamic> partner) async {
//     if (_editPartnerNameController.text.isEmpty) {
//       _showError('الرجاء إدخال اسم الشريك');
//       return;
//     }

//     final percentageText = _editPartnerPercentageController.text;
//     if (percentageText.isEmpty) {
//       _showError('الرجاء إدخال نسبة الشريك');
//       return;
//     }

//     final newPercentage = double.tryParse(percentageText);
//     if (newPercentage == null || newPercentage <= 0 || newPercentage > 100) {
//       _showError('الرجاء إدخال نسبة صحيحة بين 1 و 100');
//       return;
//     }

//     // التحقق من أن مجموع النسب لا يتجاوز 100%
//     double currentTotal = _calculateTotalPercentage();
//     final oldPercentage = partner['percentage'];

//     if ((currentTotal - oldPercentage) + newPercentage > 100) {
//       _showError('مجموع النسب يتجاوز 100%');
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       await _firestore
//           .collection('company_partners')
//           .doc(partner['id'])
//           .update({
//             'name': _editPartnerNameController.text,
//             'percentage': newPercentage,
//             'updatedAt': Timestamp.now(),
//           });

//       _showSuccess('تم تعديل الشريك بنجاح');
//       setState(() => _editingPartner = null);

//       await _loadPartners();
//     } catch (e) {
//       _showError('خطأ في تعديل الشريك: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   // ================================
//   // حذف شريك
//   // ================================
//   Future<void> _deletePartner(String partnerId) async {
//     final partner = _partners.firstWhere((p) => p['id'] == partnerId);

//     return showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('تأكيد الحذف'),
//           content: Text(
//             'هل أنت متأكد من حذف الشريك ${partner['name']}؟\n'
//             'نسبة الشريك: ${partner['percentage']}%\n'
//             'بعد الحذف، يمكنك توزيع نسبته على الشركاء الآخرين.',
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('إلغاء'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 Navigator.pop(context);
//                 await _confirmDeletePartner(partnerId, partner['percentage']);
//               },
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//               child: const Text('حذف', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _confirmDeletePartner(
//     String partnerId,
//     double deletedPercentage,
//   ) async {
//     setState(() => _isLoading = true);

//     try {
//       await _firestore.collection('company_partners').doc(partnerId).delete();

//       // بعد الحذف، إظهار نافذة لإعادة التوزيع
//       _showRedistributionDialog(deletedPercentage);
//     } catch (e) {
//       _showError('خطأ في حذف الشريك: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   // ================================
//   // إعادة توزيع النسب يدوياً
//   // ================================
//   void _showRedistributionDialog(double deletedPercentage) {
//     final remainingPartners = _partners
//         .where((p) => p['id'] != (_editingPartner?['id'] ?? ''))
//         .toList();

//     if (remainingPartners.isEmpty) {
//       _showSuccess('تم حذف الشريك، لا يوجد شركاء آخرين لتوزيع النسبة عليهم');
//       _loadPartners(); // إعادة تحميل الشركاء
//       return;
//     }

//     // إنشاء قائمة بمتحكمات النسب الجديدة
//     List<TextEditingController> percentageControllers = [];
//     for (var partner in remainingPartners) {
//       final controller = TextEditingController(
//         text: partner['percentage'].toStringAsFixed(1),
//       );
//       percentageControllers.add(controller);
//     }

//     double totalPercentage = 0;
//     for (var controller in percentageControllers) {
//       totalPercentage += double.tryParse(controller.text) ?? 0;
//     }

//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: const Text('توزيع النسبة المحذوفة'),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'نسبة الشريك المحذوف: ${deletedPercentage.toStringAsFixed(1)}%\n'
//                       'مجموع نسب الشركاء الحاليين: ${totalPercentage.toStringAsFixed(1)}%\n'
//                       'قم بتوزيع النسبة المحذوفة على الشركاء الآخرين:',
//                       style: const TextStyle(fontSize: 14),
//                     ),

//                     const SizedBox(height: 16),

//                     ...remainingPartners.asMap().entries.map((entry) {
//                       final index = entry.key;
//                       final partner = entry.value;
//                       final controller = percentageControllers[index];

//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 12),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               partner['name'],
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: TextField(
//                                     controller: controller,
//                                     keyboardType: TextInputType.number,
//                                     decoration: InputDecoration(
//                                       labelText: 'النسبة الجديدة (%)',
//                                       border: const OutlineInputBorder(),
//                                       contentPadding:
//                                           const EdgeInsets.symmetric(
//                                             horizontal: 12,
//                                             vertical: 8,
//                                           ),
//                                       suffixText: '%',
//                                     ),
//                                     onChanged: (value) {
//                                       // إعادة حساب المجموع
//                                       setState(() {});
//                                     },
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       );
//                     }).toList(),

//                     const SizedBox(height: 16),

//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[50],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.grey[300]!),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           const Text(
//                             'المجموع الحالي:',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                           Text(
//                             '${_calculateDialogTotal(percentageControllers).toStringAsFixed(1)}%',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color:
//                                   _calculateDialogTotal(
//                                         percentageControllers,
//                                       ) ==
//                                       100
//                                   ? Colors.green
//                                   : Colors.red,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     if (_calculateDialogTotal(percentageControllers) != 100)
//                       Padding(
//                         padding: const EdgeInsets.only(top: 8),
//                         child: Text(
//                           'يجب أن يكون المجموع 100% (الفرق: ${(100 - _calculateDialogTotal(percentageControllers)).toStringAsFixed(1)}%)',
//                           style: const TextStyle(
//                             color: Colors.red,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     _loadPartners(); // إعادة تحميل بدون تغيير
//                   },
//                   child: const Text('إلغاء'),
//                 ),
//                 ElevatedButton(
//                   onPressed: _calculateDialogTotal(percentageControllers) == 100
//                       ? () async {
//                           Navigator.pop(context);
//                           await _applyRedistribution(
//                             remainingPartners,
//                             percentageControllers,
//                           );
//                         }
//                       : null,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                   ),
//                   child: const Text('تطبيق التوزيع'),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   double _calculateDialogTotal(List<TextEditingController> controllers) {
//     double total = 0;
//     for (var controller in controllers) {
//       total += double.tryParse(controller.text) ?? 0;
//     }
//     return total;
//   }

//   Future<void> _applyRedistribution(
//     List<Map<String, dynamic>> remainingPartners,
//     List<TextEditingController> controllers,
//   ) async {
//     setState(() => _isLoading = true);

//     try {
//       for (int i = 0; i < remainingPartners.length; i++) {
//         final partner = remainingPartners[i];
//         final newPercentage = double.tryParse(controllers[i].text) ?? 0;

//         await _firestore
//             .collection('company_partners')
//             .doc(partner['id'])
//             .update({
//               'percentage': newPercentage,
//               'updatedAt': Timestamp.now(),
//             });
//       }

//       _showSuccess('تم توزيع النسب بنجاح');
//       await _loadPartners();
//     } catch (e) {
//       _showError('خطأ في توزيع النسب: $e');
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   // ================================
//   // تطبيع النسب لضمان أن المجموع = 100%
//   // ================================
//   void _normalizePercentages(List<Map<String, dynamic>> partnersList) {
//     if (partnersList.isEmpty) return;

//     double totalPercentage = 0;
//     for (var partner in partnersList) {
//       totalPercentage += partner['percentage'];
//     }

//     // إذا كان المجموع مختلف عن 100%، نقوم بتعديل النسب
//     if (totalPercentage != 100 && partnersList.isNotEmpty) {
//       final double adjustmentPerPartner =
//           (100 - totalPercentage) / partnersList.length;

//       for (var partner in partnersList) {
//         final newPercentage = partner['percentage'] + adjustmentPerPartner;
//         partner['percentage'] = newPercentage < 0 ? 0 : newPercentage;
//       }

//       // إذا ما زال هناك فرق بعد التعديل، نصلحه
//       totalPercentage = 0;
//       for (var partner in partnersList) {
//         totalPercentage += partner['percentage'];
//       }

//       if (totalPercentage != 100 && partnersList.isNotEmpty) {
//         final double finalAdjustment = 100 - totalPercentage;
//         partnersList[0]['percentage'] += finalAdjustment;
//       }
//     }
//   }

//   // ================================
//   // تحديث السنة المحددة
//   // ================================
//   void _onYearChanged(int? value) {
//     if (value != null) {
//       setState(() {
//         _selectedYear = value;
//       });

//       // إعادة تحميل بيانات السنة الجديدة
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _loadYearlyTaxes();
//         _calculateCompanyCapital();
//         _calculateDistribution(); // إعادة حساب التوزيع
//       });
//     }
//   }

//   // ================================
//   // تغيير التبويب
//   // ================================
//   void _changeTab(int tabIndex) {
//     setState(() {
//       _currentTab = tabIndex;
//     });
//   }

//   // ================================
//   // بناء واجهة رأس المال
//   // ================================
//   Widget _buildCapitalTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // بطاقة رأس المال
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
//                   // عنوان البطاقة
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.account_balance,
//                         color: Colors.white,
//                         size: 28,
//                       ),
//                       const SizedBox(width: 12),
//                       const Text(
//                         'رأس مال الشركة',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const Spacer(),
//                       DropdownButton<int>(
//                         value: _selectedYear,
//                         onChanged: _onYearChanged,
//                         dropdownColor: const Color(0xFF1B4F72),
//                         underline: Container(),
//                         items: _availableYears
//                             .map(
//                               (year) => DropdownMenuItem(
//                                 value: year,
//                                 child: Text(
//                                   'سنة $year',
//                                   style: const TextStyle(color: Colors.white),
//                                 ),
//                               ),
//                             )
//                             .toList(),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 24),

//                   // رصيد الخزنة
//                   _buildCapitalItem(
//                     icon: Icons.account_balance_wallet,
//                     label: 'رصيد الخزنة',
//                     value: _formatCurrency(_treasuryBalance),
//                     color: Colors.green[300]!,
//                   ),

//                   const SizedBox(height: 16),

//                   // ضرائب السنة
//                   _buildCapitalItem(
//                     icon: Icons.receipt_long,
//                     label: 'ضرائب السنة',
//                     value: _formatCurrency(_yearlyTaxes),
//                     color: Colors.orange[300]!,
//                   ),

//                   const SizedBox(height: 24),

//                   // رأس المال الصافي
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
//                               Icons.calculate,
//                               color: Colors.white,
//                               size: 24,
//                             ),
//                             const SizedBox(width: 12),
//                             const Text(
//                               'رأس المال الصافي',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             const Spacer(),
//                             Text(
//                               _formatCurrency(_companyCapital),
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'رصيد الخزنة - ضرائب السنة',
//                           style: TextStyle(
//                             color: Colors.white.withOpacity(0.8),
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   // ملخص التوزيع
//                   if (_partners.isNotEmpty)
//                     Card(
//                       elevation: 2,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const Row(
//                               children: [
//                                 Icon(
//                                   Icons.groups,
//                                   color: Color(0xFF1B4F72),
//                                   size: 20,
//                                 ),
//                                 SizedBox(width: 8),
//                                 Text(
//                                   'ملخص توزيع رأس المال',
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF1B4F72),
//                                   ),
//                                 ),
//                               ],
//                             ),

//                             const SizedBox(height: 16),

//                             Row(
//                               children: [
//                                 const Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         'المبلغ الموزع',
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                       SizedBox(height: 4),
//                                       Text(
//                                         'المبلغ المتبقي',
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: [
//                                     Text(
//                                       _formatCurrency(_totalDistributed),
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.green,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       _formatCurrency(_remainingCapital),
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                         color: _remainingCapital > 0
//                                             ? Colors.blue
//                                             : Colors.red,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),

//                             const SizedBox(height: 12),

//                             // شريط التقدم
//                             LinearProgressIndicator(
//                               value: _companyCapital > 0
//                                   ? _totalDistributed / _companyCapital
//                                   : 0,
//                               backgroundColor: Colors.grey[200],
//                               color: _totalDistributed == _companyCapital
//                                   ? Colors.green
//                                   : const Color(0xFF3498DB),
//                               minHeight: 8,
//                               borderRadius: BorderRadius.circular(4),
//                             ),

//                             const SizedBox(height: 8),

//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   '${_partners.length} شريك',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey[600],
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 Text(
//                                   '${((_totalDistributed / _companyCapital) * 100).toStringAsFixed(1)}% موزع',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey[600],
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 20),

//           // زر الانتقال إلى الشركاء
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: () => _changeTab(1),
//               icon: const Icon(Icons.groups, size: 20),
//               label: const Text('عرض وإدارة الشركاء'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF3498DB),
//                 foregroundColor: Colors.white,
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

//   Widget _buildCapitalItem({
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color color,
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
//           Icon(icon, color: color, size: 22),
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

//   // ================================
//   // بناء واجهة الشركاء
//   // ================================
//   Widget _buildPartnersTab() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // عنوان قسم الشركاء
//           Card(
//             elevation: 2,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   const Icon(Icons.groups, color: Color(0xFF1B4F72), size: 24),
//                   const SizedBox(width: 12),
//                   const Text(
//                     'إدارة الشركاء',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1B4F72),
//                     ),
//                   ),
//                   const Spacer(),
//                   Text(
//                     'مجموع النسب: ${_calculateTotalPercentage().toStringAsFixed(1)}%',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold,
//                       color: _calculateTotalPercentage() == 100
//                           ? Colors.green
//                           : Colors.red,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 16),

//           // إحصائيات التوزيع
//           if (_partners.isNotEmpty) _buildDistributionStats(),

//           const SizedBox(height: 16),

//           // قائمة الشركاء
//           if (_partners.isNotEmpty)
//             ..._partners.map((partner) => _buildPartnerCard(partner)).toList()
//           else
//             _buildNoPartnersCard(),

//           const SizedBox(height: 16),

//           // زر إضافة شريك جديد
//           if (!_showAddPartnerForm)
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: () {
//                   setState(() => _showAddPartnerForm = true);
//                 },
//                 icon: const Icon(Icons.person_add, size: 20),
//                 label: const Text('إضافة شريك جديد'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF3498DB),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//             ),

//           // نموذج إضافة شريك جديد
//           if (_showAddPartnerForm) _buildAddPartnerForm(),

//           const SizedBox(height: 16),

//           // زر العودة إلى رأس المال
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton.icon(
//               onPressed: () => _changeTab(0),
//               icon: const Icon(Icons.arrow_back, size: 18),
//               label: const Text('العودة إلى رأس المال'),
//               style: OutlinedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 12),
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

//   Widget _buildDistributionStats() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Row(
//               children: [
//                 Icon(Icons.pie_chart, color: Colors.blue, size: 20),
//                 SizedBox(width: 8),
//                 Text(
//                   'توزيع رأس المال',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue,
//                   ),
//                 ),
//               ],
//             ),

//             const SizedBox(height: 12),

//             Row(
//               children: [
//                 const Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'المبلغ الموزع',
//                         style: TextStyle(fontSize: 14, color: Colors.grey),
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         'المبلغ المتبقي',
//                         style: TextStyle(fontSize: 14, color: Colors.grey),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       _formatCurrency(_totalDistributed),
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.green,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       _formatCurrency(_remainingCapital),
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: _remainingCapital > 0 ? Colors.blue : Colors.red,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),

//             const SizedBox(height: 12),

//             // شريط التقدم
//             LinearProgressIndicator(
//               value: _companyCapital > 0
//                   ? _totalDistributed / _companyCapital
//                   : 0,
//               backgroundColor: Colors.grey[200],
//               color: _totalDistributed == _companyCapital
//                   ? Colors.green
//                   : const Color(0xFF3498DB),
//               minHeight: 8,
//               borderRadius: BorderRadius.circular(4),
//             ),

//             const SizedBox(height: 8),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   '${((_totalDistributed / _companyCapital) * 100).toStringAsFixed(1)}% موزع',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   '${((_remainingCapital / _companyCapital) * 100).toStringAsFixed(1)}% متبقي',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPartnerCard(Map<String, dynamic> partner) {
//     final percentage = partner['percentage'];
//     // استخدام المبلغ المحسوب المخزن في الpartner
//     final amount = partner['calculatedAmount'] ?? 0;
//     final isEditing = _editingPartner?['id'] == partner['id'];

//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // وضع التعديل
//             if (isEditing)
//               _buildEditPartnerForm(partner)
//             else
//               // عرض بيانات الشريك
//               Row(
//                 children: [
//                   // صورة الشريك
//                   Container(
//                     width: 50,
//                     height: 50,
//                     decoration: BoxDecoration(
//                       color: _getPartnerColor(partner['name']),
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     child: Center(
//                       child: Text(
//                         _getInitials(partner['name']),
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(width: 16),

//                   // بيانات الشريك
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Text(
//                                 partner['name'],
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF2C3E50),
//                                 ),
//                               ),
//                             ),
//                             Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 12,
//                                 vertical: 4,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Colors.blue[50],
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Text(
//                                 '${percentage.toStringAsFixed(1)}%',
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.blue,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),

//                         const SizedBox(height: 8),

//                         Row(
//                           children: [
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'المبلغ المستحق',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey[600],
//                                     ),
//                                   ),
//                                   Text(
//                                     _formatCurrency(amount),
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.green,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             // نسبة من رأس المال
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Text(
//                                   'نسبة من رأس المال',
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey[600],
//                                   ),
//                                 ),
//                                 Text(
//                                   '${((amount / _companyCapital) * 100).toStringAsFixed(1)}%',
//                                   style: const TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.blue,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),

//                         // عرض حساب المبلغ للمساعدة في التصحيح
//                         if (_companyCapital > 0 && amount > 0)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 4),
//                             child: Text(
//                               'حساب: ${percentage.toStringAsFixed(1)}% × ${_formatCurrency(_companyCapital)} = ${_formatCurrency(amount)}',
//                               style: TextStyle(
//                                 fontSize: 10,
//                                 color: Colors.grey[500],
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),

//                   // قائمة الإجراءات
//                   PopupMenuButton<String>(
//                     icon: const Icon(Icons.more_vert, color: Colors.grey),
//                     itemBuilder: (context) => [
//                       const PopupMenuItem(
//                         value: 'edit',
//                         child: Row(
//                           children: [
//                             Icon(Icons.edit, size: 18, color: Colors.blue),
//                             SizedBox(width: 8),
//                             Text('تعديل'),
//                           ],
//                         ),
//                       ),
//                       const PopupMenuItem(
//                         value: 'delete',
//                         child: Row(
//                           children: [
//                             Icon(Icons.delete, color: Colors.red, size: 18),
//                             SizedBox(width: 8),
//                             Text('حذف'),
//                           ],
//                         ),
//                       ),
//                     ],
//                     onSelected: (value) {
//                       if (value == 'edit') {
//                         _editPartnerNameController.text = partner['name'];
//                         _editPartnerPercentageController.text =
//                             partner['percentage'].toStringAsFixed(1);
//                         setState(() => _editingPartner = partner);
//                       } else if (value == 'delete') {
//                         _deletePartner(partner['id']);
//                       }
//                     },
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildEditPartnerForm(Map<String, dynamic> partner) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             const Icon(Icons.edit, color: Colors.blue, size: 20),
//             const SizedBox(width: 8),
//             const Text(
//               'تعديل بيانات الشريك',
//               style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
//             ),
//             const Spacer(),
//             IconButton(
//               icon: const Icon(Icons.close, size: 18, color: Colors.grey),
//               onPressed: () {
//                 setState(() => _editingPartner = null);
//               },
//             ),
//           ],
//         ),

//         const SizedBox(height: 16),

//         // اسم الشريك
//         TextField(
//           controller: _editPartnerNameController,
//           decoration: InputDecoration(
//             labelText: 'اسم الشريك',
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 12,
//             ),
//           ),
//         ),

//         const SizedBox(height: 12),

//         // نسبة الشريك
//         TextField(
//           controller: _editPartnerPercentageController,
//           keyboardType: TextInputType.number,
//           decoration: InputDecoration(
//             labelText: 'نسبة الشريك (%)',
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 12,
//             ),
//             suffixText: '%',
//             helperText:
//                 'النسبة المتبقية: ${(100 - (_calculateTotalPercentage() - partner['percentage'])).toStringAsFixed(1)}%',
//           ),
//         ),

//         const SizedBox(height: 16),

//         // أزرار الحفظ والإلغاء
//         Row(
//           children: [
//             Expanded(
//               child: OutlinedButton(
//                 onPressed: () {
//                   setState(() => _editingPartner = null);
//                 },
//                 style: OutlinedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text('إلغاء'),
//               ),
//             ),

//             const SizedBox(width: 12),

//             Expanded(
//               child: ElevatedButton(
//                 onPressed: () => _editPartner(partner),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: const Text('حفظ التعديلات'),
//               ),
//             ),
//           ],
//         ),
//       ],
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
//             Icon(Icons.groups, size: 60, color: Colors.grey[400]),
//             const SizedBox(height: 16),
//             const Text(
//               'لا يوجد شركاء',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'قم بإضافة الشركاء لتوزيع رأس مال الشركة عليهم',
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAddPartnerForm() {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Icon(Icons.person_add, color: Colors.green, size: 20),
//                 const SizedBox(width: 8),
//                 const Text(
//                   'إضافة شريك جديد',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green,
//                   ),
//                 ),
//                 const Spacer(),
//                 IconButton(
//                   icon: const Icon(Icons.close, size: 18, color: Colors.grey),
//                   onPressed: () {
//                     setState(() => _showAddPartnerForm = false);
//                   },
//                 ),
//               ],
//             ),

//             const SizedBox(height: 16),

//             // اسم الشريك
//             TextField(
//               controller: _partnerNameController,
//               decoration: InputDecoration(
//                 labelText: 'اسم الشريك',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//               ),
//             ),

//             const SizedBox(height: 12),

//             // نسبة الشريك
//             TextField(
//               controller: _partnerPercentageController,
//               keyboardType: TextInputType.number,
//               decoration: InputDecoration(
//                 labelText: 'نسبة الشريك (%)',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//                 suffixText: '%',
//                 helperText:
//                     'النسبة المتبقية: ${(100 - _calculateTotalPercentage()).toStringAsFixed(1)}%',
//               ),
//             ),

//             const SizedBox(height: 16),

//             // عرض تفاصيل حساب المبلغ
//             if (_companyCapital > 0 &&
//                 _partnerPercentageController.text.isNotEmpty)
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.blue[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.blue[100]!),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.calculate, color: Colors.blue, size: 18),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         'المبلغ المستحق: ${_formatCurrency((_companyCapital * (double.tryParse(_partnerPercentageController.text) ?? 0)) / 100)}',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.blue,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//             const SizedBox(height: 16),

//             // أزرار الإضافة والإلغاء
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () {
//                       setState(() => _showAddPartnerForm = false);
//                     },
//                     style: OutlinedButton.styleFrom(
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: const Text('إلغاء'),
//                   ),
//                 ),

//                 const SizedBox(width: 12),

//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: _addPartner,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       padding: const EdgeInsets.symmetric(vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: const Text('إضافة الشريك'),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ================================
//   // دوال مساعدة
//   // ================================
//   double _calculateTotalPercentage() {
//     double total = 0;
//     for (var partner in _partners) {
//       total += partner['percentage'];
//     }
//     return total;
//   }

//   Color _getPartnerColor(String name) {
//     // توليد لون ثابت بناءً على اسم الشريك
//     final hash = name.hashCode;
//     return Color(hash & 0xFFFFFF).withOpacity(1.0).withBlue(150);
//   }

//   String _getInitials(String name) {
//     final parts = name.split(' ');
//     if (parts.length >= 2) {
//       return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//     }
//     return name.length >= 2
//         ? name.substring(0, 2).toUpperCase()
//         : name.toUpperCase();
//   }

//   String _formatCurrency(double amount) {
//     return '${amount.toStringAsFixed(2)} ج';
//   }

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

//   // ================================
//   // بناء الواجهة الرئيسية
//   // ================================
//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2,
//       initialIndex: _currentTab,
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'رأس مال الشركة',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           centerTitle: true,
//           backgroundColor: const Color(0xFF1B4F72),
//           elevation: 4,
//           actions: [
//             IconButton(
//               onPressed: _loadAllData,
//               icon: const Icon(Icons.refresh, color: Colors.white),
//               tooltip: 'تحديث البيانات',
//             ),
//           ],
//           bottom: TabBar(
//             onTap: _changeTab,
//             indicatorColor: Colors.white,
//             labelColor: Colors.white,
//             unselectedLabelColor: Colors.white70,
//             labelStyle: const TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//             ),
//             tabs: const [
//               Tab(
//                 icon: Icon(Icons.account_balance, size: 22),
//                 text: 'رأس المال',
//               ),
//               Tab(icon: Icon(Icons.groups, size: 22), text: 'الشركاء'),
//             ],
//           ),
//         ),
//         body: _isLoading && _partners.isEmpty
//             ? const Center(child: CircularProgressIndicator())
//             : TabBarView(children: [_buildCapitalTab(), _buildPartnersTab()]),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _partnerNameController.dispose();
//     _partnerPercentageController.dispose();
//     _editPartnerNameController.dispose();
//     _editPartnerPercentageController.dispose();
//     super.dispose();
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CompanyCapitalPage extends StatefulWidget {
  const CompanyCapitalPage({super.key});

  @override
  State<CompanyCapitalPage> createState() => _CompanyCapitalPageState();
}

class _CompanyCapitalPageState extends State<CompanyCapitalPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // بيانات رأس المال
  double _companyCapital = 0.0;
  double _treasuryBalance = 0.0;
  double _yearlyTaxes = 0.0;
  double _totalDistributed = 0.0;
  double _remainingCapital = 0.0;

  // بيانات الشركاء
  List<Map<String, dynamic>> _partners = [];

  // controllers للنماذج
  final TextEditingController _partnerNameController = TextEditingController();
  final TextEditingController _partnerPercentageController =
      TextEditingController();
  final TextEditingController _editPartnerNameController =
      TextEditingController();
  final TextEditingController _editPartnerPercentageController =
      TextEditingController();

  // متغيرات التحكم
  final int _selectedYear = DateTime.now().year;
  bool _isLoading = false;
  bool _showAddPartnerForm = false;
  Map<String, dynamic>? _editingPartner;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // ================================
  // تحميل كل البيانات
  // ================================
  Future<void> _loadAllData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      await _loadTreasuryBalance();
      await _loadYearlyTaxes();
      _calculateCompanyCapital();
      await _loadPartners();
    } catch (e) {
      _showError('خطأ في تحميل البيانات');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ================================
  // تحميل رصيد الخزنة
  // ================================
  Future<void> _loadTreasuryBalance() async {
    try {
      double totalIncome = 0;
      double totalExpense = 0;

      // الدخل
      final incomeSnapshot = await _firestore
          .collection('treasury_entries')
          .where('isCleared', isEqualTo: true)
          .get();

      for (var doc in incomeSnapshot.docs) {
        final data = doc.data();
        totalIncome += (data['amount'] as num).toDouble();
      }

      // المصروفات
      final expenseSnapshot = await _firestore
          .collection('treasury_exits')
          .get();

      for (var doc in expenseSnapshot.docs) {
        final data = doc.data();
        totalExpense += (data['amount'] as num).toDouble();
      }

      if (mounted) {
        setState(() {
          _treasuryBalance = totalIncome - totalExpense;
        });
      }
    } catch (e) {
      print('Error loading treasury: $e');
    }
  }

  // ================================
  // تحميل ضرائب السنة
  // ================================
  Future<void> _loadYearlyTaxes() async {
    try {
      double totalTaxes = 0;

      // ضرائب 3%
      final tax3Snapshot = await _firestore
          .collection('taxes')
          .where('taxType', isEqualTo: '3%')
          .where('year', isEqualTo: _selectedYear)
          .get();

      for (var doc in tax3Snapshot.docs) {
        final data = doc.data();
        totalTaxes += (data['totalTaxAmount'] as num).toDouble();
      }

      // ضرائب 14%
      final tax14Snapshot = await _firestore
          .collection('taxes')
          .where('taxType', isEqualTo: '14%')
          .where('year', isEqualTo: _selectedYear)
          .get();

      for (var doc in tax14Snapshot.docs) {
        final data = doc.data();
        totalTaxes += (data['totalTaxAmount'] as num).toDouble();
      }

      if (mounted) {
        setState(() {
          _yearlyTaxes = totalTaxes;
        });
      }
    } catch (e) {
      print('Error loading taxes: $e');
    }
  }

  // ================================
  // تحميل الشركاء - المعدل
  // ================================
  Future<void> _loadPartners() async {
    try {
      final partnersSnapshot = await _firestore
          .collection('company_partners')
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> partnersList = [];

      for (var doc in partnersSnapshot.docs) {
        final data = doc.data();

        partnersList.add({
          'id': doc.id,
          'name': data['name']?.toString() ?? 'غير معروف',
          'percentage': (data['percentage'] as num?)?.toDouble() ?? 0.0,
          'createdAt':
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          'updatedAt': data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
        });
      }

      if (mounted) {
        setState(() {
          _partners = partnersList;
        });
      }

      _calculateDistribution();
    } catch (e) {
      print('Error loading partners: $e');
      if (mounted) {
        setState(() {
          _partners = [];
        });
      }
    }
  }

  // ================================
  // حساب رأس المال
  // ================================
  void _calculateCompanyCapital() {
    double capital = _treasuryBalance - _yearlyTaxes;
    if (capital < 0) capital = 0;

    if (mounted) {
      setState(() {
        _companyCapital = capital;
      });
    }
  }

  // ================================
  // حساب توزيع رأس المال - المعدل
  // ================================
  void _calculateDistribution() {
    double totalDistributed = 0;

    if (_partners.isEmpty) {
      if (mounted) {
        setState(() {
          _totalDistributed = 0;
          _remainingCapital = _companyCapital;
        });
      }
      return;
    }

    for (var partner in _partners) {
      final percentage = (partner['percentage'] as num?)?.toDouble() ?? 0.0;
      final amount = (_companyCapital * percentage) / 100;
      partner['calculatedAmount'] = amount;
      totalDistributed += amount;
    }

    if (mounted) {
      setState(() {
        _totalDistributed = totalDistributed;
        _remainingCapital = _companyCapital - totalDistributed;
      });
    }
  }

  // ================================
  // إضافة شريك جديد
  // ================================
  Future<void> _addPartner() async {
    final name = _partnerNameController.text.trim();
    final percentageText = _partnerPercentageController.text.trim();

    if (name.isEmpty) {
      _showError('أدخل اسم الشريك');
      return;
    }

    if (percentageText.isEmpty) {
      _showError('أدخل نسبة الشريك');
      return;
    }

    final percentage = double.tryParse(percentageText);
    if (percentage == null || percentage <= 0 || percentage > 100) {
      _showError('النسبة يجب أن تكون بين 1 و 100');
      return;
    }

    double currentTotal = 0;
    for (var partner in _partners) {
      currentTotal += (partner['percentage'] as num).toDouble();
    }

    if (currentTotal + percentage > 100) {
      _showError('مجموع النسب يتجاوز 100%');
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      await _firestore.collection('company_partners').add({
        'name': name,
        'percentage': percentage,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });

      _showSuccess('تم إضافة الشريك');
      _partnerNameController.clear();
      _partnerPercentageController.clear();

      if (mounted) {
        setState(() => _showAddPartnerForm = false);
      }

      await _loadPartners();
    } catch (e) {
      _showError('خطأ في الإضافة');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ================================
  // تعديل شريك
  // ================================
  Future<void> _editPartner(Map<String, dynamic> partner) async {
    final name = _editPartnerNameController.text.trim();
    final percentageText = _editPartnerPercentageController.text.trim();

    if (name.isEmpty) {
      _showError('أدخل اسم الشريك');
      return;
    }

    if (percentageText.isEmpty) {
      _showError('أدخل نسبة الشريك');
      return;
    }

    final newPercentage = double.tryParse(percentageText);
    if (newPercentage == null || newPercentage <= 0 || newPercentage > 100) {
      _showError('النسبة يجب أن تكون بين 1 و 100');
      return;
    }

    double currentTotal = 0;
    final oldPercentage = (partner['percentage'] as num).toDouble();

    for (var p in _partners) {
      if (p['id'] != partner['id']) {
        currentTotal += (p['percentage'] as num).toDouble();
      }
    }

    if (currentTotal + newPercentage > 100) {
      _showError('مجموع النسب يتجاوز 100%');
      return;
    }

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      await _firestore.collection('company_partners').doc(partner['id']).update(
        {
          'name': name,
          'percentage': newPercentage,
          'updatedAt': Timestamp.now(),
        },
      );

      _showSuccess('تم تعديل الشريك');

      if (mounted) {
        setState(() => _editingPartner = null);
      }

      await _loadPartners();
    } catch (e) {
      _showError('خطأ في التعديل');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ================================
  // حذف شريك - المعدل
  // ================================
  Future<void> _deletePartner(String partnerId) async {
    try {
      // البحث عن الشريك
      Map<String, dynamic>? partner;
      for (var p in _partners) {
        if (p['id'] == partnerId) {
          partner = p;
          break;
        }
      }

      if (partner == null) {
        _showError('الشريك غير موجود');
        return;
      }

      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('حذف الشريك'),
          content: Text('هل تريد حذف الشريك ${partner!['name']}؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('لا'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('نعم'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      if (mounted) {
        setState(() => _isLoading = true);
      }

      try {
        await _firestore.collection('company_partners').doc(partnerId).delete();

        _showSuccess('تم حذف الشريك');

        await _loadPartners();
      } catch (e) {
        _showError('خطأ في الحذف');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      _showError('خطأ في العملية');
    }
  }

  // ================================
  // تغيير التبويب
  // ================================
  void _changeTab(int index) {
    if (mounted) {
      setState(() {
        _currentTab = index;
      });
    }
  }

  // ================================
  // بناء تبويب رأس المال
  // ================================
  Widget _buildCapitalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
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
                        Icons.account_balance,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'رأس مال الشركة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildCapitalItem(
                    icon: Icons.account_balance_wallet,
                    label: 'رصيد الخزنة',
                    value: _formatCurrency(_treasuryBalance),
                    color: Colors.green[300]!,
                  ),

                  const SizedBox(height: 16),

                  _buildCapitalItem(
                    icon: Icons.receipt_long,
                    label: 'ضرائب السنة',
                    value: _formatCurrency(_yearlyTaxes),
                    color: Colors.orange[300]!,
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
                              Icons.calculate,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'رأس المال الصافي',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              _formatCurrency(_companyCapital),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'رصيد الخزنة - ضرائب السنة',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
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

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _changeTab(1),
              icon: const Icon(Icons.groups, size: 20),
              label: const Text('إدارة الشركاء'),
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

  Widget _buildCapitalItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
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
          Icon(icon, color: color, size: 22),
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

  // ================================
  // بناء تبويب الشركاء
  // ================================
  Widget _buildPartnersTab() {
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
                  const Icon(Icons.groups, color: Color(0xFF1B4F72), size: 24),
                  const SizedBox(width: 12),
                  const Text(
                    'إدارة الشركاء',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B4F72),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_partners.length} شريك',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // قائمة الشركاء
          if (_partners.isNotEmpty)
            ..._partners.map((partner) => _buildPartnerCard(partner))
          else
            _buildNoPartnersCard(),

          const SizedBox(height: 16),

          if (!_showAddPartnerForm)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (mounted) {
                    setState(() => _showAddPartnerForm = true);
                  }
                },
                icon: const Icon(Icons.person_add, size: 20),
                label: const Text('إضافة شريك جديد'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3498DB),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

          if (_showAddPartnerForm) _buildAddPartnerForm(),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPartnerCard(Map<String, dynamic> partner) {
    final percentage = (partner['percentage'] as num?)?.toDouble() ?? 0.0;
    final amount = (partner['calculatedAmount'] as num?)?.toDouble() ?? 0.0;
    final isEditing = _editingPartner?['id'] == partner['id'];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (isEditing)
              _buildEditPartnerForm(partner)
            else
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
                                  fontSize: 18,
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
                                    'المبلغ المستحق',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    _formatCurrency(amount),
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
                                  'نسبة من رأس المال',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '${((amount / _companyCapital) * 100).toStringAsFixed(1)}%',
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

                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('تعديل'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('حذف'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editPartnerNameController.text = partner['name'];
                        _editPartnerPercentageController.text = percentage
                            .toStringAsFixed(1);
                        if (mounted) {
                          setState(() => _editingPartner = partner);
                        }
                      } else if (value == 'delete') {
                        _deletePartner(partner['id']);
                      }
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditPartnerForm(Map<String, dynamic> partner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.edit, color: Colors.blue, size: 20),
            const SizedBox(width: 8),
            const Text(
              'تعديل بيانات الشريك',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
              onPressed: () {
                if (mounted) {
                  setState(() => _editingPartner = null);
                }
              },
            ),
          ],
        ),

        const SizedBox(height: 16),

        TextField(
          controller: _editPartnerNameController,
          decoration: InputDecoration(
            labelText: 'اسم الشريك',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),

        const SizedBox(height: 12),

        TextField(
          controller: _editPartnerPercentageController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'نسبة الشريك (%)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixText: '%',
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (mounted) {
                    setState(() => _editingPartner = null);
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('إلغاء'),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: ElevatedButton(
                onPressed: () => _editPartner(partner),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('حفظ التعديلات'),
              ),
            ),
          ],
        ),
      ],
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
            Icon(Icons.groups, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'لا يوجد شركاء',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'قم بإضافة الشركاء لتوزيع رأس مال الشركة',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPartnerForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_add, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'إضافة شريك جديد',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                  onPressed: () {
                    if (mounted) {
                      setState(() => _showAddPartnerForm = false);
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _partnerNameController,
              decoration: InputDecoration(
                labelText: 'اسم الشريك',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _partnerPercentageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'نسبة الشريك (%)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixText: '%',
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (mounted) {
                        setState(() => _showAddPartnerForm = false);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('إلغاء'),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: _addPartner,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('إضافة الشريك'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================================
  // دوال مساعدة
  // ================================
  Color _getPartnerColor(String name) {
    final hash = name.hashCode;
    return Color(hash & 0xFFFFFF).withOpacity(1.0).withBlue(150);
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '??';

    final trimmedName = name.trim();
    final words = trimmedName.split(' ');

    // إزالة الكلمات الفارغة
    final validWords = words.where((word) => word.isNotEmpty).toList();

    if (validWords.isEmpty) return '??';

    if (validWords.length >= 2) {
      // أول حرف من أول كلمتين
      return '${validWords[0][0]}${validWords[1][0]}'.toUpperCase();
    } else {
      // إذا كانت كلمة واحدة، أول حرفين
      final word = validWords[0];
      if (word.length >= 2) {
        return word.substring(0, 2).toUpperCase();
      } else {
        return word.toUpperCase();
      }
    }
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} ج';
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
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
  // بناء الواجهة الرئيسية
  // ================================
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: _currentTab,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'رأس مال الشركة',
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
              Tab(icon: Icon(Icons.account_balance), text: 'رأس المال'),
              Tab(icon: Icon(Icons.groups), text: 'الشركاء'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(children: [_buildCapitalTab(), _buildPartnersTab()]),
      ),
    );
  }

  @override
  void dispose() {
    _partnerNameController.dispose();
    _partnerPercentageController.dispose();
    _editPartnerNameController.dispose();
    _editPartnerPercentageController.dispose();
    super.dispose();
  }
}
