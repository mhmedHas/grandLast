import 'package:flutter/material.dart';
import 'package:last/screens/2section/company_work/company_account.dart';
import 'package:last/screens/2section/company_work/company_work.dart';

class CompanyMainPage extends StatefulWidget {
  const CompanyMainPage({super.key});

  @override
  State<CompanyMainPage> createState() => _CompanyMainPageState();
}

class _CompanyMainPageState extends State<CompanyMainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CompanyWorkPage(), // صفحة شغل الشركات
    const CompaniesAccountsPage(), // صفحة حسابات الشركات
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
                icon: Icon(Icons.business_outlined),
                activeIcon: Icon(Icons.business),
                label: 'شغل الشركات',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_outlined),
                activeIcon: Icon(Icons.account_balance),
                label: 'حسابات الشركات',
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
