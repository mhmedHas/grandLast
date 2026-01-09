// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:last/models/models.dart';

// // class PriceOffersListScreen extends StatefulWidget {
// //   const PriceOffersListScreen({super.key});

// //   @override
// //   State<PriceOffersListScreen> createState() => _PriceOffersListScreenState();
// // }

// // class _PriceOffersListScreenState extends State<PriceOffersListScreen> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   String _searchQuery = '';
// //   String _activeView = 'companies'; // 'companies' أو 'wheels'

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF4F6F8),
// //       body: SingleChildScrollView(
// //         child: Column(
// //           children: [
// //             _buildSearchAndStatsBar(),
// //             Padding(
// //               padding: const EdgeInsets.only(top: 8),
// //               child: SizedBox(
// //                 height: MediaQuery.of(context).size.height * 0.75,
// //                 child: _buildCompaniesWithOffersList(),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildSearchAndStatsBar() {
// //     return Container(
// //       color: Colors.white,
// //       padding: const EdgeInsets.all(16),
// //       child: Column(
// //         children: [
// //           // شريط البحث
// //           Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 16),
// //             decoration: BoxDecoration(
// //               color: const Color(0xFFF4F6F8),
// //               borderRadius: BorderRadius.circular(12),
// //               border: Border.all(color: const Color(0xFF3498DB), width: 1.5),
// //             ),
// //             child: Row(
// //               children: [
// //                 const Icon(Icons.search, color: Color(0xFF3498DB), size: 22),
// //                 const SizedBox(width: 12),
// //                 Expanded(
// //                   child: TextField(
// //                     onChanged: (value) => setState(() => _searchQuery = value),
// //                     decoration: const InputDecoration(
// //                       hintText: 'ابحث عن شركة...',
// //                       border: InputBorder.none,
// //                       hintStyle: TextStyle(color: Colors.grey),
// //                       contentPadding: EdgeInsets.symmetric(vertical: 12),
// //                     ),
// //                   ),
// //                 ),
// //                 if (_searchQuery.isNotEmpty)
// //                   GestureDetector(
// //                     onTap: () => setState(() => _searchQuery = ''),
// //                     child: const Icon(
// //                       Icons.clear,
// //                       size: 20,
// //                       color: Colors.grey,
// //                     ),
// //                   ),
// //               ],
// //             ),
// //           ),

// //           const SizedBox(height: 12),

// //           // الإحصائيات
// //           _buildStatsBar(),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildStatsBar() {
// //     return StreamBuilder<QuerySnapshot>(
// //       stream: _firestore.collectionGroup('priceOffers').snapshots(),
// //       builder: (context, snapshot) {
// //         if (!snapshot.hasData) {
// //           return const SizedBox();
// //         }

// //         int totalCompanies = 0;
// //         int totalOffers = 0;
// //         int totalTrips = 0;

// //         // حساب الإحصائيات من البيانات الحالية
// //         final companiesData = _extractCompaniesData(snapshot.data!);
// //         totalCompanies = companiesData.length;

// //         for (final company in companiesData) {
// //           totalOffers += (company['totalOffers'] as num).toInt();
// //           totalTrips += (company['totalTrips'] as num).toInt();
// //         }
// //         return Row(
// //           children: [
// //             _buildStatCard('شركات', totalCompanies.toString(), Icons.business),
// //             const SizedBox(width: 12),
// //             _buildStatCard('عروض', totalTrips.toString(), Icons.description),
// //             const SizedBox(width: 12),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   List<Map<String, dynamic>> _extractCompaniesData(QuerySnapshot snapshot) {
// //     final Map<String, Map<String, dynamic>> companiesMap = {};

// //     for (final doc in snapshot.docs) {
// //       final data = doc.data() as Map<String, dynamic>;
// //       final companyId = _extractCompanyIdFromPath(doc.reference.path);
// //       final companyName = data['companyName'] ?? 'غير معروف';

// //       if (!companiesMap.containsKey(companyId)) {
// //         companiesMap[companyId] = {
// //           'companyId': companyId,
// //           'companyName': companyName,
// //           'totalOffers': 0,
// //           'totalTrips': 0,
// //         };
// //       }

// //       companiesMap[companyId]!['totalOffers']++;
// //       final transports = data['transportations'] as List? ?? [];
// //       companiesMap[companyId]!['totalTrips'] += transports.length;
// //     }

// //     return companiesMap.values.toList();
// //   }

// //   String _extractCompanyIdFromPath(String path) {
// //     final parts = path.split('/');
// //     return parts[1]; // companies/{companyId}/priceOffers/{offerId}
// //   }

// //   Widget _buildStatCard(String label, String value, IconData icon) {
// //     return Expanded(
// //       child: Container(
// //         padding: const EdgeInsets.all(12),
// //         decoration: BoxDecoration(
// //           color: const Color(0xFF3498DB).withOpacity(0.1),
// //           borderRadius: BorderRadius.circular(10),
// //           border: Border.all(color: const Color(0xFF3498DB), width: 1),
// //         ),
// //         child: Row(
// //           children: [
// //             Icon(icon, color: const Color(0xFF3498DB), size: 24),
// //             const SizedBox(width: 8),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     label,
// //                     style: const TextStyle(
// //                       fontSize: 12,
// //                       color: Colors.grey,
// //                       fontWeight: FontWeight.w500,
// //                     ),
// //                   ),
// //                   Text(
// //                     value,
// //                     style: const TextStyle(
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.bold,
// //                       color: Color(0xFF2C3E50),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildCompaniesWithOffersList() {
// //     return StreamBuilder<QuerySnapshot>(
// //       stream: _firestore.collectionGroup('priceOffers').snapshots(),
// //       builder: (context, snapshot) {
// //         if (snapshot.hasError) {
// //           return Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 const Icon(Icons.error, size: 64, color: Colors.red),
// //                 const SizedBox(height: 16),
// //                 Text('خطأ: ${snapshot.error}', textAlign: TextAlign.center),
// //               ],
// //             ),
// //           );
// //         }

// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Center(child: CircularProgressIndicator());
// //         }

// //         final companiesWithOffers = _extractCompaniesData(snapshot.data!);

// //         final filteredCompanies = companiesWithOffers.where((company) {
// //           if (_searchQuery.isEmpty) return true;
// //           final companyName =
// //               company['companyName']?.toString().toLowerCase() ?? '';
// //           return companyName.contains(_searchQuery.toLowerCase());
// //         }).toList();

// //         if (filteredCompanies.isEmpty) {
// //           return Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 const Icon(Icons.business, size: 80, color: Colors.grey),
// //                 const SizedBox(height: 16),
// //                 const Text(
// //                   'لا توجد شركات لديها عروض أسعار',
// //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //                 ),
// //                 const SizedBox(height: 8),
// //                 Text(
// //                   _searchQuery.isEmpty
// //                       ? 'أضف عرض سعر جديد للبدء'
// //                       : 'لم يتم العثور على نتائج البحث',
// //                   style: const TextStyle(color: Colors.grey, fontSize: 14),
// //                 ),
// //               ],
// //             ),
// //           );
// //         }

// //         return ListView.builder(
// //           shrinkWrap: true,
// //           physics: const NeverScrollableScrollPhysics(),
// //           padding: const EdgeInsets.all(16),
// //           itemCount: filteredCompanies.length,
// //           itemBuilder: (context, index) {
// //             final companyData = filteredCompanies[index];
// //             return _buildCompanyWithAllOffersItem(companyData);
// //           },
// //         );
// //       },
// //     );
// //   }

// //   Widget _buildCompanyWithAllOffersItem(Map<String, dynamic> companyData) {
// //     final String companyName = companyData['companyName'];
// //     final String companyId = companyData['companyId'];
// //     final int totalOffers = companyData['totalOffers'];
// //     final int totalTrips = companyData['totalTrips'];

// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 12),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: const Color(0xFF3498DB).withOpacity(0.3)),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 8,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: ListTile(
// //         leading: Container(
// //           padding: const EdgeInsets.all(8),
// //           decoration: BoxDecoration(
// //             color: const Color(0xFF3498DB).withOpacity(0.1),
// //             borderRadius: BorderRadius.circular(8),
// //           ),
// //           child: const Icon(Icons.business, color: Color(0xFF3498DB), size: 24),
// //         ),
// //         title: Text(
// //           companyName,
// //           style: const TextStyle(
// //             fontSize: 16,
// //             fontWeight: FontWeight.bold,
// //             color: Color(0xFF2C3E50),
// //           ),
// //         ),
// //         subtitle: Text(
// //           '$totalTrips عروض السعر :',
// //           style: const TextStyle(fontSize: 12, color: Colors.grey),
// //         ),
// //         trailing: Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             _buildActionButton(
// //               icon: Icons.business,
// //               label: 'الشركات',
// //               color: Colors.blue,
// //               onPressed: () {
// //                 setState(() => _activeView = 'companies');
// //                 _showAllCompanyOffers(companyId, companyName, 'companies');
// //               },
// //             ),
// //             const SizedBox(width: 8),
// //             _buildActionButton(
// //               icon: Icons.directions_bus,
// //               label: 'العجل',
// //               color: Colors.purple,
// //               onPressed: () {
// //                 setState(() => _activeView = 'wheels');
// //                 _showAllCompanyOffers(companyId, companyName, 'wheels');
// //               },
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   void _showAllCompanyOffers(
// //     String companyId,
// //     String companyName,
// //     String viewType,
// //   ) {
// //     showDialog(
// //       context: context,
// //       builder: (context) => Directionality(
// //         textDirection: TextDirection.rtl,
// //         child: Dialog(
// //           backgroundColor: Colors.transparent,
// //           insetPadding: const EdgeInsets.all(16),
// //           child: Container(
// //             width: MediaQuery.of(context).size.width * 0.95,
// //             constraints: BoxConstraints(
// //               maxHeight: MediaQuery.of(context).size.height * 0.9,
// //             ),
// //             padding: const EdgeInsets.all(20),
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               borderRadius: BorderRadius.circular(16),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black.withOpacity(0.15),
// //                   blurRadius: 20,
// //                 ),
// //               ],
// //             ),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 // العنوان
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     IconButton(
// //                       icon: const Icon(Icons.close),
// //                       onPressed: () => Navigator.pop(context),
// //                     ),
// //                     Column(
// //                       children: [
// //                         Text(
// //                           viewType == 'companies'
// //                               ? 'عروض اسعار الشركات - $companyName'
// //                               : 'عروض اسعار العجل - $companyName',
// //                           style: const TextStyle(
// //                             fontSize: 20,
// //                             fontWeight: FontWeight.bold,
// //                             color: Color(0xFF2C3E50),
// //                           ),
// //                         ),
// //                         const SizedBox(height: 4),
// //                         // Row(
// //                         //   mainAxisAlignment: MainAxisAlignment.center,
// //                         //   children: [
// //                         //     _buildViewTypeButton(
// //                         //       'الشركات',
// //                         //       viewType == 'companies',
// //                         //       Icons.business,
// //                         //       () {
// //                         //         setState(() => _activeView = 'companies');
// //                         //         Navigator.pop(context);
// //                         //         _showAllCompanyOffers(
// //                         //           companyId,
// //                         //           companyName,
// //                         //           'companies',
// //                         //         );
// //                         //       },
// //                         //     ),
// //                         //     const SizedBox(width: 8),
// //                         //     _buildViewTypeButton(
// //                         //       'العجل',
// //                         //       viewType == 'wheels',
// //                         //       Icons.directions_bus,
// //                         //       () {
// //                         //         setState(() => _activeView = 'wheels');
// //                         //         Navigator.pop(context);
// //                         //         _showAllCompanyOffers(
// //                         //           companyId,
// //                         //           companyName,
// //                         //           'wheels',
// //                         //         );
// //                         //       },
// //                         //     ),
// //                         //   ],
// //                         // ),
// //                       ],
// //                     ),
// //                     const SizedBox(width: 48),
// //                   ],
// //                 ),

// //                 const SizedBox(height: 8),
// //                 Divider(color: const Color(0xFF3498DB).withOpacity(0.3)),

// //                 // إحصائيات الشركة
// //                 Container(
// //                   padding: const EdgeInsets.all(12),
// //                   decoration: BoxDecoration(
// //                     color: const Color(0xFF3498DB).withOpacity(0.1),
// //                     borderRadius: BorderRadius.circular(10),
// //                   ),
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceAround,
// //                     children: [
// //                       Column(
// //                         children: [
// //                           const Text(
// //                             'اسم الشركة',
// //                             style: TextStyle(fontSize: 11, color: Colors.grey),
// //                           ),
// //                           Text(
// //                             companyName,
// //                             style: const TextStyle(
// //                               fontSize: 16,
// //                               fontWeight: FontWeight.bold,
// //                               color: Color(0xFF2C3E50),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       Column(
// //                         children: [
// //                           const Text(
// //                             'إجمالي العروض',
// //                             style: TextStyle(fontSize: 11, color: Colors.grey),
// //                           ),
// //                           StreamBuilder<QuerySnapshot>(
// //                             stream: _firestore
// //                                 .collection('companies')
// //                                 .doc(companyId)
// //                                 .collection('priceOffers')
// //                                 .snapshots(),
// //                             builder: (context, snapshot) {
// //                               int totalTrips = 0;
// //                               if (snapshot.hasData) {
// //                                 for (final doc in snapshot.data!.docs) {
// //                                   final data =
// //                                       doc.data() as Map<String, dynamic>;
// //                                   final transports =
// //                                       data['transportations'] as List? ?? [];
// //                                   totalTrips += transports.length;
// //                                 }
// //                               }
// //                               return Text(
// //                                 '$totalTrips',
// //                                 style: const TextStyle(
// //                                   fontSize: 16,
// //                                   fontWeight: FontWeight.bold,
// //                                   color: Color(0xFF2C3E50),
// //                                 ),
// //                               );
// //                             },
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                 ),

// //                 const SizedBox(height: 16),

// //                 // الجدول
// //                 Expanded(child: _buildCompanyOffersTable(companyId, viewType)),

// //                 const SizedBox(height: 16),

// //                 // زر الإغلاق
// //                 ElevatedButton(
// //                   onPressed: () => Navigator.pop(context),
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: const Color(0xFF3498DB),
// //                     foregroundColor: Colors.white,
// //                     elevation: 2,
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 40,
// //                       vertical: 12,
// //                     ),
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                   ),
// //                   child: const Text('إغلاق'),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildViewTypeButton(
// //     String label,
// //     bool isActive,
// //     IconData icon,
// //     VoidCallback onPressed,
// //   ) {
// //     return ElevatedButton.icon(
// //       onPressed: onPressed,
// //       icon: Icon(icon, size: 16),
// //       label: Text(label),
// //       style: ElevatedButton.styleFrom(
// //         backgroundColor: isActive
// //             ? const Color(0xFF3498DB)
// //             : const Color(0xFF3498DB).withOpacity(0.1),
// //         foregroundColor: isActive ? Colors.white : const Color(0xFF3498DB),
// //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// //       ),
// //     );
// //   }

