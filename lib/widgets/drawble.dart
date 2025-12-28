// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// class AppDrawer extends StatelessWidget {
//   final String currentRoute;
//   final Function(String) onNavigation;

//   const AppDrawer({
//     Key? key,
//     required this.currentRoute,
//     required this.onNavigation,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: Container(
//         color: const Color(0xFFF8F9FA),
//         child: Column(
//           children: [
//             // Header
//             Container(
//               color: const Color(0xFF2C3E50),
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 20),
//                   Row(
//                     children: [
//                       Container(
//                         width: 50,
//                         height: 50,
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF3498DB),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Icon(
//                           Icons.local_shipping,
//                           color: Colors.white,
//                           size: 28,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       const Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'نيون جراند',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             'نظام إدارة الشحنات',
//                             style: TextStyle(
//                               color: Color(0xFFBDC3C7),
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),

//             // Menu Items
//             Expanded(
//               child: ListView(
//                 padding: EdgeInsets.zero,
//                 children: [
//                   // الرئيسية
//                   _buildSectionTitle('الرئيسية'),
//                   _buildMenuItem(
//                     icon: Icons.dashboard,
//                     title: 'لوحة التحكم',
//                     route: '/dashboard',
//                     isSelected: currentRoute == '/dashboard',
//                     onTap: () {
//                       onNavigation('/dashboard');
//                       Navigator.pop(context);
//                     },
//                   ),

//                   // العمليات
//                   _buildSectionTitle('العمليات'),
//                   _buildMenuItem(
//                     icon: Icons.assignment,
//                     title: 'العمليات اليومية',
//                     route: '/daily-operations',
//                     isSelected: currentRoute == '/daily-operations',
//                     onTap: () {
//                       onNavigation('/daily-operations');
//                       Navigator.pop(context);
//                     },
//                   ),
//                   _buildMenuItem(
//                     icon: Icons.calendar_month,
//                     title: 'السجل الشهري',
//                     route: '/monthly-log',
//                     isSelected: currentRoute == '/monthly-log',
//                     onTap: () {
//                       onNavigation('/monthly-log');
//                       Navigator.pop(context);
//                     },
//                   ),

//                   // الإدارة
//                   _buildSectionTitle('الإدارة'),
//                   _buildMenuItem(
//                     icon: Icons.people,
//                     title: 'العملاء',
//                     route: '/clients',
//                     isSelected: currentRoute == '/clients',
//                     onTap: () {
//                       onNavigation('/clients');
//                       Navigator.pop(context);
//                     },
//                   ),
//                   _buildMenuItem(
//                     icon: Icons.local_offer,
//                     title: 'عروض الأسعار',
//                     route: '/pricing',
//                     isSelected: currentRoute == '/pricing',
//                     onTap: () {
//                       onNavigation('/pricing');
//                       Navigator.pop(context);
//                     },
//                   ),

//                   // المالية
//                   _buildSectionTitle('المالية'),
//                   _buildMenuItem(
//                     icon: Icons.receipt_long,
//                     title: 'المصروفات',
//                     route: '/expenses',
//                     isSelected: currentRoute == '/expenses',
//                     onTap: () {
//                       onNavigation('/expenses');
//                       Navigator.pop(context);
//                     },
//                   ),
//                   _buildMenuItem(
//                     icon: Icons.assessment,
//                     title: 'تحليل الأرباح',
//                     route: '/profit-analysis',
//                     isSelected: currentRoute == '/profit-analysis',
//                     onTap: () {
//                       onNavigation('/profit-analysis');
//                       Navigator.pop(context);
//                     },
//                   ),
//                   _buildMenuItem(
//                     icon: Icons.safety_check,
//                     title: 'الملخص الشهري',
//                     route: '/monthly-summary',
//                     isSelected: currentRoute == '/monthly-summary',
//                     onTap: () {
//                       onNavigation('/monthly-summary');
//                       Navigator.pop(context);
//                     },
//                   ),
//                   _buildMenuItem(
//                     icon: Icons.account_balance,
//                     title: 'الخزينة',
//                     route: '/treasury',
//                     isSelected: currentRoute == '/treasury',
//                     onTap: () {
//                       onNavigation('/treasury');
//                       Navigator.pop(context);
//                     },
//                   ),
//                   _buildMenuItem(
//                     icon: Icons.swap_horiz,
//                     title: 'الدائنون والمدينون',
//                     route: '/debits-credits',
//                     isSelected: currentRoute == '/debits-credits',
//                     onTap: () {
//                       onNavigation('/debits-credits');
//                       Navigator.pop(context);
//                     },
//                   ),
//                   _buildMenuItem(
//                     icon: Icons.business,
//                     title: 'رأس مال الشركة',
//                     route: '/company-capital',
//                     isSelected: currentRoute == '/company-capital',
//                     onTap: () {
//                       onNavigation('/company-capital');
//                       Navigator.pop(context);
//                     },
//                   ),
//                   _buildMenuItem(
//                     icon: Icons.safety_check,
//                     title: 'الضرائب',
//                     route: '/taxes',
//                     isSelected: currentRoute == '/taxes',
//                     onTap: () {
//                       onNavigation('/taxes');
//                       Navigator.pop(context);
//                     },
//                   ),
//                 ],
//               ),
//             ),

//             // Footer
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(top: BorderSide(color: Colors.grey[300]!)),
//               ),
//               child: Column(
//                 children: [
//                   ListTile(
//                     leading: const Icon(
//                       Icons.settings,
//                       color: Color(0xFF2C3E50),
//                     ),
//                     title: const Text(
//                       'الإعدادات',
//                       style: TextStyle(color: Color(0xFF2C3E50)),
//                     ),
//                     onTap: () {
//                       onNavigation('/settings');
//                       Navigator.pop(context);
//                     },
//                   ),
//                   ListTile(
//                     leading: const Icon(Icons.logout, color: Color(0xFFE74C3C)),
//                     title: const Text(
//                       'تسجيل الخروج',
//                       style: TextStyle(color: Color(0xFFE74C3C)),
//                     ),
//                     onTap: () {
//                       // Add logout logic here
//                       Navigator.pop(context);
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//           color: Color(0xFF7F8C8D),
//           letterSpacing: 1,
//         ),
//       ),
//     );
//   }

//   Widget _buildMenuItem({
//     required IconData icon,
//     required String title,
//     required String route,
//     required bool isSelected,
//     required VoidCallback onTap,
//   }) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: isSelected
//             ? const Color(0xFF3498DB).withOpacity(0.1)
//             : Colors.transparent,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: ListTile(
//         leading: Icon(
//           icon,
//           color: isSelected ? const Color(0xFF3498DB) : const Color(0xFF2C3E50),
//           size: 22,
//         ),
//         title: Text(
//           title,
//           style: TextStyle(
//             fontSize: 14,
//             color: isSelected
//                 ? const Color(0xFF3498DB)
//                 : const Color(0xFF2C3E50),
//             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//         trailing: isSelected
//             ? const Icon(Icons.check_circle, color: Color(0xFF3498DB), size: 20)
//             : null,
//         onTap: onTap,
//       ),
//     );
//   }
// }
