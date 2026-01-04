// // import 'dart:async';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:last/models/models.dart';

// // class DailyWorkPage extends StatefulWidget {
// //   const DailyWorkPage({super.key});

// //   @override
// //   State<DailyWorkPage> createState() => _DailyWorkPageState();
// // }

// // class _DailyWorkPageState extends State<DailyWorkPage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   final _formKey = GlobalKey<FormState>();

// //   // 1. بيانات الشركة
// //   List<QueryDocumentSnapshot<Map<String, dynamic>>> _companies = [];
// //   String? _selectedCompanyId;
// //   String? _selectedCompanyName;

// //   // 2. التاريخ
// //   DateTime _selectedDate = DateTime.now();

// //   // الحقول الجديدة
// //   final TextEditingController _contractorController = TextEditingController();
// //   final TextEditingController _trController = TextEditingController();

// //   // 3-8. الحقول اليدوية
// //   final TextEditingController _driverNameController = TextEditingController();
// //   final TextEditingController _loadingLocationController =
// //       TextEditingController();
// //   final TextEditingController _unloadingLocationController =
// //       TextEditingController();
// //   final TextEditingController _ohdaController = TextEditingController();
// //   final TextEditingController _kartaController = TextEditingController();

// //   // حالة التحميل والحفظ
// //   bool _isLoading = true;
// //   bool _isSaving = false;

// //   // 9-13. عروض الأسعار
// //   List<Map<String, dynamic>> _priceOffers = [];
// //   Map<String, dynamic>? _selectedPriceOffer;
// //   bool _isDropdownOpen = false;

// //   // اقتراحات أسماء السائقين
// //   List<String> _driverSuggestions = [];
// //   bool _isLoadingSuggestions = false;
// //   Timer? _debounce;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadCompanies();
// //   }

// //   Future<void> _loadCompanies() async {
// //     try {
// //       final snapshot = await _firestore.collection('companies').get();
// //       setState(() {
// //         _companies = snapshot.docs;
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() => _isLoading = false);
// //       _showError('خطأ في تحميل الشركات: $e');
// //     }
// //   }

// //   Future<void> _loadPriceOffers(String companyId) async {
// //     if (companyId.isEmpty) return;

// //     try {
// //       final snapshot = await _firestore
// //           .collection('companies')
// //           .doc(companyId)
// //           .collection('priceOffers')
// //           .get();

// //       List<Map<String, dynamic>> allTransportations = [];

// //       for (final offerDoc in snapshot.docs) {
// //         final offerData = offerDoc.data();
// //         final transportations = offerData['transportations'] as List? ?? [];

// //         for (final transport in transportations) {
// //           final transportMap = transport as Map<String, dynamic>;

// //           // تصحيح أسماء الحقول هنا
// //           allTransportations.add({
// //             'offerId': offerDoc.id,
// //             'loadingLocation': transportMap['loadingLocation'] ?? '',
// //             'unloadingLocation': transportMap['unloadingLocation'] ?? '',
// //             'vehicleType': transportMap['vehicleType'] ?? '',
// //             // التعامل مع الأسماء المختلفة (noLon أو nolon)
// //             'nolon': (transportMap['nolon'] ?? transportMap['noLon'] ?? 0.0)
// //                 .toDouble(),
// //             'wheelNolon':
// //                 (transportMap['wheelNolon'] ??
// //                         transportMap['wheelNoLon'] ??
// //                         0.0)
// //                     .toDouble(),
// //             'companyOvernight': (transportMap['companyOvernight'] ?? 0.0)
// //                 .toDouble(),
// //             'companyHoliday': (transportMap['companyHoliday'] ?? 0.0)
// //                 .toDouble(),
// //             'wheelOvernight': (transportMap['wheelOvernight'] ?? 0.0)
// //                 .toDouble(),
// //             'wheelHoliday': (transportMap['wheelHoliday'] ?? 0.0).toDouble(),
// //             'notes': transportMap['notes'] ?? '',
// //           });
// //         }
// //       }

// //       setState(() {
// //         _priceOffers = allTransportations;
// //       });
// //     } catch (e) {
// //       print('خطأ في تحميل عروض الأسعار: $e');
// //     }
// //   }

// //   Future<List<String>> _fetchDriverSuggestions(String query) async {
// //     if (query.isEmpty) return [];

// //     try {
// //       // البحث في السجلات السابقة
// //       final snapshot = await _firestore
// //           .collection('dailyWork')
// //           .where('driverName', isGreaterThanOrEqualTo: query)
// //           .where('driverName', isLessThan: query + 'z')
// //           .orderBy('driverName')
// //           .limit(10)
// //           .get();

// //       // استخراج الأسماء الفريدة
// //       final names = snapshot.docs
// //           .map((doc) => doc.data()['driverName'] as String? ?? '')
// //           .where((name) => name.toLowerCase().contains(query.toLowerCase()))
// //           .toSet()
// //           .toList();

// //       return names;
// //     } catch (e) {
// //       print('خطأ في جلب اقتراحات السائقين: $e');
// //       return [];
// //     }
// //   }

// //   void _onDriverNameChanged(String value) {
// //     if (_debounce?.isActive ?? false) _debounce?.cancel();

// //     _debounce = Timer(const Duration(milliseconds: 300), () async {
// //       if (value.isNotEmpty && value.length >= 2) {
// //         setState(() => _isLoadingSuggestions = true);
// //         final suggestions = await _fetchDriverSuggestions(value);
// //         setState(() {
// //           _driverSuggestions = suggestions;
// //           _isLoadingSuggestions = false;
// //         });
// //       } else {
// //         setState(() => _driverSuggestions.clear());
// //       }
// //     });
// //   }

// //   void _showError(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text(message), backgroundColor: Colors.red),
// //     );
// //   }

// //   void _showSuccess(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text(message), backgroundColor: Colors.green),
// //     );
// //   }

// //   Future<void> _selectDate(BuildContext context) async {
// //     final DateTime? picked = await showDatePicker(
// //       context: context,
// //       initialDate: _selectedDate,
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime(2030),
// //     );
// //     if (picked != null && picked != _selectedDate) {
// //       setState(() {
// //         _selectedDate = picked;
// //       });
// //     }
// //   }

// //   void _selectPriceOffer(Map<String, dynamic> offer) {
// //     setState(() {
// //       _selectedPriceOffer = offer;
// //       _isDropdownOpen = false;
// //     });
// //   }

// //   Future<void> _saveDailyWork() async {
// //     if (_selectedCompanyId == null) {
// //       _showError('يرجى اختيار شركة');
// //       return;
// //     }

// //     if (_selectedPriceOffer == null) {
// //       _showError('يرجى اختيار موقع من عروض الأسعار');
// //       return;
// //     }

// //     if (!_formKey.currentState!.validate()) return;

// //     setState(() => _isSaving = true);

// //     try {
// //       // استخراج جميع البيانات من عروض الأسعار
// //       final wheelOvernight = _selectedPriceOffer!['wheelOvernight'] ?? 0.0;
// //       final wheelHoliday = _selectedPriceOffer!['wheelHoliday'] ?? 0.0;
// //       final companyOvernight = _selectedPriceOffer!['companyOvernight'] ?? 0.0;
// //       final companyHoliday = _selectedPriceOffer!['companyHoliday'] ?? 0.0;

// //       // 1. حفظ في collection "dailyWork"
// //       final dailyWork = DailyWork(
// //         companyId: _selectedCompanyId!,
// //         companyName: _selectedCompanyName!,
// //         date: _selectedDate,
// //         contractor: _contractorController.text.trim(), // إضافة
// //         tr: _trController.text.trim(), // إضافة
// //         driverName: _driverNameController.text.trim(),
// //         loadingLocation: _loadingLocationController.text.trim(),
// //         unloadingLocation: _unloadingLocationController.text.trim(),
// //         ohda: _ohdaController.text.trim(),
// //         karta: _kartaController.text.trim(),
// //         selectedRoute: '${_selectedPriceOffer!['unloadingLocation']}',
// //         selectedPrice: _selectedPriceOffer!['nolon'] ?? 0.0,
// //         wheelNolon: _selectedPriceOffer!['wheelNolon'] ?? 0.0,
// //         selectedVehicleType: _selectedPriceOffer!['vehicleType'] ?? '',
// //         selectedNotes: _selectedPriceOffer!['notes'] ?? '',
// //         priceOfferId: _selectedPriceOffer!['offerId'] ?? '',
// //         // إضافة البيانات الجديدة
// //         wheelOvernight: 0,
// //         wheelHoliday: 0,
// //         companyOvernight: 0, // إضافة مبيت الشركة
// //         companyHoliday: 0, // إضافة عطلة الشركة
// //         nolon: _selectedPriceOffer!['nolon'] ?? 0.0, // إضافة نولون الشركة
// //         createdAt: DateTime.now(),
// //         updatedAt: DateTime.now(),
// //       );

// //       final dailyWorkRef = await _firestore
// //           .collection('dailyWork')
// //           .add(dailyWork.toMap());

// //       // 2. حفظ في collection "السائقين" مع نسخة كاملة من البيانات
// //       final driverWorkData = {
// //         'dailyWorkId': dailyWorkRef.id, // ربط بالسجل الأصلي
// //         'companyId': _selectedCompanyId!,
// //         'companyName': _selectedCompanyName!,
// //         'date': _selectedDate,
// //         'contractor': _contractorController.text.trim(), // إضافة
// //         'tr': _trController.text.trim(), // إضافة
// //         'driverName': _driverNameController.text.trim(),
// //         'loadingLocation': _loadingLocationController.text.trim(),
// //         'unloadingLocation': _unloadingLocationController.text.trim(),
// //         'ohda': _ohdaController.text.trim(),
// //         'karta': _kartaController.text.trim(),
// //         'selectedRoute': '${_selectedPriceOffer!['unloadingLocation']}',
// //         'selectedPrice': _selectedPriceOffer!['nolon'] ?? 0.0,
// //         'wheelNolon': _selectedPriceOffer!['wheelNolon'] ?? 0.0,
// //         'selectedVehicleType': _selectedPriceOffer!['vehicleType'] ?? '',
// //         'selectedNotes': _selectedPriceOffer!['notes'] ?? '',
// //         'priceOfferId': _selectedPriceOffer!['offerId'] ?? '',

// //         // البيانات الجديدة
// //         'wheelOvernight': 0,
// //         'wheelHoliday': 0,
// //         'companyOvernight': 0, // إضافة مبيت الشركة
// //         'companyHoliday': 0, // إضافة عطلة الشركة
// //         'nolon': _selectedPriceOffer!['nolon'] ?? 0.0, // إضافة نولون الشركة
// //         // حقول إضافية خاصة بالسائقين
// //         'isPaid': false, // حالة الدفع
// //         'paidAmount': 0.0, // المبلغ المدفوع
// //         'remainingAmount':
// //             _selectedPriceOffer!['wheelNolon'] ?? 0.0, // المبلغ المتبقي
// //         'paymentDate': null, // تاريخ الدفع
// //         'driverNotes': '', // ملاحظات خاصة بالسائق

// //         'createdAt': DateTime.now(),
// //         'updatedAt': DateTime.now(),
// //       };

// //       await _firestore.collection('drivers').add(driverWorkData);

// //       _showSuccess('تم حفظ الشغل اليومي بنجاح وحفظ نسخة في قسم السائقين');
// //       _clearForm();
// //     } catch (e) {
// //       _showError('خطأ في الحفظ: $e');
// //     } finally {
// //       setState(() => _isSaving = false);
// //     }
// //   }

// //   void _clearForm() {
// //     setState(() {
// //       _selectedCompanyId = null;
// //       _selectedCompanyName = null;
// //       _selectedDate = DateTime.now();
// //       _selectedPriceOffer = null;
// //       _priceOffers.clear();
// //       _contractorController.clear();
// //       _trController.clear();
// //       _driverNameController.clear();
// //       _loadingLocationController.clear();
// //       _unloadingLocationController.clear();
// //       _ohdaController.clear();
// //       _kartaController.clear();
// //       _driverSuggestions.clear();
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF4F6F8),
// //       body: LayoutBuilder(
// //         builder: (context, constraints) {
// //           bool isMobile = constraints.maxWidth < 600;