// //   Widget _buildCompanyOffersTable(String companyId, String viewType) {
// //     return StreamBuilder<QuerySnapshot>(
// //       stream: _firestore
// //           .collection('companies')
// //           .doc(companyId)
// //           .collection('priceOffers')
// //           .orderBy('updatedAt', descending: true)
// //           .snapshots(),
// //       builder: (context, snapshot) {
// //         if (snapshot.connectionState == ConnectionState.waiting) {
// //           return const Center(child: CircularProgressIndicator());
// //         }

// //         if (snapshot.hasError) {
// //           return Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 const Icon(Icons.error, size: 48, color: Colors.red),
// //                 const SizedBox(height: 8),
// //                 Text(
// //                   'خطأ في تحميل البيانات: ${snapshot.error}',
// //                   textAlign: TextAlign.center,
// //                   style: const TextStyle(fontSize: 14, color: Colors.red),
// //                 ),
// //               ],
// //             ),
// //           );
// //         }

// //         final offers = snapshot.data!.docs.map((doc) {
// //           final data = doc.data() as Map<String, dynamic>;
// //           return PriceOffer.fromMap(data, doc.id);
// //         }).toList();

// //         if (offers.isEmpty) {
// //           return const Center(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Icon(Icons.description, size: 64, color: Colors.grey),
// //                 SizedBox(height: 16),
// //                 Text(
// //                   'لا توجد عروض أسعار',
// //                   style: TextStyle(fontSize: 16, color: Colors.grey),
// //                 ),
// //               ],
// //             ),
// //           );
// //         }

// //         // جمع كل الرحلات من كل العروض
// //         List<TransportationWithOffer> allTransportations = [];
// //         for (final offer in offers) {
// //           for (final transport in offer.transportations) {
// //             allTransportations.add(
// //               TransportationWithOffer(
// //                 transportation: transport,
// //                 offerId: offer.id,
// //                 companyId: companyId,
// //                 offer: offer,
// //               ),
// //             );
// //           }
// //         }

// //         return viewType == 'companies'
// //             ? _buildCompaniesTable(allTransportations)
// //             : _buildWheelsTable(allTransportations);
// //       },
// //     );
// //   }

// //   Widget _buildCompaniesTable(List<TransportationWithOffer> transportations) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(10),
// //         border: Border.all(color: Colors.transparent, width: 1.5),
// //       ),
// //       child: SingleChildScrollView(
// //         scrollDirection: Axis.horizontal,
// //         child: SingleChildScrollView(
// //           scrollDirection: Axis.vertical,
// //           child: Table(
// //             defaultColumnWidth: const FixedColumnWidth(150),
// //             border: TableBorder.all(color: const Color(0xFF3498DB), width: 1),
// //             children: [
// //               /// ✅ العناوين - جدول الشركات
// //               TableRow(
// //                 decoration: BoxDecoration(
// //                   color: const Color(0xFF3498DB).withOpacity(0.15),
// //                 ),
// //                 children: const [
// //                   _TableCellHeader('م'),
// //                   _TableCellHeader('مكان التحميل'),
// //                   _TableCellHeader('مكان التعتيق'),
// //                   _TableCellHeader('نوع العربية'),
// //                   _TableCellHeader('النولون'),
// //                   _TableCellHeader('المبيت'),
// //                   _TableCellHeader('العطلة'),
// //                   // _TableCellHeader('ملاحظات'),
// //                   _TableCellHeader('الإجراءات'),
// //                 ],
// //               ),

// //               /// ✅ الصفوف - جدول الشركات
// //               ...transportations.asMap().entries.map((entry) {
// //                 final index = entry.key;
// //                 final item = entry.value;
// //                 final transport = item.transportation;

// //                 return TableRow(
// //                   decoration: BoxDecoration(
// //                     color: index.isEven
// //                         ? Colors.white
// //                         : const Color(0xFFF8F9FA),
// //                   ),
// //                   children: [
// //                     _TableCellBody('${index + 1}'),
// //                     _TableCellBody(transport.loadingLocation),
// //                     _TableCellBody(transport.unloadingLocation),
// //                     _TableCellBody(transport.vehicleType),
// //                     _TableCellBody('${transport.nolon} ج'),
// //                     _TableCellBody('${transport.companyOvernight} ج'),
// //                     _TableCellBody('${transport.companyHoliday} ج'),
// //                     // _TableCellBody(
// //                     //   transport.notes?.isNotEmpty == true
// //                     //       ? transport.notes!
// //                     //       : '-',
// //                     // ),
// //                     _TableCellActions(
// //                       onEdit: () => _editTransportation(item, 'companies'),
// //                       onDelete: () => _deleteTransportation(item),
// //                     ),
// //                   ],
// //                 );
// //               }).toList(),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildWheelsTable(List<TransportationWithOffer> transportations) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         borderRadius: BorderRadius.circular(10),
// //         border: Border.all(color: Colors.transparent, width: 1.5),
// //       ),
// //       child: SingleChildScrollView(
// //         scrollDirection: Axis.horizontal,
// //         child: SingleChildScrollView(
// //           scrollDirection: Axis.vertical,
// //           child: Table(
// //             defaultColumnWidth: const FixedColumnWidth(150),
// //             border: TableBorder.all(color: const Color(0xFF6A1B9A), width: 1),
// //             children: [
// //               /// ✅ العناوين - جدول العجل
// //               TableRow(
// //                 decoration: BoxDecoration(
// //                   color: const Color(0xFF6A1B9A).withOpacity(0.15),
// //                 ),
// //                 children: const [
// //                   _TableCellHeader('م'),
// //                   _TableCellHeader('مكان التحميل'),
// //                   _TableCellHeader('مكان التعتيق'),
// //                   _TableCellHeader('نوع العربية'),
// //                   _TableCellHeader('النولون'),
// //                   _TableCellHeader('المبيت'),
// //                   _TableCellHeader('العطلة'),
// //                   _TableCellHeader('الإجراءات'),
// //                 ],
// //               ),

// //               /// ✅ الصفوف - جدول العجل
// //               ...transportations.asMap().entries.map((entry) {
// //                 final index = entry.key;
// //                 final item = entry.value;
// //                 final transport = item.transportation;

// //                 return TableRow(
// //                   decoration: BoxDecoration(
// //                     color: index.isEven
// //                         ? Colors.white
// //                         : const Color(0xFFF8F9FA),
// //                   ),
// //                   children: [
// //                     _TableCellBody('${index + 1}'),
// //                     _TableCellBody(transport.loadingLocation),
// //                     _TableCellBody(transport.unloadingLocation),
// //                     _TableCellBody(transport.vehicleType),
// //                     _TableCellBody('${transport.wheelNolon} ج'),
// //                     _TableCellBody('${transport.wheelOvernight} ج'),
// //                     _TableCellBody('${transport.wheelHoliday} ج'),
// //                     // _TableCellBody(
// //                     //   transport.notes?.isNotEmpty == true
// //                     //       ? transport.notes!
// //                     //       : '-',
// //                     // ),
// //                     _TableCellActions(
// //                       onEdit: () => _editTransportation(item, 'wheels'),
// //                       onDelete: () => _deleteTransportation(item),
// //                     ),
// //                   ],
// //                 );
// //               }).toList(),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   // دالة تعديل الرحلة
// //   void _editTransportation(TransportationWithOffer item, String viewType) {
// //     final transportation = item.transportation;
// //     final isCompaniesView = viewType == 'companies';

// //     final loadingLocationController = TextEditingController(
// //       text: transportation.loadingLocation,
// //     );
// //     final unloadingLocationController = TextEditingController(
// //       text: transportation.unloadingLocation,
// //     );
// //     final vehicleTypeController = TextEditingController(
// //       text: transportation.vehicleType,
// //     );
// //     final nolonController = TextEditingController(
// //       text: isCompaniesView
// //           ? transportation.nolon.toString()
// //           : transportation.wheelNolon.toString(),
// //     );
// //     final overnightController = TextEditingController(
// //       text: isCompaniesView
// //           ? transportation.companyOvernight.toString()
// //           : transportation.wheelOvernight.toString(),
// //     );
// //     final holidayController = TextEditingController(
// //       text: isCompaniesView
// //           ? transportation.companyHoliday.toString()
// //           : transportation.wheelHoliday.toString(),
// //     );
// //     final notesController = TextEditingController(
// //       text: transportation.notes ?? '',
// //     );

// //     showDialog(
// //       context: context,
// //       builder: (context) => Directionality(
// //         textDirection: TextDirection.rtl,
// //         child: Dialog(
// //           backgroundColor: Colors.white,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(16),
// //           ),
// //           child: SingleChildScrollView(
// //             child: Container(
// //               padding: const EdgeInsets.all(24),
// //               width: MediaQuery.of(context).size.width * 0.9,
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   // العنوان
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       Text(
// //                         'تعديل الرحلة - ${isCompaniesView ? 'الشركات' : 'العجل'}',
// //                         style: const TextStyle(
// //                           fontSize: 20,
// //                           fontWeight: FontWeight.bold,
// //                           color: Color(0xFF2C3E50),
// //                         ),
// //                       ),
// //                       IconButton(
// //                         icon: const Icon(Icons.close),
// //                         onPressed: () => Navigator.pop(context),
// //                       ),
// //                     ],
// //                   ),

// //                   const SizedBox(height: 8),
// //                   Divider(color: const Color(0xFF3498DB).withOpacity(0.3)),

// //                   const SizedBox(height: 20),

// //                   // حقل مكان التحميل
// //                   _buildEditField(
// //                     'مكان التحميل',
// //                     'أدخل مكان التحميل',
// //                     loadingLocationController,
// //                     Icons.location_on,
// //                   ),

// //                   const SizedBox(height: 16),

// //                   // حقل مكان التعتيق
// //                   _buildEditField(
// //                     'مكان التعتيق',
// //                     'أدخل مكان التعتيق',
// //                     unloadingLocationController,
// //                     Icons.location_on,
// //                   ),

// //                   const SizedBox(height: 16),

// //                   // حقل نوع العربية
// //                   _buildEditField(
// //                     'نوع العربية',
// //                     'أدخل نوع العربية',
// //                     vehicleTypeController,
// //                     Icons.directions_car,
// //                   ),

// //                   const SizedBox(height: 16),

// //                   // حقل النولون
// //                   _buildEditField(
// //                     'النولون',
// //                     'أدخل النولون',
// //                     nolonController,
// //                     Icons.attach_money,
// //                     keyboardType: TextInputType.number,
// //                   ),

// //                   const SizedBox(height: 16),

// //                   // حقل المبيت
// //                   _buildEditField(
// //                     'المبيت',
// //                     'أدخل المبيت',
// //                     overnightController,
// //                     Icons.hotel,
// //                     keyboardType: TextInputType.number,
// //                   ),

// //                   const SizedBox(height: 16),

// //                   // حقل العطلة
// //                   _buildEditField(
// //                     'العطلة',
// //                     'أدخل العطلة',
// //                     holidayController,
// //                     Icons.beach_access,
// //                     keyboardType: TextInputType.number,
// //                   ),

// //                   const SizedBox(height: 16),

// //                   // حقل الملاحظات
// //                   _buildEditField(
// //                     'ملاحظات',
// //                     'أدخل الملاحظات (اختياري)',
// //                     notesController,
// //                     Icons.note,
// //                     maxLines: 3,
// //                   ),

// //                   const SizedBox(height: 24),

// //                   // أزرار الحفظ والإلغاء
// //                   Row(
// //                     children: [
// //                       Expanded(
// //                         child: OutlinedButton(
// //                           onPressed: () => Navigator.pop(context),
// //                           style: OutlinedButton.styleFrom(
// //                             padding: const EdgeInsets.symmetric(vertical: 12),
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(8),
// //                             ),
// //                           ),
// //                           child: const Text(
// //                             'إلغاء',
// //                             style: TextStyle(
// //                               color: Color(0xFF2C3E50),
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(width: 12),
// //                       Expanded(
// //                         child: ElevatedButton(
// //                           onPressed: () {
// //                             _updateTransportation(
// //                               item,
// //                               loadingLocationController.text,
// //                               unloadingLocationController.text,
// //                               vehicleTypeController.text,
// //                               nolonController.text,
// //                               overnightController.text,
// //                               holidayController.text,
// //                               notesController.text,
// //                               isCompaniesView,
// //                             );
// //                             Navigator.pop(context);
// //                           },
// //                           style: ElevatedButton.styleFrom(
// //                             backgroundColor: const Color(0xFF3498DB),
// //                             foregroundColor: Colors.white,
// //                             padding: const EdgeInsets.symmetric(vertical: 12),
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(8),
// //                             ),
// //                           ),
// //                           child: const Text(
// //                             'حفظ التعديلات',
// //                             style: TextStyle(fontWeight: FontWeight.bold),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildEditField(
// //     String label,
// //     String hint,
// //     TextEditingController controller,
// //     IconData icon, {
// //     TextInputType keyboardType = TextInputType.text,
// //     int maxLines = 1,
// //   }) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           label,
// //           style: const TextStyle(
// //             fontWeight: FontWeight.bold,
// //             color: Color(0xFF2C3E50),
// //             fontSize: 14,
// //           ),
// //         ),
// //         const SizedBox(height: 6),
// //         TextFormField(
// //           controller: controller,
// //           keyboardType: keyboardType,
// //           maxLines: maxLines,
// //           decoration: InputDecoration(
// //             hintText: hint,
// //             prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
// //             filled: true,
// //             fillColor: const Color(0xFFF4F6F8),
// //             border: OutlineInputBorder(
// //               borderRadius: BorderRadius.circular(8),
// //               borderSide: BorderSide.none,
// //             ),
// //             contentPadding: const EdgeInsets.symmetric(
// //               horizontal: 16,
// //               vertical: 12,
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }

