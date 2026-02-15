// // ================================
// // صفحة تعديل الفاتورة
// // ================================
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class EditInvoicePage extends StatefulWidget {
//   final Map<String, dynamic> invoice;
//   final String companyId;
//   final String companyName;
//   final VoidCallback onInvoiceUpdated;

//   const EditInvoicePage({
//     super.key,
//     required this.invoice,
//     required this.companyId,
//     required this.companyName,
//     required this.onInvoiceUpdated,
//   });

//   @override
//   State<EditInvoicePage> createState() => _EditInvoicePageState();
// }

// class _EditInvoicePageState extends State<EditInvoicePage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   late TextEditingController _invoiceNameController;
//   late TextEditingController _invoiceNotesController;
//   late String _selectedMonth;

//   List<Map<String, dynamic>> _allCompanyTrips = [];
//   List<Map<String, dynamic>> _selectedTrips = [];
//   List<Map<String, dynamic>> _availableTrips = [];

//   bool _isLoading = true;
//   bool _isSaving = false;

//   final List<String> _monthsList = [
//     'يناير',
//     'فبراير',
//     'مارس',
//     'أبريل',
//     'مايو',
//     'يونيو',
//     'يوليو',
//     'أغسطس',
//     'سبتمبر',
//     'أكتوبر',
//     'نوفمبر',
//     'ديسمبر',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//   }

//   Future<void> _initializeData() async {
//     _invoiceNameController = TextEditingController(
//       text: widget.invoice['name'] ?? '',
//     );
//     _invoiceNotesController = TextEditingController(
//       text: widget.invoice['notes'] ?? '',
//     );
//     _selectedMonth =
//         widget.invoice['month'] ?? _monthsList[DateTime.now().month - 1];

//     await _loadCompanyTrips();
//   }

//   @override
//   void dispose() {
//     _invoiceNameController.dispose();
//     _invoiceNotesController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadCompanyTrips() async {
//     setState(() => _isLoading = true);

//     try {
//       // تحميل جميع رحلات الشركة
//       final tripsSnapshot = await _firestore
//           .collection('dailyWork')
//           .where('companyId', isEqualTo: widget.companyId)
//           .orderBy('date', descending: false)
//           .get();

//       final List<String> currentInvoiceTripIds =
//           (widget.invoice['tripIds'] as List<dynamic>?)
//               ?.map((e) => e.toString())
//               .toList() ??
//           [];

//       final List<Map<String, dynamic>> allTrips = [];

//       for (final doc in tripsSnapshot.docs) {
//         final data = doc.data();
//         final tripDate = (data['date'] as Timestamp?)?.toDate();
//         final tripId = doc.id;

//         allTrips.add({
//           'id': tripId,
//           'date': tripDate,
//           'companyName': widget.companyName,
//           'companyId': widget.companyId,
//           'driverName': data['driverName'] ?? 'غير معروف',
//           'nolon': (data['noLon'] ?? data['nolon'] ?? 0).toDouble(),
//           'companyOvernight': (data['companyOvernight'] ?? 0).toDouble(),
//           'companyHoliday': (data['companyHoliday'] ?? 0).toDouble(),
//           'selectedPrice': (data['selectedPrice'] ?? 0).toDouble(),
//           'karta': data['karta'] ?? '',
//           'ohda': data['ohda'] ?? '',
//           'selectedRoute': data['loadingLocation'] ?? '',
//           'selectedRoute2': data['unloadingLocation'] ?? '',
//           'loadingLocation': data['loadingLocation'] ?? '',
//           'unloadingLocation': data['unloadingLocation'] ?? '',
//           'vehicleType': data['selectedVehicleType'] ?? '',
//           'notes': data['selectedNotes'] ?? '',
//           'tr': data['tr'] ?? '',
//           'companyLocationName': data['companyLocationName'] ?? '',
//         });
//       }

//       // ترتيب الرحلات حسب التاريخ
//       allTrips.sort((a, b) {
//         final dateA = a['date'] as DateTime? ?? DateTime(1900);
//         final dateB = b['date'] as DateTime? ?? DateTime(1900);
//         return dateB.compareTo(dateA);
//       });

//       // تقسيم الرحلات إلى مختارة ومتاحة
//       final selectedTrips = allTrips
//           .where((trip) => currentInvoiceTripIds.contains(trip['id']))
//           .toList();

//       final availableTrips = allTrips
//           .where((trip) => !currentInvoiceTripIds.contains(trip['id']))
//           .toList();

//       if (mounted) {
//         setState(() {
//           _allCompanyTrips = allTrips;
//           _selectedTrips = selectedTrips;
//           _availableTrips = availableTrips;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint('خطأ في تحميل الرحلات: $e');
//       if (mounted) {
//         setState(() => _isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('خطأ في تحميل الرحلات: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   void _toggleTripSelection(Map<String, dynamic> trip, bool isSelected) {
//     setState(() {
//       if (isSelected) {
//         _selectedTrips.add(trip);
//         _availableTrips.removeWhere((t) => t['id'] == trip['id']);
//       } else {
//         _availableTrips.add(trip);
//         _selectedTrips.removeWhere((t) => t['id'] == trip['id']);
//       }

//       // إعادة ترتيب القوائم
//       _selectedTrips.sort((a, b) {
//         final dateA = a['date'] as DateTime? ?? DateTime(1900);
//         final dateB = b['date'] as DateTime? ?? DateTime(1900);
//         return dateB.compareTo(dateA);
//       });

//       _availableTrips.sort((a, b) {
//         final dateA = a['date'] as DateTime? ?? DateTime(1900);
//         final dateB = b['date'] as DateTime? ?? DateTime(1900);
//         return dateB.compareTo(dateA);
//       });
//     });
//   }

//   Future<void> _saveInvoiceChanges() async {
//     if (_selectedTrips.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('يجب اختيار رحلة واحدة على الأقل'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     if (_invoiceNameController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('يرجى إدخال اسم الفاتورة'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     setState(() => _isSaving = true);

//     try {
//       // حساب الإجماليات الجديدة
//       double totalNolon = 0;
//       double totalOvernight = 0;
//       double totalHoliday = 0;
//       double totalKartaValue = 0;
//       List<String> tripIds = [];
//       List<Map<String, dynamic>> invoiceTripDetails = [];

//       for (var trip in _selectedTrips) {
//         totalNolon += trip['nolon'];
//         totalOvernight += trip['companyOvernight'];
//         totalHoliday += trip['companyHoliday'];
//         tripIds.add(trip['id']);

//         final karta = trip['karta']?.toString() ?? '';
//         double kartaValue = 0;
//         try {
//           final cleanedKarta = karta.trim();
//           if (cleanedKarta.isNotEmpty) {
//             kartaValue = double.tryParse(cleanedKarta) ?? 0;
//           }
//         } catch (e) {
//           debugPrint('خطأ في تحويل الكارتة إلى رقم: $karta');
//         }
//         totalKartaValue += kartaValue;

//         invoiceTripDetails.add({
//           'selectedRoute': trip['selectedRoute'],
//           'selectedRoute2': trip['selectedRoute2'],
//           'vehicleType': trip['vehicleType'],
//           'nolon': trip['nolon'],
//           'companyOvernight': trip['companyOvernight'],
//           'companyHoliday': trip['companyHoliday'],
//           'tr': trip['tr'],
//           'companyLocationName': trip['companyLocationName'],
//           'date': trip['date'],
//           'karta': karta,
//           'kartaValue': kartaValue,
//         });
//       }

//       double totalAmount = totalNolon + totalOvernight + totalHoliday;

//       // استخدام batch للعمليات المتعددة
//       final batch = _firestore.batch();
//       final invoiceRef = _firestore
//           .collection('invoices')
//           .doc(widget.invoice['id']);

//       // تحديث بيانات الفاتورة
//       batch.update(invoiceRef, {
//         'name': _invoiceNameController.text.trim(),
//         'totalAmount': totalAmount,
//         'nolonTotal': totalNolon,
//         'overnightTotal': totalOvernight,
//         'holidayTotal': totalHoliday,
//         'kartaValue': totalKartaValue,
//         'totalWithKarta': totalAmount + totalKartaValue,
//         'tripIds': tripIds,
//         'tripDetails': invoiceTripDetails,
//         'tripCount': tripIds.length,
//         'kartaDetails': _selectedTrips
//             .map((trip) => trip['karta'] ?? '')
//             .toList(),
//         'notes': _invoiceNotesController.text.trim(),
//         'month': _selectedMonth,
//         'updatedAt': Timestamp.now(),
//       });

//       // الحصول على قائمة الرحلات القديمة
//       final oldTripIds =
//           (widget.invoice['tripIds'] as List<dynamic>?)
//               ?.map((e) => e.toString())
//               .toList() ??
//           [];

//       // تحديث حالة الرحلات القديمة (إزالة hasInvoice)
//       for (var tripId in oldTripIds) {
//         if (!tripIds.contains(tripId)) {
//           batch.update(_firestore.collection('dailyWork').doc(tripId), {
//             'hasInvoice': false,
//           });
//         }
//       }

//       // تحديث حالة الرحلات الجديدة (إضافة hasInvoice)
//       for (var tripId in tripIds) {
//         if (!oldTripIds.contains(tripId)) {
//           batch.update(_firestore.collection('dailyWork').doc(tripId), {
//             'hasInvoice': true,
//           });
//         }
//       }

//       await batch.commit();

//       if (mounted) {
//         widget.onInvoiceUpdated();
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('تم تحديث الفاتورة بنجاح'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint('خطأ في تحديث الفاتورة: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('خطأ في تحديث الفاتورة: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isSaving = false);
//       }
//     }
//   }

//   bool get _isMobile {
//     final size = MediaQuery.of(context).size;
//     return size.width < 600;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('تعديل الفاتورة'),
//         backgroundColor: const Color(0xFF1B4F72),
//         foregroundColor: Colors.white,
//         actions: [
//           IconButton(
//             icon: _isSaving
//                 ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(color: Colors.white),
//                   )
//                 : const Icon(Icons.save),
//             onPressed: _isSaving ? null : _saveInvoiceChanges,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 // معلومات الفاتورة
//                 Container(
//                   padding: EdgeInsets.all(_isMobile ? 12 : 16),
//                   color: Colors.blue[50],
//                   child: Column(
//                     children: [
//                       TextField(
//                         controller: _invoiceNameController,
//                         decoration: InputDecoration(
//                           labelText: 'اسم الفاتورة',
//                           prefixIcon: const Icon(Icons.receipt),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       TextField(
//                         controller: _invoiceNotesController,
//                         decoration: InputDecoration(
//                           labelText: 'ملاحظات (اختياري)',
//                           prefixIcon: const Icon(Icons.note),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white,
//                         ),
//                         maxLines: 2,
//                       ),
//                       const SizedBox(height: 12),
//                       DropdownButtonFormField<String>(
//                         value: _selectedMonth,
//                         decoration: InputDecoration(
//                           labelText: 'شهر الإدراج',
//                           prefixIcon: const Icon(Icons.calendar_month),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           filled: true,
//                           fillColor: Colors.white,
//                         ),
//                         items: _monthsList.map((String month) {
//                           return DropdownMenuItem<String>(
//                             value: month,
//                             child: Text(month),
//                           );
//                         }).toList(),
//                         onChanged: (String? newValue) {
//                           if (newValue != null) {
//                             setState(() {
//                               _selectedMonth = newValue;
//                             });
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),

//                 // إحصائيات سريعة
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   color: Colors.grey[100],
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildQuickStat(
//                         'الرحلات المختارة',
//                         _selectedTrips.length.toString(),
//                         Colors.green,
//                       ),
//                       Container(width: 1, height: 30, color: Colors.grey[300]),
//                       _buildQuickStat(
//                         'الرحلات المتاحة',
//                         _availableTrips.length.toString(),
//                         Colors.blue,
//                       ),
//                       Container(width: 1, height: 30, color: Colors.grey[300]),
//                       _buildQuickStat(
//                         'الإجمالي',
//                         _formatCurrency(
//                           _selectedTrips.fold<double>(0, (sum, trip) {
//                             return sum +
//                                 (trip['nolon'] ?? 0) +
//                                 (trip['companyOvernight'] ?? 0) +
//                                 (trip['companyHoliday'] ?? 0);
//                           }),
//                         ),
//                         Colors.orange,
//                       ),
//                     ],
//                   ),
//                 ),

//                 // تبويب الرحلات
//                 Container(
//                   color: Colors.white,
//                   child: Row(
//                     children: [
//                       _buildTab('الرحلات المختارة', 0),
//                       _buildTab('الرحلات المتاحة', 1),
//                     ],
//                   ),
//                 ),

//                 // محتوى الرحلات
//                 Expanded(
//                   child: DefaultTabController(
//                     length: 2,
//                     child: Column(
//                       children: [
//                         const TabBar(
//                           tabs: [
//                             Tab(text: 'الرحلات المختارة'),
//                             Tab(text: 'الرحلات المتاحة'),
//                           ],
//                           labelColor: Color(0xFF3498DB),
//                           unselectedLabelColor: Colors.grey,
//                           indicatorColor: Color(0xFF3498DB),
//                         ),
//                         Expanded(
//                           child: TabBarView(
//                             children: [
//                               _buildTripsList(
//                                 _selectedTrips,
//                                 isSelectedList: true,
//                               ),
//                               _buildTripsList(
//                                 _availableTrips,
//                                 isSelectedList: false,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _buildQuickStat(String label, String value, Color color) {
//     return Column(
//       children: [
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: _isMobile ? 16 : 18,
//             fontWeight: FontWeight.bold,
//             color: color,
//           ),
//         ),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: _isMobile ? 10 : 12,
//             color: Colors.grey[600],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTab(String title, int index) {
//     return Expanded(
//       child: InkWell(
//         onTap: () {
//           // يمكن استخدام TabController إذا أردت
//         },
//         child: Container(
//           padding: const EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             border: Border(
//               bottom: BorderSide(
//                 color: index == 0 ? const Color(0xFF3498DB) : Colors.grey[300]!,
//                 width: 2,
//               ),
//             ),
//           ),
//           child: Text(
//             title,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: index == 0 ? const Color(0xFF3498DB) : Colors.grey,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTripsList(
//     List<Map<String, dynamic>> trips, {
//     required bool isSelectedList,
//   }) {
//     if (trips.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               isSelectedList ? Icons.remove_circle : Icons.add_circle,
//               size: 60,
//               color: Colors.grey[400],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               isSelectedList ? 'لا توجد رحلات مختارة' : 'لا توجد رحلات متاحة',
//               style: TextStyle(fontSize: 16, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(8),
//       itemCount: trips.length,
//       itemBuilder: (context, index) {
//         final trip = trips[index];
//         final date = trip['date'] as DateTime?;

//         return Card(
//           margin: const EdgeInsets.symmetric(vertical: 4),
//           child: ListTile(
//             leading: CircleAvatar(
//               backgroundColor: isSelectedList ? Colors.green : Colors.blue,
//               radius: 18,
//               child: Text(
//                 '${index + 1}',
//                 style: const TextStyle(color: Colors.white, fontSize: 12),
//               ),
//             ),
//             title: Text(
//               '${trip['driverName']} - ${trip['tr'] ?? 'بدون TR'}',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//             subtitle: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '${trip['selectedRoute']} → ${trip['selectedRoute2']}',
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 Row(
//                   children: [
//                     if (trip['nolon'] > 0)
//                       Expanded(
//                         child: Text(
//                           'نولون: ${_formatCurrency(trip['nolon'])}',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.green[700],
//                           ),
//                         ),
//                       ),
//                     if (trip['companyOvernight'] > 0)
//                       Expanded(
//                         child: Text(
//                           'مبيت: ${_formatCurrency(trip['companyOvernight'])}',
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.orange[700],
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//                 if (trip['companyHoliday'] > 0)
//                   Text(
//                     'عطلة: ${_formatCurrency(trip['companyHoliday'])}',
//                     style: TextStyle(fontSize: 12, color: Colors.red[700]),
//                   ),
//               ],
//             ),
//             trailing: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   date != null ? DateFormat('dd/MM/yy').format(date) : '-',
//                   style: const TextStyle(fontSize: 12),
//                 ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   icon: Icon(
//                     isSelectedList ? Icons.remove_circle : Icons.add_circle,
//                     color: isSelectedList ? Colors.red : Colors.green,
//                   ),
//                   onPressed: () => _toggleTripSelection(trip, !isSelectedList),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   String _formatCurrency(double amount) {
//     return '${amount.toStringAsFixed(2)} ج';
//   }
// }
// ================================
// صفحة تعديل الفاتورة - نسخة محسنة
// ================================
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditInvoicePage extends StatefulWidget {
  final Map<String, dynamic> invoice;
  final String companyId;
  final String companyName;
  final VoidCallback onInvoiceUpdated;

  const EditInvoicePage({
    super.key,
    required this.invoice,
    required this.companyId,
    required this.companyName,
    required this.onInvoiceUpdated,
  });

  @override
  State<EditInvoicePage> createState() => _EditInvoicePageState();
}

class _EditInvoicePageState extends State<EditInvoicePage>
    with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late TextEditingController _invoiceNameController;
  late TextEditingController _invoiceNotesController;
  late String _selectedMonth;

  // Tab Controller
  late TabController _tabController;

  // قوائم الرحلات
  List<Map<String, dynamic>> _selectedTrips = [];
  List<Map<String, dynamic>> _availableTrips = [];

  // معرفات الرحلات المفوتورة من فواتير أخرى
  List<String> _otherInvoicedTripIds = [];

  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _monthsList = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    _invoiceNameController = TextEditingController(
      text: widget.invoice['name'] ?? '',
    );
    _invoiceNotesController = TextEditingController(
      text: widget.invoice['notes'] ?? '',
    );
    _selectedMonth =
        widget.invoice['month'] ?? _monthsList[DateTime.now().month - 1];

    await _loadCompanyTrips();
  }

  @override
  void dispose() {
    _invoiceNameController.dispose();
    _invoiceNotesController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // تحميل معرفات الرحلات المفوتورة من فواتير أخرى
  Future<List<String>> _loadOtherInvoicedTripIds(
    String companyId,
    String currentInvoiceId,
  ) async {
    try {
      final invoicesSnapshot = await _firestore
          .collection('invoices')
          .where('companyId', isEqualTo: companyId)
          .get();

      final List<String> invoicedTripIds = [];

      for (final doc in invoicesSnapshot.docs) {
        // تخطي الفاتورة الحالية
        if (doc.id == currentInvoiceId) continue;

        final data = doc.data();
        final tripIds = (data['tripIds'] as List<dynamic>? ?? []);
        for (var tripId in tripIds) {
          invoicedTripIds.add(tripId.toString());
        }
      }

      return invoicedTripIds;
    } catch (e) {
      debugPrint('خطأ في تحميل ID الرحلات المفوتورة: $e');
      return [];
    }
  }

  Future<void> _loadCompanyTrips() async {
    setState(() => _isLoading = true);

    try {
      // تحميل معرفات الرحلات المفوتورة من فواتير أخرى
      _otherInvoicedTripIds = await _loadOtherInvoicedTripIds(
        widget.companyId,
        widget.invoice['id'],
      );

      // تحميل جميع رحلات الشركة
      final tripsSnapshot = await _firestore
          .collection('dailyWork')
          .where('companyId', isEqualTo: widget.companyId)
          .orderBy('date', descending: true)
          .get();

      final List<String> currentInvoiceTripIds =
          (widget.invoice['tripIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      final List<Map<String, dynamic>> allTrips = [];

      for (final doc in tripsSnapshot.docs) {
        final data = doc.data();
        final tripDate = (data['date'] as Timestamp?)?.toDate();
        final tripId = doc.id;

        allTrips.add({
          'id': tripId,
          'date': tripDate,
          'companyName': widget.companyName,
          'companyId': widget.companyId,
          'driverName': data['driverName'] ?? 'غير معروف',
          'nolon': (data['noLon'] ?? data['nolon'] ?? 0).toDouble(),
          'companyOvernight': (data['companyOvernight'] ?? 0).toDouble(),
          'companyHoliday': (data['companyHoliday'] ?? 0).toDouble(),
          'selectedPrice': (data['selectedPrice'] ?? 0).toDouble(),
          'karta': data['karta'] ?? '',
          'ohda': data['ohda'] ?? '',
          'selectedRoute': data['loadingLocation'] ?? '',
          'selectedRoute2': data['unloadingLocation'] ?? '',
          'loadingLocation': data['loadingLocation'] ?? '',
          'unloadingLocation': data['unloadingLocation'] ?? '',
          'vehicleType': data['selectedVehicleType'] ?? '',
          'notes': data['selectedNotes'] ?? '',
          'tr': data['tr'] ?? '',
          'companyLocationName': data['companyLocationName'] ?? '',
        });
      }

      // تقسيم الرحلات:
      // 1. الرحلات المختارة حالياً في الفاتورة
      // 2. الرحلات المتاحة (غير مفوتورة وليست في فواتير أخرى)
      final selectedTrips = allTrips
          .where((trip) => currentInvoiceTripIds.contains(trip['id']))
          .toList();

      final availableTrips = allTrips
          .where(
            (trip) =>
                !currentInvoiceTripIds.contains(trip['id']) &&
                !_otherInvoicedTripIds.contains(trip['id']),
          )
          .toList();

      if (mounted) {
        setState(() {
          _selectedTrips = selectedTrips;
          _availableTrips = availableTrips;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('خطأ في تحميل الرحلات: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackbar('خطأ في تحميل الرحلات: $e');
      }
    }
  }

  void _toggleTripSelection(Map<String, dynamic> trip, bool addToSelected) {
    setState(() {
      if (addToSelected) {
        _selectedTrips.add(trip);
        _availableTrips.removeWhere((t) => t['id'] == trip['id']);
      } else {
        _availableTrips.add(trip);
        _selectedTrips.removeWhere((t) => t['id'] == trip['id']);
      }

      // إعادة ترتيب القوائم (الأحدث أولاً)
      _sortTripsByDate();
    });
  }

  void _sortTripsByDate() {
    _selectedTrips.sort((a, b) {
      final dateA = a['date'] as DateTime? ?? DateTime(1900);
      final dateB = b['date'] as DateTime? ?? DateTime(1900);
      return dateB.compareTo(dateA);
    });

    _availableTrips.sort((a, b) {
      final dateA = a['date'] as DateTime? ?? DateTime(1900);
      final dateB = b['date'] as DateTime? ?? DateTime(1900);
      return dateB.compareTo(dateA);
    });
  }

  double _calculateSelectedTotal() {
    return _selectedTrips.fold<double>(0, (sum, trip) {
      return sum +
          (trip['nolon'] ?? 0).toDouble() +
          (trip['companyOvernight'] ?? 0).toDouble() +
          (trip['companyHoliday'] ?? 0).toDouble();
    });
  }

  double _calculateSelectedKartaValue() {
    return _selectedTrips.fold<double>(0, (sum, trip) {
      final karta = trip['karta']?.toString() ?? '';
      try {
        final cleanedKarta = karta.trim();
        if (cleanedKarta.isNotEmpty) {
          return sum + (double.tryParse(cleanedKarta) ?? 0);
        }
      } catch (e) {}
      return sum;
    });
  }

  Future<void> _saveInvoiceChanges() async {
    if (_selectedTrips.isEmpty) {
      _showErrorSnackbar('يجب اختيار رحلة واحدة على الأقل');
      return;
    }

    if (_invoiceNameController.text.trim().isEmpty) {
      _showErrorSnackbar('يرجى إدخال اسم الفاتورة');
      return;
    }

    setState(() => _isSaving = true);

    try {
      // حساب الإجماليات الجديدة
      double totalNolon = 0;
      double totalOvernight = 0;
      double totalHoliday = 0;
      double totalKartaValue = 0;
      List<String> tripIds = [];
      List<Map<String, dynamic>> invoiceTripDetails = [];

      for (var trip in _selectedTrips) {
        totalNolon += (trip['nolon'] ?? 0).toDouble();
        totalOvernight += (trip['companyOvernight'] ?? 0).toDouble();
        totalHoliday += (trip['companyHoliday'] ?? 0).toDouble();
        tripIds.add(trip['id']);

        final karta = trip['karta']?.toString() ?? '';
        double kartaValue = 0;
        try {
          final cleanedKarta = karta.trim();
          if (cleanedKarta.isNotEmpty) {
            kartaValue = double.tryParse(cleanedKarta) ?? 0;
          }
        } catch (e) {}
        totalKartaValue += kartaValue;

        invoiceTripDetails.add({
          'selectedRoute': trip['selectedRoute'] ?? '',
          'selectedRoute2': trip['selectedRoute2'] ?? '',
          'vehicleType': trip['vehicleType'] ?? '',
          'nolon': (trip['nolon'] ?? 0).toDouble(),
          'companyOvernight': (trip['companyOvernight'] ?? 0).toDouble(),
          'companyHoliday': (trip['companyHoliday'] ?? 0).toDouble(),
          'tr': trip['tr'] ?? '',
          'companyLocationName': trip['companyLocationName'] ?? '',
          'date': trip['date'],
          'karta': karta,
          'kartaValue': kartaValue,
        });
      }

      double totalAmount = totalNolon + totalOvernight + totalHoliday;

      // استخدام batch للعمليات المتعددة
      final batch = _firestore.batch();
      final invoiceRef = _firestore
          .collection('invoices')
          .doc(widget.invoice['id']);

      // تحديث بيانات الفاتورة
      batch.update(invoiceRef, {
        'name': _invoiceNameController.text.trim(),
        'totalAmount': totalAmount,
        'nolonTotal': totalNolon,
        'overnightTotal': totalOvernight,
        'holidayTotal': totalHoliday,
        'kartaValue': totalKartaValue,
        'totalWithKarta': totalAmount + totalKartaValue,
        'tripIds': tripIds,
        'tripDetails': invoiceTripDetails,
        'tripCount': tripIds.length,
        'kartaDetails': _selectedTrips
            .map((trip) => trip['karta'] ?? '')
            .toList(),
        'notes': _invoiceNotesController.text.trim(),
        'month': _selectedMonth,
        'updatedAt': Timestamp.now(),
      });

      // الحصول على قائمة الرحلات القديمة
      final oldTripIds =
          (widget.invoice['tripIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      // تحديث حالة الرحلات القديمة (إزالة hasInvoice)
      for (var tripId in oldTripIds) {
        if (!tripIds.contains(tripId)) {
          batch.update(_firestore.collection('dailyWork').doc(tripId), {
            'hasInvoice': false,
          });
        }
      }

      // تحديث حالة الرحلات الجديدة (إضافة hasInvoice)
      for (var tripId in tripIds) {
        if (!oldTripIds.contains(tripId)) {
          batch.update(_firestore.collection('dailyWork').doc(tripId), {
            'hasInvoice': true,
          });
        }
      }

      await batch.commit();

      if (mounted) {
        widget.onInvoiceUpdated();
        Navigator.pop(context);
        _showSuccessSnackbar('تم تحديث الفاتورة بنجاح');
      }
    } catch (e) {
      debugPrint('خطأ في تحديث الفاتورة: $e');
      if (mounted) {
        _showErrorSnackbar('خطأ في تحديث الفاتورة: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  bool get _isMobile {
    final size = MediaQuery.of(context).size;
    return size.width < 600;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} ج';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'تعديل الفاتورة',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 4,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الرحلات المختارة', icon: Icon(Icons.check_circle)),
            Tab(text: 'الرحلات المتاحة', icon: Icon(Icons.add_circle)),
          ],
          indicatorColor: const Color.fromARGB(255, 255, 254, 254),
          labelColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحميل البيانات...'),
                ],
              ),
            )
          : Column(
              children: [
                // بطاقة معلومات الفاتورة - تصميم محسن
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // اسم الفاتورة
                      TextField(
                        controller: _invoiceNameController,
                        decoration: InputDecoration(
                          labelText: 'اسم الفاتورة',
                          hintText: 'أدخل اسم الفاتورة',
                          prefixIcon: const Icon(
                            Icons.receipt,
                            color: Color(0xFF3498DB),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // الملاحظات
                      TextField(
                        controller: _invoiceNotesController,
                        decoration: InputDecoration(
                          labelText: 'ملاحظات',
                          hintText: 'أضف ملاحظات للفاتورة (اختياري)',
                          prefixIcon: const Icon(
                            Icons.note,
                            color: Color(0xFF3498DB),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),

                      // شهر الإدراج
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedMonth,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFF3498DB),
                            ),
                            style: const TextStyle(
                              color: Color(0xFF2C3E50),
                              fontSize: 16,
                            ),
                            items: _monthsList.map((String month) {
                              return DropdownMenuItem<String>(
                                value: month,
                                child: Text(month),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() => _selectedMonth = newValue);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // بطاقة الإحصائيات - تصميم محسن
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B4F72), Color(0xFF3498DB)],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1B4F72).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildEnhancedStat(
                        'الرحلات المختارة',
                        _selectedTrips.length.toString(),
                        Icons.check_circle,
                        Colors.white,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      _buildEnhancedStat(
                        'الرحلات المتاحة',
                        _availableTrips.length.toString(),
                        Icons.add_circle,
                        Colors.white,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      _buildEnhancedStat(
                        'الإجمالي',
                        _formatCurrency(_calculateSelectedTotal()),
                        Icons.attach_money,
                        Colors.white,
                        isCompact: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // إجمالي الكارتات
                if (_calculateSelectedKartaValue() > 0)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.credit_card, color: Colors.purple[700]),
                            const SizedBox(width: 8),
                            Text(
                              'إجمالي قيمة الكارتات:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.purple[700],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          _formatCurrency(_calculateSelectedKartaValue()),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.purple[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 4),

                // محتوى التبويبات
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTripsList(_selectedTrips, isSelectedList: true),
                      _buildTripsList(_availableTrips, isSelectedList: false),
                    ],
                  ),
                ),

                // زر الحفظ - في الأسفل واليمين
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveInvoiceChanges,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save),
                        label: Text(
                          _isSaving ? 'جاري الحفظ...' : 'حفظ التغييرات',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEnhancedStat(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isCompact = false,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isCompact ? 16 : 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: isCompact ? 10 : 12,
            color: color.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTripsList(
    List<Map<String, dynamic>> trips, {
    required bool isSelectedList,
  }) {
    if (trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSelectedList ? Colors.green[50] : Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelectedList ? Icons.inbox : Icons.add_circle_outline,
                size: 60,
                color: isSelectedList ? Colors.green[300] : Colors.blue[300],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isSelectedList ? 'لا توجد رحلات مختارة' : 'لا توجد رحلات متاحة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSelectedList
                  ? 'اختر رحلات من القائمة المتاحة'
                  : 'جميع الرحلات مفوتورة أو مختارة',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        final date = trip['date'] as DateTime?;
        final totalTripValue =
            (trip['nolon'] ?? 0).toDouble() +
            (trip['companyOvernight'] ?? 0).toDouble() +
            (trip['companyHoliday'] ?? 0).toDouble();

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: isSelectedList ? Colors.green[200]! : Colors.blue[200]!,
              width: 1,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelectedList ? Colors.green[50] : Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelectedList
                        ? Colors.green[700]
                        : Colors.blue[700],
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    trip['driverName'] ?? 'غير معروف',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498DB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'TR: ${trip['tr'] ?? '-'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF3498DB),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${trip['selectedRoute'] ?? '-'} → ${trip['selectedRoute2'] ?? '-'}',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (trip['nolon'] > 0)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'نولون: ${_formatCurrency(trip['nolon'])}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green[700],
                            ),
                          ),
                        ),
                      ),
                    if (trip['companyOvernight'] > 0)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'مبيت: ${_formatCurrency(trip['companyOvernight'])}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange[700],
                            ),
                          ),
                        ),
                      ),
                    if (trip['companyHoliday'] > 0)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'عطلة: ${_formatCurrency(trip['companyHoliday'])}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatDate(date),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isSelectedList ? Colors.red[50] : Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isSelectedList ? Icons.remove_circle : Icons.add_circle,
                      color: isSelectedList ? Colors.red : Colors.green,
                      size: 28,
                    ),
                    onPressed: () =>
                        _toggleTripSelection(trip, !isSelectedList),
                    tooltip: isSelectedList
                        ? 'إزالة من الفاتورة'
                        : 'إضافة إلى الفاتورة',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
