import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:last/Splash.dart';
import 'package:last/firebase_options.dart';
import 'package:last/screens/1section/DailyWork_page.dart';
import 'package:last/screens/2section/company_work/company_home.dart';
import 'package:last/screens/2section/driver_work/driver_work.dart';
import 'package:last/screens/2section/employee_page_component/employee.dart';
import 'package:last/screens/1section/month_history.dart';
import 'package:last/screens/3section/Taxes_page.dart';
import 'package:last/screens/3section/company_partners.dart';
import 'package:last/screens/3section/kazna/kazna_home.dart';
import 'package:last/screens/3section/mony_head.dart';
import 'package:last/screens/3section/nasriat.dart';
import 'package:last/screens/3section/sallaff.dart';
import 'screens/1section/company.dart';
import 'screens/1section/prices.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ShippingCompanyApp());
}

class ShippingCompanyApp extends StatelessWidget {
  const ShippingCompanyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام إدارة شركات الشحن',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo',
        useMaterial3: true,
      ),
      home: Splash(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  _MainDashboardState createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;
  final List<Widget> _pages = [
    CompanyPage(),
    PriceOffersMainPage(),
    DailyWorkPage(),
    MonthlyRecordPage(),
    EmployeesPage(),
    CompanyMainPage(),
    DriverMainPage(), // المصروفات

    ExpensesPage(),
    LoansPage(), // النثرسات
    MainTreasuryPage(), // الضرائب
    TaxesPage(), // الملخص الشهري
    MonthlyProfitsPage(),
    CapitalManagementPage(),

    // الدائنون والمدينون
  ];

  final List<String> _pageTitles = [
    'الشركات',
    'عروض الأسعار',
    'العمليات اليومية',
    'السجل الشهري',
    'الموظفين',
    'شغل الشركات',
    'شغل السائقين',
    'النثرياات',
    'السلف',

    'الخزينة',
    'الضرائب',

    'الارباج  ',

    'راس مال الشركه ',
  ];

  final List<IconData> _pageIcons = [
    Icons.business,
    Icons.local_shipping,
    Icons.assignment,
    Icons.calendar_month,
    Icons.person,
    Icons.business_center,
    Icons.directions_car,
    Icons.receipt_long,
    Icons.kayaking_sharp,

    Icons.gavel,
    Icons.assessment,
    Icons.summarize,
    Icons.swap_horiz,
    Icons.money,
  ];

  // للتحكم في فتح وإغلاق الـ drawer في الشاشات الصغيرة
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // تحديد نوع الشاشة بناء على العرض
        bool isMobile = constraints.maxWidth < 600;
        bool isTablet =
            constraints.maxWidth < 1000 && constraints.maxWidth >= 600;

        return Scaffold(
          key: _scaffoldKey,
          // drawer للشاشات الصغيرة
          drawer: isMobile ? _buildDrawer() : null,
          body: isMobile ? _buildMobileLayout() : _buildDesktopLayout(isTablet),
        );
      },
    );
  }

  // بناء واجهة الجوال
  Widget _buildMobileLayout() {
    return SafeArea(
      child: Column(
        children: [
          // App Bar للجوال
          Container(
            height: 60,
            color: Color(0xFF2C3E50),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.menu, color: Colors.white),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  SizedBox(width: 10),
                  ClipOval(
                    child: Image.asset(
                      'assets/image/app_icon.png',
                      width: 38,
                      height: 38,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نيو جراند',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'نظام إدارة الشحنات',
                        style: TextStyle(color: Colors.grey[300], fontSize: 10),
                      ),
                    ],
                  ),
                  Spacer(),
                  // إضافة زر للصفحة الحالية
                  SingleChildScrollView(
                    child: Text(
                      _pageTitles[_selectedIndex],
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // المحتوى الرئيسي
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
    );
  }

  // بناء واجهة الكمبيوتر والتابلت
  Widget _buildDesktopLayout(bool isTablet) {
    return Row(
      children: [
        // Sidebar مع إمكانية التمرير
        Container(
          width: isTablet ? 220 : 270,
          color: Color(0xFF2C3E50),
          child: _buildSidebarContent(isTablet),
        ),

        // Main Content
        Expanded(child: _pages[_selectedIndex]),
      ],
    );
  }

  // بناء محتوى السايدبار القابل للتمرير
  Widget _buildSidebarContent(bool isTablet) {
    return Column(
      children: [
        // Header Section
        SizedBox(
          height: 120, // ارتفاع ثابت للرأس
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/image/app_icon.png',
                      width: 60,
                      height: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: isTablet ? 8 : 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نيو جراند',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isTablet ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'نظام إدارة الشحنات',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: isTablet ? 10 : 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 15),
              Container(
                width: 40,
                height: 4,
                color: Colors.blue[300],
                margin: EdgeInsets.only(bottom: 10),
              ),
            ],
          ),
        ),

        // Scrollable Menu Items
        Expanded(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // قسم النظام الرئيسي
                _buildSidebarSection('النظام الرئيسي', 0, 3),
                SizedBox(height: 20),

                // قسم الموظفين والعمل
                _buildSidebarSection('الموظفين والعمل', 4, 6),
                SizedBox(height: 20),

                // قسم المالية والإدارة
                _buildSidebarSection('المالية والإدارة', 7, _pages.length - 1),

                // مساحة إضافية في الأسفل
                SizedBox(height: 30),

                // مؤشر أن هناك المزيد من المحتوى
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey[500],
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // وظيفة مساعدة لبناء أقسام السايدبار
  Widget _buildSidebarSection(String title, int startIndex, int endIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(width: 20, height: 1, color: Colors.grey[600]),
            ],
          ),
        ),
        SizedBox(height: 8),
        Column(
          children: List.generate(endIndex - startIndex + 1, (index) {
            int itemIndex = startIndex + index;
            bool selected = _selectedIndex == itemIndex;
            return _buildSidebarItem(
              _pageIcons[itemIndex],
              _pageTitles[itemIndex],
              selected,
              itemIndex,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSidebarItem(
    IconData icon,
    String title,
    bool selected,
    int index,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: selected ? Colors.white.withOpacity(0.15) : Colors.transparent,
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: selected ? Colors.blue[300] : Colors.grey[700],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: selected ? Colors.white : Colors.grey[300],
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.blue[300] : Colors.white,
            fontSize: 14,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: selected
            ? Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.blue[300],
                  shape: BoxShape.circle,
                ),
              )
            : null,
        selected: selected,
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        hoverColor: Colors.blue.withOpacity(0.1),
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  // بناء الـ drawer للجوال
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Color(0xFF2C3E50),
      child: Column(
        children: [
          // Header
          Container(
            height: 150,
            color: Color(0xFF34495E),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/image/app_icon.png',
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'نيو جراند',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    'نظام إدارة الشحنات',
                    style: TextStyle(color: Colors.grey[300], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // قسم النظام الرئيسي
                  _buildDrawerSection('النظام الرئيسي', 0, 3),

                  // قسم الموظفين والعمل
                  _buildDrawerSection('الموظفين والعمل', 4, 6),

                  // قسم المالية والإدارة
                  _buildDrawerSection('المالية والإدارة', 7, _pages.length - 1),

                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerSection(String title, int startIndex, int endIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Column(
          children: List.generate(endIndex - startIndex + 1, (index) {
            int itemIndex = startIndex + index;
            bool selected = _selectedIndex == itemIndex;
            return _buildDrawerItem(
              _pageIcons[itemIndex],
              _pageTitles[itemIndex],
              selected,
              itemIndex,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    bool selected,
    int index,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: selected ? Colors.white.withOpacity(0.15) : Colors.transparent,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: selected ? Colors.blue[300] : Colors.grey[700],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: selected ? Colors.white : Colors.grey[300],
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.blue[300] : Colors.white,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: selected,
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context); // إغلاق الـ drawer
        },
      ),
    );
  }
}
