import 'package:flutter/material.dart';
import 'package:last/screens/3section/kazna/kazna_income.dart';
import 'package:last/screens/3section/kazna/kazna_outcome.dart';

class MainTreasuryPage extends StatefulWidget {
  const MainTreasuryPage({super.key});

  @override
  State<MainTreasuryPage> createState() => _MainTreasuryPageState();
}

class _MainTreasuryPageState extends State<MainTreasuryPage> {
  int _currentIndex = 0;

  // صفحات التطبيق
  final List<Widget> _pages = [
    IncomePage(), // صفحة الفلوس الداخلة
    ExpensePage(), // صفحة الفلوس الخارجة
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: const Color(0xFF1B4F72),
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      items: const [
        // BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
        BottomNavigationBarItem(icon: Icon(Icons.login), label: 'داخل الخزنة'),
        BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'خارج الخزنة'),
      ],
    );
  }
}
