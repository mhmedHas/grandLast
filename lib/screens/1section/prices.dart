import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:last/screens/1section/prices_widget/add.dart';
import 'package:last/screens/1section/prices_widget/list_offers.dart';

class PriceOffersMainPage extends StatefulWidget {
  const PriceOffersMainPage({super.key});

  @override
  State<PriceOffersMainPage> createState() => _PriceOffersMainPageState();
}

class _PriceOffersMainPageState extends State<PriceOffersMainPage> {
  int _currentTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Column(
        children: [
          _buildCustomAppBar(),
          Expanded(
            child: _currentTab == 0
                ? const AddPriceOfferScreen()
                : const PriceOffersListScreen(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // =================== APP BAR ===================
  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
            const Icon(Icons.price_change, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            const Text(
              'عروض الأسعار',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
            const Spacer(flex: 12),
            StreamBuilder<DateTime>(
              stream: Stream.periodic(
                const Duration(seconds: 1),
                (_) => DateTime.now(),
              ),
              builder: (context, snapshot) {
                final now = snapshot.data ?? DateTime.now();

                // تحويل إلى نظام 12 ساعة
                int hour12 = now.hour % 12;
                if (hour12 == 0) hour12 = 12; // تحويل 0 إلى 12

                // تحديد AM/PM
                String period = now.hour < 12 ? 'AM' : 'PM';

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
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  // =================== BOTTOM NAVIGATION ===================
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Color(0xFF1B4F72), Color(0xFF3498DB)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) => setState(() => _currentTab = index),
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_business),
            label: 'إضافة عرض سعر',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'قائمة عروض  الاسعار',
          ),
        ],
      ),
    );
  }
}
