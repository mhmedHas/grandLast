// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';
// // import 'package:last/screens/prices_widget/templet_add.dart';

// // class AddPriceOfferScreen extends StatefulWidget {
// //   const AddPriceOfferScreen({super.key});

// //   @override
// //   State<AddPriceOfferScreen> createState() => _AddPriceOfferScreenState();
// // }

// // class _AddPriceOfferScreenState extends State<AddPriceOfferScreen> {
// //   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// //   List<QueryDocumentSnapshot<Map<String, dynamic>>> _companies = [];
// //   bool _isLoading = true;
// //   String _searchQuery = '';

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

// //   void _showError(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(content: Text(message), backgroundColor: Colors.red),
// //     );
// //   }

// //   List<QueryDocumentSnapshot<Map<String, dynamic>>> get _filteredCompanies {
// //     if (_searchQuery.isEmpty) return _companies;

// //     return _companies.where((company) {
// //       final name =
// //           company.data()['companyName']?.toString().toLowerCase() ?? '';
// //       return name.contains(_searchQuery.toLowerCase());
// //     }).toList();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return SingleChildScrollView(
// //       padding: const EdgeInsets.all(24),
// //       child: Center(
// //         child: ConstrainedBox(
// //           constraints: const BoxConstraints(maxWidth: 1200),
// //           child: Column(
// //             children: [
// //               Card(
// //                 elevation: 10,
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(22),
// //                 ),
// //                 child: Padding(
// //                   padding: const EdgeInsets.all(32),
// //                   child: Column(
// //                     children: [
// //                       const SizedBox(height: 32),
// //                       const Text(
// //                         'اختر شركة لإضافة عرض سعر',
// //                         style: TextStyle(
// //                           fontSize: 20,
// //                           fontWeight: FontWeight.bold,
// //                           color: Color(0xFF2C3E50),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 20),

// //                       // شريط البحث
// //                       _buildSearchBar(),
// //                       const SizedBox(height: 24),

// //                       _isLoading
// //                           ? const Center(child: CircularProgressIndicator())
// //                           : _filteredCompanies.isEmpty
// //                           ? const Column(
// //                               children: [
// //                                 Icon(
// //                                   Icons.business,
// //                                   size: 64,
// //                                   color: Colors.grey,
// //                                 ),
// //                                 SizedBox(height: 16),
// //                                 Text(
// //                                   'لا توجد شركات مسجلة',
// //                                   style: TextStyle(
// //                                     fontSize: 16,
// //                                     color: Colors.grey,
// //                                   ),
// //                                 ),
// //                               ],
// //                             )
// //                           : _buildCompaniesGrid(),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildSearchBar() {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: const Color(0xFF3498DB)),
// //       ),
// //       child: Row(
// //         children: [
// //           const Icon(Icons.search, color: Color(0xFF3498DB)),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: TextField(
// //               onChanged: (value) => setState(() => _searchQuery = value),
// //               decoration: const InputDecoration(
// //                 hintText: 'ابحث عن شركة...',
// //                 border: InputBorder.none,
// //                 hintStyle: TextStyle(color: Colors.grey),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildCompaniesGrid() {
// //     return GridView.builder(
// //       shrinkWrap: true,
// //       physics: const NeverScrollableScrollPhysics(),
// //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //         crossAxisCount: 4,
// //         crossAxisSpacing: 16,
// //         mainAxisSpacing: 16,
// //         childAspectRatio: 1.2,
// //       ),
// //       itemCount: _filteredCompanies.length,
// //       itemBuilder: (context, index) {
// //         final company = _filteredCompanies[index];
// //         final data = company.data();

// //         return _buildCompanyCard(company.id, data);
// //       },
// //     );
// //   }