// //   // دالة تحديث الرحلة في Firebase
// //   Future<void> _updateTransportation(
// //     TransportationWithOffer item,
// //     String loadingLocation,
// //     String unloadingLocation,
// //     String vehicleType,
// //     String nolon,
// //     String overnight,
// //     String holiday,
// //     String notes,
// //     bool isCompaniesView,
// //   ) async {
// //     try {
// //       final offerRef = _firestore
// //           .collection('companies')
// //           .doc(item.companyId)
// //           .collection('priceOffers')
// //           .doc(item.offerId);

// //       // جلب العرض الحالي
// //       final offerDoc = await offerRef.get();
// //       final offerData = offerDoc.data() as Map<String, dynamic>;
// //       final List<dynamic> transportations = offerData['transportations'];

// //       // تحديث الرحلة المحددة
// //       final updatedTransportations = transportations.map((transport) {
// //         final map = transport as Map<String, dynamic>;
// //         if (map['loadingLocation'] == item.transportation.loadingLocation &&
// //             map['unloadingLocation'] == item.transportation.unloadingLocation &&
// //             map['vehicleType'] == item.transportation.vehicleType) {
// //           final updatedMap = {
// //             ...map,
// //             'loadingLocation': loadingLocation.trim(),
// //             'unloadingLocation': unloadingLocation.trim(),
// //             'vehicleType': vehicleType.trim(),
// //             'notes': notes.trim().isEmpty ? null : notes.trim(),
// //           };

// //           // تحديث الحقول حسب النوع
// //           if (isCompaniesView) {
// //             updatedMap['nolon'] =
// //                 double.tryParse(nolon) ?? item.transportation.nolon;
// //             updatedMap['companyOvernight'] =
// //                 double.tryParse(overnight) ??
// //                 item.transportation.companyOvernight;
// //             updatedMap['companyHoliday'] =
// //                 double.tryParse(holiday) ?? item.transportation.companyHoliday;
// //           } else {
// //             updatedMap['wheelNolon'] =
// //                 double.tryParse(nolon) ?? item.transportation.wheelNolon;
// //             updatedMap['wheelOvernight'] =
// //                 double.tryParse(overnight) ??
// //                 item.transportation.wheelOvernight;
// //             updatedMap['wheelHoliday'] =
// //                 double.tryParse(holiday) ?? item.transportation.wheelHoliday;
// //           }

// //           return updatedMap;
// //         }
// //         return transport;
// //       }).toList();

// //       // تحديث العرض في Firebase
// //       await offerRef.update({
// //         'transportations': updatedTransportations,
// //         'updatedAt': Timestamp.now(),
// //       });

