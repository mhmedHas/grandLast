// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';

// // class SalariesPage extends StatefulWidget {
// //   const SalariesPage({super.key});

// //   @override
// //   State<SalariesPage> createState() => _SalariesPageState();
// // }

// // class _SalariesPageState extends State<SalariesPage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   final TextEditingController _searchController = TextEditingController();
// //   int _selectedMonth = DateTime.now().month;
// //   int _selectedYear = DateTime.now().year;
// //   Map<String, bool> _paidStatus = {};
// //   Map<String, double> _employeePenalties = {};

// //   @override
// //   void initState() {
// //     super.initState();
// //     _searchController.addListener(_searchEmployees);
// //     _loadMonthData();
// //   }

// //   @override
// //   void dispose() {
// //     _searchController.dispose();
// //     super.dispose();
// //   }

// //   Future<void> _loadMonthData() async {
// //     // جلب الجزاءات لهذا الشهر
// //     final penaltiesQuery = await _firestore
// //         .collection('penalties')
// //         .where('month', isEqualTo: '$_selectedMonth/$_selectedYear')
// //         .get();

// //     final penaltiesMap = <String, double>{};
// //     for (final penalty in penaltiesQuery.docs) {
// //       final data = penalty.data() as Map<String, dynamic>;
// //       final employeeId = data['employeeId'];
// //       final amount = (data['amount'] ?? 0).toDouble();
// //       penaltiesMap[employeeId] = (penaltiesMap[employeeId] ?? 0) + amount;
// //     }

// //     // جبل حالة الدفع لهذا الشهر
// //     final paymentsQuery = await _firestore
// //         .collection('salaryPayments')
// //         .where('month', isEqualTo: '$_selectedMonth/$_selectedYear')
// //         .get();

// //     final paidMap = <String, bool>{};
// //     for (final payment in paymentsQuery.docs) {
// //       final data = payment.data() as Map<String, dynamic>;
// //       paidMap[data['employeeId']] = true;
// //     }

// //     setState(() {
// //       _employeePenalties = penaltiesMap;
// //       _paidStatus = paidMap;
// //     });
// //   }

// //   void _searchEmployees() {
// //     setState(() {});
// //   }

// //   Future<void> _markAsPaid(
// //     String employeeId,
// //     String employeeName,
// //     double netSalary,
// //   ) async {
// //     try {
// //       final salaryPayment = {
// //         'employeeId': employeeId,
// //         'employeeName': employeeName,
// //         'amount': netSalary,
// //         'date': DateTime.now().toIso8601String(),
// //         'month': '$_selectedMonth/$_selectedYear',
// //       };

// //       await _firestore.collection('salaryPayments').add(salaryPayment);

// //       setState(() {
// //         _paidStatus[employeeId] = true;
// //       });

// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text('تم تسجيل دفع الراتب لـ $employeeName'),
// //           backgroundColor: Colors.green,
// //         ),
// //       );
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text('خطأ في تسجيل الدفع: $e'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return SingleChildScrollView(
// //       child: Column(
// //         children: [
// //           // الجزء العلوي مع الفلتر والبحث
// //           Card(
// //             elevation: 8,
// //             margin: EdgeInsets.all(16),
// //             shape: RoundedRectangleBorder(
// //               borderRadius: BorderRadius.circular(16),
// //             ),
// //             child: Padding(
// //               padding: EdgeInsets.all(20),
// //               child: Column(
// //                 children: [
// //                   SizedBox(height: 16),
// //                   _buildHeaderSection(),
// //                   SizedBox(height: 20),
// //                   _buildMonthFilter(),
// //                   SizedBox(height: 20),
// //                   _buildSearchBar(),
// //                   SizedBox(height: 16),
// //                 ],
// //               ),
// //             ),
// //           ),
// //           SizedBox(height: 16),

// //           // الجزء السفلي مع الجدول
// //           _buildSalariesTable(),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildHeaderSection() {
// //     return Center(
// //       child: Text(
// //         'رواتب الموظفين',
// //         style: TextStyle(
// //           fontSize: 24,
// //           fontWeight: FontWeight.bold,
// //           color: const Color(0xFF2C3E50),
// //           fontFamily: 'Cairo',
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildMonthFilter() {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: [
// //         Icon(Icons.calendar_month, color: Color(0xFF3498DB), size: 24),
// //         SizedBox(width: 10),
// //         Text(
// //           'شهر:',
// //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //         ),
// //         SizedBox(width: 10),
// //         DropdownButton<int>(
// //           value: _selectedMonth,
// //           onChanged: (value) {
// //             if (value != null) {
// //               setState(() {
// //                 _selectedMonth = value;
// //               });
// //               _loadMonthData();
// //             }
// //           },
// //           items: [
// //             for (int i = 1; i <= 12; i++)
// //               DropdownMenuItem(
// //                 value: i,
// //                 child: Text('شهر $i', style: TextStyle(fontSize: 16)),
// //               ),
// //           ],
// //           style: TextStyle(
// //             color: Color(0xFF2C3E50),
// //             fontSize: 16,
// //             fontFamily: 'Cairo',
// //           ),
// //         ),
// //         SizedBox(width: 30),
// //         Text(
// //           'سنة:',
// //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //         ),
// //         SizedBox(width: 10),
// //         DropdownButton<int>(
// //           value: _selectedYear,
// //           onChanged: (value) {
// //             if (value != null) {
// //               setState(() {
// //                 _selectedYear = value;
// //               });
// //               _loadMonthData();
// //             }
// //           },
// //           items: [
// //             for (
// //               int i = DateTime.now().year - 2;
// //               i <= DateTime.now().year + 2;
// //               i++
// //             )
// //               DropdownMenuItem(
// //                 value: i,
// //                 child: Text('$i', style: TextStyle(fontSize: 16)),
// //               ),
// //           ],
// //           style: TextStyle(
// //             color: Color(0xFF2C3E50),
// //             fontSize: 16,
// //             fontFamily: 'Cairo',
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildSearchBar() {
// //     return Container(
// //       margin: EdgeInsets.symmetric(horizontal: 20),
// //       padding: EdgeInsets.symmetric(horizontal: 16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: const Color(0xFF3498DB), width: 1.5),
// //         boxShadow: [
// //           BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
// //         ],
// //       ),
// //       child: Row(
// //         children: [
// //           Icon(Icons.search, color: const Color(0xFF3498DB), size: 28),
// //           SizedBox(width: 12),
// //           Expanded(
// //             child: TextField(
// //               controller: _searchController,
// //               decoration: InputDecoration(
// //                 hintText: 'ابحث عن موظف...',
// //                 hintStyle: TextStyle(
// //                   color: Colors.grey,
// //                   fontSize: 16,
// //                   fontFamily: 'Cairo',
// //                 ),
// //                 border: InputBorder.none,
// //               ),
// //               style: TextStyle(fontSize: 16, fontFamily: 'Cairo'),
// //             ),
// //           ),
// //           if (_searchController.text.isNotEmpty)
// //             GestureDetector(
// //               onTap: () {
// //                 _searchController.clear();
// //                 _searchEmployees();
// //               },
// //               child: Icon(Icons.clear, size: 24, color: Colors.grey),
// //             ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildSalariesTable() {
// //     return Card(
// //       elevation: 8,
// //       margin: EdgeInsets.all(16),
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //       child: Padding(
// //         padding: EdgeInsets.all(16),
// //         child: StreamBuilder<QuerySnapshot>(
// //           stream: _firestore.collection('employees').snapshots(),
// //           builder: (context, snapshot) {
// //             if (snapshot.connectionState == ConnectionState.waiting) {
// //               return Center(child: CircularProgressIndicator());
// //             }

// //             if (snapshot.hasError) {
// //               return Center(child: Text('حدث خطأ: ${snapshot.error}'));
// //             }

// //             final employees = snapshot.data!.docs;
// //             final searchText = _searchController.text.toLowerCase();

// //             // تصفية الموظفين حسب البحث
// //             final filteredEmployees = employees.where((employee) {
// //               if (searchText.isEmpty) return true;
// //               final data = employee.data() as Map<String, dynamic>;
// //               final name = data['name']?.toString().toLowerCase() ?? '';
// //               return name.contains(searchText);
// //             }).toList();

// //             if (filteredEmployees.isEmpty) {
// //               return Center(
// //                 child: Column(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     Icon(Icons.people_outline, size: 80, color: Colors.grey),
// //                     SizedBox(height: 20),
// //                     Text(
// //                       searchText.isEmpty
// //                           ? 'لا يوجد موظفين مسجلين'
// //                           : 'لم يتم العثور على موظفين',
// //                       style: TextStyle(
// //                         fontSize: 18,
// //                         color: Colors.grey,
// //                         fontFamily: 'Cairo',
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               );
// //             }

// //             // حساب الإحصائيات
// //             double totalSalaries = 0;
// //             double totalPenalties = 0;
// //             double totalNet = 0;

// //             for (final employee in filteredEmployees) {
// //               final data = employee.data() as Map<String, dynamic>;
// //               final salary = (data['salary'] ?? 0).toDouble();
// //               final penalties = _employeePenalties[employee.id] ?? 0;
// //               final netSalary = salary - penalties;

// //               totalSalaries += salary;
// //               totalPenalties += penalties;
// //               totalNet += netSalary;
// //             }

// //             return Column(
// //               children: [
// //                 // العنوان والإحصائيات
// //                 Padding(
// //                   padding: EdgeInsets.only(bottom: 20),
// //                   child: Column(
// //                     children: [
// //                       Text(
// //                         'تفاصيل الرواتب - شهر $_selectedMonth/$_selectedYear',
// //                         style: TextStyle(
// //                           fontSize: 20,
// //                           fontWeight: FontWeight.bold,
// //                           color: const Color(0xFF2C3E50),
// //                           fontFamily: 'Cairo',
// //                         ),
// //                       ),
// //                       SizedBox(height: 20),

// //                       // إحصائيات
// //                       Card(
// //                         elevation: 4,
// //                         child: Padding(
// //                           padding: EdgeInsets.all(16),
// //                           child: Column(
// //                             children: [
// //                               Row(
// //                                 mainAxisAlignment:
// //                                     MainAxisAlignment.spaceBetween,
// //                                 children: [
// //                                   Text(
// //                                     'إجمالي الرواتب:',
// //                                     style: TextStyle(
// //                                       fontSize: 16,
// //                                       fontWeight: FontWeight.bold,
// //                                       fontFamily: 'Cairo',
// //                                     ),
// //                                   ),
// //                                   Text(
// //                                     '${totalSalaries.toStringAsFixed(2)} جنية',
// //                                     style: TextStyle(
// //                                       fontSize: 16,
// //                                       color: Colors.green,
// //                                       fontWeight: FontWeight.bold,
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                               SizedBox(height: 12),
// //                               Row(
// //                                 mainAxisAlignment:
// //                                     MainAxisAlignment.spaceBetween,
// //                                 children: [
// //                                   Text(
// //                                     'إجمالي الجزاءات:',
// //                                     style: TextStyle(
// //                                       fontSize: 16,
// //                                       fontWeight: FontWeight.bold,
// //                                       fontFamily: 'Cairo',
// //                                     ),
// //                                   ),
// //                                   Text(
// //                                     '${totalPenalties.toStringAsFixed(2)} جنية',
// //                                     style: TextStyle(
// //                                       fontSize: 16,
// //                                       color: Colors.red,
// //                                       fontWeight: FontWeight.bold,
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                               SizedBox(height: 12),
// //                               Divider(thickness: 1),
// //                               SizedBox(height: 12),
// //                               Row(
// //                                 mainAxisAlignment:
// //                                     MainAxisAlignment.spaceBetween,
// //                                 children: [
// //                                   Text(
// //                                     'إجمالي الصافي:',
// //                                     style: TextStyle(
// //                                       fontSize: 18,
// //                                       fontWeight: FontWeight.bold,
// //                                       fontFamily: 'Cairo',
// //                                     ),
// //                                   ),
// //                                   Text(
// //                                     '${totalNet.toStringAsFixed(2)} جنية',
// //                                     style: TextStyle(
// //                                       fontSize: 18,
// //                                       color: Color(0xFF3498DB),
// //                                       fontWeight: FontWeight.bold,
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),

// //                 // الجدول
// //                 MediaQuery.of(context).size.width < 600
// //                     ? _buildMobileTable(filteredEmployees)
// //                     : _buildDesktopTable(filteredEmployees),
// //               ],
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildMobileTable(List<QueryDocumentSnapshot> employees) {
// //     return ListView.builder(
// //       shrinkWrap: true,
// //       physics: NeverScrollableScrollPhysics(),
// //       itemCount: employees.length,
// //       itemBuilder: (context, index) {
// //         final employee = employees[index];
// //         final data = employee.data() as Map<String, dynamic>;
// //         final basicSalary = (data['salary'] ?? 0).toDouble();
// //         final penalties = _employeePenalties[employee.id] ?? 0;
// //         final netSalary = basicSalary - penalties;
// //         final isPaid = _paidStatus[employee.id] ?? false;

// //         return Card(
// //           margin: EdgeInsets.only(bottom: 12),
// //           elevation: 2,
// //           child: Padding(
// //             padding: EdgeInsets.all(16),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Expanded(
// //                       child: Row(
// //                         children: [
// //                           Text(
// //                             '${index + 1}.',
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               fontSize: 16,
// //                             ),
// //                           ),
// //                           SizedBox(width: 8),
// //                           Expanded(
// //                             child: Text(
// //                               data['name'] ?? 'غير محدد',
// //                               style: TextStyle(
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize: 16,
// //                                 fontFamily: 'Cairo',
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     Container(
// //                       padding: EdgeInsets.symmetric(
// //                         horizontal: 12,
// //                         vertical: 6,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: isPaid ? Colors.green[50] : Colors.orange[50],
// //                         borderRadius: BorderRadius.circular(8),
// //                         border: Border.all(
// //                           color: isPaid ? Colors.green : Colors.orange,
// //                           width: 1,
// //                         ),
// //                       ),
// //                       child: Text(
// //                         isPaid ? 'تم الدفع' : 'لم يتم الدفع',
// //                         style: TextStyle(
// //                           color: isPaid
// //                               ? Colors.green[800]
// //                               : Colors.orange[800],
// //                           fontWeight: FontWeight.bold,
// //                           fontSize: 14,
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 SizedBox(height: 12),
// //                 Divider(),
// //                 SizedBox(height: 12),
// //                 _buildInfoRow('الوظيفة:', data['job'] ?? 'غير محدد'),
// //                 SizedBox(height: 8),
// //                 _buildInfoRow(
// //                   'الراتب:',
// //                   '$basicSalary جنية',
// //                   valueColor: Colors.green,
// //                 ),
// //                 SizedBox(height: 8),
// //                 _buildInfoRow(
// //                   'الجزاءات:',
// //                   '$penalties جنية',
// //                   valueColor: Colors.red,
// //                 ),
// //                 SizedBox(height: 12),
// //                 Divider(),
// //                 SizedBox(height: 12),
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Text(
// //                       'الصافي:',
// //                       style: TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                         color: Color(0xFF3498DB),
// //                         fontFamily: 'Cairo',
// //                       ),
// //                     ),
// //                     Text(
// //                       '$netSalary جنية',
// //                       style: TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                         color: Color(0xFF3498DB),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 SizedBox(height: 16),
// //                 if (!isPaid)
// //                   SizedBox(
// //                     width: double.infinity,
// //                     child: ElevatedButton.icon(
// //                       onPressed: () => _markAsPaid(
// //                         employee.id,
// //                         data['name'] ?? '',
// //                         netSalary,
// //                       ),
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: Color(0xFF1B4F72),
// //                         foregroundColor: Colors.white,
// //                         padding: EdgeInsets.symmetric(vertical: 14),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(10),
// //                         ),
// //                         elevation: 4,
// //                       ),
// //                       icon: Icon(Icons.payment),
// //                       label: Text(
// //                         'تسديد الراتب',
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.bold,
// //                           fontFamily: 'Cairo',
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         Text(
// //           label,
// //           style: TextStyle(
// //             color: Colors.grey[700],
// //             fontSize: 15,
// //             fontFamily: 'Cairo',
// //           ),
// //         ),
// //         Text(
// //           value,
// //           style: TextStyle(
// //             fontSize: 15,
// //             fontWeight: FontWeight.bold,
// //             color: valueColor ?? Colors.black,
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildDesktopTable(List<QueryDocumentSnapshot> employees) {
// //     return SingleChildScrollView(
// //       scrollDirection: Axis.horizontal,
// //       child: DataTable(
// //         columnSpacing: 32,
// //         horizontalMargin: 20,
// //         headingRowHeight: 60,
// //         dataRowHeight: 60,
// //         columns: const [
// //           DataColumn(
// //             label: Text(
// //               'ر.ق',
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.bold,
// //                 color: Color(0xFF2C3E50),
// //                 fontFamily: 'Cairo',
// //               ),
// //             ),
// //           ),
// //           DataColumn(
// //             label: Text(
// //               'اسم الموظف',
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.bold,
// //                 color: Color(0xFF2C3E50),
// //                 fontFamily: 'Cairo',
// //               ),
// //             ),
// //           ),
// //           DataColumn(
// //             label: Text(
// //               'الوظيفة',
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.bold,
// //                 color: Color(0xFF2C3E50),
// //                 fontFamily: 'Cairo',
// //               ),
// //             ),
// //           ),
// //           DataColumn(
// //             label: Text(
// //               'الراتب',
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.bold,
// //                 color: Color(0xFF2C3E50),
// //                 fontFamily: 'Cairo',
// //               ),
// //             ),
// //           ),
// //           DataColumn(
// //             label: Text(
// //               'الجزاءات',
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.bold,
// //                 color: Color(0xFF2C3E50),
// //                 fontFamily: 'Cairo',
// //               ),
// //             ),
// //           ),
// //           DataColumn(
// //             label: Text(
// //               'الصافي',
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.bold,
// //                 color: Color(0xFF2C3E50),
// //                 fontFamily: 'Cairo',
// //               ),
// //             ),
// //           ),
// //           DataColumn(
// //             label: Text(
// //               'حالة الدفع',
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.bold,
// //                 color: Color(0xFF2C3E50),
// //                 fontFamily: 'Cairo',
// //               ),
// //             ),
// //           ),
// //           DataColumn(
// //             label: Text(
// //               'الإجراءات',
// //               style: TextStyle(
// //                 fontSize: 16,
// //                 fontWeight: FontWeight.bold,
// //                 color: Color(0xFF2C3E50),
// //                 fontFamily: 'Cairo',
// //               ),
// //             ),
// //           ),
// //         ],
// //         rows: employees.asMap().entries.map((entry) {
// //           final index = entry.key;
// //           final employee = entry.value;
// //           final data = employee.data() as Map<String, dynamic>;
// //           final basicSalary = (data['salary'] ?? 0).toDouble();
// //           final penalties = _employeePenalties[employee.id] ?? 0;
// //           final netSalary = basicSalary - penalties;
// //           final isPaid = _paidStatus[employee.id] ?? false;

// //           return DataRow(
// //             cells: [
// //               DataCell(
// //                 Center(
// //                   child: Text(
// //                     '${index + 1}',
// //                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
// //                   ),
// //                 ),
// //               ),
// //               DataCell(
// //                 Text(
// //                   data['name'] ?? 'غير محدد',
// //                   style: TextStyle(fontSize: 16, fontFamily: 'Cairo'),
// //                 ),
// //               ),
// //               DataCell(
// //                 Text(
// //                   data['job'] ?? 'غير محدد',
// //                   style: TextStyle(fontSize: 16, fontFamily: 'Cairo'),
// //                 ),
// //               ),
// //               DataCell(
// //                 Text(
// //                   '${basicSalary.toStringAsFixed(2)} جنية',
// //                   style: TextStyle(
// //                     fontSize: 16,
// //                     color: Colors.green,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ),
// //               DataCell(
// //                 Text(
// //                   '${penalties.toStringAsFixed(2)} جنية',
// //                   style: TextStyle(
// //                     fontSize: 16,
// //                     color: Colors.red,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ),
// //               DataCell(
// //                 Text(
// //                   '${netSalary.toStringAsFixed(2)} جنية',
// //                   style: TextStyle(
// //                     fontSize: 16,
// //                     color: Color(0xFF3498DB),
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ),
// //               DataCell(
// //                 Container(
// //                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //                   decoration: BoxDecoration(
// //                     color: isPaid ? Colors.green[50] : Colors.orange[50],
// //                     borderRadius: BorderRadius.circular(8),
// //                     border: Border.all(
// //                       color: isPaid ? Colors.green : Colors.orange,
// //                       width: 1,
// //                     ),
// //                   ),
// //                   child: Text(
// //                     isPaid ? 'تم الدفع' : 'لم يتم الدفع',
// //                     style: TextStyle(
// //                       color: isPaid ? Colors.green[800] : Colors.orange[800],
// //                       fontWeight: FontWeight.bold,
// //                       fontSize: 14,
// //                       fontFamily: 'Cairo',
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //               DataCell(
// //                 isPaid
// //                     ? Icon(Icons.check_circle, color: Colors.green, size: 28)
// //                     : ElevatedButton.icon(
// //                         onPressed: () => _markAsPaid(
// //                           employee.id,
// //                           data['name'] ?? '',
// //                           netSalary,
// //                         ),
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: Color(0xFF1B4F72),
// //                           foregroundColor: Colors.white,
// //                           padding: EdgeInsets.symmetric(
// //                             horizontal: 16,
// //                             vertical: 10,
// //                           ),
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(8),
// //                           ),
// //                         ),
// //                         icon: Icon(Icons.payment),
// //                         label: Text(
// //                           'دفع',
// //                           style: TextStyle(
// //                             fontSize: 14,
// //                             fontWeight: FontWeight.bold,
// //                             fontFamily: 'Cairo',
// //                           ),
// //                         ),
// //                       ),
// //               ),
// //             ],
// //           );
// //         }).toList(),
// //       ),
// //     );
// //   }
// // // }
// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';

// // class SalariesPage extends StatefulWidget {
// //   const SalariesPage({super.key});

// //   @override
// //   State<SalariesPage> createState() => _SalariesPageState();
// // }

// // class _SalariesPageState extends State<SalariesPage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   final TextEditingController _searchController = TextEditingController();
// //   int _selectedMonth = DateTime.now().month;
// //   int _selectedYear = DateTime.now().year;
// //   Map<String, bool> _paidStatus = {};
// //   Map<String, double> _employeePenalties = {};

// //   @override
// //   void initState() {
// //     super.initState();
// //     _searchController.addListener(_searchEmployees);
// //     _loadMonthData();
// //   }

// //   @override
// //   void dispose() {
// //     _searchController.dispose();
// //     super.dispose();
// //   }

// //   Future<void> _loadMonthData() async {
// //     // جلب الجزاءات لهذا الشهر
// //     final penaltiesQuery = await _firestore
// //         .collection('penalties')
// //         .where('month', isEqualTo: '$_selectedMonth/$_selectedYear')
// //         .get();

// //     final penaltiesMap = <String, double>{};
// //     for (final penalty in penaltiesQuery.docs) {
// //       final data = penalty.data() as Map<String, dynamic>;
// //       final employeeId = data['employeeId'];
// //       final amount = (data['amount'] ?? 0).toDouble();
// //       penaltiesMap[employeeId] = (penaltiesMap[employeeId] ?? 0) + amount;
// //     }

// //     // جلب حالة الدفع لهذا الشهر
// //     final paymentsQuery = await _firestore
// //         .collection('salaryPayments')
// //         .where('month', isEqualTo: '$_selectedMonth/$_selectedYear')
// //         .get();

// //     final paidMap = <String, bool>{};
// //     for (final payment in paymentsQuery.docs) {
// //       final data = payment.data() as Map<String, dynamic>;
// //       paidMap[data['employeeId']] = true;
// //     }

// //     setState(() {
// //       _employeePenalties = penaltiesMap;
// //       _paidStatus = paidMap;
// //     });
// //   }

// //   void _searchEmployees() {
// //     setState(() {});
// //   }

// //   Future<void> _markAsPaid(
// //     String employeeId,
// //     String employeeName,
// //     double netSalary,
// //   ) async {
// //     try {
// //       final salaryPayment = {
// //         'employeeId': employeeId,
// //         'employeeName': employeeName,
// //         'amount': netSalary,
// //         'date': DateTime.now().toIso8601String(),
// //         'month': '$_selectedMonth/$_selectedYear',
// //       };

// //       await _firestore.collection('salaryPayments').add(salaryPayment);

// //       setState(() {
// //         _paidStatus[employeeId] = true;
// //       });

// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text('تم تسجيل دفع الراتب لـ $employeeName'),
// //           backgroundColor: Colors.green,
// //         ),
// //       );
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text('خطأ في تسجيل الدفع: $e'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Directionality(
// //       textDirection: TextDirection.rtl,
// //       child: SingleChildScrollView(
// //         child: Column(
// //           children: [
// //             // الجزء العلوي مع الفلتر والبحث
// //             Card(
// //               elevation: 8,
// //               margin: EdgeInsets.all(16),
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(16),
// //               ),
// //               child: Padding(
// //                 padding: EdgeInsets.all(20),
// //                 child: Column(
// //                   children: [
// //                     SizedBox(height: 16),
// //                     _buildHeaderSection(),
// //                     SizedBox(height: 20),
// //                     _buildMonthFilter(),
// //                     SizedBox(height: 20),
// //                     _buildSearchBar(),
// //                     SizedBox(height: 16),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //             SizedBox(height: 16),

// //             // الجزء السفلي مع الجدول
// //             _buildSalariesTable(),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildHeaderSection() {
// //     return Center(
// //       child: Text(
// //         'رواتب الموظفين',
// //         style: TextStyle(
// //           fontSize: 24,
// //           fontWeight: FontWeight.bold,
// //           color: const Color(0xFF2C3E50),
// //           fontFamily: 'Cairo',
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildMonthFilter() {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.center,
// //       children: [
// //         Icon(Icons.calendar_month, color: Color(0xFF3498DB), size: 24),
// //         SizedBox(width: 10),
// //         Text(
// //           'شهر:',
// //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //         ),
// //         SizedBox(width: 10),
// //         DropdownButton<int>(
// //           value: _selectedMonth,
// //           onChanged: (value) {
// //             if (value != null) {
// //               setState(() {
// //                 _selectedMonth = value;
// //               });
// //               _loadMonthData();
// //             }
// //           },
// //           items: [
// //             for (int i = 1; i <= 12; i++)
// //               DropdownMenuItem(
// //                 value: i,
// //                 child: Text('شهر $i', style: TextStyle(fontSize: 16)),
// //               ),
// //           ],
// //           style: TextStyle(
// //             color: Color(0xFF2C3E50),
// //             fontSize: 16,
// //             fontFamily: 'Cairo',
// //           ),
// //         ),
// //         SizedBox(width: 30),
// //         Text(
// //           'سنة:',
// //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //         ),
// //         SizedBox(width: 10),
// //         DropdownButton<int>(
// //           value: _selectedYear,
// //           onChanged: (value) {
// //             if (value != null) {
// //               setState(() {
// //                 _selectedYear = value;
// //               });
// //               _loadMonthData();
// //             }
// //           },
// //           items: [
// //             for (
// //               int i = DateTime.now().year - 2;
// //               i <= DateTime.now().year + 2;
// //               i++
// //             )
// //               DropdownMenuItem(
// //                 value: i,
// //                 child: Text('$i', style: TextStyle(fontSize: 16)),
// //               ),
// //           ],
// //           style: TextStyle(
// //             color: Color(0xFF2C3E50),
// //             fontSize: 16,
// //             fontFamily: 'Cairo',
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildSearchBar() {
// //     return Container(
// //       margin: EdgeInsets.symmetric(horizontal: 20),
// //       padding: EdgeInsets.symmetric(horizontal: 16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: const Color(0xFF3498DB), width: 1.5),
// //         boxShadow: [
// //           BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
// //         ],
// //       ),
// //       child: Row(
// //         children: [
// //           Icon(Icons.search, color: const Color(0xFF3498DB), size: 28),
// //           SizedBox(width: 12),
// //           Expanded(
// //             child: TextField(
// //               controller: _searchController,
// //               textDirection: TextDirection.rtl,
// //               decoration: InputDecoration(
// //                 hintText: 'ابحث عن موظف...',
// //                 hintStyle: TextStyle(
// //                   color: Colors.grey,
// //                   fontSize: 16,
// //                   fontFamily: 'Cairo',
// //                 ),
// //                 border: InputBorder.none,
// //               ),
// //               style: TextStyle(fontSize: 16, fontFamily: 'Cairo'),
// //             ),
// //           ),
// //           if (_searchController.text.isNotEmpty)
// //             GestureDetector(
// //               onTap: () {
// //                 _searchController.clear();
// //                 _searchEmployees();
// //               },
// //               child: Icon(Icons.clear, size: 24, color: Colors.grey),
// //             ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildSalariesTable() {
// //     return Card(
// //       elevation: 8,
// //       margin: EdgeInsets.all(16),
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //       child: Padding(
// //         padding: EdgeInsets.all(16),
// //         child: StreamBuilder<QuerySnapshot>(
// //           stream: _firestore.collection('employees').snapshots(),
// //           builder: (context, snapshot) {
// //             if (snapshot.connectionState == ConnectionState.waiting) {
// //               return Center(child: CircularProgressIndicator());
// //             }

// //             if (snapshot.hasError) {
// //               return Center(child: Text('حدث خطأ: ${snapshot.error}'));
// //             }

// //             final employees = snapshot.data!.docs;
// //             final searchText = _searchController.text.toLowerCase();

// //             // تصفية الموظفين حسب البحث
// //             final filteredEmployees = employees.where((employee) {
// //               if (searchText.isEmpty) return true;
// //               final data = employee.data() as Map<String, dynamic>;
// //               final name = data['name']?.toString().toLowerCase() ?? '';
// //               return name.contains(searchText);
// //             }).toList();

// //             if (filteredEmployees.isEmpty) {
// //               return Center(
// //                 child: Column(
// //                   mainAxisAlignment: MainAxisAlignment.center,
// //                   children: [
// //                     Icon(Icons.people_outline, size: 80, color: Colors.grey),
// //                     SizedBox(height: 20),
// //                     Text(
// //                       searchText.isEmpty
// //                           ? 'لا يوجد موظفين مسجلين'
// //                           : 'لم يتم العثور على موظفين',
// //                       style: TextStyle(
// //                         fontSize: 18,
// //                         color: Colors.grey,
// //                         fontFamily: 'Cairo',
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               );
// //             }

// //             // حساب الإحصائيات مع مراعاة الموظفين المدفوعين
// //             double totalSalaries = 0;
// //             double totalPenalties = 0;
// //             double totalNet = 0;
// //             double totalPaid = 0;
// //             double totalUnpaid = 0;

// //             for (final employee in filteredEmployees) {
// //               final data = employee.data() as Map<String, dynamic>;
// //               final salary = (data['salary'] ?? 0).toDouble();
// //               final penalties = _employeePenalties[employee.id] ?? 0;
// //               final netSalary = salary - penalties;
// //               final isPaid = _paidStatus[employee.id] ?? false;

// //               totalSalaries += salary;
// //               totalPenalties += penalties;
// //               totalNet += netSalary;

// //               if (isPaid) {
// //                 totalPaid += netSalary;
// //               } else {
// //                 totalUnpaid += netSalary;
// //               }
// //             }

// //             return Column(
// //               children: [
// //                 // العنوان والإحصائيات
// //                 Padding(
// //                   padding: EdgeInsets.only(bottom: 20),
// //                   child: Column(
// //                     children: [
// //                       Text(
// //                         'تفاصيل الرواتب - شهر $_selectedMonth/$_selectedYear',
// //                         style: TextStyle(
// //                           fontSize: 20,
// //                           fontWeight: FontWeight.bold,
// //                           color: const Color(0xFF2C3E50),
// //                           fontFamily: 'Cairo',
// //                         ),
// //                       ),
// //                       SizedBox(height: 20),

// //                       // إحصائيات
// //                       Card(
// //                         elevation: 4,
// //                         child: Padding(
// //                           padding: EdgeInsets.all(16),
// //                           child: Column(
// //                             children: [
// //                               Row(
// //                                 mainAxisAlignment:
// //                                     MainAxisAlignment.spaceBetween,
// //                                 children: [
// //                                   Text(
// //                                     'إجمالي الرواتب قبل الخصم',
// //                                     style: TextStyle(
// //                                       fontSize: 16,
// //                                       fontWeight: FontWeight.bold,
// //                                       fontFamily: 'Cairo',
// //                                     ),
// //                                   ),
// //                                   Text(
// //                                     '${totalSalaries.toStringAsFixed(2)} جنية',
// //                                     style: TextStyle(
// //                                       fontSize: 16,
// //                                       color: Colors.green,
// //                                       fontWeight: FontWeight.bold,
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                               SizedBox(height: 12),
// //                               Row(
// //                                 mainAxisAlignment:
// //                                     MainAxisAlignment.spaceBetween,
// //                                 children: [
// //                                   Text(
// //                                     'إجمالي الجزاءات:',
// //                                     style: TextStyle(
// //                                       fontSize: 16,
// //                                       fontWeight: FontWeight.bold,
// //                                       fontFamily: 'Cairo',
// //                                     ),
// //                                   ),
// //                                   Text(
// //                                     '${totalPenalties.toStringAsFixed(2)} جنية',
// //                                     style: TextStyle(
// //                                       fontSize: 16,
// //                                       color: Colors.red,
// //                                       fontWeight: FontWeight.bold,
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                               SizedBox(height: 12),
// //                               Row(
// //                                 mainAxisAlignment:
// //                                     MainAxisAlignment.spaceBetween,
// //                                 children: [
// //                                   Text(
// //                                     'إجمالي الرواتب المدفوعه ',
// //                                     style: TextStyle(
// //                                       fontSize: 16,
// //                                       fontWeight: FontWeight.bold,
// //                                       fontFamily: 'Cairo',
// //                                     ),
// //                                   ),
// //                                   Text(
// //                                     '${totalPaid.toStringAsFixed(2)} جنية',
// //                                     style: TextStyle(
// //                                       fontSize: 16,
// //                                       color: Colors.blue,
// //                                       fontWeight: FontWeight.bold,
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                               SizedBox(height: 12),
// //                               Row(
// //                                 mainAxisAlignment:
// //                                     MainAxisAlignment.spaceBetween,
// //                                 children: [
// //                                   Text(
// //                                     'إجمالي الرواتب غير المدفوعه',
// //                                     style: TextStyle(
// //                                       fontSize: 16,
// //                                       fontWeight: FontWeight.bold,
// //                                       fontFamily: 'Cairo',
// //                                     ),
// //                                   ),
// //                                   Text(
// //                                     '${totalUnpaid.toStringAsFixed(2)} جنية',
// //                                     style: TextStyle(
// //                                       fontSize: 16,
// //                                       color: Colors.orange,
// //                                       fontWeight: FontWeight.bold,
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                               SizedBox(height: 12),
// //                               Divider(thickness: 2, color: Color(0xFF3498DB)),
// //                               SizedBox(height: 12),
// //                               Row(
// //                                 mainAxisAlignment:
// //                                     MainAxisAlignment.spaceBetween,
// //                                 children: [
// //                                   Text(
// //                                     'إجمالي  صافي الرواتب:',
// //                                     style: TextStyle(
// //                                       fontSize: 18,
// //                                       fontWeight: FontWeight.bold,
// //                                       fontFamily: 'Cairo',
// //                                     ),
// //                                   ),
// //                                   Text(
// //                                     '${totalNet.toStringAsFixed(2)} جنية',
// //                                     style: TextStyle(
// //                                       fontSize: 18,
// //                                       color: Color(0xFF3498DB),
// //                                       fontWeight: FontWeight.bold,
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),

// //                 // الجدول
// //                 MediaQuery.of(context).size.width < 600
// //                     ? _buildDesktopTable(filteredEmployees)
// //                     : _buildDesktopTable(filteredEmployees),
// //               ],
// //             );
// //           },
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildMobileTable(List<QueryDocumentSnapshot> employees) {
// //     return ListView.builder(
// //       shrinkWrap: true,
// //       physics: NeverScrollableScrollPhysics(),
// //       itemCount: employees.length,
// //       itemBuilder: (context, index) {
// //         final employee = employees[index];
// //         final data = employee.data() as Map<String, dynamic>;
// //         final basicSalary = (data['salary'] ?? 0).toDouble();
// //         final penalties = _employeePenalties[employee.id] ?? 0;
// //         final netSalary = basicSalary - penalties;
// //         final isPaid = _paidStatus[employee.id] ?? false;

// //         return Card(
// //           margin: EdgeInsets.only(bottom: 12),
// //           elevation: 2,
// //           child: Padding(
// //             padding: EdgeInsets.all(16),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Expanded(
// //                       child: Row(
// //                         children: [
// //                           Text(
// //                             '${index + 1}.',
// //                             style: TextStyle(
// //                               fontWeight: FontWeight.bold,
// //                               fontSize: 16,
// //                             ),
// //                           ),
// //                           SizedBox(width: 8),
// //                           Expanded(
// //                             child: Text(
// //                               data['name'] ?? 'غير محدد',
// //                               style: TextStyle(
// //                                 fontWeight: FontWeight.bold,
// //                                 fontSize: 16,
// //                                 fontFamily: 'Cairo',
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     Container(
// //                       padding: EdgeInsets.symmetric(
// //                         horizontal: 12,
// //                         vertical: 6,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: isPaid ? Colors.green[50] : Colors.orange[50],
// //                         borderRadius: BorderRadius.circular(8),
// //                         border: Border.all(
// //                           color: isPaid ? Colors.green : Colors.orange,
// //                           width: 1,
// //                         ),
// //                       ),
// //                       child: Text(
// //                         isPaid ? 'تم الدفع' : 'لم يتم الدفع',
// //                         style: TextStyle(
// //                           color: isPaid
// //                               ? Colors.green[800]
// //                               : Colors.orange[800],
// //                           fontWeight: FontWeight.bold,
// //                           fontSize: 14,
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 SizedBox(height: 12),
// //                 Divider(),
// //                 SizedBox(height: 12),
// //                 _buildInfoRow('الوظيفة:', data['job'] ?? 'غير محدد'),
// //                 SizedBox(height: 8),
// //                 _buildInfoRow(
// //                   'الراتب:',
// //                   '$basicSalary جنية',
// //                   valueColor: Colors.green,
// //                 ),
// //                 SizedBox(height: 8),
// //                 _buildInfoRow(
// //                   'الجزاءات:',
// //                   '$penalties جنية',
// //                   valueColor: Colors.red,
// //                 ),
// //                 SizedBox(height: 12),
// //                 Divider(),
// //                 SizedBox(height: 12),
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Text(
// //                       'الصافي:',
// //                       style: TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                         color: Color(0xFF3498DB),
// //                         fontFamily: 'Cairo',
// //                       ),
// //                     ),
// //                     Text(
// //                       '$netSalary جنية',
// //                       style: TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                         color: Color(0xFF3498DB),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 SizedBox(height: 16),
// //                 if (!isPaid)
// //                   SizedBox(
// //                     width: double.infinity,
// //                     child: ElevatedButton.icon(
// //                       onPressed: () => _markAsPaid(
// //                         employee.id,
// //                         data['name'] ?? '',
// //                         netSalary,
// //                       ),
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: Color(0xFF1B4F72),
// //                         foregroundColor: Colors.white,
// //                         padding: EdgeInsets.symmetric(vertical: 14),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(10),
// //                         ),
// //                         elevation: 4,
// //                       ),
// //                       icon: Icon(Icons.payment),
// //                       label: Text(
// //                         'تسديد الراتب',
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.bold,
// //                           fontFamily: 'Cairo',
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
// //     return Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         Text(
// //           label,
// //           style: TextStyle(
// //             color: Colors.grey[700],
// //             fontSize: 15,
// //             fontFamily: 'Cairo',
// //           ),
// //         ),
// //         Text(
// //           value,
// //           style: TextStyle(
// //             fontSize: 15,
// //             fontWeight: FontWeight.bold,
// //             color: valueColor ?? Colors.black,
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildDesktopTable(List<QueryDocumentSnapshot> employees) {
// //     return SingleChildScrollView(
// //       scrollDirection: Axis.horizontal,
// //       child: Container(
// //         margin: const EdgeInsets.all(12),
// //         decoration: BoxDecoration(
// //           border: Border.all(color: Colors.blueAccent, width: 1.2),
// //           borderRadius: BorderRadius.circular(10),
// //         ),
// //         child: DataTable(
// //           border: TableBorder.all(
// //             color: Colors.blueAccent,
// //             width: 1,
// //             borderRadius: BorderRadius.circular(10),
// //           ),
// //           columnSpacing: 90,
// //           horizontalMargin: 16,
// //           headingRowHeight: 55,
// //           dataRowHeight: 60,
// //           headingRowColor: MaterialStateProperty.all(const Color(0xFFEAF2FB)),
// //           headingTextStyle: const TextStyle(
// //             fontSize: 15,
// //             fontWeight: FontWeight.bold,
// //             color: Color(0xFF1B4F72),
// //             fontFamily: 'Cairo',
// //           ),
// //           columns: const [
// //             DataColumn(label: Center(child: Text('ر.ق'))),
// //             DataColumn(label: Center(child: Text('اسم الموظف'))),
// //             DataColumn(label: Center(child: Text('الوظيفة'))),
// //             DataColumn(label: Center(child: Text('الراتب'))),
// //             DataColumn(label: Center(child: Text('الجزاءات'))),
// //             DataColumn(label: Center(child: Text('الصافي'))),
// //             DataColumn(label: Center(child: Text('حالة الدفع'))),
// //             DataColumn(label: Center(child: Text('الإجراءات'))),
// //           ],
// //           rows: employees.asMap().entries.map((entry) {
// //             final index = entry.key;
// //             final employee = entry.value;
// //             final data = employee.data() as Map<String, dynamic>;

// //             final basicSalary = (data['salary'] ?? 0).toDouble();
// //             final penalties = _employeePenalties[employee.id] ?? 0;
// //             final netSalary = basicSalary - penalties;
// //             final isPaid = _paidStatus[employee.id] ?? false;

// //             return DataRow(
// //               color: MaterialStateProperty.all(
// //                 index.isEven ? Colors.white : const Color(0xFFF8FBFF),
// //               ),
// //               cells: [
// //                 _buildGridCell('${index + 1}', bold: true),

// //                 _buildGridCell(data['name'] ?? 'غير محدد'),

// //                 _buildGridCell(data['position'] ?? 'غير محدد'),

// //                 _buildGridCell(
// //                   '${basicSalary.toStringAsFixed(2)} ج',
// //                   color: Colors.green,
// //                   bold: true,
// //                 ),

// //                 _buildGridCell(
// //                   '${penalties.toStringAsFixed(2)} ج',
// //                   color: Colors.red,
// //                   bold: true,
// //                 ),

// //                 _buildGridCell(
// //                   '${netSalary.toStringAsFixed(2)} ج',
// //                   color: const Color(0xFF3498DB),
// //                   bold: true,
// //                 ),

// //                 DataCell(
// //                   Center(
// //                     child: Container(
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 14,
// //                         vertical: 6,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: isPaid ? Colors.green[50] : Colors.orange[50],
// //                         borderRadius: BorderRadius.circular(6),
// //                         border: Border.all(
// //                           color: isPaid ? Colors.green : Colors.orange,
// //                         ),
// //                       ),
// //                       child: Text(
// //                         isPaid ? 'تم الدفع' : 'لم يتم الدفع',
// //                         style: TextStyle(
// //                           fontFamily: 'Cairo',
// //                           fontWeight: FontWeight.bold,
// //                           fontSize: 13,
// //                           color: isPaid
// //                               ? Colors.green[800]
// //                               : Colors.orange[800],
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),

// //                 DataCell(
// //                   Center(
// //                     child: isPaid
// //                         ? const Icon(Icons.check_circle, color: Colors.green)
// //                         : ElevatedButton.icon(
// //                             onPressed: () => _markAsPaid(
// //                               employee.id,
// //                               data['name'] ?? '',
// //                               netSalary,
// //                             ),
// //                             style: ElevatedButton.styleFrom(
// //                               backgroundColor: const Color(0xFF1B4F72),
// //                               padding: const EdgeInsets.symmetric(
// //                                 horizontal: 14,
// //                                 vertical: 8,
// //                               ),
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(8),
// //                               ),
// //                             ),
// //                             icon: const Icon(
// //                               Icons.payment,
// //                               size: 18,
// //                               color: Colors.white,
// //                             ),
// //                             label: const Text(
// //                               'دفع',
// //                               style: TextStyle(
// //                                 fontFamily: 'Cairo',
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.white,
// //                               ),
// //                             ),
// //                           ),
// //                   ),
// //                 ),
// //               ],
// //             );
// //           }).toList(),
// //         ),
// //       ),
// //     );
// //   }

// //   /// خلية شبكية موحدة
// //   DataCell _buildGridCell(String text, {Color? color, bool bold = false}) {
// //     return DataCell(
// //       Center(
// //         child: Text(
// //           text,
// //           textAlign: TextAlign.center,
// //           style: TextStyle(
// //             fontFamily: 'Cairo',
// //             fontSize: 14,
// //             fontWeight: bold ? FontWeight.bold : FontWeight.normal,
// //             color: color ?? const Color(0xFF2C3E50),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class SalariesPage extends StatefulWidget {
//   const SalariesPage({super.key});

//   @override
//   State<SalariesPage> createState() => _SalariesPageState();
// }

// class _SalariesPageState extends State<SalariesPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final TextEditingController _searchController = TextEditingController();
//   int _selectedMonth = DateTime.now().month;
//   int _selectedYear = DateTime.now().year;
//   Map<String, double> _employeePenalties = {};
//   Map<String, double> _employeePaidAmounts = {}; // المبالغ المدفوعة جزئياً

//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(_searchEmployees);
//     _loadMonthData();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadMonthData() async {
//     // جلب الجزاءات لهذا الشهر
//     final penaltiesQuery = await _firestore
//         .collection('penalties')
//         .where('month', isEqualTo: '$_selectedMonth/$_selectedYear')
//         .get();

//     final penaltiesMap = <String, double>{};
//     for (final penalty in penaltiesQuery.docs) {
//       final data = penalty.data();
//       final employeeId = data['employeeId'];
//       final amount = (data['amount'] ?? 0).toDouble();
//       penaltiesMap[employeeId] = (penaltiesMap[employeeId] ?? 0) + amount;
//     }

//     // جلب المدفوعات الجزئية لهذا الشهر
//     final paymentsQuery = await _firestore
//         .collection('salaryPayments')
//         .where('month', isEqualTo: '$_selectedMonth/$_selectedYear')
//         .get();

//     final paidAmountsMap = <String, double>{};
//     for (final payment in paymentsQuery.docs) {
//       final data = payment.data();
//       final employeeId = data['employeeId'];
//       final amount = (data['amount'] ?? 0).toDouble();
//       paidAmountsMap[employeeId] = (paidAmountsMap[employeeId] ?? 0) + amount;
//     }

//     setState(() {
//       _employeePenalties = penaltiesMap;
//       _employeePaidAmounts = paidAmountsMap;
//     });
//   }

//   void _searchEmployees() {
//     setState(() {});
//   }

//   // دالة الدفع الجزئي
//   Future<void> _makePartialPayment(
//     String employeeId,
//     String employeeName,
//     double netSalary,
//     double alreadyPaid,
//   ) async {
//     final remainingAmount = netSalary - alreadyPaid;
//     final paymentController = TextEditingController();

//     await showDialog(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: TextDirection.rtl,
//         child: AlertDialog(
//           title: Row(
//             children: [
//               Icon(Icons.payment, color: Colors.blue),
//               SizedBox(width: 8),
//               Text('دفع جزئي للموظف'),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('الموظف: $employeeName'),
//               SizedBox(height: 8),
//               Text('الراتب الصافي: ${netSalary.toStringAsFixed(2)} ج'),
//               SizedBox(height: 8),
//               Text('المدفوع مسبقاً: ${alreadyPaid.toStringAsFixed(2)} ج'),
//               SizedBox(height: 8),
//               Text('المتبقي: ${remainingAmount.toStringAsFixed(2)} ج'),
//               SizedBox(height: 16),
//               TextField(
//                 controller: paymentController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   labelText: 'المبلغ المطلوب دفعه',
//                   prefixIcon: Icon(Icons.attach_money),
//                   hintText: 'أدخل المبلغ',
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
//               onPressed: () async {
//                 final amount = double.tryParse(paymentController.text) ?? 0;
//                 if (amount <= 0) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('يرجى إدخال مبلغ صحيح'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                   return;
//                 }
//                 if (amount > remainingAmount) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('المبلغ أكبر من المبلغ المتبقي'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                   return;
//                 }

//                 await _savePartialPayment(employeeId, employeeName, amount);
//                 Navigator.pop(context);
//               },
//               child: Text('دفع'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // دالة حفظ الدفع الجزئي
//   Future<void> _savePartialPayment(
//     String employeeId,
//     String employeeName,
//     double amount,
//   ) async {
//     try {
//       final paymentData = {
//         'employeeId': employeeId,
//         'employeeName': employeeName,
//         'amount': amount,
//         'date': DateTime.now().toIso8601String(),
//         'month': '$_selectedMonth/$_selectedYear',
//         'paymentType': 'partial', // نوع الدفع: جزئي
//         'remainingAmount': FieldValue.increment(-amount),
//       };

//       await _firestore.collection('salaryPayments').add(paymentData);

//       // تحديث المبلغ المدفوع للموظف
//       setState(() {
//         _employeePaidAmounts[employeeId] =
//             (_employeePaidAmounts[employeeId] ?? 0) + amount;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'تم دفع ${amount.toStringAsFixed(2)} ج لـ $employeeName',
//           ),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('خطأ في تسجيل الدفع: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   // دالة الدفع الكامل
//   Future<void> _makeFullPayment(
//     String employeeId,
//     String employeeName,
//     double netSalary,
//     double alreadyPaid,
//   ) async {
//     try {
//       final remainingAmount = netSalary - alreadyPaid;
//       if (remainingAmount <= 0) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('الراتب مدفوع بالكامل بالفعل'),
//             backgroundColor: Colors.blue,
//           ),
//         );
//         return;
//       }

//       final paymentData = {
//         'employeeId': employeeId,
//         'employeeName': employeeName,
//         'amount': remainingAmount,
//         'date': DateTime.now().toIso8601String(),
//         'month': '$_selectedMonth/$_selectedYear',
//         'paymentType': 'full', // نوع الدفع: كامل
//         'remainingAmount': 0,
//       };

//       await _firestore.collection('salaryPayments').add(paymentData);

//       setState(() {
//         _employeePaidAmounts[employeeId] =
//             netSalary; // يصبح المدفوع = الراتب الكامل
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('تم دفع الراتب بالكامل لـ $employeeName'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('خطأ في تسجيل الدفع: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Directionality(
//       textDirection: TextDirection.rtl,
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             Card(
//               elevation: 8,
//               margin: EdgeInsets.all(16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Padding(
//                 padding: EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     SizedBox(height: 16),
//                     _buildHeaderSection(),
//                     SizedBox(height: 20),
//                     _buildMonthFilter(),
//                     SizedBox(height: 20),
//                     _buildSearchBar(),
//                     SizedBox(height: 16),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 16),
//             _buildSalariesTable(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeaderSection() {
//     return Center(
//       child: Text(
//         'رواتب الموظفين',
//         style: TextStyle(
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//           color: const Color(0xFF2C3E50),
//           fontFamily: 'Cairo',
//         ),
//       ),
//     );
//   }

//   Widget _buildMonthFilter() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Icon(Icons.calendar_month, color: Color(0xFF3498DB), size: 24),
//         SizedBox(width: 10),
//         Text(
//           'شهر:',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         SizedBox(width: 10),
//         DropdownButton<int>(
//           value: _selectedMonth,
//           onChanged: (value) {
//             if (value != null) {
//               setState(() {
//                 _selectedMonth = value;
//               });
//               _loadMonthData();
//             }
//           },
//           items: [
//             for (int i = 1; i <= 12; i++)
//               DropdownMenuItem(
//                 value: i,
//                 child: Text('شهر $i', style: TextStyle(fontSize: 16)),
//               ),
//           ],
//           style: TextStyle(
//             color: Color(0xFF2C3E50),
//             fontSize: 16,
//             fontFamily: 'Cairo',
//           ),
//         ),
//         SizedBox(width: 30),
//         Text(
//           'سنة:',
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         SizedBox(width: 10),
//         DropdownButton<int>(
//           value: _selectedYear,
//           onChanged: (value) {
//             if (value != null) {
//               setState(() {
//                 _selectedYear = value;
//               });
//               _loadMonthData();
//             }
//           },
//           items: [
//             for (
//               int i = DateTime.now().year - 2;
//               i <= DateTime.now().year + 2;
//               i++
//             )
//               DropdownMenuItem(
//                 value: i,
//                 child: Text('$i', style: TextStyle(fontSize: 16)),
//               ),
//           ],
//           style: TextStyle(
//             color: Color(0xFF2C3E50),
//             fontSize: 16,
//             fontFamily: 'Cairo',
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSearchBar() {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 20),
//       padding: EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFF3498DB), width: 1.5),
//         boxShadow: [
//           BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
//         ],
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.search, color: const Color(0xFF3498DB), size: 28),
//           SizedBox(width: 12),
//           Expanded(
//             child: TextField(
//               controller: _searchController,
//               textDirection: TextDirection.rtl,
//               decoration: InputDecoration(
//                 hintText: 'ابحث عن موظف...',
//                 hintStyle: TextStyle(
//                   color: Colors.grey,
//                   fontSize: 16,
//                   fontFamily: 'Cairo',
//                 ),
//                 border: InputBorder.none,
//               ),
//               style: TextStyle(fontSize: 16, fontFamily: 'Cairo'),
//             ),
//           ),
//           if (_searchController.text.isNotEmpty)
//             GestureDetector(
//               onTap: () {
//                 _searchController.clear();
//                 _searchEmployees();
//               },
//               child: Icon(Icons.clear, size: 24, color: Colors.grey),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSalariesTable() {
//     return Card(
//       elevation: 8,
//       margin: EdgeInsets.all(16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: StreamBuilder<QuerySnapshot>(
//           stream: _firestore.collection('employees').snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             }

//             if (snapshot.hasError) {
//               return Center(child: Text('حدث خطأ: ${snapshot.error}'));
//             }

//             final employees = snapshot.data!.docs;
//             final searchText = _searchController.text.toLowerCase();

//             final filteredEmployees = employees.where((employee) {
//               if (searchText.isEmpty) return true;
//               final data = employee.data() as Map<String, dynamic>;
//               final name = data['name']?.toString().toLowerCase() ?? '';
//               return name.contains(searchText);
//             }).toList();

//             if (filteredEmployees.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.people_outline, size: 80, color: Colors.grey),
//                     SizedBox(height: 20),
//                     Text(
//                       searchText.isEmpty
//                           ? 'لا يوجد موظفين مسجلين'
//                           : 'لم يتم العثور على موظفين',
//                       style: TextStyle(
//                         fontSize: 18,
//                         color: Colors.grey,
//                         fontFamily: 'Cairo',
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             // حساب الإحصائيات مع مراعاة الدفع الجزئي
//             double totalSalaries = 0;
//             double totalPenalties = 0;
//             double totalNet = 0;
//             double totalPaid = 0;
//             double totalRemaining = 0;

//             for (final employee in filteredEmployees) {
//               final data = employee.data() as Map<String, dynamic>;
//               final salary = (data['salary'] ?? 0).toDouble();
//               final penalties = _employeePenalties[employee.id] ?? 0;
//               final netSalary = salary - penalties;
//               final paidAmount = _employeePaidAmounts[employee.id] ?? 0;

//               totalSalaries += salary;
//               totalPenalties += penalties;
//               totalNet += netSalary;
//               totalPaid += paidAmount;
//               totalRemaining += (netSalary - paidAmount);
//             }

//             return Column(
//               children: [
//                 Padding(
//                   padding: EdgeInsets.only(bottom: 20),
//                   child: Column(
//                     children: [
//                       Text(
//                         'تفاصيل الرواتب - شهر $_selectedMonth/$_selectedYear',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: const Color(0xFF2C3E50),
//                           fontFamily: 'Cairo',
//                         ),
//                       ),
//                       SizedBox(height: 20),

//                       // إحصائيات محدثة
//                       Card(
//                         elevation: 4,
//                         child: Padding(
//                           padding: EdgeInsets.all(16),
//                           child: Column(
//                             children: [
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     'إجمالي الرواتب قبل الخصم',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       fontFamily: 'Cairo',
//                                     ),
//                                   ),
//                                   Text(
//                                     '${totalSalaries.toStringAsFixed(2)} جنية',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.green,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 12),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     'إجمالي الجزاءات:',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       fontFamily: 'Cairo',
//                                     ),
//                                   ),
//                                   Text(
//                                     '${totalPenalties.toStringAsFixed(2)} جنية',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.red,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 12),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     'إجمالي المدفوعات:',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       fontFamily: 'Cairo',
//                                     ),
//                                   ),
//                                   Text(
//                                     '${totalPaid.toStringAsFixed(2)} جنية',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.blue,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 12),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     'إجمالي المتبقي:',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                       fontFamily: 'Cairo',
//                                     ),
//                                   ),
//                                   Text(
//                                     '${totalRemaining.toStringAsFixed(2)} جنية',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.orange,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 12),
//                               Divider(thickness: 2, color: Color(0xFF3498DB)),
//                               SizedBox(height: 12),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     'إجمالي صافي الرواتب:',
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       fontFamily: 'Cairo',
//                                     ),
//                                   ),
//                                   Text(
//                                     '${totalNet.toStringAsFixed(2)} جنية',
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       color: Color(0xFF3498DB),
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // الجدول
//                 MediaQuery.of(context).size.width < 600
//                     ? _buildMobileTable(filteredEmployees)
//                     : _buildDesktopTable(filteredEmployees),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildMobileTable(List<QueryDocumentSnapshot> employees) {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: NeverScrollableScrollPhysics(),
//       itemCount: employees.length,
//       itemBuilder: (context, index) {
//         final employee = employees[index];
//         final data = employee.data() as Map<String, dynamic>;
//         final basicSalary = (data['salary'] ?? 0).toDouble();
//         final penalties = _employeePenalties[employee.id] ?? 0;
//         final netSalary = basicSalary - penalties;
//         final paidAmount = _employeePaidAmounts[employee.id] ?? 0;
//         final remainingAmount = netSalary - paidAmount;
//         final isFullyPaid = remainingAmount <= 0;

//         return Card(
//           margin: EdgeInsets.only(bottom: 12),
//           elevation: 2,
//           child: Padding(
//             padding: EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Row(
//                         children: [
//                           Text(
//                             '${index + 1}.',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               data['name'] ?? 'غير محدد',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                                 fontFamily: 'Cairo',
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: isFullyPaid
//                             ? Colors.green[50]
//                             : Colors.orange[50],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           color: isFullyPaid ? Colors.green : Colors.orange,
//                           width: 1,
//                         ),
//                       ),
//                       child: Text(
//                         isFullyPaid ? 'مدفوع بالكامل' : 'مدفوع جزئياً',
//                         style: TextStyle(
//                           color: isFullyPaid
//                               ? Colors.green[800]
//                               : Colors.orange[800],
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 12),
//                 Divider(),
//                 SizedBox(height: 12),
//                 _buildInfoRow('الوظيفة:', data['job'] ?? 'غير محدد'),
//                 SizedBox(height: 8),
//                 _buildInfoRow(
//                   'الراتب:',
//                   '$basicSalary جنية',
//                   valueColor: Colors.green,
//                 ),
//                 SizedBox(height: 8),
//                 _buildInfoRow(
//                   'الجزاءات:',
//                   '$penalties جنية',
//                   valueColor: Colors.red,
//                 ),
//                 SizedBox(height: 8),
//                 _buildInfoRow(
//                   'المدفوع:',
//                   '${paidAmount.toStringAsFixed(2)} جنية',
//                   valueColor: Colors.blue,
//                 ),
//                 SizedBox(height: 8),
//                 _buildInfoRow(
//                   'المتبقي:',
//                   '${remainingAmount.toStringAsFixed(2)} جنية',
//                   valueColor: Colors.orange,
//                 ),
//                 SizedBox(height: 12),
//                 Divider(),
//                 SizedBox(height: 12),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'الصافي:',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF3498DB),
//                         fontFamily: 'Cairo',
//                       ),
//                     ),
//                     Text(
//                       '${netSalary.toStringAsFixed(2)} جنية',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF3498DB),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),
//                 if (!isFullyPaid)
//                   Row(
//                     children: [
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           onPressed: () => _makePartialPayment(
//                             employee.id,
//                             data['name'] ?? '',
//                             netSalary,
//                             paidAmount,
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Color(0xFF3498DB),
//                             foregroundColor: Colors.white,
//                             padding: EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           icon: Icon(Icons.payment),
//                           label: Text(
//                             'دفع جزئي',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(width: 10),
//                       Expanded(
//                         child: ElevatedButton.icon(
//                           onPressed: () => _makeFullPayment(
//                             employee.id,
//                             data['name'] ?? '',
//                             netSalary,
//                             paidAmount,
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Color(0xFF1B4F72),
//                             foregroundColor: Colors.white,
//                             padding: EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                           icon: Icon(Icons.check_circle),
//                           label: Text(
//                             'دفع كامل',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             color: Colors.grey[700],
//             fontSize: 15,
//             fontFamily: 'Cairo',
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.bold,
//             color: valueColor ?? Colors.black,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDesktopTable(List<QueryDocumentSnapshot> employees) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Container(
//         margin: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.transparent, width: 1.2),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: DataTable(
//           border: TableBorder.all(
//             color: Colors.blueAccent,
//             width: 1,
//             borderRadius: BorderRadius.circular(10),
//           ),
//           columnSpacing: 55,
//           horizontalMargin: 16,
//           headingRowHeight: 55,
//           dataRowHeight: 60,
//           headingRowColor: WidgetStateProperty.all(const Color(0xFFEAF2FB)),
//           headingTextStyle: const TextStyle(
//             fontSize: 15,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF1B4F72),
//             fontFamily: 'Cairo',
//           ),
//           columns: const [
//             DataColumn(label: Center(child: Text('ر.ق'))),
//             DataColumn(label: Center(child: Text('اسم الموظف'))),
//             DataColumn(label: Center(child: Text('الوظيفة'))),
//             DataColumn(label: Center(child: Text('الراتب'))),
//             DataColumn(label: Center(child: Text('الجزاءات'))),
//             DataColumn(label: Center(child: Text('الصافي'))),
//             DataColumn(label: Center(child: Text('المدفوع'))),
//             DataColumn(label: Center(child: Text('المتبقي'))),
//             DataColumn(label: Center(child: Text('الحالة'))),
//             DataColumn(label: Center(child: Text('الإجراءات'))),
//           ],
//           rows: employees.asMap().entries.map((entry) {
//             final index = entry.key;
//             final employee = entry.value;
//             final data = employee.data() as Map<String, dynamic>;

//             final basicSalary = (data['salary'] ?? 0).toDouble();
//             final penalties = _employeePenalties[employee.id] ?? 0;
//             final netSalary = basicSalary - penalties;
//             final paidAmount = _employeePaidAmounts[employee.id] ?? 0;
//             final remainingAmount = netSalary - paidAmount;
//             final isFullyPaid = remainingAmount <= 0;
//             final paymentPercentage = netSalary > 0
//                 ? (paidAmount / netSalary * 100)
//                 : 0;

//             return DataRow(
//               color: WidgetStateProperty.all(
//                 index.isEven ? Colors.white : const Color(0xFFF8FBFF),
//               ),
//               cells: [
//                 _buildGridCell('${index + 1}', bold: true),
//                 _buildGridCell(data['name'] ?? 'غير محدد'),
//                 _buildGridCell(data['position'] ?? 'غير محدد'),
//                 _buildGridCell(
//                   '${basicSalary.toStringAsFixed(2)} ج',
//                   color: Colors.green,
//                   bold: true,
//                 ),
//                 _buildGridCell(
//                   '${penalties.toStringAsFixed(2)} ج',
//                   color: Colors.red,
//                   bold: true,
//                 ),
//                 _buildGridCell(
//                   '${netSalary.toStringAsFixed(2)} ج',
//                   color: const Color(0xFF3498DB),
//                   bold: true,
//                 ),
//                 _buildGridCell(
//                   '${paidAmount.toStringAsFixed(2)} ج',
//                   color: Colors.blue,
//                   bold: true,
//                 ),
//                 _buildGridCell(
//                   '${remainingAmount.toStringAsFixed(2)} ج',
//                   color: Colors.orange,
//                   bold: true,
//                 ),
//                 DataCell(
//                   Center(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 14,
//                             vertical: 6,
//                           ),
//                           decoration: BoxDecoration(
//                             color: isFullyPaid
//                                 ? Colors.green[50]
//                                 : Colors.orange[50],
//                             borderRadius: BorderRadius.circular(6),
//                             border: Border.all(
//                               color: isFullyPaid ? Colors.green : Colors.orange,
//                             ),
//                           ),
//                           child: Text(
//                             isFullyPaid ? 'مدفوع بالكامل' : 'مدفوع جزئياً',
//                             style: TextStyle(
//                               fontFamily: 'Cairo',
//                               fontWeight: FontWeight.bold,
//                               fontSize: 13,
//                               color: isFullyPaid
//                                   ? Colors.green[800]
//                                   : Colors.orange[800],
//                             ),
//                           ),
//                         ),
//                         if (!isFullyPaid)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 4),
//                             child: Text(
//                               '${paymentPercentage.toStringAsFixed(1)}%',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[700],
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 DataCell(
//                   Center(
//                     child: isFullyPaid
//                         ? const Icon(Icons.check_circle, color: Colors.green)
//                         : Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               ElevatedButton(
//                                 onPressed: () => _makePartialPayment(
//                                   employee.id,
//                                   data['name'] ?? '',
//                                   netSalary,
//                                   paidAmount,
//                                 ),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFF3498DB),
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 10,
//                                     vertical: 6,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                 ),
//                                 child: const Text(
//                                   'دفع جزئي',
//                                   style: TextStyle(
//                                     fontFamily: 'Cairo',
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(width: 8),
//                               ElevatedButton(
//                                 onPressed: () => _makeFullPayment(
//                                   employee.id,
//                                   data['name'] ?? '',
//                                   netSalary,
//                                   paidAmount,
//                                 ),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFF1B4F72),
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 10,
//                                     vertical: 6,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                 ),
//                                 child: const Text(
//                                   'دفع كامل',
//                                   style: TextStyle(
//                                     fontFamily: 'Cairo',
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                   ),
//                 ),
//               ],
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   DataCell _buildGridCell(String text, {Color? color, bool bold = false}) {
//     return DataCell(
//       Center(
//         child: Text(
//           text,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontFamily: 'Cairo',
//             fontSize: 14,
//             fontWeight: bold ? FontWeight.bold : FontWeight.normal,
//             color: color ?? const Color(0xFF2C3E50),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as x;

class SalariesPage extends StatefulWidget {
  const SalariesPage({super.key});

  @override
  State<SalariesPage> createState() => _SalariesPageState();
}

class _SalariesPageState extends State<SalariesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  Map<String, double> _employeePenalties = {};
  Map<String, double> _employeePaidAmounts = {};
  double _treasuryBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_searchEmployees);
    _loadMonthData();
    _loadTreasuryBalance();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // تحميل رصيد الخزنة
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

  Future<void> _loadMonthData() async {
    // جلب الجزاءات لهذا الشهر
    final penaltiesQuery = await _firestore
        .collection('penalties')
        .where('month', isEqualTo: '$_selectedMonth/$_selectedYear')
        .get();

    final penaltiesMap = <String, double>{};
    for (final penalty in penaltiesQuery.docs) {
      final data = penalty.data();
      final employeeId = data['employeeId'];
      final amount = (data['amount'] ?? 0).toDouble();
      penaltiesMap[employeeId] = (penaltiesMap[employeeId] ?? 0) + amount;
    }

    // جلب المدفوعات الجزئية لهذا الشهر
    final paymentsQuery = await _firestore
        .collection('salaryPayments')
        .where('month', isEqualTo: '$_selectedMonth/$_selectedYear')
        .get();

    final paidAmountsMap = <String, double>{};
    for (final payment in paymentsQuery.docs) {
      final data = payment.data();
      final employeeId = data['employeeId'];
      final amount = (data['amount'] ?? 0).toDouble();
      paidAmountsMap[employeeId] = (paidAmountsMap[employeeId] ?? 0) + amount;
    }

    setState(() {
      _employeePenalties = penaltiesMap;
      _employeePaidAmounts = paidAmountsMap;
    });
  }

  void _searchEmployees() {
    setState(() {});
  }

  // دالة لإضافة المصروف إلى الخزنة
  Future<void> _addExpenseToTreasury({
    required String employeeName,
    required double amount,
    required String paymentType,
    required String month,
  }) async {
    try {
      final expenseData = {
        'amount': amount,
        'expenseType': 'مرتبات',
        'description': 'مرتب $employeeName ($paymentType) - شهر $month',
        'recipient': employeeName,
        'date': Timestamp.now(),
        'createdAt': Timestamp.now(),
        'category': 'خرج',
        'status': 'مكتمل',
        'paymentType': paymentType, // 'full' أو 'partial'
        'salaryMonth': month,
      };

      await _firestore.collection('treasury_exits').add(expenseData);

      // تحديث رصيد الخزنة
      setState(() {
        _treasuryBalance -= amount;
      });
    } catch (e) {
      print('Error adding expense to treasury: $e');
      throw e;
    }
  }

  // دالة الدفع الجزئي
  Future<void> _makePartialPayment(
    String employeeId,
    String employeeName,
    double netSalary,
    double alreadyPaid,
  ) async {
    final remainingAmount = netSalary - alreadyPaid;
    final paymentController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: x.TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(Icons.payment, color: Colors.blue),
              SizedBox(width: 8),
              Text('دفع جزئي للموظف'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عرض رصيد الخزنة
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
                      color: _treasuryBalance < 1000 ? Colors.red : Colors.blue,
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
                              color: _treasuryBalance < 1000
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
              SizedBox(height: 16),

              Text('الموظف: $employeeName'),
              SizedBox(height: 8),
              Text('الراتب الصافي: ${netSalary.toStringAsFixed(2)} ج'),
              SizedBox(height: 8),
              Text('المدفوع مسبقاً: ${alreadyPaid.toStringAsFixed(2)} ج'),
              SizedBox(height: 8),
              Text('المتبقي: ${remainingAmount.toStringAsFixed(2)} ج'),
              SizedBox(height: 16),
              TextField(
                controller: paymentController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'المبلغ المطلوب دفعه',
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: 'أدخل المبلغ',
                  border: OutlineInputBorder(),
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
              onPressed: () async {
                final amount = double.tryParse(paymentController.text) ?? 0;
                if (amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('يرجى إدخال مبلغ صحيح'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (amount > remainingAmount) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('المبلغ أكبر من المبلغ المتبقي'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (amount > _treasuryBalance) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('المبلغ أكبر من الرصيد المتاح في الخزنة'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // عرض تأكيد الدفع
                final confirmed = await _showPaymentConfirmation(
                  employeeName,
                  amount,
                  'جزئي',
                );

                if (confirmed) {
                  await _savePartialPayment(employeeId, employeeName, amount);
                  Navigator.pop(context);
                }
              },
              child: Text('دفع'),
            ),
          ],
        ),
      ),
    );
  }

  // دالة تأكيد الدفع
  Future<bool> _showPaymentConfirmation(
    String employeeName,
    double amount,
    String paymentType,
  ) async {
    bool confirmed = false;

    await showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: x.TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange),
              SizedBox(width: 8),
              Text('تأكيد الدفع'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('هل أنت متأكد من دفع ${amount.toStringAsFixed(2)} ج'),
              Text('للموظف $employeeName؟'),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'سيتم خصم المبلغ من الخزنة تحت بند "مرتبات"',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text('تأكيد الدفع'),
            ),
          ],
        ),
      ),
    );

    return confirmed;
  }

  // دالة حفظ الدفع الجزئي
  Future<void> _savePartialPayment(
    String employeeId,
    String employeeName,
    double amount,
  ) async {
    try {
      final paymentData = {
        'employeeId': employeeId,
        'employeeName': employeeName,
        'amount': amount,
        'date': DateTime.now().toIso8601String(),
        'month': '$_selectedMonth/$_selectedYear',
        'paymentType': 'partial',
        'remainingAmount': FieldValue.increment(-amount),
        'timestamp': Timestamp.now(),
      };

      // 1. حفظ بيانات الدفع
      await _firestore.collection('salaryPayments').add(paymentData);

      // 2. إضافة المصروف إلى الخزنة
      await _addExpenseToTreasury(
        employeeName: employeeName,
        amount: amount,
        paymentType: 'جزئي',
        month: '$_selectedMonth/$_selectedYear',
      );

      // 3. تحديث المبلغ المدفوع للموظف
      setState(() {
        _employeePaidAmounts[employeeId] =
            (_employeePaidAmounts[employeeId] ?? 0) + amount;
      });

      // 4. إشعار النجاح
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم دفع ${amount.toStringAsFixed(2)} ج لـ $employeeName',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تسجيل الدفع: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // دالة الدفع الكامل
  Future<void> _makeFullPayment(
    String employeeId,
    String employeeName,
    double netSalary,
    double alreadyPaid,
  ) async {
    try {
      final remainingAmount = netSalary - alreadyPaid;
      if (remainingAmount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('الراتب مدفوع بالكامل بالفعل'),
            backgroundColor: Colors.blue,
          ),
        );
        return;
      }

      // التحقق من رصيد الخزنة
      if (remainingAmount > _treasuryBalance) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('المبلغ أكبر من الرصيد المتاح في الخزنة'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // تأكيد الدفع
      final confirmed = await _showPaymentConfirmation(
        employeeName,
        remainingAmount,
        'كامل',
      );

      if (!confirmed) return;

      // 1. حفظ بيانات الدفع الكامل
      final paymentData = {
        'employeeId': employeeId,
        'employeeName': employeeName,
        'amount': remainingAmount,
        'date': DateTime.now().toIso8601String(),
        'month': '$_selectedMonth/$_selectedYear',
        'paymentType': 'full',
        'remainingAmount': 0,
        'timestamp': Timestamp.now(),
      };

      await _firestore.collection('salaryPayments').add(paymentData);

      // 2. إضافة المصروف إلى الخزنة
      await _addExpenseToTreasury(
        employeeName: employeeName,
        amount: remainingAmount,
        paymentType: 'كامل',
        month: '$_selectedMonth/$_selectedYear',
      );

      // 3. تحديث المبلغ المدفوع للموظف
      setState(() {
        _employeePaidAmounts[employeeId] = netSalary;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم دفع الراتب بالكامل لـ $employeeName'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تسجيل الدفع: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: x.TextDirection.rtl,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // بطاقة رصيد الخزنة
            // Card(
            //   elevation: 8,
            //   margin: EdgeInsets.all(16),
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(16),
            //   ),
            //   child: Container(
            //     padding: const EdgeInsets.all(20),
            //     decoration: BoxDecoration(
            //       gradient: LinearGradient(
            //         begin: Alignment.centerRight,
            //         end: Alignment.centerLeft,
            //         colors: [Color(0xFF1B4F72), Color(0xFF3498DB)],
            //       ),
            //       borderRadius: BorderRadius.circular(16),
            //     ),
            //     child: Column(
            //       children: [
            //         // Row(
            //         //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         //   children: [
            //         //     Row(
            //         //       children: [
            //         //         Icon(
            //         //           Icons.account_balance_wallet,
            //         //           color: Colors.white,
            //         //           size: 28,
            //         //         ),
            //         //         SizedBox(width: 12),
            //         //         Text(
            //         //           'رصيد الخزنة الحالي',
            //         //           style: TextStyle(
            //         //             color: Colors.white,
            //         //             fontSize: 18,
            //         //             fontWeight: FontWeight.bold,
            //         //           ),
            //         //         ),
            //         //       ],
            //         //     ),
            //         //     IconButton(
            //         //       onPressed: _loadTreasuryBalance,
            //         //       icon: Icon(Icons.refresh, color: Colors.white),
            //         //       tooltip: 'تحديث الرصيد',
            //         //     ),
            //         //   ],
            //         // ),
            //         // SizedBox(height: 16),
            //         Text(
            //           '${_treasuryBalance.toStringAsFixed(2)} ج',
            //           style: TextStyle(
            //             color: Colors.white,
            //             fontSize: 36,
            //             fontWeight: FontWeight.bold,
            //           ),
            //         ),
            //         SizedBox(height: 12),
            //         if (_treasuryBalance < 1000)
            //           Container(
            //             padding: EdgeInsets.all(8),
            //             decoration: BoxDecoration(
            //               color: Colors.red.withOpacity(0.2),
            //               borderRadius: BorderRadius.circular(8),
            //             ),
            //             child: Row(
            //               mainAxisSize: MainAxisSize.min,
            //               children: [
            //                 Icon(Icons.warning, color: Colors.white, size: 16),
            //                 SizedBox(width: 4),
            //                 Text(
            //                   'الرصيد منخفض',
            //                   style: TextStyle(
            //                     color: Colors.white,
            //                     fontWeight: FontWeight.bold,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //       ],
            //     ),
            //   ),
            // ),
            SizedBox(height: 16),

            // باقي واجهة المرتبات
            Card(
              elevation: 8,
              margin: EdgeInsets.all(8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // SizedBox(height: 16),
                    _buildHeaderSection(),
                    SizedBox(height: 8),
                    _buildMonthFilter(),
                    SizedBox(height: 8),
                    _buildSearchBar(),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            _buildSalariesTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Center(
      child: Text(
        'رواتب الموظفين',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2C3E50),
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _buildMonthFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.calendar_month, color: Color(0xFF3498DB), size: 24),
        SizedBox(width: 10),
        Text(
          'شهر:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 10),
        DropdownButton<int>(
          value: _selectedMonth,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedMonth = value;
              });
              _loadMonthData();
            }
          },
          items: [
            for (int i = 1; i <= 12; i++)
              DropdownMenuItem(
                value: i,
                child: Text('شهر $i', style: TextStyle(fontSize: 16)),
              ),
          ],
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 16,
            fontFamily: 'Cairo',
          ),
        ),
        SizedBox(width: 30),
        Text(
          'سنة:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 10),
        DropdownButton<int>(
          value: _selectedYear,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedYear = value;
              });
              _loadMonthData();
            }
          },
          items: [
            for (
              int i = DateTime.now().year - 2;
              i <= DateTime.now().year + 2;
              i++
            )
              DropdownMenuItem(
                value: i,
                child: Text('$i', style: TextStyle(fontSize: 16)),
              ),
          ],
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 16,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3498DB), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: const Color(0xFF3498DB), size: 28),
          SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              textDirection: x.TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'ابحث عن موظف...',
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontFamily: 'Cairo',
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(fontSize: 16, fontFamily: 'Cairo'),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                _searchEmployees();
              },
              child: Icon(Icons.clear, size: 24, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildSalariesTable() {
    return Card(
      elevation: 8,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore.collection('employees').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('حدث خطأ: ${snapshot.error}'));
            }

            final employees = snapshot.data!.docs;
            final searchText = _searchController.text.toLowerCase();

            final filteredEmployees = employees.where((employee) {
              if (searchText.isEmpty) return true;
              final data = employee.data() as Map<String, dynamic>;
              final name = data['name']?.toString().toLowerCase() ?? '';
              return name.contains(searchText);
            }).toList();

            if (filteredEmployees.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 80, color: Colors.grey),
                    SizedBox(height: 20),
                    Text(
                      searchText.isEmpty
                          ? 'لا يوجد موظفين مسجلين'
                          : 'لم يتم العثور على موظفين',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              );
            }

            // حساب الإحصائيات
            double totalSalaries = 0;
            double totalPenalties = 0;
            double totalNet = 0;
            double totalPaid = 0;
            double totalRemaining = 0;

            for (final employee in filteredEmployees) {
              final data = employee.data() as Map<String, dynamic>;
              final salary = (data['salary'] ?? 0).toDouble();
              final penalties = _employeePenalties[employee.id] ?? 0;
              final netSalary = salary - penalties;
              final paidAmount = _employeePaidAmounts[employee.id] ?? 0;

              totalSalaries += salary;
              totalPenalties += penalties;
              totalNet += netSalary;
              totalPaid += paidAmount;
              totalRemaining += (netSalary - paidAmount);
            }

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      Text(
                        'تفاصيل الرواتب - شهر $_selectedMonth/$_selectedYear',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                          fontFamily: 'Cairo',
                        ),
                      ),
                      SizedBox(height: 20),

                      // إحصائيات محدثة
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'إجمالي الرواتب قبل الخصم',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                  Text(
                                    '${totalSalaries.toStringAsFixed(2)} جنية',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'إجمالي الجزاءات:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                  Text(
                                    '${totalPenalties.toStringAsFixed(2)} جنية',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'إجمالي المدفوعات:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                  Text(
                                    '${totalPaid.toStringAsFixed(2)} جنية',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'إجمالي المتبقي:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                  Text(
                                    '${totalRemaining.toStringAsFixed(2)} جنية',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Divider(thickness: 2, color: Color(0xFF3498DB)),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'إجمالي صافي الرواتب:',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                  Text(
                                    '${totalNet.toStringAsFixed(2)} جنية',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF3498DB),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // الجدول
                MediaQuery.of(context).size.width < 600
                    ? _buildMobileTable(filteredEmployees)
                    : _buildDesktopTable(filteredEmployees),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileTable(List<QueryDocumentSnapshot> employees) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final employee = employees[index];
        final data = employee.data() as Map<String, dynamic>;
        final basicSalary = (data['salary'] ?? 0).toDouble();
        final penalties = _employeePenalties[employee.id] ?? 0;
        final netSalary = basicSalary - penalties;
        final paidAmount = _employeePaidAmounts[employee.id] ?? 0;
        final remainingAmount = netSalary - paidAmount;
        final isFullyPaid = remainingAmount <= 0;

        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            '${index + 1}.',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              data['name'] ?? 'غير محدد',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isFullyPaid
                            ? Colors.green[50]
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isFullyPaid ? Colors.green : Colors.orange,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isFullyPaid ? 'مدفوع بالكامل' : 'مدفوع جزئياً',
                        style: TextStyle(
                          color: isFullyPaid
                              ? Colors.green[800]
                              : Colors.orange[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Divider(),
                SizedBox(height: 12),
                _buildInfoRow('الوظيفة:', data['job'] ?? 'غير محدد'),
                SizedBox(height: 8),
                _buildInfoRow(
                  'الراتب:',
                  '$basicSalary جنية',
                  valueColor: Colors.green,
                ),
                SizedBox(height: 8),
                _buildInfoRow(
                  'الجزاءات:',
                  '$penalties جنية',
                  valueColor: Colors.red,
                ),
                SizedBox(height: 8),
                _buildInfoRow(
                  'المدفوع:',
                  '${paidAmount.toStringAsFixed(2)} جنية',
                  valueColor: Colors.blue,
                ),
                SizedBox(height: 8),
                _buildInfoRow(
                  'المتبقي:',
                  '${remainingAmount.toStringAsFixed(2)} جنية',
                  valueColor: Colors.orange,
                ),
                SizedBox(height: 12),
                Divider(),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الصافي:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3498DB),
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      '${netSalary.toStringAsFixed(2)} جنية',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3498DB),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                if (!isFullyPaid)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _makePartialPayment(
                            employee.id,
                            data['name'] ?? '',
                            netSalary,
                            paidAmount,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF3498DB),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: Icon(Icons.payment),
                          label: Text(
                            'دفع جزئي',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _makeFullPayment(
                            employee.id,
                            data['name'] ?? '',
                            netSalary,
                            paidAmount,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1B4F72),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: Icon(Icons.check_circle),
                          label: Text(
                            'دفع كامل',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
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
      },
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 15,
            fontFamily: 'Cairo',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopTable(List<QueryDocumentSnapshot> employees) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.transparent, width: 1.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DataTable(
          border: TableBorder.all(
            color: Colors.blueAccent,
            width: 1,
            borderRadius: BorderRadius.circular(10),
          ),
          columnSpacing: 55,
          horizontalMargin: 16,
          headingRowHeight: 55,
          dataRowHeight: 60,
          headingRowColor: WidgetStateProperty.all(const Color(0xFFEAF2FB)),
          headingTextStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B4F72),
            fontFamily: 'Cairo',
          ),
          columns: const [
            DataColumn(label: Center(child: Text('ر.ق'))),
            DataColumn(label: Center(child: Text('اسم الموظف'))),
            DataColumn(label: Center(child: Text('الوظيفة'))),
            DataColumn(label: Center(child: Text('الراتب'))),
            DataColumn(label: Center(child: Text('الجزاءات'))),
            DataColumn(label: Center(child: Text('الصافي'))),
            DataColumn(label: Center(child: Text('المدفوع'))),
            DataColumn(label: Center(child: Text('المتبقي'))),
            DataColumn(label: Center(child: Text('الحالة'))),
            DataColumn(label: Center(child: Text('الإجراءات'))),
          ],
          rows: employees.asMap().entries.map((entry) {
            final index = entry.key;
            final employee = entry.value;
            final data = employee.data() as Map<String, dynamic>;

            final basicSalary = (data['salary'] ?? 0).toDouble();
            final penalties = _employeePenalties[employee.id] ?? 0;
            final netSalary = basicSalary - penalties;
            final paidAmount = _employeePaidAmounts[employee.id] ?? 0;
            final remainingAmount = netSalary - paidAmount;
            final isFullyPaid = remainingAmount <= 0;
            final paymentPercentage = netSalary > 0
                ? (paidAmount / netSalary * 100)
                : 0;

            return DataRow(
              color: WidgetStateProperty.all(
                index.isEven ? Colors.white : const Color(0xFFF8FBFF),
              ),
              cells: [
                _buildGridCell('${index + 1}', bold: true),
                _buildGridCell(data['name'] ?? 'غير محدد'),
                _buildGridCell(data['position'] ?? 'غير محدد'),
                _buildGridCell(
                  '${basicSalary.toStringAsFixed(2)} ج',
                  color: Colors.green,
                  bold: true,
                ),
                _buildGridCell(
                  '${penalties.toStringAsFixed(2)} ج',
                  color: Colors.red,
                  bold: true,
                ),
                _buildGridCell(
                  '${netSalary.toStringAsFixed(2)} ج',
                  color: const Color(0xFF3498DB),
                  bold: true,
                ),
                _buildGridCell(
                  '${paidAmount.toStringAsFixed(2)} ج',
                  color: Colors.blue,
                  bold: true,
                ),
                _buildGridCell(
                  '${remainingAmount.toStringAsFixed(2)} ج',
                  color: Colors.orange,
                  bold: true,
                ),
                DataCell(
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isFullyPaid
                                ? Colors.green[50]
                                : Colors.orange[50],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isFullyPaid ? Colors.green : Colors.orange,
                            ),
                          ),
                          child: Text(
                            isFullyPaid ? 'مدفوع بالكامل' : 'مدفوع جزئياً',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isFullyPaid
                                  ? Colors.green[800]
                                  : Colors.orange[800],
                            ),
                          ),
                        ),
                        if (!isFullyPaid)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '${paymentPercentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                DataCell(
                  Center(
                    child: isFullyPaid
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () => _makePartialPayment(
                                  employee.id,
                                  data['name'] ?? '',
                                  netSalary,
                                  paidAmount,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3498DB),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: const Text(
                                  'دفع جزئي',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _makeFullPayment(
                                  employee.id,
                                  data['name'] ?? '',
                                  netSalary,
                                  paidAmount,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1B4F72),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: const Text(
                                  'دفع كامل',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  DataCell _buildGridCell(String text, {Color? color, bool bold = false}) {
    return DataCell(
      Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: color ?? const Color(0xFF2C3E50),
          ),
        ),
      ),
    );
  }
}