// //   Widget _buildCompanyCard(String companyId, Map<String, dynamic> data) {
// //     return Card(
// //       elevation: 5,
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //       child: InkWell(
// //         onTap: () => _navigateToAddOfferForm(companyId, data['companyName']),
// //         borderRadius: BorderRadius.circular(16),
// //         child: Container(
// //           padding: const EdgeInsets.all(16),
// //           decoration: BoxDecoration(
// //             gradient: const LinearGradient(
// //               begin: Alignment.topLeft,
// //               end: Alignment.bottomRight,
// //               colors: [Color(0xFF3498DB), Color(0xFF2C3E50)],
// //             ),
// //             borderRadius: BorderRadius.circular(16),
// //           ),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               const Icon(Icons.business, color: Colors.white, size: 32),
// //               const SizedBox(height: 8),
// //               Text(
// //                 data['companyName'] ?? '',
// //                 style: const TextStyle(
// //                   color: Colors.white,
// //                   fontSize: 14,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //                 textAlign: TextAlign.center,
// //                 maxLines: 2,
// //                 overflow: TextOverflow.ellipsis,
// //               ),
// //               const SizedBox(height: 4),
// //               Text(
// //                 '${data['representatives']?.length ?? 0} مندوب',
// //                 style: const TextStyle(color: Colors.white70, fontSize: 11),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   void _navigateToAddOfferForm(String companyId, String companyName) {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (context) =>
// //             AddPriceOfferForm(companyId: companyId, companyName: companyName),
// //       ),
// //     );
// //   }
// // }
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:last/screens/prices_widget/templet_add.dart';

// class AddPriceOfferScreen extends StatefulWidget {
//   const AddPriceOfferScreen({super.key});

//   @override
//   State<AddPriceOfferScreen> createState() => _AddPriceOfferScreenState();
// }

// class _AddPriceOfferScreenState extends State<AddPriceOfferScreen> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   List<QueryDocumentSnapshot<Map<String, dynamic>>> _companies = [];
//   bool _isLoading = true;
//   String _searchQuery = '';

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

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), backgroundColor: Colors.red),
//     );
//   }

//   List<QueryDocumentSnapshot<Map<String, dynamic>>> get _filteredCompanies {
//     if (_searchQuery.isEmpty) return _companies;

//     return _companies.where((company) {
//       final name =
//           company.data()['companyName']?.toString().toLowerCase() ?? '';
//       return name.contains(_searchQuery.toLowerCase());
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(24),
//       child: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 1200),
//           child: Column(
//             children: [
//               Card(
//                 elevation: 10,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(22),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(32),
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 32),
//                       const Text(
//                         'اختر شركة لإضافة عرض سعر',
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF2C3E50),
//                         ),
//                       ),
//                       const SizedBox(height: 20),

//                       // شريط البحث
//                       _buildSearchBar(),
//                       const SizedBox(height: 24),

//                       _isLoading
//                           ? const Center(child: CircularProgressIndicator())
//                           : _filteredCompanies.isEmpty
//                           ? const Column(
//                               children: [
//                                 Icon(
//                                   Icons.business,
//                                   size: 64,
//                                   color: Colors.grey,
//                                 ),
//                                 SizedBox(height: 16),
//                                 Text(
//                                   'لا توجد شركات مسجلة',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ],
//                             )
//                           : _buildCompaniesList(),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // ✅ شريط البحث
//   Widget _buildSearchBar() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: const Color(0xFF3498DB)),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.search, color: Color(0xFF3498DB)),
//           const SizedBox(width: 12),
//           Expanded(
//             child: TextField(
//               onChanged: (value) => setState(() => _searchQuery = value),
//               decoration: const InputDecoration(
//                 hintText: 'ابحث عن شركة...',
//                 border: InputBorder.none,
//                 hintStyle: TextStyle(color: Colors.grey),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ✅ ليست الشركات بدل الجريد
//   Widget _buildCompaniesList() {
//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: _filteredCompanies.length,
//       itemBuilder: (context, index) {
//         final company = _filteredCompanies[index];
//         final data = company.data();

//         return _buildCompanyListTile(company.id, data);
//       },
//     );
//   }

//   // ✅ شكل عنصر الشركة في الليست
//   Widget _buildCompanyListTile(String companyId, Map<String, dynamic> data) {
//     return Card(
//       elevation: 4,
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//       child: ListTile(
//         onTap: () => _navigateToAddOfferForm(companyId, data['companyName']),
//         leading: const CircleAvatar(
//           backgroundColor: Color(0xFF3498DB),
//           child: Icon(Icons.business, color: Colors.white),
//         ),
//         title: Text(
//           data['companyName'] ?? '',
//           style: const TextStyle(
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF2C3E50),
//           ),
//         ),
//         subtitle: Text(
//           '${data['representatives']?.length ?? 0} مندوب',
//           style: const TextStyle(fontSize: 12),
//         ),
//         trailing: const Icon(
//           Icons.arrow_forward_ios,
//           size: 16,
//           color: Color(0xFF3498DB),
//         ),
//       ),
//     );
//   }

//   // ✅ الانتقال لصفحة إضافة عرض السعر
//   void _navigateToAddOfferForm(String companyId, String companyName) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) =>
//             AddPriceOfferForm(companyId: companyId, companyName: companyName),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:last/screens/1section/prices_widget/templet_add.dart';