// //       // إظهار رسالة نجاح
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(
// //             content: Text('تم تعديل الرحلة بنجاح'),
// //             backgroundColor: Colors.green,
// //             duration: Duration(seconds: 2),
// //           ),
// //         );
// //       }
// //     } catch (e) {
// //       print('Error updating transportation: $e');
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text('خطأ في التعديل: $e'),
// //             backgroundColor: Colors.red,
// //             duration: const Duration(seconds: 3),
// //           ),
// //         );
// //       }
// //     }
// //   }

// //   // دالة حذف الرحلة
// //   void _deleteTransportation(TransportationWithOffer item) {
// //     showDialog(
// //       context: context,
// //       builder: (context) => Directionality(
// //         textDirection: TextDirection.rtl,
// //         child: AlertDialog(
// //           backgroundColor: Colors.white,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(16),
// //           ),
// //           title: const Row(
// //             children: [
// //               Icon(Icons.warning, color: Colors.orange),
// //               SizedBox(width: 8),
// //               Text(
// //                 'تأكيد الحذف',
// //                 style: TextStyle(
// //                   fontWeight: FontWeight.bold,
// //                   color: Color(0xFF2C3E50),
// //                 ),
// //               ),
// //             ],
// //           ),
// //           content: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               const Text(
// //                 'هل أنت متأكد من حذف هذه الرحلة؟',
// //                 style: TextStyle(fontSize: 16),
// //               ),
// //               const SizedBox(height: 8),
// //               Text(
// //                 'المسار: ${item.transportation.loadingLocation} → ${item.transportation.unloadingLocation}',
// //                 style: const TextStyle(color: Colors.grey),
// //               ),
// //               Text(
// //                 'النولون: ${item.transportation.nolon} ج',
// //                 style: const TextStyle(color: Colors.grey),
// //               ),
// //               const SizedBox(height: 16),
// //               const Text(
// //                 '⚠️ لا يمكن التراجع عن هذا الإجراء',
// //                 style: TextStyle(
// //                   color: Colors.red,
// //                   fontSize: 12,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.pop(context),
// //               child: const Text(
// //                 'إلغاء',
// //                 style: TextStyle(color: Color(0xFF2C3E50)),
// //               ),
// //             ),
// //             ElevatedButton(
// //               onPressed: () {
// //                 _confirmDeleteTransportation(item);
// //                 Navigator.pop(context);
// //               },
// //               style: ElevatedButton.styleFrom(
// //                 backgroundColor: Colors.red,
// //                 foregroundColor: Colors.white,
// //               ),
// //               child: const Text('حذف'),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   // دالة تأكيد الحذف
// //   Future<void> _confirmDeleteTransportation(
// //     TransportationWithOffer item,
// //   ) async {
// //     try {
// //       final offerRef = _firestore
// //           .collection('companies')
// //           .doc(item.companyId)
// //           .collection('priceOffers')
// //           .doc(item.offerId);

// //       // جلب العرض الحالي
// //       final offerDoc = await offerRef.get();
// //       final offerData = offerDoc.data() as Map<String, dynamic>;
// //       final List<dynamic> transportations = offerData['transportations'];

// //       // تصفية الرحلة المطلوب حذفها
// //       final updatedTransportations = transportations.where((transport) {
// //         final map = transport as Map<String, dynamic>;
// //         return !(map['loadingLocation'] ==
// //                 item.transportation.loadingLocation &&
// //             map['unloadingLocation'] == item.transportation.unloadingLocation &&
// //             map['vehicleType'] == item.transportation.vehicleType);
// //       }).toList();

// //       // إذا لم يتبقى أي رحلات، احذف العرض كاملاً
// //       if (updatedTransportations.isEmpty) {
// //         await offerRef.delete();
// //       } else {
// //         // وإلا قم بتحديث العرض
// //         await offerRef.update({
// //           'transportations': updatedTransportations,
// //           'updatedAt': Timestamp.now(),
// //         });
// //       }

// //       // إظهار رسالة نجاح
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(
// //             content: Text('تم حذف الرحلة بنجاح'),
// //             backgroundColor: Colors.green,
// //             duration: Duration(seconds: 2),
// //           ),
// //         );
// //       }
// //     } catch (e) {
// //       print('Error deleting transportation: $e');
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text('خطأ في الحذف: $e'),
// //             backgroundColor: Colors.red,
// //             duration: const Duration(seconds: 3),
// //           ),
// //         );
// //       }
// //     }
// //   }

// //   Widget _buildActionButton({
// //     required IconData icon,
// //     required String label,
// //     required Color color,
// //     required VoidCallback onPressed,
// //   }) {
// //     return ElevatedButton.icon(
// //       onPressed: onPressed,
// //       icon: Icon(icon, size: 18),
// //       label: Text(label),
// //       style: ElevatedButton.styleFrom(
// //         backgroundColor: color.withOpacity(0.9),
// //         foregroundColor: Colors.white,
// //         elevation: 0,
// //         padding: const EdgeInsets.symmetric(vertical: 10),
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
// //       ),
// //     );
// //   }

// //   String _formatDate(DateTime date) {
// //     return '${date.day}/${date.month}/${date.year}';
// //   }
// // }

// // // نموذج مساعد لتخزين معلومات الرحلة مع معلومات العرض
// // class TransportationWithOffer {
// //   final Transportation transportation;
// //   final offerId;
// //   final String companyId;
// //   final PriceOffer offer;

// //   TransportationWithOffer({
// //     required this.transportation,
// //     required this.offerId,
// //     required this.companyId,
// //     required this.offer,
// //   });
// // }

// // class _TableCellBody extends StatelessWidget {
// //   final String text;
// //   final TextStyle? textStyle;

// //   const _TableCellBody(this.text, {this.textStyle});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       height: 48,
// //       alignment: Alignment.center,
// //       padding: const EdgeInsets.symmetric(horizontal: 8),
// //       child: Text(
// //         text,
// //         maxLines: 2,
// //         overflow: TextOverflow.ellipsis,
// //         textAlign: TextAlign.center,
// //         style: textStyle,
// //       ),
// //     );
// //   }
// // }

// // class _TableCellHeader extends StatelessWidget {
// //   final String text;
// //   const _TableCellHeader(this.text);

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       height: 50,
// //       alignment: Alignment.center,
// //       padding: const EdgeInsets.symmetric(horizontal: 8),
// //       child: Text(
// //         text,
// //         style: const TextStyle(
// //           fontWeight: FontWeight.bold,
// //           fontSize: 14,
// //           color: Color(0xFF2C3E50),
// //         ),
// //         textAlign: TextAlign.center,
// //       ),
// //     );
// //   }
// // }

// // class _TableCellActions extends StatelessWidget {
// //   final VoidCallback onEdit;
// //   final VoidCallback onDelete;

// //   const _TableCellActions({required this.onEdit, required this.onDelete});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       height: 48,
// //       alignment: Alignment.center,
// //       padding: const EdgeInsets.symmetric(horizontal: 4),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           // زر التعديل
// //           IconButton(
// //             icon: Container(
// //               padding: const EdgeInsets.all(6),
// //               decoration: BoxDecoration(
// //                 color: Colors.blue.withOpacity(0.1),
// //                 borderRadius: BorderRadius.circular(6),
// //               ),
// //               child: const Icon(Icons.edit, size: 16, color: Colors.blue),
// //             ),
// //             onPressed: onEdit,
// //             padding: EdgeInsets.zero,
// //             constraints: const BoxConstraints(),
// //           ),
// //           const SizedBox(width: 4),
// //           // زر الحذف
// //           IconButton(
// //             icon: Container(
// //               padding: const EdgeInsets.all(6),
// //               decoration: BoxDecoration(
// //                 color: Colors.red.withOpacity(0.1),
// //                 borderRadius: BorderRadius.circular(6),
// //               ),
// //               child: const Icon(Icons.delete, size: 16, color: Colors.red),
// //             ),
// //             onPressed: onDelete,
// //             padding: EdgeInsets.zero,
// //             constraints: const BoxConstraints(),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:last/models/models.dart';
// import 'package:printing/printing.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pdfLib;
// import 'package:intl/intl.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/widgets.dart' as t;

// class PriceOffersListScreen extends StatefulWidget {
//   const PriceOffersListScreen({super.key});

//   @override
//   State<PriceOffersListScreen> createState() => _PriceOffersListScreenState();
// }

// class _PriceOffersListScreenState extends State<PriceOffersListScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   String _searchQuery = '';
//   String _activeView = 'companies'; // 'companies' أو 'wheels'
//   pdfLib.Font? _arabicFont;
//   bool _isGeneratingPDF = false;
//   String? _currentCompanyName;
//   String? _currentViewType;
//   String? _currentCompanyId;
//   List<TransportationWithOffer>? _currentTransportations;

//   @override
//   void initState() {
//     super.initState();
//     _loadArabicFont();
//   }

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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF4F6F8),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             _buildSearchAndStatsBar(),
//             Padding(
//               padding: const EdgeInsets.only(top: 8),
//               child: SizedBox(
//                 height: MediaQuery.of(context).size.height * 0.75,
//                 child: _buildCompaniesWithOffersList(),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSearchAndStatsBar() {
//     return Container(
//       color: Colors.white,
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           // شريط البحث
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF4F6F8),
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: const Color(0xFF3498DB), width: 1.5),
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.search, color: Color(0xFF3498DB), size: 22),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: TextField(
//                     onChanged: (value) => setState(() => _searchQuery = value),
//                     decoration: const InputDecoration(
//                       hintText: 'ابحث عن شركة...',
//                       border: InputBorder.none,
//                       hintStyle: TextStyle(color: Colors.grey),
//                       contentPadding: EdgeInsets.symmetric(vertical: 12),
//                     ),
//                   ),
//                 ),
//                 if (_searchQuery.isNotEmpty)
//                   GestureDetector(
//                     onTap: () => setState(() => _searchQuery = ''),
//                     child: const Icon(
//                       Icons.clear,
//                       size: 20,
//                       color: Colors.grey,
//                     ),
//                   ),
//               ],
//             ),
//           ),

//           const SizedBox(height: 12),

//           // الإحصائيات
//           _buildStatsBar(),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatsBar() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _firestore.collectionGroup('priceOffers').snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return const SizedBox();
//         }

//         int totalCompanies = 0;
//         int totalOffers = 0;
//         int totalTrips = 0;

//         // حساب الإحصائيات من البيانات الحالية
//         final companiesData = _extractCompaniesData(snapshot.data!);
//         totalCompanies = companiesData.length;

//         for (final company in companiesData) {
//           totalOffers += (company['totalOffers'] as num).toInt();
//           totalTrips += (company['totalTrips'] as num).toInt();
//         }
//         return Row(
//           children: [
//             _buildStatCard('شركات', totalCompanies.toString(), Icons.business),
//             const SizedBox(width: 12),
//             _buildStatCard('عروض', totalTrips.toString(), Icons.description),
//             const SizedBox(width: 12),
//           ],
//         );
//       },
//     );
//   }

//   List<Map<String, dynamic>> _extractCompaniesData(QuerySnapshot snapshot) {
//     final Map<String, Map<String, dynamic>> companiesMap = {};

//     for (final doc in snapshot.docs) {
//       final data = doc.data() as Map<String, dynamic>;
//       final companyId = _extractCompanyIdFromPath(doc.reference.path);
//       final companyName = data['companyName'] ?? 'غير معروف';

//       if (!companiesMap.containsKey(companyId)) {
//         companiesMap[companyId] = {
//           'companyId': companyId,
//           'companyName': companyName,
//           'totalOffers': 0,
//           'totalTrips': 0,
//         };
//       }

//       companiesMap[companyId]!['totalOffers']++;
//       final transports = data['transportations'] as List? ?? [];
//       companiesMap[companyId]!['totalTrips'] += transports.length;
//     }

//     return companiesMap.values.toList();
//   }

//   String _extractCompanyIdFromPath(String path) {
//     final parts = path.split('/');
//     return parts[1]; // companies/{companyId}/priceOffers/{offerId}
//   }

//   Widget _buildStatCard(String label, String value, IconData icon) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: const Color(0xFF3498DB).withOpacity(0.1),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: const Color(0xFF3498DB), width: 1),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: const Color(0xFF3498DB), size: 24),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     label,
//                     style: const TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   Text(
//                     value,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF2C3E50),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCompaniesWithOffersList() {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _firestore.collectionGroup('priceOffers').snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.error, size: 64, color: Colors.red),
//                 const SizedBox(height: 16),
//                 Text('خطأ: ${snapshot.error}', textAlign: TextAlign.center),
//               ],
//             ),
//           );
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final companiesWithOffers = _extractCompaniesData(snapshot.data!);

//         final filteredCompanies = companiesWithOffers.where((company) {
//           if (_searchQuery.isEmpty) return true;
//           final companyName =
//               company['companyName']?.toString().toLowerCase() ?? '';
//           return companyName.contains(_searchQuery.toLowerCase());
//         }).toList();

//         if (filteredCompanies.isEmpty) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.business, size: 80, color: Colors.grey),
//                 const SizedBox(height: 16),
//                 const Text(
//                   'لا توجد شركات لديها عروض أسعار',
//                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   _searchQuery.isEmpty
//                       ? 'أضف عرض سعر جديد للبدء'
//                       : 'لم يتم العثور على نتائج البحث',
//                   style: const TextStyle(color: Colors.grey, fontSize: 14),
//                 ),
//               ],
//             ),
//           );
//         }

//         return ListView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           padding: const EdgeInsets.all(16),
//           itemCount: filteredCompanies.length,
//           itemBuilder: (context, index) {
//             final companyData = filteredCompanies[index];
//             return _buildCompanyWithAllOffersItem(companyData);
//           },
//         );
//       },
//     );
//   }

//   Widget _buildCompanyWithAllOffersItem(Map<String, dynamic> companyData) {
//     final String companyName = companyData['companyName'];
//     final String companyId = companyData['companyId'];
//     final int totalOffers = companyData['totalOffers'];
//     final int totalTrips = companyData['totalTrips'];

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFF3498DB).withOpacity(0.3)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         leading: Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             color: const Color(0xFF3498DB).withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: const Icon(Icons.business, color: Color(0xFF3498DB), size: 24),
//         ),
//         title: Text(
//           companyName,
//           style: const TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF2C3E50),
//           ),
//         ),
//         subtitle: Text(
//           '$totalTrips عروض السعر :',
//           style: const TextStyle(fontSize: 12, color: Colors.grey),
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _buildActionButton(
//               icon: Icons.business,
//               label: 'الشركات',
//               color: Colors.blue,
//               onPressed: () {
//                 setState(() => _activeView = 'companies');
//                 _showAllCompanyOffers(companyId, companyName, 'companies');
//               },
//             ),
//             const SizedBox(width: 8),
//             _buildActionButton(
//               icon: Icons.directions_bus,
//               label: 'العجل',
//               color: Colors.purple,
//               onPressed: () {
//                 setState(() => _activeView = 'wheels');
//                 _showAllCompanyOffers(companyId, companyName, 'wheels');
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showAllCompanyOffers(
//     String companyId,
//     String companyName,
//     String viewType,
//   ) {
//     _currentCompanyId = companyId;
//     _currentCompanyName = companyName;
//     _currentViewType = viewType;

//     showDialog(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: t.TextDirection.rtl,
//         child: Dialog(
//           backgroundColor: Colors.transparent,
//           insetPadding: const EdgeInsets.all(16),
//           child: Container(
//             width: MediaQuery.of(context).size.width * 0.95,
//             constraints: BoxConstraints(
//               maxHeight: MediaQuery.of(context).size.height * 0.9,
//             ),
//             padding: const EdgeInsets.all(20),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.15),
//                   blurRadius: 20,
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // العنوان
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         // زر الطباعة
//                         IconButton(
//                           icon: Icon(Icons.print, color: Colors.green[700]),
//                           onPressed: () => _generatePDF(),
//                         ),
//                         // زر الإغلاق
//                         IconButton(
//                           icon: const Icon(Icons.close),
//                           onPressed: () => Navigator.pop(context),
//                         ),
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         Text(
//                           viewType == 'companies'
//                               ? 'عروض اسعار الشركات - $companyName'
//                               : 'عروض اسعار العجل - $companyName',
//                           style: const TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF2C3E50),
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                       ],
//                     ),
//                     const SizedBox(width: 48),
//                   ],
//                 ),

//                 const SizedBox(height: 8),
//                 Divider(color: const Color(0xFF3498DB).withOpacity(0.3)),

//                 // إحصائيات الشركة
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF3498DB).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       Column(
//                         children: [
//                           const Text(
//                             'اسم الشركة',
//                             style: TextStyle(fontSize: 11, color: Colors.grey),
//                           ),
//                           Text(
//                             companyName,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF2C3E50),
//                             ),
//                           ),
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           const Text(
//                             'إجمالي العروض',
//                             style: TextStyle(fontSize: 11, color: Colors.grey),
//                           ),
//                           StreamBuilder<QuerySnapshot>(
//                             stream: _firestore
//                                 .collection('companies')
//                                 .doc(companyId)
//                                 .collection('priceOffers')
//                                 .snapshots(),
//                             builder: (context, snapshot) {
//                               int totalTrips = 0;
//                               if (snapshot.hasData) {
//                                 for (final doc in snapshot.data!.docs) {
//                                   final data =
//                                       doc.data() as Map<String, dynamic>;
//                                   final transports =
//                                       data['transportations'] as List? ?? [];
//                                   totalTrips += transports.length;
//                                 }
//                               }
//                               return Text(
//                                 '$totalTrips',
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF2C3E50),
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // الجدول
//                 Expanded(child: _buildCompanyOffersTable(companyId, viewType)),

//                 const SizedBox(height: 16),

//                 // زر الإغلاق
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () => _generatePDF(),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color.fromARGB(255, 255, 0, 0),
//                         foregroundColor: Colors.white,
//                         elevation: 2,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 40,
//                           vertical: 12,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             Icons.print,
//                             color: const Color.fromARGB(255, 255, 255, 255),
//                           ),

//                           // Text('طباعه'),
//                         ],
//                       ),
//                     ),
//                     SizedBox(width: 10),

//                     ElevatedButton(
//                       onPressed: () => Navigator.pop(context),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF3498DB),
//                         foregroundColor: Colors.white,
//                         elevation: 2,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 40,
//                           vertical: 12,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: const Text('إغلاق'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCompanyOffersTable(String companyId, String viewType) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _firestore
//           .collection('companies')
//           .doc(companyId)
//           .collection('priceOffers')
//           .orderBy('updatedAt', descending: true)
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.error, size: 48, color: Colors.red),
//                 const SizedBox(height: 8),
//                 Text(
//                   'خطأ في تحميل البيانات: ${snapshot.error}',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(fontSize: 14, color: Colors.red),
//                 ),
//               ],
//             ),
//           );
//         }

//         final offers = snapshot.data!.docs.map((doc) {
//           final data = doc.data() as Map<String, dynamic>;
//           return PriceOffer.fromMap(data, doc.id);
//         }).toList();

//         if (offers.isEmpty) {
//           return const Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.description, size: 64, color: Colors.grey),
//                 SizedBox(height: 16),
//                 Text(
//                   'لا توجد عروض أسعار',
//                   style: TextStyle(fontSize: 16, color: Colors.grey),
//                 ),
//               ],
//             ),
//           );
//         }

//         // جمع كل الرحلات من كل العروض
//         List<TransportationWithOffer> allTransportations = [];
//         for (final offer in offers) {
//           for (final transport in offer.transportations) {
//             allTransportations.add(
//               TransportationWithOffer(
//                 transportation: transport,
//                 offerId: offer.id,
//                 companyId: companyId,
//                 offer: offer,
//               ),
//             );
//           }
//         }

//         // حفظ البيانات للطباعة
//         _currentTransportations = allTransportations;

//         return viewType == 'companies'
//             ? _buildCompaniesTable(allTransportations)
//             : _buildWheelsTable(allTransportations);
//       },
//     );
//   }

//   // ================= إنشاء PDF =================
//   Future<void> _generatePDF() async {
//     if (_arabicFont == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('الخط العربي غير محمل')));
//       return;
//     }

//     if (_currentCompanyName == null ||
//         _currentViewType == null ||
//         _currentTransportations == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('لا توجد بيانات للطباعة')));
//       return;
//     }

//     setState(() => _isGeneratingPDF = true);

//     try {
//       // إنشاء PDF
//       final pdf = pdfLib.Document(
//         theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
//       );

//       // إضافة صفحة واحدة فقط تحتوي على كل شيء
//       pdf.addPage(
//         pdfLib.MultiPage(
//           pageFormat: PdfPageFormat.a4,
//           margin: pdfLib.EdgeInsets.all(25),
//           build: (context) => [
//             _buildPdfHeader(),
//             pdfLib.SizedBox(height: 15),
//             _buildPdfTitle(),
//             pdfLib.SizedBox(height: 25),
//             _currentViewType == 'companies'
//                 ? _buildCompaniesPdfTable(_currentTransportations!)
//                 : _buildWheelsPdfTable(_currentTransportations!),
//             pdfLib.SizedBox(height: 20),
//           ],
//         ),
//       );

//       // طباعة PDF
//       await Printing.layoutPdf(
//         onLayout: (PdfPageFormat format) async => pdf.save(),
//         name: _getPDFFileName(),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('حدث خطأ في إنشاء PDF: $e')));
//     } finally {
//       setState(() => _isGeneratingPDF = false);
//     }
//   }

//   // ================= بناء رأس التقرير =================
//   pdfLib.Widget _buildPdfHeader() {
//     return pdfLib.Directionality(
//       textDirection: pdfLib.TextDirection.rtl,
//       child: pdfLib.Column(
//         crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
//         children: [
//           pdfLib.Row(
//             mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
//             children: [
//               pdfLib.Text(
//                 'FN 454.4 - 203/317/21',
//                 style: pdfLib.TextStyle(
//                   fontSize: 14,
//                   fontWeight: pdfLib.FontWeight.bold,
//                   font: _arabicFont,
//                   color: PdfColors.black,
//                 ),
//               ),
//               pdfLib.Text(
//                 _currentViewType == 'companies'
//                     ? 'عروض أسعار الشركات'
//                     : 'عروض أسعار العجل',
//                 style: pdfLib.TextStyle(
//                   fontSize: 20,
//                   fontWeight: pdfLib.FontWeight.bold,
//                   font: _arabicFont,
//                   color: PdfColors.black,
//                 ),
//               ),
//             ],
//           ),
//           pdfLib.Divider(color: PdfColors.black, thickness: 2),
//         ],
//       ),
//     );
//   }

//   // ================= بناء عنوان التقرير =================
//   pdfLib.Widget _buildPdfTitle() {
//     return pdfLib.Directionality(
//       textDirection: pdfLib.TextDirection.rtl,
//       child: pdfLib.Column(
//         crossAxisAlignment: pdfLib.CrossAxisAlignment.center,
//         children: [
//           pdfLib.Text(
//             _currentCompanyName!,
//             style: pdfLib.TextStyle(
//               fontSize: 18,
//               fontWeight: pdfLib.FontWeight.bold,
//               font: _arabicFont,
//               color: PdfColors.black,
//             ),
//             textAlign: pdfLib.TextAlign.center,
//           ),
//           pdfLib.SizedBox(height: 10),
//           pdfLib.Text(
//             'تاريخ الطباعة: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}',
//             style: pdfLib.TextStyle(
//               fontSize: 14,
//               font: _arabicFont,
//               color: PdfColors.black,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ================= بناء جدول الشركات PDF =================
//   pdfLib.Widget _buildCompaniesPdfTable(
//     List<TransportationWithOffer> transportations,
//   ) {
//     return pdfLib.Directionality(
//       textDirection: pdfLib.TextDirection.rtl,
//       child: pdfLib.Column(
//         children: [
//           // جدول الإجمالي
//           pdfLib.Container(
//             padding: pdfLib.EdgeInsets.all(12),
//             decoration: pdfLib.BoxDecoration(
//               border: pdfLib.Border.all(color: PdfColors.black, width: 2),
//             ),
//             child: pdfLib.Row(
//               mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
//               children: [
//                 pdfLib.Text(
//                   'إجمالي العروض',
//                   style: pdfLib.TextStyle(
//                     fontSize: 18,
//                     fontWeight: pdfLib.FontWeight.bold,
//                     font: _arabicFont,
//                     color: PdfColors.black,
//                   ),
//                 ),
//                 pdfLib.Text(
//                   '${transportations.length}',
//                   style: pdfLib.TextStyle(
//                     fontSize: 20,
//                     fontWeight: pdfLib.FontWeight.bold,
//                     font: _arabicFont,
//                     color: PdfColors.black,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           pdfLib.SizedBox(height: 15),

//           // الجدول الرئيسي
//           pdfLib.Table(
//             border: pdfLib.TableBorder.all(color: PdfColors.black, width: 1.5),
//             columnWidths: {
//               6: pdfLib.FlexColumnWidth(.7), // م
//               5: pdfLib.FlexColumnWidth(2.0), // مكان التحميل
//               4: pdfLib.FlexColumnWidth(2.0), // مكان التعتيق
//               3: pdfLib.FlexColumnWidth(2.0), // نوع العربية
//               2: pdfLib.FlexColumnWidth(1.5), // النولون
//               1: pdfLib.FlexColumnWidth(1.5), // المبيت
//               0: pdfLib.FlexColumnWidth(1.5), // العطلة
//             },
//             defaultVerticalAlignment: pdfLib.TableCellVerticalAlignment.middle,
//             children: [
//               // رأس الجدول - الشركات
//               pdfLib.TableRow(
//                 children: [
//                   _buildPdfHeaderCell('العطلة'),
//                   _buildPdfHeaderCell('المبيت'),
//                   _buildPdfHeaderCell('النولون'),
//                   _buildPdfHeaderCell('نوع العربية'),
//                   _buildPdfHeaderCell('مكان التعتيق'),
//                   _buildPdfHeaderCell('مكان التحميل'),
//                   _buildPdfHeaderCell('م'),
//                 ],
//               ),

//               // بيانات الجدول - الشركات
//               ...transportations.asMap().entries.map((entry) {
//                 int index = entry.key + 1;
//                 final item = entry.value;
//                 final transport = item.transportation;

//                 return pdfLib.TableRow(
//                   children: [
//                     _buildPdfDataCell('${transport.companyHoliday} '),
//                     _buildPdfDataCell('${transport.companyOvernight}'),
//                     _buildPdfDataCell('${transport.nolon}'),
//                     _buildPdfDataCell(transport.vehicleType),
//                     _buildPdfDataCell(transport.unloadingLocation),
//                     _buildPdfDataCell(transport.loadingLocation),
//                     _buildPdfDataCell(index.toString()),
//                   ],
//                 );
//               }),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ================= بناء جدول العجل PDF =================
//   pdfLib.Widget _buildWheelsPdfTable(
//     List<TransportationWithOffer> transportations,
//   ) {
//     return pdfLib.Directionality(
//       textDirection: pdfLib.TextDirection.rtl,
//       child: pdfLib.Column(
//         children: [
//           // جدول الإجمالي
//           pdfLib.Container(
//             padding: pdfLib.EdgeInsets.all(12),
//             decoration: pdfLib.BoxDecoration(
//               border: pdfLib.Border.all(color: PdfColors.black, width: 2),
//             ),
//             child: pdfLib.Row(
//               mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
//               children: [
//                 pdfLib.Text(
//                   'إجمالي العروض',
//                   style: pdfLib.TextStyle(
//                     fontSize: 18,
//                     fontWeight: pdfLib.FontWeight.bold,
//                     font: _arabicFont,
//                     color: PdfColors.black,
//                   ),
//                 ),
//                 pdfLib.Text(
//                   '${transportations.length}',
//                   style: pdfLib.TextStyle(
//                     fontSize: 20,
//                     fontWeight: pdfLib.FontWeight.bold,
//                     font: _arabicFont,
//                     color: PdfColors.black,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           pdfLib.SizedBox(height: 15),

//           // الجدول الرئيسي
//           pdfLib.Table(
//             border: pdfLib.TableBorder.all(color: PdfColors.black, width: 1.5),
//             columnWidths: {
//               6: pdfLib.FlexColumnWidth(0.7), // م
//               5: pdfLib.FlexColumnWidth(2.0), // مكان التحميل
//               4: pdfLib.FlexColumnWidth(2.0), // مكان التعتيق
//               3: pdfLib.FlexColumnWidth(2.0), // نوع العربية
//               2: pdfLib.FlexColumnWidth(1.5), // النولون
//               1: pdfLib.FlexColumnWidth(1.5), // المبيت
//               0: pdfLib.FlexColumnWidth(1.5), // العطلة
//             },
//             defaultVerticalAlignment: pdfLib.TableCellVerticalAlignment.middle,
//             children: [
//               // رأس الجدول - العجل
//               pdfLib.TableRow(
//                 children: [
//                   _buildPdfHeaderCell('العطلة'),
//                   _buildPdfHeaderCell('المبيت'),
//                   _buildPdfHeaderCell('النولون'),
//                   _buildPdfHeaderCell('نوع العربية'),
//                   _buildPdfHeaderCell('مكان التعتيق'),
//                   _buildPdfHeaderCell('مكان التحميل'),
//                   _buildPdfHeaderCell('م'),
//                 ],
//               ),

//               // بيانات الجدول - العجل
//               ...transportations.asMap().entries.map((entry) {
//                 int index = entry.key + 1;
//                 final item = entry.value;
//                 final transport = item.transportation;

//                 return pdfLib.TableRow(
//                   children: [
//                     _buildPdfDataCell('${transport.wheelHoliday}'),
//                     _buildPdfDataCell('${transport.wheelOvernight}'),
//                     _buildPdfDataCell('${transport.wheelNolon}'),
//                     _buildPdfDataCell(transport.vehicleType),
//                     _buildPdfDataCell(transport.unloadingLocation),
//                     _buildPdfDataCell(transport.loadingLocation),
//                     _buildPdfDataCell(index.toString()),
//                   ],
//                 );
//               }),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ================= بناء خلية رأس الجدول =================
//   pdfLib.Widget _buildPdfHeaderCell(String text) {
//     return pdfLib.Container(
//       padding: pdfLib.EdgeInsets.all(10),
//       child: pdfLib.Text(
//         text,
//         style: pdfLib.TextStyle(
//           fontSize: 14,
//           fontWeight: pdfLib.FontWeight.bold,
//           font: _arabicFont,
//           color: PdfColors.black,
//         ),
//         textAlign: pdfLib.TextAlign.center,
//       ),
//     );
//   }

//   // ================= بناء خلية بيانات الجدول =================
//   pdfLib.Widget _buildPdfDataCell(
//     String text, {
//     pdfLib.TextAlign textAlign = pdfLib.TextAlign.center,
//     bool isAmount = false,
//   }) {
//     return pdfLib.Container(
//       padding: pdfLib.EdgeInsets.all(8),
//       child: pdfLib.Text(
//         text,
//         style: pdfLib.TextStyle(
//           fontSize: 13,
//           fontWeight: isAmount
//               ? pdfLib.FontWeight.bold
//               : pdfLib.FontWeight.normal,
//           font: _arabicFont,
//           color: PdfColors.black,
//         ),
//         textAlign: textAlign,
//         maxLines: 2,
//       ),
//     );
//   }

//   // ================= الحصول على اسم الملف =================
//   String _getPDFFileName() {
//     final now = DateTime.now();
//     final formattedDate = DateFormat('yyyyMMdd').format(now);
//     final viewTypeText = _currentViewType == 'companies' ? 'شركات' : 'عجل';
//     return 'عروض_اسعار_${viewTypeText}_${_currentCompanyName}_$formattedDate';
//   }

//   Widget _buildCompaniesTable(List<TransportationWithOffer> transportations) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.transparent, width: 1.5),
//       ),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: SingleChildScrollView(
//           scrollDirection: Axis.vertical,
//           child: Table(
//             defaultColumnWidth: const FixedColumnWidth(150),
//             border: TableBorder.all(color: const Color(0xFF3498DB), width: 1),
//             children: [
//               /// ✅ العناوين - جدول الشركات
//               TableRow(
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF3498DB).withOpacity(0.15),
//                 ),
//                 children: const [
//                   _TableCellHeader('م'),
//                   _TableCellHeader('مكان التحميل'),
//                   _TableCellHeader('مكان التعتيق'),
//                   _TableCellHeader('نوع العربية'),
//                   _TableCellHeader('النولون'),
//                   _TableCellHeader('المبيت'),
//                   _TableCellHeader('العطلة'),
//                   _TableCellHeader('الإجراءات'),
//                 ],
//               ),