// //           return Column(
// //             children: [
// //               _buildCustomAppBar(isMobile),
// //               Expanded(
// //                 child: SingleChildScrollView(
// //                   padding: EdgeInsets.all(isMobile ? 16 : 24),
// //                   child: Center(
// //                     child: ConstrainedBox(
// //                       constraints: const BoxConstraints(maxWidth: 800),
// //                       child: Column(
// //                         children: [
// //                           Card(
// //                             elevation: 8,
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(
// //                                 isMobile ? 16 : 22,
// //                               ),
// //                             ),
// //                             child: Padding(
// //                               padding: EdgeInsets.all(isMobile ? 16 : 32),
// //                               child: Form(
// //                                 key: _formKey,
// //                                 child: Column(
// //                                   children: [
// //                                     SizedBox(height: isMobile ? 8 : 16),
// //                                     _buildHeaderSection(isMobile),
// //                                     SizedBox(height: isMobile ? 16 : 32),
// //                                     _buildDailyWorkForm(isMobile),
// //                                     SizedBox(height: isMobile ? 20 : 40),
// //                                     _buildActionButtons(isMobile),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   Widget _buildCustomAppBar(bool isMobile) {
// //     return Container(
// //       padding: EdgeInsets.symmetric(
// //         horizontal: isMobile ? 16 : 24,
// //         vertical: isMobile ? 12 : 20,
// //       ),
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
// //         child: Row(
// //           children: [
// //             Icon(Icons.work, color: Colors.white, size: isMobile ? 24 : 32),
// //             SizedBox(width: isMobile ? 8 : 12),
// //             Text(
// //               'الشغل اليومي',
// //               style: TextStyle(
// //                 color: Colors.white,
// //                 fontSize: isMobile ? 18 : 24,
// //                 fontWeight: FontWeight.bold,
// //                 fontFamily: 'Cairo',
// //               ),
// //             ),
// //             const Spacer(),
// //             _buildTimeWidget(),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildTimeWidget() {
// //     return StreamBuilder<DateTime>(
// //       stream: Stream.periodic(
// //         const Duration(seconds: 1),
// //         (_) => DateTime.now(),
// //       ),
// //       builder: (context, snapshot) {
// //         final now = snapshot.data ?? DateTime.now();
// //         int hour12 = now.hour % 12;
// //         if (hour12 == 0) hour12 = 12;

// //         return Column(
// //           crossAxisAlignment: CrossAxisAlignment.center,
// //           children: [
// //             Container(
// //               height: 50,
// //               width: 150,
// //               decoration: BoxDecoration(
// //                 color: Colors.transparent,
// //                 borderRadius: BorderRadius.circular(16),
// //               ),
// //               child: Center(
// //                 child: Text(
// //                   '${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ',
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 36,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildHeaderSection(bool isMobile) {
// //     return Column(
// //       children: [
// //         Text(
// //           'تسجيل الشغل اليومي',
// //           style: TextStyle(
// //             fontSize: isMobile ? 20 : 24,
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //           ),
// //           textAlign: TextAlign.center,
// //         ),
// //         SizedBox(height: 8),
// //         Text(
// //           'أدخل بيانات الشغل اليومي للشركة',
// //           style: TextStyle(
// //             fontSize: isMobile ? 14 : 16,
// //             color: Colors.grey[600],
// //           ),
// //           textAlign: TextAlign.center,
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildDailyWorkForm(bool isMobile) {
// //     return Column(
// //       children: [
// //         // 1. اختيار الشركة
// //         _buildCompanyDropdown(isMobile),
// //         SizedBox(height: isMobile ? 16 : 20),

// //         // 2. اختيار التاريخ
// //         _buildDateField(isMobile),
// //         SizedBox(height: isMobile ? 16 : 20),

// //         // الحقول الجديدة: المقاول و TR
// //         isMobile
// //             ? Column(
// //                 children: [
// //                   _buildField(
// //                     controller: _contractorController,
// //                     label: 'المقاول',
// //                     icon: Icons.business,
// //                     validator: (value) {
// //                       if (value == null || value.isEmpty) {
// //                         return 'هذا الحقل مطلوب';
// //                       }
// //                       return null;
// //                     },
// //                     isMobile: isMobile,
// //                   ),
// //                   SizedBox(height: 16),
// //                   _buildField(
// //                     controller: _trController,
// //                     label: 'TR',
// //                     icon: Icons.numbers,
// //                     validator: (value) {
// //                       if (value == null || value.isEmpty) {
// //                         return 'هذا الحقل مطلوب';
// //                       }
// //                       return null;
// //                     },
// //                     isMobile: isMobile,
// //                   ),
// //                 ],
// //               )
// //             : Row(
// //                 children: [
// //                   Expanded(
// //                     child: _buildField(
// //                       controller: _contractorController,
// //                       label: 'المقاول',
// //                       icon: Icons.business,
// //                       validator: (value) {
// //                         if (value == null || value.isEmpty) {
// //                           return 'هذا الحقل مطلوب';
// //                         }
// //                         return null;
// //                       },
// //                       isMobile: isMobile,
// //                     ),
// //                   ),
// //                   SizedBox(width: 16),
// //                   Expanded(
// //                     child: _buildField(
// //                       controller: _trController,
// //                       label: 'TR',
// //                       icon: Icons.numbers,
// //                       validator: (value) {
// //                         if (value == null || value.isEmpty) {
// //                           return 'هذا الحقل مطلوب';
// //                         }
// //                         return null;
// //                       },
// //                       isMobile: isMobile,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //         SizedBox(height: isMobile ? 16 : 20),

// //         // 3. اسم السائق مع الاقتراح التلقائي
// //         _buildDriverNameField(isMobile),
// //         SizedBox(height: isMobile ? 16 : 20),

// //         // 4. مكان التحميل (يدوي)
// //         // 5. مكان التعتيق (يدوي)
// //         isMobile
// //             ? Column(
// //                 children: [
// //                   _buildField(
// //                     controller: _loadingLocationController,
// //                     label: 'مكان التحميل',
// //                     icon: Icons.location_on,
// //                     validator: (value) {
// //                       if (value == null || value.isEmpty) {
// //                         return 'هذا الحقل مطلوب';
// //                       }
// //                       return null;
// //                     },
// //                     isMobile: isMobile,
// //                   ),
// //                   SizedBox(height: 16),
// //                   _buildField(
// //                     controller: _unloadingLocationController,
// //                     label: 'مكان التعتيق',
// //                     icon: Icons.location_on,
// //                     validator: (value) {
// //                       if (value == null || value.isEmpty) {
// //                         return 'هذا الحقل مطلوب';
// //                       }
// //                       return null;
// //                     },
// //                     isMobile: isMobile,
// //                   ),
// //                 ],
// //               )
// //             : Row(
// //                 children: [
// //                   Expanded(
// //                     child: _buildField(
// //                       controller: _loadingLocationController,
// //                       label: 'مكان التحميل',
// //                       icon: Icons.location_on,
// //                       validator: (value) {
// //                         if (value == null || value.isEmpty) {
// //                           return 'هذا الحقل مطلوب';
// //                         }
// //                         return null;
// //                       },
// //                       isMobile: isMobile,
// //                     ),
// //                   ),
// //                   SizedBox(width: 16),
// //                   Expanded(
// //                     child: _buildField(
// //                       controller: _unloadingLocationController,
// //                       label: 'مكان التعتيق',
// //                       icon: Icons.location_on,
// //                       validator: (value) {
// //                         if (value == null || value.isEmpty) {
// //                           return 'هذا الحقل مطلوب';
// //                         }
// //                         return null;
// //                       },
// //                       isMobile: isMobile,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //         SizedBox(height: isMobile ? 16 : 20),

// //         // 6. العهدة
// //         // 7. الكارتة
// //         isMobile
// //             ? Column(
// //                 children: [
// //                   _buildField(
// //                     controller: _ohdaController,
// //                     label: 'العهدة',
// //                     icon: Icons.assignment,
// //                     validator: (value) {
// //                       if (value == null || value.isEmpty) {
// //                         return 'هذا الحقل مطلوب';
// //                       }
// //                       return null;
// //                     },
// //                     isMobile: isMobile,
// //                   ),
// //                   SizedBox(height: 16),
// //                   _buildField(
// //                     controller: _kartaController,
// //                     label: 'الكارتة',
// //                     icon: Icons.credit_card,
// //                     validator: (value) {
// //                       if (value == null || value.isEmpty) {
// //                         return 'هذا الحقل مطلوب';
// //                       }
// //                       return null;
// //                     },
// //                     isMobile: isMobile,
// //                   ),
// //                 ],
// //               )
// //             : Row(
// //                 children: [
// //                   Expanded(
// //                     child: _buildField(
// //                       controller: _ohdaController,
// //                       label: 'العهدة',
// //                       icon: Icons.assignment,
// //                       validator: (value) {
// //                         if (value == null || value.isEmpty) {
// //                           return 'هذا الحقل مطلوب';
// //                         }
// //                         return null;
// //                       },
// //                       isMobile: isMobile,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //         SizedBox(height: isMobile ? 16 : 20),

// //         // 9. قائمة عروض الأسعار
// //         _buildPriceOffersDropdown(isMobile),
// //         SizedBox(height: isMobile ? 16 : 20),

// //         // عرض السعر المختار مع جميع التفاصيل
// //         // _buildSelectedPriceInfo(isMobile),
// //       ],
// //     );
// //   }

// //   Widget _buildSelectedPriceInfo(bool isMobile) {
// //     if (_selectedPriceOffer == null) {
// //       return Container();
// //     }

// //     return Container(
// //       padding: EdgeInsets.all(isMobile ? 12 : 16),
// //       decoration: BoxDecoration(
// //         color: Colors.grey[50],
// //         borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //         border: Border.all(color: Colors.grey[300]!),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             'تفاصيل السعر المختار',
// //             style: TextStyle(
// //               fontSize: isMobile ? 16 : 18,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.blue[800],
// //             ),
// //           ),
// //           SizedBox(height: 8),

// //           // صفوف الأسعار
// //           isMobile
// //               ? Column(
// //                   children: [
// //                     _buildPriceDetailCard(
// //                       'نولون الشركة',
// //                       '${_selectedPriceOffer!['nolon'] ?? 0} ج',
// //                       Colors.blue,
// //                       Icons.business,
// //                       isMobile,
// //                     ),
// //                     SizedBox(height: 8),
// //                     _buildPriceDetailCard(
// //                       'مبيت الشركة',
// //                       '${_selectedPriceOffer!['companyOvernight'] ?? 0} ج',
// //                       Colors.orange,
// //                       Icons.hotel,
// //                       isMobile,
// //                     ),
// //                     SizedBox(height: 8),
// //                     _buildPriceDetailCard(
// //                       'عطلة الشركة',
// //                       '${_selectedPriceOffer!['companyHoliday'] ?? 0} ج',
// //                       Colors.red,
// //                       Icons.celebration,
// //                       isMobile,
// //                     ),
// //                     SizedBox(height: 8),
// //                     _buildPriceDetailCard(
// //                       'نولون العجلات',
// //                       '${_selectedPriceOffer!['wheelNolon'] ?? 0} ج',
// //                       Colors.green,
// //                       Icons.directions_car,
// //                       isMobile,
// //                     ),
// //                     SizedBox(height: 8),
// //                     _buildPriceDetailCard(
// //                       'مبيت العجلات',
// //                       '${_selectedPriceOffer!['wheelOvernight'] ?? 0} ج',
// //                       Colors.purple,
// //                       Icons.night_shelter,
// //                       isMobile,
// //                     ),
// //                     SizedBox(height: 8),
// //                     _buildPriceDetailCard(
// //                       'عطلة العجلات',
// //                       '${_selectedPriceOffer!['wheelHoliday'] ?? 0} ج',
// //                       Colors.teal,
// //                       Icons.event,
// //                       isMobile,
// //                     ),
// //                   ],
// //                 )
// //               : GridView.count(
// //                   shrinkWrap: true,
// //                   physics: const NeverScrollableScrollPhysics(),
// //                   crossAxisCount: 3,
// //                   crossAxisSpacing: 8,
// //                   mainAxisSpacing: 8,
// //                   childAspectRatio: 2.5,
// //                   children: [
// //                     _buildPriceDetailCard(
// //                       'نولون الشركة',
// //                       '${_selectedPriceOffer!['nolon'] ?? 0} ج',
// //                       Colors.blue,
// //                       Icons.business,
// //                       isMobile,
// //                     ),
// //                     _buildPriceDetailCard(
// //                       'مبيت الشركة',
// //                       '${_selectedPriceOffer!['companyOvernight'] ?? 0} ج',
// //                       Colors.orange,
// //                       Icons.hotel,
// //                       isMobile,
// //                     ),
// //                     _buildPriceDetailCard(
// //                       'عطلة الشركة',
// //                       '${_selectedPriceOffer!['companyHoliday'] ?? 0} ج',
// //                       Colors.red,
// //                       Icons.celebration,
// //                       isMobile,
// //                     ),
// //                     _buildPriceDetailCard(
// //                       'نولون العجلات',
// //                       '${_selectedPriceOffer!['wheelNolon'] ?? 0} ج',
// //                       Colors.green,
// //                       Icons.directions_car,
// //                       isMobile,
// //                     ),
// //                     _buildPriceDetailCard(
// //                       'مبيت العجلات',
// //                       '${_selectedPriceOffer!['wheelOvernight'] ?? 0} ج',
// //                       Colors.purple,
// //                       Icons.night_shelter,
// //                       isMobile,
// //                     ),
// //                     _buildPriceDetailCard(
// //                       'عطلة العجلات',
// //                       '${_selectedPriceOffer!['wheelHoliday'] ?? 0} ج',
// //                       Colors.teal,
// //                       Icons.event,
// //                       isMobile,
// //                     ),
// //                   ],
// //                 ),

// //           // معلومات إضافية
// //           SizedBox(height: 12),
// //           Divider(color: Colors.grey[300]),
// //           SizedBox(height: 8),
// //           _buildPriceDetailRow(
// //             'نوع السيارة:',
// //             _selectedPriceOffer!['vehicleType'] ?? '',
// //             isMobile,
// //           ),
// //           _buildPriceDetailRow(
// //             'ملاحظات:',
// //             _selectedPriceOffer!['notes'] ?? 'لا توجد ملاحظات',
// //             isMobile,
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildDriverNameField(bool isMobile) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'اسم السائق',
// //           style: TextStyle(
// //             fontSize: isMobile ? 14 : 16,
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //           ),
// //         ),
// //         SizedBox(height: isMobile ? 6 : 8),
// //         Container(
// //           decoration: BoxDecoration(
// //             borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //           ),
// //           child: Column(
// //             children: [
// //               TextFormField(
// //                 controller: _driverNameController,
// //                 onChanged: _onDriverNameChanged,
// //                 style: TextStyle(fontSize: isMobile ? 14 : 16),
// //                 decoration: InputDecoration(
// //                   prefixIcon: Icon(
// //                     Icons.person,
// //                     color: const Color(0xFF3498DB),
// //                   ),
// //                   filled: true,
// //                   fillColor: Colors.white,
// //                   border: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //                     borderSide: const BorderSide(color: Color(0xFF3498DB)),
// //                   ),
// //                   contentPadding: EdgeInsets.symmetric(
// //                     horizontal: isMobile ? 12 : 16,
// //                     vertical: isMobile ? 12 : 16,
// //                   ),
// //                   hintText: 'اكتب اسم السائق',
// //                   suffixIcon: _isLoadingSuggestions
// //                       ? Padding(
// //                           padding: const EdgeInsets.all(8.0),
// //                           child: SizedBox(
// //                             width: 16,
// //                             height: 16,
// //                             child: CircularProgressIndicator(strokeWidth: 2),
// //                           ),
// //                         )
// //                       : null,
// //                 ),
// //                 validator: (value) {
// //                   if (value == null || value.isEmpty) {
// //                     return 'هذا الحقل مطلوب';
// //                   }
// //                   return null;
// //                 },
// //               ),
// //               // عرض قائمة الاقتراحات
// //               if (_driverSuggestions.isNotEmpty &&
// //                   _driverNameController.text.isNotEmpty)
// //                 Container(
// //                   margin: EdgeInsets.only(top: 4),
// //                   decoration: BoxDecoration(
// //                     color: Colors.white,
// //                     borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //                     border: Border.all(color: Colors.grey[300]!),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: Colors.black12,
// //                         blurRadius: 4,
// //                         offset: Offset(0, 2),
// //                       ),
// //                     ],
// //                   ),
// //                   child: Column(
// //                     children: _driverSuggestions
// //                         .map(
// //                           (suggestion) => ListTile(
// //                             leading: Icon(
// //                               Icons.person_outline,
// //                               color: Colors.blue,
// //                               size: 20,
// //                             ),
// //                             title: Text(
// //                               suggestion,
// //                               style: TextStyle(fontSize: isMobile ? 14 : 16),
// //                             ),
// //                             dense: true,
// //                             visualDensity: VisualDensity.compact,
// //                             contentPadding: EdgeInsets.symmetric(
// //                               horizontal: 12,
// //                             ),
// //                             onTap: () {
// //                               setState(() {
// //                                 _driverNameController.text = suggestion;
// //                                 _driverSuggestions.clear();
// //                               });
// //                             },
// //                           ),
// //                         )
// //                         .toList(),
// //                   ),
// //                 ),
// //             ],
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildCompanyDropdown(bool isMobile) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'اختر الشركة',
// //           style: TextStyle(
// //             fontSize: isMobile ? 14 : 16,
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //           ),
// //         ),
// //         SizedBox(height: isMobile ? 6 : 8),
// //         Container(
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //             border: Border.all(color: const Color(0xFF3498DB)),
// //           ),
// //           child: _isLoading
// //               ? Padding(
// //                   padding: EdgeInsets.symmetric(
// //                     horizontal: isMobile ? 12 : 16,
// //                     vertical: isMobile ? 12 : 16,
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       SizedBox(
// //                         width: isMobile ? 16 : 20,
// //                         height: isMobile ? 16 : 20,
// //                         child: const CircularProgressIndicator(strokeWidth: 2),
// //                       ),
// //                       SizedBox(width: isMobile ? 8 : 12),
// //                       Text(
// //                         'جاري تحميل الشركات...',
// //                         style: TextStyle(fontSize: isMobile ? 14 : 16),
// //                       ),
// //                     ],
// //                   ),
// //                 )
// //               : DropdownButtonHideUnderline(
// //                   child: DropdownButton<String>(
// //                     value: _selectedCompanyId,
// //                     isExpanded: true,
// //                     hint: Padding(
// //                       padding: EdgeInsets.symmetric(
// //                         horizontal: isMobile ? 12 : 16,
// //                       ),
// //                       child: Text(
// //                         'اختر شركة',
// //                         style: TextStyle(fontSize: isMobile ? 14 : 16),
// //                       ),
// //                     ),
// //                     items: _companies.map((company) {
// //                       final data = company.data();
// //                       final companyName = data['companyName'] ?? '';
// //                       return DropdownMenuItem<String>(
// //                         value: company.id,
// //                         child: Padding(
// //                           padding: EdgeInsets.symmetric(
// //                             horizontal: isMobile ? 12 : 16,
// //                           ),
// //                           child: Text(
// //                             companyName,
// //                             style: TextStyle(fontSize: isMobile ? 14 : 16),
// //                             overflow: TextOverflow.ellipsis,
// //                           ),
// //                         ),
// //                       );
// //                     }).toList(),
// //                     onChanged: (String? newValue) {
// //                       setState(() {
// //                         _selectedCompanyId = newValue;
// //                         _selectedCompanyName = _companies
// //                             .firstWhere((company) => company.id == newValue)
// //                             .data()['companyName'];
// //                         _priceOffers.clear();
// //                         _selectedPriceOffer = null;

// //                         if (newValue != null) {
// //                           _loadPriceOffers(newValue);
// //                         }
// //                       });
// //                     },
// //                   ),
// //                 ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildPriceOffersDropdown(bool isMobile) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'اسم الموقع',
// //           style: TextStyle(
// //             fontSize: isMobile ? 14 : 16,
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //           ),
// //         ),
// //         SizedBox(height: isMobile ? 6 : 8),

// //         Container(
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //             border: Border.all(color: Colors.orange),
// //           ),
// //           child: ExpansionTile(
// //             title: Row(
// //               children: [
// //                 Icon(Icons.map, color: Colors.orange, size: isMobile ? 20 : 24),
// //                 SizedBox(width: 8),
// //                 Expanded(
// //                   child: _selectedPriceOffer != null
// //                       ? Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Text(
// //                               '${_selectedPriceOffer!['unloadingLocation']}',
// //                               style: TextStyle(
// //                                 fontSize: isMobile ? 14 : 16,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.green[700],
// //                               ),
// //                             ),
// //                           ],
// //                         )
// //                       : Text(
// //                           'اختر موقع من القائمة',
// //                           style: TextStyle(
// //                             fontSize: isMobile ? 14 : 16,
// //                             color: Colors.grey[600],
// //                           ),
// //                         ),
// //                 ),
// //               ],
// //             ),
// //             trailing: Icon(
// //               _isDropdownOpen ? Icons.expand_less : Icons.expand_more,
// //               color: Colors.orange,
// //             ),
// //             onExpansionChanged: (expanded) {
// //               setState(() {
// //                 _isDropdownOpen = expanded;
// //               });

// //               if (expanded &&
// //                   _selectedCompanyId != null &&
// //                   _priceOffers.isEmpty) {
// //                 _loadPriceOffers(_selectedCompanyId!);
// //               }
// //             },
// //             children: [
// //               if (_selectedCompanyId == null)
// //                 Padding(
// //                   padding: EdgeInsets.all(16),
// //                   child: Text(
// //                     'يرجى اختيار شركة أولاً',
// //                     style: TextStyle(color: Colors.grey),
// //                     textAlign: TextAlign.center,
// //                   ),
// //                 )
// //               else if (_priceOffers.isEmpty)
// //                 Padding(
// //                   padding: EdgeInsets.all(16),
// //                   child: Text(
// //                     'لا توجد عروض أسعار لهذه الشركة',
// //                     style: TextStyle(color: Colors.grey),
// //                     textAlign: TextAlign.center,
// //                   ),
// //                 )
// //               else
// //                 ..._priceOffers.map((offer) {
// //                   return Container(
// //                     decoration: BoxDecoration(
// //                       border: Border(top: BorderSide(color: Colors.grey[200]!)),
// //                     ),
// //                     child: ListTile(
// //                       leading: Icon(Icons.route, color: Colors.blue),
// //                       title: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             '${offer['unloadingLocation']}',
// //                             style: TextStyle(
// //                               fontSize: isMobile ? 14 : 16,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       trailing:
// //                           _selectedPriceOffer != null &&
// //                               _selectedPriceOffer!['offerId'] ==
// //                                   offer['offerId']
// //                           ? Icon(Icons.check_circle, color: Colors.green)
// //                           : null,
// //                       onTap: () {
// //                         _selectPriceOffer(offer);
// //                       },
// //                       dense: true,
// //                     ),
// //                   );
// //                 }).toList(),
// //             ],
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildPriceDetailCard(
// //     String title,
// //     String value,
// //     Color color,
// //     IconData icon,
// //     bool isMobile,
// //   ) {
// //     return Container(
// //       padding: EdgeInsets.all(isMobile ? 8 : 10),
// //       decoration: BoxDecoration(
// //         color: color.withOpacity(0.1),
// //         borderRadius: BorderRadius.circular(8),
// //         border: Border.all(color: color.withOpacity(0.3)),
// //       ),
// //       child: Column(
// //         children: [
// //           Row(
// //             children: [
// //               Icon(icon, color: color, size: isMobile ? 16 : 18),
// //               SizedBox(width: 4),
// //               Expanded(
// //                 child: Text(
// //                   title,
// //                   style: TextStyle(
// //                     fontSize: isMobile ? 11 : 12,
// //                     color: color,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           SizedBox(height: 4),
// //           Text(
// //             value,
// //             style: TextStyle(
// //               fontSize: isMobile ? 14 : 16,
// //               fontWeight: FontWeight.bold,
// //               color: color,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildPriceDetailRow(String label, String value, bool isMobile) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 4),
// //       child: Row(
// //         children: [
// //           Text(
// //             label,
// //             style: TextStyle(
// //               fontSize: isMobile ? 12 : 14,
// //               color: Colors.grey[700],
// //             ),
// //           ),
// //           SizedBox(width: 8),
// //           Expanded(
// //             child: Text(
// //               value,
// //               style: TextStyle(
// //                 fontSize: isMobile ? 12 : 14,
// //                 fontWeight: FontWeight.w500,
// //               ),
// //               textAlign: TextAlign.left,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildDateField(bool isMobile) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'التاريخ',
// //           style: TextStyle(
// //             fontSize: isMobile ? 14 : 16,
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //           ),
// //         ),
// //         SizedBox(height: isMobile ? 6 : 8),
// //         InkWell(
// //           onTap: () => _selectDate(context),
// //           child: Container(
// //             padding: EdgeInsets.symmetric(
// //               horizontal: isMobile ? 12 : 16,
// //               vertical: isMobile ? 12 : 16,
// //             ),
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //               border: Border.all(color: const Color(0xFF3498DB)),
// //             ),
// //             child: Row(
// //               children: [
// //                 Icon(
// //                   Icons.calendar_today,
// //                   color: const Color(0xFF3498DB),
// //                   size: isMobile ? 18 : 24,
// //                 ),
// //                 SizedBox(width: isMobile ? 8 : 12),
// //                 Text(
// //                   _formatDate(_selectedDate),
// //                   style: TextStyle(fontSize: isMobile ? 14 : 16),
// //                 ),
// //                 const Spacer(),
// //                 Text(
// //                   'اختر التاريخ',
// //                   style: TextStyle(
// //                     color: Colors.grey,
// //                     fontSize: isMobile ? 12 : 14,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildField({
// //     required TextEditingController controller,
// //     required String label,
// //     required IconData icon,
// //     required String? Function(String?)? validator,
// //     required bool isMobile,
// //   }) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           label,
// //           style: TextStyle(
// //             fontSize: isMobile ? 14 : 16,
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //           ),
// //         ),
// //         SizedBox(height: isMobile ? 6 : 8),
// //         TextFormField(
// //           controller: controller,
// //           style: TextStyle(fontSize: isMobile ? 14 : 16),
// //           decoration: InputDecoration(
// //             prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
// //             filled: true,
// //             fillColor: Colors.white,
// //             border: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //               borderSide: const BorderSide(color: Color(0xFF3498DB)),
// //             ),
// //             contentPadding: EdgeInsets.symmetric(
// //               horizontal: isMobile ? 12 : 16,
// //               vertical: isMobile ? 12 : 16,
// //             ),
// //           ),
// //           validator: validator,
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildActionButtons(bool isMobile) {
// //     return SizedBox(
// //       width: double.infinity,
// //       child: ElevatedButton(
// //         onPressed: _isSaving ? null : _saveDailyWork,
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: const Color(0xFF2E86C1),
// //           padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 18),
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //           ),
// //         ),
// //         child: _isSaving
// //             ? SizedBox(
// //                 width: isMobile ? 20 : 24,
// //                 height: isMobile ? 20 : 24,
// //                 child: const CircularProgressIndicator(color: Colors.white),
// //               )
// //             : Text(
// //                 'حفظ الشغل اليومى',
// //                 style: TextStyle(
// //                   fontSize: isMobile ? 16 : 18,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.white,
// //                 ),
// //               ),
// //       ),
// //     );
// //   }

// //   String _formatDate(DateTime date) {
// //     return '${date.day}/${date.month}/${date.year}';
// //   }

// //   @override
// //   void dispose() {
// //     _debounce?.cancel();
// //     _contractorController.dispose();
// //     _trController.dispose();
// //     _driverNameController.dispose();
// //     _loadingLocationController.dispose();
// //     _unloadingLocationController.dispose();
// //     _ohdaController.dispose();
// //     _kartaController.dispose();
// //     super.dispose();
// //   }
// // // }
// // import 'dart:async';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:last/models/models.dart';

// // class DailyWorkPage extends StatefulWidget {
// //   const DailyWorkPage({super.key});

// //   @override
// //   State<DailyWorkPage> createState() => _DailyWorkPageState();
// // }

// // class _DailyWorkPageState extends State<DailyWorkPage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   final _formKey = GlobalKey<FormState>();

// //   // 1. بيانات الشركة
// //   List<QueryDocumentSnapshot<Map<String, dynamic>>> _companies = [];
// //   String? _selectedCompanyId;
// //   String? _selectedCompanyName;

// //   // 2. التاريخ
// //   DateTime _selectedDate = DateTime.now();

// //   // الحقول الجديدة
// //   final TextEditingController _contractorController = TextEditingController();
// //   final TextEditingController _trController = TextEditingController();
// //   final TextEditingController _notesController = TextEditingController();

// //   // 3-8. الحقول اليدوية
// //   final TextEditingController _driverNameController = TextEditingController();
// //   final TextEditingController _loadingLocationController =
// //       TextEditingController();
// //   final TextEditingController _unloadingLocationController =
// //       TextEditingController();
// //   final TextEditingController _ohdaController = TextEditingController();
// //   final TextEditingController _kartaController = TextEditingController();

// //   // حالة التحميل والحفظ
// //   bool _isLoading = true;
// //   bool _isSaving = false;

// //   // 9-13. عروض الأسعار
// //   List<Map<String, dynamic>> _priceOffers = [];
// //   Map<String, dynamic>? _selectedPriceOffer;
// //   bool _isDropdownOpen = false;

// //   // اقتراحات أسماء السائقين
// //   List<String> _driverSuggestions = [];
// //   bool _isLoadingSuggestions = false;
// //   Timer? _debounce;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadCompanies();
// //   }

// //   Future<void> _loadCompanies() async {
// //     try {
// //       final snapshot = await _firestore.collection('companies').get();
// //       setState(() {
// //         _companies = snapshot.docs;
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() => _isLoading = false);
// //       _showError('خطأ في تحميل الشركات: $e');
// //     }
// //   }

// //   Future<void> _loadPriceOffers(String companyId) async {
// //     if (companyId.isEmpty) return;

// //     try {
// //       final snapshot = await _firestore
// //           .collection('companies')
// //           .doc(companyId)
// //           .collection('priceOffers')
// //           .get();

// //       List<Map<String, dynamic>> allTransportations = [];

// //       for (final offerDoc in snapshot.docs) {
// //         final offerData = offerDoc.data();
// //         final transportations = offerData['transportations'] as List? ?? [];

// //         for (final transport in transportations) {
// //           final transportMap = transport as Map<String, dynamic>;

// //           allTransportations.add({
// //             'offerId': offerDoc.id,
// //             'loadingLocation': transportMap['loadingLocation'] ?? '',
// //             'unloadingLocation': transportMap['unloadingLocation'] ?? '',
// //             'vehicleType': transportMap['vehicleType'] ?? '',
// //             'nolon': (transportMap['nolon'] ?? transportMap['noLon'] ?? 0.0)
// //                 .toDouble(),
// //             'wheelNolon':
// //                 (transportMap['wheelNolon'] ??
// //                         transportMap['wheelNoLon'] ??
// //                         0.0)
// //                     .toDouble(),
// //             'companyOvernight': (transportMap['companyOvernight'] ?? 0.0)
// //                 .toDouble(),
// //             'companyHoliday': (transportMap['companyHoliday'] ?? 0.0)
// //                 .toDouble(),
// //             'wheelOvernight': (transportMap['wheelOvernight'] ?? 0.0)
// //                 .toDouble(),
// //             'wheelHoliday': (transportMap['wheelHoliday'] ?? 0.0).toDouble(),
// //             'notes': transportMap['notes'] ?? '',
// //           });
// //         }
// //       }

// //       setState(() {
// //         _priceOffers = allTransportations;
// //       });
// //     } catch (e) {
// //       print('خطأ في تحميل عروض الأسعار: $e');
// //     }
// //   }

// //   Future<List<String>> _fetchDriverSuggestions(String query) async {
// //     if (query.isEmpty) return [];

// //     try {
// //       final snapshot = await _firestore
// //           .collection('dailyWork')
// //           .where('driverName', isGreaterThanOrEqualTo: query)
// //           .where('driverName', isLessThan: query + 'z')
// //           .orderBy('driverName')
// //           .limit(10)
// //           .get();

// //       final names = snapshot.docs
// //           .map((doc) => doc.data()['driverName'] as String? ?? '')
// //           .where((name) => name.toLowerCase().contains(query.toLowerCase()))
// //           .toSet()
// //           .toList();

// //       return names;
// //     } catch (e) {
// //       print('خطأ في جلب اقتراحات السائقين: $e');
// //       return [];
// //     }
// //   }

// //   void _onDriverNameChanged(String value) {
// //     if (_debounce?.isActive ?? false) _debounce?.cancel();

// //     _debounce = Timer(const Duration(milliseconds: 300), () async {
// //       if (value.isNotEmpty && value.length >= 2) {
// //         setState(() => _isLoadingSuggestions = true);
// //         final suggestions = await _fetchDriverSuggestions(value);
// //         setState(() {
// //           _driverSuggestions = suggestions;
// //           _isLoadingSuggestions = false;
// //         });
// //       } else {
// //         setState(() => _driverSuggestions.clear());
// //       }
// //     });
// //   }

// //   void _showError(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text(message), backgroundColor: Colors.red),
// //     );
// //   }

// //   void _showSuccess(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text(message), backgroundColor: Colors.green),
// //     );
// //   }

// //   Future<void> _selectDate(BuildContext context) async {
// //     final DateTime? picked = await showDatePicker(
// //       context: context,
// //       initialDate: _selectedDate,
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime(2030),
// //     );
// //     if (picked != null && picked != _selectedDate) {
// //       setState(() {
// //         _selectedDate = picked;
// //       });
// //     }
// //   }

// //   void _selectPriceOffer(Map<String, dynamic> offer) {
// //     setState(() {
// //       _selectedPriceOffer = offer;
// //       _isDropdownOpen = false;
// //     });
// //   }

// //   Future<void> _saveDailyWork() async {
// //     if (_selectedCompanyId == null) {
// //       _showError('يرجى اختيار شركة');
// //       return;
// //     }

// //     if (_selectedPriceOffer == null) {
// //       _showError('يرجى اختيار موقع من عروض الأسعار');
// //       return;
// //     }

// //     if (!_formKey.currentState!.validate()) return;

// //     setState(() => _isSaving = true);

// //     try {
// //       final dailyWork = DailyWork(
// //         companyId: _selectedCompanyId!,
// //         companyName: _selectedCompanyName!,
// //         date: _selectedDate,
// //         contractor: _contractorController.text.trim(),
// //         tr: _trController.text.trim(),
// //         driverName: _driverNameController.text.trim(),
// //         loadingLocation: _loadingLocationController.text.trim(),
// //         unloadingLocation: _unloadingLocationController.text.trim(),
// //         ohda: _ohdaController.text.trim(),
// //         karta: _kartaController.text.trim(),
// //         // notes: _notesController.text.trim(),
// //         selectedRoute: '${_selectedPriceOffer!['unloadingLocation']}',
// //         selectedPrice: _selectedPriceOffer!['nolon'] ?? 0.0,
// //         wheelNolon: _selectedPriceOffer!['wheelNolon'] ?? 0.0,
// //         selectedVehicleType: _selectedPriceOffer!['vehicleType'] ?? '',
// //         selectedNotes: _notesController.text.trim(),
// //         priceOfferId: _selectedPriceOffer!['offerId'] ?? '',
// //         wheelOvernight: 0,
// //         wheelHoliday: 0,
// //         companyOvernight: 0,
// //         companyHoliday: 0,
// //         nolon: _selectedPriceOffer!['nolon'] ?? 0.0,
// //         createdAt: DateTime.now(),
// //         updatedAt: DateTime.now(),
// //       );

// //       final dailyWorkRef = await _firestore
// //           .collection('dailyWork')
// //           .add(dailyWork.toMap());

// //       final driverWorkData = {
// //         'dailyWorkId': dailyWorkRef.id,
// //         'companyId': _selectedCompanyId!,
// //         'companyName': _selectedCompanyName!,
// //         'date': _selectedDate,
// //         'contractor': _contractorController.text.trim(),
// //         'tr': _trController.text.trim(),
// //         'driverName': _driverNameController.text.trim(),
// //         'loadingLocation': _loadingLocationController.text.trim(),
// //         'unloadingLocation': _unloadingLocationController.text.trim(),
// //         'ohda': _ohdaController.text.trim(),
// //         'karta': _kartaController.text.trim(),
// //         // 'notes': _notesController.text.trim(),
// //         'selectedRoute': '${_selectedPriceOffer!['unloadingLocation']}',
// //         'selectedPrice': _selectedPriceOffer!['nolon'] ?? 0.0,
// //         'wheelNolon': _selectedPriceOffer!['wheelNolon'] ?? 0.0,
// //         'selectedVehicleType': _selectedPriceOffer!['vehicleType'] ?? '',
// //         'selectedNotes': _notesController.text.trim(),

// //         'priceOfferId': _selectedPriceOffer!['offerId'] ?? '',
// //         'wheelOvernight': 0,
// //         'wheelHoliday': 0,
// //         'companyOvernight': 0,
// //         'companyHoliday': 0,
// //         'nolon': _selectedPriceOffer!['nolon'] ?? 0.0,
// //         'isPaid': false,
// //         'paidAmount': 0.0,
// //         'remainingAmount': _selectedPriceOffer!['wheelNolon'] ?? 0.0,
// //         'paymentDate': null,
// //         'driverNotes': '',
// //         'createdAt': DateTime.now(),
// //         'updatedAt': DateTime.now(),
// //       };

// //       await _firestore.collection('drivers').add(driverWorkData);

// //       _showSuccess('تم حفظ الشغل اليومي بنجاح وحفظ نسخة في قسم السائقين');
// //       _clearForm();
// //     } catch (e) {
// //       _showError('خطأ في الحفظ: $e');
// //     } finally {
// //       setState(() => _isSaving = false);
// //     }
// //   }

// //   // دالة لبناء حقل TR اختياري
// //   Widget _buildOptionalTRField(bool isMobile) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'TR (اختياري)',
// //           style: TextStyle(
// //             fontSize: isMobile ? 14 : 16,
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //           ),
// //         ),
// //         SizedBox(height: isMobile ? 6 : 8),
// //         TextFormField(
// //           controller: _trController,
// //           style: TextStyle(fontSize: isMobile ? 14 : 16),
// //           decoration: InputDecoration(
// //             prefixIcon: Icon(Icons.numbers, color: const Color(0xFF3498DB)),
// //             filled: true,
// //             fillColor: Colors.white,
// //             border: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //               borderSide: const BorderSide(color: Color(0xFF3498DB)),
// //             ),
// //             contentPadding: EdgeInsets.symmetric(
// //               horizontal: isMobile ? 12 : 16,
// //               vertical: isMobile ? 12 : 16,
// //             ),
// //             hintText: 'أدخل قيمة TR (اختياري)',
// //           ),
// //           // لا يوجد validator هنا، مما يجعله اختيارياً
// //         ),
// //       ],
// //     );
// //   }

// //   void _clearForm() {
// //     setState(() {
// //       _selectedCompanyId = null;
// //       _selectedCompanyName = null;
// //       _selectedDate = DateTime.now();
// //       _selectedPriceOffer = null;
// //       _priceOffers.clear();
// //       _contractorController.clear();
// //       _trController.clear();
// //       _notesController.clear();
// //       _driverNameController.clear();
// //       _loadingLocationController.clear();
// //       _unloadingLocationController.clear();
// //       _ohdaController.clear();
// //       _kartaController.clear();
// //       _driverSuggestions.clear();
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF4F6F8),
// //       body: LayoutBuilder(
// //         builder: (context, constraints) {
// //           bool isMobile = constraints.maxWidth < 600;

// //           return Column(
// //             children: [
// //               _buildCustomAppBar(isMobile),
// //               Expanded(
// //                 child: SingleChildScrollView(
// //                   padding: EdgeInsets.all(isMobile ? 16 : 24),
// //                   child: Center(
// //                     child: ConstrainedBox(
// //                       constraints: const BoxConstraints(maxWidth: 800),
// //                       child: Column(
// //                         children: [
// //                           Card(
// //                             elevation: 8,
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(
// //                                 isMobile ? 16 : 22,
// //                               ),
// //                             ),
// //                             child: Padding(
// //                               padding: EdgeInsets.all(isMobile ? 16 : 32),
// //                               child: Form(
// //                                 key: _formKey,
// //                                 child: Column(
// //                                   children: [
// //                                     SizedBox(height: isMobile ? 8 : 16),
// //                                     _buildHeaderSection(isMobile),
// //                                     SizedBox(height: isMobile ? 16 : 32),
// //                                     _buildDailyWorkForm(isMobile),
// //                                     SizedBox(height: isMobile ? 20 : 40),
// //                                     _buildActionButtons(isMobile),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   Widget _buildCustomAppBar(bool isMobile) {
// //     return Container(
// //       padding: EdgeInsets.symmetric(
// //         horizontal: isMobile ? 16 : 24,
// //         vertical: isMobile ? 12 : 20,
// //       ),
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
// //         child: Row(
// //           children: [
// //             Icon(Icons.work, color: Colors.white, size: isMobile ? 24 : 32),
// //             SizedBox(width: isMobile ? 8 : 12),
// //             Text(
// //               'الشغل اليومي',
// //               style: TextStyle(
// //                 color: Colors.white,
// //                 fontSize: isMobile ? 18 : 24,
// //                 fontWeight: FontWeight.bold,
// //                 fontFamily: 'Cairo',
// //               ),
// //             ),
// //             const Spacer(),
// //             _buildTimeWidget(),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildTimeWidget() {
// //     return StreamBuilder<DateTime>(
// //       stream: Stream.periodic(
// //         const Duration(seconds: 1),
// //         (_) => DateTime.now(),
// //       ),
// //       builder: (context, snapshot) {
// //         final now = snapshot.data ?? DateTime.now();
// //         int hour12 = now.hour % 12;
// //         if (hour12 == 0) hour12 = 12;

// //         return Column(
// //           crossAxisAlignment: CrossAxisAlignment.center,
// //           children: [
// //             Container(
// //               height: 50,
// //               width: 150,
// //               decoration: BoxDecoration(
// //                 color: Colors.transparent,
// //                 borderRadius: BorderRadius.circular(16),
// //               ),
// //               child: Center(
// //                 child: Text(
// //                   '${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ',
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 36,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildHeaderSection(bool isMobile) {
// //     return Column(
// //       children: [
// //         Text(
// //           'تسجيل الشغل اليومي',
// //           style: TextStyle(
// //             fontSize: isMobile ? 20 : 24,
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //           ),
// //           textAlign: TextAlign.center,
// //         ),
// //         SizedBox(height: 8),
// //         Text(
// //           'أدخل بيانات الشغل اليومي للشركة',
// //           style: TextStyle(
// //             fontSize: isMobile ? 14 : 16,
// //             color: Colors.grey[600],
// //           ),
// //           textAlign: TextAlign.center,
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildDailyWorkForm(bool isMobile) {
// //     return Column(
// //       children: [
// //         // 1. اختيار الشركة
// //         _buildCompanyDropdown(isMobile),
// //         SizedBox(height: isMobile ? 16 : 20),

// //         // 2. اختيار التاريخ
// //         _buildDateField(isMobile),
// //         SizedBox(height: isMobile ? 16 : 20),

// //         // الحقول: المقاول و TR
// //         isMobile
// //             ? Column(
// //                 children: [
// //                   _buildField(
// //                     controller: _contractorController,
// //                     label: 'المقاول',
// //                     icon: Icons.business,
// //                     validator: (value) {
// //                       if (value == null || value.isEmpty) {
// //                         return 'هذا الحقل مطلوب';
// //                       }
// //                       return null;
// //                     },
// //                     isMobile: isMobile,
// //                   ),
// //                   SizedBox(height: 16),
// //                   _buildOptionalTRField(isMobile), // استدعاء الدالة الجديدة
// //                 ],
// //               )
// //             : Row(
// //                 children: [
// //                   Expanded(
// //                     child: _buildField(
// //                       controller: _contractorController,
// //                       label: 'المقاول',
// //                       icon: Icons.business,
// //                       validator: (value) {
// //                         if (value == null || value.isEmpty) {
// //                           return 'هذا الحقل مطلوب';
// //                         }
// //                         return null;
// //                       },
// //                       isMobile: isMobile,
// //                     ),
// //                   ),
// //                   SizedBox(width: 16),
// //                   Expanded(
// //                     child: _buildOptionalTRField(
// //                       isMobile,
// //                     ), // استدعاء الدالة الجديدة
// //                   ),
// //                 ],
// //               ),
// //         SizedBox(height: isMobile ? 16 : 20),

// //         // 3. اسم السائق مع الاقتراح التلقائي
// //         _buildDriverNameField(isMobile),
// //         SizedBox(height: isMobile ? 16 : 20),

// //         // 4. مكان التحميل (يدوي)
// //         // 5. مكان التعتيق (يدوي)
// //         isMobile
// //             ? Column(
// //                 children: [
// //                   _buildField(
// //                     controller: _loadingLocationController,
// //                     label: 'مكان التحميل',
// //                     icon: Icons.location_on,
// //                     validator: (value) {
// //                       if (value == null || value.isEmpty) {
// //                         return 'هذا الحقل مطلوب';
// //                       }
// //                       return null;
// //                     },
// //                     isMobile: isMobile,
// //                   ),
// //                   SizedBox(height: 16),
// //                   _buildField(
// //                     controller: _unloadingLocationController,
// //                     label: 'مكان التعتيق',
// //                     icon: Icons.location_on,
// //                     validator: (value) {
// //                       if (value == null || value.isEmpty) {
// //                         return 'هذا الحقل مطلوب';
// //                       }
// //                       return null;
// //                     },
// //                     isMobile: isMobile,
// //                   ),
// //                 ],
// //               )
// //             : Row(
// //                 children: [
// //                   Expanded(
// //                     child: _buildField(
// //                       controller: _loadingLocationController,
// //                       label: 'مكان التحميل',
// //                       icon: Icons.location_on,
// //                       validator: (value) {
// //                         if (value == null || value.isEmpty) {
// //                           return 'هذا الحقل مطلوب';
// //                         }
// //                         return null;
// //                       },
// //                       isMobile: isMobile,
// //                     ),
// //                   ),
// //                   SizedBox(width: 16),
// //                   Expanded(
// //                     child: _buildField(
// //                       controller: _unloadingLocationController,
// //                       label: 'مكان التعتيق',
// //                       icon: Icons.location_on,
// //                       validator: (value) {
// //                         if (value == null || value.isEmpty) {
// //                           return 'هذا الحقل مطلوب';
// //                         }
// //                         return null;
// //                       },
// //                       isMobile: isMobile,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //         SizedBox(height: isMobile ? 16 : 20),

// //         // 6. العهدة
// //         // 7. الكارتة
// //         isMobile
// //             ? Column(
// //                 children: [
// //                   _buildField(
// //                     controller: _ohdaController,
// //                     label: 'العهدة',
// //                     icon: Icons.assignment,
// //                     validator: (value) {
// //                       if (value == null || value.isEmpty) {
// //                         return 'هذا الحقل مطلوب';
// //                       }
// //                       return null;
// //                     },
// //                     isMobile: isMobile,
// //                   ),
// //                   SizedBox(height: 16),
// //                   _buildField(
// //                     controller: _kartaController,
// //                     label: 'الكارتة',
// //                     icon: Icons.credit_card,
// //                     validator: (value) {
// //                       if (value == null || value.isEmpty) {
// //                         return 'هذا الحقل مطلوب';
// //                       }
// //                       return null;
// //                     },
// //                     isMobile: isMobile,
// //                   ),
// //                 ],
// //               )
// //             : Row(
// //                 children: [
// //                   Expanded(
// //                     child: _buildField(
// //                       controller: _ohdaController,
// //                       label: 'العهدة',
// //                       icon: Icons.assignment,
// //                       validator: (value) {
// //                         if (value == null || value.isEmpty) {
// //                           return 'هذا الحقل مطلوب';
// //                         }
// //                         return null;
// //                       },
// //                       isMobile: isMobile,
// //                     ),
// //                   ),
// //                   // SizedBox(width: 16),
// //                   // Expanded(
// //                   //   child: _buildField(
// //                   //     controller: _kartaController,
// //                   //     label: 'الكارتة',
// //                   //     icon: Icons.credit_card,
// //                   //     validator: (value) {
// //                   //       if (value == null || value.isEmpty) {
// //                   //         return 'هذا الحقل مطلوب';
// //                   //       }
// //                   //       return null;
// //                   //     },
// //                   //     isMobile: isMobile,
// //                   //   ),
// //                   // ),
// //                 ],
// //               ),
// //         SizedBox(height: isMobile ? 16 : 20),

// //         // 8. الملاحظات (اختياري)
// //         _buildNotesField(isMobile),
// //         SizedBox(height: isMobile ? 16 : 20),

// //         // 9. قائمة عروض الأسعار
// //         _buildPriceOffersDropdown(isMobile),
// //         SizedBox(height: isMobile ? 16 : 20),
// //       ],
// //     );
// //   }

// //   // دالة لبناء حقل الملاحظات
// //   Widget _buildNotesField(bool isMobile) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'ملاحظات (اختياري)',
// //           style: TextStyle(
// //             fontSize: isMobile ? 14 : 16,
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //           ),
// //         ),
// //         SizedBox(height: isMobile ? 6 : 8),
// //         TextFormField(
// //           controller: _notesController,
// //           style: TextStyle(fontSize: isMobile ? 14 : 16),
// //           maxLines: 3,
// //           decoration: InputDecoration(
// //             prefixIcon: Icon(Icons.note, color: const Color(0xFF3498DB)),
// //             filled: true,
// //             fillColor: Colors.white,
// //             border: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //               borderSide: const BorderSide(color: Color(0xFF3498DB)),
// //             ),
// //             contentPadding: EdgeInsets.symmetric(
// //               horizontal: isMobile ? 12 : 16,
// //               vertical: isMobile ? 14 : 18,
// //             ),
// //             hintText: 'أدخل ملاحظات إضافية (اختياري)...',
// //             alignLabelWithHint: true,
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildSelectedPriceInfo(bool isMobile) {
// //     if (_selectedPriceOffer == null) {
// //       return Container();
// //     }

// //     return Container(
// //       padding: EdgeInsets.all(isMobile ? 12 : 16),
// //       decoration: BoxDecoration(
// //         color: Colors.grey[50],
// //         borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //         border: Border.all(color: Colors.grey[300]!),
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             'تفاصيل السعر المختار',
// //             style: TextStyle(
// //               fontSize: isMobile ? 16 : 18,
// //               fontWeight: FontWeight.bold,
// //               color: Colors.blue[800],
// //             ),
// //           ),
// //           SizedBox(height: 8),

// //           // صفوف الأسعار
// //           isMobile
// //               ? Column(
// //                   children: [
// //                     _buildPriceDetailCard(
// //                       'نولون الشركة',
// //                       '${_selectedPriceOffer!['nolon'] ?? 0} ج',
// //                       Colors.blue,
// //                       Icons.business,
// //                       isMobile,
// //                     ),
// //                     SizedBox(height: 8),
// //                     _buildPriceDetailCard(
// //                       'مبيت الشركة',
// //                       '${_selectedPriceOffer!['companyOvernight'] ?? 0} ج',
// //                       Colors.orange,
// //                       Icons.hotel,
// //                       isMobile,
// //                     ),
// //                     SizedBox(height: 8),
// //                     _buildPriceDetailCard(
// //                       'عطلة الشركة',
// //                       '${_selectedPriceOffer!['companyHoliday'] ?? 0} ج',
// //                       Colors.red,
// //                       Icons.celebration,
// //                       isMobile,
// //                     ),
// //                     SizedBox(height: 8),
// //                     _buildPriceDetailCard(
// //                       'نولون العجلات',
// //                       '${_selectedPriceOffer!['wheelNolon'] ?? 0} ج',
// //                       Colors.green,
// //                       Icons.directions_car,
// //                       isMobile,
// //                     ),
// //                     SizedBox(height: 8),
// //                     _buildPriceDetailCard(
// //                       'مبيت العجلات',
// //                       '${_selectedPriceOffer!['wheelOvernight'] ?? 0} ج',
// //                       Colors.purple,
// //                       Icons.night_shelter,
// //                       isMobile,
// //                     ),
// //                     SizedBox(height: 8),
// //                     _buildPriceDetailCard(
// //                       'عطلة العجلات',
// //                       '${_selectedPriceOffer!['wheelHoliday'] ?? 0} ج',
// //                       Colors.teal,
// //                       Icons.event,
// //                       isMobile,
// //                     ),
// //                   ],
// //                 )
// //               : GridView.count(
// //                   shrinkWrap: true,
// //                   physics: const NeverScrollableScrollPhysics(),
// //                   crossAxisCount: 3,
// //                   crossAxisSpacing: 8,
// //                   mainAxisSpacing: 8,
// //                   childAspectRatio: 2.5,
// //                   children: [
// //                     _buildPriceDetailCard(
// //                       'نولون الشركة',
// //                       '${_selectedPriceOffer!['nolon'] ?? 0} ج',
// //                       Colors.blue,
// //                       Icons.business,
// //                       isMobile,
// //                     ),
// //                     _buildPriceDetailCard(
// //                       'مبيت الشركة',
// //                       '${_selectedPriceOffer!['companyOvernight'] ?? 0} ج',
// //                       Colors.orange,
// //                       Icons.hotel,
// //                       isMobile,
// //                     ),
// //                     _buildPriceDetailCard(
// //                       'عطلة الشركة',
// //                       '${_selectedPriceOffer!['companyHoliday'] ?? 0} ج',
// //                       Colors.red,
// //                       Icons.celebration,
// //                       isMobile,
// //                     ),
// //                     _buildPriceDetailCard(
// //                       'نولون العجلات',
// //                       '${_selectedPriceOffer!['wheelNolon'] ?? 0} ج',
// //                       Colors.green,
// //                       Icons.directions_car,
// //                       isMobile,
// //                     ),
// //                     _buildPriceDetailCard(
// //                       'مبيت العجلات',
// //                       '${_selectedPriceOffer!['wheelOvernight'] ?? 0} ج',
// //                       Colors.purple,
// //                       Icons.night_shelter,
// //                       isMobile,
// //                     ),
// //                     _buildPriceDetailCard(
// //                       'عطلة العجلات',
// //                       '${_selectedPriceOffer!['wheelHoliday'] ?? 0} ج',
// //                       Colors.teal,
// //                       Icons.event,
// //                       isMobile,
// //                     ),
// //                   ],
// //                 ),

// //           // معلومات إضافية
// //           SizedBox(height: 12),
// //           Divider(color: Colors.grey[300]),
// //           SizedBox(height: 8),
// //           _buildPriceDetailRow(
// //             'نوع السيارة:',
// //             _selectedPriceOffer!['vehicleType'] ?? '',
// //             isMobile,
// //           ),
// //           _buildPriceDetailRow(
// //             'ملاحظات:',
// //             _selectedPriceOffer!['notes'] ?? 'لا توجد ملاحظات',
// //             isMobile,
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildDriverNameField(bool isMobile) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'اسم السائق',
// //           style: TextStyle(
// //             fontSize: isMobile ? 14 : 16,
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //           ),
// //         ),
// //         SizedBox(height: isMobile ? 6 : 8),
// //         Container(
// //           decoration: BoxDecoration(
// //             borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //           ),
// //           child: Column(
// //             children: [
// //               TextFormField(
// //                 controller: _driverNameController,
// //                 onChanged: _onDriverNameChanged,
// //                 style: TextStyle(fontSize: isMobile ? 14 : 16),
// //                 decoration: InputDecoration(
// //                   prefixIcon: Icon(
// //                     Icons.person,
// //                     color: const Color(0xFF3498DB),
// //                   ),
// //                   filled: true,
// //                   fillColor: Colors.white,
// //                   border: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //                     borderSide: const BorderSide(color: Color(0xFF3498DB)),
// //                   ),
// //                   contentPadding: EdgeInsets.symmetric(
// //                     horizontal: isMobile ? 12 : 16,
// //                     vertical: isMobile ? 12 : 16,
// //                   ),
// //                   hintText: 'اكتب اسم السائق',
// //                   suffixIcon: _isLoadingSuggestions
// //                       ? Padding(
// //                           padding: const EdgeInsets.all(8.0),
// //                           child: SizedBox(
// //                             width: 16,
// //                             height: 16,
// //                             child: CircularProgressIndicator(strokeWidth: 2),
// //                           ),
// //                         )
// //                       : null,
// //                 ),
// //                 validator: (value) {
// //                   if (value == null || value.isEmpty) {
// //                     return 'هذا الحقل مطلوب';
// //                   }
// //                   return null;
// //                 },
// //               ),
// //               // عرض قائمة الاقتراحات
// //               if (_driverSuggestions.isNotEmpty &&
// //                   _driverNameController.text.isNotEmpty)
// //                 Container(
// //                   margin: EdgeInsets.only(top: 4),
// //                   decoration: BoxDecoration(
// //                     color: Colors.white,
// //                     borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //                     border: Border.all(color: Colors.grey[300]!),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: Colors.black12,
// //                         blurRadius: 4,
// //                         offset: Offset(0, 2),
// //                       ),
// //                     ],
// //                   ),
// //                   child: Column(
// //                     children: _driverSuggestions
// //                         .map(
// //                           (suggestion) => ListTile(
// //                             leading: Icon(
// //                               Icons.person_outline,
// //                               color: Colors.blue,
// //                               size: 20,
// //                             ),
// //                             title: Text(
// //                               suggestion,
// //                               style: TextStyle(fontSize: isMobile ? 14 : 16),
// //                             ),
// //                             dense: true,
// //                             visualDensity: VisualDensity.compact,
// //                             contentPadding: EdgeInsets.symmetric(
// //                               horizontal: 12,
// //                             ),
// //                             onTap: () {
// //                               setState(() {
// //                                 _driverNameController.text = suggestion;
// //                                 _driverSuggestions.clear();
// //                               });
// //                             },
// //                           ),
// //                         )
// //                         .toList(),
// //                   ),
// //                 ),
// //             ],
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildCompanyDropdown(bool isMobile) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'اختر الشركة',
// //           style: TextStyle(
// //             fontSize: isMobile ? 14 : 16,
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //           ),
// //         ),
// //         SizedBox(height: isMobile ? 6 : 8),
// //         Container(
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //             border: Border.all(color: const Color(0xFF3498DB)),
// //           ),
// //           child: _isLoading
// //               ? Padding(
// //                   padding: EdgeInsets.symmetric(
// //                     horizontal: isMobile ? 12 : 16,
// //                     vertical: isMobile ? 12 : 16,
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       SizedBox(
// //                         width: isMobile ? 16 : 20,
// //                         height: isMobile ? 16 : 20,
// //                         child: const CircularProgressIndicator(strokeWidth: 2),
// //                       ),
// //                       SizedBox(width: isMobile ? 8 : 12),
// //                       Text(
// //                         'جاري تحميل الشركات...',
// //                         style: TextStyle(fontSize: isMobile ? 14 : 16),
// //                       ),
// //                     ],
// //                   ),
// //                 )
// //               : DropdownButtonHideUnderline(
// //                   child: DropdownButton<String>(
// //                     value: _selectedCompanyId,
// //                     isExpanded: true,
// //                     hint: Padding(
// //                       padding: EdgeInsets.symmetric(
// //                         horizontal: isMobile ? 12 : 16,
// //                       ),
// //                       child: Text(
// //                         'اختر شركة',
// //                         style: TextStyle(fontSize: isMobile ? 14 : 16),
// //                       ),
// //                     ),
// //                     items: _companies.map((company) {
// //                       final data = company.data();
// //                       final companyName = data['companyName'] ?? '';
// //                       return DropdownMenuItem<String>(
// //                         value: company.id,
// //                         child: Padding(
// //                           padding: EdgeInsets.symmetric(
// //                             horizontal: isMobile ? 12 : 16,
// //                           ),
// //                           child: Text(
// //                             companyName,
// //                             style: TextStyle(fontSize: isMobile ? 14 : 16),
// //                             overflow: TextOverflow.ellipsis,
// //                           ),
// //                         ),
// //                       );
// //                     }).toList(),
// //                     onChanged: (String? newValue) {
// //                       setState(() {
// //                         _selectedCompanyId = newValue;
// //                         _selectedCompanyName = _companies
// //                             .firstWhere((company) => company.id == newValue)
// //                             .data()['companyName'];
// //                         _priceOffers.clear();
// //                         _selectedPriceOffer = null;

// //                         if (newValue != null) {
// //                           _loadPriceOffers(newValue);
// //                         }
// //                       });
// //                     },
// //                   ),
// //                 ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildPriceOffersDropdown(bool isMobile) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'اسم الموقع',
// //           style: TextStyle(
// //             fontSize: isMobile ? 14 : 16,
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //           ),
// //         ),
// //         SizedBox(height: isMobile ? 6 : 8),

// //         Container(
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //             border: Border.all(color: Colors.orange),
// //           ),
// //           child: ExpansionTile(
// //             title: Row(
// //               children: [
// //                 Icon(Icons.map, color: Colors.orange, size: isMobile ? 20 : 24),
// //                 SizedBox(width: 8),
// //                 Expanded(
// //                   child: _selectedPriceOffer != null
// //                       ? Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Text(
// //                               '${_selectedPriceOffer!['unloadingLocation']}',
// //                               style: TextStyle(
// //                                 fontSize: isMobile ? 14 : 16,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.green[700],
// //                               ),
// //                             ),
// //                           ],
// //                         )
// //                       : Text(
// //                           'اختر موقع من القائمة',
// //                           style: TextStyle(
// //                             fontSize: isMobile ? 14 : 16,
// //                             color: Colors.grey[600],
// //                           ),
// //                         ),
// //                 ),
// //               ],
// //             ),
// //             trailing: Icon(
// //               _isDropdownOpen ? Icons.expand_less : Icons.expand_more,
// //               color: Colors.orange,
// //             ),
// //             onExpansionChanged: (expanded) {
// //               setState(() {
// //                 _isDropdownOpen = expanded;
// //               });

// //               if (expanded &&
// //                   _selectedCompanyId != null &&
// //                   _priceOffers.isEmpty) {
// //                 _loadPriceOffers(_selectedCompanyId!);
// //               }
// //             },
// //             children: [
// //               if (_selectedCompanyId == null)
// //                 Padding(
// //                   padding: EdgeInsets.all(16),
// //                   child: Text(
// //                     'يرجى اختيار شركة أولاً',
// //                     style: TextStyle(color: Colors.grey),
// //                     textAlign: TextAlign.center,
// //                   ),
// //                 )
// //               else if (_priceOffers.isEmpty)
// //                 Padding(
// //                   padding: EdgeInsets.all(16),
// //                   child: Text(
// //                     'لا توجد عروض أسعار لهذه الشركة',
// //                     style: TextStyle(color: Colors.grey),
// //                     textAlign: TextAlign.center,
// //                   ),
// //                 )
// //               else
// //                 ..._priceOffers.map((offer) {
// //                   return Container(
// //                     decoration: BoxDecoration(
// //                       border: Border(top: BorderSide(color: Colors.grey[200]!)),
// //                     ),
// //                     child: ListTile(
// //                       leading: Icon(Icons.route, color: Colors.blue),
// //                       title: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             '${offer['unloadingLocation']}',
// //                             style: TextStyle(
// //                               fontSize: isMobile ? 14 : 16,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       trailing:
// //                           _selectedPriceOffer != null &&
// //                               _selectedPriceOffer!['offerId'] ==
// //                                   offer['offerId']
// //                           ? Icon(Icons.check_circle, color: Colors.green)
// //                           : null,
// //                       onTap: () {
// //                         _selectPriceOffer(offer);
// //                       },
// //                       dense: true,
// //                     ),
// //                   );
// //                 }).toList(),
// //             ],
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildPriceDetailCard(
// //     String title,
// //     String value,
// //     Color color,
// //     IconData icon,
// //     bool isMobile,
// //   ) {
// //     return Container(
// //       padding: EdgeInsets.all(isMobile ? 8 : 10),
// //       decoration: BoxDecoration(
// //         color: color.withOpacity(0.1),
// //         borderRadius: BorderRadius.circular(8),
// //         border: Border.all(color: color.withOpacity(0.3)),
// //       ),
// //       child: Column(
// //         children: [
// //           Row(
// //             children: [
// //               Icon(icon, color: color, size: isMobile ? 16 : 18),
// //               SizedBox(width: 4),
// //               Expanded(
// //                 child: Text(
// //                   title,
// //                   style: TextStyle(
// //                     fontSize: isMobile ? 11 : 12,
// //                     color: color,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                   overflow: TextOverflow.ellipsis,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           SizedBox(height: 4),
// //           Text(
// //             value,
// //             style: TextStyle(
// //               fontSize: isMobile ? 14 : 16,
// //               fontWeight: FontWeight.bold,
// //               color: color,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildPriceDetailRow(String label, String value, bool isMobile) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 4),
// //       child: Row(
// //         children: [
// //           Text(
// //             label,
// //             style: TextStyle(
// //               fontSize: isMobile ? 12 : 14,
// //               color: Colors.grey[700],
// //             ),
// //           ),
// //           SizedBox(width: 8),
// //           Expanded(
// //             child: Text(
// //               value,
// //               style: TextStyle(
// //                 fontSize: isMobile ? 12 : 14,
// //                 fontWeight: FontWeight.w500,
// //               ),
// //               textAlign: TextAlign.left,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildDateField(bool isMobile) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'التاريخ',
// //           style: TextStyle(
// //             fontSize: isMobile ? 14 : 16,
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //           ),
// //         ),
// //         SizedBox(height: isMobile ? 6 : 8),
// //         InkWell(
// //           onTap: () => _selectDate(context),
// //           child: Container(
// //             padding: EdgeInsets.symmetric(
// //               horizontal: isMobile ? 12 : 16,
// //               vertical: isMobile ? 12 : 16,
// //             ),
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //               border: Border.all(color: const Color(0xFF3498DB)),
// //             ),
// //             child: Row(
// //               children: [
// //                 Icon(
// //                   Icons.calendar_today,
// //                   color: const Color(0xFF3498DB),
// //                   size: isMobile ? 18 : 24,
// //                 ),
// //                 SizedBox(width: isMobile ? 8 : 12),
// //                 Text(
// //                   _formatDate(_selectedDate),
// //                   style: TextStyle(fontSize: isMobile ? 14 : 16),
// //                 ),
// //                 const Spacer(),
// //                 Text(
// //                   'اختر التاريخ',
// //                   style: TextStyle(
// //                     color: Colors.grey,
// //                     fontSize: isMobile ? 12 : 14,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildField({
// //     required TextEditingController controller,
// //     required String label,
// //     required IconData icon,
// //     required String? Function(String?)? validator,
// //     required bool isMobile,
// //   }) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           label,
// //           style: TextStyle(
// //             fontSize: isMobile ? 14 : 16,
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //           ),
// //         ),
// //         SizedBox(height: isMobile ? 6 : 8),
// //         TextFormField(
// //           controller: controller,
// //           style: TextStyle(fontSize: isMobile ? 14 : 16),
// //           decoration: InputDecoration(
// //             prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
// //             filled: true,
// //             fillColor: Colors.white,
// //             border: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //               borderSide: const BorderSide(color: Color(0xFF3498DB)),
// //             ),
// //             contentPadding: EdgeInsets.symmetric(
// //               horizontal: isMobile ? 12 : 16,
// //               vertical: isMobile ? 12 : 16,
// //             ),
// //           ),
// //           validator: validator,
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildActionButtons(bool isMobile) {
// //     return SizedBox(
// //       width: double.infinity,
// //       child: ElevatedButton(
// //         onPressed: _isSaving ? null : _saveDailyWork,
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: const Color(0xFF2E86C1),
// //           padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 18),
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //           ),
// //         ),
// //         child: _isSaving
// //             ? SizedBox(
// //                 width: isMobile ? 20 : 24,
// //                 height: isMobile ? 20 : 24,
// //                 child: const CircularProgressIndicator(color: Colors.white),
// //               )
// //             : Text(
// //                 'حفظ الشغل اليومى',
// //                 style: TextStyle(
// //                   fontSize: isMobile ? 16 : 18,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.white,
// //                 ),
// //               ),
// //       ),
// //     );
// //   }

// //   String _formatDate(DateTime date) {
// //     return '${date.day}/${date.month}/${date.year}';
// //   }

// //   @override
// //   void dispose() {
// //     _debounce?.cancel();
// //     _contractorController.dispose();
// //     _trController.dispose();
// //     _notesController.dispose();
// //     _driverNameController.dispose();
// //     _loadingLocationController.dispose();
// //     _unloadingLocationController.dispose();
// //     _ohdaController.dispose();
// //     _kartaController.dispose();
// //     super.dispose();
// //   }
// // // }
// // import 'dart:async';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:last/models/models.dart';

// // class DailyWorkPage extends StatefulWidget {
// //   const DailyWorkPage({super.key});

// //   @override
// //   State<DailyWorkPage> createState() => _DailyWorkPageState();
// // }

// // class _DailyWorkPageState extends State<DailyWorkPage> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   final _formKey = GlobalKey<FormState>();

// //   // 1. بيانات الشركة
// //   List<QueryDocumentSnapshot<Map<String, dynamic>>> _companies = [];
// //   String? _selectedCompanyId;
// //   String? _selectedCompanyName;

// //   // 2. التاريخ
// //   DateTime _selectedDate = DateTime.now();

// //   // الحقول الجديدة
// //   final TextEditingController _contractorController = TextEditingController();
// //   final TextEditingController _trController = TextEditingController();
// //   final TextEditingController _notesController = TextEditingController();

// //   // 3-8. الحقول اليدوية
// //   final TextEditingController _driverNameController = TextEditingController();
// //   final TextEditingController _loadingLocationController =
// //       TextEditingController();
// //   final TextEditingController _unloadingLocationController =
// //       TextEditingController();
// //   final TextEditingController _ohdaController = TextEditingController();
// //   final TextEditingController _kartaController = TextEditingController();

// //   // حالة التحميل والحفظ
// //   bool _isLoading = true;
// //   bool _isSaving = false;

// //   // 9-13. عروض الأسعار
// //   List<Map<String, dynamic>> _priceOffers = [];
// //   Map<String, dynamic>? _selectedPriceOffer;
// //   bool _isDropdownOpen = false;

// //   // اقتراحات أسماء السائقين
// //   List<String> _driverSuggestions = [];
// //   bool _isLoadingSuggestions = false;
// //   Timer? _debounce;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadCompanies();
// //   }

// //   Future<void> _loadCompanies() async {
// //     try {
// //       final snapshot = await _firestore.collection('companies').get();
// //       setState(() {
// //         _companies = snapshot.docs;
// //         _isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() => _isLoading = false);
// //       _showError('خطأ في تحميل الشركات: $e');
// //     }
// //   }

// //   Future<void> _loadPriceOffers(String companyId) async {
// //     if (companyId.isEmpty) return;

// //     try {
// //       final snapshot = await _firestore
// //           .collection('companies')
// //           .doc(companyId)
// //           .collection('priceOffers')
// //           .get();

// //       List<Map<String, dynamic>> allTransportations = [];

// //       for (final offerDoc in snapshot.docs) {
// //         final offerData = offerDoc.data();
// //         final transportations = offerData['transportations'] as List? ?? [];

// //         for (final transport in transportations) {
// //           final transportMap = transport as Map<String, dynamic>;

// //           allTransportations.add({
// //             'offerId': offerDoc.id,
// //             'loadingLocation': transportMap['loadingLocation'] ?? '',
// //             'unloadingLocation': transportMap['unloadingLocation'] ?? '',
// //             'vehicleType': transportMap['vehicleType'] ?? '',
// //             'nolon': (transportMap['nolon'] ?? transportMap['noLon'] ?? 0.0)
// //                 .toDouble(),
// //             'wheelNolon':
// //                 (transportMap['wheelNolon'] ??
// //                         transportMap['wheelNoLon'] ??
// //                         0.0)
// //                     .toDouble(),
// //             'companyOvernight': (transportMap['companyOvernight'] ?? 0.0)
// //                 .toDouble(),
// //             'companyHoliday': (transportMap['companyHoliday'] ?? 0.0)
// //                 .toDouble(),
// //             'wheelOvernight': (transportMap['wheelOvernight'] ?? 0.0)
// //                 .toDouble(),
// //             'wheelHoliday': (transportMap['wheelHoliday'] ?? 0.0).toDouble(),
// //             'notes': transportMap['notes'] ?? '',
// //           });
// //         }
// //       }

// //       setState(() {
// //         _priceOffers = allTransportations;
// //       });
// //     } catch (e) {
// //       print('خطأ في تحميل عروض الأسعار: $e');
// //     }
// //   }

// //   Future<List<String>> _fetchDriverSuggestions(String query) async {
// //     if (query.isEmpty) return [];

// //     try {
// //       final snapshot = await _firestore
// //           .collection('dailyWork')
// //           .where('driverName', isGreaterThanOrEqualTo: query)
// //           .where('driverName', isLessThan: query + 'z')
// //           .orderBy('driverName')
// //           .limit(10)
// //           .get();

// //       final names = snapshot.docs
// //           .map((doc) => doc.data()['driverName'] as String? ?? '')
// //           .where((name) => name.toLowerCase().contains(query.toLowerCase()))
// //           .toSet()
// //           .toList();

// //       return names;
// //     } catch (e) {
// //       print('خطأ في جلب اقتراحات السائقين: $e');
// //       return [];
// //     }
// //   }

// //   void _onDriverNameChanged(String value) {
// //     if (_debounce?.isActive ?? false) _debounce?.cancel();

// //     _debounce = Timer(const Duration(milliseconds: 300), () async {
// //       if (value.isNotEmpty && value.length >= 2) {
// //         setState(() => _isLoadingSuggestions = true);
// //         final suggestions = await _fetchDriverSuggestions(value);
// //         setState(() {
// //           _driverSuggestions = suggestions;
// //           _isLoadingSuggestions = false;
// //         });
// //       } else {
// //         setState(() => _driverSuggestions.clear());
// //       }
// //     });
// //   }

// //   Future<double> _getTreasuryBalance() async {
// //     try {
// //       // مجموع الإيرادات المصروفة
// //       final incomeSnapshot = await _firestore
// //           .collection('treasury_entries')
// //           .where('isCleared', isEqualTo: true)
// //           .get();

// //       double totalIncome = 0;
// //       for (var doc in incomeSnapshot.docs) {
// //         final amount = doc.data()['amount'];
// //         if (amount != null) {
// //           totalIncome += (amount as num).toDouble();
// //         }
// //       }

// //       // مجموع المصروفات
// //       final expenseSnapshot = await _firestore
// //           .collection('treasury_exits')
// //           .get();

// //       double totalExpense = 0;
// //       for (var doc in expenseSnapshot.docs) {
// //         final amount = doc.data()['amount'];
// //         if (amount != null) {
// //           totalExpense += (amount as num).toDouble();
// //         }
// //       }

// //       return totalIncome - totalExpense;
// //     } catch (e) {
// //       print('Error loading treasury balance: $e');
// //       return 0.0;
// //     }
// //   }

// //   Future<void> _addExpenseForOhda() async {
// //     try {
// //       final amountText = _ohdaController.text.trim();

// //       if (amountText.isEmpty) {
// //         print('لا توجد قيمة للعهدة');
// //         return;
// //       }

// //       final amount = double.tryParse(amountText);
// //       if (amount == null || amount <= 0) {
// //         print('قيمة العهدة غير صالحة: $amountText');
// //         return;
// //       }

// //       // التحقق من رصيد الخزنة
// //       final balance = await _getTreasuryBalance();
// //       if (amount > balance) {
// //         _showError(
// //           'قيمة العهدة (${amount} ج) أكبر من الرصيد المتاح (${balance.toStringAsFixed(2)} ج) في الخزنة',
// //         );
// //         return;
// //       }

// //       final expenseData = {
// //         'amount': amount,
// //         'category': 'خرج',
// //         'createdAt': Timestamp.now(),
// //         'date': Timestamp.now(),
// //         'description':
// //             'عهدة لـ ${_driverNameController.text.trim()} - ${_loadingLocationController.text.trim()} إلى ${_unloadingLocationController.text.trim()}',
// //         'expenseType': 'عهده',
// //         'recipient': _driverNameController.text.trim(),
// //         'status': 'مكتمل',
// //         'relatedTo': 'dailyWork',
// //         'driverName': _driverNameController.text.trim(),
// //         'companyName': _selectedCompanyName ?? '',
// //         'loadingLocation': _loadingLocationController.text.trim(),
// //         'unloadingLocation': _unloadingLocationController.text.trim(),
// //         'contractor': _contractorController.text.trim(),
// //       };

// //       await _firestore.collection('treasury_exits').add(expenseData);

// //       print('تم حفظ العهدة في الخزنة بمبلغ: $amount');
// //     } catch (e) {
// //       print('خطأ في حفظ العهدة في الخزنة: $e');
// //       _showError('خطأ في حفظ العهدة في الخزنة: $e');
// //     }
// //   }

// //   void _showError(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text(message), backgroundColor: Colors.red),
// //     );
// //   }

// //   void _showSuccess(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text(message), backgroundColor: Colors.green),
// //     );
// //   }

// //   Future<void> _selectDate(BuildContext context) async {
// //     final DateTime? picked = await showDatePicker(
// //       context: context,
// //       initialDate: _selectedDate,
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime(2030),
// //     );
// //     if (picked != null && picked != _selectedDate) {
// //       setState(() {
// //         _selectedDate = picked;
// //       });
// //     }
// //   }

// //   void _selectPriceOffer(Map<String, dynamic> offer) {
// //     setState(() {
// //       _selectedPriceOffer = offer;
// //       _isDropdownOpen = false;
// //     });
// //   }

// //   Future<void> _saveDailyWork() async {
// //     if (_selectedCompanyId == null) {
// //       _showError('يرجى اختيار شركة');
// //       return;
// //     }

// //     if (_selectedPriceOffer == null) {
// //       _showError('يرجى اختيار موقع من عروض الأسعار');
// //       return;
// //     }

// //     if (!_formKey.currentState!.validate()) return;

// //     setState(() => _isSaving = true);

// //     try {
// //       final dailyWork = DailyWork(
// //         companyId: _selectedCompanyId!,
// //         companyName: _selectedCompanyName!,
// //         date: _selectedDate,
// //         contractor: _contractorController.text.trim(),
// //         tr: _trController.text.trim(),
// //         driverName: _driverNameController.text.trim(),
// //         loadingLocation: _loadingLocationController.text.trim(),
// //         unloadingLocation: _unloadingLocationController.text.trim(),
// //         ohda: _ohdaController.text.trim(),
// //         karta: _kartaController.text.trim(),
// //         selectedRoute: '${_selectedPriceOffer!['unloadingLocation']}',
// //         selectedPrice: _selectedPriceOffer!['nolon'] ?? 0.0,
// //         wheelNolon: _selectedPriceOffer!['wheelNolon'] ?? 0.0,
// //         selectedVehicleType: _selectedPriceOffer!['vehicleType'] ?? '',
// //         selectedNotes: _notesController.text.trim(),
// //         priceOfferId: _selectedPriceOffer!['offerId'] ?? '',
// //         wheelOvernight: 0,
// //         wheelHoliday: 0,
// //         companyOvernight: 0,
// //         companyHoliday: 0,
// //         nolon: _selectedPriceOffer!['nolon'] ?? 0.0,
// //         createdAt: DateTime.now(),
// //         updatedAt: DateTime.now(),
// //       );

// //       // حفظ الشغل اليومي
// //       final dailyWorkRef = await _firestore
// //           .collection('dailyWork')
// //           .add(dailyWork.toMap());

// //       // حفظ نسخة في قسم السائقين
// //       final driverWorkData = {
// //         'dailyWorkId': dailyWorkRef.id,
// //         'companyId': _selectedCompanyId!,
// //         'companyName': _selectedCompanyName!,
// //         'date': _selectedDate,
// //         'contractor': _contractorController.text.trim(),
// //         'tr': _trController.text.trim(),
// //         'driverName': _driverNameController.text.trim(),
// //         'loadingLocation': _loadingLocationController.text.trim(),
// //         'unloadingLocation': _unloadingLocationController.text.trim(),
// //         'ohda': _ohdaController.text.trim(),
// //         'karta': _kartaController.text.trim(),
// //         'selectedRoute': '${_selectedPriceOffer!['unloadingLocation']}',
// //         'selectedPrice': _selectedPriceOffer!['nolon'] ?? 0.0,
// //         'wheelNolon': _selectedPriceOffer!['wheelNolon'] ?? 0.0,
// //         'selectedVehicleType': _selectedPriceOffer!['vehicleType'] ?? '',
// //         'selectedNotes': _notesController.text.trim(),
// //         'priceOfferId': _selectedPriceOffer!['offerId'] ?? '',
// //         'wheelOvernight': 0,
// //         'wheelHoliday': 0,
// //         'companyOvernight': 0,
// //         'companyHoliday': 0,
// //         'nolon': _selectedPriceOffer!['nolon'] ?? 0.0,
// //         'isPaid': false,
// //         'paidAmount': 0.0,
// //         'remainingAmount': _selectedPriceOffer!['wheelNolon'] ?? 0.0,
// //         'paymentDate': null,
// //         'driverNotes': '',
// //         'createdAt': DateTime.now(),
// //         'updatedAt': DateTime.now(),
// //       };

// //       await _firestore.collection('drivers').add(driverWorkData);

// //       // إضافة العهدة إلى الخارج من الخزنة
// //       await _addExpenseForOhda();

// //       _showSuccess(
// //         'تم حفظ الشغل اليومي بنجاح وحفظ نسخة في قسم السائقين وإضافة العهدة للخزنة',
// //       );
// //       _clearForm();
// //     } catch (e) {
// //       _showError('خطأ في الحفظ: $e');
// //     } finally {
// //       setState(() => _isSaving = false);
// //     }
// //   }

// //   // دالة لبناء حقل TR اختياري
// //   Widget _buildOptionalTRField(bool isMobile) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'TR (اختياري)',
// //           style: TextStyle(
// //             fontSize: isMobile ? 14 : 16,
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //           ),
// //         ),
// //         SizedBox(height: isMobile ? 6 : 8),
// //         TextFormField(
// //           controller: _trController,
// //           style: TextStyle(fontSize: isMobile ? 14 : 16),
// //           decoration: InputDecoration(
// //             prefixIcon: Icon(Icons.numbers, color: const Color(0xFF3498DB)),
// //             filled: true,
// //             fillColor: Colors.white,
// //             border: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //               borderSide: const BorderSide(color: Color(0xFF3498DB)),
// //             ),
// //             contentPadding: EdgeInsets.symmetric(
// //               horizontal: isMobile ? 12 : 16,
// //               vertical: isMobile ? 12 : 16,
// //             ),
// //             hintText: 'أدخل قيمة TR (اختياري)',
// //           ),
// //           // لا يوجد validator هنا، مما يجعله اختيارياً
// //         ),
// //       ],
// //     );
// //   }

// //   void _clearForm() {
// //     setState(() {
// //       _selectedCompanyId = null;
// //       _selectedCompanyName = null;
// //       _selectedDate = DateTime.now();
// //       _selectedPriceOffer = null;
// //       _priceOffers.clear();
// //       _contractorController.clear();
// //       _trController.clear();
// //       _notesController.clear();
// //       _driverNameController.clear();
// //       _loadingLocationController.clear();
// //       _unloadingLocationController.clear();
// //       _ohdaController.clear();
// //       _kartaController.clear();
// //       _driverSuggestions.clear();
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF4F6F8),
// //       body: LayoutBuilder(
// //         builder: (context, constraints) {
// //           bool isMobile = constraints.maxWidth < 600;

// //           return Column(
// //             children: [
// //               _buildCustomAppBar(isMobile),
// //               Expanded(
// //                 child: SingleChildScrollView(
// //                   padding: EdgeInsets.all(isMobile ? 16 : 24),
// //                   child: Center(
// //                     child: ConstrainedBox(
// //                       constraints: const BoxConstraints(maxWidth: 800),
// //                       child: Column(
// //                         children: [
// //                           Card(
// //                             elevation: 8,
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(
// //                                 isMobile ? 16 : 22,
// //                               ),
// //                             ),
// //                             child: Padding(
// //                               padding: EdgeInsets.all(isMobile ? 16 : 32),
// //                               child: Form(
// //                                 key: _formKey,
// //                                 child: Column(
// //                                   children: [
// //                                     SizedBox(height: isMobile ? 8 : 16),
// //                                     _buildHeaderSection(isMobile),
// //                                     SizedBox(height: isMobile ? 16 : 32),
// //                                     _buildDailyWorkForm(isMobile),
// //                                     SizedBox(height: isMobile ? 20 : 40),
// //                                     _buildActionButtons(isMobile),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           );
// //         },
// //       ),
// //     );
// //   }

// //   Widget _buildCustomAppBar(bool isMobile) {
// //     return Container(
// //       padding: EdgeInsets.symmetric(
// //         horizontal: isMobile ? 16 : 24,
// //         vertical: isMobile ? 12 : 20,
// //       ),
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
// //         child: Row(
// //           children: [
// //             Icon(Icons.work, color: Colors.white, size: isMobile ? 24 : 32),
// //             SizedBox(width: isMobile ? 8 : 12),
// //             Text(
// //               'الشغل اليومي',
// //               style: TextStyle(
// //                 color: Colors.white,
// //                 fontSize: isMobile ? 18 : 24,
// //                 fontWeight: FontWeight.bold,
// //                 fontFamily: 'Cairo',
// //               ),
// //             ),
// //             const Spacer(),
// //             _buildTimeWidget(),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildTimeWidget() {
// //     return StreamBuilder<DateTime>(
// //       stream: Stream.periodic(
// //         const Duration(seconds: 1),
// //         (_) => DateTime.now(),
// //       ),
// //       builder: (context, snapshot) {
// //         final now = snapshot.data ?? DateTime.now();
// //         int hour12 = now.hour % 12;
// //         if (hour12 == 0) hour12 = 12;

// //         return Column(
// //           crossAxisAlignment: CrossAxisAlignment.center,
// //           children: [
// //             Container(
// //               height: 50,
// //               width: 150,
// //               decoration: BoxDecoration(
// //                 color: Colors.transparent,
// //                 borderRadius: BorderRadius.circular(16),
// //               ),
// //               child: Center(
// //                 child: Text(
// //                   '${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ',
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 36,
// //                     fontWeight: FontWeight.bold,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildHeaderSection(bool isMobile) {
// //     return Column(
// //       children: [
// //         Text(
// //           'تسجيل الشغل اليومي',
// //           style: TextStyle(
// //             fontSize: isMobile ? 20 : 24,
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //           ),
// //           textAlign: TextAlign.center,
// //         ),
// //         SizedBox(height: 8),
// //         Text(
// //           'أدخل بيانات الشغل اليومي للشركة',
// //           style: TextStyle(
// //             fontSize: isMobile ? 14 : 16,
// //             color: Colors.grey[600],
// //           ),
// //           textAlign: TextAlign.center,
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildDailyWorkForm(bool isMobile) {
// //     return Column(
// //       children: [
// //         // 1. اختيار الشركة
// //         _buildCompanyDropdown(isMobile),
// //         SizedBox(height: isMobile ? 16 : 20),

// //         // 2. اختيار التاريخ
// //         _buildDateField(isMobile),
// //         SizedBox(height: isMobile ? 16 : 20),

// //         // الحقول: المقاول و TR
// //         isMobile
// //             ? Column(
// //                 children: [
// //                   _buildField(
// //                     controller: _contractorController,
// //                     label: 'المقاول',
// //                     icon: Icons.business,
// //                     validator: (value) {
// //                       if (value == null || value.isEmpty) {
// //                         return 'هذا الحقل مطلوب';
// //                       }
// //                       return null;
// //                     },
// //                     isMobile: isMobile,
// //                   ),
// //                   SizedBox(height: 16),
// //                   _buildOptionalTRField(isMobile),
// //                 ],
// //               )
// //             : Row(
// //                 children: [
// //                   Expanded(
// //                     child: _buildField(
// //                       controller: _contractorController,
// //                       label: 'المقاول',
// //                       icon: Icons.business,
// //                       validator: (value) {
// //                         if (value == null || value.isEmpty) {
// //                           return 'هذا الحقل مطلوب';
// //                         }
// //                         return null;
// //                       },
// //                       isMobile: isMobile,
// //                     ),
// //                   ),
// //                   SizedBox(width: 16),
// //                   Expanded(child: _buildOptionalTRField(isMobile)),
// //                 ],
// //               ),
// //         SizedBox(height: isMobile ? 16 : 20),

// //         // 3. اسم السائق مع الاقتراح التلقائي
// //         _buildDriverNameField(isMobile),
// //         SizedBox(height: isMobile ? 16 : 20),

// //         // 4. مكان التحميل (يدوي)
// //         // 5. مكان التعتيق (يدوي)
// //         isMobile
// //             ? Column(
// //                 children: [
// //                   _buildField(
// //                     controller: _loadingLocationController,
// //                     label: 'مكان التحميل',
// //                     icon: Icons.location_on,
// //                     validator: (value) {
// //                       if (value == null || value.isEmpty) {
// //                         return 'هذا الحقل مطلوب';
// //                       }
// //                       return null;
// //                     },
// //                     isMobile: isMobile,
// //                   ),
// //                   SizedBox(height: 16),
// //                   _buildField(
// //                     controller: _unloadingLocationController,
// //                     label: 'مكان التعتيق',
// //                     icon: Icons.location_on,
// //                     validator: (value) {
// //                       if (value == null || value.isEmpty) {
// //                         return 'هذا الحقل مطلوب';
// //                       }
// //                       return null;
// //                     },
// //                     isMobile: isMobile,
// //                   ),
// //                 ],
// //               )
// //             : Row(
// //                 children: [
// //                   Expanded(
// //                     child: _buildField(
// //                       controller: _loadingLocationController,
// //                       label: 'مكان التحميل',
// //                       icon: Icons.location_on,
// //                       validator: (value) {
// //                         if (value == null || value.isEmpty) {
// //                           return 'هذا الحقل مطلوب';
// //                         }
// //                         return null;
// //                       },
// //                       isMobile: isMobile,
// //                     ),
// //                   ),
// //                   SizedBox(width: 16),
// //                   Expanded(
// //                     child: _buildField(
// //                       controller: _unloadingLocationController,
// //                       label: 'مكان التعتيق',
// //                       icon: Icons.location_on,
// //                       validator: (value) {
// //                         if (value == null || value.isEmpty) {
// //                           return 'هذا الحقل مطلوب';
// //                         }
// //                         return null;
// //                       },
// //                       isMobile: isMobile,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //         SizedBox(height: isMobile ? 16 : 20),

// //         // 6. العهدة
// //         // 7. الكارتة
// //         isMobile
// //             ? Column(
// //                 children: [
// //                   _buildField(
// //                     controller: _ohdaController,
// //                     label: 'العهدة',
// //                     icon: Icons.assignment,
// //                     validator: (value) {
// //                       if (value == null || value.isEmpty) {
// //                         return 'هذا الحقل مطلوب';
// //                       }
// //                       return null;
// //                     },
// //                     isMobile: isMobile,
// //                   ),
// //                   SizedBox(height: 16),
// //                   _buildField(
// //                     controller: _kartaController,
// //                     label: 'الكارتة',
// //                     icon: Icons.credit_card,
// //                     validator: (value) {
// //                       if (value == null || value.isEmpty) {
// //                         return 'هذا الحقل مطلوب';
// //                       }
// //                       return null;
// //                     },
// //                     isMobile: isMobile,
// //                   ),
// //                 ],
// //               )
// //             : Row(
// //                 children: [
// //                   Expanded(
// //                     child: _buildField(
// //                       controller: _ohdaController,
// //                       label: 'العهدة',
// //                       icon: Icons.assignment,
// //                       validator: (value) {
// //                         if (value == null || value.isEmpty) {
// //                           return 'هذا الحقل مطلوب';
// //                         }
// //                         return null;
// //                       },
// //                       isMobile: isMobile,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //         SizedBox(height: isMobile ? 16 : 20),

// //         // 8. الملاحظات (اختياري)
// //         _buildNotesField(isMobile),
// //         SizedBox(height: isMobile ? 16 : 20),

// //         // 9. قائمة عروض الأسعار
// //         _buildPriceOffersDropdown(isMobile),
// //         SizedBox(height: isMobile ? 16 : 20),
// //       ],
// //     );
// //   }

// //   // دالة لبناء حقل الملاحظات
// //   Widget _buildNotesField(bool isMobile) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'ملاحظات (اختياري)',
// //           style: TextStyle(
// //             fontSize: isMobile ? 14 : 16,
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //           ),
// //         ),
// //         SizedBox(height: isMobile ? 6 : 8),
// //         TextFormField(
// //           controller: _notesController,
// //           style: TextStyle(fontSize: isMobile ? 14 : 16),
// //           maxLines: 3,
// //           decoration: InputDecoration(
// //             prefixIcon: Icon(Icons.note, color: const Color(0xFF3498DB)),
// //             filled: true,
// //             fillColor: Colors.white,
// //             border: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //               borderSide: const BorderSide(color: Color(0xFF3498DB)),
// //             ),
// //             contentPadding: EdgeInsets.symmetric(
// //               horizontal: isMobile ? 12 : 16,
// //               vertical: isMobile ? 14 : 18,
// //             ),
// //             hintText: 'أدخل ملاحظات إضافية (اختياري)...',
// //             alignLabelWithHint: true,
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildDriverNameField(bool isMobile) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'اسم السائق',
// //           style: TextStyle(
// //             fontSize: isMobile ? 14 : 16,
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //           ),
// //         ),
// //         SizedBox(height: isMobile ? 6 : 8),
// //         Container(
// //           decoration: BoxDecoration(
// //             borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //           ),
// //           child: Column(
// //             children: [
// //               TextFormField(
// //                 controller: _driverNameController,
// //                 onChanged: _onDriverNameChanged,
// //                 style: TextStyle(fontSize: isMobile ? 14 : 16),
// //                 decoration: InputDecoration(
// //                   prefixIcon: Icon(
// //                     Icons.person,
// //                     color: const Color(0xFF3498DB),
// //                   ),
// //                   filled: true,
// //                   fillColor: Colors.white,
// //                   border: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //                     borderSide: const BorderSide(color: Color(0xFF3498DB)),
// //                   ),
// //                   contentPadding: EdgeInsets.symmetric(
// //                     horizontal: isMobile ? 12 : 16,
// //                     vertical: isMobile ? 12 : 16,
// //                   ),
// //                   hintText: 'اكتب اسم السائق',
// //                   suffixIcon: _isLoadingSuggestions
// //                       ? Padding(
// //                           padding: const EdgeInsets.all(8.0),
// //                           child: SizedBox(
// //                             width: 16,
// //                             height: 16,
// //                             child: CircularProgressIndicator(strokeWidth: 2),
// //                           ),
// //                         )
// //                       : null,
// //                 ),
// //                 validator: (value) {
// //                   if (value == null || value.isEmpty) {
// //                     return 'هذا الحقل مطلوب';
// //                   }
// //                   return null;
// //                 },
// //               ),
// //               // عرض قائمة الاقتراحات
// //               if (_driverSuggestions.isNotEmpty &&
// //                   _driverNameController.text.isNotEmpty)
// //                 Container(
// //                   margin: EdgeInsets.only(top: 4),
// //                   decoration: BoxDecoration(
// //                     color: Colors.white,
// //                     borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //                     border: Border.all(color: Colors.grey[300]!),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: Colors.black12,
// //                         blurRadius: 4,
// //                         offset: Offset(0, 2),
// //                       ),
// //                     ],
// //                   ),
// //                   child: Column(
// //                     children: _driverSuggestions
// //                         .map(
// //                           (suggestion) => ListTile(
// //                             leading: Icon(
// //                               Icons.person_outline,
// //                               color: Colors.blue,
// //                               size: 20,
// //                             ),
// //                             title: Text(
// //                               suggestion,
// //                               style: TextStyle(fontSize: isMobile ? 14 : 16),
// //                             ),
// //                             dense: true,
// //                             visualDensity: VisualDensity.compact,
// //                             contentPadding: EdgeInsets.symmetric(
// //                               horizontal: 12,
// //                             ),
// //                             onTap: () {
// //                               setState(() {
// //                                 _driverNameController.text = suggestion;
// //                                 _driverSuggestions.clear();
// //                               });
// //                             },
// //                           ),
// //                         )
// //                         .toList(),
// //                   ),
// //                 ),
// //             ],
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildCompanyDropdown(bool isMobile) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'اختر الشركة',
// //           style: TextStyle(
// //             fontSize: isMobile ? 14 : 16,
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //           ),
// //         ),
// //         SizedBox(height: isMobile ? 6 : 8),
// //         Container(
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //             border: Border.all(color: const Color(0xFF3498DB)),
// //           ),
// //           child: _isLoading
// //               ? Padding(
// //                   padding: EdgeInsets.symmetric(
// //                     horizontal: isMobile ? 12 : 16,
// //                     vertical: isMobile ? 12 : 16,
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       SizedBox(
// //                         width: isMobile ? 16 : 20,
// //                         height: isMobile ? 16 : 20,
// //                         child: const CircularProgressIndicator(strokeWidth: 2),
// //                       ),
// //                       SizedBox(width: isMobile ? 8 : 12),
// //                       Text(
// //                         'جاري تحميل الشركات...',
// //                         style: TextStyle(fontSize: isMobile ? 14 : 16),
// //                       ),
// //                     ],
// //                   ),
// //                 )
// //               : DropdownButtonHideUnderline(
// //                   child: DropdownButton<String>(
// //                     value: _selectedCompanyId,
// //                     isExpanded: true,
// //                     hint: Padding(
// //                       padding: EdgeInsets.symmetric(
// //                         horizontal: isMobile ? 12 : 16,
// //                       ),
// //                       child: Text(
// //                         'اختر شركة',
// //                         style: TextStyle(fontSize: isMobile ? 14 : 16),
// //                       ),
// //                     ),
// //                     items: _companies.map((company) {
// //                       final data = company.data();
// //                       final companyName = data['companyName'] ?? '';
// //                       return DropdownMenuItem<String>(
// //                         value: company.id,
// //                         child: Padding(
// //                           padding: EdgeInsets.symmetric(
// //                             horizontal: isMobile ? 12 : 16,
// //                           ),
// //                           child: Text(
// //                             companyName,
// //                             style: TextStyle(fontSize: isMobile ? 14 : 16),
// //                             overflow: TextOverflow.ellipsis,
// //                           ),
// //                         ),
// //                       );
// //                     }).toList(),
// //                     onChanged: (String? newValue) {
// //                       setState(() {
// //                         _selectedCompanyId = newValue;
// //                         _selectedCompanyName = _companies
// //                             .firstWhere((company) => company.id == newValue)
// //                             .data()['companyName'];
// //                         _priceOffers.clear();
// //                         _selectedPriceOffer = null;

// //                         if (newValue != null) {
// //                           _loadPriceOffers(newValue);
// //                         }
// //                       });
// //                     },
// //                   ),
// //                 ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildPriceOffersDropdown(bool isMobile) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'مطابقة نولون',
// //           style: TextStyle(
// //             fontSize: isMobile ? 14 : 16,
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //           ),
// //         ),
// //         SizedBox(height: isMobile ? 6 : 8),

// //         Container(
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //             border: Border.all(color: Colors.orange),
// //           ),
// //           child: ExpansionTile(
// //             title: Row(
// //               children: [
// //                 Icon(Icons.map, color: Colors.orange, size: isMobile ? 20 : 24),
// //                 SizedBox(width: 8),
// //                 Expanded(
// //                   child: _selectedPriceOffer != null
// //                       ? Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Text(
// //                               '${_selectedPriceOffer!['unloadingLocation']}',
// //                               style: TextStyle(
// //                                 fontSize: isMobile ? 14 : 16,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.green[700],
// //                               ),
// //                             ),
// //                           ],
// //                         )
// //                       : Text(
// //                           'اختر موقع من القائمة',
// //                           style: TextStyle(
// //                             fontSize: isMobile ? 14 : 16,
// //                             color: Colors.grey[600],
// //                           ),
// //                         ),
// //                 ),
// //               ],
// //             ),
// //             trailing: Icon(
// //               _isDropdownOpen ? Icons.expand_less : Icons.expand_more,
// //               color: Colors.orange,
// //             ),
// //             onExpansionChanged: (expanded) {
// //               setState(() {
// //                 _isDropdownOpen = expanded;
// //               });

// //               if (expanded &&
// //                   _selectedCompanyId != null &&
// //                   _priceOffers.isEmpty) {
// //                 _loadPriceOffers(_selectedCompanyId!);
// //               }
// //             },
// //             children: [
// //               if (_selectedCompanyId == null)
// //                 Padding(
// //                   padding: EdgeInsets.all(16),
// //                   child: Text(
// //                     'يرجى اختيار شركة أولاً',
// //                     style: TextStyle(color: Colors.grey),
// //                     textAlign: TextAlign.center,
// //                   ),
// //                 )
// //               else if (_priceOffers.isEmpty)
// //                 Padding(
// //                   padding: EdgeInsets.all(16),
// //                   child: Text(
// //                     'لا توجد عروض أسعار لهذه الشركة',
// //                     style: TextStyle(color: Colors.grey),
// //                     textAlign: TextAlign.center,
// //                   ),
// //                 )
// //               else
// //                 ..._priceOffers.map((offer) {
// //                   return Container(
// //                     decoration: BoxDecoration(
// //                       border: Border(top: BorderSide(color: Colors.grey[200]!)),
// //                     ),
// //                     child: ListTile(
// //                       leading: Icon(Icons.route, color: Colors.blue),
// //                       title: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             '${offer['unloadingLocation']}',
// //                             style: TextStyle(
// //                               fontSize: isMobile ? 14 : 16,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       trailing:
// //                           _selectedPriceOffer != null &&
// //                               _selectedPriceOffer!['offerId'] ==
// //                                   offer['offerId']
// //                           ? Icon(Icons.check_circle, color: Colors.green)
// //                           : null,
// //                       onTap: () {
// //                         _selectPriceOffer(offer);
// //                       },
// //                       dense: true,
// //                     ),
// //                   );
// //                 }).toList(),
// //             ],
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildDateField(bool isMobile) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           'التاريخ',
// //           style: TextStyle(
// //             fontSize: isMobile ? 14 : 16,
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //           ),
// //         ),
// //         SizedBox(height: isMobile ? 6 : 8),
// //         InkWell(
// //           onTap: () => _selectDate(context),
// //           child: Container(
// //             padding: EdgeInsets.symmetric(
// //               horizontal: isMobile ? 12 : 16,
// //               vertical: isMobile ? 12 : 16,
// //             ),
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //               border: Border.all(color: const Color(0xFF3498DB)),
// //             ),
// //             child: Row(
// //               children: [
// //                 Icon(
// //                   Icons.calendar_today,
// //                   color: const Color(0xFF3498DB),
// //                   size: isMobile ? 18 : 24,
// //                 ),
// //                 SizedBox(width: isMobile ? 8 : 12),
// //                 Text(
// //                   _formatDate(_selectedDate),
// //                   style: TextStyle(fontSize: isMobile ? 14 : 16),
// //                 ),
// //                 const Spacer(),
// //                 Text(
// //                   'اختر التاريخ',
// //                   style: TextStyle(
// //                     color: Colors.grey,
// //                     fontSize: isMobile ? 12 : 14,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildField({
// //     required TextEditingController controller,
// //     required String label,
// //     required IconData icon,
// //     required String? Function(String?)? validator,
// //     required bool isMobile,
// //   }) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           label,
// //           style: TextStyle(
// //             fontSize: isMobile ? 14 : 16,
// //             fontWeight: FontWeight.bold,
// //             color: const Color(0xFF2C3E50),
// //           ),
// //         ),
// //         SizedBox(height: isMobile ? 6 : 8),
// //         TextFormField(
// //           controller: controller,
// //           style: TextStyle(fontSize: isMobile ? 14 : 16),
// //           decoration: InputDecoration(
// //             prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
// //             filled: true,
// //             fillColor: Colors.white,
// //             border: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //               borderSide: const BorderSide(color: Color(0xFF3498DB)),
// //             ),
// //             contentPadding: EdgeInsets.symmetric(
// //               horizontal: isMobile ? 12 : 16,
// //               vertical: isMobile ? 12 : 16,
// //             ),
// //           ),
// //           validator: validator,
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildActionButtons(bool isMobile) {
// //     return SizedBox(
// //       width: double.infinity,
// //       child: ElevatedButton(
// //         onPressed: _isSaving ? null : _saveDailyWork,
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: const Color(0xFF2E86C1),
// //           padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 18),
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
// //           ),
// //         ),
// //         child: _isSaving
// //             ? SizedBox(
// //                 width: isMobile ? 20 : 24,
// //                 height: isMobile ? 20 : 24,
// //                 child: const CircularProgressIndicator(color: Colors.white),
// //               )
// //             : Text(
// //                 'حفظ الشغل اليومى',
// //                 style: TextStyle(
// //                   fontSize: isMobile ? 16 : 18,
// //                   fontWeight: FontWeight.bold,
// //                   color: Colors.white,
// //                 ),
// //               ),
// //       ),
// //     );
// //   }

// //   String _formatDate(DateTime date) {
// //     return '${date.day}/${date.month}/${date.year}';
// //   }

// //   @override
// //   void dispose() {
// //     _debounce?.cancel();
// //     _contractorController.dispose();
// //     _trController.dispose();
// //     _notesController.dispose();
// //     _driverNameController.dispose();
// //     _loadingLocationController.dispose();
// //     _unloadingLocationController.dispose();
// //     _ohdaController.dispose();
// //     _kartaController.dispose();
// //     super.dispose();
// //   }
// // }
// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/material.dart';
// import 'package:last/models/models.dart';

// class DailyWorkPage extends StatefulWidget {
//   const DailyWorkPage({super.key});

//   @override
//   State<DailyWorkPage> createState() => _DailyWorkPageState();
// }

// class _DailyWorkPageState extends State<DailyWorkPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final _formKey = GlobalKey<FormState>();

//   // 1. بيانات الشركة
//   List<QueryDocumentSnapshot<Map<String, dynamic>>> _companies = [];
//   String? _selectedCompanyId;
//   String? _selectedCompanyName;

//   // 2. التاريخ
//   DateTime _selectedDate = DateTime.now();

//   // الحقول الجديدة
//   final TextEditingController _contractorController = TextEditingController();
//   final TextEditingController _trController = TextEditingController();
//   final TextEditingController _notesController = TextEditingController();

//   // 3-8. الحقول اليدوية
//   final TextEditingController _driverNameController = TextEditingController();
//   final TextEditingController _loadingLocationController =
//       TextEditingController();
//   final TextEditingController _unloadingLocationController =
//       TextEditingController();
//   final TextEditingController _ohdaController = TextEditingController();
//   final TextEditingController _kartaController = TextEditingController();

//   // حالة التحميل والحفظ
//   bool _isLoading = true;
//   bool _isSaving = false;

//   // 9-13. عروض الأسعار
//   List<Map<String, dynamic>> _priceOffers = [];
//   Map<String, dynamic>? _selectedPriceOffer;
//   bool _isDropdownOpen = false;

//   // اقتراحات أسماء السائقين
//   List<String> _driverSuggestions = [];
//   bool _isLoadingSuggestions = false;
//   Timer? _debounce;

//   // قائمة مواقع الشركة
//   List<Map<String, dynamic>> _companyLocations = [];
//   String? _selectedLocationId;

//   @override
//   void initState() {
//     super.initState();
//     _loadCompanies();
//   }

//   Future<void> _loadCompanies() async {
//     try {
//       final snapshot = await _firestore.collection('companies').get();
//       setState(() {
//         _companies = snapshot.docs;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showError('خطأ في تحميل الشركات: $e');
//     }
//   }

//   // دالة جديدة: تحميل مواقع الشركة
//   Future<void> _loadCompanyLocations(String companyId) async {
//     if (companyId.isEmpty) return;

//     try {
//       final companyDoc = await _firestore
//           .collection('companies')
//           .doc(companyId)
//           .get();
//       final companyData = companyDoc.data() as Map<String, dynamic>;

//       List<dynamic> locations = companyData['locations'] ?? [];

//       setState(() {
//         _companyLocations = locations.map((location) {
//           return {
//             'id': '${companyId}_${locations.indexOf(location)}',
//             'name': location['name'] ?? 'موقع غير مسمى',
//             'address': location['address'] ?? '',
//             'phone': location['phone'] ?? '',
//             'manager': location['manager'] ?? '',
//           };
//         }).toList();
//         _selectedLocationId =
//             null; // إعادة تعيين الموقع المختار عند تغيير الشركة
//       });
//     } catch (e) {
//       print('خطأ في تحميل مواقع الشركة: $e');
//       setState(() {
//         _companyLocations = [];
//         _selectedLocationId = null;
//       });
//     }
//   }

//   Future<void> _loadPriceOffers(String companyId) async {
//     if (companyId.isEmpty) return;

//     try {
//       final snapshot = await _firestore
//           .collection('companies')
//           .doc(companyId)
//           .collection('priceOffers')
//           .get();

//       List<Map<String, dynamic>> allTransportations = [];

//       for (final offerDoc in snapshot.docs) {
//         final offerData = offerDoc.data();
//         final transportations = offerData['transportations'] as List? ?? [];

//         for (final transport in transportations) {
//           final transportMap = transport as Map<String, dynamic>;

//           allTransportations.add({
//             'offerId': offerDoc.id,
//             'loadingLocation': transportMap['loadingLocation'] ?? '',
//             'unloadingLocation': transportMap['unloadingLocation'] ?? '',
//             'vehicleType': transportMap['vehicleType'] ?? '',
//             'nolon': (transportMap['nolon'] ?? transportMap['noLon'] ?? 0.0)
//                 .toDouble(),
//             'wheelNolon':
//                 (transportMap['wheelNolon'] ??
//                         transportMap['wheelNoLon'] ??
//                         0.0)
//                     .toDouble(),
//             'companyOvernight': (transportMap['companyOvernight'] ?? 0.0)
//                 .toDouble(),
//             'companyHoliday': (transportMap['companyHoliday'] ?? 0.0)
//                 .toDouble(),
//             'wheelOvernight': (transportMap['wheelOvernight'] ?? 0.0)
//                 .toDouble(),
//             'wheelHoliday': (transportMap['wheelHoliday'] ?? 0.0).toDouble(),
//             'notes': transportMap['notes'] ?? '',
//           });
//         }
//       }

//       setState(() {
//         _priceOffers = allTransportations;
//       });
//     } catch (e) {
//       print('خطأ في تحميل عروض الأسعار: $e');
//     }
//   }

//   Future<List<String>> _fetchDriverSuggestions(String query) async {
//     if (query.isEmpty) return [];

//     try {
//       final snapshot = await _firestore
//           .collection('dailyWork')
//           .where('driverName', isGreaterThanOrEqualTo: query)
//           .where('driverName', isLessThan: '${query}z')
//           .orderBy('driverName')
//           .limit(10)
//           .get();

//       final names = snapshot.docs
//           .map((doc) => doc.data()['driverName'] as String? ?? '')
//           .where((name) => name.toLowerCase().contains(query.toLowerCase()))
//           .toSet()
//           .toList();

//       return names;
//     } catch (e) {
//       print('خطأ في جلب اقتراحات السائقين: $e');
//       return [];
//     }
//   }

//   void _onDriverNameChanged(String value) {
//     if (_debounce?.isActive ?? false) _debounce?.cancel();

//     _debounce = Timer(const Duration(milliseconds: 300), () async {
//       if (value.isNotEmpty && value.length >= 2) {
//         setState(() => _isLoadingSuggestions = true);
//         final suggestions = await _fetchDriverSuggestions(value);
//         setState(() {
//           _driverSuggestions = suggestions;
//           _isLoadingSuggestions = false;
//         });
//       } else {
//         setState(() => _driverSuggestions.clear());
//       }
//     });
//   }

//   Future<double> _getTreasuryBalance() async {
//     try {
//       // مجموع الإيرادات المصروفة
//       final incomeSnapshot = await _firestore
//           .collection('treasury_entries')
//           .where('isCleared', isEqualTo: true)
//           .get();

//       double totalIncome = 0;
//       for (var doc in incomeSnapshot.docs) {
//         final amount = doc.data()['amount'];
//         if (amount != null) {
//           totalIncome += (amount as num).toDouble();
//         }
//       }

//       // مجموع المصروفات
//       final expenseSnapshot = await _firestore
//           .collection('treasury_exits')
//           .get();

//       double totalExpense = 0;
//       for (var doc in expenseSnapshot.docs) {
//         final amount = doc.data()['amount'];
//         if (amount != null) {
//           totalExpense += (amount as num).toDouble();
//         }
//       }

//       return totalIncome - totalExpense;
//     } catch (e) {
//       print('Error loading treasury balance: $e');
//       return 0.0;
//     }
//   }

//   Future<void> _addExpenseForOhda() async {
//     try {
//       final amountText = _ohdaController.text.trim();

//       if (amountText.isEmpty) {
//         print('لا توجد قيمة للعهدة');
//         return;
//       }

//       final amount = double.tryParse(amountText);
//       if (amount == null || amount <= 0) {
//         print('قيمة العهدة غير صالحة: $amountText');
//         return;
//       }

//       // التحقق من رصيد الخزنة
//       final balance = await _getTreasuryBalance();
//       if (amount > balance) {
//         _showError(
//           'قيمة العهدة ($amount ج) أكبر من الرصيد المتاح (${balance.toStringAsFixed(2)} ج) في الخزنة',
//         );
//         return;
//       }

//       final expenseData = {
//         'amount': amount,
//         'category': 'خرج',
//         'createdAt': Timestamp.now(),
//         'date': Timestamp.now(),
//         'description':
//             'عهدة لـ ${_driverNameController.text.trim()} - ${_loadingLocationController.text.trim()} إلى ${_unloadingLocationController.text.trim()}',
//         'expenseType': 'عهده',
//         'recipient': _driverNameController.text.trim(),
//         'status': 'مكتمل',
//         'relatedTo': 'dailyWork',
//         'driverName': _driverNameController.text.trim(),
//         'companyName': _selectedCompanyName ?? '',
//         'loadingLocation': _loadingLocationController.text.trim(),
//         'unloadingLocation': _unloadingLocationController.text.trim(),
//         'contractor': _contractorController.text.trim(),
//       };

//       await _firestore.collection('treasury_exits').add(expenseData);

//       print('تم حفظ العهدة في الخزنة بمبلغ: $amount');
//     } catch (e) {
//       print('خطأ في حفظ العهدة في الخزنة: $e');
//       _showError('خطأ في حفظ العهدة في الخزنة: $e');
//     }
//   }

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

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2030),
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   void _selectPriceOffer(Map<String, dynamic> offer) {
//     setState(() {
//       _selectedPriceOffer = offer;
//       _isDropdownOpen = false;
//     });
//   }

//   // دالة جديدة: اختيار موقع الشركة
//   void _selectCompanyLocation(Map<String, dynamic> location) {
//     setState(() {
//       _selectedLocationId = location['id'];
//     });

//     // يمكنك هنا تعبئة حقل مكان التحميل تلقائياً إذا أردت
//     // _loadingLocationController.text = location['address'];
//   }

//   Future<void> _saveDailyWork() async {
//     if (_selectedCompanyId == null) {
//       _showError('يرجى اختيار شركة');
//       return;
//     }

//     if (_selectedPriceOffer == null) {
//       _showError('يرجى اختيار موقع من عروض الأسعار');
//       return;
//     }

//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isSaving = true);

//     try {
//       final dailyWork = DailyWork(
//         companyId: _selectedCompanyId!,
//         companyName: _selectedCompanyName!,
//         date: _selectedDate,
//         contractor: _contractorController.text.trim(),
//         tr: _trController.text.trim(),
//         driverName: _driverNameController.text.trim(),
//         loadingLocation: _loadingLocationController.text.trim(),
//         unloadingLocation: _unloadingLocationController.text.trim(),
//         ohda: _ohdaController.text.trim(),
//         karta: _kartaController.text.trim(),
//         selectedRoute: '${_selectedPriceOffer!['unloadingLocation']}',
//         selectedPrice: _selectedPriceOffer!['nolon'] ?? 0.0,
//         wheelNolon: _selectedPriceOffer!['wheelNolon'] ?? 0.0,
//         selectedVehicleType: _selectedPriceOffer!['vehicleType'] ?? '',
//         selectedNotes: _notesController.text.trim(),
//         priceOfferId: _selectedPriceOffer!['offerId'] ?? '',
//         wheelOvernight: 0,
//         wheelHoliday: 0,
//         companyOvernight: 0,
//         companyHoliday: 0,
//         nolon: _selectedPriceOffer!['nolon'] ?? 0.0,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//         companyLocationId: _selectedLocationId, // إضافة معرف موقع الشركة
//         companyLocationName: _selectedLocationId != null
//             ? _companyLocations.firstWhere(
//                 (loc) => loc['id'] == _selectedLocationId,
//                 orElse: () => {'name': ''},
//               )['name']
//             : '', // إضافة اسم موقع الشركة
//       );

//       // حفظ الشغل اليومي
//       final dailyWorkRef = await _firestore
//           .collection('dailyWork')
//           .add(dailyWork.toMap());

//       // حفظ نسخة في قسم السائقين
//       final driverWorkData = {
//         'dailyWorkId': dailyWorkRef.id,
//         'companyId': _selectedCompanyId!,
//         'companyName': _selectedCompanyName!,
//         'date': _selectedDate,
//         'contractor': _contractorController.text.trim(),
//         'tr': _trController.text.trim(),
//         'driverName': _driverNameController.text.trim(),
//         'loadingLocation': _loadingLocationController.text.trim(),
//         'unloadingLocation': _unloadingLocationController.text.trim(),
//         'ohda': _ohdaController.text.trim(),
//         'karta': _kartaController.text.trim(),
//         'selectedRoute': '${_selectedPriceOffer!['unloadingLocation']}',
//         'selectedPrice': _selectedPriceOffer!['nolon'] ?? 0.0,
//         'wheelNolon': _selectedPriceOffer!['wheelNolon'] ?? 0.0,
//         'selectedVehicleType': _selectedPriceOffer!['vehicleType'] ?? '',
//         'selectedNotes': _notesController.text.trim(),
//         'priceOfferId': _selectedPriceOffer!['offerId'] ?? '',
//         'wheelOvernight': 0,
//         'wheelHoliday': 0,
//         'companyOvernight': 0,
//         'companyHoliday': 0,
//         'nolon': _selectedPriceOffer!['nolon'] ?? 0.0,
//         'isPaid': false,
//         'paidAmount': 0.0,
//         'remainingAmount': _selectedPriceOffer!['wheelNolon'] ?? 0.0,
//         'paymentDate': null,
//         'driverNotes': '',
//         'createdAt': DateTime.now(),
//         'updatedAt': DateTime.now(),
//         'companyLocationId': _selectedLocationId,
//         'companyLocationName': _selectedLocationId != null
//             ? _companyLocations.firstWhere(
//                 (loc) => loc['id'] == _selectedLocationId,
//                 orElse: () => {'name': ''},
//               )['name']
//             : '',
//       };

//       await _firestore.collection('drivers').add(driverWorkData);

//       // إضافة العهدة إلى الخارج من الخزنة
//       await _addExpenseForOhda();

//       _showSuccess(
//         'تم حفظ الشغل اليومي بنجاح وحفظ نسخة في قسم السائقين وإضافة العهدة للخزنة',
//       );
//       _clearForm();
//     } catch (e) {
//       _showError('خطأ في الحفظ: $e');
//     } finally {
//       setState(() => _isSaving = false);
//     }
//   }

//   // دالة لبناء حقل TR اختياري
//   Widget _buildOptionalTRField(bool isMobile) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'TR (اختياري)',
//           style: TextStyle(
//             fontSize: isMobile ? 14 : 16,
//             fontWeight: FontWeight.bold,
//             color: const Color(0xFF2C3E50),
//           ),
//         ),
//         SizedBox(height: isMobile ? 6 : 8),
//         TextFormField(
//           controller: _trController,
//           style: TextStyle(fontSize: isMobile ? 14 : 16),
//           decoration: InputDecoration(
//             prefixIcon: Icon(Icons.numbers, color: const Color(0xFF3498DB)),
//             filled: true,
//             fillColor: Colors.white,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
//               borderSide: const BorderSide(color: Color(0xFF3498DB)),
//             ),
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: isMobile ? 12 : 16,
//               vertical: isMobile ? 12 : 16,
//             ),
//             hintText: 'أدخل قيمة TR (اختياري)',
//           ),
//           // لا يوجد validator هنا، مما يجعله اختيارياً
//         ),
//       ],
//     );
//   }

//   void _clearForm() {
//     setState(() {
//       _selectedCompanyId = null;
//       _selectedCompanyName = null;
//       _selectedDate = DateTime.now();
//       _selectedPriceOffer = null;
//       _priceOffers.clear();
//       _contractorController.clear();
//       _trController.clear();
//       _notesController.clear();
//       _driverNameController.clear();
//       _loadingLocationController.clear();
//       _unloadingLocationController.clear();
//       _ohdaController.clear();
//       _kartaController.clear();
//       _driverSuggestions.clear();
//       _companyLocations.clear();
//       _selectedLocationId = null;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6F8),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           bool isMobile = constraints.maxWidth < 600;

//           return Column(
//             children: [
//               _buildCustomAppBar(isMobile),
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.all(isMobile ? 16 : 24),
//                   child: Center(
//                     child: ConstrainedBox(
//                       constraints: const BoxConstraints(maxWidth: 800),
//                       child: Column(
//                         children: [
//                           Card(
//                             elevation: 8,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(
//                                 isMobile ? 16 : 22,
//                               ),
//                             ),
//                             child: Padding(
//                               padding: EdgeInsets.all(isMobile ? 16 : 32),
//                               child: Form(
//                                 key: _formKey,
//                                 child: Column(
//                                   children: [
//                                     SizedBox(height: isMobile ? 8 : 16),
//                                     _buildHeaderSection(isMobile),
//                                     SizedBox(height: isMobile ? 16 : 32),
//                                     _buildDailyWorkForm(isMobile),
//                                     SizedBox(height: isMobile ? 20 : 40),
//                                     _buildActionButtons(isMobile),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildCustomAppBar(bool isMobile) {
//     return Container(
//       padding: EdgeInsets.symmetric(
//         horizontal: isMobile ? 16 : 24,
//         vertical: isMobile ? 12 : 20,
//       ),
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
//         child: Row(
//           children: [
//             Icon(Icons.work, color: Colors.white, size: isMobile ? 24 : 32),
//             SizedBox(width: isMobile ? 8 : 12),
//             Text(
//               'الشغل اليومي',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: isMobile ? 18 : 24,
//                 fontWeight: FontWeight.bold,
//                 fontFamily: 'Cairo',
//               ),
//             ),
//             const Spacer(),
//             _buildTimeWidget(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTimeWidget() {
//     return StreamBuilder<DateTime>(
//       stream: Stream.periodic(
//         const Duration(seconds: 1),
//         (_) => DateTime.now(),
//       ),
//       builder: (context, snapshot) {
//         final now = snapshot.data ?? DateTime.now();
//         int hour12 = now.hour % 12;
//         if (hour12 == 0) hour12 = 12;

//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               height: 50,
//               width: 150,
//               decoration: BoxDecoration(
//                 color: Colors.transparent,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Center(
//                 child: Text(
//                   '${hour12.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} ',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 36,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildHeaderSection(bool isMobile) {
//     return Column(
//       children: [
//         Text(
//           'تسجيل الشغل اليومي',
//           style: TextStyle(
//             fontSize: isMobile ? 20 : 24,
//             fontWeight: FontWeight.bold,
//             color: const Color(0xFF2C3E50),
//           ),
//           textAlign: TextAlign.center,
//         ),
//         SizedBox(height: 8),
//         Text(
//           'أدخل بيانات الشغل اليومي للشركة',
//           style: TextStyle(
//             fontSize: isMobile ? 14 : 16,
//             color: Colors.grey[600],
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildDailyWorkForm(bool isMobile) {
//     return Column(
//       children: [
//         // 1. اختيار الشركة
//         _buildCompanyDropdown(isMobile),
//         SizedBox(height: isMobile ? 16 : 20),

//         // 2. اختيار التاريخ
//         _buildDateField(isMobile),
//         SizedBox(height: isMobile ? 16 : 20),

//         // الحقول: المقاول و TR
//         isMobile
//             ? Column(
//                 children: [
//                   _buildField(
//                     controller: _contractorController,
//                     label: 'المقاول',
//                     icon: Icons.business,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'هذا الحقل مطلوب';
//                       }
//                       return null;
//                     },
//                     isMobile: isMobile,
//                   ),
//                   SizedBox(height: 16),
//                   _buildOptionalTRField(isMobile),
//                 ],
//               )
//             : Row(
//                 children: [
//                   Expanded(
//                     child: _buildField(
//                       controller: _contractorController,
//                       label: 'المقاول',
//                       icon: Icons.business,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'هذا الحقل مطلوب';
//                         }
//                         return null;
//                       },
//                       isMobile: isMobile,
//                     ),
//                   ),
//                   SizedBox(width: 16),
//                   Expanded(child: _buildOptionalTRField(isMobile)),
//                 ],
//               ),
//         SizedBox(height: isMobile ? 16 : 20),

//         // 3. اسم السائق مع الاقتراح التلقائي
//         _buildDriverNameField(isMobile),
//         SizedBox(height: isMobile ? 16 : 20),

//         // موقع الشركة (جديد)
//         _buildCompanyLocationDropdown(isMobile),
//         SizedBox(height: isMobile ? 16 : 20),

//         // 4. مكان التحميل (يدوي)
//         // 5. مكان التعتيق (يدوي)
//         isMobile
//             ? Column(
//                 children: [
//                   _buildField(
//                     controller: _loadingLocationController,
//                     label: 'مكان التحميل',
//                     icon: Icons.location_on,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'هذا الحقل مطلوب';
//                       }
//                       return null;
//                     },
//                     isMobile: isMobile,
//                   ),
//                   SizedBox(height: 16),
//                   _buildField(
//                     controller: _unloadingLocationController,
//                     label: 'مكان التعتيق',
//                     icon: Icons.location_on,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'هذا الحقل مطلوب';
//                       }
//                       return null;
//                     },
//                     isMobile: isMobile,
//                   ),
//                 ],
//               )
//             : Row(
//                 children: [
//                   Expanded(
//                     child: _buildField(
//                       controller: _loadingLocationController,
//                       label: 'مكان التحميل',
//                       icon: Icons.location_on,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'هذا الحقل مطلوب';
//                         }
//                         return null;
//                       },
//                       isMobile: isMobile,
//                     ),
//                   ),
//                   SizedBox(width: 16),
//                   Expanded(
//                     child: _buildField(
//                       controller: _unloadingLocationController,
//                       label: 'مكان التعتيق',
//                       icon: Icons.location_on,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'هذا الحقل مطلوب';
//                         }
//                         return null;
//                       },
//                       isMobile: isMobile,
//                     ),
//                   ),
//                 ],
//               ),
//         SizedBox(height: isMobile ? 16 : 20),

//         // 6. العهدة
//         // 7. الكارتة
//         isMobile
//             ? Column(
//                 children: [
//                   _buildField(
//                     controller: _ohdaController,
//                     label: 'العهدة',
//                     icon: Icons.assignment,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'هذا الحقل مطلوب';
//                       }
//                       return null;
//                     },
//                     isMobile: isMobile,
//                   ),
//                   SizedBox(height: 16),
//                   _buildField(
//                     controller: _kartaController,
//                     label: 'الكارتة',
//                     icon: Icons.credit_card,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'هذا الحقل مطلوب';
//                       }
//                       return null;
//                     },
//                     isMobile: isMobile,
//                   ),
//                 ],
//               )
//             : Row(
//                 children: [
//                   Expanded(
//                     child: _buildField(
//                       controller: _ohdaController,
//                       label: 'العهدة',
//                       icon: Icons.assignment,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'هذا الحقل مطلوب';
//                         }
//                         return null;
//                       },
//                       isMobile: isMobile,
//                     ),
//                   ),
//                 ],
//               ),
//         SizedBox(height: isMobile ? 16 : 20),

//         // 8. الملاحظات (اختياري)
//         _buildNotesField(isMobile),
//         SizedBox(height: isMobile ? 16 : 20),

//         // 9. قائمة عروض الأسعار - تم التعديل لتعرض مكان التحميل - مكان التعتيق - نوع العربيه
//         _buildPriceOffersDropdown(isMobile),
//         SizedBox(height: isMobile ? 16 : 20),
//       ],
//     );
//   }

//   Widget _buildCompanyLocationDropdown(bool isMobile) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'موقع الشركة (اختياري)',
//           style: TextStyle(
//             fontSize: isMobile ? 14 : 16,
//             fontWeight: FontWeight.bold,
//             color: const Color(0xFF2C3E50),
//           ),
//         ),
//         SizedBox(height: isMobile ? 6 : 8),
//         InkWell(
//           onTap: () {
//             _showCompanyLocationsDialog(isMobile);
//           },
//           child: Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: isMobile ? 12 : 16,
//               vertical: isMobile ? 12 : 16,
//             ),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
//               border: Border.all(color: Colors.purple),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.location_on,
//                   color: Colors.purple,
//                   size: isMobile ? 18 : 22,
//                 ),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: _selectedLocationId != null
//                       ? Text(
//                           _companyLocations.firstWhere(
//                             (loc) => loc['id'] == _selectedLocationId,
//                             orElse: () => {'name': ''},
//                           )['name'],
//                           style: TextStyle(fontSize: isMobile ? 14 : 16),
//                         )
//                       : Text(
//                           'اختر موقع الشركة',
//                           style: TextStyle(
//                             fontSize: isMobile ? 14 : 16,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                 ),
//                 Icon(Icons.arrow_drop_down, color: Colors.purple),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   void _showCompanyLocationsDialog(bool isMobile) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Container(
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.7,
//             ),
//             width: isMobile ? MediaQuery.of(context).size.width * 0.9 : 500,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Text(
//                     'اختر موقع الشركة',
//                     style: TextStyle(
//                       fontSize: isMobile ? 18 : 20,
//                       fontWeight: FontWeight.bold,
//                       color: const Color(0xFF2C3E50),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: _companyLocations.isEmpty
//                       ? Center(
//                           child: Padding(
//                             padding: const EdgeInsets.all(16),
//                             child: Text(
//                               'لا توجد مواقع لهذه الشركة',
//                               style: TextStyle(color: Colors.grey),
//                             ),
//                           ),
//                         )
//                       : ListView.builder(
//                           shrinkWrap: true,
//                           itemCount:
//                               _companyLocations.length +
//                               1, // +1 للخيار "بدون موقع"
//                           itemBuilder: (context, index) {
//                             if (index == 0) {
//                               return ListTile(
//                                 leading: Icon(Icons.cancel, color: Colors.grey),
//                                 title: Text('بدون موقع محدد'),
//                                 onTap: () {
//                                   setState(() {
//                                     _selectedLocationId = null;
//                                   });
//                                   Navigator.pop(context);
//                                 },
//                               );
//                             }

//                             final location = _companyLocations[index - 1];
//                             return ListTile(
//                               leading: Icon(
//                                 Icons.location_on,
//                                 color: _selectedLocationId == location['id']
//                                     ? Colors.green
//                                     : Colors.blue,
//                               ),
//                               title: Text(
//                                 location['name'],
//                                 style: TextStyle(fontWeight: FontWeight.bold),
//                               ),

//                               trailing: _selectedLocationId == location['id']
//                                   ? Icon(Icons.check, color: Colors.green)
//                                   : null,
//                               onTap: () {
//                                 _selectCompanyLocation(location);
//                                 Navigator.pop(context);
//                               },
//                             );
//                           },
//                         ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () => Navigator.pop(context),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.grey[300],
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: Text(
//                         'إغلاق',
//                         style: TextStyle(color: Colors.black),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   // دالة لبناء حقل الملاحظات
//   Widget _buildNotesField(bool isMobile) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'ملاحظات (اختياري)',
//           style: TextStyle(
//             fontSize: isMobile ? 14 : 16,
//             fontWeight: FontWeight.bold,
//             color: const Color(0xFF2C3E50),
//           ),
//         ),
//         SizedBox(height: isMobile ? 6 : 8),
//         TextFormField(
//           controller: _notesController,
//           style: TextStyle(fontSize: isMobile ? 14 : 16),
//           maxLines: 3,
//           decoration: InputDecoration(
//             prefixIcon: Icon(Icons.note, color: const Color(0xFF3498DB)),
//             filled: true,
//             fillColor: Colors.white,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
//               borderSide: const BorderSide(color: Color(0xFF3498DB)),
//             ),
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: isMobile ? 12 : 16,
//               vertical: isMobile ? 14 : 18,
//             ),
//             hintText: 'أدخل ملاحظات إضافية (اختياري)...',
//             alignLabelWithHint: true,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDriverNameField(bool isMobile) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'اسم السائق',
//           style: TextStyle(
//             fontSize: isMobile ? 14 : 16,
//             fontWeight: FontWeight.bold,
//             color: const Color(0xFF2C3E50),
//           ),
//         ),
//         SizedBox(height: isMobile ? 6 : 8),
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
//           ),
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _driverNameController,
//                 onChanged: _onDriverNameChanged,
//                 style: TextStyle(fontSize: isMobile ? 14 : 16),
//                 decoration: InputDecoration(
//                   prefixIcon: Icon(
//                     Icons.person,
//                     color: const Color(0xFF3498DB),
//                   ),
//                   filled: true,
//                   fillColor: Colors.white,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
//                     borderSide: const BorderSide(color: Color(0xFF3498DB)),
//                   ),
//                   contentPadding: EdgeInsets.symmetric(
//                     horizontal: isMobile ? 12 : 16,
//                     vertical: isMobile ? 12 : 16,
//                   ),
//                   hintText: 'اكتب اسم السائق',
//                   suffixIcon: _isLoadingSuggestions
//                       ? Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: SizedBox(
//                             width: 16,
//                             height: 16,
//                             child: CircularProgressIndicator(strokeWidth: 2),
//                           ),
//                         )
//                       : null,
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'هذا الحقل مطلوب';
//                   }
//                   return null;
//                 },
//               ),
//               // عرض قائمة الاقتراحات
//               if (_driverSuggestions.isNotEmpty &&
//                   _driverNameController.text.isNotEmpty)
//                 Container(
//                   margin: EdgeInsets.only(top: 4),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
//                     border: Border.all(color: Colors.grey[300]!),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 4,
//                         offset: Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: _driverSuggestions
//                         .map(
//                           (suggestion) => ListTile(
//                             leading: Icon(
//                               Icons.person_outline,
//                               color: Colors.blue,
//                               size: 20,
//                             ),
//                             title: Text(
//                               suggestion,
//                               style: TextStyle(fontSize: isMobile ? 14 : 16),
//                             ),
//                             dense: true,
//                             visualDensity: VisualDensity.compact,
//                             contentPadding: EdgeInsets.symmetric(
//                               horizontal: 12,
//                             ),
//                             onTap: () {
//                               setState(() {
//                                 _driverNameController.text = suggestion;
//                                 _driverSuggestions.clear();
//                               });
//                             },
//                           ),
//                         )
//                         .toList(),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCompanyDropdown(bool isMobile) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'اختر الشركة',
//           style: TextStyle(
//             fontSize: isMobile ? 14 : 16,
//             fontWeight: FontWeight.bold,
//             color: const Color(0xFF2C3E50),
//           ),
//         ),
//         SizedBox(height: isMobile ? 6 : 8),
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
//             border: Border.all(color: const Color(0xFF3498DB)),
//           ),
//           child: _isLoading
//               ? Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: isMobile ? 12 : 16,
//                     vertical: isMobile ? 12 : 16,
//                   ),
//                   child: Row(
//                     children: [
//                       SizedBox(
//                         width: isMobile ? 16 : 20,
//                         height: isMobile ? 16 : 20,
//                         child: const CircularProgressIndicator(strokeWidth: 2),
//                       ),
//                       SizedBox(width: isMobile ? 8 : 12),
//                       Text(
//                         'جاري تحميل الشركات...',
//                         style: TextStyle(fontSize: isMobile ? 14 : 16),
//                       ),
//                     ],
//                   ),
//                 )
//               : DropdownButtonHideUnderline(
//                   child: DropdownButton<String>(
//                     value: _selectedCompanyId,
//                     isExpanded: true,
//                     hint: Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: isMobile ? 12 : 16,
//                       ),
//                       child: Text(
//                         'اختر شركة',
//                         style: TextStyle(fontSize: isMobile ? 14 : 16),
//                       ),
//                     ),
//                     items: _companies.map((company) {
//                       final data = company.data();
//                       final companyName = data['companyName'] ?? '';
//                       return DropdownMenuItem<String>(
//                         value: company.id,
//                         child: Padding(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: isMobile ? 12 : 16,
//                           ),
//                           child: Text(
//                             companyName,
//                             style: TextStyle(fontSize: isMobile ? 14 : 16),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         _selectedCompanyId = newValue;
//                         _selectedCompanyName = newValue != null
//                             ? _companies
//                                   .firstWhere(
//                                     (company) => company.id == newValue,
//                                   )
//                                   .data()['companyName']
//                             : null;
//                         _priceOffers.clear();
//                         _selectedPriceOffer = null;
//                         _companyLocations.clear();
//                         _selectedLocationId = null;

//                         if (newValue != null) {
//                           _loadPriceOffers(newValue);
//                           _loadCompanyLocations(newValue); // تحميل مواقع الشركة
//                         }
//                       });
//                     },
//                   ),
//                 ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPriceOffersDropdown(bool isMobile) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'مطابقة نولون',
//           style: TextStyle(
//             fontSize: isMobile ? 14 : 16,
//             fontWeight: FontWeight.bold,
//             color: const Color(0xFF2C3E50),
//           ),
//         ),
//         SizedBox(height: isMobile ? 6 : 8),

//         Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
//             border: Border.all(color: Colors.orange),
//           ),
//           child: ExpansionTile(
//             title: Row(
//               children: [
//                 Icon(Icons.map, color: Colors.orange, size: isMobile ? 20 : 24),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: _selectedPriceOffer != null
//                       ? Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               children: [
//                                 Text(
//                                   "${_selectedPriceOffer!['loadingLocation']} >>${_selectedPriceOffer!['unloadingLocation']}==${_selectedPriceOffer!['vehicleType']}" ??
//                                       '',
//                                   style: TextStyle(
//                                     fontSize: isMobile ? 12 : 14,
//                                     color: Colors.blue[700],
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ],
//                             ),
//                           ],
//                         )
//                       : Text(
//                           'اختر مسار من القائمة',
//                           style: TextStyle(
//                             fontSize: isMobile ? 14 : 16,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                 ),
//               ],
//             ),
//             trailing: Icon(
//               _isDropdownOpen ? Icons.expand_less : Icons.expand_more,
//               color: Colors.orange,
//             ),
//             onExpansionChanged: (expanded) {
//               setState(() {
//                 _isDropdownOpen = expanded;
//               });

//               if (expanded &&
//                   _selectedCompanyId != null &&
//                   _priceOffers.isEmpty) {
//                 _loadPriceOffers(_selectedCompanyId!);
//               }
//             },
//             children: [
//               if (_selectedCompanyId == null)
//                 Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Text(
//                     'يرجى اختيار شركة أولاً',
//                     style: TextStyle(color: Colors.grey),
//                     textAlign: TextAlign.center,
//                   ),
//                 )
//               else if (_priceOffers.isEmpty)
//                 Padding(
//                   padding: EdgeInsets.all(16),
//                   child: Text(
//                     'لا توجد عروض أسعار لهذه الشركة',
//                     style: TextStyle(color: Colors.grey),
//                     textAlign: TextAlign.center,
//                   ),
//                 )
//               else
//                 ..._priceOffers.map((offer) {
//                   return Container(
//                     decoration: BoxDecoration(
//                       border: Border(top: BorderSide(color: Colors.grey[200]!)),
//                     ),
//                     child: ListTile(
//                       leading: Icon(Icons.route, color: Colors.blue),
//                       title: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // مكان التحميل - مكان التعتيق - نوع العربيه
//                           Row(
//                             children: [
//                               Text(
//                                 "${offer['loadingLocation']} >>${offer['unloadingLocation']}==${offer['vehicleType']}" ??
//                                     '',
//                                 style: TextStyle(
//                                   fontSize: isMobile ? 12 : 14,
//                                   color: Colors.blue[700],
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       trailing:
//                           _selectedPriceOffer != null &&
//                               _selectedPriceOffer!['offerId'] ==
//                                   offer['offerId']
//                           ? Icon(Icons.check_circle, color: Colors.green)
//                           : null,
//                       onTap: () {
//                         _selectPriceOffer(offer);
//                       },
//                       dense: true,
//                     ),
//                   );
//                 }),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDateField(bool isMobile) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'التاريخ',
//           style: TextStyle(
//             fontSize: isMobile ? 14 : 16,
//             fontWeight: FontWeight.bold,
//             color: const Color(0xFF2C3E50),
//           ),
//         ),
//         SizedBox(height: isMobile ? 6 : 8),
//         InkWell(
//           onTap: () => _selectDate(context),
//           child: Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: isMobile ? 12 : 16,
//               vertical: isMobile ? 12 : 16,
//             ),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
//               border: Border.all(color: const Color(0xFF3498DB)),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   Icons.calendar_today,
//                   color: const Color(0xFF3498DB),
//                   size: isMobile ? 18 : 24,
//                 ),
//                 SizedBox(width: isMobile ? 8 : 12),
//                 Text(
//                   _formatDate(_selectedDate),
//                   style: TextStyle(fontSize: isMobile ? 14 : 16),
//                 ),
//                 const Spacer(),
//                 Text(
//                   'اختر التاريخ',
//                   style: TextStyle(
//                     color: Colors.grey,
//                     fontSize: isMobile ? 12 : 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     required String? Function(String?)? validator,
//     required bool isMobile,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: isMobile ? 14 : 16,
//             fontWeight: FontWeight.bold,
//             color: const Color(0xFF2C3E50),
//           ),
//         ),
//         SizedBox(height: isMobile ? 6 : 8),
//         TextFormField(
//           controller: controller,
//           style: TextStyle(fontSize: isMobile ? 14 : 16),
//           decoration: InputDecoration(
//             prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
//             filled: true,
//             fillColor: Colors.white,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
//               borderSide: const BorderSide(color: Color(0xFF3498DB)),
//             ),
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: isMobile ? 12 : 16,
//               vertical: isMobile ? 12 : 16,
//             ),
//           ),
//           validator: validator,
//         ),
//       ],
//     );
//   }

//   Widget _buildActionButtons(bool isMobile) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: _isSaving ? null : _saveDailyWork,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF2E86C1),
//           padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 18),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
//           ),
//         ),
//         child: _isSaving
//             ? SizedBox(
//                 width: isMobile ? 20 : 24,
//                 height: isMobile ? 20 : 24,
//                 child: const CircularProgressIndicator(color: Colors.white),
//               )
//             : Text(
//                 'حفظ الشغل اليومى',
//                 style: TextStyle(
//                   fontSize: isMobile ? 16 : 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _contractorController.dispose();
//     _trController.dispose();
//     _notesController.dispose();
//     _driverNameController.dispose();
//     _loadingLocationController.dispose();
//     _unloadingLocationController.dispose();
//     _ohdaController.dispose();
//     _kartaController.dispose();
//     super.dispose();
//   }
// }
// //

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:last/models/models.dart';

class DailyWorkPage extends StatefulWidget {
  const DailyWorkPage({super.key});

  @override
  State<DailyWorkPage> createState() => _DailyWorkPageState();
}

class _DailyWorkPageState extends State<DailyWorkPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();

  // 1. بيانات الشركة
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _companies = [];
  String? _selectedCompanyId;
  String? _selectedCompanyName;

  // 2. التاريخ
  DateTime _selectedDate = DateTime.now();

  // الحقول الجديدة
  final TextEditingController _contractorController = TextEditingController();
  final TextEditingController _trController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // 3-8. الحقول اليدوية
  final TextEditingController _driverNameController = TextEditingController();
  final TextEditingController _loadingLocationController =
      TextEditingController();
  final TextEditingController _unloadingLocationController =
      TextEditingController();
  final TextEditingController _ohdaController = TextEditingController();
  final TextEditingController _kartaController = TextEditingController();

  // حالة التحميل والحفظ
  bool _isLoading = true;
  bool _isSaving = false;

  // 9-13. عروض الأسعار
  List<Map<String, dynamic>> _priceOffers = [];
  Map<String, dynamic>? _selectedPriceOffer;
  bool _isDropdownOpen = false;

  // اقتراحات أسماء السائقين
  List<String> _driverSuggestions = [];
  bool _isLoadingSuggestions = false;
  Timer? _debounce;

  // قائمة مواقع الشركة
  List<Map<String, dynamic>> _companyLocations = [];
  String? _selectedLocationId;

  // اقتراحات أسماء المقاولين
  List<String> _contractorSuggestions = [];
  bool _isLoadingContractorSuggestions = false;
  Timer? _contractorDebounce;

  // اقتراحات أماكن التحميل
  List<String> _loadingLocationSuggestions = [];
  bool _isLoadingLoadingLocationSuggestions = false;
  Timer? _loadingLocationDebounce;

  // اقتراحات أماكن التعتيق
  List<String> _unloadingLocationSuggestions = [];
  bool _isLoadingUnloadingLocationSuggestions = false;
  Timer? _unloadingLocationDebounce;

  // شريط البحث لعروض الأسعار
  final TextEditingController _searchOfferController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCompanies();
  }

  Future<void> _loadCompanies() async {
    try {
      final snapshot = await _firestore.collection('companies').get();
      setState(() {
        _companies = snapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('خطأ في تحميل الشركات: $e');
    }
  }

  // دالة جديدة: تحميل مواقع الشركة
  Future<void> _loadCompanyLocations(String companyId) async {
    if (companyId.isEmpty) return;

    try {
      final companyDoc = await _firestore
          .collection('companies')
          .doc(companyId)
          .get();
      final companyData = companyDoc.data() as Map<String, dynamic>;

      List<dynamic> locations = companyData['locations'] ?? [];

      setState(() {
        _companyLocations = locations.map((location) {
          return {
            'id': '${companyId}_${locations.indexOf(location)}',
            'name': location['name'] ?? 'موقع غير مسمى',
            'address': location['address'] ?? '',
            'phone': location['phone'] ?? '',
            'manager': location['manager'] ?? '',
          };
        }).toList();
        _selectedLocationId = null;
      });
    } catch (e) {
      print('خطأ في تحميل مواقع الشركة: $e');
      setState(() {
        _companyLocations = [];
        _selectedLocationId = null;
      });
    }
  }

  Future<void> _loadPriceOffers(String companyId) async {
    if (companyId.isEmpty) return;

    try {
      final snapshot = await _firestore
          .collection('companies')
          .doc(companyId)
          .collection('priceOffers')
          .get();

      List<Map<String, dynamic>> allTransportations = [];

      for (final offerDoc in snapshot.docs) {
        final offerData = offerDoc.data();
        final transportations = offerData['transportations'] as List? ?? [];

        for (final transport in transportations) {
          final transportMap = transport as Map<String, dynamic>;

          allTransportations.add({
            'offerId': offerDoc.id,
            'loadingLocation': transportMap['loadingLocation'] ?? '',
            'unloadingLocation': transportMap['unloadingLocation'] ?? '',
            'vehicleType': transportMap['vehicleType'] ?? '',
            'nolon': (transportMap['nolon'] ?? transportMap['noLon'] ?? 0.0)
                .toDouble(),
            'wheelNolon':
                (transportMap['wheelNolon'] ??
                        transportMap['wheelNoLon'] ??
                        0.0)
                    .toDouble(),
            'companyOvernight': (transportMap['companyOvernight'] ?? 0.0)
                .toDouble(),
            'companyHoliday': (transportMap['companyHoliday'] ?? 0.0)
                .toDouble(),
            'wheelOvernight': (transportMap['wheelOvernight'] ?? 0.0)
                .toDouble(),
            'wheelHoliday': (transportMap['wheelHoliday'] ?? 0.0).toDouble(),
            'notes': transportMap['notes'] ?? '',
          });
        }
      }

      setState(() {
        _priceOffers = allTransportations;
      });
    } catch (e) {
      print('خطأ في تحميل عروض الأسعار: $e');
    }
  }

  Future<List<String>> _fetchDriverSuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection('dailyWork')
          .where('driverName', isGreaterThanOrEqualTo: query)
          .where('driverName', isLessThan: '${query}z')
          .orderBy('driverName')
          .limit(10)
          .get();

      final names = snapshot.docs
          .map((doc) => doc.data()['driverName'] as String? ?? '')
          .where((name) => name.toLowerCase().contains(query.toLowerCase()))
          .toSet()
          .toList();

      return names;
    } catch (e) {
      print('خطأ في جلب اقتراحات السائقين: $e');
      return [];
    }
  }

  Future<List<String>> _fetchContractorSuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection('dailyWork')
          .where('contractor', isGreaterThanOrEqualTo: query)
          .where('contractor', isLessThan: '${query}z')
          .orderBy('contractor')
          .limit(10)
          .get();

      final names = snapshot.docs
          .map((doc) => doc.data()['contractor'] as String? ?? '')
          .where(
            (name) =>
                name.toLowerCase().contains(query.toLowerCase()) &&
                name.isNotEmpty,
          )
          .toSet()
          .toList();

      return names;
    } catch (e) {
      print('خطأ في جلب اقتراحات المقاولين: $e');
      return [];
    }
  }

  Future<List<String>> _fetchLoadingLocationSuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection('dailyWork')
          .where('loadingLocation', isGreaterThanOrEqualTo: query)
          .where('loadingLocation', isLessThan: '${query}z')
          .orderBy('loadingLocation')
          .limit(10)
          .get();

      final locations = snapshot.docs
          .map((doc) => doc.data()['loadingLocation'] as String? ?? '')
          .where(
            (location) =>
                location.toLowerCase().contains(query.toLowerCase()) &&
                location.isNotEmpty,
          )
          .toSet()
          .toList();

      return locations;
    } catch (e) {
      print('خطأ في جلب اقتراحات أماكن التحميل: $e');
      return [];
    }
  }

  Future<List<String>> _fetchUnloadingLocationSuggestions(String query) async {
    if (query.isEmpty) return [];

    try {
      final snapshot = await _firestore
          .collection('dailyWork')
          .where('unloadingLocation', isGreaterThanOrEqualTo: query)
          .where('unloadingLocation', isLessThan: '${query}z')
          .orderBy('unloadingLocation')
          .limit(10)
          .get();

      final locations = snapshot.docs
          .map((doc) => doc.data()['unloadingLocation'] as String? ?? '')
          .where(
            (location) =>
                location.toLowerCase().contains(query.toLowerCase()) &&
                location.isNotEmpty,
          )
          .toSet()
          .toList();

      return locations;
    } catch (e) {
      print('خطأ في جلب اقتراحات أماكن التعتيق: $e');
      return [];
    }
  }

  void _onDriverNameChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (value.isNotEmpty && value.length >= 2) {
        setState(() => _isLoadingSuggestions = true);
        final suggestions = await _fetchDriverSuggestions(value);
        setState(() {
          _driverSuggestions = suggestions;
          _isLoadingSuggestions = false;
        });
      } else {
        setState(() => _driverSuggestions.clear());
      }
    });
  }

  void _onContractorChanged(String value) {
    if (_contractorDebounce?.isActive ?? false) _contractorDebounce?.cancel();

    _contractorDebounce = Timer(const Duration(milliseconds: 300), () async {
      if (value.isNotEmpty && value.length >= 2) {
        setState(() => _isLoadingContractorSuggestions = true);
        final suggestions = await _fetchContractorSuggestions(value);
        setState(() {
          _contractorSuggestions = suggestions;
          _isLoadingContractorSuggestions = false;
        });
      } else {
        setState(() => _contractorSuggestions.clear());
      }
    });
  }

  void _onLoadingLocationChanged(String value) {
    if (_loadingLocationDebounce?.isActive ?? false)
      _loadingLocationDebounce?.cancel();

    _loadingLocationDebounce = Timer(
      const Duration(milliseconds: 300),
      () async {
        if (value.isNotEmpty && value.length >= 2) {
          setState(() => _isLoadingLoadingLocationSuggestions = true);
          final suggestions = await _fetchLoadingLocationSuggestions(value);
          setState(() {
            _loadingLocationSuggestions = suggestions;
            _isLoadingLoadingLocationSuggestions = false;
          });
        } else {
          setState(() => _loadingLocationSuggestions.clear());
        }
      },
    );
  }

  void _onUnloadingLocationChanged(String value) {
    if (_unloadingLocationDebounce?.isActive ?? false)
      _unloadingLocationDebounce?.cancel();

    _unloadingLocationDebounce = Timer(
      const Duration(milliseconds: 300),
      () async {
        if (value.isNotEmpty && value.length >= 2) {
          setState(() => _isLoadingUnloadingLocationSuggestions = true);
          final suggestions = await _fetchUnloadingLocationSuggestions(value);
          setState(() {
            _unloadingLocationSuggestions = suggestions;
            _isLoadingUnloadingLocationSuggestions = false;
          });
        } else {
          setState(() => _unloadingLocationSuggestions.clear());
        }
      },
    );
  }

  Future<double> _getTreasuryBalance() async {
    try {
      // مجموع الإيرادات المصروفة
      final incomeSnapshot = await _firestore
          .collection('treasury_entries')
          .where('isCleared', isEqualTo: true)
          .get();

      double totalIncome = 0;
      for (var doc in incomeSnapshot.docs) {
        final amount = doc.data()['amount'];
        if (amount != null) {
          totalIncome += (amount as num).toDouble();
        }
      }

      // مجموع المصروفات
      final expenseSnapshot = await _firestore
          .collection('treasury_exits')
          .get();

      double totalExpense = 0;
      for (var doc in expenseSnapshot.docs) {
        final amount = doc.data()['amount'];
        if (amount != null) {
          totalExpense += (amount as num).toDouble();
        }
      }

      return totalIncome - totalExpense;
    } catch (e) {
      print('Error loading treasury balance: $e');
      return 0.0;
    }
  }

  Future<void> _addExpenseForOhda() async {
    try {
      final amountText = _ohdaController.text.trim();

      if (amountText.isEmpty) {
        print('لا توجد قيمة للعهدة');
        return;
      }

      final amount = double.tryParse(amountText);
      if (amount == null || amount <= 0) {
        print('قيمة العهدة غير صالحة: $amountText');
        return;
      }

      // التحقق من رصيد الخزنة
      final balance = await _getTreasuryBalance();
      if (amount > balance) {
        _showError(
          'قيمة العهدة ($amount ج) أكبر من الرصيد المتاح (${balance.toStringAsFixed(2)} ج) في الخزنة',
        );
        return;
      }

      final expenseData = {
        'amount': amount,
        'category': 'خرج',
        'createdAt': Timestamp.now(),
        'date': Timestamp.now(),
        'description':
            'عهدة لـ ${_driverNameController.text.trim()} - ${_loadingLocationController.text.trim()} إلى ${_unloadingLocationController.text.trim()}',
        'expenseType': 'عهده',
        'recipient': _driverNameController.text.trim(),
        'status': 'مكتمل',
        'relatedTo': 'dailyWork',
        'driverName': _driverNameController.text.trim(),
        'companyName': _selectedCompanyName ?? '',
        'loadingLocation': _loadingLocationController.text.trim(),
        'unloadingLocation': _unloadingLocationController.text.trim(),
        'contractor': _contractorController.text.trim(),
      };

      await _firestore.collection('treasury_exits').add(expenseData);

      print('تم حفظ العهدة في الخزنة بمبلغ: $amount');
    } catch (e) {
      print('خطأ في حفظ العهدة في الخزنة: $e');
      _showError('خطأ في حفظ العهدة في الخزنة: $e');
    }
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectPriceOffer(Map<String, dynamic> offer) {
    setState(() {
      _selectedPriceOffer = offer;
      _isDropdownOpen = false;
      _searchOfferController.clear();
    });
  }

  void _selectCompanyLocation(Map<String, dynamic> location) {
    setState(() {
      _selectedLocationId = location['id'];
    });
  }

  Future<void> _saveDailyWork() async {
    if (_selectedCompanyId == null) {
      _showError('يرجى اختيار شركة');
      return;
    }

    if (_selectedPriceOffer == null) {
      _showError('يرجى اختيار موقع من عروض الأسعار');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final dailyWork = DailyWork(
        companyId: _selectedCompanyId!,
        companyName: _selectedCompanyName!,
        date: _selectedDate,
        contractor: _contractorController.text.trim(),
        tr: _trController.text.trim(),
        driverName: _driverNameController.text.trim(),
        loadingLocation: _loadingLocationController.text.trim(),
        unloadingLocation: _unloadingLocationController.text.trim(),
        ohda: _ohdaController.text.trim(),
        karta: _kartaController.text.trim(),
        selectedRoute: '${_selectedPriceOffer!['unloadingLocation']}',
        selectedPrice: _selectedPriceOffer!['nolon'] ?? 0.0,
        wheelNolon: _selectedPriceOffer!['wheelNolon'] ?? 0.0,
        selectedVehicleType: _selectedPriceOffer!['vehicleType'] ?? '',
        selectedNotes: _notesController.text.trim(),
        priceOfferId: _selectedPriceOffer!['offerId'] ?? '',
        wheelOvernight: 0,
        wheelHoliday: 0,
        companyOvernight: 0,
        companyHoliday: 0,
        nolon: _selectedPriceOffer!['nolon'] ?? 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        companyLocationId: _selectedLocationId,
        companyLocationName: _selectedLocationId != null
            ? _companyLocations.firstWhere(
                (loc) => loc['id'] == _selectedLocationId,
                orElse: () => {'name': ''},
              )['name']
            : '',
      );

      final dailyWorkRef = await _firestore
          .collection('dailyWork')
          .add(dailyWork.toMap());

      final driverWorkData = {
        'dailyWorkId': dailyWorkRef.id,
        'companyId': _selectedCompanyId!,
        'companyName': _selectedCompanyName!,
        'date': _selectedDate,
        'contractor': _contractorController.text.trim(),
        'tr': _trController.text.trim(),
        'driverName': _driverNameController.text.trim(),
        'loadingLocation': _loadingLocationController.text.trim(),
        'unloadingLocation': _unloadingLocationController.text.trim(),
        'ohda': _ohdaController.text.trim(),
        'karta': _kartaController.text.trim(),
        'selectedRoute': '${_selectedPriceOffer!['unloadingLocation']}',
        'selectedPrice': _selectedPriceOffer!['nolon'] ?? 0.0,
        'wheelNolon': _selectedPriceOffer!['wheelNolon'] ?? 0.0,
        'selectedVehicleType': _selectedPriceOffer!['vehicleType'] ?? '',
        'selectedNotes': _notesController.text.trim(),
        'priceOfferId': _selectedPriceOffer!['offerId'] ?? '',
        'wheelOvernight': 0,
        'wheelHoliday': 0,
        'companyOvernight': 0,
        'companyHoliday': 0,
        'nolon': _selectedPriceOffer!['nolon'] ?? 0.0,
        'isPaid': false,
        'paidAmount': 0.0,
        'remainingAmount': _selectedPriceOffer!['wheelNolon'] ?? 0.0,
        'paymentDate': null,
        'driverNotes': '',
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'companyLocationId': _selectedLocationId,
        'companyLocationName': _selectedLocationId != null
            ? _companyLocations.firstWhere(
                (loc) => loc['id'] == _selectedLocationId,
                orElse: () => {'name': ''},
              )['name']
            : '',
      };

      await _firestore.collection('drivers').add(driverWorkData);

      await _addExpenseForOhda();

      _showSuccess(
        'تم حفظ الشغل اليومي بنجاح وحفظ نسخة في قسم السائقين وإضافة العهدة للخزنة',
      );
      _clearForm();
    } catch (e) {
      _showError('خطأ في الحفظ: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Widget _buildOptionalTRField(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TR (اختياري)',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        SizedBox(height: isMobile ? 6 : 8),
        TextFormField(
          controller: _trController,
          style: TextStyle(fontSize: isMobile ? 14 : 16),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.numbers, color: const Color(0xFF3498DB)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
              borderSide: const BorderSide(color: Color(0xFF3498DB)),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 12 : 16,
            ),
            hintText: 'أدخل قيمة TR (اختياري)',
          ),
        ),
      ],
    );
  }

  void _clearForm() {
    setState(() {
      _selectedCompanyId = null;
      _selectedCompanyName = null;
      _selectedDate = DateTime.now();
      _selectedPriceOffer = null;
      _priceOffers.clear();
      _contractorController.clear();
      _trController.clear();
      _notesController.clear();
      _driverNameController.clear();
      _loadingLocationController.clear();
      _unloadingLocationController.clear();
      _ohdaController.clear();
      _kartaController.clear();
      _driverSuggestions.clear();
      _contractorSuggestions.clear();
      _loadingLocationSuggestions.clear();
      _unloadingLocationSuggestions.clear();
      _companyLocations.clear();
      _selectedLocationId = null;
      _searchOfferController.clear();
    });
  }

  List<Map<String, dynamic>> _getFilteredOffers() {
    if (_priceOffers.isEmpty) return [];

    final searchText = _searchOfferController.text.trim().toLowerCase();
    if (searchText.isEmpty) return _priceOffers;

    return _priceOffers.where((offer) {
      final loading = (offer['loadingLocation'] ?? '').toString().toLowerCase();
      final unloading = (offer['unloadingLocation'] ?? '')
          .toString()
          .toLowerCase();
      final vehicleType = (offer['vehicleType'] ?? '').toString().toLowerCase();

      return loading.contains(searchText) ||
          unloading.contains(searchText) ||
          vehicleType.contains(searchText);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;

          return Column(
            children: [
              _buildCustomAppBar(isMobile),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        children: [
                          Card(
                            elevation: 8,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                isMobile ? 16 : 22,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(isMobile ? 16 : 32),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    SizedBox(height: isMobile ? 8 : 16),
                                    _buildHeaderSection(isMobile),
                                    SizedBox(height: isMobile ? 16 : 32),
                                    _buildDailyWorkForm(isMobile),
                                    SizedBox(height: isMobile ? 20 : 40),
                                    _buildActionButtons(isMobile),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCustomAppBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 12 : 20,
      ),
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
        child: Row(
          children: [
            Icon(Icons.work, color: Colors.white, size: isMobile ? 24 : 32),
            SizedBox(width: isMobile ? 8 : 12),
            Text(
              'الشغل اليومي',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 18 : 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            const Spacer(),
            _buildTimeWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeWidget() {
    return StreamBuilder<DateTime>(
      stream: Stream.periodic(
        const Duration(seconds: 1),
        (_) => DateTime.now(),
      ),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        int hour12 = now.hour % 12;
        if (hour12 == 0) hour12 = 12;

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
    );
  }

  Widget _buildHeaderSection(bool isMobile) {
    return Column(
      children: [
        Text(
          'تسجيل الشغل اليومي',
          style: TextStyle(
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          'أدخل بيانات الشغل اليومي للشركة',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDailyWorkForm(bool isMobile) {
    return Column(
      children: [
        _buildCompanyDropdown(isMobile),
        SizedBox(height: isMobile ? 16 : 20),

        _buildDateField(isMobile),
        SizedBox(height: isMobile ? 16 : 20),

        isMobile
            ? Column(
                children: [
                  _buildFieldWithSuggestions(
                    controller: _contractorController,
                    label: 'المقاول',
                    icon: Icons.business,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'هذا الحقل مطلوب';
                      }
                      return null;
                    },
                    isMobile: isMobile,
                    suggestions: _contractorSuggestions,
                    isLoading: _isLoadingContractorSuggestions,
                    onChanged: _onContractorChanged,
                  ),
                  SizedBox(height: 16),
                  _buildOptionalTRField(isMobile),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _buildFieldWithSuggestions(
                      controller: _contractorController,
                      label: 'المقاول',
                      icon: Icons.business,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'هذا الحقل مطلوب';
                        }
                        return null;
                      },
                      isMobile: isMobile,
                      suggestions: _contractorSuggestions,
                      isLoading: _isLoadingContractorSuggestions,
                      onChanged: _onContractorChanged,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(child: _buildOptionalTRField(isMobile)),
                ],
              ),
        SizedBox(height: isMobile ? 16 : 20),

        _buildDriverNameField(isMobile),
        SizedBox(height: isMobile ? 16 : 20),

        _buildCompanyLocationDropdown(isMobile),
        SizedBox(height: isMobile ? 16 : 20),

        isMobile
            ? Column(
                children: [
                  _buildFieldWithSuggestions(
                    controller: _loadingLocationController,
                    label: 'مكان التحميل',
                    icon: Icons.location_on,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'هذا الحقل مطلوب';
                      }
                      return null;
                    },
                    isMobile: isMobile,
                    suggestions: _loadingLocationSuggestions,
                    isLoading: _isLoadingLoadingLocationSuggestions,
                    onChanged: _onLoadingLocationChanged,
                  ),
                  SizedBox(height: 16),
                  _buildFieldWithSuggestions(
                    controller: _unloadingLocationController,
                    label: 'مكان التعتيق',
                    icon: Icons.location_on,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'هذا الحقل مطلوب';
                      }
                      return null;
                    },
                    isMobile: isMobile,
                    suggestions: _unloadingLocationSuggestions,
                    isLoading: _isLoadingUnloadingLocationSuggestions,
                    onChanged: _onUnloadingLocationChanged,
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _buildFieldWithSuggestions(
                      controller: _loadingLocationController,
                      label: 'مكان التحميل',
                      icon: Icons.location_on,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'هذا الحقل مطلوب';
                        }
                        return null;
                      },
                      isMobile: isMobile,
                      suggestions: _loadingLocationSuggestions,
                      isLoading: _isLoadingLoadingLocationSuggestions,
                      onChanged: _onLoadingLocationChanged,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildFieldWithSuggestions(
                      controller: _unloadingLocationController,
                      label: 'مكان التعتيق',
                      icon: Icons.location_on,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'هذا الحقل مطلوب';
                        }
                        return null;
                      },
                      isMobile: isMobile,
                      suggestions: _unloadingLocationSuggestions,
                      isLoading: _isLoadingUnloadingLocationSuggestions,
                      onChanged: _onUnloadingLocationChanged,
                    ),
                  ),
                ],
              ),
        SizedBox(height: isMobile ? 16 : 20),

        isMobile
            ? Column(
                children: [
                  _buildField(
                    controller: _ohdaController,
                    label: 'العهدة',
                    icon: Icons.assignment,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'هذا الحقل مطلوب';
                      }
                      return null;
                    },
                    isMobile: isMobile,
                  ),
                  SizedBox(height: 16),
                  _buildField(
                    controller: _kartaController,
                    label: 'الكارتة',
                    icon: Icons.credit_card,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'هذا الحقل مطلوب';
                      }
                      return null;
                    },
                    isMobile: isMobile,
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _ohdaController,
                      label: 'العهدة',
                      icon: Icons.assignment,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'هذا الحقل مطلوب';
                        }
                        return null;
                      },
                      isMobile: isMobile,
                    ),
                  ),
                ],
              ),
        SizedBox(height: isMobile ? 16 : 20),

        _buildNotesField(isMobile),
        SizedBox(height: isMobile ? 16 : 20),

        _buildPriceOffersDropdown(isMobile),
        SizedBox(height: isMobile ? 16 : 20),
      ],
    );
  }

  Widget _buildFieldWithSuggestions({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?)? validator,
    required bool isMobile,
    required List<String> suggestions,
    required bool isLoading,
    required void Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        SizedBox(height: isMobile ? 6 : 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
          ),
          child: Column(
            children: [
              TextFormField(
                controller: controller,
                onChanged: onChanged,
                style: TextStyle(fontSize: isMobile ? 14 : 16),
                decoration: InputDecoration(
                  prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                    borderSide: const BorderSide(color: Color(0xFF3498DB)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 12 : 16,
                  ),
                  hintText: 'اكتب $label',
                  suffixIcon: isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
                validator: validator,
              ),
              if (suggestions.isNotEmpty && controller.text.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: suggestions
                        .map(
                          (suggestion) => ListTile(
                            leading: Icon(icon, color: Colors.blue, size: 20),
                            title: Text(
                              suggestion,
                              style: TextStyle(fontSize: isMobile ? 14 : 16),
                            ),
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            onTap: () {
                              setState(() {
                                controller.text = suggestion;
                                if (label.contains('مقاول')) {
                                  _contractorSuggestions.clear();
                                } else if (label.contains('تحميل')) {
                                  _loadingLocationSuggestions.clear();
                                } else if (label.contains('تعتيق')) {
                                  _unloadingLocationSuggestions.clear();
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyLocationDropdown(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'موقع الشركة (اختياري)',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        SizedBox(height: isMobile ? 6 : 8),
        InkWell(
          onTap: () {
            _showCompanyLocationsDialog(isMobile);
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 12 : 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
              border: Border.all(color: Colors.purple),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.purple,
                  size: isMobile ? 18 : 22,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _selectedLocationId != null
                      ? Text(
                          _companyLocations.firstWhere(
                            (loc) => loc['id'] == _selectedLocationId,
                            orElse: () => {'name': ''},
                          )['name'],
                          style: TextStyle(fontSize: isMobile ? 14 : 16),
                        )
                      : Text(
                          'اختر موقع الشركة',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: Colors.grey[600],
                          ),
                        ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.purple),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCompanyLocationsDialog(bool isMobile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            width: isMobile ? MediaQuery.of(context).size.width * 0.9 : 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'اختر موقع الشركة',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                ),
                Expanded(
                  child: _companyLocations.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'لا توجد مواقع لهذه الشركة',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _companyLocations.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return ListTile(
                                leading: Icon(Icons.cancel, color: Colors.grey),
                                title: Text('بدون موقع محدد'),
                                onTap: () {
                                  setState(() {
                                    _selectedLocationId = null;
                                  });
                                  Navigator.pop(context);
                                },
                              );
                            }

                            final location = _companyLocations[index - 1];
                            return ListTile(
                              leading: Icon(
                                Icons.location_on,
                                color: _selectedLocationId == location['id']
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                              title: Text(
                                location['name'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              trailing: _selectedLocationId == location['id']
                                  ? Icon(Icons.check, color: Colors.green)
                                  : null,
                              onTap: () {
                                _selectCompanyLocation(location);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'إغلاق',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotesField(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ملاحظات (اختياري)',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        SizedBox(height: isMobile ? 6 : 8),
        TextFormField(
          controller: _notesController,
          style: TextStyle(fontSize: isMobile ? 14 : 16),
          maxLines: 3,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.note, color: const Color(0xFF3498DB)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
              borderSide: const BorderSide(color: Color(0xFF3498DB)),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 14 : 18,
            ),
            hintText: 'أدخل ملاحظات إضافية (اختياري)...',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDriverNameField(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اسم السائق',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        SizedBox(height: isMobile ? 6 : 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
          ),
          child: Column(
            children: [
              TextFormField(
                controller: _driverNameController,
                onChanged: _onDriverNameChanged,
                style: TextStyle(fontSize: isMobile ? 14 : 16),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.person,
                    color: const Color(0xFF3498DB),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                    borderSide: const BorderSide(color: Color(0xFF3498DB)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 12 : 16,
                  ),
                  hintText: 'اكتب اسم السائق',
                  suffixIcon: _isLoadingSuggestions
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'هذا الحقل مطلوب';
                  }
                  return null;
                },
              ),
              if (_driverSuggestions.isNotEmpty &&
                  _driverNameController.text.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: _driverSuggestions
                        .map(
                          (suggestion) => ListTile(
                            leading: Icon(
                              Icons.person_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                            title: Text(
                              suggestion,
                              style: TextStyle(fontSize: isMobile ? 14 : 16),
                            ),
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            onTap: () {
                              setState(() {
                                _driverNameController.text = suggestion;
                                _driverSuggestions.clear();
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompanyDropdown(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'اختر الشركة',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        SizedBox(height: isMobile ? 6 : 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
            border: Border.all(color: const Color(0xFF3498DB)),
          ),
          child: _isLoading
              ? Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 16,
                    vertical: isMobile ? 12 : 16,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: isMobile ? 16 : 20,
                        height: isMobile ? 16 : 20,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: isMobile ? 8 : 12),
                      Text(
                        'جاري تحميل الشركات...',
                        style: TextStyle(fontSize: isMobile ? 14 : 16),
                      ),
                    ],
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCompanyId,
                    isExpanded: true,
                    hint: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 16,
                      ),
                      child: Text(
                        'اختر شركة',
                        style: TextStyle(fontSize: isMobile ? 14 : 16),
                      ),
                    ),
                    items: _companies.map((company) {
                      final data = company.data();
                      final companyName = data['companyName'] ?? '';
                      return DropdownMenuItem<String>(
                        value: company.id,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12 : 16,
                          ),
                          child: Text(
                            companyName,
                            style: TextStyle(fontSize: isMobile ? 14 : 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedCompanyId = newValue;
                        _selectedCompanyName = newValue != null
                            ? _companies
                                  .firstWhere(
                                    (company) => company.id == newValue,
                                  )
                                  .data()['companyName']
                            : null;
                        _priceOffers.clear();
                        _selectedPriceOffer = null;
                        _companyLocations.clear();
                        _selectedLocationId = null;

                        if (newValue != null) {
                          _loadPriceOffers(newValue);
                          _loadCompanyLocations(newValue);
                        }
                      });
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPriceOffersDropdown(bool isMobile) {
    final filteredOffers = _getFilteredOffers();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مطابقة نولون',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        SizedBox(height: isMobile ? 6 : 8),

        if (_isDropdownOpen && _priceOffers.isNotEmpty)
          Container(
            margin: EdgeInsets.only(bottom: 8),
            child: TextFormField(
              controller: _searchOfferController,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.orange),
                hintText: 'ابحث بالمحطة أو الوجهة...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                  borderSide: BorderSide(color: Colors.orange),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 12 : 16,
                  vertical: isMobile ? 12 : 16,
                ),
              ),
            ),
          ),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
            border: Border.all(color: Colors.orange),
          ),
          child: ExpansionTile(
            title: Row(
              children: [
                Icon(Icons.map, color: Colors.orange, size: isMobile ? 20 : 24),
                SizedBox(width: 8),
                Expanded(
                  child: _selectedPriceOffer != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  "${_selectedPriceOffer!['loadingLocation']} >>${_selectedPriceOffer!['unloadingLocation']}==${_selectedPriceOffer!['vehicleType']}" ??
                                      '',
                                  style: TextStyle(
                                    fontSize: isMobile ? 12 : 14,
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        )
                      : Text(
                          'اختر مسار من القائمة',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: Colors.grey[600],
                          ),
                        ),
                ),
              ],
            ),
            trailing: Icon(
              _isDropdownOpen ? Icons.expand_less : Icons.expand_more,
              color: Colors.orange,
            ),
            onExpansionChanged: (expanded) {
              setState(() {
                _isDropdownOpen = expanded;
                _searchOfferController.clear();
              });

              if (expanded &&
                  _selectedCompanyId != null &&
                  _priceOffers.isEmpty) {
                _loadPriceOffers(_selectedCompanyId!);
              }
            },
            children: [
              if (_selectedCompanyId == null)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'يرجى اختيار شركة أولاً',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                )
              else if (_priceOffers.isEmpty)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'لا توجد عروض أسعار لهذه الشركة',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                )
              else if (filteredOffers.isEmpty)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'لا توجد نتائج مطابقة للبحث',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Container(
                  constraints: BoxConstraints(maxHeight: 300),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredOffers.length,
                    itemBuilder: (context, index) {
                      final offer = filteredOffers[index];
                      return _buildOfferItem(offer, isMobile);
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOfferItem(Map<String, dynamic> offer, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: ListTile(
        leading: Icon(Icons.route, color: Colors.blue),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${offer['loadingLocation']} >>${offer['unloadingLocation']}==${offer['vehicleType']}" ??
                  '',
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: Colors.blue[700],
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing:
            _selectedPriceOffer != null &&
                _selectedPriceOffer!['offerId'] == offer['offerId']
            ? Icon(Icons.check_circle, color: Colors.green)
            : null,
        onTap: () {
          _selectPriceOffer(offer);
        },
        dense: true,
      ),
    );
  }

  Widget _buildDateField(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التاريخ',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        SizedBox(height: isMobile ? 6 : 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 12 : 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
              border: Border.all(color: const Color(0xFF3498DB)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: const Color(0xFF3498DB),
                  size: isMobile ? 18 : 24,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Text(
                  _formatDate(_selectedDate),
                  style: TextStyle(fontSize: isMobile ? 14 : 16),
                ),
                const Spacer(),
                Text(
                  'اختر التاريخ',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?)? validator,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        SizedBox(height: isMobile ? 6 : 8),
        TextFormField(
          controller: controller,
          style: TextStyle(fontSize: isMobile ? 14 : 16),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
              borderSide: const BorderSide(color: Color(0xFF3498DB)),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 16,
              vertical: isMobile ? 12 : 16,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isMobile) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveDailyWork,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E86C1),
          padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
          ),
        ),
        child: _isSaving
            ? SizedBox(
                width: isMobile ? 20 : 24,
                height: isMobile ? 20 : 24,
                child: const CircularProgressIndicator(color: Colors.white),
              )
            : Text(
                'حفظ الشغل اليومى',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _contractorDebounce?.cancel();
    _loadingLocationDebounce?.cancel();
    _unloadingLocationDebounce?.cancel();
    _contractorController.dispose();
    _trController.dispose();
    _notesController.dispose();
    _driverNameController.dispose();
    _loadingLocationController.dispose();
    _unloadingLocationController.dispose();
    _ohdaController.dispose();
    _kartaController.dispose();
    _searchOfferController.dispose();
    super.dispose();
  }
}