class AddPriceOfferScreen extends StatefulWidget {
  const AddPriceOfferScreen({super.key});

  @override
  State<AddPriceOfferScreen> createState() => _AddPriceOfferScreenState();
}

class _AddPriceOfferScreenState extends State<AddPriceOfferScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> _companies = [];
  bool _isLoading = true;
  String _searchQuery = '';

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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> get _filteredCompanies {
    if (_searchQuery.isEmpty) return _companies;

    return _companies.where((company) {
      final name =
          company.data()['companyName']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          bool isTablet = constraints.maxWidth < 1000;

          return Column(
            children: [
              // _buildCustomAppBar(isMobile),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
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
                              child: Column(
                                children: [
                                  SizedBox(height: isMobile ? 16 : 32),
                                  Text(
                                    'اختر شركة لإضافة عرض سعر',
                                    style: TextStyle(
                                      fontSize: isMobile ? 18 : 20,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2C3E50),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: isMobile ? 12 : 20),
                                  // شريط البحث
                                  _buildSearchBar(isMobile),
                                  SizedBox(height: isMobile ? 16 : 24),
                                  _isLoading
                                      ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : _filteredCompanies.isEmpty
                                      ? _buildEmptyState(isMobile)
                                      : _buildCompaniesList(isMobile),
                                ],
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

  // ✅ App Bar
  // Widget _buildCustomAppBar(bool isMobile) {
  //   return Container(
  //     padding: EdgeInsets.symmetric(
  //       horizontal: isMobile ? 16 : 24,
  //       vertical: isMobile ? 12 : 20,
  //     ),
  //     decoration: const BoxDecoration(
  //       gradient: LinearGradient(
  //         begin: Alignment.centerRight,
  //         end: Alignment.centerLeft,
  //         colors: [Color(0xFF1B4F72), Color(0xFF3498DB)],
  //       ),
  //       boxShadow: [
  //         BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
  //       ],
  //     ),
  //     child: SafeArea(child: Row(children: [

  //         ],
  //       )),
  //   );
  // }

  // ✅ شريط البحث
  Widget _buildSearchBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        border: Border.all(color: const Color(0xFF3498DB)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: const Color(0xFF3498DB),
            size: isMobile ? 20 : 24,
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'ابحث عن شركة...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.grey,
                  fontSize: isMobile ? 14 : 16,
                ),
              ),
              style: TextStyle(fontSize: isMobile ? 14 : 16),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ حالة عدم وجود شركات
  Widget _buildEmptyState(bool isMobile) {
    return Column(
      children: [
        Icon(Icons.business, size: isMobile ? 48 : 64, color: Colors.grey),
        SizedBox(height: isMobile ? 12 : 16),
        Text(
          'لا توجد شركات مسجلة',
          style: TextStyle(fontSize: isMobile ? 14 : 16, color: Colors.grey),
        ),
      ],
    );
  }

  // ✅ ليست الشركات
  Widget _buildCompaniesList(bool isMobile) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _filteredCompanies.length,
      itemBuilder: (context, index) {
        final company = _filteredCompanies[index];
        final data = company.data();
        return _buildCompanyListTile(company.id, data, isMobile);
      },
    );
  }

  // ✅ شكل عنصر الشركة في الليست
  Widget _buildCompanyListTile(
    String companyId,
    Map<String, dynamic> data,
    bool isMobile,
  ) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 10 : 14),
      ),
      child: ListTile(
        onTap: () => _navigateToAddOfferForm(companyId, data['companyName']),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF3498DB),
          radius: isMobile ? 18 : 20,
          child: Icon(
            Icons.business,
            color: Colors.white,
            size: isMobile ? 16 : 20,
          ),
        ),
        title: Text(
          data['companyName'] ?? '',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
            fontSize: isMobile ? 14 : 16,
          ),
        ),
        subtitle: Text(
          '${data['representatives']?.length ?? 0} مندوب',
          style: TextStyle(fontSize: isMobile ? 12 : 14),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: isMobile ? 14 : 16,
          color: const Color(0xFF3498DB),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 8 : 12,
        ),
      ),
    );
  }

  // ✅ الانتقال لصفحة إضافة عرض السعر
  void _navigateToAddOfferForm(String companyId, String companyName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddPriceOfferForm(companyId: companyId, companyName: companyName),
      ),
    );
  }
}