//               /// ✅ الصفوف - جدول الشركات
//               ...transportations.asMap().entries.map((entry) {
//                 final index = entry.key;
//                 final item = entry.value;
//                 final transport = item.transportation;

//                 return TableRow(
//                   decoration: BoxDecoration(
//                     color: index.isEven
//                         ? Colors.white
//                         : const Color(0xFFF8F9FA),
//                   ),
//                   children: [
//                     _TableCellBody('${index + 1}'),
//                     _TableCellBody(transport.loadingLocation),
//                     _TableCellBody(transport.unloadingLocation),
//                     _TableCellBody(transport.vehicleType),
//                     _TableCellBody('${transport.nolon} ج'),
//                     _TableCellBody('${transport.companyOvernight} ج'),
//                     _TableCellBody('${transport.companyHoliday} ج'),
//                     _TableCellActions(
//                       onEdit: () => _editTransportation(item, 'companies'),
//                       onDelete: () => _deleteTransportation(item),
//                     ),
//                   ],
//                 );
//               }),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildWheelsTable(List<TransportationWithOffer> transportations) {
//     return Container(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.transparent, width: 1.5),
//       ),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: SingleChildScrollView(
//           scrollDirection: Axis.vertical,
//           child: Table(
//             defaultColumnWidth: const FixedColumnWidth(150),
//             border: TableBorder.all(color: const Color(0xFF6A1B9A), width: 1),
//             children: [
//               /// ✅ العناوين - جدول العجل
//               TableRow(
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF6A1B9A).withOpacity(0.15),
//                 ),
//                 children: const [
//                   _TableCellHeader('م'),
//                   _TableCellHeader('مكان التحميل'),
//                   _TableCellHeader('مكان التعتيق'),
//                   _TableCellHeader('نوع العربية'),
//                   _TableCellHeader('النولون'),
//                   _TableCellHeader('المبيت'),
//                   _TableCellHeader('العطلة'),
//                   _TableCellHeader('الإجراءات'),
//                 ],
//               ),

//               /// ✅ الصفوف - جدول العجل
//               ...transportations.asMap().entries.map((entry) {
//                 final index = entry.key;
//                 final item = entry.value;
//                 final transport = item.transportation;

//                 return TableRow(
//                   decoration: BoxDecoration(
//                     color: index.isEven
//                         ? Colors.white
//                         : const Color(0xFFF8F9FA),
//                   ),
//                   children: [
//                     _TableCellBody('${index + 1}'),
//                     _TableCellBody(transport.loadingLocation),
//                     _TableCellBody(transport.unloadingLocation),
//                     _TableCellBody(transport.vehicleType),
//                     _TableCellBody('${transport.wheelNolon} ج'),
//                     _TableCellBody('${transport.wheelOvernight} ج'),
//                     _TableCellBody('${transport.wheelHoliday} ج'),
//                     _TableCellActions(
//                       onEdit: () => _editTransportation(item, 'wheels'),
//                       onDelete: () => _deleteTransportation(item),
//                     ),
//                   ],
//                 );
//               }),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // دالة تعديل الرحلة
//   void _editTransportation(TransportationWithOffer item, String viewType) {
//     final transportation = item.transportation;
//     final isCompaniesView = viewType == 'companies';

//     final loadingLocationController = TextEditingController(
//       text: transportation.loadingLocation,
//     );
//     final unloadingLocationController = TextEditingController(
//       text: transportation.unloadingLocation,
//     );
//     final vehicleTypeController = TextEditingController(
//       text: transportation.vehicleType,
//     );
//     final nolonController = TextEditingController(
//       text: isCompaniesView
//           ? transportation.nolon.toString()
//           : transportation.wheelNolon.toString(),
//     );
//     final overnightController = TextEditingController(
//       text: isCompaniesView
//           ? transportation.companyOvernight.toString()
//           : transportation.wheelOvernight.toString(),
//     );
//     final holidayController = TextEditingController(
//       text: isCompaniesView
//           ? transportation.companyHoliday.toString()
//           : transportation.wheelHoliday.toString(),
//     );
//     final notesController = TextEditingController(
//       text: transportation.notes ?? '',
//     );

//     showDialog(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: t.TextDirection.rtl,
//         child: Dialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: SingleChildScrollView(
//             child: Container(
//               padding: const EdgeInsets.all(24),
//               width: MediaQuery.of(context).size.width * 0.9,
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // العنوان
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'تعديل الرحلة - ${isCompaniesView ? 'الشركات' : 'العجل'}',
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF2C3E50),
//                         ),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.close),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 8),
//                   Divider(color: const Color(0xFF3498DB).withOpacity(0.3)),

