// import 'package:flutter/material.dart';
// import 'package:last/screens/2section/driver_work/driver_work_account.dart';
// import 'package:last/screens/2section/driver_work/driver_work_amal.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _selectedIndex = 0;

//   final List<Widget> _pages = [
//     const DriverWorkPage(),
//     const DriverAccountsPage(),
//   ];

//   final List<BottomNavigationBarItem> _bottomNavItems = [
//     const BottomNavigationBarItem(
//       icon: Icon(Icons.work_outline),
//       activeIcon: Icon(Icons.work),
//       label: 'الشغل',
//     ),
//     const BottomNavigationBarItem(
//       icon: Icon(Icons.account_balance_wallet_outlined),
//       activeIcon: Icon(Icons.account_balance_wallet),
//       label: 'الحسابات',
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: const Color(0xFF1B4F72),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               spreadRadius: 1,
//               blurRadius: 8,
//               offset: const Offset(0, -2),
//             ),
//           ],
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: ClipRRect(
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//           child: BottomNavigationBar(
//             currentIndex: _selectedIndex,
//             onTap: (index) {
//               setState(() {
//                 _selectedIndex = index;
//               });
//             },
//             items: _bottomNavItems,
//             backgroundColor: const Color(0xFF1B4F72),
//             selectedItemColor: Colors.white,
//             unselectedItemColor: Colors.white.withOpacity(0.7),
//             selectedIconTheme: const IconThemeData(size: 26),
//             unselectedIconTheme: const IconThemeData(size: 22),
//             selectedLabelStyle: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Cairo',
//             ),
//             unselectedLabelStyle: const TextStyle(
//               fontSize: 11,
//               fontFamily: 'Cairo',
//             ),
//             type: BottomNavigationBarType.fixed,
//             elevation: 0,
//           ),
//         ),
//       ),
//     );
//   }
// // }
// import 'package:flutter/material.dart';
// import 'package:last/screens/2section/driver_work/driver_work_account.dart';
// import 'package:last/screens/2section/driver_work/driver_work_amal.dart';

// class DriverMainPage extends StatefulWidget {
//   const DriverMainPage({super.key});

//   @override
//   State<DriverMainPage> createState() => _DriverMainPageState();
// }

// class _DriverMainPageState extends State<DriverMainPage> {
//   int _selectedIndex = 0;

//   final List<Widget> _pages = [
//     const DriverWorkPage(),
//     const DriverAccountsPage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: const Color(0xFF1B4F72),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.2),
//               spreadRadius: 1,
//               blurRadius: 8,
//               offset: const Offset(0, -2),
//             ),
//           ],
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//         ),
//         child: ClipRRect(
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(20),
//             topRight: Radius.circular(20),
//           ),
//           child: BottomNavigationBar(
//             currentIndex: _selectedIndex,
//             onTap: (index) {
//               setState(() {
//                 _selectedIndex = index;
//               });
//             },
//             items: const [
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.work_outline),
//                 activeIcon: Icon(Icons.work),
//                 label: 'الشغل',
//               ),
//               BottomNavigationBarItem(
//                 icon: Icon(Icons.account_balance_wallet_outlined),
//                 activeIcon: Icon(Icons.account_balance_wallet),
//                 label: 'الحسابات',
//               ),
//             ],
//             backgroundColor: const Color(0xFF1B4F72),
//             selectedItemColor: Colors.white,
//             unselectedItemColor: Colors.white.withOpacity(0.7),
//             selectedIconTheme: const IconThemeData(size: 26),
//             unselectedIconTheme: const IconThemeData(size: 22),
//             selectedLabelStyle: const TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.bold,
//               fontFamily: 'Cairo',
//             ),
//             unselectedLabelStyle: const TextStyle(
//               fontSize: 11,
//               fontFamily: 'Cairo',
//             ),
//             type: BottomNavigationBarType.fixed,
//             elevation: 0,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:last/screens/2section/driver_work/driver_work_account.dart';
import 'package:last/screens/2section/driver_work/driver_work_amal.dart';

class DriverMainPage extends StatefulWidget {
  const DriverMainPage({super.key});

  @override
  State<DriverMainPage> createState() => _DriverMainPageState();
}

class _DriverMainPageState extends State<DriverMainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DriverWorkPage(),
    const DriverAccountsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B4F72),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.work_outline),
                activeIcon: Icon(Icons.work),
                label: 'الشغل',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet_outlined),
                activeIcon: Icon(Icons.account_balance_wallet),
                label: 'الحسابات',
              ),
            ],
            backgroundColor: const Color(0xFF1B4F72),
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.7),
            selectedIconTheme: const IconThemeData(size: 26),
            unselectedIconTheme: const IconThemeData(size: 22),
            selectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontFamily: 'Cairo',
            ),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
