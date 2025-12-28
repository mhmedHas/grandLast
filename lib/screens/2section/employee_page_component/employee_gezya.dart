import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PenaltyPage extends StatefulWidget {
  const PenaltyPage({super.key});

  @override
  State<PenaltyPage> createState() => _PenaltyPageState();
}

class _PenaltyPageState extends State<PenaltyPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  String? _selectedEmployeeId;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _filteredEmployees = [];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _reasonController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployees() async {
    try {
      final employeesQuery = await _firestore.collection('employees').get();

      List<Map<String, dynamic>> tempEmployees = [];

      for (final doc in employeesQuery.docs) {
        final data = doc.data();

        // جلب الجزاءات الخاصة بهذا الموظف
        final penaltiesQuery = await _firestore
            .collection('penalties')
            .where('employeeId', isEqualTo: doc.id)
            .get();

        final hasPenalty = penaltiesQuery.docs.isNotEmpty;

        final now = DateTime.now();
        final currentMonth = '${now.month}/${now.year}';

        final currentMonthPenalties = penaltiesQuery.docs.where((p) {
          final data = p.data();
          return data['month'] == currentMonth;
        }).toList();

        tempEmployees.add({
          'id': doc.id,
          'name': data['name'] ?? 'غير معروف',
          'job': data['job'] ?? data['position'] ?? 'غير معروف',
          'hasPenalty': hasPenalty,
          'penaltyCount': currentMonthPenalties.length,
          'totalPenalties': currentMonthPenalties.fold(
            0.0,
            (sum, p) => sum + ((p.data())['amount'] ?? 0).toDouble(),
          ),
          'allPenalties': penaltiesQuery.docs.map((penalty) {
            final penaltyData = penalty.data();
            return {
              'date': penaltyData['date'] ?? DateTime.now().toIso8601String(),
              'amount': penaltyData['amount'] ?? 0,
            };
          }).toList(),
        });
      }

      setState(() {
        _employees = tempEmployees;
        _filteredEmployees = List.from(_employees);
      });
    } catch (e) {
      print('Error loading employees: $e');
    }
  }

  double _calculateTotalPenalties(List<QueryDocumentSnapshot> penalties) {
    double total = 0;
    for (final penalty in penalties) {
      final data = penalty.data() as Map<String, dynamic>;
      total += (data['amount'] ?? 0).toDouble();
    }
    return total;
  }

  void _filterEmployees() {
    final searchText = _searchController.text.toLowerCase().trim();

    List<Map<String, dynamic>> filtered = List.from(_employees);

    if (searchText.isNotEmpty) {
      filtered = filtered.where((employee) {
        final name = employee['name']?.toString().toLowerCase() ?? '';
        final job = employee['job']?.toString().toLowerCase() ?? '';
        return name.contains(searchText) || job.contains(searchText);
      }).toList();
    }

    if (_selectedStartDate != null || _selectedEndDate != null) {
      filtered = filtered.where((employee) {
        final List<dynamic> penalties = employee['allPenalties'] ?? [];

        if (penalties.isEmpty) return false;

        for (final penalty in penalties) {
          try {
            final penaltyDateStr = penalty['date']?.toString() ?? '';
            if (penaltyDateStr.isEmpty) continue;

            final penaltyDate = DateTime.parse(penaltyDateStr);

            bool withinDateRange = true;

            if (_selectedStartDate != null) {
              final startDate = DateTime(
                _selectedStartDate!.year,
                _selectedStartDate!.month,
                _selectedStartDate!.day,
                0,
                0,
                0,
              );
              withinDateRange =
                  penaltyDate.isAfter(startDate) ||
                  penaltyDate.isAtSameMomentAs(startDate);
            }

            if (_selectedEndDate != null) {
              final endDate = DateTime(
                _selectedEndDate!.year,
                _selectedEndDate!.month,
                _selectedEndDate!.day,
                23,
                59,
                59,
              );
              withinDateRange =
                  withinDateRange && penaltyDate.isBefore(endDate);
            }

            if (withinDateRange) return true;
          } catch (e) {
            print('Error parsing date: $e');
            continue;
          }
        }

        return false;
      }).toList();
    }

    setState(() {
      _filteredEmployees = filtered;
    });
  }

  Future<void> _addPenalty() async {
    if (_formKey.currentState!.validate() && _selectedEmployeeId != null) {
      try {
        final employeeDoc = await _firestore
            .collection('employees')
            .doc(_selectedEmployeeId)
            .get();

        if (!employeeDoc.exists) {
          throw Exception('الموظف غير موجود');
        }

        final employeeData = employeeDoc.data() as Map<String, dynamic>;

        final newPenalty = {
          'employeeId': _selectedEmployeeId,
          'employeeName': employeeData['name'] ?? 'غير معروف',
          'employeeJob':
              employeeData['job'] ?? employeeData['position'] ?? 'غير معروف',
          'amount': double.tryParse(_amountController.text) ?? 0.0,
          'reason': _reasonController.text.trim(),
          'date': DateTime.now().toIso8601String(),
          'month': '${DateTime.now().month}/${DateTime.now().year}',
          'createdAt': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('penalties').add(newPenalty);

        await _loadEmployees();

        _formKey.currentState!.reset();
        setState(() {
          _selectedEmployeeId = null;
        });
        _amountController.clear();
        _reasonController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إضافة الجزاء بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في إضافة الجزاء: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openEmployeePenaltiesPage(Map<String, dynamic> employee) {
    print(
      'Opening penalties page for employee: ${employee['name']} - ID: ${employee['id']}',
    );
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => EmployeePenaltiesPage(
              employeeId: employee['id'],
              employeeName: employee['name'],
              employeeJob: employee['job'],
              firestore: _firestore,
            ),
          ),
        )
        .then((_) {
          _loadEmployees();
        });
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: Color(0xFF1B4F72)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
        } else {
          _selectedEndDate = picked;
        }
      });
      _filterEmployees();
    }
  }

  void _clearDateFilter() {
    setState(() {
      _selectedStartDate = null;
      _selectedEndDate = null;
    });
    _filterEmployees();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الجزاءات',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4F72),
                fontFamily: 'Cairo',
              ),
            ),
            SizedBox(height: 10),
            Text(
              'إدارة جزاءات وخصومات الموظفين',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontFamily: 'Cairo',
              ),
            ),
            SizedBox(height: 30),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'إضافة جزاء جديد',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                          fontFamily: 'Cairo',
                        ),
                      ),
                      SizedBox(height: 20),

                      StreamBuilder<QuerySnapshot>(
                        stream: _firestore.collection('employees').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'اختر الموظف',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              items: [],
                              onChanged: null,
                            );
                          }

                          final employees = snapshot.data!.docs;

                          return DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'اختر الموظف',
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.blue,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            initialValue: _selectedEmployeeId,
                            items: employees.map((employee) {
                              final data =
                                  employee.data() as Map<String, dynamic>;
                              return DropdownMenuItem<String>(
                                value: employee.id,
                                child: Text(
                                  '${data['name']} - ${data['job'] ?? data['position']}',
                                  style: TextStyle(fontFamily: 'Cairo'),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedEmployeeId = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'يرجى اختيار الموظف';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      SizedBox(height: 20),

                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'مبلغ الجزاء',
                          prefixIcon: Icon(Icons.money_off, color: Colors.red),
                          suffixText: 'جنية',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال المبلغ';
                          }
                          if (double.tryParse(value) == null) {
                            return 'يرجى إدخال رقم صحيح';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      TextFormField(
                        controller: _reasonController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'سبب الجزاء',
                          prefixIcon: Icon(
                            Icons.description,
                            color: Colors.blue,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'يرجى إدخال سبب الجزاء';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _addPenalty,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF1B4F72),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle),
                              SizedBox(width: 10),
                              Text(
                                'إضافة الجزاء',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),

            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'قائمة الموظفين',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                            fontFamily: 'Cairo',
                          ),
                        ),
                        SizedBox(width: 80),

                        Expanded(
                          child: Container(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) => _filterEmployees(),
                              decoration: InputDecoration(
                                hintText: 'ابحث عن موظف بالاسم أو الوظيفة...',
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: Colors.blue,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Card(
                    //   elevation: 2,
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(12.0),
                    //     child: Column(
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Row(
                    //           children: [
                    //             Icon(
                    //               Icons.filter_alt,
                    //               color: Color(0xFF1B4F72),
                    //             ),
                    //             SizedBox(width: 8),
                    //             Text(
                    //               'فلتر حسب تاريخ الجزاء:',
                    //               style: TextStyle(
                    //                 fontWeight: FontWeight.bold,
                    //                 fontSize: 16,
                    //                 fontFamily: 'Cairo',
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //         SizedBox(height: 10),
                    //         Row(
                    //           children: [
                    //             Expanded(
                    //               child: Column(
                    //                 crossAxisAlignment:
                    //                     CrossAxisAlignment.start,
                    //                 children: [
                    //                   Text(
                    //                     'من تاريخ:',
                    //                     style: TextStyle(fontFamily: 'Cairo'),
                    //                   ),
                    //                   SizedBox(height: 5),
                    //                   InkWell(
                    //                     onTap: () => _selectDate(context, true),
                    //                     child: Container(
                    //                       padding: EdgeInsets.all(12),
                    //                       decoration: BoxDecoration(
                    //                         border: Border.all(
                    //                           color: Colors.grey,
                    //                         ),
                    //                         borderRadius: BorderRadius.circular(
                    //                           8,
                    //                         ),
                    //                         color: Colors.white,
                    //                       ),
                    //                       child: Row(
                    //                         children: [
                    //                           Icon(
                    //                             Icons.calendar_today,
                    //                             size: 20,
                    //                             color: Colors.blue,
                    //                           ),
                    //                           SizedBox(width: 10),
                    //                           Text(
                    //                             _selectedStartDate != null
                    //                                 ? '${_selectedStartDate!.day}/${_selectedStartDate!.month}/${_selectedStartDate!.year}'
                    //                                 : 'اختر تاريخ البداية',
                    //                             style: TextStyle(
                    //                               fontFamily: 'Cairo',
                    //                             ),
                    //                           ),
                    //                         ],
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //             SizedBox(width: 10),
                    //             Expanded(
                    //               child: Column(
                    //                 crossAxisAlignment:
                    //                     CrossAxisAlignment.start,
                    //                 children: [
                    //                   Text(
                    //                     'إلى تاريخ:',
                    //                     style: TextStyle(fontFamily: 'Cairo'),
                    //                   ),
                    //                   SizedBox(height: 5),
                    //                   InkWell(
                    //                     onTap: () =>
                    //                         _selectDate(context, false),
                    //                     child: Container(
                    //                       padding: EdgeInsets.all(12),
                    //                       decoration: BoxDecoration(
                    //                         border: Border.all(
                    //                           color: Colors.grey,
                    //                         ),
                    //                         borderRadius: BorderRadius.circular(
                    //                           8,
                    //                         ),
                    //                         color: Colors.white,
                    //                       ),
                    //                       child: Row(
                    //                         children: [
                    //                           Icon(
                    //                             Icons.calendar_today,
                    //                             size: 20,
                    //                             color: Colors.blue,
                    //                           ),
                    //                           SizedBox(width: 10),
                    //                           Text(
                    //                             _selectedEndDate != null
                    //                                 ? '${_selectedEndDate!.day}/${_selectedEndDate!.month}/${_selectedEndDate!.year}'
                    //                                 : 'اختر تاريخ النهاية',
                    //                             style: TextStyle(
                    //                               fontFamily: 'Cairo',
                    //                             ),
                    //                           ),
                    //                         ],
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //             SizedBox(width: 10),
                    //             Column(
                    //               children: [
                    //                 SizedBox(height: 20),
                    //                 Tooltip(
                    //                   message: 'مسح الفلتر',
                    //                   child: IconButton(
                    //                     onPressed: _clearDateFilter,
                    //                     icon: Icon(
                    //                       Icons.clear,
                    //                       color: Colors.red,
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ],
                    //         ),
                    //         SizedBox(height: 10),
                    //         if (_selectedStartDate != null ||
                    //             _selectedEndDate != null)
                    //           Container(
                    //             padding: EdgeInsets.all(8),
                    //             decoration: BoxDecoration(
                    //               color: Colors.blue[50],
                    //               borderRadius: BorderRadius.circular(8),
                    //             ),
                    //             child: Row(
                    //               children: [
                    //                 Icon(
                    //                   Icons.info,
                    //                   color: Colors.blue,
                    //                   size: 16,
                    //                 ),
                    //                 SizedBox(width: 8),
                    //                 Expanded(
                    //                   child: Text(
                    //                     'عرض الموظفين الذين لديهم جزاءات في هذا النطاق الزمني',
                    //                     style: TextStyle(
                    //                       fontSize: 12,
                    //                       color: Colors.blue[800],
                    //                       fontFamily: 'Cairo',
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    // SizedBox(height: 20),
                    if (_filteredEmployees.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'عدد النتائج: ${_filteredEmployees.length}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    SizedBox(height: 20),

                    if (_filteredEmployees.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 20),
                            Text(
                              _searchController.text.isNotEmpty ||
                                      _selectedStartDate != null ||
                                      _selectedEndDate != null
                                  ? 'لا توجد نتائج مطابقة للبحث'
                                  : 'لا يوجد موظفين',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            if (_searchController.text.isNotEmpty ||
                                _selectedStartDate != null ||
                                _selectedEndDate != null)
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  _clearDateFilter();
                                },
                                child: Text(
                                  'مسح البحث والفلتر',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _filteredEmployees.length,
                        itemBuilder: (context, index) {
                          final employee = _filteredEmployees[index];
                          final hasPenalty = employee['hasPenalty'] == true;
                          final penaltyCount = employee['penaltyCount'] ?? 0;
                          final totalPenalties =
                              employee['totalPenalties'] ?? 0;

                          return Card(
                            margin: EdgeInsets.only(bottom: 10),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              onTap: () => _openEmployeePenaltiesPage(employee),
                              leading: CircleAvatar(
                                backgroundColor: hasPenalty
                                    ? Colors.red[100]
                                    : Colors.green[100],
                                child: Icon(
                                  hasPenalty ? Icons.money_off : Icons.person,
                                  color: hasPenalty ? Colors.red : Colors.green,
                                ),
                              ),
                              title: Text(
                                employee['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    employee['job'],
                                    style: TextStyle(fontFamily: 'Cairo'),
                                  ),
                                  if (hasPenalty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.money_off,
                                          size: 14,
                                          color: Colors.red,
                                        ),
                                        // SizedBox(width: 4),
                                        // Text(
                                        //   'إجمالي الجزاءات: ${totalPenalties.toStringAsFixed(2)} جنية',
                                        //   style: TextStyle(
                                        //     fontSize: 12,
                                        //     color: Colors.red,
                                        //     fontFamily: 'Cairo',
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (hasPenalty)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red[50],
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.red),
                                      ),
                                      child: Text(
                                        '$penaltyCount جزاء',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  SizedBox(width: 10),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class EmployeePenaltiesPage extends StatefulWidget {
//   final String employeeId;
//   final String employeeName;
//   final String employeeJob;
//   final FirebaseFirestore firestore;

//   const EmployeePenaltiesPage({
//     super.key,
//     required this.employeeId,
//     required this.employeeName,
//     required this.employeeJob,
//     required this.firestore,
//   });

//   @override
//   State<EmployeePenaltiesPage> createState() => _EmployeePenaltiesPageState();
// }

// class _EmployeePenaltiesPageState extends State<EmployeePenaltiesPage> {
//   List<Map<String, dynamic>> _penalties = [];
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadPenalties();
//   }

//   Future<void> _loadPenalties() async {
//     try {
//       print('=====================================');
//       print('Loading penalties for employee ID: ${widget.employeeId}');
//       print('Employee Name: ${widget.employeeName}');
//       print('=====================================');

//       // أولاً: تحقق من ID
//       if (widget.employeeId.isEmpty) {
//         print('ERROR: Employee ID is empty!');
//         setState(() {
//           _isLoading = false;
//         });
//         return;
//       }

//       // جلب جميع الجزاءات أولاً لترى البيانات
//       final allPenalties = await widget.firestore.collection('penalties').get();

//       print('Total penalties in database: ${allPenalties.docs.length}');
//       print('First few penalties:');

//       for (int i = 0; i < allPenalties.docs.length && i < 5; i++) {
//         final doc = allPenalties.docs[i];
//         final data = doc.data();
//         print(
//           '  Penalty ${i + 1}: employeeId=${data['employeeId']}, name=${data['employeeName']}, amount=${data['amount']}',
//         );
//       }

//       // الآن جلب جزاءات الموظف المحدد
//       final penaltiesQuery = await widget.firestore
//           .collection('penalties')
//           .where('employeeId', isEqualTo: widget.employeeId)
//           .get();

//       print('Found ${penaltiesQuery.docs.length} penalties for this employee');

//       if (penaltiesQuery.docs.isEmpty) {
//         print('No penalties found! Checking for different ID formats...');

//         // قد يكون هناك مشكلة في تنسيق ID
//         // جرب بحث بدون where
//         final allDocs = await widget.firestore.collection('penalties').get();
//         int count = 0;
//         for (final doc in allDocs.docs) {
//           final data = doc.data();
//           final storedEmployeeId = data['employeeId']?.toString() ?? '';
//           if (storedEmployeeId.contains(widget.employeeId) ||
//               widget.employeeId.contains(storedEmployeeId)) {
//             print(
//               'Found match: storedId=$storedEmployeeId, ourId=${widget.employeeId}',
//             );
//             count++;
//           }
//         }
//         print('Possible matches with partial ID: $count');
//       }

//       List<Map<String, dynamic>> tempPenalties = [];

//       for (final doc in penaltiesQuery.docs) {
//         final data = doc.data();
//         tempPenalties.add({
//           'id': doc.id,
//           'amount': (data['amount'] ?? 0).toDouble(),
//           'reason': data['reason'] ?? 'لا يوجد سبب',
//           'date': data['date'] ?? DateTime.now().toIso8601String(),
//           'month': data['month'] ?? 'غير محدد',
//         });
//       }

//       setState(() {
//         _penalties = tempPenalties;
//         _isLoading = false;
//       });

//       print('Loaded ${_penalties.length} penalties into state');
//     } catch (e) {
//       print('ERROR loading penalties: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _editPenalty(Map<String, dynamic> penalty) async {
//     final amountController = TextEditingController(
//       text: penalty['amount'].toString(),
//     );
//     final reasonController = TextEditingController(text: penalty['reason']);

//     await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('تعديل الجزاء', style: TextStyle(fontFamily: 'Cairo')),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextFormField(
//                   controller: amountController,
//                   keyboardType: TextInputType.number,
//                   decoration: InputDecoration(
//                     labelText: 'مبلغ الجزاء',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 TextFormField(
//                   controller: reasonController,
//                   decoration: InputDecoration(
//                     labelText: 'سبب الجزاء',
//                     border: OutlineInputBorder(),
//                   ),
//                   maxLines: 3,
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 try {
//                   await widget.firestore
//                       .collection('penalties')
//                       .doc(penalty['id'])
//                       .update({
//                         'amount': double.parse(amountController.text),
//                         'reason': reasonController.text.trim(),
//                       });

//                   await _loadPenalties();
//                   Navigator.pop(context);

//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('تم تعديل الجزاء بنجاح'),
//                       backgroundColor: Colors.green,
//                     ),
//                   );
//                 } catch (e) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('خطأ في التعديل: $e'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 }
//               },
//               child: Text('حفظ', style: TextStyle(fontFamily: 'Cairo')),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _deletePenalty(String penaltyId) async {
//     final confirmed = await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('تأكيد الحذف', style: TextStyle(fontFamily: 'Cairo')),
//         content: Text(
//           'هل أنت متأكد من حذف هذا الجزاء؟',
//           style: TextStyle(fontFamily: 'Cairo'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.pop(context, true),
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: Text('حذف', style: TextStyle(fontFamily: 'Cairo')),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       try {
//         await widget.firestore.collection('penalties').doc(penaltyId).delete();
//         await _loadPenalties();

//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('تم حذف الجزاء بنجاح'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('خطأ في الحذف: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('جزاءات الموظف', style: TextStyle(fontFamily: 'Cairo')),
//         backgroundColor: Color(0xFF1B4F72),
//       ),
//       body: _isLoading
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [CircularProgressIndicator()],
//               ),
//             )
//           : SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Card(
//                       elevation: 4,
//                       child: Padding(
//                         padding: const EdgeInsets.all(20.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 CircleAvatar(
//                                   backgroundColor: _penalties.isNotEmpty
//                                       ? Colors.red[100]
//                                       : Colors.green[100],
//                                   child: Icon(
//                                     _penalties.isNotEmpty
//                                         ? Icons.money_off
//                                         : Icons.person,
//                                     color: _penalties.isNotEmpty
//                                         ? Colors.red
//                                         : Colors.green,
//                                   ),
//                                 ),
//                                 SizedBox(width: 20),
//                                 Expanded(
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         widget.employeeName,
//                                         style: TextStyle(
//                                           fontSize: 28,
//                                           fontWeight: FontWeight.bold,
//                                           color: Color(0xFF1B4F72),
//                                           fontFamily: 'Cairo',
//                                         ),
//                                       ),
//                                       SizedBox(height: 5),
//                                       Text(
//                                         widget.employeeJob,
//                                         style: TextStyle(
//                                           fontSize: 18,
//                                           color: Colors.grey[600],
//                                           fontFamily: 'Cairo',
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 20),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   'عدد الجزاءات: ${_penalties.length}',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     fontFamily: 'Cairo',
//                                   ),
//                                 ),
//                                 Text(
//                                   'إجمالي الجزاءات: ${_calculateTotalPenalties()} جنية',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.red,
//                                     fontFamily: 'Cairo',
//                                   ),
//                                 ),
//                               ],
//                             ),

//                             // إضافة معلومات تصحيح الأخطاء
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 30),

//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'تفاصيل الجزاءات',
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF2C3E50),
//                             fontFamily: 'Cairo',
//                           ),
//                         ),
//                         ElevatedButton.icon(
//                           onPressed: () => Navigator.pop(context),
//                           icon: Icon(Icons.arrow_back),
//                           label: Text(
//                             'رجوع',
//                             style: TextStyle(fontFamily: 'Cairo'),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Color(0xFF3498DB),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 20),

//                     if (_penalties.isEmpty)
//                       Center(
//                         child: Column(
//                           children: [
//                             Icon(Icons.money_off, size: 80, color: Colors.grey),
//                             SizedBox(height: 20),
//                             Text(
//                               'لا توجد جزاءات مسجلة لهذا الموظف',
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 color: Colors.grey,
//                                 fontFamily: 'Cairo',
//                               ),
//                             ),
//                             // SizedBox(height: 10),
//                             // Text(
//                             //   'تأكد من أن بيانات الجزاءات مرتبطة بالمعرف الصحيح',
//                             //   style: TextStyle(
//                             //     fontSize: 12,
//                             //     color: Colors.orange,
//                             //     fontFamily: 'Cairo',
//                             //   ),
//                             //   textAlign: TextAlign.center,
//                             // ),
//                             SizedBox(height: 20),
//                             ElevatedButton(
//                               onPressed: _loadPenalties,
//                               child: Text(
//                                 'إعادة تحميل البيانات',
//                                 style: TextStyle(fontFamily: 'Cairo'),
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     else
//                       Column(
//                         children: [
//                           Container(
//                             padding: EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: Colors.green[50],
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.check_circle,
//                                   color: Colors.green,
//                                   size: 16,
//                                 ),
//                                 SizedBox(width: 8),
//                                 Expanded(
//                                   child: Text(
//                                     'تم العثور على ${_penalties.length} جزاء',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.green[800],
//                                       fontFamily: 'Cairo',
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(height: 20),
//                           Directionality(
//                             textDirection: TextDirection.rtl, // ✅ عكس الاتجاه
//                             child: Card(
//                               elevation: 4,
//                               child: Padding(
//                                 padding: const EdgeInsets.all(16.0),
//                                 child: SingleChildScrollView(
//                                   scrollDirection: Axis.horizontal,
//                                   child: SingleChildScrollView(
//                                     scrollDirection: Axis.vertical,
//                                     child: Table(
//                                       defaultColumnWidth:
//                                           const FixedColumnWidth(190),
//                                       border: TableBorder.all(
//                                         color: Colors.grey.shade400,
//                                         width: 1,
//                                       ),
//                                       children: [
//                                         /// ✅ العناوين
//                                         TableRow(
//                                           decoration: BoxDecoration(
//                                             color: Colors.grey.shade200,
//                                           ),
//                                           children: const [
//                                             _PenaltyHeaderCell('ر.ق'),
//                                             _PenaltyHeaderCell('تاريخ الجزاء'),
//                                             _PenaltyHeaderCell('قيمة الجزاء'),
//                                             _PenaltyHeaderCell('سبب الجزاء'),
//                                             // _PenaltyHeaderCell('الشهر'),
//                                             _PenaltyHeaderCell('الإجراءات'),
//                                           ],
//                                         ),

//                                         /// ✅ الصفوف
//                                         ..._penalties.asMap().entries.map((
//                                           entry,
//                                         ) {
//                                           final index = entry.key;
//                                           final penalty = entry.value;

//                                           DateTime date;
//                                           try {
//                                             date = DateTime.parse(
//                                               penalty['date'],
//                                             );
//                                           } catch (e) {
//                                             date = DateTime.now();
//                                           }

//                                           return TableRow(
//                                             children: [
//                                               _PenaltyBodyCell('${index + 1}'),

//                                               _PenaltyBodyCell(
//                                                 '${date.day}/${date.month}/${date.year}',
//                                               ),

//                                               _PenaltyBodyCell(
//                                                 '${penalty['amount'].toStringAsFixed(2)} جنيه',
//                                                 color: Colors.red,
//                                                 bold: true,
//                                               ),

//                                               _PenaltyBodyCell(
//                                                 penalty['reason'],
//                                                 maxWidth: 200,
//                                               ),

//                                               // _PenaltyBodyCell(
//                                               //   penalty['month'],
//                                               // ),

//                                               /// ✅ الإجراءات (أزرار)
//                                               Container(
//                                                 height: 48,
//                                                 alignment: Alignment.center,
//                                                 child: Row(
//                                                   mainAxisAlignment:
//                                                       MainAxisAlignment.center,
//                                                   children: [
//                                                     // IconButton(
//                                                     //   icon: const Icon(
//                                                     //     Icons.edit,
//                                                     //     color: Colors.blue,
//                                                     //   ),
//                                                     //   onPressed: () =>
//                                                     //       _editPenalty(penalty),
//                                                     // ),
//                                                     IconButton(
//                                                       icon: const Icon(
//                                                         Icons.delete,
//                                                         color: Colors.red,
//                                                       ),
//                                                       onPressed: () =>
//                                                           _deletePenalty(
//                                                             penalty['id'],
//                                                           ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           );
//                                         }).toList(),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }

//   String _calculateTotalPenalties() {
//     double total = 0;
//     for (var penalty in _penalties) {
//       total += (penalty['amount'] ?? 0).toDouble();
//     }
//     return total.toStringAsFixed(2);
//   }
// }

// class _PenaltyHeaderCell extends StatelessWidget {
//   final String text;
//   const _PenaltyHeaderCell(this.text);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 52,
//       alignment: Alignment.center,
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontWeight: FontWeight.bold,
//           fontFamily: 'Cairo',
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
// }

// class _PenaltyBodyCell extends StatelessWidget {
//   final String text;
//   final Color? color;
//   final bool bold;
//   final double? maxWidth;

//   const _PenaltyBodyCell(
//     this.text, {
//     this.color,
//     this.bold = false,
//     this.maxWidth,
//   });

//   @override
//   Widget build(BuildContext context) {
//     Widget content = Text(
//       text,
//       maxLines: 1,
//       overflow: TextOverflow.ellipsis,
//       style: TextStyle(
//         color: color ?? Colors.black,
//         fontWeight: bold ? FontWeight.bold : FontWeight.normal,
//       ),
//       textAlign: TextAlign.center,
//     );

//     return Container(
//       height: 48,
//       alignment: Alignment.center,
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       child: maxWidth != null
//           ? SizedBox(width: maxWidth, child: content)
//           : content,
//     );
//   }
// }

class EmployeePenaltiesPage extends StatefulWidget {
  final String employeeId;
  final String employeeName;
  final String employeeJob;
  final FirebaseFirestore firestore;

  const EmployeePenaltiesPage({
    super.key,
    required this.employeeId,
    required this.employeeName,
    required this.employeeJob,
    required this.firestore,
  });

  @override
  State<EmployeePenaltiesPage> createState() => _EmployeePenaltiesPageState();
}

class _EmployeePenaltiesPageState extends State<EmployeePenaltiesPage> {
  List<Map<String, dynamic>> _penalties = [];
  List<Map<String, dynamic>> _filteredPenalties = [];
  bool _isLoading = true;

  String? _selectedMonth;
  List<String> _availableMonths = [];

  @override
  void initState() {
    super.initState();
    _loadPenalties();
  }

  Future<void> _loadPenalties() async {
    try {
      print('=====================================');
      print('Loading penalties for employee ID: ${widget.employeeId}');
      print('Employee Name: ${widget.employeeName}');
      print('=====================================');

      // جلب جميع الجزاءات الخاصة بالموظف
      final penaltiesQuery = await widget.firestore
          .collection('penalties')
          .where('employeeId', isEqualTo: widget.employeeId)
          .get();

      print('Found ${penaltiesQuery.docs.length} penalties for this employee');

      List<Map<String, dynamic>> tempPenalties = [];
      Set<String> monthsSet = {};

      for (final doc in penaltiesQuery.docs) {
        final data = doc.data();
        final month = data['month']?.toString() ?? 'غير محدد';
        final amount = data['amount'];
        final reason = data['reason'];
        final date = data['date'];

        // طباعة البيانات للتأكد
        print(
          'Penalty data: month=$month, amount=$amount, reason=$reason, date=$date',
        );

        tempPenalties.add({
          'id': doc.id,
          'amount': (amount ?? 0).toDouble(),
          'reason': reason?.toString() ?? 'لا يوجد سبب',
          'date': date?.toString() ?? DateTime.now().toIso8601String(),
          'month': month,
        });

        if (month != 'غير محدد' && month.isNotEmpty) {
          monthsSet.add(month);
          print('Added month to set: $month');
        }
      }

      // طباعة الشهور المجمعة
      print('Months set before processing: $monthsSet');

      // تحويل مجموعة الشهور إلى قائمة
      _availableMonths = monthsSet.toList();

      // محاولة ترتيب الشهور إذا كانت بالصيغة الصحيحة
      try {
        _availableMonths.sort((a, b) {
          // محاولة تحليل الشهور بصيغة "شهر/سنة"
          try {
            final partsA = a.split('/');
            final partsB = b.split('/');

            if (partsA.length == 2 && partsB.length == 2) {
              final monthA = int.tryParse(partsA[0]) ?? 0;
              final yearA = int.tryParse(partsA[1]) ?? 0;
              final monthB = int.tryParse(partsB[0]) ?? 0;
              final yearB = int.tryParse(partsB[1]) ?? 0;

              if (yearA != yearB) {
                return yearB.compareTo(yearA); // سنة تنازلي
              } else {
                return monthB.compareTo(monthA); // شهر تنازلي
              }
            }
          } catch (e) {
            print('Error sorting month: $e');
          }
          return b.compareTo(a); // ترتيب أبجدي عكسي
        });
      } catch (e) {
        print('Error in sorting: $e');
        _availableMonths.sort((a, b) => b.compareTo(a));
      }

      // إضافة خيار "الكل" في البداية
      _availableMonths.insert(0, 'الكل');

      print('Available months after sorting: $_availableMonths');

      // تحديد القيمة الافتراضية
      _selectedMonth = _availableMonths.isNotEmpty
          ? _availableMonths[0]
          : 'الكل';

      setState(() {
        _penalties = tempPenalties;
        _filteredPenalties = List.from(_penalties);
        _isLoading = false;
      });

      print('Loaded ${_penalties.length} penalties into state');
      print('Total penalties: ${_penalties.length}');
      print('Filtered penalties: ${_filteredPenalties.length}');
    } catch (e) {
      print('ERROR loading penalties: $e');
      setState(() {
        _isLoading = false;
        _availableMonths = ['الكل'];
        _selectedMonth = 'الكل';
      });
    }
  }

  void _filterByMonth(String? month) {
    print('Filtering by month: $month');
    setState(() {
      _selectedMonth = month;

      if (month == null || month == 'الكل') {
        _filteredPenalties = List.from(_penalties);
      } else {
        _filteredPenalties = _penalties.where((penalty) {
          return penalty['month'] == month;
        }).toList();
      }

      print(
        'After filtering - Total: ${_penalties.length}, Filtered: ${_filteredPenalties.length}',
      );
    });
  }

  Future<void> _editPenalty(Map<String, dynamic> penalty) async {
    final amountController = TextEditingController(
      text: penalty['amount'].toString(),
    );
    final reasonController = TextEditingController(text: penalty['reason']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تعديل الجزاء', style: TextStyle(fontFamily: 'Cairo')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'مبلغ الجزاء',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    labelText: 'سبب الجزاء',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await widget.firestore
                      .collection('penalties')
                      .doc(penalty['id'])
                      .update({
                        'amount': double.parse(amountController.text),
                        'reason': reasonController.text.trim(),
                      });

                  await _loadPenalties();
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تعديل الجزاء بنجاح'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطأ في التعديل: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('حفظ', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePenalty(String penaltyId) async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف', style: TextStyle(fontFamily: 'Cairo')),
        content: Text(
          'هل أنت متأكد من حذف هذا الجزاء؟',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('حذف', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.firestore.collection('penalties').doc(penaltyId).delete();
        await _loadPenalties();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف الجزاء بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الحذف: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('جزاءات الموظف', style: TextStyle(fontFamily: 'Cairo')),
        backgroundColor: Color(0xFF1B4F72),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'جاري تحميل البيانات...',
                    style: TextStyle(fontFamily: 'Cairo'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // معلومات الموظف
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: _penalties.isNotEmpty
                                      ? Colors.red[100]
                                      : Colors.green[100],
                                  child: Icon(
                                    _penalties.isNotEmpty
                                        ? Icons.money_off
                                        : Icons.person,
                                    color: _penalties.isNotEmpty
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                                SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.employeeName,
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1B4F72),
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        widget.employeeJob,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[600],
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),

                            // إحصائيات
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'عدد الجزاءات: ${_filteredPenalties.length}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                Text(
                                  'الإجمالي: ${_calculateTotalPenalties()} جنيه',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // فلتر الشهر
                    Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.filter_alt,
                                  color: Color(0xFF1B4F72),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'فلتر حسب الشهر:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),

                            // عرض Dropdown فقط إذا كان هناك شهور متاحة
                            if (_availableMonths.isNotEmpty)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedMonth,
                                    isExpanded: true,
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: Color(0xFF1B4F72),
                                    ),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontFamily: 'Cairo',
                                    ),
                                    onChanged: _filterByMonth,
                                    items: _availableMonths.map((String month) {
                                      return DropdownMenuItem<String>(
                                        value: month,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                          ),
                                          child: Text(
                                            month,
                                            style: TextStyle(
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'لا توجد شهور متاحة للتصفية',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),

                            SizedBox(height: 8),
                            if (_selectedMonth != null &&
                                _selectedMonth != 'الكل')
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info,
                                      color: Colors.blue,
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'عرض جزاءات شهر $_selectedMonth فقط',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue[800],
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // عنوان الجدول
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'تفاصيل الجزاءات',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                            fontFamily: 'Cairo',
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back),
                          label: Text(
                            'رجوع',
                            style: TextStyle(fontFamily: 'Cairo'),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF3498DB),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // الجدول
                    if (_filteredPenalties.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.money_off, size: 80, color: Colors.grey),
                            SizedBox(height: 20),
                            Text(
                              _selectedMonth == 'الكل' || _selectedMonth == null
                                  ? 'لا توجد جزاءات مسجلة لهذا الموظف'
                                  : 'لا توجد جزاءات مسجلة لهذا الموظف في شهر $_selectedMonth',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                                fontFamily: 'Cairo',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _loadPenalties,
                              child: Text(
                                'إعادة تحميل البيانات',
                                style: TextStyle(fontFamily: 'Cairo'),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedMonth == 'الكل' ||
                                            _selectedMonth == null
                                        ? 'تم العثور على ${_filteredPenalties.length} جزاء'
                                        : 'تم العثور على ${_filteredPenalties.length} جزاء لشهر $_selectedMonth',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.green[800],
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Card(
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Table(
                                      defaultColumnWidth: FixedColumnWidth(150),
                                      border: TableBorder.all(
                                        color: Colors.grey.shade400,
                                        width: 1,
                                      ),
                                      children: [
                                        // العناوين
                                        TableRow(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                          ),
                                          children: const [
                                            _PenaltyHeaderCell('ر.ق'),
                                            _PenaltyHeaderCell('تاريخ الجزاء'),
                                            _PenaltyHeaderCell('قيمة الجزاء'),
                                            _PenaltyHeaderCell('سبب الجزاء'),
                                            _PenaltyHeaderCell('الشهر'),
                                            _PenaltyHeaderCell('الإجراءات'),
                                          ],
                                        ),

                                        // الصفوف
                                        ..._filteredPenalties.asMap().entries.map((
                                          entry,
                                        ) {
                                          final index = entry.key;
                                          final penalty = entry.value;

                                          DateTime date;
                                          try {
                                            date = DateTime.parse(
                                              penalty['date'],
                                            );
                                          } catch (e) {
                                            print(
                                              'Error parsing date: ${penalty['date']} - $e',
                                            );
                                            date = DateTime.now();
                                          }

                                          return TableRow(
                                            children: [
                                              _PenaltyBodyCell('${index + 1}'),

                                              _PenaltyBodyCell(
                                                '${date.day}/${date.month}/${date.year}',
                                              ),

                                              _PenaltyBodyCell(
                                                '${penalty['amount'].toStringAsFixed(2)} جنيه',
                                                color: Colors.red,
                                                bold: true,
                                              ),

                                              _PenaltyBodyCell(
                                                penalty['reason'],
                                                maxWidth: 180,
                                              ),

                                              _PenaltyBodyCell(
                                                penalty['month'],
                                              ),

                                              // الإجراءات
                                              Container(
                                                height: 48,
                                                alignment: Alignment.center,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        color: Colors.blue,
                                                      ),
                                                      onPressed: () =>
                                                          _editPenalty(penalty),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                      onPressed: () =>
                                                          _deletePenalty(
                                                            penalty['id'],
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  String _calculateTotalPenalties() {
    double total = 0;
    for (var penalty in _filteredPenalties) {
      total += (penalty['amount'] ?? 0).toDouble();
    }
    return total.toStringAsFixed(2);
  }
}

class _PenaltyHeaderCell extends StatelessWidget {
  final String text;
  const _PenaltyHeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _PenaltyBodyCell extends StatelessWidget {
  final String text;
  final Color? color;
  final bool bold;
  final double? maxWidth;

  const _PenaltyBodyCell(
    this.text, {
    this.color,
    this.bold = false,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: color ?? Colors.black,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontFamily: 'Cairo',
        fontSize: 14,
      ),
      textAlign: TextAlign.center,
    );

    return Container(
      height: 60,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: maxWidth != null
          ? SizedBox(width: maxWidth, child: content)
          : content,
    );
  }
}