//                   const SizedBox(height: 20),

//                   // حقل مكان التحميل
//                   _buildEditField(
//                     'مكان التحميل',
//                     'أدخل مكان التحميل',
//                     loadingLocationController,
//                     Icons.location_on,
//                   ),

//                   const SizedBox(height: 16),

//                   // حقل مكان التعتيق
//                   _buildEditField(
//                     'مكان التعتيق',
//                     'أدخل مكان التعتيق',
//                     unloadingLocationController,
//                     Icons.location_on,
//                   ),

//                   const SizedBox(height: 16),

//                   // حقل نوع العربية
//                   _buildEditField(
//                     'نوع العربية',
//                     'أدخل نوع العربية',
//                     vehicleTypeController,
//                     Icons.directions_car,
//                   ),

//                   const SizedBox(height: 16),

//                   // حقل النولون
//                   _buildEditField(
//                     'النولون',
//                     'أدخل النولون',
//                     nolonController,
//                     Icons.attach_money,
//                     keyboardType: TextInputType.number,
//                   ),

//                   const SizedBox(height: 16),

//                   // حقل المبيت
//                   _buildEditField(
//                     'المبيت',
//                     'أدخل المبيت',
//                     overnightController,
//                     Icons.hotel,
//                     keyboardType: TextInputType.number,
//                   ),

//                   const SizedBox(height: 16),

//                   // حقل العطلة
//                   _buildEditField(
//                     'العطلة',
//                     'أدخل العطلة',
//                     holidayController,
//                     Icons.beach_access,
//                     keyboardType: TextInputType.number,
//                   ),

//                   const SizedBox(height: 16),

//                   // حقل الملاحظات
//                   _buildEditField(
//                     'ملاحظات',
//                     'أدخل الملاحظات (اختياري)',
//                     notesController,
//                     Icons.note,
//                     maxLines: 3,
//                   ),

//                   const SizedBox(height: 24),

//                   // أزرار الحفظ والإلغاء
//                   Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton(
//                           onPressed: () => Navigator.pop(context),
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: const Text(
//                             'إلغاء',
//                             style: TextStyle(
//                               color: Color(0xFF2C3E50),
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       Expanded(
//                         child: ElevatedButton(
//                           onPressed: () {
//                             _updateTransportation(
//                               item,
//                               loadingLocationController.text,
//                               unloadingLocationController.text,
//                               vehicleTypeController.text,
//                               nolonController.text,
//                               overnightController.text,
//                               holidayController.text,
//                               notesController.text,
//                               isCompaniesView,
//                             );
//                             Navigator.pop(context);
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF3498DB),
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                           child: const Text(
//                             'حفظ التعديلات',
//                             style: TextStyle(fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEditField(
//     String label,
//     String hint,
//     TextEditingController controller,
//     IconData icon, {
//     TextInputType keyboardType = TextInputType.text,
//     int maxLines = 1,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF2C3E50),
//             fontSize: 14,
//           ),
//         ),
//         const SizedBox(height: 6),
//         TextFormField(
//           controller: controller,
//           keyboardType: keyboardType,
//           maxLines: maxLines,
//           decoration: InputDecoration(
//             hintText: hint,
//             prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
//             filled: true,
//             fillColor: const Color(0xFFF4F6F8),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide.none,
//             ),
//             contentPadding: const EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: 12,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // دالة تحديث الرحلة في Firebase
//   Future<void> _updateTransportation(
//     TransportationWithOffer item,
//     String loadingLocation,
//     String unloadingLocation,
//     String vehicleType,
//     String nolon,
//     String overnight,
//     String holiday,
//     String notes,
//     bool isCompaniesView,
//   ) async {
//     try {
//       final offerRef = _firestore
//           .collection('companies')
//           .doc(item.companyId)
//           .collection('priceOffers')
//           .doc(item.offerId);

//       // جلب العرض الحالي
//       final offerDoc = await offerRef.get();
//       final offerData = offerDoc.data() as Map<String, dynamic>;
//       final List<dynamic> transportations = offerData['transportations'];

//       // تحديث الرحلة المحددة
//       final updatedTransportations = transportations.map((transport) {
//         final map = transport as Map<String, dynamic>;
//         if (map['loadingLocation'] == item.transportation.loadingLocation &&
//             map['unloadingLocation'] == item.transportation.unloadingLocation &&
//             map['vehicleType'] == item.transportation.vehicleType) {
//           final updatedMap = {
//             ...map,
//             'loadingLocation': loadingLocation.trim(),
//             'unloadingLocation': unloadingLocation.trim(),
//             'vehicleType': vehicleType.trim(),
//             'notes': notes.trim().isEmpty ? null : notes.trim(),
//           };

//           // تحديث الحقول حسب النوع
//           if (isCompaniesView) {
//             updatedMap['nolon'] =
//                 double.tryParse(nolon) ?? item.transportation.nolon;
//             updatedMap['companyOvernight'] =
//                 double.tryParse(overnight) ??
//                 item.transportation.companyOvernight;
//             updatedMap['companyHoliday'] =
//                 double.tryParse(holiday) ?? item.transportation.companyHoliday;
//           } else {
//             updatedMap['wheelNolon'] =
//                 double.tryParse(nolon) ?? item.transportation.wheelNolon;
//             updatedMap['wheelOvernight'] =
//                 double.tryParse(overnight) ??
//                 item.transportation.wheelOvernight;
//             updatedMap['wheelHoliday'] =
//                 double.tryParse(holiday) ?? item.transportation.wheelHoliday;
//           }

//           return updatedMap;
//         }
//         return transport;
//       }).toList();

//       // تحديث العرض في Firebase
//       await offerRef.update({
//         'transportations': updatedTransportations,
//         'updatedAt': Timestamp.now(),
//       });

//       // إظهار رسالة نجاح
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('تم تعديل الرحلة بنجاح'),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error updating transportation: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('خطأ في التعديل: $e'),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     }
//   }

//   // دالة حذف الرحلة
//   void _deleteTransportation(TransportationWithOffer item) {
//     showDialog(
//       context: context,
//       builder: (context) => Directionality(
//         textDirection: t.TextDirection.rtl,
//         child: AlertDialog(
//           backgroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           title: const Row(
//             children: [
//               Icon(Icons.warning, color: Colors.orange),
//               SizedBox(width: 8),
//               Text(
//                 'تأكيد الحذف',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2C3E50),
//                 ),
//               ),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'هل أنت متأكد من حذف هذه الرحلة؟',
//                 style: TextStyle(fontSize: 16),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'المسار: ${item.transportation.loadingLocation} → ${item.transportation.unloadingLocation}',
//                 style: const TextStyle(color: Colors.grey),
//               ),
//               Text(
//                 'النولون: ${item.transportation.nolon} ج',
//                 style: const TextStyle(color: Colors.grey),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 '⚠️ لا يمكن التراجع عن هذا الإجراء',
//                 style: TextStyle(
//                   color: Colors.red,
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text(
//                 'إلغاء',
//                 style: TextStyle(color: Color(0xFF2C3E50)),
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 _confirmDeleteTransportation(item);
//                 Navigator.pop(context);
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//               ),
//               child: const Text('حذف'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // دالة تأكيد الحذف
//   Future<void> _confirmDeleteTransportation(
//     TransportationWithOffer item,
//   ) async {
//     try {
//       final offerRef = _firestore
//           .collection('companies')
//           .doc(item.companyId)
//           .collection('priceOffers')
//           .doc(item.offerId);

//       // جلب العرض الحالي
//       final offerDoc = await offerRef.get();
//       final offerData = offerDoc.data() as Map<String, dynamic>;
//       final List<dynamic> transportations = offerData['transportations'];

//       // تصفية الرحلة المطلوب حذفها
//       final updatedTransportations = transportations.where((transport) {
//         final map = transport as Map<String, dynamic>;
//         return !(map['loadingLocation'] ==
//                 item.transportation.loadingLocation &&
//             map['unloadingLocation'] == item.transportation.unloadingLocation &&
//             map['vehicleType'] == item.transportation.vehicleType);
//       }).toList();

//       // إذا لم يتبقى أي رحلات، احذف العرض كاملاً
//       if (updatedTransportations.isEmpty) {
//         await offerRef.delete();
//       } else {
//         // وإلا قم بتحديث العرض
//         await offerRef.update({
//           'transportations': updatedTransportations,
//           'updatedAt': Timestamp.now(),
//         });
//       }

//       // إظهار رسالة نجاح
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('تم حذف الرحلة بنجاح'),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 2),
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error deleting transportation: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('خطأ في الحذف: $e'),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     }
//   }

//   Widget _buildActionButton({
//     required IconData icon,
//     required String label,
//     required Color color,
//     required VoidCallback onPressed,
//   }) {
//     return ElevatedButton.icon(
//       onPressed: onPressed,
//       icon: Icon(icon, size: 18),
//       label: Text(label),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color.withOpacity(0.9),
//         foregroundColor: Colors.white,
//         elevation: 0,
//         padding: const EdgeInsets.symmetric(vertical: 10),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }

// // نموذج مساعد لتخزين معلومات الرحلة مع معلومات العرض
// class TransportationWithOffer {
//   final Transportation transportation;
//   final offerId;
//   final String companyId;
//   final PriceOffer offer;

//   TransportationWithOffer({
//     required this.transportation,
//     required this.offerId,
//     required this.companyId,
//     required this.offer,
//   });
// }

// class _TableCellBody extends StatelessWidget {
//   final String text;
//   final TextStyle? textStyle;

//   const _TableCellBody(this.text, {this.textStyle});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 48,
//       alignment: Alignment.center,
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       child: Text(
//         text,
//         maxLines: 2,
//         overflow: TextOverflow.ellipsis,
//         textAlign: TextAlign.center,
//         style: textStyle,
//       ),
//     );
//   }
// }

// class _TableCellHeader extends StatelessWidget {
//   final String text;
//   const _TableCellHeader(this.text);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 50,
//       alignment: Alignment.center,
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       child: Text(
//         text,
//         style: const TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 14,
//           color: Color(0xFF2C3E50),
//         ),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
// }

// class _TableCellActions extends StatelessWidget {
//   final VoidCallback onEdit;
//   final VoidCallback onDelete;

//   const _TableCellActions({required this.onEdit, required this.onDelete});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 48,
//       alignment: Alignment.center,
//       padding: const EdgeInsets.symmetric(horizontal: 4),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // زر التعديل
//           IconButton(
//             icon: Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: Colors.blue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: const Icon(Icons.edit, size: 16, color: Colors.blue),
//             ),
//             onPressed: onEdit,
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//           ),
//           const SizedBox(width: 4),
//           // زر الحذف
//           IconButton(
//             icon: Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: Colors.red.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: const Icon(Icons.delete, size: 16, color: Colors.red),
//             ),
//             onPressed: onDelete,
//             padding: EdgeInsets.zero,
//             constraints: const BoxConstraints(),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:last/models/models.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' as t;

class PriceOffersListScreen extends StatefulWidget {
  const PriceOffersListScreen({super.key});

  @override
  State<PriceOffersListScreen> createState() => _PriceOffersListScreenState();
}

class _PriceOffersListScreenState extends State<PriceOffersListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _searchQuery = '';
  String _activeView = 'companies'; // 'companies' أو 'wheels'
  pdfLib.Font? _arabicFont;
  bool _isGeneratingPDF = false;
  String? _currentCompanyName;
  String? _currentViewType;
  String? _currentCompanyId;
  List<TransportationWithOffer>? _currentTransportations;

  @override
  void initState() {
    super.initState();
    _loadArabicFont();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildSearchAndStatsBar(),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: _buildCompaniesWithOffersList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndStatsBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // شريط البحث
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3498DB), width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF3498DB), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: const InputDecoration(
                      hintText: 'ابحث عن شركة...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _searchQuery = ''),
                    child: const Icon(
                      Icons.clear,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // الإحصائيات
          _buildStatsBar(),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collectionGroup('priceOffers').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }

        int totalCompanies = 0;
        int totalOffers = 0;
        int totalTrips = 0;

        // حساب الإحصائيات من البيانات الحالية
        final companiesData = _extractCompaniesData(snapshot.data!);
        totalCompanies = companiesData.length;

        for (final company in companiesData) {
          totalOffers += (company['totalOffers'] as num).toInt();
          totalTrips += (company['totalTrips'] as num).toInt();
        }
        return Row(
          children: [
            _buildStatCard('شركات', totalCompanies.toString(), Icons.business),
            const SizedBox(width: 12),
            _buildStatCard('عروض', totalTrips.toString(), Icons.description),
            const SizedBox(width: 12),
          ],
        );
      },
    );
  }

  List<Map<String, dynamic>> _extractCompaniesData(QuerySnapshot snapshot) {
    final Map<String, Map<String, dynamic>> companiesMap = {};

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final companyId = _extractCompanyIdFromPath(doc.reference.path);
      final companyName = data['companyName'] ?? 'غير معروف';

      if (!companiesMap.containsKey(companyId)) {
        companiesMap[companyId] = {
          'companyId': companyId,
          'companyName': companyName,
          'totalOffers': 0,
          'totalTrips': 0,
        };
      }

      companiesMap[companyId]!['totalOffers']++;
      final transports = data['transportations'] as List? ?? [];
      companiesMap[companyId]!['totalTrips'] += transports.length;
    }

    return companiesMap.values.toList();
  }

  String _extractCompanyIdFromPath(String path) {
    final parts = path.split('/');
    return parts[1]; // companies/{companyId}/priceOffers/{offerId}
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF3498DB).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF3498DB), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF3498DB), size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompaniesWithOffersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collectionGroup('priceOffers').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('خطأ: ${snapshot.error}', textAlign: TextAlign.center),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final companiesWithOffers = _extractCompaniesData(snapshot.data!);

        final filteredCompanies = companiesWithOffers.where((company) {
          if (_searchQuery.isEmpty) return true;
          final companyName =
              company['companyName']?.toString().toLowerCase() ?? '';
          return companyName.contains(_searchQuery.toLowerCase());
        }).toList();

        if (filteredCompanies.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.business, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'لا توجد شركات لديها عروض أسعار',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isEmpty
                      ? 'أضف عرض سعر جديد للبدء'
                      : 'لم يتم العثور على نتائج البحث',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: filteredCompanies.length,
          itemBuilder: (context, index) {
            final companyData = filteredCompanies[index];
            return _buildCompanyWithAllOffersItem(companyData);
          },
        );
      },
    );
  }

  Widget _buildCompanyWithAllOffersItem(Map<String, dynamic> companyData) {
    final String companyName = companyData['companyName'];
    final String companyId = companyData['companyId'];
    final int totalOffers = companyData['totalOffers'];
    final int totalTrips = companyData['totalTrips'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3498DB).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF3498DB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.business, color: Color(0xFF3498DB), size: 24),
        ),
        title: Text(
          companyName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        subtitle: Text(
          '$totalTrips عروض السعر :',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              icon: Icons.business,
              label: 'الشركات',
              color: Colors.blue,
              onPressed: () {
                setState(() => _activeView = 'companies');
                _showAllCompanyOffers(companyId, companyName, 'companies');
              },
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.directions_bus,
              label: 'العجل',
              color: Colors.purple,
              onPressed: () {
                setState(() => _activeView = 'wheels');
                _showAllCompanyOffers(companyId, companyName, 'wheels');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAllCompanyOffers(
    String companyId,
    String companyName,
    String viewType,
  ) {
    _currentCompanyId = companyId;
    _currentCompanyName = companyName;
    _currentViewType = viewType;

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: t.TextDirection.rtl,
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // العنوان
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // زر الطباعة
                        IconButton(
                          icon: Icon(Icons.print, color: Colors.green[700]),
                          onPressed: () => _generatePDF(),
                        ),
                        // زر الإغلاق
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          viewType == 'companies'
                              ? 'عروض اسعار الشركات - $companyName'
                              : 'عروض اسعار العجل - $companyName',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 8),
                Divider(color: const Color(0xFF3498DB).withOpacity(0.3)),

                // إحصائيات الشركة
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498DB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'اسم الشركة',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          Text(
                            companyName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'إجمالي العروض',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: _firestore
                                .collection('companies')
                                .doc(companyId)
                                .collection('priceOffers')
                                .snapshots(),
                            builder: (context, snapshot) {
                              int totalTrips = 0;
                              if (snapshot.hasData) {
                                for (final doc in snapshot.data!.docs) {
                                  final data =
                                      doc.data() as Map<String, dynamic>;
                                  final transports =
                                      data['transportations'] as List? ?? [];
                                  totalTrips += transports.length;
                                }
                              }
                              return Text(
                                '$totalTrips',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // الجدول
                Expanded(child: _buildCompanyOffersTable(companyId, viewType)),

                const SizedBox(height: 16),

                // زر الإغلاق
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _generatePDF(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.print,
                            color: const Color.fromARGB(255, 255, 255, 255),
                          ),

                          // Text('طباعه'),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),

                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498DB),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('إغلاق'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyOffersTable(String companyId, String viewType) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('companies')
          .doc(companyId)
          .collection('priceOffers')
          .orderBy('updatedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 8),
                Text(
                  'خطأ في تحميل البيانات: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.red),
                ),
              ],
            ),
          );
        }

        final offers = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return PriceOffer.fromMap(data, doc.id);
        }).toList();

        if (offers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.description, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'لا توجد عروض أسعار',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // جمع كل الرحلات من كل العروض
        List<TransportationWithOffer> allTransportations = [];
        for (final offer in offers) {
          for (final transport in offer.transportations) {
            allTransportations.add(
              TransportationWithOffer(
                transportation: transport,
                offerId: offer.id,
                companyId: companyId,
                offer: offer,
              ),
            );
          }
        }

        // حفظ البيانات للطباعة
        _currentTransportations = allTransportations;

        return viewType == 'companies'
            ? _buildCompaniesTable(allTransportations)
            : _buildWheelsTable(allTransportations);
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

    if (_currentCompanyName == null ||
        _currentViewType == null ||
        _currentTransportations == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('لا توجد بيانات للطباعة')));
      return;
    }

    setState(() => _isGeneratingPDF = true);

    try {
      // إنشاء PDF
      final pdf = pdfLib.Document(
        theme: pdfLib.ThemeData.withFont(base: _arabicFont!),
      );

      // تقسيم البيانات إلى صفحات (25 صف لكل صفحة)
      final pages = _splitDataIntoPages(_currentTransportations!);

      for (int pageIndex = 0; pageIndex < pages.length; pageIndex++) {
        pdf.addPage(
          pdfLib.Page(
            pageFormat: PdfPageFormat.a4,
            margin: pdfLib.EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            build: (context) {
              return pdfLib.Column(
                crossAxisAlignment: pdfLib.CrossAxisAlignment.stretch,
                children: [
                  // 1. الهيدر - أعلى الصفحة مباشرة
                  _buildPdfHeader(),
                  pdfLib.SizedBox(height: 10),

                  // 2. العنوان
                  _buildPdfTitle(),
                  pdfLib.SizedBox(height: 10),

                  // 3. إحصائيات العدد
                  _buildPdfStats(_currentTransportations!.length),
                  pdfLib.SizedBox(height: 10),

                  // 4. الجدول - يأخذ المساحة المتبقية
                  pdfLib.Expanded(
                    child: _currentViewType == 'companies'
                        ? _buildCompaniesPdfTablePage(
                            pages[pageIndex],
                            pageIndex,
                          )
                        : _buildWheelsPdfTablePage(pages[pageIndex], pageIndex),
                  ),

                  // 5. رقم الصفحة (إذا كان هناك أكثر من صفحة)
                  if (pages.length > 1) pdfLib.SizedBox(height: 15),
                  if (pages.length > 1)
                    _buildPageNumber(pageIndex + 1, pages.length),
                ],
              );
            },
          ),
        );
      }

      // طباعة PDF
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: _getPDFFileName(),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ في إنشاء PDF: $e')));
    } finally {
      setState(() => _isGeneratingPDF = false);
    }
  }

  // ================= تقسيم البيانات إلى صفحات =================
  List<List<TransportationWithOffer>> _splitDataIntoPages(
    List<TransportationWithOffer> transportations,
  ) {
    List<List<TransportationWithOffer>> pages = [];
    List<TransportationWithOffer> currentPage = [];

    // حوالي 25-30 صف لكل صفحة A4
    int rowsPerPage = 25;

    for (int i = 0; i < transportations.length; i++) {
      currentPage.add(transportations[i]);

      // إذا وصلنا إلى العدد المحدد أو كانت آخر دفعة
      if ((i + 1) % rowsPerPage == 0 || i == transportations.length - 1) {
        pages.add(List.from(currentPage));
        currentPage.clear();
      }
    }

    return pages;
  }

  // ================= بناء الهيدر =================
  pdfLib.Widget _buildPdfHeader() {
    return pdfLib.Directionality(
      textDirection: pdfLib.TextDirection.rtl,
      child: pdfLib.Row(
        mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
        children: [
          pdfLib.Text(
            'FM 454.4 - 203/317/21',
            style: pdfLib.TextStyle(
              fontSize: 12,
              fontWeight: pdfLib.FontWeight.bold,
              font: _arabicFont,
            ),
          ),
          pdfLib.Text(
            _currentViewType == 'companies'
                ? 'عروض أسعار الشركات'
                : 'عروض أسعار العجل',
            style: pdfLib.TextStyle(
              fontSize: 18,
              fontWeight: pdfLib.FontWeight.bold,
              font: _arabicFont,
            ),
          ),
        ],
      ),
    );
  }

  // ================= بناء العنوان =================
  pdfLib.Widget _buildPdfTitle() {
    return pdfLib.Directionality(
      textDirection: pdfLib.TextDirection.rtl,
      child: pdfLib.Column(
        children: [
          pdfLib.Text(
            _currentCompanyName!,
            style: pdfLib.TextStyle(
              fontSize: 16,
              fontWeight: pdfLib.FontWeight.bold,
              font: _arabicFont,
            ),
            textAlign: pdfLib.TextAlign.center,
          ),
          pdfLib.SizedBox(height: 5),
          pdfLib.Text(
            'تاريخ الطباعة: ${DateFormat('yyyy/MM/dd').format(DateTime.now())}',
            style: pdfLib.TextStyle(fontSize: 11, font: _arabicFont),
          ),
        ],
      ),
    );
  }

  // ================= بناء الإحصائيات =================
  pdfLib.Widget _buildPdfStats(int total) {
    return pdfLib.Directionality(
      textDirection: pdfLib.TextDirection.rtl,
      child: pdfLib.Container(
        padding: pdfLib.EdgeInsets.all(8),
        decoration: pdfLib.BoxDecoration(
          border: pdfLib.Border.all(color: PdfColors.black, width: 1.5),
        ),
        child: pdfLib.Row(
          mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
          children: [
            pdfLib.Text(
              'إجمالي العروض',
              style: pdfLib.TextStyle(
                fontSize: 14,
                fontWeight: pdfLib.FontWeight.bold,
                font: _arabicFont,
              ),
            ),
            pdfLib.Text(
              '$total',
              style: pdfLib.TextStyle(
                fontSize: 16,
                fontWeight: pdfLib.FontWeight.bold,
                font: _arabicFont,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= بناء جدول الشركات للصفحة =================
  pdfLib.Widget _buildCompaniesPdfTablePage(
    List<TransportationWithOffer> transportations,
    int pageIndex,
  ) {
    return pdfLib.Directionality(
      textDirection: pdfLib.TextDirection.rtl,
      child: pdfLib.Table(
        border: pdfLib.TableBorder.all(color: PdfColors.black, width: 1),
        columnWidths: {
          6: pdfLib.FlexColumnWidth(0.4), // م
          5: pdfLib.FlexColumnWidth(1.8), // مكان التحميل
          4: pdfLib.FlexColumnWidth(1.8), // مكان التعتيق
          3: pdfLib.FlexColumnWidth(1.2), // نوع العربية
          2: pdfLib.FlexColumnWidth(1.0), // النولون
          1: pdfLib.FlexColumnWidth(1.0), // المبيت
          0: pdfLib.FlexColumnWidth(1.0), // العطلة
        },
        defaultVerticalAlignment: pdfLib.TableCellVerticalAlignment.middle,
        children: [
          // رأس الجدول
          pdfLib.TableRow(
            decoration: pdfLib.BoxDecoration(color: PdfColors.grey200),
            children: [
              _buildCompactHeaderCell('العطلة'),
              _buildCompactHeaderCell('المبيت'),
              _buildCompactHeaderCell('النولون'),
              _buildCompactHeaderCell('نوع العربية'),
              _buildCompactHeaderCell('مكان التعتيق'),
              _buildCompactHeaderCell('مكان التحميل'),
              _buildCompactHeaderCell('م'),
            ],
          ),

          // بيانات الجدول
          ...transportations.asMap().entries.map((entry) {
            int index = (pageIndex * 25) + entry.key + 1;
            final item = entry.value;
            final transport = item.transportation;

            return pdfLib.TableRow(
              decoration: entry.key % 2 == 0
                  ? pdfLib.BoxDecoration(color: PdfColors.white)
                  : pdfLib.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildCompactDataCell('${transport.companyHoliday}'),
                _buildCompactDataCell('${transport.companyOvernight}'),
                _buildCompactDataCell('${transport.nolon}'),
                _buildCompactDataCell(transport.vehicleType),
                _buildCompactDataCell(transport.unloadingLocation),
                _buildCompactDataCell(transport.loadingLocation),
                _buildCompactDataCell(index.toString()),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ================= بناء جدول العجل للصفحة =================
  pdfLib.Widget _buildWheelsPdfTablePage(
    List<TransportationWithOffer> transportations,
    int pageIndex,
  ) {
    return pdfLib.Directionality(
      textDirection: pdfLib.TextDirection.rtl,
      child: pdfLib.Table(
        border: pdfLib.TableBorder.all(color: PdfColors.black, width: 1),
        columnWidths: {
          6: pdfLib.FlexColumnWidth(0.4), // م
          5: pdfLib.FlexColumnWidth(1.8), // مكان التحميل
          4: pdfLib.FlexColumnWidth(1.8), // مكان التعتيق
          3: pdfLib.FlexColumnWidth(1.2), // نوع العربية
          2: pdfLib.FlexColumnWidth(1.0), // النولون
          1: pdfLib.FlexColumnWidth(1.0), // المبيت
          0: pdfLib.FlexColumnWidth(1.0), // العطلة
        },
        defaultVerticalAlignment: pdfLib.TableCellVerticalAlignment.middle,
        children: [
          // رأس الجدول
          pdfLib.TableRow(
            decoration: pdfLib.BoxDecoration(color: PdfColors.grey200),
            children: [
              _buildCompactHeaderCell('العطلة'),
              _buildCompactHeaderCell('المبيت'),
              _buildCompactHeaderCell('النولون'),
              _buildCompactHeaderCell('نوع العربية'),
              _buildCompactHeaderCell('مكان التعتيق'),
              _buildCompactHeaderCell('مكان التحميل'),
              _buildCompactHeaderCell('م'),
            ],
          ),

          // بيانات الجدول
          ...transportations.asMap().entries.map((entry) {
            int index = (pageIndex * 25) + entry.key + 1;
            final item = entry.value;
            final transport = item.transportation;

            return pdfLib.TableRow(
              decoration: entry.key % 2 == 0
                  ? pdfLib.BoxDecoration(color: PdfColors.white)
                  : pdfLib.BoxDecoration(color: PdfColors.grey100),
              children: [
                _buildCompactDataCell('${transport.wheelHoliday}'),
                _buildCompactDataCell('${transport.wheelOvernight}'),
                _buildCompactDataCell('${transport.wheelNolon}'),
                _buildCompactDataCell(transport.vehicleType),
                _buildCompactDataCell(transport.unloadingLocation),
                _buildCompactDataCell(transport.loadingLocation),
                _buildCompactDataCell(index.toString()),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ================= بناء خلية رأس مضغوطة =================
  pdfLib.Widget _buildCompactHeaderCell(String text) {
    return pdfLib.Container(
      padding: pdfLib.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: pdfLib.Text(
        text,
        style: pdfLib.TextStyle(
          fontSize: 11,
          fontWeight: pdfLib.FontWeight.bold,
          font: _arabicFont,
          color: PdfColors.black,
        ),
        textAlign: pdfLib.TextAlign.center,
        maxLines: 2,
      ),
    );
  }

  // ================= بناء خلية بيانات مضغوطة =================
  pdfLib.Widget _buildCompactDataCell(String text) {
    return pdfLib.Container(
      padding: pdfLib.EdgeInsets.symmetric(vertical: 5, horizontal: 3),
      child: pdfLib.Text(
        text,
        style: pdfLib.TextStyle(
          fontSize: 10,
          font: _arabicFont,
          color: PdfColors.black,
        ),
        textAlign: pdfLib.TextAlign.center,
        maxLines: 2,
      ),
    );
  }

  // ================= بناء رقم الصفحة =================
  pdfLib.Widget _buildPageNumber(int currentPage, int totalPages) {
    return pdfLib.Directionality(
      textDirection: pdfLib.TextDirection.rtl,
      child: pdfLib.Container(
        alignment: pdfLib.Alignment.center,
        child: pdfLib.Text(
          'الصفحة $currentPage من $totalPages',
          style: pdfLib.TextStyle(
            fontSize: 10,
            font: _arabicFont,
            color: PdfColors.grey600,
          ),
        ),
      ),
    );
  }

  // ================= الحصول على اسم الملف =================
  String _getPDFFileName() {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyyMMdd').format(now);
    final viewTypeText = _currentViewType == 'companies' ? 'شركات' : 'عجل';
    return 'عروض_اسعار_${viewTypeText}_${_currentCompanyName}_$formattedDate';
  }

  Widget _buildCompaniesTable(List<TransportationWithOffer> transportations) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.transparent, width: 1.5),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Table(
            defaultColumnWidth: const FixedColumnWidth(150),
            border: TableBorder.all(color: const Color(0xFF3498DB), width: 1),
            children: [
              /// ✅ العناوين - جدول الشركات
              TableRow(
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB).withOpacity(0.15),
                ),
                children: const [
                  _TableCellHeader('م'),
                  _TableCellHeader('مكان التحميل'),
                  _TableCellHeader('مكان التعتيق'),
                  _TableCellHeader('نوع العربية'),
                  _TableCellHeader('النولون'),
                  _TableCellHeader('المبيت'),
                  _TableCellHeader('العطلة'),
                  _TableCellHeader('الإجراءات'),
                ],
              ),

              /// ✅ الصفوف - جدول الشركات
              ...transportations.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final transport = item.transportation;

                return TableRow(
                  decoration: BoxDecoration(
                    color: index.isEven
                        ? Colors.white
                        : const Color(0xFFF8F9FA),
                  ),
                  children: [
                    _TableCellBody('${index + 1}'),
                    _TableCellBody(transport.loadingLocation),
                    _TableCellBody(transport.unloadingLocation),
                    _TableCellBody(transport.vehicleType),
                    _TableCellBody('${transport.nolon} ج'),
                    _TableCellBody('${transport.companyOvernight} ج'),
                    _TableCellBody('${transport.companyHoliday} ج'),
                    _TableCellActions(
                      onEdit: () => _editTransportation(item, 'companies'),
                      onDelete: () => _deleteTransportation(item),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWheelsTable(List<TransportationWithOffer> transportations) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.transparent, width: 1.5),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Table(
            defaultColumnWidth: const FixedColumnWidth(150),
            border: TableBorder.all(color: const Color(0xFF6A1B9A), width: 1),
            children: [
              /// ✅ العناوين - جدول العجل
              TableRow(
                decoration: BoxDecoration(
                  color: const Color(0xFF6A1B9A).withOpacity(0.15),
                ),
                children: const [
                  _TableCellHeader('م'),
                  _TableCellHeader('مكان التحميل'),
                  _TableCellHeader('مكان التعتيق'),
                  _TableCellHeader('نوع العربية'),
                  _TableCellHeader('النولون'),
                  _TableCellHeader('المبيت'),
                  _TableCellHeader('العطلة'),
                  _TableCellHeader('الإجراءات'),
                ],
              ),

              /// ✅ الصفوف - جدول العجل
              ...transportations.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final transport = item.transportation;

                return TableRow(
                  decoration: BoxDecoration(
                    color: index.isEven
                        ? Colors.white
                        : const Color(0xFFF8F9FA),
                  ),
                  children: [
                    _TableCellBody('${index + 1}'),
                    _TableCellBody(transport.loadingLocation),
                    _TableCellBody(transport.unloadingLocation),
                    _TableCellBody(transport.vehicleType),
                    _TableCellBody('${transport.wheelNolon} ج'),
                    _TableCellBody('${transport.wheelOvernight} ج'),
                    _TableCellBody('${transport.wheelHoliday} ج'),
                    _TableCellActions(
                      onEdit: () => _editTransportation(item, 'wheels'),
                      onDelete: () => _deleteTransportation(item),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // دالة تعديل الرحلة
  void _editTransportation(TransportationWithOffer item, String viewType) {
    final transportation = item.transportation;
    final isCompaniesView = viewType == 'companies';

    final loadingLocationController = TextEditingController(
      text: transportation.loadingLocation,
    );
    final unloadingLocationController = TextEditingController(
      text: transportation.unloadingLocation,
    );
    final vehicleTypeController = TextEditingController(
      text: transportation.vehicleType,
    );
    final nolonController = TextEditingController(
      text: isCompaniesView
          ? transportation.nolon.toString()
          : transportation.wheelNolon.toString(),
    );
    final overnightController = TextEditingController(
      text: isCompaniesView
          ? transportation.companyOvernight.toString()
          : transportation.wheelOvernight.toString(),
    );
    final holidayController = TextEditingController(
      text: isCompaniesView
          ? transportation.companyHoliday.toString()
          : transportation.wheelHoliday.toString(),
    );
    final notesController = TextEditingController(
      text: transportation.notes ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: t.TextDirection.rtl,
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'تعديل الرحلة - ${isCompaniesView ? 'الشركات' : 'العجل'}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Divider(color: const Color(0xFF3498DB).withOpacity(0.3)),

                  const SizedBox(height: 20),

                  // حقل مكان التحميل
                  _buildEditField(
                    'مكان التحميل',
                    'أدخل مكان التحميل',
                    loadingLocationController,
                    Icons.location_on,
                  ),

                  const SizedBox(height: 16),

                  // حقل مكان التعتيق
                  _buildEditField(
                    'مكان التعتيق',
                    'أدخل مكان التعتيق',
                    unloadingLocationController,
                    Icons.location_on,
                  ),

                  const SizedBox(height: 16),

                  // حقل نوع العربية
                  _buildEditField(
                    'نوع العربية',
                    'أدخل نوع العربية',
                    vehicleTypeController,
                    Icons.directions_car,
                  ),

                  const SizedBox(height: 16),

                  // حقل النولون
                  _buildEditField(
                    'النولون',
                    'أدخل النولون',
                    nolonController,
                    Icons.attach_money,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  // حقل المبيت
                  _buildEditField(
                    'المبيت',
                    'أدخل المبيت',
                    overnightController,
                    Icons.hotel,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  // حقل العطلة
                  _buildEditField(
                    'العطلة',
                    'أدخل العطلة',
                    holidayController,
                    Icons.beach_access,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 16),

                  // حقل الملاحظات
                  _buildEditField(
                    'ملاحظات',
                    'أدخل الملاحظات (اختياري)',
                    notesController,
                    Icons.note,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 24),

                  // أزرار الحفظ والإلغاء
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(
                              color: Color(0xFF2C3E50),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _updateTransportation(
                              item,
                              loadingLocationController.text,
                              unloadingLocationController.text,
                              vehicleTypeController.text,
                              nolonController.text,
                              overnightController.text,
                              holidayController.text,
                              notesController.text,
                              isCompaniesView,
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3498DB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'حفظ التعديلات',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditField(
    String label,
    String hint,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF3498DB)),
            filled: true,
            fillColor: const Color(0xFFF4F6F8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  // دالة تحديث الرحلة في Firebase
  Future<void> _updateTransportation(
    TransportationWithOffer item,
    String loadingLocation,
    String unloadingLocation,
    String vehicleType,
    String nolon,
    String overnight,
    String holiday,
    String notes,
    bool isCompaniesView,
  ) async {
    try {
      final offerRef = _firestore
          .collection('companies')
          .doc(item.companyId)
          .collection('priceOffers')
          .doc(item.offerId);

      // جلب العرض الحالي
      final offerDoc = await offerRef.get();
      final offerData = offerDoc.data() as Map<String, dynamic>;
      final List<dynamic> transportations = offerData['transportations'];

      // تحديث الرحلة المحددة
      final updatedTransportations = transportations.map((transport) {
        final map = transport as Map<String, dynamic>;
        if (map['loadingLocation'] == item.transportation.loadingLocation &&
            map['unloadingLocation'] == item.transportation.unloadingLocation &&
            map['vehicleType'] == item.transportation.vehicleType) {
          final updatedMap = {
            ...map,
            'loadingLocation': loadingLocation.trim(),
            'unloadingLocation': unloadingLocation.trim(),
            'vehicleType': vehicleType.trim(),
            'notes': notes.trim().isEmpty ? null : notes.trim(),
          };

          // تحديث الحقول حسب النوع
          if (isCompaniesView) {
            updatedMap['nolon'] =
                double.tryParse(nolon) ?? item.transportation.nolon;
            updatedMap['companyOvernight'] =
                double.tryParse(overnight) ??
                item.transportation.companyOvernight;
            updatedMap['companyHoliday'] =
                double.tryParse(holiday) ?? item.transportation.companyHoliday;
          } else {
            updatedMap['wheelNolon'] =
                double.tryParse(nolon) ?? item.transportation.wheelNolon;
            updatedMap['wheelOvernight'] =
                double.tryParse(overnight) ??
                item.transportation.wheelOvernight;
            updatedMap['wheelHoliday'] =
                double.tryParse(holiday) ?? item.transportation.wheelHoliday;
          }

          return updatedMap;
        }
        return transport;
      }).toList();

      // تحديث العرض في Firebase
      await offerRef.update({
        'transportations': updatedTransportations,
        'updatedAt': Timestamp.now(),
      });

      // إظهار رسالة نجاح
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تعديل الرحلة بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error updating transportation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في التعديل: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // دالة حذف الرحلة
  void _deleteTransportation(TransportationWithOffer item) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: t.TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                'تأكيد الحذف',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'هل أنت متأكد من حذف هذه الرحلة؟',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'المسار: ${item.transportation.loadingLocation} → ${item.transportation.unloadingLocation}',
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                'النولون: ${item.transportation.nolon} ج',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text(
                '⚠️ لا يمكن التراجع عن هذا الإجراء',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'إلغاء',
                style: TextStyle(color: Color(0xFF2C3E50)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _confirmDeleteTransportation(item);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );
  }

  // دالة تأكيد الحذف
  Future<void> _confirmDeleteTransportation(
    TransportationWithOffer item,
  ) async {
    try {
      final offerRef = _firestore
          .collection('companies')
          .doc(item.companyId)
          .collection('priceOffers')
          .doc(item.offerId);

      // جلب العرض الحالي
      final offerDoc = await offerRef.get();
      final offerData = offerDoc.data() as Map<String, dynamic>;
      final List<dynamic> transportations = offerData['transportations'];

      // تصفية الرحلة المطلوب حذفها
      final updatedTransportations = transportations.where((transport) {
        final map = transport as Map<String, dynamic>;
        return !(map['loadingLocation'] ==
                item.transportation.loadingLocation &&
            map['unloadingLocation'] == item.transportation.unloadingLocation &&
            map['vehicleType'] == item.transportation.vehicleType);
      }).toList();

      // إذا لم يتبقى أي رحلات، احذف العرض كاملاً
      if (updatedTransportations.isEmpty) {
        await offerRef.delete();
      } else {
        // وإلا قم بتحديث العرض
        await offerRef.update({
          'transportations': updatedTransportations,
          'updatedAt': Timestamp.now(),
        });
      }

      // إظهار رسالة نجاح
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الرحلة بنجاح'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error deleting transportation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الحذف: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.9),
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// نموذج مساعد لتخزين معلومات الرحلة مع معلومات العرض
class TransportationWithOffer {
  final Transportation transportation;
  final offerId;
  final String companyId;
  final PriceOffer offer;

  TransportationWithOffer({
    required this.transportation,
    required this.offerId,
    required this.companyId,
    required this.offer,
  });
}

class _TableCellBody extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;

  const _TableCellBody(this.text, {this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: textStyle,
      ),
    );
  }
}

class _TableCellHeader extends StatelessWidget {
  final String text;
  const _TableCellHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Color(0xFF2C3E50),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TableCellActions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TableCellActions({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // زر التعديل
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.edit, size: 16, color: Colors.blue),
            ),
            onPressed: onEdit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          // زر الحذف
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.delete, size: 16, color: Colors.red),
            ),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
